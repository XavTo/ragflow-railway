FROM infiniflow/ragflow:v0.23.1

# Bake nginx
COPY docker/nginx/ragflow.conf /etc/nginx/conf.d/ragflow.conf
COPY docker/nginx/proxy.conf /etc/nginx/proxy.conf
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# ✅ PATCH ROBUSTE
RUN python - <<'EOF'
import pathlib

p = pathlib.Path("/ragflow/rag/app/naive.py")
s = p.read_text()

if "Embedding extraction from file path is not supported." not in s:
    raise Exception("Patch failed: string not found")

s = s.replace(
    'raise Exception("Embedding extraction from file path is not supported.")',
    'embeds = []  # patched: skip file-path embedding'
)

p.write_text(s)
print("✅ Patch applied")
EOF

EXPOSE 80 9380
