package models

import (
	"database/sql"
	"fmt"
	"log"
	"strings"
)

type Device struct {
	Id  int    `json:"id"`
	Uid string `json:"uid"`
}

type Model interface {
	FindOrCreateDeviceByUid(uid string) (*Device, error)
}

type MemoryModel struct {
	Devices      []Device
	NextDeviceId int
}

func (model *MemoryModel) FindOrCreateDeviceByUid(uid string) (*Device, error) {
	for _, device := range model.Devices {
		log.Printf("Comparing %s to %s: %v", device.Uid, uid, device.Uid == uid)
		if device.Uid == uid {
			return &device, nil
		}
	}

	newDevice := Device{
		Id:  model.NextDeviceId,
		Uid: uid,
	}
	model.Devices = append(model.Devices, newDevice)
	log.Printf("New Devices: %v", model.Devices)
	model.NextDeviceId += 1
	return &newDevice, nil
}

type DbModel struct {
	db *sql.DB
}

func NewDbModel(db *sql.DB) *DbModel {
	return &DbModel{db: db}
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
