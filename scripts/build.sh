rm -rf ./target
mkdir ./target

mcpp -P -I . example-main.simf -o target/example-main.simf
simply build --entrypoint target/example-main.simf --witness ./example-witness.wit

simply run --entrypoint ./target/example-main.simf --witness ./example-witness.wit --logging debug
