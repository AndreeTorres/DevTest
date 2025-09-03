# AI + Data Engineer Challenge

This project demonstrates a complete data engineering pipeline built with modern tools and best practices. It showcases how to set up an automated data processing environment using PostgreSQL as a data warehouse and n8n as a workflow orchestration platform, all containerized with Docker.

##  What This Project Does

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
 queries
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

## 🔄 Using the DevTest Workflow

This project includes a pre-configured n8n workflow that automates the entire data ingestion process from CSV to PostgreSQL.

### Workflow Components

The **DevTest** workflow (`n8n/workflow.json`) implements a complete ETL pipeline:

```
Manual Trigger → Read CSV File → Extract Data → Transform Data → Load to PostgreSQL
```

### Step-by-Step Process

1. **Manual Trigger**: Start the workflow manually from n8n interface
2. **File Reading**: Automatically reads `ads_spend.csv` from the `/data` directory
3. **Data Extraction**: Parses CSV with proper headers and delimiter handling
4. **Data Transformation**: 
   - Converts data types (date, numeric, integer)
   - Validates data integrity
   - Adds source file metadata
5. **Database Loading**: Uses UPSERT strategy to handle duplicates

### How to Run the Workflow

1. **Access n8n**: Open http://localhost:5678 and log in
2. **Import Workflow**: The workflow should already be available as "DevTest"
3. **Configure Database Connection**: 
   - Set up PostgreSQL credentials in n8n
   - Host: `postgres-warehouse`
   - Database: `warehouse`
   - Username: `analytics`
   - Password: `analytics`
4. **Execute Workflow**: Click "Execute Workflow" or use the manual trigger
5. **Monitor Progress**: Watch each node execute and verify data loading

### Database Schema Expected

The workflow expects this table structure in PostgreSQL:

```sql
CREATE TABLE raw_ads_spend (
    date DATE,
    platform VARCHAR(50),
    account VARCHAR(100),
    campaign VARCHAR(200),
    country VARCHAR(50),
    device VARCHAR(50),
    spend NUMERIC(10,2),
    clicks INTEGER,
    impressions BIGINT,
    conversions INTEGER,
    source_file VARCHAR(100),
    load_date TIMESTAMP DEFAULT NOW(),
    UNIQUE(date, platform, account, campaign, country, device)
);
```

## 🗄️ Database Initialization & Setup

After running the workflow, you need to ensure the database is properly initialized with the required tables and structure.

### Required Database Setup

The project expects the following database configuration:

1. **Database**: `warehouse`
2. **User**: `analytics` with appropriate permissions
3. **Tables**: Properly structured tables for advertising data

### Database Schema Requirements

The main table structure needed for the analytics is already defined in the workflow section above. Make sure this table exists before running analytics queries.

### Initializing the Database

```bash
# Connect to PostgreSQL container
docker exec -it postgres-warehouse psql -U analytics -d warehouse

# Verify table exists
\dt

# If needed, create the table manually using the schema above
```

## 📊 Data Analytics & KPI Analysis

This project includes advanced SQL analytics for advertising performance measurement and optimization.

### Performance Comparison Analysis

**File: `sql/02_compare_30d.sql`**

This sophisticated analytics query provides period-over-period comparison of advertising performance:

#### Key Features:
- **Time-based Analysis**: Compares last 30 days vs previous 30 days
- **Dynamic Date Calculation**: Automatically determines periods based on latest data
- **Advanced Metrics Calculation**:
  - **CAC (Customer Acquisition Cost)**: `spend ÷ conversions`
  - **ROAS (Return on Ad Spend)**: `revenue ÷ spend` 
  - **Revenue Estimation**: `conversions × $100` (configurable value)
  
#### Technical Implementation:
- **CTEs (Common Table Expressions)**: Modular query structure for maintainability
- **Self-Join Technique**: Compares different time periods in single result set
- **Null Handling**: Uses `NULLIF()` to prevent division by zero errors
- **Percentage Deltas**: Calculates period-over-period change percentages

