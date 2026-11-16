/* ───────────────────────────────────────────────────────────
   PoultryConnect — Upload Dropzone behaviour
   - Drag & drop, preview thumbnail, change/remove buttons
   - Large photos are resized in the browser (max 1600px, JPEG)
     so uploads stay small and fast on mobile data and on Vercel.
   ─────────────────────────────────────────────────────────── */
(function () {
  var MAX_DIM = 1600;
  var MAX_BYTES = 8 * 1024 * 1024; // hard limit before compression

  function fmtSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(0) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  }

  function setFile(input, file) {
    try {
      var dt = new DataTransfer();
      dt.items.add(file);
      input.files = dt.files;
      return true;
    } catch (e) {
      return false; // old browsers: keep the original file
    }
  }

  function compressImage(file) {
    return new Promise(function (resolve) {
      if (!/^image\/(jpeg|png|webp)$/i.test(file.type) || file.size < 400 * 1024) {
        resolve(file);
        return;
      }
      var url = URL.createObjectURL(file);
      var img = new Image();
      img.onload = function () {
        var w = img.naturalWidth, h = img.naturalHeight;
        var scale = Math.min(1, MAX_DIM / Math.max(w, h));
        var canvas = document.createElement('canvas');
        canvas.width = Math.round(w * scale);
        canvas.height = Math.round(h * scale);
        var ctx = canvas.getContext('2d');
        ctx.fillStyle = '#fff';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
        URL.revokeObjectURL(url);
        canvas.toBlob(function (blob) {
          if (!blob || blob.size >= file.size) { resolve(file); return; }
          var name = file.name.replace(/\.[^.]+$/, '') + '.jpg';
          resolve(new File([blob], name, { type: 'image/jpeg', lastModified: Date.now() }));
        }, 'image/jpeg', 0.85);
      };
      img.onerror = function () { URL.revokeObjectURL(url); resolve(file); };
      img.src = url;
    });
  }

  function init(root) {
    var input = root.querySelector('.pc-upload__input');
    var thumb = root.querySelector('.pc-upload__thumb');
    var nameEl = root.querySelector('.pc-upload__name');
    var sizeEl = root.querySelector('.pc-upload__size-text');
    var errEl = root.querySelector('.pc-upload__error');
    if (!input) return;

    function showError(msg) {
      root.classList.add('has-error');
      if (errEl) errEl.textContent = msg;
    }

    function clear() {
      input.value = '';
      root.classList.remove('has-file', 'has-error');
      if (thumb) thumb.innerHTML = '';
    }

    function render(file) {
      root.classList.remove('has-error');
      root.classList.add('has-file');
      nameEl.textContent = file.name;
      sizeEl.textContent = fmtSize(file.size) + ' — ready to upload';
      thumb.innerHTML = '';
      if (/^image\//.test(file.type)) {
        var img = document.createElement('img');
        img.alt = 'Preview';
        img.src = URL.createObjectURL(file);
        thumb.appendChild(img);
      } else {
        thumb.textContent = (file.name.split('.').pop() || 'FILE').toUpperCase();
      }
    }

    function handle(file) {
      if (!file) { clear(); return; }
      var accept = (input.getAttribute('accept') || '').toLowerCase();
      var ext = '.' + (file.name.split('.').pop() || '').toLowerCase();
      if (accept && accept !== 'image/*' && accept.indexOf(ext) === -1) {
        clear();
        showError('File type not allowed. Accepted: ' + accept.replace(/\./g, '').toUpperCase());
        return;
      }
      if (accept === 'image/*' && !/^image\//.test(file.type)) {
        clear();
        showError('Please choose an image file (JPG, PNG or WEBP).');
        return;
      }
      if (file.size > MAX_BYTES && !/^image\//.test(file.type)) {
        clear();
        showError('File is too large (max 8 MB).');
        return;
      }
      sizeEl.textContent = 'Optimizing…';
      compressImage(file).then(function (out) {
        if (out !== file) setFile(input, out);
        if (out.size > 4 * 1024 * 1024) {
          clear();
          showError('File is too large after optimizing (max 4 MB). Please choose a smaller file.');
          return;
        }
        render(out);
      });
    }

    input.addEventListener('change', function () {
      handle(input.files && input.files[0]);
    });

    ['dragenter', 'dragover'].forEach(function (ev) {
      root.addEventListener(ev, function (e) { e.preventDefault(); root.classList.add('is-dragover'); });
    });
    ['dragleave', 'drop'].forEach(function (ev) {
      root.addEventListener(ev, function (e) { e.preventDefault(); root.classList.remove('is-dragover'); });
    });
    root.addEventListener('drop', function (e) {
      var f = e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0];
      if (f && setFile(input, f)) handle(f);
    });

    var changeBtn = root.querySelector('.pc-upload__action--change');
    var removeBtn = root.querySelector('.pc-upload__action--remove');
    if (changeBtn) changeBtn.addEventListener('click', function () { input.click(); });
    if (removeBtn) removeBtn.addEventListener('click', clear);
  }

  function boot() {
    document.querySelectorAll('.pc-upload').forEach(init);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
  else boot();
})();
