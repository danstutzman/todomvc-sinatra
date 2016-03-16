package main

import (
	"./models"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func handleRequest(writer http.ResponseWriter, request *http.Request, db *sql.DB) {
	var body Body
	decoder := json.NewDecoder(request.Body)
	if err := decoder.Decode(&body); err != nil {
		http.Error(writer, fmt.Sprintf("Error parsing JSON %s: %s", request.Body, err),
			http.StatusBadRequest)
		return
	}

	model := models.NewDbModel(db)
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

func handleBody(body Body, model models.Model) error {
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
