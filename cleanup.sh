#!/usr/bin/env bash

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base script.

set -o pipefail

# Destroy VM.
VM_PID=$(_get_vm_pid)
kill $VM_PID || true

# Delete VM disk.
tart delete "$VM_ID"
