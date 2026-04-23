# Pulp 3.105 API Changes Analysis - AsyncUpdateMixin Impact

## Executive Summary

Pulp 3.105 introduced PULP-734 ("Only Use Tasks When Necessary"), which changed ALL update endpoints to return:
- **202 Accepted** with `AsyncOperationResponse` when changes are made
- **200 OK** or **204 No Content** (nil/empty response) when no changes detected

This affects **6 ViewSets** via `AsyncUpdateMixin` base class.

## Affected Pulp ViewSets

| Pulpcore ViewSet | Affected Resources |
|------------------|-------------------|
| RemoteViewSet | All remotes (RPM, ULN, File, Ansible Collection/Git/Role, Container, PullThrough, Deb, Python, OSTree) |
| RepositoryViewSet | All repositories (RPM, File, Ansible, Container, Deb, Python, OSTree) |
| DistributionViewSet | All distributions (RPM, File, Ansible, Container, PullThrough, Deb, Python, OSTree) |
| ExporterViewSet | Pulp exporters |
| AlternateContentSourceViewSet | RPM ACS, Deb ACS |
| DomainViewSet | Pulp domains |

## Pulp Upstream Changes

**Primary Commit:** https://github.com/pulp/pulpcore/commit/c8ca610a4e968c10fde8bf607b9f384f892d216c
**Tracker:** https://redhat.atlassian.net/browse/PULP-734

The change was implemented in Pulp's base `AsyncUpdateMixin` class, affecting all viewsets that inherit from it.

---

## Current Status in Katello (as of commit b71861f681)

### ✅ FIXED - Methods Updated

#### 1. RemoteViewSet - `partial_update()`
- **app/services/katello/pulp3/repository.rb:114**
  ```ruby
  response = api.get_remotes_api(href: href).partial_update(href, remote_options)
  response if response.respond_to?(:task) && response.task.present?
  ```
  - Called by: `Actions::Pulp3::Repository::UpdateRemote` (AbstractAsyncTask ✅)

- **app/services/katello/pulp3/alternate_content_source.rb:93**
  ```ruby
  response = api.get_remotes_api(href: href).partial_update(href, remote_options)
  response if response.respond_to?(:task) && response.task.present?
  ```
  - Called by: `Actions::Pulp3::AlternateContentSource::UpdateRemote` (AbstractAsyncTask ✅)

- **app/services/katello/pulp3/repository_mirror.rb:30**
  ```ruby
  response = api.remotes_api.partial_update(href, remote_options)
  (response.respond_to?(:task) && response.task.present?) ? [response] : []
  ```
  - Returns array format (internal mirror usage)

#### 2. DistributionViewSet - `partial_update()`
- **app/services/katello/pulp3/repository.rb:332**
  ```ruby
  response = api.distributions_api.partial_update(distribution_reference.href, options)
  response if response.respond_to?(:task) && response.task.present?
  ```
  - Called by: `Actions::Pulp3::Repository::SaveDistributionReferences` via `update_distribution`

- **app/services/katello/pulp3/repository_mirror.rb:202**
  ```ruby
  response = api.distributions_api.partial_update(distro.pulp_href, dist_options)
  (response.respond_to?(:task) && response.task.present?) ? [response] : []
  ```

#### 3. ExporterViewSet - `partial_update()`
- **app/services/katello/pulp3/content_view_version/export.rb:120**
  ```ruby
  api.exporter_api.partial_update(exporter_href, :last_export => nil)
  ```
  - Called by: `Actions::Pulp3::ContentViewVersion::DestroyExporter` (AbstractAsyncTask ✅)
  - **Status:** Fixed via AbstractAsyncTask.transform_task_response

#### 4. AbstractAsyncTask Response Handler
- **app/lib/actions/pulp3/abstract_async_task.rb:96-110**
  - Handles new `AsyncOperationResponse` format with `@task` attribute
  - Compacts nil responses
  - ✅ Works for all actions extending `AbstractAsyncTask`

---

### ⚠️ NOT FIXED - Missing Updates

#### 1. RepositoryViewSet - `update()` [CRITICAL]
**Locations:**

- **app/services/katello/pulp3/repository.rb:220**
  ```ruby
  def update
    api.repositories_api.update(repository_reference.try(:repository_href), create_options)
  end
  ```
  - **Called by:** `Actions::Pulp3::Repository::UpdateRepository#run`
  - **Action inheritance:** `Pulp3::Abstract` (NOT AbstractAsyncTask!)
  - **Problem:** Action sets `output[:response]` but doesn't expect async tasks
  - **Impact:** HIGH - This is a fundamental operation

- **app/services/katello/pulp3/repository_mirror.rb:61**
  ```ruby
  def update
    api.repositories_api.update(repository_href, name: backend_object_name)
  end
  ```
  - **Called by:** Internal mirror operations
  - **Impact:** MEDIUM - Smart proxy mirroring

#### 2. AlternateContentSourceViewSet - `update()` [HIGH]
- **app/services/katello/pulp3/alternate_content_source.rb:129**
  ```ruby
  def update_alternate_content_source(href = smart_proxy_acs.alternate_content_source_href)
    api.alternate_content_source_api.update(href, name: generate_backend_object_name, 
                                            paths: paths.sort, remote: smart_proxy_acs.remote_href)
  end
  ```
  - **Called by:** `Actions::Pulp3::AlternateContentSource::Update#invoke_external_task`
  - **Action inheritance:** `AbstractAsyncTask` ✅
  - **Problem:** Return value needs conditional check like remotes/distributions
  - **Impact:** HIGH - ACS updates may fail or hang

