#!/bin/bash
(
  cd tomcat && bin/startup.sh
)
cd app && .venv/bin/python server.py "$HOME/applicationData/data_src"
