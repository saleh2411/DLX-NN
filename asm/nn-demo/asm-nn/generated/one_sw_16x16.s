pc = 0x0                        * origin
* ================================================================
* one_sw_16x16.s  -  16x16 handwritten-digit MLP on DLX-NN
*   'tanh' variant of ../asm-nn
*   256 (16x16) -> 16 -> 10 ;  hidden = tanh ;  output = softmax ;  class = argmax
*   TARGET: baseline ISA only (software multiply + software tanh)
*   INPUT: user image "one.png", preprocessed to 16x16 (0..4)
*          and embedded below -- nothing else to load.
*   EXPECTED PRED = 1   (py-nn bit-exact Q16.16 model)
*   All values Q16.16; memory word-addressed (stride 1).
*
*   MEMORY MAP (word addresses -- read these in a RESA / FPGA mem dump):
*     IMG     @ 0x00000004 (dec     4)  256 words  <== INPUT: 16x16 image pixels (Q16.16 = pixel<<14)
*     PRED    @ 0x000011E2 (dec  4578)    1 word   <== OUTPUT: predicted digit 0-9, READ THIS
*     Z2      @ 0x000011CE (dec  4558)   10 words  output logits (Q16.16), pre-softmax
*     PROB    @ 0x000011D8 (dec  4568)   10 words  softmax probabilities (unused -- sw has no softmax stage)
*     W1DATA  @ 0x00000104 (dec   260)  4096 words  hidden-layer weights, row-major W1[h][i]
*     B1DATA  @ 0x00001104 (dec  4356)   16 words  hidden-layer biases
*     W2DATA  @ 0x00001114 (dec  4372)  160 words  output-layer weights, row-major W2[k][h]
*     B2DATA  @ 0x000011B4 (dec  4532)   10 words  output-layer biases
*     A1      @ 0x000011BE (dec  4542)   16 words  scratch: hidden activations
*
* ================================================================
start:   addi R1 R0 main        * jump over the data section
        jr   R1
        special-nop
        special-nop

* ----------------- DATA (word-addressed, stride 1) -----------------
* input: user image "one.png" (preprocessed, ink 0..4)
* raw 16x16 pixel grid (0..4):
*    0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
*    0  0  0  0  0  0  0  0  4  3  0  0  0  0  0  0
*    0  0  0  0  0  0  0  2  4  4  0  0  0  0  0  0
*    0  0  0  0  0  0  0  4  2  4  0  0  0  0  0  0
*    0  0  0  0  0  0  2  2  1  4  0  0  0  0  0  0
*    0  0  0  0  0  2  4  1  2  4  0  0  0  0  0  0
*    0  0  0  0  1  4  2  0  3  3  0  0  0  0  0  0
*    0  0  0  0  0  0  0  0  3  3  0  0  0  1  0  0
*    0  0  0  0  0  0  0  0  4  3  0  0  0  0  0  0
*    0  0  0  0  0  0  0  1  4  2  0  0  0  0  0  0
*    0  0  0  0  0  0  0  2  4  2  0  0  0  0  0  0
*    0  0  0  0  0  0  0  2  4  0  0  0  0  0  0  0
*    0  0  0  0  0  0  0  3  4  0  0  0  0  0  0  0
*    0  0  0  0  0  0  0  3  2  0  0  0  0  0  0  0
*    0  0  0  0  0  0  0  4  2  0  0  0  0  0  0  0
*    0  0  0  0  0  0  0  3  2  0  0  0  0  0  0  0
IMG:     dc 0x00000000    * pixel[0]=0  (Q16.16 = pixel<<14)
         dc 0x00000000    * pixel[1]=0
         dc 0x00000000    * pixel[2]=0
         dc 0x00000000    * pixel[3]=0
         dc 0x00000000    * pixel[4]=0
         dc 0x00000000    * pixel[5]=0
         dc 0x00000000    * pixel[6]=0
         dc 0x00000000    * pixel[7]=0
         dc 0x00000000    * pixel[8]=0
         dc 0x00000000    * pixel[9]=0
         dc 0x00000000    * pixel[10]=0
         dc 0x00000000    * pixel[11]=0
         dc 0x00000000    * pixel[12]=0
         dc 0x00000000    * pixel[13]=0
         dc 0x00000000    * pixel[14]=0
         dc 0x00000000    * pixel[15]=0
         dc 0x00000000    * pixel[16]=0
         dc 0x00000000    * pixel[17]=0
         dc 0x00000000    * pixel[18]=0
         dc 0x00000000    * pixel[19]=0
         dc 0x00000000    * pixel[20]=0
         dc 0x00000000    * pixel[21]=0
         dc 0x00000000    * pixel[22]=0
         dc 0x00000000    * pixel[23]=0
         dc 0x00010000    * pixel[24]=4
         dc 0x0000C000    * pixel[25]=3
         dc 0x00000000    * pixel[26]=0
         dc 0x00000000    * pixel[27]=0
         dc 0x00000000    * pixel[28]=0
         dc 0x00000000    * pixel[29]=0
         dc 0x00000000    * pixel[30]=0
         dc 0x00000000    * pixel[31]=0
         dc 0x00000000    * pixel[32]=0
         dc 0x00000000    * pixel[33]=0
         dc 0x00000000    * pixel[34]=0
         dc 0x00000000    * pixel[35]=0
         dc 0x00000000    * pixel[36]=0
         dc 0x00000000    * pixel[37]=0
         dc 0x00000000    * pixel[38]=0
         dc 0x00008000    * pixel[39]=2
         dc 0x00010000    * pixel[40]=4
         dc 0x00010000    * pixel[41]=4
         dc 0x00000000    * pixel[42]=0
         dc 0x00000000    * pixel[43]=0
         dc 0x00000000    * pixel[44]=0
         dc 0x00000000    * pixel[45]=0
         dc 0x00000000    * pixel[46]=0
         dc 0x00000000    * pixel[47]=0
         dc 0x00000000    * pixel[48]=0
         dc 0x00000000    * pixel[49]=0
         dc 0x00000000    * pixel[50]=0
         dc 0x00000000    * pixel[51]=0
         dc 0x00000000    * pixel[52]=0
         dc 0x00000000    * pixel[53]=0
         dc 0x00000000    * pixel[54]=0
         dc 0x00010000    * pixel[55]=4
         dc 0x00008000    * pixel[56]=2
         dc 0x00010000    * pixel[57]=4
         dc 0x00000000    * pixel[58]=0
         dc 0x00000000    * pixel[59]=0
         dc 0x00000000    * pixel[60]=0
         dc 0x00000000    * pixel[61]=0
         dc 0x00000000    * pixel[62]=0
         dc 0x00000000    * pixel[63]=0
         dc 0x00000000    * pixel[64]=0
         dc 0x00000000    * pixel[65]=0
         dc 0x00000000    * pixel[66]=0
         dc 0x00000000    * pixel[67]=0
         dc 0x00000000    * pixel[68]=0
         dc 0x00000000    * pixel[69]=0
         dc 0x00008000    * pixel[70]=2
         dc 0x00008000    * pixel[71]=2
         dc 0x00004000    * pixel[72]=1
         dc 0x00010000    * pixel[73]=4
         dc 0x00000000    * pixel[74]=0
         dc 0x00000000    * pixel[75]=0
         dc 0x00000000    * pixel[76]=0
         dc 0x00000000    * pixel[77]=0
         dc 0x00000000    * pixel[78]=0
         dc 0x00000000    * pixel[79]=0
         dc 0x00000000    * pixel[80]=0
         dc 0x00000000    * pixel[81]=0
         dc 0x00000000    * pixel[82]=0
         dc 0x00000000    * pixel[83]=0
         dc 0x00000000    * pixel[84]=0
         dc 0x00008000    * pixel[85]=2
         dc 0x00010000    * pixel[86]=4
         dc 0x00004000    * pixel[87]=1
         dc 0x00008000    * pixel[88]=2
         dc 0x00010000    * pixel[89]=4
         dc 0x00000000    * pixel[90]=0
         dc 0x00000000    * pixel[91]=0
         dc 0x00000000    * pixel[92]=0
         dc 0x00000000    * pixel[93]=0
         dc 0x00000000    * pixel[94]=0
         dc 0x00000000    * pixel[95]=0
         dc 0x00000000    * pixel[96]=0
         dc 0x00000000    * pixel[97]=0
         dc 0x00000000    * pixel[98]=0
         dc 0x00000000    * pixel[99]=0
         dc 0x00004000    * pixel[100]=1
         dc 0x00010000    * pixel[101]=4
         dc 0x00008000    * pixel[102]=2
         dc 0x00000000    * pixel[103]=0
         dc 0x0000C000    * pixel[104]=3
         dc 0x0000C000    * pixel[105]=3
         dc 0x00000000    * pixel[106]=0
         dc 0x00000000    * pixel[107]=0
         dc 0x00000000    * pixel[108]=0
         dc 0x00000000    * pixel[109]=0
         dc 0x00000000    * pixel[110]=0
         dc 0x00000000    * pixel[111]=0
         dc 0x00000000    * pixel[112]=0
         dc 0x00000000    * pixel[113]=0
         dc 0x00000000    * pixel[114]=0
         dc 0x00000000    * pixel[115]=0
         dc 0x00000000    * pixel[116]=0
         dc 0x00000000    * pixel[117]=0
         dc 0x00000000    * pixel[118]=0
         dc 0x00000000    * pixel[119]=0
         dc 0x0000C000    * pixel[120]=3
         dc 0x0000C000    * pixel[121]=3
         dc 0x00000000    * pixel[122]=0
         dc 0x00000000    * pixel[123]=0
         dc 0x00000000    * pixel[124]=0
         dc 0x00004000    * pixel[125]=1
         dc 0x00000000    * pixel[126]=0
         dc 0x00000000    * pixel[127]=0
         dc 0x00000000    * pixel[128]=0
         dc 0x00000000    * pixel[129]=0
         dc 0x00000000    * pixel[130]=0
         dc 0x00000000    * pixel[131]=0
         dc 0x00000000    * pixel[132]=0
         dc 0x00000000    * pixel[133]=0
         dc 0x00000000    * pixel[134]=0
         dc 0x00000000    * pixel[135]=0
         dc 0x00010000    * pixel[136]=4
         dc 0x0000C000    * pixel[137]=3
         dc 0x00000000    * pixel[138]=0
         dc 0x00000000    * pixel[139]=0
         dc 0x00000000    * pixel[140]=0
         dc 0x00000000    * pixel[141]=0
         dc 0x00000000    * pixel[142]=0
         dc 0x00000000    * pixel[143]=0
         dc 0x00000000    * pixel[144]=0
         dc 0x00000000    * pixel[145]=0
         dc 0x00000000    * pixel[146]=0
         dc 0x00000000    * pixel[147]=0
         dc 0x00000000    * pixel[148]=0
         dc 0x00000000    * pixel[149]=0
         dc 0x00000000    * pixel[150]=0
         dc 0x00004000    * pixel[151]=1
         dc 0x00010000    * pixel[152]=4
         dc 0x00008000    * pixel[153]=2
         dc 0x00000000    * pixel[154]=0
         dc 0x00000000    * pixel[155]=0
         dc 0x00000000    * pixel[156]=0
         dc 0x00000000    * pixel[157]=0
         dc 0x00000000    * pixel[158]=0
         dc 0x00000000    * pixel[159]=0
         dc 0x00000000    * pixel[160]=0
         dc 0x00000000    * pixel[161]=0
         dc 0x00000000    * pixel[162]=0
         dc 0x00000000    * pixel[163]=0
         dc 0x00000000    * pixel[164]=0
         dc 0x00000000    * pixel[165]=0
         dc 0x00000000    * pixel[166]=0
         dc 0x00008000    * pixel[167]=2
         dc 0x00010000    * pixel[168]=4
         dc 0x00008000    * pixel[169]=2
         dc 0x00000000    * pixel[170]=0
         dc 0x00000000    * pixel[171]=0
         dc 0x00000000    * pixel[172]=0
         dc 0x00000000    * pixel[173]=0
         dc 0x00000000    * pixel[174]=0
         dc 0x00000000    * pixel[175]=0
         dc 0x00000000    * pixel[176]=0
         dc 0x00000000    * pixel[177]=0
         dc 0x00000000    * pixel[178]=0
         dc 0x00000000    * pixel[179]=0
         dc 0x00000000    * pixel[180]=0
         dc 0x00000000    * pixel[181]=0
         dc 0x00000000    * pixel[182]=0
         dc 0x00008000    * pixel[183]=2
         dc 0x00010000    * pixel[184]=4
         dc 0x00000000    * pixel[185]=0
         dc 0x00000000    * pixel[186]=0
         dc 0x00000000    * pixel[187]=0
         dc 0x00000000    * pixel[188]=0
         dc 0x00000000    * pixel[189]=0
         dc 0x00000000    * pixel[190]=0
         dc 0x00000000    * pixel[191]=0
         dc 0x00000000    * pixel[192]=0
         dc 0x00000000    * pixel[193]=0
         dc 0x00000000    * pixel[194]=0
         dc 0x00000000    * pixel[195]=0
         dc 0x00000000    * pixel[196]=0
         dc 0x00000000    * pixel[197]=0
         dc 0x00000000    * pixel[198]=0
         dc 0x0000C000    * pixel[199]=3
         dc 0x00010000    * pixel[200]=4
         dc 0x00000000    * pixel[201]=0
         dc 0x00000000    * pixel[202]=0
         dc 0x00000000    * pixel[203]=0
         dc 0x00000000    * pixel[204]=0
         dc 0x00000000    * pixel[205]=0
         dc 0x00000000    * pixel[206]=0
         dc 0x00000000    * pixel[207]=0
         dc 0x00000000    * pixel[208]=0
         dc 0x00000000    * pixel[209]=0
         dc 0x00000000    * pixel[210]=0
         dc 0x00000000    * pixel[211]=0
         dc 0x00000000    * pixel[212]=0
         dc 0x00000000    * pixel[213]=0
         dc 0x00000000    * pixel[214]=0
         dc 0x0000C000    * pixel[215]=3
         dc 0x00008000    * pixel[216]=2
         dc 0x00000000    * pixel[217]=0
         dc 0x00000000    * pixel[218]=0
         dc 0x00000000    * pixel[219]=0
         dc 0x00000000    * pixel[220]=0
         dc 0x00000000    * pixel[221]=0
         dc 0x00000000    * pixel[222]=0
         dc 0x00000000    * pixel[223]=0
         dc 0x00000000    * pixel[224]=0
         dc 0x00000000    * pixel[225]=0
         dc 0x00000000    * pixel[226]=0
         dc 0x00000000    * pixel[227]=0
         dc 0x00000000    * pixel[228]=0
         dc 0x00000000    * pixel[229]=0
         dc 0x00000000    * pixel[230]=0
         dc 0x00010000    * pixel[231]=4
         dc 0x00008000    * pixel[232]=2
         dc 0x00000000    * pixel[233]=0
         dc 0x00000000    * pixel[234]=0
         dc 0x00000000    * pixel[235]=0
         dc 0x00000000    * pixel[236]=0
         dc 0x00000000    * pixel[237]=0
         dc 0x00000000    * pixel[238]=0
         dc 0x00000000    * pixel[239]=0
         dc 0x00000000    * pixel[240]=0
         dc 0x00000000    * pixel[241]=0
         dc 0x00000000    * pixel[242]=0
         dc 0x00000000    * pixel[243]=0
         dc 0x00000000    * pixel[244]=0
         dc 0x00000000    * pixel[245]=0
         dc 0x00000000    * pixel[246]=0
         dc 0x0000C000    * pixel[247]=3
         dc 0x00008000    * pixel[248]=2
         dc 0x00000000    * pixel[249]=0
         dc 0x00000000    * pixel[250]=0
         dc 0x00000000    * pixel[251]=0
         dc 0x00000000    * pixel[252]=0
         dc 0x00000000    * pixel[253]=0
         dc 0x00000000    * pixel[254]=0
         dc 0x00000000    * pixel[255]=0
