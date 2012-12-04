shared_examples_for "simple crud controller" do

  describe '#index' do
    let(:data) { [{ :a => 'a' }] }
    before do
      controller.foreman_model.stub :all => data
      get :index
    end

    it('renders collection of objects') { response.body.should == data.to_json }
    it('be success') { response.should be_success }
  end

  describe '#show' do
    let(:data) { { :a => 'a' } }
    before do
      controller.foreman_model.stub :find! => data
      get :show, :id => 1
    end

    it('renders object') { response.body.should == data.to_json }
    it('be success') { response.should be_success }
  end

  describe '#create' do
    let(:a_model) { controller.foreman_model.new }
    before do
      a_model.stub :save! => true
      controller.foreman_model.stub :new => a_model
      get :create
    end

    it('renders object') {
      response.body.should == a_model.to_json({ })
    }
    it('be success') { response.should be_success }
  end

  describe '#update' do
    let(:model) { controller.foreman_model.new }
    before do
      model.stub :save! => true
      controller.foreman_model.stub :find! => model
      get :update, :id => 1
    end

    it('renders object') { response.body.should == model.to_json({ }) }
    it('be success') { response.should be_success }
  end

  describe '#destroy' do
    let(:model) { controller.foreman_model.new }
    before do
      model.stub :destroy! => true
      controller.foreman_model.stub :find! => model
      get :destroy, :id => 1
    end

    it('be success') { response.should be_success }
  end
end
