#!/usr/bin/env bash

VM_ID="runner-$CUSTOM_ENV_CI_RUNNER_ID-project-$CUSTOM_ENV_CI_PROJECT_ID-concurrent-$CUSTOM_ENV_CI_CONCURRENT_PROJECT_ID-job-$CUSTOM_ENV_CI_JOB_ID"
VM_IMAGE_FALLBACK="${CUSTOM_ENV_TART_IMAGE:-ghcr.io/cirruslabs/macos-monterey-xcode:14}" # this is left for compatibility with previous versions
VM_IMAGE="${CUSTOM_ENV_CI_JOB_IMAGE:-$VM_IMAGE_FALLBACK}"

VM_USER="admin"
VM_PASSWORD="admin"

# Load SSH keys from the host.
ssh-add

_get_vm_ip() {
    tart ip "$VM_ID" --wait 30 || true
}

_get_vm_pid() {
    ps -A | grep -m1 "tart run $VM_ID" | awk '{print $1}'
}

_ssh() {
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/$VM_ID "$VM_USER"@"$VM_IP" "/bin/zsh --login -c '$@'" >/dev/null 
}
