****************************************************************
* MODULE III: PROGRAM TO EXTRACT SIMULATION RESULTS INTO EXCEL *
****************************************************************
OPTION LIMCOL  = 0 ;
*column printouts
OPTION LIMROW  = 0 ;

PARAMETERS
*Define set of parameters to calculate percentage change each year
   CPD(C,R,U,T)   Comparison of retail prices across time (pct change)
   CPS(C,R,U,T)   Comparison of farmgate prices across time (pct change)
   CX(C,R,U,T)    Comparision of exports over time (pct change)
   CM(C,R,U,T)    Comparison of imports over time (pct change)
   CFOOD(C,R,U,T) Comparison of food demand over time (pct change)
   CFEED(F,R,U,T) Comparison of feed demand over time (pct change)
   CSCR(F,R,U,T)  Comparison of crop supply over time (pct change)
   CSLV(L,R,U,T)  Comparison of livestock supply over time (pct change)
*Define set of national summary statistics for each period
   DFOODTN(T,C)   National total food demand at time T  (1000 tons)
   DFEEDTN(T,C)   National total feed demand at time T  (1000 tons)
   SCRTN(T,F)     National total crop supply at time T  (1000 tons)
   SLVTN(T,L)     National total livestock supply at time T  (1000 tons)
   PSTN(T,C)      National average producer price at time T (D per kg)
   PDTN(T,C)      National average consumer price at time T  (D per kg)
   XTN(T,C)       National total exports at time T  (1000 tons)
   MTN(T,C)       National total imports at time T  (1000 tons)
   POPTN(T,U)     National population at time T
   MARGXT(C,R,U,T) Marketing margin for exports at time T (D per kg)
   PXTN(T,C)      Export parity price at time T ($ per ton)
   MARGWT(C,T)    Margin between world FOB and CIF prices at time T ($ per ton)
   MARGMT(C,R,U,T) Marketing margin for imports at time T (D per kg)
   PMTN(T,C)      Import parity price at time T ($ per ton)

*Define set of regional summary statistics for each period
   DFOODTR(T,C,R)  Regional food demand at time T  (1000 tons)
   DFEEDTR(T,C,R)  Regional feed demand at time T  (1000 tons)
   SCRTR(T,F,R)    Regional crop supply at time T  (1000 tons)
   SLVTR(T,L,R)    Regional livestock supply at time T  (1000 tons)
   PSTR(T,C,R)     Regional producer price at time T (D per kg)
   PDTR(T,C,R)     Regional consumer price at time T  (D per kg)
   XTR(T,C,R)      Regional exports at time T  (1000 tons)
   MTR(T,C,R)      Regional imports at time T  (1000 tons)
   TQTR(T,C,R,RR)  Regional TQ in-out (exclude R to R) at time T  (1000 tons)
   TQXTR(T,C,R,RR) Regional TQ outflow at time T  (1000 tons)
   TQMTR(T,C,RR,R) Regional TQ inflow at time T  (1000 tons)

*Define set of national summary output tables
   D_NTABLE(T,*)  National summary demand table
   S_NTABLE(T,*)  National summary supply table
   DP_NTABLE(T,*) National summary demand price table
   SP_NTABLE(T,*) National summary supply price table
   XM_NTABLE(T,*) National summary trade table
   POP_NTABLE(T,*) National population summary trade table
   PX_NTABLE(T,*)  National export parity summary table ($ per ton)
   PM_NTABLE(T,*)  National import parity summary table ($ per ton)

*Define set of summary regional output tables
   D_RTABLE(T,R,*)         Regional summary demand table
   S_RTABLE(T,R,*)         Regional summary supply table
   DP_RTABLE(T,R,*)        Regional summary demand price table
   SP_RTABLE(T,R,*)        Regional summary supply price table
   XM_RTABLE(T,R,*)        Regional summary trade table
   TQX_RTABLE(R,RR,T,*)    Regional summary TQ-out table
   TQM_RTABLE(RR,R,T,*)    Regional summary TQ-in table
   NETOUTFL_RTABLE(T,R,*)  Regional summary net outflow table ;

