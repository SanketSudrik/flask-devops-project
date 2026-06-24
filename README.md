# Flask DevOps Project

A production-ready Python Flask web application demonstrating a complete DevOps lifecycle — containerized with Docker, automated via GitHub Actions CI/CD, and deployed on AWS EC2 with Nginx as a reverse proxy and CloudWatch monitoring.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Application | Python 3.11, Flask 3.0, Gunicorn |
| Containerization | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Registry | Docker Hub (versioned tags) |
| Cloud | AWS EC2 (Ubuntu 22.04) |
| Reverse Proxy | Nginx |
| Monitoring | AWS CloudWatch + SNS Alerts |
| Security | IAM Roles, EC2 Security Groups |

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
├── scripts/
│   ├── ec2-setup.sh              # One-time EC2 provisioning script
│   └── cloudwatch-setup.sh       # CloudWatch agent + alarms setup
├── .github/
│   └── workflows/
│       └── ci-cd.yml             # GitHub Actions CI/CD pipeline
├── Dockerfile                    # Multi-stage Docker build
├── docker-compose.yml            # Local + production orchestration
├── requirements.txt
├── .env.example
└── .gitignore
```

---

## API Endpoints

| Route | Method | Description |
|---|---|---|
| `/` | GET | App status + version info |
| `/health` | GET | Health check (used by Docker + Nginx) |
| `/info` | GET | Environment + version metadata |

---

## Local Development

### Prerequisites
- Docker & Docker Compose installed
- Python 3.11+ (for running tests locally)

### Run with Docker Compose

```bash
git clone https://github.com/YOUR_USERNAME/flask-devops-project.git
cd flask-devops-project

docker-compose up --build
```

App: http://localhost  
Direct (no Nginx): http://localhost:5000

### Run Tests Locally

```bash
pip install -r requirements.txt
pytest tests/ -v
```

---

## CI/CD Pipeline (GitHub Actions)

The workflow in `.github/workflows/ci-cd.yml` runs on every push to `main`:

```
Push to main
    │
    ▼
[Job 1] Run Tests (pytest)
    │
    ▼
[Job 2] Build Docker Image → Push to Docker Hub
        Tags: latest, v<run_number>, sha-<commit>
    │
    ▼
[Job 3] SSH into EC2 → Pull image → docker-compose up
```

### Required GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description |
|---|---|
| `DOCKER_HUB_USERNAME` | Your Docker Hub username |
| `DOCKER_HUB_TOKEN` | Docker Hub access token (not your password) |
| `EC2_HOST` | Public IP or DNS of your EC2 instance |
| `EC2_SSH_KEY` | Contents of your EC2 `.pem` private key |

---

## AWS EC2 Deployment

### Step 1 — Launch EC2 Instance

- AMI: Ubuntu 22.04 LTS
- Instance type: t2.micro (free tier) or t3.small
- Storage: 20 GB gp3

### Step 2 — Configure Security Group

| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | Your IP only |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| Custom (Flask) | TCP | 5000 | 0.0.0.0/0 |

### Step 3 — Attach IAM Role

Create an IAM role with these policies and attach to EC2:
- `CloudWatchAgentServerPolicy`
- `AmazonSSMManagedInstanceCore` (optional, for SSM access)

### Step 4 — Run Setup Script

SSH into EC2 and run:

```bash
chmod +x scripts/ec2-setup.sh
./scripts/ec2-setup.sh
```

This installs Docker, Docker Compose, clones the repo, and starts the app.

---

## CloudWatch Monitoring

Set up monitoring with the provided script:

```bash
# Edit the SNS_EMAIL variable in the script first
chmod +x scripts/cloudwatch-setup.sh
./scripts/cloudwatch-setup.sh
```

### Alerts Configured

| Alarm | Threshold | Period |
|---|---|---|
| CPU High | > 80% | 5 min (2 eval periods) |
| Memory High | > 85% | 5 min (2 eval periods) |
| Disk Full | > 80% | 5 min (1 eval period) |

Alerts are sent via **SNS → Email**.

---

## Docker Hub Tags

Images are pushed with three tags on every successful CI run:

```
yourusername/flask-devops-app:latest
yourusername/flask-devops-app:v42          ← GitHub run number
yourusername/flask-devops-app:sha-a1b2c3   ← Git commit SHA
```

Pull a specific version:
```bash
docker pull yourusername/flask-devops-app:v42
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

**Your Name**  
[GitHub](https://github.com/YOUR_USERNAME) · [LinkedIn](https://linkedin.com/in/YOUR_PROFILE)
