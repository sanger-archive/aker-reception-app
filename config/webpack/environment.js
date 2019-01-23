const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')
const webpack = require('webpack')

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    'window.jQuery': 'jquery',
    'window.jquery': 'jquery',
    'window.$': 'jquery'
  })
)

environment.loaders.append('erb', erb)
module.exports = environment
