#!/bin/bash
#Uninstallation script for Redshift Time Control

set -e

echo "╔════════════════════════════════════╗"
echo "║Redshift time control uninstallation║"
echo "╚════════════════════════════════════╝"
echo ""
echo "Warning: This will remove all Redshift Time Control components."
echo ""
read -p "Continue anyway? (j/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Jj]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
#Stop service and timer
echo "Stopping services..."
systemctl --user stop redshift-timestamped.timer 2>/dev/null || true
systemctl --user stop redshift-timestamped.service 2>/dev/null || true

#Disable service and timer
echo "Disabling services..."
systemctl --user disable redshift-timestamped.timer 2>/dev/null || true
systemctl --user disable redshift-login.timer 2>/dev/null || true
systemctl --user disable redshift-timestamped.service 2>/dev/null || true

#Remove files
echo "Removing files..."
rm -f ~/.config/systemd/user/redshift-timestamped.timer
rm -f ~/.config/systemd/user/redshift-login.timer
rm -f ~/.config/systemd/user/redshift-timestamped.service
rm -f ~/.local/bin/redshift-timestamped.sh

#Reload systemd
echo "Realoading systemd..."
systemctl --user daemon-reload

#Reset redshift
echo "Resetting redshift..."
redshift -x 2>/dev/null || true

echo ""
echo "╔═════════════════════════╗"
echo "║Uninstallation completed!║"
echo "╚═════════════════════════╝"
echo ""
echo "All services and settings have been reset."
echo "The blue light filter has been reset."
