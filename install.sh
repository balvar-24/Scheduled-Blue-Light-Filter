#!/bin/bash
#Installationsskript für Redshift Zeitsteuerung

set -e

echo "╔═══════════════════════════════════╗"
echo "║Redshift Zeitsteuerung Installation║"
echo "╚═══════════════════════════════════╝"
echo ""

#Prüfen ob redshift installiert ist
if ! command -v redshift &> /dev/null; then
    echo "Warnung: redshift ist nicht installiert"
    echo "Bitte installieren mit: sudo apt install redshift"
    echo ""
    read -p "Trotzdem fortfahren? (j/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Jj]$ ]]; then
        exit 1
    fi
fi

#Prüfen ob xrandr verfügbar ist (für Multi-Monitor)
if ! command -v xrandr &> /dev/null; then
    echo "Warnung: xrandr ist nicht installiert"
    echo "Wird für Multi-Monitor-Unterstützung benötigt"
    echo "Installieren mit: sudo apt install x11-xserver-utils"
    echo ""
fi

#Verzeichnisse erstellen
echo "Erstelle Verzeichnisse..."
mkdir -p ~/.local/bin
mkdir -p ~/.config/systemd/user

#Script kopieren
echo "Kopiere Script..."
cp redshift-timestamped.sh ~/.local/bin/
chmod +x ~/.local/bin/redshift-timestamped.sh
echo "Script installiert: ~/.local/bin/redshift-timestamped.sh"

#Systemd-Dateien kopieren
echo "Kopiere systemd-Dateien..."
cp systemd/redshift-timestamped.service ~/.config/systemd/user/
cp systemd/redshift-timestamped.timer ~/.config/systemd/user/
cp systemd/redshift-login.timer ~/.config/systemd/user/
echo "Service-Dateien installiert"

#Systemd neu laden
echo "Lade systemd neu..."
systemctl --user daemon-reload

#Services aktivieren
echo "Aktiviere Services..."
systemctl --user enable redshift-timestamped.service
systemctl --user enable redshift-timestamped.timer
systemctl --user enable redshift-login.timer

#Timer starten
echo "Starte Timer..."
systemctl --user start redshift-timestamped.timer 2>/dev/null || true

#Initiales Setup ausführen
echo "Führe initiales Setup aus..."
#Kurz warten damit Display erkannt wird
sleep 2
systemctl --user start redshift-timestamped.service 2>/dev/null || true

#Warte auf Abschluss und zeige Ergebnis
sleep 2
if systemctl --user is-active --quiet redshift-timestamped.service; then
    echo "Redshift erfolgreich aktiviert"
    #Zeige gefundene Bildschirme
    if command -v xrandr &> /dev/null; then
        SCREENS=$(xrandr --query 2>/dev/null | grep " connected" | cut -d' ' -f1 | wc -l)
        echo "Aktive Bildschirme: $SCREENS"
    fi
else
    echo "Initiales Setup fehlgeschlagen (siehe Logs)"
fi

echo ""
echo "╔═══════════════════════════╗"
echo "║Installation abgeschlossen!║"
echo "╚═══════════════════════════╝"
echo ""
echo "Status prüfen:"
echo "systemctl --user status redshift-timestamped.service"
echo "systemctl --user list-timers --all"
echo ""
echo "Logs ansehen:"
echo "journalctl --user -t redshift -f"
echo "journalctl --user -t redshift --since today"
echo ""
echo "Zeitplan:"
echo "07:00-19:00 → 6000K (day)"
echo "19:00-22:00 → 4300K (evening)"
echo "22:00-07:00 → 3600K (night)"
