const express = require("express");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS for all routes
app.use(cors());

// Middleware to parse JSON
app.use(express.json());

// Basic /api endpoint
app.get("/api", (req, res) => {
  res.json({ message: "Hello from /api with CORS!" });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
