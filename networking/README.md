# Raspberry Pi Home VPN + DNS Setup with Tailscale and Pi-hole

This guide sets up a Raspberry Pi as a secure home VPN gateway and DNS server using **Tailscale** and **Pi-hole**.

It enables:

- Secure remote access to your home network
- DNS-based access to local devices using friendly names (e.g. `nas.local`, `media.local`)
- Optional routing of all traffic through your Pi (exit node)
- Network-wide ad blocking with Pi-hole
- A fully local solution — no need for port forwarding, public IPs, or HTTPS certificates

## Prerequisites

- A Raspberry Pi running Raspberry Pi OS (or another Debian-based distro)
- A static IP on your home LAN (e.g. `192.168.1.100`)
- A free [Tailscale account](https://tailscale.com)


## 1. Copy the Setup Script

Save the provided `pihole-tailscale-setup.sh` file to your Pi and make it executable:

```bash
chmod +x pihole-tailscale-setup.sh
```

## 2. Run the Script

```bash
./pihole-tailscale-setup.sh
```

This will:
- Install and configure Pi-hole
- Install and set up Tailscale with subnet routing and exit node support
- Apply required firewall and routing rules
- Prompt you to persist iptables rules across reboots


## 3. Complete Setup via Tailscale Admin Panel

1. Visit [https://tailscale.com/admin/machines](https://tailscale.com/admin/machines)
2. Enable the advertised subnet route (e.g. `192.168.1.0/24`)
3. (Optional) Mark the Pi as an exit node
4. (Recommended) Set your Pi-hole's IP as a global DNS nameserver


## 4. Configure Pi-hole DNS

1. Access the Pi-hole web UI at:

   ```
   http://<pi-ip>/admin
   ```

2. Under *Local DNS > DNS Records*, create hostnames for local devices:

   ```
   media.local → 192.168.1.50
   nas.local   → 192.168.1.10
   ```

3. (Optional) Point your home router’s DNS to the Pi-hole IP


## 5. Connect Remotely

- Install the [Tailscale app](https://tailscale.com/download) on your phone or laptop
- Sign in using the same account
- Connect to your tailnet
- Access devices using hostnames you defined (e.g. `http://media.local`)

If you've enabled the exit node, all your internet and DNS traffic will securely route through your Pi.


## Notes

- Pi-hole serves its UI using `lighttpd` on port 80
- Tailscale provides encrypted access without requiring port forwarding
- No Caddy, Nginx, or external proxying is required
- You can add more `.local` hostnames as needed for other services or devices


## Troubleshooting

- **Can't access LAN devices over Tailscale?**
  - Confirm the subnet route is enabled in Tailscale admin
  - Ensure `iptables` rules and IP forwarding are active on the Pi

- **DNS not resolving?**
  - Make sure the Pi-hole IP is set as the global DNS server in Tailscale
  - Check Pi-hole logs or tailnet settings

- **Pi-hole UI not loading?**
  - Restart the web service:

    ```bash
    sudo systemctl restart lighttpd
    ```
