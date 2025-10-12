"""Utilities for real-time motion analysis using OpenCV."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, List, Sequence, Tuple

try:  # pragma: no cover - import guard
    import numpy as np  # type: ignore
except ImportError as exc:  # pragma: no cover - handled by raising later
    np = None  # type: ignore
    _numpy_import_error = exc
else:
    _numpy_import_error = None

try:  # pragma: no cover - import guard
    import cv2  # type: ignore
except ImportError as exc:  # pragma: no cover - handled by raising later
    cv2 = None  # type: ignore
    _cv2_import_error = exc
else:
    _cv2_import_error = None


@dataclass(frozen=True)
class MotionDetection:
    """Represents a single motion detection bounding box."""

    bbox: Tuple[int, int, int, int]
    area: int
    centroid: Tuple[float, float]


@dataclass
class MotionDetectionResult:
    """Container for the binary mask and detections from a frame."""

    detections: List[MotionDetection]
    mask: "np.ndarray"

    def has_motion(self) -> bool:
        """Return ``True`` when at least one detection is present."""

        return bool(self.detections)


class MotionAnalyzer:
    """Detect motion in frames using a running background model."""

    def __init__(
        self,
        *,
        alpha: float = 0.05,
        threshold: int = 25,
        min_area: int = 500,
        dilate_iterations: int = 2,
        blur_kernel: int = 21,
    ) -> None:
        if np is None:  # pragma: no cover - triggered when NumPy is missing
            raise ImportError(
                "MotionAnalyzer requires the numpy package."
            ) from _numpy_import_error
        if cv2 is None:  # pragma: no cover - triggered when OpenCV is missing
            raise ImportError(
                "MotionAnalyzer requires the opencv-python package."
            ) from _cv2_import_error

        if not 0 < alpha <= 1:
            raise ValueError("alpha must be within (0, 1]")
        if threshold <= 0:
            raise ValueError("threshold must be positive")
        if min_area <= 0:
            raise ValueError("min_area must be positive")
        if dilate_iterations < 0:
            raise ValueError("dilate_iterations cannot be negative")
        if blur_kernel % 2 == 0:
            raise ValueError("blur_kernel must be an odd number to satisfy OpenCV requirements")

        self.alpha = alpha
        self.threshold = threshold
        self.min_area = min_area
        self.dilate_iterations = dilate_iterations
        self.blur_kernel = blur_kernel

        self._avg_frame: "np.ndarray | None" = None

    def reset(self) -> None:
        """Reset the running background model."""

        self._avg_frame = None

    def process(self, frame: "np.ndarray") -> MotionDetectionResult:
        """Analyse a frame and return detected motion bounding boxes."""

        if frame.size == 0:
            raise ValueError("frame must contain data")

        if frame.dtype != np.uint8:
            frame = frame.astype(np.uint8)

        frame_float = frame.astype(np.float32)
        if self._avg_frame is None:
            self._avg_frame = frame_float
            mask = np.zeros(frame.shape[:2], dtype=np.uint8)
            return MotionDetectionResult([], mask)

        cv2.accumulateWeighted(frame_float, self._avg_frame, self.alpha)
        avg_frame_uint8 = cv2.convertScaleAbs(self._avg_frame)
        delta = cv2.absdiff(frame, avg_frame_uint8)

        if frame.ndim == 3 and frame.shape[2] == 3:
            gray = cv2.cvtColor(delta, cv2.COLOR_BGR2GRAY)
        else:
            gray = delta if delta.ndim == 2 else delta.squeeze()

        if self.blur_kernel > 0:
            gray = cv2.GaussianBlur(gray, (self.blur_kernel, self.blur_kernel), 0)

        _, thresh = cv2.threshold(gray, self.threshold, 255, cv2.THRESH_BINARY)
        if self.dilate_iterations:
            thresh = cv2.dilate(thresh, None, iterations=self.dilate_iterations)

        contours, _ = cv2.findContours(
            thresh.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )

        detections: List[MotionDetection] = []
        for contour in contours:
            area = int(cv2.contourArea(contour))
            if area < self.min_area:
                continue

            x, y, w, h = cv2.boundingRect(contour)
            moments = cv2.moments(contour)
            if moments["m00"]:
                cx = float(moments["m10"] / moments["m00"])
                cy = float(moments["m01"] / moments["m00"])
            else:
                cx = float(x + w / 2)
                cy = float(y + h / 2)

            detections.append(MotionDetection((x, y, w, h), area, (cx, cy)))

        return MotionDetectionResult(detections, thresh)

    def annotate_frame(
        self, frame: "np.ndarray", detections: Sequence[MotionDetection]
    ) -> "np.ndarray":
        """Return a copy of ``frame`` with bounding boxes drawn."""

        if frame.dtype != np.uint8:
            frame = frame.astype(np.uint8)

        annotated = frame.copy()
        for detection in detections:
            x, y, w, h = detection.bbox
            cv2.rectangle(annotated, (x, y), (x + w, y + h), (0, 255, 0), 2)
            label = f"area={detection.area}"
            cv2.putText(
                annotated,
                label,
                (x, max(y - 5, 0)),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                (0, 255, 0),
                1,
                cv2.LINE_AA,
            )
        return annotated

    @staticmethod
    def overlay_mask(frame: "np.ndarray", mask: "np.ndarray", *, alpha: float = 0.35) -> "np.ndarray":
        """Overlay the binary mask on top of the frame for visualisation."""

        if frame.ndim != 3:
            raise ValueError("frame must be a colour image for mask overlay")
        if mask.ndim != 2:
            raise ValueError("mask must be a single channel image")

        mask_coloured = np.zeros_like(frame)
        mask_coloured[:, :, 2] = mask  # red channel
        blended = cv2.addWeighted(frame, 1 - alpha, mask_coloured, alpha, 0)
        return blended

    @staticmethod
    def detections_to_dict(detections: Iterable[MotionDetection]) -> List[dict]:
        """Serialise detections into JSON-friendly dictionaries."""

        return [
            {"bbox": det.bbox, "area": det.area, "centroid": det.centroid}
            for det in detections
        ]
