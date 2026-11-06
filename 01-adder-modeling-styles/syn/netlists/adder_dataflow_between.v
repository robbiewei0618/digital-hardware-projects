/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : V-2023.12
// Date      : Sat Oct  5 19:44:47 2024
/////////////////////////////////////////////////////////////


module adder_dataflow_DW01_add_1 ( CI, SUM, \A[31] , \A[30] , \A[29] , \A[28] , 
        \A[27] , \A[26] , \A[25] , \A[24] , \A[23] , \A[22] , \A[21] , \A[20] , 
        \A[19] , \A[18] , \A[17] , \A[16] , \A[15] , \A[14] , \A[13] , \A[12] , 
        \A[11] , \A[10] , \A[9] , \A[8] , \A[7] , \A[6] , \A[5] , \A[4] , 
        \A[3] , \A[2] , \A[1] , \A[0] , \B[31] , \B[30] , \B[29] , \B[28] , 
        \B[27] , \B[26] , \B[25] , \B[24] , \B[23] , \B[22] , \B[21] , \B[20] , 
        \B[19] , \B[18] , \B[17] , \B[16] , \B[15] , \B[14] , \B[13] , \B[12] , 
        \B[11] , \B[10] , \B[9] , \B[8] , \B[7] , \B[6] , \B[5] , \B[4] , 
        \B[3] , \B[2] , \B[1] , \B[0]  );
  output [32:0] SUM;
  input CI, \A[31] , \A[30] , \A[29] , \A[28] , \A[27] , \A[26] , \A[25] ,
         \A[24] , \A[23] , \A[22] , \A[21] , \A[20] , \A[19] , \A[18] ,
         \A[17] , \A[16] , \A[15] , \A[14] , \A[13] , \A[12] , \A[11] ,
         \A[10] , \A[9] , \A[8] , \A[7] , \A[6] , \A[5] , \A[4] , \A[3] ,
         \A[2] , \A[1] , \A[0] , \B[31] , \B[30] , \B[29] , \B[28] , \B[27] ,
         \B[26] , \B[25] , \B[24] , \B[23] , \B[22] , \B[21] , \B[20] ,
         \B[19] , \B[18] , \B[17] , \B[16] , \B[15] , \B[14] , \B[13] ,
         \B[12] , \B[11] , \B[10] , \B[9] , \B[8] , \B[7] , \B[6] , \B[5] ,
         \B[4] , \B[3] , \B[2] , \B[1] , \B[0] ;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n29, n30, n31,
         n32, n37, n38, n39, n40, n41, n43, n45, n46, n47, n48, n49, n51, n53,
         n54, n55, n56, n57, n59, n61, n62, n63, n64, n65, n67, n69, n70, n71,
         n72, n73, n75, n77, n78, n79, n80, n81, n83, n85, n86, n87, n88, n89,
         n91, n93, n94, n95, n96, n97, n99, n101, n102, n103, n104, n105, n107,
         n109, n110, n111, n112, n113, n115, n117, n118, n119, n120, n121,
         n123, n125, n126, n127, n128, n129, n130, n131, n132, n133, n134,
         n135, n136, n137, n138, n139, n140, n141, n144, n146, n148, n150,
         n152, n154, n156, n158, n160, n162, n164, n166, n167, n168, n169,
         n276, n277, n278, n279, n280, n281, n282, n283, n284, n285, n286,
         n287, n288, n289, n290, n291, n292, n293, n294, n295, n296, n297,
         n298, n299;
  wire   [31:0] B;
  wire   [31:0] A;
  assign B[31] = \B[31] ;
  assign B[30] = \B[30] ;
  assign B[29] = \B[29] ;
  assign B[28] = \B[28] ;
  assign B[27] = \B[27] ;
  assign B[26] = \B[26] ;
  assign B[25] = \B[25] ;
  assign B[24] = \B[24] ;
  assign B[23] = \B[23] ;
  assign B[22] = \B[22] ;
  assign B[21] = \B[21] ;
  assign B[20] = \B[20] ;
  assign B[19] = \B[19] ;
  assign B[18] = \B[18] ;
  assign B[17] = \B[17] ;
  assign B[16] = \B[16] ;
  assign B[15] = \B[15] ;
  assign B[14] = \B[14] ;
  assign B[13] = \B[13] ;
  assign B[12] = \B[12] ;
  assign B[11] = \B[11] ;
  assign B[10] = \B[10] ;
  assign B[9] = \B[9] ;
  assign B[8] = \B[8] ;
  assign B[7] = \B[7] ;
  assign B[6] = \B[6] ;
  assign B[5] = \B[5] ;
  assign B[4] = \B[4] ;
  assign B[3] = \B[3] ;
  assign B[2] = \B[2] ;
  assign B[1] = \B[1] ;
  assign B[0] = \B[0] ;
  assign A[31] = \A[31] ;
  assign A[30] = \A[30] ;
  assign A[29] = \A[29] ;
  assign A[28] = \A[28] ;
  assign A[27] = \A[27] ;
  assign A[26] = \A[26] ;
  assign A[25] = \A[25] ;
  assign A[24] = \A[24] ;
  assign A[23] = \A[23] ;
  assign A[22] = \A[22] ;
  assign A[21] = \A[21] ;
  assign A[20] = \A[20] ;
  assign A[19] = \A[19] ;
  assign A[18] = \A[18] ;
  assign A[17] = \A[17] ;
  assign A[16] = \A[16] ;
  assign A[15] = \A[15] ;
  assign A[14] = \A[14] ;
  assign A[13] = \A[13] ;
  assign A[12] = \A[12] ;
  assign A[11] = \A[11] ;
  assign A[10] = \A[10] ;
  assign A[9] = \A[9] ;
  assign A[8] = \A[8] ;
  assign A[7] = \A[7] ;
  assign A[6] = \A[6] ;
  assign A[5] = \A[5] ;
  assign A[4] = \A[4] ;
  assign A[3] = \A[3] ;
  assign A[2] = \A[2] ;
  assign A[1] = \A[1] ;
  assign A[0] = \A[0] ;

  FA1D1BWP16P90LVT U2 ( .A(B[31]), .B(A[31]), .CI(n29), .CO(SUM[32]), .S(
        SUM[31]) );
  ND2D1BWP16P90LVT U12 ( .A1(n299), .A2(n37), .ZN(n1) );
  ND2D1BWP16P90LVT U15 ( .A1(A[26]), .A2(B[26]), .ZN(n37) );
  ND2D1BWP16P90LVT U18 ( .A1(n144), .A2(n40), .ZN(n2) );
  ND2D1BWP16P90LVT U21 ( .A1(A[25]), .A2(B[25]), .ZN(n40) );
  ND2D1BWP16P90LVT U26 ( .A1(n298), .A2(n45), .ZN(n3) );
  ND2D1BWP16P90LVT U29 ( .A1(A[24]), .A2(B[24]), .ZN(n45) );
  ND2D1BWP16P90LVT U32 ( .A1(n146), .A2(n48), .ZN(n4) );
  ND2D1BWP16P90LVT U35 ( .A1(A[23]), .A2(B[23]), .ZN(n48) );
  ND2D1BWP16P90LVT U40 ( .A1(n297), .A2(n53), .ZN(n5) );
  ND2D1BWP16P90LVT U43 ( .A1(A[22]), .A2(B[22]), .ZN(n53) );
  ND2D1BWP16P90LVT U46 ( .A1(n148), .A2(n56), .ZN(n6) );
  ND2D1BWP16P90LVT U49 ( .A1(A[21]), .A2(B[21]), .ZN(n56) );
  ND2D1BWP16P90LVT U54 ( .A1(n296), .A2(n61), .ZN(n7) );
  ND2D1BWP16P90LVT U57 ( .A1(A[20]), .A2(B[20]), .ZN(n61) );
  ND2D1BWP16P90LVT U60 ( .A1(n150), .A2(n64), .ZN(n8) );
  ND2D1BWP16P90LVT U63 ( .A1(A[19]), .A2(B[19]), .ZN(n64) );
  ND2D1BWP16P90LVT U68 ( .A1(n295), .A2(n69), .ZN(n9) );
  ND2D1BWP16P90LVT U71 ( .A1(A[18]), .A2(B[18]), .ZN(n69) );
  ND2D1BWP16P90LVT U74 ( .A1(n152), .A2(n72), .ZN(n10) );
  ND2D1BWP16P90LVT U77 ( .A1(A[17]), .A2(B[17]), .ZN(n72) );
  ND2D1BWP16P90LVT U82 ( .A1(n294), .A2(n77), .ZN(n11) );
  ND2D1BWP16P90LVT U85 ( .A1(A[16]), .A2(B[16]), .ZN(n77) );
  ND2D1BWP16P90LVT U88 ( .A1(n154), .A2(n80), .ZN(n12) );
  ND2D1BWP16P90LVT U91 ( .A1(A[15]), .A2(B[15]), .ZN(n80) );
  ND2D1BWP16P90LVT U96 ( .A1(n293), .A2(n85), .ZN(n13) );
  ND2D1BWP16P90LVT U99 ( .A1(A[14]), .A2(B[14]), .ZN(n85) );
  ND2D1BWP16P90LVT U102 ( .A1(n156), .A2(n88), .ZN(n14) );
  ND2D1BWP16P90LVT U105 ( .A1(A[13]), .A2(B[13]), .ZN(n88) );
  ND2D1BWP16P90LVT U110 ( .A1(n292), .A2(n93), .ZN(n15) );
  ND2D1BWP16P90LVT U113 ( .A1(A[12]), .A2(B[12]), .ZN(n93) );
  ND2D1BWP16P90LVT U116 ( .A1(n158), .A2(n96), .ZN(n16) );
  ND2D1BWP16P90LVT U119 ( .A1(A[11]), .A2(B[11]), .ZN(n96) );
  ND2D1BWP16P90LVT U124 ( .A1(n291), .A2(n101), .ZN(n17) );
  ND2D1BWP16P90LVT U127 ( .A1(A[10]), .A2(B[10]), .ZN(n101) );
  ND2D1BWP16P90LVT U130 ( .A1(n160), .A2(n104), .ZN(n18) );
  ND2D1BWP16P90LVT U133 ( .A1(A[9]), .A2(B[9]), .ZN(n104) );
  ND2D1BWP16P90LVT U138 ( .A1(n290), .A2(n109), .ZN(n19) );
  ND2D1BWP16P90LVT U141 ( .A1(A[8]), .A2(B[8]), .ZN(n109) );
  ND2D1BWP16P90LVT U144 ( .A1(n162), .A2(n112), .ZN(n20) );
  ND2D1BWP16P90LVT U147 ( .A1(A[7]), .A2(B[7]), .ZN(n112) );
  ND2D1BWP16P90LVT U152 ( .A1(n289), .A2(n117), .ZN(n21) );
  ND2D1BWP16P90LVT U155 ( .A1(A[6]), .A2(B[6]), .ZN(n117) );
  ND2D1BWP16P90LVT U158 ( .A1(n164), .A2(n120), .ZN(n22) );
  ND2D1BWP16P90LVT U161 ( .A1(A[5]), .A2(B[5]), .ZN(n120) );
  ND2D1BWP16P90LVT U166 ( .A1(n288), .A2(n125), .ZN(n23) );
  ND2D1BWP16P90LVT U169 ( .A1(A[4]), .A2(B[4]), .ZN(n125) );
  ND2D1BWP16P90LVT U172 ( .A1(n166), .A2(n128), .ZN(n24) );
  ND2D1BWP16P90LVT U175 ( .A1(A[3]), .A2(B[3]), .ZN(n128) );
  OAI21D1BWP16P90LVT U179 ( .A1(n132), .A2(n136), .B(n133), .ZN(n131) );
  ND2D1BWP16P90LVT U180 ( .A1(n167), .A2(n133), .ZN(n25) );
  ND2D1BWP16P90LVT U183 ( .A1(A[2]), .A2(B[2]), .ZN(n133) );
  OAI21D1BWP16P90LVT U185 ( .A1(n137), .A2(n135), .B(n136), .ZN(n134) );
  ND2D1BWP16P90LVT U186 ( .A1(n168), .A2(n136), .ZN(n26) );
  ND2D1BWP16P90LVT U189 ( .A1(A[1]), .A2(B[1]), .ZN(n136) );
  ND2D1BWP16P90LVT U193 ( .A1(n169), .A2(n140), .ZN(n27) );
  ND2D1BWP16P90LVT U196 ( .A1(A[0]), .A2(B[0]), .ZN(n140) );
  OAI21D2BWP16P90LVT U201 ( .A1(n49), .A2(n47), .B(n48), .ZN(n46) );
  AOI21D2BWP16P90LVT U202 ( .A1(n54), .A2(n297), .B(n51), .ZN(n49) );
  AOI21D1BWP16P90LVT U203 ( .A1(n126), .A2(n288), .B(n123), .ZN(n121) );
  XOR2D1BWP16P90 U204 ( .A1(n121), .A2(n22), .Z(SUM[5]) );
  FA1D1BWP16P90LVT U205 ( .A(B[27]), .B(A[27]), .CI(n287), .CO(n32), .S(
        SUM[27]) );
  OAI21D1BWP16P90LVT U206 ( .A1(n41), .A2(n39), .B(n40), .ZN(n38) );
  AOI21D1BWP16P90LVT U207 ( .A1(n46), .A2(n298), .B(n43), .ZN(n41) );
  OAI21D1BWP16P90LVT U208 ( .A1(n113), .A2(n111), .B(n112), .ZN(n110) );
  AOI21D1BWP16P90LVT U209 ( .A1(n62), .A2(n296), .B(n59), .ZN(n277) );
  AOI21D1BWP16P90LVT U210 ( .A1(n94), .A2(n292), .B(n91), .ZN(n276) );
  OAI21D1BWP16P90LVT U211 ( .A1(n65), .A2(n63), .B(n64), .ZN(n62) );
  OAI21D1BWP16P90LVT U212 ( .A1(n282), .A2(n95), .B(n96), .ZN(n94) );
  AOI21D1BWP16P90 U213 ( .A1(n94), .A2(n292), .B(n91), .ZN(n89) );
  AOI21D1BWP16P90 U214 ( .A1(n62), .A2(n296), .B(n59), .ZN(n57) );
  AOI21D1BWP16P90 U215 ( .A1(n110), .A2(n290), .B(n107), .ZN(n278) );
  OAI21D1BWP16P90LVT U216 ( .A1(n121), .A2(n119), .B(n120), .ZN(n118) );
  AOI21D1BWP16P90LVT U217 ( .A1(n110), .A2(n290), .B(n107), .ZN(n105) );
  AOI21D1BWP16P90LVT U218 ( .A1(n130), .A2(n138), .B(n131), .ZN(n129) );
  OAI21D1BWP16P90LVT U219 ( .A1(n129), .A2(n127), .B(n128), .ZN(n126) );
  OAI21D1BWP16P90LVT U220 ( .A1(n105), .A2(n103), .B(n104), .ZN(n102) );
  OAI21D1BWP16P90 U221 ( .A1(n129), .A2(n127), .B(n128), .ZN(n279) );
  OAI21D1BWP16P90 U222 ( .A1(n278), .A2(n103), .B(n104), .ZN(n280) );
  AOI21D1BWP16P90 U223 ( .A1(n46), .A2(n298), .B(n43), .ZN(n281) );
  AOI21D1BWP16P90LVT U224 ( .A1(n118), .A2(n289), .B(n115), .ZN(n113) );
  AOI21D1BWP16P90LVT U225 ( .A1(n102), .A2(n291), .B(n99), .ZN(n282) );
  AOI21D1BWP16P90 U226 ( .A1(n280), .A2(n291), .B(n99), .ZN(n97) );
  OAI21D1BWP16P90 U227 ( .A1(n121), .A2(n119), .B(n120), .ZN(n283) );
  XOR2D1BWP16P90 U228 ( .A1(n49), .A2(n4), .Z(SUM[23]) );
  XNR2D1BWP16P90 U229 ( .A1(n54), .A2(n5), .ZN(SUM[22]) );
  XOR2D1BWP16P90 U230 ( .A1(n57), .A2(n6), .Z(SUM[21]) );
  XNR2D1BWP16P90 U231 ( .A1(n62), .A2(n7), .ZN(SUM[20]) );
  XOR2D1BWP16P90 U232 ( .A1(n65), .A2(n8), .Z(SUM[19]) );
  XNR2D1BWP16P90 U233 ( .A1(n70), .A2(n9), .ZN(SUM[18]) );
  XOR2D1BWP16P90 U234 ( .A1(n73), .A2(n10), .Z(SUM[17]) );
  XNR2D1BWP16P90 U235 ( .A1(n78), .A2(n11), .ZN(SUM[16]) );
  XOR2D1BWP16P90 U236 ( .A1(n81), .A2(n12), .Z(SUM[15]) );
  XNR2D1BWP16P90 U237 ( .A1(n86), .A2(n13), .ZN(SUM[14]) );
  XOR2D1BWP16P90 U238 ( .A1(n89), .A2(n14), .Z(SUM[13]) );
  XNR2D1BWP16P90 U239 ( .A1(n94), .A2(n15), .ZN(SUM[12]) );
  XOR2D1BWP16P90 U240 ( .A1(n97), .A2(n16), .Z(SUM[11]) );
  XNR2D1BWP16P90 U241 ( .A1(n280), .A2(n17), .ZN(SUM[10]) );
  XOR2D1BWP16P90 U242 ( .A1(n278), .A2(n18), .Z(SUM[9]) );
  XNR2D1BWP16P90 U243 ( .A1(n110), .A2(n19), .ZN(SUM[8]) );
  XNR2D1BWP16P90 U244 ( .A1(n279), .A2(n23), .ZN(SUM[4]) );
  INVD1BWP16P90 U245 ( .I(n132), .ZN(n167) );
  INVD1BWP16P90 U246 ( .I(n127), .ZN(n166) );
  INVD1BWP16P90 U247 ( .I(n135), .ZN(n168) );
  AOI21D1BWP16P90 U248 ( .A1(n283), .A2(n289), .B(n115), .ZN(n284) );
  AOI21D1BWP16P90 U249 ( .A1(n130), .A2(n138), .B(n131), .ZN(n285) );
  OAI21D2BWP16P90LVT U250 ( .A1(n139), .A2(n141), .B(n140), .ZN(n138) );
  OAI21D1BWP16P90 U251 ( .A1(n281), .A2(n39), .B(n40), .ZN(n286) );
  OAI21D1BWP16P90LVT U252 ( .A1(n276), .A2(n87), .B(n88), .ZN(n86) );
  NR2D1BWP16P90LVT U253 ( .A1(n135), .A2(n132), .ZN(n130) );
  CKND1BWP16P90LVT U254 ( .I(n93), .ZN(n91) );
  CKND1BWP16P90LVT U255 ( .I(n125), .ZN(n123) );
  AOI21D1BWP16P90LVT U256 ( .A1(n86), .A2(n293), .B(n83), .ZN(n81) );
  CKND1BWP16P90LVT U257 ( .I(n85), .ZN(n83) );
  AOI21D1BWP16P90LVT U258 ( .A1(n78), .A2(n294), .B(n75), .ZN(n73) );
  CKND1BWP16P90LVT U259 ( .I(n77), .ZN(n75) );
  AOI21D1BWP16P90LVT U260 ( .A1(n70), .A2(n295), .B(n67), .ZN(n65) );
  CKND1BWP16P90LVT U261 ( .I(n69), .ZN(n67) );
  CKND1BWP16P90LVT U262 ( .I(n61), .ZN(n59) );
  CKND1BWP16P90LVT U263 ( .I(n53), .ZN(n51) );
  CKND1BWP16P90LVT U264 ( .I(n117), .ZN(n115) );
  CKND1BWP16P90LVT U265 ( .I(n109), .ZN(n107) );
  CKND1BWP16P90LVT U266 ( .I(n101), .ZN(n99) );
  OAI21D1BWP16P90LVT U267 ( .A1(n81), .A2(n79), .B(n80), .ZN(n78) );
  OAI21D1BWP16P90LVT U268 ( .A1(n73), .A2(n71), .B(n72), .ZN(n70) );
  OAI21D1BWP16P90LVT U269 ( .A1(n277), .A2(n55), .B(n56), .ZN(n54) );
  CKND1BWP16P90LVT U270 ( .I(n45), .ZN(n43) );
  XNR2D1BWP16P90LVT U271 ( .A1(n286), .A2(n1), .ZN(SUM[26]) );
  XOR2D1BWP16P90LVT U272 ( .A1(n281), .A2(n2), .Z(SUM[25]) );
  CKND1BWP16P90LVT U273 ( .I(n39), .ZN(n144) );
  XNR2D1BWP16P90LVT U274 ( .A1(n46), .A2(n3), .ZN(SUM[24]) );
  CKND1BWP16P90LVT U275 ( .I(n47), .ZN(n146) );
  CKND1BWP16P90LVT U276 ( .I(n55), .ZN(n148) );
  CKND1BWP16P90LVT U277 ( .I(n63), .ZN(n150) );
  CKND1BWP16P90LVT U278 ( .I(n71), .ZN(n152) );
  CKND1BWP16P90LVT U279 ( .I(n79), .ZN(n154) );
  CKND1BWP16P90LVT U280 ( .I(n87), .ZN(n156) );
  CKND1BWP16P90LVT U281 ( .I(n95), .ZN(n158) );
  CKND1BWP16P90LVT U282 ( .I(n103), .ZN(n160) );
  XOR2D1BWP16P90LVT U283 ( .A1(n284), .A2(n20), .Z(SUM[7]) );
  CKND1BWP16P90LVT U284 ( .I(n111), .ZN(n162) );
  XNR2D1BWP16P90LVT U285 ( .A1(n283), .A2(n21), .ZN(SUM[6]) );
  CKND1BWP16P90LVT U286 ( .I(n119), .ZN(n164) );
  CKND1BWP16P90LVT U287 ( .I(n138), .ZN(n137) );
  XNR2D1BWP16P90LVT U288 ( .A1(n134), .A2(n25), .ZN(SUM[2]) );
  XOR2D1BWP16P90LVT U289 ( .A1(n285), .A2(n24), .Z(SUM[3]) );
  XOR2D1BWP16P90LVT U290 ( .A1(n137), .A2(n26), .Z(SUM[1]) );
  CKND1BWP16P90LVT U291 ( .I(CI), .ZN(n141) );
  IOA21D1BWP16P90LVT U292 ( .A1(n38), .A2(n299), .B(n37), .ZN(n287) );
  FA1D1BWP16P90LVT U293 ( .A(B[30]), .B(A[30]), .CI(n30), .CO(n29), .S(SUM[30]) );
  NR2D1BWP16P90LVT U294 ( .A1(A[0]), .A2(B[0]), .ZN(n139) );
  FA1D1BWP16P90LVT U295 ( .A(B[28]), .B(A[28]), .CI(n32), .CO(n31), .S(SUM[28]) );
  FA1D1BWP16P90LVT U296 ( .A(B[29]), .B(A[29]), .CI(n31), .CO(n30), .S(SUM[29]) );
  NR2D1BWP16P90LVT U297 ( .A1(A[2]), .A2(B[2]), .ZN(n132) );
  NR2D1BWP16P90LVT U298 ( .A1(A[1]), .A2(B[1]), .ZN(n135) );
  NR2D1BWP16P90LVT U299 ( .A1(A[3]), .A2(B[3]), .ZN(n127) );
  OR2D1BWP16P90LVT U300 ( .A1(A[4]), .A2(B[4]), .Z(n288) );
  NR2D1BWP16P90LVT U301 ( .A1(A[5]), .A2(B[5]), .ZN(n119) );
  OR2D1BWP16P90LVT U302 ( .A1(A[6]), .A2(B[6]), .Z(n289) );
  NR2D1BWP16P90LVT U303 ( .A1(A[7]), .A2(B[7]), .ZN(n111) );
  OR2D1BWP16P90LVT U304 ( .A1(A[8]), .A2(B[8]), .Z(n290) );
  NR2D1BWP16P90LVT U305 ( .A1(A[9]), .A2(B[9]), .ZN(n103) );
  OR2D1BWP16P90LVT U306 ( .A1(A[10]), .A2(B[10]), .Z(n291) );
  NR2D1BWP16P90LVT U307 ( .A1(A[11]), .A2(B[11]), .ZN(n95) );
  OR2D1BWP16P90LVT U308 ( .A1(A[12]), .A2(B[12]), .Z(n292) );
  NR2D1BWP16P90LVT U309 ( .A1(A[13]), .A2(B[13]), .ZN(n87) );
  OR2D1BWP16P90LVT U310 ( .A1(A[14]), .A2(B[14]), .Z(n293) );
  NR2D1BWP16P90LVT U311 ( .A1(A[15]), .A2(B[15]), .ZN(n79) );
  OR2D1BWP16P90LVT U312 ( .A1(A[16]), .A2(B[16]), .Z(n294) );
  NR2D1BWP16P90LVT U313 ( .A1(A[17]), .A2(B[17]), .ZN(n71) );
  OR2D1BWP16P90LVT U314 ( .A1(A[18]), .A2(B[18]), .Z(n295) );
  NR2D1BWP16P90LVT U315 ( .A1(A[19]), .A2(B[19]), .ZN(n63) );
  OR2D1BWP16P90LVT U316 ( .A1(A[20]), .A2(B[20]), .Z(n296) );
  NR2D1BWP16P90LVT U317 ( .A1(A[21]), .A2(B[21]), .ZN(n55) );
  OR2D1BWP16P90LVT U318 ( .A1(A[22]), .A2(B[22]), .Z(n297) );
  NR2D1BWP16P90LVT U319 ( .A1(A[23]), .A2(B[23]), .ZN(n47) );
  OR2D1BWP16P90LVT U320 ( .A1(A[24]), .A2(B[24]), .Z(n298) );
  NR2D1BWP16P90LVT U321 ( .A1(A[25]), .A2(B[25]), .ZN(n39) );
  OR2D1BWP16P90LVT U322 ( .A1(A[26]), .A2(B[26]), .Z(n299) );
  XNR2D1BWP16P90LVT U323 ( .A1(n27), .A2(CI), .ZN(SUM[0]) );
  CKND1BWP16P90LVT U324 ( .I(n139), .ZN(n169) );
