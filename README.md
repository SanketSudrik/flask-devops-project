# Flask DevOps Project

A production-ready Python Flask web application demonstrating a complete DevOps lifecycle — containerized with Docker, automated via GitHub Actions CI/CD, and deployed on Render.com with Nginx reverse proxy configuration.

---

## Live Demo

🌐 **[https://flask-devops-app.onrender.com](https://flask-devops-app.onrender.com)**

| Endpoint | Description |
|---|---|
| `/` | App status + version info |
| `/health` | Health check |
| `/info` | Environment + version metadata |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Application | Python 3.11, Flask 3.0, Gunicorn |
| Containerization | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Registry | Docker Hub (versioned tags) |
| Deployment | Render.com |
| Reverse Proxy | Nginx |

---

## Project Structure

```
flask-devops-project/
├── app/
│   └── app.py                    # Flask application
├── tests/
│   └── test_app.py               # Pytest unit tests
├── nginx/
│   └── nginx.conf                # Nginx reverse proxy config
├── .github/
│   └── workflows/
│       └── ci-cd.yml             # GitHub Actions CI/CD pipeline
├── Dockerfile                    # Multi-stage Docker build
├── docker-compose.yml            # Local development orchestration
├── requirements.txt
├── .env.example
└── .gitignore
```

---

## CI/CD Pipeline (GitHub Actions)

The workflow in `.github/workflows/ci-cd.yml` runs automatically on every push to `main`:

```
Push to main
    │
    ▼
[Job 1] Run Tests (pytest)
    │
    ▼
[Job 2] Build Docker Image → Push to Docker Hub
        Tags: latest, v<run_number>
    │
    ▼
[Job 3] Trigger Auto Deploy → Render.com
```

### Required GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description |
|---|---|
| `DOCKER_HUB_TOKEN` | Docker Hub access token |
| `RENDER_API_KEY` | Render account API key |
| `RENDER_SERVICE_ID` | Render service ID (starts with `srv-`) |

---

## Local Development

### Prerequisites
- Docker & Docker Compose installed
- Python 3.11+ (for running tests locally)

### Run with Docker Compose

```bash
git clone https://github.com/SanketSudrik/flask-devops-project.git
cd flask-devops-project

docker-compose up --build
```

App via Nginx: `http://localhost`
App direct: `http://localhost:5000`

### Run Tests Locally

```bash
pip install -r requirements.txt
pytest tests/ -v
```

---

## Deployment — Render.com

This project is deployed on **Render.com** using Docker runtime.

### Manual Setup Steps

**Step 1 — Create account**
- Go to [render.com](https://render.com) and sign up with GitHub

**Step 2 — Create Web Service**
- Click **New +** → **Web Service**
- Connect your GitHub repository
- Select **Docker** as runtime
- Region: Singapore
- Instance type: Free

**Step 3 — Add Environment Variables**

| Key | Value |
|---|---|
| `FLASK_ENV` | `production` |
| `APP_VERSION` | `1.0.0` |
| `PORT` | `5000` |

**Step 4 — Deploy**
- Click **Create Web Service**
- Render builds and deploys automatically
- Live URL provided after deploy

### Auto Deploy via GitHub Actions

Every push to `main` triggers:
1. Tests run on GitHub Actions
2. Docker image built and pushed to Docker Hub
3. Render API called to redeploy latest image

---

## Docker Hub

Images are pushed with versioned tags on every CI run:

```
sanketsudrik/flask-devops-app:latest
sanketsudrik/flask-devops-app:v1
sanketsudrik/flask-devops-app:v2
```

Pull and run locally:
```bash
docker pull sanketsudrik/flask-devops-app:latest
docker run -p 5000:5000 sanketsudrik/flask-devops-app:latest
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `FLASK_ENV` | `production` | Flask environment |
| `APP_VERSION` | `1.0.0` | Displayed in API responses |
| `PORT` | `5000` | Port Flask listens on |

Copy `.env.example` to `.env` for local overrides (never commit `.env`).

---

## Author

Sanket Sudrik
[GitHub](https://github.com/SanketSudrik) · 
