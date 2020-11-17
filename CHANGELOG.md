# 3.18.0 RC2 (2020-11-17)

## Features

### Subscriptions
 * Add extendable Slot in subscriptions manage manifest modal ([#31162](https://projects.theforeman.org/issues/31162), [25b42acc](https://github.com/Katello/katello.git/commit/25b42acc432a6b68501545cffdd5c2315fd27aaa))
 * Disable SCA toggle in UI if the Candlepin request would fail ([#31134](https://projects.theforeman.org/issues/31134), [1d00b1e0](https://github.com/Katello/katello.git/commit/1d00b1e0194891e07d919cfe89cfcfdea51f6e09))
 * Change Sub Watch links and SCA banner message ([#30892](https://projects.theforeman.org/issues/30892), [3fb165d1](https://github.com/Katello/katello.git/commit/3fb165d1b6402f3e41c69ac72868a6a2e943bb75))

### Repositories
 * Need rake task that shows Pulp2->Pulp3 content migration stats ([#31120](https://projects.theforeman.org/issues/31120), [b60f5770](https://github.com/Katello/katello.git/commit/b60f57702fdc9b919d368e21e96ed4fe0f2fdfd6))
 * Add pulp3 debian support ([#29421](https://projects.theforeman.org/issues/29421), [cbd77ad8](https://github.com/Katello/katello.git/commit/cbd77ad888cf139f46a65f462634c060f9e6c369))
 * [sat-e-492] Allow adding releasever to custom repos ([#24166](https://projects.theforeman.org/issues/24166), [67b60bb3](https://github.com/Katello/katello.git/commit/67b60bb3f7690bb68dc6396455f7bdafaa0ffcb3))

### Hosts
 * Set System Purpose on multiple hosts via bulk action ([#30994](https://projects.theforeman.org/issues/30994), [3830e16a](https://github.com/Katello/katello.git/commit/3830e16aa192bd4644208b59f2036977bcf8a8fb), [3f410ba1](https://github.com/Katello/katello.git/commit/3f410ba17fe2ece96cf8e53742c741f487b88f38))
 * Global Registration - Search for @host by :uuid or :hostname ([#30904](https://projects.theforeman.org/issues/30904), [ad6a02a5](https://github.com/Katello/katello.git/commit/ad6a02a502d2300e295ecc134b5c991aaf7f8338))
 * Extend Global registration endpoint with :activation_key parameter. ([#30676](https://projects.theforeman.org/issues/30676), [0fc2c0a9](https://github.com/Katello/katello.git/commit/0fc2c0a9572b3fa8cc4919e2248a378e4843e100))

### Performance
 * smartly sync capsules with history tracking ([#30824](https://projects.theforeman.org/issues/30824), [2e1af356](https://github.com/Katello/katello.git/commit/2e1af3567183a9b74d218cddc7c9bfdee313d32d))

### Inter Server Sync
 * As a user, i can export a content view version and only get the ‘diff’ of the content view version (incremental export). ([#30003](https://projects.theforeman.org/issues/30003), [254767cf](https://github.com/Katello/katello.git/commit/254767cfb399f7d04e85205845cc716485b636fb))

### Other
 * Add rake task that kills running pulp 3 migration tasks ([#31195](https://projects.theforeman.org/issues/31195), [4ebd34e4](https://github.com/Katello/katello.git/commit/4ebd34e4c9b01ec1c09814dbb881f6021cefca22))
 * Extend Global Registration UI form ([#31182](https://projects.theforeman.org/issues/31182), [f11b51b3](https://github.com/Katello/katello.git/commit/f11b51b311835c6e6532e4cf35045d84eae49b81))
 * Allow to set prefix for Katello::KatelloUrlsHelper::subscription_manager_configuration_url ([#30819](https://projects.theforeman.org/issues/30819), [2b654767](https://github.com/Katello/katello.git/commit/2b6547675404c4243c4b2d001b71e3ae1659bfa1))

## Bug Fixes

### Tooling
 * Need `disable_dynflow` for pulp3_migration_abort to work on production ([#31294](https://projects.theforeman.org/issues/31294), [806619c5](https://github.com/Katello/katello.git/commit/806619c566588bfe76abe13811f5a47b36f194fa))
 * make katello reset handle pip installed pulpcore ([#30655](https://projects.theforeman.org/issues/30655), [c50717c0](https://github.com/Katello/katello.git/commit/c50717c04f6b885d91da4280ae5b0de59cddc5b9))

### Upgrades
 * migration takes longer than it should on CVs with lots of versions ([#31276](https://projects.theforeman.org/issues/31276), [c4e2e114](https://github.com/Katello/katello.git/commit/c4e2e1145894e3850979a0be039a15edb2e23929))

### Docker
 * container registry depends on 'container_image_registry' even under pulp3 ([#31199](https://projects.theforeman.org/issues/31199), [152529f8](https://github.com/Katello/katello.git/commit/152529f808562bf3a1653b8d16c716e1ef7e018c))
 * Pulp 3 Docker proxy syncing does not work ([#30907](https://projects.theforeman.org/issues/30907), [ad2e9c38](https://github.com/Katello/katello.git/commit/ad2e9c38d2d6d08273f39f49c72ec1a28494c4f6))

### Content Views
 * Add Import-Only flag to Content Views ([#31189](https://projects.theforeman.org/issues/31189), [df728607](https://github.com/Katello/katello.git/commit/df7286071ce42b67cf17a30cf6b201435a6354fa))
 * Error: PLP0034: The distributor indicated a failed response when publishing repository. ([#31115](https://projects.theforeman.org/issues/31115), [580bf73c](https://github.com/Katello/katello.git/commit/580bf73c483609004ac0670c07dc629d8aeb6163))
 * Add metadata to content view export history ([#31053](https://projects.theforeman.org/issues/31053), [c3deccfc](https://github.com/Katello/katello.git/commit/c3deccfcd8018a9443eede585998b28805eb719c))
 * As a user I 'd like to `chunk` an export ([#30928](https://projects.theforeman.org/issues/30928), [f2acd999](https://github.com/Katello/katello.git/commit/f2acd99914e2ad07b967b2d4e11abe298438a890))
 * add new content view repositories tab to CV details page ([#29997](https://projects.theforeman.org/issues/29997), [a046c3b1](https://github.com/Katello/katello.git/commit/a046c3b1ce8ff2ef5cc1da6f35b8f0cd02bcbfce))

### API
 * Hammer ping/ping api will show pulp3 is down when not in 6.9 'migration mode' ([#31169](https://projects.theforeman.org/issues/31169), [1d2e29b7](https://github.com/Katello/katello.git/commit/1d2e29b74767b4f54337d2f6b86ae4ef44e0e24d))
 * /katello/api/subscriptions endpoint missing in apidoc description ([#31069](https://projects.theforeman.org/issues/31069), [98ac10c6](https://github.com/Katello/katello.git/commit/98ac10c666ff5aaf12822e328116c167f86c5522))
 * Add an end point to check one whether can use export/export-future ([#30961](https://projects.theforeman.org/issues/30961), [245d80ce](https://github.com/Katello/katello.git/commit/245d80ce2cb0c7571b7a6269bcbf3819630d2939))

### Hosts
 * Add authorization for HostBulkActionsController ([#31159](https://projects.theforeman.org/issues/31159), [686c9c8d](https://github.com/Katello/katello.git/commit/686c9c8d681b52370bc771bfacc84cf15c955630))
 * Registration fails if Katello is involved and the host is already subscribed, just not registered to this Satellite ([#31050](https://projects.theforeman.org/issues/31050), [6f671bb7](https://github.com/Katello/katello.git/commit/6f671bb7871b1cb40db9b7eef2a8595d11825e07))
 * reporter_id needs to be set for hypervisor update ([#31004](https://projects.theforeman.org/issues/31004), [dd6bd935](https://github.com/Katello/katello.git/commit/dd6bd93533efebb03ad5a5b8defc5d23086415c4))
 * Katello on EL8 uses Pulp2 for consumer related tasks (like profile uploads) ([#30832](https://projects.theforeman.org/issues/30832), [925100ea](https://github.com/Katello/katello.git/commit/925100ea97c26ed7eaf93a6d8f294c7e9d4241fe))
 * Hypervisors upload fails with duplicate UUIDs ([#30826](https://projects.theforeman.org/issues/30826), [59210c07](https://github.com/Katello/katello.git/commit/59210c0704e6935e045d6cb20584618862bac368))
 * Remove debian packages through content host page ([#30811](https://projects.theforeman.org/issues/30811), [cdbb0049](https://github.com/Katello/katello.git/commit/cdbb0049115a917989bcfb9f213753356c717a11))
 * Toggling Simple Content Access does not update host Subscription status ([#30758](https://projects.theforeman.org/issues/30758), [75864d0b](https://github.com/Katello/katello.git/commit/75864d0b7bfbb600baebad26b7293f6610a4a119))

### Repositories
 * Add authorization for repositories_bulk_actions controller ([#31156](https://projects.theforeman.org/issues/31156), [b7130f53](https://github.com/Katello/katello.git/commit/b7130f539e1010e40f18308ef217a7a06e2bbfde))
 * repository content 'compare' api does not work properly with library CVV ([#30624](https://projects.theforeman.org/issues/30624), [bb074f00](https://github.com/Katello/katello.git/commit/bb074f0084fd711f2a5d75c1ed5b76f813f515a7))

### Hammer
 * Hammer ping does not return Pulp 3 status ([#31133](https://projects.theforeman.org/issues/31133), [e3a0ac79](https://github.com/Katello/hammer-cli-katello.git/commit/e3a0ac793f71613fc1f663ac25da0c745dd0e018))
 * Implement a hammer subcommand for exportable_histories ([#31052](https://projects.theforeman.org/issues/31052), [b1d9a4d3](https://github.com/Katello/hammer-cli-katello.git/commit/b1d9a4d3eccd18d397948d3bf0a2758e44de583d), [ccc1b9d5](https://github.com/Katello/hammer-cli-katello.git/commit/ccc1b9d541b66778cce4855e87246b83dc7b8683))

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

### Tests
 * pulp3 chunk'd upload doesn't have a test ([#30777](https://projects.theforeman.org/issues/30777), [c49442fa](https://github.com/Katello/katello.git/commit/c49442fabf5ccb04ad584a290a1915b0c0344ee8))

### Other
 * Product advance sync notification link to task contains html text ([#30893](https://projects.theforeman.org/issues/30893), [d292bfa9](https://github.com/Katello/katello.git/commit/d292bfa91a09dbd9d23cb679d848d511aef4298e))
 * Add authorization for Products controller ([#30884](https://projects.theforeman.org/issues/30884), [1f113bae](https://github.com/Katello/katello.git/commit/1f113baebcbd9dce858cd4766dd08fc21267965d))
 * Use checked_icon helper instead of 'Enabled | Disabled' for SCA column ([#30883](https://projects.theforeman.org/issues/30883), [1b46dc4d](https://github.com/Katello/katello.git/commit/1b46dc4db4fd4e0f569bbdd503c8e2c3d40a2746))
