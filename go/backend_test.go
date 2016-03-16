package main

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestHandleBodyNoDeviceUid(t *testing.T) {
	model := &MemoryModel{
		nextDeviceId: 1,
		devices:      []Device{},
	}
	err := handleBody(Body{}, model)
	assert.Equal(t, fmt.Errorf("Blank DeviceUid"), err)
}

func TestHandleBodyNewDevice(t *testing.T) {
	model := &MemoryModel{
		nextDeviceId: 2,
		devices: []Device{
			{Id: 1, Uid: "earlier"},
		},
	}
	err := handleBody(Body{DeviceUid: "new"}, model)
	assert.Equal(t, nil, err)
	assert.Equal(t, []Device{
		{Id: 1, Uid: "earlier"},
		{Id: 2, Uid: "new"},
	}, model.devices)
}

func TestHandleBodyExistingDevice(t *testing.T) {
	model := &MemoryModel{
		nextDeviceId: 2,
		devices: []Device{
			{Id: 1, Uid: "here"},
		},
	}
	err := handleBody(Body{DeviceUid: "here"}, model)
	assert.Equal(t, nil, err)
	assert.Equal(t, []Device{{Id: 1, Uid: "here"}}, model.devices)
}
