/*********************************************************************/
/*        Heizungssteuerungsmodul      Ersterstellung:     13.07.22  */
/* SONDER: Sonderfunktionen  'BIOGASANLAGE DRALLE  HOHNE             */
/* Stand: 13.07.22                                                   */
/* Anpassungen mit "<<<" gekennzeichnet                              */
/*********************************************************************/

P=MPC604+FPU(4);

/*SC=20000 ,CODE=$0000 ,VAR=$0000; /**/
  SC=20000;  /* */

/* Compileroptionen:            */
/*-L Listing PEARL-Compiler     */;
/*-B Big Module                 */;
/*+M Markierung Zeilennummer    */;
/*+T Test auf Feldgrenzen       */;
/*-P Protokoll Hyperproc Code   */;

MODULE SONDER;

SYSTEM;

PROBLEM;
  SPC TERM   DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* Terminal    */
  SPC RTOS   DATION   OUT ALPHIC CONTROL(ALL) GLOBAL; /* XC.         */
  SPC LCD    DATION   OUT ALPHIC CONTROL(ALL) GLOBAL; /* LC-Display  */
  SPC ADRESSE DATION INOUT ALPHIC CONTROL(ALL) GLOBAL;/* RAM-Disk    */
  SPC DATEN  DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* RAM-Disk    */
  SPC BATRAM DATION INOUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC BTASTIN DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* ser. Schn.  */
  SPC FAXFILE DATION INOUT ALPHIC CONTROL(ALL) GLOBAL;/* Faxdatei    */
  SPC A1          DATION   OUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC VIERTOUT    DATION   OUT ALPHIC CONTROL(ALL) GLOBAL; 
  SPC VIERTIN     DATION IN    ALPHIC CONTROL(ALL) GLOBAL;
  SPC TASTVIERT   DATION INOUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC MONPROT     DATION INOUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC MIN1WERT    DATION INOUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC SERV        DATION   OUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC STOER_RIM   DATION   OUT ALPHIC GLOBAL;
  SPC RIM         DATION IN    ALPHIC GLOBAL;
  SPC A12         DATION   OUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC TEMP   DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* temporaere Datei auf Ramdisk  */

/* Tasks */
  SPC I_DISP   TASK GLOBAL;  /* Initialisiert Anzeige                */
  SPC DISPLAY  TASK GLOBAL;  /* stellt Anzeigeseiten dar             */
  SPC MENU     TASK GLOBAL;  /* betreut Tastatur und Menu            */
  SPC DIN      TASK GLOBAL;  /* betreut Tastatur und Menu            */
  SPC RAMLES     TASK GLOBAL;/* RAM-Disk R1. lesen                   */
  SPC RAMSCHREIB TASK GLOBAL;/* RAM-Disk R1. beschreiben             */
  SPC NAHBED     TASK GLOBAL;/* Umschalten auf Nahbedienung          */
  SPC ANRUF      TASK GLOBAL;/* ANRUFTASK                            */
  SPC STATISTIK TASK;

/* externe Prozeduren */
  SPC D_CS      ENTRY (FIXED, FIXED) GLOBAL; 
                      /* Cursor auf Position x,y             */
  SPC D_CLR     ENTRY GLOBAL; /* loescht LCD                         */
  SPC D_GRAPHCLR ENTRY GLOBAL; /* loescht Graphic                    */
  SPC ANZ_AUS    ENTRY GLOBAL; /* schaltet Anzeigefunktionen aus     */
  SPC STICK     ENTRY GLOBAL; /* wartet auf Eingabe                  */
  SPC TASKST   ENTRY (CHAR(24)) RETURNS (BIT(32)) GLOBAL; /* Status? */
  SPC SET_DATION ENTRY (DATION INOUT ALPHIC IDENT, CHAR(128)) GLOBAL;
  SPC (WRITE,READ) ENTRY GLOBAL;
  SPC INP_FLO     ENTRY (FIXED, FIXED, FIXED, FIXED, FLOAT, FLOAT, FLOAT, FLOAT IDENT, CHAR(12)) GLOBAL;
                        /* FLOAT-Wert eingeben: (X,Y,ST,NK,wert)    */
  SPC ROUNDLG     ENTRY (FLOAT(55)) RETURNS(FIXED(31)) GLOBAL;
                        /* runden von Gleitkommazahlen > 32768 */
  SPC TAGESNR  ENTRY (FIXED, FIXED, FIXED) RETURNS(FIXED) GLOBAL;/* Tagesnummer berechnen  */
  SPC FIXGRENZ     ENTRY (FIXED, FIXED, FIXED IDENT) GLOBAL; /* Fixwert begrenzen                */
  SPC FLOGRENZ     ENTRY (FLOAT, FLOAT, FLOAT IDENT) GLOBAL; /* Floatwert begrenzen              */
  SPC LRROT       ENTRY (FIXED IDENT) GLOBAL;    /* Hebelbewegung f}r INP_ Routinen auswerten*/
  SPC DATETIME     ENTRY (FIXED(31), FIXED IDENT, FIXED IDENT, FIXED IDENT, FIXED IDENT, FIXED IDENT) GLOBAL;

  SPC STOERMELD  ENTRY (FIXED, CHAR(20));
  SPC IDF_DATION  ENTRY(DATION ALPHIC IDENT, CHAR(128) IDENT, BIT(16) IDENT, FIXED(15) IDENT, FIXED(15) IDENT, FIXED(15) IDENT) GLOBAL;
                       /* dation             name             AI             TFU              LDN              DRIVE */

  DCL B_WART          BIT(1);
  DCL B_DATAKT        BIT(1);
  DCL NEWDAT          CHAR(128); /* Hilfsvariable  */
  DCL CHSTOER(3000)   CHAR(1);
  DCL Z_SCHREIBSTOER  FIXED;
  DCL Z_SCHREIBWART   FIXED;
  DCL FL_HILF(200,15) FLOAT;
  DCL FLSONST(15)     FLOAT;

/*-------------------------------------------------------------------*/
#INCLUDE c:\p907\033bgadrallehohne\spc.p;

MONDAT: PROC ( NR FIXED, (DAT,MON,JAHR) FIXED IDENT) GLOBAL;
  DCL X2 FIXED;

  X2=NR+273;
  JAHR=1973;
  DAT=1;
  MON=1;

  WHILE X2 > 366 OR (X2 > 365 AND (JAHR REM 4)/=0) REPEAT
    JAHR=JAHR+1;
    IF (JAHR REM 4)==1 THEN
      X2=X2-366;
    ELSE
      X2=X2-365;
    FIN;
  END;

  FOR I TO 12 REPEAT
    IF X2>28 AND MON==2 AND (JAHR REM 4)/=0 THEN
      MON=MON+1;
      X2=X2-28;
    FIN;
    IF X2>29 AND MON==2 AND (JAHR REM 4)==0 THEN
      MON=MON+1;
      X2=X2-29;
    FIN;
    IF X2>30 AND (MON==4 OR MON==6 OR MON==9 OR MON==11) THEN
      MON=MON+1;
      X2=X2-30;
    FIN;
    IF X2>31 AND (MON==1 OR MON==3 OR MON==5 OR MON==7
       OR MON==8 OR MON==10 OR MON==12) THEN
      MON=MON+1;
      X2=X2-31;
    FIN;
  END;

  DAT=X2;
END;

