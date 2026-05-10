# Evidence packet usage

`resume-maker` should prefer structured evidence packets over raw vault scouting.

## preferred input order

1. packet from `career-ops`, usually produced from `pack.py`
2. targeted `query.py` output for narrow fallback lookups
3. current application note
4. direct evidence notes only when the packet is missing or weak

## writing rules for packets

- treat `selected_work_history`, `selected_projects`, and `selected_tasks_or_notes` as the primary evidence pool
- use `strongest_metrics` as a quick shortlist, but verify the final metric against the selected entry's `source_path`, `proof_excerpt`, and per-entry `metrics` before writing
- handle `gaps` honestly, do not paper over them
- use `source_path` and `proof_excerpt` when checking whether a claim is safe to write
- use `proof_value` from `selected_tasks_or_notes` when the note entry is useful supporting context rather than a direct resume bullet source

## do not do this

- do not re-rank the whole vault when a good packet already exists
- do not promote `partial` or non-`resume_ready` evidence into polished writing unless the user explicitly asks and the uncertainty is disclosed
- do not ask the user to restate evidence that is already present in the packet
