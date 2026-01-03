#!/usr/bin/env python3
"""
Zidni Local Companion Server

Provides /health, /stt, and /llm endpoints for offline operation.
Run with: python server.py

SECURITY NOTES:
- CORS restricted to local origins only
- Input validation on all endpoints
- Rate limiting enabled
- Secure temporary file handling
- Error messages sanitized
"""

import os
import json
import tempfile
import logging
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

# MONITORING: Initialize Sentry for error tracking
sentry_sdk.init(
    dsn=os.environ.get('SENTRY_DSN', ''),
    integrations=[FlaskIntegration()],
    environment=os.environ.get('COMPANION_ENV', 'development'),
    release=f"zidni-companion@{os.environ.get('VERSION', '1.0.0')}",
    traces_sample_rate=0.2 if os.environ.get('COMPANION_ENV') == 'production' else 1.0,
    profiles_sample_rate=0.2 if os.environ.get('COMPANION_ENV') == 'production' else 1.0,
    before_send=lambda event, hint: event if os.environ.get('SENTRY_DSN') else None,
)

app = Flask(__name__)

# SECURITY FIX: Restrict CORS to local origins only
CORS(app, resources={
    r"/*": {
        "origins": [
            "https://192.168.4.1:8787",
            "https://localhost:*",
            "http://localhost:*",
        ],
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type"],
    }
})

# SECURITY FIX: Add rate limiting
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://",
)

# SECURITY FIX: Configure logging (no print statements in production)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configuration
HOST = os.environ.get('HOST', '0.0.0.0')
PORT = int(os.environ.get('PORT', 8787))
VERSION = '1.0.0'

# Lazy-loaded models
_whisper_model = None
_llm_model = None


def get_whisper_model():
    """Lazy load Whisper model for STT."""
    global _whisper_model
    if _whisper_model is None:
        try:
            import whisper
            logger.info("Loading Whisper model (small)...")
            _whisper_model = whisper.load_model("small")
            logger.info("Whisper model loaded successfully")
        except ImportError:
            logger.warning("Whisper not installed. STT will return placeholder.")
            _whisper_model = "placeholder"
    return _whisper_model


def preload_models():
    """
    Pre-load models at server startup to avoid cold start delays.

    PERFORMANCE OPTIMIZATION: Loading Whisper model takes 10-30 seconds,
    so we do it once at startup instead of on first request.
    """
    logger.info("Pre-loading models at startup...")

    # Pre-load Whisper model
    try:
        get_whisper_model()
        logger.info("✓ Whisper model pre-loaded successfully")
    except Exception as e:
        logger.error(f"✗ Failed to pre-load Whisper model: {e}")

    # TODO: Pre-load LLM model when implemented
    logger.info("Model pre-loading complete")


def get_llm_response(prompt: str, system_prompt: str = None, max_tokens: int = 1024) -> str:
    """
    Generate text using local LLM.
    
    For MVP, returns a template response.
    In production, integrate with llama.cpp, transformers, or similar.
    """
    # MVP: Return template-based response
    # In production: Use actual LLM inference
    
    if "arabic" in prompt.lower() or "عربي" in prompt:
        return """السلام عليكم،

شكراً جزيلاً على اللقاء الطيب في معرض كانتون. كان من دواعي سروري التعرف على منتجاتكم المميزة.

أود متابعة النقاط التي تحدثنا عنها، خاصة فيما يتعلق بالأسعار والكميات المتاحة.

هل يمكنكم إرسال قائمة الأسعار الكاملة؟

نتطلع للتعاون المثمر معكم.

مع أطيب التحيات"""

    elif "chinese" in prompt.lower() or "中文" in prompt:
        return """您好，

非常感谢您在广交会上的热情接待。很高兴了解到贵公司的优质产品。

我想跟进我们讨论的几个要点，特别是关于价格和可用数量的问题。

您能否发送完整的价格表？

期待与您的合作。

此致敬礼"""

    else:
        return f"Generated response for: {prompt[:100]}..."


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'version': VERSION,
        'endpoints': ['/health', '/stt', '/llm']
    })


