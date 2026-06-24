import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../app"))

from app import app as flask_app


@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as client:
        yield client


def test_home_returns_200(client):
    response = client.get("/")
    assert response.status_code == 200


def test_home_returns_json(client):
    response = client.get("/")
    data = response.get_json()
    assert data is not None
    assert "message" in data
    assert "status" in data


def test_health_endpoint(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"


def test_info_endpoint(client):
    response = client.get("/info")
    assert response.status_code == 200
    data = response.get_json()
    assert "app" in data
    assert "version" in data


def test_invalid_route_returns_404(client):
    response = client.get("/nonexistent-route")
    assert response.status_code == 404
