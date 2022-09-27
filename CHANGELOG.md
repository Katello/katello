# 4.4.2 Habanero (2022-09-27)

## Bug Fixes

### Repositories
 * Retain packages on Repository removes RPMs from Pulp but not from Katello ([#35120](https://projects.theforeman.org/issues/35120), [9da8f63c](https://github.com/Katello/katello.git/commit/9da8f63c47ee3d1935703dbf9f7daaf22b4b06a4))

### Hosts
 * Repository sets and Errata tabs do not show toggle group when host is in Library environment but non-default content view ([#35114](https://projects.theforeman.org/issues/35114), [12cfaa3a](https://github.com/Katello/katello.git/commit/12cfaa3a800fdd50751ca9b569157fd8feb5182c))
 * All errata are applied when user only selects certain errata ([#35045](https://projects.theforeman.org/issues/35045), [88653969](https://github.com/Katello/katello.git/commit/886539694b79390f890505be7ae0de26f472fabf))

### Upgrades
 * 20211220185935_clean_duplicate_content_units db:migrate fails with child records ([#35031](https://projects.theforeman.org/issues/35031), [66732409](https://github.com/Katello/katello.git/commit/667324096159ef6c0950b40588e3f04cc427c1eb))
# 4.4.1 Habanero (2022-05-25)

## Bug Fixes

### Repositories
 * Missing publications and distributions can cause sync failures ([#34880](https://projects.theforeman.org/issues/34880), [3638d91f](https://github.com/Katello/katello.git/commit/3638d91f74c7031f40c6ac217fdd1f576e118039))

### Errata Management
 * PG::ForeignKeyViolation: ERROR:  update or delete on table "katello_erratum_packages" violates foreign key constraint "katello_msep_erratum_package_id_fk" on table "katello_module_stream_erratum_packages" ([#34870](https://projects.theforeman.org/issues/34870), [a3ce2c52](https://github.com/Katello/katello.git/commit/a3ce2c5216a6ca650ec1ff4b45c9cb83a5402136))

### Upgrades
 * Katello upgrade from 4.4 to 4.4.0.2 still fails during remove duplicate errata ([#34771](https://projects.theforeman.org/issues/34771), [b7572d06](https://github.com/Katello/katello.git/commit/b7572d06e6a9ae8c413fbf230962e34fc50b467d))

### Content Views
 * Hide profiles for module streams since we no longer have that info indexed from  pulp ([#34760](https://projects.theforeman.org/issues/34760), [3afbe21c](https://github.com/Katello/katello.git/commit/3afbe21cda6fa72da5d17c70e5fb7891e2c5b8cc))

### Other
 * Undefined method epoch_to_date when syncing SUSE repos ([#34756](https://projects.theforeman.org/issues/34756), [42dbf62d](https://github.com/Katello/katello.git/commit/42dbf62d47270c67960557f1215f64c62d0392c1))
# 4.4.0.2 Habanero (2022-04-08)

## Bug Fixes

### Repositories
 * Uploaded Rpm(s) replaces Rpm(s) currently in repository ([#34707](https://projects.theforeman.org/issues/34707), [db81b915](https://github.com/Katello/katello.git/commit/db81b9152d3356cd70d7b78c91e4e1b7b3b22984))

### Inter Server Sync
 * LCE and content view label resets when trying to delete the field names in "Upstream Foreman Server" tab ([#34687](https://projects.theforeman.org/issues/34687), [0039255](https://github.com/Katello/katello/commit/0039255d135c4f270e2223fbc9baccc73524bd8f))

# 4.4.0 Habanero (2022-03-17)

## Features

### Content Views
 * Promote button should be displayed in the Content view version ([#34520](https://projects.theforeman.org/issues/34520), [1ef6f014](https://github.com/Katello/katello.git/commit/1ef6f0140d1835e981eae792a000ebe4f59d8bf1))
 * Add repositories button should highlight in Content view ([#34494](https://projects.theforeman.org/issues/34494), [6ad4bc6f](https://github.com/Katello/katello.git/commit/6ad4bc6feb55d45fba938abbdb6ceb50320010b4))
 * Create new content view should redirect to "Repositories" and not "Versions" tab ([#34491](https://projects.theforeman.org/issues/34491), [ff476372](https://github.com/Katello/katello.git/commit/ff476372ba70dc3c8f991cac5bcccf5a35e0d7c2))
 * Extend CV API to support bulk removing versions ([#34168](https://projects.theforeman.org/issues/34168), [9e6b0d07](https://github.com/Katello/katello.git/commit/9e6b0d07ef198f7a0d55399e536844cb0908150b))

### Web UI
 * [SAT-4229] Module streams - basic table ([#34382](https://projects.theforeman.org/issues/34382), [20e8293f](https://github.com/Katello/katello.git/commit/20e8293fb58fb2a9a9ef43b7fdd37a78103d558a))
 * New Host details overview - Installable errata card ([#33083](https://projects.theforeman.org/issues/33083))

### Repositories
 * Add remote download rate limit ([#34345](https://projects.theforeman.org/issues/34345), [7776b81b](https://github.com/Katello/katello.git/commit/7776b81ba39ded5eee3d7cc60dd793640b56132f))
 * Use the APT verbatim publisher for deb content on Pulp 3 foreman-proxy syncs ([#34279](https://projects.theforeman.org/issues/34279), [4a363fd9](https://github.com/Katello/katello.git/commit/4a363fd945d56ad48f6a30446d9c16320819d4a5))
 * Add default download policy for deb content ([#34119](https://projects.theforeman.org/issues/34119), [48c128db](https://github.com/Katello/katello.git/commit/48c128db02a1d9e95a81e371f4d9229ae25ebb5b))
 * De-duplicate errata migration doesn't delete child records ([#34703](https://projects.theforeman.org/issues/34703))

### Hosts
 * [SAT-4229] Content - Packages - Bulk select & remove ([#34220](https://projects.theforeman.org/issues/34220), [5e96a6f8](https://github.com/Katello/katello.git/commit/5e96a6f83e47ce3fe56862bde67d0d0b1c92bcb7))
 * Hosts - Change content source ([#34211](https://projects.theforeman.org/issues/34211), [c5f8e953](https://github.com/Katello/katello.git/commit/c5f8e9532e61f9e5c7ec648decf81660628dd4ba))
 * [SAT-4229] Packages - Install packages modal ([#34191](https://projects.theforeman.org/issues/34191), [d433a901](https://github.com/Katello/katello.git/commit/d433a901c0247b699ff742791367ecd73dd304e5))
 * Katello host detail tabs should accept URL params for search ([#34157](https://projects.theforeman.org/issues/34157), [a12116ef](https://github.com/Katello/katello.git/commit/a12116ef4cb843c87ca9f149b1b573cd14afb03c))
 * [SAT-4229] Packages - Filter by status ([#34131](https://projects.theforeman.org/issues/34131), [38e14d1e](https://github.com/Katello/katello.git/commit/38e14d1e02d73b430ca97fd813c6ac397ac707ee))

### Container
 * Allow "on_demand" download policy for repositories of content_type docker ([#34217](https://projects.theforeman.org/issues/34217), [d2c20af6](https://github.com/Katello/katello.git/commit/d2c20af6911adb02ca9005350a9f2c1ad1f8140b))

### Foreman Proxy Content
 * When choosing what capsule to use for Remote Execution into a host, use the host's "Registered through" capsule ([#33425](https://projects.theforeman.org/issues/33425), [840cbe6f](https://github.com/Katello/katello.git/commit/840cbe6ff546582272ebacf479c25f03c3946c7a))
 * Provide RHSM and content URL as info providers ([#32835](https://projects.theforeman.org/issues/32835), [f3daacdb](https://github.com/Katello/katello.git/commit/f3daacdb4f2cb5d13e11401db708b41a0ed1644d))

## Bug Fixes

### Repositories
 * Sync error for deb repos after upgrade to 4.3 ([#34591](https://projects.theforeman.org/issues/34591), [504111f7](https://github.com/Katello/katello.git/commit/504111f78731f5f57ee88947855a6e110b301681))
 * Update pulp-rpm to 3.17 ([#34510](https://projects.theforeman.org/issues/34510), [e440920c](https://github.com/Katello/katello.git/commit/e440920cdaf7383c9d427905bf2115e2684ed3e8))
 * Creating repo fails if there's a validation error in the first save. ([#34508](https://projects.theforeman.org/issues/34508), [232dfc9e](https://github.com/Katello/katello.git/commit/232dfc9e6fc83ddbf13e93c216640ee952229d12))
 * Upgrade to Satellite 6.10 fails at db:migrate stage if there are errata reference present for some ostree\puppet type repos ([#34488](https://projects.theforeman.org/issues/34488), [10c7fb70](https://github.com/Katello/katello.git/commit/10c7fb7083f07d6142ca48f0b8b1061464458e91))
 * Retain packages on Repository does not synchronize the specified number of packages on Satellite 7 ([#34469](https://projects.theforeman.org/issues/34469), [8e139559](https://github.com/Katello/katello.git/commit/8e139559acf5010c163278829b3a06f5369b2c53))
 * ReclaimSpace does not acquire repo lock so it can be run concurrently with the repo sync ([#34456](https://projects.theforeman.org/issues/34456), [5b8426e2](https://github.com/Katello/katello.git/commit/5b8426e20f4b5812375ed416180f2181ec94312a))
 * Deletion of Custom repo fails with error "uninitialized constant Actions::Foreman::Exception" in Satellite 7.0 ([#34449](https://projects.theforeman.org/issues/34449))
 * exclude source redhat containers by default ([#34398](https://projects.theforeman.org/issues/34398), [9375ebb3](https://github.com/Katello/katello.git/commit/9375ebb3f9c9a2ae5a1467ac4c6f937a2d3092c3))
 * OSTree upload error: undefined method `parent_commit=' ([#34355](https://projects.theforeman.org/issues/34355), [792fc656](https://github.com/Katello/katello.git/commit/792fc6561220486873616828dfcba55a316a1712))
 * test_resync_limit_tags_deletes_proper_repo_association_meta_tags fails with VCR error ([#34294](https://projects.theforeman.org/issues/34294), [fd541f5d](https://github.com/Katello/katello.git/commit/fd541f5d384c619e76ce2a4c5533a64ad0d8044f))
 * Uploading python packages broken in UI and CLI ([#34245](https://projects.theforeman.org/issues/34245), [d5ac4b66](https://github.com/Katello/katello.git/commit/d5ac4b66dc4928c681e59a25a3a6f46019b3fb61))
 * reindex repos after recreating them as part of correct_repositories ([#34235](https://projects.theforeman.org/issues/34235), [d60fb2b3](https://github.com/Katello/katello.git/commit/d60fb2b3bc6cc087afec8822cf8ff45cb33b7f6a))
 * Enable debian architecture support ([#34087](https://projects.theforeman.org/issues/34087), [52d20ee2](https://github.com/Katello/katello.git/commit/52d20ee20cf1865bbafb2e5bc3a6d05864217920))
 * Restrict to Architecture setting in yum type repos has no effect ([#34041](https://projects.theforeman.org/issues/34041), [68ec6706](https://github.com/Katello/katello.git/commit/68ec6706a796181c9bc57bc73b75002f616f334e))
 * In rare cases upstream APT (deb content) repos can exceed size limited DB fields ([#33804](https://projects.theforeman.org/issues/33804), [e75900ae](https://github.com/Katello/katello.git/commit/e75900ae6383ed62bf2a2b02039e9eaf46bfb78c))
 * Python backend remote options are not cleared after deleting the field in Katello ([#33685](https://projects.theforeman.org/issues/33685), [5a7dd414](https://github.com/Katello/katello.git/commit/5a7dd4147919010540fc8ea402cc1d072ffc5572))
 * Many Postgres ERRORs (duplicate key) especially on RedHat repo sync ([#33451](https://projects.theforeman.org/issues/33451), [215b0401](https://github.com/Katello/katello.git/commit/215b0401dcdda07ecf300d1751b43c2062f461e3))
 * revert monkey patch for pulp_rpm_client 3.13.3 ([#32976](https://projects.theforeman.org/issues/32976), [4897c73c](https://github.com/Katello/katello.git/commit/4897c73c45f375077b41316e301c44348e5a776e))

### Web UI
 * CV UI - Patternfly update causes tabs to navigate twice on click ([#34559](https://projects.theforeman.org/issues/34559), [acf477e2](https://github.com/Katello/katello.git/commit/acf477e24a52ed85d0b89511475e399b75192898))
 * Katello Lint failure due to uncontrolled eslint-plugin update ([#34529](https://projects.theforeman.org/issues/34529), [3b783a50](https://github.com/Katello/katello.git/commit/3b783a50eb2e5ae821ebaa07626e358495389dd5))
 * CV UI -  Content view version list API being called multiple times ([#34347](https://projects.theforeman.org/issues/34347), [97a0bd4b](https://github.com/Katello/katello.git/commit/97a0bd4b93653978a475403b3a1bc3f502922388))
 * Fix inconsistent Katello test failures on CI ([#34285](https://projects.theforeman.org/issues/34285), [86565c03](https://github.com/Katello/katello.git/commit/86565c03d852369fa0fa40106d7340b3a8cee51f))
 * Sync status showing never synced even though the repositories has been synced successfully ([#34143](https://projects.theforeman.org/issues/34143), [72756ada](https://github.com/Katello/katello.git/commit/72756ada8c9382b25e4b03d2aaa5ce3b996077c2))
 * Katello - Nightly failures due to package availability ([#33953](https://projects.theforeman.org/issues/33953), [fd833f23](https://github.com/Katello/katello.git/commit/fd833f23e9a69ee8ba035660c339b6e25c1a6d64))
 * New Content View details: Switching autopublish switch reloads entire page ([#32379](https://projects.theforeman.org/issues/32379), [8ca9d36e](https://github.com/Katello/katello.git/commit/8ca9d36efa44b8f2fa0982b066e7483989407fec))

### Inter Server Sync
 * 4.3 -> nightly update has a bad migration and marks all organizations Airgapped ([#34531](https://projects.theforeman.org/issues/34531), [26afdff1](https://github.com/Katello/katello.git/commit/26afdff1d4917f7b12316c616b28c572bd79c47e))
 *  [RFE] Need a way to sync from a specific content view lifecycle environment of the upstream organization ([#34144](https://projects.theforeman.org/issues/34144), [0cda22e6](https://github.com/Katello/katello.git/commit/0cda22e6c989d5897bd19b936dead485d7290b73))
 * RH Repos page should not access CDN on 'disconnected' mode ([#33951](https://projects.theforeman.org/issues/33951), [3e8f2696](https://github.com/Katello/katello.git/commit/3e8f26961ff2a84a1de0b5dea197ea49a514d391), [b09ddee2](https://github.com/Katello/katello.git/commit/b09ddee2f2c395c86f2f8c6cc862cc680f9debea))


### Tests
 * Remove use of `pulp_` prefixes in the tests ([#34493](https://projects.theforeman.org/issues/34493), [65e30fbc](https://github.com/Katello/katello.git/commit/65e30fbc00176964949274400a6613bb308231d3))
 * host collection test failure ([#34390](https://projects.theforeman.org/issues/34390), [7c635a79](https://github.com/Katello/katello.git/commit/7c635a798248703d1c5f4f8bcc99e2c1e60e8a23))
 * add generic test framework for more easily testing new content types ([#34178](https://projects.theforeman.org/issues/34178), [d5ac4b66](https://github.com/Katello/katello.git/commit/d5ac4b66dc4928c681e59a25a3a6f46019b3fb61))

### Content Views
 * Add activation key and hosts count to CV show rabl ([#34477](https://projects.theforeman.org/issues/34477), [5d6846d9](https://github.com/Katello/katello.git/commit/5d6846d96d3a6c6e6ca6d9dfdb7a453f6331d756))
 * Content column of cvv repository tab should navigate to the associated CVV sub-tab where applicable ([#34418](https://projects.theforeman.org/issues/34418), [53d6d6a5](https://github.com/Katello/katello.git/commit/53d6d6a54e528bf5126a6a29dc5e5e76b6ede026))
 * Applying exclude filter on a CV containing kickstart repos causes missing package groups issue during system build after upgrading to Satellite 6.10 ([#34399](https://projects.theforeman.org/issues/34399), [c2a3bed7](https://github.com/Katello/katello.git/commit/c2a3bed7f848717787d204baf361f56a8403fba8), [7ae11d0b](https://github.com/Katello/katello.git/commit/7ae11d0b4d62429c1df09eb8c2db19266d57e254))
 * Generic content units don't have the endpoint to filter out CV or CV-Version specific content ([#34184](https://projects.theforeman.org/issues/34184), [efb05fd6](https://github.com/Katello/katello.git/commit/efb05fd6236b9036a037e0a607c2d45d1fd5a7b9))
 * Versions API with wrong/deleted CV id shows all versions in the org ([#33860](https://projects.theforeman.org/issues/33860), [211af427](https://github.com/Katello/katello.git/commit/211af427cb65d74f8ef4d892d1d29c61a191bd84))

### Errata Management
 * Post upgrade to 4.1, sync summary email notification shows the incorrect summary for newly added errata. ([#34414](https://projects.theforeman.org/issues/34414), [c89e5680](https://github.com/Katello/katello.git/commit/c89e5680bf4c65e5203f9ed0ab1f6e85b313b40c))

### Container
 * Docker download policy test failure ([#34295](https://projects.theforeman.org/issues/34295), [d4f2976f](https://github.com/Katello/katello.git/commit/d4f2976f4d28e574d291dcbb793afa02b7b8a363))

### Hosts
 * Incorrect layout of new host details overview cards ([#34258](https://projects.theforeman.org/issues/34258), [bafada6d](https://github.com/Katello/katello.git/commit/bafada6dd069a3f1715b936cf9d1053a94b06bd9))
 * "Confirm services restart" modal window grammatically does not respect that multiple systems are selected for a reboot ([#34037](https://projects.theforeman.org/issues/34037), [30e6fe7d](https://github.com/Katello/katello.git/commit/30e6fe7d91d6296bb02830e4afaa3f66bee38795))

### Tooling
 * faraday 1.9 and greater breaks tests ([#34229](https://projects.theforeman.org/issues/34229), [64b10e96](https://github.com/Katello/katello.git/commit/64b10e968117c79a441e3f9f1f253605722b2557))
 * support new foreman tasks ([#34097](https://projects.theforeman.org/issues/34097), [d10534ae](https://github.com/Katello/katello.git/commit/d10534ae36aef9843a7a200cf651062d0628e630))
 * Re-enable disabled Rubocop cops that were turned off when fixing Rubocop Jenkins failure step ([#31436](https://projects.theforeman.org/issues/31436), [89230c54](https://github.com/Katello/katello.git/commit/89230c545f5775c347d3bb259cacf89c665e5790))

### Foreman Proxy Content
 * stop using 'mirror=true' for smart proxy rpm repo syncs  ([#34216](https://projects.theforeman.org/issues/34216), [bc1bcf41](https://github.com/Katello/katello.git/commit/bc1bcf41a559006e3ac96b9cb1ef0b24a0be9e19))

### Hammer
 * hammer content-view component list does not list content-view ID ([#34174](https://projects.theforeman.org/issues/34174), [701d9388](https://github.com/Katello/hammer-cli-katello.git/commit/701d938830cc54357bafe19a4be6c857f58cc9dd))

### Lifecycle Environments
 * Red Hat Satellite should notify about published content view while removing Lifecycle environment ([#33978](https://projects.theforeman.org/issues/33978), [b8ac863c](https://github.com/Katello/katello.git/commit/b8ac863c19f28d000ecd503e5cba359639240dd3))

### Organizations and Locations
 * Creating Organization produces two Audit logs ([#33952](https://projects.theforeman.org/issues/33952), [f83c7856](https://github.com/Katello/katello.git/commit/f83c785650bf03d7f2db00e3aabd7faac9448983), [33994b57](https://github.com/Katello/katello.git/commit/33994b57ed3e28a09ed9974fe58108f856287790))

### Host Collections
 * Error Can't join 'Katello::ContentFacetRepository' to association named 'hostgroup' when clicking on "Errata Installation" inside a host_collection as a non-admin user ([#33940](https://projects.theforeman.org/issues/33940), [27637185](https://github.com/Katello/katello.git/commit/276371854df4323200b9b9414a9f7fea36fe5162))

### Client/Agent
 * Old ApplicableContentHelper references cause `rake katello:import_applicability` to fail ([#33554](https://projects.theforeman.org/issues/33554), [15ec6dab](https://github.com/Katello/katello.git/commit/15ec6dab54333667ed1a98b3556445f2b56ce57f))

### Other
 * pr template is a little harsh ([#33927](https://projects.theforeman.org/issues/33927), [0a512b24](https://github.com/Katello/katello.git/commit/0a512b242eaa92c03bb0c0d956b88f61c6c88e68))
