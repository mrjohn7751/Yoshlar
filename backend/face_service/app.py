import os
import hmac
import io

import cv2
import numpy as np
from flask import Flask, request, jsonify
from deepface import DeepFace
from PIL import Image

app = Flask(__name__)

# Konfiguratsiya
STORAGE_PATH = os.path.join(os.path.dirname(__file__), '..', 'storage', 'app', 'public')
API_KEY = os.environ.get('FACE_SERVICE_KEY', 'yoshlar-face-secret-2024')
MIN_IMAGE_SIZE = 100
BLUR_THRESHOLD = 50.0
MODEL_NAME = 'ArcFace'
DETECTOR_BACKEND = 'opencv'

# Anti-spoofing mavjudligini tekshirish (torch kerak)
ANTI_SPOOFING_AVAILABLE = False
try:
    import torch
    ANTI_SPOOFING_AVAILABLE = True
    print("Anti-spoofing moduli mavjud (torch o'rnatilgan)")
except ImportError:
    print("OGOHLANTIRISH: torch o'rnatilmagan - anti-spoofing ishlamaydi. 'pip install torch' bilan o'rnating.")


def verify_api_key():
    """Laravel dan kelgan API key ni tekshirish"""
    key = request.headers.get('X-API-Key', '')
    return hmac.compare_digest(key, API_KEY)


def check_image_quality(image_np):
    """Rasm sifatini tekshirish: o'lcham va xiralashganlik"""
    h, w = image_np.shape[:2]
    if h < MIN_IMAGE_SIZE or w < MIN_IMAGE_SIZE:
        return f"Rasm juda kichik ({w}x{h}). Kamida {MIN_IMAGE_SIZE}x{MIN_IMAGE_SIZE} piksel bo'lishi kerak."

    gray = cv2.cvtColor(image_np, cv2.COLOR_RGB2GRAY)
    laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
    if laplacian_var < BLUR_THRESHOLD:
        return "Rasm xiralashgan. Aniqroq rasm yuboring."

    return None


@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'})


