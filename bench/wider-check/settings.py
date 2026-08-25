"""Runtime settings loader.

load(pairs) -> dict
Takes an iterable of (key, raw_value) string pairs and returns the settings
dict. Values are currently returned as strings, unvalidated.
"""

KNOWN = ("host", "port", "timeout", "retries", "verbose")


class SettingsError(ValueError):
    """Raised when a setting cannot be honored."""


def load(pairs):
    out = {}
    for key, raw in pairs:
        if key not in KNOWN:
            raise SettingsError(f"unknown setting: {key}")
        out[key] = raw
    return out