*Calculate percentage change in regional values
   CPD(C,R,U,T)$PDT(C,R,U,T-1)      = 100*(PDT(C,R,U,T)/PDT(C,R,U,T-1)-1) ;
   CPS(C,R,U,T)$PST(C,R,U,T-1)      = 100*(PST(C,R,U,T)/PST(C,R,U,T-1)-1) ;
   CX(C,R,U,T)$XT(C,R,U,T-1)        = 100*(XT(C,R,U,T)/XT(C,R,U,T-1)-1) ;
   CM(C,R,U,T)$MT(C,R,U,T-1)        = 100*(MT(C,R,U,T)/MT(C,R,U,T-1)-1) ;
   CFOOD(C,R,U,T)$DFOODT(C,R,U,T-1) = 100*(DFOODT(C,R,U,T)/DFOODT(C,R,U,T-1)-1);
   CFEED(F,R,U,T)$DFEEDT(F,R,U,T-1) = 100*(DFEEDT(F,R,U,T)/DFEEDT(F,R,U,T-1)-1);
   CSCR(F,R,U,T)$SCRT(F,R,U,T-1)    = 100*(SCRT(F,R,U,T)/SCRT(F,R,U,T-1)-1) ;
   CSLV(L,R,U,T)$SLVT(L,R,U,T-1)    = 100*(SLVT(L,R,U,T)/SLVT(L,R,U,T-1)-1) ;

*Calculate national totals for summary tables
   DFOODTN(T,C)   = SUM((R,U),DFOODT(C,R,U,T)) ;
   DFEEDTN(T,F)   = SUM((R,U),DFEEDT(F,R,U,T)) ;
   SCRTN(T,F)     = SUM((R,U),SCRT(F,R,U,T)) ;
   SLVTN(T,L)     = SUM((R,U),SLVT(L,R,U,T)) ;
   PSTN(T,F)      = SUM((R,U),PST(F,R,U,T)*SCRT(F,R,U,T)/SCRTN(T,F)) ;
   PSTN(T,L)      = SUM((R,U),PST(L,R,U,T)*SLVT(L,R,U,T)/SLVTN(T,L) ) ;
   PDTN(T,C)      = SUM((R,U),PDT(C,R,U,T)*DFOODT(C,R,U,T)/DFOODTN(T,C)) ;
   XTN(T,C)       = SUM((R,U),XT(C,R,U,T)) ;
   MTN(T,C)       = SUM((R,U),MT(C,R,U,T)) ;
   POPTN(T,U)     = SUM(R,POPT(R,U,T)) ;
   MARGXT(C,R,U,T) = MARGX(C,R,U) ;
   PXTN(T,C)       = (SUM((R,U),PST(C,R,U,T)/MPAR(C,'CONV')+MARGXT(C,R,U,T))/14)
                   /(NERT(T)*(1-TAX(C,'X')))  ;
   MARGMT(C,R,U,T) = MARGM(C,R,U) ;
   MARGWT(C,T)     = MARGW(C) ;
   PMTN(T,C)       = (PWT(C,T)+MARGWT(C,T))*(1+TAX(C,'M'))
                   + (SUM((R,U),MARGMT(C,R,U,T))/14)/NERT(T) ;

*Calculate regional totals for summary tables
   DFOODTR(T,C,R)  = SUM(U,DFOODT(C,R,U,T)) ;
   DFEEDTR(T,F,R)  = SUM(U,DFEEDT(F,R,U,T)) ;
   SCRTR(T,F,R)    = SUM(U,SCRT(F,R,U,T)) ;
   SLVTR(T,L,R)    = SUM(U,SLVT(L,R,U,T)) ;
   PSTR(T,F,R)     = SUM(U,PST(F,R,U,T)*SCRT(F,R,U,T)/SCRTR(T,F,R)) ;
   PSTR(T,L,R)     = SUM(U,PST(L,R,U,T)*SLVT(L,R,U,T)/SLVTR(T,L,R) ) ;
   PDTR(T,C,R)     = SUM(U,PDT(C,R,U,T)*DFOODT(C,R,U,T)/DFOODTR(T,C,R)) ;
   XTR(T,C,R)      = SUM(U,XT(C,R,U,T)) ;
   MTR(T,C,R)      = SUM(U,MT(C,R,U,T)) ;
   TQTR(T,C,R,RR)  = SUM(U,TQT(C,R,RR,U,T)) ;
   TQXTR(T,C,R,RR) = SUM(U,TQT(C,R,RR,U,T)) ;
   TQMTR(T,C,RR,R) = SUM(U,TQT(C,RR,R,U,T)) ;
