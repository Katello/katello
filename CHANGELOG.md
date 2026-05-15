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
