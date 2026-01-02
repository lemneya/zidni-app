# HTTPS/TLS Setup Required

## CRITICAL: Companion server MUST use HTTPS in production

### Quick Setup with Self-Signed Certificate

```bash
openssl req -x509 -newkey rsa:4096 -nodes -out cert.pem -keyout key.pem -days 365
gunicorn --certfile=cert.pem --keyfile=key.pem --bind 0.0.0.0:8787 server:app
```

### Production with Nginx (Recommended)

Install certificate, configure Nginx as reverse proxy with TLS enabled.
Run Flask backend on localhost:8788, Nginx handles HTTPS on port 8787.
