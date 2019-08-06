# 3.13.0-RC1 Baltic Porter (2019-08-06)

## Features

### Repositories
 * [Pulp-ansible] Expose ansible collections API endpoints ([#27268](https://projects.theforeman.org/issues/27268), [be6ab307](https://github.com/Katello/katello.git/commit/be6ab307ebb6da9be0ada8806dc3c60047822c61))
 * support creating docker content in pulp3 ([#26996](https://projects.theforeman.org/issues/26996), [c6fa1ec1](https://github.com/Katello/katello.git/commit/c6fa1ec1d8b784e23f4e827a9e1b8043e84e8108))
 * Support Creating ansible collection repostories ([#26991](https://projects.theforeman.org/issues/26991), [e35cb27f](https://github.com/Katello/katello.git/commit/e35cb27f738cca1f868f34bca8e24de24c0a3daf))
 * Use debian style repositories with ssl certificates ([#26901](https://projects.theforeman.org/issues/26901), [ce3a4e6d](https://github.com/Katello/katello.git/commit/ce3a4e6d3558783affbc6be5c82512edf0e71840))
 * Support cancelling tasks on Pulp3 ([#26863](https://projects.theforeman.org/issues/26863), [70cd5ec2](https://github.com/Katello/katello.git/commit/70cd5ec2472ae2d7844296fc9191c288f8007f47))
 * Services check before running an action for pulp3  ([#26857](https://projects.theforeman.org/issues/26857), [41c6b6c9](https://github.com/Katello/katello.git/commit/41c6b6c9fc83ea62c4b749f8cff4a4037fcb8744))

### Hammer
 * Hammer actions for System Purpose on Activation Keys ([#27230](https://projects.theforeman.org/issues/27230), [5ac18f74](https://github.com/Katello/hammer-cli-katello.git/commit/5ac18f74eb9937e5e32e8299d7c4a9df35fc493a))
 * "hammer host-collection hosts" including erratas information ([#27096](https://projects.theforeman.org/issues/27096), [fd0fd323](https://github.com/Katello/hammer-cli-katello.git/commit/fd0fd32334b4ef2b7eacc8c3c29cc4bcf39ee87d))
 *  [RFE] "hammer host list" including erratas information ([#27094](https://projects.theforeman.org/issues/27094), [cc5acad3](https://github.com/Katello/hammer-cli-katello.git/commit/cc5acad370b3a4659d9116e2e8daf44948cb6460))
 * Hammer actions for System Purpose on a Host ([#24170](https://projects.theforeman.org/issues/24170), [ec17bd02](https://github.com/Katello/hammer-cli-katello.git/commit/ec17bd02c639f98fe044606188accfab5ffcc0d1))

### Tests
 * Add minitest reporter to identify slow tests ([#27222](https://projects.theforeman.org/issues/27222), [8d0c2fe1](https://github.com/Katello/katello.git/commit/8d0c2fe1dc1004f826512635c2ed165be3d34b46))

### Settings
 * Katello setting for specifying global default proxy ([#27009](https://projects.theforeman.org/issues/27009), [1a02adfb](https://github.com/Katello/katello.git/commit/1a02adfb65a8af295ffe9ff5902e0e2a22470964))

### Content Views
 * support composite cvs with multiple source repos with pulp3 ([#26930](https://projects.theforeman.org/issues/26930), [86217e5f](https://github.com/Katello/katello.git/commit/86217e5f284e9b9d6ce2ba768a86f7b07e097e0c))

### API
 * [RFE] Would like to see a way to display errata date when using hammer erratum list ([#26889](https://projects.theforeman.org/issues/26889), [d994ad16](https://github.com/Katello/hammer-cli-katello.git/commit/d994ad16b2762efc86355c09c4402a2820f9a03b))
 * [RFE]-hammer subscription list command should show the start date of the subscriptions  ([#26888](https://projects.theforeman.org/issues/26888))

### Errata Management
 * No Select All option in Content Host Errata page ([#26811](https://projects.theforeman.org/issues/26811), [4ff78aa3](https://github.com/Katello/katello.git/commit/4ff78aa33711b7d7ef91ebce0dc871c62f2573f9))

### Web UI
 * [UI] Support System Purpose on Activation Keys ([#24180](https://projects.theforeman.org/issues/24180), [0299b87e](https://github.com/Katello/katello.git/commit/0299b87ee3a0dca3d5a1fbb741939850edccd98b))

### Hosts
 * I want to perform Package Actions on hosts with debian os family. ([#23794](https://projects.theforeman.org/issues/23794), [26b9fef6](https://github.com/Katello/katello.git/commit/26b9fef64a15367d971b1f670c7fc3acda8a2c02), [58d581f6](https://github.com/Katello/katello.git/commit/58d581f6bcbb1a40d084255c3cf0bd8ccdf32257), [65ca3119](https://github.com/Katello/katello.git/commit/65ca31194ace3f2901510be2c9a9db9dab51ae29), [8fbd28ac](https://github.com/Katello/katello.git/commit/8fbd28ac8ac22db0571205c0e8cbd32efe6b209b), [809da1cd](https://github.com/Katello/katello.git/commit/809da1cdb3ff6ac94fe6ffa12eaf8bc80deef5e5))

### Other
 * propagate global http proxy to all organizations ([#27100](https://projects.theforeman.org/issues/27100), [be4ba8ed](https://github.com/Katello/katello.git/commit/be4ba8edbf217bf14dca21473c4519f38ca7586f))
 * Extend Activation Keys to support System Purpose ([#27050](https://projects.theforeman.org/issues/27050), [3329a4f0](https://github.com/Katello/katello.git/commit/3329a4f0336f37db3bd026b93c96904b012391f1), [cdbbc2d3](https://github.com/Katello/katello.git/commit/cdbbc2d39866675f557bf5b3b34a538678c09b78))
 * rake task to update default content http proxy ([#27037](https://projects.theforeman.org/issues/27037), [730ba5e8](https://github.com/Katello/katello.git/commit/730ba5e8d7989d0e01245c1fbf019ce2726c7a7c), [8242788f](https://github.com/Katello/katello.git/commit/8242788ff1b9d019e388588bd6bf1bbc19aa8185))
 * Katello Tracer Upload Zypper Plugin ([#26375](https://projects.theforeman.org/issues/26375), [484ecdb0](https://github.com/Katello/katello-host-tools.git/commit/484ecdb0e486baf8f41f7ff06ee8970e88c487ba))

## Bug Fixes

### Repositories
 * Pulp2 Sync operations fail with http proxy ([#27518](https://projects.theforeman.org/issues/27518), [a0207cd9](https://github.com/Katello/katello.git/commit/a0207cd99f12813e0b10e07d637a8e834fcb6def))
 * change default download_policy for custom repos ([#27367](https://projects.theforeman.org/issues/27367), [67835568](https://github.com/Katello/katello.git/commit/678355684689d02b324a0d430827c852e6f49b1f))
 * visiting redhat repositories page causes error: undefined method url for nil class ([#27306](https://projects.theforeman.org/issues/27306), [675d5413](https://github.com/Katello/katello.git/commit/675d54134c23e358b500ed5d9f6e603fc033b5ab))
 * Saving Custom repos can cause "Upstream password requires upstream username be set" ([#27279](https://projects.theforeman.org/issues/27279), [2125deed](https://github.com/Katello/katello.git/commit/2125deedf0f7611674511cb331280f2e790dd024))
 * file repository sync fails under pulp2 during indexing "RestClient::BadRequest  400 Bad Request" ([#27277](https://projects.theforeman.org/issues/27277), [c898619b](https://github.com/Katello/katello.git/commit/c898619b106624a6a9682cc5e579074b4f954a79))
 * Update the CDN url may break the repositories' feed url ([#27242](https://projects.theforeman.org/issues/27242), [362cf7f0](https://github.com/Katello/katello.git/commit/362cf7f03cdcec2d56c401e68096a4cb14d2c941))
 * Automation publish of composite CV does not work when multiple content views are promoted ([#27194](https://projects.theforeman.org/issues/27194), [7265be37](https://github.com/Katello/katello.git/commit/7265be37ca1de617ae8b7c040f2f48be20db45b6))
 * Update manifest and repo enable actions to use global http proxy ([#27121](https://projects.theforeman.org/issues/27121), [5b98f31e](https://github.com/Katello/katello.git/commit/5b98f31e09df7667751b92b24754510c12ab9de8))
 * Need to hide RHEL 8 Server kickstart repo during enablement, like we did for 6Server and 7Server kickstart repos. ([#27102](https://projects.theforeman.org/issues/27102), [8fe4f6f7](https://github.com/Katello/katello.git/commit/8fe4f6f7a17ff80ae51a3bb89c49b80c62742372), [fe7244b5](https://github.com/Katello/katello.git/commit/fe7244b506f3439757d821be3516eb2f460ac97a))
 * Changing download policy fails with error Validation failed: Upstream username and password may only be set on custom repositories ([#26895](https://projects.theforeman.org/issues/26895), [0fb56644](https://github.com/Katello/katello.git/commit/0fb5664467fcb5827b435ed266ddf61845c9bcee))
 * error updating a yum repo "can't write unknown attribute `capsule_id`" ([#26870](https://projects.theforeman.org/issues/26870), [4b11f18a](https://github.com/Katello/katello.git/commit/4b11f18a2c43e97a63e6d2f49be72199f7efb379))
 * Change pulp-selector to not be a pass-through action ([#26868](https://projects.theforeman.org/issues/26868), [0be0af45](https://github.com/Katello/katello.git/commit/0be0af457324e66c92563b247dd91fbaa932c0a3))

### Hammer
 * hammer package info does not show all returned data ([#27504](https://projects.theforeman.org/issues/27504), [3f90df4f](https://github.com/Katello/hammer-cli-katello.git/commit/3f90df4f504f1ae92aef1cb75ef92cc34018be1c))
 * `hammer activation-key create` mixes lifecycle environment and puppet environment in hammer_cli_katello-0.18.0-1 ([#27428](https://projects.theforeman.org/issues/27428))
 * `hammer content-view version export-legacy` should not be described as deprecated ([#27261](https://projects.theforeman.org/issues/27261), [1312b105](https://github.com/Katello/hammer-cli-katello.git/commit/1312b105395ea3b74d05123092a2c1617f162bbf))
 * hammer content view version export does not returns correct repository.  ([#27101](https://projects.theforeman.org/issues/27101), [938591cd](https://github.com/Katello/hammer-cli-katello.git/commit/938591cd73153e73480c381c09d5ebf0d47792c2))
 * hammer content view version export fails. ([#27039](https://projects.theforeman.org/issues/27039), [39aa28d1](https://github.com/Katello/hammer-cli-katello.git/commit/39aa28d11c30d2e8ab789759ebccdcadebcdbfa7))

### Tests
 * pulp_docker_client release has broken katello tests ([#27423](https://projects.theforeman.org/issues/27423), [85722082](https://github.com/Katello/katello.git/commit/857220820e6d4a814b61ca219aae24d8f2d650e6), [841bf0bf](https://github.com/Katello/katello.git/commit/841bf0bfbfd49f61cad2785edd989d83b050e48a))
 * katello tests on foreman prs fail with ERROR:  relation "http_proxies" does not exist ([#27286](https://projects.theforeman.org/issues/27286), [44e25d5c](https://github.com/Katello/katello.git/commit/44e25d5ca2f56c0279c5c75487d976d165380ed9))
 * eslint errors in katello ([#27116](https://projects.theforeman.org/issues/27116), [01549bc6](https://github.com/Katello/katello.git/commit/01549bc6cd7c925c88ff4744226c746effc640d0))
 * master tests fail with invalid value for "proxy_url", the character length must be great than or equ ([#26866](https://projects.theforeman.org/issues/26866), [4acd90a4](https://github.com/Katello/katello.git/commit/4acd90a4963c7217e5b66bd1ba653f80d901ce3d))
 * Seed tests failure because of bcrypt ([#26682](https://projects.theforeman.org/issues/26682), [bc75baba](https://github.com/Katello/katello.git/commit/bc75babad8f278e1063ea380387e17c8faa62f42))

### Content Views
 * checksum-type does not updated on already synced repository at Satellite Capsule. ([#27394](https://projects.theforeman.org/issues/27394), [eabe6d86](https://github.com/Katello/katello.git/commit/eabe6d8688d43f52a74f5eca02ea3d7de5617ca9))
 * Duplicate content views with same filter criteria in a CCV doesn't show full packages count ([#27241](https://projects.theforeman.org/issues/27241), [6a1f7b04](https://github.com/Katello/katello.git/commit/6a1f7b04f7960a3795910928f7b0ba25ab760c14))
 * Publishing a content view with a yum repo produces no metadata ([#26947](https://projects.theforeman.org/issues/26947), [f1c05c99](https://github.com/Katello/katello.git/commit/f1c05c99065f9e44d0a47800a367d6ab435d15d6))
 * Content View publish copying wrong errata ([#26720](https://projects.theforeman.org/issues/26720), [fc8c3f96](https://github.com/Katello/katello.git/commit/fc8c3f9682f58e0855f35bbf429ebde84a4d525b))

### Web UI
 *  global "__" translation function is still in use in react code ([#27392](https://projects.theforeman.org/issues/27392), [d67e4ab1](https://github.com/Katello/katello.git/commit/d67e4ab18d0a95454d145295ae3d54c53605a46f))
 * Pulp3 - Make progress presenter extensible for all content types ([#27370](https://projects.theforeman.org/issues/27370), [6c7846b2](https://github.com/Katello/katello.git/commit/6c7846b211d74bd62fe9ddd76b5ecde7fc59a3f8))
 * Upgrade katello to use the new @theforeman/vendor npm package ([#27368](https://projects.theforeman.org/issues/27368), [a08a2138](https://github.com/Katello/katello.git/commit/a08a213810f619f55bc9221de62c6b95692c3937))
 * Red hat repositories page, right hand pane throws an error ([#27152](https://projects.theforeman.org/issues/27152), [86086718](https://github.com/Katello/katello.git/commit/8608671811078333daf13b4f557429075266f1a6))
 * remove react-router package ([#26752](https://projects.theforeman.org/issues/26752), [157f3522](https://github.com/Katello/katello.git/commit/157f3522dfd1d0612717384f9cbc7fa91a7a2523), [133397d4](https://github.com/Katello/katello.git/commit/133397d4b2cf2defc771427a537ca44d5c2a8100))
 * move system statuses from deface to react ([#26434](https://projects.theforeman.org/issues/26434), [0c44a2fa](https://github.com/Katello/katello.git/commit/0c44a2fa68e8fca1a1e6b86582512b603809d6d6))

### Hosts
 * javascript error on hosts page  Cannot read property 'includes' of null ([#27257](https://projects.theforeman.org/issues/27257), [bc46bff2](https://github.com/Katello/katello.git/commit/bc46bff284be3e4bf482a1d941a4b61fb1d7818a))
 * Applying errata through remote execution doesn't work ([#27256](https://projects.theforeman.org/issues/27256), [c88d3a85](https://github.com/Katello/katello.git/commit/c88d3a851d1ce108b33ffb6f28bf6d3ea3e930fa))
 * Host subscription status link doesn't work ([#27079](https://projects.theforeman.org/issues/27079), [96c453b4](https://github.com/Katello/katello.git/commit/96c453b4468c7b4f4d881143934060727e72e310))
 * Empty repository list when using bulk action for Manage Repository Sets  ([#26767](https://projects.theforeman.org/issues/26767), [8765d159](https://github.com/Katello/katello.git/commit/8765d1599e244eb6d3162c0bd49c474b8b659937))

### API
 * ping api call doesn't return messages ([#27229](https://projects.theforeman.org/issues/27229), [37c52033](https://github.com/Katello/katello.git/commit/37c520334b3481a8249afded75d3fcf8cb511627))
 * You cannot update a content-view filter's description using hammer ([#27213](https://projects.theforeman.org/issues/27213), [4283740c](https://github.com/Katello/hammer-cli-katello.git/commit/4283740c81a8aef0f32a6632e0d905abd8bfbc97), [e3e0f959](https://github.com/Katello/katello.git/commit/e3e0f9596358449141783e9f206cb67cc6affab3), [a9ddc074](https://github.com/Katello/hammer-cli-katello.git/commit/a9ddc074676158d7b98cf1d77c99f975032d07a5))
 * /katello/api/repository_sets/:id returns too many repositories ([#26981](https://projects.theforeman.org/issues/26981), [95b17ce4](https://github.com/Katello/katello.git/commit/95b17ce4afa848d61f0ffe40f9451918ed369759))
 * Organization create API requires the org name twice ([#26855](https://projects.theforeman.org/issues/26855), [ade64aa0](https://github.com/Katello/katello.git/commit/ade64aa07f45499cdb6889ee157362e65b1d6bc5))

### Installer
 * seed global http proxy based on configuration ([#27223](https://projects.theforeman.org/issues/27223), [9a926671](https://github.com/Katello/katello.git/commit/9a926671f29f351939d34005a65cda8b9d911f00))

### Tooling
 * migrate to new pulp3 friendly method bindings ([#27204](https://projects.theforeman.org/issues/27204), [d38d1c22](https://github.com/Katello/katello.git/commit/d38d1c2200f47d6eb10c68407c8fbb51b96619f0))
 * pin pulp gems to keep gem changes from breaking tests ([#27089](https://projects.theforeman.org/issues/27089), [e5867dbc](https://github.com/Katello/katello.git/commit/e5867dbc51991abe9fea9ef8e2c4c3f2972b4df5))
 * Gem build: ["LICENSE.txt", "package.json"] are not files ([#27011](https://projects.theforeman.org/issues/27011), [a52a4c3b](https://github.com/Katello/katello.git/commit/a52a4c3b8c355c71f848e4ba2ba7e47c428322c0))
 * remve pulp_file_client gem pinning  ([#27010](https://projects.theforeman.org/issues/27010), [f4a7b6bb](https://github.com/Katello/katello.git/commit/f4a7b6bb1347e05a648374a06ae41c29338d9518))
 * make katello talk ssl to pulp3 ([#27006](https://projects.theforeman.org/issues/27006), [aac2daa0](https://github.com/Katello/katello.git/commit/aac2daa021ec09673779bcdf65c1cc6db59f72ea))
 * update axium dependency to 0.19 ([#26956](https://projects.theforeman.org/issues/26956), [b2744f1f](https://github.com/Katello/katello.git/commit/b2744f1fc69b3ea4a5bdadaad2610b7947911871))
 * Cannot install errata via katello host tools when using libdnf ([#26920](https://projects.theforeman.org/issues/26920), [05c9eebc](https://github.com/Katello/katello-host-tools.git/commit/05c9eebc0aeb43687a1900fead1649ce7c53189d))

### Foreman Proxy Content
 * Allow rake task delete_orphaned_content to accept smart proxy as argument ([#27169](https://projects.theforeman.org/issues/27169), [d9c02454](https://github.com/Katello/katello.git/commit/d9c024543c7314f8215061b905a6ed5752470075))
 * Every capsule sync causes importers/distributors to get updated making an optimized capsule sync a full sync ([#26907](https://projects.theforeman.org/issues/26907), [a096d80d](https://github.com/Katello/katello.git/commit/a096d80d10364300497dac3a08a6855d22f62e91))

### Orchestration
 * ping failing -  if pulp3  is not enabled ([#27080](https://projects.theforeman.org/issues/27080), [0244f87c](https://github.com/Katello/katello.git/commit/0244f87c41883e29c5488fe4318c2130aa50873a))

### Subscriptions
 * Failed to delete the subscriptions from UI. ([#27062](https://projects.theforeman.org/issues/27062), [289581d8](https://github.com/Katello/katello.git/commit/289581d86762ffa176fd5b91f87cdcc220745ac5))
 * "410 gone" alert popped up on UI after manifest file successfully uploaded. ([#26912](https://projects.theforeman.org/issues/26912), [444db0c5](https://github.com/Katello/katello.git/commit/444db0c5d3d91182c1873c6f1deb5281b7d58a23))
 * JS error when opening subscription group ([#26908](https://projects.theforeman.org/issues/26908), [9221bda1](https://github.com/Katello/katello.git/commit/9221bda17fdac4edcb09e96f10cd5e4bad052d4e))
 * Show tooltip on Content Host details indicating that the "server wins" when setting Syspurpose ([#26848](https://projects.theforeman.org/issues/26848), [24b56b9f](https://github.com/Katello/katello.git/commit/24b56b9f09cca97c0581a8999cdb136788dd30ef))
 * Subscriptions details page does not handle Org switch correctly. ([#25113](https://projects.theforeman.org/issues/25113), [f4786fa7](https://github.com/Katello/katello.git/commit/f4786fa7e830e928676dbee092bbc305067e674d))

### Organizations and Locations
 * PG::TRDeadlockDetected: ERROR:  deadlock detected when deleting an Organization ([#26821](https://projects.theforeman.org/issues/26821), [b20f298d](https://github.com/Katello/katello.git/commit/b20f298d3cebf4c19e6322f1e769939e5d3c749e))

### Settings
 * fix typo in setting "Content View Dependency Solving Algorithm" ([#26808](https://projects.theforeman.org/issues/26808), [cd5e0c61](https://github.com/Katello/katello.git/commit/cd5e0c6188e348167929bd29591e81f7900dd309))

### Other
 * Ansible 2.8 needs to be the default recommended repository ([#27327](https://projects.theforeman.org/issues/27327), [0f9006f2](https://github.com/Katello/katello.git/commit/0f9006f21d79ef892d1e0d96438494d4951b7536))
 * Rubocop 0.71.0 updates ([#27267](https://projects.theforeman.org/issues/27267), [7b974241](https://github.com/Katello/katello.git/commit/7b974241c4d1965275fa08905affba63b429170b))
 * Docker Manifest 'downloaded' not used ([#27250](https://projects.theforeman.org/issues/27250), [f1a1eb39](https://github.com/Katello/katello.git/commit/f1a1eb3974650c89b02c600939e40cf33d3657de))
 * Recommended Repositories  needs rhel8 channels ([#27040](https://projects.theforeman.org/issues/27040), [ea3d7cb7](https://github.com/Katello/katello.git/commit/ea3d7cb751b22d0abe0d8d3175fefcc4a4484fcd))
 * Fix bad pulp3 tests ([#27023](https://projects.theforeman.org/issues/27023), [88f6e438](https://github.com/Katello/katello.git/commit/88f6e438b624b9c0b34e4e84a4f6f9132a6bb529))
 * sync management page and tests fail with undefined local variable or method `per_page_options' for  ([#26973](https://projects.theforeman.org/issues/26973), [62fafdad](https://github.com/Katello/katello.git/commit/62fafdad194b948058841baa80c41b2ffdfb8f63))
 * Don't run AutoAttach on every host update ([#26810](https://projects.theforeman.org/issues/26810), [9b6f9987](https://github.com/Katello/katello.git/commit/9b6f9987d2088eea7da1197490079586ccae2847))
 * Fix tests for foreman default locale and default timezone ([#26743](https://projects.theforeman.org/issues/26743), [3ee4d5a0](https://github.com/Katello/katello.git/commit/3ee4d5a0ed5beee2f4395e0f80bf6c58c6210970))
 * Regeneration of ueber certificate is causing optimized capsule sync to perform force full sync every time ([#26721](https://projects.theforeman.org/issues/26721), [c0e13bdf](https://github.com/Katello/katello.git/commit/c0e13bdf0fad9b4361ced9a47196cab31491b810))
 * Pulp3 - Honor contents_changed ([#26686](https://projects.theforeman.org/issues/26686), [fc655526](https://github.com/Katello/katello.git/commit/fc6555260515cae665865abd353ecefd1054c4c1))
