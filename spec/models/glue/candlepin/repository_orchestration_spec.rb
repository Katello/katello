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

  it "should retrieve remote content first time it's accessed" do
    Candlepin::Content.should_receive(:find).with(repository.content_id)
    repository.content
  end

  it "should update content when a gpg key is added and there was none before" do
    repository.stub(:gpg_key_id_was).and_return(nil)
    repository.stub(:gpg_key_id).and_return(rand(100))
    repository.stub(:content).and_return(Candlepin::Content.new(:gpgUrl => ""))

    repository.should_update_content?.should == true
  end

  it "should update content when an existing gpg key is removed" do
    repository.stub(:gpg_key_id_was).and_return(rand(100))
    repository.stub(:gpg_key_id).and_return(nil)
    repository.stub(:content).and_return(Candlepin::Content.new(:gpgUrl => "#{rand(100)}"))

    repository.should_update_content?.should == true
  end

  it "should call update on content in update_content" do
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
end
