"""
Content Moderation Engine — PoultryConnect 2.0
Lightweight, local image validation and integrity inspection for marketplace uploads.
Does not require external Generative AI or API keys.
"""

import os
import json
from PIL import Image

ALLOWED_FORMATS = {'JPEG', 'JPG', 'PNG', 'WEBP', 'MPO'}
MIN_DIMENSION = 50       # Minimum width and height in pixels
MAX_DIMENSION = 8000     # Maximum width and height in pixels
MAX_FILE_SIZE_MB = 15    # Maximum file size in MB


def moderate_image(image_path: str):
    """
    Validates an uploaded image for marketplace product listings.
    Checks file integrity, allowed formats, dimensions, and size.

    Returns:
        tuple: (is_safe: bool, flag_reason: str, full_json_response: str)
    """
    if not image_path or not os.path.exists(image_path):
        reason = "Image file does not exist or could not be found."
        return False, reason, json.dumps({"safe": False, "reason": reason, "category": "Missing"})

    # 1. File size check
    try:
        file_size_bytes = os.path.getsize(image_path)
        if file_size_bytes == 0:
            reason = "Uploaded file is empty (0 bytes)."
            return False, reason, json.dumps({"safe": False, "reason": reason, "category": "Corrupted"})
        if file_size_bytes > MAX_FILE_SIZE_MB * 1024 * 1024:
            reason = f"Image exceeds maximum allowable size of {MAX_FILE_SIZE_MB}MB."
            return False, reason, json.dumps({"safe": False, "reason": reason, "category": "SizeLimit"})
    except Exception as e:
        reason = f"Failed to check file size: {str(e)}"
        return False, reason, json.dumps({"safe": False, "reason": reason, "category": "FileError"})

    # 2. Image integrity and format verification using Pillow
    try:
        with Image.open(image_path) as img:
            fmt = (img.format or '').upper()
            if fmt not in ALLOWED_FORMATS:
                reason = f"Unsupported image format: {fmt}. Please upload a JPEG, PNG, or WEBP image."
                return False, reason, json.dumps({"safe": False, "reason": reason, "category": "Format"})

            width, height = img.size
            if width < MIN_DIMENSION or height < MIN_DIMENSION:
                reason = f"Image dimensions too small ({width}x{height}). Minimum required is {MIN_DIMENSION}x{MIN_DIMENSION} pixels."
                return False, reason, json.dumps({"safe": False, "reason": reason, "category": "Dimensions"})

            if width > MAX_DIMENSION or height > MAX_DIMENSION:
                reason = f"Image dimensions too large ({width}x{height}). Maximum allowed is {MAX_DIMENSION}x{MAX_DIMENSION} pixels."
                return False, reason, json.dumps({"safe": False, "reason": reason, "category": "Dimensions"})

            # Verify image file integrity
            img.verify()

        return True, "", json.dumps({"safe": True, "category": "Safe", "reason": ""})

    except Exception as e:
        reason = f"Image validation error or corrupted file: {str(e)}"
        return False, reason, json.dumps({"safe": False, "reason": reason, "category": "Corrupted"})
