# Architecture Context
Katello is a systems lifecycle management plugin for Foreman that provides content and subscription management. It integrates with Pulp (content management) and Candlepin (subscription management) to handle package repositories, subscriptions, content views, containers, and more for registered Foreman hosts.

For additional context, see [Quick Reference](./quick_reference.md) for command quick references and a directory of detailed guides.

### File Structure
```
app/
   controllers/     # API and UI controllers
   models/         # ActiveRecord models
   services/       # Service objects
   lib/           # Library code and concerns
   views/         # Rails views and RABL API templates
   assets/        # CSS/SCSS stylesheets
   jobs/          # Background job classes

engines/
   bastion_katello/  # AngularJS UI components
   bastion/         # Base AngularJS framework

webpack/            # React components and modern JS
lib/katello/
   engine.rb      # Rails engine configuration
   tasks/         # Rake tasks
   concerns/      # Shared mixins and extensions

test/              # Minitest unit and integration tests
spec/              # RSpec tests
```

This codebase follows Foreman plugin conventions and integrates deeply with Foreman's architecture, extending its capabilities with content and subscription management features.
- Use RABL for API views, not 'render :json'.

### File Locations by Task
**API Development:**
- Controllers: `app/controllers/katello/api/v2/[resource]_controller.rb`
- Routes: `config/routes/api/v2.rb`
- Views: `app/views/katello/api/v2/[resource]/`
- Tests: `test/controllers/katello/api/v2/[resource]_controller_test.rb`

**Model Development:**
- Models: `app/models/katello/[model_name].rb`
- Concerns: `app/models/katello/concerns/[concern_name].rb`
- Tests: `test/models/katello/[model_name]_test.rb`
- Factories: `test/factories/katello/[model_name].rb`

**UI Development:**
- React Components: `webpack/scenes/[Feature]/[Component].js`
- React Tests: `webpack/scenes/[Feature]/__tests__/[Component].test.js`
- Legacy AngularJS: `engines/bastion_katello/app/assets/javascripts/`
- Stylesheets: `app/assets/stylesheets/katello/[feature].scss`
- Table Pages: Use `TableIndexPage` from `foremanReact/components/PF4/TableIndexPage/TableIndexPage`

**Dynflow Actions:**
- Actions: `app/lib/actions/katello/[domain]/[action_name].rb`
- Tests: `test/actions/katello/[domain]/[action_name]_test.rb`

**Authorization:**
- Permissions: `app/models/katello/authorization/[resource].rb`
- Role definitions: `lib/katello/engine.rb`
- **CRITICAL - Permission Registration**: `lib/katello/permissions/[resource]_permissions.rb`
  - **ALL controller actions requiring authorization MUST be registered here**
  - Add to appropriate permission (`:view_hosts`, `:edit_hosts`, etc.)
  - Format: `'katello/api/v2/[controller]/[action]'`
  - Example: `'katello/api/v2/host_packages/containerfile_install_command'`
  - **Forgetting this will cause 403 errors even if controller authorization is correct**

### Environment Quick Reference
**Key Directories:**
- Edit files: `/home/vagrant/katello`
- Run commands: `/home/vagrant/foreman`
- Database: PostgreSQL "katello" (dev), "katello_test" (test)
Note: the databases above only apply when the development environment is set up by puppet-katello_devel (such as when using forklift/vagrant VM provisioning).

**Services & URLs:**
- Foreman UI: https://$(hostname) (port 443)
- API: https://$(hostname)/api/
- Katello API: https://$(hostname)/katello/api/
- Pulp 3: $(hostname):24816
- Candlepin: $(hostname):8443
- Quick status of database and all services: https://$(hostname)/api/v2/ping
Note: `$(hostname)` is used because the vagrant VM hostname varies.

### Foreman-Katello Integration
**Plugin Architecture:**
- Katello engine loaded via `lib/katello/engine.rb`
- Routes mounted at `/katello` namespace
- Shares Foreman's PostgreSQL database with `katello_` prefixed tables
- Models inherit from `ApplicationRecord`
- Controllers extend Foreman's base controllers

**Authentication & Authorization:**
- User authentication handled by Foreman core
- Uses Foreman's RBAC system with Katello-specific permissions
- Organization-based multi-tenancy inherited from Foreman
- API uses same token/session system as Foreman

**Background Jobs:**
- Katello jobs inherit from `ForemanTasks::Task`
- Long-running operations use Dynflow orchestration
- Job status visible in Foreman Tasks UI

### External Service Integration Glossary (Pulp, Candlepin, etc)
- **Pulp 3**: Backend content management service that handles repository synchronization, package storage, and content distribution. Runs on port 24816. Katello communicates with Pulp via REST API to manage RPMs, containers, Ansible collections, and other content types.
- **Candlepin**: Subscription and entitlement management service. Handles subscription certificates, product entitlements, and subscription pooling. Runs on port 8443. Based on the upstream Candlepin project.
- **Dynflow**: Workflow orchestration engine that powers Foreman Tasks. Enables long-running, stateful operations with pause/resume capabilities, error handling, and complex job dependencies. All Katello background jobs use Dynflow.
- **Foreman Tasks**: UI and infrastructure for viewing and managing asynchronous jobs. Built on Dynflow. Provides job history, status tracking, and the ability to cancel or resume tasks.
- **Message Queue**: STOMP-based event system for Candlepin events

### Key Domain Models Glossary
- **Host**: Foreman-managed systems consuming content from one or more content view versions.
- **Host Group**: A collection of hosts enabling easy bulk host configuration.
- **Organization**: Top-level multi-tenancy boundary. All Katello resources (products, content views, subscriptions) belong to an organization. Inherited from Foreman core.
- **Location**: A physical/geographical multi-tenancy boundary in Foreman core (e.g., data centers, regions). Complementary to Organization - while Organization provides business/logical isolation, Location provides infrastructure/physical isolation. Inherited from Foreman core but less commonly used in Katello workflows than Organization.
- **Repository**: A collection of content (RPMs, containers, etc.) synchronized from an external source or created locally. All repositories belong to a product.
- **Product**: A logical grouping of repositories. Can be Red Hat (synced from Red Hat CDN) or custom (user-created).
- **Content View**: A collection of repositories that defines what content is available to hosts. Content views can include filters and package restrictions, and can be modified at any time without affecting existing content view versions. Publishing a content view creates a new content view version.
- **Content View Version**: A versioned, immutable snapshot of a content view. Promoting a content view version to a lifecycle environment updates content on all hosts consuming content from the matching content view and lifecycle environment.
- **Lifecycle Environment**: A collection of content view versions. Lifecycle environments are members of a lifecycle environment path (e.g., Dev → QA → Production), enabling controlled rollout of updates.
- **Activation Key**: Reusable registration credentials that automatically configure host subscriptions, content views, and lifecycle environments during provisioning.