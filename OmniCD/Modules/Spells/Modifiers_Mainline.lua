local E = select(2, ...):unpack()

E.spell_cdmod_talents = {

	[48707]	= { 205727,	20,	410320,	10,	457574,	-20	},
	[51052]	= { 374383,	60	},
	[48792]	= { 373926,	60	},
	[108199]	= { 206970,	30	},
	[275699]	= { 288848,	15,	},
	[46585]	= { 46584,	90,	437122,	30	},
	[439843]	= { 469870,	15	},
	[49039]	= { 437122,	30	},
	[51271]	= { 1218603,	-15	},
	[43265]	= { 444099,	5	},

	[191427]	= { 320421,	{30,60}	},
	[187827]	= { 320421,	{30,60}	},
	[207684]	= { 320418,	30	},
	[204596]	= { 428557,	5	},
	[196718]	= { 389783,	120	},
	[198793]	= { 389688,	5	},
	[189110]	= { 389724,	10	},
	[205629]	= { 389724,	10	},
	[204021]	= { 389732,	12	},
	[204157]	= { 320387,	6	},
	[372048]	= { 374346,	30	},
	[188501]	= { 389849,	5	},

	[106898]	= { 288826,	60,	},
	[102342]	= { 382552,	20	},
	[740]	= { 197073,	30	},
	[132158]	= { 382550,	12	},
	[194223]	= { 390378,	60,	468743,	{429420,90,80}	},
	[102560]	= { 390378,	60,	468743,	{429420,90,80}	},
	[202770]	= { 394121,	15	},
	[274837]	= { 441846,	10,	},
	[80313]	= { 441846,	10	},
	[205636]	= { 428937,	15	},
	[102693]	= { 428937,	3	},
	[197626]	= { 451211,	4	},
	[106951]	= { 391174,	60	},
	[102543]	= { 391174,	60	},
	[102351]	= { 470549,	10	},
	[132469]	= { 400140,	5	},
	[377847]	= { 1213597,	30	},

	[358385]	= { 375528,	30,	408543,	15	},
	[357214]	= { 368838,	120	},
	[368970]	= { 375443,	120	},
	[363534]	= { 381922,	120	},
	[374348]	= { 375577,	30	},
	[357210]	= { 386348,	60	},
	[371032]	= { 386348,	60	},
	[351338]	= { 371016,	20	},
	[359073]	= { 411164,	3,	453675,	{5,pvp=0.5}	},
	[355913]	= { 414969,	30	},
	[358267]	= { 429483,	5	},
	[357170]	= { 376204,	10	},
	[370553]	= { 1236368,	60	},

	[357208]	= { 431484,	3	},
	[396286]	= { 431484,	3	},
	[355936]	= { 431484,	3	},
	[367226]	= { 431484,	3,	376150,	10	},

	[264735]	= { 388039,	30	},
	[147362]	= { 388039,	2	},
	[187707]	= { 388039,	2	},
	[186257]	= { 266921,	30	},
	[186289]	= { 266921,	30	},
	[186265]	= { 266921,	30	},
	[187698]	= { 343247,	5	},
	[236776]	= { 343247,	5	},
	[187650]	= { 343247,	5	},
	[259495]	= { 378937,	{1,2}	},
	[190925]	= { 265895,	10	},
	[34477]	= { 248518,	-15,	459546,	5	},
	[19577]	= { 459507,	10	},
	[474421]	= { 459507,	10	},
	[360966]	= { 378962,	30	},
	[360952]	= { 459875,	60	},
	[53351]	= { 321460,	2	},
	[288613]	= { 1236370,	30	},
	[359844]	= { 1236370,	60	},

	[157981]	= { 389627,	5	},
	[1953]	= { 382268,	{2,4,pvp=0.5}	},
	[212653]	= { 382268,	{2,4}	},
	[342245]	= { 342249,	10	},
	[45438]	= { 382424,	{30,60}	},
	[414658]	= { 382424,	{30,60}	},
	[319836]	= { 387044,	2	},
	[110959]	= { 210476,	45	},
	[414664]	= { 415945,	240	},
	[153561]	= { 416719,	10	},

	[205523]	= { 387230,	1	},
	[115203]	= { 388813,	{[268]=120,[269]=30,[270]=30}	},
	[109132]	= { 449582,	-2,	115173,	5	},
	[115008]	= { 449582,	-2	},
	[115078]	= { 344359,	{8,15}	},
	[119381]	= { 344359,	{5,10}	},
	[322109]	= { 394123,	90	},
	[322118]	= { 388212,	60	},
	[325197]	= { 388212,	60	},
	[116849]	= { 202424,	45	},
	[388193]	= { 406888,	10	},
	[116844]	= { 450448,	5	},
	[392983]	= { 451576,	10	},
	[152175]	= { 451524,	5	},
	[123904]	= { 392986,	30	},
	[132578]	= { 387219,	{30,60}	},

	[375576]	= { 379391,	15	},
	[31821]	= { 392911,	30,	199324,	60	},
	[6940]	= { 384820,	{[65]=15,[66]=60,[70]=60}	},
	[199448]	= { 384820,	15	},
	[1022]	= { 384909,	60	},
	[204018]	= { 384909,	60	},
	[20271]	= { 383228,	2,	},
	[35395]	= { 383228,	2	},
	[407480]	= { 383228,	2	},
	[184575]	= { 404436,	2	},
	[20066]	= { 469325,	15	},
	[115750]	= { 469325,	15	},
	[853]	= { 234299,	15	},

	[194509]	= { 390684,	3	},
	[586]	= { 390670,	{5,10}	},
	[15286]	= { 199855,	30	},
	[8122]	= { 196704,	15	},
	[32375]	= { 426438,	60	},
	[73325]	= { 390620,	30	},
	[15487]	= { 263716,	15	},
	[47585]	= { 288733,	30	},
	[19236]	= { 238100,	20	},
	[428933]	= { 440661,	15	},
	[451235]	= { 123040,	60,	200174,	60	},
	[373481]	= { 440674,	3	},
	[64843]	= { 419110,	60	},
	[88625]	= { 1215275,	15	},
	[34861]	= { 1215275,	15	},
	[2050]	= { 1215275,	15	},

	[2983]	= { 231691,	60	},
	[195457]	= { 256188,	15,	454433,	-5	},
	[212283]	= { 394309,	5	},
	[1725]	= { 441429,	-60	},

	[188389]	= { 378266,	1.5	},

	[108271]	= { 381647,	30	},
	[79206]	= { 192088,	30	},
	[51514]	= { 204268,	15	},
	[108285]	= { 383011,	60	},
	[60103]	= { 334033,	6	},
	[383013]	= { 381867,	6	},
	[192222]	= { 381867,	6	},
	[157153]	= { 381867,	6	},
	[5394]	= { 381867,	6	},
	[198838]	= { 381867,	6	},
	[51485]	= { 381867,	6	},
	[192077]	= { 381867,	6,	462791,	30	},
	[192058]	= { 381867,	6	},
	[355580]	= { 381867,	6	},
	[204331]	= { 381867,	6	},
	[204336]	= { 381867,	6	},
	[2484]	= { 381867,	6	},
	[8143]	= { 381867,	6	},
	[383019]	= { 381867,	6	},
	[108280]	= { 381867,	6,	353115,	60,	404015,	30	},
	[98008]	= { 381867,	6	},
	[207399]	= { 381867,	6	},
	[108270]	= { 381867,	6	},
	[114050]	= { 462440,	60	},
	[114052]	= { 462440,	60	},
	[30884]	= { 443442,	10	},
	[197214]	= { 469344,	10	},
	[114051]	= { 384444,	60	},

	[333889]	= { 386113,	60,	449707,	90	},
	[328774]	= { 387972,	15	},
	[108416]	= { 386686,	15	},
	[30283]	= { 264874,	15	},
	[104773]	= { 386659,	45	},
	[17962]	= { 388827,	2	},
	[19505]	= { 385881,	5	},
	[17767]	= { 385881,	30	},
	[5484]	= { 429072,	15	},

	[6552]	= { 383115,	1	},
	[6544]	= { 202163,	15	},
	[384318]	= { 391572,	45	},
	[100]	= { 103827,	3	},
	[118038]	= { 383338,	30	},
	[5308]	= { 206315,	1.5	},
	[12975]	= { 280001,	60	},
	[871]	= { 397103,	60	},
	[1160]	= { 199023,	15	},
	[97462]	= { 235941,	90	},
	[23920]	= { 213915,	-10	},
	[3411]	= { 424654,	-10	},
	[5246]	= { 424742,	15	},
	[107570]	= { 436162,	-10	},
	[46968]	= { 440992,	5	},
}

