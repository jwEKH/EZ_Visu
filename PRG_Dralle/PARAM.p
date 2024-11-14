/*********************************************************************/
/*        Heizungssteuerungsmodul      Ersterstellung:     13.07.22  */
/* PARAM: Parameterbereich  'BIOGASANLAGE DRALLE  HOHNE              */
/* Stand: 13.07.22                                                   */
/* Anpassungen mit "<<<" gekennzeichnet                              */
/*********************************************************************/
P=MPC604+FPU(4);

/*SC=F000 ,CODE=$0000 ,VAR=$0000; /**/
  SC=F000;  /* */

/* Compileroptionen:            */
/*-L Listing PEARL-Compiler     */;
/*-B Big Module                 */;
/*+M Markierung Zeilennummer    */;
/*+T Test auf Feldgrenzen       */;
/*-P Protokoll Hyperproc Code   */;

MODULE PARAM;
SYSTEM;  /* PARAM kennt keine Hardware                               */
PROBLEM; /* Hier sind f}r Variablen nur DCLs zugelassen !            */
  SPC BATRAM DATION INOUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC TERM   DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* Terminal    */
  SPC BTASTIN   DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* SER 2       */
  SPC LCD    DATION   OUT ALPHIC CONTROL(ALL) GLOBAL; /* LC-Display  */
  SPC MIST2  DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* ED-Datei    */  
  SPC A1                            DATION   OUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC RTOS                          DATION   OUT ALPHIC CONTROL(ALL) GLOBAL;

  SPC RAMLES     TASK;
  SPC RAMSCHREIB TASK;
  SPC (WRITE,READ) ENTRY GLOBAL;
  SPC TASKST ENTRY (CHAR(24)) RETURNS (BIT(32)) GLOBAL;
  SPC SET_DATION ENTRY (DATION INOUT ALPHIC IDENT, CHAR(128)) GLOBAL;
  SPC NAHBED     TASK GLOBAL;
  SPC CMD_EXW  ENTRY (CHAR(255)) RETURNS (BIT( 1)) GLOBAL; /* Bedieni.*/
  SPC STOERMELD  ENTRY (FIXED, CHAR(20)) GLOBAL;
                       /* Prozedur f}r St”rungsmeldung        */
  SPC WATCHDOG TASK GLOBAL; /* Task zur Beruhigung des Watchdog      */
  SPC D_CS      ENTRY (FIXED, FIXED) GLOBAL; 
                      /* Cursor auf Position x,y             */
  SPC D_CLR     ENTRY GLOBAL; /* loescht LCD                         */

/*-------------------------------------------------------------------*/


#INCLUDE c:\p907\033bgadrallehohne\spc.p;


COPYR0HMON: TASK PRIO 90 GLOBAL;
  DCL B1      BIT(1);
  DCL TEXT    CHAR(80);
  DCL F15     FIXED;

  IF B_FLASHVORH THEN

    /* Koordinierung der Zugriffe auf Compact Flash               */
    /* mit Z_RAMSON anfordern und warten bis alle anderen fertig  */
    F15=0;
    WHILE (Z_RAMDUE2 > 0 OR Z_RAMSTOER > 0 OR Z_RAMSTAT > 0 OR Z_RAMPAR > 0) AND F15 < 3 REPEAT
      F15=F15+1;
      AFTER 0.5 SEC RESUME;
    END;
    Z_RAMSON=50;
    AFTER 0.5 SEC RESUME;
    WHILE Z_RAMDUE2 > 0 OR Z_RAMSTOER > 0 OR Z_RAMSTAT > 0 OR Z_RAMPAR > 0 REPEAT
      IF Z_RAMDUE2  > 0 THEN  Z_RAMDUE2 = Z_RAMDUE2-1;  FIN; 
      IF Z_RAMSTOER > 0 THEN  Z_RAMSTOER= Z_RAMSTOER-1;  FIN; 
      IF Z_RAMSTAT  > 0 THEN  Z_RAMSTAT = Z_RAMSTAT-1;   FIN; 
      IF Z_RAMPAR   > 0 THEN  Z_RAMPAR  = Z_RAMPAR -1;   FIN;
      AFTER 0.5 SEC RESUME;
    END;

    CASE DA_MON
      ALT /*  1 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT01';     
      ALT /*  2 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT02';     
      ALT /*  3 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT03';     
      ALT /*  4 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT04';     
      ALT /*  5 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT05';     
      ALT /*  6 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT06';     
      ALT /*  7 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT07';     
      ALT /*  8 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT08';     
      ALT /*  9 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT09';     
      ALT /* 10 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT10';     
      ALT /* 11 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT11';     
      ALT /* 12 */
        TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BAT12';     
      OUT
    FIN;
    B1=CMD_EXW(TEXT);                
    TEXT='SYNC H0.';     
    B1=CMD_EXW(TEXT);                
    Z_RAMSON=0; /* FERTIG */
  FIN;

