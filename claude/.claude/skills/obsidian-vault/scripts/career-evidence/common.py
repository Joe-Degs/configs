from __future__ import annotations

import json
import os
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any


DEFAULT_VAULT_CANDIDATES = (
    Path("/home/joe/Obsidian"),
    Path("~/dev/Obsidian").expanduser(),
)
LIST_FIELDS = {
    "theme",
    "metrics",
    "systems",
    "tools",
    "keywords",
    "role_family_tags",
    "source_notes",
}
BOOL_FIELDS = {"is_current", "resume_ready", "interview_ready"}
STRING_FIELDS = {
    "type",
    "id",
    "company",
    "experience_type",
    "role",
    "start_period",
    "end_period",
    "problem",
    "action",
    "outcome",
    "trust_level",
    "confidentiality",
    "notes",
    "bullet_candidate",
}
TRUST_LEVEL_SCORES = {
    "verified": 40,
    "confirmed_by_you": 28,
    "partial": 12,
    "unsafe": 0,
}
STOP_WORDS = {
    "a",
    "an",
    "and",
    "for",
    "from",
    "in",
    "into",
    "of",
    "on",
    "or",
    "the",
    "to",
    "with",
    "you",
    "your",
    "need",
    "needs",
    "using",
    "use",
    "used",
    "experience",
}


@dataclass(slots=True)
class EvidenceRecord:
    id: str
    company: str
    experience_type: str
    role: str
    theme: list[str]
    start_period: str
    end_period: str
    is_current: bool
    problem: str
    action: str
    outcome: str
    metrics: list[str]
    systems: list[str]
    tools: list[str]
    keywords: list[str]
    role_family_tags: list[str]
    trust_level: str
    source_notes: list[str]
    resume_ready: bool
    interview_ready: bool
    confidentiality: str
    notes: str
    bullet_candidate: str
    path: Path
    body: str

    @property
    def search_text(self) -> str:
        return "\n".join(
            [
                self.company,
                self.role,
                " ".join(self.theme),
                self.problem,
                self.action,
                self.outcome,
                " ".join(self.metrics),
                " ".join(self.systems),
                " ".join(self.tools),
                " ".join(self.keywords),
                " ".join(self.role_family_tags),
                self.notes,
                self.bullet_candidate,
                self.body,
            ]
        ).lower()

    @property
    def recency_score(self) -> int:
        if self.is_current:
            return 999_999
        return max(date_score(self.end_period), date_score(self.start_period))

    def to_query_dict(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "company": self.company,
            "role": self.role,
            "theme": self.theme,
            "metrics": self.metrics,
            "tools": self.tools,
            "keywords": self.keywords,
            "role_family_tags": self.role_family_tags,
            "trust_level": self.trust_level,
            "resume_ready": self.resume_ready,
            "interview_ready": self.interview_ready,
            "source_notes": self.source_notes,
            "bullet_candidate": self.bullet_candidate,
            "notes": self.notes,
            "path": self.path.as_posix(),
        }


@dataclass(slots=True)
class FollowUpItem:
    text: str
    resolved: bool
    path: Path

    def to_dict(self) -> dict[str, Any]:
        return {"text": self.text, "resolved": self.resolved, "path": self.path.as_posix()}


def resolve_vault_path(vault_path: str | os.PathLike[str] | None) -> Path:
    candidates: list[Path] = []
    if vault_path:
        candidates.append(Path(vault_path).expanduser())
    env_path = os.environ.get("OBSIDIAN_VAULT_PATH")
    if env_path:
        candidates.append(Path(env_path).expanduser())
    candidates.extend(DEFAULT_VAULT_CANDIDATES)

    for candidate in candidates:
        if candidate.exists():
            return candidate.resolve()

    return candidates[0].resolve()


def parse_frontmatter(text: str) -> tuple[dict[str, Any], str]:
    lines = text.splitlines()
    start_index = 0
    while start_index < len(lines) and not lines[start_index].strip():
        start_index += 1

    if start_index >= len(lines) or lines[start_index].strip() != "---":
        return {}, text

    end_index = None
    for index in range(start_index + 1, len(lines)):
        if lines[index].strip() == "---":
            end_index = index
            break
    if end_index is None:
        return {}, text

    frontmatter: dict[str, Any] = {}
    current_list_key: str | None = None

    for raw_line in lines[start_index + 1 : end_index]:
        if not raw_line.strip():
            continue
        list_match = re.match(r"^\s*-\s+(.*)$", raw_line)
        if list_match and current_list_key:
            frontmatter.setdefault(current_list_key, []).append(_parse_scalar(list_match.group(1).strip()))
            continue
        if ":" not in raw_line:
            current_list_key = None
            continue
        key, raw_value = raw_line.split(":", 1)
        key = key.strip()
        value = raw_value.strip()
        if value == "":
            if key in LIST_FIELDS:
                frontmatter[key] = []
            else:
                frontmatter[key] = ""
            current_list_key = key
            continue
        frontmatter[key] = _parse_scalar(value)
        current_list_key = None

    body = "\n".join(lines[end_index + 1 :])
    return frontmatter, body


