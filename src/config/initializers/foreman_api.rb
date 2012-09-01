module ForemanApi
  def self.client_config
    @client_config = { :base_url => ::AppConfig.foreman.url,
                       :oauth    => { :consumer_key    => ::AppConfig.foreman.consumer_key,
                                      :consumer_secret => ::AppConfig.foreman.consumer_secret }}
  end
end