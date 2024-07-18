# 4.13.1 Sosta (2024-07-18)

## Features

### Hosts
 * Katello should be able to handle subscription-manager environments --set ([#37618](https://projects.theforeman.org/issues/37618), [799e0996](https://github.com/Katello/katello.git/commit/799e09960512f9787d1251ab40089f50324097e6))

## Bug Fixes

### Repositories
 * Migrate sha1 repos only at the next edit time ([#37609](https://projects.theforeman.org/issues/37609), [2072d3fd](https://github.com/Katello/katello.git/commit/2072d3fd73260858983a37b98ddf43dcd46fcf44))
 * Get rid of unmaintained anemone ([#37159](https://projects.theforeman.org/issues/37159), [e55b8d1d](https://github.com/Katello/katello.git/commit/e55b8d1ddc2aee494d099af56eda81ed7ec33e24))
# 4.13.0 Sosta (2024-06-26)

## Features

### Hammer
 *  Add CLI support for repository verify checksum ([#37415](https://projects.theforeman.org/issues/37415), [7e51f146](https://github.com/Katello/hammer-cli-katello.git/commit/7e51f1469d00a7e1d5a1924d40790347891d627f))
 * Allow granular repair functionality for capsules ([#37311](https://projects.theforeman.org/issues/37311), [a3541b88](https://github.com/Katello/hammer-cli-katello.git/commit/a3541b8830e41ae904a7cd41530e85b668775333))

### Hosts
 * Add Setting to disable validation of host/lifecycle environment/content source coherence ([#37400](https://projects.theforeman.org/issues/37400), [5f9296b8](https://github.com/Katello/katello.git/commit/5f9296b8fb615f5e447bb2613a6640625b6d6e68), [a1c864ac](https://github.com/Katello/katello.git/commit/a1c864acdde85deaff5b22e131086cff5e3ffb4a))
 * Add bulk CV/LCE assignment to new All Hosts page ([#37336](https://projects.theforeman.org/issues/37336), [b12280a7](https://github.com/Katello/katello.git/commit/b12280a74b81f47d4b59118b0f1fc0f7bb1a0d03))
 * Add Katello column(s) to new host index page ([#37309](https://projects.theforeman.org/issues/37309), [f3891b2b](https://github.com/Katello/katello.git/commit/f3891b2b8dacb2f5f10e19b5df22df330019aff2))
 * Offer a hint in the UI about how to get 'Synced Content' available ([#36992](https://projects.theforeman.org/issues/36992), [cb8c4231](https://github.com/Katello/katello.git/commit/cb8c4231bc1db3f1e5630dd8d6e2f13ce41e953b), [4f94f1b6](https://github.com/Katello/katello.git/commit/4f94f1b64f26790b296ff976f12ce2876afa5b93))

### Container
 * Allow pushing container images to Pulp without indexing ([#37302](https://projects.theforeman.org/issues/37302), [ac916514](https://github.com/Katello/katello.git/commit/ac916514d159acbb0466d826b39c7d9567f2cb17))

### Subscriptions
 * As a user I want to be warned before the manifest (upstream consumer identity certificate) will expire, and have a notification to refresh the manifest. ([#37271](https://projects.theforeman.org/issues/37271), [857df9e0](https://github.com/Katello/katello.git/commit/857df9e01ce9e8c594909c3b662e3cf62f2f904a), [4e585726](https://github.com/Katello/katello.git/commit/4e585726c3911dd183de4bf718c9bbeb27296f46))
 * As a user, when I refresh my manifest the expiration date of the identity certificate will get renewed, so that I am never caught with an expired manifest. ([#37266](https://projects.theforeman.org/issues/37266), [b342a208](https://github.com/Katello/katello.git/commit/b342a2085a07918de75ac626c24b94c6b86493b7))
 * Remove SCA-related API endpoints and params ([#37226](https://projects.theforeman.org/issues/37226), [7fe287f2](https://github.com/Katello/katello.git/commit/7fe287f2c78a336154df60bcc036266a255b4e27))

### Foreman Proxy Content
 * Allow granular repair functionality for capsules ([#37258](https://projects.theforeman.org/issues/37258), [03494eca](https://github.com/Katello/katello.git/commit/03494eca34658142013420e8d12417e33937aab4))
 * SmartProxy Content Sync should offer Verify Content Checksum ([#36803](https://projects.theforeman.org/issues/36803), [03494eca](https://github.com/Katello/katello.git/commit/03494eca34658142013420e8d12417e33937aab4))

### Content Views
 * Allow repairing content view versions ([#37237](https://projects.theforeman.org/issues/37237), [a3651e4b](https://github.com/Katello/katello.git/commit/a3651e4b977ad01ae249d58635ec8dfe4474aff5))
 * [RFE] Block content view publishing during repository publication tasks ([#37139](https://projects.theforeman.org/issues/37139), [ebfd49b4](https://github.com/Katello/katello.git/commit/ebfd49b414162ebebcdf68fa09c8542ce315752f))

### Reporting
 * SCA-Only: Remove Subscription-Entitlement notification ([#37170](https://projects.theforeman.org/issues/37170), [24b9c5c8](https://github.com/Katello/katello.git/commit/24b9c5c834fbc5ff30ad7d86d9f854a3dc6da1ca))

### katello-tracer
 * Use dnf needs-restarting to collect tracer information ([#36973](https://projects.theforeman.org/issues/36973), [f494bb9c](https://github.com/Katello/katello-host-tools.git/commit/f494bb9cc088216e018de45e17ea3fa41728dee3), [1408cbd8](https://github.com/Katello/katello-host-tools.git/commit/1408cbd8ca29d1a921a69e7f0f21597fe097e3c9))

### Other
 * It should be possible to upload a package / repos profile from UI ([#37191](https://projects.theforeman.org/issues/37191), [559f43c6](https://github.com/Katello/katello.git/commit/559f43c6ad81168ae396b61509d828129ceae6ec))

## Bug Fixes

### Subscriptions
 * 'Bind entitlements to an allocation' task fails with wrong number of arguments (given 1, expected 0) (ArgumentError) ([#37571](https://projects.theforeman.org/issues/37571), [9fa4a7df](https://github.com/Katello/katello.git/commit/9fa4a7df48666b9ed895dd4fa0990e6b5f3d2b12))
 * Org still holds stale cached manifest expiration date after manifest import/refresh ([#37481](https://projects.theforeman.org/issues/37481), [29330949](https://github.com/Katello/katello.git/commit/293309497b6ad3b6964fca5837516eb2d5fe784f), [12997f34](https://github.com/Katello/katello.git/commit/12997f34aa21e05a1112335295a47b78cd869550))
 * subscription-manager release --unset doesn't reset the client information on foreman ([#37358](https://projects.theforeman.org/issues/37358), [d47e2e09](https://github.com/Katello/katello.git/commit/d47e2e099a35a62d75c1de94b4192ed2d6c98779))
 * Subscription Details Page has a broken page header ([#36924](https://projects.theforeman.org/issues/36924), [db9e0c28](https://github.com/Katello/katello.git/commit/db9e0c28e4c299a879c4efca47af9bdda75a3d48), [420e9a9a](https://github.com/Katello/katello.git/commit/420e9a9a30c569d287ae8368569bb730f5923e6b))

### Content Views
 * CV promote fails with undefined method `get_status' for nil:NilClass when deleting a Host in the CV during Finalize phase of the Promote task ([#37543](https://projects.theforeman.org/issues/37543), [2d8fe20d](https://github.com/Katello/katello.git/commit/2d8fe20d4f4a8dfea67223bb9fe36f51b9bb2b50))
 * Content view publish failing with katello_repository_rpms_id_seq reached maximum value error ([#37403](https://projects.theforeman.org/issues/37403), [b405249f](https://github.com/Katello/katello.git/commit/b405249f329da215e31088fd5433ae8e01727b5a))
 * Newly imported content views show as needs publish ([#37254](https://projects.theforeman.org/issues/37254), [ec68d4ca](https://github.com/Katello/katello.git/commit/ec68d4ca614a5c7edd2a04d7767aa807c78dfe47))
 * Python content not getting published to versions ([#36611](https://projects.theforeman.org/issues/36611), [f5b4e571](https://github.com/Katello/katello.git/commit/f5b4e5710a20f828b06065604db0b73f0dcdbe6c))

### Web UI
 * load js correctly in smart_proxies ([#37539](https://projects.theforeman.org/issues/37539), [5c17dce4](https://github.com/Katello/katello.git/commit/5c17dce4c6710e8d105794880e1a8baa4f5a726b))

### Repositories
 * Yum Metadata Checksum of SHA1 no longer supported by Pulp ([#37522](https://projects.theforeman.org/issues/37522), [c98e3271](https://github.com/Katello/katello.git/commit/c98e3271dcb5abedec9fcfe03b52481a2e4a9a95))
 * Pulp never purge the completed tasks ([#37521](https://projects.theforeman.org/issues/37521), [c5bdfb75](https://github.com/Katello/katello.git/commit/c5bdfb7590168ead732b587f36ae056f78a5f324))
 * Registry doesn't 404 for v2 clients trying to search ([#37504](https://projects.theforeman.org/issues/37504), [276adf28](https://github.com/Katello/katello.git/commit/276adf28b6450dcb6bc18bcea03e6b053b099786))
 * Upgrade pulp-container bindings to 2.20 ([#37414](https://projects.theforeman.org/issues/37414), [651453ef](https://github.com/Katello/katello.git/commit/651453efe8cf5e4cf09cc639ac93db8f33989608))
 * Fix typo for container_repository_name in metadata_generate_needed? ([#37408](https://projects.theforeman.org/issues/37408), [1dbd1b9b](https://github.com/Katello/katello.git/commit/1dbd1b9bf32655ab957d7c6a78860b749bdbca05))
 * Create a rake script that reindexes manifests with label information ([#37407](https://projects.theforeman.org/issues/37407), [62ad4c59](https://github.com/Katello/katello.git/commit/62ad4c5957688d4f6a698159e3809c217901c2c9))
 * Container push can fail with a different JSON error ([#37380](https://projects.theforeman.org/issues/37380), [95a55e0d](https://github.com/Katello/katello.git/commit/95a55e0da6b5355170a23bed51d6f5065c05cb7f))
 * Index Pulp manifest annotations, labels, is_bootable, is_flatpak and expose them via API ([#37379](https://projects.theforeman.org/issues/37379), [73dcade7](https://github.com/Katello/katello.git/commit/73dcade75cc8de39b87b95426fef7d17a33b46e7))
 * Fix Katello (or maybe BATS) -- orphan cleanup tries deleting distributed repo versions ([#37371](https://projects.theforeman.org/issues/37371), [1a5d9304](https://github.com/Katello/katello.git/commit/1a5d9304110cd93603dace51eb1385b693ceb86d))
 * Registry Service Accounts token is not accepted in "Upstream Authentication Token"  of a docker repo ([#37238](https://projects.theforeman.org/issues/37238), [39d52bd1](https://github.com/Katello/katello.git/commit/39d52bd1a048531be0e4b91bb8423f1fca0dca04))
 * Red Hat products that were never synced are reporting last synced time ([#31318](https://projects.theforeman.org/issues/31318), [19d4dd7a](https://github.com/Katello/katello.git/commit/19d4dd7ac501f29e1b61c89029b5850cf3cea1a6))

### Content Credentials
 * asterisk symbol is missing for required field ([#37482](https://projects.theforeman.org/issues/37482), [d704d905](https://github.com/Katello/katello.git/commit/d704d9055b15f66d0e7938e582b00962fe24012c))

### Container
 * Create Katello push repositories as needed at container push time ([#37455](https://projects.theforeman.org/issues/37455), [1e82cd48](https://github.com/Katello/katello.git/commit/1e82cd48a76e58eaf26026b29770353a52de0c2e))
 * `podman login` against the container registry returns 500 intermittently ([#37218](https://projects.theforeman.org/issues/37218), [f96702c4](https://github.com/Katello/smart_proxy_container_gateway.git/commit/f96702c4a4a49c170a9773f343ccdfb40aa6693c))

### Foreman Proxy Content
 * Container gateway needs to send ACCEPT headers from podman to Pulp ([#37399](https://projects.theforeman.org/issues/37399), [ac7b5786](https://github.com/Katello/smart_proxy_container_gateway.git/commit/ac7b578652771bf9cbbee5815734dfccfae4a4de), [9440b1d5](https://github.com/Katello/smart_proxy_container_gateway.git/commit/9440b1d5ba75b483d85885dfd8507d0ae16db38b))
 * Container Gateway: concurrent logins trigger bad token error ([#37369](https://projects.theforeman.org/issues/37369), [39dfd4c0](https://github.com/Katello/smart_proxy_container_gateway.git/commit/39dfd4c059c7d2421387ca6aa86c06afba89fff3))
 * Slow smart proxy sync in 4.11 ([#37356](https://projects.theforeman.org/issues/37356), [98dfce09](https://github.com/Katello/katello.git/commit/98dfce09140e9d3d0d3923cdb1ef4366572a9110))

### Inter Server Sync
 * content export actions are failing in ruby 3 ([#37381](https://projects.theforeman.org/issues/37381), [1d15a187](https://github.com/Katello/katello.git/commit/1d15a1872b6c6ca89b9f25406b20a0e0a114bd90))

### Hosts
 * Trace_status = reboot_needed not working after upgrade to 4.12 ([#37354](https://projects.theforeman.org/issues/37354), [c381b09f](https://github.com/Katello/katello.git/commit/c381b09f6a501ab0b5d5521f5a7213c0d68d8be4))
 *  katello:clean_backend_objects false alarms on systems with >1500 clients when PUTing customer facts ([#37283](https://projects.theforeman.org/issues/37283), [b72874d1](https://github.com/Katello/katello.git/commit/b72874d1e734dc6ce29b5b5ec12ccc3f478db627))
 * Update Checkin time for ESXi hypervisors from virt-who report ([#37162](https://projects.theforeman.org/issues/37162), [72394b6c](https://github.com/Katello/katello.git/commit/72394b6cf9daa0fb56f51b359aedb18ad668956b))
 * Host content view environment is reset on any host edit when hostgroup assigns a CVE ([#36897](https://projects.theforeman.org/issues/36897), [a896b2f5](https://github.com/Katello/katello.git/commit/a896b2f595e84f7385298f12d6f822bce39d195a))

### API
 * API endpoint for activation_keys/:id/product_content should be TRUE by default ([#37350](https://projects.theforeman.org/issues/37350), [0540e33d](https://github.com/Katello/katello.git/commit/0540e33d0d992c4becc46ecd4d5efe506c3c7477))

### Upgrades
 * Upgrade pulpcore to 3.49 ([#37301](https://projects.theforeman.org/issues/37301), [ec0f7a2c](https://github.com/Katello/katello.git/commit/ec0f7a2cd5f6020c43d3f50b30e604adf98f8d9c))

### Hammer
 * Add verify-checksum command for CV versions in hammer ([#37235](https://projects.theforeman.org/issues/37235), [a6bbddd0](https://github.com/Katello/hammer-cli-katello.git/commit/a6bbddd0deae108a1df028f368feeb4e985421df))
 * Update hammer to remove SCA command and remove references of it from organization create/update/list/info ([#37230](https://projects.theforeman.org/issues/37230), [269635c5](https://github.com/Katello/hammer-cli-katello.git/commit/269635c5a15601a4b475f459bfed7ccc979c387c))
 * Improve displayed filter rules info in hammer ([#37181](https://projects.theforeman.org/issues/37181), [4ac06b46](https://github.com/Katello/katello.git/commit/4ac06b46fb75dbea9fb7e8a801546f6450543e39))

### Tooling
 * Missing development dependencies for rubocop ([#36998](https://projects.theforeman.org/issues/36998), [2e084c90](https://github.com/Katello/katello.git/commit/2e084c9018b574453084827c9ff548d6379c4110), [7f99691e](https://github.com/Katello/katello.git/commit/7f99691e986189a27f285cd02644effb06c932e9), [98c9fee8](https://github.com/Katello/katello.git/commit/98c9fee806a7ee36d1b0c7f3506e63290dea57fc))

### Other
 * Package rubygem-dynflow not listed in a list of packages ([#37457](https://projects.theforeman.org/issues/37457), [48746afd](https://github.com/Katello/katello.git/commit/48746afde64550eeb5570676c089502eabe103ed))
 * Fix upstream lint issues ([#37331](https://projects.theforeman.org/issues/37331), [58d2cdb1](https://github.com/Katello/katello.git/commit/58d2cdb13b2c6d04684f717611d79322cbc53d51))
 * It is possible to end up with the wrong remote type (uln vs. normal) for yum content ([#37279](https://projects.theforeman.org/issues/37279), [97f8a09c](https://github.com/Katello/katello.git/commit/97f8a09c3338b702c1d2735318e8c5e3b1b6b953))
# 4.13.0.rc1 Sosta (2024-05-29)

## Features

### Hammer
 *  Add CLI support for repository verify checksum ([#37415](https://projects.theforeman.org/issues/37415), [7e51f146](https://github.com/Katello/hammer-cli-katello.git/commit/7e51f1469d00a7e1d5a1924d40790347891d627f))
 * Allow granular repair functionality for capsules ([#37311](https://projects.theforeman.org/issues/37311), [a3541b88](https://github.com/Katello/hammer-cli-katello.git/commit/a3541b8830e41ae904a7cd41530e85b668775333))

### Hosts
 * Add Setting to disable validation of host/lifecycle environment/content source coherence ([#37400](https://projects.theforeman.org/issues/37400), [5f9296b8](https://github.com/Katello/katello.git/commit/5f9296b8fb615f5e447bb2613a6640625b6d6e68), [a1c864ac](https://github.com/Katello/katello.git/commit/a1c864acdde85deaff5b22e131086cff5e3ffb4a))
 * Add bulk CV/LCE assignment to new All Hosts page ([#37336](https://projects.theforeman.org/issues/37336), [b12280a7](https://github.com/Katello/katello.git/commit/b12280a74b81f47d4b59118b0f1fc0f7bb1a0d03))
 * Add Katello column(s) to new host index page ([#37309](https://projects.theforeman.org/issues/37309), [f3891b2b](https://github.com/Katello/katello.git/commit/f3891b2b8dacb2f5f10e19b5df22df330019aff2))
 * Offer a hint in the UI about how to get 'Synced Content' available ([#36992](https://projects.theforeman.org/issues/36992), [cb8c4231](https://github.com/Katello/katello.git/commit/cb8c4231bc1db3f1e5630dd8d6e2f13ce41e953b), [4f94f1b6](https://github.com/Katello/katello.git/commit/4f94f1b64f26790b296ff976f12ce2876afa5b93))

### Container
 * Allow pushing container images to Pulp without indexing ([#37302](https://projects.theforeman.org/issues/37302), [ac916514](https://github.com/Katello/katello.git/commit/ac916514d159acbb0466d826b39c7d9567f2cb17))

### Subscriptions
 * As a user I want to be warned before the manifest (upstream consumer identity certificate) will expire, and have a notification to refresh the manifest. ([#37271](https://projects.theforeman.org/issues/37271), [857df9e0](https://github.com/Katello/katello.git/commit/857df9e01ce9e8c594909c3b662e3cf62f2f904a), [4e585726](https://github.com/Katello/katello.git/commit/4e585726c3911dd183de4bf718c9bbeb27296f46))
 * As a user, when I refresh my manifest the expiration date of the identity certificate will get renewed, so that I am never caught with an expired manifest. ([#37266](https://projects.theforeman.org/issues/37266), [b342a208](https://github.com/Katello/katello.git/commit/b342a2085a07918de75ac626c24b94c6b86493b7))
 * Remove SCA-related API endpoints and params ([#37226](https://projects.theforeman.org/issues/37226), [7fe287f2](https://github.com/Katello/katello.git/commit/7fe287f2c78a336154df60bcc036266a255b4e27))

### Foreman Proxy Content
 * Allow granular repair functionality for capsules ([#37258](https://projects.theforeman.org/issues/37258), [03494eca](https://github.com/Katello/katello.git/commit/03494eca34658142013420e8d12417e33937aab4))
 * SmartProxy Content Sync should offer Verify Content Checksum ([#36803](https://projects.theforeman.org/issues/36803), [03494eca](https://github.com/Katello/katello.git/commit/03494eca34658142013420e8d12417e33937aab4))

### Content Views
 * Allow repairing content view versions ([#37237](https://projects.theforeman.org/issues/37237), [a3651e4b](https://github.com/Katello/katello.git/commit/a3651e4b977ad01ae249d58635ec8dfe4474aff5))
 * [RFE] Block content view publishing during repository publication tasks ([#37139](https://projects.theforeman.org/issues/37139), [ebfd49b4](https://github.com/Katello/katello.git/commit/ebfd49b414162ebebcdf68fa09c8542ce315752f))

### Reporting
 * SCA-Only: Remove Subscription-Entitlement notification ([#37170](https://projects.theforeman.org/issues/37170), [24b9c5c8](https://github.com/Katello/katello.git/commit/24b9c5c834fbc5ff30ad7d86d9f854a3dc6da1ca))

### katello-tracer
 * Use dnf needs-restarting to collect tracer information ([#36973](https://projects.theforeman.org/issues/36973), [f494bb9c](https://github.com/Katello/katello-host-tools.git/commit/f494bb9cc088216e018de45e17ea3fa41728dee3), [1408cbd8](https://github.com/Katello/katello-host-tools.git/commit/1408cbd8ca29d1a921a69e7f0f21597fe097e3c9))

### Other
 * It should be possible to upload a package / repos profile from UI ([#37191](https://projects.theforeman.org/issues/37191), [559f43c6](https://github.com/Katello/katello.git/commit/559f43c6ad81168ae396b61509d828129ceae6ec))

## Bug Fixes

### Content Credentials
 * asterisk symbol is missing for required field ([#37482](https://projects.theforeman.org/issues/37482), [d704d905](https://github.com/Katello/katello.git/commit/d704d9055b15f66d0e7938e582b00962fe24012c))

### Subscriptions
 * Org still holds stale cached manifest expiration date after manifest import/refresh ([#37481](https://projects.theforeman.org/issues/37481), [29330949](https://github.com/Katello/katello.git/commit/293309497b6ad3b6964fca5837516eb2d5fe784f))
 * subscription-manager release --unset doesn't reset the client information on foreman ([#37358](https://projects.theforeman.org/issues/37358), [d47e2e09](https://github.com/Katello/katello.git/commit/d47e2e099a35a62d75c1de94b4192ed2d6c98779))
 * Subscription Details Page has a broken page header ([#36924](https://projects.theforeman.org/issues/36924), [db9e0c28](https://github.com/Katello/katello.git/commit/db9e0c28e4c299a879c4efca47af9bdda75a3d48), [420e9a9a](https://github.com/Katello/katello.git/commit/420e9a9a30c569d287ae8368569bb730f5923e6b))

### Repositories
 * Upgrade pulp-container bindings to 2.20 ([#37414](https://projects.theforeman.org/issues/37414), [651453ef](https://github.com/Katello/katello.git/commit/651453efe8cf5e4cf09cc639ac93db8f33989608))
 * Fix typo for container_repository_name in metadata_generate_needed? ([#37408](https://projects.theforeman.org/issues/37408), [1dbd1b9b](https://github.com/Katello/katello.git/commit/1dbd1b9bf32655ab957d7c6a78860b749bdbca05))
 * Create a rake script that reindexes manifests with label information ([#37407](https://projects.theforeman.org/issues/37407), [62ad4c59](https://github.com/Katello/katello.git/commit/62ad4c5957688d4f6a698159e3809c217901c2c9))
 * Container push can fail with a different JSON error ([#37380](https://projects.theforeman.org/issues/37380), [95a55e0d](https://github.com/Katello/katello.git/commit/95a55e0da6b5355170a23bed51d6f5065c05cb7f))
 * Index Pulp manifest annotations, labels, is_bootable, is_flatpak and expose them via API ([#37379](https://projects.theforeman.org/issues/37379), [73dcade7](https://github.com/Katello/katello.git/commit/73dcade75cc8de39b87b95426fef7d17a33b46e7))
 * Fix Katello (or maybe BATS) -- orphan cleanup tries deleting distributed repo versions ([#37371](https://projects.theforeman.org/issues/37371), [1a5d9304](https://github.com/Katello/katello.git/commit/1a5d9304110cd93603dace51eb1385b693ceb86d))
 * Registry Service Accounts token is not accepted in "Upstream Authentication Token"  of a docker repo ([#37238](https://projects.theforeman.org/issues/37238), [39d52bd1](https://github.com/Katello/katello.git/commit/39d52bd1a048531be0e4b91bb8423f1fca0dca04))
 * Red Hat products that were never synced are reporting last synced time ([#31318](https://projects.theforeman.org/issues/31318), [19d4dd7a](https://github.com/Katello/katello.git/commit/19d4dd7ac501f29e1b61c89029b5850cf3cea1a6))

### Content Views
 * Content view publish failing with katello_repository_rpms_id_seq reached maximum value error ([#37403](https://projects.theforeman.org/issues/37403), [b405249f](https://github.com/Katello/katello.git/commit/b405249f329da215e31088fd5433ae8e01727b5a))
 * Newly imported content views show as needs publish ([#37254](https://projects.theforeman.org/issues/37254), [ec68d4ca](https://github.com/Katello/katello.git/commit/ec68d4ca614a5c7edd2a04d7767aa807c78dfe47))
 * Python content not getting published to versions ([#36611](https://projects.theforeman.org/issues/36611), [f5b4e571](https://github.com/Katello/katello.git/commit/f5b4e5710a20f828b06065604db0b73f0dcdbe6c))

### Foreman Proxy Content
 * Container gateway needs to send ACCEPT headers from podman to Pulp ([#37399](https://projects.theforeman.org/issues/37399), [ac7b5786](https://github.com/Katello/smart_proxy_container_gateway.git/commit/ac7b578652771bf9cbbee5815734dfccfae4a4de), [9440b1d5](https://github.com/Katello/smart_proxy_container_gateway.git/commit/9440b1d5ba75b483d85885dfd8507d0ae16db38b))
 * Container Gateway: concurrent logins trigger bad token error ([#37369](https://projects.theforeman.org/issues/37369), [39dfd4c0](https://github.com/Katello/smart_proxy_container_gateway.git/commit/39dfd4c059c7d2421387ca6aa86c06afba89fff3))

### Inter Server Sync
 * content export actions are failing in ruby 3 ([#37381](https://projects.theforeman.org/issues/37381), [1d15a187](https://github.com/Katello/katello.git/commit/1d15a1872b6c6ca89b9f25406b20a0e0a114bd90))

### API
 * API endpoint for activation_keys/:id/product_content should be TRUE by default ([#37350](https://projects.theforeman.org/issues/37350), [0540e33d](https://github.com/Katello/katello.git/commit/0540e33d0d992c4becc46ecd4d5efe506c3c7477))

### Upgrades
 * Upgrade pulpcore to 3.49 ([#37301](https://projects.theforeman.org/issues/37301), [ec0f7a2c](https://github.com/Katello/katello.git/commit/ec0f7a2cd5f6020c43d3f50b30e604adf98f8d9c))

### Hosts
 *  katello:clean_backend_objects false alarms on systems with >1500 clients when PUTing customer facts ([#37283](https://projects.theforeman.org/issues/37283), [b72874d1](https://github.com/Katello/katello.git/commit/b72874d1e734dc6ce29b5b5ec12ccc3f478db627))
 * Update Checkin time for ESXi hypervisors from virt-who report ([#37162](https://projects.theforeman.org/issues/37162), [72394b6c](https://github.com/Katello/katello.git/commit/72394b6cf9daa0fb56f51b359aedb18ad668956b))
 * Host content view environment is reset on any host edit when hostgroup assigns a CVE ([#36897](https://projects.theforeman.org/issues/36897), [a896b2f5](https://github.com/Katello/katello.git/commit/a896b2f595e84f7385298f12d6f822bce39d195a))

### Hammer
 * Add verify-checksum command for CV versions in hammer ([#37235](https://projects.theforeman.org/issues/37235), [a6bbddd0](https://github.com/Katello/hammer-cli-katello.git/commit/a6bbddd0deae108a1df028f368feeb4e985421df))
 * Update hammer to remove SCA command and remove references of it from organization create/update/list/info ([#37230](https://projects.theforeman.org/issues/37230), [269635c5](https://github.com/Katello/hammer-cli-katello.git/commit/269635c5a15601a4b475f459bfed7ccc979c387c))
 * Improve displayed filter rules info in hammer ([#37181](https://projects.theforeman.org/issues/37181), [4ac06b46](https://github.com/Katello/katello.git/commit/4ac06b46fb75dbea9fb7e8a801546f6450543e39))

### Container
 * `podman login` against the container registry returns 500 intermittently ([#37218](https://projects.theforeman.org/issues/37218), [f96702c4](https://github.com/Katello/smart_proxy_container_gateway.git/commit/f96702c4a4a49c170a9773f343ccdfb40aa6693c))

### Tooling
 * Missing development dependencies for rubocop ([#36998](https://projects.theforeman.org/issues/36998), [2e084c90](https://github.com/Katello/katello.git/commit/2e084c9018b574453084827c9ff548d6379c4110), [7f99691e](https://github.com/Katello/katello.git/commit/7f99691e986189a27f285cd02644effb06c932e9), [98c9fee8](https://github.com/Katello/katello.git/commit/98c9fee806a7ee36d1b0c7f3506e63290dea57fc))

### Other
 * Package rubygem-dynflow not listed in a list of packages ([#37457](https://projects.theforeman.org/issues/37457), [48746afd](https://github.com/Katello/katello.git/commit/48746afde64550eeb5570676c089502eabe103ed))
 * Fix upstream lint issues ([#37331](https://projects.theforeman.org/issues/37331), [58d2cdb1](https://github.com/Katello/katello.git/commit/58d2cdb13b2c6d04684f717611d79322cbc53d51))
 * It is possible to end up with the wrong remote type (uln vs. normal) for yum content ([#37279](https://projects.theforeman.org/issues/37279), [97f8a09c](https://github.com/Katello/katello.git/commit/97f8a09c3338b702c1d2735318e8c5e3b1b6b953))