#!/bin/bash

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85
LOG_FILE="health_monitor.log"

check_cpu() {
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d '%id,')
    cpu_usage=$(echo "100 - $cpu_idle" | bc)
    echo "CPU Usage: ${cpu_usage}%"
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        echo "ALERT: CPU usage is above ${CPU_THRESHOLD}% → ${cpu_usage}%" | tee -a $LOG_FILE
    fi
}

check_memory() {
    mem_total=$(free | awk '/Mem:/ {print $2}')
    mem_used=$(free | awk '/Mem:/ {print $3}')
    mem_usage=$(echo "scale=2; $mem_used * 100 / $mem_total" | bc)
    echo "Memory Usage: ${mem_usage}%"
    if (( $(echo "$mem_usage > $MEM_THRESHOLD" | bc -l) )); then
        echo "ALERT: Memory usage is above ${MEM_THRESHOLD}% → ${mem_usage}%" | tee -a $LOG_FILE
    fi
}

check_disk() {
    disk_usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    echo "Disk Usage (/): ${disk_usage}%"
    if (( disk_usage > DISK_THRESHOLD )); then
        echo "ALERT: Disk usage is above ${DISK_THRESHOLD}% → ${disk_usage}%" | tee -a $LOG_FILE
    fi
}

check_processes() {
    proc_count=$(ps aux | wc -l)
    echo "Running Processes: $proc_count"
    top_procs=$(ps aux --sort=-%cpu | head -6 | tail -5 | awk '{print $11, "CPU:", $3"%"}')
    echo "Top Processes:"
    echo "$top_procs"
}

echo "===== System Health Report - $(date) ====="
check_cpu
check_memory
check_disk
check_processes
echo "==========================================="
