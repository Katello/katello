# 4.3.0 Ghost Pepper (2022-01-06)

## Features

### Activation Keys
* Allow accessing the ActivationKey name in the safe mode ([#33818](https://projects.theforeman.org/issues/33818), [574136ae](https://github.com/Katello/katello.git/commit/574136ae75b96b2ece56a0f7c8a6233547e1551b))

### Hammer
* Add hammer support for viewing generic content units ([#33837](https://projects.theforeman.org/issues/33837), [3fea3152](https://github.com/Katello/hammer-cli-katello.git/commit/3fea31527c59121036fe89c030b18f1fedf123ae))

### Subscriptions
 * Bump up distributor version to 6.10 ([#34102](https://projects.theforeman.org/issues/34102), [cc6b4d5f](https://github.com/Katello/katello.git/commit/cc6b4d5f5affc9dce8c276892e31cb06a85d5284))

### Repositories
 * support pulp-rpm's sync_policy to give better control on mirroring options ([#33939](https://projects.theforeman.org/issues/33939), [281e9ee9](https://github.com/Katello/katello.git/commit/281e9ee968d46107556f00da86a8fc3a2f836ccb), [2fe15f43](https://github.com/Katello/katello.git/commit/2fe15f43488e9b5f984f77a3ebc4451b2db9554c))
 * Support restricting repository to rhel 9 clients ([#33923](https://projects.theforeman.org/issues/33923), [9feababd](https://github.com/Katello/katello.git/commit/9feababd9f3e2b859426422ae170cd2953f334f9))
 * Support 'cleaning' a repo of downloaded on_demand content ([#33919](https://projects.theforeman.org/issues/33919), [cb8ac796](https://github.com/Katello/katello.git/commit/cb8ac796e21571de5c25de013e1295790390d327))
 * support pulp 3.15 ([#33652](https://projects.theforeman.org/issues/33652), [a7067d14](https://github.com/Katello/katello.git/commit/a7067d14fff4310e9b594c36f81ee95217a4d6c5), [7306fdb0](https://github.com/Katello/katello.git/commit/7306fdb07e7beaf726e2dcf82608c8b2d51ccab1), [c87adcfa](https://github.com/Katello/katello.git/commit/c87adcfa3cefb9593ff8a450ba8a6b62c0ce3159))
 * Add download_policy setting for Deb-repositories ([#33578](https://projects.theforeman.org/issues/33578), [53a31d6b](https://github.com/Katello/katello.git/commit/53a31d6b8aaf4ba3a296e31b1dda7ee125b383ad))
 * show new content counts as part of sync task status ([#33509](https://projects.theforeman.org/issues/33509), [1b0ea93b](https://github.com/Katello/katello.git/commit/1b0ea93be447779cdc9101ee8eefd62364c01383))
 * Integrate Pulp3 ULN support into Katello ([#33250](https://projects.theforeman.org/issues/33250), [b781e6af](https://github.com/Katello/katello.git/commit/b781e6af48499137ccf74b57f1b70fbe079673c5), [11eed6aa](https://github.com/Katello/katello.git/commit/11eed6aaf588f17a23c1be10c2667bc5af810707))
 * Applicability for deb packages ([#27625](https://projects.theforeman.org/issues/27625), [d519e0fd](https://github.com/Katello/katello.git/commit/d519e0fde4c839522719d6af663a3c40c0adef5b), [f3ab52fb](https://github.com/Katello/katello.git/commit/f3ab52fb60173ade330626ba542b413cf8900427))
 * As a user I can publish OSTree repositories to a content view ([#33296](https://projects.theforeman.org/issues/33296), [6e2a6137](https://github.com/Katello/katello.git/commit/6e2a6137f67c9b101cafa6d232d3ce0478118c21))
 * As a user I can sync an OSTree repository with the UI ([#33295](https://projects.theforeman.org/issues/33295), [b675b814](https://github.com/Katello/katello.git/commit/b675b814a1f063c6d8567ad8497d0ad1bce9eea5))
 * As a user I can sync an OSTree repository with the CLI/API ([#33294](https://projects.theforeman.org/issues/33294), [c7a24cd9](https://github.com/Katello/katello.git/commit/c7a24cd9de9a4f7ecfcfcecd969079c749820a14))
 * As a user, I can upload an OSTree archive with the CLI/API ([#33292](https://projects.theforeman.org/issues/33292), [716cc8a7](https://github.com/Katello/katello.git/commit/716cc8a7eff6779a78e3a15435b697a4bc90332f), [9c0fde1d](https://github.com/Katello/hammer-cli-katello.git/commit/9c0fde1de84d462a2ee648187900cf431e2fedf6), [d10ac48b](https://github.com/Katello/katello.git/commit/d10ac48b00a2be2b4e1f8c563b61bec532cab3be), [9e6333a9](https://github.com/Katello/katello.git/commit/9e6333a9ffa881cf00102fc862a85f04909dbebc))
 * OSTree repositories and content are synced to external capsules ([#33303](https://projects.theforeman.org/issues/33303), [7e276eba](https://github.com/Katello/katello.git/commit/7e276eba47723420627731454c8fba1cf3ba375b))
 * Add json of extra metadata to generic content model ([#33780](https://projects.theforeman.org/issues/33780), [19372d28](https://github.com/Katello/katello.git/commit/19372d286b88264ec8bf53d111de99580d19011f))
 * Add filename attribute to python packages ([#33650](https://projects.theforeman.org/issues/33650), [04197518](https://github.com/Katello/katello.git/commit/0419751898683514ba6c153b26d9617982334507))

### Tooling
 * Support smart_proxy_pulp's exposed rhsm_url setting ([#33899](https://projects.theforeman.org/issues/33899), [94770d21](https://github.com/Katello/katello.git/commit/94770d212ca36db418dc6265bc250df26a63eb49))
 * Upgrade Pulpcore and plugins to 3.16 ([#33832](https://projects.theforeman.org/issues/33832), [2068c4e4](https://github.com/Katello/katello.git/commit/2068c4e4c57c30a0a22185665748dafd73774346))
 * Add "What was your strategy?" question to PR template ([#33708](https://projects.theforeman.org/issues/33708), [f176d979](https://github.com/Katello/katello.git/commit/f176d979c4f25a695e292658c2f9f25209e02b7c))
 * Add PR template to remind contributors to add context and testing steps ([#33571](https://projects.theforeman.org/issues/33571), [873c50aa](https://github.com/Katello/katello.git/commit/873c50aaf5287f8c78a8de41d9479da5de9b69a5))
 * Modify generic content units controller to be Apipie compatible ([#33838](https://projects.theforeman.org/issues/33838), [73323fb4](https://github.com/Katello/katello.git/commit/73323fb4a23e18e8484842307018c7dd91a5bbe5))
 * Add GraphQL type for host collections ([#33655](https://projects.theforeman.org/issues/33655), [fbf1fcb7](https://github.com/Katello/katello.git/commit/fbf1fcb7b377f867d79775307f95f594c0c7557a))

### Inter Server Sync
 * UI for Connected ISS ([#33874](https://projects.theforeman.org/issues/33874), [8f098309](https://github.com/Katello/katello.git/commit/8f0983097bd100b883e7636ee394c0f0938db4b1), [c19f7b46](https://github.com/Katello/katello.git/commit/c19f7b4629ed3d71bf9a80bb901e128b86b60dd6))
 * Support connected Inter Server Sync ([#33783](https://projects.theforeman.org/issues/33783), [d40c039b](https://github.com/Katello/katello.git/commit/d40c039b808da04029f21788575f28a2cce446e2), [a6f67a99](https://github.com/Katello/hammer-cli-katello.git/commit/a6f67a99c271543821dbb167f86b1c5571e54906))

### Content Views
 * Needs Dot Bullet to distinguised environment for Composite Content View ([#33858](https://projects.theforeman.org/issues/33858), [5082da8e](https://github.com/Katello/katello.git/commit/5082da8e7b1c4858dd56b04a52d8363090e2337e))
 * UI for 'force deleting' a repository if it's included in content view versions ([#33779](https://projects.theforeman.org/issues/33779), [b4d0977b](https://github.com/Katello/katello.git/commit/b4d0977b87ca4c5c8d925d0c1e0e23c3fa761a8d))
 * API support for 'force deleting' a repository if it's included in content view versions ([#33709](https://projects.theforeman.org/issues/33709), [33d7f724](https://github.com/Katello/katello.git/commit/33d7f7246094248f1093b681fdf867f4e38b9f5a))
 * CV UI - Add permissions to new CV UI workflows ([#33668](https://projects.theforeman.org/issues/33668), [c2963222](https://github.com/Katello/katello.git/commit/c2963222c1ef3e2ee41ba26817c01ab0441b641c))
 * CV UI - Support bulk adding component CVs to composite CVs ([#33667](https://projects.theforeman.org/issues/33667), [174d616f](https://github.com/Katello/katello.git/commit/174d616f188e294cded027314bebbe9538ff5011))
 * New Content View Page - Add Added/Available/All to the content view filter details page ([#31970](https://projects.theforeman.org/issues/31970), [1af1bfde](https://github.com/Katello/katello.git/commit/1af1bfde8196c245d949c7725493397fa4642caf))

### Hosts
 * [SAT-4229] Packages - basic table ([#33849](https://projects.theforeman.org/issues/33849), [1324d8c8](https://github.com/Katello/katello.git/commit/1324d8c8c0ab759258c192334b987bf96837fadb))
 * Migrate host to new proxy ([#33673](https://projects.theforeman.org/issues/33673), [817e7c41](https://github.com/Katello/katello.git/commit/817e7c412d8ef862370fc3c8c6eb0273247fa12b))
 * [SAT-4229] Content - Errata - Recalculate ([#33516](https://projects.theforeman.org/issues/33516), [da26df34](https://github.com/Katello/katello.git/commit/da26df34d2f760ffc6384404facf7d51d4d863d5))
 * [SAT-4229] New host details Content - Errata - Table row expansion ([#33485](https://projects.theforeman.org/issues/33485), [eb236dac](https://github.com/Katello/katello.git/commit/eb236dac08b02b1b3ac8143fe50cae4d87c4ba61))

### Web UI
 * UI for listing generic content units at repository level + removal support ([#33616](https://projects.theforeman.org/issues/33616), [ee9adf33](https://github.com/Katello/katello.git/commit/ee9adf332ba65ee6199408343aa3fd8fb79536b3))
 * CV UI - Breadcrumbs for all CV Pages ([#33552](https://projects.theforeman.org/issues/33552), [ca9556f8](https://github.com/Katello/katello.git/commit/ca9556f88bd6a1be4a60f5cc9da3e9497767278e))
 * Add Bookmarks to TableWrapper ([#33548](https://projects.theforeman.org/issues/33548), [5b9fc40d](https://github.com/Katello/katello.git/commit/5b9fc40d858de1b01fd8ce5692c9185cf51b87f6))
 * CV UI - Switch new and old UI urls ([#33547](https://projects.theforeman.org/issues/33547), [d8552ffa](https://github.com/Katello/katello.git/commit/d8552ffaf7f63735919a99f4f114d69d83382385))
 * CV UI - Allow editing filters (name, description) inline on Filter details page ([#33546](https://projects.theforeman.org/issues/33546), [570433ef](https://github.com/Katello/katello.git/commit/570433ef3da9a742bebeb8cde51decc1e0fc6dca))
 * CV UI - Add errata filter rule by ID to CV filter ([#33400](https://projects.theforeman.org/issues/33400), [1ba9d677](https://github.com/Katello/katello.git/commit/1ba9d67772d2e3ed78566850cfff489f37bde776))
 * CV UI - Add errata filter rule by Data range to CV filter ([#33399](https://projects.theforeman.org/issues/33399), [d9f7d1c7](https://github.com/Katello/katello.git/commit/d9f7d1c7e54f9a1401acd4a2ee6e2ed0dc70579c))
 * Secondary tabs should be routable in the new host details ([#33350](https://projects.theforeman.org/issues/33350), [f234e288](https://github.com/Katello/katello.git/commit/f234e288529693d0df68fff1b34bc1c6c12003e8))
 * CV UI - Add affected repository tab to Filter details page ([#33336](https://projects.theforeman.org/issues/33336), [a0dc13f3](https://github.com/Katello/katello.git/commit/a0dc13f3faeaa36cf491b59ec55073f1208a5118))
 * New Content View Page - Add module stream filter detail page ([#33252](https://projects.theforeman.org/issues/33252), [f73b9d4b](https://github.com/Katello/katello.git/commit/f73b9d4b74551e1e730c7b0b1aa8274adaa8dfbb))
 * Add pagination component to the bottom of the table for tablewrapper ([#33181](https://projects.theforeman.org/issues/33181), [1d53aab9](https://github.com/Katello/katello.git/commit/1d53aab990a6f488b6c04311a86278ea6a469797))
 * CV UI - Implement Matching content modal for RPM Filter rules ([#33117](https://projects.theforeman.org/issues/33117), [7a4e3e8d](https://github.com/Katello/katello.git/commit/7a4e3e8d199cbe682a74a2f22705fd100a05297d))
 * CV UI - Add/Remove Package Group Filter rules to Package Group Filters ([#33116](https://projects.theforeman.org/issues/33116), [84999860](https://github.com/Katello/katello.git/commit/8499986002eefabd9cb3794869c13f2378a206f1))
 * CV UI - Delete RPM Filter rules from RPM Filters ([#33114](https://projects.theforeman.org/issues/33114), [debd00ba](https://github.com/Katello/katello.git/commit/debd00ba7ccdbd2d5b6594e194b5a99512c8018d))
 * CV UI - Add RPM Filter rules to RPM Filters ([#33113](https://projects.theforeman.org/issues/33113), [4c1f972a](https://github.com/Katello/katello.git/commit/4c1f972a796489210e874c70298ea1a29544cb74))
 * [SAT-4231] Traces - Basic read-only table ([#33076](https://projects.theforeman.org/issues/33076), [b5744807](https://github.com/Katello/katello.git/commit/b574480741df4526bda26c01d657dd066e504673))
 * New Content View Page - Add container tag filter detail page ([#32638](https://projects.theforeman.org/issues/32638), [81463080](https://github.com/Katello/katello.git/commit/81463080c69222abd8d66957f8dd2fd888824374))
 * CV UI - Add Related Content Views and content view counter to new cv index page. ([#32431](https://projects.theforeman.org/issues/32431), [f29d989b](https://github.com/Katello/katello.git/commit/f29d989b829005ab7df784951d5bba1483f13927))
 * UI Remote Options Support for Generic Content Types ([#33166](https://projects.theforeman.org/issues/33166), [516c673f](https://github.com/Katello/katello.git/commit/516c673f2bed2197eafd4aff86c700e6062abc4f))
 * [SAT-1790] New Host details overview - Content view details card ([#33084](https://projects.theforeman.org/issues/33084), [131352fb](https://github.com/Katello/katello.git/commit/131352fb93ae09d699f0d6097f12d990d9380904))
 * [SAT-4231] Traces - Restart via remote execution ([#33081](https://projects.theforeman.org/issues/33081), [0f337f23](https://github.com/Katello/katello.git/commit/0f337f23c36a75791d08e39aa30ec53f91150ce4))
 * [SAT-4231] Traces - Bulk select & restart ([#33078](https://projects.theforeman.org/issues/33078), [06b3f66c](https://github.com/Katello/katello.git/commit/06b3f66ce9609ac3e93d124f6cf14734c9ca9e0a), [5a755505](https://github.com/Katello/katello.git/commit/5a755505f17a5dee46a89b88f34312f101cc532c))
 * [SAT-4231] Traces - Enable Tracer button ([#33077](https://projects.theforeman.org/issues/33077), [8420ae57](https://github.com/Katello/katello.git/commit/8420ae573aece19b34578d568dce4858a5a2bf48))
 * [SAT-4234] New Host details - Repository sets tab - basic table ([#33073](https://projects.theforeman.org/issues/33073), [e6ff331c](https://github.com/Katello/katello.git/commit/e6ff331ca70084a5b5465f7313be87e8d9375d89))
 * CV UI - Add Promote workflow to new CV UI (Component CVs) ([#32509](https://projects.theforeman.org/issues/32509), [49005039](https://github.com/Katello/katello.git/commit/490050398f5c2153ae8598c3fed3dff57f943aa0))
 * New Host details Errata - Filter by type & severity ([#33834](https://projects.theforeman.org/issues/33834), [a764d607](https://github.com/Katello/katello.git/commit/a764d6079de7c3973075efe2e9881a068c8ea84a))
 * Generic Content Browsing UI: Details/Repositories Tabs ([#33524](https://projects.theforeman.org/issues/33524), [5908354d](https://github.com/Katello/katello.git/commit/5908354d86c87ba4477a8126583f76d69c68fc7b))
 * Landing page UI for browsing generic content units ([#33435](https://projects.theforeman.org/issues/33435), [b51fde63](https://github.com/Katello/katello.git/commit/b51fde633242cce79aa65ef5bc3611971c4d2ea1))
 * Move Ansible Collections Content page to the generic UI ([#33720](https://projects.theforeman.org/issues/33720), [8c6803a0](https://github.com/Katello/katello.git/commit/8c6803a0750f2bb9d091a7d9e19120ffd774bcdf))

### API
 * Expose on the Katello API the ability to sync only an individual Content View or Repository to a Smart Proxy ([#33120](https://projects.theforeman.org/issues/33120), [d55f74dd](https://github.com/Katello/katello.git/commit/d55f74dd8a4b60ce476f542537bdb7ed96f1b926))

## Bug Fixes

### Content Views
 * undefined local variable or method `cv' for Katello::ComponentViewPresenter:Class ([#34147](https://projects.theforeman.org/issues/34147), [1a91a931](https://github.com/Katello/katello.git/commit/1a91a93198e8d361f7f1a3b3d3c3947797368107))
 * CVV Import fails due to new Pulp 3.16 task return ([#33971](https://projects.theforeman.org/issues/33971), [b5ed7567](https://github.com/Katello/katello.git/commit/b5ed7567a1f125cdd387c3cfbfb8060b127819c8))
 * Remove Greedy DepSolving from UI ([#33859](https://projects.theforeman.org/issues/33859), [29aaad9e](https://github.com/Katello/katello.git/commit/29aaad9ee60b60e8ea6860c6c3258d130e95e0a9))
 * CV UI - CV Version page tries to re-register polling with same ID when switching tabs ([#33856](https://projects.theforeman.org/issues/33856), [68129737](https://github.com/Katello/katello.git/commit/6812973721f8e1f6542980bbc2f2f474401ef168))
 * Cannot add filter on same RPM name with different architectures ([#33855](https://projects.theforeman.org/issues/33855), [92d61844](https://github.com/Katello/katello.git/commit/92d6184444a0f4d2cfb70062539a543f3b4a6d58))
 * middle clicking on new content view UI tabs does not open them in a new browser tab ([#33683](https://projects.theforeman.org/issues/33683), [882f5e59](https://github.com/Katello/katello.git/commit/882f5e59400a1560a874ba79a67e4f88bb258dfc))
 * Updating CV version sometimes throws an error - This content view version doesn't have a history. ([#33654](https://projects.theforeman.org/issues/33654), [edb22ae7](https://github.com/Katello/katello.git/commit/edb22ae79877564ebb3f293945261432865292d7))
 * Repository Clear failed ([#33354](https://projects.theforeman.org/issues/33354), [6c85818a](https://github.com/Katello/katello.git/commit/6c85818acca53fdb92b0f87edcf6d5bed9f972ed))
 * Enter key doesn't work when creating a content view filter ([#33288](https://projects.theforeman.org/issues/33288), [fa47f3f9](https://github.com/Katello/katello.git/commit/fa47f3f9a9182e5d7f8946e58ca4f616917b6180))
 * Searching for content view filter with just "inclusion_type" will return ISE ([#31523](https://projects.theforeman.org/issues/31523), [20798322](https://github.com/Katello/katello.git/commit/2079832287a023756f725d8d25cb2857a2cb193a))

### Web UI
 * [SAT-4229] - Installable Errata overview card ([#34104](https://projects.theforeman.org/issues/34104), [9f13ead8](https://github.com/Katello/katello.git/commit/9f13ead8b2298e24de1ebe9779db06e811a2dcf0))
 * UX Review - Actions on CV details page ([#34057](https://projects.theforeman.org/issues/34057), [be3094cc](https://github.com/Katello/katello.git/commit/be3094cc6548bb46c78ca46690026329961af12c))
 * UX Review - Actions on Version details page ([#34043](https://projects.theforeman.org/issues/34043), [635132df](https://github.com/Katello/katello.git/commit/635132df79514fc293c1daf984f2c34181addb75))
 * CV UI - UX Review 3 - Empty States - Tooltips - Assorted UI tweaks ([#33969](https://projects.theforeman.org/issues/33969), [6379a706](https://github.com/Katello/katello.git/commit/6379a706b7727443985aca1520f79b186c4bb9f1))
 * CV UI - UX Review - Modal Updates - Form Validation ([#33903](https://projects.theforeman.org/issues/33903), [9ea4eaad](https://github.com/Katello/katello.git/commit/9ea4eaad4c94ec46848ffa197b192e8b88ce7f15))
 * CV UI - UX Review - Table Sorting - Icon sizing/positioning - Date tooltips ([#33857](https://projects.theforeman.org/issues/33857), [a384ba7c](https://github.com/Katello/katello.git/commit/a384ba7c8893f8ebc66e0c7aacca06177cf09b74))
 * CV UI  - Versions page errata link and some UX changes ([#33819](https://projects.theforeman.org/issues/33819), [db432bff](https://github.com/Katello/katello.git/commit/db432bff23ce94132fa719405cb0a9d1908aa140))
 * Redirect users to select org page if navigating to content views UI without organization selected ([#33799](https://projects.theforeman.org/issues/33799), [88ebd7c3](https://github.com/Katello/katello.git/commit/88ebd7c3dc0339ded130ae1cd2d85796d99dafbe))
 * CV UI - Add search filters with chips to errata filter page  ([#33638](https://projects.theforeman.org/issues/33638), [648275ab](https://github.com/Katello/katello.git/commit/648275aba2a980162c5490eb27948f5501ff9186))
 * Hide not finished host redesign tabs from UI ([#33628](https://projects.theforeman.org/issues/33628), [a345c59d](https://github.com/Katello/katello.git/commit/a345c59d8d4b23c51dd0b608a504c1d3c279ec59), [45e7ecf3](https://github.com/Katello/katello.git/commit/45e7ecf3da1f81dee60f15ccc12cc75f2a356334))
 * CV UI -  Version Details - Files Tab for Table View ([#33594](https://projects.theforeman.org/issues/33594), [f0b6ccb7](https://github.com/Katello/katello.git/commit/f0b6ccb7263120187b9521630fad1d472ced6fb7))
 * [CV UI]  Version details repository drop-down selection for all associated tables ([#33555](https://projects.theforeman.org/issues/33555), [575aaeb0](https://github.com/Katello/katello.git/commit/575aaeb0aaa60d1343493988e1bc2a78e5f251a6))
 * [CV UI]  Allow "Enter" key for submit action on all forms ([#33553](https://projects.theforeman.org/issues/33553), [86dcb46d](https://github.com/Katello/katello.git/commit/86dcb46dde9b12ba1991dd6f498a1726c7afd1a7))
 * [CV UI] Allow creating Errata Filter by Id and Date type ([#33545](https://projects.theforeman.org/issues/33545), [c5458c43](https://github.com/Katello/katello.git/commit/c5458c436c869055f49d46166c96f696fc176a11))
 * Add Include all Module Streams with no errata checkbox to Module Stream Filter details page. ([#33537](https://projects.theforeman.org/issues/33537), [965d7ad3](https://github.com/Katello/katello.git/commit/965d7ad3c6ea515c07e01b589e90a45550e7b0b9))
 * CV UI -  ComponentView routing overhaul (hashrouter) ([#33404](https://projects.theforeman.org/issues/33404), [ab179e5e](https://github.com/Katello/katello.git/commit/ab179e5ed71335a8120f29c2b7197b0e9c27a450))
 * CV UI - Show Version Details - Table View ([#33403](https://projects.theforeman.org/issues/33403))
 * CV UI - Delete Content View ([#33402](https://projects.theforeman.org/issues/33402), [dc860b0c](https://github.com/Katello/katello.git/commit/dc860b0c20ef46ff1a4226226fd7700bef77f6c6))
 * CV UI - Delete CV Version ([#33401](https://projects.theforeman.org/issues/33401))
 * Host detaisl tabs should be translated ([#33398](https://projects.theforeman.org/issues/33398), [b303a63d](https://github.com/Katello/katello.git/commit/b303a63ddd4530f33a71ee43f6f81ef7e08f4c5a))
 * Updating per_page on table sends the page into infinite loops ([#33276](https://projects.theforeman.org/issues/33276), [fbdd242a](https://github.com/Katello/katello.git/commit/fbdd242accf4c62d6712912c576790c79c8b3ddf))
 * CV UI - CV Version remove from environment ([#33262](https://projects.theforeman.org/issues/33262), [03fc44cb](https://github.com/Katello/katello.git/commit/03fc44cbf448f0c1989d1ef37e148d796fe5dbc6))
 * CV UI - Show Version Details ([#33261](https://projects.theforeman.org/issues/33261), [b3608590](https://github.com/Katello/katello.git/commit/b360859071a9021c739c575363677ebcd14da6a1))
 * CV UI - Bug - Content View Version Task polling doesn't stop.  ([#34060](https://projects.theforeman.org/issues/34060), [ee27669b](https://github.com/Katello/katello.git/commit/ee27669b0030b0375acd4674dd5bb82f91956cdc))
 * CV UI - UX Review - Spacing ([#34046](https://projects.theforeman.org/issues/34046), [1deac3ca](https://github.com/Katello/katello.git/commit/1deac3ca876714dafc57fdd20baf113778a747ca))
 * Traces - Add Select All ([#33944](https://projects.theforeman.org/issues/33944), [7eb3f0bd](https://github.com/Katello/katello.git/commit/7eb3f0bdd360303eac04d34a9a8e0299eb57e78e))
 * CV UI - Ansible collection content has sub-tab but is treated differently in Versions ([#33933](https://projects.theforeman.org/issues/33933), [b5850751](https://github.com/Katello/katello.git/commit/b58507512791a02ffabc703dd0162d46f12ad73e))
 * CV counter shows In progress when count is 0 ([#33921](https://projects.theforeman.org/issues/33921), [c8dec446](https://github.com/Katello/katello.git/commit/c8dec446044f5671bdb3fc2a23275830d6f62c32))
 * Search Dropdown doesn't allow up/down arrow or tab selection.  ([#33824](https://projects.theforeman.org/issues/33824), [be136a4f](https://github.com/Katello/katello.git/commit/be136a4ff263c0c04b5f2d366373c0b7f599c2ec))
 * Autocomplete dropdown broken in 4.3 and master ([#34149](https://projects.theforeman.org/issues/34149), [63e53ecf](https://github.com/Katello/katello.git/commit/63e53ecf377edf92927450f7ad8590db3c421b5b))
 * Package dependency ui incorrectly displays dependency values ([#33407](https://projects.theforeman.org/issues/33407), [c84ed316](https://github.com/Katello/katello.git/commit/c84ed3165673e8b11f5a0b2782bb22fbc2139ba1))
 * custom confirm modal is broken ([#33393](https://projects.theforeman.org/issues/33393), [deff6f1d](https://github.com/Katello/katello.git/commit/deff6f1d9acc85d2e431d1adfc7916a3c4cf9708))
 * Fix Katello GUI issues and add debian constraints ([#33702](https://projects.theforeman.org/issues/33702), [8b56e717](https://github.com/Katello/katello.git/commit/8b56e717d2ef900c5ccd78dc428e1001957cf215))
 * Component content view list when status = Added or status = Not Added is not correctly processed ([#33700](https://projects.theforeman.org/issues/33700), [68427d85](https://github.com/Katello/katello.git/commit/68427d85374d4ae0c0b666bc99d0c74d94a19ae4))
 * Sync Plan Start Date Always null ([#33523](https://projects.theforeman.org/issues/33523), [4269c8ab](https://github.com/Katello/katello.git/commit/4269c8ab6dccb4e58c7147f54a4b5455fc806f72))
 * Tooltip stays visible after clicking on next page button ([#33498](https://projects.theforeman.org/issues/33498), [8b0f8379](https://github.com/Katello/katello.git/commit/8b0f83797746227955feeee1e05433bb51f78fbf))
 * Foreman setting has wrong description for a couple of parameters under Content Tab on the Foreman WebUI ([#33439](https://projects.theforeman.org/issues/33439), [6d755b7d](https://github.com/Katello/katello.git/commit/6d755b7dff116d611bf6eb5dfc73a3ab0c11cf02))
 * [SAT-1790] Extend TableWrapper and MainTable to allow using PF TableComposable ([#33238](https://projects.theforeman.org/issues/33238), [46d3cb14](https://github.com/Katello/katello.git/commit/46d3cb1468ca468b46a61fdc0aca6de8edc92cae))

### Repositories
 * After force deleting a repo, its entry in /etc/yum.repos.d/redhat.repo continues to be populated ([#33912](https://projects.theforeman.org/issues/33912), [a5fc808f](https://github.com/Katello/katello.git/commit/a5fc808f82f6df992e651a558bca8f88a541e9a0))
 * uploading a duplicate file fails with undefined local variable or method upload_href for #<Actions::Pulp3::Repository::CommitUpload:0x00000000134e3f00> ([#33748](https://projects.theforeman.org/issues/33748), [532ce8a0](https://github.com/Katello/katello.git/commit/532ce8a03879a771ad835c8fcfc2d60a4bc7abfe))
 * b'Update recommended repos for Satellite & Tools from 6.9 to 6.10' ([#33627](https://projects.theforeman.org/issues/33627), [d921227a](https://github.com/Katello/katello.git/commit/d921227a96e1533f09e8a9150c80835fb8b0afcf))
 * Generic repository types don't work properly with multiple generic types ([#33625](https://projects.theforeman.org/issues/33625), [6d0e46b1](https://github.com/Katello/katello.git/commit/6d0e46b1deecccf23feb34d4df0ad69343b9d161), [50642a73](https://github.com/Katello/katello.git/commit/50642a73afefeaba10db14cdb5fd4baa1c36844c))
 * change urls with username and password in the url to use basic auth parameters in pulp3 ([#33576](https://projects.theforeman.org/issues/33576), [206aa4f3](https://github.com/Katello/katello.git/commit/206aa4f373c132d806ac175a4e62f43165d3408c))
 * Selecting certain products in "Red Hat Repositories" page renders a Blank Page in Satellite 6.10 ([#33544](https://projects.theforeman.org/issues/33544), [deff2d5f](https://github.com/Katello/katello.git/commit/deff2d5f478f98b41eee62f2bbae3821e6141946))
 * Selected yum metadata checksum type on is not reflected in repomd.xml on a repo creation ([#33495](https://projects.theforeman.org/issues/33495), [d2ea3134](https://github.com/Katello/katello.git/commit/d2ea31348c420314246e45b820cd88f040502120))
 * Remove OSTree filter from Red Hat Repositories drop down list ([#33493](https://projects.theforeman.org/issues/33493), [13a09871](https://github.com/Katello/katello.git/commit/13a098718447816fd3b54b054a4caa206051f9ce))
 * Total steps: 0/0 in sync status ([#33472](https://projects.theforeman.org/issues/33472), [d30d3bbc](https://github.com/Katello/katello.git/commit/d30d3bbca803c837ff516c3a79a31a1c35dcebff))
 * Background download policy is still referenced in a number of areas ([#33468](https://projects.theforeman.org/issues/33468), [295c71a5](https://github.com/Katello/katello.git/commit/295c71a5c8a6fe7f216e7723ef0598afabcb0367))
 * Add repositories node to generic content unit rabl ([#33454](https://projects.theforeman.org/issues/33454), [28be3d12](https://github.com/Katello/katello.git/commit/28be3d12f9a7fe67ca69d2218ab877f0ec315fd7))
 * Drop rake task katello:refresh_sync_schedule ([#33450](https://projects.theforeman.org/issues/33450), [3166eb28](https://github.com/Katello/katello.git/commit/3166eb2805f4cda4c094299a6891af81e0fa4dd0))
 * UI shows 0 packages\\errata\\package_groups after a bad sync followed by a successful sync for the same repo ([#33443](https://projects.theforeman.org/issues/33443), [9ff6d950](https://github.com/Katello/katello.git/commit/9ff6d950aec6f6ad84cfb70bb9b6340a806e62d6))
 * Error in logs when scanning for repository undefined method resolve_substitutions ([#33383](https://projects.theforeman.org/issues/33383), [8cb4654d](https://github.com/Katello/katello.git/commit/8cb4654dde46d5194b9947d399a841512d3223db))
 * catch specific error  from pulp and throw a better one that is katello specific ([#33376](https://projects.theforeman.org/issues/33376), [d947a8fd](https://github.com/Katello/katello.git/commit/d947a8fd3d23a9868055faa1379d0b3e8451e4a9))
 * change 'publish via http' to 'unprotected' in UI ([#33175](https://projects.theforeman.org/issues/33175), [487e5fd7](https://github.com/Katello/katello.git/commit/487e5fd72a2dd9e9501d28278088a6db41424e3b))
 * Fix upstream_authentication error when editing ULN repository ([#33659](https://projects.theforeman.org/issues/33659), [7640c27f](https://github.com/Katello/katello.git/commit/7640c27fac40cbe87dffc6e60b0457b6c07194fc))
 * As a user I can create an OSTree repository ([#33557](https://projects.theforeman.org/issues/33557), [70cf5917](https://github.com/Katello/katello.git/commit/70cf5917beb8d456845ee212939497f190e2822b))

### Hosts
 * The host detail page widget for the content view breaks on a default long content view name ([#33876](https://projects.theforeman.org/issues/33876), [de3dfa78](https://github.com/Katello/katello.git/commit/de3dfa7894a8b78e34a12336239b125e311c4036))
 * Content - Errata - Add REX actions (menu items) ([#33852](https://projects.theforeman.org/issues/33852), [0e7f14ce](https://github.com/Katello/katello.git/commit/0e7f14ce3b639b36ab968d460cc441228d991b16))
 * Host details tabs aren't responding for click event ([#33806](https://projects.theforeman.org/issues/33806), [997cab04](https://github.com/Katello/katello.git/commit/997cab04778b1e910596af3dff7b243eb11e03a1))
 * New Traces page - wrong input format passed to REX job ([#33764](https://projects.theforeman.org/issues/33764), [fcda5a12](https://github.com/Katello/katello.git/commit/fcda5a128342bb7693991080208bba38dd05edcb))
 * Content - Errata - Add toggle group for All (applicable) errata ([#33762](https://projects.theforeman.org/issues/33762), [d7b056cd](https://github.com/Katello/katello.git/commit/d7b056cdfa66a072fbf498540a6332fa700311fd))
 * b'The link "here" in tabs of a content host (/content_hosts/1/...) is not opening any page' ([#33677](https://projects.theforeman.org/issues/33677), [37170759](https://github.com/Katello/katello.git/commit/371707597bc336fce88e31004ccf27e90085d0ea))
 * Add Errata - Bulk select & apply ([#33515](https://projects.theforeman.org/issues/33515), [644c2d33](https://github.com/Katello/katello.git/commit/644c2d33ad07d8c64bb96b3711daf86376e627f7))
 * Old Registration URL doesn't redirect to the new URL ([#33442](https://projects.theforeman.org/issues/33442), [5bf47ba6](https://github.com/Katello/katello.git/commit/5bf47ba639feb7299a77093260146ee875528c0e))
 * Host Redesign - Basic Errata table ([#33361](https://projects.theforeman.org/issues/33361), [4c624e22](https://github.com/Katello/katello.git/commit/4c624e2283145c4655368296bbcca4326667176d))
 * Change of 'auto-attach' preference via subscription-manager doesn't get reflected in Satellite WebUI ([#33285](https://projects.theforeman.org/issues/33285), [50cf33b6](https://github.com/Katello/katello.git/commit/50cf33b69b23ba0f570a515ae930425c3a12cba2))
 * Incorrect search link from packages view for applicable or upgradable hosts ([#33256](https://projects.theforeman.org/issues/33256), [5077fdc7](https://github.com/Katello/katello.git/commit/5077fdc78c21e67767fd8e13a058b42517bfd042))
 * Installation source in hostgroup cannot be changed from "synced content" to local medium ([#33144](https://projects.theforeman.org/issues/33144), [0863618b](https://github.com/Katello/katello.git/commit/0863618b348582096cb6b39e5069b1c44f946751))

### Tooling
 * katello:reset doesn't work with pulp 3.15 ([#33847](https://projects.theforeman.org/issues/33847), [24eb0863](https://github.com/Katello/katello.git/commit/24eb0863fa9a30197cacb65344de214fa7cd8880))
 * pulpcore-resource-manager gets started after rake katello:reset ([#33609](https://projects.theforeman.org/issues/33609), [b9aa4e0b](https://github.com/Katello/katello.git/commit/b9aa4e0b7516449314a897367130ebc606099605))
 * Cleanup unused methods in Candlepin Consumer resource ([#33508](https://projects.theforeman.org/issues/33508), [cafb8469](https://github.com/Katello/katello.git/commit/cafb8469216dfce0b67b99b0404956d9b29dc585))
 * Inject consumer uuid into REX jobs ([#33410](https://projects.theforeman.org/issues/33410), [ab549a2e](https://github.com/Katello/katello.git/commit/ab549a2ea76c97979c557afb5de62990cccd6920), [7179c88e](https://github.com/Katello/katello.git/commit/7179c88e661cf8f34b10c6ebe421ab2ec52e859c))
 * Pulp-ansible binding is outdated ([#33349](https://projects.theforeman.org/issues/33349), [27281d45](https://github.com/Katello/katello.git/commit/27281d457e2958ad4ed440b92b36a15f47d54922))
 * Inheritance does not work for child hostgroups Content view, Content Source and Lifecycle environment ([#33054](https://projects.theforeman.org/issues/33054), [0863618b](https://github.com/Katello/katello.git/commit/0863618b348582096cb6b39e5069b1c44f946751))

### Hammer
 * ensure hammer-cli-katello works with Ruby 2.7 ([#33792](https://projects.theforeman.org/issues/33792), [8732a4b9](https://github.com/Katello/hammer-cli-katello.git/commit/8732a4b94d6cf382ec73ba785b6e1cd4476ff3fe))
 * Make katello commands work without Puppet ([#33750](https://projects.theforeman.org/issues/33750), [5425f2ed](https://github.com/Katello/hammer-cli-katello.git/commit/5425f2ed77cd4ebd6d39ad75743c008fa56e18dd))
 * Some hammer-cli-katello commands fail when Puppet is disabled ([#33729](https://projects.theforeman.org/issues/33729))
 * Hammer host errata recalculate fails to display task ([#33327](https://projects.theforeman.org/issues/33327), [309a820e](https://github.com/Katello/hammer-cli-katello.git/commit/309a820e95e32e6b343263f43ed2d53e41a977ee))
 * Fix command extensions and tests ([#33134](https://projects.theforeman.org/issues/33134), [ab2082c5](https://github.com/Katello/hammer-cli-katello.git/commit/ab2082c596a30999ae007d34b1ee92019ee1b663))

### Tests
 * Increase nock timeout for longer running tests and possibly slow CI ([#33692](https://projects.theforeman.org/issues/33692), [ad887ced](https://github.com/Katello/katello.git/commit/ad887cedda5033ca1a888f8459f0eacda2124f6c))
 * Fix memory exceeded issue surround katello tests in CI   ([#33796](https://projects.theforeman.org/issues/33796), [831260db](https://github.com/Katello/katello.git/commit/831260db8fc6bfb9af7b23020e44da7f439010d7))

### API
 * Cache resource list API responses ([#33651](https://projects.theforeman.org/issues/33651), [cf9edcda](https://github.com/Katello/katello.git/commit/cf9edcdaffa7d3d3fba8e65e8b996ddfb2576039))
 * Ping API consideres Pulp3 healthy, even if no content apps are available ([#33703](https://projects.theforeman.org/issues/33703), [13cd0c84](https://github.com/Katello/katello.git/commit/13cd0c84879a430daa052f4dc9ffdff20cc1fb8b), [5e98c816](https://github.com/Katello/hammer-cli-katello.git/commit/5e98c81601d45713f94f3ba440c8d11940b3dbae))
 * Add component view count to versions API results ([#33467](https://projects.theforeman.org/issues/33467), [0495eb34](https://github.com/Katello/katello.git/commit/0495eb348a6274f6d36f12263fffde019dd654ff))

### Subscriptions
 *  Satellite doesn't forward the "If-Modified-Since" header for /accessible_content endpoint to Candlepin ([#33618](https://projects.theforeman.org/issues/33618), [0bbdcf78](https://github.com/Katello/katello.git/commit/0bbdcf7867e8f6fea1433daf9cb73926a71838ca), [438351af](https://github.com/Katello/katello.git/commit/438351af3352088f3a8347ed1aaaf84dc3d2ae69))
 * Task is failing but still showing success state ([#33598](https://projects.theforeman.org/issues/33598), [e7f754b1](https://github.com/Katello/katello.git/commit/e7f754b1c632379dfb49634a815820b48a55f554))
 * Navigating to Admin, Organization, and selecting an organization gives 404 ([#33573](https://projects.theforeman.org/issues/33573), [6f9310a4](https://github.com/Katello/katello.git/commit/6f9310a409a8cd3e66708aad37d80258013c5df1))

### Foreman Proxy Content
 * Cannot pull container images from Container Gateway if there are slashes in the repository name ([#33538](https://projects.theforeman.org/issues/33538), [15c1bc45](https://github.com/Katello/smart_proxy_container_gateway.git/commit/15c1bc45a43dbb62d567de50c71615b0fb0b9244))
 * Capsule content page shows content views as empty when they aren't ([#33466](https://projects.theforeman.org/issues/33466), [36aaff0b](https://github.com/Katello/katello.git/commit/36aaff0b08577c1c227d8346b228a4b69a671433))
 * Default Organization View showing status as  {{ historyText(version) }}  when you check through Infrastructure --> Smart Proxies --> proxy --> content --> Library --> Default Organization View ([#33465](https://projects.theforeman.org/issues/33465), [47d56b2e](https://github.com/Katello/katello.git/commit/47d56b2e30da05081f1409ac5a11e2fc7ce6c93a))
 * Audit the code for SmartProxy lookups that should be unscoped ([#33308](https://projects.theforeman.org/issues/33308), [cac7bf1d](https://github.com/Katello/katello.git/commit/cac7bf1d42aa681de6745666d98ca7629baacb83))
 * smart proxy pulp's client certificate setting looks for wrong value ([#33959](https://projects.theforeman.org/issues/33959), [76ce48e4](https://github.com/Katello/katello.git/commit/76ce48e43beed28960264dbfe84af1221d99ab2f))
 * capsule sync broken with new mirroring policy ([#34209](https://projects.theforeman.org/issues/34209), [aa6720c8](https://github.com/Katello/katello.git/commit/aa6720c8bc8ed5a4b4de4370a3b050e9cbee2ba6))
 * Give warning for certain content types on smart proxy sync ([#33325](https://projects.theforeman.org/issues/33325), [901236e5](https://github.com/Katello/katello.git/commit/901236e5fe931206600af10cd1212cfaf16bcda8))

### Ansible Collections
 * Add repository type count to cv version API and fix ansible collection cv publish ([#33386](https://projects.theforeman.org/issues/33386), [0eda4319](https://github.com/Katello/katello.git/commit/0eda431989ea41f479a5b4ba06ae7465bdee0a7b))

### Container
 * Adding ansible collection repos or debian repos to content views with filters causes failures ([#33375](https://projects.theforeman.org/issues/33375), [d5bc2928](https://github.com/Katello/katello.git/commit/d5bc2928c678c1068c2e899823adae54cb8b40ad))

### Client/Agent
 * katello-tracer-upload on sles / debian is broken ([#33176](https://projects.theforeman.org/issues/33176), [2d7d6f38](https://github.com/Katello/katello-host-tools.git/commit/2d7d6f3846f0c1b3983e9ef74b79e8e03fb89bd3))

### Inter Server Sync
 * CV import broken with new mirroring policy changes ([#34208](https://projects.theforeman.org/issues/34208), [b26f6735](https://github.com/Katello/katello.git/commit/b26f6735699d36c1566dbd1e9755b29f64db4a1f))
