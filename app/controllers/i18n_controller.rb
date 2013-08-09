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

class I18nController < ApplicationController
  before_filter :authorize

  def rules
    show_test = lambda {User.current}
    {:show => show_test}
  end

  def show
    respond_to do |format|
      format.json { render :json => render_to_string(:partial => 'dictionary')}
    end
  end
end
