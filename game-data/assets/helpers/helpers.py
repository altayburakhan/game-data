import json
import os
from pathlib import Path

from google.cloud import bigquery
from google.oauth2 import service_account


def get_bq_client(project_id: str = "game-data-483711"):

    creds_json = os.environ.get("GOOGLE_CLOUD_CREDENTIALS")
    if creds_json:
        info = json.loads(creds_json)
        sa_info = json.loads(info.get("service_account_json", creds_json))
        credentials = service_account.Credentials.from_service_account_info(sa_info)

    return bigquery.Client(project=project_id, credentials=credentials)