DATREAD: TASK PRIO 80;
  DCL X1        FIXED;
  DCL X2        FIXED;
  DCL IND1      FIXED;
  DCL IND2      FIXED;
  DCL POS       FIXED(31);
  DCL BLOOP     BIT(1);
  DCL LASTDAY   FIXED;
  DCL LASTQUART FIXED;
  DCL FIX1      FIXED;
  DCL FIX2      FIXED;
  DCL FIX3      FIXED;
  DCL STATJAHR FIXED; 
  DCL STATMON  FIXED; 
  DCL STATDAT  FIXED; 
  DCL FL1      FLOAT;
  DCL FL2      FLOAT;

  IF B_FLASHVORH THEN
    PUT TO DATEN BY LIST;
    OPEN DATEN BY IDF('DATEN'),OLD;    /* Datei muﬂ vorhanden sein */
    IF ST(DATEN)>1 THEN                /* Datei war nicht vorhanden */
      OPEN DATEN BY IDF('DATEN'),ANY;  /* Datei anlegen */
      CALL REWIND(DATEN);
      CALL STOERMELD (80,'1/4h Daten neu');
      FOR I TO 373 REPEAT
        PUT '1/4h Daten neu ',I TO A1 BY A,F(3),SKIP;  /* MMMM */
        CALL D_CS(1,6);
        PUT '1/4h Daten neu ',I TO LCD BY A,F(3),SKIP;  /* MMMM */
        FOR K TO 96 REPEAT
          FOR J TO DATANZ REPEAT
            CALL WRITE(DATEN,-999.0);
          END;
          B_DATAKT='1'B;
        END;
      END;
    ELSE                               /* Datei war vorhanden */
      CALL SEEK(DATEN,62(31)*96(31)*DATANZ*4(31)); /* Datum 31. Februar */
      PUT 'ST(DATEN) ',ST(DATEN) TO A1 BY A,F(3),SKIP;  /* MMMM */
      IF ST(DATEN) > 1 THEN            /* Position falsch */
        CALL REWIND(DATEN);
        CALL STOERMELD (80,'1/4h Daten neu');
        FOR I TO 373 REPEAT
          PUT '1/4h Daten neu ',I TO A1 BY A,F(3),SKIP;  /* MMMM */
          CALL D_CS(1,6);
          PUT '1/4h Daten neu ',I TO LCD BY A,F(3),SKIP;  /* MMMM */
          FOR K TO 96 REPEAT
            FOR J TO DATANZ REPEAT
              CALL WRITE(DATEN,-999.0);
            END;
            B_DATAKT='1'B;
          END;
        END;
      ELSE  /* normale Position nach Fehldaten suchen */    
    !   CALL READ(DATEN,LASTDAY,LASTQUART);  /* letzte Speicherung DATNR,1/4h */
        CALL READ(DATEN,FL1    ,FL2      );  /* letzte Speicherung DATNR,1/4h */
        LASTDAY=ROUND(FL1);
        LASTQUART=ROUND(FL2);
    !   PUT 'LASTDAY   ',LASTDAY TO A1 BY A,F(10),SKIP;
    !   PUT 'LASTQUART ',LASTQUART TO A1 BY A,F(10),SKIP;
        X1=ENTIER((ZP_NOW-00:00:00)/15 MIN);
        X2=DA_TNR-LASTDAY;  /* anz Fehltage */          
        IF X2 > 5 THEN
          X2=0;
          CALL STOERMELD (80,'1/4h> 5T. fehlen');
        FIN;
        BLOOP='1'B;
        IF DA_DAT==1 AND DA_MON==1 AND ZP_NOW < 00:02:00 THEN  /* Sylvesterreset ignorieren */
          BLOOP='0'B;
          X2=0;
        FIN;
        IF X2 > 0 THEN
          FIX1=X2//100;
          FIX2=(X2-FIX1*100)//10;
          FIX3=X2 REM 10;
          CALL STOERMELD (80,'1/4h ' CAT TOCHAR(FIX1+48)
                                     CAT TOCHAR(FIX2+48)
                                     CAT TOCHAR(FIX3+48)
                                     CAT 'Tage neu');  
        FIN;
        WHILE X2 > 0 REPEAT
          CALL MONDAT(DA_TNR-X2,STATDAT,STATMON,STATJAHR);   /* aktueller Tag - Fehltage */ 
          IF BLOOP THEN    /* erster Durchlauf bis LASTQUART sind Daten OK */
            POS=(((STATMON-1)*31(31)+STATDAT)*96(31)+(LASTQUART+1)*1(31))*DATANZ*4(31);
            CALL SEEK(DATEN,POS);
            FOR I FROM LASTQUART+1 TO 96 REPEAT
              FOR K TO DATANZ REPEAT
                CALL WRITE(DATEN,-999.0);
              END;
              B_DATAKT='1'B;
            END;
          ELSE
            POS=((STATMON-1)*31(31)+STATDAT)*96(31)*DATANZ*4(31);
            CALL SEEK(DATEN,POS);
            FOR I TO 96 REPEAT
              FOR K TO DATANZ REPEAT
                CALL WRITE(DATEN,-999.0);
              END;
              B_DATAKT='1'B;
            END;
          FIN;
          BLOOP='0'B;
          X2=X2-1;
          PUT '1/4h Daten erneuern noch',X2 TO A1 BY A,F(3),SKIP;  /* MMMM */
          CALL D_CS(1,6);
          PUT '1/4h Daten erneuern noch',X2 TO LCD BY A,F(3),SKIP;  /* MMMM */
        END;
        IF BLOOP THEN  /* X2 war < 1 Daten von heute sind bis LASTQUART OK */
          FIX1=ENTIER((ZP_NOW-00:00:00)/15 MIN)-LASTQUART;
          IF FIX1 > 10 THEN
            FIX2=FIX1//10;
            FIX3=FIX1 REM 10;
            CALL STOERMELD (80,'1/4h ' CAT TOCHAR(FIX2+48)
                                       CAT TOCHAR(FIX3+48)
                                       CAT ' 1/4h neu');  
          FIN;
          CALL MONDAT(DA_TNR,STATDAT,STATMON,STATJAHR);    /*  */
          POS=(((STATMON-1)*31(31)+STATDAT)*96(31)+(LASTQUART+1)*1(31))*DATANZ*4(31);
          CALL SEEK(DATEN,POS);
          FOR I FROM LASTQUART+1 TO 96 REPEAT
            FOR K TO DATANZ REPEAT
              CALL WRITE(DATEN,-999.0);
            END;
            B_DATAKT='1'B;
          END;
        ELSE           /* X2 war > 0 Daten von heute komplett lˆschen */
          CALL MONDAT(DA_TNR,STATDAT,STATMON,STATJAHR);    /*  */
          POS=(((STATMON-1)*31(31)+STATDAT)*96(31))*DATANZ*4(31);
          CALL SEEK(DATEN,POS);
          FOR I TO 96 REPEAT
            FOR K TO DATANZ REPEAT
              CALL WRITE(DATEN,-999.0);
            END;
            B_DATAKT='1'B;
          END;
        FIN;
      FIN;
    FIN;

    CALL SEEK(DATEN,62(31)*96(31)*DATANZ*4(31)); /* Datum 31. Februar */
    X1=ENTIER((ZP_NOW-00:00:00)/15 MIN);
    FL1=DA_TNR;
    FL2=X1;
    CALL WRITE(DATEN,FL1,FL2);  /* letzte Speicherung DATNR,1/4h */
    CALL SYNC(DATEN);
    PUT 'SYNC H0.' TO RTOS BY A;

  FIN;
END;

/*********************************************************************/
/* Initialisierung der Monatsz‰hler                                  */
/*********************************************************************/

I_MON: PROC (NAME CHAR(25), EINH CHAR(5), NR FIXED);

  MON_NAME(NR)=NAME;
  MON_EINH(NR)=EINH;

END;

/*********************************************************************/
/* Initialisierung der 1/4h-Speicherkan‰le                           */
/*********************************************************************/

I_VIERT: PROC (NAME CHAR(20), EINH CHAR(5), (NR,FAKT) FIXED, (MIN,MAX,YACHS) FLOAT);

  VIERT_NAME(NR)=NAME;
  VIERT_EINH(NR)=EINH;
  DATFAKT(NR)=FAKT;


END;

/*********************************************************************/
/* Initialisierung der Softwarez{hleing{nge                          */
/*********************************************************************/

I_Z: PROC (NAME CHAR(27), (EIN,TYP) FIXED);

  N_ZAEHLER=N_ZAEHLER+1;

  ZP_NAME(N_ZAEHLER)=NAME;  /* Name des FÅhlers                      */
  ZP_EIN(N_ZAEHLER)=EIN;    /* EingangszÑhler EIN fÅr Eingang Nr.... */
  ZP_TYP(N_ZAEHLER)=TYP;    /* ZÑhlerart (WÑrme,Strom,...)           */

END;


INIT_ZAEHL: PROC GLOBAL;

  DCL X1        FIXED;
  DCL X2        FIXED;
  DCL IND1      FIXED;
  DCL IND2      FIXED;
  DCL POS       FIXED(31);
  DCL BLOOP     BIT(1);
  DCL LASTDAY   FIXED;
  DCL LASTQUART FIXED;
  DCL FIX1      FIXED;
  DCL FIX2      FIXED;
  DCL FIX3      FIXED;
  DCL STAT      BIT(32);

  N_ZAEHLER=0;

  /* TYP             Art des Zaehlers                                */
  /*-----------------------------------------------------------------*/
  /*  1   :         m^3                                              */
  /*  2   :         kWh                                              */
  /*  3   :         l (Liter)                                        */
  /*-----------------------------------------------------------------*/

  /*                 BI_DEIN(..)      Software-                   */
  /*              Name                 Eingang  TYP   */
! CALL I_Z('Volumen HZG-Nachspeisung   ',  13,   3);  /*  */
! CALL I_Z('Gas BHKW                   ',   9,   1);  /*  */
! CALL I_Z('Gas gesamt                 ',  10,   1);  /*  */
! CALL I_Z('Wel BHKW (Imp)             ',  14,   2);  /*  */
! CALL I_Z('Wel Photovoltaik           ',  13,   2);  /*  */
! CALL I_Z('Wel Heizpatronen           ',  14,   2);  /*  */
! CALL I_Z('Wel Einspeisung -> EVU     ',  15,   2);  /*  */
! CALL I_Z('Wel Bezug <- EVU           ',  16,   2);  /*  */
! CALL I_Z('Waerme HK1 Kueche          ',  26,   2);  /*  */
! CALL I_Z('Gas BHKW2                  ',  17,   1);  /*  */

! CALL I_Z('Volumen WW1 Verbrauch      ',  18,   1);  /*  */
! CALL I_Z('Volumen WW2 Verbrauch      ',  19,   1);  /*  */
! CALL I_Z('Wel EVU-Bezug              ',   9,   2);  /*  */
! CALL I_Z('Wel EVU-Einspeisung        ',  10,   2);  /*  */
! CALL I_Z('Wel Verbr. Energiez.       ',  11,   2);  /*  */
! CALL I_Z('Wel Bedarf gesamt          ',  12,   2);  /*  */
! CALL I_Z('Volumen WW Ladung          ',  30,   1);  /*  */
! CALL I_Z('Waerme WW Ladung           ',  31,   2);  /*  */
! CALL I_Z('Wel Bedarf gesamt          ',  11,   2);  /*  */
! CALL I_Z('Volumen WW1-Kaltzulauf     ',  22,   1);  /*  */


  CALL I_MON('Waerme BHKW              ','kWh  ', 1);
  CALL I_MON('Waerme Holzkessel1       ','kWh  ', 2);
  CALL I_MON('Waerme Holzkessel2       ','kWh  ', 3);
  CALL I_MON('Waerme Biogaskessel      ','kWh  ', 4);
  CALL I_MON('Waerme HK1 Nordtrasse    ','kWh  ', 5);
  CALL I_MON('Waerme HK2 Westtrasse    ','kWh  ', 6);
  CALL I_MON('Waerme HK3 Suedtrasse    ','kWh  ', 7);
  CALL I_MON('Wel BHKW (ca.)           ','kWh  ', 8);
  CALL I_MON('BHKW1 Betriebsstunden    ','h    ', 9);
  CALL I_MON('Holzkessel1 Betriebsst.  ','h    ',10);
  CALL I_MON('Holzkessel2 Betriebsst.  ','h    ',11);
  CALL I_MON('Biogaskessel Betriebsst. ','h    ',12);

  N_MONZAEHL=12;



  /* Initialisierung der 1/4h Speicherkan‰le */
  /*             Name                Einheit   NR  Faktor    Y-Min  Y-Max  Y-Achseint.       */
