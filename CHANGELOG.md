# 4.18.0 Vessel (2025-08-13)

## Features

### Repositories
 * Add flatpak remote actions to Remote details page ([#38596](https://projects.theforeman.org/issues/38596), [7b75c70e](https://github.com/Katello/katello.git/commit/7b75c70e1076e9603ee8963f477d3ab2965e4314))
 * Add a scan action on the flatpak remote table ([#38595](https://projects.theforeman.org/issues/38595), [c9823ed7](https://github.com/Katello/katello.git/commit/c9823ed732d929c8d3e40243c4103d283a522744))
 * Add edit action to flatpak remotes page ([#38590](https://projects.theforeman.org/issues/38590), [447fe8fe](https://github.com/Katello/katello.git/commit/447fe8fe5272fbd5321c26de9900388fa51e0df8))
 * Add a create button to the flatpak remotes page ([#38562](https://projects.theforeman.org/issues/38562), [ad5a59a0](https://github.com/Katello/katello.git/commit/ad5a59a09797ab6875ab7fa8452047e48ea8cac9))

### Web UI
 * Support delete action on the remote table row ([#38588](https://projects.theforeman.org/issues/38588), [d1df7b10](https://github.com/Katello/katello.git/commit/d1df7b10c7db70613c6a7570a0d9d8298cb4a8e2))

### Foreman Proxy Content
 * As a registered host, I don't need to podman login to access flatpak index on the capsule. ([#38572](https://projects.theforeman.org/issues/38572), [b27aa973](https://github.com/Katello/smart_proxy_container_gateway.git/commit/b27aa973f1c0411ed4ae3f8dca24cfb36f3ce77d))
 * Cert auth for capsule - Maintain host-repo mapping on capsule ([#38514](https://projects.theforeman.org/issues/38514), [422dc798](https://github.com/Katello/smart_proxy_container_gateway.git/commit/422dc7984fd31ebc1a06110ae3ed3e699173251c), [5cbd30cd](https://github.com/Katello/katello.git/commit/5cbd30cde48dbd922ea4a27d920233bb80cd1887))

### Container
 * Add mirror action with a small form that selects product to mirror into ([#38537](https://projects.theforeman.org/issues/38537), [2f5a8e19](https://github.com/Katello/katello.git/commit/2f5a8e19750ffaae2b3b4509f5fe857291bc3fa7))
 * REX job template: As a user, I can easily setup certs in the /etc/containers/certs.d/hostname/ directory ([#38457](https://projects.theforeman.org/issues/38457), [40d2bb6b](https://github.com/Katello/katello.git/commit/40d2bb6bf6fd574c31cf89043d5988ff19933848))
 * Implement cert auth for flatpak index ([#38421](https://projects.theforeman.org/issues/38421), [c8e783ca](https://github.com/Katello/katello.git/commit/c8e783ca8e401b8dedf89c4852a8f0d9f8f41308))
 * As a registered host, I don't need to podman login to access container repositories on katello ([#38407](https://projects.theforeman.org/issues/38407), [e2db0a44](https://github.com/Katello/katello.git/commit/e2db0a444e281673db51eee49ed60f676e268dc0))
 * Add container upstream name to repository listing API endpoint ([#38392](https://projects.theforeman.org/issues/38392), [fcf06f77](https://github.com/Katello/katello.git/commit/fcf06f774c1952b5cd798a52d01ef48bd2352c3e), [2c8c109f](https://github.com/Katello/hammer-cli-katello.git/commit/2c8c109f3f6706297fd9ee1d9a8289d8dbd4497d))

### Hosts
 * As a user I want to be able to change the location and organization of multiple hosts ([#38436](https://projects.theforeman.org/issues/38436), [4b135b87](https://github.com/Katello/katello.git/commit/4b135b871acdf3a39eb7bb0c94c858ae5d31dbd7))

## Bug Fixes

### Container
 * Flatpak - Install REX job run hangs for 10 minutes ([#38638](https://projects.theforeman.org/issues/38638), [2c1bfa5b](https://github.com/Katello/katello.git/commit/2c1bfa5b0ba7d77623cdf17303d73fc3ec77e5b8))
 * Handle permissions correctly on flatpak UI + UX feedback ([#38621](https://projects.theforeman.org/issues/38621), [da7d3e5e](https://github.com/Katello/katello.git/commit/da7d3e5e8c40df9f308edbbe9fa73bf59ed677ec))
 * Remove "seeded" and "organization_id" from Flatpak remote search bar proposals ([#38617](https://projects.theforeman.org/issues/38617), [1b5c3966](https://github.com/Katello/katello.git/commit/1b5c3966253f22988782a5229bfea1f9cbe2de93))
 * Add capsule URL as flatpak index endpoint ([#38530](https://projects.theforeman.org/issues/38530), [783c4507](https://github.com/Katello/smart_proxy_container_gateway.git/commit/783c45077b78b8545660fd0e9385532adbeb7b9d))

### Repositories
 * HTTP should be allowed on Flatpak remote creation and application name should be displayed for remote repository ([#38634](https://projects.theforeman.org/issues/38634), [48f50cfe](https://github.com/Katello/katello.git/commit/48f50cfec6d4c0aff2d4e5a1e40785ba12a235bf))
 * Prevent unintentional password updates in empty edit forms ([#38593](https://projects.theforeman.org/issues/38593), [df7ea596](https://github.com/Katello/katello.git/commit/df7ea596fc2b655c3c61a90293aac478d9804bb2))
 * ERROR:  nextval: reached maximum value of sequence "katello_erratum_packages_id_seq"  during concurrent repository sync plan executions ([#38497](https://projects.theforeman.org/issues/38497), [63f5f434](https://github.com/Katello/katello.git/commit/63f5f434596e5bb6087da39a4ea8b649789428bf))
 * Create option for default repository mirroring behavior ([#38433](https://projects.theforeman.org/issues/38433), [d2fbe1a3](https://github.com/Katello/katello.git/commit/d2fbe1a3a4158ccc140ac482217044cc7701198c))

### Tests
 * Update CP VCR's for 4.6.3-1 ([#38618](https://projects.theforeman.org/issues/38618), [c44d9c07](https://github.com/Katello/katello.git/commit/c44d9c0713070151df48b2d12c0a7fd02a7360f8))

### Foreman Proxy Content
 * Code is not reloadable ([#38578](https://projects.theforeman.org/issues/38578), [6e242c7c](https://github.com/Katello/katello.git/commit/6e242c7c794cd9a1f90c1adb25a3ae0d50540dae))
 * Silent failure when triggering a CapsuleSync using a user without the manage_capsule_content permission ([#38406](https://projects.theforeman.org/issues/38406), [7a2787b6](https://github.com/Katello/katello.git/commit/7a2787b6186979936c344b290df699bf61fdcb77))

### Tooling
 * Fix JS snapshots after scalprum addition in Foreman ([#38577](https://projects.theforeman.org/issues/38577), [40a44203](https://github.com/Katello/katello.git/commit/40a442032d34798d04dc34509edd26402d8532bf))

### Content Uploads
 * When importing content in disconnected Satellite in syncable format via hammer, hammer content-import list is empty ([#38494](https://projects.theforeman.org/issues/38494), [440ce02e](https://github.com/Katello/katello.git/commit/440ce02e3afd276571bdb5a104be391f37961302))
 * Accept "real" file uploads to /katello/api/repositories/:repository_id/content_uploads/:id ([#38482](https://projects.theforeman.org/issues/38482), [593de752](https://github.com/Katello/katello.git/commit/593de75261341744e055336a165e5b06e36cba1c))

### Content Views
 * Incremental CCV updates all CV versions ([#38484](https://projects.theforeman.org/issues/38484), [86e656c7](https://github.com/Katello/katello.git/commit/86e656c77b249fec0c399c9d93820ffd4feb89bd))
 * Content view environments can be created without a content view version id ([#38270](https://projects.theforeman.org/issues/38270), [1c02a478](https://github.com/Katello/katello.git/commit/1c02a478adceb217c380b3f410e7ed84200f6097))

### Errata Management
 * 'Install Selected via remote execution – customize first' installs all available errata for the host collection ([#38483](https://projects.theforeman.org/issues/38483), [8e7d2891](https://github.com/Katello/katello.git/commit/8e7d2891d1f82274d8207fe90c80b9471b6970fa))

### Web UI
 * Fix plurality of React UI elements on the new Host details -> Content page ([#38476](https://projects.theforeman.org/issues/38476), [5c9f3730](https://github.com/Katello/katello.git/commit/5c9f37307a20686d3f9cc959cf839b8c66f93c3b))
 * Errata page displays 'Apply Errata' even when one erratum is selected ([#38466](https://projects.theforeman.org/issues/38466), [7652f2bf](https://github.com/Katello/katello.git/commit/7652f2bf42f3cae24fe135dfcb749ddcfa3f2678))

### Hammer
 * Hammer command with --csv option generates few fields in json format ([#38405](https://projects.theforeman.org/issues/38405), [1cb23adb](https://github.com/Katello/hammer-cli-katello.git/commit/1cb23adb604e2f8be56384a380666c22f5725bc6))
 * Org options are missing in inline help ([#38268](https://projects.theforeman.org/issues/38268), [6db0c5f3](https://github.com/Katello/hammer-cli-katello.git/commit/6db0c5f3578979d3721d181fe22c7b137e4eff6d))

### Other
 * Remove @theforeman/vendor-dev ([#38431](https://projects.theforeman.org/issues/38431), [2b5ed2f4](https://github.com/Katello/katello.git/commit/2b5ed2f4886d0f8b8efd187d03a297d0b85d2e7f))
