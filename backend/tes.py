# ================= IMPORT =================
from flask import Flask, request, jsonify
from flask_cors import CORS
from database.db import get_db
import pandas as pd
import numpy as np
import joblib
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from flask_mail import Mail, Message
import random
import os
from dotenv import load_dotenv
from datetime import timedelta
from flask_jwt_extended import (
    JWTManager,
    create_access_token
)

load_dotenv()

app = Flask(__name__)
CORS(app)
# Ambil jalur direktori tempat file app.py ini berada
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Membuat folder 'uploads' secara otomatis jika belum ada di laptop
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Membuat folder uploads otomatis jika belum ada
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Pastikan Flask mengizinkan akses statis ke folder uploads agar foto bisa dipanggil lewat URL
@app.route('/uploads/<filename>')
def upload_file(filename):
    from flask import send_from_directory
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# ================= JWT CONFIG =================
app.config["JWT_SECRET_KEY"] = "SECRET_KEY_KAMU"
jwt = JWTManager(app)

app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 465
app.config['MAIL_USE_TLS'] = False
app.config['MAIL_USE_SSL'] = True

app.config['MAIL_USERNAME'] = os.getenv("MAIL_USERNAME")
app.config['MAIL_PASSWORD'] = os.getenv("MAIL_PASSWORD")

app.config['MAIL_DEFAULT_SENDER'] = os.getenv("MAIL_USERNAME")

mail = Mail(app)

# ================= CORS =================
CORS(app, resources={r"/api/*": {"origins": "*"}})
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True

# ================= LOAD MODEL DECISION TREE =================
try:
    model = joblib.load("model.pkl")
except Exception as e:
    print("\n===== ERROR LOAD MODEL =====")
    print(f"Gagal memuat model.pkl: {str(e)}")
    model = None

# ================= HOME =================
@app.route("/")
def home():
    return "API Konseling & Mental Health Aktif 🚀"

DEFAULT_IMAGE = "http://localhost:5000/uploads/default.jpg"

# ================= LOGIN =================
@app.route("/api/login", methods=["POST"])
def login():

    try:

        db = get_db()

        cur = db.cursor(dictionary=True)

        data = request.get_json(silent=True)

        if not data:

            return jsonify({

                "status": "error",

                "message": "Data tidak dikirim"

            }), 400

        username = data.get("username")

        password = data.get("password")

        if not username or not password:

            return jsonify({

                "status": "error",

                "message": "Username & password wajib diisi"

            }), 400

        # ================= CEK USER =================
        cur.execute(
            """
             SELECT id, username, password, role, foto_profil
            FROM user
            WHERE username=%s
            """,
            (username,)
        )

        user = cur.fetchone()

        # ================= VALIDASI PASSWORD =================
        if user and check_password_hash(
            user["password"],
            password
        ):

            # ================= BUAT JWT TOKEN =================
            token = create_access_token(

                identity=str(user["id"])
            )

            # ================= HAPUS PASSWORD =================
            user.pop("password", None)


            # 🔥 DEFAULT FOTO JIKA NULL
            if not user["foto_profil"]:
                user["foto_profil"] = DEFAULT_IMAGE


            # ================= RESPONSE =================
            return jsonify({

                "status": "success",

                "message": "Login berhasil",

                "token": token,

                "data": user
            })
        

        # ================= LOGIN GAGAL =================
        return jsonify({

            "status": "error",

            "message": "Username atau password salah"

        }), 401

    except Exception as e:

        print("LOGIN ERROR:", e)

        return jsonify({

            "status": "error",

            "message": "Terjadi kesalahan server"

        }), 500
    
@app.route("/api/update_foto", methods=["POST"])
def update_foto():
    try:
        user_id = request.form.get("id")
        file = request.files.get("foto_profil")

        if not user_id:
            return jsonify({"status": "error", "message": "ID kosong"}), 400

        if not file:
            return jsonify({"status": "error", "message": "File kosong"}), 400

        ext = file.filename.split('.')[-1]
        filename = f"user_{user_id}.{ext}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)

        # Simpan berkas fisik ke folder uploads
        file.save(filepath)

        # Gunakan URL absolut agar gambar bisa dimuat di Flutter Web & Mobile
        file_url = f"{request.host_url}uploads/{filename}"

        # 🔥 UPDATE DATABASE MYSQL
        db = get_db()
        cur = db.cursor()

        cur.execute(
            "UPDATE user SET foto_profil=%s WHERE id=%s",
            (file_url, user_id)
        )
        db.commit()

        # 🟢 KEY DIUBAH MENJADI 'foto_profil' AGAR DIBACA SUKSES OLEH FLUTTER
        return jsonify({
            "status": "success",
            "message": "Foto profil berhasil diperbarui",
            "foto_profil": file_url
        }), 200

    except Exception as e:
        print("UPLOAD ERROR:", e)
        return jsonify({"status": "error", "message": str(e)}), 500

# ================= REGISTER =================
@app.route("/api/register", methods=["POST"])
def register():

    try:

        data = request.get_json(
            silent=True
        )

        if not data:

            return jsonify({

                "status": "error",

                "message": "Data kosong"
            }), 400

        email = data.get("email")

        username = data.get("username")

        password = data.get("password")

        # ================= VALIDASI =================
        if (
            not email or
            not username or
            not password
        ):

            return jsonify({

                "status": "error",

                "message": "Semua field wajib diisi"
            }), 400

        db = get_db()

        cur = db.cursor(
            dictionary=True
        )

        # ================= CEK EMAIL =================
        cur.execute(
            """
            SELECT *
            FROM user
            WHERE email=%s
            """,
            (email,)
        )

        cek_email = cur.fetchone()

        if cek_email:

            return jsonify({

                "status": "error",

                "message": "Email sudah digunakan"
            }), 400

        # ================= CEK USERNAME =================
        cur.execute(
            """
            SELECT *
            FROM user
            WHERE username=%s
            """,
            (username,)
        )

        cek_user = cur.fetchone()

        if cek_user:

            return jsonify({

                "status": "error",

                "message": "Username sudah digunakan"
            }), 400

        # ================= HASH PASSWORD =================
        hashed_password = generate_password_hash(
            password
        )

        # ================= INSERT USER =================
        cur.execute(
            """
            INSERT INTO user (
                email,
                username,
                password,
                role
            )
            VALUES (%s,%s,%s,%s)
            """,
            (
                email,
                username,
                hashed_password,
                "user"
            )
        )

        db.commit()

        return jsonify({

            "status": "success",

            "message": "Register berhasil"
        })

    except Exception as e:

        print(
            "REGISTER ERROR:",
            str(e)
        )

        return jsonify({

            "status": "error",

            "message": "Register gagal"
        }), 500

