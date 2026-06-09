# 4.21.0 (2026-06-09)

## Features

### Reporting
 * Errata severity macro is not available in 'Host - Applied Errata' report ([#39326](https://projects.theforeman.org/issues/39326), [68ae28af](https://github.com/Katello/katello.git/commit/68ae28afc0d636bfd77e5e386403ca130bb23803))

### Upgrades
 * Create upgrade job to remove publications for all Python repositories in Pulp database ([#39241](https://projects.theforeman.org/issues/39241), [d9c017f5](https://github.com/Katello/katello.git/commit/d9c017f564264aa607892f899d63de187248535f))
 * Update gemspec for Pulp 3.105 bindings ([#39145](https://projects.theforeman.org/issues/39145), [814d47ed](https://github.com/Katello/katello.git/commit/814d47ed5a80366ddf1cc1568cb20fd9e9b6fab9))

### Hosts
 * Hostgroup::ContentFacet should have 1:1 relationship to Content View Environment ([#39223](https://projects.theforeman.org/issues/39223), [81b39aea](https://github.com/Katello/katello.git/commit/81b39aea1cc8b86c2153ce26af89c9ead146ff49))

### Content Credentials
 * Content credentials - new details page ([#39197](https://projects.theforeman.org/issues/39197), [d6c704d5](https://github.com/Katello/katello.git/commit/d6c704d5dbaa2cb8fbc3babf60906bccf852cb1c))
 * New Content Credentials Page - Index page ([#39140](https://projects.theforeman.org/issues/39140), [91b19c66](https://github.com/Katello/katello.git/commit/91b19c66868951dc9cb7d652bb0675c2355d3ca5))
 * Content Credentials - set up initial infrastructure in React ([#39139](https://projects.theforeman.org/issues/39139), [b8794344](https://github.com/Katello/katello.git/commit/b8794344d24e28564bdd4a061391205454a7cd8d))

### Repositories
 * Add extensions repo to Recommended Repositories ([#39157](https://projects.theforeman.org/issues/39157), [6d678ef8](https://github.com/Katello/katello.git/commit/6d678ef8e56333565cc1e7fbca066dea1937ee1f))

### Alternate Content Sources
 * Add Alternate Content Source for Deb Repositories ([#38905](https://projects.theforeman.org/issues/38905), [7a7d9844](https://github.com/Katello/katello.git/commit/7a7d98443bee5f0d6f513769e060e403dfe26971))

## Bug Fixes

### Content Views
 * Incremental update fails with undefined method version_href' for nil:NilClass, when multiple content views are assigned ([#39379](https://projects.theforeman.org/issues/39379), [4d518c12](https://github.com/Katello/katello.git/commit/4d518c12afddcf1f8bc1d7819a409505a172a05e))
 * Fail to delete CV / CCV versions with error "The repository version cannot be deleted because it (or its publications) are currently being used to distribute content" ([#39346](https://projects.theforeman.org/issues/39346), [2c2129b4](https://github.com/Katello/katello.git/commit/2c2129b4bfb9b33b0ca215d3454f2d2ca6129e65))
 * Issue when creating filter in content view using openssl package ([#39217](https://projects.theforeman.org/issues/39217), [1a9c01b0](https://github.com/Katello/katello.git/commit/1a9c01b0bd70068ff9e7cd748ac1e90abbc6e1ea))
 * Incremental update of content view version should throw error when no content is added ([#39214](https://projects.theforeman.org/issues/39214), [1369d868](https://github.com/Katello/katello.git/commit/1369d868bc10b1c2b4550f8170dcf01f5ee11649))
 * Unable to delete empty CCV ([#39155](https://projects.theforeman.org/issues/39155), [6c0c016b](https://github.com/Katello/katello.git/commit/6c0c016bde7e3c114d52256670a4453f8f9bbf95))
 * Replace DeleteLatestContentViewVersion with execution plan callback ([#39150](https://projects.theforeman.org/issues/39150), [e1d797ff](https://github.com/Katello/katello.git/commit/e1d797ff148ab600fcd66fce43d72e085d6ff51a))
 * Composite content view auto publish will be triggered while other component content views are still publishing ([#38856](https://projects.theforeman.org/issues/38856), [fe2026fc](https://github.com/Katello/katello.git/commit/fe2026fcf44ebfe0cd18d4103f1054b7262183d6))

### Performance
 * Missing content_facet_id indexes on join tables cause sequential scans at scale ([#39358](https://projects.theforeman.org/issues/39358), [6027570d](https://github.com/Katello/katello.git/commit/6027570dac84529390192e2918885e0d3f453e5a))

### API
 * API endpoint GET /api/host_packages/installed_packages in apidoc is wrong ([#39351](https://projects.theforeman.org/issues/39351), [7689088f](https://github.com/Katello/katello.git/commit/7689088f5adca89d8834c7c32de8169da16cd379))
 * Non-admin users cannot curl /rhsm/ endpoints even if they have proper permissions ([#39313](https://projects.theforeman.org/issues/39313), [e6c52726](https://github.com/Katello/katello.git/commit/e6c527261559da280c4ffab53850eb9bfdc2d5dd))

### Hosts
 * Changing focus doesn't close dropdowns on bulk repository set wizard ([#39341](https://projects.theforeman.org/issues/39341), [2da142c2](https://github.com/Katello/katello.git/commit/2da142c29371c20a2a44c4161563ec23d0ec653e))
 * Activation Keys tab is blank when creating/editing HostGroup ([#39284](https://projects.theforeman.org/issues/39284), [392ea726](https://github.com/Katello/katello.git/commit/392ea726487440903fdcd4ca8b39a5fc3a680d42))
 * Remove content_facet.uuid usage in favor of subscription_facet.uuid ([#39259](https://projects.theforeman.org/issues/39259), [046cb2aa](https://github.com/Katello/katello.git/commit/046cb2aab3d5957f62b0b844db5472db2ff60248))
 * Hosts end up with a nil content source when registered to a foremanctl setup ([#39257](https://projects.theforeman.org/issues/39257), [489b34f4](https://github.com/Katello/katello.git/commit/489b34f42e42389f861cfdc0faa4ede1199cb180))
 * As an external Smart Proxy user, the web UI allows me to change hosts' content source and preserve multi-environment hosts ([#39216](https://projects.theforeman.org/issues/39216), [2e765f7b](https://github.com/Katello/katello.git/commit/2e765f7bd85a63a781e7a44bfe795fb1a152771a))
 * Remove redundant Candlepin pre-flight check and cache /rhsm/status response ([#39204](https://projects.theforeman.org/issues/39204), [4020849f](https://github.com/Katello/katello.git/commit/4020849f915560ad464d2280988b9d2eb005d49c))
 * Eliminate redundant Candlepin GETs during host registration ([#39202](https://projects.theforeman.org/issues/39202), [9b3e5ffe](https://github.com/Katello/katello.git/commit/9b3e5ffed331c763d46dcd1b0633f11108d1ce7a))
 * Installable updates column has no space between icon and number of updates ([#39170](https://projects.theforeman.org/issues/39170), [ddba2eff](https://github.com/Katello/katello.git/commit/ddba2effd8de55521fc9baa7447dd68543611795))

### Organizations and Locations
 * LoadingState component does not clear setTimeout on unmount ([#39338](https://projects.theforeman.org/issues/39338), [8704fcad](https://github.com/Katello/katello.git/commit/8704fcadc587ec6c645b7cba4b4e748d0f0fb7c2))
 * Organization delete fails with HasManyThroughNestedAssociationsAreReadonly on environment destroy ([#39280](https://projects.theforeman.org/issues/39280), [86d88810](https://github.com/Katello/katello.git/commit/86d88810460fec45118a0348ad3ca36fa4738947))

### Repositories
 * Red Hat container registry authentication not working as expected in Repo Discovery ([#39337](https://projects.theforeman.org/issues/39337), [a6db05da](https://github.com/Katello/katello.git/commit/a6db05da01f01ae24343d173234b67e36203e7fd))
 * Generic content pages are not scoped by organization ([#39319](https://projects.theforeman.org/issues/39319), [3d59fd20](https://github.com/Katello/katello.git/commit/3d59fd2077c993c761b27a1ccae2b7413e53c2f2))
 * Some Pulp tasks not tracked due to change in Pulp update APIs ([#39305](https://projects.theforeman.org/issues/39305), [7b2c98e5](https://github.com/Katello/katello.git/commit/7b2c98e5d6ce0a17bc9af99b46a4d6eb46318913))
 * Custom repository sync does not work without the upstream password ([#39172](https://projects.theforeman.org/issues/39172), [a745ae82](https://github.com/Katello/katello.git/commit/a745ae8253259f4ac85f88abfffc64f4ebec2f8e))
 * Importing content from an URL generates repositories with download_policy on-demand ([#39162](https://projects.theforeman.org/issues/39162), [a26e5d93](https://github.com/Katello/katello.git/commit/a26e5d936c24c3594a3ec817cced803eb6c1b01f))
 * Protected Content should be excluded from Orphan Cleanup ([#39116](https://projects.theforeman.org/issues/39116), [c43051a8](https://github.com/Katello/katello.git/commit/c43051a8486b62f4b39dbb6e00171404b7ad2b97))

### Foreman Proxy Content
 * Ensure load balanced capsules have same data in auth tables ([#39314](https://projects.theforeman.org/issues/39314), [055cc1f9](https://github.com/Katello/katello.git/commit/055cc1f956269446dbb24fa0a65958686f5eac02))
 * n-1/2 proxy syncs with publication-less python repos on 3.105+ pulp ([#39289](https://projects.theforeman.org/issues/39289), [c2e6983e](https://github.com/Katello/katello.git/commit/c2e6983e121ceeb478ace03911201c9a19d83134))
 * Incorrect smart proxy Sync Status after failure ([#39203](https://projects.theforeman.org/issues/39203), [e0d29b1f](https://github.com/Katello/katello.git/commit/e0d29b1fcd2382a836aa3c0d3c82eadf4d9150b0))

### Content Credentials
 * Missing validation to prevent CC deletion when used by ACS ([#39309](https://projects.theforeman.org/issues/39309), [81ba9743](https://github.com/Katello/katello.git/commit/81ba97437249b39ac2459b7fb7322c0e2a29a138))

### Subscriptions
 * Error on Subscriptions UI page ([#39295](https://projects.theforeman.org/issues/39295), [42c240f8](https://github.com/Katello/katello.git/commit/42c240f8c4d26118eba5ae3d72d592894800d2cc))
 * Use AI to rewrite class-based React components as functions with hooks (Red Hat Repositories page, Subscriptions page) ([#38903](https://projects.theforeman.org/issues/38903), [374c9569](https://github.com/Katello/katello.git/commit/374c9569220fb74570e9575c26b869f935ce84ac))

### Activation Key
 * API call to list the activation keys associated with a specific lifecycle environment returns all activation keys in the organization ([#39252](https://projects.theforeman.org/issues/39252), [e29375a8](https://github.com/Katello/katello.git/commit/e29375a85bccdf9b0d641f35d60d178932bb3f6a))
 * Remove Activation Key in Hostgroup does not work on UI ([#38928](https://projects.theforeman.org/issues/38928), [46dc3193](https://github.com/Katello/katello.git/commit/46dc31935c302096e544b454180aafae8335ddc0))

### Other
 * Organization destroy fails with 'Couldn't find Katello::Repository' after PR #11762 ([#39392](https://projects.theforeman.org/issues/39392), [2f4f8b15](https://github.com/Katello/katello.git/commit/2f4f8b152560081b2f77782d936371b58fcf85d3))
# 4.21.0 (2026-05-15)

## Features

### Upgrades
 * Create upgrade job to remove publications for all Python repositories in Pulp database ([#39241](https://projects.theforeman.org/issues/39241), [d9c017f5](https://github.com/Katello/katello.git/commit/d9c017f564264aa607892f899d63de187248535f))
 * Update gemspec for Pulp 3.105 bindings ([#39145](https://projects.theforeman.org/issues/39145), [814d47ed](https://github.com/Katello/katello.git/commit/814d47ed5a80366ddf1cc1568cb20fd9e9b6fab9))

### Hosts
 * Hostgroup::ContentFacet should have 1:1 relationship to Content View Environment ([#39223](https://projects.theforeman.org/issues/39223), [81b39aea](https://github.com/Katello/katello.git/commit/81b39aea1cc8b86c2153ce26af89c9ead146ff49))

### Content Credentials
 * Content credentials - new details page ([#39197](https://projects.theforeman.org/issues/39197), [d6c704d5](https://github.com/Katello/katello.git/commit/d6c704d5dbaa2cb8fbc3babf60906bccf852cb1c))
 * New Content Credentials Page - Index page ([#39140](https://projects.theforeman.org/issues/39140), [91b19c66](https://github.com/Katello/katello.git/commit/91b19c66868951dc9cb7d652bb0675c2355d3ca5))
 * Content Credentials - set up initial infrastructure in React ([#39139](https://projects.theforeman.org/issues/39139), [b8794344](https://github.com/Katello/katello.git/commit/b8794344d24e28564bdd4a061391205454a7cd8d))

### Repositories
 * Add extensions repo to Recommended Repositories ([#39157](https://projects.theforeman.org/issues/39157), [6d678ef8](https://github.com/Katello/katello.git/commit/6d678ef8e56333565cc1e7fbca066dea1937ee1f))

### Alternate Content Sources
 * Add Alternate Content Source for Deb Repositories ([#38905](https://projects.theforeman.org/issues/38905), [7a7d9844](https://github.com/Katello/katello.git/commit/7a7d98443bee5f0d6f513769e060e403dfe26971))

## Bug Fixes

### Content Credentials
 * Missing validation to prevent CC deletion when used by ACS ([#39309](https://projects.theforeman.org/issues/39309), [81ba9743](https://github.com/Katello/katello.git/commit/81ba97437249b39ac2459b7fb7322c0e2a29a138))

### Repositories
 * Some Pulp tasks not tracked due to change in Pulp update APIs ([#39305](https://projects.theforeman.org/issues/39305), [7b2c98e5](https://github.com/Katello/katello.git/commit/7b2c98e5d6ce0a17bc9af99b46a4d6eb46318913))
 * Custom repository sync does not work without the upstream password ([#39172](https://projects.theforeman.org/issues/39172), [a745ae82](https://github.com/Katello/katello.git/commit/a745ae8253259f4ac85f88abfffc64f4ebec2f8e))
 * Importing content from an URL generates repositories with download_policy on-demand ([#39162](https://projects.theforeman.org/issues/39162), [a26e5d93](https://github.com/Katello/katello.git/commit/a26e5d936c24c3594a3ec817cced803eb6c1b01f))
 * Protected Content should be excluded from Orphan Cleanup ([#39116](https://projects.theforeman.org/issues/39116), [c43051a8](https://github.com/Katello/katello.git/commit/c43051a8486b62f4b39dbb6e00171404b7ad2b97))

### Subscriptions
 * Error on Subscriptions UI page ([#39295](https://projects.theforeman.org/issues/39295), [42c240f8](https://github.com/Katello/katello.git/commit/42c240f8c4d26118eba5ae3d72d592894800d2cc))
 * Use AI to rewrite class-based React components as functions with hooks (Red Hat Repositories page, Subscriptions page) ([#38903](https://projects.theforeman.org/issues/38903), [374c9569](https://github.com/Katello/katello.git/commit/374c9569220fb74570e9575c26b869f935ce84ac))

### Foreman Proxy Content
 * n-1/2 proxy syncs with publication-less python repos on 3.105+ pulp ([#39289](https://projects.theforeman.org/issues/39289), [c2e6983e](https://github.com/Katello/katello.git/commit/c2e6983e121ceeb478ace03911201c9a19d83134))
 * Incorrect smart proxy Sync Status after failure ([#39203](https://projects.theforeman.org/issues/39203), [e0d29b1f](https://github.com/Katello/katello.git/commit/e0d29b1fcd2382a836aa3c0d3c82eadf4d9150b0))

### Organizations and Locations
 * Organization delete fails with HasManyThroughNestedAssociationsAreReadonly on environment destroy ([#39280](https://projects.theforeman.org/issues/39280), [86d88810](https://github.com/Katello/katello.git/commit/86d88810460fec45118a0348ad3ca36fa4738947))

### Hosts
 * Hosts end up with a nil content source when registered to a foremanctl setup ([#39257](https://projects.theforeman.org/issues/39257), [489b34f4](https://github.com/Katello/katello.git/commit/489b34f42e42389f861cfdc0faa4ede1199cb180))
 * As an external Smart Proxy user, the web UI allows me to change hosts' content source and preserve multi-environment hosts ([#39216](https://projects.theforeman.org/issues/39216), [2e765f7b](https://github.com/Katello/katello.git/commit/2e765f7bd85a63a781e7a44bfe795fb1a152771a))
 * Remove redundant Candlepin pre-flight check and cache /rhsm/status response ([#39204](https://projects.theforeman.org/issues/39204), [4020849f](https://github.com/Katello/katello.git/commit/4020849f915560ad464d2280988b9d2eb005d49c))
 * Installable updates column has no space between icon and number of updates ([#39170](https://projects.theforeman.org/issues/39170), [ddba2eff](https://github.com/Katello/katello.git/commit/ddba2effd8de55521fc9baa7447dd68543611795))

### Activation Key
 * API call to list the activation keys associated with a specific lifecycle environment returns all activation keys in the organization ([#39252](https://projects.theforeman.org/issues/39252), [e29375a8](https://github.com/Katello/katello.git/commit/e29375a85bccdf9b0d641f35d60d178932bb3f6a))
 * Remove Activation Key in Hostgroup does not work on UI ([#38928](https://projects.theforeman.org/issues/38928), [46dc3193](https://github.com/Katello/katello.git/commit/46dc31935c302096e544b454180aafae8335ddc0))

### Content Views
 * Issue when creating filter in content view using openssl package ([#39217](https://projects.theforeman.org/issues/39217), [1a9c01b0](https://github.com/Katello/katello.git/commit/1a9c01b0bd70068ff9e7cd748ac1e90abbc6e1ea))
 * Incremental update of content view version should throw error when no content is added ([#39214](https://projects.theforeman.org/issues/39214), [1369d868](https://github.com/Katello/katello.git/commit/1369d868bc10b1c2b4550f8170dcf01f5ee11649))
 * Unable to delete empty CCV ([#39155](https://projects.theforeman.org/issues/39155), [6c0c016b](https://github.com/Katello/katello.git/commit/6c0c016bde7e3c114d52256670a4453f8f9bbf95))
 * Replace DeleteLatestContentViewVersion with execution plan callback ([#39150](https://projects.theforeman.org/issues/39150), [e1d797ff](https://github.com/Katello/katello.git/commit/e1d797ff148ab600fcd66fce43d72e085d6ff51a))
 * Composite content view auto publish will be triggered while other component content views are still publishing ([#38856](https://projects.theforeman.org/issues/38856), [fe2026fc](https://github.com/Katello/katello.git/commit/fe2026fcf44ebfe0cd18d4103f1054b7262183d6))
