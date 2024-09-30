`timescale 1ns/1ps

module tb_combinational_karatsuba;

parameter N = 16;

// declare your signals as reg or wire
reg [N-1:0] X,Y ;
wire [2*N-1:0] Z ;
reg [2*N-1:0] Z_c ; 
// Z is from our design and Z_c is the correct output using Z_c = A*B.

initial begin

// write the stimuli conditions
$display("Testing begins...") ;
$monitor("X = %b, Y = %b, Z = %b, Z_c = %b", X, Y, Z, Z_c) ;

repeat(10) begin
    X = $random ;
    Y = $random ;
    Z_c = X*Y ;
    #15 ;
end
end

karatsuba_16 dut (.X(X), .Y(Y), .Z(Z));

initial begin
    $dumpfile("combinational_karatsuba.vcd");
    $dumpvars(0, tb_combinational_karatsuba);
end

endmodule