#### Business Value:
- **Performance Trends**: Identify if campaigns are improving or declining
- **Budget Optimization**: Lower CAC indicates better targeting efficiency  
- **ROI Measurement**: Higher ROAS shows improved campaign profitability
- **Data-Driven Decisions**: Quantitative metrics for strategy adjustments

#### Sample Output:
```sql
-- Expected result structure:
period   | spend   | conversions | cac    | roas  | delta_cac_pct | delta_roas_pct
---------|---------|-------------|--------|-------|---------------|---------------
cur_30d  | 15000.00| 150        | 100.00 | 1.00  | -16.67        | 20.00
prev_30d | 18000.00| 150        | 120.00 | 0.83  | NULL          | NULL
```

### Running Analytics Queries

1. **Access Database**:
   ```bash
   docker exec -it postgres-warehouse psql -U analytics -d warehouse
   ```

2. **Execute Analysis**:
   ```sql
   \i sql/02_compare_30d.sql
   ```

3. **Interpret Results**:
   - Negative delta_cac_pct = Cost efficiency improved
   - Positive delta_roas_pct = Return on investment increased
   - Use metrics to guide campaign optimization strategies

## Parametrizable Date Window Analysis

**#File: `sql/03_metrics_window.sql`**

This flexible analytics script allows custom date range analysis with parametrizable start and end dates:

#### Key Features:
- **Custom Date Ranges**: Accept start and end date parameters for flexible analysis
- **Multi-level Aggregation**: Provides both total metrics and platform-specific breakdowns
- **Same KPIs as Comparison**: Consistent CAC, ROAS, spend, conversions, and revenue calculations
- **Dynamic Filtering**: Uses PostgreSQL parameters (`:start` and `:end`) for date window specification

#### Technical Implementation:
- **Parameter Handling**: Uses `:'start'::date` and `:'end'::date` for runtime date injection
- **Cross Join Technique**: Efficiently applies date filters across the dataset
- **Dual Output Structure**: 
  - `TOTAL` level: Aggregated metrics across all platforms
  - `PLATFORM` level: Individual platform performance breakdown
- **Consistent Precision**: Uses `numeric(18,2)` for financial calculations

#### Business Value:
- **Flexible Reporting**: Analyze any custom date range (weekly, monthly, quarterly, yearly)
- **Campaign-specific Analysis**: Focus on specific time periods like product launches or seasonal campaigns
- **Platform Comparison**: Compare performance across different advertising platforms
- **Historical Analysis**: Examine performance trends over custom historical periods

#### Sample Usage:
```bash
# Analyze march 2025 performance
docker run -it --rm --network host -v "$PWD/sql":/sql postgres:15 \
  psql "postgresql://analytics:analytics@localhost:5432/warehouse" \
  -v start='2025-03-01' -v end='2025-03-31' -f /sql/03_metrics_window.sql


#### Sample Output:
```sql
-- Expected result structure:
  level   |  key   |   spend   | conversions |  revenue  |  cac  | roas 
----------+--------+-----------+-------------+-----------+-------+------
 PLATFORM | Google | 137032.34 |        4633 | 463300.00 | 29.58 | 3.38
 PLATFORM | Meta   | 132754.15 |        4219 | 421900.00 | 31.47 | 3.18
 TOTAL    | ALL    | 269786.49 |        8852 | 885200.00 | 30.48 | 3.28
