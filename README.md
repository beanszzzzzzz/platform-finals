# Final Project Deployment Guide

## Symfony Docker Deployment (Railway & Other Hosting Platforms)

This project demonstrates how to containerize and deploy a Symfony application using Docker and related technologies.

---

## Technologies Used

The application is deployed using:

- Docker
- Nginx
- PHP-FPM
- MySQL
- Docker Compose

---

## Project Objectives

This project is designed to demonstrate understanding of:

- Containerized application deployment
- Symfony production configuration
- Docker networking and orchestration
- Web server configuration using Nginx
- Environment variable management
- Cloud deployment workflows (e.g., Railway)

---

## Project Requirements

Your final project must include:

- A working Symfony application
- Dockerized deployment setup
- Proper Nginx configuration
- Production-ready environment configuration
- Database integration
- Complete deployment documentation
- Successful deployment on a hosting platform (e.g., Railway)

---

## Required Files

Create the following files in your project root directory:

### Dockerfile

Defines the blueprint for building the application’s Docker image.  
Without it, the application cannot be containerized or deployed consistently across environments.

---

### docker-compose.yaml

Defines and manages multiple containers as a single application stack (primarily for local development).  
Ensures all services work together as a complete system and simplifies container orchestration.

---

### entrypoint.sh

Script executed when a container starts.  
Ensures the application initializes in a consistent and production-ready state every time.

---

### nginx.conf

Main configuration file for the Nginx web server.  
Acts as the entry point for all web traffic and forwards requests correctly to the application.

---

### nginx-main.conf

Additional or environment-specific Nginx configuration file.  
Improves maintainability and allows safer updates without modifying the main config.

---

### .dockerignore

Specifies files and folders excluded from the Docker build context.  
Helps keep Docker images clean and builds efficient.

---

### .env

Stores environment variables used by the application.  
Keeps sensitive information out of the codebase and allows flexible configuration across environments.

---

## Deployment Notes

- Ensure all environment variables are properly set before deployment
- Verify database connection settings in `.env`
- Use production mode for Symfony in deployment
- Confirm Nginx is correctly routing requests to PHP-FPM
- Test Docker Compose setup locally before deploying

---

## Deployment Platform

Recommended platform:

- Railway

## Railway Deployment Steps (Using GitHub)

Repository to deploy:

- https://github.com/thv-maker/finalproject.git

1. Push this project code to your GitHub repository.
2. In Railway, click New Project -> Deploy from GitHub repo.
3. Select `thv-maker/finalproject`.
4. Railway will detect `railway.toml` and build with `Dockerfile.railway`.
5. Add a MySQL service in the same Railway project.
6. Open your app service Variables tab and set:
     - `APP_ENV=prod`
     - `APP_DEBUG=0`
     - `APP_SECRET` to a long random string
     - `RUN_MIGRATIONS=1`
     - `MYSQL_DATABASE` (same as MySQL service DB name)
     - `MYSQL_USER` (same as MySQL service user)
     - `MYSQL_PASSWORD` (same as MySQL service password)
     - `DATABASE_URL` in this format:
         - `mysql://<MYSQL_USER>:<MYSQL_PASSWORD>@<MYSQL_HOST>:<MYSQL_PORT>/<MYSQL_DATABASE>?serverVersion=8.0.32&charset=utf8mb4`
7. Redeploy the app service after variables are saved.
8. Open the generated Railway public URL and verify the homepage loads.

### Notes for Railway

- `Dockerfile.railway` runs Nginx and PHP-FPM in one container (required for single-service HTTP deployment).
- Port binding is handled through Railway `PORT` using `nginx-main.railway.conf.template`.
- Keep `docker-compose.yaml` for local development; Railway uses `railway.toml` + `Dockerfile.railway`.

## Notes

This project is intended for educational purposes and demonstrates full-stack containerized deployment practices using Symfony.

## What to submit

- Link of your application
- Recorded video containing (5-10 mins):
    - Explanation of the Dockerfile setup (1–2 mins)
    - Explanation of the Nginx configuration (1–2 mins)
    - Environment variable setup overview (1 min)
    - Deployment process walkthrough (2–3 mins)
    - Final proof that the deployed version is working correctly (1–2 mins)

## Grading Rubric (Total: 100 Points)

| Category                              | Description                                           | Points |
| ------------------------------------- | ----------------------------------------------------- | ------ |
| **Docker Setup**                      | Dockerfile and docker-compose are correct and working | 25     |
| **Nginx Configuration**               | Correct routing to PHP-FPM and proper Symfony setup   | 15     |
| **Symfony Production Setup**          | Production mode, caching, and stable runtime          | 15     |
| **Environment & Security**            | Proper .env usage and secure configuration            | 10     |
| **Database Integration**              | Working database connection and CRUD/migrations       | 10     |
| **Deployment**                        | Successfully deployed and accessible live application | 15     |
| **Understanding (Video Explanation)** | Clear explanation of Docker, Nginx, and deployment    | 7      |
| **Video Presentation Quality**        | Clear, complete, and within 5–10 minutes              | 3      |
