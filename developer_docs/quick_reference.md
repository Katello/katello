# Katello
Katello is a plugin for Foreman that orchestrates content distribution and subscription management at scale across thousands of Enterprise Linux and Debian-based systems. Katello serves as an enterprise content gateway between external repositories and Foreman-managed hosts by synchronizing RPMs, container images, flatpaks, and more into versioned Content Views, promoting this content through isolated Lifecycle Environments. Katello provides Foreman hosts with first-class content, subscription, and entitlement management.

### Important archetecture information
- Katello operates as a plugin to Foreman core (~/foreman), not as a standalone application.
- Katello development environments are virtual machines provisioned with [foremanctl](https://github.com/theforeman/foremanctl/).
  - Under foremanctl, Foreman and Katello run from source while core services such as Pulp and PostgreSQL run as Podman quadlets.
  - Podman quadlets can be accessed through `sudo podman exec -it ...`.
- Non-containerized development environments may be provisioned via [forklift](https://github.com/theforeman/forklift/).
  - These environments host core services locally on the VM.
  - Look for (containerized only) after command references; alternatives are provided in [Quick Reference for Non-Containerized Environments](developer_docs/quick_reference_non_containerized.md)
- Note for AI agents: Skill `detect-foreman-environment` can determine if the current environment is containerized or non-containerized/legacy.

### Command Quick Reference
**Development Server:**
```bash
cd $GITDIR/foreman
bundle exec foreman start                               # Start development server
bundle exec rake console                                # Rails console
```
Note for AI Agents: Typically, developers manually start/stop the Foreman server.

**Database and services:**
```bash
cd $GITDIR/foreman
bundle exec rake db:migrate                             # Run migrations
bundle exec rake db:drop db:create db:migrate           # Reset Katello database (step 1/3)
bundle exec rake db:seed                                # Reset Katello database (step 2/3)
bundle exec rake permissions:reset password=changeme    # Reset Katello database (step 3/3)
RAILS_ENV=test bundle exec rake db:drop db:create db:migrate    # Reset test database (step 1/2)
RAILS_ENV=test bundle exec rake db:seed                         # Reset test database (step 2/2)
bundle exec rake katello:delete_orphaned_content        # Clean up orphaned content in Pulp
curl https://$(hostname)/api/v2/ping                    # Get basic status of database and all services (Pulp, Candlepin, etc)
sudo podman exec -it pulp-api pulpcore-manager ...      # (containerized only) Run pulpcore-manager commands
```
Note: Reset of Pulp/Candlepin is best done through a delete and re-deploy in foremanctl (containerized only).

**Testing:**
```bash
cd $GITDIR/foreman
bundle exec rake test:katello                           # All Katello tests

# For individual test files, ALWAYS use foreman-test:
cd $GITDIR/katello
foreman-test /path/to/test_file.rb                      # (containerized only) Specific file
foreman-test /path/to/test_file.rb -n test_method_name  # (containerized only) Specific method

# JavaScript testing:
cd $GITDIR/katello
npm test                                                # All JS tests
npx jest webpack/path/to/file.test.js                   # Individual test file
npm run test:watch                                      # Watch mode
```

**Code Quality:**
```bash
cd $GITDIR/foreman
bundle exec rake katello:rubocop                        # Ruby linting

cd $GITDIR/katello
npm run lint                                            # JavaScript linting
npm run format                                          # Format JavaScript
npm run build                                           # Build and lint JS
```

### Essential Rules:
- **All `rake` and `rails` commands must be run from Foreman directory** (`$GITDIR/foreman` or `/home/vagrant/foreman`)
- **Commands must use `bundle exec` prefix** to ensure correct gem versions
- **Edit files in Katello directory** (`/home/vagrant/katello`)
- **Never abbreviate content view environment as "cve"** - "CVE" is reserved for errata CVEs - common vulnerabilities and exposures"
- **Comment only where needed to clarify difficult code. No narration** Follow existing code style wherever possible

### Glossary of Foreman/Katello terms
- **Host**: Foreman-managed systems consuming content from one or more content view versions.
- **Organization**: Top-level multi-tenancy boundary. All Katello resources (products, content views, subscriptions) belong to an organization. Inherited from Foreman core.
- **Location**: A physical/geographical multi-tenancy boundary. Inherited from Foreman core.
- **Repository**: A collection of content (RPMs, containers, etc.) synchronized from an external source or created locally. All repositories belong to a product.
- **Product**: A logical grouping of repositories. Can be Red Hat (synced from Red Hat CDN) or custom (user-created).
- **Content View**: A collection of repositories that defines what content is available to hosts. Publishing a content view creates a new content view version.
- **Content View Version**: A versioned, immutable snapshot of a content view. Promoting a content view version to a lifecycle environment updates content on all hosts consuming content from the matching content view and lifecycle environment.
- **Lifecycle Environment**: A collection of content view versions. Lifecycle environments are members of a lifecycle environment path (e.g., Dev → QA → Production), enabling controlled rollout of updates.
- **Content View Environment**: A specific content view version in a specific lifecycle environment.
- **Activation Key**: Reusable registration credentials that automatically configure host subscriptions, content views, and lifecycle environments during provisioning.

### Additional Resources
For detailed workflows, patterns, and troubleshooting, consult these topic-specific guides:

**[Architecture & Setup](./architecture.md)**:
- File Structure, File Locations by Task
- Environment Quick Reference
- Foreman-Katello Integration
- External Service Integration Glossary (Pulp, Candlepin, etc)

**[Development Workflows and Troubleshooting](./development_and_troubleshooting.md)**:
- Development Workflows (API endpoints, models, React components, database changes)
- Common API Patterns & Gotchas (search patterns, response structure, UI components)
- React Hooks & State Management Gotchas
- Toast Notifications
- Troubleshooting Bundle/Gem Issues
- Troubleshooting Test Failures
- Troubleshooting Asset/JavaScript Issues
- Troubleshooting Service Issues
- Troubleshooting ESLint False Positives

**[React & UI Patterns](./table_index_page_patterns.md)**:
- TableIndexPage Component Patterns
- Declarative vs Imperative Usage
- replacementResponse Pattern
- Bulk Actions and Selection
- Custom Action Buttons
- API Integration Patterns

**[Testing & Quality](./testing_and_code_quality.md)**:
- Test Organization
- Running tests
- Test Writing Guidelines
- VCR (Video Cassette Recorder) Testing
- Code Quality Standards
- TDD Workflow

**[Upgrading Pulp](./pulp_upgrade.md)**
