import os
import hmac
import io

import cv2
import numpy as np
import face_recognition
from flask import Flask, request, jsonify
from PIL import Image

app = Flask(__name__)

# Konfiguratsiya
STORAGE_PATH = os.path.join(os.path.dirname(__file__), '..', 'storage', 'app', 'public')
API_KEY = os.environ.get('FACE_SERVICE_KEY', 'yoshlar-face-secret-2024')
MIN_IMAGE_SIZE = 100
BLUR_THRESHOLD = 50.0
MATCH_TOLERANCE = 0.5  # Past = qattiqroq (0.4-0.6 oralig'i yaxshi)


def verify_api_key():
    """Laravel dan kelgan API key ni tekshirish"""
    key = request.headers.get('X-API-Key', '')
    return hmac.compare_digest(key, API_KEY)


def load_image(source):
    """Fayldan yoki bytesdan rasmni yuklash (RGB formatda)"""
    if isinstance(source, str):
        img = Image.open(source).convert('RGB')
    else:
        img = Image.open(io.BytesIO(source)).convert('RGB')
    return np.array(img)


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


def get_face_encoding(image_np, label="Rasm"):
    """Rasmdan yuz encoding olish. Yuz topilmasa None qaytaradi."""
    # face_recognition kutubxonasi yuz joylashuvini topadi
    face_locations = face_recognition.face_locations(image_np, model='hog')

    if len(face_locations) == 0:
        return None, f"{label}dan yuz aniqlanmadi. Yuzingiz aniq ko'rinishini ta'minlang."

    if len(face_locations) > 1:
        return None, f"{label}da bir nechta yuz aniqlandi. Faqat bitta yuz bo'lishi kerak."

    # Birinchi (yagona) yuzning encodingini olish - 128 o'lchamli vektor
    encodings = face_recognition.face_encodings(image_np, face_locations)
    if len(encodings) == 0:
        return None, f"{label}dan yuz xususiyatlari olinmadi."

    return encodings[0], None


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
        # 1. Selfie ni yuklash va sifatini tekshirish
        selfie_bytes = selfie_file.read()
        selfie_np = load_image(selfie_bytes)

        quality_error = check_image_quality(selfie_np)
        if quality_error:
            return jsonify({
                'match': False,
                'message': quality_error
            }), 400

        # 2. Selfiedan yuz encoding olish
        selfie_encoding, selfie_error = get_face_encoding(selfie_np, "Selfie")
        if selfie_error:
            return jsonify({
                'match': False,
                'message': selfie_error
            }), 400

        # 3. Mas'ul rasmidan yuz encoding olish
        officer_np = load_image(full_path)
        officer_encoding, officer_error = get_face_encoding(officer_np, "Mas'ul rasmi")
        if officer_error:
            return jsonify({
                'match': False,
                'message': officer_error
            }), 400

        # 4. Yuzlarni solishtirish
        # face_distance: 0 = bir xil odam, 1 = butunlay boshqa
        face_distance = face_recognition.face_distance(
            [officer_encoding], selfie_encoding
        )[0]

        matched = face_distance <= MATCH_TOLERANCE
        similarity = round(max(0, (1 - face_distance)) * 100, 1)

        if matched:
            msg = f"Yuz tasdiqlandi ({similarity}% o'xshashlik)"
        else:
            msg = f"Yuz mos kelmadi ({similarity}% o'xshashlik). Yetarli darajada o'xshash emas."

        return jsonify({
            'match': matched,
            'distance': round(float(face_distance), 4),
            'threshold': MATCH_TOLERANCE,
            'similarity': similarity,
            'is_real': True,
            'message': msg
        })

    except Exception as e:
        return jsonify({
            'match': False,
            'message': f"Yuz solishtirish xatosi: {str(e)}"
        }), 500


if __name__ == '__main__':
    print("Face service ishga tushmoqda...")
    print(f"Tolerance: {MATCH_TOLERANCE}")
    app.run(host='127.0.0.1', port=5000, debug=False)
