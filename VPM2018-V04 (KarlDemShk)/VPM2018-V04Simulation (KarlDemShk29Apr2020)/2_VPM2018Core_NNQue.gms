***********************************************
* MODULE II: CORE OF PROGRAM TO SOLVE VPM2018 *
***********************************************

*A recursive dynamic spatial equilibrium model
*Three categories of pig farms in relation to types of meat outlets (i.e. TRADPIG,
*COMMPIG & MODPIG), or two types of pig farms in terms of production scale
*(i.e. SMALL FARMS: TRADPIG; LARGE FARMS: COMMPIG & MODPIG), and one maize crop
*(maize food and maize feed)
*Seven regions (including urban & rural areas) and Rest of the World.
*Double log specification of supply and demand functions
*Perfectly elastic demand for exports and imports, and for intra-regional trade
*Mixed complementarity problem for model formulation (no objective function)

*DEFINE OUTPUT OPTIONS

$OFFSYMLIST
$OFFSYMXREF
$OFFUELLIST
$OFFUELXREF
$OFFUPPER
OPTION LIMCOL  = 0 ;
OPTION LIMROW  = 0 ;
OPTION ITERLIM = 10000 ;
OPTION SOLPRINT = on ;
OPTION MCP = MILES  ;

****************************************************************
***CALCULATE THE PARAMETERS USED IN SUPPLY & DEMAND FUNCTIONS***
****************************************************************

PARAMETERS
   AALPHA(F,R,U)    Intercept of crop area function (changes across iterations)
   ABETA(F,FF,R,U)  Elasticity of crop area wrt own & cross output prices
*NNQue2019: add AGAMMA for VPM2018
   AGAMMA(F,L,R,U)  Elasticity of crop area wrt livestock prices
   YALPHA(F,R,U)    Intercept of crop yield function (changes across iterations)
   YBETA(F,R,U)     Elasticity of crop yield wrt its own output price
*NNQue2019: add YGAMMA for VPM2018
   YGAMMA(F,L,R,U)  Elasticity of crop yield wrt livestock prices
   LALPHA(L,R,U)    Intercept of livestock supply (changes across iterations)
   LBETA(L,LL,R,U)  Elas. of livestock supply wrt own & cross output price
   LGAMMA(L,F,R,U)  Elasticity of livestock supply wrt feed input prices
   FALPHA(F,R,U)    Intercept on feed demand
   FBETA(F,FF,R,U)  Elasticity of feed demand wrt own & cross prices
   FGAMMA(F,L,R,U)  Elasticity of feed demand wrt livestock prices
   DALPHA(C,R,U)    Intercept of PC demand function (changes across iterations)
   DBETA(C,CC,R,U)  Elasticity of PC demand wrt own & cross prices
   DGAMMA(C,R,U)    Elasticity of PC demand wrt income  (changes across iterations)
   DDELTA(C,R,U)    Elasticity of demand wrt disease shocks
*NNQue2019: Karl added new parameter "DDELTA(C,R,U)"
   YPC(R,U)         Per capita income (changes across iterations)
   POP(R,U)         Population (changes across iterations)
   NER              Nominal exchange rate (changes across iterations)
   TAX(C,*)         Import-export taxes (in fraction & changes across iterations) ;

*1) Parameters of crop area-yield functions (double-log)
*   NNQue2019: New parameters AGAMMA & YGAMMA are added to allow
*   the connection of feed supply with livestock price.
   AGAMMA(F,L,R,U) = AREALVEL(F,L) ;
   ABETA(F,FF,R,U) = AREAE(F,R) ;
   AALPHA(F,R,U)   = LOG(AREA0(F,R,U)) - SUM(FF,ABETA(F,FF,R,U)*LOG(PSB(FF,R,U)))
                                       - SUM(L,AGAMMA(F,L,R,U)*LOG(PSB(L,R,U))) ;
   YGAMMA(F,L,R,U) = YIELDLVEL(F,L) ;
   YBETA(F,R,U)    = YIELDE(F,R) ;
   YALPHA(F,R,U)   = LOG(YIELD0(F,R,U)) - YBETA(F,R,U)*LOG(PSB(F,R,U))
                                        - SUM(L,YGAMMA(F,L,R,U)*LOG(PSB(L,R,U))) ;
