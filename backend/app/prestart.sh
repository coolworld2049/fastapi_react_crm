#! /usr/bin/env bash

# Let the DB start
python backend_pre_start.py

# Create initial data in DB
python initial_data.py
