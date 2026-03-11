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

**Recording VCRs:**
1. Either back up the current vagrant VM with a snapshot or create a new vagrant VM before beginning. The active Katello VM will be wiped.
2. Modify `/etc/pulp/settings.py` to include `ORPHAN_PROTECTION_TIME = 0`.
3. Restart Pulp with `sudo systemctl restart pulpcore* --all` and confirm services are running.
4. Configure SSL certificates by editing `~/foreman/config/settings.yaml.test` to include:
   ```yaml
:ssl_ca_file: /home/vagrant/foreman-certs/proxy_ca.pem
:ssl_certificate: /home/vagrant/foreman-certs/client_cert.pem
:ssl_priv_key: /home/vagrant/foreman-certs/client_key.pem
   ```
5. Update test fixtures by editing `~/foreman/test/fixtures/settings.yml` to include:
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
6. Reset development database, Candlepin with `cd $GITDIR/foreman && bundle exec rake katello:reset`
7. Reset test database with:
    ```bash
    cd $GITDIR/foreman
    RAILS_ENV=test bundle exec rake db:drop         # Reset test database (step 1/4)
    RAILS_ENV=test bundle exec rake db:create       # Reset test database (step 2/4)
    RAILS_ENV=test bundle exec rake db:migrate      # Reset test database (step 3/4)
    RAILS_ENV=test bundle exec rake db:seed         # Reset test database (step 4/4)
    ```
8. Clean up Pulp orphans by running `sudo pulp --force orphan cleanup`
9. Record VCRs:
    ```bash
    cd $GITDIR/foreman
    mode=all bundle exec rake test:katello:test:pulpcore # Full VCR record
    mode=all ktest ~/katello/path/to/test_file.rb   # Single file VCR record
    ```
10. Important: Any re-records after running ktest require steps 6-9 to be repeated, as VCR errors may pollute dev, test, and/or Pulp databases due to failing test cleanup.

### Code Quality Standards
- **Ruby**: Uses `theforeman-rubocop` with lenient configuration
- **JavaScript**: ESLint with Airbnb config, Prettier formatting
- **React**: Components in `webpack/`, Patternfly UI framework
- **Legacy**: AngularJS in `engines/bastion_katello/`

### TDD Workflow
1. Write failing test
2. Run test to confirm failure
3. Implement minimal code to pass
4. Verify success and refactor
5. Run related tests to prevent regressions