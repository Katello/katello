# Pulp Upgrade Guide

Pulp is Katello's content management backend, responsible for storing and syncing the actual content served by Katello. Pulp is a separate system service, meaning Katello's pulp bindings communicate with Pulp via a localhost REST API to orchestrate all content operations. 

Katello maintainers upgrade the y-version of Pulp and all Pulp plugins every two Katello releases (currently odd-numbered Katello y-versions). Pulp y-versions may only be updated with thorough testing, while Pulp z-versions may be updated with checks to the changelog. We do not typically re-record VCRs with Pulp z-version updates since the API should not change.

The following guide covers the workflow for upgrading Katello's containerized Pulp service using foremanctl development environments.

## Phase 1: Version Selection & Preparation
Begin this phase no later than 1 month before branching (ideally earlier).

1. **Coordinate with Pulp team**: Alert the Pulp team to upgrade plans and request version recommendations. Ensure Pulpcore version has full plugin support.
2. **Check pulp-smart-proxy compatibility**: Verify that `pulp-smart-proxy` supports the target pulpcore version. If the upper bound needs updating, submit a PR to update `pyproject.toml` in the pulp_smart_proxy repository.
3. **Research target Pulp and plugin versions**: Based on Pulp team recommendations, identify target versions for pulpcore and all plugins (ansible, container, rpm, deb, python, file, certguard).
4. **Verify package availability**: Verify that Pulp packages are available on [PyPI](https://pypi.org/) for all target versions you plan to pin in `requirements.txt`.
5. **Backup your environment**: Create a snapshot of your quadlet VM or use a fresh foremanctl development environment.
6. **Build development Pulp container**: Follow the [Building Custom Pulp Containers](https://github.com/theforeman/foremanctl/blob/master/docs/developer/development-environment.md#building-custom-pulp-containers) guide in foremanctl documentation to build a container with the target Pulp versions.
7. **Deploy and smoke test**
   - Deploy the development environment with the custom Pulp image by passing extra variables:
   ```bash
   ./forge deploy-dev \
     --manage-repos=false \
     --add-feature content/ostree \
     --extra-vars pulp_container_image="<Red Hat registry>/pulp-development" \
     --extra-vars pulp_container_tag="<target-version>"
   ```
   
   This overrides the default Pulp container image settings. Database migrations run automatically during deployment via `pulpcore-manager-migrate.service`.
   
   **Permanent override**
   
   To make this the default without typing it every time, add these variables to `~/foremanctl/development/vars/devel.yaml`:
   ```yaml
   httpd_foreman_backend: "http://localhost:3000/"
   pulp_container_image: <Red Hat registry>/pulp-development
   pulp_container_tag: "<target-version>"
   ```
   
   Then simply run `./forge deploy-dev` to automatically use the custom image.
   
   **Quick update via container drop-in**
   
   If updating an already-deployed environment, create a systemd drop-in to override the Pulp image:
   ```bash
   vagrant ssh quadlet
   
   sudo mkdir -p /etc/containers/systemd/pulp.image.d
   sudo tee /etc/containers/systemd/pulp.image.d/90-custom.conf <<'EOF'
   [Image]
   Image=<Red Hat registry>/pulp-development:<target-version>
   EOF
   
   sudo systemctl daemon-reload
   sudo systemctl restart pulp-image.service
   sudo systemctl restart pulp-api pulp-content pulp-worker@{1..4}
   ```
   - Verify Pulp versions: `curl -k https://quadlet.example.com/pulp/api/v3/status/ | jq '.versions[]'`
   - Run smoke tests: Try syncing content of all content types (RPM, container, deb, etc.)
8. **Review changelog and breaking changes**: Review deprecations, functionality changes, and the changelog diff between current and target Pulp versions to understand what Katello code changes may be required.
9. **Lock in final Pulp and plugin versions**: After successful smoke testing and changelog review, finalize the specific versions for pulpcore and all plugins.
10. **Update Pulp versions spreadsheet**: Document the locked versions in the [Pulp versions spreadsheet](https://docs.google.com/spreadsheets/d/1BAjPzdH4apXnKSoBWurtms5-OLfQbTbT1qGl0JOCnk0).
11. **Update pulpcore-packaging**: Update [pulpcore-packaging/automation/requirements.txt](https://github.com/theforeman/pulpcore-packaging/blob/rpm/develop/automation/requirements.txt) with the locked versions for nightly container images.
12. **Create community thread**: Create a community.theforeman.org thread announcing the Pulp upgrade with the locked versions and timeline.

## Phase 2: Code Updates & Testing
Begin this phase once versions are locked and announced.

1. **Update client bindings**:
   - Update all `pulp-*-client` dependencies in `~/katello/katello.gemspec` using versions from [RubyGems](https://rubygems.org/)
   - In `~/foreman`, run `bundle update && bundle pristine`
2. **Run unit tests with new bindings**: 
   - Run `bundle exec rake test:katello:test:pulpcore`
   - Expect failures - these are early warnings for code that needs updating
3. **Remove old monkey patches**: Check for N-2/N-3 patches that can be removed. N-1/N-2 testing will prove removal safety.
4. **Add new monkey patches**: Fix breaking API changes and add monkey patches as needed for compatibility.
5. **File Pulp bugs**: Investigate errors and file any upstream issues.
6. **Test N-1 and N-2 compatibility**: 
   - Create smart proxies with last Pulp version (N-1) and previous (N-2)
   - Test syncing with/without alternate content sources and updating content counts
7. **Handle binding compatibility issues**: If new Pulp bindings don't work with older Pulp versions, create additional monkey patches as workarounds.
8. **Re-run unit tests**: Continue testing until all unit tests pass with the new bindings and monkey patches in place. VCR tests will be re-recorded in phase 3.
9. **Create pull request containing monkey patches and unit test fixes.**

## Phase 3: VCR Recording & PR Creation
Begin this phase once all code changes are complete and tests are passing.

1. **Re-record VCRs**: Follow the VCR recording steps from [Testing & Code Quality - VCR Testing](./testing_and_code_quality.md#vcr-video-cassette-recorder-testing).
2. **Create Katello PR**: Include updated `katello.gemspec` and re-recorded VCRs.
3. **Create foreman-packaging PRs**:
   - Update Pulp bindings requirements for `rubygem-katello`. [Example](https://github.com/theforeman/foreman-packaging/pull/12547)
   - Update Pulp client binding gems to new versions (use `bump_rpms.sh`). [Example](https://github.com/theforeman/foreman-packaging/pull/12548)

## Phase 4: Validation

1. **Validate in Stream**:
   - Wait for container builds in Stream
   - Review normal pipeline results
2. **N-1/N-2 Compatibility Testing**:
   - Spin up older Foreman/Katello/smart proxy
   - Register smart proxy and upgrade Foreman/Katello once or twice (to achieve N-1 or N-2)
   - Mock Robottelo smart proxy fixture to point at N-1/N-2 smart proxy
   - Run smart proxy content tests (should work with older smart proxy)
   - Adjust timeouts as needed for Foreman/Katello versions used
3. **Early Validation** (optional):
   - Point Robottelo to a box with upgraded packages (may be a developer box)
   - Run tests/modules related to content (Repositories, CVs) and smart proxy locally
