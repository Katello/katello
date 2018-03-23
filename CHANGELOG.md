# 3.6.0 Imperial IPA (2018-03-23)

## Features 

### Content Views
 * ISO repositories not published to correct path ([#22446](http://projects.theforeman.org/issues/22446), [9c93fadc](http://github.com/katello/katello/commit/9c93fadc85b7fd58e033ba29623393fe9d606d65), [ef10bf44](http://github.com/katello/katello-installer/commit/ef10bf44def31dd8e74a0a9a17808822ba0f096e))
 * Rake task needed to clean up repos published to wrong directory ([#22293](http://projects.theforeman.org/issues/22293), [c3833708](http://github.com/katello/katello/commit/c383370802f9362aafb35233af9ccc026d899d8b))
 * [RFE] Component view versions for composite content views ([#18228](http://projects.theforeman.org/issues/18228), [ab643413](http://github.com/katello/katello/commit/ab6434137082ba219f6acb6974aee1214dcc8e08))

### Repositories
 * Add cp_label into API output ([#22385](http://projects.theforeman.org/issues/22385), [ee0fb7f1](http://github.com/katello/katello/commit/ee0fb7f14a04484afdbe91291d4e45adac114da1))
 * Experimental UI : Red Hat Repositories - add basic page layout ([#21644](http://projects.theforeman.org/issues/21644), [0c386f20](http://github.com/katello/katello/commit/0c386f20de9810f9f545db7af358fe0667a17ed7))
 * As a user, I want to list all repository sets for an organization. ([#19925](http://projects.theforeman.org/issues/19925), [a88bd055](http://github.com/katello/katello/commit/a88bd05558a512392eb1b8a7774b5cf38b0fef21))
 * Add help text to new repository Download Policy ([#19199](http://projects.theforeman.org/issues/19199), [a008356d](http://github.com/katello/katello/commit/a008356d21c206caee9264c30a2b8be4ba4f4460))

### API
 * As an API user, I should be able to retrieve GPG Key content that may not be associated with a Repository. ([#21995](http://projects.theforeman.org/issues/21995), [5382d429](http://github.com/katello/katello/commit/5382d4296f4420bea899d7a518488966c0cc2114))
 * As an API user, I should be able to compare the Errata of a Content View Version to the Errata in Library. ([#21568](http://projects.theforeman.org/issues/21568), [f38cc3f4](http://github.com/katello/katello/commit/f38cc3f4472fa4a82db77befffd5bee7af2f9e03))

### Web UI
 * RH repos: visual improvements ([#21954](http://projects.theforeman.org/issues/21954), [e447a675](http://github.com/katello/katello/commit/e447a675fa9696d67bd6d29ee11a1c2f1125c61f))
 * Add react-storybook ([#21931](http://projects.theforeman.org/issues/21931), [13b438b1](http://github.com/katello/katello/commit/13b438b13726cfdb81e9f130fc289d8b09e5905d))
 * Red Hat Repositories: get API client working ([#21646](http://projects.theforeman.org/issues/21646), [380a5bc6](http://github.com/katello/katello/commit/380a5bc6ff66d3fe6adca59e8bd242323175c9c6))
 * Add katello icons for veritcal navigation ([#21141](http://projects.theforeman.org/issues/21141), [7ef4d0cb](http://github.com/katello/katello/commit/7ef4d0cba21d867581bafdf875e366d874c0cefc))
 * Get react scaffolding in place for katello ([#21009](http://projects.theforeman.org/issues/21009), [fb2433d8](http://github.com/katello/katello/commit/fb2433d8c3916d6c22c4b98db0052fb430b5c094))
 * make the "Type" of a subscription a searchable unit ([#20979](http://projects.theforeman.org/issues/20979), [456b3858](http://github.com/katello/katello/commit/456b38584d44fbd3097087aa1276bb5bf010cdea))
 * Add setting to toggle experimental UI ([#20716](http://projects.theforeman.org/issues/20716), [50c3f55e](http://github.com/katello/katello/commit/50c3f55ed547646bc54b0c16b97d94bd0832e27e))
 * RH Repos: hook up enabled/disabled/both selector to search and multiselect ([#21953](http://projects.theforeman.org/issues/21953), [fa1f9621](http://github.com/katello/katello/commit/fa1f9621e134c9bf4fac2aa48fb7497e6ce724f3))

### Installer
 * Enable import of product content through katello installer ([#21936](http://projects.theforeman.org/issues/21936), [a0374949](http://github.com/katello/katello-installer/commit/a03749491f344458a5b52acadcf21526c66b7c65))
 * Use a different oauth for Pulp & Candlepin ([#20879](http://projects.theforeman.org/issues/20879))
 * ablity to configure Katello post_sync_url setting other than fqdn ([#20857](http://projects.theforeman.org/issues/20857), [451530b0](http://github.com/katello/puppet-katello/commit/451530b0b161d41ab09f10333f3e849c82cda70d))
 * Need additional supported database deployment options for Katello installation: such as External Postgres ([#19667](http://projects.theforeman.org/issues/19667), [51ca4090](http://github.com/katello/puppet-candlepin/commit/51ca40909f7ae82bf06f0571df673397daa56201), [65f55250](http://github.com/katello/katello-installer/commit/65f55250856162ee7fd8b4e29e1ad78074e8c866), [04ebdba2](http://github.com/katello/puppet-katello/commit/04ebdba2f334862cfd463a6396e652873eb3e471))

### Docker
 * content view filter needs to be able to work with docker manifest list ([#21388](http://projects.theforeman.org/issues/21388), [aecabf21](http://github.com/katello/katello/commit/aecabf212b6c340240c05dd798411657c17cf565))
 * Add UI Bindings for the Docker Manifest List ([#21291](http://projects.theforeman.org/issues/21291), [14128f7d](http://github.com/katello/katello/commit/14128f7d6002733c3f2c4ae9c8e60da0bcab2d3f))
 * Add Model Bindings for Docker Manifest List ([#21290](http://projects.theforeman.org/issues/21290), [14128f7d](http://github.com/katello/katello/commit/14128f7d6002733c3f2c4ae9c8e60da0bcab2d3f))

### Roles and Permissions
 * Please provide a Pre-made role for registration-only usage ([#21307](http://projects.theforeman.org/issues/21307), [f70a69f3](http://github.com/katello/katello/commit/f70a69f3c09b9435fb833a7212b46cedf69c0f9b))

### Hammer
 * hostgroup create/update doesn't support --content-source ([#18743](http://projects.theforeman.org/issues/18743), [6fad377a](http://github.com/katello/hammer-cli-katello/commit/6fad377a53f4e3160e20313eca29805d82a4f5cb))
 * Show an option to which capsule the client is registered to through hammer ([#20791](http://projects.theforeman.org/issues/20791))

### Sync Plans
 * [RFE] hammer sync-plan info should show associated products ([#17155](http://projects.theforeman.org/issues/17155), [3ed6cee9](http://github.com/katello/hammer-cli-katello/commit/3ed6cee9c511558c250e713224d0d2e728625b16))

### Subscriptions
 * Upgrade to Candlepin 2.1 ([#20792](http://projects.theforeman.org/issues/20792))

### Hosts
 * set release version of a content host via bulk action ([#20583](http://projects.theforeman.org/issues/20583), [42a3a9c1](http://github.com/katello/katello/commit/42a3a9c17e53752dab573c74fb8c1bbc9a59c72b))

### Candlepin
 * As a user, i would like to restrict a certain repo to one or more arches. ([#5477](http://projects.theforeman.org/issues/5477), [b02526be](http://github.com/katello/katello/commit/b02526bea7026560b2d6d66fac9038cfeb74bab9))

### Other
 * Use patternfly Spinner component ([#21982](http://projects.theforeman.org/issues/21982), [732a8983](http://github.com/katello/katello/commit/732a89831b770db4b7d43964fb2c8cafcfc65350))
 * Cache product content from Candlepin in Katello ([#21680](http://projects.theforeman.org/issues/21680), [946b2990](http://github.com/katello/katello/commit/946b2990c9a054babc9ad563e1b14c4161207b3e))
 * Turn on eslint in the .hound.yml ([#21575](http://projects.theforeman.org/issues/21575), [ddc77314](http://github.com/katello/katello/commit/ddc77314b5a78bd579c662cb2e6dd62eb467c513))
 * Remove pulp oauth support ([#21464](http://projects.theforeman.org/issues/21464), [d6942759](http://github.com/katello/katello/commit/d6942759f4021d92ae628e5050fed948b84a1626), [af1081f2](http://github.com/katello/puppet-katello/commit/af1081f2ab056f2a988b1caac4bbc9a082f81139), [94872522](http://github.com/katello/puppet-foreman_proxy_content/commit/9487252216c19ab1e656ed5cb24195e51f4cfe30), [a724f196](http://github.com/katello/katello-installer/commit/a724f19636871c8540ebe9ca40b0cec8a0820bad), [5cdea23c](http://github.com/katello/katello-installer/commit/5cdea23cb7bcd1d792dc65cd185855aa78d01411))
 * Support Experimental UI Routes (prefixed with `xui`) ([#21277](http://projects.theforeman.org/issues/21277), [4cb1be28](http://github.com/katello/katello/commit/4cb1be28aa04c7fdabac0b82ae956c091dee8e2c))
 * Specify "X-Correlation-ID" header for log correlation when making REST calls to Candlepin ([#20488](http://projects.theforeman.org/issues/20488), [24a58d78](http://github.com/katello/katello/commit/24a58d78b180e7456ec2c7e95466bab883ffb9c9))
 * CSV export on Content Host page ([#19954](http://projects.theforeman.org/issues/19954), [6362c738](http://github.com/katello/katello/commit/6362c738f721131630c8b0a317c4040e39e53b92))
 * Notification for low disk space on Pulp ([#19302](http://projects.theforeman.org/issues/19302), [eb45afa5](http://github.com/katello/katello/commit/eb45afa5d279cc8248e950a270d93ea69451b18a))
 * Notification for subscriptions expiring soon  ([#19314](http://projects.theforeman.org/issues/19314), [390b0967](http://github.com/katello//commit/390b09672a64cf88a84ef7b8411f771ef2ba948c))

## Bug Fixes 

### Tests
 * Rubocop can fail when there is ruby inside node_modules/ ([#22494](http://projects.theforeman.org/issues/22494), [76ecc59f](http://github.com/katello/katello/commit/76ecc59fa39e2c373c797bd6337b387a5c2d3822))
 * Test failure on Rails 5.1 ([#22073](http://projects.theforeman.org/issues/22073), [91b7adcf](http://github.com/katello/katello/commit/91b7adcf2425a3218a2629899f0954aa094be96e))
 * Update rubocop 0.51 -0.52 ([#22035](http://projects.theforeman.org/issues/22035), [5f047b65](http://github.com/katello/katello/commit/5f047b6520a39409f26761ff6820d41516754e71))
 * update to rubocop 0.51.0 ([#21467](http://projects.theforeman.org/issues/21467), [d0ded38d](http://github.com/katello/katello/commit/d0ded38d6e457a2b51ac76a465f17bcb81dd864c))
 * sync plans controller test is testing the wrong action ([#21466](http://projects.theforeman.org/issues/21466), [464b4787](http://github.com/katello/katello/commit/464b4787e66585365b8b4f4a1737cb52e15414dd))
 * No more factory_girl_rails ([#21458](http://projects.theforeman.org/issues/21458), [acf238d0](http://github.com/katello/katello/commit/acf238d07f7d0a062d8512328566dd83c892f005), [7a8b048f](http://github.com/katello/katello/commit/7a8b048f46d99fbe71f135677bbcbe838de8a228))
 * NameError: uninitialized constant Katello::Host::HostInfo  during engine load ([#20234](http://projects.theforeman.org/issues/20234), [4cc182fc](http://github.com/katello/katello/commit/4cc182fc474cd5f8caf0e77d195e6a7e04bd33b6), [564ca702](http://github.com/katello/katello/commit/564ca702668f6ec2df0ee4588291306f1c249c03))
 * Fix tests after create and edit permissions started to be enforced ([#20135](http://projects.theforeman.org/issues/20135), [259e113f](http://github.com/katello/katello/commit/259e113fee2d64a13ab4170cc943c1d5b5d87147))
 * Fix tests for sprockets-rails 3.x ([#20122](http://projects.theforeman.org/issues/20122), [0845021d](http://github.com/katello/katello/commit/0845021d7bd08d7ab0ccf43f5912a96bde649abc), [18d296d7](http://github.com/katello/katello/commit/18d296d7d37e8136fec25442100797fadf4c4609))
 * upgrade to rubocop 0.49.1 ([#19931](http://projects.theforeman.org/issues/19931), [70972aae](http://github.com/katello/katello/commit/70972aaee4cbf10d91a505a051971deb0dffc494))
 * Undefined method 'split' for nil on several tests ([#19741](http://projects.theforeman.org/issues/19741), [885e3f2e](http://github.com/katello/katello/commit/885e3f2e487a99dd0cdc5948d3e4353ec4cd382f), [108f9919](http://github.com/katello/katello/commit/108f99198f1aa9368d785a4401fb066fca69f378))
 * hound ci doesn't recognize nested .rubocop.yaml files ([#19674](http://projects.theforeman.org/issues/19674), [ed1373f4](http://github.com/katello/katello/commit/ed1373f43fd69be5700879d8bd493376c3766b4f))
 * duplicate code in test/actions/pulp/repository/* files  ([#19434](http://projects.theforeman.org/issues/19434), [e9cceccc](http://github.com/katello/katello/commit/e9cceccc3017ad4491c4a1a371015d33c696652d))
 * transient test failure ([#19351](http://projects.theforeman.org/issues/19351), [b3bc464b](http://github.com/katello/katello/commit/b3bc464b7a8ae2a15682a126f181e7edd1770134))
 * Tests relying on stubbing settings must be updated for external auth source seeding ([#19174](http://projects.theforeman.org/issues/19174), [e97a3d3c](http://github.com/katello/katello/commit/e97a3d3c7c1e0eecd45ab469cb87f5330d575219))
 * Ignore Javascript files in source code test for i18n ([#22576](http://projects.theforeman.org/issues/22576), [f5894f21](http://github.com/katello/katello/commit/f5894f21f15c8f755ea94aecfc3689e74095e9af))

### Installer
 * [ RFE ] add mgmt-pub param to qpidd.conf ([#22465](http://projects.theforeman.org/issues/22465), [e1ce860f](http://github.com/katello//commit/e1ce860fc3f95dc62630e47bf59f10e84da6393c))
 * Workers go missing under heavy load ([#22338](http://projects.theforeman.org/issues/22338), [84c00335](http://github.com/katello/puppet-pulp/commit/84c0033586861c5f165da9004c1e3e24d0165908), [525639b7](http://github.com/katello/puppet-foreman_proxy_content/commit/525639b7c7de6fcbe2a154faba4b7bda39971fc4), [00822e57](http://github.com/katello/puppet-katello/commit/00822e571bcb46b86554daed1bdb2ce5fa836438))
 * [RFE] Add an option to change value of "rest_client_timeout" present in /etc/foreman/plugins/katello.yaml ([#22200](http://projects.theforeman.org/issues/22200), [3df2fa40](http://github.com/katello/puppet-katello/commit/3df2fa40ff987c510aa45f5cb56c5200e8c07052))
 * Unclear error message when forward IP does not reverse resolve ([#22173](http://projects.theforeman.org/issues/22173), [814d70b0](http://github.com/katello/katello-installer/commit/814d70b0a70076ec5c3086307cbde55e5c6dea82), [d493c6d4](http://github.com/katello/katello-installer/commit/d493c6d49298df9f80168896f4baefa12fd50540))
 * pulp_ostree.conf should redirect gpgkey info ([#21957](http://projects.theforeman.org/issues/21957), [5ff7611c](http://github.com/katello/puppet-pulp/commit/5ff7611c6e577b95f5a3f096830c4e3097c4db2d))
 * [RFE] print warning if capsule-certs-generate --capsule-fqdn is same as satellite server's hostname ([#21873](http://projects.theforeman.org/issues/21873), [87bf159a](http://github.com/katello/puppet-certs/commit/87bf159a9e481feeccbd9ee43735776ac1c8a127), [42583cea](http://github.com/katello/puppet-certs/commit/42583cea92405c6d83d3c6937bf360ff9936b780))
 * limit puppet pulp wsgi processes to 1 on foreman smart proxy with content ([#21430](http://projects.theforeman.org/issues/21430), [0e9afcba](http://github.com/katello/puppet-foreman_proxy_content/commit/0e9afcbaf2fdbace68b2d4c43016a604ed8c563d))
 * `open': Not a directory - /var/lib/qpidd/.qpidd/qls/jrnl/<something> (Errno::ENOTDIR) ([#21268](http://projects.theforeman.org/issues/21268), [b7a1898a](http://github.com/katello/katello-installer/commit/b7a1898a046d8734aa2d983a060de28f08a43edc))
 * Re-factor installer success messages ([#21060](http://projects.theforeman.org/issues/21060), [0bab4634](http://github.com/katello/katello-installer/commit/0bab463495978de8d9661115b7ebd759921962ef), [b6916c99](http://github.com/katello/katello-installer/commit/b6916c99f777973db438184198e8ba361ecd223f))
 * upgrade to satellite 6.3 beta wont work if ssl.conf is missing ([#21708](http://projects.theforeman.org/issues/21708), [549cf61e](http://github.com/katello/katello-installer/commit/549cf61e81935afa5755faf065fe8c2c37298a2f))
 * Chef smart proxy plugin not present in katello scenario's answer file ([#21498](http://projects.theforeman.org/issues/21498), [375df41d](http://github.com/katello/katello-installer/commit/375df41d63fc9c8fa445ae0bf3e4f83bfc325581))
 *  undefined method `puppet5_installed?' from installer ([#21471](http://projects.theforeman.org/issues/21471), [505d1df5](http://github.com/katello/katello-installer/commit/505d1df5f8ebe5a6d83a127063601288fa0dc5ee))
 * Can't upgrade Puppet 3 to Puppet 4 on Capsule ([#21321](http://projects.theforeman.org/issues/21321), [3fa59d32](http://github.com/katello/katello-installer/commit/3fa59d3219f64bc0e31691b8a65f9af9629f81ec))
 * --upgrade-puppet doesn't migrate environments in the correct location ([#21248](http://projects.theforeman.org/issues/21248), [8005830a](http://github.com/katello/katello-installer/commit/8005830a6bc9d6168664263871fd57bc2176ef1e))
 * capsule-certs-generate throws errors for puppet-agent and puppetserver not installed ([#21222](http://projects.theforeman.org/issues/21222), [0dda24c8](http://github.com/katello/katello-installer/commit/0dda24c82882e1086d34a4bc4bb12d6da2c18948))
 * katello-proxy-* values in satellite-answers.yaml no longer support empty quoted entries ([#21217](http://projects.theforeman.org/issues/21217), [126decf5](http://github.com/katello/katello-installer/commit/126decf538c890a534ed472390e217d33bb2ae8a))
 * capsule-certs-generate throws NoMethodError post migration to 6.3 ([#21138](http://projects.theforeman.org/issues/21138), [4d25f6d8](http://github.com/katello/katello-installer/commit/4d25f6d8f3ca810d61e2fa18e3b6698cc1f13828))
 * capsule-certs-generate --certs-tar does not accept relative path ([#21128](http://projects.theforeman.org/issues/21128), [d3dd4190](http://github.com/katello/katello-installer/commit/d3dd4190fca86402d5036c45ce85b2c714e3f59d))
 * puppet-pulp uses enable instead of enabled in profiling ([#20865](http://projects.theforeman.org/issues/20865), [87cd4e5f](http://github.com/katello/puppet-pulp/commit/87cd4e5fa92e5970dd1ed5f8017dc26ce15a2905))
 * change import subscriptions to a more general task ([#20587](http://projects.theforeman.org/issues/20587), [0b522e50](http://github.com/katello/katello-installer/commit/0b522e50896499d91498eb5faee5ca16c1a0496a))
 * --foreman-proxy-templates is not enabled by default ([#19720](http://projects.theforeman.org/issues/19720), [330b238c](http://github.com/katello/katello-installer/commit/330b238cdbe16a2e43f85042e004f6b9cfc58870))
 * katello_devel missing from parser cache ([#19601](http://projects.theforeman.org/issues/19601), [52e7e64e](http://github.com/katello/katello-installer/commit/52e7e64ea0dfc946e0a83c8de1fa9f9e1d8dec3e))
 * foreman-installer deploys a non-working "qdrouterd.conf " after qpid-dispatch-router has been upgraded from 0.8.0-1.el7 to 1.0.0-1.el7 in epel repos ([#22289](http://projects.theforeman.org/issues/22289), [6a045064](http://github.com/katello//commit/6a0450649716c317437c8e612fda2459fba8dd27), [d1155d5f](http://github.com/katello/puppet-foreman_proxy_content/commit/d1155d5f5405d23164ad0cb13580beb75bf98873))
 * katello does not set Xmx setting in tomcat.conf, leading to possible OOMs ([#18146](http://projects.theforeman.org/issues/18146), [da68e6b3](http://github.com/katello/puppet-candlepin/commit/da68e6b351b03f8648bfc436f2d3fbd6069a15bd))
 * Expose params to configure remote MongoDB connection ([#22907](http://projects.theforeman.org/issues/22907), [c767a280](http://github.com/katello/puppet-katello/commit/c767a280f6b5b469cf594b3528390a73555097aa))

### Backup & Restore
 * Bypass validation using confirmation flag ([#22447](http://projects.theforeman.org/issues/22447))
 * Add warning/confirmation to snapshot backup ([#22418](http://projects.theforeman.org/issues/22418))
 * change name for installer suggestion in hostname change ([#21492](http://projects.theforeman.org/issues/21492), [86466b71](http://github.com/katello//commit/86466b716f63c0493576e29e9a639252a55c2cc8))
 * change name of katello-change-hostname to be easily overwritten ([#21220](http://projects.theforeman.org/issues/21220), [765b6400](http://github.com/katello//commit/765b64003d26ab58a98a93d5b11e7377ee6b655f))
 * no output on foreman rpm installed check for katello scripts ([#21219](http://projects.theforeman.org/issues/21219), [b479d7f0](http://github.com/katello//commit/b479d7f090b08107d79251af277191d627d38b96))
 * cleanup snapshots if backup fails ([#21198](http://projects.theforeman.org/issues/21198), [123c4326](http://github.com/katello//commit/123c43268669806b73e11a21f5e70448d81461b2))
 * katello-backup fails with /usr/share/ruby/fileutils.rb:125: warning: conflicting chdir during another chdir block ([#21183](http://projects.theforeman.org/issues/21183), [5b7de1e0](http://github.com/katello//commit/5b7de1e00753001ff2be0007d85f763482e10542))
 * katello-backup does not backup custom certificates and need to ensure katello-restore restores them ([#21270](http://projects.theforeman.org/issues/21270), [e1b76c02](http://github.com/katello//commit/e1b76c02654747389de0d19979cc2b28554225c4))
 * Disable system checks by default on katello scripts ([#21221](http://projects.theforeman.org/issues/21221), [be2b07f6](http://github.com/katello//commit/be2b07f6c97f7bff223748a5d66d1879394cf421))
 * katello-change-hostname- doesn't delete last scenario file ([#21252](http://projects.theforeman.org/issues/21252))

### Provisioning
 * Add missing katello_default_PXEGrub and katello_default_PXEGrub2 settings ([#22337](http://projects.theforeman.org/issues/22337), [a3954cc7](http://github.com/katello/katello/commit/a3954cc77a846ff261ce717088b03253224a9d7c))
 * Prefetch vmlinuz and initrd on sync ([#22318](http://projects.theforeman.org/issues/22318), [23a9557a](http://github.com/katello/katello/commit/23a9557a7cf3820aa96a571f29179dee9031ee06))
 * Default templates use deprecated @host.params ([#22142](http://projects.theforeman.org/issues/22142), [3770303d](http://github.com/katello/katello/commit/3770303d9276a63a56cbac1ee678ffe5da0cdcc3))
 * New provisioned machines show a warning "reboot required".  Solved by executing "katello-tracer-upload" ([#22330](http://projects.theforeman.org/issues/22330), [dda4dc30](http://github.com/katello/katello-agent/commit/dda4dc30ad269abcd33dc410ed5127e3cca00de2))

### Lifecycle Environments
 * 'Errata ID' hyperlink on Lifecycle Environments -> Errata page is broken ([#22263](http://projects.theforeman.org/issues/22263), [894e8b07](http://github.com/katello/katello/commit/894e8b072a74890b9e7a59775e89763dc476b7ee))

### Web UI
 *  Filtering by repository is not working in Packages/Errata/OSTree view ([#22241](http://projects.theforeman.org/issues/22241), [96f528a5](http://github.com/katello/katello/commit/96f528a5a553ad01c924f02e8be8eb5b0b55d373))
 * 'Select Organization' dialog only showing first 20 organizations ([#21719](http://projects.theforeman.org/issues/21719), [d645f310](http://github.com/katello/katello/commit/d645f310e69cda076aed57ff8daec6127ba1d5ae))
 * Sync Status progress bar does not work ([#21711](http://projects.theforeman.org/issues/21711), [0db15ab6](http://github.com/katello/katello/commit/0db15ab69e062c8f507b019da0ca334bee6f59df))
 * Add patternfly-react to katello package.json ([#21562](http://projects.theforeman.org/issues/21562), [a46c45de](http://github.com/katello/katello/commit/a46c45de28b4de0f82240e30c4b89cde0b5a21f9))
 * content sub menu missing sub-headers on vertical nav ([#21385](http://projects.theforeman.org/issues/21385), [8324c9a1](http://github.com/katello/katello/commit/8324c9a1e5a0088e5f382d0c036c68aeb3b4bf3d))
 * content view filter repository selection table doesn't reflect correct selected count ([#21284](http://projects.theforeman.org/issues/21284), [64253012](http://github.com/katello/katello/commit/642530128bf38809bcc8500369ceb6af0bd5d359))
 * paged list on repo discovery shows too many per page ([#21258](http://projects.theforeman.org/issues/21258), [e54bf63c](http://github.com/katello/katello/commit/e54bf63c2cdd910c044d06fb3b67ab32e3026d2f))
 * Incorrect Next Sync date calculation in weekly Sync Plan ([#21194](http://projects.theforeman.org/issues/21194), [89fcecb8](http://github.com/katello/katello/commit/89fcecb85d22ba65e39725d403f519791b19cd98))
 * Smart proxy labels should be bold ([#20659](http://projects.theforeman.org/issues/20659), [884dc3fe](http://github.com/katello/katello/commit/884dc3fef4fc31ec136c6ab52dda9e0c6e3f6700))
 * Clicking on the arrow icon on an Errata Details page does not show the other errata items ([#21481](http://projects.theforeman.org/issues/21481), [245d748c](http://github.com/katello/katello/commit/245d748cd533afceef04e0a25127da5b23776f2e))
 * New Host Synced Content Radio Button disabled  ([#21185](http://projects.theforeman.org/issues/21185), [9cb59baa](http://github.com/katello/katello/commit/9cb59baadbcf65996898115eda2343c61970ae4e))
 * Missing HTML title on "Content Hosts" page ([#20988](http://projects.theforeman.org/issues/20988), [ac25cd85](http://github.com/katello/katello/commit/ac25cd85a394a9124875d90fabbee2eed3af047f))
 * All item pages should be using id instead of uuid ([#20747](http://projects.theforeman.org/issues/20747), [d0f2a68d](http://github.com/katello/katello/commit/d0f2a68d79a1cc46175f2a660cfeb8531b83d016))
 * sprockets 3.x requires SCSS assets to use .scss ([#20544](http://projects.theforeman.org/issues/20544), [aaa18733](http://github.com/katello/katello/commit/aaa187330ec26188b25b6d6d64f7bbb2471950d7))
 * Katello can't use relocated URI ([#20313](http://projects.theforeman.org/issues/20313), [db51fdac](http://github.com/katello/katello/commit/db51fdacfc8ee414183552e03581da0e4175eec5), [5c30cb34](http://github.com/katello/katello/commit/5c30cb34202a0d5a2407c4f4f56ecf1d7eced1a4), [d45cc374](http://github.com/katello/katello/commit/d45cc374af4cf72009ebbd0d69b9edfb1fb48174))
 * Disable repository set on activation key repeatedly returns repositories ([#20057](http://projects.theforeman.org/issues/20057), [2c8fc1ea](http://github.com/katello/katello/commit/2c8fc1eaec7029c4feb1e18db4a62a0e20234682))
 * Rename "Yum Actions" to just "Actions" ([#22923](http://projects.theforeman.org/issues/22923), [ffe49883](http://github.com/katello/katello/commit/ffe498835c7ee2c6aa9795aee6292202453bb92f))
 * JS Error: s.included.ids is undefined - on choosing REX on host collection ERRATA dialog ([#22834](http://projects.theforeman.org/issues/22834), [183ec4a0](http://github.com/katello/katello/commit/183ec4a049776a5504b540e9ef597b5f5ffd09f3))

### API
 * activation key repo sets fails with error  wrong number of arguments (given 0, expected 1) ([#22240](http://projects.theforeman.org/issues/22240), [9da1e12c](http://github.com/katello/katello/commit/9da1e12c7c2d93275862945d17d2e62f032fadec))
 * API endpoint for auto_attach/remove/add subscription in host bulk action is incorrect ([#21923](http://projects.theforeman.org/issues/21923), [d09f0730](http://github.com/katello/katello/commit/d09f0730d5c57519a45db20a352201fc06c39b61))
 * As per API v2 documentation for <server_url>/apidoc/v2/packages.html | GET /katello/api/compare is not working ([#19304](http://projects.theforeman.org/issues/19304), [dc49f7e4](http://github.com/katello/katello/commit/dc49f7e403a9691503b400671f1355ef8e69d175))
 * ISE on Errata API list call when using invalid sort by name ([#21525](http://projects.theforeman.org/issues/21525), [2e39affb](http://github.com/katello/katello/commit/2e39affb47849ebd42f6974892e7618ed6c5dbd5))
 * hammer order option has no effect ([#20579](http://projects.theforeman.org/issues/20579), [3605d81f](http://github.com/katello/katello/commit/3605d81f838a624f22fe289c652a17f2f72b51fa))
 * organization_id should be a top level attribute in the API ([#20219](http://projects.theforeman.org/issues/20219), [f8008f09](http://github.com/katello/katello/commit/f8008f09aa7cc1f2d05d268e2fa58b0ab7564a72))
 * [V2] Regression in content view API ([#22180](http://projects.theforeman.org/issues/22180), [062a73e0](http://github.com/katello/katello/commit/062a73e039eb62fb60e1c9e5c140ba4ebefc0c80))
 * ignore_global_proxy missing from repo update apipie doc ([#22561](http://projects.theforeman.org/issues/22561), [e8b57ca9](http://github.com/katello/katello/commit/e8b57ca9cc973a8b8ffd6d6dde34e48b97251bdd))

### Activation Key
 * notification shows an error indicator when adding a subscription to an activation key ([#22195](http://projects.theforeman.org/issues/22195), [953ad8ce](http://github.com/katello/katello/commit/953ad8ce9507c8bdbc855d720fd99f1abc698db2))
 * content-override done by hammer has no effect when using AK ([#21275](http://projects.theforeman.org/issues/21275), [fe18baf2](http://github.com/katello/hammer-cli-katello/commit/fe18baf2dbffad45e47b54f265329f0f31abde5f))

### Hosts
 * Date format of published content view in yaml output changed on Rails 5.x and causes Puppet runs to fail ([#22186](http://projects.theforeman.org/issues/22186), [ac81226e](http://github.com/katello/katello/commit/ac81226e3da738fefefd47a8fc5daa5d029b18ba))
 * Fix tests to support fact importer transaction check ([#21880](http://projects.theforeman.org/issues/21880), [2bd734ef](http://github.com/katello/katello/commit/2bd734efdc8d10a81dba877bc940f08e97d18f56))
 * Can't register content host ([#21438](http://projects.theforeman.org/issues/21438), [3ab3dae5](http://github.com/katello/katello/commit/3ab3dae52b875debabaab1a6bbe64b854d46cf68))
 * Registered date value for content hosts in webUI is empty ([#21235](http://projects.theforeman.org/issues/21235), [57cfe796](http://github.com/katello/katello/commit/57cfe796fdef58da8531bc5ab62dc1381a752f3d))
 * “Unregister Host” needs a clear instruction for options under it ([#21051](http://projects.theforeman.org/issues/21051), [1875ec2a](http://github.com/katello/katello/commit/1875ec2a5ae628fb4f28ea1cb91ebd0501c87314))
 * Katello loads hosts controller before other plugins can extend the API ([#21382](http://projects.theforeman.org/issues/21382), [b1d44bc4](http://github.com/katello/katello/commit/b1d44bc45434f04b075477ff439df7ec8cc40577))
 * Add db index on "katello_content_facet_errata"  "content_facet_id" ([#21282](http://projects.theforeman.org/issues/21282), [42f5d95a](http://github.com/katello/katello/commit/42f5d95a05c9cf1cc0ee19c92f72e9f088eb58e9))
 * Missing 'Content Source' output in `hammer host info` ([#21057](http://projects.theforeman.org/issues/21057), [fe2d9c37](http://github.com/katello/hammer-cli-katello/commit/fe2d9c37bddb207c7688ce5e7d74fd2a08920dee))
 * Unable to update host's content source via hammer ([#21016](http://projects.theforeman.org/issues/21016), [b4cacd27](http://github.com/katello/katello/commit/b4cacd2784748480f7d354450011ba2266fcad6f))
 * Content Host Installable Errata show wrong icons color when 0 applicable ([#20714](http://projects.theforeman.org/issues/20714), [68732d64](http://github.com/katello/katello/commit/68732d644c8613100b9257fc9cc232bf8bae5fb7))
 * Extremely slow /api/v2/hosts, 200hosts/page takes about 40s to display ([#20508](http://projects.theforeman.org/issues/20508), [59c52f67](http://github.com/katello/katello/commit/59c52f6787e1a446aa8690fec28d9159ac0d2103))
 * Can't jump to its "Virtual Guests" in host's "Content host-->detail"page ([#22179](http://projects.theforeman.org/issues/22179), [cff3a5a4](http://github.com/katello/katello/commit/cff3a5a47f0174903b79d28c39f357d1abec4532))
 * Last search term for Content Hosts recalled, when pressing "Search" ([#21712](http://projects.theforeman.org/issues/21712), [a406fbe9](http://github.com/katello/katello/commit/a406fbe95cf7b41b2de7bc772d2fe3195fb69e75))
 * Allow non-RH hosts to NOT have content views ([#21670](http://projects.theforeman.org/issues/21670), [405a1bc7](http://github.com/katello/katello/commit/405a1bc7c6434cad3974b904beaca54e13c83e7d))
 * Host creation form bounces from synced content to media not found ([#21665](http://projects.theforeman.org/issues/21665), [3bf503ce](http://github.com/katello/katello/commit/3bf503ce0d3f50067c6a05df88bd25e623f0536e))
 * do not log stack trace if generateapplicability generates a 404 ([#21797](http://projects.theforeman.org/issues/21797), [c2f5ec4f](http://github.com/katello/katello/commit/c2f5ec4f4e7a0b1213339ff5df191ec39c0b95a0))
 * provide option to skip hostname facts lookup for existing host if register_hostname_fact is set ([#22939](http://projects.theforeman.org/issues/22939), [fe903fef](http://github.com/katello/katello/commit/fe903fef715cd226f7a3499dacd45d98c756f254))

### Errata Management
 * Slow katello-errata query on dashboard ([#22161](http://projects.theforeman.org/issues/22161), [254dc4a7](http://github.com/katello/katello/commit/254dc4a72c4b7a41810471105dba20c65da993f2))
 * Misleading information when applying Installable Errata in  WEBUI > Content Host ([#21796](http://projects.theforeman.org/issues/21796), [649a9fb6](http://github.com/katello/katello/commit/649a9fb69368a77bd253e2c92194fcc31eb33ad9))
 * API call for Applicable errata in host bulk action missing ([#20480](http://projects.theforeman.org/issues/20480), [d2b04853](http://github.com/katello/katello/commit/d2b048535fa5abdd14672051457ba4cf45756881))
 * host errata counts are zero after upgrade ([#21403](http://projects.theforeman.org/issues/21403), [f0609e4e](http://github.com/katello/katello/commit/f0609e4e6c0998363ac5e5a32a9b9a7bd9e5624e))
 * Listing errata for host groups does not work unless host and content facet have the same id ([#21283](http://projects.theforeman.org/issues/21283), [05ac66ec](http://github.com/katello/katello/commit/05ac66ec47518303e6549e860910e3880583c92f))

### Docker
 * uninitialized constant  - RemoveDockerTag on publish ([#22157](http://projects.theforeman.org/issues/22157), [36eacc4c](http://github.com/katello/katello/commit/36eacc4c6acca64457d78aba0919ef197b9f5a9c))
 * Docker Blobs not getting cleared out during promotion ([#21845](http://projects.theforeman.org/issues/21845), [a0e098cd](http://github.com/katello/katello/commit/a0e098cded383b65b09100a971570b7194bbd9b7))
 * Docker Tags not getting cleared out on Promote ([#21808](http://projects.theforeman.org/issues/21808), [a3ca931c](http://github.com/katello/katello/commit/a3ca931c45833762685630302dab1ba9c5734fc2))
 * Docker Tag page missing manifest type ([#21692](http://projects.theforeman.org/issues/21692), [84f5516f](http://github.com/katello/katello/commit/84f5516f209a46fe80ccb280fa3dd622922e10d3))
 * Resyncing a Docker Repository does not update the tag information ([#21683](http://projects.theforeman.org/issues/21683), [5c11f39d](http://github.com/katello/katello/commit/5c11f39d2f7e6793912e55eed4088d8da015e724))
 * Wrong docker tags copied over on publish ([#21681](http://projects.theforeman.org/issues/21681), [9b45392b](http://github.com/katello/katello/commit/9b45392b655ff0c6ab81b800b7e6007d3faafa03))
 * Remove Docker Manifest  name ([#21323](http://projects.theforeman.org/issues/21323), [14128f7d](http://github.com/katello/katello/commit/14128f7d6002733c3f2c4ae9c8e60da0bcab2d3f))
 * Docker Manifests - Auto complete options not getting displayed ([#21518](http://projects.theforeman.org/issues/21518), [5990b0bc](http://github.com/katello/katello/commit/5990b0bc08a298d08b73fda0cea3966f58c9600c))
 * Docker Tags auto complete broken ([#21484](http://projects.theforeman.org/issues/21484), [6bfcb68c](http://github.com/katello/katello/commit/6bfcb68cd532c0ea4cabd490d59ff494f03a1095))
 * wrong docker tag id referenced in repository manage manifests page ([#21470](http://projects.theforeman.org/issues/21470), [61b8a85b](http://github.com/katello/katello/commit/61b8a85b28a6f11bb258b47a33b92e8cdf0f945e))
 * docker repos synced to capsule do not use a proper repo_registry_id on initial sync ([#21397](http://projects.theforeman.org/issues/21397), [c035c037](http://github.com/katello/katello/commit/c035c0370c5f32c68d7f878bb70f8a942b778773), [a724e144](http://github.com/katello/katello/commit/a724e14487b38e4fcaa564d09b7bb68e48a03a40))
 * Delete DockerMetaTags when docker tags are deleted ([#21326](http://projects.theforeman.org/issues/21326), [abc060dd](http://github.com/katello/katello/commit/abc060dd744866c09fba422c65deff78623dc815))
 * lifecycle environments shown for a specific docker tag shows all tags ([#21255](http://projects.theforeman.org/issues/21255), [cfc117a8](http://github.com/katello/katello/commit/cfc117a8fe5474db1604b7f464fb604da28701ba))
 * Cannot provision a Katello Managed docker container  ([#21050](http://projects.theforeman.org/issues/21050), [113b5798](http://github.com/katello/katello/commit/113b57983c750573d2214a7f042d91a386a8a561))
 * ISE when trying to auto complete on a CV Docker Filter ([#21607](http://projects.theforeman.org/issues/21607), [e77c2e6b](http://github.com/katello/katello/commit/e77c2e6b8d8a1ae5d1790446da2997f04cd4c505))

### Tooling
 * Remove disable_dynflow from import_product_content rake task ([#22116](http://projects.theforeman.org/issues/22116), [36d76c3b](http://github.com/katello/katello/commit/36d76c3b6287c4a1f7b604efe01edf94d9c3f894))
 * bastion katello strings can not be extracted ([#21830](http://projects.theforeman.org/issues/21830), [5307b864](http://github.com/katello/katello/commit/5307b864371011cacc8541d74c93de121fe35ac1))
 * katello-change-hostname uses fail_with_message before defining it ([#21029](http://projects.theforeman.org/issues/21029), [94074414](http://github.com/katello//commit/94074414f1865d45a85f722ea5ae7a81cef87320))
 * katello-change-hostname should check exit codes of shell executions ([#20925](http://projects.theforeman.org/issues/20925), [685cad77](http://github.com/katello//commit/685cad775989ddf653c165bad2b94b751f4fd165))
 * katello-change-hostname should verify credentials before doing anything ([#20924](http://projects.theforeman.org/issues/20924), [ef4fa97b](http://github.com/katello//commit/ef4fa97b279409406abcd14e8ba0e03f8b575abe))
 * katello-change-hostname tries to change the wrong default proxy if default proxy id has multiple digits ([#20921](http://projects.theforeman.org/issues/20921), [f7db11e5](http://github.com/katello//commit/f7db11e5e7019a5a264c44cd77d581253776ba0d))
 * katello-change-hostname silently fails when there are special (shell) chars in the password ([#20919](http://projects.theforeman.org/issues/20919), [ece3dc6f](http://github.com/katello//commit/ece3dc6f2cda95011b72a39cbba69f8c13bb601e))
 * katello-remove is very slow ([#19941](http://projects.theforeman.org/issues/19941), [8fc138c0](http://github.com/katello//commit/8fc138c08e4e519459fa292f658b7d02fae32497))
 * rpm build failing with LoadError: cannot load such file -- katello-3.5.0/test/support/annotation_support ([#19567](http://projects.theforeman.org/issues/19567), [d7ed8a44](http://github.com/katello/katello/commit/d7ed8a44b2c717b06b9cd03b5f98913291308b95))
 * update to runcible 2.0 ([#19379](http://projects.theforeman.org/issues/19379), [7c4181f1](http://github.com/katello/katello/commit/7c4181f119e44557696f085620da905f2d94721e))

### Content Views
 * ISE when publishing a composite with cv containing  puppet content ([#22044](http://projects.theforeman.org/issues/22044), [17159892](http://github.com/katello/katello/commit/17159892b94c7c452145b4910647499b144bd34d))
 * Error when promoting content view with puppet modules ([#22040](http://projects.theforeman.org/issues/22040), [2ef7126e](http://github.com/katello/katello/commit/2ef7126e5212c761b01dfceff8ba2272182933f7))
 * publish conent view with docker, ostree, or file type repo fails with "undefined method repository' ([#22025](http://projects.theforeman.org/issues/22025), [5a46319a](http://github.com/katello/katello/commit/5a46319a981e25c9eaa4782ae92b020020d37189))
 * stop emptying repositories on promote ([#21726](http://projects.theforeman.org/issues/21726), [578dbb23](http://github.com/katello/katello/commit/578dbb238d9a9baeb8ee703a382599d200637415))
 * restrict content view version deletion if part of published composite version ([#21697](http://projects.theforeman.org/issues/21697), [d907acf6](http://github.com/katello/katello/commit/d907acf63067371fd1eea7ef8891d04d007d46ce))
 * use existing repository when indexing composite view repos ([#21695](http://projects.theforeman.org/issues/21695), [4b90abce](http://github.com/katello/katello/commit/4b90abce5d9f0bb593aa5c7cbb5eab3c3cf566fb))
 * skip unit copies on content view promotion ([#21549](http://projects.theforeman.org/issues/21549), [898584a7](http://github.com/katello/katello/commit/898584a7d241618b2d9206d21eaf2fbd0a75ecd7))
 * re-use indexed data for promotion ([#21548](http://projects.theforeman.org/issues/21548), [4a2ec5b3](http://github.com/katello/katello/commit/4a2ec5b34688e2b284edd7c9fd1323eeca42d703))
 * Content Views dont copy SRPMs at all ([#21154](http://projects.theforeman.org/issues/21154), [9622ea2c](http://github.com/katello/katello/commit/9622ea2c3c970da163be6dde0bbac19a6febe7be))
 * Hammer composite content-view create/update with component-ids add only the first component of the list ([#20995](http://projects.theforeman.org/issues/20995), [30880d02](http://github.com/katello/katello/commit/30880d02c8b587daa828e1070746c29314ffe09c))
 * Content views should be searchable on the basis on 'label' ([#20844](http://projects.theforeman.org/issues/20844), [79e4028f](http://github.com/katello/katello/commit/79e4028f6143e7783cc7da2bbd6a8b5abf6b4948))
 * deletion of CV fails when a content host is assigned ([#21512](http://projects.theforeman.org/issues/21512), [bb29e1ee](http://github.com/katello/katello/commit/bb29e1ee65ac701cbf0e577f1b7cfd6c8c779ba7))
 * Content view version's Errata tab is absent if version contains only RH repos ([#21274](http://projects.theforeman.org/issues/21274), [fafe91dc](http://github.com/katello/katello/commit/fafe91dc9dbcdbd2ba64b36827bdf89c1323d742))
 * `content-view filter rule info` does not resolve by name with multiple rules on a filter ([#20761](http://projects.theforeman.org/issues/20761), [79fa4884](http://github.com/katello/katello/commit/79fa48845a191f63e966c281fa0aff086f78e91c), [8bfa14c7](http://github.com/katello/hammer-cli-katello/commit/8bfa14c7a06b41a4b54ba4defb44c9f3b56c68c5))
 * Select inputs on content view deletion are not correctly styled ([#19285](http://projects.theforeman.org/issues/19285), [4abe9501](http://github.com/katello/katello/commit/4abe95012860c53f2cf97df49c6cadac06607967))
 * Wrong value returned for CV Component ids ([#22288](http://projects.theforeman.org/issues/22288), [98eff346](http://github.com/katello/katello/commit/98eff34620704bcd8560f98638345dd95ceb4753))
 * When we click on a task listed under "Tasks" tab for CV it does not load/redirect to the actual foreman task. ([#22239](http://projects.theforeman.org/issues/22239), [ad44e33d](http://github.com/katello/katello/commit/ad44e33d1356bcafd4d47a6c2fa93d83f5f1e931))
 *  very slow publishing of a content view with filters containing many errata ([#21727](http://projects.theforeman.org/issues/21727), [6c54a7fa](http://github.com/katello/katello/commit/6c54a7fa6f538b920c94baa0b8a891401888b283))
 * publish content view page with two repos selected causes mistaken warning on publish page ([#22614](http://projects.theforeman.org/issues/22614), [eb39dcfb](http://github.com/katello/katello/commit/eb39dcfbe1e9e4d215455f8226880111834d6f95))
 * skip unit copies on composite content view publish ([#21696](http://projects.theforeman.org/issues/21696), [4b90abce](http://github.com/katello/katello/commit/4b90abce5d9f0bb593aa5c7cbb5eab3c3cf566fb))

### Repositories
 * include repository information in enable repo task output  ([#22039](http://projects.theforeman.org/issues/22039), [df915321](http://github.com/katello/katello/commit/df9153212f3fee66c02e9da8ba8b44839341e447))
 * updating a repo fails with "undefined method content" ([#22017](http://projects.theforeman.org/issues/22017), [59d1cc30](http://github.com/katello/katello/commit/59d1cc306d7e8a4b1fecc55269280c554da5a65e))
 * Improve repository sets api ([#21955](http://projects.theforeman.org/issues/21955), [bc2c5a68](http://github.com/katello/katello/commit/bc2c5a68824b9b35d58c22398896edb54d351607))
 * allow option to bypass http proxy on syncs ([#21706](http://projects.theforeman.org/issues/21706), [c80d4d8a](http://github.com/katello/katello/commit/c80d4d8ad4092ffb1f413771bdceee945313f012))
 * hammer repository upload-content is successful even with incorrect product ID ([#21623](http://projects.theforeman.org/issues/21623), [3f04813d](http://github.com/katello/hammer-cli-katello/commit/3f04813d1e8ae30d3ac1669303e9a96c70b8ae4c))
 * Hammer CLI has not option to list File repository content ([#21142](http://projects.theforeman.org/issues/21142), [2fbee25b](http://github.com/katello/katello/commit/2fbee25b0926afa5bc0e382f68e69727e17a7278), [0e31b71e](http://github.com/katello/hammer-cli-katello/commit/0e31b71ef0681bd57543f42fd075470bf9a9abe5))
 * Improve repo web UI text ([#20916](http://projects.theforeman.org/issues/20916), [5d1543da](http://github.com/katello/katello/commit/5d1543da03beca3fc02ef95d793b3eea78c06139))
 * Add "Files" and "Images" tabs to "Red Hat Repositories" page  ([#20235](http://projects.theforeman.org/issues/20235), [b4f8ed9d](http://github.com/katello/katello/commit/b4f8ed9deb13423fb4ad3662516f9b552908b802))
 * Javascript error on Docker Tag details page ([#21439](http://projects.theforeman.org/issues/21439), [1fc82810](http://github.com/katello/katello/commit/1fc82810ba25036abae9d7d2ce0caf5eb3b81956))
 * hammer repository-set enable --help doesn't explain purpose of --new-name ([#21371](http://projects.theforeman.org/issues/21371), [048c526a](http://github.com/katello/hammer-cli-katello/commit/048c526ac2ae084e46fd28e5829629278885b428))
 * new repository page fails to load arch list with error ([#21362](http://projects.theforeman.org/issues/21362), [cf682a72](http://github.com/katello/katello/commit/cf682a7264b7ac528d84c78059e80e63c3c97669))
 * Could not able to upload packages to yum repository. ([#21288](http://projects.theforeman.org/issues/21288), [19829e08](http://github.com/katello/katello/commit/19829e088e448d1102b8fdc77c8b38cb6745e223))
 * Post-sync pulp notification shouldn't fail with lock error ([#21197](http://projects.theforeman.org/issues/21197), [d05d5a55](http://github.com/katello/katello/commit/d05d5a55750e88906287049c8362d3548f21941d))
 *  Internal Server error when searching product repository by numbers with more than 9 digits ([#21017](http://projects.theforeman.org/issues/21017), [ddd80cd4](http://github.com/katello/katello/commit/ddd80cd44b73d47556cc51259d1bf72ca0694660), [f7906cef](http://github.com/katello/katello/commit/f7906cefb94c94c1e1d154e7f3e07d96f41b6b6e), [26243182](http://github.com/katello/katello/commit/26243182825b96cd81adfe4a4d161c4815129bff), [da7a4849](http://github.com/katello/katello/commit/da7a48493621e990a6d854e90c79ab0f62e0598b))
 * Add foreman_scc_manager to repository ([#20741](http://projects.theforeman.org/issues/20741), [c523599f](http://github.com/katello//commit/c523599f18e3991ab43158e0c4ed4ba277826643))
 * Exceptions get covered in Pulp::Repository::CreateInPlan::Create ([#20349](http://projects.theforeman.org/issues/20349), [dd9bdccb](http://github.com/katello/katello/commit/dd9bdccb8b1ba65f16fba848cf78ac3ebee6d532))
 * `hammer package list --organization-id` results in 'Error: found more than one repository' ([#20091](http://projects.theforeman.org/issues/20091), [ead760ff](http://github.com/katello/hammer-cli-katello/commit/ead760ff907e75fb30dac6f07e37b90820e21960))
 * Remove old puppet modules from product that have been removed from the source repo ([#20089](http://projects.theforeman.org/issues/20089), [4ba82967](http://github.com/katello/katello/commit/4ba82967fe4efe2e60c4fe7dc82e02f7f6f90cca))
 * Javascript error on Docker Tag Lifecycle Environments page ([#21440](http://projects.theforeman.org/issues/21440))
 * Having empty repo in a Content View, Capsule sync of the CV fails on retrieving this repo metadata ([#21048](http://projects.theforeman.org/issues/21048), [d068817d](http://github.com/katello/katello/commit/d068817dfb4904b585104a0ae04766eb54e5c90c))
 * Katello schedules GenerateApplicability when syncing Puppet content ([#19370](http://projects.theforeman.org/issues/19370), [9e9b39df](http://github.com/katello/katello/commit/9e9b39df1ddcf6478263cb5556b4c0cfdc913713))

### Documentation
 * Document katello-host-tools when errata is unknown ([#21978](http://projects.theforeman.org/issues/21978), [e0345d63](http://github.com/katello/katello/commit/e0345d631fa4258c602b3df101ae6bacc02d5efb))
 * SmartProxy remove instructions wrong in manual ([#21210](http://projects.theforeman.org/issues/21210))
 * User guide's glossary is not available ([#20335](http://projects.theforeman.org/issues/20335))
 * Pulp Workflow: Document Repository Creation ([#18922](http://projects.theforeman.org/issues/18922), [fdc3b7be](http://github.com/katello/katello/commit/fdc3b7be98b85e0110576be04b8adece8e9bef19))
 * Pulp Workflow: Document repository syncing ([#18921](http://projects.theforeman.org/issues/18921), [fdc3b7be](http://github.com/katello/katello/commit/fdc3b7be98b85e0110576be04b8adece8e9bef19))
 * Sync plan docs mention monthly time period but that does not exit ([#18394](http://projects.theforeman.org/issues/18394))
 * katello README links are broken ([#21763](http://projects.theforeman.org/issues/21763), [3cf145e5](http://github.com/katello/katello/commit/3cf145e59a7cc8e1654fc717c999d6f7767d8689))

### Hammer
 * OStree upstream sync depth and sync policy not available in hammer ([#21966](http://projects.theforeman.org/issues/21966), [93e31149](http://github.com/katello/hammer-cli-katello/commit/93e3114935c05b9e412f406738b0601a393a48cd))
 * uninitialized constant HammerCLIKatello::FilterRuleHelpers (NameError) when running tests ([#21701](http://projects.theforeman.org/issues/21701), [1de50d26](http://github.com/katello/hammer-cli-katello/commit/1de50d26466b7fff904ca53b0a5b6a45935b7dcd))
 * hammer repo call needs  to show the docker manifest list ([#21524](http://projects.theforeman.org/issues/21524), [79a51f5f](http://github.com/katello/hammer-cli-katello/commit/79a51f5fdfe13718f2b5d60f3a2e1094154f547c))
 * Add hammer calls to show Source RPM Count ([#21413](http://projects.theforeman.org/issues/21413), [53d9dfb9](http://github.com/katello/hammer-cli-katello/commit/53d9dfb9e907e296928f6c330f0f24e1d9c46b07))
 * [hammer-cli-katello] Repository upload tests, request order dependency ([#21409](http://projects.theforeman.org/issues/21409), [aa33c621](http://github.com/katello/hammer-cli-katello/commit/aa33c621cb7abd1ba4e62600ee5dab236b5bc37e))
 * hammer host-collection add-host/remove-host always return success ([#21281](http://projects.theforeman.org/issues/21281), [5a6c68ac](http://github.com/katello/hammer-cli-katello/commit/5a6c68acbc6f484973746f0dfa7fb83988ffca99))
 * Support kickstart repository name parameter for host and hostgroup ([#21196](http://projects.theforeman.org/issues/21196), [6fad377a](http://github.com/katello/hammer-cli-katello/commit/6fad377a53f4e3160e20313eca29805d82a4f5cb))
 * show kickstart repository name in content facet json ([#21147](http://projects.theforeman.org/issues/21147), [1fc99d4a](http://github.com/katello/katello/commit/1fc99d4ae1111319e967d8e9cc9ae5034eafb276))
 * show kickstart repository name in hammer  ([#21146](http://projects.theforeman.org/issues/21146), [0ca5c538](http://github.com/katello/hammer-cli-katello/commit/0ca5c538006a220bfb04dff8d91c411898f95431))
 * hammer content-view filter rule create does not properly set the architecture ([#20749](http://projects.theforeman.org/issues/20749), [a4942f1b](http://github.com/katello/katello/commit/a4942f1b4bc7f0cc091d69ca4b3bf3bc632a17db))
 * hammer content-view filter rule list and info do not list arch field ([#20748](http://projects.theforeman.org/issues/20748), [aea6979c](http://github.com/katello/hammer-cli-katello/commit/aea6979c21941b10d7e136abdb413a63e0da31fa))
 * Update the help description for "--sync-date" option in hammer. ([#20613](http://projects.theforeman.org/issues/20613), [59ab7402](http://github.com/katello/hammer-cli-katello/commit/59ab74029d44befde9a0037591e3cffd493eb82f))
 * Hammer hostgroup not updating by title when katello plugin is installed ([#20433](http://projects.theforeman.org/issues/20433), [a137840f](http://github.com/katello/hammer-cli-katello/commit/a137840f12c48d759ee6edb1554cc6d905c7e7ac))
 * hammer --nondefault ignores the value passed to it and always filter out "Default Organization View" ([#19749](http://projects.theforeman.org/issues/19749), [3438db63](http://github.com/katello/katello/commit/3438db63119c7bc56c99adf359ccffcf84955582))

### Performance
 * allow system registrations to happen without waiting on tasks to complete ([#21703](http://projects.theforeman.org/issues/21703), [cd11688a](http://github.com/katello/katello/commit/cd11688ac6acc70b18a87c112ad7604997de9b4c), [f113791d](http://github.com/katello/katello-installer/commit/f113791d295974c4530a99960fa35b017e26e9e0))

### Subscriptions
 * Refreshing a manifest should no longer force regeneration of Entitlement Certificates ([#21493](http://projects.theforeman.org/issues/21493), [f79dc9dc](http://github.com/katello/katello/commit/f79dc9dc7a31ebed0a94ac7f5ef27f3dd7e3b8a2))
 * Cannot assign subscription to activation key if it doesn't provide content ([#21273](http://projects.theforeman.org/issues/21273), [b0c41a1c](http://github.com/katello/katello/commit/b0c41a1c1f46c7f44ceba6bdc065d45ce93e77de))
 * Future-dated subscriptions aren't annotated in the bulk subscriptions dialog ([#21111](http://projects.theforeman.org/issues/21111), [0f15debf](http://github.com/katello/katello/commit/0f15debf32ae82123e60846bf26dbc81a07f20a4))
 * "ERROR:  current transaction is aborted, commands ignored until end of transaction block" on katello_pools table query ([#20788](http://projects.theforeman.org/issues/20788), [4aebbb91](http://github.com/katello/katello/commit/4aebbb9191d6dff369728053ae3183dbb81c07cf))
 * Unable to list/remove or add future-dated subscriptions in individual content host view ([#20582](http://projects.theforeman.org/issues/20582), [d36a700f](http://github.com/katello/katello/commit/d36a700f62f2b0a80b9adb7e14efdc96de1cc8fc))
 * Subscriptions are not getting added via activation keys ([#19548](http://projects.theforeman.org/issues/19548), [ada82e65](http://github.com/katello/katello/commit/ada82e6549f69714a567299192c5d63e42fc6637))
 * subscription page unusable with many hosts registered ([#19394](http://projects.theforeman.org/issues/19394), [1886eef5](http://github.com/katello/katello/commit/1886eef588fc7f8a8df65fe8b59911afd1d20d54))
 * add non-green subscription status for unsubscribed_hypervisor ([#17147](http://projects.theforeman.org/issues/17147), [9deecade](http://github.com/katello/katello/commit/9deecaded9ea910986e2f4e8debf410338e25df8))
 * host registration fails during provisioning if using a limited host collection ([#21961](http://projects.theforeman.org/issues/21961), [6562474d](http://github.com/katello/katello/commit/6562474d49fc345fe0ee5d7851f548be2b15fe91))
 * SQL SELECT from Katello_subscription_facets taking too long to execute (10000ms+) ([#21928](http://projects.theforeman.org/issues/21928), [d1753454](http://github.com/katello/katello/commit/d17534544aff7b96ab047c996045763a6dcc32c2))
 * Guests of Hypervisor link not showing for guest subscriptions ([#21660](http://projects.theforeman.org/issues/21660), [c0d72eb7](http://github.com/katello/katello/commit/c0d72eb79981c215a664021bf90ef79eb2a286d2))
 * activation key link from subscription not showing activation key ([#21659](http://projects.theforeman.org/issues/21659), [8c10553e](http://github.com/katello/katello/commit/8c10553e97ef4ab3b8aff0304a5a45884e57c7b4))

### Database
 * db:seed fails if SEED_LOCATION is not defined ([#21432](http://projects.theforeman.org/issues/21432), [9f3a8eb1](http://github.com/katello/katello/commit/9f3a8eb114d56f3c7b7e67958df52f08fd5e77c7))
 * Seeding on git based setups broken ([#21071](http://projects.theforeman.org/issues/21071), [08ec387e](http://github.com/katello/katello/commit/08ec387e95aed32927846267dee6ffdc959f2fb0))
 * clean duplicate host "installed package" rows on upgrade ([#21691](http://projects.theforeman.org/issues/21691), [ed0019ad](http://github.com/katello/katello/commit/ed0019ade9670121040f793269cc87cf235f110b))
 * Scoped search definitions added by hostgroup extension should not add more relations to generic search ([#22644](http://projects.theforeman.org/issues/22644), [4cd1f63c](http://github.com/katello/katello/commit/4cd1f63c034375f5eba8d24374c441aeca1c99ec))

### Upgrades
 * On upgrade w/ 6.3, installer failed and error appears "something went wrong" though no error appeared in logs ([#21365](http://projects.theforeman.org/issues/21365), [c35df186](http://github.com/katello/katello-installer/commit/c35df186ba4a385980900a9e2044053b0c5fd845))
 * clean backend object takes a long time to run on a foreman instance with thousands of hosts ([#21569](http://projects.theforeman.org/issues/21569), [a0aeddee](http://github.com/katello/katello/commit/a0aeddee4c57cfb61ef855611e3a40c295e754f4))
 * Upgrade Step: update_subscription_facet_backend_data generate log file at non standard location (/tmp). ([#22015](http://projects.theforeman.org/issues/22015), [b6c38605](http://github.com/katello/katello/commit/b6c386051ee54a94fc8f7449400fc25b427403b6))
 * Rails 5 compatibility ([#20317](http://projects.theforeman.org/issues/20317), [2a112087](http://github.com/katello/katello/commit/2a1120872bdda964816e00fa183c7c6d31748941), [79d32bbf](http://github.com/katello/katello/commit/79d32bbf8a2bc0c8d2391186e642dde7d9f9fd5a), [9af80baf](http://github.com/katello/katello/commit/9af80baf66993377cdb314c400fdc79b6df97142), [d0798ce2](http://github.com/katello/katello/commit/d0798ce2c82d30cfe7c5f60f100ba8fd8a2b5fa1), [05a7b292](http://github.com/katello/katello/commit/05a7b292bd694b3262d9d37aa353c58a4809c179), [4bfc3867](http://github.com/katello/katello/commit/4bfc3867efa243c1fbb70c8ab9d7d0fe7afd305e), [07627d2f](http://github.com/katello/katello/commit/07627d2f934ea0541379ea5c84583cd1fcdb2b78), [8288f0b2](http://github.com/katello/katello/commit/8288f0b264f83cd0a5c4f1f0d8521a0fdb564af7), [2334beda](http://github.com/katello/katello/commit/2334beda0b41a9348cac18b306033f00a6e717cf), [0bac217b](http://github.com/katello/katello/commit/0bac217b2c2220b210d4dd5d3b68ba0be0d7a76d), [fda67090](http://github.com/katello/katello/commit/fda670909d2bd57e1130d562e5e3e622ebaca152), [841d1ada](http://github.com/katello/katello/commit/841d1ada58571242365fe19a2d2ac0b0fc2aac36), [c348873e](http://github.com/katello/katello/commit/c348873ebd86a1e34996c6a4d784441238206fc4))
 * Update failed at migrate_foreman: "can't modify frozen Array" ([#22743](http://projects.theforeman.org/issues/22743), [5c582b87](http://github.com/katello/katello/commit/5c582b87fa947826cc2f3009b401fe7237e1c69b))

### Organizations and Locations
 * Change the way how default taxonomy is derived ([#21357](http://projects.theforeman.org/issues/21357), [1832568f](http://github.com/katello/katello/commit/1832568fa5178376fb8f08b1a1ed0886bff5fb78))
 * Renaming location does not rename associated Settings ([#21363](http://projects.theforeman.org/issues/21363), [135c02a1](http://github.com/katello/katello/commit/135c02a157ff2b0559489c49d94ba5ffc07b21a8))

### Client/Agent
 * Incorrect sequence to remove the old katello agent package and certs in bootstrap.py causing error while running yum command ([#21132](http://projects.theforeman.org/issues/21132))
 * The enabled_repos_upload yum plugin is not compatible with Puppet 4 or Enterprise ([#20787](http://projects.theforeman.org/issues/20787), [156d8844](http://github.com/katello/katello-agent/commit/156d88442c07c3144a8924799d53865d33fda6a3))
 * network.hostname-override defaults to "localhost" if no fqdn set ([#20642](http://projects.theforeman.org/issues/20642), [7c0326d6](http://github.com/katello/puppet-certs/commit/7c0326d68d8232a0918e810c1a4ea31ff29ac0a1))
 * katello-agent yum-plugin enabled_repos_upload has repositories misspelled in yum output ([#20531](http://projects.theforeman.org/issues/20531), [76b8b829](http://github.com/katello/katello-agent/commit/76b8b8292e72b3bf6c5dde791b0c54630c8e6bdf))

### Sync Plans
 * When creating a sync plan, date and time are not pre-filled. ([#21049](http://projects.theforeman.org/issues/21049), [538c8f6e](http://github.com/katello/katello/commit/538c8f6ed79d9eb9bd0509fd49aee9ec71732305))
 * sync_plan['id'] missing in products#index ([#20218](http://projects.theforeman.org/issues/20218), [73629966](http://github.com/katello/katello/commit/7362996650eca2373309f0f24ba853f664a22253))
 * Docker repos with disable sync plans causes UI error ([#18036](http://projects.theforeman.org/issues/18036), [44e091af](http://github.com/katello/katello/commit/44e091af906bb3a02fc7edcea7eeaef53b5148f2))

### Candlepin
 * update candlepin to latest for 3.5 ([#21469](http://projects.theforeman.org/issues/21469))
 * Enable consistent candlepin id naming ([#19099](http://projects.theforeman.org/issues/19099), [36ef0d5b](http://github.com/katello/katello/commit/36ef0d5b419bbd3c1178084f67a227cc7735f72a))

### Host Collections
 * Can't edit host group if permission is limited to a edit_host_collections ([#21156](http://projects.theforeman.org/issues/21156), [621944d4](http://github.com/katello/katello/commit/621944d46d78e41497391bb3a1530e557f088f9c))
 * host collection index now requires organization_id ([#21150](http://projects.theforeman.org/issues/21150), [ace53d35](http://github.com/katello/hammer-cli-katello/commit/ace53d351d1830985187ffb32b96c902048a98e3), [a37f955a](http://github.com/katello/hammer-cli-katello/commit/a37f955a8c53fec979ddd2e0c6cea85ace81ceff))

### API doc
 * API Doc for content view publishing is wrong ([#20471](http://projects.theforeman.org/issues/20471), [453bf7cf](http://github.com/katello/katello/commit/453bf7cfe5a16d7c664e08175fd370c50cbd463f))

### Dashboard
 * dashboard widget data bleeds out of widget box if browser window is small ([#20338](http://projects.theforeman.org/issues/20338), [977a7c45](http://github.com/katello/katello/commit/977a7c455aa10c956c9cc1af18db1458f4af045f))
 * Clicking on links in Host collection widget redirects to 404 Page not found ([#21933](http://projects.theforeman.org/issues/21933), [472c3224](http://github.com/katello/katello/commit/472c322465ef31595e7c9a0955ab8a146f1473ae))

### SElinux
 * Installation of Katello generates denial ([#14233](http://projects.theforeman.org/issues/14233), [17700324](http://github.com/katello/katello-selinux/commit/17700324045276aa4c7ff655f19fb88fd44eb2b0))

### Roles and Permissions
 * The remote execution views in katello should require view_hosts, not edit_hosts permision ([#21794](http://projects.theforeman.org/issues/21794), [f7340d45](http://github.com/katello/katello/commit/f7340d451d19f9f8ed1878a74d569885d373ef79))

### Other
 * Don't pass AC::Params into actions ([#22306](http://projects.theforeman.org/issues/22306), [73d9bc81](http://github.com/katello/katello/commit/73d9bc81dcd726ef4ad69c214ceacf77beff82ba))
 * Support qpid_messaging 1.X ([#22238](http://projects.theforeman.org/issues/22238), [0f5aa653](http://github.com/katello/katello/commit/0f5aa6530e5edab1bea6e214e8820ad0ca70e5e4))
 * Not possible to view/edit repository: undefined method 'product' for # ([#21979](http://projects.theforeman.org/issues/21979))
 * EventQueue grows without processing events ([#21855](http://projects.theforeman.org/issues/21855), [57389c65](http://github.com/katello/katello/commit/57389c65538e68c247725886e39b91909ff325ce))
 * Depend on Bastion >= 6.1.2 for compatibility with vertical navigation ([#21709](http://projects.theforeman.org/issues/21709), [1a0d81c8](http://github.com/katello/katello/commit/1a0d81c85214136f08a738d1222da3ff9ff80fb6))
 * Move the patternfly dependencies out of devDependencies ([#21574](http://projects.theforeman.org/issues/21574), [bc3c5d99](http://github.com/katello/katello/commit/bc3c5d99743b3a9983c69dbe318828cdf4ccd28d))
 *  Search filter disappears when deleting a host. ([#21540](http://projects.theforeman.org/issues/21540), [e7bb4b81](http://github.com/katello/katello/commit/e7bb4b817b9314cfcfe667ce9428702f8f95a095))
 * Change link on “Reset Puppet Environment….” to be only on "Reset Puppet Environment" ([#21475](http://projects.theforeman.org/issues/21475), [bf4fc9a4](http://github.com/katello/katello/commit/bf4fc9a4bc374aededb97e91579767d44bea245c))
 * Allow unicode characters in certificates ([#21345](http://projects.theforeman.org/issues/21345), [a17ce3a9](http://github.com/katello/katello-installer/commit/a17ce3a92d5b0181b2ad44ecc7c0bb5eb8ba14fe))
 * Long running tasks should use Dynflow::Action::Singleton ([#21261](http://projects.theforeman.org/issues/21261), [ea51f03c](http://github.com/katello/katello/commit/ea51f03c05436c04c5f8a79c5fa8b8fce007864a))
 * Rails 5 - Replace alias_method_chain with Module prepend ([#21243](http://projects.theforeman.org/issues/21243), [a32a9be5](http://github.com/katello/katello/commit/a32a9be522015a1ef925038ca2cf94722efb6307))
 * Rails 5 - ParamsParser middleware conversion ([#21019](http://projects.theforeman.org/issues/21019), [ce312249](http://github.com/katello/katello/commit/ce3122499fef374ec4add0e0af8ae56f2194dfee))
 * Rails 5 - Resolve Katello test failures ([#21018](http://projects.theforeman.org/issues/21018), [10b1d4dd](http://github.com/katello/katello/commit/10b1d4dd903e6d8af44915352133ddd130de3105))
 * render :nothing => true deprecated in Rails 5 ([#20845](http://projects.theforeman.org/issues/20845), [018c1eba](http://github.com/katello/katello/commit/018c1ebacd8172e64a53942e18d989f8633b4573))
 * Can not extract the strings for katello.  ([#20810](http://projects.theforeman.org/issues/20810), [a59f6753](http://github.com/katello/katello/commit/a59f6753266c6c32d83a07ead7ac6d1f5e639315))
 * Visiting /smart_proxies/:id with Bastion fails 'undefined method include_plugin_styles' ([#21809](http://projects.theforeman.org/issues/21809), [652ba187](http://github.com/katello/katello/commit/652ba187a213358cad45e72a0b1633bc571782b8))
 * `foreman-rake katello:upgrades:3.0:update_puppet_repository_distributors` undefined method `mirror_on_sync?' ([#21593](http://projects.theforeman.org/issues/21593), [240848e0](http://github.com/katello/katello/commit/240848e0dbc7c9c80958ac40397de5a94ea5f0a4))
 * Incremental publish of content-view does not show packages of added errata (RHSA-2017:1679) ([#21495](http://projects.theforeman.org/issues/21495), [7a72ac86](http://github.com/katello/katello/commit/7a72ac8677204d480cd5c1891da294d6366fe9e2))
 * Fix --upgrade-puppet to handle Puppet 5 and drop all Puppet 3 upgrade options ([#21384](http://projects.theforeman.org/issues/21384), [d8895d90](http://github.com/katello/katello-installer/commit/d8895d90ad975c67cdf8b66f317de48561655c62))
 * Email notification fails for Promotion and Sync Summary  ([#21366](http://projects.theforeman.org/issues/21366), [e02ff8a4](http://github.com/katello/katello/commit/e02ff8a49f70205ff276190d831f8e0dfb6046cd))
 * Clicking on CV versions  link in Content Views widget shows 404 page not found ([#21364](http://projects.theforeman.org/issues/21364), [4736e405](http://github.com/katello/katello/commit/4736e4055cbe93d970b73c2d3f62f3f644baac24))
 * check path includes sbin in katello scripts ([#21348](http://projects.theforeman.org/issues/21348), [8b7b45d6](http://github.com/katello//commit/8b7b45d69fcb33379425c70578faa81642849cf7))
 * PG::Error: missing FROM-clause entry from items in Dashboard for Filtered role ([#21254](http://projects.theforeman.org/issues/21254), [77f0d59d](http://github.com/katello/katello/commit/77f0d59d6dc358be0e7ae1551dc98242a62de8f3))
 * foreman-proxy-content answer migration misses the clear mappings migration ([#21233](http://projects.theforeman.org/issues/21233), [ed3ddfc0](http://github.com/katello/katello-installer/commit/ed3ddfc076b8e00b0e13ad92ebad8704e12f321a))
 * name field not clickable after opening resource switcher ([#21035](http://projects.theforeman.org/issues/21035), [3e8b0796](http://github.com/katello/bastion/commit/3e8b07964f3066d77575e1821fbdac83180cda59))
 * Update installation media paths in k-change-hostname ([#20987](http://projects.theforeman.org/issues/20987), [f1418fc0](http://github.com/katello//commit/f1418fc08a9f2614b0f136bde6469328f0b6bf34))
 * katello-change-hostname should print command output when it errors out. ([#20984](http://projects.theforeman.org/issues/20984), [a727125b](http://github.com/katello//commit/a727125bb492abdf14c9eb10c39e8d67d9864cf9))
 * k-change-hostname can mix up internal capsule names ([#20983](http://projects.theforeman.org/issues/20983), [b1a9d445](http://github.com/katello//commit/b1a9d44581e7e93131c8cadfe04cb0b2d32b2346))
 * clean_installed_packages script logs a count(*), causing slow performance ([#20946](http://projects.theforeman.org/issues/20946), [cc0b15fb](http://github.com/katello/katello/commit/cc0b15fb330178aca8317873eaaf2ef1b280d1d7))
 * k-change-hostname will check for exit code on a skipped command on a foreman-proxy ([#20944](http://projects.theforeman.org/issues/20944), [d32d5854](http://github.com/katello//commit/d32d5854c167efa0bf2dc02fa5ceceb07f2eff71))
 * upgrades no longer need to configure pulp oauth ([#20907](http://projects.theforeman.org/issues/20907), [456d35e1](http://github.com/katello/katello-installer/commit/456d35e1c812981966e58f2bb4eb99cb68dac4d7))
 * Don't consider localhost as valid host name when parsing rhsm facts ([#20816](http://projects.theforeman.org/issues/20816), [2060454b](http://github.com/katello/katello/commit/2060454b1b7305136fcf43dc75e040ec328829b0))
 * Katello redhat extension tests intermittently fail ([#20795](http://projects.theforeman.org/issues/20795), [ea6d4b56](http://github.com/katello/katello/commit/ea6d4b56c14ba6fe5acf40d4f4d5984833f0fb07))
 * Kickstart repository assigned in UI to hostgroup difficult to set using Hammer ([#20785](http://projects.theforeman.org/issues/20785), [81410e9e](http://github.com/katello/katello/commit/81410e9e377d463ec717d113608692c572f93b3c))
 *  POST /api/hosts/bulk/applicable_errata API doc has incorrect URL pointing to installable_errata.html ([#20478](http://projects.theforeman.org/issues/20478), [4ca55e14](http://github.com/katello/katello/commit/4ca55e14424e16adff4ef5764cc8f30868214421))
 * Remove RHEL6 support in katello-change-hostname ([#20463](http://projects.theforeman.org/issues/20463), [45417cf6](http://github.com/katello//commit/45417cf61d90a5c862f8fb9b1a4ede81c543b297))
 * New container wizard does not store state of Katello image (step 2) ([#16509](http://projects.theforeman.org/issues/16509), [893d7cde](http://github.com/katello/katello/commit/893d7cdec1d74f6343766ec2ac6e5375318d67c6))
 * Handle autosign file with puppet 4 ([#22249](http://projects.theforeman.org/issues/22249), [95fa0307](http://github.com/katello/katello-installer/commit/95fa0307c123314d5589cd9af08f2def6be8f69c))
 * Docker Image tags are missing after upgrading the katello server. ([#22230](http://projects.theforeman.org/issues/22230), [e7271788](http://github.com/katello/katello/commit/e7271788929064baed059fa54fedbaa20298eac3), [c9f6b8ca](http://github.com/katello/katello-installer/commit/c9f6b8ca1c6a685051f7263b0c9cd16efbcf8693))
 *  Pagination issue: "Next Page" and "Last Page" options are not working on the "Errata" tab for content host. ([#22134](http://projects.theforeman.org/issues/22134), [08077241](http://github.com/katello/bastion/commit/08077241c8055a0c74924278b6b64de764d0b72c), [cb782a48](http://github.com/katello/bastion/commit/cb782a48d8fb1368a1e481e22b8ce6c2fa6f5d60))
 * Could not resolve packages from state 'content-view.repositories.yum.list' ([#21788](http://projects.theforeman.org/issues/21788), [1bca4e4d](http://github.com/katello/katello/commit/1bca4e4d2b7b06a7baf30b21e09a8a44754f55f1))
 * Error PulpNode not found when visiting SmartProxy ([#21667](http://projects.theforeman.org/issues/21667), [a89c0bb7](http://github.com/katello/katello/commit/a89c0bb776fb4481d48b0ae8ff85e7a9047710fa))
 * Katello should send the correct Tracer helpers to RemoteEX ([#21572](http://projects.theforeman.org/issues/21572), [fb68d6ad](http://github.com/katello/katello/commit/fb68d6adbe44afe1f628b9114866cdd0f58af6d5))
 * virt-who cant talk to foreman anymore  ([#21110](http://projects.theforeman.org/issues/21110))
 * Make RHSM facts compatible with fact name filtering ([#22894](http://projects.theforeman.org/issues/22894), [7346b4dc](http://github.com/katello/katello/commit/7346b4dc00d1e3839ca8cf02d63859f29d5c980e))
 * concurrent registration occasionally fails with "host_id has already been taken" error ([#22850](http://projects.theforeman.org/issues/22850), [0012f360](http://github.com/katello/katello/commit/0012f360e317485c658ba3fb9fa4c13a39f6cf4c))
# 3.6.0 Imperial IPA (2018-02-16)

## Features 

### Content Views
 * ISO repositories not published to correct path ([#22446](http://projects.theforeman.org/issues/22446), [9c93fadc](http://github.com/katello/katello/commit/9c93fadc85b7fd58e033ba29623393fe9d606d65), [ef10bf44](http://github.com/katello/katello-installer/commit/ef10bf44def31dd8e74a0a9a17808822ba0f096e))
 * Rake task needed to clean up repos published to wrong directory ([#22293](http://projects.theforeman.org/issues/22293), [c3833708](http://github.com/katello/katello/commit/c383370802f9362aafb35233af9ccc026d899d8b))
 * [RFE] Component view versions for composite content views ([#18228](http://projects.theforeman.org/issues/18228), [ab643413](http://github.com/katello/katello/commit/ab6434137082ba219f6acb6974aee1214dcc8e08))

### Repositories
 * Add cp_label into API output ([#22385](http://projects.theforeman.org/issues/22385), [ee0fb7f1](http://github.com/katello/katello/commit/ee0fb7f14a04484afdbe91291d4e45adac114da1))
 * Experimental UI : Red Hat Repositories - add basic page layout ([#21644](http://projects.theforeman.org/issues/21644), [0c386f20](http://github.com/katello/katello/commit/0c386f20de9810f9f545db7af358fe0667a17ed7))
 * As a user, I want to list all repository sets for an organization. ([#19925](http://projects.theforeman.org/issues/19925), [a88bd055](http://github.com/katello/katello/commit/a88bd05558a512392eb1b8a7774b5cf38b0fef21))
 * Add help text to new repository Download Policy ([#19199](http://projects.theforeman.org/issues/19199), [a008356d](http://github.com/katello/katello/commit/a008356d21c206caee9264c30a2b8be4ba4f4460))

### API
 * As an API user, I should be able to retrieve GPG Key content that may not be associated with a Repository. ([#21995](http://projects.theforeman.org/issues/21995), [5382d429](http://github.com/katello/katello/commit/5382d4296f4420bea899d7a518488966c0cc2114))
 * As an API user, I should be able to compare the Errata of a Content View Version to the Errata in Library. ([#21568](http://projects.theforeman.org/issues/21568), [f38cc3f4](http://github.com/katello/katello/commit/f38cc3f4472fa4a82db77befffd5bee7af2f9e03))

### Web UI
 * RH repos: visual improvements ([#21954](http://projects.theforeman.org/issues/21954), [e447a675](http://github.com/katello/katello/commit/e447a675fa9696d67bd6d29ee11a1c2f1125c61f))
 * Add react-storybook ([#21931](http://projects.theforeman.org/issues/21931), [13b438b1](http://github.com/katello/katello/commit/13b438b13726cfdb81e9f130fc289d8b09e5905d))
 * Red Hat Repositories: get API client working ([#21646](http://projects.theforeman.org/issues/21646), [380a5bc6](http://github.com/katello/katello/commit/380a5bc6ff66d3fe6adca59e8bd242323175c9c6))
 * Add katello icons for veritcal navigation ([#21141](http://projects.theforeman.org/issues/21141), [7ef4d0cb](http://github.com/katello/katello/commit/7ef4d0cba21d867581bafdf875e366d874c0cefc))
 * Get react scaffolding in place for katello ([#21009](http://projects.theforeman.org/issues/21009), [fb2433d8](http://github.com/katello/katello/commit/fb2433d8c3916d6c22c4b98db0052fb430b5c094))
 * make the "Type" of a subscription a searchable unit ([#20979](http://projects.theforeman.org/issues/20979), [456b3858](http://github.com/katello/katello/commit/456b38584d44fbd3097087aa1276bb5bf010cdea))
 * Add setting to toggle experimental UI ([#20716](http://projects.theforeman.org/issues/20716), [50c3f55e](http://github.com/katello/katello/commit/50c3f55ed547646bc54b0c16b97d94bd0832e27e))

### Installer
 * Enable import of product content through katello installer ([#21936](http://projects.theforeman.org/issues/21936), [a0374949](http://github.com/katello/katello-installer/commit/a03749491f344458a5b52acadcf21526c66b7c65))
 * Use a different oauth for Pulp & Candlepin ([#20879](http://projects.theforeman.org/issues/20879))
 * ablity to configure Katello post_sync_url setting other than fqdn ([#20857](http://projects.theforeman.org/issues/20857), [451530b0](http://github.com/katello/puppet-katello/commit/451530b0b161d41ab09f10333f3e849c82cda70d))
 * Need additional supported database deployment options for Katello installation: such as External Postgres ([#19667](http://projects.theforeman.org/issues/19667), [51ca4090](http://github.com/katello/puppet-candlepin/commit/51ca40909f7ae82bf06f0571df673397daa56201), [65f55250](http://github.com/katello/katello-installer/commit/65f55250856162ee7fd8b4e29e1ad78074e8c866), [04ebdba2](http://github.com/katello/puppet-katello/commit/04ebdba2f334862cfd463a6396e652873eb3e471))

### Docker
 * content view filter needs to be able to work with docker manifest list ([#21388](http://projects.theforeman.org/issues/21388), [aecabf21](http://github.com/katello/katello/commit/aecabf212b6c340240c05dd798411657c17cf565))
 * Add UI Bindings for the Docker Manifest List ([#21291](http://projects.theforeman.org/issues/21291), [14128f7d](http://github.com/katello/katello/commit/14128f7d6002733c3f2c4ae9c8e60da0bcab2d3f))
 * Add Model Bindings for Docker Manifest List ([#21290](http://projects.theforeman.org/issues/21290), [14128f7d](http://github.com/katello/katello/commit/14128f7d6002733c3f2c4ae9c8e60da0bcab2d3f))

### Roles and Permissions
 * Please provide a Pre-made role for registration-only usage ([#21307](http://projects.theforeman.org/issues/21307), [f70a69f3](http://github.com/katello/katello/commit/f70a69f3c09b9435fb833a7212b46cedf69c0f9b))

### Hammer
 * hostgroup create/update doesn't support --content-source ([#18743](http://projects.theforeman.org/issues/18743), [6fad377a](http://github.com/katello/hammer-cli-katello/commit/6fad377a53f4e3160e20313eca29805d82a4f5cb))
 * Show an option to which capsule the client is registered to through hammer ([#20791](http://projects.theforeman.org/issues/20791))

### Sync Plans
 * [RFE] hammer sync-plan info should show associated products ([#17155](http://projects.theforeman.org/issues/17155), [3ed6cee9](http://github.com/katello/hammer-cli-katello/commit/3ed6cee9c511558c250e713224d0d2e728625b16))

### Subscriptions
 * Upgrade to Candlepin 2.1 ([#20792](http://projects.theforeman.org/issues/20792))

### Hosts
 * set release version of a content host via bulk action ([#20583](http://projects.theforeman.org/issues/20583), [42a3a9c1](http://github.com/katello/katello/commit/42a3a9c17e53752dab573c74fb8c1bbc9a59c72b))

### Candlepin
 * As a user, i would like to restrict a certain repo to one or more arches. ([#5477](http://projects.theforeman.org/issues/5477), [b02526be](http://github.com/katello/katello/commit/b02526bea7026560b2d6d66fac9038cfeb74bab9))

### Other
 * Use patternfly Spinner component ([#21982](http://projects.theforeman.org/issues/21982), [732a8983](http://github.com/katello/katello/commit/732a89831b770db4b7d43964fb2c8cafcfc65350))
 * Cache product content from Candlepin in Katello ([#21680](http://projects.theforeman.org/issues/21680), [946b2990](http://github.com/katello/katello/commit/946b2990c9a054babc9ad563e1b14c4161207b3e))
 * Turn on eslint in the .hound.yml ([#21575](http://projects.theforeman.org/issues/21575), [ddc77314](http://github.com/katello/katello/commit/ddc77314b5a78bd579c662cb2e6dd62eb467c513))
 * Remove pulp oauth support ([#21464](http://projects.theforeman.org/issues/21464), [d6942759](http://github.com/katello/katello/commit/d6942759f4021d92ae628e5050fed948b84a1626), [af1081f2](http://github.com/katello/puppet-katello/commit/af1081f2ab056f2a988b1caac4bbc9a082f81139), [94872522](http://github.com/katello/puppet-foreman_proxy_content/commit/9487252216c19ab1e656ed5cb24195e51f4cfe30), [a724f196](http://github.com/katello/katello-installer/commit/a724f19636871c8540ebe9ca40b0cec8a0820bad), [5cdea23c](http://github.com/katello/katello-installer/commit/5cdea23cb7bcd1d792dc65cd185855aa78d01411))
 * Support Experimental UI Routes (prefixed with `xui`) ([#21277](http://projects.theforeman.org/issues/21277), [4cb1be28](http://github.com/katello/katello/commit/4cb1be28aa04c7fdabac0b82ae956c091dee8e2c))
 * Specify "X-Correlation-ID" header for log correlation when making REST calls to Candlepin ([#20488](http://projects.theforeman.org/issues/20488), [24a58d78](http://github.com/katello/katello/commit/24a58d78b180e7456ec2c7e95466bab883ffb9c9))
 * CSV export on Content Host page ([#19954](http://projects.theforeman.org/issues/19954), [6362c738](http://github.com/katello/katello/commit/6362c738f721131630c8b0a317c4040e39e53b92))

## Bug Fixes 

### Tests
 * Rubocop can fail when there is ruby inside node_modules/ ([#22494](http://projects.theforeman.org/issues/22494), [76ecc59f](http://github.com/katello/katello/commit/76ecc59fa39e2c373c797bd6337b387a5c2d3822))
 * Test failure on Rails 5.1 ([#22073](http://projects.theforeman.org/issues/22073), [91b7adcf](http://github.com/katello/katello/commit/91b7adcf2425a3218a2629899f0954aa094be96e))
 * Update rubocop 0.51 -0.52 ([#22035](http://projects.theforeman.org/issues/22035), [5f047b65](http://github.com/katello/katello/commit/5f047b6520a39409f26761ff6820d41516754e71))
 * update to rubocop 0.51.0 ([#21467](http://projects.theforeman.org/issues/21467), [d0ded38d](http://github.com/katello/katello/commit/d0ded38d6e457a2b51ac76a465f17bcb81dd864c))
 * sync plans controller test is testing the wrong action ([#21466](http://projects.theforeman.org/issues/21466), [464b4787](http://github.com/katello/katello/commit/464b4787e66585365b8b4f4a1737cb52e15414dd))
 * No more factory_girl_rails ([#21458](http://projects.theforeman.org/issues/21458), [acf238d0](http://github.com/katello/katello/commit/acf238d07f7d0a062d8512328566dd83c892f005), [7a8b048f](http://github.com/katello/katello/commit/7a8b048f46d99fbe71f135677bbcbe838de8a228))
 * NameError: uninitialized constant Katello::Host::HostInfo  during engine load ([#20234](http://projects.theforeman.org/issues/20234), [4cc182fc](http://github.com/katello/katello/commit/4cc182fc474cd5f8caf0e77d195e6a7e04bd33b6), [564ca702](http://github.com/katello/katello/commit/564ca702668f6ec2df0ee4588291306f1c249c03))
 * Fix tests after create and edit permissions started to be enforced ([#20135](http://projects.theforeman.org/issues/20135), [259e113f](http://github.com/katello/katello/commit/259e113fee2d64a13ab4170cc943c1d5b5d87147))
 * Fix tests for sprockets-rails 3.x ([#20122](http://projects.theforeman.org/issues/20122), [0845021d](http://github.com/katello/katello/commit/0845021d7bd08d7ab0ccf43f5912a96bde649abc), [18d296d7](http://github.com/katello/katello/commit/18d296d7d37e8136fec25442100797fadf4c4609))
 * upgrade to rubocop 0.49.1 ([#19931](http://projects.theforeman.org/issues/19931), [70972aae](http://github.com/katello/katello/commit/70972aaee4cbf10d91a505a051971deb0dffc494))
 * Undefined method 'split' for nil on several tests ([#19741](http://projects.theforeman.org/issues/19741), [885e3f2e](http://github.com/katello/katello/commit/885e3f2e487a99dd0cdc5948d3e4353ec4cd382f), [108f9919](http://github.com/katello/katello/commit/108f99198f1aa9368d785a4401fb066fca69f378))
 * hound ci doesn't recognize nested .rubocop.yaml files ([#19674](http://projects.theforeman.org/issues/19674), [ed1373f4](http://github.com/katello/katello/commit/ed1373f43fd69be5700879d8bd493376c3766b4f))
 * duplicate code in test/actions/pulp/repository/* files  ([#19434](http://projects.theforeman.org/issues/19434), [e9cceccc](http://github.com/katello/katello/commit/e9cceccc3017ad4491c4a1a371015d33c696652d))
 * transient test failure ([#19351](http://projects.theforeman.org/issues/19351), [b3bc464b](http://github.com/katello/katello/commit/b3bc464b7a8ae2a15682a126f181e7edd1770134))
 * Tests relying on stubbing settings must be updated for external auth source seeding ([#19174](http://projects.theforeman.org/issues/19174), [e97a3d3c](http://github.com/katello/katello/commit/e97a3d3c7c1e0eecd45ab469cb87f5330d575219))

### Installer
 * [ RFE ] add mgmt-pub param to qpidd.conf ([#22465](http://projects.theforeman.org/issues/22465), [e1ce860f](http://github.com/katello//commit/e1ce860fc3f95dc62630e47bf59f10e84da6393c))
 * Workers go missing under heavy load ([#22338](http://projects.theforeman.org/issues/22338), [84c00335](http://github.com/katello/puppet-pulp/commit/84c0033586861c5f165da9004c1e3e24d0165908), [525639b7](http://github.com/katello/puppet-foreman_proxy_content/commit/525639b7c7de6fcbe2a154faba4b7bda39971fc4), [00822e57](http://github.com/katello/puppet-katello/commit/00822e571bcb46b86554daed1bdb2ce5fa836438))
 * [RFE] Add an option to change value of "rest_client_timeout" present in /etc/foreman/plugins/katello.yaml ([#22200](http://projects.theforeman.org/issues/22200), [3df2fa40](http://github.com/katello/puppet-katello/commit/3df2fa40ff987c510aa45f5cb56c5200e8c07052))
 * Unclear error message when forward IP does not reverse resolve ([#22173](http://projects.theforeman.org/issues/22173), [814d70b0](http://github.com/katello/katello-installer/commit/814d70b0a70076ec5c3086307cbde55e5c6dea82), [d493c6d4](http://github.com/katello/katello-installer/commit/d493c6d49298df9f80168896f4baefa12fd50540))
 * pulp_ostree.conf should redirect gpgkey info ([#21957](http://projects.theforeman.org/issues/21957), [5ff7611c](http://github.com/katello/puppet-pulp/commit/5ff7611c6e577b95f5a3f096830c4e3097c4db2d))
 * [RFE] print warning if capsule-certs-generate --capsule-fqdn is same as satellite server's hostname ([#21873](http://projects.theforeman.org/issues/21873), [87bf159a](http://github.com/katello/puppet-certs/commit/87bf159a9e481feeccbd9ee43735776ac1c8a127), [42583cea](http://github.com/katello/puppet-certs/commit/42583cea92405c6d83d3c6937bf360ff9936b780))
 * limit puppet pulp wsgi processes to 1 on foreman smart proxy with content ([#21430](http://projects.theforeman.org/issues/21430), [0e9afcba](http://github.com/katello/puppet-foreman_proxy_content/commit/0e9afcbaf2fdbace68b2d4c43016a604ed8c563d))
 * `open': Not a directory - /var/lib/qpidd/.qpidd/qls/jrnl/<something> (Errno::ENOTDIR) ([#21268](http://projects.theforeman.org/issues/21268), [b7a1898a](http://github.com/katello/katello-installer/commit/b7a1898a046d8734aa2d983a060de28f08a43edc))
 * Re-factor installer success messages ([#21060](http://projects.theforeman.org/issues/21060), [0bab4634](http://github.com/katello/katello-installer/commit/0bab463495978de8d9661115b7ebd759921962ef), [b6916c99](http://github.com/katello/katello-installer/commit/b6916c99f777973db438184198e8ba361ecd223f))
 * upgrade to satellite 6.3 beta wont work if ssl.conf is missing ([#21708](http://projects.theforeman.org/issues/21708), [549cf61e](http://github.com/katello/katello-installer/commit/549cf61e81935afa5755faf065fe8c2c37298a2f))
 * Chef smart proxy plugin not present in katello scenario's answer file ([#21498](http://projects.theforeman.org/issues/21498), [375df41d](http://github.com/katello/katello-installer/commit/375df41d63fc9c8fa445ae0bf3e4f83bfc325581))
 *  undefined method `puppet5_installed?' from installer ([#21471](http://projects.theforeman.org/issues/21471), [505d1df5](http://github.com/katello/katello-installer/commit/505d1df5f8ebe5a6d83a127063601288fa0dc5ee))
 * Can't upgrade Puppet 3 to Puppet 4 on Capsule ([#21321](http://projects.theforeman.org/issues/21321), [3fa59d32](http://github.com/katello/katello-installer/commit/3fa59d3219f64bc0e31691b8a65f9af9629f81ec))
 * --upgrade-puppet doesn't migrate environments in the correct location ([#21248](http://projects.theforeman.org/issues/21248), [8005830a](http://github.com/katello/katello-installer/commit/8005830a6bc9d6168664263871fd57bc2176ef1e))
 * capsule-certs-generate throws errors for puppet-agent and puppetserver not installed ([#21222](http://projects.theforeman.org/issues/21222), [0dda24c8](http://github.com/katello/katello-installer/commit/0dda24c82882e1086d34a4bc4bb12d6da2c18948))
 * katello-proxy-* values in satellite-answers.yaml no longer support empty quoted entries ([#21217](http://projects.theforeman.org/issues/21217), [126decf5](http://github.com/katello/katello-installer/commit/126decf538c890a534ed472390e217d33bb2ae8a))
 * capsule-certs-generate throws NoMethodError post migration to 6.3 ([#21138](http://projects.theforeman.org/issues/21138), [4d25f6d8](http://github.com/katello/katello-installer/commit/4d25f6d8f3ca810d61e2fa18e3b6698cc1f13828))
 * capsule-certs-generate --certs-tar does not accept relative path ([#21128](http://projects.theforeman.org/issues/21128), [d3dd4190](http://github.com/katello/katello-installer/commit/d3dd4190fca86402d5036c45ce85b2c714e3f59d))
 * puppet-pulp uses enable instead of enabled in profiling ([#20865](http://projects.theforeman.org/issues/20865), [87cd4e5f](http://github.com/katello/puppet-pulp/commit/87cd4e5fa92e5970dd1ed5f8017dc26ce15a2905))
 * change import subscriptions to a more general task ([#20587](http://projects.theforeman.org/issues/20587), [0b522e50](http://github.com/katello/katello-installer/commit/0b522e50896499d91498eb5faee5ca16c1a0496a))
 * --foreman-proxy-templates is not enabled by default ([#19720](http://projects.theforeman.org/issues/19720), [330b238c](http://github.com/katello/katello-installer/commit/330b238cdbe16a2e43f85042e004f6b9cfc58870))
 * katello_devel missing from parser cache ([#19601](http://projects.theforeman.org/issues/19601), [52e7e64e](http://github.com/katello/katello-installer/commit/52e7e64ea0dfc946e0a83c8de1fa9f9e1d8dec3e))
 * foreman-installer deploys a non-working "qdrouterd.conf " after qpid-dispatch-router has been upgraded from 0.8.0-1.el7 to 1.0.0-1.el7 in epel repos ([#22289](http://projects.theforeman.org/issues/22289), [6a045064](http://github.com/katello//commit/6a0450649716c317437c8e612fda2459fba8dd27), [d1155d5f](http://github.com/katello/puppet-foreman_proxy_content/commit/d1155d5f5405d23164ad0cb13580beb75bf98873))
 * katello does not set Xmx setting in tomcat.conf, leading to possible OOMs ([#18146](http://projects.theforeman.org/issues/18146), [da68e6b3](http://github.com/katello/puppet-candlepin/commit/da68e6b351b03f8648bfc436f2d3fbd6069a15bd))

### Backup & Restore
 * Bypass validation using confirmation flag ([#22447](http://projects.theforeman.org/issues/22447))
 * Add warning/confirmation to snapshot backup ([#22418](http://projects.theforeman.org/issues/22418))
 * change name for installer suggestion in hostname change ([#21492](http://projects.theforeman.org/issues/21492), [86466b71](http://github.com/katello//commit/86466b716f63c0493576e29e9a639252a55c2cc8))
 * change name of katello-change-hostname to be easily overwritten ([#21220](http://projects.theforeman.org/issues/21220), [765b6400](http://github.com/katello//commit/765b64003d26ab58a98a93d5b11e7377ee6b655f))
 * no output on foreman rpm installed check for katello scripts ([#21219](http://projects.theforeman.org/issues/21219), [b479d7f0](http://github.com/katello//commit/b479d7f090b08107d79251af277191d627d38b96))
 * cleanup snapshots if backup fails ([#21198](http://projects.theforeman.org/issues/21198), [123c4326](http://github.com/katello//commit/123c43268669806b73e11a21f5e70448d81461b2))
 * katello-backup fails with /usr/share/ruby/fileutils.rb:125: warning: conflicting chdir during another chdir block ([#21183](http://projects.theforeman.org/issues/21183), [5b7de1e0](http://github.com/katello//commit/5b7de1e00753001ff2be0007d85f763482e10542))
 * katello-backup does not backup custom certificates and need to ensure katello-restore restores them ([#21270](http://projects.theforeman.org/issues/21270), [e1b76c02](http://github.com/katello//commit/e1b76c02654747389de0d19979cc2b28554225c4))
 * Disable system checks by default on katello scripts ([#21221](http://projects.theforeman.org/issues/21221), [be2b07f6](http://github.com/katello//commit/be2b07f6c97f7bff223748a5d66d1879394cf421))

### Provisioning
 * Add missing katello_default_PXEGrub and katello_default_PXEGrub2 settings ([#22337](http://projects.theforeman.org/issues/22337), [a3954cc7](http://github.com/katello/katello/commit/a3954cc77a846ff261ce717088b03253224a9d7c))
 * Prefetch vmlinuz and initrd on sync ([#22318](http://projects.theforeman.org/issues/22318), [23a9557a](http://github.com/katello/katello/commit/23a9557a7cf3820aa96a571f29179dee9031ee06))
 * Default templates use deprecated @host.params ([#22142](http://projects.theforeman.org/issues/22142), [3770303d](http://github.com/katello/katello/commit/3770303d9276a63a56cbac1ee678ffe5da0cdcc3))

### Lifecycle Environments
 * 'Errata ID' hyperlink on Lifecycle Environments -> Errata page is broken ([#22263](http://projects.theforeman.org/issues/22263), [894e8b07](http://github.com/katello/katello/commit/894e8b072a74890b9e7a59775e89763dc476b7ee))

### Web UI
 *  Filtering by repository is not working in Packages/Errata/OSTree view ([#22241](http://projects.theforeman.org/issues/22241), [96f528a5](http://github.com/katello/katello/commit/96f528a5a553ad01c924f02e8be8eb5b0b55d373))
 * 'Select Organization' dialog only showing first 20 organizations ([#21719](http://projects.theforeman.org/issues/21719), [d645f310](http://github.com/katello/katello/commit/d645f310e69cda076aed57ff8daec6127ba1d5ae))
 * Sync Status progress bar does not work ([#21711](http://projects.theforeman.org/issues/21711), [0db15ab6](http://github.com/katello/katello/commit/0db15ab69e062c8f507b019da0ca334bee6f59df))
 * Add patternfly-react to katello package.json ([#21562](http://projects.theforeman.org/issues/21562), [a46c45de](http://github.com/katello/katello/commit/a46c45de28b4de0f82240e30c4b89cde0b5a21f9))
 * content sub menu missing sub-headers on vertical nav ([#21385](http://projects.theforeman.org/issues/21385), [8324c9a1](http://github.com/katello/katello/commit/8324c9a1e5a0088e5f382d0c036c68aeb3b4bf3d))
 * content view filter repository selection table doesn't reflect correct selected count ([#21284](http://projects.theforeman.org/issues/21284), [64253012](http://github.com/katello/katello/commit/642530128bf38809bcc8500369ceb6af0bd5d359))
 * paged list on repo discovery shows too many per page ([#21258](http://projects.theforeman.org/issues/21258), [e54bf63c](http://github.com/katello/katello/commit/e54bf63c2cdd910c044d06fb3b67ab32e3026d2f))
 * Incorrect Next Sync date calculation in weekly Sync Plan ([#21194](http://projects.theforeman.org/issues/21194), [89fcecb8](http://github.com/katello/katello/commit/89fcecb85d22ba65e39725d403f519791b19cd98))
 * Smart proxy labels should be bold ([#20659](http://projects.theforeman.org/issues/20659), [884dc3fe](http://github.com/katello/katello/commit/884dc3fef4fc31ec136c6ab52dda9e0c6e3f6700))
 * Clicking on the arrow icon on an Errata Details page does not show the other errata items ([#21481](http://projects.theforeman.org/issues/21481), [245d748c](http://github.com/katello/katello/commit/245d748cd533afceef04e0a25127da5b23776f2e))
 * New Host Synced Content Radio Button disabled  ([#21185](http://projects.theforeman.org/issues/21185), [9cb59baa](http://github.com/katello/katello/commit/9cb59baadbcf65996898115eda2343c61970ae4e))
 * Missing HTML title on "Content Hosts" page ([#20988](http://projects.theforeman.org/issues/20988), [ac25cd85](http://github.com/katello/katello/commit/ac25cd85a394a9124875d90fabbee2eed3af047f))
 * All item pages should be using id instead of uuid ([#20747](http://projects.theforeman.org/issues/20747), [d0f2a68d](http://github.com/katello/katello/commit/d0f2a68d79a1cc46175f2a660cfeb8531b83d016))
 * sprockets 3.x requires SCSS assets to use .scss ([#20544](http://projects.theforeman.org/issues/20544), [aaa18733](http://github.com/katello/katello/commit/aaa187330ec26188b25b6d6d64f7bbb2471950d7))
 * Katello can't use relocated URI ([#20313](http://projects.theforeman.org/issues/20313), [db51fdac](http://github.com/katello/katello/commit/db51fdacfc8ee414183552e03581da0e4175eec5), [5c30cb34](http://github.com/katello/katello/commit/5c30cb34202a0d5a2407c4f4f56ecf1d7eced1a4), [d45cc374](http://github.com/katello/katello/commit/d45cc374af4cf72009ebbd0d69b9edfb1fb48174))
 * Disable repository set on activation key repeatedly returns repositories ([#20057](http://projects.theforeman.org/issues/20057), [2c8fc1ea](http://github.com/katello/katello/commit/2c8fc1eaec7029c4feb1e18db4a62a0e20234682))

### API
 * activation key repo sets fails with error  wrong number of arguments (given 0, expected 1) ([#22240](http://projects.theforeman.org/issues/22240), [9da1e12c](http://github.com/katello/katello/commit/9da1e12c7c2d93275862945d17d2e62f032fadec))
 * API endpoint for auto_attach/remove/add subscription in host bulk action is incorrect ([#21923](http://projects.theforeman.org/issues/21923), [d09f0730](http://github.com/katello/katello/commit/d09f0730d5c57519a45db20a352201fc06c39b61))
 * As per API v2 documentation for <server_url>/apidoc/v2/packages.html | GET /katello/api/compare is not working ([#19304](http://projects.theforeman.org/issues/19304), [dc49f7e4](http://github.com/katello/katello/commit/dc49f7e403a9691503b400671f1355ef8e69d175))
 * ISE on Errata API list call when using invalid sort by name ([#21525](http://projects.theforeman.org/issues/21525), [2e39affb](http://github.com/katello/katello/commit/2e39affb47849ebd42f6974892e7618ed6c5dbd5))
 * hammer order option has no effect ([#20579](http://projects.theforeman.org/issues/20579), [3605d81f](http://github.com/katello/katello/commit/3605d81f838a624f22fe289c652a17f2f72b51fa))
 * organization_id should be a top level attribute in the API ([#20219](http://projects.theforeman.org/issues/20219), [f8008f09](http://github.com/katello/katello/commit/f8008f09aa7cc1f2d05d268e2fa58b0ab7564a72))
 * [V2] Regression in content view API ([#22180](http://projects.theforeman.org/issues/22180), [062a73e0](http://github.com/katello/katello/commit/062a73e039eb62fb60e1c9e5c140ba4ebefc0c80))

### Activation Key
 * notification shows an error indicator when adding a subscription to an activation key ([#22195](http://projects.theforeman.org/issues/22195), [953ad8ce](http://github.com/katello/katello/commit/953ad8ce9507c8bdbc855d720fd99f1abc698db2))
 * content-override done by hammer has no effect when using AK ([#21275](http://projects.theforeman.org/issues/21275), [fe18baf2](http://github.com/katello/hammer-cli-katello/commit/fe18baf2dbffad45e47b54f265329f0f31abde5f))

### Hosts
 * Date format of published content view in yaml output changed on Rails 5.x and causes Puppet runs to fail ([#22186](http://projects.theforeman.org/issues/22186), [ac81226e](http://github.com/katello/katello/commit/ac81226e3da738fefefd47a8fc5daa5d029b18ba))
 * Fix tests to support fact importer transaction check ([#21880](http://projects.theforeman.org/issues/21880), [2bd734ef](http://github.com/katello/katello/commit/2bd734efdc8d10a81dba877bc940f08e97d18f56))
 * Can't register content host ([#21438](http://projects.theforeman.org/issues/21438), [3ab3dae5](http://github.com/katello/katello/commit/3ab3dae52b875debabaab1a6bbe64b854d46cf68))
 * Registered date value for content hosts in webUI is empty ([#21235](http://projects.theforeman.org/issues/21235), [57cfe796](http://github.com/katello/katello/commit/57cfe796fdef58da8531bc5ab62dc1381a752f3d))
 * “Unregister Host” needs a clear instruction for options under it ([#21051](http://projects.theforeman.org/issues/21051), [1875ec2a](http://github.com/katello/katello/commit/1875ec2a5ae628fb4f28ea1cb91ebd0501c87314))
 * Katello loads hosts controller before other plugins can extend the API ([#21382](http://projects.theforeman.org/issues/21382), [b1d44bc4](http://github.com/katello/katello/commit/b1d44bc45434f04b075477ff439df7ec8cc40577))
 * Add db index on "katello_content_facet_errata"  "content_facet_id" ([#21282](http://projects.theforeman.org/issues/21282), [42f5d95a](http://github.com/katello/katello/commit/42f5d95a05c9cf1cc0ee19c92f72e9f088eb58e9))
 * Missing 'Content Source' output in `hammer host info` ([#21057](http://projects.theforeman.org/issues/21057), [fe2d9c37](http://github.com/katello/hammer-cli-katello/commit/fe2d9c37bddb207c7688ce5e7d74fd2a08920dee))
 * Unable to update host's content source via hammer ([#21016](http://projects.theforeman.org/issues/21016), [b4cacd27](http://github.com/katello/katello/commit/b4cacd2784748480f7d354450011ba2266fcad6f))
 * Content Host Installable Errata show wrong icons color when 0 applicable ([#20714](http://projects.theforeman.org/issues/20714), [68732d64](http://github.com/katello/katello/commit/68732d644c8613100b9257fc9cc232bf8bae5fb7))
 * Extremely slow /api/v2/hosts, 200hosts/page takes about 40s to display ([#20508](http://projects.theforeman.org/issues/20508), [59c52f67](http://github.com/katello/katello/commit/59c52f6787e1a446aa8690fec28d9159ac0d2103))
 * Can't jump to its "Virtual Guests" in host's "Content host-->detail"page ([#22179](http://projects.theforeman.org/issues/22179), [cff3a5a4](http://github.com/katello/katello/commit/cff3a5a47f0174903b79d28c39f357d1abec4532))
 * Last search term for Content Hosts recalled, when pressing "Search" ([#21712](http://projects.theforeman.org/issues/21712), [a406fbe9](http://github.com/katello/katello/commit/a406fbe95cf7b41b2de7bc772d2fe3195fb69e75))
 * Allow non-RH hosts to NOT have content views ([#21670](http://projects.theforeman.org/issues/21670), [405a1bc7](http://github.com/katello/katello/commit/405a1bc7c6434cad3974b904beaca54e13c83e7d))
 * Host creation form bounces from synced content to media not found ([#21665](http://projects.theforeman.org/issues/21665), [3bf503ce](http://github.com/katello/katello/commit/3bf503ce0d3f50067c6a05df88bd25e623f0536e))

### Errata Management
 * Slow katello-errata query on dashboard ([#22161](http://projects.theforeman.org/issues/22161), [254dc4a7](http://github.com/katello/katello/commit/254dc4a72c4b7a41810471105dba20c65da993f2))
 * Misleading information when applying Installable Errata in  WEBUI > Content Host ([#21796](http://projects.theforeman.org/issues/21796), [649a9fb6](http://github.com/katello/katello/commit/649a9fb69368a77bd253e2c92194fcc31eb33ad9))
 * API call for Applicable errata in host bulk action missing ([#20480](http://projects.theforeman.org/issues/20480), [d2b04853](http://github.com/katello/katello/commit/d2b048535fa5abdd14672051457ba4cf45756881))
 * host errata counts are zero after upgrade ([#21403](http://projects.theforeman.org/issues/21403), [f0609e4e](http://github.com/katello/katello/commit/f0609e4e6c0998363ac5e5a32a9b9a7bd9e5624e))
 * Listing errata for host groups does not work unless host and content facet have the same id ([#21283](http://projects.theforeman.org/issues/21283), [05ac66ec](http://github.com/katello/katello/commit/05ac66ec47518303e6549e860910e3880583c92f))

### Docker
 * uninitialized constant  - RemoveDockerTag on publish ([#22157](http://projects.theforeman.org/issues/22157), [36eacc4c](http://github.com/katello/katello/commit/36eacc4c6acca64457d78aba0919ef197b9f5a9c))
 * Docker Blobs not getting cleared out during promotion ([#21845](http://projects.theforeman.org/issues/21845), [a0e098cd](http://github.com/katello/katello/commit/a0e098cded383b65b09100a971570b7194bbd9b7))
 * Docker Tags not getting cleared out on Promote ([#21808](http://projects.theforeman.org/issues/21808), [a3ca931c](http://github.com/katello/katello/commit/a3ca931c45833762685630302dab1ba9c5734fc2))
 * Docker Tag page missing manifest type ([#21692](http://projects.theforeman.org/issues/21692), [84f5516f](http://github.com/katello/katello/commit/84f5516f209a46fe80ccb280fa3dd622922e10d3))
 * Resyncing a Docker Repository does not update the tag information ([#21683](http://projects.theforeman.org/issues/21683), [5c11f39d](http://github.com/katello/katello/commit/5c11f39d2f7e6793912e55eed4088d8da015e724))
 * Wrong docker tags copied over on publish ([#21681](http://projects.theforeman.org/issues/21681), [9b45392b](http://github.com/katello/katello/commit/9b45392b655ff0c6ab81b800b7e6007d3faafa03))
 * Remove Docker Manifest  name ([#21323](http://projects.theforeman.org/issues/21323), [14128f7d](http://github.com/katello/katello/commit/14128f7d6002733c3f2c4ae9c8e60da0bcab2d3f))
 * Docker Manifests - Auto complete options not getting displayed ([#21518](http://projects.theforeman.org/issues/21518), [5990b0bc](http://github.com/katello/katello/commit/5990b0bc08a298d08b73fda0cea3966f58c9600c))
 * Docker Tags auto complete broken ([#21484](http://projects.theforeman.org/issues/21484), [6bfcb68c](http://github.com/katello/katello/commit/6bfcb68cd532c0ea4cabd490d59ff494f03a1095))
 * wrong docker tag id referenced in repository manage manifests page ([#21470](http://projects.theforeman.org/issues/21470), [61b8a85b](http://github.com/katello/katello/commit/61b8a85b28a6f11bb258b47a33b92e8cdf0f945e))
 * docker repos synced to capsule do not use a proper repo_registry_id on initial sync ([#21397](http://projects.theforeman.org/issues/21397), [c035c037](http://github.com/katello/katello/commit/c035c0370c5f32c68d7f878bb70f8a942b778773), [a724e144](http://github.com/katello/katello/commit/a724e14487b38e4fcaa564d09b7bb68e48a03a40))
 * Delete DockerMetaTags when docker tags are deleted ([#21326](http://projects.theforeman.org/issues/21326), [abc060dd](http://github.com/katello/katello/commit/abc060dd744866c09fba422c65deff78623dc815))
 * lifecycle environments shown for a specific docker tag shows all tags ([#21255](http://projects.theforeman.org/issues/21255), [cfc117a8](http://github.com/katello/katello/commit/cfc117a8fe5474db1604b7f464fb604da28701ba))
 * Cannot provision a Katello Managed docker container  ([#21050](http://projects.theforeman.org/issues/21050), [113b5798](http://github.com/katello/katello/commit/113b57983c750573d2214a7f042d91a386a8a561))
 * ISE when trying to auto complete on a CV Docker Filter ([#21607](http://projects.theforeman.org/issues/21607), [e77c2e6b](http://github.com/katello/katello/commit/e77c2e6b8d8a1ae5d1790446da2997f04cd4c505))

### Tooling
 * Remove disable_dynflow from import_product_content rake task ([#22116](http://projects.theforeman.org/issues/22116), [36d76c3b](http://github.com/katello/katello/commit/36d76c3b6287c4a1f7b604efe01edf94d9c3f894))
 * bastion katello strings can not be extracted ([#21830](http://projects.theforeman.org/issues/21830), [5307b864](http://github.com/katello/katello/commit/5307b864371011cacc8541d74c93de121fe35ac1))
 * katello-change-hostname uses fail_with_message before defining it ([#21029](http://projects.theforeman.org/issues/21029), [94074414](http://github.com/katello//commit/94074414f1865d45a85f722ea5ae7a81cef87320))
 * katello-change-hostname should check exit codes of shell executions ([#20925](http://projects.theforeman.org/issues/20925), [685cad77](http://github.com/katello//commit/685cad775989ddf653c165bad2b94b751f4fd165))
 * katello-change-hostname should verify credentials before doing anything ([#20924](http://projects.theforeman.org/issues/20924), [ef4fa97b](http://github.com/katello//commit/ef4fa97b279409406abcd14e8ba0e03f8b575abe))
 * katello-change-hostname tries to change the wrong default proxy if default proxy id has multiple digits ([#20921](http://projects.theforeman.org/issues/20921), [f7db11e5](http://github.com/katello//commit/f7db11e5e7019a5a264c44cd77d581253776ba0d))
 * katello-change-hostname silently fails when there are special (shell) chars in the password ([#20919](http://projects.theforeman.org/issues/20919), [ece3dc6f](http://github.com/katello//commit/ece3dc6f2cda95011b72a39cbba69f8c13bb601e))
 * katello-remove is very slow ([#19941](http://projects.theforeman.org/issues/19941), [8fc138c0](http://github.com/katello//commit/8fc138c08e4e519459fa292f658b7d02fae32497))
 * rpm build failing with LoadError: cannot load such file -- katello-3.5.0/test/support/annotation_support ([#19567](http://projects.theforeman.org/issues/19567), [d7ed8a44](http://github.com/katello/katello/commit/d7ed8a44b2c717b06b9cd03b5f98913291308b95))
 * update to runcible 2.0 ([#19379](http://projects.theforeman.org/issues/19379), [7c4181f1](http://github.com/katello/katello/commit/7c4181f119e44557696f085620da905f2d94721e))

### Content Views
 * ISE when publishing a composite with cv containing  puppet content ([#22044](http://projects.theforeman.org/issues/22044), [17159892](http://github.com/katello/katello/commit/17159892b94c7c452145b4910647499b144bd34d))
 * Error when promoting content view with puppet modules ([#22040](http://projects.theforeman.org/issues/22040), [2ef7126e](http://github.com/katello/katello/commit/2ef7126e5212c761b01dfceff8ba2272182933f7))
 * publish conent view with docker, ostree, or file type repo fails with "undefined method repository' ([#22025](http://projects.theforeman.org/issues/22025), [5a46319a](http://github.com/katello/katello/commit/5a46319a981e25c9eaa4782ae92b020020d37189))
 * stop emptying repositories on promote ([#21726](http://projects.theforeman.org/issues/21726), [578dbb23](http://github.com/katello/katello/commit/578dbb238d9a9baeb8ee703a382599d200637415))
 * restrict content view version deletion if part of published composite version ([#21697](http://projects.theforeman.org/issues/21697), [d907acf6](http://github.com/katello/katello/commit/d907acf63067371fd1eea7ef8891d04d007d46ce))
 * use existing repository when indexing composite view repos ([#21695](http://projects.theforeman.org/issues/21695), [4b90abce](http://github.com/katello/katello/commit/4b90abce5d9f0bb593aa5c7cbb5eab3c3cf566fb))
 * skip unit copies on content view promotion ([#21549](http://projects.theforeman.org/issues/21549), [898584a7](http://github.com/katello/katello/commit/898584a7d241618b2d9206d21eaf2fbd0a75ecd7))
 * re-use indexed data for promotion ([#21548](http://projects.theforeman.org/issues/21548), [4a2ec5b3](http://github.com/katello/katello/commit/4a2ec5b34688e2b284edd7c9fd1323eeca42d703))
 * Content Views dont copy SRPMs at all ([#21154](http://projects.theforeman.org/issues/21154), [9622ea2c](http://github.com/katello/katello/commit/9622ea2c3c970da163be6dde0bbac19a6febe7be))
 * Hammer composite content-view create/update with component-ids add only the first component of the list ([#20995](http://projects.theforeman.org/issues/20995), [30880d02](http://github.com/katello/katello/commit/30880d02c8b587daa828e1070746c29314ffe09c))
 * Content views should be searchable on the basis on 'label' ([#20844](http://projects.theforeman.org/issues/20844), [79e4028f](http://github.com/katello/katello/commit/79e4028f6143e7783cc7da2bbd6a8b5abf6b4948))
 * deletion of CV fails when a content host is assigned ([#21512](http://projects.theforeman.org/issues/21512), [bb29e1ee](http://github.com/katello/katello/commit/bb29e1ee65ac701cbf0e577f1b7cfd6c8c779ba7))
 * Content view version's Errata tab is absent if version contains only RH repos ([#21274](http://projects.theforeman.org/issues/21274), [fafe91dc](http://github.com/katello/katello/commit/fafe91dc9dbcdbd2ba64b36827bdf89c1323d742))
 * `content-view filter rule info` does not resolve by name with multiple rules on a filter ([#20761](http://projects.theforeman.org/issues/20761), [79fa4884](http://github.com/katello/katello/commit/79fa48845a191f63e966c281fa0aff086f78e91c), [8bfa14c7](http://github.com/katello/hammer-cli-katello/commit/8bfa14c7a06b41a4b54ba4defb44c9f3b56c68c5))
 * Select inputs on content view deletion are not correctly styled ([#19285](http://projects.theforeman.org/issues/19285), [4abe9501](http://github.com/katello/katello/commit/4abe95012860c53f2cf97df49c6cadac06607967))
 * Wrong value returned for CV Component ids ([#22288](http://projects.theforeman.org/issues/22288), [98eff346](http://github.com/katello/katello/commit/98eff34620704bcd8560f98638345dd95ceb4753))
 * When we click on a task listed under "Tasks" tab for CV it does not load/redirect to the actual foreman task. ([#22239](http://projects.theforeman.org/issues/22239), [ad44e33d](http://github.com/katello/katello/commit/ad44e33d1356bcafd4d47a6c2fa93d83f5f1e931))
 *  very slow publishing of a content view with filters containing many errata ([#21727](http://projects.theforeman.org/issues/21727), [6c54a7fa](http://github.com/katello/katello/commit/6c54a7fa6f538b920c94baa0b8a891401888b283))

### Repositories
 * include repository information in enable repo task output  ([#22039](http://projects.theforeman.org/issues/22039), [df915321](http://github.com/katello/katello/commit/df9153212f3fee66c02e9da8ba8b44839341e447))
 * updating a repo fails with "undefined method content" ([#22017](http://projects.theforeman.org/issues/22017), [59d1cc30](http://github.com/katello/katello/commit/59d1cc306d7e8a4b1fecc55269280c554da5a65e))
 * Improve repository sets api ([#21955](http://projects.theforeman.org/issues/21955), [bc2c5a68](http://github.com/katello/katello/commit/bc2c5a68824b9b35d58c22398896edb54d351607))
 * allow option to bypass http proxy on syncs ([#21706](http://projects.theforeman.org/issues/21706), [c80d4d8a](http://github.com/katello/katello/commit/c80d4d8ad4092ffb1f413771bdceee945313f012))
 * hammer repository upload-content is successful even with incorrect product ID ([#21623](http://projects.theforeman.org/issues/21623), [3f04813d](http://github.com/katello/hammer-cli-katello/commit/3f04813d1e8ae30d3ac1669303e9a96c70b8ae4c))
 * Hammer CLI has not option to list File repository content ([#21142](http://projects.theforeman.org/issues/21142), [2fbee25b](http://github.com/katello/katello/commit/2fbee25b0926afa5bc0e382f68e69727e17a7278), [0e31b71e](http://github.com/katello/hammer-cli-katello/commit/0e31b71ef0681bd57543f42fd075470bf9a9abe5))
 * Improve repo web UI text ([#20916](http://projects.theforeman.org/issues/20916), [5d1543da](http://github.com/katello/katello/commit/5d1543da03beca3fc02ef95d793b3eea78c06139))
 * Add "Files" and "Images" tabs to "Red Hat Repositories" page  ([#20235](http://projects.theforeman.org/issues/20235), [b4f8ed9d](http://github.com/katello/katello/commit/b4f8ed9deb13423fb4ad3662516f9b552908b802))
 * Javascript error on Docker Tag details page ([#21439](http://projects.theforeman.org/issues/21439), [1fc82810](http://github.com/katello/katello/commit/1fc82810ba25036abae9d7d2ce0caf5eb3b81956))
 * hammer repository-set enable --help doesn't explain purpose of --new-name ([#21371](http://projects.theforeman.org/issues/21371), [048c526a](http://github.com/katello/hammer-cli-katello/commit/048c526ac2ae084e46fd28e5829629278885b428))
 * new repository page fails to load arch list with error ([#21362](http://projects.theforeman.org/issues/21362), [cf682a72](http://github.com/katello/katello/commit/cf682a7264b7ac528d84c78059e80e63c3c97669))
 * Could not able to upload packages to yum repository. ([#21288](http://projects.theforeman.org/issues/21288), [19829e08](http://github.com/katello/katello/commit/19829e088e448d1102b8fdc77c8b38cb6745e223))
 * Post-sync pulp notification shouldn't fail with lock error ([#21197](http://projects.theforeman.org/issues/21197), [d05d5a55](http://github.com/katello/katello/commit/d05d5a55750e88906287049c8362d3548f21941d))
 *  Internal Server error when searching product repository by numbers with more than 9 digits ([#21017](http://projects.theforeman.org/issues/21017), [ddd80cd4](http://github.com/katello/katello/commit/ddd80cd44b73d47556cc51259d1bf72ca0694660), [f7906cef](http://github.com/katello/katello/commit/f7906cefb94c94c1e1d154e7f3e07d96f41b6b6e), [26243182](http://github.com/katello/katello/commit/26243182825b96cd81adfe4a4d161c4815129bff), [da7a4849](http://github.com/katello/katello/commit/da7a48493621e990a6d854e90c79ab0f62e0598b))
 * Add foreman_scc_manager to repository ([#20741](http://projects.theforeman.org/issues/20741), [c523599f](http://github.com/katello//commit/c523599f18e3991ab43158e0c4ed4ba277826643))
 * Exceptions get covered in Pulp::Repository::CreateInPlan::Create ([#20349](http://projects.theforeman.org/issues/20349), [dd9bdccb](http://github.com/katello/katello/commit/dd9bdccb8b1ba65f16fba848cf78ac3ebee6d532))
 * `hammer package list --organization-id` results in 'Error: found more than one repository' ([#20091](http://projects.theforeman.org/issues/20091), [ead760ff](http://github.com/katello/hammer-cli-katello/commit/ead760ff907e75fb30dac6f07e37b90820e21960))
 * Remove old puppet modules from product that have been removed from the source repo ([#20089](http://projects.theforeman.org/issues/20089), [4ba82967](http://github.com/katello/katello/commit/4ba82967fe4efe2e60c4fe7dc82e02f7f6f90cca))
 * Javascript error on Docker Tag Lifecycle Environments page ([#21440](http://projects.theforeman.org/issues/21440))
 * Having empty repo in a Content View, Capsule sync of the CV fails on retrieving this repo metadata ([#21048](http://projects.theforeman.org/issues/21048), [d068817d](http://github.com/katello/katello/commit/d068817dfb4904b585104a0ae04766eb54e5c90c))
 * Katello schedules GenerateApplicability when syncing Puppet content ([#19370](http://projects.theforeman.org/issues/19370), [9e9b39df](http://github.com/katello/katello/commit/9e9b39df1ddcf6478263cb5556b4c0cfdc913713))

### Documentation
 * Document katello-host-tools when errata is unknown ([#21978](http://projects.theforeman.org/issues/21978), [e0345d63](http://github.com/katello/katello/commit/e0345d631fa4258c602b3df101ae6bacc02d5efb))
 * SmartProxy remove instructions wrong in manual ([#21210](http://projects.theforeman.org/issues/21210))
 * User guide's glossary is not available ([#20335](http://projects.theforeman.org/issues/20335))
 * Pulp Workflow: Document Repository Creation ([#18922](http://projects.theforeman.org/issues/18922), [fdc3b7be](http://github.com/katello/katello/commit/fdc3b7be98b85e0110576be04b8adece8e9bef19))
 * Pulp Workflow: Document repository syncing ([#18921](http://projects.theforeman.org/issues/18921), [fdc3b7be](http://github.com/katello/katello/commit/fdc3b7be98b85e0110576be04b8adece8e9bef19))
 * Sync plan docs mention monthly time period but that does not exit ([#18394](http://projects.theforeman.org/issues/18394))
 * katello README links are broken ([#21763](http://projects.theforeman.org/issues/21763), [3cf145e5](http://github.com/katello/katello/commit/3cf145e59a7cc8e1654fc717c999d6f7767d8689))

### Hammer
 * OStree upstream sync depth and sync policy not available in hammer ([#21966](http://projects.theforeman.org/issues/21966), [93e31149](http://github.com/katello/hammer-cli-katello/commit/93e3114935c05b9e412f406738b0601a393a48cd))
 * uninitialized constant HammerCLIKatello::FilterRuleHelpers (NameError) when running tests ([#21701](http://projects.theforeman.org/issues/21701), [1de50d26](http://github.com/katello/hammer-cli-katello/commit/1de50d26466b7fff904ca53b0a5b6a45935b7dcd))
 * hammer repo call needs  to show the docker manifest list ([#21524](http://projects.theforeman.org/issues/21524), [79a51f5f](http://github.com/katello/hammer-cli-katello/commit/79a51f5fdfe13718f2b5d60f3a2e1094154f547c))
 * Add hammer calls to show Source RPM Count ([#21413](http://projects.theforeman.org/issues/21413), [53d9dfb9](http://github.com/katello/hammer-cli-katello/commit/53d9dfb9e907e296928f6c330f0f24e1d9c46b07))
 * [hammer-cli-katello] Repository upload tests, request order dependency ([#21409](http://projects.theforeman.org/issues/21409), [aa33c621](http://github.com/katello/hammer-cli-katello/commit/aa33c621cb7abd1ba4e62600ee5dab236b5bc37e))
 * hammer host-collection add-host/remove-host always return success ([#21281](http://projects.theforeman.org/issues/21281), [5a6c68ac](http://github.com/katello/hammer-cli-katello/commit/5a6c68acbc6f484973746f0dfa7fb83988ffca99))
 * Support kickstart repository name parameter for host and hostgroup ([#21196](http://projects.theforeman.org/issues/21196), [6fad377a](http://github.com/katello/hammer-cli-katello/commit/6fad377a53f4e3160e20313eca29805d82a4f5cb))
 * show kickstart repository name in content facet json ([#21147](http://projects.theforeman.org/issues/21147), [1fc99d4a](http://github.com/katello/katello/commit/1fc99d4ae1111319e967d8e9cc9ae5034eafb276))
 * show kickstart repository name in hammer  ([#21146](http://projects.theforeman.org/issues/21146), [0ca5c538](http://github.com/katello/hammer-cli-katello/commit/0ca5c538006a220bfb04dff8d91c411898f95431))
 * hammer content-view filter rule create does not properly set the architecture ([#20749](http://projects.theforeman.org/issues/20749), [a4942f1b](http://github.com/katello/katello/commit/a4942f1b4bc7f0cc091d69ca4b3bf3bc632a17db))
 * hammer content-view filter rule list and info do not list arch field ([#20748](http://projects.theforeman.org/issues/20748), [aea6979c](http://github.com/katello/hammer-cli-katello/commit/aea6979c21941b10d7e136abdb413a63e0da31fa))
 * Update the help description for "--sync-date" option in hammer. ([#20613](http://projects.theforeman.org/issues/20613), [59ab7402](http://github.com/katello/hammer-cli-katello/commit/59ab74029d44befde9a0037591e3cffd493eb82f))
 * Hammer hostgroup not updating by title when katello plugin is installed ([#20433](http://projects.theforeman.org/issues/20433), [a137840f](http://github.com/katello/hammer-cli-katello/commit/a137840f12c48d759ee6edb1554cc6d905c7e7ac))
 * hammer --nondefault ignores the value passed to it and always filter out "Default Organization View" ([#19749](http://projects.theforeman.org/issues/19749), [3438db63](http://github.com/katello/katello/commit/3438db63119c7bc56c99adf359ccffcf84955582))

### Performance
 * allow system registrations to happen without waiting on tasks to complete ([#21703](http://projects.theforeman.org/issues/21703), [cd11688a](http://github.com/katello/katello/commit/cd11688ac6acc70b18a87c112ad7604997de9b4c), [f113791d](http://github.com/katello/katello-installer/commit/f113791d295974c4530a99960fa35b017e26e9e0))

### Subscriptions
 * Refreshing a manifest should no longer force regeneration of Entitlement Certificates ([#21493](http://projects.theforeman.org/issues/21493), [f79dc9dc](http://github.com/katello/katello/commit/f79dc9dc7a31ebed0a94ac7f5ef27f3dd7e3b8a2))
 * Cannot assign subscription to activation key if it doesn't provide content ([#21273](http://projects.theforeman.org/issues/21273), [b0c41a1c](http://github.com/katello/katello/commit/b0c41a1c1f46c7f44ceba6bdc065d45ce93e77de))
 * Future-dated subscriptions aren't annotated in the bulk subscriptions dialog ([#21111](http://projects.theforeman.org/issues/21111), [0f15debf](http://github.com/katello/katello/commit/0f15debf32ae82123e60846bf26dbc81a07f20a4))
 * "ERROR:  current transaction is aborted, commands ignored until end of transaction block" on katello_pools table query ([#20788](http://projects.theforeman.org/issues/20788), [4aebbb91](http://github.com/katello/katello/commit/4aebbb9191d6dff369728053ae3183dbb81c07cf))
 * Unable to list/remove or add future-dated subscriptions in individual content host view ([#20582](http://projects.theforeman.org/issues/20582), [d36a700f](http://github.com/katello/katello/commit/d36a700f62f2b0a80b9adb7e14efdc96de1cc8fc))
 * Subscriptions are not getting added via activation keys ([#19548](http://projects.theforeman.org/issues/19548), [ada82e65](http://github.com/katello/katello/commit/ada82e6549f69714a567299192c5d63e42fc6637))
 * subscription page unusable with many hosts registered ([#19394](http://projects.theforeman.org/issues/19394), [1886eef5](http://github.com/katello/katello/commit/1886eef588fc7f8a8df65fe8b59911afd1d20d54))
 * add non-green subscription status for unsubscribed_hypervisor ([#17147](http://projects.theforeman.org/issues/17147), [9deecade](http://github.com/katello/katello/commit/9deecaded9ea910986e2f4e8debf410338e25df8))
 * host registration fails during provisioning if using a limited host collection ([#21961](http://projects.theforeman.org/issues/21961), [6562474d](http://github.com/katello/katello/commit/6562474d49fc345fe0ee5d7851f548be2b15fe91))
 * SQL SELECT from Katello_subscription_facets taking too long to execute (10000ms+) ([#21928](http://projects.theforeman.org/issues/21928), [d1753454](http://github.com/katello/katello/commit/d17534544aff7b96ab047c996045763a6dcc32c2))
 * Guests of Hypervisor link not showing for guest subscriptions ([#21660](http://projects.theforeman.org/issues/21660), [c0d72eb7](http://github.com/katello/katello/commit/c0d72eb79981c215a664021bf90ef79eb2a286d2))
 * activation key link from subscription not showing activation key ([#21659](http://projects.theforeman.org/issues/21659), [8c10553e](http://github.com/katello/katello/commit/8c10553e97ef4ab3b8aff0304a5a45884e57c7b4))

### Database
 * db:seed fails if SEED_LOCATION is not defined ([#21432](http://projects.theforeman.org/issues/21432), [9f3a8eb1](http://github.com/katello/katello/commit/9f3a8eb114d56f3c7b7e67958df52f08fd5e77c7))
 * Seeding on git based setups broken ([#21071](http://projects.theforeman.org/issues/21071), [08ec387e](http://github.com/katello/katello/commit/08ec387e95aed32927846267dee6ffdc959f2fb0))
 * clean duplicate host "installed package" rows on upgrade ([#21691](http://projects.theforeman.org/issues/21691), [ed0019ad](http://github.com/katello/katello/commit/ed0019ade9670121040f793269cc87cf235f110b))

### Upgrades
 * On upgrade w/ 6.3, installer failed and error appears "something went wrong" though no error appeared in logs ([#21365](http://projects.theforeman.org/issues/21365), [c35df186](http://github.com/katello/katello-installer/commit/c35df186ba4a385980900a9e2044053b0c5fd845))
 * clean backend object takes a long time to run on a foreman instance with thousands of hosts ([#21569](http://projects.theforeman.org/issues/21569), [a0aeddee](http://github.com/katello/katello/commit/a0aeddee4c57cfb61ef855611e3a40c295e754f4))
 * Upgrade Step: update_subscription_facet_backend_data generate log file at non standard location (/tmp). ([#22015](http://projects.theforeman.org/issues/22015), [b6c38605](http://github.com/katello/katello/commit/b6c386051ee54a94fc8f7449400fc25b427403b6))

### Organizations and Locations
 * Change the way how default taxonomy is derived ([#21357](http://projects.theforeman.org/issues/21357), [1832568f](http://github.com/katello/katello/commit/1832568fa5178376fb8f08b1a1ed0886bff5fb78))
 * Renaming location does not rename associated Settings ([#21363](http://projects.theforeman.org/issues/21363), [135c02a1](http://github.com/katello/katello/commit/135c02a157ff2b0559489c49d94ba5ffc07b21a8))

### Client/Agent
 * Incorrect sequence to remove the old katello agent package and certs in bootstrap.py causing error while running yum command ([#21132](http://projects.theforeman.org/issues/21132))
 * The enabled_repos_upload yum plugin is not compatible with Puppet 4 or Enterprise ([#20787](http://projects.theforeman.org/issues/20787), [156d8844](http://github.com/katello/katello-agent/commit/156d88442c07c3144a8924799d53865d33fda6a3))
 * network.hostname-override defaults to "localhost" if no fqdn set ([#20642](http://projects.theforeman.org/issues/20642), [7c0326d6](http://github.com/katello/puppet-certs/commit/7c0326d68d8232a0918e810c1a4ea31ff29ac0a1))
 * katello-agent yum-plugin enabled_repos_upload has repositories misspelled in yum output ([#20531](http://projects.theforeman.org/issues/20531), [76b8b829](http://github.com/katello/katello-agent/commit/76b8b8292e72b3bf6c5dde791b0c54630c8e6bdf))

### Sync Plans
 * When creating a sync plan, date and time are not pre-filled. ([#21049](http://projects.theforeman.org/issues/21049), [538c8f6e](http://github.com/katello/katello/commit/538c8f6ed79d9eb9bd0509fd49aee9ec71732305))
 * sync_plan['id'] missing in products#index ([#20218](http://projects.theforeman.org/issues/20218), [73629966](http://github.com/katello/katello/commit/7362996650eca2373309f0f24ba853f664a22253))
 * Docker repos with disable sync plans causes UI error ([#18036](http://projects.theforeman.org/issues/18036), [44e091af](http://github.com/katello/katello/commit/44e091af906bb3a02fc7edcea7eeaef53b5148f2))

### Candlepin
 * update candlepin to latest for 3.5 ([#21469](http://projects.theforeman.org/issues/21469))
 * Enable consistent candlepin id naming ([#19099](http://projects.theforeman.org/issues/19099), [36ef0d5b](http://github.com/katello/katello/commit/36ef0d5b419bbd3c1178084f67a227cc7735f72a))

### Host Collections
 * Can't edit host group if permission is limited to a edit_host_collections ([#21156](http://projects.theforeman.org/issues/21156), [621944d4](http://github.com/katello/katello/commit/621944d46d78e41497391bb3a1530e557f088f9c))
 * host collection index now requires organization_id ([#21150](http://projects.theforeman.org/issues/21150), [ace53d35](http://github.com/katello/hammer-cli-katello/commit/ace53d351d1830985187ffb32b96c902048a98e3), [a37f955a](http://github.com/katello/hammer-cli-katello/commit/a37f955a8c53fec979ddd2e0c6cea85ace81ceff))

### API doc
 * API Doc for content view publishing is wrong ([#20471](http://projects.theforeman.org/issues/20471), [453bf7cf](http://github.com/katello/katello/commit/453bf7cfe5a16d7c664e08175fd370c50cbd463f))

### Dashboard
 * dashboard widget data bleeds out of widget box if browser window is small ([#20338](http://projects.theforeman.org/issues/20338), [977a7c45](http://github.com/katello/katello/commit/977a7c455aa10c956c9cc1af18db1458f4af045f))
 * Clicking on links in Host collection widget redirects to 404 Page not found ([#21933](http://projects.theforeman.org/issues/21933), [472c3224](http://github.com/katello/katello/commit/472c322465ef31595e7c9a0955ab8a146f1473ae))

### SElinux
 * Installation of Katello generates denial ([#14233](http://projects.theforeman.org/issues/14233), [17700324](http://github.com/katello/katello-selinux/commit/17700324045276aa4c7ff655f19fb88fd44eb2b0))

### Roles and Permissions
 * The remote execution views in katello should require view_hosts, not edit_hosts permision ([#21794](http://projects.theforeman.org/issues/21794), [f7340d45](http://github.com/katello/katello/commit/f7340d451d19f9f8ed1878a74d569885d373ef79))

### Other
 * Don't pass AC::Params into actions ([#22306](http://projects.theforeman.org/issues/22306), [73d9bc81](http://github.com/katello/katello/commit/73d9bc81dcd726ef4ad69c214ceacf77beff82ba))
 * Support qpid_messaging 1.X ([#22238](http://projects.theforeman.org/issues/22238), [0f5aa653](http://github.com/katello/katello/commit/0f5aa6530e5edab1bea6e214e8820ad0ca70e5e4))
 * Not possible to view/edit repository: undefined method 'product' for # ([#21979](http://projects.theforeman.org/issues/21979))
 * EventQueue grows without processing events ([#21855](http://projects.theforeman.org/issues/21855), [57389c65](http://github.com/katello/katello/commit/57389c65538e68c247725886e39b91909ff325ce))
 * Depend on Bastion >= 6.1.2 for compatibility with vertical navigation ([#21709](http://projects.theforeman.org/issues/21709), [1a0d81c8](http://github.com/katello/katello/commit/1a0d81c85214136f08a738d1222da3ff9ff80fb6))
 * Move the patternfly dependencies out of devDependencies ([#21574](http://projects.theforeman.org/issues/21574), [bc3c5d99](http://github.com/katello/katello/commit/bc3c5d99743b3a9983c69dbe318828cdf4ccd28d))
 *  Search filter disappears when deleting a host. ([#21540](http://projects.theforeman.org/issues/21540), [e7bb4b81](http://github.com/katello/katello/commit/e7bb4b817b9314cfcfe667ce9428702f8f95a095))
 * Change link on “Reset Puppet Environment….” to be only on "Reset Puppet Environment" ([#21475](http://projects.theforeman.org/issues/21475), [bf4fc9a4](http://github.com/katello/katello/commit/bf4fc9a4bc374aededb97e91579767d44bea245c))
 * Allow unicode characters in certificates ([#21345](http://projects.theforeman.org/issues/21345), [a17ce3a9](http://github.com/katello/katello-installer/commit/a17ce3a92d5b0181b2ad44ecc7c0bb5eb8ba14fe))
 * Long running tasks should use Dynflow::Action::Singleton ([#21261](http://projects.theforeman.org/issues/21261), [ea51f03c](http://github.com/katello/katello/commit/ea51f03c05436c04c5f8a79c5fa8b8fce007864a))
 * Rails 5 - Replace alias_method_chain with Module prepend ([#21243](http://projects.theforeman.org/issues/21243), [a32a9be5](http://github.com/katello/katello/commit/a32a9be522015a1ef925038ca2cf94722efb6307))
 * Rails 5 - ParamsParser middleware conversion ([#21019](http://projects.theforeman.org/issues/21019), [ce312249](http://github.com/katello/katello/commit/ce3122499fef374ec4add0e0af8ae56f2194dfee))
 * Rails 5 - Resolve Katello test failures ([#21018](http://projects.theforeman.org/issues/21018), [10b1d4dd](http://github.com/katello/katello/commit/10b1d4dd903e6d8af44915352133ddd130de3105))
 * render :nothing => true deprecated in Rails 5 ([#20845](http://projects.theforeman.org/issues/20845), [018c1eba](http://github.com/katello/katello/commit/018c1ebacd8172e64a53942e18d989f8633b4573))
 * Can not extract the strings for katello.  ([#20810](http://projects.theforeman.org/issues/20810), [a59f6753](http://github.com/katello/katello/commit/a59f6753266c6c32d83a07ead7ac6d1f5e639315))
 * Visiting /smart_proxies/:id with Bastion fails 'undefined method include_plugin_styles' ([#21809](http://projects.theforeman.org/issues/21809), [652ba187](http://github.com/katello/katello/commit/652ba187a213358cad45e72a0b1633bc571782b8))
 * `foreman-rake katello:upgrades:3.0:update_puppet_repository_distributors` undefined method `mirror_on_sync?' ([#21593](http://projects.theforeman.org/issues/21593), [240848e0](http://github.com/katello/katello/commit/240848e0dbc7c9c80958ac40397de5a94ea5f0a4))
 * Incremental publish of content-view does not show packages of added errata (RHSA-2017:1679) ([#21495](http://projects.theforeman.org/issues/21495), [7a72ac86](http://github.com/katello/katello/commit/7a72ac8677204d480cd5c1891da294d6366fe9e2))
 * Fix --upgrade-puppet to handle Puppet 5 and drop all Puppet 3 upgrade options ([#21384](http://projects.theforeman.org/issues/21384), [d8895d90](http://github.com/katello/katello-installer/commit/d8895d90ad975c67cdf8b66f317de48561655c62))
 * Email notification fails for Promotion and Sync Summary  ([#21366](http://projects.theforeman.org/issues/21366), [e02ff8a4](http://github.com/katello/katello/commit/e02ff8a49f70205ff276190d831f8e0dfb6046cd))
 * Clicking on CV versions  link in Content Views widget shows 404 page not found ([#21364](http://projects.theforeman.org/issues/21364), [4736e405](http://github.com/katello/katello/commit/4736e4055cbe93d970b73c2d3f62f3f644baac24))
 * check path includes sbin in katello scripts ([#21348](http://projects.theforeman.org/issues/21348), [8b7b45d6](http://github.com/katello//commit/8b7b45d69fcb33379425c70578faa81642849cf7))
 * PG::Error: missing FROM-clause entry from items in Dashboard for Filtered role ([#21254](http://projects.theforeman.org/issues/21254), [77f0d59d](http://github.com/katello/katello/commit/77f0d59d6dc358be0e7ae1551dc98242a62de8f3))
 * foreman-proxy-content answer migration misses the clear mappings migration ([#21233](http://projects.theforeman.org/issues/21233), [ed3ddfc0](http://github.com/katello/katello-installer/commit/ed3ddfc076b8e00b0e13ad92ebad8704e12f321a))
 * name field not clickable after opening resource switcher ([#21035](http://projects.theforeman.org/issues/21035), [3e8b0796](http://github.com/katello/bastion/commit/3e8b07964f3066d77575e1821fbdac83180cda59))
 * Update installation media paths in k-change-hostname ([#20987](http://projects.theforeman.org/issues/20987), [f1418fc0](http://github.com/katello//commit/f1418fc08a9f2614b0f136bde6469328f0b6bf34))
 * katello-change-hostname should print command output when it errors out. ([#20984](http://projects.theforeman.org/issues/20984), [a727125b](http://github.com/katello//commit/a727125bb492abdf14c9eb10c39e8d67d9864cf9))
 * k-change-hostname can mix up internal capsule names ([#20983](http://projects.theforeman.org/issues/20983), [b1a9d445](http://github.com/katello//commit/b1a9d44581e7e93131c8cadfe04cb0b2d32b2346))
 * clean_installed_packages script logs a count(*), causing slow performance ([#20946](http://projects.theforeman.org/issues/20946), [cc0b15fb](http://github.com/katello/katello/commit/cc0b15fb330178aca8317873eaaf2ef1b280d1d7))
 * k-change-hostname will check for exit code on a skipped command on a foreman-proxy ([#20944](http://projects.theforeman.org/issues/20944), [d32d5854](http://github.com/katello//commit/d32d5854c167efa0bf2dc02fa5ceceb07f2eff71))
 * upgrades no longer need to configure pulp oauth ([#20907](http://projects.theforeman.org/issues/20907), [456d35e1](http://github.com/katello/katello-installer/commit/456d35e1c812981966e58f2bb4eb99cb68dac4d7))
 * Don't consider localhost as valid host name when parsing rhsm facts ([#20816](http://projects.theforeman.org/issues/20816), [2060454b](http://github.com/katello/katello/commit/2060454b1b7305136fcf43dc75e040ec328829b0))
 * Katello redhat extension tests intermittently fail ([#20795](http://projects.theforeman.org/issues/20795), [ea6d4b56](http://github.com/katello/katello/commit/ea6d4b56c14ba6fe5acf40d4f4d5984833f0fb07))
 * Kickstart repository assigned in UI to hostgroup difficult to set using Hammer ([#20785](http://projects.theforeman.org/issues/20785), [81410e9e](http://github.com/katello/katello/commit/81410e9e377d463ec717d113608692c572f93b3c))
 *  POST /api/hosts/bulk/applicable_errata API doc has incorrect URL pointing to installable_errata.html ([#20478](http://projects.theforeman.org/issues/20478), [4ca55e14](http://github.com/katello/katello/commit/4ca55e14424e16adff4ef5764cc8f30868214421))
 * Remove RHEL6 support in katello-change-hostname ([#20463](http://projects.theforeman.org/issues/20463), [45417cf6](http://github.com/katello//commit/45417cf61d90a5c862f8fb9b1a4ede81c543b297))
 * New container wizard does not store state of Katello image (step 2) ([#16509](http://projects.theforeman.org/issues/16509), [893d7cde](http://github.com/katello/katello/commit/893d7cdec1d74f6343766ec2ac6e5375318d67c6))
 * Handle autosign file with puppet 4 ([#22249](http://projects.theforeman.org/issues/22249), [95fa0307](http://github.com/katello/katello-installer/commit/95fa0307c123314d5589cd9af08f2def6be8f69c))
 * Docker Image tags are missing after upgrading the katello server. ([#22230](http://projects.theforeman.org/issues/22230), [e7271788](http://github.com/katello/katello/commit/e7271788929064baed059fa54fedbaa20298eac3), [c9f6b8ca](http://github.com/katello/katello-installer/commit/c9f6b8ca1c6a685051f7263b0c9cd16efbcf8693))
 *  Pagination issue: "Next Page" and "Last Page" options are not working on the "Errata" tab for content host. ([#22134](http://projects.theforeman.org/issues/22134), [08077241](http://github.com/katello/bastion/commit/08077241c8055a0c74924278b6b64de764d0b72c), [cb782a48](http://github.com/katello/bastion/commit/cb782a48d8fb1368a1e481e22b8ce6c2fa6f5d60))
 * Could not resolve packages from state 'content-view.repositories.yum.list' ([#21788](http://projects.theforeman.org/issues/21788), [1bca4e4d](http://github.com/katello/katello/commit/1bca4e4d2b7b06a7baf30b21e09a8a44754f55f1))
 * Error PulpNode not found when visiting SmartProxy ([#21667](http://projects.theforeman.org/issues/21667), [a89c0bb7](http://github.com/katello/katello/commit/a89c0bb776fb4481d48b0ae8ff85e7a9047710fa))
 * Katello should send the correct Tracer helpers to RemoteEX ([#21572](http://projects.theforeman.org/issues/21572), [fb68d6ad](http://github.com/katello/katello/commit/fb68d6adbe44afe1f628b9114866cdd0f58af6d5))
 * virt-who cant talk to foreman anymore  ([#21110](http://projects.theforeman.org/issues/21110))
