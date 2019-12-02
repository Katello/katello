# 3.13.3 Baltic Porter (2019-12-02)

## Bug Fixes

### Repositories
 * foreman-rake katello:reimport fails with 'NoMethodError: undefined method `pulp2_service_class' for nil:NilClass' ([#28223](https://projects.theforeman.org/issues/28223), [36788226](https://github.com/Katello/katello.git/commit/3678822678a370ccea855c4d02ff43e4b6fc5dcf))

### Content Views
 * Unable to delete version in content view [puppet is not installed/puppet content-type is missing] ([#27366](https://projects.theforeman.org/issues/27366), [3f009c16](https://github.com/Katello/katello.git/commit/3f009c165145177a6a59c74fdcb9af7038f0240a))

# 3.13.2 Baltic Porter (2019-11-04)

## Features

### Subscriptions
 * allow API user to search pools using upstream_pool_id ([#28103](https://projects.theforeman.org/issues/28103), [0e1b6b42](https://github.com/Katello/katello.git/commit/0e1b6b426a3225e0af64450efc6fb22fd71f44d1))

## Bug Fixes

### Hosts
 * Validation failed: Name Operating system version already exists when registering ([#28143](https://projects.theforeman.org/issues/28143), [8e71ab7f](https://github.com/Katello/katello.git/commit/8e71ab7f4294d4b60b718f86ee3109b9c887c7fb))
 * Remove RHSM facts when unregistering ([#28080](https://projects.theforeman.org/issues/28080), [7fd616ae](https://github.com/Katello/katello.git/commit/7fd616ae08478f231282c6e019fcb91eb2b44ee0))
 * Content Hosts OS no populated with centos 7 ([#26914](https://projects.theforeman.org/issues/26914), [4b46ebd3](https://github.com/Katello/katello.git/commit/4b46ebd3dbccc661a3900dca68b82330a6802b83))

### API
 * Content View publish does not return a meaningful result in the task output ([#28138](https://projects.theforeman.org/issues/28138), [96a476d9](https://github.com/Katello/katello.git/commit/96a476d912ffb4716d526b4e6ef2735766fcf3e4))

### Repositories
 * Smart Proxy sync fails with undefined method `[]' for nil:NilClass (NoMethodError) ([#28046](https://projects.theforeman.org/issues/28046), [6c2ff4fc](https://github.com/Katello/katello.git/commit/6c2ff4fc97e4f430900e61aef4e71794cca7b5b7))
 
# 3.13.1 Baltic Porter (2019-10-24)

## Features

## Bug Fixes

### Orchestration
 * deadlock on org delete  ([#27849](https://projects.theforeman.org/issues/27849), [1d9378f3](https://github.com/Katello/katello.git/commit/1d9378f3453cf644302e1d775171d4f6c4867fe6))

### Hosts
 * Setting to toggle host profile stealing ([#27840](https://projects.theforeman.org/issues/27840), [7f28e8d4](https://github.com/Katello/katello.git/commit/7f28e8d4dfe67c22b5a5befa9347d1dbbf5a415f))
 * Allow registration when host is unregistered and DMI UUID has changed ([#27739](https://projects.theforeman.org/issues/27739), [0095f03f](https://github.com/Katello/katello.git/commit/0095f03fde5a218dec4e6d624c267195fc423bd8))

### Inter Server Sync
 * Unable to import content view when there are more than 20 of enabled repositories in the target Satellite ([#27807](https://projects.theforeman.org/issues/27807), [4436da5f](https://github.com/Katello/hammer-cli-katello.git/commit/4436da5f24eececad4d4ee9cee19564189190b50))

### Foreman Proxy Content
 * Full Capsule sync doesn't fix the broken repository metadata. ([#27776](https://projects.theforeman.org/issues/27776), [ea10fe85](https://github.com/Katello/katello.git/commit/ea10fe85b241077217511d5002b16d3f5d7ef167))

### Host Collections
 * Incorrect error handling for Update all packages via Remote Execution ([#27768](https://projects.theforeman.org/issues/27768), [3a485398](https://github.com/Katello/katello.git/commit/3a485398c78a42ad02fb19989a5d09f919f147ea))

### Content Views
 * Unable to remove puppet module by uuid from content-view using hammer ([#27718](https://projects.theforeman.org/issues/27718), [7f33b149](https://github.com/Katello/katello.git/commit/7f33b149e5809aa3f215f2821db26000b26b397f))

### Hammer
 * hammer content-view info does not provide information about the newly added "solve_dependencies" option or the "force_puppet_environment" option ([#27715](https://projects.theforeman.org/issues/27715), [a89d742c](https://github.com/Katello/hammer-cli-katello.git/commit/a89d742cad087b293cb38213456b3ced8962e2cc), [9cf4e366](https://github.com/Katello/hammer-cli-katello.git/commit/9cf4e366dc07a6d2f420a052d0045080c503be13))

### Subscriptions
 * Accessing the subscriptions from "Add subscriptions" page redirecting it to either other subscription details or shows 'undefined' or 'no resource loaded' ([#27614](https://projects.theforeman.org/issues/27614), [cfcf11d3](https://github.com/Katello/katello.git/commit/cfcf11d3946aae365bba4468153430f971a6419d))

### Other
 * Allow override of dmi.system.uuid from server side ([#27497](https://projects.theforeman.org/issues/27497), [fd0040f7](https://github.com/Katello/katello.git/commit/fd0040f7377af86cb640214ec0c0d919effd0947))

# 3.13.0 Baltic Porter (2019-10-08)

## Features

### Hosts
 * [RFE] Enhancement of the UUID option on Content Hosts page  ([#27474](https://projects.theforeman.org/issues/27474), [cf271eb7](https://github.com/Katello/katello.git/commit/cf271eb7dc0f9d84a13bcc36a14889bcf155dd18), [6f6886ac](https://github.com/Katello/katello.git/commit/6f6886aca52bb4787f2112ec29a832d7bb158e35))
 * Handle host-related tasks in separate queue to avoid conflicts with user-related actions ([#27248](https://projects.theforeman.org/issues/27248), [2d4f893b](https://github.com/Katello/katello.git/commit/2d4f893b2d97cd1c51c955f70dcfb32157d94bb5), [e29d5da8](https://github.com/Katello/katello.git/commit/e29d5da8207cbaee4cdc2c8334543799ec05abf0))
 * I want to perform Package Actions on hosts with debian os family. ([#23794](https://projects.theforeman.org/issues/23794), [26b9fef6](https://github.com/Katello/katello.git/commit/26b9fef64a15367d971b1f670c7fc3acda8a2c02), [58d581f6](https://github.com/Katello/katello.git/commit/58d581f6bcbb1a40d084255c3cf0bd8ccdf32257), [65ca3119](https://github.com/Katello/katello.git/commit/65ca31194ace3f2901510be2c9a9db9dab51ae29), [8fbd28ac](https://github.com/Katello/katello.git/commit/8fbd28ac8ac22db0571205c0e8cbd32efe6b209b), [809da1cd](https://github.com/Katello/katello.git/commit/809da1cdb3ff6ac94fe6ffa12eaf8bc80deef5e5))

### Hammer
 * Update content view version description via hammer ([#27466](https://projects.theforeman.org/issues/27466), [8c1c3a73](https://github.com/Katello/hammer-cli-katello.git/commit/8c1c3a735f059925043f96dab1d90f10abb8a9a2))
 * Hammer actions for System Purpose on Activation Keys ([#27230](https://projects.theforeman.org/issues/27230), [5ac18f74](https://github.com/Katello/hammer-cli-katello.git/commit/5ac18f74eb9937e5e32e8299d7c4a9df35fc493a))
 * "hammer host-collection hosts" including erratas information ([#27096](https://projects.theforeman.org/issues/27096), [fd0fd323](https://github.com/Katello/hammer-cli-katello.git/commit/fd0fd32334b4ef2b7eacc8c3c29cc4bcf39ee87d))
 *  [RFE] "hammer host list" including erratas information ([#27094](https://projects.theforeman.org/issues/27094), [cc5acad3](https://github.com/Katello/hammer-cli-katello.git/commit/cc5acad370b3a4659d9116e2e8daf44948cb6460))
 * Hammer actions for System Purpose on a Host ([#24170](https://projects.theforeman.org/issues/24170), [ec17bd02](https://github.com/Katello/hammer-cli-katello.git/commit/ec17bd02c639f98fe044606188accfab5ffcc0d1))

### Repositories
 * [Pulp-ansible] Expose ansible collections API endpoints ([#27268](https://projects.theforeman.org/issues/27268), [be6ab307](https://github.com/Katello/katello.git/commit/be6ab307ebb6da9be0ada8806dc3c60047822c61))
 * support creating docker content in pulp3 ([#26996](https://projects.theforeman.org/issues/26996), [c6fa1ec1](https://github.com/Katello/katello.git/commit/c6fa1ec1d8b784e23f4e827a9e1b8043e84e8108))
 * Support Creating ansible collection repostories ([#26991](https://projects.theforeman.org/issues/26991), [e35cb27f](https://github.com/Katello/katello.git/commit/e35cb27f738cca1f868f34bca8e24de24c0a3daf))
 * Use debian style repositories with ssl certificates ([#26901](https://projects.theforeman.org/issues/26901), [ce3a4e6d](https://github.com/Katello/katello.git/commit/ce3a4e6d3558783affbc6be5c82512edf0e71840))
 * Support cancelling tasks on Pulp3 ([#26863](https://projects.theforeman.org/issues/26863), [70cd5ec2](https://github.com/Katello/katello.git/commit/70cd5ec2472ae2d7844296fc9191c288f8007f47))
 * Services check before running an action for pulp3  ([#26857](https://projects.theforeman.org/issues/26857), [41c6b6c9](https://github.com/Katello/katello.git/commit/41c6b6c9fc83ea62c4b749f8cff4a4037fcb8744))
 * [RFE] Upload/delete/view SRPMs on a repo in API ([#26135](https://projects.theforeman.org/issues/26135), [1896305c](https://github.com/Katello/katello.git/commit/1896305c330ea133e61ca4233f2fbd3ca06731ad), [ded919dc](https://github.com/Katello/hammer-cli-katello.git/commit/ded919dc0fb7136c9419a0700a2d804980470671), [150e30a7](https://github.com/Katello/katello.git/commit/150e30a7287aad67662b99038725d4571cf8918a), [250f6452](https://github.com/Katello/hammer-cli-katello.git/commit/250f6452349baf40bf670f4cd7d358a30800f6cb))
 * Unable to upload source RPM packages ([#16712](https://projects.theforeman.org/issues/16712))

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

### Other
 * propagate global http proxy to all organizations ([#27100](https://projects.theforeman.org/issues/27100), [be4ba8ed](https://github.com/Katello/katello.git/commit/be4ba8edbf217bf14dca21473c4519f38ca7586f))
 * Extend Activation Keys to support System Purpose ([#27050](https://projects.theforeman.org/issues/27050), [3329a4f0](https://github.com/Katello/katello.git/commit/3329a4f0336f37db3bd026b93c96904b012391f1), [cdbbc2d3](https://github.com/Katello/katello.git/commit/cdbbc2d39866675f557bf5b3b34a538678c09b78))
 * rake task to update default content http proxy ([#27037](https://projects.theforeman.org/issues/27037), [730ba5e8](https://github.com/Katello/katello.git/commit/730ba5e8d7989d0e01245c1fbf019ce2726c7a7c), [8242788f](https://github.com/Katello/katello.git/commit/8242788ff1b9d019e388588bd6bf1bbc19aa8185))
 * Katello Tracer Upload Zypper Plugin ([#26375](https://projects.theforeman.org/issues/26375), [484ecdb0](https://github.com/Katello/katello-host-tools.git/commit/484ecdb0e486baf8f41f7ff06ee8970e88c487ba))

## Bug Fixes

### Hammer
 * hammer repository upload content failing on rpm uploads ([#27729](https://projects.theforeman.org/issues/27729), [d4a88c8a](https://github.com/Katello/hammer-cli-katello.git/commit/d4a88c8a37db5f0798f3031bccf428e7f8dba898))
 * Remove --repositories flag from hammer content-view update  ([#27523](https://projects.theforeman.org/issues/27523), [29644390](https://github.com/Katello/hammer-cli-katello.git/commit/296443900cc2da0c36cbb2f3b62d598b26a92fd2))
 * Hammer package list with environment flag uses wrong api ([#27508](https://projects.theforeman.org/issues/27508), [0b0b878e](https://github.com/Katello/hammer-cli-katello.git/commit/0b0b878e8c67a6f14eb0c00e1adf05a49ff0c45b))
 * hammer package info does not show all returned data ([#27504](https://projects.theforeman.org/issues/27504), [3f90df4f](https://github.com/Katello/hammer-cli-katello.git/commit/3f90df4f504f1ae92aef1cb75ef92cc34018be1c))
 * `hammer activation-key create` mixes lifecycle environment and puppet environment in hammer_cli_katello-0.18.0-1 ([#27428](https://projects.theforeman.org/issues/27428))
 * `hammer content-view version export-legacy` should not be described as deprecated ([#27261](https://projects.theforeman.org/issues/27261), [1312b105](https://github.com/Katello/hammer-cli-katello.git/commit/1312b105395ea3b74d05123092a2c1617f162bbf))
 * hammer content view version export does not returns correct repository.  ([#27101](https://projects.theforeman.org/issues/27101), [938591cd](https://github.com/Katello/hammer-cli-katello.git/commit/938591cd73153e73480c381c09d5ebf0d47792c2))
 * hammer content view version export fails. ([#27039](https://projects.theforeman.org/issues/27039), [39aa28d1](https://github.com/Katello/hammer-cli-katello.git/commit/39aa28d11c30d2e8ab789759ebccdcadebcdbfa7))

### Content Views
 * Incremental update broken for puppet modules ([#27612](https://projects.theforeman.org/issues/27612), [97dfcfce](https://github.com/Katello/katello.git/commit/97dfcfce47a68a2df415726f556cb2cd6585cb13))
 * checksum-type does not updated on already synced repository at Satellite Capsule. ([#27394](https://projects.theforeman.org/issues/27394), [eabe6d86](https://github.com/Katello/katello.git/commit/eabe6d8688d43f52a74f5eca02ea3d7de5617ca9))
 * Duplicate content views with same filter criteria in a CCV doesn't show full packages count ([#27241](https://projects.theforeman.org/issues/27241), [6a1f7b04](https://github.com/Katello/katello.git/commit/6a1f7b04f7960a3795910928f7b0ba25ab760c14))
 * Publishing a content view with a yum repo produces no metadata ([#26947](https://projects.theforeman.org/issues/26947), [f1c05c99](https://github.com/Katello/katello.git/commit/f1c05c99065f9e44d0a47800a367d6ab435d15d6))
 * Content View publish copying wrong errata ([#26720](https://projects.theforeman.org/issues/26720), [fc8c3f96](https://github.com/Katello/katello.git/commit/fc8c3f9682f58e0855f35bbf429ebde84a4d525b))

### API doc
 * Content Uploads API expects the content_upload id as an Integer, while it is a String (UUID) ([#27590](https://projects.theforeman.org/issues/27590), [cf1acc58](https://github.com/Katello/katello.git/commit/cf1acc58e4577e3cc577981d0fe39914e9bbb8f0))

### Repositories
 * Pulp2 Sync operations fail with http proxy ([#27518](https://projects.theforeman.org/issues/27518), [a0207cd9](https://github.com/Katello/katello.git/commit/a0207cd99f12813e0b10e07d637a8e834fcb6def))
 * pulp_deb 1.10.0 (included in Pulp 2.20.0) will need a rake task during upgrade ([#27479](https://projects.theforeman.org/issues/27479), [242a20df](https://github.com/Katello/katello.git/commit/242a20df24289c00fe24f82b72106e2267e0d20a))
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

### Web UI
 * enabled repository does not show under 'Enabled Repository'  view without refresh the page ([#27426](https://projects.theforeman.org/issues/27426), [cb1db059](https://github.com/Katello/katello.git/commit/cb1db0592cfcc60c04f4993534842e0c3f29e144))
 *  global "__" translation function is still in use in react code ([#27392](https://projects.theforeman.org/issues/27392), [d67e4ab1](https://github.com/Katello/katello.git/commit/d67e4ab18d0a95454d145295ae3d54c53605a46f))
 * Pulp3 - Make progress presenter extensible for all content types ([#27370](https://projects.theforeman.org/issues/27370), [6c7846b2](https://github.com/Katello/katello.git/commit/6c7846b211d74bd62fe9ddd76b5ecde7fc59a3f8))
 * Upgrade katello to use the new @theforeman/vendor npm package ([#27368](https://projects.theforeman.org/issues/27368), [a08a2138](https://github.com/Katello/katello.git/commit/a08a213810f619f55bc9221de62c6b95692c3937))
 * UI sends malformed API request upon enabling *first* redhat repo ([#27198](https://projects.theforeman.org/issues/27198))
 * Red hat repositories page, right hand pane throws an error ([#27152](https://projects.theforeman.org/issues/27152), [86086718](https://github.com/Katello/katello.git/commit/8608671811078333daf13b4f557429075266f1a6))
 * remove react-router package ([#26752](https://projects.theforeman.org/issues/26752), [157f3522](https://github.com/Katello/katello.git/commit/157f3522dfd1d0612717384f9cbc7fa91a7a2523), [133397d4](https://github.com/Katello/katello.git/commit/133397d4b2cf2defc771427a537ca44d5c2a8100))
 * move system statuses from deface to react ([#26434](https://projects.theforeman.org/issues/26434), [0c44a2fa](https://github.com/Katello/katello.git/commit/0c44a2fa68e8fca1a1e6b86582512b603809d6d6))

### Tests
 * pulp_docker_client release has broken katello tests ([#27423](https://projects.theforeman.org/issues/27423), [85722082](https://github.com/Katello/katello.git/commit/857220820e6d4a814b61ca219aae24d8f2d650e6), [841bf0bf](https://github.com/Katello/katello.git/commit/841bf0bfbfd49f61cad2785edd989d83b050e48a))
 * katello tests on foreman prs fail with ERROR:  relation "http_proxies" does not exist ([#27286](https://projects.theforeman.org/issues/27286), [44e25d5c](https://github.com/Katello/katello.git/commit/44e25d5ca2f56c0279c5c75487d976d165380ed9))
 * eslint errors in katello ([#27116](https://projects.theforeman.org/issues/27116), [01549bc6](https://github.com/Katello/katello.git/commit/01549bc6cd7c925c88ff4744226c746effc640d0))
 * master tests fail with invalid value for "proxy_url", the character length must be great than or equ ([#26866](https://projects.theforeman.org/issues/26866), [4acd90a4](https://github.com/Katello/katello.git/commit/4acd90a4963c7217e5b66bd1ba653f80d901ce3d))
 * Seed tests failure because of bcrypt ([#26682](https://projects.theforeman.org/issues/26682), [bc75baba](https://github.com/Katello/katello.git/commit/bc75babad8f278e1063ea380387e17c8faa62f42))

### foreman-debug
 * Foreman-debug katello_repositories SQL query no longer works ([#27401](https://projects.theforeman.org/issues/27401))

### Installer
 * remove pulp2 http proxy configuration in installer ([#27399](https://projects.theforeman.org/issues/27399))
 * seed global http proxy based on configuration ([#27223](https://projects.theforeman.org/issues/27223), [9a926671](https://github.com/Katello/katello.git/commit/9a926671f29f351939d34005a65cda8b9d911f00))

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

### Tooling
 * migrate to new pulp3 friendly method bindings ([#27204](https://projects.theforeman.org/issues/27204), [d38d1c22](https://github.com/Katello/katello.git/commit/d38d1c2200f47d6eb10c68407c8fbb51b96619f0), [414a7471](https://github.com/Katello/katello.git/commit/414a7471b0310e0d7a9a57b9b19eb06c97eec718))
 * katello-remove failed to remove '/var/cache/pulp' because it is a mounted directory ([#27186](https://projects.theforeman.org/issues/27186))
 * pin pulp gems to keep gem changes from breaking tests ([#27089](https://projects.theforeman.org/issues/27089), [e5867dbc](https://github.com/Katello/katello.git/commit/e5867dbc51991abe9fea9ef8e2c4c3f2972b4df5))
 * Gem build: ["LICENSE.txt", "package.json"] are not files ([#27011](https://projects.theforeman.org/issues/27011), [a52a4c3b](https://github.com/Katello/katello.git/commit/a52a4c3b8c355c71f848e4ba2ba7e47c428322c0))
 * remve pulp_file_client gem pinning  ([#27010](https://projects.theforeman.org/issues/27010), [f4a7b6bb](https://github.com/Katello/katello.git/commit/f4a7b6bb1347e05a648374a06ae41c29338d9518))
 * make katello talk ssl to pulp3 ([#27006](https://projects.theforeman.org/issues/27006), [aac2daa0](https://github.com/Katello/katello.git/commit/aac2daa021ec09673779bcdf65c1cc6db59f72ea))
 * update axium dependency to 0.19 ([#26956](https://projects.theforeman.org/issues/26956), [b2744f1f](https://github.com/Katello/katello.git/commit/b2744f1fc69b3ea4a5bdadaad2610b7947911871))
 * Cannot install errata via katello host tools when using libdnf ([#26920](https://projects.theforeman.org/issues/26920), [05c9eebc](https://github.com/Katello/katello-host-tools.git/commit/05c9eebc0aeb43687a1900fead1649ce7c53189d))

### Foreman Proxy Content
 * Allow rake task delete_orphaned_content to accept smart proxy as argument ([#27169](https://projects.theforeman.org/issues/27169), [d9c02454](https://github.com/Katello/katello.git/commit/d9c024543c7314f8215061b905a6ed5752470075))
 * Every capsule sync causes importers/distributors to get updated making an optimized capsule sync a full sync ([#26907](https://projects.theforeman.org/issues/26907), [a096d80d](https://github.com/Katello/katello.git/commit/a096d80d10364300497dac3a08a6855d22f62e91))

### Errata Management
 * Host actions such as package or pkg group installation doesn't show humanized output ([#27108](https://projects.theforeman.org/issues/27108), [9a82bb9e](https://github.com/Katello/katello.git/commit/9a82bb9ee1b89af8b7faef9289c809916dcd8f5f))

### Orchestration
 * ping failing -  if pulp3  is not enabled ([#27080](https://projects.theforeman.org/issues/27080), [0244f87c](https://github.com/Katello/katello.git/commit/0244f87c41883e29c5488fe4318c2130aa50873a), [7a678632](https://github.com/Katello/katello.git/commit/7a6786325ce24629307669d078dbc393cd51fc50))

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
 * Docker Content View publishing fails with duplicate key value error ([#27524](https://projects.theforeman.org/issues/27524), [5d0a6d55](https://github.com/Katello/katello.git/commit/5d0a6d55184f4349e727dfc830cae735738f7517))
 * Ansible 2.8 needs to be the default recommended repository ([#27327](https://projects.theforeman.org/issues/27327), [0f9006f2](https://github.com/Katello/katello.git/commit/0f9006f21d79ef892d1e0d96438494d4951b7536))
 * Rubocop 0.71.0 updates ([#27267](https://projects.theforeman.org/issues/27267), [7b974241](https://github.com/Katello/katello.git/commit/7b974241c4d1965275fa08905affba63b429170b))
 * Bulk errata install via REX applies to more hosts than selected ([#27258](https://projects.theforeman.org/issues/27258), [0ec25db7](https://github.com/Katello/katello.git/commit/0ec25db78db6a9b9b9024219d4da26d2a21f9938))
 * Docker Manifest 'downloaded' not used ([#27250](https://projects.theforeman.org/issues/27250), [f1a1eb39](https://github.com/Katello/katello.git/commit/f1a1eb3974650c89b02c600939e40cf33d3657de))
 * Recommended Repositories  needs rhel8 channels ([#27040](https://projects.theforeman.org/issues/27040), [ea3d7cb7](https://github.com/Katello/katello.git/commit/ea3d7cb751b22d0abe0d8d3175fefcc4a4484fcd))
 * Fix bad pulp3 tests ([#27023](https://projects.theforeman.org/issues/27023), [88f6e438](https://github.com/Katello/katello.git/commit/88f6e438b624b9c0b34e4e84a4f6f9132a6bb529))
 * sync management page and tests fail with undefined local variable or method `per_page_options' for  ([#26973](https://projects.theforeman.org/issues/26973), [62fafdad](https://github.com/Katello/katello.git/commit/62fafdad194b948058841baa80c41b2ffdfb8f63))
 * Don't run AutoAttach on every host update ([#26810](https://projects.theforeman.org/issues/26810), [9b6f9987](https://github.com/Katello/katello.git/commit/9b6f9987d2088eea7da1197490079586ccae2847))
 * Fix tests for foreman default locale and default timezone ([#26743](https://projects.theforeman.org/issues/26743), [3ee4d5a0](https://github.com/Katello/katello.git/commit/3ee4d5a0ed5beee2f4395e0f80bf6c58c6210970))
 * Regeneration of ueber certificate is causing optimized capsule sync to perform force full sync every time ([#26721](https://projects.theforeman.org/issues/26721), [c0e13bdf](https://github.com/Katello/katello.git/commit/c0e13bdf0fad9b4361ced9a47196cab31491b810))
 * Pulp3 - Honor contents_changed ([#26686](https://projects.theforeman.org/issues/26686), [fc655526](https://github.com/Katello/katello.git/commit/fc6555260515cae665865abd353ecefd1054c4c1))
