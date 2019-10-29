# 3.14.0 Pecan Pie (2019-10-29)

## Features

### Hosts
 * Make installed packages available in safe mode ([#28082](https://projects.theforeman.org/issues/28082), [c98fdc14](https://github.com/Katello/katello.git/commit/c98fdc1444d1ec43e247dcf7c50e2ed870cb4bbd))

### API doc
 * Ping endpoints apidoc should be explicit ([#28076](https://projects.theforeman.org/issues/28076), [b5987ba1](https://github.com/Katello/katello.git/commit/b5987ba1d7932e088409090532375b35a5a484fb))

### Subscriptions
 * Generate the complete report about Entitlement Information (hypervisors versus Content Hosts) ([#27923](https://projects.theforeman.org/issues/27923), [63ce30ba](https://github.com/Katello/katello.git/commit/63ce30ba47c954b3d70371ec64fb11a8278397da))

### Repositories
 * Update a yum repository with pulp3 ([#27918](https://projects.theforeman.org/issues/27918))
 * As part of orphan cleanup delete orphan repository versions in mirrors ([#27890](https://projects.theforeman.org/issues/27890), [aacb044c](https://github.com/Katello/katello.git/commit/aacb044c9d72fc0d62cde838bc092a2a79515891))
 * Support API/UI for listing  ansible collection content within a repository  ([#27212](https://projects.theforeman.org/issues/27212))
 * Support API/UI for ansible collection content across an organization ([#27202](https://projects.theforeman.org/issues/27202), [6b25d083](https://github.com/Katello/katello.git/commit/6b25d0830abb4653f19915ed0e9511b363cd959a))
 * support syncing docker repositories in pulp3 ([#26999](https://projects.theforeman.org/issues/26999), [c1e3f511](https://github.com/Katello/katello.git/commit/c1e3f5111318ad505bed235906c263b6dc2f3749))
 * support deleting docker repositories in pulp3 ([#26998](https://projects.theforeman.org/issues/26998))
 * support updating docker repos in pulp3 ([#26997](https://projects.theforeman.org/issues/26997))
 * Support deleting ansible collection repositories  ([#26993](https://projects.theforeman.org/issues/26993))
 * Support updating ansible collection repositories ([#26992](https://projects.theforeman.org/issues/26992))

### Host Collections
 * Add host collections to safe mode ([#27893](https://projects.theforeman.org/issues/27893), [32e7c74e](https://github.com/Katello/katello.git/commit/32e7c74eba444e9c20048b0e587b1aca2d19cf3e))

### Web UI
 * [RFE] Use the word 'Delete' instead of 'Remove' when deleting a content host in WebUI ([#27872](https://projects.theforeman.org/issues/27872), [5e281ff8](https://github.com/Katello/katello.git/commit/5e281ff899da7d65e562ef08d72cccad93f0621e))
 * Check a user's permission before allowing them to access react pages  ([#27450](https://projects.theforeman.org/issues/27450), [97de7bdb](https://github.com/Katello/katello.git/commit/97de7bdbe7c45de3aae8e7f4115d6320061285d4))

### Tooling
 * Drop katello-remove from Katello ([#27780](https://projects.theforeman.org/issues/27780))

### Ansible Collections
 * [pulp3-ansible] Allow users to specify which collections to sync in requirements.yaml syntax ([#27639](https://projects.theforeman.org/issues/27639), [b7e4ba3e](https://github.com/Katello/katello.git/commit/b7e4ba3eca0cfbaccf4906a6c30034346b723827))

### Inter Server Sync
 * [RFE] Add ability to export content view like the CDN ([#27374](https://projects.theforeman.org/issues/27374), [03542576](https://github.com/Katello/hammer-cli-katello.git/commit/035425762591d22cddd649e11835e3147ca7ddf5))

### Errata Management
 * Content -> Errata should only show repositories that actually contain Errata ([#26975](https://projects.theforeman.org/issues/26975), [6860f9c3](https://github.com/Katello/katello.git/commit/6860f9c3314794b85f1769a83e2501afd91d1cbe))

## Bug Fixes

### Content Uploads
 * Pulp3 - Update pulp3 uploads workflow ([#28094](https://projects.theforeman.org/issues/28094), [9ccb8842](https://github.com/Katello/katello.git/commit/9ccb8842f5f9bec0f6c2d5cb3ce83b2481614a30))
 * Pulp3 - pin gems and fix uploads ([#27886](https://projects.theforeman.org/issues/27886), [4e7c9aef](https://github.com/Katello/katello.git/commit/4e7c9aef4132026d3800dbd9afc566d35a062afa))
 * [pulp3] Support uploading content into pulp3 repos ([#27717](https://projects.theforeman.org/issues/27717), [9276ae51](https://github.com/Katello/hammer-cli-katello.git/commit/9276ae51f22b46ad405ac0783762ca833e9e8d6e))

### Content Views
 * Content view -> History -> Action column is broken when foreman tasks are deleted ([#28085](https://projects.theforeman.org/issues/28085), [03282315](https://github.com/Katello/katello.git/commit/03282315d9604b3ed5221f852e67b1c055da45b4))
 * Content View publish with dep solve and no filters adds recursive flag ([#28039](https://projects.theforeman.org/issues/28039), [6efbd974](https://github.com/Katello/katello.git/commit/6efbd9745e07f5873e51a1079fbc7cc058c318c3))
 * Content View Package Filter Rule architecture will not include all arches after updating ([#27885](https://projects.theforeman.org/issues/27885), [f7f4fedf](https://github.com/Katello/katello.git/commit/f7f4fedff31a1b00c9d0a9191ca4d7c0ee1f80a0))
 * cannot publish a content view in location other than default smart proxy's.   "Couldn't find SmartProxy with 'id'=1 [WHERE (1=0)]" ([#27864](https://projects.theforeman.org/issues/27864), [07265e01](https://github.com/Katello/katello.git/commit/07265e019def1b48771b4726d544dd9c01bd7b6b))
 * Content-view version status showing  {{ historyText(version) }} ()  when you check through  Infrastructure --> Smart Proxies --> <Smart Proxy> --> Content --> Library --> Default Organization View ([#27783](https://projects.theforeman.org/issues/27783), [278d4d7a](https://github.com/Katello/katello.git/commit/278d4d7afcf5c984fc34bdd3149e82cd573680d4), [d1793b39](https://github.com/Katello/katello.git/commit/d1793b3953129a0bc3be741c4c6571295a151178))
 * Content-View filtering not working as expected ([#27738](https://projects.theforeman.org/issues/27738), [ed2d2998](https://github.com/Katello/katello.git/commit/ed2d29983a10fbe8726230aa7db42ec1af2187ab))
 * publishing a content view while in an alternative location fails 'Couldn't find SmartProxy with 'id'=1 [WHERE (1=0)]' ([#27530](https://projects.theforeman.org/issues/27530), [ba6414ca](https://github.com/Katello/katello.git/commit/ba6414caa15a372c1744737b0592973ea29067b7))
 * Missing CentOS Environment Groups when client uses Content View ([#27395](https://projects.theforeman.org/issues/27395), [909d69a3](https://github.com/Katello/katello.git/commit/909d69a3a1f7c7c80c0f6c980053ebf9a0ee2d52))

### API
 * deprecate ostree and puppet types ([#28074](https://projects.theforeman.org/issues/28074), [afaed50b](https://github.com/Katello/katello.git/commit/afaed50b6d4c287712405ecc79c8788cbc02caca))

### Tests
 * Update bastion katello test instructions in README ([#28038](https://projects.theforeman.org/issues/28038), [887e323e](https://github.com/Katello/katello.git/commit/887e323e3421824b5ab25347f02ac386848808d2))
 * Runcible 2.12.0 causing VCR test failures ([#27744](https://projects.theforeman.org/issues/27744), [dc8751ce](https://github.com/Katello/katello.git/commit/dc8751cebfda0df5e2f94f3c1800e4fdfca74dd7))
 * Change katello test to be compatible with audited gem 4.9.0 ([#27725](https://projects.theforeman.org/issues/27725), [c8af90d8](https://github.com/Katello/katello.git/commit/c8af90d8865d437544b63a0c34c9b9228645521e))
 * Investigate failed unit tests with ActiveRecord::StatementInvalid: PG::InFailedSqlTransaction: ERROR:  current transaction is aborted, commands ignored until end of transaction block... ([#27636](https://projects.theforeman.org/issues/27636), [d7317a34](https://github.com/Katello/katello.git/commit/d7317a3469aef1ee32b47914d37db1c0b17d4ee3))
 * Actions::Pulp3::CopyAllUnitsTest assert_equal nil, nil fails in Foreman PRs ([#27503](https://projects.theforeman.org/issues/27503), [0f02353e](https://github.com/Katello/katello.git/commit/0f02353e30d71b646dc464410ab53b1bd916b194))

### Repositories
 * Pulp 3 attribute names have changed ([#28026](https://projects.theforeman.org/issues/28026), [bd5fd3db](https://github.com/Katello/katello.git/commit/bd5fd3db85ebda228fc5d5934a6ae08586cd9f58))
 * deprecate background download type ([#28021](https://projects.theforeman.org/issues/28021), [e8979cea](https://github.com/Katello/katello.git/commit/e8979cea62a27706b93ed9c66d43f0cbbcc83602))
 * pulp3 cancel tasks no longer works ([#27911](https://projects.theforeman.org/issues/27911), [9c676914](https://github.com/Katello/katello.git/commit/9c6769140a258de88ea8f0e5af41ce6a65fd0f20))
 * when disabling Red Hat repository: Module::DelegationError: Katello::Repository#content_id delegated to root.content_id, but root is nil ([#27823](https://projects.theforeman.org/issues/27823), [f552ba20](https://github.com/Katello/katello.git/commit/f552ba20050bd858b9a5e4a74cf4c1f312e21394))
 * pulp selector isn't properly considering if a smart proxy supports a content type ([#27737](https://projects.theforeman.org/issues/27737), [7ced44b2](https://github.com/Katello/katello.git/commit/7ced44b2b9d946fbe5d1fb7daa128fb19d831fee))
 * Repository Autocomplete throws an error ([#27695](https://projects.theforeman.org/issues/27695), [f5f92bc3](https://github.com/Katello/katello.git/commit/f5f92bc36f844f2e534ea21c8daa27c8c9a3c799))
 * Add mirroring to pulp3 capsule sync ([#27606](https://projects.theforeman.org/issues/27606), [6170c084](https://github.com/Katello/katello.git/commit/6170c0849e92bc5d63fe537f55d06eefaea532fb))
 * /katello/api/srpms does not gives error on undefined parameter ([#27542](https://projects.theforeman.org/issues/27542))
 * errors": ["undefined method `srpms' for #<Katello::ContentViewVersion:0x000000000d500c28>" ([#27541](https://projects.theforeman.org/issues/27541), [e5290128](https://github.com/Katello/katello.git/commit/e529012872d54ddf9e31ba4f2d524a237b19b048))
 * Pulp3- Pass mirror option set to true by default for repository syncs. ([#27373](https://projects.theforeman.org/issues/27373), [c5fc75b1](https://github.com/Katello/katello.git/commit/c5fc75b1a122ab14ca254f51fde85caba73fa7e0))
 * [Audit] Repository creation under product creates audit record with empty content ([#26675](https://projects.theforeman.org/issues/26675), [1265e895](https://github.com/Katello/katello.git/commit/1265e895f7461aaa30ee44c2da8d240c17392ff3))

### Hosts
 * Allow safemode render for the Content Host Description ([#28019](https://projects.theforeman.org/issues/28019), [b9c38bf5](https://github.com/Katello/katello.git/commit/b9c38bf5d9c8bc4a5444760723132c49daf0b541))
 * Enable safe mode access for content host facets for reporting ([#27892](https://projects.theforeman.org/issues/27892), [8e6830c0](https://github.com/Katello/katello.git/commit/8e6830c0c4c0382131eb4efcc012c50195e60f96))
 * Hide Registered Through for Hypervisor profiles on the Content Hosts page ([#27878](https://projects.theforeman.org/issues/27878), [5de1238f](https://github.com/Katello/katello.git/commit/5de1238fc6b2dcf316d489de6ae3e0245fc240fb))
 * Drop cp_events table (Part 2/Katello only) ([#27870](https://projects.theforeman.org/issues/27870), [c5116b3e](https://github.com/Katello/katello.git/commit/c5116b3e40fc6dcfd569cb0bd81207f8dbaf7195))
 * error seen PG::Error: ERROR:  duplicate key value violates unique constraint "katello_host_installed_packages_h_id_ip_id" DETAIL:  Key (host_id, installed_package_id)=(123, 456) already exists. ([#27824](https://projects.theforeman.org/issues/27824), [fd3132a4](https://github.com/Katello/katello.git/commit/fd3132a431dd35614a8b6de9993a0083840c6a96))
 * There are missing instructions to enable satellite-tools repository ([#27667](https://projects.theforeman.org/issues/27667), [00da767b](https://github.com/Katello/katello.git/commit/00da767bc8c1d3303065f354b9d414f974a62008))
 * operatingsystem should create release-name without spaces ([#27516](https://projects.theforeman.org/issues/27516), [900ace3b](https://github.com/Katello/katello.git/commit/900ace3b922e60a99ef6d92213266fc33fce6287))
 * Rename column Status to Default Status on bulk content host > manage repository sets modal ([#27467](https://projects.theforeman.org/issues/27467), [be326130](https://github.com/Katello/katello.git/commit/be326130e91fcf461b8930073c21ebdb7962b929))
 * Missing(ID: N) for Host_ids column in case of audit records for subscription updates ([#27383](https://projects.theforeman.org/issues/27383), [db694344](https://github.com/Katello/katello.git/commit/db694344cf8cada514ae0c35f1ddf0fa5c221043))
 * Content Hosts OS no populated with centos 7 ([#26914](https://projects.theforeman.org/issues/26914), [4b46ebd3](https://github.com/Katello/katello.git/commit/4b46ebd3dbccc661a3900dca68b82330a6802b83))

### Hammer
 * Hammer-cli-katello - Update hammer to allow duplicate file uploads ([#27947](https://projects.theforeman.org/issues/27947), [0d0f877e](https://github.com/Katello/hammer-cli-katello.git/commit/0d0f877eca655b17397157a0d0e369b8a1e86e20))
 * [Modularity Filters] - Add a way to create modularity filter rule using hammer cli  ([#27712](https://projects.theforeman.org/issues/27712), [846067f4](https://github.com/Katello/hammer-cli-katello.git/commit/846067f4f9456737205ee1d2f9c6df680466186c))
 * Cannot override activation key repository-sets status using hammer ([#27221](https://projects.theforeman.org/issues/27221), [fcd47679](https://github.com/Katello/katello.git/commit/fcd4767997390dba150fcff69ac769e66325a482))

### Docker
 * Latest container CV version has double tags ([#27882](https://projects.theforeman.org/issues/27882), [b670205a](https://github.com/Katello/katello.git/commit/b670205aae22906bc85964347238b1d764e756e3))
 * Repository Autocomplete broken for Container Image Tags ([#27862](https://projects.theforeman.org/issues/27862), [f5f92bc3](https://github.com/Katello/katello.git/commit/f5f92bc36f844f2e534ea21c8daa27c8c9a3c799))
 * adapt to new pulp3 docker tag/manifest model names ([#27610](https://projects.theforeman.org/issues/27610), [2c28faa3](https://github.com/Katello/katello.git/commit/2c28faa35b728c92b9c72d85f608b78abe1f847b))

### Host Collections
 * Content View missing from Host Collections Add Table ([#27875](https://projects.theforeman.org/issues/27875), [2e7625a7](https://github.com/Katello/katello.git/commit/2e7625a75c01bb9578457f74b7a90b906c14f362))

### Foreman Proxy Content
 * orphan cleanup fails with undefined local variable or method `repos_available_to_capsule'  ([#27839](https://projects.theforeman.org/issues/27839), [526ed008](https://github.com/Katello/katello.git/commit/526ed0087d087774d8b07fffb644649c9cc1d495))
 * Capsule-sync failing on Katello::Errors::PulpError: PLP0034 when you have puppet repo enaled and sync ([#27825](https://projects.theforeman.org/issues/27825), [1814cd3c](https://github.com/Katello/katello.git/commit/1814cd3c5a92cd0fa07682ff2dbecf3acc5db74d))
 * orphan cleanup on capsule doesn't delete uneeded repos ([#27795](https://projects.theforeman.org/issues/27795), [0771fe41](https://github.com/Katello/katello.git/commit/0771fe41e843bdff65b48e828a7555dd28af6e77))
 * capsule sync fails if pulp3 is not installed ([#27616](https://projects.theforeman.org/issues/27616), [181a38c3](https://github.com/Katello/katello.git/commit/181a38c327de35dff2ffc4f61018a8ce899ca0c7))
 * Capsule not in the current location won't get sync after publishing a CV successfully. ([#27529](https://projects.theforeman.org/issues/27529), [16af1a01](https://github.com/Katello/katello.git/commit/16af1a013a7c46be56b1df93c58a12622819eed6))

### Inter Server Sync
 * Unable to export "Default Organization View 1.0" Content View ([#27838](https://projects.theforeman.org/issues/27838), [9bf7858a](https://github.com/Katello/hammer-cli-katello.git/commit/9bf7858adcf30410ae81ab9d430fd727eeb881bd))

### Web UI
 * Recommended repositories page on Satellite 6.6 is listing Capsule/Tools repos for 6.5 version ([#27777](https://projects.theforeman.org/issues/27777), [52bf8f6b](https://github.com/Katello/katello.git/commit/52bf8f6bf6340b5c4c6c206f6b105d48dc6744e7))
 * Remote Execution not being used despite being set as default ([#27714](https://projects.theforeman.org/issues/27714), [27ac8a27](https://github.com/Katello/katello.git/commit/27ac8a27bca36ddfacdd4c02677bec5e2280e3f0))
 * Update the vendor to version ^1.4.0 ([#27699](https://projects.theforeman.org/issues/27699), [e3e88ff0](https://github.com/Katello/katello.git/commit/e3e88ff09506bc577c8c7da8fd8e156a51ae3ff0))
 * content hosts bulk errata pages should not use 'applicable_hosts' ([#27679](https://projects.theforeman.org/issues/27679), [073d74b7](https://github.com/Katello/katello.git/commit/073d74b71fd2afa1234c607c9285890fa9eb4536))
 * Inconsistent font in content view filter rules list tab ([#27561](https://projects.theforeman.org/issues/27561), [dd5cc895](https://github.com/Katello/katello.git/commit/dd5cc89507529ccfb2a5e9c845aa34393516e7d2))
 * Styling for new repository type options are not consistent with other form elements ([#27449](https://projects.theforeman.org/issues/27449), [6cb2412e](https://github.com/Katello/katello.git/commit/6cb2412e6edc547da0ac103e6e404958fc0074d0))
 * Search bar assuming dropdown causes issues when typing in partial names ([#26792](https://projects.theforeman.org/issues/26792), [8afb72d2](https://github.com/Katello/katello.git/commit/8afb72d29456d8477e4d1a1079a483490dc3fe4e))

### Tooling
 * Add the ability to prefer pulp2 for some type of content ([#27773](https://projects.theforeman.org/issues/27773), [340868d4](https://github.com/Katello/katello.git/commit/340868d4de24929897611d536b4a86c5b79fe4ef))
 * Pin pulp3 gems to latest versions ([#27771](https://projects.theforeman.org/issues/27771), [a3d47584](https://github.com/Katello/katello.git/commit/a3d4758423dcd06b1131715d2dff1a39ec0a151f))
 * pin pulp3 gems to latest versions ([#27688](https://projects.theforeman.org/issues/27688), [81e259c5](https://github.com/Katello/katello.git/commit/81e259c5f333389cd30ad2943ebcf0ceebf74357))
 * migrate LOCE and Event Queue off of dynflow ([#27674](https://projects.theforeman.org/issues/27674), [771388f2](https://github.com/Katello/katello.git/commit/771388f2ee5bda582fef62701ee08ef1c4d4db12), [f4fe99a1](https://github.com/Katello/katello.git/commit/f4fe99a1c4815a7fd19478c6bf9fae4fc602cddf))
 * Remove ssl config from pulp3 configuration ([#27498](https://projects.theforeman.org/issues/27498), [09347053](https://github.com/Katello/katello.git/commit/09347053d957f1e89b48000781efcfe6599e697c))

### Activation Key
 * Activation Key Repository Sets tab sends invalid params ([#27669](https://projects.theforeman.org/issues/27669), [6d81b9ae](https://github.com/Katello/katello.git/commit/6d81b9ae4d3cd625d44cc53080698e5b77c566b3))

### Subscriptions
 * importing a manifest creates products with only alphanumeric chars in name ([#27661](https://projects.theforeman.org/issues/27661), [d447e2e9](https://github.com/Katello/katello.git/commit/d447e2e9f6ab794001ec8e8633166dc1e6f505f6))
 * Remove checkmark column from add subscriptions page ([#27658](https://projects.theforeman.org/issues/27658), [67e947db](https://github.com/Katello/katello.git/commit/67e947dbbd86fc9d9ee6a59150323632dd54b96b))
 * redhat manifest issues ([#27605](https://projects.theforeman.org/issues/27605), [91c3240d](https://github.com/Katello/katello.git/commit/91c3240d11d18061e07f34e2b39fc2b00efe177b))

### Ansible Collections
 * Pin ansible binding gem to 0.2.0b2.dev01565187947 ([#27581](https://projects.theforeman.org/issues/27581), [64815f33](https://github.com/Katello/katello.git/commit/64815f3318a49aa999d2409f4715bb4f90882958))
 * Throw descriptive error when trying to sync roles from Galaxy ([#27579](https://projects.theforeman.org/issues/27579))
 * Handle whitelist deprecation in Ansible Collections ([#27565](https://projects.theforeman.org/issues/27565), [bd04bc6d](https://github.com/Katello/katello.git/commit/bd04bc6d700838c6e86ef0ee8f41b61c1c57da58))

### API doc
 * Subscription index API says the organization_id is required, while it is not ([#27575](https://projects.theforeman.org/issues/27575), [74b03975](https://github.com/Katello/katello.git/commit/74b03975bb12191b324b909eb99fc2f6b704dd60))
 * sync_plan apidoc for add and_ remove_products is missing required organization_id ([#27532](https://projects.theforeman.org/issues/27532), [d35a9b66](https://github.com/Katello/katello.git/commit/d35a9b66608381e1ff1d1aacc03edbb6af137869))

### Errata Management
 * katello-agent errata message should be modified ([#26155](https://projects.theforeman.org/issues/26155), [716e1169](https://github.com/Katello/katello.git/commit/716e11695290fa45b1ee6f7a2f4b82c3d188459d))

### Dashboard
 * Stop using /owners/<owner>/info for sub compliance dashboard widget  ([#19505](https://projects.theforeman.org/issues/19505), [68fa87b7](https://github.com/Katello/katello.git/commit/68fa87b7746a357bf919456faba8ab79c64daba9))

### Other
 * Pin docker gem <= 4.0.0b6.dev01565529670 ([#27609](https://projects.theforeman.org/issues/27609), [3cf32301](https://github.com/Katello/katello.git/commit/3cf32301e13c0f5a74dd829b4dcefed8e93bee5d))
 * Pin ansible-gem <= 0.2.0b2.dev01565187947 ([#27594](https://projects.theforeman.org/issues/27594), [b941f99a](https://github.com/Katello/katello.git/commit/b941f99a516548fe57bc22d0b9bc71d6a849472d))
