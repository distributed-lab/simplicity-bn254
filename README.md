# simplicity-bn254

An implementation of zk-friendly [bn254](https://neuromancer.sk/std/bn/bn254) curve using SimplicityHL language.

## Usage

Use `make` to execute the following commands:
- `make debug` - builds the whole project into one file removing all test functions. Executes the project in debug mode. The result is in `target` directory;
- `make test` - takes only functions within `TESTING` macros that start from `test`. Executes them one by one;