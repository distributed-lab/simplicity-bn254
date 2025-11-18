# simplicity-bn254

An implementation of zk-friendly [bn254](https://neuromancer.sk/std/bn/bn254) curve using SimplicityHL language.

Includes:
- Fr, Fp field operations as well as the Fp2, Fp6, and Fp12 extensions. The Fr and Fp fields have been implemented according to [gnark-crypto](https://github.com/Consensys/gnark-crypto);
- bn254 curve definition and overations over groups: G1 (over Fp), G2 (twisted group over Fp2). We represent all points in Jacobian coordinates, except of the inputs, where we use Affine coordinates;
- Pairing function which leverages Ate Optimal according to [High-Speed Software Implementation of the Optimal Ate Pairing over Barreto–Naehrig Curves](https://eprint.iacr.org/2010/354.pdf).

## Requirements
Use `simply` CLI to compile as [recommended](https://docs.simplicity-lang.org/getting-started/cli/#overview). To install execute:
```shell
cargo install --git https://github.com/starkware-bitcoin/simply simply
```

You may also need to install `mcpp`:
```shell
brew install mcpp
```

You can find the build scripts in [scripts](./scripts/) package which are essentially a bash scripts that execute `mcpp` and `simply` utilites.
We use `mcpp` compiler to handle `#include` and `#define` derectives. 
In conclusion, build scripts may seem overly complicated due to the specifics of working with tests.

## Usage 

All tests are surrounded with `#ifdef TESTING ... #endif` block which enables easy test functions management. 
Any tests function name begins with `test_` prefix which enables the usage of `simply test` CLI. 

We also use `mcpp` to handle imports by using `#include "FILE_NAME"` directives. 
Also, each file content is surrounded with `#ifndef FILE_NAME #define FILE_NAME .. #endif`, which allows us to manage dobule imports easily.

All tests data are generated using [gnark-crypto](https://github.com/Consensys/gnark-crypto) which also was a refference implementation of fields.

### Running tests
- `make test all` - takes only functions within `TESTING` macros that start from `test`. Executes them one by one;
- `make test file name=NAME` - takes only functions within `TESTING` macros that start from `test` in the specified file. "NAME" can be a name of any SimplicityHL file in the root without ".simf" prefix.

### Executing pairing
To execute the pairing you can run the `test_pair()` in the `pairing.simf` file. Note that before executing the pairing iteself you should evaluate some precompute data. In order to calculate a pairing function, a product of `miller_loop` function which is an `Fp12` element should be inversed. Due to the program size saving reasons we allow providing the inverse in the witness rather then evaluating it in the script. To compute an inverse of `Fp12` we provide a CLI wich can be used as follows:

```shell
make compute inverse input="(((( Fp12 element ... ))))"
```

where `(((( Fp12 element ... ))))` is a tuple of `u64` which represents `Fp12`. The tuple should be provided in the big endian format.

It will produce an inversed well-formatted `Fp12` element that could be used for pasting it directly into the simplicity test. Of course, correctness of inverse will be checked in the pairing method.

Program usage example is as follows:

```shell
make compute inverse input="((((530129493658355355, 17916075167625392463, 4711180280911663921, 9157818692069098461), (3387967096803404700, 6372212300687130836, 15841176653016408864, 8530925170115513574)), ((2175059045283883320, 14441765966173005345, 2559014677827731724, 9675513106660359019), (1571331153009990990, 10377968323282915600, 15527864510028576156, 7386932454693768864)), ((1934311164563911892, 3622929770691282998, 11407318075946808479, 6637487534425717197), (2032803369285045680, 5759842034369281748, 8485599086578999549, 11853220111967095579))), (((1122076244777157528, 3105942951096645210, 17666666844319614831, 16526787952216643540), (497404890884837529, 2422982850023522255, 16545670813400739560, 16672643706005881302)), ((127816500615424867, 15932182823346770939, 12425593278309521881, 2158585162697425794), (265464468622919773, 16717892296610380206, 14638758304173043475, 437648322812970388)), ((3231849989090383587, 1740718609317009777, 12136977394705413371, 9431574855946654112), (2834119598781558106, 4185734422523183713, 4790605607912014296, 101773244026114257))))"
```

Result:

```shell
Running inverse computation...
(
    (
        (
            (2828460888351278467, 14834261870058777367, 11293700184799194766, 11668029572969673464),
            (1711835212597158234, 2756389094337068615, 2446727912687872856, 17614024327617929134)
        ),
        (
            (2522424038255186243, 10033299119548170556, 8233872818810130082, 5624381326061043731),
            (366836457390496470, 7906693120207876852, 12166728836186671977, 74751811623734194)
        ),
        (
            (2333631879515014971, 4407403482387750847, 11536034526258033839, 15208493760900620057),
            (1945460521170434354, 14826679219419169954, 6210312030429614948, 9574524258264394629)
        )
    ),
    (
        (
            (2824312882684893510, 2409214175280725708, 3612131076559650746, 16135536113847914421),
            (1738285377884378507, 8064652313320350605, 8139379318777143930, 16265016582627776201)
        ),
        (
            (1984724343480008408, 1510333163104583320, 335701698988478733, 1367685943322594670),
            (548916569652353325, 15171954526685034159, 3400257456924843497, 535339894640118040)
        ),
        (
            (2394228146608246664, 15044429557255325300, 4611496300541673917, 17203328851852031879),
            (735427541795017565, 6210152514628237064, 13851820957763435190, 12829596027008005357)
        )
    )
)
```

So, in general to execute pariring test for your own data you should:
1. Insert your input points in the Affine coordinates in `test_miller()` function. Run it and receive the reslut of Miller loop execution;
2. Evaluate the inverse element to be used in the pairing's final exponention using our CLI;
3. Insert your input points in the Affine coordinates in `test_pair()` function in a couple with Miller loop result inverse and evaluate the pairing.

## Benchmark
On 14-core Apple M3 Max/36RAM the compilation and evaluation of script with single pairing takes ~210 seconds and consumes ~12 - 17 GB of real RAM.