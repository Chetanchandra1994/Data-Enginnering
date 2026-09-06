# End-to-End Data Engineering Pipeline

An end-to-end Data Engineering practice project designed to demonstrate how to build a production-style data platform starting from a SQL Server source system and progressively moving data through Python ingestion, Google Cloud Storage, Airflow orchestration, Pub/Sub, Snowpipe, Snowflake, dbt transformations, Terraform infrastructure, CI/CD, data quality, monitoring, and BI consumption.

The project uses the **AdventureWorksDW2022** sample data warehouse as the source and is implemented as a hands-on enterprise-style Data Engineering platform.

---

# Project Objective

The primary objective is to build, understand, and implement a complete modern Data Engineering pipeline covering:

* Source database connectivity
* Python-based data extraction
* Batch-based ingestion
* Cloud object storage
* Apache Airflow orchestration
* Google Cloud Platform
* Google Cloud Storage
* Google Pub/Sub
* Snowflake ingestion
* Snowpipe
* dbt transformations
* Dimensional data modeling
* Terraform Infrastructure as Code
* Remote Terraform state
* Environment management
* Azure DevOps CI/CD
* Workload Identity Federation
* Data quality
* Error handling and retries
* Incremental and CDC pipelines
* Monitoring and alerting
* Security and IAM
* Performance and cost optimization
* BI/reporting consumption
* Production architecture
* Data Engineering interview scenarios

The project follows the principle:

```text
Learn → Implement → Validate → Understand → Interview Scenario → Move On
```

---

# Architecture

## Target Architecture

```text
                         ┌─────────────────────────┐
                         │       SQL Server        │
                         │   AdventureWorksDW2022  │
                         └────────────┬────────────┘
                                      │
                                      │ Python
                                      │ Extraction
                                      ▼
                         ┌─────────────────────────┐
                         │      Apache Airflow     │
                         │       Orchestration     │
                         └────────────┬────────────┘
                                      │
                                      │ Upload
                                      ▼
                         ┌─────────────────────────┐
                         │   Google Cloud Storage  │
                         │        Raw Layer        │
                         └────────────┬────────────┘
                                      │
                                      │ Object Created
                                      ▼
                         ┌─────────────────────────┐
                         │      Google Pub/Sub     │
                         │      Event Notification │
                         └────────────┬────────────┘
                                      │
                                      │ Notification
                                      ▼
                         ┌─────────────────────────┐
                         │        Snowpipe         │
                         │    Automated Ingestion  │
                         └────────────┬────────────┘
                                      │
                                      ▼
                ┌──────────────────────────────────────────┐
                │                 Snowflake                 │
                │                                          │
                │  ┌──────────────┐                        │
                │  │   LANDING    │  Raw ingestion         │
                │  └──────┬───────┘                        │
                │         ▼                                │
                │  ┌──────────────┐                        │
                │  │   PREPARE    │  Type/structure        │
                │  └──────┬───────┘                        │
                │         ▼                                │
                │  ┌──────────────┐                        │
                │  │   NORMALIZE  │  Cleansing             │
                │  └──────┬───────┘                        │
                │         ▼                                │
                │  ┌──────────────┐                        │
                │  │  SCHEMATIZE  │  Dimensional model     │
                │  └──────┬───────┘                        │
                │         ▼                                │
                │  ┌──────────────┐                        │
                │  │ MARKETPLACE  │  Business consumption   │
                │  └──────────────┘                        │
                └──────────────────────┬───────────────────┘
                                       │
                                       │ dbt
                                       ▼
                         ┌─────────────────────────┐
                         │     BI / Analytics      │
                         │  Tableau / Power BI     │
                         └─────────────────────────┘


              Supporting Platform Components
              ────────────────────────────────

       Terraform ───────► Infrastructure as Code
       Azure DevOps ────► CI/CD
       GitHub ──────────► Source Control
       GCP IAM ─────────► Identity & Access
       Monitoring ──────► Logging / Alerting
```

---

# Technologies

