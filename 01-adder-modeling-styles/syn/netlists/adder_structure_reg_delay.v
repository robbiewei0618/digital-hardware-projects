/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : V-2023.12
// Date      : Thu Oct  3 16:57:16 2024
/////////////////////////////////////////////////////////////


module FA_0 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n2, n3, n4;

  MAOI222D4BWP16P90LVT U1 ( .A(n2), .B(n3), .C(n4), .ZN(c_out) );
  CKND16BWP16P90LVT U2 ( .I(a), .ZN(n2) );
  CKND16BWP16P90LVT U3 ( .I(b), .ZN(n3) );
  CKND16BWP16P90LVT U4 ( .I(c_in), .ZN(n4) );
  XOR3D1BWP16P90LVT U5 ( .A1(b), .A2(a), .A3(c_in), .Z(sum) );
endmodule


module FA_1 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   net906, net907, net908, net909;

  XNR2D1BWP16P90LVT U1 ( .A1(c_in), .A2(net906), .ZN(sum) );
  XOR2D1BWP16P90LVT U2 ( .A1(net908), .A2(b), .Z(net906) );
  INVD1BWP16P90 U3 ( .I(c_in), .ZN(net907) );
  INVD1BWP16P90LVT U4 ( .I(a), .ZN(net908) );
  INVD1BWP16P90LVT U5 ( .I(b), .ZN(net909) );
  OAI22D1BWP16P90LVT U6 ( .A1(net907), .A2(net906), .B1(net908), .B2(net909), 
        .ZN(c_out) );
endmodule


module FA_2 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90 U1 ( .A1(c_in), .A2(n5), .ZN(sum) );
  ND2D1BWP16P90LVT U2 ( .A1(a), .A2(b), .ZN(n2) );
  ND2D4BWP16P90LVT U3 ( .A1(c_in), .A2(n3), .ZN(n1) );
  CKND2D4BWP16P90LVT U4 ( .A1(n1), .A2(n2), .ZN(c_out) );
  CKND1BWP16P90LVT U5 ( .I(n5), .ZN(n3) );
  XOR2D1BWP16P90LVT U6 ( .A1(n4), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U7 ( .I(a), .ZN(n4) );
endmodule


module FA_3 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   net916, net917, net1451, n1, n2, n3;

  XNR2D1BWP16P90LVT U1 ( .A1(b), .A2(a), .ZN(net916) );
  AN2D1BWP16P90LVT U2 ( .A1(b), .A2(a), .Z(n1) );
  OR2D1BWP16P90LVT U3 ( .A1(b), .A2(a), .Z(n2) );
  INR2D4BWP16P90LVT U4 ( .A1(n2), .B1(n3), .ZN(c_out) );
  NR2D4BWP16P90LVT U5 ( .A1(c_in), .A2(n1), .ZN(n3) );
  INVD1BWP16P90 U6 ( .I(c_in), .ZN(net917) );
  XNR2D1BWP16P90LVT U7 ( .A1(net1451), .A2(net916), .ZN(sum) );
  INVD1BWP16P90 U8 ( .I(net917), .ZN(net1451) );
endmodule


module FA_4 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4;

  XNR2D1BWP16P90LVT U1 ( .A1(n4), .A2(c_in), .ZN(sum) );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n3) );
  OAI22D4BWP16P90LVT U3 ( .A1(n3), .A2(n4), .B1(n2), .B2(n1), .ZN(c_out) );
  XOR2D1BWP16P90LVT U4 ( .A1(n2), .A2(b), .Z(n4) );
  INVD1BWP16P90LVT U5 ( .I(a), .ZN(n2) );
  INVD1BWP16P90LVT U6 ( .I(b), .ZN(n1) );
endmodule


