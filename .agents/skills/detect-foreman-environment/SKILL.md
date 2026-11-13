---
name: detect-foreman-environment
description: Determine whether this Katello/Foreman dev box is containerized (foremanctl/quadlet, services in podman) or non-containerized (foreman-installer, services as host RPMs). Use before running any command that differs between the two setups.
---

Katello dev boxes come in two flavors:
- **containerized** — provisioned by `foremanctl` on a quadlet VM. Pulp, Candlepin, PostgreSQL, and Valkey run as rootful podman containers.
- **non-containerized** — provisioned by `foreman-installer` (historically via forklift). The same services run as RPM-installed host systemd services. This install method is deprecated.

## Execution Instructions
Run the following to determine your environment type:
```bash
if test -f /etc/containers/systemd/pulp-api.container; then
  echo containerized
else
  echo non-containerized
fi
```
