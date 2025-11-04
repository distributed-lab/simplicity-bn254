#!/bin/bash

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

rm -rf ./target
mkdir ./target

base_name=$1
file=${base_name}.simf

# save tests for this file
unifdef -UTESTING -c "$file" > ${TEMP_DIR}/${base_name}_tests.simf

# dave defines
grep -E '^[[:space:]]*#define[[:space:]]+' "$file" > ${TEMP_DIR}/${base_name}_defines.simf

# build without tests but with includes
mcpp -P -I . "$file" > ${TEMP_DIR}/${base_name}_compiled0.simf 

# concat with tests and defines
cat ${TEMP_DIR}/${base_name}_defines.simf ${TEMP_DIR}/${base_name}_compiled0.simf ${TEMP_DIR}/${base_name}_tests.simf > ${TEMP_DIR}/${base_name}_compiled1.simf

mkdir ./target/${base_name}

# apply define for tests
mcpp -P -I . -DTESTING ${TEMP_DIR}/${base_name}_compiled1.simf > ./target/${base_name}/${base_name}.simf 

simply test --logging info --entrypoint ./target/${base_name}/${base_name}.simf


rm -rf ${TEMP_DIR}


