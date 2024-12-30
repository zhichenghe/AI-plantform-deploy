#!/bin/bash
# Check if cpufrequtils package is installed
if ! [ -x "$(command -v cpufreq-set)" ]; then
  echo "Error: cpufrequtils package is not installed. Please install it first."
  exit 1
fi

cpu_mode=performance
#cpu_mode=powersave

# Get the number of CPU cores
cpu_cores=$(nproc)

# Set performance mode for each CPU core
for ((cpu=0; cpu<$cpu_cores; cpu++));
do
  sudo cpufreq-set -c $cpu -g ${cpu_mode}
done

# Verify the current CPU frequency governor
cpufreq-info --policy | grep "current policy"

echo "Curent CPU(${cpu_cores}) are ${cpu_mode}."
# cat /proc/cpuinfo | grep processor | wc -l