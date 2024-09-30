`timescale 1ns/1ps

module tb_combinational_karatsuba;
reg clk , rst, enable;

parameter N = 32;

// declare your signals as reg or wire
reg [N-1:0] X,Y ;
wire [2*N-1:0] Z ;
reg [2*N-1:0] Z_c ; 
// Z is from our design and Z_c is the correct output using Z_c = A*B.

always begin
    clk = 1'b1 ;
    #5 clk = ~clk;
    #5 ;
end

always begin
    rst = 1'b1;
    enable = 1'b0;
    #10 ;
    rst = 1'b0;
    enable = 1'b1;
    #50 ;
end

initial begin

// write the stimuli conditions
$display("Testing begins...") ;
$monitor("clk = %b, X = %b, Y = %b, Z = %b, Z_c = %b",clk, X, Y, Z, Z_c) ;

repeat(10) begin
    X = $random ;
    Y = $random ;
    Z_c = X*Y ;
    #60 ;
end
end

iterative_karatsuba_32_16 uit(.clk(clk), .rst(rst), .enable(enable), .A(X), .B(Y), .C(Z)) ;

// initial begin
//     $dumpfile("iterative_karatsuba.vcd");
//     $dumpvars(0, tb.v);
// end

always  begin
    #550 ;
    $finish ;
end

endmodule