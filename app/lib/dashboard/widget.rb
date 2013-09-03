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

class Dashboard::Widget
  include Rails.application.routes.url_helpers

  def initialize(organization)
    @organization = organization
  end

  def accessible?
    true
  end

  def name
    self.class.name.demodulize.underscore[/(.*)_widget/, 1]
  end

  def title
    "Widget"
  end

  def content_path
    nil
  end

  private

  # rubocop:disable TrivialAccessors
  def current_organization
    @organization
  end

end
