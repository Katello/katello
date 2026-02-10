# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL: Plugin Architecture & Commands

**Katello operates as a plugin to Foreman core, not as a standalone application.**

### Essential Rules:
- **All `rake` and `rails` commands must be run from Foreman directory** (`$GITDIR/foreman` or `/home/vagrant/foreman`)
- **Commands must use `bundle exec` prefix** to ensure correct gem versions
- **Edit files in Katello directory** (`/home/vagrant/katello`)
- **Run commands from Foreman directory** (`/home/vagrant/foreman`)

### Key Command Pattern:
```bash
# Edit files here: /home/vagrant/katello
# Run commands here: /home/vagrant/foreman
cd $GITDIR/foreman
bundle exec [command]
```

## Quick Reference

### Essential Commands by Task

**Testing:**
```bash
# ONLY acceptable rake test commands:
cd $GITDIR/foreman
bundle exec rake test:katello                    # All Katello tests
mode=all bundle exec rake test:katello:test:pulpcore  # Rerecord Pulp VCRs

# For individual tests, ALWAYS use ktest:
ktest /path/to/test_file.rb                     # Specific file
ktest /path/to/test_file.rb -n test_method_name # Specific method
ktest                                           # All Katello tests
```

**Development Server:**
```bash
cd $GITDIR/foreman
bundle exec foreman start                       # Start development server
bundle exec rake console                        # Rails console
```

**Database:**
```bash
cd $GITDIR/foreman
bundle exec rake db:migrate                     # Run migrations
bundle exec rake katello:reset                  # Reset (destroys data!)
bundle exec rake db:test:prepare                # Prepare test database
```

**Code Quality:**
```bash
cd $GITDIR/foreman
bundle exec katello:rubocop                     # Ruby linting
bundle exec rubocop -a                          # Auto-fix Ruby issues

cd $GITDIR/katello
npm run lint                                    # JavaScript linting
npm run format                                  # Format JavaScript
npm run build                                   # Build and lint JS
```

**JavaScript Testing:**
```bash
cd $GITDIR/katello
npm test                                        # All JS tests
npx jest webpack/path/to/file.test.js           # Individual test file
npm run test:watch                              # Watch mode
```

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

**Background Jobs:**
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

**Services & URLs:**
- Foreman UI: https://localhost (port 443)
- API: https://localhost/api/
- Katello API: https://localhost/katello/api/
- Pulp 3: localhost:24816
- Candlepin: localhost:8443

## Troubleshooting

### Wrong Directory Errors
**Symptoms**: "No Rakefile found", gem version conflicts
**Solution**: Always run commands from Foreman directory:
```bash
cd $GITDIR/foreman  # or cd /home/vagrant/foreman
bundle exec [command]
```

### Bundle/Gem Issues
**Symptoms**: "Could not find gem", version conflicts
**Solution**:
```bash
cd $GITDIR/foreman
bundle install
bundle exec [command]
```

### Test Failures
**Symptoms**: Database errors, setup failures
**Solution**:
```bash
cd $GITDIR/foreman
bundle exec rake db:test:prepare
bundle exec rake katello:reset  # If needed (destroys data)
```

### Asset/JavaScript Issues
**Symptoms**: UI not updating, build errors
**Solution**:
```bash
# JavaScript issues (from Katello directory)
cd $GITDIR/katello
npm install && npm run build

# Rails assets (from Foreman directory)
cd $GITDIR/foreman
bundle exec rake assets:precompile
```

### Service Issues
**Symptoms**: Pulp/Candlepin connection errors
**Solution**:
```bash
sudo systemctl status pulpcore-worker@*
sudo systemctl status candlepin
```

## Development Workflows

### Adding New API Endpoint
1. **Test**: Create in `test/controllers/katello/api/v2/[resource]_controller_test.rb`
2. **Route**: Add to `config/routes/api/v2.rb`
3. **Controller**: Create in `app/controllers/katello/api/v2/[resource]_controller.rb`
4. **Authorization**: Update `app/models/katello/authorization/[resource].rb`
5. **CRITICAL - Permission Registration**: Add action to `lib/katello/permissions/[resource]_permissions.rb`
   - Find the appropriate permission (`:view_hosts`, `:edit_hosts`, etc.)
   - Add line: `'katello/api/v2/[controller]/[action]'`
   - **This step is required or you will get 403 errors in permission tests**
