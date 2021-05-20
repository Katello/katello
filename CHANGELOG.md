# 3.18.3 (2021-05-20)

## Features

### Other
 * Enable deb content for 2to3 migration ([#32420](https://projects.theforeman.org/issues/32420))

## Bug Fixes

### Repositories
 * katello:delete_orphaned_content fails on Katello 3.18 with "backend service pulp3: 503 Service Unavailable" ([#32623](https://projects.theforeman.org/issues/32623), [63a1d5ba](https://github.com/Katello/katello.git/commit/63a1d5bae152290cc0a31e9f1eea491749f8a009))
 * pulp3_migration_stats rake task can underestimate the migration timing ([#32449](https://projects.theforeman.org/issues/32449))
 * Deb-content should also publish original structure ([#32393](https://projects.theforeman.org/issues/32393), [c46df71a](https://github.com/Katello/katello.git/commit/c46df71a67ab07cd365194d47858f83f94b2379c))
 * Pulp 3 migration abort fails with 409 ([#32226](https://projects.theforeman.org/issues/32226), [20425810](https://github.com/Katello/katello.git/commit/204258102b40c9e35d01f5ad1680c9d0e694bcd6), [50be17da](https://github.com/Katello/katello.git/commit/50be17daf2ae161ae95026ff50092ef9ce6b6446))
 * Pulp3 Migration after migration reset doesn't import errata info from pulp3 ([#32210](https://projects.theforeman.org/issues/32210))
 * excess memory consumption when importing errata during pulp3 migration ([#32142](https://projects.theforeman.org/issues/32142))
 * pulp3 task group actions 'end' as soon as one subtask fails ([#31905](https://projects.theforeman.org/issues/31905), [a09e10c0](https://github.com/Katello/katello.git/commit/a09e10c0da42037eee63e0347d616b3b294bba50))
 * Some repositories cannot be synchronized with error: Artifact() got an unexpected keyword argument 'sha' ([#31559](https://projects.theforeman.org/issues/31559))

### Tests
 * npm install error on nightly ([#32531](https://projects.theforeman.org/issues/32531), [5d1294c8](https://github.com/Katello/katello.git/commit/5d1294c849e98ad515922ae615bd5e460a3dd36b))
 * Try to fix intermittent ApplicableContentHelper test ([#31954](https://projects.theforeman.org/issues/31954), [79d423fe](https://github.com/Katello/katello.git/commit/79d423fe1aa18a538e081df2f245fcad8593ea25), [35b80d22](https://github.com/Katello/katello.git/commit/35b80d22d90d19d1202a28e5441cb94b8d4a7d36))

### Hosts
 * Inherited hostgroup values are not set when creating host ([#32464](https://projects.theforeman.org/issues/32464), [23a5b7a7](https://github.com/Katello/katello.git/commit/23a5b7a70f6054a5bfcc61affef58c8061e40eee))

### Content Views
 * Do the orphans cleanup before switchover to pulp3 ([#32302](https://projects.theforeman.org/issues/32302))

### Container
 * syncing pulp3 to pulp2  container content sometimes fails with PLP0000: 'fsLayers ([#32230](https://projects.theforeman.org/issues/32230), [c01834bd](https://github.com/Katello/katello.git/commit/c01834bd2e79974988b064826f1ab5197a54c54b))

### Documentation
 * Katello 3.18 Documentation ([#32165](https://projects.theforeman.org/issues/32165))

### Inter Server Sync
 * Failed to import content view with more than 20 repositories enabled ([#32129](https://projects.theforeman.org/issues/32129))

### Tooling
 * katello content switchover rake task uses a sync task instead of an async task ([#32109](https://projects.theforeman.org/issues/32109))
 * loosen pulp 2to3 migration bindings gem requirement ([#32062](https://projects.theforeman.org/issues/32062))
 * foreman-rake katello:clean_backend_objects fails with "      "The Dynflow world was not initialized yet. If your plugin uses it, make sure to call Rails.application.dynflow.require! in some initializer"}," ([#31725](https://projects.theforeman.org/issues/31725), [b8c73d76](https://github.com/Katello/katello.git/commit/b8c73d768baed4d00b97cfd43997bb826a1a36a3), [58d14a2a](https://github.com/Katello/katello.git/commit/58d14a2ad729b658aa79c25fb06e224ad8f914c1), [e1bb601c](https://github.com/Katello/katello.git/commit/e1bb601c2a381369f7d25b1c961b574f54515794))
 * db seed fails with 'Unknown remote execution feature katello_module_stream_action' ([#31416](https://projects.theforeman.org/issues/31416), [c9693c16](https://github.com/Katello/katello.git/commit/c9693c16e46a1276621a86694023b5892f53eb52))

### Other
 * Update pulp-rpm to 3.10.0 for Katello 3.18. ([#32301](https://projects.theforeman.org/issues/32301))
 * Pulp3 services won't start after running a migration after performing switchover ([#32256](https://projects.theforeman.org/issues/32256))
 * Hanging task when restarting services during pulp2 to pulp3 migration ([#32119](https://projects.theforeman.org/issues/32119), [a09e10c0](https://github.com/Katello/katello.git/commit/a09e10c0da42037eee63e0347d616b3b294bba50))
# 3.18.2.1 (2021-03-12)

## Bug Fixes

### Repositories
 * errata are deleted after content switchover ([#32066](https://projects.theforeman.org/issues/32066))

### Tooling
 * Pulp3 migration reports failed services ([#32058](https://projects.theforeman.org/issues/32058), [1cb62370](https://github.com/Katello/katello.git/commit/1cb62370d82cca17806420c0b1f671a95a65a71f))

### Errata Management
 * clients using /pulp/content/ for their repo path do not have applicability calculated properly ([#32005](https://projects.theforeman.org/issues/32005), [fdcf4d76](https://github.com/Katello/katello.git/commit/fdcf4d760f39f649b4d6b2aa2c17e7c95c8abbba))

# 3.18.2 (2021-03-05)

## Bug Fixes

### Repositories
 * Unable to create repositories in Pulp 3 mode with Firefox as the browser - username : This field may not be blank. ([#31949](https://projects.theforeman.org/issues/31949), [efc22f61](https://github.com/Katello/katello.git/commit/efc22f6156dce605006282fa4a511210be08af3d))
 * katello_yum_metadata_files record has migrated_pulp3_href NULL value ([#31919](https://projects.theforeman.org/issues/31919))
 * support skip_corrupted=True for pulp 2to3 migration ([#31636](https://projects.theforeman.org/issues/31636))
 * support pulp3 migration reset flag to let users 'restart' from scratch ([#31336](https://projects.theforeman.org/issues/31336))
 * Katello Pulp 3 Applicability erroneously shows non-modular RPMs upgradable from modular RPMs with same name but older version ([#31270](https://projects.theforeman.org/issues/31270), [56fb9e52](https://github.com/Katello/katello.git/commit/56fb9e52dba2ba45f5d3e6342572bec531496ab5))

### Tooling
 * upgrade 3.18 to pulp migration plugin 0.7 ([#31863](https://projects.theforeman.org/issues/31863), [ce4c229a](https://github.com/Katello/katello.git/commit/ce4c229a53c32a218bcf1e82475a63c645439aad))
 * support migration 'reset' ([#31654](https://projects.theforeman.org/issues/31654))
 * pulp migration stats says 2x /var/lib/pulp/published, but should be 3x ([#31528](https://projects.theforeman.org/issues/31528), [a147ee2b](https://github.com/Katello/katello.git/commit/a147ee2b2479d5115964815c6f3a917929c534e4))
 * remove 'load' from rake tasks ([#31424](https://projects.theforeman.org/issues/31424), [3b1fd352](https://github.com/Katello/katello.git/commit/3b1fd352a2b9a481772355990d5632d58b0899e9))

### Subscriptions
 * WebUI not getting updated when you modify entitlements quantity like add or less in subscriptions ([#31854](https://projects.theforeman.org/issues/31854), [854fe802](https://github.com/Katello/katello.git/commit/854fe802d7d536a9925d8cf191da2b0a7b25cc0c))

### Content Views
 * User with viewer role can see "Create Content View" button ([#31839](https://projects.theforeman.org/issues/31839), [50821807](https://github.com/Katello/katello.git/commit/508218070026e8a1a2ea7993d80f105f9e136ced))
 * hammer content-view filter delete fails ([#31775](https://projects.theforeman.org/issues/31775), [72d67aa9](https://github.com/Katello/katello.git/commit/72d67aa9872da7415e3d3166cbadbaccd590030d))

### Hosts
 * Global Registration: Unable to re-register with satellite using the Curl Command ([#31810](https://projects.theforeman.org/issues/31810))
 * System Purpose bulk setting is not reflected on host ([#31591](https://projects.theforeman.org/issues/31591), [f15e3021](https://github.com/Katello/katello.git/commit/f15e30213887249ba25b413abd6e71f1a27a325d))
 * Update Host Bulk Actions SystemPurpose UI ([#31580](https://projects.theforeman.org/issues/31580), [a2451014](https://github.com/Katello/katello.git/commit/a2451014fa9e1a2b5b1d5a2cc8b36f60e19c89a3))

### Hammer
 * hammer content-export list not searching by content view  id ([#31683](https://projects.theforeman.org/issues/31683), [63d3c072](https://github.com/Katello/hammer-cli-katello.git/commit/63d3c07256868cba45f1f1701f810736edcb205d))

### Modularity
 * [Foreman 2.3] [zh_CN/ja_JP] Unlocalized string on web element, Search button on "Content -> Module Streams" page needs to be marked as translated. ([#31353](https://projects.theforeman.org/issues/31353), [7761fcbd](https://github.com/Katello/katello.git/commit/7761fcbd677da67c5b5b3686b44725b63559ba67))

### Sync Plans
 * User drop down menu(upper right corner) under sync status is whited out ([#31320](https://projects.theforeman.org/issues/31320), [a09cb408](https://github.com/Katello/katello.git/commit/a09cb408b0f0622f1b782cbdbdd3569fb303ae0e))

# 3.18.1 (2021-01-05)

## Bug Fixes

### Inter Server Sync
 * hammer content-import -: do not  check for 'pulp' things  ([#31504](https://projects.theforeman.org/issues/31504), [13d0dd04](https://github.com/Katello/katello.git/commit/13d0dd0452743a80ebe01d453427788a916c7bbd))
 * hammer content-export should take a --lifecycle-environment ([#31487](https://projects.theforeman.org/issues/31487), [54b62a91](https://github.com/Katello/hammer-cli-katello.git/commit/54b62a91fb8297b5056d449ed1951934f6a9ec0b))

### Subscriptions
 * When in Simple Content Access mode, hypervisors with no subscription attached show as 'unsubscribed hypervisor' in their Subscription sub-status ([#31479](https://projects.theforeman.org/issues/31479), [aec2e8c0](https://github.com/Katello/katello.git/commit/aec2e8c06b44a94459cbe4b1e74562ae1a5a7033))

### API
 * API doc is incorrect for /api/hosts/bulk/available_incremental_updates ([#31470](https://projects.theforeman.org/issues/31470), [6587a9d8](https://github.com/Katello/katello.git/commit/6587a9d89e2af779f5aff01eff7fe6249c73f6e7))

### Foreman Proxy Content
 * smart proxy sync fails with puppet content, leading to paused tasks. ([#31469](https://projects.theforeman.org/issues/31469), [82b9562c](https://github.com/Katello/katello.git/commit/82b9562c650e264200580e5f5beb3e8993121539))

### Repositories
 * Web UI shows duplicate rpms when user uploads the same rpm that signed with different checksum ([#31455](https://projects.theforeman.org/issues/31455), [ba98fcfe](https://github.com/Katello/katello.git/commit/ba98fcfe9e6a7c1ae2ae8d290cdbd86bb2738660))

### Content Views
 * When deleting a content view version, all hosts have been listed as affected even hosts are not using it ([#31445](https://projects.theforeman.org/issues/31445), [54812395](https://github.com/Katello/katello.git/commit/54812395cc997e140e8f9f22a64fa43fa5162f2d))
 * Incremental update should depsolve only on repos containing units ([#31427](https://projects.theforeman.org/issues/31427), [44e6d911](https://github.com/Katello/katello.git/commit/44e6d9119d55a98469586d285c7ace69d2cd8763))

# 3.18.0 (2020-12-09)

## Features

### Foreman Proxy Content
 * Support syncing to a Pulp 3 only Proxy ([#31315](https://projects.theforeman.org/issues/31315), [646e49f6](https://github.com/Katello/katello.git/commit/646e49f60e6af38e34e947bc6b75cca4062f8bf6))

### Subscriptions
 * Add extendable Slot in subscriptions manage manifest modal ([#31162](https://projects.theforeman.org/issues/31162), [25b42acc](https://github.com/Katello/katello.git/commit/25b42acc432a6b68501545cffdd5c2315fd27aaa))
 * Disable SCA toggle in UI if the Candlepin request would fail ([#31134](https://projects.theforeman.org/issues/31134), [1d00b1e0](https://github.com/Katello/katello.git/commit/1d00b1e0194891e07d919cfe89cfcfdea51f6e09))
 * Change Sub Watch links and SCA banner message ([#30892](https://projects.theforeman.org/issues/30892), [3fb165d1](https://github.com/Katello/katello.git/commit/3fb165d1b6402f3e41c69ac72868a6a2e943bb75))

### Repositories
 * Add timing estimate to Pulp 3 migration stats rake task ([#31121](https://projects.theforeman.org/issues/31121), [91c2b34b](https://github.com/Katello/katello.git/commit/91c2b34b784010464286cdaec8b7bd3bc2c0027c))
 * Need rake task that shows Pulp2->Pulp3 content migration stats ([#31120](https://projects.theforeman.org/issues/31120), [b60f5770](https://github.com/Katello/katello.git/commit/b60f57702fdc9b919d368e21e96ed4fe0f2fdfd6))
 * Add pulp3 debian support ([#29421](https://projects.theforeman.org/issues/29421), [cbd77ad8](https://github.com/Katello/katello.git/commit/cbd77ad888cf139f46a65f462634c060f9e6c369))
 * [sat-e-492] Allow adding releasever to custom repos ([#24166](https://projects.theforeman.org/issues/24166), [67b60bb3](https://github.com/Katello/katello.git/commit/67b60bb3f7690bb68dc6396455f7bdafaa0ffcb3))

### Hosts
 * Set System Purpose on multiple hosts via bulk action ([#30994](https://projects.theforeman.org/issues/30994), [3830e16a](https://github.com/Katello/katello.git/commit/3830e16aa192bd4644208b59f2036977bcf8a8fb), [3f410ba1](https://github.com/Katello/katello.git/commit/3f410ba17fe2ece96cf8e53742c741f487b88f38))
 * Global Registration - Search for @host by :uuid or :hostname ([#30904](https://projects.theforeman.org/issues/30904), [ad6a02a5](https://github.com/Katello/katello.git/commit/ad6a02a502d2300e295ecc134b5c991aaf7f8338))
 * Extend Global registration endpoint with :activation_key parameter. ([#30676](https://projects.theforeman.org/issues/30676), [0fc2c0a9](https://github.com/Katello/katello.git/commit/0fc2c0a9572b3fa8cc4919e2248a378e4843e100))

### Docker
 * Pulp3 - Docker tag upload from hammer ([#30867](https://projects.theforeman.org/issues/30867), [359a8dd1](https://github.com/Katello/katello.git/commit/359a8dd144801af188ca058be196e6a689aba736))

### Performance
 * smartly sync capsules with history tracking ([#30824](https://projects.theforeman.org/issues/30824), [2e1af356](https://github.com/Katello/katello.git/commit/2e1af3567183a9b74d218cddc7c9bfdee313d32d))

### Inter Server Sync
 * As a user, i can export a content view version and only get the ‘diff’ of the content view version (incremental export). ([#30003](https://projects.theforeman.org/issues/30003), [254767cf](https://github.com/Katello/katello.git/commit/254767cfb399f7d04e85205845cc716485b636fb))

### Other
 * Add rake task that kills running pulp 3 migration tasks ([#31195](https://projects.theforeman.org/issues/31195), [4ebd34e4](https://github.com/Katello/katello.git/commit/4ebd34e4c9b01ec1c09814dbb881f6021cefca22))
 * Extend Global Registration UI form ([#31182](https://projects.theforeman.org/issues/31182), [f11b51b3](https://github.com/Katello/katello.git/commit/f11b51b311835c6e6532e4cf35045d84eae49b81))
 * Allow to set prefix for Katello::KatelloUrlsHelper::subscription_manager_configuration_url ([#30819](https://projects.theforeman.org/issues/30819), [2b654767](https://github.com/Katello/katello.git/commit/2b6547675404c4243c4b2d001b71e3ae1659bfa1))

## Bug Fixes

### Inter Server Sync
 * Error out on export if lazy ([#31447](https://projects.theforeman.org/issues/31447), [a895741b](https://github.com/Katello/katello.git/commit/a895741b7f8fb3d3b0a31fd55ba1c2edb39345d1), [ebc668ac](https://github.com/Katello/hammer-cli-katello.git/commit/ebc668aca90948afbeb3a73fd7e594b7b2b7de8c))
 * Make the import handle default content view ([#31078](https://projects.theforeman.org/issues/31078), [93d3bd5e](https://github.com/Katello/katello.git/commit/93d3bd5ec6e0a177a3a21cd9846bd8c3a43ee721))
 * Add/update hammer endpoint for import ([#31076](https://projects.theforeman.org/issues/31076), [b14484f4](https://github.com/Katello/hammer-cli-katello.git/commit/b14484f4a72540687088fb7a0b72f942741fbe4e), [a8518a74](https://github.com/Katello/hammer-cli-katello.git/commit/a8518a7416f5b232d7386dc5ad9350459de297a1))

### Hammer
 * Add 'complete' sub command for content-export ([#31443](https://projects.theforeman.org/issues/31443), [e3eaed81](https://github.com/Katello/hammer-cli-katello.git/commit/e3eaed81c612386a2147e41a3a497ddeb55befe3))
 * Add generate-metadata command for content-export ([#31438](https://projects.theforeman.org/issues/31438), [321eb5f8](https://github.com/Katello/hammer-cli-katello.git/commit/321eb5f8727d102138fb1206708a18f33b9d9dfe))
 * Change hammer tests from travis to GH actions ([#31333](https://projects.theforeman.org/issues/31333), [b6c1ab31](https://github.com/Katello/hammer-cli-katello.git/commit/b6c1ab311dfc4ed07c14331f96a7f394eb5e01ec), [db8326ab](https://github.com/Katello/hammer-cli-katello.git/commit/db8326abc4c1e8f6b37c5577cc12fdf1d9275f39), [327b385c](https://github.com/Katello/hammer-cli-katello.git/commit/327b385c5cc6bc4bc45682b108695ceddae6de8d))
 * Hammer ping does not return Pulp 3 status ([#31133](https://projects.theforeman.org/issues/31133), [e3a0ac79](https://github.com/Katello/hammer-cli-katello.git/commit/e3a0ac793f71613fc1f663ac25da0c745dd0e018))
 * Update hammer endpoint for export with pulp3 ([#31117](https://projects.theforeman.org/issues/31117), [a19435a3](https://github.com/Katello/katello.git/commit/a19435a3757c80371a29408a9a04e131b6576ec2), [6ca1e65d](https://github.com/Katello/hammer-cli-katello.git/commit/6ca1e65df2520e92b7f5294180214445591be5b6))
 * Implement a hammer subcommand for exportable_histories ([#31052](https://projects.theforeman.org/issues/31052), [b1d9a4d3](https://github.com/Katello/hammer-cli-katello.git/commit/b1d9a4d3eccd18d397948d3bf0a2758e44de583d), [ccc1b9d5](https://github.com/Katello/hammer-cli-katello.git/commit/ccc1b9d541b66778cce4855e87246b83dc7b8683))

### Tooling
 * foreman-rake katello:receptor:extract_orgs fails with Dynflow world was not initialized ([#31433](https://projects.theforeman.org/issues/31433), [941fc64a](https://github.com/Katello/katello.git/commit/941fc64a09f63d5111649467440436273f109b58))
 * Need `disable_dynflow` for pulp3_migration_abort to work on production ([#31294](https://projects.theforeman.org/issues/31294), [806619c5](https://github.com/Katello/katello.git/commit/806619c566588bfe76abe13811f5a47b36f194fa))
 * make katello reset handle pip installed pulpcore ([#30655](https://projects.theforeman.org/issues/30655), [c50717c0](https://github.com/Katello/katello.git/commit/c50717c04f6b885d91da4280ae5b0de59cddc5b9))

### Content Views
 * As a user I 'd like to export library content ([#31406](https://projects.theforeman.org/issues/31406), [d81de1b9](https://github.com/Katello/katello.git/commit/d81de1b96bd9450c3a8eb43166ff76becc8a56bb), [e7e3823a](https://github.com/Katello/hammer-cli-katello.git/commit/e7e3823ae68a7916073bdd4440d09eff66c590b9), [bb207e6f](https://github.com/Katello/hammer-cli-katello.git/commit/bb207e6f17e0b07e6c0eb13c03b8e60aa1520003))
 * Add Import-Only flag to Content Views ([#31189](https://projects.theforeman.org/issues/31189), [df728607](https://github.com/Katello/katello.git/commit/df7286071ce42b67cf17a30cf6b201435a6354fa))
 * Add proper authorization to content view versions controller ([#31158](https://projects.theforeman.org/issues/31158), [20aca2d8](https://github.com/Katello/katello.git/commit/20aca2d8d622737f1671c878237713ecbc2eaed0))
 * Error: PLP0034: The distributor indicated a failed response when publishing repository. ([#31115](https://projects.theforeman.org/issues/31115), [580bf73c](https://github.com/Katello/katello.git/commit/580bf73c483609004ac0670c07dc629d8aeb6163))
 * Add metadata to content view export history ([#31053](https://projects.theforeman.org/issues/31053), [c3deccfc](https://github.com/Katello/katello.git/commit/c3deccfcd8018a9443eede585998b28805eb719c))
 * As a user I 'd like to `chunk` an export ([#30928](https://projects.theforeman.org/issues/30928), [f2acd999](https://github.com/Katello/katello.git/commit/f2acd99914e2ad07b967b2d4e11abe298438a890))
 * add new content view repositories tab to CV details page ([#29997](https://projects.theforeman.org/issues/29997), [a046c3b1](https://github.com/Katello/katello.git/commit/a046c3b1ce8ff2ef5cc1da6f35b8f0cd02bcbfce))

### Hosts
 * Assign registration template when creating Red Hat OS ([#31402](https://projects.theforeman.org/issues/31402), [b870080c](https://github.com/Katello/katello.git/commit/b870080c17ca989b8954b51f8f82053645b34ab8))
 * Add authorization for HostBulkActionsController ([#31159](https://projects.theforeman.org/issues/31159), [686c9c8d](https://github.com/Katello/katello.git/commit/686c9c8d681b52370bc771bfacc84cf15c955630))
 * Registration fails if Katello is involved and the host is already subscribed, just not registered to this Satellite ([#31050](https://projects.theforeman.org/issues/31050), [6f671bb7](https://github.com/Katello/katello.git/commit/6f671bb7871b1cb40db9b7eef2a8595d11825e07))
 * reporter_id needs to be set for hypervisor update ([#31004](https://projects.theforeman.org/issues/31004), [dd6bd935](https://github.com/Katello/katello.git/commit/dd6bd93533efebb03ad5a5b8defc5d23086415c4))
 * Katello on EL8 uses Pulp2 for consumer related tasks (like profile uploads) ([#30832](https://projects.theforeman.org/issues/30832), [925100ea](https://github.com/Katello/katello.git/commit/925100ea97c26ed7eaf93a6d8f294c7e9d4241fe), [ced5376f](https://github.com/Katello/katello.git/commit/ced5376fa9412ad0cb4fe3512ee69d41b18a5021))
 * Remove debian packages through content host page ([#30811](https://projects.theforeman.org/issues/30811), [cdbb0049](https://github.com/Katello/katello.git/commit/cdbb0049115a917989bcfb9f213753356c717a11))
 * Toggling Simple Content Access does not update host Subscription status ([#30758](https://projects.theforeman.org/issues/30758), [75864d0b](https://github.com/Katello/katello.git/commit/75864d0b7bfbb600baebad26b7293f6610a4a119))

### Tests
 * transient test fails wrt to outdated VCR cassettes for export tests ([#31334](https://projects.theforeman.org/issues/31334), [7e553110](https://github.com/Katello/katello.git/commit/7e55311073c7f26b9fbbaa31a60a42cd9adf1525))
 * pulp3 chunk'd upload doesn't have a test ([#30777](https://projects.theforeman.org/issues/30777), [c49442fa](https://github.com/Katello/katello.git/commit/c49442fabf5ccb04ad584a290a1915b0c0344ee8))

### Upgrades
 * re-migration of pulp3 content with no changes is slow due to excess errata importing ([#31312](https://projects.theforeman.org/issues/31312), [b8ff3e13](https://github.com/Katello/katello.git/commit/b8ff3e13a42d718d4ece046120bf2b01e3688a49))
 * migration takes longer than it should on CVs with lots of versions ([#31276](https://projects.theforeman.org/issues/31276), [c4e2e114](https://github.com/Katello/katello.git/commit/c4e2e1145894e3850979a0be039a15edb2e23929))

### Docker
 * container registry depends on 'container_image_registry' even under pulp3 ([#31199](https://projects.theforeman.org/issues/31199), [152529f8](https://github.com/Katello/katello.git/commit/152529f808562bf3a1653b8d16c716e1ef7e018c))
 * Pulp 3 Docker proxy syncing does not work ([#30907](https://projects.theforeman.org/issues/30907), [ad2e9c38](https://github.com/Katello/katello.git/commit/ad2e9c38d2d6d08273f39f49c72ec1a28494c4f6))

### API
 * Hammer ping/ping api will show pulp3 is down when not in 6.9 'migration mode' ([#31169](https://projects.theforeman.org/issues/31169), [1d2e29b7](https://github.com/Katello/katello.git/commit/1d2e29b74767b4f54337d2f6b86ae4ef44e0e24d))
 * /katello/api/subscriptions endpoint missing in apidoc description ([#31069](https://projects.theforeman.org/issues/31069), [98ac10c6](https://github.com/Katello/katello.git/commit/98ac10c666ff5aaf12822e328116c167f86c5522))
 * Add an end point to check one whether can use export/export-future ([#30961](https://projects.theforeman.org/issues/30961), [245d80ce](https://github.com/Katello/katello.git/commit/245d80ce2cb0c7571b7a6269bcbf3819630d2939))

### Repositories
 * Add authorization for repositories_bulk_actions controller ([#31156](https://projects.theforeman.org/issues/31156), [b7130f53](https://github.com/Katello/katello.git/commit/b7130f539e1010e40f18308ef217a7a06e2bbfde))
 * repository content 'compare' api does not work properly with library CVV ([#30624](https://projects.theforeman.org/issues/30624), [bb074f00](https://github.com/Katello/katello.git/commit/bb074f0084fd711f2a5d75c1ed5b76f813f515a7))
 * provide better progress reporting for katello pulp3 content migration ([#29080](https://projects.theforeman.org/issues/29080), [8506e6d9](https://github.com/Katello/katello.git/commit/8506e6d9393cc777a907134b7e8e6439cebe6d15))

### Security
 * Add permission support to validate 404 on denial and  multi permissions ([#30880](https://projects.theforeman.org/issues/30880), [e2026d90](https://github.com/Katello/katello.git/commit/e2026d90e80ab73dd720d10d9e48839c22a95b1e))
 * Add authorization for ContentViewsController controller ([#30875](https://projects.theforeman.org/issues/30875), [27822e6a](https://github.com/Katello/katello.git/commit/27822e6a1afc2316307df023b9d52607389e5ce1))

### Content Credentials
 * authorization for content credentials controller ([#30878](https://projects.theforeman.org/issues/30878), [ddf3be58](https://github.com/Katello/katello.git/commit/ddf3be58808f48455d234f08c6d7b10d2a9d67ad))

### Sync Plans
 * Add authorization for sync_plan controller ([#30877](https://projects.theforeman.org/issues/30877), [6cea0dc9](https://github.com/Katello/katello.git/commit/6cea0dc99b9652f7fe0ff866920ce1b689eba95a))

### Host Collections
 * Add authorizations for host_collections controller ([#30876](https://projects.theforeman.org/issues/30876), [903a1d40](https://github.com/Katello/katello.git/commit/903a1d4082913383d89a31d6cfd98e05e05b04fb))

### Lifecycle Environments
 * Fix permissions in environments controller ([#30874](https://projects.theforeman.org/issues/30874), [9872e0c7](https://github.com/Katello/katello.git/commit/9872e0c7da50c9d1af01e08d3c3c3a316430b410))

### Activation Key
 * Add proper authorization to activation keys controller ([#30873](https://projects.theforeman.org/issues/30873), [5173a4f4](https://github.com/Katello/katello.git/commit/5173a4f4dce4e5a8adc04770ab63d52839273c4b))

### Web UI
 * selectAPIStatus selector needs a default status after foreman's change ([#30804](https://projects.theforeman.org/issues/30804), [0ee3fb43](https://github.com/Katello/katello.git/commit/0ee3fb4354288e63d126aa7a121ac27629bea981))
 * No Notification is sent when Bastion table fails to load its resource ([#30671](https://projects.theforeman.org/issues/30671), [fcccee2a](https://github.com/Katello/katello.git/commit/fcccee2aecf9db4132914ace0bc33bde4d23b564))

### Other
 * Product advance sync notification link to task contains html text ([#30893](https://projects.theforeman.org/issues/30893), [d292bfa9](https://github.com/Katello/katello.git/commit/d292bfa91a09dbd9d23cb679d848d511aef4298e))
 * Add authorization for Products controller ([#30884](https://projects.theforeman.org/issues/30884), [1f113bae](https://github.com/Katello/katello.git/commit/1f113baebcbd9dce858cd4766dd08fc21267965d))
 * Use checked_icon helper instead of 'Enabled | Disabled' for SCA column ([#30883](https://projects.theforeman.org/issues/30883), [1b46dc4d](https://github.com/Katello/katello.git/commit/1b46dc4db4fd4e0f569bbdd503c8e2c3d40a2746))
