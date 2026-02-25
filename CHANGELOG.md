# 4.20.0 (2026-02-25)

## Features

### Container
 * Maria's UX Container Images page changes ([#39031](https://projects.theforeman.org/issues/39031), [b90c7451](https://github.com/Katello/katello.git/commit/b90c745150e1d45291c205474fe9f9d845885336))
 * As a user, I can easily copy a Containerfile RUN command with select packages from a host's transiently installed package list via the UI ([#38989](https://projects.theforeman.org/issues/38989), [d962781d](https://github.com/Katello/katello.git/commit/d962781d1eeac3b8055b6226c9d026d4baf2d93a))
 * Add Container images to main navigation and remove it out of experimental labs ([#38942](https://projects.theforeman.org/issues/38942), [b68ceae3](https://github.com/Katello/katello.git/commit/b68ceae3f525617789ebc92d5b841ab29b01cfc8))
 * As a user I have some dependency indicators on the UI ([#38908](https://projects.theforeman.org/issues/38908), [d9129398](https://github.com/Katello/katello.git/commit/d9129398cc84f7ca46235f4808809801592d2baa))
 * Ability to view/copy "pullable path" for container tags ([#38906](https://projects.theforeman.org/issues/38906), [4f51b0a6](https://github.com/Katello/katello.git/commit/4f51b0a6f59646ed8bac3190add738a45cf06159))
 * Create a modal to display labels and annotations for manifests. ([#38873](https://projects.theforeman.org/issues/38873), [762c1847](https://github.com/Katello/katello.git/commit/762c18471d6c66fcb6714ee86dccac747eabf00c))
 * Create an expandable table for Synced image tags ([#38850](https://projects.theforeman.org/issues/38850), [21792f1c](https://github.com/Katello/katello.git/commit/21792f1c2768344348e9a8b1c11b9e85f2566b35))
 * Make it easier to add redhat remotes with UI help texts ([#38810](https://projects.theforeman.org/issues/38810), [243369bf](https://github.com/Katello/katello.git/commit/243369bf85a68e92eaebed4292dc23deb27f7ca5))
 * Update tag API results to return manifests and lists tagged by the docker tag ([#38801](https://projects.theforeman.org/issues/38801), [6c37c469](https://github.com/Katello/katello.git/commit/6c37c469039380c30ad4f19c66cff06d206f4e98))

### Hosts
 * Add note about persistence data being available in future versions of sub-man ([#39022](https://projects.theforeman.org/issues/39022), [4ec53ea7](https://github.com/Katello/katello.git/commit/4ec53ea709cb33320138a073c7ac785ea4779ba6))
 * As a user, I want to assign multiple content view environments to multiple Hosts via Bulk action in web UI ([#39021](https://projects.theforeman.org/issues/39021), [bceff87a](https://github.com/Katello/katello.git/commit/bceff87a575e20257623b36465aa6790e83d0d91))
 * As a user, I want to assign multiple content view environments to a single host via WebUI ([#39010](https://projects.theforeman.org/issues/39010), [b4e0a21c](https://github.com/Katello/katello.git/commit/b4e0a21cf7c76a1fef0bb865a01817ba309020ad), [fd0a7f39](https://github.com/Katello/katello.git/commit/fd0a7f39bff4885312373f1894e3febcfc3a0aef))
 * Implement CSV exports on the hosts overview ([#38940](https://projects.theforeman.org/issues/38940), [ee045a68](https://github.com/Katello/katello.git/commit/ee045a68b492bd7629415503bfa0ece96a9983af))
 * As a user, I can fetch a Containerfile RUN command with select packages from a host's transiently installed package list via Hammer ([#38938](https://projects.theforeman.org/issues/38938), [7246d775](https://github.com/Katello/hammer-cli-katello.git/commit/7246d77584e5c559cad2b5afd79b792f3843dd2e))
 * As a user, I can fetch a Containerfile RUN command with select packages from a host's transiently installed package list via the API ([#38931](https://projects.theforeman.org/issues/38931), [aea05c35](https://github.com/Katello/katello.git/commit/aea05c357b51b7081cb147494e08210e2ba69483))
 * [RFE] As a user, I can see the persistence state of RPMs installed on hosts via the API ([#38911](https://projects.theforeman.org/issues/38911), [b77d37b4](https://github.com/Katello/katello.git/commit/b77d37b43aea53d306a5a66bfde75d3b1701dbad))
 * Add System Purpose & Release version to host bulk actions ([#38881](https://projects.theforeman.org/issues/38881), [d759950c](https://github.com/Katello/katello.git/commit/d759950c27a6174747d7c5f8d2d1fffeedff99a9))

### Activation Key
 * As a user, I want to assign multiple content view environments to an activation key via web UI ([#39019](https://projects.theforeman.org/issues/39019), [8a8fe24f](https://github.com/Katello/katello.git/commit/8a8fe24f86ca790fafdfd37f65e0f7a222a03039))

### Web UI
 * [RFE] As a user, I can see the persistence state of RPMs installed on hosts via the UI ([#38934](https://projects.theforeman.org/issues/38934), [01a7b2d7](https://github.com/Katello/katello.git/commit/01a7b2d7ac1b6bc13ac9b5f1c5838748df754d75))

### katello-tracer
 * Add bulk Traces to HostsIndex ([#38876](https://projects.theforeman.org/issues/38876), [942b2ccf](https://github.com/Katello/katello.git/commit/942b2ccff2af9cbf43a14e43afda8f8789cee5b0))

### Other
 * Add warning for Change Content Source ([#39072](https://projects.theforeman.org/issues/39072), [3fa63e88](https://github.com/Katello/katello.git/commit/3fa63e889f71f39f324e9b896b73298325cb8aa3))
 * Enable multiCV by default ([#38919](https://projects.theforeman.org/issues/38919), [264dfd8d](https://github.com/Katello/katello.git/commit/264dfd8d6469dd4ecfd38bf324cd13fa702974a7))

## Bug Fixes

### Repositories
 * PG::SequenceGeneratorLimitExceeded: ERROR: nextval: reached maximum value of sequence "katello_rpms_id_seq" during repo sync ([#39102](https://projects.theforeman.org/issues/39102))
 * Bump pulp-deb bindings to 3.8 ([#39032](https://projects.theforeman.org/issues/39032), [aa83705c](https://github.com/Katello/katello.git/commit/aa83705ccdd360a241700194b88384187179f6b0), [d70b5edd](https://github.com/Katello/katello.git/commit/d70b5edd7ef4339cb483ab9fbdb95152ad3bfb05))
 * There is no progress displayed while the Flatpak scan task is running ([#39030](https://projects.theforeman.org/issues/39030), [ddd671ae](https://github.com/Katello/katello.git/commit/ddd671aec9efb1cd5fbbf5e701c0c401c2b90c25))
 * Update the Recommended Repositories page to change the Red Hat Satellite Capsule, Maintenance and Utils repositories from version 6.18 to 6.19 for RHEL 9 ([#39011](https://projects.theforeman.org/issues/39011), [70b545f3](https://github.com/Katello/katello.git/commit/70b545f309d2da77443c667029febe7b34b095be))
 * Make RH flatpak help visible for every org instead of checking for one in any org + other UX feedback ([#38945](https://projects.theforeman.org/issues/38945), [f531e111](https://github.com/Katello/katello.git/commit/f531e1119607f688c42b154ecf040a2c7d0aded3))
 * 500 request failed on deb packages search query field shown ([#38935](https://projects.theforeman.org/issues/38935), [989458ae](https://github.com/Katello/katello.git/commit/989458ae979106d9d6a813137b89a0c047e76750))
 * Unpin pulp-rpm-client 3.32.2 ([#38832](https://projects.theforeman.org/issues/38832), [c6a5be1f](https://github.com/Katello/katello.git/commit/c6a5be1fe529039314b1017c68efa6e906112830))

### Container
 * Sequel PoolTimeouts when pulling containers from the container gateway ([#39090](https://projects.theforeman.org/issues/39090), [2cfbb91f](https://github.com/Katello/smart_proxy_container_gateway.git/commit/2cfbb91f42d06cf682b358f38677be7ebb18d3fd))
 * Revoking registry token does not prevent access to registry ([#39042](https://projects.theforeman.org/issues/39042), [d03d5a20](https://github.com/Katello/katello.git/commit/d03d5a20fcbba0f62ce7b1ada53e4598acea3926))
 * Page doesn't refresh when navigating back to Container Images via Menu ([#38985](https://projects.theforeman.org/issues/38985), [d82858da](https://github.com/Katello/katello.git/commit/d82858dadf49093467b0cf998dc3334886e56f4d))
 * `containerfile_install_command` API endpoint does not return all transient packages ([#38952](https://projects.theforeman.org/issues/38952), [70c26ad4](https://github.com/Katello/katello.git/commit/70c26ad4a0e781a10fc0cbebd0139fb0911ba227))

### Organizations and Locations
 * API docs for organizations still show taxonomy params ([#39084](https://projects.theforeman.org/issues/39084), [0041b37a](https://github.com/Katello/katello.git/commit/0041b37a3c213ba4a0909bc4b19edfc15a48b885))
 * Hide taxonomy options from API docs for taxonomy resources ([#39026](https://projects.theforeman.org/issues/39026), [77985218](https://github.com/Katello/katello.git/commit/77985218669244df0d8c671e86bdf1f9cfbb4726))

### Content Views
 * CV create lacks useful information in task list view ([#39082](https://projects.theforeman.org/issues/39082), [79fa7bd1](https://github.com/Katello/katello.git/commit/79fa7bd10b08160d279714e7a3714098a3968e70))
 * Cannot delete composite content view version due to host assignment ([#39055](https://projects.theforeman.org/issues/39055))
 * repository_errata for CV repositories missing PRNs at run time ([#39041](https://projects.theforeman.org/issues/39041), [6a46b2f1](https://github.com/Katello/katello.git/commit/6a46b2f1dccf58327b3863446919b79a95fffc84))
 * Use execution plan callbacks to orchestrate CV auto publish ([#39034](https://projects.theforeman.org/issues/39034), [c12a3b5d](https://github.com/Katello/katello.git/commit/c12a3b5d8f4f663fbf0b5d5bb8a7e6e8f2be6ba9))
 * Composite content views can update twice due to a single incremental update of a child content view ([#38460](https://projects.theforeman.org/issues/38460), [4723d11a](https://github.com/Katello/katello.git/commit/4723d11af7b48754af9bb6286527979bdb645e4d))

### Hammer
 * hammer containerfile-install-command returns nothing and 0 exit code when no transient packages found ([#39079](https://projects.theforeman.org/issues/39079), [661a7587](https://github.com/Katello/hammer-cli-katello.git/commit/661a75876b9b66cd82ecc785ce90bdf28be07b8f))
 * Add last_checkin column to hammer host list ([#39015](https://projects.theforeman.org/issues/39015), [a64117d9](https://github.com/Katello/hammer-cli-katello.git/commit/a64117d937f903f0204aba6f5dbdc22968bd17da))
 * [RFE] As a user, I can see the persistence state of RPMs installed on hosts via Hammer ([#38925](https://projects.theforeman.org/issues/38925), [b753a8bf](https://github.com/Katello/hammer-cli-katello.git/commit/b753a8bf1eaba68b20cf3b99e7d9c4febe08c5a8), [bbf43244](https://github.com/Katello/hammer-cli-katello.git/commit/bbf43244d2e3e760c71e203cde515c801a0522c1))
 * Hammer command of module filter does not shows module-filter-id of modules. ([#38678](https://projects.theforeman.org/issues/38678), [e02abbef](https://github.com/Katello/hammer-cli-katello.git/commit/e02abbef88763ea3d4cba5bdafda58f3a5f8d3ae))

### Activation Key
 * When editing activation key description, webui freezes ([#39052](https://projects.theforeman.org/issues/39052), [12b9e221](https://github.com/Katello/katello.git/commit/12b9e221c356b913bccf503333c549b48f9da3c6), [2bb2e14c](https://github.com/Katello/katello.git/commit/2bb2e14c1c01a8d6a1de156d2eabbabf2358b9f9))

### Tests
 * Update Debian ptable factory ([#39008](https://projects.theforeman.org/issues/39008), [2920ffe1](https://github.com/Katello/katello.git/commit/2920ffe13f8c02b95f4b07b246564e2f7a992381))

### Hosts
 * Katello:clean_backend_object takes a long time to complete ([#38997](https://projects.theforeman.org/issues/38997), [c148bee9](https://github.com/Katello/katello.git/commit/c148bee9dd206b81969a7b87e7590e775649f628), [0ffbbefc](https://github.com/Katello/katello.git/commit/0ffbbefc0c32c236719209001321faef80271287))
 * remove PXEGrub setting from Content settings ([#38988](https://projects.theforeman.org/issues/38988), [2cc25f31](https://github.com/Katello/katello.git/commit/2cc25f31aac4bcee381fbbfcb81f50e9eea655c2))
 * Host Collections are nested under Hosts/Templates instead of just Hosts ([#38977](https://projects.theforeman.org/issues/38977), [2d8304f0](https://github.com/Katello/katello.git/commit/2d8304f054c8d0f81f1e5a46f0d70f662625ba49))
 * Allow scoped search on 'persistence' field at `/api/v2/hosts/:id/packages` ([#38924](https://projects.theforeman.org/issues/38924), [68796b0a](https://github.com/Katello/katello.git/commit/68796b0a2b9bc6d8bde291e32b931497c2c47dec), [adbb150a](https://github.com/Katello/katello.git/commit/adbb150a287fb2bbf3e79d1a96990a74f180216c))
 * Registration fails if @rhsm_url is http, not https ([#38917](https://projects.theforeman.org/issues/38917), [dc514187](https://github.com/Katello/katello.git/commit/dc51418785bdd813e334c374e97e1fdff7406d45))

### Localization
 * i18n constants used as object keys for certain SelectableDropdown filters ([#38995](https://projects.theforeman.org/issues/38995), [fc2fa21e](https://github.com/Katello/katello.git/commit/fc2fa21e2a320d2114c4abd7220bcc8ab7ce7143))

### Tooling
 * Remove unused host_tasks_workers_pool_size setting ([#38990](https://projects.theforeman.org/issues/38990), [3f0b9892](https://github.com/Katello/katello.git/commit/3f0b9892e3823369e6979f62a1e8718294f9bb40))

### Subscriptions
 * suse product selection error in foreman 3.15 katello 4.17 ([#38719](https://projects.theforeman.org/issues/38719))

### Web UI
 * Breadcrumb switcher for Module stream details shows multiple entries ([#36929](https://projects.theforeman.org/issues/36929), [9b5e8afd](https://github.com/Katello/katello.git/commit/9b5e8afd733f9d88371855f4bb5628f6c6ed42f6))

### API
 * Remove deprecated field from docker repo authentication tokens ([#36888](https://projects.theforeman.org/issues/36888), [2b89a205](https://github.com/Katello/katello.git/commit/2b89a2055bff94a22784c5d6e8fd145ee9f1a050))

### Other
 * Structured APT migration rake task not marked as applied if there are no deb repos during upgrade ([#39091](https://projects.theforeman.org/issues/39091), [14735e43](https://github.com/Katello/katello.git/commit/14735e4390199cd7f99841a93a2f96d89dbeeb45))
 * Puma freezes when making HTTP requests that invoke code reload in dev ([#38961](https://projects.theforeman.org/issues/38961), [de473c60](https://github.com/Katello/katello.git/commit/de473c60ee835fc2841f1d777d7e62d0365ec835))