| Area                        | Technology                   |
| --------------------------- | ---------------------------- |
| Source Database             | Microsoft SQL Server         |
| Sample Dataset              | AdventureWorksDW2022         |
| Programming                 | Python                       |
| Database Connectivity       | pyodbc / ODBC Driver 17      |
| Orchestration               | Apache Airflow               |
| Cloud Platform              | Google Cloud Platform        |
| Object Storage              | Google Cloud Storage         |
| Messaging                   | Google Pub/Sub               |
| Data Warehouse              | Snowflake                    |
| Continuous Ingestion        | Snowpipe                     |
| Transformation              | dbt                          |
| Infrastructure as Code      | Terraform                    |
| CI/CD                       | Azure DevOps Pipelines       |
| Identity Federation         | Workload Identity Federation |
| Version Control             | Git / GitHub                 |
| BI                          | Tableau / Power BI           |
| Development                 | VS Code                      |
| Containerization / Platform | Docker / GKE                 |
| Metadata / Orchestration DB | PostgreSQL                   |
| Message Broker              | RabbitMQ / CloudAMQP         |

---

# Project Structure

```text
Data-pipeline-end-to-end/
│
├── .venv/
│
├── CI_CD_Pipeline/
│
├── data/
│
├── DBT/
│   ├── advworks_dbt/
│   │   ├── analyses/
│   │   ├── logs/
│   │   ├── macros/
│   │   ├── models/
│   │   ├── seeds/
│   │   ├── snapshots/
│   │   ├── target/
│   │   ├── tests/
│   │   ├── .gitignore
│   │   ├── dbt_project.yml
│   │   └── README.md
│   │
│   └── logs/
│
├── Interview_related/
│
├── logs/
│
├── python-ingestion/
│   ├── output/
│   ├── storage/
│   ├── storage_bucket/
│   │
│   ├── 00_json_test.py
│   ├── 00_read_customer.py
│   ├── config.py
│   ├── Stage_1_extract_customer.py
│   ├── Stage_1_extract_customer_v1.py
│   ├── Stage_1_extract_customer_v2.py
│   ├── Stage_2_extract_customer.py
│   ├── Stage_3_extract_customer.py
│   ├── Stage_4_extract.py
│   ├── Stage_4_validate_extraction.py
│   ├── Stage_5_test_snowflake_mfa.py
│   ├── Stage_6_extract_fact_internet_sales.py
│   └── test_connection.py
│
├── source-db/
│
├── Snowflake/
│
├── Syllabus_and_Steps_StageWise/
│
├── terraform/
│   ├── environments/
│   │   ├── dev.tfvars
│   │   ├── test.tfvars
│   │   ├── preprod.tfvars
│   │   └── prod.tfvars
│   │
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── .terraform.lock.hcl
│
├── templates/
│   ├── terraform-plan.yml
│   └── terraform-apply.yml
│
├── azure-pipelines.yml
├── azure-pipelines-debug-wif.yml
├── .gitignore
├── README.md
└── Data-pipeline-end-to-end.code-workspace
```

> Generated data, Terraform state, private keys, passphrases, and other secrets are intentionally excluded from Git.

---

# Source Database

The source system for the project is:

```text
Microsoft SQL Server
        │
        ▼
AdventureWorksDW2022
```

Primary tables used during implementation include:

```text
dbo.DimCustomer
dbo.DimProduct
dbo.FactInternetSales
```

The project initially uses `DimCustomer` to establish connectivity and extraction patterns and later uses `FactInternetSales` for the end-to-end pipeline.

---

# Stage 1 — SQL Server Connectivity & Python Extraction

**Status: ✅ Completed**

Implemented:

* SQL Server connectivity using Python
* pyodbc connectivity
* ODBC Driver 17
* Connection to AdventureWorksDW2022
* Database metadata inspection
* Customer extraction
* FactInternetSales extraction
* Batch-based extraction
* JSON/JSONL generation
* Deterministic ordering
* Extraction validation
* Duplicate detection
* Row-count validation

## Source Configuration

```text
Server: CHETAN\SQLSERVER2022
Database: AdventureWorksDW2022
ODBC Driver: ODBC Driver 17 for SQL Server
```

## FactInternetSales Extraction

Current validated dataset:

```text
Table: dbo.FactInternetSales
Rows: 60,398
Batch Size: 5,000
Output: JSONL
Files Generated: 13
Duplicate Order Lines: 0
```

