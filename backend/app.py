# ================= IMPORT =================
from flask import Flask, request, jsonify
from flask_cors import CORS
from database.db import get_db
import pandas as pd
import numpy as np
import joblib
from werkzeug.security import generate_password_hash, check_password_hash
from flask_mail import Mail, Message
import random
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# ================= EMAIL CONFIG =================
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.getenv("MAIL_USERNAME")
app.config['MAIL_PASSWORD'] = os.getenv("MAIL_PASSWORD")
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


# ================= LOGIN (SOLUSI A) =================
@app.route("/api/login", methods=["POST"])
def login():
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)

        data = request.get_json(silent=True)
        if not data:
            return jsonify({"status": "error", "message": "Data tidak dikirim"}), 400

        username = data.get("username")
        password = data.get("password")

        if not username or not password:
            return jsonify({"status": "error", "message": "Username & password wajib diisi"}), 400

        # Kita ambil username AS nama agar dibaca aman oleh getter Flutter
        cur.execute(
            """
            SELECT id, email, username, password, username AS nama, role 
            FROM user 
            WHERE username=%s
            """,
            (username,)
        )

        user = cur.fetchone()

        # ================= CEK HASH PASSWORD =================
        if user and check_password_hash(user["password"], password):

            # Hapus password sebelum dikirim ke Flutter
            user.pop("password", None)

            # Kunci sukses: Kita kembalikan key-nya menjadi "data" lagi 
            # agar dicerna dengan bahagia oleh file login.dart milikmu
            return jsonify({
                "status": "success",
                "message": "Login berhasil",
                "data": user  
            })

        return jsonify({"status": "error", "message": "Username atau password salah"}), 401

    except Exception as e:
        print("LOGIN ERROR:", e)
        return jsonify({"status": "error", "message": "Terjadi kesalahan server"}), 500
    
# ================= REGISTER =================
@app.route("/api/register", methods=["POST"])
def register():
    try:
        db = get_db()
        cur = db.cursor()

        data = request.get_json(silent=True)
        if not data:
            return jsonify({"status": "error", "message": "Data kosong"}), 400

        email = data.get("email")
        username = data.get("username")
        password = data.get("password")

        if not email or not username or not password:
            return jsonify({"status": "error", "message": "Semua field wajib diisi"}), 400

        # Cek username
        cur.execute("SELECT id FROM user WHERE username=%s", (username,))
        if cur.fetchone():
            return jsonify({"status": "error", "message": "Username sudah digunakan"}), 400

        # Cek email
        cur.execute("SELECT id FROM user WHERE email=%s", (email,))
        if cur.fetchone():
            return jsonify({"status": "error", "message": "Email sudah digunakan"}), 400

        # Insert user
        hashed_password = generate_password_hash(password)
        cur.execute(
            """
            INSERT INTO user (email, username, password, role) 
            VALUES (%s, %s, %s, 'user')
            """,
            (email, username, hashed_password)
        )
        db.commit()

        return jsonify({"status": "success", "message": "Registrasi berhasil"})

    except Exception as e:
        print("REGISTER ERROR:", e)
        return jsonify({"status": "error", "message": "Terjadi kesalahan server"}), 500


# ================= GEJALA (FROM DATABASE) =================
@app.route("/api/gejala", methods=["GET"])
def gejala():
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute("SELECT * FROM gejala")
        data = cur.fetchall()

        return jsonify({"status": "success", "data": data})
    except Exception as e:
        print("GEJALA ERROR:", e)
        return jsonify({"status": "error", "message": "Gagal mengambil data gejala"}), 500


