# 3.3.1 Baltic Porter (2017-03-16)

## Features 

## Bug Fixes 

### Upgrades
 * katello 3.3.1 rc upgrade fails "NoMethodError: undefined method `default_capsule?' for nil:NilClass" ([#18886](http://projects.theforeman.org/issues/18886), [9a480e48](http://github.com/katello/katello/commit/9a480e48844e59d36298d9f05eef97be25415ee8))
 * foreman-proxy-certs-generate overwrites /etc/httpd/conf.d/pulp.conf wrongfully on katello ([#18402](http://projects.theforeman.org/issues/18402), [12102b60](http://github.com/katello//commit/12102b60306abd30feb6d0ab6969269a7c3dea4c))
 * Failed upgrade step doesn't prevent the following steps to proceed ([#17191](http://projects.theforeman.org/issues/17191), [24ef11bb](http://github.com/katello//commit/24ef11bbe83162dae7dd64b47a3544a6820491fb))
 * upgrade failed at update_subscription_facet_backend_data (undefined method `inject' for nil:NilClass) ([#17612](http://projects.theforeman.org/issues/17612), [4f414f3d](http://github.com/katello/katello/commit/4f414f3d37ea05ee7529759acb130112814b50a7))

### Documentation
 * Documentation Katello 3.2 upgrade documentation failure ([#18840](http://projects.theforeman.org/issues/18840))
 * Katello 3.3 Upgarde documentation wrong Repository URL provided ([#18839](http://projects.theforeman.org/issues/18839))
 * Katello Capsule Upgrade to 3.3 ([#18714](http://projects.theforeman.org/issues/18714))
 * Unrecognised option ([#18535](http://projects.theforeman.org/issues/18535))

### Repositories
 * RedHat Content sync stops working after upload of manifest ([#18816](http://projects.theforeman.org/issues/18816), [51811d4d](http://github.com/katello/katello/commit/51811d4d8d0b1b96d96cf6354d84620fa366b7f5))
 * cannot disable repo of orphaned product ([#17607](http://projects.theforeman.org/issues/17607), [99741423](http://github.com/katello/katello/commit/9974142353f77b53522c184e52b24751bd32de3c))

### Installer
 * certs-tar option requires the absolute path but the result message of the foreman-installer does not ([#18797](http://projects.theforeman.org/issues/18797))
 * Clarify Java version check ([#18537](http://projects.theforeman.org/issues/18537), [1f80ab65](http://github.com/katello//commit/1f80ab65271af6d55892682a4895f537903582b4))
 * Going from signed ca/server cert back to self signed cert causes errors ([#18322](http://projects.theforeman.org/issues/18322), [2b4081ea](http://github.com/katello//commit/2b4081ea7730092b038bbc6ef341d63d97d96a21))
 * Remove red error message on gutterball/elasticsearch during upgrade if already removed ([#18307](http://projects.theforeman.org/issues/18307), [c2c8933b](http://github.com/katello//commit/c2c8933b4d8caff4b719c83ccf82eee4cc4d1dfe))
 * foreman-installer -v --scenario katello --noop deletes pulp.conf ([#18132](http://projects.theforeman.org/issues/18132), [e1c00d97](http://github.com/katello//commit/e1c00d97adbba419140b50b65b2458ea0cda3be9))
 * unable to install katello with puppet 4 ([#17376](http://projects.theforeman.org/issues/17376))

### Hosts
 * Content host add/remove subscription lists columns span multiple column headers ([#18699](http://projects.theforeman.org/issues/18699))
 * Undefined constant Katello::System ([#18621](http://projects.theforeman.org/issues/18621), [630b33f5](http://github.com/katello/katello/commit/630b33f5ab5291a2a9a46a146fcce3284284cd7e))
 * ActiveRecord::StatementInvalid on host registration ([#18122](http://projects.theforeman.org/issues/18122), [98bb66d8](http://github.com/katello/katello/commit/98bb66d8b960e56a90401128313d2d5d996d11de), [62b30487](http://github.com/katello/katello/commit/62b304870cbe5d8d2916226bda7be2842e225eee))
 * New host creation ignores permissions for lifecycle envs, content views, and conent sources (smart proxies) ([#17176](http://projects.theforeman.org/issues/17176), [b5202aef](http://github.com/katello/katello/commit/b5202aefc6fc40124aa781dfc50fbcc1b42f2503))

### Puppet
 * Puppet upgrade from 3 to 4: foreman-installer --upgrade-puppet fails on cp of ssl files ([#18548](http://projects.theforeman.org/issues/18548), [0f7ea8bc](http://github.com/katello//commit/0f7ea8bc942ebe138ea69a226f50bd24cd9ed632))
 * Content view publishing puppet modules to wrong directory ([#17617](http://projects.theforeman.org/issues/17617), [2b86ed7e](http://github.com/katello/katello/commit/2b86ed7e8d19977dc47a6d10159b88146213441f), [b0c5c13e](http://github.com/katello//commit/b0c5c13ed2b414412bdfbe411c72854039ea4a1f))

### Errata Management
 * applicablity import job logs an error w/ stack instead of warning when host isnt found ([#18486](http://projects.theforeman.org/issues/18486), [6ccc80f1](http://github.com/katello/katello/commit/6ccc80f195012978bd09f36c2107049c615fa2ca))
 * showing Content -> Errata with "Installable" checkbox checked hakes too much time and memory when on scale ([#18376](http://projects.theforeman.org/issues/18376), [bd158ce1](http://github.com/katello/katello/commit/bd158ce127aac9e6becbe28b97b533ec79947295))

### Content Views
 * `hammer content-view [add-version|remove-version|copy|update|delete]` missing organization options ([#18351](http://projects.theforeman.org/issues/18351), [0b917e2d](http://github.com/katello//commit/0b917e2d5efb9f9e6a907d2fb2cd575910c167ff))
 * During selection of puppet module - "Use Latest" is incorrectly pointing to lower version than available in the repo ([#16327](http://projects.theforeman.org/issues/16327), [601291e3](http://github.com/katello/katello/commit/601291e3e215f23d25afc33af4af125fa5c55366))

### Hammer
 * Inconsistent Package Name when Uploading content into Repository via Web UI and Hammer CLI ([#17489](http://projects.theforeman.org/issues/17489), [22c390c9](http://github.com/katello/katello/commit/22c390c98adcbbc46e67c598ec8e3282b0e00eba))

### Client/Agent
 * Katello Agent RPM missing from fedora repos ([#15485](http://projects.theforeman.org/issues/15485))
 * systems where 'hostname -f' returns an error fails registration ([#17721](http://projects.theforeman.org/issues/17721), [1544376d](http://github.com/katello/puppet-certs/commit/1544376db06fbe9b73e412758f67b00bd4870915))

### Other
 * Installer fails on Puppet 4 upgrade with no class Katello::Helpers ([#18890](http://projects.theforeman.org/issues/18890), [d8c68d12](http://github.com/katello//commit/d8c68d12c7e4c7f2e6996bb53800a879d7e8141b))
 * Content Views Create/Promotion Fails with "undefined method '[]' for nil:NilClass (NoMethodError)  ([#18793](http://projects.theforeman.org/issues/18793), [ef20b996](http://github.com/katello/katello/commit/ef20b99665c41c1470e880704fcb83010d08b062))
 * Upgrading to katello 3.3 from 3.2 breaks pulp certificate verification ([#18730](http://projects.theforeman.org/issues/18730))
 * status emails contain HTML directives ([#18529](http://projects.theforeman.org/issues/18529), [ffe7dec8](http://github.com/katello/katello/commit/ffe7dec868358933e2a681ebe5736d51c1d5f3d4))
 * Org destroy not unassociating host groups ([#15340](http://projects.theforeman.org/issues/15340), [c6a4c5bf](http://github.com/katello/katello/commit/c6a4c5bf14b009651ba9b90f8cd0c604f27cc4f6))
 * Unattended template doesn't call 'built' ([#17903](http://projects.theforeman.org/issues/17903), [d3541c40](http://github.com/katello/katello/commit/d3541c40379d9dab7f4511199c0f9a0b1228d183))
# 3.3 Baltic Porter (2017-02-23)

## Features 

### Client/Agent
 * Run katello-tracer-upload after reboot ([#18174](http://projects.theforeman.org/issues/18174), [b5d8290e](http://github.com/katello//commit/b5d8290ec2f1cf7789b843e7c30a459c06fa69d0))

### Settings
 * Change the description of "unregister_delete_host" parameter under Administer -> Settings -> Katello. ([#17745](http://projects.theforeman.org/issues/17745), [f11051c6](http://github.com/katello/katello/commit/f11051c6b34e2415d8710b56a60e5319465dc23d))

### Content Views
 * Rake task needed to clean up repos published to wrong directory ([#17662](http://projects.theforeman.org/issues/17662), [424d2983](http://github.com/katello/katello/commit/424d29833961675c2b57d5ae88bc295aa02ac7ac))
 * Publish a CV with a puppet module raising NoMethodError with locations disabled ([#17281](http://projects.theforeman.org/issues/17281), [fc9311ed](http://github.com/katello/katello/commit/fc9311ed6022fdd7afea412fcb4ca2b58ccbc95a))
 * API: Allow promotion of content views to multiple environments ([#16638](http://projects.theforeman.org/issues/16638), [506f569d](http://github.com/katello/katello/commit/506f569d8440640043bc7abdc20738b209cddbce), [2b28d376](http://github.com/katello/katello/commit/2b28d376c31f1afca683a78c63a7b866e8cd1339))
 * Composite Content View Web UI: provide indication if a newer component version is available ([#16503](http://projects.theforeman.org/issues/16503), [5782bcfa](http://github.com/katello/katello/commit/5782bcfa0df5397081a79b2df953e6b764fa1b2f))
 * Incremental Update should set description for content view ([#16502](http://projects.theforeman.org/issues/16502), [adf12b3a](http://github.com/katello/katello/commit/adf12b3a931b7004eba202bad3cc0e1c908d6ed5))
 * Would like a hammer cli to add components to cv ([#15965](http://projects.theforeman.org/issues/15965), [8f74a5d1](http://github.com/katello/hammer-cli-katello/commit/8f74a5d145bf11544e4b781acfca393a50d0725d))
 * Add ability to publish "latest version" in a composite view ([#15950](http://projects.theforeman.org/issues/15950), [5582db4f](http://github.com/katello/katello/commit/5582db4fcba098745c2a815021e2d932c1bdf6c5))
 * allow content view filter to specify arch ([#14107](http://projects.theforeman.org/issues/14107), [ccc87494](http://github.com/katello/katello/commit/ccc874945ef77b6060c96e9c5c58abf251f1411e))
 * allow descriptions for content view promotions ([#7612](http://projects.theforeman.org/issues/7612), [1dcbd355](http://github.com/katello/katello/commit/1dcbd355fb41064da9f3bae2bd24411d1a4c3b4b))
 * [RFE] allow multiple CV with same repo to be added to a composite CV ([#6757](http://projects.theforeman.org/issues/6757), [e5586b7e](http://github.com/katello/katello/commit/e5586b7e6bfd07455997fdb1d7651650f9a83154))

### Web UI
 * Remove Nutupane from Packages pages ([#17637](http://projects.theforeman.org/issues/17637), [d590b887](http://github.com/katello/katello/commit/d590b887e7f68145376b0f6c951784602a8d1fe9))
 * Move katello to normal bs3 forms instead of horizontal forms ([#17386](http://projects.theforeman.org/issues/17386), [d88eb116](http://github.com/katello/katello/commit/d88eb1164af7f2402c75adc28fecf3be6739342c))
 * Remove Nutupane from Host Collection pages ([#17169](http://projects.theforeman.org/issues/17169), [1eb4eb4b](http://github.com/katello/katello/commit/1eb4eb4b33fc72822fd98e793c88c3d3b6c94b78))
 * Remove Nutupane from Docker Tags pages ([#17166](http://projects.theforeman.org/issues/17166), [e2d220f1](http://github.com/katello/katello/commit/e2d220f1624fdea91db3216e10847ad7a23bf8b9), [7e12805a](http://github.com/katello/katello/commit/7e12805aeb375d3277d90da18a18c8636051b0e1))
 * Remove Nutupane from Content View pages ([#17162](http://projects.theforeman.org/issues/17162), [08363567](http://github.com/katello/katello/commit/083635675b8a0cd0916ccedf286ae73d22039d8a))
 * Remove Nutupane from Sync Plan pages ([#17161](http://projects.theforeman.org/issues/17161), [61716296](http://github.com/katello/katello/commit/6171629655c8db96db41a8dda6c25c6d61a65dd8))
 * Remove Nutupane from Activation Keys pages ([#17160](http://projects.theforeman.org/issues/17160), [fbe5322c](http://github.com/katello/katello/commit/fbe5322c3d16952957469a8d2fa21dab87197c0f))
 * Remove Nutupane from subscriptions pages ([#17159](http://projects.theforeman.org/issues/17159), [cc43c9e3](http://github.com/katello/katello/commit/cc43c9e3c2873fd2293fc626c526c9bf7f80921d))
 * show upgradable package count in content hosts list ([#16724](http://projects.theforeman.org/issues/16724), [534baf8e](http://github.com/katello/katello/commit/534baf8e337421a0f6f3028e73eeaef94f239622))
 * Display subscription-manager fact origin ([#16715](http://projects.theforeman.org/issues/16715), [f9db71a6](http://github.com/katello/katello/commit/f9db71a6d331325fe58ae822507811b416bddc7b))

### Hosts
 * Expose PUT /rhsm to user credentials so facts may be updated in candlepin ([#17444](http://projects.theforeman.org/issues/17444), [39f0a341](http://github.com/katello/katello/commit/39f0a34109112d42a5606e44c06d644339c69838))
 * [RFE] Clients should report what services require restarting after an update ([#17230](http://projects.theforeman.org/issues/17230), [5632b01d](http://github.com/katello/katello-agent/commit/5632b01d31382aa344788f5dd5db5eb8532308cc))

### SElinux
 * add 5001 as an alternative docker registry port ([#17059](http://projects.theforeman.org/issues/17059), [8d044444](http://github.com/katello/katello-selinux/commit/8d0444449fe9b3d78680cf1383214c39bd6e790a))

### Candlepin
 * CP 2.0: Phase 1: refactor manifest deletion to be purely dynflow ([#17026](http://projects.theforeman.org/issues/17026), [a8a6ebd3](http://github.com/katello/katello/commit/a8a6ebd3958c33c1eb4aefb0e3b1a037c0435bf5))
 * CP 2.0: Phase 1: refactor manifest import/refresh to be purely dynflow ([#17025](http://projects.theforeman.org/issues/17025), [a8a6ebd3](http://github.com/katello/katello/commit/a8a6ebd3958c33c1eb4aefb0e3b1a037c0435bf5))

### Errata Management
 * Allow access to errata data from templates ([#16857](http://projects.theforeman.org/issues/16857), [3f5a832e](http://github.com/katello/katello/commit/3f5a832e5d8061ea413c677e5f933118a70bf160))

### Foreman Proxy Content
 * add download policy setting to capsules ([#16808](http://projects.theforeman.org/issues/16808), [2824830a](http://github.com/katello/katello/commit/2824830a0295f3bfad994c91284651e3ead4a0b7))

### Puppet
 * add option to force empty puppet environment ([#16756](http://projects.theforeman.org/issues/16756), [41b5f01d](http://github.com/katello/katello/commit/41b5f01db5cbe76269653174cccd1d345320c185))

### Tests
 * Set TargetRubyVersion in rubocop ([#16710](http://projects.theforeman.org/issues/16710), [f22e72f8](http://github.com/katello/katello/commit/f22e72f82b6ba4237d483e33e796b7fa5efbf393))
 * Add lifecycle-environment tests in hammer-cli-katello ([#16677](http://projects.theforeman.org/issues/16677))
 * upgrade rubocop to version 0.42 ([#16500](http://projects.theforeman.org/issues/16500), [7b97efac](http://github.com/katello/katello/commit/7b97efac60746ce4aa50b1853500c35e77e10f76))

### Hammer
 * As a CLI user, I should be able to see a list of packages available for update on a content host. ([#16533](http://projects.theforeman.org/issues/16533), [afa1377e](http://github.com/katello/hammer-cli-katello/commit/afa1377efa24deebecac498f0694f56d8af2f2c9))
 * Update to rubocop 0.42 ([#16522](http://projects.theforeman.org/issues/16522), [27f6f3d2](http://github.com/katello/hammer-cli-katello/commit/27f6f3d239b754ac8756685f3da0be7bc29755fd))
 * CLI: Support globs when uploading files to repositories ([#16521](http://projects.theforeman.org/issues/16521), [8ee56453](http://github.com/katello/hammer-cli-katello/commit/8ee5645369e681cf1740d264b04ab243b0e48800))

### Repositories
 * Need ability to add username/password for syncing from upstream repo ([#16481](http://projects.theforeman.org/issues/16481), [fe362081](http://github.com/katello/katello/commit/fe362081787239777f2689dbe27dff7112c17df8))
 * As a user, I should be able to see a list of packages available for update on a system via the api ([#5148](http://projects.theforeman.org/issues/5148), [6fa72c1a](http://github.com/katello/katello/commit/6fa72c1a7f9205abb76464707661218319213ca5), [c3930011](http://github.com/katello/katello/commit/c3930011180ba4c478392c1f057791a6f36ee97f))

### Installer
 * Add katello-service disable/enable to stop/start services loading on boot. ([#16251](http://projects.theforeman.org/issues/16251), [86a1bb71](http://github.com/katello/katello-packaging/commit/86a1bb710f0780ef43ce5ddcb2548f29b7b9621e))

### Docker
 * Manage docker images should show image names ([#9350](http://projects.theforeman.org/issues/9350), [fc7b9417](http://github.com/katello/katello/commit/fc7b94179b4526e60d6ea994bae11f7997ed9094))

### Other
 * make "Red Hat Repositories" page faster by caching/storing data from CDN ([#17696](http://projects.theforeman.org/issues/17696), [2011c57b](http://github.com/katello/katello/commit/2011c57b286b2cad7115291a1b43e0ad468aee84))
 * Remove nutupane from GPG keys pages ([#17144](http://projects.theforeman.org/issues/17144), [8101524c](http://github.com/katello/katello/commit/8101524c5582192235b4d5f58aeeee219e82cc87))
 * Add a mention bot config ([#16924](http://projects.theforeman.org/issues/16924), [52df02e2](http://github.com/katello/katello/commit/52df02e22b2795dc1f2932ba5999fc38b73e2cd7))
 * Please add a hammer ping to the foreman-debug ([#11607](http://projects.theforeman.org/issues/11607), [00a38897](http://github.com/katello/katello-packaging/commit/00a388972f7ef97293be2331ca40d73f34e639b7))

## Bug Fixes 

### Subscriptions
 * Product Create scarcely fails with InvalidFormatException in candlepin ([#18437](http://projects.theforeman.org/issues/18437), [6d0b4130](http://github.com/katello/katello/commit/6d0b4130ac35889410e137a1d7a7fb638cf3f5d8))
 * subscriptions tables have bordered cells which display poorly for the name rows ([#18294](http://projects.theforeman.org/issues/18294), [07ca0542](http://github.com/katello/katello/commit/07ca0542965027406b19dc64c092d1b6acb6e38f))
 * handle pool stackingId in an org-safe manner ([#17789](http://projects.theforeman.org/issues/17789), [ca671e34](http://github.com/katello/katello/commit/ca671e34d0deea9e34dd37f38c3d9f704e774a8e))
 * server_status to call CandlepinPing.ping just once ([#16870](http://projects.theforeman.org/issues/16870), [6343a0a2](http://github.com/katello/katello/commit/6343a0a283591f1bdd1f0c49049d96696ed29eb5))

### Upgrades
 * foreman-proxy-certs-generate overwrites /etc/httpd/conf.d/pulp.conf wrongfully on katello ([#18402](http://projects.theforeman.org/issues/18402), [12102b60](http://github.com/katello//commit/12102b60306abd30feb6d0ab6969269a7c3dea4c))
 * upgrade_check: [FAIL] - There are 1 active tasks. ([#17944](http://projects.theforeman.org/issues/17944), [39b9c8fe](http://github.com/katello/katello/commit/39b9c8fe039c23450d11931c90d5088397568b1a))
 * upgrade failed at update_subscription_facet_backend_data (undefined method `inject' for nil:NilClass) ([#17612](http://projects.theforeman.org/issues/17612), [4f414f3d](http://github.com/katello/katello/commit/4f414f3d37ea05ee7529759acb130112814b50a7))

### Installer
 * Unify hosts task can delete live managed virtual machines ([#18388](http://projects.theforeman.org/issues/18388), [3b45869b](http://github.com/katello/katello/commit/3b45869bdeae35aa029c0e15e7a3d09b99ada082))
 * foreman-proxy-content package does not exist ([#18312](http://projects.theforeman.org/issues/18312))
 * katello-certs-check needs to provide differentiating data for capsule-certs-generate to avoid error ([#18310](http://projects.theforeman.org/issues/18310), [bc93828c](http://github.com/katello//commit/bc93828cccc516686e9f2f96265e1e1b6bd23fef))
 * /etc/crane.conf is not configured correctly ([#18144](http://projects.theforeman.org/issues/18144), [76ceffe8](http://github.com/katello/puppet-katello/commit/76ceffe8b6c5059ef07cd111a103236ca415b23c), [9a26e45a](http://github.com/katello/puppet-capsule/commit/9a26e45a0c318c947a74107b892a0dbffc42eb21))
 * foreman-installer -v --scenario katello --noop deletes pulp.conf ([#18132](http://projects.theforeman.org/issues/18132), [e1c00d97](http://github.com/katello//commit/e1c00d97adbba419140b50b65b2458ea0cda3be9))
 * self-registered katello fails on "foreman-installer --upgrade-puppet" because of missing package puppet-agent-oauth ([#18068](http://projects.theforeman.org/issues/18068), [cdd0413a](http://github.com/katello//commit/cdd0413a080a8222891a371a887f1022815e8d5d))
 * Need a migration to convert previous invalid 'false' value to undef for dhcp ranges ([#17996](http://projects.theforeman.org/issues/17996), [9da81e4a](http://github.com/katello/katello-installer/commit/9da81e4a02bf689fbf0eb685addeaad4dc128304))
 * Migration is missing to convert `capsule` to `foreman_proxy_content` in answers file ([#17995](http://projects.theforeman.org/issues/17995), [9da81e4a](http://github.com/katello/katello-installer/commit/9da81e4a02bf689fbf0eb685addeaad4dc128304))
 * foreman-proxy-certs-generate fails with no cache of file foreman_proxy_content found ([#17988](http://projects.theforeman.org/issues/17988), [c625f1a4](http://github.com/katello/katello-installer/commit/c625f1a45126cc8cddcdbb784a9a53806962bf4d))
 * Provide valid bash variable on installer output ([#17975](http://projects.theforeman.org/issues/17975), [e3136e62](http://github.com/katello/katello-installer/commit/e3136e622beba0325c1b0ed98dc6abcbc905ac27))
 * No way to enable foreman_discovery_smart_proxy via installer ([#17926](http://projects.theforeman.org/issues/17926), [45ad1621](http://github.com/katello/katello-installer/commit/45ad162133f099e471f068577821168a5ed2771a))
 * Fresh install fails because of missing 'puppet' user ([#17863](http://projects.theforeman.org/issues/17863), [1c8129bf](http://github.com/katello/puppet-certs/commit/1c8129bfa1b819a3f1ec1a83d4df3e45fc1dabd6))
 * cache generator deletes all caches that begin with 'foreman' including foreman_proxy_content ([#17710](http://projects.theforeman.org/issues/17710), [893af950](http://github.com/katello/katello-installer/commit/893af950bd1147b715d72cc7a4bd529ff809b885))
 * Katello installer tests are failing ([#17668](http://projects.theforeman.org/issues/17668), [c51a6072](http://github.com/katello/katello-installer/commit/c51a60726e8f4bc51c09d0e303e55f811481d8d8))
 * Upgrade fails if /var/lib/tfpboot/grub2 is not pre-created ([#17639](http://projects.theforeman.org/issues/17639), [9d08de25](http://github.com/katello/katello-installer/commit/9d08de2589d7a3c01f9965fa0aaf5f86be992b9b))
 * capsule installer modules_dir is broken ([#17604](http://projects.theforeman.org/issues/17604), [90a5196d](http://github.com/katello/katello-installer/commit/90a5196dc9702f5796e670f0172f7d15ebe9668f))
 * ISO repository to Capsule synchronization fails with error "Katello::Errors::PulpError: PLP0000: Importer indicated a failed response" ([#17590](http://projects.theforeman.org/issues/17590))
 * Katello shouldn't use boolean for foreman::server_ssl_crl value ([#17534](http://projects.theforeman.org/issues/17534), [9893dd96](http://github.com/katello/katello-installer/commit/9893dd9616a9fd9ae61a5b9fa24377e363de7550), [c01ce694](http://github.com/katello/katello-installer/commit/c01ce6945a1802cbeb3676def48f22aaf567f564))
 * We no longer need to delete ssl.conf when we move to the latest puppetlabs-apache version ([#17507](http://projects.theforeman.org/issues/17507), [ef64a148](http://github.com/katello/katello-installer/commit/ef64a14888273ca55e5181f2eec3197c2548bf12))
 * Installation failed - Failed to apply catalog: Found 1 dependency cycle ([#17414](http://projects.theforeman.org/issues/17414))
 * CA cert file is not configured for Candlepin communication ([#17380](http://projects.theforeman.org/issues/17380), [46216f7d](http://github.com/katello/puppet-katello/commit/46216f7d74e0cf5bc43a6ffdb322af885818fbbe))
 * group: foreman was removed from certs ([#17278](http://projects.theforeman.org/issues/17278), [145ccfe4](http://github.com/katello/katello-installer/commit/145ccfe472880a299658a1b05b2da0c7fc1472c2))
 * Sync migrations and answers ([#17201](http://projects.theforeman.org/issues/17201), [0174992d](http://github.com/katello/katello-installer/commit/0174992d0cf90fe577d0c8cf2d005eefe7bd2391), [eb38e664](http://github.com/katello/katello-installer/commit/eb38e6647aa6fe0dd0959a2e666d7258378d8fed), [a53fad63](http://github.com/katello/katello-packaging/commit/a53fad639654bcbdd2db3b853bb7768f3cbd6a8d))
 * Rubocop failing on installer ([#17138](http://projects.theforeman.org/issues/17138), [4cead21b](http://github.com/katello/katello-installer/commit/4cead21b8a0c4272cbd787d4bae836aa4d15b822))
 * Installer upgrade should only perform pre upgrade steps once ([#17092](http://projects.theforeman.org/issues/17092), [cbdace60](http://github.com/katello/katello-installer/commit/cbdace605427885a0773ed7a1dd9383748cd9fe1))
 * Satellite 6 can't be installed if syslog not running - /dev/log does not exist ([#16778](http://projects.theforeman.org/issues/16778), [76b11e65](http://github.com/katello/katello-installer/commit/76b11e652f867143110b16f7d033d0b902d089f9))
 * -capsule-puppet false doesnt work ([#16751](http://projects.theforeman.org/issues/16751))
 * katello-installer requires kafo 0.9.3 or later, should be 1.0.1 or later ([#16611](http://projects.theforeman.org/issues/16611), [ca70b317](http://github.com/katello/katello-installer/commit/ca70b317748501454053100326a44a33cdfd0a24))
 * capsule-certs-generate does not look at katello-installer-base path, script does not work on dev installs ([#16541](http://projects.theforeman.org/issues/16541), [c84a264d](http://github.com/katello/katello-installer/commit/c84a264d59f979d966459e5897fcde316febb504))
 * Qpid should only listen on localhost ([#11737](http://projects.theforeman.org/issues/11737), [8c6812cc](http://github.com/katello/puppet-capsule/commit/8c6812cc4e06572df1b757315f65916bb602e67c), [59857e16](http://github.com/katello/puppet-certs/commit/59857e16dccbeb6e9546179f1965560ccf9a674c), [37749e81](http://github.com/katello/puppet-katello/commit/37749e8182f007c653fba128d8e37d5a659f9e71), [b4d7ebf5](http://github.com/katello/katello-installer/commit/b4d7ebf5694976640a0ded556ed72f1dc105025b))
 * unable to install katello with puppet 4 ([#17376](http://projects.theforeman.org/issues/17376))

### Repositories
 * regression - Unable to upload packages to a repository ([#18272](http://projects.theforeman.org/issues/18272), [dd4c2180](http://github.com/katello/katello/commit/dd4c21803e506ea29a9958c49cb917d7375f375d))
 * Katello::<Unit type>.import_all function breaks repository association after upgrading satellite or running reindex rake task ([#18116](http://projects.theforeman.org/issues/18116), [78e9b1a5](http://github.com/katello/katello/commit/78e9b1a5dbc1c61cbb25b1d715611d6f6d70234e))
 * Keyboard tab doesnt function well with Products or Repository page ([#17787](http://projects.theforeman.org/issues/17787), [2b95d5d6](http://github.com/katello/katello/commit/2b95d5d689e7fd139b372611e3cb37c4a52c959b))
 * Repository new and edit pages list no download poilicies to select ([#17542](http://projects.theforeman.org/issues/17542), [7d7429ce](http://github.com/katello/katello/commit/7d7429ce5b7334394e4875833b13825b3341f57e))
 * sync product repo does not switch to task page ([#17523](http://projects.theforeman.org/issues/17523), [4b43ca57](http://github.com/katello/katello/commit/4b43ca5730f13d5e632fc1887b8b680109d76f34))
 * Synchronizing a repository with large amount rpms causes large memory usages while indexing ([#17512](http://projects.theforeman.org/issues/17512), [e5cd23c7](http://github.com/katello/katello/commit/e5cd23c7a8c6e329bdc140266e2dc4e70347e239))
 * pulp communication relies on system wide store rather than specifying CA path ([#17400](http://projects.theforeman.org/issues/17400), [f559725c](http://github.com/katello/katello/commit/f559725cdd1173b0c0d2b111dbc6b0120d4a000a), [264a110f](http://github.com/katello/puppet-katello/commit/264a110ff306ccf4f713aae034db847a0c2f74bc))
 * new repository button does not go to new repository page ([#17388](http://projects.theforeman.org/issues/17388), [3979337f](http://github.com/katello/katello/commit/3979337f6b8d69cccba4767ea59c56380629b228))
 * errata apply task does not show installed/updated packages  ([#17233](http://projects.theforeman.org/issues/17233), [e05874cf](http://github.com/katello/katello/commit/e05874cfe7ae75730e0ea401f5dd08ccc297310a))
 * repository delete by name neither allows to delete repo w/o org nor accepts the org ([#16730](http://projects.theforeman.org/issues/16730), [7f4d6b79](http://github.com/katello/hammer-cli-katello/commit/7f4d6b794b3c0c119cfd41778e70cb7f936bb124))
 * cannot disable repo of orphaned product ([#17607](http://projects.theforeman.org/issues/17607), [99741423](http://github.com/katello/katello/commit/9974142353f77b53522c184e52b24751bd32de3c))

### Errata Management
 * Apply Errata -  no implicit conversion of nil into Array ([#18254](http://projects.theforeman.org/issues/18254), [0919536e](http://github.com/katello/katello/commit/0919536e0bb80eb55aecd1fbe2e6cf03bcaff759))
 * Handle errata status with Library vs current environment ([#12347](http://projects.theforeman.org/issues/12347), [a75565df](http://github.com/katello/katello/commit/a75565df0b98c64efe33874f0544034071e6b1c6))

### Client/Agent
 * Katello-agent should create a katello-agent-restart file instead of manually restarting goferd ([#18187](http://projects.theforeman.org/issues/18187), [567c3c0a](http://github.com/katello//commit/567c3c0a3da1d34a2717f14b1ade038ff6e232ee), [d447c582](http://github.com/katello/katello-packaging/commit/d447c5820aeb31d7764b9ccfbdd04af3070c4e57))
 * Installing katello-agent results in error  ([#18173](http://projects.theforeman.org/issues/18173), [e35caf2d](http://github.com/katello/katello-packaging/commit/e35caf2df9b2f9ea1359a070badf9289ba10382b))
 * reinstalling katello-ca-consumer on RHEL7 Content Host does not restart goferd service ([#17658](http://projects.theforeman.org/issues/17658), [5e02f1e7](http://github.com/katello/puppet-certs/commit/5e02f1e7b8ad4888247c6a0b2c44cd1b6cbb151a))
 * tracer upload yum plugin should look at all pkgs  ([#17359](http://projects.theforeman.org/issues/17359), [03c9eb82](http://github.com/katello/katello-agent/commit/03c9eb82745e966e5be2969c18727d51176d9dc5))
 * systems where 'hostname -f' returns an error fails registration ([#17721](http://projects.theforeman.org/issues/17721), [1544376d](http://github.com/katello/puppet-certs/commit/1544376db06fbe9b73e412758f67b00bd4870915))

### Foreman Proxy Content
 * smart proxy refresh throws stackerror ([#18185](http://projects.theforeman.org/issues/18185), [1e8efa1e](http://github.com/katello/katello/commit/1e8efa1ed249099beaa5114a93eb148255937bcf))
 * API/CLI - ISE on Deleting proxy: Can't modify frozen hash ([#17784](http://projects.theforeman.org/issues/17784), [3d8abda4](http://github.com/katello/katello/commit/3d8abda434f21e4f2cb4fc33cb7f1dce9efc77e1))
 * Replace all instances of Capsule with Smart Proxy in Katello UI ([#17601](http://projects.theforeman.org/issues/17601), [738d54ad](http://github.com/katello/katello/commit/738d54ad15fc64afe4975113973877575cde8a77))

### Content Views
 * published docker content views are missing docker tags ([#18110](http://projects.theforeman.org/issues/18110), [70a2d0da](http://github.com/katello/katello/commit/70a2d0dae5e1c14081fa9af5f6413652daf140b7))
 * "add" button missing from ostree content view page ([#18048](http://projects.theforeman.org/issues/18048), [98151d48](http://github.com/katello/katello/commit/98151d48575158839e85e34314aebe9f358f0408))
 * Content view filter cannot distinguish between multiple packages with the same version but different release number ([#17916](http://projects.theforeman.org/issues/17916), [bafd8b82](http://github.com/katello/katello/commit/bafd8b82c581ef87add58af25b37b1ff9ace07d9))
 * incremental update fails with "NoMethodError: undefined method `each' for #<Katello::KTEnvironment:>" ([#17628](http://projects.theforeman.org/issues/17628), [475df1d9](http://github.com/katello/katello/commit/475df1d94904409a0becc4f7fe52529bf3fe3e14))
 * CV Publish failing for combination of repos ([#17610](http://projects.theforeman.org/issues/17610), [648336c3](http://github.com/katello/katello/commit/648336c3d8e2bef0f0c9c83904b7791a624f73d9))
 * As a user, I want to create content view filters for tags in docker repos. ([#17293](http://projects.theforeman.org/issues/17293), [d9361888](http://github.com/katello/katello/commit/d93618882f0091b90018c2264765a8d098d3927e))
 * Content view erratum filter by date: default types to all ([#17108](http://projects.theforeman.org/issues/17108), [15a4ac65](http://github.com/katello/katello/commit/15a4ac65790581f50a63306fc9f2e901cf630cc1))
 * Inconsistent data type and format for version info in API ([#16757](http://projects.theforeman.org/issues/16757), [7de7533f](http://github.com/katello/katello/commit/7de7533f6073eac422e309b3f6ea018219708979))
 * Content view histories lose their type after clearing out foreman tasks ([#16673](http://projects.theforeman.org/issues/16673), [56b7973c](http://github.com/katello/katello/commit/56b7973cd1cd91aa73003ceb996353ebff285419), [e96f76e4](http://github.com/katello/katello/commit/e96f76e4a3408f213c24672b66c29cdf64f36b85))
 * the alignment for the confirmation buttons for deleting a content view is off ([#16272](http://projects.theforeman.org/issues/16272), [249445c0](http://github.com/katello/katello/commit/249445c086c1e8f016ebf25b0cf13875536f1726))
 * Content View: Repository sync and content information are blank for a newly enabled repository ([#16265](http://projects.theforeman.org/issues/16265), [25d6f29f](http://github.com/katello/katello/commit/25d6f29f21196fcf1594ca2f0e9bf073dc692cb4))
 * During selection of puppet module - "Use Latest" is incorrectly pointing to lower version than available in the repo ([#16327](http://projects.theforeman.org/issues/16327), [601291e3](http://github.com/katello/katello/commit/601291e3e215f23d25afc33af4af125fa5c55366))

### Docker
 * environments page for a docker tag is blank ([#18077](http://projects.theforeman.org/issues/18077), [5e53ffd6](http://github.com/katello/katello/commit/5e53ffd6e9385291a1f12c1165a437a0a2a856db))
 * Associating docker tag with incorrect docker manifest. ([#17317](http://projects.theforeman.org/issues/17317), [806a8e4e](http://github.com/katello/katello/commit/806a8e4e0c19e75cfffb0de96beb0eb3ca3d3794), [beb1cd36](http://github.com/katello/katello/commit/beb1cd36c67c3566a36367bad503352fa0beb9fb))
 * Improve UI details for docker tags ([#17186](http://projects.theforeman.org/issues/17186), [b8eae753](http://github.com/katello/katello/commit/b8eae75360cf02fd69201eb8b309b17d2375cc54))
 * docker tags page only shows tag not full name  ([#16851](http://projects.theforeman.org/issues/16851), [0c37e226](http://github.com/katello/katello/commit/0c37e226676417187e76c5d3252ba2656bc9b13c))

### Provisioning
 * Katello Atomic Kickstart Default template has undefined local variable "os_major" ([#18054](http://projects.theforeman.org/issues/18054), [21bb2b59](http://github.com/katello/katello/commit/21bb2b598bf2290f702553a4c05336b644528910))
 * Network snippets missing from atomic kickstart ([#17924](http://projects.theforeman.org/issues/17924), [a0ccc0d5](http://github.com/katello/katello/commit/a0ccc0d575ee6c7779bfcc1070571e266c9bbb0a))

### Web UI
 * Sync Plans UI: Unable to create one. ([#18019](http://projects.theforeman.org/issues/18019))
 * Content view kabab doesn't work ([#17938](http://projects.theforeman.org/issues/17938), [7c972fdf](http://github.com/katello/katello/commit/7c972fdf4f29c021900db29185e57ed4e9415b64))
 * katello needs to require bastion 4.0.0 ([#17912](http://projects.theforeman.org/issues/17912), [6fe9180e](http://github.com/katello/katello/commit/6fe9180e171e6607e61a29780a51ec19e6db7824))
 * Some tables still have Deselect All link active with nothing selected ([#17685](http://projects.theforeman.org/issues/17685), [871ef7dc](http://github.com/katello/katello/commit/871ef7dc41d3dd599a732bfc909bb5b807896fc7))
 * product table name link should link directly to repositories ([#17371](http://projects.theforeman.org/issues/17371), [440121d4](http://github.com/katello/katello/commit/440121d40a58723c0bb363dc2a6447ccb4e54b98))
 * Dashboard Content Host Subscription Status Links are not URI encoded ([#17227](http://projects.theforeman.org/issues/17227), [4e6744dd](http://github.com/katello/katello/commit/4e6744dd462d613667c746c53c062c9300019500), [79ed3c6b](http://github.com/katello/katello/commit/79ed3c6b12b014dc4a8cbfff5f41f637bfa4d7c3))
 * upradable package list shows all applicable packages ([#16902](http://projects.theforeman.org/issues/16902), [b6c4c7af](http://github.com/katello/katello/commit/b6c4c7af866185082572307236a522e8bf01cd6d))
 * Content View Filter Rule version dropdown menu should place the input textbox to the right of the version dropdown ([#16777](http://projects.theforeman.org/issues/16777), [66afbd18](http://github.com/katello/katello/commit/66afbd18b047d955b3973b3877e8b3f0e735bf58))
 * Fix the case of the menu items in Katello (e.g. "Sync Status" vs "Activation keys") ([#16589](http://projects.theforeman.org/issues/16589), [b4c0cb9e](http://github.com/katello/katello/commit/b4c0cb9e761d26180d06160ab7a375b94cb33a09))
 * add step up polling interval for UI task polling ([#16575](http://projects.theforeman.org/issues/16575), [b19a24e7](http://github.com/katello/katello/commit/b19a24e7b96c203364b537f8a321c5b67d8ff1b6))
 * Lifecycle environments not redirecting to 404 ([#16246](http://projects.theforeman.org/issues/16246), [b481e2ae](http://github.com/katello/katello/commit/b481e2aecb210c42e1dd6857b2ae9ee59e8f92a7))
 * "Error: Request Timeout" from hammer when asked to show >400 content hosts ([#16010](http://projects.theforeman.org/issues/16010), [80ebe622](http://github.com/katello/katello/commit/80ebe622e8820a2aa8f9db0c78a90b9369971e6c))
 * GPG list not sorted in product/repository GPG key picklist ([#8455](http://projects.theforeman.org/issues/8455), [d3b38297](http://github.com/katello/katello/commit/d3b38297e9a499adc85d7ae76964552aba59ab10))

### GPG Keys
 * Error while navigating to Products from the GPG keys page. ([#18018](http://projects.theforeman.org/issues/18018), [461bf33a](http://github.com/katello/katello/commit/461bf33afb75eb2eec55e631ff0d5465eeb92074))

### Puppet
 * After upgrade Content View loses puppet modules ([#17987](http://projects.theforeman.org/issues/17987), [7634303d](http://github.com/katello/katello/commit/7634303df553f400edd03b30686eda8a2e3e8a0e))

### Hosts
 * Getting undefined method `name' for nil:NilClass when trying edit/view a host group ([#17815](http://projects.theforeman.org/issues/17815), [a3d89422](http://github.com/katello/katello/commit/a3d8942292fef71ab4d494208f1970b361664f93))
 * Display package applicability for a single host ([#16637](http://projects.theforeman.org/issues/16637), [940bd79d](http://github.com/katello/katello/commit/940bd79d5703a81997d8f7621084693f719d36ab))
 * New host creation ignores permissions for lifecycle envs, content views, and conent sources (smart proxies) ([#17176](http://projects.theforeman.org/issues/17176), [b5202aef](http://github.com/katello/katello/commit/b5202aefc6fc40124aa781dfc50fbcc1b42f2503))

### Tests
 * fix rubocop 0.46 errors ([#17805](http://projects.theforeman.org/issues/17805), [5043f5c8](http://github.com/katello/katello/commit/5043f5c8168d35e6ae0f0ad62ef76443e648c9b4))
 * CapsuleContent Test fails during the month of december ([#17557](http://projects.theforeman.org/issues/17557), [519b940d](http://github.com/katello/katello/commit/519b940dd7adc5da87bc2ac4bcdefcb2d3a103b4))
 * populating test DB fails on fresh install ([#17550](http://projects.theforeman.org/issues/17550), [be8ede9e](http://github.com/katello/katello/commit/be8ede9e056ff41181aa8e87be956844ed122b2e))
 * add access permission tests to katello ([#16998](http://projects.theforeman.org/issues/16998), [e23255a8](http://github.com/katello/katello/commit/e23255a8981bc1ffc12d0110cf02dea79416b3ce))

### API
 * Inconsistent host content_source field between UI and API ([#17644](http://projects.theforeman.org/issues/17644), [02caee7e](http://github.com/katello/katello/commit/02caee7ed2286cf816cbe9d5e59d3fa3d1e3999a))
 * Remove duplicate permission code from product api ([#17481](http://projects.theforeman.org/issues/17481), [c3019887](http://github.com/katello/katello/commit/c3019887587b5d42239405de765b7920d6f41eeb))
 * Katello API : POST /katello/api/v2/content_view_versions/:id/promote results in NoMethodError ([#16745](http://projects.theforeman.org/issues/16745), [ce140802](http://github.com/katello/katello/commit/ce140802145e328548c0e0c2e9e9fac7a307cd1f))

### Candlepin
 * Improve ListenOnCandlepinEvents throughput ([#17498](http://projects.theforeman.org/issues/17498), [55677460](http://github.com/katello/katello/commit/55677460eea47e2d34a04364b485daaf59296cdc), [87ef553c](http://github.com/katello/katello/commit/87ef553cfe840299389abbb4123a640c2227e0bb))
 * trigger debug cert generation during org creation ([#16978](http://projects.theforeman.org/issues/16978), [9eb73f03](http://github.com/katello/katello/commit/9eb73f03232b42749d6dce1c4dba4fc243002c6a))

### Lifecycle Environments
 * Puppet module appear in content view but doesn't appear in lifecycle environment ([#17402](http://projects.theforeman.org/issues/17402), [13f1896c](http://github.com/katello/katello/commit/13f1896ccec51492593394cf137b5070ad28974b))

### Documentation
 * hard linebreaks in developer docs on katello.org ([#16875](http://projects.theforeman.org/issues/16875), [e6211945](http://github.com/katello//commit/e62119451cae6082f65630b85a727a3e28b5d25e))

### Hammer
 * hammer package list with organization fails ([#16793](http://projects.theforeman.org/issues/16793), [6a37d966](http://github.com/katello/hammer-cli-katello/commit/6a37d966687d7507dd3ea6acf84ec1912e96ebee))

### foreman-debug
 * foreman-debug to collect whole newest (log)files instead of tailing all (log)files ([#16680](http://projects.theforeman.org/issues/16680))

### Tooling
 * "katello-service restart" does not restart goferd on Capsule ([#16586](http://projects.theforeman.org/issues/16586), [a5ee1f2a](http://github.com/katello/katello-packaging/commit/a5ee1f2af886293faf6bdd55f221328929277f52))

### Roles and Permissions
 * Unable to create a repository as non-admin user  ([#16505](http://projects.theforeman.org/issues/16505), [4506461b](http://github.com/katello/katello/commit/4506461b920f837d1097963f8c8361ac60a47fbf), [48caa6f1](http://github.com/katello/katello/commit/48caa6f12e62d19547aad52f5d7bd5a831edd81f))

### Other
 * Rendering RABL for host/main fails ([#18059](http://projects.theforeman.org/issues/18059), [661260bd](http://github.com/katello/katello/commit/661260bd002362687fdad79c1d894bd0f65ff33f))
 * katello-restore fails ([#17908](http://projects.theforeman.org/issues/17908), [bde2b486](http://github.com/katello/katello-packaging/commit/bde2b486801ae2aee47a46d50ddc837119b3a100))
 * katello:check_ping should load environment ([#17719](http://projects.theforeman.org/issues/17719), [54a25322](http://github.com/katello/katello/commit/54a25322994ee1f52e34d921afc634bd7f91cc94))
 * Red hat repositories is too slow ([#17718](http://projects.theforeman.org/issues/17718), [3611988b](http://github.com/katello/katello/commit/3611988b252cc3450b2cf8ef53a26bd3b5eb43db))
 * Hostgroup create/update does not accept --lifecycle-environment parameter ([#17619](http://projects.theforeman.org/issues/17619), [6581e356](http://github.com/katello/hammer-cli-katello/commit/6581e356a0cbe5f87c5785dccc8da816f51f8d8a))
 * Incremental update results in "undefined method description=" for ContentViewVersion ([#17584](http://projects.theforeman.org/issues/17584), [61273472](http://github.com/katello/katello/commit/61273472750db53839c06535f793326bff688d81))
 * Using update for errata install via Remote Execution instead of update-minimal ([#17513](http://projects.theforeman.org/issues/17513), [04b727fb](http://github.com/katello/katello/commit/04b727fbd0c89a8fb565e021840a110384b44ad3))
 * Backend data should not be initialized in database seeds ([#17465](http://projects.theforeman.org/issues/17465), [5cd70f08](http://github.com/katello/katello/commit/5cd70f08aa47d127fdacaf025b1c1940f976198d))
 * Refactor Ping model to address method length and branching ([#17382](http://projects.theforeman.org/issues/17382), [9a65a4f8](http://github.com/katello/katello/commit/9a65a4f805616b7c66e326ab18f69b4818fd21d6))
 * Specifying ca_cert_file for Candlepin fails with SSL verify error ([#17379](http://projects.theforeman.org/issues/17379), [a424a710](http://github.com/katello/katello/commit/a424a710b117976f4a4fdc89450c61b99f7357cc))
 * Improve the error message when a repository does not exist for a certain architecture / and version ([#17181](http://projects.theforeman.org/issues/17181), [c204cba3](http://github.com/katello/katello/commit/c204cba3b3bbbb4e8b1e9eaeff88c081dcb9a56c))
 * foreman-debug to collect whole newest (log)files instead of tailing all (log)files ([#17114](http://projects.theforeman.org/issues/17114), [4ff859b6](http://github.com/katello/katello-packaging/commit/4ff859b6ef71f25d426d63cf7b336f87cae7488c))
 * hammer content-view filter list is missing --organization parameter ([#16794](http://projects.theforeman.org/issues/16794), [463c7d63](http://github.com/katello/hammer-cli-katello/commit/463c7d63acb0ae1901cbbc0d45ac189a1da16fb2))
 * Dashboard names and titles are inconsistent ([#16679](http://projects.theforeman.org/issues/16679), [cfa911c6](http://github.com/katello/katello/commit/cfa911c6827fff885c54044c31c76a51e1b94c0c))
 * Unattended template doesn't call 'built' ([#17903](http://projects.theforeman.org/issues/17903), [d3541c40](http://github.com/katello/katello/commit/d3541c40379d9dab7f4511199c0f9a0b1228d183))
# 3.3 Baltic Porter (2017-01-11)

## Features 

### Settings
 * Change the description of "unregister_delete_host" parameter under Administer -> Settings -> Katello. ([#17745](http://projects.theforeman.org/issues/17745), [f11051c6](http://github.com/katello/katello/commit/f11051c6b34e2415d8710b56a60e5319465dc23d))

### Web UI
 * Remove Nutupane from Packages pages ([#17637](http://projects.theforeman.org/issues/17637), [d590b887](http://github.com/katello/katello/commit/d590b887e7f68145376b0f6c951784602a8d1fe9))
 * Move katello to normal bs3 forms instead of horizontal forms ([#17386](http://projects.theforeman.org/issues/17386), [d88eb116](http://github.com/katello/katello/commit/d88eb1164af7f2402c75adc28fecf3be6739342c))
 * Remove Nutupane from Host Collection pages ([#17169](http://projects.theforeman.org/issues/17169), [1eb4eb4b](http://github.com/katello/katello/commit/1eb4eb4b33fc72822fd98e793c88c3d3b6c94b78))
 * Remove Nutupane from Docker Tags pages ([#17166](http://projects.theforeman.org/issues/17166), [e2d220f1](http://github.com/katello/katello/commit/e2d220f1624fdea91db3216e10847ad7a23bf8b9), [7e12805a](http://github.com/katello/katello/commit/7e12805aeb375d3277d90da18a18c8636051b0e1))
 * Remove Nutupane from Content View pages ([#17162](http://projects.theforeman.org/issues/17162), [08363567](http://github.com/katello/katello/commit/083635675b8a0cd0916ccedf286ae73d22039d8a))
 * Remove Nutupane from Sync Plan pages ([#17161](http://projects.theforeman.org/issues/17161), [61716296](http://github.com/katello/katello/commit/6171629655c8db96db41a8dda6c25c6d61a65dd8))
 * Remove Nutupane from Activation Keys pages ([#17160](http://projects.theforeman.org/issues/17160), [fbe5322c](http://github.com/katello/katello/commit/fbe5322c3d16952957469a8d2fa21dab87197c0f))
 * Remove Nutupane from subscriptions pages ([#17159](http://projects.theforeman.org/issues/17159), [cc43c9e3](http://github.com/katello/katello/commit/cc43c9e3c2873fd2293fc626c526c9bf7f80921d))
 * show upgradable package count in content hosts list ([#16724](http://projects.theforeman.org/issues/16724), [534baf8e](http://github.com/katello/katello/commit/534baf8e337421a0f6f3028e73eeaef94f239622))
 * Display subscription-manager fact origin ([#16715](http://projects.theforeman.org/issues/16715), [f9db71a6](http://github.com/katello/katello/commit/f9db71a6d331325fe58ae822507811b416bddc7b))

### Hosts
 * Expose PUT /rhsm to user credentials so facts may be updated in candlepin ([#17444](http://projects.theforeman.org/issues/17444), [39f0a341](http://github.com/katello/katello/commit/39f0a34109112d42a5606e44c06d644339c69838))

### Content Views
 * Publish a CV with a puppet module raising NoMethodError with locations disabled ([#17281](http://projects.theforeman.org/issues/17281), [fc9311ed](http://github.com/katello/katello/commit/fc9311ed6022fdd7afea412fcb4ca2b58ccbc95a))
 * API: Allow promotion of content views to multiple environments ([#16638](http://projects.theforeman.org/issues/16638), [506f569d](http://github.com/katello/katello/commit/506f569d8440640043bc7abdc20738b209cddbce), [2b28d376](http://github.com/katello/katello/commit/2b28d376c31f1afca683a78c63a7b866e8cd1339))
 * Composite Content View Web UI: provide indication if a newer component version is available ([#16503](http://projects.theforeman.org/issues/16503), [5782bcfa](http://github.com/katello/katello/commit/5782bcfa0df5397081a79b2df953e6b764fa1b2f))
 * Incremental Update should set description for content view ([#16502](http://projects.theforeman.org/issues/16502), [adf12b3a](http://github.com/katello/katello/commit/adf12b3a931b7004eba202bad3cc0e1c908d6ed5))
 * Would like a hammer cli to add components to cv ([#15965](http://projects.theforeman.org/issues/15965), [8f74a5d1](http://github.com/katello/hammer-cli-katello/commit/8f74a5d145bf11544e4b781acfca393a50d0725d))
 * Add ability to publish "latest version" in a composite view ([#15950](http://projects.theforeman.org/issues/15950), [5582db4f](http://github.com/katello/katello/commit/5582db4fcba098745c2a815021e2d932c1bdf6c5))
 * allow content view filter to specify arch ([#14107](http://projects.theforeman.org/issues/14107), [ccc87494](http://github.com/katello/katello/commit/ccc874945ef77b6060c96e9c5c58abf251f1411e))
 * allow descriptions for content view promotions ([#7612](http://projects.theforeman.org/issues/7612), [1dcbd355](http://github.com/katello/katello/commit/1dcbd355fb41064da9f3bae2bd24411d1a4c3b4b))
 * [RFE] allow multiple CV with same repo to be added to a composite CV ([#6757](http://projects.theforeman.org/issues/6757), [e5586b7e](http://github.com/katello/katello/commit/e5586b7e6bfd07455997fdb1d7651650f9a83154))

### SElinux
 * add 5001 as an alternative docker registry port ([#17059](http://projects.theforeman.org/issues/17059), [8d044444](http://github.com/katello/katello-selinux/commit/8d0444449fe9b3d78680cf1383214c39bd6e790a))

### Candlepin
 * CP 2.0: Phase 1: refactor manifest deletion to be purely dynflow ([#17026](http://projects.theforeman.org/issues/17026), [a8a6ebd3](http://github.com/katello/katello/commit/a8a6ebd3958c33c1eb4aefb0e3b1a037c0435bf5))
 * CP 2.0: Phase 1: refactor manifest import/refresh to be purely dynflow ([#17025](http://projects.theforeman.org/issues/17025), [a8a6ebd3](http://github.com/katello/katello/commit/a8a6ebd3958c33c1eb4aefb0e3b1a037c0435bf5))

### Errata Management
 * Allow access to errata data from templates ([#16857](http://projects.theforeman.org/issues/16857), [3f5a832e](http://github.com/katello/katello/commit/3f5a832e5d8061ea413c677e5f933118a70bf160))

### Foreman Proxy Content
 * add download policy setting to capsules ([#16808](http://projects.theforeman.org/issues/16808), [2824830a](http://github.com/katello/katello/commit/2824830a0295f3bfad994c91284651e3ead4a0b7))

### Puppet
 * add option to force empty puppet environment ([#16756](http://projects.theforeman.org/issues/16756), [41b5f01d](http://github.com/katello/katello/commit/41b5f01db5cbe76269653174cccd1d345320c185))

### Tests
 * Set TargetRubyVersion in rubocop ([#16710](http://projects.theforeman.org/issues/16710), [f22e72f8](http://github.com/katello/katello/commit/f22e72f82b6ba4237d483e33e796b7fa5efbf393))
 * upgrade rubocop to version 0.42 ([#16500](http://projects.theforeman.org/issues/16500), [7b97efac](http://github.com/katello/katello/commit/7b97efac60746ce4aa50b1853500c35e77e10f76))

### Hammer
 * As a CLI user, I should be able to see a list of packages available for update on a content host. ([#16533](http://projects.theforeman.org/issues/16533), [afa1377e](http://github.com/katello/hammer-cli-katello/commit/afa1377efa24deebecac498f0694f56d8af2f2c9))
 * Update to rubocop 0.42 ([#16522](http://projects.theforeman.org/issues/16522), [27f6f3d2](http://github.com/katello/hammer-cli-katello/commit/27f6f3d239b754ac8756685f3da0be7bc29755fd))
 * CLI: Support globs when uploading files to repositories ([#16521](http://projects.theforeman.org/issues/16521), [8ee56453](http://github.com/katello/hammer-cli-katello/commit/8ee5645369e681cf1740d264b04ab243b0e48800))

### Repositories
 * Need ability to add username/password for syncing from upstream repo ([#16481](http://projects.theforeman.org/issues/16481), [fe362081](http://github.com/katello/katello/commit/fe362081787239777f2689dbe27dff7112c17df8))
 * As a user, I should be able to see a list of packages available for update on a system via the api ([#5148](http://projects.theforeman.org/issues/5148), [6fa72c1a](http://github.com/katello/katello/commit/6fa72c1a7f9205abb76464707661218319213ca5), [c3930011](http://github.com/katello/katello/commit/c3930011180ba4c478392c1f057791a6f36ee97f))

### Installer
 * Add katello-service disable/enable to stop/start services loading on boot. ([#16251](http://projects.theforeman.org/issues/16251), [86a1bb71](http://github.com/katello/katello-packaging/commit/86a1bb710f0780ef43ce5ddcb2548f29b7b9621e))

### Docker
 * Manage docker images should show image names ([#9350](http://projects.theforeman.org/issues/9350), [fc7b9417](http://github.com/katello/katello/commit/fc7b94179b4526e60d6ea994bae11f7997ed9094))

### Other
 * make "Red Hat Repositories" page faster by caching/storing data from CDN ([#17696](http://projects.theforeman.org/issues/17696), [2011c57b](http://github.com/katello/katello/commit/2011c57b286b2cad7115291a1b43e0ad468aee84))
 * Remove nutupane from GPG keys pages ([#17144](http://projects.theforeman.org/issues/17144), [8101524c](http://github.com/katello/katello/commit/8101524c5582192235b4d5f58aeeee219e82cc87))
 * Add a mention bot config ([#16924](http://projects.theforeman.org/issues/16924), [52df02e2](http://github.com/katello/katello/commit/52df02e22b2795dc1f2932ba5999fc38b73e2cd7))
 * Please add a hammer ping to the foreman-debug ([#11607](http://projects.theforeman.org/issues/11607), [00a38897](http://github.com/katello//commit/00a388972f7ef97293be2331ca40d73f34e639b7))

## Bug Fixes 

### Installer
 * Need a migration to convert previous invalid 'false' value to undef for dhcp ranges ([#17996](http://projects.theforeman.org/issues/17996), [9da81e4a](http://github.com/katello//commit/9da81e4a02bf689fbf0eb685addeaad4dc128304))
 * Migration is missing to convert `capsule` to `foreman_proxy_content` in answers file ([#17995](http://projects.theforeman.org/issues/17995), [9da81e4a](http://github.com/katello//commit/9da81e4a02bf689fbf0eb685addeaad4dc128304))
 * foreman-proxy-certs-generate fails with no cache of file foreman_proxy_content found ([#17988](http://projects.theforeman.org/issues/17988), [c625f1a4](http://github.com/katello//commit/c625f1a45126cc8cddcdbb784a9a53806962bf4d))
 * No way to enable foreman_discovery_smart_proxy via installer ([#17926](http://projects.theforeman.org/issues/17926), [45ad1621](http://github.com/katello//commit/45ad162133f099e471f068577821168a5ed2771a))
 * Fresh install fails because of missing 'puppet' user ([#17863](http://projects.theforeman.org/issues/17863), [1c8129bf](http://github.com/katello//commit/1c8129bfa1b819a3f1ec1a83d4df3e45fc1dabd6))
 * cache generator deletes all caches that begin with 'foreman' including foreman_proxy_content ([#17710](http://projects.theforeman.org/issues/17710), [893af950](http://github.com/katello/katello-installer/commit/893af950bd1147b715d72cc7a4bd529ff809b885))
 * Katello installer tests are failing ([#17668](http://projects.theforeman.org/issues/17668), [c51a6072](http://github.com/katello/katello-installer/commit/c51a60726e8f4bc51c09d0e303e55f811481d8d8))
 * Upgrade fails if /var/lib/tfpboot/grub2 is not pre-created ([#17639](http://projects.theforeman.org/issues/17639), [9d08de25](http://github.com/katello//commit/9d08de2589d7a3c01f9965fa0aaf5f86be992b9b))
 * capsule installer modules_dir is broken ([#17604](http://projects.theforeman.org/issues/17604), [90a5196d](http://github.com/katello/katello-installer/commit/90a5196dc9702f5796e670f0172f7d15ebe9668f))
 * Katello shouldn't use boolean for foreman::server_ssl_crl value ([#17534](http://projects.theforeman.org/issues/17534), [9893dd96](http://github.com/katello/katello-installer/commit/9893dd9616a9fd9ae61a5b9fa24377e363de7550), [c01ce694](http://github.com/katello/katello-installer/commit/c01ce6945a1802cbeb3676def48f22aaf567f564))
 * We no longer need to delete ssl.conf when we move to the latest puppetlabs-apache version ([#17507](http://projects.theforeman.org/issues/17507), [ef64a148](http://github.com/katello/katello-installer/commit/ef64a14888273ca55e5181f2eec3197c2548bf12))
 * Installation failed - Failed to apply catalog: Found 1 dependency cycle ([#17414](http://projects.theforeman.org/issues/17414))
 * CA cert file is not configured for Candlepin communication ([#17380](http://projects.theforeman.org/issues/17380), [46216f7d](http://github.com/katello/puppet-katello/commit/46216f7d74e0cf5bc43a6ffdb322af885818fbbe))
 * group: foreman was removed from certs ([#17278](http://projects.theforeman.org/issues/17278), [145ccfe4](http://github.com/katello/katello-installer/commit/145ccfe472880a299658a1b05b2da0c7fc1472c2))
 * Sync migrations and answers ([#17201](http://projects.theforeman.org/issues/17201), [0174992d](http://github.com/katello/katello-installer/commit/0174992d0cf90fe577d0c8cf2d005eefe7bd2391), [eb38e664](http://github.com/katello/katello-installer/commit/eb38e6647aa6fe0dd0959a2e666d7258378d8fed), [a53fad63](http://github.com/katello/katello-packaging/commit/a53fad639654bcbdd2db3b853bb7768f3cbd6a8d))
 * Rubocop failing on installer ([#17138](http://projects.theforeman.org/issues/17138), [4cead21b](http://github.com/katello/katello-installer/commit/4cead21b8a0c4272cbd787d4bae836aa4d15b822))
 * Installer upgrade should only perform pre upgrade steps once ([#17092](http://projects.theforeman.org/issues/17092), [cbdace60](http://github.com/katello/katello-installer/commit/cbdace605427885a0773ed7a1dd9383748cd9fe1))
 * Satellite 6 can't be installed if syslog not running - /dev/log does not exist ([#16778](http://projects.theforeman.org/issues/16778), [76b11e65](http://github.com/katello/katello-installer/commit/76b11e652f867143110b16f7d033d0b902d089f9))
 * -capsule-puppet false doesnt work ([#16751](http://projects.theforeman.org/issues/16751))
 * katello-installer requires kafo 0.9.3 or later, should be 1.0.1 or later ([#16611](http://projects.theforeman.org/issues/16611), [ca70b317](http://github.com/katello/katello-installer/commit/ca70b317748501454053100326a44a33cdfd0a24))
 * capsule-certs-generate does not look at katello-installer-base path, script does not work on dev installs ([#16541](http://projects.theforeman.org/issues/16541), [c84a264d](http://github.com/katello/katello-installer/commit/c84a264d59f979d966459e5897fcde316febb504))
 * Qpid should only listen on localhost ([#11737](http://projects.theforeman.org/issues/11737), [8c6812cc](http://github.com/katello/puppet-capsule/commit/8c6812cc4e06572df1b757315f65916bb602e67c), [59857e16](http://github.com/katello/puppet-certs/commit/59857e16dccbeb6e9546179f1965560ccf9a674c), [37749e81](http://github.com/katello/puppet-katello/commit/37749e8182f007c653fba128d8e37d5a659f9e71), [b4d7ebf5](http://github.com/katello/katello-installer/commit/b4d7ebf5694976640a0ded556ed72f1dc105025b))
 * unable to install katello with puppet 4 ([#17376](http://projects.theforeman.org/issues/17376))

### Puppet
 * After upgrade Content View loses puppet modules ([#17987](http://projects.theforeman.org/issues/17987), [7634303d](http://github.com/katello//commit/7634303df553f400edd03b30686eda8a2e3e8a0e))

### Provisioning
 * Network snippets missing from atomic kickstart ([#17924](http://projects.theforeman.org/issues/17924), [a0ccc0d5](http://github.com/katello//commit/a0ccc0d575ee6c7779bfcc1070571e266c9bbb0a))

### Content Views
 * Content view filter cannot distinguish between multiple packages with the same version but different release number ([#17916](http://projects.theforeman.org/issues/17916), [bafd8b82](http://github.com/katello//commit/bafd8b82c581ef87add58af25b37b1ff9ace07d9))
 * incremental update fails with "NoMethodError: undefined method `each' for #<Katello::KTEnvironment:>" ([#17628](http://projects.theforeman.org/issues/17628), [475df1d9](http://github.com/katello/katello/commit/475df1d94904409a0becc4f7fe52529bf3fe3e14))
 * CV Publish failing for combination of repos ([#17610](http://projects.theforeman.org/issues/17610), [648336c3](http://github.com/katello/katello/commit/648336c3d8e2bef0f0c9c83904b7791a624f73d9))
 * As a user, I want to create content view filters for tags in docker repos. ([#17293](http://projects.theforeman.org/issues/17293), [d9361888](http://github.com/katello//commit/d93618882f0091b90018c2264765a8d098d3927e))
 * Content view erratum filter by date: default types to all ([#17108](http://projects.theforeman.org/issues/17108), [15a4ac65](http://github.com/katello/katello/commit/15a4ac65790581f50a63306fc9f2e901cf630cc1))
 * Inconsistent data type and format for version info in API ([#16757](http://projects.theforeman.org/issues/16757), [7de7533f](http://github.com/katello/katello/commit/7de7533f6073eac422e309b3f6ea018219708979))
 * Content view histories lose their type after clearing out foreman tasks ([#16673](http://projects.theforeman.org/issues/16673), [56b7973c](http://github.com/katello/katello/commit/56b7973cd1cd91aa73003ceb996353ebff285419), [e96f76e4](http://github.com/katello/katello/commit/e96f76e4a3408f213c24672b66c29cdf64f36b85))
 * the alignment for the confirmation buttons for deleting a content view is off ([#16272](http://projects.theforeman.org/issues/16272), [249445c0](http://github.com/katello//commit/249445c086c1e8f016ebf25b0cf13875536f1726))
 * Content View: Repository sync and content information are blank for a newly enabled repository ([#16265](http://projects.theforeman.org/issues/16265), [25d6f29f](http://github.com/katello/katello/commit/25d6f29f21196fcf1594ca2f0e9bf073dc692cb4))

### Web UI
 * katello needs to require bastion 4.0.0 ([#17912](http://projects.theforeman.org/issues/17912), [6fe9180e](http://github.com/katello/katello/commit/6fe9180e171e6607e61a29780a51ec19e6db7824))
 * Some tables still have Deselect All link active with nothing selected ([#17685](http://projects.theforeman.org/issues/17685), [871ef7dc](http://github.com/katello/katello/commit/871ef7dc41d3dd599a732bfc909bb5b807896fc7))
 * product table name link should link directly to repositories ([#17371](http://projects.theforeman.org/issues/17371), [440121d4](http://github.com/katello/katello/commit/440121d40a58723c0bb363dc2a6447ccb4e54b98))
 * Dashboard Content Host Subscription Status Links are not URI encoded ([#17227](http://projects.theforeman.org/issues/17227), [4e6744dd](http://github.com/katello/katello/commit/4e6744dd462d613667c746c53c062c9300019500), [79ed3c6b](http://github.com/katello/katello/commit/79ed3c6b12b014dc4a8cbfff5f41f637bfa4d7c3))
 * upradable package list shows all applicable packages ([#16902](http://projects.theforeman.org/issues/16902), [b6c4c7af](http://github.com/katello/katello/commit/b6c4c7af866185082572307236a522e8bf01cd6d))
 * Fix the case of the menu items in Katello (e.g. "Sync Status" vs "Activation keys") ([#16589](http://projects.theforeman.org/issues/16589), [b4c0cb9e](http://github.com/katello/katello/commit/b4c0cb9e761d26180d06160ab7a375b94cb33a09))
 * add step up polling interval for UI task polling ([#16575](http://projects.theforeman.org/issues/16575), [b19a24e7](http://github.com/katello/katello/commit/b19a24e7b96c203364b537f8a321c5b67d8ff1b6))
 * Lifecycle environments not redirecting to 404 ([#16246](http://projects.theforeman.org/issues/16246), [b481e2ae](http://github.com/katello/katello/commit/b481e2aecb210c42e1dd6857b2ae9ee59e8f92a7))
 * "Error: Request Timeout" from hammer when asked to show >400 content hosts ([#16010](http://projects.theforeman.org/issues/16010), [80ebe622](http://github.com/katello/katello/commit/80ebe622e8820a2aa8f9db0c78a90b9369971e6c))
 * GPG list not sorted in product/repository GPG key picklist ([#8455](http://projects.theforeman.org/issues/8455), [d3b38297](http://github.com/katello/katello/commit/d3b38297e9a499adc85d7ae76964552aba59ab10))

### Hosts
 * Getting undefined method `name' for nil:NilClass when trying edit/view a host group ([#17815](http://projects.theforeman.org/issues/17815), [a3d89422](http://github.com/katello/katello/commit/a3d8942292fef71ab4d494208f1970b361664f93))
 * Display package applicability for a single host ([#16637](http://projects.theforeman.org/issues/16637), [940bd79d](http://github.com/katello/katello/commit/940bd79d5703a81997d8f7621084693f719d36ab))
 * New host creation ignores permissions for lifecycle envs, content views, and conent sources (smart proxies) ([#17176](http://projects.theforeman.org/issues/17176), [b5202aef](http://github.com/katello//commit/b5202aefc6fc40124aa781dfc50fbcc1b42f2503))

### Tests
 * fix rubocop 0.46 errors ([#17805](http://projects.theforeman.org/issues/17805), [5043f5c8](http://github.com/katello/katello/commit/5043f5c8168d35e6ae0f0ad62ef76443e648c9b4))
 * CapsuleContent Test fails during the month of december ([#17557](http://projects.theforeman.org/issues/17557), [519b940d](http://github.com/katello/katello/commit/519b940dd7adc5da87bc2ac4bcdefcb2d3a103b4))
 * populating test DB fails on fresh install ([#17550](http://projects.theforeman.org/issues/17550), [be8ede9e](http://github.com/katello/katello/commit/be8ede9e056ff41181aa8e87be956844ed122b2e))
 * add access permission tests to katello ([#16998](http://projects.theforeman.org/issues/16998), [e23255a8](http://github.com/katello/katello/commit/e23255a8981bc1ffc12d0110cf02dea79416b3ce))

### Subscriptions
 * handle pool stackingId in an org-safe manner ([#17789](http://projects.theforeman.org/issues/17789), [ca671e34](http://github.com/katello/katello/commit/ca671e34d0deea9e34dd37f38c3d9f704e774a8e))
 * server_status to call CandlepinPing.ping just once ([#16870](http://projects.theforeman.org/issues/16870), [6343a0a2](http://github.com/katello/katello/commit/6343a0a283591f1bdd1f0c49049d96696ed29eb5))

### Repositories
 * Keyboard tab doesnt function well with Products or Repository page ([#17787](http://projects.theforeman.org/issues/17787), [2b95d5d6](http://github.com/katello/katello/commit/2b95d5d689e7fd139b372611e3cb37c4a52c959b))
 * Repository new and edit pages list no download poilicies to select ([#17542](http://projects.theforeman.org/issues/17542), [7d7429ce](http://github.com/katello/katello/commit/7d7429ce5b7334394e4875833b13825b3341f57e))
 * sync product repo does not switch to task page ([#17523](http://projects.theforeman.org/issues/17523), [4b43ca57](http://github.com/katello/katello/commit/4b43ca5730f13d5e632fc1887b8b680109d76f34))
 * Synchronizing a repository with large amount rpms causes large memory usages while indexing ([#17512](http://projects.theforeman.org/issues/17512), [e5cd23c7](http://github.com/katello/katello/commit/e5cd23c7a8c6e329bdc140266e2dc4e70347e239))
 * pulp communication relies on system wide store rather than specifying CA path ([#17400](http://projects.theforeman.org/issues/17400), [f559725c](http://github.com/katello/katello/commit/f559725cdd1173b0c0d2b111dbc6b0120d4a000a), [264a110f](http://github.com/katello/puppet-katello/commit/264a110ff306ccf4f713aae034db847a0c2f74bc))
 * new repository button does not go to new repository page ([#17388](http://projects.theforeman.org/issues/17388), [3979337f](http://github.com/katello/katello/commit/3979337f6b8d69cccba4767ea59c56380629b228))
 * errata apply task does not show installed/updated packages  ([#17233](http://projects.theforeman.org/issues/17233), [e05874cf](http://github.com/katello/katello/commit/e05874cfe7ae75730e0ea401f5dd08ccc297310a))
 * repository delete by name neither allows to delete repo w/o org nor accepts the org ([#16730](http://projects.theforeman.org/issues/16730), [7f4d6b79](http://github.com/katello/hammer-cli-katello/commit/7f4d6b794b3c0c119cfd41778e70cb7f936bb124))

### Foreman Proxy Content
 * API/CLI - ISE on Deleting proxy: Can't modify frozen hash ([#17784](http://projects.theforeman.org/issues/17784), [3d8abda4](http://github.com/katello/katello/commit/3d8abda434f21e4f2cb4fc33cb7f1dce9efc77e1))
 * Replace all instances of Capsule with Smart Proxy in Katello UI ([#17601](http://projects.theforeman.org/issues/17601), [738d54ad](http://github.com/katello/katello/commit/738d54ad15fc64afe4975113973877575cde8a77))

### Client/Agent
 * reinstalling katello-ca-consumer on RHEL7 Content Host does not restart goferd service ([#17658](http://projects.theforeman.org/issues/17658), [5e02f1e7](http://github.com/katello/puppet-certs/commit/5e02f1e7b8ad4888247c6a0b2c44cd1b6cbb151a))
 * tracer upload yum plugin should look at all pkgs  ([#17359](http://projects.theforeman.org/issues/17359), [03c9eb82](http://github.com/katello/katello-agent/commit/03c9eb82745e966e5be2969c18727d51176d9dc5))
 * systems where 'hostname -f' returns an error fails registration ([#17721](http://projects.theforeman.org/issues/17721), [1544376d](http://github.com/katello/puppet-certs/commit/1544376db06fbe9b73e412758f67b00bd4870915))

### Candlepin
 * Improve ListenOnCandlepinEvents throughput ([#17498](http://projects.theforeman.org/issues/17498), [55677460](http://github.com/katello/katello/commit/55677460eea47e2d34a04364b485daaf59296cdc), [87ef553c](http://github.com/katello/katello/commit/87ef553cfe840299389abbb4123a640c2227e0bb))
 * trigger debug cert generation during org creation ([#16978](http://projects.theforeman.org/issues/16978), [9eb73f03](http://github.com/katello/katello/commit/9eb73f03232b42749d6dce1c4dba4fc243002c6a))

### API
 * Remove duplicate permission code from product api ([#17481](http://projects.theforeman.org/issues/17481), [c3019887](http://github.com/katello/katello/commit/c3019887587b5d42239405de765b7920d6f41eeb))
 * Katello API : POST /katello/api/v2/content_view_versions/:id/promote results in NoMethodError ([#16745](http://projects.theforeman.org/issues/16745), [ce140802](http://github.com/katello/katello/commit/ce140802145e328548c0e0c2e9e9fac7a307cd1f))

### Lifecycle Environments
 * Puppet module appear in content view but doesn't appear in lifecycle environment ([#17402](http://projects.theforeman.org/issues/17402), [13f1896c](http://github.com/katello/katello/commit/13f1896ccec51492593394cf137b5070ad28974b))

### Docker
 * Associating docker tag with incorrect docker manifest. ([#17317](http://projects.theforeman.org/issues/17317), [806a8e4e](http://github.com/katello/katello/commit/806a8e4e0c19e75cfffb0de96beb0eb3ca3d3794), [beb1cd36](http://github.com/katello/katello/commit/beb1cd36c67c3566a36367bad503352fa0beb9fb))
 * Improve UI details for docker tags ([#17186](http://projects.theforeman.org/issues/17186), [b8eae753](http://github.com/katello/katello/commit/b8eae75360cf02fd69201eb8b309b17d2375cc54))
 * docker tags page only shows tag not full name  ([#16851](http://projects.theforeman.org/issues/16851), [0c37e226](http://github.com/katello/katello/commit/0c37e226676417187e76c5d3252ba2656bc9b13c))

### Documentation
 * hard linebreaks in developer docs on katello.org ([#16875](http://projects.theforeman.org/issues/16875), [e6211945](http://github.com/katello//commit/e62119451cae6082f65630b85a727a3e28b5d25e))

### Hammer
 * hammer package list with organization fails ([#16793](http://projects.theforeman.org/issues/16793), [6a37d966](http://github.com/katello/hammer-cli-katello/commit/6a37d966687d7507dd3ea6acf84ec1912e96ebee))

### Tooling
 * "katello-service restart" does not restart goferd on Capsule ([#16586](http://projects.theforeman.org/issues/16586), [a5ee1f2a](http://github.com/katello/katello-packaging/commit/a5ee1f2af886293faf6bdd55f221328929277f52))

### Roles and Permissions
 * Unable to create a repository as non-admin user  ([#16505](http://projects.theforeman.org/issues/16505), [4506461b](http://github.com/katello/katello/commit/4506461b920f837d1097963f8c8361ac60a47fbf), [48caa6f1](http://github.com/katello/katello/commit/48caa6f12e62d19547aad52f5d7bd5a831edd81f))

### Errata Management
 * Handle errata status with Library vs current environment ([#12347](http://projects.theforeman.org/issues/12347), [a75565df](http://github.com/katello/katello/commit/a75565df0b98c64efe33874f0544034071e6b1c6))

### Upgrades
 * upgrade failed at update_subscription_facet_backend_data (undefined method `inject' for nil:NilClass) ([#17612](http://projects.theforeman.org/issues/17612), [4f414f3d](http://github.com/katello//commit/4f414f3d37ea05ee7529759acb130112814b50a7))

### Other
 * katello:check_ping should load environment ([#17719](http://projects.theforeman.org/issues/17719), [54a25322](http://github.com/katello/katello/commit/54a25322994ee1f52e34d921afc634bd7f91cc94))
 * Red hat repositories is too slow ([#17718](http://projects.theforeman.org/issues/17718), [3611988b](http://github.com/katello/katello/commit/3611988b252cc3450b2cf8ef53a26bd3b5eb43db))
 * Hostgroup create/update does not accept --lifecycle-environment parameter ([#17619](http://projects.theforeman.org/issues/17619), [6581e356](http://github.com/katello/hammer-cli-katello/commit/6581e356a0cbe5f87c5785dccc8da816f51f8d8a))
 * Incremental update results in "undefined method description=" for ContentViewVersion ([#17584](http://projects.theforeman.org/issues/17584), [61273472](http://github.com/katello/katello/commit/61273472750db53839c06535f793326bff688d81))
 * Backend data should not be initialized in database seeds ([#17465](http://projects.theforeman.org/issues/17465), [5cd70f08](http://github.com/katello/katello/commit/5cd70f08aa47d127fdacaf025b1c1940f976198d))
 * Refactor Ping model to address method length and branching ([#17382](http://projects.theforeman.org/issues/17382), [9a65a4f8](http://github.com/katello/katello/commit/9a65a4f805616b7c66e326ab18f69b4818fd21d6))
 * Specifying ca_cert_file for Candlepin fails with SSL verify error ([#17379](http://projects.theforeman.org/issues/17379), [a424a710](http://github.com/katello/katello/commit/a424a710b117976f4a4fdc89450c61b99f7357cc))
 * Improve the error message when a repository does not exist for a certain architecture / and version ([#17181](http://projects.theforeman.org/issues/17181), [c204cba3](http://github.com/katello/katello/commit/c204cba3b3bbbb4e8b1e9eaeff88c081dcb9a56c))
 * foreman-debug to collect whole newest (log)files instead of tailing all (log)files ([#17114](http://projects.theforeman.org/issues/17114), [4ff859b6](http://github.com/katello/katello-packaging/commit/4ff859b6ef71f25d426d63cf7b336f87cae7488c))
 * hammer content-view filter list is missing --organization parameter ([#16794](http://projects.theforeman.org/issues/16794), [463c7d63](http://github.com/katello/hammer-cli-katello/commit/463c7d63acb0ae1901cbbc0d45ac189a1da16fb2))
 * Dashboard names and titles are inconsistent ([#16679](http://projects.theforeman.org/issues/16679), [cfa911c6](http://github.com/katello//commit/cfa911c6827fff885c54044c31c76a51e1b94c0c))
 * Unattended template doesn't call 'built' ([#17903](http://projects.theforeman.org/issues/17903), [d3541c40](http://github.com/katello/katello/commit/d3541c40379d9dab7f4511199c0f9a0b1228d183))
# 3.3 Baltic Porter (2017-01-11)

## Features 

### Settings
 * Change the description of "unregister_delete_host" parameter under Administer -> Settings -> Katello. ([#17745](http://projects.theforeman.org/issues/17745), [f11051c6](http://github.com/katello/katello/commit/f11051c6b34e2415d8710b56a60e5319465dc23d))

### Web UI
 * Remove Nutupane from Packages pages ([#17637](http://projects.theforeman.org/issues/17637), [d590b887](http://github.com/katello/katello/commit/d590b887e7f68145376b0f6c951784602a8d1fe9))
 * Move katello to normal bs3 forms instead of horizontal forms ([#17386](http://projects.theforeman.org/issues/17386), [d88eb116](http://github.com/katello/katello/commit/d88eb1164af7f2402c75adc28fecf3be6739342c))
 * Remove Nutupane from Host Collection pages ([#17169](http://projects.theforeman.org/issues/17169), [1eb4eb4b](http://github.com/katello/katello/commit/1eb4eb4b33fc72822fd98e793c88c3d3b6c94b78))
 * Remove Nutupane from Docker Tags pages ([#17166](http://projects.theforeman.org/issues/17166), [e2d220f1](http://github.com/katello/katello/commit/e2d220f1624fdea91db3216e10847ad7a23bf8b9), [7e12805a](http://github.com/katello/katello/commit/7e12805aeb375d3277d90da18a18c8636051b0e1))
 * Remove Nutupane from Content View pages ([#17162](http://projects.theforeman.org/issues/17162), [08363567](http://github.com/katello/katello/commit/083635675b8a0cd0916ccedf286ae73d22039d8a))
 * Remove Nutupane from Sync Plan pages ([#17161](http://projects.theforeman.org/issues/17161), [61716296](http://github.com/katello/katello/commit/6171629655c8db96db41a8dda6c25c6d61a65dd8))
 * Remove Nutupane from Activation Keys pages ([#17160](http://projects.theforeman.org/issues/17160), [fbe5322c](http://github.com/katello/katello/commit/fbe5322c3d16952957469a8d2fa21dab87197c0f))
 * Remove Nutupane from subscriptions pages ([#17159](http://projects.theforeman.org/issues/17159), [cc43c9e3](http://github.com/katello/katello/commit/cc43c9e3c2873fd2293fc626c526c9bf7f80921d))
 * show upgradable package count in content hosts list ([#16724](http://projects.theforeman.org/issues/16724), [534baf8e](http://github.com/katello/katello/commit/534baf8e337421a0f6f3028e73eeaef94f239622))
 * Display subscription-manager fact origin ([#16715](http://projects.theforeman.org/issues/16715), [f9db71a6](http://github.com/katello/katello/commit/f9db71a6d331325fe58ae822507811b416bddc7b))

### Hosts
 * Expose PUT /rhsm to user credentials so facts may be updated in candlepin ([#17444](http://projects.theforeman.org/issues/17444), [39f0a341](http://github.com/katello/katello/commit/39f0a34109112d42a5606e44c06d644339c69838))

### Content Views
 * Publish a CV with a puppet module raising NoMethodError with locations disabled ([#17281](http://projects.theforeman.org/issues/17281), [fc9311ed](http://github.com/katello/katello/commit/fc9311ed6022fdd7afea412fcb4ca2b58ccbc95a))
 * API: Allow promotion of content views to multiple environments ([#16638](http://projects.theforeman.org/issues/16638), [506f569d](http://github.com/katello/katello/commit/506f569d8440640043bc7abdc20738b209cddbce), [2b28d376](http://github.com/katello/katello/commit/2b28d376c31f1afca683a78c63a7b866e8cd1339))
 * Composite Content View Web UI: provide indication if a newer component version is available ([#16503](http://projects.theforeman.org/issues/16503), [5782bcfa](http://github.com/katello/katello/commit/5782bcfa0df5397081a79b2df953e6b764fa1b2f))
 * Incremental Update should set description for content view ([#16502](http://projects.theforeman.org/issues/16502), [adf12b3a](http://github.com/katello/katello/commit/adf12b3a931b7004eba202bad3cc0e1c908d6ed5))
 * Would like a hammer cli to add components to cv ([#15965](http://projects.theforeman.org/issues/15965), [8f74a5d1](http://github.com/katello/hammer-cli-katello/commit/8f74a5d145bf11544e4b781acfca393a50d0725d))
 * Add ability to publish "latest version" in a composite view ([#15950](http://projects.theforeman.org/issues/15950), [5582db4f](http://github.com/katello/katello/commit/5582db4fcba098745c2a815021e2d932c1bdf6c5))
 * allow content view filter to specify arch ([#14107](http://projects.theforeman.org/issues/14107), [ccc87494](http://github.com/katello/katello/commit/ccc874945ef77b6060c96e9c5c58abf251f1411e))
 * allow descriptions for content view promotions ([#7612](http://projects.theforeman.org/issues/7612), [1dcbd355](http://github.com/katello/katello/commit/1dcbd355fb41064da9f3bae2bd24411d1a4c3b4b))
 * [RFE] allow multiple CV with same repo to be added to a composite CV ([#6757](http://projects.theforeman.org/issues/6757), [e5586b7e](http://github.com/katello/katello/commit/e5586b7e6bfd07455997fdb1d7651650f9a83154))

### SElinux
 * add 5001 as an alternative docker registry port ([#17059](http://projects.theforeman.org/issues/17059), [8d044444](http://github.com/katello/katello-selinux/commit/8d0444449fe9b3d78680cf1383214c39bd6e790a))

### Candlepin
 * CP 2.0: Phase 1: refactor manifest deletion to be purely dynflow ([#17026](http://projects.theforeman.org/issues/17026), [a8a6ebd3](http://github.com/katello/katello/commit/a8a6ebd3958c33c1eb4aefb0e3b1a037c0435bf5))
 * CP 2.0: Phase 1: refactor manifest import/refresh to be purely dynflow ([#17025](http://projects.theforeman.org/issues/17025), [a8a6ebd3](http://github.com/katello/katello/commit/a8a6ebd3958c33c1eb4aefb0e3b1a037c0435bf5))

### Errata Management
 * Allow access to errata data from templates ([#16857](http://projects.theforeman.org/issues/16857), [3f5a832e](http://github.com/katello/katello/commit/3f5a832e5d8061ea413c677e5f933118a70bf160))

### Foreman Proxy Content
 * add download policy setting to capsules ([#16808](http://projects.theforeman.org/issues/16808), [2824830a](http://github.com/katello/katello/commit/2824830a0295f3bfad994c91284651e3ead4a0b7))

### Puppet
 * add option to force empty puppet environment ([#16756](http://projects.theforeman.org/issues/16756), [41b5f01d](http://github.com/katello/katello/commit/41b5f01db5cbe76269653174cccd1d345320c185))

### Tests
 * Set TargetRubyVersion in rubocop ([#16710](http://projects.theforeman.org/issues/16710), [f22e72f8](http://github.com/katello/katello/commit/f22e72f82b6ba4237d483e33e796b7fa5efbf393))
 * upgrade rubocop to version 0.42 ([#16500](http://projects.theforeman.org/issues/16500), [7b97efac](http://github.com/katello/katello/commit/7b97efac60746ce4aa50b1853500c35e77e10f76))

### Hammer
 * As a CLI user, I should be able to see a list of packages available for update on a content host. ([#16533](http://projects.theforeman.org/issues/16533), [afa1377e](http://github.com/katello/hammer-cli-katello/commit/afa1377efa24deebecac498f0694f56d8af2f2c9))
 * Update to rubocop 0.42 ([#16522](http://projects.theforeman.org/issues/16522), [27f6f3d2](http://github.com/katello/hammer-cli-katello/commit/27f6f3d239b754ac8756685f3da0be7bc29755fd))
 * CLI: Support globs when uploading files to repositories ([#16521](http://projects.theforeman.org/issues/16521), [8ee56453](http://github.com/katello/hammer-cli-katello/commit/8ee5645369e681cf1740d264b04ab243b0e48800))

### Repositories
 * Need ability to add username/password for syncing from upstream repo ([#16481](http://projects.theforeman.org/issues/16481), [fe362081](http://github.com/katello/katello/commit/fe362081787239777f2689dbe27dff7112c17df8))
 * As a user, I should be able to see a list of packages available for update on a system via the api ([#5148](http://projects.theforeman.org/issues/5148), [6fa72c1a](http://github.com/katello/katello/commit/6fa72c1a7f9205abb76464707661218319213ca5), [c3930011](http://github.com/katello/katello/commit/c3930011180ba4c478392c1f057791a6f36ee97f))

### Installer
 * Add katello-service disable/enable to stop/start services loading on boot. ([#16251](http://projects.theforeman.org/issues/16251), [86a1bb71](http://github.com/katello/katello-packaging/commit/86a1bb710f0780ef43ce5ddcb2548f29b7b9621e))

### Docker
 * Manage docker images should show image names ([#9350](http://projects.theforeman.org/issues/9350), [fc7b9417](http://github.com/katello/katello/commit/fc7b94179b4526e60d6ea994bae11f7997ed9094))

### Other
 * make "Red Hat Repositories" page faster by caching/storing data from CDN ([#17696](http://projects.theforeman.org/issues/17696), [2011c57b](http://github.com/katello/katello/commit/2011c57b286b2cad7115291a1b43e0ad468aee84))
 * Remove nutupane from GPG keys pages ([#17144](http://projects.theforeman.org/issues/17144), [8101524c](http://github.com/katello/katello/commit/8101524c5582192235b4d5f58aeeee219e82cc87))
 * Add a mention bot config ([#16924](http://projects.theforeman.org/issues/16924), [52df02e2](http://github.com/katello/katello/commit/52df02e22b2795dc1f2932ba5999fc38b73e2cd7))
 * Please add a hammer ping to the foreman-debug ([#11607](http://projects.theforeman.org/issues/11607), [00a38897](http://github.com/katello//commit/00a388972f7ef97293be2331ca40d73f34e639b7))

## Bug Fixes 

### Installer
 * Need a migration to convert previous invalid 'false' value to undef for dhcp ranges ([#17996](http://projects.theforeman.org/issues/17996), [9da81e4a](http://github.com/katello//commit/9da81e4a02bf689fbf0eb685addeaad4dc128304))
 * Migration is missing to convert `capsule` to `foreman_proxy_content` in answers file ([#17995](http://projects.theforeman.org/issues/17995), [9da81e4a](http://github.com/katello//commit/9da81e4a02bf689fbf0eb685addeaad4dc128304))
 * foreman-proxy-certs-generate fails with no cache of file foreman_proxy_content found ([#17988](http://projects.theforeman.org/issues/17988), [c625f1a4](http://github.com/katello//commit/c625f1a45126cc8cddcdbb784a9a53806962bf4d))
 * No way to enable foreman_discovery_smart_proxy via installer ([#17926](http://projects.theforeman.org/issues/17926), [45ad1621](http://github.com/katello//commit/45ad162133f099e471f068577821168a5ed2771a))
 * Fresh install fails because of missing 'puppet' user ([#17863](http://projects.theforeman.org/issues/17863), [1c8129bf](http://github.com/katello//commit/1c8129bfa1b819a3f1ec1a83d4df3e45fc1dabd6))
 * cache generator deletes all caches that begin with 'foreman' including foreman_proxy_content ([#17710](http://projects.theforeman.org/issues/17710), [893af950](http://github.com/katello/katello-installer/commit/893af950bd1147b715d72cc7a4bd529ff809b885))
 * Katello installer tests are failing ([#17668](http://projects.theforeman.org/issues/17668), [c51a6072](http://github.com/katello/katello-installer/commit/c51a60726e8f4bc51c09d0e303e55f811481d8d8))
 * Upgrade fails if /var/lib/tfpboot/grub2 is not pre-created ([#17639](http://projects.theforeman.org/issues/17639), [9d08de25](http://github.com/katello//commit/9d08de2589d7a3c01f9965fa0aaf5f86be992b9b))
 * capsule installer modules_dir is broken ([#17604](http://projects.theforeman.org/issues/17604), [90a5196d](http://github.com/katello/katello-installer/commit/90a5196dc9702f5796e670f0172f7d15ebe9668f))
 * Katello shouldn't use boolean for foreman::server_ssl_crl value ([#17534](http://projects.theforeman.org/issues/17534), [9893dd96](http://github.com/katello/katello-installer/commit/9893dd9616a9fd9ae61a5b9fa24377e363de7550), [c01ce694](http://github.com/katello/katello-installer/commit/c01ce6945a1802cbeb3676def48f22aaf567f564))
 * We no longer need to delete ssl.conf when we move to the latest puppetlabs-apache version ([#17507](http://projects.theforeman.org/issues/17507), [ef64a148](http://github.com/katello/katello-installer/commit/ef64a14888273ca55e5181f2eec3197c2548bf12))
 * Installation failed - Failed to apply catalog: Found 1 dependency cycle ([#17414](http://projects.theforeman.org/issues/17414))
 * CA cert file is not configured for Candlepin communication ([#17380](http://projects.theforeman.org/issues/17380), [46216f7d](http://github.com/katello/puppet-katello/commit/46216f7d74e0cf5bc43a6ffdb322af885818fbbe))
 * group: foreman was removed from certs ([#17278](http://projects.theforeman.org/issues/17278), [145ccfe4](http://github.com/katello/katello-installer/commit/145ccfe472880a299658a1b05b2da0c7fc1472c2))
 * Sync migrations and answers ([#17201](http://projects.theforeman.org/issues/17201), [0174992d](http://github.com/katello/katello-installer/commit/0174992d0cf90fe577d0c8cf2d005eefe7bd2391), [eb38e664](http://github.com/katello/katello-installer/commit/eb38e6647aa6fe0dd0959a2e666d7258378d8fed), [a53fad63](http://github.com/katello/katello-packaging/commit/a53fad639654bcbdd2db3b853bb7768f3cbd6a8d))
 * Rubocop failing on installer ([#17138](http://projects.theforeman.org/issues/17138), [4cead21b](http://github.com/katello/katello-installer/commit/4cead21b8a0c4272cbd787d4bae836aa4d15b822))
 * Installer upgrade should only perform pre upgrade steps once ([#17092](http://projects.theforeman.org/issues/17092), [cbdace60](http://github.com/katello/katello-installer/commit/cbdace605427885a0773ed7a1dd9383748cd9fe1))
 * Satellite 6 can't be installed if syslog not running - /dev/log does not exist ([#16778](http://projects.theforeman.org/issues/16778), [76b11e65](http://github.com/katello/katello-installer/commit/76b11e652f867143110b16f7d033d0b902d089f9))
 * -capsule-puppet false doesnt work ([#16751](http://projects.theforeman.org/issues/16751))
 * katello-installer requires kafo 0.9.3 or later, should be 1.0.1 or later ([#16611](http://projects.theforeman.org/issues/16611), [ca70b317](http://github.com/katello/katello-installer/commit/ca70b317748501454053100326a44a33cdfd0a24))
 * capsule-certs-generate does not look at katello-installer-base path, script does not work on dev installs ([#16541](http://projects.theforeman.org/issues/16541), [c84a264d](http://github.com/katello/katello-installer/commit/c84a264d59f979d966459e5897fcde316febb504))
 * Qpid should only listen on localhost ([#11737](http://projects.theforeman.org/issues/11737), [8c6812cc](http://github.com/katello/puppet-capsule/commit/8c6812cc4e06572df1b757315f65916bb602e67c), [59857e16](http://github.com/katello/puppet-certs/commit/59857e16dccbeb6e9546179f1965560ccf9a674c), [37749e81](http://github.com/katello/puppet-katello/commit/37749e8182f007c653fba128d8e37d5a659f9e71), [b4d7ebf5](http://github.com/katello/katello-installer/commit/b4d7ebf5694976640a0ded556ed72f1dc105025b))
 * unable to install katello with puppet 4 ([#17376](http://projects.theforeman.org/issues/17376))

### Puppet
 * After upgrade Content View loses puppet modules ([#17987](http://projects.theforeman.org/issues/17987), [7634303d](http://github.com/katello//commit/7634303df553f400edd03b30686eda8a2e3e8a0e))

### Provisioning
 * Network snippets missing from atomic kickstart ([#17924](http://projects.theforeman.org/issues/17924), [a0ccc0d5](http://github.com/katello//commit/a0ccc0d575ee6c7779bfcc1070571e266c9bbb0a))

### Content Views
 * Content view filter cannot distinguish between multiple packages with the same version but different release number ([#17916](http://projects.theforeman.org/issues/17916), [bafd8b82](http://github.com/katello//commit/bafd8b82c581ef87add58af25b37b1ff9ace07d9))
 * incremental update fails with "NoMethodError: undefined method `each' for #<Katello::KTEnvironment:>" ([#17628](http://projects.theforeman.org/issues/17628), [475df1d9](http://github.com/katello/katello/commit/475df1d94904409a0becc4f7fe52529bf3fe3e14))
 * CV Publish failing for combination of repos ([#17610](http://projects.theforeman.org/issues/17610), [648336c3](http://github.com/katello/katello/commit/648336c3d8e2bef0f0c9c83904b7791a624f73d9))
 * As a user, I want to create content view filters for tags in docker repos. ([#17293](http://projects.theforeman.org/issues/17293), [d9361888](http://github.com/katello//commit/d93618882f0091b90018c2264765a8d098d3927e))
 * Content view erratum filter by date: default types to all ([#17108](http://projects.theforeman.org/issues/17108), [15a4ac65](http://github.com/katello/katello/commit/15a4ac65790581f50a63306fc9f2e901cf630cc1))
 * Inconsistent data type and format for version info in API ([#16757](http://projects.theforeman.org/issues/16757), [7de7533f](http://github.com/katello/katello/commit/7de7533f6073eac422e309b3f6ea018219708979))
 * Content view histories lose their type after clearing out foreman tasks ([#16673](http://projects.theforeman.org/issues/16673), [56b7973c](http://github.com/katello/katello/commit/56b7973cd1cd91aa73003ceb996353ebff285419), [e96f76e4](http://github.com/katello/katello/commit/e96f76e4a3408f213c24672b66c29cdf64f36b85))
 * the alignment for the confirmation buttons for deleting a content view is off ([#16272](http://projects.theforeman.org/issues/16272), [249445c0](http://github.com/katello//commit/249445c086c1e8f016ebf25b0cf13875536f1726))
 * Content View: Repository sync and content information are blank for a newly enabled repository ([#16265](http://projects.theforeman.org/issues/16265), [25d6f29f](http://github.com/katello/katello/commit/25d6f29f21196fcf1594ca2f0e9bf073dc692cb4))

### Web UI
 * katello needs to require bastion 4.0.0 ([#17912](http://projects.theforeman.org/issues/17912), [6fe9180e](http://github.com/katello/katello/commit/6fe9180e171e6607e61a29780a51ec19e6db7824))
 * Some tables still have Deselect All link active with nothing selected ([#17685](http://projects.theforeman.org/issues/17685), [871ef7dc](http://github.com/katello/katello/commit/871ef7dc41d3dd599a732bfc909bb5b807896fc7))
 * product table name link should link directly to repositories ([#17371](http://projects.theforeman.org/issues/17371), [440121d4](http://github.com/katello/katello/commit/440121d40a58723c0bb363dc2a6447ccb4e54b98))
 * Dashboard Content Host Subscription Status Links are not URI encoded ([#17227](http://projects.theforeman.org/issues/17227), [4e6744dd](http://github.com/katello/katello/commit/4e6744dd462d613667c746c53c062c9300019500), [79ed3c6b](http://github.com/katello/katello/commit/79ed3c6b12b014dc4a8cbfff5f41f637bfa4d7c3))
 * upradable package list shows all applicable packages ([#16902](http://projects.theforeman.org/issues/16902), [b6c4c7af](http://github.com/katello/katello/commit/b6c4c7af866185082572307236a522e8bf01cd6d))
 * Fix the case of the menu items in Katello (e.g. "Sync Status" vs "Activation keys") ([#16589](http://projects.theforeman.org/issues/16589), [b4c0cb9e](http://github.com/katello/katello/commit/b4c0cb9e761d26180d06160ab7a375b94cb33a09))
 * add step up polling interval for UI task polling ([#16575](http://projects.theforeman.org/issues/16575), [b19a24e7](http://github.com/katello/katello/commit/b19a24e7b96c203364b537f8a321c5b67d8ff1b6))
 * Lifecycle environments not redirecting to 404 ([#16246](http://projects.theforeman.org/issues/16246), [b481e2ae](http://github.com/katello/katello/commit/b481e2aecb210c42e1dd6857b2ae9ee59e8f92a7))
 * "Error: Request Timeout" from hammer when asked to show >400 content hosts ([#16010](http://projects.theforeman.org/issues/16010), [80ebe622](http://github.com/katello/katello/commit/80ebe622e8820a2aa8f9db0c78a90b9369971e6c))
 * GPG list not sorted in product/repository GPG key picklist ([#8455](http://projects.theforeman.org/issues/8455), [d3b38297](http://github.com/katello/katello/commit/d3b38297e9a499adc85d7ae76964552aba59ab10))

### Hosts
 * Getting undefined method `name' for nil:NilClass when trying edit/view a host group ([#17815](http://projects.theforeman.org/issues/17815), [a3d89422](http://github.com/katello/katello/commit/a3d8942292fef71ab4d494208f1970b361664f93))
 * Display package applicability for a single host ([#16637](http://projects.theforeman.org/issues/16637), [940bd79d](http://github.com/katello/katello/commit/940bd79d5703a81997d8f7621084693f719d36ab))
 * New host creation ignores permissions for lifecycle envs, content views, and conent sources (smart proxies) ([#17176](http://projects.theforeman.org/issues/17176), [b5202aef](http://github.com/katello//commit/b5202aefc6fc40124aa781dfc50fbcc1b42f2503))

### Tests
 * fix rubocop 0.46 errors ([#17805](http://projects.theforeman.org/issues/17805), [5043f5c8](http://github.com/katello/katello/commit/5043f5c8168d35e6ae0f0ad62ef76443e648c9b4))
 * CapsuleContent Test fails during the month of december ([#17557](http://projects.theforeman.org/issues/17557), [519b940d](http://github.com/katello/katello/commit/519b940dd7adc5da87bc2ac4bcdefcb2d3a103b4))
 * populating test DB fails on fresh install ([#17550](http://projects.theforeman.org/issues/17550), [be8ede9e](http://github.com/katello/katello/commit/be8ede9e056ff41181aa8e87be956844ed122b2e))
 * add access permission tests to katello ([#16998](http://projects.theforeman.org/issues/16998), [e23255a8](http://github.com/katello/katello/commit/e23255a8981bc1ffc12d0110cf02dea79416b3ce))

### Subscriptions
 * handle pool stackingId in an org-safe manner ([#17789](http://projects.theforeman.org/issues/17789), [ca671e34](http://github.com/katello/katello/commit/ca671e34d0deea9e34dd37f38c3d9f704e774a8e))
 * server_status to call CandlepinPing.ping just once ([#16870](http://projects.theforeman.org/issues/16870), [6343a0a2](http://github.com/katello/katello/commit/6343a0a283591f1bdd1f0c49049d96696ed29eb5))

### Repositories
 * Keyboard tab doesnt function well with Products or Repository page ([#17787](http://projects.theforeman.org/issues/17787), [2b95d5d6](http://github.com/katello/katello/commit/2b95d5d689e7fd139b372611e3cb37c4a52c959b))
 * Repository new and edit pages list no download poilicies to select ([#17542](http://projects.theforeman.org/issues/17542), [7d7429ce](http://github.com/katello/katello/commit/7d7429ce5b7334394e4875833b13825b3341f57e))
 * sync product repo does not switch to task page ([#17523](http://projects.theforeman.org/issues/17523), [4b43ca57](http://github.com/katello/katello/commit/4b43ca5730f13d5e632fc1887b8b680109d76f34))
 * Synchronizing a repository with large amount rpms causes large memory usages while indexing ([#17512](http://projects.theforeman.org/issues/17512), [e5cd23c7](http://github.com/katello/katello/commit/e5cd23c7a8c6e329bdc140266e2dc4e70347e239))
 * pulp communication relies on system wide store rather than specifying CA path ([#17400](http://projects.theforeman.org/issues/17400), [f559725c](http://github.com/katello/katello/commit/f559725cdd1173b0c0d2b111dbc6b0120d4a000a), [264a110f](http://github.com/katello/puppet-katello/commit/264a110ff306ccf4f713aae034db847a0c2f74bc))
 * new repository button does not go to new repository page ([#17388](http://projects.theforeman.org/issues/17388), [3979337f](http://github.com/katello/katello/commit/3979337f6b8d69cccba4767ea59c56380629b228))
 * errata apply task does not show installed/updated packages  ([#17233](http://projects.theforeman.org/issues/17233), [e05874cf](http://github.com/katello/katello/commit/e05874cfe7ae75730e0ea401f5dd08ccc297310a))
 * repository delete by name neither allows to delete repo w/o org nor accepts the org ([#16730](http://projects.theforeman.org/issues/16730), [7f4d6b79](http://github.com/katello/hammer-cli-katello/commit/7f4d6b794b3c0c119cfd41778e70cb7f936bb124))

### Foreman Proxy Content
 * API/CLI - ISE on Deleting proxy: Can't modify frozen hash ([#17784](http://projects.theforeman.org/issues/17784), [3d8abda4](http://github.com/katello/katello/commit/3d8abda434f21e4f2cb4fc33cb7f1dce9efc77e1))
 * Replace all instances of Capsule with Smart Proxy in Katello UI ([#17601](http://projects.theforeman.org/issues/17601), [738d54ad](http://github.com/katello/katello/commit/738d54ad15fc64afe4975113973877575cde8a77))

### Client/Agent
 * reinstalling katello-ca-consumer on RHEL7 Content Host does not restart goferd service ([#17658](http://projects.theforeman.org/issues/17658), [5e02f1e7](http://github.com/katello/puppet-certs/commit/5e02f1e7b8ad4888247c6a0b2c44cd1b6cbb151a))
 * tracer upload yum plugin should look at all pkgs  ([#17359](http://projects.theforeman.org/issues/17359), [03c9eb82](http://github.com/katello/katello-agent/commit/03c9eb82745e966e5be2969c18727d51176d9dc5))
 * systems where 'hostname -f' returns an error fails registration ([#17721](http://projects.theforeman.org/issues/17721), [1544376d](http://github.com/katello/puppet-certs/commit/1544376db06fbe9b73e412758f67b00bd4870915))

### Candlepin
 * Improve ListenOnCandlepinEvents throughput ([#17498](http://projects.theforeman.org/issues/17498), [55677460](http://github.com/katello/katello/commit/55677460eea47e2d34a04364b485daaf59296cdc), [87ef553c](http://github.com/katello/katello/commit/87ef553cfe840299389abbb4123a640c2227e0bb))
 * trigger debug cert generation during org creation ([#16978](http://projects.theforeman.org/issues/16978), [9eb73f03](http://github.com/katello/katello/commit/9eb73f03232b42749d6dce1c4dba4fc243002c6a))

### API
 * Remove duplicate permission code from product api ([#17481](http://projects.theforeman.org/issues/17481), [c3019887](http://github.com/katello/katello/commit/c3019887587b5d42239405de765b7920d6f41eeb))
 * Katello API : POST /katello/api/v2/content_view_versions/:id/promote results in NoMethodError ([#16745](http://projects.theforeman.org/issues/16745), [ce140802](http://github.com/katello/katello/commit/ce140802145e328548c0e0c2e9e9fac7a307cd1f))

### Lifecycle Environments
 * Puppet module appear in content view but doesn't appear in lifecycle environment ([#17402](http://projects.theforeman.org/issues/17402), [13f1896c](http://github.com/katello/katello/commit/13f1896ccec51492593394cf137b5070ad28974b))

### Docker
 * Associating docker tag with incorrect docker manifest. ([#17317](http://projects.theforeman.org/issues/17317), [806a8e4e](http://github.com/katello/katello/commit/806a8e4e0c19e75cfffb0de96beb0eb3ca3d3794), [beb1cd36](http://github.com/katello/katello/commit/beb1cd36c67c3566a36367bad503352fa0beb9fb))
 * Improve UI details for docker tags ([#17186](http://projects.theforeman.org/issues/17186), [b8eae753](http://github.com/katello/katello/commit/b8eae75360cf02fd69201eb8b309b17d2375cc54))
 * docker tags page only shows tag not full name  ([#16851](http://projects.theforeman.org/issues/16851), [0c37e226](http://github.com/katello/katello/commit/0c37e226676417187e76c5d3252ba2656bc9b13c))

### Documentation
 * hard linebreaks in developer docs on katello.org ([#16875](http://projects.theforeman.org/issues/16875), [e6211945](http://github.com/katello//commit/e62119451cae6082f65630b85a727a3e28b5d25e))

### Hammer
 * hammer package list with organization fails ([#16793](http://projects.theforeman.org/issues/16793), [6a37d966](http://github.com/katello/hammer-cli-katello/commit/6a37d966687d7507dd3ea6acf84ec1912e96ebee))

### Tooling
 * "katello-service restart" does not restart goferd on Capsule ([#16586](http://projects.theforeman.org/issues/16586), [a5ee1f2a](http://github.com/katello/katello-packaging/commit/a5ee1f2af886293faf6bdd55f221328929277f52))

### Roles and Permissions
 * Unable to create a repository as non-admin user  ([#16505](http://projects.theforeman.org/issues/16505), [4506461b](http://github.com/katello/katello/commit/4506461b920f837d1097963f8c8361ac60a47fbf), [48caa6f1](http://github.com/katello/katello/commit/48caa6f12e62d19547aad52f5d7bd5a831edd81f))

### Errata Management
 * Handle errata status with Library vs current environment ([#12347](http://projects.theforeman.org/issues/12347), [a75565df](http://github.com/katello/katello/commit/a75565df0b98c64efe33874f0544034071e6b1c6))

### Upgrades
 * upgrade failed at update_subscription_facet_backend_data (undefined method `inject' for nil:NilClass) ([#17612](http://projects.theforeman.org/issues/17612), [4f414f3d](http://github.com/katello//commit/4f414f3d37ea05ee7529759acb130112814b50a7))

### Other
 * katello:check_ping should load environment ([#17719](http://projects.theforeman.org/issues/17719), [54a25322](http://github.com/katello/katello/commit/54a25322994ee1f52e34d921afc634bd7f91cc94))
 * Red hat repositories is too slow ([#17718](http://projects.theforeman.org/issues/17718), [3611988b](http://github.com/katello/katello/commit/3611988b252cc3450b2cf8ef53a26bd3b5eb43db))
 * Hostgroup create/update does not accept --lifecycle-environment parameter ([#17619](http://projects.theforeman.org/issues/17619), [6581e356](http://github.com/katello/hammer-cli-katello/commit/6581e356a0cbe5f87c5785dccc8da816f51f8d8a))
 * Incremental update results in "undefined method description=" for ContentViewVersion ([#17584](http://projects.theforeman.org/issues/17584), [61273472](http://github.com/katello/katello/commit/61273472750db53839c06535f793326bff688d81))
 * Backend data should not be initialized in database seeds ([#17465](http://projects.theforeman.org/issues/17465), [5cd70f08](http://github.com/katello/katello/commit/5cd70f08aa47d127fdacaf025b1c1940f976198d))
 * Refactor Ping model to address method length and branching ([#17382](http://projects.theforeman.org/issues/17382), [9a65a4f8](http://github.com/katello/katello/commit/9a65a4f805616b7c66e326ab18f69b4818fd21d6))
 * Specifying ca_cert_file for Candlepin fails with SSL verify error ([#17379](http://projects.theforeman.org/issues/17379), [a424a710](http://github.com/katello/katello/commit/a424a710b117976f4a4fdc89450c61b99f7357cc))
 * Improve the error message when a repository does not exist for a certain architecture / and version ([#17181](http://projects.theforeman.org/issues/17181), [c204cba3](http://github.com/katello/katello/commit/c204cba3b3bbbb4e8b1e9eaeff88c081dcb9a56c))
 * foreman-debug to collect whole newest (log)files instead of tailing all (log)files ([#17114](http://projects.theforeman.org/issues/17114), [4ff859b6](http://github.com/katello/katello-packaging/commit/4ff859b6ef71f25d426d63cf7b336f87cae7488c))
 * hammer content-view filter list is missing --organization parameter ([#16794](http://projects.theforeman.org/issues/16794), [463c7d63](http://github.com/katello/hammer-cli-katello/commit/463c7d63acb0ae1901cbbc0d45ac189a1da16fb2))
 * Dashboard names and titles are inconsistent ([#16679](http://projects.theforeman.org/issues/16679), [cfa911c6](http://github.com/katello//commit/cfa911c6827fff885c54044c31c76a51e1b94c0c))
 * Unattended template doesn't call 'built' ([#17903](http://projects.theforeman.org/issues/17903), [d3541c40](http://github.com/katello/katello/commit/d3541c40379d9dab7f4511199c0f9a0b1228d183))
