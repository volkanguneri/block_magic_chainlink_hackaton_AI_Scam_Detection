const fs = require("fs");

const {
  Location,
  ReturnType,
  CodeLanguage,
} = require("@chainlink/functions-toolkit");

// Check if the source file exists
const sourceFilePath = "./ai-request.js";

if (!fs.existsSync(sourceFilePath)) {
  console.error(`Source file not found: ${sourceFilePath}`);
  throw new Error(`Source file not found: ${sourceFilePath}`);
}

const requestConfig = {
  // Define the location of the source code (inline only)
  codeLocation: Location.Inline,

  // Optional: specify the location of secrets if required (only Remote or DONHosted is supported)
  secretsLocation: Location.DONHosted,

  // Read and convert the source code to string
  source: fs.readFileSync(sourceFilePath).toString(),

  // Optional: define secrets accessed within the source code
  secrets: {
    openAiAPIKey: process.env.OPENAI_API_KEY,
    etherscanAPIKey: process.env.ETHERSCAN_API_KEY,
  },

  // Define arguments accessed in the source code via args[index]
  // uniswap pool address
  args: ["0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"],

  // Specify the code language (JavaScript only)
  codeLanguage: CodeLanguage.JavaScript,

  // Define the expected return type
  expectedReturnType: ReturnType.string,
};

console.log("Request config created successfully.");

module.exports = requestConfig;
