# FSBP Policy Set

A curated set of **15 AWS Foundational Security Best Practices (FSBP)** controls, designed so each policy genuinely **combines multiple tfpolicy language features**. This complements the sibling `../policies/` set which isolates one feature per file.

## Layout

```
fsbp/                                         ← the policy set (flat, no subdirs)
├── fsbp_<service>_<id>_<slug>.policy.hcl
└── fsbp_<service>_<id>_<slug>.policytest.hcl
```

`tfpolicy validate` does not recurse, so `fsbp/` is its own `--policies` target.

## Running

```bash
# from tfpolicy-feature-regression/
tfpolicy validate --policies ./fsbp
tfpolicy test     --policies ./fsbp --tests ./fsbp

# end-to-end against real Terraform — the parent main.tf is shared
terraform init
terraform plan -out=tfplan
```

## Control map

| # | File | FSBP ID | Intent | Features combined |
|---|---|---|---|---|
| 1 | `fsbp_s3_1_block_public_access` | S3.1 | Every bucket has a BPA resource with all 4 flags true | `locals` + `core::getresources` + `core::length` + multiple `enforce` |
| 2 | `fsbp_s3_5_ssl_only_bucket_policy` | S3.5 | Bucket policy denies non-TLS access | `core::jsondecode` + for-expr + `core::contains` |
| 3 | `fsbp_s3_8_block_public_access_bucket_level` | S3.8 | BPA resource itself has all 4 flags true | multiple `enforce` + `core::try` + null-handling |
| 4 | `fsbp_s3_14_versioning_enabled` | S3.14 | Sibling versioning resource = Enabled | `locals` + ternary + `meta` + `core::getresources` |
| 5 | `fsbp_ec2_2_default_sg_no_traffic` | EC2.2 | Default SG has no rules | `filter` + for-expr + splat + `core::length` |
| 6 | `fsbp_ec2_9_no_public_ipv4` | EC2.9 | No public IPv4 unless allowlisted | `input` + ternary + null-handling + `core::contains` |
| 7 | `fsbp_ec2_13_no_ssh_from_anywhere` | EC2.13 | No 0.0.0.0/0 → 22/3389 | for-expr + `core::contains` + multiple `enforce` |
| 8 | `fsbp_iam_1_no_admin_wildcard` | IAM.1 | No `Action:"*"` + `Resource:"*"` Allow | `core::jsondecode` + nested for-expr + `core::flatten` |
| 9 | `fsbp_iam_21_no_wildcard_actions_customer_policies` | IAM.21 | No `service:*` actions | `core::jsondecode` + nested for-expr + `core::endswith` |
| 10 | `fsbp_rds_2_no_public_access` | RDS.2 | `publicly_accessible = false` | multiple `enforce` + `meta` + `locals` |
| 11 | `fsbp_rds_3_encryption_at_rest` | RDS.3 | `storage_encrypted = true` + KMS resolves | `input` + `core::getresources` + null-handling |
| 12 | `fsbp_rds_13_minor_version_upgrades` | RDS.13 | Auto upgrade OR engine ≥ 15.0.0 | `core::semverconstraint` + ternary |
| 13 | `fsbp_kms_4_rotation_enabled` | KMS.4 | Symmetric keys rotate | `locals` + ternary + `core::contains` (asymmetric exemption) |
| 14 | `fsbp_cloudtrail_1_multi_region_trail` | CloudTrail.1 | At least one multi-region trail | `provider_policy` + `core::getresources` + for-expr |
| 15 | `fsbp_cloudtrail_2_encryption_at_rest` | CloudTrail.2 | Trail kms_key_id resolves to a real key | `core::getresources` + multiple `enforce` + null-handling |

## Authoring rules

1. **One file = one FSBP control.** When a control needs to combine multiple resource types, use `core::getresources` from a single target — don't fan out across files.
2. **Header comment on every `.policy.hcl`** lists the FSBP ID, plain-English intent, and the language-feature combo. That comment is the source of truth for the table above.
3. **Tests assert both directions** — at least one `expect_failure = false` and one `expect_failure = true` case.
4. **Mocked sibling resources** (`aws_kms_key`, `aws_s3_bucket_public_access_block`, `aws_s3_bucket_versioning`) use `skip = true` so they're visible to `core::getresources` but don't trigger their own policies during the test run.
5. **Parent `main.tf` must have at least one matching resource per policy** — when adding a new FSBP control, extend `../main.tf` first so `terraform plan` exercises the rule end-to-end.

## Relationship to the feature-regression set

| Set | Purpose | When it breaks |
|---|---|---|
| `../policies/` | Each file isolates one language feature | A specific language feature regressed |
| `./` (this set) | Each file combines multiple features for a real use case | A combination broke, or a control-level intent regressed even if individual features still work |

Both sets share the same parent `main.tf`, `providers.tf`, `variables.tf`, `terraform.tfvars`, and `modules/`.
