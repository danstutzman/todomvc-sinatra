package main

import (
	"./models"
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	_ "github.com/lib/pq"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
)

type Body struct {
	DeviceUid string `json:"deviceUid"`
}

type CommandLineArgs struct {
	postgresCredentialsPath string
	socketPath              string
}

func mustParseFlags() CommandLineArgs {
	var args CommandLineArgs
	flag.StringVar(&args.postgresCredentialsPath, "postgres_credentials_path", "",
		"JSON file with username and password")
	flag.StringVar(&args.socketPath, "socket_path", "",
		"Path for UNIX socket server for testing")
	flag.Parse()
	if args.postgresCredentialsPath == "" {
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

func mustRunWebServer(model models.Model) {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handleRequest(w, r, model)
	})
	log.Printf("Listening on :3000...")
	err := http.ListenAndServe(":3000", nil)
	if err != nil {
		log.Fatalf("Error from ListenAndServe: %s", err)
	}
}

func mustRunSocketServer(socketPath string, model models.Model) {
	log.Printf("Listening on %s...", socketPath)
	l, err := net.Listen("unix", socketPath)
	if err != nil {
		log.Fatal("listen error:", err)
	}
	defer l.Close()

	// Shut down server (delete socket file) if SIGINT received
	sigc := make(chan os.Signal, 1)
	signal.Notify(sigc, os.Interrupt)
	go func(c chan os.Signal) {
		sig := <-c
		log.Printf("Caught signal %s: shutting down.", sig)
		l.Close()
		os.Exit(2)
	}(sigc)

	for {
		fd, err := l.Accept()
		if err != nil {
			log.Fatal("accept error:", err)
		}

		var body Body
		decoder := json.NewDecoder(fd)
		if err := decoder.Decode(&body); err != nil {
			log.Fatalf("Error parsing JSON: %s", fd, err)
		}
		log.Println("Server got:", body)

		if err := handleBody(body, model); err != nil {
			log.Fatalf("Error from handleBody: %s", err)
		}
		response := "OK"

		responseJson, err := json.Marshal(response)
		if err != nil {
			log.Fatalf("Error marshaling JSON %s: %s", response, err)
		}

		_, err = fd.Write(responseJson)
		if err != nil {
			log.Fatal("Write: ", err)
		}
	}

}

func main() {
	args := mustParseFlags()

	if args.socketPath != "" {
		mustRunSocketServer(args.socketPath, &models.MemoryModel{
			NextDeviceId: 1,
			Devices:      []models.Device{},
		})
	} else {
		db := mustOpenPostgres(args.postgresCredentialsPath)
		mustRunWebServer(models.NewDbModel(db))
	}
}
