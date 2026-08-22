// Auto-generated — do not edit.
// Source: py/Softmax/softmax_golden.py -v
// Format: Q16.16 signed 32-bit fixed-point, Algorithm 3
//
// 1050 test cases, MAX_N = 500.  Each test is a vector of
// length N (variable), stored as a parallel pair of `.mem` files
// under vectors/softmax/  — one pair per test case:
//   tc{idx:02d}_in.mem    Q16.16 input vector
//   tc{idx:02d}_out.mem   Q16.16 expected output
//
// `\`include`-able from inside any tb module so the same golden
// vectors can be checked at the unit, sub-env, and top-model level.
//
// Provides:
//   localparam int SOFTMAX_NUM_TESTS
//   localparam int SOFTMAX_MAX_N
//   reg [10:0]     SOFTMAX_TC_N      [0:SOFTMAX_NUM_TESTS-1]
//   reg [31:0]     SOFTMAX_X         [0:SOFTMAX_MAX_N-1]
//   reg [31:0]     SOFTMAX_Y_EXP     [0:SOFTMAX_MAX_N-1]
//   integer        SOFTMAX_N         // length of currently-loaded test
//   task           softmax_init_meta()              // populate SOFTMAX_TC_N
//   task           softmax_load_test(int idx)       // $readmemh test idx
//   function       softmax_test_name(int idx) → string
//
// Example use (inside an `initial` block of any tb):
//
//   softmax_init_meta();
//   for (int i = 0; i < SOFTMAX_NUM_TESTS; i++) begin
//       softmax_load_test(i);
//       // stage SOFTMAX_X into SRAM, drive DUT, wait done
//       // compare sram[OUT_BASE..] against SOFTMAX_Y_EXP[0..SOFTMAX_N-1]
//   end

localparam int SOFTMAX_NUM_TESTS = 1050;
localparam int SOFTMAX_MAX_N     = 500;

// Length of each test case (vector size N).  Populated by softmax_init_meta.
reg [10:0] SOFTMAX_TC_N [0:SOFTMAX_NUM_TESTS-1];

// Storage for the currently-loaded test case.  Filled by softmax_load_test.
reg [31:0] SOFTMAX_X      [0:SOFTMAX_MAX_N-1];
reg [31:0] SOFTMAX_Y_EXP  [0:SOFTMAX_MAX_N-1];
integer    SOFTMAX_N;

