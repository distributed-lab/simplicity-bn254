mkdir test
mcpp -P -I src main.simf -o test/global.simf
output=$(simfony debug test/global.simf)

if echo "$output" | grep -q "Result: ε"; then
    echo "$output"
    echo -e "\033[1;32mPassed!\033[0m"
else
    echo -e "\033[1;31mFailed!\033[0m"
fi