W1DATA:  dc 0x00000203    * W1[0][0]  (16x256 row-major)
         dc 0xFFFFFDE3
         dc 0x00000A40
         dc 0x0000173E
         dc 0xFFFFA9C6
         dc 0xFFFF9DAC
         dc 0xFFFFE92E
         dc 0x000017E8
         dc 0xFFFFF1B4
         dc 0xFFFF828B
         dc 0xFFFFCD0C
         dc 0x00001E86
         dc 0xFFFFEBBE
         dc 0xFFFFED17
         dc 0xFFFFD78B
         dc 0xFFFFEE50
         dc 0xFFFFF74B
         dc 0xFFFFFAF0
         dc 0x0000042F
         dc 0x00001CD1
         dc 0xFFFFD2CF
         dc 0x000001E9
         dc 0x000034CD
         dc 0x00003322
         dc 0x00000C44
         dc 0x00001F2B
         dc 0x00003F35
         dc 0x00003F28
         dc 0x00000956
         dc 0xFFFFC963
         dc 0xFFFFD4EB
         dc 0xFFFFF121
         dc 0xFFFFFD74
         dc 0x000008B1
         dc 0xFFFFFA9F
         dc 0x00000CAC
         dc 0xFFFFDA28
         dc 0xFFFFF6F1
         dc 0x000010F8
         dc 0xFFFFF20E
         dc 0xFFFF93F4
         dc 0x00002919
         dc 0x00007738
         dc 0x00000A14
         dc 0x00000A98
         dc 0xFFFF8E4B
         dc 0xFFFFEBBB
         dc 0x00001709
         dc 0x00001CD3
         dc 0x00001563
         dc 0x00000615
         dc 0x00002829
         dc 0xFFFFF8F9
         dc 0x0000317C
         dc 0xFFFFBC30
         dc 0xFFFFCD24
         dc 0xFFFFEA10
         dc 0x00006B36
         dc 0x000002AA
         dc 0x00001BA2
         dc 0xFFFFE2E7
         dc 0xFFFFC94C
         dc 0x00000FB1
         dc 0xFFFFF6A0
         dc 0x00000543
         dc 0xFFFFFBF6
         dc 0x00002A1B
         dc 0x00009562
         dc 0x00002355
         dc 0x0000007B
         dc 0xFFFFF4CF
         dc 0x00006127
         dc 0x00008211
         dc 0x000009EE
         dc 0x00003AF3
         dc 0xFFFFE13B
         dc 0x000040C1
         dc 0x000016D4
         dc 0xFFFFFF5B
         dc 0x0000200A
         dc 0x00000304
         dc 0xFFFFF675
         dc 0x00002A67
         dc 0x0000313B
         dc 0x00000531
         dc 0x0000304B
         dc 0x000017A0
         dc 0x00005AA1
         dc 0x0000527C
         dc 0x000036B0
         dc 0x00002304
         dc 0x000009D6
         dc 0xFFFFF907
         dc 0xFFFFEFB3
         dc 0x000004F2
         dc 0x00001081
         dc 0x00000293
         dc 0xFFFFF6CB
         dc 0xFFFFDEF6
         dc 0x0000228A
         dc 0xFFFFF64C
         dc 0x00002E41
         dc 0x00000C56
         dc 0x000020EF
         dc 0x00002736
         dc 0x0000335D
         dc 0x00004FA8
         dc 0x000006A5
         dc 0xFFFFD409
         dc 0xFFFFA8C7
         dc 0xFFFFF64F
         dc 0x000001C0
         dc 0xFFFFFECA
         dc 0x0000033C
         dc 0xFFFFFC73
         dc 0xFFFFB73F
         dc 0xFFFF8447
         dc 0xFFFFC028
         dc 0x00001C28
         dc 0x00001929
         dc 0x0000593F
         dc 0x00002652
         dc 0x000033C2
         dc 0xFFFFE5B4
         dc 0xFFFF4D90
         dc 0xFFFFA81A
         dc 0xFFFFE93C
         dc 0x00000423
         dc 0xFFFFF6E7
         dc 0xFFFFEF86
         dc 0xFFFFE6F7
         dc 0xFFFFB039
         dc 0xFFFF9208
         dc 0xFFFFD07A
         dc 0x0000032D
         dc 0xFFFFFE80
         dc 0x00001872
         dc 0xFFFFD538
         dc 0xFFFFCD72
         dc 0xFFFFDE82
         dc 0xFFFF1CDA
         dc 0xFFFFE0E7
         dc 0x000005F1
         dc 0x00000620
         dc 0x0000051C
         dc 0xFFFFFA41
         dc 0xFFFFCB40
         dc 0xFFFFC624
         dc 0xFFFF808B
         dc 0xFFFFFEB9
         dc 0x00000799
         dc 0xFFFFF4A0
         dc 0xFFFFDE58
         dc 0xFFFFA406
         dc 0xFFFFBDCA
         dc 0xFFFFA19F
         dc 0xFFFF65CB
         dc 0xFFFFD5B5
         dc 0xFFFFED07
         dc 0xFFFFD9A1
         dc 0x00000835
         dc 0xFFFFFAAA
         dc 0xFFFFD880
         dc 0xFFFFBA1D
         dc 0xFFFFD547
         dc 0xFFFFC151
         dc 0x000019A6
         dc 0x00001317
         dc 0xFFFFB5DC
         dc 0xFFFFD6E0
         dc 0xFFFFDA88
         dc 0xFFFFE162
         dc 0xFFFFCD0E
         dc 0xFFFFEBC4
         dc 0x000008F2
         dc 0xFFFFFD91
         dc 0xFFFFE86B
         dc 0x00000854
         dc 0xFFFFB377
         dc 0xFFFFBAAA
         dc 0xFFFFE6BD
         dc 0xFFFFD44F
         dc 0xFFFF9F78
         dc 0x00000ED5
         dc 0xFFFFCF9B
         dc 0x00004EBD
         dc 0xFFFFFEA6
         dc 0xFFFFEEDD
         dc 0x000004E9
         dc 0xFFFFD8E2
         dc 0xFFFFDA0E
         dc 0xFFFFEB13
         dc 0x00001163
         dc 0xFFFFFCB8
         dc 0xFFFFA4A7
         dc 0x00001FA7
         dc 0x00004A24
         dc 0xFFFFDEBB
         dc 0xFFFFA6F7
         dc 0xFFFFCE57
         dc 0x00000F57
         dc 0x00004BF4
         dc 0xFFFFEE74
         dc 0xFFFFE78E
         dc 0xFFFFF637
         dc 0xFFFFF422
         dc 0xFFFFFE02
         dc 0xFFFFEB59
         dc 0xFFFFF873
         dc 0x00000ED2
         dc 0xFFFFEA20
         dc 0x00006622
         dc 0x00002940
         dc 0xFFFFF91F
         dc 0xFFFFA2C3
         dc 0xFFFFBB55
         dc 0x0000574C
         dc 0x0000318D
         dc 0xFFFFF3D6
         dc 0x00005FAB
         dc 0x00000752
         dc 0xFFFFE49D
         dc 0x00000725
         dc 0x00000A64
         dc 0xFFFFF800
         dc 0x000015F0
         dc 0x00000E35
         dc 0x00005149
         dc 0x00000E87
         dc 0x000033B6
         dc 0x000015A8
         dc 0x00007418
         dc 0x00006112
         dc 0x0000727E
         dc 0x0000251F
         dc 0x000050E2
         dc 0x000044F1
         dc 0x0000339B
         dc 0x00000B95
         dc 0xFFFFEE43
         dc 0x000014C0
         dc 0xFFFFFA78
         dc 0x00000DAC
         dc 0xFFFFEA1E
         dc 0xFFFF9CB1
         dc 0xFFFF7685
         dc 0xFFFFDE66
         dc 0x0000B051
         dc 0xFFFFCB1E
         dc 0xFFFFBFD2
         dc 0x0000002B
         dc 0x0000463E
         dc 0x0000378A
         dc 0x000018AF
         dc 0x00003025
         dc 0x000010BA
         dc 0xFFFFF551    * W1[1][0]
         dc 0x0000029D
         dc 0xFFFFF2B5
         dc 0x00001B5A
         dc 0xFFFFE598
         dc 0xFFFF7970
         dc 0x00001565
         dc 0x0000494D
         dc 0xFFFFD062
         dc 0xFFFFA98F
         dc 0xFFFFCE52
         dc 0xFFFF6636
         dc 0xFFFF7059
         dc 0xFFFFDA30
         dc 0x00002D50
         dc 0x00001349
         dc 0xFFFFF37F
         dc 0xFFFFEA9A
         dc 0xFFFFEF19
         dc 0xFFFFF9F7
         dc 0xFFFFAA31
         dc 0xFFFFAA61
         dc 0xFFFF7755
         dc 0xFFFFF165
         dc 0xFFFFBD64
         dc 0xFFFF79E9
         dc 0xFFFFD3AF
         dc 0xFFFFB8CD
         dc 0xFFFF536C
         dc 0xFFFFAF9E
         dc 0x000009E6
         dc 0xFFFFF243
         dc 0xFFFFF5C1
         dc 0x00000BA1
         dc 0xFFFFD416
         dc 0xFFFFA020
         dc 0xFFFF6997
         dc 0xFFFF2C4A
         dc 0xFFFF4DC9
         dc 0xFFFF5EB1
         dc 0xFFFEEAF7
         dc 0xFFFFAAE7
         dc 0xFFFF9A98
         dc 0xFFFFA2CA
         dc 0x000024E0
         dc 0xFFFFC1B0
         dc 0x00002F75
         dc 0xFFFFC14A
         dc 0x0000042C
         dc 0xFFFFFF86
         dc 0xFFFFDC99
         dc 0xFFFFDF22
         dc 0x00000AE6
         dc 0xFFFFED2F
         dc 0xFFFFC1D9
         dc 0xFFFFC5B6
         dc 0xFFFFF37D
         dc 0xFFFF97E4
         dc 0x000025D4
         dc 0x00002B79
         dc 0x000019B4
         dc 0xFFFFDC22
         dc 0xFFFFF59B
         dc 0x00000AB6
         dc 0x00000591
         dc 0xFFFFFD64
         dc 0xFFFFC34C
         dc 0xFFFFE3B2
         dc 0x00005C25
         dc 0x00000AC4
         dc 0x00004DA6
         dc 0x00009095
         dc 0x0000688D
         dc 0xFFFFDA75
         dc 0x000036BC
         dc 0x00005CC8
         dc 0xFFFFEF7B
         dc 0xFFFFD25A
         dc 0xFFFFF4E7
         dc 0xFFFFFA8E
         dc 0x00000520
         dc 0xFFFFEF95
         dc 0x0000378E
         dc 0x000098C1
         dc 0x000060A4
         dc 0x00007281
         dc 0x00008523
         dc 0xFFFFDE03
         dc 0xFFFFC64D
         dc 0xFFFFD5CF
         dc 0x00001FD7
         dc 0x0000321B
         dc 0xFFFFBED5
         dc 0xFFFFFB52
         dc 0xFFFFE6B7
         dc 0x0000206E
         dc 0xFFFFF9AE
         dc 0xFFFFF38B
         dc 0x00001D46
         dc 0x00004E17
         dc 0xFFFFC104
         dc 0x000002E8
         dc 0x00004A3E
         dc 0x0000516C
         dc 0x0000341A
         dc 0x0000272C
         dc 0x00000FD5
         dc 0xFFFFFD0B
         dc 0xFFFFED32
         dc 0x00004A56
         dc 0x00000250
         dc 0xFFFFF5A2
         dc 0xFFFFF3C3
         dc 0x00000CFB
         dc 0x00000DD6
         dc 0xFFFFFF4E
         dc 0xFFFFF8C6
         dc 0xFFFFDCCB
         dc 0x0000352E
         dc 0x00003425
         dc 0xFFFFED27
         dc 0xFFFFF221
         dc 0xFFFFD590
         dc 0xFFFFE1DB
         dc 0x0000501E
         dc 0x00002229
         dc 0xFFFFF223
         dc 0x000001F6
         dc 0xFFFFF343
         dc 0xFFFFF834
         dc 0x00000133
         dc 0xFFFFFADB
         dc 0x00000565
         dc 0x0000283E
         dc 0x00004C2D
         dc 0x00002624
         dc 0x00001378
         dc 0xFFFFC0C8
         dc 0x00002359
         dc 0xFFFFC35A
         dc 0x000016B0
         dc 0xFFFFD3E2
         dc 0x000005CD
         dc 0x0000071B
         dc 0xFFFFFA3C
         dc 0x00000957
         dc 0xFFFFD956
         dc 0xFFFFFF9E
         dc 0x000043E7
         dc 0x00002A15
         dc 0xFFFFB4C7
         dc 0x00001EE1
         dc 0x000011B7
         dc 0x000031BA
         dc 0xFFFFFA6D
         dc 0xFFFFF25E
         dc 0xFFFFCB74
         dc 0xFFFFD0B9
         dc 0xFFFFF3D7
         dc 0x000002F0
         dc 0xFFFFF8F4
         dc 0x00000C53
         dc 0x000002AD
         dc 0x0000352D
         dc 0x0000AF0B
         dc 0x0000DF13
         dc 0x0000A0A3
         dc 0x00003CE0
         dc 0x00007593
         dc 0x000040A6
         dc 0x000009C2
         dc 0xFFFFFD8E
         dc 0xFFFFFA6D
         dc 0xFFFFF7BB
         dc 0x00001FA3
         dc 0xFFFFF1A8
         dc 0x00000F45
         dc 0x00000907
         dc 0xFFFFF12E
         dc 0x000042E7
         dc 0x0000BB9A
         dc 0x0000D32D
         dc 0x0000A8FF
         dc 0x000066F7
         dc 0x00008658
         dc 0x0000469B
         dc 0x000081E3
         dc 0x00004951
         dc 0x00003206
         dc 0x0000608C
         dc 0xFFFFF2DC
         dc 0x000001B4
         dc 0x00000902
         dc 0xFFFFFCE3
         dc 0xFFFFFDD9
         dc 0x000020A0
         dc 0x0000513E
         dc 0x00006F6E
         dc 0xFFFFD2A7
         dc 0x0000039B
         dc 0x0000403D
         dc 0x000038D8
         dc 0x0000371C
         dc 0x00004C4B
         dc 0xFFFFFA7F
         dc 0x00003444
         dc 0xFFFFF837
         dc 0x00001257
         dc 0x00001117
         dc 0x00000368
         dc 0xFFFFE86F
         dc 0x0000104E
         dc 0x00000D92
         dc 0xFFFFF486
         dc 0xFFFF7502
         dc 0xFFFFE2C6
         dc 0x000020A1
         dc 0x0000021E
         dc 0xFFFFE418
         dc 0x000048A6
         dc 0xFFFFC856
         dc 0x00000A2E
         dc 0xFFFFD04F
         dc 0x00000F56
         dc 0x000008C1
         dc 0x00001B44
         dc 0xFFFFF5E4
         dc 0xFFFFFB24
         dc 0xFFFFD366
         dc 0xFFFFFFEC
         dc 0xFFFFCD42
         dc 0x0000187E
         dc 0x00004304
         dc 0x00002A08
         dc 0xFFFFF2F9
         dc 0x0000282D
         dc 0xFFFFB24D
         dc 0xFFFFFC67
         dc 0x000025CB
         dc 0xFFFFFBC3
         dc 0xFFFFFC95
         dc 0x00000AA4
         dc 0xFFFFEA95
         dc 0xFFFFE6E3
         dc 0xFFFFF3A1
         dc 0xFFFFE3CF
         dc 0xFFFFB269
         dc 0xFFFFCD38
         dc 0x00001989
         dc 0x00006A10
         dc 0x00004C5E
         dc 0xFFFFD8FD
         dc 0xFFFFE977
         dc 0xFFFFF18A
         dc 0x0000213A
         dc 0x000016DF
         dc 0xFFFFF74C    * W1[2][0]
         dc 0xFFFFFDDD
         dc 0x000014D2
         dc 0xFFFFDE94
         dc 0xFFFFF5E0
         dc 0x00005376
         dc 0x000025DC
         dc 0x000075B7
         dc 0xFFFFFB9B
         dc 0x00006C9F
         dc 0x0000676C
         dc 0xFFFFE28D
         dc 0xFFFFFBA0
         dc 0x00001453
         dc 0x00001F91
         dc 0x0000039E
         dc 0xFFFFFE5C
         dc 0x00001730
         dc 0x00000DFD
         dc 0x00001C0F
         dc 0x0000353F
         dc 0x00000EB9
         dc 0x000070D9
         dc 0x0000A21F
         dc 0x00003F2C
         dc 0xFFFFF901
         dc 0xFFFFD137
         dc 0xFFFFDA14
         dc 0x00000965
         dc 0x00003842
         dc 0x00002CCB
         dc 0x000003D0
         dc 0x00000CE5
         dc 0xFFFFF094
         dc 0x00000FAC
         dc 0x00000478
         dc 0x00003C18
         dc 0x000089D7
         dc 0x000092BD
         dc 0x00003BF9
         dc 0x00007845
         dc 0x00004ABF
         dc 0xFFFFDD8F
         dc 0x00000844
         dc 0xFFFFF618
         dc 0xFFFFF16A
         dc 0x000036A2
         dc 0xFFFFFFB7
         dc 0xFFFFF25D
         dc 0xFFFFFC64
         dc 0xFFFFEE96
         dc 0x000029DD
         dc 0x0000AB64
         dc 0x00004A0A
         dc 0x00000857
         dc 0xFFFFAA40
         dc 0xFFFFB6E4
         dc 0xFFFFA9EE
         dc 0x000052C4
         dc 0x00006D89
         dc 0x00003430
         dc 0xFFFFF5E1
         dc 0x00001782
         dc 0x000013E0
         dc 0xFFFFFCDD
         dc 0xFFFFEBDA
         dc 0x000012EB
         dc 0x000056E2
         dc 0x0000080A
         dc 0x0000252E
         dc 0x0000046A
         dc 0xFFFFA6E8
         dc 0xFFFF498F
         dc 0x00000289
         dc 0x00008BF3
         dc 0x0000723F
         dc 0xFFFFC712
         dc 0x00002550
         dc 0x00000028
         dc 0xFFFFF71F
         dc 0x00000095
         dc 0xFFFFEAAF
         dc 0xFFFFC8B0
         dc 0x00001DAF
         dc 0xFFFFDC9E
         dc 0xFFFFD58C
         dc 0x0000289C
         dc 0xFFFFC5D5
         dc 0xFFFFEF9E
         dc 0x00003A1B
         dc 0x00007F6A
         dc 0x000079C4
         dc 0x000021DA
         dc 0x0000157D
         dc 0x000006FD
         dc 0x00000C87
         dc 0xFFFFEA83
         dc 0xFFFFF735
         dc 0xFFFFF132
         dc 0x00006752
         dc 0xFFFFC02E
         dc 0x00001EB5
         dc 0x000039B6
         dc 0xFFFFF9A5
         dc 0xFFFFC5B5
         dc 0x00001099
         dc 0x00000D9F
         dc 0x000037DA
         dc 0x000038EF
         dc 0x00001DEB
         dc 0x00000E5D
         dc 0x00000E87
         dc 0xFFFFF4ED
         dc 0xFFFFE4D5
         dc 0xFFFFE69A
         dc 0x0000022C
         dc 0xFFFFB5B5
         dc 0x00004842
         dc 0x00005876
         dc 0x00001B96
         dc 0xFFFFFD9C
         dc 0x00002132
         dc 0x000016E1
         dc 0xFFFFC583
         dc 0x00004552
         dc 0x000021A5
         dc 0x000013AC
         dc 0xFFFFFEF9
         dc 0xFFFFF743
         dc 0x0000050A
         dc 0xFFFFFCC4
         dc 0xFFFFA908
         dc 0xFFFFABC4
         dc 0x00004D52
         dc 0x00007388
         dc 0xFFFFDB23
         dc 0xFFFFD323
         dc 0xFFFFD61A
         dc 0xFFFF6BFF
         dc 0xFFFFC1F7
         dc 0x00001BF9
         dc 0x00005421
         dc 0x00000FA0
         dc 0xFFFFFA51
         dc 0x00000BF8
         dc 0xFFFFF4F6
         dc 0xFFFFF365
         dc 0x00003825
         dc 0xFFFFFDF3
         dc 0x000035CB
         dc 0x00003479
         dc 0x00001C60
         dc 0x0000184B
         dc 0x0000332A
         dc 0xFFFFB337
         dc 0xFFFFE8D1
         dc 0x00002D4C
         dc 0xFFFFFD03
         dc 0xFFFFFD97
         dc 0x0000023F
         dc 0x0000054C
         dc 0xFFFFEC3D
         dc 0xFFFFF153
         dc 0x0000272A
         dc 0xFFFFBCC3
         dc 0x0000011A
         dc 0xFFFFB03B
         dc 0xFFFFAB8B
         dc 0x0000287F
         dc 0xFFFFAEAA
         dc 0x00005563
         dc 0x0000405B
         dc 0x00000DCA
         dc 0xFFFFD22A
         dc 0x000015D2
         dc 0x00000586
         dc 0x000007B3
         dc 0x00000852
         dc 0xFFFFE890
         dc 0xFFFFF21A
         dc 0xFFFF9FAA
         dc 0xFFFFBADC
         dc 0xFFFFBAC5
         dc 0xFFFF1DDE
         dc 0xFFFF8AD0
         dc 0x00001552
         dc 0x0000477F
         dc 0x00001E3A
         dc 0x00001BB9
         dc 0xFFFFA4A0
         dc 0xFFFFD190
         dc 0xFFFFFAFD
         dc 0x0000024E
         dc 0x000006B4
         dc 0xFFFFECF5
         dc 0xFFFFE21C
         dc 0x00008B0F
         dc 0xFFFFFCFE
         dc 0xFFFF9085
         dc 0xFFFF30B2
         dc 0xFFFF395E
         dc 0xFFFFDDAB
         dc 0xFFFFF548
         dc 0x0000118B
         dc 0xFFFFF774
         dc 0xFFFFD4AF
         dc 0xFFFFFF16
         dc 0x00000EAD
         dc 0x0000070E
         dc 0x00000519
         dc 0xFFFFDF01
         dc 0xFFFFA443
         dc 0x000022F0
         dc 0xFFFFAEC4
         dc 0xFFFFD95A
         dc 0xFFFFE732
         dc 0xFFFFA504
         dc 0xFFFF9D79
         dc 0xFFFFC8AD
         dc 0xFFFF95AF
         dc 0xFFFF59DF
         dc 0x00000FEF
         dc 0xFFFFBECC
         dc 0xFFFFFB56
         dc 0xFFFFE88B
         dc 0xFFFFF6B5
         dc 0xFFFFE321
         dc 0xFFFF9EB4
         dc 0xFFFFBBFD
         dc 0x00001812
         dc 0x000034A3
         dc 0x00001C59
         dc 0xFFFFBAF7
         dc 0xFFFFA893
         dc 0xFFFFDF55
         dc 0xFFFF6254
         dc 0xFFFFAD4A
         dc 0xFFFFDCF1
         dc 0xFFFFB3D1
         dc 0x00000331
         dc 0x00001602
         dc 0xFFFFE2F6
         dc 0x00001BD7
         dc 0x00000361
         dc 0x000013BA
         dc 0x00001B0B
         dc 0xFFFFE61C
         dc 0xFFFFD2A5
         dc 0xFFFFE838
         dc 0xFFFFF438
         dc 0xFFFFBAA4
         dc 0xFFFFBBAB
         dc 0xFFFFE87C
         dc 0xFFFFBC45
         dc 0xFFFFBEC0
         dc 0xFFFFEBF0
         dc 0xFFFFF3E9    * W1[3][0]
         dc 0x00000880
         dc 0x00000BD0
         dc 0x000008ED
         dc 0xFFFFA9F8
         dc 0x000009BD
         dc 0x00007727
         dc 0xFFFFDAB7
         dc 0xFFFFEA78
         dc 0xFFFFCCFF
         dc 0x000023B7
         dc 0x00007850
         dc 0xFFFFFA57
         dc 0xFFFFBEB0
         dc 0xFFFFCD31
         dc 0x000013F0
         dc 0xFFFFFD30
         dc 0xFFFFFA0C
         dc 0xFFFFDD37
         dc 0xFFFFF26A
         dc 0xFFFFCBEA
         dc 0x00003E66
         dc 0x000045F2
         dc 0x00000AFC
         dc 0x000027F3
         dc 0x000061E7
         dc 0x00005F91
         dc 0x000042CA
         dc 0xFFFFF9AD
         dc 0xFFFFC3C1
         dc 0xFFFFA446
         dc 0xFFFFF63E
         dc 0xFFFFF439
         dc 0xFFFFD7BD
         dc 0xFFFFCCD3
         dc 0x00001233
         dc 0xFFFFD50C
         dc 0x000013A2
         dc 0xFFFFE970
         dc 0xFFFFFD8E
         dc 0x00000FB4
         dc 0x00003C15
         dc 0x00006FBC
         dc 0x0000468B
         dc 0x00000F1B
         dc 0xFFFFDBAD
         dc 0xFFFFD6F9
         dc 0xFFFFF255
         dc 0x000003C1
         dc 0xFFFFD18B
         dc 0xFFFFF5AC
         dc 0xFFFFCCFD
         dc 0xFFFFCDFF
         dc 0x0000320B
         dc 0xFFFF9E5F
         dc 0x00004560
         dc 0x0000A4E5
         dc 0x00004E75
         dc 0xFFFFF02B
         dc 0x0000120F
         dc 0xFFFFC2DE
         dc 0xFFFFA91F
         dc 0xFFFFE497
         dc 0x00000CAD
         dc 0xFFFFF190
         dc 0x00000327
         dc 0x00000F6D
         dc 0xFFFFE26A
         dc 0xFFFF934B
         dc 0xFFFFD054
         dc 0xFFFFF2C9
         dc 0x00009DB0
         dc 0x000093E3
         dc 0x00000825
         dc 0xFFFFE63C
         dc 0xFFFFCF65
         dc 0xFFFFF878
         dc 0xFFFFDE27
         dc 0x00000C95
         dc 0x00000DC8
         dc 0x000023A3
         dc 0x000000C5
         dc 0x00003EFD
         dc 0xFFFF8A73
         dc 0xFFFFCB35
         dc 0x00001D11
         dc 0x00001DFC
         dc 0x00007820
         dc 0x00005E58
         dc 0xFFFFDDE3
         dc 0x00002D16
         dc 0x00002295
         dc 0xFFFFEBC5
         dc 0xFFFFE44A
         dc 0xFFFFF423
         dc 0x00000170
         dc 0x000002CD
         dc 0x0000021E
         dc 0x00003A62
         dc 0x00001FDC
         dc 0x000030A7
         dc 0x000016B2
         dc 0x0000019C
         dc 0x0000331B
         dc 0x0000576C
         dc 0x000002DE
         dc 0x00005513
         dc 0xFFFFFD4A
         dc 0xFFFFF8B8
         dc 0xFFFFAD0E
         dc 0x00000A32
         dc 0xFFFFF77D
         dc 0xFFFFF8FC
         dc 0x000008AC
         dc 0xFFFFF699
         dc 0xFFFFD8FB
         dc 0x000095EC
         dc 0x00004678
         dc 0x00000BA5
         dc 0x00003C1F
         dc 0x00007681
         dc 0x000037A6
         dc 0xFFFFFF3C
         dc 0xFFFFF9F1
         dc 0xFFFFEF87
         dc 0xFFFFC57C
         dc 0xFFFFE1E0
         dc 0xFFFFF51F
         dc 0x0000155E
         dc 0xFFFFF719
         dc 0xFFFFF538
         dc 0xFFFFD4D7
         dc 0x000073D2
         dc 0x00000BBA
         dc 0x00003C0B
         dc 0x00000472
         dc 0x00005DFD
         dc 0x00001FC1
         dc 0x00000C9F
         dc 0x00001CC1
         dc 0xFFFFE645
         dc 0x000006CB
         dc 0x00000C2E
         dc 0xFFFFE6C5
         dc 0xFFFFF871
         dc 0x00000455
         dc 0xFFFFD8B5
         dc 0xFFFFB879
         dc 0xFFFFD7B0
         dc 0xFFFFD5F8
         dc 0xFFFFCFA6
         dc 0xFFFFCA0B
         dc 0xFFFFEC85
         dc 0x000010B0
         dc 0x00001CF4
         dc 0xFFFFD0EA
         dc 0x00002558
         dc 0x00001B71
         dc 0xFFFFEDA9
         dc 0xFFFFFD0F
         dc 0xFFFFEF68
         dc 0xFFFFEF63
         dc 0xFFFFE6A7
         dc 0xFFFF9E72
         dc 0xFFFFDE2A
         dc 0xFFFF6A70
         dc 0xFFFFAC64
         dc 0xFFFFAB10
         dc 0xFFFFE7CE
         dc 0x00000049
         dc 0xFFFFF159
         dc 0x000001AD
         dc 0x00005DE2
         dc 0x000029AD
         dc 0x000003C0
         dc 0x00001281
         dc 0x00001C15
         dc 0xFFFFF0BC
         dc 0xFFFFDD37
         dc 0xFFFFDCFA
         dc 0xFFFF9CB8
         dc 0xFFFF9336
         dc 0xFFFF992A
         dc 0xFFFF9BB2
         dc 0xFFFFC8C8
         dc 0x000021E1
         dc 0x00001F1F
         dc 0xFFFFE936
         dc 0xFFFFD8BC
         dc 0x00000F8A
         dc 0xFFFFFA97
         dc 0x00000915
         dc 0xFFFFD73D
         dc 0xFFFFF4C3
         dc 0xFFFFF479
         dc 0xFFFFD25A
         dc 0xFFFF9269
         dc 0xFFFFC08A
         dc 0xFFFFD21A
         dc 0xFFFFF2C9
         dc 0xFFFFAA3D
         dc 0xFFFF921A
         dc 0x000000D4
         dc 0x0000034C
         dc 0xFFFFF6A1
         dc 0x000028CC
         dc 0xFFFFF728
         dc 0xFFFFF76E
         dc 0xFFFFFEC3
         dc 0xFFFFFEFA
         dc 0x00000825
         dc 0xFFFFDAC7
         dc 0xFFFFDC58
         dc 0x000011B9
         dc 0xFFFFDCD5
         dc 0xFFFFE45E
         dc 0xFFFFDE67
         dc 0xFFFFBB2E
         dc 0xFFFFA78F
         dc 0xFFFFBBCC
         dc 0xFFFFF358
         dc 0x00002319
         dc 0x00000C94
         dc 0xFFFFED99
         dc 0xFFFFF8FC
         dc 0xFFFFFCB1
         dc 0xFFFFE6AE
         dc 0x000016B6
         dc 0xFFFFBA43
         dc 0x00004D5A
         dc 0x000034DF
         dc 0xFFFFBFE9
         dc 0xFFFFCA8B
         dc 0xFFFFFA6F
         dc 0xFFFFCA0F
         dc 0xFFFFC870
         dc 0xFFFFF57D
         dc 0xFFFF8CF5
         dc 0xFFFFB80A
         dc 0x00001663
         dc 0xFFFFF74C
         dc 0xFFFFFF4C
         dc 0xFFFFFE73
         dc 0x00000B3B
         dc 0x00001C14
         dc 0xFFFFADBA
         dc 0xFFFF9B77
         dc 0xFFFFBE60
         dc 0x000030C5
         dc 0x000021FC
         dc 0x00003005
         dc 0xFFFFE280
         dc 0xFFFFE18A
         dc 0xFFFFCA53
         dc 0xFFFFE6B5
         dc 0x00000495
         dc 0x000007BF    * W1[4][0]
         dc 0x000019D4
         dc 0xFFFFF37C
         dc 0xFFFFFBE5
         dc 0x0000057C
         dc 0xFFFFE8FB
         dc 0x0000145E
         dc 0xFFFFFB10
         dc 0xFFFFBB2C
         dc 0xFFFFB0A5
         dc 0xFFFFF651
         dc 0xFFFFE1E3
         dc 0x000005E3
         dc 0xFFFFE15A
         dc 0xFFFFCB90
         dc 0x000018E1
         dc 0x00001170
         dc 0xFFFFF23E
         dc 0xFFFFF363
         dc 0xFFFFF78C
         dc 0x00001126
         dc 0xFFFFB23B
         dc 0xFFFFF95A
         dc 0xFFFFB868
         dc 0xFFFFF9D1
         dc 0xFFFFE133
         dc 0xFFFFB3F5
         dc 0xFFFF9CF5
         dc 0xFFFFDA15
         dc 0xFFFFD55B
         dc 0xFFFFC8B8
         dc 0x000010AA
         dc 0xFFFFED5C
         dc 0xFFFFEEF5
         dc 0xFFFFF19D
         dc 0xFFFFD636
         dc 0xFFFFBCDA
         dc 0x0000058C
         dc 0xFFFFC117
         dc 0xFFFF57D5
         dc 0xFFFFDA5D
         dc 0xFFFF9A79
         dc 0x00000C94
         dc 0xFFFF966A
         dc 0xFFFFD7D0
         dc 0x00003843
         dc 0xFFFFEFFD
         dc 0x00000103
         dc 0xFFFFFE9D
         dc 0xFFFFFFC0
         dc 0xFFFFBCE8
         dc 0xFFFFC6D2
         dc 0x00000FED
         dc 0x00000D44
         dc 0xFFFFD252
         dc 0xFFFFE3A1
         dc 0x000003A3
         dc 0xFFFFBD8B
         dc 0x0000231D
         dc 0x00003E7E
         dc 0x00001F48
         dc 0x00002D7D
         dc 0x00000614
         dc 0x00001282
         dc 0xFFFFFA9F
         dc 0x000010A6
         dc 0xFFFFF418
         dc 0xFFFFF8D8
         dc 0x00000D68
         dc 0x000092EF
         dc 0x00003FDC
         dc 0x00004B49
         dc 0x00003883
         dc 0x0000778A
         dc 0x000074DE
         dc 0x00004893
         dc 0x00006CE3
         dc 0x0000275D
         dc 0xFFFFF9D9
         dc 0x00000383
         dc 0x00000570
         dc 0x0000161C
         dc 0xFFFFF53F
         dc 0xFFFFF76A
         dc 0x00006963
         dc 0x0000A20E
         dc 0x00002F64
         dc 0xFFFFF4E5
         dc 0xFFFFFF3C
         dc 0x00004B62
         dc 0x000081D7
         dc 0x000068EC
         dc 0x000040DA
         dc 0xFFFFDFD2
         dc 0xFFFFF8DF
         dc 0x0000078E
         dc 0xFFFFF5F8
         dc 0x00001356
         dc 0x00000F82
         dc 0x00007576
         dc 0x000084B6
         dc 0x0000768E
         dc 0x00005486
         dc 0xFFFFC92A
         dc 0xFFFFDAA3
         dc 0x0000065F
         dc 0x00002C78
         dc 0x00009FEE
         dc 0x000064F0
         dc 0xFFFFDD08
         dc 0xFFFFF4BE
         dc 0x00000A35
         dc 0xFFFFF341
         dc 0x00000212
         dc 0x0000083D
         dc 0xFFFFF8D4
         dc 0x00007B61
         dc 0x0000212D
         dc 0xFFFF9AB3
         dc 0xFFFFC15E
         dc 0xFFFF9EAC
         dc 0xFFFFD253
         dc 0x00003891
         dc 0x0000EFCC
         dc 0x00005810
         dc 0xFFFFFBE2
         dc 0xFFFFFB32
         dc 0x00000E5B
         dc 0xFFFFEF56
         dc 0xFFFFF633
         dc 0x00000F3F
         dc 0x000043B6
         dc 0x00006AF9
         dc 0xFFFFDD3B
         dc 0xFFFFE09B
         dc 0xFFFF793C
         dc 0xFFFF740C
         dc 0x000014E1
         dc 0x00000EC7
         dc 0x00008F28
         dc 0x00002BD8
         dc 0xFFFFF53A
         dc 0x00000B6B
         dc 0x00000AF1
         dc 0x00000C2F
         dc 0x00001A29
         dc 0x00001B3C
         dc 0x000020C5
         dc 0x00004F41
         dc 0xFFFFD387
         dc 0xFFFFD31A
         dc 0xFFFF8883
         dc 0xFFFFBFD3
         dc 0x00003629
         dc 0x00005F23
         dc 0x00004D93
         dc 0x000016AF
         dc 0xFFFFECAC
         dc 0xFFFFF659
         dc 0x00000F3F
         dc 0xFFFFF17F
         dc 0x00000E59
         dc 0x000011E5
         dc 0x00000947
         dc 0x00000863
         dc 0xFFFFA225
         dc 0xFFFF8DDA
         dc 0xFFFF7412
         dc 0xFFFFE3D9
         dc 0x00001833
         dc 0x00000AC6
         dc 0x00004450
         dc 0xFFFFFC81
         dc 0xFFFFC397
         dc 0x000002DB
         dc 0xFFFFED3A
         dc 0xFFFFEAC5
         dc 0x000007B6
         dc 0x00003670
         dc 0xFFFFF301
         dc 0xFFFFAAF3
         dc 0xFFFFA4A8
         dc 0x00001DB8
         dc 0xFFFFEE76
         dc 0x00000204
         dc 0x00001FD6
         dc 0x00003996
         dc 0xFFFFF0B7
         dc 0xFFFFC187
         dc 0xFFFFB54B
         dc 0xFFFFEA43
         dc 0xFFFFFCFE
         dc 0x0000078B
         dc 0x00000DA9
         dc 0x000015DC
         dc 0xFFFFE63A
         dc 0xFFFFD380
         dc 0xFFFFC857
         dc 0xFFFFE036
         dc 0xFFFFD9C3
         dc 0x00002CE5
         dc 0xFFFFFFE6
         dc 0x00004FE1
         dc 0xFFFFDD60
         dc 0xFFFFD88B
         dc 0xFFFFFC69
         dc 0xFFFFEB62
         dc 0x0000119D
         dc 0x00000E94
         dc 0xFFFFD093
         dc 0x0000031A
         dc 0xFFFFFF01
         dc 0xFFFFE6F6
         dc 0x00002A16
         dc 0xFFFFC061
         dc 0x000019CA
         dc 0x00000526
         dc 0xFFFFD6DE
         dc 0xFFFFD031
         dc 0xFFFFC87D
         dc 0x00001917
         dc 0x00002EE9
         dc 0xFFFFFAD4
         dc 0x00002C25
         dc 0x00001090
         dc 0xFFFFF3AA
         dc 0x00001AA9
         dc 0xFFFFFFAC
         dc 0x000025BA
         dc 0xFFFFD1CA
         dc 0xFFFF9662
         dc 0xFFFF6080
         dc 0xFFFFC73D
         dc 0xFFFFC9DE
         dc 0xFFFFF7B0
         dc 0x0000579C
         dc 0xFFFFF958
         dc 0xFFFFEB34
         dc 0xFFFFEC40
         dc 0xFFFFF5AE
         dc 0xFFFFFA26
         dc 0xFFFFEA7A
         dc 0xFFFFED8C
         dc 0x000015F2
         dc 0x00002745
         dc 0x0000084C
         dc 0xFFFFE27B
         dc 0xFFFFB63C
         dc 0x00000F8F
         dc 0x00002CC2
         dc 0x00006953
         dc 0x000005F8
         dc 0x00000589
         dc 0x000002D1
         dc 0xFFFFF934
         dc 0x00001312
         dc 0x00000A76    * W1[5][0]
         dc 0xFFFFFF2D
         dc 0xFFFFF88E
         dc 0xFFFFED4A
         dc 0x000018ED
         dc 0x00000C5D
         dc 0xFFFFC5BF
         dc 0x000007EE
         dc 0xFFFFF9BE
         dc 0x00000A01
         dc 0xFFFFF775
         dc 0xFFFFE865
         dc 0xFFFFDDC0
         dc 0xFFFFE0EA
         dc 0xFFFFFFB3
         dc 0xFFFFE119
         dc 0xFFFFFF4B
         dc 0x00001BEB
         dc 0x0000140A
         dc 0x00003D36
         dc 0x000011D4
         dc 0xFFFFE3CF
         dc 0xFFFFD2FD
         dc 0x00003306
         dc 0x0000288D
         dc 0xFFFFFAE6
         dc 0xFFFFF978
         dc 0x00001B37
         dc 0xFFFFEA8E
         dc 0x00000422
         dc 0xFFFFF8A9
         dc 0xFFFFD5E9
         dc 0x000013BA
         dc 0xFFFFE5AE
         dc 0xFFFFF7D4
         dc 0x0000385C
         dc 0x00002960
         dc 0xFFFFEA7F
         dc 0xFFFFF017
         dc 0x000071AB
         dc 0x000060FD
         dc 0x0000565B
         dc 0x0000119E
         dc 0x00003675
         dc 0x000022BE
         dc 0xFFFFCD71
         dc 0xFFFFF41F
         dc 0xFFFFFE87
         dc 0xFFFFE4FC
         dc 0xFFFFF21F
         dc 0x0000001D
         dc 0x0000378F
         dc 0x00002C21
         dc 0xFFFFC5B4
         dc 0xFFFFDA6B
         dc 0xFFFFFA78
         dc 0x00001C52
         dc 0x00005C1D
         dc 0x000056A7
         dc 0xFFFFDD44
         dc 0x00002B4C
         dc 0x00001267
         dc 0x0000284F
         dc 0x000015EC
         dc 0x000010BC
         dc 0x0000065A
         dc 0xFFFFF63F
         dc 0x00001C95
         dc 0xFFFF982D
         dc 0xFFFF9383
         dc 0xFFFF9EF5
         dc 0xFFFFA258
         dc 0x000028EC
         dc 0x0000941F
         dc 0x00007713
         dc 0x00003DB1
         dc 0x000026F3
         dc 0x00004097
         dc 0xFFFFF79B
         dc 0x00000691
         dc 0x0000129A
         dc 0x00001571
         dc 0x0000195E
         dc 0xFFFF9928
         dc 0xFFFFAE66
         dc 0xFFFFEC7F
         dc 0xFFFFB22F
         dc 0xFFFFE5A6
         dc 0x0000540C
         dc 0x00006B49
         dc 0x00006630
         dc 0x00003031
         dc 0x00005AEB
         dc 0x00003A05
         dc 0x00000922
         dc 0x000002E4
         dc 0xFFFFDB4F
         dc 0x000004CD
         dc 0x000009FB
         dc 0xFFFFAE86
         dc 0xFFFFD61B
         dc 0xFFFF8DDD
         dc 0xFFFFA429
         dc 0x00002016
         dc 0x00000737
         dc 0xFFFFF61E
         dc 0x00005CF7
         dc 0xFFFFF5A2
         dc 0x00002555
         dc 0x0000045F
         dc 0x000001C9
         dc 0x00001EBC
         dc 0x000014FB
         dc 0xFFFFFE96
         dc 0xFFFFE19D
         dc 0xFFFFE3BE
         dc 0xFFFFAC03
         dc 0xFFFFCF47
         dc 0x00000010
         dc 0xFFFFE7E4
         dc 0x0000145C
         dc 0xFFFFDA5E
         dc 0x00004265
         dc 0x00001312
         dc 0x000003FF
         dc 0xFFFFFDD5
         dc 0x00000AB3
         dc 0x0000095A
         dc 0x00000BFD
         dc 0xFFFFEEF8
         dc 0xFFFFF76A
         dc 0xFFFFBECB
         dc 0xFFFFAB9F
         dc 0x00001E4F
         dc 0x000039BF
         dc 0x00004885
         dc 0xFFFFF8E3
         dc 0x00001F52
         dc 0x000022AD
         dc 0x00007327
         dc 0x00000DC4
         dc 0x00000708
         dc 0xFFFFF086
         dc 0x00000651
         dc 0x00000E47
         dc 0xFFFFF7C2
         dc 0x00001BBB
         dc 0x00000421
         dc 0xFFFFBAE8
         dc 0xFFFFDB45
         dc 0xFFFFF5A6
         dc 0x00001B14
         dc 0x00005799
         dc 0x000036E8
         dc 0x00004D84
         dc 0x000044E0
         dc 0x00007FB6
         dc 0x0000260C
         dc 0x0000048B
         dc 0x00001447
         dc 0x00000DA2
         dc 0x0000016D
         dc 0xFFFFEE03
         dc 0xFFFFE756
         dc 0xFFFFD3F6
         dc 0xFFFF7BFF
         dc 0xFFFFBD55
         dc 0x000027E8
         dc 0x00006C7D
         dc 0x0000400B
         dc 0x00004FA6
         dc 0x00003868
         dc 0x0000982F
         dc 0x00004474
         dc 0x00000992
         dc 0xFFFFF758
         dc 0x00000486
         dc 0xFFFFDE4F
         dc 0x00000B53
         dc 0xFFFFE29B
         dc 0xFFFFA57B
         dc 0xFFFF93F4
         dc 0xFFFF9EC5
         dc 0xFFFF9B26
         dc 0x000028EC
         dc 0x0000267B
         dc 0x00001E69
         dc 0x0000096E
         dc 0x00003E09
         dc 0x00001EB0
         dc 0xFFFFFFBD
         dc 0x000004BE
         dc 0x00000376
         dc 0xFFFFF96A
         dc 0xFFFFE45A
         dc 0xFFFFD808
         dc 0xFFFFC62D
         dc 0xFFFFD467
         dc 0xFFFFA619
         dc 0xFFFFC37A
         dc 0xFFFF9C9A
         dc 0xFFFFD022
         dc 0xFFFFFD66
         dc 0x00002EB1
         dc 0x000003DA
         dc 0x00002192
         dc 0x00000B21
         dc 0xFFFFE400
         dc 0xFFFFF8B6
         dc 0x00000A5B
         dc 0x000003BF
         dc 0xFFFFE85A
         dc 0x0000188A
         dc 0xFFFFDF6F
         dc 0xFFFFF411
         dc 0xFFFFB413
         dc 0xFFFFAEBE
         dc 0xFFFFBCE1
         dc 0xFFFFF781
         dc 0xFFFFEBE8
         dc 0xFFFFFBA5
         dc 0xFFFFA89E
         dc 0xFFFFE2E0
         dc 0xFFFFFB57
         dc 0xFFFFF2E9
         dc 0xFFFFEBE6
         dc 0x00000657
         dc 0x00003341
         dc 0x00003988
         dc 0xFFFFFCB9
         dc 0xFFFF99A4
         dc 0xFFFFB70A
         dc 0xFFFF4B8C
         dc 0xFFFF620A
         dc 0xFFFFD47D
         dc 0xFFFFEA62
         dc 0xFFFFC2D8
         dc 0xFFFF6E27
         dc 0xFFFFB577
         dc 0xFFFFEF0D
         dc 0xFFFFFF94
         dc 0xFFFFFF0A
         dc 0xFFFFF973
         dc 0x000010EC
         dc 0x00005087
         dc 0x000017BA
         dc 0xFFFF871A
         dc 0xFFFFCD9C
         dc 0xFFFFAE12
         dc 0xFFFFFEB2
         dc 0x00001D1C
         dc 0x000002D3
         dc 0xFFFFE61E
         dc 0xFFFFC0EE
         dc 0x00000A62
         dc 0xFFFFE148
         dc 0xFFFFFF5E    * W1[6][0]
         dc 0x00001625
         dc 0xFFFFFE31
         dc 0xFFFFD886
         dc 0x00000A00
         dc 0x00000E8E
         dc 0x00001B3A
         dc 0xFFFFBBD9
         dc 0xFFFFAE82
         dc 0x00002F23
         dc 0x0000347D
         dc 0x00004321
         dc 0x00003473
         dc 0x00000679
         dc 0x0000062B
         dc 0x00000C2F
         dc 0x00000F3C
         dc 0xFFFFF245
         dc 0xFFFFEE08
         dc 0xFFFFBA91
         dc 0x00002370
         dc 0x00001DD6
         dc 0xFFFFB42B
         dc 0xFFFFE318
         dc 0x00000B62
         dc 0x00006805
         dc 0x0000974D
         dc 0x00004595
         dc 0x000046D8
         dc 0x000025CE
         dc 0xFFFFF0A1
         dc 0x00002030
         dc 0xFFFFE540
         dc 0x00000EA0
         dc 0x00002A82
         dc 0xFFFFFF12
         dc 0xFFFFC589
         dc 0xFFFF7BB3
         dc 0xFFFFE1C4
         dc 0xFFFFD879
         dc 0xFFFFD0C9
         dc 0xFFFFEBAD
         dc 0x000066E2
         dc 0xFFFFFF8A
         dc 0x0000229B
         dc 0xFFFFF748
         dc 0x00000B91
         dc 0x00000748
         dc 0x000025DD
         dc 0xFFFFEAC0
         dc 0x00002E95
         dc 0xFFFFED92
         dc 0xFFFFB6E2
         dc 0xFFFFD5F7
         dc 0x000042D6
         dc 0x00000F08
         dc 0xFFFFC272
         dc 0x0000009F
         dc 0xFFFFB189
         dc 0xFFFFEA23
         dc 0xFFFFB4E2
         dc 0xFFFFF4A9
         dc 0x0000005E
         dc 0xFFFFFB70
         dc 0x00000F36
         dc 0x000002B3
         dc 0x0000053C
         dc 0x00000D78
         dc 0xFFFFB6C5
         dc 0x000045E4
         dc 0x000010A8
         dc 0x00004405
         dc 0xFFFFC411
         dc 0xFFFFB845
         dc 0xFFFFAD49
         dc 0xFFFFBDF5
         dc 0xFFFFD5D1
         dc 0xFFFFDC46
         dc 0x000004C6
         dc 0x00002999
         dc 0xFFFFEECD
         dc 0x000006F7
         dc 0x00004C29
         dc 0x00005110
         dc 0x000097CE
         dc 0x00003A2E
         dc 0x000079D2
         dc 0x000026EA
         dc 0x000016E7
         dc 0x00001746
         dc 0x00000319
         dc 0xFFFFC6A3
         dc 0xFFFF9F1B
         dc 0x00002730
         dc 0x000003C8
         dc 0xFFFFFE51
         dc 0x00000F96
         dc 0x00000C66
         dc 0x00001FB1
         dc 0x00001629
         dc 0x000002E0
         dc 0x0000566A
         dc 0x00008B8A
         dc 0x000030D8
         dc 0x00004B04
         dc 0x00001A3C
         dc 0x00004743
         dc 0xFFFFFAC4
         dc 0xFFFFF893
         dc 0x000013F9
         dc 0x00000BBE
         dc 0xFFFFF9FC
         dc 0x000023AC
         dc 0x000001CC
         dc 0x00000AD9
         dc 0xFFFF8B2C
         dc 0xFFFFFD0B
         dc 0x00004440
         dc 0x00005F96
         dc 0xFFFFF224
         dc 0x0000129C
         dc 0xFFFFE4AE
         dc 0x000032D2
         dc 0x00002DA5
         dc 0x00003BDA
         dc 0xFFFFF2A5
         dc 0xFFFFF78D
         dc 0xFFFFF459
         dc 0xFFFFE1AD
         dc 0x00000330
         dc 0x000013C3
         dc 0x000001CE
         dc 0x000014CC
         dc 0x000036DC
         dc 0x00003F71
         dc 0x00004048
         dc 0xFFFFCDB2
         dc 0xFFFFD390
         dc 0x00004B84
         dc 0x00000156
         dc 0x00004943
         dc 0x000001AC
         dc 0x0000041B
         dc 0xFFFFFBCB
         dc 0xFFFFE74F
         dc 0xFFFFE6C8
         dc 0x000007B3
         dc 0x00001A3A
         dc 0x00002F11
         dc 0x00002503
         dc 0x0000506B
         dc 0x000042C2
         dc 0x0000623E
         dc 0x00001DF8
         dc 0x000075E7
         dc 0xFFFFBFD3
         dc 0x00003B02
         dc 0x00003428
         dc 0xFFFFEB82
         dc 0xFFFFE287
         dc 0xFFFFFC7F
         dc 0xFFFFF979
         dc 0xFFFFEFED
         dc 0x0000055D
         dc 0xFFFFFC68
         dc 0x000059B0
         dc 0x0000894E
         dc 0x00009932
         dc 0x000077DD
         dc 0x0000725C
         dc 0x00005472
         dc 0x0000009A
         dc 0xFFFFD035
         dc 0x00002000
         dc 0xFFFFE73D
         dc 0xFFFFF4F9
         dc 0x00000C56
         dc 0xFFFFFD57
         dc 0xFFFFF6D7
         dc 0x0000450D
         dc 0xFFFFD873
         dc 0xFFFFF87F
         dc 0xFFFFF156
         dc 0x0000553B
         dc 0x00004AD5
         dc 0xFFFFE43C
         dc 0x00003E52
         dc 0xFFFFEC86
         dc 0x00005FAB
         dc 0x00004BC4
         dc 0x00000C78
         dc 0xFFFFEC24
         dc 0xFFFFFB0F
         dc 0xFFFFFE20
         dc 0xFFFFC661
         dc 0x000034E4
         dc 0xFFFFD959
         dc 0xFFFFD243
         dc 0xFFFF7497
         dc 0xFFFFBE54
         dc 0xFFFFFDCE
         dc 0xFFFFF66E
         dc 0xFFFFBB98
         dc 0xFFFFA89C
         dc 0x00000033
         dc 0x00003E1A
         dc 0x000003DD
         dc 0x00000BA7
         dc 0x00000AE2
         dc 0xFFFFF8BD
         dc 0xFFFFE2BD
         dc 0xFFFFDB2F
         dc 0x00000263
         dc 0xFFFFD757
         dc 0xFFFFB402
         dc 0xFFFFAD06
         dc 0xFFFFE0D6
         dc 0xFFFFFD9A
         dc 0xFFFFB2A6
         dc 0xFFFFB51D
         dc 0xFFFFFCE4
         dc 0x000025EA
         dc 0x00002A5F
         dc 0x00001546
         dc 0xFFFFF0F8
         dc 0x00000524
         dc 0x0000024B
         dc 0xFFFF8618
         dc 0x0000018B
         dc 0x00001F13
         dc 0xFFFFDE53
         dc 0xFFFFCC6D
         dc 0xFFFFBEC4
         dc 0xFFFFC347
         dc 0xFFFFCA17
         dc 0xFFFF8F6B
         dc 0xFFFFBBB3
         dc 0xFFFFD07F
         dc 0x00001EAE
         dc 0x00001EEE
         dc 0xFFFFECDE
         dc 0x000000C1
         dc 0xFFFFF6CB
         dc 0xFFFFD861
         dc 0xFFFFCE68
         dc 0xFFFFAF8F
         dc 0xFFFFCEA3
         dc 0xFFFF79C1
         dc 0xFFFFE807
         dc 0x00000BB0
         dc 0x00001DAD
         dc 0x0000302D
         dc 0x000013C3
         dc 0x00000A2F
         dc 0x0000251A
         dc 0x00000256
         dc 0xFFFFED2F    * W1[7][0]
         dc 0xFFFFF25D
         dc 0xFFFFFF38
         dc 0x000008C6
         dc 0x00002914
         dc 0xFFFFFB96
         dc 0x000011E4
         dc 0x00001D0D
         dc 0xFFFFCB5E
         dc 0xFFFFF84E
         dc 0x0000527E
         dc 0xFFFFFE1E
         dc 0xFFFFE6FB
         dc 0x00000929
         dc 0x00000C48
         dc 0xFFFFF3A8
         dc 0xFFFFF95F
         dc 0xFFFFD7E3
         dc 0x00001D13
         dc 0x00007B4F
         dc 0x000037C6
         dc 0x000018BD
         dc 0x00003C86
         dc 0x000056FC
         dc 0x000022F1
         dc 0xFFFFA497
         dc 0xFFFFB698
         dc 0xFFFFEA08
         dc 0xFFFFF344
         dc 0x0000083F
         dc 0x000005F4
         dc 0xFFFFF686
         dc 0xFFFFEB8D
         dc 0xFFFFEF22
         dc 0x00000013
         dc 0x0000036A
         dc 0x00009EFD
         dc 0x00009DD2
         dc 0x0000692C
         dc 0x00007921
         dc 0x00006CAA
         dc 0x00006162
         dc 0xFFFFDFA8
         dc 0xFFFFCF0B
         dc 0xFFFFD7CB
         dc 0x0000007A
         dc 0x00000A1B
         dc 0xFFFFFDCC
         dc 0xFFFFE9C7
         dc 0xFFFFF478
         dc 0xFFFFE9E1
         dc 0x00000F33
         dc 0x000052D2
         dc 0xFFFFF7AB
         dc 0x000003A4
         dc 0x00002158
         dc 0x00000CA9
         dc 0x0000317D
         dc 0x00006776
         dc 0x00004344
         dc 0xFFFFF55D
         dc 0xFFFFF584
         dc 0xFFFFF549
         dc 0x0000170B
         dc 0xFFFFEF4D
         dc 0xFFFFF2B6
         dc 0x0000272F
         dc 0x00000008
         dc 0xFFFF7B99
         dc 0xFFFF7ACC
         dc 0xFFFF9D99
         dc 0xFFFFA54A
         dc 0xFFFFC8F8
         dc 0x00004A2A
         dc 0x00009D6A
         dc 0x00004F35
         dc 0x00001465
         dc 0x00000D8F
         dc 0xFFFFF753
         dc 0x000000AA
         dc 0xFFFFF603
         dc 0x000012CE
         dc 0xFFFFC304
         dc 0xFFFFED72
         dc 0xFFFF4944
         dc 0xFFFF429B
         dc 0xFFFF4E32
         dc 0xFFFFA99D
         dc 0xFFFFEBC3
         dc 0xFFFFCC93
         dc 0xFFFFFCC5
         dc 0x000076F8
         dc 0x00004EF9
         dc 0x00003015
         dc 0xFFFFD820
         dc 0x000012D2
         dc 0xFFFFFAB8
         dc 0x00000F28
         dc 0xFFFFF059
         dc 0xFFFFA2B0
         dc 0xFFFFE277
         dc 0xFFFFC176
         dc 0xFFFF6D72
         dc 0x00000688
         dc 0xFFFFF071
         dc 0xFFFFDED1
         dc 0xFFFFFEEB
         dc 0x00003E36
         dc 0x0000515E
         dc 0xFFFFF32C
         dc 0xFFFFFA73
         dc 0xFFFFF5CD
         dc 0x000005AE
         dc 0xFFFFFD79
         dc 0xFFFFF600
         dc 0x0000419C
         dc 0xFFFF8EB5
         dc 0x00000B25
         dc 0xFFFF9EFC
         dc 0xFFFFC885
         dc 0x0000112E
         dc 0xFFFFA8BC
         dc 0xFFFFDC45
         dc 0x0000294A
         dc 0x000069A0
         dc 0xFFFFE5B6
         dc 0xFFFFFA54
         dc 0xFFFFE59D
         dc 0xFFFFFFAC
         dc 0xFFFFFAEB
         dc 0xFFFFD90C
         dc 0xFFFFE986
         dc 0xFFFFF0E9
         dc 0x0000196F
         dc 0xFFFFA909
         dc 0xFFFFBB6C
         dc 0x00002573
         dc 0xFFFFD8E9
         dc 0xFFFFA3A3
         dc 0x00000560
         dc 0x00005146
         dc 0x00002D65
         dc 0x00001E3B
         dc 0x00000467
         dc 0xFFFFDF7D
         dc 0x00000392
         dc 0xFFFFDD22
         dc 0xFFFF8352
         dc 0x00003658
         dc 0x00005881
         dc 0xFFFFD2D0
         dc 0xFFFFF33A
         dc 0xFFFFDAC0
         dc 0xFFFFF66C
         dc 0xFFFF80D3
         dc 0xFFFFF9FC
         dc 0x00001612
         dc 0xFFFFCA2C
         dc 0x00000D82
         dc 0x00001009
         dc 0x00000CA3
         dc 0xFFFFFAB3
         dc 0xFFFFD91A
         dc 0xFFFFC2E0
         dc 0x000084F4
         dc 0x00004B6C
         dc 0xFFFFBBB4
         dc 0x00001428
         dc 0xFFFFF740
         dc 0xFFFFA79A
         dc 0xFFFFC6B9
         dc 0xFFFFAEDB
         dc 0xFFFFFCB7
         dc 0xFFFFE7CB
         dc 0xFFFFEFA1
         dc 0xFFFFF581
         dc 0xFFFFF511
         dc 0x000001BE
         dc 0xFFFFA281
         dc 0xFFFFBF92
         dc 0x000030FB
         dc 0x00006241
         dc 0xFFFFDE3C
         dc 0xFFFFC832
         dc 0x00000780
         dc 0xFFFFCB2E
         dc 0xFFFFD8A1
         dc 0xFFFFDE78
         dc 0xFFFFAD41
         dc 0xFFFFD558
         dc 0xFFFFEC8F
         dc 0x000009AC
         dc 0x000005BA
         dc 0xFFFFE9EB
         dc 0xFFFFA54B
         dc 0xFFFFE1CC
         dc 0x000051EE
         dc 0xFFFFF554
         dc 0x000046E1
         dc 0x00000129
         dc 0x00001040
         dc 0x000059B3
         dc 0x00006507
         dc 0x00003AB2
         dc 0xFFFFAF3B
         dc 0xFFFFACB2
         dc 0xFFFFE38D
         dc 0x00000602
         dc 0x000006B1
         dc 0xFFFFF415
         dc 0xFFFFE2F2
         dc 0x00001B3D
         dc 0x000013D9
         dc 0xFFFFBB68
         dc 0xFFFFD032
         dc 0x000017BF
         dc 0xFFFFF52B
         dc 0x00001379
         dc 0x00004F35
         dc 0x00004428
         dc 0x00001B71
         dc 0x00001210
         dc 0xFFFFD462
         dc 0x00001207
         dc 0x00000D91
         dc 0xFFFFF7D5
         dc 0x00000BF1
         dc 0x0000451B
         dc 0x00005346
         dc 0xFFFFE7CC
         dc 0x00000C95
         dc 0x000085B8
         dc 0x00003076
         dc 0x00000948
         dc 0x00002B91
         dc 0x0000337E
         dc 0x00005459
         dc 0x00002EF2
         dc 0xFFFFFD55
         dc 0xFFFFFB19
         dc 0x00001EC2
         dc 0xFFFFDFBB
         dc 0x00000FAD
         dc 0x0000025A
         dc 0x000032CE
         dc 0x00001CA6
         dc 0xFFFFFA39
         dc 0x00003E2F
         dc 0xFFFFB33E
         dc 0xFFFFC29E
         dc 0xFFFFB04A
         dc 0x000017BE
         dc 0xFFFFF4C6
         dc 0xFFFFDE38
         dc 0xFFFFF74C
         dc 0xFFFFFF80
         dc 0x00000CD3    * W1[8][0]
         dc 0x00000200
         dc 0x00000563
         dc 0x00001318
         dc 0x000008F7
         dc 0xFFFF990C
         dc 0xFFFF95E8
         dc 0x00001DD0
         dc 0x00006462
         dc 0x0000897E
         dc 0x000040C4
         dc 0xFFFFD392
         dc 0xFFFFA39C
         dc 0xFFFFCD10
         dc 0xFFFFC5CA
         dc 0xFFFFECCF
         dc 0xFFFFEC6E
         dc 0x000000E8
         dc 0x00000D01
         dc 0x00002F3D
         dc 0xFFFFE9A5
         dc 0xFFFF9D01
         dc 0xFFFF8875
         dc 0x00000C9C
         dc 0x000013DA
         dc 0x00000B4C
         dc 0x00001941
         dc 0xFFFFE60C
         dc 0xFFFFCC62
         dc 0xFFFFC33C
         dc 0xFFFFD156
         dc 0xFFFFDCAD
         dc 0xFFFFF821
         dc 0x00000F28
         dc 0x000017B7
         dc 0x00001A5B
         dc 0xFFFFEA03
         dc 0xFFFFF7EE
         dc 0xFFFFDA43
         dc 0x000024E7
         dc 0x00000B11
         dc 0x00002E97
         dc 0xFFFFB8FE
         dc 0x0000246F
         dc 0xFFFFE002
         dc 0xFFFFB95F
         dc 0xFFFFCDF1
         dc 0x00001BEA
         dc 0x000010FC
         dc 0x00000449
         dc 0xFFFFFE9D
         dc 0x00002981
         dc 0x0000248D
         dc 0xFFFF737D
         dc 0xFFFFD38A
         dc 0xFFFF9240
         dc 0xFFFF7CD4
         dc 0xFFFFB9B5
         dc 0xFFFFAAE4
         dc 0x00001400
         dc 0x000001CD
         dc 0xFFFFCA01
         dc 0xFFFFF939
         dc 0xFFFFF901
         dc 0x00000677
         dc 0xFFFFF5E4
         dc 0x00001C9B
         dc 0x0000306C
         dc 0x00000EBD
         dc 0xFFFFB0C1
         dc 0xFFFFF8B9
         dc 0xFFFFAC02
         dc 0xFFFF650D
         dc 0xFFFFBC7B
         dc 0xFFFFD4A8
         dc 0xFFFFA079
         dc 0xFFFFB4A2
         dc 0xFFFFDD38
         dc 0xFFFFF762
         dc 0x00000C4F
         dc 0xFFFFF742
         dc 0xFFFFEB3F
         dc 0xFFFFE9A9
         dc 0xFFFFF4D7
         dc 0xFFFFC496
         dc 0xFFFFC589
         dc 0xFFFFDB10
         dc 0xFFFFC030
         dc 0xFFFFAF78
         dc 0xFFFFC4FB
         dc 0xFFFFC40A
         dc 0xFFFFAED7
         dc 0xFFFFE2E7
         dc 0xFFFFE572
         dc 0xFFFFF2D9
         dc 0x00000601
         dc 0xFFFFF494
         dc 0x000017FE
         dc 0xFFFFF42D
         dc 0x00000833
         dc 0xFFFFB962
         dc 0xFFFFF960
         dc 0xFFFFDDB7
         dc 0xFFFFF579
         dc 0x000015FD
         dc 0xFFFFAAB6
         dc 0xFFFFB25C
         dc 0xFFFF6C3C
         dc 0xFFFF8780
         dc 0xFFFFF2F1
         dc 0x00001AFD
         dc 0x00000694
         dc 0x000004B3
         dc 0xFFFFF861
         dc 0xFFFFDA4A
         dc 0x00001C3F
         dc 0x00000191
         dc 0x00008B2F
         dc 0x000038CB
         dc 0x00003FC4
         dc 0xFFFFE55E
         dc 0xFFFFDA2B
         dc 0x0000006D
         dc 0xFFFF7608
         dc 0xFFFF70E1
         dc 0xFFFFDFF6
         dc 0xFFFFF8A1
         dc 0x000020B7
         dc 0xFFFFFC55
         dc 0x00000519
         dc 0xFFFFF3B8
         dc 0xFFFF8D7C
         dc 0xFFFFD462
         dc 0x00001A13
         dc 0x000032AF
         dc 0x00006284
         dc 0x00003501
         dc 0xFFFFEA17
         dc 0x00002963
         dc 0xFFFFF7C6
         dc 0xFFFFE01F
         dc 0x00001057
         dc 0xFFFFEBDB
         dc 0x00001A63
         dc 0xFFFFFDBF
         dc 0xFFFFFADF
         dc 0xFFFFE562
         dc 0x00002E52
         dc 0xFFFFFCDD
         dc 0xFFFFE781
         dc 0xFFFFE4E4
         dc 0x00007B5B
         dc 0x00001740
         dc 0x00008850
         dc 0xFFFFF3BB
         dc 0x00007425
         dc 0x00003D4B
         dc 0x00001BC5
         dc 0x0000055F
         dc 0x0000131B
         dc 0x00002A88
         dc 0xFFFFF9F2
         dc 0xFFFFE0F5
         dc 0x00004F69
         dc 0xFFFFF022
         dc 0x000045E1
         dc 0xFFFFF3C9
         dc 0x00002560
         dc 0x000028C8
         dc 0x00001802
         dc 0x0000677A
         dc 0x000050D0
         dc 0x000061C5
         dc 0x000028B8
         dc 0x0000102E
         dc 0xFFFFFD8C
         dc 0xFFFFE2A4
         dc 0xFFFFF65C
         dc 0xFFFFCAF6
         dc 0x000017CE
         dc 0x00004532
         dc 0xFFFFF2CD
         dc 0xFFFF5A11
         dc 0xFFFFB698
         dc 0x0000087D
         dc 0x00003FD2
         dc 0x00002ADC
         dc 0x00008218
         dc 0x0000B44F
         dc 0x000057D1
         dc 0x00000403
         dc 0xFFFFF2C9
         dc 0xFFFFF207
         dc 0x00000399
         dc 0x00000321
         dc 0xFFFFDD67
         dc 0x000023CD
         dc 0x0000493E
         dc 0xFFFFFB6F
         dc 0xFFFFD176
         dc 0xFFFF7164
         dc 0x000033FA
         dc 0x00004C50
         dc 0x00007C6D
         dc 0x00008C51
         dc 0x000010A1
         dc 0x00003762
         dc 0xFFFFE577
         dc 0xFFFFF26F
         dc 0x000013E6
         dc 0xFFFFE565
         dc 0xFFFFF45D
         dc 0xFFFFDFA8
         dc 0x00004270
         dc 0x00006E91
         dc 0xFFFFBBF3
         dc 0xFFFFD132
         dc 0x00000960
         dc 0x00005C90
         dc 0xFFFFD73B
         dc 0xFFFFC4F0
         dc 0xFFFFBB68
         dc 0xFFFFD252
         dc 0x00001376
         dc 0xFFFFF13D
         dc 0xFFFFF6F3
         dc 0x00001CEA
         dc 0x00000D1B
         dc 0xFFFFE7F4
         dc 0xFFFFCDF4
         dc 0x00000452
         dc 0x00005B35
         dc 0x00005C89
         dc 0x00005EC8
         dc 0x000040AC
         dc 0xFFFF5498
         dc 0xFFFF69AC
         dc 0x00002037
         dc 0xFFFFAAF4
         dc 0x000004B0
         dc 0x000001A2
         dc 0x00000896
         dc 0xFFFFEA28
         dc 0xFFFFF9CE
         dc 0x00005456
         dc 0x0000069D
         dc 0xFFFFEE59
         dc 0x00000B25
         dc 0x00004646
         dc 0x00001237
         dc 0x0000097E
         dc 0x00001AC1
         dc 0x00000AA5
         dc 0x00002708
         dc 0xFFFFCB59
         dc 0xFFFFEDE4
         dc 0xFFFFF853    * W1[9][0]
         dc 0x00000E42
         dc 0xFFFFF4C5
         dc 0xFFFFF054
         dc 0x00000E6A
         dc 0x000062EC
         dc 0x00000C3A
         dc 0xFFFFFAFB
         dc 0xFFFFE01F
         dc 0x00000759
         dc 0x0000090E
         dc 0x00001775
         dc 0xFFFFE9BA
         dc 0xFFFFE722
         dc 0xFFFFF0E8
         dc 0xFFFFEB40
         dc 0xFFFFE7AB
         dc 0x00000A67
         dc 0xFFFFFE1E
         dc 0xFFFFDB5B
         dc 0x0000546F
         dc 0x00006123
         dc 0x00002631
         dc 0x000002BE
         dc 0xFFFFE86D
         dc 0x00000516
         dc 0x0000060C
         dc 0xFFFFD07A
         dc 0x000004A4
         dc 0xFFFFEFA0
         dc 0xFFFFBF83
         dc 0xFFFFFD38
         dc 0xFFFFFD8D
         dc 0xFFFFE058
         dc 0xFFFFE9BD
         dc 0x00004AA7
         dc 0x00000425
         dc 0x00003343
         dc 0x00001EE0
         dc 0xFFFFC88C
         dc 0xFFFFB090
         dc 0xFFFFEEDF
         dc 0x000020DA
         dc 0xFFFFD4B6
         dc 0xFFFFE3C3
         dc 0x00001963
         dc 0xFFFFDEF8
         dc 0xFFFFFFA6
         dc 0x00000864
         dc 0x0000088D
         dc 0xFFFFFB54
         dc 0x00002026
         dc 0x0000013B
         dc 0x00005C40
         dc 0xFFFFFE18
         dc 0xFFFFBA74
         dc 0xFFFF8222
         dc 0xFFFFA412
         dc 0xFFFFCED7
         dc 0x00000393
         dc 0xFFFFB2C0
         dc 0x00000570
         dc 0xFFFFF035
         dc 0xFFFFF155
         dc 0x00000F01
         dc 0x000008C6
         dc 0x00000C82
         dc 0x00003FF8
         dc 0xFFFFD1C5
         dc 0x0000A567
         dc 0x00006EEE
         dc 0xFFFFE380
         dc 0xFFFFBB20
         dc 0x000026D9
         dc 0x00001C27
         dc 0xFFFFCEE7
         dc 0xFFFFE961
         dc 0x00001444
         dc 0x000014B3
         dc 0xFFFFF07A
         dc 0x00000A0B
         dc 0x0000266D
         dc 0xFFFFC68D
         dc 0xFFFFEFF5
         dc 0x0000481D
         dc 0x0000B8E8
         dc 0x0000597F
         dc 0x0000271B
         dc 0x00002D05
         dc 0x00004990
         dc 0x00007F42
         dc 0x00002977
         dc 0xFFFFBA55
         dc 0x000017D8
         dc 0x000010A0
         dc 0xFFFFF62D
         dc 0x00001863
         dc 0xFFFFF017
         dc 0x00001049
         dc 0x00005219
         dc 0x00000CE3
         dc 0x00007897
         dc 0x00007BF6
         dc 0xFFFF920A
         dc 0xFFFFB6AB
         dc 0x00000316
         dc 0x00005B7D
         dc 0x00008642
         dc 0x00000160
         dc 0xFFFFE099
         dc 0xFFFFF1F2
         dc 0xFFFFF9CC
         dc 0xFFFFFD78
         dc 0xFFFFF71E
         dc 0x0000008D
         dc 0xFFFFE827
         dc 0x0000222C
         dc 0x00003D8E
         dc 0x00000B46
         dc 0xFFFFBEB4
         dc 0xFFFFBEF7
         dc 0xFFFFE5FB
         dc 0x00003BFA
         dc 0x00008167
         dc 0xFFFFF3D2
         dc 0x000006CD
         dc 0x00001396
         dc 0xFFFFFEE9
         dc 0x00000160
         dc 0xFFFFF740
         dc 0x000008B5
         dc 0xFFFFEA78
         dc 0xFFFFDF99
         dc 0x00005045
         dc 0x00004A22
         dc 0xFFFFE665
         dc 0xFFFFBF8C
         dc 0xFFFFF5D9
         dc 0xFFFFF209
         dc 0x00000599
         dc 0x00000E19
         dc 0x0000125D
         dc 0x00001C79
         dc 0xFFFFF6C2
         dc 0x00000348
         dc 0x00001810
         dc 0x00000578
         dc 0xFFFFF48B
         dc 0xFFFFCA84
         dc 0x00001071
         dc 0x0000733A
         dc 0xFFFFD527
         dc 0x00000731
         dc 0xFFFFE8A0
         dc 0xFFFFEBAC
         dc 0xFFFFB343
         dc 0xFFFFDCD6
         dc 0xFFFFF2A9
         dc 0x000000EA
         dc 0xFFFFF6CE
         dc 0xFFFFF802
         dc 0x0000091C
         dc 0xFFFFF183
         dc 0xFFFF9FB6
         dc 0xFFFF5B09
         dc 0xFFFFBD39
         dc 0x000018D8
         dc 0xFFFFA996
         dc 0xFFFFE837
         dc 0xFFFFDD5E
         dc 0xFFFFBF9F
         dc 0xFFFFDCC5
         dc 0xFFFF91C8
         dc 0xFFFFE25B
         dc 0x000001B5
         dc 0xFFFFF5FE
         dc 0x000011B4
         dc 0x00000A3E
         dc 0x00001D24
         dc 0xFFFFD507
         dc 0xFFFF5767
         dc 0xFFFF9A64
         dc 0xFFFFF29C
         dc 0xFFFFDF7C
         dc 0x00004096
         dc 0xFFFFDDA6
         dc 0x000005CE
         dc 0xFFFFA7EC
         dc 0xFFFFD9B9
         dc 0xFFFF8133
         dc 0xFFFFED8C
         dc 0xFFFFE668
         dc 0xFFFFF68D
         dc 0x00000BD9
         dc 0x00000AA2
         dc 0x00002F62
         dc 0x00001FCF
         dc 0xFFFFA4C0
         dc 0xFFFFB459
         dc 0xFFFFECE8
         dc 0xFFFFE340
         dc 0xFFFFD0E7
         dc 0xFFFFFFE2
         dc 0xFFFF8875
         dc 0x000013C3
         dc 0xFFFFF1D0
         dc 0xFFFFE445
         dc 0xFFFFFA00
         dc 0x00001EB1
         dc 0xFFFFF096
         dc 0xFFFFFF17
         dc 0xFFFFFD6F
         dc 0x00001000
         dc 0x00001091
         dc 0x000001DD
         dc 0x00002095
         dc 0xFFFFCF66
         dc 0x00004CDA
         dc 0xFFFFDE99
         dc 0xFFFFCAAB
         dc 0x00002B35
         dc 0x00002CC0
         dc 0xFFFFF121
         dc 0xFFFFE8CC
         dc 0xFFFFF735
         dc 0x000014A1
         dc 0x000016BB
         dc 0xFFFFC2A9
         dc 0x00002F63
         dc 0x000036C4
         dc 0x000021BF
         dc 0xFFFFC03A
         dc 0xFFFF9A20
         dc 0xFFFFFC8B
         dc 0xFFFFD415
         dc 0x00001D0A
         dc 0x0000182B
         dc 0xFFFFDC67
         dc 0xFFFFEA9E
         dc 0xFFFFF991
         dc 0x00000FFC
         dc 0xFFFFF9DA
         dc 0xFFFFFFA5
         dc 0xFFFFDDDF
         dc 0xFFFFF352
         dc 0xFFFFC90E
         dc 0xFFFFD4E6
         dc 0xFFFFFDDD
         dc 0x000031CF
         dc 0xFFFFA925
         dc 0xFFFFD3DF
         dc 0xFFFFD702
         dc 0xFFFFF7FB
         dc 0xFFFFD65F
         dc 0xFFFFEFC4
         dc 0xFFFFE849
         dc 0x000022DB    * W1[10][0]
         dc 0x0000158D
         dc 0x00000709
         dc 0x00002C7D
         dc 0x00002600
         dc 0x000051C6
         dc 0xFFFFD67C
         dc 0xFFFFBA16
         dc 0x00004A6A
         dc 0x0000481F
         dc 0xFFFFFFB5
         dc 0x00000B13
         dc 0x00003EBB
         dc 0x00003C8B
         dc 0x000024B3
         dc 0xFFFFF4E9
         dc 0x00000939
         dc 0x0000197D
         dc 0xFFFFF963
         dc 0x00001CFA
         dc 0x00002597
         dc 0x00004C66
         dc 0xFFFFF819
         dc 0xFFFFDA89
         dc 0xFFFFFD7E
         dc 0x00003EC6
         dc 0x00004628
         dc 0x00001F47
         dc 0x00004910
         dc 0x00003E48
         dc 0x0000362F
         dc 0xFFFFFAA7
         dc 0xFFFFFC98
         dc 0xFFFFCE88
         dc 0xFFFFDCC0
         dc 0xFFFFD3CD
         dc 0x00002DBA
         dc 0x00001D89
         dc 0x00001A83
         dc 0x00003440
         dc 0x00004C34
         dc 0x00001E83
         dc 0x0000061A
         dc 0x00000483
         dc 0x00000856
         dc 0x000013B5
         dc 0x00001B36
         dc 0xFFFFF33F
         dc 0x0000050B
         dc 0xFFFFF8FB
         dc 0xFFFFFD76
         dc 0xFFFFF983
         dc 0xFFFFC1DB
         dc 0xFFFFDED8
         dc 0x000029A9
         dc 0x00002847
         dc 0x00001223
         dc 0xFFFFDD0B
         dc 0xFFFFD9AE
         dc 0xFFFF9274
         dc 0x000009AB
         dc 0x000041B7
         dc 0x000039D1
         dc 0xFFFFFAEE
         dc 0xFFFFFE27
         dc 0xFFFFE2B1
         dc 0xFFFFF5D0
         dc 0xFFFFFD5D
         dc 0x00002856
         dc 0xFFFF9C53
         dc 0x00001CA4
         dc 0x00000A45
         dc 0xFFFFEDBA
         dc 0xFFFF5F4C
         dc 0xFFFFCD5F
         dc 0xFFFF8C4E
         dc 0x00000916
         dc 0x00002113
         dc 0xFFFFD637
         dc 0x000004A4
         dc 0x00000394
         dc 0x000001CE
         dc 0xFFFFFAF7
         dc 0xFFFFE85D
         dc 0xFFFFD3B6
         dc 0xFFFFD0C1
         dc 0xFFFFC76D
         dc 0xFFFFFE03
         dc 0xFFFFD353
         dc 0xFFFFDDDE
         dc 0xFFFFA172
         dc 0xFFFF84C6
         dc 0xFFFFE884
         dc 0xFFFFE73E
         dc 0xFFFFF006
         dc 0xFFFFF760
         dc 0xFFFFFD3C
         dc 0xFFFFFBAE
         dc 0xFFFFF462
         dc 0xFFFFF596
         dc 0xFFFFF05B
         dc 0xFFFF9799
         dc 0xFFFFBD6D
         dc 0xFFFFF82E
         dc 0xFFFFEB9B
         dc 0xFFFFB132
         dc 0xFFFFFC93
         dc 0xFFFF9D77
         dc 0xFFFF3AA7
         dc 0xFFFFC380
         dc 0x00000E8B
         dc 0xFFFFF907
         dc 0x000000EC
         dc 0xFFFFFE4F
         dc 0x00002C90
         dc 0x000003E2
         dc 0xFFFFE269
         dc 0x000008B1
         dc 0xFFFFF3B3
         dc 0xFFFFF15F
         dc 0xFFFFF416
         dc 0xFFFFCA09
         dc 0xFFFFED2A
         dc 0xFFFF98FD
         dc 0xFFFF770D
         dc 0xFFFFE59C
         dc 0xFFFFF201
         dc 0x0000034C
         dc 0xFFFFF9E3
         dc 0xFFFFECEA
         dc 0x000019D7
         dc 0x00001D42
         dc 0xFFFFDA9B
         dc 0xFFFFE945
         dc 0xFFFFE558
         dc 0x00001B90
         dc 0x00000164
         dc 0xFFFFC9C4
         dc 0xFFFFD994
         dc 0xFFFFA39D
         dc 0xFFFFD18E
         dc 0xFFFFF0CA
         dc 0x0000112B
         dc 0x00000A21
         dc 0xFFFFF553
         dc 0xFFFFFABD
         dc 0x0000064A
         dc 0xFFFFB2F5
         dc 0xFFFF8459
         dc 0xFFFFF9B0
         dc 0xFFFFF8A1
         dc 0xFFFFF8BF
         dc 0x000007D2
         dc 0xFFFFA4F5
         dc 0xFFFFD234
         dc 0xFFFFFDDF
         dc 0xFFFFC324
         dc 0xFFFFDEAA
         dc 0x00000BB3
         dc 0x000006BA
         dc 0xFFFFF65D
         dc 0x00000E06
         dc 0xFFFFEF41
         dc 0xFFFF73DF
         dc 0xFFFF6788
         dc 0xFFFF8D72
         dc 0xFFFFAB7C
         dc 0x0000681F
         dc 0xFFFF8CDC
         dc 0xFFFFA482
         dc 0xFFFFE1CC
         dc 0xFFFFDE45
         dc 0x0000107D
         dc 0x000001F9
         dc 0xFFFFE4FF
         dc 0x000009B0
         dc 0xFFFFF140
         dc 0x0000034D
         dc 0xFFFFF9A0
         dc 0xFFFF6E75
         dc 0xFFFF9265
         dc 0xFFFFAECF
         dc 0xFFFF9325
         dc 0xFFFFD031
         dc 0xFFFF7F6C
         dc 0x0000113C
         dc 0xFFFFBF6D
         dc 0x000017E8
         dc 0xFFFFD8D7
         dc 0x00001F08
         dc 0xFFFFD6B6
         dc 0x000008C1
         dc 0xFFFFE0A1
         dc 0x00002DD8
         dc 0xFFFFFE2B
         dc 0xFFFFAB2C
         dc 0xFFFFEFD9
         dc 0xFFFF8D59
         dc 0x000034EC
         dc 0x00001428
         dc 0x00004717
         dc 0x00000FBE
         dc 0xFFFFFA20
         dc 0x00004596
         dc 0xFFFFB53C
         dc 0x000015E9
         dc 0x00000790
         dc 0x00000DA3
         dc 0x000007C4
         dc 0xFFFFFE3D
         dc 0xFFFFFFC4
         dc 0x00001E6B
         dc 0x000002EB
         dc 0x00001B26
         dc 0x00007C1E
         dc 0x0000126E
         dc 0x00005EE0
         dc 0x00006475
         dc 0x00005A4E
         dc 0x000038F0
         dc 0xFFFFDDD1
         dc 0xFFFFE27B
         dc 0x00001527
         dc 0xFFFFFCE3
         dc 0x000012FB
         dc 0x00001556
         dc 0xFFFFED80
         dc 0x00001BDC
         dc 0x00009E7B
         dc 0x000060B4
         dc 0xFFFFFA1E
         dc 0x00003A2D
         dc 0x000094F0
         dc 0x000091C9
         dc 0x000051A3
         dc 0x00005A82
         dc 0x0000431A
         dc 0x00003F5D
         dc 0x000027C4
         dc 0x00000445
         dc 0xFFFFEB80
         dc 0x00000E70
         dc 0xFFFFF88A
         dc 0x0000238E
         dc 0x000016C0
         dc 0x000085E1
         dc 0x00005AAC
         dc 0x00001AC0
         dc 0x00001957
         dc 0x00005D92
         dc 0x00000C1C
         dc 0x0000032C
         dc 0x00001231
         dc 0x00002461
         dc 0x0000028E
         dc 0xFFFFFEA6
         dc 0x0000036D    * W1[11][0]
         dc 0x000008F9
         dc 0x000000D1
         dc 0xFFFFF88E
         dc 0xFFFF98EC
         dc 0xFFFFDE2B
         dc 0x0000015A
         dc 0x00001BCD
         dc 0xFFFFF62D
         dc 0xFFFFF291
         dc 0xFFFFF7FC
         dc 0xFFFFB50F
         dc 0xFFFFD256
         dc 0x0000216D
         dc 0xFFFFFC55
         dc 0xFFFFE47D
         dc 0x0000074F
         dc 0x00001D8F
         dc 0xFFFFE741
         dc 0x000000E7
         dc 0x00000379
         dc 0xFFFFE3AF
         dc 0x000053E8
         dc 0x00005464
         dc 0x00004D1D
         dc 0xFFFFAED8
         dc 0xFFFF8E77
         dc 0xFFFF8CE9
         dc 0xFFFF9C3F
         dc 0x00001298
         dc 0xFFFFF9CC
         dc 0x000005BF
         dc 0x000004E7
         dc 0xFFFFE393
         dc 0xFFFFE5BD
         dc 0xFFFFFA62
         dc 0x000007A1
         dc 0x000026B0
         dc 0x00000999
         dc 0x00002C84
         dc 0x00002714
         dc 0x00001D82
         dc 0xFFFFCB98
         dc 0x0000094B
         dc 0xFFFFF8DF
         dc 0x00002270
         dc 0x000034F1
         dc 0xFFFFECE6
         dc 0xFFFFF309
         dc 0xFFFFF1D6
         dc 0xFFFFE378
         dc 0x00005113
         dc 0x00001F73
         dc 0x00001785
         dc 0xFFFF9EE4
         dc 0x00000DE5
         dc 0x00001DEB
         dc 0x00000047
         dc 0x000009F8
         dc 0x000046B4
         dc 0x00005713
         dc 0x00000D54
         dc 0x00002BC7
         dc 0xFFFFF8BD
         dc 0xFFFFEDDB
         dc 0x0000099F
         dc 0x00000360
         dc 0x0000087A
         dc 0xFFFFBDA5
         dc 0x00000113
         dc 0xFFFFF391
         dc 0x0000212F
         dc 0x00000856
         dc 0x000034DA
         dc 0x0000B326
         dc 0x00009CCB
         dc 0x0000A511
         dc 0x0000467B
         dc 0x000022DB
         dc 0x00001ED8
         dc 0xFFFFF02F
         dc 0xFFFFF84B
         dc 0x00000C72
         dc 0xFFFFE2DD
         dc 0xFFFFC058
         dc 0xFFFFD3C9
         dc 0xFFFFCDD3
         dc 0x000082EB
         dc 0x00009D0C
         dc 0x00000089
         dc 0x00002C84
         dc 0x0000525A
         dc 0x00004966
         dc 0x0000373E
         dc 0xFFFFE597
         dc 0xFFFFFC19
         dc 0x0000097E
         dc 0xFFFFF962
         dc 0x0000013C
         dc 0x0000188B
         dc 0xFFFF98FF
         dc 0xFFFFFE64
         dc 0xFFFFF069
         dc 0x00004D68
         dc 0x000057E2
         dc 0x00005B2D
         dc 0x000043CA
         dc 0x00000837
         dc 0x00004958
         dc 0x000006A1
         dc 0x00000E5C
         dc 0x000004E7
         dc 0x0000099C
         dc 0x00000693
         dc 0xFFFFF59F
         dc 0xFFFFC5D2
         dc 0xFFFFBBFB
         dc 0xFFFFBE60
         dc 0x0000405C
         dc 0x000041FE
         dc 0x000052AD
         dc 0x0000329F
         dc 0x00004149
         dc 0xFFFFE9BE
         dc 0x00000B28
         dc 0x00001EE8
         dc 0xFFFFFBFF
         dc 0xFFFFF9E9
         dc 0xFFFFF206
         dc 0xFFFFECE9
         dc 0x00000C5F
         dc 0xFFFFAE8D
         dc 0x00000A77
         dc 0x00004092
         dc 0x0000920A
         dc 0x0000387B
         dc 0x00007109
         dc 0x00003826
         dc 0x00008C19
         dc 0x00000AA8
         dc 0xFFFFDAA8
         dc 0x00004266
         dc 0x00000E71
         dc 0x00000D4F
         dc 0x00000A00
         dc 0xFFFFFB8C
         dc 0x000034CD
         dc 0x00003ACA
         dc 0xFFFFDD11
         dc 0x00000670
         dc 0x00001CC1
         dc 0x00003440
         dc 0x000048A7
         dc 0x0000495E
         dc 0x00004697
         dc 0xFFFFA5BA
         dc 0xFFFFBE03
         dc 0xFFFFFE5F
         dc 0x0000023D
         dc 0x00001B51
         dc 0x00000942
         dc 0x000006CC
         dc 0x00004756
         dc 0x0000621C
         dc 0xFFFFE72B
         dc 0xFFFF99AE
         dc 0x0000084C
         dc 0x0000107F
         dc 0x000071F8
         dc 0x00003344
         dc 0xFFFFEC2D
         dc 0xFFFFECE0
         dc 0xFFFF9B04
         dc 0xFFFFC3B4
         dc 0x000017C0
         dc 0x000000CB
         dc 0x00001623
         dc 0x0000005D
         dc 0x00004776
         dc 0x000023C3
         dc 0xFFFFD94F
         dc 0xFFFF4EBE
         dc 0xFFFFC303
         dc 0x00000A86
         dc 0x00002EC5
         dc 0xFFFFFCA5
         dc 0xFFFFC029
         dc 0xFFFFC569
         dc 0xFFFFDF87
         dc 0xFFFF7A6A
         dc 0xFFFFD49C
         dc 0x000009B2
         dc 0x00001632
         dc 0x00000CD1
         dc 0x00005F79
         dc 0x00001309
         dc 0x000024F7
         dc 0xFFFFC673
         dc 0xFFFFE4DC
         dc 0xFFFFEA1A
         dc 0xFFFF922F
         dc 0xFFFFAD24
         dc 0xFFFF5630
         dc 0x000005A4
         dc 0xFFFFD804
         dc 0xFFFFCF2E
         dc 0xFFFFF3A7
         dc 0xFFFFF539
         dc 0x000000BD
         dc 0xFFFFFFCF
         dc 0x00001EAA
         dc 0x00000D4D
         dc 0x00001CB5
         dc 0x00000C49
         dc 0xFFFFB5ED
         dc 0xFFFFC39E
         dc 0xFFFFD338
         dc 0xFFFFA102
         dc 0xFFFFAEE5
         dc 0xFFFFD49F
         dc 0x00000295
         dc 0xFFFFE908
         dc 0x000016D9
         dc 0xFFFFE33E
         dc 0xFFFFFABD
         dc 0x00001B16
         dc 0x00000AE7
         dc 0xFFFFDF81
         dc 0xFFFFE7B4
         dc 0xFFFFF575
         dc 0xFFFFDF8E
         dc 0xFFFFB8AE
         dc 0xFFFFAC68
         dc 0xFFFFF1B4
         dc 0xFFFFBC08
         dc 0x00000522
         dc 0xFFFFABFF
         dc 0xFFFFDD8C
         dc 0x00001133
         dc 0x000020C5
         dc 0x00000884
         dc 0xFFFFFE60
         dc 0x0000023B
         dc 0xFFFFED0F
         dc 0xFFFFF0AE
         dc 0xFFFFDBD9
         dc 0xFFFFE249
         dc 0x0000743F
         dc 0x0000B18B
         dc 0x000044BB
         dc 0xFFFFDD53
         dc 0xFFFFA911
         dc 0xFFFFCBBB
         dc 0xFFFFF06D
         dc 0x000016FE
         dc 0x00001112
         dc 0xFFFFED91    * W1[12][0]
         dc 0xFFFFE72E
         dc 0xFFFFDED0
         dc 0x00003C02
         dc 0x00009F22
         dc 0x00006E15
         dc 0x00004338
         dc 0xFFFF9921
         dc 0x00000D72
         dc 0x0000242B
         dc 0xFFFFCC33
         dc 0xFFFFA319
         dc 0xFFFFFDCA
         dc 0x00003A3D
         dc 0x000028BE
         dc 0xFFFFFD79
         dc 0xFFFFDB0C
         dc 0xFFFFECFE
         dc 0xFFFFDCFA
         dc 0x00002A9D
         dc 0x0000079F
         dc 0x000056AF
         dc 0xFFFFE8E6
         dc 0xFFFFDCB3
         dc 0xFFFFA273
         dc 0xFFFFF001
         dc 0xFFFFE923
         dc 0xFFFFFC95
         dc 0xFFFFE898
         dc 0x00004EBA
         dc 0x00004796
         dc 0x0000065C
         dc 0xFFFFF1DC
         dc 0xFFFFC195
         dc 0xFFFF9D1D
         dc 0x0000052F
         dc 0xFFFFDBA6
         dc 0x00004CAA
         dc 0xFFFFDFC3
         dc 0x000005B1
         dc 0xFFFFF724
         dc 0xFFFFA756
         dc 0xFFFF9F58
         dc 0x00000DFB
         dc 0x00003154
         dc 0x000041B6
         dc 0x00002EEA
         dc 0x0000149E
         dc 0x000002CD
         dc 0xFFFFDE98
         dc 0xFFFFD4A0
         dc 0xFFFFF766
         dc 0xFFFFCD95
         dc 0x00003F45
         dc 0x00004AD6
         dc 0x000067CF
         dc 0x00004B98
         dc 0x00001B0B
         dc 0xFFFFEC18
         dc 0xFFFF8390
         dc 0x00001ADF
         dc 0x00002581
         dc 0x00000302
         dc 0x00001E59
         dc 0x000000D4
         dc 0x00000310
         dc 0xFFFFD5EA
         dc 0xFFFF767D
         dc 0xFFFFE601
         dc 0xFFFF714F
         dc 0xFFFFEDBA
         dc 0x00002A70
         dc 0x00005FEA
         dc 0xFFFFF405
         dc 0x00002656
         dc 0xFFFF682C
         dc 0xFFFFD5D6
         dc 0xFFFFDEF2
         dc 0xFFFFD1A6
         dc 0x00000E96
         dc 0x000024E9
         dc 0xFFFFF040
         dc 0x00006E7A
         dc 0xFFFFB940
         dc 0xFFFFE25B
         dc 0xFFFFAB30
         dc 0xFFFFEAB5
         dc 0x000002B4
         dc 0x000023AB
         dc 0x00009344
         dc 0xFFFFFD36
         dc 0xFFFF7723
         dc 0xFFFFA1AB
         dc 0xFFFFF563
         dc 0x00001BBF
         dc 0xFFFFF89F
         dc 0x00000C96
         dc 0xFFFFEC86
         dc 0xFFFFFF98
         dc 0xFFFFF5EC
         dc 0xFFFFEEB5
         dc 0xFFFF7A96
         dc 0xFFFFE85C
         dc 0xFFFFF7D8
         dc 0x00002734
         dc 0x0000636B
         dc 0x000036B2
         dc 0xFFFFD510
         dc 0xFFFFD913
         dc 0x00003FFD
         dc 0xFFFFFBC2
         dc 0x0000089E
         dc 0xFFFFF9CE
         dc 0x00000122
         dc 0x000027F9
         dc 0x0000156C
         dc 0x00004CAA
         dc 0xFFFFCA85
         dc 0x00002C2D
         dc 0x00000309
         dc 0x0000099B
         dc 0x00004EBA
         dc 0x000038A5
         dc 0xFFFFE8E0
         dc 0x00002B04
         dc 0x00003170
         dc 0x00000DA4
         dc 0xFFFFE40C
         dc 0x00000678
         dc 0x00001535
         dc 0x0000212E
         dc 0x00004893
         dc 0x00004B7A
         dc 0xFFFFB356
         dc 0xFFFFA739
         dc 0xFFFFAA02
         dc 0xFFFFF1E2
         dc 0x0000790E
         dc 0x00008CA7
         dc 0x000033A7
         dc 0x00003AA5
         dc 0xFFFFF754
         dc 0xFFFFFF6A
         dc 0x000007E3
         dc 0x00000A4B
         dc 0xFFFFFE93
         dc 0x00003C95
         dc 0x00000797
         dc 0xFFFFE99C
         dc 0xFFFFCDDB
         dc 0xFFFFA326
         dc 0xFFFFB84E
         dc 0xFFFFE182
         dc 0x00001C76
         dc 0x00003508
         dc 0x00003904
         dc 0x00002F26
         dc 0x0000098C
         dc 0x00000CD2
         dc 0x00000647
         dc 0xFFFFF4D4
         dc 0xFFFFFC74
         dc 0x00002432
         dc 0x00000F63
         dc 0xFFFFCCFD
         dc 0xFFFF6973
         dc 0xFFFFC618
         dc 0x00000477
         dc 0x00001C56
         dc 0x0000588C
         dc 0xFFFFF6FF
         dc 0xFFFFF3A7
         dc 0x00008839
         dc 0x00000F0B
         dc 0xFFFFF43D
         dc 0xFFFFFC5E
         dc 0x00000FB1
         dc 0x00000F3C
         dc 0x0000373B
         dc 0x000007AE
         dc 0xFFFFFDE9
         dc 0xFFFF78E6
         dc 0xFFFFF2AC
         dc 0x000033EB
         dc 0x0000275B
         dc 0x00009AB4
         dc 0xFFFFE490
         dc 0xFFFFB736
         dc 0xFFFF97FE
         dc 0xFFFFEC5B
         dc 0xFFFFDFE6
         dc 0x00000090
         dc 0xFFFFF2CC
         dc 0x00001BC8
         dc 0x00002280
         dc 0x00001087
         dc 0xFFFF8FC2
         dc 0xFFFFA9D1
         dc 0x00000B8E
         dc 0x0000A4B7
         dc 0x0000DA2D
         dc 0x000013A3
         dc 0xFFFFF5C6
         dc 0x000036C5
         dc 0xFFFF998C
         dc 0x00001B89
         dc 0x000002FF
         dc 0xFFFFEE92
         dc 0xFFFFDC74
         dc 0x00000364
         dc 0x00003D91
         dc 0x000036F4
         dc 0x0000222F
         dc 0xFFFFE0FD
         dc 0x000020E9
         dc 0x000012C8
         dc 0x00004E24
         dc 0x00003081
         dc 0x0000433E
         dc 0xFFFFD636
         dc 0x000011E0
         dc 0xFFFFE9BD
         dc 0xFFFFF72D
         dc 0xFFFFE4FF
         dc 0xFFFFEE50
         dc 0xFFFFFC1E
         dc 0x000015DC
         dc 0x00005911
         dc 0x00000B9C
         dc 0x00000B63
         dc 0xFFFFF155
         dc 0xFFFF91FC
         dc 0xFFFFDDD6
         dc 0xFFFFF6CA
         dc 0x00003ED2
         dc 0x000019C8
         dc 0x00004443
         dc 0xFFFFCAEA
         dc 0x00001FC1
         dc 0x0000108F
         dc 0x000007AC
         dc 0xFFFFFB76
         dc 0x0000054E
         dc 0x00004C40
         dc 0x00003319
         dc 0x00002651
         dc 0xFFFFB9A7
         dc 0xFFFFF87E
         dc 0xFFFF9EB7
         dc 0x00000D7B
         dc 0xFFFFFC09
         dc 0xFFFFE438
         dc 0x00001F25
         dc 0x0000176F
         dc 0x00000DE2
         dc 0xFFFFFC0E
         dc 0xFFFFEBB3    * W1[13][0]
         dc 0xFFFFDFD2
         dc 0xFFFFF20C
         dc 0xFFFFFCF6
         dc 0x00006FDE
         dc 0x0000453F
         dc 0xFFFFF4E9
         dc 0xFFFFEB36
         dc 0xFFFFC920
         dc 0x000081E6
         dc 0x000031FA
         dc 0xFFFFED70
         dc 0xFFFFB21C
         dc 0x0000221A
         dc 0x000026CD
         dc 0xFFFFF2FA
         dc 0xFFFFE828
         dc 0x0000028C
         dc 0x0000143D
         dc 0xFFFFF3DE
         dc 0x00003625
         dc 0xFFFFEBBB
         dc 0xFFFFE84D
         dc 0xFFFFEB5B
         dc 0x00000B69
         dc 0xFFFFBD76
         dc 0xFFFF7B57
         dc 0xFFFFDEE6
         dc 0xFFFFEF04
         dc 0xFFFFF58E
         dc 0x00003ADE
         dc 0xFFFFFF9D
         dc 0x000007DB
         dc 0xFFFFEE5F
         dc 0x0000089D
         dc 0x00001DDF
         dc 0xFFFFF009
         dc 0xFFFFEC13
         dc 0x00000D5F
         dc 0x00003E69
         dc 0x00009524
         dc 0x00000163
         dc 0xFFFF794C
         dc 0xFFFFCE76
         dc 0xFFFFEB09
         dc 0x00002E39
         dc 0x00002913
         dc 0x00003093
         dc 0xFFFFFFF7
         dc 0xFFFFEC8F
         dc 0x00001EC0
         dc 0x000014DC
         dc 0x00000924
         dc 0x00000510
         dc 0x000069A0
         dc 0x00004AC7
         dc 0x00000182
         dc 0xFFFFF672
         dc 0xFFFF9623
         dc 0xFFFFCFD5
         dc 0x000045E5
         dc 0xFFFFEA9F
         dc 0xFFFFF7DD
         dc 0xFFFFFD14
         dc 0xFFFFFB8C
         dc 0xFFFFF4E8
         dc 0xFFFFF117
         dc 0xFFFF9EC2
         dc 0x00000D99
         dc 0xFFFF9003
         dc 0xFFFFCCB8
         dc 0xFFFF94D9
         dc 0xFFFF9DCF
         dc 0x00000D60
         dc 0xFFFFEC07
         dc 0xFFFFE75C
         dc 0xFFFF9DAB
         dc 0xFFFFFECF
         dc 0xFFFFED85
         dc 0xFFFFF3EA
         dc 0xFFFFEFBC
         dc 0xFFFFF817
         dc 0xFFFFEDF7
         dc 0xFFFFDDD1
         dc 0xFFFFC34E
         dc 0xFFFF9FAA
         dc 0xFFFFBEC1
         dc 0xFFFFD4D8
         dc 0xFFFFB775
         dc 0x0000172A
         dc 0xFFFFC81E
         dc 0x00000D91
         dc 0xFFFFCC6E
         dc 0x00003718
         dc 0xFFFFED13
         dc 0x00000DD2
         dc 0x0000091D
         dc 0xFFFFFC19
         dc 0xFFFFF1A1
         dc 0xFFFFF111
         dc 0xFFFFA4E8
         dc 0xFFFFBA1B
         dc 0x000016D8
         dc 0xFFFFFF49
         dc 0xFFFFEBBB
         dc 0x00002C6A
         dc 0x00000CE4
         dc 0x00002F2C
         dc 0x00004C89
         dc 0x00007E45
         dc 0x00000B22
         dc 0x00001033
         dc 0x00000001
         dc 0xFFFFEEA7
         dc 0x00002291
         dc 0x00000784
         dc 0x00001CA7
         dc 0xFFFFCE1A
         dc 0x00003E6A
         dc 0xFFFFB0B2
         dc 0xFFFFE8AA
         dc 0x0000526D
         dc 0x000043EE
         dc 0x00000657
         dc 0x000098DE
         dc 0x0000976F
         dc 0x000006EA
         dc 0xFFFFF99A
         dc 0xFFFFF567
         dc 0xFFFFF5EC
         dc 0x00003F06
         dc 0xFFFFF76E
         dc 0xFFFFC904
         dc 0xFFFFF4DF
         dc 0xFFFFE0E8
         dc 0x000009A9
         dc 0x00002AE6
         dc 0x00006E90
         dc 0x0000444C
         dc 0x00000B92
         dc 0x0000C3CE
         dc 0x00004E78
         dc 0x00000B0E
         dc 0x0000033E
         dc 0xFFFFF170
         dc 0x0000178F
         dc 0x00006615
         dc 0x0000625B
         dc 0x00002F60
         dc 0x0000154F
         dc 0xFFFFC6A5
         dc 0xFFFFF4FA
         dc 0x00005496
         dc 0x00003749
         dc 0x0000495B
         dc 0x000027D4
         dc 0x0000A4E4
         dc 0x00000057
         dc 0xFFFFF331
         dc 0xFFFFEEF0
         dc 0x000005AC
         dc 0xFFFFFC09
         dc 0x00003E8D
         dc 0x0000A974
         dc 0xFFFFDAC4
         dc 0xFFFFF325
         dc 0x00003EE7
         dc 0x000024F3
         dc 0x00000AFC
         dc 0x0000478E
         dc 0xFFFFD0F9
         dc 0xFFFFEA72
         dc 0xFFFFF055
         dc 0xFFFFB664
         dc 0xFFFFFDBD
         dc 0xFFFFFD5C
         dc 0xFFFFF25F
         dc 0xFFFFFB7C
         dc 0x00005B0A
         dc 0x00008343
         dc 0x00004B08
         dc 0xFFFFFC80
         dc 0x00009127
         dc 0x000052B1
         dc 0x0000420C
         dc 0xFFFFD105
         dc 0xFFFFCEAC
         dc 0xFFFFC641
         dc 0xFFFF7DCB
         dc 0xFFFF8A2D
         dc 0xFFFFE627
         dc 0x00000CAC
         dc 0x00000B8D
         dc 0x0000100F
         dc 0x000032A6
         dc 0x00006A4B
         dc 0x000020EC
         dc 0x00000E91
         dc 0x000029AE
         dc 0x00005916
         dc 0x00005F6B
         dc 0xFFFFF05B
         dc 0xFFFFD3A2
         dc 0xFFFFB3D6
         dc 0xFFFF8C4A
         dc 0xFFFFB209
         dc 0xFFFFC4A9
         dc 0xFFFFFFF2
         dc 0xFFFFEDF6
         dc 0x00000359
         dc 0x0000156E
         dc 0x000063DE
         dc 0x00005769
         dc 0xFFFFBE4D
         dc 0xFFFFF861
         dc 0xFFFFC51E
         dc 0xFFFFAE75
         dc 0xFFFFE016
         dc 0xFFFFF8D3
         dc 0xFFFF858D
         dc 0x00002B11
         dc 0x00002833
         dc 0xFFFFE848
         dc 0x00000005
         dc 0xFFFFF6DD
         dc 0xFFFFEEAA
         dc 0x000006D0
         dc 0xFFFFDABF
         dc 0x00000A57
         dc 0xFFFFCD8E
         dc 0xFFFFCE06
         dc 0xFFFF53B6
         dc 0xFFFF739B
         dc 0xFFFFB419
         dc 0x00000CF9
         dc 0x00001032
         dc 0x000048DB
         dc 0x00003739
         dc 0x00004185
         dc 0x000007FA
         dc 0xFFFFF3E1
         dc 0x00000DA2
         dc 0xFFFFFFB9
         dc 0xFFFFEDB1
         dc 0x000027E9
         dc 0x00001729
         dc 0x0000097D
         dc 0xFFFF8D04
         dc 0xFFFFB925
         dc 0x00002A19
         dc 0x00002E2C
         dc 0x0000083D
         dc 0x00000EC2
         dc 0x0000343C
         dc 0x0000442B
         dc 0xFFFFF666
         dc 0x00000558    * W1[14][0]
         dc 0xFFFFFF64
         dc 0x00001A50
         dc 0x000002A8
         dc 0xFFFFDCAA
         dc 0x00000625
         dc 0x00001242
         dc 0x00002C16
         dc 0x00001368
         dc 0x000054A1
         dc 0x00003388
         dc 0xFFFFAE8F
         dc 0xFFFFD64A
         dc 0xFFFFEBFB
         dc 0xFFFFF280
         dc 0x0000059E
         dc 0x0000048A
         dc 0x000019CD
         dc 0x0000016C
         dc 0xFFFFEC77
         dc 0x00001A46
         dc 0x00000B6B
         dc 0xFFFFF955
         dc 0x00000764
         dc 0x0000582D
         dc 0x00000DB4
         dc 0x00003765
         dc 0xFFFFED17
         dc 0xFFFFFFE6
         dc 0x00001072
         dc 0x0000052B
         dc 0x00000A65
         dc 0xFFFFF605
         dc 0x000018A5
         dc 0x00003052
         dc 0x00001442
         dc 0x00001017
         dc 0xFFFFB528
         dc 0xFFFFDC13
         dc 0x000026D6
         dc 0x00003C89
         dc 0xFFFFEBC0
         dc 0x00001BF0
         dc 0x00002397
         dc 0x00001491
         dc 0xFFFFF10B
         dc 0xFFFFF1D2
         dc 0xFFFFFEF5
         dc 0x00001983
         dc 0x00000FFB
         dc 0x00003F4F
         dc 0x00001638
         dc 0xFFFFCA6B
         dc 0xFFFFA7E7
         dc 0x000006B5
         dc 0x0000465E
         dc 0x000026ED
         dc 0xFFFFD296
         dc 0x00005602
         dc 0x0000305F
         dc 0xFFFFE1A1
         dc 0xFFFFCE02
         dc 0xFFFFE935
         dc 0x000003E4
         dc 0x00000FBC
         dc 0xFFFFFD72
         dc 0x000024D5
         dc 0x00003B3E
         dc 0xFFFFDFF3
         dc 0xFFFFF017
         dc 0x00003CB7
         dc 0x00007D5B
         dc 0x0000169D
         dc 0xFFFFFDBF
         dc 0x00002FC0
         dc 0x000014E0
         dc 0xFFFFB32C
         dc 0xFFFFA606
         dc 0xFFFFE29D
         dc 0x00000B14
         dc 0xFFFFF91A
         dc 0xFFFFFFAA
         dc 0x000029D9
         dc 0x000019E3
         dc 0xFFFFD929
         dc 0x00002A44
         dc 0x00002738
         dc 0x00003C9C
         dc 0x00000087
         dc 0x000017A2
         dc 0xFFFFE514
         dc 0x000022AD
         dc 0xFFFFE5C6
         dc 0xFFFFD1B6
         dc 0xFFFFF170
         dc 0xFFFFFC6E
         dc 0x00000B0B
         dc 0xFFFFDF98
         dc 0x000020D6
         dc 0x00000B70
         dc 0xFFFFD6D7
         dc 0x00000B44
         dc 0x00000C7F
         dc 0x00001C56
         dc 0x000004DB
         dc 0xFFFFB329
         dc 0xFFFFCF4F
         dc 0x00002039
         dc 0xFFFFC83C
         dc 0xFFFFEA7C
         dc 0x000005F7
         dc 0x00001049
         dc 0xFFFFF783
         dc 0xFFFFFD59
         dc 0x000016C6
         dc 0x00000AAC
         dc 0x000003F7
         dc 0x000011D5
         dc 0x00000405
         dc 0x00000F5F
         dc 0xFFFF9F48
         dc 0xFFFF8D76
         dc 0xFFFFCAE4
         dc 0xFFFFFE17
         dc 0x00002015
         dc 0xFFFFFE56
         dc 0xFFFFF05E
         dc 0x0000065F
         dc 0x0000068E
         dc 0x00000C1B
         dc 0x00000831
         dc 0xFFFFE784
         dc 0x00001B35
         dc 0xFFFFFA4B
         dc 0xFFFFDED3
         dc 0xFFFFC1C9
         dc 0xFFFFA431
         dc 0xFFFF8234
         dc 0xFFFFBB02
         dc 0x00002F39
         dc 0x00005EE1
         dc 0xFFFFF60F
         dc 0xFFFFE9C5
         dc 0xFFFFE7F4
         dc 0x0000047C
         dc 0x000002DF
         dc 0x00000B40
         dc 0x000029D8
         dc 0x00001FF5
         dc 0xFFFFAB4C
         dc 0xFFFFD836
         dc 0xFFFF9CEC
         dc 0xFFFFB988
         dc 0xFFFFEDA1
         dc 0xFFFFDC92
         dc 0x0000377E
         dc 0x0000366F
         dc 0x0000152D
         dc 0xFFFFFFD7
         dc 0x0000062A
         dc 0x0000189B
         dc 0x00000389
         dc 0x00004F81
         dc 0x00004B31
         dc 0xFFFF936A
         dc 0xFFFF8BEC
         dc 0xFFFFE290
         dc 0xFFFFE8C9
         dc 0xFFFFDBAE
         dc 0x00000457
         dc 0x00002D30
         dc 0x0000722B
         dc 0x000029AD
         dc 0x00001E80
         dc 0xFFFFEF47
         dc 0xFFFFFCB5
         dc 0xFFFFF3C1
         dc 0x00002365
         dc 0x00004F2F
         dc 0x00003F9B
         dc 0xFFFFB10B
         dc 0xFFFF5427
         dc 0xFFFFE7EE
         dc 0xFFFF7F55
         dc 0xFFFFCDD7
         dc 0x000049A6
         dc 0x000033B6
         dc 0x00004C5D
         dc 0x00000374
         dc 0xFFFFE11C
         dc 0x00002085
         dc 0xFFFFEF10
         dc 0x00001F03
         dc 0x0000125B
         dc 0x00006CE8
         dc 0x00004211
         dc 0x00000A6E
         dc 0xFFFFB571
         dc 0xFFFF9DC2
         dc 0xFFFFE252
         dc 0x0000115C
         dc 0x0000327C
         dc 0x000031F8
         dc 0x000059D4
         dc 0x00001CA1
         dc 0xFFFFDB11
         dc 0x000001C0
         dc 0x000021A5
         dc 0x00000F5D
         dc 0xFFFFFD30
         dc 0x0000198B
         dc 0x00004A2E
         dc 0x00001E9E
         dc 0x00000D93
         dc 0xFFFFEDDD
         dc 0x00001BEC
         dc 0x00002A36
         dc 0x00002F3E
         dc 0xFFFFFF23
         dc 0xFFFFF84C
         dc 0xFFFFDB65
         dc 0xFFFFF79A
         dc 0x00000725
         dc 0xFFFFED99
         dc 0xFFFFFA5C
         dc 0xFFFFFC8C
         dc 0x000002A3
         dc 0x00003169
         dc 0x00004479
         dc 0x000044DC
         dc 0xFFFFE2A2
         dc 0xFFFFB519
         dc 0x000013BE
         dc 0x000022AC
         dc 0xFFFFB463
         dc 0xFFFFC9B0
         dc 0xFFFFB087
         dc 0xFFFFBEE3
         dc 0x000004E3
         dc 0xFFFFE4DD
         dc 0x00000525
         dc 0xFFFFED28
         dc 0xFFFFF223
         dc 0x000009F0
         dc 0x00005145
         dc 0x00004A4F
         dc 0x000047E7
         dc 0x000061DC
         dc 0x00003A84
         dc 0x00004606
         dc 0xFFFFB5E4
         dc 0xFFFFA9A7
         dc 0xFFFFB3D7
         dc 0xFFFFD4A6
         dc 0xFFFFE3D6
         dc 0xFFFFFFE2
         dc 0x000005FF    * W1[15][0]
         dc 0xFFFFFA23
         dc 0x00000EEB
         dc 0xFFFFF62C
         dc 0x000049D1
         dc 0x000064FA
         dc 0xFFFFE218
         dc 0xFFFFE60C
         dc 0xFFFF9F90
         dc 0x00000A35
         dc 0x0000267B
         dc 0x00005BB4
         dc 0x00003E14
         dc 0x000045E9
         dc 0x00005503
         dc 0x000005CA
         dc 0xFFFFFF0E
         dc 0xFFFFF82A
         dc 0x00000A68
         dc 0xFFFFFD6A
         dc 0x000007AD
         dc 0x00006DF3
         dc 0x000060AC
         dc 0xFFFFED06
         dc 0xFFFFF67F
         dc 0x00005954
         dc 0x00004216
         dc 0x00005ADD
         dc 0x0000692B
         dc 0x00005195
         dc 0x0000472E
         dc 0x000021CC
         dc 0x0000131E
         dc 0xFFFFF43C
         dc 0x0000327B
         dc 0x00002981
         dc 0x00004239
         dc 0x0000958F
         dc 0x00004000
         dc 0x0000167C
         dc 0x00008795
         dc 0x00003485
         dc 0x00006E62
         dc 0x00002E86
         dc 0xFFFFDAC4
         dc 0x0000023F
         dc 0x000009E4
         dc 0x00000728
         dc 0xFFFFFE8C
         dc 0x00001305
         dc 0x00004D07
         dc 0xFFFFE57F
         dc 0xFFFFE3E2
         dc 0x00002E6C
         dc 0x00007877
         dc 0x00007FB2
         dc 0x00000E1B
         dc 0x000041B7
         dc 0xFFFFFB2C
         dc 0xFFFFAE0E
         dc 0xFFFFB6CF
         dc 0xFFFFD67E
         dc 0xFFFFE5A8
         dc 0xFFFFE07F
         dc 0xFFFFFBFF
         dc 0xFFFFFF75
         dc 0xFFFFEE59
         dc 0xFFFFFD8A
         dc 0xFFFFD4E0
         dc 0x00002874
         dc 0x000032CC
         dc 0xFFFFA5AA
         dc 0xFFFF85E6
         dc 0xFFFFD472
         dc 0xFFFF8CAD
         dc 0xFFFFB24B
         dc 0xFFFF81B9
         dc 0xFFFF9E3D
         dc 0xFFFFE049
         dc 0x0000014A
         dc 0xFFFFF449
         dc 0xFFFFECC5
         dc 0xFFFFCE50
         dc 0x00000A03
         dc 0x00000C31
         dc 0x000015FD
         dc 0xFFFFF9CA
         dc 0xFFFFA36A
         dc 0xFFFFDBCE
         dc 0xFFFFF4B9
         dc 0xFFFFF2A9
         dc 0xFFFFAD8D
         dc 0x000007C9
         dc 0x000008BC
         dc 0x00000283
         dc 0x00001418
         dc 0x000012BE
         dc 0xFFFFE5BC
         dc 0xFFFFED4B
         dc 0xFFFFFF3D
         dc 0x00003A70
         dc 0x000020E4
         dc 0xFFFFD3EA
         dc 0xFFFFAC29
         dc 0xFFFFDFD9
         dc 0xFFFFBBD5
         dc 0xFFFFBB18
         dc 0x0000348E
         dc 0xFFFFBEC5
         dc 0xFFFFFBD2
         dc 0x00000FE0
         dc 0x00000605
         dc 0xFFFFE90E
         dc 0xFFFFF1BF
         dc 0xFFFFDC68
         dc 0x00000126
         dc 0x00005FB7
         dc 0x000034CC
         dc 0xFFFFAACC
         dc 0xFFFF8F90
         dc 0xFFFFB445
         dc 0xFFFFF70A
         dc 0xFFFFB94B
         dc 0xFFFFFBA3
         dc 0x0000145C
         dc 0xFFFFC8BC
         dc 0x00000D11
         dc 0xFFFFEF93
         dc 0x00000832
         dc 0x00001816
         dc 0xFFFFE59E
         dc 0x00005BD7
         dc 0x00005BB0
         dc 0xFFFFE4D8
         dc 0xFFFFBE03
         dc 0x00000661
         dc 0xFFFFFE87
         dc 0xFFFFD8DF
         dc 0xFFFFC9FE
         dc 0xFFFFE420
         dc 0x00004E59
         dc 0x0000125D
         dc 0x00001A5D
         dc 0xFFFFFB0F
         dc 0xFFFFE585
         dc 0xFFFFEF97
         dc 0xFFFFF835
         dc 0x00000B6D
         dc 0x000012BC
         dc 0xFFFF9263
         dc 0x00000134
         dc 0xFFFFE472
         dc 0x000047A9
         dc 0xFFFFD088
         dc 0xFFFFAD99
         dc 0xFFFFD89E
         dc 0x0000552E
         dc 0x000022E0
         dc 0x000008D1
         dc 0xFFFFF212
         dc 0x00000DA2
         dc 0x000004F7
         dc 0xFFFFF6B5
         dc 0xFFFFEE5D
         dc 0xFFFFC591
         dc 0xFFFF8ABD
         dc 0xFFFFD7F7
         dc 0xFFFFEDF2
         dc 0x000013FE
         dc 0xFFFFE588
         dc 0xFFFFC080
         dc 0x00000B89
         dc 0x000037CF
         dc 0x00004864
         dc 0xFFFFF7FA
         dc 0x0000018E
         dc 0x00000EA4
         dc 0xFFFFF3AF
         dc 0xFFFFE7AE
         dc 0xFFFFE6C6
         dc 0xFFFFDD20
         dc 0xFFFFB30F
         dc 0xFFFF9C85
         dc 0xFFFFB54E
         dc 0xFFFF82A8
         dc 0xFFFFE44E
         dc 0xFFFFA9E6
         dc 0xFFFFF7DA
         dc 0x000011E7
         dc 0x00006041
         dc 0x00000724
         dc 0x0000048F
         dc 0xFFFFF425
         dc 0xFFFFF51E
         dc 0xFFFFDFD8
         dc 0xFFFFDB43
         dc 0x0000241D
         dc 0x00001245
         dc 0xFFFFA719
         dc 0xFFFF99F0
         dc 0xFFFFDAB3
         dc 0xFFFFE311
         dc 0xFFFFE0B8
         dc 0xFFFFD45B
         dc 0xFFFFE618
         dc 0x0000508D
         dc 0xFFFFE57A
         dc 0x0000037E
         dc 0xFFFFFA14
         dc 0xFFFFF1F6
         dc 0xFFFFFE3C
         dc 0xFFFFE4FB
         dc 0xFFFFEF0A
         dc 0x00003357
         dc 0x000048C8
         dc 0x000006E3
         dc 0xFFFFC535
         dc 0x0000005A
         dc 0xFFFFF66A
         dc 0xFFFFB1F3
         dc 0xFFFFDDD2
         dc 0x000029E0
         dc 0xFFFFED89
         dc 0xFFFFFD9E
         dc 0xFFFFFED6
         dc 0xFFFFF37F
         dc 0xFFFFFD59
         dc 0x0000074C
         dc 0xFFFFE1B3
         dc 0x000012A2
         dc 0x0000747C
         dc 0x00001E4E
         dc 0xFFFFEAC8
         dc 0xFFFFD61A
         dc 0xFFFFC420
         dc 0xFFFF855C
         dc 0x00000292
         dc 0xFFFFBA2B
         dc 0xFFFFB034
         dc 0x00000AFA
         dc 0xFFFFFB49
         dc 0xFFFFF43F
         dc 0x00000A5E
         dc 0xFFFFFCAC
         dc 0x000024E6
         dc 0xFFFFEAEA
         dc 0x00002ED5
         dc 0xFFFFFA41
         dc 0xFFFFE1CE
         dc 0xFFFFEC5E
         dc 0x000004E8
         dc 0xFFFFF5EC
         dc 0xFFFFBFE2
         dc 0xFFFFC24F
         dc 0xFFFFD112
         dc 0xFFFFEB2C
