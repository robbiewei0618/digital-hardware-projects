/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : V-2023.12
// Date      : Thu Oct  3 16:50:53 2024
/////////////////////////////////////////////////////////////


module FA_0 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11;

  ND2D2BWP16P90LVT U1 ( .A1(n1), .A2(c_in), .ZN(n8) );
  CKND2D4BWP16P90LVT U2 ( .A1(n11), .A2(n5), .ZN(c_out) );
  CKND1BWP16P90LVT U3 ( .I(a), .ZN(n4) );
  CKND1BWP16P90LVT U4 ( .I(b), .ZN(n1) );
  ND2D1BWP16P90LVT U5 ( .A1(n4), .A2(c_in), .ZN(n3) );
  CKND8BWP16P90LVT U6 ( .I(c_in), .ZN(n2) );
  ND2D2BWP16P90LVT U7 ( .A1(n3), .A2(n8), .ZN(n9) );
  ND2D1BWP16P90LVT U8 ( .A1(n6), .A2(n7), .ZN(n10) );
  NR2D1BWP16P90LVT U9 ( .A1(a), .A2(n2), .ZN(n6) );
  NR2D1BWP16P90LVT U10 ( .A1(n2), .A2(b), .ZN(n7) );
  OR2D1BWP16P90LVT U11 ( .A1(n4), .A2(n1), .Z(n5) );
  ND2D2BWP16P90LVT U12 ( .A1(n10), .A2(n9), .ZN(n11) );
  XOR3D1BWP16P90LVT U13 ( .A1(b), .A2(a), .A3(c_in), .Z(sum) );
endmodule


module FA_1 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4;

  XNR2D1BWP16P90LVT U1 ( .A1(c_in), .A2(n4), .ZN(sum) );
  XOR2D1BWP16P90LVT U2 ( .A1(n2), .A2(b), .Z(n4) );
  INVD1BWP16P90LVT U3 ( .I(a), .ZN(n2) );
  INVD1BWP16P90LVT U4 ( .I(c_in), .ZN(n3) );
  INVD1BWP16P90LVT U5 ( .I(b), .ZN(n1) );
  OAI22D1BWP16P90LVT U6 ( .A1(n3), .A2(n4), .B1(n2), .B2(n1), .ZN(c_out) );
endmodule


module FA_2 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4;

  XNR2D2BWP16P90LVT U1 ( .A1(n4), .A2(c_in), .ZN(sum) );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n3) );
  OAI22D4BWP16P90LVT U3 ( .A1(n3), .A2(n4), .B1(n2), .B2(n1), .ZN(c_out) );
  XOR2D1BWP16P90LVT U4 ( .A1(n2), .A2(b), .Z(n4) );
  INVD1BWP16P90LVT U5 ( .I(a), .ZN(n2) );
  INVD1BWP16P90LVT U6 ( .I(b), .ZN(n1) );
endmodule


module FA_3 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90LVT U1 ( .I(c_in), .Z(n1) );
  XNR2D1BWP16P90LVT U2 ( .A1(n5), .A2(n1), .ZN(sum) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_4 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5, n6;

  DEL025D1BWP16P90LVT U1 ( .I(n5), .Z(n1) );
  XNR2D1BWP16P90LVT U2 ( .A1(n2), .A2(n6), .ZN(sum) );
  INVD1BWP16P90 U3 ( .I(n1), .ZN(n2) );
  INVD4BWP16P90LVT U4 ( .I(c_in), .ZN(n5) );
  OAI22D4BWP16P90LVT U5 ( .A1(n5), .A2(n6), .B1(n4), .B2(n3), .ZN(c_out) );
  XOR2D1BWP16P90LVT U6 ( .A1(n4), .A2(b), .Z(n6) );
  INVD1BWP16P90LVT U7 ( .I(a), .ZN(n4) );
  INVD1BWP16P90LVT U8 ( .I(b), .ZN(n3) );
endmodule


module FA_5 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5, n6;

  DEL025D1BWP16P90 U1 ( .I(n5), .Z(n1) );
  INVD1BWP16P90 U2 ( .I(n1), .ZN(n2) );
  XNR2D1BWP16P90LVT U3 ( .A1(n2), .A2(n6), .ZN(sum) );
  INVD4BWP16P90LVT U4 ( .I(c_in), .ZN(n5) );
  OAI22D4BWP16P90LVT U5 ( .A1(n5), .A2(n6), .B1(n4), .B2(n3), .ZN(c_out) );
  XOR2D1BWP16P90LVT U6 ( .A1(n4), .A2(b), .Z(n6) );
  INVD1BWP16P90LVT U7 ( .I(a), .ZN(n4) );
  INVD1BWP16P90LVT U8 ( .I(b), .ZN(n3) );
endmodule


module FA_6 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n4) );
  XNR2D1BWP16P90LVT U3 ( .A1(n1), .A2(n5), .ZN(sum) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_7 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  XNR2D1BWP16P90LVT U2 ( .A1(n1), .A2(n5), .ZN(sum) );
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

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n4) );
  XNR2D1BWP16P90LVT U3 ( .A1(n1), .A2(n5), .ZN(sum) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_9 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  INVD1BWP16P90 U1 ( .I(n4), .ZN(n1) );
  XNR2D1BWP16P90LVT U2 ( .A1(n1), .A2(n5), .ZN(sum) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_10 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3;

  XOR2D1BWP16P90LVT U1 ( .A1(n2), .A2(n3), .Z(sum) );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n2) );
  MOAI22D4BWP16P90LVT U3 ( .A1(n2), .A2(n3), .B1(a), .B2(b), .ZN(c_out) );
  XOR2D1BWP16P90LVT U4 ( .A1(n1), .A2(b), .Z(n3) );
  INVD1BWP16P90LVT U5 ( .I(a), .ZN(n1) );
