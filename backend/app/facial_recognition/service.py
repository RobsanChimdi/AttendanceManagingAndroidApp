import os
import logging
import requests
import numpy as np
from app.config import settings

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("facial_recognition")

# We defer cv2 import inside methods or handle it safely so the app can start even if cv2 fails to load initially.
cv2 = None
try:
    import cv2 as _cv2
    cv2 = _cv2
except ImportError:
    logger.warning("OpenCV (cv2) is not installed. Facial recognition features will be disabled.")

class FaceRecognitionService:
    def __init__(self):
        self.detector = None
        self.recognizer = None
        self.models_loaded = False
        
        # Model file names
        self.yunet_filename = "face_detection_yunet_2023mar.onnx"
        self.sface_filename = "face_recognition_sface_2021dec.onnx"
        
        # Absolute paths
        self.yunet_path = os.path.join(settings.MODELS_DIR, self.yunet_filename)
        self.sface_path = os.path.join(settings.MODELS_DIR, self.sface_filename)

    def download_models_if_missing(self):
        """
        Downloads YuNet and SFace model files from OpenCV Zoo if they do not exist.
        Creates models directory if necessary.
        """
        os.makedirs(settings.MODELS_DIR, exist_ok=True)

        # Download YuNet (detector)
        if not os.path.exists(self.yunet_path):
            logger.info(f"Downloading YuNet face detector from {settings.YUNET_MODEL_URL}...")
            try:
                self._download_file(settings.YUNET_MODEL_URL, self.yunet_path)
                logger.info("YuNet downloaded successfully.")
            except Exception as e:
                logger.error(f"Failed to download YuNet model: {e}")

        # Download SFace (recognizer)
        if not os.path.exists(self.sface_path):
            logger.info(f"Downloading SFace face recognizer from {settings.SFACE_MODEL_URL}...")
            try:
                self._download_file(settings.SFACE_MODEL_URL, self.sface_path)
                logger.info("SFace downloaded successfully.")
            except Exception as e:
                logger.error(f"Failed to download SFace model: {e}")

        # Try to load models after downloading
        self.load_models()

    def _download_file(self, url: str, dest_path: str):
        response = requests.get(url, stream=True, timeout=30)
        response.raise_for_status()
        with open(dest_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

    def load_models(self) -> bool:
        """
        Loads ONNX models into OpenCV's DNN FaceDetectorYN and FaceRecognizerSF.
        """
        if cv2 is None:
            logger.warning("Cannot load models because cv2 is not available.")
            return False

        if not os.path.exists(self.yunet_path) or not os.path.exists(self.sface_path):
            logger.warning("Model files are missing. Run download_models_if_missing() first.")
            return False

        try:
            # We initialize YuNet detector with a default size of 320x320
            # (must be updated dynamically based on actual input images)
            self.detector = cv2.FaceDetectorYN.create(
                model=self.yunet_path,
                config="",
                input_size=(320, 320),
                score_threshold=0.9,
                nms_threshold=0.3,
                top_k=5000
            )
            
            self.recognizer = cv2.FaceRecognizerSF.create(
                model=self.sface_path,
                config=""
            )
            
            self.models_loaded = True
            logger.info("Facial recognition models loaded successfully.")
            return True
        except Exception as e:
            logger.error(f"Failed to load OpenCV face recognition models: {e}")
            self.models_loaded = False
            return False

    def verify_models_loaded(self) -> bool:
        """
        Check if models are loaded. Attempts loading if not already loaded.
        """
        if self.models_loaded:
            return True
        return self.load_models()

    def detect_face(self, image_bytes: bytes) -> tuple:
        """
        Detects a face in the image.
        Returns:
            - bool: True if face is detected, False otherwise
            - face_coords: the raw face coordinates or bounding box from YuNet
        """
        if not self.verify_models_loaded() or cv2 is None:
            raise RuntimeError("Facial recognition models are not loaded or cv2 is missing.")

        try:
            # Decode image from bytes
            nparr = np.frombuffer(image_bytes, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if img is None:
                return False, None

            h, w, _ = img.shape
            self.detector.setInputSize((w, h))
            
            _, faces = self.detector.detect(img)
            
            if faces is not None and len(faces) > 0:
                # Return True and the first detected face coordinates
                return True, faces[0]
            
            return False, None
        except Exception as e:
            logger.error(f"Error in face detection: {e}")
            return False, None

    def extract_embedding(self, image_bytes: bytes, face_coords) -> np.ndarray:
        """
        Extracts facial embedding vector (128 floats) from the detected face.
        """
        if not self.verify_models_loaded() or cv2 is None:
            raise RuntimeError("Facial recognition models are not loaded or cv2 is missing.")

        try:
            # Decode image
            nparr = np.frombuffer(image_bytes, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if img is None:
                raise ValueError("Failed to decode image.")

            # Align and crop face
            aligned_face = self.recognizer.alignCrop(img, face_coords)
            
            # Extract features (128-dimensional vector)
            embedding = self.recognizer.feature(aligned_face)
            return embedding[0]  # First feature row
        except Exception as e:
            logger.error(f"Error extracting embedding: {e}")
            raise

    def compare_embeddings(self, embedding1: np.ndarray, embedding2: np.ndarray) -> tuple:
        """
        Compares two embeddings.
        Returns:
            - bool: True if match, False otherwise
            - float: similarity score
        """
        if not self.verify_models_loaded() or cv2 is None:
            raise RuntimeError("Facial recognition models are not loaded or cv2 is missing.")

        try:
            # Reshape inputs to 2D arrays as expected by match
            emb1 = np.atleast_2d(embedding1)
            emb2 = np.atleast_2d(embedding2)
            
            # Cosine similarity
            score = self.recognizer.match(emb1, emb2, cv2.FaceRecognizerSF_FR_COSINE)
            
            # Match is true if score exceeds the threshold
            is_match = bool(score >= settings.FACE_MATCH_THRESHOLD)
            return is_match, float(score)
        except Exception as e:
            logger.error(f"Error comparing embeddings: {e}")
            return False, 0.0

# Singleton instance
face_recognition_service = FaceRecognitionService()
