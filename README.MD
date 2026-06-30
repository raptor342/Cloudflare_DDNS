# 🌐 Cloudflare Multi-Record DDNS (Alpine + Bash + Curl)

This is an **ultra-lightweight Docker-based DDNS agent** that automatically updates multiple Cloudflare DNS records whenever your public IP changes.

---

# ⚙️ Features

- ✔ Manages multiple DNS records in a single container  
- ✔ Updates only when the IP actually changes  
- ✔ Compares against current Cloudflare DNS values (no unnecessary updates)  
- ✔ Runs on a configurable interval (default: 5 minutes)  
- ✔ Logs directly to Docker stdout  
- ✔ Minimal stack: Alpine + bash + curl  

---

# 📦 Environment

## Docker image
- Alpine Linux  
- curl  
- bash  

---

# 📌 Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| CF_API_TOKEN | ✔ | Cloudflare API token |
| ZONE_ID | ✔ | DNS zone ID |
| RECORDS | ✔ | List of DNS records |
| INTERVAL | ❌ | Loop interval in seconds (default: 300) |
| TTL | ❌ | DNS TTL (default: 120) |
| PROXIED | ❌ | Cloudflare proxy status (default: true) |

---

# 🧾 RECORDS format

```bash
RECORDS="home.example.com,jellyfin.example.com,vpn.example.com"
```
```bash
docker run -d \
  --name cf-ddns \
  -e CF_API_TOKEN="your_api_token" \
  -e ZONE_ID="your_zone_id" \
  -e RECORDS="example.test.com,example2.test.com" \
  -e INTERVAL=300 \
  cf-ddns
```