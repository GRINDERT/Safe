import cv2
import numpy as np
from mtcnn.mtcnn import MTCNN
from skimage.metrics import structural_similarity as compare_ssim

def analyze_video_for_deepfake(video_path, mse_threshold=2000, ssim_threshold=0.8, win_size=3):
    
    detector = MTCNN()  # MTCNN detector for faces
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        raise IOError(f"Cannot open video file: {video_path}")

    previous_frame = None
    frame_id = 0
    potential_deepfake = False

    print(f"Analyzing video: {video_path}")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame_id += 1

        # Convert frame to RGB for processing
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # Skip frames that are too small for SSIM calculation
        if frame_rgb.shape[0] < win_size or frame_rgb.shape[1] < win_size:
            print(f"Frame {frame_id} is too small for SSIM calculation. Skipping.")
            continue

        # Detect faces in the frame
        faces = detector.detect_faces(frame_rgb)

        # If no face is detected, skip this frame
        if len(faces) == 0:
            continue

        if previous_frame is not None:
            # Calculate MSE and SSIM between the current and previous frames
            m = np.sum((frame_rgb.astype("float") - previous_frame.astype("float")) ** 2)
            m /= float(frame_rgb.shape[0] * frame_rgb.shape[1])

            s = compare_ssim(frame_rgb, previous_frame, multichannel=True, win_size=win_size)

            # Check thresholds
            if m > mse_threshold or s < ssim_threshold:
                potential_deepfake = True

        # Update the previous frame
        previous_frame = frame_rgb

    cap.release()

    if potential_deepfake:
        return "Oh oh!! Cette vidéo n'est pas authentique"
    else:
        return "Cette vidéo est authentique"

# Example usage:
if __name__ == "__main__":
    video_path = "/home/mmeganndo/videos/vid1.mp4"
    result = analyze_video_for_deepfake(video_path)
    print(f"Result: {result}")
