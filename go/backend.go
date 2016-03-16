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
	"strings"
)

type Body struct {
	DeviceUid string `json:"deviceUid"`
}

type Device struct {
	Id  int    `json:"id"`
	Uid string `json:"uid"`
}

type Model interface {
	FindOrCreateDeviceByUid(uid string) (*Device, error)
}

type MemoryModel struct {
	devices      []Device
	nextDeviceId int
}

func (model *MemoryModel) FindOrCreateDeviceByUid(uid string) (*Device, error) {
	for _, device := range model.devices {
		log.Printf("Comparing %s to %s: %v", device.Uid, uid, device.Uid == uid)
		if device.Uid == uid {
			return &device, nil
		}
	}

	newDevice := Device{
		Id:  model.nextDeviceId,
		Uid: uid,
	}
	model.devices = append(model.devices, newDevice)
	log.Printf("New devices: %v", model.devices)
	model.nextDeviceId += 1
	return &newDevice, nil
}

type DbModel struct {
	db *sql.DB
}

func (model *DbModel) FindOrCreateDeviceByUid(uid string) (*Device, error) {
	var device Device
	findSql := `SELECT id, uid
		FROM devices
		WHERE uid = $1`
	find1Err := model.db.QueryRow(findSql, uid).Scan(&device.Id, &device.Uid)

	if find1Err == nil {
		return &device, nil
	} else if find1Err == sql.ErrNoRows {
		insertSql := `INSERT INTO devices(
			uid,
			action_to_sync_id_to_output_json,
			completed_action_to_sync_id
		) VALUES(
			$1,
			'{}',
			0
		) RETURNING uid;`
		_, insertErr := model.db.Exec(insertSql, uid)
		if insertErr == nil {
			find2Err := model.db.QueryRow(findSql, uid).Scan(&device.Id, &device.Uid)
			if find2Err == nil {
				return &device, nil
			} else {
				return nil, fmt.Errorf(
					"Error from db.QueryRow with findSql=%s uid=%s find2Err=%s",
					findSql, uid, find2Err)
			}
		} else {
			if strings.HasPrefix(insertErr.Error(),
				"pq: duplicate key value violates unique constraint") {
				find2Err := model.db.QueryRow(findSql, uid).Scan(&device.Id, &device.Uid)
				if find2Err == nil {
					return &device, nil
				} else {
					return nil, fmt.Errorf(
						`Error from db.QueryRow after constraint failure
						with findSql=%s uid=%s findSql=%s`,
						findSql, uid, find2Err)
				}
			} else {
				return nil, fmt.Errorf(
					"Error from db.Exec with insertSql=%s uid=%s insertErr=%s",
					insertSql, uid, insertErr)
			}
		}
	} else {
		return nil, fmt.Errorf(
			"Error from db.QueryRows with findSql=%s uid=%s find1Err=%s",
			findSql, uid, find1Err)
	}
}

func main() {
	type CommandLineArgs struct {
		postgresCredentialsPath *string
	}
	args := CommandLineArgs{
		postgresCredentialsPath: flag.String(
			"postgres_credentials_path", "", "JSON file with username and password"),
	}
	flag.Parse()

	if *args.postgresCredentialsPath == "" {
		log.Fatal("Missing -postgres_credentials_path")
	}
	postgresCredentialsFile, err := os.Open(*args.postgresCredentialsPath)
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
			args.postgresCredentialsPath, err)
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

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handleRequest(w, r, db)
	})
	log.Printf("Listening on :3000...")
	err = http.ListenAndServe(":3000", nil)
	if err != nil {
		log.Fatalf("Error from ListenAndServe: %s", err)
	}
}

func handleRequest(writer http.ResponseWriter, request *http.Request, db *sql.DB) {
	var body Body
	decoder := json.NewDecoder(request.Body)
	if err := decoder.Decode(&body); err != nil {
		http.Error(writer, fmt.Sprintf("Error parsing JSON %s: %s", request.Body, err),
			http.StatusBadRequest)
		return
	}

	model := &DbModel{db: db}
	if err := handleBody(body, model); err != nil {
		http.Error(writer, fmt.Sprintf("Error from handleBody: %s", err),
			http.StatusBadRequest)
		return
	}
	response := "OK"

	responseJson, err := json.Marshal(response)
	if err != nil {
		http.Error(writer, fmt.Sprintf("Error marshaling JSON %s: %s", response, err),
			http.StatusInternalServerError)
		return
	}

	writer.Header().Set("Content-Type", "application/json")
	writer.Write(responseJson)
}

func handleBody(body Body, model Model) error {
	if body.DeviceUid == "" {
		return fmt.Errorf("Blank DeviceUid")
	}
	device, err := model.FindOrCreateDeviceByUid(body.DeviceUid)
	if err != nil {
		return fmt.Errorf("Error from FindOrCreateDeviceByUid: %s", err)
	}
	log.Println("Got device", device)

	return nil
}
