#!/bin/bash

rm -rf ./tmp
mkdir ./tmp

rm -rf ./target
mkdir ./target

# Find all *.simf files in src directory
simf_files=$(find . -path "./test" -prune -o -name "*.simf" -print)

# Process each file
for file in $simf_files; do
    base_name=$(basename "$file" .simf)

    # save tests for this file
    unifdef -UTESTING -c "$file" > ./tmp/${base_name}_tests.simf

    # dave defines
    grep -E '^[[:space:]]*#define[[:space:]]+' "$file" > ./tmp/${base_name}_defines.simf

    # build without tests but with includes
    mcpp -P -I . "$file" > ./tmp/${base_name}_compiled0.simf 

    # concat with tests and defines
    cat ./tmp/${base_name}_defines.simf ./tmp/${base_name}_compiled0.simf ./tmp/${base_name}_tests.simf > ./tmp/${base_name}_compiled1.simf

    mkdir ./target/${base_name}


    # apply define for tests
    mcpp -P -I . -DTESTING ./tmp/${base_name}_compiled1.simf > ./target/${base_name}/${base_name}.simf 

    simply test --logging info --entrypoint ./target/${base_name}/${base_name}.simf
done

rm -rf ./tmp


