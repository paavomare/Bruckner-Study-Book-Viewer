#!/bin/bash
docker run \
  -it \
  --rm \
  --name studienbuch \
  -p 127.0.0.1:4444:4444 \
  -p 127.0.0.1:8080:8080 \
  bruckner-studienbuch
