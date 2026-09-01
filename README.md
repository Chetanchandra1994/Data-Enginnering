# End-to-End Data Engineering Pipeline

An end-to-end data engineering practice project that demonstrates how to build a production-style data pipeline starting from a SQL Server source database and progressively moving data through cloud storage, orchestration, Snowflake, dbt transformations, and BI reporting.

## Project Objective

The goal of this project is to build and practice a complete modern data engineering pipeline using technologies commonly used in enterprise data platforms.

The pipeline will progressively cover:

* Source database extraction
* Python-based ingestion
* Cloud object storage
* Airflow orchestration
* GCP services
* Snowflake ingestion
* Snowpipe
* dbt transformations
* Terraform infrastructure as code
* CI/CD
* Data quality and validation
* BI/reporting consumption

---

## Architecture

### Target Architecture

```text
                         ┌─────────────────────┐
                         │   SQL Server        │
                         │ AdventureWorksDW2022│
                         └──────────┬──────────┘
                                    │
                                    │ Python Extraction
                                    ▼
                         ┌─────────────────────┐
                         │   Apache Airflow    │
                         │   Orchestration     │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │     GCS Bucket      │
                         │   Raw Data Layer    │
                         └──────────┬──────────┘
                                    │
                          Pub/Sub / Snowpipe
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │      Snowflake      │
                         │                     │
                         │ Landing             │
                         │ Prepare             │
                         │ Normalize           │
                         │ Schematize          │
                         │ Marketplace         │
                         └──────────┬──────────┘
                                    │
                                    │ dbt
                                    ▼
                         ┌─────────────────────┐
                         │     BI Layer        │
                         │ Tableau / Power BI  │
                         └─────────────────────┘
```

---

## Technologies

| Area                   | Technology             |
| ---------------------- | ---------------------- |
| Source Database        | SQL Server             |
| Sample Dataset         | AdventureWorksDW2022   |
| Programming            | Python                 |
| Orchestration          | Apache Airflow         |
| Cloud Platform         | Google Cloud Platform  |
| Object Storage         | Google Cloud Storage   |
| Messaging              | Google Pub/Sub         |
| Data Warehouse         | Snowflake              |
| Continuous Ingestion   | Snowpipe               |
| Transformation         | dbt                    |
| Infrastructure as Code | Terraform              |
| CI/CD                  | Azure DevOps Pipelines |
| BI                     | Tableau / Power BI     |
| Version Control        | Git / GitHub           |
| Development            | VS Code                |

---

# Project Structure

```text
Data-pipeline-end-to-end/
│
├── data/
│
├── python-ingestion/
│   ├── 00_json_test.py
│   ├── 00_read_customer.py
│   ├── Stage_1_extract_customer.py
│   ├── Stage_1_extract_customer_v1.py
│   ├── Stage_1_extract_customer_v2.py
│   ├── Stage_2_extract_customer.py
│   ├── config.py
│   ├── test_connection.py
│   │
│   └── storage/
│       └── local_storage.py
│
├── source-db/
│
├── Syllabus_and_Steps_StageWise/
│
├── .gitignore
├── README.md
└── Data-pipeline-end-to-end.code-workspace
```

---

# Implementation Progress

## Stage 1 — SQL Server Connectivity and Customer Extraction

**Status: Completed**

Implemented:

* SQL Server connectivity using Python
* Connection to `AdventureWorksDW2022`
* Reading data from `dbo.DimCustomer`
* Python database extraction
* Basic validation of extracted records
* JSON generation
* Initial ingestion scripts

### Configuration

Current source configuration:

```text
Server: CHETAN\SQLSERVER2022
Database: AdventureWorksDW2022
Table: dbo.DimCustomer
Batch Size: 5000
```

---

## Stage 2 — Local File-Based Ingestion

**Status: Completed**

Implemented:

* Batch-based extraction
* Local output generation
* Local storage abstraction
* Storage bucket simulation
* JSON/JSONL-based ingestion
* Separation between extraction and storage logic
* Local validation of generated data

Generated/local files are excluded from Git using `.gitignore`.

---

## Stage 3 — Cloud Storage Ingestion

**Status: Planned**

Planned implementation:

```text
SQL Server
    ↓
Python / Airflow
    ↓
Google Cloud Storage
    ↓
Raw Layer
```

Activities:

* Create GCP project
* Create environment-specific GCS buckets
* Configure authentication
* Upload extracted files to GCS
* Implement raw-zone folder structure
* Validate uploaded objects
* Implement error handling
* Add ingestion metadata

---

## Stage 4 — Airflow Orchestration

**Status: Planned**

Implement Apache Airflow DAGs to orchestrate:

```text
Extract
   ↓
Validate
   ↓
Transform to ingestion format
   ↓
Upload to GCS
   ↓
Validate GCS object
```

Topics covered:

* DAGs
* Tasks
* Operators
* Scheduling
* Dependencies
* Retries
* Failure handling
* XCom
* Connections
* Variables
* Logging

---

