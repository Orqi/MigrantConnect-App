const express = require("express");
const cors = require("cors");
const multer = require("multer");
const fs = require("fs"); // Core Node.js file system module
const path = require("path"); // Core Node.js path module
const axios = require("axios");
const FormData = require("form-data");
require("dotenv").config(); // Loads environment variables from .env file

const app = express();
const port = 5001;

// Middleware
app.use(cors()); // Enable CORS for all origins - IMPORTANT FOR REACT/FLUTTER
app.use(express.json()); // To parse JSON request bodies

// Multer setup for temporary file storage
// Ensure 'uploads/' directory exists or can be created by the process
const uploadDir = path.join(__dirname, "uploads");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true }); // Create directory if it doesn't exist
  console.log(`[INIT] Created 'uploads' directory at: ${uploadDir}`);
}
const upload = multer({ dest: uploadDir }); // Files will be temporarily stored here

// --- Persistent Data Storage Setup ---
const usersFilePath = path.join(__dirname, "users.json"); // Absolute path to users.json
let userRegistrations = {}; // In-memory cache for user data

// Function to load user data from file
const loadUsers = () => {
  console.log(`[INIT] --- Loading Users ---`);
  console.log(`[INIT] Target users.json path: ${usersFilePath}`);
  try {
    if (fs.existsSync(usersFilePath)) {
      console.log(`[INIT] Found users.json at: ${usersFilePath}`);
      const data = fs.readFileSync(usersFilePath, "utf8");
      if (data.trim().length > 0) { // Check if file is not empty or just whitespace
        userRegistrations = JSON.parse(data);
        console.log(`[INIT] ✅ Loaded ${Object.keys(userRegistrations).length} users from users.json.`);
        console.log(`[INIT] In-memory userRegistrations after load: ${JSON.stringify(userRegistrations, null, 2)}`); // Log actual contents for debug
      } else {
        console.log("[INIT] ℹ️ users.json exists but is empty. Starting with empty registrations.");
        userRegistrations = {}; // Ensure it's an empty object if file is empty
      }
    } else {
      console.log("[INIT] ℹ️ users.json not found. Attempting to create an empty file.");
      // Create an empty file if it doesn't exist
      fs.writeFileSync(usersFilePath, JSON.stringify({}), "utf8");
      userRegistrations = {}; // Initialize as empty object
      console.log(`[INIT] ✅ Successfully created empty users.json at: ${usersFilePath}`);
    }
  } catch (err) {
    console.error(`[INIT] ❌ FATAL ERROR during loadUsers: ${err.message}`);
    console.error(`[INIT] Error code: ${err.code}`); // Look for EACCES here!
    console.error(`[INIT] Error stack: ${err.stack}`);
    console.error("[INIT] Server will start with empty user data. Persistence is compromised.");
    userRegistrations = {}; // Fallback to empty if there's a parsing error or other issue
  }
  console.log(`[INIT] --- End Loading Users ---`);
};

// Function to save user data to file
const saveUsers = () => {
  console.log(`[PERSIST] --- Saving Users ---`);
  console.log(`[PERSIST] Attempting to write to: ${usersFilePath}`);
  try {
    const dataToWrite = JSON.stringify(userRegistrations, null, 2);
    fs.writeFileSync(usersFilePath, dataToWrite, "utf8");
    console.log(`[PERSIST] ✅ Successfully saved ${Object.keys(userRegistrations).length} users to users.json.`);
    console.log(`[PERSIST] Data written: ${dataToWrite}`); // Show what was written
    console.log(`[PERSIST] Verify file existence: ${fs.existsSync(usersFilePath)}`);
    console.log(`[PERSIST] Verify file size (bytes): ${fs.statSync(usersFilePath).size}`);
  } catch (err) {
    console.error(`[PERSIST] ❌ FATAL ERROR during saveUsers: ${err.message}`);
    console.error(`[PERSIST] Error code: ${err.code}`); // THIS IS THE KEY! Likely EACCES.
    console.error(`[PERSIST] Error stack: ${err.stack}`);
    console.error("[PERSIST] User data WILL NOT be persisted. Check file permissions!");
  }
  console.log(`[PERSIST] --- End Saving Users ---`);
};

// Load users when the server starts
loadUsers();
// --- End Persistent Data Storage Setup ---


// --- API Endpoints ---

