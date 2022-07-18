# Load the Rails application.
require_relative "application"

# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
app_env_var = File.join(Rails.root, 'config', 'app_env_var.rb')
load(app_env_var) if File.exists?(app_env_var)

# Initialize the Rails application.
Rails.application.initialize!
