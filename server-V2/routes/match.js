const express = require("express");
const router = express.Router();
const { execSync } = require("child_process");
const { getProof } = require("./getProof.js");

router.get("/match", match);

router.get("/getProof", getProof1);
function match(req, res) {
  const output = execSync("python ./python/match.py");
  console.log(output.toString());
  res.send("匹配成功");
}

async function getProof1(req, res) {
  const proof = await getProof(
    String(req.query.amount),
    String(req.query.quato)
  );
  res.send(proof);
}

module.exports = router;
