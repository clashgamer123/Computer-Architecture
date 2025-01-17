/* 32-bit simple karatsuba multiplier */

/*32-bit Karatsuba multipliction using a single 16-bit module*/

module iterative_karatsuba_32_16(clk, rst, enable, A, B, C);
    input clk;
    input rst;
    input [31:0] A;
    input [31:0] B;
    output [63:0] C;
    
    input enable;

    wire [1:0] sel_y;
    wire [1:0] sel_x;
    
    wire [1:0] sel_z;
    wire [1:0] sel_T;
    
    wire done;
    wire en_z;
    wire en_T;
    
    wire [32:0] h1;
    wire [32:0] h2;
    wire [63:0] g1;
    wire [63:0] g2;
    
    assign C = g2;
    reg_with_enable #(.N(63)) Z(.clk(clk), .rst(rst), .en(en_z), .X(g1), .O(g2) );  // Fill in the proper size of the register
    reg_with_enable #(.N(32)) T(.clk(clk), .rst(rst), .en(en_T), .X(h1), .O(h2) );  // Fill in the proper size of the register
    
    iterative_karatsuba_datapath dp(.clk(clk), .rst(rst), .X(A), .Y(B), .Z(g2), .T(h2), .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T), .en_z(en_z), .en_T(en_T), .done(done), .W1(g1), .W2(h1));
    iterative_karatsuba_control control(.clk(clk),.rst(rst), .enable(enable), .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T), .en_z(en_z), .en_T(en_T), .done(done));
    
endmodule

