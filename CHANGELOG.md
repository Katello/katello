# 2.2.2 Maibock (2015-06-24)

## Features 

### Other
 * Change default certificate signing algorithm to sha256WithRSAEncryption ([#10777](http://projects.theforeman.org/issues/10777))

## Bug Fixes 

### Web UI
 * Content host product content tab does not load ([#10871](http://projects.theforeman.org/issues/10871), [4227b724](http://github.com/katello/katello/commit/4227b7240df02581baa5cef9bfa8a08bc26e951e))
 * Content Host => Product Content / Activation Key => Product Content page not loading ([#10737](http://projects.theforeman.org/issues/10737))
 * Organization delete failed ([#10655](http://projects.theforeman.org/issues/10655), [63bf81f3](http://github.com/katello/katello/commit/63bf81f35261b658832b18e46a9bca7fa35a8ed3))
 * Repository delete and bulk deletes results in javascript traceback ([#10622](http://projects.theforeman.org/issues/10622), [b5d92ffa](http://github.com/katello/katello/commit/b5d92ffa94d6797d979273bf6a8cacf7b13a1935))
 * NoMethodError: undefined method `archive_puppet_evironment' for #<Katello::ContentViewVersion:0x0000000f66e518> ([#10588](http://projects.theforeman.org/issues/10588), [014c84c3](http://github.com/katello/katello/commit/014c84c3b5d77981e69497d95922c71c55592031))
 * Product_content tab on activation-key page remains in loading state and getting TypeError: Cannot read property 'length' of undefined ([#10575](http://projects.theforeman.org/issues/10575), [0994bb85](http://github.com/katello/katello/commit/0994bb85a732738213f4db8bea6bcbd22b604ea0))
 * Incremental update task never completes if one of the content hosts does not complete installation ([#10489](http://projects.theforeman.org/issues/10489), [dc480f7b](http://github.com/katello/katello/commit/dc480f7b7d55506ab492b0776ed1f84d0a6e662e))
 * "The selected environment contains no Content Views" when creating new activation key ([#9961](http://projects.theforeman.org/issues/9961))

### Katello Disconnected
 * Stale katello-utils in 2.2 Repo ([#10783](http://projects.theforeman.org/issues/10783))

### Packaging
 * hammer_cli_gutterball, hammer_cli_import, hammer_cli_katello not loaded ([#10764](http://projects.theforeman.org/issues/10764))

### Installer
 * katello-agent doesn't work when custom certs are used ([#10670](http://projects.theforeman.org/issues/10670), [2d7f81d6](http://github.com/katello/katello-agent/commit/2d7f81d679a595dc674b4a9c4e604b7e56c51262))

### Capsule
 * Unable to install custom packages via capsule due to GPG key failure ([#10616](http://projects.theforeman.org/issues/10616), [4a8be016](http://github.com/katello//commit/4a8be016b48e0d810eceb37303967d95440b4e18))
 * capsule: synchronize command never times out/silently fails. ([#7162](http://projects.theforeman.org/issues/7162), [f778714b](http://github.com/katello/katello/commit/f778714b1e934857301ec977c31ec3e9075a3c4a))

### Katello Agent
 * 'Non-fatal POSTIN scriptlet failure in rpm package' (when installing server cert / subscription-manager) ([#10608](http://projects.theforeman.org/issues/10608))

### Foreman Integration
 * When multiple users are subscribed, satellite sends notification to one user only ([#10572](http://projects.theforeman.org/issues/10572), [ce174b43](http://github.com/katello/katello/commit/ce174b43f57e92d9e5b3b18494e7f27d56bffd12))
 * Don't publish puppet environments for content views without puppet environments ([#10459](http://projects.theforeman.org/issues/10459), [99c1a67e](http://github.com/katello/katello/commit/99c1a67ece5fea9329d73af1dc62380d519a6427))
 * Adding lifecycle environment to smart proxy results in ActiveRecord::RecordNotFound ([#9385](http://projects.theforeman.org/issues/9385))

### Content Views
 * Publishing an existing CV with a previous deletion of Puppet Environment ends up with Error "Validation failed: Puppet environment can't be blank" ([#10435](http://projects.theforeman.org/issues/10435), [99c1a67e](http://github.com/katello/katello/commit/99c1a67ece5fea9329d73af1dc62380d519a6427))

### Dynflow
 * Capsule syncing should timeout if it is not picked up within a certain amount of time ([#10295](http://projects.theforeman.org/issues/10295))

### Other
 * Publish can fail with "No recipients found for RHEL View promotion summary" ([#10593](http://projects.theforeman.org/issues/10593), [47d352f5](http://github.com/katello/katello/commit/47d352f58ede63ec80ac78059b074f1b8c73c3b9))
 * Installation of custom certs causes httpd failure due to bad paths ([#10591](http://projects.theforeman.org/issues/10591))
 * TCP port for qdrouterd needs to be added to the docs ([#10472](http://projects.theforeman.org/issues/10472), [a6660b9b](http://github.com/katello//commit/a6660b9be189fcc0084dcae14f0a3676bffe7d81))