*2) Livestock supply parameters (double-log)
   LGAMMA(L,F,R,U) = LVFDEL(L,F) ;
   LBETA(L,LL,R,U) = LVELAS(L,LL,R) ;
   LALPHA(L,R,U)   = LOG(S0(L,R,U)) - SUM(LL,LBETA(L,LL,R,U)*LOG(PSB(LL,R,U)))
                                    - SUM(F,LGAMMA(L,F,R,U)*LOG(PSB(F,R,U))) ;
*3) Parameters of food demand function  (double-log)
   DDELTA(C,R,U)   = 1 ;
   DGAMMA(C,R,U)   = DYE(C,R,U) ;
   DBETA(C,CC,R,U) = DPE(C,CC,R,U) ;
   DALPHA(C,R,U)   = LOG(DFOOD0(C,R,U))
                   - SUM(CC,DBETA(C,CC,R,U)*LOG(PDB(CC,R,U)))
                   - DGAMMA(C,R,U)*LOG(YPC0(R,U))
                   - LOG(POP0(R,U)*1000)
                   - DDELTA(C,R,U)*LOG(1-SHK(C,R,U));
*NNQue2019: DDELTA maybe no need here (since DDELTA=1)!

*4) Parameters of feed demand function  (double-log)
   FGAMMA(F,L,R,U)  = FDLVEL(F,L)  ;
   FBETA(F,FF,R,U)  = FDELAS(F,FF) ;
   FALPHA(F,R,U)    = LOG(DFEED0(F,R,U))
                    - LOG(SUM(L,S0(L,R,U)))
                    - SUM(FF,FBETA(F,FF,R,U)*LOG(PDB(FF,R,U)))
                    - SUM(L ,FGAMMA(F,L,R,U)*LOG(PSB(L,R,U))) ;
*5) Other macro parameters
   YPC(R,U) = YPC0(R,U) ;
   POP(R,U) = POP0(R,U) ;
   NER      = NER0      ;
   TAX(C,'X') = TAX0(C,'X') ;
   TAX(C,'M') = TAX0(C,'M') ;

***THE CORE SYSTEM OF VPM2018 EQUATIONS & INEQUATIONS***
********************************************************

POSITIVE VARIABLES
   PS(C,R,U)    Producer price (VND per kg)
   PD(C,R,U)    Consumer price (VND per kg)
   TQ(C,R,RR,U) Transport of goods (1000 tons consumer weight CW)
   X(C,R,U)     Exports (1000 tons)
   M(C,R,U)     Imports (1000 tons)
   IXT(C)       Implicit export tax (VND per kg)
   IMT(C)       Implicit import tax (VND per kg) ;
VARIABLES
   DFOOD(C,R,U) Demand for food (1000 tons)
   DFEED(F,R,U) Demand for feed (1000 tons)
   AR(F,R,U)    Planted area of (feed) crops (1000 ha)
   YLD(F,R,U)   Yields of (feed) crops (tons per ha)
   SCR(F,R,U)   Supply of (feed) crops (1000 tons CW)
   SLV(L,R,U)   Supply of livestock (1000 tons CW)
   PW(C)        World (FOB) price (US$ per ton) ;
EQUATIONS
   AREA         Crop area equation
   YIELD        Crop yield equation
   CSUPPLY      Crop supply equation
   LSUPPLY      Livestock supply equation
   FOODDEM      Food demand equation
   FEEDDEM      Feed demand equation (for pig plus adjusment for other animals)
   INFLOW       Shipments into region
   OUTFLOW      Shipments out of region
   DOM_TRADE    Domestic trade
   IMPORTS      Imports
   EXPORTS      Exports
   MQUOTA       Import quota limits
   XQUOTA       Export quota limits ;

AREA(F,R,U)..
   LOG(AR(F,R,U))    =E= AALPHA(F,R,U) + SUM(FF,ABETA(F,FF,R,U)*LOG(PS(FF,R,U)))
                                       + SUM(L,AGAMMA(F,L,R,U)*LOG(PS(L,R,U))) ;
YIELD(F,R,U)..
   LOG(YLD(F,R,U))   =E= YALPHA(F,R,U) + YBETA(F,R,U)*LOG(PS(F,R,U))
                                       + SUM(L,YGAMMA(F,L,R,U)*LOG(PS(L,R,U))) ;
CSUPPLY(F,R,U)..
   SCR(F,R,U)        =E= AR(F,R,U)*YLD(F,R,U)*MPAR(F,'CONV') ;
