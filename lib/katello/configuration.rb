#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello

  # Katello::Configuration module contains all necessary code for Katello configuration.
  # Configuration is not dependent on any gem which allows loading configuration very early
  # (even before Rails). Therefore this configuration can be used anywhere
  # (Gemfile, boot scripts, stand-alone)
  #
  # Configuration access points are methods {Katello.config} and {Katello.early_config}, see method documentation.
  #
  # Default configuration values are stored in `src/config/katello_defaults.yml`. Default values can be overridden
  # in configuration files (`config/katello.yml` or `/etc/katello/katello.yml`)
  #
  # Configuration is represented with tree-like-structure defined with {Katello::Configuration::Node}. Node has
  # minimal Hash-like interface. Node is more strict than Hash. Differences:
  # * If undefined key is accessed an error NoKey is raised (keys with nil values has to be
  #   defined explicitly).
  # * Keys can be accessed by methods. `config.host` is equivalent to `config[:host]`
  # * All keys has to be Symbols, otherwise you get an ArgumentError
  #
  # AppConfig will work for now, but warning is printed to `$stderr`.
  #
  # Some examples
  #
  #     !!!txt
  #     # create by a Hash which is converted to Node instance
  #     irb> n = Katello::Configuration::Node.new 'a' => nil
  #     => #<Katello::Configuration::Node:0x10e27b618 @data={:a=>nil}>
  #
  #     # assign a value, also converted
  #     irb> n[:a] = {'a' => 12}
  #     => {:a=>12}
  #     irb> n
  #     => #<Katello::Configuration::Node:0x10e2cd2b0 @data=
  #         {:a=>#<Katello::Configuration::Node:0x10e2bcb40 @data={:a=>12}>}>
  #
  #     # accessing a key
  #     irb> n['a']
  #     ArgumentError: "a" should be a Symbol
  #     irb> n[:a]
  #     => #<Katello::Configuration::Node:0x10e2bcb40 @data={:a=>12}>
  #     irb> n[:not]
  #     Katello::Configuration::Node::NoKey:  missing key 'not' in configuration
  #
  #     # supports deep_merge and #to_hash
  #     irb> n.deep_merge!('a' => {:b => 34})
  #     => #<Katello::Configuration::Node:0x10e2cd2b0 @data=
  #         {:a=>#<Katello::Configuration::Node:0x10e2a64d0 @data={:a=>12, :b=>34}>}>
  #     irb> n.to_hash
  #     => {:a=>{:a=>12, :b=>34}}
  #
  module Configuration
    path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    $LOAD_PATH << path unless $LOAD_PATH.include? path

    require 'katello/configuration/node'
    require 'katello/configuration/validator'
    require 'katello/configuration/loader'
  end
end
