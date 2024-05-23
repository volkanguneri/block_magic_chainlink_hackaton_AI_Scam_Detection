const dotenv = require("dotenv");
const dotenvenc = require("dotenvenc");

// Define the decryption key
const decryptionKey = process.env.DOTENVENC_KEY;

// Decrypt the.env.enc file
dotenvenc
  .decrypt("./.env.enc", decryptionKey)
  .then(() => {
    // Load the decrypted.env file
    dotenv.config();

    // Now you can access your environment variables
    console.log(process.env.YOUR_VARIABLE_NAME);

    // Remember to handle errors appropriately
  })
  .catch((error) => {
    console.error("Error decrypting.env.enc:", error);
  });
