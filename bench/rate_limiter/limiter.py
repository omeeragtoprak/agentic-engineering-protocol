"""Sliding-window rate limiter.

RateLimiter(limit, window): allow at most `limit` calls per `window`
seconds PER USER. allow(user, now) returns True and records the call if
the user has made FEWER than `limit` calls in the window (now - window,
now]; otherwise False and the call is NOT recorded. Old timestamps must
be pruned so memory does not grow forever.
"""


class RateLimiter:
    def __init__(self, limit, window):
        self.limit = limit
        self.window = window
        self.calls = []

    def allow(self, user, now):
        recent = [t for t in self.calls if t > now - self.window]
        if len(recent) > self.limit:
            return False
        self.calls.append(now)
        return True
