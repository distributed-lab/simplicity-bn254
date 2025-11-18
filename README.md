# simplicity-bn254

An implementation of zk-friendly [bn254](https://neuromancer.sk/std/bn/bn254) curve using SimplicityHL language.

Includes:
- bn254 curve definition;
- Fr, Fp field operations with Fp2, Fp6, Fp12 extensions. Fr and Fp fields have been implemented according to [gnark-crypto](https://github.com/Consensys/gnark-crypto);
- G1, G2 group operations on bn254. All points are represented in Jacobian coordinates, except of the input points where we leverage Affine coordinates;
- Pairing function which leverages Ate Optimal according to [High-Speed Software Implementation of the Optimal Ate Pairing over Barreto–Naehrig Curves](https://eprint.iacr.org/2010/354.pdf).

## Usage
Use `simply` CLI to compile as [recommended](https://docs.simplicity-lang.org/getting-started/cli/#overview). To install execute:
```shell
cargo install --git https://github.com/starkware-bitcoin/simply simply
```

You may also need to install `mcpp`:
```shell
brew install mcpp
```

Build scripts leverage `mcpp` compiler to handle `#include` and `#define` derectives. 
In addition, build scripts may seem overly complex due to the specifics of working with tests.

## Testing
- `make test all` - takes only functions within `TESTING` macros that start from `test`. Executes them one by one;
- `make test file name=NAME` - takes only functions within `TESTING` macros that start from `test` in the specified file. "NAME" can be a name of any SimplicityHL file in the root without ".simf" prefix.

## Computing 
In order to calculate a pairing function, a product of `miller_loop` function which is an `Fp12` element should be inversed due to the program size saving reasons. To compute an inverse of `Fp12` use:

```shell
make compute inverse input="(((( Fp12 ... ))))"
```

where `(((( Fp12 ... ))))` is a tuple of `u64` which represents `Fp12`. The tuple is in big endian format.

It will produce an inversed well-formatted `Fp12` element that could be used for pasting it directly into the simplicity test. Of course, correctness of inverse will be checked in the pairing method.

Program usage example is as follows:

```shell
make compute inverse input="((((530129493658355355, 17916075167625392463, 4711180280911663921, 9157818692069098461), (3387967096803404700, 6372212300687130836, 15841176653016408864, 8530925170115513574)), ((2175059045283883320, 14441765966173005345, 2559014677827731724, 9675513106660359019), (1571331153009990990, 10377968323282915600, 15527864510028576156, 7386932454693768864)), ((1934311164563911892, 3622929770691282998, 11407318075946808479, 6637487534425717197), (2032803369285045680, 5759842034369281748, 8485599086578999549, 11853220111967095579))), (((1122076244777157528, 3105942951096645210, 17666666844319614831, 16526787952216643540), (497404890884837529, 2422982850023522255, 16545670813400739560, 16672643706005881302)), ((127816500615424867, 15932182823346770939, 12425593278309521881, 2158585162697425794), (265464468622919773, 16717892296610380206, 14638758304173043475, 437648322812970388)), ((3231849989090383587, 1740718609317009777, 12136977394705413371, 9431574855946654112), (2834119598781558106, 4185734422523183713, 4790605607912014296, 101773244026114257))))"
```

## Benchmark
On 14-core Apple M3 Max, 36 GB RAM single pairing computation takes ~210 seconds and requires ~12 - 17 GB of real RAM.