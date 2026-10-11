# Facial Recognition Documentation

## Model Information

### Face Detection Model
- **Model**: YuNet (face_detection_yunet_2023mar.onnx)
- **Source**: OpenCV Zoo
- **Purpose**: Detect faces in images and provide bounding box coordinates

### Face Recognition Model
- **Model**: SFace (face_recognition_sface_2021dec.onnx)
- **Source**: OpenCV Zoo
- **Embedding Dimension**: 128 floats
- **Purpose**: Generate facial embeddings for recognition

## Embedding Details

### Embedding Vector
- **Dimension**: 128-dimensional float vector
- **Representation**: Normalized feature vector extracted from aligned face
- **Storage**: Binary (pickle) in PostgreSQL database
- **Security**: Embeddings are not exposed via API endpoints

## Comparison Method

### Similarity Metric
- **Method**: Cosine Similarity
- **Implementation**: OpenCV FaceRecognizerSF with `cv2.FaceRecognizerSF_FR_COSINE`
- **Range**: 0.0 to 1.0 (higher values indicate better match)

### Threshold Selection
- **Threshold**: 0.363
- **Selection**: Based on SFace model recommendations and empirical testing
- **Rationale**: 
  - Cosine similarity threshold optimized for SFace model
  - Balances false positive rate vs. false negative rate
  - Configurable via `FACE_RECOGNITION_THRESHOLD` environment variable

## Recognition Flow

### Face Enrollment
1. Receive 3-10 face samples from different angles
2. Detect face in each sample
3. Validate face quality (size, position, centering)
4. Extract embedding from each valid sample
5. Average embeddings to create representative vector
6. Store with student ID, model name, and version

### Attendance Recognition
1. Receive single frame/image
2. Detect exactly one face
3. Validate face quality
4. Extract embedding
5. Compare against all enrolled embeddings
6. Find best match (highest cosine similarity)
7. Apply threshold (0.363)
8. Return result:
   - **MATCH**: Similarity >= threshold
   - **LOW_CONFIDENCE**: Similarity > 0 but < threshold
   - **UNKNOWN**: No face detected, multiple faces, or similarity = 0

## Quality Validation

### Face Size Requirements
- Minimum: 100x100 pixels
- Relative to image: At least 20% of total image area

### Face Position Requirements
- Face must be within 25% of image center
- Ensures consistent alignment for recognition

## Security Considerations

- Embeddings stored as binary (not exposed via API)
- No automatic enrollment during attendance
- Recognition only against pre-enrolled students
- Session validation (must be OPEN for recognition)
- Duplicate attendance prevention per session

## Configuration

### Environment Variables
```bash
FACE_RECOGNITION_THRESHOLD=0.363  # Cosine similarity threshold
```

### Model Configuration
```python
YUNET_MODEL_URL: URL for YuNet model download
SFACE_MODEL_URL: URL for SFace model download
MODELS_DIR: Directory for model storage
```