E.spell_cdmod_talents_mult = {
	[49028]	= { 233412,	.50	},

	[195072]	= { 391397,	{.9,.8}	},
	[189110]	= { 391397,	{.9,.8}	},
	[205629]	= { 391397,	{.9,.8}	},
	[207684]	= { 211489,	.75	},
	[202137]	= { 211489,	.75	},
	[204596]	= { 211489,	.75	},
	[202138]	= { 211489,	.75	},
	[390163]	= { 211489,	.75	},

	[391528]	= { 393371,	.50,	393414,	.50,	391548,	.50,	393991,	.50	},
	[22812]	= { 203965,	{.88,.76}	},
	[61336]	= { 203965,	{.88,.76}	},

	[186257]	= { 203235,	.50	},
	[257044]	= { 400472,	.90	},


	[120]	= { 431067,	{[63]=.7}	},
	[122]	= { 431067,	{[63]=.7}	},
	[157997]	= { 431067,	{[63]=.7}	},
	[113724]	= { 431067,	{[63]=.7}	},
	[108839]	= { 431067,	{[63]=.7}	},
	[31661]	= { 431067,	{[64]=.7}	},
	[157981]	= { 431067,	{[64]=.7}	},
	[353082]	= { 431067,	{[64]=.7}	},

	[322507]	= { 325093,	.80	},
	[119582]	= { 325093,	.80	},
	[115310]	= { 353313,	.84	},
	[388615]	= { 353313,	.50	},
	[115203]	= { 202107,	.50	},

	[498]	= { 114154,	.70	},
	[403876]	= { 114154,	.70	},
	[184662]	= { 114154,	.70	},
	[31850]	= { 114154,	.70	},
	[633]	= { 114154,	.70,	378425,	{.85,pvp=.67}	},
	[642]	= { 114154,	.70,	378425,	{.85,pvp=.67}	},
	[1022]	= { 216853,	.67,	378425,	{.85,pvp=.67}	},
	[204018]	= { 216853,	.67,	378425,	{.85,pvp=.67}	},
	[6940]	= { 216853,	.67	},
	[199448]	= { 216853,	.67	},
	[387174]	= { 405757,	.67	},
	[35395]	= { 203316,	.85	},
	[432472]	= { 432804,	.80	},
	[190784]	= { 469409,	.80	},

	[34433]	= { 390770,	.50	},
	[123040]	= { 390770,	.50	},
	[451235]	= { 390770,	.50	},

	[36554]	= { 382503,	.80	},
	[2094]	= { 256165,	.75,	441415,	.90	},
	[200733]	= { 256165,	.75,	441415,	.90	},
	[114018]	= { 423662,	.50,	441415,	.90	},
	[121471]	= { 354825,	.80	},
	[1856]	= { 354825,	.80	},
	[1966]	= { 354825,	.80	},
	[2983]	= { 197000,	.50	},
	[51690]	= { 441274,	.90	},

	[64382]	= { 329033,	.50	},
	[384110]	= { 329033,	.50	},
	[6552]	= { 391271,	.95	},
	[184364]	= { 391271,	.95	},
	[107570]	= { 391271,	.95	},
	[118038]	= { 391271,	.95	},
	[871]	= { 391271,	.95	},
	[23920]	= { 391271,	.95	},
	[3411]	= { 391271,	.95	},
}

E.spell_chmod_talents = {

	[48265]	= { 356367,	1	},
	[444347]	= { 356367,	1	},
	[43265]	= { 356367,	1	},
	[49576]	= { 356367,	1	},

	[185123]	= { 389763,	1,	429211,	1	},
	[204157]	= { 389763,	1,	429211,	1	},
	[195072]	= { 320416,	1	},
	[189110]	= { 320416,	1	},
	[205629]	= { 320416,	1	},
	[204021]	= { 389732,	1	},
	[258920]	= { 427775,	1	},
	[205625]	= { 427775,	1	},
	[204596]	= { 428557,	1	},
	[207684]	= { 1235091,	1	},

	[22842]	= { 377811,	1	},
	[61336]	= { 328767,	1	},
	[18562]	= { 200383,	1	},
	[194223]	= { 468743,	1	},
	[102560]	= { 468743,	1	},
	[132158]	= { 470540,	1	},

	[358267]	= { 365933,	1	},
	[363916]	= { 375406,	1	},
	[443328]	= { 444081,	1	},
	[357170]	= { 376204,	1	},

	[259489]	= { 269737,	1	},
	[53351]	= { 321460,	1	},
	[259495]	= { 264332,	1	},
	[264735]	= { 459450,	1	},

	[122]	= { 205036,	1	},
	[153626]	= { 384651,	1	},
	[108853]	= { 205029,	1	},
	[44614]	= { 378198,	1	},

	[109132]	= { 115173,	1,	328669,	1	},
	[115008]	= { 328669,	1	},
	[121253]	= { 383707,	1	},
	[322507]	= { 450892,	1,	},

	[35395]	= { 383254,	1	},
	[190784]	= { 230332,	1	},
	[275779]	= { 204023,	1	},
	[1022]	= { 199454,	1	},
	[184575]	= { 403745,	1	},
	[20473]	= { 414073,	1	},

	[194509]	= { 322115,	1	},
	[2050]	= { 235587,	1	},
	[34861]	= { 235587,	1	},
	[8092]	= { 406788,	1	},
	[527]	= { 196439,	1	},
	[33206]	= { 373035,	1	},

	[5938]	= { 394983,	1	},
	[185313]	= { 394930,	1	},
	[1856]	= { 382513,	1	},
	[1966]	= { 423647,	1	},
	[36554]	= { 394931,	1	},
	[195457]	= { 394931,	1	},
	[212283]	= { 469642,	{1,2}	},

	[5394]	= { 5394,	{0,1}	},
	[157153]	= { 5394,	{0,1}	},
	[51505]	= { 333919,	1,	443418,	1	},
	[61295]	= { 333919,	1,	443418,	1	},

	[17962]	= { 231793,	1	},

	[100]	= { 103827,	1	},
	[228920]	= { 382953,	1	},
	[85288]	= { 383854,	1	},
	[871]	= { 397103,	1	},
	[3411]	= { 424654,	1	},
}

