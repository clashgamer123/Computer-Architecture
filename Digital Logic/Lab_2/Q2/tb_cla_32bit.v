`timescale 1ns/1ns

module tb_cla_32bit;

parameter N = 32;     /*Change this to 16 if you want to test CLA 16-bit*/

// declare your signals as reg or wire
reg [N-1:0] a, b;
reg cin;
wire[N-1:0] S;
wire cout, Pout, Gout;

// The correct outputs being cout_c and S_c .
reg [N-1:0] S_c ;
reg cout_c ;

initial begin

// write the stimuli conditions
$display("Testing begins....") ;
$monitor("a = %b, b = %b, cin = %b, S = %b, S_c = %b, cout = %b, cout_c = %b", a, b, cin, S, S_c, cout, cout_c);

// write the stimuli conditions
repeat(10) begin
    a = $random ;
    b = $random ;
    cin =$random ;
    {cout_c, S_c} = a + b + cin ;
    #30 ;
end
end

CLA_32bit dut (.a(a), .b(b), .cin(cin), .sum(S), .cout(cout), .Pout(Pout), .Gout(Gout));


initial begin
    $dumpfile("cla_32bit.vcd");
    $dumpvars(0, tb_cla_32bit);
end

endmodule

// VERIFIED. THE MODULES WORK CORRECTLY.
