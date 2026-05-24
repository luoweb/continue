"""
Simple test script for Dev Data Service API
"""
import requests
import json
from datetime import datetime

BASE_URL = "http://localhost:8001"


def test_health():
    """Test health endpoint"""
    print("Testing health endpoint...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    return response.status_code == 200


def test_submit_data():
    """Test submitting dev data"""
    print("\nTesting data submission...")
    
    test_data = {
        "name": "chatInteraction",
        "data": {
            "prompt": "Hello, world!",
            "completion": "Hi there! How can I help you today?",
            "modelProvider": "openai",
            "modelName": "gpt-4",
            "modelTitle": "GPT-4",
            "sessionId": "test-session-123",
            "tools": [],
            "rules": [
                {"id": "rule-1", "slug": "test-rule"}
            ]
        },
        "schema": "0.2.0",
        "level": "all",
        "profileId": "test-profile"
    }
    
    response = requests.post(
        f"{BASE_URL}/api/v1/data",
        json=test_data,
        headers={"Content-Type": "application/json"}
    )
    
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    return response.status_code == 200


def test_submit_tokens():
    """Test submitting tokensGenerated event"""
    print("\nTesting tokensGenerated submission...")
    
    test_data = {
        "name": "tokensGenerated",
        "data": {
            "generatedTokens": 150,
            "model": "gpt-4",
            "promptTokens": 50,
            "provider": "openai"
        },
        "schema": "0.2.0",
        "level": "all"
    }
    
    response = requests.post(
        f"{BASE_URL}/api/v1/data",
        json=test_data,
        headers={"Content-Type": "application/json"}
    )
    
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    return response.status_code == 200


def test_get_stats():
    """Test getting statistics"""
    print("\nTesting stats endpoint...")
    response = requests.get(f"{BASE_URL}/api/v1/stats")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    return response.status_code == 200


def test_query_data():
    """Test querying data"""
    print("\nTesting query endpoint...")
    response = requests.get(f"{BASE_URL}/api/v1/data?limit=10")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    return response.status_code == 200


def test_get_events():
    """Test getting event types"""
    print("\nTesting events endpoint...")
    response = requests.get(f"{BASE_URL}/api/v1/events")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    return response.status_code == 200


def main():
    """Run all tests"""
    print("=" * 50)
    print("Continue Dev Data Service - API Test")
    print("=" * 50)
    
    tests = [
        ("Health Check", test_health),
        ("Submit Chat Data", test_submit_data),
        ("Submit Token Data", test_submit_tokens),
        ("Get Statistics", test_get_stats),
        ("Query Data", test_query_data),
        ("Get Event Types", test_get_events)
    ]
    
    results = []
    for name, test_func in tests:
        try:
            success = test_func()
            results.append((name, success))
        except Exception as e:
            print(f"Error: {e}")
            results.append((name, False))
    
    print("\n" + "=" * 50)
    print("Test Summary")
    print("=" * 50)
    for name, success in results:
        status = "✓ PASSED" if success else "✗ FAILED"
        print(f"{name}: {status}")
    
    passed = sum(1 for _, s in results if s)
    total = len(results)
    print(f"\nTotal: {passed}/{total} tests passed")


if __name__ == "__main__":
    main()
