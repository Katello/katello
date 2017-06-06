require 'spec_helper'

describe Repository do

  let(:repository) do
    repository = Repository.new.tap do |r|
      r.id = rand(100)
      r.name = "name-#{rand(100)}"
      r.environment_product = EnvironmentProduct.new(
          :environment => KTEnvironment.new(:organization => Organization.new(:label => "organization-label-#{100}")),
          :product => Product.new(:label => "product-label-#{rand(100)}"))
      r.label = "label-#{rand(100)}"
      r.gpg_key = GpgKey.new(:content => "rand(100")
    end
    repository.stub(:content_id).and_return("content_id-rand#{rand(100)}")
    repository
  end

  it "should contain create/update Candlepin::Content orchestration" do
    repository._save_callbacks.select {|cb| cb.kind.eql?(:before)}.collect(&:filter).include?(:save_content_orchestration)
  end

  it "should contain delete Candlepin::Content orchestration" do
    repository._destroy_callbacks.select {|cb| cb.kind.eql?(:before)}.collect(&:filter).include?(:destroy_content_orchestration)
  end

  it "should retrieve remote content first time it's accessed", :katello => true do #TODO headpin
    Candlepin::Content.should_receive(:find).with(repository.content_id)
    repository.content
  end

  it "should update content when a gpg key is added and there was none before", :katello => true do #TODO headpin
    repository.stub(:gpg_key_id_was).and_return(nil)
    repository.stub(:gpg_key_id).and_return(rand(100))
    repository.stub(:content).and_return(Candlepin::Content.new(:gpgUrl => ""))

    repository.should_update_content?.should == true
  end

  it "should update content when an existing gpg key is removed", :katello => true do #TODO headpin
    repository.stub(:gpg_key_id_was).and_return(rand(100))
    repository.stub(:gpg_key_id).and_return(nil)
    repository.stub(:content).and_return(Candlepin::Content.new(:gpgUrl => "#{rand(100)}"))

    repository.should_update_content?.should == true
  end

  it "should call update on content in update_content", :katello => true do #TODO headpin
    remote_content = double("Candlepin::Content")
    remote_content.stub(:update).and_return(remote_content)
    Candlepin::Content.stub(:find).and_return(remote_content)
    repository.stub(:should_update_content?).and_return(true)

    remote_content.should_receive(:update).with(hash_including(
      :name => repository.name,
      :contentUrl => Glue::Pulp::Repos.custom_content_path(repository.product, repository.label),
      :gpgUrl => repository.yum_gpg_key_url,
      :label => repository.custom_content_label,
      :type => "yum",
      :vendor => Provider::CUSTOM
    ))

    repository.update_content
  end

  # If some of tests in following describe block is broken, read this carefully!
  # Situation where two products share same Candlepin content can occur. This happens during
  # manifest import in Candlepin so katello has no control over it. However when deleting content
  # we must be sure that there is no other product using this content. That's why this test makes
  # sure we decide based on #other_repos_with_same_content method whether we delete content or not.
  describe "#del_content" do
    before do
      repository.stub :other_repos_with_same_product_and_content => []
      repository.product.stub :remove_content_by_id => true
      repository.product.stub :provider => mock("provider", :redhat_provider? => false)
    end

    context "there isn't another product using same candlepin content" do
      before { Resources::Candlepin::Content.should_receive(:destroy).once }
      it "should delete CP content", :katello => true do #TODO headpin
        repository.del_content
      end
    end

    context "there is another product using same candlepin content" do
      before do
        Resources::Candlepin::Content.should_not_receive(:destroy)
        repository.stub :other_repos_with_same_content => ['not', 'empty']
      end
      it "should not delete CP content", :katello => true do #TODO headpin
        repository.del_content
      end
    end
  end
end
