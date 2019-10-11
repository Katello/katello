# 3.13.1 Baltic Porter (2019-10-11)

## Features

## Bug Fixes

### Content Views
 * cannot publish a content view in location other than default smart proxy's.   "Couldn't find SmartProxy with 'id'=1 [WHERE (1=0)]" ([#27864](https://projects.theforeman.org/issues/27864), [07265e01](https://github.com/Katello/katello.git/commit/07265e019def1b48771b4726d544dd9c01bd7b6b))
 * Unable to remove puppet module by uuid from content-view using hammer ([#27718](https://projects.theforeman.org/issues/27718), [7f33b149](https://github.com/Katello/katello.git/commit/7f33b149e5809aa3f215f2821db26000b26b397f))

### Orchestration
 * deadlock on org delete  ([#27849](https://projects.theforeman.org/issues/27849), [1d9378f3](https://github.com/Katello/katello.git/commit/1d9378f3453cf644302e1d775171d4f6c4867fe6))

### Hosts
 * Setting to toggle host profile stealing ([#27840](https://projects.theforeman.org/issues/27840), [7f28e8d4](https://github.com/Katello/katello.git/commit/7f28e8d4dfe67c22b5a5befa9347d1dbbf5a415f))
 * Allow registration when host is unregistered and DMI UUID has changed ([#27739](https://projects.theforeman.org/issues/27739), [0095f03f](https://github.com/Katello/katello.git/commit/0095f03fde5a218dec4e6d624c267195fc423bd8))

### Inter Server Sync
 * Unable to import content view when there are more than 20 of enabled repositories in the target Satellite ([#27807](https://projects.theforeman.org/issues/27807), [4436da5f](https://github.com/Katello/hammer-cli-katello.git/commit/4436da5f24eececad4d4ee9cee19564189190b50))

### Foreman Proxy Content
 * Full Capsule sync doesn't fix the broken repository metadata. ([#27776](https://projects.theforeman.org/issues/27776), [ea10fe85](https://github.com/Katello/katello.git/commit/ea10fe85b241077217511d5002b16d3f5d7ef167))

### Host Collections
 * Incorrect error handling for Update all packages via Remote Execution ([#27768](https://projects.theforeman.org/issues/27768), [3a485398](https://github.com/Katello/katello.git/commit/3a485398c78a42ad02fb19989a5d09f919f147ea))

### Hammer
 * hammer content-view info does not provide information about the newly added "solve_dependencies" option or the "force_puppet_environment" option ([#27715](https://projects.theforeman.org/issues/27715), [a89d742c](https://github.com/Katello/hammer-cli-katello.git/commit/a89d742cad087b293cb38213456b3ced8962e2cc), [9cf4e366](https://github.com/Katello/hammer-cli-katello.git/commit/9cf4e366dc07a6d2f420a052d0045080c503be13))

### Subscriptions
 * Accessing the subscriptions from "Add subscriptions" page redirecting it to either other subscription details or shows 'undefined' or 'no resource loaded' ([#27614](https://projects.theforeman.org/issues/27614), [cfcf11d3](https://github.com/Katello/katello.git/commit/cfcf11d3946aae365bba4468153430f971a6419d))

### Other
 * Allow override of dmi.system.uuid from server side ([#27497](https://projects.theforeman.org/issues/27497), [fd0040f7](https://github.com/Katello/katello.git/commit/fd0040f7377af86cb640214ec0c0d919effd0947))