END;

COPYR0H0: TASK PRIO 90 GLOBAL;
  DCL B1      BIT(1);
  DCL TEXT    CHAR(80);

  TEXT='ER NIL.;COPY PRIO 10 /RD/BATRAM1 > /H0/BATRAM1';     
  B1=CMD_EXW(TEXT);                
  TEXT='SYNC H0.';     
  B1=CMD_EXW(TEXT);                

END;

/*********************************************************************/
/* Batteriegepufferte Daten von der Compact Flash H0. lesen          */
/*********************************************************************/
COPYH0R0: TASK PRIO 90 GLOBAL;
  DCL B1      BIT(1);
  DCL INFO    CHAR(150);
  DCL TEXT    CHAR(80);
  DCL POS     FIXED;

  TEXT='ER NIL.;RM ED.MIST2';     
  B1=CMD_EXW(TEXT);                
  AFTER 0.5 SEC RESUME;
  PUT 'DIR H0.' TO A1 BY A,SKIP;
  AFTER 0.2 SEC RESUME;
  TEXT='O ED.MIST2;DIR h0.';     
  B1=CMD_EXW(TEXT);                
  AFTER 0.2 SEC RESUME;
  CALL REWIND(MIST2);
  CALL READ(MIST2,INFO);
  TEXT='ER NIL.;copy ed.MIST2 > A1.';     
  B1=CMD_EXW(TEXT);                
! PUT INFO TO A1 BY A,SKIP;
  AFTER 0.5 SEC RESUME;
  POS=INSTR(INFO,1,150,'*FREE*',1,6);  
  IF POS > 0 THEN
    B_FLASHVORH='1'B;
    PUT 'SD-Karte vorhanden',POS TO A1 BY A,F(5),SKIP;
  ELSE
    PUT 'SD-Karte nicht vorhanden',POS TO A1 BY A,F(5),SKIP;
  FIN;
  AFTER 0.2 SEC RESUME;

  PUT 'kopiere H0.BATRAM1 > RD.BATRAM1' TO A1 BY A;
  TEXT='ER NIL.;COPY /H0/BATRAM1 > /RD/BATRAM1';     
  B1=CMD_EXW(TEXT);                
  IF B1 THEN
    PUT '  FEHLER' TO A1 BY A,SKIP;
  ELSE
    PUT '  erfolgreich' TO A1 BY A,SKIP;
  FIN;    

END;
  
