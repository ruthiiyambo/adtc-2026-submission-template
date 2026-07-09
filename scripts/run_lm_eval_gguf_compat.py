#!/usr/bin/env python3

from __future__ import annotations

import logging
from typing import Any


LOG = logging.getLogger(__name__)


def _convert_logprobs_content_to_legacy(content: list[dict[str, Any]]) -> dict[str, Any]:
    text_offset: list[int] = []
    tokens: list[str] = []
    token_logprobs: list[float | None] = []
    top_logprobs: list[dict[str, float]] = []

    current_offset = 0
    for item in content:
        token = item.get("token", "")
        if not isinstance(token, str):
            token = str(token)

        token_top_logprobs: dict[str, float] = {}
        for candidate in item.get("top_logprobs", []) or []:
            candidate_token = candidate.get("token")
            candidate_logprob = candidate.get("logprob")
            if isinstance(candidate_token, str) and isinstance(
                candidate_logprob, (int, float)
            ):
                token_top_logprobs[candidate_token] = float(candidate_logprob)

        logprob = item.get("logprob")

        text_offset.append(current_offset)
        tokens.append(token)
        token_logprobs.append(float(logprob) if isinstance(logprob, (int, float)) else None)
        top_logprobs.append(token_top_logprobs)
        current_offset += len(token)

    return {
        "text_offset": text_offset,
        "tokens": tokens,
        "token_logprobs": token_logprobs,
        "top_logprobs": top_logprobs,
    }


def _patch_lm_eval_gguf() -> None:
    import lm_eval.models.gguf as gguf_model

    original_completion = gguf_model.GGUFLM.gguf_completion

    def patched_completion(self, *args, **kwargs):
        response = original_completion(self, *args, **kwargs)

        try:
            choices = response.get("choices", [])
            if not choices:
                return response

            choice = choices[0]
            logprobs = choice.get("logprobs")
            if not isinstance(logprobs, dict):
                return response

            if "token_logprobs" in logprobs:
                return response

            content = logprobs.get("content")
            if isinstance(content, list) and content:
                choice["logprobs"] = _convert_logprobs_content_to_legacy(content)
        except Exception:
            LOG.exception("Failed to normalize llama.cpp logprobs response")

        return response

    gguf_model.GGUFLM.gguf_completion = patched_completion


def main() -> None:
    _patch_lm_eval_gguf()

    from lm_eval.__main__ import cli_evaluate

    cli_evaluate()


if __name__ == "__main__":
    main()