LSUPPLY(L,R,U)..
   LOG(SLV(L,R,U))   =E= LALPHA(L,R,U) + SUM(LL,LBETA(L,LL,R,U)*LOG(PS(LL,R,U)))
                                       + SUM(F,LGAMMA(L,F,R,U)*LOG(PS(F,R,U )));
FOODDEM(C,R,U)..
   LOG(DFOOD(C,R,U)) =E= DALPHA(C,R,U)
                         + SUM(CC,DBETA(C,CC,R,U)*LOG(PD(CC,R,U)))
                         + DGAMMA(C,R,U)*LOG(YPC(R,U))
                         + LOG(POP(R,U)*1000)
                         + DDELTA(C,R,U)*LOG(1-SHK(C,R,U)) ;
*NNQue2019: Karl added DDELTA=1 & SHK is simply fraction change in intercept
*of DFOOD equation. Maybe no need DDELTA here

FEEDDEM(F,R,U)..
   LOG(DFEED(F,R,U)) =E= FALPHA(F,R,U)
                         + LOG(SUM(L,SLV(L,R,U)))
                         + SUM(FF,FBETA(F,FF,R,U)*LOG(PD(FF,R,U)))
                         + SUM(L ,FGAMMA(F,L,R,U)*LOG(PS(L,R,U )))   ;
INFLOW(C,R,U)..
   SUM(RR,TQ(C,RR,R,U)) + M(C,R,U) =G= DFOOD(C,R,U)
                                 + SUM(F,IDEN1(C,F)*DFEED(F,R,U));
OUTFLOW(C,R,U)..
   SUM(L,IDEN2(C,L)*SLV(L,R,U)) + SUM(F,IDEN1(C,F)*SCR(F,R,U))
                                  =G= SUM(RR,TQ(C,R,RR,U)) + X(C,R,U) ;
DOM_TRADE(C,R,RR,U)..
   PS(C,R,U)/MPAR(C,'CONV') + MARGD(C,R,RR,U) =G= PD(C,RR,U)   ;
IMPORTS(C,R,U)..
   (PW(C)+MARGW(C))*NER*(1+TAX(C,'M'))+ IMT(C)+MARGM(C,R,U) =G= PD(C,R,U) ;
EXPORTS(C,R,U)..
   PS(C,R,U)/MPAR(C,'CONV')+MARGX(C,R,U)+IXT(C) =G= PW(C)*NER*(1-TAX(C,'X')) ;
MQUOTA(C)..
   QUOTA(C,'M') =G= SUM((R,U),M(C,R,U)) ;
XQUOTA(C)..
   QUOTA(C,'X') =G= SUM((R,U),X(C,R,U)) ;

**FIXED VALUES
PW.FX(C) = PW0(C,'X') ;

**LOWER BOUNDS
PD.LO(C,R,U)   = 1 ;
PS.LO(C,R,U)   = 1 ;
TQ.LO(C,R,R,U) = 0 ;

**INITIAL VALUES
PD.L(C,R,U)     = PDB(C,R,U) ;
PS.L(C,R,U)     = MPAR(C,'CONV')*(PDB(C,R,U) - MARGD(C,R,R,U)) ;
DFOOD.L(C,R,U)  = DFOOD0(C,R,U) ;
DFEED.L(F,R,U)  = DFEED0(F,R,U) ;
AR.L(F,R,U)     = AREA0(F,R,U) ;
YLD.L(F,R,U)    = YIELD0(F,R,U) ;
SLV.L(L,R,U)    = S0(L,R,U) ;
SCR.L(F,R,U)    = S0(F,R,U) ;

**DEFINE AND SOLVE MODEL:
MODEL PIGMKT /  AREA, YIELD, CSUPPLY, LSUPPLY, FOODDEM, FEEDDEM,
                INFLOW.PD, OUTFLOW.PS, DOM_TRADE.TQ,
                IMPORTS.M, EXPORTS.X,
                XQUOTA.IXT,
                MQUOTA.IMT / ;

**************************************************************************
* DEFINE SET OF DYNAMIC PARAMETERS TO STORE VALUES FROM EACH TIME PERIOD *
**************************************************************************

