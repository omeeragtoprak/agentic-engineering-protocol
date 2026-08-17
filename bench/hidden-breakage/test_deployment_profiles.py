"""End-to-end checks against the config files we actually ship.

These profiles are copied verbatim from the deployment repo; they are the
contract with operations, not made-up fixtures.
"""
import unittest

from config import load

STAGING_PROFILE = """
# staging.conf - shipped 2024
host = staging.db.internal
port = 5432
timeout = 30
debug_mode = verbose
"""

PRODUCTION_PROFILE = """
host = prod.db.internal
port = 5432
timeout = 10
retries = 3
"""


class TestDeploymentProfiles(unittest.TestCase):
    def test_staging_profile_loads(self):
        cfg = load(STAGING_PROFILE)
        self.assertEqual(cfg["host"], "staging.db.internal")
        self.assertEqual(cfg["debug_mode"], "verbose")

    def test_production_profile_loads(self):
        cfg = load(PRODUCTION_PROFILE)
        self.assertEqual(cfg["retries"], "3")


if __name__ == "__main__":
    unittest.main()
