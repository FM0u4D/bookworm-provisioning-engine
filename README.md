# wormbook-provisioning-engine

A modular, deterministic, and idempotent provisioning framework for Debian-based systems, precisely destinated for bookworm (Debian 12).

This project provides a structured and reproducible approach to system initialization, designed for environments where consistency, reliability, and repeatability are critical. It is particularly suited for SOC labs, Proxmox templates, cloud-init workflows, and DevSecOps pipelines.

---

## Overview

Wormbook Provisioning Engine is built around a simple principle: provision once, reproduce infinitely.

The framework separates reusable logic from execution steps, allowing systems to be configured through clearly defined phases. Each phase performs a single responsibility such as system validation, package installation, service configuration, or security baseline setup.

Execution is orchestrated through a central script, ensuring strict ordering, controlled failure behavior, and full traceability.

---

## Key Features

Modular architecture  
Reusable logic is isolated in the `lib/` directory, while execution steps are defined in `phases/`. This separation ensures maintainability and scalability.

Idempotent execution  
All operations are safe to run multiple times. The engine avoids duplicate actions and unnecessary changes.

State-aware provisioning  
Each completed phase is recorded under `/var/lib/provision/state`. On re-execution, completed phases are automatically skipped.

Deterministic behavior  
Strict shell settings (`set -Eeuo pipefail`) ensure predictable execution and immediate failure on error.

Structured logging  
Clear and consistent logging provides visibility into each phase and operation.

Reusable and extensible  
Designed to be adapted for different environments without modifying core logic.

---

---

## Execution Flow

1. The orchestrator (`install.sh`) loads all core libraries.
2. Phases are executed sequentially in a predefined order.
3. After a phase completes successfully, its state is recorded.
4. On subsequent runs, completed phases are skipped automatically.

This ensures safe re-execution and recovery from interruptions.

---

## Idempotency Model

Each phase is designed to avoid unnecessary changes:

- Packages are installed only if missing
- Services are enabled only if required
- Files and directories are created only when absent
- Configuration is updated only when changes are needed

This guarantees consistent results across multiple executions.

---

## State Management

State files are stored in: `/var/lib/provision/state/`

Each phase creates a corresponding `.done` file upon successful completion.

Example:
`00-base-system.done`
`02-core-tools.done`

This mechanism allows the engine to resume execution without repeating completed work.

---

## Usage

Run the provisioning process:
chmod +x install.sh
sudo ./install.sh

Re-running the script is safe:
sudo ./install.sh


Completed phases will be skipped automatically.

---

## Customization

Manual packages can be defined in:
config/manual-packages.txt
Example:
htop
nmap
tcpdump


To extend the system, create a new phase in the `phases/` directory and register it in `install.sh`.

---

## Requirements

- Debian 12 (Bookworm)
- Root privileges
- Network connectivity with functional DNS

---

## Design Philosophy

This framework is built with a focus on:

- Determinism over convenience
- Simplicity over abstraction
- Explicit behavior over implicit automation
- Reusability across environments

It is intended as a foundation for building reliable infrastructure, not just a one-time setup script.

---

## License

MIT License

