# 4.10.0 (2023-09-12)

## Features

### Tooling
 * Remove Agent events from Katello Event Daemon ([#36706](https://projects.theforeman.org/issues/36706), [ea06f3d1](https://github.com/Katello/katello.git/commit/ea06f3d103587765413c3427b776a836cab6520e))
 * Upgrade to Pulpcore 3.28 ([#36637](https://projects.theforeman.org/issues/36637), [3e134772](https://github.com/Katello/katello.git/commit/3e134772909d6dc6f8002a86ab47e6c456c46022))

### API
 * Remove katello-agent API endpoints ([#36665](https://projects.theforeman.org/issues/36665), [bb738c6a](https://github.com/Katello/katello.git/commit/bb738c6ae3c6336706606142b856496b8d3f6ab1), [ff7d5d71](https://github.com/Katello/hammer-cli-katello.git/commit/ff7d5d71b55920284974134c11d4611c40675bbc))

### Hosts
 * New host details UI - Remove katello-agent code ([#36664](https://projects.theforeman.org/issues/36664), [acd85a45](https://github.com/Katello/katello.git/commit/acd85a45b04061c4f3499e2fe1076cb0420008ed))

### Content Views
 * "Add content view" window and "Update version" window should display content view version, description and publishing date ([#36648](https://projects.theforeman.org/issues/36648), [c9fe25d6](https://github.com/Katello/katello.git/commit/c9fe25d6705d5cf84dc60fefb521e8d3e939688b))

### Alternate Content Sources
 * Add option --all to "hammer alternate-content-source refresh" command to refresh all ACS's ([#36589](https://projects.theforeman.org/issues/36589), [9599a2c5](https://github.com/Katello/katello.git/commit/9599a2c58d9dd804d463c985b9bcfbdfbd02fd1b), [1f29a1a8](https://github.com/Katello/hammer-cli-katello.git/commit/1f29a1a8acfcdb5689ee773da06327c061356bb0))

### Activation Key
 * Add activation key details top bar ([#36576](https://projects.theforeman.org/issues/36576), [b4f50250](https://github.com/Katello/katello.git/commit/b4f50250492191c8caf610593f564276b8c2a098))

## Bug Fixes

### Web UI
 * about page broken after katello-agent removal ([#36722](https://projects.theforeman.org/issues/36722), [5d2f049c](https://github.com/Katello/katello.git/commit/5d2f049c72b900f45de7e062edc162207b6743ba))
 * Legacy Content Host UI - Remove katello-agent code ([#36649](https://projects.theforeman.org/issues/36649), [5dc6942e](https://github.com/Katello/katello.git/commit/5dc6942e738d55c0a4a672cab881245aa482f3ed))
 * Content tab subtabs disappear from host details page when you click them ([#36613](https://projects.theforeman.org/issues/36613), [d12f0b13](https://github.com/Katello/katello.git/commit/d12f0b1303608401912e2e28e3f1f2ce1f53ae5e))
 * Update PermissionDenied snapshots  ([#36552](https://projects.theforeman.org/issues/36552), [1b149653](https://github.com/Katello/katello.git/commit/1b149653ba1c62a4473595b0a810d14f27c351a7))

### Hosts
 * Discovery Provisioning fails as the sync media is getting diminished from the host page even though its synced. ([#36721](https://projects.theforeman.org/issues/36721), [58dd1b73](https://github.com/Katello/katello.git/commit/58dd1b73e79ce27895107adbfaa5d7122a95204b))
 * Can not re-register with --force after deleting consumer certs against satellite614 ([#36674](https://projects.theforeman.org/issues/36674), [eb2d2557](https://github.com/Katello/katello.git/commit/eb2d2557b034d12932863a941ebcfeb0ff4efc70))
 * Change host content source warning implies overall failure when it should instead tell you that step 1 of 2 is complete ([#36623](https://projects.theforeman.org/issues/36623), [ad9bfef2](https://github.com/Katello/katello.git/commit/ad9bfef21905c34fa58b3f3a397c9ed22dd33237))
 * Change content source page never shows job invocation link ([#36621](https://projects.theforeman.org/issues/36621), [aae344dc](https://github.com/Katello/katello.git/commit/aae344dcb23dc12f246af9cc79ac4dbb4acde485))
 * Rename 'Change content source' job template so it's less confusing ([#36597](https://projects.theforeman.org/issues/36597), [8bbb1ff0](https://github.com/Katello/katello.git/commit/8bbb1ff0df34cce029946ea70aa0647fdb93325a))
 * Host details UI, Repository sets table contains empty column header ([#36445](https://projects.theforeman.org/issues/36445), [1a758354](https://github.com/Katello/katello.git/commit/1a758354ebc8b308edc4cf50e4da60326ff7ee75))
 * Remove the setting 'Use remote execution by default' ([#36083](https://projects.theforeman.org/issues/36083), [283c63dc](https://github.com/Katello/katello.git/commit/283c63dc301b52f08ff6e09d45f0e817e811f9a0))

### API
 * Remove deprecated docker_tags_whitelist ([#36695](https://projects.theforeman.org/issues/36695), [2292c987](https://github.com/Katello/katello.git/commit/2292c98756554ab43f4942790466fb783e6a302c))

### Content Views
 * Content View filter creation/edit button should say "Save" instead of "Edit rule" ([#36687](https://projects.theforeman.org/issues/36687), [afcee25e](https://github.com/Katello/katello.git/commit/afcee25ef92a210cb2bb6e29c19589b62c176473))
 * Adding a CV to a CCV lists CV versions disorderly ([#36679](https://projects.theforeman.org/issues/36679), [908f869f](https://github.com/Katello/katello.git/commit/908f869f7c5569d2594ed3b3d904537f33868abc))
 * Solve dependencies in settings is a dead setting ([#36654](https://projects.theforeman.org/issues/36654), [8e5ffdde](https://github.com/Katello/katello.git/commit/8e5ffdde6ff1794288953090753e88a742d58216))
 * [Regression] The "hammer content-view version republish-repositories" action is not republishing repository metadata for the content-view versions in Satellite 6.14 ([#36638](https://projects.theforeman.org/issues/36638), [b32de373](https://github.com/Katello/katello.git/commit/b32de373813b0240ee62a09745cc747de9252d59))
 * update event is not created after updating CV name ([#36628](https://projects.theforeman.org/issues/36628), [a14bb3f1](https://github.com/Katello/katello.git/commit/a14bb3f1d3681b8422d35149f5cbff583482c1d5))
 * Content View API lists same Environment Name and Label despite name changes ([#36598](https://projects.theforeman.org/issues/36598), [31d434ad](https://github.com/Katello/katello.git/commit/31d434adec82cb228f9e872c838f742a08f8f632))
 * Filter gets applied to all the repository upon removal of repository for which the filter was created. ([#36577](https://projects.theforeman.org/issues/36577), [49a55b14](https://github.com/Katello/katello.git/commit/49a55b142600866ac9e384b4230e91a7c2e03960))
 * Content view Promote always warns for 'Force promotion' even if correct path is followed. ([#36515](https://projects.theforeman.org/issues/36515), [39a79824](https://github.com/Katello/katello.git/commit/39a7982497318a4d28a3a85a22391d66f576d1e9))

### Foreman Proxy Content
 * Restore n-1 smart proxy sync support for pulpcore 3.28 / 3.22 ([#36686](https://projects.theforeman.org/issues/36686), [e5377b84](https://github.com/Katello/katello.git/commit/e5377b84513fb59765395f21cdc13019156f683a), [623dd15b](https://github.com/Katello/katello.git/commit/623dd15b3848dc20e4dbf28090eac72be76ecc0f))
 * Capsule Content view's 'Last published' field is confusing ([#36629](https://projects.theforeman.org/issues/36629), [c34f38eb](https://github.com/Katello/katello.git/commit/c34f38eb750f38543294cd90f85ed1efcfaa5b70))

### Alternate Content Sources
 * ACS bulk refresh through API silently sanitizes input ids ([#36634](https://projects.theforeman.org/issues/36634), [b291abc2](https://github.com/Katello/katello.git/commit/b291abc28537628524033642020d7f33ad8f82ff))
 * ACS error message contains duplicate words ([#36590](https://projects.theforeman.org/issues/36590), [91a48ec1](https://github.com/Katello/katello.git/commit/91a48ec1aa61d98aba83648ba1f48d8a55bcebff))
 * Incorrect aria-label and component id in the alternate content source modal for editing Products ([#36514](https://projects.theforeman.org/issues/36514), [ba388b63](https://github.com/Katello/katello.git/commit/ba388b63dca0a5b79cb228d9d33968436c4395f0))
 * Incorrect aria-label and component id in the alternate content source modal for editing smart proxies ([#36513](https://projects.theforeman.org/issues/36513), [7efc0cb6](https://github.com/Katello/katello.git/commit/7efc0cb6ebcb3505dc6d04362e089394f71e2fe9))
 * Incorrect aria-label in the alternate content source drawer ([#36511](https://projects.theforeman.org/issues/36511), [6f8faee5](https://github.com/Katello/katello.git/commit/6f8faee515797f4e6edea680a3498454abcdb596), [6dffdc7c](https://github.com/Katello/katello.git/commit/6dffdc7ca703754228634bb6932bf96facc0af6a))
 * Incorrect aria-label and component id in the alternate content source modal for editing credentials ([#36510](https://projects.theforeman.org/issues/36510), [bb874ab9](https://github.com/Katello/katello.git/commit/bb874ab92f060ef4849bd5d9bc3854017f6a4184))
 * Simplified ACS update fails to remove products if product has any empty URL repos ([#36221](https://projects.theforeman.org/issues/36221), [80a84ae6](https://github.com/Katello/katello.git/commit/80a84ae61fdef7ad838b133b5be88353523567d0))

### Container
 * [smart_proxy_container_gateway] Smart proxy clamps reply to a max of 100 tags when listing the tags ([#36616](https://projects.theforeman.org/issues/36616), [f14594ac](https://github.com/Katello/smart_proxy_container_gateway.git/commit/f14594ac95e848bc5c588385ff66e7af74e97152))

### Repositories
 * Repository export fails with Error "Validation failed: Relative path is too long ([#36584](https://projects.theforeman.org/issues/36584), [776036f6](https://github.com/Katello/katello.git/commit/776036f6f5f40d5808c9aa5f3f2fe327a5c4e841))
 * Remove deprecated & not working API endpoints from APIdoc ([#36530](https://projects.theforeman.org/issues/36530), [a2959b27](https://github.com/Katello/katello.git/commit/a2959b274b0df32d8d8e2ee3b01c6e4eba7b9d70))
 * Can't remove GPG and SSL Keys from existing Product using the API ([#36497](https://projects.theforeman.org/issues/36497), [5dc7382e](https://github.com/Katello/katello.git/commit/5dc7382e8b9abe55847b67558af7405e8a59468b))
 * Updating ignorable_content should not trigger pulp updates cause there is nothing to update in pulp. ([#36428](https://projects.theforeman.org/issues/36428), [22140b06](https://github.com/Katello/katello.git/commit/22140b06844c4f39bb95fbf1661090c711e091a1))

### Errata Management
 * Allow installable errata count methods ([#36506](https://projects.theforeman.org/issues/36506), [f3dba82d](https://github.com/Katello/katello.git/commit/f3dba82d5f35f679c0f7906cf07e211a716b6785))

### Subscriptions
 * Fix the Documentation link in the Manifest history tab ([#36272](https://projects.theforeman.org/issues/36272), [aeb2b178](https://github.com/Katello/katello.git/commit/aeb2b178665e7e6e1501305268a339173c92c7d0))

### Other
 * Incorrect aria-label and component id in the alternate content source modal for editing credentials certificates ([#36512](https://projects.theforeman.org/issues/36512), [da817191](https://github.com/Katello/katello.git/commit/da8171915ddf9acde98602911b4f7b9d913c0c77))
# 4.10.0 (2023-09-06)

## Features

### Tooling
 * Remove Agent events from Katello Event Daemon ([#36706](https://projects.theforeman.org/issues/36706), [ea06f3d1](https://github.com/Katello/katello.git/commit/ea06f3d103587765413c3427b776a836cab6520e))
 * Upgrade to Pulpcore 3.28 ([#36637](https://projects.theforeman.org/issues/36637), [3e134772](https://github.com/Katello/katello.git/commit/3e134772909d6dc6f8002a86ab47e6c456c46022))

### API
 * Remove katello-agent API endpoints ([#36665](https://projects.theforeman.org/issues/36665), [bb738c6a](https://github.com/Katello/katello.git/commit/bb738c6ae3c6336706606142b856496b8d3f6ab1), [ff7d5d71](https://github.com/Katello/hammer-cli-katello.git/commit/ff7d5d71b55920284974134c11d4611c40675bbc))

### Hosts
 * New host details UI - Remove katello-agent code ([#36664](https://projects.theforeman.org/issues/36664), [acd85a45](https://github.com/Katello/katello.git/commit/acd85a45b04061c4f3499e2fe1076cb0420008ed))

### Content Views
 * "Add content view" window and "Update version" window should display content view version, description and publishing date ([#36648](https://projects.theforeman.org/issues/36648), [c9fe25d6](https://github.com/Katello/katello.git/commit/c9fe25d6705d5cf84dc60fefb521e8d3e939688b))

### Alternate Content Sources
 * Add option --all to "hammer alternate-content-source refresh" command to refresh all ACS's ([#36589](https://projects.theforeman.org/issues/36589), [9599a2c5](https://github.com/Katello/katello.git/commit/9599a2c58d9dd804d463c985b9bcfbdfbd02fd1b), [1f29a1a8](https://github.com/Katello/hammer-cli-katello.git/commit/1f29a1a8acfcdb5689ee773da06327c061356bb0))

### Activation Key
 * Add activation key details top bar ([#36576](https://projects.theforeman.org/issues/36576), [b4f50250](https://github.com/Katello/katello.git/commit/b4f50250492191c8caf610593f564276b8c2a098))

## Bug Fixes

### API
 * Remove deprecated docker_tags_whitelist ([#36695](https://projects.theforeman.org/issues/36695), [2292c987](https://github.com/Katello/katello.git/commit/2292c98756554ab43f4942790466fb783e6a302c))

### Content Views
 * Content View filter creation/edit button should say "Save" instead of "Edit rule" ([#36687](https://projects.theforeman.org/issues/36687), [afcee25e](https://github.com/Katello/katello.git/commit/afcee25ef92a210cb2bb6e29c19589b62c176473))
 * Adding a CV to a CCV lists CV versions disorderly ([#36679](https://projects.theforeman.org/issues/36679), [908f869f](https://github.com/Katello/katello.git/commit/908f869f7c5569d2594ed3b3d904537f33868abc))
 * Solve dependencies in settings is a dead setting ([#36654](https://projects.theforeman.org/issues/36654), [8e5ffdde](https://github.com/Katello/katello.git/commit/8e5ffdde6ff1794288953090753e88a742d58216))
 * [Regression] The "hammer content-view version republish-repositories" action is not republishing repository metadata for the content-view versions in Satellite 6.14 ([#36638](https://projects.theforeman.org/issues/36638), [b32de373](https://github.com/Katello/katello.git/commit/b32de373813b0240ee62a09745cc747de9252d59))
 * update event is not created after updating CV name ([#36628](https://projects.theforeman.org/issues/36628), [a14bb3f1](https://github.com/Katello/katello.git/commit/a14bb3f1d3681b8422d35149f5cbff583482c1d5))
 * Content View API lists same Environment Name and Label despite name changes ([#36598](https://projects.theforeman.org/issues/36598), [31d434ad](https://github.com/Katello/katello.git/commit/31d434adec82cb228f9e872c838f742a08f8f632))
 * Filter gets applied to all the repository upon removal of repository for which the filter was created. ([#36577](https://projects.theforeman.org/issues/36577), [49a55b14](https://github.com/Katello/katello.git/commit/49a55b142600866ac9e384b4230e91a7c2e03960))
 * Content view Promote always warns for 'Force promotion' even if correct path is followed. ([#36515](https://projects.theforeman.org/issues/36515), [39a79824](https://github.com/Katello/katello.git/commit/39a7982497318a4d28a3a85a22391d66f576d1e9))

### Foreman Proxy Content
 * Restore n-1 smart proxy sync support for pulpcore 3.28 / 3.22 ([#36686](https://projects.theforeman.org/issues/36686), [e5377b84](https://github.com/Katello/katello.git/commit/e5377b84513fb59765395f21cdc13019156f683a), [623dd15b](https://github.com/Katello/katello.git/commit/623dd15b3848dc20e4dbf28090eac72be76ecc0f))
 * Capsule Content view's 'Last published' field is confusing ([#36629](https://projects.theforeman.org/issues/36629), [c34f38eb](https://github.com/Katello/katello.git/commit/c34f38eb750f38543294cd90f85ed1efcfaa5b70))

### Hosts
 * Can not re-register with --force after deleting consumer certs against satellite614 ([#36674](https://projects.theforeman.org/issues/36674), [eb2d2557](https://github.com/Katello/katello.git/commit/eb2d2557b034d12932863a941ebcfeb0ff4efc70))
 * Change host content source warning implies overall failure when it should instead tell you that step 1 of 2 is complete ([#36623](https://projects.theforeman.org/issues/36623), [ad9bfef2](https://github.com/Katello/katello.git/commit/ad9bfef21905c34fa58b3f3a397c9ed22dd33237))
 * Change content source page never shows job invocation link ([#36621](https://projects.theforeman.org/issues/36621), [aae344dc](https://github.com/Katello/katello.git/commit/aae344dcb23dc12f246af9cc79ac4dbb4acde485))
 * Rename 'Change content source' job template so it's less confusing ([#36597](https://projects.theforeman.org/issues/36597), [8bbb1ff0](https://github.com/Katello/katello.git/commit/8bbb1ff0df34cce029946ea70aa0647fdb93325a))
 * Host details UI, Repository sets table contains empty column header ([#36445](https://projects.theforeman.org/issues/36445), [1a758354](https://github.com/Katello/katello.git/commit/1a758354ebc8b308edc4cf50e4da60326ff7ee75))
 * Remove the setting 'Use remote execution by default' ([#36083](https://projects.theforeman.org/issues/36083), [283c63dc](https://github.com/Katello/katello.git/commit/283c63dc301b52f08ff6e09d45f0e817e811f9a0))

### Web UI
 * Legacy Content Host UI - Remove katello-agent code ([#36649](https://projects.theforeman.org/issues/36649), [5dc6942e](https://github.com/Katello/katello.git/commit/5dc6942e738d55c0a4a672cab881245aa482f3ed))
 * Content tab subtabs disappear from host details page when you click them ([#36613](https://projects.theforeman.org/issues/36613), [d12f0b13](https://github.com/Katello/katello.git/commit/d12f0b1303608401912e2e28e3f1f2ce1f53ae5e))
 * Update PermissionDenied snapshots  ([#36552](https://projects.theforeman.org/issues/36552), [1b149653](https://github.com/Katello/katello.git/commit/1b149653ba1c62a4473595b0a810d14f27c351a7))
 * Incorrect aria-label and component id in the alternate content source modal for editing credentials certificates ([#36512](https://projects.theforeman.org/issues/36512), [da817191](https://github.com/Katello/katello.git/commit/da8171915ddf9acde98602911b4f7b9d913c0c77))

### Alternate Content Sources
 * ACS bulk refresh through API silently sanitizes input ids ([#36634](https://projects.theforeman.org/issues/36634), [b291abc2](https://github.com/Katello/katello.git/commit/b291abc28537628524033642020d7f33ad8f82ff))
 * ACS error message contains duplicate words ([#36590](https://projects.theforeman.org/issues/36590), [91a48ec1](https://github.com/Katello/katello.git/commit/91a48ec1aa61d98aba83648ba1f48d8a55bcebff))
 * Incorrect aria-label and component id in the alternate content source modal for editing Products ([#36514](https://projects.theforeman.org/issues/36514), [ba388b63](https://github.com/Katello/katello.git/commit/ba388b63dca0a5b79cb228d9d33968436c4395f0))
 * Incorrect aria-label and component id in the alternate content source modal for editing smart proxies ([#36513](https://projects.theforeman.org/issues/36513), [7efc0cb6](https://github.com/Katello/katello.git/commit/7efc0cb6ebcb3505dc6d04362e089394f71e2fe9))
 * Incorrect aria-label in the alternate content source drawer ([#36511](https://projects.theforeman.org/issues/36511), [6f8faee5](https://github.com/Katello/katello.git/commit/6f8faee515797f4e6edea680a3498454abcdb596), [6dffdc7c](https://github.com/Katello/katello.git/commit/6dffdc7ca703754228634bb6932bf96facc0af6a))
 * Incorrect aria-label and component id in the alternate content source modal for editing credentials ([#36510](https://projects.theforeman.org/issues/36510), [bb874ab9](https://github.com/Katello/katello.git/commit/bb874ab92f060ef4849bd5d9bc3854017f6a4184))
 * Simplified ACS update fails to remove products if product has any empty URL repos ([#36221](https://projects.theforeman.org/issues/36221), [80a84ae6](https://github.com/Katello/katello.git/commit/80a84ae61fdef7ad838b133b5be88353523567d0))

### Container
 * [smart_proxy_container_gateway] Smart proxy clamps reply to a max of 100 tags when listing the tags ([#36616](https://projects.theforeman.org/issues/36616), [f14594ac](https://github.com/Katello/smart_proxy_container_gateway.git/commit/f14594ac95e848bc5c588385ff66e7af74e97152))

### Repositories
 * Repository export fails with Error "Validation failed: Relative path is too long ([#36584](https://projects.theforeman.org/issues/36584), [776036f6](https://github.com/Katello/katello.git/commit/776036f6f5f40d5808c9aa5f3f2fe327a5c4e841))
 * Remove deprecated & not working API endpoints from APIdoc ([#36530](https://projects.theforeman.org/issues/36530), [a2959b27](https://github.com/Katello/katello.git/commit/a2959b274b0df32d8d8e2ee3b01c6e4eba7b9d70))
 * Can't remove GPG and SSL Keys from existing Product using the API ([#36497](https://projects.theforeman.org/issues/36497), [5dc7382e](https://github.com/Katello/katello.git/commit/5dc7382e8b9abe55847b67558af7405e8a59468b))
 * Updating ignorable_content should not trigger pulp updates cause there is nothing to update in pulp. ([#36428](https://projects.theforeman.org/issues/36428), [22140b06](https://github.com/Katello/katello.git/commit/22140b06844c4f39bb95fbf1661090c711e091a1))

### Errata Management
 * Allow installable errata count methods ([#36506](https://projects.theforeman.org/issues/36506), [f3dba82d](https://github.com/Katello/katello.git/commit/f3dba82d5f35f679c0f7906cf07e211a716b6785))

### Subscriptions
 * Fix the Documentation link in the Manifest history tab ([#36272](https://projects.theforeman.org/issues/36272), [aeb2b178](https://github.com/Katello/katello.git/commit/aeb2b178665e7e6e1501305268a339173c92c7d0))