RAMLES: TASK PRIO 9 GLOBAL;
  /* Absicherung gegen gleichzeitiges Lesen und Schreiben            */

  DCL FIX1    FIXED;
  DCL DRAN    FIXED;
  DCL NOCHMAL BIT(1);
  DCL STAT    BIT(32);
  DCL TEXT    CHAR(80);
  DCL B1      BIT(1);
  DCL REFCHAR         REF CHAR(1);
  DCL CH      CHAR(1);
  
 
  STAT=TASKST('RAMSCHREIB');
  WHILE STAT.BIT(1)=='0'B REPEAT
    AFTER 0.2 SEC RESUME;
    STAT=TASKST('RAMSCHREIB');
  END;

  B_FLASHVORH='0'B;
  ACTIVATE COPYH0R0;
  FIX1=0;
  STAT=TASKST('COPYH0R0');
  WHILE STAT.BIT(1)=='0'B AND FIX1 < 50 REPEAT
    FIX1=FIX1+1;
    AFTER 0.2 SEC RESUME;
    STAT=TASKST('COPYH0R0');
  END;
  IF FIX1 > 49 THEN
    TERMINATE COPYH0R0;  
    B_FLASHVORH='0'B;
    PUT 'Kopiervorgang blockiert' TO A1 BY A,SKIP;
  FIN;               
  
  
  DRAN=1;
  BI_PARA='00000000'B4;

  WHILE DRAN<2 REPEAT

    NOCHMAL='0'B;
    PUT TO BATRAM BY LIST;

    CASE DRAN
      ALT
        CALL D_CLR;
        CALL D_CS(1,1);
        PUT 'lese BATRAM1 ' TO LCD BY A;
        OPEN BATRAM BY IDF('BATRAM1');
      ALT
        CALL D_CS(1,4);
        PUT 'lese BATRAM2 ' TO LCD BY A;
        OPEN BATRAM BY IDF('BATRAM2');
      OUT 
    FIN;
    IF ST(BATRAM)>1 THEN
      NOCHMAL='1'B;
    FIN;
    
    CALL SEEK(BATRAM,0(31));
    IF ST(BATRAM)>1 THEN
      NOCHMAL='1'B;
    FIN;

    CALL READ(BATRAM,BI_PARA);
    IF BI_PARA == 'ABCD5678'B4 THEN
      PUT 'Neuinitialisierung gewuenscht' TO LCD BY SKIP,A,SKIP;
      PUT 'Neuinitialisierung gewuenscht' TO A1  BY SKIP,A,SKIP;
      TERMINATE;
    FIN;

    PUT TO BATRAM BY LIST;
    CALL REWIND(BATRAM);

    CALL READ(BATRAM,BI_PARA,
                     Z_BETRIEB,                                                            
                     B_ROTSP,
                     B_WINTER,
                     ZF_TMESS,
                     TD_BO,
                     TD_BU,
                     TD_KS,
                     TC_MAXMIN,
                     PE_RMIN1B,
                     ZF_TAUS,
                     ZF_T1EIN,
                     TD_1EIN,
                     Z_KALSEC,
                     Z_RESET,
                     ZP_SCHANF,
                     ZP_SCHEND,
                     ZP_PUMPSCH,
                     PT_SCHNITT,
                     Z_ZAEHL,
                     FL_IMP,
                     Z_STRMAX,
                     DA_STRMAX,
                     PE_STRMAX,
                     FL_GASSTOER,
                     FL_GASWARN,
                     FL_DRWARN,
                     FL_DRMAX,
                     Z_SYSOUT,
                     FL_GASHU,
                     FL_GASHO,
                     TD_UEBERHEIZ,
                     W_ERZHT,
                     W_ERZNT,
                     W_BEDHT,
                     W_BEDNT,
                     W_EINHT,
                     W_EINNT,
                     W_BEZHT,
                     W_BEZNT,
                     W_55,
                     TX_STOER,
                     ZT_STOER,
                     ART_STOER,
                     FP_ULOW,
                     FP_UHIGH,
                     FP_NULL,
                     FP_STEIG,
                     B_FUEHLWACH,
                     FL_XAEINMAX,
                     FL_XAEINMIN,
                     TD_ABSHK,
                     RP_M,
                     RI_M,
                     RD_M,
                     RDI_M,
                     RTAU_M,
                     ZUST_HK,
                     P_HKMIN,
                     TC_HMT,
                     TC_HMN,
                     FL_EXPHK,
                     TD_HKSPREI,
                     TC_HKINENN,
                     TC_HKVMIN,
                     TC_HKVNENN,
                     TC_HKANENN,
                     W_HKTH,
                     TC_HKSTW,
                     ZF_HKMISTELL,
                     HK_NAME,
                     FL_SOLLATM10,
                     FL_SOLLAT5,
                     FL_SOLLAT20,
                     TC_TAGSOLL,
                     TC_BEREITSOLL,
                     TC_NACHTSOLL,
                     TD_HKINTMAX,
                     TD_HKINTMIN,
                     F_ESTRICH,
                     FL_ATTAU,
                     TC_ATTAU,
                     ZF_HKPEXT,
                     ZF_HKMIEXT,
                     FL_HKEXT,
                     FS_LBHKW,
                     Z_START,
                     XA_BPMP,
                     PE_MAXBHKW,
                     PE_MINBHKW,
                     PE_BMINPRO,
                     TC_BVLMIN, 
                     TC_BHZGVO,
                     TC_BHZGRO,
                     B_BERLAUBT,
                     ZF_BPNL, 
                     Z_BLAUFZ,
                     ZP_BAUS,
                     DAT_BAUS,
                     FL_BLFZGESHZG,
                     FL_BKWHGESHZG,
                     TC_BRMIN,
                     TD_BHZGSOLL,
                     STR_AUS,
                     FL_BLFZWART,
                     FL_BLFZWARTINT,
                     B_FSLBHKWAUTO,
                     ZF_STARTMAX,
                     ZF_BEINEXT,
                     FS_LKES,
                     RP_K,   
                     RI_K,   
                     RD_K,   
                     RDI_K,  
                     RTAU_K, 
                     RP_KP,   
                     RI_KP,  
                     RD_KP,   
                     RDI_KP,  
                     RTAU_KP,
                     FL_KWART,
                     TD_KMIN, 
                     PT_KES,  
                     Z_KLAUFZ,
                     ZP_KAUS,
                     DAT_KAUS,
                     ZF_KPNL, 
                     ZF_KWARML,
                     ZF_KSTELL,
                     TC_KRMIN,
                     TC_KVMAX,
                     TD_KVLPLUS,
                     TD_KMAX,  
                     X_AAKMIN,
                     Z_KESLFZ,
                     Z_KSTART,
                     B_KERLAUBT,
                     B_FSLKESAUTO,
                     B_PMPVORL,
                     ZF_KEINEXT,
                     ZF_KPMPEXT,
                     TC_BWSOLL,
                     TC_BWZRSOLL,
                     TC_BOMAX,
                     TD_BWNORM,
                     TD_BWDRIG,
                     TD_BWB,
                     TD_BWTW,
                     TD_BWTOO,
                     TD_BWTOU,
                     TD_BWLS,
                     TC_BWMIN,
                     TC_LEGIO,
                     RP_BWL,
                     RI_BWL,
                     RD_BWL,
                     TC_BWRSOLL,
                     RP_WWZ,
                     RI_WWZ,
                     RD_WWZ,
                     RDI_WWZ,
                     RTAU_WWZ,
                     RP_WWL,
                     RI_WWL,
                     RD_WWL,
                     RDI_WWL,
                     RTAU_WWL,
                     ZF_LMISTELL,
                     ZF_WWMI,  
                     BI_ON,
                     BI_OFF,
                     Z_DOHAND,
                     Z_DIBEWERT,
                     AP_ULOW,
                     AP_UHIGH,
                     X_AHAND,
                     Z_AAUTO,
                     X_AAUSMIN,
                     X_AAUSMAX,
                     X_PWMHAND,
                     Z_PWMAUTO,
                     X_PWMMIN, 
                     X_PWMMAX, 
                     B_ZONE1,
                     B_JAHRAB,
                     IDBATRAM,
                     B_UPEHAND,
                     Z_UPEKOMMAND,
                     Z_UPESOLLHAND,
                     UPE_PRESSSCALE,
                     UPE_FLOWSCALE,
                     UPE_TEMPSCALE,
                     UPE_FRQSCALE,
                     UPE_PDCSCALE,
                     UPE_FREIG,
                     UPE_KENN,
                     UPE_EXT,
                     ZF_STOERDRIG,
                     ZF_STOERFREI,
                     B_STSAMMFREI,
                     MARKOW,
                     IDSTRING2,
                     FL_ZEITZAEHL,
                     NAMESTR,
                     DA_DATCALL,
                     DA_MONCALL,
                     ZP_CALL,
                     ZF_WTAUP,
                     ANZ_SLAVE,  
                     VERZ_SLAVE,
                     FL_HZGFUEEIN,
                     FL_HZGFUEAUS,
                     ZF_HZGFUELL,
                     MON_ZAEHL,
                     AT_MON,
                     MON_ZAEHLJAN,
                     JAHR_ZAEHL,
                     WIRT_ZAEHL,
                     FL_GASCENTPROKWH,
                     Z_WAERMEBHKW,
                     POSWTH,
                     POSPTH,
                     POSWQM,
                     POSDF,
                     POSTCV,
                     POSTCR,
                     POSFIX,
                     ZF_MBUSLES,
                     ZF_TASTVERZ,
                     ZF_STOERMAX24,
                     DUMMYP);



    PUT 'ST(Batram)= ',ST(BATRAM) TO A1 BY A,F(5),SKIP;  /* MMMM */
    PUT 'BI_PARA= ',BI_PARA TO A1 BY A,B4,SKIP;  /* MMMM */
    IF ST(BATRAM) > 0 AND ST(BATRAM) /= 50 THEN
      NOCHMAL='1'B;
    FIN;

    IF IDSTRING /= IDBATRAM THEN
      BI_PARA='00000000'B4;
    FIN;
    
    IF BI_PARA /= 'ECAD1101'B4 THEN
