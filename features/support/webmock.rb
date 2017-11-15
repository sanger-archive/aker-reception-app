require 'webmock/cucumber'
WebMock.disable_net_connect!(allow_localhost: true)
WebMock.disable_net_connect!(allow: 'fonts.googleapis.com')
