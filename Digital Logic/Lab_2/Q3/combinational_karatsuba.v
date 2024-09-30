module karatsuba_16 (
    input wire[15:0] X,
    input wire[15:0] Y,
    output wire[31:0] Z
);

karatsuba #(.N(16)) K( .X(X), .Y(Y), .Z(Z)) ;    
endmodule

module karatsuba #(parameter N=16) (
    input wire[N-1:0] X ,
    input wire[N-1:0] Y ,
    output wire[2*N-1:0] Z
) ;
// Let us use recursion.
// N is power of 2 obviously.
// Base case N=1
if (N==1) begin
    assign Z = X&Y ;
end else begin
    
    // Divide into 2 parts.
    wire[N/2-1:0] X_high = X[N-1:N/2] ;
    wire[N/2-1:0] X_low = X[N/2-1:0] ;
    wire[N/2-1:0] Y_high = Y[N-1:N/2] ;
    wire[N/2-1:0] Y_low = Y[N/2-1:0] ;

    // Compute z1 = x_high*y_high and z2 = x_low*y_low
    // Compute z3 = (x_high + x_low)*(y_high+y_low) .
    // final Z = {z1,16'b0}+{z3-z1-z2,8'b0}+z2 for N=16.
    wire[N-1:0] z1, z2 ;
    wire[N/2-1:0] z31, z32 ; // last n/2 bits in both the sums
    wire b1, b2 ; // first bit that is carry in both sums.

    karatsuba #(.N(N/2)) U1(.X(X_high),.Y(Y_high),.Z(z1)) ;
    karatsuba #(.N(N/2)) U2(.X(X_low),.Y(Y_low),.Z(z2)) ;
    RCA #(.N(N/2)) R1(.a(X_high), .b(X_low), .cin(1'b0), .S(z31), .cout(b1)) ;
    RCA #(.N(N/2)) R2(.a(Y_high), .b(Y_low), .cin(1'b0), .S(z32), .cout(b2)) ;

    // we are finding z3 by treating it as (2^(n/2)*b1+z31)(2^(n/2)*b2+z32) . This has 4 terms.
    // term1 : z31*z32 called t1.
    wire[N-1:0] t1;
    karatsuba #(.N(N/2)) U3(.X(z31), .Y(z32), .Z(t1)) ;

    // term 2 : 2^N/2 * b1 * z32 ie mux between 2 values.
    wire[N-1:0] t2 ;
    mux_2_1 #(.N(N)) M1( .s1({z32, {(N/2){1'b0}}}), .s2({(N){1'b0}}), .b(b1), .o(t2)) ;

    // term 3 : 2^(N/2)*z31*b2
    wire[N-1:0] t3;
    mux_2_1 #(.N(N)) M2( .s1({z31, {(N/2){1'b0}}}), .s2({(N){1'b0}}), .b(b2), .o(t3)) ;

    // term 4 is just b1b2*2^(N/2)
    wire[N:0] t4 ;
    assign t4 = {b1&b2, {(N){1'b0}}} ;

    //Now add all using RCA 4 times.
    wire[N+1:0] x1,x2,x3 ;
    RCA #(.N(N+2)) RCA1(.a({1'b0,t4}), .b({{(2){1'b0}}, t1}), .cin(1'b0), .S(x1), .cout()) ;
    RCA #(.N(N+2)) RCA2(.a(x1), .b({{(2){1'b0}}, t2}), .cin(1'b0), .S(x2), .cout()) ;
    RCA #(.N(N+2)) RCA3(.a(x2), .b({{(2){1'b0}}, t3}), .cin(1'b0), .S(x3), .cout()) ;

    // compute z3-z1-z2
    
    wire[N+1:0] S1, S2 ;
    RCS #(.N(N+2)) Y1(.a(x3), .b({{(2){1'b0}}, z1}), .D(S1)) ;
    RCS #(.N(N+2)) Y2(.a(S1), .b({{(2){1'b0}}, z2}), .D(S2)) ;

    // Remove the 1st 0 from S2 to make it say S3.
    wire[N:0] S3; 
    assign S3 = S2[N:0]
    
    // Now we need to add them using a normal rca adder. Name it RCA.
    // First add z31 and z32 but before adding concatenate them with N/2 zeroes. This is because both of them are N size and we multiply there 
    // sum by 2^(N/2) finally. Hence we need another N/2 zeroes in the left to make size 2N.

    wire[3*N/2-1:0] z3 ;
    assign z3 = {{(N/2-1){1'b0}}, S3} ;
    
    // Now add to get final product. First add z1 and z2 to get z
    wire[2*N-1:0] z;
    RCA #(.N(2*N)) R3(.a( { z1 ,{(N){1'b0}}} ), .b( {{(N){1'b0}}, z2 } ), .cin(1'b0), .S(z), .cout()) ;

    // Final addition.
    RCA #(.N(2*N)) R4(.a( z ), .b({ z3, {(N/2){1'b0}} }), .cin(1'b0), .S(Z), .cout()) ;
end
endmodule


// Half adder.
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
module RCA #(parameter N = 32) (
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

// Subtractor using RCA and 2s complement. Here there is no carry in.
// We find a-b by adding 2s complement of b to a. 
// When a>b we get cout 1 and the correct answer.
// Else we get cout 0 and the negative number in 2s complement.
// In our case a will always be >b hence we can safely ignore cout.
module RCS #(parameter N = 32) (
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output wire [N-1:0] D
) ;
wire [N-1:0] b_c ;
wire [N-1:0] b_2_c ;
// generate complement of b.
generate
    for( genvar i = 0; i<N; i=i+1) begin
        assign b_c[i] = ~b[i] ; // not gate
    end
endgenerate

// So create (n-1){0}1 and b_c and use N RCA.
RCA #(.N(N)) u1 (.a( b_c), .b({{(N-1){1'b0}}, 1'b1}), .cin(1'b0), .S(b_2_c), .cout()) ; // cout can be safely ignored as it is 1 only when b is 0000..
RCA #(.N(N)) u2 (.a(b_2_c), .b(a), .cin(1'b0), .S(D), .cout()) ; // as a>b ignore the cout that is 1 and capture D.

endmodule

// Mux that selects between s1 and s2 based on b.
module mux_2_1 #(parameter N = 16)(
    input wire[N-1:0] s1,
    input wire[N-1:0] s2,
    input wire b,
    output wire[N-1:0] o
) ;
wire[N-1:0] and_out0;
wire[N-1:0] and_out1;

// AND gates
generate
    for (genvar i = 0; i < N; i=i+1) begin
        assign and_out0[i] = b&s1[i] ;
        assign and_out1[i] = (~b)&s2[i] ;
    end
endgenerate

// OR gates
generate
    for (genvar i = 0; i < N; i=i+1) begin 
        assign o[i] = and_out0[i] | and_out1[i] ;
    end
endgenerate

endmodule
