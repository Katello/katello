#
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

describe "activation_keys/index.html.haml" do
  before(:each) do
    @activation_keys = assign(:activation_keys, [
      stub_model(ActivationKey,
        :name => "key 1",
        :description => "this is key 1"
      ),
      stub_model(ActivationKey,
        :name => "key 2",
        :description => "this is key 2"
      )
    ])

    # these are dummy options... in reality, the controller will pass several options
    @panel_options = assign(:panel_options, { :title => "Activation Keys" })

    view.stub(:help_tip_button)
    view.stub(:help_tip)
    view.stub(:two_panel)
  end

  it "renders a helptip buttons" do
    # look for invocation of the helper which will render the appropriate html
    view.should_receive(:help_tip_button).once
    render
  end

  it "renders a helptip" do
    # look for invocation of the helper which will render the appropriate html
    view.should_receive(:help_tip).once
    render
  end

  it "renders using 2 pane layout consisting of activation keys and options" do
    # look for invocation of the helper which will render the appropriate html
    view.should_receive(:two_panel).with(@activation_keys, @panel_options).once
    render
  end

  it "renders a placeholder for the environment edit dialog" do
    render
    assert_select "div#environment_edit_dialog", {:count => 1}
  end
end
