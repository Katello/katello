# 4.15.0 Macho Man (2024-11-21)

## Features

### Foreman Proxy Content
 * Granular content counting on the UI ([#37945](https://projects.theforeman.org/issues/37945), [aadc393a](https://github.com/Katello/katello.git/commit/aadc393af67dee8d0b087d10e104c09f22c0e605))

### Repositories
 * [Flatpak] Add models and API for flatpak remotes in katello ([#37902](https://projects.theforeman.org/issues/37902), [590ef6df](https://github.com/Katello/katello.git/commit/590ef6df29bfa9cbb9ca5458aaae0f61bc19eafa))
 *  Add to manifest lists and index is-bootable, is-flatpak, labels, and annotations fields  ([#37887](https://projects.theforeman.org/issues/37887), [da405876](https://github.com/Katello/katello.git/commit/da40587680c2e05d53752196d157da34653e475d))
 * Add depth option for OSTree repository type ([#37853](https://projects.theforeman.org/issues/37853), [c58ef63a](https://github.com/Katello/katello.git/commit/c58ef63a691566b163eae787318ea015e2fa5104))
 * Deletion of repository not working from "Products" page when repo in published CV ([#37617](https://projects.theforeman.org/issues/37617), [a04ca798](https://github.com/Katello/katello.git/commit/a04ca7988f32a9d47eea23562aa782621a56f033))

### Hammer
 * Add hammer content-view-environments list command ([#37894](https://projects.theforeman.org/issues/37894), [bbffe936](https://github.com/Katello/hammer-cli-katello.git/commit/bbffe936764a1413e2107afcba96d52ab5a09b73), [1eaac148](https://github.com/Katello/hammer-cli-katello.git/commit/1eaac1481c459a1d8c145968cc41051a73b04558))

### Hosts
 * As a user, I can see image-mode hosts' current and future image, manifest, tag via API ([#37888](https://projects.theforeman.org/issues/37888), [db89c590](https://github.com/Katello/katello.git/commit/db89c59031e34994805faaf3c6314b0e412b56c3))
 * Add  Bulk Errata Wizard ([#37596](https://projects.theforeman.org/issues/37596), [231c41f0](https://github.com/Katello/katello.git/commit/231c41f0c08cf1aebcd0f5eb58c34fe60b8a4a63))
 * Add 'remove packages' to Packages wizard ([#37586](https://projects.theforeman.org/issues/37586), [f55e7f8c](https://github.com/Katello/katello.git/commit/f55e7f8c759deb2bc332624b6418f0f988ad7f0f))
 * Display multi-CV on host details page ([#37509](https://projects.theforeman.org/issues/37509), [ce5508e5](https://github.com/Katello/katello.git/commit/ce5508e57c78d5c60855a9ac3e2730da46a56576))
 * Multi-CV: Add ordering to content view environments ([#37508](https://projects.theforeman.org/issues/37508), [44b6d9e8](https://github.com/Katello/katello.git/commit/44b6d9e8a7baf01492d0c5b561620e714d7881d2))

### Content Views
 * Add a content view environments controller ([#37884](https://projects.theforeman.org/issues/37884), [41dab45b](https://github.com/Katello/katello.git/commit/41dab45b809f3e6385db29ab5da6341acf6e4c02))
 * Update web UI for multi-CV activation key display ([#37861](https://projects.theforeman.org/issues/37861), [dceb439f](https://github.com/Katello/katello.git/commit/dceb439ff843ddadcf717e1c663ad7f49f549c34))

### Web UI
 * Align deb-package details with rpm-package details ([#37794](https://projects.theforeman.org/issues/37794), [ade7b9ad](https://github.com/Katello/katello.git/commit/ade7b9ad948657b5e700734bb2333ec56b4c75f9), [bcc75d9f](https://github.com/Katello/katello.git/commit/bcc75d9f2df60c2cc1a4e44fa1928071b9c5a5e7))

### Activation Key
 * Filter for repository status on activation key --> repository sets page ([#37743](https://projects.theforeman.org/issues/37743), [e2c7ad1d](https://github.com/Katello/katello.git/commit/e2c7ad1dd86f07b1b846ce60073b7c1dc2006bf0))

### Subscriptions
 * Count hosts that consume a particular product (now that subscriptions are gone) ([#37683](https://projects.theforeman.org/issues/37683), [42f890dd](https://github.com/Katello/katello.git/commit/42f890ddad42eeaaffc12596a96d35f542d83622))

### Other
 * Update global registration form for multi-env AK display ([#37881](https://projects.theforeman.org/issues/37881), [e1dc9cf8](https://github.com/Katello/katello.git/commit/e1dc9cf843912d4e9d45d3e4abc2ee76170be7e4))
 * Allow smart proxy content counting for an environment/content view ([#37871](https://projects.theforeman.org/issues/37871), [90deb814](https://github.com/Katello/katello.git/commit/90deb814baf4b47bbad0a119589861d4d3db5b36))

## Bug Fixes

### Localization
 * generic content units controller api translation broken ([#37981](https://projects.theforeman.org/issues/37981), [0f836659](https://github.com/Katello/katello.git/commit/0f8366599a203ab3f6c06cb305292083a97aa02e))

### Repositories
 * Upgrade Pulp Container to 2.22 ([#37973](https://projects.theforeman.org/issues/37973), [e135256e](https://github.com/Katello/katello.git/commit/e135256ea8d2a4cc86874531a30c0318dd564908))
 * Ostree repo creation fails if Depth is not set to a value ([#37951](https://projects.theforeman.org/issues/37951), [29b4e30b](https://github.com/Katello/katello.git/commit/29b4e30b86d2c08bbe67ac3799e7ff47fc95a9a6))
 * Upgrade Pulpcore to 3.63 and plugins ([#37950](https://projects.theforeman.org/issues/37950), [b27a14a2](https://github.com/Katello/katello.git/commit/b27a14a29866c7ac97a574b00b5b872ae97152b2))
 * Add RHEL 9 AppStream and BaseOS EUS repos under Recommeded Repositories  ([#37916](https://projects.theforeman.org/issues/37916), [7daa6763](https://github.com/Katello/katello.git/commit/7daa6763dec6b98ac7a4b273a592bdc031250831))
 * Remove remnants of Katello container management workflow ([#37659](https://projects.theforeman.org/issues/37659), [01b1c154](https://github.com/Katello/katello.git/commit/01b1c154556454c6c181571c069ae1a4712fef70))
 * API endpoint "/katello/api/repositories/:id/upload_content " not accepting calls from the client ([#37603](https://projects.theforeman.org/issues/37603), [9c25238e](https://github.com/Katello/katello.git/commit/9c25238e9aa59305c9b981627bb3a8d33cada294))
 * Filtering repositories on RH Repos page gives incorrect results ([#37534](https://projects.theforeman.org/issues/37534), [80a1d01c](https://github.com/Katello/katello.git/commit/80a1d01cdef8511f46756d7a602efa36f89d649f))
 * No one needs migrated_pulp3_href on content tables anymore ([#36874](https://projects.theforeman.org/issues/36874), [e83bdae3](https://github.com/Katello/katello.git/commit/e83bdae3fb2e2fbae5df8ab5ed1372161636e8ce))
 * Container image manifests synced without tags triggers "no content added" ([#36404](https://projects.theforeman.org/issues/36404), [c3181b0e](https://github.com/Katello/katello.git/commit/c3181b0e7ffb49505a56c11de5d248e3a028a19f))

### Foreman Proxy Content
 * Synchronization messages should not contain branding information ([#37972](https://projects.theforeman.org/issues/37972))
 * [DEV] [RFE] Need an option to turn off the 'Reclaim Space' warning ([#37716](https://projects.theforeman.org/issues/37716), [28e0a4e7](https://github.com/Katello/katello.git/commit/28e0a4e7924db41e5ef2846a464832c66ec3c710))

### Hosts
 * Katello tries to update the deleted Candlepin consumer during force register after deleting certificates ([#37966](https://projects.theforeman.org/issues/37966), [80a76835](https://github.com/Katello/katello.git/commit/80a76835112e6c608b59be0538dc980641c14563))
 * Improve restart services job ([#37918](https://projects.theforeman.org/issues/37918), [ea1b9112](https://github.com/Katello/katello.git/commit/ea1b9112e0c430634b6892d666a4895c769edd48))
 * getting hosts list performs redundantly huge query over duplicated host IDs ([#37842](https://projects.theforeman.org/issues/37842), [3c8c351e](https://github.com/Katello/katello.git/commit/3c8c351e72c087e09b77dea7ea2dff49e3b56150))
 * Hammer host update false positive when assigning multiple environments ([#37772](https://projects.theforeman.org/issues/37772), [31b5c98b](https://github.com/Katello/katello.git/commit/31b5c98ba80fbe8ae8e13eb902529fe6dc81bf6a))
 * BulkChangeCVModal should be disabled when Any Organization is selected ([#37546](https://projects.theforeman.org/issues/37546), [ac9da969](https://github.com/Katello/katello.git/commit/ac9da96950389954d48bf741c1f759b03d289524), [4a288f94](https://github.com/Katello/katello.git/commit/4a288f944abbf53bd5d7b25084d0794f0a34eea1))
 * Kickstart Repository association is not deleted from a host when it is unregistered ([#37518](https://projects.theforeman.org/issues/37518), [9dcbd3e0](https://github.com/Katello/katello.git/commit/9dcbd3e094811639ec3ba0cdc796013467433784))
 * Package update chooses latest version instead of input version ([#37072](https://projects.theforeman.org/issues/37072), [d07494f4](https://github.com/Katello/katello.git/commit/d07494f4dba5f32f4673eb78ada8e36bacfa985d))

### API
 * Add content view environment labels to host rabl ([#37957](https://projects.theforeman.org/issues/37957), [c123c23f](https://github.com/Katello/katello.git/commit/c123c23f57e51308ca25f57b91faed7acde298d0))

### Hammer
 * hammer capsule content info fails when counts are out of date ([#37954](https://projects.theforeman.org/issues/37954))
 * Update hammer host info and hammer host list for multi-environment hosts ([#37948](https://projects.theforeman.org/issues/37948), [d2c7a358](https://github.com/Katello/hammer-cli-katello.git/commit/d2c7a35887f386157fcf0975a90b2d25fb1fc293))
 * Hammer does not filter deb-packages correctly ([#37924](https://projects.theforeman.org/issues/37924), [ee225a71](https://github.com/Katello/hammer-cli-katello.git/commit/ee225a714a3f7e60fa53c18d63762b182c361379))

### Activation Key
 * Activation key doesn't get LCE/CV assigned to it on creation ([#37941](https://projects.theforeman.org/issues/37941), [82d7a2c8](https://github.com/Katello/katello.git/commit/82d7a2c8899a1ccf52e124dcc8464d20970e9599))
 * Add multi-env AK display to hammer activation-key info ([#37865](https://projects.theforeman.org/issues/37865), [74e13f9f](https://github.com/Katello/katello.git/commit/74e13f9fa50fa000d69e9c3ad2df374787058295), [2142e03e](https://github.com/Katello/hammer-cli-katello.git/commit/2142e03ecea8ca8ac149daacc6e27c3e43484433))
 * Single activation key is not filled in on Register page ([#37572](https://projects.theforeman.org/issues/37572), [22ed4291](https://github.com/Katello/katello.git/commit/22ed4291d77a925d7c326a29150b9345575bc55f))

### Host Collections
 * Issues when using Host Collection membership Management, the number of content hosts is not accurate ([#37934](https://projects.theforeman.org/issues/37934), [10e63301](https://github.com/Katello/katello.git/commit/10e63301cc27ae19512aec63cb1b1fc971031595))

### Subscriptions
 * Installed products report fails with Jail issue for #purpose_role and #purpose_usage ([#37921](https://projects.theforeman.org/issues/37921), [5aad5543](https://github.com/Katello/katello.git/commit/5aad554311c7764b5f985825b2886c247cc05d8c))

### Content Views
 * Content view version errata page shows incorrect date for "updated at" value ([#37911](https://projects.theforeman.org/issues/37911), [78146fe4](https://github.com/Katello/katello.git/commit/78146fe4798e7025cbfc85a3097843eb12bc1946))
 * Newly published CV version shows need_published as true ([#37633](https://projects.theforeman.org/issues/37633), [d971128b](https://github.com/Katello/katello.git/commit/d971128becebce1cb42cebb417172774f706c8ec))
 * katello_repository_debs "id" column hits max integer size ([#37585](https://projects.theforeman.org/issues/37585), [fc3dff18](https://github.com/Katello/katello.git/commit/fc3dff18c6a74cb089bceb8c873070e472ce79a5))
 * Very long CV names/labels display weirdly on CV UI ([#37530](https://projects.theforeman.org/issues/37530), [8548944e](https://github.com/Katello/katello.git/commit/8548944ee75c7eb4f3adbc304f8b975efb59c266))
 * Make distributing archived content view repositories off by default ([#37006](https://projects.theforeman.org/issues/37006), [24cd3a97](https://github.com/Katello/katello.git/commit/24cd3a977f375555ec5a1456322828c50aa9771a))

### Errata Management
 * Bold "Skip dependency solving for a significant speed increase" on incremental update page ([#37839](https://projects.theforeman.org/issues/37839), [a9bb2033](https://github.com/Katello/katello.git/commit/a9bb203319904166b5761c1caa21c54e1bc43e04))

### Tests
 * Tests failing on Ruby 2.7 due to sorting of content types in the message ([#37681](https://projects.theforeman.org/issues/37681), [f43b70ae](https://github.com/Katello/katello.git/commit/f43b70aeea914c14fe61d375fc2c288252ed30fa))

### Inter Server Sync
 * PUT /katello/api/organizations/:id doesn't update redhat_repository_url ([#37658](https://projects.theforeman.org/issues/37658), [99641b89](https://github.com/Katello/katello.git/commit/99641b8971a5f947877f3947908b2116c0872177))

### Client/Agent
 * "Upload profile - Katello Script Default" doesn't work for SLES ([#37569](https://projects.theforeman.org/issues/37569), [99f5cdbb](https://github.com/Katello/katello.git/commit/99f5cdbbd81ce331515d4494bb809fe287ed96a7))

### katello-tracer
 * sudo katello-tracer-upload fails ([#37561](https://projects.theforeman.org/issues/37561), [94445d2c](https://github.com/Katello/katello.git/commit/94445d2c80a73ea9aca128acb13039c533fcd8d6))

### Tooling
 * Rewrite 'React Tests' GH action ([#37560](https://projects.theforeman.org/issues/37560), [9dbfc297](https://github.com/Katello/katello.git/commit/9dbfc297e1e97f0728c16e4d46938fdd33879b5f))

### Web UI
 * Exclude vendor dir in jest config ([#37506](https://projects.theforeman.org/issues/37506), [71bee44f](https://github.com/Katello/katello.git/commit/71bee44f768009dd8b67370a8c48d49fdfc818a7))

### Other
 * Use memory fact instead of dmi ([#37866](https://projects.theforeman.org/issues/37866), [fe178dd1](https://github.com/Katello/katello.git/commit/fe178dd17dc7b0777eeb654e04f7e4fae20c765c))
 * Remove python3-tracer package from el8 ([#37526](https://projects.theforeman.org/issues/37526), [8413020a](https://github.com/Katello/katello-host-tools.git/commit/8413020acb3ce15783a210a1c4d8dc3022cc7fae))
# 4.15.0 Macho Man (2024-11-14)

## Features

### Foreman Proxy Content
 * Granular content counting on the UI ([#37945](https://projects.theforeman.org/issues/37945), [aadc393a](https://github.com/Katello/katello.git/commit/aadc393af67dee8d0b087d10e104c09f22c0e605))

### Repositories
 * [Flatpak] Add models and API for flatpak remotes in katello ([#37902](https://projects.theforeman.org/issues/37902), [590ef6df](https://github.com/Katello/katello.git/commit/590ef6df29bfa9cbb9ca5458aaae0f61bc19eafa))
 *  Add to manifest lists and index is-bootable, is-flatpak, labels, and annotations fields  ([#37887](https://projects.theforeman.org/issues/37887), [da405876](https://github.com/Katello/katello.git/commit/da40587680c2e05d53752196d157da34653e475d))
 * Add depth option for OSTree repository type ([#37853](https://projects.theforeman.org/issues/37853), [c58ef63a](https://github.com/Katello/katello.git/commit/c58ef63a691566b163eae787318ea015e2fa5104))
 * Deletion of repository not working from "Products" page when repo in published CV ([#37617](https://projects.theforeman.org/issues/37617), [a04ca798](https://github.com/Katello/katello.git/commit/a04ca7988f32a9d47eea23562aa782621a56f033))

### Hammer
 * Add hammer content-view-environments list command ([#37894](https://projects.theforeman.org/issues/37894), [bbffe936](https://github.com/Katello/hammer-cli-katello.git/commit/bbffe936764a1413e2107afcba96d52ab5a09b73), [1eaac148](https://github.com/Katello/hammer-cli-katello.git/commit/1eaac1481c459a1d8c145968cc41051a73b04558))

### Hosts
 * As a user, I can see image-mode hosts' current and future image, manifest, tag via API ([#37888](https://projects.theforeman.org/issues/37888), [db89c590](https://github.com/Katello/katello.git/commit/db89c59031e34994805faaf3c6314b0e412b56c3))
 * Add  Bulk Errata Wizard ([#37596](https://projects.theforeman.org/issues/37596), [231c41f0](https://github.com/Katello/katello.git/commit/231c41f0c08cf1aebcd0f5eb58c34fe60b8a4a63))
 * Add 'remove packages' to Packages wizard ([#37586](https://projects.theforeman.org/issues/37586), [f55e7f8c](https://github.com/Katello/katello.git/commit/f55e7f8c759deb2bc332624b6418f0f988ad7f0f))
 * Display multi-CV on host details page ([#37509](https://projects.theforeman.org/issues/37509), [ce5508e5](https://github.com/Katello/katello.git/commit/ce5508e57c78d5c60855a9ac3e2730da46a56576))
 * Multi-CV: Add ordering to content view environments ([#37508](https://projects.theforeman.org/issues/37508), [44b6d9e8](https://github.com/Katello/katello.git/commit/44b6d9e8a7baf01492d0c5b561620e714d7881d2))

### Content Views
 * Add a content view environments controller ([#37884](https://projects.theforeman.org/issues/37884), [41dab45b](https://github.com/Katello/katello.git/commit/41dab45b809f3e6385db29ab5da6341acf6e4c02))
 * Update web UI for multi-CV activation key display ([#37861](https://projects.theforeman.org/issues/37861), [dceb439f](https://github.com/Katello/katello.git/commit/dceb439ff843ddadcf717e1c663ad7f49f549c34))

### Web UI
 * Align deb-package details with rpm-package details ([#37794](https://projects.theforeman.org/issues/37794), [ade7b9ad](https://github.com/Katello/katello.git/commit/ade7b9ad948657b5e700734bb2333ec56b4c75f9), [bcc75d9f](https://github.com/Katello/katello.git/commit/bcc75d9f2df60c2cc1a4e44fa1928071b9c5a5e7))

### Activation Key
 * Filter for repository status on activation key --> repository sets page ([#37743](https://projects.theforeman.org/issues/37743), [e2c7ad1d](https://github.com/Katello/katello.git/commit/e2c7ad1dd86f07b1b846ce60073b7c1dc2006bf0))

### Subscriptions
 * Count hosts that consume a particular product (now that subscriptions are gone) ([#37683](https://projects.theforeman.org/issues/37683), [42f890dd](https://github.com/Katello/katello.git/commit/42f890ddad42eeaaffc12596a96d35f542d83622))

### Other
 * Update global registration form for multi-env AK display ([#37881](https://projects.theforeman.org/issues/37881), [e1dc9cf8](https://github.com/Katello/katello.git/commit/e1dc9cf843912d4e9d45d3e4abc2ee76170be7e4))
 * Allow smart proxy content counting for an environment/content view ([#37871](https://projects.theforeman.org/issues/37871), [90deb814](https://github.com/Katello/katello.git/commit/90deb814baf4b47bbad0a119589861d4d3db5b36))

## Bug Fixes

### Localization
 * generic content units controller api translation broken ([#37981](https://projects.theforeman.org/issues/37981), [0f836659](https://github.com/Katello/katello.git/commit/0f8366599a203ab3f6c06cb305292083a97aa02e))

### Repositories
 * Upgrade Pulp Container to 2.22 ([#37973](https://projects.theforeman.org/issues/37973), [e135256e](https://github.com/Katello/katello.git/commit/e135256ea8d2a4cc86874531a30c0318dd564908))
 * Upgrade Pulpcore to 3.63 and plugins ([#37950](https://projects.theforeman.org/issues/37950), [b27a14a2](https://github.com/Katello/katello.git/commit/b27a14a29866c7ac97a574b00b5b872ae97152b2))
 * Add RHEL 9 AppStream and BaseOS EUS repos under Recommeded Repositories  ([#37916](https://projects.theforeman.org/issues/37916), [7daa6763](https://github.com/Katello/katello.git/commit/7daa6763dec6b98ac7a4b273a592bdc031250831))
 * Remove remnants of Katello container management workflow ([#37659](https://projects.theforeman.org/issues/37659), [01b1c154](https://github.com/Katello/katello.git/commit/01b1c154556454c6c181571c069ae1a4712fef70))
 * API endpoint "/katello/api/repositories/:id/upload_content " not accepting calls from the client ([#37603](https://projects.theforeman.org/issues/37603), [9c25238e](https://github.com/Katello/katello.git/commit/9c25238e9aa59305c9b981627bb3a8d33cada294))
 * Filtering repositories on RH Repos page gives incorrect results ([#37534](https://projects.theforeman.org/issues/37534), [80a1d01c](https://github.com/Katello/katello.git/commit/80a1d01cdef8511f46756d7a602efa36f89d649f))
 * No one needs migrated_pulp3_href on content tables anymore ([#36874](https://projects.theforeman.org/issues/36874), [e83bdae3](https://github.com/Katello/katello.git/commit/e83bdae3fb2e2fbae5df8ab5ed1372161636e8ce))
 * Container image manifests synced without tags triggers "no content added" ([#36404](https://projects.theforeman.org/issues/36404), [c3181b0e](https://github.com/Katello/katello.git/commit/c3181b0e7ffb49505a56c11de5d248e3a028a19f))

### Hosts
 * Katello tries to update the deleted Candlepin consumer during force register after deleting certificates ([#37966](https://projects.theforeman.org/issues/37966), [80a76835](https://github.com/Katello/katello.git/commit/80a76835112e6c608b59be0538dc980641c14563))
 * getting hosts list performs redundantly huge query over duplicated host IDs ([#37842](https://projects.theforeman.org/issues/37842), [3c8c351e](https://github.com/Katello/katello.git/commit/3c8c351e72c087e09b77dea7ea2dff49e3b56150))
 * Hammer host update false positive when assigning multiple environments ([#37772](https://projects.theforeman.org/issues/37772), [31b5c98b](https://github.com/Katello/katello.git/commit/31b5c98ba80fbe8ae8e13eb902529fe6dc81bf6a))
 * BulkChangeCVModal should be disabled when Any Organization is selected ([#37546](https://projects.theforeman.org/issues/37546), [ac9da969](https://github.com/Katello/katello.git/commit/ac9da96950389954d48bf741c1f759b03d289524), [4a288f94](https://github.com/Katello/katello.git/commit/4a288f944abbf53bd5d7b25084d0794f0a34eea1))
 * Kickstart Repository association is not deleted from a host when it is unregistered ([#37518](https://projects.theforeman.org/issues/37518), [9dcbd3e0](https://github.com/Katello/katello.git/commit/9dcbd3e094811639ec3ba0cdc796013467433784))
 * Package update chooses latest version instead of input version ([#37072](https://projects.theforeman.org/issues/37072), [d07494f4](https://github.com/Katello/katello.git/commit/d07494f4dba5f32f4673eb78ada8e36bacfa985d))

### API
 * Add content view environment labels to host rabl ([#37957](https://projects.theforeman.org/issues/37957), [c123c23f](https://github.com/Katello/katello.git/commit/c123c23f57e51308ca25f57b91faed7acde298d0))

### Hammer
 * Update hammer host info and hammer host list for multi-environment hosts ([#37948](https://projects.theforeman.org/issues/37948), [d2c7a358](https://github.com/Katello/hammer-cli-katello.git/commit/d2c7a35887f386157fcf0975a90b2d25fb1fc293))
 * Hammer does not filter deb-packages correctly ([#37924](https://projects.theforeman.org/issues/37924), [ee225a71](https://github.com/Katello/hammer-cli-katello.git/commit/ee225a714a3f7e60fa53c18d63762b182c361379))

### Activation Key
 * Activation key doesn't get LCE/CV assigned to it on creation ([#37941](https://projects.theforeman.org/issues/37941), [82d7a2c8](https://github.com/Katello/katello.git/commit/82d7a2c8899a1ccf52e124dcc8464d20970e9599))
 * Add multi-env AK display to hammer activation-key info ([#37865](https://projects.theforeman.org/issues/37865), [74e13f9f](https://github.com/Katello/katello.git/commit/74e13f9fa50fa000d69e9c3ad2df374787058295), [2142e03e](https://github.com/Katello/hammer-cli-katello.git/commit/2142e03ecea8ca8ac149daacc6e27c3e43484433))
 * Single activation key is not filled in on Register page ([#37572](https://projects.theforeman.org/issues/37572), [22ed4291](https://github.com/Katello/katello.git/commit/22ed4291d77a925d7c326a29150b9345575bc55f))

### Host Collections
 * Issues when using Host Collection membership Management, the number of content hosts is not accurate ([#37934](https://projects.theforeman.org/issues/37934), [10e63301](https://github.com/Katello/katello.git/commit/10e63301cc27ae19512aec63cb1b1fc971031595))

### Subscriptions
 * Installed products report fails with Jail issue for #purpose_role and #purpose_usage ([#37921](https://projects.theforeman.org/issues/37921), [5aad5543](https://github.com/Katello/katello.git/commit/5aad554311c7764b5f985825b2886c247cc05d8c))

### Content Views
 * Content view version errata page shows incorrect date for "updated at" value ([#37911](https://projects.theforeman.org/issues/37911), [78146fe4](https://github.com/Katello/katello.git/commit/78146fe4798e7025cbfc85a3097843eb12bc1946))
 * Newly published CV version shows need_published as true ([#37633](https://projects.theforeman.org/issues/37633), [d971128b](https://github.com/Katello/katello.git/commit/d971128becebce1cb42cebb417172774f706c8ec))
 * katello_repository_debs "id" column hits max integer size ([#37585](https://projects.theforeman.org/issues/37585), [fc3dff18](https://github.com/Katello/katello.git/commit/fc3dff18c6a74cb089bceb8c873070e472ce79a5))
 * Very long CV names/labels display weirdly on CV UI ([#37530](https://projects.theforeman.org/issues/37530), [8548944e](https://github.com/Katello/katello.git/commit/8548944ee75c7eb4f3adbc304f8b975efb59c266))
 * Make distributing archived content view repositories off by default ([#37006](https://projects.theforeman.org/issues/37006), [24cd3a97](https://github.com/Katello/katello.git/commit/24cd3a977f375555ec5a1456322828c50aa9771a))

### Errata Management
 * Bold "Skip dependency solving for a significant speed increase" on incremental update page ([#37839](https://projects.theforeman.org/issues/37839), [a9bb2033](https://github.com/Katello/katello.git/commit/a9bb203319904166b5761c1caa21c54e1bc43e04))

### Foreman Proxy Content
 * [DEV] [RFE] Need an option to turn off the 'Reclaim Space' warning ([#37716](https://projects.theforeman.org/issues/37716), [28e0a4e7](https://github.com/Katello/katello.git/commit/28e0a4e7924db41e5ef2846a464832c66ec3c710))

### Tests
 * Tests failing on Ruby 2.7 due to sorting of content types in the message ([#37681](https://projects.theforeman.org/issues/37681), [f43b70ae](https://github.com/Katello/katello.git/commit/f43b70aeea914c14fe61d375fc2c288252ed30fa))

### Inter Server Sync
 * PUT /katello/api/organizations/:id doesn't update redhat_repository_url ([#37658](https://projects.theforeman.org/issues/37658), [99641b89](https://github.com/Katello/katello.git/commit/99641b8971a5f947877f3947908b2116c0872177))

### Client/Agent
 * "Upload profile - Katello Script Default" doesn't work for SLES ([#37569](https://projects.theforeman.org/issues/37569), [99f5cdbb](https://github.com/Katello/katello.git/commit/99f5cdbbd81ce331515d4494bb809fe287ed96a7))

### katello-tracer
 * sudo katello-tracer-upload fails ([#37561](https://projects.theforeman.org/issues/37561), [94445d2c](https://github.com/Katello/katello.git/commit/94445d2c80a73ea9aca128acb13039c533fcd8d6))

### Tooling
 * Rewrite 'React Tests' GH action ([#37560](https://projects.theforeman.org/issues/37560), [9dbfc297](https://github.com/Katello/katello.git/commit/9dbfc297e1e97f0728c16e4d46938fdd33879b5f))

### Web UI
 * Exclude vendor dir in jest config ([#37506](https://projects.theforeman.org/issues/37506), [71bee44f](https://github.com/Katello/katello.git/commit/71bee44f768009dd8b67370a8c48d49fdfc818a7))

### Other
 * Use memory fact instead of dmi ([#37866](https://projects.theforeman.org/issues/37866), [fe178dd1](https://github.com/Katello/katello.git/commit/fe178dd17dc7b0777eeb654e04f7e4fae20c765c))
 * Remove python3-tracer package from el8 ([#37526](https://projects.theforeman.org/issues/37526), [8413020a](https://github.com/Katello/katello-host-tools.git/commit/8413020acb3ce15783a210a1c4d8dc3022cc7fae))
