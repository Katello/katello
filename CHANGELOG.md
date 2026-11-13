# 5.1.0 (2026-11-16)

## Features

### Tooling
 * Generate API documentation artifacts in CI ([#39988](https://projects.theforeman.org/issues/39988), [4bee61cb](https://github.com/Katello/katello.git/commit/4bee61cb08d4d7078270bc86b8e18bee812ae31d))

### Repositories
 * Organization UI should allow for dynamic selection of debug certificate algorithm. ([#39795](https://projects.theforeman.org/issues/39795), [bac17dd1](https://github.com/Katello/katello.git/commit/bac17dd15b7482dc6f6c4c579fd6b2108b87a35a))
 * As a hammer user, I can see `orphaned` info in a repository's details ([#39729](https://projects.theforeman.org/issues/39729), [9d2c0ab3](https://github.com/Katello/hammer-cli-katello.git/commit/9d2c0ab375459499cf851ed93419200c816396e8))
 * API controller layer should accept algorithm params. ([#39690](https://projects.theforeman.org/issues/39690), [f5f9e5fc](https://github.com/Katello/katello.git/commit/f5f9e5fc3a9f26f077dea99b8e16eb6bf218354a))

### Container
 * Allow to push container from smart proxy to katello ([#39763](https://projects.theforeman.org/issues/39763), [f7f40761](https://github.com/Katello/katello.git/commit/f7f40761fb76418606ec2edd5c3ab961afea36b8))

### Other
 * Adapt bulk action delete test for bulk action guard ([#39855](https://projects.theforeman.org/issues/39855), [6e273539](https://github.com/Katello/katello.git/commit/6e273539602315bf6804b9bd5c6f27bc2f47de70))
 * Add per-path proxy timeout overrides for smart proxy reverse proxy ([#39776](https://projects.theforeman.org/issues/39776))

## Bug Fixes

### Localization
 * locale/Makefile reports success without compiling anything ([#39999](https://projects.theforeman.org/issues/39999), [78495071](https://github.com/Katello/katello.git/commit/784950710efa9795a73a2a0039ff083820c3f2e8))

### Tooling
 * Gem packages the vendored bundle when one is present ([#39998](https://projects.theforeman.org/issues/39998), [246c53fa](https://github.com/Katello/katello.git/commit/246c53fa0a8199e2252a91001cd52eb28cc9d39d))

### Hosts
 * Remove separate CV and LCE managed columns from All Hosts Page ([#39986](https://projects.theforeman.org/issues/39986), [51b15666](https://github.com/Katello/katello.git/commit/51b1566628e1bf999749dabc9777c5bf2ed1874c))
 * Forward cryptographicCapabilities from RHSM proxy to Candlepin ([#39791](https://projects.theforeman.org/issues/39791), [fb057e85](https://github.com/Katello/katello.git/commit/fb057e85886510c3e41a38760a9884621b7d16e6))
 * Bulk generate applicability fails with out of range for ActiveModel::Type::Integer with limit 4 bytes ([#39780](https://projects.theforeman.org/issues/39780), [dcc00d9b](https://github.com/Katello/katello.git/commit/dcc00d9b9096628271318f3410fa044eafcad243))
 * Client failed to register to the foreman with "integer out of range" error ([#39778](https://projects.theforeman.org/issues/39778), [49d8fcec](https://github.com/Katello/katello.git/commit/49d8fcec35751d7e78a85cda5a0667239d17dcc9))
 * Attributes inherited by a child hostgroup from a parent are returned as `nil` when querying the child via API ([#39579](https://projects.theforeman.org/issues/39579), [59989cfc](https://github.com/Katello/katello.git/commit/59989cfcb0bf6f878f7cf9411a79c566c557e2e4))
 * A nested host group that inherits its content view can't be assigned a kickstart repository ([#39916](https://projects.theforeman.org/issues/39916), [bcf3796b](https://github.com/Katello/katello.git/commit/bcf3796b9b16c089327cf312349073057a802762))

### Subscriptions
 * Fix Manage Manifest clear button not working ([#39953](https://projects.theforeman.org/issues/39953), [3c63ee3b](https://github.com/Katello/katello.git/commit/3c63ee3b60fdaca84af7b9bbaf6581bd2b1fd746))
 * Adds a new hammer CLI command to retrieve subscription manifest details for an organization directly from the command line, eliminating the need to use the Satellite web UI. ([#39802](https://projects.theforeman.org/issues/39802), [3933be45](https://github.com/Katello/hammer-cli-katello.git/commit/3933be4500068644cae29ec705df209938592155))
 * Add macro to allow showing and fetching activation_key_names used to register a content host ([#39328](https://projects.theforeman.org/issues/39328), [e52bb975](https://github.com/Katello/katello.git/commit/e52bb975e1f0c4ef54203a1c2e584a1701950b22))

### Foreman Proxy Content
 * Container Gateway fails to start with a non-RSA (PQC/ML-DSA) Pulp client SSL key ([#39940](https://projects.theforeman.org/issues/39940), [8eb08cb2](https://github.com/Katello/smart_proxy_container_gateway.git/commit/8eb08cb20e400f38d7eb5fe580021a7dc045e030))
 * Container gateway fails to serve manifests due to removal of Pulp Container redirect ([#39923](https://projects.theforeman.org/issues/39923), [a4bda8e3](https://github.com/Katello/smart_proxy_container_gateway.git/commit/a4bda8e3f8876c148d6f60045fd8f0c6ff901654))
 * N-1 sync for files is broken due to the new optimize field ([#39821](https://projects.theforeman.org/issues/39821), [917a4843](https://github.com/Katello/katello.git/commit/917a484346798b94b57c77c94ad50f9fbac1b8b5))
 * Eager-load repository root in repositories_available_to_capsule ([#39788](https://projects.theforeman.org/issues/39788), [94ea0936](https://github.com/Katello/katello.git/commit/94ea0936beb47bb2aac212a9107ba6862a714dad))
 * Token endpoint crashes with NotNullConstraintViolation for clients that omit the account query parameter ([#39767](https://projects.theforeman.org/issues/39767), [f470a39d](https://github.com/Katello/smart_proxy_container_gateway.git/commit/f470a39d605137414ae2140da80efb933af97e0c))

### Activation Key
 * Activation Keys list does not show Content View Environment ([#39934](https://projects.theforeman.org/issues/39934), [3a402699](https://github.com/Katello/katello.git/commit/3a4026998fbdac052376ca3880c12d4aff3d879d))

### Content Credentials
 * "View Tasks" for individual Content Credentials is basically of no use ([#39933](https://projects.theforeman.org/issues/39933), [9385bf66](https://github.com/Katello/katello.git/commit/9385bf6618d3a14a92b67c18588486b9833a2815))

### Repositories
 * download_debug_certificate API returns 500 instead of 422 for invalid/unsupported key_algorithms ([#39928](https://projects.theforeman.org/issues/39928), [ce0dbd90](https://github.com/Katello/katello.git/commit/ce0dbd907a58c6c5fd40bee37690b6e75a513af0))
 * The "Progress / Result" column does not shows a link to task when sync task is in progress, on Sync Status page ([#39926](https://projects.theforeman.org/issues/39926), [a9f6700c](https://github.com/Katello/katello.git/commit/a9f6700caf4c8fbb9901126c29775f496e12564e))
 * Sync Status page has Org Name appended with Product name since  Katello 4.21 ([#39924](https://projects.theforeman.org/issues/39924), [49b7bac2](https://github.com/Katello/katello.git/commit/49b7bac23b1591a4cb4332ace01d7e33e89e5760))
 * Orphaned product status not shown on Sync Status page and should also show in Products pages ([#39921](https://projects.theforeman.org/issues/39921), [25f386ca](https://github.com/Katello/katello.git/commit/25f386ca0915bccdc87c25b6b693be660662a231))
 * As a user, I can push container images to pulp_container repositories ([#39896](https://projects.theforeman.org/issues/39896), [af3a3ab3](https://github.com/Katello/katello.git/commit/af3a3ab35155c73675c3dab25d110f4b8b6a7774))
 * Pulp RPM distributor tests fail with pulp_rpm_client 3.39.1 ([#39890](https://projects.theforeman.org/issues/39890), [dee144b1](https://github.com/Katello/katello.git/commit/dee144b16b8270355c9c311aaf8273ae93b504f8))
 * Sync status showing "Never synced" even though the repositories has been synced successfully ([#39853](https://projects.theforeman.org/issues/39853), [c65a46e6](https://github.com/Katello/katello.git/commit/c65a46e68d1d74e077a3d923d71a9cfb8f1e80ee))
 * Python repo distribution path is displayed incorrectly as /pulp/content/ ([#39758](https://projects.theforeman.org/issues/39758), [93553dc2](https://github.com/Katello/katello.git/commit/93553dc287c49f58a7a4130af2fbffdea873f201))
 * [RFE] As a python content user, I can specify a download policy ([#39691](https://projects.theforeman.org/issues/39691), [9b46a005](https://github.com/Katello/katello.git/commit/9b46a005d20cae0d74746587bb0a4fd3a070fdf0), [f1e5280f](https://github.com/Katello/katello.git/commit/f1e5280fba18559d8c0c017129a64dea972eadca))

### Content Views
 * Repositories "Sync state" column for a CV shows "Not synced" while a repository is actively syncing for the first time ([#39925](https://projects.theforeman.org/issues/39925), [1cd0a811](https://github.com/Katello/katello.git/commit/1cd0a8114a55ed2dca5924e154ad491bb6251d8d))
 * Remove Setting[:allow_multiple_content_views] ([#39793](https://projects.theforeman.org/issues/39793), [51c395c5](https://github.com/Katello/katello.git/commit/51c395c535c97c5c3bad1352dc94d2eafc3349c3))

### Alternate Content Sources
 * ACS should only allow adding pulp-proxies ([#39854](https://projects.theforeman.org/issues/39854), [bcbb1b52](https://github.com/Katello/katello.git/commit/bcbb1b52e2a51f1fede77aa47f7377076d2234f1))

### Upgrades
 * Update gemspec and add patches and VCRs for pulpcore upgrade to 3.118 ([#39798](https://projects.theforeman.org/issues/39798), [a4a5ed2d](https://github.com/Katello/katello.git/commit/a4a5ed2d72932c967bdf0e9c8c82b3e75bad9b5a))
 * Upgrade Issues With evr Column Not Found, preventing the Migration Scripts From Running ([#39621](https://projects.theforeman.org/issues/39621), [3b29a626](https://github.com/Katello/katello.git/commit/3b29a6269982d4659489e7447a950922a59830cf))

### Hammer
 * Hammer host info shows installable errata counts under "Applicable Errata" ([#39782](https://projects.theforeman.org/issues/39782), [6f1796f4](https://github.com/Katello/hammer-cli-katello.git/commit/6f1796f414e89ae8be20bc13c80e807fda96bd85))

### Container
 * Registry returns NAME_UNKNOWN instead of MANIFEST_UNKNOWN for missing tags ([#39766](https://projects.theforeman.org/issues/39766), [2de25882](https://github.com/Katello/katello.git/commit/2de25882a15d7afc31a349077e2abd2ea0b1fffd))

### Documentation
 * Support containerized environment in developer_docs ([#39757](https://projects.theforeman.org/issues/39757), [f230a1be](https://github.com/Katello/katello.git/commit/f230a1be7d3273395db33c582a716292c31a5d94))

### Web UI
 * prevent global override of CSS ([#39367](https://projects.theforeman.org/issues/39367), [fab9abb7](https://github.com/Katello/katello.git/commit/fab9abb7c030b5eefa05a0c89a053849752b3c6d))

### Other
 * Re-enabling a sync plan with no scheduled task raises RecurringLogicCancelledException ([#39866](https://projects.theforeman.org/issues/39866), [778a17fe](https://github.com/Katello/katello.git/commit/778a17fe5af826c07868dafbcc55183048f13047))