# ================= KONSULTASI HYBRID (PROSES BERAPAPUN GEJALA) =================
@app.route("/api/konsultasi", methods=["POST"])
def konsultasi():
    try:
        data = request.get_json(silent=True)
        if not data or "gejala" not in data:
            return jsonify({"status": "error", "message": "Data gejala tidak ditemukan"}), 400

        # Ambil list gejala dari Flutter dan bersihkan spasi/kapital
        gejala_user = [str(g).lower().strip() for g in data.get("gejala", [])]
        print("GEJALA YANG DITERIMA DARI FLUTTER:", gejala_user)

        # JIKA USER TIDAK MENCENTANG SAMA SEKALI (KOSONG)
        if not gejala_user:
            return jsonify({
                "status": "success",
                "hasil": "Normal",
                "level": "Normal",
                "stress_percentage": 0,
                "kecemasan_percentage": 0,
                "depresi_percentage": 0,
                "saran": "Anda tidak memilih gejala apapun. Tetap jaga kesehatan mental dan fisik Anda!",
                "skor": {"stres": 0, "kecemasan": 0, "depresi": 0}
            })

        # Ambil koneksi database menggunakan fungsi bawaan Anda
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM gejala")
        daftar_gejala_db = cursor.fetchall()
        cursor.close()

        user_bobot = {"stres": 0, "kecemasan": 0, "depresi": 0}
        max_bobot = {"stres": 0, "kecemasan": 0, "depresi": 0}

        # Lakukan iterasi kecocokan data text database dengan kiriman Flutter
        for g in daftar_gejala_db:
            kategori = g['kategori'].lower().strip() if g.get('kategori') else 'stres'
            bobot = int(g['bobot']) if g.get('bobot') is not None else 2
            nama_gejala_db = str(g['nama_gejala']).lower().strip()

            if kategori in max_bobot:
                max_bobot[kategori] += bobot

            if nama_gejala_db in gejala_user:
                if kategori in user_bobot:
                    user_bobot[kategori] += bobot
                    print(f"-> COCOK: '{g['nama_gejala']}' masuk kategori [{kategori}] dengan bobot {bobot}")

        print("TOTAL BOBOT PILIHAN USER:", user_bobot)
        print("TOTAL BOBOT MAKSIMAL DB:", max_bobot)

        # Hitung persentase akhir (Anti Error DivisionByZero)
        stress_percentage = round((user_bobot["stres"] / max_bobot["stres"] * 100)) if max_bobot["stres"] > 0 else 0
        kecemasan_percentage = round((user_bobot["kecemasan"] / max_bobot["kecemasan"] * 100)) if max_bobot["kecemasan"] > 0 else 0
        depresi_percentage = round((user_bobot["depresi"] / max_bobot["depresi"] * 100)) if max_bobot["depresi"] > 0 else 0

        # Menentukan hasil diagnosis tertinggi
        persentase_tertinggi = max(stress_percentage, kecemasan_percentage, depresi_percentage)
        
        if persentase_tertinggi == 0:
            hasil_diagnosis = "Normal"
            level_diagnosis = "Normal"
        elif persentase_tertinggi == stress_percentage:
            hasil_diagnosis = "Stres"
            level_diagnosis = "Berat" if stress_percentage >= 70 else ("Sedang" if stress_percentage >= 40 else "Ringan")
        elif persentase_tertinggi == kecemasan_percentage:
            hasil_diagnosis = "Kecemasan"
            level_diagnosis = "Berat" if kecemasan_percentage >= 70 else ("Sedang" if kecemasan_percentage >= 40 else "Ringan")
        else:
            hasil_diagnosis = "Depresi"
            level_diagnosis = "Berat" if depresi_percentage >= 70 else ("Sedang" if depresi_percentage >= 40 else "Ringan")

        # Berikan saran penanganan berdasarkan hasil tertinggi
        saran = "Pertahankan kondisi Anda atau lakukan konsultasi jika dirasa perlu."
        if hasil_diagnosis == "Stres":
            saran = "Cobalah istirahat yang cukup, kelola waktu dengan baik, dan lakukan relaksasi mandiri secara berkala."
        elif hasil_diagnosis == "Kecemasan":
            saran = "Cobalah latihan pernapasan dalam (deep breathing), kurangi overthinking, dan lakukan visualisasi positif."
        elif hasil_diagnosis == "Depresi":
            saran = "Sangat disarankan untuk berbagi cerita dengan orang terdekat yang Anda percayai atau segera hubungi psikolog."

        response_data = {
            "status": "success",
            "hasil": hasil_diagnosis,
            "level": level_diagnosis,
            "stress_percentage": stress_percentage,
            "kecemasan_percentage": kecemasan_percentage,
            "depresi_percentage": depresi_percentage,
            "saran": saran,
            "skor": user_bobot
        }
        
        print("DATA RESPONS YANG DIKIRIM KE FLUTTER:", response_data)
        return jsonify(response_data)

    except Exception as e:
        print("\n===== ERROR SISTEM KONSULTASI =====")
        print(str(e))
        return jsonify({
            "status": "error",
            "message": f"Terjadi kegagalan sistem saat memproses kalkulasi diagnosa: {str(e)}"
        }), 500

    try:
        # ================= 1. AMBIL DATA DARI FLUTTER =================
        data = request.get_json(silent=True)
        if not data:
            return jsonify({"status": "error", "message": "Data kosong"}), 400

        gejala_user = data.get("gejala", [])

        # ================= 2. VALIDASI INPUT MINIM =================
        if not gejala_user or len(gejala_user) <= 2:
            return jsonify(
                {
                    "status": "success",
                    "hasil": "normal",
                    "level": "Normal",
                    "stress_percentage": "0%",
                    "depresi_percentage": "0%",
                    "kecemasan_percentage": "0%",
                    "saran": "Gejala yang Anda rasakan masih tergolong minim dan wajar. Tetap jaga pola hidup sehat, istirahat cukup, dan kelola pikiran positif Anda!",
                    "skor": {"stres": 0, "kecemasan": 0, "depresi": 0},
                }
            )

        # ================= 3. STRUKTUR FITUR BAWAAN ML (27 KOLOM) =================
        fitur_ml = {
            "gangguan_tidur": 0,
            "lelah": 0,
            "sakit_kepala": 0,
            "sakit_perut": 0,
            "nyeri_dada": 0,
            "otot_tegang": 0,
            "penurunan_gairah_seksual": 0,
            "obesitas": 0,
            "hipertensi": 0,
            "diabetes": 0,
            "gangguan_jantung": 0,
            "sulit_tidur": 0,
            "badan_gemetar": 0,
            "keringat_berlebih": 0,
            "jantung_berdebar": 0,
            "sesak_nafas": 0,
            "pusing": 0,
            "mulut_kering": 0,
            "kesemutan": 0,
            "kehilangan_minat": 0,
            "sedih_terus": 0,
            "mudah_menangis": 0,
            "merasa_bersalah": 0,
            "tidak_percaya_diri": 0,
            "mudah_tersinggung": 0,
            "tidak_acuh": 0,
            "bunuh_diri": 0,
        }

        # Batasan pembagi maksimum default untuk data bawaan
        max_bobot_stres = 30
        max_bobot_kecemasan = 25
        max_bobot_depresi = 34

        # Map internal untuk skoring data bawaan (Fallback aman)
        bobot_default = {
            "gangguan_tidur": ("stres", 2),
            "lelah": ("stres", 2),
            "sakit_kepala": ("stres", 2),
            "sakit_perut": ("stres", 2),
            "nyeri_dada": ("stres", 3),
            "otot_tegang": ("stres", 3),
            "hipertensi": ("stres", 4),
            "diabetes": ("stres", 3),
            "gangguan_jantung": ("stres", 4),
            "obesitas": ("stres", 3),
            "sulit_tidur": ("kecemasan", 2),
            "badan_gemetar": ("kecemasan", 3),
            "keringat_berlebih": ("kecemasan", 3),
            "jantung_berdebar": ("kecemasan", 4),
            "sesak_nafas": ("kecemasan", 4),
            "pusing": ("kecemasan", 2),
            "mulut_kering": ("kecemasan", 3),
            "kesemutan": ("kecemasan", 4),
            "kehilangan_minat": ("depresi", 5),
            "sedih_terus": ("depresi", 5),
            "mudah_menangis": ("depresi", 4),
            "merasa_bersalah": ("depresi", 4),
            "tidak_percaya_diri": ("depresi", 4),
            "mudah_tersinggung": ("depresi", 3),
            "tidak_acuh": ("depresi", 4),
            "bunuh_diri": ("depresi", 5),
        }

        # ================= 4. AMBIL BOBOT DAN DATA DINAMIS DARI DATABASE =================
        gejala_db_map = {}
        try:
            # Menggunakan koneksi database Anda (sesuaikan object 'db' jika menggunakan SQLAlchemy/Flask-MySQL)
            with db.engine.connect() as conn:
                result = conn.execute(
                    "SELECT id, nama_gejala, kategori, bobot FROM gejala"
                ).fetchall()
                for row in result:
                    # Normalisasi nama_gejala dari DB ("Gangguan tidur" -> "gangguan_tidur")
                    key_raw = (
                        str(row["nama_gejala"]).strip().lower().replace(" ", "_")
                    )
                    gejala_db_map[key_raw] = {
                        "kategori": str(
                            row["kategori"] if "kategori" in row else "stres"
                        )
                        .lower()
                        .strip(),
                        "bobot": int(row["bobot"] if "bobot" in row else 2),
                    }
        except Exception as db_err:
            print(f"Peringatan Database: Menggunakan skema default ({db_err})")

        # ================= 5. MAPPING PILIHAN USER & SINKRONISASI STRING =================
        skor_stres = 0
        skor_kecemasan = 0
        skor_depresi = 0
        input_terekam = {}

        for g in gejala_user:
            if not g:
                continue
            # Konversi input Flutter ("Gangguan tidur" -> "gangguan_tidur")
            g_clean = str(g).strip().lower().replace(" ", "_")

            # Aturan penyelarasan kalimat panjang database ke Key Model ML Anda
            if (
                "tegang_pada_otot" in g_clean
                or "otot_leher" in g_clean
                or g_clean == "nyeri_atau_tegang_pada_otot"
            ):
                g_clean = "otot_tegang"
            elif "gairah_seksual" in g_clean:
                g_clean = "penurunan_gairah_seksual"
            elif "mulut_terasa_kering" in g_clean or "mulut_kering" in g_clean:
                g_clean = "mulut_kering"
            elif "kehilangan_motivasi" in g_clean:
                g_clean = "kehilangan_minat"
            elif "merasa_sedih_terus" in g_clean or "sedih_menerus" in g_clean:
                g_clean = "sedih_terus"
            elif (
                "bersalah_berlebihan" in g_clean
                or "merasa_bersalah_berlebihan" in g_clean
            ):
                g_clean = "merasa_bersalah"

            # A. Aktifkan fitur ML (1 atau 0) jika masuk dalam 27 fitur latih asli
            if g_clean in fitur_ml:
                fitur_ml[g_clean] = 1

            # B. Hitung Skoring Berdasarkan Map Database / Default
            if g_clean in gejala_db_map:
                kategori = gejala_db_map[g_clean]["kategori"]
                bobot = gejala_db_map[g_clean]["bobot"]
                input_terekam[g_clean] = 1

                if "stres" in kategori or "stress" in kategori:
                    skor_stres += bobot
                elif "cemas" in kategori or "kecemasan" in kategori:
                    skor_kecemasan += bobot
                elif "depresi" in kategori:
                    skor_depresi += bobot

            elif g_clean in bobot_default:
                kategori, bobot = bobot_default[g_clean]
                input_terekam[g_clean] = 1

                if kategori == "stres":
                    skor_stres += bobot
                elif kategori == "kecemasan":
                    skor_kecemasan += bobot
                elif kategori == "depresi":
                    skor_depresi += bobot
            else:
                # Mengakomodasi gejala dinamis baru dari admin yang belum dipetakan kategorinya
                input_terekam[g_clean] = 1
                # Default dimasukkan ke stres jika tidak diketahui kategori datanya
                skor_stres += 2

        if len(input_terekam) == 0:
            return jsonify(
                {
                    "status": "success",
                    "hasil": "normal",
                    "level": "Normal",
                    "stress_percentage": "0%",
                    "depresi_percentage": "0%",
                    "kecemasan_percentage": "0%",
                    "saran": "Nama gejala dari aplikasi tidak cocok dengan sistem pengenalan backend.",
                    "skor": {"stres": 0, "kecemasan": 0, "depresi": 0},
                }
            )

        # Update batas cap pembagi maksimum jika ada gejala baru dari database admin
        for key, info in gejala_db_map.items():
            if key not in bobot_default:
                if "stres" in info["kategori"] or "stress" in info["kategori"]:
                    max_bobot_stres += info["bobot"]
                elif "cemas" in info["kategori"] or "kecemasan" in info["kategori"]:
                    max_bobot_kecemasan += info["bobot"]
                elif "depresi" in info["kategori"]:
                    max_bobot_depresi += info["bobot"]

        # ================= 6. PROSES PREDIKSI MODEL ML (27 FITUR AWAL) =================
        input_dataframe = pd.DataFrame([fitur_ml])
        hasil_dt = model.predict(input_dataframe)[0]

        # ================= 7. PENENTUAN PERSENTASE RIIL =================
        pct_stress = (
            round((skor_stres / max_bobot_stres) * 100) if skor_stres > 0 else 0
        )
        pct_kecemasan = (
            round((skor_kecemasan / max_bobot_kecemasan) * 100)
            if skor_kecemasan > 0
            else 0
        )
        pct_depresi = (
            round((skor_depresi / max_bobot_depresi) * 100)
            if skor_depresi > 0
            else 0
        )

        rasio_skor = {
            "stres": skor_stres / max_bobot_stres if skor_stres > 0 else 0,
            "kecemasan": (
                skor_kecemasan / max_bobot_kecemasan if skor_kecemasan > 0 else 0
            ),
            "depresi": skor_depresi / max_bobot_depresi if skor_depresi > 0 else 0,
        }

        skor_asli = {
            "stres": skor_stres,
            "kecemasan": skor_kecemasan,
            "depresi": skor_depresi,
        }

        hasil_rule = max(rasio_skor, key=rasio_skor.get)

        # Keputusan Hibrida (Prioritaskan rule-based jika admin menambahkan data baru)
        if hasil_dt == hasil_rule:
            hasil_akhir = hasil_dt
        else:
            hasil_akhir = hasil_rule

        # ================= 8. DETERMINASI LEVEL SKOR =================
        skor_terpilih = skor_asli[hasil_akhir]

        if hasil_akhir == "stres":
            level = (
                "Berat"
                if skor_terpilih >= (max_bobot_stres * 0.65)
                else ("Sedang" if skor_terpilih >= (max_bobot_stres * 0.33) else "Ringan")
            )
        elif hasil_akhir == "kecemasan":
            level = (
                "Berat"
                if skor_terpilih >= (max_bobot_kecemasan * 0.68)
                else (
                    "Sedang"
                    if skor_terpilih >= (max_bobot_kecemasan * 0.32)
                    else "Ringan"
                )
            )
        else:
            level = (
                "Berat"
                if skor_terpilih >= (max_bobot_depresi * 0.67)
                else (
                    "Sedang" if skor_terpilih >= (max_bobot_depresi * 0.35) else "Ringan"
                )
            )

        # ================= 9. SARAN DINAMIS =================
        saran = ""
        if hasil_akhir == "stres":
            saran = "Cobalah istirahat yang cukup, kelola waktu dengan baik, dan lakukan relaksasi mandiri secara berkala."
        elif hasil_akhir == "kecemasan":
            saran = "Cobalah latihan pernapasan dalam (deep breathing), kurangi overthinking, dan lakukan visualisasi positif."
        elif hasil_akhir == "depresi":
            saran = "Sangat disarankan untuk berbagi cerita dengan orang terdekat yang Anda percayai atau segera hubungi psikolog/tenaga profesional kesehatan mental."

        # ================= 10. RESPONSE BACK TO FLUTTER =================
        return jsonify(
            {
                "status": "success",
                "hasil": hasil_akhir,
                "level": level,
                "stress_percentage": f"{pct_stress}%",
                "kecemasan_percentage": f"{pct_kecemasan}%",
                "depresi_percentage": f"{pct_depresi}%",
                "skor": skor_asli,
                "saran": saran,
                "input_user": fitur_ml,
            }
        )

    except Exception as e:
        print("\n===== ERROR SISTEM KONSULTASI =====")
        print(str(e))
        return (
            jsonify(
                {
                    "status": "error",
                    "message": "Terjadi kegagalan sistem saat memproses kalkulasi diagnosa.",
                }
            ),
            500,
        )


