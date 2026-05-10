from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any

if __package__ in {None, ""}:
    from common import compact_record_summary, load_follow_up_items, load_records, resolve_vault_path, to_json
else:
    from .common import compact_record_summary, load_follow_up_items, load_records, resolve_vault_path, to_json


def run(vault_path: str | Path | None = None, output_format: str = "json") -> str:
    resolved_vault = resolve_vault_path(vault_path)
    records = load_records(resolved_vault)
    follow_ups = load_follow_up_items(resolved_vault)

    unresolved_follow_ups = [item.to_dict() for item in follow_ups if not item.resolved]
    partial_records = [compact_record_summary(record) for record in records if record.trust_level == "partial"]
    unsafe_records = [compact_record_summary(record) for record in records if record.trust_level == "unsafe"]
    non_resume_ready_records = [compact_record_summary(record) for record in records if not record.resume_ready]
    missing_dates_records = [
        compact_record_summary(record)
        for record in records
        if not record.start_period or (not record.end_period and not record.is_current)
    ]

    payload = {
        "vault_path": resolved_vault.as_posix(),
        "counts": {
            "unresolved_follow_up_items": len(unresolved_follow_ups),
            "partial_records": len(partial_records),
            "unsafe_records": len(unsafe_records),
            "non_resume_ready_records": len(non_resume_ready_records),
            "missing_dates_records": len(missing_dates_records),
        },
        "unresolved_follow_up_items": unresolved_follow_ups,
        "partial_records": partial_records,
        "unsafe_records": unsafe_records,
        "non_resume_ready_records": non_resume_ready_records,
        "missing_dates_records": missing_dates_records,
    }
    if output_format == "markdown":
        return _to_markdown(payload)
    return to_json(payload)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Report evidence gaps")
    parser.add_argument("--vault-path")
    parser.add_argument("--output-format", choices=("json", "markdown"), default="json")
    return parser


def main() -> None:
    args = build_parser().parse_args()
    print(run(vault_path=args.vault_path, output_format=args.output_format))


def _to_markdown(payload: dict[str, Any]) -> str:
    lines = [f"vault_path: {payload['vault_path']}"]
    for key, value in payload["counts"].items():
        lines.append(f"{key}: {value}")
    return "\n".join(lines)


if __name__ == "__main__":
    main()
