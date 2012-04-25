require "logical-insight"

if AppConfig.logical_insight
  Rails.application.config.middleware.use "Insight::App", :secret_key => false, :ip_masks => false
end
