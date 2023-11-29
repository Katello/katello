# 4.11.0 (2023-11-28)

## Features

### Hosts
 * Support Foreman API bulk host deletion ([#36878](https://projects.theforeman.org/issues/36878), [95c8263c](https://github.com/Katello/katello.git/commit/95c8263c2cf7c32db17040b9006067cf0f1d8158))
 * Preselect upgradable packages when clicking on installable packages on the hosts page ([#36794](https://projects.theforeman.org/issues/36794), [7fb4c8e6](https://github.com/Katello/katello.git/commit/7fb4c8e644f5a8e35963dd5c86234518ba782045))
 * As a web UI user, I can view RHEL client lifecycle alerts on the content host detail page ([#36756](https://projects.theforeman.org/issues/36756), [bd253739](https://github.com/Katello/katello.git/commit/bd253739771282b52f453da351641dac8d4b7a5b))
 * I have a new notification about how many RHEL clients are about to EOS ([#36735](https://projects.theforeman.org/issues/36735), [06cf003b](https://github.com/Katello/katello.git/commit/06cf003bf238f515e374c1a61ccab353d20eb9c1))
 * Add new searchable host_status column that tells me about RHEL life cycle support in host index page ([#36732](https://projects.theforeman.org/issues/36732), [b4661678](https://github.com/Katello/katello.git/commit/b46616785462d629f3bf5409617244bec7b1b59b))
 * Add new host status for RHEL lifecycle alert ([#36693](https://projects.theforeman.org/issues/36693), [d442ec12](https://github.com/Katello/katello.git/commit/d442ec12ccaa7d0e01949001c05e7ff329e80e70))

### Web UI
 * Add the action for Change Content Sources  ([#36862](https://projects.theforeman.org/issues/36862), [c90b9a01](https://github.com/Katello/katello.git/commit/c90b9a010e8fd62f5ecf9e7784a1bd2ac19e63bc))

### Foreman Proxy Content
 * Trigger capsule content count update action after Orphan cleanup ([#36857](https://projects.theforeman.org/issues/36857), [f07f4742](https://github.com/Katello/katello.git/commit/f07f47424a1874821f970b527a27b148b47dbc4a))
 * As a user, I want to have a way to refresh the calculated counts on-demand on the UI ([#36807](https://projects.theforeman.org/issues/36807), [ed385972](https://github.com/Katello/katello.git/commit/ed3859729a2cb71c59ae5657b34b44805115603f))
 * As a user, I want to have package counts shown on capsule content page ([#36758](https://projects.theforeman.org/issues/36758), [8199f335](https://github.com/Katello/katello.git/commit/8199f3353975ed32d54418bc7b4dc7f3e6ca7ece))
 * Add content counts to API results and add aggregated CV version content counts to Capsule content counts ([#36750](https://projects.theforeman.org/issues/36750), [244a6066](https://github.com/Katello/katello.git/commit/244a6066f9025cdc0fa09921baaf36f5b182e51f))
 * Redesign capsule sync page to prepare for new enhancements on the page. ([#36720](https://projects.theforeman.org/issues/36720), [8199f335](https://github.com/Katello/katello.git/commit/8199f3353975ed32d54418bc7b4dc7f3e6ca7ece))
 * As a user, I want to have the package counts pre-calculated on smart proxy sync ([#36702](https://projects.theforeman.org/issues/36702), [70896729](https://github.com/Katello/katello.git/commit/70896729437446f45c2ac968b1619a4df63345a1))

### Hammer
 * Show content counts with `hammer capsule content info` ([#36814](https://projects.theforeman.org/issues/36814), [f3c33cb6](https://github.com/Katello/hammer-cli-katello.git/commit/f3c33cb6fdf1b6e144edbc894d70b43bc06e3645))
 * Prepare for SCA-Only: Update Hammer ([#36795](https://projects.theforeman.org/issues/36795), [3bc7d4c6](https://github.com/Katello/hammer-cli-katello.git/commit/3bc7d4c6182eb9b615ef7123a4ea06a0fd701df8))

### Subscriptions
 * Prepare for SCA-Only: Update Web UI ([#36782](https://projects.theforeman.org/issues/36782), [dbfa00bd](https://github.com/Katello/katello.git/commit/dbfa00bdc1c4de147b2a4503e4815d81ed64c55f))

### Repositories
 * Change the color of the remove repository icon when repositories cannot be removed ([#36733](https://projects.theforeman.org/issues/36733), [0db661ca](https://github.com/Katello/katello.git/commit/0db661ca1c221002ed97979de0db6778adf10f60))

### Activation Key
 * Add system purpose card to new AK details page ([#36610](https://projects.theforeman.org/issues/36610), [4867c8a2](https://github.com/Katello/katello.git/commit/4867c8a28e1eab1b0eae126bb4a7a8097c3b43f9))
 * Add new activation key details page under experimental labs ([#36493](https://projects.theforeman.org/issues/36493), [2fdde824](https://github.com/Katello/katello.git/commit/2fdde824c39c48cb6e1efb002af7d73fe5ed6b4a))

### Other
 * Prepare for SCA-Only: Deprecate API endpoints and params ([#36797](https://projects.theforeman.org/issues/36797), [27ce2b78](https://github.com/Katello/katello.git/commit/27ce2b78787f5d5104353d6eafbe5296948b4cb5))

## Bug Fixes

### Hosts
 * katello:reimport fails with "TypeError: no implicit conversion of String into Integer" when there are product contents to move ([#36920](https://projects.theforeman.org/issues/36920), [12c3f778](https://github.com/Katello/katello.git/commit/12c3f778b327dbaca310fb22153297e228b8e0be))
 * Slow generate applicability for Hosts with multiple modulestreams installed ([#36850](https://projects.theforeman.org/issues/36850), [d2baeb26](https://github.com/Katello/katello.git/commit/d2baeb2642046c52cf779d82f91461aa32c869cb))
 * When installing a new package, the job is labeled with a job ID and not the package. ([#36846](https://projects.theforeman.org/issues/36846), [586f2fee](https://github.com/Katello/katello.git/commit/586f2feec6879586165abda2ab11d5cdee2845b6))
 * Re-registering a host does not change content source ([#36840](https://projects.theforeman.org/issues/36840), [c045d9bc](https://github.com/Katello/katello.git/commit/c045d9bc9f7c527bbc56da34c6a4af5c0a84c6b4))
 * Recalculate errata uses out-of-date host package profile ([#36789](https://projects.theforeman.org/issues/36789), [a5782848](https://github.com/Katello/katello.git/commit/a57828483396b6e02e4b6d849202a0253abe9004))
 * OraceLinux supports ModuleStreams, too ([#36754](https://projects.theforeman.org/issues/36754), [ca25ba54](https://github.com/Katello/katello.git/commit/ca25ba54e39941298b4041959129012b4ea8135e))
 * PG::UniqueViolation on index_cve_cp_id during registration ([#36753](https://projects.theforeman.org/issues/36753), [337b5d61](https://github.com/Katello/katello.git/commit/337b5d6163d324ad601a4165e90dae7de4779392))
 * RHEL lifecycle status depends on 'RedHat' operatingsystem name ([#36731](https://projects.theforeman.org/issues/36731), [cdbc7010](https://github.com/Katello/katello.git/commit/cdbc7010d0f4da03c2a8f2413f69d4b5fdebc133))
 * Redefine append domain names setting in Katello ([#36328](https://projects.theforeman.org/issues/36328), [a02cd425](https://github.com/Katello/katello.git/commit/a02cd42570f096350421394cfdab7879aa68bf0e), [abf5c0c4](https://github.com/Katello/katello.git/commit/abf5c0c47e5198cdb4a94852e67be787d3cfbfe8))

### Errata Management
 * Generate applicability tasks fails with error "ERROR:  insert or update on table "katello_content_facet_errata" violates foreign key constraint "katello_content_facet_errata_ca_id" ([#36914](https://projects.theforeman.org/issues/36914), [17c731a6](https://github.com/Katello/katello.git/commit/17c731a6c8df23b8d3ab712fcb22d4e902efd530))
 * errata's issued and updated times shouldn't be changed to local timezone on WebUI ([#36882](https://projects.theforeman.org/issues/36882), [e0145f8e](https://github.com/Katello/katello.git/commit/e0145f8e1dd3a8adf61dbad6f5f3d05c9d5f4f5f))
 * Timeout for "hammer  --no-headers erratum list --errata-restrict-applicable 1 --organization-id 1" ([#36835](https://projects.theforeman.org/issues/36835), [2653d8ca](https://github.com/Katello/katello.git/commit/2653d8ca9e7d0484e33af027efe20f6899dfbb11))
 * Applied Errata report download fails with undefined method `value' for nil:NilClass error ([#36811](https://projects.theforeman.org/issues/36811), [159b0d1d](https://github.com/Katello/katello.git/commit/159b0d1d015b0b0cdbf74d7e1f2bf750a85cb4df))
 * Recalculate button for Errata is not available on Satellite 6.13/ Satellite 6.14 if no errata is present ([#36790](https://projects.theforeman.org/issues/36790), [9d03ca67](https://github.com/Katello/katello.git/commit/9d03ca678b4613cf58563def09517fa82f84af0c))
 * 'hammer erratum list' Gives 'Error: environment not found' If '--lifecycle-environment' Is Used. ([#36773](https://projects.theforeman.org/issues/36773), [ab9f1380](https://github.com/Katello/hammer-cli-katello.git/commit/ab9f1380b28d52ac075008b14a75bab2ad1239bd))

### Container
 * Taxonomy filtration on Container Image Tags page does not work as expected ([#36911](https://projects.theforeman.org/issues/36911), [9309d121](https://github.com/Katello/katello.git/commit/9309d121d8b0cf88777ba0fe853ebd9955c03d9c))

### Tooling
 * Upgrade to Pulpcore 3.39 ([#36903](https://projects.theforeman.org/issues/36903), [7436bf11](https://github.com/Katello/katello.git/commit/7436bf113a4bcd28a322d6df9b363e4f42009e7f))
 * Events can be incorrectly marked as In Progress by the Event Queue ([#36670](https://projects.theforeman.org/issues/36670), [142002a7](https://github.com/Katello/katello.git/commit/142002a7334acbe5df5bbd9e5654ab70fcc917b8))

### Tests
 * Update Candlepin VCR's with new Candlepin 4.3.10 ([#36901](https://projects.theforeman.org/issues/36901), [a69f9846](https://github.com/Katello/katello.git/commit/a69f9846c55c3a1f91f0049bcfb7e39de2995d92))
 * Hammer katello has random test failures around cv promote ([#36788](https://projects.theforeman.org/issues/36788), [a54dc018](https://github.com/Katello/hammer-cli-katello.git/commit/a54dc0180084a379e4603f2c5291fe8667940920))

### Content Views
 * hammer content-view version info not working with --lifecycle-environment flag ([#36900](https://projects.theforeman.org/issues/36900), [fee98736](https://github.com/Katello/hammer-cli-katello.git/commit/fee987369dee4a1cd29449cc22ef680dfddd328b))
 * Satellite showing the wrong date when using a filter when the 'end date' ([#36883](https://projects.theforeman.org/issues/36883), [7af23167](https://github.com/Katello/katello.git/commit/7af2316758fc448fcb219b924cd156a85cf91e75))
 * Promoting a composite content view to environment with registry name as "<%= lifecycle_environment.label %>/<%= repository.name %>" on Red Hat Satellite 6 fails with "'undefined method '#label' for NilClass::Jail (NilClass)'" ([#36776](https://projects.theforeman.org/issues/36776), [173b904b](https://github.com/Katello/katello.git/commit/173b904b579f174cde91f495791c6bdee58853f2))
 * hammer content-view list --full-result true command doesn't show the list of all the repository IDs. ([#36743](https://projects.theforeman.org/issues/36743), [8330f7ab](https://github.com/Katello/hammer-cli-katello.git/commit/8330f7ab955cfe061f25097f78b76a1af7dcf96c))
 * Bring back duplicate content warning for composite CVs for non-docker repos ([#36492](https://projects.theforeman.org/issues/36492), [a485b371](https://github.com/Katello/katello.git/commit/a485b3715913b48b3dc97a4fce01499dd3470c1c))
 * Wrong listing of Content Views which contain Files ([#36288](https://projects.theforeman.org/issues/36288), [3c41dfee](https://github.com/Katello/katello.git/commit/3c41dfeef4f0bcd35b0bc3e4a892cf4b340be65f))

### Localization
 * Make more strings translatable and extract strings for Katello 4.11 ([#36884](https://projects.theforeman.org/issues/36884), [1ca7df74](https://github.com/Katello/katello.git/commit/1ca7df748ad91a394570942ac8a3eff0b6fb332c))

### Foreman Proxy Content
 * Store all env_ids for smart_proxy complete sync in task input or output ([#36873](https://projects.theforeman.org/issues/36873), [d5f40d54](https://github.com/Katello/katello.git/commit/d5f40d542a646e6430e352039c7cba81604302bd))
 * Last capsule sync date should have a way to query per environment ([#36852](https://projects.theforeman.org/issues/36852), [a2611464](https://github.com/Katello/katello.git/commit/a2611464f75812e9bc453b15160582e4754615e6))
 * Properly translate rpm.modulemd to "module_stream" ([#36820](https://projects.theforeman.org/issues/36820), [3c152d0f](https://github.com/Katello/katello.git/commit/3c152d0fe328fec59e85e833539165330273b6b2))
 * Delete oprhan content task doesn't remove orphaned remotes in the Capsule ([#36787](https://projects.theforeman.org/issues/36787), [be25c084](https://github.com/Katello/katello.git/commit/be25c084fd7bd141eaed5a7d55f13cec8540af9b))
 * [smart_proxy_container_gateway] introduce sqlite timeout tuning ([#36771](https://projects.theforeman.org/issues/36771), [adc61957](https://github.com/Katello/smart_proxy_container_gateway.git/commit/adc61957f42a8f7205b0630a9d0a976511551b47))
 * Sync timeouts should be available for smart-proxy syn ([#36737](https://projects.theforeman.org/issues/36737), [8b2e94f0](https://github.com/Katello/katello.git/commit/8b2e94f091e7dec13c0b86f98fc9bbaeb2cf9ba2))
 * Non-admin user cannot list an individual capsule but can list all capsules ([#36726](https://projects.theforeman.org/issues/36726), [23091275](https://github.com/Katello/katello.git/commit/2309127577a534c5e024bd0a1d67dfb992176eb5))
 * syncing a capsule fails with ActiveRecord::RecordNotFound Couldn't find SmartProxy with 'id'=2 ([#36520](https://projects.theforeman.org/issues/36520), [f9ce129c](https://github.com/Katello/katello.git/commit/f9ce129c658d6405c5d3b47dcd5cb63b27417cff))
 * Track reclaimspace task properly as an allowed action ([#35556](https://projects.theforeman.org/issues/35556), [878b5f4e](https://github.com/Katello/katello.git/commit/878b5f4e86cca5d01edf259f87205ad97d2b6c03))

### Repositories
 * Add error handling in repo sync when trying to sync non-library repos ([#36844](https://projects.theforeman.org/issues/36844), [2831bae1](https://github.com/Katello/katello.git/commit/2831bae1c7f80dcd435dd4eae7b2b38a632fd76a))
 * Deb package applicability should consider architecture ([#36740](https://projects.theforeman.org/issues/36740), [2cdea3fb](https://github.com/Katello/katello.git/commit/2cdea3fb282abc07a99e01815bf8fc89de3bf863))
 * 'Module Streams' hyperlink missing in 'Content --> Module Streams --> $stream' ([#36708](https://projects.theforeman.org/issues/36708), [d7324528](https://github.com/Katello/katello.git/commit/d732452813d38df93e0d6210ba08708ad76ea414))
 * File content count in Product > Repositories is not presented as a link ([#36612](https://projects.theforeman.org/issues/36612), [4e922d8e](https://github.com/Katello/katello.git/commit/4e922d8e5c2435d66c2b7b99e49c802f728f8b73))
 * Hide option to delete content from Redhat repos ([#36554](https://projects.theforeman.org/issues/36554), [ece3963f](https://github.com/Katello/katello.git/commit/ece3963f73d689b9d82378b65d3c8d9824ccbdab))

### Reporting
 * Add methods to safemode jail for new products report ([#36828](https://projects.theforeman.org/issues/36828), [2212c9af](https://github.com/Katello/katello.git/commit/2212c9af4df9e0ce5adf22e3359bf7a3ce01801f))

### katello-tracer
 * katello-tracer-upload: command not found when executed via remote execution using effective user other than root. ([#36808](https://projects.theforeman.org/issues/36808), [f310056e](https://github.com/Katello/katello.git/commit/f310056e74107c68ee7a290c9d74281c553b3e00))

### Hammer
 * To have "reclaim-space" option introduced for "hammer capsule content" command ([#36777](https://projects.theforeman.org/issues/36777), [f247480e](https://github.com/Katello/hammer-cli-katello.git/commit/f247480e04e26134f4002572f7f6e12feee22495))

### Web UI
 * Host UI Details has storage unit set to bytes ([#36766](https://projects.theforeman.org/issues/36766), [85c310be](https://github.com/Katello/katello.git/commit/85c310be2b81e73feb708b66da594760df709c6b))
 * Katello css overrides foreman ([#36762](https://projects.theforeman.org/issues/36762), [dc02aab4](https://github.com/Katello/katello.git/commit/dc02aab466e61a1bdde759ab52ccacd0978b09eb))
 * Fix sticky pagination in rh repos ([#36367](https://projects.theforeman.org/issues/36367), [fe72e98f](https://github.com/Katello/katello.git/commit/fe72e98f2e100bd878cc1502a4de633a24660b4d))

### Sync Plans
 * Product without any repo is added to a Sync Plan regardless the error message ([#36739](https://projects.theforeman.org/issues/36739), [5d782bc1](https://github.com/Katello/katello.git/commit/5d782bc15bcaac6fd763fc2e9651c3ebb7b2a076))
 * Unclear error message when disabling last repo of a product that is in a sync plan ([#36690](https://projects.theforeman.org/issues/36690), [68294f2e](https://github.com/Katello/katello.git/commit/68294f2e21a2c98cdb011be1a3e3f9e953c19d23))

### Host Collections
 * Host collections errata broken ([#36713](https://projects.theforeman.org/issues/36713), [506c5282](https://github.com/Katello/katello.git/commit/506c5282e72d1c4dcbd5a579d189641b0ec84f4b))

### Inter Server Sync
 * Ensure permission on listing file is 644 during syncable exports ([#36689](https://projects.theforeman.org/issues/36689))
 * Can't update the redhat_repository_url without changing the cdn_configuration to custom_cdn ([#36463](https://projects.theforeman.org/issues/36463), [3cb9f1a5](https://github.com/Katello/katello.git/commit/3cb9f1a53cb29c3b1e6e097562087e9cb12eb34b))
 * Better error message when content-export fails due to unsynced repository ([#36162](https://projects.theforeman.org/issues/36162), [f238c238](https://github.com/Katello/katello.git/commit/f238c23896194b6a5165c6eb7c87670c19a55b2a))

### Subscriptions
 * A failed "Actions::Katello::Host::Hypervisors" task lacks identifying information ([#36599](https://projects.theforeman.org/issues/36599), [f0404d13](https://github.com/Katello/katello.git/commit/f0404d130f95e211227b794f41dbfbf7409475b0))

### Security
 * Empty The Foreman and Katello repository on client side ([#36544](https://projects.theforeman.org/issues/36544))

### Activation Key
 * Environment and Content View info is not visible on the Associations Content Host page for Activation keys ([#36501](https://projects.theforeman.org/issues/36501), [b8857514](https://github.com/Katello/katello.git/commit/b8857514670e82f88a1d03e859fc76535504f44f))

### Other
 *  Cannot discovery container repositories on private registries or on registries that only support api v2 ([#36861](https://projects.theforeman.org/issues/36861), [6619b6d3](https://github.com/Katello/katello.git/commit/6619b6d3824f0afdb7e0a0edcc20e2b2fc561db3))
 * Fix SIGKILL in test and nightly pipelines ([#36853](https://projects.theforeman.org/issues/36853), [f59a21a5](https://github.com/Katello/katello.git/commit/f59a21a5cc47904ff20e7fbf1345e5ed0bc343b8))
 * Container registries for Sat and Capsule set wrong token expiration field ([#36827](https://projects.theforeman.org/issues/36827), [63ebb473](https://github.com/Katello/smart_proxy_container_gateway.git/commit/63ebb4732511057820a9529b20b7696a2145f8fe), [ad53ad96](https://github.com/Katello/smart_proxy_container_gateway.git/commit/ad53ad96924edd6086e9f6c0d9c99e1a142bc2f1), [ad424635](https://github.com/Katello/katello.git/commit/ad42463519fbb8e063a0ec3417f5155b0f77d7c7))
