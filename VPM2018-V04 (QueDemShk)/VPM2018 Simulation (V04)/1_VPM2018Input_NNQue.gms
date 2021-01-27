** ** ** ** ** ** ** ** ** ** ** ** ** **************
* MODULE I: PROGRAM TO DECLARE DATA INPUT PARAMETER *
* FOR VIETNAM PIG MODEL VERSION 2018                *
*****************************************************
*UPGRADED by NGUYEN NGOC QUE

$OFFUPPER
SETS
     T  Time period        / 2018*2030 /
     C  All commodities
                    / 'MAIZE'   Crops used for human & animal
                      'TRADPIG' Traditional small-scale pig farms
                      'COMMPIG' Commercial large-scale pig farms
                      'MODPIG'  Modern large-scale pig farms      /
     RW    Regions incl world
                    / 'NMM  '   North Moutainous and Middle Lands
                      'RRD  '   Red River Delta
                      'NCC  '   North Central Coast
                      'SCC  '   South Central Coast
                      'CH   '   Central Highlands
                      'SE   '   South East
                      'MRD  '   Mekong River Delta
                      'WORLD'   Rest of world               /
     R(RW) Regions excl world
                    / 'NMM  '   North Moutainous and Middle Lands
                      'RRD  '   Red River Delta
                      'NCC  '   North Central Coast
                      'SCC  '   South Central Coast
                      'CH   '   Central Highlands
                      'SE   '   Southeast
                      'MRD  '   Mekong River Delta          /
     U     Urban & rural areas / URBAN,RURAL /
     L(C)  Subset of livestock commodities  / TRADPIG,COMMPIG,MODPIG /
     F(C)  Subset of food-feed crop commodities       / MAIZE /
     SIMS  Simulations                      / SIM /
*NNQue2020 add subsets for time period
     T1(T) Subset of first time period / 2018*2025 /
     T2(T) Subset of second time period / 2026*2030 /     ;

ALIAS (R,RR),(RW,RRW),(U,UU),(C,CC),(L,LL),(F,FF) ;


PARAMETERS

MPAR(C,*)     Market parameters: CONV PMARGPR CTA XPROC FEEDCONV
AREA0(F,R,U)   Original crop area for urban-rural consumption 2018 (1000ha)
YIELD0(F,R,U)  Original crop yield for urban-rural consumption 2018 (ton per ha)
PROD0(C,R,U)   Original production for urban-rural consumption 2018 (1000tons)
CRPROD0(F,R,U) Original production for urban-rural consumption 2018 (1000tons)
LVPROD0(L,R,U) Original lvstck prod. for urban-rural consumption 2018 (1000tons LW)
DPC0(C,R,U)    Original per capita food cons. 2018 (kg per per year)
PD0(C,R,U)     Original consumer price 2018 (VND per kg)
PDB(C,R,U)     Base scenario consumer price (VND per kg)
PW0(C,*)       Original world prices 2018 (US$ per ton)
TAX0(C,*)      Original import-export tax 2018 (fraction)
TRADE(C,*)     Import and export volumes 2018 (1000 tons)
IDEN1(C,F)     Identity matrix for proper dimension of feed demand in inflows
IDEN2(C,L)     Identity matrix for proper dimension of lstck Supply in outflows
KM(RW,RRW,*)   Distance (km)
YPC0(R,U)      Urban & rural per capita income in 2018 (mill. VND per prsn per yr)
POP0(R,U)      Urban & rural population in 2018 (1000 inhabitants)
FEEDSHARE(L,F) Share of each feed in total composite feed demand (fraction)
ADJ(C,*)       Adjustment factor to match VHLSS consumption with national data
YGR(R,U)       Annual income growth 2018-29 in fraction
PGR(R,U)       Annual pop growth 2018-29 in fraction
AREAE(F,R)     Elasticity of crop area wrt output price
YIELDE(F,R)    Elasticity of crop yield wrt output price
LVELAS(L,LL,R) Elasticity of livestock supply wrt output prices
LVFDEL(L,F)    Elasticity of livestock supply wrt feed prices
DYE(C,R,U)     Food demand elasticity wrt consumer income
DPE(C,CC,R,U)  Food demand elasticities wrt food prices
PWGR(T,C)      Annual growth of commodity world prices
FDELAS(F,F)    Elasticity feed Demand wrt feed own prices
AREALVEL(F,L)  Elasticity of feed crop area wrt livestock prices
YIELDLVEL(F,L) Elasticity of feed crop yield wrt livestock prices
SHK(C,R,U)     Initial disease-induced demand shock     ;

*Call for parameter values stored in excel file
$CALL 'GDXXRW VPM2018Input_NNQue.XLSX skipempty=0 trace=2 index=INPUT!A3'
$GDXIN VPM2018Input_NNQue.GDX
$LOAD MPAR AREA0 YIELD0 PROD0 CRPROD0 LVPROD0 DPC0 PD0 PDB PW0 TRADE
$LOAD IDEN1 IDEN2 KM YPC0 POP0 FEEDSHARE ADJ YGR PGR
$LOAD PWGR TAX0
$LOAD AREAE YIELDE LVELAS LVFDEL DYE DPE FDELAS AREALVEL YIELDLVEL


