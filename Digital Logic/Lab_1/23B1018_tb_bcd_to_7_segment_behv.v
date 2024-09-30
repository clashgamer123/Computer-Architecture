module testbench ;
    reg x1, x2, x3, x4 ;
    wire A, B, C, D, E, F, G ;

    seven_segment uut(
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .E(E),
        .F(F),
        .G(G)
    );

    initial begin
        // Create a dump file to get the wave form with gtkwave.
        $dumpfile("dump.vcd") ;
        // import all the variables you want in the wave form
        $dumpvars(0, testbench) ;

        // monitor the variables.
        $display("x1 x2 x3 x4 - A B C D E F G") ;
        $monitor("%b  %b  %b  %b    %b %b %b %b %b %b %b",x1, x2, x3, x4, A, B, C, D, E, F, G) ;

        x1 = 0; x2 = 0; x3 = 0; x4 = 1 ; #10;
        x1 = 0; x2 = 0; x3 = 1; x4 = 0 ; #10 ;
        x1 = 0; x2 = 0; x3 = 1; x4 = 1 ; #10 ;
        x1 = 0; x2 = 1; x3 = 0; x4 = 0 ; #10 ;
        x1 = 0; x2 = 1; x3 = 0; x4 = 1 ; #10 ;
        x1 = 0; x2 = 1; x3 = 1; x4 = 0 ; #10 ;
        x1 = 0; x2 = 1; x3 = 1; x4 = 1 ; #10 ;
        x1 = 1; x2 = 0; x3 = 0; x4 = 0 ; #10 ;
        x1 = 1; x2 = 0; x3 = 0; x4 = 1 ; #10 ;
        x1 = 0; x2 = 0; x3 = 0; x4 = 0 ; #10 ;

        $display("Name: Abhinav Chowdary Bikkina.") ; 
        $display("Roll_No : 23B1018") ;

        $finish ;
    end

endmodule