endmodule


module FA_11 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4;

  XOR2D1BWP16P90LVT U1 ( .A1(n4), .A2(n3), .Z(sum) );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n3) );
  OAI22D4BWP16P90LVT U3 ( .A1(n4), .A2(n3), .B1(n2), .B2(n1), .ZN(c_out) );
  XOR2D1BWP16P90LVT U4 ( .A1(n2), .A2(b), .Z(n4) );
  INVD1BWP16P90LVT U5 ( .I(a), .ZN(n2) );
  INVD1BWP16P90LVT U6 ( .I(b), .ZN(n1) );
endmodule


module FA_12 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(n4), .Z(n1) );
  XOR2D2BWP16P90 U2 ( .A1(n5), .A2(n1), .Z(sum) );
  OAI22D4BWP16P90LVT U3 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  CKND2BWP16P90LVT U4 ( .I(c_in), .ZN(n4) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_13 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  MOAI22D2BWP16P90LVT U2 ( .A1(n3), .A2(n4), .B1(a), .B2(b), .ZN(c_out) );
  XNR2D1BWP16P90LVT U3 ( .A1(n1), .A2(n4), .ZN(sum) );
  CKND2BWP16P90LVT U4 ( .I(c_in), .ZN(n3) );
  XOR2D1BWP16P90LVT U5 ( .A1(n2), .A2(b), .Z(n4) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n2) );
endmodule


module FA_14 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  INVD1BWP16P90 U1 ( .I(n4), .ZN(n1) );
  XNR2D1BWP16P90LVT U2 ( .A1(n1), .A2(n5), .ZN(sum) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_15 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(n4), .Z(n1) );
  INVD1BWP16P90 U2 ( .I(n1), .ZN(n2) );
  CKND2BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  XNR2D1BWP16P90LVT U4 ( .A1(n2), .A2(n5), .ZN(sum) );
  MOAI22D4BWP16P90LVT U5 ( .A1(n4), .A2(n5), .B1(a), .B2(b), .ZN(c_out) );
  XOR2D1BWP16P90LVT U6 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U7 ( .I(a), .ZN(n3) );
endmodule


module FA_16 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4;

  INVD1BWP16P90 U1 ( .I(n3), .ZN(n1) );
  MOAI22D2BWP16P90LVT U2 ( .A1(n3), .A2(n4), .B1(a), .B2(b), .ZN(c_out) );
  XNR2D1BWP16P90LVT U3 ( .A1(n1), .A2(n4), .ZN(sum) );
  CKND2BWP16P90LVT U4 ( .I(c_in), .ZN(n3) );
  XOR2D1BWP16P90LVT U5 ( .A1(n2), .A2(b), .Z(n4) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n2) );
endmodule


