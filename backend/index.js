const express = require("express");
const cors = require("cors");
const fs = require("fs/promises");
const { v4: uuidv4 } = require("uuid");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const USERS_FILE = "./users.json";

// Helper to load users
async function loadUsers() {
  try {
    const data = await fs.readFile(USERS_FILE, "utf8");
    return JSON.parse(data);
  } catch (err) {
    // If file doesn't exist, return empty array
    return [];
  }
}

// Helper to save users
async function saveUsers(users) {
  await fs.writeFile(USERS_FILE, JSON.stringify(users, null, 2));
}

// Register route
app.post("/api/register", async (req, res) => {
  const { name, designation, password } = req.body;
  console.log("Received data:", req.body); // <-- Add this

  if (!name || !designation || !password) {
    return res.status(400).json({ error: "All fields are required" });
  }

  const users = await loadUsers();

  const newUser = {
    userId: uuidv4(),
    name,
    designation,
    password, // ⚠️ Reminder: don't store plain passwords in production
  };

  users.push(newUser);
  await saveUsers(users);

  res.status(201).json({ userId: newUser.userId });
});

// Test route
app.get("/api", (req, res) => {
  res.json({ message: "API is working with file storage" });
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