module FA_5 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  ND2D1BWP16P90LVT U2 ( .A1(a), .A2(b), .ZN(n3) );
  XNR2D1BWP16P90LVT U3 ( .A1(n5), .A2(n1), .ZN(sum) );
  IND2D4BWP16P90LVT U4 ( .A1(n5), .B1(c_in), .ZN(n2) );
  CKND2D4BWP16P90LVT U5 ( .A1(n2), .A2(n3), .ZN(c_out) );
  XOR2D1BWP16P90LVT U6 ( .A1(n4), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U7 ( .I(a), .ZN(n4) );
endmodule


module FA_6 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n2) );
  OAI22D4BWP16P90LVT U4 ( .A1(n2), .A2(n5), .B1(n4), .B2(n3), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n4), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n4) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n3) );
endmodule


module FA_7 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  XNR2D1BWP16P90LVT U2 ( .A1(n5), .A2(n1), .ZN(sum) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_8 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_9 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_10 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_11 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_12 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   net960, net1411, n1, n2, n3;

  OAI22D4BWP16P90LVT U1 ( .A1(n1), .A2(net960), .B1(n2), .B2(n3), .ZN(c_out)
         );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n1) );
  XOR2D1BWP16P90LVT U3 ( .A1(n2), .A2(b), .Z(net960) );
  INVD1BWP16P90LVT U4 ( .I(a), .ZN(n2) );
  INVD1BWP16P90LVT U5 ( .I(b), .ZN(n3) );
  DEL025D1BWP16P90 U6 ( .I(n1), .Z(net1411) );
  XOR2D1BWP16P90LVT U7 ( .A1(net1411), .A2(net960), .Z(sum) );
endmodule


module FA_13 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XOR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .Z(sum) );
  DEL025D1BWP16P90 U2 ( .I(n4), .Z(n1) );
  XOR2D1BWP16P90LVT U3 ( .A1(n3), .A2(b), .Z(n5) );
  INVD4BWP16P90LVT U4 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U5 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_14 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XOR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .Z(sum) );
  DEL025D1BWP16P90 U2 ( .I(n4), .Z(n1) );
  XOR2D1BWP16P90LVT U3 ( .A1(n3), .A2(b), .Z(n5) );
  INVD4BWP16P90LVT U4 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U5 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_15 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5, n6;

  XNR2D1BWP16P90LVT U1 ( .A1(n2), .A2(n6), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(n5), .Z(n1) );
  INVD1BWP16P90 U3 ( .I(n1), .ZN(n2) );
  XOR2D1BWP16P90LVT U4 ( .A1(n4), .A2(b), .Z(n6) );
  INVD4BWP16P90LVT U5 ( .I(c_in), .ZN(n5) );
  OAI22D4BWP16P90LVT U6 ( .A1(n5), .A2(n6), .B1(n4), .B2(n3), .ZN(c_out) );
  INVD1BWP16P90LVT U7 ( .I(a), .ZN(n4) );
  INVD1BWP16P90LVT U8 ( .I(b), .ZN(n3) );
endmodule


module FA_16 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5, n6;

  XNR2D1BWP16P90LVT U1 ( .A1(n2), .A2(n6), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(n5), .Z(n1) );
  INVD1BWP16P90 U3 ( .I(n1), .ZN(n2) );
  INVD4BWP16P90LVT U4 ( .I(c_in), .ZN(n5) );
  OAI22D4BWP16P90LVT U5 ( .A1(n5), .A2(n6), .B1(n4), .B2(n3), .ZN(c_out) );
  XOR2D1BWP16P90LVT U6 ( .A1(n4), .A2(b), .Z(n6) );
  INVD1BWP16P90LVT U7 ( .I(a), .ZN(n4) );
  INVD1BWP16P90LVT U8 ( .I(b), .ZN(n3) );
endmodule