B1DATA:  dc 0xFFFF94C7    * b1[0]
         dc 0xFFFFF090    * b1[1]
         dc 0xFFFFFF74    * b1[2]
         dc 0xFFFF95DE    * b1[3]
         dc 0x00000E8F    * b1[4]
         dc 0xFFFFD436    * b1[5]
         dc 0x00002AEC    * b1[6]
         dc 0xFFFFD301    * b1[7]
         dc 0xFFFFED2B    * b1[8]
         dc 0xFFFFEA16    * b1[9]
         dc 0x00002C50    * b1[10]
         dc 0xFFFFDBAC    * b1[11]
         dc 0x00003278    * b1[12]
         dc 0x00009CF3    * b1[13]
         dc 0x00000A6A    * b1[14]
         dc 0x0000019D    * b1[15]
W2DATA:  dc 0xFFFDE3BD    * W2[0][0]  (10x16 row-major)
         dc 0x000139DF
         dc 0x0000DC04
         dc 0xFFFF5700
         dc 0x0002112E
         dc 0xFFFF04DF
         dc 0xFFFEDBA9
         dc 0x0001A844
         dc 0xFFFF1E07
         dc 0xFFFF0D2C
         dc 0xFFFEB895
         dc 0xFFFE3306
         dc 0xFFFF6668
         dc 0xFFFFCD6F
         dc 0x00016AF3
         dc 0x0000D92D
         dc 0x0002230D    * W2[1][0]
         dc 0x00027254
         dc 0xFFFCDAD7
         dc 0x0001BF98
         dc 0xFFFFE17B
         dc 0x0001A511
         dc 0x0001E429
         dc 0xFFFE9179
         dc 0xFFFD3C8B
         dc 0xFFFF8859
         dc 0xFFFFF9C3
         dc 0x000043D6
         dc 0x000168D7
         dc 0xFFFF6AD3
         dc 0xFFFF5764
         dc 0xFFFF4938
         dc 0x000170A0    * W2[2][0]
         dc 0xFFFEB947
         dc 0xFFFE8C02
         dc 0xFFFD659E
         dc 0xFFFFAE59
         dc 0xFFFE40F7
         dc 0xFFFD1AF6
         dc 0x0001F97A
         dc 0xFFFEF68C
         dc 0xFFFFD8A0
         dc 0x0001F5B7
         dc 0xFFFFFF9F
         dc 0xFFFFF9E5
         dc 0x0000AA79
         dc 0xFFFF5E2D
         dc 0xFFFEB0B9
         dc 0x00005DFE    * W2[3][0]
         dc 0xFFFEF176
         dc 0x00010734
         dc 0x000067B4
         dc 0xFFFF379E
         dc 0x000257B6
         dc 0xFFFEE2C8
         dc 0x0000BF38
         dc 0x000295BB
         dc 0xFFFE7B0F
         dc 0x000257B8
         dc 0x0000CCEB
         dc 0x00014D33
         dc 0xFFFE6AA2
         dc 0x000127BC
         dc 0xFFFF4369
         dc 0xFFFDC640    * W2[4][0]
         dc 0x00020CB3
         dc 0xFFFF7BE6
         dc 0xFFFF21DA
         dc 0x00017FE6
         dc 0xFFFF5F2D
         dc 0x00013F31
         dc 0xFFFD48FC
         dc 0xFFFFE8A1
         dc 0x00015AEF
         dc 0xFFFEA4F3
         dc 0x0000DE92
         dc 0x00019099
         dc 0x000342C4
         dc 0x00020A22
         dc 0xFFFED6B4
         dc 0x0000A16D    * W2[5][0]
         dc 0xFFFDAA28
         dc 0x0000C1C3
         dc 0x00008E1E
         dc 0xFFFF0B6C
         dc 0xFFFE2849
         dc 0x00018E12
         dc 0xFFFE571C
         dc 0xFFFF6DC0
         dc 0x00010BE8
         dc 0x0001DB7C
         dc 0xFFFE4239
         dc 0xFFFFC6E9
         dc 0xFFFEC60B
         dc 0x0001D69F
         dc 0x00036A5F
         dc 0xFFFEA28B    * W2[6][0]
         dc 0x000143B6
         dc 0xFFFE509E
         dc 0xFFFEA5D9
         dc 0xFFFF8A69
         dc 0xFFFF6B58
         dc 0x0000D573
         dc 0xFFFFA0F1
         dc 0x0002123E
         dc 0xFFFE96B4
         dc 0x000034B9
         dc 0xFFFD4A81
         dc 0xFFFEF431
         dc 0x000012E0
         dc 0xFFFD8D09
         dc 0xFFFFB5E4
         dc 0xFFFE40F2    * W2[7][0]
         dc 0xFFFE47F6
         dc 0x00015DC9
         dc 0x000056ED
         dc 0xFFFED246
         dc 0x00024BB3
         dc 0x00010E29
         dc 0x00016669
         dc 0xFFFF9FFD
         dc 0xFFFFC68E
         dc 0xFFFE8986
         dc 0x0000C64D
         dc 0x0000EDFB
         dc 0x00025B8E
         dc 0xFFFE590E
         dc 0x0000B5FC
         dc 0x00021D4A    * W2[8][0]
         dc 0x000241F2
         dc 0x0001FA58
         dc 0xFFFFB49C
         dc 0xFFFEAFF7
         dc 0xFFFE4C4B
         dc 0x0000D6EF
         dc 0x0001389B
         dc 0x0001DCA1
         dc 0x000110EB
         dc 0xFFFE6801
         dc 0x00016197
         dc 0xFFFE3697
         dc 0xFFFFF3B1
         dc 0xFFFFEFDC
         dc 0xFFFEF28E
         dc 0x00005CF2    * W2[9][0]
         dc 0xFFFD6C6B
         dc 0x00012969
         dc 0x0002BD84
         dc 0x00030D97
         dc 0x0000F701
         dc 0xFFFEC450
         dc 0xFFFF5653
         dc 0xFFFF3341
         dc 0x000280ED
         dc 0xFFFEBCD3
         dc 0x00028392
         dc 0xFFFE94AC
         dc 0xFFFE89E3
         dc 0x00000DE7
         dc 0xFFFF5CA7
