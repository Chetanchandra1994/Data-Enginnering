import snowflake.connector
import getpass

password = getpass.getpass("Snowflake password: ")
#totp = getpass.getpass("Current TOTP code: ")

conn = snowflake.connector.connect(
    account="QNFANFA-QI17075",
    user="CHETANCHANDRA81",
    password=password,
    authenticator="username_password_mfa",
 #   passcode=totp,
    client_request_mfa_token=True,
    database="ADVWORKS_DEV",
    schema="PREPARE",
    warehouse="ETL_WH_DEV",
    role="ACCOUNTADMIN",
)

cursor = conn.cursor()

cursor.execute("""
    SELECT
        CURRENT_USER(),
        CURRENT_ROLE(),
        CURRENT_DATABASE(),
        CURRENT_SCHEMA(),
        CURRENT_WAREHOUSE()
""")

print(cursor.fetchone())

cursor.close()
conn.close()

print("Snowflake MFA connection successful!")