/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : V-2023.12
// Date      : Thu Oct  3 17:04:55 2024
/////////////////////////////////////////////////////////////


module adder_behavior_reg_DW01_add_2 ( CI, SUM, \A[31] , \A[30] , \A[29] , 
        \A[28] , \A[27] , \A[26] , \A[25] , \A[24] , \A[23] , \A[22] , \A[21] , 
        \A[20] , \A[19] , \A[18] , \A[17] , \A[16] , \A[15] , \A[14] , \A[13] , 
        \A[12] , \A[11] , \A[10] , \A[9] , \A[8] , \A[7] , \A[6] , \A[5] , 
        \A[4] , \A[3] , \A[2] , \A[1] , \A[0] , \B[31] , \B[30] , \B[29] , 
        \B[28] , \B[27] , \B[26] , \B[25] , \B[24] , \B[23] , \B[22] , \B[21] , 
        \B[20] , \B[19] , \B[18] , \B[17] , \B[16] , \B[15] , \B[14] , \B[13] , 
        \B[12] , \B[11] , \B[10] , \B[9] , \B[8] , \B[7] , \B[6] , \B[5] , 
        \B[4] , \B[3] , \B[2] , \B[1] , \B[0]  );
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
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n33, n34, n35, n36, n38, n40, n41, n42, n43, n44, n46, n48, n49,
         n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n62, n64, n65,
         n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79,
         n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92, n93,
         n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n114, n115, n116, n117,
         n118, n119, n120, n121, n122, n123, n124, n125, n126, n127, n129,
         n130, n131, n132, n133, n134, n135, n136, n137, n138, n139, n141,
         n142, n143, n144, n145, n146, n147, n148, n149, n150, n151, n152,
         n154, n155, n156, n157, n158, n159, n160, n161, n162, n163, n164,
         n165, n166, n167, n168, n169, n170, n171, n172, n173, n174, n175,
         n176, n177, n178, n179, n180, n181, n182, n183, n185, n186, n187,
         n188, n189, n190, n191, n192, n193, n194, n195, n196, n197, n198,
         n199, n200, n201, n202, n204, n206, n208, n209, n210, n211, n212,
         n213, n214, n215, n216, n217, n218, n219, n220, n221, n222, n223,
         n224, n225, n226, n227, n228, n229, n230, n231, n232, n339, n340,
         n341;
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

  FA1D1BWP16P90LVT U2 ( .A(B[31]), .B(A[31]), .CI(n33), .CO(SUM[32]), .S(
        SUM[31]) );
  OAI21D1BWP16P90LVT U4 ( .A1(n36), .A2(n34), .B(n35), .ZN(n33) );
  ND2D1BWP16P90LVT U5 ( .A1(n202), .A2(n35), .ZN(n1) );
  ND2D1BWP16P90LVT U8 ( .A1(A[30]), .A2(B[30]), .ZN(n35) );
  ND2D1BWP16P90LVT U13 ( .A1(n341), .A2(n40), .ZN(n2) );
  ND2D1BWP16P90LVT U16 ( .A1(A[29]), .A2(B[29]), .ZN(n40) );
  ND2D1BWP16P90LVT U19 ( .A1(n204), .A2(n43), .ZN(n3) );
  ND2D1BWP16P90LVT U22 ( .A1(A[28]), .A2(B[28]), .ZN(n43) );
  ND2D1BWP16P90LVT U27 ( .A1(n340), .A2(n48), .ZN(n4) );
  ND2D1BWP16P90LVT U30 ( .A1(A[27]), .A2(B[27]), .ZN(n48) );
  ND2D1BWP16P90LVT U33 ( .A1(n75), .A2(n52), .ZN(n50) );
  OAI21D1BWP16P90LVT U36 ( .A1(n60), .A2(n54), .B(n55), .ZN(n53) );
  ND2D1BWP16P90LVT U37 ( .A1(n206), .A2(n55), .ZN(n5) );
  ND2D1BWP16P90LVT U40 ( .A1(A[26]), .A2(B[26]), .ZN(n55) );
  ND2D1BWP16P90LVT U45 ( .A1(n66), .A2(n339), .ZN(n59) );
  ND2D1BWP16P90LVT U49 ( .A1(n339), .A2(n64), .ZN(n6) );
  ND2D1BWP16P90LVT U52 ( .A1(A[25]), .A2(B[25]), .ZN(n64) );
  OAI21D1BWP16P90LVT U56 ( .A1(n68), .A2(n72), .B(n69), .ZN(n67) );
  ND2D1BWP16P90LVT U57 ( .A1(n208), .A2(n69), .ZN(n7) );
  ND2D1BWP16P90LVT U60 ( .A1(A[24]), .A2(B[24]), .ZN(n69) );
  OAI21D1BWP16P90LVT U62 ( .A1(n74), .A2(n71), .B(n72), .ZN(n70) );
  ND2D1BWP16P90LVT U63 ( .A1(n209), .A2(n72), .ZN(n8) );
  ND2D1BWP16P90LVT U66 ( .A1(A[23]), .A2(B[23]), .ZN(n72) );
  OAI21D1BWP16P90LVT U71 ( .A1(n77), .A2(n99), .B(n78), .ZN(n76) );
  ND2D1BWP16P90LVT U72 ( .A1(n87), .A2(n79), .ZN(n77) );
  OAI21D1BWP16P90LVT U75 ( .A1(n81), .A2(n85), .B(n82), .ZN(n80) );
  ND2D1BWP16P90LVT U76 ( .A1(n210), .A2(n82), .ZN(n9) );
  ND2D1BWP16P90LVT U79 ( .A1(A[22]), .A2(B[22]), .ZN(n82) );
  OAI21D1BWP16P90LVT U81 ( .A1(n86), .A2(n84), .B(n85), .ZN(n83) );
  ND2D1BWP16P90LVT U82 ( .A1(n211), .A2(n85), .ZN(n10) );
  ND2D1BWP16P90LVT U85 ( .A1(A[21]), .A2(B[21]), .ZN(n85) );
  OAI21D1BWP16P90LVT U89 ( .A1(n89), .A2(n93), .B(n90), .ZN(n88) );
  ND2D1BWP16P90LVT U90 ( .A1(n212), .A2(n90), .ZN(n11) );
  ND2D1BWP16P90LVT U93 ( .A1(A[20]), .A2(B[20]), .ZN(n90) );
  OAI21D1BWP16P90LVT U95 ( .A1(n95), .A2(n92), .B(n93), .ZN(n91) );
  ND2D1BWP16P90LVT U96 ( .A1(n213), .A2(n93), .ZN(n12) );
  ND2D1BWP16P90LVT U99 ( .A1(A[19]), .A2(B[19]), .ZN(n93) );
  ND2D1BWP16P90LVT U105 ( .A1(n108), .A2(n100), .ZN(n98) );
  OAI21D1BWP16P90LVT U108 ( .A1(n102), .A2(n106), .B(n103), .ZN(n101) );
  ND2D1BWP16P90LVT U109 ( .A1(n214), .A2(n103), .ZN(n13) );
  ND2D1BWP16P90LVT U112 ( .A1(A[18]), .A2(B[18]), .ZN(n103) );
  OAI21D1BWP16P90LVT U114 ( .A1(n107), .A2(n105), .B(n106), .ZN(n104) );
  ND2D1BWP16P90LVT U115 ( .A1(n215), .A2(n106), .ZN(n14) );
  ND2D1BWP16P90LVT U118 ( .A1(A[17]), .A2(B[17]), .ZN(n106) );
  OAI21D1BWP16P90LVT U122 ( .A1(n110), .A2(n116), .B(n111), .ZN(n109) );
  ND2D1BWP16P90LVT U123 ( .A1(n216), .A2(n111), .ZN(n15) );
  ND2D1BWP16P90LVT U126 ( .A1(A[16]), .A2(B[16]), .ZN(n111) );
  ND2D1BWP16P90LVT U131 ( .A1(n217), .A2(n116), .ZN(n16) );
  ND2D1BWP16P90LVT U134 ( .A1(A[15]), .A2(B[15]), .ZN(n116) );
  OAI21D1BWP16P90LVT U139 ( .A1(n121), .A2(n147), .B(n122), .ZN(n120) );
  ND2D1BWP16P90LVT U140 ( .A1(n135), .A2(n123), .ZN(n121) );
  OAI21D1BWP16P90LVT U143 ( .A1(n125), .A2(n131), .B(n126), .ZN(n124) );
  ND2D1BWP16P90LVT U144 ( .A1(n218), .A2(n126), .ZN(n17) );
  ND2D1BWP16P90LVT U147 ( .A1(A[14]), .A2(B[14]), .ZN(n126) );
  ND2D1BWP16P90LVT U152 ( .A1(n219), .A2(n131), .ZN(n18) );
  ND2D1BWP16P90LVT U155 ( .A1(A[13]), .A2(B[13]), .ZN(n131) );
  OAI21D1BWP16P90LVT U157 ( .A1(n144), .A2(n133), .B(n134), .ZN(n132) );
  OAI21D1BWP16P90LVT U161 ( .A1(n137), .A2(n143), .B(n138), .ZN(n136) );
  ND2D1BWP16P90LVT U162 ( .A1(n220), .A2(n138), .ZN(n19) );
  ND2D1BWP16P90LVT U165 ( .A1(A[12]), .A2(B[12]), .ZN(n138) );
  ND2D1BWP16P90LVT U170 ( .A1(n221), .A2(n143), .ZN(n20) );
  ND2D1BWP16P90LVT U173 ( .A1(A[11]), .A2(B[11]), .ZN(n143) );
  OAI21D1BWP16P90LVT U176 ( .A1(n167), .A2(n146), .B(n147), .ZN(n145) );
  ND2D1BWP16P90LVT U177 ( .A1(n160), .A2(n148), .ZN(n146) );
  OAI21D1BWP16P90LVT U180 ( .A1(n150), .A2(n156), .B(n151), .ZN(n149) );
  ND2D1BWP16P90LVT U181 ( .A1(n222), .A2(n151), .ZN(n21) );
  ND2D1BWP16P90LVT U184 ( .A1(A[10]), .A2(B[10]), .ZN(n151) );
  ND2D1BWP16P90LVT U189 ( .A1(n223), .A2(n156), .ZN(n22) );
  ND2D1BWP16P90LVT U192 ( .A1(A[9]), .A2(B[9]), .ZN(n156) );
  OAI21D1BWP16P90LVT U194 ( .A1(n167), .A2(n158), .B(n159), .ZN(n157) );
  OAI21D1BWP16P90LVT U198 ( .A1(n162), .A2(n166), .B(n163), .ZN(n161) );
  ND2D1BWP16P90LVT U199 ( .A1(n224), .A2(n163), .ZN(n23) );
  ND2D1BWP16P90LVT U202 ( .A1(A[8]), .A2(B[8]), .ZN(n163) );
  OAI21D1BWP16P90LVT U204 ( .A1(n167), .A2(n165), .B(n166), .ZN(n164) );
  ND2D1BWP16P90LVT U205 ( .A1(n225), .A2(n166), .ZN(n24) );
  ND2D1BWP16P90LVT U208 ( .A1(A[7]), .A2(B[7]), .ZN(n166) );
  OAI21D1BWP16P90LVT U211 ( .A1(n169), .A2(n189), .B(n170), .ZN(n168) );
  ND2D1BWP16P90LVT U212 ( .A1(n179), .A2(n171), .ZN(n169) );
  OAI21D1BWP16P90LVT U215 ( .A1(n173), .A2(n177), .B(n174), .ZN(n172) );
  ND2D1BWP16P90LVT U216 ( .A1(n226), .A2(n174), .ZN(n25) );
  ND2D1BWP16P90LVT U219 ( .A1(A[6]), .A2(B[6]), .ZN(n174) );
  OAI21D1BWP16P90LVT U221 ( .A1(n178), .A2(n176), .B(n177), .ZN(n175) );
  ND2D1BWP16P90LVT U222 ( .A1(n227), .A2(n177), .ZN(n26) );
  ND2D1BWP16P90LVT U225 ( .A1(A[5]), .A2(B[5]), .ZN(n177) );
  ND2D1BWP16P90LVT U230 ( .A1(n228), .A2(n182), .ZN(n27) );
  ND2D1BWP16P90LVT U233 ( .A1(A[4]), .A2(B[4]), .ZN(n182) );
  ND2D1BWP16P90LVT U238 ( .A1(n229), .A2(n187), .ZN(n28) );
  OAI21D1BWP16P90LVT U246 ( .A1(n192), .A2(n196), .B(n193), .ZN(n191) );
  ND2D1BWP16P90LVT U247 ( .A1(n230), .A2(n193), .ZN(n29) );
  ND2D1BWP16P90LVT U250 ( .A1(A[2]), .A2(B[2]), .ZN(n193) );
  OAI21D1BWP16P90LVT U252 ( .A1(n197), .A2(n195), .B(n196), .ZN(n194) );
  ND2D1BWP16P90LVT U253 ( .A1(n231), .A2(n196), .ZN(n30) );
  ND2D1BWP16P90LVT U256 ( .A1(A[1]), .A2(B[1]), .ZN(n196) );
  OAI21D1BWP16P90LVT U259 ( .A1(n199), .A2(n201), .B(n200), .ZN(n198) );
  ND2D1BWP16P90LVT U260 ( .A1(n232), .A2(n200), .ZN(n31) );
  ND2D1BWP16P90LVT U263 ( .A1(A[0]), .A2(B[0]), .ZN(n200) );
  AOI21D1BWP16P90 U268 ( .A1(n188), .A2(n179), .B(n180), .ZN(n178) );
  CKND1BWP16P90LVT U269 ( .I(n118), .ZN(n117) );
  CKND1BWP16P90LVT U270 ( .I(n95), .ZN(n94) );
  CKND1BWP16P90LVT U271 ( .I(n145), .ZN(n144) );
  NR2D1BWP16P90LVT U272 ( .A1(n98), .A2(n77), .ZN(n75) );
  CKND1BWP16P90LVT U273 ( .I(n74), .ZN(n73) );
  AOI21D1BWP16P90LVT U274 ( .A1(n119), .A2(n168), .B(n120), .ZN(n118) );
  NR2D1BWP16P90LVT U275 ( .A1(n146), .A2(n121), .ZN(n119) );
  AOI21D1BWP16P90LVT U276 ( .A1(n94), .A2(n87), .B(n88), .ZN(n86) );
  AOI21D1BWP16P90LVT U277 ( .A1(n117), .A2(n96), .B(n97), .ZN(n95) );
  CKND1BWP16P90LVT U278 ( .I(n98), .ZN(n96) );
  CKND1BWP16P90LVT U279 ( .I(n99), .ZN(n97) );
  CKND1BWP16P90LVT U280 ( .I(n135), .ZN(n133) );
  CKND1BWP16P90LVT U281 ( .I(n136), .ZN(n134) );
  CKND1BWP16P90LVT U282 ( .I(n168), .ZN(n167) );
  AOI21D1BWP16P90LVT U283 ( .A1(n117), .A2(n108), .B(n109), .ZN(n107) );
  AOI21D1BWP16P90LVT U284 ( .A1(n117), .A2(n75), .B(n76), .ZN(n74) );
  CKND1BWP16P90LVT U285 ( .I(n160), .ZN(n158) );
  CKND1BWP16P90LVT U286 ( .I(n161), .ZN(n159) );
  CKND1BWP16P90LVT U287 ( .I(n189), .ZN(n188) );
  CKND1BWP16P90LVT U288 ( .I(n60), .ZN(n58) );
  CKND1BWP16P90LVT U289 ( .I(n59), .ZN(n57) );
  OAI21D1BWP16P90LVT U290 ( .A1(n118), .A2(n50), .B(n51), .ZN(n49) );
  AOI21D1BWP16P90LVT U291 ( .A1(n76), .A2(n52), .B(n53), .ZN(n51) );
  NR2D1BWP16P90LVT U292 ( .A1(n59), .A2(n54), .ZN(n52) );
  NR2D1BWP16P90LVT U293 ( .A1(n176), .A2(n173), .ZN(n171) );
  AOI21D1BWP16P90LVT U294 ( .A1(n49), .A2(n340), .B(n46), .ZN(n44) );
  CKND1BWP16P90LVT U295 ( .I(n48), .ZN(n46) );
  AOI21D1BWP16P90LVT U296 ( .A1(n41), .A2(n341), .B(n38), .ZN(n36) );
  CKND1BWP16P90LVT U297 ( .I(n40), .ZN(n38) );
  OAI21D1BWP16P90LVT U298 ( .A1(n44), .A2(n42), .B(n43), .ZN(n41) );
  XNR2D1BWP16P90LVT U299 ( .A1(n83), .A2(n9), .ZN(SUM[22]) );
  CKND1BWP16P90LVT U300 ( .I(n81), .ZN(n210) );
  AOI21D1BWP16P90LVT U301 ( .A1(n190), .A2(n198), .B(n191), .ZN(n189) );
  NR2D1BWP16P90LVT U302 ( .A1(n195), .A2(n192), .ZN(n190) );
  AOI21D1BWP16P90LVT U303 ( .A1(n79), .A2(n88), .B(n80), .ZN(n78) );
  AOI21D1BWP16P90LVT U304 ( .A1(n100), .A2(n109), .B(n101), .ZN(n99) );
  AOI21D1BWP16P90LVT U305 ( .A1(n148), .A2(n161), .B(n149), .ZN(n147) );
  XOR2D1BWP16P90LVT U306 ( .A1(n127), .A2(n17), .Z(SUM[14]) );
  AOI21D1BWP16P90LVT U307 ( .A1(n132), .A2(n219), .B(n129), .ZN(n127) );
  CKND1BWP16P90LVT U308 ( .I(n125), .ZN(n218) );
  AOI21D1BWP16P90LVT U309 ( .A1(n123), .A2(n136), .B(n124), .ZN(n122) );
  AOI21D1BWP16P90LVT U310 ( .A1(n67), .A2(n339), .B(n62), .ZN(n60) );
  CKND1BWP16P90LVT U311 ( .I(n64), .ZN(n62) );
  NR2D1BWP16P90LVT U312 ( .A1(n186), .A2(n181), .ZN(n179) );
  NR2D1BWP16P90LVT U313 ( .A1(n105), .A2(n102), .ZN(n100) );
  NR2D1BWP16P90LVT U314 ( .A1(n84), .A2(n81), .ZN(n79) );
  NR2D1BWP16P90LVT U315 ( .A1(n92), .A2(n89), .ZN(n87) );
  NR2D1BWP16P90LVT U316 ( .A1(n155), .A2(n150), .ZN(n148) );
  NR2D1BWP16P90LVT U317 ( .A1(n130), .A2(n125), .ZN(n123) );
  NR2D1BWP16P90LVT U318 ( .A1(n142), .A2(n137), .ZN(n135) );
  XNR2D1BWP16P90LVT U319 ( .A1(n104), .A2(n13), .ZN(SUM[18]) );
  CKND1BWP16P90LVT U320 ( .I(n102), .ZN(n214) );
  NR2D1BWP16P90LVT U321 ( .A1(n165), .A2(n162), .ZN(n160) );
  NR2D1BWP16P90LVT U322 ( .A1(n71), .A2(n68), .ZN(n66) );
  NR2D1BWP16P90LVT U323 ( .A1(n115), .A2(n110), .ZN(n108) );
  XOR2D1BWP16P90LVT U324 ( .A1(n86), .A2(n10), .Z(SUM[21]) );
  CKND1BWP16P90LVT U325 ( .I(n84), .ZN(n211) );
  XOR2D1BWP16P90LVT U326 ( .A1(n65), .A2(n6), .Z(SUM[25]) );
  AOI21D1BWP16P90LVT U327 ( .A1(n73), .A2(n66), .B(n67), .ZN(n65) );
  XOR2D1BWP16P90LVT U328 ( .A1(n56), .A2(n5), .Z(SUM[26]) );
  AOI21D1BWP16P90LVT U329 ( .A1(n73), .A2(n57), .B(n58), .ZN(n56) );
  CKND1BWP16P90LVT U330 ( .I(n54), .ZN(n206) );
  XNR2D1BWP16P90LVT U331 ( .A1(n132), .A2(n18), .ZN(SUM[13]) );
  XNR2D1BWP16P90LVT U332 ( .A1(n70), .A2(n7), .ZN(SUM[24]) );
  CKND1BWP16P90LVT U333 ( .I(n68), .ZN(n208) );
  XNR2D1BWP16P90LVT U334 ( .A1(n91), .A2(n11), .ZN(SUM[20]) );
  CKND1BWP16P90LVT U335 ( .I(n89), .ZN(n212) );
  CKND1BWP16P90LVT U336 ( .I(n34), .ZN(n202) );
  XOR2D1BWP16P90LVT U337 ( .A1(n152), .A2(n21), .Z(SUM[10]) );
  AOI21D1BWP16P90LVT U338 ( .A1(n157), .A2(n223), .B(n154), .ZN(n152) );
  CKND1BWP16P90LVT U339 ( .I(n150), .ZN(n222) );
  XNR2D1BWP16P90LVT U340 ( .A1(n73), .A2(n8), .ZN(SUM[23]) );
  CKND1BWP16P90LVT U341 ( .I(n71), .ZN(n209) );
  XNR2D1BWP16P90LVT U342 ( .A1(n41), .A2(n2), .ZN(SUM[29]) );
  XNR2D1BWP16P90LVT U343 ( .A1(n94), .A2(n12), .ZN(SUM[19]) );
  CKND1BWP16P90LVT U344 ( .I(n92), .ZN(n213) );
  XOR2D1BWP16P90LVT U345 ( .A1(n107), .A2(n14), .Z(SUM[17]) );
  CKND1BWP16P90LVT U346 ( .I(n105), .ZN(n215) );
  XOR2D1BWP16P90LVT U347 ( .A1(n112), .A2(n15), .Z(SUM[16]) );
  AOI21D1BWP16P90LVT U348 ( .A1(n117), .A2(n217), .B(n114), .ZN(n112) );
  CKND1BWP16P90LVT U349 ( .I(n110), .ZN(n216) );
  XOR2D1BWP16P90LVT U350 ( .A1(n139), .A2(n19), .Z(SUM[12]) );
  AOI21D1BWP16P90LVT U351 ( .A1(n145), .A2(n221), .B(n141), .ZN(n139) );
  CKND1BWP16P90LVT U352 ( .I(n137), .ZN(n220) );
  XNR2D1BWP16P90LVT U353 ( .A1(n157), .A2(n22), .ZN(SUM[9]) );
  XOR2D1BWP16P90LVT U354 ( .A1(n44), .A2(n3), .Z(SUM[28]) );
  CKND1BWP16P90LVT U355 ( .I(n42), .ZN(n204) );
  XNR2D1BWP16P90LVT U356 ( .A1(n164), .A2(n23), .ZN(SUM[8]) );
  CKND1BWP16P90LVT U357 ( .I(n162), .ZN(n224) );
  XOR2D1BWP16P90LVT U358 ( .A1(n144), .A2(n20), .Z(SUM[11]) );
  XNR2D1BWP16P90LVT U359 ( .A1(n49), .A2(n4), .ZN(SUM[27]) );
  XNR2D1BWP16P90LVT U360 ( .A1(n117), .A2(n16), .ZN(SUM[15]) );
  XNR2D1BWP16P90LVT U361 ( .A1(n175), .A2(n25), .ZN(SUM[6]) );
  CKND1BWP16P90LVT U362 ( .I(n173), .ZN(n226) );
  XOR2D1BWP16P90LVT U363 ( .A1(n167), .A2(n24), .Z(SUM[7]) );
  CKND1BWP16P90LVT U364 ( .I(n165), .ZN(n225) );
  XOR2D1BWP16P90LVT U365 ( .A1(n178), .A2(n26), .Z(SUM[5]) );
  CKND1BWP16P90LVT U366 ( .I(n176), .ZN(n227) );
  XOR2D1BWP16P90LVT U367 ( .A1(n183), .A2(n27), .Z(SUM[4]) );
  AOI21D1BWP16P90LVT U368 ( .A1(n188), .A2(n229), .B(n185), .ZN(n183) );
  CKND1BWP16P90LVT U369 ( .I(n181), .ZN(n228) );
  CKND1BWP16P90LVT U370 ( .I(n198), .ZN(n197) );
  XNR2D1BWP16P90LVT U371 ( .A1(n194), .A2(n29), .ZN(SUM[2]) );
  CKND1BWP16P90LVT U372 ( .I(n192), .ZN(n230) );
  XNR2D1BWP16P90LVT U373 ( .A1(n188), .A2(n28), .ZN(SUM[3]) );
  XOR2D1BWP16P90LVT U374 ( .A1(n197), .A2(n30), .Z(SUM[1]) );
  CKND1BWP16P90LVT U375 ( .I(n195), .ZN(n231) );
  CKND1BWP16P90LVT U376 ( .I(n156), .ZN(n154) );
  CKND1BWP16P90LVT U377 ( .I(n131), .ZN(n129) );
  CKND1BWP16P90LVT U378 ( .I(n143), .ZN(n141) );
  CKND1BWP16P90LVT U379 ( .I(n116), .ZN(n114) );
  CKND1BWP16P90LVT U380 ( .I(n155), .ZN(n223) );
  CKND1BWP16P90LVT U381 ( .I(n130), .ZN(n219) );
  CKND1BWP16P90LVT U382 ( .I(n142), .ZN(n221) );
  CKND1BWP16P90LVT U383 ( .I(n115), .ZN(n217) );
  CKND1BWP16P90LVT U384 ( .I(n186), .ZN(n229) );
  CKND1BWP16P90LVT U385 ( .I(n187), .ZN(n185) );
  NR2D1BWP16P90LVT U386 ( .A1(A[4]), .A2(B[4]), .ZN(n181) );
  ND2D1BWP16P90LVT U387 ( .A1(A[3]), .A2(B[3]), .ZN(n187) );
  CKND1BWP16P90LVT U388 ( .I(CI), .ZN(n201) );
  NR2D1BWP16P90LVT U389 ( .A1(A[0]), .A2(B[0]), .ZN(n199) );
  NR2D1BWP16P90LVT U390 ( .A1(A[16]), .A2(B[16]), .ZN(n110) );
  NR2D1BWP16P90LVT U391 ( .A1(A[2]), .A2(B[2]), .ZN(n192) );
  NR2D1BWP16P90LVT U392 ( .A1(A[8]), .A2(B[8]), .ZN(n162) );
  NR2D1BWP16P90LVT U393 ( .A1(A[6]), .A2(B[6]), .ZN(n173) );
  NR2D1BWP16P90LVT U394 ( .A1(A[20]), .A2(B[20]), .ZN(n89) );
  NR2D1BWP16P90LVT U395 ( .A1(A[1]), .A2(B[1]), .ZN(n195) );
  NR2D1BWP16P90LVT U396 ( .A1(A[18]), .A2(B[18]), .ZN(n102) );
  NR2D1BWP16P90LVT U397 ( .A1(A[12]), .A2(B[12]), .ZN(n137) );
  NR2D1BWP16P90LVT U398 ( .A1(A[5]), .A2(B[5]), .ZN(n176) );
  NR2D1BWP16P90LVT U399 ( .A1(A[24]), .A2(B[24]), .ZN(n68) );
  NR2D1BWP16P90LVT U400 ( .A1(A[17]), .A2(B[17]), .ZN(n105) );
  NR2D1BWP16P90LVT U401 ( .A1(A[10]), .A2(B[10]), .ZN(n150) );
  NR2D1BWP16P90LVT U402 ( .A1(A[22]), .A2(B[22]), .ZN(n81) );
  NR2D1BWP16P90LVT U403 ( .A1(A[3]), .A2(B[3]), .ZN(n186) );
  NR2D1BWP16P90LVT U404 ( .A1(A[21]), .A2(B[21]), .ZN(n84) );
  NR2D1BWP16P90LVT U405 ( .A1(A[19]), .A2(B[19]), .ZN(n92) );
  NR2D1BWP16P90LVT U406 ( .A1(A[14]), .A2(B[14]), .ZN(n125) );
  NR2D1BWP16P90LVT U407 ( .A1(A[9]), .A2(B[9]), .ZN(n155) );
  NR2D1BWP16P90LVT U408 ( .A1(A[13]), .A2(B[13]), .ZN(n130) );
  NR2D1BWP16P90LVT U409 ( .A1(A[11]), .A2(B[11]), .ZN(n142) );
  NR2D1BWP16P90LVT U410 ( .A1(A[7]), .A2(B[7]), .ZN(n165) );
  NR2D1BWP16P90LVT U411 ( .A1(A[23]), .A2(B[23]), .ZN(n71) );
  NR2D1BWP16P90LVT U412 ( .A1(A[15]), .A2(B[15]), .ZN(n115) );
  OR2D1BWP16P90LVT U413 ( .A1(A[25]), .A2(B[25]), .Z(n339) );
  NR2D1BWP16P90LVT U414 ( .A1(A[26]), .A2(B[26]), .ZN(n54) );
  OR2D1BWP16P90LVT U415 ( .A1(A[27]), .A2(B[27]), .Z(n340) );
  NR2D1BWP16P90LVT U416 ( .A1(A[28]), .A2(B[28]), .ZN(n42) );
  OR2D1BWP16P90LVT U417 ( .A1(A[29]), .A2(B[29]), .Z(n341) );
  NR2D1BWP16P90LVT U418 ( .A1(A[30]), .A2(B[30]), .ZN(n34) );
  XNR2D1BWP16P90LVT U419 ( .A1(n31), .A2(CI), .ZN(SUM[0]) );
  CKND1BWP16P90LVT U420 ( .I(n199), .ZN(n232) );
  XOR2D1BWP16P90LVT U421 ( .A1(n36), .A2(n1), .Z(SUM[30]) );
  OAI21D1BWP16P90 U422 ( .A1(n181), .A2(n187), .B(n182), .ZN(n180) );
  AOI21D1BWP16P90LVT U423 ( .A1(n171), .A2(n180), .B(n172), .ZN(n170) );
