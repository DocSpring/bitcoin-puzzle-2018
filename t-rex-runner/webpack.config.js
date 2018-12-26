const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const JavaScriptObfuscator = require("webpack-obfuscator");

module.exports = (env, argv) => {
  const mode = argv.mode || "development";

  return {
    mode: mode,
    entry: "./src/index.js",
    output: {
      filename: "[name]-[contenthash].js",
      path: path.resolve(__dirname, "dist")
    },
    devServer: {
      contentBase: path.join(__dirname, "/public"),
      compress: true,
      port: 8080
    },
    optimization: {
      minimizer: [
        new UglifyJsPlugin({
          cache: true,
          parallel: true
        }),
        new OptimizeCSSAssetsPlugin({}),
        new JavaScriptObfuscator({
          compact: true,
          selfDefending: true,
          deadCodeInjection: true,
          controlFlowFlattening: true,
          debugProtection: true,
          debugProtectionInterval: true,
          rotateUnicodeArray: true,
          stringArrayEncoding: true,
          renameGlobals: true,
          transformObjectKeys: true
        })
      ]
    },
    module: {
      rules: [
        {
          test: /\.css$/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader
            },
            "css-loader"
          ]
        },
        {
          test: /\.(png|jpg|gif)$/,
          use: [
            {
              loader: "file-loader",
              options: { name: "[name]-[contenthash].[ext]" }
            }
          ]
        }
      ]
    },
    plugins: [
      new MiniCssExtractPlugin({
        // Options similar to the same options in webpackOptions.output
        // both options are optional
        filename: "[name]-[hash].css",
        chunkFilename: "[id].css"
      }),
      new HtmlWebpackPlugin({
        title: "Custom template using Handlebars",
        template: "src/index.html"
      })
    ]
  };
};