DISPLAY MPAR,AREA0,YIELD0,PROD0,CRPROD0,LVPROD0,DPC0,PD0,PDB,PW0,TRADE ;
DISPLAY IDEN1,IDEN2,KM,YPC0,POP0,FEEDSHARE,ADJ,YGR,PGR ;
DISPLAY PWGR,TAX0 ;
DISPLAY AREAE,YIELDE,LVELAS,LVFDEL,DYE,DPE,FDELAS,AREALVEL,YIELDLVEL ;

*Set distance RW2RRW equal to distance RRW2RW
$MAXCOL 120 ;
KM(RRW,RW,'ROAD')$KM(RW,RRW,'LINK') = KM(RW,RRW,'ROAD') ;
KM(RRW,RW,'SEA' )$KM(RW,RRW,'LINK') = KM(RW,RRW,'SEA ') ;
KM(RRW,RW,'LINK')$KM(RW,RRW,'LINK') = KM(RW,RRW,'LINK') ;

*Some other original parameters
PARAMETERS
NER0            Nominal exchange rate in 2018 (1000 VND per US$)
DFOOD0(C,R,U)   Original food demand (1000 tons)
DFEED0(C,R,U)   Original feed demand (1000 tons)
D0(C,R,U)       Original food-feed demand (1000 tons)
S0(C,R,U)       Original product supply (1000 tons)
NATD0(C)        National food-feed demand (1000 tons)
NATS0(C)        National product supply (1000 tons)
TP(RW,RRW)      Cost of transportation (VND per kg)
MARGPR(C,R,U)   Processing costs (VND per kg)
MARGD(C,R,RR,U) Marketing margin for internal trade (VND per kg)
MARGM(C,R,U)    Marketing margin for imports (VND per kg)
MARGX(C,R,U)    Marketing margin for exports (VND per kg)
MARGW(C)        Margin between world FOB and CIF prices (US$ per ton)
PS0(C,R,U)      Original producer price (VND per kg)
PSB(C,R,U)      Producer price in base scenario (VND per kg)
DFEEDPIG0(F,R,U) Original feed demand for pig only (1000 t)   ;

**Calculate parameter values
NER0            = 23.000 ;
DFOOD0(C,R,U)   = DPC0(C,R,U)*POP0(R,U)*ADJ(C,'FOOD')/1000 ;
DFEED0(F,R,U)   =
      SUM(L,PROD0(L,R,U)*MPAR(L,'FEEDCONV')*FEEDSHARE(L,F)*ADJ(F,'FEED'));
DFEEDPIG0(F,R,U) = SUM(L,PROD0(L,R,U)*MPAR(L,'FEEDCONV')*FEEDSHARE(L,F));

S0(C,R,U)       = PROD0(C,R,U)*MPAR(C,'CONV') ;
D0(C,R,U)       = DFOOD0(C,R,U)+DFEED0(C,R,U) ;
NATD0(C)        = SUM((R,U),D0(C,R,U)) ;
NATS0(C)        = SUM((R,U),S0(C,R,U)) ;
TP(RW,RRW)      = 80.28$(KM(RW,RRW,'ROAD')) + 1.17*KM(RW,RRW,'ROAD')
                + 57.75$(KM(RW,RRW,'SEA'))  +  0.42*KM(RW,RRW,'SEA')
                - 0.000099*KM(RW,RRW,'SEA' )**2 ;
TP(RW,RRW)$(KM(RW,RRW,'LINK')=0) = 9999  ;
TP(RW,RW)                        = 0     ;

MARGPR(C,R,U)   = PDB(C,R,U)*MPAR(C,'PMARGPR') ;
MARGD(C,R,RR,U) = MARGPR(C,R,U) + TP(R,RR)*MPAR(C,'CTA') ;
MARGM(C,R,U)    = MARGPR(C,R,U) + TP('WORLD',R)*MPAR(C,'CTA') ;
MARGX(C,R,U)    = MARGPR(C,R,U) + MPAR(C,'XPRO') + TP(R,'WORLD')*MPAR(C,'CTA') ;
MARGW(C)        = PW0(C,'M')-PW0(C,'X') ;
PS0(C,R,U)      = PD0(C,R,U)*MPAR(C,'CONV')*(1 - MPAR(C,'PMARGPR')) ;
PSB(C,R,U)      = PDB(C,R,U)*MPAR(C,'CONV')*(1 - MPAR(C,'PMARGPR')) ;
SHK(C,R,U)      = 0 ;

DISPLAY MARGPR,MARGD,MARGM,MARGX,MARGW,DFEED0,DFOOD0,PROD0 ;
DISPLAY POP0,YPC0,D0,S0,NATD0,NATS0,TP,KM,PS0,PD0,NER0,PSB,PDB ;

**Calculate FDLVEL(F,L) from LVFDEL(L,F)
PARAMETERS
AVEPS0(C)       Original National Average Producer Price
SUMPROD0(C)     Original National Total Production
FDLVEL(F,L)     Elasticity of feed demand wrt livestock prices ;
AVEPS0(C)       = SUM((R,U), PS0(C,R,U)*S0(C,R,U))/SUM((R,U),S0(C,R,U)) ;
SUMPROD0(C)     = SUM((R,U),PROD0(C,R,U));
FDLVEL(F,L)     = -LVFDEL(L,F)*(AVEPS0(L)/AVEPS0(F))
                 *(SUMPROD0(L)/(SUMPROD0(L)*MPAR(L,'FEEDCONV')*FEEDSHARE(L,F)));

DISPLAY AVEPS0,SUMPROD0,FDLVEL ;

*****************************
***END OF PARAMETER MODULE***
*****************************


