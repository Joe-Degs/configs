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
stats = load_module("stats")


def write_note(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(textwrap.dedent(content).strip() + "\n", encoding="utf-8")


class StatsTests(unittest.TestCase):
    def test_stats_return_grouped_counts(self) -> None:
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
                  - platform
                trust_level: verified
                source_notes: []
                resume_ready: true
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
                company: ExampleCo
                experience_type: project
                role: Engineer
                theme:
                  - backend
                start_period: 2023-01
                end_period: 2023-02
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
                interview_ready: false
                confidentiality: public_safe
                notes:
                bullet_candidate:
                ---
                body
                """,
            )

            output = stats.run(vault_path=vault_path, output_format="json")
            payload = json.loads(output)

            self.assertEqual(payload["total_records"], 2)
            self.assertEqual(payload["by_trust_level"]["verified"], 1)
            self.assertEqual(payload["by_company"]["ExampleCo"], 2)
            self.assertEqual(payload["by_role_family_tag"]["backend"], 2)
            self.assertEqual(payload["by_resume_ready"]["true"], 1)

    def test_stats_markdown_handles_empty_results(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            output = stats.run(vault_path=Path(temp_dir), output_format="markdown")
            self.assertIn("total_records: 0", output)


if __name__ == "__main__":
    unittest.main()
