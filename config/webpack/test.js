process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

var nodeExternals = require('webpack-node-externals');

module.exports = environment.toWebpackConfig().merge({
  externals: [nodeExternals()], // in order to ignore all modules in node_modules folder from bundling  
})
