# 4.14.0 Gold Road (2024-09-17)

## Features

### Hosts
 * Change All Hosts kebab menu to match mockup ([#37674](https://projects.theforeman.org/issues/37674), [57ca5858](https://github.com/Katello/katello.git/commit/57ca58580a99fae650104efdc4c6615782f02a15))
 * Set default templates for Debian/Suse based systems ([#37416](https://projects.theforeman.org/issues/37416), [bc07be6c](https://github.com/Katello/katello.git/commit/bc07be6c5c010e9b846da62a17f40cbfd34e791f))
 * As a web UI user, I can select multiple hosts and install or update packages via REX ([#37347](https://projects.theforeman.org/issues/37347), [38e1e4d2](https://github.com/Katello/katello.git/commit/38e1e4d22ab2472062e06c6fc42974c104ed2034))

### API
 * Add Hammer & API support for host multi-CV ([#37669](https://projects.theforeman.org/issues/37669), [9d324e4e](https://github.com/Katello/katello.git/commit/9d324e4e680bfff3724b2f1d55028385d1f1705a))

### Errata Management
 * Use custom snippets during Errata Installation ([#37654](https://projects.theforeman.org/issues/37654), [2064ec74](https://github.com/Katello/katello.git/commit/2064ec7457b3d41b72c2d48b7df9371f8b09d053))

### Repositories
 * Stop users from editing container push repositories ([#37634](https://projects.theforeman.org/issues/37634), [00aa4323](https://github.com/Katello/katello.git/commit/00aa4323fd06b33a130c3d953f9a28c7cd48e0cb))
 * Add Include Refs and Exclude Refs options for OSTree repository type ([#37383](https://projects.theforeman.org/issues/37383), [846b651f](https://github.com/Katello/katello.git/commit/846b651f0675a8100540bcd8fce86eeaf0526adb))

### Tooling
 * Upgrade pulp-rpm to 3.26 ([#37622](https://projects.theforeman.org/issues/37622), [451854b1](https://github.com/Katello/katello.git/commit/451854b1ea7cf9d3377ac849d358fe46bf6775e1))

### Host Collections
 * Host Collections widget should respect the errata_status_installable setting ([#37288](https://projects.theforeman.org/issues/37288), [02a207b0](https://github.com/Katello/katello.git/commit/02a207b09c5bd3fb1a65a17428b72f2c221ab2f6))

### Other
 * [RFE] Request to have the view 'Restrict to architecture", 'Restrict to OS version', and 'Always update to latest version' with hammer ([#37232](https://projects.theforeman.org/issues/37232), [e1b107b8](https://github.com/Katello/hammer-cli-katello.git/commit/e1b107b8ed3c9c362ae5f5a8a6debbb7ac6793af))

## Bug Fixes

### Hosts
 * Registration without environments or environment_id param causes NoMethodError ([#37829](https://projects.theforeman.org/issues/37829))
 * Large table titles show in All Hosts wizards ([#37788](https://projects.theforeman.org/issues/37788), [c8848498](https://github.com/Katello/katello.git/commit/c884849809cba09d96a7d50cfb1185404f345a89))
 * Remove packages list can be missing some removable packages ([#37784](https://projects.theforeman.org/issues/37784), [f033452b](https://github.com/Katello/katello.git/commit/f033452b43570e4233e767f6f6935e8a8fe9f22c))
 * Banner text on Repository sets screen needs updating for multi-CV ([#37771](https://projects.theforeman.org/issues/37771), [0e3c2b0c](https://github.com/Katello/katello.git/commit/0e3c2b0c354bed29188f540eb5fe213180ffb1f1))
 * Using the "Select All" checkbox on All Hosts Errata and Package pages throws an error ([#37762](https://projects.theforeman.org/issues/37762), [8cd215e1](https://github.com/Katello/katello.git/commit/8cd215e1158c51ec13064c2c930f8231aef20be4))
 * Remote execution controller still uses old job invocation form ([#37728](https://projects.theforeman.org/issues/37728), [01caca03](https://github.com/Katello/katello.git/commit/01caca0350c540b38aa2441078b08c8c1bde3538))
 * Content source is changed to wrong proxy if you simply press the submit button on the host page ([#37709](https://projects.theforeman.org/issues/37709), [c98aede1](https://github.com/Katello/katello.git/commit/c98aede1e5c41fecc63112c2cf0792b6a63d390a))
 * Host update failure: param is missing or the value is empty: content_facet_attributes ([#37704](https://projects.theforeman.org/issues/37704), [98555b66](https://github.com/Katello/katello.git/commit/98555b66802f01bba7e1a07b5cc4c709f57a37ef))
 * Convert2rhel env facts are getting filtered due to env ethernet regex ([#37696](https://projects.theforeman.org/issues/37696), [4bd1489e](https://github.com/Katello/katello.git/commit/4bd1489e3c60406cb113683bdc47a37260ca66e6), [763e72dc](https://github.com/Katello/katello.git/commit/763e72dc95351bd4b7d00dc04126a84555b42e21))
 * 'TypeError: getCustomizedRexUrl is not a function' when you go to Review step in Packages wizard ([#37684](https://projects.theforeman.org/issues/37684), [6ba14f8c](https://github.com/Katello/katello.git/commit/6ba14f8c13bacca6d77663b9d2697e4c547318a5))
 * Multiple environments can be assigned to a host even if setting should prevent it ([#37657](https://projects.theforeman.org/issues/37657), [d207d35d](https://github.com/Katello/katello.git/commit/d207d35dee2c45826377a8a1f52983ef45c61461))
 * Don't clear KS repo when  reregistering host ([#37599](https://projects.theforeman.org/issues/37599), [4769f932](https://github.com/Katello/katello.git/commit/4769f93204da25b928febf936ab49716547e361f))
 * @host nil error with kickstart_repository_id when creating host ([#37544](https://projects.theforeman.org/issues/37544), [16440c39](https://github.com/Katello/katello.git/commit/16440c3907d6b1f64c6edc2a2dedc213085436e0))

### Foreman Proxy Content
 * If a smart proxy sync task fails in plan, for_resource helper does not work ([#37820](https://projects.theforeman.org/issues/37820), [2caec803](https://github.com/Katello/katello.git/commit/2caec8035c201f85aa0600f03404eb48649f2582))
 * Block users from pushing content to container gateway ([#37661](https://projects.theforeman.org/issues/37661), [d74a50f9](https://github.com/Katello/smart_proxy_container_gateway.git/commit/d74a50f9b994d7ac701fff5ca84a494c7ee6d2d4))
 * Smart Proxy referred to as "proxy" in settings ([#37656](https://projects.theforeman.org/issues/37656), [cf5e05dd](https://github.com/Katello/katello.git/commit/cf5e05dd6b05908c232bf1160e5c34dafe113e3e))

### Roles and Permissions
 * Improve the error message when listing/viewing capsules via API w/o permissions ([#37816](https://projects.theforeman.org/issues/37816), [640ef717](https://github.com/Katello/katello.git/commit/640ef71793eeb22d24886e936fede46498632ae6))
 * Improve the error message when listing/viewing capsules via API w/o permissions ([#37555](https://projects.theforeman.org/issues/37555), [b6169e40](https://github.com/Katello/katello.git/commit/b6169e40997e4b756708333d21379378dfffa68b))

### Content Credentials
 * Unable to load gpg key using downloaded key file ([#37804](https://projects.theforeman.org/issues/37804), [9a6a7a09](https://github.com/Katello/katello.git/commit/9a6a7a09c9eb4fd5b572ccb5da7a44982e281572))

### Repositories
 * Pagination broken on Redhat repos page and generic content tables ([#37777](https://projects.theforeman.org/issues/37777), [f79911ee](https://github.com/Katello/katello.git/commit/f79911ee1d790ada6e2c63abc50c0540a19ef430))
 * Upload file section doesn't hide "Upload Package" for file repos ([#37736](https://projects.theforeman.org/issues/37736), [9de6410a](https://github.com/Katello/katello.git/commit/9de6410a959b402085db768580d29fb49de7a386))
 * "Remove Repositories" button not shown for non-admin users with "destroy_repositories" permission ([#37732](https://projects.theforeman.org/issues/37732), [e9cac28f](https://github.com/Katello/katello.git/commit/e9cac28f641eb2349ac923c73d0f66fcd8a46dea))
 * [DEV] links from package details page incorrectly parse plus signs ([#37722](https://projects.theforeman.org/issues/37722), [a56b8b94](https://github.com/Katello/katello.git/commit/a56b8b946086d78791c78c442c843883a329fb2c))
 * Previous sha1 repo stays sha1 when changed to Default ([#37715](https://projects.theforeman.org/issues/37715), [06dacfb7](https://github.com/Katello/katello.git/commit/06dacfb7285d6dd73ef6371296b71c540220394f))
 * [DEV] When having connection issue, scan CDN always fail silently and return empty result which is hard to debug ([#37697](https://projects.theforeman.org/issues/37697), [0f7c58fd](https://github.com/Katello/katello.git/commit/0f7c58fd9a1f9dd6ee34ea2c3ffd76f99c86fddc))
 * [DEV] Remove container push setting necessity ([#37668](https://projects.theforeman.org/issues/37668), [4d86e130](https://github.com/Katello/katello.git/commit/4d86e130079a3bd482dd00a7ccc6b6b57b4c4c32))
 * Publish container push repositories in content views ([#37552](https://projects.theforeman.org/issues/37552), [72467400](https://github.com/Katello/katello.git/commit/72467400bca2aa658f422f4de79be927ad92c58c))
 * /katello/sync_management tries to use /assets/spinner.gif but that's 404 ([#37133](https://projects.theforeman.org/issues/37133), [c989e46e](https://github.com/Katello/katello.git/commit/c989e46e3c7d9c9741544bea1ac5431f2e95bcd7))

### Content Views
 * Pagination component navigation within content view details pages does not function properly ([#37760](https://projects.theforeman.org/issues/37760), [c2146ecf](https://github.com/Katello/katello.git/commit/c2146ecf082d94232a646a8e69315b57f0cea74b))
 * Content import task failed indexing errata from Pulp ([#37549](https://projects.theforeman.org/issues/37549), [36b0d00b](https://github.com/Katello/katello.git/commit/36b0d00b283854d85300cc1473de910271793aa7))
 * Removing CV error's with "Cannot delete record because of dependent content_facet"  ([#37538](https://projects.theforeman.org/issues/37538), [d39fb368](https://github.com/Katello/katello.git/commit/d39fb3688dc887e20a76304b6bf9657ff531c210))

### Hammer
 * Hammer erratum list output is wrong when using content-view filter ([#37721](https://projects.theforeman.org/issues/37721), [a7824846](https://github.com/Katello/hammer-cli-katello.git/commit/a7824846f284eb836311776e269635e49df7e606))

### Container
 * Limit v1 search to v1 container clients on Capsule ([#37705](https://projects.theforeman.org/issues/37705), [28fcc521](https://github.com/Katello/smart_proxy_container_gateway.git/commit/28fcc52189a85a5ca484cebea3b1e494cd71bc9c))

### Tooling
 * Trying to reset katello devel box, shows warning ([#37666](https://projects.theforeman.org/issues/37666), [8fed606f](https://github.com/Katello/katello.git/commit/8fed606fdc2bcd783a8e875aef43273e686c80e5))

### Inter Server Sync
 * Unable to import cvv export on RHEL 9 ([#37598](https://projects.theforeman.org/issues/37598), [ace28c6e](https://github.com/Katello/katello.git/commit/ace28c6e8520dc37bf746ecbfa9b01eb5013d3b7))

### API
 * --content-view-filter-id only works for ID-type filters ([#37394](https://projects.theforeman.org/issues/37394), [aa14f84e](https://github.com/Katello/katello.git/commit/aa14f84e03fe5d10ab8863fd8e9212102eb0c711))

### Reporting
 * Move Ansible-based job templates to "Katello via Ansible" ([#37362](https://projects.theforeman.org/issues/37362), [0e25591b](https://github.com/Katello/katello.git/commit/0e25591bec9bb0b1abcf767e56abee20f5fd3ce2))

### Web UI
 * Change content source screen is still confusing coming from host edit ([#37313](https://projects.theforeman.org/issues/37313), [737a6f2e](https://github.com/Katello/katello.git/commit/737a6f2e0c999e63312c6ed88cf75b1e9ffd6342))

### Alternate Content Sources
 * ACS - throw proper errors for ULN ACS URLs ([#35582](https://projects.theforeman.org/issues/35582), [81493d3d](https://github.com/Katello/katello.git/commit/81493d3d725f39795ddf44c1bf85b091f5dfcbef))

### Other
 * Down migration in AddConvert2rhelToHostFacets has wrong table name for subscription facets ([#37815](https://projects.theforeman.org/issues/37815), [8d378f3a](https://github.com/Katello/katello.git/commit/8d378f3a6cd46ef31ba2d65d3d3f90ff670ec104))
 * Container push sometimes makes duplicate repos due to race condition ([#37785](https://projects.theforeman.org/issues/37785), [326474f5](https://github.com/Katello/katello.git/commit/326474f524ed4177e079bfc17e57f31e8243d296))
 * Deleting published repos from product page doesn't work right ([#37782](https://projects.theforeman.org/issues/37782), [cb67ea57](https://github.com/Katello/katello.git/commit/cb67ea578b884226838da48f86fd493a6b68a600))
 * Use :default_location_subscribed_hosts in registration ([#37703](https://projects.theforeman.org/issues/37703), [47ebea17](https://github.com/Katello/katello.git/commit/47ebea176a4e2e1faf20a44c29dd9974f4ed9b5f))
 * Pagination within Packages wizard is wonky ([#37587](https://projects.theforeman.org/issues/37587), [baa05125](https://github.com/Katello/katello.git/commit/baa05125680662c2742f20fce306a20319e99824))
 * Cannot update packages on non-EL hosts ([#37340](https://projects.theforeman.org/issues/37340), [0cb7253f](https://github.com/Katello/katello.git/commit/0cb7253f929ecd8c4b2e0def8308cfa55f6c9704))
 * Default Organization View is not listed first on the CV select screen in Change Content Source ([#37229](https://projects.theforeman.org/issues/37229), [2b522d0b](https://github.com/Katello/katello.git/commit/2b522d0bf9232cfdeb57841e52a943ae2b9404ea))
# 4.14.0 Gold Road (2024-08-20)

## Features

### Hosts
 * Change All Hosts kebab menu to match mockup ([#37674](https://projects.theforeman.org/issues/37674), [57ca5858](https://github.com/Katello/katello.git/commit/57ca58580a99fae650104efdc4c6615782f02a15))
 * Set default templates for Debian/Suse based systems ([#37416](https://projects.theforeman.org/issues/37416), [bc07be6c](https://github.com/Katello/katello.git/commit/bc07be6c5c010e9b846da62a17f40cbfd34e791f))
 * As a web UI user, I can select multiple hosts and install or update packages via REX ([#37347](https://projects.theforeman.org/issues/37347), [38e1e4d2](https://github.com/Katello/katello.git/commit/38e1e4d22ab2472062e06c6fc42974c104ed2034))

### API
 * Add Hammer & API support for host multi-CV ([#37669](https://projects.theforeman.org/issues/37669), [9d324e4e](https://github.com/Katello/katello.git/commit/9d324e4e680bfff3724b2f1d55028385d1f1705a))

### Repositories
 * Stop users from editing container push repositories ([#37634](https://projects.theforeman.org/issues/37634), [00aa4323](https://github.com/Katello/katello.git/commit/00aa4323fd06b33a130c3d953f9a28c7cd48e0cb))
 * Add Include Refs and Exclude Refs options for OSTree repository type ([#37383](https://projects.theforeman.org/issues/37383), [846b651f](https://github.com/Katello/katello.git/commit/846b651f0675a8100540bcd8fce86eeaf0526adb))

### Tooling
 * Upgrade pulp-rpm to 3.26 ([#37622](https://projects.theforeman.org/issues/37622), [451854b1](https://github.com/Katello/katello.git/commit/451854b1ea7cf9d3377ac849d358fe46bf6775e1))

### Host Collections
 * Host Collections widget should respect the errata_status_installable setting ([#37288](https://projects.theforeman.org/issues/37288), [02a207b0](https://github.com/Katello/katello.git/commit/02a207b09c5bd3fb1a65a17428b72f2c221ab2f6))

### Other
 * Use custom snippets during Errata Installation ([#37654](https://projects.theforeman.org/issues/37654), [2064ec74](https://github.com/Katello/katello.git/commit/2064ec7457b3d41b72c2d48b7df9371f8b09d053))
 * [RFE] Request to have the view 'Restrict to architecture", 'Restrict to OS version', and 'Always update to latest version' with hammer ([#37232](https://projects.theforeman.org/issues/37232), [e1b107b8](https://github.com/Katello/hammer-cli-katello.git/commit/e1b107b8ed3c9c362ae5f5a8a6debbb7ac6793af))

## Bug Fixes

### Repositories
 * Upload file section doesn't hide "Upload Package" for file repos ([#37736](https://projects.theforeman.org/issues/37736), [9de6410a](https://github.com/Katello/katello.git/commit/9de6410a959b402085db768580d29fb49de7a386))
 * [DEV] links from package details page incorrectly parse plus signs ([#37722](https://projects.theforeman.org/issues/37722), [a56b8b94](https://github.com/Katello/katello.git/commit/a56b8b946086d78791c78c442c843883a329fb2c))
 * Previous sha1 repo stays sha1 when changed to Default ([#37715](https://projects.theforeman.org/issues/37715), [06dacfb7](https://github.com/Katello/katello.git/commit/06dacfb7285d6dd73ef6371296b71c540220394f))
 * [DEV] When having connection issue, scan CDN always fail silently and return empty result which is hard to debug ([#37697](https://projects.theforeman.org/issues/37697), [0f7c58fd](https://github.com/Katello/katello.git/commit/0f7c58fd9a1f9dd6ee34ea2c3ffd76f99c86fddc))
 * [DEV] Remove container push setting necessity ([#37668](https://projects.theforeman.org/issues/37668), [4d86e130](https://github.com/Katello/katello.git/commit/4d86e130079a3bd482dd00a7ccc6b6b57b4c4c32))
 * Publish container push repositories in content views ([#37552](https://projects.theforeman.org/issues/37552), [72467400](https://github.com/Katello/katello.git/commit/72467400bca2aa658f422f4de79be927ad92c58c))

### Hammer
 * Hammer erratum list output is wrong when using content-view filter ([#37721](https://projects.theforeman.org/issues/37721), [a7824846](https://github.com/Katello/hammer-cli-katello.git/commit/a7824846f284eb836311776e269635e49df7e606))

### Hosts
 * Content source is changed to wrong proxy if you simply press the submit button on the host page ([#37709](https://projects.theforeman.org/issues/37709), [c98aede1](https://github.com/Katello/katello.git/commit/c98aede1e5c41fecc63112c2cf0792b6a63d390a))
 * Host update failure: param is missing or the value is empty: content_facet_attributes ([#37704](https://projects.theforeman.org/issues/37704), [98555b66](https://github.com/Katello/katello.git/commit/98555b66802f01bba7e1a07b5cc4c709f57a37ef))
 * Convert2rhel env facts are getting filtered due to env ethernet regex ([#37696](https://projects.theforeman.org/issues/37696), [4bd1489e](https://github.com/Katello/katello.git/commit/4bd1489e3c60406cb113683bdc47a37260ca66e6), [763e72dc](https://github.com/Katello/katello.git/commit/763e72dc95351bd4b7d00dc04126a84555b42e21))
 * 'TypeError: getCustomizedRexUrl is not a function' when you go to Review step in Packages wizard ([#37684](https://projects.theforeman.org/issues/37684), [6ba14f8c](https://github.com/Katello/katello.git/commit/6ba14f8c13bacca6d77663b9d2697e4c547318a5))
 * Don't clear KS repo when  reregistering host ([#37599](https://projects.theforeman.org/issues/37599), [4769f932](https://github.com/Katello/katello.git/commit/4769f93204da25b928febf936ab49716547e361f))
 * @host nil error with kickstart_repository_id when creating host ([#37544](https://projects.theforeman.org/issues/37544), [16440c39](https://github.com/Katello/katello.git/commit/16440c3907d6b1f64c6edc2a2dedc213085436e0))

### Container
 * Limit v1 search to v1 container clients on Capsule ([#37705](https://projects.theforeman.org/issues/37705), [28fcc521](https://github.com/Katello/smart_proxy_container_gateway.git/commit/28fcc52189a85a5ca484cebea3b1e494cd71bc9c))

### Tooling
 * Trying to reset katello devel box, shows warning ([#37666](https://projects.theforeman.org/issues/37666), [8fed606f](https://github.com/Katello/katello.git/commit/8fed606fdc2bcd783a8e875aef43273e686c80e5))

### Foreman Proxy Content
 * Block users from pushing content to container gateway ([#37661](https://projects.theforeman.org/issues/37661), [d74a50f9](https://github.com/Katello/smart_proxy_container_gateway.git/commit/d74a50f9b994d7ac701fff5ca84a494c7ee6d2d4))

### Inter Server Sync
 * Unable to import cvv export on RHEL 9 ([#37598](https://projects.theforeman.org/issues/37598), [ace28c6e](https://github.com/Katello/katello.git/commit/ace28c6e8520dc37bf746ecbfa9b01eb5013d3b7))

### Roles and Permissions
 * Improve the error message when listing/viewing capsules via API w/o permissions ([#37555](https://projects.theforeman.org/issues/37555), [b6169e40](https://github.com/Katello/katello.git/commit/b6169e40997e4b756708333d21379378dfffa68b))

### Content Views
 * Content import task failed indexing errata from Pulp ([#37549](https://projects.theforeman.org/issues/37549), [36b0d00b](https://github.com/Katello/katello.git/commit/36b0d00b283854d85300cc1473de910271793aa7))
 * Removing CV error's with "Cannot delete record because of dependent content_facet"  ([#37538](https://projects.theforeman.org/issues/37538), [d39fb368](https://github.com/Katello/katello.git/commit/d39fb3688dc887e20a76304b6bf9657ff531c210))

### API
 * --content-view-filter-id only works for ID-type filters ([#37394](https://projects.theforeman.org/issues/37394), [aa14f84e](https://github.com/Katello/katello.git/commit/aa14f84e03fe5d10ab8863fd8e9212102eb0c711))

### Reporting
 * Move Ansible-based job templates to "Katello via Ansible" ([#37362](https://projects.theforeman.org/issues/37362), [0e25591b](https://github.com/Katello/katello.git/commit/0e25591bec9bb0b1abcf767e56abee20f5fd3ce2))

### Web UI
 * Change content source screen is still confusing coming from host edit ([#37313](https://projects.theforeman.org/issues/37313), [737a6f2e](https://github.com/Katello/katello.git/commit/737a6f2e0c999e63312c6ed88cf75b1e9ffd6342))

### Alternate Content Sources
 * ACS - throw proper errors for ULN ACS URLs ([#35582](https://projects.theforeman.org/issues/35582), [81493d3d](https://github.com/Katello/katello.git/commit/81493d3d725f39795ddf44c1bf85b091f5dfcbef))

### Other
 * Multiple environments can be assigned to a host even if setting should prevent it ([#37657](https://projects.theforeman.org/issues/37657), [d207d35d](https://github.com/Katello/katello.git/commit/d207d35dee2c45826377a8a1f52983ef45c61461))
 * Smart Proxy referred to as "proxy" in settings ([#37656](https://projects.theforeman.org/issues/37656), [cf5e05dd](https://github.com/Katello/katello.git/commit/cf5e05dd6b05908c232bf1160e5c34dafe113e3e))
 * Cannot update packages on non-EL hosts ([#37340](https://projects.theforeman.org/issues/37340), [0cb7253f](https://github.com/Katello/katello.git/commit/0cb7253f929ecd8c4b2e0def8308cfa55f6c9704))
 * Default Organization View is not listed first on the CV select screen in Change Content Source ([#37229](https://projects.theforeman.org/issues/37229), [2b522d0b](https://github.com/Katello/katello.git/commit/2b522d0bf9232cfdeb57841e52a943ae2b9404ea))
