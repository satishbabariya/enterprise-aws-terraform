## Summary

<!-- 1-3 bullets describing what changed and why. -->

## Type of change

- [ ] New module
- [ ] Module update (existing behavior preserved)
- [ ] Account/deployment change (medium or large)
- [ ] CI/CD workflow change
- [ ] Documentation
- [ ] Security/compliance fix
- [ ] Breaking change

## Affected accounts

<!-- Which account roots will run a plan/apply for this PR? -->

- [ ] management
- [ ] log-archive
- [ ] security
- [ ] network
- [ ] shared-services
- [ ] prod / staging / dev / sandbox
- [ ] None (module-only)

## Compliance impact

<!-- Does this change affect any control in docs/compliance-matrix.md? -->

- [ ] No compliance controls affected
- [ ] Strengthens an existing control (describe below)
- [ ] Weakens an existing control (requires explicit approval - explain why)
- [ ] Adds a new control

## Test plan

- [ ] `terraform fmt -recursive` passes
- [ ] `terraform validate` passes in every affected root
- [ ] Manually reviewed plan output for unexpected destroy/replace
- [ ] If touching SCPs: tested the policy logic against a sandbox account
- [ ] If touching IAM: ran the policy through IAM Access Analyzer

## Rollback plan

<!-- How do we undo this if something breaks in production? -->
