const { Wallet } = require("ethers");

// Sign the message
exports.signMessage = async function signMessage(wallet, message) {
  // Create a wallet instance from the private key
  // const wallet = new ethers.Wallet(privateKey);

  // Sign the message
  const signature = await wallet.signMessage(message);
  console.log('Signature:', signature);

  return signature;
}

// Verify the signature
// Verify the signature
exports.verifyMessage = function verifyMessage(message, signature) {
  return ethers.utils.verifyMessage(message, signature)

}
exports.hashSignedMessage = function hashSignedMessage(message) {
  const signedMessage = signMessage(message)
  // Remove the '0x' prefix from the signed message if present
  const formattedMessage = signedMessage.startsWith('0x') ? signedMessage.slice(2) : signedMessage;

  // Hash the signed message using Keccak256 algorithm
  const hashedMessage = ethers.utils.keccak256(formattedMessage);

  return hashedMessage;
}

exports.dblHashSigndMessage = function  dblHashSigndMessage (msg) {
  const hashed = hashSignedMessage(msg)
  const dblHashed = hashSignedMessage(hashed)

  return [hashed, dblHashed]
}

exports.encryptStream = function encryptStream(password) {
  const iv = crypto.randomBytes(16); // Generate a random IV

  const cipher = crypto.createCipheriv('aes-256-cbc', password, iv);

  // Create a transform stream that handles the encryption process
  const encryptStream = crypto.createTransformStream(cipher);

  // Prepend the IV to the first chunk of data
  const firstChunk = Buffer.concat([iv, encryptStream.read()]);
  encryptStream.unshift(firstChunk);

  return encryptStream;
}

exports.decryptStream = function decryptStream(password) {
  let isFirstChunk = true;
  let iv;

  const decipher = crypto.createDecipheriv('aes-256-cbc', password, iv);

  // Create a transform stream that handles the decryption process
  const decryptStream = crypto.createTransformStream(decipher);

  // Read the IV from the first chunk
  decryptStream.on('pipe', (source) => {
    source.once('data', (chunk) => {
      if (isFirstChunk) {
        isFirstChunk = false;
        iv = chunk.slice(0, 16); // Extract the IV from the first chunk
        decryptStream.push(chunk.slice(16)); // Push the remaining data to the decryption stream
      } else {
        decryptStream.push(chunk);
      }
    });
  });

  return decryptStream;
}
