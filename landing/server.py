#!/usr/bin/env python3
"""
EloFit Landing & Admin Local Server
Zero dependencies - uses standard library Python 3.
Serves static files and provides a JSON backend for user registrations with exact timestamps.
"""

import http.server
import socketserver
import json
import os
import sys
from datetime import datetime
from urllib.parse import urlparse

# Ensure UTF-8 output on Windows consoles
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')

PORT = 3000
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_FILE = os.path.join(BASE_DIR, 'registrations.json')

# Ensure registrations.json exists
if not os.path.exists(DATA_FILE):
    with open(DATA_FILE, 'w', encoding='utf-8') as f:
        json.dump([], f, ensure_ascii=False, indent=2)

def load_registrations():
    try:
        with open(DATA_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"[Error] Failed to read {DATA_FILE}: {e}")
        return []

def save_registrations(data):
    try:
        with open(DATA_FILE, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"[Error] Failed to write {DATA_FILE}: {e}")
        return False

class EloFitHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == '/api/registrations':
            data = load_registrations()
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(data, ensure_ascii=False).encode('utf-8'))
            return
        
        # Route '/' to 'index.html'
        if parsed.path == '/':
            self.path = '/index.html'
        return super().do_GET()

    def do_POST(self):
        parsed = urlparse(self.path)
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)

        try:
            payload = json.loads(body.decode('utf-8'))
        except Exception:
            payload = {}

        if parsed.path == '/api/register':
            now = datetime.now()
            # Ensure exact timestamp is stamped server-side as well
            if not payload.get('timeFormatted'):
                payload['timeFormatted'] = now.strftime('%d.%m.%Y в %H:%M:%S')
            if not payload.get('dateOnly'):
                payload['dateOnly'] = now.strftime('%d.%m.%Y')
            if not payload.get('timeOnly'):
                payload['timeOnly'] = now.strftime('%H:%M:%S')
            if not payload.get('timestamp'):
                payload['timestamp'] = now.isoformat()
            if not payload.get('id'):
                payload['id'] = f"reg_{int(now.timestamp())}"

            registrations = load_registrations()
            registrations.insert(0, payload)
            save_registrations(registrations)

            print(f"[NEW REGISTRATION] {payload.get('name')} | {payload.get('email')} | {payload.get('contact')} | {payload.get('timeFormatted')}")

            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({"success": True, "record": payload}, ensure_ascii=False).encode('utf-8'))
            return

        elif parsed.path == '/api/sync':
            if isinstance(payload, list):
                save_registrations(payload)
                self.send_response(200)
                self.send_header('Content-Type', 'application/json; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "count": len(payload)}).encode('utf-8'))
                return

        self.send_response(404)
        self.end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else PORT
    with socketserver.TCPServer(("", port), EloFitHandler) as httpd:
        print("=" * 60)
        print(f"🔥 EloFit Landing & Admin Server запущен!")
        print(f"👉 Главная страница (для людей):    http://localhost:{port}/")
        print(f"🔐 Панель администратора (база):  http://localhost:{port}/admin.html")
        print(f"💾 База данных сохраняется в:      {DATA_FILE}")
        print("=" * 60)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nСервер остановлен.")
