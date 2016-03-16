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
	Id  int    `json:"id"`
	Uid string `json:"uid"`
}

type Db struct {
	devices      []Device
	nextDeviceId int
}

func (db *Db) FindOrCreateDeviceByUid(uid string) *Device {
	for _, device := range db.devices {
		log.Printf("Comparing %s to %s: %v", device.Uid, uid, device.Uid == uid)
		if device.Uid == uid {
			return &device
		}
	}

	newDevice := Device{
		Id:  db.nextDeviceId,
		Uid: uid,
	}
	db.devices = append(db.devices, newDevice)
	log.Printf("New devices: %v", db.devices)
	db.nextDeviceId += 1
	return &newDevice
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
	device := db.FindOrCreateDeviceByUid(body.DeviceUid)
	log.Println("Got device", device)

	return nil
}