E.spell_cdmod_by_haste = {
	[50842]	= true,
	[232893]	= true,
	[258920]	= true,
	[205625]	= true,
	[203720]	= true,
	[188499]	= true,
	[185123]	= true,
	[342817]	= true,
	[22842]	= true,
	[33917]	= true,
	[360995]	= 1468,
	[443328]	= true,
	[259495]	= true,
	[259489]	= true,
	[34026]	= true,
	[19434]	= true,
	[217200]	= true,
	[212436]	= true,
	[100784]	= true,
	[205523]	= true,
	[107428]	= true,
	[467307]	= true,
	[113656]	= true,
	[119582]	= true,
	[204019]	= true,
	[31935]	= true,
	[35395]	= true,
	[24275]	= true,
	[275773]	= true,
	[275779]	= true,
	[20271]	= true,
	[184575]	= true,
	[17877]	= true,
	[8092]	= true,
	[47540]	= true,
	[17962]	= true,
	[196447]	= true,
	[2565]	= true,
	[845]	= true,
	[23881]	= true,
	[5308]	= true,
	[280735]	= true,
	[12294]	= true,
	[396719]	= true,
	[315720]	= true,
}






local blessingOfTheBronze = { 0,"mult_timeSpiral", 0.85,"mult_blessingOfTheBronze"	}
E.spell_cdmod_by_aura_mult = {
	[22842]	= { 0,"mult_berserkPersistence"	},
	[6795]	= { 0.5,"mult_berserkRavage"	},
	[48265]	= blessingOfTheBronze,
	[444347]	= blessingOfTheBronze,
	[195072]	= blessingOfTheBronze,
	[189110]	= blessingOfTheBronze,
	[205629]	= blessingOfTheBronze,
	[1850]	= blessingOfTheBronze,
	[252216]	= blessingOfTheBronze,
	[358267]	= blessingOfTheBronze,
	[186257]	= blessingOfTheBronze,
	[1953]	= blessingOfTheBronze,
	[212653]	= blessingOfTheBronze,
	[109132]	= blessingOfTheBronze,
	[115008]	= blessingOfTheBronze,
	[190784]	= blessingOfTheBronze,
	[73325]	= { 0,"mult_saveTheDay", 0,"mult_timeSpiral", 0.85,"mult_blessingOfTheBronze"	},
	[2983]	= blessingOfTheBronze,
	[79206]	= blessingOfTheBronze,
	[58875]	= blessingOfTheBronze,
	[192063]	= blessingOfTheBronze,
	[48020]	= blessingOfTheBronze,
	[6544]	= blessingOfTheBronze,
	[368847]	= { 0,"mult_snapFire"	},
	[257044]	= { 0.3,"mult_trueshot"	},
	[31935]	= { 0.25,"mult_momentOfGlory"	},
	[36554]	= { 0,"mult_deathsArrival"	},
	[195457]	= { 0,"mult_deathsArrival"	},
	[315341]	= { 0,"mult_isStealthed"	},
}

E.spell_noreset_onencounterend = {
	[20608]	= true,
	[6262]	= true,
}





E.spellcast_linked = {
	[204018]	= { 204018, 1022 },
	[1022]	= { 204018, 1022 },
	[189110] = { 189110,	205629	},
	[205629] = { 189110,	205629	},
}



E.spellcast_merged = {

	[410358]	= 48707,
	[207349]	= 49206,
	[46584]	= 46585,

	[389813]	= 207684,
	[389809]	= 202137,
	[389810]	= 204596,
	[389807]	= 202138,
	[389815]	= 390163,
	[452490]	= 204596,
	[452486]	= 212084,
	[452497]	= 198013,
	[452487]	= 258920,
	[258920]	= 205625,
	[221527]	= 217832,

	[274282]	= 274281,
	[274283]	= 274281,
	[77764]	= 106898,
	[77761]	= 106898,
	[102417]	= 102401,
	[49376]	= 102401,
	[16979]	= 102401,
	[102383]	= 102401,
	[383410]	= 194223,
	[390414]	= 102560,

	[406971]	= 372048,
	[382731]	= 367226,
	[382614]	= 355936,
	[382266]	= 357208,
	[408092]	= 396286,
	[382411]	= 359073,
	[433874]	= 357210,
	[357210]	= 371032,
	[442204]	= 403631,
	[403631]	= 371032,

	[53271]	= 272651,
	[272682]	= 272651,
	[264667]	= 272651,
	[272678]	= 272651,
	[388035]	= 272651,
	[272679]	= 272651,

	[198149]	= 84714,
	[30449]	= 198100,
	[108853]	= 319836,

	[388010]	= 388007,
	[388013]	= 388007,

	[388011]	= 388007,
	[212641]	= 86659,
	[31884]	= 384376,
	[10326]	= 469317,
	[471195]	= 633,

	[215769]	= 215982,
	[457042]	= 205385,
	[428930]	= 428933,
	[428934]	= 428933,
	[440725]	= 428933,

	[57934]	= 221622,
	[2094]	= 200733,

	[32182]	= 2825,
	[204361]	= 193876,
	[204362]	= 193876,
	[51490]	= 378779,
	[211004]	= 51514,
	[210873]	= 51514,
	[211015]	= 51514,
	[211010]	= 51514,
	[277784]	= 51514,
	[269352]	= 51514,
	[277778]	= 51514,
	[309328]	= 51514,

	[19647]	= 119898,
	[119910]	= 119898,
	[132409]	= 119898,
	[6358]	= 119898,
	[261589]	= 119898,
	[89808]	= 119898,
	[119905]	= 119898,
	[132411]	= 119898,
	[89766]	= 119898,
	[119914]	= 119898,

	[316593]	= 5246,
	[446035]	= 227847,

	[25046]	= 129597,
	[28730]	= 129597,
	[232633]	= 129597,
	[50613]	= 129597,
	[69179]	= 129597,
	[80483]	= 129597,
	[155145]	= 129597,
	[202719]	= 129597,
	[33697]	= 20572,
	[33702]	= 20572,
	[28880]	= 59542,
	[121093]	= 59542,
	[59547]	= 59542,
	[59544]	= 59542,
	[59543]	= 59542,
	[59545]	= 59542,
	[59548]	= 59542,
	[385953]	= 385952,

	[93985]	= 106839,
	[97547]	= 78675,
	[220543]	= 15487,
	[347008]	= 119898,
	[91807]	= 47482,

	[338035]	= 338142,
	[338018]	= 338142,
	[326462]	= 338142,
	[326446]	= 338142,
	[326647]	= 338142,





	[315443]	= 383269,
	[306830]	= 390163,
	[323639]	= 370965,
	[325727]	= 391888,
	[323764]	= 391528,


	[314791]	= 382440,
	[325216]	= 386276,
	[327104]	= 388193,
	[310454]	= 387184,
	[328622]	= 388007,
	[328282]	= 388007,
	[328620]	= 388007,
	[328281]	= 388007,
	[304971]	= 375576,
	[323673]	= 375901,
	[323547]	= 385616,
	[323654]	= 384631,
	[328305]	= 385408,
	[328547]	= 385424,
	[326059]	= 375982,
	[325640]	= 386997,
	[307865]	= 376079,





	[452767]	= 431416,
}

