from google.cloud import bigquery
from google.oauth2 import service_account
from pathlib import Path


def get_bq_client(project_id: str = "game-data-483711"):
    creds_path = Path(__file__).resolve().parents[3] / "keys" / "my_creds.json"

    credentials = service_account.Credentials.from_service_account_file(
        creds_path
    )

    return bigquery.Client(
        project=project_id,
        credentials=credentials,
    )