rm -rf ./target
mkdir ./target

mcpp -P -I src main.simf -o target/main.simf
simply build --entrypoint target/main.simf
