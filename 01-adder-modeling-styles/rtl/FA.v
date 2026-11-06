module FA (sum, c_out, a, b, c_in);
    output sum, c_out;
    input a, b, c_in;
    wire s1, c1, c2;

    // Sum calculation
    xor G1 (s1, a, b);       // s1 = a XOR b
    xor G2 (sum, s1, c_in);  // sum = s1 XOR c_in

    // Carry-out calculation
    and G3 (c1, a, b);       // c1 = a AND b
    and G4 (c2, s1, c_in);   // c2 = s1 AND c_in
    or  G5 (c_out, c1, c2);  // c_out = c1 OR c2
endmodule