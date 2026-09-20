# Welcome to the Group Canam Enterprise Team DBT project  #

The Enterprise team is responsible for providing data services and tools that will help generate business insights for the entire Canam organization. 

Data can be consumed directly from Snowflake by power users (via the Snowflake UI, python, etc.) or via BI reporting tools like Tableau. 

Data from the following sources have been ingested so far:

- Oracle's EBS
- Canam's proprietary Supplier model.
- Canam's RDM via Big Query.
- SPM data (factory production data)  

Most of the data is automatically ingested using Snowpipes which load data written to GCP (more information in this [repo](https://dev.azure.com/canamgroup/Data%20Platform/_git/snowpipe-terraform)).

## Repository Structure ##

```bash
├── macros/                 # Custom Jinja macros
├── models/
│   ├── landing/            # Includes a landing.yml detailing where to get the source data from. 
│   ├── prepare/       
│       ├── /{sources}/     # sources ∈ {bigquery, ebs, canam_model, ...}.
│   ├── normalize/ 
│       ├── /{sources}/      
|   ├── schematize/     
│       ├── /dimensions/    # Contains the .sql files for the dimensions data objects of the star schema.
│       ├── /facts/         # Contains the .sql files for the facts data objects of the star schema.
│   ├── marketplace/    
│       ├── /dimensions/    
│       ├── /facts/    
│       ├── /dataproducts/  # Contains the dataproducts table used as the basis for reports created in the /visuals/ folder   
│       ├── /visuals/       # Tableau reports
│   └── governance/         
├── azure-pipeline.yml      # Contains the Azure devops pipeline specs --- see the "The deployment pipeline (CICD)" section below.
├── dbt_project.yml         # dbt project configuration
├── packages.yml            # Contains the packages that need to be installed --- see the "Using the dbt-utils package to generate surrogate keys" section below.
├── profiles.yml            # --- see the "dbt profiles" section below.
├── requirements.txt        # Contains the dbt version to install --- see the "Installing dbt" section below.
└── README.md               # Documentation
```

**Note**: There are other folders that are supported in a dbt project structure like analysis, docs, seeds, snapshot, tests, etc. 
These are not included above as we are not using them so far but they could be used in the future (additional information [here](https://docs.getdbt.com/docs/build/projects)).


## Data models: ##

There are 5 layers in the data model (see  `/models` folder):

1. LANDING: Where data is written in Snowflake (usually, a Snowpipe will
acquire data from Google Cloud Storage (CGS) and write it to this layer).
2. PREPARE: Where (if needed) we transform/flatten the raw data (often .json)
in a workable table structure.
3. NORMALIZE: This is where the data is cleaned and standardized to an
agreed-upon Canam format (for dates, numbers, currencies, locations,
addresses, etc.). 
This is also where we use the **RDM** information to standardize some fields.
This is also where data is **deduplicated**. 
4. SCHEMATIZE: Where we build the facts and dimension tables of the star
schema.
5. MARKETPLACE: The final data products for consumption. This includes
value-added (dataproducts & reporting) tables developed for reporting (+ other needs) 
and the finalized dimensions and facts tables of the star schema for the power-users of the business.

6. GOVERNANCE: Contains reference data, master data, policies, and metadata that are officially managed and approved by data stewards at Groupe Canam.

────────────

Here's the data flow between the layers:

| Data Stage  | Next Step |
|------------|-------------|
| 🔴 LANDING  | 🟡 PREPARE  |
| 🟡 PREPARE  | 🟠 NORMALIZE  |
| 🟠 NORMALIZE  | 🔵 SCHEMATIZE, 🟣 GOVERNANCE  |
| 🔵 SCHEMATIZE  | 🟢 MARKETPLACE  |



---

## Local Setup ##

Follow these steps to configure your local development environment.

1.  **Prerequisites**:
    *   Ensure you have [Python installed](https://www.python.org/downloads/windows/).
    *   Verify that `python` and `pip` are included in your system's PATH environment variables.

2.  **Create a Virtual Environment**:
    This keeps your project dependencies isolated.
    ```bash
    # Create the virtual environment
    python -m venv venv
    ```

3.  **Configure Snowflake Credentials**:
    Edit your virtual environment's activation script (e.g., `venv\Scripts\activate.bat` on Windows) to set your Snowflake credentials as environment variables.
    ```batch
    set DBT_SNOWFLAKE_ACCOUNT=your_account.ca-central-1.aws
    set DBT_SNOWFLAKE_USER=your_user
    set DBT_SNOWFLAKE_ROLE=your_role
    set DBT_SNOWFLAKE_DATABASE=your_database
    set DBT_SNOWFLAKE_WAREHOUSE=your_warehouse
    set DBT_SNOWFLAKE_SCHEMA=your_schema
    ```

4.  **Activate the Virtual Environment and Install Dependencies**:
    With the virtual environment configured, activate it and install the necessary packages.
    ```bash
    # Activate the environment (on Windows)
    venv\Scripts\activate

    # Install dependencies
    pip install -r requirements.txt
    ```

5.  **Verify Connection**:
    Run `dbt debug --target local`. A successful connection will produce the following output:
    ```bash
    Connection test: [✅ OK connection ok]
    ✅ All checks passed!
    ```

### dbt profiles ###

dbt profiles are defined in the [profiles.yml](profiles.yml) file, which contains the credentials and settings dbt uses to connect to Snowflake. <br>Currently there are 2 profiles: <br>(1) **test** is for the test environment and is used by the [deployment pipeline](#the-deployment-pipeline-cicd) to build the test environment (this is why you will see a `--target test` flag in the [azure-pipeline.yml](azure-pipeline.yml) file) <br> (2) **local** is used by developers to run dbt from their local machine with a sandbox target (i.e. sandbox databases). 

### Common dbt commands ###

```bash
dbt debug  # Test the connection
dbt deps   # Install dependencies
dbt seed   # Load seed files
dbt run    # Run transformations.
dbt test   # Run data tests
dbt docs generate && dbt docs serve  # Generate and view documentation
```
Additional documentation [here](https://docs.getdbt.com/reference/dbt-commands)

**Note1**: you can run specifc dbt models using the --select flag.<br>
**Note2**: you can run specific target profiles using the --target  flag.

For example, executing `dbt run --select models/normalize/canam_model/norm_canammodel_suppliersInvoiceFromProfiles.sql --target local` <br>
will only build the canam_model.suppliersInvoiceFromProfiles view in Snowflake in the database associated with your SANDBOX.


## Best practices & syntax ##

- **Use snake_case for column names** (<mark>To be implemented consistently across models</mark>):

    <br> By default, Snowflake  will save column names in UPPERCASE. This means a column named `AS BusinessApplicationCode` in Snowflake will be saved as BUSINESSAPPLICATIONCODE. Saving the column using snake_case with `AS Business_Application_Code` will make BUSINESS_APPLICATION_CODE less ambiguous.


- **Use a _SK suffix for generated (columns) surrogate keys**:
<br><br> Surrogate keys are generated in the normalize layer and a "_SK" suffix is used:
<br><br>Ex: IF_PROFILE_SK (in sche_dim_InvoiceFrom_Profile.sql), SUPPLIER_PURCHASEINVOICE_SK (in sche_fact_PurchaseInvoice.sql), etc.

- **Naming .sql files**: 
<br><br> For the 🟡 prepare and 🟠 normalize layers, the naming convention should be {*layer_abbreviation*}\_{*source_abbreviation*}_{*data_object_name_snake_case*}.sql
<br> So *layer_abbreviation* ∈ {prep, norm}, (so far) *source_abbreviation* ∈ {bigquery, manual, canammoodel, cm50} 
<br><br><mark>I think SPM source data needs to be revised and snake_case implemented for all objects.</mark>

    <br> For the 🔵 schematize and 🟢 marketplace layers, the naming convention should be {*layer_abbreviation*}\_{*data_category_abbreviation*}_{*data_object_name_snake_case*}.sql
<br> So *layer_abbreviation* ∈ {sche, mkt} & *data_category_abbreviation* ∈ {dim, fact, dataproduct, viz} 

- **Folder structure for the dbt model layers**: 

    See the [Repository Structure](#Repository Structure) section. It is by source (ex: bigquery, canam_model, ebs, etc.) for the 🟡 prepare and 🟠 normalize layers. It is by data_category (ex: dimensions, facts, dataproducts, visuals) for the 🔵 schematize and 🟢 marketplace layers.

- **SQL syntax styling**: 

    <br><mark>TBD & then implemented across all models - this [link](https://docs.getdbt.com/best-practices/how-we-style/2-how-we-style-our-sql) could be of interest.</mark><br><br>

- **Using persist_docs and .yml files for describing data objects and columns in Snowflake**: 

    <br><mark>TBD by Steven Maheux</mark><br><br>

- **Using dbt tests to validate the uniqueness of keys**: 
<br><br> This was implemented for **every key including surrogate keys** (see [here](models/schematize/dimensions/dimensions.yml) and [here](models/schematize/facts/facts.yml)) in the schematize layer and [here](models/marketplace/dataproducts/dataproducts.yml) as well for the dataproducts table.<br>The tests are ran by the [deployment pipeline](#the-deployment-pipeline-cicd) after a PR is merged.<br> <u>The pipeline will fail if the tests are not successful</u>. 

- **Using the [dbt-utils package](https://github.com/dbt-labs/dbt-utils) to generate surrogate keys**: 
<br><br> Using dbt_utils.generate_surrogate_key() ensures consistent, NULL-safe key generation across dbt models while keeping the code consistent if you ever decide to integrate other systems besides Snowflake with dbt.<br><br>dbt packages are installed as part of the [deployment pipeline](#the-deployment-pipeline-cicd) both on PR and on merge.<br>The packages to install are defined in the [packages.yml](packages.yml) file. 


## The deployment pipeline (CICD) ##

On the creation of a **Pull Request** (PR) from a branch into main, an Azure Devops pipeline will automatically trigger a job that:
- Runs a `dbt deps` command to install the packages and dependencies.
- Runs a `dbt debug` command to test the connection to Snowflake.
- Runs a `dbt compile` command to make sure all the sql syntax makes sense.

Once a PR is approved and merged, this will trigger a job that:
- Runs a `dbt deps` command to install the packages and dependencies.
- Runs a `dbt debug` command to test the connection to Snowflake.
- Runs a `dbt compile` command to make sure all the sql syntax makes sense.
- Runs a `dbt run` command that will execute the compiled sql model files in Snowflake.
- Runs a `dbt test` command that will run the defined data tests against the models/data objects in Snowflake. 

<br>

## What moves the data from layer to layer - Dynamic tables and orchestration ##

We use **Snowflake's dynamic tables** to move data from layer to layer in the data model.
This allows us to materialize the data where we need it. 
The materializations happen automatically (it's managed by Snowflake) when the source data of the dynamic tables has been changed in any way. 
That means that when data is written to the landing layer via the Snowpipes, this will automatically trigger the dynamic tables to recompute if that table relies on data that has been updated.
<br>
This type of architecture allows us <u>not to rely on an orchestration tool</u> like Airflow or Prefect that would "normally" have had to trigger dbt to run at a specific time. It is one less stack to manage.  



## Additional Resources ##

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