B2DATA:  dc 0x00004206    * b2[0]
         dc 0xFFFFD3C1    * b2[1]
         dc 0x00003E5A    * b2[2]
         dc 0x00000E3B    * b2[3]
         dc 0x0000075C    * b2[4]
         dc 0x000090CA    * b2[5]
         dc 0xFFFFC34F    * b2[6]
         dc 0x00000EB4    * b2[7]
         dc 0xFFFF438C    * b2[8]
         dc 0xFFFFEFEE    * b2[9]
A1:      ds 16                * hidden activations
Z2:      ds 10                * output logits
PROB:    ds 10                * softmax probabilities (hw)
PRED:    ds 1                 * <-- predicted digit lands here
cFFFF:   dc 0x0000FFFF        * low-16 mask (needs a reg; imm would sign-extend)
cONE:    dc 0x00010000        * +1.0
cNEG1:   dc 0xFFFF0000        * -1.0
cX5:     dc 0x00050000        * 5.0
cX2375:  dc 0x00026000        * 2.375
cX1125:  dc 0x00012000        * 1.125
cX0875:  dc 0x0000E000        * 0.875
cB2732:  dc 0x0000D800        * 0.84375
cB58:    dc 0x0000A000        * 0.625
cBTAY:   dc 0x00009B27        * 0.6060586
cB12:    dc 0x00008000        * 0.5

