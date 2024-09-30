module half_adder(
    input wire a,
    input wire b,
    output wire S,
    output wire cout
) ;
// Design the logic.

assign S = a^b ; // ^ is xor.
assign cout = a&b ;

endmodule

// Design the full adder.
module full_adder(
    input wire a,
    input wire b,
    input wire cin,
    output wire S,
    output wire cout
) ;
// Design the logic.

wire S1, C1, C2 ;

half_adder U1(
    .a(a),
    .b(b),
    .S(S1),
    .cout(C1)
) ;

half_adder U2(
    .a(S1),
    .b(cin),
    .S(S),
    .cout(C2)
) ;

assign cout = C1 | C2 ;

endmodule

// Design RCA using full adder.
module rca_Nbit #(parameter N = 32) (
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    input wire cin,
    output wire [N-1:0] S,
    output wire cout
) ;
wire [N:0] carry ;
assign carry[0] = cin ;

// generate block.
generate
    for(genvar i = 0; i<N; i=i+1) begin
        full_adder rca(
            .a(a[i]),
            .b(b[i]),
            .cin(carry[i]),
            .S(S[i]),
            .cout(carry[i+1])
        ) ;
    end
endgenerate

assign cout = carry[N] ;

endmodule

