from __future__ import annotations

import importlib.util
import json
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))


def load_module(name: str):
    spec = importlib.util.spec_from_file_location(name, BASE_DIR / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


load_module("common")
query = load_module("query")


def write_note(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(textwrap.dedent(content).strip() + "\n", encoding="utf-8")


class QueryTests(unittest.TestCase):
    def test_query_filters_records_and_returns_json(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            vault_path = Path(temp_dir)
            write_note(
                vault_path / "Areas/Career/Evidence/Records/A/REC-001.md",
                """
                ---
                type: evidence
                id: REC-001
                company: ExampleCo
                experience_type: paid_work
                role: Platform Engineer
                theme:
                  - ownership
                start_period: 2024-01
                end_period: 2024-06
                is_current: false
                problem: old process
                action: built python tooling
                outcome: improved delivery
                metrics:
                  - 25% faster
                systems:
                  - CI
                tools:
                  - Python
                keywords:
                  - delivery
                role_family_tags:
                  - platform
                trust_level: verified
                source_notes:
                  - "[[note]]"
                resume_ready: true
                interview_ready: true
                confidentiality: public_safe
                notes: safe
                bullet_candidate: did the thing
                ---
                text
                """,
            )
            write_note(
                vault_path / "Areas/Career/Evidence/Records/A/REC-002.md",
                """
                ---
                type: evidence
                id: REC-002
                company: OtherCo
                experience_type: project
                role: Builder
                theme:
                  - data
                start_period: 2022-01
                end_period: 2022-02
                is_current: false
                problem: none
                action: used go
                outcome: shipped
                metrics: []
                systems: []
                tools:
                  - Go
                keywords:
                  - data
                role_family_tags:
                  - data
                trust_level: partial
                source_notes: []
                resume_ready: false
                interview_ready: false
                confidentiality: public_safe
                notes:
                bullet_candidate:
                ---
                text
                """,
            )

            output = query.run(
                vault_path=vault_path,
                company="ExampleCo",
                tool="python",
                role_family_tag="platform",
                resume_ready=True,
                output_format="json",
                limit=5,
            )
            payload = json.loads(output)

            self.assertEqual(len(payload["records"]), 1)
            self.assertEqual(payload["records"][0]["id"], "REC-001")
            self.assertEqual(payload["records"][0]["tools"], ["Python"])

    def test_query_markdown_handles_empty_results(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            vault_path = Path(temp_dir)
            output = query.run(vault_path=vault_path, keyword="missing", output_format="markdown")
            self.assertIn("records: 0", output)


if __name__ == "__main__":
    unittest.main()
