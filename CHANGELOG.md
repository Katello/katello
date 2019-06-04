# 3.12.0 Iron Stout (2019-06-04)

## Features

### Errata Management
 * Load errata applications should allow filtering by date and result ([#26479](https://projects.theforeman.org/issues/26479), [ecb75c3c](https://github.com/Katello/katello.git/commit/ecb75c3c387f84ce6e0b0b748dd5bb7f6e9836cf))

### Tooling
 * Set license metadata ([#26385](https://projects.theforeman.org/issues/26385), [bb6a59c3](https://github.com/Katello/katello.git/commit/bb6a59c32ef614ae1ae95a12c523c5ba852ec052))

### Content Views
 * Dependency Resolution within content views + associated UI constructs. ([#26206](https://projects.theforeman.org/issues/26206), [7474c9d7](https://github.com/Katello/katello.git/commit/7474c9d72928d3d539c2e0f5cd85a06017c465c2))

### Hosts
 * Generate report for success/failed patching of content hosts between date ranges ([#25973](https://projects.theforeman.org/issues/25973), [76ca4f85](https://github.com/Katello/katello.git/commit/76ca4f85f2dddabcedabef8b5528c3f5ca75ef00), [98b033bc](https://github.com/Katello/katello.git/commit/98b033bcb5c569abf4554de0dd44cb94ffeff324))

### Repositories
 * Add Red Hat Satellite Maintenance 6 in recommended repositories ([#25920](https://projects.theforeman.org/issues/25920), [c5fe7210](https://github.com/Katello/katello.git/commit/c5fe7210a12df9103a980edb9ed3902f5d94743d))

### Other
 * Don't duplicate host record when hypervisor_id changes in virt-who report ([#26600](https://projects.theforeman.org/issues/26600), [86c91f89](https://github.com/Katello/katello.git/commit/86c91f89eaffed8f8b8ce2fe56fdeb0c9571d583), [1d0d2370](https://github.com/Katello/katello.git/commit/1d0d2370cf51c02439eb092d9a59073180437e70))

## Bug Fixes

### Content Views
 * 'uuid' option removed from command "hammer content-view puppet-module list" ([#26902](https://projects.theforeman.org/issues/26902), [c58e1825](https://github.com/Katello/katello.git/commit/c58e182509499a46f74a1d2c612999b427e6563e))
 * Installable Errata not recalculated after CV publish/promote ([#26624](https://projects.theforeman.org/issues/26624), [64ed269e](https://github.com/Katello/katello.git/commit/64ed269ea64595dc12a1355f1a5125c81095e102))
 * Unable to promote content view version ([#26515](https://projects.theforeman.org/issues/26515), [7abd0cfc](https://github.com/Katello/katello.git/commit/7abd0cfc38aaa2796996aec20fc5626ca7c20518))
 * Distributor publish happening even if "matching_content" is true ([#26422](https://projects.theforeman.org/issues/26422), [6ebf1e36](https://github.com/Katello/katello.git/commit/6ebf1e36fac8f8b9ca83dec4fbfb27ec5eaa88df))
 * Docker tag content view filters are ignored ([#26407](https://projects.theforeman.org/issues/26407), [c317cce9](https://github.com/Katello/katello.git/commit/c317cce980982603f8c2ac78a955e329e87de497))

### ElasticSearch
 * ActionController::RoutingError (No route matches [POST] "/katello/api/v2/repositories/sync_complete") ([#26836](https://projects.theforeman.org/issues/26836), [0d1f772b](https://github.com/Katello/katello.git/commit/0d1f772b6f0934889057f1522cb0bb128912ffc7))

### Sync Plans
 * No syncable repositories found for selected products and options. (RuntimeError) ([#26734](https://projects.theforeman.org/issues/26734), [e3fec828](https://github.com/Katello/katello.git/commit/e3fec8286e138cad755aa0403148d4a9fb0d5094))
 * Save sync plan after new rec logic is added ([#26503](https://projects.theforeman.org/issues/26503), [db91b404](https://github.com/Katello/katello.git/commit/db91b404f763a85e54c1823f541627ffeb50fc5d))
 * Downstream CP: Allow enabling/disabling at recurring logic for sync plan 6.5 ([#26305](https://projects.theforeman.org/issues/26305), [71f4d4a8](https://github.com/Katello/katello.git/commit/71f4d4a8871dc0448db674604f074a16b539804f))
 * hammer sync-plan update does not work with custom cron ([#26283](https://projects.theforeman.org/issues/26283), [bdab6e48](https://github.com/Katello/katello.git/commit/bdab6e48551683ab4cc834344e450bc1463360e1))
 * "Working" text on sync plan interval custom cron can be confusing ([#26242](https://projects.theforeman.org/issues/26242), [1ad6c49e](https://github.com/Katello/katello.git/commit/1ad6c49ef87b4581cc212001119013e1fe9a1db2))
 * Allow enabling/disabling at recurring logic for sync plan ([#26219](https://projects.theforeman.org/issues/26219), [de8e0f09](https://github.com/Katello/katello.git/commit/de8e0f097b11ad685de95111ab3f9b316a5684a3))
 * [Recurring logic/Sync Plan] - Associated Resources are not shown in Recurring Logic created using sync plan ([#25934](https://projects.theforeman.org/issues/25934), [591e9386](https://github.com/Katello/katello.git/commit/591e93860941116312aea17df1307b9c3773fadf))

### Repositories
 * Support one to one content url changes ([#26694](https://projects.theforeman.org/issues/26694), [fafb8f6b](https://github.com/Katello/katello.git/commit/fafb8f6bcf26cab8f6f66b4ae833a13b3aebe24f))
 * [Repositories] - Product link should be present in Packages -> Repositories ([#26501](https://projects.theforeman.org/issues/26501), [f0b8cd2a](https://github.com/Katello/katello.git/commit/f0b8cd2aa38569a6ae1a1496e36d46ad49cd417e), [832c13ec](https://github.com/Katello/katello.git/commit/832c13ecbedb4e81c148ac105733cf1f651b6d09))
 * Remove dead code on pulp-2.19 upgrade ([#26478](https://projects.theforeman.org/issues/26478), [dc8776cf](https://github.com/Katello/katello.git/commit/dc8776cfbe29a3e9b8dbc5551bd5316e8773ffa2))
 * Allow for removal of repo and cv puppet env ([#26397](https://projects.theforeman.org/issues/26397), [a2bc3e2b](https://github.com/Katello/katello.git/commit/a2bc3e2b58efe7203d72582854a5d7159d9ffe2f))
 * Please add  Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.x into recommended list ([#26345](https://projects.theforeman.org/issues/26345), [d5a90515](https://github.com/Katello/katello.git/commit/d5a90515711d25ebaef65fd531463dbf41b84097))
 * Recommended repositories page listing some non-relevant repositories ([#26303](https://projects.theforeman.org/issues/26303), [0f54fcaa](https://github.com/Katello/katello.git/commit/0f54fcaa4245e3c6ec1db41241e88cf32fa32f0d))
 * [webUI, Repo-Discovery]- Failed to discover the repository from Repo Discovery Page  ([#26251](https://projects.theforeman.org/issues/26251), [7a81aa84](https://github.com/Katello/katello.git/commit/7a81aa84639352685aa7e5048bb71a8370e9a297))
 * arch and release for RHEL8 does not seem right on "Sync Status" page ([#26075](https://projects.theforeman.org/issues/26075), [36cd944e](https://github.com/Katello/katello.git/commit/36cd944e643ca316d9c55f23123a18a0c5685c11))
 * [Container Admin] Changing repository of any type through web UI changes "Container Image Tags Filter" field value ([#25980](https://projects.theforeman.org/issues/25980), [098bc257](https://github.com/Katello/katello.git/commit/098bc257aef291e575d1035a47bf97f562189332))
 * Red Hat Repositories does not show enabled repositories list with search criteria 'Enabled/Both' ([#25946](https://projects.theforeman.org/issues/25946), [9e770370](https://github.com/Katello/katello.git/commit/9e7703705eabd7809c9f0019d8934f0b667f129c))
 * [Container Admin] docker pull does not work ([#25922](https://projects.theforeman.org/issues/25922), [1af93f7f](https://github.com/Katello/katello.git/commit/1af93f7fa376f9a86dfc9e046ba25d51b2dd9028))
 * [Subscription] - Not able to add RHEL8 repositories into Katello ([#25901](https://projects.theforeman.org/issues/25901), [53e88d8a](https://github.com/Katello/katello.git/commit/53e88d8a47384246696b0084d958b5397c74cc64))
 * Repo filtering is inconsistent ([#25875](https://projects.theforeman.org/issues/25875), [7d6135a6](https://github.com/Katello/katello.git/commit/7d6135a62437c49fba10b8ace9ebb8a59a6f794c))

### Errata Management
 * Errata counts aren't similar between the content-hosts view and the export csv ([#26678](https://projects.theforeman.org/issues/26678), [6696f876](https://github.com/Katello/katello.git/commit/6696f8768431b7f14ce8739665f629c1efd4487b))
 * Available Errata report performs poorly for some filters ([#26030](https://projects.theforeman.org/issues/26030), [3ec1138d](https://github.com/Katello/katello.git/commit/3ec1138d3d837d9111c6d462959b48bc398eef0d))

### Tests
 * Fix intermittent failure in CandlepinDynflowProxyControllerIntegrationTest ([#26677](https://projects.theforeman.org/issues/26677), [3e6716b1](https://github.com/Katello/katello.git/commit/3e6716b1f1bcca05ee0136a0a27e0d6431083198))
 * React Snapshot test errors ([#26390](https://projects.theforeman.org/issues/26390))
 * numeric error when running tests sometimes ([#25887](https://projects.theforeman.org/issues/25887), [8257bcc9](https://github.com/Katello/katello.git/commit/8257bcc9b24a4c34c64e1be6d9e6609952cb8637))

### Roles and Permissions
 * User with 'edit_host' permission can't view certain parts of content host page ([#26673](https://projects.theforeman.org/issues/26673), [4005b230](https://github.com/Katello/katello.git/commit/4005b23088a816129c0fd6a2d1c1c9882a91c67a))
 *  403 on attempt to open Packages Actions tab as user with viewer role ([#25907](https://projects.theforeman.org/issues/25907), [9a0cb8fd](https://github.com/Katello/katello.git/commit/9a0cb8fdd7c44675b8ba6ef1d72134df6a5d00a8))

### Puppet
 * Puppet environments are not synced to the capsules ([#26596](https://projects.theforeman.org/issues/26596), [f50741cd](https://github.com/Katello/katello.git/commit/f50741cd34a38310c30246c6aa0e39ddc770c0c5))
 * undefined method `backend_service' for nil:NilClass when publishing a CV with Puppet content ([#26410](https://projects.theforeman.org/issues/26410), [97c0da15](https://github.com/Katello/katello.git/commit/97c0da150c9ab08951e06d13bc585f09a1df708c))

### Web UI
 * Change wording around accidentally removed host at Unregister button ([#26551](https://projects.theforeman.org/issues/26551), [b98f0d12](https://github.com/Katello/katello.git/commit/b98f0d12309378185d9f05473ef8c36ac94e891e))
 * react-bootstrap-tooltip-button has some packaging issues ([#26276](https://projects.theforeman.org/issues/26276), [eead193a](https://github.com/Katello/katello.git/commit/eead193a4138d62c5bc8d9b325e4dfcac0fca11f))
 * Listing of available yum-repositories in ContentView is not paginated ([#25945](https://projects.theforeman.org/issues/25945), [579a1336](https://github.com/Katello/katello.git/commit/579a1336044773170cabd5a194194f2eab66aaa1))
 *  [Life Cycle Environment] - Duplicate repos are getting displayed in Library->yum repositories ([#25938](https://projects.theforeman.org/issues/25938), [486c8881](https://github.com/Katello/katello.git/commit/486c8881277e00730e760945e361b792d38d2b50))
 * getting 404 for /javascripts/bastion/angular-i18n/angular-locale_en.js on content hosts details page on reload ([#25114](https://projects.theforeman.org/issues/25114), [411faba4](https://github.com/Katello/katello.git/commit/411faba4cec1c8d7442d8b87a0d285f52e9ee69d))

### Candlepin
 * Katello::Content uses removed Katello::Glue::Candlepin::Product.import_product_content ([#26535](https://projects.theforeman.org/issues/26535), [1a4660e9](https://github.com/Katello/katello.git/commit/1a4660e9ff71165f7ce0c07df62a855ea166ab55))

### Hosts
 * System Purpose: Updating host SLA or usage type resets addons ([#26530](https://projects.theforeman.org/issues/26530), [3bc4f54a](https://github.com/Katello/katello.git/commit/3bc4f54accf4cf4b6444b2f1970f0c9bc08f0fa6))
 * Update syspurpose status handling to match Candlepin ([#26516](https://projects.theforeman.org/issues/26516), [4401f8cf](https://github.com/Katello/katello.git/commit/4401f8cf89144304f91651718482894cab21734f))
 * Registering a system fails randomly (409 Conflict) ([#26191](https://projects.theforeman.org/issues/26191), [94fdc445](https://github.com/Katello/katello.git/commit/94fdc4456bffe91590be2294e90cad548f8dae24), [7f880082](https://github.com/Katello/katello.git/commit/7f8800822c7d43414347d3e33e3d3ab704afa48e), [40f4927b](https://github.com/Katello/katello.git/commit/40f4927bf53ee6b42fb6c1517e1961adf48d86f1))
 * Tracer rex templates don't handle reboot properly ([#26185](https://projects.theforeman.org/issues/26185), [0432d0ec](https://github.com/Katello/katello.git/commit/0432d0ec16772dfd4eddf0adb9b79a426fd94e69), [9067e372](https://github.com/Katello/katello.git/commit/9067e3722e6d5182ad372f739d82d4c7169f60e1))
 * Missing timeout for "Actions::Katello::Host::Package::Update" task ([#25965](https://projects.theforeman.org/issues/25965), [7949d971](https://github.com/Katello/katello.git/commit/7949d971aabd65cd4d4f5dc765fcc961092a745f))
 * custom system purpose values not shown in content host details dropdowns ([#25832](https://projects.theforeman.org/issues/25832), [6c317ff9](https://github.com/Katello/katello.git/commit/6c317ff98ab3f4e2ed58b632dcb4209a8c6acbf3))
 * Virt-who reported host type is blank, under Hosts---> Content Hosts shows "Type" as blank ([#25818](https://projects.theforeman.org/issues/25818), [9b38ba7b](https://github.com/Katello/katello.git/commit/9b38ba7b74f52375d68780c039247108d49d706f))

### Hammer
 * hammer package info not showing if a package is modular ([#26469](https://projects.theforeman.org/issues/26469), [da0589a5](https://github.com/Katello/hammer-cli-katello.git/commit/da0589a548926534b1593cc6906b1630cf02cfc1))
 * hammer content-view update fails on --repositories ([#26091](https://projects.theforeman.org/issues/26091), [90e8f98a](https://github.com/Katello/hammer-cli-katello.git/commit/90e8f98af445e218d82f3d90a766d931c5cd8b00))
 * Non-grammatical error message when docker tags whitelist is being set for non-docker repos ([#26049](https://projects.theforeman.org/issues/26049), [a4870668](https://github.com/Katello/katello.git/commit/a4870668984eaae1fce03b002a8855488edf47c5))
 * exporting a CV with only puppet modules raises a tar error ([#26047](https://projects.theforeman.org/issues/26047), [1abe5820](https://github.com/Katello/hammer-cli-katello.git/commit/1abe58204d5caa7bf1cba4075bc9627772c10e2a))
 * user-related resolvers don't work when Katello hammer plugin enabled ([#26026](https://projects.theforeman.org/issues/26026), [e97297a2](https://github.com/Katello/hammer-cli-katello.git/commit/e97297a2cd8bf3b2b36eb09491be7af4c189df07))

### Modularity
 * Errata module association not getting indexed on Sync ([#26468](https://projects.theforeman.org/issues/26468), [2f6c9cdd](https://github.com/Katello/katello.git/commit/2f6c9cdd2a76a9db9d19fc645e72c19eebef2a0c))
 * As a user I would like to be  warned that modular rpms are not going to get filtered by my package filters ([#26227](https://projects.theforeman.org/issues/26227))
 * As a user I would not allow filtering of modular rpms in rpm filters (UI and API) ([#26223](https://projects.theforeman.org/issues/26223), [1c2c46f4](https://github.com/Katello/katello.git/commit/1c2c46f474d03f334b1cb2adf3b1c5876d093400))
 *  As a user I would like to search/display rpm as modular ([#26222](https://projects.theforeman.org/issues/26222))
 * As a user I want to index rpms as modular and show them in api response ([#26221](https://projects.theforeman.org/issues/26221), [a52a0cc2](https://github.com/Katello/katello.git/commit/a52a0cc25eaab51e1db6595dba37e315af93406f))

### GPG Keys
 * Satellite gpg key import removes newline ([#26463](https://projects.theforeman.org/issues/26463), [3249b27a](https://github.com/Katello/katello.git/commit/3249b27a9043bec01263a1a3a659f9499778e278))

### Foreman Proxy Content
 * Syncing Atomic Host Trees to capsule fails ([#26460](https://projects.theforeman.org/issues/26460), [0d4468eb](https://github.com/Katello/katello.git/commit/0d4468eb4383447045218a9cf042db4a2c9434c8))
 * [RFE] User control of Capsule sync policy and other traffic from Satellite to capsule ([#25633](https://projects.theforeman.org/issues/25633), [d9aaf9bc](https://github.com/Katello/katello.git/commit/d9aaf9bcd08a5c0156c0808860645cc834712a99))
 * Split out Katello and Smart Proxy Cron files ([#25289](https://projects.theforeman.org/issues/25289))

### Client/Agent
 * Could not perform package actions install/remove on rhel 8 clients ([#26446](https://projects.theforeman.org/issues/26446), [ed3b1d19](https://github.com/Katello/katello-host-tools.git/commit/ed3b1d1949add3455635e65a79c0eb9085444ece))

### Subscriptions
 * manifest upload duplicate key value violates unique constraint ([#26412](https://projects.theforeman.org/issues/26412), [c71a605e](https://github.com/Katello/katello.git/commit/c71a605e4cd3f0d9b0abbe7ff3e7bf94ffde137b))
 * Katello::Pool.import_all unnecessarily slow ([#26365](https://projects.theforeman.org/issues/26365), [81191940](https://github.com/Katello/katello.git/commit/81191940af928511d7a118b069f408f1d9597de0))
 * allow for duplicate virt-who hypervisor names when uploading with hypervisor_id=uuid ([#26351](https://projects.theforeman.org/issues/26351), [b92de0e6](https://github.com/Katello/katello.git/commit/b92de0e6bda9c7587087a53c6ec5dc08d3d6863d))
 * production.log filled with too many no route errors for rhsm/consumer URLs for accessible_content calls ([#26350](https://projects.theforeman.org/issues/26350), [5be88e31](https://github.com/Katello/katello.git/commit/5be88e31fa846d19b43f5ba0783737697fa73444))
 * "Requires Virt-Who" column not listed on Red Hat Subscriptions page ([#26300](https://projects.theforeman.org/issues/26300), [72c0d1d7](https://github.com/Katello/katello.git/commit/72c0d1d7ac50af6c3342bde9900a5b3041fbbeb0))
 * when manifest import task fails, no indication is given on manifest import page ([#26258](https://projects.theforeman.org/issues/26258), [138bd2af](https://github.com/Katello/katello.git/commit/138bd2afc8870dae25b1b3ef064a1ead0c1bbe61))
 * Search filter for hypervisor prompt errror message "Unsupported type ':boolean')' for field 'hypervisor'" on click ([#26255](https://projects.theforeman.org/issues/26255), [d105d1e1](https://github.com/Katello/katello.git/commit/d105d1e1eda78a8d53afdc9c36f50804c2ea74fc))
 * Manifest upload task takes too much time ([#25981](https://projects.theforeman.org/issues/25981), [74506f5b](https://github.com/Katello/katello.git/commit/74506f5b68c485412e9928bdce2b62ac7b12bb12), [6720091c](https://github.com/Katello/katello.git/commit/6720091c283e951eccba5e1150398a4edae07a97))
 * Subscription allocation on customer portal changes back to 6.3 from 6.4 after a manifest refresh from upgraded server ([#25937](https://projects.theforeman.org/issues/25937), [72de72bb](https://github.com/Katello/katello.git/commit/72de72bba331f8501cdf62661910eb65160022ed))
 * There is no "Type" attribute column for subscription under "Content" -> "Subscriptions ([#25906](https://projects.theforeman.org/issues/25906), [54c67187](https://github.com/Katello/katello.git/commit/54c6718708fa787e6d25c87285d9b68889cfaf1e))
 * Change "Red Hat Subscriptions" to "Subscriptions" ([#25837](https://projects.theforeman.org/issues/25837), [95725c39](https://github.com/Katello/katello.git/commit/95725c39d6aacff37e01edeacd0cd0f7543b3429))
 * Error when uploading a manifest file on the disconnected Server ([#25834](https://projects.theforeman.org/issues/25834), [8fb1cc5d](https://github.com/Katello/katello.git/commit/8fb1cc5d7bf8ed1372777acca48635169451d2fd))
 * Unable to add same subscription more than once in Satellite ([#25115](https://projects.theforeman.org/issues/25115))

### Tooling
 * remove lazy_accessor change tracking ([#26376](https://projects.theforeman.org/issues/26376), [6b605bee](https://github.com/Katello/katello.git/commit/6b605bee625d53853762fea30fb0633cb8dab9cc))

### Docker
 * Unable to create docker repository when "Registry Name Pattern" is set in LE ([#26304](https://projects.theforeman.org/issues/26304), [8455f5e1](https://github.com/Katello/katello.git/commit/8455f5e1a7e1218501bfe01d84cad03ced5f1e63))

### Inter Server Sync
 * Content View version export with huge contents gets timed out ([#26257](https://projects.theforeman.org/issues/26257), [3dfc3237](https://github.com/Katello/hammer-cli-katello.git/commit/3dfc3237631d2241cbd0bb43049fdc3ce5555b16))

### Installer
 * katello-ssl-tool fails on nightly ([#26188](https://projects.theforeman.org/issues/26188))

### API
 * Expose route for system purpose compliance ([#25955](https://projects.theforeman.org/issues/25955), [a0a26726](https://github.com/Katello/katello.git/commit/a0a26726d3f24ab41c9c6500c93a33196341434a))

### Dashboard
 * slow errata query on dashboard ([#25884](https://projects.theforeman.org/issues/25884), [227f1ab0](https://github.com/Katello/katello.git/commit/227f1ab0de9cda4a557e12099ac5967fdf40236f))

### Documentation
 * docs still refer to 'gpg keys' instead of content credentials  ([#25841](https://projects.theforeman.org/issues/25841))

### Lifecycle Environments
 * Repositories drop downs show duplicate named repositories ([#25034](https://projects.theforeman.org/issues/25034), [9ee1692f](https://github.com/Katello/katello.git/commit/9ee1692f90af61b5a57e8a439db3071dfc570f08))

### Other
 * Errata details overflows into affected packages column ([#26683](https://projects.theforeman.org/issues/26683), [ad4e4f19](https://github.com/Katello/katello.git/commit/ad4e4f19909b863f5235bb6222e8d1dadb0702da))
 * Don't ship katello-host-tools-fact-plugin in rhel8 sat-tools ([#26661](https://projects.theforeman.org/issues/26661))
 * Registering a host with the same hostname as another host unregisters the original host ([#26640](https://projects.theforeman.org/issues/26640), [cf57e0d0](https://github.com/Katello/katello.git/commit/cf57e0d065fbb39b9f7787c5907a9bfb6f554b64))
 * Rubocop 0.66 updates ([#26570](https://projects.theforeman.org/issues/26570), [c1ca09b2](https://github.com/Katello/katello.git/commit/c1ca09b23a768f2599306c27a738f153ec14c7e8))
 * Unauthenticated pull not working for Head requests ([#26549](https://projects.theforeman.org/issues/26549), [dddaaade](https://github.com/Katello/katello.git/commit/dddaaadeedfd93ddf7c07d48f7c4c4c85a345091))
 * registration fails if puppet fact with dmi::system::uuid exists in foreman ([#26480](https://projects.theforeman.org/issues/26480), [75452bf9](https://github.com/Katello/katello.git/commit/75452bf9867fbf3b40c2f581a347bff99d210875))
 * "Red Hat Registry" is ambiguous ([#26470](https://projects.theforeman.org/issues/26470), [2d46c667](https://github.com/Katello/katello.git/commit/2d46c6674a8e3be83b8c81e4a7d91eb074ee692f))
 * katello test failure on test_develop_katello_pr katello ([#26459](https://projects.theforeman.org/issues/26459), [12762f99](https://github.com/Katello/katello.git/commit/12762f99c9dc49e4d969cfcff47bbfa4845a3467))
 * katello-tracer-upload: command not found on rhel8 clients ([#26440](https://projects.theforeman.org/issues/26440), [8bb1154c](https://github.com/Katello/katello-host-tools.git/commit/8bb1154c1402c8d747d615ed86b6dcc9f9623816))
 * README on Katello Repository on github has broken link ([#26398](https://projects.theforeman.org/issues/26398), [c0a67d54](https://github.com/Katello/katello.git/commit/c0a67d5459833c03ea6565c8c704eaad6865d5c1))
 * Actions::Katello::Repository::Clear doesn't track actions ([#26395](https://projects.theforeman.org/issues/26395), [67c0117a](https://github.com/Katello/katello.git/commit/67c0117aaa76bf2e19de5911fc6bd440e79df727))
 * Incremental update with errata should copy all modules over to resulting cv ([#26364](https://projects.theforeman.org/issues/26364), [2a588e11](https://github.com/Katello/katello.git/commit/2a588e11361f78d41e3d127a7e3198fe9b1ae777))
 * tracer plugin to yum/dnf prevents yum/dnf from working if tracer is broken ([#26363](https://projects.theforeman.org/issues/26363), [41f59686](https://github.com/Katello/katello-host-tools.git/commit/41f5968612d04bae1692a268628edaacf6272f46))
 * HTML table created in sync_status page is invalid ([#26309](https://projects.theforeman.org/issues/26309), [9dae605d](https://github.com/Katello/katello.git/commit/9dae605dea2fb229b1df0580fc823116a256c6df))
 * Extract strings for katello cli ([#26178](https://projects.theforeman.org/issues/26178), [41498de4](https://github.com/Katello/hammer-cli-katello.git/commit/41498de4e417244cbd877599e72e60e82823454b))
 * Extract latest strings for Katello and Bastion ([#26176](https://projects.theforeman.org/issues/26176), [48acd2ee](https://github.com/Katello/katello.git/commit/48acd2ee14fb54fd79f1b1005dae988555230a84))
 * Remove foreman-docker as a dependency ([#26165](https://projects.theforeman.org/issues/26165), [71c2c3ea](https://github.com/Katello/katello.git/commit/71c2c3ea2005cfb4245bfd2169c90080cbdfd072), [b635a7b6](https://github.com/Katello/katello.git/commit/b635a7b6151ac9a640abf5c9f6174fe488c5331f), [90cd19da](https://github.com/Katello/katello.git/commit/90cd19dadfca45db4d4dc2a59bc4f80bdaf02be6), [049cef97](https://github.com/Katello/katello.git/commit/049cef97855561d686d29016c9ad21c1f772dd28))
 * system purpose dropdowns are not disabled when no values present ([#26117](https://projects.theforeman.org/issues/26117), [cd14da93](https://github.com/Katello/katello.git/commit/cd14da93b79bdb8456aadeb92ef18751b1c2fadb))
 * Removing recurring logic fails with `katello_sync_plans.recurring_logic_id does not exist` ([#26028](https://projects.theforeman.org/issues/26028), [0f752247](https://github.com/Katello/katello.git/commit/0f752247afe4c00be788390c0fc78a5a50da190a))
 * Can't sync discovered containers without slash in name from Docker.io registry ([#25972](https://projects.theforeman.org/issues/25972), [c490d55e](https://github.com/Katello/katello.git/commit/c490d55ed1012aac08e10dacc4e581d19125fbea), [1625f449](https://github.com/Katello/katello.git/commit/1625f449d1db536d74eeebfa296d61bfd604e1c6), [38587f48](https://github.com/Katello/katello.git/commit/38587f481460b053cf5ddfc9f15c3c5c8a36044c))
 * hammer shows "Container Image Tags Filter" for non-docker repositories ([#25915](https://projects.theforeman.org/issues/25915), [f911d42a](https://github.com/Katello/hammer-cli-katello.git/commit/f911d42a392d7460bd8810a2aca61d93e338ddc4))
 * subscription changes to a content host are not audited ([#23912](https://projects.theforeman.org/issues/23912), [88c1fb4c](https://github.com/Katello/katello.git/commit/88c1fb4c41c37f84fa023ef9b8f6b05413ca6172))
