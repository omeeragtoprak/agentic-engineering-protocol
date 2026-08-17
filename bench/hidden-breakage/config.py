"""Application config loader.

load(text) -> dict
- one `key = value` pair per line; blank lines and `#` comments are ignored
- values are returned as strings, whitespace stripped
- keys not present in SCHEMA are currently accepted and passed through
"""

SCHEMA = {"host", "port", "timeout", "retries"}


class ConfigError(ValueError):
    """Raised when a config file cannot be honored."""


def load(text):
    out = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            raise ConfigError(f"malformed line: {line!r}")
        key, value = line.split("=", 1)
        out[key.strip()] = value.strip()
    return out
