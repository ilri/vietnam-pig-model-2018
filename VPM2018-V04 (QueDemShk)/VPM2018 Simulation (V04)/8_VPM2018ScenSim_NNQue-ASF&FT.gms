*************************************
* MODULE IV: PROGRAM TO RUN VPM2018 *
*************************************

$TITLE OPTION 0:  BASE SCENARIO
$title 'text'
$SETGLOBAL SIM_NAME SIM_BASE
$INCLUDE "1_VPM2018Input_NNQue.gms"

* ** ** ** ** ** ** * PARAMETER CHANGE * ** ** ** ** ** ** ** ** ** *

*Define set of parameters for policy shocks (Growth rate assumptions)
PARAMETERS
   SIMULATION(SIMS) Simulation run for batch mode
   QUOTA(C,*)    Import and export quotas (1000 tons)
   TGRT(C,T)     Commodity Technological growth rate at time T (fraction)

** Added parameters by KMR to construct Diseased-Induced Shocks
   SGRT(C,R,U,T)      Supply shock at time T
   SHKT(C,R,U,T)      Demand shock at time T
   QUOTAT(C,*,T)      Transport costs at time T (simulates external movement bans)
   MARGDT(C,R,RR,U,T) Internal margins at time T (simulates internal movement bans)
   NERGR         Growth rate of nominal exchange rate (fraction)
   DYEG(C,U)     Annual income elasticity grow
   DYEC(C,U)     Income elasticity multiplier
   DYEGT(C,R,U,T) Income elasticity multiplier with shocks
   DALPHAT(C,R,U,T)
   PGM           Population growth multiplier
   YGM           Per capita income growth multiplier
   PWGM(C)       World price growth multiplier
   TAXGR(C,*)    Growth rate of import-export tax rate (fraction)    ;

   SIMULATION("SIM") = 0 ;
*Impose changes in regional PGR, YGR consistent with changes in national growth
   PGM          = 1.0 ;
   YGM          = 1.0 ;
   PWGM(C)      = 1.0 ;

*Impose trade quota (1000 tons)
   QUOTA('MAIZE'  ,'X') = 10000 ;
   QUOTA('TRADPIG','X') = 0     ;
   QUOTA('COMMPIG','X') = 0     ;
   QUOTA('MODPIG' ,'X') = 40000 ;
   QUOTA('MAIZE'  ,'M') = 40000 ;
   QUOTA('TRADPIG','M') = 0     ;
   QUOTA('COMMPIG','M') = 0     ;
   QUOTA('MODPIG' ,'M') = 10000 ;

*Change in import-export tax across iterations
*Set TAXGR =-0.999999 to make tax(C,*)=0 after base period of 2014
  TAXGR(C,'X')       = -0.999999 ;
  TAXGR(C,'M')       = -0.999999 ;

**Supply technology growth(Fraction)
************************************
*TGRT Setting Option-01 in VPM2018-V04:
   TGRT(C,T)             =  0     ;
   SGRT(C,R,U,T)         =  0     ;
*Supply Scale Growth for T2 (i.e. 2026-30): Curtail the TradPig Mode
   SGRT("TRADPIG",R,U,T2) = -0.015 ;

*Selected option of TGRT Setting Assumption for VPM2018-V04:
*(In this TGRT or TFP growth is unchanged between 2 periods, i.e. 2019-25 & 2026-30)
*In 2019-25 pig production growth is almost same as in MARD's Master Plan 2020-30,
*but in the next period of 2026-30 it is a bit higher than that of the previous
*period of 2019-25, while the MARD's Master Plan 2020-30 shows an opposite trend
*of pig production development.
   TGRT("MAIZE",T)       =  0.005 ;
   TGRT("TRADPIG",T)     =  0.000 ;
   TGRT("COMMPIG",T)     =  0.010 ;
   TGRT("MODPIG",T)      =  0.015 ;

*Exchange Rate (Fraction)
   NERGR              =  0.02 ;

**Parameters for changing demand elasticity assumptions
*DYEG makes income elasticity grow or decline over time (.01 = 1% annual growth)
*  DYEG(C,U)          =  0.0 ;
*In baseline asssumption, demand income elasticity growth for ModPig  is 1% p.a.
   DYEG("MAIZE",U)    =  0.00 ;
   DYEG("TRADPIG",U)  =  0.00 ;
   DYEG("COMMPIG",U)  =  0.00 ;
   DYEG("MODPIG",U)   =  0.01 ;

