#!/bin/bash

# check_freeipa_demo.sh
# Script to check if the FreeIPA demo server is down
# This script performs multiple checks to determine if the FreeIPA demo server is operational
# 
# Enhanced version with DNS failure handling:
# - Continues checks even when DNS resolution fails
# - Uses direct IP connection as fallback
# - Provides detailed diagnostic information

DEMO_HOST="ipa.demo1.freeipa.org"
DNS_DOMAIN="demo1.freeipa.org"
SUCCESS=0
FAILURE=1
TIMEOUT=5

# Text colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "Checking FreeIPA demo server status..."
echo "======================================="

# Check 1: DNS resolution
echo -n "DNS resolution test: "
if host "$DEMO_HOST" > /dev/null 2>&1; then
    echo -e "${GREEN}PASSED${NC} - $DEMO_HOST resolves to an IP address"
    IP_ADDRESS=$(host "$DEMO_HOST" | awk '/has address/ {print $4}' | head -1)
    echo "  IP Address: $IP_ADDRESS"
else
    echo -e "${RED}FAILED${NC} - Cannot resolve $DEMO_HOST"
    echo "The demo server may be down or DNS resolution is failing."
    echo "Continuing with direct IP checks..."
    
    # Hardcoded IP address as a fallback
    # This IP is just a placeholder - you should replace it with the actual known IP
    IP_ADDRESS="54.235.131.77"  # Example - replace with actual IP if known
    echo "  Using fallback IP Address: $IP_ADDRESS"
    DEMO_HOST="$IP_ADDRESS"
fi

# Check 2: ICMP ping
echo -n "ICMP ping test: "
if ping -c 1 -W $TIMEOUT "$DEMO_HOST" > /dev/null 2>&1; then
    echo -e "${GREEN}PASSED${NC} - Server responds to ping"
else
    echo -e "${YELLOW}WARNING${NC} - Server does not respond to ping"
    echo "  Note: This may be normal if ICMP is blocked."
fi

# Check 3: Web UI availability (HTTPS)
echo -n "Web UI availability test: "
# Try with host first, if that fails, try with hardcoded IP with Host header
curl_command="curl -s -o /dev/null -w \"%{http_code}\" -m $TIMEOUT"
HTTP_STATUS=$(eval "$curl_command \"https://$DEMO_HOST/ipa/ui/\" --insecure 2>/dev/null")

if [[ $HTTP_STATUS -eq 000 && "$IP_ADDRESS" != "$DEMO_HOST" ]]; then
    echo -e "${YELLOW}RETRY${NC} - Trying with IP address directly..."
    # Try with IP address and Host header
    HTTP_STATUS=$(eval "$curl_command \"https://$IP_ADDRESS/ipa/ui/\" -H \"Host: ipa.demo1.freeipa.org\" --insecure 2>/dev/null")
fi

if [[ $HTTP_STATUS -eq 200 || $HTTP_STATUS -eq 302 || $HTTP_STATUS -eq 301 ]]; then
    echo -e "${GREEN}PASSED${NC} - Web UI is available (HTTP status: $HTTP_STATUS)"
else
    echo -e "${RED}FAILED${NC} - Web UI is not available (HTTP status: $HTTP_STATUS)"
    echo "The demo server web interface is not responding."
fi

# Check 4: LDAP port availability
echo -n "LDAP port test: "
if timeout $TIMEOUT bash -c "echo > /dev/tcp/$DEMO_HOST/389" 2>/dev/null; then
    echo -e "${GREEN}PASSED${NC} - LDAP port (389) is open"
else
    echo -e "${RED}FAILED${NC} - LDAP port (389) is not accessible"
    echo "LDAP service may be down."
fi

# Check 5: Kerberos port availability
echo -n "Kerberos port test: "
if timeout $TIMEOUT bash -c "echo > /dev/tcp/$DEMO_HOST/88" 2>/dev/null; then
    echo -e "${GREEN}PASSED${NC} - Kerberos port (88) is open"
else
    echo -e "${RED}FAILED${NC} - Kerberos port (88) is not accessible"
    echo "Kerberos service may be down."
fi

# Check 6: Try to anonymously query the LDAP server
echo -n "LDAP anonymous query test: "
if which ldapsearch >/dev/null 2>&1; then
    LDAP_RESULT=$(ldapsearch -x -h "$DEMO_HOST" -b "dc=demo1,dc=freeipa,dc=org" -s base 2>&1)
    if echo "$LDAP_RESULT" | grep -q "result:"; then
        echo -e "${GREEN}PASSED${NC} - LDAP server responds to queries"
    else
        echo -e "${RED}FAILED${NC} - LDAP server is not responding properly"
        echo "  Error: $LDAP_RESULT"
    fi
else
    echo -e "${YELLOW}SKIPPED${NC} - ldapsearch command not available"
    echo "  Install the ldap-utils package to enable this test"
fi

# Summary
echo -e "\nSummary:"
echo "========"
DNS_WORKING=0
SERVICES_WORKING=0

# Check if DNS is working
if host "ipa.demo1.freeipa.org" > /dev/null 2>&1; then
    DNS_WORKING=1
fi

# Check if at least one core service is responsive
if [[ $HTTP_STATUS -eq 200 || $HTTP_STATUS -eq 302 || $HTTP_STATUS -eq 301 ]]; then
    SERVICES_WORKING=1
fi

# Different messages based on what's working
if [[ $DNS_WORKING -eq 1 && $SERVICES_WORKING -eq 1 ]]; then
    echo -e "${GREEN}The FreeIPA demo server appears to be UP${NC}"
    echo "You can access the web interface at: https://ipa.demo1.freeipa.org/ipa/ui/"
elif [[ $DNS_WORKING -eq 0 && $SERVICES_WORKING -eq 1 ]]; then
    echo -e "${YELLOW}The FreeIPA demo server appears to be UP, but DNS resolution is failing${NC}"
    echo "You can access the web interface at: https://$IP_ADDRESS/ipa/ui/"
    echo "You may need to add an entry to your /etc/hosts file:"
    echo "  $IP_ADDRESS ipa.demo1.freeipa.org"
elif [[ $DNS_WORKING -eq 1 && $SERVICES_WORKING -eq 0 ]]; then
    echo -e "${RED}The FreeIPA demo server appears to be DOWN (DNS works but services don't respond)${NC}"
else
    echo -e "${RED}The FreeIPA demo server appears to be DOWN (both DNS and services are not responding)${NC}"
fi

# Always show login credentials and additional information
echo -e "\nLogin credentials (when server is available):"
echo "  - admin (administrator)"
echo "  - helpdesk (user with helpdesk role)" 
echo "  - employee (regular user)"
echo "  - manager (regular user, manager of employee)"
echo "Password for all users: Secret123"

echo -e "\nTroubleshooting tips:"
echo "  1. The server might be under maintenance"
echo "  2. Remember that the server is wiped clean every day at 05:00 UTC"
echo "  3. Contact the FreeIPA team for support"
echo "  4. Consider setting up your own local test instance using Docker"

# Return appropriate exit code
if [[ $SERVICES_WORKING -eq 1 ]]; then
    exit $SUCCESS
else
    exit $FAILURE
fi

exit $SUCCESS