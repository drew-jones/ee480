`define STATE    [4:0]
`define TEXT     [15:0]
`define DATA     [31:0]
`define REGSIZE  [15:0]
`define CODESIZE [65535:0]
`define MEMSIZE  [65535:0]

// field locations within instruction
`define Opcode   [15:12]
`define Dest     [11:8]
`define Src      [7:4]
`define Arg      [3:0]
`define Imm      [15:0]

// opcode and state number
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

// state numbers only for extra opcodes
`define OPst     5'b10000
`define OPld     5'b10001
`define OPjnz    5'b10010
`define OPjz     5'b10011
`define OPnop    5'b10100
`define Start    5'b11111
`define Start1   5'b11110

`define OPalu    5'b10101

// arg field values for extra opcodes
`define EXst     4'b0001
`define EXld     4'b0010
`define EXjnz    4'b0011
`define EXjz     4'b0100
`define EXnop    4'b1111

// field locations for vector ops
`define V1       [7:0]
`define V2       [15:8]
`define V3       [23:16]
`define V4       [31:24]


// mask for cutting carry chains
`define MASKaddv 32'h80808080



module testbench;
   reg clk;
   wire done;
   reg reset;

   processor p1(done, clk, reset);
   
   initial begin
      reset = 1;
      reset = 0;
      clk = 1;
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
   
   reg 	      `TEXT codemem `CODESIZE;
   reg 	      `DATA mainmem `MEMSIZE;
   reg   signed     `DATA regfile `REGSIZE;
   
   reg 	      `TEXT pc = 0;
   reg 	      `TEXT ir;
   reg 	      `STATE s = `Start;
   
   wire signed `DATA alu_out;
   reg signed `DATA alu_a, alu_b;
 
 

   alu a(alu_out, clk, alu_a, alu_b, ir `Opcode);
   
   
   always @(reset) begin
      halt = 0;
      pc = 0;
      
      s = `Start;

      $display("processor reset");
      
      $readmemh("text.vmem", codemem);
      $readmemh("data.vmem", mainmem);
      $readmemh("reg.vmem", regfile);
      
   end


   always @(posedge clk) begin
      
      case (s)
	`Start: begin 
	   ir <= codemem[pc];
	   s <= `Start1;

	   $display("$u0: %d\n$u1: %d\n$u2: %d\n$u3: %d", regfile[6],regfile[7],regfile[8],regfile[9]);
	   //$display("\n$u1: ", regfile[7],"\n$u2: ", regfile[8],"\n$u3: ", regfile[9],"\n$u4: ", regfile[10],"\n$u5: ", regfile[11],"\n$u6: ", regfile[12],"\n$u7: ", regfile[13], "\n$u8: ", regfile[14], "\n$u9: ", regfile[15]);

	end
	
	`Start1: begin
	   // bump pc	   
	   pc <= pc + 1;
		
	   case (ir `Opcode)
	     `OPextra:
	       case (ir `Arg)      // use Arg  as extended opcode
		 `EXst: s <= `OPst;		 // store
		 `EXld: s <= `OPld;		 // load
		 `EXjnz: s <= `OPjnz;		 // jnz
		 `EXjz: s <= `OPjz;		 // jz
		 default: s <= `OPnop;
		 
	       endcase // case (ir `Arg)

	     default: s <= ir `Opcode;	     // rest of instructions
	   endcase // case (ir `Opcode)
	end // case: `Start1

	`OPnop: begin
	   $display("nop");
	   s <= `Start;
	end
	
	`OPst: begin
	   $display("store");

	   mainmem[regfile[ir `Src]] = regfile[ir `Dest];
	   
	   s <= `Start;
	end

	`OPld: begin
	   $display("load");

	   regfile[ir `Dest] = mainmem[regfile[ir `Src]];
	   
	   s <= `Start;
	end

	`OPjnz: begin
	   $display("jnz");

	   pc = (regfile[ir `Dest] ? regfile[ir `Src] : pc);
	   
	   s <= `Start;
	end

	`OPjz: begin
	   $display("jz", regfile[ir `Dest], " ", regfile[ir `Src]);
	   
	   pc = (regfile[ir `Dest] ? pc : regfile[ir `Src]);
	   	   
	   s <= `Start;
	end

	// ALU DONE
	`OPalu: begin
		
	   regfile[ir `Dest] = alu_out;
	   
	   $display("alu_out: ", alu_out);
	   
	   
	   s <= `Start;
	end

	
	`OPadd: begin
	   $display("add ", ir `Dest, " ", regfile[ir `Src], " ", regfile[ir `Arg]); 
	   
	   alu_a = regfile[ir `Src];
	   alu_b = regfile[ir `Arg];

	   s <= `OPalu;
	end 

	`OPaddv: begin
	   $display("addv ", ir `Dest, " ", regfile[ir `Src], " ", regfile[ir `Arg]); 

	   alu_a = regfile[ir `Src];
	   alu_b = regfile[ir `Arg];

	   s <= `OPalu;
	end

	`OPand: begin
	   $display("and ", ir `Dest, " ", regfile[ir `Src], " ", regfile[ir `Arg]); 

	   alu_a = regfile[ir `Src];
	   alu_b = regfile[ir `Arg];
	   	   	   
	   s <= `OPalu;
	end

	`OPor: begin
	   $display("or ", regfile[ir `Dest], " ", regfile[ir `Src], " ", regfile[ir `Arg]); 

	   alu_a = regfile[ir `Src];
	   alu_b = regfile[ir `Arg];
	   
	   s <= `OPalu;
	end

	`OPxor: begin
	   $display("xor ", regfile[ir `Dest], " ", regfile[ir `Src], " ", regfile[ir `Arg]); 

	   alu_a = regfile[ir `Src];
	   alu_b = regfile[ir `Arg];
	   
	   s <= `OPalu;
	end

	`OPshift: begin
	   $display("shift ", regfile[ir `Dest], " ", regfile[ir `Src], " ", regfile[ir `Arg]); 

	   alu_a = regfile[ir `Src];
	   alu_b = regfile[ir `Arg];
	   
	   s <= `OPalu;
	end

	`OPpack: begin
	   $display("pack");

	   regfile[ir `Dest] `V1 = ((ir `Arg & 4'b0001) ? regfile[ir `Src] `V1 : regfile[ir `Dest] `V1);
	   regfile[ir `Dest] `V2 = ((ir `Arg & 4'b0010) ? regfile[ir `Src] `V2 : regfile[ir `Dest] `V2);
	   regfile[ir `Dest] `V3 = ((ir `Arg & 4'b0100) ? regfile[ir `Src] `V3 : regfile[ir `Dest] `V3);
	   regfile[ir `Dest] `V4 = ((ir `Arg & 4'b1000) ? regfile[ir `Src] `V4 : regfile[ir `Dest] `V4);
	   
	   s <= `Start;
	end

	`OPunpack: begin
	   $display("unpack");

	   regfile[ir `Dest] = ((ir `Arg & 4'b0001) ? regfile[ir `Src] `V1 : 0) +
			       ((ir `Arg & 4'b0010) ? regfile[ir `Src] `V2 : 0) +
			       ((ir `Arg & 4'b0100) ? regfile[ir `Src] `V3 : 0) +
			       ((ir `Arg & 4'b1000) ? regfile[ir `Src] `V4 : 0);
	   
	   s <= `Start;
	end

	`OPli: begin
	   $display("li");

	   regfile[ir `Dest] = ((ir `Imm & 8'h80) ? 32'hffffff00 : 0) | (ir `Imm & 8'hff);

	   s <= `Start;
	end

	`OPmorei: begin
	   $display("morei");

	   regfile[ir `Dest] = (regfile[ir `Dest] << 8) | (ir `Imm & 8'hff);

	   s <= `Start;
	end

	`OPany: begin
	   $display("any ", regfile[ir `Dest], " ", regfile[ir `Src]);
	   
	   alu_a = regfile[ir `Src];
	   alu_b = 0;
	   
	   s <= `OPalu;
	end

	`OPanyv: begin
	   $display("anyv ", regfile[ir `Dest], " ", regfile[ir `Src]);
	   
	   alu_a = regfile[ir `Src];
	   alu_b = 0;
	   
	   s <= `OPalu;
	end

	`OPneg: begin
	   $display("neg ", regfile[ir `Dest], " ", regfile[ir `Src]);
	   
	   alu_a = regfile[ir `Src];
	   alu_b = 0;
	   
	   s <= `OPalu;
	end

	`OPnegv: begin
	   $display("negv ", regfile[ir `Dest], " ", regfile[ir `Src]);
	   
	   alu_a = regfile[ir `Src];
	   alu_b = 0;
	   	   
	   s <= `OPalu;
	end

	`OPsys: begin
	  $display("sys");
	   
	   halt <= 1;
	end
	
	default: halt <= 1;
	   
      endcase // case (s)
      
   end

endmodule // processor

		 

module alu(bus_out, clk, a, b, ctrl);
   output reg `DATA bus_out;
   input      clk, en;
   input  signed    `DATA a, b;
   input 	  [3:0] ctrl;
   

   always @(posedge clk) begin
      
      case(ctrl)
	`OPadd: bus_out <= a + b;
	`OPaddv:   bus_out <= ((a & ~(`MASKaddv)) + (b & ~(`MASKaddv))) ^ ((a & `MASKaddv) ^ (b & `MASKaddv));
	`OPand: bus_out <= a & b; 
	`OPany:    bus_out <= (a ? 1 : 0);
	`OPanyv: begin
	   bus_out[0]  <= (a & 32'h000000FF ? 1 : 0);
	   bus_out[8]  <= (a & 32'h0000FF00 ? 1 : 0);
	   bus_out[16] <= (a & 32'h00FF0000 ? 1 : 0);
	   bus_out[24] <= (a & 32'hFF000000 ? 1 : 0);
	end
	`OPor:     bus_out <= a | b;
	`OPxor:    bus_out <= a ^ b;
	`OPneg:    bus_out <= -a;
	`OPnegv: begin
	   bus_out `V1 <= -(a `V1);
	   bus_out `V2 <= -(a `V2);
	   bus_out `V3 <= -(a `V3);
	   bus_out `V4 <= -(a `V4);
	end
	`OPshift: begin
	   bus_out <= ( (b < 0) ? (a >> -b) : (a << b) );
	end
      endcase // case (ctrl)

	end
endmodule // alu
