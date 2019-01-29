# frozen_string_literal: true

source 'https://rubygems.org'

# Force git gems to use secure HTTPS
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# All the gems not in a group will always be installed:
#   http://bundler.io/v1.6/groups.html#grouping-your-dependencies
gem 'activeresource', '~> 5.0' # Wrap your RESTful web app with Ruby classes
gem 'bootsnap', '~> 1.3', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'bootstrap-table-rails'
gem 'bootstrap_form'
gem 'bunny', '~> 2.9', '>= 2.9.2', require: false
gem 'coffee-rails', '~> 4.2' # Use CoffeeScript for .coffee assets and views
gem 'faraday-http-cache'
gem 'font-awesome-sass'
gem 'health_check'
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'js-routes'
gem 'lograge'
gem 'logstash-event'
gem 'logstash-logger'
gem 'net-ldap' # Pure Ruby LDAP library. Read more: https://github.com/ruby-ldap/ruby-net-ldap
gem 'pg', '~> 0.18' # pg version 1.0.0 is not compatible with Rails 5.1.4
gem 'puma', '~> 3.0' # Use Puma as the app server
gem 'rails', '~> 5.2.0'
gem 'request_store'
gem 'roo', '~> 2.7.0'
gem 'sassc-rails', '~> 1.3'
gem 'select2-rails'
gem 'therubyracer', platforms: :ruby # See https://github.com/rails/execjs#readme for more runtimes
gem 'turbolinks', '~> 5' # Turbolinks makes navigating your web application faster
gem 'uglifier', '~> 3.2' # Use Uglifier as compressor for JavaScript assets
gem 'uuid'
gem 'webpacker', '~> 3.5', '>= 3.5.3'
gem 'webpacker-react'
gem 'react-rails'
gem 'wicked'

###
# Sanger gems
###
gem 'aker_credentials_gem', github: 'sanger/aker-credentials'
gem 'aker_permission_gem', github: 'sanger/aker-permission'
gem 'aker-set-client', github: 'sanger/aker-set-client'
gem 'aker_stamp_client', github: 'sanger/aker-stamp-client'
gem 'aker_shared_navbar', github: 'sanger/aker-shared-navbar'
gem 'aker-taxonomy-client', github: 'sanger/aker-taxonomy-client'
gem 'bootstrap-sass', '~> 3.3.6', github: 'sanger/bootstrap-sass'
gem 'json_api_client', github: 'sanger/json_api_client'
gem 'matcon_client', github: 'sanger/aker-matcon-client'
gem 'pmb-client', '0.1.0', github: 'sanger/pmb-client'

###
# Groups
###
group :development, :test do
  gem 'brakeman', require: false
  gem 'byebug', platform: :mri
  gem 'database_cleaner' # database_cleaner is not required, but highly recommended
  gem 'factory_bot_rails', '~> 4.8'
  gem 'launchy'
  gem 'rspec-rails', '~> 3.4'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'pry-rails', '~> 0.3.6' # An IRB alternative and runtime developer console
  gem 'rubocop', '~> 0.51.0', require: false # A Ruby static code analyzer
  gem 'rubocop-rspec'
  gem 'spring' # Spring speeds up development by keeping your application running in the background
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console' # Access an IRB console on exception pages or by using <%= console %> anywhere
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'chromedriver-helper' #, '~> 1.0'
  gem 'poltergeist'
  gem 'rake'
  gem 'rspec-json_expectations'
  gem 'rubycritic'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false # Code coverage for Ruby 1.9+
  gem 'simplecov-rcov'
  gem 'timecop'
end
