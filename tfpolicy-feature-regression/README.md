# tfpolicy Feature Regression Set

A single policy set that exercises **every feature of the tfpolicy policy language and CLI**, one feature per `.policy.hcl` file. The paired `.policytest.hcl` suite is the regression harness — a failure in any single file points directly at the language or CLI feature that regressed.

## Layout

```
tfpolicy-feature-regression/
├── policies/                       # flat — tfpolicy validate does not recurse
│   ├── feature_<category>_<feature>.policy.hcl
│   ├── feature_<category>_<feature>.policytest.hcl
│   ├── feature_test_input_varfile.policyvars.hcl   # varfile used with --input-file
│   └── plugin/                     # sample plugin binary + source
│       ├── main.go, go.mod, go.sum
│       ├── plugin_binary
│       └── README.md
├── fsbp/                           # sibling FSBP policy set (see fsbp/README.md)
├── modules/example/                # target for module_policy tests
├── main.tf, variables.tf,          # real Terraform config for end-to-end runs
├── providers.tf, terraform.tfvars
└── README.md
```

## Naming convention

```
feature_<category>_<feature>[_<variant>].policy.hcl
```

Closed category set: `toplevel`, `target`, `metaarg`, `enforce`, `result`, `expr`, `func`, `input`, `local`, `plugin`, `test`, `state`, `preplan`. snake_case throughout. The basename is the test-case ID that appears in CI failures.

### Pre-plan-safe contract (`feature_preplan_*`)

`feature_preplan_*` files **must read only `meta` (and optionally `prior_attrs`)** — no `attrs.*` references anywhere. Pre-plan evaluation rejects attrs as hard errors (`terraform-policy-core/policy/policy_opts.go`), so this category is the regression anchor for "policies that remain valid when invoked by a pre-plan caller." There is no per-policy HCL declaration of stage — the contract is enforced by review + the suite's grep-able naming.

## CLI flag coverage matrix

The `tfpolicy` CLI exposes three commands and a handful of flags; this set exercises every one:

| Surface | Flag / construct | Where exercised |
|---|---|---|
| `tfpolicy validate` | `--policies <dir>` | every file in `policies/` |
| `tfpolicy test` | `--policies <dir>` | every file in `policies/` |
| `tfpolicy test` | `--tests <dir>` | every `.policytest.hcl` in `policies/` |
| `tfpolicy test` | `--input name=value` | resolves through any `feature_input_*` policy |
| `tfpolicy test` | `--input-file <varfile>` | `feature_test_input_varfile.policyvars.hcl` |
| `tfpolicy version` | (no flags) | not in the suite — call directly |
| File ext | `*.policy.hcl` / `*.policytest.hcl` | every paired feature |
| File ext | `*.policyvars.hcl` | `feature_test_input_varfile.policyvars.hcl` |

## Running

From this folder:

```bash
# 1. Structural validation (parsing, references, types)
tfpolicy validate --policies ./policies

# 2. Feature-by-feature regression
tfpolicy test --policies ./policies --tests ./policies

# 3. Varfile-driven inputs
tfpolicy test \
  --policies ./policies \
  --tests    ./policies \
  --input-file ./policies/feature_test_input_varfile.policyvars.hcl

# 4. Single-input override via flag
tfpolicy test --policies ./policies --tests ./policies --input required_prefix=regression-

# 5. End-to-end against a real plan (policy plugin must be loaded)
terraform init
terraform plan -out=tfplan
```

## Language-feature coverage matrix

| Category | Files | What is covered |
|---|---|---|
| `toplevel` | `feature_toplevel_*` | `policy {}`, `input {}`, `locals {}`, `plugins {}` top-level blocks |
| `target` | `feature_target_*` | `resource_policy`, wildcard `*`, `provider_policy`, `module_policy`, `data_source_policy` |
| `metaarg` | `feature_metaarg_*` | `filter`, `enforcement_level` (advisory / mandatory / mandatory_overridable), `operations` (create / update / delete) |
| `enforce` | `feature_enforce_*` | single + multiple `enforce` blocks, `error_message`, `info_message` |
| `result` | `feature_result_*` | Allow, Deny, Unknown, Error outcomes |
| `expr` | `feature_expr_*` | `attrs`, `prior_attrs`, `meta`, `local`, `input` references; splat; for-list; for-map; ternary; type coercion; null & unknown handling |
| `func` | `feature_func_core_*` | every `core::` built-in: `join`, `split`, `contains`, `startswith`, `endswith`, `replace`, `length`, `keys`, `values`, `flatten`, `distinct`, `reverse`, `type`, `try`, `has_key`, `min`, `max`, `sum`, `semver`, `semverconstraint`, `getresources`, `getdatasource`, `jsonencode`, `jsondecode` |
| `func` (plugin) | `feature_func_plugin_*` | `plugin::<name>::<fn>` — basic call, multi-arg call, `is_valid_cidr`, `cidr_contains_ip`, `sha256_hex`, `is_kebab_case`, `count_substring` |
| `input` | `feature_input_*` | type variants: `string`, `number`, `bool`, `list`, `map`, `object`; plus `default`, `sensitive`; cross-file module scope |
| `state` | `feature_state_*` | `prior_attrs` on `update` and `delete` |
| `local` | `feature_local_*` | file-scope locals + cross-file module-level locals |
| `test` | `feature_test_*` (no policy pair) | `expect_failure` (true/false), mocked `resource`/`provider`/`data`/`module`/`plugins`, `skip`, `terraform_config`, test-level `locals`, **inputs block in test**, **plugin call inside test attrs**, **cross-resource reference**, **varfile (`--input-file`)** |
| `preplan` | `feature_preplan_*` | pre-plan-safe contract — provider/module policies that read only `meta` (no `attrs`): provider type, provider version, module source allowlist, module version constraint |

## Authoring rules

1. **One policy file = one language feature.** Dependencies on other features belong in the test fixture, not the policy body.
2. **Every policy ships with both directions** — at least one `expect_failure = false` and one `expect_failure = true` case (where the feature has a failure mode).
3. **Test-framework-only features** (`feature_test_*` without a policy pair) target the shared `feature_target_resource.policy.hcl` so the focus stays on the test feature itself.
4. **New language or CLI feature → new row in the matrix above → new file pair.** No changes to existing files.

## CI

GitHub Actions workflow at `.github/workflows/policy-regression.yml` runs `tfpolicy validate` and `tfpolicy test` on every PR touching `tfpolicy-feature-regression/**` and on every push to `main`. Self-hosted ubuntu runners; auth via Vault → GitHub OAuth (same pattern as `terraform-policy-cli`'s `checks.yml`).

A richer per-policy report is intentionally deferred until `tfpolicy` exposes structured output (`--json` or `--format=junit`) — parsing the CLI's pretty-printed text isn't a maintainable foundation.

v1 is advisory (`continue-on-error: true`). After one clean week, delete that line and ask the repo admin to promote `policy-regression / tfpolicy regression suite` to a required check on `main`.

## Status

Skeletons are in place for every feature. Bodies use minimal but valid HCL that should parse; runtime semantics for plugin-backed tests require the binary at `policies/plugin/plugin_binary` — rebuild with `go build -o plugin_binary .` from inside `policies/plugin/` after pulling. Adjust each file's expressions and fixtures as the language evolves.
