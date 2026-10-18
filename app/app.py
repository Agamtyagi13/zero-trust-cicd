from flask import Flask, jsonify
import os
app = Flask(__name__)

@app.get("/")
def index():
    return jsonify(service="secure-app", version=os.getenv("APP_VERSION", "dev"))

@app.get("/healthz")
def health():
    return "ok", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
