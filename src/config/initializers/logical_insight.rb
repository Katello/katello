if Katello.config.logical_insight
  require "logical-insight"
  Rails.application.config.middleware.use "Insight::App", :secret_key => false, :ip_masks => false
end
