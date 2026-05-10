# Evidence integration

`career-ops` should use the shared career-evidence scripts before doing broad vault scouting.

## shared script path

- `~/.config/opencode-profiles/golly/opencode/skills/obsidian-vault/scripts/career-evidence/`

## primary scripts

- `pack.py`: build ranked evidence packets for a role, keyword set, or JD
- `query.py`: narrow record lookup for targeted follow-up or inspection
- `gaps.py`: surface unresolved evidence gaps and weak spots

## usage rules

1. call `pack.py` first when building a fit summary, tailoring a live application, or preparing interview evidence
2. use `query.py` only when the packet is weak, incomplete, or needs targeted enrichment
3. use `gaps.py` when the user asks what is missing or when the packet surfaces obvious weakness
4. fall back to raw vault scouting only when the script layer cannot answer the question well enough

## packet contract

`pack.py` should be treated as the preferred machine source for `references/evidence-pack-schema.md`.

That means `career-ops` should translate script output into:

- fit summary
- keyword map
- selected work history
- selected projects
- strongest metrics
- gaps
- recommended next artifact

## do not do this

- do not rebuild evidence selection from scratch when a packet already exists
- do not ask the user to restate evidence that already lives in the vault or packet
- do not treat packet ranking as final truth, `career-ops` still owns judgment
