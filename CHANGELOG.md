# 3.11.0 Beautiful Disaster (2019-03-12)

## Features

### Other
 * [Container Admin Feature] Registry Name Pattern with repository.url will always be rejected ([#25781](https://projects.theforeman.org/issues/25781), [3cc98400](https://github.com/Katello/katello.git/commit/3cc984002fc1e56c44f2d67a75a098d7c5f83880))
 * Katello does not import facts from virt-who reported Hypervisors ([#25415](https://projects.theforeman.org/issues/25415), [81530a06](https://github.com/Katello/katello.git/commit/81530a06de177a78275b229d0ec491579ce016f4))

## Bug Fixes

### Repositories
 * rake task katello:upgrades:3.11:update_puppet_repos sometimes fails on slow hardware ([#26171](https://projects.theforeman.org/issues/26171), [463f2a55](https://github.com/Katello/katello.git/commit/463f2a551de0469b263d944a2fbacd91d03775b3))
 * Upgrade Step: katello:upgrades:3.11:update_puppet_repos failed during 6.4 to 6.5 upgrade ([#25866](https://projects.theforeman.org/issues/25866), [6f2ff89d](https://github.com/Katello/katello.git/commit/6f2ff89df3f797d3dbce121897b0e79af351d4e6))
 * hammer repository info show "Red Hat Repository: no" for a Redhat enabled repository ([#25805](https://projects.theforeman.org/issues/25805), [4967a656](https://github.com/Katello/katello.git/commit/4967a656fccc33153790a0a479193573487e7eed), [0de73e68](https://github.com/Katello/hammer-cli-katello.git/commit/0de73e6874d46e3e4f7c852410e09a9af4c77ec9))
 * rename content unit 'uuid' to 'backend_identifier' ([#25794](https://projects.theforeman.org/issues/25794), [0d5a1ebe](https://github.com/Katello/katello.git/commit/0d5a1ebe7d722113d16146d6f98b6d2a39c351c0))
 * No validation on download policy for non-yum repositories ([#25793](https://projects.theforeman.org/issues/25793), [e0cb6597](https://github.com/Katello/katello.git/commit/e0cb6597f0dd9f49cd09718aca2d25207ee33cb5))
 * sometimes RHEL8 Beta sync fails: PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "katello_module_stream_artifacts_name_mod_stream_id_uniq" ([#25774](https://projects.theforeman.org/issues/25774), [55ab5479](https://github.com/Katello/katello.git/commit/55ab54799e4bf0454c89accc4ed30206bc2219df))
 * uploading a package to custom repo does not trigger sync of Capsule in Library LE ([#25761](https://projects.theforeman.org/issues/25761), [cd1b0b50](https://github.com/Katello/katello.git/commit/cd1b0b5028f1dcc1a9b55c555b9aa3a40d241c75))
 * Product sync: wrong link to task ([#25751](https://projects.theforeman.org/issues/25751), [02d8b97a](https://github.com/Katello/katello.git/commit/02d8b97ae38b31580295259f43dc304dcdee9c47))
 * Recommended Repositories lists tools for outdated Satellite version ([#25750](https://projects.theforeman.org/issues/25750), [a293cac8](https://github.com/Katello/katello.git/commit/a293cac81496ef4bd12948fa4577a8a2ef71a690))

### Hosts
 * OS's with 3 digit versions not showing up as "synced content" ([#26095](https://projects.theforeman.org/issues/26095), [a04b0ba0](https://github.com/Katello/katello.git/commit/a04b0ba0f4289200b246874a5d3ba681129748d7))

### Content Views
 * productid is not published in the content view if that is the only item which changed in the sync ([#26058](https://projects.theforeman.org/issues/26058))
 * CV History: Incorrect API call due to parsing error (page=NaN) ([#25232](https://projects.theforeman.org/issues/25232))

### Tests
 * react test failure - initExpanded={false} ([#26031](https://projects.theforeman.org/issues/26031), [a9096b74](https://github.com/Katello/katello.git/commit/a9096b74c5ab3540e9bb854db9f3c99807f381ab))
 * Repository controller transient test failures ([#25867](https://projects.theforeman.org/issues/25867), [a137467e](https://github.com/Katello/katello.git/commit/a137467ed23923964c6134f46cb3760a813ff225))
 * db:seeds tries to talk to candlepin during pr tests ([#25744](https://projects.theforeman.org/issues/25744), [135ddf68](https://github.com/Katello/katello.git/commit/135ddf68d93e18574db5d956d8bbe27dcfaa7624))
 * test breakage from foreman change ([#25738](https://projects.theforeman.org/issues/25738), [1087a435](https://github.com/Katello/katello.git/commit/1087a435e089201baf0a0d49ae50b4f0b6e7f398))
 * silent errors in Katello::Host::HypervisorsUpdateTest ([#25546](https://projects.theforeman.org/issues/25546), [3fa2ee88](https://github.com/Katello/katello.git/commit/3fa2ee88fbae9051eab13340a9e33d0f8450b965))

### Web UI
 * adapt to new webpack bundle entry format ([#25883](https://projects.theforeman.org/issues/25883), [ffb6e876](https://github.com/Katello/katello.git/commit/ffb6e876b646bc9c3903c829fb8a734ac42c7c14))
 * [object Object] instead of organization name on Content -> Sync status page ([#25228](https://projects.theforeman.org/issues/25228), [013fd5f3](https://github.com/Katello/katello.git/commit/013fd5f3ed9ca9ef2a0820265fc3f446d4e0a2d4))

### Inter Server Sync
 * CV with repo having background download policy is importing and exporting ([#25861](https://projects.theforeman.org/issues/25861), [b00cb3c8](https://github.com/Katello/hammer-cli-katello.git/commit/b00cb3c8be632f52d1b636b093bda10ab816f887))
 * Content View Version export breaks while exporting to relative path ([#25857](https://projects.theforeman.org/issues/25857), [03658ddb](https://github.com/Katello/hammer-cli-katello.git/commit/03658ddb516abae5f7bd691136e6dae374e63bf5))

### Errata Management
 * hammer erratum list  --organization-id="org_id" display all organizations erratum ([#25856](https://projects.theforeman.org/issues/25856), [cb6a7e3a](https://github.com/Katello/katello.git/commit/cb6a7e3ac8882991edb3bd35de2de1d7c1590580))

### Subscriptions
 * unable to change Red Hat CDN URL: Value (NilClass) '' is not any of: ForemanTasks::Concerns::ActionSubject. ([#25816](https://projects.theforeman.org/issues/25816), [5e69bd12](https://github.com/Katello/katello.git/commit/5e69bd1284a8ee4c7f0acdaa175df19159785df2))
 * Printing info into logs when logging level is set to debug ([#25595](https://projects.theforeman.org/issues/25595), [926fd8b2](https://github.com/Katello/katello.git/commit/926fd8b2abbb7d4aec7aecd2cc7c1a85fa6ef755))
 * Subscription Status Widget showing incorrect information on Dashboard ([#25480](https://projects.theforeman.org/issues/25480), [ec474741](https://github.com/Katello/katello.git/commit/ec4747412bcf16c62226ef5dea0c1be9c277e758), [95fc70bf](https://github.com/Katello/katello.git/commit/95fc70bf4b49fbe0c117e570b8372e6cf7fd76ef))
 * The meaning of "max" subscriptions is incorrect ([#25408](https://projects.theforeman.org/issues/25408), [d34f4964](https://github.com/Katello/katello.git/commit/d34f49642af8c55143542109d1f6775d37b789a4))
 * Some repositories from the CDN no longer has variants and repository page shows "Unspecified" ([#25224](https://projects.theforeman.org/issues/25224), [091015e9](https://github.com/Katello/katello.git/commit/091015e9b30dfce041d6173d63fc61ee55c5fbe1))

### Hammer
 * Docker tag info in man pages very vague ([#25813](https://projects.theforeman.org/issues/25813), [4afc4c35](https://github.com/Katello/hammer-cli-katello.git/commit/4afc4c35495e99d73708b502c6ae4048941939e7))

### Docker
 * publishing a cv with two docker repos with conflicting container names shows generic error ([#25782](https://projects.theforeman.org/issues/25782), [7c2c4cbd](https://github.com/Katello/katello.git/commit/7c2c4cbd1924160a6b55f81296a991f0c424fe5b))

### Client/Agent
 * katello-rhsm-consumer can fail, breaking the isntallation of katello-ca-consumer.rpm ([#25739](https://projects.theforeman.org/issues/25739), [f5397553](https://github.com/theforeman/puppet-certs/commit/f53975534752041d655994795b539912e4b7aa36))

### Sync Plans
 * Form button on Product> New Sync Plan doesn't get disabled on first click ([#24718](https://projects.theforeman.org/issues/24718))

### Installer
 * port 8080 is needed by candlepin for one-time initialization ([#19095](https://projects.theforeman.org/issues/19095))

### Other
 * Need to add module streams in hammer o/p for "host errata info" ([#25845](https://projects.theforeman.org/issues/25845), [1fad5382](https://github.com/Katello/hammer-cli-katello.git/commit/1fad5382de0e166cc570fe17e3fd9f64c6d813fa))
 * Foreman Tasks Ping fails with undefined method `failed?' for ResolvableFuture ([#25827](https://projects.theforeman.org/issues/25827), [dcdfec59](https://github.com/Katello/katello.git/commit/dcdfec598263b6f7fb311821fa9abce6a0a4540f))
 * Use string in `add_controller_action_scope` ([#25820](https://projects.theforeman.org/issues/25820), [6ac78b79](https://github.com/Katello/katello.git/commit/6ac78b79f30eca916555805099c441ef1e91ef0b))
 * JS tests broken by patternfly-react change ([#25773](https://projects.theforeman.org/issues/25773), [9931f89b](https://github.com/Katello/katello.git/commit/9931f89b0454cf042f95ac2d9f3ec9204df23391))
 * fix lint due to eslint-plugin-react update ([#25771](https://projects.theforeman.org/issues/25771), [83a010a6](https://github.com/Katello/katello.git/commit/83a010a6a57cc8ef678f28d6676b96c624940819))
 * race condition when creating multiple repos in same product ([#25626](https://projects.theforeman.org/issues/25626), [e737e2e3](https://github.com/Katello/katello.git/commit/e737e2e335bb72cda791eba8f3890b0c2585f4e2))
 * Pulp should handle cleanup of Puppet directories ([#25576](https://projects.theforeman.org/issues/25576), [42b1fcb7](https://github.com/Katello/katello.git/commit/42b1fcb73452c06552b28b286726af43f0e5c413))
 * No Audit written for install Errata ([#25298](https://projects.theforeman.org/issues/25298), [0591e22f](https://github.com/Katello/katello.git/commit/0591e22f37f5ba46a080ea986a5e016d82b1910e), [760e7419](https://github.com/Katello/katello.git/commit/760e741910dce28cfd128995f7378aeb54922450))
