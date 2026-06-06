import mysql.connector
import config

def run_sql():
    try:
        # Connect to MySQL server (initially without database in case it doesn't exist)
        conn = mysql.connector.connect(
            host=config.MYSQL_HOST,
            port=config.MYSQL_PORT,
            user=config.MYSQL_USER,
            password=config.MYSQL_PASSWORD
        )
        cursor = conn.cursor()
        
        with open('elite_sports_club.sql', 'r', encoding='utf-8') as file:
            sql_script = file.read()
            
        lines = sql_script.split('\n')
        current_delimiter = ';'
        statement = []
        
        for line in lines:
            stripped = line.strip()
            if not stripped:
                continue
            if stripped.startswith('--') or stripped.startswith('#'):
                continue
            if stripped.upper().startswith('DELIMITER'):
                # Change delimiter (e.g. DELIMITER // -> //)
                current_delimiter = stripped.split()[1]
                continue
            
            statement.append(line)
            if stripped.endswith(current_delimiter):
                stmt_text = '\n'.join(statement).strip()
                # Remove delimiter from the end of the statement text
                if stmt_text.endswith(current_delimiter):
                    stmt_text = stmt_text[:-len(current_delimiter)].strip()
                
                if stmt_text:
                    try:
                        cursor.execute(stmt_text)
                        # Consume any results to avoid "Unread result found"
                        if cursor.description:
                            cursor.fetchall()
                        try:
                            while cursor.nextset():
                                if cursor.description:
                                    cursor.fetchall()
                        except mysql.connector.Error:
                            pass
                    except mysql.connector.Error as err:
                        print(f"Error executing statement:\n{stmt_text}\nError: {err}")
                        raise err
                statement = []
                
        conn.commit()
        print("Database recreated and seeded successfully.")
    except Exception as e:
        print(f"Failed to execute SQL: {e}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == '__main__':
    run_sql()
