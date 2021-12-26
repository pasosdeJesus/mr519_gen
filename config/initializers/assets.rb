Rails.application.config.assets.paths << Rails.root.join('node_modules/gristack')

Rails.application.config.assets.precompile << 'gridstack.js'
Rails.application.config.assets.precompile << 'gridstack.jQueryUI.js'