@app.route('/stt', methods=['POST'])
@limiter.limit("10 per minute")
def speech_to_text():
    """
    Speech-to-text endpoint.

    Accepts audio file upload and returns transcript.

    SECURITY:
    - Rate limited to 10 requests per minute
    - File type validation
    - File size limit (50MB)
    - Secure temporary file handling
    """
    # SECURITY FIX: Validate file exists
    if 'audio' not in request.files:
        return jsonify({'error': 'No audio file provided'}), 400

    audio_file = request.files['audio']

    # SECURITY FIX: Validate filename exists
    if not audio_file.filename:
        return jsonify({'error': 'Invalid audio file'}), 400

    # SECURITY FIX: Validate file extension
    ALLOWED_EXTENSIONS = {'wav', 'mp3', 'ogg', 'flac', 'm4a', 'webm'}
    file_ext = audio_file.filename.rsplit('.', 1)[-1].lower() if '.' in audio_file.filename else ''
    if file_ext not in ALLOWED_EXTENSIONS:
        return jsonify({'error': f'Invalid file type. Allowed: {", ".join(ALLOWED_EXTENSIONS)}'}), 400

    # SECURITY FIX: Validate file size (50MB limit)
    audio_file.seek(0, os.SEEK_END)
    file_size = audio_file.tell()
    audio_file.seek(0)

    MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB
    if file_size > MAX_FILE_SIZE:
        return jsonify({'error': 'File too large (max 50MB)'}), 413

    if file_size == 0:
        return jsonify({'error': 'Empty audio file'}), 400

    # SECURITY FIX: Use context manager for temp file (auto-cleanup)
    tmp_path = None
    try:
        # Create secure temp file
        with tempfile.NamedTemporaryFile(suffix=f'.{file_ext}', delete=False, dir=tempfile.gettempdir()) as tmp:
            audio_file.save(tmp.name)
            tmp_path = tmp.name

        model = get_whisper_model()

        if model == "placeholder":
            transcript = "[Whisper not installed - install with: pip install openai-whisper]"
        else:
            # Transcribe with Whisper
            result = model.transcribe(tmp_path)
            transcript = result.get('text', '').strip()

        return jsonify({'transcript': transcript})

    except Exception as e:
        # SECURITY FIX: Don't expose internal errors to client
        logger.error(f"STT processing failed: {str(e)}", exc_info=True)
        return jsonify({'error': 'Speech transcription failed', 'transcript': ''}), 500

    finally:
        # SECURITY FIX: Ensure temp file cleanup
        if tmp_path and os.path.exists(tmp_path):
            try:
                os.unlink(tmp_path)
                logger.debug(f"Cleaned up temp file: {tmp_path}")
            except Exception as e:
                logger.error(f"Failed to delete temp file {tmp_path}: {e}")


@app.route('/llm', methods=['POST'])
@limiter.limit("20 per minute")
def generate_text():
    """
    LLM text generation endpoint.

    Accepts prompt and returns generated text.

    SECURITY: Rate limited, input validated
    """
    try:
        data = request.get_json()

        if not data or 'prompt' not in data:
            return jsonify({'error': 'No prompt provided'}), 400

        prompt = str(data['prompt']).strip()
        if not prompt or len(prompt) > 5000:
            return jsonify({'error': 'Invalid prompt length'}), 400

        system_prompt = data.get('system_prompt')
        if system_prompt and len(str(system_prompt)) > 2000:
            return jsonify({'error': 'System prompt too long'}), 400

        max_tokens = int(data.get('max_tokens', 1024))
        if not (1 <= max_tokens <= 2048):
            return jsonify({'error': 'max_tokens must be between 1-2048'}), 400

        text = get_llm_response(prompt, system_prompt, max_tokens)

        return jsonify({
            'text': text,
            'tokens_used': len(text.split())
        })

    except ValueError:
        return jsonify({'error': 'Invalid request format'}), 400
    except Exception as e:
        logger.error(f"LLM error: {str(e)}", exc_info=True)
        return jsonify({'error': 'Text generation failed'}), 500


@app.route('/', methods=['GET'])
def index():
    """Root endpoint with API info."""
    return jsonify({
        'name': 'Zidni Local Companion',
        'version': VERSION,
        'endpoints': {
            'GET /health': 'Health check',
            'POST /stt': 'Speech-to-text (upload audio file)',
            'POST /llm': 'Text generation (JSON body with prompt)'
        }
    })


if __name__ == '__main__':
    print(f"""
╔═══════════════════════════════════════════════════════════╗
║           Zidni Local Companion Server v{VERSION}            ║
╠═══════════════════════════════════════════════════════════╣
║  Endpoints:                                               ║
║    GET  /health  - Health check                           ║
║    POST /stt     - Speech-to-text                         ║
║    POST /llm     - Text generation                        ║
╠═══════════════════════════════════════════════════════════╣
║  Running on: http://{HOST}:{PORT}                           ║
╚═══════════════════════════════════════════════════════════╝
""")

    # PERFORMANCE OPTIMIZATION: Pre-load models to eliminate cold start
    preload_models()

    app.run(host=HOST, port=PORT, debug=False)
