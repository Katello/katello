# 4.1.2 (2021-07-26)

## Bug Fixes

### Repositories
 * Katello saves publication as a repo's version_href at sync time if Pulp auto-creates publications ([#33044](https://projects.theforeman.org/issues/33044), [8b9fbc41](https://github.com/Katello/katello.git/commit/8b9fbc41c4c9fac5262983c2b138290835294b5c), [11ad37c1](https://github.com/Katello/katello.git/commit/11ad37c1c1addeb65f66ad709bc79ba65ff0bc1e))
 *  Sync of content from an authenticated yum repository fails ([#32994](https://projects.theforeman.org/issues/32994), [27a2687d](https://github.com/Katello/katello.git/commit/27a2687d7b19f6ec0454e5eb528a658f5de233b0))

### Client/Agent
 * via Katello-agent option is not clickable on content host errata page ([#33036](https://projects.theforeman.org/issues/33036), [cf2fa844](https://github.com/Katello/katello.git/commit/cf2fa844048217182b473bfe1d8d4f2c63b98ca6), [b31dcd83](https://github.com/Katello/katello.git/commit/b31dcd830cb533d286a067bea01959246e2fd460))

### Content Views
 * Capsule syncing is not triggered by CV promotion ([#33014](https://projects.theforeman.org/issues/33014), [2dea3a78](https://github.com/Katello/katello.git/commit/2dea3a78574e0907686ec1364685ccf60ad26eee))
# 4.1.1 (2021-07-13)

## Features

### Repositories
 * Upgrade Pulpcore and plugins to 3.14 for Katello master ([#32933](https://projects.theforeman.org/issues/32933), [1aab1178](https://github.com/Katello/katello.git/commit/1aab117867341ddebf4370c8c174ee54bbfed166))

## Bug Fixes

### Repositories
 * pulp_rpm_client 3.13 throws uninitialized constant PulpRpmClient::OneOfMetadataChecksumTypeEnumNullEnum ([#32974](https://projects.theforeman.org/issues/32974), [01cb7b3f](https://github.com/Katello/katello.git/commit/01cb7b3f613b7099b3ec3246f19d4907858f52df))
 * Creating ansible collection repo fails with: "Invalid URL Ensure the URL ends '/'" but repo gets created ([#32867](https://projects.theforeman.org/issues/32867), [ae8389d2](https://github.com/Katello/katello.git/commit/ae8389d2279a0a61070f06eb69386a65085c4bc0))

### Hosts
 * Error when trying to restart Traces: TypeError in Katello::RemoteExecutionController#create  no implicit conversion of nil into String ([#32936](https://projects.theforeman.org/issues/32936), [a186876a](https://github.com/Katello/katello.git/commit/a186876abe8ba1218834d403e65d4fa4cde59a4e))

### Content Views
 * available_for content_view_version parameter to /katello/api/packages or /katello/api/errata is slow ([#31764](https://projects.theforeman.org/issues/31764), [006ecc75](https://github.com/Katello/katello.git/commit/006ecc75bc264c42b0b3052d1843bb661a6242db))
# 4.1.0 (2021-06-16)

## Features

### Repositories
 * Support global download_concurrency setting and default to 5 ([#32246](https://projects.theforeman.org/issues/32246))
 * support new 'feature' names in pulp3 ([#31968](https://projects.theforeman.org/issues/31968), [fa8a91b5](https://github.com/Katello/katello.git/commit/fa8a91b5fdb8f108f83bd5bb1cd66854249bddcc))
 * Pulp download timeouts should be configurable ([#17423](https://projects.theforeman.org/issues/17423), [0428d1dd](https://github.com/Katello/katello.git/commit/0428d1dd79743a91138289dbc737e75794633011))
 * Katello 3.16 to 3.17 upgrade fails at the db:migrate stage with error "ERROR:  insert or update on table "katello_hostgroup_content_facets" violates foreign key constraint" ([#32498](https://projects.theforeman.org/issues/32498), [1fbe1f1d](https://github.com/Katello/katello.git/commit/1fbe1f1deb44592e9a04c77fdfeffd2643135043))

### Tooling
 * upgrade to pulpcore 3.11 ([#32234](https://projects.theforeman.org/issues/32234), [8b0b8dfe](https://github.com/Katello/katello.git/commit/8b0b8dfe18fde5a2466cf675a624daee73b70c14), [ea9570ae](https://github.com/Katello/katello.git/commit/ea9570ae2e2529b54f20f113abdab86b83371040))
 * Support correlation id with pulp3 ([#29912](https://projects.theforeman.org/issues/29912), [edf943bc](https://github.com/Katello/katello.git/commit/edf943bc9fe1efa8257784f64eee6a304435db66))

### Container
 * Katello should send user to repo permissions mapping to container gateway ([#32233](https://projects.theforeman.org/issues/32233), [628ee7ed](https://github.com/Katello/katello.git/commit/628ee7ed2a40ec1ea33c1d84bd940035ad34bdec))
 * The Container Gateway's CA cert should be configurable ([#31759](https://projects.theforeman.org/issues/31759), [cc605c02](https://github.com/Katello/smart_proxy_container_gateway.git/commit/cc605c02f708534352e389d2686b8c31b5bddc69))

### Hammer
 * Deprecate agent-based Hammer commands ([#32157](https://projects.theforeman.org/issues/32157), [cba821db](https://github.com/Katello/hammer-cli-katello.git/commit/cba821db5b85c2e6d8e7085bcc6e6a5d93b3827b))
 * Drop requires on hammer_cli_bootdisk ([#32102](https://projects.theforeman.org/issues/32102), [a86af5e7](https://github.com/Katello/hammer-cli-katello.git/commit/a86af5e78f2c9b095f7b9b0ee2a30a6802416e14))

### API
 * Deprecate agent-based APIs ([#32156](https://projects.theforeman.org/issues/32156), [ceb43270](https://github.com/Katello/katello.git/commit/ceb432709b885df401dc36f377b170c9d7a227fa))

### Provisioning
 * Remove auto-assign of registration template to OS ([#32093](https://projects.theforeman.org/issues/32093), [b0ca2be0](https://github.com/Katello/katello.git/commit/b0ca2be0e6acec475c80f79ab76b5af0fa80477a))

### Content Views
 * New Content View Page - Add filter RPM detail pages ([#31969](https://projects.theforeman.org/issues/31969), [dec61c64](https://github.com/Katello/katello.git/commit/dec61c64679ceb8009599aad508d6d32a1603774))

### Hosts
 * Host Registration - Activation key field improvements ([#31918](https://projects.theforeman.org/issues/31918), [e574ca6d](https://github.com/Katello/katello.git/commit/e574ca6db26c71ecc9cb501ed3e898f16af5267d))
 * [RFE] - request for IDs in system purpose bulk action dialog ([#31832](https://projects.theforeman.org/issues/31832), [82e8a61a](https://github.com/Katello/katello.git/commit/82e8a61a6e3f492316f2155526fbda0559216ea9))
 * GR template - add --force option for Sub-man to re-register a host ([#31820](https://projects.theforeman.org/issues/31820), [b312e196](https://github.com/Katello/katello.git/commit/b312e196f87b74829c41e7a2925a900b5b87d5c4))
 * Host Registration - ACKs & LCE from host group ([#31817](https://projects.theforeman.org/issues/31817))
 * Host Registration - Life cycle environment ([#31816](https://projects.theforeman.org/issues/31816))
 * Host Registration - Activation key field improvement ([#31809](https://projects.theforeman.org/issues/31809), [5d63c9b7](https://github.com/Katello/katello.git/commit/5d63c9b7069f37cc22ae4ca08af6bdd41a334990), [065566f9](https://github.com/Katello/katello.git/commit/065566f9e81ac4d869d2a39a96d142c85c38ad01), [6280d47a](https://github.com/Katello/katello.git/commit/6280d47ab322e4f4b7188d34d2172289820197ec))
 * Enable goferless builds by default ([#31023](https://projects.theforeman.org/issues/31023), [2ea0047d](https://github.com/Katello/katello.git/commit/2ea0047d88377f02143ed6145edf2d5b322c020b))

### Web UI
 * [sat-e-613] Update UI to hide k-agent dep warnings if it is disabled ([#31910](https://projects.theforeman.org/issues/31910), [830a06a3](https://github.com/Katello/katello.git/commit/830a06a3fefb3bf881d6ac74df39bcec498d9f43), [9002f0e1](https://github.com/Katello/katello.git/commit/9002f0e1f52fa641618f5061d92b7173131e7d98), [c895e21e](https://github.com/Katello/katello.git/commit/c895e21e123a570d18b87fd13d8a5064bf74c557))

### Other
 * As a user, I can podman pull against an authenticated repo on a smart proxy with the Container Gateway ([#32085](https://projects.theforeman.org/issues/32085), [7bc9ac89](https://github.com/Katello/smart_proxy_container_gateway.git/commit/7bc9ac89f7089838bf6330ebc08185bdb9b806bb))
 * Pulpcore integration test CI reports ([#32079](https://projects.theforeman.org/issues/32079), [8d47018c](https://github.com/Katello/katello.git/commit/8d47018c166031fe5878b3cd8b2383ddb27089c8), [53e9d86b](https://github.com/Katello/katello.git/commit/53e9d86ba155a175fb2efeec00e84c20702b6ca4))
 * Extend API params for generating registration command  ([#31712](https://projects.theforeman.org/issues/31712), [67d8fb89](https://github.com/Katello/katello.git/commit/67d8fb895d364ee1a1a83b45d4a51cc3de338d6c))

## Bug Fixes

### Web UI
 * Red Hat repositories page filtering dropdowns do not work in production ([#32711](https://projects.theforeman.org/issues/32711), [e5cffa05](https://github.com/Katello/katello.git/commit/e5cffa0509756f1d85ca8e26eb642be48f2e884b))
 * Update Composite and Component View icons on UI ([#32349](https://projects.theforeman.org/issues/32349), [753046d4](https://github.com/Katello/katello.git/commit/753046d4e6a71b89d5e8beaea67fa0cbb118c858))
 * New Content View Page - CV List page env and version expandable columns ([#32283](https://projects.theforeman.org/issues/32283), [d2af4f53](https://github.com/Katello/katello.git/commit/d2af4f53a56cf4e69ffe25799b3da1df6baa8b33))
 * New Content View Page - Versions tab ([#32281](https://projects.theforeman.org/issues/32281), [35513c5b](https://github.com/Katello/katello.git/commit/35513c5bf7fbe7eb51a193286f9a711988a08f16))
 * New Content View page: Back button doesn't work to return to list ([#32162](https://projects.theforeman.org/issues/32162), [c72adddb](https://github.com/Katello/katello.git/commit/c72adddbd939ad374f3feea67e67e4b47d12d181))
 * Deprecate package groups UI on content host detail page ([#32137](https://projects.theforeman.org/issues/32137), [5005ed5a](https://github.com/Katello/katello.git/commit/5005ed5a458ecde1bac26b7ecc33fdd650a8b954))
 * Need to add deprecation warning on Content Host -> Register Content Host page since we are planning to deprecate katello-ca-consumer and old registration method. ([#31973](https://projects.theforeman.org/issues/31973), [67803e6c](https://github.com/Katello/katello.git/commit/67803e6c36fd94829f426b34cbfc1eefe08c5577))
 * update Angular ([#31929](https://projects.theforeman.org/issues/31929), [3d6c569a](https://github.com/Katello/katello.git/commit/3d6c569a745f5e44991a487bb0bd8ac323119fd4))
 * eslint error in Tasks/helpers.js ([#31862](https://projects.theforeman.org/issues/31862), [1db3d50e](https://github.com/Katello/katello.git/commit/1db3d50e5aa41f1dc1eb6330415cbf96662cb34a))
 * Patternfly 4 - Have tabs that support routing and subpages ([#31716](https://projects.theforeman.org/issues/31716), [3197ac57](https://github.com/Katello/katello.git/commit/3197ac57f2acd231c9b4b3e523124164d0fcfef9))

### Repositories
 * Remove references to Pulp 2 from new/update repository UI ([#32658](https://projects.theforeman.org/issues/32658), [5dbf6f79](https://github.com/Katello/katello.git/commit/5dbf6f791d90ff865fcba71b7b8a93b93d182d58))
 * cannot create a repository with an http proxy set with auth credentials ([#32422](https://projects.theforeman.org/issues/32422), [4fa40353](https://github.com/Katello/katello.git/commit/4fa403534a649b9aa3ce6dc03941690785981f0b))
 * Package matching query does not exist when syncing TimeScaleDB repo after migration ([#32232](https://projects.theforeman.org/issues/32232), [f7bef07a](https://github.com/Katello/katello.git/commit/f7bef07afbde848cd7728a7f144d8f33955bcb76))
 * "podman search returns 'archived/versioned' repos, but ISE is returned when pulling them" ([#32159](https://projects.theforeman.org/issues/32159), [06cdb710](https://github.com/Katello/katello.git/commit/06cdb710bc5b335492ae9ce2de736006b3d375d7))
 * pulp3: Exclude filter in CVV does not work ([#32010](https://projects.theforeman.org/issues/32010), [58b9974a](https://github.com/Katello/katello.git/commit/58b9974a0a7bb384eb3a7843ae6f9e50406982ba))
 * Unsetting repository architecture restriction doesn't reach clients ([#32008](https://projects.theforeman.org/issues/32008), [28bb2bee](https://github.com/Katello/katello.git/commit/28bb2bee1d5fa93532b2bbc1c48dcf6bc5f924ab), [6d70fab5](https://github.com/Katello/katello.git/commit/6d70fab5d062010335e04eee8e9a995b824256f4))
 * Cancel is outside of the table on sync status page during synchronization ([#31921](https://projects.theforeman.org/issues/31921), [2b4b6b5a](https://github.com/Katello/katello.git/commit/2b4b6b5a4c33b45246537829defd13cfeef014e1))
 * change bulk_load_size  within katello -> pulp SETTING to use a Setting ([#31323](https://projects.theforeman.org/issues/31323), [188fcc6e](https://github.com/Katello/katello.git/commit/188fcc6e8f2f8d33909e6a48511837ba226751f4))

### Client/Agent
 * Tracer Upload for debian / ubuntu systems ([#32581](https://projects.theforeman.org/issues/32581), [5fb47513](https://github.com/Katello/katello-host-tools.git/commit/5fb47513f3f294887785d8b208332e8feb7b4844))
 * katello-agent fails to install packages on CentOS 8 stream ([#32450](https://projects.theforeman.org/issues/32450), [028df6bc](https://github.com/Katello/katello-host-tools.git/commit/028df6bc7084f106396df62cdd0c6425a40e01c9))

### Content Views
 *  Duplicate YumMetadata index entries in content view repositories causing unneeded capsule sync ([#32533](https://projects.theforeman.org/issues/32533), [8e5d21a2](https://github.com/Katello/katello.git/commit/8e5d21a269bcc236baf583e54677d05857746a70))
 * New Content View Page - view added CVs for Composite Content View ([#31827](https://projects.theforeman.org/issues/31827), [c711fd66](https://github.com/Katello/katello.git/commit/c711fd669ada3164406d9571e4194e5e84e845d2))
 * New Content View Page - History Tab ([#31804](https://projects.theforeman.org/issues/31804), [9cc57c12](https://github.com/Katello/katello.git/commit/9cc57c12ad70f686e0e5543bd38d3b90ef3558f8))
 * Make single API call to show all content available and added to a content view filter ([#31756](https://projects.theforeman.org/issues/31756), [1f2af485](https://github.com/Katello/katello.git/commit/1f2af48525052b59c6bbaeeced2a3e4cbd34deb2))
 * New Content View Page - UX changes for create and copy modals ([#31655](https://projects.theforeman.org/issues/31655), [53940c06](https://github.com/Katello/katello.git/commit/53940c069e36bad3dad330ec3e198b269813bc9c))
 * New Content View Page - Add/Remove repositories from content view ([#31653](https://projects.theforeman.org/issues/31653), [0675f718](https://github.com/Katello/katello.git/commit/0675f7183c26f50ed53485b6393af8ae32583c39))
 * New Content View page - show package group filters ([#31648](https://projects.theforeman.org/issues/31648), [ba2b39e4](https://github.com/Katello/katello.git/commit/ba2b39e4e6862f0994016d6a6d4f36ce60bb870c))

### Inter Server Sync
 * Auto-import/create RH repos/Products on disconnected Katello ([#32528](https://projects.theforeman.org/issues/32528), [cc804963](https://github.com/Katello/katello.git/commit/cc804963d55aa4e9a2667fa3a1bd2a3057435445))
 * hammer export fails with super large  chunk size (change chunk-size-mb to gb) ([#32421](https://projects.theforeman.org/issues/32421), [8bf6159f](https://github.com/Katello/katello.git/commit/8bf6159f42a5d74da05c74620a3a897d00ad0916), [fcca49db](https://github.com/Katello/hammer-cli-katello.git/commit/fcca49db2afd15e0f4ed21bdd6d949bae3ff7ea4))
 * import/export metadata.json needs to be trimmed ([#32407](https://projects.theforeman.org/issues/32407), [0f3220e6](https://github.com/Katello/katello.git/commit/0f3220e6c7ce4dd4aad3f95720bf3c94a9d38d9f))
 * Auto-import custom repos - Disconnected ([#32333](https://projects.theforeman.org/issues/32333), [893cc6dd](https://github.com/Katello/katello.git/commit/893cc6dd265754e865c1c93a3a6df73cf9a4a736))
 * Auto create cv on import ([#32241](https://projects.theforeman.org/issues/32241), [d4e4b6d9](https://github.com/Katello/hammer-cli-katello.git/commit/d4e4b6d95cf15fd131bca534359e5d05011a4ada), [f34f3d21](https://github.com/Katello/katello.git/commit/f34f3d21876d5fcb93a3cc25c5e9ffb18942ad40), [2b3e263b](https://github.com/Katello/hammer-cli-katello.git/commit/2b3e263b8f416ee9c369a0ffffe2365ce682adf0))
 * Can Import/Export file type ([#32187](https://projects.theforeman.org/issues/32187), [8d32486b](https://github.com/Katello/katello.git/commit/8d32486b7b3b3358d748fd42f88ed4e93947e4db))
 * Need a dry run option to see content is importable ([#31955](https://projects.theforeman.org/issues/31955), [b41dfa2d](https://github.com/Katello/katello.git/commit/b41dfa2de87641028fcbbaa90409de6bfb4cd4ef))

### Roles and Permissions
 * Permissions for import/export ([#32396](https://projects.theforeman.org/issues/32396), [69864057](https://github.com/Katello/katello.git/commit/69864057c2c55641dc1d9234fae323ee3d838eb8))

### Tests
 * SubscriptionsTable failing test ([#32340](https://projects.theforeman.org/issues/32340), [ee7d0cc4](https://github.com/Katello/katello.git/commit/ee7d0cc4c501376cd35923f5a1e6617132d5a2a6))
 * Intermittent module stream clause generator test ([#32231](https://projects.theforeman.org/issues/32231), [5022393e](https://github.com/Katello/katello.git/commit/5022393eda8a15bf68efe3f2813f00deaa51130c))
 * test failure due to template kinds ([#32087](https://projects.theforeman.org/issues/32087), [55adc4f3](https://github.com/Katello/katello.git/commit/55adc4f3b3e33ef3c8cc0b08be41710dfb72a9dd))
 * bulk_host_extensions transient test failure ([#31911](https://projects.theforeman.org/issues/31911), [78239560](https://github.com/Katello/katello.git/commit/782395606474d14254f307a65bd2acc340312584))
 * Module stream copying tests need to be un-skipped after Pulpcore 3.9.1 is released ([#31704](https://projects.theforeman.org/issues/31704), [1e389926](https://github.com/Katello/katello.git/commit/1e38992603284a11def8de517e5b9ed280cb20e7))

### Hammer
 * hammer repository create needs to take a requirements file ([#32339](https://projects.theforeman.org/issues/32339), [25453dfe](https://github.com/Katello/hammer-cli-katello.git/commit/25453dfeb72abdfd1a9296d9b0f64be4b6938ae8))
 * hammer activation-key/content-host product-content not working correctly ([#32259](https://projects.theforeman.org/issues/32259), [49799266](https://github.com/Katello/katello.git/commit/49799266289075aa71bb5832c841373fd7d04f7b))
 * Add hammer bindings for `hammer content-import list` ([#32127](https://projects.theforeman.org/issues/32127), [067d6da6](https://github.com/Katello/katello.git/commit/067d6da6d080d6e1847a215e34c9f62c7961df8e), [228bde38](https://github.com/Katello/hammer-cli-katello.git/commit/228bde38ac5e0d236a1fe278a193a46fae590f2b))
 * Drop hammer_cli_foreman_docker requirement as the project is discontinued ([#32101](https://projects.theforeman.org/issues/32101), [52ec4658](https://github.com/Katello/hammer-cli-katello.git/commit/52ec4658bef06ce691eda34ee3eb0101b8f808aa), [b212a728](https://github.com/Katello/hammer-cli-katello.git/commit/b212a7286945af11cc5ecc6d929fa3895d9b2166))
 * Latest API data fails in hammer activation key tests now needs org id ([#32073](https://projects.theforeman.org/issues/32073), [23489dcb](https://github.com/Katello/hammer-cli-katello.git/commit/23489dcbc366edc81ff55864a4b1b4f8e2f8a0c2))
 * Show katello-agent status in hammer ping ([#31896](https://projects.theforeman.org/issues/31896), [497116af](https://github.com/Katello/hammer-cli-katello.git/commit/497116afe54e2e6bbcc47bf44ae9b4d30d035329), [b07e82cd](https://github.com/Katello/hammer-cli-katello.git/commit/b07e82cd2fdf08c39e87d5386ebe9ea107d237f6))
 * Org info should reflect the Simple Content Access status ([#31858](https://projects.theforeman.org/issues/31858), [492a7a26](https://github.com/Katello/hammer-cli-katello.git/commit/492a7a26385ed0aa82b2a6e79bfc686bc4b37d08))
 * hammer content-export --name option does not work ([#31456](https://projects.theforeman.org/issues/31456), [6a9f329f](https://github.com/Katello/hammer-cli-katello.git/commit/6a9f329fb097154750fae4842bd7ae99a3e5147f))

### Subscriptions
 * Subscriptions and Pools can be associated across organizations ([#32334](https://projects.theforeman.org/issues/32334), [df86940f](https://github.com/Katello/katello.git/commit/df86940f1ab1116b8b3126424ba6064aa69e4853), [a9544596](https://github.com/Katello/katello.git/commit/a9544596d785d0a0b171e1b9ad8cda3f9ca4fa3a), [7c990202](https://github.com/Katello/katello.git/commit/7c990202f99565d579c8e8a385194ee52f40d410))
 * "Current organization has no manifest imported" error when trying to import a manifest ([#32320](https://projects.theforeman.org/issues/32320), [d05262e6](https://github.com/Katello/katello.git/commit/d05262e60203bcb7f8e3577481c6449ee50ed5e2))
 * Auto-attaching subscriptions on a host triggers pool import for all organizations ([#32267](https://projects.theforeman.org/issues/32267), [127733b7](https://github.com/Katello/katello.git/commit/127733b7b90295ac06d787b9e9bfe22bc4ce8da8))
 * Manifest deletion indexes subscriptions for all organizations ([#32261](https://projects.theforeman.org/issues/32261), [af76f405](https://github.com/Katello/katello.git/commit/af76f405d5cbccffcf58ad02bd29fe71904a9613))
 * Custom subscriptions showing entitlements as -1 on Subscriptions page ([#31864](https://projects.theforeman.org/issues/31864), [18a7153e](https://github.com/Katello/katello.git/commit/18a7153e566bbb441f2d74d769f6e60743d2e0fa))
 * Avoid race conditions in CandlepinMessageHandler ([#31812](https://projects.theforeman.org/issues/31812), [84844d81](https://github.com/Katello/katello.git/commit/84844d818ae56821f63134662e24f9a7a2326e16))
 * Syspurpose role is showing empty in the subscription page and rest api even it has a role ([#30708](https://projects.theforeman.org/issues/30708), [bc682301](https://github.com/Katello/katello.git/commit/bc682301b52cac8c42b3979286fff0749f13d1d1))

### Hosts
 * Report Templates Host - Applied Errata report is empty. ([#32312](https://projects.theforeman.org/issues/32312), [cc397e2f](https://github.com/Katello/katello.git/commit/cc397e2f6f2b767ab6ab9dde343efa70ee7555ec), [f53ee79f](https://github.com/Katello/katello.git/commit/f53ee79ffcafaa8d036fecc30ccf1ce383782f64))
 * Hypervisor task failed with NoMethodError: undefined method `split` for nil:NilClass ([#32150](https://projects.theforeman.org/issues/32150), [28976c3d](https://github.com/Katello/katello.git/commit/28976c3db591e2cbdbaf1eb2ef36588d4e57b436))
 * Show Candlepin version in /rhsm/status API ([#31706](https://projects.theforeman.org/issues/31706), [a8be6572](https://github.com/Katello/katello.git/commit/a8be657280469373bafd66bff073e0209e35ffc4))
 * Actions::Katello::Applicability::Hosts::BulkGenerate called many times with only a single host after sync plan runs ([#31411](https://projects.theforeman.org/issues/31411), [9e06c62b](https://github.com/Katello/katello.git/commit/9e06c62b37c568f03466a155f3a801b101e25f21))
 * Update content host registration page ([#31266](https://projects.theforeman.org/issues/31266))
 * The display of the errata status on hosts page is different to the status on the content host page ([#31000](https://projects.theforeman.org/issues/31000))

### API
 * Use public API to update Setting values ([#32285](https://projects.theforeman.org/issues/32285), [4b07d4d9](https://github.com/Katello/katello.git/commit/4b07d4d928e59de9a69924389aa98362095330c4))
 * "Unable to print debug information" log message from Katello::HttpResource.print_debug_info ([#32249](https://projects.theforeman.org/issues/32249), [ee5c736c](https://github.com/Katello/katello.git/commit/ee5c736c56c9287acb6652c8649380a4c0650496))
 * Remove unused import/export end points ([#32000](https://projects.theforeman.org/issues/32000), [89802465](https://github.com/Katello/katello.git/commit/898024650ec1667a87034b0d06c1f81c9daf594c), [61d1a50e](https://github.com/Katello/hammer-cli-katello.git/commit/61d1a50e1d3ae30b7430ab8f3657b33b33285698))
 * Remove deprecated API params ([#31996](https://projects.theforeman.org/issues/31996), [1984006e](https://github.com/Katello/katello.git/commit/1984006ea57a497a7619b5c0c1f61b32b52e86be))

### Organizations and Locations
 * Seed fails with  PG::ForeignKeyViolation: ERROR:  insert or update on table "foreman_tasks_tasks" violates foreign key constraint "fk_rails_a56904dd86" ([#32277](https://projects.theforeman.org/issues/32277), [4670bc21](https://github.com/Katello/katello.git/commit/4670bc21ef8dd4f33d660a3d4c4e08cdeab81265))

### Activation Key
 * Activation Key details always asking for content view ([#32225](https://projects.theforeman.org/issues/32225), [6a17dd0c](https://github.com/Katello/katello.git/commit/6a17dd0c7378eca0aa404f44d018234cad470caf))
 * Activation Key Repository Set page not functioning correctly ([#32067](https://projects.theforeman.org/issues/32067), [a41851ba](https://github.com/Katello/katello.git/commit/a41851ba5600cc8526edbfade6dae9058861393d))
 * Adding subscription to activation-key fails on incorrectly detected duplicates ([#30250](https://projects.theforeman.org/issues/30250), [9bbc8bf4](https://github.com/Katello/katello.git/commit/9bbc8bf4804fba83601976b356e458f22dea6886))

### Tooling
 * katello shouldn't require ruby < 2.7 ([#31958](https://projects.theforeman.org/issues/31958), [154d6cae](https://github.com/Katello/katello.git/commit/154d6cae6ee3c1ae8d7f22965167cb562674dde5))

### Errata Management
 * Errata freeform search needs to look into  title/history/description ([#31939](https://projects.theforeman.org/issues/31939), [d6afc2a2](https://github.com/Katello/katello.git/commit/d6afc2a2598086707d464347e298754e45e02642))
 * errata filter (search) not working in katello 3.18.1 ([#31925](https://projects.theforeman.org/issues/31925))
 * Applying errata from the errata's page always tries to use katello-agent even when remote_execution_by_default set to true ([#31894](https://projects.theforeman.org/issues/31894), [6d32fc73](https://github.com/Katello/katello.git/commit/6d32fc732b4ef436ff979b358577425327b05e9d))
 * applicability should run once for a sync plan instead of after every repo ([#29898](https://projects.theforeman.org/issues/29898), [b033c5fa](https://github.com/Katello/katello.git/commit/b033c5fae831e4233dd0a107841d4064fa0cc8f0))

### Ansible Collections
 * Ansible collection remotes need auth_url, token fields exposed ([#31928](https://projects.theforeman.org/issues/31928), [17636b30](https://github.com/Katello/katello.git/commit/17636b306f28fbbe912178b5359c10419f33bf68))
 * upgrade pulp ansible plugin to 0.5.0 ([#31197](https://projects.theforeman.org/issues/31197), [427b67eb](https://github.com/Katello/katello.git/commit/427b67ebe2822d8f969fe7d5bc64b39af37c2b2a))

### Sync Plans
 * Any product disabled/removed should automatically disassociate from sync plan ([#31920](https://projects.theforeman.org/issues/31920), [78bd7bd0](https://github.com/Katello/katello.git/commit/78bd7bd0d0cd01e961296fac106c509acf9007c6))

### Installer
 * make host dynflow worker count configurable  and assign applicability to a dynflow queue ([#29752](https://projects.theforeman.org/issues/29752))

### Other
 * Changing the HTTP proxy for a repository that doesn't have an upstream URL causes an error (nightly) ([#32578](https://projects.theforeman.org/issues/32578), [fa770a9e](https://github.com/Katello/katello.git/commit/fa770a9ea3a14957e1c50425308e1a3fbf4244d6))
 *  Errata installation via Host Collection Remote Execution Only Sends First Page of Errata Ids ([#32436](https://projects.theforeman.org/issues/32436), [02e2151a](https://github.com/Katello/katello.git/commit/02e2151a90717faf54cb6c3918d6d1dc2f777ae5))
 * [BUG] Non-Admin users cannot generate the command for registration while having "Register hosts" role associated in Satellite 6.9 ([#32425](https://projects.theforeman.org/issues/32425), [35a0d5f7](https://github.com/Katello/katello.git/commit/35a0d5f7136672c0bcd05cddafd5fcd108ea44c1))
 * Package dependency is wrong on Katello UI ([#32358](https://projects.theforeman.org/issues/32358), [36689e96](https://github.com/Katello/katello.git/commit/36689e96f4fb419373e70beb90499a7a8dce8a83))
 * Possible file descriptor leaks ([#32262](https://projects.theforeman.org/issues/32262), [47277c64](https://github.com/Katello/katello.git/commit/47277c64ee2193577501b6a80cec488286882ffe))
 * Modify 'Media Selection' string of Operating System's hostgroup page ([#32237](https://projects.theforeman.org/issues/32237), [cc1a7ecb](https://github.com/Katello/katello.git/commit/cc1a7ecb7377e6492c095fb17810b8860dbbfddf))
 * rubocop: Metrics/MethodLength cop: Count hashes etc. as one line of code ([#32111](https://projects.theforeman.org/issues/32111), [a4063aae](https://github.com/Katello/katello.git/commit/a4063aae501fd3b89e4360e99ba9a23c671ff355))
 * Unable to set HostGroup content source to capsule that isn't synced ([#32100](https://projects.theforeman.org/issues/32100), [80aa661a](https://github.com/Katello/katello.git/commit/80aa661a1ef44a991736a42b3635e5562b3fc28a))
 * Add auditing for pulp3 import/export ([#32039](https://projects.theforeman.org/issues/32039), [ac5d863a](https://github.com/Katello/katello.git/commit/ac5d863a935fda2d9522e4b0832e8747aa4c39af))
 * "Failed to discover docker repositories because  'Content Default HTTP Proxy' is not used to connect to the registry." ([#32036](https://projects.theforeman.org/issues/32036), [fdff81f5](https://github.com/Katello/katello.git/commit/fdff81f5bbcd2548a2dd2cde888ac1126ab2ba4a))
# 4.1.0 (2021-05-18)

## Features

### Repositories
 * Support global download_concurrency setting and default to 5 ([#32246](https://projects.theforeman.org/issues/32246))
 * support new 'feature' names in pulp3 ([#31968](https://projects.theforeman.org/issues/31968), [fa8a91b5](https://github.com/Katello/katello.git/commit/fa8a91b5fdb8f108f83bd5bb1cd66854249bddcc))
 * Pulp download timeouts should be configurable ([#17423](https://projects.theforeman.org/issues/17423), [0428d1dd](https://github.com/Katello/katello.git/commit/0428d1dd79743a91138289dbc737e75794633011))

### Tooling
 * upgrade to pulpcore 3.11 ([#32234](https://projects.theforeman.org/issues/32234), [8b0b8dfe](https://github.com/Katello/katello.git/commit/8b0b8dfe18fde5a2466cf675a624daee73b70c14), [ea9570ae](https://github.com/Katello/katello.git/commit/ea9570ae2e2529b54f20f113abdab86b83371040))
 * Support correlation id with pulp3 ([#29912](https://projects.theforeman.org/issues/29912), [edf943bc](https://github.com/Katello/katello.git/commit/edf943bc9fe1efa8257784f64eee6a304435db66))

### Container
 * Katello should send user to repo permissions mapping to container gateway ([#32233](https://projects.theforeman.org/issues/32233), [628ee7ed](https://github.com/Katello/katello.git/commit/628ee7ed2a40ec1ea33c1d84bd940035ad34bdec))
 * The Container Gateway's CA cert should be configurable ([#31759](https://projects.theforeman.org/issues/31759), [cc605c02](https://github.com/Katello/smart_proxy_container_gateway.git/commit/cc605c02f708534352e389d2686b8c31b5bddc69))

### API
 * Deprecate agent-based APIs ([#32156](https://projects.theforeman.org/issues/32156), [ceb43270](https://github.com/Katello/katello.git/commit/ceb432709b885df401dc36f377b170c9d7a227fa))

### Hammer
 * Drop requires on hammer_cli_bootdisk ([#32102](https://projects.theforeman.org/issues/32102), [a86af5e7](https://github.com/Katello/hammer-cli-katello.git/commit/a86af5e78f2c9b095f7b9b0ee2a30a6802416e14))

### Provisioning
 * Remove auto-assign of registration template to OS ([#32093](https://projects.theforeman.org/issues/32093), [b0ca2be0](https://github.com/Katello/katello.git/commit/b0ca2be0e6acec475c80f79ab76b5af0fa80477a))

### Content Views
 * New Content View Page - Add filter RPM detail pages ([#31969](https://projects.theforeman.org/issues/31969), [dec61c64](https://github.com/Katello/katello.git/commit/dec61c64679ceb8009599aad508d6d32a1603774))

### Hosts
 * Host Registration - Activation key field improvements ([#31918](https://projects.theforeman.org/issues/31918), [e574ca6d](https://github.com/Katello/katello.git/commit/e574ca6db26c71ecc9cb501ed3e898f16af5267d))
 * [RFE] - request for IDs in system purpose bulk action dialog ([#31832](https://projects.theforeman.org/issues/31832), [82e8a61a](https://github.com/Katello/katello.git/commit/82e8a61a6e3f492316f2155526fbda0559216ea9))
 * GR template - add --force option for Sub-man to re-register a host ([#31820](https://projects.theforeman.org/issues/31820), [b312e196](https://github.com/Katello/katello.git/commit/b312e196f87b74829c41e7a2925a900b5b87d5c4))
 * Host Registration - Activation key field improvement ([#31809](https://projects.theforeman.org/issues/31809), [5d63c9b7](https://github.com/Katello/katello.git/commit/5d63c9b7069f37cc22ae4ca08af6bdd41a334990), [065566f9](https://github.com/Katello/katello.git/commit/065566f9e81ac4d869d2a39a96d142c85c38ad01), [6280d47a](https://github.com/Katello/katello.git/commit/6280d47ab322e4f4b7188d34d2172289820197ec))
 * Enable goferless builds by default ([#31023](https://projects.theforeman.org/issues/31023), [2ea0047d](https://github.com/Katello/katello.git/commit/2ea0047d88377f02143ed6145edf2d5b322c020b))

### Web UI
 * [sat-e-613] Update UI to hide k-agent dep warnings if it is disabled ([#31910](https://projects.theforeman.org/issues/31910), [830a06a3](https://github.com/Katello/katello.git/commit/830a06a3fefb3bf881d6ac74df39bcec498d9f43), [9002f0e1](https://github.com/Katello/katello.git/commit/9002f0e1f52fa641618f5061d92b7173131e7d98), [c895e21e](https://github.com/Katello/katello.git/commit/c895e21e123a570d18b87fd13d8a5064bf74c557))

### Other
 * As a user, I can podman pull against an authenticated repo on a smart proxy with the Container Gateway ([#32085](https://projects.theforeman.org/issues/32085), [7bc9ac89](https://github.com/Katello/smart_proxy_container_gateway.git/commit/7bc9ac89f7089838bf6330ebc08185bdb9b806bb))
 * Pulpcore integration test CI reports ([#32079](https://projects.theforeman.org/issues/32079), [8d47018c](https://github.com/Katello/katello.git/commit/8d47018c166031fe5878b3cd8b2383ddb27089c8), [53e9d86b](https://github.com/Katello/katello.git/commit/53e9d86ba155a175fb2efeec00e84c20702b6ca4))
 * Extend API params for generating registration command  ([#31712](https://projects.theforeman.org/issues/31712), [67d8fb89](https://github.com/Katello/katello.git/commit/67d8fb895d364ee1a1a83b45d4a51cc3de338d6c))

## Bug Fixes

### Client/Agent
 * katello-agent fails to install packages on CentOS 8 stream ([#32450](https://projects.theforeman.org/issues/32450), [028df6bc](https://github.com/Katello/katello-host-tools.git/commit/028df6bc7084f106396df62cdd0c6425a40e01c9))

### Repositories
 * cannot create a repository with an http proxy set with auth credentials ([#32422](https://projects.theforeman.org/issues/32422), [4fa40353](https://github.com/Katello/katello.git/commit/4fa403534a649b9aa3ce6dc03941690785981f0b))
 * Package matching query does not exist when syncing TimeScaleDB repo after migration ([#32232](https://projects.theforeman.org/issues/32232), [f7bef07a](https://github.com/Katello/katello.git/commit/f7bef07afbde848cd7728a7f144d8f33955bcb76))
 * "podman search returns 'archived/versioned' repos, but ISE is returned when pulling them" ([#32159](https://projects.theforeman.org/issues/32159), [06cdb710](https://github.com/Katello/katello.git/commit/06cdb710bc5b335492ae9ce2de736006b3d375d7))
 * pulp3: Exclude filter in CVV does not work ([#32010](https://projects.theforeman.org/issues/32010), [58b9974a](https://github.com/Katello/katello.git/commit/58b9974a0a7bb384eb3a7843ae6f9e50406982ba))
 * Unsetting repository architecture restriction doesn't reach clients ([#32008](https://projects.theforeman.org/issues/32008), [28bb2bee](https://github.com/Katello/katello.git/commit/28bb2bee1d5fa93532b2bbc1c48dcf6bc5f924ab), [6d70fab5](https://github.com/Katello/katello.git/commit/6d70fab5d062010335e04eee8e9a995b824256f4))
 * Cancel is outside of the table on sync status page during synchronization ([#31921](https://projects.theforeman.org/issues/31921), [2b4b6b5a](https://github.com/Katello/katello.git/commit/2b4b6b5a4c33b45246537829defd13cfeef014e1))
 * change bulk_load_size  within katello -> pulp SETTING to use a Setting ([#31323](https://projects.theforeman.org/issues/31323), [188fcc6e](https://github.com/Katello/katello.git/commit/188fcc6e8f2f8d33909e6a48511837ba226751f4))

### Inter Server Sync
 * hammer export fails with super large  chunk size (change chunk-size-mb to gb) ([#32421](https://projects.theforeman.org/issues/32421), [8bf6159f](https://github.com/Katello/katello.git/commit/8bf6159f42a5d74da05c74620a3a897d00ad0916), [fcca49db](https://github.com/Katello/hammer-cli-katello.git/commit/fcca49db2afd15e0f4ed21bdd6d949bae3ff7ea4))
 * import/export metadata.json needs to be trimmed ([#32407](https://projects.theforeman.org/issues/32407), [0f3220e6](https://github.com/Katello/katello.git/commit/0f3220e6c7ce4dd4aad3f95720bf3c94a9d38d9f))
 * Auto-import custom repos - Disconnected ([#32333](https://projects.theforeman.org/issues/32333), [893cc6dd](https://github.com/Katello/katello.git/commit/893cc6dd265754e865c1c93a3a6df73cf9a4a736))
 * Auto create cv on import ([#32241](https://projects.theforeman.org/issues/32241), [d4e4b6d9](https://github.com/Katello/hammer-cli-katello.git/commit/d4e4b6d95cf15fd131bca534359e5d05011a4ada), [f34f3d21](https://github.com/Katello/katello.git/commit/f34f3d21876d5fcb93a3cc25c5e9ffb18942ad40), [2b3e263b](https://github.com/Katello/hammer-cli-katello.git/commit/2b3e263b8f416ee9c369a0ffffe2365ce682adf0))
 * Can Import/Export file type ([#32187](https://projects.theforeman.org/issues/32187), [8d32486b](https://github.com/Katello/katello.git/commit/8d32486b7b3b3358d748fd42f88ed4e93947e4db))
 * Need a dry run option to see content is importable ([#31955](https://projects.theforeman.org/issues/31955), [b41dfa2d](https://github.com/Katello/katello.git/commit/b41dfa2de87641028fcbbaa90409de6bfb4cd4ef))

### Web UI
 * Update Composite and Component View icons on UI ([#32349](https://projects.theforeman.org/issues/32349), [753046d4](https://github.com/Katello/katello.git/commit/753046d4e6a71b89d5e8beaea67fa0cbb118c858))
 * New Content View Page - CV List page env and version expandable columns ([#32283](https://projects.theforeman.org/issues/32283), [d2af4f53](https://github.com/Katello/katello.git/commit/d2af4f53a56cf4e69ffe25799b3da1df6baa8b33))
 * New Content View Page - Versions tab ([#32281](https://projects.theforeman.org/issues/32281), [35513c5b](https://github.com/Katello/katello.git/commit/35513c5bf7fbe7eb51a193286f9a711988a08f16))
 * New Content View page: Back button doesn't work to return to list ([#32162](https://projects.theforeman.org/issues/32162), [c72adddb](https://github.com/Katello/katello.git/commit/c72adddbd939ad374f3feea67e67e4b47d12d181))
 * Need to add deprecation warning on Content Host -> Register Content Host page since we are planning to deprecate katello-ca-consumer and old registration method. ([#31973](https://projects.theforeman.org/issues/31973), [67803e6c](https://github.com/Katello/katello.git/commit/67803e6c36fd94829f426b34cbfc1eefe08c5577))
 * update Angular ([#31929](https://projects.theforeman.org/issues/31929), [3d6c569a](https://github.com/Katello/katello.git/commit/3d6c569a745f5e44991a487bb0bd8ac323119fd4))
 * eslint error in Tasks/helpers.js ([#31862](https://projects.theforeman.org/issues/31862), [1db3d50e](https://github.com/Katello/katello.git/commit/1db3d50e5aa41f1dc1eb6330415cbf96662cb34a))
 * Patternfly 4 - Have tabs that support routing and subpages ([#31716](https://projects.theforeman.org/issues/31716), [3197ac57](https://github.com/Katello/katello.git/commit/3197ac57f2acd231c9b4b3e523124164d0fcfef9))

### Tests
 * SubscriptionsTable failing test ([#32340](https://projects.theforeman.org/issues/32340), [ee7d0cc4](https://github.com/Katello/katello.git/commit/ee7d0cc4c501376cd35923f5a1e6617132d5a2a6))
 * Intermittent module stream clause generator test ([#32231](https://projects.theforeman.org/issues/32231), [5022393e](https://github.com/Katello/katello.git/commit/5022393eda8a15bf68efe3f2813f00deaa51130c))
 * test failure due to template kinds ([#32087](https://projects.theforeman.org/issues/32087), [55adc4f3](https://github.com/Katello/katello.git/commit/55adc4f3b3e33ef3c8cc0b08be41710dfb72a9dd))
 * bulk_host_extensions transient test failure ([#31911](https://projects.theforeman.org/issues/31911), [78239560](https://github.com/Katello/katello.git/commit/782395606474d14254f307a65bd2acc340312584))
 * Module stream copying tests need to be un-skipped after Pulpcore 3.9.1 is released ([#31704](https://projects.theforeman.org/issues/31704), [1e389926](https://github.com/Katello/katello.git/commit/1e38992603284a11def8de517e5b9ed280cb20e7))

### Hammer
 * hammer repository create needs to take a requirements file ([#32339](https://projects.theforeman.org/issues/32339), [25453dfe](https://github.com/Katello/hammer-cli-katello.git/commit/25453dfeb72abdfd1a9296d9b0f64be4b6938ae8))
 * hammer activation-key/content-host product-content not working correctly ([#32259](https://projects.theforeman.org/issues/32259), [49799266](https://github.com/Katello/katello.git/commit/49799266289075aa71bb5832c841373fd7d04f7b))
 * Add hammer bindings for `hammer content-import list` ([#32127](https://projects.theforeman.org/issues/32127), [067d6da6](https://github.com/Katello/katello.git/commit/067d6da6d080d6e1847a215e34c9f62c7961df8e), [228bde38](https://github.com/Katello/hammer-cli-katello.git/commit/228bde38ac5e0d236a1fe278a193a46fae590f2b))
 * Drop hammer_cli_foreman_docker requirement as the project is discontinued ([#32101](https://projects.theforeman.org/issues/32101), [52ec4658](https://github.com/Katello/hammer-cli-katello.git/commit/52ec4658bef06ce691eda34ee3eb0101b8f808aa), [b212a728](https://github.com/Katello/hammer-cli-katello.git/commit/b212a7286945af11cc5ecc6d929fa3895d9b2166))
 * Latest API data fails in hammer activation key tests now needs org id ([#32073](https://projects.theforeman.org/issues/32073), [23489dcb](https://github.com/Katello/hammer-cli-katello.git/commit/23489dcbc366edc81ff55864a4b1b4f8e2f8a0c2))
 * Show katello-agent status in hammer ping ([#31896](https://projects.theforeman.org/issues/31896), [497116af](https://github.com/Katello/hammer-cli-katello.git/commit/497116afe54e2e6bbcc47bf44ae9b4d30d035329), [b07e82cd](https://github.com/Katello/hammer-cli-katello.git/commit/b07e82cd2fdf08c39e87d5386ebe9ea107d237f6))
 * Org info should reflect the Simple Content Access status ([#31858](https://projects.theforeman.org/issues/31858), [492a7a26](https://github.com/Katello/hammer-cli-katello.git/commit/492a7a26385ed0aa82b2a6e79bfc686bc4b37d08))
 * hammer content-export --name option does not work ([#31456](https://projects.theforeman.org/issues/31456), [6a9f329f](https://github.com/Katello/hammer-cli-katello.git/commit/6a9f329fb097154750fae4842bd7ae99a3e5147f))

### Subscriptions
 * Subscriptions and Pools can be associated across organizations ([#32334](https://projects.theforeman.org/issues/32334), [df86940f](https://github.com/Katello/katello.git/commit/df86940f1ab1116b8b3126424ba6064aa69e4853), [a9544596](https://github.com/Katello/katello.git/commit/a9544596d785d0a0b171e1b9ad8cda3f9ca4fa3a), [7c990202](https://github.com/Katello/katello.git/commit/7c990202f99565d579c8e8a385194ee52f40d410))
 * Auto-attaching subscriptions on a host triggers pool import for all organizations ([#32267](https://projects.theforeman.org/issues/32267), [127733b7](https://github.com/Katello/katello.git/commit/127733b7b90295ac06d787b9e9bfe22bc4ce8da8))
 * Manifest deletion indexes subscriptions for all organizations ([#32261](https://projects.theforeman.org/issues/32261), [af76f405](https://github.com/Katello/katello.git/commit/af76f405d5cbccffcf58ad02bd29fe71904a9613))
 * Custom subscriptions showing entitlements as -1 on Subscriptions page ([#31864](https://projects.theforeman.org/issues/31864), [18a7153e](https://github.com/Katello/katello.git/commit/18a7153e566bbb441f2d74d769f6e60743d2e0fa))
 * Avoid race conditions in CandlepinMessageHandler ([#31812](https://projects.theforeman.org/issues/31812), [84844d81](https://github.com/Katello/katello.git/commit/84844d818ae56821f63134662e24f9a7a2326e16))
 * Syspurpose role is showing empty in the subscription page and rest api even it has a role ([#30708](https://projects.theforeman.org/issues/30708), [bc682301](https://github.com/Katello/katello.git/commit/bc682301b52cac8c42b3979286fff0749f13d1d1))

### Hosts
 * Report Templates Host - Applied Errata report is empty. ([#32312](https://projects.theforeman.org/issues/32312), [cc397e2f](https://github.com/Katello/katello.git/commit/cc397e2f6f2b767ab6ab9dde343efa70ee7555ec), [f53ee79f](https://github.com/Katello/katello.git/commit/f53ee79ffcafaa8d036fecc30ccf1ce383782f64))
 * Hypervisor task failed with NoMethodError: undefined method `split` for nil:NilClass ([#32150](https://projects.theforeman.org/issues/32150), [28976c3d](https://github.com/Katello/katello.git/commit/28976c3db591e2cbdbaf1eb2ef36588d4e57b436))
 * Show Candlepin version in /rhsm/status API ([#31706](https://projects.theforeman.org/issues/31706), [a8be6572](https://github.com/Katello/katello.git/commit/a8be657280469373bafd66bff073e0209e35ffc4))
 * Actions::Katello::Applicability::Hosts::BulkGenerate called many times with only a single host after sync plan runs ([#31411](https://projects.theforeman.org/issues/31411))
 * Update content host registration page ([#31266](https://projects.theforeman.org/issues/31266))
 * The display of the errata status on hosts page is different to the status on the content host page ([#31000](https://projects.theforeman.org/issues/31000))

### API
 * Use public API to update Setting values ([#32285](https://projects.theforeman.org/issues/32285), [4b07d4d9](https://github.com/Katello/katello.git/commit/4b07d4d928e59de9a69924389aa98362095330c4))
 * "Unable to print debug information" log message from Katello::HttpResource.print_debug_info ([#32249](https://projects.theforeman.org/issues/32249), [ee5c736c](https://github.com/Katello/katello.git/commit/ee5c736c56c9287acb6652c8649380a4c0650496))
 * Remove unused import/export end points ([#32000](https://projects.theforeman.org/issues/32000), [89802465](https://github.com/Katello/katello.git/commit/898024650ec1667a87034b0d06c1f81c9daf594c), [61d1a50e](https://github.com/Katello/hammer-cli-katello.git/commit/61d1a50e1d3ae30b7430ab8f3657b33b33285698))

### Organizations and Locations
 * Seed fails with  PG::ForeignKeyViolation: ERROR:  insert or update on table "foreman_tasks_tasks" violates foreign key constraint "fk_rails_a56904dd86" ([#32277](https://projects.theforeman.org/issues/32277), [4670bc21](https://github.com/Katello/katello.git/commit/4670bc21ef8dd4f33d660a3d4c4e08cdeab81265))

### Activation Key
 * Activation Key details always asking for content view ([#32225](https://projects.theforeman.org/issues/32225), [6a17dd0c](https://github.com/Katello/katello.git/commit/6a17dd0c7378eca0aa404f44d018234cad470caf))
 * Activation Key Repository Set page not functioning correctly ([#32067](https://projects.theforeman.org/issues/32067), [a41851ba](https://github.com/Katello/katello.git/commit/a41851ba5600cc8526edbfade6dae9058861393d))
 * Adding subscription to activation-key fails on incorrectly detected duplicates ([#30250](https://projects.theforeman.org/issues/30250), [9bbc8bf4](https://github.com/Katello/katello.git/commit/9bbc8bf4804fba83601976b356e458f22dea6886))

### Tooling
 * katello shouldn't require ruby < 2.7 ([#31958](https://projects.theforeman.org/issues/31958), [154d6cae](https://github.com/Katello/katello.git/commit/154d6cae6ee3c1ae8d7f22965167cb562674dde5))

### Errata Management
 * Errata freeform search needs to look into  title/history/description ([#31939](https://projects.theforeman.org/issues/31939), [d6afc2a2](https://github.com/Katello/katello.git/commit/d6afc2a2598086707d464347e298754e45e02642))
 * errata filter (search) not working in katello 3.18.1 ([#31925](https://projects.theforeman.org/issues/31925))
 * Applying errata from the errata's page always tries to use katello-agent even when remote_execution_by_default set to true ([#31894](https://projects.theforeman.org/issues/31894), [6d32fc73](https://github.com/Katello/katello.git/commit/6d32fc732b4ef436ff979b358577425327b05e9d))
 * applicability should run once for a sync plan instead of after every repo ([#29898](https://projects.theforeman.org/issues/29898))

### Ansible Collections
 * Ansible collection remotes need auth_url, token fields exposed ([#31928](https://projects.theforeman.org/issues/31928), [17636b30](https://github.com/Katello/katello.git/commit/17636b306f28fbbe912178b5359c10419f33bf68))

### Sync Plans
 * Any product disabled/removed should automatically disassociate from sync plan ([#31920](https://projects.theforeman.org/issues/31920), [78bd7bd0](https://github.com/Katello/katello.git/commit/78bd7bd0d0cd01e961296fac106c509acf9007c6))

### Content Views
 * New Content View Page - view added CVs for Composite Content View ([#31827](https://projects.theforeman.org/issues/31827), [c711fd66](https://github.com/Katello/katello.git/commit/c711fd669ada3164406d9571e4194e5e84e845d2))
 * New Content View Page - History Tab ([#31804](https://projects.theforeman.org/issues/31804), [9cc57c12](https://github.com/Katello/katello.git/commit/9cc57c12ad70f686e0e5543bd38d3b90ef3558f8))
 * Make single API call to show all content available and added to a content view filter ([#31756](https://projects.theforeman.org/issues/31756), [1f2af485](https://github.com/Katello/katello.git/commit/1f2af48525052b59c6bbaeeced2a3e4cbd34deb2))
 * New Content View Page - UX changes for create and copy modals ([#31655](https://projects.theforeman.org/issues/31655), [53940c06](https://github.com/Katello/katello.git/commit/53940c069e36bad3dad330ec3e198b269813bc9c))
 * New Content View Page - Add/Remove repositories from content view ([#31653](https://projects.theforeman.org/issues/31653), [0675f718](https://github.com/Katello/katello.git/commit/0675f7183c26f50ed53485b6393af8ae32583c39))
 * New Content View page - show package group filters ([#31648](https://projects.theforeman.org/issues/31648), [ba2b39e4](https://github.com/Katello/katello.git/commit/ba2b39e4e6862f0994016d6a6d4f36ce60bb870c))

### Installer
 * make host dynflow worker count configurable  and assign applicability to a dynflow queue ([#29752](https://projects.theforeman.org/issues/29752))

### Other
 * Changing the HTTP proxy for a repository that doesn't have an upstream URL causes an error (nightly) ([#32578](https://projects.theforeman.org/issues/32578))
 * [BUG] Non-Admin users cannot generate the command for registration while having "Register hosts" role associated in Satellite 6.9 ([#32425](https://projects.theforeman.org/issues/32425), [35a0d5f7](https://github.com/Katello/katello.git/commit/35a0d5f7136672c0bcd05cddafd5fcd108ea44c1))
 * Package dependency is wrong on Katello UI ([#32358](https://projects.theforeman.org/issues/32358), [36689e96](https://github.com/Katello/katello.git/commit/36689e96f4fb419373e70beb90499a7a8dce8a83))
 * Possible file descriptor leaks ([#32262](https://projects.theforeman.org/issues/32262), [47277c64](https://github.com/Katello/katello.git/commit/47277c64ee2193577501b6a80cec488286882ffe))
 * Modify 'Media Selection' string of Operating System's hostgroup page ([#32237](https://projects.theforeman.org/issues/32237), [cc1a7ecb](https://github.com/Katello/katello.git/commit/cc1a7ecb7377e6492c095fb17810b8860dbbfddf))
 * rubocop: Metrics/MethodLength cop: Count hashes etc. as one line of code ([#32111](https://projects.theforeman.org/issues/32111), [a4063aae](https://github.com/Katello/katello.git/commit/a4063aae501fd3b89e4360e99ba9a23c671ff355))
 * Unable to set HostGroup content source to capsule that isn't synced ([#32100](https://projects.theforeman.org/issues/32100), [80aa661a](https://github.com/Katello/katello.git/commit/80aa661a1ef44a991736a42b3635e5562b3fc28a))
 * Add auditing for pulp3 import/export ([#32039](https://projects.theforeman.org/issues/32039), [ac5d863a](https://github.com/Katello/katello.git/commit/ac5d863a935fda2d9522e4b0832e8747aa4c39af))
 * "Failed to discover docker repositories because  'Content Default HTTP Proxy' is not used to connect to the registry." ([#32036](https://projects.theforeman.org/issues/32036), [fdff81f5](https://github.com/Katello/katello.git/commit/fdff81f5bbcd2548a2dd2cde888ac1126ab2ba4a))
# 4.1.0 (2021-05-10)

## Features

### Tooling
 * upgrade to pulpcore 3.11 ([#32234](https://projects.theforeman.org/issues/32234), [8b0b8dfe](https://github.com/Katello/katello.git/commit/8b0b8dfe18fde5a2466cf675a624daee73b70c14), [ea9570ae](https://github.com/Katello/katello.git/commit/ea9570ae2e2529b54f20f113abdab86b83371040))
 * Support correlation id with pulp3 ([#29912](https://projects.theforeman.org/issues/29912), [edf943bc](https://github.com/Katello/katello.git/commit/edf943bc9fe1efa8257784f64eee6a304435db66))

### Container
 * Katello should send user to repo permissions mapping to container gateway ([#32233](https://projects.theforeman.org/issues/32233), [628ee7ed](https://github.com/Katello/katello.git/commit/628ee7ed2a40ec1ea33c1d84bd940035ad34bdec))
 * The Container Gateway's CA cert should be configurable ([#31759](https://projects.theforeman.org/issues/31759))

### API
 * Deprecate agent-based APIs ([#32156](https://projects.theforeman.org/issues/32156), [ceb43270](https://github.com/Katello/katello.git/commit/ceb432709b885df401dc36f377b170c9d7a227fa))

### Hammer
 * Drop requires on hammer_cli_bootdisk ([#32102](https://projects.theforeman.org/issues/32102), [a86af5e7](https://github.com/Katello/hammer-cli-katello.git/commit/a86af5e78f2c9b095f7b9b0ee2a30a6802416e14))

### Provisioning
 * Remove auto-assign of registration template to OS ([#32093](https://projects.theforeman.org/issues/32093), [b0ca2be0](https://github.com/Katello/katello.git/commit/b0ca2be0e6acec475c80f79ab76b5af0fa80477a))

### Content Views
 * New Content View Page - Add filter RPM detail pages ([#31969](https://projects.theforeman.org/issues/31969), [dec61c64](https://github.com/Katello/katello.git/commit/dec61c64679ceb8009599aad508d6d32a1603774))

### Repositories
 * support new 'feature' names in pulp3 ([#31968](https://projects.theforeman.org/issues/31968), [fa8a91b5](https://github.com/Katello/katello.git/commit/fa8a91b5fdb8f108f83bd5bb1cd66854249bddcc))
 * Pulp download timeouts should be configurable ([#17423](https://projects.theforeman.org/issues/17423), [0428d1dd](https://github.com/Katello/katello.git/commit/0428d1dd79743a91138289dbc737e75794633011))

### Hosts
 * Host Registration - Activation key field improvements ([#31918](https://projects.theforeman.org/issues/31918), [e574ca6d](https://github.com/Katello/katello.git/commit/e574ca6db26c71ecc9cb501ed3e898f16af5267d))
 * [RFE] - request for IDs in system purpose bulk action dialog ([#31832](https://projects.theforeman.org/issues/31832), [82e8a61a](https://github.com/Katello/katello.git/commit/82e8a61a6e3f492316f2155526fbda0559216ea9))
 * GR template - add --force option for Sub-man to re-register a host ([#31820](https://projects.theforeman.org/issues/31820), [b312e196](https://github.com/Katello/katello.git/commit/b312e196f87b74829c41e7a2925a900b5b87d5c4))
 * Host Registration - Activation key field improvement ([#31809](https://projects.theforeman.org/issues/31809), [5d63c9b7](https://github.com/Katello/katello.git/commit/5d63c9b7069f37cc22ae4ca08af6bdd41a334990), [065566f9](https://github.com/Katello/katello.git/commit/065566f9e81ac4d869d2a39a96d142c85c38ad01))
 * Enable goferless builds by default ([#31023](https://projects.theforeman.org/issues/31023), [2ea0047d](https://github.com/Katello/katello.git/commit/2ea0047d88377f02143ed6145edf2d5b322c020b))

### Web UI
 * [sat-e-613] Update UI to hide k-agent dep warnings if it is disabled ([#31910](https://projects.theforeman.org/issues/31910), [830a06a3](https://github.com/Katello/katello.git/commit/830a06a3fefb3bf881d6ac74df39bcec498d9f43), [9002f0e1](https://github.com/Katello/katello.git/commit/9002f0e1f52fa641618f5061d92b7173131e7d98), [c895e21e](https://github.com/Katello/katello.git/commit/c895e21e123a570d18b87fd13d8a5064bf74c557))

### Other
 * As a user, I can podman pull against an authenticated repo on a smart proxy with the Container Gateway ([#32085](https://projects.theforeman.org/issues/32085))
 * Pulpcore integration test CI reports ([#32079](https://projects.theforeman.org/issues/32079), [8d47018c](https://github.com/Katello/katello.git/commit/8d47018c166031fe5878b3cd8b2383ddb27089c8), [53e9d86b](https://github.com/Katello/katello.git/commit/53e9d86ba155a175fb2efeec00e84c20702b6ca4))
 * Extend API params for generating registration command  ([#31712](https://projects.theforeman.org/issues/31712), [67d8fb89](https://github.com/Katello/katello.git/commit/67d8fb895d364ee1a1a83b45d4a51cc3de338d6c))

## Bug Fixes

### Client/Agent
 * katello-agent fails to install packages on CentOS 8 stream ([#32450](https://projects.theforeman.org/issues/32450), [028df6bc](https://github.com/Katello/katello-host-tools.git/commit/028df6bc7084f106396df62cdd0c6425a40e01c9))

### Inter Server Sync
 * hammer export fails with super large  chunk size (change chunk-size-mb to gb) ([#32421](https://projects.theforeman.org/issues/32421), [8bf6159f](https://github.com/Katello/katello.git/commit/8bf6159f42a5d74da05c74620a3a897d00ad0916), [fcca49db](https://github.com/Katello/hammer-cli-katello.git/commit/fcca49db2afd15e0f4ed21bdd6d949bae3ff7ea4))
 * import/export metadata.json needs to be trimmed ([#32407](https://projects.theforeman.org/issues/32407), [0f3220e6](https://github.com/Katello/katello.git/commit/0f3220e6c7ce4dd4aad3f95720bf3c94a9d38d9f))
 * Auto-import custom repos - Disconnected ([#32333](https://projects.theforeman.org/issues/32333), [893cc6dd](https://github.com/Katello/katello.git/commit/893cc6dd265754e865c1c93a3a6df73cf9a4a736))
 * Auto create cv on import ([#32241](https://projects.theforeman.org/issues/32241), [d4e4b6d9](https://github.com/Katello/hammer-cli-katello.git/commit/d4e4b6d95cf15fd131bca534359e5d05011a4ada), [f34f3d21](https://github.com/Katello/katello.git/commit/f34f3d21876d5fcb93a3cc25c5e9ffb18942ad40), [2b3e263b](https://github.com/Katello/hammer-cli-katello.git/commit/2b3e263b8f416ee9c369a0ffffe2365ce682adf0))
 * Can Import/Export file type ([#32187](https://projects.theforeman.org/issues/32187), [8d32486b](https://github.com/Katello/katello.git/commit/8d32486b7b3b3358d748fd42f88ed4e93947e4db))
 * Need a dry run option to see content is importable ([#31955](https://projects.theforeman.org/issues/31955), [b41dfa2d](https://github.com/Katello/katello.git/commit/b41dfa2de87641028fcbbaa90409de6bfb4cd4ef))

### Web UI
 * Update Composite and Component View icons on UI ([#32349](https://projects.theforeman.org/issues/32349), [753046d4](https://github.com/Katello/katello.git/commit/753046d4e6a71b89d5e8beaea67fa0cbb118c858))
 * New Content View Page - CV List page env and version expandable columns ([#32283](https://projects.theforeman.org/issues/32283), [d2af4f53](https://github.com/Katello/katello.git/commit/d2af4f53a56cf4e69ffe25799b3da1df6baa8b33))
 * New Content View Page - Versions tab ([#32281](https://projects.theforeman.org/issues/32281), [35513c5b](https://github.com/Katello/katello.git/commit/35513c5bf7fbe7eb51a193286f9a711988a08f16))
 * New Content View page: Back button doesn't work to return to list ([#32162](https://projects.theforeman.org/issues/32162), [c72adddb](https://github.com/Katello/katello.git/commit/c72adddbd939ad374f3feea67e67e4b47d12d181))
 * Need to add deprecation warning on Content Host -> Register Content Host page since we are planning to deprecate katello-ca-consumer and old registration method. ([#31973](https://projects.theforeman.org/issues/31973), [67803e6c](https://github.com/Katello/katello.git/commit/67803e6c36fd94829f426b34cbfc1eefe08c5577))
 * update Angular ([#31929](https://projects.theforeman.org/issues/31929), [3d6c569a](https://github.com/Katello/katello.git/commit/3d6c569a745f5e44991a487bb0bd8ac323119fd4))
 * eslint error in Tasks/helpers.js ([#31862](https://projects.theforeman.org/issues/31862), [1db3d50e](https://github.com/Katello/katello.git/commit/1db3d50e5aa41f1dc1eb6330415cbf96662cb34a))
 * Patternfly 4 - Have tabs that support routing and subpages ([#31716](https://projects.theforeman.org/issues/31716), [3197ac57](https://github.com/Katello/katello.git/commit/3197ac57f2acd231c9b4b3e523124164d0fcfef9))

### Tests
 * SubscriptionsTable failing test ([#32340](https://projects.theforeman.org/issues/32340), [ee7d0cc4](https://github.com/Katello/katello.git/commit/ee7d0cc4c501376cd35923f5a1e6617132d5a2a6))
 * Intermittent module stream clause generator test ([#32231](https://projects.theforeman.org/issues/32231), [5022393e](https://github.com/Katello/katello.git/commit/5022393eda8a15bf68efe3f2813f00deaa51130c))
 * test failure due to template kinds ([#32087](https://projects.theforeman.org/issues/32087), [55adc4f3](https://github.com/Katello/katello.git/commit/55adc4f3b3e33ef3c8cc0b08be41710dfb72a9dd))
 * Try to fix intermittent ApplicableContentHelper test ([#31954](https://projects.theforeman.org/issues/31954), [79d423fe](https://github.com/Katello/katello.git/commit/79d423fe1aa18a538e081df2f245fcad8593ea25), [35b80d22](https://github.com/Katello/katello.git/commit/35b80d22d90d19d1202a28e5441cb94b8d4a7d36))
 * bulk_host_extensions transient test failure ([#31911](https://projects.theforeman.org/issues/31911), [78239560](https://github.com/Katello/katello.git/commit/782395606474d14254f307a65bd2acc340312584))
 * Module stream copying tests need to be un-skipped after Pulpcore 3.9.1 is released ([#31704](https://projects.theforeman.org/issues/31704), [1e389926](https://github.com/Katello/katello.git/commit/1e38992603284a11def8de517e5b9ed280cb20e7))

### Hammer
 * hammer repository create needs to take a requirements file ([#32339](https://projects.theforeman.org/issues/32339), [25453dfe](https://github.com/Katello/hammer-cli-katello.git/commit/25453dfeb72abdfd1a9296d9b0f64be4b6938ae8))
 * hammer activation-key/content-host product-content not working correctly ([#32259](https://projects.theforeman.org/issues/32259), [49799266](https://github.com/Katello/katello.git/commit/49799266289075aa71bb5832c841373fd7d04f7b))
 * Add hammer bindings for `hammer content-import list` ([#32127](https://projects.theforeman.org/issues/32127), [067d6da6](https://github.com/Katello/katello.git/commit/067d6da6d080d6e1847a215e34c9f62c7961df8e), [228bde38](https://github.com/Katello/hammer-cli-katello.git/commit/228bde38ac5e0d236a1fe278a193a46fae590f2b))
 * Drop hammer_cli_foreman_docker requirement as the project is discontinued ([#32101](https://projects.theforeman.org/issues/32101), [52ec4658](https://github.com/Katello/hammer-cli-katello.git/commit/52ec4658bef06ce691eda34ee3eb0101b8f808aa), [b212a728](https://github.com/Katello/hammer-cli-katello.git/commit/b212a7286945af11cc5ecc6d929fa3895d9b2166))
 * Latest API data fails in hammer activation key tests now needs org id ([#32073](https://projects.theforeman.org/issues/32073), [23489dcb](https://github.com/Katello/hammer-cli-katello.git/commit/23489dcbc366edc81ff55864a4b1b4f8e2f8a0c2))
 * Show katello-agent status in hammer ping ([#31896](https://projects.theforeman.org/issues/31896), [497116af](https://github.com/Katello/hammer-cli-katello.git/commit/497116afe54e2e6bbcc47bf44ae9b4d30d035329), [b07e82cd](https://github.com/Katello/hammer-cli-katello.git/commit/b07e82cd2fdf08c39e87d5386ebe9ea107d237f6))
 * Org info should reflect the Simple Content Access status ([#31858](https://projects.theforeman.org/issues/31858), [492a7a26](https://github.com/Katello/hammer-cli-katello.git/commit/492a7a26385ed0aa82b2a6e79bfc686bc4b37d08))
 * hammer content-export --name option does not work ([#31456](https://projects.theforeman.org/issues/31456), [6a9f329f](https://github.com/Katello/hammer-cli-katello.git/commit/6a9f329fb097154750fae4842bd7ae99a3e5147f))

### Subscriptions
 * Subscriptions and Pools can be associated across organizations ([#32334](https://projects.theforeman.org/issues/32334), [df86940f](https://github.com/Katello/katello.git/commit/df86940f1ab1116b8b3126424ba6064aa69e4853), [a9544596](https://github.com/Katello/katello.git/commit/a9544596d785d0a0b171e1b9ad8cda3f9ca4fa3a), [7c990202](https://github.com/Katello/katello.git/commit/7c990202f99565d579c8e8a385194ee52f40d410))
 * Auto-attaching subscriptions on a host triggers pool import for all organizations ([#32267](https://projects.theforeman.org/issues/32267), [127733b7](https://github.com/Katello/katello.git/commit/127733b7b90295ac06d787b9e9bfe22bc4ce8da8))
 * Manifest deletion indexes subscriptions for all organizations ([#32261](https://projects.theforeman.org/issues/32261), [af76f405](https://github.com/Katello/katello.git/commit/af76f405d5cbccffcf58ad02bd29fe71904a9613))
 * Custom subscriptions showing entitlements as -1 on Subscriptions page ([#31864](https://projects.theforeman.org/issues/31864), [18a7153e](https://github.com/Katello/katello.git/commit/18a7153e566bbb441f2d74d769f6e60743d2e0fa))
 * Avoid race conditions in CandlepinMessageHandler ([#31812](https://projects.theforeman.org/issues/31812), [84844d81](https://github.com/Katello/katello.git/commit/84844d818ae56821f63134662e24f9a7a2326e16))
 * Syspurpose role is showing empty in the subscription page and rest api even it has a role ([#30708](https://projects.theforeman.org/issues/30708), [bc682301](https://github.com/Katello/katello.git/commit/bc682301b52cac8c42b3979286fff0749f13d1d1))

### API
 * Use public API to update Setting values ([#32285](https://projects.theforeman.org/issues/32285), [4b07d4d9](https://github.com/Katello/katello.git/commit/4b07d4d928e59de9a69924389aa98362095330c4))
 * "Unable to print debug information" log message from Katello::HttpResource.print_debug_info ([#32249](https://projects.theforeman.org/issues/32249), [ee5c736c](https://github.com/Katello/katello.git/commit/ee5c736c56c9287acb6652c8649380a4c0650496))
 * Remove unused import/export end points ([#32000](https://projects.theforeman.org/issues/32000), [89802465](https://github.com/Katello/katello.git/commit/898024650ec1667a87034b0d06c1f81c9daf594c), [61d1a50e](https://github.com/Katello/hammer-cli-katello.git/commit/61d1a50e1d3ae30b7430ab8f3657b33b33285698))

### Organizations and Locations
 * Seed fails with  PG::ForeignKeyViolation: ERROR:  insert or update on table "foreman_tasks_tasks" violates foreign key constraint "fk_rails_a56904dd86" ([#32277](https://projects.theforeman.org/issues/32277), [4670bc21](https://github.com/Katello/katello.git/commit/4670bc21ef8dd4f33d660a3d4c4e08cdeab81265))

### Repositories
 * Package matching query does not exist when syncing TimeScaleDB repo after migration ([#32232](https://projects.theforeman.org/issues/32232), [f7bef07a](https://github.com/Katello/katello.git/commit/f7bef07afbde848cd7728a7f144d8f33955bcb76))
 * "podman search returns 'archived/versioned' repos, but ISE is returned when pulling them" ([#32159](https://projects.theforeman.org/issues/32159), [06cdb710](https://github.com/Katello/katello.git/commit/06cdb710bc5b335492ae9ce2de736006b3d375d7))
 * pulp3: Exclude filter in CVV does not work ([#32010](https://projects.theforeman.org/issues/32010), [58b9974a](https://github.com/Katello/katello.git/commit/58b9974a0a7bb384eb3a7843ae6f9e50406982ba))
 * Unsetting repository architecture restriction doesn't reach clients ([#32008](https://projects.theforeman.org/issues/32008), [28bb2bee](https://github.com/Katello/katello.git/commit/28bb2bee1d5fa93532b2bbc1c48dcf6bc5f924ab), [6d70fab5](https://github.com/Katello/katello.git/commit/6d70fab5d062010335e04eee8e9a995b824256f4))
 * Cancel is outside of the table on sync status page during synchronization ([#31921](https://projects.theforeman.org/issues/31921), [2b4b6b5a](https://github.com/Katello/katello.git/commit/2b4b6b5a4c33b45246537829defd13cfeef014e1))
 * change bulk_load_size  within katello -> pulp SETTING to use a Setting ([#31323](https://projects.theforeman.org/issues/31323), [188fcc6e](https://github.com/Katello/katello.git/commit/188fcc6e8f2f8d33909e6a48511837ba226751f4))

### Activation Key
 * Activation Key details always asking for content view ([#32225](https://projects.theforeman.org/issues/32225), [6a17dd0c](https://github.com/Katello/katello.git/commit/6a17dd0c7378eca0aa404f44d018234cad470caf))
 * Activation Key Repository Set page not functioning correctly ([#32067](https://projects.theforeman.org/issues/32067), [a41851ba](https://github.com/Katello/katello.git/commit/a41851ba5600cc8526edbfade6dae9058861393d))
 * Adding subscription to activation-key fails on incorrectly detected duplicates ([#30250](https://projects.theforeman.org/issues/30250), [9bbc8bf4](https://github.com/Katello/katello.git/commit/9bbc8bf4804fba83601976b356e458f22dea6886))

### Hosts
 * Hypervisor task failed with NoMethodError: undefined method `split` for nil:NilClass ([#32150](https://projects.theforeman.org/issues/32150), [28976c3d](https://github.com/Katello/katello.git/commit/28976c3db591e2cbdbaf1eb2ef36588d4e57b436))
 * Show Candlepin version in /rhsm/status API ([#31706](https://projects.theforeman.org/issues/31706), [a8be6572](https://github.com/Katello/katello.git/commit/a8be657280469373bafd66bff073e0209e35ffc4))
 * Update content host registration page ([#31266](https://projects.theforeman.org/issues/31266))
 * The display of the errata status on hosts page is different to the status on the content host page ([#31000](https://projects.theforeman.org/issues/31000))

### Tooling
 * katello shouldn't require ruby < 2.7 ([#31958](https://projects.theforeman.org/issues/31958), [154d6cae](https://github.com/Katello/katello.git/commit/154d6cae6ee3c1ae8d7f22965167cb562674dde5))

### Errata Management
 * Errata freeform search needs to look into  title/history/description ([#31939](https://projects.theforeman.org/issues/31939), [d6afc2a2](https://github.com/Katello/katello.git/commit/d6afc2a2598086707d464347e298754e45e02642))
 * errata filter (search) not working in katello 3.18.1 ([#31925](https://projects.theforeman.org/issues/31925))
 * Applying errata from the errata's page always tries to use katello-agent even when remote_execution_by_default set to true ([#31894](https://projects.theforeman.org/issues/31894), [6d32fc73](https://github.com/Katello/katello.git/commit/6d32fc732b4ef436ff979b358577425327b05e9d))

### Ansible Collections
 * Ansible collection remotes need auth_url, token fields exposed ([#31928](https://projects.theforeman.org/issues/31928), [17636b30](https://github.com/Katello/katello.git/commit/17636b306f28fbbe912178b5359c10419f33bf68))

### Sync Plans
 * Any product disabled/removed should automatically disassociate from sync plan ([#31920](https://projects.theforeman.org/issues/31920), [78bd7bd0](https://github.com/Katello/katello.git/commit/78bd7bd0d0cd01e961296fac106c509acf9007c6))

### Content Views
 * New Content View Page - view added CVs for Composite Content View ([#31827](https://projects.theforeman.org/issues/31827), [c711fd66](https://github.com/Katello/katello.git/commit/c711fd669ada3164406d9571e4194e5e84e845d2))
 * New Content View Page - History Tab ([#31804](https://projects.theforeman.org/issues/31804), [9cc57c12](https://github.com/Katello/katello.git/commit/9cc57c12ad70f686e0e5543bd38d3b90ef3558f8))
 * Make single API call to show all content available and added to a content view filter ([#31756](https://projects.theforeman.org/issues/31756), [1f2af485](https://github.com/Katello/katello.git/commit/1f2af48525052b59c6bbaeeced2a3e4cbd34deb2))
 * New Content View Page - UX changes for create and copy modals ([#31655](https://projects.theforeman.org/issues/31655), [53940c06](https://github.com/Katello/katello.git/commit/53940c069e36bad3dad330ec3e198b269813bc9c))
 * New Content View Page - Add/Remove repositories from content view ([#31653](https://projects.theforeman.org/issues/31653), [0675f718](https://github.com/Katello/katello.git/commit/0675f7183c26f50ed53485b6393af8ae32583c39))
 * New Content View page - show package group filters ([#31648](https://projects.theforeman.org/issues/31648), [ba2b39e4](https://github.com/Katello/katello.git/commit/ba2b39e4e6862f0994016d6a6d4f36ce60bb870c))

### Installer
 * make host dynflow worker count configurable  and assign applicability to a dynflow queue ([#29752](https://projects.theforeman.org/issues/29752))

### Other
 * [BUG] Non-Admin users cannot generate the command for registration while having "Register hosts" role associated in Satellite 6.9 ([#32425](https://projects.theforeman.org/issues/32425), [35a0d5f7](https://github.com/Katello/katello.git/commit/35a0d5f7136672c0bcd05cddafd5fcd108ea44c1))
 * Package dependency is wrong on Katello UI ([#32358](https://projects.theforeman.org/issues/32358), [36689e96](https://github.com/Katello/katello.git/commit/36689e96f4fb419373e70beb90499a7a8dce8a83))
 * Possible file descriptor leaks ([#32262](https://projects.theforeman.org/issues/32262), [47277c64](https://github.com/Katello/katello.git/commit/47277c64ee2193577501b6a80cec488286882ffe))
 * Modify 'Media Selection' string of Operating System's hostgroup page ([#32237](https://projects.theforeman.org/issues/32237), [cc1a7ecb](https://github.com/Katello/katello.git/commit/cc1a7ecb7377e6492c095fb17810b8860dbbfddf))
 * rubocop: Metrics/MethodLength cop: Count hashes etc. as one line of code ([#32111](https://projects.theforeman.org/issues/32111), [a4063aae](https://github.com/Katello/katello.git/commit/a4063aae501fd3b89e4360e99ba9a23c671ff355))
 * Unable to set HostGroup content source to capsule that isn't synced ([#32100](https://projects.theforeman.org/issues/32100), [80aa661a](https://github.com/Katello/katello.git/commit/80aa661a1ef44a991736a42b3635e5562b3fc28a))
 * Add auditing for pulp3 import/export ([#32039](https://projects.theforeman.org/issues/32039), [ac5d863a](https://github.com/Katello/katello.git/commit/ac5d863a935fda2d9522e4b0832e8747aa4c39af))
 * "Failed to discover docker repositories because  'Content Default HTTP Proxy' is not used to connect to the registry." ([#32036](https://projects.theforeman.org/issues/32036), [fdff81f5](https://github.com/Katello/katello.git/commit/fdff81f5bbcd2548a2dd2cde888ac1126ab2ba4a))
