#!/bin/bash

# Check AWS VPN Client by looking for openvpn process with profile name
AWS_PROCESS=$(pgrep -f "acvc-openvpn.*CVPN_CONN_PROFILE_NAME" 2>/dev/null | head -1)
if [[ -n "$AWS_PROCESS" ]]; then
  # Extract profile name from the openvpn process command line and trim whitespace
  PROFILE=$(/bin/ps -p "$AWS_PROCESS" -o command= 2>/dev/null | grep -o "CVPN_CONN_PROFILE_NAME [^-]*" | cut -d' ' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  if [[ -n "$PROFILE" ]]; then
    echo "$PROFILE"
  else
    echo "AWS"
  fi
# Check ProtonVPN (creates utun interface)
elif pgrep -q "ProtonVPN"; then
  echo "Proton"
fi