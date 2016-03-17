package main

import (
	"./models"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

type Response struct {
	DeviceId int `json:"deviceId"`
}

func handleRequest(writer http.ResponseWriter, request *http.Request,
	model models.Model) {

	var body Body
	decoder := json.NewDecoder(request.Body)
	if err := decoder.Decode(&body); err != nil {
		http.Error(writer, fmt.Sprintf("Error parsing JSON %s: %s", request.Body, err),
			http.StatusBadRequest)
		return
	}

	response, err := handleBody(body, model)
	if err != nil {
		http.Error(writer, fmt.Sprintf("Error from handleBody: %s", err),
			http.StatusBadRequest)
		return
	}

	responseJson, err := json.Marshal(response)
	if err != nil {
		http.Error(writer, fmt.Sprintf("Error marshaling JSON %s: %s", response, err),
			http.StatusInternalServerError)
		return
	}

	writer.Header().Set("Content-Type", "application/json")
	writer.Write(responseJson)
}

func handleBody(body Body, model models.Model) (*Response, error) {
	if body.DeviceUid == "" {
		return nil, fmt.Errorf("Blank DeviceUid")
	}
	device, err := model.FindOrCreateDeviceByUid(body.DeviceUid)
	if err != nil {
		return nil, fmt.Errorf("Error from FindOrCreateDeviceByUid: %s", err)
	}
	log.Println("Got device", device)

	response := Response{
		DeviceId: device.Id,
	}

	return &response, nil
}
