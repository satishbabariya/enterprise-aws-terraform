# Onboarding

## Prerequisites

- Terraform >= 1.9
- AWS CLI configured with management account admin credentials
- GitHub repo with the org/repo name updated in all `terraform.tfvars` files

## Initial Deployment Sequence

### 1. Bootstrap state infrastructure (run once)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# Edit with your org_name, region, repo_url, management_account_id
terraform init
terraform apply
```

Uncomment the backend block in `bootstrap/backend.tf` and run:

```bash
terraform init -migrate-state
```

### 2. Update placeholders

In every `medium/accounts/*/terraform.tfvars` (or `large/accounts/*/terraform.tfvars`):
- Replace `acme` with your `org_name`
- Replace 12-digit placeholder account IDs (`111111111111`, etc.) with your real account IDs
- Replace `o-PLACEHOLDER` with your real Organization ID
- Replace `ssoins-PLACEHOLDER` and `d-PLACEHOLDER` with your IAM Identity Center instance values from `aws sso-admin list-instances`

### 3. Deploy accounts in order

```
management -> log-archive -> security -> network -> shared-services -> workloads
```

For each account:

```bash
cd medium/accounts/<account-name>
terraform init
terraform plan
terraform apply
```

### 4. Wire CI/CD

After `management` is applied:
- Set GitHub repo variable `MANAGEMENT_ACCOUNT_ID` to your management account ID
- Push a PR to validate the plan workflow runs

`MANAGEMENT_ACCOUNT_ID` is shared by the Plan, Apply and Drift Detection
workflows. Each one assumes
`arn:aws:iam::<MANAGEMENT_ACCOUNT_ID>:role/acme-management-terraform-ci` through
GitHub OIDC, so that role (created by the `management` account root) must
exist and trust this repository.

The nightly Drift Detection workflow checks for the variable first. Until it is
set, the drift job is skipped and the run finishes successfully with the notice
"drift detection skipped: no AWS role configured". Once it is set, every
account root is planned nightly: drift opens a `terraform-drift` issue, and a
plan error fails the run.

## Adding a New Workload Account

```bash
./scripts/new-account.sh \
  -s medium \
  -n team-acme \
  -e prod \
  -i 123456789012 \
  -c 10.5.0.0/16
```

Then edit `medium/accounts/team-acme/main.tf` to add the desired modules.

## Common Operations

| Task                         | Command                                          |
|------------------------------|--------------------------------------------------|
| Validate a single account    | `cd <dir> && terraform validate`                 |
| Plan a single account        | `cd <dir> && terraform plan`                     |
| Apply a single account       | `cd <dir> && terraform apply`                    |
| Format all files             | `terraform fmt -recursive`                       |
| Run pre-commit checks        | `pre-commit run --all-files`                     |
| Trigger drift detection      | GitHub Actions -> Drift Detection -> Run workflow|

## Customization Checklist

- [ ] Update `org_name` (currently `acme`) in all tfvars and locals
- [ ] Update `repo_url`, `github_org`, `github_repo` in all tfvars
- [ ] Update placeholder AWS account IDs in tfvars
- [ ] Update `allowed_regions` in `medium/accounts/management/terraform.tfvars`
- [ ] Update SSO instance ARN and identity store ID after enabling Identity Center
- [ ] Add real budget notification emails in `modules/account-baseline` calls
- [ ] Review SCPs in `modules/scp-policies/main.tf` and adjust per your policy
