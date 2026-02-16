#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, unquote
import subprocess
import os

class NotificationHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Read POST data
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        
        # Parse the form data
        params = parse_qs(post_data)
        message = params.get('text', ['Notification from VM'])[0]
        message = unquote(message)
        
        print(f"[{self.log_date_time_string()}] Received: {message}")
        
        try:
            # Run ntg with the message
            result = subprocess.run(
                ['ntg', message],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                print(f"✓ Notification sent successfully")
            else:
                print(f"✗ ntg failed: {result.stderr}")
            
            # Send success response (mimic Telegram API)
            response = b'{"ok":true,"result":{"message_id":1}}'
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', len(response))
            self.end_headers()
            self.wfile.write(response)
            
        except Exception as e:
            print(f"Error running ntg: {e}")
            self.send_response(500)
            self.end_headers()
    
    def log_message(self, format, *args):
        # Suppress default logging, we handle it ourselves
        pass

def run_server(port=8888):
    server_address = ('localhost', port)
    httpd = HTTPServer(server_address, NotificationHandler)
    print(f"Notification server started on http://localhost:{port}")
    print("Waiting for notifications from VM...")
    print("Press Ctrl+C to stop\n")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server...")
        httpd.shutdown()

if __name__ == '__main__':
    run_server()
