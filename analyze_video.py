#!/usr/bin/env python3
"""Command line utility for analysing smartphone camera video streams."""
from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path
from typing import Any, Dict

import cv2  # type: ignore

from mobile_video_analysis import MotionAnalyzer


def _parse_source(value: str) -> int | str:
    if value.isdigit():
        return int(value)
    return value


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Analyse a video feed (e.g. from a smartphone IP camera app) and detect motion in real time."
        )
    )
    parser.add_argument(
        "--source",
        default="0",
        help="Camera index or URL (for IP camera streams from a smartphone app).",
    )
    parser.add_argument(
        "--width", type=int, default=None, help="Optional override for capture width."
    )
    parser.add_argument(
        "--height", type=int, default=None, help="Optional override for capture height."
    )
    parser.add_argument(
        "--alpha",
        type=float,
        default=0.05,
        help="Learning rate for the running background model (0 < alpha <= 1).",
    )
    parser.add_argument(
        "--threshold",
        type=int,
        default=25,
        help="Pixel intensity threshold for motion detection.",
    )
    parser.add_argument(
        "--min-area",
        type=int,
        default=500,
        help="Minimum contour area in pixels required to report motion.",
    )
    parser.add_argument(
        "--dilate-iterations",
        type=int,
        default=2,
        help="Number of dilation iterations applied to the motion mask.",
    )
    parser.add_argument(
        "--blur-kernel",
        type=int,
        default=21,
        help="Odd-sized Gaussian blur kernel for noise reduction.",
    )
    parser.add_argument(
        "--record-out",
        type=Path,
        default=None,
        help="Optional path to save the annotated video (mp4v codec).",
    )
    parser.add_argument(
        "--save-metrics",
        type=Path,
        default=None,
        help="Optional path to a JSON file with per-frame detection metadata.",
    )
    parser.add_argument(
        "--max-frames",
        type=int,
        default=None,
        help="Stop after processing this many frames (useful for testing).",
    )
    parser.add_argument(
        "--display",
        action="store_true",
        help="Display the annotated video stream in a window (press q to exit).",
    )
    parser.add_argument(
        "--overlay-mask",
        action="store_true",
        help="Overlay the binary motion mask on top of the annotated frame.",
    )
    return parser


def _initialise_writer(
    path: Path, frame_shape: tuple[int, int, int], fps: float
) -> cv2.VideoWriter:
    height, width = frame_shape[:2]
    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    return cv2.VideoWriter(str(path), fourcc, fps, (width, height))


def run(args: argparse.Namespace) -> Dict[str, Any]:
    source = _parse_source(args.source)

    analyzer = MotionAnalyzer(
        alpha=args.alpha,
        threshold=args.threshold,
        min_area=args.min_area,
        dilate_iterations=args.dilate_iterations,
        blur_kernel=args.blur_kernel,
    )

    capture = cv2.VideoCapture(source)
    if not capture.isOpened():
        raise RuntimeError(f"Unable to open video source: {source}")

    if args.width:
        capture.set(cv2.CAP_PROP_FRAME_WIDTH, float(args.width))
    if args.height:
        capture.set(cv2.CAP_PROP_FRAME_HEIGHT, float(args.height))

    metrics: Dict[str, Any] = {
        "frames": 0,
        "motion_frames": 0,
        "detections": [],
        "source": source,
    }

    writer: cv2.VideoWriter | None = None
    fps = capture.get(cv2.CAP_PROP_FPS)
    if fps <= 0:
        fps = 30.0

    start_time = time.time()

    try:
        while True:
            ret, frame = capture.read()
            if not ret:
                break

            metrics["frames"] += 1
            result = analyzer.process(frame)
            if result.has_motion():
                metrics["motion_frames"] += 1

            annotated = analyzer.annotate_frame(frame, result.detections)
            if args.overlay_mask:
                annotated = analyzer.overlay_mask(annotated, result.mask)

            if args.record_out and writer is None:
                writer = _initialise_writer(args.record_out, annotated.shape, fps)
            if writer is not None:
                writer.write(annotated)

            if args.display:
                cv2.imshow("Mobile Motion Analysis", annotated)
                if cv2.waitKey(1) & 0xFF == ord("q"):
                    break

            metrics["detections"].append(
                {
                    "frame_index": metrics["frames"] - 1,
                    "detections": MotionAnalyzer.detections_to_dict(result.detections),
                }
            )

            if args.max_frames and metrics["frames"] >= args.max_frames:
                break
    finally:
        capture.release()
        if writer is not None:
            writer.release()
        if args.display:
            cv2.destroyAllWindows()

    elapsed = time.time() - start_time
    metrics["elapsed_seconds"] = elapsed
    metrics["average_fps"] = (
        metrics["frames"] / elapsed if elapsed > 0 else None
    )
    return metrics


def main(argv: list[str] | None = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)

    try:
        metrics = run(args)
    except Exception as exc:  # pragma: no cover - CLI convenience
        parser.error(str(exc))
        return 2

    if args.save_metrics:
        args.save_metrics.parent.mkdir(parents=True, exist_ok=True)
        args.save_metrics.write_text(
            json.dumps(metrics, indent=2, ensure_ascii=False), encoding="utf-8"
        )

    summary = (
        f"Processed {metrics['frames']} frames; "
        f"motion detected in {metrics['motion_frames']} frames; "
        f"average FPS: {metrics['average_fps']:.2f}"
        if metrics["average_fps"] is not None
        else f"Processed {metrics['frames']} frames; motion detected in {metrics['motion_frames']} frames."
    )
    print(summary)
    return 0


if __name__ == "__main__":
    sys.exit(main())
