# Be sure to restart your server when you modify this file.
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'kt_environment' => 'KTEnvironment',
    'cdn' => 'CDN',
    'cveak_migrator' => 'CVEAKMigrator',
    'cvecf_migrator' => 'CVECFMigrator'
  )
end

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w(fish sheep)

  inflect.singular 'bases', 'base'

  inflect.acronym 'SCA' # Simple Content Access
  inflect.acronym 'CV' # Content view
end
