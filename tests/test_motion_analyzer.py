import pytest

np = pytest.importorskip("numpy")
cv2 = pytest.importorskip("cv2")

from mobile_video_analysis import MotionAnalyzer


def create_frame():
    return np.zeros((120, 160, 3), dtype=np.uint8)


def test_motion_detection_identifies_simple_object():
    analyzer = MotionAnalyzer(alpha=0.4, threshold=10, min_area=50, blur_kernel=5, dilate_iterations=1)

    background = create_frame()
    analyzer.process(background)

    moving = background.copy()
    cv2.rectangle(moving, (50, 40), (80, 70), (255, 255, 255), -1)

    result = analyzer.process(moving)
    assert result.has_motion()
    assert len(result.detections) == 1

    detection = result.detections[0]
    x, y, w, h = detection.bbox
    assert w * h >= 900
    assert detection.area >= 800
    assert 60 <= detection.centroid[0] <= 70
    assert 50 <= detection.centroid[1] <= 60


def test_overlay_mask_preserves_shape():
    analyzer = MotionAnalyzer(alpha=0.3, threshold=5, min_area=20, blur_kernel=5, dilate_iterations=1)

    frame = create_frame()
    mask = np.zeros(frame.shape[:2], dtype=np.uint8)
    mask[10:20, 10:20] = 255

    overlaid = analyzer.overlay_mask(frame, mask)
    assert overlaid.shape == frame.shape
    assert overlaid.dtype == frame.dtype


def test_detections_serialisation():
    analyzer = MotionAnalyzer(alpha=0.3, threshold=5, min_area=20, blur_kernel=5, dilate_iterations=1)

    base = create_frame()
    analyzer.process(base)

    frame = base.copy()
    cv2.circle(frame, (30, 30), 10, (255, 255, 255), -1)
    result = analyzer.process(frame)
    serialised = analyzer.detections_to_dict(result.detections)

    assert isinstance(serialised, list)
    assert serialised and "bbox" in serialised[0]
