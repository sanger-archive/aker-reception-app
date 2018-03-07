# Adds request_id from the RequestStore into a Faraday request
class RequestIdMiddleware < ::Faraday::Middleware

  def call(env)
    env[:request_headers]['X-Request-Id'] = RequestStore.store[:request_id] if RequestStore.store[:request_id]
    @app.call(env)
  end

end