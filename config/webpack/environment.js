const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// [PJ] add jQuery and papaparse here so that it remains available to all JS files
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    'window.jQuery': 'jquery',
    'window.jquery': 'jquery',
    'window.$': 'jquery',
    'Papa': 'papaparse',
  })
)

module.exports = environment
