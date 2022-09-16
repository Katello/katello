# 4.6 Belgian Tripel (2022-09-15)

## Features

### Content Views
 * CVV Compare - Add other content types ([#35313](https://projects.theforeman.org/issues/35313), [6a962057](https://github.com/Katello/katello/commit/6a9620577c65b5e45bbaad363f53d1264467e177))
 * CVV Compare - Add compare button and basic page for Packages ([#35118](https://projects.theforeman.org/issues/35118), [1a40f0c2](https://github.com/Katello/katello/commit/1a40f0c275a8e0b519e66a65bee8a3b300d9cc9b))

### Organizations and Locations
 * Write contentAccessModeList on org create or update; add checkbox to create screen ([#35312](https://projects.theforeman.org/issues/35312), [b38b2e7f](https://github.com/Katello/katello/commit/b38b2e7f069f6fc1b522563b66192cf90af6286f))

### Hosts
 * Details tab cards - Switch to masonry card layout instead of square grid ([#35295](https://projects.theforeman.org/issues/35295), [bc1304b2](https://github.com/Katello/katello/commit/bc1304b275671ab357fd2703ddcb1915d39dda99))
 * Add 'System purpose' card to new host details / Overview tab ([#35078](https://projects.theforeman.org/issues/35078), [9aa43b5b](https://github.com/Katello/katello/commit/9aa43b5bd5f23d909a207160982ce6f8ad8b4e07))
 * API should return simple results to understand if the repositories for hosts are enabled or not. ([#35000](https://projects.theforeman.org/issues/35000), [8f791e11](https://github.com/Katello/katello/commit/8f791e11c8081bf3a587a57d617a618524024e18))
 * Be able to retrieve the software vendor package from the installed package ([#34999](https://projects.theforeman.org/issues/34999), [193cd018](https://github.com/Katello/katello/commit/193cd018beebef8bf822498638d89346721210fd))
 * Details tab - Add Tracer to 'System properties' card ([#34962](https://projects.theforeman.org/issues/34962), [ef289e23](https://github.com/Katello/katello/commit/ef289e23df2a7a516f3aa81d9b8bfd43f2e8bc82))
 * Details tab - HW properties card ([#34904](https://projects.theforeman.org/issues/34904), [aaa05f15](https://github.com/Katello/katello/commit/aaa05f1538bd08cc89e1ec31975f09be96a55975))

### Hammer
 * Hammer support for /hosts/:id/subscriptions/enabled_repositories ([#35141](https://projects.theforeman.org/issues/35141), [c1ce6a07](https://github.com/Katello/hammer-cli-katello/commit/c1ce6a0708e0c5ba9ddcbdb99c6ed02ab88f225a))
 * As a user, I can CRUD Simplified ACSs via Hammer ([#34337](https://projects.theforeman.org/issues/34337), [ca556ee1](https://github.com/Katello/hammer-cli-katello/commit/ca556ee129698f9b33c41dbf05fd697dcb708b35))

### Web UI
 * As a user, I can view Simplified ACS details in the UI. ([#35096](https://projects.theforeman.org/issues/35096), [a9e44e26](https://github.com/Katello/katello/commit/a9e44e26abb667ed474fc562b97172a62ea98a2a))
 * Add call-to-action empty states ([#35012](https://projects.theforeman.org/issues/35012), [14fe0ffe](https://github.com/Katello/katello/commit/14fe0ffe90c6c480088a561272276703839488ed))

### API
 * Add different/same params to compare API for contents in Content view versions ([#35082](https://projects.theforeman.org/issues/35082), [befe738c](https://github.com/Katello/katello/commit/befe738cd7dae82dfaa6dbb3f226546a7f19e92e))

### Repositories
 * As a user, I can edit ACS details ([#35026](https://projects.theforeman.org/issues/35026), [bfb0b081](https://github.com/Katello/katello/commit/bfb0b08194e4df411c045a03a996309770940f9d))
 * ACS: remove last_refreshed column and enable audits on ACS changes/refreshes ([#34930](https://projects.theforeman.org/issues/34930), [1e399f16](https://github.com/Katello/katello/commit/1e399f167606ddf714864476dbed5d5ee4897ef1))
 * As a user, I can view ACS details ([#34929](https://projects.theforeman.org/issues/34929), [9c54e9d2](https://github.com/Katello/katello/commit/9c54e9d26d9a9d176fbc02c1ff290d00b08fc9bb))
 * Add Deb Repositories and Packages Tab in Lifecycle Environment ([#34793](https://projects.theforeman.org/issues/34793), [edef0061](https://github.com/Katello/katello/commit/edef00619ae6a6f393d99ef2012353e684681022))
 * As a user, I can CRUD Simplified ACSs via the API ([#34336](https://projects.theforeman.org/issues/34336), [95f66df3](https://github.com/Katello/katello/commit/95f66df3a7382f65b151617edb1aa943dd41a195))

### Other
 * CVV Compare - Add the "View By - Different/Same" dropdown ([#35323](https://projects.theforeman.org/issues/35323), [a5759f7e](https://github.com/Katello/katello/commit/a5759f7e960ab76f179d30d7d7af7d808a2bf9c7))
 * Empty Searches - adding link to clear search ([#35027](https://projects.theforeman.org/issues/35027), [37899ec7](https://github.com/Katello/katello/commit/37899ec73edf2bdd4f9e333075c9c240e506875d))
 * Drop use of pulp_client certificates ([#35004](https://projects.theforeman.org/issues/35004), [63a1499f](https://github.com/Katello/katello/commit/63a1499fe319588bed8006cffada4faccd13a532))
 * Update pulp_deb to 2.18.0 ([#34829](https://projects.theforeman.org/issues/34829), [65c23872](https://github.com/Katello/katello/commit/65c23872583555d41a6d846e39e8e8d287fe566a))

## Bug Fixes

### Hosts
 * User report: host repo files are not updating when switching lifecycle environments or content views ([#35458](https://projects.theforeman.org/issues/35458), [5ef2caca](https://github.com/Katello/katello/commit/5ef2cacaf92eb6034df94db6b174f3168483fdba))
 * new host ui details, add button to navigate to old content UI ([#35367](https://projects.theforeman.org/issues/35367), [dc10b82f](https://github.com/Katello/katello/commit/dc10b82fe5af4bc9141a7f6d20fd1fb7e24b99c4))
 * useTableSort should translate initialSortColumnName ([#35329](https://projects.theforeman.org/issues/35329), [dcdd1e06](https://github.com/Katello/katello/commit/dcdd1e061bc70d31083b44116f4cedd00d96796e))
 * new host ui, content, errata subtab,  when N/A is chosen as severity filter erratas results are empty ([#35277](https://projects.theforeman.org/issues/35277), [3da0b394](https://github.com/Katello/katello/commit/3da0b394c9bb7d76e20547d179884bc7826a68e7))
 * Show arch restrictions on Repository Sets tab (new host details) ([#35197](https://projects.theforeman.org/issues/35197), [d7199e27](https://github.com/Katello/katello/commit/d7199e270b9933712c56dc7f06e9c06eb019f763))
 * "Registered Content Hosts" Report is Showing the Wrong Available Kernel Version for RHEL 7.7 Client ([#35040](https://projects.theforeman.org/issues/35040), [f98327e1](https://github.com/Katello/katello/commit/f98327e10b5cbadfd0e060ba6b8fe468bbcc706c))
 * Overview tab (new host details) - Correct card order ([#35002](https://projects.theforeman.org/issues/35002), [21353017](https://github.com/Katello/katello/commit/213530172e0ca8ac0df7b36b221a804e980bf78d))
 * Errata overview card - Add tooltips for errata type icons ([#34769](https://projects.theforeman.org/issues/34769), [064a710f](https://github.com/Katello/katello/commit/064a710f48d7118f4db6a039be73f2d655d33ee1))
 * host registration form should include activation key selection on the first page ([#33902](https://projects.theforeman.org/issues/33902), [8ba12c34](https://github.com/Katello/katello/commit/8ba12c34f521651a243be80ac77675bd070e6eed))

### Foreman Proxy Content
 * After deploying custom certs on Satellite, signed by a new CA, capsule can't fetch on-demand content ([#35382](https://projects.theforeman.org/issues/35382), [21107ca9](https://github.com/Katello/katello/commit/21107ca9a9efd6acc5acd057688cf41355dd3463))
 * Space reclaiming fails on a blank Satellite ([#34932](https://projects.theforeman.org/issues/34932), [ba4eacff](https://github.com/Katello/katello/commit/ba4eacffb6feed5c06dcc38a878a53e4aa7e9881))

### Inter Server Sync
 * Incremental export on repository exports not working correctly after syncably exporting repository ([#35369](https://projects.theforeman.org/issues/35369), [7195abf6](https://github.com/Katello/katello/commit/7195abf66541ed6763a7c8b288a3e12aa4ed6070))
 * [RFE] Allow to export Docker images from content views or as repository as part ISS ([#35247](https://projects.theforeman.org/issues/35247), [877546b3](https://github.com/Katello/katello/commit/877546b391c7b0acc716ce3c71e4cef8ab3f99c3))
 * Missing LCE and CV label in CLI CDN configuration ([#35092](https://projects.theforeman.org/issues/35092), [65751bbe](https://github.com/Katello/hammer-cli-katello/commit/65751bbe2ccdc6b8872c17711a6c8cde4eb42524))

### Subscriptions
 * Update registration controller to check for multiple envs being passed in ([#35368](https://projects.theforeman.org/issues/35368), [bb5d05d3](https://github.com/Katello/katello/commit/bb5d05d3558f88b81578e9a87e57eac7310a9f16))
 * When toggling SCA, change the owner (not consumer) and don't refresh manifest ([#35265](https://projects.theforeman.org/issues/35265), [597b385b](https://github.com/Katello/katello/commit/597b385ba32e13d0e9764bd03c7e45644bab9482))
 * Orgs by default are in SCA mode, remove toggle sca from manage manifest modal ([#35238](https://projects.theforeman.org/issues/35238), [b306ac25](https://github.com/Katello/katello/commit/b306ac25bfbbcbf479ac43ec491175a4342e52cf))
 * Add Simple content access status API to check whether SCA is enabled or disabled in Satellite ([#35102](https://projects.theforeman.org/issues/35102), [ce43867f](https://github.com/Katello/katello/commit/ce43867f040cf596867595875cd5fccc1c0ceb26), [ee705aab](https://github.com/Katello/hammer-cli-katello/commit/ee705aabd59ff466c2a032c980bc31cdcb8fe1e0))

### Repositories
 * Katello rpm search via nvra also ([#35290](https://projects.theforeman.org/issues/35290), [d4188e57](https://github.com/Katello/katello/commit/d4188e57127c0a66c2a225bdcbd321ac071be129))
 * Not able to enable repositories when FIPS is enabled ([#35262](https://projects.theforeman.org/issues/35262), [66d9e4e7](https://github.com/Katello/katello/commit/66d9e4e7291d1041b5c2da3d22f10de773e77f18))
 * RHEL 9 appstream and baseos not showing as recommended repositories ([#35170](https://projects.theforeman.org/issues/35170), [40377cc4](https://github.com/Katello/katello/commit/40377cc48ab9b3de5c6de93813e5251c1f70fb3b))
 * Improve speed of manifest refresh by running RefreshIfNeeded steps concurrently ([#35169](https://projects.theforeman.org/issues/35169), [fccabdff](https://github.com/Katello/katello/commit/fccabdffb5bff1a902feb6ba3c9541a73e31ed65))
 * Multiples of every module stream show in the web UI ([#34792](https://projects.theforeman.org/issues/34792), [d828bb07](https://github.com/Katello/katello/commit/d828bb07060947630f0b9703653afa101449dbcd))
 * Archived content view version repositories are no longer hosted at /pulp/content ([#32846](https://projects.theforeman.org/issues/32846), [69d4da47](https://github.com/Katello/katello/commit/69d4da4767ea71810a4323c02ff0ce3969418289))

### Organizations and Locations
 * Unhide SCA checkbox in org settings for edit/create ([#35284](https://projects.theforeman.org/issues/35284), [ae3d8a61](https://github.com/Katello/katello/commit/ae3d8a6189f3732194f4872a310877d531a3628f))

### API
 * Can't create bookmarks under Lifecyle Environments ([#35276](https://projects.theforeman.org/issues/35276), [427bc170](https://github.com/Katello/katello/commit/427bc170b040d157b9389f8d5326ff5e741a855b))

### Activation Key
 * Hammer Allows Invalid Release Version to be Set on Activation Key ([#35236](https://projects.theforeman.org/issues/35236), [8b478a0a](https://github.com/Katello/katello/commit/8b478a0a3a2b35e44556241bdbe954a15b73e6ee))
 * The value set by 'hammer activation-key content-override'command cannot be confirmed by 'hammer activation-key info' command. ([#35032](https://projects.theforeman.org/issues/35032), [4020064d](https://github.com/Katello/hammer-cli-katello/commit/4020064d758b317300da1092dec14e71e486acf3))

### Tests
 * JS test improvements - assertNockRequest & nock.cleanAll() ([#35165](https://projects.theforeman.org/issues/35165), [8eac390c](https://github.com/Katello/katello/commit/8eac390cac53bd7f99bff7165fc472578dcee1bf))

### Web UI
 * Hide table toolbar / filter dropdowns for empty states ([#35074](https://projects.theforeman.org/issues/35074), [58f822fa](https://github.com/Katello/katello/commit/58f822fad9c54942155e75317735d47ec0663980))
 * Rails 6: "`render file:` should be given the absolute path to a file. 'layouts/base' was given instead" ([#34952](https://projects.theforeman.org/issues/34952), [155fa6f9](https://github.com/Katello/katello/commit/155fa6f9416b078b48c1d8fca35761e9acc45f5f))
 * CV UI - Standardize empty state across all tables ([#34472](https://projects.theforeman.org/issues/34472), [658d4c8c](https://github.com/Katello/katello/commit/658d4c8c1c45c8be6fa35db580197f02040d58c2))

### Content Uploads
 * ActionController::BadRequest when uploading RPMs via Hammer ([#34984](https://projects.theforeman.org/issues/34984), [2be708d3](https://github.com/Katello/katello/commit/2be708d33aaafaaa420963a31cba308f86274bee))

### Hammer
 * hammer host-collection update inconsistent with create ([#34889](https://projects.theforeman.org/issues/34889), [2ef8866d](https://github.com/Katello/hammer-cli-katello/commit/2ef8866d3368ba26d87324e0eb6357aa7272a65c), [ee7e0d16](https://github.com/Katello/katello/commit/ee7e0d167f2354d7a529e9ff9ac8eb7843d08b54))

### Other
 * New host details UI does not work at all ([#35336](https://projects.theforeman.org/issues/35336), [64d5fb76](https://github.com/Katello/katello/commit/64d5fb76ecf6df8dc0eb668f91d7b6398ae1155c))
 * No longer receive errata email notification after syncing repository when there are new errata. ([#35053](https://projects.theforeman.org/issues/35053), [08594eb0](https://github.com/Katello/katello/commit/08594eb09f5821bae5f20a3c64639037c38267ad))
 * Update grunt-bower-task to use NPM published version ([#17050](https://projects.theforeman.org/issues/17050), [0a179cb6](https://github.com/Katello/katello/commit/0a179cb621c34831252ad2c0f814139858a33f00))
