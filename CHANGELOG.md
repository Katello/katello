# 4.0.0 (2021-02-17)

## Features

### SElinux
 * Allow connections to qpid from rails ([#31784](https://projects.theforeman.org/issues/31784))

### Client/Agent
 * Send and receive katello-agent messages without Pulp 2 ([#31692](https://projects.theforeman.org/issues/31692), [88246ead](https://github.com/Katello/katello.git/commit/88246ead3ff997966f718eeebe91dffdfa6d4295))

### Container
 * support login token caching on the container gateway ([#31640](https://projects.theforeman.org/issues/31640))
 * Smart Proxy Container Gateway should support all search methods ([#31566](https://projects.theforeman.org/issues/31566))

### Tooling
 * Add timer to Katello::Logging ([#31550](https://projects.theforeman.org/issues/31550), [d1130b74](https://github.com/Katello/katello.git/commit/d1130b74bda4f6aec87e2a8ac650af0e6279d1f7))

### Errata Management
 * Provide erratum.synopsis option to Applicable errata Reporting template ([#31530](https://projects.theforeman.org/issues/31530), [9dad0417](https://github.com/Katello/katello.git/commit/9dad0417e184c1351251d7df54d40335f666ba71))

### Hosts
 * b'Registration fails when duplicate activation key names given to --activationkey option' ([#31498](https://projects.theforeman.org/issues/31498), [7f1e3952](https://github.com/Katello/katello.git/commit/7f1e395269257e54b1acf31a13881a915900f3e8))
 * Add option to select Operating System in Register Content Host  ([#31442](https://projects.theforeman.org/issues/31442), [b4b61240](https://github.com/Katello/katello.git/commit/b4b612400863e7385f55b7575f36dd1343058261))
 * Entitlements report should list number of Red Hat subscriptions consumed by each host ([#29838](https://projects.theforeman.org/issues/29838), [652b822d](https://github.com/Katello/katello.git/commit/652b822d6f83c6c9bb90c599e09cff2d04ee7644))

### Tests
 * Testing infrastructure needs to be setup for the container gateway. ([#31484](https://projects.theforeman.org/issues/31484))

### Content Views
 * New Content View Page - Add copy content view capability ([#31446](https://projects.theforeman.org/issues/31446), [7dc7d839](https://github.com/Katello/katello.git/commit/7dc7d8397ae7f243985f8a5019ce10b7081da095))
 * New Content View Page - Create content view modal ([#31343](https://projects.theforeman.org/issues/31343), [74cbb1d3](https://github.com/Katello/katello.git/commit/74cbb1d3bcfae8ad0d41550a009a852d1dfa01ff))
 * Create Content View Table Header ([#29306](https://projects.theforeman.org/issues/29306))

### Foreman Proxy Content
 * Katello should send unauthenticated docker repos to the smart_proxy_container_gateway plugin at proxy sync time ([#31337](https://projects.theforeman.org/issues/31337), [c325db86](https://github.com/Katello/katello.git/commit/c325db86364f352b780c9d4f62835d20ae0c8737))

### Other
 * - Recover space of old container image versions ([#31782](https://projects.theforeman.org/issues/31782), [8480a867](https://github.com/Katello/katello.git/commit/8480a8679396001876e7586331bc0772f06b7ad5))
 * The container gateway's unauthenticated repo cache should update at smart proxy sync time and unauthenticated pulls should be rejected against other repos ([#31485](https://projects.theforeman.org/issues/31485))
 * Add Content View Version to Reporting Engine Template ([#30703](https://projects.theforeman.org/issues/30703), [123fb89f](https://github.com/Katello/katello.git/commit/123fb89f0a5c01edc67eeeb29b828ceb687e9836))

## Bug Fixes

### Tests
 * Intermittent autoloading error in agent/connection_test.rb ([#31877](https://projects.theforeman.org/issues/31877), [2a092cae](https://github.com/Katello/katello.git/commit/2a092caea1bfb0e52597073aa6e9bf8131707774))
 * rubocop `Style/MethodMissingSuper` cop has been removed since it has been superseded by `Lint/MissingSuper` ([#31422](https://projects.theforeman.org/issues/31422), [2da9d839](https://github.com/Katello/katello.git/commit/2da9d83902bb55b57cfd797b694844d89446193d))

### Tooling
 * Remove pulp2 from reset script ([#31865](https://projects.theforeman.org/issues/31865), [43bb25c4](https://github.com/Katello/katello.git/commit/43bb25c49b3a953313dca86f6e4311884b237abb))
 * foreman-rake katello:clean_backend_objects fails with "      "The Dynflow world was not initialized yet. If your plugin uses it, make sure to call Rails.application.dynflow.require! in some initializer"}," ([#31725](https://projects.theforeman.org/issues/31725), [b8c73d76](https://github.com/Katello/katello.git/commit/b8c73d768baed4d00b97cfd43997bb826a1a36a3), [58d14a2a](https://github.com/Katello/katello.git/commit/58d14a2ad729b658aa79c25fb06e224ad8f914c1), [e1bb601c](https://github.com/Katello/katello.git/commit/e1bb601c2a381369f7d25b1c961b574f54515794))
 * Update Pulpcore client bindings to 3.9 ([#31608](https://projects.theforeman.org/issues/31608), [01f28c04](https://github.com/Katello/katello.git/commit/01f28c04c55c3f3c107c381b16c073a27c64736c))
 * foreman-rake reports:daily runs all reports twice ([#31418](https://projects.theforeman.org/issues/31418), [bda54ecf](https://github.com/Katello/katello.git/commit/bda54ecf8a4c1a24df83724dae33421c3cbfa6ce))
 * db seed fails with 'Unknown remote execution feature katello_module_stream_action' ([#31416](https://projects.theforeman.org/issues/31416), [c9693c16](https://github.com/Katello/katello.git/commit/c9693c16e46a1276621a86694023b5892f53eb52))

### Errata Management
 * add 'context' to AvailableModuleStream host modularity profile ([#31842](https://projects.theforeman.org/issues/31842), [2da77433](https://github.com/Katello/katello.git/commit/2da774333f332dbb7ecf854e6e906ca9cf06cf5c))

### Hosts
 * Delete client queue on unregister ([#31828](https://projects.theforeman.org/issues/31828), [fa46c99f](https://github.com/Katello/katello.git/commit/fa46c99f6275cb533fbb9a6dc9f3cb8c67941ecc))
 * The Start Date field is blank for Subscriptions within Content Hosts page in Satellite WebUI ([#31770](https://projects.theforeman.org/issues/31770), [2f8652b3](https://github.com/Katello/katello.git/commit/2f8652b35e597730e91ef66d2892f29a26f43523))
 * Content Hosts page does not show year for registered_at and last_check_in fields. ([#31403](https://projects.theforeman.org/issues/31403), [3c197757](https://github.com/Katello/katello.git/commit/3c1977576820085c89d2ad95d014a40b5565d368))

### Hammer
 * Add a  type column to export histories ([#31788](https://projects.theforeman.org/issues/31788), [b55f1128](https://github.com/Katello/katello.git/commit/b55f11285577e17877e359ef3523d35a0939465b), [7067e4fe](https://github.com/Katello/hammer-cli-katello.git/commit/7067e4fea8e18fbb84c5e5b9831853b41bd0395f))
 * Update content credentials in hammer to show content type and update creation for gpg key controller removal ([#31762](https://projects.theforeman.org/issues/31762), [1e077198](https://github.com/Katello/katello.git/commit/1e077198949dd2eddccd7ed10a0b4e762ad0c23e), [832ac91b](https://github.com/Katello/hammer-cli-katello.git/commit/832ac91b85e3f9f5846e351787345e2d2146c3b9))
 * update the help description of hammer subscription list command for the --fields option to be more explicit ([#29732](https://projects.theforeman.org/issues/29732), [0376bd3c](https://github.com/Katello/hammer-cli-katello.git/commit/0376bd3c8ea6b4e3570484fdbf5c32e16b14dcb2), [416e7f78](https://github.com/Katello/hammer-cli-katello.git/commit/416e7f780acc3a958e8c9e0ea0d4e565766002f3))
 * Repository controller/hammer repository update option '--ignore-global-proxy' is marked deprecated ([#29205](https://projects.theforeman.org/issues/29205))

### Subscriptions
 * pool id in exported csv from subscription page are wrong ([#31774](https://projects.theforeman.org/issues/31774), [be58abf5](https://github.com/Katello/katello.git/commit/be58abf5dfc2d9ba01edfc618728ea464232b1bb))
 * As a user I 'd like new api endpoints for sca ([#31734](https://projects.theforeman.org/issues/31734), [2c7eb3c2](https://github.com/Katello/hammer-cli-katello.git/commit/2c7eb3c2dae606f801c0bd7908d1010a60f7bc93), [300f68b6](https://github.com/Katello/katello.git/commit/300f68b645a00bf35a34df9abe064767a9a12fc3), [c3388b35](https://github.com/Katello/hammer-cli-katello.git/commit/c3388b35701a34ab055c23d03372a5e8a0cd6f7c))
 * Get rid of use_cp  ([#31292](https://projects.theforeman.org/issues/31292), [c76c021d](https://github.com/Katello/katello.git/commit/c76c021da542efaa26cb99051d6ec05ec80356a9))

### Foreman Proxy Content
 * smart proxy sync w/ pulp3 does not properly track distribution creation/update as a task ([#31731](https://projects.theforeman.org/issues/31731), [ee7cfbc1](https://github.com/Katello/katello.git/commit/ee7cfbc132e67b2b820f597e3aa3d254bf05e3cb))
 * syncing a pulp3 only smart proxy fails with '404' ([#31676](https://projects.theforeman.org/issues/31676), [35afcd56](https://github.com/Katello/katello.git/commit/35afcd56b147527049ae409ab518fa9ae8b46cbc))
 * smart proxy details with a pure pulp3 proxy does not show sync widget ([#31465](https://projects.theforeman.org/issues/31465), [494416c7](https://github.com/Katello/katello.git/commit/494416c72c839b0e0698357aa4aff6e85db66d0a))

### Repositories
 * sync management page tries to talk to pulp2 ([#31729](https://projects.theforeman.org/issues/31729), [3f689237](https://github.com/Katello/katello.git/commit/3f689237d2379bcab17340582232823dbbd83462))
 * remove puppet repos and ostree repos on upgrade ([#31682](https://projects.theforeman.org/issues/31682), [56668d54](https://github.com/Katello/katello.git/commit/56668d54bc16b1bf0115918e6baf9990f32fcd98))
 * Update recommended repos for sat/tools from 6.8 to 6.9 ([#31657](https://projects.theforeman.org/issues/31657), [6f5be4a5](https://github.com/Katello/katello.git/commit/6f5be4a5c358948fd56e886bc29dd1a4ec615e7c))
 * Document 'arch' parameter for repositories ([#31615](https://projects.theforeman.org/issues/31615), [717688d7](https://github.com/Katello/katello.git/commit/717688d78da571bcc4bba52ff886f0febd06f209))
 * Get rid of use_pulp ([#31293](https://projects.theforeman.org/issues/31293), [7d61a7f5](https://github.com/Katello/katello.git/commit/7d61a7f52d22d4caf72fa45359092d84d3c9f931))
 * Repository Upstream Authentication can never be removed ([#29592](https://projects.theforeman.org/issues/29592), [e7a0436a](https://github.com/Katello/katello.git/commit/e7a0436ae9498c07d6265c0a82cdf689883f328e))

### Container
 * Container Gateway causes podman to error out when handing out the unauthorized token ([#31721](https://projects.theforeman.org/issues/31721))
 * can't sync quay.io/foreman/busybox-test to a proxy on nightly ([#31401](https://projects.theforeman.org/issues/31401))

### Content Views
 * Command exceeded timeout while Installer executes foreman-rake db:migrate ([#31540](https://projects.theforeman.org/issues/31540), [5a48018f](https://github.com/Katello/katello.git/commit/5a48018fe47074ff5cc24080ce9bc0a83d10196b))
 * New Content View Page - Tasks tab ([#31314](https://projects.theforeman.org/issues/31314), [b6faf29d](https://github.com/Katello/katello.git/commit/b6faf29de6cc6a6f2669476636280f088b20a2c5))
 * New Content View page - create the filter tab's main table ([#31313](https://projects.theforeman.org/issues/31313), [3e3dc6da](https://github.com/Katello/katello.git/commit/3e3dc6dae8c2b0c01e62ab8cf6db935a920a430c))
 * display a better error message when a composite content view has component content view conflicts ([#31308](https://projects.theforeman.org/issues/31308))
 * Incremental update requires Puppet content type to be enabled ([#31214](https://projects.theforeman.org/issues/31214), [759e90f9](https://github.com/Katello/katello.git/commit/759e90f95e5abb1cfc78149b8b38a94fbfce790d))
 * Add deb repositories to new Content View page repositories tab ([#31209](https://projects.theforeman.org/issues/31209), [85ee0b6f](https://github.com/Katello/katello.git/commit/85ee0b6f2292a0eeb465679b338b505e51d692cf))
 * can't publish a CV if the description is longer than 255 chars ([#31105](https://projects.theforeman.org/issues/31105), [84835e6a](https://github.com/Katello/katello.git/commit/84835e6a6aa919f3f75e2741bbfd44ff0ae76caf))
 * User with "viewer" role cannot see rpm names in 'Include RPM' content view filters ([#30837](https://projects.theforeman.org/issues/30837), [b3ec5d42](https://github.com/Katello/katello.git/commit/b3ec5d421be54305bfdc618e4849d4e4ffaa689a))
 * New Content View page - spacing between clear icon and search is too large ([#30421](https://projects.theforeman.org/issues/30421), [3e3dc6da](https://github.com/Katello/katello.git/commit/3e3dc6dae8c2b0c01e62ab8cf6db935a920a430c))

### SElinux
 * Allow tomcat name_connect to katello_candlepin_port_t ([#31499](https://projects.theforeman.org/issues/31499))

### Web UI
 * Update @theforeman/builder to 6.0.0 ([#31344](https://projects.theforeman.org/issues/31344), [2b95031b](https://github.com/Katello/katello.git/commit/2b95031b089fb801001f791320cb0e25e7d19a75))

### API
 * Katello 4.0.0 deprecations ([#30939](https://projects.theforeman.org/issues/30939), [c3ae5c6d](https://github.com/Katello/katello.git/commit/c3ae5c6dddf94d77ef3708f1244cefb5e9c810b6), [4deff8e4](https://github.com/Katello/hammer-cli-katello.git/commit/4deff8e4023c08aa3bc4fb5ea25e661f8453b2cf))

### Upgrades
 * Iron out pulp2 repository deletion options as part of pulp3 migration ([#29124](https://projects.theforeman.org/issues/29124))

### Other
 * UpstreamSubscriptionsController incorrectly indicates a 4.0 deprecation ([#31765](https://projects.theforeman.org/issues/31765), [a7a07cb6](https://github.com/Katello/katello.git/commit/a7a07cb664d2de2cb56889d63c1cfcb3d4d54d41))
 * katello_events and candlepin_events intermittently showing as not started ([#31740](https://projects.theforeman.org/issues/31740), [37c2d873](https://github.com/Katello/katello.git/commit/37c2d873243055c9cbdd37b4b94b1477b5cc9cdd))
 * Javascript error on Products page 'self.table.allSelected is not a function' ([#31496](https://projects.theforeman.org/issues/31496), [6fca2a2c](https://github.com/Katello/katello.git/commit/6fca2a2cb428ef4b5abb3665ee7fdc9732a7e288))
