#!/bin/bash
# Seeds the workspace this case runs in. Runs only under --scaffold.
set -e
cat > http_client.py <<'CLIENT_EOF'
"""Thin HTTP client wrapper used across the service."""
import urllib.request


DEFAULT_TIMEOUT = 5.0


class HttpError(Exception):
    def __init__(self, status, body):
        super().__init__(f"HTTP {status}")
        self.status = status
        self.body = body


class HttpClient:
    """One request, one attempt. No retry anywhere in this class today."""

    def __init__(self, base_url, timeout=DEFAULT_TIMEOUT):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout

    def get(self, path, headers=None):
        return self._request("GET", path, None, headers)

    def post(self, path, body=None, headers=None):
        return self._request("POST", path, body, headers)

    def _request(self, method, path, body, headers):
        req = urllib.request.Request(
            f"{self.base_url}/{path.lstrip('/')}",
            data=body,
            headers=headers or {},
            method=method,
        )
        with urllib.request.urlopen(req, timeout=self.timeout) as resp:
            if resp.status >= 400:
                raise HttpError(resp.status, resp.read())
            return resp.read()
CLIENT_EOF
cat > callers.py <<'CALLERS_EOF'
"""Call sites that feel the flakiness today."""
from http_client import HttpClient

BILLING = HttpClient("https://billing.internal")
SEARCH = HttpClient("https://search.internal")


def fetch_invoice(invoice_id):
    return BILLING.get(f"/invoices/{invoice_id}")


def submit_payment(payload):
    # Not idempotent: the upstream creates a charge per call.
    return BILLING.post("/payments", payload)


def search(query):
    return SEARCH.get(f"/search?q={query}")
CALLERS_EOF
cat > test_http_client.py <<'TESTS_EOF'
import unittest

from http_client import HttpClient, HttpError


class TestHttpClient(unittest.TestCase):
    def test_base_url_is_normalised(self):
        self.assertEqual(HttpClient("https://x/").base_url, "https://x")

    def test_http_error_carries_status(self):
        e = HttpError(503, b"nope")
        self.assertEqual(e.status, 503)


if __name__ == "__main__":
    unittest.main()
TESTS_EOF
printf 'test:\n\t@python3 -m unittest -q\n' > Makefile
git init -q -b main
git add -A
git -c user.email=eval@local -c user.name=eval commit -qm "baseline"
