# frozen_string_literal: true

Dummy::Application.config.relative_url_root = ENV.fetch(
  "RUTA_RELATIVA", "/mr519"
)
Dummy::Application.config.assets.prefix = ENV.fetch(
  "RUTA_RELATIVA", "/mr519"
) + "/assets"
