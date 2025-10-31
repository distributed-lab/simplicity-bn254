# simplicity-bn254

An implementation of zk-friendly [bn254](https://neuromancer.sk/std/bn/bn254) curve using SimplicityHL language.

## Usage
Use `simply` compiler as [described](https://docs.simplicity-lang.org/getting-started/cli/#overview). To install
```shell
cargo install --git https://github.com/starkware-bitcoin/simply simply
```
PS. It is recommended to use [olegfomenko/simply](https://github.com/olegfomenko/simply/tree/feature/bump-simplicity-versions) fork.

Use `make` to execute the following commands:
- `make debug` - builds the whole project into one file removing all test functions. Executes the project in debug mode. The result is in `target` directory;

## Testing
- `make test all` - takes only functions within `TESTING` macros that start from `test`. Executes them one by one;
- `make test file name=NAME` - takes only functions within `TESTING` macros that start from `test` in the specified file. "NAME" can be a name of any SimplicityHL file in the root without ".simf" prefix.