// Populate SOFTMAX_TC_N.  Call once at the top of `initial`.
task automatic softmax_init_meta;
begin
    SOFTMAX_TC_N[ 0] =  8;  // bin neg_extreme  N=8  LOW
    SOFTMAX_TC_N[ 1] =  8;  // bin neg_high     N=8  LOW
    SOFTMAX_TC_N[ 2] =  8;  // bin neg_low      N=8  LOW
    SOFTMAX_TC_N[ 3] =  8;  // bin pos_low      N=8  LOW
    SOFTMAX_TC_N[ 4] =  8;  // bin pos_high     N=8  LOW
    SOFTMAX_TC_N[ 5] =  8;  // bin pos_extreme  N=8  LOW
    SOFTMAX_TC_N[ 6] =  8;  // bin neg_extreme  N=8  HIGH
    SOFTMAX_TC_N[ 7] =  8;  // bin neg_high     N=8  HIGH
    SOFTMAX_TC_N[ 8] =  8;  // bin neg_low      N=8  HIGH
    SOFTMAX_TC_N[ 9] =  8;  // bin pos_low      N=8  HIGH
    SOFTMAX_TC_N[10] =  8;  // bin pos_high     N=8  HIGH
    SOFTMAX_TC_N[11] =  8;  // bin pos_extreme  N=8  HIGH
    SOFTMAX_TC_N[12] =  6;  // all 6 bins symmetric  N=6
    SOFTMAX_TC_N[13] =  8;  // bimodal extremes      N=8
    SOFTMAX_TC_N[14] =  9;  // bin boundaries        N=9
    SOFTMAX_TC_N[15] =  7;  // neg dominant          N=7
    SOFTMAX_TC_N[16] =  7;  // pos dominant          N=7
    SOFTMAX_TC_N[17] =  8;  // half neg / half pos   N=8
    SOFTMAX_TC_N[18] = 12;  // step across bins      N=12
    SOFTMAX_TC_N[19] =  8;  // alt extremes          N=8
    SOFTMAX_TC_N[20] =  8;  // alt highs             N=8
    SOFTMAX_TC_N[21] =  8;  // alt lows              N=8
    SOFTMAX_TC_N[22] =  8;  // zeros + one extreme   N=8
    SOFTMAX_TC_N[23] =  8;  // zeros + one neg_extr  N=8
    SOFTMAX_TC_N[24] =  8;  // zero variance        N=8
    SOFTMAX_TC_N[25] =  8;  // equal pos            N=8
    SOFTMAX_TC_N[26] =  8;  // equal neg            N=8
    SOFTMAX_TC_N[27] =  8;  // tight 100 ±0.01      N=8
    SOFTMAX_TC_N[28] =  8;  // wide -300..400       N=8
    SOFTMAX_TC_N[29] =  4;  // very wide -32k..32k  N=4
    SOFTMAX_TC_N[30] =  1;  // N=1  single positive
    SOFTMAX_TC_N[31] =  2;  // N=2  cross bins
    SOFTMAX_TC_N[32] =  4;  // N=4  across all bin signs
    SOFTMAX_TC_N[33] = 16;  // N=16 wide cross-bin sweep
    SOFTMAX_TC_N[34] = 32;  // N=32 ascending across bins
    SOFTMAX_TC_N[35] = 64;  // N=64 alternating extremes
    SOFTMAX_TC_N[36] =  8;  // one_hot start            N=8
    SOFTMAX_TC_N[37] =  8;  // one_hot end              N=8
    SOFTMAX_TC_N[38] = 16;  // one_hot middle           N=16
    SOFTMAX_TC_N[39] =  8;  // ascending                N=8
    SOFTMAX_TC_N[40] =  8;  // descending               N=8
    SOFTMAX_TC_N[41] =  8;  // uniform                  N=8
    SOFTMAX_TC_N[42] =  8;  // near uniform             N=8
    SOFTMAX_TC_N[43] =  4;  // boundary -201            N=4
    SOFTMAX_TC_N[44] =  4;  // boundary +201            N=4
    SOFTMAX_TC_N[45] =  4;  // boundary -11 / -10
    SOFTMAX_TC_N[46] =  4;  // boundary +10 / +11
    SOFTMAX_TC_N[47] =  2;  // Q16.16 range edges       N=2
    SOFTMAX_TC_N[48] = 16;  // alt low                  N=16
    SOFTMAX_TC_N[49] = 16;  // alt high                 N=16
    SOFTMAX_TC_N[50] = 194;  // rand-000 N=194
    SOFTMAX_TC_N[51] = 255;  // rand-001 N=255
    SOFTMAX_TC_N[52] = 301;  // rand-002 N=301
    SOFTMAX_TC_N[53] = 498;  // rand-003 N=498
    SOFTMAX_TC_N[54] = 351;  // rand-004 N=351
    SOFTMAX_TC_N[55] = 296;  // rand-005 N=296
    SOFTMAX_TC_N[56] = 94;  // rand-006 N=94
    SOFTMAX_TC_N[57] = 436;  // rand-007 N=436
    SOFTMAX_TC_N[58] = 410;  // rand-008 N=410
    SOFTMAX_TC_N[59] = 496;  // rand-009 N=496
    SOFTMAX_TC_N[60] =  2;  // rand-010 N= 2
    SOFTMAX_TC_N[61] = 327;  // rand-011 N=327
    SOFTMAX_TC_N[62] = 431;  // rand-012 N=431
    SOFTMAX_TC_N[63] = 461;  // rand-013 N=461
    SOFTMAX_TC_N[64] = 73;  // rand-014 N=73
    SOFTMAX_TC_N[65] = 277;  // rand-015 N=277
    SOFTMAX_TC_N[66] = 122;  // rand-016 N=122
    SOFTMAX_TC_N[67] = 345;  // rand-017 N=345
    SOFTMAX_TC_N[68] = 160;  // rand-018 N=160
    SOFTMAX_TC_N[69] = 255;  // rand-019 N=255
    SOFTMAX_TC_N[70] = 12;  // rand-020 N=12
    SOFTMAX_TC_N[71] = 118;  // rand-021 N=118
    SOFTMAX_TC_N[72] = 317;  // rand-022 N=317
    SOFTMAX_TC_N[73] = 270;  // rand-023 N=270
    SOFTMAX_TC_N[74] = 428;  // rand-024 N=428
    SOFTMAX_TC_N[75] = 336;  // rand-025 N=336
    SOFTMAX_TC_N[76] = 438;  // rand-026 N=438
    SOFTMAX_TC_N[77] = 252;  // rand-027 N=252
    SOFTMAX_TC_N[78] = 148;  // rand-028 N=148
    SOFTMAX_TC_N[79] = 235;  // rand-029 N=235
    SOFTMAX_TC_N[80] = 37;  // rand-030 N=37
    SOFTMAX_TC_N[81] = 299;  // rand-031 N=299
    SOFTMAX_TC_N[82] = 146;  // rand-032 N=146
    SOFTMAX_TC_N[83] = 298;  // rand-033 N=298
    SOFTMAX_TC_N[84] = 93;  // rand-034 N=93
    SOFTMAX_TC_N[85] = 462;  // rand-035 N=462
    SOFTMAX_TC_N[86] = 89;  // rand-036 N=89
    SOFTMAX_TC_N[87] = 377;  // rand-037 N=377
    SOFTMAX_TC_N[88] = 93;  // rand-038 N=93
    SOFTMAX_TC_N[89] = 159;  // rand-039 N=159
    SOFTMAX_TC_N[90] = 131;  // rand-040 N=131
    SOFTMAX_TC_N[91] = 63;  // rand-041 N=63
    SOFTMAX_TC_N[92] = 95;  // rand-042 N=95
    SOFTMAX_TC_N[93] = 19;  // rand-043 N=19
    SOFTMAX_TC_N[94] = 121;  // rand-044 N=121
    SOFTMAX_TC_N[95] = 161;  // rand-045 N=161
    SOFTMAX_TC_N[96] = 187;  // rand-046 N=187
    SOFTMAX_TC_N[97] = 215;  // rand-047 N=215
    SOFTMAX_TC_N[98] = 372;  // rand-048 N=372
    SOFTMAX_TC_N[99] = 175;  // rand-049 N=175
    SOFTMAX_TC_N[100] = 299;  // rand-050 N=299
    SOFTMAX_TC_N[101] = 284;  // rand-051 N=284
    SOFTMAX_TC_N[102] = 281;  // rand-052 N=281
    SOFTMAX_TC_N[103] = 237;  // rand-053 N=237
    SOFTMAX_TC_N[104] = 377;  // rand-054 N=377
    SOFTMAX_TC_N[105] = 21;  // rand-055 N=21
    SOFTMAX_TC_N[106] = 320;  // rand-056 N=320
    SOFTMAX_TC_N[107] = 496;  // rand-057 N=496
    SOFTMAX_TC_N[108] = 328;  // rand-058 N=328
    SOFTMAX_TC_N[109] = 163;  // rand-059 N=163
    SOFTMAX_TC_N[110] = 490;  // rand-060 N=490
    SOFTMAX_TC_N[111] =  2;  // rand-061 N= 2
    SOFTMAX_TC_N[112] = 257;  // rand-062 N=257
    SOFTMAX_TC_N[113] = 180;  // rand-063 N=180
    SOFTMAX_TC_N[114] = 422;  // rand-064 N=422
    SOFTMAX_TC_N[115] = 185;  // rand-065 N=185
    SOFTMAX_TC_N[116] = 313;  // rand-066 N=313
    SOFTMAX_TC_N[117] = 350;  // rand-067 N=350
    SOFTMAX_TC_N[118] = 407;  // rand-068 N=407
    SOFTMAX_TC_N[119] = 414;  // rand-069 N=414
    SOFTMAX_TC_N[120] = 448;  // rand-070 N=448
    SOFTMAX_TC_N[121] = 353;  // rand-071 N=353
    SOFTMAX_TC_N[122] = 277;  // rand-072 N=277
    SOFTMAX_TC_N[123] = 55;  // rand-073 N=55
    SOFTMAX_TC_N[124] = 376;  // rand-074 N=376
    SOFTMAX_TC_N[125] = 423;  // rand-075 N=423
    SOFTMAX_TC_N[126] = 178;  // rand-076 N=178
    SOFTMAX_TC_N[127] =  1;  // rand-077 N= 1
    SOFTMAX_TC_N[128] = 497;  // rand-078 N=497
    SOFTMAX_TC_N[129] = 175;  // rand-079 N=175
    SOFTMAX_TC_N[130] = 491;  // rand-080 N=491
    SOFTMAX_TC_N[131] = 209;  // rand-081 N=209
    SOFTMAX_TC_N[132] = 18;  // rand-082 N=18
    SOFTMAX_TC_N[133] = 169;  // rand-083 N=169
    SOFTMAX_TC_N[134] = 314;  // rand-084 N=314
    SOFTMAX_TC_N[135] = 173;  // rand-085 N=173
    SOFTMAX_TC_N[136] = 389;  // rand-086 N=389
    SOFTMAX_TC_N[137] = 12;  // rand-087 N=12
    SOFTMAX_TC_N[138] = 33;  // rand-088 N=33
    SOFTMAX_TC_N[139] = 127;  // rand-089 N=127
    SOFTMAX_TC_N[140] = 445;  // rand-090 N=445
    SOFTMAX_TC_N[141] = 413;  // rand-091 N=413
    SOFTMAX_TC_N[142] = 466;  // rand-092 N=466
    SOFTMAX_TC_N[143] = 387;  // rand-093 N=387
    SOFTMAX_TC_N[144] = 199;  // rand-094 N=199
    SOFTMAX_TC_N[145] = 458;  // rand-095 N=458
    SOFTMAX_TC_N[146] = 125;  // rand-096 N=125
    SOFTMAX_TC_N[147] = 258;  // rand-097 N=258
    SOFTMAX_TC_N[148] = 258;  // rand-098 N=258
    SOFTMAX_TC_N[149] = 199;  // rand-099 N=199
    SOFTMAX_TC_N[150] = 167;  // rand-100 N=167
    SOFTMAX_TC_N[151] = 308;  // rand-101 N=308
    SOFTMAX_TC_N[152] = 189;  // rand-102 N=189
    SOFTMAX_TC_N[153] = 173;  // rand-103 N=173
    SOFTMAX_TC_N[154] = 187;  // rand-104 N=187
    SOFTMAX_TC_N[155] = 178;  // rand-105 N=178
    SOFTMAX_TC_N[156] = 122;  // rand-106 N=122
    SOFTMAX_TC_N[157] = 334;  // rand-107 N=334
    SOFTMAX_TC_N[158] = 129;  // rand-108 N=129
    SOFTMAX_TC_N[159] = 266;  // rand-109 N=266
    SOFTMAX_TC_N[160] = 10;  // rand-110 N=10
    SOFTMAX_TC_N[161] = 369;  // rand-111 N=369
    SOFTMAX_TC_N[162] = 338;  // rand-112 N=338
    SOFTMAX_TC_N[163] = 322;  // rand-113 N=322
    SOFTMAX_TC_N[164] = 25;  // rand-114 N=25
    SOFTMAX_TC_N[165] = 163;  // rand-115 N=163
    SOFTMAX_TC_N[166] = 144;  // rand-116 N=144
    SOFTMAX_TC_N[167] = 339;  // rand-117 N=339
    SOFTMAX_TC_N[168] = 98;  // rand-118 N=98
    SOFTMAX_TC_N[169] = 239;  // rand-119 N=239
    SOFTMAX_TC_N[170] = 417;  // rand-120 N=417
    SOFTMAX_TC_N[171] = 438;  // rand-121 N=438
    SOFTMAX_TC_N[172] = 61;  // rand-122 N=61
    SOFTMAX_TC_N[173] = 457;  // rand-123 N=457
    SOFTMAX_TC_N[174] = 238;  // rand-124 N=238
    SOFTMAX_TC_N[175] = 147;  // rand-125 N=147
    SOFTMAX_TC_N[176] = 114;  // rand-126 N=114
    SOFTMAX_TC_N[177] = 37;  // rand-127 N=37
    SOFTMAX_TC_N[178] = 162;  // rand-128 N=162
    SOFTMAX_TC_N[179] = 226;  // rand-129 N=226
    SOFTMAX_TC_N[180] = 191;  // rand-130 N=191
    SOFTMAX_TC_N[181] = 418;  // rand-131 N=418
    SOFTMAX_TC_N[182] = 301;  // rand-132 N=301
    SOFTMAX_TC_N[183] = 18;  // rand-133 N=18
    SOFTMAX_TC_N[184] = 136;  // rand-134 N=136
    SOFTMAX_TC_N[185] = 216;  // rand-135 N=216
    SOFTMAX_TC_N[186] = 406;  // rand-136 N=406
    SOFTMAX_TC_N[187] = 477;  // rand-137 N=477
    SOFTMAX_TC_N[188] = 496;  // rand-138 N=496
    SOFTMAX_TC_N[189] = 328;  // rand-139 N=328
    SOFTMAX_TC_N[190] = 26;  // rand-140 N=26
    SOFTMAX_TC_N[191] = 254;  // rand-141 N=254
    SOFTMAX_TC_N[192] = 201;  // rand-142 N=201
    SOFTMAX_TC_N[193] = 143;  // rand-143 N=143
    SOFTMAX_TC_N[194] = 347;  // rand-144 N=347
    SOFTMAX_TC_N[195] = 120;  // rand-145 N=120
    SOFTMAX_TC_N[196] = 439;  // rand-146 N=439
    SOFTMAX_TC_N[197] =  4;  // rand-147 N= 4
    SOFTMAX_TC_N[198] = 463;  // rand-148 N=463
    SOFTMAX_TC_N[199] = 498;  // rand-149 N=498
    SOFTMAX_TC_N[200] = 375;  // rand-150 N=375
    SOFTMAX_TC_N[201] = 484;  // rand-151 N=484
    SOFTMAX_TC_N[202] = 178;  // rand-152 N=178
    SOFTMAX_TC_N[203] = 84;  // rand-153 N=84
    SOFTMAX_TC_N[204] = 116;  // rand-154 N=116
    SOFTMAX_TC_N[205] = 347;  // rand-155 N=347
    SOFTMAX_TC_N[206] = 431;  // rand-156 N=431
    SOFTMAX_TC_N[207] = 296;  // rand-157 N=296
    SOFTMAX_TC_N[208] = 138;  // rand-158 N=138
    SOFTMAX_TC_N[209] = 302;  // rand-159 N=302
    SOFTMAX_TC_N[210] = 397;  // rand-160 N=397
    SOFTMAX_TC_N[211] = 300;  // rand-161 N=300
    SOFTMAX_TC_N[212] = 156;  // rand-162 N=156
    SOFTMAX_TC_N[213] = 32;  // rand-163 N=32
    SOFTMAX_TC_N[214] = 279;  // rand-164 N=279
    SOFTMAX_TC_N[215] = 500;  // rand-165 N=500
    SOFTMAX_TC_N[216] = 310;  // rand-166 N=310
    SOFTMAX_TC_N[217] = 124;  // rand-167 N=124
    SOFTMAX_TC_N[218] = 442;  // rand-168 N=442
    SOFTMAX_TC_N[219] = 31;  // rand-169 N=31
    SOFTMAX_TC_N[220] = 346;  // rand-170 N=346
    SOFTMAX_TC_N[221] = 106;  // rand-171 N=106
    SOFTMAX_TC_N[222] = 200;  // rand-172 N=200
    SOFTMAX_TC_N[223] = 276;  // rand-173 N=276
    SOFTMAX_TC_N[224] = 135;  // rand-174 N=135
    SOFTMAX_TC_N[225] = 305;  // rand-175 N=305
    SOFTMAX_TC_N[226] = 204;  // rand-176 N=204
    SOFTMAX_TC_N[227] = 97;  // rand-177 N=97
    SOFTMAX_TC_N[228] = 409;  // rand-178 N=409
    SOFTMAX_TC_N[229] = 265;  // rand-179 N=265
    SOFTMAX_TC_N[230] = 332;  // rand-180 N=332
    SOFTMAX_TC_N[231] = 121;  // rand-181 N=121
    SOFTMAX_TC_N[232] = 307;  // rand-182 N=307
    SOFTMAX_TC_N[233] = 122;  // rand-183 N=122
    SOFTMAX_TC_N[234] = 252;  // rand-184 N=252
    SOFTMAX_TC_N[235] = 402;  // rand-185 N=402
    SOFTMAX_TC_N[236] = 335;  // rand-186 N=335
    SOFTMAX_TC_N[237] = 476;  // rand-187 N=476
    SOFTMAX_TC_N[238] = 419;  // rand-188 N=419
    SOFTMAX_TC_N[239] = 114;  // rand-189 N=114
    SOFTMAX_TC_N[240] = 297;  // rand-190 N=297
    SOFTMAX_TC_N[241] = 400;  // rand-191 N=400
    SOFTMAX_TC_N[242] = 280;  // rand-192 N=280
    SOFTMAX_TC_N[243] = 290;  // rand-193 N=290
    SOFTMAX_TC_N[244] = 302;  // rand-194 N=302
    SOFTMAX_TC_N[245] = 252;  // rand-195 N=252
    SOFTMAX_TC_N[246] = 406;  // rand-196 N=406
    SOFTMAX_TC_N[247] = 372;  // rand-197 N=372
    SOFTMAX_TC_N[248] = 52;  // rand-198 N=52
    SOFTMAX_TC_N[249] = 177;  // rand-199 N=177
    SOFTMAX_TC_N[250] = 157;  // rand-200 N=157
    SOFTMAX_TC_N[251] = 373;  // rand-201 N=373
    SOFTMAX_TC_N[252] = 43;  // rand-202 N=43
    SOFTMAX_TC_N[253] = 153;  // rand-203 N=153
    SOFTMAX_TC_N[254] = 207;  // rand-204 N=207
    SOFTMAX_TC_N[255] = 229;  // rand-205 N=229
    SOFTMAX_TC_N[256] = 36;  // rand-206 N=36
    SOFTMAX_TC_N[257] = 111;  // rand-207 N=111
    SOFTMAX_TC_N[258] = 258;  // rand-208 N=258
    SOFTMAX_TC_N[259] = 13;  // rand-209 N=13
    SOFTMAX_TC_N[260] = 205;  // rand-210 N=205
    SOFTMAX_TC_N[261] = 48;  // rand-211 N=48
    SOFTMAX_TC_N[262] = 256;  // rand-212 N=256
    SOFTMAX_TC_N[263] = 399;  // rand-213 N=399
    SOFTMAX_TC_N[264] = 286;  // rand-214 N=286
    SOFTMAX_TC_N[265] = 334;  // rand-215 N=334
    SOFTMAX_TC_N[266] = 349;  // rand-216 N=349
    SOFTMAX_TC_N[267] =  2;  // rand-217 N= 2
    SOFTMAX_TC_N[268] = 478;  // rand-218 N=478
    SOFTMAX_TC_N[269] = 460;  // rand-219 N=460
    SOFTMAX_TC_N[270] = 167;  // rand-220 N=167
    SOFTMAX_TC_N[271] = 62;  // rand-221 N=62
    SOFTMAX_TC_N[272] = 220;  // rand-222 N=220
    SOFTMAX_TC_N[273] = 104;  // rand-223 N=104
    SOFTMAX_TC_N[274] = 429;  // rand-224 N=429
    SOFTMAX_TC_N[275] = 430;  // rand-225 N=430
    SOFTMAX_TC_N[276] = 106;  // rand-226 N=106
    SOFTMAX_TC_N[277] = 81;  // rand-227 N=81
    SOFTMAX_TC_N[278] = 447;  // rand-228 N=447
    SOFTMAX_TC_N[279] = 190;  // rand-229 N=190
    SOFTMAX_TC_N[280] = 252;  // rand-230 N=252
    SOFTMAX_TC_N[281] = 495;  // rand-231 N=495
    SOFTMAX_TC_N[282] = 392;  // rand-232 N=392
    SOFTMAX_TC_N[283] = 63;  // rand-233 N=63
    SOFTMAX_TC_N[284] = 108;  // rand-234 N=108
    SOFTMAX_TC_N[285] = 75;  // rand-235 N=75
    SOFTMAX_TC_N[286] = 153;  // rand-236 N=153
    SOFTMAX_TC_N[287] = 493;  // rand-237 N=493
    SOFTMAX_TC_N[288] = 242;  // rand-238 N=242
    SOFTMAX_TC_N[289] = 21;  // rand-239 N=21
    SOFTMAX_TC_N[290] = 438;  // rand-240 N=438
    SOFTMAX_TC_N[291] = 159;  // rand-241 N=159
    SOFTMAX_TC_N[292] = 164;  // rand-242 N=164
    SOFTMAX_TC_N[293] = 135;  // rand-243 N=135
    SOFTMAX_TC_N[294] = 238;  // rand-244 N=238
    SOFTMAX_TC_N[295] = 244;  // rand-245 N=244
    SOFTMAX_TC_N[296] = 411;  // rand-246 N=411
    SOFTMAX_TC_N[297] = 241;  // rand-247 N=241
    SOFTMAX_TC_N[298] =  8;  // rand-248 N= 8
    SOFTMAX_TC_N[299] = 154;  // rand-249 N=154
    SOFTMAX_TC_N[300] = 322;  // rand-250 N=322
    SOFTMAX_TC_N[301] = 465;  // rand-251 N=465
    SOFTMAX_TC_N[302] = 121;  // rand-252 N=121
    SOFTMAX_TC_N[303] =  7;  // rand-253 N= 7
    SOFTMAX_TC_N[304] = 398;  // rand-254 N=398
    SOFTMAX_TC_N[305] = 241;  // rand-255 N=241
    SOFTMAX_TC_N[306] = 401;  // rand-256 N=401
    SOFTMAX_TC_N[307] =  5;  // rand-257 N= 5
    SOFTMAX_TC_N[308] = 109;  // rand-258 N=109
    SOFTMAX_TC_N[309] = 314;  // rand-259 N=314
    SOFTMAX_TC_N[310] = 255;  // rand-260 N=255
    SOFTMAX_TC_N[311] = 271;  // rand-261 N=271
    SOFTMAX_TC_N[312] = 291;  // rand-262 N=291
    SOFTMAX_TC_N[313] = 426;  // rand-263 N=426
    SOFTMAX_TC_N[314] = 163;  // rand-264 N=163
    SOFTMAX_TC_N[315] = 183;  // rand-265 N=183
    SOFTMAX_TC_N[316] = 420;  // rand-266 N=420
    SOFTMAX_TC_N[317] = 152;  // rand-267 N=152
    SOFTMAX_TC_N[318] = 474;  // rand-268 N=474
    SOFTMAX_TC_N[319] = 452;  // rand-269 N=452
    SOFTMAX_TC_N[320] = 166;  // rand-270 N=166
    SOFTMAX_TC_N[321] = 256;  // rand-271 N=256
    SOFTMAX_TC_N[322] = 278;  // rand-272 N=278
    SOFTMAX_TC_N[323] = 274;  // rand-273 N=274
    SOFTMAX_TC_N[324] = 405;  // rand-274 N=405
    SOFTMAX_TC_N[325] = 478;  // rand-275 N=478
    SOFTMAX_TC_N[326] = 369;  // rand-276 N=369
    SOFTMAX_TC_N[327] = 127;  // rand-277 N=127
    SOFTMAX_TC_N[328] = 265;  // rand-278 N=265
    SOFTMAX_TC_N[329] = 485;  // rand-279 N=485
    SOFTMAX_TC_N[330] = 364;  // rand-280 N=364
    SOFTMAX_TC_N[331] = 281;  // rand-281 N=281
    SOFTMAX_TC_N[332] = 136;  // rand-282 N=136
    SOFTMAX_TC_N[333] =  3;  // rand-283 N= 3
    SOFTMAX_TC_N[334] = 140;  // rand-284 N=140
    SOFTMAX_TC_N[335] = 447;  // rand-285 N=447
    SOFTMAX_TC_N[336] = 189;  // rand-286 N=189
    SOFTMAX_TC_N[337] = 166;  // rand-287 N=166
    SOFTMAX_TC_N[338] = 425;  // rand-288 N=425
    SOFTMAX_TC_N[339] = 118;  // rand-289 N=118
    SOFTMAX_TC_N[340] = 442;  // rand-290 N=442
    SOFTMAX_TC_N[341] =  6;  // rand-291 N= 6
    SOFTMAX_TC_N[342] = 111;  // rand-292 N=111
    SOFTMAX_TC_N[343] = 92;  // rand-293 N=92
    SOFTMAX_TC_N[344] = 42;  // rand-294 N=42
    SOFTMAX_TC_N[345] = 257;  // rand-295 N=257
    SOFTMAX_TC_N[346] = 327;  // rand-296 N=327
    SOFTMAX_TC_N[347] = 444;  // rand-297 N=444
    SOFTMAX_TC_N[348] = 289;  // rand-298 N=289
    SOFTMAX_TC_N[349] = 272;  // rand-299 N=272
    SOFTMAX_TC_N[350] =  9;  // rand-300 N= 9
    SOFTMAX_TC_N[351] = 308;  // rand-301 N=308
    SOFTMAX_TC_N[352] = 446;  // rand-302 N=446
    SOFTMAX_TC_N[353] = 299;  // rand-303 N=299
    SOFTMAX_TC_N[354] = 161;  // rand-304 N=161
    SOFTMAX_TC_N[355] = 246;  // rand-305 N=246
    SOFTMAX_TC_N[356] = 289;  // rand-306 N=289
    SOFTMAX_TC_N[357] = 313;  // rand-307 N=313
    SOFTMAX_TC_N[358] = 67;  // rand-308 N=67
    SOFTMAX_TC_N[359] = 17;  // rand-309 N=17
    SOFTMAX_TC_N[360] = 266;  // rand-310 N=266
    SOFTMAX_TC_N[361] =  3;  // rand-311 N= 3
    SOFTMAX_TC_N[362] = 88;  // rand-312 N=88
    SOFTMAX_TC_N[363] = 80;  // rand-313 N=80
    SOFTMAX_TC_N[364] = 499;  // rand-314 N=499
    SOFTMAX_TC_N[365] = 180;  // rand-315 N=180
    SOFTMAX_TC_N[366] = 57;  // rand-316 N=57
    SOFTMAX_TC_N[367] = 13;  // rand-317 N=13
    SOFTMAX_TC_N[368] = 170;  // rand-318 N=170
    SOFTMAX_TC_N[369] = 461;  // rand-319 N=461
    SOFTMAX_TC_N[370] = 226;  // rand-320 N=226
    SOFTMAX_TC_N[371] = 480;  // rand-321 N=480
    SOFTMAX_TC_N[372] = 398;  // rand-322 N=398
    SOFTMAX_TC_N[373] = 147;  // rand-323 N=147
    SOFTMAX_TC_N[374] = 377;  // rand-324 N=377
    SOFTMAX_TC_N[375] = 425;  // rand-325 N=425
    SOFTMAX_TC_N[376] = 331;  // rand-326 N=331
    SOFTMAX_TC_N[377] = 124;  // rand-327 N=124
    SOFTMAX_TC_N[378] = 225;  // rand-328 N=225
    SOFTMAX_TC_N[379] = 385;  // rand-329 N=385
    SOFTMAX_TC_N[380] = 384;  // rand-330 N=384
    SOFTMAX_TC_N[381] = 195;  // rand-331 N=195
    SOFTMAX_TC_N[382] = 484;  // rand-332 N=484
    SOFTMAX_TC_N[383] = 118;  // rand-333 N=118
    SOFTMAX_TC_N[384] = 176;  // rand-334 N=176
    SOFTMAX_TC_N[385] = 188;  // rand-335 N=188
    SOFTMAX_TC_N[386] = 168;  // rand-336 N=168
    SOFTMAX_TC_N[387] = 165;  // rand-337 N=165
    SOFTMAX_TC_N[388] = 14;  // rand-338 N=14
    SOFTMAX_TC_N[389] = 196;  // rand-339 N=196
    SOFTMAX_TC_N[390] = 118;  // rand-340 N=118
    SOFTMAX_TC_N[391] = 104;  // rand-341 N=104
    SOFTMAX_TC_N[392] = 289;  // rand-342 N=289
    SOFTMAX_TC_N[393] =  3;  // rand-343 N= 3
    SOFTMAX_TC_N[394] = 47;  // rand-344 N=47
    SOFTMAX_TC_N[395] = 319;  // rand-345 N=319
    SOFTMAX_TC_N[396] = 223;  // rand-346 N=223
    SOFTMAX_TC_N[397] = 105;  // rand-347 N=105
    SOFTMAX_TC_N[398] = 413;  // rand-348 N=413
    SOFTMAX_TC_N[399] = 95;  // rand-349 N=95
    SOFTMAX_TC_N[400] = 421;  // rand-350 N=421
    SOFTMAX_TC_N[401] = 144;  // rand-351 N=144
    SOFTMAX_TC_N[402] = 38;  // rand-352 N=38
    SOFTMAX_TC_N[403] = 268;  // rand-353 N=268
    SOFTMAX_TC_N[404] = 440;  // rand-354 N=440
    SOFTMAX_TC_N[405] = 241;  // rand-355 N=241
    SOFTMAX_TC_N[406] = 349;  // rand-356 N=349
    SOFTMAX_TC_N[407] = 186;  // rand-357 N=186
    SOFTMAX_TC_N[408] = 336;  // rand-358 N=336
    SOFTMAX_TC_N[409] = 132;  // rand-359 N=132
    SOFTMAX_TC_N[410] = 128;  // rand-360 N=128
    SOFTMAX_TC_N[411] = 113;  // rand-361 N=113
    SOFTMAX_TC_N[412] = 308;  // rand-362 N=308
    SOFTMAX_TC_N[413] = 364;  // rand-363 N=364
    SOFTMAX_TC_N[414] = 479;  // rand-364 N=479
    SOFTMAX_TC_N[415] = 249;  // rand-365 N=249
    SOFTMAX_TC_N[416] = 190;  // rand-366 N=190
    SOFTMAX_TC_N[417] = 497;  // rand-367 N=497
    SOFTMAX_TC_N[418] =  6;  // rand-368 N= 6
    SOFTMAX_TC_N[419] = 43;  // rand-369 N=43
    SOFTMAX_TC_N[420] = 381;  // rand-370 N=381
    SOFTMAX_TC_N[421] = 425;  // rand-371 N=425
    SOFTMAX_TC_N[422] = 56;  // rand-372 N=56
    SOFTMAX_TC_N[423] = 436;  // rand-373 N=436
    SOFTMAX_TC_N[424] = 355;  // rand-374 N=355
    SOFTMAX_TC_N[425] = 355;  // rand-375 N=355
    SOFTMAX_TC_N[426] = 116;  // rand-376 N=116
    SOFTMAX_TC_N[427] = 145;  // rand-377 N=145
    SOFTMAX_TC_N[428] = 343;  // rand-378 N=343
    SOFTMAX_TC_N[429] = 289;  // rand-379 N=289
    SOFTMAX_TC_N[430] = 22;  // rand-380 N=22
    SOFTMAX_TC_N[431] = 355;  // rand-381 N=355
    SOFTMAX_TC_N[432] = 286;  // rand-382 N=286
    SOFTMAX_TC_N[433] = 424;  // rand-383 N=424
    SOFTMAX_TC_N[434] = 485;  // rand-384 N=485
    SOFTMAX_TC_N[435] = 41;  // rand-385 N=41
    SOFTMAX_TC_N[436] = 454;  // rand-386 N=454
    SOFTMAX_TC_N[437] = 450;  // rand-387 N=450
    SOFTMAX_TC_N[438] = 286;  // rand-388 N=286
    SOFTMAX_TC_N[439] = 72;  // rand-389 N=72
    SOFTMAX_TC_N[440] = 163;  // rand-390 N=163
    SOFTMAX_TC_N[441] = 378;  // rand-391 N=378
    SOFTMAX_TC_N[442] = 191;  // rand-392 N=191
    SOFTMAX_TC_N[443] = 469;  // rand-393 N=469
    SOFTMAX_TC_N[444] = 494;  // rand-394 N=494
    SOFTMAX_TC_N[445] = 307;  // rand-395 N=307
    SOFTMAX_TC_N[446] = 171;  // rand-396 N=171
    SOFTMAX_TC_N[447] = 424;  // rand-397 N=424
    SOFTMAX_TC_N[448] = 130;  // rand-398 N=130
    SOFTMAX_TC_N[449] =  7;  // rand-399 N= 7
    SOFTMAX_TC_N[450] = 26;  // rand-400 N=26
    SOFTMAX_TC_N[451] = 366;  // rand-401 N=366
    SOFTMAX_TC_N[452] = 308;  // rand-402 N=308
    SOFTMAX_TC_N[453] = 406;  // rand-403 N=406
    SOFTMAX_TC_N[454] = 458;  // rand-404 N=458
    SOFTMAX_TC_N[455] = 97;  // rand-405 N=97
    SOFTMAX_TC_N[456] = 400;  // rand-406 N=400
    SOFTMAX_TC_N[457] = 284;  // rand-407 N=284
    SOFTMAX_TC_N[458] = 46;  // rand-408 N=46
    SOFTMAX_TC_N[459] =  9;  // rand-409 N= 9
    SOFTMAX_TC_N[460] = 288;  // rand-410 N=288
    SOFTMAX_TC_N[461] = 52;  // rand-411 N=52
    SOFTMAX_TC_N[462] = 332;  // rand-412 N=332
    SOFTMAX_TC_N[463] = 465;  // rand-413 N=465
    SOFTMAX_TC_N[464] = 181;  // rand-414 N=181
    SOFTMAX_TC_N[465] = 393;  // rand-415 N=393
    SOFTMAX_TC_N[466] = 479;  // rand-416 N=479
    SOFTMAX_TC_N[467] = 63;  // rand-417 N=63
    SOFTMAX_TC_N[468] = 208;  // rand-418 N=208
    SOFTMAX_TC_N[469] = 459;  // rand-419 N=459
    SOFTMAX_TC_N[470] = 83;  // rand-420 N=83
    SOFTMAX_TC_N[471] = 35;  // rand-421 N=35
    SOFTMAX_TC_N[472] = 366;  // rand-422 N=366
    SOFTMAX_TC_N[473] = 251;  // rand-423 N=251
    SOFTMAX_TC_N[474] = 396;  // rand-424 N=396
    SOFTMAX_TC_N[475] = 382;  // rand-425 N=382
    SOFTMAX_TC_N[476] = 290;  // rand-426 N=290
    SOFTMAX_TC_N[477] = 360;  // rand-427 N=360
    SOFTMAX_TC_N[478] = 317;  // rand-428 N=317
    SOFTMAX_TC_N[479] = 327;  // rand-429 N=327
    SOFTMAX_TC_N[480] = 206;  // rand-430 N=206
    SOFTMAX_TC_N[481] = 185;  // rand-431 N=185
    SOFTMAX_TC_N[482] = 246;  // rand-432 N=246
    SOFTMAX_TC_N[483] = 416;  // rand-433 N=416
    SOFTMAX_TC_N[484] = 121;  // rand-434 N=121
    SOFTMAX_TC_N[485] = 15;  // rand-435 N=15
    SOFTMAX_TC_N[486] = 16;  // rand-436 N=16
    SOFTMAX_TC_N[487] = 361;  // rand-437 N=361
    SOFTMAX_TC_N[488] = 102;  // rand-438 N=102
    SOFTMAX_TC_N[489] = 425;  // rand-439 N=425
    SOFTMAX_TC_N[490] = 24;  // rand-440 N=24
    SOFTMAX_TC_N[491] = 105;  // rand-441 N=105
    SOFTMAX_TC_N[492] = 462;  // rand-442 N=462
    SOFTMAX_TC_N[493] = 123;  // rand-443 N=123
    SOFTMAX_TC_N[494] = 281;  // rand-444 N=281
    SOFTMAX_TC_N[495] = 290;  // rand-445 N=290
    SOFTMAX_TC_N[496] = 185;  // rand-446 N=185
    SOFTMAX_TC_N[497] = 71;  // rand-447 N=71
    SOFTMAX_TC_N[498] = 274;  // rand-448 N=274
    SOFTMAX_TC_N[499] = 323;  // rand-449 N=323
    SOFTMAX_TC_N[500] = 286;  // rand-450 N=286
    SOFTMAX_TC_N[501] = 210;  // rand-451 N=210
    SOFTMAX_TC_N[502] = 139;  // rand-452 N=139
    SOFTMAX_TC_N[503] = 414;  // rand-453 N=414
    SOFTMAX_TC_N[504] = 493;  // rand-454 N=493
    SOFTMAX_TC_N[505] = 303;  // rand-455 N=303
    SOFTMAX_TC_N[506] = 292;  // rand-456 N=292
    SOFTMAX_TC_N[507] = 17;  // rand-457 N=17
    SOFTMAX_TC_N[508] = 335;  // rand-458 N=335
    SOFTMAX_TC_N[509] = 210;  // rand-459 N=210
    SOFTMAX_TC_N[510] = 238;  // rand-460 N=238
    SOFTMAX_TC_N[511] = 117;  // rand-461 N=117
    SOFTMAX_TC_N[512] = 117;  // rand-462 N=117
    SOFTMAX_TC_N[513] = 184;  // rand-463 N=184
    SOFTMAX_TC_N[514] = 311;  // rand-464 N=311
    SOFTMAX_TC_N[515] = 307;  // rand-465 N=307
    SOFTMAX_TC_N[516] = 453;  // rand-466 N=453
    SOFTMAX_TC_N[517] = 438;  // rand-467 N=438
    SOFTMAX_TC_N[518] =  2;  // rand-468 N= 2
    SOFTMAX_TC_N[519] = 463;  // rand-469 N=463
    SOFTMAX_TC_N[520] = 122;  // rand-470 N=122
    SOFTMAX_TC_N[521] = 204;  // rand-471 N=204
    SOFTMAX_TC_N[522] = 417;  // rand-472 N=417
    SOFTMAX_TC_N[523] = 445;  // rand-473 N=445
    SOFTMAX_TC_N[524] = 463;  // rand-474 N=463
    SOFTMAX_TC_N[525] = 100;  // rand-475 N=100
    SOFTMAX_TC_N[526] = 388;  // rand-476 N=388
    SOFTMAX_TC_N[527] = 43;  // rand-477 N=43
    SOFTMAX_TC_N[528] = 78;  // rand-478 N=78
    SOFTMAX_TC_N[529] = 40;  // rand-479 N=40
    SOFTMAX_TC_N[530] = 407;  // rand-480 N=407
    SOFTMAX_TC_N[531] = 483;  // rand-481 N=483
    SOFTMAX_TC_N[532] = 173;  // rand-482 N=173
    SOFTMAX_TC_N[533] = 53;  // rand-483 N=53
    SOFTMAX_TC_N[534] = 196;  // rand-484 N=196
    SOFTMAX_TC_N[535] = 140;  // rand-485 N=140
    SOFTMAX_TC_N[536] = 44;  // rand-486 N=44
    SOFTMAX_TC_N[537] = 46;  // rand-487 N=46
    SOFTMAX_TC_N[538] = 340;  // rand-488 N=340
    SOFTMAX_TC_N[539] = 256;  // rand-489 N=256
    SOFTMAX_TC_N[540] = 55;  // rand-490 N=55
    SOFTMAX_TC_N[541] = 493;  // rand-491 N=493
    SOFTMAX_TC_N[542] = 250;  // rand-492 N=250
    SOFTMAX_TC_N[543] = 216;  // rand-493 N=216
    SOFTMAX_TC_N[544] = 361;  // rand-494 N=361
    SOFTMAX_TC_N[545] = 126;  // rand-495 N=126
    SOFTMAX_TC_N[546] = 42;  // rand-496 N=42
    SOFTMAX_TC_N[547] = 262;  // rand-497 N=262
    SOFTMAX_TC_N[548] = 363;  // rand-498 N=363
    SOFTMAX_TC_N[549] = 205;  // rand-499 N=205
    SOFTMAX_TC_N[550] = 22;  // rand-500 N=22
    SOFTMAX_TC_N[551] = 479;  // rand-501 N=479
    SOFTMAX_TC_N[552] = 317;  // rand-502 N=317
    SOFTMAX_TC_N[553] = 287;  // rand-503 N=287
    SOFTMAX_TC_N[554] = 213;  // rand-504 N=213
    SOFTMAX_TC_N[555] = 84;  // rand-505 N=84
    SOFTMAX_TC_N[556] = 194;  // rand-506 N=194
    SOFTMAX_TC_N[557] = 403;  // rand-507 N=403
    SOFTMAX_TC_N[558] = 96;  // rand-508 N=96
    SOFTMAX_TC_N[559] = 246;  // rand-509 N=246
    SOFTMAX_TC_N[560] = 418;  // rand-510 N=418
    SOFTMAX_TC_N[561] = 365;  // rand-511 N=365
    SOFTMAX_TC_N[562] = 361;  // rand-512 N=361
    SOFTMAX_TC_N[563] = 186;  // rand-513 N=186
    SOFTMAX_TC_N[564] = 81;  // rand-514 N=81
    SOFTMAX_TC_N[565] = 298;  // rand-515 N=298
    SOFTMAX_TC_N[566] = 394;  // rand-516 N=394
    SOFTMAX_TC_N[567] = 231;  // rand-517 N=231
    SOFTMAX_TC_N[568] = 375;  // rand-518 N=375
    SOFTMAX_TC_N[569] = 402;  // rand-519 N=402
    SOFTMAX_TC_N[570] = 381;  // rand-520 N=381
    SOFTMAX_TC_N[571] = 42;  // rand-521 N=42
    SOFTMAX_TC_N[572] = 137;  // rand-522 N=137
    SOFTMAX_TC_N[573] = 400;  // rand-523 N=400
    SOFTMAX_TC_N[574] = 409;  // rand-524 N=409
    SOFTMAX_TC_N[575] = 99;  // rand-525 N=99
    SOFTMAX_TC_N[576] = 25;  // rand-526 N=25
    SOFTMAX_TC_N[577] = 421;  // rand-527 N=421
    SOFTMAX_TC_N[578] = 20;  // rand-528 N=20
    SOFTMAX_TC_N[579] = 185;  // rand-529 N=185
    SOFTMAX_TC_N[580] = 199;  // rand-530 N=199
    SOFTMAX_TC_N[581] = 197;  // rand-531 N=197
    SOFTMAX_TC_N[582] = 197;  // rand-532 N=197
    SOFTMAX_TC_N[583] = 379;  // rand-533 N=379
    SOFTMAX_TC_N[584] = 306;  // rand-534 N=306
    SOFTMAX_TC_N[585] = 61;  // rand-535 N=61
    SOFTMAX_TC_N[586] = 224;  // rand-536 N=224
    SOFTMAX_TC_N[587] = 420;  // rand-537 N=420
    SOFTMAX_TC_N[588] = 102;  // rand-538 N=102
    SOFTMAX_TC_N[589] = 116;  // rand-539 N=116
    SOFTMAX_TC_N[590] = 46;  // rand-540 N=46
    SOFTMAX_TC_N[591] = 256;  // rand-541 N=256
    SOFTMAX_TC_N[592] = 390;  // rand-542 N=390
    SOFTMAX_TC_N[593] = 175;  // rand-543 N=175
    SOFTMAX_TC_N[594] = 334;  // rand-544 N=334
    SOFTMAX_TC_N[595] = 440;  // rand-545 N=440
    SOFTMAX_TC_N[596] = 62;  // rand-546 N=62
    SOFTMAX_TC_N[597] = 144;  // rand-547 N=144
    SOFTMAX_TC_N[598] = 22;  // rand-548 N=22
    SOFTMAX_TC_N[599] = 280;  // rand-549 N=280
    SOFTMAX_TC_N[600] = 488;  // rand-550 N=488
    SOFTMAX_TC_N[601] = 142;  // rand-551 N=142
    SOFTMAX_TC_N[602] = 349;  // rand-552 N=349
    SOFTMAX_TC_N[603] = 35;  // rand-553 N=35
    SOFTMAX_TC_N[604] = 287;  // rand-554 N=287
    SOFTMAX_TC_N[605] = 463;  // rand-555 N=463
    SOFTMAX_TC_N[606] = 393;  // rand-556 N=393
    SOFTMAX_TC_N[607] = 11;  // rand-557 N=11
    SOFTMAX_TC_N[608] = 205;  // rand-558 N=205
    SOFTMAX_TC_N[609] = 75;  // rand-559 N=75
    SOFTMAX_TC_N[610] = 135;  // rand-560 N=135
    SOFTMAX_TC_N[611] = 123;  // rand-561 N=123
    SOFTMAX_TC_N[612] = 436;  // rand-562 N=436
    SOFTMAX_TC_N[613] = 352;  // rand-563 N=352
    SOFTMAX_TC_N[614] = 240;  // rand-564 N=240
    SOFTMAX_TC_N[615] = 206;  // rand-565 N=206
    SOFTMAX_TC_N[616] = 496;  // rand-566 N=496
    SOFTMAX_TC_N[617] = 449;  // rand-567 N=449
    SOFTMAX_TC_N[618] = 108;  // rand-568 N=108
    SOFTMAX_TC_N[619] = 469;  // rand-569 N=469
    SOFTMAX_TC_N[620] = 132;  // rand-570 N=132
    SOFTMAX_TC_N[621] = 454;  // rand-571 N=454
    SOFTMAX_TC_N[622] = 371;  // rand-572 N=371
    SOFTMAX_TC_N[623] = 158;  // rand-573 N=158
    SOFTMAX_TC_N[624] = 351;  // rand-574 N=351
    SOFTMAX_TC_N[625] = 304;  // rand-575 N=304
    SOFTMAX_TC_N[626] = 81;  // rand-576 N=81
    SOFTMAX_TC_N[627] = 352;  // rand-577 N=352
    SOFTMAX_TC_N[628] = 428;  // rand-578 N=428
    SOFTMAX_TC_N[629] = 370;  // rand-579 N=370
    SOFTMAX_TC_N[630] = 414;  // rand-580 N=414
    SOFTMAX_TC_N[631] = 259;  // rand-581 N=259
    SOFTMAX_TC_N[632] = 267;  // rand-582 N=267
    SOFTMAX_TC_N[633] = 247;  // rand-583 N=247
    SOFTMAX_TC_N[634] = 53;  // rand-584 N=53
    SOFTMAX_TC_N[635] = 86;  // rand-585 N=86
    SOFTMAX_TC_N[636] = 341;  // rand-586 N=341
    SOFTMAX_TC_N[637] = 65;  // rand-587 N=65
    SOFTMAX_TC_N[638] = 128;  // rand-588 N=128
    SOFTMAX_TC_N[639] = 200;  // rand-589 N=200
    SOFTMAX_TC_N[640] = 206;  // rand-590 N=206
    SOFTMAX_TC_N[641] = 237;  // rand-591 N=237
    SOFTMAX_TC_N[642] = 180;  // rand-592 N=180
    SOFTMAX_TC_N[643] = 330;  // rand-593 N=330
    SOFTMAX_TC_N[644] = 159;  // rand-594 N=159
    SOFTMAX_TC_N[645] = 180;  // rand-595 N=180
    SOFTMAX_TC_N[646] = 388;  // rand-596 N=388
    SOFTMAX_TC_N[647] = 469;  // rand-597 N=469
    SOFTMAX_TC_N[648] = 90;  // rand-598 N=90
    SOFTMAX_TC_N[649] = 399;  // rand-599 N=399
    SOFTMAX_TC_N[650] = 216;  // rand-600 N=216
    SOFTMAX_TC_N[651] = 112;  // rand-601 N=112
    SOFTMAX_TC_N[652] = 488;  // rand-602 N=488
    SOFTMAX_TC_N[653] = 436;  // rand-603 N=436
    SOFTMAX_TC_N[654] = 197;  // rand-604 N=197
    SOFTMAX_TC_N[655] = 443;  // rand-605 N=443
    SOFTMAX_TC_N[656] = 383;  // rand-606 N=383
    SOFTMAX_TC_N[657] = 94;  // rand-607 N=94
    SOFTMAX_TC_N[658] = 81;  // rand-608 N=81
    SOFTMAX_TC_N[659] = 229;  // rand-609 N=229
    SOFTMAX_TC_N[660] = 34;  // rand-610 N=34
    SOFTMAX_TC_N[661] = 162;  // rand-611 N=162
    SOFTMAX_TC_N[662] = 447;  // rand-612 N=447
    SOFTMAX_TC_N[663] = 396;  // rand-613 N=396
    SOFTMAX_TC_N[664] = 78;  // rand-614 N=78
    SOFTMAX_TC_N[665] = 58;  // rand-615 N=58
    SOFTMAX_TC_N[666] = 367;  // rand-616 N=367
    SOFTMAX_TC_N[667] = 249;  // rand-617 N=249
    SOFTMAX_TC_N[668] = 325;  // rand-618 N=325
    SOFTMAX_TC_N[669] = 248;  // rand-619 N=248
    SOFTMAX_TC_N[670] = 375;  // rand-620 N=375
    SOFTMAX_TC_N[671] = 317;  // rand-621 N=317
    SOFTMAX_TC_N[672] = 109;  // rand-622 N=109
    SOFTMAX_TC_N[673] = 303;  // rand-623 N=303
    SOFTMAX_TC_N[674] = 72;  // rand-624 N=72
    SOFTMAX_TC_N[675] = 409;  // rand-625 N=409
    SOFTMAX_TC_N[676] = 189;  // rand-626 N=189
    SOFTMAX_TC_N[677] = 228;  // rand-627 N=228
    SOFTMAX_TC_N[678] = 92;  // rand-628 N=92
    SOFTMAX_TC_N[679] = 168;  // rand-629 N=168
    SOFTMAX_TC_N[680] = 95;  // rand-630 N=95
    SOFTMAX_TC_N[681] = 481;  // rand-631 N=481
    SOFTMAX_TC_N[682] = 382;  // rand-632 N=382
    SOFTMAX_TC_N[683] = 255;  // rand-633 N=255
    SOFTMAX_TC_N[684] =  1;  // rand-634 N= 1
    SOFTMAX_TC_N[685] = 329;  // rand-635 N=329
    SOFTMAX_TC_N[686] = 133;  // rand-636 N=133
    SOFTMAX_TC_N[687] = 114;  // rand-637 N=114
    SOFTMAX_TC_N[688] = 464;  // rand-638 N=464
    SOFTMAX_TC_N[689] = 372;  // rand-639 N=372
    SOFTMAX_TC_N[690] = 124;  // rand-640 N=124
    SOFTMAX_TC_N[691] = 183;  // rand-641 N=183
    SOFTMAX_TC_N[692] = 196;  // rand-642 N=196
    SOFTMAX_TC_N[693] = 272;  // rand-643 N=272
    SOFTMAX_TC_N[694] = 314;  // rand-644 N=314
    SOFTMAX_TC_N[695] = 339;  // rand-645 N=339
    SOFTMAX_TC_N[696] = 449;  // rand-646 N=449
    SOFTMAX_TC_N[697] = 31;  // rand-647 N=31
    SOFTMAX_TC_N[698] = 154;  // rand-648 N=154
    SOFTMAX_TC_N[699] = 226;  // rand-649 N=226
    SOFTMAX_TC_N[700] = 492;  // rand-650 N=492
    SOFTMAX_TC_N[701] = 327;  // rand-651 N=327
    SOFTMAX_TC_N[702] = 357;  // rand-652 N=357
    SOFTMAX_TC_N[703] = 135;  // rand-653 N=135
    SOFTMAX_TC_N[704] = 171;  // rand-654 N=171
    SOFTMAX_TC_N[705] = 88;  // rand-655 N=88
    SOFTMAX_TC_N[706] = 406;  // rand-656 N=406
    SOFTMAX_TC_N[707] = 372;  // rand-657 N=372
    SOFTMAX_TC_N[708] = 410;  // rand-658 N=410
    SOFTMAX_TC_N[709] = 474;  // rand-659 N=474
    SOFTMAX_TC_N[710] = 93;  // rand-660 N=93
    SOFTMAX_TC_N[711] = 159;  // rand-661 N=159
    SOFTMAX_TC_N[712] = 408;  // rand-662 N=408
    SOFTMAX_TC_N[713] = 20;  // rand-663 N=20
    SOFTMAX_TC_N[714] = 457;  // rand-664 N=457
    SOFTMAX_TC_N[715] = 236;  // rand-665 N=236
    SOFTMAX_TC_N[716] = 491;  // rand-666 N=491
    SOFTMAX_TC_N[717] = 160;  // rand-667 N=160
    SOFTMAX_TC_N[718] = 478;  // rand-668 N=478
    SOFTMAX_TC_N[719] = 490;  // rand-669 N=490
    SOFTMAX_TC_N[720] = 453;  // rand-670 N=453
    SOFTMAX_TC_N[721] = 494;  // rand-671 N=494
    SOFTMAX_TC_N[722] = 438;  // rand-672 N=438
    SOFTMAX_TC_N[723] = 103;  // rand-673 N=103
    SOFTMAX_TC_N[724] = 380;  // rand-674 N=380
    SOFTMAX_TC_N[725] = 413;  // rand-675 N=413
    SOFTMAX_TC_N[726] = 354;  // rand-676 N=354
    SOFTMAX_TC_N[727] = 188;  // rand-677 N=188
    SOFTMAX_TC_N[728] = 148;  // rand-678 N=148
    SOFTMAX_TC_N[729] = 424;  // rand-679 N=424
    SOFTMAX_TC_N[730] = 143;  // rand-680 N=143
    SOFTMAX_TC_N[731] = 52;  // rand-681 N=52
    SOFTMAX_TC_N[732] = 395;  // rand-682 N=395
    SOFTMAX_TC_N[733] = 225;  // rand-683 N=225
    SOFTMAX_TC_N[734] = 479;  // rand-684 N=479
    SOFTMAX_TC_N[735] = 415;  // rand-685 N=415
    SOFTMAX_TC_N[736] = 394;  // rand-686 N=394
    SOFTMAX_TC_N[737] = 389;  // rand-687 N=389
    SOFTMAX_TC_N[738] = 295;  // rand-688 N=295
    SOFTMAX_TC_N[739] = 432;  // rand-689 N=432
    SOFTMAX_TC_N[740] = 242;  // rand-690 N=242
    SOFTMAX_TC_N[741] = 318;  // rand-691 N=318
    SOFTMAX_TC_N[742] = 344;  // rand-692 N=344
    SOFTMAX_TC_N[743] = 497;  // rand-693 N=497
    SOFTMAX_TC_N[744] = 380;  // rand-694 N=380
    SOFTMAX_TC_N[745] = 274;  // rand-695 N=274
    SOFTMAX_TC_N[746] = 255;  // rand-696 N=255
    SOFTMAX_TC_N[747] = 367;  // rand-697 N=367
    SOFTMAX_TC_N[748] = 103;  // rand-698 N=103
    SOFTMAX_TC_N[749] = 91;  // rand-699 N=91
    SOFTMAX_TC_N[750] = 284;  // rand-700 N=284
    SOFTMAX_TC_N[751] = 338;  // rand-701 N=338
    SOFTMAX_TC_N[752] = 103;  // rand-702 N=103
    SOFTMAX_TC_N[753] = 37;  // rand-703 N=37
    SOFTMAX_TC_N[754] = 317;  // rand-704 N=317
    SOFTMAX_TC_N[755] = 447;  // rand-705 N=447
    SOFTMAX_TC_N[756] = 442;  // rand-706 N=442
    SOFTMAX_TC_N[757] = 450;  // rand-707 N=450
    SOFTMAX_TC_N[758] = 257;  // rand-708 N=257
    SOFTMAX_TC_N[759] = 159;  // rand-709 N=159
    SOFTMAX_TC_N[760] = 101;  // rand-710 N=101
    SOFTMAX_TC_N[761] = 413;  // rand-711 N=413
    SOFTMAX_TC_N[762] = 120;  // rand-712 N=120
    SOFTMAX_TC_N[763] = 65;  // rand-713 N=65
    SOFTMAX_TC_N[764] = 422;  // rand-714 N=422
    SOFTMAX_TC_N[765] = 407;  // rand-715 N=407
    SOFTMAX_TC_N[766] = 156;  // rand-716 N=156
    SOFTMAX_TC_N[767] = 121;  // rand-717 N=121
    SOFTMAX_TC_N[768] = 422;  // rand-718 N=422
    SOFTMAX_TC_N[769] = 173;  // rand-719 N=173
    SOFTMAX_TC_N[770] =  5;  // rand-720 N= 5
    SOFTMAX_TC_N[771] = 63;  // rand-721 N=63
    SOFTMAX_TC_N[772] = 465;  // rand-722 N=465
    SOFTMAX_TC_N[773] = 281;  // rand-723 N=281
    SOFTMAX_TC_N[774] = 255;  // rand-724 N=255
    SOFTMAX_TC_N[775] = 229;  // rand-725 N=229
    SOFTMAX_TC_N[776] = 59;  // rand-726 N=59
    SOFTMAX_TC_N[777] = 326;  // rand-727 N=326
    SOFTMAX_TC_N[778] = 343;  // rand-728 N=343
    SOFTMAX_TC_N[779] = 87;  // rand-729 N=87
    SOFTMAX_TC_N[780] = 54;  // rand-730 N=54
    SOFTMAX_TC_N[781] = 489;  // rand-731 N=489
    SOFTMAX_TC_N[782] = 427;  // rand-732 N=427
    SOFTMAX_TC_N[783] = 480;  // rand-733 N=480
    SOFTMAX_TC_N[784] = 95;  // rand-734 N=95
    SOFTMAX_TC_N[785] = 421;  // rand-735 N=421
    SOFTMAX_TC_N[786] = 131;  // rand-736 N=131
    SOFTMAX_TC_N[787] = 249;  // rand-737 N=249
    SOFTMAX_TC_N[788] = 259;  // rand-738 N=259
    SOFTMAX_TC_N[789] = 92;  // rand-739 N=92
    SOFTMAX_TC_N[790] = 322;  // rand-740 N=322
    SOFTMAX_TC_N[791] = 119;  // rand-741 N=119
    SOFTMAX_TC_N[792] = 50;  // rand-742 N=50
    SOFTMAX_TC_N[793] = 360;  // rand-743 N=360
    SOFTMAX_TC_N[794] = 200;  // rand-744 N=200
    SOFTMAX_TC_N[795] = 267;  // rand-745 N=267
    SOFTMAX_TC_N[796] = 147;  // rand-746 N=147
    SOFTMAX_TC_N[797] = 357;  // rand-747 N=357
    SOFTMAX_TC_N[798] = 208;  // rand-748 N=208
    SOFTMAX_TC_N[799] = 496;  // rand-749 N=496
    SOFTMAX_TC_N[800] = 434;  // rand-750 N=434
    SOFTMAX_TC_N[801] = 243;  // rand-751 N=243
    SOFTMAX_TC_N[802] = 370;  // rand-752 N=370
    SOFTMAX_TC_N[803] = 202;  // rand-753 N=202
    SOFTMAX_TC_N[804] = 187;  // rand-754 N=187
    SOFTMAX_TC_N[805] = 275;  // rand-755 N=275
    SOFTMAX_TC_N[806] = 26;  // rand-756 N=26
    SOFTMAX_TC_N[807] = 98;  // rand-757 N=98
    SOFTMAX_TC_N[808] = 472;  // rand-758 N=472
    SOFTMAX_TC_N[809] = 129;  // rand-759 N=129
    SOFTMAX_TC_N[810] = 84;  // rand-760 N=84
    SOFTMAX_TC_N[811] = 472;  // rand-761 N=472
    SOFTMAX_TC_N[812] = 317;  // rand-762 N=317
    SOFTMAX_TC_N[813] = 191;  // rand-763 N=191
    SOFTMAX_TC_N[814] = 132;  // rand-764 N=132
    SOFTMAX_TC_N[815] = 44;  // rand-765 N=44
    SOFTMAX_TC_N[816] = 323;  // rand-766 N=323
    SOFTMAX_TC_N[817] = 420;  // rand-767 N=420
    SOFTMAX_TC_N[818] = 266;  // rand-768 N=266
    SOFTMAX_TC_N[819] = 329;  // rand-769 N=329
    SOFTMAX_TC_N[820] = 151;  // rand-770 N=151
    SOFTMAX_TC_N[821] = 330;  // rand-771 N=330
    SOFTMAX_TC_N[822] = 326;  // rand-772 N=326
    SOFTMAX_TC_N[823] = 267;  // rand-773 N=267
    SOFTMAX_TC_N[824] = 38;  // rand-774 N=38
    SOFTMAX_TC_N[825] = 203;  // rand-775 N=203
    SOFTMAX_TC_N[826] = 79;  // rand-776 N=79
    SOFTMAX_TC_N[827] = 85;  // rand-777 N=85
    SOFTMAX_TC_N[828] = 110;  // rand-778 N=110
    SOFTMAX_TC_N[829] = 460;  // rand-779 N=460
    SOFTMAX_TC_N[830] = 344;  // rand-780 N=344
    SOFTMAX_TC_N[831] = 78;  // rand-781 N=78
    SOFTMAX_TC_N[832] = 148;  // rand-782 N=148
    SOFTMAX_TC_N[833] = 60;  // rand-783 N=60
    SOFTMAX_TC_N[834] = 265;  // rand-784 N=265
    SOFTMAX_TC_N[835] = 441;  // rand-785 N=441
    SOFTMAX_TC_N[836] = 161;  // rand-786 N=161
    SOFTMAX_TC_N[837] = 445;  // rand-787 N=445
    SOFTMAX_TC_N[838] = 84;  // rand-788 N=84
    SOFTMAX_TC_N[839] = 282;  // rand-789 N=282
    SOFTMAX_TC_N[840] = 500;  // rand-790 N=500
    SOFTMAX_TC_N[841] = 274;  // rand-791 N=274
    SOFTMAX_TC_N[842] = 109;  // rand-792 N=109
    SOFTMAX_TC_N[843] = 263;  // rand-793 N=263
    SOFTMAX_TC_N[844] = 363;  // rand-794 N=363
    SOFTMAX_TC_N[845] = 216;  // rand-795 N=216
    SOFTMAX_TC_N[846] = 316;  // rand-796 N=316
    SOFTMAX_TC_N[847] = 292;  // rand-797 N=292
    SOFTMAX_TC_N[848] = 307;  // rand-798 N=307
    SOFTMAX_TC_N[849] = 43;  // rand-799 N=43
    SOFTMAX_TC_N[850] = 416;  // rand-800 N=416
    SOFTMAX_TC_N[851] = 242;  // rand-801 N=242
    SOFTMAX_TC_N[852] = 451;  // rand-802 N=451
    SOFTMAX_TC_N[853] = 59;  // rand-803 N=59
    SOFTMAX_TC_N[854] = 467;  // rand-804 N=467
    SOFTMAX_TC_N[855] = 386;  // rand-805 N=386
    SOFTMAX_TC_N[856] = 122;  // rand-806 N=122
    SOFTMAX_TC_N[857] = 82;  // rand-807 N=82
    SOFTMAX_TC_N[858] = 248;  // rand-808 N=248
    SOFTMAX_TC_N[859] = 316;  // rand-809 N=316
    SOFTMAX_TC_N[860] = 434;  // rand-810 N=434
    SOFTMAX_TC_N[861] = 349;  // rand-811 N=349
    SOFTMAX_TC_N[862] = 154;  // rand-812 N=154
    SOFTMAX_TC_N[863] = 209;  // rand-813 N=209
    SOFTMAX_TC_N[864] = 301;  // rand-814 N=301
    SOFTMAX_TC_N[865] = 294;  // rand-815 N=294
    SOFTMAX_TC_N[866] = 247;  // rand-816 N=247
    SOFTMAX_TC_N[867] = 189;  // rand-817 N=189
    SOFTMAX_TC_N[868] = 439;  // rand-818 N=439
    SOFTMAX_TC_N[869] = 178;  // rand-819 N=178
    SOFTMAX_TC_N[870] = 294;  // rand-820 N=294
    SOFTMAX_TC_N[871] = 205;  // rand-821 N=205
    SOFTMAX_TC_N[872] = 346;  // rand-822 N=346
    SOFTMAX_TC_N[873] = 430;  // rand-823 N=430
    SOFTMAX_TC_N[874] = 483;  // rand-824 N=483
    SOFTMAX_TC_N[875] = 134;  // rand-825 N=134
    SOFTMAX_TC_N[876] = 125;  // rand-826 N=125
    SOFTMAX_TC_N[877] = 367;  // rand-827 N=367
    SOFTMAX_TC_N[878] = 138;  // rand-828 N=138
    SOFTMAX_TC_N[879] = 234;  // rand-829 N=234
    SOFTMAX_TC_N[880] = 253;  // rand-830 N=253
    SOFTMAX_TC_N[881] = 430;  // rand-831 N=430
    SOFTMAX_TC_N[882] = 36;  // rand-832 N=36
    SOFTMAX_TC_N[883] = 113;  // rand-833 N=113
    SOFTMAX_TC_N[884] = 346;  // rand-834 N=346
    SOFTMAX_TC_N[885] = 423;  // rand-835 N=423
    SOFTMAX_TC_N[886] = 158;  // rand-836 N=158
    SOFTMAX_TC_N[887] = 45;  // rand-837 N=45
    SOFTMAX_TC_N[888] = 479;  // rand-838 N=479
    SOFTMAX_TC_N[889] = 379;  // rand-839 N=379
    SOFTMAX_TC_N[890] = 244;  // rand-840 N=244
    SOFTMAX_TC_N[891] = 442;  // rand-841 N=442
    SOFTMAX_TC_N[892] = 19;  // rand-842 N=19
    SOFTMAX_TC_N[893] = 376;  // rand-843 N=376
    SOFTMAX_TC_N[894] = 345;  // rand-844 N=345
    SOFTMAX_TC_N[895] = 474;  // rand-845 N=474
    SOFTMAX_TC_N[896] = 168;  // rand-846 N=168
    SOFTMAX_TC_N[897] = 175;  // rand-847 N=175
    SOFTMAX_TC_N[898] = 485;  // rand-848 N=485
    SOFTMAX_TC_N[899] = 313;  // rand-849 N=313
    SOFTMAX_TC_N[900] = 211;  // rand-850 N=211
    SOFTMAX_TC_N[901] = 128;  // rand-851 N=128
    SOFTMAX_TC_N[902] = 285;  // rand-852 N=285
    SOFTMAX_TC_N[903] = 12;  // rand-853 N=12
    SOFTMAX_TC_N[904] = 447;  // rand-854 N=447
    SOFTMAX_TC_N[905] = 211;  // rand-855 N=211
    SOFTMAX_TC_N[906] = 15;  // rand-856 N=15
    SOFTMAX_TC_N[907] = 459;  // rand-857 N=459
    SOFTMAX_TC_N[908] = 68;  // rand-858 N=68
    SOFTMAX_TC_N[909] = 97;  // rand-859 N=97
    SOFTMAX_TC_N[910] = 428;  // rand-860 N=428
    SOFTMAX_TC_N[911] = 440;  // rand-861 N=440
    SOFTMAX_TC_N[912] = 236;  // rand-862 N=236
    SOFTMAX_TC_N[913] = 105;  // rand-863 N=105
    SOFTMAX_TC_N[914] =  3;  // rand-864 N= 3
    SOFTMAX_TC_N[915] = 41;  // rand-865 N=41
    SOFTMAX_TC_N[916] = 164;  // rand-866 N=164
    SOFTMAX_TC_N[917] = 93;  // rand-867 N=93
    SOFTMAX_TC_N[918] = 29;  // rand-868 N=29
    SOFTMAX_TC_N[919] = 299;  // rand-869 N=299
    SOFTMAX_TC_N[920] = 189;  // rand-870 N=189
    SOFTMAX_TC_N[921] = 136;  // rand-871 N=136
    SOFTMAX_TC_N[922] = 133;  // rand-872 N=133
    SOFTMAX_TC_N[923] = 478;  // rand-873 N=478
    SOFTMAX_TC_N[924] = 62;  // rand-874 N=62
    SOFTMAX_TC_N[925] = 107;  // rand-875 N=107
    SOFTMAX_TC_N[926] = 390;  // rand-876 N=390
    SOFTMAX_TC_N[927] = 67;  // rand-877 N=67
    SOFTMAX_TC_N[928] = 188;  // rand-878 N=188
    SOFTMAX_TC_N[929] = 145;  // rand-879 N=145
    SOFTMAX_TC_N[930] = 415;  // rand-880 N=415
    SOFTMAX_TC_N[931] = 233;  // rand-881 N=233
    SOFTMAX_TC_N[932] = 108;  // rand-882 N=108
    SOFTMAX_TC_N[933] = 159;  // rand-883 N=159
    SOFTMAX_TC_N[934] = 373;  // rand-884 N=373
    SOFTMAX_TC_N[935] = 488;  // rand-885 N=488
    SOFTMAX_TC_N[936] = 331;  // rand-886 N=331
    SOFTMAX_TC_N[937] = 370;  // rand-887 N=370
    SOFTMAX_TC_N[938] = 67;  // rand-888 N=67
    SOFTMAX_TC_N[939] = 433;  // rand-889 N=433
    SOFTMAX_TC_N[940] = 472;  // rand-890 N=472
    SOFTMAX_TC_N[941] = 27;  // rand-891 N=27
    SOFTMAX_TC_N[942] = 364;  // rand-892 N=364
    SOFTMAX_TC_N[943] = 313;  // rand-893 N=313
    SOFTMAX_TC_N[944] = 75;  // rand-894 N=75
    SOFTMAX_TC_N[945] = 216;  // rand-895 N=216
    SOFTMAX_TC_N[946] = 486;  // rand-896 N=486
    SOFTMAX_TC_N[947] = 204;  // rand-897 N=204
    SOFTMAX_TC_N[948] = 126;  // rand-898 N=126
    SOFTMAX_TC_N[949] = 127;  // rand-899 N=127
    SOFTMAX_TC_N[950] = 218;  // rand-900 N=218
    SOFTMAX_TC_N[951] = 153;  // rand-901 N=153
    SOFTMAX_TC_N[952] = 139;  // rand-902 N=139
    SOFTMAX_TC_N[953] = 67;  // rand-903 N=67
    SOFTMAX_TC_N[954] = 233;  // rand-904 N=233
    SOFTMAX_TC_N[955] = 135;  // rand-905 N=135
    SOFTMAX_TC_N[956] = 192;  // rand-906 N=192
    SOFTMAX_TC_N[957] = 226;  // rand-907 N=226
    SOFTMAX_TC_N[958] = 423;  // rand-908 N=423
    SOFTMAX_TC_N[959] = 419;  // rand-909 N=419
    SOFTMAX_TC_N[960] = 320;  // rand-910 N=320
    SOFTMAX_TC_N[961] = 282;  // rand-911 N=282
    SOFTMAX_TC_N[962] = 337;  // rand-912 N=337
    SOFTMAX_TC_N[963] = 300;  // rand-913 N=300
    SOFTMAX_TC_N[964] = 291;  // rand-914 N=291
    SOFTMAX_TC_N[965] = 331;  // rand-915 N=331
    SOFTMAX_TC_N[966] = 353;  // rand-916 N=353
    SOFTMAX_TC_N[967] = 428;  // rand-917 N=428
    SOFTMAX_TC_N[968] = 449;  // rand-918 N=449
    SOFTMAX_TC_N[969] = 255;  // rand-919 N=255
    SOFTMAX_TC_N[970] = 492;  // rand-920 N=492
    SOFTMAX_TC_N[971] = 148;  // rand-921 N=148
    SOFTMAX_TC_N[972] = 199;  // rand-922 N=199
    SOFTMAX_TC_N[973] = 432;  // rand-923 N=432
    SOFTMAX_TC_N[974] = 71;  // rand-924 N=71
    SOFTMAX_TC_N[975] = 89;  // rand-925 N=89
    SOFTMAX_TC_N[976] = 124;  // rand-926 N=124
    SOFTMAX_TC_N[977] = 234;  // rand-927 N=234
    SOFTMAX_TC_N[978] = 30;  // rand-928 N=30
    SOFTMAX_TC_N[979] = 104;  // rand-929 N=104
    SOFTMAX_TC_N[980] = 262;  // rand-930 N=262
    SOFTMAX_TC_N[981] = 474;  // rand-931 N=474
    SOFTMAX_TC_N[982] = 109;  // rand-932 N=109
    SOFTMAX_TC_N[983] = 187;  // rand-933 N=187
    SOFTMAX_TC_N[984] = 243;  // rand-934 N=243
    SOFTMAX_TC_N[985] =  5;  // rand-935 N= 5
    SOFTMAX_TC_N[986] = 263;  // rand-936 N=263
    SOFTMAX_TC_N[987] = 11;  // rand-937 N=11
    SOFTMAX_TC_N[988] = 172;  // rand-938 N=172
    SOFTMAX_TC_N[989] = 438;  // rand-939 N=438
    SOFTMAX_TC_N[990] = 184;  // rand-940 N=184
    SOFTMAX_TC_N[991] = 449;  // rand-941 N=449
    SOFTMAX_TC_N[992] = 224;  // rand-942 N=224
    SOFTMAX_TC_N[993] = 401;  // rand-943 N=401
    SOFTMAX_TC_N[994] = 401;  // rand-944 N=401
    SOFTMAX_TC_N[995] = 412;  // rand-945 N=412
    SOFTMAX_TC_N[996] = 176;  // rand-946 N=176
    SOFTMAX_TC_N[997] = 468;  // rand-947 N=468
    SOFTMAX_TC_N[998] = 183;  // rand-948 N=183
    SOFTMAX_TC_N[999] = 169;  // rand-949 N=169
    SOFTMAX_TC_N[1000] = 357;  // rand-950 N=357
    SOFTMAX_TC_N[1001] = 108;  // rand-951 N=108
    SOFTMAX_TC_N[1002] = 273;  // rand-952 N=273
    SOFTMAX_TC_N[1003] = 199;  // rand-953 N=199
    SOFTMAX_TC_N[1004] = 41;  // rand-954 N=41
    SOFTMAX_TC_N[1005] = 97;  // rand-955 N=97
    SOFTMAX_TC_N[1006] = 177;  // rand-956 N=177
    SOFTMAX_TC_N[1007] = 399;  // rand-957 N=399
    SOFTMAX_TC_N[1008] = 443;  // rand-958 N=443
    SOFTMAX_TC_N[1009] = 157;  // rand-959 N=157
    SOFTMAX_TC_N[1010] = 348;  // rand-960 N=348
    SOFTMAX_TC_N[1011] = 171;  // rand-961 N=171
    SOFTMAX_TC_N[1012] = 407;  // rand-962 N=407
    SOFTMAX_TC_N[1013] = 270;  // rand-963 N=270
    SOFTMAX_TC_N[1014] = 31;  // rand-964 N=31
    SOFTMAX_TC_N[1015] = 351;  // rand-965 N=351
    SOFTMAX_TC_N[1016] = 255;  // rand-966 N=255
    SOFTMAX_TC_N[1017] = 344;  // rand-967 N=344
    SOFTMAX_TC_N[1018] = 40;  // rand-968 N=40
    SOFTMAX_TC_N[1019] = 467;  // rand-969 N=467
    SOFTMAX_TC_N[1020] = 318;  // rand-970 N=318
    SOFTMAX_TC_N[1021] = 328;  // rand-971 N=328
    SOFTMAX_TC_N[1022] = 359;  // rand-972 N=359
    SOFTMAX_TC_N[1023] = 356;  // rand-973 N=356
    SOFTMAX_TC_N[1024] = 419;  // rand-974 N=419
    SOFTMAX_TC_N[1025] = 273;  // rand-975 N=273
    SOFTMAX_TC_N[1026] = 233;  // rand-976 N=233
    SOFTMAX_TC_N[1027] = 96;  // rand-977 N=96
    SOFTMAX_TC_N[1028] = 55;  // rand-978 N=55
    SOFTMAX_TC_N[1029] = 383;  // rand-979 N=383
    SOFTMAX_TC_N[1030] = 180;  // rand-980 N=180
    SOFTMAX_TC_N[1031] = 404;  // rand-981 N=404
    SOFTMAX_TC_N[1032] = 345;  // rand-982 N=345
    SOFTMAX_TC_N[1033] = 270;  // rand-983 N=270
    SOFTMAX_TC_N[1034] = 33;  // rand-984 N=33
    SOFTMAX_TC_N[1035] = 363;  // rand-985 N=363
    SOFTMAX_TC_N[1036] = 18;  // rand-986 N=18
    SOFTMAX_TC_N[1037] = 294;  // rand-987 N=294
    SOFTMAX_TC_N[1038] = 184;  // rand-988 N=184
    SOFTMAX_TC_N[1039] = 18;  // rand-989 N=18
    SOFTMAX_TC_N[1040] = 284;  // rand-990 N=284
    SOFTMAX_TC_N[1041] = 476;  // rand-991 N=476
    SOFTMAX_TC_N[1042] = 21;  // rand-992 N=21
    SOFTMAX_TC_N[1043] = 492;  // rand-993 N=492
    SOFTMAX_TC_N[1044] = 379;  // rand-994 N=379
    SOFTMAX_TC_N[1045] = 267;  // rand-995 N=267
    SOFTMAX_TC_N[1046] = 305;  // rand-996 N=305
    SOFTMAX_TC_N[1047] = 104;  // rand-997 N=104
    SOFTMAX_TC_N[1048] = 264;  // rand-998 N=264
    SOFTMAX_TC_N[1049] = 353;  // rand-999 N=353