# ================= EDUKASI =================
@app.route("/api/edukasi", methods=["GET"])
def edukasi():
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute("SELECT * FROM edukasi")
        return jsonify({"status": "success", "data": cur.fetchall()})
    except Exception as e:
        print("EDUKASI ERROR:", e)
        return jsonify({"status": "error", "message": "Gagal mengambil edukasi"}), 500


# ================= BERITA =================
@app.route("/api/berita", methods=["GET"])
def berita():
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute("SELECT * FROM berita")
        return jsonify({"status": "success", "data": cur.fetchall()})
    except Exception as e:
        print("BERITA ERROR:", e)
        return jsonify({"status": "error", "message": "Gagal mengambil berita"}), 500


# ================= DOKTER =================
@app.route("/api/dokter", methods=["GET"])
def dokter():
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute("SELECT * FROM dokter")
        return jsonify({"status": "success", "data": cur.fetchall()})
    except Exception as e:
        print("DOKTER ERROR:", e)
        return jsonify({"status": "error", "message": "Gagal mengambil dokter"}), 500
        
# ================= BOOKING =================
# ================= BOOKING (REVISI DINAMIS HARGA) =================
@app.route("/api/booking", methods=["POST"])
def booking():
    try:
        data = request.get_json(silent=True)
        if not data or not all(k in data for k in ("user_id", "dokter_id", "tanggal", "keluhan")):
            return jsonify({"status": "error", "message": "Data tidak lengkap"}), 400

        user_id = data.get("user_id")
        dokter_id = data.get("dokter_id")
        tanggal = data.get("tanggal")
        keluhan = data.get("keluhan")

        db = get_db()
        cur = db.cursor(dictionary=True)
        
        # 1. Ambil harga dari tabel dokter agar sinkron
        cur.execute("SELECT harga FROM dokter WHERE id = %s", (dokter_id,))
        dokter = cur.fetchone()
        
        if not dokter:
            return jsonify({"status": "error", "message": "Dokter tidak ditemukan"}), 404
            
        total_pembayaran = dokter['harga'] # Menggunakan harga dari DB

        # 2. Simpan ke database
        cur.execute(
            """
            INSERT INTO booking (user_id, dokter_id, tanggal, keluhan, total_price) 
            VALUES (%s, %s, %s, %s, %s)
            """,
            (user_id, dokter_id, tanggal, keluhan, total_pembayaran)
        )
        db.commit()
        booking_id = cur.lastrowid # Ambil ID booking yang baru dibuat
        cur.close()

        return jsonify({
            "status": "success", 
            "message": "Booking berhasil",
            "booking_id": booking_id,
            "total_harga": total_pembayaran
        }), 200
        
    except Exception as e:
        print("BOOKING ERROR:", e)
        return jsonify({"status": "error", "message": "Booking gagal"}), 500