def load_records(vault_path: Path) -> list[EvidenceRecord]:
    records_dir = Path(vault_path) / "Areas/Career/Evidence/Records"
    if not records_dir.exists():
        return []

    records: list[EvidenceRecord] = []
    for path in sorted(records_dir.glob("**/*.md")):
        text = path.read_text(encoding="utf-8")
        frontmatter, body = parse_frontmatter(text)
        if frontmatter.get("type") != "evidence":
            continue
        records.append(_record_from_frontmatter(path, frontmatter, body))
    return records


def load_follow_up_items(vault_path: Path) -> list[FollowUpItem]:
    path = Path(vault_path) / "Areas/Career/Evidence/follow-up.md"
    if not path.exists():
        return []

    items: list[FollowUpItem] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("- [x] ") or stripped.startswith("- [X] "):
            items.append(FollowUpItem(text=stripped[6:].strip(), resolved=True, path=path))
        elif stripped.startswith("- [ ] "):
            items.append(FollowUpItem(text=stripped[6:].strip(), resolved=False, path=path))
        elif stripped.startswith("- "):
            items.append(FollowUpItem(text=stripped[2:].strip(), resolved=False, path=path))
    return items


def extract_keywords(*texts: str, limit: int = 20) -> list[str]:
    counts: dict[str, int] = {}
    order: dict[str, int] = {}
    for text in texts:
        for token in re.findall(r"[a-z0-9_+.#-]+", text.lower()):
            normalized = token.strip(".-")
            if len(normalized) < 3 or normalized in STOP_WORDS:
                continue
            order.setdefault(normalized, len(order))
            counts[normalized] = counts.get(normalized, 0) + 1
    ranked = sorted(counts, key=lambda item: (-counts[item], order[item], item))
    return ranked[:limit]


def record_terms(record: EvidenceRecord) -> set[str]:
    terms = set(extract_keywords(record.search_text, limit=200))
    for value in record.theme + record.metrics + record.systems + record.tools + record.keywords + record.role_family_tags:
        for token in re.findall(r"[a-z0-9_+.#-]+", value.lower()):
            normalized = token.strip(".-")
            if normalized:
                terms.add(normalized)
    return terms


def date_score(period: str) -> int:
    if not period or not re.fullmatch(r"\d{4}-\d{2}", period):
        return 0
    year_text, month_text = period.split("-", 1)
    return int(year_text) * 12 + int(month_text)


def to_json(payload: Any) -> str:
    return json.dumps(payload, indent=2, sort_keys=True)


def trust_level_score(trust_level: str) -> int:
    return TRUST_LEVEL_SCORES.get(trust_level, 0)


def compact_record_summary(record: EvidenceRecord) -> dict[str, Any]:
    return {
        "id": record.id,
        "company": record.company,
        "role": record.role,
        "trust_level": record.trust_level,
        "resume_ready": record.resume_ready,
        "start_period": record.start_period,
        "end_period": record.end_period,
        "path": record.path.as_posix(),
    }


def as_plain_dict(value: Any) -> Any:
    if isinstance(value, Path):
        return value.as_posix()
    if hasattr(value, "__dataclass_fields__"):
        data = asdict(value)
        return {key: as_plain_dict(item) for key, item in data.items()}
    if isinstance(value, dict):
        return {key: as_plain_dict(item) for key, item in value.items()}
    if isinstance(value, list):
        return [as_plain_dict(item) for item in value]
    return value


def _parse_scalar(value: str) -> Any:
    if value in {"true", "false"}:
        return value == "true"
    if value == "[]":
        return []
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def _record_from_frontmatter(path: Path, frontmatter: dict[str, Any], body: str) -> EvidenceRecord:
    def as_list(key: str) -> list[str]:
        value = frontmatter.get(key, [])
        if value == "":
            return []
        if isinstance(value, list):
            return [str(item) for item in value]
        return [str(value)]

    def as_bool(key: str) -> bool:
        value = frontmatter.get(key, False)
        return value if isinstance(value, bool) else str(value).lower() == "true"

    def as_str(key: str) -> str:
        value = frontmatter.get(key, "")
        return "" if value is None else str(value)

    return EvidenceRecord(
        id=as_str("id"),
        company=as_str("company"),
        experience_type=as_str("experience_type"),
        role=as_str("role"),
        theme=as_list("theme"),
        start_period=as_str("start_period"),
        end_period=as_str("end_period"),
        is_current=as_bool("is_current"),
        problem=as_str("problem"),
        action=as_str("action"),
        outcome=as_str("outcome"),
        metrics=as_list("metrics"),
        systems=as_list("systems"),
        tools=as_list("tools"),
        keywords=as_list("keywords"),
        role_family_tags=as_list("role_family_tags"),
        trust_level=as_str("trust_level"),
        source_notes=as_list("source_notes"),
        resume_ready=as_bool("resume_ready"),
        interview_ready=as_bool("interview_ready"),
        confidentiality=as_str("confidentiality"),
        notes=as_str("notes"),
        bullet_candidate=as_str("bullet_candidate"),
        path=path.resolve(),
        body=body.strip(),
    )
