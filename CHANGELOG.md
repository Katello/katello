# 4.8.3 Phoenix (2023-07-12)

## Bug Fixes

### Repositories
 * Upgrade to Katello 4.5 can fail if some on_demand repositories have checksum_type set ([#36562](https://projects.theforeman.org/issues/36562), [f0ab69db](https://github.com/Katello/katello.git/commit/f0ab69db3927014c5e570366162d8bbb1fbc6044))

### Hammer
 * Update katello-agent deprecation warnings to show specific removal version ([#36546](https://projects.theforeman.org/issues/36546), [43d06395](https://github.com/Katello/hammer-cli-katello.git/commit/43d06395ff0f449c20b0be8c435d70a3afb3b983))
 * hammer host info no longer shows content view and lifecycle environment ([#36401](https://projects.theforeman.org/issues/36401), [85e4eaea](https://github.com/Katello/katello.git/commit/85e4eaea613dd001d7f6f8975ef6990c26e4b1a9), [94b39e09](https://github.com/Katello/hammer-cli-katello.git/commit/94b39e092ae176849b992cde4d9263392757fed7))

### Client/Agent
 * tasks Actions::Katello::BulkAgentAction without any sub-plans and stuck in running/pending ([#36528](https://projects.theforeman.org/issues/36528), [f9bf7d00](https://github.com/Katello/katello.git/commit/f9bf7d0065c55e202275de84b9c69b5ebbca9ed0))

### Hosts
 * undefined method `each' for #<Katello::ContentViewEnvironment when running hammer host subscription register ([#36524](https://projects.theforeman.org/issues/36524), [f579e498](https://github.com/Katello/katello.git/commit/f579e4989f92f66c30608eac3c6d6426e6aa6dbe))

### Foreman Proxy Content
 * Optimized capsule sync doesn't sync recently published/promoted docker repositories ([#36523](https://projects.theforeman.org/issues/36523), [1429ec99](https://github.com/Katello/katello.git/commit/1429ec99c7916a6954fda50040397eb1f0142d6a))

### Inter Server Sync
 * hammer content import fails with undefined method `substitutor' for nil:NilClass during import content if product being imported is not covered by subscriptions on the manifest ([#36521](https://projects.theforeman.org/issues/36521), [58dcb484](https://github.com/Katello/katello.git/commit/58dcb484f07c16b033d238b57f3e77206b02f3f9))
# 4.8.2 Phoenix (2023-06-21)

## Bug Fixes

### Content Views
 * Content View comparison - RPM packages search missing auto completion ([#36516](https://projects.theforeman.org/issues/36516), [76fdd41f](https://github.com/Katello/katello.git/commit/76fdd41fcf9f8650cf188612cd5cecc7d41125c7))

### Hosts
 * undefined method `content_view=' for #<Katello::Host::ContentFacet:0x00007fc530855ac8> ([#36504](https://projects.theforeman.org/issues/36504), [ccd234ac](https://github.com/Katello/katello.git/commit/ccd234acfa7c7294f036d3904b01ca74aed9a985))
 * Editing a host results in an error "content_view_id and lifecycle_environment_id must be provided together" ([#36498](https://projects.theforeman.org/issues/36498), [08941da7](https://github.com/Katello/katello.git/commit/08941da7038f16286688e237824560442f8afb54))
 * Can't add hostgroup to new host ([#36462](https://projects.theforeman.org/issues/36462), [2fdd82af](https://github.com/Katello/katello.git/commit/2fdd82af41cb95ea54b48a59f535ab0e40af6436))
 * hammer host update fails with "unknown attribute ‘content_view_id’ for Katello::Host::ContentFacet" when you pass a content view / LCE ([#36440](https://projects.theforeman.org/issues/36440), [0a200518](https://github.com/Katello/katello.git/commit/0a200518702c6d87ade221a030701dfe6e8cab22))
 * Arch restriction label missing from Repository sets for repos without URL ([#36430](https://projects.theforeman.org/issues/36430), [338eb1db](https://github.com/Katello/katello.git/commit/338eb1dbe72be020ea02bc088afed2e3607aacfc))

### Inter Server Sync
 *  Unable to enable any repository in network sync ([#36482](https://projects.theforeman.org/issues/36482), [03e1186c](https://github.com/Katello/katello.git/commit/03e1186c1922658a0f55bada97cda10959611966))

### Other
 * Failed to update host: undefined method `custom_content_labels' for #<Katello::ProductContentFinder> when turning on SCA ([#36505](https://projects.theforeman.org/issues/36505))
# 4.8.1 Phoenix (2023-05-22)

## Bug Fixes

### Content Views
 * Getting "NoMethodError undefined method `get_status' for nil:NilClass" when publishing content view (https://projects.theforeman.org/issues/36303[#36303], https://github.com/Katello/katello/commit/a331781372a75b37ea62027560979fea1027ccac[a3317813])

### Other
 * Enable tracer on host page (debian os) is always on (https://projects.theforeman.org/issues/36297[#36297], https://github.com/Katello/katello/commit/ac0b74a532885f240628c1581c88d13e9504dd20[ac0b74a5])
# 4.8.0 Phoenix (2023-04-12)

## Features

### Inter Server Sync
 * Need incremental export for syncable format (https://projects.theforeman.org/issues/35948[#35948], https://github.com/Katello/katello/commit/3dd58df7579341b0b1dba7017b2e7086cd6477bd[3dd58df7])

### Content Views
 * Backend work: As a user I want to be able to assign multiple content views on a content host (https://projects.theforeman.org/issues/35580[#35580], https://github.com/Katello/katello/commit/c33da7a3fa9473add44a154feba4e57f34b2b289[c33da7a3])

## Bug Fixes

### Web UI
 * Clear search link doesn't work in any tables except maybe Host details (https://projects.theforeman.org/issues/36220[#36220], https://github.com/Katello/katello/commit/43a573a796c918ace2b1ea8c08c663c4f444b889[43a573a7])
 * Update JS snapshots after PF update (https://projects.theforeman.org/issues/36081[#36081], https://github.com/Katello/katello/commit/9db5562ae93502dd00ff56f8f16ab2096b136fd8[9db5562a])
 * Link from Content Hosts should navigate to Host's Content pane/tab (https://projects.theforeman.org/issues/36078[#36078], https://github.com/Katello/katello/commit/15352c2a07b5e8c3060eb9c7e0f00d81578ef160[15352c2a])
 * Add warning in UI that space reclamation won't work on deleted repositories (https://projects.theforeman.org/issues/35935[#35935], https://github.com/Katello/katello/commit/a8f0e832e907d877272d2cc04c803510b93ac2e7[a8f0e832])
 * Audit ouia-ids for ACS UI (https://projects.theforeman.org/issues/35873[#35873], https://github.com/Katello/katello/commit/cafb1428a6b2947d8aace72dca361b6c478ba07c[cafb1428], https://github.com/Katello/katello/commit/22db652c2fa8efbc00109ef0077774238ee08961[22db652c], https://github.com/Katello/katello/commit/b0a187ee79dba811216cdfa78314998a97e492cb[b0a187ee])
 * wrap bookmarks in angular pages (https://projects.theforeman.org/issues/35771[#35771], https://github.com/Katello/katello/commit/b7f84e5a6daa3168ea2009d26b17634cd696f0b1[b7f84e5a])

### Alternate Content Sources
 * ACS page shows loading spinner forever after bulk removing ACSs (https://projects.theforeman.org/issues/36202[#36202], https://github.com/Katello/katello/commit/d8e8e4329b50ccf44cf3e082018e9c09d103e42e[d8e8e432])
 * Bulk select/deselect does not work properly on paginated ACS page (https://projects.theforeman.org/issues/36103[#36103], https://github.com/Katello/katello/commit/8cb8f2777fd350d31bf5c9f8974e647ac821f613[8cb8f277])
 * ForeignKeyViolation on ACS create when invalid --ssl-* argument is provided (https://projects.theforeman.org/issues/36051[#36051], https://github.com/Katello/katello/commit/19b4a6b686d09ae12c68031c95ff54e7010a7a24[19b4a6b6])
 * Add validations for RHUI ACS create and update (https://projects.theforeman.org/issues/36042[#36042], https://github.com/Katello/katello/commit/b4340d5417175a538cc749e8160c2d57ba8acdef[b4340d54])

### Inter Server Sync
 * Importing incremental content not recreating metadata properly (https://projects.theforeman.org/issues/36164[#36164], https://github.com/Katello/katello/commit/df3b102e512c193b213ecc3a8c8ed2f2ef1ef8e6[df3b102e])
 * Need a better warning message for empty incremental export (https://projects.theforeman.org/issues/36146[#36146], https://github.com/Katello/katello/commit/dde5565960ea6183f35a3aa10efe046b9636c5ae[dde55659])

### Repositories
 * Need to update Recommended Repositories page with Satellite 6.13 repos (https://projects.theforeman.org/issues/36158[#36158], https://github.com/Katello/katello/commit/48694791d2922b52c39780529b812231090be9f5[48694791])
 * RHEL 9 appstream and baseos kickstart repositories not showing as recommended repositories (https://projects.theforeman.org/issues/36151[#36151], https://github.com/Katello/katello/commit/66d75338f2632b95b3c98d19a633c93a7791384b[66d75338])
 * Wrong rake task name in Rails log warning (https://projects.theforeman.org/issues/36147[#36147], https://github.com/Katello/katello/commit/6547094f3d5a58a106f0a194f14bb1ce3a5f5255[6547094f])
 * hammer repository reclaim-space raises "undefined local variable or method `repositories'" exception (https://projects.theforeman.org/issues/36142[#36142], https://github.com/Katello/katello/commit/6e8274f255f731a44b2398b463c03f6b3f795160[6e8274f2])
 * mirror_on_sync is deprecated in favor of mirroring_policy and should be removed in Katello (https://projects.theforeman.org/issues/36140[#36140], https://github.com/Katello/katello/commit/b0cafa10a227cc24c8fb90699ff1e0029da6895f[b0cafa10])
 * Saving RHUI alternate content source with a malformed Base URL is possible (https://projects.theforeman.org/issues/36074[#36074], https://github.com/Katello/katello/commit/09f69b74148fe2af5177f9240060f5691182cfe1[09f69b74])
 * Add some validation for name in Simplified ACS creation via hammer (https://projects.theforeman.org/issues/36041[#36041], https://github.com/Katello/katello/commit/3bdb5ae877d64110cda1961b2abce1b857c91789[3bdb5ae8])
 * Add validations for Simplified ACS update via hammer (https://projects.theforeman.org/issues/36038[#36038], https://github.com/Katello/katello/commit/fdb31151d7b2a055b0f397e07ed130e53cd26a92[fdb31151])
 * Upgrade to 4.5 may fail to apply RemoveDrpmFromIgnorableContent migration if erratum is also a ignorable content type for any repo (https://projects.theforeman.org/issues/35864[#35864], https://github.com/Katello/katello/commit/98fe46f4ea32ff10f28f2391b096e06e4fb13f6b[98fe46f4])

### Container
 * Pulp headers are overwritten incorrectly during manifest pull (https://projects.theforeman.org/issues/36157[#36157], https://github.com/Katello/katello/commit/501940dc84a1ff7cdb588570636367263a6ce262[501940dc])
 * The "pulp_docker_registry_port" settings is still exposed and set to port 5000 (https://projects.theforeman.org/issues/35783[#35783], https://github.com/Katello/katello/commit/b31ae26d5ee9ed255c2665780b1968ed53a904b1[b31ae26d])

### Hosts
 * Can't update host with Katello plugin installed (https://projects.theforeman.org/issues/36137[#36137], https://github.com/Katello/katello/commit/0599f93088b7725da4563d49a7c30ad4c4c26e09[0599f930])
 * Host cloning is broken (https://projects.theforeman.org/issues/36064[#36064], https://github.com/Katello/katello/commit/870746dc26734a7afbf7112bd6ed59b000755990[870746dc])
 * Add support for Erratum release date in Host - Applied Errata report template (https://projects.theforeman.org/issues/36049[#36049], https://github.com/Katello/katello/commit/d1b4c553b19d3056dc5ca5cb133e880b51df638f[d1b4c553])
 * Package and Errata actions on content hosts selected using the "select all hosts" option fails. (https://projects.theforeman.org/issues/35947[#35947], https://github.com/Katello/katello/commit/8001e4c39a1b9219e2fe63a32900f170f0def5a3[8001e4c3])
 * Repository sets banner shows "" for content view and lifecycle environment (https://projects.theforeman.org/issues/35878[#35878], https://github.com/Katello/katello/commit/f07230ecc6041a3d06123a6d61a747beaa345ad2[f07230ec])
 * Registration fails in method:  host_setup_extension (https://projects.theforeman.org/issues/35874[#35874], https://github.com/Katello/katello/commit/db5a820f93dad82348b382570fdad90e36c6f51c[db5a820f])
 * Overriding 25 repo sets to disabled causes error (https://projects.theforeman.org/issues/35818[#35818], https://github.com/Katello/katello/commit/7592f61ef3fa0c2dadc3c178f72a6dc13b7f9929[7592f61e])
 * Repository sets not reflecting SCA status on direct load (https://projects.theforeman.org/issues/35604[#35604], https://github.com/Katello/katello/commit/6e500def9afdadccba0c626a4fbcd475d0fba52c[6e500def])
 * Errata tooltip not pluralized (https://projects.theforeman.org/issues/35046[#35046], https://github.com/Katello/katello/commit/5c4b1ef7aa5b6ca6e47b9bd5deb72f81f25c230e[5c4b1ef7])

### Errata Management
 * Improve wording of errata_status_installable setting (https://projects.theforeman.org/issues/36124[#36124], https://github.com/Katello/katello/commit/1f427adf595582012563d3d0c4fde18af2526c89[1f427adf])
 * Errata search filtered with ID does not work in Web UI  (https://projects.theforeman.org/issues/35752[#35752], https://github.com/Katello/katello/commit/c51a68973a0b00a6c169b7ea97eefd79fd5428ed[c51a6897])
 * Improve empty state design when a host has applicable errata but no installable errata (https://projects.theforeman.org/issues/35707[#35707], https://github.com/Katello/katello/commit/53b2a5677c5eb90d115b8eb74bdd34c4f2674b08[53b2a567])
 *  Email notification shows incorrect new errata after syncing an Epel repository (https://projects.theforeman.org/issues/35191[#35191], https://github.com/Katello/katello/commit/a5e9405a44d62b224257cb3b371e47f35970ea71[a5e9405a])

### Foreman Proxy Content
 * Navigating to an external proxy details displays error "Pulp plugin missing for synchronizable content types: . Repositories containing these content types will not be synced." for few seconds (https://projects.theforeman.org/issues/36122[#36122], https://github.com/Katello/katello/commit/35fcf95e5a429656b773d6e498073d9ac2cd915e[35fcf95e])
 * delete orphans task does not remove pulp3 remotes from capsules when removing repositories (https://projects.theforeman.org/issues/35965[#35965], https://github.com/Katello/katello/commit/9e6cab229def6c337cf5830c73370724bc95f0ad[9e6cab22])
 * Inspecting an image with skopeo no longer works on smart proxies (https://projects.theforeman.org/issues/35801[#35801], https://github.com/Katello/smart_proxy_container_gateway/commit/19370a115202a10102bb86c674abca213d82b8ea[19370a11])
 * Python content isn't sychronized to smart proxies (https://projects.theforeman.org/issues/35091[#35091], https://github.com/Katello/katello/commit/e1a6974cd9ba07a997102a3b0f919f766cc48270[e1a6974c])

### Hammer
 * Can't create hostgroup if puppet plugin is installed (https://projects.theforeman.org/issues/36099[#36099], https://github.com/Katello/hammer-cli-katello/commit/3a06fd89b64a510ae3b994f369cb024224e99c13[3a06fd89])
 * hammer acs show does not show any SSL related fields (https://projects.theforeman.org/issues/36052[#36052], https://github.com/Katello/hammer-cli-katello/commit/d2ab20e935483fd345e92abd1f13828f0a4aeaae[d2ab20e9])
 * hammer repository types command is missing options (https://projects.theforeman.org/issues/35666[#35666], https://github.com/Katello/hammer-cli-katello/commit/80707a083c0315fb928c3d687518dcee2734fabd[80707a08])
 * hammer failed to override repository sets (https://projects.theforeman.org/issues/35640[#35640], https://github.com/Katello/katello/commit/46094b64985f284522b4d71e794cfa2549d14e5c[46094b64])

### Tests
 * Re-enable test_sync_skipped_srpms (https://projects.theforeman.org/issues/36053[#36053], https://github.com/Katello/katello/commit/35fbe9b7af6bf69a05983b6af6052e3ff619a3cd[35fbe9b7])
 * Intermittent docker content type not found error in Actions::Katello::Repository::UploadDockerTest (https://projects.theforeman.org/issues/35735[#35735], https://github.com/Katello/katello/commit/0047bb6df73d828ac598ca85c84898de47121c3d[0047bb6d])
 * ouia-ID for tile cards in the new host details page (https://projects.theforeman.org/issues/35411[#35411], https://github.com/Katello/katello/commit/2c01e818765d49bb38562e9313a4587df18faaeb[2c01e818], https://github.com/Katello/katello/commit/ecd11019cf5c30c1779a756cb116f506ee71e139[ecd11019])
 * Uncomment upload tests that were commented while waiting on updated pulp bindings that upgrade Faraday to 1.0.1 (https://projects.theforeman.org/issues/35395[#35395], https://github.com/Katello/katello/commit/f0f54d67fb123940fecac4a71fbcd13ee5128e69[f0f54d67])
 * Comment upload tests while waiting on updated pulp bindings that upgrade Faraday to 1.0.1 (https://projects.theforeman.org/issues/35394[#35394], https://github.com/Katello/katello/commit/53454eb7d4f61cfef13308d0f919dab8a32f520f[53454eb7])

### Content Views
 * Missing ouia-id for content view (https://projects.theforeman.org/issues/35989[#35989], https://github.com/Katello/katello/commit/223243e0b4bb6f1a2c689169aa5afc0861a4cc67[223243e0], https://github.com/Katello/katello/commit/e4fee67b780c9e6f5ec0df02fa53919e7314eb21[e4fee67b])
 * Unable to promote content view due to "NoMethodError: undefined method `get_status' for nil:NilClass" (https://projects.theforeman.org/issues/35861[#35861], https://github.com/Katello/katello/commit/f37728cc5f2eb57ad9e242573ef7a647a4e2cb92[f37728cc], https://github.com/Katello/katello/commit/927d0564ead514150a8979479af2d500fc9f0e49[927d0564], https://github.com/Katello/katello/commit/cb5621bbfe9275dc9a5a53bd0c90bf463b2313fa[cb5621bb])
 * hammer content-view purge only deletes up to "Entries per page" versions (https://projects.theforeman.org/issues/35750[#35750], https://github.com/Katello/hammer-cli-katello/commit/6f9bd71e62a5187b8bb05551984685334432e86c[6f9bd71e])
 * Content view filter included errata not in the filter date range (https://projects.theforeman.org/issues/35614[#35614], https://github.com/Katello/katello/commit/4950081967a99de4b68825cbe86ea8845334b155[49500819])

### Subscriptions
 * Deb repository using multiple archs is not provided to managed host (https://projects.theforeman.org/issues/35968[#35968], https://github.com/Katello/katello/commit/8d6c1a80911965b92d16480327c92facd7146d9c[8d6c1a80])
 * 'Import a Manifest' button displays when a blank manifest is imported (https://projects.theforeman.org/issues/35963[#35963], https://github.com/Katello/katello/commit/04a246957d4e2fe31e0f2fc0a8f11acd840066b4[04a24695])
 * Registration error: PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "katello_available_module_streams_name_stream_context" (https://projects.theforeman.org/issues/35936[#35936], https://github.com/Katello/katello/commit/d4c72d2c11a7b6548cdee6ab05b89887a4fcee2e[d4c72d2c])
 * consumer uuid differing between candlepin and katello (https://projects.theforeman.org/issues/35381[#35381], https://github.com/Katello/katello/commit/a3b1f51efcddb5976020690acb6ddde72de0915a[a3b1f51e])

### API
 * Creating an organization through API does not propagate encountered errors properly (https://projects.theforeman.org/issues/35954[#35954], https://github.com/Katello/katello/commit/94ed9749edb0e9350047054bc8d060417256cfd0[94ed9749])

### Host Collections
 * minor, help text for HC host list when empty speaks of HG, not HC (https://projects.theforeman.org/issues/35937[#35937], https://github.com/Katello/katello/commit/6b2b86d96f54497527df1387d4048cf151bd9c57[6b2b86d9])

### Tooling
 * Upgrade to Pulpcore 3.22 (https://projects.theforeman.org/issues/35934[#35934], https://github.com/Katello/katello/commit/d298ddad79a61cc5a85a57bfd12b7841b4fd2174[d298ddad])
 * Don't initialize EventDaemon in rake tasks (https://projects.theforeman.org/issues/35774[#35774], https://github.com/Katello/katello/commit/16d25a52bf37b8d2895e96559c8c369883607818[16d25a52], https://github.com/Katello/katello/commit/3ef7613c93985e003e1f07625441706ec120c749[3ef7613c])

### Client/Agent
 * katello-agent use upgrade instead of upgrade-minimal when applying errata in dnf (https://projects.theforeman.org/issues/35759[#35759], https://github.com/Katello/katello-host-tools/commit/046a17d3d52496dc6dfcb825ab900c12ca8a6046[046a17d3])

### Lifecycle Environments
 * Change Content Source should use CV/environment picker from CV UI (https://projects.theforeman.org/issues/35559[#35559], https://github.com/Katello/katello/commit/94066022e08d6fcd0049f9827d7faf063d8cf8d3[94066022], https://github.com/Katello/katello/commit/22e1dbf0d68b4af96c32e48f83196f9628c0d8ca[22e1dbf0])

### Other
 * undefined method `[]' for nil:NilClass" or undefined method `last' for nil:NilClass" when generating Host - applied errata report (https://projects.theforeman.org/issues/36182[#36182], https://github.com/Katello/katello/commit/4b34cadae167b56cd2934607511900901a80bcae[4b34cada])
 * NoMethodError when reassigning hosts while deleting a content view version (https://projects.theforeman.org/issues/36043[#36043], https://github.com/Katello/katello/commit/96c23ce7ffee083be13bb0cfcfa444fb28b5c934[96c23ce7])
 * Subscription can't be blank, A Pool and its Subscription cannot belong to different organizations (https://projects.theforeman.org/issues/36025[#36025], https://github.com/Katello/katello/commit/a52b58a030fad092567feaf8520a8193db7ebd7a[a52b58a0])
 * Migration error 'column settings.category does not exist' (https://projects.theforeman.org/issues/36007[#36007], https://github.com/Katello/katello/commit/87ddaf179f9598bf11b2bce319d0310fc23aee68[87ddaf17])
 * deleting of products after a content export ends up in a candlepin error (https://projects.theforeman.org/issues/35929[#35929], https://github.com/Katello/katello/commit/4d2503ad80f5067ef0f49f439514d4863b98cf9f[4d2503ad])
 * Allow installed_debs method (https://projects.theforeman.org/issues/35886[#35886], https://github.com/Katello/katello/commit/e630a6e28a23795739b05c9625747fa8784884c2[e630a6e2])
 * Stop using #hosts with KTEnvironments (https://projects.theforeman.org/issues/35863[#35863], https://github.com/Katello/katello/commit/fa2e5488fec42e4d0bacaee6c86643e4efca7422[fa2e5488])
 * RABL templates shouldn't rely on single_content_view being non-nil (https://projects.theforeman.org/issues/35857[#35857], https://github.com/Katello/katello/commit/2e03fef93e18b9212a35c94669680ab4f2662bd3[2e03fef9])
 * Last checkin and Registered columns should show up as empty if there's no data (https://projects.theforeman.org/issues/35854[#35854], https://github.com/Katello/katello/commit/3920e5a7384e93769dfa830b8097ed210c9a0e3d[3920e5a7])
 * Switch to standard PF4 search input in Katello (https://projects.theforeman.org/issues/35763[#35763], https://github.com/Katello/katello/commit/1ecd0f23f6b5371719e07f5b017d27a93d03bdc8[1ecd0f23], https://github.com/Katello/katello/commit/a1402c04c8a0c6083096901770080aafd145116f[a1402c04])
 * Improve empty state of repo sets with Limit to environment  (https://projects.theforeman.org/issues/35232[#35232], https://github.com/Katello/katello/commit/a4e03e0a80aec78db8fb815a3e7ed2076637b5c7[a4e03e0a])
