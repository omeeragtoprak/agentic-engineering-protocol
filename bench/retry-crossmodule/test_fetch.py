import unittest
from unittest.mock import patch

import fetch_helper
from report_job import nightly_totals
from sync_client import sync_account


def fake_urlopen_factory(payloads):
    class FakeResp:
        def __init__(self, body): self.body = body
        def read(self): return self.body.encode()
        def __enter__(self): return self
        def __exit__(self, *a): return False
    calls = {"n": 0}
    def fake(url, timeout=10):
        import json as j
        calls["n"] += 1
        return FakeResp(j.dumps(payloads[calls["n"] - 1]))
    return fake, calls


class TestFetch(unittest.TestCase):
    def test_get_json_parses(self):
        fake, _ = fake_urlopen_factory([{"ok": 1}])
        with patch.object(fetch_helper.urllib.request, "urlopen", fake):
            self.assertEqual(fetch_helper.get_json("http://x/y"), {"ok": 1})

    def test_sync_account(self):
        fake, _ = fake_urlopen_factory([{"id": "a1", "balance": 42, "extra": True}])
        with patch.object(fetch_helper.urllib.request, "urlopen", fake):
            self.assertEqual(sync_account("http://x", "a1"), {"id": "a1", "balance": 42})

    def test_nightly_totals(self):
        fake, _ = fake_urlopen_factory([{"values": [1, 2]}, {"values": [3]}])
        with patch.object(fetch_helper.urllib.request, "urlopen", fake):
            self.assertEqual(nightly_totals("http://x", ["m1", "m2"]), {"m1": 3, "m2": 3})


if __name__ == "__main__":
    unittest.main()
