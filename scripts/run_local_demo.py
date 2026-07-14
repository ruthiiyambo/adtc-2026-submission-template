#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlparse
from urllib.request import Request, urlopen


ROOT_DIR = Path(__file__).resolve().parents[1]
STATIC_DIR = ROOT_DIR / "demo"

SYSTEM_PROMPT = """
You are FarmHand NA, an offline livestock triage assistant for smallholder
farmers and extension officers in northern Namibia.

Give cautious, practical guidance for cattle, goats, sheep, and calves.
Do not present yourself as a veterinarian and do not claim certainty when the
symptoms could have multiple causes.

Always do the following:
- Focus on likely causes, safe first actions, urgent red flags, and what to
  check next.
- Prefer actions that are realistic in low-resource settings: isolate the sick
  animal, provide shade, clean water, oral rehydration when appropriate, reduce
  stress, observe manure, urine, breathing, appetite, swelling, and temperature.
- Tell the user when urgent veterinary help is needed.
- If more than one animal is affected, mention possible outbreak risk.
- Avoid made-up medicines, made-up dosages, or overconfident treatment plans.

Use these headings exactly:
1. Most likely causes
2. Safe first actions
3. Get urgent veterinary help now if
4. What to check next

Keep the response easy to scan, concrete, and no longer than needed.
""".strip()


class DemoServer(ThreadingHTTPServer):
    backend_url: str
    model_name: str


class DemoHandler(SimpleHTTPRequestHandler):
    server: DemoServer

    def __init__(self, *args: Any, **kwargs: Any) -> None:
        super().__init__(*args, directory=str(STATIC_DIR), **kwargs)

    def do_GET(self) -> None:
        parsed = urlparse(self.path)

        if parsed.path == "/api/health":
            self.handle_health()
            return

        if parsed.path == "/":
            self.path = "/index.html"

        super().do_GET()

    def do_POST(self) -> None:
        parsed = urlparse(self.path)

        if parsed.path == "/api/chat":
            self.handle_chat()
            return

        self.send_error(HTTPStatus.NOT_FOUND, "File Not Found")

    def handle_health(self) -> None:
        upstream = self.fetch_json(f"{self.server.backend_url}/health", method="GET")

        if upstream["ok"]:
            payload = {
                "status": "ok",
                "model": self.server.model_name,
                "detail": f"Connected to local model on {self.server.backend_url}.",
            }
            self.write_json(HTTPStatus.OK, payload)
            return

        payload = {
            "status": "offline",
            "model": self.server.model_name,
            "detail": upstream["detail"],
        }
        self.write_json(HTTPStatus.SERVICE_UNAVAILABLE, payload)

    def handle_chat(self) -> None:
        content_length = int(self.headers.get("Content-Length", "0"))

        if content_length <= 0:
            self.write_json(
                HTTPStatus.BAD_REQUEST,
                {"detail": "Request body is required."},
            )
            return

        try:
            raw_body = self.rfile.read(content_length)
            payload = json.loads(raw_body.decode("utf-8"))
        except json.JSONDecodeError:
            self.write_json(
                HTTPStatus.BAD_REQUEST,
                {"detail": "Invalid JSON request body."},
            )
            return

        messages = self.normalize_messages(payload)

        if not messages:
            self.write_json(
                HTTPStatus.BAD_REQUEST,
                {"detail": "Provide a non-empty message or messages array."},
            )
            return

        try:
            max_tokens = int(payload.get("max_tokens", 360))
        except (TypeError, ValueError):
            max_tokens = 360
        max_tokens = max(128, min(max_tokens, 512))

        upstream_payload = {
            "model": self.server.model_name,
            "messages": [{"role": "system", "content": SYSTEM_PROMPT}] + messages[-8:],
            "temperature": 0.2,
            "max_tokens": max_tokens,
            "stream": False,
        }

        upstream = self.fetch_json(
            f"{self.server.backend_url}/v1/chat/completions",
            method="POST",
            payload=upstream_payload,
        )

        if not upstream["ok"]:
            self.write_json(
                HTTPStatus.BAD_GATEWAY,
                {"detail": upstream["detail"]},
            )
            return

        data = upstream["data"]
        answer = ""

        choices = data.get("choices", [])
        if choices:
            answer = choices[0].get("message", {}).get("content", "").strip()

        if not answer:
            answer = "I could not generate a useful answer just now."

        response_payload = {
            "answer": answer,
            "model": data.get("model", self.server.model_name),
            "usage": data.get("usage"),
            "timings": data.get("timings"),
        }
        self.write_json(HTTPStatus.OK, response_payload)

    def normalize_messages(self, payload: dict[str, Any]) -> list[dict[str, str]]:
        messages: list[dict[str, str]] = []

        if isinstance(payload.get("message"), str):
            message = payload["message"].strip()
            if message:
                messages.append({"role": "user", "content": message})

        raw_messages = payload.get("messages")
        if not isinstance(raw_messages, list):
            return messages

        normalized: list[dict[str, str]] = []
        for item in raw_messages:
            if not isinstance(item, dict):
                continue

            role = item.get("role")
            content = item.get("content")

            if role not in {"user", "assistant"}:
                continue
            if not isinstance(content, str):
                continue

            text = content.strip()
            if not text:
                continue

            normalized.append({"role": role, "content": text})

        return normalized or messages

    def fetch_json(
        self,
        url: str,
        *,
        method: str,
        payload: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        headers = {"Accept": "application/json"}
        body = None

        if payload is not None:
            headers["Content-Type"] = "application/json"
            body = json.dumps(payload).encode("utf-8")

        request = Request(url, headers=headers, data=body, method=method)

        try:
            with urlopen(request, timeout=180) as response:
                data = json.load(response)
            return {"ok": True, "data": data}
        except HTTPError as exc:
            detail = self.read_error_detail(exc)
            return {"ok": False, "detail": detail}
        except URLError as exc:
            return {"ok": False, "detail": str(exc.reason)}

    def read_error_detail(self, exc: HTTPError) -> str:
        try:
            raw = exc.read().decode("utf-8")
        except Exception:
            return f"Upstream error {exc.code}."

        try:
            data = json.loads(raw)
        except json.JSONDecodeError:
            return raw or f"Upstream error {exc.code}."

        if isinstance(data, dict):
            error = data.get("error")
            if isinstance(error, dict):
                return error.get("message", raw) or raw

        return raw or f"Upstream error {exc.code}."

    def write_json(self, status: HTTPStatus, payload: dict[str, Any]) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Serve the FarmHand NA demo UI.")
    parser.add_argument("--host", default="127.0.0.1", help="Host to bind to.")
    parser.add_argument("--port", type=int, default=3000, help="Port to serve on.")
    parser.add_argument(
        "--backend",
        default="http://127.0.0.1:8080",
        help="Base URL for llama-server.",
    )
    parser.add_argument(
        "--model-name",
        default="Phi-4-mini-instruct-Q4_K_M",
        help="Model name to send to llama-server.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if not STATIC_DIR.exists():
        raise SystemExit(f"Missing demo assets directory: {STATIC_DIR}")

    server = DemoServer((args.host, args.port), DemoHandler)
    server.backend_url = args.backend.rstrip("/")
    server.model_name = args.model_name

    print(f"Serving FarmHand NA demo at http://{args.host}:{args.port}")
    print(f"Proxying chat requests to {server.backend_url}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping FarmHand NA demo server.")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
