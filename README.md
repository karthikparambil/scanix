
<div align="center">

<img src="https://github.com/karthikparambil/scanix/blob/main/assets/images/scanix-bgrm.png" width="350" alt="Scanix Logo">

<br>

![Version](https://img.shields.io/badge/Version-1.0-blue)
![Platform](https://img.shields.io/badge/Platform-Linux-orange)
![License](https://img.shields.io/badge/License-MIT-green)

**Automated Reconnaissance Suite for Penetration Testing**

</div>

---









## Overview

Scanix is a powerful automation tool that streamlines the initial reconnaissance phase of penetration testing. It orchestrates multiple security tools Nmap, Feroxbuster, Nikto across parallel terminals to provide comprehensive target assessment with minimal manual intervention.

## Features

- **Parallel Scanning**: Simultaneous nmap scans for efficiency
- **Smart Web Detection**: Auto-identifies HTTP/HTTPS services on any port
- **Sequential Directory Busting**: Feroxbuster + Nikto in organized workflow
- **Structured Output**: Timestamped, well-organized results
- **Resource Optimized**: Prevents system overload with intelligent scheduling


## Prerequisites -
Required Tools

Make sure the following tools are installed on your system:

| Tools        | Purpose                                      | Installation |
| -------------| ---------------------------------------------|--------------|
| Nmap         | Network discovery and security auditing      | `sudo apt install nmap `
| feroxbuster	 | Fast, recursive directory discovery          | `sudo apt install feroxbuster`
| nikto        | Web vulnerability scanner                    | `sudo apt install nikto`
| qterminal    | Terminal emulator for multi-window           | `sudo apt install qterminal`
| seclists     | Collection of multiple security wordlists    | `sudo apt install seclists`

##  Installation

```bash
# Clone the repository
git clone https://github.com/karthikiyer/scanix.git
cd scanix
# Make the script executable
chmod +x scanix.sh
```
## Dependencies
```
sudo apt update
sudo apt install nmap feroxbuster nikto qterminal
```
## Usage
```
./scanix.sh <TARGET_IP>
```
Example:
```
./scanix.sh 192.168.1.100
```
## Detailed Workflow

### Phase 1: Initial Setup

**Validation:** Checks for required tools and target IP

**Directory Creation:** Creates timestamped output directory

**Tool Verification:** Ensures all dependencies are installed

### Phase 2: Parallel Scanning (Terminal 1 & 2)

**Terminal 1:** Service version detection (nmap -sV)

**Terminal 2:** Full port scan (nmap -p-) followed by aggressive scan on discovered ports

### Phase 3: Web Service Detection & Enumeration

**Automatic Detection:** Identifies web services on common ports (80, 443, 8080, etc.)

**Service Analysis:** Checks service scan results for HTTP/HTTPS services

**Non-Standard Ports:** Detects web services on uncommon ports

### Phase 4: Sequential Directory Busting

For each identified web service, the tool executes in sequence:

**Feroxbuster (Small):** Quick scan with common wordlist

**Feroxbuster (Large):** Comprehensive scan with big wordlist

**Nikto Scan:** Web vulnerability assessment

## Terminal Layout
The tool automatically organizes work across multiple terminals:

+-------------------+  +--------------------+  +----------------------+
|   Terminal 1      |  |    Terminal 2      |  |     Terminal 3+      |
+-------------------+  +--------------------+  +----------------------+
|       |  |  Full Port Scan    |  |  Directory Busting   |
|           |  |  nmap -p- → -A     |  | Feroxbuster + Nikto  |
|                   |  |                    |  |   (per web port)     |
+-------------------+  +--------------------+  +----------------------+

| Terminal 1    |
|---------------|
| Service Scan  |
|  nmap -sV     |
|               |

### Output Structure
```
pentest_192.168.1.100_20231201_143022/
├── nmap_service_scan.txt
├── nmap_full_ports.txt
├── nmap_aggressive.txt
├── ferox_small_80.txt
├── ferox_large_80.txt
└── nikto_80.txt
```

## ⚠️ Legal & Ethical Use

This tool is for:

- **Authorized penetration testing**
- **Security research with permission**
- **Educational purposes in controlled environments**
- **Unauthorized scanning may be illegal in your jurisdiction**
- **Use responsibly and ethically**

## 🤝 Contributing

### *Contributions are welcome!*
Please feel free to submit pull requests or open issues for:

- Bug fixes
- New features
- Documentation improvements
- Performance enhancements

### 👨‍💻 Author: Karthik

**GitHub: @karthikparambil**

**Project: Scanix**

## ⭐ Star this repo if you find it useful!

Disclaimer: This tool is for educational and authorized testing purposes only. The authors are not responsible for any misuse or damage caused by this program.
