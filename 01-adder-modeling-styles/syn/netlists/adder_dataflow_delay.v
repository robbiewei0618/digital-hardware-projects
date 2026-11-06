/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : V-2023.12
// Date      : Thu Oct  3 16:09:57 2024
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
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48,
         n49, n50, n51, n52, n53, n54, n55, n56, n59, n60, n61, n62, n63, n64,
         n65, n66, n68, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81,
         n82, n83, n84, n85, n86, n87, n88, n91, n92, n93, n94, n95, n96, n97,
         n98, n99, n101, n102, n103, n104, n105, n106, n107, n108, n109, n110,
         n115, n116, n117, n118, n119, n120, n123, n124, n125, n126, n127,
         n128, n131, n132, n133, n134, n135, n136, n137, n138, n139, n140,
         n143, n144, n145, n146, n147, n148, n149, n152, n153, n154, n155,
         n156, n157, n158, n161, n162, n165, n166, n167, n168, n171, n173,
         n174, n175, n176, n177, n178, n181, n182, n183, n184, n189, n190,
         n191, n193, n194, n195, n196, n197, n198, n199, n200, n201, n202,
         n203, n204, n205, n206, n207, n208, n209, n210, n211, n214, n215,
         n216, n217, n218, n219, n221, n224, n225, n226, n227, n228, n230,
         n231, n232, n233, n234, n235, n236, n237, n240, n241, n242, n243,
         n244, n245, n246, n248, n249, n250, n251, n252, n254, n255, n260,
         n261, n262, n263, n264, n265, n266, n267, n268, n269, n270, n271,
         n272, n273, n274, n275, n276, n279, n280, n281, n282, n287, n288,
         n289, n291, n292, n293, n295, n296, n297, n298, n299, n300, n301,
         n302, n303, n304, n305, n306, n307, n309, n310, n311, n313, n314,
         n315, n316, n317, n318, n319, n320, n321, n322, n323, n324, n325,
         n326, n327, n328, n329, n330, n331, n332, n334, n335, n336, n337,
         n338, n339, n446, n447, n448, n449, n450, n451, n452, n454, n455,
         n456, n457, n458, n459, n460;
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

  ND2D1BWP16P90LVT U6 ( .A1(n454), .A2(n37), .ZN(n1) );
  ND2D1BWP16P90LVT U9 ( .A1(A[31]), .A2(B[31]), .ZN(n37) );
  ND2D1BWP16P90LVT U12 ( .A1(n125), .A2(n41), .ZN(n39) );
  OAI21D1BWP16P90LVT U15 ( .A1(n43), .A2(n86), .B(n44), .ZN(n42) );
  ND2D1BWP16P90LVT U16 ( .A1(n65), .A2(n45), .ZN(n43) );
  OAI21D1BWP16P90LVT U19 ( .A1(n47), .A2(n59), .B(n48), .ZN(n46) );
  ND2D1BWP16P90LVT U20 ( .A1(n309), .A2(n48), .ZN(n2) );
  ND2D1BWP16P90LVT U23 ( .A1(A[30]), .A2(B[30]), .ZN(n48) );
  OAI21D1BWP16P90LVT U27 ( .A1(n452), .A2(n52), .B(n53), .ZN(n51) );
  ND2D1BWP16P90LVT U28 ( .A1(n87), .A2(n54), .ZN(n52) );
  OAI21D1BWP16P90LVT U31 ( .A1(n68), .A2(n56), .B(n59), .ZN(n55) );
  ND2D1BWP16P90LVT U34 ( .A1(n310), .A2(n59), .ZN(n3) );
  ND2D1BWP16P90LVT U37 ( .A1(A[29]), .A2(B[29]), .ZN(n59) );
  ND2D1BWP16P90LVT U42 ( .A1(n87), .A2(n65), .ZN(n63) );
  ND2D1BWP16P90LVT U50 ( .A1(n311), .A2(n72), .ZN(n4) );
  ND2D1BWP16P90LVT U53 ( .A1(A[28]), .A2(B[28]), .ZN(n72) );
  OAI21D1BWP16P90LVT U57 ( .A1(n452), .A2(n76), .B(n77), .ZN(n75) );
  ND2D1BWP16P90LVT U58 ( .A1(n87), .A2(n78), .ZN(n76) );
  ND2D1BWP16P90LVT U62 ( .A1(n78), .A2(n81), .ZN(n5) );
  ND2D1BWP16P90LVT U65 ( .A1(A[27]), .A2(B[27]), .ZN(n81) );
  OAI21D1BWP16P90LVT U77 ( .A1(n93), .A2(n103), .B(n94), .ZN(n92) );
  ND2D1BWP16P90LVT U78 ( .A1(n313), .A2(n94), .ZN(n6) );
  ND2D1BWP16P90LVT U81 ( .A1(A[26]), .A2(B[26]), .ZN(n94) );
  OAI21D1BWP16P90LVT U85 ( .A1(n452), .A2(n98), .B(n99), .ZN(n97) );
  ND2D1BWP16P90LVT U86 ( .A1(n109), .A2(n314), .ZN(n98) );
  ND2D1BWP16P90LVT U90 ( .A1(n314), .A2(n103), .ZN(n7) );
  ND2D1BWP16P90LVT U93 ( .A1(A[25]), .A2(B[25]), .ZN(n103) );
  OAI21D1BWP16P90LVT U97 ( .A1(n452), .A2(n107), .B(n108), .ZN(n106) );
  ND2D1BWP16P90LVT U106 ( .A1(n315), .A2(n116), .ZN(n8) );
  ND2D1BWP16P90LVT U109 ( .A1(A[24]), .A2(B[24]), .ZN(n116) );
  OAI21D1BWP16P90LVT U113 ( .A1(n452), .A2(n120), .B(n123), .ZN(n119) );
  ND2D1BWP16P90LVT U116 ( .A1(n316), .A2(n123), .ZN(n9) );
  ND2D1BWP16P90LVT U119 ( .A1(A[23]), .A2(B[23]), .ZN(n123) );
  OAI21D1BWP16P90LVT U131 ( .A1(n135), .A2(n143), .B(n136), .ZN(n134) );
  ND2D1BWP16P90LVT U132 ( .A1(n317), .A2(n136), .ZN(n10) );
  ND2D1BWP16P90LVT U135 ( .A1(A[22]), .A2(B[22]), .ZN(n136) );
  OAI21D1BWP16P90LVT U139 ( .A1(n148), .A2(n140), .B(n143), .ZN(n139) );
  ND2D1BWP16P90LVT U142 ( .A1(n318), .A2(n143), .ZN(n11) );
  ND2D1BWP16P90LVT U145 ( .A1(A[21]), .A2(B[21]), .ZN(n143) );
  ND2D1BWP16P90LVT U150 ( .A1(n167), .A2(n149), .ZN(n147) );
  OAI21D1BWP16P90LVT U155 ( .A1(n153), .A2(n161), .B(n154), .ZN(n152) );
  ND2D1BWP16P90LVT U156 ( .A1(n319), .A2(n154), .ZN(n12) );
  ND2D1BWP16P90LVT U159 ( .A1(A[20]), .A2(B[20]), .ZN(n154) );
  ND2D1BWP16P90LVT U166 ( .A1(n320), .A2(n161), .ZN(n13) );
  ND2D1BWP16P90LVT U182 ( .A1(n321), .A2(n174), .ZN(n14) );
  ND2D1BWP16P90LVT U185 ( .A1(A[18]), .A2(B[18]), .ZN(n174) );
  ND2D1BWP16P90LVT U192 ( .A1(n322), .A2(n181), .ZN(n15) );
  ND2D1BWP16P90LVT U195 ( .A1(A[17]), .A2(B[17]), .ZN(n181) );
  ND2D1BWP16P90LVT U204 ( .A1(n323), .A2(n190), .ZN(n16) );
  ND2D1BWP16P90LVT U212 ( .A1(n324), .A2(n195), .ZN(n17) );
  OAI21D1BWP16P90LVT U224 ( .A1(n204), .A2(n214), .B(n205), .ZN(n203) );
  ND2D1BWP16P90LVT U225 ( .A1(n325), .A2(n205), .ZN(n18) );
  ND2D1BWP16P90LVT U228 ( .A1(A[14]), .A2(B[14]), .ZN(n205) );
  OAI21D1BWP16P90LVT U230 ( .A1(n265), .A2(n207), .B(n208), .ZN(n206) );
  ND2D1BWP16P90LVT U231 ( .A1(n236), .A2(n209), .ZN(n207) );
  ND2D1BWP16P90LVT U237 ( .A1(n326), .A2(n214), .ZN(n19) );
  ND2D1BWP16P90LVT U240 ( .A1(A[13]), .A2(B[13]), .ZN(n214) );
  OAI21D1BWP16P90LVT U242 ( .A1(n265), .A2(n216), .B(n217), .ZN(n215) );
  ND2D1BWP16P90LVT U243 ( .A1(n236), .A2(n447), .ZN(n216) );
  ND2D1BWP16P90LVT U251 ( .A1(n327), .A2(n225), .ZN(n20) );
  ND2D1BWP16P90LVT U254 ( .A1(A[12]), .A2(B[12]), .ZN(n225) );
  OAI21D1BWP16P90LVT U256 ( .A1(n265), .A2(n227), .B(n228), .ZN(n226) );
  ND2D1BWP16P90LVT U257 ( .A1(n236), .A2(n328), .ZN(n227) );
  ND2D1BWP16P90LVT U261 ( .A1(n328), .A2(n232), .ZN(n21) );
  OAI21D1BWP16P90LVT U266 ( .A1(n265), .A2(n234), .B(n235), .ZN(n233) );
  ND2D1BWP16P90LVT U275 ( .A1(n329), .A2(n243), .ZN(n22) );
  ND2D1BWP16P90LVT U278 ( .A1(A[10]), .A2(B[10]), .ZN(n243) );
  OAI21D1BWP16P90LVT U280 ( .A1(n265), .A2(n245), .B(n246), .ZN(n244) );
  ND2D1BWP16P90LVT U281 ( .A1(n254), .A2(n330), .ZN(n245) );
  ND2D1BWP16P90LVT U285 ( .A1(n330), .A2(n250), .ZN(n23) );
  OAI21D1BWP16P90LVT U290 ( .A1(n265), .A2(n252), .B(n457), .ZN(n251) );
  ND2D1BWP16P90LVT U299 ( .A1(n331), .A2(n261), .ZN(n24) );
  OAI21D1BWP16P90LVT U304 ( .A1(n265), .A2(n263), .B(n264), .ZN(n262) );
  OAI21D1BWP16P90LVT U315 ( .A1(n271), .A2(n279), .B(n272), .ZN(n270) );
  ND2D1BWP16P90LVT U316 ( .A1(n455), .A2(n272), .ZN(n26) );
  ND2D1BWP16P90LVT U319 ( .A1(A[6]), .A2(B[6]), .ZN(n272) );
  ND2D1BWP16P90LVT U326 ( .A1(n334), .A2(n279), .ZN(n27) );
  ND2D1BWP16P90LVT U329 ( .A1(A[5]), .A2(B[5]), .ZN(n279) );
  ND2D1BWP16P90LVT U338 ( .A1(n335), .A2(n456), .ZN(n28) );
  ND2D1BWP16P90LVT U341 ( .A1(A[4]), .A2(B[4]), .ZN(n288) );
  ND2D1BWP16P90LVT U346 ( .A1(n336), .A2(n293), .ZN(n29) );
  ND2D1BWP16P90LVT U355 ( .A1(n337), .A2(n299), .ZN(n30) );
  ND2D1BWP16P90LVT U358 ( .A1(A[2]), .A2(B[2]), .ZN(n299) );
  OAI21D1BWP16P90LVT U360 ( .A1(n303), .A2(n301), .B(n302), .ZN(n300) );
  ND2D1BWP16P90LVT U361 ( .A1(n338), .A2(n302), .ZN(n31) );
  OAI21D2BWP16P90LVT U376 ( .A1(n305), .A2(n307), .B(n306), .ZN(n304) );
  CKNR2D1BWP16P90LVT U377 ( .A1(n234), .A2(n200), .ZN(n198) );
  CKND2D1BWP16P90LVT U378 ( .A1(n149), .A2(n133), .ZN(n131) );
  ND2D1BWP16P90 U379 ( .A1(n332), .A2(n264), .ZN(n25) );
  OA21D4BWP16P90 U380 ( .A1(n260), .A2(n264), .B(n261), .Z(n457) );
  AN2D2BWP16P90LVT U381 ( .A1(n240), .A2(n255), .Z(n450) );
  INVD4BWP16P90LVT U382 ( .I(n197), .ZN(n196) );
  CKNR2D1BWP16P90LVT U383 ( .A1(A[9]), .A2(B[9]), .ZN(n249) );
  ND2D2BWP16P90LVT U384 ( .A1(A[7]), .A2(B[7]), .ZN(n264) );
  AOI21D1BWP16P90LVT U385 ( .A1(n296), .A2(n304), .B(n297), .ZN(n295) );
  NR2D1BWP16P90LVT U386 ( .A1(n263), .A2(n260), .ZN(n254) );
  NR2D2BWP16P90LVT U387 ( .A1(n450), .A2(n241), .ZN(n235) );
  CKNR2D1BWP16P90LVT U388 ( .A1(A[12]), .A2(B[12]), .ZN(n224) );
  NR2D2BWP16P90LVT U389 ( .A1(A[16]), .A2(B[16]), .ZN(n189) );
  NR2D1BWP16P90LVT U390 ( .A1(A[20]), .A2(B[20]), .ZN(n153) );
  NR2D1BWP16P90LVT U391 ( .A1(A[21]), .A2(B[21]), .ZN(n140) );
  XNR2D1BWP16P90LVT U392 ( .A1(n17), .A2(n449), .ZN(SUM[15]) );
  OAI21D1BWP16P90LVT U393 ( .A1(n260), .A2(n264), .B(n261), .ZN(n255) );
  ND2D2BWP16P90LVT U394 ( .A1(A[8]), .A2(B[8]), .ZN(n261) );
  INVD4BWP16P90LVT U395 ( .I(n197), .ZN(n449) );
  NR2D2BWP16P90LVT U396 ( .A1(n249), .A2(n242), .ZN(n240) );
  AOI21D4BWP16P90LVT U397 ( .A1(n266), .A2(n198), .B(n199), .ZN(n197) );
  INVD1BWP16P90LVT U398 ( .I(n126), .ZN(n128) );
  OAI21D1BWP16P90LVT U399 ( .A1(n128), .A2(n63), .B(n64), .ZN(n62) );
  NR2D1BWP16P90LVT U400 ( .A1(n165), .A2(n131), .ZN(n125) );
  OAI21D2BWP16P90LVT U401 ( .A1(n131), .A2(n166), .B(n132), .ZN(n126) );
  NR2D1BWP16P90LVT U402 ( .A1(n158), .A2(n153), .ZN(n149) );
  NR2D1BWP16P90LVT U403 ( .A1(n178), .A2(n173), .ZN(n171) );
  OA21D1BWP16P90 U404 ( .A1(n287), .A2(n293), .B(n456), .Z(n460) );
  NR2D2BWP16P90LVT U405 ( .A1(A[10]), .A2(B[10]), .ZN(n242) );
  CKNR2D1BWP16P90LVT U406 ( .A1(A[18]), .A2(B[18]), .ZN(n173) );
  INR2D1BWP16P90LVT U407 ( .A1(n183), .B1(n178), .ZN(n176) );
  NR2D1BWP16P90LVT U408 ( .A1(A[24]), .A2(B[24]), .ZN(n115) );
  OAI21D1BWP16P90LVT U409 ( .A1(n197), .A2(n39), .B(n40), .ZN(n38) );
  OA21D1BWP16P90LVT U410 ( .A1(n173), .A2(n181), .B(n174), .Z(n446) );
  CKND2D1BWP16P90LVT U411 ( .A1(A[3]), .A2(B[3]), .ZN(n293) );
  ND2D2BWP16P90LVT U412 ( .A1(A[15]), .A2(B[15]), .ZN(n195) );
  AOI21D1BWP16P90LVT U413 ( .A1(n41), .A2(n126), .B(n42), .ZN(n40) );
  CKND2BWP16P90LVT U414 ( .I(n126), .ZN(n452) );
  OAI21D1BWP16P90LVT U415 ( .A1(n128), .A2(n85), .B(n86), .ZN(n84) );
  AOI21D2BWP16P90LVT U416 ( .A1(n91), .A2(n110), .B(n92), .ZN(n86) );
  AOI21D1BWP16P90LVT U417 ( .A1(n83), .A2(n196), .B(n84), .ZN(n82) );
  OAI21D2BWP16P90LVT U418 ( .A1(n295), .A2(n267), .B(n268), .ZN(n266) );
  NR2D2BWP16P90LVT U419 ( .A1(A[19]), .A2(B[19]), .ZN(n158) );
  NR2D1BWP16P90 U420 ( .A1(n231), .A2(n224), .ZN(n447) );
  NR2D2BWP16P90LVT U421 ( .A1(A[4]), .A2(B[4]), .ZN(n287) );
  NR2D1BWP16P90 U422 ( .A1(n127), .A2(n63), .ZN(n61) );
  NR2D1BWP16P90 U423 ( .A1(n127), .A2(n120), .ZN(n118) );
  CKND2BWP16P90LVT U424 ( .I(n125), .ZN(n127) );
  ND2D1BWP16P90LVT U425 ( .A1(n183), .A2(n171), .ZN(n165) );
  AN2D2BWP16P90LVT U426 ( .A1(n451), .A2(n446), .Z(n166) );
  NR2D2BWP16P90LVT U427 ( .A1(A[17]), .A2(B[17]), .ZN(n178) );
  OAI21D2BWP16P90LVT U428 ( .A1(n200), .A2(n235), .B(n201), .ZN(n199) );
  CKNR2D4BWP20P90LVT U429 ( .A1(A[8]), .A2(B[8]), .ZN(n260) );
  OAI21D1BWP16P90 U430 ( .A1(n189), .A2(n195), .B(n190), .ZN(n448) );
  INVD1BWP16P90LVT U431 ( .I(n148), .ZN(n146) );
  NR2D1BWP16P90LVT U432 ( .A1(n292), .A2(n287), .ZN(n281) );
  OAI21D1BWP16P90LVT U433 ( .A1(n242), .A2(n250), .B(n243), .ZN(n241) );
  INVD1BWP16P90LVT U434 ( .I(n266), .ZN(n265) );
  CKND1BWP16P90 U435 ( .I(n93), .ZN(n313) );
  OAI21D1BWP16P90LVT U436 ( .A1(n189), .A2(n195), .B(n190), .ZN(n184) );
  NR2D1BWP16P90LVT U437 ( .A1(n194), .A2(n189), .ZN(n183) );
  ND2D1BWP16P90LVT U438 ( .A1(n254), .A2(n240), .ZN(n234) );
  INVD1BWP16P90 U439 ( .I(n120), .ZN(n316) );
  INVD1BWP16P90 U440 ( .I(n260), .ZN(n331) );
  ND2D1BWP16P90LVT U441 ( .A1(n171), .A2(n184), .ZN(n451) );
  NR2D1BWP16P90 U442 ( .A1(n127), .A2(n98), .ZN(n96) );
  NR2D1BWP16P90 U443 ( .A1(n127), .A2(n76), .ZN(n74) );
  NR2D1BWP16P90 U444 ( .A1(n127), .A2(n52), .ZN(n50) );
  INVD1BWP16P90LVT U445 ( .I(n86), .ZN(n88) );
  NR2D1BWP16P90 U446 ( .A1(n85), .A2(n43), .ZN(n41) );
  INVD1BWP16P90 U447 ( .I(n235), .ZN(n237) );
  INVD1BWP16P90 U448 ( .I(n109), .ZN(n107) );
  INVD1BWP16P90 U449 ( .I(n115), .ZN(n315) );
  INVD1BWP16P90 U450 ( .I(n173), .ZN(n321) );
  INVD1BWP16P90 U451 ( .I(n153), .ZN(n319) );
  INVD1BWP16P90 U452 ( .I(n140), .ZN(n318) );
  INVD1BWP16P90 U453 ( .I(n135), .ZN(n317) );
  NR2D1BWP16P90 U454 ( .A1(n231), .A2(n224), .ZN(n218) );
  AOI21D1BWP16P90 U455 ( .A1(n88), .A2(n78), .B(n79), .ZN(n77) );
  INVD1BWP16P90 U456 ( .I(n211), .ZN(n326) );
  INVD1BWP16P90 U457 ( .I(n204), .ZN(n325) );
  INVD1BWP16P90 U458 ( .I(n242), .ZN(n329) );
  INVD1BWP16P90 U459 ( .I(n224), .ZN(n327) );
  INVD1BWP16P90 U460 ( .I(n254), .ZN(n252) );
  INVD1BWP16P90 U461 ( .I(n287), .ZN(n335) );
  NR2D1BWP16P90 U462 ( .A1(n147), .A2(n140), .ZN(n138) );
  INVD1BWP16P90 U463 ( .I(n263), .ZN(n332) );
  XOR2D1BWP16P90 U464 ( .A1(n265), .A2(n25), .Z(SUM[7]) );
  INR2D1BWP16P90 U465 ( .A1(n447), .B1(n211), .ZN(n209) );
  IOAI21D1BWP16P90 U466 ( .A2(n448), .A1(n178), .B(n181), .ZN(n177) );
  INR2D1BWP16P90 U467 ( .A1(n281), .B1(n276), .ZN(n274) );
  INVD1BWP16P90 U468 ( .I(n298), .ZN(n337) );
  INVD1BWP16P90 U469 ( .I(n231), .ZN(n328) );
  INVD1BWP16P90 U470 ( .I(n249), .ZN(n330) );
  INVD1BWP16P90 U471 ( .I(n194), .ZN(n324) );
  INVD1BWP16P90 U472 ( .I(n301), .ZN(n338) );
  INVD1BWP16P90 U473 ( .I(n292), .ZN(n336) );
  INVD1BWP16P90 U474 ( .I(n293), .ZN(n291) );
  INVD1BWP16P90 U475 ( .I(n195), .ZN(n193) );
  INVD1BWP16P90 U476 ( .I(n305), .ZN(n339) );
  CKND1BWP16P90LVT U477 ( .I(n165), .ZN(n167) );
  CKND1BWP16P90LVT U478 ( .I(n147), .ZN(n145) );
  ND2D1BWP16P90LVT U479 ( .A1(n218), .A2(n202), .ZN(n200) );
  ND2D1BWP16P90LVT U480 ( .A1(n109), .A2(n91), .ZN(n85) );
  CKND1BWP16P90LVT U481 ( .I(n459), .ZN(n108) );
  AOI21D1BWP16P90LVT U482 ( .A1(n168), .A2(n149), .B(n152), .ZN(n148) );
  XOR2D1BWP16P90LVT U483 ( .A1(n191), .A2(n16), .Z(SUM[16]) );
  AOI21D1BWP16P90LVT U484 ( .A1(n449), .A2(n324), .B(n193), .ZN(n191) );
  ND2D1BWP16P90LVT U485 ( .A1(n281), .A2(n269), .ZN(n267) );
  AOI21D1BWP16P90LVT U486 ( .A1(n269), .A2(n282), .B(n270), .ZN(n268) );
  NR2D1BWP16P90LVT U487 ( .A1(n276), .A2(n271), .ZN(n269) );
  XNR2D1BWP16P90LVT U488 ( .A1(n244), .A2(n22), .ZN(SUM[10]) );
  IAOI21D1BWP16P90LVT U489 ( .A2(n457), .A1(n330), .B(n248), .ZN(n246) );
  NR2D1BWP16P90LVT U490 ( .A1(n301), .A2(n298), .ZN(n296) );
  OAI21D1BWP16P90LVT U491 ( .A1(n298), .A2(n302), .B(n299), .ZN(n297) );
  NR2D1BWP16P90LVT U492 ( .A1(n211), .A2(n204), .ZN(n202) );
  XOR2D1BWP16P90LVT U493 ( .A1(n289), .A2(n28), .Z(SUM[4]) );
  NR2D1BWP16P90LVT U494 ( .A1(n140), .A2(n135), .ZN(n133) );
  OAI21D1BWP16P90LVT U495 ( .A1(n224), .A2(n232), .B(n225), .ZN(n219) );
  AOI21D1BWP16P90LVT U496 ( .A1(n202), .A2(n219), .B(n203), .ZN(n201) );
  AOI21D1BWP16P90LVT U497 ( .A1(n133), .A2(n152), .B(n134), .ZN(n132) );
  XNR2D1BWP16P90LVT U498 ( .A1(n206), .A2(n18), .ZN(SUM[14]) );
  CKND1BWP16P90LVT U499 ( .I(n56), .ZN(n310) );
  XNR2D1BWP16P90LVT U500 ( .A1(n215), .A2(n19), .ZN(SUM[13]) );
  XNR2D1BWP16P90LVT U501 ( .A1(n226), .A2(n20), .ZN(SUM[12]) );
  XNR2D1BWP16P90LVT U502 ( .A1(n262), .A2(n24), .ZN(SUM[8]) );
  XNR2D1BWP16P90LVT U503 ( .A1(n251), .A2(n23), .ZN(SUM[9]) );
  XNR2D1BWP16P90LVT U504 ( .A1(n233), .A2(n21), .ZN(SUM[11]) );
  CKND1BWP16P90LVT U505 ( .I(n47), .ZN(n309) );
  NR2D1BWP16P90LVT U506 ( .A1(n127), .A2(n107), .ZN(n105) );
  NR2D1BWP16P90LVT U507 ( .A1(n120), .A2(n115), .ZN(n109) );
  OAI21D1BWP16P90LVT U508 ( .A1(n115), .A2(n123), .B(n116), .ZN(n110) );
  CKND1BWP16P90LVT U509 ( .I(n81), .ZN(n79) );
  AOI21D1BWP16P90LVT U510 ( .A1(n74), .A2(n196), .B(n75), .ZN(n73) );
  CKND1BWP16P90LVT U511 ( .I(n71), .ZN(n311) );
  AOI21D1BWP16P90LVT U512 ( .A1(n209), .A2(n237), .B(n210), .ZN(n208) );
  AOI21D1BWP16P90LVT U513 ( .A1(n459), .A2(n314), .B(n101), .ZN(n99) );
  CKND1BWP16P90LVT U514 ( .I(n103), .ZN(n101) );
  AOI21D1BWP16P90LVT U515 ( .A1(n54), .A2(n88), .B(n55), .ZN(n53) );
  NR2D1BWP16P90LVT U516 ( .A1(n102), .A2(n93), .ZN(n91) );
  IOA21D1BWP16P90LVT U517 ( .A1(n38), .A2(n454), .B(n37), .ZN(SUM[32]) );
  AOI21D1BWP16P90LVT U518 ( .A1(n237), .A2(n328), .B(n230), .ZN(n228) );
  OAI21D1BWP16P90LVT U519 ( .A1(n71), .A2(n81), .B(n72), .ZN(n66) );
  NR2D1BWP16P90LVT U520 ( .A1(n80), .A2(n71), .ZN(n65) );
  INR2D1BWP16P90LVT U521 ( .A1(n65), .B1(n56), .ZN(n54) );
  NR2D1BWP16P90LVT U522 ( .A1(n56), .A2(n47), .ZN(n45) );
  XNR2D1BWP16P90LVT U523 ( .A1(n300), .A2(n30), .ZN(SUM[2]) );
  CKND1BWP16P90LVT U524 ( .I(n102), .ZN(n314) );
  CKND1BWP16P90LVT U525 ( .I(n80), .ZN(n78) );
  XOR2D1BWP16P90LVT U526 ( .A1(n303), .A2(n31), .Z(SUM[1]) );
  NR2D1BWP16P90LVT U527 ( .A1(A[5]), .A2(B[5]), .ZN(n276) );
  INVD1BWP16P90LVT U528 ( .I(CI), .ZN(n307) );
  OAI21D1BWP16P90LVT U529 ( .A1(n287), .A2(n293), .B(n288), .ZN(n282) );
  ND2D1BWP16P90LVT U530 ( .A1(A[9]), .A2(B[9]), .ZN(n250) );
  NR2D1BWP16P90LVT U531 ( .A1(A[14]), .A2(B[14]), .ZN(n204) );
  NR2D1BWP16P90LVT U532 ( .A1(A[7]), .A2(B[7]), .ZN(n263) );
  NR2D1BWP16P90LVT U533 ( .A1(A[1]), .A2(B[1]), .ZN(n301) );
  NR2D1BWP16P90LVT U534 ( .A1(A[6]), .A2(B[6]), .ZN(n271) );
  ND2D1BWP16P90LVT U535 ( .A1(A[1]), .A2(B[1]), .ZN(n302) );
  NR2D1BWP16P90LVT U536 ( .A1(A[0]), .A2(B[0]), .ZN(n305) );
  NR2D1BWP16P90LVT U537 ( .A1(A[13]), .A2(B[13]), .ZN(n211) );
  ND2D1BWP16P90LVT U538 ( .A1(A[0]), .A2(B[0]), .ZN(n306) );
  ND2D1BWP16P90LVT U539 ( .A1(A[11]), .A2(B[11]), .ZN(n232) );
  NR2D1BWP16P90LVT U540 ( .A1(A[11]), .A2(B[11]), .ZN(n231) );
  NR2D1BWP16P90LVT U541 ( .A1(A[2]), .A2(B[2]), .ZN(n298) );
  NR2D1BWP16P90LVT U542 ( .A1(A[22]), .A2(B[22]), .ZN(n135) );
  NR2D1BWP16P90LVT U543 ( .A1(A[3]), .A2(B[3]), .ZN(n292) );
  ND2D1BWP16P90LVT U544 ( .A1(A[16]), .A2(B[16]), .ZN(n190) );
  ND2D1BWP16P90LVT U545 ( .A1(A[19]), .A2(B[19]), .ZN(n161) );
  NR2D1BWP16P90LVT U546 ( .A1(A[23]), .A2(B[23]), .ZN(n120) );
  NR2D1BWP16P90LVT U547 ( .A1(A[26]), .A2(B[26]), .ZN(n93) );
  NR2D1BWP16P90LVT U548 ( .A1(A[15]), .A2(B[15]), .ZN(n194) );
  NR2D1BWP16P90LVT U549 ( .A1(A[25]), .A2(B[25]), .ZN(n102) );
  NR2D1BWP16P90LVT U550 ( .A1(A[28]), .A2(B[28]), .ZN(n71) );
  NR2D1BWP16P90LVT U551 ( .A1(A[30]), .A2(B[30]), .ZN(n47) );
  NR2D1BWP16P90LVT U552 ( .A1(A[29]), .A2(B[29]), .ZN(n56) );
  NR2D1BWP16P90LVT U553 ( .A1(A[27]), .A2(B[27]), .ZN(n80) );
  XNR2D1BWP16P90LVT U554 ( .A1(n32), .A2(CI), .ZN(SUM[0]) );
  OR2D1BWP16P90LVT U555 ( .A1(A[31]), .A2(B[31]), .Z(n454) );
  XOR2D1BWP16P90LVT U556 ( .A1(n182), .A2(n15), .Z(SUM[17]) );
  AOI21D1BWP16P90LVT U557 ( .A1(n449), .A2(n183), .B(n448), .ZN(n182) );
  XOR2D1BWP16P90LVT U558 ( .A1(n162), .A2(n13), .Z(SUM[19]) );
  AOI21D1BWP16P90LVT U559 ( .A1(n449), .A2(n167), .B(n168), .ZN(n162) );
  XOR2D1BWP16P90LVT U560 ( .A1(n175), .A2(n14), .Z(SUM[18]) );
  AOI21D1BWP16P90LVT U561 ( .A1(n449), .A2(n176), .B(n177), .ZN(n175) );
  XOR2D1BWP16P90LVT U562 ( .A1(n144), .A2(n11), .Z(SUM[21]) );
  AOI21D1BWP16P90LVT U563 ( .A1(n449), .A2(n145), .B(n146), .ZN(n144) );
  XOR2D1BWP16P90LVT U564 ( .A1(n155), .A2(n12), .Z(SUM[20]) );
  AOI21D1BWP16P90LVT U565 ( .A1(n449), .A2(n156), .B(n157), .ZN(n155) );
  XOR2D1BWP16P90LVT U566 ( .A1(n137), .A2(n10), .Z(SUM[22]) );
  AOI21D1BWP16P90LVT U567 ( .A1(n449), .A2(n138), .B(n139), .ZN(n137) );
  XOR2D1BWP16P90LVT U568 ( .A1(n273), .A2(n26), .Z(SUM[6]) );
  XOR2D1BWP16P90LVT U569 ( .A1(n124), .A2(n9), .Z(SUM[23]) );
  AOI21D1BWP16P90LVT U570 ( .A1(n449), .A2(n125), .B(n126), .ZN(n124) );
  XNR2D1BWP16P90LVT U571 ( .A1(n38), .A2(n1), .ZN(SUM[31]) );
  AOI21D1BWP16P90 U572 ( .A1(n458), .A2(n281), .B(n282), .ZN(n280) );
  AOI21D1BWP16P90LVT U573 ( .A1(n458), .A2(n336), .B(n291), .ZN(n289) );
  XNR2D1BWP16P90LVT U574 ( .A1(n458), .A2(n29), .ZN(SUM[3]) );
  AOI21D1BWP16P90LVT U575 ( .A1(n274), .A2(n458), .B(n275), .ZN(n273) );
  XOR2D1BWP16P90LVT U576 ( .A1(n280), .A2(n27), .Z(SUM[5]) );
  OAI21D1BWP16P90 U577 ( .A1(n221), .A2(n211), .B(n214), .ZN(n210) );
  INVD1BWP16P90 U578 ( .I(n178), .ZN(n322) );
  INVD1BWP16P90 U579 ( .I(n234), .ZN(n236) );
  OR2D1BWP16P90LVT U580 ( .A1(A[6]), .A2(B[6]), .Z(n455) );
  CKND1BWP16P90LVT U581 ( .I(n158), .ZN(n320) );
  NR2D1BWP16P90 U582 ( .A1(n165), .A2(n158), .ZN(n156) );
  XOR2D1BWP16P90LVT U583 ( .A1(n117), .A2(n8), .Z(SUM[24]) );
  AOI21D1BWP16P90LVT U584 ( .A1(n118), .A2(n196), .B(n119), .ZN(n117) );
  OAI21D1BWP16P90 U585 ( .A1(n460), .A2(n276), .B(n279), .ZN(n275) );
  CKND1BWP20P90LVT U586 ( .I(n276), .ZN(n334) );
  XOR2D1BWP16P90LVT U587 ( .A1(n104), .A2(n7), .Z(SUM[25]) );
  AOI21D1BWP16P90LVT U588 ( .A1(n105), .A2(n196), .B(n106), .ZN(n104) );
  NR2D1BWP16P90 U589 ( .A1(n127), .A2(n85), .ZN(n83) );
  CKND1BWP16P90LVT U590 ( .I(n85), .ZN(n87) );
  ND2D1BWP16P90LVT U591 ( .A1(A[4]), .A2(B[4]), .ZN(n456) );
  AOI21D1BWP16P90LVT U592 ( .A1(n88), .A2(n65), .B(n66), .ZN(n64) );
  CKND1BWP16P90LVT U593 ( .I(n66), .ZN(n68) );
  AOI21D1BWP16P90LVT U594 ( .A1(n45), .A2(n66), .B(n46), .ZN(n44) );
  ND2D1BWP16P90 U595 ( .A1(n339), .A2(n306), .ZN(n32) );
  CKND1BWP16P90LVT U596 ( .I(n189), .ZN(n323) );
  XOR2D1BWP16P90LVT U597 ( .A1(n95), .A2(n6), .Z(SUM[26]) );
  AOI21D1BWP16P90LVT U598 ( .A1(n96), .A2(n196), .B(n97), .ZN(n95) );
  XOR2D1BWP16P90LVT U599 ( .A1(n73), .A2(n4), .Z(SUM[28]) );
  AOI21D1BWP16P90LVT U600 ( .A1(n50), .A2(n196), .B(n51), .ZN(n49) );
  AOI21D1BWP16P90LVT U601 ( .A1(n61), .A2(n196), .B(n62), .ZN(n60) );
  CKND1BWP16P90LVT U602 ( .I(n250), .ZN(n248) );
  CKND1BWP16P90LVT U603 ( .I(n232), .ZN(n230) );
  INVD1BWP16P90 U604 ( .I(n295), .ZN(n458) );
  OAI21D1BWP16P90 U605 ( .A1(n166), .A2(n158), .B(n161), .ZN(n157) );
  INVD1BWP16P90LVT U606 ( .I(n166), .ZN(n168) );
  OAI21D1BWP16P90 U607 ( .A1(n115), .A2(n123), .B(n116), .ZN(n459) );
  XOR2D1BWP16P90LVT U608 ( .A1(n60), .A2(n3), .Z(SUM[29]) );
  CKND1BWP16P90LVT U609 ( .I(n304), .ZN(n303) );
  XOR2D1BWP16P90LVT U610 ( .A1(n49), .A2(n2), .Z(SUM[30]) );
  INVD1BWP16P90 U611 ( .I(n219), .ZN(n221) );
  AOI21D1BWP16P90 U612 ( .A1(n237), .A2(n447), .B(n219), .ZN(n217) );
  XOR2D1BWP16P90LVT U613 ( .A1(n82), .A2(n5), .Z(SUM[27]) );
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

