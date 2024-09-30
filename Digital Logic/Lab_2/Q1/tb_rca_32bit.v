`timescale 1ns/1ps

module tb_rca_32_bit;

parameter N = 32;

// declare your signals as reg or wire
reg [N-1:0] A ;
reg [N-1:0] B ;
reg cin ;
wire cout ;
wire [N-1:0] S ;

// The correct outputs being cout_c and S_c .
reg [N-1:0] S_c ;
reg cout_c ;

// Instantiate our design.
rca_Nbit #(.N(N)) dut(.a(A), .b(B), .cin(cin), .S(S), .cout(cout));


initial begin	
$display("Testing begins....") ;
$monitor("A = %b, B = %b, cin = %b, S = %b, S_c = %b, cout = %b, cout_c = %b", A, B, cin, S, S_c, cout, cout_c);

// write the stimuli conditions
repeat(10) begin
    A = $random ;
    B = $random ;
    cin =$random ;
    {cout_c, S_c} = A + B + cin ;
    #30 ;
end
end

initial begin
    $dumpfile("rca_32bit.vcd");
    $dumpvars(0, tb_rca_32_bit);
end

endmodule
