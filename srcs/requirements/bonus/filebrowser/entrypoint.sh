#!/bin/sh
set -eu

# default fallback if not set
USER="${FILEBROWSER_USER:-admin}"
PASS="${FILEBROWSER_PASS:-admin}"

if [ ! -f /data/filebrowser.db ]; then
  filebrowser config init --database /data/filebrowser.db
  filebrowser users add "$USER" "$PASS" \
    --database /data/filebrowser.db \
    --perm.admin
fi

exec filebrowser \
  --database /data/filebrowser.db \
  --root /srv \
  --address 0.0.0.0 \
  --port 8080
