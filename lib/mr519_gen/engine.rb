# frozen_string_literal: true

module Mr519Gen
  class Engine < ::Rails::Engine
    isolate_namespace Mr519Gen

    initializer :append_migrations do |app|
      unless app.root.to_s === root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
