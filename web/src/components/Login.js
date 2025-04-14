// src/components/Login.js
import React, { useState, useEffect } from "react";
import {
  Form,
  Button,
  Container,
  Alert,
  Tabs,
  Tab,
  Row,
  Col,
  Modal,
} from "react-bootstrap";
import AddTaskModal from "./AddTaskModal";

function Login() {
  const [credentials, setCredentials] = useState({ name: "", password: "" });
  const [status, setStatus] = useState("");
  const [userId, setUserId] = useState("");
  const [tasks, setTasks] = useState([]);
  const [users, setUsers] = useState([]);
  const [showAddTaskModal, setShowAddTaskModal] = useState(false);

  const handleChange = (e) => {
    setCredentials({ ...credentials, [e.target.name]: e.target.value });
  };

  const loginUser = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(credentials),
      });

      if (res.status === 200) {
        const data = await res.json();
        setUserId(data.userId);
        setStatus("Login successful!");
        fetchUsers();
        fetchTasks();
      } else {
        const error = await res.text();
        setStatus(`Login failed: ${error}`);
      }
    } catch (e) {
      setStatus(`Error: ${e.message}`);
    }
  };

  const fetchUsers = async () => {
    const res = await fetch("http://localhost:3001/api/users");
    const data = await res.json();
    setUsers(data);
  };

  const fetchTasks = async () => {
    const res = await fetch("http://localhost:3001/api/tasks");
    const data = await res.json();
    setTasks(data);
  };

  const updateTaskState = async (taskId, newState) => {
    await fetch(`http://localhost:3001/api/tasks/${taskId}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ state: newState }),
    });
    fetchTasks();
  };

  const showTaskModal = (task) => {
    const assignedNames = task.assignedTo.map((id) => {
      const user = users.find((u) => u.userId === id);
      return user ? user.name : "Unknown";
    });

    const handleChangeState = async (e) => {
      const newState = e.target.value;
      await updateTaskState(task.taskId, newState);
      document.getElementById("closeModal").click();
    };

    const modalContent = (
      <Modal show={true} onHide={() => setShowAddTaskModal(false)} centered>
        <Modal.Header closeButton>
          <Modal.Title>{task.name}</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <p>{task.description}</p>
          <h6>Assigned To:</h6>
          <ul>
            {assignedNames.map((name, i) => (
              <li key={i}>{name}</li>
            ))}
          </ul>
          <h6>Change State:</h6>
          <Form.Select defaultValue={task.state} onChange={handleChangeState}>
            <option value="todo">TODO</option>
            <option value="in progress">IN PROGRESS</option>
            <option value="done">DONE</option>
          </Form.Select>
        </Modal.Body>
        <Modal.Footer>
          <Button
            id="closeModal"
            variant="secondary"
            onClick={() => setShowAddTaskModal(false)}
          >
            Close
          </Button>
        </Modal.Footer>
      </Modal>
    );

    setShowAddTaskModal(modalContent);
  };

  const renderTasks = (taskList) => {
    return taskList.map((task) => (
      <div
        key={task.taskId}
        className="card task-card p-4 mb-3 fade-in"
        onClick={() => showTaskModal(task)}
      >
        <Row className="align-items-center">
          <Col>
            <h5 className="mb-2">{task.name}</h5>
            <p className="text-muted mb-0">{task.description}</p>
          </Col>
          <Col md="auto" className="text-end">
            <span className={`badge bg-${getStatusColor(task.state)} mb-2`}>
              {task.state.toUpperCase()}
            </span>
            <br />
            <small className="text-muted">
              {task.assignedTo.length} Assigned
            </small>
          </Col>
        </Row>
      </div>
    ));
  };

  const getStatusColor = (state) => {
    switch (state) {
      case "todo":
        return "warning";
      case "in progress":
        return "info";
      case "done":
        return "success";
      default:
        return "primary";
    }
  };

  return (
    <Container className="mt-5 fade-in">
      {!userId ? (
        <Row className="justify-content-center">
          <Col md={6}>
            <div className="card p-4">
              <h3 className="text-center mb-4">Welcome Back</h3>
              <Form>
                <Form.Group className="mb-4">
                  <Form.Label>Username</Form.Label>
                  <Form.Control 
                    type="text" 
                    name="name" 
                    onChange={handleChange}
                    placeholder="Enter your username"
                  />
                </Form.Group>
                <Form.Group className="mb-4">
                  <Form.Label>Password</Form.Label>
                  <Form.Control
                    type="password"
                    name="password"
                    onChange={handleChange}
                    placeholder="Enter your password"
                  />
                </Form.Group>
                <Button variant="primary" className="w-100 py-2" onClick={loginUser}>
                  Sign In
                </Button>
              </Form>
              {status && (
                <Alert
                  variant={status.includes("successful") ? "success" : "danger"}
                  className="mt-3"
                >
                  {status}
                </Alert>
              )}
            </div>
          </Col>
        </Row>
      ) : (
        <>
          <Row className="mb-4 align-items-center">
            <Col>
              <h3 className="mb-0">Task Dashboard</h3>
            </Col>
            <Col md="auto">
              <Button
                variant="success"
                className="px-4"
                onClick={() => setShowAddTaskModal(true)}
              >
                + New Task
              </Button>
            </Col>
          </Row>
          <Tabs defaultActiveKey="my" className="mb-4">
            <Tab eventKey="my" title="My Tasks">
              <div className="mt-3">
                {renderTasks(
                  tasks.filter(
                    (t) => t.assignedTo.includes(userId) && t.state !== "done"
                  )
                )}
              </div>
            </Tab>
            <Tab eventKey="all" title="All Tasks">
              <div className="mt-3">
                {renderTasks(tasks)}
              </div>
            </Tab>
            <Tab eventKey="done" title="Completed">
              <div className="mt-3">
                {renderTasks(tasks.filter((t) => t.state === "done"))}
              </div>
            </Tab>
          </Tabs>
        </>
      )}

      {showAddTaskModal === true && (
        <AddTaskModal
          onClose={() => setShowAddTaskModal(false)}
          onTaskCreated={fetchTasks}
        />
      )}

      {typeof showAddTaskModal !== "boolean" && showAddTaskModal}
    </Container>
  );
}

export default Login;
