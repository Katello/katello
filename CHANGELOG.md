# 3.16.0 Tasty Taiyaki (2020-07-01)

## Features

### Subscriptions
 * Improve experience when manifest identity certs have expired ([#30129](https://projects.theforeman.org/issues/30129), [70ae87c0](https://github.com/Katello/katello.git/commit/70ae87c01845eae3b9ac1a502d66958d92f7c99b))
 * add macro to allow host_subscription_facet(host)&.registered_at from a custom report while safe mode is enabled ([#29743](https://projects.theforeman.org/issues/29743), [1621c4f1](https://github.com/Katello/katello.git/commit/1621c4f1c54253c58d5a27a88df512bbbb42d88f))
 * Add expiring_in_days method to Pool ([#29322](https://projects.theforeman.org/issues/29322), [bb2a20c9](https://github.com/Katello/katello.git/commit/bb2a20c914904812c5fb89f08d62bad290246770))

### Hammer
 * Add ability to list traces by host with hammer ([#29884](https://projects.theforeman.org/issues/29884), [ddfa6c1b](https://github.com/Katello/hammer-cli-katello.git/commit/ddfa6c1b64188c66f292b42e66a3ed035b16d5d3))
 * Add candlepin_events and katello_events to `hammer ping` output ([#29536](https://projects.theforeman.org/issues/29536), [90426329](https://github.com/Katello/hammer-cli-katello.git/commit/90426329fefc4169f9ac3a2012312cad4ea82f9d))

### Hosts
 * Add new macro to report consumption of Red Hat Subscriptions only ([#29790](https://projects.theforeman.org/issues/29790), [5f6eb93a](https://github.com/Katello/katello.git/commit/5f6eb93ae21e4acd259b6638ef97ffe0996cb548))
 * Tracer: warn the user if they have done a select all and it includes the restart|reboot service ([#29730](https://projects.theforeman.org/issues/29730), [999f0700](https://github.com/Katello/katello.git/commit/999f0700220687c1741f994811850e980b660587))
 * Enable installation of Tracer from the UI ([#29692](https://projects.theforeman.org/issues/29692), [16ddcbad](https://github.com/Katello/katello.git/commit/16ddcbadfd6f0ff05b1c927fd7b72ab4b26ac678))

### Tooling
 * upgrade to pulp 3.3 ([#29662](https://projects.theforeman.org/issues/29662), [4675b97f](https://github.com/Katello/katello.git/commit/4675b97fa9305c142a32ffcca422d50cb1b81f9b), [23dd6ccb](https://github.com/Katello/katello.git/commit/23dd6ccbd7cc8fef8e2db8afb84ada0d3ab2ab1f))
 * [RFE] - Bulk Tracer Remediation ([#29516](https://projects.theforeman.org/issues/29516), [93fab731](https://github.com/Katello/katello.git/commit/93fab731a53f9813a1b8d06fc35bfcf049f7770a))
 * Use zypper instead of yum to get list of repositories ([#29418](https://projects.theforeman.org/issues/29418), [8fc29a92](https://github.com/Katello/katello-host-tools.git/commit/8fc29a92c42a6dbc90c90025f5fd1f0d098fc55b))
 * Add message to tracer tab in UI saying how to enable ([#29405](https://projects.theforeman.org/issues/29405), [3f772fca](https://github.com/Katello/katello.git/commit/3f772fca8aabbf561a92b46219af6a21ecd09d75))
 * Consume Candlepin events via STOMP ([#29000](https://projects.theforeman.org/issues/29000), [a69551ea](https://github.com/Katello/katello.git/commit/a69551ea009af21fda779b42c72acd90ca1d4627))

### Repositories
 * SSL Authentication Guard across all types ([#29442](https://projects.theforeman.org/issues/29442), [3e145c13](https://github.com/Katello/katello.git/commit/3e145c138ad013946828a8ec13f3f252d4c56a9f))
 * Validation Sync for debian-repositories ([#27461](https://projects.theforeman.org/issues/27461), [d4c9cdaf](https://github.com/Katello/katello.git/commit/d4c9cdaf070f8648b92dbb93864d6f5ee03f2f2a))

### Errata Management
 * Improvement for the data populated in "CVEs" field for "Applicable Errata" report template  is required ([#29355](https://projects.theforeman.org/issues/29355), [6aca5045](https://github.com/Katello/katello.git/commit/6aca5045fb408e41d79b5e768ff1f0cda736d9cc))

### Content Views
 * Create redux content view API actions and reducers ([#29319](https://projects.theforeman.org/issues/29319))

### Web UI
 * Create empty experimental labs page for content views ([#29315](https://projects.theforeman.org/issues/29315), [589c371e](https://github.com/Katello/katello.git/commit/589c371e17ba7fb07a5ac0d2739c8678b78379da))
 * Create Content View table   ([#29298](https://projects.theforeman.org/issues/29298), [44f71201](https://github.com/Katello/katello.git/commit/44f712016f8c6c873b7daec4f158dc2a0bd9b48a))

### API
 * Provide informative message when using the auto-attach API while in Simple Content Access ([#29149](https://projects.theforeman.org/issues/29149), [c073f485](https://github.com/Katello/katello.git/commit/c073f4854724809fc74ddae0d9aa2bfafba4d812))

### Notifications
 * Add link to Entitlements Expiring Soon report to the "Subscriptions expiring soon" email notification ([#28971](https://projects.theforeman.org/issues/28971), [717285d2](https://github.com/Katello/katello.git/commit/717285d2b99dde8afc14907888b84637bbc5ac7d))
 * Add ability to customize email notifications for "Subscriptions expiring soon" ([#28970](https://projects.theforeman.org/issues/28970), [d414726b](https://github.com/Katello/katello.git/commit/d414726b6843ea4ab06d3556d9ba47b42838a9d7))
 * Add "Subscriptions expiring soon" email to Email Preferences ([#28969](https://projects.theforeman.org/issues/28969), [6e8e1802](https://github.com/Katello/katello.git/commit/6e8e18024279010fd4293bab8d14c5d877262e7a))

### Other
 * RFE: more granular support for RedHat Enterprise Linux ([#29366](https://projects.theforeman.org/issues/29366), [9c9640d1](https://github.com/Katello/katello.git/commit/9c9640d10ce2142ea369190f1c0a2466215a4675))

## Bug Fixes

### Tests
 * react tests - eslint is failing ([#30241](https://projects.theforeman.org/issues/30241), [4e8ef6c4](https://github.com/Katello/katello.git/commit/4e8ef6c41bfa1b75232acce5ebe5f04d99dc4b72))
 * Urls to https://repos.fedorapeople.org/repos/pulp/pulp/fixtures/ are deprecated ([#30227](https://projects.theforeman.org/issues/30227), [14d3e539](https://github.com/Katello/katello.git/commit/14d3e539b591786acf72a9a114a1df15b613b484))
 * React tests - timeout on some tests for nock (http mocking lib) wrapper ([#29987](https://projects.theforeman.org/issues/29987), [99791b65](https://github.com/Katello/katello.git/commit/99791b65a47437db6de16d03932af04dd83ce8e4))
 * Fix React test issues ([#29717](https://projects.theforeman.org/issues/29717), [68219a01](https://github.com/Katello/katello.git/commit/68219a01ef036fe338b8ef457e82df30d8d82e1a))
 * Intermittent ContentViewComponent test ([#29657](https://projects.theforeman.org/issues/29657), [1033fb02](https://github.com/Katello/katello.git/commit/1033fb02ab5f64b3d7135a2054d3e906aa99db24))
 * Allow use of foremanReact from foreman in React tests ([#29637](https://projects.theforeman.org/issues/29637), [cb8ed4df](https://github.com/Katello/katello.git/commit/cb8ed4dfe684c1ae76023137513614632874029f))
 * Katello Applicability tests are failing due to jenkins test DB issues ([#29618](https://projects.theforeman.org/issues/29618), [d9dc5fe0](https://github.com/Katello/katello.git/commit/d9dc5fe04ae5fb9688bcd6759a37fc276fa803c5))
 * Travis CI keeps failing on "eslint: not found" ([#29576](https://projects.theforeman.org/issues/29576), [9183a8e9](https://github.com/Katello/katello.git/commit/9183a8e9de29fcc9582aaa6a530d795f92a63e65))
 * Transient test failures with org labels ([#29519](https://projects.theforeman.org/issues/29519), [34b931a6](https://github.com/Katello/katello.git/commit/34b931a68266f9df550607ba19cc3662a767c71e))
 * fix intermittent failing tests   ActivationKey and ContentView Copy ([#29411](https://projects.theforeman.org/issues/29411), [8dd68556](https://github.com/Katello/katello.git/commit/8dd6855640f679f0d806aea89b8678ee7e101d59), [364d11c9](https://github.com/Katello/katello.git/commit/364d11c90665f92506bba73c62ead6b5b2b3950c))
 * Address cops for rubocop-minitest ([#29395](https://projects.theforeman.org/issues/29395), [3fe0945f](https://github.com/Katello/katello.git/commit/3fe0945f46329586a9dfcbed314434afeb5e3b20))
 * angular-ui tests broke due to patternfly update ([#29381](https://projects.theforeman.org/issues/29381), [bc651a30](https://github.com/Katello/katello.git/commit/bc651a3080c6c9cbfdb5d3f9e1a54d43b7be386d))
 * Delete all http proxies in test setup ([#29142](https://projects.theforeman.org/issues/29142), [6ed753d6](https://github.com/Katello/katello.git/commit/6ed753d6d4e61111649d6291f466fccf759db15f))

### Sync Plans
 * Arrow position is on left rather in the middle under "Start Time" ([#30220](https://projects.theforeman.org/issues/30220), [8d1adbc3](https://github.com/Katello/katello.git/commit/8d1adbc3e462aa8a397187e6a289402009170416))
 * Changing the organization in UI shows sync plan created in another organization ([#29013](https://projects.theforeman.org/issues/29013), [ae2d150c](https://github.com/Katello/katello.git/commit/ae2d150c268c8c9807a06d28a1fae18c6e0373d6))

### Errata Management
 * indexing a yum repo with pulp3 fails to calculate nvra at first indexing ([#30118](https://projects.theforeman.org/issues/30118), [7cef4298](https://github.com/Katello/katello.git/commit/7cef42989230033c4cb6b0ace5b04d0a55b40af3))
 * Katello Applicability needs to calculate applicable module streams ([#29604](https://projects.theforeman.org/issues/29604), [ed09874e](https://github.com/Katello/katello.git/commit/ed09874eaa66489728ffa23a5956a65af8b42c91))
 * Katello Applicability needs to process more than one host per task ([#29554](https://projects.theforeman.org/issues/29554), [fa452587](https://github.com/Katello/katello.git/commit/fa452587088d40eda01041a31ddaaac650090b1e))
 * Skip planning of errata installation when the list applicable errata for a host is empty ([#29368](https://projects.theforeman.org/issues/29368), [d3594739](https://github.com/Katello/katello.git/commit/d35947391c2eeaff9f28231c8d349cb1d12023d9))
 * Installing all Errata of a host doesn't work ([#29330](https://projects.theforeman.org/issues/29330), [6a8d63b9](https://github.com/Katello/katello.git/commit/6a8d63b972dbbadfe1974690273d33ebc9e35a18), [aaf599e7](https://github.com/Katello/katello.git/commit/aaf599e75db51bcb7f3b21e09de4bfaff12c49b6), [c963f3cd](https://github.com/Katello/katello.git/commit/c963f3cdbac5f012a214c225e3b3706cbd3d64a5))
 * Add custom evr type column to katello_rpms and katello_installed_packages ([#29145](https://projects.theforeman.org/issues/29145), [413f9800](https://github.com/Katello/katello.git/commit/413f9800083d5497bd700c8f91577bd28b787d1e))
 * Applied Errata report no longer works when last reboot is included ([#29042](https://projects.theforeman.org/issues/29042), [b528f36e](https://github.com/Katello/katello.git/commit/b528f36ea754985d3084c2ccc5452c2db71891d4))

### Repositories
 * Pulp 2 repo binding still occurs when using Pulp 3 ([#30114](https://projects.theforeman.org/issues/30114), [55127321](https://github.com/Katello/katello.git/commit/551273219be5f36bf84d550e6121831e7c213139))
 * RootRepository password length too short ([#30064](https://projects.theforeman.org/issues/30064), [8c51d7b4](https://github.com/Katello/katello.git/commit/8c51d7b477c95d6c22745a469d711fb17d3cfa36))
 * Root repository upstream password  saved in clear text ([#29931](https://projects.theforeman.org/issues/29931), [a9abccc2](https://github.com/Katello/katello.git/commit/a9abccc2c10f5f2c1194d564834d131d57b28401))
 * Support 'skip' on rpm syncing, to enable skipping srpms ([#29753](https://projects.theforeman.org/issues/29753), [eedd7d02](https://github.com/Katello/katello.git/commit/eedd7d026deb88b0be5a0a61adb9b4c899853df2))
 * katello installed without pulp3 fails when deleting a content view or org ([#29644](https://projects.theforeman.org/issues/29644), [a7d9d4fe](https://github.com/Katello/katello.git/commit/a7d9d4fe3aac2055850b9eb329410ff3def22a08))
 * hammer does not support description for custom repositories ([#29555](https://projects.theforeman.org/issues/29555), [7589f87d](https://github.com/Katello/katello.git/commit/7589f87d786d8ed1086e96b94a8e0a254674dfb3))
 * Links to an errata list of a repository lack repositoryId in URI and points to generic "errata" page instead ([#29398](https://projects.theforeman.org/issues/29398), [d6cb1099](https://github.com/Katello/katello.git/commit/d6cb109993750ee235c688cb5fa37fbb8f4e6889))
 * [Pulpcore 3.2] - Use RpmRepositorySyncUrl for yum repositories ([#29340](https://projects.theforeman.org/issues/29340))
 * SystemStackError (stack level too deep) when syncing a repo with many content units ([#29321](https://projects.theforeman.org/issues/29321), [7ff28c13](https://github.com/Katello/katello.git/commit/7ff28c134d75f481acbc1687a15e75c6a9158766))
 * file repo deletion is slow ([#29267](https://projects.theforeman.org/issues/29267), [155d7951](https://github.com/Katello/katello.git/commit/155d7951cafb18fdad607f7771b2e6f4f1f73032))
 * RepositorySyncUrl is now qualified by plugin name ex: RpmRepositorySyncUrl ([#29266](https://projects.theforeman.org/issues/29266), [5f268c0d](https://github.com/Katello/katello.git/commit/5f268c0d330e43f972e11304a440801dd6e9f3b5))
 * ensure that pulp3 object deletions ignore 404s ([#29228](https://projects.theforeman.org/issues/29228), [41436e78](https://github.com/Katello/katello.git/commit/41436e78897a33f3c193534c36b656e5a525ddd8))
 * Deprecate katello:reimport task ([#29209](https://projects.theforeman.org/issues/29209), [e7e7cd98](https://github.com/Katello/katello.git/commit/e7e7cd98f57ae2746d9b1b91f0bd08d81e42f8b8))
 * deprecate background download_policy in apipie docs ([#29134](https://projects.theforeman.org/issues/29134), [342724bd](https://github.com/Katello/katello.git/commit/342724bd8ae2ca8a93f93f0d37c139404da555fb))
 * If katello applicability is configured, upon update of enabled repositories, a host's applicability should be recalculated ([#29098](https://projects.theforeman.org/issues/29098), [413f9800](https://github.com/Katello/katello.git/commit/413f9800083d5497bd700c8f91577bd28b787d1e))
 * Set architecture attribute for debian repo ([#29029](https://projects.theforeman.org/issues/29029), [e779210b](https://github.com/Katello/katello.git/commit/e779210b7d5d214e34fb38f4d1f8ffd22533a6ec))
 * Add errata pulp3_href to katello_repository_errata and index ([#28913](https://projects.theforeman.org/issues/28913), [51b89bea](https://github.com/Katello/katello.git/commit/51b89beadb7e8e8be068eefbfa1afc4b4b2ad2fa))
 * Filter Pulp 3 SRPMs by arch != "src" once Pulp 3 supports it. ([#28536](https://projects.theforeman.org/issues/28536), [c7b2fc51](https://github.com/Katello/katello.git/commit/c7b2fc511a26b7ffca4fbbc398fad454f7cc66ce))
 * GET /katello/api/srpms/compare always fails with error: Missing template katello/api/v2/common/compare ([#27546](https://projects.theforeman.org/issues/27546), [10192e4a](https://github.com/Katello/katello.git/commit/10192e4adce3b69a9181b759cfa08adf6e019006))

### Content Views
 * Content Hosts has Access to Content View from Different Organization ([#30112](https://projects.theforeman.org/issues/30112), [70ebdbbf](https://github.com/Katello/katello.git/commit/70ebdbbf7a9394b692d19e626804f3c6684e9902))
 * Content view version details can be viewed by an organization that the content view does not belong to ([#30092](https://projects.theforeman.org/issues/30092), [fc4683b7](https://github.com/Katello/katello.git/commit/fc4683b70693a2998f1b565c8f2c5156ab24044f))
 * Cannot enable dep solving or auto publish on content views: `Unpermitted parameters: :auto_publish, :solve_dependencies, :label, :default, :created_at, :updated_at, :composite, :next_version` ([#29847](https://projects.theforeman.org/issues/29847), [dad98b5f](https://github.com/Katello/katello.git/commit/dad98b5fbaa9c9e825cbb33df4c0f937f30b3a0b))
 * Skip puppet env import on cv publish/promote if smart proxy feature is not present ([#29448](https://projects.theforeman.org/issues/29448), [80bd479e](https://github.com/Katello/katello.git/commit/80bd479ee6b997610e6f511096c8d9e1c6c0e6c8))
 * Publishing large content view for 2nd time fails with PostgreSQL invalid message format ([#29335](https://projects.theforeman.org/issues/29335), [125d41ad](https://github.com/Katello/katello.git/commit/125d41add601f472d03f5f39f32c674b25af86f1))
 * Publish a yum repository in a content view with pulp 3 with filters ([#29323](https://projects.theforeman.org/issues/29323), [c7735525](https://github.com/Katello/katello.git/commit/c77355253d1a7eafbb61caa9c7079ae27630a808))
 * drpms not getting copied over cv publish ([#29104](https://projects.theforeman.org/issues/29104), [bc0651c5](https://github.com/Katello/katello.git/commit/bc0651c586c73da246ac259d8e878371e9dd1cd1))

### Subscriptions
 * Cleanup data more efficiently when importing backend objects ([#30101](https://projects.theforeman.org/issues/30101), [654fa774](https://github.com/Katello/katello.git/commit/654fa7743b1186e526f549c77dabd623546c0028))
 * Unable to re-import subscriptions in large environment (60k+ content hosts) ([#29948](https://projects.theforeman.org/issues/29948), [bb672414](https://github.com/Katello/katello.git/commit/bb672414d89e51eee88453ea73b91d1250594343))
 * Manifest import task keeps on executing, causing duplicate notifications ([#29942](https://projects.theforeman.org/issues/29942), [1ae0488b](https://github.com/Katello/katello.git/commit/1ae0488b5b66b8165169a9a7ea8424ee9e29478b))
 * Error in production log from Candlepin events handler ([#29694](https://projects.theforeman.org/issues/29694), [b226cf98](https://github.com/Katello/katello.git/commit/b226cf98a8e16c338cda6d4117d690029d323657))
 * Manifest import and delete calls Actions::Pulp::Repository::Refresh for non-Library repositories ([#29611](https://projects.theforeman.org/issues/29611), [e801fb0f](https://github.com/Katello/katello.git/commit/e801fb0f70bf25e184b89c937c5df849e120fb71))
 * Load distributor version from a constant ([#29527](https://projects.theforeman.org/issues/29527), [acd0617e](https://github.com/Katello/katello.git/commit/acd0617ea5b7188ce9977c3bd147904a1c0e6708))
 * HTTP error when deploying the virt-who configure plugin ([#29521](https://projects.theforeman.org/issues/29521), [5a8860a0](https://github.com/Katello/katello.git/commit/5a8860a0952db6f8f0b446b9d221cbc73edf597d))
 * Non-admin user with view_subscriptions perms cannot view subscriptions ([#29376](https://projects.theforeman.org/issues/29376), [de6fd725](https://github.com/Katello/katello.git/commit/de6fd72533c232d9e493ed9affcb974fcd3f89b9))
 * send notification if manifest is no longer valid ([#29367](https://projects.theforeman.org/issues/29367), [3d86aee1](https://github.com/Katello/katello.git/commit/3d86aee17402a34e1f7748b13cce40f7c31b1a15))
 * Ignore missing candlepin content on product delete ([#29316](https://projects.theforeman.org/issues/29316), [846afb00](https://github.com/Katello/katello.git/commit/846afb0063834925b4bf2f4db0c6ddb39aa78aec))
 * Remove upstream idCert from organization details API ([#29146](https://projects.theforeman.org/issues/29146), [79366cce](https://github.com/Katello/katello.git/commit/79366cce0bd0e7a986b47ecb097819a071b9db50))

### Activation Key
 * Product name link is not working on the activation keys "Repository Sets" tab. ([#30022](https://projects.theforeman.org/issues/30022), [2d78723a](https://github.com/Katello/katello.git/commit/2d78723add7e26b85b8936932dbd61ce9caac755))
 * Disallow commas in activation key names ([#29202](https://projects.theforeman.org/issues/29202), [58d2c768](https://github.com/Katello/katello.git/commit/58d2c768358a0b3000befe8dcf44b5792a36e531))

### Tooling
 * Pulpcore 3.4 application changes and gem bumps ([#30021](https://projects.theforeman.org/issues/30021), [0b6d2e77](https://github.com/Katello/katello.git/commit/0b6d2e7732ee586820ab093eb0f81fddfc9c054c), [6db2479f](https://github.com/Katello/katello.git/commit/6db2479fccedb3af6c72d4a2f7d046e7584af6eb))
 * Rely on Tracer to find affected packages for DNF ([#29824](https://projects.theforeman.org/issues/29824), [83c106dd](https://github.com/Katello/katello-host-tools.git/commit/83c106dd205ca4d35138d455e534407c62a3e045))
 * detect pull requests with only one commit ([#29674](https://projects.theforeman.org/issues/29674), [28a3ad01](https://github.com/Katello/katello.git/commit/28a3ad01c06301ca37ca4ab8c49124d6e1da4282))
 * resolve i18n rails 6 initalizer issue ([#29609](https://projects.theforeman.org/issues/29609), [d0dad1ea](https://github.com/Katello/katello.git/commit/d0dad1ea9019523c2f34d24ecfc79b29c1d212ca))
 * adjust gemspec to not reference pre-release builds of pulp client gems ([#29600](https://projects.theforeman.org/issues/29600), [6de36002](https://github.com/Katello/katello.git/commit/6de36002fc8b8f4f2048bdd0f2fadf3c9d394d14))
 * katello-host-tools-tracer stats paths abusively, leading to a hang or slowness of yum command ([#29436](https://projects.theforeman.org/issues/29436))
 * Tracer shows the machines needs rebooting even after reboot if kernel-debug is installed ([#29435](https://projects.theforeman.org/issues/29435))
 * Pulpcore3.2 application changes and gem bumps ([#29372](https://projects.theforeman.org/issues/29372), [8aaf0f04](https://github.com/Katello/katello.git/commit/8aaf0f04815ad15c57bba73d51b2249220fe72bc))
 * synchronize katello-host-tools and k-h-t-tracer versions ([#29313](https://projects.theforeman.org/issues/29313))
 * Fix Katello:reset task ([#29169](https://projects.theforeman.org/issues/29169), [1a2ca096](https://github.com/Katello/katello.git/commit/1a2ca096f8423a99d1ea84519d047c33733ae999))

### Web UI
 * Rename 'Enable Traces on this host' to 'Enable Traces' ([#29945](https://projects.theforeman.org/issues/29945), [ca7e1b25](https://github.com/Katello/katello.git/commit/ca7e1b2571a66a16859879e7e39e61f21dcdef85))
 * Mime::Type::InvalidMimeType from bastion requests ([#29646](https://projects.theforeman.org/issues/29646), [5514ced2](https://github.com/Katello/katello.git/commit/5514ced28d85e6ba66670cd92385c79dda54d241))
 * react-helmet should be removed as a dependency  ([#29428](https://projects.theforeman.org/issues/29428), [9ff05f5f](https://github.com/Katello/katello.git/commit/9ff05f5fd867e27ed83d2759b4d613588a88291a))
 * Update to use foreman's newer meta npm packages ([#29358](https://projects.theforeman.org/issues/29358), [d76be79b](https://github.com/Katello/katello.git/commit/d76be79bd8e68a75d88857dbed693e87f00709da))
 * Upgrade eslint from 0.14.1 to 6.7.2  ([#29168](https://projects.theforeman.org/issues/29168), [52f530ef](https://github.com/Katello/katello.git/commit/52f530efab89d8a71bb79f9a440b125a0d6384a6))
 * Update angular deps to fix security vulnerabilities ([#28998](https://projects.theforeman.org/issues/28998), [23a4c690](https://github.com/Katello/katello.git/commit/23a4c69022064a11d106b0d7de95fae70eff7e22), [57f4117a](https://github.com/Katello/katello.git/commit/57f4117a865d3c873854226b748f583376eae8d6), [7b55f254](https://github.com/Katello/katello.git/commit/7b55f254ed4829ed953dc1d2804a8f11610b3d49), [57f110b0](https://github.com/Katello/katello.git/commit/57f110b00644ef2c80057b1719abf77945c45c2b))

### Hosts
 * Ignore uploaded Traces that have no helper ([#29823](https://projects.theforeman.org/issues/29823), [fceaba29](https://github.com/Katello/katello.git/commit/fceaba29ad48b9d0955df356cd057afbb661853d))
 * Show Traces status in hosts API ([#29721](https://projects.theforeman.org/issues/29721), [c919619a](https://github.com/Katello/katello.git/commit/c919619ae1cdd6fb939d4300669d039e2ab73833))

### Client/Agent
 * katello-agent generating invalid package patterns ([#29691](https://projects.theforeman.org/issues/29691), [6710c1eb](https://github.com/Katello/katello-host-tools.git/commit/6710c1eb1581b4d83757cd49c16385d911beedca))

### Content Credentials
 * Certificate count wrong ([#29634](https://projects.theforeman.org/issues/29634), [53335a0f](https://github.com/Katello/katello.git/commit/53335a0f36b6c3723f5dec49d5c1b9f5fe306bfa))

### SElinux
 * Allow Passenger to connect to Artemis ([#29603](https://projects.theforeman.org/issues/29603))

### Modularity
 * Katello Applicability needs to take modularity into account during its calculations ([#29553](https://projects.theforeman.org/issues/29553), [3a908778](https://github.com/Katello/katello.git/commit/3a908778ad2410a9b9d191a8417184eb359ea6ed))
 * Add module stream <-> rpm mapping ([#29480](https://projects.theforeman.org/issues/29480), [25c4fb8a](https://github.com/Katello/katello.git/commit/25c4fb8ad501a26e8f47ec5a516cb75b57816616))
 * Modulemd Defaults not copied on incremental update ([#28953](https://projects.theforeman.org/issues/28953), [d6cb3307](https://github.com/Katello/katello.git/commit/d6cb33076d4606676086c0159282aaef5022fda9))

### API
 * Delays when many clients upload tracer data simultaneously ([#29397](https://projects.theforeman.org/issues/29397), [709fe41f](https://github.com/Katello/katello.git/commit/709fe41f8dc000014fca037bf3b1d0a92402ae6c))
 * missing @taxonomy instance variable when creating organization from API ([#29035](https://projects.theforeman.org/issues/29035), [29f949ec](https://github.com/Katello/katello.git/commit/29f949ec70a3ea9b2655552dfbdced6948112235))
 * API doc for /api/v2/organizations does not mention locations in create/update ([#28907](https://projects.theforeman.org/issues/28907), [947222ae](https://github.com/Katello/katello.git/commit/947222ae10edaccc1ef28629076d7575ef9d37b2))

### Foreman Proxy Content
 * Pulpcore capsule sync for yum repositories doesn't reflect smart proxy download policy ([#29320](https://projects.theforeman.org/issues/29320), [8e5c047e](https://github.com/Katello/katello.git/commit/8e5c047ed5227a1c58fe83146ae1c9f21ca4e71a))
 * Support syncing a pulp3 capsule with yum content content ([#28951](https://projects.theforeman.org/issues/28951), [6c1d5d72](https://github.com/Katello/katello.git/commit/6c1d5d72e7ed6e8305d5dfafd64822fcd6b57d5d))

### Hammer
 * content-view version promote uses deprecated `environment_id` parameter ([#29310](https://projects.theforeman.org/issues/29310), [603cd84f](https://github.com/Katello/hammer-cli-katello.git/commit/603cd84fef10113eef25d25847a4ad6b3ce8b6a3))
 * search_options creators do not include usergroups ([#29033](https://projects.theforeman.org/issues/29033), [f941e089](https://github.com/Katello/hammer-cli-katello.git/commit/f941e089a474ec38c696bbdee980b35accb2e7d1))
 * hammer repository info shows blank sync status if the repository sync is in warning/error state. ([#28949](https://projects.theforeman.org/issues/28949), [e5d46a7a](https://github.com/Katello/hammer-cli-katello.git/commit/e5d46a7a11480afca0540feaa5bce75ec4882c90))

### Content Uploads
 * Refactor content uploads for pulpcore non-File type plugins ([#29280](https://projects.theforeman.org/issues/29280), [c22857d6](https://github.com/Katello/katello.git/commit/c22857d6f4719cc57fca9cf76d94dd487baf7fda))
 * Upload srpm content  to pulp3 ([#28952](https://projects.theforeman.org/issues/28952), [6077f1a7](https://github.com/Katello/katello.git/commit/6077f1a734c1f20a0b218ed6a5c7622d85954ea5))

### Upgrades
 * remove orphaned pulp3 repos and distributions from the master pulp server after migration ([#29079](https://projects.theforeman.org/issues/29079), [01bce9d6](https://github.com/Katello/katello.git/commit/01bce9d69919ec9e99fbcca43f74f1054100e0f9))

### Lifecycle Environments
 * Create Lifecycle button should be deactivated if it is not yet initialized ([#28958](https://projects.theforeman.org/issues/28958), [d2fb9a7c](https://github.com/Katello/katello.git/commit/d2fb9a7c98167befdd98729446f1b411011c0321))

### Docker
 * Identical Docker tags aren't grouped by repository ([#28795](https://projects.theforeman.org/issues/28795))

### Notifications
 * Toast notifications not working when permissions are missing ([#27970](https://projects.theforeman.org/issues/27970), [01635361](https://github.com/Katello/katello.git/commit/01635361297154a38c9d07083dc8e6244254f375))

### Security
 * Private keys found in debug log ([#27501](https://projects.theforeman.org/issues/27501), [458d7fb1](https://github.com/Katello/katello.git/commit/458d7fb1a9df1f414c7c24c65dd589696cb59992), [f6bf200e](https://github.com/Katello/katello.git/commit/f6bf200e551e5b4e4c744e6bd145c24ab060c858), [ed15d82e](https://github.com/Katello/katello.git/commit/ed15d82ea51df5463e0c4f6bba3fb15fdd803845), [014844e2](https://github.com/Katello/katello.git/commit/014844e2300297864b127502d33e2542b9c16e4b), [1583a45d](https://github.com/Katello/katello.git/commit/1583a45d762ee041e1bb3782f84d296734695685), [2cc7e2dd](https://github.com/Katello/katello.git/commit/2cc7e2dd54e6dfdf1bcf7c84ed891857293cef78), [8d9738db](https://github.com/Katello/katello.git/commit/8d9738db82727674ce061666e727c5dab02f19f2), [ffd42df9](https://github.com/Katello/katello.git/commit/ffd42df9a5b626e7a8c6daa3ff93e4b8aab25d98), [ffa48e0b](https://github.com/Katello/katello.git/commit/ffa48e0ba9ef068d933c05845ae816fb42c86d7b), [2d85910b](https://github.com/Katello/katello.git/commit/2d85910bc6e4fcffd300154cd7664a71167aa326))

### Installer
 * tomcat listens on 0.0.0.0 by default ([#21508](https://projects.theforeman.org/issues/21508))

### Other
 * Database migration fails on SQLite ([#29549](https://projects.theforeman.org/issues/29549), [fc1dbc74](https://github.com/Katello/katello.git/commit/fc1dbc745a1b7df2d657b70bf2a58b8de2235341))
