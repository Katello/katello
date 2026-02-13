# Katello
Katello is a plugin for Foreman that orchestrates content distribution and subscription management at scale across thousands of Enterprise Linux and Debian-based systems. Katello serves as an enterprise content gateway between external repositories and Foreman-managed hosts by synchronizing RPMs, container images, flatpaks, and more into versioned Content Views, promoting this content through isolated Lifecycle Environments. Katello provides Foreman hosts with first-class content, subscription, and entitlement management.

### Essential Rules:
- **Katello operates as a plugin to Foreman core, not as a standalone application.**
- **All `rake` and `rails` commands must be run from Foreman directory** (`$GITDIR/foreman` or `/home/vagrant/foreman`)
- **Commands must use `bundle exec` prefix** to ensure correct gem versions
- **Edit files in Katello directory** (`/home/vagrant/katello`)
- **Run commands from Foreman directory** (`/home/vagrant/foreman`)

### Command Quick Reference
**Development Server:**
```bash
cd $GITDIR/foreman
bundle exec foreman start                       # Start development server
bundle exec rake console                        # Rails console
```
Note for AI Agents: Typically, developers manually start/stop the Foreman server.

**Database and services:**
```bash
cd $GITDIR/foreman
bundle exec rake db:migrate                     # Run migrations
bundle exec rake katello:reset                  # Wipe Foreman/Katello/Pulp/Candlepin data and seed sane defaults
RAILS_ENV=test bundle exec rake db:drop         # Reset test database (step 1/4)
RAILS_ENV=test bundle exec rake db:create       # Reset test database (step 2/4)
RAILS_ENV=test bundle exec rake db:migrate      # Reset test database (step 3/4)
RAILS_ENV=test bundle exec rake db:seed         # Reset test database (step 4/4)
sudo pulp --force orphan cleanup                # Clean up orphaned content in Pulp
curl https://$(hostname)/api/v2/ping            # Get basic status of database and all services (Pulp, Candlepin, etc)
```

**Testing:**
```bash
cd $GITDIR/foreman
bundle exec rake test:katello                   # All Katello tests

# For individual test files, ALWAYS use ktest:
cd $GITDIR/katello
ktest /path/to/test_file.rb                     # Specific file
ktest /path/to/test_file.rb -n test_method_name # Specific method

# JavaScript testing:
cd $GITDIR/katello
npm test                                        # All JS tests
npx jest webpack/path/to/file.test.js           # Individual test file
npm run test:watch                              # Watch mode
```

**Code Quality:**
```bash
cd $GITDIR/foreman
bundle exec rake katello:rubocop                # Ruby linting

cd $GITDIR/katello
npm run lint                                    # JavaScript linting
npm run format                                  # Format JavaScript
npm run build                                   # Build and lint JS
```

### Additional Resources
For detailed workflows, patterns, and troubleshooting, consult these topic-specific guides:

**[Architecture & Setup](./architecture.md)**:
- File Structure, File Locations by Task
- Environment Quick Reference
- Foreman-Katello Integration
- External Service Integration Glossary (Pulp, Candlepin, etc)
- Key Domain Models Glossary

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
