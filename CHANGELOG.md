# 4.17.2 Fallingwater (2025-11-26)

## Bug Fixes

### Hammer
 * Hammer host info command fields contain abbreviations ([#38703](https://projects.theforeman.org/issues/38703), [01964f16](https://github.com/Katello/hammer-cli-katello.git/commit/01964f168e2d4c63b7af8efe805ee79a24c65536), [9258e0af](https://github.com/Katello/hammer-cli-katello.git/commit/9258e0af0fbab281d0300ca1e4cf691781ddaf41))

### Content Views
 * Error "Katello::Resources::Candlepin::Environment: 404 Not Found" When Deleting Rolling Content View ([#38689](https://projects.theforeman.org/issues/38689), [21b4d5c6](https://github.com/Katello/katello.git/commit/21b4d5c61d2b7e364ce9d8b0b49c07639c368205))
 * Repo removal from a rolling CV does not trigger the Capsule sync ([#38561](https://projects.theforeman.org/issues/38561), [6966677d](https://github.com/Katello/katello.git/commit/6966677dc3e91bcd5832ecf0feebeb1eb5845ca3))

### Other
 * Async Repository::CapsuleSync tasks that don't find any relevant proxies to sync sometimes end up in failing state ([#38546](https://projects.theforeman.org/issues/38546), [a1f951cd](https://github.com/Katello/katello.git/commit/a1f951cd55e7cf58de7413caf70b374164dfce6d))
# 4.17.1 Fallingwater (2025-07-31)

## Bug Fixes

### Hammer
 * Remove rolling CVs from hammer host info commands in hammer-cli-katello 1.17 ([#38612](https://projects.theforeman.org/issues/38612))

### Hosts
 * After installing a package via the --transient flag on an image mode host, any template that uses bootc usr-overlay will fail to perform package actions ([#38508](https://projects.theforeman.org/issues/38508), [5053686f](https://github.com/Katello/katello.git/commit/5053686f91483d25fc32a8164ce293385d84ff18))

### Repositories
 * Do not delete candlepin content when deleting a rolling repo clone of a structured apt deb repository ([#38440](https://projects.theforeman.org/issues/38440), [1a793acb](https://github.com/Katello/katello.git/commit/1a793acb30116340e3446cdb86610536386ca531))

# 4.17.0 Fallingwater (2025-06-09)

## Features

### Hosts
 * As a user, I can install transient packages on image mode hosts via REX ([#38377](https://projects.theforeman.org/issues/38377), [ea81b3c3](https://github.com/Katello/katello.git/commit/ea81b3c389b38a17d6e336a656eccf8c9c28be71))
 * Warn users that a package installed to an image mode host will be transient ([#38350](https://projects.theforeman.org/issues/38350), [308d91b5](https://github.com/Katello/katello.git/commit/308d91b5c7b280d5b7a1f54df95b941cf055a89b))

### Container
 * Add container gateway support for redirecting clients to Pulp content at a different FQDN ([#38304](https://projects.theforeman.org/issues/38304), [3db73cf3](https://github.com/Katello/smart_proxy_container_gateway.git/commit/3db73cf3469c3c1a2a53a0de4943a39ce1b3b3d3))

### Subscriptions
 * Use Foreman client certificates to talk to Candlepin ([#38297](https://projects.theforeman.org/issues/38297), [1a5b7dce](https://github.com/Katello/katello.git/commit/1a5b7dcedaa908a69a971e21bc5564d007fb6967))

### Content Views
 * Add rolling content views ([#38048](https://projects.theforeman.org/issues/38048), [a300f970](https://github.com/Katello/katello.git/commit/a300f9707f3e4c62eaa3e8856e6fe3989f2f9f6d), [9d17dc77](https://github.com/Katello/hammer-cli-katello.git/commit/9d17dc7739b6ed18614fe987db684a842453ddfb))

### Repositories
 * Add hammer support for flatpak remotes ([#38019](https://projects.theforeman.org/issues/38019), [4eab7ae1](https://github.com/Katello/hammer-cli-katello.git/commit/4eab7ae1f91bc21d8dfe0cd8baa62cce5d0d8527))

## Bug Fixes

### Hosts
 * subscription-manager environments --set raises Forbidden error until the user is Admin ([#38448](https://projects.theforeman.org/issues/38448), [72f7a98f](https://github.com/Katello/katello.git/commit/72f7a98f7cfaebba46c4dbf6838a399b3c9d131f))
 * Move of Ansible-based job templates to "Katello via Ansible" through seeds may not be propagated on already existing installations ([#38366](https://projects.theforeman.org/issues/38366), [70498359](https://github.com/Katello/katello.git/commit/70498359db942bce6439757b86c5872bc40baae4))
 * New Host UI Bulk wizards fail to render ([#38342](https://projects.theforeman.org/issues/38342), [0a9a4a32](https://github.com/Katello/katello.git/commit/0a9a4a32543d95af989809d71203e74be0b46afb))
 * Add unit test cases to image mode card. ([#38323](https://projects.theforeman.org/issues/38323), [1c4e1cfb](https://github.com/Katello/katello.git/commit/1c4e1cfb4d5d0adf03f055415daa8a59da452f16))

### Content Views
 * When creating a rolling content view with repository_ids no rolling repo clones are created ([#38413](https://projects.theforeman.org/issues/38413), [eff2f62a](https://github.com/Katello/katello.git/commit/eff2f62a0aa67010657828ba5ad337f83493718b))
 * rolling attribute is missing from activation key API response ([#38411](https://projects.theforeman.org/issues/38411), [d934b0f6](https://github.com/Katello/katello.git/commit/d934b0f6eb614d916092e5d0129e3719433c333b))
 * PF5 issue: Bad icon spacing ([#38337](https://projects.theforeman.org/issues/38337), [1e37a44c](https://github.com/Katello/katello.git/commit/1e37a44c6ea3f0f1fae74b05b98b4f2baebe81c6))
 * Disallow pushing containers to rolling content views ([#38285](https://projects.theforeman.org/issues/38285), [197bf2f2](https://github.com/Katello/katello.git/commit/197bf2f27f3c08dac970b1833d14c7725e36994e))
 * Remove version from environment wizard still makes you choose a replacement cv/lce even if it will be ignored ([#38191](https://projects.theforeman.org/issues/38191), [87dc8cfc](https://github.com/Katello/katello.git/commit/87dc8cfc18dedbea67c59233392a6528e14a979e))
 * needs_publish is incorrect before page refresh ([#38007](https://projects.theforeman.org/issues/38007))

### Repositories
 * Add organization to the Katello repositories API  response ([#38399](https://projects.theforeman.org/issues/38399), [cb3c9bf8](https://github.com/Katello/katello.git/commit/cb3c9bf84e59158f5a786c9471413606cd008ecb))
 * Updating file type repository fails due to Download Policy not being set ([#38369](https://projects.theforeman.org/issues/38369), [658c07aa](https://github.com/Katello/katello.git/commit/658c07aa8e4e46a789682cad01225aff1c18e04a))
 * APT repos using path prefixes for components will be misconfigured on consuming hosts ([#38359](https://projects.theforeman.org/issues/38359), [c26a27b7](https://github.com/Katello/katello.git/commit/c26a27b7d090a62af59f8151c427eca80406c3d2))
 * Duplicity in recommended RH repos ([#38308](https://projects.theforeman.org/issues/38308), [871b862a](https://github.com/Katello/katello.git/commit/871b862a1daf09bde35cebaf34228ea3084e57ac))
 * Debian repos are not displayed in the Repository Set Management on the Content Hosts page ([#38296](https://projects.theforeman.org/issues/38296), [d6cf242d](https://github.com/Katello/katello.git/commit/d6cf242d01e1fea3cdfdf64262c8282b4e87b038))
 * Orphan deletion fails with "The repository version cannot be deleted because it (or its publications) are currently being used to distribute content. Please update the necessary distributions first." ([#38205](https://projects.theforeman.org/issues/38205), [193274e8](https://github.com/Katello/katello.git/commit/193274e8c9f61f2271e0b7eb8f1b6513a64c67e5))
 * Content Override on deb type host with structured APT enabled bulk-action issue ([#38009](https://projects.theforeman.org/issues/38009), [6b69f0d1](https://github.com/Katello/katello.git/commit/6b69f0d1fbef79d71dd22453668e97e7350f2cd3))

### Foreman Proxy Content
 * The "Refresh Counts" button fails to work after the lifecycle environment is removed and then re-added. ([#38376](https://projects.theforeman.org/issues/38376), [b4c502a2](https://github.com/Katello/katello.git/commit/b4c502a27ba2e5091153b1f74d09849a823cb690))
 * Smart proxy sync status doesn't handle partially synced CVs ([#38314](https://projects.theforeman.org/issues/38314), [3380d81e](https://github.com/Katello/katello.git/commit/3380d81ea951dd291c986c02e8b8db4d1e2bb258))
 * Syncing rolling content views to smart proxies does not update proxy content counts ([#38284](https://projects.theforeman.org/issues/38284), [0b7fed99](https://github.com/Katello/katello.git/commit/0b7fed99cb06d565879d9e6db8a98f96e75ca36b))
 * Refresh content counts action on Smart proxy fails when content_counts is set to {} ([#38056](https://projects.theforeman.org/issues/38056), [fa899c07](https://github.com/Katello/katello.git/commit/fa899c07b9da9ad085f9ba5b68850c952cb299ee))
 * Smart proxy content page console error when count is {} ([#38015](https://projects.theforeman.org/issues/38015), [257c4ca8](https://github.com/Katello/katello.git/commit/257c4ca89b063d57b211afd285c1b48f93c37eac))

### Organizations and Locations
 * download_debug_certificate doesn't accept org label ([#38365](https://projects.theforeman.org/issues/38365), [87b62c21](https://github.com/Katello/katello.git/commit/87b62c2124b7d09fdbfba659827aaf09974c6711))
 * Label option is removed while creating new Organization in UI ([#38025](https://projects.theforeman.org/issues/38025), [d3a9089c](https://github.com/Katello/katello.git/commit/d3a9089c6cf3a65a990b461c93922abf2642971e))

### Roles and Permissions
 * container_gateway on capsules returns success for login attempts with no username/password informed ([#38349](https://projects.theforeman.org/issues/38349), [48424ed5](https://github.com/Katello/smart_proxy_container_gateway.git/commit/48424ed5131f704af29064ade56ee05797bd5087))

### Hammer
 * Missing "Product Host Count" column in Hammer CLI subscription list output ([#38341](https://projects.theforeman.org/issues/38341), [862bbe55](https://github.com/Katello/hammer-cli-katello.git/commit/862bbe5583f940d603f9997da27359577aea6be0))
 * Assigning  multiple CVs to a client via hammer fails with error 500 when allow_multiple_content_views setting is disabled ([#38253](https://projects.theforeman.org/issues/38253))
 * hammer does not propagate errors in host update ([#37955](https://projects.theforeman.org/issues/37955))

### Errata Management
 * PF5 issue: Toggle groups render incorrectly ([#38334](https://projects.theforeman.org/issues/38334), [92e57771](https://github.com/Katello/katello.git/commit/92e57771965d074c6fe5dbcfa97272ccebd6b921))

### Lifecycle Environments
 * Console error in /lifecycle_environments/{id}: this.repositoryType is not a function ([#38312](https://projects.theforeman.org/issues/38312), [8302fe2b](https://github.com/Katello/katello.git/commit/8302fe2b9204268a64e7b06f0021bcb8b1c99c50))
 * Remove version from environment wizard doesn't enforce content source LCE rules ([#38190](https://projects.theforeman.org/issues/38190), [c03f4c6b](https://github.com/Katello/katello.git/commit/c03f4c6b0abacdfa1a00f0ec072f5b7f0d7000d9))

### Upgrades
 * Unskip the 2 skipped UI tests ([#38310](https://projects.theforeman.org/issues/38310), [fc2993da](https://github.com/Katello/katello.git/commit/fc2993da69fd8d3bea8d25606cb3c61fbd5fa6fa))

### Container
 * Organization-label can break container image sync ([#38269](https://projects.theforeman.org/issues/38269), [c81dc110](https://github.com/Katello/katello.git/commit/c81dc110ff1a3a3ed1fdc6cd65a1a9f0f614a104))

### katello-tracer
 * python2 / python3 interop issue ([#37377](https://projects.theforeman.org/issues/37377))