Deterministic ordering is implemented using:

```text
SalesOrderNumber
SalesOrderLineNumber
```

---

# Stage 2 — Local File-Based Ingestion

**Status: ✅ Completed**

Implemented:

* Batch extraction
* Local file generation
* JSON/JSONL storage
* Storage abstraction
* Local storage simulation
* Storage bucket simulation
* Separation of extraction and storage responsibilities
* Local validation
* Record-count validation
* Duplicate validation

Generated data files are excluded from Git using `.gitignore`.

This stage establishes the abstraction that will allow the same extraction process to move from:

```text
Local Storage
```

to:

```text
Google Cloud Storage
```

without rewriting the core extraction logic.

---

# Stage 3 — Google Cloud Storage Ingestion

**Status: 🔄 Next**

The existing Python ingestion process will be extended to upload extracted files to Google Cloud Storage.

Target flow:

```text
SQL Server
     ↓
Python Extraction
     ↓
JSONL
     ↓
Google Cloud Storage
```

Planned implementation:

* GCP authentication
* GCS bucket creation
* Environment-specific storage
* GCS Python client
* Raw-zone structure
* Object naming conventions
* Date-based partition paths
* Upload validation
* Object existence validation
* Metadata
* Error handling
* Retry handling
* Idempotent uploads

Expected structure:

```text
GCS
└── advworks-dev-ingestion/
    ├── customer/
    │   └── YYYY/MM/DD/
    │
    └── fact_internet_sales/
        └── YYYY/MM/DD/
```

The existing Python extraction logic will be reused wherever possible.

---

# Stage 4 — Apache Airflow Orchestration

**Status: 🔲 Planned**

Apache Airflow will orchestrate the ingestion pipeline.

Target DAG:

```text
Extract
   ↓
Validate
   ↓
Generate JSONL
   ↓
Upload to GCS
   ↓
Validate GCS Object
```

Topics:

* DAGs
* Tasks
* Operators
* Scheduling
* Dependencies
* Retries
* Failure handling
* Sensors
* XCom
* Connections
* Variables
* Secrets
* Logging
* Task-level monitoring
* Backfills
* Catchup
* Idempotency

Target platform:

```text
Apache Airflow
       ↓
GKE
       ↓
Kubernetes
```

Airflow infrastructure will eventually be managed through Terraform.

---

# Stage 5 — Snowflake Cloud Storage Ingestion

**Status: 🔄 Partially Completed / Integration Pending**

Snowflake infrastructure has already been provisioned through Terraform.

Implemented Snowflake environments:

```text
DEV
TEST
PRE-PROD
PROD
```

Databases:

```text
ADVWORKS_DEV
ADVWORKS_TEST
ADVWORKS_PREPROD
ADVWORKS_PROD
```

Warehouses:

```text
ETL_WH_DEV
ETL_WH_TEST
ETL_WH_PREPROD
ETL_WH_PROD
```

Schemas:

```text
LANDING
PREPARE
NORMALIZE
SCHEMATIZE
MARKETPLACE
```

Next integration:

```text
GCS
  ↓
Snowflake External Stage
  ↓
File Format
  ↓
COPY INTO
  ↓
LANDING
```

Topics:

* External stages
* GCS integration
* Storage integrations
* File formats
* COPY INTO
* Load history
* File tracking
* Error handling
* Load validation

---

# Stage 6 — Pub/Sub + Snowpipe Event-Driven Ingestion

**Status: 🔲 Planned**

The pipeline will be converted from manually triggered ingestion to event-driven ingestion.

Target architecture:

```text
GCS
  │
  │ Object Created
  ▼
Google Pub/Sub
  │
  │ Notification
  ▼
Snowpipe
  │
  ▼
Snowflake LANDING
```

Objectives:

* Understand event-driven architecture
* Configure GCS notifications
* Configure Pub/Sub
* Integrate Pub/Sub with Snowpipe
* Implement automated ingestion
* Monitor Snowpipe
* Validate loaded files
* Handle failed files
* Understand near-real-time ingestion

---

# Stage 7 — dbt Transformations

**Status: ✅ Completed**

dbt transformation architecture has been implemented and validated.

