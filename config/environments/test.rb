Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.material_url = 'http://localhost:5000'
  ENV['MATERIALS_URL'] = config.material_url
  config.set_url = 'http://localhost:1500/api/v1/'
  config.set_url_default_proxy = 'http://localhost:1500'
  config.ownership_url = 'http://localhost:4000/ownerships'
  config.ownership_url_default_proxy = 'http://localhost:4000'
  config.pmb_uri = ENV.fetch('PMB_URI', 'http://localhost:10000/v1')
  config.stamp_url = 'http://localhost:7000/api/v1/'
  config.study_url = 'http://localhost:3300/api/v1/'
  config.taxonomy_service_url = 'http://external-service/tax-id'

  config.aker_deployment_default_proxy = {}

  config.ehmdmc_url = 'http://localhost:3501/validate'
  config.show_hmdmc_warning = false

  config.printing_disabled = true

  config.jwt_secret_key = 'test'

  config.events = {
    enabled: false
  }

  config.fake_ldap = true

  config.auth_service_url = 'http://auth'
  config.login_url = config.auth_service_url + '/login'
  config.logout_url = config.auth_service_url + '/logout'

  config.urls = { reception: '',
                  permissions: '',
                  sets: '',
                  projects: '',
                  work: '' }

  config.ssr_groups = %w[team252 pirates]
end
