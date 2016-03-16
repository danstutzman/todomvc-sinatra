package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

type Body struct {
	DeviceUid string `json:"deviceUid"`
}

type Device struct {
	Uid string `json:"uid"`
}

type Db struct {
	numDevicesCreated int
}

func (db *Db) FindOrCreateDeviceByUid(uid string) {
	db.numDevicesCreated = 1
}

func main() {
	http.HandleFunc("/", handleRequest)
	log.Printf("Listening on :3000...")
	http.ListenAndServe(":3000", nil)
}

func handleRequest(writer http.ResponseWriter, request *http.Request) {
	var body Body
	decoder := json.NewDecoder(request.Body)
	if err := decoder.Decode(&body); err != nil {
		http.Error(writer, fmt.Sprintf("Error parsing JSON %s: %s", request.Body, err),
			http.StatusBadRequest)
		return
	}

	db := &Db{}
	if err := handleBody(body, db); err != nil {
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

func handleBody(body Body, db *Db) error {
	if body.DeviceUid == "" {
		return fmt.Errorf("Blank DeviceUid")
	}
	db.FindOrCreateDeviceByUid(body.DeviceUid)

	return nil
}
