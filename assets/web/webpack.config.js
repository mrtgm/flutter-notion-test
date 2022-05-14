const env = process.env.NODE_ENV || "development";
const webpack = require("webpack");

module.exports = {
  mode: env,

  entry: "./src/index.js",

  output: {
    path: __dirname + "/dist",
    filename: "main.js",
  },

  devServer: {
    static: "dist",
    open: true,
  },

  plugins: [new webpack.EnvironmentPlugin(["NOTION_API_KEY"])],
};
