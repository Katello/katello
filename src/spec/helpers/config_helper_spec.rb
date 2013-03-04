# makes application think that it's in headpin mode
def stub_headpin_mode
  Katello.config.stub(:katello? => false, :headpin? => true, :app_mode => 'headpin')
end

def stub_katello_mode
  Katello.config.stub(:katello? => true, :headpin? => false, :app_mode => 'katello')
end