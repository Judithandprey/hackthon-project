Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.assume_ssl = true
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
  config.public_file_server.enabled = true
  config.log_level = :info
  config.logger = ActiveSupport::Logger.new($stdout)
  config.active_record.dump_schema_after_migration = false
  config.secret_key_base = ENV.fetch("SECRET_KEY_BASE")
end
