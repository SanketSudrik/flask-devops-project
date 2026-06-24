from flask import Flask, jsonify
import os
import platform

app = Flask(__name__)


@app.route("/")
def home():
    return jsonify({
        "message": "Flask DevOps App is running!",
        "status": "healthy",
        "version": os.environ.get("APP_VERSION", "1.0.0")
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "hostname": platform.node(),
        "python_version": platform.python_version()
    }), 200


@app.route("/info")
def info():
    return jsonify({
        "app": "Flask DevOps Demo",
        "environment": os.environ.get("FLASK_ENV", "production"),
        "version": os.environ.get("APP_VERSION", "1.0.0")
    })


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
