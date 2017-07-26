#!/bin/bash
cd $(dirname $0)
source easy.config

arg=$1

if [[ -n $arg && $arg = "anon" ]]; then
	python3 anon.py $username
else
	python3 easy.py $username
fi