# ================= TAMBAHAN FITUR PEMBAYARAN VA =================

@app.route("/api/get-va-details/<int:booking_id>", methods=["GET"])
def get_va_details(booking_id):
    """
    Mengambil detail VA setelah user berhasil melakukan booking.
    """
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        # Ambil data dari tabel booking
        cur.execute("SELECT id, total_price FROM booking WHERE id = %s", (booking_id,))
        booking = cur.fetchone()
        
        if not booking:
            return jsonify({"status": "error", "message": "Booking tidak ditemukan"}), 404
            
        # Logika VA: Biasanya di sini Anda memanggil API Payment Gateway (Xendit/Midtrans)
        # Untuk simulasi, kita kembalikan data statis sesuai desain Anda
        return jsonify({
            "status": "success",
            "data": {
                "va_number": "7000701501999576408", 
                "bank": "BCA",
                "account_name": "Yomansid",
                "amount": booking['total_price']
            }
        })
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
# ================= ARTIKEL MENTAL =================
@app.route("/api/artikel", methods=["GET"])
def artikel():

    try:

        db = get_db()
        cur = db.cursor(dictionary=True)

        # ================= BERITA =================
        cur.execute("""
            SELECT 
                id,
                judul,
                isi,
                sumber,
                link_sumber,
                'Artikel Mental' AS kategori
            FROM berita
        """)

        berita = cur.fetchall()

        # ================= EDUKASI =================
        cur.execute("""
            SELECT 
                id,
                judul,
                isi,
                sumber,
                link_sumber,
                'Edukasi Mental' AS kategori
            FROM edukasi
        """)

        edukasi = cur.fetchall()

        # ================= GABUNG =================
        semua = berita + edukasi

        return jsonify({
            "status": "success",
            "data": semua
        })

    except Exception as e:

        print("ARTIKEL ERROR:", e)

        return jsonify({
            "status": "error",
            "message": "Gagal mengambil artikel mental"
        }), 500


