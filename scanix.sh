#!/bin/bash

# ==============================================================================
# Author: Karthik
# GitHub: https://github.com/karthikiyer/scanix
# License: MIT
# Description: penetration testing automation tool with
#              multi-threaded scanning, directory busting, and vulnerability
#              detection capabilities.
# ==============================================================================

# Pentesting Automation Script
# Usage: ./pentest_automation.sh <IP_ADDRESS>
echo """
 ░▒▓███████▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
 ░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓██████▓▒░  
       ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
       ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
                                                                         
                                                                         

                                                           v1.0

"""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if IP address is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    echo "Example: $0 192.168.1.100"
    exit 1
fi

IP=$1
OUTPUT_DIR="/tmp/pentest_${IP}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

print_status "Starting penetration testing against $IP"
print_status "Output directory: $OUTPUT_DIR"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
print_status "Checking required tools..."
for tool in nmap feroxbuster nikto qterminal; do
    if command_exists "$tool"; then
        print_success "$tool is installed"
    else
        print_error "$tool is not installed"
        exit 1
    fi
done

# Function to get open ports from full port scan
get_open_ports() {
    local ip=$1
    local output_file="$OUTPUT_DIR/nmap_full_ports.txt"
    
    # Wait for full port scan to complete and extract open ports
    while [ ! -f "$output_file" ] || ! grep -q "Nmap done" "$output_file"; do
        sleep 5
    done
    
    # Extract open ports
    grep -E '^[0-9]+/tcp.*open' "$output_file" | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//'
}

# Function to check if port is HTTP/HTTPS
is_web_port() {
    local port=$1
    # Common web ports and any port that might run HTTP/HTTPS service
    case $port in
        80|443|8080|8443|8000|8008|3000|5000|9000)
            return 0
            ;;
        *)
            # Check if service detection shows HTTP/HTTPS
            if [ -f "$OUTPUT_DIR/nmap_service_scan.txt" ] && \
               grep -q "$port/tcp.*open" "$OUTPUT_DIR/nmap_service_scan.txt" && \
               (grep -q "$port/tcp.*http" "$OUTPUT_DIR/nmap_service_scan.txt" || \
                grep -q "$port/tcp.*ssl/http" "$OUTPUT_DIR/nmap_service_scan.txt"); then
                return 0
            fi
            return 1
            ;;
    esac
}

# Function to run feroxbuster scans in series for a specific port
run_feroxbuster_series() {
    local ip=$1
    local port=$2
    local protocol="http"
    
    # Check if it's HTTPS
    if [ "$port" -eq 443 ] || [ "$port" -eq 8443 ]; then
        protocol="https"
    fi
    
    local url="$protocol://$ip:$port"
    local title_port=$port
    
    print_status "Starting sequential directory busting for $url"
    
    # Create a script for sequential execution
    local script_file="$OUTPUT_DIR/ferox_series_$port.sh"
    cat > "$script_file" << EOF
#!/bin/bash
echo "=== Starting sequential directory busting for $url ==="
echo "1. Running feroxbuster with small wordlist..."
feroxbuster -u "$url" -w /usr/share/seclists/Discovery/Web-Content/common.txt -o "$OUTPUT_DIR/ferox_small_$port.txt" -k -C 404,403
echo "Small wordlist scan completed."

echo "2. Running feroxbuster with large wordlist..."
feroxbuster -u "$url" -w /usr/share/seclists/Discovery/Web-Content/big.txt -o "$OUTPUT_DIR/ferox_large_$port.txt" -k -C 404,403
echo "Large wordlist scan completed."

echo "3. Running nikto scan..."
nikto -h "$url" -output "$OUTPUT_DIR/nikto_$port.txt"
echo "Nikto scan completed."

echo "=== All scans completed for $url ==="
echo "Press Enter to close this terminal..."
read
EOF
    
    chmod +x "$script_file"
    
    # Run all scans in one qterminal instance
    qterminal --title "Directory Scan $url" -e bash -c "$script_file" &
}

# Function to run individual directory busting (if needed separately)
run_directory_busting() {
    local ip=$1
    local port=$2
    run_feroxbuster_series "$ip" "$port"
}

# Terminal 1: Service version detection
print_status "Starting service version scan in Terminal 1"
qterminal --title "Version Scan $IP" -e bash -c "
echo 'Running nmap service version scan on $IP';
nmap -sV '$IP' -oN '$OUTPUT_DIR/nmap_service_scan.txt';
echo 'Service scan completed. Press Enter to close...';
read" &