// Handle file upload to Pinata
app.post("/upload", upload.single("file"), async (req, res) => {
  try {
    console.log("------------------------------------------");
    console.log("📥 [UPLOAD] Request received.");

    if (!req.file) {
      console.error("[UPLOAD] ❌ No file received in the request.");
      return res.status(400).json({ error: "No file uploaded" });
    }

    console.log(`[UPLOAD] 📄 Received file: ${req.file.originalname} (${req.file.size} bytes), Temp Path: ${req.file.path}`);

    const fileStream = fs.createReadStream(req.file.path);
    const data = new FormData();
    data.append("file", fileStream, req.file.originalname); // Use original filename for Pinata

    console.log("[UPLOAD] 🔁 Sending file to Pinata...");

    const result = await axios.post(
      "https://api.pinata.cloud/pinning/pinFileToIPFS",
      data,
      {
        maxBodyLength: Infinity, // Allows large file uploads
        headers: {
          ...data.getHeaders(), // Important for FormData to include boundary
          pinata_api_key: process.env.PINATA_API_KEY,
          pinata_secret_api_key: process.env.PINATA_SECRET_API_KEY,
        },
      }
    );

    console.log("[UPLOAD] ✅ Pinata response received. IPFS Hash:", result.data.IpfsHash);

    // Clean up the uploaded file from the server's 'uploads' directory
    fs.unlink(req.file.path, (err) => {
      if (err) {
        console.error(`[UPLOAD] 🗑️ ERROR deleting temporary file ${req.file.path}: ${err.message}`);
      } else {
        console.log(`[UPLOAD] 🗑️ Deleted temporary file: ${req.file.path}`);
      }
    });

    res.json({ ipfsHash: result.data.IpfsHash });
    console.log("------------------------------------------");

  } catch (error) {
    console.error("------------------------------------------");
    console.error("[UPLOAD] ❌ Error during /upload:");
    if (error.response) {
      // Pinata API error
      console.error("[UPLOAD] 📄 Pinata Response data:", error.response.data);
      console.error("[UPLOAD] 📄 Pinata Status code:", error.response.status);
      console.error("[UPLOAD] 📄 Pinata Headers:", error.response.headers);
      res.status(error.response.status).json({
        error: error.response.data.error || "Failed to upload to Pinata (API error)",
        details: error.response.data,
      });
    } else if (error.request) {
      // The request was made but no response was received (e.g., network error)
      console.error("[UPLOAD] 📄 No response received from Pinata:", error.request);
      res.status(500).json({ error: "No response from Pinata API. Check network or Pinata status." });
    } else if (error.code === 'ENOENT' && req.file) {
      console.error(`[UPLOAD] ❌ File not found error: The temporary file ${req.file.path} may have been moved or deleted prematurely.`);
      res.status(500).json({ error: "Temporary file issue during upload." });
    } else {
      // Other errors (e.g., during file stream, Multer issues)
      console.error("[UPLOAD] 📄 General Error message:", error.message);
      res.status(500).json({ error: "Failed to upload to Pinata (Server error)" });
    }
    console.error("[UPLOAD] Stack:", error.stack);
    console.log("------------------------------------------");
  }
});

// Handle /register POST requests
app.post("/register", (req, res) => {
  console.log("------------------------------------------");
  console.log("📨 [REGISTER] Request received:", req.body);
  const { email, name, ipfsHash } = req.body;

  if (!email || !name || !ipfsHash) {
    console.error("[REGISTER] ❌ Missing required fields for registration. Received:", { email, name, ipfsHash });
    return res.status(400).json({ success: false, error: "Missing required fields: email, name, or ipfsHash" });
  }

  // Ensure consistent casing for email keys (e.g., all lowercase)
  const normalizedEmail = email.toLowerCase().trim();

  userRegistrations[normalizedEmail] = {
    name: name,
    imageUrl: `https://gateway.pinata.cloud/ipfs/${ipfsHash}`, // Assuming ipfsHash is just the hash now
  };

  // Save the updated data to the file
  saveUsers(); // <-- This is where the persistence happens

  console.log(`[REGISTER] ✨ Registered/Updated user: ${normalizedEmail}. Data:`, userRegistrations[normalizedEmail]);
  res.json({ success: true, message: "Identity registered successfully!" });
  console.log("------------------------------------------");
});

// Handle /user-profile GET requests to retrieve user data
app.get("/user-profile", (req, res) => {
  console.log("------------------------------------------");
  console.log("🔍 [PROFILE] Request received:", req.query);
  const email = req.query.email;

  if (!email) {
    console.error("[PROFILE] ❌ Email query parameter is required for user profile lookup.");
    return res.status(400).json({ error: "Email query parameter is required." });
  }

  // Ensure consistent casing for lookup
  const normalizedEmail = email.toLowerCase().trim();

  console.log(`[PROFILE] Looking up profile for normalized email: "${normalizedEmail}"`);
  console.log(`[PROFILE] Current in-memory userRegistration keys: [${Object.keys(userRegistrations).map(key => `"${key}"`).join(', ')}]`);


  const userData = userRegistrations[normalizedEmail];

  if (userData) {
    console.log(`[PROFILE] ✅ Found profile for "${normalizedEmail}":`, userData);
    res.json(userData); // Return name and imageUrl
  } else {
    console.log(`[PROFILE] 👻 No profile found for "${normalizedEmail}" in current registrations.`);
    res.status(404).json({ error: "User profile not found." });
  }
  console.log("------------------------------------------");
});

// Start the server
app.listen(port, () => {
  console.log(`\n🚀 Backend listening on port ${port}`);
  console.log("--- Server Initialized ---");
});