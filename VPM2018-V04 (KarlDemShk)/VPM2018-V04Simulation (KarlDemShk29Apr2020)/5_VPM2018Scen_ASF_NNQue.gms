*************************************
* MODULE IV: PROGRAM TO RUN VPM2018 *
*************************************

$TITLE OPTION 0:  SCENARIO with ASF in 2019
$title 'text'
$SETGLOBAL SIM_NAME SIM_BASE
$INCLUDE "1_VPM2018Input_NNQue.gms"

* ** ** ** ** ** ** * PARAMETER CHANGE * ** ** ** ** ** ** ** ** ** *

*Define set of parameters for policy shocks (Growth rate assumptions)
PARAMETERS
   SIMULATION(SIMS) Simulation run for batch mode
*  TAX(C,*)      Import and export taxes (in fraction)
   QUOTA(C,*)    Import and export quotas (1000 tons)
*   TGR(C)        Technological growth rate for each commodity (fraction)
*NNQue2020 add TGRT(C,T) and remove TGR(C)
   TGRT(C,T)     Commodity Technological growth rate at time T (fraction)
*  SGR(C)        NNQue add supply scale growth (times)

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

*Set YGM=1.527 to make annual income growth rate (YGR) increase from 5% to 7.5%
*  YGM          = 1.527 ;
*World prices annual growth rate would reduce by 1 percent point due to FTAs,
*i.e. from 2.08% & -1.32% to 1.08% & -2.32% for maize & pork respectively.
*Set PWGM=0.5202 to make PWGR for maize change from 2.08% to 1.08%
*Set PWGM=1.7571 to make PWGR for pork change from -1.32% to -2.32%
*   (-0.0232=-0.0132*1.7571)
$ontext
   PWGM('MAIZE')   = 0.5202 ;
   PWGM('TRADPIG') = 1.7571 ;
   PWGM('COMMPIG') = 1.7571 ;
   PWGM('MODPIG')  = 1.7571 ;
$offtext

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
*$ontext
   TAXGR(C,'X')       = 0 ;
   TAXGR(C,'M')       = 0 ;
*$offtext

*Set TAXGR =-0.999999 to make tax(C,*)=0 after base period of 2014
$ontext
  TAXGR(C,'X')       = -0.999999 ;
  TAXGR(C,'M')       = -0.999999 ;
$offtext

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
*Change DYE for COMMPIG & MODPIG to 2.3 & TRADPIG to 0.6
*  DYEC('MAIZE',U)    =  1.000 ;
*  DYEC('TRADPIG',U)  =  1.000 ;
*  DYEC('TRADPIG',U)  =  0.4812 ;
*  DYEC('COMMPIG',U)  =  1.6726 ;
*  DYEC('MODPIG',U)   =  1.5205 ;
*NNQue:
*Set DYEC=0.4812 to change DYE('TRADPIG') from 1.247 to 0.6
*Set DYEC=1.6726 to change DYE('COMMPIG') from 1.375 to 2.3
*Set DYEC=1.5205 to change DYE('MODPIG')  from 1.513 to 2.3


** SETTTNG DISEASE-RELATED SHOCKS **
************************************

*1) Pigmeat supply shocks (added June 2019):
*$ontext
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
*$offtext

*2) Pigmeat Demand shocks (positive value means X% shock)
  SHKT(C,R,U,T)   = 0 ;
$ontext
*NNQue's version of demand shocks:
*It seems that on the average of whole 2019 year Vietnamese consumers did not
*constrain much from pork consuming due to ASF (as it does not iffect human),
*but some more cautious urban consumers partially shifted from consuming
*"warm pork" to consuming "supermarket porks".
  SHKT("TRADPIG",R,U,"2019") = 0.05 ;
  SHKT("COMMPIG",R,U,"2019") = 0.05 ;
  SHKT("MODPIG",R,U,"2019") = -0.10 ;
$offtext
*Karl's vesion of demand shocks
  SHKT("TRADPIG",R,U,"2019") = 0.2 ;
  SHKT("COMMPIG",R,U,"2019") = 0.2 ;
  SHKT("MODPIG",R,U,"2019") = -0.1 ;

*3) export shock to simulate external movement ban
   QUOTAT(C,"X",T) = QUOTA(C,"X") ;
*  QUOTAT("MODPIG","X","2019") = 0 ;
*  QUOTA("MODPIG","X") = QUOTAT("MODPIG","X","2019") ;

*4) domestic trade shock to simulate internal movement ban
   MARGDT(L,R,RR,U,T) = MARGD(L,R,RR,U) ;
*$ontext
   MARGDT("TRADPIG","NMM","RRD",U,"2019") = 999999;
   MARGDT("TRADPIG","MRD","SE",U,"2019")  = 999999;
*NNQue2019 added pig movement ban from MRD to SE
*$offtext

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
