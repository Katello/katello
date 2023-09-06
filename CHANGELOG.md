# 4.9.2 (2023-09-26)

## Bug Fixes

### Content Views
 * undefined method '#single_content_view' for Katello::Host::ContentFacet::Jail (Katello::Host::ContentFacet) (Safemode::NoMethodError) ([#36684](https://projects.theforeman.org/issues/36684), [05690632](https://github.com/Katello/katello.git/commit/05690632cb3d0a501192c6e645fa6ee4466de187))
 * Re-synchronizing the repository whose sync had failed earlier, the Content View does not display new upgradable packages that are available. ([#36622](https://projects.theforeman.org/issues/36622), [4e3d804e](https://github.com/Katello/katello.git/commit/4e3d804e104098e5f1b6c604ff55aeb01f9db971))
 * Filter gets applied to all the repository upon removal of repository for which the filter was created. ([#36577](https://projects.theforeman.org/issues/36577), [49a55b14](https://github.com/Katello/katello.git/commit/49a55b142600866ac9e384b4230e91a7c2e03960))
 * Content View comparison - RPM packages search missing auto completion ([#36516](https://projects.theforeman.org/issues/36516), [76fdd41f](https://github.com/Katello/katello.git/commit/76fdd41fcf9f8650cf188612cd5cecc7d41125c7))

### Hosts
 * Hammer accepts non-existent LCE in host update ([#36667](https://projects.theforeman.org/issues/36667), [05b73f70](https://github.com/Katello/katello.git/commit/05b73f708fbebf6a5118da91dd75f888d9432605))
 * Errors due to lack of safe navigation when you try to customize a discovered host ([#36608](https://projects.theforeman.org/issues/36608), [5f1e74d2](https://github.com/Katello/katello.git/commit/5f1e74d27e40b429a9ba8f81307e7554cf5dc244))
 * Error when autoprovision/provision for a discovered host ([#36601](https://projects.theforeman.org/issues/36601), [e834c88d](https://github.com/Katello/katello.git/commit/e834c88d8a8cb95bd24d6bc2de6ec0d7054aae62))
 * undefined method `each' for #<Katello::ContentViewEnvironment when running hammer host subscription register ([#36524](https://projects.theforeman.org/issues/36524), [f579e498](https://github.com/Katello/katello.git/commit/f579e4989f92f66c30608eac3c6d6426e6aa6dbe))
 * undefined method `content_view=' for #<Katello::Host::ContentFacet:0x00007fc530855ac8> ([#36504](https://projects.theforeman.org/issues/36504), [ccd234ac](https://github.com/Katello/katello.git/commit/ccd234acfa7c7294f036d3904b01ca74aed9a985))
 * Editing a host results in an error "content_view_id and lifecycle_environment_id must be provided together" ([#36498](https://projects.theforeman.org/issues/36498), [08941da7](https://github.com/Katello/katello.git/commit/08941da7038f16286688e237824560442f8afb54))
 * Can't add hostgroup to new host ([#36462](https://projects.theforeman.org/issues/36462), [2fdd82af](https://github.com/Katello/katello.git/commit/2fdd82af41cb95ea54b48a59f535ab0e40af6436))
 * hammer host update fails with "unknown attribute ‘content_view_id’ for Katello::Host::ContentFacet" when you pass a content view / LCE ([#36440](https://projects.theforeman.org/issues/36440), [0a200518](https://github.com/Katello/katello.git/commit/0a200518702c6d87ade221a030701dfe6e8cab22))
 * Arch restriction label missing from Repository sets for repos without URL ([#36430](https://projects.theforeman.org/issues/36430), [338eb1db](https://github.com/Katello/katello.git/commit/338eb1dbe72be020ea02bc088afed2e3607aacfc))

### Alternate Content Sources
 * Custom ACS path help text is missing file:// ([#36631](https://projects.theforeman.org/issues/36631), [9b68b005](https://github.com/Katello/katello.git/commit/9b68b005185e0c9fe421d49a5961bb6a3239dc0e))

### Repositories
 * hammer- allow user to run Verify Content Checksum, on container repositories. ([#36625](https://projects.theforeman.org/issues/36625), [03101039](https://github.com/Katello/katello.git/commit/031010390a8b089377c6ecff51f69548b0ea1685))
 * Repository details page shouldn't say 'enabled by default' ([#36593](https://projects.theforeman.org/issues/36593), [6b1d742c](https://github.com/Katello/katello.git/commit/6b1d742c9d8ec2ee40efba1c9bdacd5683678beb))
 * Upgrade to Katello 4.5 can fail if some on_demand repositories have checksum_type set ([#36562](https://projects.theforeman.org/issues/36562), [f0ab69db](https://github.com/Katello/katello.git/commit/f0ab69db3927014c5e570366162d8bbb1fbc6044))
 * Optimize DockerMetaTag query and CV version deletion to run a single invocation of the method. ([#36500](https://projects.theforeman.org/issues/36500), [6077a1ec](https://github.com/Katello/katello.git/commit/6077a1ecf4221470fe3eaadbf6822477bf6ee707))
 * Can't remove GPG and SSL Keys from existing Product using the API ([#36497](https://projects.theforeman.org/issues/36497), [5dc7382e](https://github.com/Katello/katello.git/commit/5dc7382e8b9abe55847b67558af7405e8a59468b))

### Client/Agent
 * tasks Actions::Katello::BulkAgentAction without any sub-plans and stuck in running/pending ([#36528](https://projects.theforeman.org/issues/36528), [f9bf7d00](https://github.com/Katello/katello.git/commit/f9bf7d0065c55e202275de84b9c69b5ebbca9ed0))

### Foreman Proxy Content
 * Optimized capsule sync doesn't sync recently published/promoted docker repositories ([#36523](https://projects.theforeman.org/issues/36523), [1429ec99](https://github.com/Katello/katello.git/commit/1429ec99c7916a6954fda50040397eb1f0142d6a))

### Inter Server Sync
 * hammer content import fails with undefined method `substitutor' for nil:NilClass during import content if product being imported is not covered by subscriptions on the manifest ([#36521](https://projects.theforeman.org/issues/36521), [58dcb484](https://github.com/Katello/katello.git/commit/58dcb484f07c16b033d238b57f3e77206b02f3f9))

### Errata Management
 * Allow installable errata count methods ([#36506](https://projects.theforeman.org/issues/36506), [f3dba82d](https://github.com/Katello/katello.git/commit/f3dba82d5f35f679c0f7906cf07e211a716b6785))

# 4.9.1 (2023-07-20)

## Bug Fixes

### Web UI
 * Fix lint errors  ([#36609](https://projects.theforeman.org/issues/36609), [ecfb84a0](https://github.com/Katello/katello.git/commit/ecfb84a04a724fd5c906961a0a1dbd6247497065))

### Subscriptions
 * Reasons for not deleting the manifest don't apply with SCA enabled ([#36604](https://projects.theforeman.org/issues/36604), [1896c347](https://github.com/Katello/katello.git/commit/1896c34786d4ebdc8a4dc7027bb33dc3242da0ee))

### Tests
 * Pin ostree binding on nightly for tests to pass. ([#36586](https://projects.theforeman.org/issues/36586), [ba8eb2ae](https://github.com/Katello/katello.git/commit/ba8eb2ae61121065e80b9511bac0bd1ad5a3b049))

### Content Views
 * hammer content-view version info --include-applied-filters true should display rules ([#36585](https://projects.theforeman.org/issues/36585), [05ef2c83](https://github.com/Katello/hammer-cli-katello.git/commit/05ef2c83a5bd102049b827ad3ad06acf2b4c478f))
 * Hammer should treat indeterminate needs_publish as publish_needed. ([#36581](https://projects.theforeman.org/issues/36581), [945e2e7f](https://github.com/Katello/katello.git/commit/945e2e7f628fb9752e5ae79fc71a2234b71257ad))
 * Content view dependency solving should be tracked for needs_publish ([#36580](https://projects.theforeman.org/issues/36580), [d1a991e9](https://github.com/Katello/katello.git/commit/d1a991e96a66171708907b936827d0902d5d97b4))
 * CV page needs refresh to get the current filters state ([#36529](https://projects.theforeman.org/issues/36529), [009f5c64](https://github.com/Katello/katello.git/commit/009f5c64ae900957b9f895e725815561139a213f))

### Repositories
 * 4.9 is slow to sync and index repositories ([#36563](https://projects.theforeman.org/issues/36563), [51f7a12e](https://github.com/Katello/katello.git/commit/51f7a12e2c591ac7132faa822b9872528d8e5fd8))

### Foreman Proxy Content
 * The "POST /katello/api/capsules/:id/reclaim_space" endpoint is wrong ([#36545](https://projects.theforeman.org/issues/36545), [a29414b5](https://github.com/Katello/katello.git/commit/a29414b5650c99afe01ae8aa8f9aa1dde0ed17b3))

### Upgrades
 * Upgrade rake task will create bad content overrides on post-4.9 Katello upgrades ([#36540](https://projects.theforeman.org/issues/36540), [ee53d52f](https://github.com/Katello/katello.git/commit/ee53d52ff09b17f1204a88ef7f99207b1d332411))

### Inter Server Sync
 * Exporting repositories that have architecture restrictions results in bogus data that can't be properly imported ([#36477](https://projects.theforeman.org/issues/36477), [79ad3adf](https://github.com/Katello/katello.git/commit/79ad3adf14ed97a9bd3eaa13191cfc2dadab24ff))

# 4.9.0 (2023-06-21)

## Features

### Web UI
 * Add ouia-id to Tab ([#36478](https://projects.theforeman.org/issues/36478), [bd0d06af](https://github.com/Katello/katello.git/commit/bd0d06af6a8741b70dffa47cdef3acb0393f6cc0))
 * Change default status of shown repositories in content view ([#36035](https://projects.theforeman.org/issues/36035), [d400e399](https://github.com/Katello/katello.git/commit/d400e3996f068841259b6d4274288f547e7a5f06))

### Repositories
 * Add ability to skip syncing treeinfo files ([#36411](https://projects.theforeman.org/issues/36411), [981f8a6f](https://github.com/Katello/katello.git/commit/981f8a6fed2e4c2a919d5ed22608c3f0721ebfd3), [a44d283c](https://github.com/Katello/katello.git/commit/a44d283c896307205d235db24fd6a9040a48d6c0))
 * [RFE] Allow updating metadata_expire for custom repositories ([#36352](https://projects.theforeman.org/issues/36352), [f0891806](https://github.com/Katello/katello.git/commit/f089180681cdc700bd715b77497d5e8d260cabb3))
 * Add an easy way to enable/disable all custom repos on activation keys ([#35722](https://projects.theforeman.org/issues/35722), [535666ac](https://github.com/Katello/katello.git/commit/535666ac7758ea52fd1f995c8b9b43cdc894d352))

### Content Views
 * Set needs_publish to true for versions published with a failed task ([#36410](https://projects.theforeman.org/issues/36410), [5628bc3e](https://github.com/Katello/katello.git/commit/5628bc3e7300c6254a1fd6a5c7fc5050911e0d8d))
 * Update UI to reflect needs_publish disabled flag for CVs with audits cleaned up ([#36397](https://projects.theforeman.org/issues/36397), [31cb8fc1](https://github.com/Katello/katello.git/commit/31cb8fc1c849509767954946ce79a3837951179c))
 * Update UI to reflect needs_publish on CV ([#36270](https://projects.theforeman.org/issues/36270), [06ca735d](https://github.com/Katello/katello.git/commit/06ca735d39db8e9da057bd3d241a89793984fe77))
 * Update API, publish action and rabl with "needs_publish" from content view ([#36269](https://projects.theforeman.org/issues/36269), [e75e0359](https://github.com/Katello/katello.git/commit/e75e0359da2fdbc11b423addd9b076356c68b202))
 * Add audit to filter and filter rules changes that need a publish of content view ([#36268](https://projects.theforeman.org/issues/36268), [9f68c59c](https://github.com/Katello/katello.git/commit/9f68c59cc9ea23d1ba36f597992b713cd9148807))
 * Add audit to repository changes that need a publish of content view ([#36267](https://projects.theforeman.org/issues/36267), [fbc81d44](https://github.com/Katello/katello.git/commit/fbc81d4496f0e55550f055f0dcbc28cd248125a4), [f4046e11](https://github.com/Katello/katello.git/commit/f4046e11b92a3af2493f849e399654b298934f33))
 * Create a new applied_filters field in CV version table and store filters at time of publish in Human readable format. ([#36251](https://projects.theforeman.org/issues/36251), [71d7beb3](https://github.com/Katello/katello.git/commit/71d7beb3869be3410c4ead9468a0354d3579e659))
 *  Add a link to filters in the review page of CV publish ([#36250](https://projects.theforeman.org/issues/36250), [63757c01](https://github.com/Katello/katello.git/commit/63757c0179c41c2bb062cbb8a3e02dabaa1ac073))
 * Content view dropdown should be visible but disabled until you select an environment ([#36184](https://projects.theforeman.org/issues/36184), [1627e46b](https://github.com/Katello/katello.git/commit/1627e46b0be984d7a4d507f6a04a9c0b71a24663))

### Hosts
 * Should not be able to assign LE on the client profile which is not synced on the capsule server ([#36316](https://projects.theforeman.org/issues/36316), [b778e209](https://github.com/Katello/katello.git/commit/b778e20991e745e50b0175c519c06c311a382691))

### Subscriptions
 * Make it easier to specify the content for content overrides ([#36284](https://projects.theforeman.org/issues/36284), [59d51c96](https://github.com/Katello/hammer-cli-katello.git/commit/59d51c96b93d9e62ba91bd8ca60ecc1550e72774))
 * Add an easy way to enable/disable all custom repos on a host ([#36178](https://projects.theforeman.org/issues/36178), [8ae74c64](https://github.com/Katello/katello.git/commit/8ae74c64d5c09338ae26da99882ca360585bde39), [b82372a0](https://github.com/Katello/katello.git/commit/b82372a01c617d97e541be9af7c2b78c0d9c5355))
 * Custom products should be disabled by default ([#36120](https://projects.theforeman.org/issues/36120), [52b6d897](https://github.com/Katello/katello.git/commit/52b6d8978a0d11daaef62c72e9c145294f6a5628), [dc6579f0](https://github.com/Katello/katello.git/commit/dc6579f06a0e38c392b57c8a0686f3f0b14d2f2f), [260e7b2b](https://github.com/Katello/katello.git/commit/260e7b2bb5d9d5b1bebc97b3a81f46077616ad7c), [55972ecf](https://github.com/Katello/katello.git/commit/55972ecfea54cfa2035e5571cb4188c2c9fc478a))

### Errata Management
 * "Installable Errata" in report template ([#30664](https://projects.theforeman.org/issues/30664), [96d978aa](https://github.com/Katello/katello.git/commit/96d978aadf84534a6ed9b48e53b6f77ae5faf78a))

### Other
 * Add applied_filters to hammer ([#36355](https://projects.theforeman.org/issues/36355), [72fbe19c](https://github.com/Katello/hammer-cli-katello.git/commit/72fbe19c5debf0657042a1186ddbcaa40c431f47))
 * Calculate needs_publish for composite content views based on component CV needs_publish ([#36333](https://projects.theforeman.org/issues/36333), [25061d6f](https://github.com/Katello/katello.git/commit/25061d6fb53c7303da9e666d2ad16e648a1f15ab))
 * Ensure valid needs_published for old records and CVs with deleted audit records. ([#36320](https://projects.theforeman.org/issues/36320), [481bba06](https://github.com/Katello/katello.git/commit/481bba06f0e554169e67c6e759247737cd3144f0))
 * Hosts should upload package profile after content view / lifecycle environment change ([#36256](https://projects.theforeman.org/issues/36256), [18d404c8](https://github.com/Katello/katello.git/commit/18d404c80c13f7b5e814031a3fd227b06ca7c0cd))

## Bug Fixes

### Organizations and Locations
 * edit_organization permissions needed on upstream satellite  ([#36503](https://projects.theforeman.org/issues/36503), [fe0481cd](https://github.com/Katello/katello.git/commit/fe0481cd6c9ddcdf9f923675560a3c0d6ef207e8))

### Repositories
 * Bump recommended Red Hat repos for 6.14 ([#36485](https://projects.theforeman.org/issues/36485), [335e1efe](https://github.com/Katello/katello.git/commit/335e1efed5a897b564e6011a2000878713c81485))
 * Prevent regenerating metadata for repositories that use complete mirroring ([#36453](https://projects.theforeman.org/issues/36453), [161ccdaf](https://github.com/Katello/katello.git/commit/161ccdaf90f4ab8bc6d6d27bfb04ac2689acdf9f))
 * Make metadata_expire field optional ([#36435](https://projects.theforeman.org/issues/36435), [64c34c70](https://github.com/Katello/katello.git/commit/64c34c7094a61d47cc1abb7588c5eb90301b0981))
 * Bring back the option to Republish Repository\CV Version metadata in web UI ([#36417](https://projects.theforeman.org/issues/36417), [8c5426eb](https://github.com/Katello/katello.git/commit/8c5426ebf613d6d8cfe21e1805a9182e6593f7ba))
 * Add metadata expire option for custom repo to UI and hammer ([#36373](https://projects.theforeman.org/issues/36373), [b2c46a36](https://github.com/Katello/hammer-cli-katello.git/commit/b2c46a36925e55c498712a66969eb2a8adc84f3d), [7f4aa62f](https://github.com/Katello/katello.git/commit/7f4aa62f535e8773baed2587dc248a7df81919e7))
 * Container images Repository Discovery against v2-only API always reports "No discovered repositories" ([#36362](https://projects.theforeman.org/issues/36362), [f6a1688f](https://github.com/Katello/katello.git/commit/f6a1688f8078bc50bc1140ca8ea66115cdd9aecf))
 * ACS Products in details should present a better empty view rather than blank. ([#36176](https://projects.theforeman.org/issues/36176), [ed9fd95a](https://github.com/Katello/katello.git/commit/ed9fd95a27cb495fed24cfe794068ef14aae9bc6))
 * Update ssl cert error message for ACS to include "Simplified" ([#36174](https://projects.theforeman.org/issues/36174), [23d1b81f](https://github.com/Katello/katello.git/commit/23d1b81fc6ab10d6811ee1fad8c5823c6c0aaab4))
 * use-http-proxy switch does not work properly ([#36102](https://projects.theforeman.org/issues/36102), [c693539f](https://github.com/Katello/katello.git/commit/c693539f564315ab3e8e5e891ecba96ac675e1e2))

### Hosts
 * User with "Register Hosts" role ignores all the setup options. ([#36484](https://projects.theforeman.org/issues/36484), [56417cc7](https://github.com/Katello/katello.git/commit/56417cc7ef61b436a4ab95bfcdb7e8c82a8562a6))
 * Installable updates links on the hosts page still link to the old content host detail page. ([#36254](https://projects.theforeman.org/issues/36254), [38d1581e](https://github.com/Katello/katello.git/commit/38d1581ece23303b443fe10feede7a88979bd911))
 * Add export definitions for columns ([#36132](https://projects.theforeman.org/issues/36132), [930847cf](https://github.com/Katello/katello.git/commit/930847cf62243afa1448f752ab4cb7480d9b5ffd))
 * Package upgradable versions are not set correctly based on architecture ([#36100](https://projects.theforeman.org/issues/36100), [449e3197](https://github.com/Katello/katello.git/commit/449e319762f962c33dafd8b123f3f7f1d9feb1f5), [7fa589c0](https://github.com/Katello/katello.git/commit/7fa589c085080b2aad1f116e94faa67793e0c33c))
 * Link from host collections and Errata page should go to new host details page ([#36095](https://projects.theforeman.org/issues/36095), [c1529496](https://github.com/Katello/katello.git/commit/c1529496a3cf5b3f1554174492c34dbc343a2d02))
 * Setting a Content Source is not persistent ([#35834](https://projects.theforeman.org/issues/35834), [2de0d704](https://github.com/Katello/katello.git/commit/2de0d7043d5825cf660318eeb931fc83f124e7c4))
 * Global registration form needs call-to-action link when there are no activation keys created ([#35310](https://projects.theforeman.org/issues/35310), [df619076](https://github.com/Katello/katello.git/commit/df619076961a7cadcedac56d43bf2fc223f92a39))

### Content Views
 * Link for container count on CV page redirects to an invalid page ([#36474](https://projects.theforeman.org/issues/36474), [3995b680](https://github.com/Katello/katello.git/commit/3995b6805ffd4187d5c85591b2ac86d2d2baa742))
 * Unable to disable import_only flag in Satellite UI when set on Content Views ([#36459](https://projects.theforeman.org/issues/36459), [a4310fc3](https://github.com/Katello/katello.git/commit/a4310fc38af0993880c60b0e8139b5b6ccd99b90))
 * Needs_publish icon doesn't refresh when publish wizard is closed with task running ([#36402](https://projects.theforeman.org/issues/36402), [23c269d7](https://github.com/Katello/katello.git/commit/23c269d7b4f78204ec2fe5f2ce8c4b3e3f095727))
 * Content view publish with filters is getting failed with error "Could not find the following content units:" ([#36334](https://projects.theforeman.org/issues/36334), [aed62992](https://github.com/Katello/katello.git/commit/aed629926451904e6d00d679d10d1b68314bf4a4))
 * Add filters_applied? to cv version API. ([#36322](https://projects.theforeman.org/issues/36322), [918b22b4](https://github.com/Katello/katello.git/commit/918b22b4bc147b433f724a9f47eeffd731c32f24))
 * Incremental update of the content view takes long time to complete ([#36302](https://projects.theforeman.org/issues/36302), [ee56983f](https://github.com/Katello/katello.git/commit/ee56983f78da6b771f9846621f643c7f309d8f85))
 * Missing repository name (image name) in Container tags CVv comparison ([#36290](https://projects.theforeman.org/issues/36290), [1bab1087](https://github.com/Katello/katello.git/commit/1bab10879037e8c24d373b16b1e84c7994844d5c))
 * Hidden CV version number in CVv comparison ([#36289](https://projects.theforeman.org/issues/36289), [2403f6fa](https://github.com/Katello/katello.git/commit/2403f6faaf1fa4f95b85bfaf64233d155c8c47bc))
 * Cannot force delete repositories that are included in export content view versions ([#36123](https://projects.theforeman.org/issues/36123), [df934dc7](https://github.com/Katello/katello.git/commit/df934dc7ef0e4ce49996132198317b080deb760a))

### Alternate Content Sources
 * 'Remove orphans' task fails on DeleteOrphanAlternateContentSources step ([#36461](https://projects.theforeman.org/issues/36461), [8fa12c75](https://github.com/Katello/katello.git/commit/8fa12c75f4ae961737c4656837902d5bf5b75593))
 * Simplified ACS products are not removed if the last repository in the product of th ACS's type has its URL removed ([#35358](https://projects.theforeman.org/issues/35358), [1b165ff1](https://github.com/Katello/katello.git/commit/1b165ff11c7ed616e3213abe90801b8c8237a872))

### Localization
 * split out mo file and po file adding to git ([#36444](https://projects.theforeman.org/issues/36444), [dc58136c](https://github.com/Katello/katello.git/commit/dc58136cad8b1c173dffcf90fb28c96171022e3a))
 * Update webpack translations and edit mo-files command to ignore .gitignore ([#36409](https://projects.theforeman.org/issues/36409), [23528fab](https://github.com/Katello/katello.git/commit/23528fab117cd682b3b4748375ddd7ed5de2648d))
 * migrate transifex configuration ([#36335](https://projects.theforeman.org/issues/36335), [cdc68b01](https://github.com/Katello/katello.git/commit/cdc68b01d4ad42d22c2375311b33b8c9b0c12cf5))

### Foreman Proxy Content
 * External capsule is auto-synced on CV promotion regardless foreman_proxy_content_auto_sync settings ([#36442](https://projects.theforeman.org/issues/36442), [144ca316](https://github.com/Katello/katello.git/commit/144ca3160c504d0d3c9aa142d178a0088f357bc1))
 * Capsule redundantly synces *-Export-Library repos ([#36436](https://projects.theforeman.org/issues/36436), [70c4a6fc](https://github.com/Katello/katello.git/commit/70c4a6fcbed33a958e266e53e97a9894079bddbe))
 * Orphan cleanup runs fine but does not clears anything from /var/lib/pulp/media/artifact of Red Hat Capsule 6.10 ([#36390](https://projects.theforeman.org/issues/36390), [0c6298ab](https://github.com/Katello/katello.git/commit/0c6298ab7617c92ce48569d121cdebf3f3a086ab))

### Web UI
 * Incorrect aria-label in the alternate content source details ([#36420](https://projects.theforeman.org/issues/36420), [b02da002](https://github.com/Katello/katello.git/commit/b02da002b87f4e55b4182306a13fc9b8a54ee5a6))
 * Hostgroup edit form does not refresh operating system on LCE change if there is only 1 hostgroup ([#36278](https://projects.theforeman.org/issues/36278), [d1b0d466](https://github.com/Katello/katello.git/commit/d1b0d466e53345fcc2fccbb2fe251542b24dce8d))
 * Refine empty states for CV UI ([#36204](https://projects.theforeman.org/issues/36204), [052ed6b7](https://github.com/Katello/katello.git/commit/052ed6b7a734e47523ac0751625571c63615cb51))
 * Columns are overlapping while adding columns through "Manage columns" tab in "All Hosts" - katello edition ([#36172](https://projects.theforeman.org/issues/36172), [3746b037](https://github.com/Katello/katello.git/commit/3746b0372da77f9547ff47f4bd982aea2753c93f))

### Subscriptions
 * Test Candlepin 4.3.1 and tag to nightly ([#36287](https://projects.theforeman.org/issues/36287), [77440f96](https://github.com/Katello/katello.git/commit/77440f96751650710a95184516862eda951d3fa0))
 * Add simple-content-access param to organization update command ([#36197](https://projects.theforeman.org/issues/36197), [2b70c9d6](https://github.com/Katello/katello.git/commit/2b70c9d6495d6207f52ce333bc85686a21195856))

### Tooling
 * Use Node 14 for katello CI ([#36285](https://projects.theforeman.org/issues/36285), [e8e7c5a9](https://github.com/Katello/katello.git/commit/e8e7c5a92821b77468ccbe9b9aa7c33ef573633b), [eeb05c66](https://github.com/Katello/katello.git/commit/eeb05c66857d9e76e3a553664c3f4b94e86f5a78))
 * Using pulp with S3-storage throws exception on smartproxy overview-page ([#36094](https://projects.theforeman.org/issues/36094), [d0353bbc](https://github.com/Katello/katello.git/commit/d0353bbc993ce603ce9aa5fbaf5bd066e8823913))

### API
 * hammer does not show the how many times the activation key still can be used, also does not show the content host associated with the key ([#36237](https://projects.theforeman.org/issues/36237), [402306d8](https://github.com/Katello/hammer-cli-katello.git/commit/402306d89ebc76e735771ccc861972ca7e52431b), [f037cdd5](https://github.com/Katello/katello.git/commit/f037cdd517403b16026a865ea92639be561126aa))

### Tests
 * Re-record VCR cassettes once artifact structure is reverted in pulp_rpm 3.19 ([#36205](https://projects.theforeman.org/issues/36205), [b1c6db3b](https://github.com/Katello/katello.git/commit/b1c6db3ba7d27707f8e7898cf22eb105c150088e))

### Hammer
 * Suppress 'Nothing to update' message when toggling SCA ([#36198](https://projects.theforeman.org/issues/36198), [c644dd65](https://github.com/Katello/hammer-cli-katello.git/commit/c644dd65f97c6c052dd0b73140abaf3e387b23bb))
 * hammer host info no longer shows content view and lifecycle environment ([#36401](https://projects.theforeman.org/issues/36401), [85e4eaea](https://github.com/Katello/katello.git/commit/85e4eaea613dd001d7f6f8975ef6990c26e4b1a9), [94b39e09](https://github.com/Katello/hammer-cli-katello.git/commit/94b39e092ae176849b992cde4d9263392757fed7))

### Errata Management
 * Improve errata installation templates ([#36075](https://projects.theforeman.org/issues/36075), [c9c15fac](https://github.com/Katello/katello.git/commit/c9c15fac7fbdb39ab72ffd49c178eb047990bb38))

### Content Credentials
 * SSL cert content credential reported on ACS but not SSL key ([#35976](https://projects.theforeman.org/issues/35976), [231fb303](https://github.com/Katello/katello.git/commit/231fb30340960d7c42fb891e9917eca416b0a5b5))

### Container
 * Docker tags, manifests, and manifest lists aren't displaying properly ([#35710](https://projects.theforeman.org/issues/35710), [2cad75d2](https://github.com/Katello/katello.git/commit/2cad75d2d309afe0061f2f656d80409feff6c180))

### Inter Server Sync
 * We shouldn't allow assigning hosts to import/export content views ([#35192](https://projects.theforeman.org/issues/35192))

### Other
 * ID for activation keys on register host page is incorrect ([#36489](https://projects.theforeman.org/issues/36489), [4c530aef](https://github.com/Katello/katello.git/commit/4c530aef57918428d47e603d02c342e8858ea089))
 * Use plugin dsl for gettext registration ([#36378](https://projects.theforeman.org/issues/36378), [f1c0cc8a](https://github.com/Katello/katello.git/commit/f1c0cc8ac0079f7dd109131a960619531817d142))
 * ACS delete via API returns empty response ([#36346](https://projects.theforeman.org/issues/36346), [71702115](https://github.com/Katello/katello.git/commit/7170211589792a906cd5ae88bd903dce43a88bb6))
 * Bookmarks button for search in content -> subscriptions is missing ([#36324](https://projects.theforeman.org/issues/36324), [659655b4](https://github.com/Katello/katello.git/commit/659655b429711f4e58b7fa2081a6b069a377e6ba))
 * Create an ESlint rule to enforce OUIA IDs ([#36323](https://projects.theforeman.org/issues/36323), [20e49220](https://github.com/Katello/katello.git/commit/20e49220be295ddedb72b8bfa6f9934edc140c24), [f0dcf191](https://github.com/Katello/katello.git/commit/f0dcf19129e3b8bcddbf99ca07b9e7e1f7396a5c))
 * Make the EventDeamon runner safer to run ([#36277](https://projects.theforeman.org/issues/36277), [4134aa44](https://github.com/Katello/katello.git/commit/4134aa440d4de725578a2320e15aae0335cc6182))
 * Content -> Errata does not display the year for the dates listed under column "Updated" ([#36156](https://projects.theforeman.org/issues/36156), [e17daafb](https://github.com/Katello/katello.git/commit/e17daafbd44ea1cef81a65aef1bc92de376fc49b))
 * generate_metadata or metadata_generate ([#34923](https://projects.theforeman.org/issues/34923), [07c98968](https://github.com/Katello/katello.git/commit/07c98968413e9e66d1a96ddcc50a9c5cc82feff9))