option decimals=1;
   TQTR(T,C,R,R)   = 0 ;

*Construct national demand summary table
   D_NTABLE(T,"D_TP")  = DFOODTN(T,"TRADPIG") ;
   D_NTABLE(T,"D_CP")  = DFOODTN(T,"COMMPIG") ;
   D_NTABLE(T,"D_MP")  = DFOODTN(T,"MODPIG") ;
   D_NTABLE(T,"D_MZH") = DFOODTN(T,"MAIZE") ;
   D_NTABLE(T,"D_MZL") = DFEEDTN(T,"MAIZE") ;
*Construct national supply summary table
   S_NTABLE(T,"S_TP")  = SLVTN(T,"TRADPIG") ;
   S_NTABLE(T,"S_CP")  = SLVTN(T,"COMMPIG") ;
   S_NTABLE(T,"S_MP")  = SLVTN(T,"MODPIG") ;
   S_NTABLE(T,"S_MZ")  = SCRTN(T,"MAIZE") ;
*Construct national demand price summary table
   DP_NTABLE(T,"DP_TP")  = PDTN(T,"TRADPIG") ;
   DP_NTABLE(T,"DP_CP")  = PDTN(T,"COMMPIG") ;
   DP_NTABLE(T,"DP_MP")  = PDTN(T,"MODPIG") ;
   DP_NTABLE(T,"DP_MZ")  = PDTN(T,"MAIZE") ;
*Construct national supply price summary table
   SP_NTABLE(T,"SP_TP")  = PSTN(T,"TRADPIG") ;
   SP_NTABLE(T,"SP_CP")  = PSTN(T,"COMMPIG") ;
   SP_NTABLE(T,"SP_MP")  = PSTN(T,"MODPIG") ;
   SP_NTABLE(T,"SP_MZ")  = PSTN(T,"MAIZE") ;
*Construct national trade summary table
   XM_NTABLE(T,"NX_TP")  = XTN(T,"TRADPIG")-MTN(T,"TRADPIG") +0.001 ;
   XM_NTABLE(T,"NX_CP")  = XTN(T,"COMMPIG")-MTN(T,"COMMPIG") +0.001 ;
   XM_NTABLE(T,"NX_MP")  = XTN(T,"MODPIG") -MTN(T,"MODPIG")  +0.001 ;
   XM_NTABLE(T,"NX_MZ")  = XTN(T,"MAIZE")  -MTN(T,"MAIZE")   +0.001 ;
*Construct national POP summary table
   POP_NTABLE(T,"POP_U")   = POPTN(T,"URBAN")     ;
   POP_NTABLE(T,"POP_R")   = POPTN(T,"RURAL")     ;
   POP_NTABLE(T,"POP_T")   = POPTN(T,"URBAN") + POPTN(T,"RURAL")     ;
*Construct national PXTN (VNM parity export price) summary table
   PX_NTABLE(T,"PX_TP")    = PXTN(T,"TRADPIG")  ;
   PX_NTABLE(T,"PX_CP")    = PXTN(T,"COMMPIG")  ;
   PX_NTABLE(T,"PX_MP")    = PXTN(T,"MODPIG")  ;
   PX_NTABLE(T,"PX_MZ")    = PXTN(T,"MAIZE")  ;