module FA_17 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP20P90 U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_18 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   net984, n1, n2, n3, n4, n5;

  CKND1BWP16P90LVT U1 ( .I(n5), .ZN(n3) );
  ND2D1BWP16P90LVT U2 ( .A1(b), .A2(a), .ZN(n5) );
  ND2D1BWP16P90LVT U3 ( .A1(n4), .A2(n5), .ZN(n1) );
  NR2D1BWP16P90LVT U4 ( .A1(b), .A2(a), .ZN(n4) );
  XNR2D1BWP16P90LVT U5 ( .A1(b), .A2(a), .ZN(net984) );
  INR2D4BWP16P90LVT U6 ( .A1(n1), .B1(n2), .ZN(c_out) );
  NR2D4BWP16P90LVT U7 ( .A1(c_in), .A2(n3), .ZN(n2) );
  XNR2D1BWP16P90LVT U8 ( .A1(c_in), .A2(net984), .ZN(sum) );
endmodule


module FA_19 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   net988, net1360, n1, n2, n3;

  XNR2D1BWP16P90LVT U1 ( .A1(b), .A2(a), .ZN(net988) );
  AN2D1BWP16P90LVT U2 ( .A1(b), .A2(a), .Z(n1) );
  OR2D1BWP16P90LVT U3 ( .A1(b), .A2(a), .Z(n2) );
  INR2D4BWP16P90LVT U4 ( .A1(n2), .B1(n3), .ZN(c_out) );
  NR2D4BWP16P90LVT U5 ( .A1(c_in), .A2(n1), .ZN(n3) );
  XNR2D1BWP16P90LVT U6 ( .A1(net1360), .A2(net988), .ZN(sum) );
  DEL025D1BWP16P90 U7 ( .I(c_in), .Z(net1360) );
endmodule


module FA_20 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_21 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   net996, n1, n2, n3, n4, n5;

  CKND1BWP16P90LVT U1 ( .I(n5), .ZN(n3) );
  ND2D1BWP16P90LVT U2 ( .A1(b), .A2(a), .ZN(n5) );
  ND2D1BWP16P90LVT U3 ( .A1(n4), .A2(n5), .ZN(n1) );
  NR2D1BWP16P90LVT U4 ( .A1(b), .A2(a), .ZN(n4) );
  XNR2D1BWP16P90LVT U5 ( .A1(b), .A2(a), .ZN(net996) );
  INR2D4BWP16P90LVT U6 ( .A1(n1), .B1(n2), .ZN(c_out) );
  CKNR2D4BWP16P90LVT U7 ( .A1(c_in), .A2(n3), .ZN(n2) );
  XNR2D1BWP20P90 U8 ( .A1(c_in), .A2(net996), .ZN(sum) );
endmodule


module FA_22 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n4), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n3) );
  MOAI22D4BWP16P90LVT U4 ( .A1(n3), .A2(n4), .B1(a), .B2(b), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n2), .A2(b), .Z(n4) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n2) );
endmodule


module FA_23 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_24 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_25 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_26 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_27 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   net1026, net1381, net1435, n1, n2, n3;

  OAI22D4BWP16P90LVT U1 ( .A1(n1), .A2(net1026), .B1(n2), .B2(n3), .ZN(c_out)
         );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n1) );
  XOR2D1BWP16P90LVT U3 ( .A1(n2), .A2(b), .Z(net1026) );
  INVD1BWP16P90LVT U4 ( .I(a), .ZN(n2) );
  INVD1BWP16P90LVT U5 ( .I(b), .ZN(n3) );
  DEL025D1BWP16P90 U6 ( .I(n1), .Z(net1435) );
  XNR2D1BWP16P90LVT U7 ( .A1(net1381), .A2(net1026), .ZN(sum) );
  INVD1BWP16P90 U8 ( .I(net1435), .ZN(net1381) );
endmodule


