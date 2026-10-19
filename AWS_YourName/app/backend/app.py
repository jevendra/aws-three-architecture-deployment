import os
import re
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": os.environ.get("FRONTEND_ORIGIN", "*")}})

def validate(data):
    if not isinstance(data, dict):
        return "Expected a JSON object."
    name = str(data.get("name", "")).strip()
    email = str(data.get("email", "")).strip()
    message = str(data.get("message", "")).strip()
    if not name or not email or not message:
        return "Name, email, and message are required."
    if len(name) > 100 or len(email) > 254 or len(message) > 2000:
        return "One or more fields are too long."
    if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", email):
        return "Please enter a valid email address."
    return None

@app.get("/health")
def health():
    return jsonify({"status": "ok", "service": "flask-backend"})

@app.get("/api")
def api():
    return jsonify({"message": "Flask backend is running", "deployment": os.environ.get("DEPLOYMENT_MODE", "local")})

@app.post("/api/submit")
def submit():
    data = request.get_json(silent=True)
    error = validate(data)
    if error:
        return jsonify({"ok": False, "error": error}), 400
    # Demo processes request without persisting personal information.
    print(f"Accepted form submission (name_length={len(data['name'].strip())})")
    return jsonify({"ok": True, "message": "Data submitted successfully"}), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "5000")))
