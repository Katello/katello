# -*- coding: utf-8 -*-
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

module Foreman
  class ArchitecturesController < SimpleCRUDController

    resource_model ::Foreman::Architecture
    list_column :name, :label=>_("Name")
    sort_by :name

    before_filter :check_params, :only => [:update]

    helper :foreman

    def rules
      {
        :index => lambda{true},
        :items => lambda{true},
        :new => lambda{true},
        :create => lambda{true},
        :edit => lambda{true},
        :update => lambda{true},
        :destroy => lambda{true}
      }
    end

    def panel_options
      {
        :title => _('Architectures'),
        :create => _("Architecture"),
        :create_label => _('+ New Architecture'),
        :ajax_scroll => items_architectures_path,
      }
    end

    def check_params
      params['architecture'] ||= {}
      params['architecture']['operatingsystem_ids'] ||= []
    end

  end
end