@app.route('/compare', methods=['POST'])
def compare_faces():
    # API key tekshirish
    if not verify_api_key():
        return jsonify({
            'match': False,
            'message': "Autentifikatsiya xatosi"
        }), 401

    officer_photo_path = request.form.get('officer_photo_path')
    selfie_file = request.files.get('selfie')

    if not officer_photo_path or not selfie_file:
        return jsonify({
            'match': False,
            'message': "officer_photo_path va selfie talab qilinadi"
        }), 400

    # Path traversal himoyasi
    full_path = os.path.realpath(os.path.join(STORAGE_PATH, officer_photo_path))
    if not full_path.startswith(os.path.realpath(STORAGE_PATH)):
        return jsonify({
            'match': False,
            'message': "Noto'g'ri fayl yo'li"
        }), 400

    if not os.path.exists(full_path):
        return jsonify({
            'match': False,
            'message': "Mas'ul rasmi topilmadi"
        }), 404

    try:
        # Selfie ni yuklash
        selfie_bytes = selfie_file.read()
        selfie_pil = Image.open(io.BytesIO(selfie_bytes)).convert('RGB')
        selfie_np = np.array(selfie_pil)

        # 1. Rasm sifatini tekshirish
        quality_error = check_image_quality(selfie_np)
        if quality_error:
            return jsonify({
                'match': False,
                'message': quality_error
            }), 400

        # 2. Selfie da yuz borligini va anti-spoofing tekshirish
        try:
            selfie_faces = DeepFace.extract_faces(
                img_path=selfie_np,
                detector_backend=DETECTOR_BACKEND,
                anti_spoofing=ANTI_SPOOFING_AVAILABLE,
                enforce_detection=True
            )
        except ValueError as ve:
            err_msg = str(ve).lower()
            if 'torch' in err_msg or 'anti spoofing' in err_msg:
                # torch yo'q - anti-spoofing'siz qayta urinish
                selfie_faces = DeepFace.extract_faces(
                    img_path=selfie_np,
                    detector_backend=DETECTOR_BACKEND,
                    anti_spoofing=False,
                    enforce_detection=True
                )
            else:
                return jsonify({
                    'match': False,
                    'message': "Selfiedan yuz aniqlanmadi. Yuzingiz aniq ko'rinishini ta'minlang."
                }), 400
        except Exception:
            return jsonify({
                'match': False,
                'message': "Selfiedan yuz aniqlanmadi. Yuzingiz aniq ko'rinishini ta'minlang."
            }), 400

        if not selfie_faces:
            return jsonify({
                'match': False,
                'message': "Selfiedan yuz aniqlanmadi."
            }), 400

        # Bir nechta yuz tekshiruvi
        real_faces = [f for f in selfie_faces if f.get('confidence', 0) > 0.5]
        if len(real_faces) > 1:
            return jsonify({
                'match': False,
                'message': "Rasmda bir nechta yuz aniqlandi. Faqat bitta yuz bo'lishi kerak."
            }), 400

        # Anti-spoofing: soxta rasm tekshiruvi (tiriklik aniqlash)
        face_data = real_faces[0] if real_faces else selfie_faces[0]
        is_real = face_data.get('is_real', None)
        antispoof_score = face_data.get('antispoof_score', None)

        if is_real is False:
            return jsonify({
                'match': False,
                'is_real': False,
                'antispoof_score': antispoof_score,
                'message': "Soxta rasm aniqlandi! Iltimos, haqiqiy yuzingizni kameraga ko'rsating. "
                           "Telefon ekranidagi yoki qog'ozdagi rasm qabul qilinmaydi."
            }), 403

        # 3. Officer rasmida yuz borligini tekshirish
        try:
            officer_faces = DeepFace.extract_faces(
                img_path=full_path,
                detector_backend=DETECTOR_BACKEND,
                enforce_detection=True
            )
            if not officer_faces:
                return jsonify({
                    'match': False,
                    'message': "Mas'ul rasmidan yuz aniqlanmadi."
                }), 400
        except ValueError:
            return jsonify({
                'match': False,
                'message': "Mas'ul rasmidan yuz aniqlanmadi."
            }), 400

        # 4. Yuzlarni solishtirish (ArcFace modeli bilan)
        result = DeepFace.verify(
            img1_path=full_path,
            img2_path=selfie_np,
            model_name=MODEL_NAME,
            detector_backend=DETECTOR_BACKEND,
            anti_spoofing=False  # Yuqorida alohida tekshirdik
        )

        distance = result.get('distance', 1.0)
        threshold = result.get('threshold', 0.68)
        verified = result.get('verified', False)

        # Similarity foizini hisoblash
        # ArcFace cosine distance: 0 = bir xil, 1 = butunlay boshqa
        similarity = round(max(0, (1 - distance)) * 100, 1)

        if verified:
            msg = f"Yuz tasdiqlandi ({similarity}% o'xshashlik)"
        else:
            msg = f"Yuz mos kelmadi ({similarity}% o'xshashlik). Yetarli darajada o'xshash emas."

        return jsonify({
            'match': verified,
            'distance': round(distance, 4),
            'threshold': round(threshold, 4),
            'similarity': similarity,
            'is_real': True,
            'message': msg
        })

    except Exception as e:
        error_msg = str(e).lower()
        if 'spoof' in error_msg or 'fake' in error_msg:
            return jsonify({
                'match': False,
                'is_real': False,
                'message': "Soxta rasm aniqlandi! Haqiqiy yuzingizni ko'rsating."
            }), 403

        return jsonify({
            'match': False,
            'message': "Yuz solishtirish xatosi yuz berdi. Qaytadan urinib ko'ring."
        }), 500


if __name__ == '__main__':
    # Modellarni oldindan yuklash (birinchi so'rov sekin bo'lmasligi uchun)
    print("Modellar yuklanmoqda...")
    try:
        DeepFace.build_model(MODEL_NAME)
        print(f"{MODEL_NAME} modeli tayyor.")
    except Exception as e:
        print(f"Model yuklashda xato: {e}")

    app.run(host='127.0.0.1', port=5001, debug=False)
