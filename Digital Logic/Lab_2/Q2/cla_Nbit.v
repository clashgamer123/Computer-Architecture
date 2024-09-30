module CLA_4bit(
    input wire[3:0] a,
    input wire[3:0] b,
    input wire cin,
    output wire[3:0] sum,
    output wire cout
);
wire[3:0] P ; // Propogate signals a^b .
wire[3:0] G ; // Generate signals a&b .
wire[4:0] C ; // carries

generate  // Generate the P's and G's
    for(genvar i = 0; i<4; i=i+1) begin
        assign P[i] = a[i]^b[i] ;
        assign G[i] = a[i]&b[i] ;
    end
endgenerate

// Calculate all the carries.
assign C[0] = cin ;
assign C[1] = G[0] | (P[0]&C[0]) ;
assign C[2] = G[1] | (P[1]&G[0]) | (P[1]&P[0]&C[0]) ;
assign C[3] = G[2] | (P[2]&G[1]) | (P[2]&P[1]&G[0]) | (P[2]&P[1]&P[0]&C[0]) ;
assign C[4] = G[3] | (P[3]&G[2]) | (P[3]&P[2]&G[1]) | (P[3]&P[2]&P[1]&G[0]) | (P[3]&P[2]&P[1]&P[0]&C[0]) ;

// Calculate sums using the carries.
generate
    for(genvar i = 0; i<4; i=i+1) begin
        assign sum[i] = a[i]^b[i]^C[i] ;
    end
endgenerate

assign cout = C[4] ;

endmodule

module CLA_4bit_P_G(
    input wire[3:0] a,
    input wire[3:0] b,
    input wire cin,
    output wire[3:0] sum,
    output wire P,
    output wire G
) ;

wire[3:0] p ; // Propogate signals a^b .
wire[3:0] g ; // Generate signals a&b .
wire[4:0] C ; // carries

generate  // Generate the P's and G's
    for(genvar i = 0; i<4; i=i+1) begin
        assign p[i] = a[i]^b[i] ;
        assign g[i] = a[i]&b[i] ;
    end
endgenerate

// generate block propagate and block generate.
assign P = p[0]&p[1]&p[2]&p[3] ;
assign G = g[3] | (p[3]&g[2]) | (p[3]&p[2]&g[1]) | (p[3]&p[2]&p[1]&g[0]) ;


// Calculate all the carries.
assign C[0] = cin ;
assign C[1] = g[0] | (p[0]&C[0]) ;
assign C[2] = g[1] | (p[1]&g[0]) | (p[1]&p[0]&C[0]) ;
assign C[3] = g[2] | (p[2]&g[1]) | (p[2]&p[1]&g[0]) | (p[2]&p[1]&p[0]&C[0]) ;
assign C[4] = g[3] | (p[3]&g[2]) | (p[3]&p[2]&g[1]) | (p[3]&p[2]&p[1]&g[0]) | (p[3]&p[2]&p[1]&p[0]&C[0]) ;

// Calculate sums using the carries.
generate
    for(genvar i = 0; i<4; i=i+1) begin
        assign sum[i] = a[i]^b[i]^C[i] ;
    end
endgenerate

endmodule


module lookahead_carry_unit_16_bit(
    input wire P0, P1, P2, P3, G0, G1, G2, G3, cin ,
    output wire C4, C8, C12, C16, PF, GF 
) ;
// Calculate all the carries,
assign C4 = G0 | (P0&cin) ;
assign C8 = G1 | (P1&G0) | (P1&P0&cin) ;
assign C12 = G2 | (P2&G1) | (P2&P1&G0) | (P2&P1&P0&cin) ;
assign C16 = G3 | (P3&G2) | (P3&P2&G1) | (P3&P2&P1&G0) | (P3&P2&P1&P0&cin) ;

// Calculate PF and GF.
assign PF = P3&P2&P1&P0 ;
assign GF = G3 | (P3&G2) | (P3&P2&G1) | (P3&P2&P1&G0) ;

