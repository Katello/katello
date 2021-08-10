# 4.2.0 Alfalfa (2021-08-10)

## Features

### Web UI
 * CV UI - Task progress bar with details to poll and track Publish/Promote tasks ([#33118](https://projects.theforeman.org/issues/33118), [a24fa7cb](https://github.com/Katello/katello.git/commit/a24fa7cbcfe4960d3f0e4bbf8786aba094b9596d))
 * CV UI - Add filters to CV ([#32932](https://projects.theforeman.org/issues/32932), [e919b8fa](https://github.com/Katello/katello.git/commit/e919b8fae7c99f4f0de3a344e56e81c7b86cc27f))
 * CV UI - Delete filters from CV ([#32931](https://projects.theforeman.org/issues/32931), [489d0a84](https://github.com/Katello/katello.git/commit/489d0a84b0bcb2e18bb1260b134ac61bec193b50))
 * CV UI - Add component CVs to composite CVs ([#32698](https://projects.theforeman.org/issues/32698), [ec40908a](https://github.com/Katello/katello.git/commit/ec40908addd2d0befc53e6d2d6220e6a2a503e06))

### Hosts
 * Host registration - :rhsm_base_url helper ([#32841](https://projects.theforeman.org/issues/32841), [e677f208](https://github.com/Katello/katello.git/commit/e677f208a11fd52b9d0a4a045edd5a15b8f8bf38))
 * Add Rocky Linux parsing support ([#32515](https://projects.theforeman.org/issues/32515), [0eb319f2](https://github.com/Katello/katello.git/commit/0eb319f230015223e83caf41035c5c80ac5a61bd))

### Repositories
 * Sync/index python repository and handle remote options ([#32802](https://projects.theforeman.org/issues/32802), [1afd1c59](https://github.com/Katello/katello.git/commit/1afd1c59f566e24a3c1e6d01eba77ae57d35db75))
 * support deleting RH repos from the repositories details ([#32800](https://projects.theforeman.org/issues/32800), [912475a9](https://github.com/Katello/katello.git/commit/912475a9b91cbbf1297b9faff3966cf61bdcf663))
 * Product sync-status of all repo-syncs ([#32798](https://projects.theforeman.org/issues/32798), [55252d90](https://github.com/Katello/katello.git/commit/55252d90f800d9969fc87a53e087b3c86d86bb7c))
 * Create/Read/Update/Destroy Python repository with generic content type registration ([#32712](https://projects.theforeman.org/issues/32712), [6887975c](https://github.com/Katello/katello.git/commit/6887975cfb8303657136cd4e0efacbf936e29b1f))

### Content Views
 * Add functionality to publish and promote content view in one API call ([#32574](https://projects.theforeman.org/issues/32574), [14366073](https://github.com/Katello/katello.git/commit/143660734dec0f7b6fa6dd33a062b33d9919b01f))
 * Add a show_all endpoint for content view components ([#32303](https://projects.theforeman.org/issues/32303), [56b5409b](https://github.com/Katello/katello.git/commit/56b5409baaac5407aff0d06e3f4afe37f3cae789))

### Subscriptions
 * Prevent re-register unless host is in build mode ([#32406](https://projects.theforeman.org/issues/32406), [47a628e4](https://github.com/Katello/katello.git/commit/47a628e4a35c95f49bd389674ac7987258ec91eb))
 * Permit DMI change when host is in build mode ([#32405](https://projects.theforeman.org/issues/32405), [ac5caa69](https://github.com/Katello/katello.git/commit/ac5caa699555fa5acdaf54d39ce362e791d13888))

### Other
 * Content View Publish for Generic Types ([#33103](https://projects.theforeman.org/issues/33103), [47afafaa](https://github.com/Katello/katello.git/commit/47afafaa8ad73c131e4e8db051d9ef64fabf3fcc))
 * Remove rhsm parser and importer ([#32524](https://projects.theforeman.org/issues/32524), [8201e87f](https://github.com/Katello/katello.git/commit/8201e87f5d30ef3511c3348941b92cef8251e144))
 * Add support for AlmaLinux OS ([#32510](https://projects.theforeman.org/issues/32510), [fc0d0fe4](https://github.com/Katello/katello.git/commit/fc0d0fe4c477c6dd44f138d836b3d8eadc5ef50c))
 * Use Foreman client certificates to communicate with Pulp 3 API ([#32487](https://projects.theforeman.org/issues/32487), [b1af520b](https://github.com/Katello/katello.git/commit/b1af520bca01eaa538492608d17ac9acd050ab95))
 * CV UI - Add Publish workflow to new CV UI (Component CVs) ([#32441](https://projects.theforeman.org/issues/32441), [e596a327](https://github.com/Katello/katello.git/commit/e596a32718b40b435abccac9944d5803e8206622))

## Bug Fixes

### Foreman Proxy Content
 * incorrect pulp version number after upgrade to pulp 3 ([#33211](https://projects.theforeman.org/issues/33211), [97176a59](https://github.com/Katello/katello.git/commit/97176a59947b14e6072b6436175d277554386308))
 * Cancel button should be enabled in the capsule sync until the job completions ([#33037](https://projects.theforeman.org/issues/33037), [5f23a602](https://github.com/Katello/katello.git/commit/5f23a60246ad77b13128efb25f1475bba24e32fb))

### Ansible Collections
 * Ansible Collection - auth_token should be allowed without providing auth_url ([#33208](https://projects.theforeman.org/issues/33208), [72531240](https://github.com/Katello/katello.git/commit/725312408d360cf2e0473159515240e4f006f7b5))

### Tooling
 * gem build includes .edit.po files in locale ([#33200](https://projects.theforeman.org/issues/33200), [c62fd6f2](https://github.com/Katello/katello.git/commit/c62fd6f241135a10052b65e0681c02d9785d3988))
 * Http Proxy passwords are not making it to candlepin properly ([#32998](https://projects.theforeman.org/issues/32998), [b06d0f2e](https://github.com/Katello/katello.git/commit/b06d0f2e9de97a1b6c92c0780461d502e17474f6))
 * Make with_ansible? check more precise ([#32839](https://projects.theforeman.org/issues/32839), [2289a550](https://github.com/Katello/katello.git/commit/2289a5506831b3cf9f5873f6e71c01c47e7792c1))

### Tests
 * Intermittent Pipeline katello-master-source-release failure on contentViewDetailRepos.test.js ([#33199](https://projects.theforeman.org/issues/33199), [be49f49e](https://github.com/Katello/katello.git/commit/be49f49e4866268b28be8ef908db1981328ff132), [a45dcca6](https://github.com/Katello/katello.git/commit/a45dcca6a08e8e9bd5354ac5e87023bd2ea18d74), [ac6e1c55](https://github.com/Katello/katello.git/commit/ac6e1c5594342c3527e54ab4439ee6b3f844d2bf))
 * spacing issue with rubocop disablement ([#33167](https://projects.theforeman.org/issues/33167), [f75b3389](https://github.com/Katello/katello.git/commit/f75b3389a0d04e651c131ee53c1c49b144e519cc))
 * Use unsafe_load in tests ([#32604](https://projects.theforeman.org/issues/32604), [928b12fd](https://github.com/Katello/katello.git/commit/928b12fd11a343f43088e9f09b01c40265c8dc51), [63c13ab2](https://github.com/Katello/katello.git/commit/63c13ab2eb1cd3505bc76ec6b034317cc1bd6d04))
 * Transient package groups test ([#32527](https://projects.theforeman.org/issues/32527), [953f4641](https://github.com/Katello/katello.git/commit/953f4641aaa0b2fad99c7fd663e99f8fd2d296c5))
 * Use eslint react-hooks rules ([#32221](https://projects.theforeman.org/issues/32221), [cd9419ab](https://github.com/Katello/katello.git/commit/cd9419abb4466bfd64bddc77f8d083ef795f168c))

### Repositories
 * Show rhel-6-server-els-rpms under recommended repositories instead of rhel-6-server-rpms ([#33189](https://projects.theforeman.org/issues/33189), [8015ee4b](https://github.com/Katello/katello.git/commit/8015ee4b9c5913cd0d1d323ba149a0f4124a2bf0))
 * Do not display Red Hat Enterprise Linux 5 Server - Extended Life Cycle Support (RPMs) repository under recommended repositories ([#33188](https://projects.theforeman.org/issues/33188), [cf5d58bd](https://github.com/Katello/katello.git/commit/cf5d58bd40bf64010ff9ce195971e3756a6f9f37))
 * unable to set SSL certs when creating Ansible Collection repository ([#33171](https://projects.theforeman.org/issues/33171), [9c48b078](https://github.com/Katello/katello.git/commit/9c48b078f206ed34c4450ef70566e70875253a15))
 * Ansible collection repo validate both auth url and token are supplied ([#33147](https://projects.theforeman.org/issues/33147), [eed98173](https://github.com/Katello/katello.git/commit/eed981730c594e6e86e41c8e86c6cc01aeac592c))
 * [BUG] The --docker-tags-whitelist option is not allowing the syncing of whitelisted tags for a docker type repo in Satellite 6 ([#33039](https://projects.theforeman.org/issues/33039))
 * Enabling a RH repo is not reflected in the list of enabled repos ([#32997](https://projects.theforeman.org/issues/32997), [a28eb7bf](https://github.com/Katello/katello.git/commit/a28eb7bf49d3f8f464c1dd3bb11742a9f47fa30c))
 * Katello 4.1 journal: warning: URI.escape is obsolete ([#32995](https://projects.theforeman.org/issues/32995), [987eb63a](https://github.com/Katello/katello.git/commit/987eb63aec385e192368c9efc009fdd71684b245))
 * Deleting repository shows success toast notification but repositories remain on the page ([#32965](https://projects.theforeman.org/issues/32965), [e87c9331](https://github.com/Katello/katello.git/commit/e87c93312fa56a0e77206ef65a6e05edddfab3cd))
 * Problems when creating a new repository with Chrome ([#32626](https://projects.theforeman.org/issues/32626), [4c026a24](https://github.com/Katello/katello.git/commit/4c026a2465262439ca9669ec0513e33f1d1e714b))
 * deb repo - Verify Content Checksum - undefined method `repair' ([#32144](https://projects.theforeman.org/issues/32144), [bb8fbd67](https://github.com/Katello/katello.git/commit/bb8fbd6784085951d7affec3eb58b91c4f9241fd))
 * Remove content_types requirement in katello.yaml and use of it ([#31616](https://projects.theforeman.org/issues/31616), [304de977](https://github.com/Katello/katello.git/commit/304de977b189990164968a7d1a482137012bc9d7))
 * Katello repository export requires a shared filesystem with Pulp ([#20854](https://projects.theforeman.org/issues/20854))

### Errata Management
 * Warnings should be improved for hammer host errata apply, when not passing errata_ids ([#33182](https://projects.theforeman.org/issues/33182), [ece0b63a](https://github.com/Katello/hammer-cli-katello.git/commit/ece0b63a2814badf4a36bb880a0e52b476f735d2), [c35f3100](https://github.com/Katello/katello.git/commit/c35f3100fda7fcdd89b34e8324b3e82c4b8b491e))
 * repo package upload & package remove doesn't trigger applicability regen for hosts ([#32601](https://projects.theforeman.org/issues/32601), [b2324123](https://github.com/Katello/katello.git/commit/b2324123bb54562a4f21c88996eec8146a83346b))

### Roles and Permissions
 * Some of the "filters" permission changed after the upgrade. ([#33146](https://projects.theforeman.org/issues/33146), [82c3516a](https://github.com/Katello/katello.git/commit/82c3516ab71ac773bff195683879b380e2bbe4f6))

### Content Views
 * Bats failure on 'compare contents of library export and import' ([#33021](https://projects.theforeman.org/issues/33021))
 * Remove old EnvironmentCreate action ([#33020](https://projects.theforeman.org/issues/33020), [9600157d](https://github.com/Katello/katello.git/commit/9600157dc1c6e2e09f405235d01557b5619514c6))
 * Introduce a valid solution to fix the error "Katello::Errors::CandlepinError: Environment with id XXXX could not be found" ([#33019](https://projects.theforeman.org/issues/33019), [ecdf0913](https://github.com/Katello/katello.git/commit/ecdf09135b70e4fc74c2d9304a66617481c0d964))
 * Create content view button doesn't work after the first time ([#32911](https://projects.theforeman.org/issues/32911), [56fba61b](https://github.com/Katello/katello.git/commit/56fba61b74e5b658e7cf50813fbe9326d0f04c1e))
 * Fix wording on new CV page empty state ([#32788](https://projects.theforeman.org/issues/32788), [d9a80c2c](https://github.com/Katello/katello.git/commit/d9a80c2c86c9a3d82ccdc6f55b49568efcf23bc3))
 * Navigation doesn't display Content views (within Lab Features) without admin rights ([#32138](https://projects.theforeman.org/issues/32138), [7db3ca84](https://github.com/Katello/katello.git/commit/7db3ca848ae1577810b40a879bc0675254226528))
 * New Content View Page - Add breadcrumbs ([#31825](https://projects.theforeman.org/issues/31825), [1c436b6d](https://github.com/Katello/katello.git/commit/1c436b6d8422b78ffd1ead4ff8b3c5c14ae1f16a))
 * A publish content view displays (Invalid Date) for the date and time of when the content view was published. ([#30334](https://projects.theforeman.org/issues/30334))

### Subscriptions
 * Not possible to remove subscriptions from 'WebUI --> Content --> Subscriptions' page if the user doesn't have 'Setting' permissions." ([#33000](https://projects.theforeman.org/issues/33000), [0e11585c](https://github.com/Katello/katello.git/commit/0e11585c3859472a2decc4e6579cda25f9753855))
 * Disconnected satellite's subscription page missing the checkbox/select column ([#32815](https://projects.theforeman.org/issues/32815), [eb8feb65](https://github.com/Katello/katello.git/commit/eb8feb65f9cca8ff793121aca4912cd694e19e9f))
 * RHEL8 hosts show System Purpose: Mismatched ([#31983](https://projects.theforeman.org/issues/31983))
 * Add authorization for upstream_subscriptions controller ([#30881](https://projects.theforeman.org/issues/30881))

### Web UI
 * Component content view > repositories checkbox selection doesn't work for bulk actions. ([#32956](https://projects.theforeman.org/issues/32956), [ea44c8ea](https://github.com/Katello/katello.git/commit/ea44c8eab2597b6234f1a4b0efbb1bd6cd7e4ffc))
 * Change text on Component/Composite tiles in Create CV modal form ([#32895](https://projects.theforeman.org/issues/32895), [5a06e5d1](https://github.com/Katello/katello.git/commit/5a06e5d17a0956bddc4ae90384d767dde0d973a9))
 * use-deep-compare to replace usage of JSON.stringify in effect hooks ([#32621](https://projects.theforeman.org/issues/32621), [a6ab4b11](https://github.com/Katello/katello.git/commit/a6ab4b11fadaefcea2f5caf8cac19334cb7f5573))
 * Tables with MainTable component momentarily show empty content component before the table is populated. ([#32229](https://projects.theforeman.org/issues/32229))

### Hosts
 * Add extensions for Packages/Errata/Module streams ([#32938](https://projects.theforeman.org/issues/32938), [0238a3c2](https://github.com/Katello/katello.git/commit/0238a3c2a510012c7cd81635337ed7b7761a5454))
 * Move Actions::Katello::Host::UploadPackageProfile out of dynflow' ([#32889](https://projects.theforeman.org/issues/32889), [bf572c3f](https://github.com/Katello/katello.git/commit/bf572c3f761c167a3bf3d91b49b0ca8bda58074a))
 * Manage Errata from Content Host Page does not provide link to view list of content hosts affected by an Errata. ([#32806](https://projects.theforeman.org/issues/32806), [44c8533a](https://github.com/Katello/katello.git/commit/44c8533ab4ce792253a9cafb9c93e83f67db1cd5))

### Lifecycle Environments
 * Use correct inverse association for kt_environment -> organization association ([#32905](https://projects.theforeman.org/issues/32905), [10ef8120](https://github.com/Katello/katello.git/commit/10ef81200b4694401d66b58f1c7d36caa79ef40a))

### Hammer
 * Consistent use of unlimited-host argument throughout CLI' ([#32868](https://projects.theforeman.org/issues/32868), [35deb716](https://github.com/Katello/hammer-cli-katello.git/commit/35deb71684e25633d153c0f10f657811482deb35))

### Container
 * Capsule sync fails with ISE (500) during container gateway repository list update ([#32745](https://projects.theforeman.org/issues/32745), [667d566d](https://github.com/Katello/smart_proxy_container_gateway.git/commit/667d566d625b3a7309b94a33e094c45069aae183))

### Client/Agent
 * enabled repositories upload fails with not subscribed error, when run as non-root user. ([#32744](https://projects.theforeman.org/issues/32744), [3a6c91b3](https://github.com/Katello/katello-host-tools.git/commit/3a6c91b3c794eac3f08053731bc25a992e4765d0))
 * Dynflow error output when performing katello-agent action ([#31853](https://projects.theforeman.org/issues/31853), [fec21e39](https://github.com/Katello/katello.git/commit/fec21e39b51a4a46d425f87e897176358d101344))

### Other
 * bump pulp-rpm requires to allow 3.14.0 ([#33148](https://projects.theforeman.org/issues/33148), [cc84eb83](https://github.com/Katello/katello.git/commit/cc84eb83e4f267106b15ec8cdf47862f6c6ffadc))
 * apipie cache out of date because repo_create param content_type relies on creatable_repository_types instead of defined_repository_types ([#33057](https://projects.theforeman.org/issues/33057), [d5bbb290](https://github.com/Katello/katello.git/commit/d5bbb290811e9d1d9880ddbb5e5467636747bb30))
 * RHEL8 re-registration error shows the information about foreman rather satellite ([#33031](https://projects.theforeman.org/issues/33031), [da73b782](https://github.com/Katello/katello.git/commit/da73b7824661e58062e2803d930a3ceb07f8bef4), [f4cb1ad8](https://github.com/Katello/katello.git/commit/f4cb1ad8dc59efda0d3d798248a7d9a29fcaeecf))
 * Parse Amazon distribution properly ([#32807](https://projects.theforeman.org/issues/32807), [1ca61e3d](https://github.com/Katello/katello.git/commit/1ca61e3d2155a7e5245185fb3aeb2e26c65dcf80))
