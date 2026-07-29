"""HTTP JSON fetch helper shared by sync_client and report_job."""
import json
import urllib.request


def get_json(url, timeout=10):
    """Fetch a URL and parse the JSON body. Raises URLError/HTTPError on failure."""
    with urllib.request.urlopen(url, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))
