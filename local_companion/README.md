# Zidni Local Companion Server

A lightweight local server that provides STT (Speech-to-Text) and LLM (Language Model) capabilities for Zidni when operating in offline mode at Canton Fair.

## Purpose

When Wi-Fi is unreliable at the fair, the Local Companion runs on a laptop or Raspberry Pi on the same network, providing:

- **`/health`** - Health check endpoint
- **`/stt`** - Speech-to-text transcription
- **`/llm`** - Text generation for follow-up templates

## Quick Start

### Option 1: Python Server (Recommended)

```bash
# Install dependencies
pip install -r requirements.txt

# Run server
python server.py
```

### Option 2: Shell Script

```bash
# Make executable
chmod +x run.sh

# Run
./run.sh
```

## Configuration

Default settings:
- **Host**: `0.0.0.0` (all interfaces)
- **Port**: `8787`
- **Default URL**: `http://192.168.4.1:8787`

To change port:
```bash
PORT=9000 python server.py
```

## API Endpoints

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

### POST /stt

Transcribe audio to text.

**Request:**
- Content-Type: `multipart/form-data`
- Body: `audio` file (WAV format)

**Response:**
```json
{
  "transcript": "transcribed text here"
}
```

### POST /llm

Generate text using local LLM.

**Request:**
```json
{
  "prompt": "Your prompt here",
  "system_prompt": "Optional system prompt",
  "max_tokens": 1024
}
```

**Response:**
```json
{
  "text": "Generated text here",
  "tokens_used": 150
}
```

## Hardware Requirements

Minimum:
- Raspberry Pi 4 (4GB RAM) or equivalent
- Python 3.9+

Recommended:
- Laptop with GPU for faster LLM inference
- 8GB+ RAM

## Network Setup

1. Create a mobile hotspot on your phone or use a portable router
2. Connect both your phone (running Zidni) and the companion device
3. Find the companion's IP address: `hostname -I`
4. Enter the IP in Zidni's Offline Settings

## Troubleshooting

### Connection Failed
- Verify both devices are on the same network
- Check firewall settings: `sudo ufw allow 8787`
- Verify IP address is correct

### STT Not Working
- Ensure Whisper model is downloaded
- Check audio format is WAV

### LLM Slow
- Use a smaller model (e.g., `phi-2` instead of `llama`)
- Consider using CPU-optimized builds

## Models

The server uses:
- **STT**: OpenAI Whisper (small model by default)
- **LLM**: Configurable (default: phi-2 or similar small model)

To change models, edit `config.py`.

## License

Part of the Zidni project. Internal use only.