endmodule


module CLA_16bit(
    input wire[15:0] a, b,
    input wire cin,
    output wire[15:0] sum,
    output wire cout,
    output wire Pout, Gout
);

// Create 4 cla_4bit with p and g outputs.
// This is to compute P and Gs
wire[3:0] P, G ;
wire[15:0] dummysum ; // We use dummy sum because we have not yet computed CINs hence wrong sum for now.
generate
    for(genvar i = 0; i<4; i=i+1) begin
        CLA_4bit_P_G mini(
            .a(a[4*i+3:4*i]),
            .b(b[4*i+3:4*i]),
            .cin(1'b0),
            .sum(dummysum[4*i+3:4*i]),
            .P(P[i]),
            .G(G[i])
        );
    end
endgenerate

// Now calculate C4,C8,C12,C16 using lookahead_carry_unit_16_bit. 
wire[4:0] C; // carry[0] is cin and rest are c4,c8,c12,c16.
assign C[0] = cin ;
lookahead_carry_unit_16_bit U(.P0(P[0]), .P1(P[1]), .P2(P[2]), .P3(P[3]), .G0(G[0]), .G1(G[1]), .G2(G[2]), .G3(G[3]), .cin(cin), .C4(C[1]), .C8(C[2]), .C12(C[3]), .C16(C[4]), .PF(Pout), .GF(Gout)) ;

// Now we have all the carries.
generate
    for(genvar i = 0; i<4; i=i+1) begin
        CLA_4bit_P_G mini(
            .a(a[4*i+3:4*i]),
            .b(b[4*i+3:4*i]),
            .cin(C[i]),
            .sum(sum[4*i+3:4*i]),
            .P(P[i]),
            .G(G[i])
        );
    end
endgenerate

assign cout = C[4] ;

endmodule

module lookahead_carry_unit_32_bit(
    input wire P0, P1, G0, G1, cin,
    output wire C16, C32, PF, GF
) ;
// Calculate C16 and C32
assign C16 = G0 | (P0&cin) ;
assign C32 = G1 | (P1&G0) | (P1&P0&cin) ;

// Calculate PF and GF.
assign PF = P1&P0 ;
assign GF = G1 | (P1&G0) ;

endmodule

module CLA_32bit(
    input wire[31:0] a, b,
    input wire cin,
    output wire[31:0] sum,
    output wire cout,
    output wire Pout, Gout
) ;

// Calculate P0, P1, G0, G1 using 16bit CLA
wire [1:0] P, G;
wire[31:0] dummysum ; // Because when we use this 1st time we do not know the cin for each box and hence we get incorrect sum.

generate
    for(genvar i =0 ; i<2; i=i+1) begin
        CLA_16bit U(
            .a(a[16*i+15:16*i]),
            .b(b[16*i+15:16*i]),
            .cin(1'b0),
            .sum(dummysum[16*i+15:16*i]),
            .Pout(P[i]),
            .Gout(G[i])
        ) ;
    end
endgenerate

// Calculate C16 and C32 using lookahaed.
// Use C[2:0] to keep track
wire[2:0] C;
assign C[0] = cin ;
lookahead_carry_unit_32_bit U(.P0(P[0]), .P1(P[1]), .G0(G[0]), .G1(G[1]), .cin(cin), .C16(C[1]), .C32(C[2]), .PF(Pout), .GF(Gout)) ;

// Now that we know C16 and C32 we can calculate sum easily.
generate
    for(genvar i =0 ; i<2; i=i+1) begin
        CLA_16bit U(
            .a(a[16*i+15:16*i]),
            .b(b[16*i+15:16*i]),
            .cin(C[i]),
            .sum(sum[16*i+15:16*i]),
            .Pout(P[i]),
            .Gout(G[i])
        ) ;
    end
endgenerate

assign cout = C[2] ;

endmodule
