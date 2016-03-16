package main

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestHandleBodyNoDeviceUid(t *testing.T) {
	db := &Db{
		nextDeviceId: 1,
		devices:      []Device{},
	}
	err := handleBody(Body{}, db)
	assert.Equal(t, fmt.Errorf("Blank DeviceUid"), err)
}

func TestHandleBodyNewDevice(t *testing.T) {
	db := &Db{
		nextDeviceId: 2,
		devices: []Device{
			{Id: 1, Uid: "earlier"},
		},
	}
	err := handleBody(Body{DeviceUid: "new"}, db)
	assert.Equal(t, nil, err)
	assert.Equal(t, []Device{
		{Id: 1, Uid: "earlier"},
		{Id: 2, Uid: "new"},
	}, db.devices)
}

func TestHandleBodyExistingDevice(t *testing.T) {
	db := &Db{
		nextDeviceId: 2,
		devices: []Device{
			{Id: 1, Uid: "here"},
		},
	}
	err := handleBody(Body{DeviceUid: "here"}, db)
	assert.Equal(t, nil, err)
	assert.Equal(t, []Device{{Id: 1, Uid: "here"}}, db.devices)
}
