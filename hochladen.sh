#!/bin/zsh
# Netboard veröffentlichen: Fassung stempeln, hochladen, ins Repo sichern.
# Aufruf:  ./hochladen.sh "Titel" "Punkt eins" "Punkt zwei"
#          ./hochladen.sh ""          still, ohne Neuerungen in der App
set -e
cd "$(dirname "$0")"
ENV_DATEI=~/.config/netboard/.env
[ -f "$ENV_DATEI" ] && { set -a; . "$ENV_DATEI"; set +a; }

STAND=$(date +%Y-%m-%d-%H%M)

# Fassung in die App stempeln
python3 - "$STAND" <<'PY'
import re, sys
stand = sys.argv[1]
s = open("index.html", encoding="utf-8").read()
if not re.search(r'var VERSION = "[^"]*";', s): raise SystemExit("VERSION nicht gefunden")
s = re.sub(r'var VERSION = "[^"]*";', 'var VERSION = "%s";' % stand, s, count=1)
open("index.html", "w", encoding="utf-8").write(s)
PY

# Neuerungen, die in der App einmal angezeigt werden
python3 - "$STAND" "$@" <<'PY2'
import json, sys
stand = sys.argv[1]
punkte = [p for p in sys.argv[3:] if p.strip()]
if not punkte and len(sys.argv) > 2 and sys.argv[2].strip(): punkte = [sys.argv[2]]
json.dump({"stand": stand, "punkte": punkte}, open("version.json", "w", encoding="utf-8"), ensure_ascii=False)
PY2
echo "$STAND" > version.txt

# Hochladen per FTP, nur wenn Zugangsdaten hinterlegt sind (FTP_HOST, FTP_USER, FTP_PASS, FTP_ORDNER)
if [ -n "$FTP_HOST" ]; then
  for f in index.html sw.js manifest.webmanifest icon-192.png icon-512.png version.json version.txt .htaccess; do
    [ -f "$f" ] || continue
    curl -s --ssl-reqd -T "$f" "ftp://$FTP_HOST/$FTP_ORDNER/$f" -u "$FTP_USER:$FTP_PASS" -o /dev/null -w "$f %{http_code}  "
  done
  echo
  echo "Stand $STAND ist hochgeladen (226 heißt angekommen)"
else
  echo "Keine FTP-Daten in $ENV_DATEI, nur ins Repo gesichert"
fi

git add -A
git commit -q -m "${1:-Neue Fassung} (Stand $STAND)" || true
git remote | grep -q . && git push -q || echo "Kein Remote eingerichtet, nur lokal gesichert"