# ================= KONSULTASI HYBRID =================
@app.route("/api/konsultasi", methods=["POST"])
def konsultasi():
    if model is None:
        return jsonify({
            "status": "error",
            "message": "Model Machine Learning gagal dimuat di server"
        }), 500

    try:
        # ================= AMBIL DATA =================
        data = request.get_json(silent=True)
        if not data:
            return jsonify({"status": "error", "message": "Data kosong"}), 400

        gejala_user = data.get("gejala", [])

        # ================= VALIDASI JIKA INPUT KOSONG / GEJALA MINIM =================
        if not gejala_user or len(gejala_user) <= 2:
            return jsonify({
                "status": "success",
                "hasil": "normal",
                "level": "Normal",
                "stress_percentage": "0%",
                "depresi_percentage": "0%",
                "kecemasan_percentage": "0%",
                "saran": "Gejala yang Anda rasakan masih tergolong minim dan wajar. Tetap jaga pola hidup sehat, istirahat cukup, dan kelola pikiran positif Anda!",
                "skor": {"stres": 0, "kecemasan": 0, "depresi": 0}
            })

        # ================= SEMUA FITUR INDEKS =================
        fitur = {
            "gangguan_tidur": 0, "lelah": 0, "sakit_kepala": 0, "sakit_perut": 0, "nyeri_dada": 0,
            "otot_tegang": 0, "penurunan_gairah_seksual": 0, "obesitas": 0, "hipertensi": 0,
            "diabetes": 0, "gangguan_jantung": 0,

            "sulit_tidur": 0, "badan_gemetar": 0, "keringat_berlebih": 0, "jantung_berdebar": 0,
            "sesak_nafas": 0, "pusing": 0, "mulut_kering": 0, "kesemutan": 0,

            "kehilangan_minat": 0, "sedih_terus": 0, "mudah_menangis": 0, "merasa_bersalah": 0,
            "tidak_percaya_diri": 0, "mudah_tersinggung": 0, "tidak_acuh": 0, "bunuh_diri": 0,
        }

        jumlah_terisi = 0
        for g in gejala_user:
            if g in fitur:
                fitur[g] = 1
                jumlah_terisi += 1

        if jumlah_terisi == 0:
            return jsonify({
                "status": "success",
                "hasil": "normal",
                "level": "Normal",
                "stress_percentage": "0%",
                "depresi_percentage": "0%",
                "kecemasan_percentage": "0%",
                "saran": "Nama gejala yang dikirim dari Flutter tidak cocok dengan sistem backend.",
                "skor": {"stres": 0, "kecemasan": 0, "depresi": 0}
            })

        # ================= DATAFRAME UNTUK MODEL =================
        input_data = pd.DataFrame([{k: v for k, v in fitur.items()}])

        # ================= ML DECISION TREE =================
        hasil_dt = model.predict(input_data)[0]
        probabilitas = model.predict_proba(input_data)[0]
        confidence = round(np.max(probabilitas) * 100, 2)

        # ================= RULE BASED SCORING =================
        skor_stres = (
            fitur["gangguan_tidur"] * 2 + fitur["lelah"] * 2 + fitur["sakit_kepala"] * 2 +
            fitur["sakit_perut"] * 2 + fitur["nyeri_dada"] * 3 + fitur["otot_tegang"] * 3 +
            fitur["hipertensi"] * 4 + fitur["diabetes"] * 3 + fitur["gangguan_jantung"] * 4 +
            fitur["obesitas"] * 3
        )

        skor_kecemasan = (
            fitur["sulit_tidur"] * 2 + fitur["badan_gemetar"] * 3 + fitur["keringat_berlebih"] * 3 +
            fitur["jantung_berdebar"] * 4 + fitur["sesak_nafas"] * 4 + fitur["pusing"] * 2 +
            fitur["mulut_kering"] * 3 + fitur["kesemutan"] * 4
        )

        skor_depresi = (
            fitur["kehilangan_minat"] * 5 + fitur["sedih_terus"] * 5 + fitur["mudah_menangis"] * 4 +
            fitur["merasa_bersalah"] * 4 + fitur["tidak_percaya_diri"] * 4 + fitur["mudah_tersinggung"] * 3 +
            fitur["tidak_acuh"] * 4 + fitur["bunuh_diri"] * 5
        )

        # Perhitungan Persentase Riil Berdasarkan Bobot Gejala Terpilih
        pct_stress = round((skor_stres / 30) * 100) if skor_stres > 0 else 0
        pct_kecemasan = round((skor_kecemasan / 25) * 100) if skor_kecemasan > 0 else 0
        pct_depresi = round((skor_depresi / 34) * 100) if skor_depresi > 0 else 0

        rasio_skor = {
            "stres": skor_stres / 30 if skor_stres > 0 else 0,
            "kecemasan": skor_kecemasan / 25 if skor_kecemasan > 0 else 0,
            "depresi": skor_depresi / 34 if skor_depresi > 0 else 0
        }

        skor_asli = {
            "stres": skor_stres,
            "kecemasan": skor_kecemasan,
            "depresi": skor_depresi
        }

        hasil_rule = max(rasio_skor, key=rasio_skor.get)

        # ================= HYBRID DECISION =================
        if hasil_dt == hasil_rule:
            hasil_akhir = hasil_dt
        else:
            hasil_akhir = hasil_rule  # Prioritas rule based

        # ================= DETERMINASI LEVEL SKOR =================
        skor_terpilih = skor_asli[hasil_akhir]
        
        if hasil_akhir == "stres":
            level = "Berat" if skor_terpilih >= 20 else ("Sedang" if skor_terpilih >= 10 else "Ringan")
        elif hasil_akhir == "kecemasan":
            level = "Berat" if skor_terpilih >= 17 else ("Sedang" if skor_terpilih >= 8 else "Ringan")
        else:
            level = "Berat" if skor_terpilih >= 23 else ("Sedang" if skor_terpilih >= 12 else "Ringan")

        # ================= SARAN =================
        saran = ""
        if hasil_akhir == "stres":
            saran = "Cobalah istirahat yang cukup, kelola waktu dengan baik, dan lakukan relaksasi."
        elif hasil_akhir == "kecemasan":
            saran = "Cobalah latihan pernapasan, kurangi overthinking, dan konsultasi jika berlanjut."
        elif hasil_akhir == "depresi":
            saran = "Segera berbicara dengan orang terpercaya atau tenaga profesional kesehatan mental."

        # ================= RESPONSE WITH PERCENTAGE MAP =================
        return jsonify({
            "status": "success",
            "decision_tree": str(hasil_dt),
            "rule_based": hasil_rule,
            "hasil": hasil_akhir,
            "level": level,
            "stress_percentage": f"{pct_stress}%",
            "kecemasan_percentage": f"{pct_kecemasan}%",
            "depresi_percentage": f"{pct_depresi}%",
            "skor": skor_asli,
            "saran": saran,
            "input_user": fitur
        })

    except Exception as e:
        print("\n===== ERROR KONSULTASI =====")
        print(str(e))
        return jsonify({"status": "error", "message": "Terjadi kesalahan memproses data"}), 500


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
@app.route("/api/booking", methods=["POST"])
def booking():
    try:
        data = request.get_json(silent=True)
        if not data or not all(k in data for k in ("user_id", "dokter_id", "tanggal", "keluhan")):
            return jsonify({"status": "error", "message": "Data booking tidak lengkap"}), 400

        db = get_db()
        cur = db.cursor()
        cur.execute(
            """
            INSERT INTO booking (user_id, dokter_id, tanggal, keluhan) 
            VALUES (%s, %s, %s, %s)
            """,
            (data.get("user_id"), data.get("dokter_id"), data.get("tanggal"), data.get("keluhan"))
        )
        db.commit()

        return jsonify({"status": "success", "message": "Booking berhasil"})
    except Exception as e:
        print("BOOKING ERROR:", e)
        return jsonify({"status": "error", "message": "Booking gagal"}), 500
    

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

