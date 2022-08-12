# Connect to sql server database
from email import message
from socket import timeout
from turtle import title
import pyodbc 
import pandas as pd 
import csv
from plyer import notification

"""
Step 1: Cleaning the data that we want to insert.

"""
# Reading from the csv file  
df = pd.read_csv("movies.csv")
df = df.fillna(value=0) # Define rule that every empty cell will get 0.

# Change realese_date dtype to datetime
df['release_date'] = pd.to_datetime(df['release_date'])
"""
Pandas data types are diffrent from sql data types.
We need to create a dict that contains the pands dtype and sql dtype so we will be able to replace between them.
"""

# Create replacment dictionary
replacement_dict = {
    'object': 'varchar(MAX)',
    'int64': 'int',
    'float64': 'float',
    'datetime64': 'timestamp',
    'bool': 'BIT'
}

# creating row of tuples superted with , sign.
# replace all the pandas dtypes with sql dtypes from the dict we build using zip format and replace.
col_str = ", ".join("{} {}".format(n, d) for n,d in zip(df.columns, df.dtypes.replace(replacement_dict)))
# print(col_str)
    
"""
STEP 2: Creating database connection 
"""

server= 'DESKTOP-5EVNBVL'
database = 'MoviedbProject'
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server}; \
                       SERVER=' + server + '; \
                       DATABASE=' + database + ';\
                       Trusted_Connection=yes;')

print(f'''Connect succesfully to {database} datebase...''')

# Creating connection cursor
cursor = cnxn.cursor()
print('')
print(f'''Connection cursor created succesfully...''')

# Creating queries to establish the tables
table_name = "movies"
drop_table = f"drop table if exists {table_name};"
create_table = f'''create table {table_name} (adult BIT, backdrop_path varchar(MAX), budget int, homepage varchar(MAX), id int, imdb_id varchar(MAX), original_language varchar(MAX), original_title varchar(MAX), overview varchar(MAX), popularity float, poster_path varchar(MAX), release_date datetime, revenue int, runtime int, status varchar(MAX), tagline varchar(MAX), title varchar(MAX), video BIT, vote_average float, vote_count int);
'''
cursor.execute(drop_table) 
print('')
print(f"{table_name} table droped...")

cursor.execute(create_table) # executing the query inside the sql database
print('')
print(f"Table {table_name} Created succesfully... ")

# Create place holder var that will put ? sign for each column.
place_holders = (len(df.columns) * '?, ').rstrip(', ')

"""
STEP 3: Insert the values from the csv file into the table we created.
"""
insert_query = f'''
 INSERT INTO [dbo].[movies]
           ([adult]
           ,[backdrop_path]
           ,[budget]
           ,[homepage]
           ,[id]
           ,[imdb_id]
           ,[original_language]
           ,[original_title]
           ,[overview]
           ,[popularity]
           ,[poster_path]
           ,[release_date]
           ,[revenue]
           ,[runtime]
           ,[status]
           ,[tagline]
           ,[title]
           ,[video]
           ,[vote_average]
           ,[vote_count])
        values ({place_holders})
 '''
df_records = df.values.tolist()

cursor.executemany(insert_query,df_records)

# Creating status notification 
notification.notify(title = "Status:",
message = f"Data inserted succesfully into {table_name} table.\
    \n Total Rows: {df.shape[0]},\n Total Columns: {df.shape[1]}",
    timeout = 10)

# commit the changes - important if we want to see the changes in db.
cnxn.commit()

cursor.close()
cnxn.close()
