// src/components/Register.js
import React, { useState } from "react";
import { Form, Button, Container, Alert, Row, Col } from "react-bootstrap";

function Register() {
  const [formData, setFormData] = useState({
    name: "",
    designation: "",
    password: "",
  });
  const [status, setStatus] = useState("");
  const [userId, setUserId] = useState("");

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const registerUser = async () => {
    try {
      const response = await fetch("http://localhost:3001/api/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      if (response.status === 201) {
        const data = await response.json();
        setUserId(data.userId);
        setStatus("Registration successful!");
      } else {
        const errorText = await response.text();
        setStatus(`Registration failed: ${errorText}`);
      }
    } catch (error) {
      setStatus(`Error: ${error.message}`);
    }
  };

  return (
    <Container className="mt-5 fade-in">
      <Row className="justify-content-center">
        <Col md={6}>
          <div className="card p-4">
            <h3 className="text-center mb-4">Create Account</h3>
            <Form>
              <Form.Group className="mb-4">
                <Form.Label>Full Name</Form.Label>
                <Form.Control 
                  type="text" 
                  name="name" 
                  onChange={handleChange}
                  placeholder="Enter your full name"
                />
              </Form.Group>
              <Form.Group className="mb-4">
                <Form.Label>Designation</Form.Label>
                <Form.Control
                  type="text"
                  name="designation"
                  onChange={handleChange}
                  placeholder="Enter your designation"
                />
              </Form.Group>
              <Form.Group className="mb-4">
                <Form.Label>Password</Form.Label>
                <Form.Control
                  type="password"
                  name="password"
                  onChange={handleChange}
                  placeholder="Create a password"
                />
              </Form.Group>
              <Button variant="primary" className="w-100 py-2" onClick={registerUser}>
                Create Account
              </Button>
            </Form>
            {status && (
              <Alert
                variant={status.includes("successful") ? "success" : "danger"}
                className="mt-3"
              >
                {status}
                {userId && (
                  <div className="mt-2">
                    <strong>Your user ID: </strong>
                    <span className="text-primary">{userId}</span>
                  </div>
                )}
              </Alert>
            )}
          </div>
        </Col>
      </Row>
    </Container>
  );
}

export default Register;
