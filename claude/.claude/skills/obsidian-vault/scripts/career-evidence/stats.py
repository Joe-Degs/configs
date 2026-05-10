from __future__ import annotations

import argparse
from collections import Counter
from pathlib import Path
from typing import Any

if __package__ in {None, ""}:
    from common import load_records, resolve_vault_path, to_json
else:
    from .common import load_records, resolve_vault_path, to_json


def run(vault_path: str | Path | None = None, output_format: str = "json") -> str:
    resolved_vault = resolve_vault_path(vault_path)
    records = load_records(resolved_vault)
    by_trust_level = Counter(record.trust_level for record in records)
    by_company = Counter(record.company for record in records)
    by_role_family_tag = Counter(tag for record in records for tag in record.role_family_tags)
    by_resume_ready = Counter(str(record.resume_ready).lower() for record in records)
    payload = {
        "vault_path": resolved_vault.as_posix(),
        "total_records": len(records),
        "by_trust_level": dict(sorted(by_trust_level.items())),
        "by_company": dict(sorted(by_company.items())),
        "by_role_family_tag": dict(sorted(by_role_family_tag.items())),
        "by_resume_ready": dict(sorted(by_resume_ready.items())),
    }
    if output_format == "markdown":
        return _to_markdown(payload)
    return to_json(payload)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Summarize career evidence stats")
    parser.add_argument("--vault-path")
    parser.add_argument("--output-format", choices=("json", "markdown"), default="json")
    return parser


def main() -> None:
    args = build_parser().parse_args()
    print(run(vault_path=args.vault_path, output_format=args.output_format))


def _to_markdown(payload: dict[str, Any]) -> str:
    lines = [f"vault_path: {payload['vault_path']}", f"total_records: {payload['total_records']}"]
    for key in ("by_trust_level", "by_company", "by_role_family_tag", "by_resume_ready"):
        lines.append(f"{key}: {payload[key]}")
    return "\n".join(lines)


if __name__ == "__main__":
    main()
