#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Fort
  class Engine < ::Rails::Engine

    isolate_namespace Fort

    initializer 'fort.mount_engine', :after => :build_middleware_stack do |app|
      app.routes_reloader.paths << "#{Fort::Engine.root}/config/mount_engine.rb"
    end

    config.to_prepare do
      Katello::System.send :include, Fort::Concerns::System
    end

    initializer "fort.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += Fort::Engine.paths['db/migrate'].existent
    end

    config.after_initialize do
      require File.expand_path("../../app/models/node", File.dirname(__FILE__))
    end

    rake_tasks do
      load "#{Fort::Engine.root}/lib/fort/tasks/test.rake"
    end

    initializer "fort.paths" do |app|
      app.routes_reloader.paths << "#{Fort::Engine.root}/config/routes.rb"
    end

  end
end
