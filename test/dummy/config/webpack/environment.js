// Siguiendo ejemplo de https://github.com/rails/webpacker/blob/master/docs/webpack.md

module.exports = {
  resolve: {
    alias: {
      'jquery-ui': 'jquery-ui/ui',
    }
  }
}

const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    'window.jQuery':'jquery',
    Popper: ['popper.js', 'default'],
    tinycolor: 'tinycolor2'
  })
)

environment.loaders.append('expose', {
  test: require.resolve('jquery'),
  use: [
    { loader: 'expose-loader', options: '$' },
    { loader: 'expose-loader', options: 'jQuery' },
    { loader: 'expose-loader', options: 'tinycolor' }
  ]
})

module.exports = environment
