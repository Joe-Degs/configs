# Evidence pack schema

Use this schema when handing work to `resume-maker`.

```text
company:
role:
application_stage:
target_artifact:
target_context_available:

jd_keywords:
-

selected_work_history:
- source:
  source_path:
  recency:
  confidence:
  summary:
  proof_excerpt:
  metrics:
  keywords:

selected_projects:
- source:
  source_path:
  recency:
  confidence:
  summary:
  proof_excerpt:
  metrics:
  keywords:

selected_tasks_or_notes:
- source:
  source_path:
  recency:
  confidence:
  summary:
  proof_excerpt:
  proof_value:

strongest_metrics:
-

gaps:
-

tone_constraints:
-

save_back_preference:
```

## notes

- keep the packet concise
- include source paths for every item
- include only the strongest evidence
- identify gaps honestly so the writer can handle them cleanly
- if target context is missing, say so plainly instead of guessing