```text
LANDING
   ↓
PREPARE
   ↓
NORMALIZE
   ↓
SCHEMATIZE
   ↓
MARKETPLACE
```

Implemented:

* dbt project
* Models
* Model dependencies
* Layered transformations
* Dimensional modeling
* Business models
* Data quality tests
* dbt parse
* dbt build
* Model lineage
* Documentation structure

## Validated Model Counts

```text
PREPARE
Customer: 18,484
Product: 606
Fact: 60,398

NORMALIZE
Customer: 18,484
Product: 606
Fact: 60,398

SCHEMATIZE
Customer: 18,484
Product: 606
Date: 10,000
Fact: 60,398

MARKETPLACE
Fact Rows: 60,398
```

## Data Quality Validation

Implemented tests include:

* Duplicate detection
* Referential integrity
* Row-count validation
* Business-level validation

Current dbt test result:

```text
4 / 4 tests passed
```

---

# Stage 8 — Dimensional Data Modeling

**Status: ✅ Completed**

The project implements a dimensional warehouse model.

Core dimensions:

```text
DIM_CUSTOMER
DIM_PRODUCT
DIM_DATE
```

Fact:

```text
FACT_SALES
```

The model supports role-playing date relationships such as:

```text
Order Date
Due Date
Ship Date
```

Target model:

```text
                  DIM_CUSTOMER
                       │
                       │
                       ▼
DIM_PRODUCT ─────► FACT_SALES ◄───── DIM_DATE
                       │
                       │
                       ▼
                  BI / Analytics
```

---

# Stage 9 — Terraform Infrastructure as Code

**Status: ✅ Completed**

Terraform is used to manage Snowflake infrastructure.

Implemented:

* Terraform configuration
* Provider configuration
* Snowflake authentication
* Encrypted private-key authentication
* Databases
* Schemas
* Warehouses
* Environment-specific variables
* Remote state
* GCS backend
* State locking
* State separation
* Terraform formatting
* Terraform validation
* Terraform planning
* Terraform deployment

Terraform version:

```text
Terraform: 1.15.8
Snowflake Provider: 2.20.0
```

## Environment Strategy

```text
DEV
TEST
PRE-PROD
PROD
```

Terraform state is separated by environment:

```text
GCS Terraform State Bucket
│
├── terraform/state/dev
├── terraform/state/test
├── terraform/state/preprod
└── terraform/state/prod
```

This prevents one environment from accidentally using another environment's Terraform state.

---

# Stage 10 — CI/CD with Azure DevOps

**Status: ✅ Completed / PROD APPLY PENDING**

Azure DevOps is used for automated validation, Terraform planning, approvals, and deployment.

Architecture:

```text
GitHub
   ↓
Azure DevOps Pipeline
   ↓
Python Validation
   ↓
dbt Validation
   ↓
Terraform Code Validation
   ↓
Google Cloud Authentication
   ↓
Terraform Plan
   ↓
Environment Approval
   ↓
Terraform Apply
```

## Implemented Pipeline Stages

```text
1. Python Validation
2. dbt Validation
3. Terraform Code Validation
4. Google Cloud WIF Validation
5. Terraform Plan - DEV
6. Terraform Apply - DEV
7. Terraform Plan - TEST
8. Terraform Apply - TEST
9. Terraform Plan - PRE-PROD
10. Terraform Apply - PRE-PROD
11. Terraform Plan - PROD
12. Terraform Apply - PROD
```

Current validation status:

```text
DEV       ✅
TEST      ✅
PRE-PROD  ✅
PROD PLAN ✅
PROD APPLY ⏳
```

---

# Workload Identity Federation

**Status: ✅ Completed**

The CI/CD pipeline authenticates to Google Cloud using Workload Identity Federation instead of storing a long-lived Google Cloud service-account key.

Architecture:

```text
Azure DevOps
      │
      │ OIDC Token
      ▼
Microsoft Entra ID
      │
      ▼
Google Workload Identity Federation
      │
      ▼
Google Service Account
      │
      ▼
GCP Resources
```

Benefits:

* No long-lived GCP service-account key
* Short-lived credentials
* Federated authentication
* Better security
* Suitable for enterprise CI/CD

---

# GCP Terraform State

**Status: ✅ Completed**