endmodule


module adder_dataflow ( s, co, a, b, ci );
  output [31:0] s;
  input [31:0] a;
  input [31:0] b;
  input ci;
  output co;
  wire   n1;

  adder_dataflow_DW01_add_1 add_1_root_add_9_2 ( .CI(ci), .SUM({co, s}), 
        .\A[31] (a[31]), .\A[30] (a[30]), .\A[29] (a[29]), .\A[28] (a[28]), 
        .\A[27] (a[27]), .\A[26] (a[26]), .\A[25] (a[25]), .\A[24] (a[24]), 
        .\A[23] (a[23]), .\A[22] (a[22]), .\A[21] (a[21]), .\A[20] (a[20]), 
        .\A[19] (a[19]), .\A[18] (a[18]), .\A[17] (a[17]), .\A[16] (a[16]), 
        .\A[15] (a[15]), .\A[14] (a[14]), .\A[13] (a[13]), .\A[12] (a[12]), 
        .\A[11] (a[11]), .\A[10] (a[10]), .\A[9] (a[9]), .\A[8] (a[8]), 
        .\A[7] (a[7]), .\A[6] (a[6]), .\A[5] (a[5]), .\A[4] (a[4]), .\A[3] (
        a[3]), .\A[2] (a[2]), .\A[1] (a[1]), .\A[0] (a[0]), .\B[31] (b[31]), 
        .\B[30] (b[30]), .\B[29] (b[29]), .\B[28] (b[28]), .\B[27] (b[27]), 
        .\B[26] (b[26]), .\B[25] (b[25]), .\B[24] (b[24]), .\B[23] (b[23]), 
        .\B[22] (b[22]), .\B[21] (b[21]), .\B[20] (b[20]), .\B[19] (b[19]), 
        .\B[18] (b[18]), .\B[17] (b[17]), .\B[16] (b[16]), .\B[15] (b[15]), 
        .\B[14] (b[14]), .\B[13] (b[13]), .\B[12] (b[12]), .\B[11] (b[11]), 
        .\B[10] (b[10]), .\B[9] (b[9]), .\B[8] (b[8]), .\B[7] (b[7]), .\B[6] (
        b[6]), .\B[5] (b[5]), .\B[4] (b[4]), .\B[3] (b[3]), .\B[2] (b[2]), 
        .\B[1] (b[1]), .\B[0] (b[0]) );
  TIELBWP20P90LVT U3 ( .ZN(n1) );
endmodule

