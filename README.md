# Signature-Verification-and-Face-Verification-using-Matlab
Double Verification System using MATLAB .First level verification using Signature and second level using customer face image 
# Signature & Face Verification App

A MATLAB-based desktop application for verifying a user's identity using both **signature verification** and **face recognition** techniques. The application provides a graphical user interface (GUI) where users can load stored and input images for comparison and perform dual biometric authentication.

---

## Features

- Signature verification using HOG (Histogram of Oriented Gradients) features
- Face verification using Haar Cascade face detection
- Dual authentication system for improved accuracy
- Simple and interactive MATLAB App Designer GUI
- Real-time verification results with similarity scores
- Automatic image preprocessing and resizing

---

## Technologies Used

- MATLAB
- MATLAB App Designer
- Image Processing Toolbox
- Computer Vision Toolbox

---

## Project Workflow

1. Load stored signature image
2. Load input signature image
3. Load stored face image
4. Load input face image
5. Extract HOG features from signatures and faces
6. Compare feature vectors using Euclidean distance
7. Display verification result based on similarity scores

---

## Verification Method

### Signature Verification
- Images are converted to grayscale
- Resized to a fixed dimension
- HOG features are extracted
- Euclidean distance is calculated between feature vectors

### Face Verification
- Face detection using `vision.CascadeObjectDetector`
- Detected faces are cropped and resized
- HOG features are extracted
- Similarity score is calculated for authentication

---

## File Structure

```text
SignatureFaceVerificationAppw.m   % Main MATLAB App file
README.md                         % Project documentation
```

---

## Requirements

- MATLAB R2021a or later
- Image Processing Toolbox
- Computer Vision Toolbox

---

## How to Run

1. Open MATLAB
2. Navigate to the project folder
3. Open the file:

```matlab
SignatureFaceVerificationAppw.m
```

4. Run the application:

```matlab
app = SignatureFaceVerificationApp;
```

---

## Output

- Displays loaded signature and face images
- Shows verification status:
  - ✅ Verified
  - ❌ Verification Failed
- Displays similarity scores for both signature and face matching

---

## Future Improvements

- Deep learning-based face recognition
- Signature dataset training
- Database integration for user management
- Real-time webcam authentication
- Improved accuracy using CNN models

---

## Author

Developed as an image processing and biometric verification project using MATLAB.
