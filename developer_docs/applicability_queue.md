# Applicability queue processing

Host package-profile uploads enqueue host IDs in the existing
`katello_host_queue_elements` table. Uploads do not create one Foreman task per
request. The shared queue still combines separate requests and deduplicates
hosts before splitting work using `applicability_batch_size`.

## Runtime

One singleton `Actions::Katello::Applicability::Hosts::PollQueue` execution plan
runs in the existing Dynflow runtime. It uses persisted polling events with a
three-second interval, releasing its executor between ticks. It does not start
an application thread, need a separate service, or create a new task every tick.
It is a system execution plan rather than a permanently running Foreman task,
so it does not prevent maintenance from waiting for user tasks to finish.

Each tick hands batches to the existing `BulkGenerate` action on `hosts_queue`.
The singleton lock is shared across application servers. A PostgreSQL advisory
session lock additionally protects queue selection, handoff, and acknowledgement.
The same database connection holds this lock across two short transactions:
selection commits before task submission, and acknowledgement happens afterwards.
Task submission runs outside either transaction so another executor can see its
committed task record. Callers must not wrap dispatch in another transaction.
Calculations for the same host use a separate advisory lock; different hosts
can still be calculated concurrently. Multi-host calculations acquire host
locks in host-ID order.
Lock acquisition and release bypass Rails' query cache: their SELECT statements
change PostgreSQL session state and must reach the database on every call.

## Handoff and recovery

- Rows are acknowledged only after Foreman Tasks accepts their batch.
- Selection records exact queue row IDs. Uploads committed during handoff are
  not deleted, even if PostgreSQL allocated their sequence IDs earlier.
- A fixed high-water mark bounds each tick while new requests keep arriving.
- New requests received during a calculation remain eligible for another batch;
  they are not discarded merely because an older calculation is running.
- A failed handoff retains its rows and is retried on the next tick. Failures
  are logged through the Dynflow action logger.
- Suspended polling and accepted calculations use Dynflow persistence and its
  executor recovery. An executor starting without a consumer starts one.

Delivery is **at least once**, not exactly once. A crash after task acceptance
but before queue acknowledgement can cause a repeated calculation. Per-host
locks serialize those calculations. The queue is not an automatic retry system
for calculations that have already been accepted and subsequently fail; those
remain visible as unsuccessful Foreman tasks, as before.

## Upgrade and rollback

Stop the old web processes and Dynflow executors before deploying the change;
do not run the old EventDaemon and new consumer together during a rolling
upgrade. Start the updated executors before accepting profile uploads again.

The existing queue table and its pending host IDs are retained. There is no
schema migration that empties the queue or submits all pending hosts during
upgrade. Obsolete `katello_events` rows are only wake-up notifications: the
host queue remains the source of pending work. The legacy event table is left
in place for rollback and can be retired separately after the new consumer is
accepted. The retired `katello_events` ping entry is removed.

Before rolling back, cancel the `PollQueue` execution plan through Dynflow while
the new code is still available, then stop the updated executors and revert the
application. After starting the old version, enqueue one
`Katello::Events::GenerateHostApplicability` event to wake its old consumer for
any host IDs left by the new version. Do not merely revert while leaving the
new, suspended system execution plan active.

## Verification

Regression tests cover cross-request batching and deduplication, batch limits,
failed handoffs, recovery polling, singleton startup, competing PostgreSQL
consumers, profile uploads during handoff, late commits with older sequence
IDs, task visibility from a separate database connection before acknowledgement,
session-lock release after a failed handoff or an empty batch with query caching
enabled, and serialization of same-host calculations across cached transactions.
Dynflow execution tests use the application's configured test database rather
than requiring a separate SQLite adapter.

Before merge, compare the previous consumer and this implementation under
concurrent package-profile ingestion: task count, hosts per batch, repeated
calculations per host, API latency, and queue-to-calculation latency. Unit
tests and isolated queue simulations do not replace that deployment benchmark.
