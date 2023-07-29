#!/bin/bash

python3 watchapi/pod.py

python3 watchapi/deploy.py

python3 watchapi/configmap.py

python3 watchapi/service.py