end
endtask

// Load test idx from disk:  reads the in/out mem pair, sets SOFTMAX_N.
task automatic softmax_load_test(input int idx);
    string fn_in;
    string fn_out;
begin
    SOFTMAX_N = SOFTMAX_TC_N[idx];
    $sformat(fn_in,  "vectors/softmax/tc%02d_in.mem",  idx);
    $sformat(fn_out, "vectors/softmax/tc%02d_out.mem", idx);
    $readmemh(fn_in,  SOFTMAX_X,     0, SOFTMAX_N - 1);
    $readmemh(fn_out, SOFTMAX_Y_EXP, 0, SOFTMAX_N - 1);
end
endtask

// Human-readable test name (handy for log lines / waveform annotation).
function automatic string softmax_test_name(input int idx);
begin
    case (idx)
         0: softmax_test_name = "bin neg_extreme  N=8  LOW";
         1: softmax_test_name = "bin neg_high     N=8  LOW";
         2: softmax_test_name = "bin neg_low      N=8  LOW";
         3: softmax_test_name = "bin pos_low      N=8  LOW";
         4: softmax_test_name = "bin pos_high     N=8  LOW";
         5: softmax_test_name = "bin pos_extreme  N=8  LOW";
         6: softmax_test_name = "bin neg_extreme  N=8  HIGH";
         7: softmax_test_name = "bin neg_high     N=8  HIGH";
         8: softmax_test_name = "bin neg_low      N=8  HIGH";
         9: softmax_test_name = "bin pos_low      N=8  HIGH";
        10: softmax_test_name = "bin pos_high     N=8  HIGH";
        11: softmax_test_name = "bin pos_extreme  N=8  HIGH";
        12: softmax_test_name = "all 6 bins symmetric  N=6";
        13: softmax_test_name = "bimodal extremes      N=8";
        14: softmax_test_name = "bin boundaries        N=9";
        15: softmax_test_name = "neg dominant          N=7";
        16: softmax_test_name = "pos dominant          N=7";
        17: softmax_test_name = "half neg / half pos   N=8";
        18: softmax_test_name = "step across bins      N=12";
        19: softmax_test_name = "alt extremes          N=8";
        20: softmax_test_name = "alt highs             N=8";
        21: softmax_test_name = "alt lows              N=8";
        22: softmax_test_name = "zeros + one extreme   N=8";
        23: softmax_test_name = "zeros + one neg_extr  N=8";
        24: softmax_test_name = "zero variance        N=8";
        25: softmax_test_name = "equal pos            N=8";
        26: softmax_test_name = "equal neg            N=8";
        27: softmax_test_name = "tight 100 ±0.01      N=8";
        28: softmax_test_name = "wide -300..400       N=8";
        29: softmax_test_name = "very wide -32k..32k  N=4";
        30: softmax_test_name = "N=1  single positive";
        31: softmax_test_name = "N=2  cross bins";
        32: softmax_test_name = "N=4  across all bin signs";
        33: softmax_test_name = "N=16 wide cross-bin sweep";
        34: softmax_test_name = "N=32 ascending across bins";
        35: softmax_test_name = "N=64 alternating extremes";
        36: softmax_test_name = "one_hot start            N=8";
        37: softmax_test_name = "one_hot end              N=8";
        38: softmax_test_name = "one_hot middle           N=16";
        39: softmax_test_name = "ascending                N=8";
        40: softmax_test_name = "descending               N=8";
        41: softmax_test_name = "uniform                  N=8";
        42: softmax_test_name = "near uniform             N=8";
        43: softmax_test_name = "boundary -201            N=4";
        44: softmax_test_name = "boundary +201            N=4";
        45: softmax_test_name = "boundary -11 / -10";
        46: softmax_test_name = "boundary +10 / +11";
        47: softmax_test_name = "Q16.16 range edges       N=2";
        48: softmax_test_name = "alt low                  N=16";
        49: softmax_test_name = "alt high                 N=16";
        50: softmax_test_name = "rand-000 N=194";
        51: softmax_test_name = "rand-001 N=255";
        52: softmax_test_name = "rand-002 N=301";
        53: softmax_test_name = "rand-003 N=498";
        54: softmax_test_name = "rand-004 N=351";
        55: softmax_test_name = "rand-005 N=296";
        56: softmax_test_name = "rand-006 N=94";
        57: softmax_test_name = "rand-007 N=436";
        58: softmax_test_name = "rand-008 N=410";
        59: softmax_test_name = "rand-009 N=496";
        60: softmax_test_name = "rand-010 N= 2";
        61: softmax_test_name = "rand-011 N=327";
        62: softmax_test_name = "rand-012 N=431";
        63: softmax_test_name = "rand-013 N=461";
        64: softmax_test_name = "rand-014 N=73";
        65: softmax_test_name = "rand-015 N=277";
        66: softmax_test_name = "rand-016 N=122";
        67: softmax_test_name = "rand-017 N=345";
        68: softmax_test_name = "rand-018 N=160";
        69: softmax_test_name = "rand-019 N=255";
        70: softmax_test_name = "rand-020 N=12";
        71: softmax_test_name = "rand-021 N=118";
        72: softmax_test_name = "rand-022 N=317";
        73: softmax_test_name = "rand-023 N=270";
        74: softmax_test_name = "rand-024 N=428";
        75: softmax_test_name = "rand-025 N=336";
        76: softmax_test_name = "rand-026 N=438";
        77: softmax_test_name = "rand-027 N=252";
        78: softmax_test_name = "rand-028 N=148";
        79: softmax_test_name = "rand-029 N=235";
        80: softmax_test_name = "rand-030 N=37";
        81: softmax_test_name = "rand-031 N=299";
        82: softmax_test_name = "rand-032 N=146";
        83: softmax_test_name = "rand-033 N=298";
        84: softmax_test_name = "rand-034 N=93";
        85: softmax_test_name = "rand-035 N=462";
        86: softmax_test_name = "rand-036 N=89";
        87: softmax_test_name = "rand-037 N=377";
        88: softmax_test_name = "rand-038 N=93";
        89: softmax_test_name = "rand-039 N=159";
        90: softmax_test_name = "rand-040 N=131";
        91: softmax_test_name = "rand-041 N=63";
        92: softmax_test_name = "rand-042 N=95";
        93: softmax_test_name = "rand-043 N=19";
        94: softmax_test_name = "rand-044 N=121";
        95: softmax_test_name = "rand-045 N=161";
        96: softmax_test_name = "rand-046 N=187";
        97: softmax_test_name = "rand-047 N=215";
        98: softmax_test_name = "rand-048 N=372";
        99: softmax_test_name = "rand-049 N=175";
        100: softmax_test_name = "rand-050 N=299";
        101: softmax_test_name = "rand-051 N=284";
        102: softmax_test_name = "rand-052 N=281";
        103: softmax_test_name = "rand-053 N=237";
        104: softmax_test_name = "rand-054 N=377";
        105: softmax_test_name = "rand-055 N=21";
        106: softmax_test_name = "rand-056 N=320";
        107: softmax_test_name = "rand-057 N=496";
        108: softmax_test_name = "rand-058 N=328";
        109: softmax_test_name = "rand-059 N=163";
        110: softmax_test_name = "rand-060 N=490";
        111: softmax_test_name = "rand-061 N= 2";
        112: softmax_test_name = "rand-062 N=257";
        113: softmax_test_name = "rand-063 N=180";
        114: softmax_test_name = "rand-064 N=422";
        115: softmax_test_name = "rand-065 N=185";
        116: softmax_test_name = "rand-066 N=313";
        117: softmax_test_name = "rand-067 N=350";
        118: softmax_test_name = "rand-068 N=407";
        119: softmax_test_name = "rand-069 N=414";
        120: softmax_test_name = "rand-070 N=448";
        121: softmax_test_name = "rand-071 N=353";
        122: softmax_test_name = "rand-072 N=277";
        123: softmax_test_name = "rand-073 N=55";
        124: softmax_test_name = "rand-074 N=376";
        125: softmax_test_name = "rand-075 N=423";
        126: softmax_test_name = "rand-076 N=178";
        127: softmax_test_name = "rand-077 N= 1";
        128: softmax_test_name = "rand-078 N=497";
        129: softmax_test_name = "rand-079 N=175";
        130: softmax_test_name = "rand-080 N=491";
        131: softmax_test_name = "rand-081 N=209";
        132: softmax_test_name = "rand-082 N=18";
        133: softmax_test_name = "rand-083 N=169";
        134: softmax_test_name = "rand-084 N=314";
        135: softmax_test_name = "rand-085 N=173";
        136: softmax_test_name = "rand-086 N=389";
        137: softmax_test_name = "rand-087 N=12";
        138: softmax_test_name = "rand-088 N=33";
        139: softmax_test_name = "rand-089 N=127";
        140: softmax_test_name = "rand-090 N=445";
        141: softmax_test_name = "rand-091 N=413";
        142: softmax_test_name = "rand-092 N=466";
        143: softmax_test_name = "rand-093 N=387";
        144: softmax_test_name = "rand-094 N=199";
        145: softmax_test_name = "rand-095 N=458";
        146: softmax_test_name = "rand-096 N=125";
        147: softmax_test_name = "rand-097 N=258";
        148: softmax_test_name = "rand-098 N=258";
        149: softmax_test_name = "rand-099 N=199";
        150: softmax_test_name = "rand-100 N=167";
        151: softmax_test_name = "rand-101 N=308";
        152: softmax_test_name = "rand-102 N=189";
        153: softmax_test_name = "rand-103 N=173";
        154: softmax_test_name = "rand-104 N=187";
        155: softmax_test_name = "rand-105 N=178";
        156: softmax_test_name = "rand-106 N=122";
        157: softmax_test_name = "rand-107 N=334";
        158: softmax_test_name = "rand-108 N=129";
        159: softmax_test_name = "rand-109 N=266";
        160: softmax_test_name = "rand-110 N=10";
        161: softmax_test_name = "rand-111 N=369";
        162: softmax_test_name = "rand-112 N=338";
        163: softmax_test_name = "rand-113 N=322";
        164: softmax_test_name = "rand-114 N=25";
        165: softmax_test_name = "rand-115 N=163";
        166: softmax_test_name = "rand-116 N=144";
        167: softmax_test_name = "rand-117 N=339";
        168: softmax_test_name = "rand-118 N=98";
        169: softmax_test_name = "rand-119 N=239";
        170: softmax_test_name = "rand-120 N=417";
        171: softmax_test_name = "rand-121 N=438";
        172: softmax_test_name = "rand-122 N=61";
        173: softmax_test_name = "rand-123 N=457";
        174: softmax_test_name = "rand-124 N=238";
        175: softmax_test_name = "rand-125 N=147";
        176: softmax_test_name = "rand-126 N=114";
        177: softmax_test_name = "rand-127 N=37";
        178: softmax_test_name = "rand-128 N=162";
        179: softmax_test_name = "rand-129 N=226";
        180: softmax_test_name = "rand-130 N=191";
        181: softmax_test_name = "rand-131 N=418";
        182: softmax_test_name = "rand-132 N=301";
        183: softmax_test_name = "rand-133 N=18";
        184: softmax_test_name = "rand-134 N=136";
        185: softmax_test_name = "rand-135 N=216";
        186: softmax_test_name = "rand-136 N=406";
        187: softmax_test_name = "rand-137 N=477";
        188: softmax_test_name = "rand-138 N=496";
        189: softmax_test_name = "rand-139 N=328";
        190: softmax_test_name = "rand-140 N=26";
        191: softmax_test_name = "rand-141 N=254";
        192: softmax_test_name = "rand-142 N=201";
        193: softmax_test_name = "rand-143 N=143";
        194: softmax_test_name = "rand-144 N=347";
        195: softmax_test_name = "rand-145 N=120";
        196: softmax_test_name = "rand-146 N=439";
        197: softmax_test_name = "rand-147 N= 4";
        198: softmax_test_name = "rand-148 N=463";
        199: softmax_test_name = "rand-149 N=498";
        200: softmax_test_name = "rand-150 N=375";
        201: softmax_test_name = "rand-151 N=484";
        202: softmax_test_name = "rand-152 N=178";
        203: softmax_test_name = "rand-153 N=84";
        204: softmax_test_name = "rand-154 N=116";
        205: softmax_test_name = "rand-155 N=347";
        206: softmax_test_name = "rand-156 N=431";
        207: softmax_test_name = "rand-157 N=296";
        208: softmax_test_name = "rand-158 N=138";
        209: softmax_test_name = "rand-159 N=302";
        210: softmax_test_name = "rand-160 N=397";
        211: softmax_test_name = "rand-161 N=300";
        212: softmax_test_name = "rand-162 N=156";
        213: softmax_test_name = "rand-163 N=32";
        214: softmax_test_name = "rand-164 N=279";
        215: softmax_test_name = "rand-165 N=500";
        216: softmax_test_name = "rand-166 N=310";
        217: softmax_test_name = "rand-167 N=124";
        218: softmax_test_name = "rand-168 N=442";
        219: softmax_test_name = "rand-169 N=31";
        220: softmax_test_name = "rand-170 N=346";
        221: softmax_test_name = "rand-171 N=106";
        222: softmax_test_name = "rand-172 N=200";
        223: softmax_test_name = "rand-173 N=276";
        224: softmax_test_name = "rand-174 N=135";
        225: softmax_test_name = "rand-175 N=305";
        226: softmax_test_name = "rand-176 N=204";
        227: softmax_test_name = "rand-177 N=97";
        228: softmax_test_name = "rand-178 N=409";
        229: softmax_test_name = "rand-179 N=265";
        230: softmax_test_name = "rand-180 N=332";
        231: softmax_test_name = "rand-181 N=121";
        232: softmax_test_name = "rand-182 N=307";
        233: softmax_test_name = "rand-183 N=122";
        234: softmax_test_name = "rand-184 N=252";
        235: softmax_test_name = "rand-185 N=402";
        236: softmax_test_name = "rand-186 N=335";
        237: softmax_test_name = "rand-187 N=476";
        238: softmax_test_name = "rand-188 N=419";
        239: softmax_test_name = "rand-189 N=114";
        240: softmax_test_name = "rand-190 N=297";
        241: softmax_test_name = "rand-191 N=400";
        242: softmax_test_name = "rand-192 N=280";
        243: softmax_test_name = "rand-193 N=290";
        244: softmax_test_name = "rand-194 N=302";
        245: softmax_test_name = "rand-195 N=252";
        246: softmax_test_name = "rand-196 N=406";
        247: softmax_test_name = "rand-197 N=372";
        248: softmax_test_name = "rand-198 N=52";
        249: softmax_test_name = "rand-199 N=177";
        250: softmax_test_name = "rand-200 N=157";
        251: softmax_test_name = "rand-201 N=373";
        252: softmax_test_name = "rand-202 N=43";
        253: softmax_test_name = "rand-203 N=153";
        254: softmax_test_name = "rand-204 N=207";
        255: softmax_test_name = "rand-205 N=229";
        256: softmax_test_name = "rand-206 N=36";
        257: softmax_test_name = "rand-207 N=111";
        258: softmax_test_name = "rand-208 N=258";
        259: softmax_test_name = "rand-209 N=13";
        260: softmax_test_name = "rand-210 N=205";
        261: softmax_test_name = "rand-211 N=48";
        262: softmax_test_name = "rand-212 N=256";
        263: softmax_test_name = "rand-213 N=399";
        264: softmax_test_name = "rand-214 N=286";
        265: softmax_test_name = "rand-215 N=334";
        266: softmax_test_name = "rand-216 N=349";
        267: softmax_test_name = "rand-217 N= 2";
        268: softmax_test_name = "rand-218 N=478";
        269: softmax_test_name = "rand-219 N=460";
        270: softmax_test_name = "rand-220 N=167";
        271: softmax_test_name = "rand-221 N=62";
        272: softmax_test_name = "rand-222 N=220";
        273: softmax_test_name = "rand-223 N=104";
        274: softmax_test_name = "rand-224 N=429";
        275: softmax_test_name = "rand-225 N=430";
        276: softmax_test_name = "rand-226 N=106";
        277: softmax_test_name = "rand-227 N=81";
        278: softmax_test_name = "rand-228 N=447";
        279: softmax_test_name = "rand-229 N=190";
        280: softmax_test_name = "rand-230 N=252";
        281: softmax_test_name = "rand-231 N=495";
        282: softmax_test_name = "rand-232 N=392";
        283: softmax_test_name = "rand-233 N=63";
        284: softmax_test_name = "rand-234 N=108";
        285: softmax_test_name = "rand-235 N=75";
        286: softmax_test_name = "rand-236 N=153";
        287: softmax_test_name = "rand-237 N=493";
        288: softmax_test_name = "rand-238 N=242";
        289: softmax_test_name = "rand-239 N=21";
        290: softmax_test_name = "rand-240 N=438";
        291: softmax_test_name = "rand-241 N=159";
        292: softmax_test_name = "rand-242 N=164";
        293: softmax_test_name = "rand-243 N=135";
        294: softmax_test_name = "rand-244 N=238";
        295: softmax_test_name = "rand-245 N=244";
        296: softmax_test_name = "rand-246 N=411";
        297: softmax_test_name = "rand-247 N=241";
        298: softmax_test_name = "rand-248 N= 8";
        299: softmax_test_name = "rand-249 N=154";
        300: softmax_test_name = "rand-250 N=322";
        301: softmax_test_name = "rand-251 N=465";
        302: softmax_test_name = "rand-252 N=121";
        303: softmax_test_name = "rand-253 N= 7";
        304: softmax_test_name = "rand-254 N=398";
        305: softmax_test_name = "rand-255 N=241";
        306: softmax_test_name = "rand-256 N=401";
        307: softmax_test_name = "rand-257 N= 5";
        308: softmax_test_name = "rand-258 N=109";
        309: softmax_test_name = "rand-259 N=314";
        310: softmax_test_name = "rand-260 N=255";
        311: softmax_test_name = "rand-261 N=271";
        312: softmax_test_name = "rand-262 N=291";
        313: softmax_test_name = "rand-263 N=426";
        314: softmax_test_name = "rand-264 N=163";
        315: softmax_test_name = "rand-265 N=183";
        316: softmax_test_name = "rand-266 N=420";
        317: softmax_test_name = "rand-267 N=152";
        318: softmax_test_name = "rand-268 N=474";
        319: softmax_test_name = "rand-269 N=452";
        320: softmax_test_name = "rand-270 N=166";
        321: softmax_test_name = "rand-271 N=256";
        322: softmax_test_name = "rand-272 N=278";
        323: softmax_test_name = "rand-273 N=274";
        324: softmax_test_name = "rand-274 N=405";
        325: softmax_test_name = "rand-275 N=478";
        326: softmax_test_name = "rand-276 N=369";
        327: softmax_test_name = "rand-277 N=127";
        328: softmax_test_name = "rand-278 N=265";
        329: softmax_test_name = "rand-279 N=485";
        330: softmax_test_name = "rand-280 N=364";
        331: softmax_test_name = "rand-281 N=281";
        332: softmax_test_name = "rand-282 N=136";
        333: softmax_test_name = "rand-283 N= 3";
        334: softmax_test_name = "rand-284 N=140";
        335: softmax_test_name = "rand-285 N=447";
        336: softmax_test_name = "rand-286 N=189";
        337: softmax_test_name = "rand-287 N=166";
        338: softmax_test_name = "rand-288 N=425";
        339: softmax_test_name = "rand-289 N=118";
        340: softmax_test_name = "rand-290 N=442";
        341: softmax_test_name = "rand-291 N= 6";
        342: softmax_test_name = "rand-292 N=111";
        343: softmax_test_name = "rand-293 N=92";
        344: softmax_test_name = "rand-294 N=42";
        345: softmax_test_name = "rand-295 N=257";
        346: softmax_test_name = "rand-296 N=327";
        347: softmax_test_name = "rand-297 N=444";
        348: softmax_test_name = "rand-298 N=289";
        349: softmax_test_name = "rand-299 N=272";
        350: softmax_test_name = "rand-300 N= 9";
        351: softmax_test_name = "rand-301 N=308";
        352: softmax_test_name = "rand-302 N=446";
        353: softmax_test_name = "rand-303 N=299";
        354: softmax_test_name = "rand-304 N=161";
        355: softmax_test_name = "rand-305 N=246";
        356: softmax_test_name = "rand-306 N=289";
        357: softmax_test_name = "rand-307 N=313";
        358: softmax_test_name = "rand-308 N=67";
        359: softmax_test_name = "rand-309 N=17";
        360: softmax_test_name = "rand-310 N=266";
        361: softmax_test_name = "rand-311 N= 3";
        362: softmax_test_name = "rand-312 N=88";
        363: softmax_test_name = "rand-313 N=80";
        364: softmax_test_name = "rand-314 N=499";
        365: softmax_test_name = "rand-315 N=180";
        366: softmax_test_name = "rand-316 N=57";
        367: softmax_test_name = "rand-317 N=13";
        368: softmax_test_name = "rand-318 N=170";
        369: softmax_test_name = "rand-319 N=461";
        370: softmax_test_name = "rand-320 N=226";
        371: softmax_test_name = "rand-321 N=480";
        372: softmax_test_name = "rand-322 N=398";
        373: softmax_test_name = "rand-323 N=147";
        374: softmax_test_name = "rand-324 N=377";
        375: softmax_test_name = "rand-325 N=425";
        376: softmax_test_name = "rand-326 N=331";
        377: softmax_test_name = "rand-327 N=124";
        378: softmax_test_name = "rand-328 N=225";
        379: softmax_test_name = "rand-329 N=385";
        380: softmax_test_name = "rand-330 N=384";
        381: softmax_test_name = "rand-331 N=195";
        382: softmax_test_name = "rand-332 N=484";
        383: softmax_test_name = "rand-333 N=118";
        384: softmax_test_name = "rand-334 N=176";
        385: softmax_test_name = "rand-335 N=188";
        386: softmax_test_name = "rand-336 N=168";
        387: softmax_test_name = "rand-337 N=165";
        388: softmax_test_name = "rand-338 N=14";
        389: softmax_test_name = "rand-339 N=196";
        390: softmax_test_name = "rand-340 N=118";
        391: softmax_test_name = "rand-341 N=104";
        392: softmax_test_name = "rand-342 N=289";
        393: softmax_test_name = "rand-343 N= 3";
        394: softmax_test_name = "rand-344 N=47";
        395: softmax_test_name = "rand-345 N=319";
        396: softmax_test_name = "rand-346 N=223";
        397: softmax_test_name = "rand-347 N=105";
        398: softmax_test_name = "rand-348 N=413";
        399: softmax_test_name = "rand-349 N=95";
        400: softmax_test_name = "rand-350 N=421";
        401: softmax_test_name = "rand-351 N=144";
        402: softmax_test_name = "rand-352 N=38";
        403: softmax_test_name = "rand-353 N=268";
        404: softmax_test_name = "rand-354 N=440";
        405: softmax_test_name = "rand-355 N=241";
        406: softmax_test_name = "rand-356 N=349";
        407: softmax_test_name = "rand-357 N=186";
        408: softmax_test_name = "rand-358 N=336";
        409: softmax_test_name = "rand-359 N=132";
        410: softmax_test_name = "rand-360 N=128";
        411: softmax_test_name = "rand-361 N=113";
        412: softmax_test_name = "rand-362 N=308";
        413: softmax_test_name = "rand-363 N=364";
        414: softmax_test_name = "rand-364 N=479";
        415: softmax_test_name = "rand-365 N=249";
        416: softmax_test_name = "rand-366 N=190";
        417: softmax_test_name = "rand-367 N=497";
        418: softmax_test_name = "rand-368 N= 6";
        419: softmax_test_name = "rand-369 N=43";
        420: softmax_test_name = "rand-370 N=381";
        421: softmax_test_name = "rand-371 N=425";
        422: softmax_test_name = "rand-372 N=56";
        423: softmax_test_name = "rand-373 N=436";
        424: softmax_test_name = "rand-374 N=355";
        425: softmax_test_name = "rand-375 N=355";
        426: softmax_test_name = "rand-376 N=116";
        427: softmax_test_name = "rand-377 N=145";
        428: softmax_test_name = "rand-378 N=343";
        429: softmax_test_name = "rand-379 N=289";
        430: softmax_test_name = "rand-380 N=22";
        431: softmax_test_name = "rand-381 N=355";
        432: softmax_test_name = "rand-382 N=286";
        433: softmax_test_name = "rand-383 N=424";
        434: softmax_test_name = "rand-384 N=485";
        435: softmax_test_name = "rand-385 N=41";
        436: softmax_test_name = "rand-386 N=454";
        437: softmax_test_name = "rand-387 N=450";
        438: softmax_test_name = "rand-388 N=286";
        439: softmax_test_name = "rand-389 N=72";
        440: softmax_test_name = "rand-390 N=163";
        441: softmax_test_name = "rand-391 N=378";
        442: softmax_test_name = "rand-392 N=191";
        443: softmax_test_name = "rand-393 N=469";
        444: softmax_test_name = "rand-394 N=494";
        445: softmax_test_name = "rand-395 N=307";
        446: softmax_test_name = "rand-396 N=171";
        447: softmax_test_name = "rand-397 N=424";
        448: softmax_test_name = "rand-398 N=130";
        449: softmax_test_name = "rand-399 N= 7";
        450: softmax_test_name = "rand-400 N=26";
        451: softmax_test_name = "rand-401 N=366";
        452: softmax_test_name = "rand-402 N=308";
        453: softmax_test_name = "rand-403 N=406";
        454: softmax_test_name = "rand-404 N=458";
        455: softmax_test_name = "rand-405 N=97";
        456: softmax_test_name = "rand-406 N=400";
        457: softmax_test_name = "rand-407 N=284";
        458: softmax_test_name = "rand-408 N=46";
        459: softmax_test_name = "rand-409 N= 9";
        460: softmax_test_name = "rand-410 N=288";
        461: softmax_test_name = "rand-411 N=52";
        462: softmax_test_name = "rand-412 N=332";
        463: softmax_test_name = "rand-413 N=465";
        464: softmax_test_name = "rand-414 N=181";
        465: softmax_test_name = "rand-415 N=393";
        466: softmax_test_name = "rand-416 N=479";
        467: softmax_test_name = "rand-417 N=63";
        468: softmax_test_name = "rand-418 N=208";
        469: softmax_test_name = "rand-419 N=459";
        470: softmax_test_name = "rand-420 N=83";
        471: softmax_test_name = "rand-421 N=35";
        472: softmax_test_name = "rand-422 N=366";
        473: softmax_test_name = "rand-423 N=251";
        474: softmax_test_name = "rand-424 N=396";
        475: softmax_test_name = "rand-425 N=382";
        476: softmax_test_name = "rand-426 N=290";
        477: softmax_test_name = "rand-427 N=360";
        478: softmax_test_name = "rand-428 N=317";
        479: softmax_test_name = "rand-429 N=327";
        480: softmax_test_name = "rand-430 N=206";
        481: softmax_test_name = "rand-431 N=185";
        482: softmax_test_name = "rand-432 N=246";
        483: softmax_test_name = "rand-433 N=416";
        484: softmax_test_name = "rand-434 N=121";
        485: softmax_test_name = "rand-435 N=15";
        486: softmax_test_name = "rand-436 N=16";
        487: softmax_test_name = "rand-437 N=361";
        488: softmax_test_name = "rand-438 N=102";
        489: softmax_test_name = "rand-439 N=425";
        490: softmax_test_name = "rand-440 N=24";
        491: softmax_test_name = "rand-441 N=105";
        492: softmax_test_name = "rand-442 N=462";
        493: softmax_test_name = "rand-443 N=123";
        494: softmax_test_name = "rand-444 N=281";
        495: softmax_test_name = "rand-445 N=290";
        496: softmax_test_name = "rand-446 N=185";
        497: softmax_test_name = "rand-447 N=71";
        498: softmax_test_name = "rand-448 N=274";
        499: softmax_test_name = "rand-449 N=323";
        500: softmax_test_name = "rand-450 N=286";
        501: softmax_test_name = "rand-451 N=210";
        502: softmax_test_name = "rand-452 N=139";
        503: softmax_test_name = "rand-453 N=414";
        504: softmax_test_name = "rand-454 N=493";
        505: softmax_test_name = "rand-455 N=303";
        506: softmax_test_name = "rand-456 N=292";
        507: softmax_test_name = "rand-457 N=17";
        508: softmax_test_name = "rand-458 N=335";
        509: softmax_test_name = "rand-459 N=210";
        510: softmax_test_name = "rand-460 N=238";
        511: softmax_test_name = "rand-461 N=117";
        512: softmax_test_name = "rand-462 N=117";
        513: softmax_test_name = "rand-463 N=184";
        514: softmax_test_name = "rand-464 N=311";
        515: softmax_test_name = "rand-465 N=307";
        516: softmax_test_name = "rand-466 N=453";
        517: softmax_test_name = "rand-467 N=438";
        518: softmax_test_name = "rand-468 N= 2";
        519: softmax_test_name = "rand-469 N=463";
        520: softmax_test_name = "rand-470 N=122";
        521: softmax_test_name = "rand-471 N=204";
        522: softmax_test_name = "rand-472 N=417";
        523: softmax_test_name = "rand-473 N=445";
        524: softmax_test_name = "rand-474 N=463";
        525: softmax_test_name = "rand-475 N=100";
        526: softmax_test_name = "rand-476 N=388";
        527: softmax_test_name = "rand-477 N=43";
        528: softmax_test_name = "rand-478 N=78";
        529: softmax_test_name = "rand-479 N=40";
        530: softmax_test_name = "rand-480 N=407";
        531: softmax_test_name = "rand-481 N=483";
        532: softmax_test_name = "rand-482 N=173";
        533: softmax_test_name = "rand-483 N=53";
        534: softmax_test_name = "rand-484 N=196";
        535: softmax_test_name = "rand-485 N=140";
        536: softmax_test_name = "rand-486 N=44";
        537: softmax_test_name = "rand-487 N=46";
        538: softmax_test_name = "rand-488 N=340";
        539: softmax_test_name = "rand-489 N=256";
        540: softmax_test_name = "rand-490 N=55";
        541: softmax_test_name = "rand-491 N=493";
        542: softmax_test_name = "rand-492 N=250";
        543: softmax_test_name = "rand-493 N=216";
        544: softmax_test_name = "rand-494 N=361";
        545: softmax_test_name = "rand-495 N=126";
        546: softmax_test_name = "rand-496 N=42";
        547: softmax_test_name = "rand-497 N=262";
        548: softmax_test_name = "rand-498 N=363";
        549: softmax_test_name = "rand-499 N=205";
        550: softmax_test_name = "rand-500 N=22";
        551: softmax_test_name = "rand-501 N=479";
        552: softmax_test_name = "rand-502 N=317";
        553: softmax_test_name = "rand-503 N=287";
        554: softmax_test_name = "rand-504 N=213";
        555: softmax_test_name = "rand-505 N=84";
        556: softmax_test_name = "rand-506 N=194";
        557: softmax_test_name = "rand-507 N=403";
        558: softmax_test_name = "rand-508 N=96";
        559: softmax_test_name = "rand-509 N=246";
        560: softmax_test_name = "rand-510 N=418";
        561: softmax_test_name = "rand-511 N=365";
        562: softmax_test_name = "rand-512 N=361";
        563: softmax_test_name = "rand-513 N=186";
        564: softmax_test_name = "rand-514 N=81";
        565: softmax_test_name = "rand-515 N=298";
        566: softmax_test_name = "rand-516 N=394";
        567: softmax_test_name = "rand-517 N=231";
        568: softmax_test_name = "rand-518 N=375";
        569: softmax_test_name = "rand-519 N=402";
        570: softmax_test_name = "rand-520 N=381";
        571: softmax_test_name = "rand-521 N=42";
        572: softmax_test_name = "rand-522 N=137";
        573: softmax_test_name = "rand-523 N=400";
        574: softmax_test_name = "rand-524 N=409";
        575: softmax_test_name = "rand-525 N=99";
        576: softmax_test_name = "rand-526 N=25";
        577: softmax_test_name = "rand-527 N=421";
        578: softmax_test_name = "rand-528 N=20";
        579: softmax_test_name = "rand-529 N=185";
        580: softmax_test_name = "rand-530 N=199";
        581: softmax_test_name = "rand-531 N=197";
        582: softmax_test_name = "rand-532 N=197";
        583: softmax_test_name = "rand-533 N=379";
        584: softmax_test_name = "rand-534 N=306";
        585: softmax_test_name = "rand-535 N=61";
        586: softmax_test_name = "rand-536 N=224";
        587: softmax_test_name = "rand-537 N=420";
        588: softmax_test_name = "rand-538 N=102";
        589: softmax_test_name = "rand-539 N=116";
        590: softmax_test_name = "rand-540 N=46";
        591: softmax_test_name = "rand-541 N=256";
        592: softmax_test_name = "rand-542 N=390";
        593: softmax_test_name = "rand-543 N=175";
        594: softmax_test_name = "rand-544 N=334";
        595: softmax_test_name = "rand-545 N=440";
        596: softmax_test_name = "rand-546 N=62";
        597: softmax_test_name = "rand-547 N=144";
        598: softmax_test_name = "rand-548 N=22";
        599: softmax_test_name = "rand-549 N=280";
        600: softmax_test_name = "rand-550 N=488";
        601: softmax_test_name = "rand-551 N=142";
        602: softmax_test_name = "rand-552 N=349";
        603: softmax_test_name = "rand-553 N=35";
        604: softmax_test_name = "rand-554 N=287";
        605: softmax_test_name = "rand-555 N=463";
        606: softmax_test_name = "rand-556 N=393";
        607: softmax_test_name = "rand-557 N=11";
        608: softmax_test_name = "rand-558 N=205";
        609: softmax_test_name = "rand-559 N=75";
        610: softmax_test_name = "rand-560 N=135";
        611: softmax_test_name = "rand-561 N=123";
        612: softmax_test_name = "rand-562 N=436";
        613: softmax_test_name = "rand-563 N=352";
        614: softmax_test_name = "rand-564 N=240";
        615: softmax_test_name = "rand-565 N=206";
        616: softmax_test_name = "rand-566 N=496";
        617: softmax_test_name = "rand-567 N=449";
        618: softmax_test_name = "rand-568 N=108";
        619: softmax_test_name = "rand-569 N=469";
        620: softmax_test_name = "rand-570 N=132";
        621: softmax_test_name = "rand-571 N=454";
        622: softmax_test_name = "rand-572 N=371";
        623: softmax_test_name = "rand-573 N=158";
        624: softmax_test_name = "rand-574 N=351";
        625: softmax_test_name = "rand-575 N=304";
        626: softmax_test_name = "rand-576 N=81";
        627: softmax_test_name = "rand-577 N=352";
        628: softmax_test_name = "rand-578 N=428";
        629: softmax_test_name = "rand-579 N=370";
        630: softmax_test_name = "rand-580 N=414";
        631: softmax_test_name = "rand-581 N=259";
        632: softmax_test_name = "rand-582 N=267";
        633: softmax_test_name = "rand-583 N=247";
        634: softmax_test_name = "rand-584 N=53";
        635: softmax_test_name = "rand-585 N=86";
        636: softmax_test_name = "rand-586 N=341";
        637: softmax_test_name = "rand-587 N=65";
        638: softmax_test_name = "rand-588 N=128";
        639: softmax_test_name = "rand-589 N=200";
        640: softmax_test_name = "rand-590 N=206";
        641: softmax_test_name = "rand-591 N=237";
        642: softmax_test_name = "rand-592 N=180";
        643: softmax_test_name = "rand-593 N=330";
        644: softmax_test_name = "rand-594 N=159";
        645: softmax_test_name = "rand-595 N=180";
        646: softmax_test_name = "rand-596 N=388";
        647: softmax_test_name = "rand-597 N=469";
        648: softmax_test_name = "rand-598 N=90";
        649: softmax_test_name = "rand-599 N=399";
        650: softmax_test_name = "rand-600 N=216";
        651: softmax_test_name = "rand-601 N=112";
        652: softmax_test_name = "rand-602 N=488";
        653: softmax_test_name = "rand-603 N=436";
        654: softmax_test_name = "rand-604 N=197";
        655: softmax_test_name = "rand-605 N=443";
        656: softmax_test_name = "rand-606 N=383";
        657: softmax_test_name = "rand-607 N=94";
        658: softmax_test_name = "rand-608 N=81";
        659: softmax_test_name = "rand-609 N=229";
        660: softmax_test_name = "rand-610 N=34";
        661: softmax_test_name = "rand-611 N=162";
        662: softmax_test_name = "rand-612 N=447";
        663: softmax_test_name = "rand-613 N=396";
        664: softmax_test_name = "rand-614 N=78";
        665: softmax_test_name = "rand-615 N=58";
        666: softmax_test_name = "rand-616 N=367";
        667: softmax_test_name = "rand-617 N=249";
        668: softmax_test_name = "rand-618 N=325";
        669: softmax_test_name = "rand-619 N=248";
        670: softmax_test_name = "rand-620 N=375";
        671: softmax_test_name = "rand-621 N=317";
        672: softmax_test_name = "rand-622 N=109";
        673: softmax_test_name = "rand-623 N=303";
        674: softmax_test_name = "rand-624 N=72";
        675: softmax_test_name = "rand-625 N=409";
        676: softmax_test_name = "rand-626 N=189";
        677: softmax_test_name = "rand-627 N=228";
        678: softmax_test_name = "rand-628 N=92";
        679: softmax_test_name = "rand-629 N=168";
        680: softmax_test_name = "rand-630 N=95";
        681: softmax_test_name = "rand-631 N=481";
        682: softmax_test_name = "rand-632 N=382";
        683: softmax_test_name = "rand-633 N=255";
        684: softmax_test_name = "rand-634 N= 1";
        685: softmax_test_name = "rand-635 N=329";
        686: softmax_test_name = "rand-636 N=133";
        687: softmax_test_name = "rand-637 N=114";
        688: softmax_test_name = "rand-638 N=464";
        689: softmax_test_name = "rand-639 N=372";
        690: softmax_test_name = "rand-640 N=124";
        691: softmax_test_name = "rand-641 N=183";
        692: softmax_test_name = "rand-642 N=196";
        693: softmax_test_name = "rand-643 N=272";
        694: softmax_test_name = "rand-644 N=314";
        695: softmax_test_name = "rand-645 N=339";
        696: softmax_test_name = "rand-646 N=449";
        697: softmax_test_name = "rand-647 N=31";
        698: softmax_test_name = "rand-648 N=154";
        699: softmax_test_name = "rand-649 N=226";
        700: softmax_test_name = "rand-650 N=492";
        701: softmax_test_name = "rand-651 N=327";
        702: softmax_test_name = "rand-652 N=357";
        703: softmax_test_name = "rand-653 N=135";
        704: softmax_test_name = "rand-654 N=171";
        705: softmax_test_name = "rand-655 N=88";
        706: softmax_test_name = "rand-656 N=406";
        707: softmax_test_name = "rand-657 N=372";
        708: softmax_test_name = "rand-658 N=410";
        709: softmax_test_name = "rand-659 N=474";
        710: softmax_test_name = "rand-660 N=93";
        711: softmax_test_name = "rand-661 N=159";
        712: softmax_test_name = "rand-662 N=408";
        713: softmax_test_name = "rand-663 N=20";
        714: softmax_test_name = "rand-664 N=457";
        715: softmax_test_name = "rand-665 N=236";
        716: softmax_test_name = "rand-666 N=491";
        717: softmax_test_name = "rand-667 N=160";
        718: softmax_test_name = "rand-668 N=478";
        719: softmax_test_name = "rand-669 N=490";
        720: softmax_test_name = "rand-670 N=453";
        721: softmax_test_name = "rand-671 N=494";
        722: softmax_test_name = "rand-672 N=438";
        723: softmax_test_name = "rand-673 N=103";
        724: softmax_test_name = "rand-674 N=380";
        725: softmax_test_name = "rand-675 N=413";
        726: softmax_test_name = "rand-676 N=354";
        727: softmax_test_name = "rand-677 N=188";
        728: softmax_test_name = "rand-678 N=148";
        729: softmax_test_name = "rand-679 N=424";
        730: softmax_test_name = "rand-680 N=143";
        731: softmax_test_name = "rand-681 N=52";
        732: softmax_test_name = "rand-682 N=395";
        733: softmax_test_name = "rand-683 N=225";
        734: softmax_test_name = "rand-684 N=479";
        735: softmax_test_name = "rand-685 N=415";
        736: softmax_test_name = "rand-686 N=394";
        737: softmax_test_name = "rand-687 N=389";
        738: softmax_test_name = "rand-688 N=295";
        739: softmax_test_name = "rand-689 N=432";
        740: softmax_test_name = "rand-690 N=242";
        741: softmax_test_name = "rand-691 N=318";
        742: softmax_test_name = "rand-692 N=344";
        743: softmax_test_name = "rand-693 N=497";
        744: softmax_test_name = "rand-694 N=380";
        745: softmax_test_name = "rand-695 N=274";
        746: softmax_test_name = "rand-696 N=255";
        747: softmax_test_name = "rand-697 N=367";
        748: softmax_test_name = "rand-698 N=103";
        749: softmax_test_name = "rand-699 N=91";
        750: softmax_test_name = "rand-700 N=284";
        751: softmax_test_name = "rand-701 N=338";
        752: softmax_test_name = "rand-702 N=103";
        753: softmax_test_name = "rand-703 N=37";
        754: softmax_test_name = "rand-704 N=317";
        755: softmax_test_name = "rand-705 N=447";
        756: softmax_test_name = "rand-706 N=442";
        757: softmax_test_name = "rand-707 N=450";
        758: softmax_test_name = "rand-708 N=257";
        759: softmax_test_name = "rand-709 N=159";
        760: softmax_test_name = "rand-710 N=101";
        761: softmax_test_name = "rand-711 N=413";
        762: softmax_test_name = "rand-712 N=120";
        763: softmax_test_name = "rand-713 N=65";
        764: softmax_test_name = "rand-714 N=422";
        765: softmax_test_name = "rand-715 N=407";
        766: softmax_test_name = "rand-716 N=156";
        767: softmax_test_name = "rand-717 N=121";
        768: softmax_test_name = "rand-718 N=422";
        769: softmax_test_name = "rand-719 N=173";
        770: softmax_test_name = "rand-720 N= 5";
        771: softmax_test_name = "rand-721 N=63";
        772: softmax_test_name = "rand-722 N=465";
        773: softmax_test_name = "rand-723 N=281";
        774: softmax_test_name = "rand-724 N=255";
        775: softmax_test_name = "rand-725 N=229";
        776: softmax_test_name = "rand-726 N=59";
        777: softmax_test_name = "rand-727 N=326";
        778: softmax_test_name = "rand-728 N=343";
        779: softmax_test_name = "rand-729 N=87";
        780: softmax_test_name = "rand-730 N=54";
        781: softmax_test_name = "rand-731 N=489";
        782: softmax_test_name = "rand-732 N=427";
        783: softmax_test_name = "rand-733 N=480";
        784: softmax_test_name = "rand-734 N=95";
        785: softmax_test_name = "rand-735 N=421";
        786: softmax_test_name = "rand-736 N=131";
        787: softmax_test_name = "rand-737 N=249";
        788: softmax_test_name = "rand-738 N=259";
        789: softmax_test_name = "rand-739 N=92";
        790: softmax_test_name = "rand-740 N=322";
        791: softmax_test_name = "rand-741 N=119";
        792: softmax_test_name = "rand-742 N=50";
        793: softmax_test_name = "rand-743 N=360";
        794: softmax_test_name = "rand-744 N=200";
        795: softmax_test_name = "rand-745 N=267";
        796: softmax_test_name = "rand-746 N=147";
        797: softmax_test_name = "rand-747 N=357";
        798: softmax_test_name = "rand-748 N=208";
        799: softmax_test_name = "rand-749 N=496";
        800: softmax_test_name = "rand-750 N=434";
        801: softmax_test_name = "rand-751 N=243";
        802: softmax_test_name = "rand-752 N=370";
        803: softmax_test_name = "rand-753 N=202";
        804: softmax_test_name = "rand-754 N=187";
        805: softmax_test_name = "rand-755 N=275";
        806: softmax_test_name = "rand-756 N=26";
        807: softmax_test_name = "rand-757 N=98";
        808: softmax_test_name = "rand-758 N=472";
        809: softmax_test_name = "rand-759 N=129";
        810: softmax_test_name = "rand-760 N=84";
        811: softmax_test_name = "rand-761 N=472";
        812: softmax_test_name = "rand-762 N=317";
        813: softmax_test_name = "rand-763 N=191";
        814: softmax_test_name = "rand-764 N=132";
        815: softmax_test_name = "rand-765 N=44";
        816: softmax_test_name = "rand-766 N=323";
        817: softmax_test_name = "rand-767 N=420";
        818: softmax_test_name = "rand-768 N=266";
        819: softmax_test_name = "rand-769 N=329";
        820: softmax_test_name = "rand-770 N=151";
        821: softmax_test_name = "rand-771 N=330";
        822: softmax_test_name = "rand-772 N=326";
        823: softmax_test_name = "rand-773 N=267";
        824: softmax_test_name = "rand-774 N=38";
        825: softmax_test_name = "rand-775 N=203";
        826: softmax_test_name = "rand-776 N=79";
        827: softmax_test_name = "rand-777 N=85";
        828: softmax_test_name = "rand-778 N=110";
        829: softmax_test_name = "rand-779 N=460";
        830: softmax_test_name = "rand-780 N=344";
        831: softmax_test_name = "rand-781 N=78";
        832: softmax_test_name = "rand-782 N=148";
        833: softmax_test_name = "rand-783 N=60";
        834: softmax_test_name = "rand-784 N=265";
        835: softmax_test_name = "rand-785 N=441";
        836: softmax_test_name = "rand-786 N=161";
        837: softmax_test_name = "rand-787 N=445";
        838: softmax_test_name = "rand-788 N=84";
        839: softmax_test_name = "rand-789 N=282";
        840: softmax_test_name = "rand-790 N=500";
        841: softmax_test_name = "rand-791 N=274";
        842: softmax_test_name = "rand-792 N=109";
        843: softmax_test_name = "rand-793 N=263";
        844: softmax_test_name = "rand-794 N=363";
        845: softmax_test_name = "rand-795 N=216";
        846: softmax_test_name = "rand-796 N=316";
        847: softmax_test_name = "rand-797 N=292";
        848: softmax_test_name = "rand-798 N=307";
        849: softmax_test_name = "rand-799 N=43";
        850: softmax_test_name = "rand-800 N=416";
        851: softmax_test_name = "rand-801 N=242";
        852: softmax_test_name = "rand-802 N=451";
        853: softmax_test_name = "rand-803 N=59";
        854: softmax_test_name = "rand-804 N=467";
        855: softmax_test_name = "rand-805 N=386";
        856: softmax_test_name = "rand-806 N=122";
        857: softmax_test_name = "rand-807 N=82";
        858: softmax_test_name = "rand-808 N=248";
        859: softmax_test_name = "rand-809 N=316";
        860: softmax_test_name = "rand-810 N=434";
        861: softmax_test_name = "rand-811 N=349";
        862: softmax_test_name = "rand-812 N=154";
        863: softmax_test_name = "rand-813 N=209";
        864: softmax_test_name = "rand-814 N=301";
        865: softmax_test_name = "rand-815 N=294";
        866: softmax_test_name = "rand-816 N=247";
        867: softmax_test_name = "rand-817 N=189";
        868: softmax_test_name = "rand-818 N=439";
        869: softmax_test_name = "rand-819 N=178";
        870: softmax_test_name = "rand-820 N=294";
        871: softmax_test_name = "rand-821 N=205";
        872: softmax_test_name = "rand-822 N=346";
        873: softmax_test_name = "rand-823 N=430";
        874: softmax_test_name = "rand-824 N=483";
        875: softmax_test_name = "rand-825 N=134";
        876: softmax_test_name = "rand-826 N=125";
        877: softmax_test_name = "rand-827 N=367";
        878: softmax_test_name = "rand-828 N=138";
        879: softmax_test_name = "rand-829 N=234";
        880: softmax_test_name = "rand-830 N=253";
        881: softmax_test_name = "rand-831 N=430";
        882: softmax_test_name = "rand-832 N=36";
        883: softmax_test_name = "rand-833 N=113";
        884: softmax_test_name = "rand-834 N=346";
        885: softmax_test_name = "rand-835 N=423";
        886: softmax_test_name = "rand-836 N=158";
        887: softmax_test_name = "rand-837 N=45";
        888: softmax_test_name = "rand-838 N=479";
        889: softmax_test_name = "rand-839 N=379";
        890: softmax_test_name = "rand-840 N=244";
        891: softmax_test_name = "rand-841 N=442";
        892: softmax_test_name = "rand-842 N=19";
        893: softmax_test_name = "rand-843 N=376";
        894: softmax_test_name = "rand-844 N=345";
        895: softmax_test_name = "rand-845 N=474";
        896: softmax_test_name = "rand-846 N=168";
        897: softmax_test_name = "rand-847 N=175";
        898: softmax_test_name = "rand-848 N=485";
        899: softmax_test_name = "rand-849 N=313";
        900: softmax_test_name = "rand-850 N=211";
        901: softmax_test_name = "rand-851 N=128";
        902: softmax_test_name = "rand-852 N=285";
        903: softmax_test_name = "rand-853 N=12";
        904: softmax_test_name = "rand-854 N=447";
        905: softmax_test_name = "rand-855 N=211";
        906: softmax_test_name = "rand-856 N=15";
        907: softmax_test_name = "rand-857 N=459";
        908: softmax_test_name = "rand-858 N=68";
        909: softmax_test_name = "rand-859 N=97";
        910: softmax_test_name = "rand-860 N=428";
        911: softmax_test_name = "rand-861 N=440";
        912: softmax_test_name = "rand-862 N=236";
        913: softmax_test_name = "rand-863 N=105";
        914: softmax_test_name = "rand-864 N= 3";
        915: softmax_test_name = "rand-865 N=41";
        916: softmax_test_name = "rand-866 N=164";
        917: softmax_test_name = "rand-867 N=93";
        918: softmax_test_name = "rand-868 N=29";
        919: softmax_test_name = "rand-869 N=299";
        920: softmax_test_name = "rand-870 N=189";
        921: softmax_test_name = "rand-871 N=136";
        922: softmax_test_name = "rand-872 N=133";
        923: softmax_test_name = "rand-873 N=478";
        924: softmax_test_name = "rand-874 N=62";
        925: softmax_test_name = "rand-875 N=107";
        926: softmax_test_name = "rand-876 N=390";
        927: softmax_test_name = "rand-877 N=67";
        928: softmax_test_name = "rand-878 N=188";
        929: softmax_test_name = "rand-879 N=145";
        930: softmax_test_name = "rand-880 N=415";
        931: softmax_test_name = "rand-881 N=233";
        932: softmax_test_name = "rand-882 N=108";
        933: softmax_test_name = "rand-883 N=159";
        934: softmax_test_name = "rand-884 N=373";
        935: softmax_test_name = "rand-885 N=488";
        936: softmax_test_name = "rand-886 N=331";
        937: softmax_test_name = "rand-887 N=370";
        938: softmax_test_name = "rand-888 N=67";
        939: softmax_test_name = "rand-889 N=433";
        940: softmax_test_name = "rand-890 N=472";
        941: softmax_test_name = "rand-891 N=27";
        942: softmax_test_name = "rand-892 N=364";
        943: softmax_test_name = "rand-893 N=313";
        944: softmax_test_name = "rand-894 N=75";
        945: softmax_test_name = "rand-895 N=216";
        946: softmax_test_name = "rand-896 N=486";
        947: softmax_test_name = "rand-897 N=204";
        948: softmax_test_name = "rand-898 N=126";
        949: softmax_test_name = "rand-899 N=127";
        950: softmax_test_name = "rand-900 N=218";
        951: softmax_test_name = "rand-901 N=153";
        952: softmax_test_name = "rand-902 N=139";
        953: softmax_test_name = "rand-903 N=67";
        954: softmax_test_name = "rand-904 N=233";
        955: softmax_test_name = "rand-905 N=135";
        956: softmax_test_name = "rand-906 N=192";
        957: softmax_test_name = "rand-907 N=226";
        958: softmax_test_name = "rand-908 N=423";
        959: softmax_test_name = "rand-909 N=419";
        960: softmax_test_name = "rand-910 N=320";
        961: softmax_test_name = "rand-911 N=282";
        962: softmax_test_name = "rand-912 N=337";
        963: softmax_test_name = "rand-913 N=300";
        964: softmax_test_name = "rand-914 N=291";
        965: softmax_test_name = "rand-915 N=331";
        966: softmax_test_name = "rand-916 N=353";
        967: softmax_test_name = "rand-917 N=428";
        968: softmax_test_name = "rand-918 N=449";
        969: softmax_test_name = "rand-919 N=255";
        970: softmax_test_name = "rand-920 N=492";
        971: softmax_test_name = "rand-921 N=148";
        972: softmax_test_name = "rand-922 N=199";
        973: softmax_test_name = "rand-923 N=432";
        974: softmax_test_name = "rand-924 N=71";
        975: softmax_test_name = "rand-925 N=89";
        976: softmax_test_name = "rand-926 N=124";
        977: softmax_test_name = "rand-927 N=234";
        978: softmax_test_name = "rand-928 N=30";
        979: softmax_test_name = "rand-929 N=104";
        980: softmax_test_name = "rand-930 N=262";
        981: softmax_test_name = "rand-931 N=474";
        982: softmax_test_name = "rand-932 N=109";
        983: softmax_test_name = "rand-933 N=187";
        984: softmax_test_name = "rand-934 N=243";
        985: softmax_test_name = "rand-935 N= 5";
        986: softmax_test_name = "rand-936 N=263";
        987: softmax_test_name = "rand-937 N=11";
        988: softmax_test_name = "rand-938 N=172";
        989: softmax_test_name = "rand-939 N=438";
        990: softmax_test_name = "rand-940 N=184";
        991: softmax_test_name = "rand-941 N=449";
        992: softmax_test_name = "rand-942 N=224";
        993: softmax_test_name = "rand-943 N=401";
        994: softmax_test_name = "rand-944 N=401";
        995: softmax_test_name = "rand-945 N=412";
        996: softmax_test_name = "rand-946 N=176";
        997: softmax_test_name = "rand-947 N=468";
        998: softmax_test_name = "rand-948 N=183";
        999: softmax_test_name = "rand-949 N=169";
        1000: softmax_test_name = "rand-950 N=357";
        1001: softmax_test_name = "rand-951 N=108";
        1002: softmax_test_name = "rand-952 N=273";
        1003: softmax_test_name = "rand-953 N=199";
        1004: softmax_test_name = "rand-954 N=41";
        1005: softmax_test_name = "rand-955 N=97";
        1006: softmax_test_name = "rand-956 N=177";
        1007: softmax_test_name = "rand-957 N=399";
        1008: softmax_test_name = "rand-958 N=443";
        1009: softmax_test_name = "rand-959 N=157";
        1010: softmax_test_name = "rand-960 N=348";
        1011: softmax_test_name = "rand-961 N=171";
        1012: softmax_test_name = "rand-962 N=407";
        1013: softmax_test_name = "rand-963 N=270";
        1014: softmax_test_name = "rand-964 N=31";
        1015: softmax_test_name = "rand-965 N=351";
        1016: softmax_test_name = "rand-966 N=255";
        1017: softmax_test_name = "rand-967 N=344";
        1018: softmax_test_name = "rand-968 N=40";
        1019: softmax_test_name = "rand-969 N=467";
        1020: softmax_test_name = "rand-970 N=318";
        1021: softmax_test_name = "rand-971 N=328";
        1022: softmax_test_name = "rand-972 N=359";
        1023: softmax_test_name = "rand-973 N=356";
        1024: softmax_test_name = "rand-974 N=419";
        1025: softmax_test_name = "rand-975 N=273";
        1026: softmax_test_name = "rand-976 N=233";
        1027: softmax_test_name = "rand-977 N=96";
        1028: softmax_test_name = "rand-978 N=55";
        1029: softmax_test_name = "rand-979 N=383";
        1030: softmax_test_name = "rand-980 N=180";
        1031: softmax_test_name = "rand-981 N=404";
        1032: softmax_test_name = "rand-982 N=345";
        1033: softmax_test_name = "rand-983 N=270";
        1034: softmax_test_name = "rand-984 N=33";
        1035: softmax_test_name = "rand-985 N=363";
        1036: softmax_test_name = "rand-986 N=18";
        1037: softmax_test_name = "rand-987 N=294";
        1038: softmax_test_name = "rand-988 N=184";
        1039: softmax_test_name = "rand-989 N=18";
        1040: softmax_test_name = "rand-990 N=284";
        1041: softmax_test_name = "rand-991 N=476";
        1042: softmax_test_name = "rand-992 N=21";
        1043: softmax_test_name = "rand-993 N=492";
        1044: softmax_test_name = "rand-994 N=379";
        1045: softmax_test_name = "rand-995 N=267";
        1046: softmax_test_name = "rand-996 N=305";
        1047: softmax_test_name = "rand-997 N=104";
        1048: softmax_test_name = "rand-998 N=264";
        1049: softmax_test_name = "rand-999 N=353";
        default: softmax_test_name = "<unknown>";
    endcase
end
endfunction
