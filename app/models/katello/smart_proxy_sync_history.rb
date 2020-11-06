module Katello
  class SmartProxySyncHistory < Katello::Model
    self.table_name = 'katello_smart_proxy_sync_history'

    belongs_to :smart_proxy, :class_name => "::SmartProxy", :inverse_of => :smart_proxy_sync_histories
    belongs_to :repository, :class_name => "Katello::Repository", :inverse_of => :smart_proxy_sync_histories
  end
end
