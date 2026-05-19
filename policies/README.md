# Policy-as-Code

Rego policies for [Open Policy Agent](https://www.openpolicyagent.org/) /
[Conftest](https://www.conftest.dev/) that run against `terraform plan` output
in CI to prevent non-compliant infrastructure from being applied.

## Policies

| File                       | Purpose                                                                    |
|----------------------------|----------------------------------------------------------------------------|
| `deny_public_s3.rego`      | Every S3 bucket must have full Block Public Access set                     |
| `require_encryption.rego`  | S3, EBS, RDS, DynamoDB must use encryption at rest                         |
| `require_tags.rego`        | Mandatory tags on storage / compute / IAM / KMS / messaging resources      |
| `no_iam_users.rego`        | Forbid IAM users + long-lived access keys + overly broad inline policies   |

## Running locally

```bash
brew install conftest
cd medium/accounts/management
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > plan.json
conftest test plan.json --policy ../../../policies/
```

## CI integration

`.github/workflows/policy-check.yml` runs Conftest on every account root's
plan output during PR validation. Failures block the merge.

## Adding a new policy

1. Create a `<rule_name>.rego` file under this directory using `package terraform`.
2. Write `deny[msg]` rules that return a human-readable message when violated.
3. Add a test fixture under `policies/tests/` if the rule is non-trivial.
4. Update this README's table.
5. Open a PR - the Conftest step will run your new rule against all in-flight plans.
