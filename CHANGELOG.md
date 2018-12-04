# 3.9.1 New England IPA (2018-12-04)

## Features

## Bug Fixes

### Installer
 * Upgrade from 6.4.0 to 6.4.1 failed at Upgrade Step: remove_legacy_mongo ([#25561](https://projects.theforeman.org/issues/25561))

### Upgrades
 * Upgrade issue 3.8 -> 3.9 ([#25544](https://projects.theforeman.org/issues/25544), [dd6df320](https://github.com/Katello/katello.git/commit/dd6df32019fdcd30da9fa7a5e57e3d6bbe372bd9))

### Subscriptions
 * Non-unlimited guest subscriptions breaks subscription page inline edit ([#25464](https://projects.theforeman.org/issues/25464), [ac0620f2](https://github.com/Katello/katello.git/commit/ac0620f2d614d6ad690008f3f5a2d7848972ce6e))

### Content Views
 * Invalid content of CCV with two same repos with filters ([#25452](https://projects.theforeman.org/issues/25452), [021586e3](https://github.com/Katello/katello.git/commit/021586e3f9a092225f9526d11df8bc2b8f49d712))

### Host Collections
 * host_collection controller does not return host_ids key inside a POST response ([#25420](https://projects.theforeman.org/issues/25420), [a9383fbb](https://github.com/Katello/katello.git/commit/a9383fbbbb8660c219d55ed30210a77a7edc2e85))

### Docker
 * publishing docker repo in content view errors with 'Content View publish to environment Library will result in invalid container image name of member repositories' ([#25414](https://projects.theforeman.org/issues/25414), [29d5245e](https://github.com/Katello/katello.git/commit/29d5245e0f0a517921481ff2ddc9433057f519c2))

### Hosts
 * Export list of content host do not honour search filter ([#25226](https://projects.theforeman.org/issues/25226), [0a4673e6](https://github.com/Katello/katello.git/commit/0a4673e6035cc5b0d416035ffac35765b5bfb1aa))

### Other
 * 1.19 -> 1.20 upgrade fail: “add queue katello_event_queue –durable’ returned 1 instead of one of [0] ([#25571](https://projects.theforeman.org/issues/25571))
 * No Product View after Katello Update 3.8 -> 3.9 ([#25562](https://projects.theforeman.org/issues/25562), [d1005da0](https://github.com/Katello/katello.git/commit/d1005da0d2e72f1eea14dd1261070ac077f42776))
 * Singleton actions may not start after unclean shutdown ([#25541](https://projects.theforeman.org/issues/25541), [c23ae22b](https://github.com/Katello/katello.git/commit/c23ae22b7d82fc35e277fb6aad3ae167e706472f))
# 3.9.0 New England IPA (2018-11-16)

## Features

### Errata Management
 * Add report for applicable errata ([#25166](https://projects.theforeman.org/issues/25166), [68527e6d](https://github.com/Katello/katello.git/commit/68527e6d0223485727e63aaed9506b7d9adc1921))

### Hosts
 * Add report for registered hosts ([#25165](https://projects.theforeman.org/issues/25165), [68527e6d](https://github.com/Katello/katello.git/commit/68527e6d0223485727e63aaed9506b7d9adc1921))
 * Display content host system purpose compliance status ([#24916](https://projects.theforeman.org/issues/24916), [3323905d](https://github.com/Katello/katello.git/commit/3323905d7c9d5a4671a01c7d4ca882f5d74cad89))
 * Process candlepin system purpose compliance event ([#24915](https://projects.theforeman.org/issues/24915), [60311a47](https://github.com/Katello/katello.git/commit/60311a47c88902bbbeda6b1fe9c167942ee2ace7))

### Subscriptions
 * Add report for subscriptions ([#25163](https://projects.theforeman.org/issues/25163), [68527e6d](https://github.com/Katello/katello.git/commit/68527e6d0223485727e63aaed9506b7d9adc1921))
 * Add customizable columns to Red Hat Subscriptions Page ([#22733](https://projects.theforeman.org/issues/22733), [f1c81f01](https://github.com/Katello/katello.git/commit/f1c81f012e86477fc0b49e732c70c0ef65e45e4a))

### Installer
 * Send system purpose compliance created even to the katello event queue ([#25082](https://projects.theforeman.org/issues/25082))
 * installer missing --upgrade-mongo-storage option ([#24066](https://projects.theforeman.org/issues/24066), [8d83241f](https://github.com/Katello/katello-installer.git/commit/8d83241fbf57e4e15abdcd2d08e35b5e49dca42c), [c5a1ec41](https://github.com/Katello/katello-installer.git/commit/c5a1ec411f204355bc83c9e8dbeeec808137de30), [596df8d7](https://github.com/Katello/katello-installer.git/commit/596df8d7a8bc9e868680c7349b14a67db6ab583d))

### Hammer
 * As a user I should be able to import a content view from an export tar. ([#25037](https://projects.theforeman.org/issues/25037), [cfac3a5b](https://github.com/Katello/hammer-cli-katello.git/commit/cfac3a5b1980ed824aad6e8f594fb33571c6c215))

### Repositories
 * Add module stream details page ([#24945](https://projects.theforeman.org/issues/24945), [809286ea](https://github.com/Katello/katello.git/commit/809286ea735c1a504b1b3ca7bd48057d00b7f9a9))
 * Searching for all instances of packages in all repos ([#24018](https://projects.theforeman.org/issues/24018), [d2717821](https://github.com/Katello/katello.git/commit/d27178212bb816394949dad8326d7f58853497f7), [dadea2d3](https://github.com/Katello/katello.git/commit/dadea2d36fa7fff0464125ccdaca2d2d72258616), [a88a1ef0](https://github.com/Katello/katello.git/commit/a88a1ef025ac71c3dee53b2f86942f0fc07fb894))
 * De-emphasize yStreams in the repos page ([#23882](https://projects.theforeman.org/issues/23882), [a9909889](https://github.com/Katello/katello.git/commit/a99098890f82c9c8fb6a1de66bb90811a0fa500d), [fea1211d](https://github.com/Katello/katello.git/commit/fea1211ddb6778ca4355159bd9d0cb085ae3a219))

### Lifecycle Environments
 * Provide the ability to delete a lifecycle environment from the middle of an existing path ([#24596](https://projects.theforeman.org/issues/24596), [4aabaa28](https://github.com/Katello/katello.git/commit/4aabaa28b1d8fdafc5696cb763e22a097bee2f00))

### Modularity
 * API/UI - can see modules associated to repositories belonging to the content view version ([#24587](https://projects.theforeman.org/issues/24587), [d9d7fb83](https://github.com/Katello/katello.git/commit/d9d7fb83d0a388ed4bc49cd111e3d70c83d47be9))
 * As a user, I would like a  "UploadModuleProfile" ([#24434](https://projects.theforeman.org/issues/24434))

### API
 * Add purpose attributes ([#24575](https://projects.theforeman.org/issues/24575), [59f3ac49](https://github.com/Katello/katello.git/commit/59f3ac497dd8f37badc15034d3688b14d04c16aa))
 * Add the ability to override 'major' and 'minor' versions of a content view ([#24569](https://projects.theforeman.org/issues/24569), [d95e9b76](https://github.com/Katello/katello.git/commit/d95e9b7675a04d01102fe59ffa8791edab1d82b8), [5eeb68c3](https://github.com/Katello/hammer-cli-katello.git/commit/5eeb68c3816cec9bccb7111128a4e6c9780b09ef))
 * content view filters rule should be filterable via name & errata_id ([#24358](https://projects.theforeman.org/issues/24358), [d24c5017](https://github.com/Katello/katello.git/commit/d24c5017245fed4a34d25d38f92964ad9785f301))
 * Show System Purpose Status via API ([#24177](https://projects.theforeman.org/issues/24177))

### Web UI
 * UI actions for System Purpose on host details page ([#24174](https://projects.theforeman.org/issues/24174), [3704949b](https://github.com/Katello/katello.git/commit/3704949b7553247326794112e1a74ffb3bd2e186))

### Candlepin
 * Upgrade to Candlepin version supporting System Purpose ([#24172](https://projects.theforeman.org/issues/24172))

### Sync Plans
 * Specify custom cron syntax for sync plans ([#23929](https://projects.theforeman.org/issues/23929), [4d2328d5](https://github.com/Katello/katello.git/commit/4d2328d5fea400179d4ec813c1e2e1576549869f))

### Other
 * Add new export command to hammer ([#24963](https://projects.theforeman.org/issues/24963), [94966302](https://github.com/Katello/hammer-cli-katello.git/commit/949663022c7ed41a9ff43d7f59b9f8432838cbf5), [eeaef209](https://github.com/Katello/hammer-cli-katello.git/commit/eeaef20913053732873ce8c4364a4c63de8df278))
 * allow specifying a package list when publishing a content view ([#24902](https://projects.theforeman.org/issues/24902), [fcbd67c7](https://github.com/Katello/katello.git/commit/fcbd67c7c68c3f81cfc0460b6e6040339bea71a2), [a4d21f85](https://github.com/Katello/katello.git/commit/a4d21f85ece031bc6df52230045771be9764488e))
 * Moving Katello to Rails 5.2 ([#24676](https://projects.theforeman.org/issues/24676), [1ff80cec](https://github.com/Katello/katello.git/commit/1ff80cec6979cd391e6340288b50b74d60dbd61b))
 * Add permissions to Canned admin ([#24268](https://projects.theforeman.org/issues/24268), [5eb08cf0](https://github.com/Katello/katello.git/commit/5eb08cf03cb888affefcb5ef91d228d43a6654a4))
 * Port robottelo tests for test_bookmarks ([#24156](https://projects.theforeman.org/issues/24156), [e69d0840](https://github.com/Katello/katello.git/commit/e69d08400fc2f0f113ddd43883fffc8710683237), [0afac09b](https://github.com/Katello/katello.git/commit/0afac09b0ff4a09523271c976deb5f5e48a9ce24))
 * System Purpose P1, P2 ([#24075](https://projects.theforeman.org/issues/24075))

## Bug Fixes

### Upgrades
 * Katello upgrade from 3.8 to 3.9 fails at db:migrate ([#25399](https://projects.theforeman.org/issues/25399), [d303f34f](https://github.com/Katello/katello.git/commit/d303f34f699905a8236fe7e0c7e57793e20bb04f))
 * add sync-plan upgrade task to new upgrade process ([#24828](https://projects.theforeman.org/issues/24828), [7c0e7968](https://github.com/Katello/katello.git/commit/7c0e7968fbbb88fe38ecfe528e505c900c0419e9))

### Installer
 * Upgrading a content proxy fails with module_enabled?: undefined method enabled? for nil:NilClass (NoMethodError) ([#25386](https://projects.theforeman.org/issues/25386), [7211b932](https://github.com/Katello/katello-installer.git/commit/7211b9321cc340fd61e76ee862004e42e7666ef6))
 * While upgrading satellite from 6.3->6.4, satellite-installer does not perform remove_legacy_mongo step in some situations which results in error ([#25336](https://projects.theforeman.org/issues/25336), [6c6fd50a](https://github.com/Katello/katello-installer.git/commit/6c6fd50a40d87c9e9c3bca0d58f2d604b1ecd4e7))
 * improper command given in output of "katello-certs-check" ([#25306](https://projects.theforeman.org/issues/25306), [7314bf2c](https://github.com/Katello/katello-installer.git/commit/7314bf2c6060b1c6cbe100e5bb001e2bbd4ef0e2))
 * Installer fails due to dependency cycle on File[/etc/pki/katello/puppet/puppet_client.crt] ([#25294](https://projects.theforeman.org/issues/25294), [7f79f03f](https://github.com/theforeman/puppet-foreman_proxy_content/commit/7f79f03f1916714f9d96e324122a1ad37766a20b))
 * Set Hibernate logging in Candlepin to ERROR ([#25062](https://projects.theforeman.org/issues/25062), [ed0ed838](https://github.com/theforeman/puppet-candlepin/commit/ed0ed838f05731aa9c49316886b82a4ba0753d8d))
 * upgrade step 'remove_legacy_mongo' continues when "Running installer" failed ([#24966](https://projects.theforeman.org/issues/24966), [c20b390f](https://github.com/Katello/katello-installer.git/commit/c20b390f42dd89ef6a77a33bd70edd14c27b1ca5), [d9e5abbb](https://github.com/Katello/katello-installer.git/commit/d9e5abbb2a5825cac582e3518364718f9c6549bf), [03a363e2](https://github.com/Katello/katello-installer.git/commit/03a363e29078c66c43255510c71ffd7262cb81cf))
 * installer option to change value of "rest_client_timeout" present in /etc/foreman/plugins/katello.yaml does not work ([#24854](https://projects.theforeman.org/issues/24854))
 * Newly added check (check-cert-san) in katello-certs-check is breaking installer for all customers not using Subject Alternative Name (SAN) ([#24815](https://projects.theforeman.org/issues/24815), [0c88a64a](https://github.com/Katello/katello-installer.git/commit/0c88a64a2888f0e1326cfdc63d49376fdcc40b07))
 * need to reset puppet::server_puppetserver_metrics on Puppet4 → Puppet5 upgrade ([#24752](https://projects.theforeman.org/issues/24752), [08d69463](https://github.com/Katello/katello-installer.git/commit/08d694639c2b8a752fa6c8166dea10d5a6fed2c9))
 * installer does not work for custom ssl certificates, fails with "illegal option -- r" for katello-certs-check command  ([#24632](https://projects.theforeman.org/issues/24632), [aa5c8f6d](https://github.com/Katello/katello-installer.git/commit/aa5c8f6d4f63aacb74fda24a78b0b719cdc74a7b))
 * foreman-installer --reset cannot empty local mongo 3.4 database ([#23620](https://projects.theforeman.org/issues/23620), [0da32fc6](https://github.com/Katello/katello-installer.git/commit/0da32fc60ffc5c0f2655b0c61bb79b23285854f9))
 * qdrouterd should listen to ipv6 ([#12386](https://projects.theforeman.org/issues/12386), [89b4ea98](https://github.com/theforeman/puppet-foreman_proxy_content/commit/89b4ea988d18f100b806e7cddc2dca623b68f084), [5cc7d853](https://github.com/Katello/katello-installer.git/commit/5cc7d85377c18143202f6906832b844894265228))

### Repositories
 * deleting a repo after deleting a cvv results in "Couldn't find Katello::Content without an ID" ([#25378](https://projects.theforeman.org/issues/25378), [a07b48df](https://github.com/Katello/katello.git/commit/a07b48dfec88e0fd9d4eda5316bb17f7945cd89c))
 * cannot create two repos in the same organization with the same name ([#25317](https://projects.theforeman.org/issues/25317), [67d88d9d](https://github.com/Katello/katello.git/commit/67d88d9de5b3a99f5442dbe0287788e86c1f8222))
 * Repositories base.json.rabl missing container_repository_name, full_path ([#25288](https://projects.theforeman.org/issues/25288), [ee0b953e](https://github.com/Katello/katello.git/commit/ee0b953e1994a538f0ea65d7363a35560e2db205))
 * Manifest refresh broken when ostree content enabled ([#25210](https://projects.theforeman.org/issues/25210), [e301a19a](https://github.com/Katello/katello.git/commit/e301a19aa2c8df8214a0f9611f04a66800a907d8))
 * Rearrange search/filter options  on Red Hat Repositories page. ([#25068](https://projects.theforeman.org/issues/25068), [d705af4a](https://github.com/Katello/katello.git/commit/d705af4a6390610cd856d99c0b7fd8572b97f172))
 * repository api changed attribute from content_label to cp_label ([#25045](https://projects.theforeman.org/issues/25045), [8f5f02f4](https://github.com/Katello/katello.git/commit/8f5f02f4c832e5e909cda53d5e211bafae68761e))
 * allow any length passwords for docker repositories ([#24994](https://projects.theforeman.org/issues/24994), [e5337152](https://github.com/Katello/katello.git/commit/e53371520db67ed5ec09f99b6db167a784f9eb83))
 * Show Repo Label on Enabled repos results ([#24827](https://projects.theforeman.org/issues/24827), [7764ddf8](https://github.com/Katello/katello.git/commit/7764ddf8cc49261fe77ff222d65279717349a15e))
 * 'orphaned' text is missing from orphaned repositories on the Red Hat Repos page ([#24764](https://projects.theforeman.org/issues/24764), [6a2cd055](https://github.com/Katello/katello.git/commit/6a2cd0554d55cffc253632173701e1dbfb909f09))
 * add search parameter to registry repo discovery ([#24739](https://projects.theforeman.org/issues/24739), [0ea297b7](https://github.com/Katello/katello.git/commit/0ea297b7dcb6ca5e4fd14e7ecf72b2d20588007b))
 * [Sat6.4] Filter to list RPM repos on new Red Hat Repositories page should not list Beta repos ([#24680](https://projects.theforeman.org/issues/24680), [fb6c539d](https://github.com/Katello/katello.git/commit/fb6c539d499c414cfb3f1ac3d41c7942748e429b))
 * [Sat6.4] Sorting of available minor version repositories is not consistent on new Red Hat Repositories page ([#24679](https://projects.theforeman.org/issues/24679), [42526237](https://github.com/Katello/katello.git/commit/4252623713f7554f391b5f8545a97037aa9cd552))
 * pulp-2.17 new container image json ([#24603](https://projects.theforeman.org/issues/24603), [fc4dc04b](https://github.com/Katello/katello.git/commit/fc4dc04b5be4d1ae1618fca1e609a24410d276d7))
 * Save bookmark on container image manifests errors ([#24538](https://projects.theforeman.org/issues/24538), [8974b8e5](https://github.com/Katello/katello.git/commit/8974b8e5a6ca7d0f4644362f79c1efd06a98080b))
 * Pulp will fail in a dynflow action and the action will still pass. ([#24534](https://projects.theforeman.org/issues/24534), [81db0bd5](https://github.com/Katello/katello.git/commit/81db0bd58e66e93075f7c6f61824b0f0f8d08257))
 * Rearrange search/filter options  on Red Hat Repositories page. ([#24518](https://projects.theforeman.org/issues/24518), [eb12c6e6](https://github.com/Katello/katello.git/commit/eb12c6e64e7fc9ce6211d22128d57fd2d138b4c9))
 * Add UI for docker tags whitelist repo sync ([#24512](https://projects.theforeman.org/issues/24512), [eaa34f75](https://github.com/Katello/katello.git/commit/eaa34f75954c12381600a285529370aa994b5a2c))
 * [sat64] Next/Previous page option should also be available at the bottom of the Red Hat Repositories page ([#24485](https://projects.theforeman.org/issues/24485), [9bbae121](https://github.com/Katello/katello.git/commit/9bbae12183b0a6f830d204398d27bbad18250ee3))
 * ActiveRecord::UnknownAttributeError: unknown attribute 'sourcerpm' for Katello::Srpm. ([#24334](https://projects.theforeman.org/issues/24334), [cbd6775e](https://github.com/Katello/katello.git/commit/cbd6775e335128b6305c38fd57cd4001ff10cc55))
 * repository description ui should be text area ([#24319](https://projects.theforeman.org/issues/24319), [911dbe1e](https://github.com/Katello/katello.git/commit/911dbe1e0bad9c918362d8d86830f1a2c7711cab))
 * Count of enabled repos not updated when repo enabled ([#24314](https://projects.theforeman.org/issues/24314), [8b110f85](https://github.com/Katello/katello.git/commit/8b110f85491a7ea8aba2d5429e8b5f2dbfec0099))
 * katello allows setting invalid repo settings that pulp does not accept ([#24115](https://projects.theforeman.org/issues/24115), [81db0bd5](https://github.com/Katello/katello.git/commit/81db0bd58e66e93075f7c6f61824b0f0f8d08257))
 * add docker tags whitelist to use during repo sync ([#24051](https://projects.theforeman.org/issues/24051), [3bd78a98](https://github.com/Katello/katello.git/commit/3bd78a98c2210fcf4b07dbffd90a3d0388217770), [8316b08f](https://github.com/Katello/hammer-cli-katello.git/commit/8316b08fec620d956fb23357b8c91b596098affa))
 * repo discovery page product selection not working ([#16894](https://projects.theforeman.org/issues/16894))

### GPG Keys
 * Unable to create Content Credential bookmark via WebUI ([#25219](https://projects.theforeman.org/issues/25219), [ec27b285](https://github.com/Katello/katello.git/commit/ec27b28548dfe5da8999bc3c7e5fbeedfaf9fad1))

### API
 * computed_ostree_upstream_sync_depth missing from repository API ([#25212](https://projects.theforeman.org/issues/25212), [39d83ea9](https://github.com/Katello/katello.git/commit/39d83ea91dad4fd565330724ed6fe58bb2c9f21f), [82d9acec](https://github.com/Katello/katello.git/commit/82d9aceca07aa218f6deefff7df74b0ee4b87ff6))
 * Some default sorts with scoped_search are broken ([#25196](https://projects.theforeman.org/issues/25196), [ae2d01b4](https://github.com/Katello/katello.git/commit/ae2d01b470ad101e25516b919fd53f35626b3421))
 * hammer -r gives syntax error in katello api ([#23303](https://projects.theforeman.org/issues/23303))

### Sync Plans
 * hammer tabular output of sync-plan fails with undefined method `start_at` ([#25200](https://projects.theforeman.org/issues/25200), [62813250](https://github.com/Katello/katello.git/commit/6281325043ab0f9dba3782522e9a04c48c9074b3))
 * [Sync-Plans] Clear cron expression when interval is not custom cron ([#24901](https://projects.theforeman.org/issues/24901), [8ac17807](https://github.com/Katello/katello.git/commit/8ac17807def695834c80170e8af836a82744325b))
 * [Sync-plans] Sync plans created with start date in the past schedule a lot of dynflow tasks. ([#24733](https://projects.theforeman.org/issues/24733))
 * [Sync-plans] Remove dead code ([#24671](https://projects.theforeman.org/issues/24671), [a9ef90dd](https://github.com/Katello/katello.git/commit/a9ef90dd3e57295fe19e66e8601a4ff6fd1d23e8))
 * Sync Plan Date incorrectly set in Timezone ([#24519](https://projects.theforeman.org/issues/24519), [d79fcbc5](https://github.com/Katello/katello.git/commit/d79fcbc5460887b894dc24347e693615197ddaac))
 * Add an upgrade rake task for sync plans ([#24083](https://projects.theforeman.org/issues/24083), [e32ee2f2](https://github.com/Katello/katello.git/commit/e32ee2f210a23f41f2dd75694ad527f835744e59))
 * Migrate sync plans to recurring logics ([#23928](https://projects.theforeman.org/issues/23928), [977d1c6e](https://github.com/Katello/katello.git/commit/977d1c6e3109b43e123714856a9d3ad2a6a0cb96))

### Errata Management
 * error when viewing host errata the field 'updated_at' in the order statement is not valid field for search ([#25194](https://projects.theforeman.org/issues/25194), [8451f0fd](https://github.com/Katello/katello.git/commit/8451f0fdf23df47f857128dec6fbff47415204ae))

### Security
 * XSS on Subscription/Repositories pages ([#25182](https://projects.theforeman.org/issues/25182), [17451c95](https://github.com/Katello/katello.git/commit/17451c950201bedec9bdd3748e17863b550a6be2))

### Web UI
 * productDelete function not called on product delete ([#25148](https://projects.theforeman.org/issues/25148), [81eae680](https://github.com/Katello/katello.git/commit/81eae68084b48cc8c37bf64e34813be3c5d2bae9))
 * Host details status icons missing ([#25147](https://projects.theforeman.org/issues/25147), [76ebe36b](https://github.com/Katello/katello.git/commit/76ebe36b44798f6f14d9f9ca408fd0cc1c7382c7))
 * Fix Notification.setSuccessMessage call with link ([#25146](https://projects.theforeman.org/issues/25146), [5e82990c](https://github.com/Katello/katello.git/commit/5e82990c5f7353787077be1fcd87934f9d9e5124))
 * use i18n from webpack ([#25135](https://projects.theforeman.org/issues/25135), [c459959e](https://github.com/Katello/katello.git/commit/c459959e410dafde33689abf000fb24dd50fb3b0))
 * New Repositories page needs a clear option for the search bar. ([#25049](https://projects.theforeman.org/issues/25049), [107f4ed2](https://github.com/Katello/katello.git/commit/107f4ed2b2b12b9a8c41429abf011c8c3105334b))
 * update react to 16.4  ([#24926](https://projects.theforeman.org/issues/24926), [91ce9378](https://github.com/Katello/katello.git/commit/91ce9378b312cd0697f781dcc075be01fe6dc5c2))
 * Fix prop-types warning about noneSelectedText in move_to_pf/react-bootstrap-select/index.js ([#24542](https://projects.theforeman.org/issues/24542), [5d725d8e](https://github.com/Katello/katello.git/commit/5d725d8e62f90d3f6708aaec8f19ef7b4fd6f849))
 * Empty <title> on Subscriptions & Red Hat Repositories pages ([#24515](https://projects.theforeman.org/issues/24515), [bc7a371a](https://github.com/Katello/katello.git/commit/bc7a371aa24d2842a0ca0c8c4cd725fb7fd001be))
 * Subscription delete manifest button should be marked as `danger` ([#24398](https://projects.theforeman.org/issues/24398), [92e8b889](https://github.com/Katello/katello.git/commit/92e8b8897e11a77f17be1f89d1ed0db2ad5a29be))
 * "20" is default pagination for Subscriptions, but cannot actually be re-selected ([#24311](https://projects.theforeman.org/issues/24311), [9272e73e](https://github.com/Katello/katello.git/commit/9272e73e539b605af3d9991bf21c22e83cb35b49))
 * Documentation link on Content Host Registration page should use documentation helper ([#24218](https://projects.theforeman.org/issues/24218))

### Hammer
 * Hammer command with content view version --order is not working as expected. ([#25145](https://projects.theforeman.org/issues/25145), [4d473ada](https://github.com/Katello/katello.git/commit/4d473adaea7d100a73226a61bd44de8e751a63b2))
 * Filtering of some entities does not work ([#25027](https://projects.theforeman.org/issues/25027), [1c91b78e](https://github.com/Katello/hammer-cli-katello.git/commit/1c91b78e16c28f4064ef68e8cb7401fbcb549def))
 * [Sync Plan] Hammer cli support for custom cron expressions ([#24894](https://projects.theforeman.org/issues/24894), [3ca2ddab](https://github.com/Katello/hammer-cli-katello.git/commit/3ca2ddab8dae6923cffac265ea5b0c27396e18cd))
 * hammer-cli-katello bump master to 0.15.0 ([#24747](https://projects.theforeman.org/issues/24747), [ec6b5704](https://github.com/Katello/hammer-cli-katello.git/commit/ec6b5704df75f975f92d660629d2505ad1f6e72d))
 * search_options_with_katello_api doesn't support plural resolution ([#24582](https://projects.theforeman.org/issues/24582), [df49f3bf](https://github.com/Katello/hammer-cli-katello.git/commit/df49f3bf1ea7ad4b8056a49b29c9c3476a84e0bc))

### Content Views
 * composite_content_view_ids field of a content_view_version is always empty ([#25143](https://projects.theforeman.org/issues/25143), [cd99f28a](https://github.com/Katello/katello.git/commit/cd99f28a3270995ce607403b27f39124cc49d058))
 * Content view version API should include library_instance_id in repositories ([#25132](https://projects.theforeman.org/issues/25132), [72786f38](https://github.com/Katello/katello.git/commit/72786f3869148e39468cf7216d2041d451605b81))
 * Content View version packages  page shows ostree repos in its repositories drop down ([#24971](https://projects.theforeman.org/issues/24971), [d4d332c3](https://github.com/Katello/katello.git/commit/d4d332c3da32f1d6c386bf99ebef8c55ab267888))
 * Content View version packages page magically appending "All Repositories" ([#24970](https://projects.theforeman.org/issues/24970), [d9d7fb83](https://github.com/Katello/katello.git/commit/d9d7fb83d0a388ed4bc49cd111e3d70c83d47be9))
 * Validation failed: Cannot set auto publish to a non-composite content view ([#24937](https://projects.theforeman.org/issues/24937), [a8c4bb71](https://github.com/Katello/katello.git/commit/a8c4bb713f8bbf933285c7ed81e5793d6f019f8b))
 * Forcing content view version repository regeneration does not actually regenerate some repositories ([#24841](https://projects.theforeman.org/issues/24841), [c2194967](https://github.com/Katello/katello.git/commit/c2194967d34aee59ced6bc25918f8e9d9e198d87))
 * Per-page setting does not work in RPM and repo listings ([#24554](https://projects.theforeman.org/issues/24554), [262f43a4](https://github.com/Katello/bastion.git/commit/262f43a4998f25704a650bb34fb19b10a00cc3c2))
 * GET content_view_filter_rules index API default search is set to :name, this doesnt work for errata rules ([#24137](https://projects.theforeman.org/issues/24137), [026dbf73](https://github.com/Katello/katello.git/commit/026dbf73a674ca99228a138b7d8e0fae8201ede9))

### Modularity
 * Module Stream Search on Content Host page gives an error on wrong/blank search ([#25116](https://projects.theforeman.org/issues/25116))

### Subscriptions
 * /api/settings/content_disconnected gives 403 without pointing out which permission is required ([#25105](https://projects.theforeman.org/issues/25105))
 * Subscription Details switcher items are not filtered by organization ([#24822](https://projects.theforeman.org/issues/24822), [a338ebf4](https://github.com/Katello/katello.git/commit/a338ebf46bb5ffe38ba0ee8e7e0084a64d289f52), [7801dad4](https://github.com/Katello/katello.git/commit/7801dad4618a10a17655b84079ce8f1a6b32f590))
 * Missing value in product details causes values to not align to their labels ([#24810](https://projects.theforeman.org/issues/24810), [75e26d47](https://github.com/Katello/katello.git/commit/75e26d47f35a4dec8ba92124e36f8a2969c36cfd))
 * Two meanings of "Enabled" on new Subscription tab might cause confusion ([#24809](https://projects.theforeman.org/issues/24809), [b9ae916d](https://github.com/Katello/katello.git/commit/b9ae916d438f81bdf1d2805cc68d40d2eb168387))
 * Guest of hypervisor shows "Undefined" on subscriptions page ([#24681](https://projects.theforeman.org/issues/24681))
 * No menu entry for Content -> Subscriptions for user with Viewer role ([#24677](https://projects.theforeman.org/issues/24677), [1ead23c5](https://github.com/Katello/katello.git/commit/1ead23c56999fd24b1147c2d2d825cba7a151b01))
 * accessing subscription.rhn.redhat.com unexpectedly ([#24675](https://projects.theforeman.org/issues/24675), [d888a711](https://github.com/Katello/katello.git/commit/d888a7116702ad600d4a5a2e31007a9846048864))
 * Subscription page not showing Guest/Virtual subscriptions details as "Guest of" ([#24617](https://projects.theforeman.org/issues/24617), [c053f882](https://github.com/Katello/katello.git/commit/c053f882b6b733b4f14fd0e05c0e707f585ab0c7))
 * Unhelpful error messages when manifest can't be found upstream ([#24535](https://projects.theforeman.org/issues/24535), [1f88926d](https://github.com/Katello/katello.git/commit/1f88926d5598b765ead21429cb1b240be76e0caf))
 * Using the Mast Head Org Switcher and the in page Organization Selection dropdown produces unpredictable results ([#24480](https://projects.theforeman.org/issues/24480), [0d987237](https://github.com/Katello/katello.git/commit/0d987237d09f28042b367af75dfe351337bde624))
 * Upgrade from 6.3 to 6.4 failed at Upgrade Step: set_upstream_pool_id ([#24436](https://projects.theforeman.org/issues/24436), [327c3a34](https://github.com/Katello/katello.git/commit/327c3a349778a1159c18b8e483179936a21745cd))
 * New RH Subscriptions page allows deleting of custom subs ([#24221](https://projects.theforeman.org/issues/24221), [0c77a55e](https://github.com/Katello/katello.git/commit/0c77a55ee7e50a098b772d3bc4f205c5ad75e0e8))
 * Manifest upload UI status bleeds into other orgs ([#24126](https://projects.theforeman.org/issues/24126), [dc7b4c78](https://github.com/Katello/katello.git/commit/dc7b4c78a05c7bda35f0b3496e2da5423b904091))
 * processing virt-who report blocks RHSM certs checks what can lead to 503 errors ([#23995](https://projects.theforeman.org/issues/23995), [e0d2c879](https://github.com/Katello/katello.git/commit/e0d2c8790718e5aaf366a76b33ee446c06999bde))

### Hosts
 * "Manage Repository Sets" option for content hosts list all available repos and search is broken on this page ([#25033](https://projects.theforeman.org/issues/25033), [f4cb0627](https://github.com/Katello/katello.git/commit/f4cb062795543fe783af01075be506dd8fe23199))
 * generateapplicability should ignore 404s from pulp ([#25003](https://projects.theforeman.org/issues/25003), [85ebdad4](https://github.com/Katello/katello.git/commit/85ebdad46e83d25819ff797c41fa069219b99a27))
 * host add subscription page not showing subscriptions ([#24999](https://projects.theforeman.org/issues/24999), [1ec2aed1](https://github.com/Katello/katello.git/commit/1ec2aed110c068b94b5302afea8f8f8c56c4f302))
 * [Satellite 6.3]Content Host does not display IP information on Sat GUI ([#24507](https://projects.theforeman.org/issues/24507), [e2b261b6](https://github.com/Katello/katello.git/commit/e2b261b628a363b5e3ddc90016e3a994176813db))
 * Can not set release version of a content host as non-administrative user ([#24395](https://projects.theforeman.org/issues/24395), [5c41cef2](https://github.com/Katello/katello.git/commit/5c41cef25ace9d88972f3873ad24bc94539e1020))
 * clean_backend_objects batch size can cause issues on slower systems ([#24333](https://projects.theforeman.org/issues/24333), [9b1a513a](https://github.com/Katello/katello.git/commit/9b1a513a726fa385525ff2f81e44dfd68cb06e8a))

### Candlepin
 * Candlepin throws 500 Internal Server Error for more than 40+ guests ([#25026](https://projects.theforeman.org/issues/25026), [b0a370d0](https://github.com/Katello/katello.git/commit/b0a370d0066c133fd242fde09a1d22e6678b3f0a))

### Docker
 * disable docker v2 api for container image push ([#25023](https://projects.theforeman.org/issues/25023), [6ab4412f](https://github.com/Katello/katello.git/commit/6ab4412f8a6351478688ca2233b0b82c089acaed))
 * allow any length passwords for docker repositories ([#24382](https://projects.theforeman.org/issues/24382), [ed3fa059](https://github.com/Katello/katello.git/commit/ed3fa059efd5ba5d129d19e5afc3aad06c1b4667))
 * As a user, I want to find all container images without tags. ([#23507](https://projects.theforeman.org/issues/23507), [d369217b](https://github.com/Katello/katello.git/commit/d369217b8096ade04f671c9ef8f428ed37ff43c9))

### Tests
 * eslint is broken on master ([#24996](https://projects.theforeman.org/issues/24996), [9bd6dc8a](https://github.com/Katello/katello.git/commit/9bd6dc8ae110565120a7fd5eb5332d7f86bd5de8))
 * ERF42-1709 Must supply an entity to find a medium provider during template render validation ([#24975](https://projects.theforeman.org/issues/24975), [ec6d2b15](https://github.com/Katello/katello.git/commit/ec6d2b15430b2be55bd555896445e3bfd373f36d))
 * Add pulp 2.17 tests ([#24630](https://projects.theforeman.org/issues/24630), [48b7cecf](https://github.com/Katello/katello.git/commit/48b7cecf9e8da1a86642143f7de19e763acf7258))
 * npm run lint always exits with 0 ([#24597](https://projects.theforeman.org/issues/24597), [f5322438](https://github.com/Katello/katello.git/commit/f5322438f94ad87a475a9cacb0610dff44fdebcc))
 * Template rendering extensions are untested and broken ([#24549](https://projects.theforeman.org/issues/24549), [2d8841e1](https://github.com/Katello/katello.git/commit/2d8841e1819f178100bd1603bc3a5f488f4653be))

### Host Collections
 * Katello 3.4: Removing hypervisor from one host collection will remove hypervisor from all host collections ([#24905](https://projects.theforeman.org/issues/24905), [9207421d](https://github.com/Katello/katello.git/commit/9207421dcfaa271e31f08a27d0c765d498583b3b))

### Settings
 * Some default values not shown in Settings page tool tips ([#24868](https://projects.theforeman.org/issues/24868), [c897cee1](https://github.com/Katello/katello.git/commit/c897cee1a0be0a9bf8728a9bd80f81490ba6d04b))
 * Behavior of attributed_changed? inside callbacks will change in next rails version ([#24585](https://projects.theforeman.org/issues/24585), [f4d1738d](https://github.com/Katello/katello.git/commit/f4d1738d6247037f968d206e77850df4364b160e))

### Activation Key
 * Subscriptions tab links to /legacy_subscriptions/:id: ([#24839](https://projects.theforeman.org/issues/24839), [40570524](https://github.com/Katello/katello.git/commit/4057052478c6f52e10610f953c9e4ff86bfc662a))

### Tooling
 * Make Katello Ruby 2.5 compliant ([#24726](https://projects.theforeman.org/issues/24726), [38369680](https://github.com/Katello/katello.git/commit/38369680aa17cadec0b0aceeec9701f8844a4e4c))

### Provisioning
 * Fetch TFTP boot files for jan-vernier.example.org task failed with the following error: undefined method 'kickstart_repository' for #<Host::Managed:0xXXXXXXXXXXXXXXXX> ([#24709](https://projects.theforeman.org/issues/24709), [8f205ad6](https://github.com/Katello/katello.git/commit/8f205ad6e865ed4ecdd14154c20655f78a200b92), [a67a31a3](https://github.com/Katello/katello.git/commit/a67a31a3e6319ea6fefaea9296efc2563b0aa9b4))
 * Installation media and kickstart repository ID are not exclusive ([#24376](https://projects.theforeman.org/issues/24376), [46dd0ff9](https://github.com/Katello/katello.git/commit/46dd0ff97846ed8e15467b4ba832a712fa46ca75))

### Database
 * rake db:create fails to initialize with Katello with Rails 5.2 ([#24664](https://projects.theforeman.org/issues/24664), [78a7ee16](https://github.com/Katello/katello.git/commit/78a7ee16782210ceff5ca45615eb7f8a839e0b02))

### API doc
 * document /repository_sets API ([#24580](https://projects.theforeman.org/issues/24580), [33c8c329](https://github.com/Katello/katello.git/commit/33c8c329e268029674e5bb83c615a7e972ab737d))

### ElasticSearch
 * Improve MonitorEventQueue performance for large workloads ([#24576](https://projects.theforeman.org/issues/24576), [00954691](https://github.com/Katello/katello.git/commit/009546913c01fe3387743d5216338c0ef92ddff8))

### Backup & Restore
 * katello-change-hostname should check current hostname to make sure that the hostname was not changed with a different tool ([#24422](https://projects.theforeman.org/issues/24422))

### Documentation
 * Fix out of date references in our README ([#24327](https://projects.theforeman.org/issues/24327), [528d5250](https://github.com/Katello/katello.git/commit/528d525068d543d3dfd57db55d09a887309abe19))

### Other
 * DisownForemanTemplates db:migrate failing  ([#25344](https://projects.theforeman.org/issues/25344), [b8dabc3d](https://github.com/Katello/katello.git/commit/b8dabc3d681f9a903d0d53c87c07cf489859083b))
 * deprecate old export API ([#25183](https://projects.theforeman.org/issues/25183), [80297db4](https://github.com/Katello/katello.git/commit/80297db4b2cc02315d1ac0eacf1c68cad487ace9))
 * User filters on katello fields break fact values page ([#25174](https://projects.theforeman.org/issues/25174), [931c4dbe](https://github.com/Katello/katello.git/commit/931c4dbe95c8fdf052ff0728092814baaf8a35bc))
 * Regenerate VCR casettes after changing the defualt hashing algorithm ([#25080](https://projects.theforeman.org/issues/25080), [fbdd81b8](https://github.com/Katello/katello.git/commit/fbdd81b88997b6d6d3350617db71a107ea616fff))
 * do not send large bulk requests for consumers as part of virt-who check in ([#25060](https://projects.theforeman.org/issues/25060), [23a35efc](https://github.com/Katello/katello.git/commit/23a35efca6bb8b4fe6ac7c5974f74eac1623940b))
 * foreman dirs getting gitignored ([#25050](https://projects.theforeman.org/issues/25050), [872fc2ca](https://github.com/Katello/katello.git/commit/872fc2cafd7320fdc52f7b7161465c3e4ab63117))
 * Capsule upgrade failed at Upgrade Step: start_postgresql ([#25011](https://projects.theforeman.org/issues/25011), [885f3e98](https://github.com/Katello/katello-installer.git/commit/885f3e9835650a90bc7c8bc208772de59a0f8401))
 * Listing debian type reposin Browser is broken ([#24948](https://projects.theforeman.org/issues/24948), [7b4fc1c9](https://github.com/Katello/katello.git/commit/7b4fc1c9188c6180c5806ce1e2bc4986a57c044a))
 * adding unit test for invalid cron expression  ([#24890](https://projects.theforeman.org/issues/24890), [227fd40a](https://github.com/Katello/katello.git/commit/227fd40af82442300724b01df697952b4786f5f4))
 * [Sync-plans] Sync plan save button continues to be in working mode after error ([#24818](https://projects.theforeman.org/issues/24818), [da52ed77](https://github.com/Katello/katello.git/commit/da52ed770a560e1a7436cee7fe319f8a3ff11300))
 * requests to smart_proxies API never return 'download_policy' param ([#24813](https://projects.theforeman.org/issues/24813), [bf378d92](https://github.com/Katello/katello.git/commit/bf378d92d4b6e1c9a9ab04801d35178c3f6b1430))
 * audits - type: user not recognized for searching ([#24757](https://projects.theforeman.org/issues/24757), [458c5a51](https://github.com/Katello/katello.git/commit/458c5a514ede88071e5dae11cb5a43285d8a74d6))
 * Missing  reset_column_information after rebasing from rails_5.2 branch ([#24751](https://projects.theforeman.org/issues/24751), [84d9f889](https://github.com/Katello/katello.git/commit/84d9f88901cda6460eb444163e8a247281631443))
 * Hostgroups should use AssociationExistsValidator for content_source ([#24559](https://projects.theforeman.org/issues/24559), [e8f2e13b](https://github.com/Katello/katello.git/commit/e8f2e13bed00a4395b47f2d3e9eb6b7aa0bab2aa))
 * Add test coverage for authorization sync plan ([#24533](https://projects.theforeman.org/issues/24533), [ce605682](https://github.com/Katello/katello.git/commit/ce605682f4f6b18bf4ba494f42a4b5773e2c3f16))
 * Content Source resource_name is smart_proxy, which is confusing to users ([#24528](https://projects.theforeman.org/issues/24528))
 * React pages don't include Rails url_helpers ([#24513](https://projects.theforeman.org/issues/24513), [d271e608](https://github.com/Katello/katello.git/commit/d271e6083db481cac2671460ef2834d2e4190d47))
 * Synchronizing CentOS repo fails with argument error ([#24502](https://projects.theforeman.org/issues/24502), [27d5de24](https://github.com/Katello/katello.git/commit/27d5de2493bfab921c3bf2060ea8f2fcfb364561))
 * PUT requests content is logged in info level ([#24370](https://projects.theforeman.org/issues/24370))
 * RFE: Need to set proper filename in  Subscription Export CSV response ([#24339](https://projects.theforeman.org/issues/24339), [b9505e4e](https://github.com/Katello/katello.git/commit/b9505e4e07387862288a5b58a69f0269d71461f9))
 * Smart proxy missing GPG key (ProxyPass missing) ([#24316](https://projects.theforeman.org/issues/24316), [7389e5b4](https://github.com/theforeman/puppet-foreman_proxy_content/commit/7389e5b4e3529fb62e89644e6f8f753ee1bf98c7))
 * patternly bindMethods is deprecated  ([#24283](https://projects.theforeman.org/issues/24283), [d23e07c5](https://github.com/Katello/katello.git/commit/d23e07c5822cd60b7d1790f76fefd49fce4a6253))
 * Create managed content medium provider ([#24263](https://projects.theforeman.org/issues/24263), [d9c0492a](https://github.com/Katello/katello.git/commit/d9c0492a01c9f4e6bca0a93c7540a6575f716b8c))