*Construct national PMTN (VNM parity import price) summary table
   PM_NTABLE(T,"PM_TP")    = PMTN(T,"TRADPIG")  ;
   PM_NTABLE(T,"PM_CP")    = PMTN(T,"COMMPIG")  ;
   PM_NTABLE(T,"PM_MP")    = PMTN(T,"MODPIG")  ;
   PM_NTABLE(T,"PM_MZ")    = PMTN(T,"MAIZE")  ;
*Construct regional demand summary table
   D_RTABLE(T,R,"D_TP")  = DFOODTR(T,"TRADPIG",R) ;
   D_RTABLE(T,R,"D_CP")  = DFOODTR(T,"COMMPIG",R) ;
   D_RTABLE(T,R,"D_MP")  = DFOODTR(T,"MODPIG",R) ;
   D_RTABLE(T,R,"D_MZH") = DFOODTR(T,"MAIZE",R) ;
   D_RTABLE(T,R,"D_MZL") = DFEEDTR(T,"MAIZE",R) ;
*Construct regional supply summary table
   S_RTABLE(T,R,"S_TP")  = SLVTR(T,"TRADPIG",R) ;
   S_RTABLE(T,R,"S_CP")  = SLVTR(T,"COMMPIG",R) ;
   S_RTABLE(T,R,"S_MP")  = SLVTR(T,"MODPIG",R) ;
   S_RTABLE(T,R,"S_MZ")  = SCRTR(T,"MAIZE",R) ;
*Construct regional demand price summary table
   DP_RTABLE(T,R,"DP_TP")= PDTR(T,"TRADPIG",R) ;
   DP_RTABLE(T,R,"DP_CP")= PDTR(T,"COMMPIG",R) ;
   DP_RTABLE(T,R,"DP_MP")= PDTR(T,"MODPIG",R) ;
   DP_RTABLE(T,R,"DP_MZ")= PDTR(T,"MAIZE",R) ;
*Construct regional supply price summary table
   SP_RTABLE(T,R,"SP_TP")= PSTR(T,"TRADPIG",R) ;
   SP_RTABLE(T,R,"SP_CP")= PSTR(T,"COMMPIG",R) ;
   SP_RTABLE(T,R,"SP_MP")= PSTR(T,"MODPIG",R) ;
   SP_RTABLE(T,R,"SP_MZ")= PSTR(T,"MAIZE",R) ;
*Construct regional trade summary table
   XM_RTABLE(T,R,"NX_TP")= XTR(T,"TRADPIG",R)-MTR(T,"TRADPIG",R) +0.001 ;
   XM_RTABLE(T,R,"NX_CP")= XTR(T,"COMMPIG",R)-MTR(T,"COMMPIG",R) +0.001 ;
   XM_RTABLE(T,R,"NX_MP")= XTR(T,"MODPIG",R) -MTR(T,"MODPIG",R)  +0.001 ;
   XM_RTABLE(T,R,"NX_MZ")= XTR(T,"MAIZE",R)  -MTR(T,"MAIZE",R)   +0.001 ;
*NNQue: add small number (+0.001) to avoid missing column for print-out
*Construct regional TQ out summary table
   TQX_RTABLE(R,RR,T,"TQX_MZ")=TQTR(T,"MAIZE",R,RR)$TQTR(T,"MAIZE",R,RR)  ;
   TQX_RTABLE(R,RR,T,"TQX_TP")=TQTR(T,"TRADPIG",R,RR)$TQTR(T,"TRADPIG",R,RR) ;
   TQX_RTABLE(R,RR,T,"TQX_CP")=TQTR(T,"COMMPIG",R,RR)$TQTR(T,"COMMPIG",R,RR)  ;
   TQX_RTABLE(R,RR,T,"TQX_MP")=TQTR(T,"MODPIG",R,RR)$TQTR(T,"MODPIG",R,RR)  ;
*Construct regional TQ in summary table
   TQM_RTABLE(RR,R,T,"TQM_MZ")= TQTR(T,"MAIZE",RR,R)$TQTR(T,"MAIZE",RR,R) ;
   TQM_RTABLE(RR,R,T,"TQM_TP")= TQTR(T,"TRADPIG",RR,R)$TQTR(T,"TRADPIG",RR,R) ;
   TQM_RTABLE(RR,R,T,"TQM_CP")= TQTR(T,"COMMPIG",RR,R)$TQTR(T,"COMMPIG",RR,R) ;
   TQM_RTABLE(RR,R,T,"TQM_MP")= TQTR(T,"MODPIG",RR,R)$TQTR(T,"MODPIG",RR,R) ;
