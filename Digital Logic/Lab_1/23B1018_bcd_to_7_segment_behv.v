module seven_segment(
    input x1,
    input x2,
    input x3,
    input x4,
    output A, B, C, D, E, F, G
);

assign A = (x1|x2|x3|~x4)&(x1|~x2|x4) ;
assign B = (x1|~x2|x3|~x4)&(x1|~x2|~x3|x4) ;
assign C = x1|x2|~x3|x4 ;
assign D = (x2|x3|~x4)&(x1|~x2|x3|x4)&(x1|~x2|~x3|~x4) ;
assign E = (~x1&x3&~x4)|(~x2&~x3&~x4) ;
assign F = (x1|x2|~x4)&(x1|~x3|~x4)&(x1|x2|~x3) ; 
assign G = (x1|x2|x3|~x4)&(x1|~x2|~x3|~x4)&(x1|x2|x3|x4) ;

endmodule