# 4.4.0 Habanero (2022-02-14)

## Features

### Repositories
 * Use the APT verbatim publisher for deb content on Pulp 3 foreman-proxy syncs ([#34279](https://projects.theforeman.org/issues/34279), [4a363fd9](https://github.com/Katello/katello.git/commit/4a363fd945d56ad48f6a30446d9c16320819d4a5))

### Hosts
 * Hosts - Change content source ([#34211](https://projects.theforeman.org/issues/34211), [c5f8e953](https://github.com/Katello/katello.git/commit/c5f8e9532e61f9e5c7ec648decf81660628dd4ba))
 * Katello host detail tabs should accept URL params for search ([#34157](https://projects.theforeman.org/issues/34157), [a12116ef](https://github.com/Katello/katello.git/commit/a12116ef4cb843c87ca9f149b1b573cd14afb03c))
 * [SAT-4229] Packages - Filter by status ([#34131](https://projects.theforeman.org/issues/34131), [38e14d1e](https://github.com/Katello/katello.git/commit/38e14d1e02d73b430ca97fd813c6ac397ac707ee))

### Content Views
 * Extend CV API to support bulk removing versions ([#34168](https://projects.theforeman.org/issues/34168), [9e6b0d07](https://github.com/Katello/katello.git/commit/9e6b0d07ef198f7a0d55399e536844cb0908150b))

### Web UI
 * New Host details overview - Installable errata card ([#33083](https://projects.theforeman.org/issues/33083))

### Foreman Proxy Content
 * Provide RHSM and content URL as info providers ([#32835](https://projects.theforeman.org/issues/32835), [f3daacdb](https://github.com/Katello/katello.git/commit/f3daacdb4f2cb5d13e11401db708b41a0ed1644d))

### Other
 * Add remote download rate limit ([#34345](https://projects.theforeman.org/issues/34345), [7776b81b](https://github.com/Katello/katello.git/commit/7776b81ba39ded5eee3d7cc60dd793640b56132f))
 * Allow "on_demand" download policy for repositories of content_type docker ([#34217](https://projects.theforeman.org/issues/34217), [d2c20af6](https://github.com/Katello/katello.git/commit/d2c20af6911adb02ca9005350a9f2c1ad1f8140b))
 * Add default download policy for deb content ([#34119](https://projects.theforeman.org/issues/34119), [48c128db](https://github.com/Katello/katello.git/commit/48c128db02a1d9e95a81e371f4d9229ae25ebb5b))
 * When choosing what capsule to use for Remote Execution into a host, use the host's "Registered through" capsule ([#33425](https://projects.theforeman.org/issues/33425), [840cbe6f](https://github.com/Katello/katello.git/commit/840cbe6ff546582272ebacf479c25f03c3946c7a))

## Bug Fixes

### Repositories
 * exclude source redhat containers by default ([#34398](https://projects.theforeman.org/issues/34398), [9375ebb3](https://github.com/Katello/katello.git/commit/9375ebb3f9c9a2ae5a1467ac4c6f937a2d3092c3))
 * test_resync_limit_tags_deletes_proper_repo_association_meta_tags fails with VCR error ([#34294](https://projects.theforeman.org/issues/34294), [fd541f5d](https://github.com/Katello/katello.git/commit/fd541f5d384c619e76ce2a4c5533a64ad0d8044f))
 * reindex repos after recreating them as part of correct_repositories ([#34235](https://projects.theforeman.org/issues/34235), [d60fb2b3](https://github.com/Katello/katello.git/commit/d60fb2b3bc6cc087afec8822cf8ff45cb33b7f6a))
 * Restrict to Architecture setting in yum type repos has no effect ([#34041](https://projects.theforeman.org/issues/34041), [68ec6706](https://github.com/Katello/katello.git/commit/68ec6706a796181c9bc57bc73b75002f616f334e))
 * In rare cases upstream APT (deb content) repos can exceed size limited DB fields ([#33804](https://projects.theforeman.org/issues/33804), [e75900ae](https://github.com/Katello/katello.git/commit/e75900ae6383ed62bf2a2b02039e9eaf46bfb78c))
 * Many Postgres ERRORs (duplicate key) especially on RedHat repo sync ([#33451](https://projects.theforeman.org/issues/33451), [215b0401](https://github.com/Katello/katello.git/commit/215b0401dcdda07ecf300d1751b43c2062f461e3))
 * revert monkey patch for pulp_rpm_client 3.13.3 ([#32976](https://projects.theforeman.org/issues/32976), [4897c73c](https://github.com/Katello/katello.git/commit/4897c73c45f375077b41316e301c44348e5a776e))

### Tests
 * host collection test failure ([#34390](https://projects.theforeman.org/issues/34390), [7c635a79](https://github.com/Katello/katello.git/commit/7c635a798248703d1c5f4f8bcc99e2c1e60e8a23))
 * add generic test framework for more easily testing new content types ([#34178](https://projects.theforeman.org/issues/34178), [d5ac4b66](https://github.com/Katello/katello.git/commit/d5ac4b66dc4928c681e59a25a3a6f46019b3fb61))

### Web UI
 * CV UI -  Content view version list API being called multiple times ([#34347](https://projects.theforeman.org/issues/34347), [97a0bd4b](https://github.com/Katello/katello.git/commit/97a0bd4b93653978a475403b3a1bc3f502922388))
 * Fix inconsistent Katello test failures on CI ([#34285](https://projects.theforeman.org/issues/34285), [86565c03](https://github.com/Katello/katello.git/commit/86565c03d852369fa0fa40106d7340b3a8cee51f))
 * Sync status showing never synced even though the repositories has been synced successfully ([#34143](https://projects.theforeman.org/issues/34143), [72756ada](https://github.com/Katello/katello.git/commit/72756ada8c9382b25e4b03d2aaa5ce3b996077c2))
 * Katello - Nightly failures due to package availability ([#33953](https://projects.theforeman.org/issues/33953), [fd833f23](https://github.com/Katello/katello.git/commit/fd833f23e9a69ee8ba035660c339b6e25c1a6d64))
 * New Content View details: Switching autopublish switch reloads entire page ([#32379](https://projects.theforeman.org/issues/32379), [8ca9d36e](https://github.com/Katello/katello.git/commit/8ca9d36efa44b8f2fa0982b066e7483989407fec))

### Hosts
 * Incorrect layout of new host details overview cards ([#34258](https://projects.theforeman.org/issues/34258), [bafada6d](https://github.com/Katello/katello.git/commit/bafada6dd069a3f1715b936cf9d1053a94b06bd9))
 * "Confirm services restart" modal window grammatically does not respect that multiple systems are selected for a reboot ([#34037](https://projects.theforeman.org/issues/34037), [30e6fe7d](https://github.com/Katello/katello.git/commit/30e6fe7d91d6296bb02830e4afaa3f66bee38795))

### Tooling
 * faraday 1.9 and greater breaks tests ([#34229](https://projects.theforeman.org/issues/34229), [64b10e96](https://github.com/Katello/katello.git/commit/64b10e968117c79a441e3f9f1f253605722b2557))
 * Re-enable disabled Rubocop cops that were turned off when fixing Rubocop Jenkins failure step ([#31436](https://projects.theforeman.org/issues/31436), [89230c54](https://github.com/Katello/katello.git/commit/89230c545f5775c347d3bb259cacf89c665e5790))

### Inter Server Sync
 *  [RFE] Need a way to sync from a specific content view lifecycle environment of the upstream organization ([#34144](https://projects.theforeman.org/issues/34144), [0cda22e6](https://github.com/Katello/katello.git/commit/0cda22e6c989d5897bd19b936dead485d7290b73))
 * RH Repos page should not access CDN on 'disconnected' mode ([#33951](https://projects.theforeman.org/issues/33951), [3e8f2696](https://github.com/Katello/katello.git/commit/3e8f26961ff2a84a1de0b5dea197ea49a514d391), [b09ddee2](https://github.com/Katello/katello.git/commit/b09ddee2f2c395c86f2f8c6cc862cc680f9debea))

### Lifecycle Environments
 * Red Hat Satellite should notify about published content view while removing Lifecycle environment ([#33978](https://projects.theforeman.org/issues/33978), [b8ac863c](https://github.com/Katello/katello.git/commit/b8ac863c19f28d000ecd503e5cba359639240dd3))

### Organizations and Locations
 * Creating Organization produces two Audit logs ([#33952](https://projects.theforeman.org/issues/33952), [f83c7856](https://github.com/Katello/katello.git/commit/f83c785650bf03d7f2db00e3aabd7faac9448983), [33994b57](https://github.com/Katello/katello.git/commit/33994b57ed3e28a09ed9974fe58108f856287790))

### Content Views
 * Versions API with wrong/deleted CV id shows all versions in the org ([#33860](https://projects.theforeman.org/issues/33860), [211af427](https://github.com/Katello/katello.git/commit/211af427cb65d74f8ef4d892d1d29c61a191bd84))

### Client/Agent
 * Old ApplicableContentHelper references cause `rake katello:import_applicability` to fail ([#33554](https://projects.theforeman.org/issues/33554), [15ec6dab](https://github.com/Katello/katello.git/commit/15ec6dab54333667ed1a98b3556445f2b56ce57f))

### Other
 * Docker download policy test failure ([#34295](https://projects.theforeman.org/issues/34295), [d4f2976f](https://github.com/Katello/katello.git/commit/d4f2976f4d28e574d291dcbb793afa02b7b8a363))
 * stop using 'mirror=true' for smart proxy rpm repo syncs  ([#34216](https://projects.theforeman.org/issues/34216), [bc1bcf41](https://github.com/Katello/katello.git/commit/bc1bcf41a559006e3ac96b9cb1ef0b24a0be9e19))
 * Generic content units don't have the endpoint to filter out CV or CV-Version specific content ([#34184](https://projects.theforeman.org/issues/34184), [efb05fd6](https://github.com/Katello/katello.git/commit/efb05fd6236b9036a037e0a607c2d45d1fd5a7b9))
 * hammer content-view component list does not list content-view ID ([#34174](https://projects.theforeman.org/issues/34174), [701d9388](https://github.com/Katello/hammer-cli-katello.git/commit/701d938830cc54357bafe19a4be6c857f58cc9dd))
 * support new foreman tasks ([#34097](https://projects.theforeman.org/issues/34097), [d10534ae](https://github.com/Katello/katello.git/commit/d10534ae36aef9843a7a200cf651062d0628e630))
 * Enable debian architecture support ([#34087](https://projects.theforeman.org/issues/34087), [52d20ee2](https://github.com/Katello/katello.git/commit/52d20ee20cf1865bbafb2e5bc3a6d05864217920))
 * Error Can't join 'Katello::ContentFacetRepository' to association named 'hostgroup' when clicking on "Errata Installation" inside a host_collection as a non-admin user ([#33940](https://projects.theforeman.org/issues/33940), [27637185](https://github.com/Katello/katello.git/commit/276371854df4323200b9b9414a9f7fea36fe5162))
 * pr template is a little harsh ([#33927](https://projects.theforeman.org/issues/33927), [0a512b24](https://github.com/Katello/katello.git/commit/0a512b242eaa92c03bb0c0d956b88f61c6c88e68))
 * Python backend remote options are not cleared after deleting the field in Katello ([#33685](https://projects.theforeman.org/issues/33685), [5a7dd414](https://github.com/Katello/katello.git/commit/5a7dd4147919010540fc8ea402cc1d072ffc5572))
