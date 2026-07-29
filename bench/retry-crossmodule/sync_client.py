"""Interactive sync: fetches account state on user command."""
from fetch_helper import get_json


def sync_account(base_url, account_id):
    data = get_json(f"{base_url}/accounts/{account_id}")
    return {"id": data["id"], "balance": data["balance"]}
