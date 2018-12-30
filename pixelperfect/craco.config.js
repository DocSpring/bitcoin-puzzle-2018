const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
const WebpackBar = require('webpackbar');
const JavaScriptObfuscator = require('webpack-obfuscator');
const CracoAntDesignPlugin = require('craco-antd');
const path = require('path');

// Don't open the browser during development
process.env.BROWSER = 'none';

module.exports = {
  webpack: {
    plugins: [
      new WebpackBar({ profile: true }),
      ...(process.env.NODE_ENV === 'development'
        ? [new BundleAnalyzerPlugin({ openAnalyzer: false })]
        : []),
    ],
    configure: (webpackConfig, { env, paths }) => {
      // no source maps!
      webpackConfig.devtool = false;

      webpackConfig.optimization = webpackConfig.optimization || {};
      const optimization = webpackConfig.optimization;
      optimization.minimizer = optimization.minimizer || [];
      optimization.minimizer.push(
        new JavaScriptObfuscator(
          {
            compact: true,
            selfDefending: true,
            deadCodeInjection: true,
            deadCodeInjectionThreshold: 0.2,
            controlFlowFlattening: false,
            controlFlowFlatteningThreshold: 0.4,
            // debugProtection: true,
            // debugProtectionInterval: true,
            disableConsoleOutput: true,
            identifierNamesGenerator: 'hexadecimal',
            log: false,
            rotateStringArray: true,
            stringArray: true,
            stringArrayEncoding: 'rc4',
            stringArrayThreshold: 0.5,
            renameGlobals: true,
            // transformObjectKeys: true,   // This breaks the build
            unicodeEscapeSequence: false,
          },
          ['**/1.*', '**/runtime~main.*']
        )
      );
      debugger;
      return webpackConfig;
    },
  },
  plugins: [
    // { plugin: require('craco-preact') },
    {
      plugin: CracoAntDesignPlugin,
      options: {
        customizeThemeLessPath: path.join(
          __dirname,
          'src/style/AntDesign/customTheme.less'
        ),
      },
    },
  ],
};
