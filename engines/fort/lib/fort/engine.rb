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

module Fort
  class Engine < ::Rails::Engine

    config.to_prepare do
      ::System.send :include, Fort::Concerns::System
    end

    initializer "fort.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += Fort::Engine.paths['db/migrate'].existent
    end

    config.after_initialize do
      Dir[File.expand_path('../actions/*.rb', __FILE__)].each { |f| require f }
    end

  end
end