Terraform remote state is stored in Google Cloud Storage.

State bucket:

```text
electric-tesla-507710-k2-tfstate
```

Configuration includes:

* Remote GCS backend
* Environment-specific state prefixes
* Bucket-level access controls
* Versioning
* Soft delete
* Public access prevention
* State locking

Example:

```text
terraform/state/dev/default.tfstate
terraform/state/test/default.tfstate
terraform/state/preprod/default.tfstate
terraform/state/prod/default.tfstate
```

---

# Stage 11 — Data Quality & Validation

**Status: 🔄 Partially Completed**

Data quality is already implemented at multiple stages and will continue to expand.

Current validations:

* Source connectivity
* Extraction row counts
* Duplicate detection
* Deterministic extraction
* dbt model validation
* Referential integrity
* Fact row counts
* Business totals
* Terraform validation
* CI/CD validation

Current FactInternetSales baseline:

```text
Rows:
60,398

Distinct Order Lines:
60,398

Duplicate Order Lines:
0

TOTAL_SALES:
29,358,677.2207

TOTAL_PRODUCT_COST:
17,277,793.5757

TOTAL_TAX:
2,348,694.2301

TOTAL_FREIGHT:
733,969.6091
```

Future checks:

* Null validation
* Schema validation
* Source-to-target reconciliation
* File completeness
* Late-arriving data
* Schema drift
* Data freshness
* Pipeline SLA
* Business-rule validation

---

# Stage 12 — Error Handling, Retry & Idempotency

**Status: 🔲 Planned**

Production-style ingestion behavior will be implemented.

Topics:

* Retry strategies
* Exponential backoff
* Failed records
* Dead-letter handling
* Partial failures
* Duplicate file handling
* Idempotent processing
* Transaction boundaries
* Checkpointing
* Reprocessing
* Recovery strategies

Example:

```text
File Arrives
    ↓
Process
    ↓
Success ─────► Mark Complete
    │
    └── Failure
          ↓
       Retry
          ↓
       Retry
          ↓
      Dead Letter
```

---

# Stage 13 — Incremental Loads & CDC

**Status: 🔲 Planned**

The current pipeline primarily demonstrates batch extraction.

The next evolution will cover:

```text
Full Load
   ↓
Incremental Load
   ↓
CDC
```

Topics:

* Watermarks
* Last modified timestamps
* High-water marks
* Change tracking
* CDC concepts
* Insert/update/delete handling
* MERGE
* SCD Type 1
* SCD Type 2
* Incremental dbt models

---

# Stage 14 — Security & IAM

**Status: 🔲 Planned**

Security will be implemented across:

```text
SQL Server
GCP
GCS
Pub/Sub
Airflow
Snowflake
Azure DevOps
```

Topics:

* IAM
* Least privilege
* Service accounts
* Workload Identity Federation
* Snowflake RBAC
* Secrets management
* Private keys
* Credential rotation
* Environment isolation
* Bucket permissions
* Data access controls

Secrets and private keys will never be committed to Git.

---

# Stage 15 — Monitoring, Logging & Alerting

**Status: 🔲 Planned**

Production monitoring will cover:

```text
Pipeline
   ↓
Logs
   ↓
Metrics
   ↓
Alerts
   ↓
Incident Response
```

Monitoring areas:

* Airflow task failures
* DAG failures
* GCS upload failures
* Pub/Sub failures
* Snowpipe failures
* Snowflake load failures
* dbt failures
* Data quality failures
* Pipeline duration
* Data freshness
* SLA breaches

---

# Stage 16 — Performance & Cost Optimization

**Status: 🔲 Planned**

The project will cover optimization across the platform.

Topics:

### Python

* Batch size
* Memory management
* Streaming
* Parallel extraction

### GCS

* File sizing
* Compression
* Object organization

### Snowflake

* Warehouse sizing
* Auto-suspend
* Auto-resume
* Query optimization
* Clustering
* Micro-partitions
* Caching
* Cost monitoring

### dbt

* Incremental models
* Materializations
* Model dependencies
* Query optimization

### Airflow

* Parallelism
* DAG scheduling
* Executor selection
* Task concurrency

---

# Stage 17 — Production Architecture

**Status: 🔲 Planned**