@app.route("/api/kirim-otp", methods=["POST"])
def kirim_otp():

    try:

        data = request.get_json(silent=True)

        if not data:
            return jsonify({
                "status": "error",
                "message": "Data kosong"
            }), 400

        email = data.get("email")

        if not email:
            return jsonify({
                "status": "error",
                "message": "Email wajib diisi"
            }), 400

        db = get_db()
        cur = db.cursor(dictionary=True)

        # ================= CEK USER =================
        cur.execute(
            "SELECT * FROM user WHERE email=%s",
            (email,)
        )

        user = cur.fetchone()

        if not user:
            return jsonify({
                "status": "error",
                "message": "Email tidak ditemukan"
            }), 404

        # ================= GENERATE OTP =================
        otp = str(random.randint(100000, 999999))

        print(f"OTP UNTUK {email}: {otp}")

        # ================= HAPUS OTP LAMA =================
        cur.execute(
            "DELETE FROM otp_reset WHERE email=%s",
            (email,)
        )

        # ================= SIMPAN OTP =================
        cur.execute(
            """
            INSERT INTO otp_reset (email, kode_otp)
            VALUES (%s,%s)
            """,
            (email, otp)
        )

        db.commit()

        # ================= EMAIL =================
        msg = Message(
            subject="Kode OTP Reset Password",
            sender=("Yomans Konseling", app.config['MAIL_USERNAME']),
            recipients=[email]
        )

        # ================= TEXT VERSION =================
        msg.body = f"""
Halo {user['username']},

Kode OTP reset password Anda adalah:

{otp}

Jangan berikan kode ini kepada siapa pun.

Yomans Konseling
"""

        # ================= HTML VERSION =================
        msg.html = f"""
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
        }}

        .container {{
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            max-width: 500px;
            margin: auto;
        }}

        .otp {{
            font-size: 36px;
            font-weight: bold;
            color: #2E86DE;
            text-align: center;
            margin: 20px 0;
        }}

        .footer {{
            margin-top: 30px;
            font-size: 12px;
            color: gray;
            text-align: center;
        }}
    </style>
</head>

<body>

<div class="container">

<h2>Kode OTP Reset Password</h2>

<p>Halo <b>{user['username']}</b>,</p>

<p>Kode OTP reset password Anda adalah:</p>

<div class="otp">
    {otp}
</div>

<p>
Jangan berikan kode ini kepada siapa pun demi keamanan akun Anda.
</p>

<div class="footer">
Yomans Konseling App
</div>

</div>

</body>
</html>
"""

        print("MULAI KIRIM EMAIL")

        mail.send(msg)

        print("EMAIL BERHASIL DIKIRIM")

        return jsonify({
            "status": "success",
            "message": "OTP berhasil dikirim"
        })

    except Exception as e:

        print("OTP ERROR:", str(e))

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500


