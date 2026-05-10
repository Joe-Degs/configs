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
gaps = load_module("gaps")


def write_note(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(textwrap.dedent(content).strip() + "\n", encoding="utf-8")


class GapsTests(unittest.TestCase):
    def test_gap_report_collects_followups_and_record_flags(self) -> None:
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
                role: Engineer
                theme:
                  - backend
                start_period:
                end_period:
                is_current: false
                problem: p
                action: a
                outcome: o
                metrics: []
                systems: []
                tools: []
                keywords: []
                role_family_tags:
                  - backend
                trust_level: partial
                source_notes: []
                resume_ready: false
                interview_ready: true
                confidentiality: public_safe
                notes:
                bullet_candidate:
                ---
                body
                """,
            )
            write_note(
                vault_path / "Areas/Career/Evidence/Records/A/REC-002.md",
                """
                ---
                type: evidence
                id: REC-002
                company: RiskyCo
                experience_type: project
                role: Engineer
                theme:
                  - backend
                start_period: 2024-01
                end_period: 2024-02
                is_current: false
                problem: p
                action: a
                outcome: o
                metrics: []
                systems: []
                tools: []
                keywords: []
                role_family_tags:
                  - backend
                trust_level: unsafe
                source_notes: []
                resume_ready: false
                interview_ready: false
                confidentiality: public_safe
                notes:
                bullet_candidate:
                ---
                body
                """,
            )
            write_note(
                vault_path / "Areas/Career/Evidence/follow-up.md",
                """
                # Evidence follow-up
                - open item
                - [x] finished
                """,
            )

            output = gaps.run(vault_path=vault_path, output_format="json")
            payload = json.loads(output)

            self.assertEqual(payload["counts"]["unresolved_follow_up_items"], 1)
            self.assertEqual([item["id"] for item in payload["partial_records"]], ["REC-001"])
            self.assertEqual([item["id"] for item in payload["unsafe_records"]], ["REC-002"])
            self.assertEqual(sorted(item["id"] for item in payload["missing_dates_records"]), ["REC-001"])

    def test_gap_markdown_handles_empty_vault(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            output = gaps.run(vault_path=Path(temp_dir), output_format="markdown")
            self.assertIn("unresolved_follow_up_items: 0", output)


if __name__ == "__main__":
    unittest.main()
