`define STATE    [4:0]
`define TEXT     [15:0]
`define DATA     [31:0]
`define REGSIZE  [65535:0]
`define MEMSIZE  [65535:0]

`define Opcode   [15:12]
`define Dest     [11:8]
`define Source   [7:4]
`define Arg      [3:0]

`define OPadd    4'b0000
`define OPaddv   4'b0001
`define OPand    4'b0010
`define OPor     4'b0011
`define OPxor    4'b0100
`define OPshift  4'b0101
`define OPpack   4'b0110
`define OPunpack 4'b0111
`define OPli     4'b1000
`define OPmorei  4'b1001
`define OPany    4'b1010
`define OPanyv   4'b1011
`define OPneg    4'b1100
`define OPnegv   4'b1101
`define OPsys    4'b1110
`define OPextra  4'b1111

// state numbers only
`define OPst     5'b10000
`define OPld     5'b10001
`define OPjnz    5'b10010
`define OPjz     5'b10011
`define Start    5'b11111
`define Start1   5'b11110


`define EXst     4'b0001
`define EXld     4'b0010
`define EXjnz    4'b0011
`define EXjz     4'b0100



module testbench;
   reg clk;
   wire done;
   reg reset;

   processor p1(done, clk, reset);
   
   initial begin
      reset = 1;
      reset = 0;
      clk = 0;
   end

   always begin
      clk <= ~clk;
      #1;
      
      if( done ) $finish;
      
   end

endmodule // testbench


module processor(halt, clk, reset);
   output reg halt;
   input      reset, clk;
   
   reg 	      `TEXT regfile `REGSIZE;
   reg 	      `DATA mainmem `MEMSIZE;
   reg 	      `TEXT pc = 0;
   reg 	      `TEXT ir;
   reg 	      `STATE s = `Start;
   
   integer a;
   
   always @(reset) begin
      halt = 0;
      pc = 0;
      
      s = `Start;

      $display("processor reset");
      
      
      $readmemh("text.vmem", regfile);
      $readmemh("data.vmem", mainmem);
      
   end


   always @(posedge clk) begin
      $display("\t\tpc=",pc,"\ts=",s);
      
      case (s)
	`Start: begin 
	   ir <= regfile[pc];
	   s <= `Start1;
	end
	
	`Start1: begin
	   // bump pc	   
	   pc <= pc + 1;

	   case (ir `Opcode)
	     `OPextra:
	       case (ir `Arg)      // use Arg  as extended opcode
		 // store
		 `EXst: s <= `OPst;
		 
		 // load
		 `EXld: s <= `OPld;
		 
		 // jnz
		 `EXjnz: s <= `OPjnz;

		 // jz
		 `EXjz: s <= `OPjz;
		 
		 default: s <= `OPsys;
		 
	       endcase // case (ir `Arg)

	     default: s <= ir `Opcode;
	     // most instructions, state # is opcode
	   endcase // case (ir `Opcode)
	   
	end // case: `Start1


	`OPst: begin
	   $display("store");

	   s <= `Start;
	end
	
	`OPld: begin
	   $display("load");

	   s <= `Start;
	end
	
	`OPjnz: begin
	   $display("jnz");

	   s <= `Start;
	end
	
	`OPjz: begin
	   $display("jz");

	   s <= `Start;
	end
	


	////

	`OPadd: begin
	   $display("add"); 
	   	   
	   s <= `Start;
	end

	`OPaddv: begin
	   $display("addv");

	   s <= `Start;
	end

	`OPand: begin
	   $display("and");

	   s <= `Start;
	end

	`OPor: begin
	   $display("or");

	   s <= `Start;
	end

	`OPxor: begin
	   $display("xor");

	   s <= `Start;
	end

	`OPshift: begin
	   $display("shift");

	   s <= `Start;
	end

	`OPpack: begin
	   $display("pack");


	   s <= `Start;
	end

	`OPunpack: begin
	   $display("unpack");

	   s <= `Start;
	end

	`OPli: begin
	   $display("li");

	   s <= `Start;
	end

	`OPmorei: begin
	   $display("morei");

	   s <= `Start;
	end

	`OPany: begin
	   $display("any");

	   s <= `Start;
	end

	`OPanyv: begin
	   $display("anyv");

	   s <= `Start;
	end

	`OPneg: begin
	   $display("neg");

	   s <= `Start;
	end

	`OPnegv: begin
	   $display("negv");

	   s <= `Start;
	end

	`OPsys: begin
	  $display("sys");
	   
	   halt <= 1;
	end
	
	default: begin
	   halt <= 1;
	   $display("halting");
	end
	
	
	   
      endcase // case (s)
      
   end
   
   
endmodule // processor

		 

module alu(bus_out, clk, a, b, ctrl);
   output reg `DATA bus_out;
   input      clk;
   input      `DATA a;
   input      `DATA b;
   input      `TEXT ctrl;
   

   always @(posedge clk) begin

      case(ctrl `Opcode)
	`OPadd: bus_out <= a + b;	
      endcase // case (ctrl)

      
   end


endmodule // alu