E.spellcast_merged_updateoncast = {

	[207349]	= { nil,	298674	},

	[274281]	= { nil,	1392543	},
	[274282]	= { nil,	1392542	},
	[274283]	= { nil,	1392545	},

	[53271]	= { 45,	236189	},
	[272682]	= { 45,	236189	},
	[264667]	= { 360,	136224	},
	[272678]	= { 360,	136224	},
	[388035]	= { 120,	571585	},
	[272679]	= { 120,	571585	},

	[388013]	= { nil,	3636845	},
	[388007]	= { nil,	3636843	},
	[388010]	= { nil,	3636846	},
	[388011]	= { nil,	3636844	},

	[428933]	= { nil,	5927641	},
	[428930]	= { nil,	5927642	},
	[428934]	= { nil,	5927640,	428940,	6118849	},
	[440725]	= { nil,	5927640	},

	[19647]	= { 24,	136174	},
	[119910]	= { 24,	136174	},
	[132409]	= { 24,	136174	},
	[6358]	= { 30,	1717715	},
	[261589]	= { 30,	1717715	},
	[89808]	= { 15,	135791	},
	[119905]	= { 15,	135791	},
	[132411]	= { 15,	135791	},
	[89766]	= { 30,	236316	},
	[119914]	= { 30,	236316	},

	[328282]	= { nil,	3636845	},
	[328620]	= { nil,	3636843	},
	[328622]	= { nil,	3636846	},
	[328281]	= { nil,	3636844	},

	[307865]	= { 60,	3565453	},





}

local function GetSharedCD(spec)
	return E.HEALER_SPEC[spec] and 60 or 90
end

E.spellcast_shared_cdstart = {

	[336126]	= { 265221,30,	59752,GetSharedCD,	20594,30,	7744,30	},
	[336135]	= { 265221,30,	59752,GetSharedCD,	20594,30,	7744,30	},
	[59752]	= { 336126,GetSharedCD	},
	[20594]	= { 336126,30	},
	[7744]	= { 336126,30	},
	[265221]	= { 336126,30	},
}

E.spellcast_cdreset = {
	[187827]	= { 452409,	204596,212084	},
	[191427]	= { nil,	{388112, 188499,198013},{452409, 204596,258920,205625}	},
	[198793]	= { 444931,	232893	},
	[357210]	= { 441257,	358267	},
	[433874]	= { 441257,	358267	},
	[403631]	= { 441257,	358267	},
	[442204]	= { 441257,	358267	},
	[235219]	= { nil,	45438,414658,11426,120,122,{431112, 319836,31661,157981,353082}	},
	[387184]	= { nil,	121253,191837	},
	[115399]	= { nil,	119582,322507	},
	[121253]	= { 383697,	115181	},
	[200183]	= { nil,	88625,34861,2050	},
}

E.spellcast_cdr = {
	[8921]	= { 429539,	nil,	nil,	{[202770]=2,[274281]=1,[204066]=3}	},
	[194153]	= { 429539,	nil,	nil,	{[202770]=2,[274281]=1}	},
	[197628]	= { 429539,	nil,	3,	204066	},
	[78674]	= { 429539,	nil,	nil,	{[202770]=2,[274281]=1}	},
	[197626]	= { 429539,	nil,	3,	204066	},
	[191034]	= { 429539,	nil,	nil,	{[202770]=2,[274281]=1}	},
	[202347]	= { 429539,	nil,	nil,	{[202770]=2,[274281]=1}	},
	[77758]	= { 429539,	nil,	nil,	{[204066]={429523,3}}	},
	[373861]	= { 376237,	nil,	nil,	{[367226]=5,[355936]=5,[357208]=5}	},
	[395160]	= { 407876,	nil,	1,	396286	},
	[217200]	= { 231548,	nil,	12,	19574	},
	[19434]	= { 459533,	nil,	nil,	{[474421]=0.5,[109248]=0.5}	},
	[34026]	= { 459533,	nil,	nil,	{[19577]=0.5,[109248]=0.5}},
	[259495]	= { 459533,	nil,	nil,	{[19577]=0.5,[109248]=0.5}},
	[100784]	= { 269,	nil,	nil,	{[107428]=1,[113656]=1},	nil,	269,	nil,	nil,	{[107428]=1,[113656]=1},	"rrt_orderedElements"	},
	[116841]	= { 451041,	nil,	nil,	{[109132]=5,[115008]=5}	},
	[19750]	= { 432919,	nil,	3.0,	432472,	"hasInfusionOfLight"	},
	[82326]	= { 432919,	nil,	3.0,	432472,	"hasInfusionOfLight"	},
	[275773]	= { 432919,	nil,	3.0,	432472,	"hasInfusionOfLight"	},
	[85673]	= { 432919,	nil,	3.0,	432472,	"rrt_shiningLight",	468454,	nil,	4.0,	1044	},
	[23922]	= { 384072,	nil,	6,	871	},
	[6544]	= { 444777,	nil,	5,	100	},
	[100]	= { 444777,	nil,	2,	6544	},
}