endmodule


module adder_behavior_reg ( s, co, a, b, ci, clk );
  output [31:0] s;
  input [31:0] a;
  input [31:0] b;
  input ci, clk;
  output co;
  wire   N33, N34, N35, N36, N37, N38, N39, N40, N41, N42, N43, N44, N45, N46,
         N47, N48, N49, N50, N51, N52, N53, N54, N55, N56, N57, N58, N59, N60,
         N61, N62, N63, N64, N65, n1;

  DFQD2BWP16P90LVT co_reg ( .D(N65), .CP(clk), .Q(co) );
  DFQD2BWP16P90LVT s_reg_31_ ( .D(N64), .CP(clk), .Q(s[31]) );
  DFQD2BWP16P90LVT s_reg_30_ ( .D(N63), .CP(clk), .Q(s[30]) );
  DFQD2BWP16P90LVT s_reg_29_ ( .D(N62), .CP(clk), .Q(s[29]) );
  DFQD2BWP16P90LVT s_reg_28_ ( .D(N61), .CP(clk), .Q(s[28]) );
  DFQD2BWP16P90LVT s_reg_27_ ( .D(N60), .CP(clk), .Q(s[27]) );
  DFQD2BWP16P90LVT s_reg_26_ ( .D(N59), .CP(clk), .Q(s[26]) );
  DFQD2BWP16P90LVT s_reg_25_ ( .D(N58), .CP(clk), .Q(s[25]) );
  DFQD2BWP16P90LVT s_reg_24_ ( .D(N57), .CP(clk), .Q(s[24]) );
  DFQD2BWP16P90LVT s_reg_23_ ( .D(N56), .CP(clk), .Q(s[23]) );
  DFQD2BWP16P90LVT s_reg_22_ ( .D(N55), .CP(clk), .Q(s[22]) );
  DFQD2BWP16P90LVT s_reg_21_ ( .D(N54), .CP(clk), .Q(s[21]) );
  DFQD2BWP16P90LVT s_reg_20_ ( .D(N53), .CP(clk), .Q(s[20]) );
  DFQD2BWP16P90LVT s_reg_19_ ( .D(N52), .CP(clk), .Q(s[19]) );
  DFQD2BWP16P90LVT s_reg_18_ ( .D(N51), .CP(clk), .Q(s[18]) );
  DFQD2BWP16P90LVT s_reg_17_ ( .D(N50), .CP(clk), .Q(s[17]) );
  DFQD2BWP16P90LVT s_reg_16_ ( .D(N49), .CP(clk), .Q(s[16]) );
  DFQD2BWP16P90LVT s_reg_15_ ( .D(N48), .CP(clk), .Q(s[15]) );
  DFQD2BWP16P90LVT s_reg_14_ ( .D(N47), .CP(clk), .Q(s[14]) );
  DFQD2BWP16P90LVT s_reg_13_ ( .D(N46), .CP(clk), .Q(s[13]) );
  DFQD2BWP16P90LVT s_reg_12_ ( .D(N45), .CP(clk), .Q(s[12]) );
  DFQD2BWP16P90LVT s_reg_11_ ( .D(N44), .CP(clk), .Q(s[11]) );
  DFQD2BWP16P90LVT s_reg_10_ ( .D(N43), .CP(clk), .Q(s[10]) );
  DFQD2BWP16P90LVT s_reg_9_ ( .D(N42), .CP(clk), .Q(s[9]) );
  DFQD2BWP16P90LVT s_reg_8_ ( .D(N41), .CP(clk), .Q(s[8]) );
  DFQD2BWP16P90LVT s_reg_7_ ( .D(N40), .CP(clk), .Q(s[7]) );
  DFQD2BWP16P90LVT s_reg_6_ ( .D(N39), .CP(clk), .Q(s[6]) );
  DFQD2BWP16P90LVT s_reg_5_ ( .D(N38), .CP(clk), .Q(s[5]) );
  DFQD2BWP16P90LVT s_reg_4_ ( .D(N37), .CP(clk), .Q(s[4]) );
  DFQD2BWP16P90LVT s_reg_3_ ( .D(N36), .CP(clk), .Q(s[3]) );
  DFQD2BWP16P90LVT s_reg_2_ ( .D(N35), .CP(clk), .Q(s[2]) );
  DFQD2BWP16P90LVT s_reg_1_ ( .D(N34), .CP(clk), .Q(s[1]) );
  DFQD2BWP16P90LVT s_reg_0_ ( .D(N33), .CP(clk), .Q(s[0]) );
  adder_behavior_reg_DW01_add_2 add_1_root_add_9_2 ( .CI(ci), .SUM({N65, N64, 
        N63, N62, N61, N60, N59, N58, N57, N56, N55, N54, N53, N52, N51, N50, 
        N49, N48, N47, N46, N45, N44, N43, N42, N41, N40, N39, N38, N37, N36, 
        N35, N34, N33}), .\A[31] (a[31]), .\A[30] (a[30]), .\A[29] (a[29]), 
        .\A[28] (a[28]), .\A[27] (a[27]), .\A[26] (a[26]), .\A[25] (a[25]), 
        .\A[24] (a[24]), .\A[23] (a[23]), .\A[22] (a[22]), .\A[21] (a[21]), 
        .\A[20] (a[20]), .\A[19] (a[19]), .\A[18] (a[18]), .\A[17] (a[17]), 
        .\A[16] (a[16]), .\A[15] (a[15]), .\A[14] (a[14]), .\A[13] (a[13]), 
        .\A[12] (a[12]), .\A[11] (a[11]), .\A[10] (a[10]), .\A[9] (a[9]), 
        .\A[8] (a[8]), .\A[7] (a[7]), .\A[6] (a[6]), .\A[5] (a[5]), .\A[4] (
        a[4]), .\A[3] (a[3]), .\A[2] (a[2]), .\A[1] (a[1]), .\A[0] (a[0]), 
        .\B[31] (b[31]), .\B[30] (b[30]), .\B[29] (b[29]), .\B[28] (b[28]), 
        .\B[27] (b[27]), .\B[26] (b[26]), .\B[25] (b[25]), .\B[24] (b[24]), 
        .\B[23] (b[23]), .\B[22] (b[22]), .\B[21] (b[21]), .\B[20] (b[20]), 
        .\B[19] (b[19]), .\B[18] (b[18]), .\B[17] (b[17]), .\B[16] (b[16]), 
        .\B[15] (b[15]), .\B[14] (b[14]), .\B[13] (b[13]), .\B[12] (b[12]), 
        .\B[11] (b[11]), .\B[10] (b[10]), .\B[9] (b[9]), .\B[8] (b[8]), 
        .\B[7] (b[7]), .\B[6] (b[6]), .\B[5] (b[5]), .\B[4] (b[4]), .\B[3] (
        b[3]), .\B[2] (b[2]), .\B[1] (b[1]), .\B[0] (b[0]) );
  TIELBWP20P90LVT U4 ( .ZN(n1) );
endmodule

