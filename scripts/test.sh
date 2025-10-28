#!/bin/bash

# Use system temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse command line arguments
DEBUG_MODE=false
for arg in "$@"; do
    case $arg in
        --debug)
            DEBUG_MODE=true
            shift
            ;;
    esac
done

# Arrays to store test results
failed_tests=()
error_messages=()

# Find all *.simf files in src directory
simf_files=$(find . -path "./test" -prune -o -name "*.simf" -print)

# Counter for tests
total_tests=0
passed_tests=0

# Process each file
for file in $simf_files; do
    # Extract test functions from the file
    test_functions=$(grep -o "fn test_[a-zA-Z0-9_]*" "$file" | sed 's/fn //')
    
    # Process each test function
    for test_func in $test_functions; do
        ((total_tests++))
        test_name=$(basename "$file" .simf)::${test_func}
        
        # Print test name with simple format
        printf "%s ... " "$test_name"
        
        # Create unique filenames for this test
        base_name=$(basename "$file" .simf)
        temp_file="$TEMP_DIR/${base_name}_${test_func}_temp.simf"
        preprocessed_file="$TEMP_DIR/${base_name}_${test_func}_preprocessed.simf"
        
        # Replace the test function with main
        sed "s/fn $test_func/fn main/" "$file" > "$temp_file"
        
        # If debug mode is enabled, wrap custom function calls in dbg!()
        if [ "$DEBUG_MODE" = true ]; then
            # Create a temporary file for the debug modifications
            debug_temp="$TEMP_DIR/${base_name}_${test_func}_debug_temp.simf"
            
            # First, create a temporary file with function declarations marked
            # This helps us avoid matching function declarations
            sed 's/^fn /__FN__/g' "$temp_file" > "$debug_temp"
               
            # Now wrap remaining function calls in dbg!()
            sed -E 's/(let [^:]*: [^=]*= )([a-zA-Z0-9_]+)\(([^;]*)\);/\1dbg!(\2(\3));/g' "$debug_temp" > "$temp_file"
            
            # Restore function declarations
            sed 's/^__FN__/fn /g' "$temp_file" > "$debug_temp"
            mv "$debug_temp" "$temp_file"
        fi
        
        # Check if witness and param files exist for this test
        witness_file=""
        param_file=""
        
        if [ -f "src/${base_name}.wit" ]; then
            witness_file="--witness src/${base_name}.wit"
        fi
        
        if [ -f "src/${base_name}.param" ]; then
            param_file="--param src/${base_name}.param"
        fi
        
        # Preprocess the file with mcpp, including src directory for dependencies
        mcpp -P -DTESTING -I . "$temp_file" > "$preprocessed_file" 
        mcpp_exit=$?
                
        if [ $mcpp_exit -ne 0 ]; then
            printf "${RED}err${NC}\n"
            failed_tests+=("$test_name")
            error_messages+=("${RED}$test_name${NC} (mcpp failed)")
            continue
        fi
        
        # Run the test with the preprocessed file and any parameters
        output=$(simfony debug "$preprocessed_file" $witness_file $param_file 2>&1)
        exit_code=$?
        
        # Print result
        if [ $exit_code -eq 0 ]; then
            printf "${GREEN}ok${NC}\n"
            ((passed_tests++))
        else
            printf "${RED}err${NC}\n"
            failed_tests+=("$test_name")
            error_messages+=("${RED}$test_name${NC}:\n$output")
        fi
    done
done

# Calculate failed tests
failed_tests_count=$((total_tests - passed_tests))

# Print summary in the requested format
if [ $failed_tests_count -gt 0 ]; then
    printf "\ntest result: ${RED}failed${NC}. %d passed; %d failed\n" $passed_tests $failed_tests_count
    
    echo -e "\n"
    for error in "${error_messages[@]}"; do
        echo -e "$error\n"
    done
    exit 1
else
    printf "\ntest result: ${GREEN}success${NC}. %d passed; 0 failed\n" $passed_tests
    exit 0
fi