#!/bin/bash

sudo ptp4l -i mgbe3_0 -f /etc/automotive-slave.cfg -D &

function kill_process_if_exists() {
    local process_name=$1
    local pid=$(pgrep $process_name)

    if [ -n "$pid" ]; then
        pkexec env SUDO_USER=$USER kill $pid
    fi
}

kill_process_if_exists ntp
kill_process_if_exists phc2sys

pkexec env SUDO_USER=$USER rm /tmp/time_sync_ok
sed -i '/MCU2UTC_OFFSET/d' /etc/environment

# Get the current system time
system_time=$(date +%s)

if [ -e "/dev/ptp0" ]; then
    # Synchronize time with MCU, run in the background
    pkexec env SUDO_USER=$USER phc2sys -s mgbe3_0 -O 0 -S 1 &
else
    sleep 8
    pkexec env SUDO_USER=$USER phc2sys -s mgbe3_0 -O 0 -S 1 &
fi

# Calculate the time delta between system time and current time
current_time=$(date +%s)
delta=$(($system_time - $current_time))

for i in {1..5}
do
    sleep 10
# Execute the command and capture the output
    output=$(pkexec env SUDO_USER=$USER ntpdate ntp.aliyun.com)
#output=$(pkexec env SUDO_USER=$USER python3 -m timesync.py)
# Get the return value
    return_value=$?
# Check if the return value is 0
    if [ $return_value -eq 0 ]; then
        # Extract the tenth data separated by space
        data=$(echo "$output" | awk '{print $10}')
        delta=${data%.*}
        echo "INFO: ntpdate success" >> /tmp/timesync.log
        break;
    else
        echo "WARN: ntpdate failed" >> /tmp/timesync.log
        continue;
    fi
done

zero=0
if [ $delta -le $zero ]; then
    delta=0
fi

echo "Time Delta (seconds): $delta"
echo "$delta" >> /tmp/time_sync_ok
echo "MCU2UTC_OFFSET=$delta" >> /etc/environment

kill_process_if_exists phc2sys

# Subsequent SOC time will be accumulated based on MCU time + delta time
echo "INFO: phc2sys process running"
pkexec env SUDO_USER=$USER phc2sys -s mgbe3_0 -O $delta -S 1 &

echo "INFO: timesync OK"
