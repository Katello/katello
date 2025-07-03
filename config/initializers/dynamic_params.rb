Rails.application.config.after_initialize do
  Katello::Api::V2::RepositoriesController.include Katello::Concerns::Api::V2::DynamicParams::Repositories
end
