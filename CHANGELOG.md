# 3.2 Malt Liquor (2016-09-22)

## Features

### Capsule
 * Update Katello to synchronize puppet content to capsule based on capsules puppet path. ([#16456](http://projects.theforeman.org/issues/16456), [c7a3b4f1](http://github.com/katello/katello/commit/c7a3b4f140651896951d1527f39a543037298abe))
 * [RFE] make it possible to run capsule-remove unattended ([#16003](http://projects.theforeman.org/issues/16003), [010d458f](http://github.com/katello/katello-installer/commit/010d458f4ac2fc1569fbf2fcbebaa3dc01a54388))
 * Content Hosts: UI should have some indicator as if/which capsule is providing content ([#15818](http://projects.theforeman.org/issues/15818), [69df0ec0](http://github.com/katello/katello/commit/69df0ec0629dad7ef0262cac2618fe789328fcf3))

### Installer
 * Add rubocop to katello-installer ([#16354](http://projects.theforeman.org/issues/16354), [0743b788](http://github.com/katello/katello-installer/commit/0743b788f551c4f117e8493ac25bf5a6c8302181), [34d01ec2](http://github.com/katello/katello-installer/commit/34d01ec28515f15487bcc06b18994d06795c42e8))

### Content Views
 * [RFE] Content View - package filter version field too short for length of typical version strings ([#16332](http://projects.theforeman.org/issues/16332), [f6930f84](http://github.com/katello/katello/commit/f6930f8463c597fa59d4eb709e740ceac78d010b))
 * Add content-view published status to " hammer -u admin -p changeme content-view  list" ([#16302](http://projects.theforeman.org/issues/16302), [60ed450e](http://github.com/katello/hammer-cli-katello/commit/60ed450e834583179447fcb203d274c9d49c6c34))
 * Allow adding file type repositories to content views ([#13661](http://projects.theforeman.org/issues/13661), [94e8f780](http://github.com/katello/katello/commit/94e8f7803bf99d74433e6592957c20ddeb5b6df7))

### Errata Management
 * add a way to manually generate applicability for a host ([#16295](http://projects.theforeman.org/issues/16295), [f9ea2ba2](http://github.com/katello/katello/commit/f9ea2ba27ae62bdddc524c888e2e66fdb17ba950))

### Tests
 * Enable HoundCI for checking rubocop cops ([#16242](http://projects.theforeman.org/issues/16242), [da866bef](http://github.com/katello/katello/commit/da866bef41f74888516fcba776bf45103e652dfa))
 * Add code climate and build status badges to Katello README ([#15608](http://projects.theforeman.org/issues/15608), [d51e0587](http://github.com/katello/katello/commit/d51e0587a7efe85583c19ec4c6f2c39701dc0090))
 * Turn on AssignmentInCondition cop ([#15483](http://projects.theforeman.org/issues/15483), [a7228ec6](http://github.com/katello/katello/commit/a7228ec6c5b2c68d64502fc877d1dfb558480f32))
 * Add a coverage report to Katello ([#15288](http://projects.theforeman.org/issues/15288), [407d3ae3](http://github.com/katello/katello/commit/407d3ae3baee516d79887d24b739bbbdece464ff))

### Tooling
 * Update to foreman-tasks 0.8.0 ([#16171](http://projects.theforeman.org/issues/16171), [d385d8ac](http://github.com/katello/katello/commit/d385d8acbfd01ce79c79b2c21624d4d465bd139d), [2145ea4e](http://github.com/katello//commit/2145ea4e6c4d178c5b2a110dd6ee030ffafa26b8))

### Hammer
 * Listing product content for an activation key does not show correct state in Hammer ([#16000](http://projects.theforeman.org/issues/16000), [41584f75](http://github.com/katello/hammer-cli-katello/commit/41584f751e7c8a082a7c3da7708e897e9c5e62be), [028bd011](http://github.com/katello/katello/commit/028bd0115e60da9253da38b01556d0143087c4ed))
 *  Hostgroup info should show associated cv and lifecycle-environment ([#15990](http://projects.theforeman.org/issues/15990), [5b617f3b](http://github.com/katello/hammer-cli-katello/commit/5b617f3bb888106bd5027a166d42e18c875a8a53))
 * Test with Ruby 2.3 ([#15691](http://projects.theforeman.org/issues/15691), [725801c8](http://github.com/katello/hammer-cli-katello/commit/725801c8bbf0655a94570510e87fa7e034144b61))
 * - "hammer content-host info" command should have information related to "Content Host Status" ([#14829](http://projects.theforeman.org/issues/14829), [29520f64](http://github.com/katello/hammer-cli-katello/commit/29520f6448a9bf2f68e8e6373b25221a05624696))
 * Create/update composite content-view by content-view Names ([#14604](http://projects.theforeman.org/issues/14604), [fa2c5214](http://github.com/katello/hammer-cli-katello/commit/fa2c52142990af23b7f2d6c26ec18cc5f53d6921))

### Repositories
 * Need a quick way to allow "insecure"  syncs ([#15802](http://projects.theforeman.org/issues/15802), [810cc603](http://github.com/katello/katello/commit/810cc603b2a4f8841b7d995f700dc2c50eeed2ca), [34824f25](http://github.com/katello/katello/commit/34824f250d5b35e8088b4463852f2b4c5e422cde))
 * Provide API for file type content ([#15630](http://projects.theforeman.org/issues/15630), [8fac5bed](http://github.com/katello/katello/commit/8fac5bed86cfb476e5ec0b3ed539d4769a15c965))

### API
 * Use parameter_filter instead of attr_accessible ([#15741](http://projects.theforeman.org/issues/15741), [328ee19a](http://github.com/katello/katello/commit/328ee19afa9b743d6ff25e3c7cabaa20c87b43cc))
 * [Sat6] allow multiple rpms to be added via content-view filter rule create API endpoint ([#15536](http://projects.theforeman.org/issues/15536), [ad75723f](http://github.com/katello/katello/commit/ad75723f03b84378feff7cbc983d6caf73acbb15))

### Documentation
 * Remove YARD from Katello ([#15670](http://projects.theforeman.org/issues/15670), [37ff67b3](http://github.com/katello/katello/commit/37ff67b3f2ac3f0c78f45715baa735d93a044cab))

### Backup & Restore
 * Fully online backup ([#15454](http://projects.theforeman.org/issues/15454), [46e44353](http://github.com/katello//commit/46e44353099568f6321047887404b24500a27e35))

### Web UI
 * Upgrade katello to new angular/jasmin ([#15085](http://projects.theforeman.org/issues/15085), [35879d13](http://github.com/katello/katello/commit/35879d1300416281a75ed677bede37547b6e9384))

### Atomic
 * UI - As a user I want to be able to search rpm-ostree repos ([#13953](http://projects.theforeman.org/issues/13953), [67d0bd27](http://github.com/katello/katello/commit/67d0bd279e88783cd141bde4f00bf9619a6d06cf))

### Subscriptions
 * As a UI user i like to select hosts to attach subscriptions ([#10431](http://projects.theforeman.org/issues/10431), [95d7b249](http://github.com/katello/katello/commit/95d7b249824621b8df8dcf7875e12113c687a685))

### Upgrades
 * Create a preupgrade script to check systems before upgrades ([#15611](http://projects.theforeman.org/issues/15611), [fea48380](http://github.com/katello/katello/commit/fea48380ff60330b12f3966f82d4353c56dcc152))

## Bug Fixes

### Puppet
 * Support cleaning empty puppet envs with puppet 4 ([#16523](http://projects.theforeman.org/issues/16523), [f7b70e71](http://github.com/katello//commit/f7b70e71ecaf99cd9de375d75d0880d4f3d5c3be), [58469817](http://github.com/katello//commit/5846981719e9bd6a5617daf7078b8729dbb1e5f0))
 * katello installer does not allow for upgrading puppet ([#16053](http://projects.theforeman.org/issues/16053), [8db5561d](http://github.com/katello/katello-installer/commit/8db5561d884b46d0dd81f88a3666f0b1cf3130df), [b192d5e7](http://github.com/katello/katello.org/commit/b192d5e7f500a445ff8b71473f8fbf624e96a280))
 * --clear-puppet-environments does not handle puppet 4 env dir ([#16011](http://projects.theforeman.org/issues/16011), [6cbb35d5](http://github.com/katello/katello-installer/commit/6cbb35d5244cef8799531f82044d3134088de9fe))
 * empty puppet environments are left behind in /etc/puppet/environments ([#15845](http://projects.theforeman.org/issues/15845), [13189a68](http://github.com/katello//commit/13189a683be47c455f7da00d8152baebbffa4e7e))

### Hammer
 * Support large file uploads in the CLI ([#16457](http://projects.theforeman.org/issues/16457), [f060a2b3](http://github.com/katello/hammer-cli-katello/commit/f060a2b37b07d4280959af4dc5eaec363e709d0e))
 * Following the README in setting up hammer-cli-katello, you get a gem dependency conflict ([#16101](http://projects.theforeman.org/issues/16101), [f46fbd64](http://github.com/katello/hammer-cli-katello/commit/f46fbd641171a0cae871f268230ef484f50bae44), [8f19345a](http://github.com/katello/hammer-cli-katello/commit/8f19345a8e386f43eed359e289e3d66d9ab7cd2e))
 * [Sat6.2] command "hammer activation-key add-host-collection" fails if using option "--host-collection" with organization_id set to default 1 ([#16034](http://projects.theforeman.org/issues/16034), [34ae3d3d](http://github.com/katello/hammer-cli-katello/commit/34ae3d3d6ede2df3aba85db7a7028e6dd0f14a6f))
 * Drop support for Ruby 2.0.0 ([#15949](http://projects.theforeman.org/issues/15949), [44a80a49](http://github.com/katello/hammer-cli-katello/commit/44a80a499d11e4814f42af5f3e945ca98696c8b6))
 * Fix the broken link to Travis in the Readme ([#15934](http://projects.theforeman.org/issues/15934), [5fbe0fab](http://github.com/katello/hammer-cli-katello/commit/5fbe0fabd3c6e81d1e684dcf0eaf14cd32b1d045))
 * Adjust coverage settings in hammer-cli-katello ([#15927](http://projects.theforeman.org/issues/15927), [03f06430](http://github.com/katello/hammer-cli-katello/commit/03f064307418a51e384003cff1e7af2f1d481688))
 * Hammer doesn't handle removal of required :organization_id param on content_view and lifecycle_environment ([#15830](http://projects.theforeman.org/issues/15830), [e0bea267](http://github.com/katello/hammer-cli-katello/commit/e0bea267be201e78d4f732b29233de7334451270))
 * Allow Foreman objects to resolve using `create_search_options_creators_without_katello_api` ([#15701](http://projects.theforeman.org/issues/15701), [18926cd6](http://github.com/katello/hammer-cli-katello/commit/18926cd614495c4c59f043e7151af5e67edea5be), [d270200b](http://github.com/katello/hammer-cli-katello/commit/d270200b47dc3d8574a8fc8c676f8855faa01427))
 * Organization options for content-view and lifecycle-environment should fail gracefully for `hammer hostgroups create/update`   ([#15693](http://projects.theforeman.org/issues/15693), [101e9666](http://github.com/katello/hammer-cli-katello/commit/101e9666d599c9c38f922bde85ebecfa92184a32))
 * hammer content-view create fails when component-ids are specified ([#15678](http://projects.theforeman.org/issues/15678), [d9551dc8](http://github.com/katello/katello/commit/d9551dc8e503c2839626c26aa0ba981b91b3d762))
 * Cannot create new content view ([#15604](http://projects.theforeman.org/issues/15604), [6feaf353](http://github.com/katello/hammer-cli-katello/commit/6feaf35385717242afbe09ba84e9ba6f8b19af6a))
 * Remove Ruby 1.9.3 support from hammer-cli-katello Travis tests ([#15593](http://projects.theforeman.org/issues/15593), [7b95d443](http://github.com/katello/hammer-cli-katello/commit/7b95d4434fa5875d2404c838d4a4a3e782f9773e))
 * Remove `hammer content-host update` - New command is `hammer host update` ([#15589](http://projects.theforeman.org/issues/15589), [2597aaef](http://github.com/katello/hammer-cli-katello/commit/2597aaeffc710066380b5461e0bd757191d24001))
 * [Sat6] allow multiple rpms to be added via hammer content-view filter rule create ([#15537](http://projects.theforeman.org/issues/15537), [6dce9a75](http://github.com/katello/hammer-cli-katello/commit/6dce9a75ba071d9d358baa165ba9b85b1a7766e2))
 * Use fully qualified object ::Foreman in #15420 ([#15443](http://projects.theforeman.org/issues/15443), [39117d81](http://github.com/katello/katello/commit/39117d81e7fb4436e10979f074c2dc0f8b0ba8a1))
 * Update test data with new API ([#15436](http://projects.theforeman.org/issues/15436), [a9fa1808](http://github.com/katello/hammer-cli-katello/commit/a9fa18080b81130c0d2c183daa55fd75e5b027d3))
 * Only require hammer_cli and hammer_cli_foreman from git in development and production ([#15419](http://projects.theforeman.org/issues/15419), [650bb22e](http://github.com/katello/hammer-cli-katello/commit/650bb22e4aaf11e436f27dea603477b6b7c8a6fd))
 * hammer hostgroup update or create command fails when using --organization-ids option fails ([#15313](http://projects.theforeman.org/issues/15313), [2c7c6b6f](http://github.com/katello/hammer-cli-katello/commit/2c7c6b6f8776671509d1e0526b396a736b9a46a1))
 * hammer host-collection add-host/remove-host always return success ([#15291](http://projects.theforeman.org/issues/15291), [2e3e5edf](http://github.com/katello/katello/commit/2e3e5edf4d8a1883aa827a6278ad7cd83bdc00d4))
 * 'hammer activation-key subscriptions' shows already removed subscriptions ([#15272](http://projects.theforeman.org/issues/15272), [9e72e0c8](http://github.com/katello/hammer-cli-katello/commit/9e72e0c8a3759016112b4445d38a2bc55a020aeb))
 * unable to remove 'version' parameter from command ([#13636](http://projects.theforeman.org/issues/13636))
 * need way to attach a subscription to a content host w/ hammer ([#9669](http://projects.theforeman.org/issues/9669), [14c96768](http://github.com/katello/hammer-cli-katello/commit/14c967686b5ef466cd9f30f180cacd7db56507a5))

### Installer
 * capsule-certs-generate fails for missing parser cache ([#16455](http://projects.theforeman.org/issues/16455), [95eea445](http://github.com/katello/katello-installer/commit/95eea44544c1a2b42a0e9f85f4c49b23884cad47))
 * Installer should support Puppet 3 and Puppet 4 cache directory ([#16334](http://projects.theforeman.org/issues/16334), [e7177df5](http://github.com/katello/katello-installer/commit/e7177df5c0917ea3f00de027d314755e19cfe16d))
 * katello-certs-check output should display a absolute path to certs ([#16280](http://projects.theforeman.org/issues/16280), [e03bc400](http://github.com/katello/katello-installer/commit/e03bc400004ab6343c81e65bb097b45ad744fa5f))
 * Generate katello-installer's parser cache for kafo and include in the source bundle ([#15938](http://projects.theforeman.org/issues/15938), [7e43a9d2](http://github.com/katello/katello-installer/commit/7e43a9d29bd70c33bc1945042c39a46e71cc829a), [9fa93e0a](http://github.com/katello//commit/9fa93e0a6b539210f8b7ff6ced75324ab28fa155))
 * Do not use facter anywhere in katello-installer ([#15911](http://projects.theforeman.org/issues/15911), [57814d72](http://github.com/katello/katello-installer/commit/57814d725eb369211175b609beb9086f107ce8d1))
 * Look at AIO data path for cached data ([#15910](http://projects.theforeman.org/issues/15910), [3edf7534](http://github.com/katello/katello-installer/commit/3edf7534471cbf787be02b39b139e5fe9484661c))
 * puppet-certs doesn't support puppet 4 aio paths for SSL certificates ([#15882](http://projects.theforeman.org/issues/15882), [55b0911f](http://github.com/katello/puppet-certs/commit/55b0911f7d8465a11fca5d45d31a1fee59a3b7f8))
 * katello-installer may fail on machines with low RAM ([#15696](http://projects.theforeman.org/issues/15696), [33f41e6d](http://github.com/katello/katello-installer/commit/33f41e6d1c9df71e213a75f85591407bd79aa68a))
 * rake setup_local creates ./modules/modules ([#15511](http://projects.theforeman.org/issues/15511), [ce810a94](http://github.com/katello/katello-installer/commit/ce810a9473ac17ebf4a5413a646b385d393a0749))
 * Install fails if host puppet certs have already been generated ([#15241](http://projects.theforeman.org/issues/15241), [b54acb74](http://github.com/katello/katello-installer/commit/b54acb744e9de530ec019bcca0f850d11b37d5b8))
 * Select Puppet::server_implementation from installer ([#14602](http://projects.theforeman.org/issues/14602))
 * katello-certs-check should print absolute paths to certificates ([#15775](http://projects.theforeman.org/issues/15775), [b57b21e4](http://github.com/katello/katello-installer/commit/b57b21e46f51490bd7d5e1f5f5d18b03fa494ed2))
 * The installer should check that the cert rpms installed on the system are corresponding to those present in ~/ssl-build (or in the capsule certs tar.gz) ([#15538](http://projects.theforeman.org/issues/15538), [df36e803](http://github.com/katello/puppet-certs/commit/df36e803c6d24ac08d780e103cabb36dabf852fa), [e1f168d7](http://github.com/katello/puppet-certs/commit/e1f168d72a9ca9aa573dfd3e5f7cd214ff28e2bd))
 * Making Upgrade from 3.1 RC2 to 3.1 Release ([#16433](http://projects.theforeman.org/issues/16433), [4ea05178](http://github.com/katello/katello.org/commit/4ea05178a0d06e13f4704ea4b189620665532c62))

### Repositories
 * Handle import upload errors from pulp ([#16451](http://projects.theforeman.org/issues/16451), [f58088de](http://github.com/katello/katello/commit/f58088def544fb08af927568b4b42e321628a1f9))
 * Unable to upload large RPM files from Satellite UI ([#16344](http://projects.theforeman.org/issues/16344), [0127b0ad](http://github.com/katello/katello/commit/0127b0adda4c3a2635031f41617b07c9e0aca597))
 * look for treeinfo files when enabling a repo ([#16278](http://projects.theforeman.org/issues/16278), [821d936d](http://github.com/katello/katello/commit/821d936d3f5f7ffd729a22cc390a18bff0d97515))
 * The refresh_repositsory file is misspelled as refresh_repostiory ([#16157](http://projects.theforeman.org/issues/16157), [be6cc4be](http://github.com/katello/katello/commit/be6cc4be2ab0462082889092d003955ac0075fbe))
 * Unable to sync Docker Containers to Satellite if repository already exists ([#15971](http://projects.theforeman.org/issues/15971), [4f30704e](http://github.com/katello/katello/commit/4f30704e95a9be5d80ef465be24455e372959ee1))
 * Repository > Details: "Last Synced" for an unsynced repo looks silly. ([#15933](http://projects.theforeman.org/issues/15933), [9cff370e](http://github.com/katello/katello/commit/9cff370e8ac9e108848e0ecbc7d95902caec0dc8))
 * Cannot add/remove repositories to a content view ([#15869](http://projects.theforeman.org/issues/15869), [a7dcac7e](http://github.com/katello/katello/commit/a7dcac7ebd20caa34983c7629216f2378b458a76))
 * Enabling a repository needs to fail on pulp error ([#15824](http://projects.theforeman.org/issues/15824), [236caa38](http://github.com/katello/katello/commit/236caa388ad1a31a22305735a1898e1c7716314e))
 * Syncing a PULP_MANIFEST puppet repo over file:// fails with No such file or directory: u'///dir/modules.json' ([#15812](http://projects.theforeman.org/issues/15812), [d72f8c10](http://github.com/katello/katello.org/commit/d72f8c10077e6b2f3286d4aae968a9e41386439a))
 * Incremental update task name should have more info ([#15808](http://projects.theforeman.org/issues/15808), [133a4dde](http://github.com/katello/katello/commit/133a4dde762d85ebd0ca76c4fc5ef33f515e8239))
 * Opening Red Hat Repositories link without an uploaded manifest provides the user with a dead link ([#15803](http://projects.theforeman.org/issues/15803), [c7eb8c52](http://github.com/katello/katello/commit/c7eb8c52545082ef72aa6230d13a0b87fe85fb62))

### Documentation
 * doc change for updated memory specs ([#16427](http://projects.theforeman.org/issues/16427), [e3b1057f](http://github.com/katello/katello.org/commit/e3b1057f0c8f5db002d2252ddef94e67ef26d66c))
 * Fix README references to YARD and praise ([#15669](http://projects.theforeman.org/issues/15669), [4e21fa41](http://github.com/katello/katello/commit/4e21fa41d0913e9e2ba065c33c4dabd6085cffef))
 * Fix broken link in the README ([#15609](http://projects.theforeman.org/issues/15609), [1a6e0477](http://github.com/katello/katello/commit/1a6e04773fd3e9bf8637ff67645d04c50584dc22))
 * katello disconnected instructions fail to work due to vhost configuration ([#15702](http://projects.theforeman.org/issues/15702), [3913669a](http://github.com/katello/katello.org/commit/3913669a7a68f77ea882bd49460f6615a3513454))

### GPG Keys
 * Inconsistent with capitalization of GPG keys across navigation, page title, and button ([#16409](http://projects.theforeman.org/issues/16409), [e77758e2](http://github.com/katello/katello/commit/e77758e2f449c0c8e1db68402a687e21a8541c26))

### Errata Management
 * Environment and content view not displayed for content host ([#16399](http://projects.theforeman.org/issues/16399), [d157380f](http://github.com/katello/katello/commit/d157380f2477e7e5709c1591717bfaf8940f30c9))
 * dashboard latest errata shows untranslated strings ([#15929](http://projects.theforeman.org/issues/15929), [3f888f37](http://github.com/katello/katello/commit/3f888f374fa85f78c4532c41ab96f3f61d66ec96))
 * Cannot apply large sets of errata on errata page because the host search returns a 414 ([#15376](http://projects.theforeman.org/issues/15376), [d099e609](http://github.com/katello/katello/commit/d099e60957b15c2617e7d34ec5f8eb6b0254a9eb))
 * Incremental Update fails with --update-all-systems ([#16232](http://projects.theforeman.org/issues/16232), [d715a3f1](http://github.com/katello/katello/commit/d715a3f13bf648328fe508bb9f601e90b8ceed6b))

### Client/Agent
 *  Removing katello-ca-consumer rpm should revert rhsm.conf  ([#16388](http://projects.theforeman.org/issues/16388), [8d75e8c8](http://github.com/katello/puppet-certs/commit/8d75e8c86a4dfd43bec9295dad736e5cf9fa6059))
 * Large virt-who json may cause performance issue ([#16228](http://projects.theforeman.org/issues/16228), [a0ec0f2b](http://github.com/katello/katello/commit/a0ec0f2ba5c49a31799cd37574bfce8e02de9124))
 * calling `enabled_repos` always forces an errata applicability regeneration ([#16209](http://projects.theforeman.org/issues/16209), [184c966c](http://github.com/katello/katello/commit/184c966ca192ae2eacef9e888475c705cf66ac63))
 * provide option to delete host with subscription-manager unregister ([#15455](http://projects.theforeman.org/issues/15455), [71bf4797](http://github.com/katello/katello/commit/71bf4797cadf58ca003e9383a8cc94a46f1ab0db))
 * Re-Registering  host with uppercase hostname errors 'Name has already been taken' ([#15891](http://projects.theforeman.org/issues/15891), [54e881bf](http://github.com/katello/katello/commit/54e881bf55a5e3915121d902adbc02f2e3eef44c))
 * Facts updated twice by checkin ([#16368](http://projects.theforeman.org/issues/16368), [fb6aaf92](http://github.com/katello/katello/commit/fb6aaf928e88ff236068b739148f1ef2b70cae55))
 * unable to process virt-who data, fails with error: "Validation failed: Name is invalid, Name is invalid" ([#16248](http://projects.theforeman.org/issues/16248), [fdecd6dc](http://github.com/katello/katello/commit/fdecd6dc82585e0d9f8ebd5560aaca9ec38ca07d))

### Web UI
 * Content host detail page says "RAM (GB): 1024 MB" which is bit confusing ("GB" vs. "MB") ([#16370](http://projects.theforeman.org/issues/16370), [21c9750b](http://github.com/katello/katello/commit/21c9750ba80f117474cce1f1dbac78646ab34e49))
 * Update All button is grayed out unless a package is selected. ([#16341](http://projects.theforeman.org/issues/16341), [2062d106](http://github.com/katello/katello/commit/2062d10692d3524273fac45129d6ebcf506b2ca2))
 * Javascript tests are failing on Jenkins ([#16282](http://projects.theforeman.org/issues/16282), [11d70ff4](http://github.com/katello/katello/commit/11d70ff431db6f48b5e9d27e862751dd45c5d1f2))
 * Make manifest upload link on RH repositories page point to the actual manage manifest page. ([#16078](http://projects.theforeman.org/issues/16078), [069e742a](http://github.com/katello/katello/commit/069e742a1c6e216fc0ad91ad162166033bd824ca))
 * Search functionality stop to work after selecting Activation Key Association tab ([#16033](http://projects.theforeman.org/issues/16033), [8ec1a101](http://github.com/katello/katello/commit/8ec1a101d597e4a5f31be338205d5589b8e12ecd))
 * Free up space in content view version UI ([#15986](http://projects.theforeman.org/issues/15986), [4c02361b](http://github.com/katello/katello/commit/4c02361bb5263ede20f4ccb91236a1cfbc65689b))
 * Red Hat Repositories page not loading ([#15832](http://projects.theforeman.org/issues/15832), [a6008343](http://github.com/katello/katello/commit/a6008343a3e4d054b14377c1df3110824594b418))
 * Cron weekly katello-remove-orphans warnings sending mail ([#15823](http://projects.theforeman.org/issues/15823), [0b7806c6](http://github.com/katello//commit/0b7806c65f7d4aab7f65a16f0de5e6a302f0aadf))
 * Handle 'use latest' correctly when removing puppet modules from CVs ([#15817](http://projects.theforeman.org/issues/15817), [8de4f8a9](http://github.com/katello/katello/commit/8de4f8a9d90f4b7639d9ff20763666a198fa487b))
 * Update katello details page to use bastion nutupane action panel loading screen ([#15545](http://projects.theforeman.org/issues/15545), [1de7a9dd](http://github.com/katello/katello/commit/1de7a9ddec1fcc4c3959077ead8516c5d03ea2cb))
 * Content host details page should be explicit about unregistered clients ([#15456](http://projects.theforeman.org/issues/15456), [e550e639](http://github.com/katello/katello/commit/e550e639babc123a6bc31af446f252b579556138))
 * When search results is zero, message returned is misleading ([#14271](http://projects.theforeman.org/issues/14271), [20bac1b0](http://github.com/katello/bastion/commit/20bac1b067f7b63b6244483da9550dee8ac9352e))
 * guest subscriptions have incorrect link to hypervisor ([#14218](http://projects.theforeman.org/issues/14218), [6eaa32d8](http://github.com/katello/katello/commit/6eaa32d8a1567c14daf3e6259976fc460005ff53))
 * no change in status color when assigning subscription to content host ([#12569](http://projects.theforeman.org/issues/12569), [d31947e0](http://github.com/katello/katello/commit/d31947e0f05e89298e8c718fb84245ef2fc27cd9))

### API
 * Error undefined method inject' for nil:NilClass when no subscriptions are provided to bulk add/remove APi ([#16369](http://projects.theforeman.org/issues/16369), [d684dd81](http://github.com/katello/katello/commit/d684dd8112e3028af911bf9e2af4a02ff48fe526))
 * /api/v2/hosts/:id does not expose content_source_id ([#15697](http://projects.theforeman.org/issues/15697), [e6a7ba59](http://github.com/katello/katello/commit/e6a7ba59f0b3f713d3a7fdf1a20f2ac58cf01702))
 * Do not require organization_id when searching in content_views#index and katello/environments#index ([#15672](http://projects.theforeman.org/issues/15672), [b2640c53](http://github.com/katello/katello/commit/b2640c53d625eaaab0c1bf9908fbd31b669a4149))
 * API ping don't return information for foreman_auth service ([#15582](http://projects.theforeman.org/issues/15582), [95d7b906](http://github.com/katello/katello/commit/95d7b9067d38f269a5ec121fb73b5c19d4422baf))
 * API Missing route /organizations/:orgid/repositories to list all repos in an organization ([#15487](http://projects.theforeman.org/issues/15487), [1de1c034](http://github.com/katello/katello/commit/1de1c034a8f24b026f48e2b16d23c87d8f54a9f2))
 * full_results parameter is improperly defined in the API documentation ([#15420](http://projects.theforeman.org/issues/15420), [49469e2e](http://github.com/katello/katello/commit/49469e2e05d1036351fa1caee2d607b851442dfa))

### Hosts
 * Breaking change in inherited_attributes method  ([#16359](http://projects.theforeman.org/issues/16359), [f4dae3ca](http://github.com/katello/katello/commit/f4dae3ca40e78c0bd4ce6229f73273a252302bd7))
 * strong params filter incorrect for subscription_facet_attributes - cannot update hypervisor_guest_uuids or installed_products ([#16173](http://projects.theforeman.org/issues/16173), [c282e562](http://github.com/katello/katello/commit/c282e562d62efea82212cfb05239ba9a3d06f57e))
 * Unregistering a Content Host can pause ListenOnCandlepinEvents with Candlepin::Consumer: 410 Gone error ([#16170](http://projects.theforeman.org/issues/16170), [883c8066](http://github.com/katello/katello/commit/883c8066488cf12fef0260a26e74107b0a81418c))
 * visiting new host page has js error of "KT is not defined" ([#15512](http://projects.theforeman.org/issues/15512), [2ab1d40b](http://github.com/katello/katello/commit/2ab1d40bc5ba8fd0e63f6b5061b2d133a4ba0cb0))
 * Helper rake tasks not fully updated for Host Unification and Scoped search ([#15721](http://projects.theforeman.org/issues/15721), [5f624ad3](http://github.com/katello/katello/commit/5f624ad37bfefbd7ebde9b37d7bc8a2187e79a83))

### Content Views
 * Unpublished content views displayed in the content view list on the composite content view page [Web/UI] ([#16346](http://projects.theforeman.org/issues/16346), [eb439b09](http://github.com/katello/katello/commit/eb439b0960d215acab5345e002a524d21a1247ed), [a5ccff01](http://github.com/katello/katello/commit/a5ccff015609ab28169b5bc7d9bf33e75ea4f276))
 * Do not wrap description field in the Content View version listing ([#16331](http://projects.theforeman.org/issues/16331), [1e332614](http://github.com/katello/katello/commit/1e3326148f5e1abafc8101b4bb65f9ede807f730))
 * The "Remove View" button for deleting a content view should say "Delete View" to match the confirmation submit button ([#16271](http://projects.theforeman.org/issues/16271), [b5e80512](http://github.com/katello/katello/commit/b5e805123365f9c8da66555076367ac09ac1fcfa))
 * User shouldn't be allowed to add same package in content-view filter repeatedly ([#16186](http://projects.theforeman.org/issues/16186), [a43dc492](http://github.com/katello/katello/commit/a43dc492bd1a2cf4c112a6ebd2ca6c84de078e45))
 * Probably should condense the list of puppet modules (and maybe other associations) for content view info ([#15987](http://projects.theforeman.org/issues/15987), [dd4aaadf](http://github.com/katello/hammer-cli-katello/commit/dd4aaadf5f7408b93f0c4416543b044129611c28))
 * Cannot delete a RedHat Product or Products with Repositories published in a Content View error does not help user ([#15811](http://projects.theforeman.org/issues/15811), [63d1d08f](http://github.com/katello/katello/commit/63d1d08f6168d26f14f61a8814506769727a50ef))
 * hammer content-view version list ignores --organization{-id} options ([#15796](http://projects.theforeman.org/issues/15796), [8e39aac8](http://github.com/katello/katello/commit/8e39aac83584c0b6c795d91f9e168da7bac1c4ef), [c2956945](http://github.com/katello/hammer-cli-katello/commit/c2956945752778f54251d50c51670af319a65d07))
 * Not able to select/publish " Use Latest Version" of puppet module in content view ([#15579](http://projects.theforeman.org/issues/15579), [57eaec9b](http://github.com/katello/katello/commit/57eaec9b6b8e821c05d519824491598ff9a361b6))

### Atomic
 * Containers hosted on Atomic host not able to access Katello yum repos ([#16343](http://projects.theforeman.org/issues/16343))

### Foreman Integration
 * need script to unify hosts with shortname and fqdn ([#16270](http://projects.theforeman.org/issues/16270), [3fb17a34](http://github.com/katello/katello/commit/3fb17a34452cc5e3f8d012d8b305c99804e5bb49))
 * host status .relevant? deprecation warning ([#15398](http://projects.theforeman.org/issues/15398), [6cc8e2f6](http://github.com/katello/katello/commit/6cc8e2f64fbb96e82c71ad4cc56f6ec2608eb440))
 * Remove System and Hypervsior models/controllers/tests/actions ([#12556](http://projects.theforeman.org/issues/12556), [f5dcf970](http://github.com/katello/katello/commit/f5dcf97068fd119ce7afd226d8d95c23c0c5a1b4), [df4bc4d7](http://github.com/katello/katello/commit/df4bc4d7d6a59cc85d6c2acdcaa27965bab3b5ac), [440b51d5](http://github.com/katello/katello/commit/440b51d54a020885d2680ce9edeef01b477a28b4), [37fa1d79](http://github.com/katello/hammer-cli-katello/commit/37fa1d7951bb3dceb3adf5a626d53416e379bcaa))

### Tests
 * Tests are failing with 'LoadError: cannot load such file -- polyglot' ([#16213](http://projects.theforeman.org/issues/16213), [1ce49302](http://github.com/katello/katello/commit/1ce49302b1698a79da76d03de0f1c96dd02caef4))
 * Test failures under Rails 4.2.7.1 ([#16088](http://projects.theforeman.org/issues/16088), [db95d867](http://github.com/katello/katello/commit/db95d8676965d81cb5df35951d8f9edf117785e7))
 * Reduce warnings when running katello tests ([#15588](http://projects.theforeman.org/issues/15588), [4e5d97dc](http://github.com/katello/katello/commit/4e5d97dc73dc3e291d251b91fee215ff87e0d1dd))
 * katello_fixtures directory not cleaned up in /tmp ([#15042](http://projects.theforeman.org/issues/15042), [f3713906](http://github.com/katello/katello/commit/f37139069e84bd70d99b9c99477355d223b45f4c))

### Activation Key
 * attaching subscription to an activation key causes UI error ([#16189](http://projects.theforeman.org/issues/16189), [db12c23b](http://github.com/katello/katello/commit/db12c23bc7b03037aee88bb533487d1d33690979))

### Capsule
 * Capsule auto-synchronization fails with an error 'PLP0034' (Katello::Errors::PulpError ) after publishing content view on satellite 6.2.0 ([#16177](http://projects.theforeman.org/issues/16177), [fd79377c](http://github.com/katello/katello/commit/fd79377cd1577177ce4f89629569ec9578ef1574))
 * Pulp storage error ([#16064](http://projects.theforeman.org/issues/16064), [2bb06e19](http://github.com/katello//commit/2bb06e191813ae14ed0b9400b15e6b0a66e2bb06))

### Subscriptions
 * Add API Bulk Actions for add/remove/auto-attach subscriptions ([#16038](http://projects.theforeman.org/issues/16038), [e51d11fe](http://github.com/katello/katello/commit/e51d11fe0491d76ae8a149242bece9d9f6936f7f))
 * hammer activation-key add-subscription/host subscription attach must accept pool ids ([#16036](http://projects.theforeman.org/issues/16036), [a66ae300](http://github.com/katello/katello/commit/a66ae300e96c40146569f82a7a06ed32df4c5127))
 * Package upload action logs whole input as Parameters ([#15940](http://projects.theforeman.org/issues/15940), [59e9f514](http://github.com/katello/katello/commit/59e9f514afaf79b179e3ee08de122aa1db037494))

### Docker
 * Enable katello docker registries to use other ports ([#16037](http://projects.theforeman.org/issues/16037), [7be5d7f2](http://github.com/katello/katello/commit/7be5d7f2540b9e60ca0e92b604a275e632f11bc9))
 * docker tag view page shows empty alert ([#15759](http://projects.theforeman.org/issues/15759), [a78a3ee8](http://github.com/katello/katello/commit/a78a3ee8fee2ed651f6635346c4d777063606c5c))

### Tooling
 * Carry patched version of urrlib3 for lazy sync ([#15982](http://projects.theforeman.org/issues/15982), [b60f4e83](http://github.com/katello//commit/b60f4e8362a66c7864d01c2c10c0c4ff77f30dbe))

### Upgrades
 * upgrade_check fails because of running tasks ([#15945](http://projects.theforeman.org/issues/15945), [a0aeaa25](http://github.com/katello/katello/commit/a0aeaa2517396ef19f92c17d78eb0d3f77a81732))
 * Apache has 7x number of open files on capsule with satellite 6.2 compare to satellite 6.1 ([#15841](http://projects.theforeman.org/issues/15841), [b4ed05ec](http://github.com/katello/puppet-katello/commit/b4ed05ec849864e1b009733f20add03647de7b07))
 * upgrade_check does not correctly determine active tasks ([#15694](http://projects.theforeman.org/issues/15694), [d12e6e67](http://github.com/katello/katello/commit/d12e6e67f8706787f95546e90b4d38865639d669))
 * update_subscription_facet_backend_data step fails on upgrade ([#16117](http://projects.theforeman.org/issues/16117), [dfa26d40](http://github.com/katello/katello/commit/dfa26d40266c2ce59e607077b16c67d9ebda239f))
 * hypervisors are deleted upon upgrade to 3.0 ([#15726](http://projects.theforeman.org/issues/15726), [93a2d186](http://github.com/katello/katello/commit/93a2d186408240489d0402cd331f52f9cd7e77b5))
 * Error rendering info message in migration due to missed escaping ([#15683](http://projects.theforeman.org/issues/15683), [70e6cf78](http://github.com/katello/katello-installer/commit/70e6cf784b4e31564ca18dad795ea806efaa18a1))
 * Upgrade from Katello 3.0 to Katello 3.1 fails on apipie:cache task ([#16441](http://projects.theforeman.org/issues/16441), [a812f1f1](http://github.com/katello/katello/commit/a812f1f1a52d0da71ae73e627bf92f6b94748546))

### Dashboard
 * Content dashboard has wrong links to [Invalid|Insufficient|Current] Subscriptions ([#15941](http://projects.theforeman.org/issues/15941), [73cc4243](http://github.com/katello/katello/commit/73cc424308075f67dcacf39951a0cd39a6685733))

### Candlepin
 * Katello not receiving messages from candlepin ([#15727](http://projects.theforeman.org/issues/15727), [72ad0375](http://github.com/katello/puppet-katello/commit/72ad037539160bb420ed446ff769af6ddc9ab041))
 * virt-who checkin should use default org view and should not overwrite existing registration ([#15725](http://projects.theforeman.org/issues/15725), [6a9661b5](http://github.com/katello/katello/commit/6a9661b5822986ff255631117626145845b81b22))
 * Deleting a product with multiple repos results in candlepin error ([#15482](http://projects.theforeman.org/issues/15482), [7e64292a](http://github.com/katello/katello/commit/7e64292a0d632a51f887d025cdbecb15f0894158))
 * undefined method [] for nil:NilClass related to activation_key pool association ([#15749](http://projects.theforeman.org/issues/15749), [946f3c77](http://github.com/katello/katello/commit/946f3c771d16ca0491b765fc34d222728364b90f))
 * VDC guest subscriptions showing as null in activation key  ([#16398](http://projects.theforeman.org/issues/16398), [fe268976](http://github.com/katello/katello/commit/fe2689762e888eed40fb3f897cd691185ab15488))

### Roles and Permissions
 * 03-roles.rb seeds katello view_* filters for Viewer role multiple times ([#15427](http://projects.theforeman.org/issues/15427), [7c71d45d](http://github.com/katello/katello/commit/7c71d45dadedbe262d0d2866db69a3f83b52085a))

### Pulp
 * Out of Memory error while syncing repo ([#15101](http://projects.theforeman.org/issues/15101))
 * incremental export should be in same format as full export ([#14915](http://projects.theforeman.org/issues/14915), [b261110a](http://github.com/katello/katello/commit/b261110a5fc2eb6aa37d9981b6bc644c020b3542))
 * Users should be warned during upgrade of long running Pulp migrations ([#15660](http://projects.theforeman.org/issues/15660), [ba43845f](http://github.com/katello/katello-installer/commit/ba43845ff5f45706200b7c6b933e0b8cde14b008))
 * Errata Install to Content Host takes too long and doesn't scale well ([#15366](http://projects.theforeman.org/issues/15366), [ab45b88e](http://github.com/katello//commit/ab45b88ed48c522be6b8a97462fc02cd18e61c50))

### Orchestration
 * ListenOnCandlepinEvents pauses during manifest import ([#15648](http://projects.theforeman.org/issues/15648), [66e98cb7](http://github.com/katello/katello/commit/66e98cb7560420741bf795d2fd4682655af09594))
 * katello 3.0 RC failing content promotion but can be resumed manually ([#15428](http://projects.theforeman.org/issues/15428))

### Other
 * Cannot create new hostgroup via API/CLI ([#16484](http://projects.theforeman.org/issues/16484), [5608b835](http://github.com/katello/katello/commit/5608b835b01dbe39cbea48ffad11396c83fd684d))
 * katello-installer - exclude build dirs from from rubocop checking ([#16469](http://projects.theforeman.org/issues/16469), [1e99296f](http://github.com/katello/katello-installer/commit/1e99296f9129ce45cbf7835a06613a0cb6e581f1))
 * Large files can't be uploaded through content upload APIs ([#16429](http://projects.theforeman.org/issues/16429), [68c5d7d1](http://github.com/katello/katello/commit/68c5d7d13d2337ed03658bd96742af3e1241a166))
 * katello-service tool is missing smart_proxy_dynflow_core ([#16373](http://projects.theforeman.org/issues/16373), [d323d1c3](http://github.com/katello//commit/d323d1c31c1f63276996a515f6dc8a6132a2c594))
 * Cannot create new organization via the web ui ([#16304](http://projects.theforeman.org/issues/16304), [f867be09](http://github.com/katello/katello/commit/f867be09164e9d2b27956fc51f1f1c4dfa847f76))
 * Add description of remove-content to hammer repository help ([#16247](http://projects.theforeman.org/issues/16247), [28ba5d4f](http://github.com/katello/hammer-cli-katello/commit/28ba5d4f38f424745ec8134f0189ebb8c2d76b15))
 * Incorrect Next Sync date calculation in weekly Sync Plan ([#16035](http://projects.theforeman.org/issues/16035), [08e85148](http://github.com/katello/katello/commit/08e851485c73e7a51fcc87de2f422f7c0cbb4aa0))
 * Adjust coverage settings in Katello ([#15998](http://projects.theforeman.org/issues/15998), [6fce27a8](http://github.com/katello/katello/commit/6fce27a88e01c5b627655d579a0b8668f9c6f89c))
 * Autocomplete is not working. ([#15917](http://projects.theforeman.org/issues/15917), [6c5b6f1e](http://github.com/katello/katello/commit/6c5b6f1e34b3e2d4038fa4fad0ffcdd554973a36))
 * Content view version in progress tasks should take me to the task itself ([#15892](http://projects.theforeman.org/issues/15892), [935afb3f](http://github.com/katello/katello/commit/935afb3f05041362cd63854fb911b9eeb0736f26))
 * capsule pulp disk usage is not available on rhel6 ([#15673](http://projects.theforeman.org/issues/15673), [71b1a3b4](http://github.com/katello//commit/71b1a3b463358592633e9ba1b628e45f9aeb37db))
 * New hammer host-collection hosts command does not expose any options ([#15429](http://projects.theforeman.org/issues/15429), [8a8057e2](http://github.com/katello/hammer-cli-katello/commit/8a8057e2ac41a5bb18a528f003aac440792f2306))
 * Add a Readme for test/data directory on how to generate JSON api ([#15305](http://projects.theforeman.org/issues/15305), [1e876e57](http://github.com/katello/hammer-cli-katello/commit/1e876e5755f75ef0b5921825187894a01baa436e))
 * migrate_content_hosts fails with unique constraint violation  ([#16137](http://projects.theforeman.org/issues/16137), [7c6a0017](http://github.com/katello/katello/commit/7c6a00174bb9621acc3fa01314b1375d73991203))
 * No proper subscriptions created for custom products ([#15981](http://projects.theforeman.org/issues/15981), [54c453cd](http://github.com/katello/katello/commit/54c453cdff9f80b200f8939dae3f38809d073e46))
 * Migrate shouldn't ping backends when there are no systems present ([#15826](http://projects.theforeman.org/issues/15826), [f70b73a8](http://github.com/katello/katello/commit/f70b73a8bd0962fa256bf129b5f14990919fc9b5))
 * sync and publish emails are never sent ([#16303](http://projects.theforeman.org/issues/16303), [319c4650](http://github.com/katello/katello/commit/319c4650c8e4a93ae1cd2f06f1481201b8ae5fe4))
