# Repository upload staging and upgrade

With Foreman's Active Storage support, Katello stages browser/API repository
uploads as private attachments owned by their repository and Dynflow execution
plan. Workers receive a staging ID, filename, checksum and size rather than a
shared local path. They verify streamed downloads before creating a Pulp upload.
This moves only temporary web-to-worker handoff data: **Pulp still owns repository
content**. No Pulp content storage, content unit or repository is migrated.

Foreman versions without Active Storage automatically retain the filesystem
workflow. No Kubernetes-specific setting is introduced. Configure the same
Foreman storage service on all web/worker instances and apply database migrations
before using the new code. Disk is still supported but requires persistent/shared
storage if several processes need access. Object storage removes the shared
`tmp/uploads` requirement for new jobs. Verification/forwarding needs temporary
disk capacity for the largest upload; checksum calculations are streamed.

Use a coordinated upgrade: stop upload producers and workers, apply migrations and
upgrade all web/worker processes to the same Katello version before allowing new
jobs. New workers accept old path inputs, but old workers cannot understand new
staging-ID inputs; mixed-version rolling upload processing is not supported.

New staging is created only after repository/content-type validation. Failed
planning cleans up copies created by that plan; normal task finalization removes
only its own temporary attachments. Staging IDs cannot be resolved for another
repository or execution plan. There is no global unattached-blob garbage collector.
Database/object-store backups must be coordinated; unresolved or paused jobs must
retain their attachments until resumed or explicitly resolved.
Repository deletion is blocked while staging records exist, so it cannot purge
attachments still needed by a paused or running upload. Resolve the owning jobs
and remove their staging through the normal finalizer or explicit cleanup first.

## Existing path-based jobs

Back up the database and `tmp/uploads`. Stop/pause upload writers and workers
while copying so old jobs cannot run on another node before their copy exists.
Preview and import resumable legacy repository-upload jobs:

```console
foreman-rake katello:uploads:migrate
APPLY=true foreman-rake katello:uploads:migrate
```

The importer reads existing task ownership and inputs; it does not rewrite
serialized Dynflow plans or execute/upload content. It copies only regular files
directly in Katello's `tmp/uploads` that are referenced by a known resumable
upload task. Uploaded bytes and source identity are verified before committing.
Repeated runs skip verified copies. Symlinks, changing files, multiple resumable
tasks sharing a mutable path and missing ownership are not guessed around.
Failures return non-zero; fix the conflict and retry. Unowned old files are not
automatically imported or deleted.

Resume workers after importing. New code resolves old path inputs through the
repository/plan-owned copy where available, otherwise it retains the old path
reader. Keep the legacy mount until all old jobs have drained. Imported copies
remain protected during task finalization for the explicit cleanup below.

## Explicit legacy cleanup

After legacy jobs have completed successfully, stop legacy writers and drain or
resolve active/paused upload jobs. Check the uploaded content in Pulp and take
coordinated backups. Preview, then explicitly remove verified temporary copies:

```console
foreman-rake katello:uploads:cleanup
CONFIRM_DRAINED=true APPLY=true foreman-rake katello:uploads:cleanup
```

Cleanup refuses active/resumable upload tasks and only processes imported records
or leftover owned staging whose task stopped successfully. It checks the attachment and any remaining
original against the stored checksum before removing the original and purging the
temporary attachment. Changed or corrupt files are retained and reported. A
source already removed by an older successful finalizer is also supported.
Unrelated files, failed/cancelled owners and unresolved ownership are retained
for operator investigation. No recursive directory deletion is performed.

Downgrade to path-only code requires a matching pre-upgrade backup or draining all
new attachment-backed uploads first. Copying alone does not permit removing a
legacy mount: some old jobs or unowned files may still require it.