E.spell_auraremoved_cdstart_preactive = {
	[188501]	= 188501,

	[5215]	= 5215,
	[370553]	= 370553,
	[370537]	= 370537,
	[369536]	= 369536,
	[199483]	= 199483,
	[34477]	= 34477,
	[205025]	= 205025,
	[209584]	= 209584,
	[210294]	= 210294,
	[215652]	= 215652,
	[382245]	= 382245,
	[456330]	= 382245,
	[378081]	= 378081,
	[443454]	= 443454,
	[328774]	= 328774,
	[256948]	= 256948,
	[5384]	= 0,
	[57934]	= 0,
}

E.spell_auraapplied_processspell = {
	[123981]	= 114556,
	[209261]	= 209258,
	[472708]	= 472707,
	[87024]	= 86949,
	[393879]	= 378279,
	[211319]	= 391124,
	[45182]	= 31230,
	[386397]	= 386394,
	[386001]	= 386001,
	[313015]	= 312916,
	[320224]	= 319217,
	[404381]	= 404381,
	[410232]	= 410232,
	[382912]	= 377847,
	[417069]	= 417050,
	[442489]	= 442489,
	[451568]	= 451568,
	[457489]	= 457489,

	[342246]	= 342245,
	[305395]	= 1044,
	[283167]	= 336135,
}

E.spell_dispel_cdstart = {
	[88423]	= true,
	[2782]	= true,
	[365585]	= true,
	[360823]	= true,
	[374251]	= true,
	[475]	= true,
	[115450]	= true,
	[218164]	= true,
	[4987]	= true,
	[213644]	= true,
	[527]	= true,
	[213634]	= true,
	[77130]	= true,
	[51886]	= true,

	[33891]	= true,
	[119996]	= true,
	[633]	= true,
	[471195]	= true,
	[316262]	= true,
	[323436]	= true,
	[6262]	= true,
	[381623]	= true,
}

E.selfLimitedMinMaxReducer = {
	[387184]	= true,
	[192058]	= true,
	[46968]	= true,
}





E.runeforge_bonus_to_descid = {
	[6948]	= 334724,
	[6941]	= 334525,
	[6943]	= 334580,
	[6946]	= 334692,
	[6951]	= 334898,
	[7051]	= 337685,
	[7048]	= 337547,
	[7043]	= 337534,
	[7046]	= 337544,
	[7095]	= 339062,
	[7109]	= 340053,
	[7571]	= 354118,
	[8121]	= 354118,
	[7003]	= 336742,
	[7006]	= 336747,
	[7009]	= 336830,
	[7012]	= 336867,
	[7016]	= 336901,
	[7476]	= 354333,
	[8123]	= 354333,
	[7081]	= 337296,
	[7077]	= 337288,
	[7070]	= 337481,
	[7726]	= 356818,
	[8124]	= 356818,
	[7078]	= 337290,
	[7079]	= 337570,
	[7053]	= 337600,
	[7701]	= 355447,
	[8125]	= 355447,
	[7060]	= 337831,
	[7064]	= 337247,
	[7065]	= 337638,
	[7061]	= 337838,
	[6972]	= 336470,
	[6984]	= 337477,
	[6979]	= 336133,
	[6977]	= 336314,
	[7728]	= 356395,
	[7703]	= 356391,
	[8126]	= {356395,356391},
	[7114]	= 340080,
	[7118]	= 340084,
	[7572]	= 354703,
	[8127]	= 354703,
	[6995]	= 335897,
	[6989]	= 336734,
	[7708]	= 356218,
	[7709]	= 356250,
	[8128]	= {356218,356250},
	[7025]	= 337020,
	[7038]	= 337166,
	[7028]	= 337065,
	[6955]	= 335214,
	[6956]	= 335229,
	[6957]	= 335239,
	[6967]	= 335629,
	[6965]	= 335582,

}

E.runeforge_specid = {
	[334724]=nil,	[334525]=250,	[334580]=250,	[334692]=251,	[334898]=252,
	[337685]=577,	[337547]=581,	[337534]=nil,	[337544]=581,
	[339062]=104,	[340053]=103,	[354118]=nil,
	[336742]=nil,	[336747]=nil,	[336830]=253,	[336867]=254,	[336901]=255,
	[354333]=nil,
	[337296]=nil,	[337288]=268,	[337481]=269,	[356818]=nil,	[337290]=268,	[337570]=268,
	[337600]=nil,	[355447]=nil,	[337831]=70,	[337247]=70,	[337638]=70,	[337838]=66,
	[336470]=nil,	[337477]=257,	[336133]=256,	[336314]=257,	[356395]=nil,	[356391]=nil,
	[340080]=nil,	[340084]=259,	[354703]=nil,
	[335897]=263,	[336734]=262,	[356218]=nil,	[356250]=nil,
	[337020]=nil,	[337166]=267,	[337065]=nil,
	[335214]=nil,	[335229]=73,	[335239]=73,	[335629]=73,	[335582]=72,
}

E.runeforge_desc_to_powerid={
	[334724]=33,	[334525]=35,	[334580]=36,	[334692]=40,	[334898]=44,
	[337685]=24,	[337547]=29,	[337534]=20,	[337544]=27,
	[339062]=61,	[340053]=54,	[354118]=226,
	[336742]=66,	[336747]=69,	[336830]=72,	[336867]=75,	[336901]=79,
	[354333]=222,
	[337296]=85,	[337288]=87,	[337481]=94,	[356818]=259,	[337290]=88,	[337570]=89,
	[337600]=98,	[355447]=240,	[337831]=106,	[337247]=113,	[337638]=112,	[337838]=107,
	[336470]=149,	[337477]=154,	[336133]=152,	[336314]=155,	[356395]=261,	[356391]=242,
	[340080]=114,	[340084]=121,	[354703]=229,
	[335897]=140,	[336734]=134,	[356218]=246,	[356250]=nil,
	[337020]=162,	[337166]=175,	[337065]=165,
	[335214]=178,	[335229]=190,	[335239]=191,	[335629]=192,	[335582]=188,
}

E.runeforge_unity = {
	[354118]	= true,
	[354333]	= true,
	[356395]	= true,
	[356391]	= true,
	[355447]	= true,
	[356818]	= true,
	[356250]	= true,
	[356218]	= true,
	[354703]	= true,
}





E.covenant_to_spellid = {
	321076,
	321079,
	321077,
	321078,
}

