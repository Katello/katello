#
## Copyright 2011 Red Hat, Inc.
##
## This software is licensed to you under the GNU General Public
## License as published by the Free Software Foundation; either version
## 2 of the License (GPLv2) or (at your option) any later version.
## There is NO WARRANTY for this software, express or implied,
## including the implied warranties of MERCHANTABILITY,
## NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
## have received a copy of GPLv2 along with this software; if not, see
## http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


class Api::GpgKeysController < Api::ApiController

  skip_filter   :set_locale, :require_user, :thread_locals, :authorize, :only => [:content]
  before_filter :find_gpg_key,                                          :only => [:content]

  # returns the content of a repo gpg key, used directly by yum
  # I've amended REST best practices(e.g. not using the show action) as we don't want to
  # authenticate, authorize etc, trying to distinquse between a yum request and normal api request
  # might not always be 100% bullet proof, and its more important that yum can fetch the key.
  def content
    @gpg_key.content.present? ? render(:text => @gpg_key.content, :layout => false) : head(404)
  end

  private
  def find_gpg_key
    @gpg_key = GpgKey.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render_exception(404, e)
  end

end
