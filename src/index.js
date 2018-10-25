const express = require("express");
const PORT = 80;
const HOST = "0.0.0.0";

const app = express();
const promisify = require("util").promisify;
const exec = require("child_process").exec;
const readFile = promisify(require("fs").readFile);

const pathToChallenge = (host, key) => {
  host = host.toLowerCase();
  return `/var/www/chal/${host}/.well-known/acme-challenge/${key}`;
};

const def = async function(request, response, next) {
  console.log(request.headers.host);
  response.send("OK");
};
app.get("/", def);

const challenge = async function(request, response, next) {
  const cmd = `acme.sh --issue -d ${request.headers.host.toLowerCase()} -w /var/www/chal/${request.headers.host.toLowerCase()}`;
  console.log(cmd);
  try {
    exec(cmd);
  } catch (e) {}
  response.send("OK");
};
app.get("/do-acme-challenge", challenge);

app.get("/.well-known/acme-challenge/:fileid", async (req, res) => {
  const chal = pathToChallenge(req.headers.host, req.params.fileid);
  console.log("Requesting " + req.params.fileid);
  console.log(
    "Requesting " + pathToChallenge(req.headers.host, req.params.fileid)
  );
  try {
    const results = await readFile(chal);
    res.send(results.toString());
  } catch (e) {
    console.error(e);
    res.send("Error Requesting " + req.params.fileid);
  }
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
