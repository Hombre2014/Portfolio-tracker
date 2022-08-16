# Load the Rails application.
require_relative "application"

# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
app_env_var = File.join(Rails.root, 'config', 'app_env_var.rb')
load(app_env_var) if File.exists?(app_env_var)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  user_name: 'apikey', # This is the string literal 'apikey', NOT the ID of your API key
  password: Rails.application.credentials.dig(:sendgrid, :api_key), # This is the secret sendgrid API key which was issued during API key creation
  domain: 'yuriy-portfolio-tracker.herokuapp.com',
  address: 'smtp.sendgrid.net',
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}
