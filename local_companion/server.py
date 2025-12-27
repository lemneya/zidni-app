#!/usr/bin/env python3
"""
Zidni Local Companion Server

Provides /health, /stt, and /llm endpoints for offline operation.
Run with: python server.py
"""

import os
import json
import tempfile
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

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
            print("Loading Whisper model (small)...")
            _whisper_model = whisper.load_model("small")
            print("Whisper model loaded.")
        except ImportError:
            print("Warning: Whisper not installed. STT will return placeholder.")
            _whisper_model = "placeholder"
    return _whisper_model


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
def speech_to_text():
    """
    Speech-to-text endpoint.
    
    Accepts audio file upload and returns transcript.
    """
    if 'audio' not in request.files:
        return jsonify({'error': 'No audio file provided'}), 400
    
    audio_file = request.files['audio']
    
    # Save to temp file
    with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp:
        audio_file.save(tmp.name)
        tmp_path = tmp.name
    
    try:
        model = get_whisper_model()
        
        if model == "placeholder":
            # Whisper not installed, return placeholder
            transcript = "[Whisper not installed - install with: pip install openai-whisper]"
        else:
            # Transcribe with Whisper
            result = model.transcribe(tmp_path)
            transcript = result.get('text', '').strip()
        
        return jsonify({'transcript': transcript})
    
    except Exception as e:
        return jsonify({'error': str(e), 'transcript': ''}), 500
    
    finally:
        # Cleanup temp file
        try:
            os.unlink(tmp_path)
        except:
            pass


@app.route('/llm', methods=['POST'])
def generate_text():
    """
    LLM text generation endpoint.
    
    Accepts prompt and returns generated text.
    """
    try:
        data = request.get_json()
        
        if not data or 'prompt' not in data:
            return jsonify({'error': 'No prompt provided'}), 400
        
        prompt = data['prompt']
        system_prompt = data.get('system_prompt')
        max_tokens = data.get('max_tokens', 1024)
        
        # Generate response
        text = get_llm_response(prompt, system_prompt, max_tokens)
        
        return jsonify({
            'text': text,
            'tokens_used': len(text.split())  # Approximate
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


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
    app.run(host=HOST, port=PORT, debug=False)
