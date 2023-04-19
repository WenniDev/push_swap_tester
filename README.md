# Push_swap Tester

This repository contains a tester for the `push_swap` project at School 42. Use the following options with the tester:

	-p: path to your push_swap program. Default: push_swap.
	-c: path to your checker program. Default: checker.
	-t: number of tests for each range of numbers. Default: 20.
	-e: max number of iteration. Default: 500.
	-o: number of elements to add to the range of numbers. Default: 50.
	-s: start value for the range of numbers. Default: 0.
	-v: enables Valgrind to detect memory leaks. Default: disabled.
## Usage
To run the tester, copy `push_swap_tester.sh` in your `push_swap` folder and compile your `push_swap` and `checker`. Then, use the following command to run the tester with default values:

```bash
./push_swap_tester.sh
```
To run the tester with custom options, use a command like the following:

```bash
./push_swap_tester.sh -r 1000 -o 100 -s 3 -i 10 -v
```
Here, the test begins at 3 and we add 100 until we reach 1000. And every time 10 lists are generated and tested with Valgrind.

To run the tester with another checker, use -c followed by the path of the checker:

```bash
./push_swap_tester.sh -c checker_linux
```
## Precision
The value in parenthesis represents the difference with an nlog(n) sorting algorithm to get an idea of its efficiency 

## Evaluation
The majority of the evaluation is based on the number of steps required to sort a list of n elements.

	For 3 elements:
	 - 3 steps maximum are needed
	
	For 5 elements:
	 - 12 steps maximum are needed

	For 100 numbers:
	 - 5 points if the number of steps is less than 700
	 - 4 points if the number of steps is less than 900
	 - 3 points if the number of steps is less than 1100
	 - 2 points if the number of steps is less than 1300
	 - 1 points if the number of steps is less than 1500

	With 500 numbers:
	 - 5 points if the number of steps is less than 5500
	 - 4 points if the number of steps is less than 7000
	 - 3 points if the number of steps is less than 8500
	 - 2 points if the number of steps is less than 10000
	 - 1 points if the number of steps is less than 11500

	According to unreliable sources, we need to get at least 84 points to pass.

The tester was created by [jopadova](https://profile.intra.42.fr/users/jopadova). It is distributed under the MIT license. See the LICENSE file for more information.
