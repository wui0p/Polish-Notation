# 2025 FPGA Final Exercise (Polish Notation)

* Vivado 2024.2

A functioning Verilog code for notations that only simulates the waveform.

## INTRODUCTION
Polish Notation in the data structure is a method of expressing mathematical, logical, and algebraic equations universally. This notation is used by the compiler to evaluate mathematical equations based on their order of operations. When parsing mathematical expressions, three types of notations are commonly used: Infix Notation, Prefix Notation, and Postfix Notation.

## RULES
1. All output signals should be reset after the “rst_n” signal is asserted. 
2. The “out_valid” signal should not be high when the “in_valid” signal is high. 
3. The “out” signal should be 0 when your “out_valid” signal is pulled down. 
4. Each of the pattern execution latencies is limited to 1000 cycles. 
5. When the "mode" signal is "0,1", the duration of the "out_valid" signal should be one-third of the duration of the "in_valid" signal. Otherwise, the "out_valid" signal can only be high for one cycle. 
6. While the "out_valid" signal is high, TESTBED will check if your "out" signal matches the expected value. If it matches, nothing will happen until you pass the pattern. If it does not match, an error message will tell you the expected output value, and at the end of the message, it will tell you the total number of errors. Your grade will depend on this.
7. The “in” signal is given unsigned, but the “out” signal is a signed number because the answer may be negative. 
8. The next round of the game will come in 2~4 negative edges of clk. 
9. If the “mode” signal is 0 or 1, the “in_valid” signal will randomly rise up for a continuous period of 6, 9, or 12 cycles. 
10. If the “mode” signal is 2 or 3, the “in_valid” signal will randomly rise up for a continuous period of 5, 7, or 9 cycles.

<br>
Due to copyright claims, the midterm PDF can't be uploaded!