!     IF BI_PARA == 'ABCD5678'B4 THEN  /* Neuinitialisierung gewnscht */
      IF BI_PARA == 'ABCD5678'B4 OR (IDSTRING /= IDBATRAM AND (ST(BATRAM) == 0 OR ST(BATRAM) == 50)) THEN  
        IF BI_PARA == 'ABCD5678'B4 THEN
          PUT 'Neuinitialisierung gewnscht' TO LCD BY SKIP,A,SKIP;
          PUT 'Neuinitialisierung gewnscht' TO A1  BY SKIP,A,SKIP;
        ELSE
          PUT 'Daten passen nicht zu Projekt' TO LCD BY SKIP,A,SKIP;
          PUT 'Daten passen nicht zu Projekt' TO A1  BY SKIP,A,SKIP;
        FIN;
        PUT TO LCD BY SKIP;
        AFTER 2 SEC RESUME;
        BI_PARA='ABCD5678'B4; /* Magic Word auf Neuinit setzen       */
        ACTIVATE RAMSCHREIB;
        AFTER 0.8 SEC RESUME;
        ACTIVATE RAMSCHREIB; 
        AFTER 0.8 SEC RESUME;

!       PUT 'l”sche /H0/BATRAM1 ' TO LCD BY A,SKIP;
!       TEXT='RM /H0/BATRAM1';     
!       B1=CMD_EXW(TEXT);                
!       PUT 'l”sche /H0/BATRAM2 ' TO LCD BY A,SKIP;
!       TEXT='RM /H0/BATRAM2';     
!       B1=CMD_EXW(TEXT);
!       CALL SYNC(BATRAM);
        AFTER 2 SEC RESUME;
        TEXT='TERMINATE Watch -- PREVENT WATCHDOG';             /* Flasheprom l”schen */
        B1=CMD_EXW(TEXT);
        AFTER 10 SEC RESUME;
        NOCHMAL='0'B;
      ELSE
        NOCHMAL='1'B;
      FIN;
    FIN;

    IF NOCHMAL THEN
      PUT '  FEHLER ' TO LCD BY A,SKIP;
      DRAN=DRAN+1;
      IF DRAN==3 THEN
        BI_PARA='00000000'B4;
      FIN;
    ELSE
      PUT ' OK' TO LCD BY A,SKIP;
      IF DRAN > 1 THEN
        CALL STOERMELD(80,'BATRAM1 defekt');
        B_STOER(80)='1'B;
      ELSE

      FIN;    
      DRAN=5;
    FIN;

  END;