#### 3. DomainViewSet - `update()` / `partial_update()` [UNKNOWN]
- **Status:** No domain update calls found in codebase
- **Impact:** LOW - Domains may not be actively used in Katello yet

---

## Required Changes

### 1. Fix RepositoryViewSet.update() Calls

**File: app/services/katello/pulp3/repository.rb**
```ruby
def update
  response = api.repositories_api.update(repository_reference.try(:repository_href), create_options)
  # Pulp 3.90+ returns polymorphic responses (PULP-734):
  # - AsyncOperationResponse with @task attribute for updates
  # - HTTP 200/204 when no changes detected
  response if response.respond_to?(:task) && response.task.present?
end
```

**File: app/services/katello/pulp3/repository_mirror.rb**
```ruby
def update
  response = api.repositories_api.update(repository_href, name: backend_object_name)
  # Pulp 3.90+ returns polymorphic responses (PULP-734)
  (response.respond_to?(:task) && response.task.present?) ? [response] : []
end
```

### 2. Fix AlternateContentSourceViewSet.update()

**File: app/services/katello/pulp3/alternate_content_source.rb**
```ruby
def update_alternate_content_source(href = smart_proxy_acs.alternate_content_source_href)
  paths = acs.subpaths.deep_dup
  if acs.content_type == ::Katello::Repository::FILE_TYPE && acs.subpaths.present?
    paths = insert_pulp_manifest!(paths)
  end
  response = api.alternate_content_source_api.update(href, name: generate_backend_object_name, 
                                                     paths: paths.sort, remote: smart_proxy_acs.remote_href)
  # Pulp 3.90+ returns polymorphic responses (PULP-734)
  response if response.respond_to?(:task) && response.task.present?
end
```

---

## Testing Strategy

### 1. Unit Tests to Update/Create

- **test/actions/pulp3/repository/update_repository_test.rb**
  - Test repository update with no changes (should handle nil/empty response)
  
- **test/actions/pulp3/alternate_content_source/update_test.rb**
  - Test ACS update with no changes

- **test/services/pulp3/repository_test.rb**
  - Test `update()` method with both 202 and 200 responses

- **test/services/pulp3/repository_mirror_test.rb**
  - Test mirror update scenarios

### 2. VCR Re-recording
After code changes, re-record VCRs for:
```bash
cd $GITDIR/foreman
mode=all ktest ~/katello/test/actions/pulp3/repository/update_repository_test.rb
mode=all ktest ~/katello/test/actions/pulp3/alternate_content_source/update_test.rb
```

### 3. Manual Testing Scenarios

1. **Repository Update - No Changes:**
   - Update repository with same metadata checksum type
   - Verify no tasks created, operation succeeds

2. **Repository Update - With Changes:**
   - Update repository metadata checksum type
   - Verify task created and tracked

3. **ACS Update - No Changes:**
   - Update ACS with same paths
   - Verify no tasks created

4. **ACS Update - With Changes:**
   - Update ACS with new paths
   - Verify task created and tracked

---

## Open Questions for Ian

1. **UpdateRepository Action Inheritance:**
   - `UpdateRepository` extends `Pulp3::Abstract` (not AbstractAsyncTask)
   - Does this action actually expect tasks? Or is repository update synchronous?
   - Should we change the action to extend `AbstractAsyncTask`?

2. **Ruby Bindings Verification:**
   - Have the Ruby bindings been verified to properly handle `AsyncOperationResponse` objects?
   - Do they correctly return `nil` for 204 responses?
   - Ian mentioned concerns about binding issues - has this been validated?

3. **Domains:**
   - Are domains actively used in Katello?
   - Do we need to worry about domain update operations?

4. **Backwards Compatibility:**
   - Comments mention "Pulp 3.90+" - should we verify these work back to N-2?
   - What's the minimum Pulp version we need to support?

---

## Risk Assessment

### HIGH RISK - Immediate Attention Needed
- **repositories_api.update()** - Core repository operations
- **alternate_content_source_api.update()** - ACS management

### MEDIUM RISK - Verify and Test
- **repository_mirror.rb updates** - Smart proxy syncing

### LOW RISK - Monitor
- **Domain updates** - Not actively used

### ALREADY MITIGATED
- **All partial_update() calls** - Fixed in b71861f681
- **AbstractAsyncTask response handling** - Fixed in b71861f681

---

## Next Steps

1. ✅ Create this analysis document
2. ⬜ Apply code fixes to `repositories_api.update()` and `alternate_content_source_api.update()`
3. ⬜ Write/update unit tests
4. ⬜ Re-record VCRs for affected tests
5. ⬜ Manual testing of all scenarios
6. ⬜ Verify Ruby bindings handle polymorphic responses
7. ⬜ Check N-1/N-2 Pulp compatibility
8. ⬜ Update commit message to reference PULP-734

---

## Additional Notes

- The fix pattern is consistent: capture response, check for task presence, return conditionally
- AbstractAsyncTask already handles the new response format via `transform_task_response`
- The comments in the code mention "Pulp 3.90+" but PULP-734 was completed in 3.105
- Some methods return single response, others return arrays (mirror operations) - maintain consistency
