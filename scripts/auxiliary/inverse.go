package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"

	"github.com/consensys/gnark-crypto/ecc/bn254"
	"github.com/consensys/gnark-crypto/ecc/bn254/fp"
)

func fp2(a, b [4]uint64) bn254.E2 {
	return bn254.E2{A0: a, A1: b}
}

func fp6(a0a, a0b, a1a, a1b, a2a, a2b [4]uint64) bn254.E6 {
	return bn254.E6{
		B0: fp2(a0a, a0b),
		B1: fp2(a1a, a1b),
		B2: fp2(a2a, a2b),
	}
}

func fp12(
	a0a, a0b, a1a, a1b, a2a, a2b,
	b0a, b0b, b1a, b1b, b2a, b2b [4]uint64,
) bn254.E12 {
	return bn254.E12{
		C0: fp6(a0a, a0b, a1a, a1b, a2a, a2b),
		C1: fp6(b0a, b0b, b1a, b1b, b2a, b2b),
	}
}

func parseU64s(input string) ([]uint64, error) {
	re := regexp.MustCompile(`[0-9]+`)
	nums := re.FindAllString(input, -1)
	out := make([]uint64, 0, len(nums))
	for _, n := range nums {
		v, err := strconv.ParseUint(n, 10, 64)
		if err != nil {
			return nil, err
		}
		out = append(out, v)
	}
	return out, nil
}

func tabs(level int) string {
	return strings.Repeat("    ", level)
}

func printFp(f *fp.Element, level int) {
	fmt.Printf("%s(%d, %d, %d, %d)", tabs(level), f[3], f[2], f[1], f[0])
}

func printE2(e *bn254.E2, level int) {
	fmt.Printf("%s(\n", tabs(level))
	printFp(&e.A0, level+1)
	fmt.Println(",")
	printFp(&e.A1, level+1)
	fmt.Printf("\n%s)", tabs(level))
}

func printE6(e *bn254.E6, level int) {
	fmt.Printf("%s(\n", tabs(level))
	printE2(&e.B0, level+1)
	fmt.Println(",")
	printE2(&e.B1, level+1)
	fmt.Println(",")
	printE2(&e.B2, level+1)
	fmt.Printf("\n%s)", tabs(level))
}

func printE12(e *bn254.E12, level int) {
	fmt.Printf("%s(\n", tabs(level))
	printE6(&e.C0, level+1)
	fmt.Println(",")
	printE6(&e.C1, level+1)
	fmt.Printf("\n%s)\n", tabs(level))
}


func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Usage: go run main.go \"((((... your FP12 limbs ...))))\"")
		os.Exit(1)
	}

	raw := os.Args[1]
	raw = strings.TrimSpace(raw)

	nums, err := parseU64s(raw)
	if err != nil {
		fmt.Fprintf(os.Stderr, "parse error: %v\n", err)
		os.Exit(1)
	}

	// Build limb arrays
	idx := 0
	next := func() [4]uint64 {
		var arr [4]uint64
		copy(arr[:], nums[idx:idx+4])
		idx += 4
		return arr
	}

	a := fp12(
		next(), next(), next(), next(), next(), next(),
		next(), next(), next(), next(), next(), next(),
	)

	var inv bn254.E12
	inv.Inverse(&a)

	printE12(&inv, 0)
}
