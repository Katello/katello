# Pulp Upgrade Guide

Pulp is Katello's content management backend, responsible for storing and syncing the actual content served by Katello. Pulp is a separate system service, meaning Katello's pulp bindings communicate with Pulp via a localhost REST API to orchestrate all content operations. 

Katello maintainers upgrade the y-version of Pulp and all Pulp plugins every two Katello releases (currently odd-numbered Katello y-versions). Pulp y-versions may only be updated with thorough testing, while Pulp z-versions may be updated with checks to the changelog. We do not typically re-record VCRs with Pulp z-version updates since the API should not change.

The following guide demonstrates a typical Pulp upgrade procedure:

### Phase 1
Begin this phase no later than 1 month after Katello branching.

1. **Coordinate with Pulp team**: Alert the Pulp team to upgrade plans and request version recommendations. Ensure Pulpcore version has full plugin support.
2. **Check for breaking changes**: Review deprecations and functionality changes in the new Pulp version that may require Katello code changes.
3. **Backup your environment**: Create a VM snapshot or use a fresh katello-devel Vagrant box.
4. **Update client bindings only**:
   - Update all `pulp-*-client` dependencies in `katello.gemspec` using versions from [PyPI](https://pypi.org/project/pulpcore/)
   - In `~/foreman`, run `bundle update && bundle pristine`
   - Run Pulp tests: `bundle exec rake test TEST=../katello/test/services/pulp3/`
   - Check for failures (early warning for N-1 smart proxy sync issues)
5. **Install target Pulpcore and plugins**
Using values from gemspec (verify pulp-\*-client was released alongside pulp-\* package), run the following:
   ```bash
   sudo python3.12 -m pip install --upgrade --force-reinstall \
       pulpcore==X.Y.Z \
       pulp-ansible==X.Y.Z \
       pulp-container==X.Y.Z \
       pulp-deb==X.Y.Z \
       pulp-rpm==X.Y.Z \
       pulp-python==X.Y.Z \
       pulp-ostree==X.Y.Z
   ```
   **Notes:**
   - `pulp-file` and `pulp-certguard` plugins have merged into pulpcore. Only client bindings are required.
   - This step may require installing/updating many dependencies. Be sure to record the upgrade dependency requirements and have patience. Ensure these new dependencies are understood by all parties.
6. **Update systemd service files** to use pip-installed binaries (do not switch configuration away from the 'pulp' user):
   - `/etc/systemd/system/pulpcore-api.service`: `ExecStart=/usr/local/bin/pulpcore-api`
   - `/etc/systemd/system/pulpcore-content.service`: `ExecStart=/usr/local/bin/pulpcore-content`
   - `/etc/systemd/system/pulpcore-worker@.service`: `ExecStart=/usr/local/bin/pulpcore-worker`
7. **Restart Pulp services**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart pulpcore* --all
   ```
8. **Run Pulp migrations**:
    ```bash
    sudo -u pulp PULP_SETTINGS='/etc/pulp/settings.py' \
      DJANGO_SETTINGS_MODULE='pulpcore.app.settings' \
      /usr/local/bin/pulpcore-manager migrate
    ```
9. **Verify versions for installed plugins**: `sudo pulp status`
10. **Run a quick smoke test**: Restart Katello and try syncing content of all content types (RPM, container, deb, etc.)
11. **Request RPM builds**: Post to Foreman community requesting RPM builds for new Pulpcore & plugins. Anticipate 1 month for RPM builds. [Example](https://community.theforeman.org/t/request-for-pulpcore-3-85-builds/44413)

### Phase 2
Begin this phase once Pulp RPMs are ready.

1. **Run unit tests with new bindings**: Run unit tests with new Pulp client bindings but old VCR recordings
2. **Remove old monkey patches**: Check for N-1/N-2 patches that can be removed. N-1/N-2 testing will prove removal safety.
3. **Re-record VCRs**: Follow instructions in [Testing & Code Quality - VCR Testing](./testing_and_code_quality.md#vcr-video-cassette-recorder-testing)
4. **File Pulp bugs**: Investigate errors and file any upstream issues.
5. **Test N-1 and N-2 compatibility**: Create smart proxies with last Pulp version (N-1) and previous (N-2). Test syncing with/without alternate content sources and updating content counts.
6. **Handle binding compatibility issues**: If new Pulp bindings don't work with older Pulp versions, create monkey patches as workarounds.

### Phase 3
Begin this phase once Pulp bugs and monkey patches are complete (or workable).

1. **Create Katello PR**: Include updated `katello.gemspec`, re-recorded VCRs, and code changes
2. **Create foreman-packaging PR for bindings**: Update Pulp bindings requirements for `rubygem-katello`. [Example](https://github.com/theforeman/foreman-packaging/pull/12547)
3. **Create foreman-packaging PR for client gems**: Update Pulp client binding gems to new versions (use `bump_rpms.sh`). [Example](https://github.com/theforeman/foreman-packaging/pull/12548)

### Phase 4

1. **Early Foreman/Katello/Smart Proxy Validation**
   - Point Robottelo to a box with upgraded packages (may be a developer box).
   - Run tests/modules related to content (Repositories, CVs) and smart proxy locally.
2. **Normal Foreman/Katello/Smart Proxy Validation**
   - Wait for RPMs in Stream.
   - Review normal pipeline results.
3. **N-1/N-2 Compatibility Testing**
   - Spin up older Foreman/Katello/smart proxy.
   - Register smart proxy and upgrade Foreman/Katello once or twice (to achieve N-1 or N-2).
   - Mock Robottelo smart proxy fixture to point at N-1/N-2 smart proxy.
   - Run smart proxy content tests (should work with older smart proxy).
   - Adjust timeouts as needed for Foreman/Katello versions used.
