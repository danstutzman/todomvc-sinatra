package main

import (
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	_ "github.com/lib/pq"
	"log"
	"net/http"
	"os"
)

type Body struct {
	DeviceUid string `json:"deviceUid"`
}

type CommandLineArgs struct {
	postgresCredentialsPath *string
}

func mustParseFlags() CommandLineArgs {
	args := CommandLineArgs{
		postgresCredentialsPath: flag.String(
			"postgres_credentials_path", "", "JSON file with username and password"),
	}
	flag.Parse()
	if *args.postgresCredentialsPath == "" {
		log.Fatal("Missing -postgres_credentials_path")
	}
	return args
}

func mustOpenPostgres(postgresCredentialsPath string) *sql.DB {
	postgresCredentialsFile, err := os.Open(postgresCredentialsPath)
	if err != nil {
		log.Fatal(fmt.Errorf("Couldn't os.Open postgres_credentials: %s", err))
	}
	defer postgresCredentialsFile.Close()

	type PostgresCredentials struct {
		Username     *string
		Password     *string
		DatabaseName *string
		SSLMode      *string
	}
	postgresCredentials := PostgresCredentials{}
	decoder := json.NewDecoder(postgresCredentialsFile)
	if err = decoder.Decode(&postgresCredentials); err != nil {
		log.Fatalf("Error using decoder.Decode to parse JSON at %s: %s",
			postgresCredentialsPath, err)
	}

	dataSourceName := ""
	if postgresCredentials.Username != nil {
		dataSourceName += " user=" + *postgresCredentials.Username
	}
	if postgresCredentials.Password != nil {
		dataSourceName += " password=" + *postgresCredentials.Password
	}
	if postgresCredentials.DatabaseName != nil {
		dataSourceName += " dbname=" + *postgresCredentials.DatabaseName
	}
	if postgresCredentials.SSLMode != nil {
		dataSourceName += " sslmode=" + *postgresCredentials.SSLMode
	}

	db, err := sql.Open("postgres", dataSourceName)
	if err != nil {
		log.Fatal(fmt.Errorf("Error from sql.Open: %s", err))
	}

	// Test out the database connection immediately to check the credentials
	ignored := 0
	err = db.QueryRow("SELECT 1").Scan(&ignored)
	if err != nil {
		log.Fatal(fmt.Errorf("Error from db.QueryRow: %s", err))
	}

	return db
}

func mustRunWebServer(db *sql.DB) {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handleRequest(w, r, db)
	})
	log.Printf("Listening on :3000...")
	err := http.ListenAndServe(":3000", nil)
	if err != nil {
		log.Fatalf("Error from ListenAndServe: %s", err)
	}
}

func main() {
	args := mustParseFlags()
	db := mustOpenPostgres(*args.postgresCredentialsPath)
	mustRunWebServer(db)
}
