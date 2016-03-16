package main

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestHandleBodyNoDeviceUid(t *testing.T) {
	db := &Db{}
	err := handleBody(Body{}, db)
	assert.Equal(t, fmt.Errorf("Blank DeviceUid"), err)
}

func TestHandleBodyNormal(t *testing.T) {
	db := &Db{}
	err := handleBody(Body{DeviceUid: "here"}, db)
	assert.Equal(t, nil, err)
	assert.Equal(t, 1, db.numDevicesCreated)
}
