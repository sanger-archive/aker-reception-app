source 'https://rubygems.org'


# Force git gems to use secure HTTPS
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use sqlite3 as the database for Active Record
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
# ?
gem 'pry'
# ?
gem 'activeresource', github: 'rails/activeresource', branch: 'master'
# ?
gem 'bootstrap-table-rails'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
# ?
gem 'wicked'
# ?
gem 'bootstrap_form'
# ?
gem 'uuid'
# ?
gem 'select2-rails'
# ?
gem 'forgery'
# ?
gem 'pg'
# ?
gem 'zipkin-tracer'
# Pure Ruby LDAP library. Read more: https://github.com/ruby-ldap/ruby-net-ldap
gem 'net-ldap'
# Devise Module for LDAP. Read more: https://github.com/cschiewek/devise_ldap_authenticatable
gem 'devise_ldap_authenticatable', '~> 0.8.5'
# ?
gem 'bunny', '= 0.9.0.pre10'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
# ?
gem 'font-awesome-sass'


###
# Sanger gems
###
# Add simple support for print-my barcode)
gem 'pmb-client', '0.1.0', github: 'sanger/pmb-client'
# ?
gem 'aker-set-client', github: 'sanger/aker-set-client'
# ?
gem 'matcon_client', github: 'sanger/aker-matcon-client'
# ?
gem 'aker_stamp_client', github: 'sanger/aker-stamp-client'
# ?
gem 'json_api_client', github: 'sanger/json_api_client'
# ?
gem 'aker_credentials_gem', github: 'sanger/aker-credentials'
# ?
gem 'aker_permission_gem', github: 'sanger/aker-permission'
# Official Sass port of Bootstrap 2 and 3. http://getbootstrap.com/css/#sass
gem 'bootstrap-sass', '~> 3.3.6', github: 'sanger/bootstrap-sass'

gem 'aker-taxonomy-client', github: 'sanger/aker-taxonomy-client'

gem 'faraday-http-cache'

###
# Groups
###
# Development group
group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  # ?
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # ?
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Test group
group :test do
  # ?
  gem 'cucumber-rails', require: false
  # ?
  gem 'rspec-json_expectations'
  # ?
  gem 'timecop'
  # Code coverage for Ruby 1.9+ with a powerful configuration library and automatic merging of
  # coverage across test suites - https://github.com/colszowka/simplecov
  gem 'simplecov', require: false
  # SimpleCov formatter to generate a simple index.html Rcov style
  # https://github.com/fguillen/simplecov-rcov
  gem 'simplecov-rcov'
  # ?
  gem 'rubycritic'
end

# Development and test groups
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  #gem 'byebug', platform: :mri
  # ?
  gem 'sqlite3'
  # ?
  gem 'webmock'
  # ?
  gem 'rspec-rails', '~> 3.4'
  # ?
  gem 'launchy'
  # ?
  gem 'capybara'

  gem 'sinatra'

  gem 'capybara-webmock'

  # ?
  gem 'poltergeist'
  # ?
  gem 'factory_bot_rails', '~> 4.8'
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
end

# Deployment group
group :deployment do
  # ?
  gem 'psd_logger', github: 'sanger/psd_logger'
  # # ?
  gem 'gmetric', '~> 0.1.3'
  # ?
  gem 'exception_notification'
end