E.covenant_abilities = {
	[324739]	= 1,
	[323436]	= 1,
	[312202]	= 1,
	[306830]	= 1,
	[326434]	= 1,
	[338142]	= 1,
	[338035]	= 1,
	[338018]	= 1,
	[326462]	= 1,
	[326446]	= 1,
	[326647]	= 1,



	[308491]	= 1,
	[307443]	= 1,
	[310454]	= 1,
	[304971]	= 1,
	[325013]	= 1,


	[323547]	= 1,
	[324386]	= 1,
	[312321]	= 1,
	[307865]	= 1,
	[300728]	= 2,
	[311648]	= 2,
	[317009]	= 2,
	[323546]	= 2,
	[324149]	= 2,
	[314793]	= 2,
	[326860]	= 2,
	[316958]	= 2,
	[323673]	= 2,
	[323654]	= 2,
	[320674]	= 2,
	[321792]	= 2,
	[317483]	= 2,
	[317488]	= 2,
	[310143]	= 3,
	[324128]	= 3,
	[323639]	= 3,
	[323764]	= 3,
	[328231]	= 3,
	[314791]	= 3,
	[327104]	= 3,

	[328622]	= 3,
	[328282]	= 3,
	[328620]	= 3,
	[328281]	= 3,
	[327661]	= 3,
	[328305]	= 3,
	[328923]	= 3,
	[325640]	= 3,
	[325886]	= 3,
	[319217]	= 3,
	[324631]	= 4,
	[315443]	= 4,
	[329554]	= 4,
	[325727]	= 4,
	[325028]	= 4,
	[324220]	= 4,
	[325216]	= 4,
	[328204]	= 4,
	[324724]	= 4,
	[328547]	= 4,
	[326059]	= 4,
	[325289]	= 4,
	[324143]	= 4,
}

E.spell_benevolent_faerie_majorcd = E.BLANK

E.covenant_cdmod_conduits = {
	[310143]	= { 320658, 15 },
	[300728]	= { 336147, -30 },
}

E.covenant_chmod_conduits = {
	[300728]	= { 336147, 1 },
}

E.covenant_cdmod_items_mult = {
	[300728]	= { 184807, 0.8 },
	[310143]	= { 184807, 0.8 },
	[324631]	= { 184807, 0.8 },
	[323436]	= { 184807, 0.8 },
}


E.soulbind_conduits_rank = {
	[337704]	= { 20.0, 22.0, 24.0, 26.0, 28.0, 30.0, 32.0, 34.0, 36.0, 38.0, 40.0, 42.0, 44.0, 46.0, 48.0 },

	[338553]	= { 1.0 },
	[338671]	= { 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20 },
	[340028]	= { 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 11.5, 12.0 },
	[340550]	= { .90, .89, .88, .87, .86, .85, .84, .83, .82, .81, .80, .79, .78, .77, .76 },
	[340529]	= { .90, .89, .88, .87, .86, .85, .84, .83, .82, .81, .80, .79, .78, .77, .76 },
	[341451]	= { .90, .89, .88, .87, .86, .85, .84, .83, .82, .81, .80, .79, .78, .77, .76 },
	[341378]	= { .90, .89, .88, .87, .86, .85, .84, .83, .82, .81, .80, .79, .78, .77, .76 },
	[341440]	= { 1.0 },
	[339377]	= { 10, 11.5, 13, 14.5, 16, 17.5, 19, 20.5, 23, 24.5, 26, 27.5, 29, 30.5, 32 },
	[339558]	= { 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0 },
	[339704]	= { 1.0, 1.2, 1.4, 1.6, 1.8, 2.0, 2.2, 2.5, 2.7, 2.9, 3.1, 3.4, 3.6, 3.8, 4.0 },
	[346747]	= { 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 1.0, 2.3, 2.4 },
	[340876]	= { 5.0, 6.0, 6.0, 7.0, 7.0, 8.0, 8.0, 9.0, 9.0, 10.0, 10.0, 11.0, 11.0, 12.0, 12.0 },
	[336636]	= { 2.0, 2.2, 2.4, 2.6, 2.8, 3.0, 3.2, 3.4, 3.6, 3.8, 4.0, 4.2, 4.4, 4.6, 4.8 },
	[336613]	= { 25, 28, 30, 33, 35, 38, 40, 43, 45, 48, 50, 53, 55, 58, 60 },
	[336777]	= { 2.5, 2.8, 3.0, 3.3, 3.5, 3.8, 4.0, 4.3, 4.5, 4.8, 5.0, 5.3, 5.5, 5.8, 6.0 },
	[336992]	= { 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4 },
	[336873]	= { 0.30, 0.33, 0.36, 0.39, 0.42, 0.45, 0.48, 0.51, 0.54, 0.57, 0.60, 0.63, 0.66, 0.69, 0.72 },
	[336522]	= { 0.75, 0.83, 0.90, 0.98, 1.05, 1.13, 1.20, 1.28, 1.35, 1.43, 1.50, 1.58, 1.65, 1.73, 1.80 },
	[337099]	= { 1.0 },
	[336773]	= { 0.3 },
	[337264]	= { 0.5 },
	[336616]	= { 0.1 },
	[337295]	= { 0.5 },
	[337084]	= { 6.0, 6.6, 7.2, 7.8, 8.4, 9.0, 9.6, 10.2, 10.8, 11.4, 12.0, 12.6, 13.2, 13.8, 14.4 },
	[340030]	= { 15.0, 16.5, 18.0, 19.5, 21.0, 22.5, 24.0, 25.5, 27.0, 28.5, 30.0, 31.5, 33.0, 34.5, 36.0 },
	[340023]	= { 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 },
	[338741]	= { 48.0, 46.0, 44.0, 42.0, 40.0, 38.0, 36.0, 34.0, 32.0, 30.0, 28.0, 26.0, 24.0, 22.0, 20.0 },
	[337678]	= { 20.0, 22.0, 24.0, 26.0, 28.0, 30.0, 32.0, 34.0, 36.0, 38.0, 40.0, 42.0, 44.0, 46.0, 48.0 },
	[338345]	= { 1.06, 1.088, 1.096, 1.104, 1.112, 1.120, 1.128, 1.136, 1.144, 1.152, 1.160, 1.168, 1.176, 1.184, 1.192 },
	[337762]	= { 6.0, 6.6, 7.2, 7.8, 8.4, 9.0, 9.6, 10.2, 10.8, 11.4, 12.0, 12.6, 13.2, 13.8, 14.4 },
	[341559]	= { 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4 },
	[341535]	= { 2.0, 2.2, 2.4, 2.6, 2.8, 3.0, 3.2, 3.4, 3.6, 3.8, 4.0, 4.2, 4.4, 4.6, 4.8 },
	[341531]	= { .90 },
	[337964]	= { 180, 210, 240, 270, 300, 330, 360, 390, 420, 450, 480, 510, 540, 570, 600 },
	[338042]	= { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 },
	[339183]	= { 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 33.0, 34.0, 35.0, 36.0, 37.0, 38.0, 39.0, 40.0 },
	[339186]	= { 20, 21, 23, 24, 26, 27, 29, 30, 31, 33, 34, 36, 37, 39, 40 },
	[339130]	= { 48, 51, 54, 57, 60, 63, 66, 69, 72, 75, 78, 81, 84, 87, 90 },
	[339455]	= { 3, 3.2, 3.4, 3.6, 3.8, 4, 4.2, 4.4, 4.6, 4.8, 5, 5.2, 5.4, 5.6, 5.8 },
	[339272]	= { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 },
	[334993]	= { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 },
	[339948]	= { 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12 },
	[339939]	= { 15 },
}

