"""Nightly batch job: aggregates metrics from several endpoints."""
from fetch_helper import get_json


def nightly_totals(base_url, metric_names):
    totals = {}
    for name in metric_names:
        payload = get_json(f"{base_url}/metrics/{name}")
        totals[name] = sum(payload["values"])
    return totals
