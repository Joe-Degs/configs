from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Any

if __package__ in {None, ""}:
    from common import EvidenceRecord, extract_keywords, load_follow_up_items, load_records, record_terms, resolve_vault_path, to_json, trust_level_score
else:
    from .common import EvidenceRecord, extract_keywords, load_follow_up_items, load_records, record_terms, resolve_vault_path, to_json, trust_level_score


OWNERSHIP_TERMS = ("own", "owned", "ownership", "sole", "led", "lead", "accountable")


def run(
    vault_path: str | Path | None = None,
    role: str | None = None,
    company: str | None = None,
    application_stage: str | None = None,
    keywords: list[str] | None = None,
    jd_text: str | None = None,
    limit: int = 8,
    output_format: str = "json",
) -> str:
    resolved_vault = resolve_vault_path(vault_path)
    requested_keywords = _requested_keywords(role=role, keywords=keywords, jd_text=jd_text)
    records = load_records(resolved_vault)
    ranked_records = sorted(records, key=lambda record: _score_record(record, requested_keywords), reverse=True)
    work_records = [record for record in ranked_records if record.experience_type in {"paid_work", "freelance", "leadership", "teaching", "volunteer"}][:limit]
    project_records = [record for record in ranked_records if record.experience_type == "project"][:limit]
    note_records = [record for record in ranked_records if record.experience_type not in {"paid_work", "freelance", "leadership", "teaching", "volunteer", "project"}][:limit]
    selected_records = work_records + project_records + note_records

    selected_work_history = [_packet_entry(record, requested_keywords) for record in work_records]
    selected_projects = [_packet_entry(record, requested_keywords) for record in project_records]
    selected_tasks_or_notes = [_packet_note_entry(record, requested_keywords) for record in note_records]

    strongest_metrics = _strongest_metrics(selected_records)
    gaps = _build_gaps(role=role, requested_keywords=requested_keywords, selected_records=selected_records, vault_path=resolved_vault)
    payload = {
        "company": company or "",
        "role": role or "",
        "application_stage": application_stage or "",
        "target_artifact": "resume_support_packet",
        "target_context_available": bool((role and role.strip()) or (keywords and any(keywords)) or (jd_text and jd_text.strip())),
        "jd_keywords": requested_keywords,
        "selected_work_history": selected_work_history,
        "selected_projects": selected_projects,
        "selected_tasks_or_notes": selected_tasks_or_notes,
        "strongest_metrics": strongest_metrics,
        "gaps": gaps,
        "tone_constraints": ["keep claims grounded", "preserve source-backed scope"],
        "save_back_preference": "do_not_write",
    }
    if output_format == "markdown":
        return _to_markdown(payload)
    return to_json(payload)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Build a compact evidence packet")
    parser.add_argument("--vault-path")
    parser.add_argument("--role")
    parser.add_argument("--company")
    parser.add_argument("--application-stage")
    parser.add_argument("--keyword", action="append", dest="keywords")
    parser.add_argument("--jd-text")
    parser.add_argument("--limit", type=int, default=8)
    parser.add_argument("--output-format", choices=("json", "markdown"), default="json")
    return parser


def main() -> None:
    args = build_parser().parse_args()
    print(
        run(
            vault_path=args.vault_path,
            role=args.role,
            company=args.company,
            application_stage=args.application_stage,
            keywords=args.keywords,
            jd_text=args.jd_text,
            limit=args.limit,
            output_format=args.output_format,
        )
    )


def _requested_keywords(role: str | None, keywords: list[str] | None, jd_text: str | None) -> list[str]:
    parts = []
    if role:
        parts.append(role)
    if keywords:
        parts.extend(keywords)
    if jd_text:
        parts.append(jd_text)
    extracted = extract_keywords(*parts)
    return [keyword for keyword in extracted if keyword not in {"engineer", "software", "senior"}]


def _score_record(record: EvidenceRecord, requested_keywords: list[str]) -> tuple[int, int, int, int, int, str]:
    terms = record_terms(record)
    keyword_matches = len({keyword for keyword in requested_keywords if keyword in terms})
    ownership_score = _ownership_score(record)
    metrics_score = 1 if record.metrics else 0
    resume_score = 1 if record.resume_ready else 0
    return (
        keyword_matches * 10 + ownership_score,
        trust_level_score(record.trust_level),
        resume_score,
        metrics_score,
        record.recency_score,
        record.id,
    )


def _ownership_score(record: EvidenceRecord) -> int:
    text = " ".join([record.role, record.action, record.outcome, record.body]).lower()
    return sum(1 for term in OWNERSHIP_TERMS if term in text)


def _packet_entry(record: EvidenceRecord, requested_keywords: list[str]) -> dict[str, Any]:
    return {
        "source": record.id,
        "source_path": record.path.as_posix(),
        "recency": record.end_period or record.start_period,
        "confidence": record.trust_level,
        "resume_ready": record.resume_ready,
        "interview_ready": record.interview_ready,
        "summary": record.bullet_candidate or _summarize(record),
        "proof_excerpt": _proof_excerpt(record),
        "metrics": record.metrics,
        "keywords": _matched_keywords(record, requested_keywords),
    }


def _packet_note_entry(record: EvidenceRecord, requested_keywords: list[str]) -> dict[str, Any]:
    return {
        "source": record.id,
        "source_path": record.path.as_posix(),
        "recency": record.end_period or record.start_period,
        "confidence": record.trust_level,
        "resume_ready": record.resume_ready,
        "interview_ready": record.interview_ready,
        "summary": record.bullet_candidate or _summarize(record),
        "proof_excerpt": _proof_excerpt(record),
        "proof_value": "; ".join(_matched_keywords(record, requested_keywords)) or record.company,
    }


