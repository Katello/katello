# 2.3 Berliner Weisse (2015-08-20)

## Features 

### Packaging
 * add task export to foreman-debug ([#10820](http://projects.theforeman.org/issues/10820), [6c95126d](http://github.com/katello/katello/commit/6c95126d1735a4fb6803f9cd02ddc103586dd730))

### Installer
 * Need a better rake katello:reindex  ([#10724](http://projects.theforeman.org/issues/10724), [7e246b83](http://github.com/katello/katello/commit/7e246b8341bfce91035f1e31d0746e253cd227e8))
 * installer check for underscores in hostname ([#10175](http://projects.theforeman.org/issues/10175), [5621fa77](http://github.com/katello/katello-installer/commit/5621fa77a6f6e110519cd60d9b8d1a51d67dc622))
 * As a developer, I would like the puppet modules to meet a minimum of 4.0 out of 5.0 on Puppet Forge's quality score ([#9207](http://projects.theforeman.org/issues/9207))
 * Install katello-selinux package via the installer ([#9129](http://projects.theforeman.org/issues/9129))

### Database
 * remove provider from elasticsearch ([#10570](http://projects.theforeman.org/issues/10570), [2bc486b4](http://github.com/katello/katello/commit/2bc486b4e898d5869d9327e22e1b3a3651723f81))

### Web UI
 * Allow users to search content view versions by fields like version, and perhaps repository and environment ([#10551](http://projects.theforeman.org/issues/10551), [a7e8ad4c](http://github.com/katello/katello/commit/a7e8ad4c7adcbbce30cc37f73653aa3aa8eca6f4))
 * As a SAM user, I wish the About page to hide "System Status" portions ([#8204](http://projects.theforeman.org/issues/8204))
 * As a SAM user, I wish to remove Location references everywhere. ([#8202](http://projects.theforeman.org/issues/8202))
 * As a SAM user, I wish to hide the host relation on the content host pages. ([#8201](http://projects.theforeman.org/issues/8201))
 * As a SAM user, I wish to hide permission resources that are not applicable. ([#8200](http://projects.theforeman.org/issues/8200))
 * As a SAM user, I wish to hide resources on the organization edit page that are not applicable. ([#8199](http://projects.theforeman.org/issues/8199))
 * As a SAM user, I wish to see only settings that are applicable. ([#8198](http://projects.theforeman.org/issues/8198))
 * As a SAM user, I wish to create an organization w/o the "associate hosts" step. ([#8197](http://projects.theforeman.org/issues/8197))
 * As a SAM user, I wish to only see appropriate menus. ([#8196](http://projects.theforeman.org/issues/8196))
 * UI for viewing applicable environments or content views an errata applies to ([#8189](http://projects.theforeman.org/issues/8189))
 * activation keys UI - missing reference list ([#5517](http://projects.theforeman.org/issues/5517))

### Documentation
 * Document new Capsule Isolation features ([#9292](http://projects.theforeman.org/issues/9292), [45304fc2](http://github.com/katello/katello.org/commit/45304fc2ac6b2ac59adbe37902235ac624e1204b))

### SElinux
 * Isolated capsule should work while confined by SELinux ([#9143](http://projects.theforeman.org/issues/9143))

### CLI
 * add hammer_cli_foreman_bootdisk package ([#8680](http://projects.theforeman.org/issues/8680), [ec93e133](http://github.com/katello/hammer-cli-katello/commit/ec93e133986361d1366df587d38d02bf3be1f22e))

### Docker
 * Extend or disable the docker api from foreman-docker ([#8562](http://projects.theforeman.org/issues/8562))
 * Need a way to update docker tags in runcible ([#8079](http://projects.theforeman.org/issues/8079))
 * As a UI user, I want to view docker content for a content view ([#7807](http://projects.theforeman.org/issues/7807))
 * As a user, I want to promote content views with docker repos ([#7792](http://projects.theforeman.org/issues/7792))
 * As a user, I want to publish content views with docker repos ([#7789](http://projects.theforeman.org/issues/7789))

### Dynflow
 * API for remote action history ([#8249](http://projects.theforeman.org/issues/8249))

### Other
 * As a user of a disconnected Satellite, I'd like to change my disconnected Satellite to a connected one. ([#10950](http://projects.theforeman.org/issues/10950), [8dca6238](http://github.com/katello/katello/commit/8dca623812b7b0895e90d45988916e99296df5f7))
 * Add katello-installer customization of mongodb path ([#10885](http://projects.theforeman.org/issues/10885))
 * Add dependencies for hammer_cli_foreman_docker ([#9728](http://projects.theforeman.org/issues/9728), [09090036](http://github.com/katello/hammer-cli-katello/commit/0909003628cd5c14bf0b17f042a6e9f823890df8))
 * Foreman gutterball needs to generate reports ([#9154](http://projects.theforeman.org/issues/9154))
 * Add a remove-content command to the CLI ([#8511](http://projects.theforeman.org/issues/8511), [74efbfb1](http://github.com/katello/hammer-cli-katello/commit/74efbfb101887da4fcc4c6432f7d639647d56c7f))

## Bug Fixes 

### Pulp
 * pulp_celerybeat pulp_resorce_manager fail to start on boot. ([#11411](http://projects.theforeman.org/issues/11411))
 * Timeout requesting rpm_ids from pulp during sync/publish/promote ([#10107](http://projects.theforeman.org/issues/10107))

### Web UI
 * Having no applicable Errata does not hint to uncheck applicable ([#11330](http://projects.theforeman.org/issues/11330), [7e2c1530](http://github.com/katello/katello/commit/7e2c1530d7153deab7e996748a2ba9006ebb2b0e))
 * syncing content the second time throws traceback in production.log ([#11183](http://projects.theforeman.org/issues/11183), [9cb7ac3c](http://github.com/katello/katello/commit/9cb7ac3c33c84b605602efb83b1076c8aab5006f))
 * Duplicate erratas are displayed which causes the errata apply to fail ([#11117](http://projects.theforeman.org/issues/11117), [33e5f194](http://github.com/katello/katello/commit/33e5f19468c7432d0cfd484e2cfbc7a466089737))
 * Incremental update on more than one content host fails ([#11075](http://projects.theforeman.org/issues/11075), [5bfc23dd](http://github.com/katello/katello/commit/5bfc23ddf157d8cf55dd793c62a329043e87e9ed))
 * Repo Discovery - Existing product not listed to create discovered repo within. ([#11026](http://projects.theforeman.org/issues/11026), [810d954f](http://github.com/katello/katello/commit/810d954f6a07a298684f25305e18d785108644cf))
 * products dissappear after browser refresh ([#10922](http://projects.theforeman.org/issues/10922), [c0281116](http://github.com/katello/katello/commit/c02811168b721704d64f26dcf5ffde40fe0c2212))
 * Incremental Update: Selected content hosts are not recognized ([#10904](http://projects.theforeman.org/issues/10904), [b1f0448a](http://github.com/katello/katello/commit/b1f0448a1755e3526a201a3d81251d2458fb330c))
 * Incremental update displays errata counts but calls it Host count ([#10839](http://projects.theforeman.org/issues/10839))
 * Can't completely delete a version of content view ([#10822](http://projects.theforeman.org/issues/10822), [7aa362ca](http://github.com/katello/katello/commit/7aa362ca546252643accbb5f4536c2a7c9ccd32e))
 * Docker tag published at information should not contain uppercase chars or not valid docker image name chars ([#10804](http://projects.theforeman.org/issues/10804), [c31947ce](http://github.com/katello/katello/commit/c31947ce81c73496bf4aaf2728a97d7eaec9746d))
 * Overlap in Content view -> Versions -> Packages ([#10798](http://projects.theforeman.org/issues/10798), [3767dd6c](http://github.com/katello/katello/commit/3767dd6c0667b1ae0a66e2b8647588e9c32be363))
 * Content Dashboard -> Setting button doesnt work ([#10786](http://projects.theforeman.org/issues/10786), [e62b1180](http://github.com/katello/katello/commit/e62b118070a3c37097fdb940bda4978577bd198d))
 * Duplicated notifications for Content View actions ([#10775](http://projects.theforeman.org/issues/10775), [25f51201](http://github.com/katello/katello/commit/25f512010f3d96c8ec832f1229f703f5410c371f))
 * Content host -> errata tab: Not all applicable errata shown from my Library ([#10774](http://projects.theforeman.org/issues/10774), [acf17478](http://github.com/katello/katello/commit/acf174784db0d3a37a0ff4518d603a823553f540))
 * Defining discovery rule with "organization =  under search raises 500 ISE in production.log ([#10735](http://projects.theforeman.org/issues/10735), [d73f191e](http://github.com/katello/katello/commit/d73f191e389c0165ee3e0005c934f1aa2fa79aed))
 * Incremental Update: Unable to filter my content hosts with environment if the selected errata contains atleast one installable errata ([#10705](http://projects.theforeman.org/issues/10705), [881198cd](http://github.com/katello/katello/commit/881198cd4da2c491d9c7362dbeefd030dc6a370f))
 * Incremental update screenshot showing incorrect text info ([#10704](http://projects.theforeman.org/issues/10704), [ca7ac75d](http://github.com/katello/katello/commit/ca7ac75ddecd69989dc11ae7c7df45ee4b052277))
 * Content View Promote Fails with Katello::Errors::CandlepinError ([#10697](http://projects.theforeman.org/issues/10697), [c2aa177c](http://github.com/katello/katello/commit/c2aa177c3ae76a02bfaa1071a65628e32e332626))
 * Installable errata is not listed in Content -> Errata page ([#10681](http://projects.theforeman.org/issues/10681), [fcd7bcc8](http://github.com/katello/katello/commit/fcd7bcc806015514fc76215597d393d985919da3))
 * could not update gpg-key, UI raises red-cross without any error and logs says unsupported media type ([#10671](http://projects.theforeman.org/issues/10671), [81af74b5](http://github.com/katello/katello/commit/81af74b5d97818a6345c4fc9544a3b2b834ec37b))
 * hammer: Activation key name update claims to run without error but did not really update the name ([#10669](http://projects.theforeman.org/issues/10669), [c78f11a0](http://github.com/katello/katello/commit/c78f11a0ebadda49780e43b5f8543eb74b6d3c64))
 * UI shows 3 entries of same product under CV --> Version -> yum_repositories ([#10640](http://projects.theforeman.org/issues/10640), [27b6d7cf](http://github.com/katello/katello/commit/27b6d7cf208272d10c313e1e85beaee803639568))
 * Incremental updates broken ([#10631](http://projects.theforeman.org/issues/10631), [863ed70a](http://github.com/katello/katello/commit/863ed70a984865a8792991150b37a83d4c4aab2c))
 * Need way to promote latest version of Content View to next environment via hammer ([#10623](http://projects.theforeman.org/issues/10623), [35cbd6fd](http://github.com/katello//commit/35cbd6fd566b7d13faaa7eb2dd0158a13128f10b))
 * Duplicated content listed as available for inclusion ([#10617](http://projects.theforeman.org/issues/10617), [38420e5e](http://github.com/katello/katello/commit/38420e5e1d330ddbbaf1ae4b8b5f1840bee7e394))
 * Deleted product repos has been listed under Operating system-> Installation Media to select. ([#10601](http://projects.theforeman.org/issues/10601), [acb2e52a](http://github.com/katello/katello/commit/acb2e52a38ee9fd4566c4a44d394d4b4331a9ee0))
 * Clicking on product hyperlinks in Errata -> Repositories page fails ([#10540](http://projects.theforeman.org/issues/10540), [20276b15](http://github.com/katello/katello/commit/20276b15b5ff555e0f26d27b85f9111b46324eec))
 * Content Hosts > Subscriptions: Switching between "List/Remove" and "Add" doesn't toggle right/leads to off-by-one ([#10537](http://projects.theforeman.org/issues/10537), [254542f5](http://github.com/katello/katello/commit/254542f5bb82cf5fcf840b3d1a00664dd44541c0))
 * Webui -> Monitor -> Content Dashboard does not load ([#10525](http://projects.theforeman.org/issues/10525), [265bf603](http://github.com/katello/katello/commit/265bf6037b6b0173d99a88d8750a0653dbd4756b))
 * Can't compare 2 content views ([#10498](http://projects.theforeman.org/issues/10498), [26768c83](http://github.com/katello/katello/commit/26768c83fde27118e32342c468ffa7e05bbbf7b6))
 * Content Views list for Lifecycle Environment throws error and won't load ([#10488](http://projects.theforeman.org/issues/10488), [266f883c](http://github.com/katello/katello/commit/266f883c69fb9b43bc6c6520277d82eb2c74e3a9))
 * Better display metadata sync issues (404/403) to users ([#10396](http://projects.theforeman.org/issues/10396), [61d1d1d3](http://github.com/katello/katello/commit/61d1d1d3770f699d491d47b9cb948b4c4ae3172e))
 * Searching an errata with issued date displays incorrect results ([#10383](http://projects.theforeman.org/issues/10383), [e44c303a](http://github.com/katello/katello/commit/e44c303adf35789077b9d15148c9c423cfdf46d0))
 * Attempting to display the content hosts that have the errata in their life cycle environment failed ([#10308](http://projects.theforeman.org/issues/10308), [9f2797e3](http://github.com/katello/katello/commit/9f2797e3d9540b548e499f714773ead424e1932f))
 * Red Hat Repositories displayed even after successful deletion of manifest. ([#10281](http://projects.theforeman.org/issues/10281), [db9cbcc5](http://github.com/katello/katello/commit/db9cbcc5a234299953fe85296ead507c9157871b))
 * externally cancelled pulp tasks are treated as successful ([#10249](http://projects.theforeman.org/issues/10249), [d5ad3e7d](http://github.com/katello/katello/commit/d5ad3e7d451968bfbe28adc3cc35e93434299411))
 * attaching subscription to guest: "Unable to build object from JSON." ([#10246](http://projects.theforeman.org/issues/10246), [9f716307](http://github.com/katello/katello/commit/9f716307d1e4d812b1a7d0b232bcfe0f32e173d2))
 * content search render issues on Firefox ([#10227](http://projects.theforeman.org/issues/10227), [148f8be0](http://github.com/katello/katello/commit/148f8be0faa0791c327a709279fe2b6222506dcb))
 * Allow sync-plan to change sync-date in WebUI ([#10140](http://projects.theforeman.org/issues/10140), [f614d6b6](http://github.com/katello/katello/commit/f614d6b6ef23dac73580c46ddbb13ab9cc48ef77))
 * 414 Request URI too long when attempting to perform an incremental update on a large amount of errata ([#10011](http://projects.theforeman.org/issues/10011), [9b270778](http://github.com/katello/katello/commit/9b270778a439882b07ade7c9ba55de211295f648))
 * Apply Errata page shows wrong informational text ([#9992](http://projects.theforeman.org/issues/9992), [bd1edf25](http://github.com/katello/katello/commit/bd1edf250927043a9d6bf202556a4f2db80e2947))
 * Clicking on Errata count URLs on Content host details page shows incorrect errata ([#9933](http://projects.theforeman.org/issues/9933), [ec439607](http://github.com/katello/katello/commit/ec439607b407f4c862eb89e3f7a6124b8f2dabc0))
 * errata listing UI page jumbled ([#9927](http://projects.theforeman.org/issues/9927), [91a91efa](http://github.com/katello/katello/commit/91a91efab12811003ff9734e40201ddcbc8759f9))
 * content view history always blank ([#9924](http://projects.theforeman.org/issues/9924), [e5e4d70e](http://github.com/katello/katello/commit/e5e4d70ec1600d10b70192539fb51b909e13223f))
 * typo in subscription-products.html ([#9922](http://projects.theforeman.org/issues/9922), [2d0c8a54](http://github.com/katello/katello/commit/2d0c8a546b65b74e9ba53867a99fd76919f5f605))
 * Installable errata count wrong if you have multiple content hosts with different CVs ([#9913](http://projects.theforeman.org/issues/9913), [447fd26e](http://github.com/katello/katello/commit/447fd26e11e6a573d74ba4d48c65f106b330da6c))
 * Content Host registration should be more explicit in mentioning Organization and Activation key ([#9898](http://projects.theforeman.org/issues/9898), [c375db31](http://github.com/katello/katello/commit/c375db31b988918b37d740bfe9abf8f059bac758))
 * Trying to remove a content view indicates "affected hosts" that do not use said CV ([#9890](http://projects.theforeman.org/issues/9890), [b27e0a42](http://github.com/katello/katello/commit/b27e0a422acf2d81475af5c806798f3b11c0f228))
 * When editing activation key, some fields have an X next to edit button ([#9889](http://projects.theforeman.org/issues/9889), [e3563489](http://github.com/katello/katello/commit/e356348900ac6bbe0d3b82df1e8420e2eb675934))
 * Badly marked translations for loading subscriptions loading screens ([#9796](http://projects.theforeman.org/issues/9796), [b30b239f](http://github.com/katello/katello/commit/b30b239feb466b19d4a0c4a5d1453a61dfc871ae))
 * WebUI: the pop-up msgbox show null when unregister content hosts ([#9792](http://projects.theforeman.org/issues/9792), [540dc0ce](http://github.com/katello/katello/commit/540dc0ceef19556213ce74170163eab1e94ed4da))
 * UI should raise tool-tip to select CV on env selection, while editing the key which was created without env and CV ([#9790](http://projects.theforeman.org/issues/9790), [c86a6ab9](http://github.com/katello/katello/commit/c86a6ab9c308091dea335f8bff68720770420a85))
 * Search does not work on Content host errata tab ([#9786](http://projects.theforeman.org/issues/9786), [c063ff97](http://github.com/katello/katello/commit/c063ff97c7882b57bd6330a8e28ae19c2391594e))
 * Content Dashboard - Errata overview shows duplicate errata entries ([#9783](http://projects.theforeman.org/issues/9783), [58ef4139](http://github.com/katello/katello/commit/58ef41391f26f56a62dca14ee28bf3b97ca136bc))
 * wrong permission check for deleting products ([#9739](http://projects.theforeman.org/issues/9739), [be66aa55](http://github.com/katello/katello/commit/be66aa5573da166709a8c63ead9b0e2a097c0150))
 * No UI confirmation on updating filter name ([#9731](http://projects.theforeman.org/issues/9731), [87873e83](http://github.com/katello/katello/commit/87873e8374dcf23468ee9bc2cafc27f4d9df9162))
 * Content View versions page is not showing user info when empty ([#9730](http://projects.theforeman.org/issues/9730), [c69bc8bc](http://github.com/katello/katello/commit/c69bc8bc9939b10a2c8661ebba44c1f275058726))
 * content host name overlaps with subscription status in activation key page ([#9698](http://projects.theforeman.org/issues/9698), [49ba6e7d](http://github.com/katello/katello/commit/49ba6e7df73b55d552335c0e21a59219320e6094))
 * User Confirmation window does not go away when attempting to apply errata via content host bulk actions ([#9697](http://projects.theforeman.org/issues/9697), [59bcb8d5](http://github.com/katello/katello/commit/59bcb8d5ccc488433aa5c05b2a1cdd37313a9cb0))
 * Provide meaningful options for Activation key - Product Content override ([#9681](http://projects.theforeman.org/issues/9681), [32da9fa0](http://github.com/katello/katello/commit/32da9fa0d398bb83a33d9575f7c9ae1f264e27d3))
 * [RFE] Content hosts -> Errata tab: Add helptext to inform Applicable errata cannot be applied ([#9670](http://projects.theforeman.org/issues/9670), [e077aa1b](http://github.com/katello/katello/commit/e077aa1b15c639a98f2ae9e8e59007ebd5f55a5b))
 * Email notification - Katello Sync Summary - New Errata section hyperlinks does not work ([#9664](http://projects.theforeman.org/issues/9664), [145b398e](http://github.com/katello/katello/commit/145b398efc626603b74adcb759649d24ac5f7214))
 * Incremental update task should list the packages in an alphatetical order ([#9626](http://projects.theforeman.org/issues/9626), [fb81aedb](http://github.com/katello/katello/commit/fb81aedb1fe71ad75c882842f641d215c9b97e7f))
 * Javascript error on content host errata search ([#9528](http://projects.theforeman.org/issues/9528), [7aca8071](http://github.com/katello/katello/commit/7aca80715bc20c915e65095e7a355d0326c06af9))
 * Content View removal does not properly update the content view list ([#9401](http://projects.theforeman.org/issues/9401), [33a8a25b](http://github.com/katello/katello/commit/33a8a25b4b1396879f8c45109bdb7259dd5b3ca3))
 * package name matching in content search requires wildcard ([#6614](http://projects.theforeman.org/issues/6614))

### Foreman Integration
 * Operating System created for Satellite server does not have partition table or templates assigned ([#11322](http://projects.theforeman.org/issues/11322), [5befbde7](http://github.com/katello/katello/commit/5befbde7e1ee7fface3ad83c2904a711bd6c38ba))
 * select2 screws up all our overrides ([#11296](http://projects.theforeman.org/issues/11296), [93ab5431](http://github.com/katello/katello/commit/93ab54314f479dedb9b082d13968bcd116e24447))
 * sync plans can be created and assigned, but don't trigger syncs ([#11292](http://projects.theforeman.org/issues/11292))
 * rendered kickstarts do not include ks url when content view is used ([#11195](http://projects.theforeman.org/issues/11195), [63de0095](http://github.com/katello/katello/commit/63de00950db0e9eea42fb4155f8cd5d47bebf230))
 * Kickstart template on rhel5 includes --device=MAC ([#10614](http://projects.theforeman.org/issues/10614), [72ac9eaa](http://github.com/katello/katello/commit/72ac9eaaecb6d3c44e655ee85a532a626e3a0141))

### Content Views
 * UI: Unable to add component content view to a composite view ([#11264](http://projects.theforeman.org/issues/11264), [344e8126](http://github.com/katello/katello/commit/344e81260807430a738bdbb5e89e63a8c41271d1))
 * I can't re-promote a content view if it's in the last environment of a path ([#10351](http://projects.theforeman.org/issues/10351), [5b2db62a](http://github.com/katello//commit/5b2db62a2a24e48eaa3b81b982ce066285c67e78), [0df00b98](http://github.com/katello/katello/commit/0df00b988138c3f8572af454ffa5a4d2cb1599df))
 * in order to specify package exactly in a content view filter, both release and version must be accepted ([#6599](http://projects.theforeman.org/issues/6599))

### Installer
 * Reindex needs to handle bad errata and package/packagegroups etc ([#11140](http://projects.theforeman.org/issues/11140), [7d353896](http://github.com/katello/katello/commit/7d3538960c882b1126d610b8548aecb4ab9b1b91))
 * katello-devel-installer seg faults on EL6 ([#10680](http://projects.theforeman.org/issues/10680), [eb0657b3](http://github.com/katello/katello-installer/commit/eb0657b3db97b3cccecaf2d1b5f56bdd06278d8e))
 * Make --capsule-templates option true by default ([#10675](http://projects.theforeman.org/issues/10675), [db730f33](http://github.com/katello//commit/db730f332ae13992e5fefc441485a35dc49e7bf6))
 * Install will occasionally fail on virtual machines ([#10654](http://projects.theforeman.org/issues/10654))
 * katello-installer capsule module does not expose dhcp_option_domain dhcp parameter ([#10599](http://projects.theforeman.org/issues/10599))
 * katello-devel-installer complains about duplicate resource crane ([#10252](http://projects.theforeman.org/issues/10252), [b28d98a0](http://github.com/katello/katello-installer/commit/b28d98a0f17d3dbdcad5cd22bbf4b1019e957b51))
 * 'unable to get certificate CRL' Apache errors ([#10210](http://projects.theforeman.org/issues/10210), [1ccb322b](http://github.com/katello/katello-installer/commit/1ccb322b928ae8b70d5c5c30d46d160b37762dfc))
 * katello-installer cannot update to Foreman 3.X puppet modules ([#10096](http://projects.theforeman.org/issues/10096), [d8081a28](http://github.com/katello/katello-installer/commit/d8081a28d3b23f7a6156993113d4b0bbefb90edb))
 * devel installer fails when attempting to install rvm gpg key ([#10086](http://projects.theforeman.org/issues/10086), [d89554e5](http://github.com/katello/katello-installer/commit/d89554e53087c5b98c0e46448068dd7b1104a694))
 * katello-installer should use apipie:cache:index instead of apipie:cache:index ([#9964](http://projects.theforeman.org/issues/9964))
 * Better docker service restart and checking when installing the certificate RPM ([#9875](http://projects.theforeman.org/issues/9875))
 * Ensure plugin settings directory exists for gutterball (katello-devel) ([#9834](http://projects.theforeman.org/issues/9834), [2699a7cf](http://github.com/katello/katello-installer/commit/2699a7cf755183e7866bc4b6b45e24d6680debd4))
 * katello-installer should show option to enable BMC on smart-proxy ([#9743](http://projects.theforeman.org/issues/9743))
 * katello-installer - dev install has several errors reported  ([#9706](http://projects.theforeman.org/issues/9706))
 * katello-installer - dev install missing rubygem-smart_proxy_pulp rpm and default capsule registered ([#9702](http://projects.theforeman.org/issues/9702), [a85eb638](http://github.com/katello/katello-installer/commit/a85eb638a3d242d4cd6d4b0be9c1ef489cc0f8ce))
 * devel installer fails with error Could not set 'file' on ensure (gutterball) ([#9415](http://projects.theforeman.org/issues/9415))
 * Katello installer segfaults on Ruby 1.8.7 ([#7064](http://projects.theforeman.org/issues/7064), [68819b4c](http://github.com/katello/katello-installer/commit/68819b4cf638d08b9048f9c636ef530e8c42f466))

### Upgrades
 * 2.3 Upgrade Fails with Unable to Reload Puppet ([#11139](http://projects.theforeman.org/issues/11139), [d4b15588](http://github.com/katello//commit/d4b15588253327b727698d4e0a7b81794fda09f3))
 * Upgrades failing in nightly due to "undefined local variable or method `noop'" ([#10986](http://projects.theforeman.org/issues/10986), [9d839617](http://github.com/katello/katello-installer/commit/9d83961717287d6542770d208cc21414170e078f))

### Capsule
 * [upgrade] Could not find Content Host with exact name <capsule_fqdn> (Katello::Errors::CapsuleContentMissingConsumer): On synchronising contents from upgraded sat6 to upgraded capsule ([#11123](http://projects.theforeman.org/issues/11123), [0bc31483](http://github.com/katello/katello/commit/0bc31483f1110205dfa38ce1b0e16ce88dfd0839))
 * Satellite 6 Capsule server: needs official support & docs for un-installation (via katello-remove?) ([#10538](http://projects.theforeman.org/issues/10538), [51ea9c98](http://github.com/katello/katello-installer/commit/51ea9c98b40932c0d4bbbc95ec9015b3a6ba4874))
 * Capsule: openSSL not getting pulled in as a dep? ([#9888](http://projects.theforeman.org/issues/9888), [794b34ee](http://github.com/katello/katello-installer/commit/794b34ee5a6868bd1ede87f39a2e111b981b7d5c))

### Packaging
 * Katello-agent is not available for Fedora 22 ([#11116](http://projects.theforeman.org/issues/11116), [160c05d1](http://github.com/katello/katello/commit/160c05d10c7f3ee3a4dcb50a10f58352bc4480f6))
 * Upgrade pulp to 2.6.2 ([#10673](http://projects.theforeman.org/issues/10673), [6e554d70](http://github.com/katello/katello/commit/6e554d70018f1c0acbb9d0dbbc7a70367dd96642))

### Client/Agent
 * Remove enabling Red Hat repos from Katello ([#11055](http://projects.theforeman.org/issues/11055), [9f17ee59](http://github.com/katello/katello/commit/9f17ee591dce510f19137ec3204ab69ba8c6bc5f))
 * remove katello-agent from epel ([#8576](http://projects.theforeman.org/issues/8576))

### CLI
 * Unable to get unlimited-content-hosts value for host collection ([#10948](http://projects.theforeman.org/issues/10948), [6e3a67d8](http://github.com/katello/hammer-cli-katello/commit/6e3a67d8f7b742f77e1bcf4fb96e50cd7cb5b960))
 * hammer puppet-module list and filter list only shows 20 entries ([#10934](http://projects.theforeman.org/issues/10934), [c35d6f81](http://github.com/katello/katello/commit/c35d6f81475e0019f95900f698a32756fc7c634c))
 * Some parameter in Sat 6.1 CLI were renamed ([#10628](http://projects.theforeman.org/issues/10628), [f87bc6ec](http://github.com/katello/hammer-cli-katello/commit/f87bc6ecb973f0049ab99a243591382b0546256b), [2488fd79](http://github.com/katello/hammer-cli-katello/commit/2488fd79f5a717ae51bf910f413c1618b9aabc8d), [a65cc8ec](http://github.com/katello/hammer-cli-katello/commit/a65cc8ecb5e8398bb07149a92ac9b02b171db5f7), [298d1817](http://github.com/katello/hammer-cli-katello/commit/298d1817f7d58407fffd6b45195297707fda68fe))
 * Remove unused options from hammer content-view version incremental-update ([#10600](http://projects.theforeman.org/issues/10600), [30b9ceff](http://github.com/katello/hammer-cli-katello/commit/30b9ceff88462c265af4de3376145a5a7c08c3d2))
 * Cannot update lifecycle environment on rhel 66 with GA snap2 installed ([#10473](http://projects.theforeman.org/issues/10473), [33aea9c5](http://github.com/katello/hammer-cli-katello/commit/33aea9c57a256301d8bcf65c3a3250622d84afbf), [cf21fd50](http://github.com/katello/katello/commit/cf21fd5091c2e2ffc204c90e980749058f8f545b))
 * hammer content view create fails with null violation ([#10456](http://projects.theforeman.org/issues/10456), [a8126fc4](http://github.com/katello/hammer-cli-katello/commit/a8126fc44d3b5b46a045762b50a2890dee9e48cf))
 * Outdated hammer_cli_import gemspec ([#10419](http://projects.theforeman.org/issues/10419))
 * There is no way to view an activation key's content enablement in CLI ([#9876](http://projects.theforeman.org/issues/9876), [83830f3c](http://github.com/katello/katello/commit/83830f3cfd1068f1f263c794c407b3b752cfbe6b))
 * The content-view-version param in the CLI is interfering with commands ([#9736](http://projects.theforeman.org/issues/9736), [b05270a6](http://github.com/katello/hammer-cli-katello/commit/b05270a665c8bd63c2a45f2b6c9608fb983ddc52))
 * hammer content-host info having blank "Release Version" every time ([#9666](http://projects.theforeman.org/issues/9666), [f4d85a9c](http://github.com/katello/hammer-cli-katello/commit/f4d85a9cd96a398bec1e1081ad025b2526ad536f))
 * Redundant help text in host-collection erratum install ([#9537](http://projects.theforeman.org/issues/9537), [9eb33a35](http://github.com/katello/hammer-cli-katello/commit/9eb33a351006074dca45adcd7213c9ebb1cfab3e))
 * puppet-module CLI command says I'm missing product params when there are no product params ([#7269](http://projects.theforeman.org/issues/7269))
 * Need to be able to associate gpg key to a repository by gpg key name ([#6028](http://projects.theforeman.org/issues/6028))
 * Katello CLI subcommands are inconsistent with Foreman subcommands ([#4263](http://projects.theforeman.org/issues/4263))

### Dynflow
 * Repo syncs should always fail completely rather than be paused ([#10901](http://projects.theforeman.org/issues/10901), [b3d43c00](http://github.com/katello/katello/commit/b3d43c00ee7b937fc6190ec532b7a3f27c260de3))
 * As a user, I would like tasks to confirm that required services are running during plan phase ([#10725](http://projects.theforeman.org/issues/10725), [313d2236](http://github.com/katello/katello/commit/313d22361610722afd50f2ed147865c0ae31cf5c))
 * content-host unregister returns success but shows dynflow validation error ([#10127](http://projects.theforeman.org/issues/10127), [61a22e9a](http://github.com/katello/katello/commit/61a22e9a8fc2e0c80bf3f6a7cc628d8ffc11114e))

### API
 * readable repositories is not calculated properly ([#10886](http://projects.theforeman.org/issues/10886), [a3470b1d](http://github.com/katello/katello/commit/a3470b1ddfa980cd9af95e607c61b3adf1463acb))
 * hammer repository upload-content throws error: "Error: Too many open files" ([#10561](http://projects.theforeman.org/issues/10561), [d5b4bd12](http://github.com/katello/hammer-cli-katello/commit/d5b4bd12de12addd65874fd63452500123b28838))
 * traceback when registering a content host ([#10536](http://projects.theforeman.org/issues/10536), [b5b37d33](http://github.com/katello/katello/commit/b5b37d33cb9aeae12f2527d77f815667f282f941))
 * When configuring virt-who 0.12 with rhsm_username and rhsm_password with Satellite 6, virt-who fails with a traceback. ([#10484](http://projects.theforeman.org/issues/10484), [9149a86d](http://github.com/katello/katello/commit/9149a86d492136a1c504ec47976f53e2ea81e7cf))
 * trigger content host checkin when last_checkin specified to create/update api ([#10144](http://projects.theforeman.org/issues/10144), [e5f7c846](http://github.com/katello/katello/commit/e5f7c8467d0cb40f1f259f599ce17f78aed27c6a))
 * Content View Versions api should be paginated but isn't (performance issue) ([#10014](http://projects.theforeman.org/issues/10014), [15b8f9f1](http://github.com/katello/katello/commit/15b8f9f131fe023f47fc19d584f83a202006e18f))
 * Unused/nonexistent attribute on product 'marketing_product' ([#9622](http://projects.theforeman.org/issues/9622), [75a49aff](http://github.com/katello/katello/commit/75a49aff1e695be9d3e0c0188c947ede3ecb2b05))
 * Content VIew json is missing the repository content counts ([#9608](http://projects.theforeman.org/issues/9608), [952d6d26](http://github.com/katello/katello/commit/952d6d268ba90ca5d182ea4e0708e7b8df84a10d))
 * Add cancel to repository discover ([#5684](http://projects.theforeman.org/issues/5684), [93282607](http://github.com/katello/katello/commit/93282607ff8d74409c966c2f3f71f331d92f4e97))

### Katello Disconnected
 * pulp-katello plugin depends on qpid ([#10574](http://projects.theforeman.org/issues/10574))

### Subscriptions
 * unregister content host results in error in reindexing ([#10514](http://projects.theforeman.org/issues/10514), [1874ba10](http://github.com/katello/katello/commit/1874ba10eaeee5ef60b1432308410ab312b78428))

### API doc
 * apipie docs incorrect for DELETE /subscriptions/:id ([#9984](http://projects.theforeman.org/issues/9984), [2cf41d8e](http://github.com/katello/katello/commit/2cf41d8e184f73d909a55ae89b34ac72d03f275f))

### Tests
 * Content bats tests are failing due to hammer output change ([#9667](http://projects.theforeman.org/issues/9667))
 * remove model reloading from tests ([#9587](http://projects.theforeman.org/issues/9587), [50e7d6be](http://github.com/katello/katello/commit/50e7d6be1252ff9bd7376715fc6baf99f3344a0d))

### Docker
 * app/models/repository_docker_image.rb is in the wrong directory and is not being used ([#9539](http://projects.theforeman.org/issues/9539), [1c977c92](http://github.com/katello/katello/commit/1c977c92600bd4240523a2709846c4f2fa27e7f0))
 * Cannot update the upstream name for a docker-based repository ([#9423](http://projects.theforeman.org/issues/9423), [ab345f52](http://github.com/katello/katello/commit/ab345f52cefef6d2e08828d63e572401a5124ef4))
 * Need to include katello-default-ca-cert for docker ([#8636](http://projects.theforeman.org/issues/8636), [c66aed02](http://github.com/katello/katello-installer/commit/c66aed02f91f5c7b6f9aa8f0dc03938a7ceaaf8b))

### Candlepin
 * Custom product pools have no providedProducts ([#9519](http://projects.theforeman.org/issues/9519))
 * timeout trying to process 218 hypervisors and 5607 guests between candlepin and katello ([#8280](http://projects.theforeman.org/issues/8280))

### Errata Management
 * Race condition in indexing errata ([#8586](http://projects.theforeman.org/issues/8586), [d379aca4](http://github.com/katello/katello/commit/d379aca4934bea62d8076b8d7772c689d7963894))

### Roles and Permissions
 * bastion js looks for 'import_subscriptions' permission, but server defines 'import_manifest' ([#7354](http://projects.theforeman.org/issues/7354), [02198ab3](http://github.com/katello/katello/commit/02198ab3376449d79d7a9eaa6d7598c772d666fa))

### RHSM
 * Unable to list available subscriptions with subscription-manager < 0.96 ([#7321](http://projects.theforeman.org/issues/7321))

### Documentation
 * Add 'How to release Katello' guide to katello.org ([#7205](http://projects.theforeman.org/issues/7205))

### ElasticSearch
 * regression: searching for content hosts by internal database id no longer working ([#6449](http://projects.theforeman.org/issues/6449))

### Other
 * Some upgrades are failing on RHEL 6 with an error about tomcat ([#11353](http://projects.theforeman.org/issues/11353))
 * Katello 2.3 Repo Sync issue ([#11285](http://projects.theforeman.org/issues/11285))
 * Repository update can clear GPG key URL from cloned repositories ([#11262](http://projects.theforeman.org/issues/11262), [51b18641](http://github.com/katello/katello/commit/51b186415ce0fd3a7cbfbfb1d6db08f9ed824293))
 * Satellite and Capsule upgrade is failing as httpd service failed to start on RHEL 66 only. ([#11261](http://projects.theforeman.org/issues/11261))
 * All content view filters are shown in every content view ([#11253](http://projects.theforeman.org/issues/11253), [a123aa7c](http://github.com/katello/katello/commit/a123aa7c449af87d213fb8cf2b58c913ca983c16))
 * "katello-service list" doesn't work on Satellite 6 installed on RHEL7 ([#11249](http://projects.theforeman.org/issues/11249))
 * Enabling errata email notification without configuring email server breaks syncs, publishing and promotions ([#11228](http://projects.theforeman.org/issues/11228), [f28b18cc](http://github.com/katello/katello/commit/f28b18cc4ddb8237e0a347d6445c39010e784418))
 * Deprecation warning for available package groups for content view filter ([#11227](http://projects.theforeman.org/issues/11227), [606cbd53](http://github.com/katello/katello/commit/606cbd537da2ca03b0d046589f7329006eb64072))
 * manifest import "wrong number of arguments (3 for 2)" ([#11222](http://projects.theforeman.org/issues/11222), [593d2f09](http://github.com/katello/katello/commit/593d2f09ef28d46265de8a5917886219a8f98337))
 * ping causing "uninitialized constant Dynflow::Executors::RemoteViaSocket". ([#11215](http://projects.theforeman.org/issues/11215), [83581d54](http://github.com/katello/katello/commit/83581d54319f17139a8ff3ed53025263d3779118))
 * Distributions API endpoint deprecation ([#11210](http://projects.theforeman.org/issues/11210), [462fa1b5](http://github.com/katello/katello/commit/462fa1b55f35c2df21fc23e83139a8116f848992))
 * Duplicate Actions::Candlepin::ListenOnCandlepinEvents tasks ([#11166](http://projects.theforeman.org/issues/11166), [47c989a1](http://github.com/katello/katello/commit/47c989a192a0a755f6dba83b841087b4838d8e88))
 * `katello-service [re]start` hangs indefinitely if pulp_celerybeat is started before mongod ([#11165](http://projects.theforeman.org/issues/11165), [c5707335](http://github.com/katello/katello/commit/c570733519c86047718869b34203d0b6bd7701da))
 * katello-service doesn't work on el6 ([#11129](http://projects.theforeman.org/issues/11129), [1727a4f2](http://github.com/katello/katello/commit/1727a4f2b6a627cddfc3201b2214f0011c3c58fd))
 * Cannot publish content view as non-admin user ([#11094](http://projects.theforeman.org/issues/11094), [2de120a2](http://github.com/katello/katello/commit/2de120a23ec338f0f03aa5e9bfbc7f9e55c33840))
 * Errors during upgrade do not get properly reported ([#11086](http://projects.theforeman.org/issues/11086), [28f2c8b8](http://github.com/katello//commit/28f2c8b80a3b00f8b8f078bdaf56e5c688669fd0))
 * Fix confine Katello 2.3 to Foreman 1.9 and above ([#11070](http://projects.theforeman.org/issues/11070), [8611332b](http://github.com/katello/katello/commit/8611332b83e8273bdb21f47aaad9fef41a950043))
 * Nightly repo syncs often result in duplicate key error ([#11028](http://projects.theforeman.org/issues/11028), [6b2570c9](http://github.com/katello/katello/commit/6b2570c9ad25f74dcafcb7e17d40207a332be827))
 * Confine Katello 2.3 to Foreman 1.9 and above ([#10987](http://projects.theforeman.org/issues/10987), [4b614c88](http://github.com/katello/katello/commit/4b614c8817e3a7161616bf756db8d8aed379586a))
 * ISO repos are not published via http ([#10958](http://projects.theforeman.org/issues/10958))
 * reference to removed methods in host_collections_controller.rb ([#10903](http://projects.theforeman.org/issues/10903), [150081a5](http://github.com/katello/katello/commit/150081a59114b843350120696b1129807b055723))
 * Error can't find Actions::Katello::Repository::DestroyMedia ([#10857](http://projects.theforeman.org/issues/10857), [230584ae](http://github.com/katello/katello/commit/230584ae66e720e507bacdae01a15bcc667316d5))
 * katello_devel module should deploy katello.local.rb from template ([#10836](http://projects.theforeman.org/issues/10836))
 * Package groups aren't shown for add or list/remove content view package group filter rule ([#10790](http://projects.theforeman.org/issues/10790), [45a18a0a](http://github.com/katello/katello/commit/45a18a0a7165a387536f279796c41689f83f7488))
 * Can't sync puppet forge repo ([#10771](http://projects.theforeman.org/issues/10771), [1ce72cb8](http://github.com/katello/katello/commit/1ce72cb81cc18bdd4ca72b6cbb93262a5a414c95))
 * cannot import manifest due to change in args to import_products_from_cp ([#10719](http://projects.theforeman.org/issues/10719), [9eff2108](http://github.com/katello/katello/commit/9eff210881d0b57075cd91a3c4ddbe4f9921804b))
 * enabled repos shown on too many tabs of red hat repos ([#10718](http://projects.theforeman.org/issues/10718), [e6878abb](http://github.com/katello/katello/commit/e6878abb6eab3a3d0d7fcb8bf6cac6e44c48d664))
 * Capsule upgrade fails with unknown image type docker ([#10716](http://projects.theforeman.org/issues/10716), [63ffb72c](http://github.com/katello/katello-installer/commit/63ffb72c46af790bd6d7f4908b8f8796abd1dc84))
 * katello-disconnected fails when performing a date-based export ([#10706](http://projects.theforeman.org/issues/10706))
 * hammer import organization of an existing name fails to use any recover strategy ([#10696](http://projects.theforeman.org/issues/10696), [45aec9b8](http://github.com/katello/katello/commit/45aec9b88a184ab820ba298f23fa433c695ecd22))
 * ActiveRecord::RecordInvalid: Validation failed: Title has already been taken ([#10690](http://projects.theforeman.org/issues/10690), [45f26bce](http://github.com/katello/katello/commit/45f26bce8777ca9ab4f75481e21afc8395981e77))
 * Reindex fails ([#10637](http://projects.theforeman.org/issues/10637))
 * Can not pull docker images from katello once they are synced ([#10620](http://projects.theforeman.org/issues/10620), [70dda2a5](http://github.com/katello/katello/commit/70dda2a57fcf4f285b6952d073f93842331622ed))
 * Creating a Content View leads to 'Validation failed: Composite is not included in the list' ([#10604](http://projects.theforeman.org/issues/10604))
 * Help text for hammer-cli-katello prodct synchronize is incorrect ([#10590](http://projects.theforeman.org/issues/10590), [d0b39ed8](http://github.com/katello/katello/commit/d0b39ed85ce27690f4a2ce7dd392b058511eda56))
 * Unregister Content Host via host page doesn't work ([#10578](http://projects.theforeman.org/issues/10578))
 * GPG key not on Katello Site ([#10486](http://projects.theforeman.org/issues/10486))
 * Content views should validate that a boolean value was passed for composite field ([#10455](http://projects.theforeman.org/issues/10455), [c3b1e2e3](http://github.com/katello/katello/commit/c3b1e2e3e135cf583d64db1ba1be54410a27e2df))
 * apipie content host update should not require facts ([#10424](http://projects.theforeman.org/issues/10424), [566f4a13](http://github.com/katello/katello/commit/566f4a13c54802e4de032deeb9b4eb0de5dea233))
 * Mongodb custom fact in puppet-pulp leads to installation breakages if the same repository is declared twice by yum ([#10385](http://projects.theforeman.org/issues/10385), [f0b0edd5](http://github.com/katello/katello-installer/commit/f0b0edd5aa013ae3bb13d95789cf6de60716e7ba))
 * After creating puppet repository using webui, there is option named "Published At" which points to broken link ([#10258](http://projects.theforeman.org/issues/10258), [eebba24d](http://github.com/katello/katello/commit/eebba24d1e569e4c6584ef6178b83fd52dad2b65))
 * UI displays incorrect number of consumed subscriptions ([#10225](http://projects.theforeman.org/issues/10225), [45bac3b0](http://github.com/katello/katello/commit/45bac3b0b8a1cdd33a1a65a3b7a1c6ec3d805cc5))
 * link to content host from guest subscription on subscriptions page missing uuid ([#10218](http://projects.theforeman.org/issues/10218), [99d1c1ee](http://github.com/katello/katello/commit/99d1c1eed4bcd7a64c82124d00c6cd0e295c4da1))
 * Hitting the resume button on a repo sync job stalled at 53% gives this error ([#10141](http://projects.theforeman.org/issues/10141))
 * puppet-certs refers to 'sity' instead of 'city' in a number of places ([#10097](http://projects.theforeman.org/issues/10097))
 * add description column to content view versions ([#9923](http://projects.theforeman.org/issues/9923), [59acd64d](http://github.com/katello/katello/commit/59acd64d33a9784cbab52bddf73c2adc0fce78ec))
 * Errata filters showing incorrect count ([#9747](http://projects.theforeman.org/issues/9747))
 * Incorrect UI design for selecting content hosts for errata install ([#9658](http://projects.theforeman.org/issues/9658), [6a5defd1](http://github.com/katello/katello/commit/6a5defd107b0472ef3f50ed56868fe47db0daf27))
 * auto-attach content hosts bulk action does not reindex elasticsearch ([#9655](http://projects.theforeman.org/issues/9655), [98e27b80](http://github.com/katello/katello/commit/98e27b80f96e3d5d15776ee9c20fa9897651eb13))
 * roles: content-search doesn't show packages to normal user, who has permission to view_product ([#9554](http://projects.theforeman.org/issues/9554), [2162948c](http://github.com/katello/katello/commit/2162948c05f28f830dfe4545b0f07fab88db55d8))
 * hammer content-report CSV output of dates should be in form consumable by spreadsheet ([#9476](http://projects.theforeman.org/issues/9476))