E.soulbind_abilities = {
	[319217]	= true,
	[336147]	= true,
	[328261]	= true,
	[326507]	= true,
	[320658]	= true,
}

E.spell_cdmod_conduits = {
	[48792]	= 337704,
	[317009]	= 340028,
	[198589]	= 338671,
	[204021]	= 338671,
	[217200]	= 341440,
	[186265]	= 339377,
	[186257]	= 339558,
	[1953]	= 336636,
	[212653]	= 336636,
	[45438]	= 336613,
	[86659]	= 340030,
	[228049]	= 340030,
	[73325]	= 337678,
	[328923]	= 339183,
	[20608]	= 337964,
	[8143]	= 338042,
	[2484]	= 338042,
	[192058]	= 338042,
	[333889]	= 339130,
	[325886]	= 339939,
	[118038]	= 334993,
	[184364]	= 334993,
	[871]	= 334993,
	[12323]	= 339948,
	[46968]	= 339948,
}

E.spell_cdmod_conduits_mult = {
	[132158]	= 340550,
	[338142]	= 341378,



	[22812]	= 340529,
	[5211]	= 341451,
	[102359]	= 341451,
	[319454]	= 341451,





	[195457]	= 341531,
	[36554]	= 341531,
}

E.spell_symbol_of_hope_majorcd = E.BLANK
E.spell_major_cd = E.BLANK





E.item_merged = {
	[184052]=181333, [184054]=181816, [184053]=181335, [178334]=178447, [175884]=175921,
	[185304]=181333, [185306]=181816, [185305]=181335, [185282]=178447, [185197]=175921,
	[185309]=181333, [185311]=181816, [185310]=181335, [185242]=178447, [185161]=175921,
	[186869]=181333, [186871]=181816, [186870]=181335, [186868]=178447, [186866]=175921,
	[186966]=181333, [186968]=181816, [186967]=181335, [186946]=178447, [186906]=175921,
	[192298]=181333, [192300]=181816, [192299]=181335, [192297]=178447, [192295]=175921,
	[192412]=181333, [192414]=181816, [192413]=181335, [192392]=178447, [192352]=175921,
	[192301]=188524, [192302]=188691, [192303]=188766, [192304]=188775, [192305]=188778,
	[201810]=181333, [201811]=181816, [201809]=178447, [201807]=175921,
	[201450]=181333, [201453]=181816, [201452]=178447, [201449]=175921,
	[205711]=181333, [205712]=181816, [205710]=178447, [205708]=175921,
	[205779]=181333, [205782]=181816, [205781]=178447, [205778]=175921,
	[209346]=181333, [209347]=181816, [209345]=178447, [209343]=175921,
	[208307]=181333, [209767]=181816, [208309]=178447, [209763]=175921, [209764]=181333, [209766]=178447,
	[216282]=181333, [216283]=181816, [216281]=178447, [216279]=175921,
	[211606]=181333, [216372]=181816, [211608]=178447, [216368]=175921, [216369]=181333, [216371]=178447,
	[218716]=181333, [218717]=181816, [218715]=178447, [218713]=175921,
	[218422]=181333, [218425]=181816, [218424]=178447, [218421]=175921,
	[229783]=181333, [229784]=181816, [229782]=178447, [229780]=175921,
	[229492]=181333, [229495]=181816, [229494]=178447, [229491]=175921,
	[230641]=181333, [230642]=181816, [230640]=178447, [230638]=175921,
	[230353]=181333, [230356]=181816, [230355]=178447, [230352]=175921,
}

E.item_equip_bonus = {
	[168989] = 300142,
}

local class_set_bonus = {
	PRIE110000	= { [257] = { 453677, 2, 453678, 4 }	},
	EVOK110000	= { [1467] = { 453675, 4	},	},
	DEMO110100	= { [581] = { 1215991, 4 }	},
	EVOK110100	= { [1468] = { 1215610, 4 }	},
	MAGE110100	= { [63] = { 1215132, 2 }	},
	PALA110100	= { [65] = { 1215613, 4 }	},
	WARR110100	= { [73] = { 1215995, 4 }	},

	EVOK110200	= { [38] = { 1236368, 2 },	},
	HUNT110200	= { [44] = { 1236370, 2 },	},
	ROGU110200	= { [52] = { 1236403, 4 },	},
}


E.item_set_bonus = {
	[212083]	= class_set_bonus.PRIE110000,
	[212081]	= class_set_bonus.PRIE110000,
	[212086]	= class_set_bonus.PRIE110000,
	[212084]	= class_set_bonus.PRIE110000,
	[212082]	= class_set_bonus.PRIE110000,
	[212029]	= class_set_bonus.EVOK110000,
	[212027]	= class_set_bonus.EVOK110000,
	[212032]	= class_set_bonus.EVOK110000,
	[212030]	= class_set_bonus.EVOK110000,
	[212028]	= class_set_bonus.EVOK110000,
	[229314]	= class_set_bonus.DEMO110100,
	[229315]	= class_set_bonus.DEMO110100,
	[229316]	= class_set_bonus.DEMO110100,
	[229317]	= class_set_bonus.DEMO110100,
	[229319]	= class_set_bonus.DEMO110100,
	[229278]	= class_set_bonus.EVOK110100,
	[229279]	= class_set_bonus.EVOK110100,
	[229280]	= class_set_bonus.EVOK110100,
	[229281]	= class_set_bonus.EVOK110100,
	[229283]	= class_set_bonus.EVOK110100,
	[229341]	= class_set_bonus.MAGE110100,
	[229342]	= class_set_bonus.MAGE110100,
	[229343]	= class_set_bonus.MAGE110100,
	[229344]	= class_set_bonus.MAGE110100,
	[229346]	= class_set_bonus.MAGE110100,
	[229242]	= class_set_bonus.PALA110100,
	[229243]	= class_set_bonus.PALA110100,
	[229244]	= class_set_bonus.PALA110100,
	[229245]	= class_set_bonus.PALA110100,
	[229247]	= class_set_bonus.PALA110100,
	[229233]	= class_set_bonus.WARR110100,
	[229234]	= class_set_bonus.WARR110100,
	[229235]	= class_set_bonus.WARR110100,
	[229236]	= class_set_bonus.WARR110100,
	[229238]	= class_set_bonus.WARR110100,
	[237655]	= class_set_bonus.EVOK110200,
	[237653]	= class_set_bonus.EVOK110200,
	[237650]	= class_set_bonus.EVOK110200,
	[237656]	= class_set_bonus.EVOK110200,
	[237654]	= class_set_bonus.EVOK110200,
	[237646]	= class_set_bonus.HUNT110200,
	[237644]	= class_set_bonus.HUNT110200,
	[237649]	= class_set_bonus.HUNT110200,
	[237647]	= class_set_bonus.HUNT110200,
	[237645]	= class_set_bonus.HUNT110200,
	[237664]	= class_set_bonus.ROGU110200,
	[237662]	= class_set_bonus.ROGU110200,
	[237667]	= class_set_bonus.ROGU110200,
	[237665]	= class_set_bonus.ROGU110200,
	[237663]	= class_set_bonus.ROGU110200,
}

