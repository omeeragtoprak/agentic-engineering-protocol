import unittest

from limiter import RateLimiter


class TestRateLimiter(unittest.TestCase):
    def test_allows_up_to_limit(self):
        rl = RateLimiter(3, 60)
        self.assertTrue(rl.allow("a", 0))
        self.assertTrue(rl.allow("a", 1))
        self.assertTrue(rl.allow("a", 2))

    def test_blocks_over_limit(self):
        rl = RateLimiter(3, 60)
        for t in range(3):
            rl.allow("a", t)
        self.assertFalse(rl.allow("a", 3))

    def test_denied_call_not_recorded(self):
        rl = RateLimiter(1, 60)
        rl.allow("a", 0)
        self.assertFalse(rl.allow("a", 1))
        self.assertTrue(rl.allow("a", 61))

    def test_window_slides(self):
        rl = RateLimiter(2, 10)
        rl.allow("a", 0)
        rl.allow("a", 5)
        self.assertFalse(rl.allow("a", 9))
        self.assertTrue(rl.allow("a", 11))

    def test_users_are_isolated(self):
        rl = RateLimiter(1, 60)
        self.assertTrue(rl.allow("a", 0))
        self.assertTrue(rl.allow("b", 0))

    def test_user_b_not_blocked_by_a(self):
        rl = RateLimiter(2, 60)
        rl.allow("a", 0)
        rl.allow("a", 1)
        self.assertFalse(rl.allow("a", 2))
        self.assertTrue(rl.allow("b", 2))

    def test_old_calls_pruned(self):
        rl = RateLimiter(2, 10)
        for t in (0, 1):
            rl.allow("a", t)
        rl.allow("a", 100)
        stored = getattr(rl, "calls", None)
        if isinstance(stored, dict):
            per_user = stored.get("a", [])
        else:
            per_user = stored if stored is not None else []
        self.assertLessEqual(len(per_user), 2)


if __name__ == "__main__":
    unittest.main()
