# Testing & Code Quality Context
This document contains information regarding testing practices in Foreman/Katello development.

For additional context, see [Quick Reference](./quick_reference.md) for command quick references and a directory of detailed guides.

### Test Organization
- **Unit tests**: `test/models/`, `test/lib/`
- **Controller tests**: `test/controllers/`
- **Action tests**: `test/actions/`
- **Integration tests**: `test/scenarios/`
- **JavaScript tests**: `webpack/` with Jest

### Running tests
See "Testing" section in [Quick Reference](./quick_reference.md).

### Test Writing Guidelines
Don't write unnecessary comments in tests. When writing a new test, look at surrounding tests and try to match their qualities, including
- testing style - method names, choice of test methods, etc.
- test length, where possible
- length and quantity of comments (don't be too wordy)

Avoid Non-Determinism. Never use `SecureRandom.uuid` or other random values in tests, use fixed strings like `'test-task-id-123'` instead. This ensures tests are reproducible and debuggable.

### VCR (Video Cassette Recorder) Testing
VCR records HTTP interactions for tests that communicate with external services (Pulp, Candlepin). Most testing will not require recording VCR cassettes.

Note for AI agents: The `record_vcr` command is available to assist with VCR recordings.

**Important VCR Info:**
- VCR recording requires careful configuration and environment resets.
- Live scenarios automatically delete and recreate VCR cassettes. Recording is a destructive operation.
- Before recording VCR cassettes, look into the source of the failing test. Perhaps you have disovered a new bug with Pulp!
- Always attempt to record the minimum number of VCR cassettes to fix a given issue. Novel issues will usually require only one or two test files to be re-recorded.
- Pulp upgrades (and similar system-wide changes) should invoke a full re-record regardless of test failure count.
- Never commit cassettes with sensitive data (tokens, passwords).
- VCR cassettes are stored in `test/fixtures/vcr_cassettes/`.

**Recording VCRs (Containerized Pulp):**
1. Either back up the current vagrant VM with a snapshot or create a new vagrant VM before beginning. The active Katello VM will be wiped.
2. Set `PULP_ORPHAN_PROTECTION_TIME=0` for VCR recording:
   ```bash
   sudo mkdir -p /etc/containers/systemd/pulp-api.container.d
   sudo mkdir -p /etc/containers/systemd/pulp-content.container.d
   sudo mkdir -p /etc/containers/systemd/pulp-worker@.container.d
   
   sudo tee /etc/containers/systemd/pulp-api.container.d/vcr.conf <<'EOF'
   [Container]
   Environment=PULP_ORPHAN_PROTECTION_TIME=0
   EOF
   
   sudo tee /etc/containers/systemd/pulp-content.container.d/vcr.conf <<'EOF'
   [Container]
   Environment=PULP_ORPHAN_PROTECTION_TIME=0
   EOF
   
   sudo tee /etc/containers/systemd/pulp-worker@.container.d/vcr.conf <<'EOF'
   [Container]
   Environment=PULP_ORPHAN_PROTECTION_TIME=0
   EOF
   
   sudo systemctl daemon-reload
   sudo systemctl restart pulp-api pulp-content pulp-worker@{1..4}
   ```
3. Configure SSL certificates:
   
   Edit `~/foreman/config/settings.yaml.test` to include:
   ```yaml
   :ssl_ca_file: /home/vagrant/foreman-certs/proxy_ca.pem
   :ssl_certificate: /home/vagrant/foreman-certs/client_cert.pem
   :ssl_priv_key: /home/vagrant/foreman-certs/client_key.pem
   ```
   
   Edit `~/foreman/test/fixtures/settings.yml` to include:
   ```yaml
   attribute101:
       name: ssl_ca_file
       value: "/home/vagrant/foreman-certs/proxy_ca.pem"
   attribute102:
       name: ssl_certificate
       value: "/home/vagrant/foreman-certs/client_cert.pem"
   attribute103:
       name: ssl_priv_key
       value: "/home/vagrant/foreman-certs/client_key.pem"
   ```
4. Reset databases and deploy fresh environment:
   ```bash
   sudo systemctl stop foreman.target
   sudo rm -rf /var/lib/pgsql/data/* /var/lib/pulp/*
   cd ~/foremanctl
   ./forge deploy-dev \
     --manage-repos=false \
     --add-feature content/ostree \
     --extra-vars pulp_container_image="<Red Hat registry>/pulp-development" \
     --extra-vars pulp_container_tag="<target-version>"
   ```
5. Record VCRs:
   ```bash
   cd ~/foreman
   mode=all bundle exec rake test:katello:test:pulpcore # Full VCR record
   mode=all ktest ~/katello/path/to/test_file.rb   # Single file VCR record
   ```
6. Important: Any re-records after running ktest require step 4 to be repeated, as VCR errors may pollute dev, test, and/or Pulp databases due to failing test cleanup.

### Code Quality Standards
- **Ruby**: Uses `theforeman-rubocop` with lenient configuration, plus a Katello-local cop (`Katello/CveAbbreviation`, in `lib/rubocop/cop/katello/cve_abbreviation.rb`) that flags "cve" used as shorthand for "content view environment" (see the CVE/CVEnv naming rule in `CLAUDE.md`, including its exclude list for legitimate errata/security CVE files)
- **JavaScript**: ESLint with Airbnb config, Prettier formatting, plus a Katello-local rule (`no-cve-abbreviation`, in `webpack/eslint-rules/`, loaded via `--rulesdir`) that flags "cve" used as shorthand for "content view environment" (see the CVE/CVEnv naming rule in `CLAUDE.md`, including its exclude list for legitimate errata/security CVE files)
- **React**: Components in `webpack/`, Patternfly UI framework
- **Legacy**: AngularJS in `engines/bastion_katello/`

### TDD Workflow
1. Write failing test
2. Run test to confirm failure
3. Implement minimal code to pass
4. Verify success and refactor
5. Run related tests to prevent regressions