# Terminal 2: Full port scan followed by aggressive scan
print_status "Starting full port scan in Terminal 2"
qterminal --title "Full Port Scan $IP" -e bash -c "
echo 'Running full port scan on $IP';
nmap -p- '$IP' -T4 -oN '$OUTPUT_DIR/nmap_full_ports.txt';
echo 'Full port scan completed. Extracting open ports...';

# Wait a moment for file to be fully written
sleep 2

OPEN_PORTS=\$(grep -E '^[0-9]+/tcp.*open' '$OUTPUT_DIR/nmap_full_ports.txt' | cut -d'/' -f1 | tr '\\n' ',' | sed 's/,\$//');

if [ -n \"\$OPEN_PORTS\" ]; then
    echo 'Open ports found: \$OPEN_PORTS';
    echo 'Starting aggressive scan on open ports...';
    nmap -A -p \"\$OPEN_PORTS\" '$IP' -oN '$OUTPUT_DIR/nmap_aggressive.txt';
    
    # Identify web ports and run directory busting
    for port in \$(echo \"\$OPEN_PORTS\" | tr ',' ' '); do
        if [ \"\$port\" -eq 80 ] || [ \"\$port\" -eq 443 ] || [ \"\$port\" -eq 8080 ] || [ \"\$port\" -eq 8443 ] || [ \"\$port\" -eq 8000 ] || [ \"\$port\" -eq 8008 ] || [ \"\$port\" -eq 3000 ] || [ \"\$port\" -eq 5000 ] || [ \"\$port\" -eq 9000 ]; then
            echo 'Port \$port appears to be a web service. Starting directory busting...';
            # We'll let the monitoring function handle this to avoid complexity
        fi
    done
else
    echo 'No open ports found.';
fi

echo 'Aggressive scan completed. Press Enter to close...';
read" &

# Monitor for web services and start directory busting
print_status "Monitoring for web services..."
(
    # First, wait for service scan to complete
    print_status "Waiting for service scan to complete..."
    while [ ! -f "$OUTPUT_DIR/nmap_service_scan.txt" ] || ! grep -q "Nmap done" "$OUTPUT_DIR/nmap_service_scan.txt"; do
        sleep 10
    done
    
    print_success "Service scan completed. Identifying web services..."
    
    # Array to track ports we've already processed
    processed_ports=()
    
    # Check for common web ports first
    for port in 80 443 8080 8443 8000 8008 3000 5000 9000; do
        if grep -q "$port/tcp.*open" "$OUTPUT_DIR/nmap_service_scan.txt"; then
            if [[ ! " ${processed_ports[@]} " =~ " ${port} " ]]; then
                print_success "Found web service on common port $port"
                run_feroxbuster_series "$IP" "$port"
                processed_ports+=("$port")
                # Small delay between starting each series to avoid resource contention
                sleep 2
            fi
        fi
    done
    
    # Check for non-standard web ports from service detection
    print_status "Checking for non-standard web ports..."
    if grep -E '[0-9]+/tcp.*open.*http' "$OUTPUT_DIR/nmap_service_scan.txt" | while read -r line; do
        port=$(echo "$line" | cut -d'/' -f1)
        if [[ ! " ${processed_ports[@]} " =~ " ${port} " ]]; then
            print_success "Found HTTP service on non-standard port $port"
            run_feroxbuster_series "$IP" "$port"
            processed_ports+=("$port")
            sleep 2
        fi
    done; then
        print_success "Non-standard port check completed"
    fi
    
    # Also check full port scan for additional web ports
    print_status "Checking full port scan for additional web services..."
    if [ -f "$OUTPUT_DIR/nmap_full_ports.txt" ] && grep -q "Nmap done" "$OUTPUT_DIR/nmap_full_ports.txt"; then
        grep -E '^[0-9]+/tcp.*open' "$OUTPUT_DIR/nmap_full_ports.txt" | cut -d'/' -f1 | while read -r port; do
            if [[ ! " ${processed_ports[@]} " =~ " ${port} " ]] && is_web_port "$port"; then
                print_success "Found additional web service on port $port"
                run_feroxbuster_series "$IP" "$port"
                processed_ports+=("$port")
                sleep 2
            fi
        done
    fi
    
    print_success "Web service detection and directory busting initialization completed"
) &

print_success "All tasks started in separate terminals!"
print_status "Output files are being saved to: $OUTPUT_DIR"
echo ""
print_status "Terminal Layout:"
echo "  - Terminal 1: Nmap Service Scan"
echo "  - Terminal 2: Nmap Full Port Scan → Aggressive Scan" 
echo "  - Terminal 3+: Sequential directory busting (Feroxbuster + Nikto) for each web port"
echo ""
print_warning "Directory busting now runs sequentially in each terminal to avoid resource conflicts"
print_warning "Remember to review all findings and conduct testing ethically and legally!"