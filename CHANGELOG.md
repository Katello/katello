# 4.8.0 Phoenix (2023-02-21)

## Features

### Inter Server Sync
 * Need incremental export for syncable format ([#35948](https://projects.theforeman.org/issues/35948), [3dd58df7](https://github.com/Katello/katello.git/commit/3dd58df7579341b0b1dba7017b2e7086cd6477bd))

### Content Views
 * Backend work: As a user I want to be able to assign multiple content views on a content host ([#35580](https://projects.theforeman.org/issues/35580), [c33da7a3](https://github.com/Katello/katello.git/commit/c33da7a3fa9473add44a154feba4e57f34b2b289))

### Tests
 * ouia-ID for tile cards in the new host details page ([#35411](https://projects.theforeman.org/issues/35411), [2c01e818](https://github.com/Katello/katello.git/commit/2c01e818765d49bb38562e9313a4587df18faaeb), [ecd11019](https://github.com/Katello/katello.git/commit/ecd11019cf5c30c1779a756cb116f506ee71e139))

### Other
 * Allow installed_debs method ([#35886](https://projects.theforeman.org/issues/35886), [e630a6e2](https://github.com/Katello/katello.git/commit/e630a6e28a23795739b05c9625747fa8784884c2))
 * Last checkin and Registered columns should show up as empty if there's no data ([#35854](https://projects.theforeman.org/issues/35854), [3920e5a7](https://github.com/Katello/katello.git/commit/3920e5a7384e93769dfa830b8097ed210c9a0e3d))
 * As a user, I can CRUD Simplified ACSs via the API and hammer ([#33455](https://projects.theforeman.org/issues/33455))

## Bug Fixes

### Web UI
 * Bulk select/deselect does not work properly on paginated ACS page ([#36103](https://projects.theforeman.org/issues/36103), [8cb8f277](https://github.com/Katello/katello.git/commit/8cb8f2777fd350d31bf5c9f8974e647ac821f613))
 * Update JS snapshots after PF update ([#36081](https://projects.theforeman.org/issues/36081), [9db5562a](https://github.com/Katello/katello.git/commit/9db5562ae93502dd00ff56f8f16ab2096b136fd8))
 * Link from Content Hosts should navigate to Host's Content pane/tab ([#36078](https://projects.theforeman.org/issues/36078), [15352c2a](https://github.com/Katello/katello.git/commit/15352c2a07b5e8c3060eb9c7e0f00d81578ef160))
 * Add warning in UI that space reclamation won't work on deleted repositories ([#35935](https://projects.theforeman.org/issues/35935), [a8f0e832](https://github.com/Katello/katello.git/commit/a8f0e832e907d877272d2cc04c803510b93ac2e7))
 * Audit ouia-ids for ACS UI ([#35873](https://projects.theforeman.org/issues/35873), [cafb1428](https://github.com/Katello/katello.git/commit/cafb1428a6b2947d8aace72dca361b6c478ba07c), [22db652c](https://github.com/Katello/katello.git/commit/22db652c2fa8efbc00109ef0077774238ee08961))
 * wrap bookmarks in angular pages ([#35771](https://projects.theforeman.org/issues/35771), [b7f84e5a](https://github.com/Katello/katello.git/commit/b7f84e5a6daa3168ea2009d26b17634cd696f0b1))

### Repositories
 * Saving RHUI alternate content source with a malformed Base URL is possible ([#36074](https://projects.theforeman.org/issues/36074), [09f69b74](https://github.com/Katello/katello.git/commit/09f69b74148fe2af5177f9240060f5691182cfe1))
 * Add validations for RHUI ACS create and update ([#36042](https://projects.theforeman.org/issues/36042), [b4340d54](https://github.com/Katello/katello.git/commit/b4340d5417175a538cc749e8160c2d57ba8acdef))
 * Add some validation for name in Simplified ACS creation via hammer ([#36041](https://projects.theforeman.org/issues/36041), [3bdb5ae8](https://github.com/Katello/katello.git/commit/3bdb5ae877d64110cda1961b2abce1b857c91789))
 * Upgrade to 4.5 may fail to apply RemoveDrpmFromIgnorableContent migration if erratum is also a ignorable content type for any repo ([#35864](https://projects.theforeman.org/issues/35864), [98fe46f4](https://github.com/Katello/katello.git/commit/98fe46f4ea32ff10f28f2391b096e06e4fb13f6b))

### Tests
 * Re-enable test_sync_skipped_srpms ([#36053](https://projects.theforeman.org/issues/36053), [35fbe9b7](https://github.com/Katello/katello.git/commit/35fbe9b7af6bf69a05983b6af6052e3ff619a3cd))
 * Intermittent docker content type not found error in Actions::Katello::Repository::UploadDockerTest ([#35735](https://projects.theforeman.org/issues/35735), [0047bb6d](https://github.com/Katello/katello.git/commit/0047bb6df73d828ac598ca85c84898de47121c3d))
 * Uncomment upload tests that were commented while waiting on updated pulp bindings that upgrade Faraday to 1.0.1 ([#35395](https://projects.theforeman.org/issues/35395), [f0f54d67](https://github.com/Katello/katello.git/commit/f0f54d67fb123940fecac4a71fbcd13ee5128e69))
 * Comment upload tests while waiting on updated pulp bindings that upgrade Faraday to 1.0.1 ([#35394](https://projects.theforeman.org/issues/35394), [53454eb7](https://github.com/Katello/katello.git/commit/53454eb7d4f61cfef13308d0f919dab8a32f520f))

### Hammer
 * hammer acs show does not show any SSL related fields ([#36052](https://projects.theforeman.org/issues/36052), [d2ab20e9](https://github.com/Katello/hammer-cli-katello.git/commit/d2ab20e935483fd345e92abd1f13828f0a4aeaae))
 * hammer repository types command is missing options ([#35666](https://projects.theforeman.org/issues/35666), [80707a08](https://github.com/Katello/hammer-cli-katello.git/commit/80707a083c0315fb928c3d687518dcee2734fabd))
 * hammer failed to override repository sets ([#35640](https://projects.theforeman.org/issues/35640), [46094b64](https://github.com/Katello/katello.git/commit/46094b64985f284522b4d71e794cfa2549d14e5c))

### Content Views
 * Missing ouia-id for content view ([#35989](https://projects.theforeman.org/issues/35989), [223243e0](https://github.com/Katello/katello.git/commit/223243e0b4bb6f1a2c689169aa5afc0861a4cc67))
 * Unable to promote content view due to "NoMethodError: undefined method `get_status' for nil:NilClass" ([#35861](https://projects.theforeman.org/issues/35861), [f37728cc](https://github.com/Katello/katello.git/commit/f37728cc5f2eb57ad9e242573ef7a647a4e2cb92), [927d0564](https://github.com/Katello/katello.git/commit/927d0564ead514150a8979479af2d500fc9f0e49), [cb5621bb](https://github.com/Katello/katello.git/commit/cb5621bbfe9275dc9a5a53bd0c90bf463b2313fa))
 * hammer content-view purge only deletes up to "Entries per page" versions ([#35750](https://projects.theforeman.org/issues/35750), [6f9bd71e](https://github.com/Katello/hammer-cli-katello.git/commit/6f9bd71e62a5187b8bb05551984685334432e86c))
 * Content view filter included errata not in the filter date range ([#35614](https://projects.theforeman.org/issues/35614), [49500819](https://github.com/Katello/katello.git/commit/4950081967a99de4b68825cbe86ea8845334b155))

### Subscriptions
 * Deb repository using multiple archs is not provided to managed host ([#35968](https://projects.theforeman.org/issues/35968), [8d6c1a80](https://github.com/Katello/katello.git/commit/8d6c1a80911965b92d16480327c92facd7146d9c))
 * 'Import a Manifest' button displays when a blank manifest is imported ([#35963](https://projects.theforeman.org/issues/35963), [04a24695](https://github.com/Katello/katello.git/commit/04a246957d4e2fe31e0f2fc0a8f11acd840066b4))
 * Registration error: PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "katello_available_module_streams_name_stream_context" ([#35936](https://projects.theforeman.org/issues/35936), [d4c72d2c](https://github.com/Katello/katello.git/commit/d4c72d2c11a7b6548cdee6ab05b89887a4fcee2e))
 * consumer uuid differing between candlepin and katello ([#35381](https://projects.theforeman.org/issues/35381), [a3b1f51e](https://github.com/Katello/katello.git/commit/a3b1f51efcddb5976020690acb6ddde72de0915a))

### Foreman Proxy Content
 * delete orphans task does not remove pulp3 remotes from capsules when removing repositories ([#35965](https://projects.theforeman.org/issues/35965), [9e6cab22](https://github.com/Katello/katello.git/commit/9e6cab229def6c337cf5830c73370724bc95f0ad))
 * Inspecting an image with skopeo no longer works on smart proxies ([#35801](https://projects.theforeman.org/issues/35801), [19370a11](https://github.com/Katello/smart_proxy_container_gateway.git/commit/19370a115202a10102bb86c674abca213d82b8ea))
 * Python content isn't sychronized to smart proxies ([#35091](https://projects.theforeman.org/issues/35091), [e1a6974c](https://github.com/Katello/katello.git/commit/e1a6974cd9ba07a997102a3b0f919f766cc48270))

### API
 * Creating an organization through API does not propagate encountered errors properly ([#35954](https://projects.theforeman.org/issues/35954), [94ed9749](https://github.com/Katello/katello.git/commit/94ed9749edb0e9350047054bc8d060417256cfd0))

### Hosts
 * Package and Errata actions on content hosts selected using the "select all hosts" option fails. ([#35947](https://projects.theforeman.org/issues/35947), [8001e4c3](https://github.com/Katello/katello.git/commit/8001e4c39a1b9219e2fe63a32900f170f0def5a3))
 * Repository sets banner shows "" for content view and lifecycle environment ([#35878](https://projects.theforeman.org/issues/35878), [f07230ec](https://github.com/Katello/katello.git/commit/f07230ecc6041a3d06123a6d61a747beaa345ad2))
 * Registration fails in method:  host_setup_extension ([#35874](https://projects.theforeman.org/issues/35874), [db5a820f](https://github.com/Katello/katello.git/commit/db5a820f93dad82348b382570fdad90e36c6f51c))
 * Overriding 25 repo sets to disabled causes error ([#35818](https://projects.theforeman.org/issues/35818), [7592f61e](https://github.com/Katello/katello.git/commit/7592f61ef3fa0c2dadc3c178f72a6dc13b7f9929))
 * Repository sets not reflecting SCA status on direct load ([#35604](https://projects.theforeman.org/issues/35604), [6e500def](https://github.com/Katello/katello.git/commit/6e500def9afdadccba0c626a4fbcd475d0fba52c))
 * Errata tooltip not pluralized ([#35046](https://projects.theforeman.org/issues/35046), [5c4b1ef7](https://github.com/Katello/katello.git/commit/5c4b1ef7aa5b6ca6e47b9bd5deb72f81f25c230e))

### Host Collections
 * minor, help text for HC host list when empty speaks of HG, not HC ([#35937](https://projects.theforeman.org/issues/35937), [6b2b86d9](https://github.com/Katello/katello.git/commit/6b2b86d96f54497527df1387d4048cf151bd9c57))

### Tooling
 * Upgrade to Pulpcore 3.22 ([#35934](https://projects.theforeman.org/issues/35934), [d298ddad](https://github.com/Katello/katello.git/commit/d298ddad79a61cc5a85a57bfd12b7841b4fd2174))
 * Don't initialize EventDaemon in rake tasks ([#35774](https://projects.theforeman.org/issues/35774), [16d25a52](https://github.com/Katello/katello.git/commit/16d25a52bf37b8d2895e96559c8c369883607818), [3ef7613c](https://github.com/Katello/katello.git/commit/3ef7613c93985e003e1f07625441706ec120c749))

### Container
 * The "pulp_docker_registry_port" settings is still exposed and set to port 5000 ([#35783](https://projects.theforeman.org/issues/35783), [b31ae26d](https://github.com/Katello/katello.git/commit/b31ae26d5ee9ed255c2665780b1968ed53a904b1))

### Client/Agent
 * katello-agent use upgrade instead of upgrade-minimal when applying errata in dnf ([#35759](https://projects.theforeman.org/issues/35759), [046a17d3](https://github.com/Katello/katello-host-tools.git/commit/046a17d3d52496dc6dfcb825ab900c12ca8a6046))

### Errata Management
 * Errata search filtered with ID does not work in Web UI  ([#35752](https://projects.theforeman.org/issues/35752), [c51a6897](https://github.com/Katello/katello.git/commit/c51a68973a0b00a6c169b7ea97eefd79fd5428ed))
 * Improve empty state design when a host has applicable errata but no installable errata ([#35707](https://projects.theforeman.org/issues/35707), [53b2a567](https://github.com/Katello/katello.git/commit/53b2a5677c5eb90d115b8eb74bdd34c4f2674b08))
 *  Email notification shows incorrect new errata after syncing an Epel repository ([#35191](https://projects.theforeman.org/issues/35191), [a5e9405a](https://github.com/Katello/katello.git/commit/a5e9405a44d62b224257cb3b371e47f35970ea71))

### Other
 * NoMethodError when reassigning hosts while deleting a content view version ([#36043](https://projects.theforeman.org/issues/36043), [96c23ce7](https://github.com/Katello/katello.git/commit/96c23ce7ffee083be13bb0cfcfa444fb28b5c934))
 * Subscription can't be blank, A Pool and its Subscription cannot belong to different organizations ([#36025](https://projects.theforeman.org/issues/36025), [a52b58a0](https://github.com/Katello/katello.git/commit/a52b58a030fad092567feaf8520a8193db7ebd7a))
 * Migration error 'column settings.category does not exist' ([#36007](https://projects.theforeman.org/issues/36007), [87ddaf17](https://github.com/Katello/katello.git/commit/87ddaf179f9598bf11b2bce319d0310fc23aee68))
 * deleting of products after a content export ends up in a candlepin error ([#35929](https://projects.theforeman.org/issues/35929), [4d2503ad](https://github.com/Katello/katello.git/commit/4d2503ad80f5067ef0f49f439514d4863b98cf9f))
 * Stop using #hosts with KTEnvironments ([#35863](https://projects.theforeman.org/issues/35863), [fa2e5488](https://github.com/Katello/katello.git/commit/fa2e5488fec42e4d0bacaee6c86643e4efca7422))
 * RABL templates shouldn't rely on single_content_view being non-nil ([#35857](https://projects.theforeman.org/issues/35857), [2e03fef9](https://github.com/Katello/katello.git/commit/2e03fef93e18b9212a35c94669680ab4f2662bd3))
 * Improve empty state of repo sets with Limit to environment  ([#35232](https://projects.theforeman.org/issues/35232), [a4e03e0a](https://github.com/Katello/katello.git/commit/a4e03e0a80aec78db8fb815a3e7ed2076637b5c7))
