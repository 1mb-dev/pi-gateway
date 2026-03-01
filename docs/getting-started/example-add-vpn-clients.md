---
title: Add VPN Clients
nav_order: 2
parent: Example Guides
grand_parent: Getting Started
layout: default
---

# Add VPN Clients

Configure VPN access for your devices (laptops, phones, tablets).

## Using the VPN Client Manager

```bash
# Start the interactive manager
./scripts/vpn-client-manager.sh
```

Follow the prompts:
1. Select "Add new client"
2. Enter client name (e.g., "laptop", "iphone", "work-computer")
3. System generates keys and creates configuration

## Supported Devices

### macOS / iOS

**On your Pi:**
```bash
./scripts/vpn-client-manager.sh
# Select: 1) Add new client
# Name: my-iphone
# The script generates a QR code
```

**On your iPhone:**
1. Install WireGuard app from App Store
2. Open WireGuard app
3. Tap "+" → "Create from QR Code"
4. Scan the QR code from your Pi's terminal
5. Name the configuration and activate

**On your Mac:**
1. Install WireGuard from `brew install wireguard-tools`
2. Export the config: `cat ~/.wireguard/clients/my-mac.conf`
3. Save to file and import into WireGuard app

### Windows

```bash
# On your Pi, export the config
cat ~/.wireguard/clients/my-windows-pc.conf > config.conf

# Copy config.conf to your Windows machine

# On Windows:
# 1. Download WireGuard from wireguard.com/install
# 2. Install and launch
# 3. Click "Import tunnel(s) from file"
# 4. Select config.conf
# 5. Connect
```

### Linux

```bash
# Export client config
cat ~/.wireguard/clients/my-linux.conf

# Create /etc/wireguard/my-tunnel.conf with the content above

# Bring up the connection
sudo wg-quick up my-tunnel

# Check connection
sudo wg show

# View assigned IP (should be 10.0.0.x)
ip addr show wg-quick
```

### Android

Similar to iOS:
1. Install WireGuard from Play Store
2. Open app and tap "+"
3. Scan QR code from your Pi
4. Connect

## Managing Clients

```bash
# List all clients
ls -la ~/.wireguard/clients/

# Remove a client (revoke access)
sudo wg set wg0 peer <client-public-key> remove

# Then restart WireGuard
sudo systemctl restart wg-quick@wg0

# View active connections
sudo wg show wg0 peers
```

## Testing Your Connection

```bash
# After connecting your client:

# 1. Check your VPN IP
curl -s https://checkip.amazonaws.com

# Should return 10.0.0.x (your Pi's internal network)

# 2. Ping other devices on home network
ping 192.168.1.X  # Another device on your home network

# 3. SSH through the VPN
ssh -i ~/.ssh/pi-gateway-key user@10.0.0.1
```

## Troubleshooting

**Client can't connect?**
```bash
# Check if WireGuard is running on Pi
sudo systemctl status wg-quick@wg0

# Check firewall allows port 51820
sudo ufw status | grep 51820
# Should show: 51820/udp ALLOW

# Restart WireGuard
sudo systemctl restart wg-quick@wg0
```

**Connected but can't reach home network?**
```bash
# Verify routing on Pi
sudo ip route show
# Should include: 10.0.0.0/24 via ... dev wg0

# Check firewall isn't blocking internal network
sudo ufw status
```

**Phone keeps disconnecting?**
- Check router isn't rate-limiting UDP
- Verify firewall rule for port 51820 is active
- Restart WireGuard app on phone

## Next Steps

- [Configure SSH Access]({{ site.baseurl }}/getting-started/example-configure-ssh/)
- [Set Up Dynamic DNS]({{ site.baseurl }}/getting-started/example-setup-dynamic-dns/)
- [Daily Operations Guide]({{ site.baseurl }}/operations/daily-operations/)
