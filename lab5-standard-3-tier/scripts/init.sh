#!/usr/bin/env bash
set -e

# Script to initialize Terraform environments on Linux/MacOS
if [ -z "$1" ]; then
  echo "Usage: ./init.sh <dev|staging|prod>"
  exit 1
fi

ENV=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="$SCRIPT_DIR/../environments/$ENV"

if [ ! -d "$ENV_DIR" ]; then
  echo "Error: Environment '$ENV' not found at $ENV_DIR"
  exit 1
fi

echo "Initializing environment: $ENV..."
terraform -chdir="$ENV_DIR" init -backend-config="backend.hcl"
