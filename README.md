# Katello

[![Build Status](https://ci.theforeman.org/buildStatus/icon?job=katello-nightly-release)](https://ci.theforeman.org/job/katello-nightly-release/)
[![Code Climate](https://codeclimate.com/github/Katello/katello/badges/gpa.svg)](https://codeclimate.com/github/Katello/katello)

## About

[Katello](https://www.theforeman.org/plugins/katello/) is a plugin for [Foreman](https://www.theforeman.org) that orchestrates content distribution and subscription management at scale across thousands of Enterprise Linux and Debian-based systems. Katello serves as an enterprise content gateway between external repositories and Foreman-managed hosts by synchronizing RPMs, container images, flatpaks, and more into versioned Content Views, promoting this content through isolated Lifecycle Environments. Katello provides Foreman hosts with first-class content, subscription, and entitlement management.

Full user documentation is available at https://docs.theforeman.org/release/nightly/index-katello.html. Use the selection in the upper right to select your Foreman/Katello version.

## Found a bug?

That's rather unfortunate. But don't worry; we can help! Just file a bug [in our project tracker](https://projects.theforeman.org/projects/katello).

## Development and Contributing

Katello welcomes community contributions! We typically review community pull requests within a week. All pull requests are required to reference a valid Katello issue on Foreman's [project tracker](https://projects.theforeman.org/projects/katello/issues). Please view existing PRs to get a sense of our contribution standards.

To set up Katello for development, we recommend using [forklift](https://github.com/theforeman/forklift) to set up a virtual machine with the Katello codebase checked out and pre-configured. Please use the forklift documentation found in the repository above for further information. Once your environment is checked out, view our [developer quick reference guide](https://github.com/Katello/katello/blob/master/developer_docs/quick_reference.md) for information on running your Katello development server.

Please see our [development guidelines](https://www.theforeman.org/plugins/katello/developers.html). Katello source follows the following style guidelines:

* [Ruby guidelines](https://theforeman.org/handbook.html#Ruby)
* [Javascript guidelines](https://theforeman.org/handbook.html#JavaScript)

If you have questions about or issues with deploying a development environment, feel free to ask for assistance in our [matrix channel](https://matrix.to/#/#theforeman:matrix.org) or our [community forum](https://community.theforeman.org/)

## Annotated Pulp and Candlepin Workflows and test Scenarios

See the [annotation docs](./test/scenarios/annotations/README.md) for more information.

## Contact & Resources

 * [theforeman.org](https://theforeman.org/plugins/katello)
 * [Discourse Forum](https://theforeman.org/support.html#DiscourseForum)
 * [Support Matrix channel](https://matrix.to/#/#theforeman:matrix.org)
 * [Developer Matrix channel](https://matrix.to/#/#theforeman-dev:matrix.org)