* ----------------------------- CODE -----------------------------
main:    lw   R19 R0 cFFFF     * R19 = 0x0000FFFF (low-16 mask)
        addi R17 R0 0x1       * R17 = 1 (bit test)
        addi R7 R0 mulq16     * R7 = software-multiply address
        addi R8 R0 tanhsub    * R8 = activation subroutine address
* ---- Layer 1: A1[h] = act( b1[h] + sum_i W1[h][i]*IMG[i] ) ----
        addi R20 R0 W1DATA    * weight ptr (row-major, runs continuously)
        addi R21 R0 B1DATA    * bias ptr
        addi R22 R0 A1        * output ptr
        addi R23 R0 0x10       * hidden-neuron counter
l1n:     lw   R24 R21 0x0      * acc = b1[h]
        addi R25 R0 IMG       * input ptr (reset per neuron)
        addi R26 R0 0x100      * input counter = 256
l1d:     lw   R1 R20 0x0       * A = W1[h][i]
        lw   R2 R25 0x0       * B = IMG[i]
        jalr R7               * R3 = mulq16(A,B) = (A*B)>>16
        add  R24 R24 R3       * acc += product
        addi R20 R20 0x1
        addi R25 R25 0x1
        addi R26 R26 0xFFFF
        bnez R26 l1d
        add  R1 R24 R0        * arg = acc
        jalr R8               * R2 = act(acc)
        sw   R2 R22 0x0       * A1[h] = act(acc)
        addi R21 R21 0x1
        addi R22 R22 0x1
        addi R23 R23 0xFFFF
        bnez R23 l1n
