FROM infiniflow/ragflow:v0.23.1

# Bake nginx
COPY docker/nginx/ragflow.conf /etc/nginx/conf.d/ragflow.conf
COPY docker/nginx/proxy.conf /etc/nginx/proxy.conf
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# ✅ PATCH 1 — embedding bug (déjà OK)
RUN python - <<'EOF'
import pathlib

p = pathlib.Path("/ragflow/rag/app/naive.py")
s = p.read_text()

if "Embedding extraction from file path is not supported." not in s:
    raise Exception("Patch 1 failed")

s = s.replace(
    'raise Exception("Embedding extraction from file path is not supported.")',
    'embeds = []  # patched: skip file-path embedding'
)

p.write_text(s)
print("✅ Patch 1 applied")
EOF


# ✅ PATCH 2 — FIX MINIO (fallback si fichier local absent)
RUN python - <<'EOF'
import pathlib

p = pathlib.Path("/ragflow/rag/app/naive.py")
s = p.read_text()

old = '''with open(filename, "r") as f:
                txt = f.read()'''

new = '''try:
                with open(filename, "r") as f:
                    txt = f.read()
            except FileNotFoundError:
                if binary is not None:
                    txt = binary.decode("utf-8", errors="ignore")
                else:
                    raise'''

if old not in s:
    raise Exception("Patch 2 failed: block not found")

s = s.replace(old, new)
p.write_text(s)

print("✅ Patch 2 applied")
EOF

EXPOSE 80 9380
