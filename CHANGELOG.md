# 4.19.0 (2025-12-09)

## Features

### Container
 * Create a manifest details page for the container content UI ([#38863](https://projects.theforeman.org/issues/38863), [2b92c3ce](https://github.com/Katello/katello.git/commit/2b92c3ce0fea65197f9be8348e141fc5ff790bb5))
 * Create a new route/page with tabs for Synced images and Booted images ([#38812](https://projects.theforeman.org/issues/38812), [fb29e74b](https://github.com/Katello/katello.git/commit/fb29e74bfcb5a6e2d07820dfe8dbe81fe79d4521))
 * Add a Remote details page with a table for scanned remote repositories ([#38489](https://projects.theforeman.org/issues/38489), [14e1906c](https://github.com/Katello/katello.git/commit/14e1906cda0b473075f395ec67ab1e107cc2b85c))
 * Global Registration: As a user, I can easily setup certs in the /etc/containers/certs.d/hostname/ directory ([#38455](https://projects.theforeman.org/issues/38455), [6e1f42d9](https://github.com/Katello/katello.git/commit/6e1f42d98966b41bf5b55957d24769976da9f3cf))

### Hosts
 * As a user I want to be able to change the host collection of multiple hosts ([#38829](https://projects.theforeman.org/issues/38829), [6625fe75](https://github.com/Katello/katello.git/commit/6625fe75ffea36a14666d26d1f8d314851b970a0), [7978ce3c](https://github.com/Katello/katello.git/commit/7978ce3c117d683fb91271968afa97c913ce22ad))
 * Add bulk Repository Sets wizard to new All Hosts page ([#38353](https://projects.theforeman.org/issues/38353), [5b64949b](https://github.com/Katello/katello.git/commit/5b64949b046fc600efe432b525edaa6de75ea822))
 * Add Debian support to the new All Hosts --> Manage packages wizard ([#38186](https://projects.theforeman.org/issues/38186), [94e97713](https://github.com/Katello/katello.git/commit/94e97713e1caaa4919e79f58794d4f94170d43ee))

### Reporting
 * Add "updated" to the Erratum Jail ([#38816](https://projects.theforeman.org/issues/38816), [aae5f45a](https://github.com/Katello/katello.git/commit/aae5f45ac31250fedd47a04bf3a15d5c87fcdcc9))

### Repositories
 * Index PRN IDs on all new / updated Pulp entities ([#38809](https://projects.theforeman.org/issues/38809), [b86c40a5](https://github.com/Katello/katello.git/commit/b86c40a5698d68197529e87206303852e0d9757f))
 * Populate PRN columns for Repository versions ([#38778](https://projects.theforeman.org/issues/38778), [4ade1a3e](https://github.com/Katello/katello.git/commit/4ade1a3e90a31fd177687499cd8f1db8fd611889))
 * Populate PRN fields for DB records in a migration ([#38751](https://projects.theforeman.org/issues/38751), [91ae9ea0](https://github.com/Katello/katello.git/commit/91ae9ea06d21c079221ba6a2e83186b57e4cf513))
 * Add pulp prn fields to katello tables with a db migration ([#38743](https://projects.theforeman.org/issues/38743), [988ea8e1](https://github.com/Katello/katello.git/commit/988ea8e1d2fc14627aa46a75ce88a99f33ef3685))
 * Migrate all deb content to use structured APT ([#38741](https://projects.theforeman.org/issues/38741), [f357133a](https://github.com/Katello/katello.git/commit/f357133a9d349f80c172679e6b7cf31723d8f13a))

### Tests
 * Make the new host overview page default ([#38555](https://projects.theforeman.org/issues/38555), [868b6fb7](https://github.com/Katello/katello.git/commit/868b6fb72ad1663bdb71dfd040354e72199797ed))

### Content Views
 * Extend rolling content views to arbitrary lifecycle environments ([#38477](https://projects.theforeman.org/issues/38477), [d8ed5ab5](https://github.com/Katello/katello.git/commit/d8ed5ab5507c6f7e709212459a88a3e2cde4620b))
 * Version option for deb filter rules ([#37729](https://projects.theforeman.org/issues/37729), [445e4d7f](https://github.com/Katello/katello.git/commit/445e4d7f10926bc40c9efbbe8d0e021e82dfa5cf))

### Web UI
 * Create a page with a table listing flatpak remotes in an organization. ([#38385](https://projects.theforeman.org/issues/38385), [151d653d](https://github.com/Katello/katello.git/commit/151d653de49d4efa12305b1ae76e5abd2f67fc68), [04007ef4](https://github.com/Katello/katello.git/commit/04007ef414d9b0bd35b1d485418ee2675e8aab4d))

### Foreman Proxy Content
 * Point to main RHSM URL when rhsm_url is empty on Pulp Smart Proxies ([#38364](https://projects.theforeman.org/issues/38364), [46abdb24](https://github.com/Katello/katello.git/commit/46abdb24234df46c94424cf376b6119e386c8c70))

## Bug Fixes

### Content Views
 * Expand structured APT fallback mechanism for deb content ([#38907](https://projects.theforeman.org/issues/38907), [3994a3ae](https://github.com/Katello/katello.git/commit/3994a3aef6ac83732b87b713863fafe03af02763))
 * 500 error is creating rolling CV via API with no environments ([#38726](https://projects.theforeman.org/issues/38726), [a053c92d](https://github.com/Katello/katello.git/commit/a053c92d0fa4413400d6032492fc6b90224d31f6))
 * Can't create CV from create CV form since empty environment id is passed for all CV types. ([#38721](https://projects.theforeman.org/issues/38721), [d79a2032](https://github.com/Katello/katello.git/commit/d79a20324d1e4ec73b959916018751be9f677117))

### Hosts
 * TypeError: Cannot read properties of undefined (reading 'RowSelectTd') errors on HostsIndex wizards ([#38882](https://projects.theforeman.org/issues/38882), [7c3c7fa8](https://github.com/Katello/katello.git/commit/7c3c7fa8770c5e0f49ac537e596d5a8aabd5990e))
 * Bulk Errata Wizard should only show installable Errata ([#38687](https://projects.theforeman.org/issues/38687), [27921d16](https://github.com/Katello/katello.git/commit/27921d16398d7852349808fc72fb863e5042028a))
 * Need an option to retain build profile information like cve, lce and ks repo id on unregistering hosts ([#38671](https://projects.theforeman.org/issues/38671), [abf3d607](https://github.com/Katello/katello.git/commit/abf3d6078ace9a3055256f77e011e4e7a379728d))

### Container
 * Unauth container content from different orgs shows up for registered hosts ([#38878](https://projects.theforeman.org/issues/38878), [89bef9c6](https://github.com/Katello/katello.git/commit/89bef9c67c4cc5d4d59f55e61178b74228319383))
 * Untagged manifests remain tagged in Katello ([#38865](https://projects.theforeman.org/issues/38865), [9e07e0bf](https://github.com/Katello/katello.git/commit/9e07e0bff8d043452fc710798e1ea38853d7f589))

### Repositories
 * Missing product ID arg shows Ruby error when mirroring flatpak ([#38874](https://projects.theforeman.org/issues/38874), [24107480](https://github.com/Katello/katello.git/commit/241074805b8995c88b0061d5668e3b06437c44c9))
 * Repetitive recalculation of Katello::RepositoryTypeManager.enabled_repository_types makes katello:correct_repositories very slow ([#38838](https://projects.theforeman.org/issues/38838), [3a4bf49f](https://github.com/Katello/katello.git/commit/3a4bf49f481113b03811db52fe8ff1ad8cf9492f))
 * Temporarily pin pulp-rpm-client to 3.32.2 to avoid remote response error ([#38831](https://projects.theforeman.org/issues/38831), [466cde13](https://github.com/Katello/katello.git/commit/466cde13d9c81fdfbb0892e8ccb94042ea423f7c))
 * Error while synchronizing concurrently RPM content - PG::TRDeadlockDetected: ERROR:  deadlock detected ([#38789](https://projects.theforeman.org/issues/38789), [a66ca1b2](https://github.com/Katello/katello.git/commit/a66ca1b2d64dc01847aa30eda4cad0ceb18ed682))
 * Refactor Flatpak pages to use TableIndexPage component ([#38776](https://projects.theforeman.org/issues/38776), [d67b96c0](https://github.com/Katello/katello.git/commit/d67b96c0c4e163e8f94faf4892aba2876bbba6ec))
 * Debian repos are not displayed in the Repository Set Management on the Content Hosts page ([#38296](https://projects.theforeman.org/issues/38296), [d6cf242d](https://github.com/Katello/katello.git/commit/d6cf242d01e1fea3cdfdf64262c8282b4e87b038))

### Hammer
 * Remove entitlements-related Hammer commands and fields ([#38847](https://projects.theforeman.org/issues/38847), [5cc7fd8d](https://github.com/Katello/hammer-cli-katello.git/commit/5cc7fd8def3b954a90292f083bdd83ee8043024b))

### Subscriptions
 * Katello should not send cp-consumer or cp-user header to hosted Candlepin ([#38845](https://projects.theforeman.org/issues/38845), [053c677f](https://github.com/Katello/katello.git/commit/053c677f7e1de9b0ea4f2d73d2edced24deb4c80))
 * Content > Subscriptions stuck in loading state if organization GET ends with 403 ([#38774](https://projects.theforeman.org/issues/38774), [a165abc7](https://github.com/Katello/katello.git/commit/a165abc7feafcce2217cf492e491189ae159db11))
 * Calls to upstream Candlepin consumer fail when using an apiUrl from manifest ([#38724](https://projects.theforeman.org/issues/38724), [8f4da281](https://github.com/Katello/katello.git/commit/8f4da2816a1a44f99dfda030056fe28b53978ddd))

### Roles and Permissions
 * Adjust tests to taxonomy checks being done as part of authorization checks ([#38844](https://projects.theforeman.org/issues/38844), [33f5ba99](https://github.com/Katello/katello.git/commit/33f5ba99a6f0dbf35c59e8b76edf36051f97e4e1), [1f234b5a](https://github.com/Katello/katello.git/commit/1f234b5a3065b426b830465115c7f86d87edfccb))

### Errata Management
 * /hosts/bulk/applicable_errata API is listing installable hosts ([#38824](https://projects.theforeman.org/issues/38824), [0774dc1c](https://github.com/Katello/katello.git/commit/0774dc1c757bca8e68cd7f902f789028a5d60174))
 * Web UI shows incorrect host count when applying an erratum ([#38550](https://projects.theforeman.org/issues/38550), [24ab5f97](https://github.com/Katello/katello.git/commit/24ab5f97fedd90a31eeed6ba42abebfdd3d0c895))
 * Allow for scoped search of 'other' errata types ([#38135](https://projects.theforeman.org/issues/38135), [62ac9abf](https://github.com/Katello/katello.git/commit/62ac9abf08caf9ef3b15bcceb8bb331b7d793b4c))
 * Host details content page does not display 'other' type errata ([#38005](https://projects.theforeman.org/issues/38005), [6d5f7f7a](https://github.com/Katello/katello.git/commit/6d5f7f7a9fa52ed8e798d136af3ca07ef7c6fb02))

### Foreman Proxy Content
 * Pulpcore 3.85 breaks n-1 capsule syncing: gpgcheck cannot be nil ([#38808](https://projects.theforeman.org/issues/38808), [dfc038fa](https://github.com/Katello/katello.git/commit/dfc038fa974cee5c6d5ac7e71fd6eb22a768cb81))
 * Trigger Capsule content repair from UI ([#38662](https://projects.theforeman.org/issues/38662), [95f19923](https://github.com/Katello/katello.git/commit/95f1992397580e7b737a458eb272a9c6f43c1cd9))

### Tooling
 * Upgrade Pulpcore to 3.85 ([#38748](https://projects.theforeman.org/issues/38748), [769a5a17](https://github.com/Katello/katello.git/commit/769a5a179e76316e7b96667b9b45e57255461c44))

### Tests
 * UpdateRollingTest sometimes fails based on array order ([#38745](https://projects.theforeman.org/issues/38745), [ad0659ae](https://github.com/Katello/katello.git/commit/ad0659ae7ab2914f2d3fa37097a1770ed4305bcd))
 * Random content unit test failures ([#38670](https://projects.theforeman.org/issues/38670), [b8c26b82](https://github.com/Katello/katello.git/commit/b8c26b82f9c77f901c467184dcce25cc58aa67a8))

### Organizations and Locations
 * Raw backend error displayed on submitting blank 'New Organisation' form ([#38701](https://projects.theforeman.org/issues/38701), [e1e45f7d](https://github.com/Katello/katello.git/commit/e1e45f7d0bb59eacabee7687c72512612f9d4294))

### Activation Key
 * Multiple content view environments for activation keys do not follow prioritization rules ([#38651](https://projects.theforeman.org/issues/38651))

### Upgrades
 * upgrade fails with unique constraint "index_katello_installed_packages_on_nvrea" ([#38568](https://projects.theforeman.org/issues/38568))

### Web UI
 * Content view publish wizard uses Satellite branding ([#38487](https://projects.theforeman.org/issues/38487))
 * Change content source JS console error: Cannot update a component ('ConnectFunction') while rendering a different component ('Context.Consumer') ([#37256](https://projects.theforeman.org/issues/37256), [1a92fe1e](https://github.com/Katello/katello.git/commit/1a92fe1e8672366f37bc4022695a4f292a5ec84d))

### Other
 * Async Repository::CapsuleSync tasks that don't find any relevant proxies to sync sometimes end up in failing state ([#38546](https://projects.theforeman.org/issues/38546), [a1f951cd](https://github.com/Katello/katello.git/commit/a1f951cd55e7cf58de7413caf70b374164dfce6d))
 * Capsule container repo complete sync fails with 'find' nil error ([#38922](https://projects.theforeman.org/issues/38922), [509c9ae8](https://github.com/Katello/katello.git/commit/509c9ae830223d2f3dcd307b5e7cb55a458d2cf7))
 * Republish repository metadata action should update deb content URL options when needed ([#38912](https://projects.theforeman.org/issues/38912), [c5beb0a5](https://github.com/Katello/katello.git/commit/c5beb0a5f404ef8538de855f5ed767c4c296070d))
 * WebUI broken in nightly: "__FOREMAN_VENDOR__REACT__ is not defined" ([#38584](https://projects.theforeman.org/issues/38584))
 * IPv6 addresses in HTTP proxy URL breaks CDN content retrieval ([#38545](https://projects.theforeman.org/issues/38545), [d6096128](https://github.com/Katello/katello.git/commit/d609612833b63cbc1c6a586ea66abea0e0f71564))
 * undefined method `repository_url' for nil:NilClass ([#37077](https://projects.theforeman.org/issues/37077), [07fdfc35](https://github.com/Katello/katello.git/commit/07fdfc359faade860fc0254e406063a163681043))
