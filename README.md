#### TODO:
- ✅ Model test
- ✅ OpenAPI doc (swagger)
- Implement APIs
  - ✅ Movie, Watchlist, Auth
- ✅ Provision infra with Terraform
- Push Docker images to ECR (image registry)
- Use Auto Scaling Group (ASG)


# Rails Movie API

[![CI](https://github.com/bambina/rails-movie-api/actions/workflows/ci.yml/badge.svg)](https://github.com/bambina/rails-movie-api/actions/workflows/ci.yml)
![Ruby](https://img.shields.io/badge/Ruby-3.3.8-red)
![Rails](https://img.shields.io/badge/Rails-8.0.2-crimson)
![Postgres](https://img.shields.io/badge/Postgres-16-blue)
![Docker](https://img.shields.io/badge/Docker-✓-blue)
![Swagger](https://img.shields.io/badge/Swagger-API%20Docs-brightgreen)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-623CE4)

Rails-based RESTful API for managing movies, built with JWT authentication, RSpec testing, and Dockerized for deployment.
Infrastructure is provisioned with Terraform and deployed on AWS.

## 🌐 Demo
The API documentation is available via Swagger UI:
🔗 [rails-movie-api.bambi-dev.net/api-docs](https://rails-movie-api.bambi-dev.net/api-docs/index.html)
(access protected with Basic Auth)

## 🛠 Tech Stack

- Ruby 3.3.8 / Rails 8.0.2
- PostgreSQL 16.9
- Docker 28.3.2 / Docker Compose v2.38.2
- Terraform 1.13.x (IaC for AWS resources)

## 🚀 Setup Instructions

### 🐳 Using Docker

```bash
git clone <repository-url>
cd <repository-name>
docker compose up
```

### 💻 Local Development

```bash
bundle install
bin/rails db:prepare # (db:create + db:migrate + db:seed)
bin/rails server
```

## ✅ Testing

```bash
# Using Docker
docker compose run --rm test

# Local Development
bundle exec rspec
```

## 📘 API Documentation

**Swagger UI**: http://localhost:3000/api-docs/index.html

### Quick Update
1. Edit `spec/requests/api/v1/docs/*_spec.rb`
2. Run `SWAGGER_DRY_RUN=false bin/rails rswag:specs:swaggerize`

### Test Files
- `docs/*_spec.rb` - Swagger generation
- `*_spec.rb` - Detailed API tests

## API Endpoints

### 🎬 Movies

| Method | Endpoint        | Description                        |
|--------|-----------------|------------------------------------|
| GET    | /movies         | Retrieve a list of movies          |
| POST   | /movies         | Create a new movie                 |
| GET    | /movies/{id}    | Retrieve details of a specific movie |
| PUT    | /movies/{id}    | Fully update movie information     |
| PATCH  | /movies/{id}    | Partially update movie information |
| DELETE | /movies/{id}    | Delete a movie                     |


### 📺 Watchlist

| Method | Endpoint                              | Description                              |
|--------|---------------------------------------|------------------------------------------|
| GET    | /users/me/watchlists                  | Retrieve the current user's watchlist    |
| POST   | /users/me/watchlists                  | Add a movie to the watchlist             |
| DELETE | /users/me/watchlists/{movie_id}       | Remove a movie from the watchlist        |


### 🔐 Authentication

| Method | Endpoint         | Description                 |
|--------|------------------|-----------------------------|
| POST   | /auth/login      | Issue JWT upon login        |
| POST   | /auth/refresh    | Refresh access token        |


## Database Schema

### ER Diagram

```mermaid
erDiagram
    User {
        bigint id PK
        string username "NOT NULL, UNIQUE"
        string password_digest "NOT NULL"
    }

    Movie {
        bigint id PK
        string title "NOT NULL"
        text description
        integer release_year
    }

    Watchlist {
        bigint id PK
        bigint user_id FK "NOT NULL"
        bigint movie_id FK "NOT NULL"
    }

    User ||--o{ Watchlist : "has_many"
    Movie ||--o{ Watchlist : "has_many"
    Watchlist }o--|| User : "belongs_to"
    Watchlist }o--|| Movie : "belongs_to"
```

*Note: Standard Rails timestamps (created_at, updated_at) are omitted from the diagram for clarity*

### Constraints
- `(user_id, movie_id)` combination must be unique in Watchlists

## Architecture

```mermaid
flowchart TD
    Internet -->|"HTTPS (ACM)"| ALB[ALB_public]
    ALB -->|HTTP| EC2[EC2_private]
    EC2 -->|HTTP| RDS[(RDS_private)]
```
