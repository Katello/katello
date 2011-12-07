# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Src::Application.initialize!

GettextI18nRails.translations_are_html_safe = true
