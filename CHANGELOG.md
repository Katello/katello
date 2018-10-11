# 3.7.1 Blonde Ale (2018-10-11)

## Features

## Bug Fixes

### Hosts
 * Unit test failure on host full search ([#24986](https://projects.theforeman.org/issues/24986), [82d5494c](https://github.com/Katello/katello.git/commit/82d5494cf9cd68e69fa2cf7b90c275892c0a6fdc))
 * clean_backend_objects does not verify managed host status prior to action ([#24812](https://projects.theforeman.org/issues/24812), [8667e2bf](https://github.com/Katello/katello.git/commit/8667e2bfd02710455a86c694eb37f2af3eda41bd))
 * updating errata counts on a content host should not use validation ([#24768](https://projects.theforeman.org/issues/24768), [b0a37152](https://github.com/Katello/katello.git/commit/b0a371522a891b6aba5c782665c727e814c4717c))
 * Bulk action for Manage Repository Sets is broken ([#24678](https://projects.theforeman.org/issues/24678), [677f715c](https://github.com/Katello/katello.git/commit/677f715ccafdc689dbffc564a9c27e31aaacb4a5))
 * Cannot remove packages from content host web UI ([#24651](https://projects.theforeman.org/issues/24651), [146bd13d](https://github.com/Katello/katello.git/commit/146bd13d0671af002eebb3ec6813df7767c07a51))
 * Pushing updates from katello 3.7 to CentOS 7.5 client not working  ([#24523](https://projects.theforeman.org/issues/24523), [29a85705](https://github.com/Katello/hammer-cli-katello.git/commit/29a8570582c1a8b17e8d175b800cee108ec203f6), [e71b3b39](https://github.com/Katello/katello.git/commit/e71b3b39ada4be835a351439b2260ea47b51f265))
 * Content source is not inherited from hostgroup while creating host ([#24390](https://projects.theforeman.org/issues/24390), [c10267ef](https://github.com/Katello/katello.git/commit/c10267ef1296b2b05480e985a93f447b077534bb))

### Upgrades
 * 3.6 to 3.7 upgrade issue: katello_pools_hypervisor_fk constraint violation ([#24892](https://projects.theforeman.org/issues/24892), [4a599e7e](https://github.com/Katello/katello.git/commit/4a599e7e79fce6654ae0edcfd8064f83960189b2))
 * User db upgrade from 3.4 to 3.7 failed at Upgrade Step: set_upstream_pool_id ([#24374](https://projects.theforeman.org/issues/24374), [3830ac7b](https://github.com/Katello/katello.git/commit/3830ac7bfdb77bd7f5909ee6544217f8ae3ade52))

### Repositories
 * unable to search for packages ([#24769](https://projects.theforeman.org/issues/24769), [9f5f1585](https://github.com/Katello/katello.git/commit/9f5f15856327f35556fbc60dd05a9cff539dba6b))
 * On the Sync Status page, the Active Only checkbox does not work ([#24499](https://projects.theforeman.org/issues/24499), [f6ed298a](https://github.com/Katello/katello.git/commit/f6ed298ab1c28b356ec1e582b40219f8750fc9fe))
 * Content Host Applicable Package List page can DOS Foreman server and Postgres ([#24389](https://projects.theforeman.org/issues/24389), [b9430c00](https://github.com/Katello/katello.git/commit/b9430c00c72c75511113e518d4f3bf94d3cf5ad0))
 * No notification and 500 ISE while disabling repository included in published content view ([#24310](https://projects.theforeman.org/issues/24310), [6c19cff5](https://github.com/Katello/katello.git/commit/6c19cff5b5c4952c60fefaf5ab662a98bbe89423))
 * Repo discovery: adding GPG key doesn't actually assign it to neither repo nor product ([#24265](https://projects.theforeman.org/issues/24265), [99c55453](https://github.com/Katello/katello.git/commit/99c554533427536022d65b1279e1b024c24e72d4))
 * Recommended repositories toggle is too close to the "Available Repositories" header on narrow displays ([#24243](https://projects.theforeman.org/issues/24243), [ac3032d4](https://github.com/Katello/katello.git/commit/ac3032d4349930576ffa57d3a01476ea1f953cc9))
 * RH Repositories page ostree filter shows no results ([#24188](https://projects.theforeman.org/issues/24188), [54437044](https://github.com/Katello/katello.git/commit/54437044ca53d92e69ab9eae77f059a38a7d53a2))
 * Cannot sync Atomic kickstart nor RPMs ([#23801](https://projects.theforeman.org/issues/23801))

### Client/Agent
 * installation/update package using Katello web UI not working ([#24500](https://projects.theforeman.org/issues/24500), [40928baa](https://github.com/Katello/katello-host-tools.git/commit/40928baab704da9784f6af2719e06dadc3eb2130))
 * Error when using REX for errata installation ([#24304](https://projects.theforeman.org/issues/24304), [62b93c1d](https://github.com/Katello/katello.git/commit/62b93c1d3678c392ef606aef2e22b7525c343b6e))

### Subscriptions
 * Black background instead of transparency on subscription related modals ([#24354](https://projects.theforeman.org/issues/24354), [4fa6778b](https://github.com/Katello/katello.git/commit/4fa6778bcc3529636dc8315edd97451007ec4c1b))
 * "Requires Virt-Who" column incorrect in new Subscriptions UI ([#24335](https://projects.theforeman.org/issues/24335), [51788d9c](https://github.com/Katello/katello.git/commit/51788d9cef0016554050434f3ab9dc9bc3f2f5ec))
 * Add Subscriptions: Subscriptions with Unlimited Entitlements list as "-1" ([#24309](https://projects.theforeman.org/issues/24309))
 * Difficulty editing CDN url field ([#24292](https://projects.theforeman.org/issues/24292), [0475d841](https://github.com/Katello/katello.git/commit/0475d8414d2871ee3f3a59f0d61e1589c9b80735))
 * Subscriptions page throws error under the "Any Organization" context ([#24143](https://projects.theforeman.org/issues/24143), [6ef62d1f](https://github.com/Katello/katello.git/commit/6ef62d1f497f905848f6185a279ca12d0c170eb8))
 * "Select All" on folded subscriptions should be implied/automatic ([#24141](https://projects.theforeman.org/issues/24141), [afd62c48](https://github.com/Katello/katello.git/commit/afd62c4862ed175ff85480ade745c2e329df71c0))
 * Hide link to "Add subscriptions" when no manifest is uploaded ([#24129](https://projects.theforeman.org/issues/24129), [d04bf684](https://github.com/Katello/katello.git/commit/d04bf684dad7949ec72b8cc463eabdede1ac3b6f))
 * UI fails silently when uploading manifests produces warnings/errors ([#24127](https://projects.theforeman.org/issues/24127))
 * Add product content info to new subscription details page ([#23886](https://projects.theforeman.org/issues/23886), [3fdd5848](https://github.com/Katello/katello.git/commit/3fdd5848139237dec6f8b5605984e878500c1d32))
 * RH Subscriptions: ensure toast notifications when a task is started ([#23750](https://projects.theforeman.org/issues/23750), [98a8e8ce](https://github.com/Katello/katello.git/commit/98a8e8ce992bf082d4338724424b050f6d7c6209))
 * Error when fetching available subscription quantities shouldn't block quantity editing ([#23510](https://projects.theforeman.org/issues/23510), [c5283890](https://github.com/Katello/katello.git/commit/c528389076d19fee443f9dcfa2b85ed3db12874f))

### Tests
 * clean up test output for jest (react) tests ([#24336](https://projects.theforeman.org/issues/24336), [63746060](https://github.com/Katello/katello.git/commit/63746060ec97dfbfea0908e922a98fbe13d32db8))

### Tooling
 * Add eslint to jenkins for webpack ([#24324](https://projects.theforeman.org/issues/24324), [2f5e99ff](https://github.com/Katello/katello.git/commit/2f5e99ff6329f7f0fbda715196bd6e89d64c1c98))

### Web UI
 * Loading state should render a spinner after a small delay  ([#24288](https://projects.theforeman.org/issues/24288), [4c976ff6](https://github.com/Katello/katello.git/commit/4c976ff6ccf4006a111b7af07720c373592fd39e))
 * Its not clear what repo type filter does in RH repos page ([#24229](https://projects.theforeman.org/issues/24229), [8bdeb0a5](https://github.com/Katello/katello.git/commit/8bdeb0a52d33435b94dd13fa9af207028f0cabf1))
 * New Sync Plan Start Time Not Displayed Properly ([#23989](https://projects.theforeman.org/issues/23989), [a1a4f753](https://github.com/Katello/katello.git/commit/a1a4f7534141046fbc57517ddd45a643a1ab437f))

### Content Views
 * restrict_composite_view flag prevents CCV promotion even when component versions have been promoted ([#24273](https://projects.theforeman.org/issues/24273), [70341125](https://github.com/Katello/katello.git/commit/7034112539920b72df5b31506fe85aa86bf5c13f))
 * Content view incremental update fails when --packages option used ([#22696](https://projects.theforeman.org/issues/22696), [f7576287](https://github.com/Katello/hammer-cli-katello.git/commit/f757628797c44c2816d09442993205cd9dfd8630))

### Hammer
 * Filtering of some entities does not work ([#23993](https://projects.theforeman.org/issues/23993), [31e2fb82](https://github.com/Katello/hammer-cli-katello.git/commit/31e2fb825d4ec563cc069850a785f1e79f0a31cf))

### Other
 * Katello Upgrade from 3.6.0 to 3.7.0 fails on subscription import ([#24649](https://projects.theforeman.org/issues/24649))
 * on smartproxies, calls to api/v2/ are no passed to upstream foreman server ([#24341](https://projects.theforeman.org/issues/24341))
 * fix <br> tag ([#24190](https://projects.theforeman.org/issues/24190), [d80d7114](https://github.com/Katello/katello.git/commit/d80d7114b961c52aae29bca086084171d38f0101))
 * Unable to use select action on content host (Manage Subscription) ([#23992](https://projects.theforeman.org/issues/23992), [7a355320](https://github.com/Katello/katello.git/commit/7a3553208ece870f213bac05725f576d27e8c6a5))
 * RH repos XUI: page crashes when in Any context ([#22568](https://projects.theforeman.org/issues/22568), [6ef62d1f](https://github.com/Katello/katello.git/commit/6ef62d1f497f905848f6185a279ca12d0c170eb8))
# 3.7.0 Blonde Ale (2018-07-23)

## Features

### Web UI
 * Upgrade and pin patternfly-react to v2.5.1 ([#23791](https://projects.theforeman.org/issues/23791), [7563b482](https://github.com/Katello/katello.git/commit/7563b482416bbb4aebe4b458539349fc50669db0))
 * Update react to 16.3+ ([#23691](https://projects.theforeman.org/issues/23691), [2c69a40c](https://github.com/Katello/katello.git/commit/2c69a40c24e7eb14c35c1bfde02bd9cfc15a9530))
 * Open URLs to access.redhat.com with a new tab ([#23282](https://projects.theforeman.org/issues/23282), [6ca79a2d](https://github.com/Katello/katello.git/commit/6ca79a2d19382fd43bdff61110ded2a0aece7ae8))
 * RH Repos: add a more accurate message when all repositories are enabled ([#22936](https://projects.theforeman.org/issues/22936), [f8054d48](https://github.com/Katello/katello.git/commit/f8054d48c98013dcd51c6155183cab56a55056fb))
 * Get default per page values for redhat subscriptions and redhat repositories from user setting ([#22897](https://projects.theforeman.org/issues/22897))
 * Add RH subscriptions routing skeleton page to labs pages ([#22726](https://projects.theforeman.org/issues/22726), [8def2f53](https://github.com/Katello/katello.git/commit/8def2f53052a7516a3d3409465d855d33b511454))
 * RH Repos: hook up repository content type selector ([#22563](https://projects.theforeman.org/issues/22563), [112de8c1](https://github.com/Katello/katello.git/commit/112de8c129e484ac4e8f6f56e9ae4693d877f11c))
 * RH Repos: do not truncate repository (set) titles ([#22562](https://projects.theforeman.org/issues/22562), [5cac7fa8](https://github.com/Katello/katello.git/commit/5cac7fa8fc6e15614c217bc507bd955979b93e1c))
 * RH Repos: use pagination from patternfly-react ([#22371](https://projects.theforeman.org/issues/22371), [112de8c1](https://github.com/Katello/katello.git/commit/112de8c129e484ac4e8f6f56e9ae4693d877f11c))
 * Replace the old RH repos page with the new "labs" version ([#22370](https://projects.theforeman.org/issues/22370), [bf02310d](https://github.com/Katello/katello.git/commit/bf02310dc2156c10532dbde8be7e02556eefcde7))
 * Red Hat Repositories: Ability to enable/disable repositories  ([#21649](https://projects.theforeman.org/issues/21649), [9e7f1304](https://github.com/Katello/katello.git/commit/9e7f1304ab05b6f344b502933385dd7869320871))
 * Red Hat Repositories: preload popular repository sets ([#21648](https://projects.theforeman.org/issues/21648), [09cecfa0](https://github.com/Katello/katello.git/commit/09cecfa093b7755c7deac4c7459a3690c865ec8d))

### Installer
 * katello-installer certificate options should not require --certs-server-cert-req ([#23766](https://projects.theforeman.org/issues/23766), [35722703](https://github.com/Katello/katello-installer.git/commit/35722703f8252ab835b6f5bfd8be04ce4d547465))
 * Show instructions after installing the development scenario ([#22558](https://projects.theforeman.org/issues/22558), [874e1311](https://github.com/Katello/katello-installer.git/commit/874e1311300f8db40b68861670736bb85655ce9c), [de924728](https://github.com/Katello/katello-installer.git/commit/de924728e5c219bbc828191349e38c46fc1d70ee))

### Tests
 * Port robottelo tests for hostgroups ([#23724](https://projects.theforeman.org/issues/23724), [b9fe3e12](https://github.com/Katello/katello.git/commit/b9fe3e1244cec2f348599298e71562b94241609c))

### Subscriptions
 * RH subscriptions: group subscriptions by SKU ([#23694](https://projects.theforeman.org/issues/23694), [fd8c2c01](https://github.com/Katello/katello.git/commit/fd8c2c012d62055b052a08820b37c76f35fef44e))
 * RH Subscription: disable relevant actions in manifest modal when a task is in process ([#23325](https://projects.theforeman.org/issues/23325), [62d69e98](https://github.com/Katello/katello.git/commit/62d69e987c06867a8a439ca62ae06470b1add1f5))
 * RH Subscriptions: create notification when refresh, delete, and upload tasks have completed ([#23324](https://projects.theforeman.org/issues/23324), [86bc5fcc](https://github.com/Katello/katello.git/commit/86bc5fcc864d422997ee17bebd3d8139d449cf56))
 * RH Subscriptions: hook up save call to upstream subscriptions page ([#23301](https://projects.theforeman.org/issues/23301), [023da41d](https://github.com/Katello/katello.git/commit/023da41db131d3b294b2c11d0b6b68da752f2594))
 * RH Subscriptions: show modal for delete confirmation ([#23286](https://projects.theforeman.org/issues/23286), [e8ff2f4e](https://github.com/Katello/katello.git/commit/e8ff2f4ee53ac8bae98cb3c47c3d798eca90fd03))
 * RH Subscriptions: show progress bar over table for tasks that are running  ([#23285](https://projects.theforeman.org/issues/23285), [2e7aef07](https://github.com/Katello/katello.git/commit/2e7aef07c56840e702c4562362884b865498d82d))
 * RH subscriptions:  update manifest name/etc on successful upload/delete ([#23283](https://projects.theforeman.org/issues/23283))
 * Move labs subscriptions page to /subscriptions and delete existing angular page  ([#23275](https://projects.theforeman.org/issues/23275), [cdc03f08](https://github.com/Katello/katello.git/commit/cdc03f0836cde3b41675fd4df13cc96048c333af))
 * (MANAGE SUBS) As an API user, i want to know the upstream quantity for a set of local pools ([#23087](https://projects.theforeman.org/issues/23087), [78c0c322](https://github.com/Katello/katello.git/commit/78c0c322d27ec84a8c0b37431d17eb900a15a8e8))
 * As an API user, I want to delete subscriptions from my allocation. ([#22909](https://projects.theforeman.org/issues/22909), [59e3a1a4](https://github.com/Katello/katello.git/commit/59e3a1a4fbdb4665e47258e15dc1fb6b6ff999f5), [11aa29b2](https://github.com/Katello/katello.git/commit/11aa29b26ea4727e22c7a2448a5ecc6bcb1732c7))
 * RH Subscriptions: hide actions when satellite is in disconnected mode ([#22836](https://projects.theforeman.org/issues/22836), [62d69e98](https://github.com/Katello/katello.git/commit/62d69e987c06867a8a439ca62ae06470b1add1f5))
 * RH Subscriptions: add GET API actions and reducers ([#22781](https://projects.theforeman.org/issues/22781), [6dbf2352](https://github.com/Katello/katello.git/commit/6dbf23520e6eba147860cc63d9b122990dc23213))
 * Add ability to edit Red Hat Subscription entitlement quantities ([#22734](https://projects.theforeman.org/issues/22734), [e66857d4](https://github.com/Katello/katello.git/commit/e66857d4bbcef70449e8d288e964830fbf6f6f27))
 * Add export CSV capability to the Red Hat Subscriptions page ([#22732](https://projects.theforeman.org/issues/22732), [9fe4494f](https://github.com/Katello/katello.git/commit/9fe4494f526eda96bf1b232beaf0eecc504caccd))
 * Add delete subscriptions capability to the RH subscriptions page ([#22731](https://projects.theforeman.org/issues/22731), [29846107](https://github.com/Katello/katello.git/commit/29846107338df3f7c9a81a97cd10df5bf5782b22))
 * Add Manage Manifest modal and button to the RH subscriptions page ([#22730](https://projects.theforeman.org/issues/22730), [2a5bde8f](https://github.com/Katello/katello.git/commit/2a5bde8fd566266ee39a7793b9bc750756f27fe7))
 * Add search capabilities to the Red Hat Subscriptions Page ([#22729](https://projects.theforeman.org/issues/22729), [a1698055](https://github.com/Katello/katello.git/commit/a16980550614bd73f0efb92e924c664f31f56b10))
 * Add read-only RH subscriptions table ([#22728](https://projects.theforeman.org/issues/22728), [6dbf2352](https://github.com/Katello/katello.git/commit/6dbf23520e6eba147860cc63d9b122990dc23213))
 * List available subscriptions from the customer portal ([#22594](https://projects.theforeman.org/issues/22594), [53d7ed1b](https://github.com/Katello/katello.git/commit/53d7ed1b877dff5ef9ce2ddfb3ff6e1fe6552512))
 * Utilize empty state view when subscriptions are not present in an allocation ([#22366](https://projects.theforeman.org/issues/22366), [6dbf2352](https://github.com/Katello/katello.git/commit/6dbf23520e6eba147860cc63d9b122990dc23213))

### Hosts
 * support updating installed products via host update api ([#23189](https://projects.theforeman.org/issues/23189), [81c160a6](https://github.com/Katello/katello.git/commit/81c160a621d1867a48ac461666a67ece0150bc47))

### API
 * Subscriptions index should reveal which came from upstream ([#23034](https://projects.theforeman.org/issues/23034), [f3fa9712](https://github.com/Katello/katello.git/commit/f3fa97128f7484e97c5deb35b92f40bbee01728d))
 * Repository Set Search auto complete api ([#22202](https://projects.theforeman.org/issues/22202), [ead3189a](https://github.com/Katello/katello.git/commit/ead3189a28e2a950b694f1ac3db0777139fd295f))

### Tooling
 * Update Katello nightly to use Pulp 2.16 Beta ([#22947](https://projects.theforeman.org/issues/22947))

### Errata Management
 * Job Template to install Errata on SUSE ([#22755](https://projects.theforeman.org/issues/22755), [038dce86](https://github.com/Katello/katello.git/commit/038dce8696d16079b09e6c982ba4053de2a56dc2))

### Provisioning
 * adding support for liveimg ([#22736](https://projects.theforeman.org/issues/22736), [e4b99393](https://github.com/Katello/katello.git/commit/e4b993935744c8fe706aaef8fb38c8ce265d3754))

### Content Views
 * Auto publish Composite if component updates ([#21994](https://projects.theforeman.org/issues/21994), [580f7f80](https://github.com/Katello/katello.git/commit/580f7f808d9b06bbf5ee2f947e121008caf583f6))

### Foreman Proxy Content
 * [RFE] make it possible to run capsule-remove unattended ([#16003](https://projects.theforeman.org/issues/16003), [010d458f](https://github.com/Katello/katello-installer.git/commit/010d458f4ac2fc1569fbf2fcbebaa3dc01a54388))

### Repositories
 * Add ability to add SSL protected repositories in Katello ([#15068](https://projects.theforeman.org/issues/15068), [95594cfb](https://github.com/Katello/katello.git/commit/95594cfb7a2bafc1b66d4463142196d3d3dadf92), [a659b23b](https://github.com/Katello/katello.git/commit/a659b23bf6f9e523ff9345cd1a5746ab1786320a), [2934f376](https://github.com/Katello/katello.git/commit/2934f376473e341ffbb10ac1ffd42efb8c5bdab8), [d026e463](https://github.com/Katello/katello.git/commit/d026e463f368b5ccf926a7125832720b2083630b), [865101a1](https://github.com/Katello/katello.git/commit/865101a111b8a94db1b13cec8a10f4b0046ef8f8))

### Other
 * As an API user, I should be able to obtain the bugzillas associated with an Errata. ([#23317](https://projects.theforeman.org/issues/23317), [c9d15653](https://github.com/Katello/katello.git/commit/c9d15653ddce51410e42f36de18886816f8ba06d))
 * Add a script to pin installer dependencies when branching ([#23207](https://projects.theforeman.org/issues/23207), [0d192013](https://github.com/Katello/katello-installer.git/commit/0d1920139957508d416cc1c41970f31d78b20cf2))
 * Include Katello job templates for Ansible REX provider from community-templates ([#23202](https://projects.theforeman.org/issues/23202), [0715b962](https://github.com/Katello/katello.git/commit/0715b9621669e2ada6704e8c72801585445cb9fe))
 * [RFE] (MANAGE SUBS) As an API or CLI user, I want to add available subscriptions to my allocation. ([#22853](https://projects.theforeman.org/issues/22853), [1015edbc](https://github.com/Katello/katello.git/commit/1015edbcdb73b6e18bf89acf5c5d6de35ca75f91))
 * Port robottelo tests for katello organization ([#22794](https://projects.theforeman.org/issues/22794), [ac828fc3](https://github.com/Katello/katello.git/commit/ac828fc3a7aa9f21553030515cc759d505ee73a3), [3af3efa0](https://github.com/Katello/katello.git/commit/3af3efa0f57f432b31cdf0d144d8ab052b570a34), [6710b15c](https://github.com/Katello/katello.git/commit/6710b15ce2c9a19a8b8e16615f422fb99644d822), [6c88f18e](https://github.com/Katello/katello.git/commit/6c88f18e1f44742ef16656c5ba4cf94f92181540))
 * [Audit]  Add audit to more Katello resources - Content-view, Repository, Lifecycle environment and their associations ([#22690](https://projects.theforeman.org/issues/22690), [68d64c0f](https://github.com/Katello/katello.git/commit/68d64c0ff8223a4f73ea13c13644e86e0318b31e))
 * [Audit] has_many association between sync-plan & product ([#22377](https://projects.theforeman.org/issues/22377))
 * [Audit] Sync Plans, Activation Keys, GPG keys, Product ([#22372](https://projects.theforeman.org/issues/22372), [0c0a45a6](https://github.com/Katello/katello.git/commit/0c0a45a6a125d057948f40d3c5a6dfa193383a4c))
 * Add autocomplete component ([#22254](https://projects.theforeman.org/issues/22254), [fdddce0c](https://github.com/Katello/katello.git/commit/fdddce0c9fab92aeb11611f5cfcc4ebaff5fa65e))
 * Notification for subscriptions expiring soon  ([#19314](https://projects.theforeman.org/issues/19314), [390b0967](https://github.com/Katello/katello.git/commit/390b09672a64cf88a84ef7b8411f771ef2ba948c))

## Bug Fixes

### Subscriptions
 * Error after upgrade on subscription page ([#24272](https://projects.theforeman.org/issues/24272), [5cd628f2](https://github.com/Katello/katello-installer.git/commit/5cd628f2ae671b4348a970ef0307a509f7894b14))
 * Prevent deletion of custom subscriptions ([#24223](https://projects.theforeman.org/issues/24223))
 * RH Subscriptions: caret is backwards on grouped subscriptions ([#24222](https://projects.theforeman.org/issues/24222), [823d062a](https://github.com/Katello/katello.git/commit/823d062a821c2761ae636214fd37cc2d41d45a95))
 * No input validation on Add Subscriptions Page ([#24215](https://projects.theforeman.org/issues/24215), [b5af2f1b](https://github.com/Katello/katello.git/commit/b5af2f1bbd42e02b1fbe0454e25153229750c34c))
 * Main subscription placed at bottom of collapsed subscriptions ([#24206](https://projects.theforeman.org/issues/24206), [ae73cdd4](https://github.com/Katello/katello.git/commit/ae73cdd4f44c20c019512741366d00d6856b9784))
 * Subscription update value of 0 passes UI validation, but fails in task. ([#24197](https://projects.theforeman.org/issues/24197), [e3c8094d](https://github.com/Katello/katello.git/commit/e3c8094da0ef41fe77f37c754a336f63c03fac02))
 * Cannot update entitlements for subscriptions with unlimited guests ([#24145](https://projects.theforeman.org/issues/24145), [c093b588](https://github.com/Katello/katello.git/commit/c093b5886e067e9943b8f4edbf18077333a180c0))
 * Subscriptions page is blank when switching between Orgs ([#24142](https://projects.theforeman.org/issues/24142), [bfd20b92](https://github.com/Katello/katello.git/commit/bfd20b921b4852003c5ec38fb143e04b19eab406))
 * Navigating back to Subscriptions from Add Subscriptions results in blank page. ([#24140](https://projects.theforeman.org/issues/24140), [bfd20b92](https://github.com/Katello/katello.git/commit/bfd20b921b4852003c5ec38fb143e04b19eab406))
 * Select all children of grouped subscriptions when select all is checked. ([#24095](https://projects.theforeman.org/issues/24095))
 * Upstream Subscriptions API/GET is returning upstream id twice and missing local katello id ([#24064](https://projects.theforeman.org/issues/24064), [b3efb0eb](https://github.com/Katello/katello.git/commit/b3efb0ebda8d56628d2a92cfe2f14e24e63bc1c4))
 * RH Subscriptions: subscription details page appears underneath upstream subscriptions page ([#23946](https://projects.theforeman.org/issues/23946))
 * The new add subscriptions page renders SubscriptionDetailsPage at the same time ([#23944](https://projects.theforeman.org/issues/23944), [837ebedf](https://github.com/Katello/katello.git/commit/837ebedf32677686e0e7cf79ea307119e1d80a36))
 * Error deleting manifest. PG::UniqueViolation: ERROR: duplicate key value violates unique constraint "index_katello_pools_on_cp_id" ([#23942](https://projects.theforeman.org/issues/23942), [936291aa](https://github.com/Katello/katello.git/commit/936291aa1c52402606acaf4ce6d52994d3685521))
 * RH Subscriptions: center the loading spinner and otherwise adhere to pf best practices ([#23922](https://projects.theforeman.org/issues/23922), [94943dad](https://github.com/Katello/katello.git/commit/94943dad0dde2e6a6cc1c64791ebeb756902fb90))
 * Katello Content is shared across organizations ([#23904](https://projects.theforeman.org/issues/23904), [6d2cf88b](https://github.com/Katello/katello.git/commit/6d2cf88b114d8ba7ef98fa31cd00e2f8f4ce0672))
 * subscriptions pages/api errors with 'NoMethodError: undefined method `id' for nil:NilClass' ([#23823](https://projects.theforeman.org/issues/23823), [8234c3af](https://github.com/Katello/katello.git/commit/8234c3af59ae5ab8eb2f3a312fd6728c3a8f2679))
 * update product name and repo names when content is updated ([#23788](https://projects.theforeman.org/issues/23788), [cc60ee97](https://github.com/Katello/katello.git/commit/cc60ee97c2b67a78083937117cacb10b60e800eb))
 * Remove "Red Hat" from subscriptions menu item ([#23783](https://projects.theforeman.org/issues/23783), [7a4c63ac](https://github.com/Katello/katello.git/commit/7a4c63ac41b4987dc24af4c1696960574093eb68))
 * Attached subscription quantity is showing as "Automatic" instead of a number in "Quantity" field for hypervisor ([#23761](https://projects.theforeman.org/issues/23761), [d5fb04c8](https://github.com/Katello/katello.git/commit/d5fb04c81deab79aae060ba636adbe11c2eecab7))
 * RH Subscriptions: brief delay between manifest related action and modal closing/progress bar showing ([#23760](https://projects.theforeman.org/issues/23760))
 * Error when changing or refreshing manifest ([#23733](https://projects.theforeman.org/issues/23733), [f8c98b77](https://github.com/Katello/katello.git/commit/f8c98b77163e17a3643a71d0903361a45b01dd20))
 * RH Subscriptions: add subscriptions details page ([#23687](https://projects.theforeman.org/issues/23687), [0fc33e91](https://github.com/Katello/katello.git/commit/0fc33e916f65d36948f0de8f55a0442a6f407604))
 * Speed up manifest import with lots of pools ([#23604](https://projects.theforeman.org/issues/23604), [6de94a2c](https://github.com/Katello/katello.git/commit/6de94a2c18f2f23bc45d2a012bede539fd70755d))
 * Refresh and Delete manifest buttons aren't disabled when manifest is deleted ([#23571](https://projects.theforeman.org/issues/23571), [b510bf39](https://github.com/Katello/katello.git/commit/b510bf39ba3b927c625a6588543bfeabdd96c1e0))
 * JS error when opening manage manifest modal ([#23552](https://projects.theforeman.org/issues/23552), [9f8bd2b6](https://github.com/Katello/katello.git/commit/9f8bd2b6ca8f9e0fc3439aa5076bfcbfa1cc65d6))
 * JS error on modals in the new subscriptions page ([#23541](https://projects.theforeman.org/issues/23541))
 * Upstream subscriptions, quantities are wrong when editing subscriptions ([#23532](https://projects.theforeman.org/issues/23532), [bac5a1b3](https://github.com/Katello/katello.git/commit/bac5a1b3b0f99489c49e34bef319e1751c93614f))
 * subscriptions api should sort by name by default ([#23472](https://projects.theforeman.org/issues/23472), [bd9d6923](https://github.com/Katello/katello.git/commit/bd9d6923ed5517a40d3851770fdefc4730552b82))
 * RH Subscriptions:  TypeError: deburr(...).replace is not a function after delete/upload manifest ([#23302](https://projects.theforeman.org/issues/23302))
 * RH Subscriptions: Modal opening each time the task polling returns ([#23284](https://projects.theforeman.org/issues/23284))
 * compliance reasons don't refresh automatically after changing status via UI ([#23105](https://projects.theforeman.org/issues/23105), [9fd15508](https://github.com/Katello/katello.git/commit/9fd155084a0fe32f9359d57e9ec6faa02e342b92))
 * Indexing subscription facet pools generates  sql query per consumer ([#23096](https://projects.theforeman.org/issues/23096), [3298bb1a](https://github.com/Katello/katello.git/commit/3298bb1a72e4b21e0ca5006a4c62dffb50b3d41f))
 * Errors in webpack compile after merging subscription pages ([#23094](https://projects.theforeman.org/issues/23094), [b5c05f63](https://github.com/Katello/katello.git/commit/b5c05f63c2ba1ad12193326d120900db089095a9))
 * upstream_subscriptions url should be org scoped ([#23069](https://projects.theforeman.org/issues/23069), [6e3f500f](https://github.com/Katello/katello.git/commit/6e3f500f1302c91af264c14e99373d842a03cf4d))
 * RH subscriptions: trigger toast notifications on errors ([#23063](https://projects.theforeman.org/issues/23063), [ffd94bf2](https://github.com/Katello/katello.git/commit/ffd94bf24205f9587d4dd067609abcc735f141c3))
 * As a user, I want the 'disconnected' setting to control the behavior interactions with the RH Portal ([#22931](https://projects.theforeman.org/issues/22931), [c2cd0d2e](https://github.com/Katello/katello.git/commit/c2cd0d2ef9064cafd40bb3eb7bd4c7eedc48f8b8), [e33167b7](https://github.com/Katello/katello.git/commit/e33167b7499fb6b11a53147e20c59d035ce7847e))
 * Add breadcrumbs to RH Subscriptions page ([#22900](https://projects.theforeman.org/issues/22900), [7a234ada](https://github.com/Katello/katello.git/commit/7a234ada63cd11a27874b58b77d119f394f7f4a5))
 * SAP HANA Repository cannot be enabled if future dated subscriptions of SAP HANA are added to the subscription manifest file. ([#22878](https://projects.theforeman.org/issues/22878), [1917b37d](https://github.com/Katello/katello.git/commit/1917b37ddf760b8aac291b30757e85ecf6c94ddc))
 * Provide a setting to indicate Katello is operating in disconnected mode ([#22799](https://projects.theforeman.org/issues/22799), [37b0f613](https://github.com/Katello/katello.git/commit/37b0f6136bbb57548c841a3d8e749a863d6ca511))

### Errata Management
 * Enabled repo report saves cache even if remote server error occurs, resulting in invalid errata ([#24270](https://projects.theforeman.org/issues/24270), [95a7de9c](https://github.com/Katello/katello-host-tools.git/commit/95a7de9c6f7165b024cf2c38cf0b1824dd002e64))
 * No applicable errata/updates on content host ([#24214](https://projects.theforeman.org/issues/24214), [1ffbd8af](https://github.com/Katello/katello-host-tools.git/commit/1ffbd8afe9dfce6cf69f9b3bfed840a8e340256b))
 * Listing errata on bulk apply page errors with ActionView::Template::Error: undefined method `where' for ([#23109](https://projects.theforeman.org/issues/23109))

### Hammer
 * hammer repository upload-content fails when uploading larger files ([#24249](https://projects.theforeman.org/issues/24249), [54e9f0b3](https://github.com/Katello/hammer-cli-katello.git/commit/54e9f0b30ecdbf048f5682a311f159be9b0589ab))
 * hammer content-view create --repositories doesn't work with --name ([#24023](https://projects.theforeman.org/issues/24023), [1dc05861](https://github.com/Katello/hammer-cli-katello.git/commit/1dc05861ed2121a5f02db6f70efdb367bf4cd61b))
 * hammer doesn't show "release-version" and "service-level" for "activation-key" ([#23972](https://projects.theforeman.org/issues/23972))
 * hammer content-view puppet-module add raises ArgumentError (wrong number of arguments (given 1, expected 0)) ([#22763](https://projects.theforeman.org/issues/22763))
 * Hammer product info does not parse the repositories info correctly ([#22758](https://projects.theforeman.org/issues/22758), [d3cce829](https://github.com/Katello/katello.git/commit/d3cce8294a4e7ff24fb6ce94f1c9adda1adf5cf1))

### Upgrades
 * traceback for CreatePulpDiskSpaceNotifications : NoMethodError (undefined method `storage' for nil:NilClass) while upgrading ([#24242](https://projects.theforeman.org/issues/24242), [fab85828](https://github.com/Katello/katello.git/commit/fab85828df26ec6b770cca1a7630c26d6943c83f))
 * content_source_id value is not migrated during upgrade ([#23781](https://projects.theforeman.org/issues/23781), [ced737ab](https://github.com/Katello/katello.git/commit/ced737abf2752cda53da2149cb02dbecb8277cd9))
 * Upgrade after Mongo 3.x is installed fails out on remove_nodes_distributors ([#23649](https://projects.theforeman.org/issues/23649), [3049c5f3](https://github.com/Katello/katello-installer.git/commit/3049c5f359ebbde52e62d6194bcddcac9fd67989))

### Installer
 * New installs are missing mongo client and foreman-debug fails ([#24241](https://projects.theforeman.org/issues/24241), [b70dde18](https://github.com/Katello/katello-installer.git/commit/b70dde1807e6b96c92d5f893d67e1172fd8a9722))
 * Katello certs must be readable by foreman user ([#24210](https://projects.theforeman.org/issues/24210), [677a47e7](https://github.com/Katello/puppet-certs/commit/677a47e7d0b29ae354639b2985f0d3d55a0aacd0))
 * yum Update from satellite 6.3.1 to 6.4 failed at dependency resolution ([#24020](https://projects.theforeman.org/issues/24020), [87b00163](https://github.com/Katello/katello-installer.git/commit/87b001637a8274c6432e8d0f2af33ff67bee58e4))
 * Mongodb is_master fact requires the mongodb to be present ([#23978](https://projects.theforeman.org/issues/23978))
 * Remove no longer needed steps from upgrade hooks ([#23657](https://projects.theforeman.org/issues/23657), [33152353](https://github.com/Katello/katello-installer.git/commit/33152353cdf5842875aa49f09745978f7fe11d91))
 * Remove puppet-common dependency ([#23567](https://projects.theforeman.org/issues/23567), [c2ec4415](https://github.com/Katello/katello-installer.git/commit/c2ec441589495089393134c3d80573adce62c2db))
 * Configure qrouterd to log into syslog ([#23557](https://projects.theforeman.org/issues/23557), [e99bd28a](https://github.com/Katello/puppet-foreman_proxy_content/commit/e99bd28a4e7b4692cbf664dbe11b37d0c687b41f), [92bb8311](https://github.com/Katello/puppet-qpid/commit/92bb8311acf66136d87af857fdf901d69c87a684))
 * Clean up el6 references & remove service-wait ([#23407](https://projects.theforeman.org/issues/23407), [c55ba7fe](https://github.com/Katello/katello-installer.git/commit/c55ba7fe28dda9b5a8f472355df0eb22649b4cd6))
 * foreman-installer --reset does not work with remote Mongo DB ([#23309](https://projects.theforeman.org/issues/23309), [1aba38ff](https://github.com/Katello/katello-installer.git/commit/1aba38ff9ef35b700587546dfd3c1abf747137a2))
 * satellite-installer --katello-pulp-max-speed leads to broken pulp ([#23233](https://projects.theforeman.org/issues/23233), [045dedfd](https://github.com/Katello/puppet-pulp/commit/045dedfd3be324b2f3b156c7e5aca0c771f19285))
 * pulp_deb is not installed on forklifts centos7-devel ([#23198](https://projects.theforeman.org/issues/23198))
 * foreman-installer fails when ssl-verify is set to false for candlepin db ([#23025](https://projects.theforeman.org/issues/23025), [34388103](https://github.com/Katello/katello-installer.git/commit/343881039d055c579482fd036f72568f5f5dfcc4), [04c0e2c7](https://github.com/Katello/puppet-candlepin/commit/04c0e2c72e7d78bd3853dadcd707a6ba9d6de19f))
 * NoMethodError ssl_client_cert while foreman-installer --upgrade ([#23000](https://projects.theforeman.org/issues/23000), [b9a4e63c](https://github.com/Katello/katello.git/commit/b9a4e63c25c0b59311e0943a26796d2a05cb1548))
 * Inconsistent examples in capsule-certs-generate screen output ([#22949](https://projects.theforeman.org/issues/22949), [56e63429](https://github.com/Katello/katello-installer.git/commit/56e63429977c067f7c0de84ff4d6a574fdbf5919))
 * Remove devel scenario and module from installer ([#22905](https://projects.theforeman.org/issues/22905), [dd307b0b](https://github.com/Katello/katello-installer.git/commit/dd307b0b7c9bc541d801785f78e1024e87b75947))
 * Script in katello-ca-consumer-latest.noarch.rpm throws a warning on SLES client ([#22884](https://projects.theforeman.org/issues/22884), [b96b3d62](https://github.com/Katello/puppet-certs/commit/b96b3d620e98a6d3b6a306ef2a1c14c8b672042e))
 * capsule-certs-generate logfile should be under /var/log/foreman* ([#22810](https://projects.theforeman.org/issues/22810), [f321f98e](https://github.com/Katello/katello-installer.git/commit/f321f98eb4e2e2e09424ab0346cc854e08819dd5))
 * Katello-certs-check need to check and make sure "new line" present at the end of the certificate ([#22725](https://projects.theforeman.org/issues/22725), [f960c6ee](https://github.com/Katello/puppet-certs/commit/f960c6ee052898469a19d1d72746d0ad0507e805))
 * [RFE] katello-certs-check to distinguish between Satellite and Capsule ([#22694](https://projects.theforeman.org/issues/22694), [e521bbab](https://github.com/Katello/katello-installer.git/commit/e521bbab4ac743142b565f77ff202bdccf431b18))
 * Performing katello-certs-check without argument -r REQ_FILE shows readlink: missing operand ([#22608](https://projects.theforeman.org/issues/22608), [d14c9b6f](https://github.com/Katello/katello-installer.git/commit/d14c9b6fe8a7e192a5b3e0d08ddd960f3f775e60))
 * Satellite 6: katello-certs-check does not ensures certificate has SubjectAltName ([#22598](https://projects.theforeman.org/issues/22598), [ca1b8374](https://github.com/Katello/katello-installer.git/commit/ca1b8374e1c12efdc61b379db2cf961432bbc5d3), [4c35334a](https://github.com/Katello/katello-installer.git/commit/4c35334a710cb95b860959f697f110550984d567))
 * Tomcat server.xml templates require the sslEnabledProtocols parameter to  ([#22567](https://projects.theforeman.org/issues/22567), [7320f16d](https://github.com/Katello/puppet-candlepin/commit/7320f16d2acfab52d7da26e3b4bdee44501244a9))
 * katello-installer --help typos ([#15963](https://projects.theforeman.org/issues/15963), [a669bd98](https://github.com/Katello/puppet-certs/commit/a669bd988f310ff33846cf54a890820d1a0a8290), [1251792b](https://github.com/Katello/katello-installer.git/commit/1251792bc0eb934dce9656aeed865fbc6365a7d2))

### Dashboard
 * dashboard widget data bleeds out of widget box if browser window is small - table headers ([#24230](https://projects.theforeman.org/issues/24230), [15badd61](https://github.com/Katello/katello.git/commit/15badd6133709b211fdb152cd9bd0beb72d8f4b3))

### Repositories
 * Red Hat Enterprise Linux Atomic Host (Kickstart) fails to enable ([#24134](https://projects.theforeman.org/issues/24134), [31ab44e2](https://github.com/Katello/katello.git/commit/31ab44e2675a51cf3b6089d989faf38970c15fc2))
 * RH Repositories page contains wrong link to subscriptions page ([#24128](https://projects.theforeman.org/issues/24128), [b8ae5419](https://github.com/Katello/katello.git/commit/b8ae5419abe9d335c813dee68e1f5b64594355ac))
 * Deleting a sync plan does not stop syncing repos from it ([#24068](https://projects.theforeman.org/issues/24068), [c5a25d9f](https://github.com/Katello/katello.git/commit/c5a25d9f35127ab68883891d30085eb8e57d84a4))
 * foreman-rake katello:regenerate_repo_metadata failed with "NoMethodError: undefined method `in_default_view' for #<Array:0x000000000ce126f0>" ([#23943](https://projects.theforeman.org/issues/23943), [bd3b03ac](https://github.com/Katello/katello.git/commit/bd3b03ac37f9dfc99cc5755b7f73314998ad268e))
 * Atomic repos show up for enabling even if ostree plugin is not installed ([#23925](https://projects.theforeman.org/issues/23925))
 * Removing subscription from manifest still shows repos to enable ([#23903](https://projects.theforeman.org/issues/23903), [97a11e1c](https://github.com/Katello/katello.git/commit/97a11e1c8c1dcfd06dea77a8d87f3e2a39243bc0))
 * repositories index returning incorrect repository ids for lifecycle environment ([#23866](https://projects.theforeman.org/issues/23866), [d434ddae](https://github.com/Katello/katello.git/commit/d434ddaedce55199812718c20fe3596fee2fa612))
 * RH repos pages throws error "No translation key found." ([#23730](https://projects.theforeman.org/issues/23730), [f80698e4](https://github.com/Katello/katello.git/commit/f80698e4a918e6374931412cc87632340da63a75))
 * Content type selector on Red Hat Repos page is empty ([#23680](https://projects.theforeman.org/issues/23680), [8fb712ad](https://github.com/Katello/katello.git/commit/8fb712ad121b6dd004c6075f97f4af99e8060397))
 * undefined method `include?' for nil:NilClass on selecting some kickstart repos on RH repos page ([#23674](https://projects.theforeman.org/issues/23674), [e98bc550](https://github.com/Katello/katello.git/commit/e98bc550f9842382c27cc11a40ba3b53754b0b68))
 * Cannot list ostree (or other Repos with no substitutions) on new red hat repositories page  ([#23650](https://projects.theforeman.org/issues/23650), [318b71e4](https://github.com/Katello/katello.git/commit/318b71e43e0dd3b44c43520a42e61f0fb8ff8e30))
 * hammer repository-set enable doesn't work ([#23341](https://projects.theforeman.org/issues/23341), [3b35e474](https://github.com/Katello/katello.git/commit/3b35e474b266742c4973078ac14bc96c782fa491))
 * s390x kickstart repos should be bootable ([#23292](https://projects.theforeman.org/issues/23292), [b56273f7](https://github.com/Katello/katello.git/commit/b56273f715422ebaa9e9ef990d2910615a559a8c), [f4a98312](https://github.com/Katello/katello-installer.git/commit/f4a983121401227119c55b229158c2075b07a9e9), [00105a73](https://github.com/Katello/katello-installer.git/commit/00105a73b6da68d6051ed8a62e380b263f2bc6ec))
 * It possible to create puppet repository using name contains html tag ([#23085](https://projects.theforeman.org/issues/23085), [da6438e7](https://github.com/Katello/katello.git/commit/da6438e7e575324ffe93c6ceeb0984ac1e66bdbf))
 * When searching packages, epoch is not shown unless a package from list is selected ([#23051](https://projects.theforeman.org/issues/23051), [4360a3d2](https://github.com/Katello/katello.git/commit/4360a3d2228dc29a336c7f5b95ee370c169edb1d))
 * deprecate/remove force_post_sync_actions ([#23033](https://projects.theforeman.org/issues/23033), [1b26c3ca](https://github.com/Katello/katello.git/commit/1b26c3ca90c8d197f35cbb1eefe5bcbe0489d538))
 * Docker Tags link on repository details page points to Docker Manifests ([#22998](https://projects.theforeman.org/issues/22998), [5b99a98e](https://github.com/Katello/katello.git/commit/5b99a98ed23094fcec4938c99378f95a9d7c4e44))
 * do not allow file:// repos with on_demand ([#22769](https://projects.theforeman.org/issues/22769), [4da7cd36](https://github.com/Katello/katello.git/commit/4da7cd36c79ba6dba22a02d9204e49d1ebcd1a1f))
 * Invalid search: PG::UndefinedColumn: ERROR:  column katello_product_contents.name does not exist - on searching by name ([#22760](https://projects.theforeman.org/issues/22760), [f7a5ffa9](https://github.com/Katello/katello.git/commit/f7a5ffa9f1efc7d4aad9c2c5b61bdcec083de237))
 * Katello doesn't update sync notification URL on sync ([#22647](https://projects.theforeman.org/issues/22647), [75c44228](https://github.com/Katello/katello.git/commit/75c442286e7d9b9479dabb21483cea6e93bf6696))
 * Support disabling individulal Content types ([#22620](https://projects.theforeman.org/issues/22620), [1538b562](https://github.com/Katello/bastion/commit/1538b562e3de1cb3e603ccb97a332472b2e4fae2), [4d55e3ef](https://github.com/Katello/katello.git/commit/4d55e3eff05f91094ca685aeb3539ac480284f50))
 * repository sets api only returns enabled sets if org_id is provided ([#22290](https://projects.theforeman.org/issues/22290), [f27609ea](https://github.com/Katello/katello.git/commit/f27609ea770e39cc11a28fb2a77d48514668c298))
 * repo discovery table showing empty rows ([#22156](https://projects.theforeman.org/issues/22156), [e54b5a15](https://github.com/Katello/katello.git/commit/e54b5a156a0cc354d013466d9d7a039de7f6c964))

### Tests
 * test failing for #23965 fix ([#24117](https://projects.theforeman.org/issues/24117), [912cd57d](https://github.com/Katello/katello.git/commit/912cd57d10b107874d07a83378cbe94c52876076))
 * Tests stub controller to return Foreman::Task instead of a Dynlfow task, causing error ([#23954](https://projects.theforeman.org/issues/23954), [a333a273](https://github.com/Katello/katello.git/commit/a333a27316e147abff56e22cc9eaf3718ebb684c))
 * react tests are broken on master ([#23890](https://projects.theforeman.org/issues/23890), [6bb72289](https://github.com/Katello/katello.git/commit/6bb72289e758602fc5e2019d4ab248c82be0594e))
 * broken rubocop on master 'Unnecessary disabling of Metrics/ClassLength.' ([#23669](https://projects.theforeman.org/issues/23669), [f387b582](https://github.com/Katello/katello.git/commit/f387b5825f8913e0e0ea5cb851eb6149c527e669))
 * grunt eslint failing on master ([#23305](https://projects.theforeman.org/issues/23305), [724bd0a6](https://github.com/Katello/katello.git/commit/724bd0a6266a2d10d0365e4f5fbef43a6b8c059b))
 * Add nightly apipie cache to hammer-cli-katello tests ([#23230](https://projects.theforeman.org/issues/23230), [81da7627](https://github.com/Katello/hammer-cli-katello.git/commit/81da76272edb2ea7153c68e8b5e813b88a02fcc3))
 * Port robottelo tests for kt_environment ([#23005](https://projects.theforeman.org/issues/23005), [ad973e65](https://github.com/Katello/katello.git/commit/ad973e656215c01af4be5f6c17f4d6a984dce8e9), [4d012e26](https://github.com/Katello/katello.git/commit/4d012e267bfcc7f6572053c8b4d662a98634dd4b), [f2e35006](https://github.com/Katello/katello.git/commit/f2e350061934d191a7b1bb09a500ebab8b1dfa51))
 * failing foreman test on devel setup when ran with katello enabled ([#22917](https://projects.theforeman.org/issues/22917), [ef23f1d3](https://github.com/Katello/katello.git/commit/ef23f1d34c22cc621d13153f1d38fb6682159d2a))
 * Run hammer-cli-katello tests with Ruby 2.3, 2.4, 2.5 to match hammer-cli[-foreman] ([#22712](https://projects.theforeman.org/issues/22712), [b96b8115](https://github.com/Katello/hammer-cli-katello.git/commit/b96b8115284f007f38c8d329d8c4655a64b6560b))
 * test failure around katello_urls_helper ([#22600](https://projects.theforeman.org/issues/22600), [a65a9850](https://github.com/Katello/katello.git/commit/a65a9850bc81efb6d787518752dd6a5f155786d3))
 * Hammer expects improper sentences in tests ([#22504](https://projects.theforeman.org/issues/22504), [8a9f8518](https://github.com/Katello/hammer-cli-katello.git/commit/8a9f851892cd9b73fc49c428500a34be3f6ed7fd))
 * hammer host-collection list doesn't require organization options ([#22503](https://projects.theforeman.org/issues/22503), [8a9f8518](https://github.com/Katello/hammer-cli-katello.git/commit/8a9f851892cd9b73fc49c428500a34be3f6ed7fd))

### Notifications
 * Getting "disk is % full" warnings even for < 90% ([#24093](https://projects.theforeman.org/issues/24093), [6d90fb6e](https://github.com/Katello/katello.git/commit/6d90fb6e83b4de83d805682eab084f8bfaa4b645))
 * multiple paused state "Create Pulpdiskspace" notifications is beng triggered in dynflow ([#23326](https://projects.theforeman.org/issues/23326), [30203315](https://github.com/Katello/katello.git/commit/302033155de1038950001cd6e8c23140b9edd7e6), [9ab0d774](https://github.com/Katello/katello.git/commit/9ab0d774aba6a0f6f2050f5d9b5905f2b34cb433))
 * traceback during rake tasks around pulp_disk_space check ([#23003](https://projects.theforeman.org/issues/23003), [72a59ae8](https://github.com/Katello/katello.git/commit/72a59ae88ff258c028d29e4357981a8808895f74))

### Hosts
 * hammer host create using wrong API endpoint to list environments ([#24060](https://projects.theforeman.org/issues/24060), [49b48b3c](https://github.com/Katello/hammer-cli-katello.git/commit/49b48b3c1d431da10c254e3c59e62552cb909122))
 * Content host registration instructions recommends HTTPS over HTTP ([#23921](https://projects.theforeman.org/issues/23921), [38623a1a](https://github.com/Katello/katello.git/commit/38623a1a66b68cce54147bf0592291dbca672b1c))
 * host last_checkin changes should not be audited ([#23914](https://projects.theforeman.org/issues/23914), [6fbe1b10](https://github.com/Katello/katello.git/commit/6fbe1b101fffdafe724ef32cdfa2c6811512f924))
 * Unclear Error when performing bulk action of Manage Repository Set against Hosts without Content registration ([#23887](https://projects.theforeman.org/issues/23887), [d2b7208c](https://github.com/Katello/katello.git/commit/d2b7208cdb7378238736a3b09d79a1579fed90be))
 * hosts table still contains content_view_id and lifecycle_environment_id ([#23841](https://projects.theforeman.org/issues/23841), [552760af](https://github.com/Katello/katello.git/commit/552760af4c817a88631c85e178f95f8acaa729fe))
 * Unable to override hostgroup parameters from All hosts => edit host on WebUI ([#23706](https://projects.theforeman.org/issues/23706), [81ecd36f](https://github.com/Katello/katello.git/commit/81ecd36fc2749cbc6ccbd4471b76bcea35eb8584), [824172c2](https://github.com/Katello/katello.git/commit/824172c216d575946d13b8a0fcbafb0754f7c00c))
 *   Host registration fails with the error: "Validation failed: Host has already been taken" ([#23516](https://projects.theforeman.org/issues/23516), [275cecdf](https://github.com/Katello/katello.git/commit/275cecdfe5fc8d814df10399b4a8877da0b6011e))
 * unregistration doesn't handle hosts never registered in candlepin ([#23489](https://projects.theforeman.org/issues/23489), [8b997805](https://github.com/Katello/katello.git/commit/8b99780588e94a28918562c42d21b08e6636fa66))
 * content host installed packages list is blank ([#23464](https://projects.theforeman.org/issues/23464), [b48ca341](https://github.com/Katello/katello.git/commit/b48ca34122cc52e77a2c9e4421f276342ac4935c))
 * slow query when updating content facet applicability counts ([#23270](https://projects.theforeman.org/issues/23270), [9920678b](https://github.com/Katello/katello.git/commit/9920678b8c32ff1ff6e2cff3a427ce6bbf165da9))
 * SQL error when using PUT to upload RHSM facts ([#23022](https://projects.theforeman.org/issues/23022), [643d3b81](https://github.com/Katello/katello.git/commit/643d3b81b6e52bf0d43bce1ee7a9d3584965baca))
 * Race condition around host destroy ([#22873](https://projects.theforeman.org/issues/22873), [7ea6dc32](https://github.com/Katello/katello.git/commit/7ea6dc32e1bc2ef44689e3e456df1bec0813e95a))
 * Support SLES operating system fact on sub-man register ([#22797](https://projects.theforeman.org/issues/22797), [8bc1ef32](https://github.com/Katello/katello.git/commit/8bc1ef327073f03149b4dd29e0284b65c4b5626a))
 * Ansible Tower inventory integration is slow ([#22287](https://projects.theforeman.org/issues/22287), [d81c22ba](https://github.com/Katello/katello.git/commit/d81c22bad03c18327d9abbbece81ff42e7b382c2))

### Tooling
 * Orphaned candlepin/pulp consumers are not printed when running clean_backend_objects ([#24014](https://projects.theforeman.org/issues/24014), [c21c40b8](https://github.com/Katello/katello.git/commit/c21c40b8fcd30b9e997b30db87e3dcbd7d61429c))
 * Add humanized_name to jobs ([#23221](https://projects.theforeman.org/issues/23221), [f4b5e1bf](https://github.com/Katello/katello.git/commit/f4b5e1bf005c450e2aed27ac4fd07ac61134fe89))
 * Correct rubocop on candlepin proxies controller ([#23119](https://projects.theforeman.org/issues/23119), [f5c29747](https://github.com/Katello/katello.git/commit/f5c29747bfaa04c41a8c899c00dc21148e687d73))
 * Update rubocop_todo.yml ([#23092](https://projects.theforeman.org/issues/23092), [a353ce7e](https://github.com/Katello/katello.git/commit/a353ce7e9088df4c724f3901bf6c210ace058f8f))
 * remove dynflow dependency  ([#23088](https://projects.theforeman.org/issues/23088), [384c94df](https://github.com/Katello/katello.git/commit/384c94df21859ff7a1c83dbdd83b4532ddff25cc))
 * The license for rubygem-katello is Distributable. It should be GPLv2 ([#23052](https://projects.theforeman.org/issues/23052))
 * katello-change-hostname should remove last_scenario.yml only after success of installer ([#21517](https://projects.theforeman.org/issues/21517))

### Client/Agent
 * Orphaned queues are not auto-deleted for Qpid  at scale ([#24006](https://projects.theforeman.org/issues/24006), [8fc79619](https://github.com/Katello/katello-host-tools.git/commit/8fc796196e28de2ffdaca73735a0669a280b4bb5))
 * Restore legacy goferd plugin in host tools ([#23459](https://projects.theforeman.org/issues/23459), [d685e387](https://github.com/Katello/katello-host-tools.git/commit/d685e387064c4f0ce139efc604b957e8292a15a2))
 * Bats errata test fails -- package upload appears to not work on the client ([#23456](https://projects.theforeman.org/issues/23456), [d16caad1](https://github.com/Katello/katello-host-tools.git/commit/d16caad146aecf85353c51bf3453ad27f640c209), [d16caad1](https://github.com/Katello/katello-host-tools.git/commit/d16caad146aecf85353c51bf3453ad27f640c209))
 * Tracer executable is broken ([#23405](https://projects.theforeman.org/issues/23405), [01198628](https://github.com/Katello/katello-host-tools.git/commit/01198628349d3bf82b2ce3491c62332f951ade8e), [01198628](https://github.com/Katello/katello-host-tools.git/commit/01198628349d3bf82b2ce3491c62332f951ade8e))
 * Don't build tracer plugin on suse ([#23265](https://projects.theforeman.org/issues/23265))
 * Add Zypper plugin to upload Enabled repos report ([#22889](https://projects.theforeman.org/issues/22889), [ad90e326](https://github.com/Katello/katello-host-tools.git/commit/ad90e3266e41b39ac6607b6a132f0cca9083792a), [ad90e326](https://github.com/Katello/katello-host-tools.git/commit/ad90e3266e41b39ac6607b6a132f0cca9083792a))
 * RHEL8 support for subman facts plugin ([#22852](https://projects.theforeman.org/issues/22852), [0d05fce8](https://github.com/Katello/katello-host-tools.git/commit/0d05fce8a0bda7328b10869218b6bd098864e303), [0d05fce8](https://github.com/Katello/katello-host-tools.git/commit/0d05fce8a0bda7328b10869218b6bd098864e303))
 * Yum plugins should support DNF ([#22623](https://projects.theforeman.org/issues/22623), [3d102c3e](https://github.com/Katello/katello-host-tools.git/commit/3d102c3e7cddad99a1def2ebe7a759ea1001a689), [3d102c3e](https://github.com/Katello/katello-host-tools.git/commit/3d102c3e7cddad99a1def2ebe7a759ea1001a689))

### Web UI
 * Missing expander icon on Sync Status page ([#23988](https://projects.theforeman.org/issues/23988))
 * Notification.setRenderedSuccessMessage is not a function on bulk product sync ([#23957](https://projects.theforeman.org/issues/23957), [44ab18ee](https://github.com/Katello/katello.git/commit/44ab18ee50f0b0b92ec498d5b5bb34d4f508fcab))
 * Manifest History table should be with scrolling  ([#23908](https://projects.theforeman.org/issues/23908), [a101f789](https://github.com/Katello/katello.git/commit/a101f789ce0eea0eacc1e783445b7bdb6f7c6915))
 * New subscriptions page polling causes a re-render even when nothing changed  ([#23906](https://projects.theforeman.org/issues/23906), [1fbe855f](https://github.com/Katello/katello.git/commit/1fbe855fbd760350cd5bb91b471a43388b05de7e))
 * host collection bulk package actions modal is too short ([#23744](https://projects.theforeman.org/issues/23744), [87817105](https://github.com/Katello/katello.git/commit/87817105c69fe21ef55d49fb13ee0c565b4aedbd))
 * Tabs not hidden on CV page when a repository type is Disabled ([#23735](https://projects.theforeman.org/issues/23735), [913c33fe](https://github.com/Katello/katello.git/commit/913c33fe5b9f2fec72613982415690302f7a891a))
 * Katello Task pages lose context when refreshed ([#23264](https://projects.theforeman.org/issues/23264))
 * Red Hat Repositories shows blank page when in any/any org/loc ([#23201](https://projects.theforeman.org/issues/23201))
 * Subscription Page broken on nightly ([#23176](https://projects.theforeman.org/issues/23176))
 * Katello Task pages give 404 at /katello/api/v2/tasks? ([#23150](https://projects.theforeman.org/issues/23150), [55413875](https://github.com/Katello/katello.git/commit/55413875260ab85043155f10a9807b4261fd2c19))
 * Several JS errors visiting repo discovery page ([#23032](https://projects.theforeman.org/issues/23032))
 * Rename "docker" to "container" ([#23020](https://projects.theforeman.org/issues/23020), [2c8da09b](https://github.com/Katello/katello.git/commit/2c8da09b8f0c621415c511d97cf97e0ee713604f), [0ac18eb2](https://github.com/Katello/hammer-cli-katello.git/commit/0ac18eb23d1b013dffd90e6a69011ca4dcde45cf))
 * RH Repos content type selection is not preserved on page change ([#22966](https://projects.theforeman.org/issues/22966), [d897d870](https://github.com/Katello/katello.git/commit/d897d870512a73fd103ab9b1df4c88553084e5e0))
 * Fix styling issues on the Red Hat Repositories Page ([#22911](https://projects.theforeman.org/issues/22911), [031aa49b](https://github.com/Katello/katello.git/commit/031aa49b17b74478228ada8e7b76b4b8721f4db2))
 * RepositoryTypeIcon tests are intermittently failing due to ListViewIcon ([#22881](https://projects.theforeman.org/issues/22881), [80436b5a](https://github.com/Katello/katello.git/commit/80436b5a18f1b9c8ece1393b2a0144f5503f1caa))
 * RepositoryTypeIcon tests failing after patternfly-react upgrade ([#22825](https://projects.theforeman.org/issues/22825), [29d38292](https://github.com/Katello/katello.git/commit/29d382923348ab85c5b4c41c1440fed46e65397d))
 * RH repos Add opt-out classes for jquery-multiselect and select2 to  ([#22597](https://projects.theforeman.org/issues/22597), [c64df0d6](https://github.com/Katello/katello.git/commit/c64df0d6c9f305f365ae1c00f86351759137d0cf))
 * RH Repos: figure out way to disable jquery select2 and jquery-multiselect ([#22565](https://projects.theforeman.org/issues/22565))
 * Hook up live api for RH Repos page ([#22275](https://projects.theforeman.org/issues/22275), [cd6708ee](https://github.com/Katello/katello.git/commit/cd6708ee6dc95c677d9db6552fde1323fb647101))

### Content Views
 * SQL error when adding some puppet modules to CV: PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "katello_cv_puppet_modules_name" ([#23945](https://projects.theforeman.org/issues/23945), [403f7d48](https://github.com/Katello/katello.git/commit/403f7d484e66d1bd006dc3bb7c4ff7325b98a4a8))
 * Cannot destroy content view when it has content facet errata ([#23873](https://projects.theforeman.org/issues/23873), [69cd04b3](https://github.com/Katello/katello.git/commit/69cd04b32cda02492f8010aec650f2fd82e36423))
 * content view tag filters including all tags referencing a manifest ([#23747](https://projects.theforeman.org/issues/23747), [5630b0c0](https://github.com/Katello/katello.git/commit/5630b0c0d0a67e5c05aea26c97e7c0206f1b02d8))
 * History of actions of content views missing after upgrade to 6.3 ([#23667](https://projects.theforeman.org/issues/23667), [2befef5d](https://github.com/Katello/katello.git/commit/2befef5d7c7dd03e8ffb175ae285a6ba8140851c))
 * Cannot add/update description on composite content view ([#23660](https://projects.theforeman.org/issues/23660), [f2739a51](https://github.com/Katello/katello.git/commit/f2739a516c38983ffadd3f5f9346f2475b84e409))
 * Use correct validator in ContentViewFilterRules#create ([#23465](https://projects.theforeman.org/issues/23465), [9b8274b0](https://github.com/Katello/katello.git/commit/9b8274b050a596162cf1f0125da65eec7dece4c5))
 * content view ui pages call repositories index api twice ([#23432](https://projects.theforeman.org/issues/23432), [6ad60c59](https://github.com/Katello/katello.git/commit/6ad60c596e0bf0f34dec65fc19c057a8ce353f9a))
 * replace .uniq with .distinct in content view ([#23190](https://projects.theforeman.org/issues/23190), [6d7ca7cf](https://github.com/Katello/katello.git/commit/6d7ca7cf957a774db31d66bee3fbb9e4376986b2), [542a00c1](https://github.com/Katello/katello.git/commit/542a00c1d752327f6195a8608e69a7f115af4035))
 * Attempting to promote a content view to a lifecycle environment in another org is not immediately rejected ([#23185](https://projects.theforeman.org/issues/23185), [bc4a0352](https://github.com/Katello/katello.git/commit/bc4a03523a071252fe4ed7c13caa533d78df61c7))

### Lifecycle Environments
 * lifecycle environment container image tags search 500s on server ([#23850](https://projects.theforeman.org/issues/23850), [d434ddae](https://github.com/Katello/katello.git/commit/d434ddaedce55199812718c20fe3596fee2fa612))
 * lifecycle environment UI page missing breadcrumb switcher ([#23390](https://projects.theforeman.org/issues/23390), [cd85395b](https://github.com/Katello/katello.git/commit/cd85395bf0f786b5c88235bee33076fef8662c54))

### Documentation
 * Document how to setup katello with remote databases ([#23786](https://projects.theforeman.org/issues/23786))
 * add foreman-maintain documentation to theforeman.org ([#23762](https://projects.theforeman.org/issues/23762))
 * client install docs show old fedoras and sles is broken ([#23542](https://projects.theforeman.org/issues/23542))
 * Update backup section to say to encrypt or move somewhere secure ([#22648](https://projects.theforeman.org/issues/22648))

### Backup & Restore
 * katello-remove-orphans in cron.daily can clash with katello-backup ([#23647](https://projects.theforeman.org/issues/23647))
 * katello-restore is not properly restoring the incremental backup ([#23107](https://projects.theforeman.org/issues/23107))
 * Validate the --split-pulp-data-tar option on kbackup ([#23065](https://projects.theforeman.org/issues/23065))
 * katello-backup does incremental backup of pulp data when checksum check is failing ([#23029](https://projects.theforeman.org/issues/23029))
 * additional files to grab during backup ([#22971](https://projects.theforeman.org/issues/22971))
 * sudo requires a tty while running katello-backup from cron ([#22551](https://projects.theforeman.org/issues/22551))

### Database
 * foreman-installer --reset does not use mongo 3.4 ([#23564](https://projects.theforeman.org/issues/23564), [2daf7349](https://github.com/Katello/katello-installer.git/commit/2daf73494ce8ed6c388bdcbfeefe2e25f779a296))
 * Index name 'index_katello_content_facet_applicable_rpms_on_content_facet_id' on table 'katello_content_facet_applicable_rpms' is too long; the limit is 62 characters ([#23296](https://projects.theforeman.org/issues/23296), [cf741f2d](https://github.com/Katello/katello.git/commit/cf741f2d07d39c6c9fc527d54a7167ab367acf70))
 * [RFE] Update mongodb to 3.X ([#23030](https://projects.theforeman.org/issues/23030), [9042cf8e](https://github.com/Katello/katello-installer.git/commit/9042cf8e18022ab2f4bc9cb4e2aa4d4ed987effe), [e38ef520](https://github.com/Katello/katello-installer.git/commit/e38ef5205323c8017413bde254dcfef4936158c5), [ee65414b](https://github.com/Katello/katello-installer.git/commit/ee65414b6fe6b9c0fa25790f2e6d9e5704a4448e))

### API
 * Subscription quantity available should not show less than -1 ([#23535](https://projects.theforeman.org/issues/23535), [d4f27ce5](https://github.com/Katello/katello.git/commit/d4f27ce5a2d92331d1a2e80d39434c9db76435b1))
 * Add available attribute to upstream subscriptions API ([#23533](https://projects.theforeman.org/issues/23533), [7b34ceab](https://github.com/Katello/katello.git/commit/7b34ceabf4886dd995ec074d0c855e653e2614f3))
 * NumberValidator should come from apipie-rails ([#23460](https://projects.theforeman.org/issues/23460), [cf076c66](https://github.com/Katello/katello.git/commit/cf076c66a1ea2ab029eff11520ac3b1c794e967f))
 * Add param to limit upstream subs index to attachable ones ([#23182](https://projects.theforeman.org/issues/23182), [1390d88f](https://github.com/Katello/katello.git/commit/1390d88f2f4a7619bc15d8023772b3f3c33a61d9))
 * Set http proxy in a thread-safe way ([#23137](https://projects.theforeman.org/issues/23137), [79715ea0](https://github.com/Katello/katello.git/commit/79715ea04d73e7813bf36ec5b411466bdb5301ef))
 * Add API to update upstream_entitlement quantities ([#23111](https://projects.theforeman.org/issues/23111), [e6058817](https://github.com/Katello/katello.git/commit/e6058817a69510c3711e265418c89dd7adb682ce))
 * show total pools count for GET upstream subscriptions ([#23074](https://projects.theforeman.org/issues/23074), [779b8fde](https://github.com/Katello/katello.git/commit/779b8fdeefb1e13d91eea2fde6a20a5366708082))
 * Not able to attach a subscription to a host with hammer ([#22981](https://projects.theforeman.org/issues/22981), [49a3e258](https://github.com/Katello/katello.git/commit/49a3e2584b9e7842f3e17f84d533eb461f5b55f8))
 * Content view filter rule name param is wrongly documented as enum ([#22754](https://projects.theforeman.org/issues/22754))

### Foreman Proxy Content
 * server using :9090 port for smart-proxy pulp calls ([#23181](https://projects.theforeman.org/issues/23181), [ba6efb8e](https://github.com/Katello/katello.git/commit/ba6efb8eff377403584c989b24ea1d24c99553bd))
 * ISE when changing Organization setting of Smart Proxy when Lifecycle Environment is set ([#22795](https://projects.theforeman.org/issues/22795))

### OSTree
 * Cannot list ostree repos on new red hat repositories page ([#23171](https://projects.theforeman.org/issues/23171))

### Activation Key
 *  activation-key copy fails with "undefined method" and Internal Server Error ([#23084](https://projects.theforeman.org/issues/23084), [bc606efb](https://github.com/Katello/katello.git/commit/bc606efb144c2c60b12c26bc6187e8a13b2e535c), [556b48d8](https://github.com/Katello/katello.git/commit/556b48d812a8c4bd119c1e121e4d795badf55193))

### Candlepin
 * Upgrade to candlepin 2.3 ([#23068](https://projects.theforeman.org/issues/23068), [2d170866](https://github.com/Katello/katello.git/commit/2d170866abd0ebae1cb530f14e0fb5ace772f3dc))

### Performance
 * Katello Event Queue db queries need improvement ([#22978](https://projects.theforeman.org/issues/22978), [1066301f](https://github.com/Katello/katello.git/commit/1066301fbc7ddaaef6defb361edcee6825a7d113))

### GPG Keys
 * Remove GPG key size limit ([#22956](https://projects.theforeman.org/issues/22956), [4781bc4c](https://github.com/Katello/katello.git/commit/4781bc4cbe807a8842f93d97f3699652dcc73edc))

### Settings
 * Configurable 'expiring soon' days ([#22867](https://projects.theforeman.org/issues/22867), [b5dfba94](https://github.com/Katello/katello.git/commit/b5dfba941d0b479be04d5c5e3c8bd6a0ebf6435e))

### Docker
 * As a user, I can search docker manifests by digest. ([#22501](https://projects.theforeman.org/issues/22501), [22a94ce5](https://github.com/Katello/katello.git/commit/22a94ce568b50e3a85bf74b6ff4ea853c382c95a))
 * As a user, I can create an empty docker repository. ([#22302](https://projects.theforeman.org/issues/22302), [3b3f6552](https://github.com/Katello/katello.git/commit/3b3f65528d7df9c12c5b375626c4e54cb5ffb688))
 * As a user, I can upload container images to a repo. ([#22301](https://projects.theforeman.org/issues/22301), [9be8a09d](https://github.com/Katello/katello.git/commit/9be8a09d2d128312c793ae37c6ff14079ecfa894), [e3ffaab2](https://github.com/Katello/hammer-cli-katello.git/commit/e3ffaab26bcb66816c715cf2f84cadf6cd9697e3))

### ElasticSearch
 * Specifying wrong foreign key id for object (such as host or hostgroup) via hammer/api throws SQL error ([#21689](https://projects.theforeman.org/issues/21689), [18eb3558](https://github.com/Katello/katello.git/commit/18eb35587087fc5a67edeb4725ac322a015a3f42))

### Puppet
 * puppet module version not correct in content view ([#16699](https://projects.theforeman.org/issues/16699), [b1b3829f](https://github.com/Katello/katello.git/commit/b1b3829f208a8ccba44503b23db7af49332cc2c6), [9c295089](https://github.com/Katello/katello.git/commit/9c295089f2343101763d11ea8ee9dfa2111f2260))

### Other
 * Intermittent failure w/ robottello test_attributes ([#24337](https://projects.theforeman.org/issues/24337))
 * Prevent jest from hitting engines directory ([#24255](https://projects.theforeman.org/issues/24255), [bd3aa865](https://github.com/Katello/katello.git/commit/bd3aa8651d7806be21e23f8b70c9f72e5c17e208))
 * katello paginates call when fetching upstream subs, leading to possible tomcat error ([#24187](https://projects.theforeman.org/issues/24187), [bf842cc2](https://github.com/Katello/katello.git/commit/bf842cc29b142985e86deb9b02705536ca6d3648))
 * Subscriptions page is broken on centos7-katello-bats-ci ([#24157](https://projects.theforeman.org/issues/24157), [7e0065c6](https://github.com/Katello/katello.git/commit/7e0065c611fb2fb3a69aeed54ebec1317f5fd7cb))
 * The server appears to cause a yum update when an errata is apply is issued through katello-agent ([#24081](https://projects.theforeman.org/issues/24081), [414f5ede](https://github.com/Katello/katello-host-tools.git/commit/414f5edebbad043180fd4e4a01a950fbdb149557))
 * Katello package install via katello-agent fails ([#24079](https://projects.theforeman.org/issues/24079))
 * React router doesn't catch empty state buttons  ([#23966](https://projects.theforeman.org/issues/23966), [bcb8a5e0](https://github.com/Katello/katello.git/commit/bcb8a5e04fa02c67636180477319082dd1c1ea12))
 * SSL Certs of a Repository are not updated if Product is changes ([#23964](https://projects.theforeman.org/issues/23964), [83ef4029](https://github.com/Katello/katello.git/commit/83ef4029426a73f691c47b4915a8e0c246754238))
 * Update Katello spec enable SCL for Mongo ([#23767](https://projects.theforeman.org/issues/23767))
 * Incorrect REST API call GET /api/hosts/:host_id/tracer ([#23737](https://projects.theforeman.org/issues/23737), [c3eb1961](https://github.com/Katello/katello.git/commit/c3eb1961ad1598f0d098924fe7901b155d6579b2))
 * CV publish can publish puppet before yum, causing provisioning issues ([#23672](https://projects.theforeman.org/issues/23672), [9ae7dbf5](https://github.com/Katello/katello.git/commit/9ae7dbf506a766d8af23123875d241ce707ea2a6))
 * Unable to promote content views due to 'null' value for timestamps. ([#23662](https://projects.theforeman.org/issues/23662), [31b9d1da](https://github.com/Katello/katello.git/commit/31b9d1da4ef29a15bba73f71b743690dbdcc5256))
 * Remove unused methods from PulpTaskStatus ([#23659](https://projects.theforeman.org/issues/23659), [ecebc6c7](https://github.com/Katello/katello.git/commit/ecebc6c7c344fff6697d0f865323f804d3bf3b2d))
 * Relative comparisons of package versions/releases via scoped_search are incorrect ([#23644](https://projects.theforeman.org/issues/23644), [10a12816](https://github.com/Katello/katello.git/commit/10a12816281b64a968cc9c50a9c5244960f5dcea))
 * Suse errata do not show icons for their type and they are not summed up ([#23566](https://projects.theforeman.org/issues/23566), [583b7870](https://github.com/Katello/katello.git/commit/583b787092889d01286a31fc245c7b3b3e05bc18))
 * Collect file /var/log/qdrouterd/qdrouterd.log ([#23556](https://projects.theforeman.org/issues/23556), [6aef875a](https://github.com/theforeman/foreman-packaging.git/commit/6aef875a0f2d9165d7beb156786dd57cdc52510c))
 * hammer-cli-katello should check string formats in tests ([#23484](https://projects.theforeman.org/issues/23484), [6e04d2b8](https://github.com/Katello/hammer-cli-katello.git/commit/6e04d2b836f8b409659354c682b8b7ecafdf23af))
 * Include content view in @repository_url@ helper, if applicable ([#23478](https://projects.theforeman.org/issues/23478), [ccc815fd](https://github.com/Katello/katello.git/commit/ccc815fdae73782592a64732c1d4d07fdb97f697))
 * Upgrades should allow picking up new puppet server versions automatically ([#23470](https://projects.theforeman.org/issues/23470), [43dd5195](https://github.com/Katello/katello-installer.git/commit/43dd519593fbc85680934fbbaefe1566fe8b31e2), [f78722c8](https://github.com/Katello/katello-installer.git/commit/f78722c8fd6525cc882242fc0fbc7480ebaac0b2), [36df1d5a](https://github.com/Katello/katello-installer.git/commit/36df1d5aeec6621328d117e93579c16fba9c9f02), [a5d2df88](https://github.com/Katello/katello-installer.git/commit/a5d2df888dfc1d6f96986e62638cf14f4e78787f))
 * can't attach custom subscriptions to an activation key ([#23421](https://projects.theforeman.org/issues/23421), [128de120](https://github.com/Katello/katello.git/commit/128de1204b5c8ede23ac345d1b3c9b7f73758883))
 * foreman-installer --reset has hardcoded default internal database names ([#23375](https://projects.theforeman.org/issues/23375), [cd6a57e2](https://github.com/Katello/katello-installer.git/commit/cd6a57e268efa0820a1f7b55c06acf3187435538))
 * Remove puppet-service_wait from installer ([#23368](https://projects.theforeman.org/issues/23368), [3c171512](https://github.com/Katello/katello-installer.git/commit/3c171512e72d8dbe3c1431b517df11cc69e94cfb))
 * Katello uses md5hash function incompatible with FIPS-enabled environments ([#23363](https://projects.theforeman.org/issues/23363), [39b472d5](https://github.com/Katello/katello.git/commit/39b472d5b91c75573bd7b07157e21b942ef3c8ae))
 * Accept local pool ids when listing upstream subscriptions ([#23338](https://projects.theforeman.org/issues/23338), [ba154186](https://github.com/Katello/katello.git/commit/ba154186b518dcb4f1d6e81b401836d7cebde5c0))
 * db:seed is failing for Ansible job templates when foreman_ansible is not installed ([#23329](https://projects.theforeman.org/issues/23329), [d1a16e43](https://github.com/Katello/katello.git/commit/d1a16e43f74d89f0cc813f6a231a7b0e3d9dc8ac))
 * available_errata.rabl should be named available_errata.json.rabl ([#23316](https://projects.theforeman.org/issues/23316), [327f7864](https://github.com/Katello/katello.git/commit/327f786466a06e750b209e412fb75520a2b0339a))
 * apipie param type :number is not a valid validator ([#23287](https://projects.theforeman.org/issues/23287))
 * Can't add activation key to hostgroup via UI ([#23274](https://projects.theforeman.org/issues/23274), [b8e73d0a](https://github.com/Katello/katello.git/commit/b8e73d0a871cddb6683c6a107bf429b290261ab4))
 * Checking if SendExpireSoonNotifications, CreatePulpDiskSpaceNotifications is planned doesn't take into account possible existence of different plans ([#23257](https://projects.theforeman.org/issues/23257), [27d20522](https://github.com/Katello/katello.git/commit/27d205224895b5b56bb402237add9f3366c2969e))
 * Include package.json and webpack in gemspec ([#23217](https://projects.theforeman.org/issues/23217), [2e19c475](https://github.com/Katello/katello.git/commit/2e19c47513122cfa706f2af4002e9b47310de2a2))
 * tasks page not showing action name for some events ([#23160](https://projects.theforeman.org/issues/23160))
 * rake katello:reset errors with `Setting::Auth is marked as readonly` ([#23154](https://projects.theforeman.org/issues/23154), [60aecb8b](https://github.com/Katello/katello.git/commit/60aecb8b761ab47de76d9d4f23c9691b26fd4c2e))
 * UpstreamPool placement is causing autoreloading to not happen in dev environment ([#23122](https://projects.theforeman.org/issues/23122), [7ff9760d](https://github.com/Katello/katello.git/commit/7ff9760d83a22b99f9bcd5a482cc618978916a9e))
 * (MANAGE SUBS) default pagination params should be forwarded to upstream Candlepin ([#23121](https://projects.theforeman.org/issues/23121), [ebf578eb](https://github.com/Katello/katello.git/commit/ebf578eb52f46458cf6cd10a799db962e9551c5b))
 * UI: After add the CV on the CCV, Content View still on the list to add ([#23120](https://projects.theforeman.org/issues/23120), [776fb48d](https://github.com/Katello/bastion/commit/776fb48dd363c70b05c2bc4d73c19fb82c8289bb))
 * Remote Execution Fails for Applying errata in Content Hosts Via Remote Execution Method. ([#23082](https://projects.theforeman.org/issues/23082), [3f036a0b](https://github.com/Katello/katello.git/commit/3f036a0b1354b8c54d1361a130e3485f85b8528f))
 * getting error when accessing Content -> Red Hat Repositories: Oops, we're sorry but something went wrong Can't find entry point 'katello' in webpack manifest ([#23036](https://projects.theforeman.org/issues/23036))
 * dev server hangs on code change ([#23006](https://projects.theforeman.org/issues/23006), [a9b6c66b](https://github.com/Katello/katello.git/commit/a9b6c66b841048b6780e3f0293e8d33d68b368fb))
 * run upgrade task import_backend_consumer_attributes ([#22970](https://projects.theforeman.org/issues/22970), [3ea2a5d5](https://github.com/Katello/katello-installer.git/commit/3ea2a5d5e03f9e51086b1fff91161599c4898bab))
 * Upstream HttpResource should use current Organizatoin ([#22944](https://projects.theforeman.org/issues/22944), [dfd14f4a](https://github.com/Katello/katello.git/commit/dfd14f4abcd48491cac8ac3331d5b9ede075864c))
 * Bastion_katello string extraction process results in duplicate strings. ([#22919](https://projects.theforeman.org/issues/22919), [a7a652d4](https://github.com/Katello/katello.git/commit/a7a652d46f7e28bf775e4fe9863180f23cfe89e8))
 * extract the strings for hammer_cli_katello ([#22870](https://projects.theforeman.org/issues/22870), [94089a67](https://github.com/Katello/hammer-cli-katello.git/commit/94089a670faf7ae4155f601e78a29e857e82ab63))
 * Extract the latest strings from the dev environment.  ([#22859](https://projects.theforeman.org/issues/22859), [83b439d5](https://github.com/Katello/katello.git/commit/83b439d546613ff8ea01f01a268a18bd621c3813))
 * `subscription-manager unsubscribe --pool` ends up with 'ActionController::RoutingError (No route matches [DELETE] "/rhsm/consumers/2cb5a878-3a70-482c-b22d-a23092ecfc62/entitlements/pool/ff808081620a401901620b8aa3520037") ([#22835](https://projects.theforeman.org/issues/22835), [b59cf1e9](https://github.com/Katello/katello.git/commit/b59cf1e9be2a97744aa7ae21808a1c5a47de7478))
 * Allow setting verify_ssl to false when talking to pulp ([#22826](https://projects.theforeman.org/issues/22826), [d6f2de92](https://github.com/Katello/katello.git/commit/d6f2de926749f8304f75bd150aa3b947f8184810))
 * RH repos XUI: accessing page by url breaks page layout ([#22808](https://projects.theforeman.org/issues/22808))
 * As a user I would like to skip srpms on sync ([#22803](https://projects.theforeman.org/issues/22803), [9872e5b4](https://github.com/Katello/katello.git/commit/9872e5b48212742715383b50d25b649fd2ed50c3))
 * Create a Skip list for yum importer ([#22802](https://projects.theforeman.org/issues/22802))
 * Repository Sets API should not return docker and containerimage types or custom products ([#22564](https://projects.theforeman.org/issues/22564), [3883410f](https://github.com/Katello/katello.git/commit/3883410f269289ef2d65ad526f778112c811a446))
 * Katello assets need to use Foreman plugin assets configuration ([#22484](https://projects.theforeman.org/issues/22484), [069aa015](https://github.com/Katello/katello.git/commit/069aa01560be152c8f128a05dd26a0a514c98488))
 * [Audit] Refresh manifest ([#22373](https://projects.theforeman.org/issues/22373), [2e99f59b](https://github.com/Katello/katello.git/commit/2e99f59bc158713bf8b195d928ca3a137d51c0bb))
 * Clean up postgres write-access failure in katello-backup ([#22060](https://projects.theforeman.org/issues/22060))
 * backup & restore do not work with remote DB ([#20550](https://projects.theforeman.org/issues/20550), [81fcaa5f](https://github.com/Katello/katello-installer.git/commit/81fcaa5fa6d9f166823538f9999a03afafcc3875))
