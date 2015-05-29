# 2.2.1 Maibock (2015-05-29)

## Features 

### Documentation
 * Add documentation on how to use Docker ([#9601](http://projects.theforeman.org/issues/9601), [ffdda4f3](http://github.com/katello/katello.org/commit/ffdda4f3b0c8ae4c868481cce1c7ec7d9b528c9d))

## Bug Fixes 

### Web UI
 * katello fails when content host registers with a release version or uploading facts ([#10523](http://projects.theforeman.org/issues/10523), [86973983](http://github.com/katello/katello/commit/86973983e0e615661e697f9f106b9ace6eecfd40))
 * Custom repositories do not define 'metadata_expire = 1' ([#10495](http://projects.theforeman.org/issues/10495), [78c75ae8](http://github.com/katello/katello/commit/78c75ae85c8a5752de9e655f1ec278f492f95245))
 * Product -> Repository page is slow (10-30 seconds) to render when there are 10+ repos with content synced ([#10381](http://projects.theforeman.org/issues/10381), [e179a600](http://github.com/katello/katello/commit/e179a60018fe0cdb951342bd44cf6327ecc45c20))
 * Bulk Actions -> Errata page does not load ([#10309](http://projects.theforeman.org/issues/10309), [ecbb51bc](http://github.com/katello/katello/commit/ecbb51bca629a6c90c8e0528cb62f6dd238d4654))
 * The Content Hosts page is loading very slowly on Satellite 6 ([#10152](http://projects.theforeman.org/issues/10152), [20fecb64](http://github.com/katello/katello/commit/20fecb6490a200a7ac8bba577068d7d7b51b3902))

### Installer
 * GPG key urls not updated on upgrade from 2.1 -> 2.2 ([#10512](http://projects.theforeman.org/issues/10512), [bc091d97](http://github.com/katello/katello-installer/commit/bc091d97eef4b1151c9bbc89e0b6f75414004d01))

### CLI
 * hammer content-host errata list failed ([#10499](http://projects.theforeman.org/issues/10499), [e1fbd2f6](http://github.com/katello/hammer-cli-katello/commit/e1fbd2f60ec2d65775f1cf3dfa5f902a40abcafd))

### Capsule
 * Unable to sync capsule: "undefined method `fetch' for nil:NilClass" ([#10422](http://projects.theforeman.org/issues/10422), [d575025f](http://github.com/katello/katello/commit/d575025fe14e2c2cf91f1878a518ad3a6e80189c))
 * Repeated crashes of goferd on Pulp Node Capsule when trying to SyncNode  ([#10148](http://projects.theforeman.org/issues/10148))

### Content Uploads
 * Package Upload via GUI to Products is not updating Info ([#10327](http://projects.theforeman.org/issues/10327))

### Pulp
 * "undefined method `[]' for nil:NilClass (NoMethodError)" problem synching repo's ([#10231](http://projects.theforeman.org/issues/10231))

### Packaging
 * Katello-agent is not available for Fedora 21 ([#10224](http://projects.theforeman.org/issues/10224), [60b72b76](http://github.com/katello/katello/commit/60b72b762064540a072329c50be54d58613aa9b5))

### Documentation
 * katello.org is missing information about katello-agent ([#7735](http://projects.theforeman.org/issues/7735))

### Other
 * katello-service package doesn't have katello-service ([#10428](http://projects.theforeman.org/issues/10428), [95f1e0cc](http://github.com/katello/katello/commit/95f1e0cc6e2b3ff9877ce2d3f8b2203512ab2296))
 * Can't delete Lifecycle Environment when hosts are assigned to Content View ([#10331](http://projects.theforeman.org/issues/10331), [a0ee7b07](http://github.com/katello/katello/commit/a0ee7b07c00459577be5cac79c105cad5a73733c))

# 2.2 Maibock (2015-03-28)

## Features 

### Subscriptions
 * 24 hour guest subscription should be hidden from user ([#9422](http://projects.theforeman.org/issues/9422), [749c15a3](http://github.com/katello/katello/commit/749c15a3128480592f9e2d6d639bc17802cc6038))

### Web UI
 * Indicate to the user that an incremental update is in progress (API) ([#9223](http://projects.theforeman.org/issues/9223))
 * Incremental update:  show resulting update task in details pane  ([#9176](http://projects.theforeman.org/issues/9176), [f7c6efc9](http://github.com/katello/katello/commit/f7c6efc969510d2258e8d5e8378c8b88b0af2cf3))
 * Indicate to the user that an incremental update is in progress (UI) ([#9166](http://projects.theforeman.org/issues/9166), [cb495cdf](http://github.com/katello/katello/commit/cb495cdfe221919b6da0e03e20a26002fbc7487d))
 * Show only non zero content counts in UI ([#8962](http://projects.theforeman.org/issues/8962), [1db5669e](http://github.com/katello/katello/commit/1db5669e2e1e0cba992db7fd0686458916166f8c))
 * Repo create pages need to be clearer for docker content type ([#8959](http://projects.theforeman.org/issues/8959), [6c6a9219](http://github.com/katello/katello/commit/6c6a921943e506a08805684db556054dd6b425ff))
 * Replace errata content search links with links to errata list page ([#8652](http://projects.theforeman.org/issues/8652), [4de68b2b](http://github.com/katello/katello/commit/4de68b2b756b8fb4c2e34963ff0b7f5b6a401f6c))
 * As an UI user i like to have a confirmation dialog before packages are deleted ([#8570](http://projects.theforeman.org/issues/8570), [e16e1964](http://github.com/katello/katello/commit/e16e19641d4af525e4988394657b16726fc51662))
 * As a UI user, I should see content available in an individual environment. ([#8448](http://projects.theforeman.org/issues/8448), [142ccd5d](http://github.com/katello/katello/commit/142ccd5dd837553626e79a603985b19216f773ed))
 * Add bulk apply to errata list ([#8350](http://projects.theforeman.org/issues/8350))
 * UI:  support option for initiating and update on all affected systems when performing an update ([#8192](http://projects.theforeman.org/issues/8192), [1c696ef5](http://github.com/katello/katello/commit/1c696ef5203eb61a32e9e12d79ee0b98e2bcbc34))
 * UI for select multiple errata, and 'apply them' to multiple content views in multiple environments ([#8178](http://projects.theforeman.org/issues/8178), [7d84414b](http://github.com/katello/katello/commit/7d84414b1aaa451f83971bdfbe3ee65b69289b36))
 * As a UI user, I should be able to view a list of products/repositories for an erratum. ([#7953](http://projects.theforeman.org/issues/7953), [1074b9ff](http://github.com/katello/katello/commit/1074b9ff57d3c3e7f343933a1e81ede330e49c11))
 * As a UI user, I should be able to sort errata by updated date. ([#7694](http://projects.theforeman.org/issues/7694), [a2326986](http://github.com/katello/katello/commit/a23269861bcbf36eb722613572b0ab88540c3879))
 * As a UI user, I should be able to filter the errata list by product and repository ([#7691](http://projects.theforeman.org/issues/7691), [fcb0a966](http://github.com/katello/katello/commit/fcb0a966ec25933c06aa5c11ac3d15ac15ded835))
 * As a UI user, the Dashboard should show me new errata and link me to the errata page. ([#7676](http://projects.theforeman.org/issues/7676), [8c39ac2e](http://github.com/katello/katello/commit/8c39ac2ebf76b4513f5be99d5da2c298c81200c0))

### Pulp
 * Upgrade to Pulp 2.6 ([#9179](http://projects.theforeman.org/issues/9179))
 * Upgrade Katello to pulp 2.5.1 ([#8759](http://projects.theforeman.org/issues/8759))

### Foreman Integration
 * Provide a kickstart provisioning template to configure networking ([#9132](http://projects.theforeman.org/issues/9132), [7cdc6868](http://github.com/katello/katello/commit/7cdc68684e1f98786c1cbfca2c5fcb7cc305a0d2))

### Capsule
 * As a user, I should be able to upgrade an existing capsule to an isolated capsule ([#9037](http://projects.theforeman.org/issues/9037))
 * Client Qpid traffic should be routable through the client's Capsule. ([#8175](http://projects.theforeman.org/issues/8175), [22189c32](http://github.com/katello/katello/commit/22189c320a2678f5fbbe02c2f220a88c622a7b5a))
 * Client hosts should be able to retrieve GPG Keys through the Capsule. ([#8174](http://projects.theforeman.org/issues/8174), [6993fb68](http://github.com/katello/katello/commit/6993fb68744f3ca17033578b7394a7fbd0d9c9a7))
 * Client systems should be able to route all RHSM traffic through a Capsule. ([#7745](http://projects.theforeman.org/issues/7745), [dacbf2f4](http://github.com/katello/katello/commit/dacbf2f4fb308ee36c285dd2f79bcdb9f333ed44))

### Installer
 * As a user, I want to be able to migrate my answers file to support new default options ([#9035](http://projects.theforeman.org/issues/9035))
 * Support templates plugin in Capsule ([#8991](http://projects.theforeman.org/issues/8991), [9885e83a](http://github.com/katello/katello/commit/9885e83ac24c196d71085043abda681d973fe547))
 * Allow configuration of the RHSM port for the consumer RPM ([#8755](http://projects.theforeman.org/issues/8755), [9885e83a](http://github.com/katello/katello/commit/9885e83ac24c196d71085043abda681d973fe547))
 * pulp worker count needs a maximum ([#8266](http://projects.theforeman.org/issues/8266))
 * Bootstrap EPEL instead of fixed link to release packages ([#7747](http://projects.theforeman.org/issues/7747))

### Content Views
 * Support incremental update via hammer ([#8972](http://projects.theforeman.org/issues/8972))

### Errata Management
 * Rename "Available Errata" to "Installable Errata" ([#8971](http://projects.theforeman.org/issues/8971), [a01096ae](http://github.com/katello/katello/commit/a01096ae12d0ff38de8f7d2da7d3733e9f36bfb9))
 * Clicking on Dashboard widget should take user to the errata page ([#8895](http://projects.theforeman.org/issues/8895), [29edbd56](http://github.com/katello/katello/commit/29edbd560056c4129dfdd23b85ae3a6d94ef8a62))
 * As a user, i should be able to see what was added as part of an incremental errata update ([#8251](http://projects.theforeman.org/issues/8251), [bcf79504](http://github.com/katello/katello/commit/bcf79504bdd5f9fa25056df095f4fea64e3ffaab))
 * Update composite content views and environments with new point releases ([#8194](http://projects.theforeman.org/issues/8194), [3e25ff88](http://github.com/katello/katello/commit/3e25ff88ab75e85ae5e9e1385ea1dedd94601ee4))

### Docker
 * Show tag info on the manage docker image screen ([#8958](http://projects.theforeman.org/issues/8958), [2ec71ae7](http://github.com/katello/katello/commit/2ec71ae7ec6bfc8d6d021ebf1d840910af9fcc7f))
 * As a user I would like to provision new container using katello repositories ([#8918](http://projects.theforeman.org/issues/8918), [cdbebe9d](http://github.com/katello/katello/commit/cdbebe9d90a449e6f8cfd0bc058f6cc95e8a1a1a))
 * Document how to use docker for katello.org ([#8897](http://projects.theforeman.org/issues/8897))
 * CV version details page needs to show docker repo information ([#8836](http://projects.theforeman.org/issues/8836), [c4018ab4](http://github.com/katello/katello/commit/c4018ab4d202ee93e2b4049a3da028e9f0cd45dd))
 * show docker tag counts instead of (or with) image count ([#8113](http://projects.theforeman.org/issues/8113), [d1e7fe7a](http://github.com/katello/katello/commit/d1e7fe7af559f47eff77f29d6426264ad4b7391b))
 * Show docker pull url for repository details page  ([#8101](http://projects.theforeman.org/issues/8101), [fbc37191](http://github.com/katello/katello/commit/fbc3719159a2f116d545bb31c6b6fa29d139df8b))
 * As a user, I want to remove docker images and puppet modules from a repository ([#7810](http://projects.theforeman.org/issues/7810), [10c037d4](http://github.com/katello/katello/commit/10c037d493904dac97005c279218e788c3c2da4b))
 * As a UI user, I want to view docker content for an environment ([#7783](http://projects.theforeman.org/issues/7783))
 * As a docker user, I should be able to run docker build on a local client and have it pull images from katello ([#7782](http://projects.theforeman.org/issues/7782))
 * As a user, when installing a capsule with 'pulp/content' enabled, crane should be installed and configured ([#7780](http://projects.theforeman.org/issues/7780))
 * As a user, I would like to sync Docker images from the Red Hat CDN. ([#7128](http://projects.theforeman.org/issues/7128))
 * As a UI user, I would like to view the content of a Docker repository. ([#7127](http://projects.theforeman.org/issues/7127), [03749dea](http://github.com/katello/katello/commit/03749dea1c6f8181dd3914b71dc76ec7d5ae85ed))

### SAM.next
 * As a SAM user, katello-agent information is not necessary on content host details UI page ([#8893](http://projects.theforeman.org/issues/8893), [71f60183](http://github.com/katello/katello/commit/71f601839866c1b8e2a51f62aa9f33bb63d84dc2))
 * As a SAM user, I should not see references to custom products ([#8671](http://projects.theforeman.org/issues/8671), [f80bb882](http://github.com/katello/katello/commit/f80bb8829280ede749a3e04d00b436ff2ec9be06))
 * package samui into nightly builds ([#8495](http://projects.theforeman.org/issues/8495))
 * As a user, I would like to be able to install SAM.next ([#8213](http://projects.theforeman.org/issues/8213), [9ff2d9a2](http://github.com/katello/katello/commit/9ff2d9a2a8e13f56f19b35f3a09bd3dca4297ed2))

### API
 * Keep track of components of each composite content view version ([#8730](http://projects.theforeman.org/issues/8730), [74c751b7](http://github.com/katello/katello/commit/74c751b72d10e3070e07d89a4e31d9126663ff34))
 * Add ability to filter errata list based on affected_content_hosts  ([#8307](http://projects.theforeman.org/issues/8307), [7a70cc7f](http://github.com/katello/katello/commit/7a70cc7f76bb7b3195c5ed4e5db70e1fd9affe9c))
 * API for selecting multiple *packages*, and 'apply them' to multiple content views in multiple environments. ([#8306](http://projects.theforeman.org/issues/8306), [981dac77](http://github.com/katello/katello/commit/981dac777fd1d9ee7c15c2ed220bef7e16f64605))
 * API for initiating an update on all affected systems after applying new errata to content views/environments ([#8191](http://projects.theforeman.org/issues/8191), [240b6447](http://github.com/katello/katello/commit/240b6447e7d693eb492f2c55b7ff23fc8e78d1b5))
 * API for querying a subset of environments or content views to push new errata to. ([#8188](http://projects.theforeman.org/issues/8188), [a55f62fa](http://github.com/katello/katello/commit/a55f62fa5c1dc1b9786ed6f65527411f0cc376fc))
 * As a user, I would expect errata that are added to a new point release to use dependency resolution to ensure needed dependencies are added ([#8180](http://projects.theforeman.org/issues/8180), [e5a77f16](http://github.com/katello/katello/commit/e5a77f16384ef690f0163aea36094c2c2149d59b))
 * API for select multiple errata, and 'apply them' to multiple content views in multiple environments ([#8177](http://projects.theforeman.org/issues/8177))

### Gutterball
 * add hammer-cli-gutterball to build infrastructure ([#8635](http://projects.theforeman.org/issues/8635), [b2e0d95e](http://github.com/katello/katello/commit/b2e0d95e584766fb88468548304b7faaab9d0160))

### CLI
 * CLI:  support option for initiating and update on all affected systems when performing an update ([#8193](http://projects.theforeman.org/issues/8193), [e4baf742](http://github.com/katello/katello/commit/e4baf74207d1df17ecb3f09b253140a9959d06f9))
 * CLI for viewing applicable environments or content views an errata applies to ([#8190](http://projects.theforeman.org/issues/8190), [32642a9f](http://github.com/katello/katello/commit/32642a9f6b4f6060d3cf03c1c21e067297486367))
 * CLI for select multiple errata, and 'apply them' to multiple content views in multiple environments ([#8179](http://projects.theforeman.org/issues/8179), [e4baf742](http://github.com/katello/katello/commit/e4baf74207d1df17ecb3f09b253140a9959d06f9))
 * hammer command to remove content host deletion record ([#8028](http://projects.theforeman.org/issues/8028))

### Documentation
 * Create and add data backup guide to katello.org ([#7631](http://projects.theforeman.org/issues/7631), [f29aa981](http://github.com/katello/katello/commit/f29aa981158258c3bfeb5b513db73b52a6614a28))

### Candlepin
 * some form of activation key that contains subscription groups rather than exact subscriptions needed ([#6939](http://projects.theforeman.org/issues/6939), [66b1a73d](http://github.com/katello/katello/commit/66b1a73dd0cee4c0053fe8b32073b78a9d5f2afa))

### Other
 * As a SAM user, I should not see references to lifecycle environments ([#8731](http://projects.theforeman.org/issues/8731), [4b1cd065](http://github.com/katello/katello/commit/4b1cd0655276b90930841e5e5ac2d8692de1718e))
 * As a SAM user, I should not see references to remote actions ([#8729](http://projects.theforeman.org/issues/8729), [820ed709](http://github.com/katello/katello/commit/820ed709a118f2916396248790446a105ca4f361))
 * Consider turning on the EmptyLinesAroundBody cop ([#8579](http://projects.theforeman.org/issues/8579), [72adffb8](http://github.com/katello/katello/commit/72adffb8709f7d6aab895ab9fb9e995a5e597743))
 * As a user, I should be able to install gutterball ([#8548](http://projects.theforeman.org/issues/8548))

## Bug Fixes 

### Installer
 * installer not configuring crane on main katello server ([#9892](http://projects.theforeman.org/issues/9892))
 * Update katello-remove to remove new stuff ([#9867](http://projects.theforeman.org/issues/9867))
 * Self-registered Katello should update cleanly from 2.1 to 2.2 ([#9680](http://projects.theforeman.org/issues/9680))
 * capsule-installer throws error when --pulp=false ([#9668](http://projects.theforeman.org/issues/9668), [59adba41](http://github.com/katello/katello/commit/59adba41b17bad6e0b54d3acd880cac237e2e463))
 * unable to create user on sat upgraded from 6.0 to 6.1: "undefined method `user' for resources - []:Runcible::Wrapper (NoMethodError)" ([#9633](http://projects.theforeman.org/issues/9633), [4fc67852](http://github.com/katello/katello/commit/4fc67852c9854497babe409f995e42742c02bf2c))
 * upgrade from 6.0.4 to 6.1 hangs with "Upgrade Step: migrate_pulp..." ([#9602](http://projects.theforeman.org/issues/9602), [4fc67852](http://github.com/katello/katello/commit/4fc67852c9854497babe409f995e42742c02bf2c))
 * foreman-tasks fails to start on rhel7 as soon as install finished ([#9483](http://projects.theforeman.org/issues/9483), [784a25aa](http://github.com/katello/katello/commit/784a25aa12cadfc83829142b93c8db369595535a))
 * This module does not support osfamily CentOS for puppet-pulp ([#9479](http://projects.theforeman.org/issues/9479))
 * katello devel install fails Duplicate declaration: Class[Certs::Katello] ([#9254](http://projects.theforeman.org/issues/9254), [22189c32](http://github.com/katello/katello/commit/22189c320a2678f5fbbe02c2f220a88c622a7b5a))
 * puppet pulp tests fail ([#9205](http://projects.theforeman.org/issues/9205))
 * hooks_dir should be hook_dirs in katello-installer ([#9075](http://projects.theforeman.org/issues/9075), [96bb675d](http://github.com/katello/katello/commit/96bb675d7f4b901ec1ebe1e6548147212994b149))
 * Improve java check error message ([#9024](http://projects.theforeman.org/issues/9024), [4b296419](http://github.com/katello/katello/commit/4b2964191c1ca45bdf0f2ea59085b08539b1c42d))
 * Puppetfile in the installer should be consistent in using hyphens ([#9020](http://projects.theforeman.org/issues/9020), [93fcc4b3](http://github.com/katello/katello/commit/93fcc4b3e4a215d0c906c3e54b2d1386c63c08b2))
 * puppet-capsule refers to incorrect version numbers of foreman modules ([#8909](http://projects.theforeman.org/issues/8909))
 * puppet ordering causing failure to import gutterball certificate into katello nssdb ([#8850](http://projects.theforeman.org/issues/8850))
 * katello module needs to install foreman_gutterball  ([#8849](http://projects.theforeman.org/issues/8849), [c605e8b0](http://github.com/katello/katello/commit/c605e8b08aca49ec7a4dc414f6d51c546475120d))
 * GeoTrust/RapidSSL WildCard cert issue ([#8787](http://projects.theforeman.org/issues/8787))
 * [RFE] validate custom certificates before Satellite 6 installation ([#8609](http://projects.theforeman.org/issues/8609), [d578e1a3](http://github.com/katello/katello/commit/d578e1a302ec26058e1b2d59b635b8ceae898284))
 * MongoDB fails to start with a RHEL 7 system ([#8478](http://projects.theforeman.org/issues/8478), [0832ffb5](http://github.com/katello/katello/commit/0832ffb5689e27eec61cd4ebfc61a08c0547ddb6))
 * Make puppet ssl certificate+key that is used to authenticate against foreman available to the smart-proxy ([#8372](http://projects.theforeman.org/issues/8372))
 * katello-installer changes to katello.yml do not restart foreman-tasks ([#7716](http://projects.theforeman.org/issues/7716), [784a25aa](http://github.com/katello/katello/commit/784a25aa12cadfc83829142b93c8db369595535a))

### Web UI
 * activation key - create:  "Loading...." hangs on UI due to 404/elasticsearch error ([#9887](http://projects.theforeman.org/issues/9887), [a15d5098](http://github.com/katello/katello/commit/a15d5098b0252eaeed3bc4a8c59ede2177f61593))
 * Applying installable errata to multiple content hosts does not work ([#9802](http://projects.theforeman.org/issues/9802), [2760883c](http://github.com/katello/katello/commit/2760883c13a1e05359033863ce7525f6f59bc68c))
 * Incremental update publishes/promotes to incorrect lifecycle environments of a composite content view ([#9799](http://projects.theforeman.org/issues/9799), [3817b397](http://github.com/katello/katello/commit/3817b397dcb2a50fbf3682e9c06c3ec0e6190f90))
 * Some errata disappeared in publish/promotion of content view ([#9750](http://projects.theforeman.org/issues/9750), [52a37ee9](http://github.com/katello/katello/commit/52a37ee92b989c015687e37e77e1d768ba33f7c0))
 * Unable to perform incremental update of puppet module in CLI ([#9735](http://projects.theforeman.org/issues/9735), [ca29f591](http://github.com/katello/katello/commit/ca29f5912983d6f536b033a514e062d462354ffc))
 * Unable to perform incremental update of errata in CLI ([#9732](http://projects.theforeman.org/issues/9732), [286a2c89](http://github.com/katello/katello/commit/286a2c893e4854282e15aeb27de81205c089b93e), [43f9b8f2](http://github.com/katello/katello/commit/43f9b8f2f73e84d4d74668ab307bae6b502b9eb1))
 * available puppet modules takes too long to load with a large number of puppet modules ([#9729](http://projects.theforeman.org/issues/9729))
 * Content Views leak information under certian conditions ([#9724](http://projects.theforeman.org/issues/9724))
 * Content Search:  Package search does not return any results for packages starting with capital letters. ([#9685](http://projects.theforeman.org/issues/9685), [7d2d5387](http://github.com/katello/katello/commit/7d2d538776719d610a5524e5bdf5cc07057991db))
 * Publish/Promotion times in Satellite 6 growing after each publish/promotion ([#9647](http://projects.theforeman.org/issues/9647), [a610d6c9](http://github.com/katello/katello/commit/a610d6c93a74e1e8c2ca2fdf930955ab99c07e99))
 * Content search: content view compare seems to hang indefinitely and/or eventually not respond to click ([#9586](http://projects.theforeman.org/issues/9586), [973918ee](http://github.com/katello/katello/commit/973918eeb03fe3db1c1b6ab643977d57c1bdab97))
 * The 'Red Hat Repositories' page response is slow on enabling new repository. ([#9585](http://projects.theforeman.org/issues/9585), [5d539e88](http://github.com/katello/katello/commit/5d539e88388f10d20f7c6f5a1b59b9dff8f56b1c))
 * Deleting a repo should either block until done or return a task ([#9583](http://projects.theforeman.org/issues/9583), [b222c9bb](http://github.com/katello/katello/commit/b222c9bb5f44ae054fd0d36aaf89ea18cce0ff79))
 * Composite Content View Component Tab display too slow ([#9582](http://projects.theforeman.org/issues/9582), [0e91e0d0](http://github.com/katello/katello/commit/0e91e0d096725a0d7443d6a62b15110c15541adb))
 * Loading Activation keys list slow ([#9580](http://projects.theforeman.org/issues/9580), [2f7e0e56](http://github.com/katello/katello/commit/2f7e0e560b95b6c6082a35a5f6b5e9ab1230d516))
 * Slow UI (>20seconds to load page) Composite Content-view -> Adding Content Views ([#9534](http://projects.theforeman.org/issues/9534), [0603abca](http://github.com/katello/katello/commit/0603abcadd03186cf0a969274cd42c538e2a1170))
 * Disable bulk action checkboxes on any pages that do not support them. ([#9522](http://projects.theforeman.org/issues/9522), [0ad17908](http://github.com/katello/katello/commit/0ad17908c0756d6c63c0ab78eca47022e6483b7e))
 * Manifest upload: "Upstream Subscription Managment Application" has typos and bad formatting ([#9511](http://projects.theforeman.org/issues/9511), [ac086106](http://github.com/katello/katello/commit/ac086106d1350c0917354084704233f0ec773bed))
 * All bastion_katello modal dialogs are untranslated ([#9484](http://projects.theforeman.org/issues/9484), [d8ac8ae3](http://github.com/katello/katello/commit/d8ac8ae3df05669e5c25c7c950914cbcd87dab16), [c4dfc3f2](http://github.com/katello/katello/commit/c4dfc3f2d9b6fa52634a8c469fc2268672fdfee9))
 * Contest host -> Errata tab fails with a javascript error ([#9471](http://projects.theforeman.org/issues/9471), [5dde6c76](http://github.com/katello/katello/commit/5dde6c76db653352af1ce0ef62ac504556e6e39c))
 * Incorrect errata count displayed on Content host Details page ([#9464](http://projects.theforeman.org/issues/9464), [dd934bc6](http://github.com/katello/katello/commit/dd934bc650e8562b4f02e2817e0240187e6c4c2a))
 * creating/updating activation-key with long integer value under content-host limit raises PGError: integer out of range ([#9455](http://projects.theforeman.org/issues/9455), [4fe00c99](http://github.com/katello/katello/commit/4fe00c9919ab5b84719c6626ad31d8a5e128232b))
 * No success notification when adding content to content-views ([#9396](http://projects.theforeman.org/issues/9396))
 * Next sync plan time on sync plan index and details pages incorrect ([#9376](http://projects.theforeman.org/issues/9376), [e76609cf](http://github.com/katello/katello/commit/e76609cf4ed5fdb02ba33d5a0e7c69e2c3f2668b))
 * Using IE 11, cannot promote items on Satellite 6 ([#9345](http://projects.theforeman.org/issues/9345), [cc61cf44](http://github.com/katello/katello/commit/cc61cf449c7970d50c7a6d390b410113c94b42c8))
 * activation-key description shouldn't contain more than 1000 charcters ([#9344](http://projects.theforeman.org/issues/9344), [6d1d33a2](http://github.com/katello/katello/commit/6d1d33a24fab6549f49abe3bd458879f6c88e810))
 * Copying an activation key does not include auto-attach preference ([#9343](http://projects.theforeman.org/issues/9343), [5e3d0b59](http://github.com/katello/katello/commit/5e3d0b596049b5d8e32daf40b238ba520380b498))
 * Validation error needs to be updated when copying an existing activation-key with blank name ([#9330](http://projects.theforeman.org/issues/9330), [494f3fb4](http://github.com/katello/katello/commit/494f3fb494ac269f4433a91ca556aca28aa94298))
 * Monitor > Tasks page throws "Not Implemented error" after an incremental update (with system errata apply) ([#9309](http://projects.theforeman.org/issues/9309), [ff03a8d0](http://github.com/katello/katello/commit/ff03a8d0a29e95b5e7140f5e3770e6fb20a353dd))
 * errata apply with inc update includes full system info and sends even without checking 'apply to content hosts' ([#9298](http://projects.theforeman.org/issues/9298), [fdc996f7](http://github.com/katello/katello/commit/fdc996f71c846b643586f2aa0b7b7434c1df90db))
 * WebUI -> Errata -> Content Hosts page does not load ([#9264](http://projects.theforeman.org/issues/9264), [bda907bb](http://github.com/katello/katello/commit/bda907bb608aa484e652cb83409a42d4cef6b1c2))
 * Errata security advisory icons are missing on CVV page ([#9238](http://projects.theforeman.org/issues/9238), [bdc54e3a](http://github.com/katello/katello/commit/bdc54e3a6d03c2a2e0ded6ce38572e700ba25621))
 * apply errata confirm button does not disable when click, nor handle errors ([#9220](http://projects.theforeman.org/issues/9220), [58db89ae](http://github.com/katello/katello/commit/58db89ae45ca2e77ea5231e1b1588dbbd88d1461))
 * cancel button on errata apply does not work properly ([#9219](http://projects.theforeman.org/issues/9219), [473f4cf5](http://github.com/katello/katello/commit/473f4cf5d5126f01728c4302573a9d2aa0f1f257))
 * Sorting does not work on errata page ([#9181](http://projects.theforeman.org/issues/9181), [5c7b8974](http://github.com/katello/katello/commit/5c7b8974d751a542ab40b24b6c7ffa81ee9cd510))
 * Content Hosts Bulk Actions errata search different than individual content hosts errata search. ([#9180](http://projects.theforeman.org/issues/9180))
 * Composite content view publish puppet module by specified version (uuid) not working ([#9131](http://projects.theforeman.org/issues/9131), [8ad61197](http://github.com/katello/katello/commit/8ad61197895c1ad3d9494000dc24d2799fcc0e96))
 * Nothing happens when I try to sync a repository without a URL ([#9043](http://projects.theforeman.org/issues/9043))
 * ISE on bulk  repos sync page ([#8960](http://projects.theforeman.org/issues/8960), [2ada769e](http://github.com/katello/katello/commit/2ada769e4b4d6962184a9a29ae92ff947e749c8d))
 * Editing a Content Host allows you to add a Host Collections from a different organization ([#8951](http://projects.theforeman.org/issues/8951), [4a6ec6b3](http://github.com/katello/katello/commit/4a6ec6b3a66c2c20c0721b5821820d714f2c9b5d))
 * [CCJK] Unlocalized period next to the end sentence 'Red Hat Repositories page' locations' link in Activation Key->Product Content tab. ([#8936](http://projects.theforeman.org/issues/8936), [2b016667](http://github.com/katello/katello/commit/2b016667b51d2d654a10d9a8d773e680f932bb00))
 * Content > Sync Status: Don't need a period after "Only show syncing." ([#8931](http://projects.theforeman.org/issues/8931), [7ce5de93](http://github.com/katello/katello/commit/7ce5de936ffbed8cb50deee2fe8bd3bacb9a0f47))
 * Typo on Content View Publish New Version screen ([#8928](http://projects.theforeman.org/issues/8928), [57f8b59a](http://github.com/katello/katello/commit/57f8b59a2fa4f5fb212f909211045386fced40f2))
 * sync plan shows "never synced" for a repository even though it has been manually synchronised ([#8924](http://projects.theforeman.org/issues/8924), [56bb674f](http://github.com/katello/katello/commit/56bb674f7686d4d43f126e2df539353e399165e5))
 * Incorrect page title on version pages ([#8896](http://projects.theforeman.org/issues/8896))
 * Errata Details Page: Show N/A if CVE information is not present ([#8886](http://projects.theforeman.org/issues/8886), [7ef72c2f](http://github.com/katello/katello/commit/7ef72c2fac9c1dac03d8cdac6019fc6bcccc153d))
 * errata list affected host count only shows available ([#8870](http://projects.theforeman.org/issues/8870), [af3cb4a7](http://github.com/katello/katello/commit/af3cb4a723cc972a149f70fff6ba85deb472a4ee))
 * Activation key dynflow not updating properly ([#8867](http://projects.theforeman.org/issues/8867), [f8a35514](http://github.com/katello/katello/commit/f8a35514efbc2e34ce4b14edbdde2c145c96f92e))
 * UI does not allow setting activation key content host limit to 0 ([#8760](http://projects.theforeman.org/issues/8760))
 * content-hosts registration hint page is incorrect ([#8728](http://projects.theforeman.org/issues/8728), [0172068b](http://github.com/katello/katello/commit/0172068b062dbd4fb67f60705665038289258d0e))
 * "Upload Package" section of Product -> Repositories UI should not be displayed for Red Hat products ([#8684](http://projects.theforeman.org/issues/8684), [f80bb882](http://github.com/katello/katello/commit/f80bb8829280ede749a3e04d00b436ff2ec9be06))
 * Add environment filter to errata content hosts page ([#8482](http://projects.theforeman.org/issues/8482), [512b05ef](http://github.com/katello/katello/commit/512b05efac0c945099ae06e309be4332062bdb9d))
 * No feedback from Katello that there's no organization selected ([#8387](http://projects.theforeman.org/issues/8387), [91dd4dc5](http://github.com/katello/katello/commit/91dd4dc5bf864bda5a4f086ff3ea55391c6f45a8))
 * Activation key product content changes aren't reflected in the UI ([#8040](http://projects.theforeman.org/issues/8040), [1fa3e12d](http://github.com/katello/katello/commit/1fa3e12d129809f0583eec54037e8877c237b19a))
 * Subsequent syncs for a Docker repository generates massive stacktrace in the background ([#7944](http://projects.theforeman.org/issues/7944))
 * subscription details is missing virtual guest subscription and required host information ([#7176](http://projects.theforeman.org/issues/7176), [5e1b29fa](http://github.com/katello/katello/commit/5e1b29fa750415611a9a37564063cd1dbbb92f84))
 * Repositories with username/password can't be synced ([#6637](http://projects.theforeman.org/issues/6637), [a1c597d1](http://github.com/katello/katello/commit/a1c597d1ce5883d1b99d45551c81b4077e560ae7))

### Client/Agent
 * Updating client content view fails when client is registered to capsule ([#9883](http://projects.theforeman.org/issues/9883), [a6ca904f](http://github.com/katello/katello/commit/a6ca904fe2fd057e5606683e1354318cbc4f5da1))
 * remove katello-agent from epel ([#8576](http://projects.theforeman.org/issues/8576))

### API
 * Sat6 Content Hosts unusable after candlepin has an error in finding a unit ([#9872](http://projects.theforeman.org/issues/9872))
 * undefined method `docker_images' for <Katello::ContentViewVersion:0x00000013> ([#9755](http://projects.theforeman.org/issues/9755), [5aae5f8d](http://github.com/katello/katello/commit/5aae5f8ded418d29bbfc994d89723e19561d325a))
 * registered content-hosts are not able to update facts ([#9646](http://projects.theforeman.org/issues/9646), [4bc5956e](http://github.com/katello/katello/commit/4bc5956eeba875bd51fdf49f0eba25d2ae382440))
 * Unable to create lifecycle-env with cli or UI ([#9628](http://projects.theforeman.org/issues/9628), [d1b797a3](http://github.com/katello/katello/commit/d1b797a359c9a243219c786d10af3bbe3da583e9), [c2e56f85](http://github.com/katello/katello/commit/c2e56f85db2261a3af0fa7add7f8be693048f086))
 * Content View index page takes a long time to list ([#9564](http://projects.theforeman.org/issues/9564), [726b9c4f](http://github.com/katello/katello/commit/726b9c4f1b34635311074ac9a618d6231633e3b7))
 * Task failed with traceback, but task detail is success ([#9502](http://projects.theforeman.org/issues/9502), [33112a4e](http://github.com/katello/katello/commit/33112a4e0713904dbe40a755a94474c352b42a5f))
 * content view removal does not allow removal from env and deleting archive together ([#9402](http://projects.theforeman.org/issues/9402), [d3d620f9](http://github.com/katello/katello/commit/d3d620f971a27b6b0c60abacfd5d7c66a8fe1a60))
 * error fetching environment by name ([#9221](http://projects.theforeman.org/issues/9221), [4e15e0ef](http://github.com/katello/katello/commit/4e15e0efb9ac0362c971fe875bde297848de4163))
 * Incorrect data being returned when calling APIs that use chained joins and scoped search ([#9167](http://projects.theforeman.org/issues/9167), [25dda4c9](http://github.com/katello/katello/commit/25dda4c9d05a9f386eda118035ad18ce87f7f6f1))
 * better feedback around composites and incremental updates ([#9120](http://projects.theforeman.org/issues/9120), [518ca32c](http://github.com/katello/katello/commit/518ca32c130e0de73587d40744e4ec23b9454a4c))
 * systems controller index should handle multiple errata_ids ([#9051](http://projects.theforeman.org/issues/9051), [9a713de0](http://github.com/katello/katello/commit/9a713de014886ba6e361c6c1470a0c85a798dcdc))
 * Fixing a typo in the name of an action class ([#8961](http://projects.theforeman.org/issues/8961), [076794dd](http://github.com/katello/katello/commit/076794dd1287bf48a5e1db08e8a23c62815a6350))
 * Too many queries to list products - Satellite 6 - Slow Response Time ([#8954](http://projects.theforeman.org/issues/8954), [11eea886](http://github.com/katello/katello/commit/11eea88663ef47def9d0254a01ac07463dc24b09))
 * clean_backend_objects rake task seems broken ([#8860](http://projects.theforeman.org/issues/8860), [afe38fe0](http://github.com/katello/katello/commit/afe38fe0f0b195804a52a1079e3a86beeb3bb2f5))
 * Katello API throws an incorrect error when receiving non-json requests ([#8846](http://projects.theforeman.org/issues/8846), [50c3c9c3](http://github.com/katello/katello/commit/50c3c9c3db8a637e5034d9c1d44d6bc9808eedec))
 * API Delete activation key does not respond with content ([#8612](http://projects.theforeman.org/issues/8612), [16b0d916](http://github.com/katello/katello/commit/16b0d916b71c6b3db929b325c094b265e69204bb))

### CLI
 * hammer content-host update truncates content host information ([#9849](http://projects.theforeman.org/issues/9849))
 * Cannot use ``none`` for Sync Plan interval ([#9819](http://projects.theforeman.org/issues/9819), [97e93853](http://github.com/katello/katello/commit/97e93853139c616e1e67fef93402434bf54e7a80))
 * Org delete  fails in hammer and UI with API error ([#9798](http://projects.theforeman.org/issues/9798), [a312e17e](http://github.com/katello/katello/commit/a312e17ec9748fe1823723b3ace71bc04d165ebb))
 * hammer: content-view version list failed ([#9741](http://projects.theforeman.org/issues/9741), [a7a6192f](http://github.com/katello/katello/commit/a7a6192f7318c5083801ef4efe51061e8c31749f))
 * CLI: host-collection erratum install failed ([#9679](http://projects.theforeman.org/issues/9679), [d7a4dc62](http://github.com/katello/katello/commit/d7a4dc62f96bd5df6bb97a4f6f86d5f63efefe43))
 * hammer content-host list shows 'Available' errata instead of 'Installable' errata ([#9504](http://projects.theforeman.org/issues/9504), [28354997](http://github.com/katello/katello/commit/28354997d6af155e3b2dd9afb91771659618978f))
 * content-host errata apply gives success message for an invalid errata id  ([#9503](http://projects.theforeman.org/issues/9503), [33112a4e](http://github.com/katello/katello/commit/33112a4e0713904dbe40a755a94474c352b42a5f))
 * Activation Key content override accepts any value ([#9340](http://projects.theforeman.org/issues/9340), [bc668761](http://github.com/katello/katello/commit/bc66876163e0cd5f6ccaaaf7223f990147aea9d5))
 * hammer repository info does not show docker-upstream-name value ([#9226](http://projects.theforeman.org/issues/9226), [bfb6fa89](http://github.com/katello/katello/commit/bfb6fa89c4eecaefe7aeedecb5997b77691058c4))
 * Pagination control not supported for content view ([#9201](http://projects.theforeman.org/issues/9201), [89e4bb78](http://github.com/katello/katello/commit/89e4bb78044b69703775ecfaf9c502c849940889))
 * hammer content-view puppet-module add fails with 'Missing values for content_view_puppet_module' ([#9008](http://projects.theforeman.org/issues/9008), [d60510a0](http://github.com/katello/katello/commit/d60510a0830ca9065c378342a3c6e96796680687))
 * Updating host-collection using only id is failing ([#8974](http://projects.theforeman.org/issues/8974), [7e37fb8d](http://github.com/katello/katello/commit/7e37fb8de1470492db675b1d34b23f0ea6bfaa1c))
 * hammer content-view version publish no longer has content view params ([#8913](http://projects.theforeman.org/issues/8913), [e5c4b6b3](http://github.com/katello/katello/commit/e5c4b6b3653b9062fafa11faf75b61c6c364c071))
 * content-override does not produce an error when --label is missing ([#8892](http://projects.theforeman.org/issues/8892), [bc668761](http://github.com/katello/katello/commit/bc66876163e0cd5f6ccaaaf7223f990147aea9d5))
 * Auto attach is not included in activation-key info output ([#8891](http://projects.theforeman.org/issues/8891), [8ad52571](http://github.com/katello/katello/commit/8ad525715e7f32acd88d550c993364ff7e6bb716), [42d79435](http://github.com/katello/katello/commit/42d7943522fc83773c63c1910f205a935ed8e834))
 * Unable to update activation key by id ([#8833](http://projects.theforeman.org/issues/8833), [ac237cac](http://github.com/katello/katello/commit/ac237cac266b9580fcb9e52bf3348ab6af66d949))
 * Cannot add a puppet module to a content view by name ([#8583](http://projects.theforeman.org/issues/8583), [d08b9834](http://github.com/katello/katello/commit/d08b9834dd43a58104d34311ad485f50649686c1))
 * It's not possible to add a subscription on an activation key ([#8549](http://projects.theforeman.org/issues/8549), [36cdaf21](http://github.com/katello/katello/commit/36cdaf21cfaf3b45d5af39089b67704ed79ce8ec))
 * Promoting CVs with hammer results in error when referencing environment by name ([#8547](http://projects.theforeman.org/issues/8547), [1afcd902](http://github.com/katello/katello/commit/1afcd902eefc9846bdd3014f5189d94bdd2a7815))

### Packaging
 * additional packages needed for .30 qpid  ([#9838](http://projects.theforeman.org/issues/9838), [299aec36](http://github.com/katello/katello/commit/299aec364fc1b8cb9dcb50872f9acf83c20c4688))
 * allow katello-pulp spec to install 0.30 of qpid-cpp ([#9801](http://projects.theforeman.org/issues/9801))
 * katello should no longer depend on rubygems-devel ([#9707](http://projects.theforeman.org/issues/9707), [08ac6b60](http://github.com/katello/katello/commit/08ac6b606ee638cfd99edeb061f470502c4f890b))
 * Katello-debug does not collect installer logs ([#9530](http://projects.theforeman.org/issues/9530), [c34def9a](http://github.com/katello/katello/commit/c34def9a22545a6ff61487886062589370f9e933))
 * katello-common RPM symlinks to non-existant script ([#9337](http://projects.theforeman.org/issues/9337), [80f4081c](http://github.com/katello/katello/commit/80f4081c90ad1b1fe9563cf230c6d8abd074ff24))
 * Remove secret-token generation and shared secret from katello's specfile ([#8956](http://projects.theforeman.org/issues/8956), [80f4081c](http://github.com/katello/katello/commit/80f4081c90ad1b1fe9563cf230c6d8abd074ff24))
 * rpm build failure due to lack of version bump  ([#8776](http://projects.theforeman.org/issues/8776), [3521f490](http://github.com/katello/katello/commit/3521f4902c7c4484e89dcd315ca55df0a98d3732))
 * remove maruku as dependency ([#8681](http://projects.theforeman.org/issues/8681), [6fde2e99](http://github.com/katello/katello/commit/6fde2e9978b871df194fbaa48de9ea01505e729b))
 * el5 repos do not install on an el5 system ([#8544](http://projects.theforeman.org/issues/8544))

### Capsule
 * Capsule: cannot browse /pub using both http and https ([#9816](http://projects.theforeman.org/issues/9816), [bc4bff65](http://github.com/katello/katello/commit/bc4bff65feba51357cad134362b85adb885766f5))
 * failed errata apply does not show task as failed ([#9722](http://projects.theforeman.org/issues/9722), [19d6db33](http://github.com/katello/katello/commit/19d6db33a74a38368ef0563043fa6ff523da01ca))
 * Katello needs to activate pulp consumer as node ([#9521](http://projects.theforeman.org/issues/9521), [24d37557](http://github.com/katello/katello/commit/24d37557621be418f5bc2333acca2fdad60bb29f))
 * Repo create on renamed capsule ISEs ([#9209](http://projects.theforeman.org/issues/9209), [a9ee4823](http://github.com/katello/katello/commit/a9ee482323cfdc9f2bfbbfd1b09a3dba85dabc92))
 * pulp-manage-db fails during  capsule-installer ([#7817](http://projects.theforeman.org/issues/7817))

### Documentation
 * Align installation yum repo instructions with Foreman? ([#9749](http://projects.theforeman.org/issues/9749))
 * Content-view Documentation ([#9540](http://projects.theforeman.org/issues/9540))
 * Add time service information to the install documentation ([#8508](http://projects.theforeman.org/issues/8508), [dea28a31](http://github.com/katello/katello/commit/dea28a316220e75e942aa2e9ca32292f70f021db))
 * add security contact information to katello.org ([#7940](http://projects.theforeman.org/issues/7940))
 * katello.org is missing information about katello-agent ([#7735](http://projects.theforeman.org/issues/7735))
 * Add 'How to release Katello' guide to katello.org ([#7205](http://projects.theforeman.org/issues/7205))

### Upgrades
 * regenerate bootstrap rpm on upgrade ([#9665](http://projects.theforeman.org/issues/9665))
 * foreman-rake katello:upgrades:2.1:import_errata fails: wrong number of arguments ([#9354](http://projects.theforeman.org/issues/9354))

### Docker
 * Composite content view UI presents users with 'Docker Content' tab erroneously ([#9610](http://projects.theforeman.org/issues/9610), [348c8734](http://github.com/katello/katello/commit/348c8734a86e013874fcae8aeaeed7044d6008e0))
 * Add some tests for new DockerTag methods ([#9276](http://projects.theforeman.org/issues/9276), [c853bcfd](http://github.com/katello/katello/commit/c853bcfd1b039f9c5fb5dba3beda9a468dc2b237))
 * Validation error attempting to publish content view with docker content ([#9224](http://projects.theforeman.org/issues/9224), [2aa2347b](http://github.com/katello/katello/commit/2aa2347b7fd0d4b3fee574062863b2855c5a64a0))
 * Hard coded port for docker pull via capsule ([#9157](http://projects.theforeman.org/issues/9157))
 * Fix docker tag name on docker images show in CLI ([#9133](http://projects.theforeman.org/issues/9133), [2cc720f7](http://github.com/katello/katello/commit/2cc720f737d137afaf2009490efab1a9ae8a2c5e))
 * Sync task for docker repo indicates it found 522 images but upon inspection, there looks to be only 179 ([#8835](http://projects.theforeman.org/issues/8835))
 * Update katello code based on updates to foreman-docker ([#8634](http://projects.theforeman.org/issues/8634))
 * Remove column katello_repository_id from docker_images ([#8458](http://projects.theforeman.org/issues/8458))
 * Combine the docker-tag and docker-image commands to use one parent docker command ([#8437](http://projects.theforeman.org/issues/8437), [783e9ce8](http://github.com/katello/katello/commit/783e9ce838790a8a449cac17a478a1e268f644e5))
 * hammer  repository info commands need to show docker totals ([#8203](http://projects.theforeman.org/issues/8203), [bfb6fa89](http://github.com/katello/katello/commit/bfb6fa89c4eecaefe7aeedecb5997b77691058c4))

### Foreman Integration
 * All Hosts - Bulk Action - Delete throws error Dependent Content Host ([#9577](http://projects.theforeman.org/issues/9577), [6040e333](http://github.com/katello/katello/commit/6040e3337ea4d47109ad2b10c3d4cf537bcd0519))
 * Finish config template should also configure networking ([#9400](http://projects.theforeman.org/issues/9400), [2df454b6](http://github.com/katello/katello/commit/2df454b6aa92dc18e3c477350dd8bca44a8afe62))
 * Adding lifecycle environment to smart proxy results in ActiveRecord::RecordNotFound ([#9385](http://projects.theforeman.org/issues/9385))
 * Asset compilation broken by missing mixin 'border_radius' ([#9206](http://projects.theforeman.org/issues/9206), [538eb2a3](http://github.com/katello/katello/commit/538eb2a33d9171912c68064ef34a45f709a43049))
 * Foreman discovery does not work with develop/master (Foreman 1.8/Katello 2.2.) ([#9200](http://projects.theforeman.org/issues/9200), [46ce6ae9](http://github.com/katello/katello/commit/46ce6ae9acf1a4f189994670a77515790ebc8306), [d6b860ec](http://github.com/katello/katello/commit/d6b860ec12c775ed14572cd6ed4e7c01d5d6808c))
 * registering a client with nightly(katello+foreman) server raises: PGError: ERROR: column hosts.mac does not exist ([#9158](http://projects.theforeman.org/issues/9158), [8e90541e](http://github.com/katello/katello/commit/8e90541ed394e40f5cb47f4a33339aa9921306f8))
 * Cannot edit Foreman host after upgrading to next minor release ([#8415](http://projects.theforeman.org/issues/8415))
 * Unable to use cloned PXELinux global default template with 6.0.4 ([#7480](http://projects.theforeman.org/issues/7480), [268ea646](http://github.com/katello/katello/commit/268ea646bcc163956b73ae7c474f386774902550))

### SAM.next
 * sam-installer is not installing gutterball  ([#9535](http://projects.theforeman.org/issues/9535), [95df69b2](http://github.com/katello/katello/commit/95df69b2a9023a9b1c59d5edef5716be3bd39308))
 * [SAM] host collections / collection actions needs de-featuring ([#9360](http://projects.theforeman.org/issues/9360), [ce4152b3](http://github.com/katello/katello/commit/ce4152b38264c309e8df70432057ecc6b113dd71))
 * unable to use foreman with foreman_sam ([#9283](http://projects.theforeman.org/issues/9283))
 * [SAM] remove location from commands ([#9070](http://projects.theforeman.org/issues/9070), [9024aa62](http://github.com/katello/katello/commit/9024aa627646ba180e1af93c7517a5b94716950a))
 * sam-installer check that sam is installed instead of katello and rubygems-katello ([#9055](http://projects.theforeman.org/issues/9055))

### Tests
 * Tests can fail randomly when array order doesn't match ([#9525](http://projects.theforeman.org/issues/9525), [fce56d28](http://github.com/katello/katello/commit/fce56d28fe42314eb5474be3d241cc7f6b7c454b))
 * Unit tests failing on errata system_test ([#9428](http://projects.theforeman.org/issues/9428), [369c8331](http://github.com/katello/katello/commit/369c83317b290feea39c1c39f35bce15a214b232))
 * rubocop does not ignore engines/bastion_katello/node_modules/ files ([#8675](http://projects.theforeman.org/issues/8675), [d34fd064](http://github.com/katello/katello/commit/d34fd0643538bdac2ffd8a18ac8da2e7e147dec5))
 * add foreman-gutterball to build infrastructure ([#8584](http://projects.theforeman.org/issues/8584), [83eef5d9](http://github.com/katello/katello/commit/83eef5d92078f7a41e698d24883a156821ce528a))

### Errata Management
 * 500 when attempting to apply errata via content host bulk actions ([#9467](http://projects.theforeman.org/issues/9467), [265b2e90](http://github.com/katello/katello/commit/265b2e90a762affb7eea134e343f49279311fa20))
 * Cannot sync EPEL 7 repo ([#9211](http://projects.theforeman.org/issues/9211))
 * Race condition in indexing errata ([#8586](http://projects.theforeman.org/issues/8586))

### Gutterball
 * gutterball.conf missing gutterball.amqp.connect  ([#9466](http://projects.theforeman.org/issues/9466), [cf6ad85f](http://github.com/katello/katello/commit/cf6ad85fbf76b4bba7684838ab2e958d5ac9f6ff))

### Content Views
 * Content View update - needs to be dynflow'ed ([#9416](http://projects.theforeman.org/issues/9416), [7666b964](http://github.com/katello/katello/commit/7666b964ea3a14e1eb4a4c53374f903b209154d3))
 * immediately publish redhat repos upon creation ([#8938](http://projects.theforeman.org/issues/8938), [5bcf6f45](http://github.com/katello/katello/commit/5bcf6f45bcfc08419402cc7ba37885c2d8649984))
 * When creating a composite content view, the components page is initially blank ([#8834](http://projects.theforeman.org/issues/8834), [ec0fab27](http://github.com/katello/katello/commit/ec0fab27970148098959244c9292cac9b927f3e8))
 * CV repo list/remove shows wrong repos ([#8494](http://projects.theforeman.org/issues/8494), [3be9e06a](http://github.com/katello/katello/commit/3be9e06a2602c007cf8730c48315906450848dde))

### SElinux
 * Support for http(s) proxy communication on 3128/8080 ports ([#9216](http://projects.theforeman.org/issues/9216))
 * Katello plugin connects to AMQP port ([#9106](http://projects.theforeman.org/issues/9106))
 * Allow TCP bind for 5000 - pulp/crane service ([#8683](http://projects.theforeman.org/issues/8683), [8e0fa8e3](http://github.com/katello/katello/commit/8e0fa8e3dc823e479c79c17e55b05e52b12ae959))

### Puppet
 * Foreman proxy cert not being generated by installer ([#9204](http://projects.theforeman.org/issues/9204), [046627bc](http://github.com/katello/katello/commit/046627bc43a91280e9009e5481bccfd4943388b2))

### Candlepin
 * foreman-tasks qpid connection seems broken ([#9068](http://projects.theforeman.org/issues/9068))
 * foreman_gutterball RPM doesn't install files to the right location ([#8864](http://projects.theforeman.org/issues/8864))

### Pulp
 * Getting a 401 error in test/glue/pulp/erratum_test.rb ([#8768](http://projects.theforeman.org/issues/8768), [5c47dc28](http://github.com/katello/katello/commit/5c47dc28a4aca9a0806cc36cfa64c2dd9ca05f6f))

### Orchestration
 * On unclear restart, the start occasionally fails with Action Actions::Candlepin::ListenOnCandlepinEvents is already active ([#8725](http://projects.theforeman.org/issues/8725))
 * Dynflowize system update ([#6184](http://projects.theforeman.org/issues/6184), [729f9f43](http://github.com/katello/katello/commit/729f9f434a03323856bd8eab2180508ac79420a1))

### Katello Agent
 * goferd not available in Katello Agent for EPEL6 repository ([#8575](http://projects.theforeman.org/issues/8575), [b4b4e2d4](http://github.com/katello/katello/commit/b4b4e2d44a804ba36743610006acef2af5ee2db5))

### Other
 * Removing a product from a sync plan does not remove the sync schedule from the repositories in pulp ([#9866](http://projects.theforeman.org/issues/9866))
 * sync plan 'enabled' flag does not actually control pulp's sync plan ([#9818](http://projects.theforeman.org/issues/9818))
 * Firewall ports for qpidd/katello-agent need to be updated ([#9817](http://projects.theforeman.org/issues/9817))
 * In Errata -> Content hosts tab - Check box to filter out content hosts based on Life cycle environment does not work ([#9737](http://projects.theforeman.org/issues/9737), [223b6b65](http://github.com/katello/katello/commit/223b6b656645389b55999c05bc18bd2ebadeecbf))
 * Error undefined local variable or method `resolve_dependencies' when attempting to incrementally update a puppet module ([#9734](http://projects.theforeman.org/issues/9734))
 * Installer should lock puppet-pulp to 0.1.0 ([#9715](http://projects.theforeman.org/issues/9715), [6b0d7b65](http://github.com/katello/katello/commit/6b0d7b650b78f76deb539782b20e0d2e9d56f80c))
 * Installer logs on EL6 contain error messages for certutil ([#9699](http://projects.theforeman.org/issues/9699), [bfc4c389](http://github.com/katello/katello/commit/bfc4c389ca97db9e5b57ea85971c1f148b29e465))
 * Need to specify cdn registry scheme based of cdn scheme ([#9688](http://projects.theforeman.org/issues/9688), [aafec58f](http://github.com/katello/katello/commit/aafec58fab020370cf304c2844152fc60062ed63))
 * From RHEL 7 client I miss a lot of yum package groups ([#9652](http://projects.theforeman.org/issues/9652))
 * "Apply Selected" errata workflow does not have an "Are you sure?" check ([#9474](http://projects.theforeman.org/issues/9474), [6be4de9e](http://github.com/katello/katello/commit/6be4de9ed926524522a2323f60f89a941f0b2497))
 * What is this products.json file and what'll happen when if I delete it? ([#9421](http://projects.theforeman.org/issues/9421), [dcf0061c](http://github.com/katello/katello/commit/dcf0061c31cd2ee61916519d48fb75b829cc4d3b))
 * Activation key w/auto-attach=true does not attach custom products ([#9405](http://projects.theforeman.org/issues/9405), [b2382be3](http://github.com/katello/katello/commit/b2382be35ca7badb0b52f7da8acb3c8837590414))
 * Assets precompile fails with 'invalid byte sequence US-ASCII' ([#9370](http://projects.theforeman.org/issues/9370), [ac38df30](http://github.com/katello/katello/commit/ac38df30f36fc0ba64ca2feedeb5b225d6df584d))
 * Missing uuidtools build dependency in katello.spec ([#9174](http://projects.theforeman.org/issues/9174))
 * foreman-debug does not contain main mongodb logfile ([#9079](http://projects.theforeman.org/issues/9079), [9ba969b7](http://github.com/katello/katello/commit/9ba969b7933a47caa8fa819b00b39361852eb2dc))
 * Support qpid 0.30 for downstream ([#9069](http://projects.theforeman.org/issues/9069), [292a76cf](http://github.com/katello/katello/commit/292a76cf285c6b13e0fd66eb1e55b28f4ee96aad))
 * Satellite 6.0 manifest cannot be refreshed after updating entitlements ([#9011](http://projects.theforeman.org/issues/9011), [90f0f8e1](http://github.com/katello/katello/commit/90f0f8e1f06401826f12e775765aef32eb3f3e16))
 * unable to install unsigned packages ([#8973](http://projects.theforeman.org/issues/8973))
 * repositories of Composite Views in Content Views not counted ([#8964](http://projects.theforeman.org/issues/8964), [b4e69b7a](http://github.com/katello/katello/commit/b4e69b7a24bbfb377c3a3e6205e2c9f923f4e894))
 * reverts table columns for SAM feature flags ([#8935](http://projects.theforeman.org/issues/8935), [f871dbae](http://github.com/katello/katello/commit/f871dbaea8f4fdcf41a7fdd84d87e79be594c9ef))
 * PUT refresh_manifest api call not setting content-type ([#8933](http://projects.theforeman.org/issues/8933), [3f1de643](http://github.com/katello/katello/commit/3f1de643bbe9d22f3743d5f730c0dca7dce01a91))
 * add foreman_sam to build infrastructure ([#8596](http://projects.theforeman.org/issues/8596), [f936737e](http://github.com/katello/katello/commit/f936737e6c2acc0cfabfd33532c8baeaa004611e))
