# Sample policy plugin

Built artefact for the `plugin::sample::*` functions referenced by the policies in this directory (and reused by `../fsbp/` if any FSBP policies grow to need them).

Provides:

| Function | Signature | Notes |
|---|---|---|
| `echo(s)` | `string → string` | Identity; round-trip probe used by `feature_toplevel_plugin_block`, `feature_func_plugin_basic`. |
| `trim(s, prefix)` | `(string, string) → string` | Strips a prefix; used by `feature_func_plugin_with_args`. |
| `http_get(url)` | `string → string (JSON)` | HTTP GET wrapped as `{"message": …, "error": …}`. |
| `is_valid_cidr(cidr)` | `string → bool` | Validates CIDR notation; demo: `feature_func_plugin_is_valid_cidr`. |
| `cidr_contains_ip(cidr, ip)` | `(string, string) → bool` | Whether `ip` falls inside `cidr`; demo: `feature_func_plugin_cidr_contains_ip`. |
| `sha256_hex(s)` | `string → string` | Lowercase hex SHA-256 digest; demo: `feature_func_plugin_sha256_hex`. |
| `is_kebab_case(s)` | `string → bool` | Strict kebab-case match; demo: `feature_func_plugin_is_kebab_case`. |
| `count_substring(haystack, needle)` | `(string, string) → int` | Non-overlapping occurrences (returns 0 for empty needle); demo: `feature_func_plugin_count_substring`. |

## Build

```bash
# from this directory
go build -o plugin_binary .
```

The committed `plugin_binary` is built for **darwin/arm64**. Rebuild for your platform — the regression workflow builds linux/amd64 per-job.

## How policies reference it

Both `--policies` runs are scoped to the directory containing the policy files, and `tfpolicy` resolves plugin `source` paths relative to that directory:

```hcl
policy {
  plugins {
    sample = {
      source = "./plugin/plugin_binary"
    }
  }
}
```

So when this folder lives at `tfpolicy-feature-regression/policies/plugin/`, the matching policy in `tfpolicy-feature-regression/policies/feature_toplevel_plugin_block.policy.hcl` resolves the binary correctly.

Note: subdirectories under `--policies` are **not** scanned for `*.policy.hcl` / `*.policytest.hcl` files (the discovery walk is flat), so co-locating the plugin folder here does not pollute test discovery.

## Private module access

Depends on `github.com/hashicorp/terraform-policy-plugin-framework` (private). Before `go build`:

```bash
git config --global url."git@github.com:".insteadOf "https://github.com/"
export GOPRIVATE=github.com/hashicorp/*
```