END; /* !!! */
  
/*********************************************************************/
/* Task zum schreiben der batteriegepufferten Daten auf R8.          */
/*********************************************************************/

RAMSCHREIB: TASK PRIO 15 GLOBAL;

  DCL F15  FIXED; 
  DCL FIX1 FIXED; 
  DCL TEXT CHAR(80);
  DCL B1   BIT(1);
  DCL STAT    BIT(32);
  
  IDBATRAM=IDSTRING;  /* Steuerungsnamen auf Ramdisk sichern         */

  IF NOT B_RAMSPERR THEN


    STAT=TASKST('COPYR0H0');
    IF STAT.BIT(1)=='1'B THEN  /* COPYR0H0 schlaeft  */
 
      /* Koordinierung der Zugriffe auf Compact Flash               */
      /* mit Z_RAMPAR anfordern und warten bis alle anderen fertig  */
      F15=0;
      WHILE (Z_RAMDUE2 > 0 OR Z_RAMSTOER > 0 OR Z_RAMSTAT > 0 OR Z_RAMSON > 0) AND F15 < 3 REPEAT
        F15=F15+1;
        AFTER 0.5 SEC RESUME;
      END;
      Z_RAMPAR=50;
      AFTER 0.5 SEC RESUME;
      WHILE Z_RAMDUE2 > 0 OR Z_RAMSTOER > 0 OR Z_RAMSTAT > 0 OR Z_RAMSON > 0 REPEAT
        IF Z_RAMDUE2  > 0 THEN  Z_RAMDUE2 = Z_RAMDUE2-1;  FIN; 
        IF Z_RAMSTOER > 0 THEN  Z_RAMSTOER= Z_RAMSTOER-1;  FIN; 
        IF Z_RAMSTAT  > 0 THEN  Z_RAMSTAT = Z_RAMSTAT-1;   FIN; 
        IF Z_RAMSON   > 0 THEN  Z_RAMSON  = Z_RAMSON -1;   FIN;
        AFTER 0.5 SEC RESUME;
      END;
  
      PUT TO BATRAM BY LIST;
  
      OPEN BATRAM BY IDF('BATRAM1');
  
      CALL REWIND(BATRAM);
      CALL WRITE(BATRAM,'01010101'B4,
                     Z_BETRIEB,                                                            
                     B_ROTSP,
                     B_WINTER,
                     ZF_TMESS,
                     TD_BO,
                     TD_BU,
                     TD_KS,
                     TC_MAXMIN,
                     PE_RMIN1B,
                     ZF_TAUS,
                     ZF_T1EIN,
                     TD_1EIN,
                     Z_KALSEC,
                     Z_RESET,
                     ZP_SCHANF,
                     ZP_SCHEND,
                     ZP_PUMPSCH,
                     PT_SCHNITT,
                     Z_ZAEHL,
                     FL_IMP,
                     Z_STRMAX,
                     DA_STRMAX,
                     PE_STRMAX,
                     FL_GASSTOER,
                     FL_GASWARN,
                     FL_DRWARN,
                     FL_DRMAX,
                     Z_SYSOUT,
                     FL_GASHU,
                     FL_GASHO,
                     TD_UEBERHEIZ,
                     W_ERZHT,
                     W_ERZNT,
                     W_BEDHT,
                     W_BEDNT,
                     W_EINHT,
                     W_EINNT,
                     W_BEZHT,
                     W_BEZNT,
                     W_55,
                     TX_STOER,
                     ZT_STOER,
                     ART_STOER,
                     FP_ULOW,
                     FP_UHIGH,
                     FP_NULL,
                     FP_STEIG,
                     B_FUEHLWACH,
                     FL_XAEINMAX,
                     FL_XAEINMIN,
                     TD_ABSHK,
                     RP_M,
                     RI_M,
                     RD_M,
                     RDI_M,
                     RTAU_M,
                     ZUST_HK,
                     P_HKMIN,
                     TC_HMT,
                     TC_HMN,
                     FL_EXPHK,
                     TD_HKSPREI,
                     TC_HKINENN,
                     TC_HKVMIN,
                     TC_HKVNENN,
                     TC_HKANENN,
                     W_HKTH,
                     TC_HKSTW,
                     ZF_HKMISTELL,
                     HK_NAME,
                     FL_SOLLATM10,
                     FL_SOLLAT5,
                     FL_SOLLAT20,
                     TC_TAGSOLL,
                     TC_BEREITSOLL,
                     TC_NACHTSOLL,
                     TD_HKINTMAX,
                     TD_HKINTMIN,
                     F_ESTRICH,
                     FL_ATTAU,
                     TC_ATTAU,
                     ZF_HKPEXT,
                     ZF_HKMIEXT,
                     FL_HKEXT,
                     FS_LBHKW,
                     Z_START,
                     XA_BPMP,
                     PE_MAXBHKW,
                     PE_MINBHKW,
                     PE_BMINPRO,
                     TC_BVLMIN, 
                     TC_BHZGVO,
                     TC_BHZGRO,
                     B_BERLAUBT,
                     ZF_BPNL, 
                     Z_BLAUFZ,
                     ZP_BAUS,
                     DAT_BAUS,
                     FL_BLFZGESHZG,
                     FL_BKWHGESHZG,
                     TC_BRMIN,
                     TD_BHZGSOLL,
                     STR_AUS,
                     FL_BLFZWART,
                     FL_BLFZWARTINT,
                     B_FSLBHKWAUTO,
                     ZF_STARTMAX,
                     ZF_BEINEXT,
                     FS_LKES,
                     RP_K,   
                     RI_K,   
                     RD_K,   
                     RDI_K,  
                     RTAU_K, 
                     RP_KP,   
                     RI_KP,  
                     RD_KP,   
                     RDI_KP,  
                     RTAU_KP,
                     FL_KWART,
                     TD_KMIN, 
                     PT_KES,  
                     Z_KLAUFZ,
                     ZP_KAUS,
                     DAT_KAUS,
                     ZF_KPNL, 
                     ZF_KWARML,
                     ZF_KSTELL,
                     TC_KRMIN,
                     TC_KVMAX,
                     TD_KVLPLUS,
                     TD_KMAX,  
                     X_AAKMIN,
                     Z_KESLFZ,
                     Z_KSTART,
                     B_KERLAUBT,
                     B_FSLKESAUTO,
                     B_PMPVORL,
                     ZF_KEINEXT,
                     ZF_KPMPEXT,
                     TC_BWSOLL,
                     TC_BWZRSOLL,
                     TC_BOMAX,
                     TD_BWNORM,
                     TD_BWDRIG,
                     TD_BWB,
                     TD_BWTW,
                     TD_BWTOO,
                     TD_BWTOU,
                     TD_BWLS,
                     TC_BWMIN,
                     TC_LEGIO,
                     RP_BWL,
                     RI_BWL,
                     RD_BWL,
                     TC_BWRSOLL,
                     RP_WWZ,
                     RI_WWZ,
                     RD_WWZ,
                     RDI_WWZ,
                     RTAU_WWZ,
                     RP_WWL,
                     RI_WWL,
                     RD_WWL,
                     RDI_WWL,
                     RTAU_WWL,
                     ZF_LMISTELL,
                     ZF_WWMI,  
                     BI_ON,
                     BI_OFF,
                     Z_DOHAND,
                     Z_DIBEWERT,
                     AP_ULOW,
                     AP_UHIGH,
                     X_AHAND,
                     Z_AAUTO,
                     X_AAUSMIN,
                     X_AAUSMAX,
                     X_PWMHAND,
                     Z_PWMAUTO,
                     X_PWMMIN, 
                     X_PWMMAX, 
                     B_ZONE1,
                     B_JAHRAB,
                     IDBATRAM,
                     B_UPEHAND,
                     Z_UPEKOMMAND,
                     Z_UPESOLLHAND,
                     UPE_PRESSSCALE,
                     UPE_FLOWSCALE,
                     UPE_TEMPSCALE,
                     UPE_FRQSCALE,
                     UPE_PDCSCALE,
                     UPE_FREIG,
                     UPE_KENN,
                     UPE_EXT,
                     ZF_STOERDRIG,
                     ZF_STOERFREI,
                     B_STSAMMFREI,
                     MARKOW,
                     IDSTRING2,
                     FL_ZEITZAEHL,
                     NAMESTR,
                     DA_DATCALL,
                     DA_MONCALL,
                     ZP_CALL,
                     ZF_WTAUP,
                     ANZ_SLAVE,  
                     VERZ_SLAVE,
                     FL_HZGFUEEIN,
                     FL_HZGFUEAUS,
                     ZF_HZGFUELL,
                     MON_ZAEHL,
                     AT_MON,
                     MON_ZAEHLJAN,
                     JAHR_ZAEHL,
                     WIRT_ZAEHL,
                     FL_GASCENTPROKWH,
                     Z_WAERMEBHKW,
                     POSWTH,
                     POSPTH,
                     POSWQM,
                     POSDF,
                     POSTCV,
                     POSTCR,
                     POSFIX,
                     ZF_MBUSLES,
                     ZF_TASTVERZ,
                     ZF_STOERMAX24,
                     DUMMYP);

  
      CALL SEEK(BATRAM,0(31));
      CALL WRITE(BATRAM,BI_PARA);
      CALL SYNC(BATRAM);
      CLOSE BATRAM;
  
      IF B_FLASHVORH THEN
        /* Kopieren r0.BATRAM1 > h0.BATRAM1  */
        ACTIVATE COPYR0H0;
      FIN;

    FIN;
   
    FIX1=0;
    STAT=TASKST('COPYR0H0');
    /* While noch arbeitet */
    WHILE STAT.BIT(1)=='0'B AND FIX1 < 21 REPEAT
      FIX1=FIX1+1;
      AFTER 0.5 SEC RESUME;
      STAT=TASKST('COPYR0H0');
    END;
    IF FIX1 > 20 THEN
      PUT 'TERMINATE COPYR0H0' TO RTOS;
      CALL STOERMELD(80,'Datensicher.');
      B_STOER(80)='1'B;
  !   PUT 'Datensicherung H0. fehlgeschlagen' TO A1 BY A,SKIP;
    FIN;               

    Z_RAMPAR=0; /* FERTIG */

    /* einmal am Tag eine Kopie von BATRAM1 anlegen (Monatsnamen BAT01,BAT02,...) */
    IF ZP_NOW > 00:30:00 AND ZP_NOW < 00:55:00 AND NOT B_FLASHMERK AND B_FLASHVORH THEN
      B_FLASHMERK='1'B;
      ACTIVATE COPYR0HMON;           
    FIN;
    IF ZP_NOW > 01:00:00 THEN
      B_FLASHMERK='0'B;
    FIN;                    

      
  FIN;

  PUT 'sync h0.' TO RTOS BY A;       /* NNNNN */
  AFTER 15 MIN ACTIVATE RAMSCHREIB;

