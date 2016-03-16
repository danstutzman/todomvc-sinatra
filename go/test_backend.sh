#!/bin/bash -ex
echo '{"DeviceUid": "test"}' | curl -d @- http://localhost:3000/
