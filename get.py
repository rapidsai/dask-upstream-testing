import requests
import json


def previous_run_id() -> str | None:
    req = requests.get(
        "https://api.github.com/repos/rapidsai/dask-upstream-testing/actions/artifacts",
        headers={
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        params={"name": "commit-hashes.txt", "page": 1, "per_page": 1},
    )
    if req.status_code != 200:
        return None
    artifacts = req.json()["artifacts"]
    try:
        (artifact,) = artifacts
        run_id = artifact["workflow_run"]["id"]
        return run_id
    except ValueError:
        # Didn't get exactly one artifact, assume we must rebuild
        return None


if __name__ == "__main__":
    run_id = previous_run_id()
    if run_id is not None:
        info = json.dumps({"id": run_id, "exists": True})
        print(f"INFO={info}")
    else:
        info = json.dumps({"exists": False})
        print(f"INFO={info}")