6. **View**: Create RABL template in `app/views/katello/api/v2/[resource]/`
7. **Test**: Run `ktest test/controllers/katello/api/v2/[resource]_controller_test.rb`

### Adding New Model
1. **Migration**: `cd $GITDIR/foreman && bundle exec rails g migration CreateKatello[ModelName]`
2. **Test**: Create in `test/models/katello/[model_name]_test.rb`
3. **Model**: Create in `app/models/katello/[model_name].rb` extending `Katello::Model`
4. **Associations**: Link to Organization and other models
5. **Validations**: Add business rule validations
6. **Test**: Run `ktest test/models/katello/[model_name]_test.rb`

### Fixing Bug
1. **Reproduce**: Write failing test demonstrating the bug
2. **Debug**: Use `cd $GITDIR/foreman && bundle exec rake console`
3. **Fix**: Implement minimal change
4. **Verify**: Ensure test passes
5. **Test**: Run related test suite to prevent regressions

### Adding React Component
1. **Location**: Place in `webpack/scenes/[Feature]/[Component].js`
2. **Test**: Create `webpack/scenes/[Feature]/__tests__/[Component].test.js`
3. **Component**: Follow Patternfly patterns
4. **Table Pages**: Use `TableIndexPage` from Foreman (see examples below)
5. **API**: Connect to existing endpoints
6. **Manual Test**: `cd $GITDIR/foreman && bundle exec foreman start`
7. **Test Individual File**: `cd $GITDIR/katello && npx jest webpack/scenes/[Feature]/__tests__/[Component].test.js`

### Database Changes
1. **Migration**: Generate from Foreman directory
2. **Test Migration**: Ensure clean database compatibility
3. **Update Model**: Modify attributes/associations
4. **Test Models**: Update and run model tests
5. **Rollback**: Write down migration if needed

## Common API Patterns & Gotchas

### Rails Controller Search Patterns

**scoped_search Helper Return Value:**

The `scoped_search` helper in controllers returns a hash with specific keys, NOT an ActiveRecord relation:

```ruby
# In controllers (e.g., HostsBulkActionsController)
results = scoped_search(Katello::HostTracer.resolvable, nil, nil, resource_class: Katello::HostTracer)
# Returns: { results: [...], total: 10, subtotal: 5, page: 1, per_page: 20, selectable: 10 }
```

**Important gotchas:**
- Empty string `""` is a valid search query meaning "match all records"
- Don't try to chain ActiveRecord methods on the return value
- Access results via `results[:results]`, not as a direct array
- The hash also includes pagination metadata (total, subtotal, page, per_page, selectable)

**Example:**
```ruby
def find_traces
  if params[:trace_search].present?
    search_results = scoped_search(Katello::HostTracer.resolvable, nil, nil, resource_class: Katello::HostTracer)
    @traces = search_results[:results]  # Extract the actual records
  elsif params[:trace_ids].present?
    @traces = Katello::HostTracer.resolvable.where(id: params[:trace_ids])
  end
end
```

### API Response Structure

When building API responses for React components, follow this structure:
```json
{
  "results": [...],
  "total": 100,        // Total available records
  "subtotal": 50,      // Records matching current filter
  "selectable": 45,    // Records that can be selected (excluding disabled)
  "page": 1,
  "per_page": 20
}
```

This matches what `TableIndexPage` expects from the API.

## Testing & Code Quality

### Test Organization
- **Unit tests**: `test/models/`, `test/lib/`
- **Controller tests**: `test/controllers/`
- **Action tests**: `test/actions/`
- **Integration tests**: `test/scenarios/`
- **JavaScript tests**: `webpack/` with Jest

### Test Writing Guidelines

