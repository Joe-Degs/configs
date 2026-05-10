from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any

if __package__ in {None, ""}:
    from common import EvidenceRecord, load_records, record_terms, resolve_vault_path, to_json
else:
    from .common import EvidenceRecord, load_records, record_terms, resolve_vault_path, to_json


def run(
    vault_path: str | Path | None = None,
    company: str | None = None,
    role: str | None = None,
    trust_level: str | None = None,
    resume_ready: bool | None = None,
    interview_ready: bool | None = None,
    role_family_tag: str | None = None,
    keyword: str | None = None,
    tool: str | None = None,
    theme: str | None = None,
    limit: int | None = None,
    output_format: str = "json",
) -> str:
    resolved_vault = resolve_vault_path(vault_path)
    records = [record for record in load_records(resolved_vault) if _matches(record, company, role, trust_level, resume_ready, interview_ready, role_family_tag, keyword, tool, theme)]
    if limit is not None:
        records = records[:limit]

    payload = {
        "vault_path": resolved_vault.as_posix(),
        "count": len(records),
        "records": [record.to_query_dict() for record in records],
    }
    if output_format == "markdown":
        return _to_markdown(payload)
    return to_json(payload)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Query career evidence records")
    parser.add_argument("--vault-path")
    parser.add_argument("--company")
    parser.add_argument("--role")
    parser.add_argument("--trust-level")
    parser.add_argument("--resume-ready", choices=("true", "false"))
    parser.add_argument("--interview-ready", choices=("true", "false"))
    parser.add_argument("--role-family-tag")
    parser.add_argument("--keyword")
    parser.add_argument("--tool")
    parser.add_argument("--theme")
    parser.add_argument("--limit", type=int)
    parser.add_argument("--output-format", choices=("json", "markdown"), default="json")
    return parser


def main() -> None:
    args = build_parser().parse_args()
    print(
        run(
            vault_path=args.vault_path,
            company=args.company,
            role=args.role,
            trust_level=args.trust_level,
            resume_ready=_parse_bool_flag(args.resume_ready),
            interview_ready=_parse_bool_flag(args.interview_ready),
            role_family_tag=args.role_family_tag,
            keyword=args.keyword,
            tool=args.tool,
            theme=args.theme,
            limit=args.limit,
            output_format=args.output_format,
        )
    )


def _matches(
    record: EvidenceRecord,
    company: str | None,
    role: str | None,
    trust_level: str | None,
    resume_ready: bool | None,
    interview_ready: bool | None,
    role_family_tag: str | None,
    keyword: str | None,
    tool: str | None,
    theme: str | None,
) -> bool:
    if company and record.company.casefold() != company.casefold():
        return False
    if role and role.casefold() not in record.role.casefold():
        return False
    if trust_level and record.trust_level.casefold() != trust_level.casefold():
        return False
    if resume_ready is not None and record.resume_ready is not resume_ready:
        return False
    if interview_ready is not None and record.interview_ready is not interview_ready:
        return False
    if role_family_tag and not _contains(record.role_family_tags, role_family_tag):
        return False
    if keyword and keyword.casefold() not in record_terms(record):
        return False
    if tool and not _contains(record.tools, tool):
        return False
    if theme and not _contains(record.theme, theme):
        return False
    return True


def _contains(values: list[str], expected: str) -> bool:
    expected_folded = expected.casefold()
    return any(expected_folded in value.casefold() for value in values)


def _parse_bool_flag(value: str | None) -> bool | None:
    if value is None:
        return None
    return value == "true"


def _to_markdown(payload: dict[str, Any]) -> str:
    lines = [
        f"vault_path: {payload['vault_path']}",
        f"records: {payload['count']}",
    ]
    for record in payload["records"]:
        lines.extend(
            [
                f"- id: {record['id']}",
                f"  company: {record['company']}",
                f"  role: {record['role']}",
                f"  trust_level: {record['trust_level']}",
                f"  resume_ready: {str(record['resume_ready']).lower()}",
                f"  interview_ready: {str(record['interview_ready']).lower()}",
                f"  path: {record['path']}",
            ]
        )
    return "\n".join(lines)


if __name__ == "__main__":
    main()
