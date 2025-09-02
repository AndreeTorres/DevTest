# AI + Data Engineer Challenge

This project demonstrates a complete data engineering pipeline built with modern tools and best practices. It showcases how to set up an automated data processing environment using PostgreSQL as a data warehouse and n8n as a workflow orchestration platform, all containerized with Docker.

## 📋 What This Project Does

This data engineering challenge implements:

- **Data Warehousing**: PostgreSQL database to store and manage advertising spend data
- **Workflow Automation**: n8n workflows for automated data ingestion and transformation
- **ETL Processes**: Extract data from CSV files, transform it, and load it into the warehouse
- **Analytics Queries**: SQL queries for business intelligence and reporting
- **Containerized Architecture**: Docker-based setup for easy deployment and scalability

The project processes advertising campaign data to provide insights on spend optimization, ROI analysis, and campaign performance metrics.

## 📂 Project Structure

```text
AIchallenge/
├── README.md
├── docker-compose.yml          # Container orchestration configuration
├── data/
│   └── ads_spend.csv          # Sample advertising dataset
├── dbdata/                    # PostgreSQL data persistence directory
├── n8n/                      # n8n workflow data and configurations
└── sql/                      # SQL scripts for database setup and analytics
    ├── 01_init.sql           # Database initialization
    ├── 02_create_tables.sql  # Table schemas
    ├── 03_load_data.sql      # Data loading procedures
    ├── 04_transformations.sql # ETL transformations
    └── 05_analytics.sql      # Business intelligence queries
```

## Technologies Used

- **PostgreSQL 15**: Relational database for data warehousing
- **n8n**: Open-source workflow automation platform
- **Docker & Docker Compose**: Containerization and orchestration
- **SQL**: Data querying and transformation
- **CSV**: Data source format

## Prerequisites to Run This Project

Before you can run this project, make sure you have:

### Required Software
- **Docker Desktop** (latest version)
- **Git** (for cloning the repository)
- **Postgres** (copy the image on docker hub)
- **PGAmdin** (latest version)

### System Requirements
- **Operating System**: macOS, Linux, or Windows with WSL2
- **RAM**: Minimum 4GB available (8GB recommended)
- **Disk Space**: At least 2GB free space
- **Network**: Internet connection for downloading Docker images

### Optional but Recommended
- **SQL Client** (like DBeaver, pgAdmin, or VS Code with PostgreSQL extension)
- **Text Editor** (VS Code recommended for viewing workflows)

## 🚀 How to Copy and Run This Project

### Step 1: Clone the Repository

```bash
# Clone this repository
git clone [https://github.com/AndreeTorres/DevTest.git]
cd AIchallenge

# Or if starting fresh, create the directory structure
mkdir -p AIchallenge/{data,dbdata,n8n,sql}
cd AIchallenge
```

### Step 2: Prepare the Data File

Make sure you have the `ads_spend.csv` file in the `data/` directory. This file contains sample advertising campaign data used by the project.

### Step 3: Start the Environment

```bash
# Start all services (PostgreSQL + n8n)
docker-compose up -d

# Verify services are running
docker-compose ps
```

### Step 4: Access the Applications

**PostgreSQL Database:**
- **Host**: localhost
- **Port**: 5432
- **Database**: warehouse
- **Username**: analytics
- **Password**: analytics

**n8n Workflow Platform:**
- **URL**: http://localhost:5678
- **First time setup**: Create owner account (use any username/password you prefer)
- **After setup**: Use the credentials you created

> **Important**: n8n will ask you to create an owner account on first visit. The admin/admin123 credentials in docker-compose.yml are overridden by n8n's user management system.

### Step 5: Verify Everything Works

```bash
# Test database connection
docker run --rm postgres:15 psql -h localhost -U analytics -d warehouse -c "SELECT 'Database connected successfully';"

# Check n8n is responding (will show Unauthorized - this is expected)
curl http://localhost:5678/rest/login
```

**For n8n setup:**
1. Open http://localhost:5678 in your browser
2. If this is the first time, you'll see "Set up owner account" 
3. Create your owner account with any username and password you prefer
4. Use those credentials to log in

##  What Each File Does

### `docker-compose.yml`
Defines two services:
- **PostgreSQL container**: Provides the data warehouse with persistent storage
- **n8n container**: Runs the workflow automation platform with database connectivity

### `data/ads_spend.csv`
Sample dataset containing:
- Campaign performance metrics
- Advertising spend data across channels
- Time-series data for trend analysis
- Geographic and demographic information

### `sql/` Directory
Contains SQL scripts for:
- Database initialization and user setup
- Table creation for raw and transformed data
- Data loading procedures from CSV
- ETL transformation logic
- Analytics and reporting queries

### `n8n/` Directory
Stores n8n configuration and workflow data:
- Workflow definitions (JSON format)
- Node configurations
- Credentials and connections
- Execution logs and history

## 🔧 Common Issues When Copying This Project

### Problem: "Port already in use"
```bash
# Solution: Stop existing PostgreSQL services
brew services stop postgresql  # macOS
sudo systemctl stop postgresql  # Linux

# Or change ports in docker-compose.yml
```

### Problem: "Permission denied" errors
```bash
# Solution: Fix directory permissions
sudo chown -R $USER:$USER ./n8n ./dbdata
```

### Problem: "Database connection failed"
```bash
# Solution: Restart containers with clean volumes
docker-compose down -v
docker-compose up -d
```

### Problem: n8n not accessible
```bash
# Solution: Check if containers are running
docker-compose ps
docker-compose logs n8n
```

### Problem: n8n login credentials don't work
```bash
# Solution 1: Reset n8n completely (this will delete workflows)
docker-compose down
rm -rf ./n8n/*
docker-compose up -d

# Solution 2: Check if n8n started without authentication
# Go to http://localhost:5678 - if it asks to create account, create one
# Username/password will be what you set, not admin/admin123

# Solution 3: Restart n8n service specifically
docker-compose restart n8n
# Wait 30 seconds, then try again

# Solution 4: Check n8n logs for authentication errors
docker-compose logs -f n8n
```

### Problem: n8n shows "Set up owner account" instead of login
```bash
# This means n8n started fresh - create your account:
# 1. Go to http://localhost:5678
# 2. Create owner account with your preferred credentials
# 3. Use those credentials instead of admin/admin123
```

## How to Explore the Project

### 1. Database Exploration
```bash
# Connect to PostgreSQL
docker exec -it postgres-warehouse psql -U analytics -d warehouse

# Inside PostgreSQL, explore:
\dt          # List tables
\d+ tablename # Describe table structure
SELECT * FROM your_table LIMIT 5;  # View sample data
```

### 2. n8n Workflow Exploration
1. Open http://localhost:5678 in your browser
2. Login with admin/admin123
3. Explore existing workflows
4. Check execution history
5. Monitor data processing

### 3. Data Analysis
- Review SQL files in `sql/` directory
- Run analytics queries to understand the data
- Examine transformation logic
- Check data quality procedures