The final architecture will simulate an enterprise Data Engineering platform.

```text
                    ┌────────────────────┐
                    │    Source Systems  │
                    │ SQL Server/Oracle  │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │      Airflow       │
                    │   Orchestration    │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │        GCS         │
                    │     Raw Layer      │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │     Pub/Sub        │
                    │   Event Layer      │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │     Snowpipe       │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │     Snowflake      │
                    │                    │
                    │ Landing            │
                    │ Prepare            │
                    │ Normalize          │
                    │ Schematize         │
                    │ Marketplace        │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │       dbt          │
                    │ Transformations    │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │   BI / Analytics   │
                    │ Tableau / Power BI │
                    └────────────────────┘
```

Supporting services:

```text
GitHub
Azure DevOps
Terraform
GCP IAM
Monitoring
Secrets Management
```

---

# Environment Strategy

The project uses isolated environments.

```text
DEV
TEST
PRE-PROD
PROD
```

## Snowflake

```text
ADVWORKS_DEV
ADVWORKS_TEST
ADVWORKS_PREPROD
ADVWORKS_PROD
```

## Warehouses

```text
ETL_WH_DEV
ETL_WH_TEST
ETL_WH_PREPROD
ETL_WH_PROD
```

## GCS

Planned:

```text
advworks-dev-ingestion
advworks-test-ingestion
advworks-preprod-ingestion
advworks-prod-ingestion
```

## Terraform State

```text
terraform/state/dev
terraform/state/test
terraform/state/preprod
terraform/state/prod
```

Environment promotion:

```text
DEV
 ↓
TEST
 ↓
PRE-PROD
 ↓
PROD
```

Production deployment requires an explicit approval through Azure DevOps.

---

# Current End-to-End Data Flow

The completed and planned pipeline progressively evolves into:

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
 Snowflake LANDING
        │
        ▼
     dbt
        │
        ▼
    PREPARE
        │
        ▼
   NORMALIZE
        │
        ▼
  SCHEMATIZE
        │
        ▼
  MARKETPLACE
        │
        ▼
 Tableau / Power BI
```

---

# Infrastructure & Deployment Flow

Infrastructure:

```text
Terraform
    │
    ├── Snowflake Database
    ├── Snowflake Schemas
    ├── Snowflake Warehouses
    ├── GCS
    ├── Pub/Sub
    ├── IAM
    └── Airflow / GKE
```

CI/CD:

```text
Developer
   │
   ▼
GitHub
   │
   ▼
Azure DevOps
   │
   ├── Python Validation
   ├── dbt Validation
   ├── Terraform Validation
   └── WIF Authentication
          │
          ▼
     Terraform Plan
          │
          ▼
       Approval
          │
          ▼
     Terraform Apply