* ---- Layer 2: Z2[k] = b2[k] + sum_h W2[k][h]*A1[h]  (no activation) ----
        addi R20 R0 W2DATA
        addi R21 R0 B2DATA
        addi R22 R0 Z2
        addi R23 R0 0xA       * 10 output neurons
l2n:     lw   R24 R21 0x0      * acc = b2[k]
        addi R25 R0 A1        * hidden ptr (reset per neuron)
        addi R26 R0 0x10       * hidden counter = H
l2d:     lw   R1 R20 0x0       * A = W2[k][h]
        lw   R2 R25 0x0       * B = A1[h]
        jalr R7               * R3 = mulq16(A,B)
        add  R24 R24 R3
        addi R20 R20 0x1
        addi R25 R25 0x1
        addi R26 R26 0xFFFF
        bnez R26 l2d
        sw   R24 R22 0x0      * Z2[k] = acc (logit)
        addi R21 R21 0x1
        addi R22 R22 0x1
        addi R23 R23 0xFFFF
        bnez R23 l2n

* ---- argmax over Z2[0..9] -> PRED (first max on ties) ----
        addi R25 R0 Z2
        lw   R22 R25 0x0       * best = src[0]
        addi R23 R0 0x0        * bestIdx = 0
        addi R24 R0 0x0        * idx = 0
        addi R26 R0 0xA        * count = 10