module FA_28 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP20P90 U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_29 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_30 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(a), .A2(b), .ZN(n5) );
  XNR2D1BWP16P90LVT U2 ( .A1(n1), .A2(n5), .ZN(sum) );
  DEL025D1BWP16P90 U3 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U4 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U5 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_31 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5, n6, n7, n8;

  ND2D1BWP16P90LVT U1 ( .A1(a), .A2(b), .ZN(n3) );
  CKND12BWP16P90LVT U2 ( .I(b), .ZN(n2) );
  CKND8BWP16P90LVT U3 ( .I(a), .ZN(n1) );
  XNR2D1BWP20P90 U4 ( .A1(n6), .A2(n8), .ZN(sum) );
  CKND2D4BWP16P90LVT U5 ( .A1(n1), .A2(n2), .ZN(n4) );
  INVD4BWP16P90LVT U6 ( .I(c_in), .ZN(n7) );
  ND2D2BWP16P90LVT U7 ( .A1(n3), .A2(n4), .ZN(n8) );
  DEL025D1BWP16P90 U8 ( .I(n7), .Z(n5) );
  INVD1BWP16P90 U9 ( .I(n5), .ZN(n6) );
  OAI22D4BWP16P90LVT U10 ( .A1(n7), .A2(n8), .B1(n1), .B2(n2), .ZN(c_out) );
endmodule


module RCA_32bit ( sum, c_out, a, b, c_in );
  output [31:0] sum;
  input [31:0] a;
  input [31:0] b;
  input c_in;
  output c_out;

  wire   [30:0] carry;

  FA_0 FA0 ( .sum(sum[0]), .c_out(carry[0]), .a(a[0]), .b(b[0]), .c_in(c_in)
         );
  FA_31 FA_Stages_1__FA_inst ( .sum(sum[1]), .c_out(carry[1]), .a(a[1]), .b(
        b[1]), .c_in(carry[0]) );
  FA_30 FA_Stages_2__FA_inst ( .sum(sum[2]), .c_out(carry[2]), .a(a[2]), .b(
        b[2]), .c_in(carry[1]) );
  FA_29 FA_Stages_3__FA_inst ( .sum(sum[3]), .c_out(carry[3]), .a(a[3]), .b(
        b[3]), .c_in(carry[2]) );
  FA_28 FA_Stages_4__FA_inst ( .sum(sum[4]), .c_out(carry[4]), .a(a[4]), .b(
        b[4]), .c_in(carry[3]) );
  FA_27 FA_Stages_5__FA_inst ( .sum(sum[5]), .c_out(carry[5]), .a(a[5]), .b(
        b[5]), .c_in(carry[4]) );
  FA_26 FA_Stages_6__FA_inst ( .sum(sum[6]), .c_out(carry[6]), .a(a[6]), .b(
        b[6]), .c_in(carry[5]) );
  FA_25 FA_Stages_7__FA_inst ( .sum(sum[7]), .c_out(carry[7]), .a(a[7]), .b(
        b[7]), .c_in(carry[6]) );
  FA_24 FA_Stages_8__FA_inst ( .sum(sum[8]), .c_out(carry[8]), .a(a[8]), .b(
        b[8]), .c_in(carry[7]) );
  FA_23 FA_Stages_9__FA_inst ( .sum(sum[9]), .c_out(carry[9]), .a(a[9]), .b(
        b[9]), .c_in(carry[8]) );
  FA_22 FA_Stages_10__FA_inst ( .sum(sum[10]), .c_out(carry[10]), .a(a[10]), 
        .b(b[10]), .c_in(carry[9]) );
  FA_21 FA_Stages_11__FA_inst ( .sum(sum[11]), .c_out(carry[11]), .a(a[11]), 
        .b(b[11]), .c_in(carry[10]) );
  FA_20 FA_Stages_12__FA_inst ( .sum(sum[12]), .c_out(carry[12]), .a(a[12]), 
        .b(b[12]), .c_in(carry[11]) );
  FA_19 FA_Stages_13__FA_inst ( .sum(sum[13]), .c_out(carry[13]), .a(a[13]), 
        .b(b[13]), .c_in(carry[12]) );
  FA_18 FA_Stages_14__FA_inst ( .sum(sum[14]), .c_out(carry[14]), .a(a[14]), 
        .b(b[14]), .c_in(carry[13]) );
  FA_17 FA_Stages_15__FA_inst ( .sum(sum[15]), .c_out(carry[15]), .a(a[15]), 
        .b(b[15]), .c_in(carry[14]) );
  FA_16 FA_Stages_16__FA_inst ( .sum(sum[16]), .c_out(carry[16]), .a(a[16]), 
        .b(b[16]), .c_in(carry[15]) );
  FA_15 FA_Stages_17__FA_inst ( .sum(sum[17]), .c_out(carry[17]), .a(a[17]), 
        .b(b[17]), .c_in(carry[16]) );
  FA_14 FA_Stages_18__FA_inst ( .sum(sum[18]), .c_out(carry[18]), .a(a[18]), 
        .b(b[18]), .c_in(carry[17]) );
  FA_13 FA_Stages_19__FA_inst ( .sum(sum[19]), .c_out(carry[19]), .a(a[19]), 
        .b(b[19]), .c_in(carry[18]) );
  FA_12 FA_Stages_20__FA_inst ( .sum(sum[20]), .c_out(carry[20]), .a(a[20]), 
        .b(b[20]), .c_in(carry[19]) );
  FA_11 FA_Stages_21__FA_inst ( .sum(sum[21]), .c_out(carry[21]), .a(a[21]), 
        .b(b[21]), .c_in(carry[20]) );
  FA_10 FA_Stages_22__FA_inst ( .sum(sum[22]), .c_out(carry[22]), .a(a[22]), 
        .b(b[22]), .c_in(carry[21]) );
  FA_9 FA_Stages_23__FA_inst ( .sum(sum[23]), .c_out(carry[23]), .a(a[23]), 
        .b(b[23]), .c_in(carry[22]) );
  FA_8 FA_Stages_24__FA_inst ( .sum(sum[24]), .c_out(carry[24]), .a(a[24]), 
        .b(b[24]), .c_in(carry[23]) );
  FA_7 FA_Stages_25__FA_inst ( .sum(sum[25]), .c_out(carry[25]), .a(a[25]), 
        .b(b[25]), .c_in(carry[24]) );
  FA_6 FA_Stages_26__FA_inst ( .sum(sum[26]), .c_out(carry[26]), .a(a[26]), 
        .b(b[26]), .c_in(carry[25]) );
  FA_5 FA_Stages_27__FA_inst ( .sum(sum[27]), .c_out(carry[27]), .a(a[27]), 
        .b(b[27]), .c_in(carry[26]) );
  FA_4 FA_Stages_28__FA_inst ( .sum(sum[28]), .c_out(carry[28]), .a(a[28]), 
        .b(b[28]), .c_in(carry[27]) );
  FA_3 FA_Stages_29__FA_inst ( .sum(sum[29]), .c_out(carry[29]), .a(a[29]), 
        .b(b[29]), .c_in(carry[28]) );
  FA_2 FA_Stages_30__FA_inst ( .sum(sum[30]), .c_out(carry[30]), .a(a[30]), 
        .b(b[30]), .c_in(carry[29]) );
  FA_1 FA_Stages_31__FA_inst ( .sum(sum[31]), .c_out(c_out), .a(a[31]), .b(
        b[31]), .c_in(carry[30]) );
