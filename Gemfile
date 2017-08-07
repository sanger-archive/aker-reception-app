source 'https://rubygems.org'

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
gem 'pry'

gem 'activeresource', github: 'rails/activeresource', branch: 'master'

gem 'json_api_client', github: 'sanger/json_api_client'
# Add simple support for print-my barcode)
gem 'pmb-client', '0.1.0', :github => 'sanger/pmb-client'


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

gem 'wicked'
gem 'bootstrap_form'
gem 'uuid'
gem 'select2-rails'
gem 'forgery'

gem 'pg'
gem 'zipkin-tracer'

gem 'aker-set-client', github: 'sanger/aker-set-client'
gem 'aker-study-client', github: 'sanger/aker-study-client'
gem 'matcon_client', github: 'sanger/aker-matcon-client'
gem 'aker_stamp_client', github: 'sanger/aker-stamp-client'
#gem 'material_service_client', '~> 1.0.1', github: 'sanger/material_service_client_gem'

gem 'bootstrap-table-rails'

gem 'aker_credentials_gem', :github => 'sanger/aker-credentials'
gem 'aker_authentication_gem', :github => 'sanger/aker-authentication'
gem 'aker_permission_gem', :github => 'sanger/aker-permission'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'sqlite3'

end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'bootstrap-sass', '~> 3.3.6'
gem 'font-awesome-sass'
group :development, :test do
  gem 'webmock'
  gem 'rspec-rails', '~> 3.4'
  gem 'launchy'
  gem 'capybara'
  gem 'poltergeist'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'rspec-json_expectations'
  # database_cleaner is not required, but highly recommended
end


gem 'simplecov', :require => false, :group => :test
gem 'simplecov-rcov', :group => :test
gem 'rubycritic', :group => :test

gem "exception_notification"
group :deployment do
  gem "psd_logger",
    :github => "sanger/psd_logger"
  gem "gmetric", "~>0.1.3"
  gem "exception_notification"
end
