import boto3
import mysql.connector
import csv
import os
import json
from dotenv import load_dotenv

load_dotenv()

# RDS MySQL connection details
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")

# Create Table
create_table_sql = """
CREATE TABLE IF NOT EXISTS iris (
    sepal_length FLOAT,
    sepal_width FLOAT,
    petal_length FLOAT,
    petal_width FLOAT,
    species VARCHAR(50)
);
"""

# Connect to S3
s3 = boto3.client('s3')

def lambda_handler(event, context):

    bucket = event['Records'][0]['s3']['bucket']['name']
    csv_file = event['Records'][0]['s3']['object']['key']

    try:
        csv_file_obj = s3.get_object(Bucket=bucket, Key=csv_file)
    except Exception as e:
        print("Error downloading CSV file from S3:", e)
        exit(1)

    lines = csv_file_obj['Body'].read().decode('utf-8').split()
    results = []
    for row in csv.DictReader(lines):
        results.append(row.values())
    #print(results)

    try:
        conn = mysql.connector.connect(host=db_host, port=db_port, database=db_name, user=db_user, password=db_password)
        cursor = conn.cursor()
        cursor.execute(create_table_sql)
    except mysql.connector.Error as e:
        print("Error connecting to MySQL:", e)
        exit(1)
    
    mysql_insert_query = "INSERT INTO iris (sepal_length, sepal_width, petal_length, petal_width, species) VALUES (%s, %s, %s, %s, %s)"

    try:
        cursor.executemany(mysql_insert_query,results)
        conn.commit()
        print(cursor.rowcount, "Record inserted successfully into employee table")
    except mysql.connector.Error as e:
        conn.rollback()
        print("Error inserting data into MySQL:", e)
    finally:
        cursor.close()
        conn.close()

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }