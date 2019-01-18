const path = require("path");
const CopyWebpackPlugin = require("copy-webpack-plugin");

module.exports = {
  entry: "./src/index.js",
  output: {
    filename: "index.js",
    path: path.resolve(__dirname, "dist"),
  },
  plugins: [
    new CopyWebpackPlugin([{ from: "./src/index.html", to: "index.html" }]),
    new CopyWebpackPlugin([{ from: "./src/signup.html", to: "signup.html" }]),
    new CopyWebpackPlugin([{ from: "./src/customer.html", to: "customer.html" }]),
    new CopyWebpackPlugin([{ from: "./src/producer.html", to: "producer.html" }]),
    new CopyWebpackPlugin([{ from: "./src/dealer.html", to: "dealer.html" }]),
    new CopyWebpackPlugin([{ from: "./src/retailer.html", to: "retailer.html" }]),
    new CopyWebpackPlugin([{ from: "./src/query.html", to: "query.html" }]),
  ],
  devServer: { contentBase: path.join(__dirname, "dist"), compress: true },
};