amlp:    lw   R5 R25 0x0
        sub  R6 R5 R22        * src[idx] - best
        slei R6 R6 0x0000     * src[idx] <= best ?
        bnez R6 amsk          * not strictly greater -> keep
        add  R22 R5 R0        * best = src[idx]
        add  R23 R24 R0       * bestIdx = idx
amsk:    addi R25 R25 0x1
        addi R24 R24 0x1
        addi R26 R26 0xFFFF
        bnez R26 amlp
        addi R5 R0 PRED
        sw   R23 R5 0x0       * PRED = bestIdx
        halt

* ============================================================
* mulq16 - EXACT Q16.16 signed multiply, baseline ISA only.
*   in : R1 = A, R2 = B      out: R3 = (A*B) >> 16
*   result = bits [47:16] of the 64-bit signed product, matching
*   the hardware `mult` opcode bit-for-bit (verified in Python).
*   Method (all shifts are logical srli/slli):
*     sign-magnitude; a=|A|,b=|B|; split into 16-bit halves
*     ah:al, bh:bl;  (a*b)>>16 = (ah*bh<<16)+ah*bl+al*bh+(al*bl>>16)
*     then floor-correct for a negative result and re-apply sign.
*   reserved regs: R17 = 1, R19 = 0x0000FFFF.  ret via R31.
*   clobbers R1,R2,R4,R5,R6,R9-R16.  Leaves R17,R19,R20-R26 intact.
* ============================================================
mulq16:  addi R12 R0 0x0        * R12 = count of negative operands
        slti R6 R1 0x0000
        beqz R6 mqa
        sub  R1 R0 R1          * a = |A|
        addi R12 R12 0x1