def _matched_keywords(record: EvidenceRecord, requested_keywords: list[str]) -> list[str]:
    terms = record_terms(record)
    matches = [keyword for keyword in requested_keywords if keyword in terms]
    return matches[:8]


def _summarize(record: EvidenceRecord) -> str:
    pieces = [piece for piece in [record.action, record.outcome] if piece]
    return " ".join(pieces)[:280]


def _proof_excerpt(record: EvidenceRecord) -> str:
    excerpt = " ".join(piece for piece in [record.problem, record.action, record.outcome] if piece)
    excerpt = re.sub(r"\s+", " ", excerpt).strip()
    return excerpt[:320]


def _strongest_metrics(records: list[EvidenceRecord]) -> list[str]:
    metrics: list[str] = []
    for record in records:
        metrics.extend(record.metrics)
    seen: set[str] = set()
    unique_metrics: list[str] = []
    for metric in metrics:
        if metric not in seen:
            unique_metrics.append(metric)
            seen.add(metric)
    return unique_metrics[:10]


def _build_gaps(role: str | None, requested_keywords: list[str], selected_records: list[EvidenceRecord], vault_path: Path) -> list[str]:
    gaps: list[str] = []
    selected_text = "\n".join(record.search_text for record in selected_records)
    for keyword in requested_keywords:
        if keyword not in selected_text:
            gaps.append(f"missing direct evidence for keyword: {keyword}")
    for item in load_follow_up_items(vault_path):
        if not item.resolved:
            gaps.append(item.text)
    if role and not selected_records:
        gaps.append(f"no evidence selected for role: {role}")
    deduped: list[str] = []
    seen: set[str] = set()
    for gap in gaps:
        if gap not in seen:
            deduped.append(gap)
            seen.add(gap)
    return deduped[:20]


def _to_markdown(payload: dict[str, Any]) -> str:
    lines = [
        f"company: {payload['company']}",
        f"role: {payload['role']}",
        f"application_stage: {payload['application_stage']}",
        f"target_artifact: {payload['target_artifact']}",
        f"target_context_available: {str(payload['target_context_available']).lower()}",
        f"jd_keywords: {', '.join(payload['jd_keywords'])}",
        "",
        "selected_work_history:",
    ]
    if payload["selected_work_history"]:
        for item in payload["selected_work_history"]:
            lines.append(f"- {item['source']}: {item['summary']}")
            lines.append(f"  recency: {item['recency']}")
            lines.append(f"  confidence: {item['confidence']}")
            lines.append(f"  resume_ready: {str(item['resume_ready']).lower()}")
            lines.append(f"  interview_ready: {str(item['interview_ready']).lower()}")
            lines.append(f"  metrics: {', '.join(item['metrics'])}")
            lines.append(f"  keywords: {', '.join(item['keywords'])}")
            lines.append(f"  source_path: {item['source_path']}")
            lines.append(f"  proof_excerpt: {item['proof_excerpt']}")
    else:
        lines.append("- none")

    lines.append("")
    lines.append("selected_projects:")
    if payload["selected_projects"]:
        for item in payload["selected_projects"]:
            lines.append(f"- {item['source']}: {item['summary']}")
            lines.append(f"  recency: {item['recency']}")
            lines.append(f"  confidence: {item['confidence']}")
            lines.append(f"  resume_ready: {str(item['resume_ready']).lower()}")
            lines.append(f"  interview_ready: {str(item['interview_ready']).lower()}")
            lines.append(f"  metrics: {', '.join(item['metrics'])}")
            lines.append(f"  keywords: {', '.join(item['keywords'])}")
            lines.append(f"  source_path: {item['source_path']}")
            lines.append(f"  proof_excerpt: {item['proof_excerpt']}")
    else:
        lines.append("- none")

    lines.append("")
    lines.append("selected_tasks_or_notes:")
    if payload["selected_tasks_or_notes"]:
        for item in payload["selected_tasks_or_notes"]:
            lines.append(f"- {item['source']}: {item['summary']}")
            lines.append(f"  recency: {item['recency']}")
            lines.append(f"  confidence: {item['confidence']}")
            lines.append(f"  resume_ready: {str(item['resume_ready']).lower()}")
            lines.append(f"  interview_ready: {str(item['interview_ready']).lower()}")
            lines.append(f"  source_path: {item['source_path']}")
            lines.append(f"  proof_excerpt: {item['proof_excerpt']}")
            lines.append(f"  proof_value: {item['proof_value']}")
    else:
        lines.append("- none")

    lines.append("")
    lines.append("strongest_metrics:")
    if payload["strongest_metrics"]:
        for metric in payload["strongest_metrics"]:
            lines.append(f"- {metric}")
    else:
        lines.append("- none")

    lines.append("")
    lines.append("gaps:")
    if payload["gaps"]:
        for gap in payload["gaps"]:
            lines.append(f"- {gap}")
    else:
        lines.append("- none")

    lines.append("")
    lines.append("tone_constraints:")
    for tone in payload["tone_constraints"]:
        lines.append(f"- {tone}")
    lines.append(f"save_back_preference: {payload['save_back_preference']}")

    return "\n".join(lines)


if __name__ == "__main__":
    main()
