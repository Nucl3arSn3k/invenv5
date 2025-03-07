#!/bin/bash
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
cd src
crystal build --release invenv6.cr --link-flags="-L$(dirname $(pwd))"