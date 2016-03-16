package models

type Device struct {
	Id  int    `json:"id"`
	Uid string `json:"uid"`
}

type Model interface {
	FindOrCreateDeviceByUid(uid string) (*Device, error)
}
