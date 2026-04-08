FROM infiniflow/ragflow:v0.23.1

# Bake nginx
COPY docker/nginx/ragflow.conf /etc/nginx/conf.d/ragflow.conf
COPY docker/nginx/proxy.conf /etc/nginx/proxy.conf
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# ✅ PATCH GLOBAL ROBUSTE (embedding + file read)
RUN python - <<'EOF'
import pathlib

patched = 0

for p in pathlib.Path("/ragflow").rglob("naive.py"):
    try:
        s = p.read_text()

        original = s

        # --- FIX 1: embedding crash ---
        s = s.replace(
            'raise Exception("Embedding extraction from file path is not supported.")',
            'embeds = []  # patched: skip file-path embedding'
        )

        # --- FIX 2: file not found ---
        s = s.replace(
            'with open(filename, "r") as f:',
            'try:\n            with open(filename, "r") as f:\n                txt = f.read()\n        except FileNotFoundError:\n            if binary is not None:\n                txt = binary.decode("utf-8", errors="ignore")\n            else:\n                raise'
        )

        if s != original:
            p.write_text(s)
            print(f"patched: {p}")
            patched += 1

    except Exception as e:
        print(f"skip {p}: {e}")

print(f"TOTAL PATCHED FILES: {patched}")

if patched == 0:
    raise Exception("❌ No files patched — something is wrong")
EOF

EXPOSE 80 9380
