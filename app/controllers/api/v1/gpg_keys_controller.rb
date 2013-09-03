#
## Copyright 2013 Red Hat, Inc.
##
## This software is licensed to you under the GNU General Public
## License as published by the Free Software Foundation; either version
## 2 of the License (GPLv2) or (at your option) any later version.
## There is NO WARRANTY for this software, express or implied,
## including the implied warranties of MERCHANTABILITY,
## NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
## have received a copy of GPLv2 along with this software; if not, see
## http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


class Api::V1::GpgKeysController < Api::V1::ApiController

  skip_filter :set_locale, :require_user, :thread_locals, :authorize, :only => [:content]

  before_filter :find_gpg_key, :only => [:content, :show, :update, :destroy]
  before_filter :find_organization, :only => [:index, :create]
  before_filter :authorize, :except => [:content]

  def rules
    read_test   = lambda { @gpg_key.readable? }
    manage_test = lambda { @gpg_key.manageable? }
    create_test = lambda { GpgKey.createable?(@organization) }
    index_test  = lambda { GpgKey.any_readable?(@organization) }
    {
        :index   => index_test,
        :show    => read_test,
        :create  => create_test,
        :update  => manage_test,
        :destroy => manage_test
    }
  end

  def param_rules
    {
        :create => { :gpg_key => [:name, :content] },
        :update => { :gpg_key => [:name, :content] }
    }
  end

  def_param_group :gpg_key do
    param :gpg_key, Hash, :required => true, :action_aware => true do
      param :name, :identifier, :required => true, :desc => "identifier of the gpg key"
      param :content, String, :required => true, :desc => "public key block in DER encoding"
    end
  end

  api :GET, "/organizations/:organization_id/gpg_keys", "List gpg keys"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :name, :identifier, :desc => "identifier of the gpg key"
  def index
    gpg_keys = @organization.gpg_keys.where(params.slice(:name))
    render :json => gpg_keys, :only => [:id, :name]
  end

  api :GET, "/gpg_keys/:id", "Show a gpg key"
  param :id, :number, :desc => "gpg key numeric identifier"
  def show
    render :json => @gpg_key, :details => true
  end

  api :POST, "/organizations/:organization_id/gpg_keys", "Create a gpg key"
  param :organization_id, :identifier, :desc => "organization identifier"
  param_group :gpg_key
  def create
    gpg_key = @organization.gpg_keys.create!(params[:gpg_key].slice(:name, :content))
    respond :resource => gpg_key
  end

  api :PUT, "/gpg_keys/:id", "Update a gpg key"
  param_group :gpg_key
  def update
    @gpg_key.update_attributes!(params[:gpg_key].slice(:name, :content))
    respond :resource => @gpg_key
  end

  api :DELETE, "/gpg_keys/:id", "Destroy a gpg key"
  param :id, :number, :desc => "gpg key numeric identifier"
  def destroy
    @gpg_key.destroy
    respond :message => _("Deleted GPG key '%s'") % params[:id]
  end

  api :GET, "/gpg_keys/:id/content"
  param :id, :number, :desc => "gpg key numeric identifier"
  desc <<-EOS
Returns the content of a repo gpg key, used directly by yum
We've amended REST best practices (e.g. not using the show action) as we don't want to
authenticate, authorize etc, trying to distinquse between a yum request and normal api request
might not always be 100% bullet proof, and its more important that yum can fetch the key.
  EOS
  def content
    @gpg_key.content.present? ? render(:text => @gpg_key.content, :layout => false) : head(404)
  end

  private

  def find_gpg_key
    @gpg_key = GpgKey.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise HttpErrors::NotFound, _("Couldn't find GPG key '%s'") % params[:id]
  end

end
