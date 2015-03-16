#!/bin/bash

directory="/var/lib/mysql"
service mysql start
/opt/sonar/bin/linux-x86-64/sonar.sh console
