module.exports = {
  entry: "./src/index.js",

  output: {
    path: __dirname + "/dist",
    filename: "main.js",
  },

  devServer: {
    static: "dist",
    open: true,
  },
};