# ================= RESET PASSWORD =================
@app.route("/api/reset-password", methods=["POST"])
def reset_password():

    try:

        # ================= AMBIL DATA =================
        data = request.get_json(
            silent=True
        )

        if not data:

            return jsonify({

                "status": "error",

                "message": "Data kosong"
            }), 400

        email = data.get("email")

        otp = data.get("otp")

        password_baru = data.get(
            "password"
        )

        # ================= VALIDASI =================
        if (
            not email or
            not otp or
            not password_baru
        ):

            return jsonify({

                "status": "error",

                "message": "Data tidak lengkap"
            }), 400

        # ================= DB =================
        db = get_db()

        cur = db.cursor(
            dictionary=True
        )

        # ================= CEK OTP =================
        cur.execute(
            """
            SELECT *
            FROM otp_reset
            WHERE email=%s
            AND kode_otp=%s
            """,
            (
                email,
                otp
            )
        )

        cek = cur.fetchone()

        if not cek:

            return jsonify({

                "status": "error",

                "message": "OTP salah"
            }), 400

        # ================= HASH PASSWORD =================
        hashed_password = (
            generate_password_hash(
                password_baru
            )
        )

        # ================= UPDATE PASSWORD =================
        cur.execute(
            """
            UPDATE user
            SET password=%s
            WHERE email=%s
            """,
            (
                hashed_password,
                email
            )
        )

        # ================= HAPUS OTP =================
        cur.execute(
            """
            DELETE FROM otp_reset
            WHERE email=%s
            """,
            (email,)
        )

        db.commit()

        return jsonify({

            "status": "success",

            "message":
                "Password berhasil direset"
        })

    except Exception as e:

        print(
            "RESET PASSWORD ERROR:",
            str(e)
        )

        return jsonify({

            "status": "error",

            "message":
                "Reset password gagal"
        }), 500
    
    # ================= RIWAYAT BOOKING (SINKRON KE FLUTTER) =================

@app.route("/api/history", methods=["GET"])
def get_history():
    client_name = request.args.get('client_name')
    if not client_name:
        return jsonify({"status": "error", "message": "client_name wajib diisi"}), 400

    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        # Mengambil riwayat booking user berdasarkan nama
        cur.execute("SELECT * FROM booking_history WHERE client_name = %s", (client_name,))
        data = cur.fetchall()
        cur.close()
        return jsonify(data), 200
    except Exception as e:
        print("GET HISTORY ERROR:", e)
        return jsonify({"status": "error", "message": str(e)}), 500

 
# ================= SUBMIT REVIEW (LENGKAPI YANG TERPOTONG) =================
@app.route("/api/submit-review", methods=["POST"])
def submit_review():
    try:
        data = request.get_json(silent=True)
        booking_id = data.get("booking_id")
        rating = data.get("rating")
        comment = data.get("comment")

        if not booking_id or not rating:
            return jsonify({"status": "error", "message": "Booking ID dan Rating wajib diisi"}), 400

        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute(
            "INSERT INTO review (booking_id, rating, comment) VALUES (%s, %s, %s)",
            (booking_id, rating, comment)
        )
        db.commit()
        cur.close()
        return jsonify({"status": "success", "message": "Review berhasil dikirim"}), 200
    except Exception as e:
        print("SUBMIT REVIEW ERROR:", e)
        return jsonify({"status": "error", "message": str(e)}), 500


# ================= TAMBAHKAN KODE INI DI PALING BAWAH FILE APP.PY =================
# ================= MASTER DATA GEJALA (SINKRONISASI FLUTTER) =================

@app.route("/api/gejala", methods=["GET"])
def get_all_gejala():
    """Mengambil semua data gejala untuk ditampilkan di list Admin Flutter"""
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        
        # Mengambil id, nama_gejala, kategori, dan bobot dari database
        cur.execute("SELECT id, nama_gejala, kategori, bobot FROM gejala ORDER BY id DESC")
        data_gejala = cur.fetchall()
        cur.close()
        
        return jsonify({
            "status": "success",
            "data": data_gejala
        }), 200
    except Exception as e:
        print("GET GEJALA ERROR:", e)
        return jsonify({"status": "error", "message": "Gagal mengambil data gejala"}), 500


@app.route("/api/gejala", methods=["POST"])
def tambah_gejala_baru():
    """Menambahkan data gejala baru dari form dialog Flutter"""
    try:
        data = request.get_json(silent=True)
        if not data:
            return jsonify({"status": "error", "message": "Data kosong"}), 400
            
        nama = data.get("nama_gejala")
        kategori = data.get("kategori", "stres")
        bobot = data.get("bobot", 2)
        
        if not nama:
            return jsonify({"status": "error", "message": "Nama gejala wajib diisi"}), 400
            
        db = get_db()
        cur = db.cursor(dictionary=True)
        
        cur.execute(
            "INSERT INTO gejala (nama_gejala, kategori, bobot) VALUES (%s, %s, %s)",
            (nama, kategori, int(bobot))
        )
        db.commit()
        cur.close()
        
        return jsonify({
            "status": "success",
            "message": "Gejala baru berhasil ditambahkan"
        }), 201
    except Exception as e:
        print("POST GEJALA ERROR:", e)
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/api/gejala/<int:gejala_id>", methods=["PUT"])
def update_gejala_existing(gejala_id):
    """Memperbarui nama, kategori, dan bobot gejala berdasarkan ID saat tombol Update ditekan"""
    try:
        data = request.get_json(silent=True)
        if not data:
            return jsonify({"status": "error", "message": "Data perubahan kosong"}), 400
            
        nama = data.get("nama_gejala")
        kategori = data.get("kategori")
        bobot = data.get("bobot")
        
        db = get_db()
        cur = db.cursor(dictionary=True)
        
        cur.execute(
            "UPDATE gejala SET nama_gejala=%s, kategori=%s, bobot=%s WHERE id=%s",
            (nama, kategori, int(bobot), gejala_id)
        )
        db.commit()
        cur.close()
        
        return jsonify({
            "status": "success",
            "message": "Data gejala berhasil diperbarui"
        }), 200
    except Exception as e:
        print("PUT GEJALA ERROR:", e)
        return jsonify({"status": "error", "message": str(e)}), 500


