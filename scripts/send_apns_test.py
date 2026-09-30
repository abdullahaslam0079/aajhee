#!/usr/bin/env python3
"""Send a direct APNs test push (bypasses Firebase Admin IAM).

Use this when FCM Admin returns cloudmessaging.messages.create denied, but the
iOS app already has an APNs device token (Documents/apns_token.txt).

Required:
  AAJHEE_APNS_KEY_PATH   path to AuthKey_XXXX.p8
  AAJHEE_APNS_KEY_ID     e.g. U4ZBFCM8MN
  AAJHEE_APNS_TEAM_ID    e.g. J5F5G7B832
  AAJHEE_APNS_TOKEN      hex APNs device token (or pass --token)

Optional:
  AAJHEE_APNS_BUNDLE_ID  default com.aajhee.app
  AAJHEE_APNS_HOST       api.sandbox.push.apple.com (USB/dev) or
                         api.push.apple.com (TestFlight/App Store)

Example:
  export AAJHEE_APNS_KEY_PATH=~/Downloads/AuthKey_U4ZBFCM8MN.p8
  export AAJHEE_APNS_KEY_ID=U4ZBFCM8MN
  export AAJHEE_APNS_TEAM_ID=J5F5G7B832
  python3 scripts/send_apns_test.py --token "$(cat /tmp/apns_token.txt)" --state foreground
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import uuid
from pathlib import Path

try:
    import jwt
except ImportError:
    print("Install PyJWT: pip install PyJWT cryptography", file=sys.stderr)
    raise

try:
    import httpx
except ImportError:
    print("Install httpx: pip install 'httpx[http2]'", file=sys.stderr)
    raise

STATES = {
    "foreground": {
        "title": "Foreground test",
        "body": "App is open — banner should appear over the UI.",
        "data": {"type": "test_push", "route": "/notifications"},
    },
    "background": {
        "title": "Background test",
        "body": "App is backgrounded — system banner expected.",
        "data": {"type": "test_push", "route": "/notifications"},
    },
    "terminated": {
        "title": "Terminated test",
        "body": "App was killed — system banner expected; tap to cold-start.",
        "data": {"type": "test_push", "route": "/notifications"},
    },
    "order": {
        "title": "Test order update",
        "body": "Your order is being prepared",
        "data": {
            "type": "order_status_changed",
            "order_public_id": "00000000-0000-4000-8000-000000000001",
        },
    },
}


def build_jwt(key_path: Path, key_id: str, team_id: str) -> str:
    private_key = key_path.read_text()
    now = int(time.time())
    return jwt.encode(
        {"iss": team_id, "iat": now},
        private_key,
        algorithm="ES256",
        headers={"alg": "ES256", "kid": key_id},
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--token", default=os.environ.get("AAJHEE_APNS_TOKEN", ""))
    parser.add_argument(
        "--state",
        default="foreground",
        choices=sorted(STATES.keys()),
    )
    parser.add_argument(
        "--production",
        action="store_true",
        help="Use production APNs host (TestFlight / App Store builds).",
    )
    args = parser.parse_args()

    token = (args.token or "").strip()
    key_path = Path(
        os.environ.get("AAJHEE_APNS_KEY_PATH", "")
    ).expanduser()
    key_id = os.environ.get("AAJHEE_APNS_KEY_ID", "").strip()
    team_id = os.environ.get("AAJHEE_APNS_TEAM_ID", "").strip()
    bundle_id = os.environ.get("AAJHEE_APNS_BUNDLE_ID", "com.aajhee.app").strip()

    if not token:
        print("Missing APNs device token (--token or AAJHEE_APNS_TOKEN)", file=sys.stderr)
        return 2
    if not key_path.is_file() or not key_id or not team_id:
        print(
            "Set AAJHEE_APNS_KEY_PATH, AAJHEE_APNS_KEY_ID, AAJHEE_APNS_TEAM_ID",
            file=sys.stderr,
        )
        return 2

    payload = STATES[args.state]
    host = (
        "api.push.apple.com"
        if args.production
        else os.environ.get("AAJHEE_APNS_HOST", "api.sandbox.push.apple.com")
    )
    auth = build_jwt(key_path, key_id, team_id)
    body = {
        "aps": {
            "alert": {"title": payload["title"], "body": payload["body"]},
            "sound": "default",
            "badge": 1,
        },
        **payload["data"],
    }

    url = f"https://{host}/3/device/{token}"
    headers = {
        "authorization": f"bearer {auth}",
        "apns-topic": bundle_id,
        "apns-push-type": "alert",
        "apns-priority": "10",
        "apns-id": str(uuid.uuid4()),
    }

    with httpx.Client(http2=True, timeout=30.0) as client:
        response = client.post(url, headers=headers, content=json.dumps(body))

    print(f"APNs {host} state={args.state} status={response.status_code}")
    if response.content:
        print(response.text)
    if response.status_code != 200:
        return 1
    print("Delivered. Check the iPhone banner / Notification Center.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
