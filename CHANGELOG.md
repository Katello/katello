# 4.5 Old Monk (2022-05-12)

## Features

### Hosts
 * New host detail - Change content source ([#34865](https://projects.theforeman.org/issues/34865), [0dd6dadd](https://github.com/Katello/katello.git/commit/0dd6dadd3fe8913e29a7b6f3d1b105101f9fa098))
 * new host detail page - 'Installed products' card ([#34816](https://projects.theforeman.org/issues/34816), [a26097ce](https://github.com/Katello/katello.git/commit/a26097ce0a1502e17c782063f5fba8c4837ee5a9))
 * new host details - Add happy empty states ([#34805](https://projects.theforeman.org/issues/34805), [08694c96](https://github.com/Katello/katello.git/commit/08694c96b227473ab4ecb942a2368357e86705bf))
 * Hosts UI - Module streams - Add module stream actions ([#34784](https://projects.theforeman.org/issues/34784), [ffda83fe](https://github.com/Katello/katello.git/commit/ffda83fef64e878b4d0f8c5d6748278f0fc3a1dc))
 * New host details - Host collections Add & Remove modals ([#34548](https://projects.theforeman.org/issues/34548), [fa97fa63](https://github.com/Katello/katello.git/commit/fa97fa6337eaa8895aecca3a1adf34dbbf5c7551))

### Repositories
 * Extend info box in release field of Deb repository create page in Katello GUI ([#34795](https://projects.theforeman.org/issues/34795), [7b1bd0e3](https://github.com/Katello/katello.git/commit/7b1bd0e30815355bb8439364d854511e2f56aaef))
 * Report that lists all the hosts on which a particular repository is enabled ([#34711](https://projects.theforeman.org/issues/34711), [d6d9b712](https://github.com/Katello/katello.git/commit/d6d9b712f3cdae45823431a0b786b975bbbcdced))
 * As a user, I can CRUD custom ACSs via the API ([#34034](https://projects.theforeman.org/issues/34034), [71f9e497](https://github.com/Katello/katello.git/commit/71f9e497bc63aeb53902718dc842e8e7cf39862b))

### Web UI
 * Set up lab routes for ACS UI and land on read-only index page for ACS ([#34783](https://projects.theforeman.org/issues/34783), [2a10b1eb](https://github.com/Katello/katello.git/commit/2a10b1eb15f0dab79630aeba832b67b8ef043767))
 * Hosts UI - Module streams - Filter by state & installation status ([#34663](https://projects.theforeman.org/issues/34663), [91dd495a](https://github.com/Katello/katello.git/commit/91dd495a2b04d8c54411b2be7ef9967b1cbb467e))
 * Add table sorting by column ([#34461](https://projects.theforeman.org/issues/34461), [f609171f](https://github.com/Katello/katello.git/commit/f609171fd2bdc2372a88af85087efc3b018e1ea0))

### Subscriptions
 * - add ouia-ID prop to all fields in CDN configuration ([#34754](https://projects.theforeman.org/issues/34754), [b18916be](https://github.com/Katello/katello.git/commit/b18916be101b65b3326580561ce4d6cf3540c76d), [dc4790d3](https://github.com/Katello/katello.git/commit/dc4790d3cf4960d27544d5eca3ad65bbe83436d3))
 * - add ouia-ID prop to update buttons in CDN configuration ([#34753](https://projects.theforeman.org/issues/34753), [418b6a9c](https://github.com/Katello/katello.git/commit/418b6a9c895215397a6557c50f939b1652be7f6f))

### Content Views
 * RFE - add ouia-ID for buttons on a cv ([#34749](https://projects.theforeman.org/issues/34749), [07d59d07](https://github.com/Katello/katello.git/commit/07d59d076fead2f98b6ec96475ed33986345a0fd), [f67131e5](https://github.com/Katello/katello.git/commit/f67131e5bf3a5b52d90247da1b812201607295cc))
 * Report template support: list enabled repositories and RPM counts for content hosts ([#34695](https://projects.theforeman.org/issues/34695), [688869a5](https://github.com/Katello/katello.git/commit/688869a59f30523b486798039cfcb350ee2aa441))
 * Content view filter should suggest architectures parameters in RPM rule ([#34586](https://projects.theforeman.org/issues/34586), [96125025](https://github.com/Katello/katello.git/commit/961250253da90741e2db976676a39fb82e042837))
 * Publish new version should redirect to "Version" tab ([#34496](https://projects.theforeman.org/issues/34496), [e4c3cc06](https://github.com/Katello/katello.git/commit/e4c3cc063cf13ed691a2776ca38713fe8207bc32))
 * Allow bulk selections on CV UI to support bulk removing versions ([#34169](https://projects.theforeman.org/issues/34169), [197688c0](https://github.com/Katello/katello.git/commit/197688c0c7a95cc8cdc382bb9881e767bd147eef))

### Foreman Proxy Content
 * SmartProxy Content download-policy Streamed ([#34582](https://projects.theforeman.org/issues/34582), [78884edb](https://github.com/Katello/katello.git/commit/78884edb4fdb0912fd27d23796409553e8592a5c))

### Other
 * new host details - Add Subscription UUID to System Properties card ([#34814](https://projects.theforeman.org/issues/34814), [0839a913](https://github.com/Katello/katello.git/commit/0839a91389dfe015d727821d2978ee5880dbd66a))
 * Properly translate plurals ([#34628](https://projects.theforeman.org/issues/34628), [87ad581a](https://github.com/Katello/katello.git/commit/87ad581ad025cae794642956fda635776c5b1a22))
 * [RFE] add option to export and import just repository for hammer content-export  ([#34374](https://projects.theforeman.org/issues/34374), [dd112712](https://github.com/Katello/hammer-cli-katello.git/commit/dd11271239cddc5f78255b1f6f6f726cba736665), [4c1e7211](https://github.com/Katello/katello.git/commit/4c1e72119659be50dd60682b1ef10e13c3ab682a))

## Bug Fixes

### Tooling
 * Rails 6.1 upgrade raising errors on server startup ([#34862](https://projects.theforeman.org/issues/34862), [7fa2de58](https://github.com/Katello/katello.git/commit/7fa2de58861c68c446033a5828dbe0e756ec46aa))
 * Pin pulp_rpm_client to <3.17.5 ([#34770](https://projects.theforeman.org/issues/34770), [5125b763](https://github.com/Katello/katello.git/commit/5125b763841ac5baf929e959affe810c8c43bff5))
 *  Update Pulpcore to 3.17 ([#34697](https://projects.theforeman.org/issues/34697), [ad46cb3e](https://github.com/Katello/katello.git/commit/ad46cb3ee5c57a9b1d3f4b4a5678b875a1a27dde))

### API
 * don't expose "label" param in PUT /organizations/:id API ([#34859](https://projects.theforeman.org/issues/34859), [56e5b386](https://github.com/Katello/katello.git/commit/56e5b3862f12325b32a83efecc2fb70930f13721))

### Web UI
 * [SAT-5692] Details tab - Registration details card ([#34836](https://projects.theforeman.org/issues/34836), [b5eaf76f](https://github.com/Katello/katello.git/commit/b5eaf76f71c20a1f7b1126f08f44a3bdd2da1930))
 * New host detail page - sentence case fixes ([#34797](https://projects.theforeman.org/issues/34797), [b997a2f0](https://github.com/Katello/katello.git/commit/b997a2f01d7f14844f75c0085a00e6f7d1762b55))
 * [SAT-5692] Add Bookmarks to all host detail tables ([#34632](https://projects.theforeman.org/issues/34632), [0daa8c99](https://github.com/Katello/katello.git/commit/0daa8c99b1e67bd26a368faef3f64e2842f79837))
 * [RFE] CV UI -  Errata Filter Date doesn't show "Start Date" & "End Date" ([#34630](https://projects.theforeman.org/issues/34630), [05798608](https://github.com/Katello/katello.git/commit/057986082ebf268478db94dfb35cd0eee3e4070c))
 * CV UI -  Wizard bug fixes ([#34599](https://projects.theforeman.org/issues/34599), [d2497425](https://github.com/Katello/katello.git/commit/d2497425e3a75a7a7df41fb1a547aa565cfd4f10))
 * CV UI - Patternfly update causes tabs to navigate twice on click ([#34559](https://projects.theforeman.org/issues/34559), [acf477e2](https://github.com/Katello/katello.git/commit/acf477e24a52ed85d0b89511475e399b75192898))
 * CV UI - Status value translations should only translate the user facing text, not params etc sent to API. ([#34158](https://projects.theforeman.org/issues/34158), [aa9592ee](https://github.com/Katello/katello.git/commit/aa9592eec9d4ff47506c3d7b316098b14768d9f4))

### Repositories
 * Fix upstream authentication autofill issue for Katello repositories ([#34818](https://projects.theforeman.org/issues/34818), [ea78e268](https://github.com/Katello/katello.git/commit/ea78e2682b6305db0f453b7df624345b3c890b7c))
 * Bring back 0 package counts!  ([#34803](https://projects.theforeman.org/issues/34803), [b82bfb5a](https://github.com/Katello/katello.git/commit/b82bfb5a3970639372cc19d1ae843afef87ee94e))
 * Sync Status page does not show syncing progress bar under "Result" column when syncing a repo ([#34766](https://projects.theforeman.org/issues/34766), [f8172454](https://github.com/Katello/katello.git/commit/f81724544d3cc7a27e03a903ff34d05b8f878846))
 * Add 'republish repository metadata' to Hammer ([#34762](https://projects.theforeman.org/issues/34762), [114b12ad](https://github.com/Katello/hammer-cli-katello.git/commit/114b12ad9094a16da2ff7867c6517d6591c9b496))
 * repositories/import_uploads API endpoint do require two mandatory parameters ([#34729](https://projects.theforeman.org/issues/34729), [2d288ff1](https://github.com/Katello/katello.git/commit/2d288ff1a6ae471119d6810c9abe9ce555f97971))
 * A failed CV promote during publish or repo sync causes ISE ([#34680](https://projects.theforeman.org/issues/34680), [f0c69a1b](https://github.com/Katello/katello.git/commit/f0c69a1bf7799807e2238998f7b54e230aa5fa36))
 * Cannot upload a package to a repository if the same package already exists in another repository, but is not downloaded  ([#34635](https://projects.theforeman.org/issues/34635), [a3a856e8](https://github.com/Katello/katello.git/commit/a3a856e896823dd70510c197070199b013a434b4))
 * Remotes should have username and password cleared out if a user sets them to be blank ([#34619](https://projects.theforeman.org/issues/34619), [17a12869](https://github.com/Katello/katello.git/commit/17a12869397c56d556a38784ac88380713873866))
 * The "Serve via HTTP" and "Verify SSL" options in Repo Discovery page does not functions at all in Satellite 7.0 ([#34617](https://projects.theforeman.org/issues/34617), [8f76e5e9](https://github.com/Katello/katello.git/commit/8f76e5e98e97ff138884e2d0a6db2b7ff6610543))
 * Satellite/capsule 6.10 and tools 6.10 repos are listed in the Recommended Repositories for Sat 7.0 ([#34577](https://projects.theforeman.org/issues/34577), [c0cb3e25](https://github.com/Katello/katello.git/commit/c0cb3e25f3abdd14af5d3e0b9a4739345252b015))
 * Deletion of Custom repo deletes it from all versions of CV where it is included but the behavior is different for Red Hat based repos in Satellite 7.0 ([#34576](https://projects.theforeman.org/issues/34576), [05d1d710](https://github.com/Katello/katello.git/commit/05d1d71017ea839409bb84b8d74262bcb0bce1a3))
 * Red Hat Repositories have weird behavior if arch setting is changed ([#34490](https://projects.theforeman.org/issues/34490), [77f6193f](https://github.com/Katello/katello.git/commit/77f6193f8c1e59e067f8df29917b136001223a0c))
 * After upgrade products with repositories that had Ignorable Content = drpm can no longer be modified ([#34432](https://projects.theforeman.org/issues/34432), [2859ec67](https://github.com/Katello/katello.git/commit/2859ec678d2ce3e1d92cbc9d5daa9b8b32a361bf))

### Hosts
 * Repository Sets - Filter by status ([#34808](https://projects.theforeman.org/issues/34808), [bd142604](https://github.com/Katello/katello.git/commit/bd142604d182d1559ca817784675b44e86a19823))
 * Updating packages from the Content host's page always tries to use katello-agent even when remote_execution_by_default set to true ([#34743](https://projects.theforeman.org/issues/34743), [2b824a86](https://github.com/Katello/katello.git/commit/2b824a86dde492b726fa14e0d62de4872a289145))
 * rename SSH to script provider ([#34696](https://projects.theforeman.org/issues/34696), [6014c4b6](https://github.com/Katello/katello.git/commit/6014c4b6b2feb4f1636d5df96e9ffc64ddb751ed))
 * New host details tables should link to REX job page, not Foreman Tasks ([#34620](https://projects.theforeman.org/issues/34620), [a0f9140b](https://github.com/Katello/katello.git/commit/a0f9140b6313e31a3eff848826d781d7d9c4cefd))
 * Repository Sets - Add Select All & bulk actions ([#34421](https://projects.theforeman.org/issues/34421), [70a71857](https://github.com/Katello/katello.git/commit/70a71857af0649cc942b398faf8411aa7dec5ba8))

### Inter Server Sync
 * Repository set not showing repos after importing library and creating an ak in a disconnected satellite ([#34733](https://projects.theforeman.org/issues/34733), [13dba28d](https://github.com/Katello/katello.git/commit/13dba28d9724cfab41458dbab14d70554df3c500))
 * on content import failure for a repository the created version should be cleaned up ([#34518](https://projects.theforeman.org/issues/34518), [dfacc815](https://github.com/Katello/katello.git/commit/dfacc81503e66aab70bb2131a25297f50ba611b6))
 * Fail to import contents when the connected and disconnected servers have different product labels for the same product ([#34501](https://projects.theforeman.org/issues/34501), [c90c4bd2](https://github.com/Katello/katello.git/commit/c90c4bd2722437463a3e9532bc54d3dac4c4342d))
 * Misleading error message when incorrect org label is entered ([#34464](https://projects.theforeman.org/issues/34464), [cf5f9c87](https://github.com/Katello/katello.git/commit/cf5f9c87fad2abeddad31f63e507e5e4b6f65bd5))

### Tests
 * transient test failure test_yum_copy_all_no_filter_rules   ([#34679](https://projects.theforeman.org/issues/34679), [694c6bcd](https://github.com/Katello/katello.git/commit/694c6bcd20ba153c8924c0d6b44898b497268030))

### Content Views
 * Incremental CV update does not auto-publish CCV ([#34676](https://projects.theforeman.org/issues/34676), [7424532d](https://github.com/Katello/katello.git/commit/7424532df4e8165703b03ae8c77fcf3310c9dabe))
 * Multi-page listing when adding repositories to Content Views confuses the number of repositories to add ([#34670](https://projects.theforeman.org/issues/34670), [29bf01ba](https://github.com/Katello/katello.git/commit/29bf01ba5bee9199872f485ad9c2e6ebf8dd8850))
 * Epoch version is missing from rpm Packages tab of Content View Version ([#34633](https://projects.theforeman.org/issues/34633), [066d693e](https://github.com/Katello/katello.git/commit/066d693ebf03336b543db6a90ae49ef0c78a2f32))
 * Exclude filter may exclude errata and packages that are needed ([#34437](https://projects.theforeman.org/issues/34437), [f5a42e78](https://github.com/Katello/katello.git/commit/f5a42e785bf95a2b183e66ab06242d867176c20b))
 * Incremental update with --propagate-all-composites makes new CVV but with no new content ([#34383](https://projects.theforeman.org/issues/34383), [2b908d44](https://github.com/Katello/katello.git/commit/2b908d44276c3fc05b8ee236a80d801bf92354e4))

### Foreman Proxy Content
 * UI suddenly shows  "Connection refused - connect(2) for 10.74.xxx.yyy:443 (Errno::ECONNREFUSED) Plus 6 more errors" for a smart proxy even if there are no connectivity issue present ([#34671](https://projects.theforeman.org/issues/34671), [2a19fa75](https://github.com/Katello/katello.git/commit/2a19fa75374c098798f51fe6e4f194a5dc85acea))

### Subscriptions
 * "Subscription - Entitlement Report" does not show correct number of subscriptions attached/consumed ([#34609](https://projects.theforeman.org/issues/34609), [cf82cbbc](https://github.com/Katello/katello.git/commit/cf82cbbc769199c6642abfaeefdad9ddf0959b5a))
 * [Bug] Custom subscriptions consumed and available quantity not correct in the CSV file ([#34578](https://projects.theforeman.org/issues/34578), [ad4c50a7](https://github.com/Katello/katello.git/commit/ad4c50a737d3c67592b45e96f525dd2b05122436))
 * Add deprecation banners for traditional (non-SCA) subscription management ([#34522](https://projects.theforeman.org/issues/34522), [ad0cc6f8](https://github.com/Katello/katello.git/commit/ad0cc6f8edfb77765644c93829bd5a1e7d401071))

### Hammer
 * Mirror on sync still shows up in 'hammer repository info', while mirroring policy does not ([#34594](https://projects.theforeman.org/issues/34594), [75bac351](https://github.com/Katello/hammer-cli-katello.git/commit/75bac351da07bb1d5b5488f60a5c46a00505aa5f))

### Upgrades
 * default_location_puppet_content setting and others not cleaned up ([#34587](https://projects.theforeman.org/issues/34587), [24d0ba88](https://github.com/Katello/katello.git/commit/24d0ba8817d621db157c98f1bde7b6bf23e5ec23))

### Lifecycle Environments
 * Lifecycle Environment tab flash OSTree & Docker details for a second then shows actual content path. ([#34470](https://projects.theforeman.org/issues/34470), [8089232c](https://github.com/Katello/katello.git/commit/8089232c5f8bd84f3d54a0dc6693aeb7c478d45f))

### Errata Management
 * Errata icons are the wrong colors ([#34425](https://projects.theforeman.org/issues/34425), [6f39ec6a](https://github.com/Katello/katello.git/commit/6f39ec6a90515fff171bef01c2a4fb0bc1444fa6))

### Other
 * Un-break Katello after Foreman settings change ([#34902](https://projects.theforeman.org/issues/34902))
 * Update terminology for ISS ([#34734](https://projects.theforeman.org/issues/34734), [92980096](https://github.com/Katello/katello.git/commit/92980096784151ed88072bdb0c49e96cf8d70682), [4f334235](https://github.com/Katello/hammer-cli-katello.git/commit/4f334235ae64bba279c78ae97540184e7b637bf8))
 * Recurring logic does not clean up sync plan relationship when unset  ([#34660](https://projects.theforeman.org/issues/34660), [828e4f05](https://github.com/Katello/katello.git/commit/828e4f05e7facca2bdf9506c7885a86ae462723d))
 * Job invocation installs all the installable errata if incorrect `Job Template` is used ([#34638](https://projects.theforeman.org/issues/34638), [bbecd8d7](https://github.com/Katello/katello.git/commit/bbecd8d788fc8c872d396d45e956b62785485639))
 * rake katello:correct_repositories will try to re-create content in katello ([#34540](https://projects.theforeman.org/issues/34540), [1aa4945f](https://github.com/Katello/katello.git/commit/1aa4945f530bc32fa1c89e74504a5caa5312ee39))
 * Failed to docker pull image with "Error: image <image name> not found" error ([#34530](https://projects.theforeman.org/issues/34530), [3963952e](https://github.com/Katello/katello.git/commit/3963952ea3a76f9ce62ec37d020e48e3d3ead99b))
# 4.5 Old Monk (2022-05-12)

## Features

### Hosts
 * New host detail - Change content source ([#34865](https://projects.theforeman.org/issues/34865))
 * new host detail page - 'Installed products' card ([#34816](https://projects.theforeman.org/issues/34816), [a26097ce](https://github.com/Katello/katello.git/commit/a26097ce0a1502e17c782063f5fba8c4837ee5a9))
 * new host details - Add happy empty states ([#34805](https://projects.theforeman.org/issues/34805), [08694c96](https://github.com/Katello/katello.git/commit/08694c96b227473ab4ecb942a2368357e86705bf))
 * Hosts UI - Module streams - Add module stream actions ([#34784](https://projects.theforeman.org/issues/34784), [ffda83fe](https://github.com/Katello/katello.git/commit/ffda83fef64e878b4d0f8c5d6748278f0fc3a1dc))
 * New host details - Host collections Add & Remove modals ([#34548](https://projects.theforeman.org/issues/34548), [fa97fa63](https://github.com/Katello/katello.git/commit/fa97fa6337eaa8895aecca3a1adf34dbbf5c7551))

### Repositories
 * Extend info box in release field of Deb repository create page in Katello GUI ([#34795](https://projects.theforeman.org/issues/34795), [7b1bd0e3](https://github.com/Katello/katello.git/commit/7b1bd0e30815355bb8439364d854511e2f56aaef))
 * Report that lists all the hosts on which a particular repository is enabled ([#34711](https://projects.theforeman.org/issues/34711), [d6d9b712](https://github.com/Katello/katello.git/commit/d6d9b712f3cdae45823431a0b786b975bbbcdced))
 * As a user, I can CRUD custom ACSs via the API ([#34034](https://projects.theforeman.org/issues/34034), [71f9e497](https://github.com/Katello/katello.git/commit/71f9e497bc63aeb53902718dc842e8e7cf39862b))

### Web UI
 * Set up lab routes for ACS UI and land on read-only index page for ACS ([#34783](https://projects.theforeman.org/issues/34783), [2a10b1eb](https://github.com/Katello/katello.git/commit/2a10b1eb15f0dab79630aeba832b67b8ef043767))
 * Hosts UI - Module streams - Filter by state & installation status ([#34663](https://projects.theforeman.org/issues/34663), [91dd495a](https://github.com/Katello/katello.git/commit/91dd495a2b04d8c54411b2be7ef9967b1cbb467e))
 * Add table sorting by column ([#34461](https://projects.theforeman.org/issues/34461), [f609171f](https://github.com/Katello/katello.git/commit/f609171fd2bdc2372a88af85087efc3b018e1ea0))

### Subscriptions
 * - add ouia-ID prop to all fields in CDN configuration ([#34754](https://projects.theforeman.org/issues/34754), [b18916be](https://github.com/Katello/katello.git/commit/b18916be101b65b3326580561ce4d6cf3540c76d), [dc4790d3](https://github.com/Katello/katello.git/commit/dc4790d3cf4960d27544d5eca3ad65bbe83436d3))
 * - add ouia-ID prop to update buttons in CDN configuration ([#34753](https://projects.theforeman.org/issues/34753), [418b6a9c](https://github.com/Katello/katello.git/commit/418b6a9c895215397a6557c50f939b1652be7f6f))

### Content Views
 * RFE - add ouia-ID for buttons on a cv ([#34749](https://projects.theforeman.org/issues/34749), [07d59d07](https://github.com/Katello/katello.git/commit/07d59d076fead2f98b6ec96475ed33986345a0fd))
 * Report template support: list enabled repositories and RPM counts for content hosts ([#34695](https://projects.theforeman.org/issues/34695), [688869a5](https://github.com/Katello/katello.git/commit/688869a59f30523b486798039cfcb350ee2aa441))
 * Content view filter should suggest architectures parameters in RPM rule ([#34586](https://projects.theforeman.org/issues/34586), [96125025](https://github.com/Katello/katello.git/commit/961250253da90741e2db976676a39fb82e042837))
 * Publish new version should redirect to "Version" tab ([#34496](https://projects.theforeman.org/issues/34496), [e4c3cc06](https://github.com/Katello/katello.git/commit/e4c3cc063cf13ed691a2776ca38713fe8207bc32))
 * Allow bulk selections on CV UI to support bulk removing versions ([#34169](https://projects.theforeman.org/issues/34169), [197688c0](https://github.com/Katello/katello.git/commit/197688c0c7a95cc8cdc382bb9881e767bd147eef))

### Foreman Proxy Content
 * SmartProxy Content download-policy Streamed ([#34582](https://projects.theforeman.org/issues/34582), [78884edb](https://github.com/Katello/katello.git/commit/78884edb4fdb0912fd27d23796409553e8592a5c))

### Other
 * new host details - Add Subscription UUID to System Properties card ([#34814](https://projects.theforeman.org/issues/34814), [0839a913](https://github.com/Katello/katello.git/commit/0839a91389dfe015d727821d2978ee5880dbd66a))
 * Properly translate plurals ([#34628](https://projects.theforeman.org/issues/34628), [87ad581a](https://github.com/Katello/katello.git/commit/87ad581ad025cae794642956fda635776c5b1a22))
 * [RFE] add option to export and import just repository for hammer content-export  ([#34374](https://projects.theforeman.org/issues/34374), [dd112712](https://github.com/Katello/hammer-cli-katello.git/commit/dd11271239cddc5f78255b1f6f6f726cba736665), [4c1e7211](https://github.com/Katello/katello.git/commit/4c1e72119659be50dd60682b1ef10e13c3ab682a))

## Bug Fixes

### Tooling
 * Rails 6.1 upgrade raising errors on server startup ([#34862](https://projects.theforeman.org/issues/34862), [7fa2de58](https://github.com/Katello/katello.git/commit/7fa2de58861c68c446033a5828dbe0e756ec46aa))
 * Pin pulp_rpm_client to <3.17.5 ([#34770](https://projects.theforeman.org/issues/34770), [5125b763](https://github.com/Katello/katello.git/commit/5125b763841ac5baf929e959affe810c8c43bff5))
 *  Update Pulpcore to 3.17 ([#34697](https://projects.theforeman.org/issues/34697), [ad46cb3e](https://github.com/Katello/katello.git/commit/ad46cb3ee5c57a9b1d3f4b4a5678b875a1a27dde))

### API
 * don't expose "label" param in PUT /organizations/:id API ([#34859](https://projects.theforeman.org/issues/34859), [56e5b386](https://github.com/Katello/katello.git/commit/56e5b3862f12325b32a83efecc2fb70930f13721))

### Web UI
 * [SAT-5692] Details tab - Registration details card ([#34836](https://projects.theforeman.org/issues/34836), [b5eaf76f](https://github.com/Katello/katello.git/commit/b5eaf76f71c20a1f7b1126f08f44a3bdd2da1930))
 * New host detail page - sentence case fixes ([#34797](https://projects.theforeman.org/issues/34797), [b997a2f0](https://github.com/Katello/katello.git/commit/b997a2f01d7f14844f75c0085a00e6f7d1762b55))
 * [SAT-5692] Add Bookmarks to all host detail tables ([#34632](https://projects.theforeman.org/issues/34632), [0daa8c99](https://github.com/Katello/katello.git/commit/0daa8c99b1e67bd26a368faef3f64e2842f79837))
 * [RFE] CV UI -  Errata Filter Date doesn't show "Start Date" & "End Date" ([#34630](https://projects.theforeman.org/issues/34630), [05798608](https://github.com/Katello/katello.git/commit/057986082ebf268478db94dfb35cd0eee3e4070c))
 * CV UI -  Wizard bug fixes ([#34599](https://projects.theforeman.org/issues/34599), [d2497425](https://github.com/Katello/katello.git/commit/d2497425e3a75a7a7df41fb1a547aa565cfd4f10))
 * CV UI - Patternfly update causes tabs to navigate twice on click ([#34559](https://projects.theforeman.org/issues/34559), [acf477e2](https://github.com/Katello/katello.git/commit/acf477e24a52ed85d0b89511475e399b75192898))
 * CV UI - Status value translations should only translate the user facing text, not params etc sent to API. ([#34158](https://projects.theforeman.org/issues/34158), [aa9592ee](https://github.com/Katello/katello.git/commit/aa9592eec9d4ff47506c3d7b316098b14768d9f4))

### Repositories
 * Fix upstream authentication autofill issue for Katello repositories ([#34818](https://projects.theforeman.org/issues/34818), [ea78e268](https://github.com/Katello/katello.git/commit/ea78e2682b6305db0f453b7df624345b3c890b7c))
 * Bring back 0 package counts!  ([#34803](https://projects.theforeman.org/issues/34803), [b82bfb5a](https://github.com/Katello/katello.git/commit/b82bfb5a3970639372cc19d1ae843afef87ee94e))
 * Sync Status page does not show syncing progress bar under "Result" column when syncing a repo ([#34766](https://projects.theforeman.org/issues/34766), [f8172454](https://github.com/Katello/katello.git/commit/f81724544d3cc7a27e03a903ff34d05b8f878846))
 * Add 'republish repository metadata' to Hammer ([#34762](https://projects.theforeman.org/issues/34762), [114b12ad](https://github.com/Katello/hammer-cli-katello.git/commit/114b12ad9094a16da2ff7867c6517d6591c9b496))
 * repositories/import_uploads API endpoint do require two mandatory parameters ([#34729](https://projects.theforeman.org/issues/34729), [2d288ff1](https://github.com/Katello/katello.git/commit/2d288ff1a6ae471119d6810c9abe9ce555f97971))
 * A failed CV promote during publish or repo sync causes ISE ([#34680](https://projects.theforeman.org/issues/34680), [f0c69a1b](https://github.com/Katello/katello.git/commit/f0c69a1bf7799807e2238998f7b54e230aa5fa36))
 * Cannot upload a package to a repository if the same package already exists in another repository, but is not downloaded  ([#34635](https://projects.theforeman.org/issues/34635), [a3a856e8](https://github.com/Katello/katello.git/commit/a3a856e896823dd70510c197070199b013a434b4))
 * Remotes should have username and password cleared out if a user sets them to be blank ([#34619](https://projects.theforeman.org/issues/34619), [17a12869](https://github.com/Katello/katello.git/commit/17a12869397c56d556a38784ac88380713873866))
 * The "Serve via HTTP" and "Verify SSL" options in Repo Discovery page does not functions at all in Satellite 7.0 ([#34617](https://projects.theforeman.org/issues/34617), [8f76e5e9](https://github.com/Katello/katello.git/commit/8f76e5e98e97ff138884e2d0a6db2b7ff6610543))
 * Satellite/capsule 6.10 and tools 6.10 repos are listed in the Recommended Repositories for Sat 7.0 ([#34577](https://projects.theforeman.org/issues/34577), [c0cb3e25](https://github.com/Katello/katello.git/commit/c0cb3e25f3abdd14af5d3e0b9a4739345252b015))
 * Deletion of Custom repo deletes it from all versions of CV where it is included but the behavior is different for Red Hat based repos in Satellite 7.0 ([#34576](https://projects.theforeman.org/issues/34576), [05d1d710](https://github.com/Katello/katello.git/commit/05d1d71017ea839409bb84b8d74262bcb0bce1a3))
 * Red Hat Repositories have weird behavior if arch setting is changed ([#34490](https://projects.theforeman.org/issues/34490), [77f6193f](https://github.com/Katello/katello.git/commit/77f6193f8c1e59e067f8df29917b136001223a0c))
 * After upgrade products with repositories that had Ignorable Content = drpm can no longer be modified ([#34432](https://projects.theforeman.org/issues/34432), [2859ec67](https://github.com/Katello/katello.git/commit/2859ec678d2ce3e1d92cbc9d5daa9b8b32a361bf))

### Hosts
 * Repository Sets - Filter by status ([#34808](https://projects.theforeman.org/issues/34808), [bd142604](https://github.com/Katello/katello.git/commit/bd142604d182d1559ca817784675b44e86a19823))
 * Updating packages from the Content host's page always tries to use katello-agent even when remote_execution_by_default set to true ([#34743](https://projects.theforeman.org/issues/34743), [2b824a86](https://github.com/Katello/katello.git/commit/2b824a86dde492b726fa14e0d62de4872a289145))
 * rename SSH to script provider ([#34696](https://projects.theforeman.org/issues/34696), [6014c4b6](https://github.com/Katello/katello.git/commit/6014c4b6b2feb4f1636d5df96e9ffc64ddb751ed))
 * New host details tables should link to REX job page, not Foreman Tasks ([#34620](https://projects.theforeman.org/issues/34620), [a0f9140b](https://github.com/Katello/katello.git/commit/a0f9140b6313e31a3eff848826d781d7d9c4cefd))
 * Repository Sets - Add Select All & bulk actions ([#34421](https://projects.theforeman.org/issues/34421), [70a71857](https://github.com/Katello/katello.git/commit/70a71857af0649cc942b398faf8411aa7dec5ba8))

### Inter Server Sync
 * Repository set not showing repos after importing library and creating an ak in a disconnected satellite ([#34733](https://projects.theforeman.org/issues/34733), [13dba28d](https://github.com/Katello/katello.git/commit/13dba28d9724cfab41458dbab14d70554df3c500))
 * on content import failure for a repository the created version should be cleaned up ([#34518](https://projects.theforeman.org/issues/34518), [dfacc815](https://github.com/Katello/katello.git/commit/dfacc81503e66aab70bb2131a25297f50ba611b6))
 * Fail to import contents when the connected and disconnected servers have different product labels for the same product ([#34501](https://projects.theforeman.org/issues/34501), [c90c4bd2](https://github.com/Katello/katello.git/commit/c90c4bd2722437463a3e9532bc54d3dac4c4342d))
 * Misleading error message when incorrect org label is entered ([#34464](https://projects.theforeman.org/issues/34464), [cf5f9c87](https://github.com/Katello/katello.git/commit/cf5f9c87fad2abeddad31f63e507e5e4b6f65bd5))

### Tests
 * transient test failure test_yum_copy_all_no_filter_rules   ([#34679](https://projects.theforeman.org/issues/34679), [694c6bcd](https://github.com/Katello/katello.git/commit/694c6bcd20ba153c8924c0d6b44898b497268030))

### Content Views
 * Incremental CV update does not auto-publish CCV ([#34676](https://projects.theforeman.org/issues/34676), [7424532d](https://github.com/Katello/katello.git/commit/7424532df4e8165703b03ae8c77fcf3310c9dabe))
 * Multi-page listing when adding repositories to Content Views confuses the number of repositories to add ([#34670](https://projects.theforeman.org/issues/34670), [29bf01ba](https://github.com/Katello/katello.git/commit/29bf01ba5bee9199872f485ad9c2e6ebf8dd8850))
 * Epoch version is missing from rpm Packages tab of Content View Version ([#34633](https://projects.theforeman.org/issues/34633), [066d693e](https://github.com/Katello/katello.git/commit/066d693ebf03336b543db6a90ae49ef0c78a2f32))
 * Exclude filter may exclude errata and packages that are needed ([#34437](https://projects.theforeman.org/issues/34437), [f5a42e78](https://github.com/Katello/katello.git/commit/f5a42e785bf95a2b183e66ab06242d867176c20b))
 * Incremental update with --propagate-all-composites makes new CVV but with no new content ([#34383](https://projects.theforeman.org/issues/34383), [2b908d44](https://github.com/Katello/katello.git/commit/2b908d44276c3fc05b8ee236a80d801bf92354e4))

### Foreman Proxy Content
 * UI suddenly shows  "Connection refused - connect(2) for 10.74.xxx.yyy:443 (Errno::ECONNREFUSED) Plus 6 more errors" for a smart proxy even if there are no connectivity issue present ([#34671](https://projects.theforeman.org/issues/34671), [2a19fa75](https://github.com/Katello/katello.git/commit/2a19fa75374c098798f51fe6e4f194a5dc85acea))

### Subscriptions
 * "Subscription - Entitlement Report" does not show correct number of subscriptions attached/consumed ([#34609](https://projects.theforeman.org/issues/34609), [cf82cbbc](https://github.com/Katello/katello.git/commit/cf82cbbc769199c6642abfaeefdad9ddf0959b5a))
 * [Bug] Custom subscriptions consumed and available quantity not correct in the CSV file ([#34578](https://projects.theforeman.org/issues/34578), [ad4c50a7](https://github.com/Katello/katello.git/commit/ad4c50a737d3c67592b45e96f525dd2b05122436))
 * Add deprecation banners for traditional (non-SCA) subscription management ([#34522](https://projects.theforeman.org/issues/34522), [ad0cc6f8](https://github.com/Katello/katello.git/commit/ad0cc6f8edfb77765644c93829bd5a1e7d401071))

### Hammer
 * Mirror on sync still shows up in 'hammer repository info', while mirroring policy does not ([#34594](https://projects.theforeman.org/issues/34594), [75bac351](https://github.com/Katello/hammer-cli-katello.git/commit/75bac351da07bb1d5b5488f60a5c46a00505aa5f))

### Upgrades
 * default_location_puppet_content setting and others not cleaned up ([#34587](https://projects.theforeman.org/issues/34587), [24d0ba88](https://github.com/Katello/katello.git/commit/24d0ba8817d621db157c98f1bde7b6bf23e5ec23))

### Lifecycle Environments
 * Lifecycle Environment tab flash OSTree & Docker details for a second then shows actual content path. ([#34470](https://projects.theforeman.org/issues/34470), [8089232c](https://github.com/Katello/katello.git/commit/8089232c5f8bd84f3d54a0dc6693aeb7c478d45f))

### Errata Management
 * Errata icons are the wrong colors ([#34425](https://projects.theforeman.org/issues/34425), [6f39ec6a](https://github.com/Katello/katello.git/commit/6f39ec6a90515fff171bef01c2a4fb0bc1444fa6))

### Other
 * Un-break Katello after Foreman settings change ([#34902](https://projects.theforeman.org/issues/34902))
 * Update terminology for ISS ([#34734](https://projects.theforeman.org/issues/34734), [92980096](https://github.com/Katello/katello.git/commit/92980096784151ed88072bdb0c49e96cf8d70682), [4f334235](https://github.com/Katello/hammer-cli-katello.git/commit/4f334235ae64bba279c78ae97540184e7b637bf8))
 * Recurring logic does not clean up sync plan relationship when unset  ([#34660](https://projects.theforeman.org/issues/34660), [828e4f05](https://github.com/Katello/katello.git/commit/828e4f05e7facca2bdf9506c7885a86ae462723d))
 * Job invocation installs all the installable errata if incorrect `Job Template` is used ([#34638](https://projects.theforeman.org/issues/34638), [bbecd8d7](https://github.com/Katello/katello.git/commit/bbecd8d788fc8c872d396d45e956b62785485639))
 * rake katello:correct_repositories will try to re-create content in katello ([#34540](https://projects.theforeman.org/issues/34540), [1aa4945f](https://github.com/Katello/katello.git/commit/1aa4945f530bc32fa1c89e74504a5caa5312ee39))
 * Failed to docker pull image with "Error: image <image name> not found" error ([#34530](https://projects.theforeman.org/issues/34530), [3963952e](https://github.com/Katello/katello.git/commit/3963952ea3a76f9ce62ec37d020e48e3d3ead99b))
