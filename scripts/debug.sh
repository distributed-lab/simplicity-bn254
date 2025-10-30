[ -d target ] || mkdir target

mcpp -P -I src main.simf -o target/global.simf
output=$(simc --debug target/global.simf)

if echo "$output" | grep -q "Result: ε"; then
    echo "$output"
    echo -e "\033[1;32mPassed!\033[0m"
else
    echo -e "\033[1;31mFailed!\033[0m"
fi