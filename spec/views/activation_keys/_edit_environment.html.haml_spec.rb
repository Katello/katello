
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'

describe "activation_keys/_edit_environment.html.haml" do
  before(:each) do
    @organization = assign(:organization, stub_model(Organization,
      :name => "Test Org"))

    @key_name = "New Key"
    @key_description = "This is a new activation key"

    @activation_key = assign(:activation_key, stub_model(ActivationKey,
      :name => @key_name,
      :description => @key_description,
      :organization => @organization
    ))

    view.stub_chain(:current_organization, :environments).and_return([])
  end

  it "renders an input element for the env selected" do
    render
    assert_select "input[name='activation_key[environment_id]']", {:count => 1}
  end

  it "renders a select element for the system template" do
    render
    assert_select "select[name='activation_key[system_template_id]']", {:count => 1}
  end

  it "renders a save button" do
    render
    assert_select "input#save_env[type=submit]", {:count => 1}
  end

end
