// EE/CS 480 Fall 2016
// average.v - assignment 1
// Matt Ruffner


// averaging module, no high level operators
module average(s, a, b);
	input [7:0] a;
	input [7:0] b;
	output [7:0] s;

    wire [7:0] temp;
	wire c_out;

	// feed a 1 to carry in, the +1 results in rounding
	// up after 'shifting'
	ripple_carry r0(temp, c_out, a, b, 1'b1);
	
	// tack on the carry out bit as new msb 
	assign s = {c_out, temp[7:1]};
endmodule


module testbench;
	reg [7:0] a, b;
	wire [7:0] oracle, exp;
	integer passed, failed;
	
	refaverage r1(oracle, a, b);
	average a1(exp, a, b);
	
	initial begin
		a = 0; passed = 0; failed = 0;
		repeat(256) begin
			b = 0;
			repeat (256) begin
				#10
				
				if( oracle == exp )
					passed = passed+1;
				else
					failed = failed+1;
					
				b = b+1;
			end
			a = a+1;
		end
		
		$display("All cases tested; %d correct, %d failed", passed, failed);
	end		
endmodule


// reference module using + and >> operators
module refaverage(s, a, b);
	input [7:0] a, b;
	output [7:0] s;

	assign s = (a + b + 1) >> 1;
endmodule



// full adder module
module full_adder(s, c_out, a, b, c_in);
	input a, b, c_in;
	output s, c_out;
	wire t0, t1, t2;
	
	xor x1(t0, a, b);
	xor x2(s, t0, c_in);
	
	nand n1(t1, t0, c_in);
	nand n2(t2, a, b);
	nand n3(c_out, t1, t2);
endmodule


// ripple carry adder
module ripple_carry(s, c_out, a, b, c_in);
	input [7:0] a;
	input [7:0] b;
	input c_in;
	output [7:0] s;
	output c_out;
	wire c0, c1, c2, c3, c4, c5, c6;
	
	full_adder fa0(s[0], c0, a[0], b[0], c_in);
	full_adder fa1(s[1], c1, a[1], b[1], c0);
	full_adder fa2(s[2], c2, a[2], b[2], c1);
	full_adder fa3(s[3], c3, a[3], b[3], c2);
	full_adder fa4(s[4], c4, a[4], b[4], c3);
	full_adder fa5(s[5], c5, a[5], b[5], c4);
	full_adder fa6(s[6], c6, a[6], b[6], c5);
	full_adder fa7(s[7], c_out, a[7], b[7], c6);
endmodule