const path = require("path");
const DashboardPlugin = require('webpack-dashboard/plugin');
const webpack = require('webpack');

module.exports = () => ({
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: [
                    {loader: 'elm-hot-webpack-loader'},
                    {
                        loader: 'elm-webpack-loader',
                        options: {
                            cwd: path.join(__dirname, '../'),
                            debug: true
                        }
                    }
                ]
            },
            {
                test: /\.less$/,
                use: [
                    'style-loader',
                    'css-loader',
                    'postcss-loader',
                    'less-loader'
                ]
            }
        ]
    },

    plugins: [
        new webpack.HotModuleReplacementPlugin(),

        new DashboardPlugin(),
    ],

    devServer: {
        contentBase: './src/static',
        historyApiFallback: true,
        inline: true,
        stats: 'errors-only',
        hot: true,
    }
});