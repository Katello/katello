# 3.5.0 Schwarzbier (2017-10-10)

## Features 

### Subscriptions
 * Upgrade to Candlepin 2.1 ([#20792](http://projects.theforeman.org/issues/20792))

### Repositories
 * As a user, I want to list all repository sets for an organization. ([#19925](http://projects.theforeman.org/issues/19925), [a88bd055](http://github.com/katello/katello/commit/a88bd05558a512392eb1b8a7774b5cf38b0fef21))
 * Add help text to new repository Download Policy ([#19199](http://projects.theforeman.org/issues/19199), [a008356d](http://github.com/katello/katello/commit/a008356d21c206caee9264c30a2b8be4ba4f4460))

### Installer
 * Need additional supported database deployment options for Katello installation: such as External Postgres ([#19667](http://projects.theforeman.org/issues/19667), [51ca4090](http://github.com/katello/puppet-candlepin/commit/51ca40909f7ae82bf06f0571df673397daa56201), [65f55250](http://github.com/katello/katello-installer/commit/65f55250856162ee7fd8b4e29e1ad78074e8c866), [04ebdba2](http://github.com/katello/puppet-katello/commit/04ebdba2f334862cfd463a6396e652873eb3e471))

### Content Views
 * [RFE] Component view versions for composite content views ([#18228](http://projects.theforeman.org/issues/18228), [ab643413](http://github.com/katello/katello/commit/ab6434137082ba219f6acb6974aee1214dcc8e08))

### Candlepin
 * As a user, i would like to restrict a certain repo to one or more arches. ([#5477](http://projects.theforeman.org/issues/5477), [b02526be](http://github.com/katello/katello/commit/b02526bea7026560b2d6d66fac9038cfeb74bab9))

### Hammer
 * Show an option to which capsule the client is registered to through hammer ([#20791](http://projects.theforeman.org/issues/20791))

### Backup & Restore
 * katello-change-hostname needs better requirements checking ([#20799](http://projects.theforeman.org/issues/20799), [d3fe631e](http://github.com/katello/katello-packaging/commit/d3fe631e52f0d6837243c10cfcf2d1ec0a8aed77))

### Hosts
 * set release version of a content host via bulk action ([#20583](http://projects.theforeman.org/issues/20583), [42a3a9c1](http://github.com/katello/katello/commit/42a3a9c17e53752dab573c74fb8c1bbc9a59c72b))

### Other
 * CSV export on Content Host page ([#19954](http://projects.theforeman.org/issues/19954), [6362c738](http://github.com/katello/katello/commit/6362c738f721131630c8b0a317c4040e39e53b92))

## Bug Fixes 

### Installer
 * puppet-pulp uses enable instead of enabled in profiling ([#20865](http://projects.theforeman.org/issues/20865), [87cd4e5f](http://github.com/katello/puppet-pulp/commit/87cd4e5fa92e5970dd1ed5f8017dc26ce15a2905))
 * katello_devel missing from parser cache ([#19601](http://projects.theforeman.org/issues/19601), [52e7e64e](http://github.com/katello/katello-installer/commit/52e7e64ea0dfc946e0a83c8de1fa9f9e1d8dec3e))
 * server and foreman-proxy-content installer misses /etc/crane.conf data_dir ([#19684](http://projects.theforeman.org/issues/19684))
 * puppet-pulp missing docker schema 2 for /etc/httpd/conf.d/pulp_docker.conf ([#19740](http://projects.theforeman.org/issues/19740), [5b0c9810](http://github.com/katello/puppet-pulp/commit/5b0c9810341b1cac2536b7ea6672fd69d2b6cc5c))

### Hammer
 * hammer content-view filter rule create does not properly set the architecture ([#20749](http://projects.theforeman.org/issues/20749), [a4942f1b](http://github.com/katello/katello/commit/a4942f1b4bc7f0cc091d69ca4b3bf3bc632a17db))
 * hammer content-view filter rule list and info do not list arch field ([#20748](http://projects.theforeman.org/issues/20748), [aea6979c](http://github.com/katello/hammer-cli-katello/commit/aea6979c21941b10d7e136abdb413a63e0da31fa))
 * Update the help description for "--sync-date" option in hammer. ([#20613](http://projects.theforeman.org/issues/20613), [59ab7402](http://github.com/katello/hammer-cli-katello/commit/59ab74029d44befde9a0037591e3cffd493eb82f))
 * Hammer hostgroup not updating by title when katello plugin is installed ([#20433](http://projects.theforeman.org/issues/20433), [a137840f](http://github.com/katello/hammer-cli-katello/commit/a137840f12c48d759ee6edb1554cc6d905c7e7ac))
 * hammer --nondefault ignores the value passed to it and always filter out "Default Organization View" ([#19749](http://projects.theforeman.org/issues/19749), [3438db63](http://github.com/katello/katello/commit/3438db63119c7bc56c99adf359ccffcf84955582))

### Web UI
 * All item pages should be using id instead of uuid ([#20747](http://projects.theforeman.org/issues/20747), [d0f2a68d](http://github.com/katello/katello/commit/d0f2a68d79a1cc46175f2a660cfeb8531b83d016))
 * sprockets 3.x requires SCSS assets to use .scss ([#20544](http://projects.theforeman.org/issues/20544), [aaa18733](http://github.com/katello/katello/commit/aaa187330ec26188b25b6d6d64f7bbb2471950d7))
 * Foreman tasks table should be using index method instead of bulk_search ([#20393](http://projects.theforeman.org/issues/20393), [51de0437](http://github.com/katello/katello/commit/51de0437f9dd0255826401668288422cfc55910b))
 * Missing HTML title on "Content Hosts" page ([#20988](http://projects.theforeman.org/issues/20988), [ac25cd85](http://github.com/katello/katello/commit/ac25cd85a394a9124875d90fabbee2eed3af047f))

### Repositories
 * Add foreman_scc_manager to repository ([#20741](http://projects.theforeman.org/issues/20741), [c523599f](http://github.com/katello/katello-packaging/commit/c523599f18e3991ab43158e0c4ed4ba277826643))
 * Exceptions get covered in Pulp::Repository::CreateInPlan::Create ([#20349](http://projects.theforeman.org/issues/20349), [dd9bdccb](http://github.com/katello/katello/commit/dd9bdccb8b1ba65f16fba848cf78ac3ebee6d532))
 * `hammer package list --organization-id` results in 'Error: found more than one repository' ([#20091](http://projects.theforeman.org/issues/20091), [ead760ff](http://github.com/katello/hammer-cli-katello/commit/ead760ff907e75fb30dac6f07e37b90820e21960))
 * Remove old puppet modules from product that have been removed from the source repo ([#20089](http://projects.theforeman.org/issues/20089), [4ba82967](http://github.com/katello/katello/commit/4ba82967fe4efe2e60c4fe7dc82e02f7f6f90cca))
 * yum repo discovery using incorrect url when creating ([#20063](http://projects.theforeman.org/issues/20063), [976b01a7](http://github.com/katello/katello/commit/976b01a7852835dbfdf30b3543c11886a8a29333))
 * Internal server error when removing packages from a repository ([#20023](http://projects.theforeman.org/issues/20023), [04e16d63](http://github.com/katello/katello/commit/04e16d639eeeaa79e68d457ee1bc83c189035922))
 * Can't create repository within Product as non-admin user ([#19971](http://projects.theforeman.org/issues/19971), [2e48f8e3](http://github.com/katello/katello/commit/2e48f8e368c67d2e55a34c27ef23c3245a8bab07))
 * When creating a new yum repository checksum list is empty and without a default value ([#19932](http://projects.theforeman.org/issues/19932), [6e10b6cd](http://github.com/katello/katello/commit/6e10b6cd7f60bfbfb7c82c5055567f0c91c75cb3))
 * JS error on product details page when trying to create a new sync plan ([#19581](http://projects.theforeman.org/issues/19581), [e6b4282c](http://github.com/katello/katello/commit/e6b4282c1efec1fd59f9ba9a49428afe4c55d2ef))
 *  Internal Server error when searching product repository by numbers with more than 9 digits ([#21017](http://projects.theforeman.org/issues/21017), [ddd80cd4](http://github.com/katello/katello/commit/ddd80cd44b73d47556cc51259d1bf72ca0694660), [f7906cef](http://github.com/katello/katello/commit/f7906cefb94c94c1e1d154e7f3e07d96f41b6b6e), [26243182](http://github.com/katello/katello/commit/26243182825b96cd81adfe4a4d161c4815129bff), [da7a4849](http://github.com/katello/katello/commit/da7a48493621e990a6d854e90c79ab0f62e0598b))

### Hosts
 * Content Host Installable Errata show wrong icons color when 0 applicable ([#20714](http://projects.theforeman.org/issues/20714), [68732d64](http://github.com/katello/katello/commit/68732d644c8613100b9257fc9cc232bf8bae5fb7))
 * Update/Upgrade package buttons missing in Katello 3.4 ([#19958](http://projects.theforeman.org/issues/19958), [3fe064c1](http://github.com/katello/katello/commit/3fe064c15b264ec3ecd58f1b2b477c7ff658fba5))
 * undefined method `kickstart_repos' for #<Suse:0x007f1bdbd558d8> ([#20874](http://projects.theforeman.org/issues/20874), [4683ea07](http://github.com/katello/katello/commit/4683ea072d907b8bf597c69d77dca042b5c1766c))
 * Extremely slow /api/v2/hosts, 200hosts/page takes about 40s to display ([#20508](http://projects.theforeman.org/issues/20508), [59c52f67](http://github.com/katello/katello/commit/59c52f6787e1a446aa8690fec28d9159ac0d2103))

### Client/Agent
 * network.hostname-override defaults to "localhost" if no fqdn set ([#20642](http://projects.theforeman.org/issues/20642), [7c0326d6](http://github.com/katello/puppet-certs/commit/7c0326d68d8232a0918e810c1a4ea31ff29ac0a1))
 * katello-agent yum-plugin enabled_repos_upload has repositories misspelled in yum output ([#20531](http://projects.theforeman.org/issues/20531), [76b8b829](http://github.com/katello/katello-agent/commit/76b8b8292e72b3bf6c5dde791b0c54630c8e6bdf))
 * Optimize package profile task processing time ([#20682](http://projects.theforeman.org/issues/20682), [71c42653](http://github.com/katello/katello/commit/71c426531d694307376dac579fd63502c0d7d62f), [1730f5a7](http://github.com/katello/katello/commit/1730f5a79013a24a421c9389b1c26512895374e2))
 * The enabled_repos_upload yum plugin is not compatible with Puppet 4 or Enterprise ([#20787](http://projects.theforeman.org/issues/20787), [156d8844](http://github.com/katello/katello-agent/commit/156d88442c07c3144a8924799d53865d33fda6a3))

### Subscriptions
 * Unable to list/remove or add future-dated subscriptions in individual content host view ([#20582](http://projects.theforeman.org/issues/20582), [d36a700f](http://github.com/katello/katello/commit/d36a700f62f2b0a80b9adb7e14efdc96de1cc8fc))
 * Subscriptions are not getting added via activation keys ([#19548](http://projects.theforeman.org/issues/19548), [ada82e65](http://github.com/katello/katello/commit/ada82e6549f69714a567299192c5d63e42fc6637))
 * subscription page unusable with many hosts registered ([#19394](http://projects.theforeman.org/issues/19394), [1886eef5](http://github.com/katello/katello/commit/1886eef588fc7f8a8df65fe8b59911afd1d20d54))
 * Reduce the amount of data subscriptions asks for in show endpoint ([#20010](http://projects.theforeman.org/issues/20010), [4497a2e8](http://github.com/katello/katello/commit/4497a2e83db913120924d8b1c15b7872538fa9e1))
 * candlepin event listener does not release messages after error ([#20532](http://projects.theforeman.org/issues/20532), [6f9ecbfb](http://github.com/katello/katello/commit/6f9ecbfb02154370067d47237509e4827acf7c7f))

### API
 * hammer order option has no effect ([#20579](http://projects.theforeman.org/issues/20579), [3605d81f](http://github.com/katello/katello/commit/3605d81f838a624f22fe289c652a17f2f72b51fa))
 * organization_id should be a top level attribute in the API ([#20219](http://projects.theforeman.org/issues/20219), [f8008f09](http://github.com/katello/katello/commit/f8008f09aa7cc1f2d05d268e2fa58b0ab7564a72))

### Dashboard
 * dashboard widget data bleeds out of widget box if browser window is small ([#20338](http://projects.theforeman.org/issues/20338), [977a7c45](http://github.com/katello/katello/commit/977a7c455aa10c956c9cc1af18db1458f4af045f))

### Tests
 * NameError: uninitialized constant Katello::Host::HostInfo  during engine load ([#20234](http://projects.theforeman.org/issues/20234), [4cc182fc](http://github.com/katello/katello/commit/4cc182fc474cd5f8caf0e77d195e6a7e04bd33b6), [564ca702](http://github.com/katello/katello/commit/564ca702668f6ec2df0ee4588291306f1c249c03))
 * Fix tests after create and edit permissions started to be enforced ([#20135](http://projects.theforeman.org/issues/20135), [259e113f](http://github.com/katello/katello/commit/259e113fee2d64a13ab4170cc943c1d5b5d87147))
 * Fix tests for sprockets-rails 3.x ([#20122](http://projects.theforeman.org/issues/20122), [0845021d](http://github.com/katello/katello/commit/0845021d7bd08d7ab0ccf43f5912a96bde649abc), [18d296d7](http://github.com/katello/katello/commit/18d296d7d37e8136fec25442100797fadf4c4609))
 * upgrade to rubocop 0.49.1 ([#19931](http://projects.theforeman.org/issues/19931), [70972aae](http://github.com/katello/katello/commit/70972aaee4cbf10d91a505a051971deb0dffc494))
 * Undefined method 'split' for nil on several tests ([#19741](http://projects.theforeman.org/issues/19741), [885e3f2e](http://github.com/katello/katello/commit/885e3f2e487a99dd0cdc5948d3e4353ec4cd382f), [108f9919](http://github.com/katello/katello/commit/108f99198f1aa9368d785a4401fb066fca69f378))
 * hound ci doesn't recognize nested .rubocop.yaml files ([#19674](http://projects.theforeman.org/issues/19674), [ed1373f4](http://github.com/katello/katello/commit/ed1373f43fd69be5700879d8bd493376c3766b4f))
 * duplicate code in test/actions/pulp/repository/* files  ([#19434](http://projects.theforeman.org/issues/19434), [e9cceccc](http://github.com/katello/katello/commit/e9cceccc3017ad4491c4a1a371015d33c696652d))
 * transient test failure ([#19351](http://projects.theforeman.org/issues/19351), [b3bc464b](http://github.com/katello/katello/commit/b3bc464b7a8ae2a15682a126f181e7edd1770134))
 * Tests relying on stubbing settings must be updated for external auth source seeding ([#19174](http://projects.theforeman.org/issues/19174), [e97a3d3c](http://github.com/katello/katello/commit/e97a3d3c7c1e0eecd45ab469cb87f5330d575219))

### Sync Plans
 * sync_plan['id'] missing in products#index ([#20218](http://projects.theforeman.org/issues/20218), [73629966](http://github.com/katello/katello/commit/7362996650eca2373309f0f24ba853f664a22253))

### Tooling
 * katello-remove is very slow ([#19941](http://projects.theforeman.org/issues/19941), [8fc138c0](http://github.com/katello/katello-packaging/commit/8fc138c08e4e519459fa292f658b7d02fae32497))
 * rpm build failing with LoadError: cannot load such file -- katello-3.5.0/test/support/annotation_support ([#19567](http://projects.theforeman.org/issues/19567), [d7ed8a44](http://github.com/katello/katello/commit/d7ed8a44b2c717b06b9cd03b5f98913291308b95))
 * update to runcible 2.0 ([#19379](http://projects.theforeman.org/issues/19379), [7c4181f1](http://github.com/katello/katello/commit/7c4181f119e44557696f085620da905f2d94721e))
 * Ping does not show pulp_auth ([#19987](http://projects.theforeman.org/issues/19987), [839bfd36](http://github.com/katello/katello/commit/839bfd36a97cefdbc487363aefc322ec531194f5))
 * katello-change-hostname should check exit codes of shell executions ([#20925](http://projects.theforeman.org/issues/20925), [685cad77](http://github.com/katello/katello-packaging/commit/685cad775989ddf653c165bad2b94b751f4fd165))
 * katello-change-hostname should verify credentials before doing anything ([#20924](http://projects.theforeman.org/issues/20924), [ef4fa97b](http://github.com/katello/katello-packaging/commit/ef4fa97b279409406abcd14e8ba0e03f8b575abe))
 * katello-change-hostname tries to change the wrong default proxy if default proxy id has multiple digits ([#20921](http://projects.theforeman.org/issues/20921), [f7db11e5](http://github.com/katello/katello-packaging/commit/f7db11e5e7019a5a264c44cd77d581253776ba0d))
 * katello-change-hostname silently fails when there are special (shell) chars in the password ([#20919](http://projects.theforeman.org/issues/20919), [ece3dc6f](http://github.com/katello/katello-packaging/commit/ece3dc6f2cda95011b72a39cbba69f8c13bb601e))

### Content Views
 * Select inputs on content view deletion are not correctly styled ([#19285](http://projects.theforeman.org/issues/19285), [4abe9501](http://github.com/katello/katello/commit/4abe95012860c53f2cf97df49c6cadac06607967))
 * Editing a content view package filter rule with greater or less than breaks the filter ([#20876](http://projects.theforeman.org/issues/20876), [ae5f0ea5](http://github.com/katello/katello/commit/ae5f0ea5617fb116b9d73a34870ef54e8fe8ac71))
 * `content-view filter rule info` does not resolve by name with multiple rules on a filter ([#20761](http://projects.theforeman.org/issues/20761), [79fa4884](http://github.com/katello/katello/commit/79fa48845a191f63e966c281fa0aff086f78e91c), [8bfa14c7](http://github.com/katello/hammer-cli-katello/commit/8bfa14c7a06b41a4b54ba4defb44c9f3b56c68c5))

### Candlepin
 * Enable consistent candlepin id naming ([#19099](http://projects.theforeman.org/issues/19099), [36ef0d5b](http://github.com/katello/katello/commit/36ef0d5b419bbd3c1178084f67a227cc7735f72a))

### Documentation
 * Pulp Workflow: Document Repository Creation ([#18922](http://projects.theforeman.org/issues/18922), [fdc3b7be](http://github.com/katello/katello/commit/fdc3b7be98b85e0110576be04b8adece8e9bef19))
 * Pulp Workflow: Document repository syncing ([#18921](http://projects.theforeman.org/issues/18921), [fdc3b7be](http://github.com/katello/katello/commit/fdc3b7be98b85e0110576be04b8adece8e9bef19))

### SElinux
 * Installation of Katello generates denial ([#14233](http://projects.theforeman.org/issues/14233), [17700324](http://github.com/katello/katello-selinux/commit/17700324045276aa4c7ff655f19fb88fd44eb2b0))

### Host Collections
 * UI / Host Collection / Copy page missing validation ([#20011](http://projects.theforeman.org/issues/20011), [5ae62cf9](http://github.com/katello/katello/commit/5ae62cf9bd3f072f5ec9ac4b866ed1275eb3f2e4))

### Errata Management
 * errata applicability are not regenerated on re-registered client (with the same repos) ([#19605](http://projects.theforeman.org/issues/19605), [86242349](http://github.com/katello/katello/commit/862423497394935c7c13eb7f09e3ec9355588fa1))
 * Errata content host apply confirm button has no effect ([#20789](http://projects.theforeman.org/issues/20789), [0c6a18c5](http://github.com/katello/katello/commit/0c6a18c5665acd04088497e006626971d088738c))

### Backup & Restore
 * Support use of snapshots in katello-backup to allow service to be restored quickly ([#18329](http://projects.theforeman.org/issues/18329), [5536ca4b](http://github.com/katello/katello-packaging/commit/5536ca4b588f588f636e8cdacd0c8c25d49c91e3))

### API doc
 * Katello overrides apipie definition for Smart Proxies ([#20863](http://projects.theforeman.org/issues/20863), [1f0b8269](http://github.com/katello/katello/commit/1f0b8269df1d56b284da6dfa95b08285416a4d0c))
 * Katello overrides apipie definition for hostgroups ([#20862](http://projects.theforeman.org/issues/20862), [ef092004](http://github.com/katello/katello/commit/ef09200425f7d2679e976f22b0a0952b881aca08))

### Provisioning
 * Safe mode rendering does not correctly prevent using symbol to proc calls ([#20836](http://projects.theforeman.org/issues/20836), [83ed4f8d](http://github.com/katello/katello/commit/83ed4f8dd9b31ff59cdfbfea3171ac5feb88532a))

### Foreman Proxy Content
 * New packages are not synced from the katello to capsule even after a successful capsule sync. ([#19179](http://projects.theforeman.org/issues/19179), [7fddb44d](http://github.com/katello/katello/commit/7fddb44d8b013a6b3e7ab0f5195ea5d05bc37398))

### Other
 * Don't consider localhost as valid host name when parsing rhsm facts ([#20816](http://projects.theforeman.org/issues/20816), [2060454b](http://github.com/katello/katello/commit/2060454b1b7305136fcf43dc75e040ec328829b0))
 * Katello redhat extension tests intermittently fail ([#20795](http://projects.theforeman.org/issues/20795), [ea6d4b56](http://github.com/katello/katello/commit/ea6d4b56c14ba6fe5acf40d4f4d5984833f0fb07))
 *  POST /api/hosts/bulk/applicable_errata API doc has incorrect URL pointing to installable_errata.html ([#20478](http://projects.theforeman.org/issues/20478), [4ca55e14](http://github.com/katello/katello/commit/4ca55e14424e16adff4ef5764cc8f30868214421))
 * Remove RHEL6 support in katello-change-hostname ([#20463](http://projects.theforeman.org/issues/20463), [45417cf6](http://github.com/katello/katello-packaging/commit/45417cf61d90a5c862f8fb9b1a4ede81c543b297))
 * Error on registering a host ([#19970](http://projects.theforeman.org/issues/19970), [46bee19e](http://github.com/katello/katello/commit/46bee19ed7fe7c445ecf45c196825143e0bbf4b9))
 * katello-change-hostname should ask for credentials if not provided ([#20805](http://projects.theforeman.org/issues/20805), [a29de727](http://github.com/katello/katello-packaging/commit/a29de727340560128e086e57113202f21accfc2a))
 * Hypervisors show up as Hosts with no Puppet reports ([#20727](http://projects.theforeman.org/issues/20727), [70c8be75](http://github.com/katello/katello/commit/70c8be756dda2b3c92fd32b6cee81136af93eb5a))
 * Cancel button not working on create activation key page ([#20719](http://projects.theforeman.org/issues/20719), [3fba6188](http://github.com/katello/katello/commit/3fba61885e15da7536acd1b382fdeb590bc46aa6))
 * Content Hosts Traces page doesnt work ([#20703](http://projects.theforeman.org/issues/20703), [321c0071](http://github.com/katello/katello/commit/321c0071dcc05e0116b67c3acb46fc2a1b0a27b9))
 * API call of GET /katello/api/host_collections says organization_id optional, but doesn't accept without organization id ([#20574](http://projects.theforeman.org/issues/20574), [6f77b2e3](http://github.com/katello/katello/commit/6f77b2e34a88eff02043298ccd062b7ee94b828e))
 * name field not clickable after opening resource switcher ([#21035](http://projects.theforeman.org/issues/21035), [3e8b0796](http://github.com/katello/bastion/commit/3e8b07964f3066d77575e1821fbdac83180cda59))
 * Update installation media paths in k-change-hostname ([#20987](http://projects.theforeman.org/issues/20987), [f1418fc0](http://github.com/katello/katello-packaging/commit/f1418fc08a9f2614b0f136bde6469328f0b6bf34))
 * katello-change-hostname should print command output when it errors out. ([#20984](http://projects.theforeman.org/issues/20984), [a727125b](http://github.com/katello/katello-packaging/commit/a727125bb492abdf14c9eb10c39e8d67d9864cf9))
 * k-change-hostname can mix up internal capsule names ([#20983](http://projects.theforeman.org/issues/20983), [b1a9d445](http://github.com/katello/katello-packaging/commit/b1a9d44581e7e93131c8cadfe04cb0b2d32b2346))
 * clean_installed_packages script logs a count(*), causing slow performance ([#20946](http://projects.theforeman.org/issues/20946), [cc0b15fb](http://github.com/katello/katello/commit/cc0b15fb330178aca8317873eaaf2ef1b280d1d7))
 * k-change-hostname will check for exit code on a skipped command on a foreman-proxy ([#20944](http://projects.theforeman.org/issues/20944), [d32d5854](http://github.com/katello/katello-packaging/commit/d32d5854c167efa0bf2dc02fa5ceceb07f2eff71))
