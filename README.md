
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

- **🔍 Parallel Scanning**: Simultaneous nmap scans for efficiency
- **🌐 Smart Web Detection**: Auto-identifies HTTP/HTTPS services on any port
- **📁 Sequential Directory Busting**: Feroxbuster + Nikto in organized workflow
- **💾 Structured Output**: Timestamped, well-organized results
- **🎯 Resource Optimized**: Prevents system overload with intelligent scheduling

##  Installation

```bash
git clone https://github.com/karthikiyer/scanix.git
cd scanix
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
``
./scanix.sh 192.168.1.100
``<br>
### Workflow

Service Discovery - Nmap version detection
Port Enumeration - Comprehensive TCP port scan
Web Assessment - Auto directory busting on discovered web services
Vulnerability Scanning - Nikto checks on web applications

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
### Terminal Layout

Terminal 1: Service Version Scan
Terminal 2: Full Port → Aggressive Scan
Terminal 3+: Directory busting per web port

## ⚠️ Legal & Ethical Use

This tool is for:

Authorized penetration testing
Security research with permission
Educational purposes in controlled environments

Requires explicit permission before scanning any systems.
### Contributing

Contributions welcome! Feel free to submit issues and pull requests.
### License

MIT License - see LICENSE file for details.

## ⭐ Star this repo if you find it useful!

