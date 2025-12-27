#!/bin/bash
#Redshift Zeitsteuerung
#Anpassung des Blaulichtfilters je nach Uhrzeit
#7-19  Uhr -> redshift -O 6000
#19-22 Uhr -> redshift -O 4300
#22-7  Uhr -> redshift -O 3600

#Fehlerabfang
set -euo pipefail

#X11 Umgebung sicherstellen
export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

#Stunde ermitteln
HOUR=$(date +%H)

#Logging-Funktionen
log() {
    echo "[$(date +'%H:%M:%S')] $*" | systemd-cat -t redshift -p info 2>/dev/null || echo "[$(date +'%H:%M:%S')] $*"
}

log_error() {
    echo "[$(date +'%H:%M:%S')] ERROR: $*" | systemd-cat -t redshift -p err 2>/dev/null || echo "[$(date +'%H:%M:%S')] ERROR: $*" >&2
}

#Start-Log
log "=== redshift-timestamped.sh START (HOUR=$HOUR) ==="
log "Log gestartet..."

#Prüfen ob redshift installiert ist
if ! command -v redshift >/dev/null 2>&1; then
    log_error "redshift ist nicht installiert"
    exit 1
fi

#Redshift zurücksetzen
log "Setze redshift zurück..."
redshift -x -m randr >/dev/null 2>&1 || log "Warnung: redshift -x fehlgeschlagen (möglicherweise nicht aktiv)"

#Farbtemperatur nach Uhrzeit bestimmen
if [ "$HOUR" -ge 7 ] && [ "$HOUR" -lt 19 ]; then
    K=6000
    PHASE="day"
elif [ "$HOUR" -ge 19 ] && [ "$HOUR" -lt 22 ]; then
    K=4300
    PHASE="evening"
else
    K=3600
    PHASE="night"
fi

#Phase loggen
log "Setze Blaulichtfilter: $PHASE (${K}K)"

#Redshift setzen
if redshift -O "$K" -m randr >/dev/null 2>&1; then
    log "Blaulichtfilter gesetzt: ${K}K ($PHASE)"
else
    log_error "Konnte Blaulichtfilter nicht setzen"
fi
