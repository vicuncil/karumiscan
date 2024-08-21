#!/bin/bash

RED='\033[1;31m'
NC='\033[0m' 

scan_ports() {
  TARGET=$1

  echo "Pinging $TARGET..."
  ping -c 4 $TARGET

  echo "Checking open ports on $TARGET..."

  PORTS="22 80 443 8080 25"

  for PORT in $PORTS; do
    timeout 1 bash -c "echo > /dev/tcp/$TARGET/$PORT" 2>/dev/null && echo "Port $PORT is open" || echo "Port $PORT is closed"
  done
}

scan_os() {
  TARGET=$1

  echo "Scanning for operating system on $TARGET..."
  nmap -O $TARGET
}

email_details() {
  EMAIL=$1
  DOMAIN=$(echo $EMAIL | awk -F'@' '{print $2}')

  echo "Email: $EMAIL"
  echo "Domain: $DOMAIN"

  if command -v whois >/dev/null 2>&1; then
    echo "Fetching domain information..."
    whois $DOMAIN | grep -E 'Creation Date|Creation Date|created|Domain created|Domain Registration Date' | head -n 1
  else
    echo "whois command not found. Please install whois to fetch domain information."
  fi

  if command -v dig >/dev/null 2>&1; then
    echo "Fetching MX records..."
    dig MX $DOMAIN +short
  else
    echo "dig command not found. Please install dig to fetch MX records."
  fi
}

scan_wifi() {
  echo "Scanning for nearby Wi-Fi networks..."
  
  if command -v iwlist >/dev/null 2>&1; then

    sudo iwlist scan | grep 'ESSID:' | awk -F':' '{print $2}' | sed 's/"//g'
  elif command -v airport >/dev/null 2>&1; then
    airport -s | awk '{print $1}'
  else
    echo "Neither iwlist nor airport command found. Please install wireless-tools or use macOS airport command."
  fi
}


echo -e "${RED} 
   ▄█   ▄█▄    ▄████████    ▄████████ ███    █▄    ▄▄▄▄███▄▄▄▄    ▄█   
  ███ ▄███▀   ███    ███   ███    ███ ███    ███ ▄██▀▀▀███▀▀▀██▄ ███  
  ███▐██▀     ███    ███   ███    ███ ███    ███ ███   ███   ███ ███▌ 
 ▄█████▀      ███    ███  ▄███▄▄▄▄██▀ ███    ███ ███   ███   ███ ███▌ 
▀▀█████▄    ▀███████████ ▀▀███▀▀▀▀▀   ███    ███ ███   ███   ███ ███▌ 
  ███▐██▄     ███    ███ ▀███████████ ███    ███ ███   ███   ███ ███  
  ███ ▀███▄   ███    ███   ███    ███ ███    ███ ███   ███   ███ ███  
  ███   ▀█▀   ███    █▀    ███    ███ ████████▀   ▀█   ███   █▀  █▀   
  ▀                        ███    ███                                 

                                                    
                         
Karumi is  scan tool for  scaning  ports,ping,os and etc.

                                                                       ${NC}"   
echo -e "${RED}[1]- Start Scan ${NC}"
echo -e "${RED}[2]- Scan OS ${NC}"
echo -e "${RED}[3]- Email Detail ${NC}"
echo -e "${RED}[4]- Wi-Fi Networks ${NC}"
read -p "Choose option: " OPTION

case $OPTION in
  1)

    if [ -z "$1" ]; then
      echo "Usage: bash $0 <IP address or ip/24>"
      exit 1
    fi
    scan_ports $1
    ;;
  2)

    if [ -z "$1" ]; then
      echo "Usage: bash $0 <IP address for scan OS>"
      exit 1
    fi
    scan_os $1
    ;;
  3)

    if [ -z "$1" ]; then
      echo "Usage: bash $0 <email address>"
      exit 1
    fi
    email_details $1
    ;;
  4)

    scan_wifi
    ;;
  *)
    echo "Invalid Option"
    ;;
esac
