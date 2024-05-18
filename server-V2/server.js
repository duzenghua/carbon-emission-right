const express = require("express");

const bodyParser = require("body-parser");
const cors = require("cors");
const timeout = require("connect-timeout");
const app = express();
app.use(express.json())
app.use(express.urlencoded({extended:false}))

app.use(timeout("120s"));
app.use(cors());
// app.use(bodyParser.urlencoded({ extended: false }));

app.use("/", require("./routes/match"));
app.use("/paillier", require("./routes/paillier"));


app.get("/", (req, res) => {
  res.send("服务启动");
});


app.listen(3000, (res, req) => {
  console.log("服务已启动在3000端口");
});
