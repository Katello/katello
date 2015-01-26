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

require 'katello_test_helper'

module Katello
  describe Repository do
    let(:repository) do
      repository = Repository.new(attributes_for(:katello_repository))
      repository.product = build(:katello_product)
      repository.gpg_key = build(:katello_gpg_key)
      repository.stubs(:content_id).returns("content_id-rand#{rand(100)}")
      repository
    end

    it "should contain delete Candlepin::Content orchestration" do
      repository._destroy_callbacks.select { |cb| cb.kind.eql?(:before) }.collect(&:filter).include?(:destroy_content_orchestration)
    end

    it "should retrieve remote content first time it's accessed (katello)" do #TODO: headpin
      Candlepin::Content.expects(:find).with(repository.content_id)
      repository.content
    end

    it "should update content when a gpg key is added and there was none before (katello)" do #TODO: headpin
      repository.stubs(:gpg_key_id_was).returns(nil)
      repository.stubs(:gpg_key_id).returns(rand(100))
      repository.stubs(:content).returns(Candlepin::Content.new(:gpgUrl => ""))

      repository.should_update_content?.must_equal(true)
    end

    it "should update content when an existing gpg key is removed (katello)" do #TODO: headpin
      repository.stubs(:gpg_key_id_was).returns(rand(100))
      repository.stubs(:gpg_key_id).returns(nil)
      repository.stubs(:content).returns(Candlepin::Content.new(:gpgUrl => "#{rand(100)}"))

      repository.should_update_content?.must_equal(true)
    end
  end
end
