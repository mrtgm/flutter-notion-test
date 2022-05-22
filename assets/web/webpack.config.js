const env = process.env.NODE_ENV || "development";
const webpack = require("webpack");

module.exports = {
  mode: env,

  entry: "./src/index.js",

  target: ["web", "es5"],

  output: {
    path: __dirname + "/dist",
    filename: "main.js",
    libraryTarget: "var",
    library: "RenderMd",
  },

  devServer: {
    static: "dist",
    open: true,
  },

  module: {
//    rules: [
//      {
//        test: /\.js$/i,
//        exclude: /node_modules/,
//        use: {
//          loader: "babel-loader",
//          options: {
//            presets: [["@babel/preset-env", { useBuiltIns: "usage", corejs: "3" }]],
//            cacheDirectory: true,
//          },
//        },
//      },
//    ],
  },

  plugins: [new webpack.EnvironmentPlugin(["NOTION_API_KEY"])],
};
