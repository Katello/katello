# Container Distribution Management

Docker/container repositories handle Pulp distributions differently from every
other content type. This document explains the behavior, why it is docker-only,
and the intended path toward unifying the logic.

## Why docker is different

For yum/deb/file/python/etc., the distribution `base_path` is derived from
`relative_path`, which is built from immutable labels and is not user-settable
through the API. Paths cannot collide or move by construction.

Docker is the only content type whose serving path is rendered from **mutable
user configuration**: the lifecycle environment's `registry_name_pattern` can
reference attributes like `repository.name` or `product.name`. That means
docker paths can move, collide with each other, or collide with non-docker
paths — which is why docker has validation and reconciliation the other types
do not need.

## Path validation: one engine, thin adapters

Overlap detection lives in a single core engine,
`Katello::Validators::ContainerPathOverlapValidator`: pure overlap logic and
authorization-scoped messaging against `DistributionReference` records (actual
Pulp state), with no knowledge of operations. Candidates describe distributions
that will actually be written, not their source repositories.

The boundary adapters only decide *which path an operation is about to write*
and delegate the decision to the engine:

- `RepositoryContainerPathValidator` — repository create/update (the projected
  rendered path, before anything is saved), plus the sync/metadata/refresh
  backstops (the current path). A repository update that actually moves a
  docker path additionally queries Pulp live for unmanaged (untracked)
  distributions at the target path.
- `ContentViewContainerPathValidator` — publish/promote (the projected
  version's paths across target environments).
- `EnvironmentDockerRepositoriesValidator` — registry pattern changes, before
  the environment is saved.

All validation happens at plan time, so conflicts surface as a 409 with an
actionable message instead of a paused task.

## Distribution writes and reference reconciliation

- **Reference-first refresh** (`Pulp3::Repository::Docker#refresh_distributions`):
  if a `DistributionReference` exists and its distribution is readable in Pulp,
  that distribution is updated (moved) to the current container name. Lookup is
  by tracked href, never by path, so a stale path column cannot strand a
  distribution. Only when no usable reference exists is a distribution created.
- **Reference reconciliation** (`Actions::Pulp3::Repository::SaveDistributionReferences`):
  after a successful distribution write, the distribution is re-read from Pulp
  and the reference row (path, content guard, prn) is updated to actual Pulp
  state. `RefreshIfNeeded` plans this with `existing_only: true` for docker on
  the primary so updates (which create no Pulp resources) still refresh the row.
- **Late-error translation**: if Pulp still rejects a distribution write
  (races, capsule-side conflicts), the overlap error is translated into an
  actionable message instead of a paused task with a raw API error.

## Divergence warning (TODO)

The docker guards (`repository.docker?` / `root.docker?`) exist to avoid
changing distribution behavior for content types that do not need it — their
existing recovery paths are preserved deliberately to reduce regression risk.
The cost is divergence: two refresh behaviors now coexist.

If the reference-first + reconciliation model proves out, the intent is to
extend it to all content types and delete the guards. See the TODOs in
`Pulp3::Repository::Docker#refresh_distributions` and
`Actions::Pulp3::Repository::SaveDistributionReferences`.
