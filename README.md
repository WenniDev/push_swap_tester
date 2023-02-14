# Push_swap Tester

This repository contains a tester for the `push_swap` project at School 42. Use the following options with the tester:

	-p: path to your push_swap program. Default: push_swap.
	-c: path to your checker program. Default: checker.
	-i: number of times your push_swap and checker programs should be run for each range of numbers. Default: 20.
	-r: range of numbers to sort. Default: 500.
	-o: number of elements to add to the range of numbers. Default: 50.
	-s: start value for the range of numbers. Default: 1.
	-v: enables Valgrind to detect memory leaks. Default: disabled.

To run the tester, clone the repository in your `push_swap` folder. Then, use the following command to run the tester with default values:

```bash
./push_swap_test.sh
```
To run the tester with custom options, use a command like the following:

```bash
./push_swap_test.sh -r 1000 -o 100 -s 3 -i 10 -v
```
The tester was created by [jopadova](https://profile.intra.42.fr/users/jopadova). It is distributed under the MIT license. See the LICENSE file for more information.
