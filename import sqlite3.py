import sqlite3

# Connect to the database
conn = sqlite3.connect('your_database.db')
cursor = conn.cursor()

# Add a new column "location" to the table
cursor.execute("ALTER TABLE sqlitebrowser_rename_column_new_table ADD COLUMN location TEXT")

# Commit and close the connection
conn.commit()
conn.close()