PARAMETERS
**Declare dynamic parameters
   SCRT(F,R,U,T)    Supply of crops at time T (1000 tons CW)
   SLVT(L,R,U,T)    Supply of livestock at time T (1000 tons CW)
   DFOODT(C,R,U,T)  Demand for food at time T (1000 tons CW)
   DFEEDT(F,R,U,T)  Demand for feed at time T (1000 tons CW)
   TQT(C,R,RR,U,T)  Transport from one region to another at time T (1000 tons)
   XT(C,R,U,T)      Exports at time T (1000 tons CW)
   MT(C,R,U,T)      Imports at time T (1000 tons CW)
   PST(C,R,U,T)     Producer price at time T (VND per kg)
   PDT(C,R,U,T)     Consumer price at time T (VND per kg)
   PWT(C,T)         World (FOB) price at time T (US$ per ton)
   YPCT(R,U,T)      Income per capita at time T (mill. VND per person per year)
   POPT(R,U,T)      Population at time T (1000 inhabitants)
   NERT(T)          NER at time T (1000 VND per US$)                  ;

**Beginning of loop for multiple simulations
LOOP(T,
**Shift demand curve out by increasing YPC and POP over time
   YPC(R,U) = YPC0(R,U)*(1+YGM*YGR(R,U))**(ord(T)-1) ;
   POP(R,U) = POP0(R,U)*(1+PGM*PGR(R,U))**(ord(T)-1) ;
   TAX(C,'X') = TAX0(C,'X')*(1+TAXGR(C,'X'))**(ord(T)-1)  ;
   TAX(C,'M') = TAX0(C,'M')*(1+TAXGR(C,'M'))**(ord(T)-1)  ;
   MARGD(L,R,RR,U) = MARGDT(L,R,RR,U,T) ;
*NNQue2019: Karl added MARGDT (Domestic Trade Margin at time T for
*trade "BAN" Shock!

**Change the NER over time
   NER      = NER0*(1+NERGR)**(ord(T)-1) ;

**Shift supply curve out by increasing alpha to reflect productivity gains
*NNQue2019: karl replace Scale Growth SGR with SGRT (scale growth at time T)
*  AALPHA(F,R,U) = AALPHA(F,R,U)+LOG((1+SGR(F))**(ord(T)-1)) ;
*  LALPHA(L,R,U) = LALPHA(L,R,U)+LOG((1+TGR(L))**(ord(T)-1))
*                + LOG((1+SGR(L))**(ord(T)-1));
   AALPHA(F,R,U) = AALPHA(F,R,U)+LOG((1+SGRT(F,R,U,T))**(ord(T)-1)) ;
*NNQue2020 add TGRT(C,T)
*  YALPHA(F,R,U) = YALPHA(F,R,U)+LOG((1+TGR(F))**(ord(T)-1)) ;
   YALPHA(F,R,U) = YALPHA(F,R,U)+LOG((1+TGRT(F,T))**(ord(T)-1)) ;
*  LALPHA(L,R,U) = LALPHA(L,R,U) + LOG((1+SGRT(L,R,U,T))**(ord(T)-1))
*                                + LOG((1+TGR(L))**(ord(T)-1)) ;
   LALPHA(L,R,U) = LALPHA(L,R,U) + LOG((1+SGRT(L,R,U,T))**(ord(T)-1))
                                 + LOG((1+TGRT(L,T))**(ord(T)-1));

**Reduce income elasticity for traditional pigs for urbanization scenario
   DGAMMA(C,R,U)  = DYE(C,R,U)*DYEC(C,U)*(1+DYEG(C,U))**(ord(T)-1) ;
*  DDELTA(C,R,U)  = 1 ;
*NNQue2019: "DDELTA(C,R,U)  = 1" is already declared above
   SHK(C,R,U) = SHKT(C,R,U,T) ;

DISPLAY SHK ;

**Adjust demand intercept to reflect new DGAMMA
   DALPHA(C,R,U)  = LOG(DFOOD0(C,R,U))
                  - SUM(CC,DBETA(C,CC,R,U)*LOG(PDB(CC,R,U)))
                  - DGAMMA(C,R,U)*LOG(YPC0(R,U))
                  - LOG(POP0(R,U)*1000)  ;
*Test             - DDELTA(C,R,U)*LOG(1)  ;
*NNQue2019: Karl put LOG(1)=0 make DALPHA do not change.
*Thus, the "- DDELTA(C,R,U)*LOG(1)" could be omitted.

SOLVE PIGMKT USING MCP ;

**Define set of dynamic parameters
   SCRT(F,R,U,T)    = SCR.L(F,R,U)  ;
   SLVT(L,R,U,T)    = SLV.L(L,R,U) ;
   DFOODT(C,R,U,T)  = DFOOD.L(C,R,U) ;
   DFEEDT(F,R,U,T)  = DFEED.L(F,R,U) ;
   TQT(C,R,RR,U,T)  = TQ.L(C,R,RR,U) ;
   XT(C,R,U,T)      = X.L(C,R,U) ;
   MT(C,R,U,T)      = M.L(C,R,U) ;
   PDT(C,R,U,T)     = PD.L(C,R,U) ;
   PST(C,R,U,T)     = PS.L(C,R,U) ;
   PWT(C,T)         = PW.L(C) ;
   YPCT(R,U,T)      = YPC(R,U);
   POPT(R,U,T)      = POP(R,U) ;
   NERT(T)          = NER ;

**Initialize values of variables for next period based on current period
   SCR.L(F,R,U)     = SCRT(F,R,U,T) ;
   SLV.L(L,R,U)     = SLVT(L,R,U,T) ;
   DFOOD.L(C,R,U)   = DFOODT(C,R,U,T) ;
   DFEED.L(F,R,U)   = DFEEDT(F,R,U,T) ;
   TQ.L(C,R,RR,U)   = TQT(C,R,RR,U,T) ;
   X.L(C,R,U)       = XT(C,R,U,T) ;
   M.L(C,R,U)       = MT(C,R,U,T) ;
   PD.L(C,R,U)      = PDT(C,R,U,T) ;
   PS.L(C,R,U)      = PST(C,R,U,T) ;

**FIXED VALUES IN LOOP
PW.FX(C)  = PW.L(C)*(1+PWGM(C)*PWGR(T+1,C)) ;
*PW.FX(C)  = PW.L(C)*(1+PWGM*PWGR(T,C)) ;
*NNQue: Since in LOOP" using T index, "fixed values" after SOLVE is lag by one
*period, thus for define fixed value we need to use "T+1" instead of "T".
*The VPM2010 has this kind of problem and needs to be corrected

$ontext
*VPM2010 version uses the following:
*PW.FX(C)  = PW0(C,'X')*(1+PWGR(C))**TT(T) ;
*The corrected formula is as follow (check the PWT result)
PW.FX(C)  = PW0(C,'X')*(1+PWGR(C))**(TT(T)+1) ;
*Alternative way using ord(T)
*PW.FX(C)  = PW0(C,'X')*(1+PWGR(C))**ord(T) ;
$offtext

**LOWER BOUNDS
PD.LO(C,R,U) = 1 ;
PS.LO(C,R,U) = 1 ;

DISPLAY YPCT, POPT,NERT, PWT ;
DISPLAY MARGPR, MARGD, MARGM, MARGX, MARGW ;
DISPLAY TAX ;

*** END OF LOOP***

) ;


************************
***END OF CORE MODULE***
************************

*NNQue2019:
*Disease-Induced Shocks used for Scenario Simulations:
******************************************************

*1) DDELTA Elasticity of food demand wrt disease shocks is set to be 1 (Perfect elastic)
*DDELTA could be omitted!
*2) SHK (with DDELTA=1) is designed to change Intercept of Demand function
*3) SGRT Scaling Growth (i.e. Change in Intercept of Supply Function)
*4) MARGD(L,R,RR,U) = MARGDT(L,R,RR,U,T) or = MARGDT(L,R,RR,U,'2019')
*Increasing Domestic Trade Margin at time T (e.g. 2019) to simulate the
*Trade BAN during ASF Outbreak in 2019.

*NNQue: Change in Intercept of Pigmeat Demand Function due to ASF
*(African Swine Fever) for the case of VNM might be specific (consumers might
*partially shift from TRADPIG/COMMPIG to MODPIG pork).
*SHKT(L,R,U,T) would be specific, e.g. SHKT('MODPIG',R,'URBAN','2019') <0;
*SHKT('TRADPIG',R,'URBAN','2019') <0 and SHKT('COMMPIG',R,'URBAN','2019') >0
*TABLE SHKT(C,R,'URBAN','2019')
*            NMM    RRD   NCC   SCC   SH    SE    MRD
*TRADPIG     0.05   0.05  0.05  0.05  0.05  0.05  0.05
*COMMPIG     0.05  0.05   0.05  0.05  0.05  0.05  0.05
*MODPIG      -0.1  -0.1   -0.1  -0.1  -0.1  -0.1  -0.1

*Change the MARGD(L,R,RR,U) by setting Trade-Prohibited High Values for
*MARGDT(,L,R,RR,U,T) at time T (says, 2019)
