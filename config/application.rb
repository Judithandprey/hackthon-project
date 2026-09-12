require_relative "boot"
require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
Bundler.require(*Rails.groups)

module HabPortal
  class Application < Rails::Application
    config.load_defaults 7.2
    config.time_zone = "Pacific Time (US & Canada)"
    config.generators.system_tests = nil
    config.filter_parameters += [:password, :password_confirmation, :invite_code, :token]
  end
end
