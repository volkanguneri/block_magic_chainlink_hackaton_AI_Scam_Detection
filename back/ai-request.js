// [1] ARGUMENT DECLARATION //
const CONTRACT_ADDRESS = args[0]; // --------------> |   msg senders contract to be analysed before any interaction with

// [2] REQUEST PRICES //
let contractSourceCodeRequest;
try {
  // constructs: an HTTP request for prices using Functions.
  contractSourceCodeRequest = await Functions.makeHttpRequest({
    url: `https://api-sepolia.etherscan.io/api?module=contract&action=getsourcecode&address=${CONTRACT_ADDRESS}&apikey=${secrets.etherscanAPIKey}`,
  });
} catch (error) {
  console.error("Error making HTTP request for prices:", error);
  return Functions.encodeString("Failed to fetch contract source code");
}

if (
  !contractSourceCodeRequest ||
  !contractSourceCodeRequest.data ||
  !contractSourceCodeRequest.data.data
) {
  console.error(
    "Invalid contract source code request response:",
    contractSourceCodeRequest
  );
  return Functions.encodeString(
    "Invalid contract source code request response"
  );
}

// [3] RESPONSE HANDLING //

// executes: request then waits for the response.
const contractSourceCode = contractSourceCodeRequest.data.data;

// [4] PROMPT ENGINEERING //
const prompt = `Analyse ${contractSourceCode} and report if there a security issue in it.`;

// [5] AI DATA REQUEST //
let openAIRequest;
try {
  // requests: OpenAI API using Functions
  openAIRequest = await Functions.makeHttpRequest({
    url: `https://api.openai.com/v1/chat/completions`,
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${secrets.openAiAPIKey}`,
    },
    data: {
      model: "gpt-3.5-turbo",
      messages: [
        {
          role: "system",
          content: "You are analysing security issues in a smart contract",
        },
        {
          role: "user",
          content: prompt,
        },
      ],
    },
    timeout: 10000,
    responseType: "json",
  });
} catch (error) {
  console.error("Error making HTTP request to OpenAI:", error);
  return Functions.encodeString("Failed to fetch openAi request response");
}

if (
  !openAIRequest ||
  !openAIRequest.data ||
  !openAIRequest.data.choices ||
  !openAIRequest.data.choices[0].message
) {
  console.error("Invalid OpenAI request response:", openAIRequest);
  return Functions.encodeString("Invalid openAI request response");
}

const stringResult = openAIRequest.data.choices[0].message.content.trim();

// // note: if your result is a really small price, then update to your desired precision.
// const result = Number(stringResult).toFixed(PRECISION).toString();

console.log(
  `OpenAI security analyse of the contract address ${CONTRACT_ADDRESS} is: ${stringResult}`
);

// return Functions.encodeString(result || "Failed");
