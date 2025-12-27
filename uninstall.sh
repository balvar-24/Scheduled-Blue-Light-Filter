#!/bin/bash
#Deinstallationsscript für Redshift Zeitsteuerung

set -e

echo "╔═════════════════════════════════════╗"
echo "║Redshift Zeitsteuerung Deinstallation║"
echo "╚═════════════════════════════════════╝"
echo ""
echo "Warnung: Diese Datei entfernt alle Redshift-Zeitsteuerungs-Komponenten."
echo ""
read -p "Trotzdem fortfahren? (j/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Jj]$ ]]; then
    echo "Abgebrochen."
    exit 0
fi

echo ""
#Service & Timer stoppen
echo "Stoppe Services..."
systemctl --user stop redshift-timestamped.timer 2>/dev/null || true
systemctl --user stop redshift-timestamped.service 2>/dev/null || true

#Service & Timer deaktivieren
echo "Deaktiviere Services..."
systemctl --user disable redshift-timestamped.timer 2>/dev/null || true
systemctl --user disable redshift-login.timer 2>/dev/null || true
systemctl --user disable redshift-timestamped.service 2>/dev/null || true

#Dateien löschen
echo "Entferne Dateien..."
rm -f ~/.config/systemd/user/redshift-timestamped.timer
rm -f ~/.config/systemd/user/redshift-login.timer
rm -f ~/.config/systemd/user/redshift-timestamped.service
rm -f ~/.local/bin/redshift-timestamped.sh

#Systemd neu laden
echo "Lade systemd neu..."
systemctl --user daemon-reload

#Redshift reset
echo "Setze Redshift zurück..."
redshift -x 2>/dev/null || true

echo ""
echo "╔═════════════════════════════╗"
echo "║Deinstallation abgeschlossen!║"
echo "╚═════════════════════════════╝"
echo ""
echo "Alle Dienste und Einstellungen zurückgesetzt."
echo "Der Blaulichtfilter wurde zurückgestellt."