# Pastikan baris ini tetap berada di paling bawah file app.py Anda
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)


@app.route("/api/cancel-booking", methods=["POST"])
def cancel_booking():
    try:
        data = request.get_json(silent=True)
        booking_id = data.get("booking_id")

        if not booking_id:
            return jsonify({"status": "error", "message": "booking_id wajib diisi"}), 400

        db = get_db()
        cur = db.cursor()
        cur.execute(
            "UPDATE booking_history SET status = 'Dibatalkan' WHERE id = %s",
            (booking_id,)
        )
        db.commit()
        cur.close()
        return jsonify({"status": "success", "message": "Booking berhasil dibatalkan"}), 200
    except Exception as e:
        print("CANCEL BOOKING ERROR:", e)
        return jsonify({"status": "error", "message": str(e)}), 500
    
# ============================================================
# ================= FITUR CRUD DASHBOARD ADMIN ================
# ============================================================

import json # Pastikan ini sudah di-import di bagian paling atas file app.py Anda

@app.route("/api/admin/dokter", methods=["POST"])

def admin_tambah_dokter():

    try:

        # ===============================

        # AMBIL DATA DARI FLUTTER

        # ===============================

        nama = request.form.get("nama", "").strip()

        tags_raw = request.form.get("tags", "").strip()

        jadwal = request.form.get("jadwal", "").strip()

        harga_awal = request.form.get("harga_awal", "0").strip()

        harga_diskon = request.form.get("harga_diskon", "0").strip()

        durasi = request.form.get("durasi", "1 jam").strip()



        # 2. LOGIKA RAPIKAN FORMAT TAGS (Dibuat lebih robust)

        tags = ""

        if tags_raw:

            clean_tags = tags_raw.strip()

            # Coba parse jika formatnya JSON array, jika gagal anggap string biasa

            try:

                if clean_tags.startswith('['):

                    tags_list = json.loads(clean_tags)

                    if isinstance(tags_list, list):

                        tags = ", ".join([str(t) for t in tags_list])

                    else:

                        tags = clean_tags

                else:

                    tags = clean_tags

            except:

                # Jika JSON error, bersihkan karakter pemisah manual

                tags = clean_tags.replace('[', '').replace(']', '').replace('"', '').replace("'", "")

        

        # Bersihkan tags dari karakter sisa yang tidak diinginkan

        tags = tags.strip(", ")



        # 3. VALIDASI

        if not nama or not tags or not harga_diskon:

            return jsonify({

                "status": "error",

                "message": "Data Nama, Tags, atau Harga Diskon wajib diisi"

            }), 400



        # 4. FOTO (LOGIKA UPLOAD)

        foto = ""

        if 'foto' in request.files:

            file = request.files['foto']

            if file and file.filename != '':

                filename = secure_filename(file.filename)

                # Pastikan direktori ada

                os.makedirs(app.config.get('UPLOAD_FOLDER', 'uploads'), exist_ok=True) 

                filepath = os.path.join(app.config.get('UPLOAD_FOLDER', 'uploads'), filename)

                file.save(filepath)

                foto = f"http://127.0.0.1:5000/uploads/{filename}"



        # 5. DATABASE INSERT

        db = get_db()

        cur = db.cursor()



        query = """

            INSERT INTO dokter 

            (nama, tags, jadwal, image_url, harga_awal, harga_diskon, durasi) 

            VALUES (%s, %s, %s, %s, %s, %s, %s)

        """

        values = (nama, tags, jadwal, foto, harga_awal, harga_diskon, durasi)

        

        cur.execute(query, values)

        db.commit()

        cur.close()



        return jsonify({

            "status": "success",

            "message": "Dokter berhasil ditambahkan"

        }), 201



    except Exception as e:

        print("EROR SERVER:", str(e))

        return jsonify({

            "status": "error",

            "message": "Gagal menyimpan ke database: " + str(e)

        }), 500

    

@app.route("/api/dokter", methods=["GET"])

def get_dokter():

    try:

        db = get_db()

        cur = db.cursor(dictionary=True)



        cur.execute("""

            SELECT *

            FROM dokter

            ORDER BY id ASC

        """)



        rows = cur.fetchall()



        data = []



        for row in rows:

            harga_awal = float(row["harga_awal"] or 0)

            harga_diskon = float(row["harga_diskon"] or 0)



            # Hitung diskon otomatis

            if harga_awal > 0:

                diskon = round(

                    ((harga_awal - harga_diskon) / harga_awal) * 100

                )

            else:

                diskon = 0



            data.append({

                "id": row["id"],

                "nama": row["nama"],

                "tags": row["tags"],

                "jadwal": row["jadwal"],

                "durasi": row["durasi"],

                "image_url": row["image_url"],



                # harga

                "harga_awal": harga_awal,

                "harga_diskon": harga_diskon,

                "diskon": diskon,

            })



        cur.close()

        db.close()



        return jsonify({

            "status": "success",

            "data": data

        }), 200



    except Exception as e:

        return jsonify({

            "status": "error",

            "message": str(e)

        }), 500


# ----------------- 2. CRUD BERITA -----------------

