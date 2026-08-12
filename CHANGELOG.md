# 5.0.0 (2026-08-12)

## Features

### HTTP Proxy
 * Use valid PEM for HttpProxy cacert in yum test ([#39577](https://projects.theforeman.org/issues/39577), [97041ca0](https://github.com/Katello/katello.git/commit/97041ca0f3a2752cedabc3c4b15a50c4b9627973))

### Container
 * Enable Katello to support syncing container gateway on containerized smart proxies ([#39576](https://projects.theforeman.org/issues/39576), [70cf5970](https://github.com/Katello/katello.git/commit/70cf5970dfb9547b03743d54b93ca26947dfd377))

### Content Views
 * Add warning to dependency solving checkbox ([#39535](https://projects.theforeman.org/issues/39535), [5d06d15e](https://github.com/Katello/katello.git/commit/5d06d15ed1edd8ae4b9bb7acdff3f6bc8f1c7989))

### Errata Management
 * Disable dependency solving default for incremental update and update UI to match ([#39519](https://projects.theforeman.org/issues/39519), [b5bfd671](https://github.com/Katello/katello.git/commit/b5bfd671f7fa9e843c86a3392ac827698cad2c71))

### Content Credentials
 * Move Content Credentials out of Labs + Remove angular CC pages ([#39516](https://projects.theforeman.org/issues/39516), [acd1ef01](https://github.com/Katello/katello.git/commit/acd1ef0149a9da47d943475819f41a015a003dc5))
 * Content Credentials overview - Create modal + Remove action ([#39332](https://projects.theforeman.org/issues/39332), [2e318164](https://github.com/Katello/katello.git/commit/2e318164153985a47679ca4e0ad043eb98158086))

### Tooling
 * Add Ruby 3.3 support to Foreman ([#39410](https://projects.theforeman.org/issues/39410), [3fe7dec0](https://github.com/Katello/katello.git/commit/3fe7dec08bea03d2a9bc7e159cc7e8e2158fa29d))

### Web UI
 * Update TooltipButton component from pf3 to pf5 ([#39390](https://projects.theforeman.org/issues/39390), [c1b690ac](https://github.com/Katello/katello.git/commit/c1b690acb3542df7181049ea3c710b7d6f203a58))

### Foreman Proxy Content
 * [RFE] Capsule content tab not showing synced content count on page. ([#39388](https://projects.theforeman.org/issues/39388), [468f03fe](https://github.com/Katello/katello.git/commit/468f03fec27ab8ce16f66c74216a83d0800b4b76))

### Hosts
 * Import only OS-detection facts at registration to keep RhelLifecycleStatus accurate ([#39213](https://projects.theforeman.org/issues/39213), [358d4ddb](https://github.com/Katello/katello.git/commit/358d4ddb7bbf98d0bd284553deb53a8187514c16))

## Bug Fixes

### Web UI
 * UX feedback on Module Streams UI ([#39573](https://projects.theforeman.org/issues/39573), [f7235e20](https://github.com/Katello/katello.git/commit/f7235e20f8ece651aa630de3b11c63b27465b89f))

### Hosts
 * Host edit page misses information about assigned Content view environment ([#39571](https://projects.theforeman.org/issues/39571), [f9037e6f](https://github.com/Katello/katello.git/commit/f9037e6f6b034751c08789d0ed77411e52820028))
 * Registration assumes that the registration smart proxy and pulpcore smart proxy are the same ([#39569](https://projects.theforeman.org/issues/39569), [ac258626](https://github.com/Katello/katello.git/commit/ac25862683c7fc43d169d5b4123765baf7efb8fe))
 * Child host group fails to inherit "Synced Content" from the parent ([#39418](https://projects.theforeman.org/issues/39418), [9448bd1a](https://github.com/Katello/katello.git/commit/9448bd1a2a77b9142a59e8bba6d801f108d8b921))

### Subscriptions
 * Subscriptions Api Returns SubTotal as the number of items filtered ([#39551](https://projects.theforeman.org/issues/39551), [df11ba76](https://github.com/Katello/katello.git/commit/df11ba76e3165a1e4ea8d10197a3f78dc32f6e30))
 * Host cleanup fails in some scenarios ([#39308](https://projects.theforeman.org/issues/39308), [0136950c](https://github.com/Katello/katello.git/commit/0136950cb8f5b657fdd0992e78cb2c25ad75f97c))

### API
 * Convert RSA references to generic PKey ([#39509](https://projects.theforeman.org/issues/39509), [580a88aa](https://github.com/Katello/katello.git/commit/580a88aa1c90556b3963159f364c8e9eb90d2d36))
 * Change singular Katello api errors from displayMessage to message ([#39400](https://projects.theforeman.org/issues/39400), [b1d64438](https://github.com/Katello/katello.git/commit/b1d64438ac9fc30cf163b4ae2305e36283761481))
 * Katello hard overrides list of valid controllers for bookmarks, preventing plugins from extending it ([#39322](https://projects.theforeman.org/issues/39322), [4ad40010](https://github.com/Katello/katello.git/commit/4ad4001045fd9616178d2dfef627a44b1f646701))

### Errata Management
 * Errata Synchronization Status Mismatch Between Default Organization View and Content View ([#39432](https://projects.theforeman.org/issues/39432), [82f99b3b](https://github.com/Katello/katello.git/commit/82f99b3b8d62920253edaf7105208f46a33b46c9))
 * Applied Errata Report generate empty ([#39185](https://projects.theforeman.org/issues/39185), [8b4d2837](https://github.com/Katello/katello.git/commit/8b4d283737475ccd6b9843d404ae487d6cf6c528))

### Repositories
 * product_content_importer do not update the content_label even if it has changed in the source for same content_id ([#39423](https://projects.theforeman.org/issues/39423), [a9920832](https://github.com/Katello/katello.git/commit/a992083213cb6d94316a03dd0d88696f710f3766))
 * Improve empty repo metadata handling for deb content ([#39054](https://projects.theforeman.org/issues/39054), [926734c3](https://github.com/Katello/katello.git/commit/926734c3ac3a5e262460a793c98f929246c0247e))
 * ContentFacet#find_by_installable_rpms finds applicable rpms, not installable ([#38746](https://projects.theforeman.org/issues/38746), [a2b5f525](https://github.com/Katello/katello.git/commit/a2b5f5255bdb8975990723160b9e7d9dfe5c09cc))

### Host Collections
 * Host collection membership updates scale poorly on large collections ([#39421](https://projects.theforeman.org/issues/39421), [cd3642b1](https://github.com/Katello/katello.git/commit/cd3642b1f2017bd34c8ef81ef82e8037a0db1912))

### katello-tracer
 * Show katello tracer installation dialog for debian based hosts ([#39312](https://projects.theforeman.org/issues/39312), [5cfed63b](https://github.com/Katello/katello.git/commit/5cfed63b5a9204d1c4de6ce811877f004259a2c0))

### Client/Agent
 * Remove old TaskStatus model ([#39222](https://projects.theforeman.org/issues/39222), [c372681a](https://github.com/Katello/katello.git/commit/c372681a5ab6d69f704c96b64d934bfd15cd88f3))
