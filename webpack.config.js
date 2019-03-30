const path = require('path');
const webpackMerge = require('webpack-merge');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const StyleLintPlugin = require('stylelint-webpack-plugin');

const modeConfig = env => require(`./build-tools/webpack.${env}`)(env);
const presetConfig = require("./build-tools/loadPresets");

module.exports = ({mode, presets} = {mode: "production", presets: []}) => {
    console.log(`Building for: ${mode}`);

    return webpackMerge({
            mode: mode,
            entry: path.join(__dirname, './src/static/index.js'),
            module: {
                rules: [
                    {
                        test: /\.html$/,
                        exclude: /node_modules/,
                        loader: 'file-loader?name=[name].[ext]'
                    },
                    {
                        test: /\.(eot|svg|ttf|woff|woff2)$/,
                        loader: 'file-loader'
                    }
                ]
            },
            plugins: [
                // new HtmlWebpackPlugin({
                //     template: 'src/static/index.html',
                //     inject: 'body',
                //     filename: 'index.html',
                // }),

                new StyleLintPlugin(),

                // new CopyWebpackPlugin([
                //     { from: 'src/assets/favicon.ico' }
                // ]),
            ]
        },
        modeConfig(mode),
        presetConfig({mode: mode, presets: presets})
    );
};