@app.route("/api/admin/berita", methods=["POST"])
def admin_tambah_berita():
    try:
        data = request.get_json(silent=True)
        judul = data.get("judul")
        isi = data.get("isi")
        sumber = data.get("sumber")
        link_sumber = data.get("link_sumber")

        if not judul or not isi:
            return jsonify({"status": "error", "message": "Judul dan isi berita wajib diisi"}), 400

        db = get_db()
        cur = db.cursor()
        cur.execute(
            "INSERT INTO berita (judul, isi, sumber, link_sumber) VALUES (%s, %s, %s, %s)",
            (judul, isi, sumber, link_sumber)
        )
        db.commit()
        cur.close()
        return jsonify({"status": "success", "message": "Berita berhasil ditambahkan"}), 201
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/api/admin/berita/<int:id>", methods=["PUT"])
def admin_edit_berita(id):
    try:
        data = request.get_json(silent=True)
        judul = data.get("judul")
        isi = data.get("isi")
        sumber = data.get("sumber")
        link_sumber = data.get("link_sumber")

        db = get_db()
        cur = db.cursor()
        cur.execute(
            "UPDATE berita SET judul=%s, isi=%s, sumber=%s, link_sumber=%s WHERE id=%s",
            (judul, isi, sumber, link_sumber, id)
        )
        db.commit()
        cur.close()
        return jsonify({"status": "success", "message": "Berita berhasil diperbarui"}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/api/admin/berita/<int:id>", methods=["DELETE"])
def admin_hapus_berita(id):
    try:
        db = get_db()
        cur = db.cursor()
        cur.execute("DELETE FROM berita WHERE id=%s", (id,))
        db.commit()
        cur.close()
        return jsonify({"status": "success", "message": "Berita berhasil dihapus"}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ----------------- 3. CRUD EDUKASI -----------------

@app.route("/api/admin/edukasi", methods=["POST"])
def admin_tambah_edukasi():
    try:
        data = request.get_json(silent=True)
        judul = data.get("judul")
        isi = data.get("isi")
        sumber = data.get("sumber")
        link_sumber = data.get("link_sumber")

        if not judul or not isi:
            return jsonify({"status": "error", "message": "Judul dan isi edukasi wajib diisi"}), 400

        db = get_db()
        cur = db.cursor()
        cur.execute(
            "INSERT INTO edukasi (judul, isi, sumber, link_sumber) VALUES (%s, %s, %s, %s)",
            (judul, isi, sumber, link_sumber)
        )
        db.commit()
        cur.close()
        return jsonify({"status": "success", "message": "Edukasi berhasil ditambahkan"}), 201
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/api/admin/edukasi/<int:id>", methods=["PUT"])
def admin_edit_edukasi(id):
    try:
        data = request.get_json(silent=True)
        judul = data.get("judul")
        isi = data.get("isi")
        sumber = data.get("sumber")
        link_sumber = data.get("link_sumber")

        db = get_db()
        cur = db.cursor()
        cur.execute(
            "UPDATE edukasi SET judul=%s, isi=%s, sumber=%s, link_sumber=%s WHERE id=%s",
            (judul, isi, sumber, link_sumber, id)
        )
        db.commit()
        cur.close()
        return jsonify({"status": "success", "message": "Edukasi berhasil diperbarui"}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/api/admin/edukasi/<int:id>", methods=["DELETE"])
def admin_hapus_edukasi(id):
    try:
        db = get_db()
        cur = db.cursor()
        cur.execute("DELETE FROM edukasi WHERE id=%s", (id,))
        db.commit()
        cur.close()
        return jsonify({"status": "success", "message": "Edukasi berhasil dihapus"}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/uploads/<filename>')
def tampilkan_foto_dari_folder(filename):
    from flask import send_from_directory
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)


# ==================== ROUTE HAPUS DOKTER ====================
@app.route('/api/admin/dokter/<int:id>', methods=['DELETE'])
def delete_dokter(id):
    try:
        db = get_db()
        cursor = db.cursor()

        # Ambil foto terlebih dahulu
        cursor.execute(
            "SELECT image_url FROM dokter WHERE id = %s",
            (id,)
        )

        result = cursor.fetchone()

        # Hapus data dokter
        cursor.execute(
            "DELETE FROM dokter WHERE id = %s",
            (id,)
        )

        db.commit()

        cursor.close()

        return jsonify({
            "status": "success",
            "message": "Dokter berhasil dihapus"
        }), 200

    except Exception as e:
        print("ERROR HAPUS DOKTER:", str(e))

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500
    
 # ==================== KELOLA GEJALA (SESUAI DATABASE ASLI) ====================

# 1. AMBIL DATA GEJALA (GET)
@app.route('/api/gejala', methods=['GET'])
def get_all_gejala():
    db = None
    cur = None
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        # Hanya mengambil id dan nama_gejala sesuai database Anda
        cur.execute("SELECT id, nama_gejala FROM gejala ORDER BY id DESC")
        daftar_gejala = cur.fetchall()
        
        return jsonify({
            "status": "success",
            "data": daftar_gejala
        }), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        if cur: cur.close()
        if db: db.close()

# 2. TAMBAH DATA GEJALA (POST)
@app.route('/api/gejala', methods=['POST'])
def tambah_gejala_baru():
    db = None
    cur = None
    try:
        data = request.get_json()
        if not data:
            return jsonify({"status": "error", "message": "Format data tidak valid!"}), 400
        
        nama_gejala = data.get('nama_gejala')

        if not nama_gejala:
            return jsonify({"status": "error", "message": "Nama gejala wajib diisi!"}), 400

        db = get_db()
        cur = db.cursor()
        
        # Hanya insert ke kolom nama_gejala
        cur.execute("INSERT INTO gejala (nama_gejala) VALUES (%s)", (nama_gejala,))
        db.commit()
        
        return jsonify({"status": "success", "message": "Gejala baru berhasil ditambahkan!"}), 201
    except Exception as e:
        if db: db.rollback()
        return jsonify({"status": "error", "message": f"Kendala Database: {str(e)}"}), 500
    finally:
        if cur: cur.close()
        if db: db.close()

# 3. UBAH DATA GEJALA (PUT)
@app.route('/api/gejala/<int:id>', methods=['PUT'])
def edit_gejala_by_id(id):
    db = None
    cur = None
    try:
        data = request.get_json()
        if not data:
            return jsonify({"status": "error", "message": "Format data tidak valid!"}), 400
        
        nama_gejala = data.get('nama_gejala')

        if not nama_gejala:
            return jsonify({"status": "error", "message": "Nama gejala tidak boleh kosong!"}), 400

        db = get_db()
        cur = db.cursor()
        
        cur.execute("SELECT id FROM gejala WHERE id = %s", (id,))
        if not cur.fetchone():
            return jsonify({"status": "error", "message": "Data tidak ditemukan!"}), 404

        # Update data berdasarkan id
        cur.execute("UPDATE gejala SET nama_gejala = %s WHERE id = %s", (nama_gejala, id))
        db.commit()
        
        return jsonify({"status": "success", "message": "Gejala berhasil diperbarui!"}), 200
    except Exception as e:
        if db: db.rollback()
        return jsonify({"status": "error", "message": f"Kendala Database: {str(e)}"}), 500
    finally:
        if cur: cur.close()
        if db: db.close()
# ================= RUN SERVER =================
if __name__ == "__main__":
    app.run(
        debug=True,
        host="0.0.0.0",
        port=5000
    )