## Stage 5 — Snowflake Ingestion

**Status: Planned**

Implement:

```text
GCS
 ↓
Snowflake External Stage
 ↓
Landing
```

Topics:

* Snowflake database
* Schemas
* Warehouses
* Roles
* External stages
* File formats
* COPY INTO
* Load validation

---

## Stage 6 — Snowpipe and Event-Driven Ingestion

**Status: Planned**

Implement event-driven ingestion:

```text
GCS
 ↓
Pub/Sub
 ↓
Snowpipe
 ↓
Snowflake Landing
```

The objective is to understand automated and near-real-time ingestion rather than relying only on scheduled batch loads.

---

## Stage 7 — Data Transformation with dbt

**Status: Planned**

Implement the transformation layers:

```text
Landing
   ↓
Prepare
   ↓
Normalize
   ↓
Schematize
   ↓
Marketplace
```

dbt implementation will cover:

* Sources
* Models
* Staging
* Incremental models
* Tests
* Documentation
* Macros
* Seeds
* Snapshots
* Model dependencies
* Lineage

---

## Stage 8 — Terraform Infrastructure

**Status: Planned**

Infrastructure will be managed using Terraform.

Expected infrastructure:

```text
GCP
├── Project configuration
├── GCS
├── Pub/Sub
├── IAM
└── Airflow/GKE infrastructure

Snowflake
├── Databases
├── Schemas
├── Warehouses
├── Roles
├── Stages
├── File formats
└── Snowpipes
```

Environment strategy:

```text
DEV
TEST
PROD
```

---

## Stage 9 — CI/CD

**Status: Planned**

Azure DevOps Pipelines will be used to automate:

```text
Git Push
   ↓
Azure Pipeline
   ↓
Validation
   ↓
Terraform Plan
   ↓
Terraform Apply
   ↓
Deployment
```

Planned checks include:

* Python validation
* dbt validation
* Terraform formatting
* Terraform validation
* Infrastructure plan
* Deployment

---

## Stage 10 — Data Quality and Monitoring

**Status: Planned**

Implement data quality checks for:

* Record counts
* Null values
* Duplicate records
* Primary keys
* Schema changes
* File availability
* Pipeline failures
* Load completeness

---

# Environment Strategy

The project will use separate environments:

```text
DEV
TEST
PROD
```

Example:

```text
GCS
├── advworks-dev
├── advworks-test
└── advworks-prod
```

```text
Snowflake
├── ADVWORKS_DEV
├── ADVWORKS_TEST
└── ADVWORKS_PROD
```

```text
Warehouses
├── ETL_WH_DEV
├── ETL_WH_TEST
└── ETL_WH_PROD
```

---

# Data Flow

The final pipeline will follow this general flow:

```text
AdventureWorksDW2022
        │
        ▼
     SQL Server
        │
        ▼
 Python Extraction
        │
        ▼
 Apache Airflow
        │
        ▼
 Google Cloud Storage
        │
        ▼
      Pub/Sub
        │
        ▼
     Snowpipe
        │
        ▼
 Snowflake Landing
        │
        ▼
      dbt
        │
        ▼
 Prepare
        │
        ▼
 Normalize
        │
        ▼
 Schematize
        │
        ▼
 Marketplace
        │
        ▼
 Tableau / Power BI
```

---

# Git Workflow

The project uses Git for version control and GitHub as the remote repository.

Typical workflow:

```bash
git status

git add .

git commit -m "Description of change"

git push
```

Main branch:

```text
main
```

GitHub repository:

`Chetanchandra1994/Data-pipeline-end-to-end`

---

# Learning Objectives

This project is designed to provide hands-on experience with:

1. Python data ingestion
2. SQL Server
3. Apache Airflow
4. Google Cloud Platform
5. Google Cloud Storage
6. Pub/Sub
7. Snowflake
8. Snowpipe
9. dbt
10. Terraform
11. Azure DevOps
12. CI/CD
13. Data quality
14. Data modeling
15. Production-style pipeline architecture

---

# Project Status

| Stage | Component                      | Status      |
| ----- | ------------------------------ | ----------- |
| 1     | SQL Server + Python extraction | ✅ Completed |
| 2     | Local ingestion/storage        | ✅ Completed |
| 3     | GCS ingestion                  | 🔲 Planned  |
| 4     | Airflow orchestration          | 🔲 Planned  |
| 5     | Snowflake ingestion            | 🔲 Planned  |
| 6     | Pub/Sub + Snowpipe             | 🔲 Planned  |
| 7     | dbt transformations            | 🔲 Planned  |
| 8     | Terraform                      | 🔲 Planned  |
| 9     | CI/CD                          | 🔲 Planned  |
| 10    | Data quality & monitoring      | 🔲 Planned  |
| 11    | BI consumption                 | 🔲 Planned  |

---

# Disclaimer

This is a personal learning and practice project built using the AdventureWorks sample dataset. The architecture and implementation are designed to simulate an enterprise-grade data engineering platform for educational purposes.