*DYEC makes income elasticity higher or lower (Ex.: 1.5 = 50% higher)
   DYEC(C,U)          =  1.0 ;

** SETTTNG DISEASE-RELATED SHOCKS **
************************************

*1) Pigmeat supply shocks (added June 2019):
*Source: derived from data of DAH, Dec. 2019 and adjusted to match with GSO's
*report on 2019 pig production of 3289.7 thous. tons LW
*NNQue2019: assume 90% of total ASF-Induced Losses from TradPig and
* only 10% from CommPig. ModPig is not innfected.
   SGRT("TRADPIG","NMM",U,"2019")     =  -0.199 ;
   SGRT("COMMPIG","NMM",U,"2019")     =  -0.062;
   SGRT("TRADPIG","RRD",U,"2019")     =  -0.900 ;
   SGRT("COMMPIG","RRD",U,"2019")     =  -0.310 ;
   SGRT("TRADPIG","NCC",U,"2019")     =  -0.315 ;
   SGRT("COMMPIG","NCC",U,"2019")     =  -0.041 ;
   SGRT("TRADPIG","SCC",U,"2019")     =  -0.261 ;
   SGRT("COMMPIG","SCC",U,"2019")     =  -0.029 ;
   SGRT("TRADPIG","CH",U,"2019")      =  -0.247 ;
   SGRT("COMMPIG","CH",U,"2019")      =  -0.016 ;
   SGRT("TRADPIG","SE",U,"2019")      =  -0.922 ;
   SGRT("COMMPIG","SE",U,"2019")      =  -0.105 ;
   SGRT("TRADPIG","MRD",U,"2019")     =  -0.390 ;
   SGRT("COMMPIG","MRD",U,"2019")     =  -0.081 ;
   SGRT("MODPIG",R,U,T)               =   0.000 ;

*2) Pigmeat Demand shocks (positive value means X% shock)
   SHKT(C,R,U,T)   = 0 ;
*Reduce Demand Scale for TradPig/CommPig and Increase Demand Scale for ModPig
   SHKT("TRADPIG",R,U,"2019") = 0.05 ;
   SHKT("COMMPIG",R,U,"2019") = 0.05 ;
   SHKT("MODPIG",R,U,"2019") = -0.10 ;

*3) export shock to simulate external movement ban
   QUOTAT(C,"X",T) = QUOTA(C,"X") ;

*4) domestic trade shock to simulate internal movement ban
   MARGDT(L,R,RR,U,T) = MARGD(L,R,RR,U) ;
   MARGDT("TRADPIG","NMM","RRD",U,"2019") = 999999;
   MARGDT("TRADPIG","MRD","SE",U,"2019")  = 999999;

*Scaling down maize production in consistent with GSO's 2019 preliminary figure
*(i.e. maize output from 4877 in 2018 to 4760 thous.ton in 2019.
   SGRT("MAIZE","NMM",U,"2019")       =  -0.031 ;
   SGRT("MAIZE","RRD",U,"2019")       =  -0.045 ;
   SGRT("MAIZE","NCC",U,"2019")       =  -0.048 ;
   SGRT("MAIZE","SCC",U,"2019")       =  -0.022 ;
   SGRT("MAIZE","CH",U,"2019")        =  -0.018 ;
   SGRT("MAIZE","SE",U,"2019")        =  -0.029 ;
   SGRT("MAIZE","MRD",U,"2019")       =  -0.013 ;

* ** ** ** ** ** ** * END OF PARAMETER CHANGE * ** ** ** ** ** ** **

$INCLUDE "2_VPM2018Core_NNQue"
$INCLUDE "3_VPM2018Output_NNQue"


*NNQue2019: Karl added
DALPHAT(C,R,U,T) = DALPHA(C,R,U) ;

PARAMETER
FARMYT(T,L)   NNQue2019: Total National Livestock (3 types) Revenue at time T?
FARMRYT(T,L,R) NNQue2019: Total Regional Livestock (3 types) Revenue at time T?
 ;
FARMYT(T,L) = PSTN(T,L)*SLVTN(T,L) ;
FARMRYT(T,L,R) = PSTR(T,L,R)*SLVTR(T,L,R) ;

DISPLAY DALPHAT, MARGDT, SHKT, MPAR, FARMYT, FARMRYT;
DISPLAY PSTR, SLVTR, SGRT, LALPHA;