endmodule


module D_FF_0 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_1 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_2 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_3 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_4 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_5 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_6 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_7 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_8 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_9 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_10 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_11 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_12 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_13 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_14 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_15 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_16 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_17 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_18 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_19 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_20 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_21 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_22 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_23 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_24 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_25 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_26 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_27 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_28 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_29 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_30 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_31 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module D_FF_32 ( q, d, clk );
  input d, clk;
  output q;


  DFQD2BWP16P90LVT q_reg ( .D(d), .CP(clk), .Q(q) );
endmodule


module adder_structure_reg ( s, co, a, b, ci, clk );
  output [31:0] s;
  input [31:0] a;
  input [31:0] b;
  input ci, clk;
  output co;
  wire   carry_out;
  wire   [31:0] sum;

  RCA_32bit U1 ( .sum(sum), .c_out(carry_out), .a(a), .b(b), .c_in(ci) );
  D_FF_0 store_sum_0__sum_ff ( .q(s[0]), .d(sum[0]), .clk(clk) );
  D_FF_32 store_sum_1__sum_ff ( .q(s[1]), .d(sum[1]), .clk(clk) );
  D_FF_31 store_sum_2__sum_ff ( .q(s[2]), .d(sum[2]), .clk(clk) );
  D_FF_30 store_sum_3__sum_ff ( .q(s[3]), .d(sum[3]), .clk(clk) );
  D_FF_29 store_sum_4__sum_ff ( .q(s[4]), .d(sum[4]), .clk(clk) );
  D_FF_28 store_sum_5__sum_ff ( .q(s[5]), .d(sum[5]), .clk(clk) );
  D_FF_27 store_sum_6__sum_ff ( .q(s[6]), .d(sum[6]), .clk(clk) );
  D_FF_26 store_sum_7__sum_ff ( .q(s[7]), .d(sum[7]), .clk(clk) );
  D_FF_25 store_sum_8__sum_ff ( .q(s[8]), .d(sum[8]), .clk(clk) );
  D_FF_24 store_sum_9__sum_ff ( .q(s[9]), .d(sum[9]), .clk(clk) );
  D_FF_23 store_sum_10__sum_ff ( .q(s[10]), .d(sum[10]), .clk(clk) );
  D_FF_22 store_sum_11__sum_ff ( .q(s[11]), .d(sum[11]), .clk(clk) );
  D_FF_21 store_sum_12__sum_ff ( .q(s[12]), .d(sum[12]), .clk(clk) );
  D_FF_20 store_sum_13__sum_ff ( .q(s[13]), .d(sum[13]), .clk(clk) );
  D_FF_19 store_sum_14__sum_ff ( .q(s[14]), .d(sum[14]), .clk(clk) );
  D_FF_18 store_sum_15__sum_ff ( .q(s[15]), .d(sum[15]), .clk(clk) );
  D_FF_17 store_sum_16__sum_ff ( .q(s[16]), .d(sum[16]), .clk(clk) );
  D_FF_16 store_sum_17__sum_ff ( .q(s[17]), .d(sum[17]), .clk(clk) );
  D_FF_15 store_sum_18__sum_ff ( .q(s[18]), .d(sum[18]), .clk(clk) );
  D_FF_14 store_sum_19__sum_ff ( .q(s[19]), .d(sum[19]), .clk(clk) );
  D_FF_13 store_sum_20__sum_ff ( .q(s[20]), .d(sum[20]), .clk(clk) );
  D_FF_12 store_sum_21__sum_ff ( .q(s[21]), .d(sum[21]), .clk(clk) );
  D_FF_11 store_sum_22__sum_ff ( .q(s[22]), .d(sum[22]), .clk(clk) );
  D_FF_10 store_sum_23__sum_ff ( .q(s[23]), .d(sum[23]), .clk(clk) );
  D_FF_9 store_sum_24__sum_ff ( .q(s[24]), .d(sum[24]), .clk(clk) );
  D_FF_8 store_sum_25__sum_ff ( .q(s[25]), .d(sum[25]), .clk(clk) );
  D_FF_7 store_sum_26__sum_ff ( .q(s[26]), .d(sum[26]), .clk(clk) );
  D_FF_6 store_sum_27__sum_ff ( .q(s[27]), .d(sum[27]), .clk(clk) );
  D_FF_5 store_sum_28__sum_ff ( .q(s[28]), .d(sum[28]), .clk(clk) );
  D_FF_4 store_sum_29__sum_ff ( .q(s[29]), .d(sum[29]), .clk(clk) );
  D_FF_3 store_sum_30__sum_ff ( .q(s[30]), .d(sum[30]), .clk(clk) );
  D_FF_2 store_sum_31__sum_ff ( .q(s[31]), .d(sum[31]), .clk(clk) );
  D_FF_1 carry_ff ( .q(co), .d(carry_out), .clk(clk) );
endmodule

