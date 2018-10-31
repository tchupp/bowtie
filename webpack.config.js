module.exports = {
    entry: './src/static/index.js',
    module: {
        rules: [
            {
                test: /\.html$/,
                exclude: /node_modules/,
                loader: 'file-loader?name=[name].[ext]'
            },
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                // This is what you need in your own work
                // loader: "elm-webpack-loader",
                loader: 'elm-webpack-loader',
                options: {
                    debug: true
                }
            }
        ]
    },
    devServer: {
        inline: true,
        contentBase: './src',
        stats: 'errors-only'
    }
};
