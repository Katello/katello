# Development and Troubleshooting Context
This document contains information regarding common development practices and issues encountered with Foreman/Katello development.

For additional context, see [Quick Reference](./quick_reference.md) for command quick references and a directory of detailed guides.

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
1. **Migration**: `cd $GITDIR/foreman && bundle exec rails g migration [model_name]` and move created migration file from `$GITDIR/foreman/db/migrate/...` to `$GITDIR/katello/db/migrate/...`
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

### UI Components & Patterns
**TableIndexPage - Use for All Table Pages**
Always use `TableIndexPage` from Foreman when creating new table-based UI pages. See [Table Index Page](./table_index_page_patterns.md) for details.

**References:**
- [Table Index Page](./table_index_page_patterns.md)
- Simple [ModelsPage](https://github.com/theforeman/foreman/blob/develop/webpack/assets/javascripts/react_app/routes/Models/ModelsPage/index.js)
- Complex: [HostsIndex](https://github.com/theforeman/foreman/blob/develop/webpack/assets/javascripts/react_app/components/HostsIndex/index.js)
- Katello: `./webpack/scenes/ContentViews/Table/ContentViewsTable.js`

### React Hooks & State Management Gotchas
**useAPI Hook State Timing:**
The `useAPI` hook from Foreman has internal state (`APIOptions`) that doesn't update reactively. When the method changes from `null` to `'post'`, it fires immediately with whatever `APIOptions` are currently set. This can cause race conditions where the API call happens before params are ready.

**Problem Pattern (DON'T DO THIS):**
```javascript
// BAD: API fires before params are set
const { setAPIOptions } = useAPI(
  isReady ? 'post' : null,
  url,
  { key: 'MY_KEY' }
);

useEffect(() => {
  if (isReady) {
    setAPIOptions({ params: myParams });  // Too late! Request already fired
  }
}, [isReady]);
```

**Solution: syncWithOptions Pattern:**
Use `syncWithOptions` to automatically sync params when they change:

```javascript
const myParams = useMemo(() => {
  if (!isReady) return {};
  return {
    foo: param1,
    bar: param2,
    baz: 20,
    // ... any other params
  };
}, [isReady, param1, param2]);

const { setAPIOptions } = useAPI(
  isReady ? 'post' : null,  // Simple activation - no paramsReady needed
  url,
  {
    key: 'MY_KEY',
    params: myParams,         // Params included from the start
    syncWithOptions: true,    // Auto-updates when params change
  }
);
```

**Legacy Pattern (if working with older code):**
You may see a `paramsReady` pattern in existing code that manually coordinates param setting with API activation. This pattern predates `syncWithOptions` and can be replaced with the pattern above.

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

## Troubleshooting

### Bundle/Gem Issues
**Symptoms**: "Could not find gem", version conflicts
**Solution**:
```bash
cd $GITDIR/foreman
bundle install
bundle update # If needed
bundle exec [command]
```

### Test Failures
**Symptoms**: Database errors, setup failures
**Solution**:
```bash
cd $GITDIR/foreman
bundle exec rake katello:reset  # If needed (destroys data)
RAILS_ENV=test bundle exec rake db:drop
RAILS_ENV=test bundle exec rake db:create
RAILS_ENV=test bundle exec rake db:migrate
RAILS_ENV=test bundle exec rake db:seed
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

### ESLint False Positives
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