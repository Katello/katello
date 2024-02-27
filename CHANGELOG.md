<<<<<<< HEAD
# 4.12.0.rc1 Mile 42 (2024-02-27)
=======
# 4.12.0-rc1 Mile 42 (2024-02-27)
>>>>>>> df8164b7fa (Release 4.12.0-rc1 (#10909))

## Features

### Hosts
 * Remove entitlement-mode-related host statuses ([#37148](https://projects.theforeman.org/issues/37148), [89a802a2](https://github.com/Katello/katello.git/commit/89a802a2ebeb2c9278ff0115c057cbb2735b3779))

### Tooling
 * Make plugin compatible with Ruby 3 ([#37145](https://projects.theforeman.org/issues/37145), [192800a1](https://github.com/Katello/katello.git/commit/192800a11feb1b1d255c94da84a4af1b05850ded))

### Web UI
 * Update web UI for SCA-only ([#37140](https://projects.theforeman.org/issues/37140), [1bd84c20](https://github.com/Katello/katello.git/commit/1bd84c2006f10f3ac9d9ec7813320dbc70bd8629))
 * Can't change default template name for change content source ([#37005](https://projects.theforeman.org/issues/37005), [8b176631](https://github.com/Katello/katello.git/commit/8b176631c6cab4d86e822cdff2874fc7061d2595))

### Organizations and Locations
 * SCA-Only: Update behavior of organizations & Candlepin owners ([#37131](https://projects.theforeman.org/issues/37131), [16cbea2e](https://github.com/Katello/katello.git/commit/16cbea2ed64109baed9227dd47588ccc314c766e))

### Inter Server Sync
 * Add ability to export and import APT (deb) content ([#36765](https://projects.theforeman.org/issues/36765), [c384fed6](https://github.com/Katello/katello.git/commit/c384fed698c0595ecadc8566612f44d1d4475364))

### Errata Management
 * New host details page should show debian content ([#35713](https://projects.theforeman.org/issues/35713), [e48bd5b7](https://github.com/Katello/katello.git/commit/e48bd5b749022b38874d169b1e53313896f79f6a), [3ac7cddf](https://github.com/Katello/katello.git/commit/3ac7cddf0f452afac1514f1c37b660930833bf4b))

### Other
 * Use shared GitHub Action for test execution ([#37095](https://projects.theforeman.org/issues/37095), [16be0148](https://github.com/Katello/katello.git/commit/16be014837f818a31d45c977325815b48148da33))

## Bug Fixes

### Hosts
 * Packages Tab on Host Details page depends on operatingsystem description (which can be changed by user) ([#37144](https://projects.theforeman.org/issues/37144), [f14f58e3](https://github.com/Katello/katello.git/commit/f14f58e3d7dc2a3c5a14b7b64592d5c9a9900868))
 * virt-who host and virtual host guest did not display the correct mapping info on old Legacy Content Host UI->Details ([#37123](https://projects.theforeman.org/issues/37123), [e5fccf9a](https://github.com/Katello/katello.git/commit/e5fccf9afddcece4205fc9069c24f609c0e5c686))
 * Host facts disappear during registration, causing incorrect RHEL lifecycle status of Unknown ([#37107](https://projects.theforeman.org/issues/37107), [3dcae86c](https://github.com/Katello/katello.git/commit/3dcae86ca41974534ec67771364ed6b312351e92))
 * hammer host list does not print parameters even if they are present in the fields list like LCE and CVs ([#37053](https://projects.theforeman.org/issues/37053), [9a6ae05c](https://github.com/Katello/hammer-cli-katello.git/commit/9a6ae05cd72e8dd09004204c00571d449abe4c63))
 * Traces service restart should warn user that host will reboot ([#36986](https://projects.theforeman.org/issues/36986), [d8c443ce](https://github.com/Katello/katello.git/commit/d8c443cede87b4c4222464acd8f75116958b79a0))
 * all hosts page slow -> improve installed packages queries ([#36946](https://projects.theforeman.org/issues/36946), [ced0ed0f](https://github.com/Katello/katello.git/commit/ced0ed0f87dfd5da1e8e6ca2fa4b3bfe8391b060))
 * all hosts page slow -> reduce the amount of errat queries ([#36943](https://projects.theforeman.org/issues/36943), [96da01ca](https://github.com/Katello/katello.git/commit/96da01ca7042955d5b534d72b329bfc4c223f676))
 * all hosts page slow -> reduce the amount of katello host tracer queries ([#36941](https://projects.theforeman.org/issues/36941), [ae6ac5b2](https://github.com/Katello/katello.git/commit/ae6ac5b2fa296f9c27ce452dc36401482b49d7ea))
 * Host search by installed_package_name invokes OOM killer ([#35974](https://projects.theforeman.org/issues/35974), [8591b4c2](https://github.com/Katello/katello.git/commit/8591b4c250da8c27fc81b47af8aa2443fff51e3d))

### Web UI
 * Virtual guests show up on legacy UI for hosts even if they are not hypervisors ([#37118](https://projects.theforeman.org/issues/37118), [136a73e8](https://github.com/Katello/katello.git/commit/136a73e8c007d4ed5969adfb6411dc2c68e9880d))

### Repositories
 * Setting pulp_export_destination is unused ([#37083](https://projects.theforeman.org/issues/37083), [08dbe775](https://github.com/Katello/katello.git/commit/08dbe7751a3dd8b17a0ae4b164a7ae549ee7c1dd))
 * param :source_url not working with the sync API ([#36987](https://projects.theforeman.org/issues/36987), [58f49878](https://github.com/Katello/katello.git/commit/58f498787ffef5db04920462591bf6f7f6117e36))
 * Never use dependency-solving for deb content ([#36748](https://projects.theforeman.org/issues/36748), [8a156c16](https://github.com/Katello/katello.git/commit/8a156c1639832c37b7812304cbf4bae1674e6380))

### API
 * Remove LCE option from host-registration generate-command in Hammer/API similar to WebUI ([#37044](https://projects.theforeman.org/issues/37044), [5992bdd3](https://github.com/Katello/katello.git/commit/5992bdd393f8fdd51f863030ce8a395447b2031c))

### Foreman Proxy Content
 * Set up smart proxy reference to content source proxy ([#37028](https://projects.theforeman.org/issues/37028), [57ab3c95](https://github.com/Katello/katello.git/commit/57ab3c95b713dd51115399d2fb33a4b4f4a0e3ff))

### Content Views
 * CV version should display Container manifest list count ([#36988](https://projects.theforeman.org/issues/36988), [8491ba0b](https://github.com/Katello/katello.git/commit/8491ba0bcc72ed9ff272e6aacf0e29976e7147db))

### Inter Server Sync
 * Hammer is not propagating error message from production log when content-export fails ([#36977](https://projects.theforeman.org/issues/36977), [6b1d95ed](https://github.com/Katello/katello.git/commit/6b1d95ed2d4d52255db7f8cd221007b80baa07b4))

### Hammer
 * hammer repository info doesn't return content counts for AC repos ([#36970](https://projects.theforeman.org/issues/36970), [e09be6e8](https://github.com/Katello/hammer-cli-katello.git/commit/e09be6e8e25f36559900f7b081a40983f8f64dbf))
 * Hammer content-view info command shows only yum and container repositories ([#36742](https://projects.theforeman.org/issues/36742), [a14fcb42](https://github.com/Katello/hammer-cli-katello.git/commit/a14fcb42eaada249d10bcb1705bcb83e107ac135))

### Localization
 * Unused config/locale directory ([#36950](https://projects.theforeman.org/issues/36950), [68a817e8](https://github.com/Katello/katello.git/commit/68a817e86e4611298c933f41c4784ab9ee942d79))

### Performance
 * "Actions::Katello::Applicability::Hosts::BulkGenerate" tasks are processed in the default queue instead of hosts_queue causing congestion ([#36921](https://projects.theforeman.org/issues/36921), [da87a05e](https://github.com/Katello/katello.git/commit/da87a05e4d2e2a0ea8c529aefe77ed945550fe96))

### Other
 * Remove unused downshift dependency ([#37113](https://projects.theforeman.org/issues/37113), [383e45ae](https://github.com/Katello/katello.git/commit/383e45ae6ade95dd677c259cf75fc2ba2d101a7a))
 * A lot of COUNT() SQL queries on the content view page ([#37111](https://projects.theforeman.org/issues/37111), [14b63bd0](https://github.com/Katello/katello.git/commit/14b63bd0131c2007c934dabaa4f51cef049cf380))
 * Enable eager loading on CV latest_version_object ([#37109](https://projects.theforeman.org/issues/37109), [43110860](https://github.com/Katello/katello.git/commit/431108603e30857e1dbed826ad22e54c5b1a0caa))
 * Upgrade to VCR 6.1+ ([#37100](https://projects.theforeman.org/issues/37100), [cc1b7cc0](https://github.com/Katello/katello.git/commit/cc1b7cc0a624e00a6b59b5bae2be298a8ba6331e))
 * Drop uglifier development dependency ([#37094](https://projects.theforeman.org/issues/37094), [6af370d2](https://github.com/Katello/katello.git/commit/6af370d2bc979c2188f3a5525bcbb3f9e764af06))
 * Invalid single-table inheritance type: ConfigManagementError is not a subclass of RemoveKatelloFromNotificationName::FakeMailNotification ([#37075](https://projects.theforeman.org/issues/37075), [98a9b4da](https://github.com/Katello/katello.git/commit/98a9b4da64b890c5bf5299a8d36f704d2f2bedc6))
 * Migration error 'users.disabled' already exists ([#37074](https://projects.theforeman.org/issues/37074), [9915be72](https://github.com/Katello/katello.git/commit/9915be7280e4d380fc2a14f8ba052cfb2b707eb5))
 * Migration error 'column settings.category does not exist' ([#37073](https://projects.theforeman.org/issues/37073), [3773276a](https://github.com/Katello/katello.git/commit/3773276af1e5489641132b60f455047b2d7f347f))
 * Cleanup orphans task generates inefficient queries consuming resources and taking long time to run ([#37058](https://projects.theforeman.org/issues/37058), [799b4c0b](https://github.com/Katello/katello.git/commit/799b4c0bc97d6aa02a309a02d923ebf7be14d7ac))
 * Package install/remove job templates failing due to incorrect method calls ([#37045](https://projects.theforeman.org/issues/37045))