END;  

/*********************************************************************/
/* šbertragung der batteriegepufferten Parameter von BATRAM1 auf die */
/* serielle Schnittstelle                                            */
/*********************************************************************/
DUE1: TASK PRIO 31 GLOBAL;

  DCL LAENGE  FIXED(31);
  DCL POS     FIXED(31);
  DCL FIXED   FIXED;
  DCL Z       FIXED;
  DCL CH1     CHAR(1);
  DCL NEWDAT  CHAR(128); 

  IF B_FERN THEN
  ELSE
    NEWDAT='/TY';
    OPEN TERM BY IDF(NEWDAT);

    NEWDAT='/TYB';
    OPEN BTASTIN BY IDF(NEWDAT);
  FIN;

  IF Z_LZ > 2(31) THEN
    PUT 'Diese Funktion nur im RESET !! ' TO TERM BY SKIP;
    PUT '   ABBRUCH !! ' TO TERM BY SKIP;
    AFTER 1 SEC RESUME;
    PUT 'ACTIVATE NAHBED' TO RTOS;
    TERMINATE;
    AFTER 1 SEC RESUME;
  FIN;

  PUT 'Uebertragung der Batteriegepufferten Parameter',
      '........bitte ASCII-Download starten!.........',
      '..........und mit ENTER bestaetigen...........'
    TO TERM BY A,SKIP,A,SKIP,A,SKIP;
  GET CH1 FROM BTASTIN BY SKIP,A;
 
  AFTER 90 MIN ACTIVATE NAHBED;
  AFTER 0.5 SEC RESUME;
  OPEN BATRAM BY IDF('BATRAM1');
  CALL APPEND(BATRAM);
  CALL SAVEP(BATRAM,LAENGE);
  CALL SEEK (BATRAM,0(31));          /* Anfang aufsuchen             */
  POS=0(31);
  Z=0;
  PUT -31111 TO TERM BY F(6),SKIP; /* Beginn der Uebertragung         */
  WHILE ST(BATRAM)==0 REPEAT
    CALL READ(BATRAM,FIXED);
    CALL SAVEP(BATRAM,POS);
    PUT FIXED TO TERM BY F(6),SKIP;
    Z=Z+1;
  END;
