# 3.7.0 Blonde Ale (2018-07-16)

## Features 

### Web UI
 * Upgrade and pin patternfly-react to v2.5.1 ([#23791](http://projects.theforeman.org/issues/23791), [7563b482](http://github.com/katello/katello/commit/7563b482416bbb4aebe4b458539349fc50669db0))
 * Update react to 16.3+ ([#23691](http://projects.theforeman.org/issues/23691), [2c69a40c](http://github.com/katello/katello/commit/2c69a40c24e7eb14c35c1bfde02bd9cfc15a9530))
 * Open URLs to access.redhat.com with a new tab ([#23282](http://projects.theforeman.org/issues/23282), [6ca79a2d](http://github.com/katello/katello/commit/6ca79a2d19382fd43bdff61110ded2a0aece7ae8))
 * RH Repos: add a more accurate message when all repositories are enabled ([#22936](http://projects.theforeman.org/issues/22936), [f8054d48](http://github.com/katello/katello/commit/f8054d48c98013dcd51c6155183cab56a55056fb))
 * Add RH subscriptions routing skeleton page to labs pages ([#22726](http://projects.theforeman.org/issues/22726), [8def2f53](http://github.com/katello/katello/commit/8def2f53052a7516a3d3409465d855d33b511454))
 * RH Repos: hook up repository content type selector ([#22563](http://projects.theforeman.org/issues/22563), [112de8c1](http://github.com/katello/katello/commit/112de8c129e484ac4e8f6f56e9ae4693d877f11c))
 * RH Repos: do not truncate repository (set) titles ([#22562](http://projects.theforeman.org/issues/22562), [5cac7fa8](http://github.com/katello/katello/commit/5cac7fa8fc6e15614c217bc507bd955979b93e1c))
 * RH Repos: use pagination from patternfly-react ([#22371](http://projects.theforeman.org/issues/22371), [112de8c1](http://github.com/katello/katello/commit/112de8c129e484ac4e8f6f56e9ae4693d877f11c))
 * Replace the old RH repos page with the new "labs" version ([#22370](http://projects.theforeman.org/issues/22370), [bf02310d](http://github.com/katello/katello/commit/bf02310dc2156c10532dbde8be7e02556eefcde7))
 * Red Hat Repositories: Ability to enable/disable repositories  ([#21649](http://projects.theforeman.org/issues/21649), [9e7f1304](http://github.com/katello/katello/commit/9e7f1304ab05b6f344b502933385dd7869320871))
 * Red Hat Repositories: preload popular repository sets ([#21648](http://projects.theforeman.org/issues/21648), [09cecfa0](http://github.com/katello/katello/commit/09cecfa093b7755c7deac4c7459a3690c865ec8d))

### Installer
 * katello-installer certificate options should not require --certs-server-cert-req ([#23766](http://projects.theforeman.org/issues/23766), [35722703](http://github.com/katello/katello-installer/commit/35722703f8252ab835b6f5bfd8be04ce4d547465))
 * Show instructions after installing the development scenario ([#22558](http://projects.theforeman.org/issues/22558), [874e1311](http://github.com/katello/katello-installer/commit/874e1311300f8db40b68861670736bb85655ce9c), [de924728](http://github.com/katello/katello-installer/commit/de924728e5c219bbc828191349e38c46fc1d70ee))

### Tests
 * Port robottelo tests for hostgroups ([#23724](http://projects.theforeman.org/issues/23724), [b9fe3e12](http://github.com/katello/katello/commit/b9fe3e1244cec2f348599298e71562b94241609c))

### Subscriptions
 * RH subscriptions: group subscriptions by SKU ([#23694](http://projects.theforeman.org/issues/23694), [fd8c2c01](http://github.com/katello/katello/commit/fd8c2c012d62055b052a08820b37c76f35fef44e))
 * RH Subscription: disable relevant actions in manifest modal when a task is in process ([#23325](http://projects.theforeman.org/issues/23325), [62d69e98](http://github.com/katello/katello/commit/62d69e987c06867a8a439ca62ae06470b1add1f5))
 * RH Subscriptions: create notification when refresh, delete, and upload tasks have completed ([#23324](http://projects.theforeman.org/issues/23324), [86bc5fcc](http://github.com/katello/katello/commit/86bc5fcc864d422997ee17bebd3d8139d449cf56))
 * RH Subscriptions: hook up save call to upstream subscriptions page ([#23301](http://projects.theforeman.org/issues/23301), [023da41d](http://github.com/katello/katello/commit/023da41db131d3b294b2c11d0b6b68da752f2594))
 * RH Subscriptions: show modal for delete confirmation ([#23286](http://projects.theforeman.org/issues/23286), [e8ff2f4e](http://github.com/katello/katello/commit/e8ff2f4ee53ac8bae98cb3c47c3d798eca90fd03))
 * RH Subscriptions: show progress bar over table for tasks that are running  ([#23285](http://projects.theforeman.org/issues/23285), [2e7aef07](http://github.com/katello/katello/commit/2e7aef07c56840e702c4562362884b865498d82d))
 * Move labs subscriptions page to /subscriptions and delete existing angular page  ([#23275](http://projects.theforeman.org/issues/23275), [cdc03f08](http://github.com/katello/katello/commit/cdc03f0836cde3b41675fd4df13cc96048c333af))
 * (MANAGE SUBS) As an API user, i want to know the upstream quantity for a set of local pools ([#23087](http://projects.theforeman.org/issues/23087), [78c0c322](http://github.com/katello/katello/commit/78c0c322d27ec84a8c0b37431d17eb900a15a8e8))
 * As an API user, I want to delete subscriptions from my allocation. ([#22909](http://projects.theforeman.org/issues/22909), [59e3a1a4](http://github.com/katello/katello/commit/59e3a1a4fbdb4665e47258e15dc1fb6b6ff999f5), [11aa29b2](http://github.com/katello/katello/commit/11aa29b26ea4727e22c7a2448a5ecc6bcb1732c7))
 * RH Subscriptions: hide actions when satellite is in disconnected mode ([#22836](http://projects.theforeman.org/issues/22836), [62d69e98](http://github.com/katello/katello/commit/62d69e987c06867a8a439ca62ae06470b1add1f5))
 * RH Subscriptions: add GET API actions and reducers ([#22781](http://projects.theforeman.org/issues/22781), [6dbf2352](http://github.com/katello/katello/commit/6dbf23520e6eba147860cc63d9b122990dc23213))
 * Add ability to edit Red Hat Subscription entitlement quantities ([#22734](http://projects.theforeman.org/issues/22734), [e66857d4](http://github.com/katello/katello/commit/e66857d4bbcef70449e8d288e964830fbf6f6f27))
 * Add export CSV capability to the Red Hat Subscriptions page ([#22732](http://projects.theforeman.org/issues/22732), [9fe4494f](http://github.com/katello/katello/commit/9fe4494f526eda96bf1b232beaf0eecc504caccd))
 * Add delete subscriptions capability to the RH subscriptions page ([#22731](http://projects.theforeman.org/issues/22731), [29846107](http://github.com/katello/katello/commit/29846107338df3f7c9a81a97cd10df5bf5782b22))
 * Add Manage Manifest modal and button to the RH subscriptions page ([#22730](http://projects.theforeman.org/issues/22730), [2a5bde8f](http://github.com/katello/katello/commit/2a5bde8fd566266ee39a7793b9bc750756f27fe7))
 * Add search capabilities to the Red Hat Subscriptions Page ([#22729](http://projects.theforeman.org/issues/22729), [a1698055](http://github.com/katello/katello/commit/a16980550614bd73f0efb92e924c664f31f56b10))
 * Add read-only RH subscriptions table ([#22728](http://projects.theforeman.org/issues/22728), [6dbf2352](http://github.com/katello/katello/commit/6dbf23520e6eba147860cc63d9b122990dc23213))
 * List available subscriptions from the customer portal ([#22594](http://projects.theforeman.org/issues/22594), [53d7ed1b](http://github.com/katello/katello/commit/53d7ed1b877dff5ef9ce2ddfb3ff6e1fe6552512))
 * Utilize empty state view when subscriptions are not present in an allocation ([#22366](http://projects.theforeman.org/issues/22366), [6dbf2352](http://github.com/katello/katello/commit/6dbf23520e6eba147860cc63d9b122990dc23213))

### Hosts
 * support updating installed products via host update api ([#23189](http://projects.theforeman.org/issues/23189), [81c160a6](http://github.com/katello/katello/commit/81c160a621d1867a48ac461666a67ece0150bc47))

### API
 * Subscriptions index should reveal which came from upstream ([#23034](http://projects.theforeman.org/issues/23034), [f3fa9712](http://github.com/katello/katello/commit/f3fa97128f7484e97c5deb35b92f40bbee01728d))
 * Repository Set Search auto complete api ([#22202](http://projects.theforeman.org/issues/22202), [ead3189a](http://github.com/katello/katello/commit/ead3189a28e2a950b694f1ac3db0777139fd295f))

### Tooling
 * Update Katello nightly to use Pulp 2.16 Beta ([#22947](http://projects.theforeman.org/issues/22947))

### Errata Management
 * Job Template to install Errata on SUSE ([#22755](http://projects.theforeman.org/issues/22755), [038dce86](http://github.com/katello/katello/commit/038dce8696d16079b09e6c982ba4053de2a56dc2))

### Provisioning
 * adding support for liveimg ([#22736](http://projects.theforeman.org/issues/22736), [e4b99393](http://github.com/katello/katello/commit/e4b993935744c8fe706aaef8fb38c8ce265d3754))

### Content Views
 * Auto publish Composite if component updates ([#21994](http://projects.theforeman.org/issues/21994), [580f7f80](http://github.com/katello/katello/commit/580f7f808d9b06bbf5ee2f947e121008caf583f6))

### Repositories
 * Add ability to add SSL protected repositories in Katello ([#15068](http://projects.theforeman.org/issues/15068), [95594cfb](http://github.com/katello/katello/commit/95594cfb7a2bafc1b66d4463142196d3d3dadf92), [a659b23b](http://github.com/katello/katello/commit/a659b23bf6f9e523ff9345cd1a5746ab1786320a), [2934f376](http://github.com/katello/katello/commit/2934f376473e341ffbb10ac1ffd42efb8c5bdab8), [d026e463](http://github.com/katello/katello/commit/d026e463f368b5ccf926a7125832720b2083630b), [865101a1](http://github.com/katello/katello/commit/865101a111b8a94db1b13cec8a10f4b0046ef8f8))

### Other
 * As an API user, I should be able to obtain the bugzillas associated with an Errata. ([#23317](http://projects.theforeman.org/issues/23317), [c9d15653](http://github.com/katello/katello/commit/c9d15653ddce51410e42f36de18886816f8ba06d))
 * Add a script to pin installer dependencies when branching ([#23207](http://projects.theforeman.org/issues/23207), [0d192013](http://github.com/katello/katello-installer/commit/0d1920139957508d416cc1c41970f31d78b20cf2))
 * Include Katello job templates for Ansible REX provider from community-templates ([#23202](http://projects.theforeman.org/issues/23202), [0715b962](http://github.com/katello/katello/commit/0715b9621669e2ada6704e8c72801585445cb9fe))
 * [RFE] (MANAGE SUBS) As an API or CLI user, I want to add available subscriptions to my allocation. ([#22853](http://projects.theforeman.org/issues/22853), [1015edbc](http://github.com/katello/katello/commit/1015edbcdb73b6e18bf89acf5c5d6de35ca75f91))
 * Port robottelo tests for katello organization ([#22794](http://projects.theforeman.org/issues/22794), [ac828fc3](http://github.com/katello/katello/commit/ac828fc3a7aa9f21553030515cc759d505ee73a3), [3af3efa0](http://github.com/katello/katello/commit/3af3efa0f57f432b31cdf0d144d8ab052b570a34), [6710b15c](http://github.com/katello/katello/commit/6710b15ce2c9a19a8b8e16615f422fb99644d822), [6c88f18e](http://github.com/katello//commit/6c88f18e1f44742ef16656c5ba4cf94f92181540))
 * [Audit]  Add audit to more Katello resources - Content-view, Repository, Lifecycle environment and their associations ([#22690](http://projects.theforeman.org/issues/22690), [68d64c0f](http://github.com/katello/katello/commit/68d64c0ff8223a4f73ea13c13644e86e0318b31e))
 * [Audit] has_many association between sync-plan & product ([#22377](http://projects.theforeman.org/issues/22377))
 * [Audit] Sync Plans, Activation Keys, GPG keys, Product ([#22372](http://projects.theforeman.org/issues/22372), [0c0a45a6](http://github.com/katello/katello/commit/0c0a45a6a125d057948f40d3c5a6dfa193383a4c))
 * Add autocomplete component ([#22254](http://projects.theforeman.org/issues/22254), [fdddce0c](http://github.com/katello/katello/commit/fdddce0c9fab92aeb11611f5cfcc4ebaff5fa65e))
 * Notification for subscriptions expiring soon  ([#19314](http://projects.theforeman.org/issues/19314), [390b0967](http://github.com/katello/katello/commit/390b09672a64cf88a84ef7b8411f771ef2ba948c))

## Bug Fixes 

### Dashboard
 * dashboard widget data bleeds out of widget box if browser window is small - table headers ([#24230](http://projects.theforeman.org/issues/24230), [15badd61](http://github.com/katello/katello/commit/15badd6133709b211fdb152cd9bd0beb72d8f4b3))

### Subscriptions
 * RH Subscriptions: caret is backwards on grouped subscriptions ([#24222](http://projects.theforeman.org/issues/24222), [823d062a](http://github.com/katello/katello/commit/823d062a821c2761ae636214fd37cc2d41d45a95))
 * Main subscription placed at bottom of collapsed subscriptions ([#24206](http://projects.theforeman.org/issues/24206), [ae73cdd4](http://github.com/katello/katello/commit/ae73cdd4f44c20c019512741366d00d6856b9784))
 * Subscription update value of 0 passes UI validation, but fails in task. ([#24197](http://projects.theforeman.org/issues/24197), [e3c8094d](http://github.com/katello/katello/commit/e3c8094da0ef41fe77f37c754a336f63c03fac02))
 * Cannot update entitlements for subscriptions with unlimited guests ([#24145](http://projects.theforeman.org/issues/24145), [c093b588](http://github.com/katello/katello/commit/c093b5886e067e9943b8f4edbf18077333a180c0))
 * Subscriptions page is blank when switching between Orgs ([#24142](http://projects.theforeman.org/issues/24142), [bfd20b92](http://github.com/katello/katello/commit/bfd20b921b4852003c5ec38fb143e04b19eab406))
 * Navigating back to Subscriptions from Add Subscriptions results in blank page. ([#24140](http://projects.theforeman.org/issues/24140), [bfd20b92](http://github.com/katello/katello/commit/bfd20b921b4852003c5ec38fb143e04b19eab406))
 * Upstream Subscriptions API/GET is returning upstream id twice and missing local katello id ([#24064](http://projects.theforeman.org/issues/24064), [b3efb0eb](http://github.com/katello/katello/commit/b3efb0ebda8d56628d2a92cfe2f14e24e63bc1c4))
 * The new add subscriptions page renders SubscriptionDetailsPage at the same time ([#23944](http://projects.theforeman.org/issues/23944), [837ebedf](http://github.com/katello/katello/commit/837ebedf32677686e0e7cf79ea307119e1d80a36))
 * Error deleting manifest. PG::UniqueViolation: ERROR: duplicate key value violates unique constraint "index_katello_pools_on_cp_id" ([#23942](http://projects.theforeman.org/issues/23942), [936291aa](http://github.com/katello/katello/commit/936291aa1c52402606acaf4ce6d52994d3685521))
 * RH Subscriptions: center the loading spinner and otherwise adhere to pf best practices ([#23922](http://projects.theforeman.org/issues/23922), [94943dad](http://github.com/katello/katello/commit/94943dad0dde2e6a6cc1c64791ebeb756902fb90))
 * Katello Content is shared across organizations ([#23904](http://projects.theforeman.org/issues/23904), [6d2cf88b](http://github.com/katello/katello/commit/6d2cf88b114d8ba7ef98fa31cd00e2f8f4ce0672))
 * subscriptions pages/api errors with 'NoMethodError: undefined method `id' for nil:NilClass' ([#23823](http://projects.theforeman.org/issues/23823), [8234c3af](http://github.com/katello/katello/commit/8234c3af59ae5ab8eb2f3a312fd6728c3a8f2679))
 * update product name and repo names when content is updated ([#23788](http://projects.theforeman.org/issues/23788), [cc60ee97](http://github.com/katello/katello/commit/cc60ee97c2b67a78083937117cacb10b60e800eb))
 * Remove "Red Hat" from subscriptions menu item ([#23783](http://projects.theforeman.org/issues/23783), [7a4c63ac](http://github.com/katello/katello/commit/7a4c63ac41b4987dc24af4c1696960574093eb68))
 * Attached subscription quantity is showing as "Automatic" instead of a number in "Quantity" field for hypervisor ([#23761](http://projects.theforeman.org/issues/23761), [d5fb04c8](http://github.com/katello/katello/commit/d5fb04c81deab79aae060ba636adbe11c2eecab7))
 * Error when changing or refreshing manifest ([#23733](http://projects.theforeman.org/issues/23733), [f8c98b77](http://github.com/katello/katello/commit/f8c98b77163e17a3643a71d0903361a45b01dd20))
 * RH Subscriptions: add subscriptions details page ([#23687](http://projects.theforeman.org/issues/23687), [0fc33e91](http://github.com/katello/katello/commit/0fc33e916f65d36948f0de8f55a0442a6f407604))
 * Speed up manifest import with lots of pools ([#23604](http://projects.theforeman.org/issues/23604), [6de94a2c](http://github.com/katello/katello/commit/6de94a2c18f2f23bc45d2a012bede539fd70755d))
 * Refresh and Delete manifest buttons aren't disabled when manifest is deleted ([#23571](http://projects.theforeman.org/issues/23571), [b510bf39](http://github.com/katello/katello/commit/b510bf39ba3b927c625a6588543bfeabdd96c1e0))
 * JS error when opening manage manifest modal ([#23552](http://projects.theforeman.org/issues/23552), [9f8bd2b6](http://github.com/katello/katello/commit/9f8bd2b6ca8f9e0fc3439aa5076bfcbfa1cc65d6))
 * JS error on modals in the new subscriptions page ([#23541](http://projects.theforeman.org/issues/23541))
 * Upstream subscriptions, quantities are wrong when editing subscriptions ([#23532](http://projects.theforeman.org/issues/23532), [bac5a1b3](http://github.com/katello/katello/commit/bac5a1b3b0f99489c49e34bef319e1751c93614f))
 * subscriptions api should sort by name by default ([#23472](http://projects.theforeman.org/issues/23472), [bd9d6923](http://github.com/katello/katello/commit/bd9d6923ed5517a40d3851770fdefc4730552b82))
 * RH Subscriptions: Modal opening each time the task polling returns ([#23284](http://projects.theforeman.org/issues/23284))
 * compliance reasons don't refresh automatically after changing status via UI ([#23105](http://projects.theforeman.org/issues/23105), [9fd15508](http://github.com/katello/katello/commit/9fd155084a0fe32f9359d57e9ec6faa02e342b92))
 * Indexing subscription facet pools generates  sql query per consumer ([#23096](http://projects.theforeman.org/issues/23096), [3298bb1a](http://github.com/katello/katello/commit/3298bb1a72e4b21e0ca5006a4c62dffb50b3d41f))
 * Errors in webpack compile after merging subscription pages ([#23094](http://projects.theforeman.org/issues/23094), [b5c05f63](http://github.com/katello/katello/commit/b5c05f63c2ba1ad12193326d120900db089095a9))
 * upstream_subscriptions url should be org scoped ([#23069](http://projects.theforeman.org/issues/23069), [6e3f500f](http://github.com/katello/katello/commit/6e3f500f1302c91af264c14e99373d842a03cf4d))
 * As a user, I want the 'disconnected' setting to control the behavior interactions with the RH Portal ([#22931](http://projects.theforeman.org/issues/22931), [c2cd0d2e](http://github.com/katello/katello/commit/c2cd0d2ef9064cafd40bb3eb7bd4c7eedc48f8b8), [e33167b7](http://github.com/katello/katello/commit/e33167b7499fb6b11a53147e20c59d035ce7847e))
 * SAP HANA Repository cannot be enabled if future dated subscriptions of SAP HANA are added to the subscription manifest file. ([#22878](http://projects.theforeman.org/issues/22878), [1917b37d](http://github.com/katello/katello/commit/1917b37ddf760b8aac291b30757e85ecf6c94ddc))
 * Provide a setting to indicate Katello is operating in disconnected mode ([#22799](http://projects.theforeman.org/issues/22799), [37b0f613](http://github.com/katello/katello/commit/37b0f6136bbb57548c841a3d8e749a863d6ca511))

### Errata Management
 * No applicable errata/updates on content host ([#24214](http://projects.theforeman.org/issues/24214), [1ffbd8af](http://github.com/katello/katello-host-tools/commit/1ffbd8afe9dfce6cf69f9b3bfed840a8e340256b))

### Repositories
 * Red Hat Enterprise Linux Atomic Host (Kickstart) fails to enable ([#24134](http://projects.theforeman.org/issues/24134), [31ab44e2](http://github.com/katello/katello/commit/31ab44e2675a51cf3b6089d989faf38970c15fc2))
 * RH Repositories page contains wrong link to subscriptions page ([#24128](http://projects.theforeman.org/issues/24128), [b8ae5419](http://github.com/katello/katello/commit/b8ae5419abe9d335c813dee68e1f5b64594355ac))
 * Deleting a sync plan does not stop syncing repos from it ([#24068](http://projects.theforeman.org/issues/24068), [c5a25d9f](http://github.com/katello/katello/commit/c5a25d9f35127ab68883891d30085eb8e57d84a4))
 * foreman-rake katello:regenerate_repo_metadata failed with "NoMethodError: undefined method `in_default_view' for #<Array:0x000000000ce126f0>" ([#23943](http://projects.theforeman.org/issues/23943), [bd3b03ac](http://github.com/katello/katello/commit/bd3b03ac37f9dfc99cc5755b7f73314998ad268e))
 * Atomic repos show up for enabling even if ostree plugin is not installed ([#23925](http://projects.theforeman.org/issues/23925), [ded508ed](http://github.com/katello//commit/ded508edae3acaab169e0ea130dbba3db93eb0b2))
 * repositories index returning incorrect repository ids for lifecycle environment ([#23866](http://projects.theforeman.org/issues/23866), [d434ddae](http://github.com/katello/katello/commit/d434ddaedce55199812718c20fe3596fee2fa612))
 * RH repos pages throws error "No translation key found." ([#23730](http://projects.theforeman.org/issues/23730), [f80698e4](http://github.com/katello/katello/commit/f80698e4a918e6374931412cc87632340da63a75))
 * Content type selector on Red Hat Repos page is empty ([#23680](http://projects.theforeman.org/issues/23680), [8fb712ad](http://github.com/katello/katello/commit/8fb712ad121b6dd004c6075f97f4af99e8060397))
 * undefined method `include?' for nil:NilClass on selecting some kickstart repos on RH repos page ([#23674](http://projects.theforeman.org/issues/23674), [e98bc550](http://github.com/katello/katello/commit/e98bc550f9842382c27cc11a40ba3b53754b0b68))
 * Cannot list ostree (or other Repos with no substitutions) on new red hat repositories page  ([#23650](http://projects.theforeman.org/issues/23650), [318b71e4](http://github.com/katello/katello/commit/318b71e43e0dd3b44c43520a42e61f0fb8ff8e30))
 * hammer repository-set enable doesn't work ([#23341](http://projects.theforeman.org/issues/23341), [3b35e474](http://github.com/katello/katello/commit/3b35e474b266742c4973078ac14bc96c782fa491))
 * s390x kickstart repos should be bootable ([#23292](http://projects.theforeman.org/issues/23292), [b56273f7](http://github.com/katello/katello/commit/b56273f715422ebaa9e9ef990d2910615a559a8c), [f4a98312](http://github.com/katello/katello-installer/commit/f4a983121401227119c55b229158c2075b07a9e9), [00105a73](http://github.com/katello/katello-installer/commit/00105a73b6da68d6051ed8a62e380b263f2bc6ec))
 * It possible to create puppet repository using name contains html tag ([#23085](http://projects.theforeman.org/issues/23085), [da6438e7](http://github.com/katello/katello/commit/da6438e7e575324ffe93c6ceeb0984ac1e66bdbf))
 * When searching packages, epoch is not shown unless a package from list is selected ([#23051](http://projects.theforeman.org/issues/23051), [4360a3d2](http://github.com/katello/katello/commit/4360a3d2228dc29a336c7f5b95ee370c169edb1d))
 * deprecate/remove force_post_sync_actions ([#23033](http://projects.theforeman.org/issues/23033), [1b26c3ca](http://github.com/katello/katello/commit/1b26c3ca90c8d197f35cbb1eefe5bcbe0489d538))
 * Docker Tags link on repository details page points to Docker Manifests ([#22998](http://projects.theforeman.org/issues/22998), [5b99a98e](http://github.com/katello/katello/commit/5b99a98ed23094fcec4938c99378f95a9d7c4e44))
 * do not allow file:// repos with on_demand ([#22769](http://projects.theforeman.org/issues/22769), [4da7cd36](http://github.com/katello/katello/commit/4da7cd36c79ba6dba22a02d9204e49d1ebcd1a1f))
 * Invalid search: PG::UndefinedColumn: ERROR:  column katello_product_contents.name does not exist - on searching by name ([#22760](http://projects.theforeman.org/issues/22760), [f7a5ffa9](http://github.com/katello/katello/commit/f7a5ffa9f1efc7d4aad9c2c5b61bdcec083de237))
 * Katello doesn't update sync notification URL on sync ([#22647](http://projects.theforeman.org/issues/22647), [75c44228](http://github.com/katello/katello/commit/75c442286e7d9b9479dabb21483cea6e93bf6696))
 * repository sets api only returns enabled sets if org_id is provided ([#22290](http://projects.theforeman.org/issues/22290), [f27609ea](http://github.com/katello/katello/commit/f27609ea770e39cc11a28fb2a77d48514668c298))
 * repo discovery table showing empty rows ([#22156](http://projects.theforeman.org/issues/22156), [e54b5a15](http://github.com/katello/katello/commit/e54b5a156a0cc354d013466d9d7a039de7f6c964))

### Tests
 * test failing for #23965 fix ([#24117](http://projects.theforeman.org/issues/24117), [912cd57d](http://github.com/katello/katello/commit/912cd57d10b107874d07a83378cbe94c52876076))
 * Tests stub controller to return Foreman::Task instead of a Dynlfow task, causing error ([#23954](http://projects.theforeman.org/issues/23954), [a333a273](http://github.com/katello/katello/commit/a333a27316e147abff56e22cc9eaf3718ebb684c))
 * react tests are broken on master ([#23890](http://projects.theforeman.org/issues/23890), [6bb72289](http://github.com/katello/katello/commit/6bb72289e758602fc5e2019d4ab248c82be0594e))
 * broken rubocop on master 'Unnecessary disabling of Metrics/ClassLength.' ([#23669](http://projects.theforeman.org/issues/23669), [f387b582](http://github.com/katello/katello/commit/f387b5825f8913e0e0ea5cb851eb6149c527e669))
 * grunt eslint failing on master ([#23305](http://projects.theforeman.org/issues/23305), [724bd0a6](http://github.com/katello/katello/commit/724bd0a6266a2d10d0365e4f5fbef43a6b8c059b))
 * Add nightly apipie cache to hammer-cli-katello tests ([#23230](http://projects.theforeman.org/issues/23230), [81da7627](http://github.com/katello/hammer-cli-katello/commit/81da76272edb2ea7153c68e8b5e813b88a02fcc3))
 * Port robottelo tests for kt_environment ([#23005](http://projects.theforeman.org/issues/23005), [ad973e65](http://github.com/katello/katello/commit/ad973e656215c01af4be5f6c17f4d6a984dce8e9), [4d012e26](http://github.com/katello/katello/commit/4d012e267bfcc7f6572053c8b4d662a98634dd4b), [f2e35006](http://github.com/katello//commit/f2e350061934d191a7b1bb09a500ebab8b1dfa51))
 * failing foreman test on devel setup when ran with katello enabled ([#22917](http://projects.theforeman.org/issues/22917), [ef23f1d3](http://github.com/katello/katello/commit/ef23f1d34c22cc621d13153f1d38fb6682159d2a))
 * Run hammer-cli-katello tests with Ruby 2.3, 2.4, 2.5 to match hammer-cli[-foreman] ([#22712](http://projects.theforeman.org/issues/22712), [b96b8115](http://github.com/katello/hammer-cli-katello/commit/b96b8115284f007f38c8d329d8c4655a64b6560b))
 * test failure around katello_urls_helper ([#22600](http://projects.theforeman.org/issues/22600), [a65a9850](http://github.com/katello/katello/commit/a65a9850bc81efb6d787518752dd6a5f155786d3))
 * Hammer expects improper sentences in tests ([#22504](http://projects.theforeman.org/issues/22504), [8a9f8518](http://github.com/katello/hammer-cli-katello/commit/8a9f851892cd9b73fc49c428500a34be3f6ed7fd))
 * hammer host-collection list doesn't require organization options ([#22503](http://projects.theforeman.org/issues/22503), [8a9f8518](http://github.com/katello/hammer-cli-katello/commit/8a9f851892cd9b73fc49c428500a34be3f6ed7fd))

### Notifications
 * Getting "disk is % full" warnings even for < 90% ([#24093](http://projects.theforeman.org/issues/24093), [6d90fb6e](http://github.com/katello/katello/commit/6d90fb6e83b4de83d805682eab084f8bfaa4b645))
 * multiple paused state "Create Pulpdiskspace" notifications is beng triggered in dynflow ([#23326](http://projects.theforeman.org/issues/23326), [30203315](http://github.com/katello/katello/commit/302033155de1038950001cd6e8c23140b9edd7e6), [9ab0d774](http://github.com/katello/katello/commit/9ab0d774aba6a0f6f2050f5d9b5905f2b34cb433))
 * traceback during rake tasks around pulp_disk_space check ([#23003](http://projects.theforeman.org/issues/23003), [72a59ae8](http://github.com/katello/katello/commit/72a59ae88ff258c028d29e4357981a8808895f74))

### Hosts
 * hammer host create using wrong API endpoint to list environments ([#24060](http://projects.theforeman.org/issues/24060), [49b48b3c](http://github.com/katello/hammer-cli-katello/commit/49b48b3c1d431da10c254e3c59e62552cb909122))
 * Content host registration instructions recommends HTTPS over HTTP ([#23921](http://projects.theforeman.org/issues/23921), [38623a1a](http://github.com/katello/katello/commit/38623a1a66b68cce54147bf0592291dbca672b1c))
 * host last_checkin changes should not be audited ([#23914](http://projects.theforeman.org/issues/23914), [6fbe1b10](http://github.com/katello/katello/commit/6fbe1b101fffdafe724ef32cdfa2c6811512f924))
 * Unclear Error when performing bulk action of Manage Repository Set against Hosts without Content registration ([#23887](http://projects.theforeman.org/issues/23887), [d2b7208c](http://github.com/katello/katello/commit/d2b7208cdb7378238736a3b09d79a1579fed90be))
 * hosts table still contains content_view_id and lifecycle_environment_id ([#23841](http://projects.theforeman.org/issues/23841), [552760af](http://github.com/katello/katello/commit/552760af4c817a88631c85e178f95f8acaa729fe))
 * Unable to override hostgroup parameters from All hosts => edit host on WebUI ([#23706](http://projects.theforeman.org/issues/23706), [81ecd36f](http://github.com/katello/katello/commit/81ecd36fc2749cbc6ccbd4471b76bcea35eb8584))
 *   Host registration fails with the error: "Validation failed: Host has already been taken" ([#23516](http://projects.theforeman.org/issues/23516), [275cecdf](http://github.com/katello/katello/commit/275cecdfe5fc8d814df10399b4a8877da0b6011e))
 * unregistration doesn't handle hosts never registered in candlepin ([#23489](http://projects.theforeman.org/issues/23489), [8b997805](http://github.com/katello/katello/commit/8b99780588e94a28918562c42d21b08e6636fa66))
 * content host installed packages list is blank ([#23464](http://projects.theforeman.org/issues/23464), [b48ca341](http://github.com/katello/katello/commit/b48ca34122cc52e77a2c9e4421f276342ac4935c))
 * slow query when updating content facet applicability counts ([#23270](http://projects.theforeman.org/issues/23270), [9920678b](http://github.com/katello/katello/commit/9920678b8c32ff1ff6e2cff3a427ce6bbf165da9))
 * SQL error when using PUT to upload RHSM facts ([#23022](http://projects.theforeman.org/issues/23022), [643d3b81](http://github.com/katello/katello/commit/643d3b81b6e52bf0d43bce1ee7a9d3584965baca))
 * Race condition around host destroy ([#22873](http://projects.theforeman.org/issues/22873), [7ea6dc32](http://github.com/katello/katello/commit/7ea6dc32e1bc2ef44689e3e456df1bec0813e95a))
 * Support SLES operating system fact on sub-man register ([#22797](http://projects.theforeman.org/issues/22797), [8bc1ef32](http://github.com/katello/katello/commit/8bc1ef327073f03149b4dd29e0284b65c4b5626a))
 * Ansible Tower inventory integration is slow ([#22287](http://projects.theforeman.org/issues/22287), [d81c22ba](http://github.com/katello/katello/commit/d81c22bad03c18327d9abbbece81ff42e7b382c2))

### Hammer
 * hammer content-view create --repositories doesn't work with --name ([#24023](http://projects.theforeman.org/issues/24023), [1dc05861](http://github.com/katello/hammer-cli-katello/commit/1dc05861ed2121a5f02db6f70efdb367bf4cd61b))
 * hammer doesn't show "release-version" and "service-level" for "activation-key" ([#23972](http://projects.theforeman.org/issues/23972))
 * hammer content-view puppet-module add raises ArgumentError (wrong number of arguments (given 1, expected 0)) ([#22763](http://projects.theforeman.org/issues/22763))
 * Hammer product info does not parse the repositories info correctly ([#22758](http://projects.theforeman.org/issues/22758), [d3cce829](http://github.com/katello/katello/commit/d3cce8294a4e7ff24fb6ce94f1c9adda1adf5cf1))

### Installer
 * yum Update from satellite 6.3.1 to 6.4 failed at dependency resolution ([#24020](http://projects.theforeman.org/issues/24020), [87b00163](http://github.com/katello/katello-installer/commit/87b001637a8274c6432e8d0f2af33ff67bee58e4))
 * Mongodb is_master fact requires the mongodb to be present ([#23978](http://projects.theforeman.org/issues/23978))
 * Remove no longer needed steps from upgrade hooks ([#23657](http://projects.theforeman.org/issues/23657), [33152353](http://github.com/katello/katello-installer/commit/33152353cdf5842875aa49f09745978f7fe11d91))
 * Remove puppet-common dependency ([#23567](http://projects.theforeman.org/issues/23567), [c2ec4415](http://github.com/katello/katello-installer/commit/c2ec441589495089393134c3d80573adce62c2db))
 * Configure qrouterd to log into syslog ([#23557](http://projects.theforeman.org/issues/23557), [e99bd28a](http://github.com/katello/puppet-foreman_proxy_content/commit/e99bd28a4e7b4692cbf664dbe11b37d0c687b41f), [92bb8311](http://github.com/katello/puppet-qpid/commit/92bb8311acf66136d87af857fdf901d69c87a684))
 * Clean up el6 references & remove service-wait ([#23407](http://projects.theforeman.org/issues/23407), [c55ba7fe](http://github.com/katello/katello-installer/commit/c55ba7fe28dda9b5a8f472355df0eb22649b4cd6))
 * foreman-installer --reset does not work with remote Mongo DB ([#23309](http://projects.theforeman.org/issues/23309), [1aba38ff](http://github.com/katello/katello-installer/commit/1aba38ff9ef35b700587546dfd3c1abf747137a2))
 * satellite-installer --katello-pulp-max-speed leads to broken pulp ([#23233](http://projects.theforeman.org/issues/23233), [045dedfd](http://github.com/katello/puppet-pulp/commit/045dedfd3be324b2f3b156c7e5aca0c771f19285))
 * pulp_deb is not installed on forklifts centos7-devel ([#23198](http://projects.theforeman.org/issues/23198), [705ed02b](http://github.com/katello//commit/705ed02b32fd1712d2980cd49e4c5934e77ae6a1))
 * foreman-installer fails when ssl-verify is set to false for candlepin db ([#23025](http://projects.theforeman.org/issues/23025), [34388103](http://github.com/katello/katello-installer/commit/343881039d055c579482fd036f72568f5f5dfcc4), [04c0e2c7](http://github.com/katello/puppet-candlepin/commit/04c0e2c72e7d78bd3853dadcd707a6ba9d6de19f))
 * NoMethodError ssl_client_cert while foreman-installer --upgrade ([#23000](http://projects.theforeman.org/issues/23000), [b9a4e63c](http://github.com/katello/katello/commit/b9a4e63c25c0b59311e0943a26796d2a05cb1548))
 * Inconsistent examples in capsule-certs-generate screen output ([#22949](http://projects.theforeman.org/issues/22949), [56e63429](http://github.com/katello/katello-installer/commit/56e63429977c067f7c0de84ff4d6a574fdbf5919))
 * Remove devel scenario and module from installer ([#22905](http://projects.theforeman.org/issues/22905), [dd307b0b](http://github.com/katello/katello-installer/commit/dd307b0b7c9bc541d801785f78e1024e87b75947))
 * Script in katello-ca-consumer-latest.noarch.rpm throws a warning on SLES client ([#22884](http://projects.theforeman.org/issues/22884), [b96b3d62](http://github.com/katello/puppet-certs/commit/b96b3d620e98a6d3b6a306ef2a1c14c8b672042e))
 * capsule-certs-generate logfile should be under /var/log/foreman* ([#22810](http://projects.theforeman.org/issues/22810), [f321f98e](http://github.com/katello/katello-installer/commit/f321f98eb4e2e2e09424ab0346cc854e08819dd5))
 * Katello-certs-check need to check and make sure "new line" present at the end of the certificate ([#22725](http://projects.theforeman.org/issues/22725), [f960c6ee](http://github.com/katello/puppet-certs/commit/f960c6ee052898469a19d1d72746d0ad0507e805))
 * [RFE] katello-certs-check to distinguish between Satellite and Capsule ([#22694](http://projects.theforeman.org/issues/22694), [e521bbab](http://github.com/katello/katello-installer/commit/e521bbab4ac743142b565f77ff202bdccf431b18))
 * Performing katello-certs-check without argument -r REQ_FILE shows readlink: missing operand ([#22608](http://projects.theforeman.org/issues/22608), [d14c9b6f](http://github.com/katello/katello-installer/commit/d14c9b6fe8a7e192a5b3e0d08ddd960f3f775e60))
 * Satellite 6: katello-certs-check does not ensures certificate has SubjectAltName ([#22598](http://projects.theforeman.org/issues/22598), [ca1b8374](http://github.com/katello/katello-installer/commit/ca1b8374e1c12efdc61b379db2cf961432bbc5d3), [4c35334a](http://github.com/katello/katello-installer/commit/4c35334a710cb95b860959f697f110550984d567))
 * Tomcat server.xml templates require the sslEnabledProtocols parameter to  ([#22567](http://projects.theforeman.org/issues/22567), [7320f16d](http://github.com/katello/puppet-candlepin/commit/7320f16d2acfab52d7da26e3b4bdee44501244a9))

### Tooling
 * Orphaned candlepin/pulp consumers are not printed when running clean_backend_objects ([#24014](http://projects.theforeman.org/issues/24014), [c21c40b8](http://github.com/katello/katello/commit/c21c40b8fcd30b9e997b30db87e3dcbd7d61429c))
 * Add humanized_name to jobs ([#23221](http://projects.theforeman.org/issues/23221), [f4b5e1bf](http://github.com/katello/katello/commit/f4b5e1bf005c450e2aed27ac4fd07ac61134fe89))
 * Correct rubocop on candlepin proxies controller ([#23119](http://projects.theforeman.org/issues/23119), [f5c29747](http://github.com/katello/katello/commit/f5c29747bfaa04c41a8c899c00dc21148e687d73))
 * Update rubocop_todo.yml ([#23092](http://projects.theforeman.org/issues/23092), [a353ce7e](http://github.com/katello/katello/commit/a353ce7e9088df4c724f3901bf6c210ace058f8f))
 * remove dynflow dependency  ([#23088](http://projects.theforeman.org/issues/23088), [384c94df](http://github.com/katello/katello/commit/384c94df21859ff7a1c83dbdd83b4532ddff25cc))
 * katello-change-hostname should remove last_scenario.yml only after success of installer ([#21517](http://projects.theforeman.org/issues/21517))

### Client/Agent
 * Orphaned queues are not auto-deleted for Qpid  at scale ([#24006](http://projects.theforeman.org/issues/24006), [8fc79619](http://github.com/katello/katello-host-tools/commit/8fc796196e28de2ffdaca73735a0669a280b4bb5))
 * Restore legacy goferd plugin in host tools ([#23459](http://projects.theforeman.org/issues/23459), [d685e387](http://github.com/katello/katello-host-tools/commit/d685e387064c4f0ce139efc604b957e8292a15a2))
 * Bats errata test fails -- package upload appears to not work on the client ([#23456](http://projects.theforeman.org/issues/23456), [d16caad1](http://github.com/katello/katello-host-tools/commit/d16caad146aecf85353c51bf3453ad27f640c209), [d16caad1](http://github.com/katello/katello-host-tools/commit/d16caad146aecf85353c51bf3453ad27f640c209))
 * Tracer executable is broken ([#23405](http://projects.theforeman.org/issues/23405), [01198628](http://github.com/katello/katello-host-tools/commit/01198628349d3bf82b2ce3491c62332f951ade8e), [01198628](http://github.com/katello/katello-host-tools/commit/01198628349d3bf82b2ce3491c62332f951ade8e))
 * Don't build tracer plugin on suse ([#23265](http://projects.theforeman.org/issues/23265))
 * Add Zypper plugin to upload Enabled repos report ([#22889](http://projects.theforeman.org/issues/22889), [ad90e326](http://github.com/katello/katello-host-tools/commit/ad90e3266e41b39ac6607b6a132f0cca9083792a), [ad90e326](http://github.com/katello/katello-host-tools/commit/ad90e3266e41b39ac6607b6a132f0cca9083792a))
 * RHEL8 support for subman facts plugin ([#22852](http://projects.theforeman.org/issues/22852), [0d05fce8](http://github.com/katello/katello-host-tools/commit/0d05fce8a0bda7328b10869218b6bd098864e303), [0d05fce8](http://github.com/katello/katello-host-tools/commit/0d05fce8a0bda7328b10869218b6bd098864e303))
 * Yum plugins should support DNF ([#22623](http://projects.theforeman.org/issues/22623), [3d102c3e](http://github.com/katello/katello-host-tools/commit/3d102c3e7cddad99a1def2ebe7a759ea1001a689), [3d102c3e](http://github.com/katello/katello-host-tools/commit/3d102c3e7cddad99a1def2ebe7a759ea1001a689))

### Web UI
 * Missing expander icon on Sync Status page ([#23988](http://projects.theforeman.org/issues/23988))
 * Notification.setRenderedSuccessMessage is not a function on bulk product sync ([#23957](http://projects.theforeman.org/issues/23957), [44ab18ee](http://github.com/katello/katello/commit/44ab18ee50f0b0b92ec498d5b5bb34d4f508fcab))
 * Manifest History table should be with scrolling  ([#23908](http://projects.theforeman.org/issues/23908), [a101f789](http://github.com/katello/katello/commit/a101f789ce0eea0eacc1e783445b7bdb6f7c6915))
 * New subscriptions page polling causes a re-render even when nothing changed  ([#23906](http://projects.theforeman.org/issues/23906), [1fbe855f](http://github.com/katello/katello/commit/1fbe855fbd760350cd5bb91b471a43388b05de7e))
 * host collection bulk package actions modal is too short ([#23744](http://projects.theforeman.org/issues/23744), [87817105](http://github.com/katello/katello/commit/87817105c69fe21ef55d49fb13ee0c565b4aedbd))
 * Tabs not hidden on CV page when a repository type is Disabled ([#23735](http://projects.theforeman.org/issues/23735), [913c33fe](http://github.com/katello/katello/commit/913c33fe5b9f2fec72613982415690302f7a891a))
 * Katello Task pages lose context when refreshed ([#23264](http://projects.theforeman.org/issues/23264))
 * Subscription Page broken on nightly ([#23176](http://projects.theforeman.org/issues/23176))
 * Katello Task pages give 404 at /katello/api/v2/tasks? ([#23150](http://projects.theforeman.org/issues/23150), [55413875](http://github.com/katello/katello/commit/55413875260ab85043155f10a9807b4261fd2c19))
 * Rename "docker" to "container" ([#23020](http://projects.theforeman.org/issues/23020), [2c8da09b](http://github.com/katello/katello/commit/2c8da09b8f0c621415c511d97cf97e0ee713604f), [0ac18eb2](http://github.com/katello/hammer-cli-katello/commit/0ac18eb23d1b013dffd90e6a69011ca4dcde45cf))
 * RH Repos content type selection is not preserved on page change ([#22966](http://projects.theforeman.org/issues/22966), [d897d870](http://github.com/katello/katello/commit/d897d870512a73fd103ab9b1df4c88553084e5e0))
 * Fix styling issues on the Red Hat Repositories Page ([#22911](http://projects.theforeman.org/issues/22911), [031aa49b](http://github.com/katello/katello/commit/031aa49b17b74478228ada8e7b76b4b8721f4db2))
 * RepositoryTypeIcon tests are intermittently failing due to ListViewIcon ([#22881](http://projects.theforeman.org/issues/22881), [80436b5a](http://github.com/katello/katello/commit/80436b5a18f1b9c8ece1393b2a0144f5503f1caa))
 * RepositoryTypeIcon tests failing after patternfly-react upgrade ([#22825](http://projects.theforeman.org/issues/22825), [29d38292](http://github.com/katello/katello/commit/29d382923348ab85c5b4c41c1440fed46e65397d))
 * RH repos Add opt-out classes for jquery-multiselect and select2 to  ([#22597](http://projects.theforeman.org/issues/22597), [c64df0d6](http://github.com/katello/katello/commit/c64df0d6c9f305f365ae1c00f86351759137d0cf))
 * Hook up live api for RH Repos page ([#22275](http://projects.theforeman.org/issues/22275), [cd6708ee](http://github.com/katello/katello/commit/cd6708ee6dc95c677d9db6552fde1323fb647101))

### Content Views
 * SQL error when adding some puppet modules to CV: PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "katello_cv_puppet_modules_name" ([#23945](http://projects.theforeman.org/issues/23945), [403f7d48](http://github.com/katello/katello/commit/403f7d484e66d1bd006dc3bb7c4ff7325b98a4a8))
 * Cannot destroy content view when it has content facet errata ([#23873](http://projects.theforeman.org/issues/23873), [69cd04b3](http://github.com/katello/katello/commit/69cd04b32cda02492f8010aec650f2fd82e36423))
 * content view tag filters including all tags referencing a manifest ([#23747](http://projects.theforeman.org/issues/23747), [5630b0c0](http://github.com/katello/katello/commit/5630b0c0d0a67e5c05aea26c97e7c0206f1b02d8))
 * History of actions of content views missing after upgrade to 6.3 ([#23667](http://projects.theforeman.org/issues/23667), [2befef5d](http://github.com/katello/katello/commit/2befef5d7c7dd03e8ffb175ae285a6ba8140851c))
 * Cannot add/update description on composite content view ([#23660](http://projects.theforeman.org/issues/23660), [f2739a51](http://github.com/katello/katello/commit/f2739a516c38983ffadd3f5f9346f2475b84e409))
 * Use correct validator in ContentViewFilterRules#create ([#23465](http://projects.theforeman.org/issues/23465), [9b8274b0](http://github.com/katello/katello/commit/9b8274b050a596162cf1f0125da65eec7dece4c5))
 * content view ui pages call repositories index api twice ([#23432](http://projects.theforeman.org/issues/23432), [6ad60c59](http://github.com/katello/katello/commit/6ad60c596e0bf0f34dec65fc19c057a8ce353f9a))
 * replace .uniq with .distinct in content view ([#23190](http://projects.theforeman.org/issues/23190), [6d7ca7cf](http://github.com/katello/katello/commit/6d7ca7cf957a774db31d66bee3fbb9e4376986b2), [542a00c1](http://github.com/katello/katello/commit/542a00c1d752327f6195a8608e69a7f115af4035))
 * Attempting to promote a content view to a lifecycle environment in another org is not immediately rejected ([#23185](http://projects.theforeman.org/issues/23185), [bc4a0352](http://github.com/katello/katello/commit/bc4a03523a071252fe4ed7c13caa533d78df61c7))

### Lifecycle Environments
 * lifecycle environment container image tags search 500s on server ([#23850](http://projects.theforeman.org/issues/23850), [d434ddae](http://github.com/katello/katello/commit/d434ddaedce55199812718c20fe3596fee2fa612))
 * lifecycle environment UI page missing breadcrumb switcher ([#23390](http://projects.theforeman.org/issues/23390), [cd85395b](http://github.com/katello/katello/commit/cd85395bf0f786b5c88235bee33076fef8662c54))

### Documentation
 * Document how to setup katello with remote databases ([#23786](http://projects.theforeman.org/issues/23786))
 * add foreman-maintain documentation to theforeman.org ([#23762](http://projects.theforeman.org/issues/23762))
 * client install docs show old fedoras and sles is broken ([#23542](http://projects.theforeman.org/issues/23542))
 * Update backup section to say to encrypt or move somewhere secure ([#22648](http://projects.theforeman.org/issues/22648))

### Upgrades
 * content_source_id value is not migrated during upgrade ([#23781](http://projects.theforeman.org/issues/23781), [ced737ab](http://github.com/katello/katello/commit/ced737abf2752cda53da2149cb02dbecb8277cd9))
 * Upgrade after Mongo 3.x is installed fails out on remove_nodes_distributors ([#23649](http://projects.theforeman.org/issues/23649), [3049c5f3](http://github.com/katello/katello-installer/commit/3049c5f359ebbde52e62d6194bcddcac9fd67989))

### Backup & Restore
 * katello-remove-orphans in cron.daily can clash with katello-backup ([#23647](http://projects.theforeman.org/issues/23647))
 * katello-restore is not properly restoring the incremental backup ([#23107](http://projects.theforeman.org/issues/23107))
 * katello-backup does incremental backup of pulp data when checksum check is failing ([#23029](http://projects.theforeman.org/issues/23029))
 * additional files to grab during backup ([#22971](http://projects.theforeman.org/issues/22971))
 * sudo requires a tty while running katello-backup from cron ([#22551](http://projects.theforeman.org/issues/22551))

### Database
 * foreman-installer --reset does not use mongo 3.4 ([#23564](http://projects.theforeman.org/issues/23564), [2daf7349](http://github.com/katello/katello-installer/commit/2daf73494ce8ed6c388bdcbfeefe2e25f779a296))
 * Index name 'index_katello_content_facet_applicable_rpms_on_content_facet_id' on table 'katello_content_facet_applicable_rpms' is too long; the limit is 62 characters ([#23296](http://projects.theforeman.org/issues/23296), [cf741f2d](http://github.com/katello/katello/commit/cf741f2d07d39c6c9fc527d54a7167ab367acf70))

### API
 * Subscription quantity available should not show less than -1 ([#23535](http://projects.theforeman.org/issues/23535), [d4f27ce5](http://github.com/katello/katello/commit/d4f27ce5a2d92331d1a2e80d39434c9db76435b1))
 * Add available attribute to upstream subscriptions API ([#23533](http://projects.theforeman.org/issues/23533), [7b34ceab](http://github.com/katello/katello/commit/7b34ceabf4886dd995ec074d0c855e653e2614f3))
 * NumberValidator should come from apipie-rails ([#23460](http://projects.theforeman.org/issues/23460), [cf076c66](http://github.com/katello/katello/commit/cf076c66a1ea2ab029eff11520ac3b1c794e967f))
 * Add param to limit upstream subs index to attachable ones ([#23182](http://projects.theforeman.org/issues/23182), [1390d88f](http://github.com/katello/katello/commit/1390d88f2f4a7619bc15d8023772b3f3c33a61d9))
 * Set http proxy in a thread-safe way ([#23137](http://projects.theforeman.org/issues/23137), [79715ea0](http://github.com/katello/katello/commit/79715ea04d73e7813bf36ec5b411466bdb5301ef))
 * Add API to update upstream_entitlement quantities ([#23111](http://projects.theforeman.org/issues/23111), [e6058817](http://github.com/katello/katello/commit/e6058817a69510c3711e265418c89dd7adb682ce))
 * show total pools count for GET upstream subscriptions ([#23074](http://projects.theforeman.org/issues/23074), [779b8fde](http://github.com/katello/katello/commit/779b8fdeefb1e13d91eea2fde6a20a5366708082))
 * Not able to attach a subscription to a host with hammer ([#22981](http://projects.theforeman.org/issues/22981), [49a3e258](http://github.com/katello/katello/commit/49a3e2584b9e7842f3e17f84d533eb461f5b55f8))
 * Content view filter rule name param is wrongly documented as enum ([#22754](http://projects.theforeman.org/issues/22754))

### Foreman Proxy Content
 * server using :9090 port for smart-proxy pulp calls ([#23181](http://projects.theforeman.org/issues/23181), [ba6efb8e](http://github.com/katello/katello/commit/ba6efb8eff377403584c989b24ea1d24c99553bd))

### Activation Key
 *  activation-key copy fails with "undefined method" and Internal Server Error ([#23084](http://projects.theforeman.org/issues/23084), [bc606efb](http://github.com/katello/katello/commit/bc606efb144c2c60b12c26bc6187e8a13b2e535c), [556b48d8](http://github.com/katello/katello/commit/556b48d812a8c4bd119c1e121e4d795badf55193))

### Candlepin
 * Upgrade to candlepin 2.3 ([#23068](http://projects.theforeman.org/issues/23068), [2d170866](http://github.com/katello/katello/commit/2d170866abd0ebae1cb530f14e0fb5ace772f3dc))

### Performance
 * Katello Event Queue db queries need improvement ([#22978](http://projects.theforeman.org/issues/22978), [1066301f](http://github.com/katello/katello/commit/1066301fbc7ddaaef6defb361edcee6825a7d113))

### GPG Keys
 * Remove GPG key size limit ([#22956](http://projects.theforeman.org/issues/22956), [4781bc4c](http://github.com/katello/katello/commit/4781bc4cbe807a8842f93d97f3699652dcc73edc))

### Settings
 * Configurable 'expiring soon' days ([#22867](http://projects.theforeman.org/issues/22867), [b5dfba94](http://github.com/katello/katello/commit/b5dfba941d0b479be04d5c5e3c8bd6a0ebf6435e))

### Docker
 * As a user, I can search docker manifests by digest. ([#22501](http://projects.theforeman.org/issues/22501), [22a94ce5](http://github.com/katello/katello/commit/22a94ce568b50e3a85bf74b6ff4ea853c382c95a))
 * As a user, I can create an empty docker repository. ([#22302](http://projects.theforeman.org/issues/22302), [3b3f6552](http://github.com/katello/katello/commit/3b3f65528d7df9c12c5b375626c4e54cb5ffb688))
 * As a user, I can upload container images to a repo. ([#22301](http://projects.theforeman.org/issues/22301), [9be8a09d](http://github.com/katello/katello/commit/9be8a09d2d128312c793ae37c6ff14079ecfa894), [e3ffaab2](http://github.com/katello/hammer-cli-katello/commit/e3ffaab26bcb66816c715cf2f84cadf6cd9697e3))

### ElasticSearch
 * Specifying wrong foreign key id for object (such as host or hostgroup) via hammer/api throws SQL error ([#21689](http://projects.theforeman.org/issues/21689), [18eb3558](http://github.com/katello/katello/commit/18eb35587087fc5a67edeb4725ac322a015a3f42))

### Puppet
 * puppet module version not correct in content view ([#16699](http://projects.theforeman.org/issues/16699), [b1b3829f](http://github.com/katello/katello/commit/b1b3829f208a8ccba44503b23db7af49332cc2c6), [9c295089](http://github.com/katello/katello/commit/9c295089f2343101763d11ea8ee9dfa2111f2260))

### Other
 * katello paginates call when fetching upstream subs, leading to possible tomcat error ([#24187](http://projects.theforeman.org/issues/24187), [bf842cc2](http://github.com/katello/katello/commit/bf842cc29b142985e86deb9b02705536ca6d3648))
 * The server appears to cause a yum update when an errata is apply is issued through katello-agent ([#24081](http://projects.theforeman.org/issues/24081), [414f5ede](http://github.com/katello/katello-host-tools/commit/414f5edebbad043180fd4e4a01a950fbdb149557))
 * Katello package install via katello-agent fails ([#24079](http://projects.theforeman.org/issues/24079))
 * React router doesn't catch empty state buttons  ([#23966](http://projects.theforeman.org/issues/23966), [bcb8a5e0](http://github.com/katello/katello/commit/bcb8a5e04fa02c67636180477319082dd1c1ea12))
 * SSL Certs of a Repository are not updated if Product is changes ([#23964](http://projects.theforeman.org/issues/23964), [83ef4029](http://github.com/katello/katello/commit/83ef4029426a73f691c47b4915a8e0c246754238))
 * Incorrect REST API call GET /api/hosts/:host_id/tracer ([#23737](http://projects.theforeman.org/issues/23737), [c3eb1961](http://github.com/katello/katello/commit/c3eb1961ad1598f0d098924fe7901b155d6579b2))
 * CV publish can publish puppet before yum, causing provisioning issues ([#23672](http://projects.theforeman.org/issues/23672), [9ae7dbf5](http://github.com/katello/katello/commit/9ae7dbf506a766d8af23123875d241ce707ea2a6))
 * Unable to promote content views due to 'null' value for timestamps. ([#23662](http://projects.theforeman.org/issues/23662), [31b9d1da](http://github.com/katello/katello/commit/31b9d1da4ef29a15bba73f71b743690dbdcc5256))
 * Remove unused methods from PulpTaskStatus ([#23659](http://projects.theforeman.org/issues/23659), [ecebc6c7](http://github.com/katello/katello/commit/ecebc6c7c344fff6697d0f865323f804d3bf3b2d))
 * Relative comparisons of package versions/releases via scoped_search are incorrect ([#23644](http://projects.theforeman.org/issues/23644), [10a12816](http://github.com/katello/katello/commit/10a12816281b64a968cc9c50a9c5244960f5dcea))
 * Suse errata do not show icons for their type and they are not summed up ([#23566](http://projects.theforeman.org/issues/23566), [583b7870](http://github.com/katello/katello/commit/583b787092889d01286a31fc245c7b3b3e05bc18))
 * Collect file /var/log/qdrouterd/qdrouterd.log ([#23556](http://projects.theforeman.org/issues/23556), [6aef875a](http://github.com/katello/foreman-packaging/commit/6aef875a0f2d9165d7beb156786dd57cdc52510c))
 * hammer-cli-katello should check string formats in tests ([#23484](http://projects.theforeman.org/issues/23484), [6e04d2b8](http://github.com/katello/hammer-cli-katello/commit/6e04d2b836f8b409659354c682b8b7ecafdf23af))
 * Include content view in @repository_url@ helper, if applicable ([#23478](http://projects.theforeman.org/issues/23478), [ccc815fd](http://github.com/katello/katello/commit/ccc815fdae73782592a64732c1d4d07fdb97f697))
 * Upgrades should allow picking up new puppet server versions automatically ([#23470](http://projects.theforeman.org/issues/23470), [43dd5195](http://github.com/katello/katello-installer/commit/43dd519593fbc85680934fbbaefe1566fe8b31e2), [f78722c8](http://github.com/katello/katello-installer/commit/f78722c8fd6525cc882242fc0fbc7480ebaac0b2), [36df1d5a](http://github.com/katello/katello-installer/commit/36df1d5aeec6621328d117e93579c16fba9c9f02), [a5d2df88](http://github.com/katello/katello-installer/commit/a5d2df888dfc1d6f96986e62638cf14f4e78787f))
 * can't attach custom subscriptions to an activation key ([#23421](http://projects.theforeman.org/issues/23421), [128de120](http://github.com/katello/katello/commit/128de1204b5c8ede23ac345d1b3c9b7f73758883))
 * foreman-installer --reset has hardcoded default internal database names ([#23375](http://projects.theforeman.org/issues/23375), [cd6a57e2](http://github.com/katello/katello-installer/commit/cd6a57e268efa0820a1f7b55c06acf3187435538))
 * Remove puppet-service_wait from installer ([#23368](http://projects.theforeman.org/issues/23368), [3c171512](http://github.com/katello/katello-installer/commit/3c171512e72d8dbe3c1431b517df11cc69e94cfb))
 * Katello uses md5hash function incompatible with FIPS-enabled environments ([#23363](http://projects.theforeman.org/issues/23363), [39b472d5](http://github.com/katello/katello/commit/39b472d5b91c75573bd7b07157e21b942ef3c8ae))
 * Accept local pool ids when listing upstream subscriptions ([#23338](http://projects.theforeman.org/issues/23338), [ba154186](http://github.com/katello/katello/commit/ba154186b518dcb4f1d6e81b401836d7cebde5c0))
 * db:seed is failing for Ansible job templates when foreman_ansible is not installed ([#23329](http://projects.theforeman.org/issues/23329), [d1a16e43](http://github.com/katello/katello/commit/d1a16e43f74d89f0cc813f6a231a7b0e3d9dc8ac))
 * available_errata.rabl should be named available_errata.json.rabl ([#23316](http://projects.theforeman.org/issues/23316), [327f7864](http://github.com/katello/katello/commit/327f786466a06e750b209e412fb75520a2b0339a))
 * Can't add activation key to hostgroup via UI ([#23274](http://projects.theforeman.org/issues/23274), [b8e73d0a](http://github.com/katello/katello/commit/b8e73d0a871cddb6683c6a107bf429b290261ab4))
 * Checking if SendExpireSoonNotifications, CreatePulpDiskSpaceNotifications is planned doesn't take into account possible existence of different plans ([#23257](http://projects.theforeman.org/issues/23257), [27d20522](http://github.com/katello/katello/commit/27d205224895b5b56bb402237add9f3366c2969e))
 * Include package.json and webpack in gemspec ([#23217](http://projects.theforeman.org/issues/23217), [2e19c475](http://github.com/katello/katello/commit/2e19c47513122cfa706f2af4002e9b47310de2a2))
 * rake katello:reset errors with `Setting::Auth is marked as readonly` ([#23154](http://projects.theforeman.org/issues/23154), [60aecb8b](http://github.com/katello/katello/commit/60aecb8b761ab47de76d9d4f23c9691b26fd4c2e))
 * UpstreamPool placement is causing autoreloading to not happen in dev environment ([#23122](http://projects.theforeman.org/issues/23122), [7ff9760d](http://github.com/katello/katello/commit/7ff9760d83a22b99f9bcd5a482cc618978916a9e))
 * (MANAGE SUBS) default pagination params should be forwarded to upstream Candlepin ([#23121](http://projects.theforeman.org/issues/23121), [ebf578eb](http://github.com/katello/katello/commit/ebf578eb52f46458cf6cd10a799db962e9551c5b))
 * UI: After add the CV on the CCV, Content View still on the list to add ([#23120](http://projects.theforeman.org/issues/23120), [776fb48d](http://github.com/katello/bastion/commit/776fb48dd363c70b05c2bc4d73c19fb82c8289bb))
 * Remote Execution Fails for Applying errata in Content Hosts Via Remote Execution Method. ([#23082](http://projects.theforeman.org/issues/23082), [3f036a0b](http://github.com/katello/katello/commit/3f036a0b1354b8c54d1361a130e3485f85b8528f))
 * dev server hangs on code change ([#23006](http://projects.theforeman.org/issues/23006), [a9b6c66b](http://github.com/katello/katello/commit/a9b6c66b841048b6780e3f0293e8d33d68b368fb))
 * run upgrade task import_backend_consumer_attributes ([#22970](http://projects.theforeman.org/issues/22970), [3ea2a5d5](http://github.com/katello/katello-installer/commit/3ea2a5d5e03f9e51086b1fff91161599c4898bab))
 * Upstream HttpResource should use current Organizatoin ([#22944](http://projects.theforeman.org/issues/22944), [dfd14f4a](http://github.com/katello/katello/commit/dfd14f4abcd48491cac8ac3331d5b9ede075864c))
 * Bastion_katello string extraction process results in duplicate strings. ([#22919](http://projects.theforeman.org/issues/22919), [a7a652d4](http://github.com/katello/katello/commit/a7a652d46f7e28bf775e4fe9863180f23cfe89e8))
 * extract the strings for hammer_cli_katello ([#22870](http://projects.theforeman.org/issues/22870), [94089a67](http://github.com/katello/hammer-cli-katello/commit/94089a670faf7ae4155f601e78a29e857e82ab63))
 * Extract the latest strings from the dev environment.  ([#22859](http://projects.theforeman.org/issues/22859), [83b439d5](http://github.com/katello/katello/commit/83b439d546613ff8ea01f01a268a18bd621c3813))
 * `subscription-manager unsubscribe --pool` ends up with 'ActionController::RoutingError (No route matches [DELETE] "/rhsm/consumers/2cb5a878-3a70-482c-b22d-a23092ecfc62/entitlements/pool/ff808081620a401901620b8aa3520037") ([#22835](http://projects.theforeman.org/issues/22835), [b59cf1e9](http://github.com/katello/katello/commit/b59cf1e9be2a97744aa7ae21808a1c5a47de7478))
 * Allow setting verify_ssl to false when talking to pulp ([#22826](http://projects.theforeman.org/issues/22826), [d6f2de92](http://github.com/katello/katello/commit/d6f2de926749f8304f75bd150aa3b947f8184810))
 * As a user I would like to skip srpms on sync ([#22803](http://projects.theforeman.org/issues/22803), [9872e5b4](http://github.com/katello/katello/commit/9872e5b48212742715383b50d25b649fd2ed50c3))
 * Create a Skip list for yum importer ([#22802](http://projects.theforeman.org/issues/22802))
 * Repository Sets API should not return docker and containerimage types or custom products ([#22564](http://projects.theforeman.org/issues/22564), [3883410f](http://github.com/katello/katello/commit/3883410f269289ef2d65ad526f778112c811a446))
 * Katello assets need to use Foreman plugin assets configuration ([#22484](http://projects.theforeman.org/issues/22484), [069aa015](http://github.com/katello/katello/commit/069aa01560be152c8f128a05dd26a0a514c98488))
 * [Audit] Refresh manifest ([#22373](http://projects.theforeman.org/issues/22373), [2e99f59b](http://github.com/katello/katello/commit/2e99f59bc158713bf8b195d928ca3a137d51c0bb))
 * Clean up postgres write-access failure in katello-backup ([#22060](http://projects.theforeman.org/issues/22060))
 * backup & restore do not work with remote DB ([#20550](http://projects.theforeman.org/issues/20550), [81fcaa5f](http://github.com/katello/katello-installer/commit/81fcaa5fa6d9f166823538f9999a03afafcc3875))
