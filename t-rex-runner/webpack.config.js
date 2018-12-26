const path = require("path");
const { EnvironmentPlugin } = require("webpack");
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
          deadCodeInjectionThreshold: 0.2,
          controlFlowFlattening: false,
          controlFlowFlatteningThreshold: 0.4,
          // debugProtection: true,
          // debugProtectionInterval: true,
          disableConsoleOutput: true,
          identifierNamesGenerator: "hexadecimal",
          log: false,
          rotateStringArray: true,
          stringArray: true,
          stringArrayEncoding: "rc4",
          stringArrayThreshold: 0.5,
          renameGlobals: true,
          // transformObjectKeys: true,   // This breaks the build
          unicodeEscapeSequence: false
        })
      ]
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /(node_modules|bower_components)/,
          use: {
            loader: "babel-loader",
            options: {
              presets: [
                [
                  "@babel/preset-env",
                  {
                    targets: {
                      chrome: 59,
                      edge: 13,
                      firefox: 50
                    },
                    // For UglifyJS
                    forceAllTransforms: true
                  }
                ]
              ]
            }
          }
        },
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
          test: /\.(png|jpg|gif|svg)$/,
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
      new EnvironmentPlugin({
        NODE_ENV: mode
      }),
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
