#!/usr/bin/env bash

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base script.

set -eo pipefail

# trap any error, and mark it as a system failure.
trap "exit $SYSTEM_FAILURE_EXIT_CODE" ERR

# Install the VM
tart clone "$VM_IMAGE" "$VM_ID"

# Update VM configuration
tart set "$VM_ID" --cpu 4 --memory 8192

# Run the VM in background
daemonize $(brew --prefix)/bin/tart run "$VM_ID" --no-graphics

# Wait for VM to get IP
echo 'Waiting for VM to get IP'
VM_IP=$(_get_vm_ip)

if [ -n "$VM_IP" ]; then
    echo "VM got IP: $VM_IP"
else
    echo 'Waited 30 seconds for VM to start, exiting...'
    # Inform GitLab Runner that this is a system failure, so it
    # should be retried.
    exit "$SYSTEM_FAILURE_EXIT_CODE"
fi

# Wait for ssh to become available
echo "Waiting for sshd to be available"
for i in $(seq 1 30); do
    if ${currentDir}/install-ssh-key.sh "$VM_IP" "$VM_USER" "$VM_PASSWORD" >/dev/null 2>/dev/null; then
        break
    fi

    if [ "$i" == "30" ]; then
        echo 'Waited 30 seconds for sshd to start, exiting...'
        # Inform GitLab Runner that this is a system failure, so it
        # should be retried.
        exit "$SYSTEM_FAILURE_EXIT_CODE"
    fi

    sleep 1
done

echo "Updating hostname"
_ssh "sudo scutil --set HostName $VM_ID && sudo scutil --set ComputerName $VM_ID && sudo scutil --set LocalHostName $VM_ID && sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $VM_ID"

echo "Updating timezone to GMT"
_ssh "sudo systemsetup -settimezone GMT"

echo "Installing gitlab-runner for artifact uploads"
_ssh "brew install gitlab-runner"