/*PUT Z TO TERM BY F(6),SKIP;  */
  PUT 'FERTIG' TO TERM BY A,SKIP; /* Abschluss der Uebertragung       */
  AFTER 0.2 SEC RESUME;

END;

/*******************************************************************/
/* Erneuerung der batteriegepufferten Daten auf BATRAM1            */
/*******************************************************************/
RAMNEU: TASK PRIO 30;

  DCL FIX1 FIXED;
  DCL CH1  CHAR(1); 
  DCL TEXT CHAR(80);
  DCL B1   BIT(1);
  DCL NEWDAT  CHAR(128); 

  IF B_FERN THEN
  ELSE
    NEWDAT='/TY';
    OPEN TERM BY IDF(NEWDAT);

    NEWDAT='/TYB';
    OPEN BTASTIN BY IDF(NEWDAT);
  FIN;
        
  IF Z_LZ > 2(31) THEN
    PUT 'Diese Funktion nur im RESET !! ' TO TERM BY SKIP;
    PUT '   ABBRUCH !! ' TO TERM BY SKIP;
    PUT 'ACTIVATE NAHBED' TO RTOS;
    AFTER 1 SEC RESUME;
    TERMINATE;
  FIN;

  PUT TOCHAR(26) TO TERM;                  /* TERMINAL L™SCHEN    */
  PUT TOCHAR(30) TO TERM;                  /* TERMINAL POS 1,1    */
  PUT TOCHAR(27),'=',TOCHAR(31+2),TOCHAR(31+1) TO TERM; /* POS X,Y*/
  PUT '    Erneuerung der Batteriegepufferten Variablen bei:'
    TO TERM BY A,SKIP;
  PUT '     ',IDSTRING TO TERM BY A,A,SKIP,SKIP;
  PUT '    Daten werden ueber diese Schnittstelle entgegengenommen.' TO TERM BY A,SKIP;
  PUT '    Nach dem Ueberspielen erfolgt ein Reset.' TO TERM BY A,SKIP,SKIP;
  PUT '    Sind Sie sicher dass die Variablen erneuert werden sollen ?' TO TERM BY A,SKIP;
  PUT '      (j / n): ' TO TERM BY A;
  GET CH1 FROM BTASTIN BY SKIP,A;
  PUT TO TERM BY SKIP,SKIP;
  IF CH1=='J' OR CH1=='j' THEN
    TEXT='UNLOAD -A RAMSCHREIB';     
    B1=CMD_EXW(TEXT);                
      
    PUT '         Bitte die Datei vom PC uebertragen' TO TERM BY A,SKIP;
    PUT '         (nach Uebertragung evtl. mit "Strg-d" beenden)' TO TERM BY A,SKIP,SKIP;
    OPEN BATRAM BY IDF('BATRAM1');
    CALL REWIND(BATRAM);
    FIX1=0;
    WHILE FIX1/=-31111 AND ST(BTASTIN)==0 REPEAT
      GET FIX1 FROM BTASTIN BY F(6),SKIP;
    END;  
    WHILE ST(BTASTIN)==0 REPEAT
      GET FIX1 FROM BTASTIN BY F(6),SKIP;
      CALL WRITE(BATRAM,FIX1);
    END;  
    CALL SYNC(BATRAM);
    CLOSE BATRAM;
    PUT 'fertig, es folgt ein RESET' TO TERM BY A,SKIP;
    AFTER 1 SEC RESUME;
    PUT 'TERMINATE Watch -- PREVENT WATCHDOG' TO RTOS;
  ELSE /* ENDE */
    PUT 'abgebrochen' TO TERM BY A,SKIP;
  FIN;
    
END;

/*+L*/
MODEND;




