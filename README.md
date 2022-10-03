# Run GitLab Runner jobs with macOS virtualization

## What is this?
A set of configuration files which allows gitlab-runner to make use of the macOS virtualization framework.
Under the hood, these scripts use the [tart](https://github.com/cirruslabs/tart) commandline tool to provision VMs for jobs.
The macOS virtualization framework allows running two macOS virtual machines in parallel.

## Installation
Clone this repository onto your build machine and register a `custom` gitlab-runner to your instance. 
You need to adjust the paths in `prepare_exec`, `run_exec` and `cleanup_exec` which can also be found in `gitlab-runner-example-config.toml`.

Install dependencies: `brew install gitlab-runner daemonize tart`.

## Configurations
- `TART_IMAGE`: Choose a different tart image, e.g. from https://github.com/orgs/cirruslabs/packages?tab=packages&q=macos. The current default is `ghcr.io/cirruslabs/macos-monterey-xcode:14`.
