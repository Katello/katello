# 3.15.3 Rocky Road (2020-07-02)

## Bug Fixes

### Tests
 * react tests - eslint is failing ([#30241](https://projects.theforeman.org/issues/30241), [4e8ef6c4](https://github.com/Katello/katello.git/commit/4e8ef6c41bfa1b75232acce5ebe5f04d99dc4b72))

### Orchestration
 * async_task fails with `The Dynflow world was not initialized yet.` in rake tasks on nightly production ([#29337](https://projects.theforeman.org/issues/29337), [be88d945](https://github.com/Katello/katello.git/commit/be88d94503b1448c1c7ea8043d0c86424a6bcd3b))

### Other
 * Deleting global default HTTP proxy does not reset repositories or settings using the global default HTTP proxy ([#30100](https://projects.theforeman.org/issues/30100), [bc8bc4aa](https://github.com/Katello/katello.git/commit/bc8bc4aaf6831ea75ef1a21bb8e56cf3eda4e8c5))
 * Katello Scenario with external database fails during migration ([#29689](https://projects.theforeman.org/issues/29689), [41711a2d](https://github.com/Katello/katello.git/commit/41711a2d9397c42d5961eba03cd236679e208075))

# 3.15.2 Rocky Road (2020-06-16)

## Bug Fixes

### Hosts
 * Actions::Katello::Host::UploadProfiles failing at upload_modules_to_pulp ([#29961](https://projects.theforeman.org/issues/29961), [7b726086](https://github.com/Katello/katello.git/commit/7b726086422f9a5c9bde1f4eb224a521b3e1d310))

### Repositories
 * Minor fixes for developing for pulp3 ([#29449](https://projects.theforeman.org/issues/29449), [e38b9e2f](https://github.com/Katello/katello.git/commit/e38b9e2f4924b50961629b51ba21d0338b822f85))

# 3.15.1 Rocky Road (2020-05-26)

## Bug Fixes

### Foreman Proxy Content
 * simultaneously syncing multiple LCEs on smart proxy fails due to "required lock" error ([#29678](https://projects.theforeman.org/issues/29678), [246d899a](https://github.com/Katello/katello.git/commit/246d899a47ee11b358b92b5ff722ee1a582220a7))

### Hosts
 * upgraded 3.15 katello fails sometimes uploading package profile ([#29653](https://projects.theforeman.org/issues/29653), [89f83399](https://github.com/Katello/katello.git/commit/89f83399d7a11e80754eb0f097185b26c5d6bc83))

### Repositories
 * handle smart proxy refresh with missing pulp3 capabilities ([#29650](https://projects.theforeman.org/issues/29650), [e5a6f749](https://github.com/Katello/katello.git/commit/e5a6f7498892b941edfbe04d829022520c5ca672))

### Documentation
 * update http proxies documentation for 3.15 ([#29638](https://projects.theforeman.org/issues/29638))

### Modularity
 *  Applicable errata not showing up for module stream errata ([#29488](https://projects.theforeman.org/issues/29488), [34ea1d9f](https://github.com/Katello/katello.git/commit/34ea1d9f09d072c6a7c7b8ad90cd383798373552))

### Docker
 * container tags don't show all lifecycle envs/cvs on details page ([#29454](https://projects.theforeman.org/issues/29454), [576259f4](https://github.com/Katello/katello.git/commit/576259f4f4551d2a596b9577cc21fc84d7eea480))

### Other
 * Orphaned repos cause `ERROR: at least one katello_docker_tags record has migrated_pulp3_href NULL value` during pulp3_content_switchover ([#29595](https://projects.theforeman.org/issues/29595), [590a15e9](https://github.com/Katello/katello.git/commit/590a15e97983f2a2a5bde7f67f5d2907ed338ef6))
 * Katello Ansible Template for yum package install missing yes flag ([#29260](https://projects.theforeman.org/issues/29260), [21bffbad](https://github.com/Katello/katello.git/commit/21bffbadc4cc9e0acb29213704be6ab9840b66d5))

# 3.15.0 Rocky Road (2020-04-15)

## Features

### Errata Management
 * Add proper InstalledPackage model associations for Pulp 3 Applicability prep ([#28886](https://projects.theforeman.org/issues/28886), [14e31703](https://github.com/Katello/katello.git/commit/14e3170395708f7e75e54bc6138b171780421a90))
 * Allow searching errata by issued date ([#28780](https://projects.theforeman.org/issues/28780), [9dd8c02f](https://github.com/Katello/katello.git/commit/9dd8c02f02d73d6064ce3a2c4d220c5a1a50d104))

### Upgrades
 * support repository migration to pulp3 ([#28879](https://projects.theforeman.org/issues/28879), [b28b6c56](https://github.com/Katello/katello.git/commit/b28b6c56d8cf6d26f78abbc0d442965da12d70ec))
 * rake task should validate that all expected content is migrated once it completes ([#28660](https://projects.theforeman.org/issues/28660), [0f32a081](https://github.com/Katello/katello.git/commit/0f32a0811a20e76cc6509c793dc6e5ed608be377))
 * Rake task to switchover any data from pulp2 ids to pulp3 ids ([#28657](https://projects.theforeman.org/issues/28657), [ff5f2fe0](https://github.com/Katello/katello.git/commit/ff5f2fe0ee34f82e27d3c79d4d3f3e3778a42ec5))

### API
 * deprecate ostree and puppet types ([#28873](https://projects.theforeman.org/issues/28873), [346bb238](https://github.com/Katello/katello.git/commit/346bb2384586e7442f79a4b0f2c47bc3199aa500))

### Hammer
 * hammer sync-plan info doesn't show the next sync plan field ([#28852](https://projects.theforeman.org/issues/28852), [89633d69](https://github.com/Katello/hammer-cli-katello.git/commit/89633d69b6fe28d016ddea723b55e12e007a947b))
 * add possibiliy to add ssl-stuff with the name ([#28294](https://projects.theforeman.org/issues/28294), [b6f129a1](https://github.com/Katello/hammer-cli-katello.git/commit/b6f129a1b7245226499540e2aeb49a14a83cd1ed), [801649e1](https://github.com/Katello/katello.git/commit/801649e1efec04e439ad79262200b0be7fc6f55b))
 * Rename "hammer gpg" command ([#28293](https://projects.theforeman.org/issues/28293), [5c2a94c1](https://github.com/Katello/hammer-cli-katello.git/commit/5c2a94c159df8d7130fc0ad73c8589085d9b441c))

### Subscriptions
 * [sat-e-390] Provide informative message on Content -> Subscriptions page when in Simple Content Access ([#28842](https://projects.theforeman.org/issues/28842), [e451d816](https://github.com/Katello/katello.git/commit/e451d816df1f5762bef1b5c5e182c78537fd6e1f))
 * Disable auto-attach for Host Collection while in Simple Content Access ([#28778](https://projects.theforeman.org/issues/28778), [63b72b6f](https://github.com/Katello/katello.git/commit/63b72b6ffebe3724158abcd593be3ce844eec50a))
 * As user I want to see a "disabled" status for Golden Ticketed Orgs ([#28721](https://projects.theforeman.org/issues/28721), [62f26fab](https://github.com/Katello/katello.git/commit/62f26fab0018afd66bc6f124d1c35b676c75215e))
 * Handle ManifestRefresh with Pulp 3 ([#28183](https://projects.theforeman.org/issues/28183), [645def3a](https://github.com/Katello/katello.git/commit/645def3aa6f1edec7ef62e8c062bdf84e87f189c), [36938093](https://github.com/Katello/katello.git/commit/369380931608509ca493c4ef3230ec83db976cd3))

### Tooling
 * foreman-debug support for pulp3 ([#28501](https://projects.theforeman.org/issues/28501))
 * Drop katello-service  ([#28180](https://projects.theforeman.org/issues/28180))
 * katello reset needs to reset pulp3 database  ([#28102](https://projects.theforeman.org/issues/28102), [5c7d6199](https://github.com/Katello/katello.git/commit/5c7d61990adca10d5d06aa3e9573e897671501a1))
 * As a user, i can execute a rake task to migrate content to pulp3 ([#27934](https://projects.theforeman.org/issues/27934), [74f35987](https://github.com/Katello/katello.git/commit/74f359874477fb52a252d6ee337ba001d729eff6))

### Repositories
 * Index package groups and SRPMs from Pulp 3 ([#28459](https://projects.theforeman.org/issues/28459), [d0772a41](https://github.com/Katello/katello.git/commit/d0772a41ed9b446e1f71bcefffbb9652bec1eeaa))
 * as a user, i can publish a yum repository with no filters with pulp3 ([#28195](https://projects.theforeman.org/issues/28195), [f3d2b3b8](https://github.com/Katello/katello.git/commit/f3d2b3b8dd5aea663b95952dcb39e01b516099c9))
 * As a user I can remove rpms from a pulp3 yum repository ([#28194](https://projects.theforeman.org/issues/28194), [fa2fed65](https://github.com/Katello/katello.git/commit/fa2fed65832d08bdd1ee264bfdd8904fa609b218), [5895cc59](https://github.com/Katello/katello.git/commit/5895cc59ddef4557cfaec77b9e63e8dbbf954d48), [4a22e6a0](https://github.com/Katello/katello.git/commit/4a22e6a0935d151f6fd565332a9d65775db49a98), [5f7f32eb](https://github.com/Katello/katello.git/commit/5f7f32ebf1f4a221b6c370ea2a15b733e18527b8), [e57649eb](https://github.com/Katello/katello.git/commit/e57649eb18c27b30816e3f3a5d2d2eecad87b661))
 * Upload rpm content  to pulp3 ([#28050](https://projects.theforeman.org/issues/28050), [73b500f3](https://github.com/Katello/katello.git/commit/73b500f3b6a6469a6ce9f80cedceec692fe9f675))
 * Index a yum repository (except errata) after syncing with pulp3 ([#28049](https://projects.theforeman.org/issues/28049), [4b8709c0](https://github.com/Katello/katello.git/commit/4b8709c0282b063c4f03a2171a790a7be6be4bb5))
 * Trigger orphan cleanup in pulp3 ([#28048](https://projects.theforeman.org/issues/28048), [b6d3ea23](https://github.com/Katello/katello.git/commit/b6d3ea239319cd2f68c832d11c9928f816904bd4), [1cd2353f](https://github.com/Katello/katello.git/commit/1cd2353f4e73e39e43353474ab9a6728a30d210d), [3695778b](https://github.com/Katello/katello.git/commit/3695778bf905e8015dec854d7c8f053b7c2f3328))

### Hosts
 *  Move Actions::Katello::Host::Update out of dynflow ([#28317](https://projects.theforeman.org/issues/28317), [2ae55d3e](https://github.com/Katello/katello.git/commit/2ae55d3e841ff5e8699c94a31774262b337cd4d2), [8954ae6d](https://github.com/Katello/katello.git/commit/8954ae6dba085b07d28e80693a594227e3811bbd))
 * Create Report Template to list inactive hosts ([#28211](https://projects.theforeman.org/issues/28211), [fc40e380](https://github.com/Katello/katello.git/commit/fc40e38029a95bcb9f75535f268c4399f0b2215d))
 * Deprecate applicable_errata in Host Bulk Actions API response ([#25440](https://projects.theforeman.org/issues/25440), [da1dc560](https://github.com/Katello/katello.git/commit/da1dc56012749d29d016243ce86fe73bc6f96245))

### Web UI
 * Upgrade vendor to v3 ([#28241](https://projects.theforeman.org/issues/28241), [01850835](https://github.com/Katello/katello.git/commit/01850835b2c9901923e2cad83862887ed4452b34), [90ee6e7b](https://github.com/Katello/katello.git/commit/90ee6e7b50402a0055ded6e8b21846712eb6bed7))
 * Use ForemanModal in Katello modals ([#28056](https://projects.theforeman.org/issues/28056), [7ced8f27](https://github.com/Katello/katello.git/commit/7ced8f27806a3efd3660c4464b7b4c6d164af453))

### Foreman Proxy Content
 * make it clear for a smart proxy what is running in pulp2 vs pulp3 ([#28047](https://projects.theforeman.org/issues/28047), [822c2121](https://github.com/Katello/katello.git/commit/822c2121f13b3c6c72f3414128964ebec34f58bf), [b2fcf70d](https://github.com/Katello/katello.git/commit/b2fcf70d0b6da0cbe1797b62faa78e881db31c0a))

### Host Collections
 * HostCollection Errata Install WebUI errata selection and pagination issues ([#27647](https://projects.theforeman.org/issues/27647), [3b7824c6](https://github.com/Katello/katello.git/commit/3b7824c6f28dd5db8eb884e66a14ec125070f239), [667ff57a](https://github.com/Katello/katello.git/commit/667ff57ad9cf874886e97eac51c70556425b839b))

### Other
 * Add consumed into jail for pool ([#28865](https://projects.theforeman.org/issues/28865), [0a0dc761](https://github.com/Katello/katello.git/commit/0a0dc761a0057ee068d01a08288aa44db9d68076))
 * Allow pool organization in safe mode ([#28789](https://projects.theforeman.org/issues/28789), [d6939f6f](https://github.com/Katello/katello.git/commit/d6939f6ff0c5936c00d03ed900a1fd597d0dc176))
 * Extend Organization Jail from core ([#28773](https://projects.theforeman.org/issues/28773), [80e077bb](https://github.com/Katello/katello.git/commit/80e077bbe306c04f13a70e18f4bdf6f28418669c))

## Bug Fixes

### Hosts
 * bulk errata install prefers errata_ids even when install_all is passed ([#29374](https://projects.theforeman.org/issues/29374), [f628c5fa](https://github.com/Katello/katello.git/commit/f628c5fa37a28bc22c6dbb53e2ad719aacf91a1e))
 * Store DMI UUID on Subscription Facet ([#28656](https://projects.theforeman.org/issues/28656), [7eb48bf9](https://github.com/Katello/katello.git/commit/7eb48bf97db6246f52ae7ffc3ebecb5f7f6c0eb4))
 * Editing a host group result in blank page ([#28383](https://projects.theforeman.org/issues/28383), [67e904fa](https://github.com/Katello/katello.git/commit/67e904fa847f4c400fa13acf668bcbe5d984c83f))

### Settings
 * deprecate background download policy in settings ([#29314](https://projects.theforeman.org/issues/29314), [87749303](https://github.com/Katello/katello.git/commit/87749303029ccba42b35e1c4145d2cbed35096a7))
 * hammer settings content_default_http_proxy  does not have validation for provided values ([#28386](https://projects.theforeman.org/issues/28386), [23db0e06](https://github.com/Katello/katello.git/commit/23db0e06ea24eaac541771f3bd5ed471470a69b7))

### Client/Agent
 * deprecate katello-agent in satellite 6.7 ([#29200](https://projects.theforeman.org/issues/29200), [4235120a](https://github.com/Katello/katello.git/commit/4235120a90caf579e9c119ff3ea30c2951ba261b))
 * [RHEL 8.1 client - libdnf] All packages are not getting updated after click on "Update All Packages"  ([#28909](https://projects.theforeman.org/issues/28909), [011a2308](https://github.com/Katello/katello-host-tools.git/commit/011a23084ae8f455ffdf9200fa5b704927a7fb67))
 * enabled_repos_upload should not spam the console ([#27912](https://projects.theforeman.org/issues/27912), [c35bed91](https://github.com/Katello/katello-host-tools.git/commit/c35bed912441f5e1662ce0eb8eceb70448b5260c))
 * package profile upload & repos upload needs to use subman combined profiles ([#27650](https://projects.theforeman.org/issues/27650), [3d780978](https://github.com/Katello/katello-host-tools.git/commit/3d780978ffe57eded5b501112a67a8a913aed899))

### Repositories
 * migrated docker tags may have their pulp3 href change after multiple migrations ([#29199](https://projects.theforeman.org/issues/29199), [b693a0b9](https://github.com/Katello/katello.git/commit/b693a0b908a9f41bebeb6a7460c747433f2b2819))
 * [pulp3] file uploads via hammer fail ([#29007](https://projects.theforeman.org/issues/29007), [53f50325](https://github.com/Katello/katello.git/commit/53f50325a502997ced2239f2ecf11d1d31d45121))
 * Remove references to :cdn_proxy, HTTP proxy db seeds ([#28834](https://projects.theforeman.org/issues/28834), [d593923a](https://github.com/Katello/katello.git/commit/d593923a18d445f853d61d8af9d9a86e6195c82c))
 * Product sync-status of latest repo-sync vs. sync-status of all repo-syncs ([#28818](https://projects.theforeman.org/issues/28818), [d79d11d8](https://github.com/Katello/katello.git/commit/d79d11d8262507ac81362d22a915a966ca9d453c), [acc1d7ca](https://github.com/Katello/hammer-cli-katello.git/commit/acc1d7ca7c0962002591baee9e95e961c8f41bc4), [3c9f3cd9](https://github.com/Katello/katello.git/commit/3c9f3cd98cac28b5ee2b7d36c9bed3aa8d8f159b), [17969c24](https://github.com/Katello/katello.git/commit/17969c24e0bc54a07362084bfbafabf07c86d960))
 * publish_unpublished_repositories tasks references column that was moved to another table ([#28811](https://projects.theforeman.org/issues/28811), [beec7cbd](https://github.com/Katello/katello.git/commit/beec7cbdb600a30a730cea972def63b710d12e16))
 * repository show template displays incorrect HTTP proxy attributes when global HTTP proxy policy is selected ([#28794](https://projects.theforeman.org/issues/28794), [6dc6e0cc](https://github.com/Katello/katello.git/commit/6dc6e0cc4f92aa450f0c155b0dedf4498953164e))
 * Products-API has no result for sync_summary ([#28777](https://projects.theforeman.org/issues/28777), [ba65d4c1](https://github.com/Katello/katello.git/commit/ba65d4c1648924350cd0004b230c4a9d92c35dee))
 * Required lock is already taken by other running tasks." error in production.log while assigning HTTP Proxy to Products ([#28709](https://projects.theforeman.org/issues/28709), [21fb2f37](https://github.com/Katello/katello.git/commit/21fb2f3701cce783e01fe0c2a42ec91564ae61f9))
 * inconsistent repository enabled state for RHEL8 repository sets in the API ([#28644](https://projects.theforeman.org/issues/28644), [1a440ef3](https://github.com/Katello/katello.git/commit/1a440ef348422de50cf8d63c195f7480bacd621e))
 * some redhat repos do not pop back up on the left after disabling them ([#28621](https://projects.theforeman.org/issues/28621), [228a0212](https://github.com/Katello/katello.git/commit/228a0212b264b4f6240a42c8a1f31b7d62642c2e))
 * Pulp Repository Clear references `clone` instead of `repo`. ([#28557](https://projects.theforeman.org/issues/28557), [35e1895a](https://github.com/Katello/katello.git/commit/35e1895aa722a10e7681121dd5a55a5da5d6731e))
 * Recommended repositories page shows  Capsule/Tools repos for 6.6 version ([#28537](https://projects.theforeman.org/issues/28537), [4d596497](https://github.com/Katello/katello.git/commit/4d59649799bb4a4715fc3f94c71346ab10828754))
 * Red Hat Satellite Tools 6.5 repository for RHEL 8  showing not selected on Red Hat Satellite ([#28489](https://projects.theforeman.org/issues/28489), [3328a512](https://github.com/Katello/katello.git/commit/3328a512f812c6f46e9010b56f66524eb9beda73))
 * Text for "http proxy" should be changed to "HTTP proxy" or "HTTP Proxy" ([#28474](https://projects.theforeman.org/issues/28474))
 * Pulp 3 Docker repo distribution collision for mirrors when changing environment naming scheme ([#28354](https://projects.theforeman.org/issues/28354))
 * update to typed repositories with new bindings ([#28249](https://projects.theforeman.org/issues/28249), [667d9d39](https://github.com/Katello/katello.git/commit/667d9d39f3550dbedba1aa7c7ebb990e1d0179ea))
 * Change package build time from seconds to human readable format ([#28231](https://projects.theforeman.org/issues/28231), [80eca9dc](https://github.com/Katello/katello.git/commit/80eca9dcc3f6b52d869d28c9eb81208900c376c2))
 * repositories controller responds with 200 instead of 201 to a POST request ([#28219](https://projects.theforeman.org/issues/28219), [1ff94c3a](https://github.com/Katello/katello.git/commit/1ff94c3a3187443e29e186b87ceb11d085fd4f29))
 * pulp3 sync statuses lines are not consistently ordered ([#28206](https://projects.theforeman.org/issues/28206), [00a58b45](https://github.com/Katello/katello.git/commit/00a58b45d2ce0069bfe03e28c1b6a34c960c2bf8))
 * Repository create with http_proxy name fails with  Error: Found more than one http_proxy. ([#28178](https://projects.theforeman.org/issues/28178), [1d3e98bf](https://github.com/Katello/hammer-cli-katello.git/commit/1d3e98bf0c35b08c62489dcccfc7e6b316240280))
 * Deleting old distributions on pulp mirrors for pulp3 ([#27938](https://projects.theforeman.org/issues/27938), [9aa9fa8b](https://github.com/Katello/katello.git/commit/9aa9fa8bd116fcc565bda5b7ecc6212cb9591641))

### Upgrades
 * after pulp3 migration, docker schema v1 tags that haven't been migrated should be deleted ([#29197](https://projects.theforeman.org/issues/29197), [c67ab40e](https://github.com/Katello/katello.git/commit/c67ab40e47bee053e4f147e31b679a230418bf41))
 * prevent rake katello:pulp3_migration and switchover from running if its already been switched over ([#29125](https://projects.theforeman.org/issues/29125), [52bb96ca](https://github.com/Katello/katello.git/commit/52bb96ca675c466120fbd94d7edfb8c0b4f4b647))

### Content Views
 * deleting a content view should delete all pulp3 repositories associated with it in pulp3 ([#29122](https://projects.theforeman.org/issues/29122), [665d679c](https://github.com/Katello/katello.git/commit/665d679c5b667f09c378f39b8013b42637876160))
 * Erratum Excludes filter by id not working in some cases ([#28988](https://projects.theforeman.org/issues/28988), [df338af8](https://github.com/Katello/katello.git/commit/df338af817ef6f53b312bee148a6e4edf9114d09))
 * Content View publishing fails after katello_repository_rpms "id" column hits max integer size ([#28831](https://projects.theforeman.org/issues/28831), [109ab480](https://github.com/Katello/katello.git/commit/109ab4805a4b72e4a6ca58316470c17fa1c39297))
 * Publishing a new version of Content view is slow and taking huge time  ([#28677](https://projects.theforeman.org/issues/28677), [b85e018f](https://github.com/Katello/katello.git/commit/b85e018fba06aabde4dac2c4a996f39558db0d5e))
 * Content view versions list has slow query for package count ([#28427](https://projects.theforeman.org/issues/28427), [b2c46015](https://github.com/Katello/katello.git/commit/b2c46015f0790bd4cb0b9e3a7699ef6852240530))

### Subscriptions
 * Prevent setting auto-attach on Activation Key when in Simple Content Access ([#29094](https://projects.theforeman.org/issues/29094), [8fdefe32](https://github.com/Katello/katello.git/commit/8fdefe329b1f923a4703a63cd5d9bd8ae839588e))
 * loading subscriptions page is very slow ([#28894](https://projects.theforeman.org/issues/28894), [9b47cf0a](https://github.com/Katello/katello.git/commit/9b47cf0a2d1e0638ce15df75db68a6abec9f36fb))
 * Disable Auto attach on Host Subscriptions for Golden Ticketed org ([#28781](https://projects.theforeman.org/issues/28781), [97589ec7](https://github.com/Katello/katello.git/commit/97589ec7e1a56f2e8a0f8398172828e155c4743b), [8fdefe32](https://github.com/Katello/katello.git/commit/8fdefe329b1f923a4703a63cd5d9bd8ae839588e))
 * An admin cannot GET subscription/manifest uploaded in org created by another admin ([#28751](https://projects.theforeman.org/issues/28751), [844f3c24](https://github.com/Katello/katello.git/commit/844f3c244196ba9f5ea991ab16bd9f1778ba06b2))
 * Page should auto-refresh after subscriptions have been modified on the webui ([#28659](https://projects.theforeman.org/issues/28659), [aa41e9da](https://github.com/Katello/katello.git/commit/aa41e9dab385884a025829f50f675f5b48b8cb97), [8dd1a030](https://github.com/Katello/katello.git/commit/8dd1a0305ee994a987f69c394a15c832a5df0ac7))

### Tests
 * eslint errors on master branch ([#29001](https://projects.theforeman.org/issues/29001), [f9d5042c](https://github.com/Katello/katello.git/commit/f9d5042c6842652bd61bc0ff992836531e55447b))
 * Lock mock version in host tools ([#28962](https://projects.theforeman.org/issues/28962), [9e4e264f](https://github.com/Katello/katello-host-tools.git/commit/9e4e264f61c505683965b60bd76735a81f803eda))
 * product update proxy test - fix it ([#28792](https://projects.theforeman.org/issues/28792), [796b07df](https://github.com/Katello/katello.git/commit/796b07dff0ef934e65b5be06cdd373797d47962f))
 * transient test failure - test_errata_filter – Katello::Service::Repository::YumVcrCopyTest ([#28699](https://projects.theforeman.org/issues/28699), [d1229112](https://github.com/Katello/katello.git/commit/d12291127f9e91809466910b361f433286fb9d16))
 * katello-host-tools el5 build broken ([#28455](https://projects.theforeman.org/issues/28455), [0ad0f6f7](https://github.com/Katello/katello-host-tools.git/commit/0ad0f6f72bfced4866190c96be61b7c8d00a87e2))
 * React UI Snapshot Tests are failing and out of date ([#28446](https://projects.theforeman.org/issues/28446), [38bcdd15](https://github.com/Katello/katello.git/commit/38bcdd15f0f95eb704ff1eea673b9c7e9550d030), [d3ce6ce9](https://github.com/Katello/katello.git/commit/d3ce6ce9f6d51cb4c07717a5eb55f938f20213b8))
 * Need to un-skip Actions::Pulp3::FileSyncTest#test_sync_with_mirror_false once Pulp 3 issue is fixed ([#28368](https://projects.theforeman.org/issues/28368), [d9f5d173](https://github.com/Katello/katello.git/commit/d9f5d173cb8a604caae3ad20c3f237d06c0f846b))
 * Transient test failure Actions::Pulp::Repository::RemoveUnitTest.test_remove_with_contents ([#28284](https://projects.theforeman.org/issues/28284), [191e9aa7](https://github.com/Katello/katello.git/commit/191e9aa77c88d6501552ad2d131da30b962924a6))
 * master test failure: Actions::Pulp3::CopyAllUnitsTest.test_exclusion_docker_filters   VCR failure ([#28165](https://projects.theforeman.org/issues/28165), [6d0d9151](https://github.com/Katello/katello.git/commit/6d0d91511f288ad7b1a922af645e0a3a3b7a2673))

### Hammer
 * deprecate ostree and puppet types ([#28908](https://projects.theforeman.org/issues/28908), [3c825116](https://github.com/Katello/hammer-cli-katello.git/commit/3c825116892f5e79c83837ec0c8fb03ad0b912f9))
 * hammer repository info commands shows "Http Proxy Policy" in products section instead of showing it in Http Proxy section. ([#28864](https://projects.theforeman.org/issues/28864), [cfc48b75](https://github.com/Katello/hammer-cli-katello.git/commit/cfc48b751da3d0e425fcc37be6ef6e7c21af7b8f))
 * Deleting organization by title does not work in hammer ([#28833](https://projects.theforeman.org/issues/28833), [6b890a89](https://github.com/Katello/hammer-cli-katello.git/commit/6b890a894dc90f2ecf44a79b4e9906a222f41e44))
 * Repository info does not show assigned http_proxy policy ([#28486](https://projects.theforeman.org/issues/28486), [749cbe65](https://github.com/Katello/hammer-cli-katello.git/commit/749cbe650627caf5a120f2c16ef7cfa20c5817eb))
 * Unable to assign http_proxy to a product using hammer CLI ([#28175](https://projects.theforeman.org/issues/28175), [3553ce62](https://github.com/Katello/hammer-cli-katello.git/commit/3553ce62eafc778a61bc012bb870292bce75a3ef))
 * hammer throws "too few arguments (ArgumentError)" when Satellite returns 500 ([#27548](https://projects.theforeman.org/issues/27548), [63e9f595](https://github.com/Katello/hammer-cli-katello.git/commit/63e9f595c14637597b1eb0a7c1a6c6943613cf09))

### Foreman Proxy Content
 * foreman proxy with content always tries to sync from port :5000, even if pulp3 is handling docker content ([#28880](https://projects.theforeman.org/issues/28880), [3d32c6a5](https://github.com/Katello/katello.git/commit/3d32c6a5a3ef9b20ee1bda3d8719aca2cc633f9e))
 * pulpcore content types don't show up on smart proxy features page ([#28829](https://projects.theforeman.org/issues/28829), [557cb453](https://github.com/Katello/katello.git/commit/557cb453fbf0c095552063fa83ac740ac65fe75b))
 * switch to smart proxy pulpcore plugin ([#28671](https://projects.theforeman.org/issues/28671), [b3dd9e30](https://github.com/Katello/katello.git/commit/b3dd9e30785b4eecfd548ebdacbc00f84a3d40d0))
 * switch to cert based auth for pulp3 ([#28658](https://projects.theforeman.org/issues/28658), [369badaa](https://github.com/Katello/katello.git/commit/369badaa636dc423b1394487f16b43a048997848))
 * expect /pulp/api/v3/ coming from the smart proxy ([#28529](https://projects.theforeman.org/issues/28529), [0b2f3eb9](https://github.com/Katello/katello.git/commit/0b2f3eb93334e6d4e2d60ed0e38d3c78d2bdcf16))

### Provisioning
 * Adding last_checkin macro to safemode ([#28746](https://projects.theforeman.org/issues/28746), [bf119856](https://github.com/Katello/katello.git/commit/bf1198568ac6ca43ddbc27346c2d4edc7fde561d))

### Modularity
 * As a user I want to be able to upgrade task to reset is_modular ([#28722](https://projects.theforeman.org/issues/28722), [f2ca7695](https://github.com/Katello/katello.git/commit/f2ca7695c3b658cd170ceddfff5382cc5f29044e))

### Roles and Permissions
 *  Non-admin user with enough permissions can't generate report of applicable errata ([#28715](https://projects.theforeman.org/issues/28715), [b626c718](https://github.com/Katello/katello.git/commit/b626c7186cd090b263e33a2ce99d10913c1f5081))
 * Creating a new product by limited permissions user fails with error "NoMethodError: undefined method `[]' for nil:NilClass" ([#28413](https://projects.theforeman.org/issues/28413), [71327211](https://github.com/Katello/katello.git/commit/7132721109753672327386f9c5bce441ae0020eb))

### Docker
 * docker registry in katello doesn't work with installed pulp3 ([#28698](https://projects.theforeman.org/issues/28698), [60698344](https://github.com/Katello/katello.git/commit/606983444717b4e558297393d8a8523d1f99bd84))
 * repository docker tags do not display tag names properly ([#28350](https://projects.theforeman.org/issues/28350), [8c08b9a6](https://github.com/Katello/katello.git/commit/8c08b9a641d0ce375f830347a454440a37032c6b))
 * pulp3: docker distributors are created with base_path of relative_url instead of 'container_repository_name' ([#27942](https://projects.theforeman.org/issues/27942), [f3f4f63a](https://github.com/Katello/katello.git/commit/f3f4f63a3d920bb1d645d1b0c152b40e39cba025))

### Web UI
 * Support multiple vendor version from npm ([#28665](https://projects.theforeman.org/issues/28665), [710c0a01](https://github.com/Katello/katello.git/commit/710c0a0160ca370c42cba3517cb6a5c6153106c6), [b5e7d05c](https://github.com/Katello/katello.git/commit/b5e7d05c134a864e8f1971b803fd2fadc8648bb0))
 * Subscriptions page blank with JS error ([#28423](https://projects.theforeman.org/issues/28423), [f6bfa939](https://github.com/Katello/katello.git/commit/f6bfa939d209b0059f6b9784fe206805b8eb5e59))

### Database
 * sqlite db migration fails with Cannot add a NOT NULL column with default value NULL: ([#28551](https://projects.theforeman.org/issues/28551), [cd83eb38](https://github.com/Katello/katello.git/commit/cd83eb386f116877b2565e672ffbac089c85fcb9))

### API
 * Pulp 3 workers no longer have `reserved-resource-worker-` which breaks ping.rb ([#28478](https://projects.theforeman.org/issues/28478), [90dd3bb4](https://github.com/Katello/katello.git/commit/90dd3bb4af9775fc434a97656084b277c9848d95))

### Sync Plans
 * Sync status information is lost after cleaning up old tasks related to sync. ([#28188](https://projects.theforeman.org/issues/28188), [ea446721](https://github.com/Katello/katello.git/commit/ea4467214aa55d8290d99a873ae171b7c983816a))

### Other
 * rake katello:pulp3_post_migration_check incorrectly warns for nil Docker remote_hrefs ([#29441](https://projects.theforeman.org/issues/29441), [50d4d046](https://github.com/Katello/katello.git/commit/50d4d0468776e54d28fdf91aab60f1cee1d743c9))
 * Migration fails on 20200129172534_add_epoch_version_release_arch_to_katello_installed_packages.rb ([#29389](https://projects.theforeman.org/issues/29389), [189008ec](https://github.com/Katello/katello.git/commit/189008ec3208d8967abbca4bb76592f08b9c6d57))
 * katello:pulp3_content_switchover fails if multiple docker tags point to the same manifest ([#29342](https://projects.theforeman.org/issues/29342), [89bee135](https://github.com/Katello/katello.git/commit/89bee13590f26703d01e05c05c1b527ce31d8d23), [4ba11295](https://github.com/Katello/katello.git/commit/4ba11295b937d1784b7e9bb7dce8188a61c4a0ea))
 * Object references instead of values in generated reports ([#29271](https://projects.theforeman.org/issues/29271), [d33b503d](https://github.com/Katello/katello.git/commit/d33b503da47003a02384c37495afd652bbfd0452), [d6067cf7](https://github.com/Katello/katello.git/commit/d6067cf7fc714fbac5147ba13665be8de0ccf570))
 * loosen pulp3 2to3 migration plugin client bindings requirements ([#29073](https://projects.theforeman.org/issues/29073), [7d978b5a](https://github.com/Katello/katello.git/commit/7d978b5a5ab09b45a21b3b8d4a137c57deb50343), [6be61c3c](https://github.com/Katello/katello.git/commit/6be61c3c6ff56f185c3258f95909c927021a47c7))
 * make pulp client requirements more strict ([#28887](https://projects.theforeman.org/issues/28887), [395c1eaa](https://github.com/Katello/katello.git/commit/395c1eaa951da2589f76f1548952c11a8854ea24))
 * Restore compatibility with foreman-tasks 1.0 ([#28550](https://projects.theforeman.org/issues/28550), [9582fb08](https://github.com/Katello/katello.git/commit/9582fb0823c614c04e2d4be5d0248b76416d93a3))