! CALL I_VIERT('Pe Bedarf           ','kW   ',  1,     1,     0.0, 200.0,        20.0);   /*  */
  CALL I_VIERT('Pe BHKW (ca.)       ','kW   ',  1,     1,     0.0, 200.0,        20.0);   /*  */
  CALL I_VIERT('Pth Kessel ca.      ','kW   ',  2,     1,     0.0,2000.0,       200.0);   /*  */
  CALL I_VIERT('Pth gesamt ca.      ','kW   ',  3,     1,     0.0,2000.0,       200.0);   /*  */
  CALL I_VIERT('Aussentemp.         ','∞C   ',  4,     1,   -10.0,  30.0,         5.0);   /*  */
  CALL I_VIERT('Hauptkreis VL IST   ','∞C   ',  5,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Hauptkreis VL SOLL  ','∞C   ',  6,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Hauptkreis VL       ','∞C   ',  7,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Puffer1 oben        ','∞C   ',  8,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Puffer1 Mitte oben  ','∞C   ',  9,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Puffer1 Mitte       ','∞C   ', 10,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Puffer1 Mitte unten ','∞C   ', 11,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Puffer1 unten       ','∞C   ', 12,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Hauptkreis RL       ','∞C   ', 13,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Holzkessel1 VL      ','∞C   ', 14,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Holzkessel1 RL      ','∞C   ', 15,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Holzkessel2 VL      ','∞C   ', 16,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Holzkessel2 RL      ','∞C   ', 17,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Biogaskessel VL     ','∞C   ', 18,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Biogaskessel RL     ','∞C   ', 19,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('BHKW VL             ','∞C   ', 20,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('BHKW RL             ','∞C   ', 21,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('HK1 Nordtrasse VL   ','∞C   ', 22,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('HK1 Nordtrasse RL   ','∞C   ', 23,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('HK2 Westtrasse VL   ','∞C   ', 24,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('HK2 Westtrasse RL   ','∞C   ', 25,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Zuluft Trocknung    ','∞C   ', 26,     1,     0.0,  90.0,        10.0);   /*  */  
  CALL I_VIERT('HK3 Suedtrasse VL   ','∞C   ', 27,     1,     0.0,  90.0,        10.0);   /*  */  
  CALL I_VIERT('HK3 Suedtrasse RL   ','∞C   ', 28,     1,     0.0,  90.0,        10.0);   /*  */  
  CALL I_VIERT('Raumtemp.           ','∞C   ', 29,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Pth BHKW            ','kW   ', 30,     1,     0.0,  60.0,         6.0);   /*  */
  CALL I_VIERT('Pth Holzkessel1     ','kW   ', 31,     1,     0.0,  60.0,         6.0);   /*  */
  CALL I_VIERT('Pth Holzkessel2     ','kW   ', 32,     1,     0.0,  60.0,         6.0);   /*  */
  CALL I_VIERT('Pth Biogaskessel    ','kW   ', 33,     1,     0.0, 100.0,        10.0);   /*  */
  CALL I_VIERT('Pth HK1 Nordtrasse  ','kW   ', 34,     1,     0.0, 100.0,        10.0);   /*  */
  CALL I_VIERT('Pth HK2 Westtrasse  ','kW   ', 35,     1,     0.0, 100.0,        10.0);   /*  */
  CALL I_VIERT('Pth HK3 Suedtrasse  ','kW   ', 36,     1,     0.0, 100.0,        10.0);   /*  */
  CALL I_VIERT('Biogas Fuellstand   ','%    ', 37,     1,     0.0, 100.0,        10.0);   /*  */
  CALL I_VIERT('Betrieb Trocknung   ','%    ', 38,     1,     0.0, 100.0,        10.0);   /*  */
  CALL I_VIERT('Druck Verteiler     ','bar  ', 39,     1,     0.0,   5.0,         0.5);   /*  */
  CALL I_VIERT('Stoker Holzkessel1  ','%    ', 40,     1,     0.0, 100.0,        10.0);   /*  */
  CALL I_VIERT('Stoker Holzkessel2  ','%    ', 41,     1,     0.0, 100.0,        10.0);   /*  */
  CALL I_VIERT('Puffer2 oben        ','∞C   ', 42,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Puffer2 Mitte oben  ','∞C   ', 43,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Puffer2 Mitte       ','∞C   ', 44,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Puffer2 Mitte unten ','∞C   ', 45,     1,     0.0,  90.0,        10.0);   /*  */
  CALL I_VIERT('Puffer2 unten       ','∞C   ', 46,     1,     0.0,  90.0,        10.0);   /*  */


  MAXDAT=46;






! CALL I_VIERT('Gassensor           ','V    ', 36,     1,     0.0,   5.0,         0.5);   /*  */
! CALL I_VIERT('Pel Bezug <- EVU    ','kW   ', 36,     1,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('Pel Einsp. -> EVU   ','kW   ', 37,     1,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('Pel Heizpatrone     ','kW   ', 33,     1,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('Pel Photovoltaik    ','kW   ', 34,     1,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('dP HK1 (mWS)  123456','mWS  ', 37,    100,     0.0,  60.0,         6.0);   /*  */
! CALL I_VIERT('Pth gesamt    123456','kW   ', 31,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('Gas gesamt    123456','m^3/h', 32,    100,     0.0,  60.0,         6.0);   /*  */
! CALL I_VIERT('Gas BHKW1     123456','m^3/h', 33,    100,     0.0,  60.0,         6.0);   /*  */
! CALL I_VIERT('Gas BHKW2     123456','m^3/h', 34,    100,     0.0,  60.0,         6.0);   /*  */
! CALL I_VIERT('Gassensor     123456','V    ', 35,    100,     0.0,   5.0,         0.5);   /*  */
! CALL I_VIERT('uAussent. nord','∞C   ', 70,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHauptkreis VL','∞C   ', 71,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHauptkreis RL','∞C   ', 72,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHydr. Weiche ','∞C   ', 73,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uKessel1 VL   ','∞C   ', 74,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uKessel1 RL   ','∞C   ', 75,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uKessel2 VL   ','∞C   ', 76,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uKessel2 RL   ','∞C   ', 77,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uKes Sammel VL','∞C   ', 78,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK1 Sauna VL ','∞C   ', 79,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK1 Sauna RL ','∞C   ', 80,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK2 Kosmet VL','∞C   ', 81,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK2 Kosmet RL','∞C   ', 82,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK3 Calad. VL','∞C   ', 83,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK3 Calad. RL','∞C   ', 84,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK4 FBH VL   ','∞C   ', 85,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK4 FBH RL   ','∞C   ', 86,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK5 Lueft. VL','∞C   ', 87,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK5 Lueft. RL','∞C   ', 88,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK6 Betten VL','∞C   ', 89,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uHK6 Betten RL','∞C   ', 90,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uWW Austritt  ','∞C   ', 91,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uWW Zirk RL   ','∞C   ', 92,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('uGassensor    ','V    ', 93,    100,     0.0,   5.0,         0.5);   /*  */
! CALL I_VIERT('uDruck Vert.  ','bar  ', 94,    100,     0.0,   5.0,         0.5);   /*  */
! CALL I_VIERT('uPth Gaskes.  ','kW   ', 95,     10,     0.0, 200.0,        20.0);   /*  */
! CALL I_VIERT('uPth Oelkes.  ','kW   ', 96,     10,     0.0, 200.0,        20.0);   /*  */
! CALL I_VIERT('uHauptVL IST  ','∞C   ', 97,     10,     0.0,  90.0,        10.0);   /*  */
! CALL I_VIERT('uHauptVL SOLL ','∞C   ', 98,     10,     0.0,  90.0,        10.0);   /*  */

! CALL I_VIERT('Heizraumtemp. ','∞C   ', 41,     10,     0.0,  90.0,        10.0);   /*  */
! CALL I_VIERT('U1 VL Soll    ','∞C   ', 37,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 VL Ist     ','∞C   ', 38,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 NW VL (Beh)','∞C   ', 39,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 NW RL      ','∞C   ', 40,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 HK VL      ','∞C   ', 41,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 HK RL      ','∞C   ', 42,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 WW Lade RL ','∞C   ', 43,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 WW Spei VL ','∞C   ', 44,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 WW Spei o  ','∞C   ', 45,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 WW Spei u  ','∞C   ', 46,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 WW Austr.  ','∞C   ', 47,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 WW Zirk RL ','∞C   ', 48,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('U1 WW-Ladevent','%    ', 49,     10,     0.0, 110.0,        10.0);   /*  */
! CALL I_VIERT('---           ','     ', 50,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('Anst. HKP prim','%    ', 33,     10,     0.0, 110.0,        10.0);   /*  */
! CALL I_VIERT('eta BHKW el   ','%    ', 46,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('eta BHKW th   ','%    ', 47,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('eta BHKW ges  ','%    ', 48,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('eta Kessel th ','%    ', 49,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('1/4Max WW Verb','kW   ', 50,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('1/4Max WW Verb','m^3/h', 51,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('eta BHKW el   ','%    ', 57,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('eta BHKW th   ','%    ', 58,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('eta BHKW ges  ','%    ', 59,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('eta Kessel th ','%    ', 60,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('1/4Max WW Verb','kW   ', 61,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('1/4Max WW Verb','m^3/h', 62,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('Pth WW Ladung ','kW   ', 27,     10,     0.0, 100.0,        10.0);   /*  */
! CALL I_VIERT('BHKW VL       ','∞C   ',  8,     10,     0.0,  90.0,        10.0);   /*  */
! CALL I_VIERT('BHKW RL       ','∞C   ',  9,     10,     0.0,  90.0,        10.0);   /*  */
! CALL I_VIERT('Puffer oben   ','∞C   ', 17,     10,     0.0,  90.0,        10.0);   /*  */
! CALL I_VIERT('Puffer Mitte  ','∞C   ', 18,     10,     0.0,  90.0,        10.0);   /*  */
! CALL I_VIERT('Puffer unten  ','∞C   ', 19,     10,     0.0,  90.0,        10.0);   /*  */
! CALL I_VIERT('Gas BHKW      ','m^3/h', 54,    100,     0.0,  30.0,         3.0);   /*  */

! CALL I_VIERT('Pth BHKW      ','kW   ', 29,     10,     0.0, 400.0,        50.0);   /*  */
! CALL I_VIERT('Pth HK1 Boed80','kW   ', 30,     10,     0.0, 400.0,        50.0);   /*  */
! CALL I_VIERT('Pth HK2 Wede22','kW   ', 31,     10,     0.0,2000.0,       200.0);   /*  */
! CALL I_VIERT('Pth HK3 Boed76','kW   ', 32,     10,     0.0,2000.0,       200.0);   /*  */
! CALL I_VIERT('Gas gesamt    ','m^3/h', 33,    100,     0.0,  60.0,         6.0);   /*  */
! CALL I_VIERT('Gas BHKW      ','m^3/h', 34,    100,     0.0,  60.0,         6.0);   /*  */
! CALL I_VIERT('Pe Bezug      ','kW   ', 35,     10,     0.0, 600.0,        50.0);   /*  */
! CALL I_VIERT('Pe Einspeis.  ','kW   ', 36,     10,     0.0, 600.0,        50.0);   /*  */
! CALL I_VIERT('Druck sek.    ','bar  ', 19,    100,     0.0,   5.0,         0.5);   /*  */
! CALL I_VIERT('Raumtemp Halle','∞C   ', 22,     10,     0.0,  40.0,         5.0);   /*  */
! CALL I_VIERT('RÅckm. HK Mi. ','%    ', 29,     10,     0.0, 110.0,        10.0);   /*  */
! CALL I_VIERT('Druck HK Pmp. ','mWs  ', 33,    100,     0.0,  10.0,         1.0);   /*  */
! CALL I_VIERT('PWM Solar Ladp','%    ', 23,     10,     0.0, 110.0,        10.0);   /*  */
! CALL I_VIERT('WMZ WW Zirk B.','kW   ', 30,     10,     0.0, 100.0,        10.0);   /*  */

! ALL 0.019 SEC ACTIVATE DIN; /* Auslesung der Digitaleing{nge aktiv.*/
  ACTIVATE DIN; /* Auslesung der Digitaleing{nge aktiv.*/

  ACTIVATE DATREAD;
  
  FIX2=0;
  B_DATAKT='1'B;
  STAT=TASKST('DATREAD');
  WHILE STAT.BIT(1)=='0'B AND FIX2 < 25 REPEAT
    IF B_DATAKT THEN
      FIX2=0;
    ELSE
      FIX2=FIX2+1;
    FIN;
    B_DATAKT='0'B;
    AFTER 0.5 SEC RESUME;
    STAT=TASKST('DATREAD');
  END;
  IF FIX2 > 24 THEN
    TERMINATE DATREAD;  
    CALL STOERMELD(80,'1/4h Datei def.');
    B_STOER(80)='1'B;
    PUT '1/4h Datei defekt' TO A1 BY A,SKIP;
  FIN;               

  PUT 'ACTIVATE STOERRIM' TO RTOS;
  PUT 'ACTIVATE STOERMON' TO RTOS;
  
END;

/**Testtask f¸r Datenspeicherung***********************************/
DATTEST: TASK PRIO 32 GLOBAL;

  DCL FL1    FLOAT;
  DCL X1     FIXED;     /* Anzahl der zu Åbertragenden Tage           */
  DCL X2     FIXED;     /* Differenz HEUTE zu gerade Åbertragenem Tag */
  DCL DAT    FIXED;     /* gelesene Daten */
  DCL X3     FIXED(31); /* */
  DCL POS    FIXED(31);


  PUT 'Testdaten suchen' TO TERM BY A,SKIP;
  PUT 'Adresse: ' TO TERM BY A;
  GET X3 FROM BTASTIN BY SKIP,F(8);
  PUT 'Anz Daten: ' TO TERM BY SKIP,A;
  GET X1 FROM BTASTIN BY SKIP,F(6);


  PUT TO TERM BY SKIP,SKIP;
  CALL SEEK(DATEN,X3);
  TO X1 REPEAT
    CALL READ(DATEN,FL1); 
    PUT FL1 TO TERM BY F(9,2),SKIP;
  END;

END;


/*********************************************************************/
/* Erfassung von Viertelstundenwerten verschiedener Gr|~en           */
/*********************************************************************/
M1AUSWERT: PROC ((IDSPUR,IDVAR,ART) FIXED) RETURNS (FLOAT);
  DCL FL1  FLOAT;
  DCL F15  FIXED;

  FL1=0.0;
  CASE ART
    ALT /* 1-MIN DATEN  AUS FL_AIVIERT( , ) */
      FOR I TO 15 REPEAT
        FL_HILF(IDSPUR,I)=FL_AIVIERT(IDVAR,I)/60.0;
        FL1=FL1+FL_HILF(IDSPUR,I);
        FL_AIVIERT(IDVAR,I)=0.0;
      END;
    ALT /* 1-MIN DATEN  AUS Z_IMPDIVIERT( , ) */
      FOR I TO 15 REPEAT
        FL_HILF(IDSPUR,I)=Z_IMPDIVIERT(IDVAR,I)/FL_IMP(IDVAR)*30.0;
        FL1=FL1+Z_IMPDIVIERT(IDVAR,I);
        Z_IMPDIVIERT(IDVAR,I)=0;
      END;
    ALT /* 1-MIN DATEN  AUS FL_THVIERT( , ) */
      FOR I TO 15 REPEAT
        FL_HILF(IDSPUR,I)=FL_THVIERT(IDVAR,I)*60.0;
        FL1=FL1+FL_THVIERT(IDVAR,I);
        FL_THVIERT(IDVAR,I)=0.0;
      END;
    ALT /* 1-MIN DATEN  AUS FL_MBUSVIERT( , ) */
      FOR I TO 15 REPEAT
        FL_HILF(IDSPUR,I)=FL_MBUSVIERT(IDVAR,I)*60.0;
        FL1=FL1+FL_MBUSVIERT(IDVAR,I);
        FL_MBUSVIERT(IDVAR,I)=0.0;
      END;
    ALT /* 1-MIN DATEN  AUS FLSONST( ) */
      FOR I TO 15 REPEAT
        FL_HILF(IDSPUR,I)=FLSONST(I)/60.0;
        FL1=FL1+FL_HILF(IDSPUR,I);
      END;
    OUT
      FOR I TO 15 REPEAT
        FL_HILF(IDSPUR,I)= -999.0;
      END;
  FIN;

  CASE ART
    ALT /* 15-MIN DATEN  AUS FL_AIVIERT( , ) */
      FL1=FL1*0.06666*DATFAKT(IDSPUR);
  !   IF FL1 > 32765.0 THEN  FL1=32765.0;  FIN;
      F15=ROUND(FL1);
    ALT /* 15-MIN DATEN  AUS Z_IMPDIVIERT( , ) */
      FL1=FL1/FL_IMP(IDVAR)*DATFAKT(IDSPUR)*2.0;
  !   IF FL1 > 32765.0 THEN  FL1=32765.0;  FIN;
      F15=ROUND(FL1);
    ALT /* 15-MIN DATEN  AUS FL_THVIERT( , ) */
      FL1=FL1*DATFAKT(IDSPUR)*4.0;
  !   IF FL1 > 32765.0 THEN  FL1=32765.0;  FIN;
      F15=ROUND(FL1);
    ALT /* 15-MIN DATEN  AUS FL_MBUSVIERT( , ) */
      FL1=FL1*DATFAKT(IDSPUR)*4.0;
  !   IF FL1 > 32765.0 THEN  FL1=32765.0;  FIN;
      F15=ROUND(FL1);
    ALT /* 15-MIN DATEN  AUS FLSONST( ) */
      FL1=FL1*0.06666*DATFAKT(IDSPUR);
  !   IF FL1 > 32765.0 THEN  FL1=32765.0;  FIN;
      F15=ROUND(FL1);
    OUT
      F15= -999;
  FIN;

! RETURN(F15);
  RETURN(FL1);

END; /* of PROC TAGESNR */

STATISTIK: TASK PRIO 80;  /* <<< */
  DCL Z_VIERTEL FIXED;
  DCL F_HILF(400) FLOAT;
  DCL F15       FIXED;
  DCL X1        FIXED;
  DCL X2        FIXED;
  DCL X3        FIXED(31);
  DCL ID        FIXED;
  DCL IND1      FIXED;
  DCL IND2      FIXED;
  DCL POS       FIXED(31);
  DCL FL        FLOAT;
  DCL FL1       FLOAT;
  DCL FL2       FLOAT;
  DCL STATJAHR FIXED; 
  DCL STATMON  FIXED; 
  DCL STATDAT  FIXED; 
  DCL TX1MIN   CHAR(21); 
  DCL TXZEIT   CHAR( 8); 
  DCL ZP1       CLOCK;
  DCL ZP2       CLOCK;
  DCL ZP3       CLOCK;
  DCL BWART     BIT(1);


  

  /* Z_VIERTELste Viertelstunde des Tages     */
  ZP_NOW=NOW;
  Z_VIERTEL=ENTIER((ZP_NOW-00:00:00)/15 MIN);

  CALL MONDAT(DA_TNR,STATDAT,STATMON,STATJAHR);   /* aktueller Tag */ 

  TX1MIN.CHAR( 1)='M';              
  TX1MIN.CHAR( 2)='I';              
  TX1MIN.CHAR( 3)='N';              
  TX1MIN.CHAR( 4)='1';              
  TX1MIN.CHAR( 5)='W';              
  TX1MIN.CHAR( 6)='E';              
  TX1MIN.CHAR( 7)='R';              
  TX1MIN.CHAR( 8)='T';              
  TX1MIN.CHAR( 9)='/';              
  TX1MIN.CHAR(10)=TX_DATUM.CHAR( 7);
  TX1MIN.CHAR(11)=TX_DATUM.CHAR( 8);
  TX1MIN.CHAR(12)=TX_DATUM.CHAR( 9);
  TX1MIN.CHAR(13)=TX_DATUM.CHAR(10);
  TX1MIN.CHAR(14)=TX_DATUM.CHAR( 4);
  TX1MIN.CHAR(15)=TX_DATUM.CHAR( 5);
  TX1MIN.CHAR(16)=TX_DATUM.CHAR( 1);
  TX1MIN.CHAR(17)=TX_DATUM.CHAR( 2);
  TX1MIN.CHAR(18)='.';              
  TX1MIN.CHAR(19)='c';              
  TX1MIN.CHAR(20)='s';              
  TX1MIN.CHAR(21)='v';              

! IF Z_LZ < 900(31) THEN
!   FOR I TO 80 REPEAT
!     FL_AIVIERT(I)=FL_AIVIERT(I)*(900(31)/Z_LZ);
!   END;
!   TC_ATFELD(1)=TC_ATFELD(1)*(900(31)/Z_LZ);
! FIN;

  X1=ZF_MIN;   /* Merker */
  X2=0;
  BWART='1'B;
  WHILE BWART AND X2 < 60 REPEAT        /* erst loslegen wenn die letzte MIN der 1/4h rum ist */
    IF X1 == ZF_MIN THEN
    ELSE
      BWART='0'B;
    FIN;
    X2=X2+1;
    AFTER 0.5 SEC RESUME;
  END;


  ZP1=NOW; 


  FOR I TO 200 REPEAT
    F_HILF(I)=0;
  END;



! /* ETAS BHKW1 */
! FL2=Z_IMPDIVIERT( 6)/FL_IMP( 6)/2.0; /* m^3 BHKW */
! IF FL2 > 0.2 THEN /* Gasint.?  -> dann BHKW eta el th ges */
!   FL=(FL_MBUSVIERT(1)) / (FL2*FL_GASHU);
!   F_HILF(47)=ROUND(FL*1000.0);
!   FL=(FL_AIVIERT(87)/3600.0) / (FL2*FL_GASHU);
!   F_HILF(46)=ROUND(FL*1000.0);
!   F_HILF(48)=F_HILF(47)+F_HILF(48);
! ELSE
!   F_HILF(46)=-999;
!   F_HILF(47)=-999;
!   F_HILF(48)=-999;
! FIN;
! FL_AIVIERT(87)=0.0;

! /* ETA KESSEL */
! FL1=Z_IMPDIVIERT( 5)/FL_IMP( 5)/2.0; /* m^3 gesamt */
! FL2=Z_IMPDIVIERT( 6)/FL_IMP( 6)/2.0; /* m^3 BHKW */
! IF FL1-FL2 > 0.2 THEN /* Gasint.?  -> dann KESSEL ETA TH */
!   FL=(FL_MBUSVIERT(2)) / ((FL1-FL2)*FL_GASHU);
!   F_HILF(49)=ROUND(FL*1000.0);
! ELSE
!   F_HILF(49)=-999;
! FIN;




  /* Daten an das File dranh{ngen                                  */
! F_HILF( 1)=M1AUSWERT( 1,201, 1);  /* Pe Bedarf         ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

! F_HILF(1)=ROUND(PE_FELD(1)*10);                 /* el. Bedarf */
! F_HILF(1)=ROUND((Z_BEDVIERT/FL_IMP(30))*20.0);  /* el. Bedarf */
! Z_BEDVIERT=0;                                  
! F_HILF( 1)=ROUND((Z_IMPDIVIERT( 6)/FL_IMP( 6))*20.0 );  /* el. Bedarf        */
! Z_IMPDIVIERT( 6)=0;                                  
! F_HILF( 1)=ROUND(FL_AIVIERTEXT(50)/90.0); /* PE_BEDARF   */
! FL_AIVIERTEXT(50)=0.0;
 
! ID=  1; F_HILF(ID)=M1AUSWERT(ID,201, 1);  /* Pe Bedarf         ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID=  1; F_HILF(ID)=M1AUSWERT(ID,202, 1);  /* Pe BHKWs          ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

! F_HILF(1)=ROUND(PE_ERZFELD(1)*10);            /* el. Erzeugung */
! F_HILF(2)=ROUND((Z_ERZVIERT1/FL_IMP(24))*20.0);  /* el. Erzeugung */
! Z_ERZVIERT1=0;                                  
! F_HILF( 2)=ROUND((Z_IMPDIVIERT(14)/FL_IMP(14))*20.0 );  /* el. Erzeugung     */
! Z_IMPDIVIERT(14)=0;                                  
! F_HILF(3)=ROUND((Z_ERZVIERT2/FL_IMP(25))*20.0);  /* el. Erzeugung */
! Z_ERZVIERT2=0;                                  

  ID=  2; F_HILF(ID)=M1AUSWERT(ID,203, 1);  /* Pth Kessel        ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 
! F_HILF(2)=ROUND(PT_KVIERTEL/90.0*10.0);         /* th. Kessel-Leistung */
  PT_KVIERTEL=0.0;

  ID=  3; F_HILF(ID)=M1AUSWERT(ID,205, 1);  /* Pth gesamt ca.    ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 
! F_HILF(3)=ROUND(TC_ATFELD(1)*10);               /* Pth gesamt ca. */

  Z_BLZVIERT(1)=0;         
  Z_BLZVIERT(2)=0;
! Z_BLZVIERT(3)=0;

  ID=  4; F_HILF(ID)=M1AUSWERT(ID,204, 1);  /* Aussentemp        ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID=  5; F_HILF(ID)=M1AUSWERT(ID,191, 1);  /* Hauptkr. VList    ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID=  6; F_HILF(ID)=M1AUSWERT(ID,190, 1);  /* Hauptkr. VLsoll   ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID=  7; F_HILF(ID)=M1AUSWERT(ID, 13, 1);  /* Haupt VL          ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID=  8; F_HILF(ID)=M1AUSWERT(ID,  8, 1);  /* Pu 1 O            ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID=  9; F_HILF(ID)=M1AUSWERT(ID,  9, 1);  /* Pu2               ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 10; F_HILF(ID)=M1AUSWERT(ID, 10, 1);  /* Pu3               ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 11; F_HILF(ID)=M1AUSWERT(ID, 11, 1);  /* Pu4               ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 12; F_HILF(ID)=M1AUSWERT(ID, 12, 1);  /* Pu5 u             ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 13; F_HILF(ID)=M1AUSWERT(ID, 14, 1);  /* hAUPT rl          ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 14; F_HILF(ID)=M1AUSWERT(ID,  2, 1);  /* Holzk1 Vl         ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 15; F_HILF(ID)=M1AUSWERT(ID,  3, 1);  /* Holzk1 RL         ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 16; F_HILF(ID)=M1AUSWERT(ID,  4, 1);  /* Holzk2 VL         ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 17; F_HILF(ID)=M1AUSWERT(ID,  5, 1);  /* Holzk2 RL         ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 18; F_HILF(ID)=M1AUSWERT(ID,  6, 1);  /* Biogk VL          ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 19; F_HILF(ID)=M1AUSWERT(ID,  7, 1);  /* Biogk RL          ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 20; F_HILF(ID)=M1AUSWERT(ID, 22, 1);  /* bhkw vl           ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 21; F_HILF(ID)=M1AUSWERT(ID, 23, 1);  /* bhkw rl           ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 22; F_HILF(ID)=M1AUSWERT(ID, 15, 1);  /* hk1 vl            ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 23; F_HILF(ID)=M1AUSWERT(ID, 16, 1);  /* hk1 rl            ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 24; F_HILF(ID)=M1AUSWERT(ID, 17, 1);  /* hk2 vl            ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 25; F_HILF(ID)=M1AUSWERT(ID, 18, 1);  /* hk2 rl            ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 26; F_HILF(ID)=M1AUSWERT(ID, 21, 1);  /* Zulu Trock        ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 27; F_HILF(ID)=M1AUSWERT(ID, 19, 1);  /* hk3 vl            ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 28; F_HILF(ID)=M1AUSWERT(ID, 20, 1);  /* hk3 rl            ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 29; F_HILF(ID)=M1AUSWERT(ID, 29, 1);  /* raumt             ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

 
  ID= 30; F_HILF(ID)=M1AUSWERT(ID,  1, 4);  /* pth bhkw          ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 31; F_HILF(ID)=M1AUSWERT(ID,  2, 4);  /* pth holzk1        ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 32; F_HILF(ID)=M1AUSWERT(ID,  3, 4);  /* pth holzk2        ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 33; F_HILF(ID)=M1AUSWERT(ID,  4, 4);  /* pth biogask       ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 34; F_HILF(ID)=M1AUSWERT(ID,  5, 4);  /* pth hk1           ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 35; F_HILF(ID)=M1AUSWERT(ID,  6, 4);  /* pth hk2           ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 36; F_HILF(ID)=M1AUSWERT(ID,  7, 4);  /* pth hk3           ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 37; F_HILF(ID)=M1AUSWERT(ID, 30, 1);  /* biog fuell        ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 38; F_HILF(ID)=M1AUSWERT(ID,188, 1);  /* trockn betr       ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 39; F_HILF(ID)=M1AUSWERT(ID, 32, 1);  /* Druck Vert (bar)  ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 40; F_HILF(ID)=M1AUSWERT(ID,208, 1);  /* stok holzk1       ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 41; F_HILF(ID)=M1AUSWERT(ID,209, 1);  /* stok holzk2       ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 42; F_HILF(ID)=M1AUSWERT(ID, 24, 1);  /* Pu2 1 O           ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 43; F_HILF(ID)=M1AUSWERT(ID, 25, 1);  /* Pu2 2             ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 
                                                         
  ID= 44; F_HILF(ID)=M1AUSWERT(ID, 26, 1);  /* Pu2 3             ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 45; F_HILF(ID)=M1AUSWERT(ID, 27, 1);  /* Pu2 4             ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

  ID= 46; F_HILF(ID)=M1AUSWERT(ID, 28, 1);  /* Pu2 5 u           ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 



! F_HILF(46)=0;
! F_HILF(47)=0;
! F_HILF(48)=0;
! F_HILF(49)=0;

! FOR I TO 15 REPEAT
!   FLSONST(I)=FL_AIVIERT(31,I)+150.0;  /* + 60*2,5 */
!   FL_AIVIERT(31,I)=0.0;
! END;
! ID= 36; F_HILF(ID)=M1AUSWERT(ID,  0, 5);  /* GASSENSOR (V)     ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

! ID= 67; F_HILF(ID)=M1AUSWERT(ID,188, 1);  /* PMP Zubr. Haus A  ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 
!
! ID= 68; F_HILF(ID)=M1AUSWERT(ID,189, 1);  /* PMP Zubr. Villa   ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 
!
! ID= 54; F_HILF(ID)=M1AUSWERT(ID,  1, 4);  /* pth BHKW          ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 
!
!
! F_HILF(32)=M1AUSWERT(32, 15, 2);  /* gas ges           ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 
!
! F_HILF(33)=M1AUSWERT(33, 16, 2);  /* gas bhkw1         ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 
!
! F_HILF(34)=M1AUSWERT(34, 17, 2);  /* gas bhkw2         ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 
!
! FOR I TO 15 REPEAT
!   FLSONST(I)=FL_AIVIERT(31,I)+150.0;  /* + 60*2,5 */
!   FL_AIVIERT(31,I)=0.0;
! END;
! F_HILF(35)=M1AUSWERT(35,  0, 5);  /* GASSENSOR (V)     ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 

! F_HILF(37)=M1AUSWERT(37, 27, 1);  /* dP HK1 (mWS)      ID,ID, 1: AI  2: IMPDI  3: THVIERT  4: MBVIERT  5: FLSONST */ 


! F_HILF(74)=ROUND(FL_THVIERT( 4)*40.0); /* PTH WW4 verb          */
! FL_THVIERT( 4)=0.0;

! F_HILF(60)=ROUND(FL_MBUSVIERT(2)*40.0);   /* PTH bhkw1             */
! FL_MBUSVIERT(2)=0.0;

 
! F_HILF(70)=ROUND(FL_AIVIERTEXT( 1,1)/90.0); /* u at                  */
! FL_AIVIERTEXT( 1,1)=0.0;
!
! F_HILF(71)=ROUND(FL_AIVIERTEXT( 8,1)/90.0); /* u haupt vl            */
! FL_AIVIERTEXT( 8,1)=0.0;
!
! F_HILF(72)=ROUND(FL_AIVIERTEXT( 9,1)/90.0); /* u haupt rl               */
! FL_AIVIERTEXT( 9,1)=0.0;
!
! F_HILF(73)=ROUND(FL_AIVIERTEXT( 7,1)/90.0); /* u hyd wei                */
! FL_AIVIERTEXT( 7,1)=0.0;
!
! F_HILF(74)=ROUND(FL_AIVIERTEXT( 2,1)/90.0); /* u k1 vl                   */
! FL_AIVIERTEXT( 2,1)=0.0;
!
! F_HILF(75)=ROUND(FL_AIVIERTEXT( 3,1)/90.0); /* u k1 rl                   */
! FL_AIVIERTEXT( 3,1)=0.0;
!
! F_HILF(76)=ROUND(FL_AIVIERTEXT( 4,1)/90.0); /* u k2 vl                   */
! FL_AIVIERTEXT( 4,1)=0.0;
!
! F_HILF(77)=ROUND(FL_AIVIERTEXT( 5,1)/90.0); /* u k2 rl                   */
! FL_AIVIERTEXT( 5,1)=0.0;
!
! F_HILF(78)=ROUND(FL_AIVIERTEXT( 6,1)/90.0); /* u k sam vl                */
! FL_AIVIERTEXT( 6,1)=0.0;
!
! F_HILF(79)=ROUND(FL_AIVIERTEXT(10,1)/90.0); /* u hk1 vl                  */
! FL_AIVIERTEXT(10,1)=0.0;
!
! F_HILF(80)=ROUND(FL_AIVIERTEXT(11,1)/90.0); /* u hk1 rl                  */
! FL_AIVIERTEXT(11,1)=0.0;
!
! F_HILF(81)=ROUND(FL_AIVIERTEXT(12,1)/90.0); /* u hk2 vl                  */
! FL_AIVIERTEXT(12,1)=0.0;
!
! F_HILF(82)=ROUND(FL_AIVIERTEXT(13,1)/90.0); /* u hk2 rl                  */
! FL_AIVIERTEXT(13,1)=0.0;
!
! F_HILF(83)=ROUND(FL_AIVIERTEXT(14,1)/90.0); /* u hk3 vl                  */
! FL_AIVIERTEXT(14,1)=0.0;
!
! F_HILF(84)=ROUND(FL_AIVIERTEXT(15,1)/90.0); /* u hk3 rl                  */
! FL_AIVIERTEXT(15,1)=0.0;
!
! F_HILF(85)=ROUND(FL_AIVIERTEXT(16,1)/90.0); /* u hk4 vl                  */
! FL_AIVIERTEXT(16,1)=0.0;
!
! F_HILF(86)=ROUND(FL_AIVIERTEXT(17,1)/90.0); /* u hk4 rl                  */
! FL_AIVIERTEXT(17,1)=0.0;
!
! F_HILF(87)=ROUND(FL_AIVIERTEXT(18,1)/90.0); /* u hk5 vl                  */
! FL_AIVIERTEXT(18,1)=0.0;
!
! F_HILF(88)=ROUND(FL_AIVIERTEXT(19,1)/90.0); /* u hk5 rl                  */
! FL_AIVIERTEXT(19,1)=0.0;
!
! F_HILF(89)=ROUND(FL_AIVIERTEXT(22,1)/90.0); /* u hk6 vl                  */
! FL_AIVIERTEXT(22,1)=0.0;
!
! F_HILF(90)=ROUND(FL_AIVIERTEXT(23,1)/90.0); /* u hk6 rl                  */
! FL_AIVIERTEXT(23,1)=0.0;
!
! F_HILF(91)=ROUND(FL_AIVIERTEXT(20,1)/90.0); /* u ww aus                  */
! FL_AIVIERTEXT(20,1)=0.0;
!
! F_HILF(92)=ROUND(FL_AIVIERTEXT(21,1)/90.0); /* u ww zirk                 */
! FL_AIVIERTEXT(21,1)=0.0;
!
! F_HILF(93)=ROUND((FL_AIVIERTEXT(28,1)+2250.0)/9.0); /* u GASSENSOR (V)      */
! FL_AIVIERTEXT(28,1)=0.0;
!
! F_HILF(94)=ROUND(FL_AIVIERTEXT(29,1)/9.0); /* u Druck Vert (bar)      */
! FL_AIVIERTEXT(29,1)=0.0;
!
! F_HILF(95)=ROUND(FL_AIVIERTEXT(63,1)/90.0); /* u pth gask                */
! FL_AIVIERTEXT(63,1)=0.0;
!
! F_HILF(96)=ROUND(FL_AIVIERTEXT(64,1)/90.0); /* u pth oelk                */
! FL_AIVIERTEXT(64,1)=0.0;
!
! F_HILF(97)=ROUND(FL_AIVIERTEXT(30,1)/90.0); /* u tc_vist                 */
! FL_AIVIERTEXT(30,1)=0.0;
!
! F_HILF(98)=ROUND(FL_AIVIERTEXT(46,1)/90.0); /* u tc_vsoll                */
! FL_AIVIERTEXT(46,1)=0.0;
!
 



! F_HILF(33)=ROUND(FL_AIVIERT(89)*10.0); /* ANST HKP PRIM         */
! FL_AIVIERT(89)=0.0;


!
! F_HILF(42)=ROUND(FL_MBUSVIERT(1)*40.0);   /* PTH Kessel            */
! FL_MBUSVIERT(1)=0.0;
!
! F_HILF(39)=ROUND(FL_THVIERT( 1)*40.0); /* PTH WW VERBR          */
! FL_THVIERT( 1)=0.0;
!
! F_HILF(40)=ROUND((Z_IMPDIVIERT(20)/FL_IMP(20))*200.0 );  /* WW GES ZULAUF     */
! Z_IMPDIVIERT(20)=0;                                  
 



! F_HILF(30)=ROUND(FL_THVIERT( 1)*40.0); /* WMZ BHKW              */
! FL_THVIERT( 1)=0.0;


! F_HILF(83)=ROUND(FL_AIVIERTEXT(70)/90.0); /* uPel Bueros         */
! FL_AIVIERTEXT(70)=0.0;



! F_HILF(27)=Z_DIVIERT(67);              /* Anz Bewe Dusch        */
! Z_DIVIERT(67)=0;                                  

! F_HILF(28)=Z_DIVIERT(68);              /* Anz Tast Dusch        */
! Z_DIVIERT(68)=0;                                  




! F_HILF(15)=ROUND(FL_THVIERT( 1)*40.0); /* WMZ Hauptkreis        */
! FL_THVIERT( 1)=0.0;

! F_HILF(16)=ROUND(FL_THVIERT( 2)*40.0); /* WMZ WW-Ladung         */
! FL_THVIERT( 2)=0.0;

! F_HILF(17)=ROUND(FL_THVIERT( 3)*40.0); /* WMZ BHKW              */
! FL_THVIERT( 3)=0.0;

! F_HILF(18)=ROUND(FL_AIVIERT(29)/9.0); /* Druck prim (bar)      */
! FL_AIVIERT(29)=0.0;

! F_HILF(19)=ROUND(FL_AIVIERT(30)/9.0); /* Druck sek  (bar)      */
! FL_AIVIERT(30)=0.0;


! F_HILF(11)=ROUND((Z_IMPDIVIERT(12)/FL_IMP(12))*20.0 );  /* W‰rme WMZ WW1         */
! Z_IMPDIVIERT(12)=0;                                  
!
! F_HILF(12)=ROUND((Z_IMPDIVIERT(36)/FL_IMP(36))*20.0 );  /* W‰rme WMZ WW2            */
! Z_IMPDIVIERT(36)=0;                                  
!
! F_HILF(13)=ROUND((Z_GASVIERT/FL_IMP( 8))*20.0);   /* 1/4h Gasleistung GESAMT */
! Z_GASVIERT=0;



 
! F_HILF(34)=ROUND((Z_IMPDIVIERT( 5)/FL_IMP( 5))*200.0);  /* DF WW-Kaltzulauf */
! Z_IMPDIVIERT( 5)=0;                                  



! F_HILF(12)=Z_DOVIERT(27);              /* Laufz. L¸ftung        */
! Z_DOVIERT(27)=0;


! F_HILF(17)=ROUND((Z_GASVIERTB/FL_IMP(15))*20.0);   /* 1/4h Gasleistung BHKW   */
! Z_GASVIERTB=0;



! F_HILF(28)=Z_DIVIERT(24);                              /* Tarif HT              */
! Z_DIVIERT(24)=0;                                  

  ZP3=NOW;


  X1=Z_VIERTEL;

! FOR I TO 10 REPEAT
!   F_HILF(I)=I*10;
! END;

  IF Z_LZ < 850(31) THEN
    FOR K TO DATANZ REPEAT
      F_HILF(K)=-999;
    END;
  FIN;


  POS=(((STATMON-1)*31(31)+STATDAT)*96(31)+X1*1(31))*DATANZ*4(31);

! PUT 'POS ',POS TO A1 BY A,F(10),SKIP;

  IF B_FLASHVORH THEN
    /* Koordinierung der Zugriffe auf Compact Flash               */
    /* mit Z_RAMSTAT anfordern und warten bis alle anderen fertig  */
    F15=0;
    WHILE (Z_RAMDUE2 > 0 OR Z_RAMSTOER > 0 OR Z_RAMPAR > 0 OR Z_RAMSON > 0) AND F15 < 3 REPEAT
      F15=F15+1;
      AFTER 0.5 SEC RESUME;
    END;
    Z_RAMSTAT=50;
    AFTER 0.5 SEC RESUME;
    WHILE Z_RAMDUE2 > 0 OR Z_RAMSTOER > 0 OR Z_RAMPAR > 0 OR Z_RAMSON > 0 REPEAT
      IF Z_RAMDUE2  > 0 THEN  Z_RAMDUE2 = Z_RAMDUE2-1;  FIN; 
      IF Z_RAMSTOER > 0 THEN  Z_RAMSTOER= Z_RAMSTOER-1;  FIN; 
      IF Z_RAMPAR   > 0 THEN  Z_RAMPAR  = Z_RAMPAR -1;   FIN; 
      IF Z_RAMSON   > 0 THEN  Z_RAMSON  = Z_RAMSON -1;   FIN;
      AFTER 0.5 SEC RESUME;
    END;
    CALL SEEK(DATEN,POS);
    FOR K TO DATANZ REPEAT
      CALL WRITE(DATEN,F_HILF(K));
    END;
    CALL SEEK(DATEN,62(31)*96(31)*DATANZ*4(31)); /* Datum 31. Februar */
    FL1=DA_TNR;
    FL2=X1;
    CALL WRITE(DATEN,FL1,FL2);  /* letzte Speicherung DATNR,1/4h */
!   CALL SYNC(DATEN);

    OPEN MIN1WERT BY IDF(TX1MIN),OLD;     /* Datei muﬂ vorhanden sein */

 !  X1=ST(MIN1WERT);
 !  PUT X1 TO A1 BY F(15),SKIP;

    IF ST(MIN1WERT)>1 THEN                /* Datei war nicht vorhanden */
      OPEN MIN1WERT BY IDF(TX1MIN),ANY;   /* Datei anlegen */
      CALL REWIND(MIN1WERT);
 !    PUT 'neu anlegen' TO A1 BY A,SKIP;
      PUT 'P',NR_PRJ TO MIN1WERT BY A,F(4);
      PUT '  ',DA_DAT,'.',DA_MON,'.',DA_JAH,'  ' TO MIN1WERT BY A,F(2),A,F(2),A,F(4),A,SKIP;
      PUT 'Zeit,' TO MIN1WERT BY A;
      FOR K TO MAXDAT REPEAT
        PUT VIERT_NAME(K),',' TO MIN1WERT BY A,A;
      END;
      PUT TO MIN1WERT BY SKIP;
 
      FOR I TO 15 REPEAT
        X1=Z_VIERTEL//4;
        X2=Z_VIERTEL REM 4;
        IND1=X1//10;
        TXZEIT.CHAR(1)=TOCHAR(IND1+48);
        IND2=X1 REM 10;
        TXZEIT.CHAR(2)=TOCHAR(IND2+48);
        TXZEIT.CHAR(3)=':';
        IND1=(X2*15+I-1)//10;
        TXZEIT.CHAR(4)=TOCHAR(IND1+48);
        IND2=(X2*15+I-1) REM 10;
        TXZEIT.CHAR(5)=TOCHAR(IND2+48);
        TXZEIT.CHAR(6)=':';
        TXZEIT.CHAR(7)='0';
        TXZEIT.CHAR(8)='0';
        PUT TXZEIT,',' TO MIN1WERT BY A,A;
        FOR K TO MAXDAT REPEAT
          IF FL_HILF(K,I) < 100.0 AND FL_HILF(K,I) > -10.0 THEN
            PUT FL_HILF(K,I),',' TO MIN1WERT BY F(5,2),A;
          ELSE
            IF FL_HILF(K,I) < 1000.0 AND FL_HILF(K,I) > -100.0 THEN
              PUT FL_HILF(K,I),',' TO MIN1WERT BY F(6,2),A;
            ELSE
              IF FL_HILF(K,I) < 10000.0 THEN
                PUT FL_HILF(K,I),',' TO MIN1WERT BY F(7,2),A;
                IF FL_HILF(K,I) < 100000.0 THEN
                  PUT FL_HILF(K,I),',' TO MIN1WERT BY F(8,2),A;
                ELSE
                  PUT FL_HILF(K,I),',' TO MIN1WERT BY F(9,2),A;
                FIN;
              FIN;
            FIN;
          FIN;
        END;
        PUT TO MIN1WERT BY SKIP;
      END;
    
    ELSE

  !   PUT 'vorhanden' TO A1 BY A,SKIP;
      CALL APPEND(MIN1WERT);
      FOR I TO 15 REPEAT
        X1=Z_VIERTEL//4;
        X2=Z_VIERTEL REM 4;
        IND1=X1//10;
        TXZEIT.CHAR(1)=TOCHAR(IND1+48);
        IND2=X1 REM 10;
        TXZEIT.CHAR(2)=TOCHAR(IND2+48);
        TXZEIT.CHAR(3)=':';
        IND1=(X2*15+I-1)//10;
        TXZEIT.CHAR(4)=TOCHAR(IND1+48);
        IND2=(X2*15+I-1) REM 10;
        TXZEIT.CHAR(5)=TOCHAR(IND2+48);
        TXZEIT.CHAR(6)=':';
        TXZEIT.CHAR(7)='0';
        TXZEIT.CHAR(8)='0';
        PUT TXZEIT,',' TO MIN1WERT BY A,A;
        FOR K TO MAXDAT REPEAT
          IF FL_HILF(K,I) < 100.0 AND FL_HILF(K,I) > -10.0 THEN
            PUT FL_HILF(K,I),',' TO MIN1WERT BY F(5,2),A;
          ELSE
            IF FL_HILF(K,I) < 1000.0 AND FL_HILF(K,I) > -100.0 THEN
              PUT FL_HILF(K,I),',' TO MIN1WERT BY F(6,2),A;
            ELSE
              IF FL_HILF(K,I) < 10000.0 THEN
                PUT FL_HILF(K,I),',' TO MIN1WERT BY F(7,2),A;
                IF FL_HILF(K,I) < 100000.0 THEN
                  PUT FL_HILF(K,I),',' TO MIN1WERT BY F(8,2),A;
                ELSE
                  PUT FL_HILF(K,I),',' TO MIN1WERT BY F(9,2),A;
                FIN;
              FIN;
            FIN;
          FIN;
        END;
        PUT TO MIN1WERT BY SKIP;
      END;

    FIN;
    CALL SYNC(MIN1WERT);
  ! CLOSE MIN1WERT;

  FIN;

! ZP2=NOW;
! PUT ZP1,ZP3,ZP2,ZP2-ZP1 TO A1 BY T(18,3),T(18,3),T(18,3),D(27,3),SKIP;

  Z_RAMSTAT=0;  /* FERTIG */

END; /* of Task */




/*********************************************************************/
/* ]bertragung der gespeicherten Viertelstundenwerte auf die         */
/* serielle Schnittstelle  MTERM-AUTOMATIKMODUS                      */
/*********************************************************************/

DATOUT32: PROC( D FLOAT ,K FIXED);
  DCL F15 FIXED;
  DCL F152 FIXED;

  PUT D TO TEMP BY F(11,2);
  PUT ',' TO TEMP BY A;

! F15=ROUND(D);
! IF F15 == -999 THEN
!   PUT ' -999,00' TO TEMP BY A;
! ELSE
!   IF DATFAKT(K)==1 THEN
!     PUT D,',00' TO TEMP BY F(5),A;
!   ELSE
!     IF DATFAKT(K)==10 THEN
!       IF D < 0 THEN
!         F15=D//10;
!         F152=-D;
!         IF F15 == 0 THEN
!           PUT '   -0,',F152 REM 10,'0' TO TEMP BY A,F(1),A;
!         ELSE
!           PUT F15,',',F152 REM 10,'0' TO TEMP BY F(5),A,F(1),A;
!         FIN;
!       ELSE
!         PUT D // 10,',',D REM 10,'0' TO TEMP BY F(5),A,F(1),A;
!       FIN;
!     ELSE /* ==100 */
!       IF D < 0 THEN
!         F15=D//100;
!         IF F15 == 0 THEN
!           PUT '   -0' TO TEMP BY A;
!         ELSE
!           PUT F15 TO TEMP BY F(5);
!         FIN;
!         PUT ',' TO TEMP BY A;
!         D=D-(F15*100);
!         D=-D;
!         F15=D // 10;
!         PUT F15 TO TEMP BY F(1);
!         D=D-(F15*10);
!         PUT D REM 10 TO TEMP BY F(1);
!       ELSE
!         F15=D//100;
!         PUT F15 TO TEMP BY F(5);
!         PUT ',' TO TEMP BY A;
!         D=D-(F15*100);
!         F15=D // 10;
!         PUT F15 TO TEMP BY F(1);
!         D=D-(F15*10);
!         PUT D REM 10 TO TEMP BY F(1);
!       FIN;
!     FIN;
!   FIN;
! FIN;

END;

DUE32: PROC GLOBAL;

  DCL F15    FIXED;
  DCL FIX1   FIXED;
  DCL FIX2   FIXED;
  DCL FIX3   FIXED;
  DCL MAX14H  FIXED;
  DCL ANZ14H  FIXED;
  DCL X1     FIXED;     /* Anzahl der zu Åbertragenden Tage           */
  DCL X2     FIXED;     /* Differenz HEUTE zu gerade Åbertragenem Tag */
  DCL X3     FIXED;     
  DCL X4     FIXED;     
  DCL DAT(150,99) FLOAT;     /* gelesene Daten */
  DCL POS    FIXED(31);
  DCL ANZTAG FIXED;
  DCL DASTART FIXED;
  DCL DASTOP  FIXED;
  DCL MOSTART FIXED;
  DCL MOSTOP  FIXED;
  DCL JASTART FIXED;
  DCL JASTOP  FIXED;
  DCL BLOOP   BIT(1);
  DCL TNR1    FIXED;
  DCL TNR2    FIXED;
  DCL ZWARTOK FIXED;
  DCL NAME    CHAR(128);
  DCL STATJAHR FIXED; 
  DCL STATMON  FIXED; 
  DCL STATDAT  FIXED; 


  IF B_DUE2 THEN  /* ES LƒUFT BEREITS EINE ‹BERTRAGUNG DUE3 / DUE4 */
    AFTER 10 MIN ACTIVATE NAHBED;
    GOTO ENDE;
  FIN;

  IF B_FLASHVORH THEN

    X3=D_SERVDAT( 7)*10+D_SERVDAT( 8);
    DASTART=X3;

    X3=D_SERVDAT( 5)*10+D_SERVDAT( 6);
    MOSTART=X3;

    X3=D_SERVDAT( 3)*10+D_SERVDAT( 4);
    JASTART=X3+2000;
    
    FIX2=D_SERVDAT( 9)*10+D_SERVDAT(10);  /* LETZTE SCHON VORH 1/4H AUF SERVER */

    MAX14H=D_SERVDAT(11)*10+D_SERVDAT(12);  /* gewuenschte ANZ 1/4h */
    IF MAX14H == 0 OR MAX14H > 96 THEN
      MAX14H=96;
    FIN;

    FIX1=ENTIER((ZP_NOW-00:00:00)/15 MIN);
    B_DUE2='1'B;
    X2=0;
  
    TNR1=TAGESNR(DASTART,MOSTART,JASTART);
    TNR2=DA_TNR;                            /* HEUTE */
    IF DA_TNR-TNR1 > 364 THEN
      TNR1=DA_TNR-364;
    FIN;
    IF TNR2 > DA_TNR THEN
      TNR2=DA_TNR;
    FIN;
    IF TNR2 > TNR1-1 THEN
      BLOOP='1'B;
    FIN;
    IF TNR1 < TNR2 THEN  /* SERVER HAT NUR DATEN VOM VORTAG */
      FIX3=FIX2;
      FIX2=0;
    ELSE
      FIX3=0;
    FIN;  
 !  PUT 'TNR1 ',TNR1 TO A1 BY A,F(6),SKIP;
 !  PUT 'TNR2 ',TNR2 TO A1 BY A,F(6),SKIP;
 !  PUT 'FIX2 ',FIX2 TO A1 BY A,F(6),SKIP;
 !  PUT 'FIX3 ',FIX3 TO A1 BY A,F(6),SKIP;
    WHILE BLOOP REPEAT
  
      /* Koordinierung der Zugriffe auf Compact Flash                 */
      /* mit Z_RAMDUE2 anfordern und warten bis alle anderen fertig   */
      F15=0;
      WHILE (Z_RAMSTOER > 0 OR Z_RAMSTAT > 0 OR Z_RAMPAR > 0 OR Z_RAMSON > 0) AND F15 < 3 REPEAT
        F15=F15+1;
        AFTER 0.5 SEC RESUME;
      END;
      Z_RAMDUE2=50;
      AFTER 0.5 SEC RESUME;
      WHILE Z_RAMSTOER > 0 OR Z_RAMSTAT > 0 OR Z_RAMPAR > 0 OR Z_RAMSON > 0 REPEAT
        IF Z_RAMSTOER > 0 THEN  Z_RAMSTOER= Z_RAMSTOER-1; FIN; 
        IF Z_RAMSTAT  > 0 THEN  Z_RAMSTAT = Z_RAMSTAT-1;  FIN; 
        IF Z_RAMPAR   > 0 THEN  Z_RAMPAR  = Z_RAMPAR -1;  FIN; 
        IF Z_RAMSON   > 0 THEN  Z_RAMSON  = Z_RAMSON -1;  FIN;
        AFTER 0.5 SEC RESUME;
      END;
                  
      CALL MONDAT(TNR1,STATDAT,STATMON,STATJAHR);    /*  */
      POS=(((STATMON-1)*31(31)+STATDAT)*96(31))*DATANZ*4(31);
      CALL SEEK(DATEN,POS);
      FOR I TO 96 REPEAT
        FOR K TO DATANZ REPEAT
          CALL READ(DATEN,DAT(K,I));
        END;
      END;
      Z_RAMDUE2=0; /* FERTIG */

      ANZ14H=0;
      IF TNR1 < DA_TNR THEN          /* nicht der aktuelle Tag */
        FOR I TO 96 REPEAT
          IF I > FIX3 AND ANZ14H < MAX14H THEN
            ANZ14H=ANZ14H+1;
            PUT STATDAT,STATMON,STATJAHR-2000  TO TEMP BY F(2),F(2),F(2);    /* Tag   */
            PUT I              TO TEMP BY F(2);    /* 1/4   */
            FOR K TO DATANZ REPEAT
              IF K <= MAXDAT THEN 
                CALL DATOUT32(DAT(K,I),K);
              FIN;
            END;
 !          AFTER 0.3 SEC RESUME;
          FIN;
        END;
        BLOOP='0'B;  /* MAXIMAL 1 TAG */
      ELSE                    /* aktueller Tag Daten nur bis zur akt. 1/4h (FIX1) */
        FOR I TO FIX1 REPEAT
          IF I > FIX2 AND ANZ14H < MAX14H THEN
            ANZ14H=ANZ14H+1;
            PUT STATDAT,STATMON,STATJAHR-2000  TO TEMP BY F(2),F(2),F(2);    /* Tag   */
            PUT I              TO TEMP BY F(2);    /* 1/4   */
            FOR K TO DATANZ REPEAT
              IF K <= MAXDAT THEN 
                CALL DATOUT32(DAT(K,I),K);
              FIN;
            END;
 !          AFTER 0.3 SEC RESUME;
          FIN;
        END;
      FIN;
          
      TNR1=TNR1+1;
      IF TNR1 > TNR2 THEN
        BLOOP='0'B;
      FIN;
    END;
  
 !  AFTER 0.1 SEC RESUME;
  ELSE

   PUT 'Compact Flash nicht vorhanden'  TO TEMP BY A,SKIP; 

  FIN;

ENDE:  
  PUT TOCHAR(27),TOCHAR(27),'D4' TO TEMP BY A,A,A;

  B_DUE2='0'B;
  Z_RAMDUE2=0; /* FERTIG */

END; /* of Task */



/*********************************************************************/
/* Prozeduren zur Verwaltung von Stoerungsmeldungen                  */
/*********************************************************************/
STOERRIM: TASK PRIO 29;
  DCL rim     DATION IN ALPHIC CREATED(RIM);
  DCL CHAR1   CHAR(1);

  OPEN STOER_RIM BY IDF('/STOERRIM');
  
  Z_SCHREIBSTOER=0;
  Z_SCHREIBWART=0;
  REPEAT
    CHAR1=TOCHAR(0);    
    WHILE Z_SCHREIBWART > 0 REPEAT
      Z_SCHREIBWART=Z_SCHREIBWART-1;
      AFTER 0.1 SEC RESUME;
    END;
    GET CHAR1 FROM rim BY A(1);
  ! IF Z_SCHREIBSTOER > 195 THEN
  !   Z_SCHREIBWART=2;
  !   WHILE Z_SCHREIBWART < 10 REPEAT
  !     Z_SCHREIBWART=Z_SCHREIBWART+1;
  !     AFTER 0.5 SEC RESUME;
  !   END;
  !   Z_SCHREIBWART=0;
  ! FIN;
    IF Z_SCHREIBSTOER > 2999 OR Z_SCHREIBSTOER < 1 THEN
      Z_SCHREIBSTOER=1;
    ELSE 
      Z_SCHREIBSTOER=Z_SCHREIBSTOER+1;
    FIN;
    CHSTOER(Z_SCHREIBSTOER)=CHAR1;
  END;

END;


STOERMON: TASK PRIO 28;
  DCL F31     FIXED(31);
  DCL Z       FIXED;
  DCL F15     FIXED;
  DCL CHAR1   CHAR(1);

  REPEAT
    IF Z_SCHREIBSTOER > 1 THEN
      Z=Z+1;
    ELSE
      Z=0;
    FIN;
!   IF Z > 5 OR Z_SCHREIBWART > 1 THEN
    IF Z > 5 OR Z_SCHREIBSTOER > 1000 THEN

      IF B_FLASHVORH THEN
        /* Koordinierung der Zugriffe auf Compact Flash                 */
        /* mit Z_RAMSTOER anfordern und warten bis alle anderen fertig  */
        Z_SCHREIBWART=60;
        F15=0;
        WHILE (Z_RAMDUE2 > 0 OR Z_RAMSTAT > 0 OR Z_RAMPAR > 0 OR Z_RAMSON > 0) AND F15 < 3 REPEAT
          F15=F15+1;
          AFTER 0.5 SEC RESUME;
        END;
        Z_RAMSTOER=50;
        AFTER 0.5 SEC RESUME;
        WHILE Z_RAMDUE2 > 0 OR Z_RAMSTAT > 0 OR Z_RAMPAR > 0 OR Z_RAMSON > 0 REPEAT
          IF Z_RAMDUE2  > 0 THEN  Z_RAMDUE2 = Z_RAMDUE2-1;  FIN; 
          IF Z_RAMSTAT  > 0 THEN  Z_RAMSTAT = Z_RAMSTAT-1;  FIN; 
          IF Z_RAMPAR   > 0 THEN  Z_RAMPAR  = Z_RAMPAR -1;  FIN; 
          IF Z_RAMSON   > 0 THEN  Z_RAMSON  = Z_RAMSON -1;  FIN;
          AFTER 0.1 SEC RESUME;
        END;
        CASE DA_MON
          ALT 
            OPEN MONPROT BY IDF('MONP01'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP02'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP03'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP04'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP05'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP06'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP07'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP08'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP09'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP10'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP11'),ANY;
          ALT 
            OPEN MONPROT BY IDF('MONP12'),ANY;
          OUT
        FIN;
           
        CALL APPEND(MONPROT);
        CALL SAVEP(MONPROT,F31);
        IF F31 < 100000(31) THEN
      !   PUT Z_SCHREIBSTOER TO A12 BY F(5),SKIP;
          FOR I TO Z_SCHREIBSTOER REPEAT
            CHAR1=CHSTOER(I);
            PUT CHAR1 TO MONPROT BY A(1);
          END;
        FIN;
      
        CLOSE MONPROT;
        Z_RAMSTOER=0;  /* FERTIG */

      FIN;

      Z=0;
      Z_SCHREIBSTOER=0;
      Z_SCHREIBWART=0;
      AFTER 0.1 SEC RESUME;

    ELSE

      AFTER 0.1 SEC RESUME;

    FIN;

  END;

END;


STOERMELD: PROC(NR FIXED, TEXT CHAR(20)) GLOBAL;
  DCL MON  FIXED;
  DCL DAT  FIXED;
  DCL STD  FIXED;
  DCL MIN  FIXED;
  DCL SEK  FIXED;
  DCL TX   CHAR(20);

  IF ZF_STOERFREI(NR) < 2 THEN
    FOR I FROM 25 BY -1 TO 2 REPEAT
      TX_STOER(I)=TX_STOER(I-1);
      ART_STOER(I)=ART_STOER(I-1);
      ZT_STOER(I)=ZT_STOER(I-1);
    END;
    TX=TEXT;
    IF Z_STOERNEU(NR)==ZF_STOERMAX24 THEN
      TX.CHAR(19)='!';
      TX.CHAR(20)='W';
    FIN;
    TX_STOER(1)=TX;
    ART_STOER(1)=NR;
    ZT_STOER(1)=ZT_JAHR;
    CALL DATETIME(ZT_STOER(1),DAT,MON,STD,MIN,SEK);
    PUT TX_STOER(1),DAT,'.',MON,'.  ',STD,':',MIN,':',SEK TO STOER_RIM 
      BY A(20),F(3),A,F(2),A,F(2),A,F(2),A,F(2),SKIP;
  FIN;

END;


/*+L*/

MODEND;

