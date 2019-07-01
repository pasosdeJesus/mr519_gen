require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "mr519_gen"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.time_zone = 'America/Bogota'
    config.i18n.default_locale = :es
    config.x.formato_fecha = 'dd/M/yyyy'
    config.active_record.schema_format = :sql
    config.railties_order = [:main_app, Sip::Engine, :all]


    config.hosts << ENV['CONFIG_HOSTS'] || '127.0.0.1'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

