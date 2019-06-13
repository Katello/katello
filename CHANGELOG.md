# 3.10.2 Belgian Tripel (2019-06-13)

## Bug Fixes

### Hosts
 * Foreman/Katello node.rb Issue with Puppet 6 ([#26763](https://projects.theforeman.org/issues/26763), [e2cbcd5b](https://github.com/Katello/katello.git/commit/e2cbcd5be621c2fe588119a33096367beb164d0d))

### Other
 * Unable to retrieve gpg_keys through smart proxy ([#25823](https://projects.theforeman.org/issues/25823), [81f1a08b](https://github.com/Katello/katello.git/commit/81f1a08b907fa4b2ae6e743cadb7d459b0813b42))
# 3.10.1 Belgian Tripel (2019-04-17)

## Bug Fixes

### Content Views
 * Content View Version - ostree branch - generates error ([#26514](https://projects.theforeman.org/issues/26514), [9b4e10eb](https://github.com/Katello/katello.git/commit/9b4e10eb4e3fe88d662de54781cc683a17d40f60))

### OSTree
 * Syncing Red Hat Enterprise Linux Atomic Host Trees x86_64 from CDN gives undefined method `to_datetime' for nil:NilClass ([#26447](https://projects.theforeman.org/issues/26447), [cb71d1d9](https://github.com/Katello/hammer-cli-katello.git/commit/cb71d1d936ab345b715101f415e9c5abf5fd03b8), [e53d750f](https://github.com/Katello/katello.git/commit/e53d750fc691b2e63beef202c5e3749ab84fc616))

### Repositories
 * refresh repos should track async tasks ([#26005](https://projects.theforeman.org/issues/26005), [0f394f21](https://github.com/Katello/katello.git/commit/0f394f213503e7ece3857c564ea30296a3bea93e))
 * source-url is not honored when syncing repos ([#25737](https://projects.theforeman.org/issues/25737), [6aaa50fb](https://github.com/Katello/katello.git/commit/6aaa50fb9755133c0baf790f77ea900271455d01))
 * Syncing puppet repo gives Error: PLP0034: The distributor indicated a failed response when publishing repository ([#25729](https://projects.theforeman.org/issues/25729), [ce530681](https://github.com/Katello/katello.git/commit/ce530681401bbb388640d0c402f3fc4f02742eb0), [c2b76683](https://github.com/Katello/katello.git/commit/c2b766835d36cc05614864c37073ae852ebf01e0))
 * Should expose suse client repos via http ([#25667](https://projects.theforeman.org/issues/25667), [768446a0](https://github.com/Katello/katello.git/commit/768446a055f94fbe5081be15dc15655bbb8b8744), [269d516c](https://github.com/Katello/katello.git/commit/269d516ced4adc230e67147b7c2a86cea46a2e0e))
 * Upgrade step katello:upgrades:3.8:clear_checksum_type from 6.4 to 6.5 failed ([#25597](https://projects.theforeman.org/issues/25597), [899a61ce](https://github.com/Katello/katello.git/commit/899a61ce7439449b65e6cb3e89ed387e039dd25b))

### Subscriptions
 * scan_cdn task failed while enabling red hat repositories from cdn ([#25996](https://projects.theforeman.org/issues/25996), [3e7e1658](https://github.com/Katello/katello.git/commit/3e7e1658bbde267bed2623d42848e43965aabcdb))
 * org delete sometimes fails on product/destroy.rb ([#25711](https://projects.theforeman.org/issues/25711), [e254baba](https://github.com/Katello/katello.git/commit/e254baba718bf1dbfd71178b03ae096719898357))
 * view_subscription filter does not allow subscriptions to be viewed ([#25699](https://projects.theforeman.org/issues/25699), [bc33b8d4](https://github.com/Katello/katello.git/commit/bc33b8d447841d944e3c24209e60b914378da83f))
 * Missing consumed and entitlements columns at subscriptions page ([#25574](https://projects.theforeman.org/issues/25574), [6e18d3d1](https://github.com/Katello/katello.git/commit/6e18d3d1c9e054468fa785752ec66861a6a24d39))
 * Subscription details doesn't show in web UI ([#25573](https://projects.theforeman.org/issues/25573))
 * Subscription detail page is empty ([#25515](https://projects.theforeman.org/issues/25515), [1ecd066b](https://github.com/Katello/katello.git/commit/1ecd066b7edab6db5903a1cfa282685130c43203))

### Foreman Proxy Content
 * Capsule sync failed with undefined method `backend_service' for nil:NilClass after upgrade ([#25954](https://projects.theforeman.org/issues/25954), [c3de1231](https://github.com/Katello/katello.git/commit/c3de1231755190bdd346808f0d6420bcc4f7f8f5))
 * syncing a content view puppet environment to a smart proxy fails a refresh step ([#25830](https://projects.theforeman.org/issues/25830))

### Provisioning
 * undefined method `content_facet' for #<Hostgroup:0x00007f1fb2583b98> ([#25753](https://projects.theforeman.org/issues/25753), [5f581e95](https://github.com/Katello/katello.git/commit/5f581e9525027af47564d3558c54676dcb2b681b))

### Hammer
 * [Sync Plan] - Hammer Sync-Plan info does not show foreman_tasks_recurring_logic_id ([#25728](https://projects.theforeman.org/issues/25728), [d8db9a6c](https://github.com/Katello/hammer-cli-katello.git/commit/d8db9a6c690ce94a58ecd3f1539c63e74a7aeecf))

### Client/Agent
 * disable host-tools plugins where subman supports combined profile ([#25725](https://projects.theforeman.org/issues/25725), [1614be4c](https://github.com/Katello/katello-host-tools.git/commit/1614be4c645f927cc689aa54785f52181ab0ed95))

### Sync Plans
 * [Product]- Sync Plan Interval and timing is shown incorrectly in Product Details Page If Sync Interval is Custom Cron ([#25687](https://projects.theforeman.org/issues/25687), [5b5dfee7](https://github.com/Katello/katello.git/commit/5b5dfee71d1b54e217b0075f0dbc6c06dde5494c))
 * organization changed from Default org to [object Object] on sync status page in satellite WebUI. ([#25632](https://projects.theforeman.org/issues/25632))

### Inter Server Sync
 * [RFE] The CV exported tar should have name respective to Content View name ([#25682](https://projects.theforeman.org/issues/25682), [e42198e3](https://github.com/Katello/hammer-cli-katello.git/commit/e42198e3578ea1527f219ab66ce9363a38f5d56a))
 * Reimporting the existing CV version should have more refined validation message ([#25406](https://projects.theforeman.org/issues/25406), [a633c90b](https://github.com/Katello/katello.git/commit/a633c90b93638c11e3e65358a64a1ca7bff7b700))

### Modularity
 * UUID error on syncing repo with  module errata  ([#25676](https://projects.theforeman.org/issues/25676), [b3e38874](https://github.com/Katello/katello.git/commit/b3e388743286b320111f97487d7ad07cdb35c49f))

### Installer
 * upgrade-mongo-storage-engine is not restoring database ([#25634](https://projects.theforeman.org/issues/25634), [8879ed3d](https://github.com/Katello/katello-installer.git/commit/8879ed3d08f9673112a96e364a7ac5f188a495c7))

### Hosts
 * [Module Streams] - "Filter by Status:" is not working if user tried to use pagination ([#25627](https://projects.theforeman.org/issues/25627), [d64e347a](https://github.com/Katello/katello.git/commit/d64e347a82a9ac8ec2ad868590e8f5759ff87d7f))

### Docker
 * Docker repositories sync - Limit Sync Tags is ignored ([#25615](https://projects.theforeman.org/issues/25615), [bce600ed](https://github.com/Katello/katello.git/commit/bce600ed6c28acb0a9a279ed1d1ecbab3d869cac))

### Activation Key
 * Activation key search is broken ([#25599](https://projects.theforeman.org/issues/25599), [51044123](https://github.com/Katello/katello.git/commit/5104412333617709815ec814cabdc51c5df94f1e))

### Web UI
 * blank page on navigating from foreman to katello page ([#25572](https://projects.theforeman.org/issues/25572))

### API
 * switch to scoped_search based sorting ([#23512](https://projects.theforeman.org/issues/23512))

### Other
 * Error When Creating or Editing Host Group With Operating System ([#25917](https://projects.theforeman.org/issues/25917), [ee4dbaba](https://github.com/Katello/katello.git/commit/ee4dbaba78a3bc410eb7a83103b2b2a889d24e2f))
 * 3.10 repo points to rc packages and beta pulp repo ([#25859](https://projects.theforeman.org/issues/25859))
 * Restore DNF tracer plugin in host tools ([#25587](https://projects.theforeman.org/issues/25587), [8c1ebfbd](https://github.com/Katello/katello-host-tools.git/commit/8c1ebfbd54d660843a2d533bed29fcaa5e5c5adf))


# 3.10.0 Belgian Tripel (2018-12-14)

## Features

### Hammer
 * Add command to recalculate errata for a host ([#25404](https://projects.theforeman.org/issues/25404), [1136d549](https://github.com/Katello/hammer-cli-katello.git/commit/1136d549365f94952215fff07b997b4de0b42497))

### Modularity
 * As a user I  would like to see Upgradable Module Streams for a Content Host ([#25345](https://projects.theforeman.org/issues/25345), [b378a5cd](https://github.com/Katello/katello.git/commit/b378a5cdba570b8096eabba7c84705bc8dfad325))
 * As a user I would like to enable specific modules on my content host via remote execution -(client bit) ([#24432](https://projects.theforeman.org/issues/24432))

### Repositories
 * As a user i want to configure mirror_on_sync for debian repositories ([#25283](https://projects.theforeman.org/issues/25283), [165ba75e](https://github.com/Katello/katello.git/commit/165ba75efb95b437f6670d72a0ef312fc6a49e92))
 * Debian repository signature-verification ([#24105](https://projects.theforeman.org/issues/24105), [a0e0f89c](https://github.com/Katello/katello.git/commit/a0e0f89c18fe3e9a424b20f616ca682d2661353e))

### Content Views
 * Include deb packages into incremental content_view_version updates ([#24727](https://projects.theforeman.org/issues/24727), [d72c825c](https://github.com/Katello/katello.git/commit/d72c825c93e586112aa9f586123a4b9e58e92d3f))

### Tests
 * Port robottelo tests - repository ([#23910](https://projects.theforeman.org/issues/23910), [473fd3d2](https://github.com/Katello/katello.git/commit/473fd3d28de278e422b8cda19f9bf4fe5e1a13be))

## Bug Fixes

### GPG Keys
 * Content credential repo page is broken ([#25660](https://projects.theforeman.org/issues/25660), [6eee848d](https://github.com/Katello/katello.git/commit/6eee848da3774cd12cfb0441bab77bd307094efb))
 * Cannot update GPG Key on created product ([#25412](https://projects.theforeman.org/issues/25412), [5e75a9be](https://github.com/Katello/katello.git/commit/5e75a9beba47ada5e7927c6cc57cd47c6aeb128c))

### Sync Plans
 * Upgrade step katello:upgrades:3.9:migrate_sync_plans failed while 6.4 to 6.5 upgrade ([#25639](https://projects.theforeman.org/issues/25639), [2281d911](https://github.com/Katello/katello.git/commit/2281d9112315fee5e0244b13a514899a6979c5c1))

### Activation Key
 * [6.4]After unregistering hypervisor, unable to view subscriptions on activation key via Satellite WebUI ([#25604](https://projects.theforeman.org/issues/25604), [8e2ebe8d](https://github.com/Katello/katello.git/commit/8e2ebe8dd4a33da89966f339527c92c692293d07))

### Repositories
 * [Container Admin Feature] Failed promotion of CV with containers - error message is unhelpful ([#25558](https://projects.theforeman.org/issues/25558), [095a0374](https://github.com/Katello/katello.git/commit/095a037426567991e4fcd9bc9a73a18b4b8e72ba))
 * Upgrades can fail when repo has username but not password set (or vice versa) ([#25518](https://projects.theforeman.org/issues/25518), [34d3d132](https://github.com/Katello/katello.git/commit/34d3d132752f7c7c53795b0ed7e85337dcad4e42))
 * Updating a repo causes Actions::Pulp::Repository::Refresh to fail with Couldn't find SmartProxy without an ID ([#25475](https://projects.theforeman.org/issues/25475), [569c0f3f](https://github.com/Katello/katello.git/commit/569c0f3f47fd3018190ca941a5f7f35616e0d7bd))
 * "source_url" on repo sync is not passed to Pulp ([#25318](https://projects.theforeman.org/issues/25318), [62eeb306](https://github.com/Katello/katello.git/commit/62eeb306c7de10579e9f4b12fc127c77d1d52fd4))
 * FIPS Scheduled synchronization task ends with PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_katello_repository_rpms_on_rpm_id_and_repository_id" ([#24732](https://projects.theforeman.org/issues/24732))
 * Search and enable new repo on Red Hat Repositories page is tedious task ([#24550](https://projects.theforeman.org/issues/24550), [a7eebfff](https://github.com/Katello/katello.git/commit/a7eebfff9ec35c8070b5f6c342cf09b94ea9e90f), [ed80ad41](https://github.com/Katello/katello.git/commit/ed80ad419d5cbb522a6c88f091577f182e8ec21a), [9f114b7d](https://github.com/Katello/katello.git/commit/9f114b7df56295afafbc0a1136adbc9d7eae2ba3))

### Installer
 * Puppet report for installer not generated due to  "Invalid byte sequence in US-ASCII" ([#25516](https://projects.theforeman.org/issues/25516), [2a02cf64](https://github.com/Katello/katello-installer.git/commit/2a02cf645be7676a0be43e1fe5f870aae944516d))
 * /etc/rhsm/rhsm.conf is being incorrectly edited during registration ([#25512](https://projects.theforeman.org/issues/25512), [8c7254c5](https://github.com/theforeman/puppet-certs/commit/8c7254c58e023336fbbc45684a0c8dbfeef5f8da))
 * Pulp_max_tasks_per_child is disabled in capsule but not in satellite ([#25511](https://projects.theforeman.org/issues/25511), [3245fc39](https://github.com/theforeman/puppet-katello/commit/3245fc396d0e14fa5994e1490de9610d5846cada))
 * installer should not set pulp's redirect_host to $::fqdn ([#25266](https://projects.theforeman.org/issues/25266), [31932471](https://github.com/theforeman/puppet-pulp/commit/31932471ef4a9fe1cdc53fdd57e6d1cbd011afc4))

### Subscriptions
 * traceback when deleting organization: javax.persistence.RollbackException: Error while committing the transaction ([#25509](https://projects.theforeman.org/issues/25509), [2627a190](https://github.com/Katello/katello.git/commit/2627a1901712335276121892ccd2d9bb48a6e36b))

### Lifecycle Environments
 * "An error occurred saving the Environment: undefined method `custom_content_path' for #<Katello::Repository:0x00007ff94525c6f0> Did you mean? custom_repo_path" when updating Registry Name Pattern for Library ([#25410](https://projects.theforeman.org/issues/25410), [cff302e4](https://github.com/Katello/katello.git/commit/cff302e43a05562053337ea95dfd0052a8b4cee3))

### Candlepin
 * Katello::Resources::Candlepin::Consumer.get not always returns HashWithIndifferentAccess ([#25407](https://projects.theforeman.org/issues/25407), [8d3cad2f](https://github.com/Katello/katello.git/commit/8d3cad2f6ac393fff27f094972276405c8a0708f), [1c21a097](https://github.com/Katello/katello.git/commit/1c21a0975f77d11cbc1fdb26e93dd5627f878e1d))
 * Upgrade fromis failing on foreman-rake katello:import_subscriptions ([#25287](https://projects.theforeman.org/issues/25287), [45d437d5](https://github.com/Katello/katello.git/commit/45d437d5de9636c0887bd1c12b4e080af44c4688))

### Content Views
 * remove force_yum_metadata_regeneration method ([#25400](https://projects.theforeman.org/issues/25400), [fafaf3bb](https://github.com/Katello/katello.git/commit/fafaf3bbebcd4c5204a99f2c9163b00955faff93))
 * Show filter rule info API displays information for another CV filter ([#25348](https://projects.theforeman.org/issues/25348), [20b88e03](https://github.com/Katello/katello.git/commit/20b88e031bea0141e1a7455b8f77e6d2a630388b))
 * When deleting content views, UI indicates wrong number of environments ([#25321](https://projects.theforeman.org/issues/25321), [07bd127b](https://github.com/Katello/katello.git/commit/07bd127bdd38d85d9bbee272e67a4227b79f004d))
 * "the field 'created_at' in the order statement is not valid field for search" on content view history tab ([#25231](https://projects.theforeman.org/issues/25231), [5aedfccc](https://github.com/Katello/katello.git/commit/5aedfcccd2b54ca85d12aafbd78f48c8916e8690))

### Tests
 * Test failure ActiveRecord::RecordNotFound: Couldn't find SmartProxy without an ID ([#25392](https://projects.theforeman.org/issues/25392), [b320ee90](https://github.com/Katello/katello.git/commit/b320ee906ff42bef263b563158ecbf39784c9899))
 * intermittent failing test in activation_key_test.rb and debvcr ([#25360](https://projects.theforeman.org/issues/25360), [cee70cb9](https://github.com/Katello/katello.git/commit/cee70cb95d7a41172b1477bc1416c427f512d9b4))
 * transient vcr error around DebTest  ([#25353](https://projects.theforeman.org/issues/25353), [a09a7d88](https://github.com/Katello/katello.git/commit/a09a7d8880f6470587b63fc0f1a4cccade6eab3a))

### Hosts
 * DRY up applicability methods in content facet ([#25380](https://projects.theforeman.org/issues/25380), [f3d62346](https://github.com/Katello/katello.git/commit/f3d62346d8140cddfb17265bcb65c6faea84bafb))
 * Content Host -> Bulk Action -> Manage Package doesn't add a task and doesn't write a audit entry ([#25184](https://projects.theforeman.org/issues/25184), [a97c5526](https://github.com/Katello/katello.git/commit/a97c5526e3bc7a622f8c247d39d6dcfebd377f3b), [c9f9064c](https://github.com/Katello/katello.git/commit/c9f9064c461cac1ffdf51b00cab8cb9c43735a0f))

### Web UI
 * Content Credentials SSL Cert / GPG Key difficult to read ([#25332](https://projects.theforeman.org/issues/25332), [563164e1](https://github.com/Katello/katello.git/commit/563164e1cc31100c959d429743201fb705092ec4))

### Errata Management
 * /api/v2/hosts/bulk/installable_errata seems to hang ([#25311](https://projects.theforeman.org/issues/25311), [83515913](https://github.com/Katello/katello.git/commit/8351591309001ef8a34c554bcd5996cf0aaf5ddf))

### Provisioning
 * Include additional repo(s) for provisioning ([#25284](https://projects.theforeman.org/issues/25284), [a090aae2](https://github.com/Katello/katello.git/commit/a090aae2b582b84b8038ec562dec1186dae5d744))

### Hammer
 * allow import and export of composite content views ([#25272](https://projects.theforeman.org/issues/25272), [db3146ea](https://github.com/Katello/hammer-cli-katello.git/commit/db3146eaf327ab30038052a8d107768807b400d5))

### Tooling
 * katello-remove does not completely remove data on mounted filesystems ([#25195](https://projects.theforeman.org/issues/25195))

### Client/Agent
 * katello-host-tools commands should honor yum plugin config ([#25181](https://projects.theforeman.org/issues/25181), [ddbd4d2f](https://github.com/Katello/katello-host-tools.git/commit/ddbd4d2fcfe764d211a947498dbf6caeee52bdc5), [70851711](https://github.com/Katello/katello-host-tools.git/commit/70851711da5689121083c9ee1f13fd3f8a3f106a))
 * enabled_repos_upload plugin is slow ([#25173](https://projects.theforeman.org/issues/25173), [60c286a1](https://github.com/Katello/katello-host-tools.git/commit/60c286a1dc55b683b49b4058ec97af014dc76710))

### Modularity
 * Host Tools - Remove Package Profile/Enabled repos from Host Tools ([#25089](https://projects.theforeman.org/issues/25089), [89e62f5e](https://github.com/Katello/katello-host-tools.git/commit/89e62f5ef29e818b9aa80f348d8e5efe113e47e6))
 * UI - As a user I want to see Installed/Enabled modules ([#25088](https://projects.theforeman.org/issues/25088), [712300a6](https://github.com/Katello/katello.git/commit/712300a6c6a76cc3161ebaf4b3662a5840cc1241))
 * API - Would like Import Module Inventory Data from subscription manager ([#25087](https://projects.theforeman.org/issues/25087), [e60aa66e](https://github.com/Katello/katello.git/commit/e60aa66e17b40aef5ef2510f640a4b42a3443779))
 * API - Would like Import inventory Data from subscription manager ([#25086](https://projects.theforeman.org/issues/25086), [e94b95b9](https://github.com/Katello/katello.git/commit/e94b95b9fb9469761287f647b2a251ec54b15ce4))
 * UI - As a user I  would like to know the module information associated to an erratum  ([#25085](https://projects.theforeman.org/issues/25085), [65f82d01](https://github.com/Katello/katello.git/commit/65f82d01a0d4f8377d7547192d754da83ba83577))
 * As a user I would like to sync module information associated to an erratum  ([#25084](https://projects.theforeman.org/issues/25084), [77a4d76d](https://github.com/Katello/katello.git/commit/77a4d76db2d1524f152281a78ef8d17f4fdfa646))

### API
 * repository_sets shoudln't require product_id if i have given ID ([#24636](https://projects.theforeman.org/issues/24636), [716bb817](https://github.com/Katello/katello.git/commit/716bb81756ca55f7b60d1e9fc750afb4d7ff2de8))

### Localization
 * Refresh the strings and the connection from transifex ([#21836](https://projects.theforeman.org/issues/21836), [b9991bd8](https://github.com/Katello/katello.git/commit/b9991bd8291ec6ae8c9c5d2d4b2ebc1bf62fdb47))

### Other
 *  undefined method `[]' for nil:NilClass when more virt-who reports are sent a short time after othe ([#25643](https://projects.theforeman.org/issues/25643), [91fd93dc](https://github.com/Katello/katello.git/commit/91fd93dcfabf84f6fdc77490fffab4b6a7896f6e))
 * Update system purpose Candlepin API usage ([#25638](https://projects.theforeman.org/issues/25638), [3b421f50](https://github.com/Katello/katello.git/commit/3b421f5059f02d2532347bdb8382597513995689))
 * hammer lifecycle-environment info doesn't show Registry-related fields ([#25583](https://projects.theforeman.org/issues/25583), [cfce8868](https://github.com/Katello/hammer-cli-katello.git/commit/cfce8868df1d3da49e6a2bc876d174edae75aa22))
 * Package katello requires foreman-webpack-vendor ([#25545](https://projects.theforeman.org/issues/25545))
 * Audit Message for package installation / remove / update inconsistent ([#25450](https://projects.theforeman.org/issues/25450), [aee8b625](https://github.com/Katello/katello.git/commit/aee8b62594bcfb2bcefdd445e797f9bea610fc98))
 * Update for host task is no clear with what happened, and next steps ([#25443](https://projects.theforeman.org/issues/25443), [4e6d483b](https://github.com/Katello/katello.git/commit/4e6d483b1d13d7a32c5465e2aacc61e915e90c47))
 * Kickstart repo seems not available in promoted CV. ([#25379](https://projects.theforeman.org/issues/25379), [3d0250d5](https://github.com/Katello/katello.git/commit/3d0250d5cb305734511601e130b3d60dfcc92f59))
 * Capsule syncs fail ([#25371](https://projects.theforeman.org/issues/25371), [802c35f5](https://github.com/Katello/katello.git/commit/802c35f543140893936e8735f45bc563b85762cb))
 * [Modularity] - name_stream_only and host_ids missing from apidocs ([#25142](https://projects.theforeman.org/issues/25142), [951cae82](https://github.com/Katello/katello.git/commit/951cae823001814125d2b3e583bccf94fd478e7a))
 * Promoting debian Repositories to lifecycle Environments should not use the CheckMatchingContent logic until properly implemented ([#24929](https://projects.theforeman.org/issues/24929), [6756c4ed](https://github.com/Katello/katello.git/commit/6756c4ed1c2c126cedf44b309660bab01387952a))
 * Do not enable globally enabled middlewares in actions ([#24896](https://projects.theforeman.org/issues/24896), [494c82cf](https://github.com/Katello/katello.git/commit/494c82cf7240256cbfdb56059b5ab9e277bedb7b), [b35bdc56](https://github.com/Katello/katello.git/commit/b35bdc568e0424a5abc0935692b21e0325c12f9c), [95283713](https://github.com/Katello/katello.git/commit/95283713215b1756c1a0f95523d5f3394c6c17e8), [2eceff3f](https://github.com/Katello/katello.git/commit/2eceff3f1c7687129277d231064151d913b47c3a))
 * Docker repository sync on FIPS system fails with TypeError: can't quote ActiveSupport::HashWithIndifferentAccess ([#24889](https://projects.theforeman.org/issues/24889))
