# 4.16.0.rc2 Taliesin (2025-03-04)

## Features

### Activation Key
 * [RFE] Hint to enable settings 'allow_multiple_content_views' in hammer ak command ([#38143](https://projects.theforeman.org/issues/38143), [4b9bac94](https://github.com/Katello/katello.git/commit/4b9bac94930a1c6fa04ec9b51555dc8d0756add9))
 * As a user, I want to be able to set multiple Content Views via a single Activation key ([#37795](https://projects.theforeman.org/issues/37795), [746bda76](https://github.com/Katello/katello.git/commit/746bda76b50cbe6a321f17994dcd0cd13d97c49b))

### Hammer
 * As a user, I can see an overview of container images used with image-mode systems via Hammer ([#38127](https://projects.theforeman.org/issues/38127), [0f63d27f](https://github.com/Katello/katello.git/commit/0f63d27fbd3cacfe7c77067c5b21f6f28d9631fa), [83ae9dbf](https://github.com/Katello/hammer-cli-katello.git/commit/83ae9dbfc9f5764ff907f12502704210f7c623d9))

### Hosts
 * Add a link to the new REX bootc action on the image mode details card ([#38113](https://projects.theforeman.org/issues/38113), [25e95465](https://github.com/Katello/katello.git/commit/25e95465376dfead5d0772dd24fb873dd5bb0f2a))
 * New "All Hosts Page" should show Package Updates for Debian/Ubuntu ([#38097](https://projects.theforeman.org/issues/38097), [26d9ea98](https://github.com/Katello/katello.git/commit/26d9ea98729fbe744e000c2e10b4654266542b0e))
 * Add new job templates for bootc upgrade/switch/rollback via REX ([#38084](https://projects.theforeman.org/issues/38084), [916e7023](https://github.com/Katello/katello.git/commit/916e7023b57e818a1fa2e00d86d7f074aabf89e6))
 * A new card on Host details tab for image information ([#38013](https://projects.theforeman.org/issues/38013), [c79f9b17](https://github.com/Katello/katello.git/commit/c79f9b179e6f357c335099cd544325a9e7f4b068))
 * Gather bootc-related facts and populate content facet fields ([#37994](https://projects.theforeman.org/issues/37994), [dcf890d9](https://github.com/Katello/katello.git/commit/dcf890d963be9505fa8fba3c890b83f781c469c5))
 * As a user, I can see image-mode hosts' current and future image, manifest, tag via Hammer ([#37975](https://projects.theforeman.org/issues/37975), [f96ac211](https://github.com/Katello/hammer-cli-katello.git/commit/f96ac2110daa075285de69e4cf99b5c4486966e7))

### Repositories
 * Add a job template for flatpak setup on hosts and possibly install a flatpak image ([#38109](https://projects.theforeman.org/issues/38109), [ea0409b1](https://github.com/Katello/katello.git/commit/ea0409b1d46482db15e72e69c943ececa5396e15))
 * Filter Deb Packages by repository ([#38083](https://projects.theforeman.org/issues/38083), [f07701af](https://github.com/Katello/katello.git/commit/f07701af308530a2c1c5f70d6a01711998ab3ead))
 * Migrate to using type field in container manifests and lists ([#38071](https://projects.theforeman.org/issues/38071), [da6eb470](https://github.com/Katello/katello.git/commit/da6eb47008ef76c16bbc340643a824a86f3609a0))
 * As a user I can interact with remote repositories and manifests via API and mirror remote repositories in Katello ([#37989](https://projects.theforeman.org/issues/37989), [3f2a522d](https://github.com/Katello/katello.git/commit/3f2a522d00ca983c401157266587b95c41934e72), [363db98c](https://github.com/Katello/katello.git/commit/363db98c91728bcf5e69980dd9e2999874d6fa5a))
 * Add API endpoints with permissions for Flatpak remotes ([#37976](https://projects.theforeman.org/issues/37976), [3f2a522d](https://github.com/Katello/katello.git/commit/3f2a522d00ca983c401157266587b95c41934e72))
 * Add option to not sync dependencies of Ansible collections ([#37958](https://projects.theforeman.org/issues/37958), [58dfb8ca](https://github.com/Katello/katello.git/commit/58dfb8cac9fed8bd868338391900a801c947ba0e))
 * Support on-demand for file repos ([#37929](https://projects.theforeman.org/issues/37929), [c32d9acd](https://github.com/Katello/katello.git/commit/c32d9acd6b8b681038720f897824f0ea5d43b644))
 * Replace simple publisher with structured publisher for Debian Repositories ([#35959](https://projects.theforeman.org/issues/35959), [3b7244f4](https://github.com/Katello/katello.git/commit/3b7244f4cf744942928274c1fcc5084fa31b1318))

### Content Views
 * As a client, I should have access to all flatpaks available via registered Content View/Environment ([#38105](https://projects.theforeman.org/issues/38105), [20533616](https://github.com/Katello/katello.git/commit/2053361665c65451aae0eab6f49c57f0d9a7b5ac))

### Tooling
 * Update angular-rails-templates to a Rails 7 compatible version ([#38018](https://projects.theforeman.org/issues/38018), [74d6613b](https://github.com/Katello/katello.git/commit/74d6613b8f879ac4f2fc7b6edeafd2bb379b2ff7))
 * Support Rails 7.0 ([#37852](https://projects.theforeman.org/issues/37852), [20331a05](https://github.com/Katello/katello.git/commit/20331a051f101c752068f67ffed01587ee41b253))
 * Allow Katello to run without Redis ([#35162](https://projects.theforeman.org/issues/35162))

### HTTP Proxy
 * Set HTTP proxy as default after creating ([#37923](https://projects.theforeman.org/issues/37923), [c06a666f](https://github.com/Katello/katello.git/commit/c06a666ff13478cfe4334e28602e3950b4896359), [b316f4cc](https://github.com/Katello/katello.git/commit/b316f4cc1faacb70307c692c693b31a122a48198))

### Other
 * Support Zeitwerk loader ([#37471](https://projects.theforeman.org/issues/37471), [c90a1dc4](https://github.com/Katello/katello.git/commit/c90a1dc46dcf0991127f1f369f83d00e07b524d5))

## Bug Fixes

### Activation Key
 * Unable to an create activation key when no content-view is selected ([#38251](https://projects.theforeman.org/issues/38251), [fa485519](https://github.com/Katello/katello.git/commit/fa48551933923044b7dd7284acdf33a1988c8035))
 * hammer activation-key create false positive when passing in only --content-view ([#38170](https://projects.theforeman.org/issues/38170), [571efcb9](https://github.com/Katello/katello.git/commit/571efcb9d623e2c686eb97856a6eec57f6f8469c))
 * Can't remove a version from an environment if it is being used by a multi-CV activation key. ([#37895](https://projects.theforeman.org/issues/37895), [380e7ed1](https://github.com/Katello/katello.git/commit/380e7ed17310eebcb7430b86ca433d2fb7fadd26))
 * Multi-CV activation keys get their content view environments overwritten on any edit ([#37798](https://projects.theforeman.org/issues/37798), [c87ef0f6](https://github.com/Katello/katello.git/commit/c87ef0f6ad9ec6ade3bb10e811e3cfef17b7cb48))

### Content Views
 * Old CV versions may contain deb repos without structure content ([#38231](https://projects.theforeman.org/issues/38231), [a94ad14e](https://github.com/Katello/katello.git/commit/a94ad14e0164c7d55a8181dc87baad7d2ce30874))
 * CV with depsolving and filters on selected repos is broken at orhpan cleanup ([#38218](https://projects.theforeman.org/issues/38218), [ebfaf9bb](https://github.com/Katello/katello.git/commit/ebfaf9bb78bf8ac663584f647ae220b3ac928c6f))
 * Content views list duplicate relations for multiCV hosts and activation keys ([#38179](https://projects.theforeman.org/issues/38179), [3bad7ac6](https://github.com/Katello/katello.git/commit/3bad7ac6fcfe801910200348014adf1cd93f024e))
 * Use new host page setting to link to hosts index from content view details page ([#38160](https://projects.theforeman.org/issues/38160), [412e7f93](https://github.com/Katello/katello.git/commit/412e7f93ef4a3d9a7601a4cc1ed8d51dfb819ead))
 * To convert "Got multiple version_hrefs for pulp task" error into a warning or suppress it ([#38150](https://projects.theforeman.org/issues/38150), [882b257a](https://github.com/Katello/katello.git/commit/882b257afce348d1795db28fce81611543287b9e))
 * Reassigning host content views when removing Content view version/environment in multi-CV hosts ([#38116](https://projects.theforeman.org/issues/38116), [9c9d486b](https://github.com/Katello/katello.git/commit/9c9d486b4cd566d5b937da7c7013c5207634f128))
 * The content view APIs will pass repository_ids to the code both as a list of int or a list of strings ([#38076](https://projects.theforeman.org/issues/38076), [d041f949](https://github.com/Katello/katello.git/commit/d041f949beb8d5c30eb5f3005ffe3ac1d1721987))

### Hosts
 * in host edit, unselecting media causes page freeze  ([#38230](https://projects.theforeman.org/issues/38230), [83498c4f](https://github.com/Katello/katello.git/commit/83498c4f1e027faf730f6d40d27dcdf309d0af1e))
 * Image mode all hosts column title should be 'Type' ([#38226](https://projects.theforeman.org/issues/38226), [bbbf9e02](https://github.com/Katello/katello.git/commit/bbbf9e026ba85ada1ba8ce75be1e4f26168b9fbb))
 * Extra tbody left inside booted containers table causes automation issues ([#38225](https://projects.theforeman.org/issues/38225), [d8dc2626](https://github.com/Katello/katello.git/commit/d8dc2626709e1303d683585b8ae073b11850b73a))
 * Add unset feature in set release version bulk action on the content host ([#38215](https://projects.theforeman.org/issues/38215), [a739b710](https://github.com/Katello/katello.git/commit/a739b7104bde511b2a77eead93c6207cc94943a2))
 * Should hide Change content source task when permissions are missing ([#38214](https://projects.theforeman.org/issues/38214), [d0ec81e8](https://github.com/Katello/katello.git/commit/d0ec81e8a1ba430f1cc67840d4ad3e309c34d803))
 * RHEL 10 support policy + EOL info is added to hosts ([#38152](https://projects.theforeman.org/issues/38152), [527df0a5](https://github.com/Katello/katello.git/commit/527df0a5da5379d19ade2a7b3abcbbf43fc5b72b))
 * Flatpak install REX template assumes presence of the optional remote name input ([#38149](https://projects.theforeman.org/issues/38149))
 * content_view_environments methods need to be added to Safemode ([#38142](https://projects.theforeman.org/issues/38142), [614ec0b7](https://github.com/Katello/katello.git/commit/614ec0b74057e5c418524343994403a457a65f3b))
 * Job: Resolve Traces - Katello Ansible Default - fails to reboot machine ([#38140](https://projects.theforeman.org/issues/38140), [c988a004](https://github.com/Katello/katello.git/commit/c988a004a54587ef615b2593741afae28ef8897b))
 * Do not double-escape "*" during package update ([#38137](https://projects.theforeman.org/issues/38137), [fcd6cdb8](https://github.com/Katello/katello.git/commit/fcd6cdb830fe3a77c342752203cd2f9af618c688))
 * Image mode digests should be allowed to be empty ([#38128](https://projects.theforeman.org/issues/38128), [dfa1ec8b](https://github.com/Katello/katello.git/commit/dfa1ec8b2d28bb2ea0498308b3801f51fcdb2d76))
 * Change content source & REX Pull provider ([#38111](https://projects.theforeman.org/issues/38111), [fb274faa](https://github.com/Katello/katello.git/commit/fb274faa08ac4745420172a01b73d6006e0aa0f0))
 * In host/groups media should not be visible when Synced Content is selected ([#38104](https://projects.theforeman.org/issues/38104), [469efd5b](https://github.com/Katello/katello.git/commit/469efd5b76f78869fdc92d442853315678ea77e9))
 * As a user, I can see an overview of container images used with image-mode systems via API & hammer ([#38072](https://projects.theforeman.org/issues/38072), [ec7ef5c7](https://github.com/Katello/katello.git/commit/ec7ef5c70fd68e865a580ef498bbda2909728cdc))

### Repositories
 * APT repos using flat repo format with a distribution other than "/" are broken ([#38221](https://projects.theforeman.org/issues/38221), [6db53865](https://github.com/Katello/katello.git/commit/6db538659a93349c0bc63419d78769416ed963a7))
 * Http proxy is referenced in postgres even after being removed from the Satellite server ([#38204](https://projects.theforeman.org/issues/38204), [63404582](https://github.com/Katello/katello.git/commit/6340458228aa063ef1b24a1f01f119d97f01ef26))
 * Sync Status page Select None not working ([#38196](https://projects.theforeman.org/issues/38196), [0b6754eb](https://github.com/Katello/katello.git/commit/0b6754eb04a2bdd7f44bbeb1219448079e57ad60))
 * The "Synchronize Now" button within Sync Status page of Satellite WebUI does not perform any visible action when the associated Content View is being published ([#38188](https://projects.theforeman.org/issues/38188), [5b40dfee](https://github.com/Katello/katello.git/commit/5b40dfeeb39bf979a9042f01769368dfc0251aa6))
 * Flatpak rex templates don't appear in order ([#38180](https://projects.theforeman.org/issues/38180), [b959a021](https://github.com/Katello/katello.git/commit/b959a021014e936a815a67641e7b1b86e5c4dbc6), [1ce9c222](https://github.com/Katello/katello.git/commit/1ce9c2220e06b161b16cd99e416f9daa9e85c9fb))
 * Add RHEL 10 to repo version restriction logic. ([#38158](https://projects.theforeman.org/issues/38158), [5f06aa56](https://github.com/Katello/katello.git/commit/5f06aa5615cf52176cf848b57594dc2fbc964afb))
 * Products index page is slow for products that have no synced repositories ([#38086](https://projects.theforeman.org/issues/38086), [27e2ec4b](https://github.com/Katello/katello.git/commit/27e2ec4b3f4409953c76c766c57a52347ee80ce1))
 * Using deb content filters with structured APT enabled breaks repo publications ([#38061](https://projects.theforeman.org/issues/38061), [f5f8f4f5](https://github.com/Katello/katello.git/commit/f5f8f4f56120ee21ddbd497004c4575bf9f2f5eb))
 * Show URL to GPG Key ([#38038](https://projects.theforeman.org/issues/38038), [34d7f9c2](https://github.com/Katello/katello.git/commit/34d7f9c29706f1a6877c350cbb25a3dac5b715c9))
 * Upload deb package through hammer may not add it publication ([#38035](https://projects.theforeman.org/issues/38035), [7150ba28](https://github.com/Katello/katello.git/commit/7150ba2810f30e6548ee51810654168af80c04ed))
 * [DEV] Add RHEL 10 repos to recommended repositories (after 4.15 branching) ([#38020](https://projects.theforeman.org/issues/38020), [45510db1](https://github.com/Katello/katello.git/commit/45510db1b72bb32c0e94dca92d205fbda2adadbf))
 * Errors while deleting repository from Katello: Unable to find content with the ID "XXXX" ([#37600](https://projects.theforeman.org/issues/37600), [fae84712](https://github.com/Katello/katello.git/commit/fae847127ac78a38e0bbf2da98d804add0674746))
 * Python Package Types don't filter out whitespace ([#35676](https://projects.theforeman.org/issues/35676), [155aa5b4](https://github.com/Katello/katello.git/commit/155aa5b4629131563aa74eea3aede9df794c65e1))

### Container
 * Container push should hide expected 404 message from pulp when looking up blobs ([#38212](https://projects.theforeman.org/issues/38212), [e2be2fbb](https://github.com/Katello/katello.git/commit/e2be2fbb245d5c03d26b04e7c77d150b22159ad7))
 * OSP Authenticated Pull fails from Satellite with error 422 Client Error: Unprocessable Content for url ([#38206](https://projects.theforeman.org/issues/38206), [86ea51ec](https://github.com/Katello/katello.git/commit/86ea51ec575416b788ce5c3b08843cde8562e25b))
 * As a user, I can see an overview of container images used with image-mode systems in the UI ([#38107](https://projects.theforeman.org/issues/38107), [775218f4](https://github.com/Katello/katello.git/commit/775218f4444e8c3513149d58dc7c2b8f26fab9d0))

### Errata Management
 * 'Select all' on errata page attempts installing extra errata on host ([#38175](https://projects.theforeman.org/issues/38175), [002a5436](https://github.com/Katello/katello.git/commit/002a5436b5d67fefc36fc97351f5cab5e33dc3b7))
 * Argument list too long in "Install errata by search query - Katello Ansible Default" when applying multiple errata ([#38163](https://projects.theforeman.org/issues/38163), [e6f6e436](https://github.com/Katello/katello.git/commit/e6f6e436736be0e06a358941f0a6a59f144fe7be))
 * Content view with include errata filter has fewer package count than expected ([#37946](https://projects.theforeman.org/issues/37946), [68b1db34](https://github.com/Katello/katello.git/commit/68b1db34593597d77dbba126a53dbec2d3aa4fa3))

### Foreman Proxy Content
 * Drop EL8 builds from container_gateway plugin ([#38148](https://projects.theforeman.org/issues/38148), [ab847a2f](https://github.com/Katello/smart_proxy_container_gateway.git/commit/ab847a2f4a4760369ff28646154d39c9f8b9ac8a))
 * Flatpak client unable to do authenticated pull from smart proxy ([#38144](https://projects.theforeman.org/issues/38144), [1e58f202](https://github.com/Katello/smart_proxy_container_gateway.git/commit/1e58f202b1e4bc26435a4a7ff430d4fc6457bfa5))
 * Smart proxy sync is not updating package count for repos inside content view. ([#38117](https://projects.theforeman.org/issues/38117), [fb6cca70](https://github.com/Katello/katello.git/commit/fb6cca703783c443c4a4f4a368f8d5fe1072c20e))
 * APT repos using flat repo format cannot be synced to smart proxy ([#38096](https://projects.theforeman.org/issues/38096), [cf57e554](https://github.com/Katello/katello.git/commit/cf57e55407a6437fea6c540ae5578c6fc687d77f))
 * LCE id is not passed on Refresh counts trigger from WebUI ([#38042](https://projects.theforeman.org/issues/38042), [951fb57a](https://github.com/Katello/katello.git/commit/951fb57a3786fe1e45674166d07841c96691964d))
 * Update smart proxy url methods for load balancer compatibility ([#38028](https://projects.theforeman.org/issues/38028), [02b80790](https://github.com/Katello/katello.git/commit/02b80790d46c6b2a9c1c0ae06417f7a30ac5390a), [7ba19bd7](https://github.com/Katello/katello.git/commit/7ba19bd7beb24d8f01fa90c3635bebf406e38aab))
 * Ansible collection capsule sync doesn't respect optimized:false value ([#37959](https://projects.theforeman.org/issues/37959), [62f5a5c3](https://github.com/Katello/katello.git/commit/62f5a5c3d24f0631df15b1842d949df35805d4eb))

### Lifecycle Environments
 * Hammer should provide the option to add an environment after Library to an existing path ([#38114](https://projects.theforeman.org/issues/38114), [dbfa2ef5](https://github.com/Katello/katello.git/commit/dbfa2ef50c46faade2d44a320957db69637d51f8))
 * Display LCEs in order of LCE Path in GUI CV Page and hammer for Content View  ([#38112](https://projects.theforeman.org/issues/38112), [d632f76c](https://github.com/Katello/katello.git/commit/d632f76c298fa806dc00ccbad58d6d60ad304b97))

### API
 * Flatpak remote returns auth_token on the API ([#38102](https://projects.theforeman.org/issues/38102), [1891dc42](https://github.com/Katello/katello.git/commit/1891dc425a285f006affc6922fcd7be976f17f88))

### Web UI
 * Deb Packages page shows empty on Content Views tab ([#38069](https://projects.theforeman.org/issues/38069), [f3402e04](https://github.com/Katello/katello.git/commit/f3402e04e93425adad3dcfad47278ee83d5f951d))
 * Do not tranlsate links in toasts ([#38047](https://projects.theforeman.org/issues/38047), [58f2eda0](https://github.com/Katello/katello.git/commit/58f2eda0fe20af3ec07d32b6384f4dfed2bde738))

### Hammer
 * Remove syspurpose addons from hammer ([#38065](https://projects.theforeman.org/issues/38065), [b45e4347](https://github.com/Katello/hammer-cli-katello.git/commit/b45e43470a31de6c17b1f941f9af4a007cd23a7e))
 * Add full GPG Key URL to hammer repo info ([#38054](https://projects.theforeman.org/issues/38054), [93d8f615](https://github.com/Katello/hammer-cli-katello.git/commit/93d8f615e2c1dc3f5154cc82a608198b7a549e6c))
 * undefined method error for hammer capsule content info ([#38014](https://projects.theforeman.org/issues/38014), [ff599e19](https://github.com/Katello/hammer-cli-katello.git/commit/ff599e19b305d43e281d29a49ff334e48785dee3))

### Tooling
 * Get rid of evr extension and recreate evr_t in katello ([#37859](https://projects.theforeman.org/issues/37859), [a153d942](https://github.com/Katello/katello.git/commit/a153d9423d6f4555dc55575c3e5b859b9aecf2fd), [b551d41d](https://github.com/Katello/katello.git/commit/b551d41d853d53e5f753b6ac609bb956f46295fe))

### Subscriptions
 * hammer allows creation of content overrides other than 'enabled' ([#37151](https://projects.theforeman.org/issues/37151), [8d3c4c78](https://github.com/Katello/hammer-cli-katello.git/commit/8d3c4c783e68df896888d975c2001b3329d7f383), [49bffbb7](https://github.com/Katello/hammer-cli-katello.git/commit/49bffbb7a2e0145950c8fe66a1f26f7435a50614))

### Other
 * Update Recommeneded Repositories Page to modify Satellite, Capsule and Maintainance repository from 6.16 to 6.17 for RHEL 9 ([#38261](https://projects.theforeman.org/issues/38261), [3252bf73](https://github.com/Katello/katello.git/commit/3252bf739d4c54fefa17d871b0155e4f21715a5d))
 * Humanize Resource Type for flatpak permissions ([#38161](https://projects.theforeman.org/issues/38161), [a30fb411](https://github.com/Katello/katello.git/commit/a30fb41138771f56451ef2601ad578dd984559a8))
 * deb type content host with structured APT enabled throws errors on repository sets tab ([#37998](https://projects.theforeman.org/issues/37998), [efd860b8](https://github.com/Katello/katello.git/commit/efd860b84b7ac8395dac7599bbad64d289ada363))
 * As a user, I can expect container repo names to follow the latest standard ([#37988](https://projects.theforeman.org/issues/37988), [9c985331](https://github.com/Katello/katello.git/commit/9c985331886f51ed79241796e5aaf87609c9f1f7))