module iterative_karatsuba_datapath(clk, rst, X, Y, T, Z, sel_x, sel_y, en_z, sel_z, en_T, sel_T, done, W1, W2);
    input clk;
    input rst;
    input [31:0] X;    // input X
    input [31:0] Y;    // Input Y
    input [32:0] T;    // input which sums X_h*Y_h and X_l*Y_l (its also a feedback through the register)
    input [63:0] Z;    // input which calculates the final outcome (its also a feedback through the register)
    output [63:0] W1;  // Signals going to the registers as input
    output [32:0] W2;  // signals hoing to the registers as input

    input [1:0] sel_x;  // control signal 
    input [1:0] sel_y;  // control signal 
    
    input en_z;         // control signal 
    input [1:0] sel_z;  // control signal 
    input en_T;         // control signal 
    input [1:0] sel_T;  // control signal 
    
    input done;         // Final done signal
    
    // Let us create wires for Xh, Xl, Yh, Yl.
    wire[15:0] Xh ;
    wire[15:0] Xl ;
    wire[15:0] Yh ;
    wire[15:0] Yl ;
    assign Xh = X[31:16] ;
    assign Xl = X[15:0] ;
    assign Yh = Y[31:16] ;
    assign Yl = Y[15:0] ;

    // Xh+Xl and Yh+Yl requires adder. Connect the most significant bits in them wire b1 and b2 respectively.
    wire b1, b2 ;
    wire[15:0] Xs ; // remaining 16 bits in sum Xh+Xl
    wire[15:0] Ys ; // remaining 16 bits in sum Yh+Yl

    // Instantiate the adders. We can use multiple adders. Restriction is only on multipliers.
    adder_Nbit #(.N(16)) adder1(.a(Xh), .b(Xl), .cin(1'b0), .S(Xs), .cout(b1)) ;
    adder_Nbit #(.N(16)) adder2(.a(Yh), .b(Yl), .cin(1'b0), .S(Ys), .cout(b2)) ;

    // (Xh+Xl)(Yh+Yl) = 2^32*b1*b2 + 2^16*Xs*b2 + 2^16*Ys*b1 + Xs*Ys
    // Computing first 3 terms is very easy as a multiplexer is enough.
    
    wire[32:0] t1 ;
    wire[31:0] t2, t3 ; // The first 3 terms t1, t2, t3.
    assign t1 = {(b1&b2), {(32){1'b0}}} ;
    mux_2_1 #(.N(32)) M1(.s1({Xs, {(16){1'b0}}}), .s2({(32){1'b0}}), .b(b2), .o(t2)) ;
    mux_2_1 #(.N(32)) M2(.s1({Ys, {(16){1'b0}}}), .s2({(32){1'b0}}), .b(b1), .o(t3)) ;    

    // Inputs and outputs to the mult_16(X,Y,Z).
    // We need 3 multiplications respectively Xh*Xl, Yh*Yl and Xs*Ys . Use sel_x and sel_y to control.
    wire[15:0] i1, i2 ;
    mux_4_2 #(.N(16)) M3(.s1(Xs), .s2(Xl), .s3(Xh), .s4({(16){1'b0}}), .s(sel_x), .o(i1)) ;
    mux_4_2 #(.N(16)) M4(.s1(Ys), .s2(Yl), .s3(Yh), .s4({(16){1'b0}}), .s(sel_y), .o(i2)) ;

    wire[31:0] M ;  // Multiplier output.
    mult_16 mul(.X(i1), .Y(i2), .Z(M)) ;

    // Adder that adds the input from T and from mult16 to store in reg H.
    // Initially it adds XhYh to 0 and stores it.
    // In the next state it adds XlYl to XhYh and stores it. After this disable en_T.
    adder_Nbit #(.N(33)) H_add(.a({1'b0,M}), .b(T), .cin(1'b0), .S(W2), .cout()) ;

    // Now lets manipulate Z and W1 based on sel_z.
    // Compute (Xh+Xl)(Yh+Yl) first.
    // Three values from which sel_z selects one.
    wire[63:0] A1, A2, A3 ;
    wire[33:0] v1, v2, v3 ;
    adder_Nbit #(.N(34)) add1(.a({1'b0, t1}), .b({{(2){1'b0}}, t2}), .cin(1'b0), .S(v1), .cout()) ;
    adder_Nbit #(.N(34)) add2(.a(v1), .b({{(2){1'b0}}, t3}), .cin(1'b0), .S(v2), .cout()) ;
    adder_Nbit #(.N(34)) add3(.a(v2), .b({{(2){1'b0}}, M}), .cin(1'b0), .S(v3), .cout()) ;

    // Compute z3-z1-z2. Take z1+z2 from T.
    wire[33:0] h ;
    subtract_Nbit #(.N(34)) sub1(.a(v3), .b({1'b0,T}), .cin(1'b0), .S(h), .cout_sub(), .ov()) ;

    // Now add this properly to Z.
    adder_Nbit #(.N(64)) ADD(.a(Z), .b({{(14){1'b0}}, h, {(16){1'b0}}}), .cin(1'b0), .S(A3), .cout()) ;

    // Now A1.
    assign A1 = {M,{(32){1'b0}}} ;
    
    // Now A2.
    adder_Nbit #(.N(64)) A2_comp(.a(Z), .b({{(32){1'b0}}, M}), .cin(1'b0), .S(A2), .cout()) ;

    // Now the multiplexer to choose from these . The control signal is sel_z.
    mux_4_2 #(.N(64)) M5(.s1(A1), .s2(A2), .s3(A3), .s4({(64){1'b0}}), .s(sel_z), .o(W1) ) ;

endmodule


module iterative_karatsuba_control(clk,rst, enable, sel_x, sel_y, sel_z, sel_T, en_z, en_T, done);
    input clk;
    input rst;
    input enable;
    
    output reg [1:0] sel_x;
    output reg [1:0] sel_y;
    
    output reg [1:0] sel_z;
    output reg [1:0] sel_T;    
    
    output reg en_z;
    output reg en_T;
    
    output reg done;
    
    reg [5:0] state, nxt_state; // We are using 4 states.
    parameter S0 = 6'b000001;   // initial state when XhYh is calculated and is stored in T and Z(after adding 32 zeroes to the right).
    parameter S1 = 6'b000010;   // XlYl is added to the feedback from T and stored in T. {320's,XlYl} is added to feedback from Z and stored in Z.
    parameter S2 = 6'b000011;   // XsYs is computed and then z3-z1-z2 is computed and this value with appropriate  0's padding is added to feedback from Z.
    parameter S3 = 6'b000100;   // en_Z is set to 0 ie the register Z value becomes fixed untill rst.

    always @(posedge clk) begin
        if (rst) begin
            state <= S0;
        end
        else if (enable) begin
            state <= nxt_state;
        end
    end
    
    always@(*) begin
        case(state) 
            S0: 
                begin
					sel_x = 2'b10 ;
                    sel_y = 2'b10 ;
                    sel_z = 2'b11 ;
                    sel_T = 2'b00 ;
                    en_z = 1'b1 ;
                    en_T = 1'b1 ; 
                    done = 1'b0 ;
                    nxt_state = S1 ;
                end

            S1:
                begin
                    sel_x = 2'b01 ;
                    sel_y = 2'b01 ;
                    sel_z = 2'b01 ;
                    sel_T = 2'b00 ;
                    en_z = 1'b1 ;
                    en_T = 1'b1 ;
                    done = 1'b0 ;
                    nxt_state = S2 ; 
                end

            S2: 
                begin
                    sel_x = 2'b11 ;
                    sel_y = 2'b11 ;
                    sel_z = 2'b10 ;
                    sel_T = 2'b00 ;
                    en_z = 1'b1 ;
                    en_T = 1'b0 ; 
                    done = 1'b0 ;
                    nxt_state = S3 ;
                end
            
            S3:
                begin
                    en_z = 1'b0 ;
                    en_T = 1'b0 ;
                    done = 1'b1 ;
                    nxt_state = S3 ;
                    // Here we have disabled both en_z and en_T as we have reached the answer ie done = 1'b1 .
                end
            default: 
                begin
                    nxt_state = S0 ;
                end            
        endcase
        
    end

endmodule


module reg_with_enable #(parameter N = 32) (clk, rst, en, X, O );
    input [N:0] X;
    input clk;
    input rst;
    input en;
    output [N:0] O;
    
    reg [N:0] R;
    
    always@(posedge clk) begin
        if (rst) begin
            R <= {N{1'b0}};
        end
        if (en) begin
            R <= X;
        end
    end
    assign O = R;
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

// Mux that selects between 4 inputs based on two control signals.
module mux_4_2 #(parameter N = 16)(
    input wire[N-1:0] s1, s2, s3, s4,
    input wire[1:0] s,
    output wire[N-1:0] o 
);

wire[N-1:0] out1, out2 ;
mux_2_1 #(.N(N)) M1(.s1(s1), .s2(s2), .b(s[1]), .o(out1)) ;
mux_2_1 #(.N(N)) M2(.s1(s3), .s2(s4), .b(s[1]), .o(out2)) ;
mux_2_1 #(.N(N)) M3(.s1(out1), .s2(out2), .b(s[0]), .o(o)) ;

endmodule

/*-------------------Supporting Modules--------------------*/
/*------------- Iterative Karatsuba: 32-bit Karatsuba using a single 16-bit Module*/

module mult_16(X, Y, Z);
input [15:0] X;
input [15:0] Y;
output [31:0] Z;

assign Z = X*Y;

endmodule


module mult_17(X, Y, Z);
input [16:0] X;
input [16:0] Y;
output [33:0] Z;

assign Z = X*Y;

endmodule

module full_adder(a, b, cin, S, cout);
input a;
input b;
input cin;
output S;
output cout;

assign S = a ^ b ^ cin;
assign cout = (a&b) ^ (b&cin) ^ (a&cin);

endmodule


module check_subtract (A, B, C);
 input [7:0] A;
 input [7:0] B;
 output [8:0] C;
 
 assign C = A - B; 
endmodule



/* N-bit RCA adder (Unsigned) */
module adder_Nbit #(parameter N = 32) (a, b, cin, S, cout);
input [N-1:0] a;
input [N-1:0] b;
input cin;
output [N-1:0] S;
output cout;

wire [N:0] cr;  

assign cr[0] = cin;


generate
    genvar i;
    for (i = 0; i < N; i = i + 1) begin
        full_adder addi (.a(a[i]), .b(b[i]), .cin(cr[i]), .S(S[i]), .cout(cr[i+1]));
    end
endgenerate    


assign cout = cr[N];

endmodule


module Not_Nbit #(parameter N = 32) (a,c);
input [N-1:0] a;
output [N-1:0] c;

generate
genvar i;
for (i = 0; i < N; i = i+1) begin
    assign c[i] = ~a[i];
end
endgenerate 

endmodule


/* 2's Complement (N-bit) */
module Complement2_Nbit #(parameter N = 32) (a, c, cout_comp);

input [N-1:0] a;
output [N-1:0] c;
output cout_comp;

wire [N-1:0] b;
wire ccomp;

Not_Nbit #(.N(N)) compl(.a(a),.c(b));
adder_Nbit #(.N(N)) addc(.a(b), .b({ {N-1{1'b0}} ,1'b1 }), .cin(1'b0), .S(c), .cout(ccomp));

assign cout_comp = ccomp;

endmodule


/* N-bit Subtract (Unsigned) */
module subtract_Nbit #(parameter N = 32) (a, b, cin, S, ov, cout_sub);

input [N-1:0] a;
input [N-1:0] b;
input cin;
output [N-1:0] S;
output ov;
output cout_sub;

wire [N-1:0] minusb;
wire cout;
wire ccomp;

Complement2_Nbit #(.N(N)) compl(.a(b),.c(minusb), .cout_comp(ccomp));
adder_Nbit #(.N(N)) addc(.a(a), .b(minusb), .cin(1'b0), .S(S), .cout(cout));

assign ov = (~(a[N-1] ^ minusb[N-1])) & (a[N-1] ^ S[N-1]);
assign cout_sub = cout | ccomp;

endmodule



/* n-bit Left-shift */

module Left_barrel_Nbit #(parameter N = 32)(a, n, c);

input [N-1:0] a;
input [$clog2(N)-1:0] n;
output [N-1:0] c;


generate
genvar i;
for (i = 0; i < $clog2(N); i = i + 1 ) begin: stage
    localparam integer t = 2**i;
    wire [N-1:0] si;
    if (i == 0) 
    begin 
        assign si = n[i]? {a[N-t:0], {t{1'b0}}} : a;
    end    
    else begin 
        assign si = n[i]? {stage[i-1].si[N-t:0], {t{1'b0}}} : stage[i-1].si;
    end
end
endgenerate

assign c = stage[$clog2(N)-1].si;

endmodule



