OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Figaro.env.google_oauth_client_id, Figaro.env.google_oauth_secret_key, {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end