const webpack = require('webpack');
const merge = require('webpack-merge');
const common = require('./webpack.common.js');

module.exports = merge(common, {
  mode: 'development',
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        include: /node_modules/,
        use: ['react-hot-loader/webpack'],
      },
    ],
  },
  devServer: {
    contentBase: './dist',
    hot: true,
    port: 9000,
  },
  devtool: 'eval-source-map',
  plugins: [new webpack.HotModuleReplacementPlugin()],
});
