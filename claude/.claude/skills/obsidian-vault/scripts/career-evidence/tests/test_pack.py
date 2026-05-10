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
pack = load_module("pack")


def write_note(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(textwrap.dedent(content).strip() + "\n", encoding="utf-8")


class PackTests(unittest.TestCase):
    def test_pack_ranks_classifies_and_reports_gaps(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            vault_path = Path(temp_dir)
            write_note(
                vault_path / "Areas/Career/Evidence/Records/Work/REC-001.md",
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
                end_period: 2024-08
                is_current: false
                problem: noisy delivery
                action: owned python deployment automation and led the migration
                outcome: cut failures and improved speed
                metrics:
                  - 40% faster deploys
                systems:
                  - CI
                tools:
                  - Python
                  - AWS
                keywords:
                  - python
                  - deployment
                role_family_tags:
                  - platform
                  - cloud
                trust_level: verified
                source_notes:
                  - "[[note]]"
                resume_ready: true
                interview_ready: true
                confidentiality: public_safe
                notes: strong record
                bullet_candidate: Improved deploys.
                ---
                ownership and accountability
                """,
            )
            write_note(
                vault_path / "Areas/Career/Evidence/Records/Projects/REC-002.md",
                """
                ---
                type: evidence
                id: REC-002
                company: ExampleCo Labs
                experience_type: project
                role: Builder
                theme:
                  - tooling
                start_period: 2023-01
                end_period: 2023-06
                is_current: false
                problem: need tooling
                action: built a python tool
                outcome: easier work
                metrics: []
                systems: []
                tools:
                  - Python
                keywords:
                  - python
                role_family_tags:
                  - developer_tools
                trust_level: confirmed_by_you
                source_notes:
                  - "[[note]]"
                resume_ready: true
                interview_ready: true
                confidentiality: public_safe
                notes:
                bullet_candidate: Built a tool.
                ---
                body
                """,
            )
            write_note(
                vault_path / "Areas/Career/Evidence/Records/Notes/REC-003.md",
                """
                ---
                type: evidence
                id: REC-003
                company: Supporting Note
                experience_type: note
                role: Context Note
                theme:
                  - support
                start_period: 2024-03
                end_period: 2024-03
                is_current: false
                problem: needed context
                action: captured a note about rollout support
                outcome: provided supporting detail
                metrics: []
                systems: []
                tools: []
                keywords:
                  - cloud
                role_family_tags:
                  - cloud
                trust_level: verified
                source_notes:
                  - "[[note]]"
                resume_ready: false
                interview_ready: false
                confidentiality: public_safe
                notes:
                bullet_candidate: Supporting note.
                ---
                body
                """,
            )
            write_note(
                vault_path / "Areas/Career/Evidence/follow-up.md",
                """
                # Evidence follow-up
                - need more direct kubernetes evidence
                """,
            )

            output = pack.run(
                vault_path=vault_path,
                role="Senior Platform Engineer",
                company="TargetCo",
                application_stage="interview",
                keywords=["python", "deployment", "ownership"],
                jd_text="Need ownership, python, and cloud delivery experience.",
                limit=5,
                output_format="json",
            )
            payload = json.loads(output)

            self.assertEqual(payload["company"], "TargetCo")
            self.assertEqual(payload["application_stage"], "interview")
            self.assertEqual(payload["selected_work_history"][0]["source"], "REC-001")
            self.assertEqual(payload["selected_projects"][0]["source"], "REC-002")
            self.assertEqual(payload["selected_tasks_or_notes"][0]["source"], "REC-003")
            self.assertTrue(payload["selected_work_history"][0]["resume_ready"])
            self.assertTrue(payload["selected_projects"][0]["resume_ready"])
            self.assertIn("source_path", payload["selected_work_history"][0])
            self.assertIn("recency", payload["selected_work_history"][0])
            self.assertIn("confidence", payload["selected_work_history"][0])
            self.assertIn("proof_excerpt", payload["selected_work_history"][0])
            self.assertIn("metrics", payload["selected_work_history"][0])
            self.assertIn("keywords", payload["selected_work_history"][0])
            self.assertIn("proof_value", payload["selected_tasks_or_notes"][0])
            self.assertIn("40% faster deploys", payload["strongest_metrics"])
            self.assertTrue(any("kubernetes" in gap for gap in payload["gaps"]))
            self.assertFalse(any("targetco" in gap for gap in payload["gaps"]))

    def test_pack_preserves_project_results_when_work_history_dominates_limit(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            vault_path = Path(temp_dir)
            for index in range(3):
                write_note(
                    vault_path / f"Areas/Career/Evidence/Records/Work/REC-W{index}.md",
                    f"""
                    ---
                    type: evidence
                    id: REC-W{index}
                    company: ExampleCo
                    experience_type: paid_work
                    role: Platform Engineer
                    theme:
                      - platform
                    start_period: 2024-0{index + 1}
                    end_period: 2024-0{index + 2}
                    is_current: false
                    problem: delivery drift
                    action: built python platform automation {index}
                    outcome: improved delivery
                    metrics:
                      - {index + 1}% improvement
                    systems: []
                    tools:
                      - Python
                    keywords:
                      - python
                      - platform
                    role_family_tags:
                      - platform
                    trust_level: verified
                    source_notes:
                      - "[[note]]"
                    resume_ready: true
                    interview_ready: true
                    confidentiality: public_safe
                    notes:
                    bullet_candidate: work bullet {index}
                    ---
                    body
                    """,
                )
            write_note(
                vault_path / "Areas/Career/Evidence/Records/Projects/REC-P1.md",
                """
                ---
                type: evidence
                id: REC-P1
                company: ProjectCo
                experience_type: project
                role: Tool Builder
                theme:
                  - developer_tools
                start_period: 2023-01
                end_period: 2023-02
                is_current: false
                problem: needed tooling
                action: built python developer tools
                outcome: improved developer workflow
                metrics: []
                systems: []
                tools:
                  - Python
                keywords:
                  - python
                  - tooling
                role_family_tags:
                  - developer_tools
                trust_level: verified
                source_notes:
                  - "[[note]]"
                resume_ready: true
                interview_ready: true
                confidentiality: public_safe
                notes:
                bullet_candidate: project bullet
                ---
                body
                """,
            )

            payload = json.loads(
                pack.run(
                    vault_path=vault_path,
                    role="Platform Engineer",
                    keywords=["python", "platform"],
                    limit=2,
                    output_format="json",
                )
            )

            self.assertEqual(len(payload["selected_work_history"]), 2)
            self.assertEqual(len(payload["selected_projects"]), 1)

    def test_pack_markdown_handles_empty_results(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            output = pack.run(vault_path=Path(temp_dir), output_format="markdown")
            self.assertIn("target_artifact: resume_support_packet", output)
            self.assertIn("selected_work_history:", output)
            self.assertIn("selected_tasks_or_notes:", output)
            self.assertIn("tone_constraints:", output)
            self.assertIn("save_back_preference: do_not_write", output)
            self.assertIn("- none", output)

    def test_pack_contract_includes_expected_top_level_fields(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            vault_path = Path(temp_dir)
            payload = json.loads(pack.run(vault_path=vault_path, role="Platform Engineer", output_format="json"))

            self.assertEqual(payload["target_artifact"], "resume_support_packet")
            self.assertTrue(payload["target_context_available"])
            self.assertEqual(payload["jd_keywords"], ["platform"])
            self.assertIn("selected_work_history", payload)
            self.assertIn("selected_projects", payload)
            self.assertIn("selected_tasks_or_notes", payload)
            self.assertEqual(payload["selected_tasks_or_notes"], [])
            self.assertEqual(payload["tone_constraints"], ["keep claims grounded", "preserve source-backed scope"])
            self.assertEqual(payload["save_back_preference"], "do_not_write")


if __name__ == "__main__":
    unittest.main()
