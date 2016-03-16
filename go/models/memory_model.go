package models

type MemoryModel struct {
	Devices      []Device
	NextDeviceId int
}

func (model *MemoryModel) FindOrCreateDeviceByUid(uid string) (*Device, error) {
	for _, device := range model.Devices {
		if device.Uid == uid {
			return &device, nil
		}
	}

	newDevice := Device{
		Id:  model.NextDeviceId,
		Uid: uid,
	}
	model.Devices = append(model.Devices, newDevice)
	model.NextDeviceId += 1
	return &newDevice, nil
}
