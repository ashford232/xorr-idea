package database

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func InitDB(host, user, password, dbname, port string) error {
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable", host, port, user, password, dbname)
	var err error
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		return err
	}
	if err = DB.Ping(); err != nil {
		return err
	}
	return createTables()
}

func createTables() error {
	// Run each schema statement separately so existing Docker volumes are
	// upgraded and failures identify the exact migration that stopped startup.
	statements := []struct {
		name  string
		query string
	}{
		{
			name: "users table",
			query: `CREATE TABLE IF NOT EXISTS users(
				id SERIAL PRIMARY KEY,
				email VARCHAR(255) UNIQUE NOT NULL,
				password VARCHAR(200) NOT NULL,
				username VARCHAR(255),
				photo_url VARCHAR(255)
			)`,
		},
		{
			name: "items table",
			query: `CREATE TABLE IF NOT EXISTS items(
				id SERIAL PRIMARY KEY,
				title VARCHAR(255) NOT NULL,
				description TEXT,
				user_id INT REFERENCES users(id) ON DELETE CASCADE
			)`,
		},
	}

	for _, statement := range statements {
		if _, err := DB.Exec(statement.query); err != nil {
			return fmt.Errorf("create %s: %w", statement.name, err)
		}
	}
	return nil
}
