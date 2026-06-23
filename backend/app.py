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
            SELECT 
                id,
                email,
                username,
                password,
                username AS nama,
                role
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

 
@app.route("/api/submit-review", methods=["POST"])
def submit_review():
    try:
        data = request.get_json(silent=True)
        booking_id = data.get("booking_id")
        rating = data.get("rating")
        comment = data.get("comment")

        if not booking_id or rating is None:
            return jsonify({"status": "error", "message": "Data tidak lengkap"}), 400

        db = get_db()
        cur = db.cursor()
        cur.execute(
            """
            UPDATE booking_history 
            SET reviewed = TRUE, rating = %s, comment = %s 
            WHERE id = %s
            """,
            (rating, comment, booking_id)
        )
        db.commit()
        cur.close()
        return jsonify({"status": "success", "message": "Ulasan berhasil disimpan"}), 200
    except Exception as e:
        print("SUBMIT REVIEW ERROR:", e)
        return jsonify({"status": "error", "message": str(e)}), 500


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
# ================= TAMBAH JADWAL =================
@app.route("/api/admin/jadwal", methods=["POST"])
def tambah_jadwal():

    try:

        data = request.get_json()

        dokter_id = data.get("dokter_id")
        tanggal = data.get("tanggal")
        jam = data.get("jam")
        sesi = data.get("sesi")

        if not dokter_id or not tanggal or not jam or not sesi:

            return jsonify({
                "status": "error",
                "message": "Data tidak lengkap"
            }), 400

        db = get_db()

        cur = db.cursor()

        cur.execute("""
            INSERT INTO jadwal_dokter
            (
                dokter_id,
                tanggal,
                jam,
                sesi,
                status
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                'tersedia'
            )
        """, (
            dokter_id,
            tanggal,
            jam,
            sesi
        ))

        db.commit()

        return jsonify({
            "status": "success",
            "message": "Jadwal berhasil ditambahkan"
        })

    except Exception as e:

        print("TAMBAH JADWAL ERROR:", e)

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500
    
    # ================= GET ALL JADWAL =================
@app.route("/api/admin/jadwal", methods=["GET"])
def get_all_jadwal():

    try:

        db = get_db()

        cur = db.cursor(
            dictionary=True
        )

        cur.execute("""
            SELECT
                j.*,
                d.nama
            FROM jadwal_dokter j
            JOIN dokter d
            ON j.dokter_id = d.id
            ORDER BY j.tanggal ASC,
                     j.jam ASC
        """)

        data = cur.fetchall()

        for item in data:

            item["tanggal"] = str(
                item["tanggal"]
            )

            item["jam"] = str(
                item["jam"]
            )

        return jsonify({
            "status": "success",
            "data": data
        })

    except Exception as e:

        print(e)

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500
    
    # ================= EDIT JADWAL =================
@app.route(
    "/api/admin/jadwal/<int:id>",
    methods=["PUT"]
)
def edit_jadwal(id):

    try:

        data = request.get_json()

        tanggal = data.get("tanggal")
        jam = data.get("jam")
        sesi = data.get("sesi")

        db = get_db()

        cur = db.cursor()

        cur.execute("""
            UPDATE jadwal_dokter
            SET
                tanggal=%s,
                jam=%s,
                sesi=%s
            WHERE id=%s
        """, (
            tanggal,
            jam,
            sesi,
            id
        ))

        db.commit()

        return jsonify({
            "status": "success",
            "message": "Jadwal berhasil diubah"
        })

    except Exception as e:

        print(e)

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500
    
    # ================= HAPUS JADWAL =================
@app.route(
    "/api/admin/jadwal/<int:id>",
    methods=["DELETE"]
)
def hapus_jadwal(id):

    try:

        db = get_db()

        cur = db.cursor()

        cur.execute("""
            DELETE FROM jadwal_dokter
            WHERE id=%s
        """, (id,))

        db.commit()

        return jsonify({
            "status": "success",
            "message": "Jadwal berhasil dihapus"
        })

    except Exception as e:

        print(e)

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500
    
    # ================= ADD THIS NEW ENDPOINT =================
@app.route("/api/dokter/<int:dokter_id>/jadwal", methods=["GET"])
def get_jadwal_by_dokter(dokter_id):
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        
        # Mengambil jadwal spesifik milik 1 dokter saja
        cur.execute("""
            SELECT id, dokter_id, tanggal, jam, sesi, status 
            FROM jadwal_dokter 
            WHERE dokter_id = %s
            ORDER BY tanggal ASC, jam ASC
        """, (dokter_id,))
        
        data = cur.fetchall()
        
        # Konversi tipe data Date dan Time agar bisa dikirim sebagai JSON string
        for item in data:
            item["tanggal"] = str(item["tanggal"])
            item["jam"] = str(item["jam"])
            if "id_jadwal" in item and "id" not in item:
                item["id"] = item["id_jadwal"]
                
        return jsonify({
            "status": "success",
            "data": data
        }), 200

    except Exception as e:
        print("GET JADWAL PER DOKTER ERROR:", e)
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
  # ================= GET JADWAL DOKTER =================
@app.route(
    "/api/dokter/<int:dokter_id>/jadwal",
    methods=["GET"]
)
def get_jadwal_dokter(dokter_id):

    try:

        db = get_db()

        cur = db.cursor(
            dictionary=True
        )

        cur.execute("""
            SELECT
                id,
                dokter_id,
                tanggal,
                jam,
                sesi,
                status
            FROM jadwal_dokter
            WHERE dokter_id = %s
            AND status = 'tersedia'
            ORDER BY tanggal ASC,
                     jam ASC
        """, (dokter_id,))

        data = cur.fetchall()

        # ================= FIX FORMAT JSON =================
        for item in data:

            if item.get("tanggal"):
                item["tanggal"] = str(
                    item["tanggal"]
                )

            if item.get("jam"):
                item["jam"] = str(
                    item["jam"]
                )

            if item.get("sesi"):
                item["sesi"] = str(
                    item["sesi"]
                )

        return jsonify({
            "status": "success",
            "data": data
        })

    except Exception as e:

        print(
            "GET JADWAL ERROR:",
            e
        )

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

        # ================= FIX DATE & TIME =================
        for item in data:

            if item.get("tanggal"):
                item["tanggal"] = str(
                    item["tanggal"]
                )

            if item.get("jam"):
                item["jam"] = str(
                    item["jam"]
                )

        print("JADWAL DOKTER:")
        print(data)

        return jsonify({
            "status": "success",
            "data": data
        })

    except Exception as e:

        print(
            "GET JADWAL ERROR:",
            e
        )

        return jsonify({
            "status": "error",
            "message":
                str(e)
        }), 500
# ================= RUN SERVER =================
if __name__ == "__main__":
    app.run(
        debug=True,
        host="0.0.0.0",
        port=5000
    )