E.item_unity = {
	[190465]	= 354118,
	[190464]	= 354333,
	[190468]	= { 356395, 356391	},
	[190474]	= 355447,
	[190472]	= 356818,
	[190473]	= { 356250, 356218	},
	[190471]	= 354703,
}





--[[
v2.8.18:
	Synced spells are now tracked in the background, so that the addon's CDR can be directly compared to the game's CDR.
	This allows sync to be delayed until a discrepancy is found, as opposed to sending data every time a cooldown is reduced.
	The resulting reduction to bandwidth usage will be proportional to the addon's CDR accuracy, which means we can add as much
	spells to the list as backup with little to no increase in traffic.

	Rogue abilities are an exception. There's no way to track the actual amount of combo points spent on a finishing move, so the
	addon calculates all finishers as if it had consumed max combo points. This means that every finisher that isn't used at
	max combo points will be tranferring cooldown data. Unless Blizzard updates UnitPower() to work on other units, there's no
	way around this.
]]



E.sync_cooldowns = {
	["DEATHKNIGHT"]	= {
		[49576]	= { 276079	},
		[48792]	= { {250,252},	434136,	48792	},

		[55233]	= { 250,	205723,	55233	},
		[49028]	= { 250,	377637,	49028	},
	},
	["DEMONHUNTER"]	= {
		[232893]	= { 232893	},
		[212084]	= { 581,	389708,	212084	},
		[452486]	= { 581,	389708,	452415,	212084	},
		[370965]	= { 581,	1215991	},
	},
	["DRUID"]	= {
		[204066]	= { 104,	429539,	204066	},
		[33891]	= { 105,	393371,	33891,	{-473909, 473909}	},

		[102558]	= { 104,	393414,	102558,	},
	},
	["EVOKER"]	= {
		[357208]	= { 431484	},
		[382266]	= { 431484,	{408083,375783}	},
		[396286]	= { 431484,	396286	},
		[408092]	= { 431484,	396286,	408083	},
		[355936]	= { 431484,	355936	},
		[382614]	= { 431484,	355936,	375783	},
		[367226]	= { 431484,	367226	},
		[382731]	= { 431484,	367226,	375783	},
		[357210]	= { 441206,	{-403631,403631}	},
		[433874]	= { 441206,	433871,	{-403631,442204}	},
	},
	["HUNTER"]	= {
		[257044]	= { 254,	391559,	257044	},
		[190925]	= { 255,	265895	},
		[360952]	= { 255,	451546,	360952	},

		[109304]	= { 270581	},
		[288613]	= { 254,	451546,	288613	},
	},
	["MAGE"]	= {
		[55342]	= { 382569,	55342	},
		[190319]	= { 63,	190319	},
	},
	["MONK"]	= {
		[115203]	= { 268,	{386937,418359},	115203	},
		[322507]	= { 268,	{386937,418359},	322507	},
		[119582]	= { 268,	{386937,418359},	119582	},
		[115399]	= { 268,	{386937,418359},	115399	},
		[322109]	= { 269,	391330	},
		[119996]	= { 270,	353584,	101643	},

		[387184]	= { 268,	450989,	387184	},
		[137639]	= { 269,	280197,	137639	},
	},
	["PALADIN"]	= {

		[633]	= { {392928, 414720, 326734}	},
		[471195]	= { {392928, 414720, 326734}, 387791	},
		[31850]	= { 66,	385422,	31850	},
		[642]	= { 66,	385422	},

		[31884]	= { 66,	204074,	{31884,389539}, {-389539,389539}	},
		[86659]	= { 66,	204074,	86659,	{-228049,228049}	},
		[212641]	= { 66,	204074,	86659,	{-228049,228049}	},
	},
	["PRIEST"]	= {
		[228260] = { 258,	199259,	228260	},
		[391109] = { 258,	199259,	391109	},
	},
	["ROGUE"]	= {

		[185313]	= { 261,	185314	},
		[280719]	= { 261,	280719	},
		[13750]	= { 260,	13750	},
		[196937]	= { 260,	196937	},
		[381989]	= { 260,	381989	},
		[51690]	= { 260,	51690	},
		[1856]	= { 260	},
		--[[
		CDR amount is the same for all Restless Blades' base abilities, so use any of the watched spell's sync data to
		adjust other nonessential timers. However, atleast one watched spell needs to be on cooldown.
		[315341]	= { 260	},
		[13877]	= { 260,	13877	},
		[271877]	= { 260,	271877	},
		[195457]	= { 260	},
		[315508]	= { 260,	315508	},
		[2983]	= { 260	},
		]]
		[5277]	= { 260,	354897,	5277	},
		[1966]	= { 260,	354897	},
	},
	["SHAMAN"]	= {


		[108280]	= { 264,	382030,	108280	},
		[383013]	= { 264,	382030,	383013	},
		[8143]	= { {263,264},	445027,	8143	},
		[197214]	= { 263,	469344,	197214	},

		[51533]	= { 263,	384447,	51533	},
	},
	["WARLOCK"]	= {
		[104773]	= { 389359	},
		[48020]	= { 268358, 409835	},
	},
	["WARRIOR"]	= {

		[1719]	= { 72,	152278,	1719	},
		[228920]	= { {71,72},	152278,	228920	},
		[167105]	= { 71,	152278,	167105	},
		[262161]	= { 71,	152278,	262161	},
		[227847]	= { {71,72},	152278,	227847	},
		[446035]	= { {71,72},	152278,	227847,	444780	},
		[107574]	= { 73,	152278,	401150	},
		[871]	= { 73,	152278,	871	},
	},
	["ALL"]	= {
		[6262]	= { false	},
	},
}

E.sync_in_raid = {
	[48792]	= true,
	[33891]	= true,
	[115203]	= true,
	[108280]	= true,
	[871]	= true,
}


E.sync_reset = {
	[49576]	= true,
	[370965] = true,
	[257044]	= true,
	[190925]	= true,
	[6262]	= true,
}

E:ProcessSpellDB()