# ================= RUN SERVER =================
if __name__ == "__main__":
    app.run(
        debug=True,
        host="0.0.0.0",
        port=5000
    )

    # ================= KIRIM OTP =================
@app.route("/api/kirim-otp", methods=["POST"])
def kirim_otp():

    try:

        data = request.get_json()

        email = data.get("email")

        db = get_db()
        cur = db.cursor(dictionary=True)

        # cek email user
        cur.execute(
            "SELECT * FROM user WHERE email=%s",
            (email,)
        )

        user = cur.fetchone()

        if not user:
            return jsonify({
                "status": "error",
                "message": "Email tidak ditemukan"
            })

        # generate otp
        otp = str(random.randint(100000, 999999))

        # hapus otp lama
        cur.execute(
            "DELETE FROM otp_reset WHERE email=%s",
            (email,)
        )

        # simpan otp baru
        cur.execute(
            "INSERT INTO otp_reset (email, kode_otp) VALUES (%s,%s)",
            (email, otp)
        )

        db.commit()

        # kirim email
        msg = Message(
            "Kode OTP Reset Password",
            recipients=[email]
        )

        msg.body = f"""
Kode OTP reset password Anda:

{otp}

Jangan berikan kode ini kepada siapa pun.
"""

        mail.send(msg)

        return jsonify({
            "status": "success",
            "message": "OTP berhasil dikirim"
        })

    except Exception as e:

        print(e)

        return jsonify({
            "status": "error",
            "message": "Gagal mengirim OTP"
        })
    
    # ================= RESET PASSWORD =================
@app.route("/api/reset-password", methods=["POST"])
def reset_password():

    try:

        data = request.get_json()

        email = data.get("email")
        otp = data.get("otp")
        password_baru = data.get("password")

        db = get_db()
        cur = db.cursor(dictionary=True)

        # cek otp
        cur.execute(
            """
            SELECT * FROM otp_reset
            WHERE email=%s AND kode_otp=%s
            """,
            (email, otp)
        )

        cek = cur.fetchone()

        if not cek:

            return jsonify({
                "status": "error",
                "message": "OTP salah"
            })

        # update password
        cur.execute(
            """
            UPDATE user
            SET password=%s
            WHERE email=%s
            """,
            (password_baru, email)
        )

        # hapus otp
        cur.execute(
            "DELETE FROM otp_reset WHERE email=%s",
            (email,)
        )

        db.commit()

        return jsonify({
            "status": "success",
            "message": "Password berhasil direset"
        })

    except Exception as e:

        print(e)

        return jsonify({
            "status": "error",
            "message": "Reset password gagal"
        })