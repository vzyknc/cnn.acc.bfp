// 3-operand adder simulation top module

`timescale 1ns/1ps

module top;
  localparam EXP = 8;
  localparam MAN = 23;

  reg clk;

  reg [EXP+MAN:0] A_i;
  reg [EXP+MAN:0] B_i;
  reg [EXP+MAN:0] C_i;
  reg [EXP+MAN:0] D_o;
  reg             A_sign;
  reg             B_sign;
  reg             C_sign;



  localparam a_width    = MAN+1+2; // width of sum after rounding (_sum)
  // addr_width should be less than EXPONENT
  localparam addr_width = log(a_width);
  `include "misc.v"
  `include "DW_lzd_function.inc"
  reg [addr_width-1:0] num_zeros;

  initial begin
    clk = 1'b1;
    A_i = 32'h0;
    B_i = 32'h0;
    C_i = 32'h0;
    #10
    A_i = 32'h423c0000; //47 32'h3edd039c; //0.432688  32'h3e71d0a6; // 0.236147
    B_i = 32'h42380000; //46 32'h3fa6a865; //1.302014  32'h3f2f9e2c; // 0.686007
    C_i = 32'h42840000; //66 32'h3efad8c4; //0.489935  32'hbc81abaa; //-0.015829
    //Ai  = {1'b1,A_i[MAN-1:0],2'b00};
    //Bi  = {1'b1,B_i[MAN-1:0],2'b00};
    //Ci  = {1'b1,C_i[MAN-1:0],2'b00};

    #100
    $display("[%t] : A_i: %h, B_i: %h C_i: %h\n", $realtime, A_i, B_i, C_i);
    $display("[%t] : A_sign:%h, B_sign:%h, C_sign:%h\n", $realtime, A_sign, B_sign, C_sign);
    $display("[%t] : D_o:%h\n", $realtime, D_o);
    $finish;
  end

  fp_adder#(
          .EXPONENT(EXP),
          .MANTISSA(MAN)
    ) fpadder(
          .clk(clk),
          .a1(A_i),
          .a2(B_i),
          .a3(C_i),
          .adder_o(D_o)
    );

  always #10 clk=~clk;

  initial begin
    if ($test$plusargs ("dump_all")) begin
      `ifdef NCV // Cadence TRN dump
          $recordsetup("design=board",
                       "compress",
                       "wrapsize=100M",
                       "version=1",
                       "run=1");
          $recordvars();
  
      `elsif VCS //Synopsys VPD dump
          $vcdplusfile("board.vpd");
          $vcdpluson;
          $vcdplusglitchon;
          $vcdplusflush;
      `else
          // Verilog VC dump
          $dumpfile("board.vcd");
          $dumpvars(0, board);
      `endif
    end
  end

endmodule
