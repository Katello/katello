# Katello 2.1.2 

## Bug Fixes 

### Web UI
 * only destroy repo in finalize for direct repo deletes ([#9566](http://projects.theforeman.org/issues/9566), [4835f07](http://github.com/katello/katello/commit/4835f07))
 * speed up puppet class import ([#9647](http://projects.theforeman.org/issues/9647), [72cbf6c](http://github.com/katello/katello/commit/72cbf6c))
 * various inherited hostgroup issues ([#9462](http://projects.theforeman.org/issues/9462), [#9557](http://projects.theforeman.org/issues/9557), [#9556](http://projects.theforeman.org/issues/9556), [294f99f](http://github.com/katello/katello/commit/294f99f))

### Content Views
 * update system env and cv in candlepin on cv remove (cherry picked from commit 5c0446e0b9c6b66f357394f9466ba5b1d290f508) ([#9478](http://projects.theforeman.org/issues/9478), [8608df9](http://github.com/katello/katello/commit/8608df9))

### Candlepin
 * Don't initialize cp task if no qpid config ([#8552](http://projects.theforeman.org/issues/8552), [cacd17d](http://github.com/katello/katello/commit/cacd17d))

### Dynflow
 * fix sync_plan add/del product action getting stuck ([#9404](http://projects.theforeman.org/issues/9404), [5970a12](http://github.com/katello/katello/commit/5970a12))


# Katello 2.1.1

### Installer 
 * Update service wait for EL7, fixing broken installations. ([#9364](http://projects.theforeman.org/issues/9364), [3ba2d25](http://github.com/katello/katello/commit/3ba2d25))
 * hooks_dir should be hook_dirs ([#9075](http://projects.theforeman.org/issues/9075), [6697b2d](http://github.com/katello/katello/commit/6697b2d))
 * fixing --reset on broken installation ([#9101](http://projects.theforeman.org/issues/9101), [343c706](http://github.com/katello/katello/commit/343c706))

### Katello Agent
 * use correct certificate location ([#9403](http://projects.theforeman.org/issues/9403), [d04d43d](http://github.com/katello/katello-agent/commit/d04d43d))

### ElasticSearch
 * reindex all distributions on indexing ([#9150](http://projects.theforeman.org/issues/9150), [a07ac2a](http://github.com/katello/katello/commit/a07ac2a))

### Upgrades
 * syntax error in hash substitution in errata import task ([#9363](http://projects.theforeman.org/issues/9363), [9860955](http://github.com/katello/katello/commit/9860955))

### Web UI
 * correct logic to hide content hosts list on collection ([#9361](http://projects.theforeman.org/issues/9361), [ce70b44](http://github.com/katello/katello/commit/ce70b44))

### Dynflow
 * fix bad action name on lifecycle env delete ([#9333](http://projects.theforeman.org/issues/9333), [8a4dd44](http://github.com/katello/katello/commit/8a4dd44))

### API
 * only call foreman content update when needed ([#9317](http://projects.theforeman.org/issues/9317), [f1d2e04](http://github.com/katello/katello/commit/f1d2e04))
 * handle errata import with duplicate packages ([#9312](http://projects.theforeman.org/issues/9312), [886ef64](http://github.com/katello/katello/commit/886ef64))
 * extend hostgroups controller create/update to include katello attrs ([#9218](http://projects.theforeman.org/issues/9218), [b989b23](http://github.com/katello/katello/commit/b989b23))

### Other
 * Clear system_errata when pruning backend objects. ([#9431](http://projects.theforeman.org/issues/9431), [0caeead](http://github.com/katello/katello/commit/0caeead))
 * Remove sync plan from products when a sync plan is destroyed. ([#8984](http://projects.theforeman.org/issues/8984), [bd44944](http://github.com/katello/katello/commit/bd44944))
 * Fix for lifecycle environment destroy on org destroy ([32269a0](http://github.com/katello/katello/commit/32269a0))


#Winter Warmer (rubygem-katello-2.1.0-5 - 2015-02-06) 

## Features 

### Foreman Integration
 * separating host content view & life env from puppet env ([#8574](http://projects.theforeman.org/issues/8574), [3d08a4b](http://github.com/katello/katello/commit/3d08a4b))

### API
 * Show content view and environment pairings for library repositories. ([#8655](http://projects.theforeman.org/issues/8655), [ff5f285](http://github.com/katello/katello/commit/ff5f285))
 * adding api to determine what inc update is needed ([#8188](http://projects.theforeman.org/issues/8188), [a55f62f](http://github.com/katello/katello/commit/a55f62f))
 * adding incremnetal update api ([#8306](http://projects.theforeman.org/issues/8306), [981dac7](http://github.com/katello/katello/commit/981dac7))
 * enable searching by CVE ([#7697](http://projects.theforeman.org/issues/7697), [77396ca](http://github.com/katello/katello/commit/77396ca))
 * adding autocomplete for errata ([#7904](http://projects.theforeman.org/issues/7904), [7d31f0c](http://github.com/katello/katello/commit/7d31f0c))
 * Allow content to be filtered by environment. ([#8406](http://projects.theforeman.org/issues/8406), [f2bd009](http://github.com/katello/katello/commit/f2bd009))
 * adding api errata comparison for content view versions ([#7711](http://projects.theforeman.org/issues/7711), [5a7c5b3](http://github.com/katello/katello/commit/5a7c5b3))
 * adding errata applicable/available systems api ([#7690](http://projects.theforeman.org/issues/7690), [1001902](http://github.com/katello/katello/commit/1001902))
 * Added backend/api for docker images ([#7642](http://projects.theforeman.org/issues/7642), [2d21563](http://github.com/katello/katello/commit/2d21563))
 * filter errata optionally by organization id from api ([#7680](http://projects.theforeman.org/issues/7680), [4ddf87f](http://github.com/katello/katello/commit/4ddf87f))
 * adding errata counts to content host details ([#7705](http://projects.theforeman.org/issues/7705), [2ef156a](http://github.com/katello/katello/commit/2ef156a))
 * Back-end code for viewing docker images ([#7642](http://projects.theforeman.org/issues/7642), [a6f182d](http://github.com/katello/katello/commit/a6f182d))

### Web UI
 * add product/repositories list for an erratum. ([#7953](http://projects.theforeman.org/issues/7953), [1074b9f](http://github.com/katello/katello/commit/1074b9f))
 * Hide 'Server' kickstart repositories from enablement. ([#8668](http://projects.theforeman.org/issues/8668), [9c6f26b](http://github.com/katello/katello/commit/9c6f26b))
 * add content hosts tab to the errata details page. ([#7688](http://projects.theforeman.org/issues/7688), [858e542](http://github.com/katello/katello/commit/858e542))
 * Re-factor environments UI to show environment counts. ([#8404](http://projects.theforeman.org/issues/8404), [1a9cb6b](http://github.com/katello/katello/commit/1a9cb6b))
 * Performs docker repository name validation on repo create ([#8018](http://projects.theforeman.org/issues/8018), [fdb366c](http://github.com/katello/katello/commit/fdb366c))
 * Adds repository filter to tabs on content view version details. ([#7883](http://projects.theforeman.org/issues/7883), [b23235f](http://github.com/katello/katello/commit/b23235f))
 * Allow filtering content by a content view version and repository. ([#7883](http://projects.theforeman.org/issues/7883), [aa99743](http://github.com/katello/katello/commit/aa99743))
 * add errata counts to the content host details page. ([#8127](http://projects.theforeman.org/issues/8127), [cd9aaa2](http://github.com/katello/katello/commit/cd9aaa2))
 * Enable docker image uploads ([#7604](http://projects.theforeman.org/issues/7604), [a2ceb33](http://github.com/katello/katello/commit/a2ceb33))
 * Able to view the Errata in the Library Environment ([#7961](http://projects.theforeman.org/issues/7961), [f138b1e](http://github.com/katello/katello/commit/f138b1e))
 * adding counts to lifecycle environments ([#7885](http://projects.theforeman.org/issues/7885), [b1ba5f0](http://github.com/katello/katello/commit/b1ba5f0))
 *  add color to errata icons based on errata count. ([#8126](http://projects.theforeman.org/issues/8126), [558da4b](http://github.com/katello/katello/commit/558da4b))
 * View the details of a Content View Version ([#7609](http://projects.theforeman.org/issues/7609), [922979d](http://github.com/katello/katello/commit/922979d))
 * Adds cloning of activation key, BZ 531307 ([#7754](http://projects.theforeman.org/issues/7754), [4b95eae](http://github.com/katello/katello/commit/4b95eae))
 * Convert to using Bastion core to provide the Katello UI. ([#7423](http://projects.theforeman.org/issues/7423), [8c3b2e6](http://github.com/katello/katello/commit/8c3b2e6))
 * adding selector for type of applicability view ([#7701](http://projects.theforeman.org/issues/7701), [b761e5a](http://github.com/katello/katello/commit/b761e5a))
 * show affected packages of errata on details page. ([#7949](http://projects.theforeman.org/issues/7949), [b236b93](http://github.com/katello/katello/commit/b236b93))
 * add errata details page. ([#7685](http://projects.theforeman.org/issues/7685), [0c62ceb](http://github.com/katello/katello/commit/0c62ceb))
 * add the errata list page and menu item. ([#7679](http://projects.theforeman.org/issues/7679), [0ab24ac](http://github.com/katello/katello/commit/0ab24ac))
 * show applicable Errata count for Content Host list. ([#7704](http://projects.theforeman.org/issues/7704), [6ce1a88](http://github.com/katello/katello/commit/6ce1a88))
 * Docker - initial ui chgs to support CRUD ([#7598](http://projects.theforeman.org/issues/7598), [327b428](http://github.com/katello/katello/commit/327b428))
 * Adds a spinner to the repository tabs, BZ 1129526 ([#7426](http://projects.theforeman.org/issues/7426), [540295f](http://github.com/katello/katello/commit/540295f))

### Docker
 * Code to promote/publish dockered cv's ([#7603](http://projects.theforeman.org/issues/7603), [e2c478e](http://github.com/katello/katello/commit/e2c478e))
 * Remove docker and puppet content from a repository ([#7810](http://projects.theforeman.org/issues/7810), [10c037d](http://github.com/katello/katello/commit/10c037d))
 * Docker tags count now displayed for Repositories ([#8113](http://projects.theforeman.org/issues/8113), [d1e7fe7](http://github.com/katello/katello/commit/d1e7fe7))
 * Show docker pull url for repository details page ([#8101](http://projects.theforeman.org/issues/8101), [fbc3719](http://github.com/katello/katello/commit/fbc3719))
 * Create docker tag API ([#8242](http://projects.theforeman.org/issues/8242), [2d570ca](http://github.com/katello/katello/commit/2d570ca))
 * Upload docker images to the API ([#7126](http://projects.theforeman.org/issues/7126), [f3bdf3d](http://github.com/katello/katello/commit/f3bdf3d))
 * Add/Remove Docker repos to Content Views ([#7951](http://projects.theforeman.org/issues/7951), [e5a3026](http://github.com/katello/katello/commit/e5a3026))
 * Added code to enable docker repos ([#7796](http://projects.theforeman.org/issues/7796), [06bedb1](http://github.com/katello/katello/commit/06bedb1))
 * adding editable redhat registry url ([#7798](http://projects.theforeman.org/issues/7798), [bcbb547](http://github.com/katello/katello/commit/bcbb547))
 * docker - downcase pulp_id when creating docker repository ([#7124](http://projects.theforeman.org/issues/7124), [984bee3](http://github.com/katello/katello/commit/984bee3))
 * docker - fix issue where repo was always created as protected ([#7124](http://projects.theforeman.org/issues/7124), [609e77a](http://github.com/katello/katello/commit/609e77a))
 * Docker - initial backend/api changes to support repository CRUD actions ([#7124](http://projects.theforeman.org/issues/7124), [2ccb516](http://github.com/katello/katello/commit/2ccb516))

### CLI
 * enable searching errata by issued/updated times ([#7695](http://projects.theforeman.org/issues/7695), [#7677](http://projects.theforeman.org/issues/7677), [cbc8a30](http://github.com/katello/katello/commit/cbc8a30))
 * extend errata rabl in systems API ([#7706](http://projects.theforeman.org/issues/7706), [af9e545](http://github.com/katello/katello/commit/af9e545))
 * Fixes activation-key content override, BZ 1104638 ([#6060](http://projects.theforeman.org/issues/6060), [9db82fc](http://github.com/katello/katello/commit/9db82fc))
 * Added code to sync docker repos ([#7606](http://projects.theforeman.org/issues/7606), [b679864](http://github.com/katello/katello/commit/b679864))

### Candlepin
 * Sets autoattach flag for act key, BZ 1126924 ([#6939](http://projects.theforeman.org/issues/6939), [66b1a73](http://github.com/katello/katello/commit/66b1a73))

### Pulp
 * Fixing crane dependency ([#7526](http://projects.theforeman.org/issues/7526), [657f0a1](http://github.com/katello/katello/commit/657f0a1))
 * Add pulp-docker dependencies for pulp 2.5 upgrade ([#7526](http://projects.theforeman.org/issues/7526), [aa096b3](http://github.com/katello/katello/commit/aa096b3))

### Subscriptions
 * add checksum selection for custom repos ([#4056](http://projects.theforeman.org/issues/4056), [ed84085](http://github.com/katello/katello/commit/ed84085))

### Documentation
 * Add 1.5-2.0 Changelog. ([#7242](http://projects.theforeman.org/issues/7242), [f0bf704](http://github.com/katello/katello/commit/f0bf704))
 * Add 1.5-2.0 Changelog. ([#7242](http://projects.theforeman.org/issues/7242), [3a57bc6](http://github.com/katello/katello/commit/3a57bc6))

### Other
 * promotion errata mail notification ([#7667](http://projects.theforeman.org/issues/7667), [ae6e415](http://github.com/katello/katello/commit/ae6e415))
 * sync errata mail notification ([#7666](http://projects.theforeman.org/issues/7666), [4c96c39](http://github.com/katello/katello/commit/4c96c39))
 * host errata mail notification ([#7668](http://projects.theforeman.org/issues/7668), [3331f54](http://github.com/katello/katello/commit/3331f54))
 * Adds default setting for act key autoattach, BZ 1166889 ([#8480](http://projects.theforeman.org/issues/8480), [9b12978](http://github.com/katello/katello/commit/9b12978))
 * Enabling EmptyLinesAroundBody cop ([#8579](http://projects.theforeman.org/issues/8579), [72adffb](http://github.com/katello/katello/commit/72adffb))
 * Upgrade rubocop to 0.26.1 ([#7863](http://projects.theforeman.org/issues/7863), [50cb939](http://github.com/katello/katello/commit/50cb939))

## Bug Fixes 

### Foreman Integration
 * set default org for initial admin user ([#9105](http://projects.theforeman.org/issues/9105), [127675c](http://github.com/katello/katello/commit/127675c))
 * Use product label to make media unique. ([#7755](http://projects.theforeman.org/issues/7755), [42b9d4f](http://github.com/katello/katello/commit/42b9d4f))
 * disown foreman templates ([#7480](http://projects.theforeman.org/issues/7480), [268ea64](http://github.com/katello/katello/commit/268ea64))
 * treat a nil minor OS version as empty string ([#7621](http://projects.theforeman.org/issues/7621), [b0a8b43](http://github.com/katello/katello/commit/b0a8b43))
 * treat a nil minor OS version as empty string ([#7621](http://projects.theforeman.org/issues/7621), [7bf7458](http://github.com/katello/katello/commit/7bf7458))
 * Host delete dynflowed ([#7446](http://projects.theforeman.org/issues/7446), [880dc9e](http://github.com/katello/katello/commit/880dc9e))
 * fix taxonomy association on smart proxy create ([#7481](http://projects.theforeman.org/issues/7481), [9aeb555](http://github.com/katello/katello/commit/9aeb555))
 * fix taxonomy association on smart proxy create ([#7481](http://projects.theforeman.org/issues/7481), [e9437e8](http://github.com/katello/katello/commit/e9437e8))

### Dynflow
 * dynflow refresh subscriptions (auto-attach) ([#8941](http://projects.theforeman.org/issues/8941), [3ed60f6](http://github.com/katello/katello/commit/3ed60f6))
 * Update org create dynflow ([#7362](http://projects.theforeman.org/issues/7362), [896e382](http://github.com/katello/katello/commit/896e382))

### Web UI
 * publish content view was always using latest puppet module ([#9131](http://projects.theforeman.org/issues/9131), [4f8f6d1](http://github.com/katello/katello/commit/4f8f6d1))
 * loosening url validation restrictions ([#6637](http://projects.theforeman.org/issues/6637), [a1c597d](http://github.com/katello/katello/commit/a1c597d))
 * ensure errata icons line up, BZ 1171310. ([#8626](http://projects.theforeman.org/issues/8626), [549680c](http://github.com/katello/katello/commit/549680c))
 * display hypervisor/guest info for subscription ([#7176](http://projects.theforeman.org/issues/7176), [5e1b29f](http://github.com/katello/katello/commit/5e1b29f))
 * Allows user to delete custom product ([#7845](http://projects.theforeman.org/issues/7845), [635d535](http://github.com/katello/katello/commit/635d535))
 * Fix broken table layouts. ([#8553](http://projects.theforeman.org/issues/8553), [e440d7c](http://github.com/katello/katello/commit/e440d7c))
 * display product id (sku) ([#8454](http://projects.theforeman.org/issues/8454), [2105e81](http://github.com/katello/katello/commit/2105e81))
 * Fix broken auto_complete URL in Package Filter UI. ([#8440](http://projects.theforeman.org/issues/8440), [dc87589](http://github.com/katello/katello/commit/dc87589))
 * add CVE numbers to errata details. ([#8338](http://projects.theforeman.org/issues/8338), [e833b3b](http://github.com/katello/katello/commit/e833b3b))
 * display black icons if no errata needs to be applied. ([#8322](http://projects.theforeman.org/issues/8322), [0c87faa](http://github.com/katello/katello/commit/0c87faa))
 * fix JS error on content hosts page. ([#8273](http://projects.theforeman.org/issues/8273), [113fe9b](http://github.com/katello/katello/commit/113fe9b))
 * adding progress reporting for puppet sync ([#8268](http://projects.theforeman.org/issues/8268), [e3e8c5b](http://github.com/katello/katello/commit/e3e8c5b))
 * remove deselect all link from tables. ([#8265](http://projects.theforeman.org/issues/8265), [57b5798](http://github.com/katello/katello/commit/57b5798))
 * fixing progress updating on sync status page ([#8262](http://projects.theforeman.org/issues/8262), [7dd9236](http://github.com/katello/katello/commit/7dd9236))
 * properly display new version for publish after just publishing old version ([#8255](http://projects.theforeman.org/issues/8255), [cd7a27d](http://github.com/katello/katello/commit/cd7a27d))
 * Throw error for act key content host limit beyond max, BZ 1139576 ([#8220](http://projects.theforeman.org/issues/8220), [d2bcce0](http://github.com/katello/katello/commit/d2bcce0))
 * RH Cdn url can now be updated ([#8225](http://projects.theforeman.org/issues/8225), [9e6f473](http://github.com/katello/katello/commit/9e6f473))
 * Content Host - fix the host collection capacity ([#8094](http://projects.theforeman.org/issues/8094), [c3069e7](http://github.com/katello/katello/commit/c3069e7))
 * Content Dashboard - fix the sorting of items in Sync Overview ([#8089](http://projects.theforeman.org/issues/8089), [1fedd50](http://github.com/katello/katello/commit/1fedd50))
 * Locations - update to allow proper use of nested locations ([#8087](http://projects.theforeman.org/issues/8087), [c5f9b5c](http://github.com/katello/katello/commit/c5f9b5c))
 * adding better error reporting for repo enable ui ([#7979](http://projects.theforeman.org/issues/7979), [b0a8b01](http://github.com/katello/katello/commit/b0a8b01))
 * fix translations of sync plan intervals. ([#7919](http://projects.theforeman.org/issues/7919), [5b2fc29](http://github.com/katello/katello/commit/5b2fc29))
 * Validating package checksums when syncing ([#7947](http://projects.theforeman.org/issues/7947), [cdb1f1e](http://github.com/katello/katello/commit/cdb1f1e))
 * redirect to correct place after creating a sync plan. ([#7942](http://projects.theforeman.org/issues/7942), [59fa56e](http://github.com/katello/katello/commit/59fa56e))
 * Creating new product saves its description ([#7630](http://projects.theforeman.org/issues/7630), [a9c9054](http://github.com/katello/katello/commit/a9c9054))
 * Repo discovery display format ([#5015](http://projects.theforeman.org/issues/5015), [2f7d762](http://github.com/katello/katello/commit/2f7d762))
 * Bastion pages couldn't load due to unparseable User.to_json ([#7900](http://projects.theforeman.org/issues/7900), [7f6af41](http://github.com/katello/katello/commit/7f6af41))
 * fixing test that is randomly failing ([#7493](http://projects.theforeman.org/issues/7493), [3b7a403](http://github.com/katello/katello/commit/3b7a403))
 * Activation key max host count can be set from finite number to infinite ([#7730](http://projects.theforeman.org/issues/7730), [d40cef4](http://github.com/katello/katello/commit/d40cef4))
 * Store the description entered during publish ([#7493](http://projects.theforeman.org/issues/7493), [cf63c75](http://github.com/katello/katello/commit/cf63c75))
 * add errata icon tooltips on content view versions page. ([#7641](http://projects.theforeman.org/issues/7641), [8694d33](http://github.com/katello/katello/commit/8694d33))
 * Sync Plan enabled by default, checkbox to disable on edit ([#6912](http://projects.theforeman.org/issues/6912), [9291c47](http://github.com/katello/katello/commit/9291c47))
 * add ability to delete a Hypervisor ([#7542](http://projects.theforeman.org/issues/7542), [13e4b3d](http://github.com/katello/katello/commit/13e4b3d))
 * display message when there aren't any subscriptions. ([#7465](http://projects.theforeman.org/issues/7465), [9feea15](http://github.com/katello/katello/commit/9feea15))
 * Select all checkbox deselected after sync ([#4633](http://projects.theforeman.org/issues/4633), [95f06e5](http://github.com/katello/katello/commit/95f06e5))
 * Messages for empty tables in Bastion ([#5229](http://projects.theforeman.org/issues/5229), [758427c](http://github.com/katello/katello/commit/758427c))

### API
 * Fixing a typo in the name of an action class ([#8961](http://projects.theforeman.org/issues/8961), [da19db1](http://github.com/katello/katello/commit/da19db1))
 * returning correct CVE structure in rabl. ([#8887](http://projects.theforeman.org/issues/8887), [aa2bf51](http://github.com/katello/katello/commit/aa2bf51))
 * fixing content host errata list ([#8848](http://projects.theforeman.org/issues/8848), [db5c35b](http://github.com/katello/katello/commit/db5c35b))
 * Fix errata listing for content view filter regression. ([#8594](http://projects.theforeman.org/issues/8594), [9b6357b](http://github.com/katello/katello/commit/9b6357b))
 * Repo Index returns promoted repos ([#8743](http://projects.theforeman.org/issues/8743), [2026b63](http://github.com/katello/katello/commit/2026b63))
 * fixing errata queries due to ambiguous sort ([#8326](http://projects.theforeman.org/issues/8326), [ae96e0a](http://github.com/katello/katello/commit/ae96e0a))
 * fixing repository delete current user was not set during finalize phase ([#8598](http://projects.theforeman.org/issues/8598), [0b489b5](http://github.com/katello/katello/commit/0b489b5))
 * fixing puppet module index ([#8606](http://projects.theforeman.org/issues/8606), [a7d1c62](http://github.com/katello/katello/commit/a7d1c62))
 * Adding search param to repo content api ([#8610](http://projects.theforeman.org/issues/8610), [4792dbe](http://github.com/katello/katello/commit/4792dbe))
 * removing puppet modules list from content view version api ([#8491](http://projects.theforeman.org/issues/8491), [1ced1c5](http://github.com/katello/katello/commit/1ced1c5))
 * using correct environments for repository lookup ([#8438](http://projects.theforeman.org/issues/8438), [796b667](http://github.com/katello/katello/commit/796b667))
 * Validate that the user can not set max_content_hosts if unlimited_content_hosts is true ([#8237](http://projects.theforeman.org/issues/8237), [70b4edd](http://github.com/katello/katello/commit/70b4edd))
 * Add orgzanization_id to the systems json which is generated ([#8235](http://projects.theforeman.org/issues/8235), [4cb268d](http://github.com/katello/katello/commit/4cb268d))
 * Mark content_type parameter as required, since it is for POSTS ([#8238](http://projects.theforeman.org/issues/8238), [bcc6b15](http://github.com/katello/katello/commit/bcc6b15))
 * Hammer repo create doesn't require url ([#8209](http://projects.theforeman.org/issues/8209), [fa2d520](http://github.com/katello/katello/commit/fa2d520))
 * correcting prior env description in apidoc, BZ 1130258 ([#8116](http://projects.theforeman.org/issues/8116), [4345a25](http://github.com/katello/katello/commit/4345a25))
 * showing available errata and not all applicable ([#7993](http://projects.theforeman.org/issues/7993), [2e2fc4f](http://github.com/katello/katello/commit/2e2fc4f))
 * Refactor puppet modules controller to use content concern. ([#7852](http://projects.theforeman.org/issues/7852), [eaab468](http://github.com/katello/katello/commit/eaab468))
 * Avoid use of params local variables ([#7427](http://projects.theforeman.org/issues/7427), [86f78e1](http://github.com/katello/katello/commit/86f78e1))

### Content Views
 * fetch package information in chunks when fetching file lists ([#8563](http://projects.theforeman.org/issues/8563), [b81cc9b](http://github.com/katello/katello/commit/b81cc9b))
 * fixing query breaking content view repo list ([#8904](http://projects.theforeman.org/issues/8904), [fbb3019](http://github.com/katello/katello/commit/fbb3019))
 * Re-adding the content view filter line ([#8494](http://projects.theforeman.org/issues/8494), [3be9e06](http://github.com/katello/katello/commit/3be9e06))

### Packaging
 * require all neccessary pulp packages in RPM ([#8353](http://projects.theforeman.org/issues/8353), [000cf39](http://github.com/katello/katello/commit/000cf39))
 * removing requirements for maruku ([#8681](http://projects.theforeman.org/issues/8681), [6fde2e9](http://github.com/katello/katello/commit/6fde2e9))
 * relax qpid_messaging dependency ([#8615](http://projects.theforeman.org/issues/8615), [fd39e92](http://github.com/katello/katello/commit/fd39e92))
 * Require foreman-assets RPM. ([#8483](http://projects.theforeman.org/issues/8483), [14060d4](http://github.com/katello/katello/commit/14060d4))
 * remove uneeded packages from comps ([#8340](http://projects.theforeman.org/issues/8340), [1db71a8](http://github.com/katello/katello/commit/1db71a8))
 * Require jquery-ui-rails for the RPM spec and bump Runcible. ([#8283](http://projects.theforeman.org/issues/8283), [bbc847b](http://github.com/katello/katello/commit/bbc847b))
 * Remove unused styling and import to fix asset compile. ([#8132](http://projects.theforeman.org/issues/8132), [63251c0](http://github.com/katello/katello/commit/63251c0))
 * Rely on factory_girl_rails and mocha version from Foreman. ([#8013](http://projects.theforeman.org/issues/8013), [d34d496](http://github.com/katello/katello/commit/d34d496))
 * lockdown qpid_messaging rpms ([#7844](http://projects.theforeman.org/issues/7844), [f2405df](http://github.com/katello/katello/commit/f2405df))
 * lockdown qpid_messaging >= 0.26.1 && ([#7844](http://projects.theforeman.org/issues/7844), [0d97356](http://github.com/katello/katello/commit/0d97356))
 * Updates releasers for 2.0 ([#7476](http://projects.theforeman.org/issues/7476), [9fc9d7e](http://github.com/katello/katello/commit/9fc9d7e))
 * add candlepin-common to comps ([#7441](http://projects.theforeman.org/issues/7441), [cdbddac](http://github.com/katello/katello/commit/cdbddac))
 * add candlepin-common to comps ([#7441](http://projects.theforeman.org/issues/7441), [151b412](http://github.com/katello/katello/commit/151b412))
 * Use apipie packages provided by Foreman repos. ([#7282](http://projects.theforeman.org/issues/7282), [6502a2b](http://github.com/katello/katello/commit/6502a2b))

### Errata Management
 * ensure available errata are unique ([#8775](http://projects.theforeman.org/issues/8775), [2f054bc](http://github.com/katello/katello/commit/2f054bc))
 * fix promotion notification mail ([#8703](http://projects.theforeman.org/issues/8703), [4a54c7b](http://github.com/katello/katello/commit/4a54c7b))
 * truncate long erratum titles ([#8354](http://projects.theforeman.org/issues/8354), [a0af101](http://github.com/katello/katello/commit/a0af101))
 * make repo indexing idempotent ([#8588](http://projects.theforeman.org/issues/8588), [1948e0b](http://github.com/katello/katello/commit/1948e0b))
 * Display errata counts for Library environment counts. ([#8397](http://projects.theforeman.org/issues/8397), [6e253ae](http://github.com/katello/katello/commit/6e253ae))
 * remove ambigious column plucks for older rails ([#8355](http://projects.theforeman.org/issues/8355), [629ec7e](http://github.com/katello/katello/commit/629ec7e))
 * make errata indexing idempotent ([#8318](http://projects.theforeman.org/issues/8318), [46a38c9](http://github.com/katello/katello/commit/46a38c9))

### Orchestration
 * Dynflowizes system update. ([#6184](http://projects.theforeman.org/issues/6184), [328e008](http://github.com/katello/katello/commit/328e008))
 * copy uploaded files to shared tmp directory in plan phase ([#7915](http://projects.theforeman.org/issues/7915), [a5af255](http://github.com/katello/katello/commit/a5af255))
 * Remove call to undefined class ([#7903](http://projects.theforeman.org/issues/7903), [842b1d7](http://github.com/katello/katello/commit/842b1d7))

### Katello Agent
 * adding python-qpid-common to comps ([#8575](http://projects.theforeman.org/issues/8575), [fff3ee9](http://github.com/katello/katello/commit/fff3ee9))

### Pulp
 * fixing pulp glue tests in live mode ([#8768](http://projects.theforeman.org/issues/8768), [5c47dc2](http://github.com/katello/katello/commit/5c47dc2))

### Capsule
 * delay node metadata sync to 2nd action ([#8770](http://projects.theforeman.org/issues/8770), [82cd0a4](http://github.com/katello/katello/commit/82cd0a4))

### Tests
 * updating rubocop.yml for bastion_katello ([#8675](http://projects.theforeman.org/issues/8675), [d34fd06](http://github.com/katello/katello/commit/d34fd06))
 * foreman-gutterball and gutterball to comps ([#8584](http://projects.theforeman.org/issues/8584), [83eef5d](http://github.com/katello/katello/commit/83eef5d))
 * Turning on rubocop for the test directory ([#6421](http://projects.theforeman.org/issues/6421), [c0f8171](http://github.com/katello/katello/commit/c0f8171))
 * Fix spec directory rubocop offenses. ([#6421](http://projects.theforeman.org/issues/6421), [af2e310](http://github.com/katello/katello/commit/af2e310))
 * render permissions to fix oj 2.10.3 error ([#7818](http://projects.theforeman.org/issues/7818), [40c8cb5](http://github.com/katello/katello/commit/40c8cb5))

### CLI
 * Fixes subscription error messages for act key, BZ 1154619 ([#8549](http://projects.theforeman.org/issues/8549), [36cdaf2](http://github.com/katello/katello/commit/36cdaf2))
 * Fixing broken apidoc route and field ([#8436](http://projects.theforeman.org/issues/8436), [4a7c4d3](http://github.com/katello/katello/commit/4a7c4d3))
 * adding org_id param b/c it's required, BZ 1135125 ([#8292](http://projects.theforeman.org/issues/8292), [0664ff8](http://github.com/katello/katello/commit/0664ff8))
 * hammer was unable to update the org's desc, BZ 1114136 ([#6463](http://projects.theforeman.org/issues/6463), [460f918](http://github.com/katello/katello/commit/460f918))
 * adds arguments to activation-key functions, BZ 1110475 ([#7813](http://projects.theforeman.org/issues/7813), [9320483](http://github.com/katello/katello/commit/9320483))
 * CVV promotion out of sequence ([#7243](http://projects.theforeman.org/issues/7243), [0aa23f2](http://github.com/katello/katello/commit/0aa23f2))
 * Show user friendly error when no repo name ([#7428](http://projects.theforeman.org/issues/7428), [7dd233e](http://github.com/katello/katello/commit/7dd233e))
 * documenting the `label` param for env creation, BZ 883170 ([#7422](http://projects.theforeman.org/issues/7422), [9dae751](http://github.com/katello/katello/commit/9dae751))

### Installer
 * Can specify cdn ssl version via config ([#8441](http://projects.theforeman.org/issues/8441), [280a77f](http://github.com/katello/katello/commit/280a77f))
 * updating requirements for foreman_docker ([#8253](http://projects.theforeman.org/issues/8253), [a22ac7a](http://github.com/katello/katello/commit/a22ac7a))
 * fixing db:seed when called twice with seed organization ([#8232](http://projects.theforeman.org/issues/8232), [c43d801](http://github.com/katello/katello/commit/c43d801))

### Docker
 * Prevent duplicate docker tags for repos ([#8222](http://projects.theforeman.org/issues/8222), [184b1b1](http://github.com/katello/katello/commit/184b1b1))

### Content Uploads
 * Show user friendly error message on 413 ([#7554](http://projects.theforeman.org/issues/7554), [78b88cf](http://github.com/katello/katello/commit/78b88cf))

### Database
 * don't index users in elasticsearch ([#7996](http://projects.theforeman.org/issues/7996), [4c1edeb](http://github.com/katello/katello/commit/4c1edeb))
 * Update organization to disallow modifying label ([#6946](http://projects.theforeman.org/issues/6946), [82118cd](http://github.com/katello/katello/commit/82118cd))

### Candlepin
 * remove critcal section from cp events task ([#7846](http://projects.theforeman.org/issues/7846), [789f6f6](http://github.com/katello/katello/commit/789f6f6))
 * updt index on cp event bz1115602 ([#6543](http://projects.theforeman.org/issues/6543), [e7c6a85](http://github.com/katello/katello/commit/e7c6a85))
 * fix import of virt-who subscription information ([#7521](http://projects.theforeman.org/issues/7521), [7fc8874](http://github.com/katello/katello/commit/7fc8874))
 * fix import of virt-who subscription information ([#7521](http://projects.theforeman.org/issues/7521), [0666cd5](http://github.com/katello/katello/commit/0666cd5))

### Client/Agent
 * adding one last client package to comps ([#7814](http://projects.theforeman.org/issues/7814), [50816a7](http://github.com/katello/katello/commit/50816a7))
 * adding a few client pages to comps ([#7814](http://projects.theforeman.org/issues/7814), [1b58f8c](http://github.com/katello/katello/commit/1b58f8c))
 * ensure displayMessage is present ([#7155](http://projects.theforeman.org/issues/7155), [8cb615f](http://github.com/katello/katello/commit/8cb615f))

### Katello Disconnected
 * handle cases where this codte is ran outside of rails ([#7627](http://projects.theforeman.org/issues/7627), [bc16155](http://github.com/katello/katello/commit/bc16155))
 * handle cases where this codte is ran outside of rails ([#7627](http://projects.theforeman.org/issues/7627), [29992ee](http://github.com/katello/katello/commit/29992ee))

### Documentation
 * lock down 2.0 to foreman 1.6 ([#7206](http://projects.theforeman.org/issues/7206), [854f82b](http://github.com/katello/katello/commit/854f82b))

### RHSM
 * Fixed handling of empty body (just whitespaces) ([#7322](http://projects.theforeman.org/issues/7322), [80c8319](http://github.com/katello/katello/commit/80c8319))

### Other
 *  Automatic commit of package [rubygem-katello] minor release [2.1.0-5]. ([f98151e](http://github.com/katello/katello/commit/f98151e))
 *  Automatic commit of package [katello] minor release [2.1.0-3]. ([82309d6](http://github.com/katello/katello/commit/82309d6))
 *  Automatic commit of package [rubygem-katello] minor release [2.1.0-4]. ([83acfea](http://github.com/katello/katello/commit/83acfea))
 * do not perform post sync actions until after the sync is finished ([#8943](http://projects.theforeman.org/issues/8943), [b0f6ff1](http://github.com/katello/katello/commit/b0f6ff1))
 * Set sync plan on product during repository creation. ([#8621](http://projects.theforeman.org/issues/8621), [bfef813](http://github.com/katello/katello/commit/bfef813))
 *  Automatic commit of package [rubygem-katello] minor release [2.1.0-3]. ([318c11e](http://github.com/katello/katello/commit/318c11e))
 * Collect candlepin logs on RHEL7 ([#8858](http://projects.theforeman.org/issues/8858), [dcfe188](http://github.com/katello/katello/commit/dcfe188))
 * Redoing docker tables/fields ([#8632](http://projects.theforeman.org/issues/8632), [16a9df4](http://github.com/katello/katello/commit/16a9df4))
 *  Add rubygem-bastion to comps files ([dbe3c79](http://github.com/katello/katello/commit/dbe3c79))
 *  Automatic commit of package [katello] minor release [2.1.0-2]. ([a9719f1](http://github.com/katello/katello/commit/a9719f1))
 *  Automatic commit of package [rubygem-katello] minor release [2.1.0-2]. ([2a07db2](http://github.com/katello/katello/commit/2a07db2))
 * Remove katello_api from comps ([#8771](http://projects.theforeman.org/issues/8771), [da35031](http://github.com/katello/katello/commit/da35031))
 *  Bumping for 2.1 release ([72073c7](http://github.com/katello/katello/commit/72073c7))
 * Remove unnecessary ignore blocks ([#8763](http://projects.theforeman.org/issues/8763), [460aa72](http://github.com/katello/katello/commit/460aa72))
 * Bonus subs not being reindexed ([#8519](http://projects.theforeman.org/issues/8519), [5c6ed2f](http://github.com/katello/katello/commit/5c6ed2f))
 * adding foreman_sam and hammer-cli-sam to comps ([#8596](http://projects.theforeman.org/issues/8596), [f936737](http://github.com/katello/katello/commit/f936737))
 *  BuildRequires needs to be updated as well ([50de853](http://github.com/katello/katello/commit/50de853))
 * add hammer-cli-csv to nightly builds ([#8451](http://projects.theforeman.org/issues/8451), [e8c32f6](http://github.com/katello/katello/commit/e8c32f6))
 * Returns error message when sorting by wrong column. ([#5059](http://projects.theforeman.org/issues/5059), [2f69346](http://github.com/katello/katello/commit/2f69346))
 * Remove usage of to_sym on user input params. ([#8263](http://projects.theforeman.org/issues/8263), [fc5ccc5](http://github.com/katello/katello/commit/fc5ccc5))
 * hypervisors forced into content host's org, env, and cv ([#8131](http://projects.theforeman.org/issues/8131), [8f414f9](http://github.com/katello/katello/commit/8f414f9))
 * Removes use of RootURL removed from Bastion. ([#8138](http://projects.theforeman.org/issues/8138), [ee0a6af](http://github.com/katello/katello/commit/ee0a6af))
 * properly process incoming and updated hypervisors ([#7834](http://projects.theforeman.org/issues/7834), [f753644](http://github.com/katello/katello/commit/f753644))
 * fix subscription-manager registration for missing constant ([24a776b](http://github.com/katello/katello/commit/24a776b))
 * Update the MethodLength namespaces ([#7929](http://projects.theforeman.org/issues/7929), [436b4d0](http://github.com/katello/katello/commit/436b4d0))
 * Improved a complicated if statement ([5abd4d0](http://github.com/katello/katello/commit/5abd4d0))
 *  Automatic commit of package [rubygem-katello] minor release [2.0.0-6]. ([3d187ed](http://github.com/katello/katello/commit/3d187ed))
 *  Automatic commit of package [rubygem-katello] minor release [2.0.0-5]. ([dc78bc1](http://github.com/katello/katello/commit/dc78bc1))
 *  Automatic commit of package [rubygem-katello] minor release [2.0.0-4]. ([d3f1e18](http://github.com/katello/katello/commit/d3f1e18))
 *  Automatic commit of package [rubygem-katello] minor release [2.0.0-3]. ([816f02d](http://github.com/katello/katello/commit/816f02d))
 * don't require less in production unless from rake ([#7527](http://projects.theforeman.org/issues/7527), [3fb3359](http://github.com/katello/katello/commit/3fb3359))
 * don't require less in production unless from rake ([#7527](http://projects.theforeman.org/issues/7527), [220c4be](http://github.com/katello/katello/commit/220c4be))
 *  Automatic commit of package [rubygem-katello] minor release [2.0.0-2]. ([4146396](http://github.com/katello/katello/commit/4146396))
 * fixing comps for el7 candlepin ([a89f439](http://github.com/katello/katello/commit/a89f439))
 * fixing comps for el7 candlepin ([b603073](http://github.com/katello/katello/commit/b603073))
 *  Automatic commit of package [katello] minor release [2.1.0-1]. ([9be2cba](http://github.com/katello/katello/commit/9be2cba))
 *  bumping to katello version to 2.1 ([92626b2](http://github.com/katello/katello/commit/92626b2))
 *  Automatic commit of package [rubygem-katello] minor release [2.1.0-1]. ([c1df248](http://github.com/katello/katello/commit/c1df248))
 *  bumping to version to 2.1 ([26b8b10](http://github.com/katello/katello/commit/26b8b10))