```

---

# Git Workflow

GitHub is used as the source-code repository.

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

Repository:

```text
Chetanchandra1994/Data-pipeline-end-to-end
```

---

# Security Practices

The project follows secure development practices.

Implemented:

* `.gitignore` for secrets
* Terraform state excluded from Git
* Private keys excluded from Git
* Snowflake passphrases excluded from Git
* Azure DevOps secret variables
* Azure DevOps secure files
* GCP Workload Identity Federation
* Short-lived cloud authentication
* Environment separation
* Remote Terraform state
* State locking

Sensitive credentials should never be committed to the repository.

---

# Interview & Learning Focus

This project is also designed as a Data Engineering interview preparation platform.

Each implementation stage is accompanied by concepts and interview scenarios covering:

### SQL

* Joins
* CTEs
* Window functions
* Aggregations
* Query optimization
* Incremental extraction

### Python

* File processing
* APIs
* Database connectivity
* Batch processing
* Exception handling
* Logging
* Memory optimization
* Object-oriented design

### Airflow

* DAG design
* Operators
* Scheduling
* Retries
* Sensors
* XCom
* Executors
* Failure handling

### GCP

* GCS
* Pub/Sub
* IAM
* Service accounts
* Workload Identity
* Event-driven architecture

### Snowflake

* Warehouses
* Databases
* Schemas
* Stages
* COPY INTO
* Snowpipe
* Micro-partitions
* RBAC
* Performance optimization

### dbt

* Models
* Sources
* Tests
* Macros
* Seeds
* Snapshots
* Incremental models
* Materializations
* Lineage

### Terraform

* Providers
* Resources
* Variables
* State
* Remote backends
* Modules
* Environment management
* Plan vs Apply
* State locking

### CI/CD

* Pipeline stages
* Artifacts
* Approvals
* Environment promotion
* Secure authentication
* WIF
* Infrastructure deployment

### Production Scenarios

* Duplicate files
* Pipeline failures
* Late-arriving data
* Schema changes
* Data quality failures
* Incremental loads
* CDC
* Backfills
* Reprocessing
* Disaster recovery
* Cost optimization
* Security

---

# Project Progress

| Stage | Component                            | Status                 |
| ----- | ------------------------------------ | ---------------------- |
| 1     | SQL Server + Python extraction       | ✅ Completed            |
| 2     | Local ingestion/storage              | ✅ Completed            |
| 3     | GCS ingestion                        | 🔄 Next                |
| 4     | Airflow orchestration                | 🔲 Planned             |
| 5     | Snowflake cloud ingestion            | 🔄 Partially Completed |
| 6     | Pub/Sub + Snowpipe                   | 🔲 Planned             |
| 7     | dbt transformations                  | ✅ Completed            |
| 8     | Dimensional modeling                 | ✅ Completed            |
| 9     | Terraform Infrastructure             | ✅ Completed            |
| 10    | Azure DevOps CI/CD                   | ✅ Completed*           |
| 11    | Data Quality                         | 🔄 In Progress         |
| 12    | Error Handling / Retry / Idempotency | 🔲 Planned             |
| 13    | Incremental / CDC                    | 🔲 Planned             |
| 14    | Security / IAM                       | 🔄 In Progress         |
| 15    | Monitoring / Logging / Alerting      | 🔲 Planned             |
| 16    | Performance / Cost Optimization      | 🔲 Planned             |
| 17    | Production Architecture              | 🔲 Planned             |
| 18    | BI Consumption                       | 🔲 Planned             |
| 19    | Interview Scenarios                  | 🔄 In Progress         |
| 20    | Mock Data Engineering Interviews     | 🔲 Planned             |

* DEV, TEST, and PRE-PROD deployment are validated through CI/CD. PROD Plan is validated; PROD Apply requires the final production approval/deployment.

---

# Current Project Milestone

The project has completed the foundation and infrastructure layers:

```text
SQL Server
    ↓
Python Extraction
    ↓
Local Ingestion
    ↓
Snowflake
    ↓
dbt
    ↓
Terraform
    ↓
Remote Terraform State
    ↓
Azure DevOps
    ↓
WIF Authentication
    ↓
DEV
    ↓
TEST
    ↓
PRE-PROD
    ↓
PROD PLAN
```

The next major milestone is:

```text
Python
   ↓
GCS
   ↓
Airflow
   ↓
Pub/Sub
   ↓
Snowpipe
   ↓
Snowflake LANDING
```

This will convert the existing local ingestion process into a real cloud-based ingestion pipeline.

---

# Learning Objectives

By completing this project, the goal is to gain practical experience with:

1. SQL Server
2. SQL
3. Python
4. Data extraction
5. Batch processing
6. JSON / JSONL
7. Google Cloud Storage
8. Apache Airflow
9. Google Pub/Sub
10. Snowflake
11. Snowpipe
12. dbt
13. Dimensional modeling
14. Terraform
15. Remote Terraform state
16. IAM
17. Workload Identity Federation
18. Azure DevOps
19. CI/CD
20. Data quality
21. Error handling
22. Idempotency
23. Incremental processing
24. CDC
25. Monitoring
26. Performance optimization
27. Cost optimization
28. Production architecture
29. BI consumption
30. Data Engineering interview preparation

---

# Disclaimer

This is a personal Data Engineering learning and practice project built using the AdventureWorks sample dataset.

The architecture and implementation are designed to simulate an enterprise-grade Data Engineering platform for educational and interview-preparation purposes.

The project intentionally combines multiple technologies to provide hands-on experience with modern Data Engineering concepts, cloud ingestion, orchestration, transformation, infrastructure automation, CI/CD, data quality, and production-style architecture.