```



## Running Analytics Queries

1. **Access Database**:
   ```bash
   docker exec -it postgres-warehouse psql -U analytics -d warehouse
   ```

2. **Execute Period Comparison**:
   ```sql
   \i sql/02_compare_30d.sql
   ```

3. **Execute Custom Date Range Analysis**:
   ```bash
   # From terminal (outside PostgreSQL)
   docker run -it --rm --network host -v "$PWD/sql":/sql postgres:15 \
     psql "postgresql://analytics:analytics@localhost:5432/warehouse" \
     -v start='2024-08-01' -v end='2024-08-31' -f /sql/03_metrics_window.sql
   ```

4. **Interpret Results**:
   - **02_compare_30d.sql**: Negative delta_cac_pct = Cost efficiency improved, Positive delta_roas_pct = ROI increased
   - **03_metrics_window.sql**: Compare TOTAL vs PLATFORM metrics to identify top-performing channels
   - Use metrics to guide campaign optimization and budget allocation strategies
## What Each File Does

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
- **Analytics and reporting queries**

#### Available SQL Analytics Files

**`02_compare_30d.sql`** - 30-Day Performance Comparison
- Compares advertising KPIs between current 30 days vs previous 30 days
- Calculates key metrics: CAC (Customer Acquisition Cost), ROAS (Return on Ad Spend)
- Provides percentage deltas to identify performance trends
- Uses advanced SQL techniques: CTEs, window functions, self-joins
- Output includes period-over-period analysis for campaign optimization

### `n8n/` Directory
Stores n8n configuration and workflow data:
- **workflow.json**: Complete ETL workflow for processing ads_spend.csv data
- Node configurations and credentials
- Execution logs and history

#### DevTest Workflow Overview
The `workflow.json` file contains a complete data pipeline with the following nodes:

1. **Manual Trigger**: Initiates the workflow manually for data processing
2. **Read Binary File**: Reads the `/data/ads_spend.csv` file from the container
3. **Extract from File**: Parses CSV data with headers and comma delimiter
4. **Code Node**: Data transformation and validation:
   - Converts data types (strings, numbers, integers)
   - Adds source file tracking
   - Validates data format
5. **Postgres (UPSERT)**: Inserts data into `raw_ads_spend` table with conflict resolution

**Key Features:**
- **UPSERT Logic**: Handles duplicate records by updating existing data
- **Data Type Validation**: Ensures proper casting for database storage
- **Source Tracking**: Adds metadata about data origin
- **Error Handling**: Robust pipeline with proper data validation

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

### Problem: DevTest workflow fails to execute
```bash
# Solution 1: Check PostgreSQL connection
docker-compose logs postgres-warehouse

# Solution 2: Verify CSV file exists
docker exec -it n8n ls -la /data/ads_spend.csv

# Solution 3: Check n8n credentials for PostgreSQL
# In n8n interface: Settings → Credentials → Postgres account
# Ensure: Host=postgres-warehouse, Database=warehouse, User=analytics

# Solution 4: Verify table exists
docker exec -it postgres-warehouse psql -U analytics -d warehouse -c "\dt"
```

### Problem: Workflow executes but no data appears in database
```bash
# Check if table exists and has correct structure
docker exec -it postgres-warehouse psql -U analytics -d warehouse -c "
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'raw_ads_spend';"

# Check if data was actually inserted
docker exec -it postgres-warehouse psql -U analytics -d warehouse -c "
SELECT COUNT(*) FROM raw_ads_spend;"
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
2. Login with your created credentials
3. **DevTest Workflow**: 
   - View the complete ETL pipeline
   - Test individual nodes
   - Monitor execution history
   - Check data transformation logic
4. **Workflow Features**:
   - Manual trigger for on-demand processing
   - CSV parsing with data validation
   - PostgreSQL UPSERT operations
   - Error handling and logging
5. **Testing the Workflow**:
   - Click "Execute Workflow" to run the complete pipeline
   - Monitor each node's output
   - Verify data loaded correctly in PostgreSQL

### 3. Data Analysis & KPI Exploration
- **Review SQL Analytics**: Examine `sql/02_compare_30d.sql` for advanced analysis patterns
- **Run Performance Comparisons**: Execute period-over-period analysis queries  
- **Examine Transformation Logic**: Understand CAC and ROAS calculation methodologies
- **Validate Data Quality**: Check data consistency and transformation accuracy
- **Business Intelligence**: Use metrics for campaign optimization insights

#### Running the 30-Day Comparison Analysis:
```bash
# Connect to database and run analytics
docker exec -it postgres-warehouse psql -U analytics -d warehouse -f sql/02_compare_30d.sql

# Or run interactively
docker exec -it postgres-warehouse psql -U analytics -d warehouse
warehouse=# \i sql/02_compare_30d.sql
```
