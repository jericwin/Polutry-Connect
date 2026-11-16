"""
File storage helper — PoultryConnect

Uploaded files are stored in the `stored_files` table and served from
/media/<id>. This works on read-only serverless hosts (Vercel), and every
device that shares the same database sees the same pictures.
"""
import os
import tempfile
from contextlib import contextmanager

from flask import url_for
from werkzeug.utils import secure_filename

from app import db
from app.models import StoredFile

MAX_UPLOAD_BYTES = 4 * 1024 * 1024  # stay under Vercel's 4.5 MB request limit

_EXT_MIME = {
    'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png',
    'webp': 'image/webp', 'gif': 'image/gif', 'pdf': 'application/pdf',
}


class UploadTooLarge(Exception):
    pass


def file_ext(filename: str) -> str:
    return filename.rsplit('.', 1)[1].lower() if filename and '.' in filename else ''


def save_upload(file_storage, owner_id=None, private=False) -> str:
    """Persist an uploaded werkzeug FileStorage. Returns the public URL (/media/<id>)."""
    data = file_storage.read()
    if len(data) > MAX_UPLOAD_BYTES:
        raise UploadTooLarge(f'File is too large ({len(data) // 1024} KB). Maximum is 4 MB.')
    name = secure_filename(file_storage.filename or 'upload') or 'upload'
    mime = file_storage.mimetype or _EXT_MIME.get(file_ext(name), 'application/octet-stream')
    if mime == 'application/octet-stream':
        mime = _EXT_MIME.get(file_ext(name), mime)
    rec = StoredFile(owner_id=owner_id, filename=name, mimetype=mime,
                     size_bytes=len(data), data=data, is_private=private)
    db.session.add(rec)
    db.session.flush()  # assign id
    return f'/media/{rec.id}'


@contextmanager
def temp_copy(file_url: str):
    """Yield a temporary local path holding the bytes of a stored /media/<id> file."""
    path = None
    try:
        rec = None
        if file_url and file_url.startswith('/media/'):
            try:
                rec = db.session.get(StoredFile, int(file_url.rsplit('/', 1)[1]))
            except ValueError:
                rec = None
        if rec is None:
            yield None
            return
        fd, path = tempfile.mkstemp(suffix='.' + (file_ext(rec.filename) or 'bin'))
        with os.fdopen(fd, 'wb') as fh:
            fh.write(rec.data)
        yield path
    finally:
        if path and os.path.exists(path):
            try:
                os.remove(path)
            except OSError:
                pass


def media_url(value) -> str:
    """Jinja filter: turn a stored path/URL into something an <img>/<a> can use."""
    if not value:
        return ''
    value = str(value)
    if value.startswith(('/', 'http://', 'https://', 'data:')):
        return value
    return url_for('static', filename=value)
