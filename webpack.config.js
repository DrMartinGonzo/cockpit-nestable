// webpack.config.js
const path = require('path');
const webpack = require('webpack');
const isProd = process.env.NODE_ENV === 'production';

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'field-nestable-components.js',
  },
  mode: isProd ? 'production' : 'development',
  devtool: isProd ? false : 'inline-source-map',
  externals: {
    riot: 'riot',
  },
  module: {
    rules: [
      {
        test: /\.tag$/,
        exclude: /node_modules/,
        loader: 'riot-tag-loader',
        query: {
          type: 'es6', // transpile the riot tags using babel
          hot: true,
        },
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
      },
    ],
  },
};
