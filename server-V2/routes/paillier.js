const express = require("express");
const router = express.Router();
const { spawn } = require("child_process");

// 获取密钥
router.get("/keygen", keygen);
//加密
router.post("/encrypt", encrypt);
// 解密
router.post("/decrypt", decrypt);
// 密文相加
router.post("/add_ciphers", add_ciphers);

function keygen(req, res) {
  const process = spawn("python", ["./python/paillier.py", "1"]);
  process.stdout.on("data", (data) => {
    var sol_str = data.toString().split(/(\r?\n)/g);
    console.log("sol_str", sol_str);
    res.send({ pubKeyN: sol_str[0], priKeyP: sol_str[2], priKeyQ: sol_str[4] });
  });
  process.stderr.on("data", (data) => {
    console.log(`e_add spawn error:${data}`);
    res.status(400).send("e_add spawn error");
  });
}

function encrypt(req, res) {
  const process = spawn("python", [
    "./python/paillier.py",
    "2",
    req.body.pub,
    req.body.x,
  ]);
  process.stdout.on("data", (data) => {
    const sol_str = data.toString().split(/(\r?\n)/g);
    res.send({ cipher: sol_str[0] });
  });
  process.stderr.on("data", (data) => {
    console.log(`encrypt spawn error:${data}`);
    res.status(400).send("encrypt spawn error");
  });
}

function decrypt(req, res) {
  const process = spawn("python", [
    "./python/paillier.py",
    "3",
    req.body.pub,
    req.body.p,
    req.body.q,
    req.body.x,
  ]);
  process.stdout.on("data", (data) => {
    const sol_str = data.toString().split(/(\r?\n)/g);
    res.send({ text: sol_str[0] });
  });
  process.stderr.on("data", (data) => {
    console.log(`Cipher decrypt spawn error:${data}`);
    res.status(400).send("Cipher decrypt spawn error");
  });
}

function add_ciphers(req, res) {
  const process = spawn("python", [
    "./python/paillier.py",
    "4",
    req.body.pub,
    req.body.x,
    req.body.y,
  ]);
  process.stdout.on("data", (data) => {
    const sol_str = data.toString().split(/(\r?\n)/g);
    res.send({ aAddb: sol_str[0] });
  });
  process.stderr.on("data", (data) => {
    console.log(`add spawn error:${data}`);
    res.status(400).send("add spawn error");
  });
}

module.exports = router;
