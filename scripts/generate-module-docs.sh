#!/usr/bin/env bash
set -euo pipefail

# Generates a README.md per module using terraform-docs.
# Idempotent - run on every PR via .github/workflows/docs.yml.

if ! command -v terraform-docs >/dev/null 2>&1; then
  echo "Error: terraform-docs not installed."
  echo "Install with: brew install terraform-docs (macOS) or"
  echo "             curl -sSLo terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/latest/download/terraform-docs-v0.18.0-Linux-amd64.tar.gz"
  exit 1
fi

cd "$(dirname "$0")/.."

for d in modules/*/; do
  # Skip template
  [ "$d" = "modules/_template/" ] && continue
  echo "Generating $d/README.md"
  terraform-docs markdown table \
    --config .terraform-docs.yaml \
    --output-file README.md \
    --output-mode replace \
    "$d"
done

echo "Done. terraform fmt -recursive may follow if any module READMEs reference embedded HCL."