Don't write unnecessary comments in tests. When writing a new test, look at surrounding tests and try to match their qualities, including
- testing style - method names, choice of test methods, etc.
- test length, where possible
- length and quantity of comments (don't be too wordy)

### Test Commands Reference

**CRITICAL: Never use `bundle exec rake test TEST=...` for individual tests. Always use `ktest`.**

```bash
# ONLY acceptable rake test commands:
cd $GITDIR/foreman
bundle exec rake test:katello                      # All Katello tests
mode=all bundle exec rake test:katello:test:pulpcore  # Rerecord Pulp VCRs

# For ALL individual/specific tests, use ktest:
ktest                                          # All Katello tests
ktest /path/to/test.rb                        # Specific file
ktest /path/to/test.rb -n test_method_name    # Specific method

# Test by pattern (use ktest with grep-like patterns)
ktest | grep content_view                      # Pattern matching
```

### VCR (Video Cassette Recorder) Testing

VCR records HTTP interactions for tests that communicate with external services (Pulp, Candlepin).

**VCR Cassette Management:**
```bash
# Rerecord Pulp VCR cassettes (when Pulp API changes)
cd $GITDIR/foreman
mode=all bundle exec rake test:katello:test:pulpcore

# Rerecord a specific VCR test
mode=all ktest ~/katello/test/actions/pulp3/orchestration/multi_copy_all_units_test.rb -n test_yum_copy_all_no_filter_rules
```

**VCR Best Practices:**
- VCR cassettes are stored in `test/fixtures/vcr_cassettes/`
- Never commit cassettes with sensitive data (tokens, passwords)
- Use `mode=all` to rerecord all cassettes for external service tests
- Live scenarios automatically delete and recreate VCR cassettes

### JavaScript Testing
```bash
cd $GITDIR/katello
npm test                                    # All tests (single run)
npm run test:watch                          # Watch mode
npm run test:current                        # Current changes only
npx jest webpack/path/to/test_file.test.js  # Run individual test file
npm run storybook                           # Component development (port 6007)
```

### Code Quality Standards
- **Ruby**: Uses `theforeman-rubocop` with lenient configuration
- **JavaScript**: ESLint with Airbnb config, Prettier formatting
- **React**: Components in `webpack/`, Patternfly UI framework
- **Legacy**: AngularJS in `engines/bastion_katello/`

#### Common ESLint False Positives

**promise/prefer-await-to-callbacks:**

This rule gives false positives for standard array methods like `.find()` and `.filter()`:

```javascript
// ESLint incorrectly flags these as promise callbacks:
const found = array.find(item => item.id === targetId);  // Not a promise!
const filtered = array.filter(cb => cb.disabled);        // Not a promise!
```

**Solution:** Use `// eslint-disable-next-line promise/prefer-await-to-callbacks` on the line before the array method call. The rule is intended for actual promise callbacks but can't distinguish them from array callbacks.

```javascript
// eslint-disable-next-line promise/prefer-await-to-callbacks
const firstCheckbox = checkboxes.find(cb => !cb.disabled);
```

### TDD Workflow
1. Write failing test
2. Run test to confirm failure
3. Implement minimal code to pass
4. Verify success and refactor
5. Run related tests to prevent regressions

### UI Components & Patterns

**TableIndexPage - Use for All Table Pages**

Always use `TableIndexPage` from Foreman when creating new table-based UI pages.

**Basic Pattern:**
```javascript
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';

const columns = {
  name: { title: __('Name'), wrapper: ({id, name}) => <a href={`/path/${id}`}>{name}</a>, isSorted: true },
  status: { title: __('Status') },
};

return (
  <TableIndexPage
    apiUrl="/katello/api/resources"
    apiOptions={{ key: 'RESOURCE_KEY' }}
    header={__('Resources')}
    controller="resources"
    columns={columns}
  />
);
```

**References:**
- [Table Index Page](./TABLE_INDEX_PAGE_PATTERNS.md)
- Simple [ModelsPage] (https://github.com/theforeman/foreman/blob/develop/webpack/assets/javascripts/react_app/routes/Models/ModelsPage/index.js)
- Complex: [HostsIndex](https://github.com/theforeman/foreman/blob/develop/webpack/assets/javascripts/react_app/components/HostsIndex/index.js)
- Katello: `./webpack/scenes/ContentViews/Table/ContentViewsTable.js`

### React Hooks & State Management Gotchas

**useAPI Hook State Timing:**

The `useAPI` hook from Foreman has internal state (`APIOptions`) that doesn't update reactively. When the method changes from `null` to `'post'`, it fires immediately with whatever `APIOptions` are currently set. This can cause race conditions where the API call happens before params are ready.

**Problem Pattern (DON'T DO THIS):**
```javascript
// BAD: API fires before params are set
const { setAPIOptions } = useAPI(
  isReady ? 'post' : null,  // Changes from null to 'post'
  url,
  { key: 'MY_KEY' }
);

useEffect(() => {
  if (isReady) {
    setAPIOptions({ params: myParams });  // Too late! Request already fired
  }
}, [isReady]);
```

**Solution: paramsReady Pattern:**
```javascript
// GOOD: Coordinate API activation with params readiness
const [paramsReady, setParamsReady] = useState(false);
const shouldActivateAPI = hasValidParams && paramsReady;

const { setAPIOptions } = useAPI(
  shouldActivateAPI ? 'post' : null,
  url,
  { key: 'MY_KEY' }
);

useEffect(() => {
  if (hasValidParams && !paramsReady) {
    setAPIOptions({ params: myParams });  // Set params first
    setParamsReady(true);                 // THEN activate
  } else if (!hasValidParams && paramsReady) {
    setParamsReady(false);                // Reset when closed
  }
}, [hasValidParams, paramsReady, myParams, setAPIOptions]);
```

**When to Use replacementResponse:**

Use `replacementResponse` prop on `TableIndexPage` when you need to:
1. Make a POST request instead of GET
2. Control when the API call happens
3. Prevent `TableIndexPage` from making its own API call

Always provide `replacementResponse` when the modal/component is open to prevent unwanted GET requests:

```javascript
const replacementResponse = isOpen ? {
  response: apiResponse || {},
  status: apiStatus || 'PENDING',
  setAPIOptions: wrappedSetAPIOptions,
} : undefined;

<TableIndexPage
  replacementResponse={replacementResponse}
  // ... other props
/>
```

**Reference Implementation:** See `webpack/components/extensions/Hosts/BulkActions/BulkManageTracesModal/BulkManageTracesModal.js` for a complete example.

### Toast Notifications

**Two Toast APIs:**
- **Redux-based (modern):** `store.dispatch(addToast({...}))` - Use for sticky notifications
- **Legacy:** `window.tfm.toastNotifications.notify({...})` - Use for simple notifications

**Job Link Notifications:**

For remote execution jobs, use this pattern to include a link to the job details:

```javascript
import store from 'foremanReact/redux';
import { addToast } from 'foremanReact/components/ToastsList/slice';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';

const rexJobLink = id => ({
  children: __('Go to job details'),
  href: urlBuilder('job_invocations', '', id),
});

// Extract job from response
const successToast = (response) => {
  const jobInvocations = response?.data || [];
  const firstJob = jobInvocations[0];

  if (firstJob?.id) {
    const message = __(`Job '${firstJob.description}' has started.`);
    store.dispatch(addToast({
      message,
      type: 'info',
      link: rexJobLink(firstJob.id),
      sticky: true,
      key: `JOB_TOAST_${firstJob.id}`,
    }));
  }
};
```

**Toast Options:**
- `message`: String or React element - The notification text
- `type`: `'success'`, `'info'`, `'warning'`, `'danger'` - Visual style
- `link`: Object with `children` (link text) and `href` properties
- `sticky`: Boolean - If true, requires manual dismissal
- `key`: Unique identifier for the toast (allows deletion/updates)

**Reference:** See `webpack/scenes/Tasks/helpers.js` for more toast patterns (`renderRexJobStartedToast`, `renderRexJobSucceededToast`, etc.).


## Technical Details

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

### External Service Integration
- **Pulp 3**: Content repository management (packages, containers, etc.)
- **Candlepin**: Subscription and entitlement management
- **Foreman Tasks**: Asynchronous job processing via Dynflow
- **Message Queue**: STOMP-based event system for Candlepin events

### Key Domain Models
- **Organization**: Multi-tenancy container
- **Content View**: Versioned collection of repositories
- **Repository**: Package/content repositories
- **Product**: Grouping of repositories
- **Subscription**: Entitlements for content access
- **Host**: Managed systems consuming content

## Architecture Context

### Overview
Katello is a systems life cycle management plugin for Foreman that provides content and subscription management. It integrates with Pulp (content management) and Candlepin (subscription management) to handle package repositories, subscriptions, and content views for Red Hat Enterprise Linux and Fedora systems.

### Development Environment Setup
The primary setup method is [forklift](https://github.com/theforeman/forklift), which creates a VM with both Foreman and Katello codebases.

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