module FA_17 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  IND2D2BWP16P90LVT U2 ( .A1(n5), .B1(c_in), .ZN(n2) );
  ND2D1BWP16P90LVT U3 ( .A1(a), .A2(b), .ZN(n3) );
  XNR2D1BWP16P90LVT U4 ( .A1(n1), .A2(n5), .ZN(sum) );
  ND2D2BWP16P90LVT U5 ( .A1(n2), .A2(n3), .ZN(c_out) );
  XOR2D1BWP16P90LVT U6 ( .A1(n4), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U7 ( .I(a), .ZN(n4) );
endmodule


module FA_18 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  OAI22D2BWP16P90LVT U2 ( .A1(n5), .A2(n4), .B1(n3), .B2(n2), .ZN(c_out) );
  INVD1BWP16P90 U3 ( .I(n4), .ZN(n1) );
  INVD4BWP16P90LVT U4 ( .I(c_in), .ZN(n4) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_19 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  CKND2BWP16P90LVT U1 ( .I(c_in), .ZN(n4) );
  BUFFD2BWP16P90 U2 ( .I(c_in), .Z(n1) );
  XNR2D1BWP16P90LVT U3 ( .A1(n1), .A2(n5), .ZN(sum) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_20 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5, n6;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  ND2D2BWP16P90LVT U2 ( .A1(n2), .A2(n3), .ZN(c_out) );
  ND2D1BWP16P90LVT U3 ( .A1(a), .A2(b), .ZN(n3) );
  ND2D2BWP16P90LVT U4 ( .A1(c_in), .A2(n4), .ZN(n2) );
  XNR2D1BWP16P90LVT U5 ( .A1(n1), .A2(n6), .ZN(sum) );
  CKND1BWP16P90LVT U6 ( .I(n6), .ZN(n4) );
  XOR2D1BWP16P90LVT U7 ( .A1(n5), .A2(b), .Z(n6) );
  INVD1BWP16P90LVT U8 ( .I(a), .ZN(n5) );
endmodule


module FA_21 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n4) );
  XNR2D1BWP16P90LVT U3 ( .A1(n1), .A2(n5), .ZN(sum) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_22 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  INVD1BWP16P90 U2 ( .I(n4), .ZN(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n5), .A2(n4), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_23 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  XNR2D1BWP16P90LVT U2 ( .A1(n1), .A2(n5), .ZN(sum) );
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
  INVD1BWP16P90 U2 ( .I(n4), .ZN(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n5), .A2(n4), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_25 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  XNR2D1BWP16P90LVT U2 ( .A1(n1), .A2(n5), .ZN(sum) );
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
  INVD1BWP16P90 U2 ( .I(n4), .ZN(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n5), .A2(n4), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_27 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  INVD1BWP16P90 U2 ( .I(n4), .ZN(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n5), .A2(n4), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_28 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XNR2D1BWP16P90LVT U1 ( .A1(n1), .A2(n5), .ZN(sum) );
  INVD1BWP16P90 U2 ( .I(n4), .ZN(n1) );
  INVD4BWP16P90LVT U3 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U4 ( .A1(n5), .A2(n4), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_29 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  XNR2D1BWP16P90LVT U2 ( .A1(n1), .A2(n5), .ZN(sum) );
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

  DEL025D1BWP16P90 U1 ( .I(c_in), .Z(n1) );
  INVD4BWP16P90LVT U2 ( .I(c_in), .ZN(n4) );
  XNR2D1BWP16P90LVT U3 ( .A1(n1), .A2(n5), .ZN(sum) );
  OAI22D4BWP16P90LVT U4 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  XOR2D1BWP16P90LVT U5 ( .A1(n3), .A2(b), .Z(n5) );
  INVD1BWP16P90LVT U6 ( .I(a), .ZN(n3) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module FA_31 ( sum, c_out, a, b, c_in );
  input a, b, c_in;
  output sum, c_out;
  wire   n1, n2, n3, n4, n5;

  XOR2D2BWP16P90LVT U1 ( .A1(n3), .A2(b), .Z(n5) );
  DEL025D1BWP16P90 U2 ( .I(c_in), .Z(n1) );
  CKND1BWP16P90LVT U3 ( .I(a), .ZN(n3) );
  XNR2D1BWP20P90 U4 ( .A1(n1), .A2(n5), .ZN(sum) );
  CKND2BWP16P90LVT U5 ( .I(c_in), .ZN(n4) );
  OAI22D4BWP16P90LVT U6 ( .A1(n4), .A2(n5), .B1(n3), .B2(n2), .ZN(c_out) );
  INVD1BWP16P90LVT U7 ( .I(b), .ZN(n2) );
endmodule


module adder_structure ( s, co, a, b, ci );
  output [31:0] s;
  input [31:0] a;
  input [31:0] b;
  input ci;
  output co;

  wire   [30:0] carry;

  FA_0 FA0 ( .sum(s[0]), .c_out(carry[0]), .a(a[0]), .b(b[0]), .c_in(ci) );
  FA_31 FA_Stages_1__FA_inst ( .sum(s[1]), .c_out(carry[1]), .a(a[1]), .b(b[1]), .c_in(carry[0]) );
  FA_30 FA_Stages_2__FA_inst ( .sum(s[2]), .c_out(carry[2]), .a(a[2]), .b(b[2]), .c_in(carry[1]) );
  FA_29 FA_Stages_3__FA_inst ( .sum(s[3]), .c_out(carry[3]), .a(a[3]), .b(b[3]), .c_in(carry[2]) );
  FA_28 FA_Stages_4__FA_inst ( .sum(s[4]), .c_out(carry[4]), .a(a[4]), .b(b[4]), .c_in(carry[3]) );
  FA_27 FA_Stages_5__FA_inst ( .sum(s[5]), .c_out(carry[5]), .a(a[5]), .b(b[5]), .c_in(carry[4]) );
  FA_26 FA_Stages_6__FA_inst ( .sum(s[6]), .c_out(carry[6]), .a(a[6]), .b(b[6]), .c_in(carry[5]) );
  FA_25 FA_Stages_7__FA_inst ( .sum(s[7]), .c_out(carry[7]), .a(a[7]), .b(b[7]), .c_in(carry[6]) );
  FA_24 FA_Stages_8__FA_inst ( .sum(s[8]), .c_out(carry[8]), .a(a[8]), .b(b[8]), .c_in(carry[7]) );
  FA_23 FA_Stages_9__FA_inst ( .sum(s[9]), .c_out(carry[9]), .a(a[9]), .b(b[9]), .c_in(carry[8]) );
  FA_22 FA_Stages_10__FA_inst ( .sum(s[10]), .c_out(carry[10]), .a(a[10]), .b(
        b[10]), .c_in(carry[9]) );
  FA_21 FA_Stages_11__FA_inst ( .sum(s[11]), .c_out(carry[11]), .a(a[11]), .b(
        b[11]), .c_in(carry[10]) );
  FA_20 FA_Stages_12__FA_inst ( .sum(s[12]), .c_out(carry[12]), .a(a[12]), .b(
        b[12]), .c_in(carry[11]) );
  FA_19 FA_Stages_13__FA_inst ( .sum(s[13]), .c_out(carry[13]), .a(a[13]), .b(
        b[13]), .c_in(carry[12]) );
  FA_18 FA_Stages_14__FA_inst ( .sum(s[14]), .c_out(carry[14]), .a(a[14]), .b(
        b[14]), .c_in(carry[13]) );
  FA_17 FA_Stages_15__FA_inst ( .sum(s[15]), .c_out(carry[15]), .a(a[15]), .b(
        b[15]), .c_in(carry[14]) );
  FA_16 FA_Stages_16__FA_inst ( .sum(s[16]), .c_out(carry[16]), .a(a[16]), .b(
        b[16]), .c_in(carry[15]) );
  FA_15 FA_Stages_17__FA_inst ( .sum(s[17]), .c_out(carry[17]), .a(a[17]), .b(
        b[17]), .c_in(carry[16]) );
  FA_14 FA_Stages_18__FA_inst ( .sum(s[18]), .c_out(carry[18]), .a(a[18]), .b(
        b[18]), .c_in(carry[17]) );
  FA_13 FA_Stages_19__FA_inst ( .sum(s[19]), .c_out(carry[19]), .a(a[19]), .b(
        b[19]), .c_in(carry[18]) );
  FA_12 FA_Stages_20__FA_inst ( .sum(s[20]), .c_out(carry[20]), .a(a[20]), .b(
        b[20]), .c_in(carry[19]) );
  FA_11 FA_Stages_21__FA_inst ( .sum(s[21]), .c_out(carry[21]), .a(a[21]), .b(
        b[21]), .c_in(carry[20]) );
  FA_10 FA_Stages_22__FA_inst ( .sum(s[22]), .c_out(carry[22]), .a(a[22]), .b(
        b[22]), .c_in(carry[21]) );
  FA_9 FA_Stages_23__FA_inst ( .sum(s[23]), .c_out(carry[23]), .a(a[23]), .b(
        b[23]), .c_in(carry[22]) );
  FA_8 FA_Stages_24__FA_inst ( .sum(s[24]), .c_out(carry[24]), .a(a[24]), .b(
        b[24]), .c_in(carry[23]) );
  FA_7 FA_Stages_25__FA_inst ( .sum(s[25]), .c_out(carry[25]), .a(a[25]), .b(
        b[25]), .c_in(carry[24]) );
  FA_6 FA_Stages_26__FA_inst ( .sum(s[26]), .c_out(carry[26]), .a(a[26]), .b(
        b[26]), .c_in(carry[25]) );
  FA_5 FA_Stages_27__FA_inst ( .sum(s[27]), .c_out(carry[27]), .a(a[27]), .b(
        b[27]), .c_in(carry[26]) );
  FA_4 FA_Stages_28__FA_inst ( .sum(s[28]), .c_out(carry[28]), .a(a[28]), .b(
        b[28]), .c_in(carry[27]) );
  FA_3 FA_Stages_29__FA_inst ( .sum(s[29]), .c_out(carry[29]), .a(a[29]), .b(
        b[29]), .c_in(carry[28]) );
  FA_2 FA_Stages_30__FA_inst ( .sum(s[30]), .c_out(carry[30]), .a(a[30]), .b(
        b[30]), .c_in(carry[29]) );
  FA_1 FA_Stages_31__FA_inst ( .sum(s[31]), .c_out(co), .a(a[31]), .b(b[31]), 
        .c_in(carry[30]) );
endmodule

