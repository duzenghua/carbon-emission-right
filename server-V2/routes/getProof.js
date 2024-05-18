const { initialize } = require("zokrates-js");

exports.getProof = async function (amount, quato) {
  return initialize()
    .then((zokratesProvider) => {
      const source =
        "def main(private field a,  private field b) {assert(a <= b);return;}";

      // compilation
      const artifacts = zokratesProvider.compile(source);

      // computation
      const { witness, output } = zokratesProvider.computeWitness(artifacts, [
        amount,
        quato,
      ]);
      // run setup
      const keypair = zokratesProvider.setup(artifacts.program);

      // generate proof
      const proof = zokratesProvider.generateProof(
        artifacts.program,
        witness,
        keypair.pk
      );
      const isVerified = zokratesProvider.verify(keypair.vk, proof);

      return { proof, isVerified };
    })
    .catch((err) => console.log(err));
};
