// index.js
const express = require("express");
const cors = require("cors");
const fs = require("fs/promises");
const { v4: uuidv4 } = require("uuid");

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

const USERS_FILE = "./users.json";

async function loadUsers() {
  try {
    const data = await fs.readFile(USERS_FILE, "utf8");
    return JSON.parse(data);
  } catch (err) {
    return [];
  }
}

async function saveUsers(users) {
  await fs.writeFile(USERS_FILE, JSON.stringify(users, null, 2));
}

// Register route
app.post("/api/register", async (req, res) => {
  console.log("Received data:", req.body);

  const { name, designation, password } = req.body;

  if (!name || !designation || !password) {
    return res.status(400).json({ error: "All fields are required" });
  }

  const users = await loadUsers();

  const newUser = {
    userId: uuidv4(),
    name,
    designation,
    password,
  };

  users.push(newUser);
  await saveUsers(users);

  res.status(201).json({ userId: newUser.userId });
});

// Login route
app.post("/api/login", async (req, res) => {
  const { name, password } = req.body;

  if (!name || !password) {
    return res.status(400).json({ error: "Name and password are required" });
  }

  const users = await loadUsers();

  const foundUser = users.find(
    (user) => user.name === name && user.password === password
  );

  if (!foundUser) {
    return res.status(401).json({ error: "Invalid credentials" });
  }

  res.status(200).json({ userId: foundUser.userId });
});

const TASKS_FILE = "./tasks.json";

// Load tasks
async function loadTasks() {
  try {
    const data = await fs.readFile(TASKS_FILE, "utf8");
    return JSON.parse(data);
  } catch (err) {
    return [];
  }
}

// Save tasks
async function saveTasks(tasks) {
  await fs.writeFile(TASKS_FILE, JSON.stringify(tasks, null, 2));
}

// Create Task
app.post("/api/tasks", async (req, res) => {
  const { name, description, assignedTo } = req.body;

  if (!name || !description || !Array.isArray(assignedTo)) {
    return res.status(400).json({ error: "Invalid task data" });
  }

  const tasks = await loadTasks();

  const newTask = {
    taskId: uuidv4(),
    name,
    description,
    assignedTo,
  };

  tasks.push(newTask);
  await saveTasks(tasks);

  res.status(201).json({ message: "Task created", taskId: newTask.taskId });
});

// Get all tasks
app.get("/api/tasks", async (req, res) => {
  const tasks = await loadTasks();
  res.json(tasks);
});

// Get all users (for assignment list)
app.get("/api/users", async (req, res) => {
  const users = await loadUsers();
  res.json(users);
});


app.listen(PORT, () => {
  console.log(`🚀 Server is running at http://localhost:${PORT}`);
});
