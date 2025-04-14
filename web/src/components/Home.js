// src/components/Home.js
import React from "react";
import { Container, Button, Row, Col } from "react-bootstrap";
import { useNavigate } from "react-router-dom";

function Home() {
  const navigate = useNavigate();

  return (
    <Container className="text-center mt-5 fade-in">
      <div className="card p-5 mb-4">
        <h1 className="display-4 mb-4">Welcome to Task Manager</h1>
        <p className="lead mb-5">Organize your tasks efficiently and collaborate with your team seamlessly.</p>
        <Row className="justify-content-center g-4">
          <Col xs={12} sm={6} md={4}>
            <Button 
              variant="primary" 
              size="lg" 
              className="w-100 py-3"
              onClick={() => navigate("/register")}
            >
              Get Started
            </Button>
          </Col>
          <Col xs={12} sm={6} md={4}>
            <Button 
              variant="secondary" 
              size="lg" 
              className="w-100 py-3"
              onClick={() => navigate("/login")}
            >
              Sign In
            </Button>
          </Col>
        </Row>
      </div>
      
      <Row className="g-4 mt-4">
        <Col md={4}>
          <div className="card p-4 h-100">
            <h3 className="h5 mb-3">Task Organization</h3>
            <p className="text-muted">Keep all your tasks organized in one place with our intuitive interface.</p>
          </div>
        </Col>
        <Col md={4}>
          <div className="card p-4 h-100">
            <h3 className="h5 mb-3">Team Collaboration</h3>
            <p className="text-muted">Work together with your team members efficiently and effectively.</p>
          </div>
        </Col>
        <Col md={4}>
          <div className="card p-4 h-100">
            <h3 className="h5 mb-3">Progress Tracking</h3>
            <p className="text-muted">Monitor task progress and stay updated with real-time status changes.</p>
          </div>
        </Col>
      </Row>
    </Container>
  );
}

export default Home;
