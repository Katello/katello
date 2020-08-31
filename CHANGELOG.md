# 3.17.0 (2020-08-31)

## Features

### Client/Agent
 * Job Template install_errata_-_katello_ansible_default.erb only works with yum ([#30619](https://projects.theforeman.org/issues/30619), [fcb47422](https://github.com/Katello/katello.git/commit/fcb474226d4b38dd244d83000bda8cb9a69604fc))

### Foreman Proxy Content
 * Support 'repair-sync for deb-repository on SmartProxy ([#30530](https://projects.theforeman.org/issues/30530), [970dc18b](https://github.com/Katello/katello.git/commit/970dc18bdcce62ea1000ef27c0c1d2fb09f4c79a))

### Content Views
 * Add a way to show both added and available repositories to a Content View to the API ([#30524](https://projects.theforeman.org/issues/30524), [777d076c](https://github.com/Katello/katello.git/commit/777d076ce6b4eb65d15409fe039a3dfee17fcf45))
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

### Repositories
 * Support verify checksum scan in pulp3 ([#30190](https://projects.theforeman.org/issues/30190))
 * Capsule - SSL Authentication Guard across all types ([#29995](https://projects.theforeman.org/issues/29995), [be3dd332](https://github.com/Katello/katello.git/commit/be3dd332854055dfb23206e0427adc9aafb21e47))

### SElinux
 * Selinux change for Candlepin on port 23443 ([#30087](https://projects.theforeman.org/issues/30087))

### Subscriptions
 * [sat-e-492] Disable or enable a repo by default under product/repo ([#29951](https://projects.theforeman.org/issues/29951), [80c3541a](https://github.com/Katello/katello.git/commit/80c3541a0c42c3e4c5f71ec216dc808aefb00efd))
 * [sat-e-492] As a user, I should not be able to attach a subscription to an activation key with SCA enabled ([#29929](https://projects.theforeman.org/issues/29929), [9e9228f4](https://github.com/Katello/katello.git/commit/9e9228f4d29601efefe8e95b36ca60fe9f199978))
 * [sat-e-492] As a user, I should not be able to attach a subscription to a host with SCA enabled ([#29791](https://projects.theforeman.org/issues/29791), [dd84b037](https://github.com/Katello/katello.git/commit/dd84b0370efafdcd5f582d5d99a76f4401ee43da))

## Bug Fixes

### Subscriptions
 * User can perform other manifest actions while the first one starts ([#30591](https://projects.theforeman.org/issues/30591), [9a18b96b](https://github.com/Katello/katello.git/commit/9a18b96b9e8b6b13ec1926fed1316cd12c730dfe), [817cb4b2](https://github.com/Katello/katello.git/commit/817cb4b274f82d645079d32e4aeb05a4c1830e4d))
 * Opening blank page if click on "Guest of virt-who" link under Content -> Subscription ([#30391](https://projects.theforeman.org/issues/30391), [065b093c](https://github.com/Katello/katello.git/commit/065b093cd9ee24f317cd9eeb27ddeee517652d8b))
 * Subscription status should be reset when rebuilding a Host ([#26977](https://projects.theforeman.org/issues/26977), [27c8af70](https://github.com/Katello/katello.git/commit/27c8af701f385410220f95954705e601b05daac7))
 * Selecting a group subscription collapses opened menu ([#26954](https://projects.theforeman.org/issues/26954), [a87652d9](https://github.com/Katello/katello.git/commit/a87652d9a578854fe48c9be5bc3a6468f2b1bb5f))
 * Attaching a subscription via API does not provide correct output ([#30155](https://projects.theforeman.org/issues/30155), [4e5bccc0](https://github.com/Katello/katello.git/commit/4e5bccc08aa8414a15403ae603467d5274a6fe66))

### Web UI
 * Content -> Product doesn't work when no organization is selected ([#30580](https://projects.theforeman.org/issues/30580), [0e9ae146](https://github.com/Katello/katello.git/commit/0e9ae146969244b6f1150dda854a10d07074c144))
 * Fix breaking changes for upgrade to @patternfly/react v4 major version bump ([#30239](https://projects.theforeman.org/issues/30239), [548c4aa0](https://github.com/Katello/katello.git/commit/548c4aa0a7ca5d680538ea090f8deaf98ab5df84))
 * Remove react-tokens from katello's package.json ([#29879](https://projects.theforeman.org/issues/29879), [82b0fe0b](https://github.com/Katello/katello.git/commit/82b0fe0b6f93e11214b65bf6f2682d2f7c5e1b17))
 * Bastion Katello translation strings need to be updated ([#30108](https://projects.theforeman.org/issues/30108), [4ae270c2](https://github.com/Katello/katello.git/commit/4ae270c21c60b8277a9faec6a6e29aa31cfcede5))

### Hammer
 * Add deb package CLI support ([#30579](https://projects.theforeman.org/issues/30579))
 * Hammer repository info does not show description ([#30464](https://projects.theforeman.org/issues/30464), [89afd8b7](https://github.com/Katello/hammer-cli-katello.git/commit/89afd8b7c3ae312595912a404d7986baf91e8dd7))
 * hammer --csv content-view version export-legacy stopped working after Upgrade ([#28263](https://projects.theforeman.org/issues/28263))

### Tests
 * Intermittent LoadError for Messaging tests ([#30521](https://projects.theforeman.org/issues/30521), [eabd4e79](https://github.com/Katello/katello.git/commit/eabd4e79ff2e9445f183a2f3e61dc8fc033e0eff))
 * react-testing-library keeps timing out on Jenkins ([#30411](https://projects.theforeman.org/issues/30411), [883baf75](https://github.com/Katello/katello.git/commit/883baf75db86703a3c5efa63baca17e6388c46ea))
 * Fix timeout issue in React content view test ([#30336](https://projects.theforeman.org/issues/30336), [bab3adfd](https://github.com/Katello/katello.git/commit/bab3adfd6b7b599e08512bb34a9a13752cb088b3))
 * Stop collecting coverage from React tests ([#30335](https://projects.theforeman.org/issues/30335), [16fd8914](https://github.com/Katello/katello.git/commit/16fd8914e85b613aa71ded31a187b54d6de688a2))
 * Correct APIMiddleware path for react tests ([#30157](https://projects.theforeman.org/issues/30157), [015620aa](https://github.com/Katello/katello.git/commit/015620aaef75234588e422204b11fa25d2d9a248))
 * Update React testing to use @theforeman/find-foreman ([#30137](https://projects.theforeman.org/issues/30137), [cb7a2632](https://github.com/Katello/katello.git/commit/cb7a263205d76e69e268f848a434ba0db03384dc))
 * Some tests set, but don't unset, ENV variables ([#29975](https://projects.theforeman.org/issues/29975), [7e3d56ad](https://github.com/Katello/katello.git/commit/7e3d56ad60754493be90f587268164c2f2b5cf6d))
 * Remove duplicate npm dependencies in Katello ([#29905](https://projects.theforeman.org/issues/29905), [243881b4](https://github.com/Katello/katello.git/commit/243881b4be54eeddfe8337205bdfbcc92c8ccf4d))

### Repositories
 * Make download_concurrency configurable in pulpcore ([#30488](https://projects.theforeman.org/issues/30488), [a9e9869e](https://github.com/Katello/katello.git/commit/a9e9869ec2a3a98a81751f4df00811fe034719ed))
 * As a developer I 'd like DeleteRepositoryReferenceTest to run ([#30482](https://projects.theforeman.org/issues/30482))
 * Cannot see why redhat repo scanning failed ([#29933](https://projects.theforeman.org/issues/29933), [394c8b6a](https://github.com/Katello/katello.git/commit/394c8b6a3daaf59bb8942b0f555f030a4a107a52))
 * Skip audit record creation when content changed in the root repository ([#30082](https://projects.theforeman.org/issues/30082), [51eb4925](https://github.com/Katello/katello.git/commit/51eb49258413867c5d65b08cec033c3c7ea23a85))
 * Repository create fails when only Pulp 3 is installed (EL8) ([#30168](https://projects.theforeman.org/issues/30168), [4171a36f](https://github.com/Katello/katello.git/commit/4171a36f2bdb3a309861d87ab7412d70a8205f76), [54f22aef](https://github.com/Katello/katello.git/commit/54f22aefc038a0dc5e21afc801ea84df2b76616e))

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
 * Add new content view details page with details tab ([#29996](https://projects.theforeman.org/issues/29996), [64f9d6a7](https://github.com/Katello/katello.git/commit/64f9d6a7dfcf4347ec8937ecf42642adfbed8512))
 * List of Content Views on Create Host or Hostgroup page unordered if the field was prefilled ([#30077](https://projects.theforeman.org/issues/30077), [7cdf27a5](https://github.com/Katello/katello.git/commit/7cdf27a5fd80d34e81325b1ce108e03fe7f972aa))

### Errata Management
 * Oops page when trying perform action on all systems from content host page ([#30350](https://projects.theforeman.org/issues/30350), [11f0ce3c](https://github.com/Katello/katello.git/commit/11f0ce3cda7414d75d6d99e685e56a67c8f45aa7))

### Activation Key
 * Activation key page loading is very slow ([#30270](https://projects.theforeman.org/issues/30270), [c973aad6](https://github.com/Katello/katello.git/commit/c973aad6f8b1caca5f997a895b65c6cbb273b7a3))

### Installer
 * capsule-certs-generate failed to increment release number when generating certificate rpm for foreman-proxy ([#15932](https://projects.theforeman.org/issues/15932))