plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

# Disabled rules with rationale:

# Module libraries legitimately declare variables that aren't referenced in
# every code path (forward-compat, reserved for future features, passthrough
# wiring that's optional). Removing them would be a breaking interface change.
# We rely on `terraform_documented_variables` (above) to ensure every variable
# has a clear description instead.
rule "terraform_unused_declarations" {
  enabled = false
}
