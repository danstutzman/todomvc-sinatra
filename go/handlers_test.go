package main

import (
	"./models"
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestHandleBodyNoDeviceUid(t *testing.T) {
	model := &models.MemoryModel{
		NextDeviceId: 1,
		Devices:      []models.Device{},
	}
	err := handleBody(Body{}, model)
	assert.Equal(t, fmt.Errorf("Blank DeviceUid"), err)
}

func TestHandleBodyNewDevice(t *testing.T) {
	model := &models.MemoryModel{
		NextDeviceId: 2,
		Devices: []models.Device{
			{Id: 1, Uid: "earlier"},
		},
	}
	err := handleBody(Body{DeviceUid: "new"}, model)
	assert.Equal(t, nil, err)
	assert.Equal(t, []models.Device{
		{Id: 1, Uid: "earlier"},
		{Id: 2, Uid: "new"},
	}, model.Devices)
}

func TestHandleBodyExistingDevice(t *testing.T) {
	model := &models.MemoryModel{
		NextDeviceId: 2,
		Devices: []models.Device{
			{Id: 1, Uid: "here"},
		},
	}
	err := handleBody(Body{DeviceUid: "here"}, model)
	assert.Equal(t, nil, err)
	assert.Equal(t, []models.Device{{Id: 1, Uid: "here"}}, model.Devices)
}
