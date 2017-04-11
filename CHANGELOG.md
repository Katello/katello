# 3.4.0  (2017-04-11)

## Features

### Hammer
 * hammer  host subscriptions product-content  needs to show available product content  ([#19080](http://projects.theforeman.org/issues/19080))
 * hammer  host subscriptions content overrides needs to use updated api ([#18860](http://projects.theforeman.org/issues/18860))
 * Add content-view purge command ([#14611](http://projects.theforeman.org/issues/14611), [30d74bb7](http://github.com/katello/hammer-cli-katello/commit/30d74bb7eb833564f79d5cb542b6f99a16158c40))

### Hosts
 * [UX] selection choices for content host subscriptions ([#18897](http://projects.theforeman.org/issues/18897), [c6cd5dc9](http://github.com/katello/katello/commit/c6cd5dc9fffe9c9a169b3f0abfbe1353a706e519), [21402b70](http://github.com/katello/katello/commit/21402b7081cb51b18b5ead9d96745ce8e84438ed))
 * [RFE] Traces should effect the hosts status ([#18895](http://projects.theforeman.org/issues/18895), [3dd72391](http://github.com/katello/katello/commit/3dd723917444e760c3a6dc31048861c61ab4174d))
 * Need API's to content overrides for single host ([#18859](http://projects.theforeman.org/issues/18859), [43f1e810](http://github.com/katello/katello/commit/43f1e810cd63bee37fe50fe735d313bec20b1863))
 * Need API's to content overrides for AK ([#18774](http://projects.theforeman.org/issues/18774), [7f987c9c](http://github.com/katello/katello/commit/7f987c9cbce48cd482be1e3bee86f6f1ddc73708))
 * Include Host's Host Collection to YAML definition. ([#17215](http://projects.theforeman.org/issues/17215), [9d063d5d](http://github.com/katello/katello/commit/9d063d5de2aa0143974481b40a0a6ae37f7b47b6))
 * Need API's to content overrides for bulk hosts ([#18773](http://projects.theforeman.org/issues/18773), [ed21e2e7](http://github.com/katello/katello/commit/ed21e2e7554ca50607f4c4f4e364fd1509493e0b))

### Repositories
 * Add UI page to manage file content in a repository ([#18755](http://projects.theforeman.org/issues/18755), [0812a6f8](http://github.com/katello/katello/commit/0812a6f8ed282f39f16237501bc4f77861df3168))
 * Add top level file type UI page ([#18754](http://projects.theforeman.org/issues/18754), [a216a1a8](http://github.com/katello/katello/commit/a216a1a89e0da8f432857c5c2abe427acaf76e99))
 * Add option to force sync repository ([#18558](http://projects.theforeman.org/issues/18558), [71532079](http://github.com/katello/katello/commit/71532079d8be4d3220372311a9ec990355a125cc), [241d6aac](http://github.com/katello/katello/commit/241d6aacf3df7564d0676d774afe1fe077c2b772))
 * OSTree Sync pulls only the latest version ([#17427](http://projects.theforeman.org/issues/17427), [dffc419f](http://github.com/katello/katello/commit/dffc419fa416148352f682823a8b22dc161dacbd))

### Tooling
 * Need a way to run bunch of tests based of wildcard ([#18727](http://projects.theforeman.org/issues/18727), [32ee9253](http://github.com/katello/katello/commit/32ee925336ce3e0d93c948aadea2ea0e7b4a27e7))

### Content Views
 * Allow force republish of content view version repos ([#18524](http://projects.theforeman.org/issues/18524), [4043cba5](http://github.com/katello/katello/commit/4043cba551e155a9221304dc44723637101b2a5d), [ac94a150](http://github.com/katello/hammer-cli-katello/commit/ac94a15035648eaa934b71ad77751eab3292ef92))
 * Add content counters to Content View Versions Repositories overview ([#16276](http://projects.theforeman.org/issues/16276), [417ec5f7](http://github.com/katello/katello/commit/417ec5f7ebd69b0c900692b69b3c5aa672dc8f82))

### Subscriptions
 * [UI] As a user, I want the product content UI pages to be a table. ([#18452](http://projects.theforeman.org/issues/18452), [99d4362f](http://github.com/katello/katello/commit/99d4362fb8eff8ac67bf643860f4e3ab1dd3053f))
 * Refreshing a manifest should re-generate entitlement certificates. ([#17970](http://projects.theforeman.org/issues/17970), [eecfd963](http://github.com/katello/katello/commit/eecfd96324778ba67cf92264f3c4e08077044671))
 * Enhance UI to make the need for virt-who apparent ([#17622](http://projects.theforeman.org/issues/17622), [d6f204f2](http://github.com/katello/katello/commit/d6f204f272ea44cef4ed6fda39b2bd0c24eb3899), [d1eae9fb](http://github.com/katello/katello-installer/commit/d1eae9fb00c2ee3f285b847b75ca1eecf8875d9b), [17171be4](http://github.com/katello/katello-installer/commit/17171be419a47e372db2b9d0882f03dda811d728))
 * As a user, I want future-dated subscriptions to be displayed. ([#18631](http://projects.theforeman.org/issues/18631), [453ec560](http://github.com/katello/katello/commit/453ec5607da40441e137e42337eeaa75c3ed3dba))

### Docker
 * repo search for docker image repos using the results of docker search ([#18253](http://projects.theforeman.org/issues/18253), [bac0eb30](http://github.com/katello/katello/commit/bac0eb3016b269088af2f43df26b1f1433c1c85d))

### Installer
 * Ask users to run foreman-tail during upgrade ([#18196](http://projects.theforeman.org/issues/18196), [f6798ac6](http://github.com/katello/katello-installer/commit/f6798ac64c9df6333707a59820a4dca78c3db0bd))

### Web UI
 * Remove nutupane from task details ([#18050](http://projects.theforeman.org/issues/18050), [076d8e0d](http://github.com/katello/katello/commit/076d8e0d159a36e83d3c08ca3a25e9b9b207574a))
 * Remove nutupane from environment pages ([#18049](http://projects.theforeman.org/issues/18049), [0f9d12d0](http://github.com/katello/katello/commit/0f9d12d0a7d9c7ab6b59b5ce9c847e32458b0013))
 * Remove nutupane from puppet modules pages ([#17640](http://projects.theforeman.org/issues/17640), [a848d32d](http://github.com/katello/katello/commit/a848d32de67b8566f185d77dddbab5e3d05a40ad))
 * Add links to the refresh manifest kcs article ([#17220](http://projects.theforeman.org/issues/17220))
 * Remove Nutupane from Content Host pages ([#17168](http://projects.theforeman.org/issues/17168), [cfa1b54a](http://github.com/katello/katello/commit/cfa1b54ab2b3b777e94e5edd9143d7ab0aa59dd1))
 * Remove Nutupane from Errata Pages ([#17163](http://projects.theforeman.org/issues/17163), [b67a1eb2](http://github.com/katello/katello/commit/b67a1eb26cc7c29a653f2ffe5fbe5ae7d07245f8))

### Candlepin
 * Add ability to search for hypervisors and guests ([#17148](http://projects.theforeman.org/issues/17148), [e688d31a](http://github.com/katello/katello/commit/e688d31adba2f84f30d1a6f6489c1f81c0e7e88b))
 * CP 2.0: Phase 1: Update katello layers to support new katello-candlepin ruby bindings ([#17029](http://projects.theforeman.org/issues/17029), [aad62cc6](http://github.com/katello/katello/commit/aad62cc6dae670565218f7434a4e908550244b41))
 * CP 2.0: Phase 1: Update katello-candlepin ruby bindings ([#17028](http://projects.theforeman.org/issues/17028), [aad62cc6](http://github.com/katello/katello/commit/aad62cc6dae670565218f7434a4e908550244b41))

### API
 * API Missing activation key listing available service_levels ([#8407](http://projects.theforeman.org/issues/8407), [a6c50d0f](http://github.com/katello/hammer-cli-katello/commit/a6c50d0f6797c81e0baa516bd4e64625fc8c9a83))

### Other
 * [RFE] Allow creating package groups via API  ([#18497](http://projects.theforeman.org/issues/18497), [c641bed6](http://github.com/katello/katello/commit/c641bed6f8401c40760b7fc74a76b1d44a8a43ac))
 * Satellite 6: database online-backup should add pg_dumpall -g to include global permissions ([#18335](http://projects.theforeman.org/issues/18335), [5634ee0d](http://github.com/katello/katello-packaging/commit/5634ee0d2d785f894bbb289ca4d7880416edacec))
 * Remove nutupane from OSTree branches pages ([#17642](http://projects.theforeman.org/issues/17642), [16bba7aa](http://github.com/katello/katello/commit/16bba7aa22765adb2b9111859b7eadf677aadfbb))
 * Eliminate capsule-remove in favor of katello-remove ([#17567](http://projects.theforeman.org/issues/17567), [9b68a1fb](http://github.com/katello/katello-packaging/commit/9b68a1fb7a5b1365252d18fe03bbedf1551b3fc4))
 * Upgrade bastion to 5.0.0 part 2 the sequel ([#19074](http://projects.theforeman.org/issues/19074), [57190666](http://github.com/katello/katello-packaging/commit/5719066637386b63b688ed96dfd3191daaa33949))

## Bug Fixes

### Installer
 * Add foreman CLI deployment through installer ([#19118](http://projects.theforeman.org/issues/19118), [730de817](http://github.com/katello/katello-installer/commit/730de817f3681978ba5efc33b7394337719aa577))
 * katello-certs-check doesn't check expiration date ([#18849](http://projects.theforeman.org/issues/18849), [9abe1bfd](http://github.com/katello/katello-installer/commit/9abe1bfdbc02811dcc8295d114805d4fa54ab66c), [3e03c6f9](http://github.com/katello/katello-installer/commit/3e03c6f93467eafbabeb40269538524018b86ea7))
 * Content hosts show red untitled status from webui yet subscribed from command line, as well as green fully entitled with no subscription attached ([#18812](http://projects.theforeman.org/issues/18812), [151c4071](http://github.com/katello//commit/151c407182f616509f0bb490244156cc832a098a), [ba8aae68](http://github.com/katello//commit/ba8aae68386aa352149822fd9937decdf2677232))
 * Cannot enable compute resource via "foreman-installer --scenario katello" ([#18641](http://projects.theforeman.org/issues/18641), [a2b03315](http://github.com/katello/katello-installer/commit/a2b03315d50273214cd6a5092e921010f302b6f9))
 * Update pulp server conf template 2.12 ([#18617](http://projects.theforeman.org/issues/18617))
 * Not all foreman modules are excluded from the parser cache ([#18543](http://projects.theforeman.org/issues/18543), [e252f931](http://github.com/katello/katello-installer/commit/e252f931e8c08b5fe6cafdc513379abbd1ca71ee))
 * Katello is not able to sync OSTree contents using proxy ([#18484](http://projects.theforeman.org/issues/18484))
 * Update installer upgrade process to include resolving data integrity issues. ([#18405](http://projects.theforeman.org/issues/18405), [009c33d6](http://github.com/katello/katello-installer/commit/009c33d62593f343948f01dc803641387a1fd79f))
 * Capsule-certs-generate` asks to register capsule to `Default Organization` instead of org set at install ([#18247](http://projects.theforeman.org/issues/18247), [8af1cea7](http://github.com/katello/katello-installer/commit/8af1cea7fd8f7dcde1db69cdbc19d4451aa4ff8a), [347405a3](http://github.com/katello/katello-packaging/commit/347405a353906fa8d6e176d83ade0dcc9a345c4c))
 * Typos in installer --help ([#17986](http://projects.theforeman.org/issues/17986), [7c91a681](http://github.com/katello/katello-installer/commit/7c91a6813c2dc672346e948950b65fdb45fc7a2c))
 * candlepin uses ca cert for server cert ([#17378](http://projects.theforeman.org/issues/17378), [b0c60e73](http://github.com/katello//commit/b0c60e735106f1052af81315f3b14afeafe7c141))
 * Enable Process Recycling for Pulp Worker Processes ([#17298](http://projects.theforeman.org/issues/17298), [59961f35](http://github.com/katello//commit/59961f35197c0b28d7f6a593997907f3575d0932))
 * obsolete squid directives ([#17219](http://projects.theforeman.org/issues/17219))
 * Repeated SSL warnings in httpd logs ([#16256](http://projects.theforeman.org/issues/16256), [0ae1d294](http://github.com/katello//commit/0ae1d294a71129a9d00eca3d8574a663da0ef4ff))
 * Fix indentation in answers files ([#18884](http://projects.theforeman.org/issues/18884), [d1f7895d](http://github.com/katello/katello-installer/commit/d1f7895d0997757d34a10803654514e06f61e7fe))

### Web UI
 * Tasks table not setting table.working to false correctly ([#19089](http://projects.theforeman.org/issues/19089), [c8dcb913](http://github.com/katello/katello/commit/c8dcb9138f6c126efd9db5113d83fb3f410331c3))
 * Fix katello models to not have red confirmation buttons unless an action is destructive ([#18939](http://projects.theforeman.org/issues/18939), [fba91e71](http://github.com/katello/katello/commit/fba91e71c0cfcecd5803c9c100de7c131b6cf210))
 * Content Hosts Traces page doesnt work ([#18891](http://projects.theforeman.org/issues/18891), [0a1d47fc](http://github.com/katello/katello/commit/0a1d47fc155474ffb03c23e05db18549db36abd3))
 * checkboxes in forms should have the label and checkbox in-line ([#18526](http://projects.theforeman.org/issues/18526), [6f0f05d0](http://github.com/katello/katello/commit/6f0f05d0faa2cf22ecdb848d95d065e74b8582a1))
 * Some styling issues on the content view filter pages ([#18383](http://projects.theforeman.org/issues/18383), [ce27fe31](http://github.com/katello/katello/commit/ce27fe3191fd1832ca5ba1b920af44fd31639e2f))
 * undefined local variable error when navigating to red hat repositories page ([#18188](http://projects.theforeman.org/issues/18188), [8da4ac05](http://github.com/katello/katello/commit/8da4ac0528c9485e339aa9f84f9be88498933c65))
 * Use ReactJsHelper on Sync controller ([#18166](http://projects.theforeman.org/issues/18166), [4dae79f3](http://github.com/katello/katello/commit/4dae79f334d42bb353878ab49c264230fbf0efea))
 * unable to set focus in text field of content host bulk actions errata modal ([#18140](http://projects.theforeman.org/issues/18140), [a13c53f1](http://github.com/katello/katello/commit/a13c53f1f46ef413aba37d6686dbbebc110f4953))
 * Create blue primary buttons for each page ([#17966](http://projects.theforeman.org/issues/17966), [0e8b94ec](http://github.com/katello/katello/commit/0e8b94ecf3479eaf01619d9abd143528fa11f196))
 * Update the button label from New XXX to Create XXX ([#17882](http://projects.theforeman.org/issues/17882), [0f05ff6b](http://github.com/katello/katello/commit/0f05ff6bc6731453094a3d4c9cc639c228a10c4b))
 * Replace secondary add/remove tabs with patternfly secondary tabs ([#17555](http://projects.theforeman.org/issues/17555), [fc629636](http://github.com/katello/katello/commit/fc629636166cca65027288d9c392311e6034f79d))
 * Incorrect memory value under content host properties ([#17132](http://projects.theforeman.org/issues/17132), [6a0f3c74](http://github.com/katello/katello/commit/6a0f3c74a9c3db19b02e13cdee8ba305ae0d39f4))
 * Upload manifest button should lock out ([#15396](http://projects.theforeman.org/issues/15396), [c5264fc5](http://github.com/katello/katello/commit/c5264fc5f9a923af2cc7beecc9759cc48c58c7db))
 * Empty name and Version in Composite Content View (WebUI) ([#18820](http://projects.theforeman.org/issues/18820), [798a84b8](http://github.com/katello/katello/commit/798a84b890ee8722010fb3e67ec285ca80117f59))
 * 3.3 - Search box is small on CV puppet modules page ([#18827](http://projects.theforeman.org/issues/18827))
 * [RFE] add confirmation step for manifest deletion (explaining when refresh will do, and when have to use delete) ([#18696](http://projects.theforeman.org/issues/18696), [367b534f](http://github.com/katello/katello/commit/367b534fa1fbe009e45282cf55baa27a4bd2546f))
 * Upgrade bastion to 5.0.0 ([#19073](http://projects.theforeman.org/issues/19073), [634a3dab](http://github.com/katello/katello/commit/634a3dab6e3c67f5907625b2aa50377de84840da))

### Hosts
 * Need to address Inconsistent Json between product content jsons ([#19057](http://projects.theforeman.org/issues/19057), [218d4db8](http://github.com/katello/katello/commit/218d4db8f5c80600ec85d9ba8dd1439dd167fb8e))
 * registration with activation key fails with 'Couldn't find Domain with 'id'=1 [WHERE (1=0)]' ([#18759](http://projects.theforeman.org/issues/18759), [028b832a](http://github.com/katello/katello/commit/028b832a2975a45d8610817536f7f456d6e97139))
 * Can't enter text in box in manage packages modal ([#18711](http://projects.theforeman.org/issues/18711), [4dd4d92f](http://github.com/katello/katello/commit/4dd4d92fbe64fd7e91c153e3266343e4da0d950b))
 * [UX] bookmark search on content hosts add subscriptions page does not specify controller param ([#18634](http://projects.theforeman.org/issues/18634), [4186110a](http://github.com/katello/katello/commit/4186110aadfc5fe07ab3cb7e268e1bad04e26d3b))
 * [UX] host UI page link to content host incorrect ([#18465](http://projects.theforeman.org/issues/18465), [5f03f9a1](http://github.com/katello/katello/commit/5f03f9a159f1ccae4a737b0f62886fafaf6a6f77))
 * searching on content hosts page and hitting enter opens 'register a host' page instead of searching ([#18448](http://projects.theforeman.org/issues/18448), [7016e5d6](http://github.com/katello/katello/commit/7016e5d600b853dd4c32ee58f9996ff8b98170a5))
 * [UX] content host page for unregistered host shows both states ([#18423](http://projects.theforeman.org/issues/18423), [499e326a](http://github.com/katello/katello/commit/499e326ae357a17caab347d650f0d2cc3bb7adf0))
 * db:migrate fails with wrong number of arguments (1 for 0) due to pagelets change ([#18360](http://projects.theforeman.org/issues/18360), [b90716cb](http://github.com/katello/katello/commit/b90716cb621954ff76f766b9d1e3a92c622ac5a6))
 * [UX] change dropdown buttons in katello to use "Select Action" and correct patternfly styling ([#18370](http://projects.theforeman.org/issues/18370), [4aaf93aa](http://github.com/katello/katello/commit/4aaf93aa84cad0c7b8a8f7222594f17cc3a31a46))

### Subscriptions
 * Getting error "no implicit conversion of Fixnum into String" while performing manifest refresh ([#19042](http://projects.theforeman.org/issues/19042), [59799d59](http://github.com/katello/katello/commit/59799d596e852f25e2e05cbde4e8f5eb7a65be3a))
 * candlepin /pools API deprecated ([#18896](http://projects.theforeman.org/issues/18896), [b6f876d4](http://github.com/katello/katello/commit/b6f876d4cbf547c65329196adc942f535347e45d))
 * [UX] "Manage Manifest" button on subscriptions page should land on "Import/Remove Manifest" page ([#18580](http://projects.theforeman.org/issues/18580), [273ee8d4](http://github.com/katello/katello/commit/273ee8d4a1fec9c320e05bb48fe6ee117729596a))
 * Standard user is unable to access  "Red Hat Subscriptions" page ([#17757](http://projects.theforeman.org/issues/17757), [69175798](http://github.com/katello/katello/commit/691757985133710c1de7cc62535e2f50411035a6))
 * create a virt-who guest and hypervisor report ([#17663](http://projects.theforeman.org/issues/17663), [9c283d9e](http://github.com/katello/katello/commit/9c283d9ec0830ffc554d94179df49151c0b2a425))
 * removing multiple subscriptions causes parallel calls to candlepin ([#19158](http://projects.theforeman.org/issues/19158), [e95fc6d6](http://github.com/katello/katello/commit/e95fc6d637b7dcc0775b17ac80082f93b2eb8b90))
 * uploading facts involves synchronous dynflow task, can cause bottleneck ([#19061](http://projects.theforeman.org/issues/19061), [d80a3f67](http://github.com/katello/katello/commit/d80a3f67691b1ca4aab7c1d5312ca586fd6897f0))

### Client/Agent
 * After katello-agent installation goferd is not started ([#19038](http://projects.theforeman.org/issues/19038), [5bda77da](http://github.com/katello/katello-packaging/commit/5bda77da0e7680e8db55d542cb1c181554105b4a))
 * goferd segfaults while pushing erratas to 1K clients ([#18406](http://projects.theforeman.org/issues/18406), [070ea706](http://github.com/katello/katello-agent/commit/070ea7064575fccf8de7bf92b45bf7491c4caac3))

### Foreman Proxy Content
 * Pulp Node inconsistencies ([#19016](http://projects.theforeman.org/issues/19016), [f4c18c16](http://github.com/katello//commit/f4c18c16ce2642510b05a058fde577e5c809901b))
 * syncing a capsule fails with ActiveRecord::RecordNotFound  Couldn't find SmartProxy with 'id'=2 ([#18656](http://projects.theforeman.org/issues/18656), [8f19bafc](http://github.com/katello/katello/commit/8f19bafcd9e011a843413fffef9ba3ec3dbbb617))
 * Weight capsule sync tasks appropriately  ([#18416](http://projects.theforeman.org/issues/18416), [166b598c](http://github.com/katello/katello/commit/166b598ce6a50c639d51a0b34ece5336106ebdb4))
 * Unable to delete smart-proxies ([#19010](http://projects.theforeman.org/issues/19010), [a345dc12](http://github.com/katello/katello/commit/a345dc1203812b2eacfad024e991de53ec70d5ea))
 * Race condition among capsule sync tasks to destroy/create pulp repos ([#18706](http://projects.theforeman.org/issues/18706), [271f5808](http://github.com/katello/katello/commit/271f580840ca34c7f3ea5938323ca2b401661831))
 * smart proxy refresh throws stackerror ([#18185](http://projects.theforeman.org/issues/18185), [1e8efa1e](http://github.com/katello/katello/commit/1e8efa1ed249099beaa5114a93eb148255937bcf))

### Tests
 * tests failing with ArgumentError: invalid byte sequence in UTF-8 ([#18991](http://projects.theforeman.org/issues/18991), [d6f2b3c1](http://github.com/katello/katello/commit/d6f2b3c1c5e861c7482d940e5fdc1147c28914eb))
 * Make sure permissions are present before test execution ([#18832](http://projects.theforeman.org/issues/18832), [88762925](http://github.com/katello/katello/commit/887629251e9d47a31006ae5daed2fca4fbcc48d3), [6b169375](http://github.com/katello/katello/commit/6b1693754d2e11852b40a173c4dd7a604d326619), [1040567e](http://github.com/katello/katello/commit/1040567e8d432d6768592dadf415fe8e777f29bf))
 * require test file in content_view/puppet_module/add_test.rb ([#18749](http://projects.theforeman.org/issues/18749), [b426247e](http://github.com/katello/hammer-cli-katello/commit/b426247e2bc1a41308d3a39431e3c04872aa60d1))
 * VCR test fails on json 2.* ([#18669](http://projects.theforeman.org/issues/18669), [21789de7](http://github.com/katello/katello/commit/21789de7cf401aabeddc249609552647d51010e7))
 * rake katello:rubocop does not provide accurate return code ([#18503](http://projects.theforeman.org/issues/18503), [a4ec6015](http://github.com/katello/katello/commit/a4ec6015325169e7d164373b7d85c5290c5490f5))
 * require test file in content_view add_repository_test.rb ([#18392](http://projects.theforeman.org/issues/18392), [f6d7bb23](http://github.com/katello/hammer-cli-katello/commit/f6d7bb23c56e8d135313cb0f88dcf2d7adb6c295))
 * Fix typo in unify_hosts script ([#19100](http://projects.theforeman.org/issues/19100), [00bae46f](http://github.com/katello/katello/commit/00bae46f965a43831b43eea1cee32d157298f29b))

### Candlepin
 * rake katello:clean_backend_objects fails with Must specify at least one search criteria. ([#18984](http://projects.theforeman.org/issues/18984), [e985ff12](http://github.com/katello/katello/commit/e985ff120baf6948b6ed9e76cb67a24fd4ae5a13))
 * candlepin 2.0 requires numeric ids for products ([#18413](http://projects.theforeman.org/issues/18413), [6332e46d](http://github.com/katello/katello/commit/6332e46ddc186ba66f0f9e939d3828b5bf991755))

### Dashboard
 * Latest errata widget host count isn't correctly pluralized ([#18979](http://projects.theforeman.org/issues/18979), [37be60a4](http://github.com/katello/katello/commit/37be60a44e2c55bc387edcb75a94771953d4734b))

### Content Views
 * identify pulp errata by id only, to save pulp celery memory ([#18916](http://projects.theforeman.org/issues/18916), [c83af869](http://github.com/katello/katello/commit/c83af8691f238ac106b416b8574140d069342295))
 * publishing a puppet module in a content view errors ([#18848](http://projects.theforeman.org/issues/18848), [7dd24a1f](http://github.com/katello/katello/commit/7dd24a1fa80009370dbbdfa3fabfa85d87d3502e))
 * Publish content view with puppet module fails "Validation failed: Puppet environment can't be blank" ([#18819](http://projects.theforeman.org/issues/18819), [b941f26a](http://github.com/katello/katello/commit/b941f26a2a07697224b7e9bba6b6a780109341c1))
 * link from a yum repository in a content view does nothing ([#18578](http://projects.theforeman.org/issues/18578), [fb45b98e](http://github.com/katello/katello/commit/fb45b98ebdd1ba1357807614830d1b8924191043))
 * auto-complete tag name on content view docker tag no longer working ([#18577](http://projects.theforeman.org/issues/18577), [09fe2854](http://github.com/katello/katello/commit/09fe2854f959a35cb12eaeeb0f92d86c246a7a9c))
 * errata by date content view filters do not display the dates properly ([#18420](http://projects.theforeman.org/issues/18420), [24e29069](http://github.com/katello/katello/commit/24e2906909ff239cdc715ba3c65c3086a0eeeb27))
 * katello errata by date content view filter cannot be created in ui ([#18419](http://projects.theforeman.org/issues/18419), [c96c7755](http://github.com/katello/katello/commit/c96c7755a349631282c29acd4b524e76f2afb0c4))
 * `hammer content-view remove` has unnecessary option `--content-view-version-content-view-ids` ([#18352](http://projects.theforeman.org/issues/18352), [aa6e9c31](http://github.com/katello/hammer-cli-katello/commit/aa6e9c31c71ab25099b5a0e39b1e86bfaf05a00f))
 * do not show file repositories tab on content view versions without any file repos ([#18164](http://projects.theforeman.org/issues/18164), [dd38bcad](http://github.com/katello/katello/commit/dd38bcad466cf6bae596669ccc5f1e59bf7c5c4d))
 * cancel button for new docker content view filter returns to the yum filters page ([#18163](http://projects.theforeman.org/issues/18163), [9c8dc3e5](http://github.com/katello/katello/commit/9c8dc3e54f50d02f6cb2e9b1af5c8dae53bd5ba4))
 * Trying to delete a Puppet content view version throws the error " TypeError: Value (NilClass) '' is not any of: ForemanTasks::Concerns::ActionSubject" ([#17929](http://projects.theforeman.org/issues/17929), [b2c0e756](http://github.com/katello/katello/commit/b2c0e75679c20e70376fe539c5a85070516ff9f7))
 * unable to add a puppet module from GUI ([#17930](http://projects.theforeman.org/issues/17930), [3a35c40c](http://github.com/katello/katello/commit/3a35c40c59d48a734a08125d4faa091698614f3e))
 * Content view publish styling is off  ([#19138](http://projects.theforeman.org/issues/19138), [73bace93](http://github.com/katello/katello/commit/73bace93a23b9fc7bdc3e822b069d5565781e3f7))
 * Composite Content View shows incorrect total number of included repos ([#18983](http://projects.theforeman.org/issues/18983), [3166c7cf](http://github.com/katello/katello/commit/3166c7cf0c7ce51fd637a3980800720fe913c926))
 * new container from content view ui page not working ([#18223](http://projects.theforeman.org/issues/18223), [0097078d](http://github.com/katello/katello/commit/0097078d8bd563afb1ecc532e78436e05404db2c))
 * Hammer- can't remove puppet module from content view by id -- uuid is sent instead ([#18923](http://projects.theforeman.org/issues/18923), [954a560a](http://github.com/katello/hammer-cli-katello/commit/954a560a23dece6e040352bff041b81b14b79bed))
 * Succesfully promoted <content_view_version> to undefined ([#18421](http://projects.theforeman.org/issues/18421), [4600cff5](http://github.com/katello/katello/commit/4600cff5b39bf7a8cecdefbd4dcb60a928d33f96))

### Provisioning
 * Fix Smart Proxies test to use factory girl ([#18907](http://projects.theforeman.org/issues/18907), [aa4af5a6](http://github.com/katello/katello/commit/aa4af5a652a62510c1c7e3702f4eb61c0b7ea0b5))
 * Katello kickstart template hardcodes root password hash algorithm ([#18508](http://projects.theforeman.org/issues/18508), [2f159188](http://github.com/katello/katello/commit/2f159188bff0ee8292097cf0d2c2ee7ee2491e5d))

### Tooling
 * auto load rake tasks ([#18894](http://projects.theforeman.org/issues/18894), [4c37ec3b](http://github.com/katello/katello/commit/4c37ec3bd2888ccc6aa54ae89aa1f9f390ccc293), [df4f680d](http://github.com/katello/katello/commit/df4f680df35d24ff72c6765c5f09300a8506547c))
 * FileUnitPresenter has the wrong filename ([#17865](http://projects.theforeman.org/issues/17865), [4dc96eaa](http://github.com/katello/katello/commit/4dc96eaa595df75c4448be57dce478baed299476))
 * Remove katello-disconnected (or katello-utils) ([#15758](http://projects.theforeman.org/issues/15758))
 * clean_backend_objects doesn't handle nil subscription_facet uuids properly ([#18972](http://projects.theforeman.org/issues/18972), [49fbe735](http://github.com/katello/katello/commit/49fbe73556babe762ff4de77aa6f1901e903cb5c))

### Upgrades
 * upgrade fail with error : Upgrade Step: set_virt_who_on_pools (this may take a while) ... ([#18879](http://projects.theforeman.org/issues/18879), [e8ea1407](http://github.com/katello/katello/commit/e8ea1407b17194b8244352710ba85a81c07b1693))
 * Provide more information about currently running upgrade steps ([#17192](http://projects.theforeman.org/issues/17192), [25acd4a1](http://github.com/katello/katello-installer/commit/25acd4a14dd8b91f5eb27440187aaf90be6d7c27))

### Hammer
 * Correct the directory name for hammer activation keys tests  ([#18847](http://projects.theforeman.org/issues/18847), [fae4074a](http://github.com/katello/hammer-cli-katello/commit/fae4074a71a9141488649cc06a6deee674b48470))
 * hammer activation key content overrides needs to use updated api ([#18846](http://projects.theforeman.org/issues/18846), [9f0a7b02](http://github.com/katello/hammer-cli-katello/commit/9f0a7b0234574e5534a0abb6747e0e88214785f4))
 * `hammer package list --product-id 1` returns all packages for all products ([#18702](http://projects.theforeman.org/issues/18702), [a7d0f269](http://github.com/katello/hammer-cli-katello/commit/a7d0f2698c0157943533036dc9325208871e6497))
 * Cannot create a hostgroup with a content view ([#17709](http://projects.theforeman.org/issues/17709), [75844ddb](http://github.com/katello/hammer-cli-katello/commit/75844ddba36bbbeaccf5182579593a39680f26dd))
 * Hammer repository remove-content should allow reposotiry ID resolution by name, organization, and product ([#15555](http://projects.theforeman.org/issues/15555), [417fc2d9](http://github.com/katello/hammer-cli-katello/commit/417fc2d97befc521c0ada6cf772576960a5d8bf7))
 * Package list in CLI lacks information ([#15189](http://projects.theforeman.org/issues/15189), [0b91a0a3](http://github.com/katello/hammer-cli-katello/commit/0b91a0a32b3adbb25cb410ddb9661d4f51b0bfc4))
 * Adapt hammer-cli-katello to use the new options changes in hammer-cli ([#19079](http://projects.theforeman.org/issues/19079), [c073fe95](http://github.com/katello/hammer-cli-katello/commit/c073fe95498e5bb443970ff2aec3fbfcaf3a2e3b))

### Repositories
 * Support verify content sync on bulk products ([#18844](http://projects.theforeman.org/issues/18844), [9b7942bd](http://github.com/katello/katello/commit/9b7942bdb751026f986b25506a16eee806c02cdc))
 * Do not index full rpm metadata if already present ([#18655](http://projects.theforeman.org/issues/18655), [937ca0da](http://github.com/katello/katello/commit/937ca0da561347f94a22aae87aa52ab345eb1238))
 * docker repos not synced to capsule ([#18593](http://projects.theforeman.org/issues/18593), [ebd33521](http://github.com/katello/katello/commit/ebd33521c826d05d5b0f68da85184415d355933c))
 * Docker upstream repository name length limit ([#18533](http://projects.theforeman.org/issues/18533), [67fa4623](http://github.com/katello/katello/commit/67fa46237aa0f7d88c257e343ab6008af3ed4c93))
 * 255 character length too short for content view names ([#17949](http://projects.theforeman.org/issues/17949), [7e3bb1b6](http://github.com/katello/katello/commit/7e3bb1b659e67b564dbc2e9d3e3b096fd1deba3e))
 * allow for force generation of repo metadata ([#17941](http://projects.theforeman.org/issues/17941), [64b2f747](http://github.com/katello/katello/commit/64b2f747f6208bb768acec4dcb532193276ca17b))
 * "hammer repository upload-content --path" redundantly non-performant against big repos ([#17691](http://projects.theforeman.org/issues/17691), [9e1a95b7](http://github.com/katello/katello/commit/9e1a95b7fdeeca9d67fe960e82c0451e2355d431), [ab8925e7](http://github.com/katello/hammer-cli-katello/commit/ab8925e79445d759be128ff2ae8caf5083395361))
 * Unpacking tree in Red Hat Repositories sequentially contacts CDN for each and every CDN path ([#17564](http://projects.theforeman.org/issues/17564), [1897a6bb](http://github.com/katello/katello/commit/1897a6bbfe52be9a357c5a67b55bf2b17814955f))
 * JS error on repository page ([#19178](http://projects.theforeman.org/issues/19178), [cc3be615](http://github.com/katello/katello/commit/cc3be615f07e0054a0111784f347f5c338d81767))
 * need mechanism to clear repository upstream username and password ([#16824](http://projects.theforeman.org/issues/16824), [fa1546bb](http://github.com/katello/katello/commit/fa1546bb59f4a7bfac4b5265d13be228c334ca26))

### Activation Key
 * PG::Error: ERROR:  missing FROM-clause entry for table "katello_environments" when viewing activation keys as a user with customized viewing permissions ([#18738](http://projects.theforeman.org/issues/18738), [211df8bc](http://github.com/katello/katello/commit/211df8bc4758f1f828a6115bfc92a9edee0191ce))

### Documentation
 * Documentation: Troubleshooting page links to nothing ([#18685](http://projects.theforeman.org/issues/18685))

### OSTree
 * Ostree View Branches link missing ([#18579](http://projects.theforeman.org/issues/18579), [f596afaa](http://github.com/katello/katello/commit/f596afaa38ecddd257abdd36bf5e42a45d0473f9))
 * Updating an ostree repo causes ISE ([#19182](http://projects.theforeman.org/issues/19182), [1c676303](http://github.com/katello/katello/commit/1c676303ca3a4c27ec973a6a5ca0f41b398ca25f))

### Host Collections
 * Trying to apply errata on host-collection using hammer fails ([#18536](http://projects.theforeman.org/issues/18536), [f1497c05](http://github.com/katello/hammer-cli-katello/commit/f1497c05fb8953af783779b0284c9afc9fde19f5))

### API
 * Hammer does not list over 20 item per page for some resources ([#18470](http://projects.theforeman.org/issues/18470), [d3e60743](http://github.com/katello/katello/commit/d3e607438e7b3c0bcec90e381a3063b244d5822d))

### Errata Management
 * [RFE] - Applying Erratum to a client, Cancel and Next button only visible while scrolling through the entire list of content-hosts ([#18459](http://projects.theforeman.org/issues/18459), [3527c140](http://github.com/katello/katello/commit/3527c1408b75a0d17e4a3e6b34f95edb5b0497fd))
 * cannot go to task details from errata task list  ([#18393](http://projects.theforeman.org/issues/18393), [2769723a](http://github.com/katello/katello/commit/2769723aece9cabb1aae2b28c4cff9208c623353))
 * Allow batched content install actions during errata install ([#18258](http://projects.theforeman.org/issues/18258), [34eee5e6](http://github.com/katello/katello/commit/34eee5e67e856d92ca71b423b3a9dae2de497ad5))
 * Inconsistent naming of errata applicable vs affected ([#17911](http://projects.theforeman.org/issues/17911), [b7e0d437](http://github.com/katello/katello/commit/b7e0d437659bbad4371cd18b1c1376b1deaa9ad8))

### Organizations and Locations
 * Organization delete fails when products exist ([#18453](http://projects.theforeman.org/issues/18453), [e919963a](http://github.com/katello/katello/commit/e919963a944ce0a3738d4dd14a98c1c50861e57f))
 * Org create returns unclear message when trying to assign a non-existent subnet ([#18063](http://projects.theforeman.org/issues/18063), [6b372871](http://github.com/katello/katello/commit/6b3728719a54531e013384ab5d457f0ed12dc7d7))

### Atomic
 * need ostree repo sync show better progress information. ([#18361](http://projects.theforeman.org/issues/18361), [2b5cd85d](http://github.com/katello/katello/commit/2b5cd85d045cfacf5a2785a48b527e0042adc264))

### Settings
 * Use regular names for settings ([#18236](http://projects.theforeman.org/issues/18236), [67963da1](http://github.com/katello/katello/commit/67963da194bc4d4f9ab28d9adcdf06ddbbc1f90d))

### Backup & Restore
 * The Script katello-backup reports Permission denied messages ([#18137](http://projects.theforeman.org/issues/18137))

### Lifecycle Environments
 * Lifecycle environments not displayed correctly with restricted permissions ([#18034](http://projects.theforeman.org/issues/18034), [eb14a2f8](http://github.com/katello/katello/commit/eb14a2f886c270792ac2049d1fdfb9dafdbe9b97))

### Docker
 * update content view docker to include filters ([#17726](http://projects.theforeman.org/issues/17726), [31ceb776](http://github.com/katello/katello/commit/31ceb776fc06327e48924d94582267d5f4360e72))

### Sync Plans
 * Non-enabled products can be added to a sync plan by ID via the API ([#16052](http://projects.theforeman.org/issues/16052), [3252332f](http://github.com/katello/katello/commit/3252332f6bc5f157a127fd393a2048cefc4e497d))

### Database
 * db:migrate breaks RPM build ([#19189](http://projects.theforeman.org/issues/19189), [493c5c9f](http://github.com/katello/katello/commit/493c5c9fe50ff06e1d77ddab056ed941f0f69ef9), [35de7e89](http://github.com/katello/katello/commit/35de7e892031410d4894e7e2378f9ebe0a38349e))

### Other
 * use single-consumer call when regenerating applicability ([#19076](http://projects.theforeman.org/issues/19076), [59c58a8e](http://github.com/katello/katello/commit/59c58a8ebd9dbd0a5a8bc6fdb3c0a4b5318608c3))
 * Unknown class TransportFailure ([#19027](http://projects.theforeman.org/issues/19027), [0b77b8f0](http://github.com/katello/katello/commit/0b77b8f093637c4854566731e67798ac270dda7b))
 * Add links and make subscription add/remove tables more readable ([#18990](http://projects.theforeman.org/issues/18990), [6f1ae764](http://github.com/katello/katello/commit/6f1ae764d093a46b8013aa4cbaace65f76a651b5))
 * undefined method when no Pulp capsule present ([#18959](http://projects.theforeman.org/issues/18959), [12684b70](http://github.com/katello/katello/commit/12684b70a3f9f80ed108e56498ec8211753a2a15))
 * Hammer shows no errata "installable" even if it is actually installable" ([#18785](http://projects.theforeman.org/issues/18785), [fbca8db4](http://github.com/katello/hammer-cli-katello/commit/fbca8db42d5ab5d4241957c8363d5c2b970e500f))
 *  Sync Errata should send emails only if Errata count is greater than 0 ([#18784](http://projects.theforeman.org/issues/18784), [34cb28fb](http://github.com/katello/katello/commit/34cb28fb4db811ef61f38173c6a60a239ffb7796))
 * upgrade to vcr 3.0 ([#18670](http://projects.theforeman.org/issues/18670), [15d0a9df](http://github.com/katello/katello/commit/15d0a9df0a926b26c6b1339096b54edb80b6e358))
 * Add better documentation on how to add tests to hammer-cli-katello ([#18589](http://projects.theforeman.org/issues/18589), [3b2e0f40](http://github.com/katello/hammer-cli-katello/commit/3b2e0f406f62e9f38bfe335afc32ad3693de7f27))
 * Add action scopes to hosts API controller. ([#18586](http://projects.theforeman.org/issues/18586), [4f5aa92e](http://github.com/katello/katello/commit/4f5aa92ee932496315437d15474e42322539490e))
 * katello debug should not use known directory structures ([#18571](http://projects.theforeman.org/issues/18571), [b1ddc8a2](http://github.com/katello/katello-packaging/commit/b1ddc8a2d80e9074cb8f969172be1a93b660a411))
 * hammer cli : hostgroup info is not showing content-related fields ([#18523](http://projects.theforeman.org/issues/18523), [7ebdebd6](http://github.com/katello/hammer-cli-katello/commit/7ebdebd67126b8a2fbd808d0a0032c589e78e5a9))
 * hammer throws error "Uuid can't be blank" while adding groups to a content view filter of content type "Package Group" ([#18499](http://projects.theforeman.org/issues/18499), [0abf4af2](http://github.com/katello/katello/commit/0abf4af28741a18784f3c3c81cb325e6b3953523), [e605f0cb](http://github.com/katello/hammer-cli-katello/commit/e605f0cb95f09b692a8b6a510d6d021b18ea05bd))
 * Uninitialized contant Host::ContentFacet on hostgroup edit ([#18475](http://projects.theforeman.org/issues/18475), [89a978f1](http://github.com/katello/katello/commit/89a978f1f0f864e2e7dff79101f5e9a8b565145d))
 * datetime format should be db independent for support mysql ([#18441](http://projects.theforeman.org/issues/18441), [c2a8e058](http://github.com/katello/katello/commit/c2a8e058e875cb13398286396035eb457e661262))
 * tag in pulp-2.12 ([#18411](http://projects.theforeman.org/issues/18411))
 * katello-backup returns with wrong exit code when failing ([#18333](http://projects.theforeman.org/issues/18333), [af3a5bc0](http://github.com/katello/katello-packaging/commit/af3a5bc035a23fec778aeaf3e9bfc22116325dff), [a5593c5f](http://github.com/katello/katello-packaging/commit/a5593c5ff8cf4a3303d4869240e99eb23db35574))
 * Missing bulk content host auto-attach button ([#18320](http://projects.theforeman.org/issues/18320), [3256117f](http://github.com/katello/katello/commit/3256117f51f558aa9fd531259cad01200e2576cf))
 * The Docker Tags page spins forever under Any Context ([#18283](http://projects.theforeman.org/issues/18283), [5ef91fbb](http://github.com/katello/katello/commit/5ef91fbb91f394a9d9b93276644881f55ed272a4))
 * after hostname change - publishing a content view with puppet modules in it throws ssl error ([#18270](http://projects.theforeman.org/issues/18270), [81c2e29a](http://github.com/katello/katello-packaging/commit/81c2e29a891b813c82bd1632b53337812847333c))
 * https://katello.example.com/pub shows entries for the old hostname ([#18267](http://projects.theforeman.org/issues/18267))
 * Update Katello-backup to omit the /var/lib/pulp/katello-export directory ([#18242](http://projects.theforeman.org/issues/18242), [c6444fe0](http://github.com/katello/katello-packaging/commit/c6444fe026689f8e1f760558c19f8d504acbff71))
 * Unable to delete Default Location from katello ([#18226](http://projects.theforeman.org/issues/18226), [c3a0892d](http://github.com/katello/katello/commit/c3a0892d1dfe3848d1c27ec1a038bdcc2d2cfd53))
 * Fix usages of sub-header angular block in katello ([#18220](http://projects.theforeman.org/issues/18220), [75e420c9](http://github.com/katello/katello/commit/75e420c934e30c4e76348a7894a07b3c00fe0595))
 * [RFE] Add RHSM.log to katello-debug ([#18145](http://projects.theforeman.org/issues/18145), [c417fcee](http://github.com/katello/katello-packaging/commit/c417fceeb7fce878497deb54df3ab541fb6e9082))
 * Katello fields do not show up on host view ([#18141](http://projects.theforeman.org/issues/18141), [3fbc39b7](http://github.com/katello/katello/commit/3fbc39b7cd9327fe3c2d76c4b253b2f6488e5461), [3d223206](http://github.com/katello/katello/commit/3d223206dd73eef46b342869ee2f2d7cf6fa2298))
 * Puppet repository update fails with no method puppet_path for nil when missing a default smart proxy ([#18138](http://projects.theforeman.org/issues/18138), [9c31f5e2](http://github.com/katello/katello/commit/9c31f5e2f77979a74e8468b2e381f3585d709576))
 * Search raises PGError on feeding a non-integer value for a integer field ([#18084](http://projects.theforeman.org/issues/18084), [ac66f56b](http://github.com/katello/katello/commit/ac66f56be254e881ce575818aa1a744b0308858b))
 * Regression: Syncing large Library of content from Katello to Proxy takes hours even if no content changes ([#18032](http://projects.theforeman.org/issues/18032), [8b4e78db](http://github.com/katello/katello/commit/8b4e78db1f5fa8fd88605ee06cf98333f9e89a9c))
 * Custom product content published in Library isn't syncing to capsule ([#18028](http://projects.theforeman.org/issues/18028), [1c9ad27d](http://github.com/katello/katello/commit/1c9ad27d5a15ff21fe910a1689582ec1fb91312a), [9c239083](http://github.com/katello/hammer-cli-katello/commit/9c239083f62ac30d2a54d94ab71c920f6e170cd3))
 * Fix tests that depend on CVE 2016-7078 ([#17266](http://projects.theforeman.org/issues/17266), [236abac4](http://github.com/katello/katello/commit/236abac4f8df9ed7f74a2710646e1ffa01669d26))
 * Update foreman-tasks to 0.9.0 ([#19162](http://projects.theforeman.org/issues/19162), [74dbf758](http://github.com/katello/katello/commit/74dbf7581041b31de015daf99b3ad0abf668f452))
