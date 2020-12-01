# 3.17.1 (2020-12-01)

## Bug Fixes

### Hosts
 * Hypervisors upload fails with duplicate UUIDs ([#30826](https://projects.theforeman.org/issues/30826), [59210c07](https://github.com/Katello/katello.git/commit/59210c0704e6935e045d6cb20584618862bac368))

 ### Errata Management 
 * Katello Pulp 3 Applicability errors out when deleted hosts are plucked from the queue ([#31321](https://projects.theforeman.org/issues/31321), [260c0ff](https://github.com/Katello/katello/pull/9041/commits/260c0ff7e2280a686a9a06ddf77b3a686a3e46fa))

 ### Repositories
 * “NoMethodError: undefined method `repository_href’ for nil:NilClass” when syncing yum repos ([#31247](https://projects.theforeman.org/issues/31247), [6ef23ff](https://github.com/Katello/katello.git/commit/6ef23ff41adaeeb13feab7ec8fbebceb792cb313))

### Content Views
* publishing a content view w/ a filter with multiple repositories and 10K+ rpms will result in empty repos ([#31268](https://projects.theforeman.org/issues/31268), [59a20b7](https://github.com/Katello/katello.git/commit/59a20b76a851f690d2b1325180ab4e3021c5cf82))

# 3.17.0 (2020-11-06)

## Features

### Repositories
 * Add pulp_href to repositories API ([#30745](https://projects.theforeman.org/issues/30745), [a0305b7f](https://github.com/Katello/katello.git/commit/a0305b7f8ce043efffd614372e96b27c9236f05f))
 * Capsule - SSL Authentication Guard across all types ([#29995](https://projects.theforeman.org/issues/29995), [be3dd332](https://github.com/Katello/katello.git/commit/be3dd332854055dfb23206e0427adc9aafb21e47))
 * Support yum migration for pulp3 ([#29959](https://projects.theforeman.org/issues/29959), [5a2b891f](https://github.com/Katello/katello.git/commit/5a2b891f0bda6be0cb2791685e2c0f211ad0fb56), [4fe9e26d](https://github.com/Katello/katello.git/commit/4fe9e26d268aa4b60ec2eab9ba77219275a04327), [104bea71](https://github.com/Katello/katello.git/commit/104bea7110cb57bb26ba4b9c2864a3a12d28c720))

### Tooling
 * upgrade to pulp 3.6 ([#30630](https://projects.theforeman.org/issues/30630), [a5cec538](https://github.com/Katello/katello.git/commit/a5cec538c4b6943ab7326155f836774a4c37e268), [aace1e04](https://github.com/Katello/katello.git/commit/aace1e0406cc8b91c7423f5a4cb4d3431d110f1b), [b236224c](https://github.com/Katello/katello.git/commit/b236224c7de85bc0a5f0e88e1fe5da1d089c806f), [444a8a87](https://github.com/Katello/katello.git/commit/444a8a873f6d2354be3475b03972ff73dd0f628d), [60f40f89](https://github.com/Katello/katello.git/commit/60f40f8989fadb1cbc7ef237aa08c7e2c9756b76), [42797591](https://github.com/Katello/katello.git/commit/427975911bce0974413bc466683da5037b578ca4))

### Errata Management
 * Allow filtering errata applications by host on applied errata report ([#30626](https://projects.theforeman.org/issues/30626), [05a66170](https://github.com/Katello/katello.git/commit/05a661709a1f846528202262f0a7a63d89a748f2))

### Client/Agent
 * Job Template install_errata_-_katello_ansible_default.erb only works with yum ([#30619](https://projects.theforeman.org/issues/30619), [fcb47422](https://github.com/Katello/katello.git/commit/fcb474226d4b38dd244d83000bda8cb9a69604fc))

### Subscriptions
 * Activation Key repository list should be in 'Show All' mode by default with Organization Env Access aka Simple Content Access" ([#30592](https://projects.theforeman.org/issues/30592), [a2e534d0](https://github.com/Katello/katello.git/commit/a2e534d096ec36d28dd0de145d5671c8d6ffd7a9))
 * [sat-e-492] Disable or enable a repo by default under product/repo ([#29951](https://projects.theforeman.org/issues/29951), [80c3541a](https://github.com/Katello/katello.git/commit/80c3541a0c42c3e4c5f71ec216dc808aefb00efd))
 * [sat-e-492] As a user, I should not be able to attach a subscription to an activation key with SCA enabled ([#29929](https://projects.theforeman.org/issues/29929), [9e9228f4](https://github.com/Katello/katello.git/commit/9e9228f4d29601efefe8e95b36ca60fe9f199978))
 * [sat-e-492] Remove both Subscription widgets from Dashboard when SCA is enabled ([#29928](https://projects.theforeman.org/issues/29928), [1c67208b](https://github.com/Katello/katello.git/commit/1c67208baef7fed418c171e3dbecfdda25eb12ae))
 * [sat-e-492] Add Simple Content Access messaging & links ([#29927](https://projects.theforeman.org/issues/29927), [39c777e1](https://github.com/Katello/katello.git/commit/39c777e1f5485da4ae03e0ea64380a8a0c93bb0d))
 * [sat-e-492] In Organization details, show Simple Content Access status ([#29926](https://projects.theforeman.org/issues/29926), [f410eafc](https://github.com/Katello/katello.git/commit/f410eafc84d342c3d44405179a08d4400a717850))
 * [sat-e-492] Allow the user to toggle Simple Content Access on/off  ([#29925](https://projects.theforeman.org/issues/29925), [e3673e7f](https://github.com/Katello/katello.git/commit/e3673e7fa0051adb2e70cc46a3d919929131f3a1))
 * [sat-e-492] As a user, I should not be able to attach a subscription to a host with SCA enabled ([#29791](https://projects.theforeman.org/issues/29791), [dd84b037](https://github.com/Katello/katello.git/commit/dd84b0370efafdcd5f582d5d99a76f4401ee43da))

### Foreman Proxy Content
 * Support 'repair-sync for deb-repository on SmartProxy ([#30530](https://projects.theforeman.org/issues/30530), [970dc18b](https://github.com/Katello/katello.git/commit/970dc18bdcce62ea1000ef27c0c1d2fb09f4c79a))

### Content Views
 * Add a way to show both added and available repositories to a Content View to the API ([#30524](https://projects.theforeman.org/issues/30524), [777d076c](https://github.com/Katello/katello.git/commit/777d076ce6b4eb65d15409fe039a3dfee17fcf45))
 * [Pulp3] - As a developer I 'd like to export a content view version  ([#30479](https://projects.theforeman.org/issues/30479), [67287c07](https://github.com/Katello/katello.git/commit/67287c07475207cf24223121afd3343349e05076))
 * Content View Page - add pagination to main CV table ([#29832](https://projects.theforeman.org/issues/29832), [7c7f2926](https://github.com/Katello/katello.git/commit/7c7f29269ac6d38bbac2ac825d308618fbbb2526))
 * [cv table] Create faceted (?) search ([#29307](https://projects.theforeman.org/issues/29307), [8f592663](https://github.com/Katello/katello.git/commit/8f592663f699f07656cb37cbda847eac74df5116))

### Documentation
 * Document the Repository model ([#30267](https://projects.theforeman.org/issues/30267), [d148051c](https://github.com/Katello/katello.git/commit/d148051cb8023d8fe02f746e76ec980c841f9822))
 * Document the ContentView model ([#30266](https://projects.theforeman.org/issues/30266), [77dd7578](https://github.com/Katello/katello.git/commit/77dd75782560c72fae082824728e6b27ab98b3d0))
 * Document the ContentFacet model ([#30265](https://projects.theforeman.org/issues/30265), [66fc6f0a](https://github.com/Katello/katello.git/commit/66fc6f0a97e63e458e27c62249d4189c167a73f8))
 * Document the RootRepository model ([#30264](https://projects.theforeman.org/issues/30264), [d148051c](https://github.com/Katello/katello.git/commit/d148051cb8023d8fe02f746e76ec980c841f9822))
 * Document the ContentViewVersion model ([#30263](https://projects.theforeman.org/issues/30263), [77dd7578](https://github.com/Katello/katello.git/commit/77dd75782560c72fae082824728e6b27ab98b3d0))
 * Document the KTenvironment model ([#30262](https://projects.theforeman.org/issues/30262), [77dd7578](https://github.com/Katello/katello.git/commit/77dd75782560c72fae082824728e6b27ab98b3d0))
 * Document the Product model ([#30261](https://projects.theforeman.org/issues/30261), [77dd7578](https://github.com/Katello/katello.git/commit/77dd75782560c72fae082824728e6b27ab98b3d0))
 * Document the Erratum model ([#30260](https://projects.theforeman.org/issues/30260), [e0bdef1d](https://github.com/Katello/katello.git/commit/e0bdef1d21a1175dddf73ec98482972a8f88340c))
 * Document the Host::Managed model ([#30259](https://projects.theforeman.org/issues/30259), [abcc324f](https://github.com/Katello/katello.git/commit/abcc324f07aac9e4b3551af6d12397dfb905dea8))
 * Document the HostCollection model ([#30258](https://projects.theforeman.org/issues/30258), [abcc324f](https://github.com/Katello/katello.git/commit/abcc324f07aac9e4b3551af6d12397dfb905dea8))
 * Document the Hostgroup model ([#30257](https://projects.theforeman.org/issues/30257), [abcc324f](https://github.com/Katello/katello.git/commit/abcc324f07aac9e4b3551af6d12397dfb905dea8))
 * Document the Pool model ([#30256](https://projects.theforeman.org/issues/30256), [5d94b4c6](https://github.com/Katello/katello.git/commit/5d94b4c6389db8e6ca6651ac653655835d4d41e6))
 * Document the InstalledPackage model ([#30255](https://projects.theforeman.org/issues/30255), [820d24a5](https://github.com/Katello/katello.git/commit/820d24a5f7fa8c4a534120ab0afd099c7185a466))
 * Document the ErratumCve model ([#30254](https://projects.theforeman.org/issues/30254), [e0bdef1d](https://github.com/Katello/katello.git/commit/e0bdef1d21a1175dddf73ec98482972a8f88340c))
 * Add documentation for models ([#30253](https://projects.theforeman.org/issues/30253))

### SElinux
 * Selinux change for Candlepin on port 23443 ([#30087](https://projects.theforeman.org/issues/30087))

## Bug Fixes

### Repositories
 * Revert #29951 -  Auto Enable/Disable repository  ([#30841](https://projects.theforeman.org/issues/30841), [e0df12cf](https://github.com/Katello/katello.git/commit/e0df12cfa16b382cbd426fd1b4788fd35666a6b3))
 * No longer able to tag docker image using hammer after upgrading to Satellite 6.7/6.8 ([#30825](https://projects.theforeman.org/issues/30825), [a75120cb](https://github.com/Katello/hammer-cli-katello.git/commit/a75120cb7755a318c4ac55c7fdb695e7adac06b2))
 * Set sles_auth_token in yum-repository form for synching SLES-repos from SCC ([#30752](https://projects.theforeman.org/issues/30752), [3968c441](https://github.com/Katello/katello.git/commit/3968c441d7805b29ffdcb3e5665317ff8f36c49f))
 * Make download_concurrency configurable in pulpcore ([#30488](https://projects.theforeman.org/issues/30488), [a9e9869e](https://github.com/Katello/katello.git/commit/a9e9869ec2a3a98a81751f4df00811fe034719ed))
 * As a developer I 'd like DeleteRepositoryReferenceTest to run ([#30482](https://projects.theforeman.org/issues/30482), [88e4ae4f](https://github.com/Katello/katello.git/commit/88e4ae4fa456afdd54a3cd9d71f336ae4913ae4d))
 * Failed Repository enable/create task can leave orphan repo root objects in db ([#30480](https://projects.theforeman.org/issues/30480), [89f1bb6e](https://github.com/Katello/katello.git/commit/89f1bb6e07b91e79648fd06115d9bef6577a3ba6))
 * repositories controller does not respect permissions ([#30380](https://projects.theforeman.org/issues/30380), [edcc122c](https://github.com/Katello/katello.git/commit/edcc122cd5127d821e458f3b46ba0e049e7831a4))
 * Validation failed: Title has already been taken during first time repository sync ([#30571](https://projects.theforeman.org/issues/30571), [82520222](https://github.com/Katello/katello.git/commit/825202223ffe7f26569d7e26178d87c386424e99))
 * Repository create fails when only Pulp 3 is installed (EL8) ([#30168](https://projects.theforeman.org/issues/30168), [4171a36f](https://github.com/Katello/katello.git/commit/4171a36f2bdb3a309861d87ab7412d70a8205f76), [54f22aef](https://github.com/Katello/katello.git/commit/54f22aefc038a0dc5e21afc801ea84df2b76616e))
 * Skip audit record creation when content changed in the root repository ([#30082](https://projects.theforeman.org/issues/30082), [51eb4925](https://github.com/Katello/katello.git/commit/51eb49258413867c5d65b08cec033c3c7ea23a85))

### Errata Management
 * Zypper waits for user input during application of errata ([#30795](https://projects.theforeman.org/issues/30795), [1fdc5f52](https://github.com/Katello/katello.git/commit/1fdc5f52bc8e61abf9db3d4f1397851fd220cf7e))
 * Host errata status not refresh after CV publish/promote ([#30427](https://projects.theforeman.org/issues/30427), [d21e5db0](https://github.com/Katello/katello.git/commit/d21e5db0f09e218f1ac30d1bbccad4ba845ea741))
 * Oops page when trying perform action on all systems from content host page ([#30350](https://projects.theforeman.org/issues/30350), [11f0ce3c](https://github.com/Katello/katello.git/commit/11f0ce3cda7414d75d6d99e685e56a67c8f45aa7))

### Subscriptions
 * User can perform other manifest actions while the first one starts ([#30591](https://projects.theforeman.org/issues/30591), [9a18b96b](https://github.com/Katello/katello.git/commit/9a18b96b9e8b6b13ec1926fed1316cd12c730dfe), [817cb4b2](https://github.com/Katello/katello.git/commit/817cb4b274f82d645079d32e4aeb05a4c1830e4d))
 * System purpose status should show as 'disabled' when Satellite is in Simple Content Access mode ([#30522](https://projects.theforeman.org/issues/30522), [9c17faa3](https://github.com/Katello/katello.git/commit/9c17faa3045b22dcf8df898601d4162a0e1405e8))
 * Opening blank page if click on "Guest of virt-who" link under Content -> Subscription ([#30391](https://projects.theforeman.org/issues/30391), [065b093c](https://github.com/Katello/katello.git/commit/065b093cd9ee24f317cd9eeb27ddeee517652d8b))
 * Subscription status should be reset when rebuilding a Host ([#26977](https://projects.theforeman.org/issues/26977), [27c8af70](https://github.com/Katello/katello.git/commit/27c8af701f385410220f95954705e601b05daac7))
 * Selecting a group subscription collapses opened menu ([#26954](https://projects.theforeman.org/issues/26954), [a87652d9](https://github.com/Katello/katello.git/commit/a87652d9a578854fe48c9be5bc3a6468f2b1bb5f))
 * Attaching a subscription via API does not provide correct output ([#30155](https://projects.theforeman.org/issues/30155), [4e5bccc0](https://github.com/Katello/katello.git/commit/4e5bccc08aa8414a15403ae603467d5274a6fe66))

### Web UI
 * Content -> Product doesn't work when no organization is selected ([#30580](https://projects.theforeman.org/issues/30580), [0e9ae146](https://github.com/Katello/katello.git/commit/0e9ae146969244b6f1150dda854a10d07074c144))
 * Fix breaking changes for upgrade to @patternfly/react v4 major version bump ([#30239](https://projects.theforeman.org/issues/30239), [548c4aa0](https://github.com/Katello/katello.git/commit/548c4aa0a7ca5d680538ea090f8deaf98ab5df84))

### Hammer
 * Add deb package CLI support ([#30579](https://projects.theforeman.org/issues/30579))
 * Hammer repository info does not show description ([#30464](https://projects.theforeman.org/issues/30464), [89afd8b7](https://github.com/Katello/hammer-cli-katello.git/commit/89afd8b7c3ae312595912a404d7986baf91e8dd7))

### Tests
 * Intermittent LoadError for Messaging tests ([#30521](https://projects.theforeman.org/issues/30521), [eabd4e79](https://github.com/Katello/katello.git/commit/eabd4e79ff2e9445f183a2f3e61dc8fc033e0eff))
 * transient test failure Actions::Katello::ContentView::CapsuleSyncTest ([#30434](https://projects.theforeman.org/issues/30434), [d2ec23ee](https://github.com/Katello/katello.git/commit/d2ec23eec71a8cfc1578c055a93e6353a5636dc1))
 * react-testing-library keeps timing out on Jenkins ([#30411](https://projects.theforeman.org/issues/30411), [883baf75](https://github.com/Katello/katello.git/commit/883baf75db86703a3c5efa63baca17e6388c46ea))
 * Fix timeout issue in React content view test ([#30336](https://projects.theforeman.org/issues/30336), [bab3adfd](https://github.com/Katello/katello.git/commit/bab3adfd6b7b599e08512bb34a9a13752cb088b3))
 * Stop collecting coverage from React tests ([#30335](https://projects.theforeman.org/issues/30335), [16fd8914](https://github.com/Katello/katello.git/commit/16fd8914e85b613aa71ded31a187b54d6de688a2))
 * Correct APIMiddleware path for react tests ([#30157](https://projects.theforeman.org/issues/30157), [015620aa](https://github.com/Katello/katello.git/commit/015620aaef75234588e422204b11fa25d2d9a248))
 * Update React testing to use @theforeman/find-foreman ([#30137](https://projects.theforeman.org/issues/30137), [cb7a2632](https://github.com/Katello/katello.git/commit/cb7a263205d76e69e268f848a434ba0db03384dc))
 * Some tests set, but don't unset, ENV variables ([#29975](https://projects.theforeman.org/issues/29975), [7e3d56ad](https://github.com/Katello/katello.git/commit/7e3d56ad60754493be90f587268164c2f2b5cf6d))
 * Remove duplicate npm dependencies in Katello ([#29905](https://projects.theforeman.org/issues/29905), [243881b4](https://github.com/Katello/katello.git/commit/243881b4be54eeddfe8337205bdfbcc92c8ccf4d))

### Hosts
 * Errata status messages are unclear ([#30452](https://projects.theforeman.org/issues/30452), [43074f2f](https://github.com/Katello/katello.git/commit/43074f2f9e8cfe940520c5dde9fa22487bc64a23))
 * Changing a Content View on a single Content Host twice throws an angular error but works still ([#30361](https://projects.theforeman.org/issues/30361), [78b015ec](https://github.com/Katello/katello.git/commit/78b015ecb1f808cb6a7317a241e89bf56643af02))
 * undefined method `klass' for nil:NilClass ([#30238](https://projects.theforeman.org/issues/30238), [e62c1d83](https://github.com/Katello/katello.git/commit/e62c1d835474ce56612492197f3f50f0c5ed731b))
 * Cannot delete Hostgroup with Content Facet ([#30184](https://projects.theforeman.org/issues/30184), [57ef04fe](https://github.com/Katello/katello.git/commit/57ef04fe61c22bbecdb7be10037bee4c98e168bb))
 * Lock default Job templates ([#29956](https://projects.theforeman.org/issues/29956), [cf1bf090](https://github.com/Katello/katello.git/commit/cf1bf09002252669c997b6317868582d2c35b465))
 * Changing Content View of a Content Host needs to better inform the user around client needs ([#17798](https://projects.theforeman.org/issues/17798), [52cce6e8](https://github.com/Katello/katello.git/commit/52cce6e8413c81953ee2d7d5c9fbcaa99e5d918e), [8c257840](https://github.com/Katello/katello.git/commit/8c257840cb800cc3c415eb1c76be615b9fc0817f))

### Tooling
 * Event daemon throws errors after code reloading in development ([#30448](https://projects.theforeman.org/issues/30448), [4c83a1ea](https://github.com/Katello/katello.git/commit/4c83a1ea00ee79bb97db12b9df916559e968354c))
 * require REX for katello ([#30409](https://projects.theforeman.org/issues/30409), [bb2bb217](https://github.com/Katello/katello.git/commit/bb2bb2175bcac0d1b8110d66ca49f1d8739fa057))

### Content Views
 * Hammer export-legacy Fails with Composite Content Views ([#30405](https://projects.theforeman.org/issues/30405), [c6c7fafc](https://github.com/Katello/katello.git/commit/c6c7fafc64c7b8718b300e11892e85d4e23efa57))
 * ActiveRecord::RecordNotUnique: PG::UniqueViolation: ERROR: duplicate key value violates unique constraint  ([#30322](https://projects.theforeman.org/issues/30322), [93395276](https://github.com/Katello/katello.git/commit/933952768309480bf742b4369805130bbaa6bf27))
 * Searching for just "composite" in content views page causes ISE ([#30079](https://projects.theforeman.org/issues/30079), [8a1c4fa4](https://github.com/Katello/katello.git/commit/8a1c4fa46d9fb4b0ee941b08f0278a84600e87d6))
 * Add new content view details page with details tab ([#29996](https://projects.theforeman.org/issues/29996), [64f9d6a7](https://github.com/Katello/katello.git/commit/64f9d6a7dfcf4347ec8937ecf42642adfbed8512))
 * Apply Errata to a Content Host via incremental CV has to wait till Capsule sync of the CV finishes ([#25921](https://projects.theforeman.org/issues/25921), [dfc27450](https://github.com/Katello/katello.git/commit/dfc2745080810e967a69ba311125b0a335ba2417))
 * Hammer --resolve-dependencies flag not working ([#17608](https://projects.theforeman.org/issues/17608), [70035844](https://github.com/Katello/katello.git/commit/70035844356d12dcaa4020ddbce68d995b049b9c))
 * As a user, i can import a content view version export into an existing content view ([#30004](https://projects.theforeman.org/issues/30004), [dce578c1](https://github.com/Katello/katello.git/commit/dce578c1648a9eec1b2e4b2954c6cd1aa3519f9e))
 * As a user I  would like to the see the history events associated with my content view version ([#29999](https://projects.theforeman.org/issues/29999), [9dc14ebc](https://github.com/Katello/katello.git/commit/9dc14ebc5e8d5351b15e1d9c8bb82855b7964bbd))
 * List of Content Views on Create Host or Hostgroup page unordered if the field was prefilled ([#30077](https://projects.theforeman.org/issues/30077), [7cdf27a5](https://github.com/Katello/katello.git/commit/7cdf27a5fd80d34e81325b1ce108e03fe7f972aa))

### Sync Plans
 * Sync plan time handling still doesn't behave as expected ([#30371](https://projects.theforeman.org/issues/30371), [54731788](https://github.com/Katello/katello.git/commit/5473178806f66149b77df1026f23f1e766ebb1d4))

### Activation Key
 * Activation key page loading is very slow ([#30270](https://projects.theforeman.org/issues/30270), [c973aad6](https://github.com/Katello/katello.git/commit/c973aad6f8b1caca5f997a895b65c6cbb273b7a3))

### Installer
 * capsule-certs-generate failed to increment release number when generating certificate rpm for foreman-proxy ([#15932](https://projects.theforeman.org/issues/15932))

### Other
 * Bastion Katello translation strings need to be updated ([#30108](https://projects.theforeman.org/issues/30108), [4ae270c2](https://github.com/Katello/katello.git/commit/4ae270c21c60b8277a9faec6a6e29aa31cfcede5))
 * Remove react-tokens from katello's package.json ([#29879](https://projects.theforeman.org/issues/29879), [82b0fe0b](https://github.com/Katello/katello.git/commit/82b0fe0b6f93e11214b65bf6f2682d2f7c5e1b17))