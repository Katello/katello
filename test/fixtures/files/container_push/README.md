# Container push fixture

A minimal Docker schema 2 image built locally, with no external base image.
`layer.tar.gz` contains only `hello.txt` (`Katello container push VCR fixture\n`).
The tar header has fixed timestamps, UID/GID 0, and mode 0644; the gzip header
has timestamp 0. The two configs differ only in their `version` label, giving
`manifest_v1.json` and `manifest_v2.json` distinct digests while sharing a layer.
Manifest descriptor sizes/digests and config rootfs diff IDs describe the exact
fixture bytes; do not reformat the JSON without updating those descriptors.

`test/controllers/api/registry/container_push_vcr_test.rb` uploads these bytes
through the registry controller using Ruby HTTP calls, allowing WebMock/VCR to
record Pulp requests. Podman/Docker and external registries are unnecessary.

From the Foreman checkout, replay with:

```sh
bundle exec ruby -Itest -I../katello/test ../katello/test/controllers/api/registry/container_push_vcr_test.rb
```

To re-record against a configured Pulp recording environment, add `mode=all`:

```sh
mode=all bundle exec ruby -Itest -I../katello/test ../katello/test/controllers/api/registry/container_push_vcr_test.rb
```

Recording requires pulp_container 2.29 or newer. The tests create and clean up
their own Pulp repositories and distributions; no manually seeded data is needed.
Legacy `container-push` compatibility belongs in upgrade tests in Robottelo.

The tests prepare an existing Katello repository fixture with no Pulp backend;
the first registry upload must create the backend in Pulp. Authentication is
stubbed because it has separate controller tests; registry forwarding, href
lookup, indexing, publication, and manifest retrieval use recorded HTTP calls.

Publication coverage runs the real `CopyAllUnits`, indexing, and metadata stages
against a content-view repository fixture. It does not exercise the complete
`ContentView::Publish` action or Candlepin environment creation.