mqa:     slti R6 R2 0x0000
        beqz R6 mqb
        sub  R2 R0 R2          * b = |B|
        addi R12 R12 0x1
mqb:     and  R5 R1 R19         * al = a & 0xFFFF
        and  R10 R2 R19        * bl = b & 0xFFFF
        add  R4 R1 R0          * R4 = a
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        srli R4 R4             * (x16) ah = a >> 16
        add  R9 R2 R0          * R9 = b
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
        srli R9 R9             * (x16) bh = b >> 16
* four unsigned 16x16 partial products
        add  R14 R0 R0        * uhh: acc = 0
        add  R6 R4 R0          * tmpx = multiplicand
        add  R11 R9 R0         * m = multiplier (copy)
uhh:   beqz R11 uhhd        * while m != 0
        and  R13 R11 R17        * bit = m & 1
        beqz R13 uhhs
        add  R14 R14 R6     * acc += tmpx
uhhs:  slli R6 R6             * tmpx <<= 1
        srli R11 R11           * m >>= 1
        beqz R0 uhh          * loop
uhhd:   addi R0 R0 0x0        * umul done (landing pad)
        add  R15 R0 R0        * uab: acc = 0
        add  R6 R4 R0          * tmpx = multiplicand
        add  R11 R10 R0         * m = multiplier (copy)
uab:   beqz R11 uabd        * while m != 0
        and  R13 R11 R17        * bit = m & 1
        beqz R13 uabs
        add  R15 R15 R6     * acc += tmpx
uabs:  slli R6 R6             * tmpx <<= 1
        srli R11 R11           * m >>= 1
        beqz R0 uab          * loop
uabd:   addi R0 R0 0x0        * umul done (landing pad)
        add  R16 R0 R0        * ualh: acc = 0
        add  R6 R5 R0          * tmpx = multiplicand
        add  R11 R9 R0         * m = multiplier (copy)
ualh:   beqz R11 ualhd        * while m != 0
        and  R13 R11 R17        * bit = m & 1
        beqz R13 ualhs
        add  R16 R16 R6     * acc += tmpx
ualhs:  slli R6 R6             * tmpx <<= 1
        srli R11 R11           * m >>= 1
        beqz R0 ualh          * loop
ualhd:   addi R0 R0 0x0        * umul done (landing pad)
        add  R3 R0 R0        * uabl: acc = 0
        add  R6 R5 R0          * tmpx = multiplicand
        add  R11 R10 R0         * m = multiplier (copy)
uabl:   beqz R11 uabld        * while m != 0
        and  R13 R11 R17        * bit = m & 1
        beqz R13 uabls
        add  R3 R3 R6     * acc += tmpx
uabls:  slli R6 R6             * tmpx <<= 1
        srli R11 R11           * m >>= 1
        beqz R0 uabl          * loop
uabld:   addi R0 R0 0x0        * umul done (landing pad)
* combine:  R9 = rem (low 16 of albl), then t = hh<<16 + ahbl + albh + albl>>16
        and  R9 R3 R19         * rem = albl & 0xFFFF (for floor correction)
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        srli R3 R3             * (x16) albl >> 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        slli R14 R14           * (x16) hh << 16
        add  R14 R14 R15       * + ahbl
        add  R14 R14 R16       * + albh
        add  R3 R14 R3         * R3 = |t| (truncated magnitude)
        seqi R6 R12 0x1        * exactly one negative operand?
        beqz R6 mqret          * positive result -> done
        beqz R9 mqneg          * rem == 0 -> no floor correction
        addi R3 R3 0x1         * floor(neg) = -(t+1) when remainder
mqneg:   sub  R3 R0 R3          * apply sign: R3 = -t
mqret:   jr   R31

* ============================================================
* tanhsub - R2 = tanh(R1) = clamp(2*sigma0(2*R1) - 1), Q16.16.
*   sigma0 is the shift-only 5-segment PWL sigmoid, inlined.
*   ret R31; clobbers R1,R3,R5,R6.  Matches the tanh opcode exactly.
* ============================================================
tanhsub: slli R1 R1             * z = 2*x
        addi R3 R0 0x0000      * sign = 0
        slti R5 R1 0x0000
        beqz R5 thpos
        sub  R1 R0 R1          * z = -z
        addi R3 R0 0x0001      * sign = 1
thpos:   lw   R6 R0 cX5
        sub  R5 R1 R6
        slti R5 R5 0x0000      * z < 5.0 ?
        bnez R5 thseg2
        lw   R2 R0 cONE        * sigma = 1.0
        beqz R0 thsign
thseg2:  lw   R6 R0 cX2375
        sub  R5 R1 R6
        slti R5 R5 0x0000      * z < 2.375 ?
        bnez R5 thseg3
        srli R2 R1
        srli R2 R2
        srli R2 R2
        srli R2 R2
        srli R2 R2             * z >> 5
        lw   R6 R0 cB2732
        add  R2 R2 R6          * + 0.84375
        beqz R0 thsign
thseg3:  lw   R6 R0 cX1125
        sub  R5 R1 R6
        slti R5 R5 0x0000      * z < 1.125 ?
        bnez R5 thseg4
        srli R2 R1
        srli R2 R2
        srli R2 R2             * z >> 3
        lw   R6 R0 cB58
        add  R2 R2 R6          * + 0.625
        beqz R0 thsign
thseg4:  lw   R6 R0 cX0875
        sub  R5 R1 R6
        slti R5 R5 0x0000      * z < 0.875 ?
        bnez R5 thseg5
        srli R2 R1
        srli R2 R2
        srli R2 R2             * z >> 3
        lw   R6 R0 cBTAY
        add  R2 R2 R6          * + 0.6060586
        beqz R0 thsign
thseg5:  srli R2 R1
        srli R2 R2             * z >> 2
        lw   R6 R0 cB12
        add  R2 R2 R6          * + 0.5
thsign:  beqz R3 thpost
        lw   R6 R0 cONE
        sub  R2 R6 R2          * sigma = 1 - sigma
thpost:  slli R2 R2             * 2*sigma
        lw   R6 R0 cONE
        sub  R2 R2 R6          * 2*sigma - 1
        lw   R6 R0 cONE
        sub  R5 R2 R6
        slei R5 R5 0x0000      * out <= 1.0 ?
        bnez R5 thclo
        lw   R2 R0 cONE        * clamp +1
        beqz R0 thret
thclo:   lw   R6 R0 cNEG1
        sub  R5 R2 R6
        sgei R5 R5 0x0000      * out >= -1.0 ?
        bnez R5 thret
        lw   R2 R0 cNEG1       * clamp -1
thret:   jr   R31