*Construct regional net TQ-out & net export in summary table
   NETOUTFL_RTABLE(T,R,"NTQX_TP") = SUM(RR,TQX_RTABLE(R,RR,T,"TQX_TP"))
                                  - SUM(RR,TQM_RTABLE(RR,R,T,"TQM_TP")) +0.001 ;
   NETOUTFL_RTABLE(T,R,"NTQX_CP") = SUM(RR,TQX_RTABLE(R,RR,T,"TQX_CP"))
                                  - SUM(RR,TQM_RTABLE(RR,R,T,"TQM_CP")) +0.001 ;
   NETOUTFL_RTABLE(T,R,"NTQX_MP") = SUM(RR,TQX_RTABLE(R,RR,T,"TQX_MP"))
                                  - SUM(RR,TQM_RTABLE(RR,R,T,"TQM_MP")) +0.001 ;
   NETOUTFL_RTABLE(T,R,"NTQX_MZ") = SUM(RR,TQX_RTABLE(R,RR,T,"TQX_MZ"))
                                  - SUM(RR,TQM_RTABLE(RR,R,T,"TQM_MZ")) +0.001 ;
   NETOUTFL_RTABLE(T,R,"NX_TP")   = SUM(U,XT("TRADPIG",R,U,T))
                                  - SUM(U,MT("TRADPIG",R,U,T))   +0.001 ;
   NETOUTFL_RTABLE(T,R,"NX_CP")   = SUM(U,XT("COMMPIG",R,U,T))
                                  - SUM(U,MT("COMMPIG",R,U,T))   +0.001 ;
   NETOUTFL_RTABLE(T,R,"NX_MP")   = SUM(U,XT("MODPIG",R,U,T) )
                                  - SUM(U,MT("MODPIG",R,U,T) )   +0.001 ;
   NETOUTFL_RTABLE(T,R,"NX_MZ")   = SUM(U,XT("MAIZE",R,U,T))
                                  - SUM(U,MT("MAIZE",R,U,T))     +0.001 ;

*SEND REGIONAL SUMMARY OUTPUT TABLES TO EXCEL FILE
*Use this to aggregate to national level
$LIBInclude XLDUMP S_RTABLE VPM2018Output_NNQue.xlsx %sim_name%!C5:H96
$LIBInclude XLDUMP D_RTABLE VPM2018Output_NNQue.xlsx %sim_name%!I5:O96
$LIBInclude XLDUMP NETOUTFL_RTABLE VPM2018Output_NNQue.xlsx %sim_name%!P5:Y96
$LIBInclude XLDUMP DP_RTABLE VPM2018Output_NNQue.xlsx %sim_name%!Z5:AE96

DISPLAY PDT,CPD,PST,CPS,XT,CX,MT,CM,DFOODT,CFOOD,DFEEDT,CFEED ;
DISPLAY SCRT, SLVT,CSCR, CSLV ;

*Tables with national value for each period
DISPLAY SCRTN,SLVTN,DFOODTN,DFEEDTN,XTN,MTN,PSTN,PDTN,POPTN,PWT,PMTN,PXTN ;
DISPLAY D_NTABLE,S_NTABLE,DP_NTABLE,SP_NTABLE,XM_NTABLE,POP_NTABLE ;
DISPLAY PX_NTABLE,PM_NTABLE ;
DISPLAY D_RTABLE, S_RTABLE, DP_RTABLE, SP_RTABLE, XM_RTABLE,TQTR,TQX_RTABLE ;
DISPLAY TQM_RTABLE,NETOUTFL_RTABLE ;
DISPLAY DYE, DGAMMA ;


* * * * * * * * * * * * * * *
*                           *
*       END PROGRAM         *
*                           *
* * * * * * * * * * * * * * *

