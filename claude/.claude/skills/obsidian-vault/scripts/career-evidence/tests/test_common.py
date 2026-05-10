from __future__ import annotations

import importlib.util
import json
import os
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).resolve().parent.parent / "common.py"
SPEC = importlib.util.spec_from_file_location("career_evidence_common", MODULE_PATH)
common = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
sys.modules[SPEC.name] = common
SPEC.loader.exec_module(common)


def write_note(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(textwrap.dedent(content).strip() + "\n", encoding="utf-8")


class CommonTests(unittest.TestCase):
    def test_resolve_vault_path_prefers_argument_then_env_then_defaults(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            explicit = Path(temp_dir) / "explicit"
            explicit.mkdir()
            env_path = Path(temp_dir) / "env"
            env_path.mkdir()

            previous = os.environ.get("OBSIDIAN_VAULT_PATH")
            os.environ["OBSIDIAN_VAULT_PATH"] = str(env_path)
            try:
                self.assertEqual(common.resolve_vault_path(str(explicit)), explicit)
                self.assertEqual(common.resolve_vault_path(None), env_path)
            finally:
                if previous is None:
                    os.environ.pop("OBSIDIAN_VAULT_PATH", None)
                else:
                    os.environ["OBSIDIAN_VAULT_PATH"] = previous

    def test_parse_frontmatter_supports_lists_booleans_blank_values_and_strings(self) -> None:
        text = """
        ---
        type: evidence
        id: TEST-001
        theme:
          - platform
          - backend
        start_period:
        end_period: 2024-06
        is_current: false
        metrics: []
        notes: "quoted string"
        resume_ready: true
        source_notes:
          - "[[Areas/Career/source-a]]"
        ---

        body text
        """

        frontmatter, body = common.parse_frontmatter(text)

        self.assertEqual(frontmatter["type"], "evidence")
        self.assertEqual(frontmatter["id"], "TEST-001")
        self.assertEqual(frontmatter["theme"], ["platform", "backend"])
        self.assertEqual(frontmatter["start_period"], "")
        self.assertEqual(frontmatter["end_period"], "2024-06")
        self.assertIs(frontmatter["is_current"], False)
        self.assertEqual(frontmatter["metrics"], [])
        self.assertEqual(frontmatter["notes"], "quoted string")
        self.assertIs(frontmatter["resume_ready"], True)
        self.assertEqual(frontmatter["source_notes"], ["[[Areas/Career/source-a]]"])
        self.assertEqual(body.strip(), "body text")

    def test_load_records_and_follow_up_items_normalize_content(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            vault_path = Path(temp_dir)
            write_note(
                vault_path / "Areas/Career/Evidence/Records/Company/TEST-001-note.md",
                """
                ---
                type: evidence
                id: TEST-001
                company: ExampleCo
                experience_type: paid_work
                role: Platform Engineer
                theme:
                  - platform
                start_period: 2024-01
                end_period:
                is_current: true
                problem: Slow deploys
                action: Owned the deployment workflow
                outcome: Improved reliability
                metrics:
                  - 42% faster deploys
                systems:
                  - CI
                tools:
                  - Python
                keywords:
                  - deployments
                role_family_tags:
                  - platform
                trust_level: verified
                source_notes:
                  - "[[source]]"
                resume_ready: true
                interview_ready: true
                confidentiality: public_safe
                notes: Keep concise
                bullet_candidate: Improved deploy reliability.
                ---

                ## summary
                ownership and delivery
                """,
            )
            write_note(
                vault_path / "Areas/Career/Evidence/follow-up.md",
                """
                # Evidence follow-up

                - unresolved item
                - [ ] still open
                - [x] done already
                """,
            )

            records = common.load_records(vault_path)
            follow_ups = common.load_follow_up_items(vault_path)

            self.assertEqual(len(records), 1)
            record = records[0]
            self.assertEqual(record.id, "TEST-001")
            self.assertEqual(record.company, "ExampleCo")
            self.assertEqual(record.metrics, ["42% faster deploys"])
            self.assertEqual(record.path.as_posix().split("/Areas/Career/")[1], "Evidence/Records/Company/TEST-001-note.md")
            self.assertIn("ownership", record.search_text)

            self.assertEqual([item.text for item in follow_ups if not item.resolved], ["unresolved item", "still open"])

    def test_extract_keywords_date_score_and_json_output_are_deterministic(self) -> None:
        keywords = common.extract_keywords("Python platform ownership and Python delivery")
        self.assertIn("python", keywords)
        self.assertIn("platform", keywords)
        self.assertEqual(common.date_score("2024-06"), 2024 * 12 + 6)
        self.assertEqual(common.date_score(""), 0)

        payload = {"b": 2, "a": [2, 1]}
        rendered = common.to_json(payload)
        self.assertEqual(json.loads(rendered), payload)
        self.assertEqual(rendered.splitlines()[0], "{")


if __name__ == "__main__":
    unittest.main()
