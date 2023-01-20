# 4.7.1 Whiskey Sour (2023-01-20)

## Features

### Hosts
 * Add Virtual guests to System properties card ([#35741](https://projects.theforeman.org/issues/35741), [5d66a5e1](https://github.com/Katello/katello.git/commit/5d66a5e1053404d257f49779402a2cb8b232d390))

## Bug Fixes

### API
 * Include SmartProxyAuth into RegistrationController ([#35926](https://projects.theforeman.org/issues/35926), [f432a51d](https://github.com/Katello/katello.git/commit/f432a51d8dd5913184fe8e80ae524c6e3d1e9f22))

### Web UI
 * UX on change content source page is ambiguous ([#35919](https://projects.theforeman.org/issues/35919), [0c258941](https://github.com/Katello/katello.git/commit/0c258941b12848d3932f6b24923585c3cc7b1fd6))
 * new host details - Content view selector not scrollable ([#35742](https://projects.theforeman.org/issues/35742), [f9907675](https://github.com/Katello/katello.git/commit/f99076758b8bde89a4f4512cbf20201fb45ee402))

### Hosts
 * Module streams subtab in new host details UI is missing on RHEL 8.7 hosts ([#35915](https://projects.theforeman.org/issues/35915), [8349b751](https://github.com/Katello/katello.git/commit/8349b7512eb11cbf4279e2e00d9bc2603e83e1e2))
 * Content host status refreshed even for hosts without content ([#35683](https://projects.theforeman.org/issues/35683), [329c1610](https://github.com/Katello/katello.git/commit/329c16105c209d385cb03dda845dc4c19ac8d260))
 * New host details Repository sets - Sorting is incorrect ([#35213](https://projects.theforeman.org/issues/35213), [5b7ede35](https://github.com/Katello/katello.git/commit/5b7ede358cbf28c23c0f23c9840a5aecf2cecd8f))

### Repositories
 * [katello] Allow pulp_rest debugs for pulp3 ([#35906](https://projects.theforeman.org/issues/35906), [f2497b03](https://github.com/Katello/katello.git/commit/f2497b034770d4172be5df24dd9c7436d96211c3))
 * Duplicate RepositorySet when manifest updated. ([#35848](https://projects.theforeman.org/issues/35848), [72a192cf](https://github.com/Katello/katello.git/commit/72a192cf398009661b98f5b87f4f0ffd490ca300))

### Alternate Content Sources
 * Refreshing ACS with --name instead of --id fails with "Error: Found more than one alternate_content_source." ([#35754](https://projects.theforeman.org/issues/35754), [d4d2d483](https://github.com/Katello/katello.git/commit/d4d2d48363171d37a6acf19c1650ec0fa4c1d9c2))

### Hammer
 * Hammer simplified ACS creation shouldn't allow user to enter product names ([#35815](https://projects.theforeman.org/issues/35815), [15cc4c08](https://github.com/Katello/hammer-cli-katello.git/commit/15cc4c0805131292ff186a55c8bf1880ff73bfc8))

# 4.7.0 Whiskey Sour (2022-12-08)

## Features

### Subscriptions
 * Katello should use the newer asynchronous Candlepin endpoint to export manifests ([#35734](https://projects.theforeman.org/issues/35734), [fce0a6d7](https://github.com/Katello/katello.git/commit/fce0a6d7eeca412a3586c74759f423e99cc6155f))

### Repositories
 * Use pulp_deb optimize sync mode for most APT repo syncs ([#35693](https://projects.theforeman.org/issues/35693), [a077047c](https://github.com/Katello/katello.git/commit/a077047c4ea08e249875043f4ddb5de4601a049e))
 * Remove ACS from labs and place it in the Content section ([#35608](https://projects.theforeman.org/issues/35608), [aa0a02f5](https://github.com/Katello/katello.git/commit/aa0a02f5f96b3f35d3e94636b7ec53ef1623b244))
 * - Add rhel-6-server-els-rpms repository under recommended repositories ([#35539](https://projects.theforeman.org/issues/35539), [af29276c](https://github.com/Katello/katello.git/commit/af29276c8590d8bad7eb3e4c27659a773b14276b), [10795f8f](https://github.com/Katello/katello.git/commit/10795f8f647562d757e67d9c5d74373e1ae6eadf))
 * Add Alternate Content Sources tab to content credentials ([#35344](https://projects.theforeman.org/issues/35344), [6ec0e826](https://github.com/Katello/katello.git/commit/6ec0e826b64dda5bad1080112f83d35c586bfb03))

### Errata Management
 * Show applicable errata on ErrataOverviewCard ([#35668](https://projects.theforeman.org/issues/35668), [4978b131](https://github.com/Katello/katello.git/commit/4978b1314d7fd7d0a6d513353af6690a20426170))

### Hosts
 * As a user, when I click a link to a content host it should take me to the new host details page ([#35632](https://projects.theforeman.org/issues/35632), [d079c97b](https://github.com/Katello/katello.git/commit/d079c97b58ab090e9de5bfd3140e03128ae22892))

### Foreman Proxy Content
 * Use proxy template URL in registration ([#35627](https://projects.theforeman.org/issues/35627), [fa5ac016](https://github.com/Katello/katello.git/commit/fa5ac0161ed1292bc900ed6d0593b7d88b792cf8))

### Content Views
 * CVV Compare - Add sorting to the tables ([#35613](https://projects.theforeman.org/issues/35613), [ed08beb6](https://github.com/Katello/katello.git/commit/ed08beb6cd98dbd70959f5f8b9836f6fc22c8017))
 * CVV Compare - Add repository subtab to content view compare ([#35589](https://projects.theforeman.org/issues/35589), [3bc91588](https://github.com/Katello/katello.git/commit/3bc91588f71a3cb41825b9ed448d994364967f43))
 * - Add static ouia-id to modal with wizard for publishing a cv ([#35370](https://projects.theforeman.org/issues/35370), [bd2c2c16](https://github.com/Katello/katello.git/commit/bd2c2c16dac397398d050e1a2199cb66b21a1771), [e6d6576a](https://github.com/Katello/katello.git/commit/e6d6576ac7392b9a8c38a14678cffe9005d8a856))
 * CVVersion Compare - add support for different content types  ([#35220](https://projects.theforeman.org/issues/35220), [1a40f0c2](https://github.com/Katello/katello.git/commit/1a40f0c275a8e0b519e66a65bee8a3b300d9cc9b))

### Inter Server Sync
 * Make syncable import accept a url instead of a path ([#35606](https://projects.theforeman.org/issues/35606), [6a705229](https://github.com/Katello/katello.git/commit/6a705229041682536ed504de8dc81cd88989194e), [3b4052ec](https://github.com/Katello/hammer-cli-katello.git/commit/3b4052ec1c5b0e2729ed1a58edefde711f11f771))
 * [RFE] Need syncable yum-format repository imports ([#35505](https://projects.theforeman.org/issues/35505), [49d9db72](https://github.com/Katello/katello.git/commit/49d9db72c6985ec1aac502444b78ea282dc93383), [8fb71dd2](https://github.com/Katello/hammer-cli-katello.git/commit/8fb71dd2a47132cbf3bda38c0f27222015cca083))

### Web UI
 * Add content profile for hosts index page ([#35595](https://projects.theforeman.org/issues/35595), [4a0c3541](https://github.com/Katello/katello.git/commit/4a0c35413671a15ae0281fc0a2cf364b6ccec916))
 * Don’t allow to mismatch Environment / CV / capsule ([#35446](https://projects.theforeman.org/issues/35446), [3383c710](https://github.com/Katello/katello.git/commit/3383c71086cd847c2beab6280fc8d588e0629178))

### Sync Plans
 * Capsule Last Sync date and status should not be based on task data. ([#35407](https://projects.theforeman.org/issues/35407), [b5962efe](https://github.com/Katello/katello.git/commit/b5962efe644cb3fbb2bafa46b301aa7e1f847d0f))

### Alternate Content Sources
 * As a user, I can bulk delete and refresh ACSs via the UI ([#33464](https://projects.theforeman.org/issues/33464), [012aca74](https://github.com/Katello/katello.git/commit/012aca74de9b4414bf233701a6e091936c3a78d0))
 * As a user, I can create CDN and RHUI ACSs via the UI ([#33463](https://projects.theforeman.org/issues/33463), [706094cb](https://github.com/Katello/katello.git/commit/706094cbf79f4bebb0d4e9a9628f21a7b2badebb))

## Bug Fixes

### Hosts
 * Hosts filter isn't working with host_ids URL param ([#35810](https://projects.theforeman.org/issues/35810), [a06d6471](https://github.com/Katello/katello.git/commit/a06d64715c37f11e08f823c48d1936fd2955f40c))
 * new host details - Repository sets pagination ignores filters ([#35795](https://projects.theforeman.org/issues/35795), [5b7ede35](https://github.com/Katello/katello.git/commit/5b7ede358cbf28c23c0f23c9840a5aecf2cecd8f))
 * Don't use the term 'Subscription Watch' any more ([#35704](https://projects.theforeman.org/issues/35704), [8cf95988](https://github.com/Katello/katello.git/commit/8cf959880228feac08f8934a0fd25f026f90ea3e))
 * Content change template assumes host has a kickstart repository available ([#35566](https://projects.theforeman.org/issues/35566), [b7aea089](https://github.com/Katello/katello.git/commit/b7aea08962a97dfaa00b069c16cd380bd477a928))
 * Changing content source for a host breaks REX pull, if configured ([#35516](https://projects.theforeman.org/issues/35516), [a6427862](https://github.com/Katello/katello.git/commit/a64278629616b6b7e378ef1375b7eda80012e13a))
 * Packages tab - Add dropdown to select upgrade version ([#35452](https://projects.theforeman.org/issues/35452), [b80d6220](https://github.com/Katello/katello.git/commit/b80d622028ff391c0763098bab1fdd3c5f0dcebe))
 * Host UI - cards have cursor pointer ([#35441](https://projects.theforeman.org/issues/35441), [cfb8779d](https://github.com/Katello/katello.git/commit/cfb8779d0885d3044e8f5f209fccb56884035d8d))
 * '0 enhancements' text sometimes overflows Errata overview card ([#35399](https://projects.theforeman.org/issues/35399), [8df695ac](https://github.com/Katello/katello.git/commit/8df695ac76fef4a0f30789bad5c311858b915f6c))
 * Add host collections card empty state ([#35372](https://projects.theforeman.org/issues/35372), [309624be](https://github.com/Katello/katello.git/commit/309624be4ea2e89cf14427fd80f03612456e4a3f))
 * New host details - Hide module streams tab for EL7 hosts ([#34973](https://projects.theforeman.org/issues/34973), [9d6b86d1](https://github.com/Katello/katello.git/commit/9d6b86d1cae62f6b0f09725e45908c7fcfbc1421))
 * Use synced content broken if hostgroup is set to all media ([#35624](https://projects.theforeman.org/issues/35624), [6b36dea1](https://github.com/Katello/katello.git/commit/6b36dea1b9be7208c89a468703f7f1d9c56045c5))

### Tooling
 * Create Georgian translations in Katello  ([#35782](https://projects.theforeman.org/issues/35782), [b18dab85](https://github.com/Katello/katello.git/commit/b18dab85c6941e86112309aea21e224e8762fc3c))
 * Development env issue: param group Api::V2::HostsController#installed_products not defined ([#35499](https://projects.theforeman.org/issues/35499), [eef975fa](https://github.com/Katello/katello.git/commit/eef975fa903a2ef9f079ab0365d47d2601977f74))
 * When installing errata via katello-agent, content_action_finish_timeout is ignored and tasks don't wait for client status to finish ([#35364](https://projects.theforeman.org/issues/35364), [fe90a5c6](https://github.com/Katello/katello.git/commit/fe90a5c6bd6ad5f2bcc4101f406c23ec41616e88))
 * [Upgrade Pulp Deb] pulp-deb fails to sync repo with a package that contains + in the name ([#35148](https://projects.theforeman.org/issues/35148))

### Foreman Proxy Content
 * Add pulp_deb monkeypatch for pulp 3.21 - 3.18 sync ([#35776](https://projects.theforeman.org/issues/35776), [28e0136a](https://github.com/Katello/katello.git/commit/28e0136ae8c9820a1cd179eb0ab02781bfbf21dc))
 *  Error "no certificate or crl found" when using a http proxy as "Default Http Proxy" for content syncing or manifest operations  ([#35773](https://projects.theforeman.org/issues/35773), [54334bf5](https://github.com/Katello/katello.git/commit/54334bf5cadcd372996839e6ecd0fd2277ec19ea))
 * Orphaned ACSs should be cleaned from smart proxies ([#35736](https://projects.theforeman.org/issues/35736), [28a7171e](https://github.com/Katello/katello.git/commit/28a7171ed3be4fdb0ebd96bfad2304b05f0ea080))
 * Can't sync container repos from pulp_container 2.14 to proxies with pulp_container 2.10 ([#35688](https://projects.theforeman.org/issues/35688), [71218935](https://github.com/Katello/katello.git/commit/71218935e3e8204fc7d58dcd6922efd1a50da079))
 * Accessing an external capsule from UI, shows "Last sync failed: 404 Not Found" even if the last capsule content sync was successful in Satellite 6.12 ([#35552](https://projects.theforeman.org/issues/35552), [26b1d1ba](https://github.com/Katello/katello.git/commit/26b1d1ba05100caff0fe17d64483fc6fb48f39a0))
 * Assign HTTP Proxies to ACSs per smart proxy rather than per ACS ([#34897](https://projects.theforeman.org/issues/34897), [e95e87ef](https://github.com/Katello/katello.git/commit/e95e87ef4253c62785fecbb91541cb5f81f2b3e6))

### Content Views
 * Composite content view versions can be emptied out during same-repo merging ([#35740](https://projects.theforeman.org/issues/35740), [d793dda2](https://github.com/Katello/katello.git/commit/d793dda2a36d70a8aefae2cb14f9226552dda690))
 * Content view filter errata by  id will include module streams of other repos/arches ([#35737](https://projects.theforeman.org/issues/35737), [279073d7](https://github.com/Katello/katello.git/commit/279073d7446e1cbf096437c1533925e83e4b7b31))
 * Content view filter will include module streams of other repos/arches if the errata contain rpms in multiple repos/arches. ([#35610](https://projects.theforeman.org/issues/35610), [3cff7f7c](https://github.com/Katello/katello.git/commit/3cff7f7c20a7e468feef002014ff694aa3e43b1b))
 * Make cv publish fail on invalid/non existent content ([#35572](https://projects.theforeman.org/issues/35572), [7664477e](https://github.com/Katello/katello.git/commit/7664477e77e54bb44d6475b64784e511880a49f1))
 * Navigating to content view page from the left panel after creating a cv does not work ([#35511](https://projects.theforeman.org/issues/35511), [50d5cd97](https://github.com/Katello/katello.git/commit/50d5cd97f9a08abed982f2a1dd42c8a98b90a7cf))
 * Input sanitation of Content View Names not working ([#35235](https://projects.theforeman.org/issues/35235), [2509fae9](https://github.com/Katello/katello.git/commit/2509fae91199c4bb886c70d06e488985f8b4b521))

### Web UI
 * Show include all RPM without errata and the 3 other checkboxes for rpm and module stream filters outside table so they don't get hidden by empty state. ([#35730](https://projects.theforeman.org/issues/35730), [e601daea](https://github.com/Katello/katello.git/commit/e601daea51be0750418f9289dab12dfa2784bfb5))
 * UX review - CVV compare screen ([#35712](https://projects.theforeman.org/issues/35712), [f8f6fee9](https://github.com/Katello/katello.git/commit/f8f6fee9074c364906951877d62c9bf3ea28fa8c))
 * ACS UI - UX reviews ([#35711](https://projects.theforeman.org/issues/35711), [a0b25a0e](https://github.com/Katello/katello.git/commit/a0b25a0eb3990a77618d84e5b140296600df1980))
 * Audit permissions on ACS UI ([#35661](https://projects.theforeman.org/issues/35661), [5f4ffd28](https://github.com/Katello/katello.git/commit/5f4ffd28caf97e43a2471cbd97ebd6baa22422fb))
 * Change 'Subscription Allocation' to 'Manifest' on the Manage Manifest screen ([#35618](https://projects.theforeman.org/issues/35618), [723f67e8](https://github.com/Katello/katello.git/commit/723f67e87aa8d482be64a8e7dda054f93f98ae96))
 * ACS UI - General updates ([#35571](https://projects.theforeman.org/issues/35571), [3dd05eaa](https://github.com/Katello/katello.git/commit/3dd05eaae500ace69b76ea590ce3d882ed1510c8))
 * ACS Wizard - UX changes ([#35565](https://projects.theforeman.org/issues/35565), [e2314970](https://github.com/Katello/katello.git/commit/e231497012e63bb2589d9cc19c146f21656cc3dc))
 * When searching for content, dropdown filters are literal search terms. ([#35512](https://projects.theforeman.org/issues/35512), [76f715bf](https://github.com/Katello/katello.git/commit/76f715bfd28a50c59e94f924a7d03be91ef512b2))

### Inter Server Sync
 * Generated content views are displayed in Main Dashboard ([#35723](https://projects.theforeman.org/issues/35723), [6b5e6ee5](https://github.com/Katello/katello.git/commit/6b5e6ee53f1453407b3ec47874e11e9b440f9b63))
 * Content View Versions generated by Export are still listed in Composite page ([#35501](https://projects.theforeman.org/issues/35501), [3b23b993](https://github.com/Katello/katello.git/commit/3b23b99334ef9a3bd8d7d298b84c51dedf9806a2))
 * Syncable exports not properly validated ([#35442](https://projects.theforeman.org/issues/35442), [19056c10](https://github.com/Katello/hammer-cli-katello.git/commit/19056c10c202374a8b4cf200f357b299555e8ce6), [2166e5e3](https://github.com/Katello/katello.git/commit/2166e5e34c2013f419036c9f24f1dfcffef8e475))
 * Importing a custom repository with different label but same name causes validation error ([#35425](https://projects.theforeman.org/issues/35425), [cf159cad](https://github.com/Katello/katello.git/commit/cf159cadb0b306faea429aba0af5fa07ad45b105))
 * Pathing issue on exports ([#35410](https://projects.theforeman.org/issues/35410), [491e8af0](https://github.com/Katello/katello.git/commit/491e8af044cae8da1cb7b2c77f33516dda79aab3))
 * Need to be able to provide custom cert for ISS for Red Hat CDN ([#35296](https://projects.theforeman.org/issues/35296), [a0e63cb0](https://github.com/Katello/katello.git/commit/a0e63cb063a07646ef079acfab762a6e7435b110), [6a47ac35](https://github.com/Katello/hammer-cli-katello.git/commit/6a47ac3546be9aafa2533e09b9ca4b51fd449f43))

### Container
 * Getting "undefined method `schema_version' for nil:NilClass" while syncing from quay.io ([#35709](https://projects.theforeman.org/issues/35709), [475388ea](https://github.com/Katello/katello.git/commit/475388eaef0796339326b17b8362b5015c719f9c))

### API
 * Can't edit the `ignore_types` of an Organization ([#35687](https://projects.theforeman.org/issues/35687), [414bcb72](https://github.com/Katello/katello.git/commit/414bcb720be9f9c6bfc730e5a9836f93b5784307))
 * Activation Keys "product_content" API doesn't expose the "per_page" parameter ([#35633](https://projects.theforeman.org/issues/35633), [2496c9da](https://github.com/Katello/katello.git/commit/2496c9da198f6e19efb0eb37104b227ba9bb2831))
 * repositories/import_uploads API endpoint do require two mandatory parameters ([#35567](https://projects.theforeman.org/issues/35567), [7088cb1c](https://github.com/Katello/katello.git/commit/7088cb1c8382f84f247a2629802731b2e0947d22))

### Repositories
 * Index module profiles for modular repos ([#35653](https://projects.theforeman.org/issues/35653), [35c4634b](https://github.com/Katello/katello.git/commit/35c4634be2054a1d1c1bd6a8a2882e4bfc6ac4a1))
 * Pulpcore 3.21 - Upload rpm fails ([#35590](https://projects.theforeman.org/issues/35590), [3caad4a1](https://github.com/Katello/katello.git/commit/3caad4a130d4a6f4a5d8ac62f2e9c7e5ab8ad4cf))
 * Unable to "Remove" a repository directly if the repo is part of a CV as well as CCV in Satellite 6.12 ([#35549](https://projects.theforeman.org/issues/35549), [d552e95d](https://github.com/Katello/katello.git/commit/d552e95de12156d0db318ac2c4d125b7deb8c79a))
 * CV version details repository tab links to library_instance_inverse version and lets you use it like a regular library repo ([#35517](https://projects.theforeman.org/issues/35517), [8c506de3](https://github.com/Katello/katello.git/commit/8c506de31f427d304141d6a406e38d59d0cc36fc))
 * Non-enabled repository types make it into the apipie help-text ([#35459](https://projects.theforeman.org/issues/35459), [b9069a44](https://github.com/Katello/hammer-cli-katello.git/commit/b9069a44dd0fea700e680fc6952c77bb44a67924), [71959b72](https://github.com/Katello/katello.git/commit/71959b720220baaef8b79d699c25093671aaba7c))
 * Task group errors do not drill into child task errors ([#35275](https://projects.theforeman.org/issues/35275), [ee84716c](https://github.com/Katello/katello.git/commit/ee84716c4c94b28b0bb1302e63e6e81f3615c710))

### Subscriptions
 * Create a rake task to identify missing content in Candlepin ([#35599](https://projects.theforeman.org/issues/35599), [7a5a352f](https://github.com/Katello/katello.git/commit/7a5a352fbd8fbf9913c215c5bba15c83bc4ad4db))

### Alternate Content Sources
 * ACS create wizard: review details step displays password in plaintext when manual auth is selected ([#35537](https://projects.theforeman.org/issues/35537), [364205f6](https://github.com/Katello/katello.git/commit/364205f67240833eef1736510b5f5dda4cc2ee5c))
 * ACS create fails when same name used with "PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint" ([#35482](https://projects.theforeman.org/issues/35482), [445b0ee6](https://github.com/Katello/katello.git/commit/445b0ee69e8ce2e8850f32a377ec0d355757071c))
### Content Credentials
 * Prevent the deletion of content credentials when they are in use ([#35588](https://projects.theforeman.org/issues/35588), [8cb5f411](https://github.com/Katello/katello.git/commit/8cb5f411a95e55d8c78bda8b92c185ab08faea80))

### Errata Management
 * Errata Mail calculates updated_at date per repository, should be per erratum ([#35503](https://projects.theforeman.org/issues/35503), [e626c4ce](https://github.com/Katello/katello.git/commit/e626c4ce9078ddfd36bfe3216a85bacc96427212))
 * 'This host has errata that are applicable, but not installable' message incorrectly appears ([#35398](https://projects.theforeman.org/issues/35398), [06067779](https://github.com/Katello/katello.git/commit/06067779f1668a9e92dcd42c6356052cfae6eb5d))

### Ansible Collections
 * Indexing error if a collection to be synced from galaxy doesn't have tags associated. ([#35412](https://projects.theforeman.org/issues/35412), [d6eb14ec](https://github.com/Katello/katello.git/commit/d6eb14ec5f23583247b5ec3bcda9ec64089321db))

### Activation Key
 * Activation key can be deleted, but still shows up in hostgroup configuration ([#35386](https://projects.theforeman.org/issues/35386), [dcfc73ea](https://github.com/Katello/katello.git/commit/dcfc73ea9a150a0291f94a5959e42163dfa2c330))

### Roles and Permissions
 * Katello 403 after pressing Sync button on a repository page ([#35153](https://projects.theforeman.org/issues/35153), [333e11c7](https://github.com/Katello/katello.git/commit/333e11c7c4c9f03d2bbf4edef033679e8aac848f))
