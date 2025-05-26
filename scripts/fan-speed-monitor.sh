#!/bin/bash
# fan-speed-monitor.sh
# Requires: sudo apt install lm-sensors

# Make sure you execute `chmod +x fan-speed-monitor.sh`

echo "Running sensor diagnostics..."
sensors | tee fan-temp-report.txt

CPU_TEMP=$(sensors | grep -i 'cpu temp\|Package id 0:' | awk '{print $NF}')
FAN_SPEED=$(sensors | grep -i 'fan' | awk '{print $2, $3}')

echo ""
echo "CPU Temperature: $CPU_TEMP"
echo "Fan Speed(s):"
echo "$FAN_SPEED"
