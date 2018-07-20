# 3.8.0 Stout (2018-07-20)

## Features

### Tests
 * Port robottelo tests - repository ([#23910](https://projects.theforeman.org/issues/23910), [473fd3d2](https://github.com/Katello/katello.git/commit/473fd3d28de278e422b8cda19f9bf4fe5e1a13be))
 * Port robottelo tests - sync_plan ([#23802](https://projects.theforeman.org/issues/23802), [9e225cf5](https://github.com/Katello/katello.git/commit/9e225cf550763683457ec52b15f456f01f83f944))
 * Port robottelo tests for host_collection ([#23780](https://projects.theforeman.org/issues/23780), [8da1e39e](https://github.com/Katello/katello.git/commit/8da1e39e01c9f50363c9d5569a554cce58087741))
 * Port robottelo tests for product ([#23758](https://projects.theforeman.org/issues/23758), [c796333b](https://github.com/Katello/katello.git/commit/c796333b0426f2a5b71095912afe62966f6df6bc))
 * Port robottelo tests for activation_key ([#23400](https://projects.theforeman.org/issues/23400), [3b32a48a](https://github.com/Katello/katello.git/commit/3b32a48a9139daa60139342461896634bde3bc48), [3c582906](https://github.com/Katello/katello.git/commit/3c582906fa1c024532370d7527e11d68813c5d3d))

### Docker
 * As a container image admin, I want option to expose some images without requiring login ([#23899](https://projects.theforeman.org/issues/23899), [672482a8](https://github.com/Katello/katello.git/commit/672482a87745838babeab553ec0adf842e9dcb81))
 * Docker Regsitry Image Name Format on katello ([#18964](https://projects.theforeman.org/issues/18964), [961148c0](https://github.com/Katello/katello.git/commit/961148c07b550096bd8ec9b57dd5b3cc5a8bbed3))

### Installer
 * Allow overriding the "Options" httpd directive for /pub directory ([#23624](https://projects.theforeman.org/issues/23624))
 * Satellite 6.2: katello-certs-check should check Key Usage ([#23618](https://projects.theforeman.org/issues/23618))

### Content Views
 * Change the description of content view version ([#23594](https://projects.theforeman.org/issues/23594), [e643193b](https://github.com/Katello/katello.git/commit/e643193b8f00c5aa3f924f226e8e40b2d585b63f))
 * ability to insert new environments in an environment path ([#13983](https://projects.theforeman.org/issues/13983), [f9591200](https://github.com/Katello/katello.git/commit/f959120067d7405bfaa60574be54303487939083))

### Other
 * Port robottelo tests for puppet_module ([#23983](https://projects.theforeman.org/issues/23983), [09292240](https://github.com/Katello/katello.git/commit/09292240d3e40308336de37323b5e678d147fa6a), [abbff485](https://github.com/Katello/katello.git/commit/abbff485b07e94f8dd1dc1caeff4fc23f4e1b356))
 * As an API user, I should be able to compare the Packages of a Content View Version to the Packages in Library. ([#23320](https://projects.theforeman.org/issues/23320), [c874ec9f](https://github.com/Katello/katello.git/commit/c874ec9f6aa9bb75b52e403502fe3fe0cbf05ae3))
 * As an API user, I should be able to search for the latest versions of packages. ([#23319](https://projects.theforeman.org/issues/23319), [514128c1](https://github.com/Katello/katello.git/commit/514128c1c541bbe5a3475ffe22a38fa31668c9f8))
 * As an API user, I should be able to compare the Errata of a Content View Version to the installable Errata in Library. ([#23318](https://projects.theforeman.org/issues/23318), [8956eec2](https://github.com/Katello/katello.git/commit/8956eec2b92c94ccb20c868a3a0a9f70d5d21ef8))

## Bug Fixes

### Docker
 * return repository description during docker search ([#24317](https://projects.theforeman.org/issues/24317))
 * unauthenticated docker search ([#24055](https://projects.theforeman.org/issues/24055), [12ce7e82](https://github.com/Katello/katello.git/commit/12ce7e8206a385746cdd09ccc4d75dfa478a0539))
 * docker v2 api - don't output blobs to log ([#23835](https://projects.theforeman.org/issues/23835), [ca2af71b](https://github.com/Katello/katello.git/commit/ca2af71b39de355989aca40aed675292f923d00f))
 * docker v2 api - allow repositories with slashes in routes ([#23822](https://projects.theforeman.org/issues/23822), [39817828](https://github.com/Katello/katello.git/commit/39817828cd4dd477663ed04a0e7c1a3f4ae21a67))
 * referencing non-existent registry setting in class loading ([#23820](https://projects.theforeman.org/issues/23820), [40669ab1](https://github.com/Katello/katello.git/commit/40669ab1041ff34eafe3ae47921f320140397a6c))
 * docker v2 api - pull_manifest not setting Docker-Content-Digest response header ([#23778](https://projects.theforeman.org/issues/23778), [c569d5d2](https://github.com/Katello/katello.git/commit/c569d5d2056e6f67a181d7c7fcde5449c6cbf97f))
 * As a user I want the full docker v2 api ([#22951](https://projects.theforeman.org/issues/22951), [989648bf](https://github.com/Katello/katello.git/commit/989648bf14ad62c608cea0860dac04781f42b751))

### Tests
 * eslint error on master ([#24254](https://projects.theforeman.org/issues/24254), [f2ff28bd](https://github.com/Katello/katello.git/commit/f2ff28bd3b8b2966776ef8333bf5e0fd17430645))
 * Katello host tests do not add puppet environment to orgs/locs ([#24239](https://projects.theforeman.org/issues/24239), [211ba4ee](https://github.com/Katello/katello.git/commit/211ba4ee8f210048d4cb69f0ad2672cb5d638518))
 * Use 3.8 apipie cache in hammer-cli-katello ([#24076](https://projects.theforeman.org/issues/24076))
 * port robotello tests for docker repos ([#23846](https://projects.theforeman.org/issues/23846), [3e623e4c](https://github.com/Katello/katello.git/commit/3e623e4caca24af2a5b9e3f948fd9a4c7de368f6))
 * hammer-cli-katello sends integer task IDs to task_progress, which no longer accepts integers ([#23772](https://projects.theforeman.org/issues/23772))

### Installer
 * puppet-capsule to puppet-foreman_proxy_content migration drops the puppet answer ([#24088](https://projects.theforeman.org/issues/24088), [c508e58d](https://github.com/Katello/katello-installer.git/commit/c508e58d2251e5fdbfa8ced6f583c7e132320cff))
 * foreman-installer does not install hammer openscap plugin ([#23242](https://projects.theforeman.org/issues/23242), [0d7f9618](https://github.com/Katello/katello-installer.git/commit/0d7f961829417df30651e7feb166d6b9b1be18f0))

### Host Collections
 * Removing the assigned subscription from multiple hosts using bulk action fails. ([#23968](https://projects.theforeman.org/issues/23968), [76ae5b79](https://github.com/Katello/katello.git/commit/76ae5b79763bc4c9c1bf4dc2c7cbd71824a7a7ec))

### Lifecycle Environments
 * use full page width on lifecycle environment details page ([#23839](https://projects.theforeman.org/issues/23839), [75248db2](https://github.com/Katello/katello.git/commit/75248db283afac9f665bffc66aeba85de73151c5))

### API doc
 * Inconsistant documentation in --order option in scoped_search for katello and foreman ([#23774](https://projects.theforeman.org/issues/23774), [c1b5edf1](https://github.com/Katello/katello.git/commit/c1b5edf1f1387d5b95f4141bf78efdbec2f8d3e3))

### Tooling
 * Redirect katello-service to foreman-maintain ([#23615](https://projects.theforeman.org/issues/23615), [d9f3f547](https://github.com/theforeman/foreman-packaging.git/commit/d9f3f547fc961e2ae223f30cd5e1e8a1a9f20e1d))

### Repositories
 * add description field to repository model ([#23493](https://projects.theforeman.org/issues/23493), [d9618362](https://github.com/Katello/katello.git/commit/d9618362c94e4bbe94f25ffc480ae90a163b4bef))

### Content Views
 * provide before_promote and after_promote to content view version ([#23438](https://projects.theforeman.org/issues/23438), [8eddfe6f](https://github.com/Katello/katello.git/commit/8eddfe6f94754c997a905340232ea3a4734fe853))
 * [Performance improvement] On CV publish/promote, call Pulp::Repository::* dynflow steps concurrently ([#23322](https://projects.theforeman.org/issues/23322))

### Web UI
 * Console errors on Repo Discovery Page ([#23381](https://projects.theforeman.org/issues/23381), [565db72a](https://github.com/Katello/katello.git/commit/565db72a49139a05450caa4d0136c6068e5eae4f))

### Upgrades
 * re-vamp upgrade proccess to not require installer updates ([#22961](https://projects.theforeman.org/issues/22961))

### Other
 * Port robottelo tests for cv filters ([#23712](https://projects.theforeman.org/issues/23712), [afea362f](https://github.com/Katello/katello.git/commit/afea362fd966580597ba7a3533a98f6091f647bd), [2d881437](https://github.com/Katello/katello.git/commit/2d881437a45827cf6cbf13f8a414a3f2a9fbccee))
 * Port robottelo tests for content views ([#23676](https://projects.theforeman.org/issues/23676), [51cb879e](https://github.com/Katello/katello.git/commit/51cb879eb3bc53a3a96c6e11183af6e63a4d2776))
 * katello_devel puppet module references file that moved, breaking devel install ([#23648](https://projects.theforeman.org/issues/23648))
 * Update Contacts & Resources ([#23639](https://projects.theforeman.org/issues/23639), [82ee6946](https://github.com/Katello/katello.git/commit/82ee6946c22d0fc3e63c709d7888cce0f2f90db1), [90e80a81](https://github.com/Katello/katello.git/commit/90e80a81799f121e01a7f409cf9c3245674d9031))
 * undefined method `before_promote_hooks' ([#23636](https://projects.theforeman.org/issues/23636), [263afc68](https://github.com/Katello/katello.git/commit/263afc6895d2fb850592d0001d978af2980fb2d5))
 * content view version docker repositories table change value in repository column ([#23392](https://projects.theforeman.org/issues/23392), [c7e922c7](https://github.com/Katello/katello.git/commit/c7e922c7480a4ec43f7d6a75315a6eb8f9112efe))
 * Katello::Util::Package.find_latest_packages() is broken ([#23315](https://projects.theforeman.org/issues/23315), [37370ea3](https://github.com/Katello/katello.git/commit/37370ea333c0cb4eb5195e657240da18742048ed))
