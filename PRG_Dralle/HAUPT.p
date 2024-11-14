/*********************************************************************/
/*          Heizungssteuerungsmodul      Ersterstellung: 13.07.22    */
/* HAUPT:Ablaufsteuerung und Regelung                                */
/* Stand: 13.07.22                                                   */
/*                                                                   */
/* BIOGASANLAGE DRALLE  HOHNE  (aus ROUSSEAU PARK  LUDWIGSFELDE)     */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/* Spezifische Kennzeichnungen mit "<<<"                             */
/* Standartkennzeichnungen mit "!!!"                                 */
/*********************************************************************/

P=MPC604+FPU(4);

/*SC=81000 ,CODE=$0000 ,VAR=$0000; /**/
  SC=75000;  /* */
                                                                  
MODULE HAUPT;

/* Compileroptionen einstellen: */;
/*-L Listing PEARL-Compiler     */;
/*+B Big Module                 */;
/*+M Markierung Zeilennummer    */;
/*+T Test auf Feldgrenzen       */;
/*-P Protokoll Hyperproc Code   */;

SYSTEM;
  /* KEINE VEREINBARUNGEN, HAUPT kennt keine Hardware                */

PROBLEM;
/* fuer Kontrollausgaben bei der Simulation                           */
  SPC TERM DATION   OUT ALPHIC CONTROL (ALL) GLOBAL; /*              */
  SPC LCD  DATION INOUT ALPHIC CONTROL (ALL) GLOBAL; /*              */
  SPC RTOS DATION   OUT ALPHIC CONTROL (ALL) GLOBAL;
  SPC A1                            DATION   OUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC A12                           DATION   OUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC PROT                          DATION INOUT ALPHIC CONTROL(ALL) GLOBAL;

/*-------------------------------------------------------------------*/
/* Tasks                                                             */
  SPC START    TASK;        /* zentrale Starttask                    */
  SPC SYSTAKT  TASK;        /* Grundtakt des Systems                 */
  SPC I_DISP   TASK GLOBAL; /* Nach REGEL wird DISP initialisiert    */
  SPC WATCHDOG TASK GLOBAL; /* Task zur Beruhigung des Watchdog      */
  SPC RAUMABS  TASK;        /* Einzelraumabsenkungstask              */
  SPC HKABS    TASK;        /* Heizkreisabsenkungstask               */
  SPC TASKCONTR TASK;       /* Kontrolltask                          */
  SPC RAMLES   TASK GLOBAL; /* gepufferte Variablen von R8. lesen    */
  SPC RAMSCHREIB TASK GLOBAL; /* gepufferte Var. auf R8. schreiben   */
  SPC STATISTIK TASK GLOBAL; /* Betriebsdatenauswertung in SONDER    */
  SPC DIN       TASK GLOBAL; /* Digitalausg„nge auslesen             */
  SPC BHKWSEND  TASK GLOBAL; /* Task fuer CAN-Comm mit BHKWs          */
  SPC GRUNDFOS   TASK GLOBAL; /* Task fuer Grundfos-Pumpenkommunikation*/
  SPC GRUNDFOS2  TASK GLOBAL; /* Task fuer Grundfos-Pumpenkommunikation*/
  SPC CANIOPLAT TASK GLOBAL; /* Task fuer CAN-Erweiterungsplatinen    */
  SPC CAN1EMPF  TASK GLOBAL; /* Task fuer CAN-Empfang                 */
  SPC MBUSCOMM  TASK GLOBAL; /* Task fuer M-Bus-Kommunikation         */
  SPC FLAMCO    TASK GLOBAL; /* Task fuer FLAMCO-Kommunikation         */
  SPC MODBUS    TASK GLOBAL; /* Task fuer ModBus-Kommunikation         */

/*-------------------------------------------------------------------*/
/* Prozeduren                                                        */
  SPC AIN        ENTRY (FIXED) GLOBAL;
                       /* Analogeing„nge lesen                */
  SPC DIGOUT     ENTRY GLOBAL;/* Digitaldaten ausgeben               */
  SPC AOUT       ENTRY GLOBAL;/* Analogdaten ausgeben                */
  SPC RTC_DATUM  ENTRY GLOBAL;/* Datum aus Echtzeituhr lesen         */
  SPC I_HARDW    ENTRY GLOBAL;/* Initialisierung der Hardware        */
  SPC STOERMELD  ENTRY (FIXED, CHAR(20)) GLOBAL; /* Prozedur fuer Stoerungsmeldungen  */
  SPC INIT_ZAEHL ENTRY GLOBAL;/* Digitaleing„nge mit Z„hlern init.   */
  SPC STARTBHKW  ENTRY GLOBAL;/* BHKW-šberwachung starten            */
  SPC SYSTEMOUT  ENTRY (FIXED) GLOBAL; /* Organisation der Systemmeldungen    */
  SPC I_PARA     ENTRY; /* Initialisierung des Parameter-RAMs        */
  SPC I_F        ENTRY (CHAR(20), FIXED, FIXED, FLOAT, FIXED, FIXED, FIXED, FIXED, FLOAT, FLOAT, FIXED);
                       /* Datensatz eines Analogeingangs initialis. */
  SPC A_F        ENTRY (CHAR(20), FIXED, FIXED, FIXED); 
                        /* Datensatz eines Analogausgangs initialis. */
  SPC TST_B1ZU   ENTRY RETURNS(BIT(1)); /* Zuschaltbedingung BHKW 1  */
  SPC TST_BNZU1  ENTRY RETURNS(BIT(1)); /* Zuschaltbed. BHKW n Teil 1*/
  SPC TST_BNZU2  ENTRY RETURNS(BIT(1)); /* Zuschaltbed. BHKW n Teil 2*/
  SPC TST_K1ZU1  ENTRY RETURNS(BIT(1)); /* Zuschaltbedingung Kessel 1*/
  SPC TST_K1ZU2  ENTRY RETURNS(BIT(1)); /* Zuschaltbedingung Kessel 1*/
  SPC TST_KNZU1  ENTRY RETURNS(BIT(1)); /* Zuschaltbedingung Kessel n*/
  SPC TST_KNZU2  ENTRY RETURNS(BIT(1)); /* Zuschaltbedingung Kessel n*/
  SPC TST_KAB    ENTRY RETURNS(BIT(1)); /* Abschaltbedingung Kessel  */
  SPC TST_BNAB   ENTRY RETURNS(BIT(1)); /* Abschaltbedingung BHKW n  */
  SPC TST_B1AB   ENTRY RETURNS(BIT(1)); /* Abschaltbedingung BHKW 1  */
  SPC (SCH_BZU, SCH_KZU,SCH_BAB,  SCH_KAB) ENTRY;  /* Schaltroutinen            */
  SPC TAGESNR    ENTRY (FIXED, FIXED, FIXED) RETURNS(FIXED); /* berechnet Tagesnummer     */
  SPC WAEZAEHL   ENTRY (FIXED, FIXED, FIXED, FIXED, FIXED);  /* Waermemengenzaehlung        */
  SPC CMD_EXW  ENTRY (CHAR(255)) RETURNS (BIT( 1)) GLOBAL; /* Bedieni.*/
  SPC TASKST   ENTRY (CHAR(24)) RETURNS (BIT(32)) GLOBAL; /* Status? */
  SPC D_CS       ENTRY GLOBAL; /* Curserpositionierung               */
  SPC I_UPE      ENTRY (CHAR(20), FIXED, FIXED);  /* Datensatz einer UPE-Pumpe initialis.      */
  SPC FIXGRENZ   ENTRY (FIXED, FIXED, FIXED IDENT); /* Fixwert begrenzen y > FIX > z      */
  SPC FLOGRENZ   ENTRY (FLOAT, FLOAT, FLOAT IDENT); /* Floatwert begrenzen y > FLOAT > z  */
  SPC DATETIME   ENTRY (FIXED(31), FIXED IDENT, FIXED IDENT, FIXED IDENT, FIXED IDENT, FIXED IDENT);
  SPC MONZAEHL   ENTRY (FIXED, FLOAT(55), FIXED(31));
  SPC I_DO       ENTRY (CHAR(22), FIXED, FIXED, FIXED); /* Digitalausgang initialisieren              */
! SPC CANINIT      ENTRY GLOBAL ; /* CAN-Bus initialisieren */

  DCL ZDFELD1(100) FLOAT;
  DCL ZDFELD2(100) FIXED(31);
  DCL ZFELD        FIXED;
  DCL TC_A         FLOAT;
  DCL Z_MINVIERT   FIXED;

/*-------------------------------------------------------------------*/
#INCLUDE c:\p907\033bgadrallehohne\dcl.p;


RESETPROT: TASK PRIO 9;
  OPEN PROT BY IDF('PROT'),ANY;
  CALL APPEND(PROT);
  PUT 'Reset Nr.: ',Z_RESET,ZP_NOW TO PROT BY A,F(6),T(11),SKIP;
  CLOSE PROT;
END;

REST3: TASK PRIO 9;
  PUT Z_LZ,IT_REST,'%' TO A12 BY F(7),F(8,1),A;
END;

/*********************************************************************/
/* zentrale Start-Task zum Starten der Steuerung                     */
/*********************************************************************/
START: TASK PRIO 10 MAIN; /* wird mittels AUTOSTART gestartet        */

  DCL STAT    BIT(32);
  DCL FL1     FLOAT;
  DCL FL55    FLOAT(55);
  DCL F31     FIXED(31);

  /*-----------------------------------------------------------------*/
  /* Watchdogsoftware aktivieren:                                    */
  B_WDINIT  ='1'B;           /* Watchdog fuer Init paralysieren       */
  B_WATCHDOG='1'B;           /* Watchdog scharfmachen                */
  B_BENUTZER='1'B;           /* Watchdog scharfmachen                */

  /*-----------------------------------------------------------------*/

  /* !!! */
! IDSTRING=' Heizungsst. Brockeler Str. Rotenburg  ';  VERSION AUS P906
! IDSTRING=' Heizungsst. Karrenf.-Str. 1-3  Braunschweig ';  
! IDSTRING=' Heizungsst. Koester Einricht. Rotenburg     ';  
! IDSTRING=' Heizungsst. Havel Marina  Brandenburg       ';  
! IDSTRING=' Heizungsst. Golm (Am Muehlenb.)  Potsdam    ';  
! IDSTRING=' Heizungsst. Torstrasse  Berlin              ';  
! IDSTRING=' Heizungsst. Kurt Bohm Haus  Ketzin          ';  
! IDSTRING=' Heizungsst. Hannaheim  Eberswalde           ';  
! IDSTRING=' Heizungsst. Westerholzer Weg   SW Rotenburg ';  
! IDSTRING=' Heizungsst. Leibnitzstr.99  Postdam         ';  
! IDSTRING=' Heizungsst. Teltomat  Michendorf            ';  
! IDSTRING=' Heizungsst. Wittenauerstr. 112  Berlin      ';  
! IDSTRING=' Heizungsst. Maria Jankowski Park 2-6  Berlin';  
! IDSTRING=' Heizungsst. Rousseau Park  Ludwigsfelde     ';  
  IDSTRING=' Heizungsst. Biogasanlage Dralle  Hohne      ';  

  IDPI=' Biogasanlage Dralle  Hohne                          ';

  PUT 'ER NIL.; mkdir /h0/BGADRALLEHOHNE' TO RTOS;

  CALL I_HARDW;  /* Hardware initialisieren                          */

  PUT 'nach I_HARDW ' TO A1 BY A,SKIP;  /* MMMM */

  /* schon mal alle m”glichen Fuehler vorbesetzen                     */
  N_FUEHLER=0;            /* Analogeing„nge werden in I_F gez„hlt    */
  FOR I TO 150 REPEAT
    CALL I_F('BLIND      '  ,  80,  3,  1.0,    45, 0,   0, 0, 0.0, 0.0, 0);
  END;

  /*-----------------------------------------------------------------*/
  /* Initialisierung der Fuehlerparameter (fuer max. 160 Eing„nge):   */
  /* Fuehler mit Ger„tenummer:                                        */
  /* ID und Nummer kennzeichnen die Art des Fuehlers:                 */
  /* 1. Elektrische Leistung von BHKW(Nummer)                         */
  /* 2. Vorlauftemperatur von Heizkreis(Nummer)                       */
  /* 3. Vorlauftemperatur von Kessel(Nummer)                          */
  /* 4. Obere Brauchwassertemperatur von Speicher(Nummer)             */
  /* 5.                                                               */
  /* 6. BrauchwasserSPEISEtemperatur von Speicher(Nummer)             */
  /* 7. Ruecklauftemperatur von Kessel(Nummer)                        */
  /* 8. Vorlauftemperatur von BHKW(Nummer)                            */
  /* 9. Ruecklauftemperatur von BHKW(Nummer)                          */
  /* 10. Aussentemperatur                                             */
  /* 11. Innentemperatur                                              */
  /* 12. Hauptkreisvorlauftemperatur                                  */
  /* 13. elektrischer Leistungsbedarf des Geb„udes                    */
  /* 14. Ruecklauftemperatur von Brauchwasser(Nummer)                 */
  /* 15. Hauptkreisruecklauftemperatur                                */
  /* 16. šberstr”mung                                                 */
  /* 17. WW-Lade-VL (Nummer)                                          */
  /* 18.                                                              */
  /* 19.                                                              */
  /* 20.                                                              */
  /* 21.                                                              */
  /* 22.                                                              */
  /* 23. Heizkreisruecklauf(Nummer)                                   */
  /* 24.                                                              */
  /* 25.                                                              */
  /* 26.                                                              */
  /* 27.                                                              */
  /* 28.                                                              */
  /* 29.                                                              */
  /* 30. Zirkuations RL (Nummer)                                      */
  /* 31.                                                              */
  /* 32.                                                              */
  /* 33.                                                              */
  /* 40...  Eing„nge die keine weitere Funktion haben als angezeigt   */
  /*        zu werden oder Sonderfunktionen                           */


  N_FUEHLER=0;            /* Analogeing„nge werden in I_F gez„hlt    */

  /*!!!--------------------------------------------------------------*/
  /*                                     Tau in SEC                  */
  /*           Name                HARD  Typ Mittelw. ID,Nr,Seite,Zeile,Untergr,Obergr,ueB?   */
  CALL I_F('Aussent. nord       ' ,   1, 17,100.0,    10, 0,   0, 0,   -25.0,    55.0,  1);
  CALL I_F('Holzkessel1 VL      ' ,   2, 17,  8.0,     3, 1,   3, 1,     0.0,   105.0,  1); 
  CALL I_F('Holzkessel1 RL      ' ,   3, 17,  8.0,     7, 1,   3, 2,     0.0,   105.0,  1); 
  CALL I_F('Holzkessel2 VL      ' ,   4, 17,  8.0,     3, 2,   3, 4,     0.0,   105.0,  1); 
  CALL I_F('Holzkessel2 RL      ' ,   5, 17,  8.0,     7, 2,   3, 5,     0.0,   105.0,  1); 
  CALL I_F('Biogaskessel VL     ' ,   6, 17,  8.0,     3, 3,   2,12,     0.0,   105.0,  1); 
  CALL I_F('Biogaskessel RL     ' ,   7, 17,  8.0,     7, 3,   2,13,     0.0,   105.0,  1); 
  CALL I_F('Puffer1 oben        ' ,   8, 17,  3.0,    40, 0,   2, 2,     0.0,   105.0,  1); 
  CALL I_F('Puffer1 Mitte oben  ' ,   9, 17,  3.0,    16, 0,   2, 3,     0.0,   105.0,  1); /* hyd. Weiche */
  CALL I_F('Puffer1 Mitte       ' ,  10, 17,  3.0,    40, 0,   2, 4,     0.0,   105.0,  1); 
  CALL I_F('Puffer1 Mitte unten ' ,  11, 17, 20.0,    40, 0,   2, 5,     0.0,   105.0,  1); 
  CALL I_F('Puffer1 unten       ' ,  12, 17, 15.0,    40, 0,   2, 6,     0.0,   105.0,  1); 
  CALL I_F('Hauptkreis VL       ' ,  13, 17,  3.0,    12, 0,   2, 1,     0.0,   105.0,  1); /* Hauptkreis VL  */
  CALL I_F('Hauptkreis RL       ' ,  14, 17,  3.0,    15, 0,   2, 7,     0.0,   105.0,  1); /* Hauptkreis RL  */ 
  CALL I_F('HK1 Nordtrasse VL   ' ,  15, 17,  3.0,     2, 1,   3, 7,     0.0,   105.0,  1); 
  CALL I_F('HK1 Nordtrasse RL   ' ,  16, 17,  3.0,    23, 1,   3, 8,     0.0,   105.0,  1);
  CALL I_F('HK2 Westtrasse VL   ' ,  17, 17,  3.0,     2, 2,   3,10,     0.0,   105.0,  1); 
  CALL I_F('HK2 Westtrasse RL   ' ,  18, 17,  3.0,    23, 2,   3,11,     0.0,   105.0,  1);
  CALL I_F('HK3 Suedtrasse VL   ' ,  19, 17,  3.0,     2, 3,   3,14,     0.0,   105.0,  1); 
  CALL I_F('HK3 Suedtrasse RL   ' ,  20, 17,  3.0,    23, 3,   3,15,     0.0,   105.0,  1);
  CALL I_F('Zuluft Trocknung    ' ,  21, 17, 20.0,    40, 0,   3,12,     0.0,   105.0,  1); 
  CALL I_F('BHKW VL             ' ,  22, 17,  3.0,     8, 1,   2, 9,     0.0,   105.0,  0); /*  */
  CALL I_F('BHKW RL             ' ,  23, 17,  3.0,     9, 1,   2,10,     0.0,   105.0,  0); /*  */
  CALL I_F('Puffer2 oben        ' ,  24, 17,  3.0,    40, 0,   4, 1,     0.0,   105.0,  1);                  
  CALL I_F('Puffer2 Mitte oben  ' ,  25, 17,  3.0,    40, 0,   4, 2,     0.0,   105.0,  1); 
  CALL I_F('Puffer2 Mitte       ' ,  26, 17,  3.0,    40, 0,   4, 3,     0.0,   105.0,  1); 
  CALL I_F('Puffer2 Mitte unten ' ,  27, 17, 10.0,    40, 0,   4, 4,     0.0,   105.0,  1); 
  CALL I_F('Puffer2 unten       ' ,  28, 17, 15.0,    40, 0,   4, 5,     0.0,   105.0,  1); 
  CALL I_F('Raumtemp.           ' ,  29, 17,  3.0,    40, 0,   0, 0,     0.0,   105.0,  0);
  CALL I_F('Biogas Fuellstand(%)' ,  30,  4, 15.0,    40, 0,   0, 0,     0.0,   105.0,  0);
  CALL I_F('frei GS             ' ,  31,  7,  3.0,    40, 0,   0, 0,    -1.5,     2.3,  0);
  CALL I_F('Druck Verteiler     ' ,  32,  5,  3.0,    40, 0,   0, 0,    -0.1,     4.5,  1);




  KES_TXT1(1)=' Holzkessel mit  0-10V  Temp-Anst.     ';
  KES_TXT2(1)=' Pumpe mit 0-10V Ansteuerung           ';

  KES_TXT1(2)=' Holzkessel mit  0-10V  Temp-Anst.     ';
  KES_TXT2(2)=' Pumpe mit 0-10V Ansteuerung           ';

  KES_TXT1(3)=' Biogaskessel P rauf/runter            ';
  KES_TXT2(3)=' Pumpe mit 0-10V Ansteuerung           ';

! KES_TXT1(2)=' Remeha ACE mit  0-10V  P-Ansteuerung  ';
! KES_TXT2(2)=' Pumpe Magna3 mit Genibus              ';

! KES_TXT1(1)=' Buderus Lugano 0-10V  P-Ansteuerung   ';
! KES_TXT2(1)=' Pumpe Magna3 mit Genibus              ';
!
! KES_TXT1(2)=' Buderus Lugano 0-10V  P-Ansteuerung   ';
! KES_TXT2(2)=' Pumpe Magna3 mit Genibus              ';

!
! KES_TXT1(2)=' Remeha mit  0-10V  P-Ansteuerung      ';
! KES_TXT2(2)=' Pumpe Magna3 mit Genibus              ';

! KES_TXT1(2)=' Viessmann 0-10V  P-Ansteuerung        ';
! KES_TXT2(2)=' Pumpe Magna3 mit Genibus              ';
!

! WW_NAME(1)=' WW1 Pu Zentr.';
! WW_NAME(2)=' WW2 Pu Haus A';
! WW_NAME(3)=' WW3 Pu Villa ';
! WW_NAME(2)=' WW2 Unterst. ';
! WW_NAME(3)=' WW3 Block8A  ';
! WW_NAME(4)=' WW4 Block9   ';


  FL_XAEINMAX(201)=668.0;

! CALL I_F('dP Haus A (mWS)     ' ,  28, 16,  4.0,    40, 0,   4, 6,    -2.0,     8.0,  0); /* */
! CALL I_F('dP Villa (mWS)      ' ,  29, 16,  4.0,    40, 0,   5, 6,    -2.0,     8.0,  0); /* */
! CALL I_F('WW Lade VL          ' ,  22, 17,  3.0,    17, 1,   3,13,     0.0,   105.0,  1);
! CALL I_F('WW Lade RL          ' ,  23, 17,  3.0,    14, 1,   3,14,     0.0,   105.0,  1);
! CALL I_F('WW Speicher         ' ,  24, 17,  3.0,     4, 1,   3,12,     0.0,   105.0,  1); /* ( WWoben) */
! CALL I_F('WW Austritt         ' ,  25, 17,  3.0,    40, 0,   3,15,     0.0,   105.0,  1); 
! CALL I_F('WW Zirk RL          ' ,  26, 17,  3.0,    30, 1,   3,16,     0.0,   105.0,  1); 
! CALL I_F('WW Lade VL          ' ,  15, 17,  3.0,    17, 1,   3, 4,     0.0,   105.0,  1);
! CALL I_F('WW Lade RL          ' ,  16, 17,  3.0,    14, 1,   3, 5,     0.0,   105.0,  1);
! CALL I_F('WW Austritt         ' ,  17, 17,  3.0,     4, 1,   3, 6,     0.0,   105.0,  1); /* ( WWoben) */
! CALL I_F('WW Zirk RL          ' ,  18, 17,  3.0,    30, 1,   3, 7,     0.0,   105.0,  1); 
! CALL I_F('frei Pt             ' ,  15, 17,  3.0,    40, 0,   0, 0,     0.0,   105.0,  0);
! CALL I_F('Hauptkreis VL 123456' ,  14,  3,  3.0,    12, 0,   2, 1,     0.0,   105.0,  1); /* Hauptkreis VL  */
! CALL I_F('Hauptkreis RL 123456' ,  15,  3,  3.0,    15, 0,   2, 7,     0.0,   105.0,  1); /* Hauptkreis RL  */
! CALL I_F('Puffer oben   123456' ,  10,  3,  3.0,    16, 0,   2, 3,     0.0,   105.0,  1); /* hyd. Weiche */
! CALL I_F('Feuerwehrh. VL' ,  14,  3,  3.0,    17, 1,   3, 4,     0.0,   105.0,  1); /* WW LAD VL */
! CALL I_F('Feuerwehrh. RL' ,  15,  3,  3.0,    14, 1,   3, 5,     0.0,   105.0,  1); /* WW LAD RL */
! CALL I_F('Puffer FW Mitt' ,  16,  3,  3.0,     4, 1,   3, 9,     0.0,   105.0,  1); /* ( WWoben) */
! CALL I_F('Puffer FW RL  ' ,  17,  3,  3.0,    40, 0,   3,10,     0.0,   105.0,  1);
! CALL I_F('WW1 Lade VL   ' ,  20,  3,  3.0,    17, 1,   3, 7,     0.0,   105.0,  1);
! CALL I_F('WW1 Lade RL   ' ,  21,  3,  3.0,    14, 1,   3, 8,     0.0,   105.0,  1);
! CALL I_F('WW1 Zirk RL   ' ,  24,  3,  3.0,    30, 1,   3,11,     0.0,   105.0,  1); 
! CALL I_F('frei PT500    ' ,  42, 12,  3.0,    40, 0,   0, 0,     0.0,   105.0,  0);
! CALL I_F('Zuluftso Halle' ,  48, 11,  3.0,    40, 0,   3,15,     0.0,    31.0,  0);
! CALL I_F('P Bedarf      ' ,  28,  2,  1.0,    13, 0,   0, 0,     0.0,   150.0,  0); 
! CALL I_F('P BHKW 1      ' ,  29,  2,  1.5,     1, 1,   0, 0,     0.0,   150.0,  0); /* */

/* Timer fuer Tarifkalender initialisieren                            */
  T_NAME(55)=' Tarifkalender      ';  /* Tarifkalender Sommer          */
/*T_NAME(56)=' Tarif Winter       ';  /* Tarifkalender Winter          */
! T_NAME(43)=' WW1 Desinfektion   ';  /* Wochenkalender Legionellen WW1*/
! T_NAME(44)=' WW2 Desinfektion   ';  /* Wochenkalender Legionellen WW2*/
! T_NAME(45)=' WW3 Desinfektion   ';  /* Wochenkalender Legionellen WW2*/
! T_NAME(45)=' Desinf. WW3 B8a    ';  /* Wochenkalender Legionellen WW2*/
! T_NAME(46)=' Desinf. WW4 B9     ';  /* Wochenkalender Legionellen WW2*/
  T_NAME(60)=' Freigabe BHKW      ';  /* Wochenkalender BHKW Freigabe  */
  T_NAME(61)=' Zwangsbetr. Trockn.';  /* Wochenkalender Zwangsbetrieb Trocknung */
  T_NAME(62)=' Leisebetr. Trockn. ';  /* Wochenkalender Zwangsbetrieb Trocknung */
! T_NAME(33)=' WW1 Zentr. Tagbetr.';  /* Wochenkalender Freig. WW-Anf.  */
! T_NAME(34)=' WW2 Haus A Tagbetr.';  /* Wochenkalender Freig. WW-Anf.  */
! T_NAME(35)=' WW3 Villa Tagbetr. ';  /* Wochenkalender Freig. WW-Anf.  */
 !T_NAME(36)=' WW4 Block9 Tagb.   ';  /* Wochenkalender Freig. WW-Anf.  */
  /* Wenn sich keine ID oder Nummer zuordnen lassen, liegt ein       */
  /* Spezialfall vor!                                                */

  /* Zeiger vorbesetzen */
  FOR I TO 10 REPEAT
    ZA_BWLPMP(I)=49;  
    ZA_BWSPMP(I)=49;
    ZA_BWZPMP(I)=49;
  END;
  FOR I TO 10 REPEAT
    ZA_KESPMP(I)=49;  
    ZA_KANST(I)=49;  
  END;
  FOR I TO 8 REPEAT    
    ZA_PEBHKW(I)=49;
    ZA_BHKWPMP(I)=49;
  END;
  FOR I TO 32 REPEAT    
    ZA_PHK(I)=49;
  END;

  /*-----------------------------------------------------------------*/
  /* Initialisierung der analogen Ausg„nge                           */
  /*                                                                 */
  /* Identifikationsnummern der analogen Ausg„nge                    */
  /* 1:  Heizkreispumpe                                              */
  /* 2:  BHKW-Solleistung                                            */
  /* 3:  Kesselpumpenleistung                                        */
  /* 4:  Brauchwasserladepumpenleistung                              */
  /* 5:  Brauchwasserspeisepumpenleistung                            */
  /* 6:  Brauchwasserzirkulationspumpenleistung                      */
  /* 7:  BHKW-Pumpenleistung                                         */
  /* 8:  Ansteuerung Kesselleistung                                  */
  /* 9:  sonstiges 0-20mA = 0-100%                                   */
  /*20:  PWM Ausg„nge                                                */
 
  FOR I TO 60 REPEAT
    CALL A_F('---                 ',  16,     9,          0);
  END;
  N_ANALOG=0;
  N_PWM   =0;
  /*          Name                HARD  Identif.  Ger„tenummer       */
! CALL A_F('Solltemp. Holzk.1   ',   1,     8,          1);   /*  1  */
  CALL A_F('Soll PMP Biogaskess.',   1,     8,          1);   /*  1   BIOGASKESSEL PUMPE */
  CALL A_F('Soll Pumpe Holzk.1  ',   2,     3,          1);   /*  2  */
  CALL A_F('Solltemp. Holzk.2   ',   3,     8,          2);   /*  3  */
  CALL A_F('Soll Pumpe Holzk.2  ',   4,     3,          2);   /*  4  */
  CALL A_F('Soll Vent. Trocknung',   5,     9,          0);   /*  5  */
  CALL A_F('Soll Pumpe HK1 Nord ',   6,     1,          1);   /*  6  */
  CALL A_F('Soll Pumpe HK2 West ',   7,     1,          2);   /*  7  */
  CALL A_F('Soll Pumpe HK3 Sued ',   8,     1,          3);   /*  8  */
! CALL A_F('frei 0-10V          ',   6,     9,          0);   /*  6  */
! CALL A_F('frei 0-20mA         ',   7,     9,          0);   /*  7  */
! CALL A_F('frei 0-20mA         ',   8,     9,          0);   /*  8  */
! CALL A_F('Sollleist. Kessel3  ',   3,     8,          3);   /*  3  */
! CALL A_F('Soll WW1-Ladepumpe  ',   2,     4,          1);   /*  2  */

  /* PWM - Ausgaenge benutzen X_AAUS( >100 )                         */
! CALL A_F('Heizpatrone         ',   0,    20,          0);  /*      */
! CALL A_F('Heizpatrone2 (unten)',   0,    20,          0);  /*      */
! ZA_BWZPMP(1)=1;
! CALL A_F('WW Zirk-PMP (Takt)  ',   0,    20,          0);  /* 102  */
! ZA_BWZPMP(1)=1;
! CALL A_F('WW3 Bl.8a Zirk-Pumpe',   0,    20,          0);  /* 103  */
! ZA_BWZPMP(3)=3;
! CALL A_F('WW4 Bl.9 Zirk-Pumpe ',   0,    20,          0);  /* 104  */
! ZA_BWZPMP(4)=4;

  PUT 'nach A_F ' TO A1 BY A,SKIP;  /* MMMM */
  !AFTER 1 SEC RESUME;

/*CALL A_F('Soll BHKW 2         ',   2,     2,          2);   /*  2  */
/*CALL A_F('Pumpe BHKW 1        ',   2,     7,          1);   /*  2  */
/*CALL A_F('BW Speisepumpe      ',   3,     5,          1);   /*  3  */
/*CALL A_F('BW Zirkulationspumpe',   4,     6,          1);   /*  4  */
/*CALL A_F('Kesselpumpe         ',   1,     3,          1);   /*  1  */


  /*******************************************************************/
  /* UPE-Pumpen initialisieren                                       */
  /* Pumpentypen:                                                    */
  /* 1:  Heizkreispumpe                                              */
  /* 2:  Kesselpumpe                                                 */
  /* 3:  Brauchwasserladepumpe                                       */
  /* 4:  Brauchwasserspeisepumpe                                     */
  /* 5:  Brauchwasserzirkulationspumpe                               */
  /* 6:  BHKW-Pumpe                                                  */
  /*10:  sonstige UPE Pumpen                                         */
  N_UPE=0;
  /*          Name                  Typ  Ger„ten.           */
! CALL I_UPE('Pumpe Kessel        ',  2,      1);      /* 1             */
! CALL I_UPE('Pumpe1 HK1 NW nord  ',  1,      1);      /* 2             */
! CALL I_UPE('Pumpe2 HK1 NW nord  ',  1,      2);      /* 3             */
! CALL I_UPE('Pumpe1 HK2 NW sued  ',  1,      3);      /* 4             */
! CALL I_UPE('Pumpe2 HK2 NW sued  ',  1,      4);      /* 5             */
! CALL I_UPE('Pumpe Zubr. Haus A  ',  1,      2);      /* 3             */
! CALL I_UPE('Pumpe Zubr. Villa   ',  1,      3);      /* 4             */
! CALL I_UPE('PMP HK4 FB SH       ',  1,      4);      /* 5             */
! CALL I_UPE('PMP HK5 Konvektoren ',  1,      4);      /* 6             */
! CALL I_UPE('WW2 Sporth Ladepumpe',  3,      1);      /* 7             */
! CALL I_UPE('WW1 Kueche Ladepumpe',  3,      1);      /* 8             */
! CALL I_UPE('WW Zirkulationsp.   ',  5,      1);      /* 4             */
! CALL I_UPE('PMP Freibad         ', 10,      0);      /* 10            */
! CALL I_UPE('uNahwaermepumpe     ', 10,      0);      /* 4             */
! CALL I_UPE('uWW2 Ladepumpe      ',  3,      2);      /* 5             */
! CALL I_UPE('uWW2 Zirkulationsp. ',  5,      2);      /* 6             */
! CALL I_UPE('WW Speisepumpe      ',  4,      1);      /* 4             */


  /* jetzt noch die Fhler initialisieren die Hardwarem„áig nicht    */
  /* an diese Steuerung angeschlossen sind, sondern deren Daten      */
  /* mit dem CAN-Bus bertragen werden. Die Fhler bekommen einen    */
  /* Anzeigeplatz eine logische Identifikation und einen Hardware-   */
  /* kanal gr”áer 80 (N_FUEHLER muá nach der Initialisierung um die  */
  /* Anzahl dieser Fhler reduziert werden)                          */
  /* Die Empfangsdaten werden im Modul BHKW individuell eingetragen  */
! CALL I_F('BHKW1 VL CAN        ' , 181,  1,  3.0,     8, 1,   3, 1,     0.0,   105.0,  0); /*  */
! CALL I_F('BHKW1 RL CAN        ' , 182,  1,  3.0,     9, 1,   3, 2,     0.0,   105.0,  0); /*  */
! CALL I_F('BHKW2 VL CAN        ' , 183,  1,  3.0,     8, 2,   3, 4,     0.0,   105.0,  0); /*  */
! CALL I_F('BHKW2 RL CAN        ' , 184,  1,  3.0,     9, 2,   3, 5,     0.0,   105.0,  0); /*  */
! CALL I_F('BHKW3 VL CAN        ' , 185,  1,  3.0,     8, 3,   3,12,     0.0,   105.0,  0); /*  */
! CALL I_F('BHKW3 RL CAN        ' , 186,  1,  3.0,     9, 3,   3,13,     0.0,   105.0,  0); /*  */
! N_FUEHLER=N_FUEHLER-4;  /* keine echten Fuehler, also wieder abziehen */
  PT_GRUND=0.80;
  PT_FAKTOR=0.80;

  PUT 'N_FUEHLER=',N_FUEHLER TO A1 BY A,F(4),SKIP;  /* MMMM */


  /*-----------------------------------------------------------------*/
  /* Initialisierung der Digitalausgangsdaten                        */
  /*                                                                 */
  /* Initialisiert wird der Name des Ausgangs, die Hardwarenummer    */
  /* des Ausgangs und zwei Zahlen                                    */
  /* die bestimmen ob der Ausgang mit Softwarehandschaltern EIN-     */
  /* oder AUSgeschaltet werden darf und fuer wieviele Sekunden.       */
  /* Ist der Absolutwert der eingegebenen Zahl gr|~er 999 dann ist   */
  /* fuer den Ausgang und die Schaltrichung eine dauerhafte           */
  /* Verstellung ueber Softwarehandschalter m|glich.                  */
  /* TestEIN: 0 bis  1000   (0:kein EIN-Test erlaubt)                */
  /* TestAUS: 0 bis -1000   (0:kein AUS-Test erlaubt)                */
  TO 160 REPEAT
    CALL I_DO('---                   ',80,       0    ,     0);
  END;
  N_DIGOUT=0;

  /*        Name                    HARD   TestEIN   TestAUS */
  CALL I_DO('Holzkessel1           ', 1,    1000    , -1000);
  CALL I_DO('Pumpe Holzkessel1     ', 2,    1000    , -1000);
  CALL I_DO('RL Mischer Holzk.1 auf', 3,    1000    , -1000);
  CALL I_DO('RL Mischer Holzk.1 zu ', 4,    1000    , -1000);
  CALL I_DO('Holzkessel2           ', 5,    1000    , -1000);
  CALL I_DO('Pumpe Holzkessel2     ', 6,    1000    , -1000);
  CALL I_DO('RL Mischer Holzk.2 auf', 7,    1000    , -1000);
  CALL I_DO('RL Mischer Holzk.2 zu ', 8,    1000    , -1000);

  CALL I_DO('Biogaskessel          ', 9,    1000    , -1000);
  CALL I_DO('Biogaskessel P rauf   ',10,    1000    , -1000);
  CALL I_DO('Biogaskessel P runter ',11,    1000    , -1000);
  CALL I_DO('Pumpe Biogaskessel    ',12,    1000    , -1000);
  CALL I_DO('RL Mischer Biogask auf',13,    1000    , -1000);
  CALL I_DO('RL Mischer Biogask zu ',14,    1000    , -1000);
  CALL I_DO('Pumpe HK1 Nordtrasse  ',15,    1000    , -1000);
  CALL I_DO('HK1 Mischer auf       ',16,    1000    , -1000);

  CALL I_DO('HK1 Mischer zu        ',17,    1000    , -1000);
  CALL I_DO('Pumpe HK2 Westtrasse  ',18,    1000    , -1000);
  CALL I_DO('HK2 Mischer auf       ',19,    1000    , -1000);
  CALL I_DO('HK2 Mischer zu        ',20,    1000    , -1000);
  CALL I_DO('Pumpe HK3 Suedtrasse  ',21,    1000    , -1000);
  CALL I_DO('HK3 Mischer auf       ',22,    1000    , -1000);
  CALL I_DO('HK3 Mischer zu        ',23,    1000    , -1000);
  CALL I_DO('Gasfackel EIN         ',24,    1000    , -1000);

  CALL I_DO('Ventilator Trocknung  ',25,    1000    , -1000);
  CALL I_DO('Mischer Trocknung auf ',26,    1000    , -1000);
  CALL I_DO('Mischer Trocknung zu  ',27,    1000    , -1000);
  CALL I_DO('Verdichter Biogas     ',28,    1000    , -1000);  /* parallel mit Biogaskessel */
  CALL I_DO('frei                  ',29,    1000    , -1000);
  CALL I_DO('Sammelstoerung        ',30,    1000    , -1000);
  CALL I_DO('Vers. Pi/Monitor AUS  ',31,     900    , -1000);
  CALL I_DO('VPN-Modul AUS         ',32,     900    , -1000);



  PUT 'nach I_DO ' TO A1 BY A,SKIP;  /* MMMM */

  FOR I TO 150 REPEAT
    DI_NAME(I)= 'frei                     ';
  END;
  
  DI_NAME( 1)=  'HZG-Notschalter          ';
  DI_NAME( 2)=  'Holzk.1 Betrieb (Stoker) ';
  DI_NAME( 3)=  'Holzkessel1 Stoerung     ';
  DI_NAME( 4)=  'Holzk.2 Betrieb (Stoker) ';
  DI_NAME( 5)=  'Holzkessel2 Stoerung     ';
  DI_NAME( 6)=  'Biogaskessel Betrieb     ';
  DI_NAME( 7)=  'Biogaskessel Stoerung    ';
  DI_NAME( 8)=  'Pumpe HK1 Nord Betrieb   ';
  DI_NAME( 9)=  'Stoe PMP HK1 Nord        ';
  DI_NAME(10)=  'Pumpe HK2 West Betrieb   ';
  DI_NAME(11)=  'Stoe PMP HK2 West        ';
  DI_NAME(12)=  'Pumpe HK3 Sued Betrieb   ';
  DI_NAME(13)=  'Stoe PMP HK3 Sued        ';
  DI_NAME(14)=  'Stoe Druckhaltung        ';
  DI_NAME(15)=  'Biogas Fuellstand MAX    ';
  DI_NAME(16)=  'NOT-AUS Trockn. (1:OK)   ';



  FOR I TO 200 REPEAT
    TX_STOERMEL(I)='---                 ';
  END;

! TX_STOERMEL( 1)='BHKW1               ';
! TX_STOERMEL( 2)='BHKW2               ';
! TX_STOERMEL( 3)='BHKW3               ';
  TX_STOERMEL( 4)='Warn HZG-Dr. MAX    ';
  TX_STOERMEL( 5)='Warn HZG-Dr. MIN    ';
  TX_STOERMEL( 6)='HZG-Notschalter     ';
! TX_STOERMEL( 7)='Gassensor Stoer     ';
! TX_STOERMEL( 8)='Gassensor Warn      ';
  TX_STOERMEL( 9)='Holzk.1 Stoerung    ';
  TX_STOERMEL(10)='Holzk.1 Rueckmeld.  ';
  TX_STOERMEL(11)='Holzk.2 Stoerung    ';
  TX_STOERMEL(12)='Holzk.2 Rueckmeld.  ';
  TX_STOERMEL(13)='Biogask. Stoerung   ';
  TX_STOERMEL(14)='Biogask. Rueckmeld. ';
! TX_STOERMEL(11)='Kes2 Stoerung       ';
! TX_STOERMEL(12)='Kes2 Rueckmeld.     ';
  TX_STOERMEL(17)='Hauptkreis kalt     ';
! TX_STOERMEL(15)='WW1 Zent zu kalt    ';
! TX_STOERMEL(16)='WW1 Zent Zirk kalt  ';
! TX_STOERMEL(17)='WW2 Haus A zu kalt  ';
! TX_STOERMEL(18)='WW2 Haus A Zirk kalt';
! TX_STOERMEL(19)='WW3 Villa zu kalt   ';
! TX_STOERMEL(20)='WW3 Villa Zirk kalt ';
! TX_STOERMEL(17)='Warn Sek-Dr. MAX    ';
! TX_STOERMEL(18)='Warn Sek-Dr. MIN    ';
  TX_STOERMEL(21)='HK1 Nord kalt       ';
  TX_STOERMEL(22)='HK2 West kalt       ';
  TX_STOERMEL(23)='HK3 Sued kalt       ';
! TX_STOERMEL(24)='HK4 FB SH kalt      ';
! TX_STOERMEL(25)='HK5 Konvektoren kalt';
! TX_STOERMEL(23)='HK3 Tischlerei kalt ';
! TX_STOERMEL(24)='HK4 Schlosserei kalt';
! TX_STOERMEL(25)='HK5 Sued kalt       ';
! TX_STOERMEL(26)='HK6 FBH kalt        ';
! TX_STOERMEL(26)='HK10 Labor nord kalt';
! TX_STOERMEL(30)='BHKW Rueckm.        ';
  TX_STOERMEL(30)='Stoe PMP HK1 Nord   ';
  TX_STOERMEL(31)='Stoe PMP HK2 West   ';
  TX_STOERMEL(32)='Stoe PMP HK3 Sued   ';
  TX_STOERMEL(33)='Stoe Druckhaltung   ';
  TX_STOERMEL(34)='Biogas Fuellst. MAX ';
  TX_STOERMEL(35)='NOT-AUS Trockn.     ';
! TX_STOERMEL(35)='Stoe PMP Zubr Villa ';
! TX_STOERMEL(36)='Stoe WW1 Zentrale   ';
! TX_STOERMEL(37)='Stoe WW2 Haus A     ';
! TX_STOERMEL(38)='Stoe WW3 Villa      ';
! TX_STOERMEL(39)='Stoe Entgasung      ';
! TX_STOERMEL(40)='Stoe Unterstation   ';
! TX_STOERMEL(35)='Stoe Neutralis.     ';
! TX_STOERMEL(37)='---                 ';
! TX_STOERMEL(38)='---                 ';
! TX_STOERMEL(39)='---                 ';
! TX_STOERMEL(40)='---                 ';
! TX_STOERMEL(43)='UPE1 Kessel  xxx    ';
! TX_STOERMEL(44)='UPE2 P1 HK1  xxx    ';
! TX_STOERMEL(45)='UPE3 P2 HK1  xxx    ';
! TX_STOERMEL(46)='UPE4 P1 HK2  xxx    ';
! TX_STOERMEL(47)='UPE5 P2 HK2  xxx    ';
! TX_STOERMEL(48)='UPE6 HK5 Kon xxx    ';
! TX_STOERMEL(49)='UPE7 WW2 Spo xxx    ';
! TX_STOERMEL(50)='UPE8 WW1 Kue xxx    ';
! TX_STOERMEL(30)='CAN - UST Neub.     ';
! TX_STOERMEL(40)='U1 Hauptk kalt      ';
! TX_STOERMEL(41)='U1 HK kalt          ';
! TX_STOERMEL(42)='U1 WW kalt          ';
! TX_STOERMEL(43)='U1 sonstiges        ';
! TX_STOERMEL(44)='U1 PMP HK           ';

! TX_STOERMEL(52)='BHKW Starts >>      ';
! TX_STOERMEL(53)='CAN - BHKW1         ';
! TX_STOERMEL(54)='CAN - BHKW2         ';
! TX_STOERMEL(55)='CAN - BHKW3         ';
! TX_STOERMEL(56)='Warn. BHKW1         ';
! TX_STOERMEL(57)='Warn. BHKW2         ';
! TX_STOERMEL(58)='Warn. BHKW3         ';

! TX_STOERMEL(60)='Timer BHKW??        ';
! TX_STOERMEL(61)='CAN-Bus             ';
  TX_STOERMEL(62)='System_reset        ';
  TX_STOERMEL(63)='K EIN wg. Hauptk    ';
  TX_STOERMEL(64)='HKxx STW VL         ';
! TX_STOERMEL(65)='WWx Desinf. Warn    ';

  TX_STOERMEL(71)='DATUM???            ';
  TX_STOERMEL(72)='Pi/Monitor reset    ';
  TX_STOERMEL(73)='Pi/Monitor aufgeh.  ';
  TX_STOERMEL(74)='Werte AIxx          ';
! TX_STOERMEL(77)='CAN EW-Karte 3      ';
! TX_STOERMEL(78)='CAN EW-Karte 2      ';
! TX_STOERMEL(79)='CAN EW-Karte 1      ';
  TX_STOERMEL(80)='SYSTEM              ';
  TX_STOERMEL(81)='Handschalter!!      ';
  TX_STOERMEL(82)='A1 Reset xxx        ';

  TX_STOERMEL( 85)='MBus-Zaehler1       ';
  TX_STOERMEL( 86)='MBus-Zaehler2       ';
  TX_STOERMEL( 87)='MBus-Zaehler3       ';
  TX_STOERMEL( 88)='MBus-Zaehler4       ';
  TX_STOERMEL( 89)='MBus-Zaehler5       ';
  TX_STOERMEL( 90)='MBus-Zaehler6       ';
  TX_STOERMEL( 91)='MBus-Zaehler7       ';
! TX_STOERMEL( 92)='MBus-Zaehler8       ';
! TX_STOERMEL( 93)='MBus-Zaehler9       ';
! TX_STOERMEL( 94)='MBus-Zaehler10      ';
! TX_STOERMEL( 95)='MBus-Zaehler11      ';
! TX_STOERMEL( 96)='MBus-Zaehler12      ';
! TX_STOERMEL( 97)='MBus-Zaehler13      ';
! TX_STOERMEL( 98)='MBus-Zaehler14      ';
! TX_STOERMEL( 99)='MBus-Zaehler15      ';
! TX_STOERMEL(100)='MBus-Zaehler16      ';
! TX_STOERMEL(101)='MBus-Zaehler17      ';
! TX_STOERMEL(102)='MBus-Zaehler18      ';
! TX_STOERMEL(103)='MBus-Zaehler19      ';
 
! TX_STOERMEL(100)='UPE1 Kessel  xxx    ';
! TX_STOERMEL(101)='UPE2 HK1 Tor xxx    ';
! TX_STOERMEL(102)='UPE3 HK2 Lin xxx    ';
! TX_STOERMEL(103)='UPE4 HK3 MB  xxx    ';
! TX_STOERMEL(104)='UPE5 HK4 NBp xxx    ';
! TX_STOERMEL(105)='UPE6 HK4 NBs xxx    ';
! TX_STOERMEL(106)='UPE7 WWlad   xxx    ';
! TX_STOERMEL(107)='UPE8 WWzirk  xxx    ';
! TX_STOERMEL(108)='UPE9 Hallb   xxx    ';
! TX_STOERMEL(109)='UPE10 Freib  xxx    ';

  /*-----------------------------------------------------------------*/


  /*-----------------------------------------------------------------*/
  /* Initialisierung der Variablen bei jedem Neustart:               */
  Z_LETZT=1; /* Letzten W{rmeerzeuger vorbesetzen                    */
  TC_VSOLL=20.0; /* Vorlaufsoll                                      */

  PUT 'nach TX_STOERM ' TO A1 BY A,SKIP;  /* MMMM */
  !AFTER 1 SEC RESUME;

  /*-----------------------------------------------------------------*/
  /* Resetdaten ermitteln:                                           */
  ZP_NOW=NOW;                /* ZP_NOW ist die globale Zeit          */
  Z_RESET=Z_RESET+1(31);     /* RESET-Z„hler erh”hen                 */
  ZP_RESET=ZP_NOW;           /*      -Zeitpunkt notieren             */
  DA_RESDAT=DA_DAT;          /*      -Datum notieren                 */
  DA_RESMON=DA_MON;          /*      -Monat notieren                 */

  /*-----------------------------------------------------------------*/
  ZF_STD=ENTIER( (ZP_NOW-00:00:00)/ 1 HRS );
  ZF_MIN=ENTIER( (ZP_NOW-00:00:00)/ 1 MIN ) - 60*ZF_STD;

  /* Zehntelsekundenstand des Jahres                                 */
  F31=ZF_STD*ZK_STUND+ZF_MIN*ZK_MIN;
  ZT_JAHR=(Z_JAHRTAG-1)*ZK_TAG+F31+ENTIER((ZP_NOW-00:00:00)/0.1 SEC-F31);

  
  /*-----------------------------------------------------------------*/
  /* Parameter im batteriegepufferten CMOS-RAM einmal initialisieren:*/
  IF BI_PARA /= 'ECAD1101'B4 THEN /* Falls Magic Word nicht da ist:  */
    AFTER 1 SEC RESUME;
    CALL I_PARA;                  /* Variablen vorbesetzen und       */
    CALL STOERMELD(80,'Neuinit. erf.');
    B_STOER(80)='1'B;
  FIN;

  PUT 'nach BI_PARA/= ' TO A1 BY A,SKIP;  /* MMMM */

  ACTIVATE RESETPROT;


  /* TD_KMIN(10) missbrauchen um bei einem Update einstellbare Variablen vorzubesetzen */ 
  IF TD_KMIN(10) < 100.0 THEN
    TD_KMIN(10)=110.0;

    FL_EXPHK(13)=3.0;    /* WARN SEK DRUCK MAX  */
    FL_EXPHK(14)=1.5;    /* WARN SEK DRUCK MIN  */
!   FL_EXPHK(13)=3.0;    /* LP AUS AB AUSTR > SOLL +  */
!   FL_EXPHK(14)=3.5;    /* LP P+  AB AUSTR < SOLL -  */
!   ZF_WWMI(10)=14;      /* Grundtakt WW-Ladepumpe (s) */ 
!   ZF_WWMI(10)=12;       /* GRUNDTAKT AA WW-LADEPUMPEN   */
!   HK_NAME(1)=' HK1 RLT Buero nord ';
!   HK_NAME(2)=' HK2 RLT WC nord    ';
!   HK_NAME(3)=' HK3 RLT Buero sued ';
!   HK_NAME(4)=' HK4 RLT WC sued    ';
!   HK_NAME(5)=' HK5 RLT Labor sued ';
!   HK_NAME(6)=' HK6 RLT Labor nord ';
    HK_NAME( 1)=' HK1 Nordtrasse     ';
    HK_NAME( 2)=' HK2 Westtrasse     ';
    HK_NAME( 3)=' HK3 Suedtrasse     ';
!   HK_NAME( 4)=' HK4 FB SH          ';
!   HK_NAME( 5)=' HK5 Konvektoren    ';
!   HK_NAME( 6)=' HK6 FBH            ';
!   HK_NAME( 7)=' HK7 Freibad        ';
!   HK_NAME(2)=' HK2 Malerei        ';
!   HK_NAME(3)=' HK3 Buero          ';
!   HK_NAME(4)=' HK4 DAA            ';
    TD_UEBERHEIZ=2.0; /* Ueberheizung Hauptkreis    */
    B_PMPVORL='0'B;   /* Pumpenvorlauf erlaubt?                       */
    PT_KES(1)= 300.0; /* Kesselleistung vorbesetzen                   */
    PT_KES(2)= 300.0; /* Kesselleistung vorbesetzen                   */
    PT_KES(3)= 300.0; /* Kesselleistung vorbesetzen                   */
 !  X_AAKMIN(1)=35.0;  /* Mindest AA bei Kesselbetrieb               */
 !  X_AAKMIN(2)=35.0;  /* Mindest AA bei Kesselbetrieb               */
 !  FS_LKES(1)=1;
    PE_MAXBHKW(1)=300.0; /* Maximalleistung des BHKW                  */
    PE_MINBHKW(1)=200.0; /* Minimalleistung des BHKW                  */
    PE_BMINPRO(1)= 60.0; /* Pel Min erlaubt in % (wg eta)     */
 !  PE_MAXBHKW(2)= 50.0; /* Maximalleistung des BHKW                  */
 !  PE_MINBHKW(2)= 22.0; /* Minimalleistung des BHKW                  */
 !  PE_BMINPRO(2)= 60.0; /* Pel Min erlaubt in % (wg eta)     */
 !  PE_MAXBHKW(3)= 50.0; /* Maximalleistung des BHKW                  */
 !  PE_MINBHKW(3)= 22.0; /* Minimalleistung des BHKW                  */
 !  PE_BMINPRO(3)= 60.0; /* Pel Min erlaubt in % (wg eta)     */
    ZF_T1EIN=  6;         /* Zaehlergrenze TC_VIST<TC_VSOLL (in MIN)  bei Puffer= 2..6   */
    TD_1EIN= 4.0;         /* erlaubte Abweichung BHKW1                bei Puffer= 2..5 bei mit Puentladp= 9  */
  ! ZF_STOERDRIG(7)=1;    /* Gassensor dringend */
    FL_ATTAU=24.0;        /* Tau Glaettung At fuer AT Schnitt (h)  */
    TC_ATTAU=5.0;         /* Geglaettete AT               */
 !  Z_UPEKOMMAND( 1)=2;   /* Kommando Kes-PMP = Konst-KENNL      */
 !  UPE_KENN( 1,2)=60;    /* upe Sollstufe bei   0,8%  */
 !
 !  Z_UPEKOMMAND( 2)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  UPE_KENN( 2,2)= 2;    /* upe Sollstufe bei   0,8%  */
 !
 !  Z_UPEKOMMAND( 3)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  UPE_KENN( 3,2)= 2;    /* upe Sollstufe bei   0,8%  */
 !
 !  Z_UPEKOMMAND( 4)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  UPE_KENN( 4,2)= 2;    /* upe Sollstufe bei   0,8%  */
 !
 !  Z_UPEKOMMAND( 5)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  UPE_KENN( 5,2)= 2;    /* upe Sollstufe bei   0,8%  */
! 
!   Z_UPEKOMMAND( 3)=2;   /* Kommando ZUB-PMP = Konst-KENNL      */
!   UPE_KENN( 3,2)=60;    /* upe Sollstufe bei   0,8%  */
! 
!   Z_UPEKOMMAND( 4)=2;   /* Kommando ZUB-PMP = Konst-KENNL      */
!   UPE_KENN( 4,2)=60;    /* upe Sollstufe bei   0,8%  */
! 
!   Z_UPEKOMMAND( 7)=2;   /* Kommando WWlade PMP = Konst-KENNL      */
!   UPE_KENN( 7,2)=60;    /* upe Sollstufe bei   0,8%  */
! 
!   Z_UPEKOMMAND( 8)=2;   /* Kommando WWlade PMP = Konst-KENNL      */
!   UPE_KENN( 8,2)=60;    /* upe Sollstufe bei   0,8%  */
  
 !  Z_UPEKOMMAND( 5)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  UPE_KENN( 5,2)= 2;    /* upe Sollstufe bei   0,8%  */
 !
 !  Z_UPEKOMMAND( 6)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  UPE_KENN( 6,2)= 2;    /* upe Sollstufe bei   0,8%  */
 !
 !  Z_UPEKOMMAND( 4)=2;   /* Kommando WWzirk PMP = Konst-KENNL      */
 !  UPE_KENN( 4,2)=60;    /* upe Sollstufe bei   0,8%  */
 !
 !  Z_UPEKOMMAND( 3)=2;   /* Kommando PRI-PMP = Konst-KENNL      */
 !  UPE_KENN( 3,2)=60;    /* upe Sollstufe bei   0,8%  */
 !  Z_UPEKOMMAND(10)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  UPE_KENN(10,2)= 2;    /* upe Sollstufe bei   0,8%  */
 !  Z_UPEKOMMAND(11)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  UPE_KENN(11,2)= 2;    /* upe Sollstufe bei   0,8%  */
 !  Z_UPEKOMMAND(12)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  UPE_KENN(12,2)= 2;    /* upe Sollstufe bei   0,8%  */
 !  Z_UPEKOMMAND(8)=2;   /* Kommando WW-Zirkp= Konst-KENNL      */
 !  UPE_KENN(8,2)=50;    /* upe Sollstufe bei   0,8%  */
 !  Z_UPEKOMMAND(5)=2;   /* Kommando HK -PMP = Konst-KENNL      */
 !  UPE_KENN(5,2)=50;    /* upe Sollstufe bei   0,8%  */
 !  FL_SOLLATM10(1)= 5.0; /* Soll HK-Pumpe bei -10 Grad  (mWs)  */
 !  FL_SOLLAT5(1)= 4.0;   /* Soll HK-Pumpe bei   5 Grad  (mWs)  */
 !  FL_SOLLAT20(1)= 3.0;  /* Soll HK-Pumpe bei  20 Grad  (mWs)  */
 !  Z_UPEKOMMAND(6)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
 !  Z_UPEKOMMAND(7)=1;   /* Kommando HK -PMP = PROP -DRUCK      */
!   Z_UPEKOMMAND(3)=0;   /* Kommando WWL-PMP = Konst-DRUCK      */
!   Z_UPEKOMMAND(3)=0;   /* Kommando WWZ-PMP = Konst-DRUCK      */
!   Z_UPEKOMMAND(4)=0;   /* Kommando NW -PMP = Konst-DRUCK      */
!   Z_UPEKOMMAND(5)=0;   /* Kommando WWL-PMP = Konst-DRUCK      */
!   Z_UPEKOMMAND(6)=0;   /* Kommando WWZ-PMP = Konst-DRUCK      */
!   FL_IMP( 6)= 100.0;  /* Gas Kessel                        */
!   FL_IMP( 7)= 100.0;  /* Gas BHKW                          */
!   FL_IMP( 8)=  40.0;  /* Volumen Hauptkreis                */
!   FL_IMP( 9)=  40.0;  /* Volumen WW-Ladung                 */
!   FL_IMP(10)=1000.0;  /* Volumen BHKW                      */
!   TC_HKVMIN(1)=68.0;
    TC_HMT(1)=50.0;
    TC_HMN(1)=50.0;
    TC_HKVMIN(1)=65.0;
    TC_HMT(2)=50.0;
    TC_HMN(2)=50.0;
    TC_HKVMIN(2)=65.0;
    TC_HMT(3)=50.0;
    TC_HMN(3)=50.0;
    TC_HKVMIN(3)=65.0;
    TC_HKVNENN(4)=45.0;  /* ZULUFTSOLLWERT TROCKNUNG */
    TC_HKVNENN(12)=70.0; /* GRENZE PU UNTEN ZWANGSBETRIEB TROCKNUNG */
    TC_HKVNENN(13)=85.0; /* GRENZE FUELLSTAND BIOGAS ZWANGSBETRIEB BIOGASKESSEL */
    TC_HKVNENN(14)=95.0; /* GRENZE FUELLSTAND BIOGAS ZWANGSBETRIEB BIOGASFACKEL */
    TC_HKVNENN(15)=80.0; /* GRENZE BETRIEBSERKENNUNG BHKW                       */


  ! TC_HMT(6)=50.0;
  ! TC_HMN(6)= -2.0;
  ! TC_HMT(7)=50.0;
  ! TC_HMN(7)= -2.0;
  ! TC_HKVMIN(2)=65.0;
  ! TC_HMT(3)=50.0;
  ! TC_HMN(3)=50.0;
  ! TC_HKVMIN(6)=65.0;
  ! TC_HKVNENN(2)=45.0;
  ! TC_HKVNENN(3)=45.0;
  ! TC_HKVNENN(4)=45.0;
  ! TD_HKINTMAX(6)=3.0;      /* langfrist. Integr. MAX        */
  ! TD_HKINTMIN(6)=-1.0;     /* langfrist. Integr. MIN        */
  ! TC_BWSOLL(1)=68.0; /* Brauchwasserspeicher Solltemperatur        */
  ! TC_BWMIN (1)=50.0; /* Brauchwasserspeicher Mindesttemp.          */
  ! TC_BOMAX(1) =80.0; /* maximale obere Speichertemperatur          */
  ! TC_BWSOLL(2)=68.0; /* Brauchwasserspeicher Solltemperatur        */
  ! TC_BWMIN (2)=50.0; /* Brauchwasserspeicher Mindesttemp.          */
  ! TC_BOMAX(2) =80.0; /* maximale obere Speichertemperatur          */
  ! TC_BWSOLL(3)=68.0; /* Brauchwasserspeicher Solltemperatur        */
  ! TC_BWMIN (3)=50.0; /* Brauchwasserspeicher Mindesttemp.          */
  ! TC_BOMAX(3) =80.0; /* maximale obere Speichertemperatur          */
!   TD_BWNORM(1)= 2.5; /* Brauchwasserlad. normal Grenze             */
!   TD_BWDRIG(1)= 5.5; /* Brauchwasserlad. dringend Grenze           */
!   TD_BWTOO(1) = 2.0; /* Start WW-Lad wenn VL > Sp o + TD_BWTOO     */
!   TD_BWTOU(1) = 0.0; /* Stop WW-Lad wenn  VL < Sp o + TD_BWTOU     */
!   TD_BWLS(1)  = 4.0; /* Haupt VL-Sollanf. = BWSOLL+TD_BWLS         */
!   TC_HKVNENN(2)=50.0;
!   TC_HKVMIN(2)=25.0;
    X_AAUSMIN( 2)= 20.0;  /* Pumpe Wilo  */
    X_AAUSMIN( 4)= 20.0;  /* Pumpe Wilo  */
    X_AAUSMIN( 6)= 20.0;  /* Pumpe Wilo  */
    X_AAUSMIN( 7)= 20.0;  /* Pumpe Wilo  */
    X_AAUSMIN( 8)= 20.0;  /* Pumpe Wilo  */
!   ANZ_SLAVE=1;          /* SCHLEICHUPDATE  Anzahl Slaves */
!   VERZ_SLAVE=2;         /* SCHLEICHUPDATE  Verzoegerung bei Uebertragung 2ms   */
    Z_SYSOUT=1;           /* Systemausgaben ganz normal auf Ser1 */  
    ZF_TASTVERZ=500;      /* Tastaturverzoegerung                */ 
    ZF_STOERMAX24=10;     /* erlaubtes Auftreten von Stoerungen / Tag */
    FL_DRMAX=2.9;         /* max HZG-Druck Warngrenze      */
    FL_HZGFUEEIN=2.4;     /* autom. HZG-Nachfuell EIN      */
    FL_HZGFUEAUS=2.6;     /* autom. HZG-Nachfuell AUS      */
    ZF_HZGFUELL=900;      /* autom. HZG-Nachfuell max/Tag (s)  */
    ZF_MBUSLES=900;       /* MBus Auslesung alle ...s      */
  ! FL_EXPHK(15)=20.0;    /* max erl. Einspeisung der Erzeugung in %  */

  ! FOR I TO 2 REPEAT      <<<< BAEDER 
  !   TC_BADSOLL(I)=22.0;
  !   TD_BAD(I)=4.0;
  !   FL_BAD(I)=3.0;
  ! END;
  ! FL_EXPHK(21)=24.0; /* SOLL BAD1  */
  ! FL_EXPHK(22)=24.0; /* SOLL BAD2  */
  ! FL_EXPHK(23)= 1.0; /* ZUSCHLAG BAD1  */
  ! FL_EXPHK(24)= 1.0; /* ZUSCHLAG BAD2  */
  ! FL_EXPHK(25)= 2.0; /* FAKTOR BAD1  */
  ! FL_EXPHK(26)= 2.0; /* FAKTOR BAD2  */
  FIN;


  IF TD_KMIN(10) < 120.0 THEN
    TD_KMIN(10)=130.0;

    FL55=2.0;
    WIRT_ZAEHL(2, 1)=17400.0*FL55;
    WIRT_ZAEHL(2, 2)=14800.0*FL55;
    WIRT_ZAEHL(2, 3)=12600.0*FL55;
    WIRT_ZAEHL(2, 4)= 9800.0*FL55;
    WIRT_ZAEHL(2, 5)= 6400.0*FL55;
    WIRT_ZAEHL(2, 6)= 4200.0*FL55;
    WIRT_ZAEHL(2, 7)= 3900.0*FL55;
    WIRT_ZAEHL(2, 8)= 4000.0*FL55;
    WIRT_ZAEHL(2, 9)= 7400.0*FL55;
    WIRT_ZAEHL(2,10)= 8600.0*FL55;
    WIRT_ZAEHL(2,11)=12300.0*FL55;
    WIRT_ZAEHL(2,12)=15900.0*FL55;
    
    FL_GASCENTPROKWH=5.6;  /* Gaspreis                     */
    Z_WAERMEBHKW=1;        /* 1: SOFT BHKW  2: SOFTWMZ     */

  FIN;

  IF TD_KMIN(10) < 140.0 THEN
    TD_KMIN(10)=150.0;

    TC_KVMAX( 8)=0.0;
    TC_KVMAX( 9)=0.0;

  FIN;

  IF TD_KMIN(10) < 160.0 THEN
    TD_KMIN(10)=170.0;

    TC_HMT(21)=10.0;

  FIN;

  IF TD_KMIN(10) < 180.0 THEN
    TD_KMIN(10)=190.0;

    TC_HMT(22)=60.0;

  FIN;


  /* Texte fuer die Wochentage vorbesetzen:                           */
  TX_TAG(1)='Mo'; TX_TAG(2)='Di'; TX_TAG(3)='Mi';
  TX_TAG(4)='Do'; TX_TAG(5)='Fr'; TX_TAG(6)='Sa'; TX_TAG(7)='So';

  IF DA_JAH < 1990 THEN
    CALL STOERMELD(80,'Uhr,Datum falsch');
  FIN;



  FOR I TO 150 REPEAT          /* Merker mit aktuellen St„nden  <<<   */
    Z_ZAEHLMERK(I)=Z_ZAEHL(I);                      /* vorbesetzen   */
    IF FL_IMP(I)<0.001 THEN
      FL_IMP(I)=0.001;
    FIN;
    FL_IMPDAU(I)=87000.0;
    ZP_IMPALT(I)=NOW;
    IF Z_DIBEWERT(I) > 4 OR Z_DIBEWERT(I) < 1 THEN
      Z_DIBEWERT(I)=1;
    FIN;
  END;

  IF ZP_NOW>01:00:00 AND ZP_NOW<01:10:00 THEN
    /* Kontrollieren ob der Reset evtl. Folge der automatischen      */
    /* Umschaltung auf die Winterzeit war                            */
    IF NOT B_WINTER THEN
      IF   (DA_MON==10 AND DA_WOTAG==7 AND DA_DAT+7>31 AND DA_JAH>1995)
        OR (DA_MON== 9 AND DA_WOTAG==7 AND DA_DAT+7>30 AND DA_JAH<1996)
           THEN
        B_WINTER='1'B;         /* Merker setzen */
      FIN;
    FIN;
  FIN;
  
  B_OUTENA='0'B;   /* Ausgabe vorl„ufig sperren                      */

  CALL INIT_ZAEHL;  /* Z„hler initialisieren und Digitaleing„nge <<< */
  ACTIVATE I_DISP;  /* jetzt den Displayteil starten  */
  PUT 'nach AC I_DISP ' TO A1 BY A,SKIP;  /* MMMM */
  ALL 1 SEC ACTIVATE SYSTAKT; /* Systemgrundtakt                */
  PUT 'nach AC SYSTAKT ' TO A1 BY A,SKIP;  /* MMMM */
  AFTER 0.2 SEC ACTIVATE TASKCONTR;  /* <<< */

  AFTER 20 SEC ACTIVATE RAUMABS;   /* Einzelraumabsenkungstask       */
  AFTER 20.5 SEC ACTIVATE HKABS;   /* Heizkreisabsenkungstask        */
  AFTER 20 SEC ACTIVATE RAMSCHREIB;/* Parametersicherung aktivieren  */
  FOR I TO N_HZKR REPEAT
    B_ABSHK(I)='1'B;
    B_RUNTHK(I)='1'B;
  END;                                       /* vorbesetzen          */

  FOR I TO 96 REPEAT          /* Feld fuer thermische Durchschnitts-  */
    PT_FELD(I)=PT_SCHNITT;    /* leistung mit gelesener              */
  END;                        /* Durchschnittsleistung vorbesetzen   */

  /* Verz”gerte Ausgabe der Steuerbefehle an die Hardware            */
  AFTER 2 SEC RESUME;

  CALL STOERMELD(62,'System_reset');

! AFTER 2 SEC ACTIVATE BHKWSEND;  /* <<< */
  
! AFTER 2 SEC ACTIVATE CANIOPLAT; /* <<< */

! PUT 'nach CANIOPLAT ' TO A1 BY A,SKIP;  /* MMMM */

  AFTER 6 SEC RESUME;

  FOR I TO 96 REPEAT  /* Feld fr durchschn. Aussentemp. mit der     */
    TC_ATFELD(I)=TC_AUSSEN-5.0; /* aktuellen Aussentemp. vorbesetzen */
  END;

  B_OUTENA='1'B; /* Digitalausgabe freigeben                         */

  AFTER 12 SEC RESUME;

  B_WDINIT='0'B;     /* Watchdog nach Init scharfmachen              */
  Z_HMNEU=0;         /* Hausmeister freigeben                            */

  PUT 'START BEENDET' TO A1 BY A,SKIP;  /* MMMM */

END; /* of TASK START */

/*****************************************************************/
/* Task zur Kontrolle von RS485- und CAN-Kommunikation           */
/*****************************************************************/
PLANRESET: PROC;
  DCL C FIXED;

  ACTIVATE RAMSCHREIB;
  ACTIVATE RAMSCHREIB;
  C=0;
  WHILE C < 120 REPEAT
    FOR I TO N_KESSEL REPEAT
      B_KEIN(I)='0'B;
      Z_KPNL(I)=20;
    END;
    FOR I TO N_BHKW REPEAT
      B_BEIN(I)='0'B;
      Z_BPNL(I)=20;
    END;
    C=C+1;
    AFTER 1 SEC RESUME;
  END;
  PUT 'TERMINATE Watch -- PREVENT WATCHDOG' TO RTOS;
  WHILE C < 200 REPEAT
    C=C+1;
    AFTER 1 SEC RESUME;
  END;

END;



TASKCONTR: TASK PRIO 10;
  DCL TEXT    CHAR(80);
  DCL B1      BIT(1);

  DCL Z_MODINITAKT  FIXED;
  DCL Z_MENUERR     FIXED;
  DCL Z_DISPERR     FIXED;
  DCL C             FIXED;
  DCL STAT          BIT(32);
  DCL F31           FIXED(31);   

  Z_MODINITAKT=0;
  Z_MENUERR=0;
  Z_DISPERR=0;

  Z_GFCONTR=60;
  Z_GFCONTR2=60;
  Z_GFNEUST=0;
  Z_GFNEUST2=0;
  Z_CAN1CONTR=60;
  Z_CAN1NEUST=0;
  Z_MBUS=60;
  Z_MBUSNEUST=0;
  Z_HKABS=200;
  Z_RAUMABS=200;
  Z_FLAMCO=600;
  Z_MODBUS=915;
  
! ACTIVATE GRUNDFOS; /* <<< */
! ACTIVATE GRUNDFOS2; /* <<< */
  ACTIVATE MBUSCOMM;
! ACTIVATE FLAMCO;  
! AFTER 15 SEC ACTIVATE MODBUS;
  
  REPEAT

    IT_REST=IT_COUNT2/12300.0;
    IT_COUNT1=1(31);
    IT_COUNT2=0(31);
  
    IF Z_LZ < 5(31) THEN
      PUT Z_LZ,NOW,IT_REST,'%' TO A12 BY F(7),T(14,3),F(6,1),A,SKIP;
    FIN;
  
    IF IT_COUNT3 > 1(31) THEN
      IT_COUNT3=IT_COUNT3-1(31);
      PUT Z_LZ,NOW,IT_REST,'%' TO A12 BY F(7),T(14,3),F(6,1),A,SKIP;
      PUT Z_LZ,NOW,IT_REST,'%' TO LCD BY SKIP,F(7),T(14,3),F(6,1),A;
    FIN;

    Z_TASKCONTR=150;

    Z_MODBUS=Z_MODBUS-1;
    CALL FIXGRENZ(999,0,Z_MODBUS);  
    Z_FLAMCO=Z_FLAMCO-1;
    CALL FIXGRENZ(999,0,Z_FLAMCO);  
    Z_MBUS=Z_MBUS-1;
    CALL FIXGRENZ(999,0,Z_MBUS);  
    Z_GFCONTR=Z_GFCONTR-1;
    CALL FIXGRENZ(60,0,Z_GFCONTR);  
!   Z_GFCONTR2=Z_GFCONTR2-1;
!   CALL FIXGRENZ(60,0,Z_GFCONTR2);  
    Z_CAN1CONTR=Z_CAN1CONTR-1;
    CALL FIXGRENZ(60,0,Z_CAN1CONTR);  
    Z_HKABS=Z_HKABS-1;
    CALL FIXGRENZ(200,0,Z_HKABS);  
    Z_RAUMABS=Z_RAUMABS-1;
    CALL FIXGRENZ(200,0,Z_RAUMABS);  

!   IF Z_MODBUS < 1 THEN
!     TEXT='PREVENT MODBUS';     /* Task beenden */
!     B1=CMD_EXW(TEXT);
!     TEXT='TERMINATE MODBUS';     /* Task beenden */
!     B1=CMD_EXW(TEXT);
!     Z_MODBUSNEUST=Z_MODBUSNEUST+1;
!     Z_MODBUS=915;
!     AFTER 1 SEC RESUME;
!     TEXT='ACTIVATE MODBUS';     /* Task neu starten */
!     B1=CMD_EXW(TEXT);
!   FIN;    
!   IF Z_FLAMCO < 1 THEN
!     TEXT='TERMINATE FLAMCO';     /* Task beenden */
!     B1=CMD_EXW(TEXT);
!     TEXT='TERMINATE RS485READ';     /* Task beenden */
!     B1=CMD_EXW(TEXT);
!     AFTER 1 SEC RESUME;
!     TEXT='ACTIVATE FLAMCO';     /* Task neu starten */
!     B1=CMD_EXW(TEXT);
!     Z_FLAMCONEUST=Z_FLAMCONEUST+1;
!     Z_FLAMCO=900;
!     B_FLAMCONEUST='1'B;
!   FIN;    
    IF Z_MBUS < 1 THEN
      TEXT='PREVENT MBUSCOMM';     /* Task beenden */
      B1=CMD_EXW(TEXT);
      TEXT='PREVENT MBUSAUSWERT';     /* Task beenden */
      B1=CMD_EXW(TEXT);
      TEXT='TERMINATE MBUSCOMM';     /* Task beenden */
      B1=CMD_EXW(TEXT);
      TEXT='TERMINATE MBUSAUSWERT';     /* Task beenden */
      B1=CMD_EXW(TEXT);
      AFTER 1 SEC RESUME;
      TEXT='ACTIVATE MBUSCOMM';     /* Task neu starten */
      B1=CMD_EXW(TEXT);
      Z_MBUSNEUST=Z_MBUSNEUST+1;
      Z_MBUS=900;
    FIN;    
!   IF Z_GFCONTR < 1 THEN
!     TEXT='TERMINATE GRUNDFOS';     /* Task beenden */
!     B1=CMD_EXW(TEXT);
!     AFTER 1 SEC RESUME;
!     TEXT='ACTIVATE GRUNDFOS';     /* Task neu starten */
!     B1=CMD_EXW(TEXT);
!     Z_GFNEUST=Z_GFNEUST+1;
!     Z_GFCONTR=60;
!   FIN;    
!   IF Z_GFCONTR2 < 1 THEN
!     TEXT='TERMINATE GRUNDFOS2';     /* Task beenden */
!     B1=CMD_EXW(TEXT);
!     AFTER 1 SEC RESUME;
!     TEXT='ACTIVATE GRUNDFOS2';     /* Task neu starten */
!     B1=CMD_EXW(TEXT);
!     Z_GFNEUST2=Z_GFNEUST2+1;
!     Z_GFCONTR2=60;
!   FIN;    
    IF Z_CAN1CONTR < 1 THEN
      TEXT='PREVENT CAN1EMPF';       /* Task beenden */
      B1=CMD_EXW(TEXT);
      TEXT='TERMINATE CAN1EMPF';     /* Task beenden */
      B1=CMD_EXW(TEXT);
      AFTER 1 SEC RESUME;
      TEXT='ACTIVATE CANINIT';       /* CAN initialisieren */
      B1=CMD_EXW(TEXT);
      AFTER 1 SEC RESUME;
      TEXT='ACTIVATE CAN1EMPF';      /* Task neu starten */
      B1=CMD_EXW(TEXT);
      Z_CAN1NEUST=Z_CAN1NEUST+1;
      Z_CAN1CONTR=60;
    FIN;    

    STAT=TASKST('DISPLAY');
 !  PUT STAT TO TERM BY B(32),SKIP;
    IF STAT.BIT(21) OR STAT.BIT(23) THEN   /* 21: CWS?  23: SEMA */
      Z_DISPERR=Z_DISPERR+1;
 !    PUT 'D',Z_DISPERR TO TERM BY A,F(4),SKIP;
    ELSE
      Z_DISPERR=0;
    FIN;
    IF Z_DISPERR > 1200 THEN
      IF STAT.BIT(21) THEN   /* 21: CWS?  */
        CALL STOERMELD(80,'Reset wg DISP CW');
      ELSE
        CALL STOERMELD(80,'Reset wg DISP SE');
      FIN;
      CALL PLANRESET;
    FIN;      

    STAT=TASKST('MENU');
 !  PUT STAT TO TERM BY B(32),SKIP;
    IF STAT.BIT(21) OR STAT.BIT(23) THEN   /* 21: CWS?  23: SEMA */
      Z_MENUERR=Z_MENUERR+1;
    ELSE
      Z_MENUERR=0;
    FIN;
    IF Z_MENUERR > 90 THEN
      CALL STOERMELD(80,'Reset wg MENU');
      CALL PLANRESET;
    FIN;      

    IF Z_HKABS < 1 THEN
      CALL STOERMELD(80,'Reset wg HKABS');
      CALL PLANRESET;
    FIN;      

    IF Z_RAUMABS < 1 THEN
      CALL STOERMELD(80,'Reset wg RAUMABS');
      CALL PLANRESET;
    FIN;      

    AFTER 1 SEC RESUME;
  END;
END;



/*********************************************************************/
/* Initialisierung des Parameter-RAM. I_PARA wird bei neuen RAM's    */
/* einmal gestartet. Aufruf auch ueber Menue (Systembereich)           */
/*********************************************************************/
I_PARA: PROC;
  /* Werte vorbesetzen:                                              */
  B_ROTSP='0'B;
  BI_PARA='ECAD1101'B4;  /* Magic Word schreiben                     */
  Z_BETRIEB=1;        /* Betriebsart der Anlage                      */
  ZF_TMESS = 30;      /* Steigungsmessintervall                      */
  TD_BO = 1.5;        /*                                             */
  TD_BU = 2.0;        /*                                             */
  TD_KS = 4.0;        /*                                             */
  TC_MAXMIN = 80.0;   /*                                             */
  PE_RMIN1B = 2.0;    /*                                             */
  ZF_TAUS= 15;        /* T AUS in MIN                                */
  ZF_T1EIN= 30;       /* Z„hlergrenze TC_VIST<TC_VSOLL (in MIN)      */
  TD_1EIN= 5.0;       /* erlaubte Abweichung BHKW1                   */
  ZF_STARTMAX=12;     /* Warn. bei Starts > (in 24h)   */
  Z_KALSEC=0;
  Z_RESET=0(31);
  ZP_PUMPSCH=00:00:00;
  ZP_SCHANF=05:00:00;
  ZP_SCHEND=23:00:00;
  PT_SCHNITT=35.0*N_BHKW+500.0;
  TC_BRMIN=52.0;
  TD_BHZGSOLL=20.0;
  TD_UEBERHEIZ=0.0;     /* šberheizung Hauptkreis    */
  /*  <<< anlagenspezifische Variablen                               */
  FL_GASSTOER=2.5;
  FL_GASWARN=2.0;
  FL_DRWARN=1.50;
  Z_SYSOUT=1;
  FOR I TO 12 REPEAT
    PE_STRMAX(I)=30.0;
  END;

  FOR I TO 150 REPEAT
    FL_IMP(I)=100.0;
    Z_ZAEHL(I)=0(31);
  END;

  FL_GASHU=8.9;
  FL_GASHO=10.0;
  TC_BHZGVO(1)=89.0;  /* BHKW Vorlaufthermostat  */
  TC_BHZGRO(1)=69.5;  /* BHKW Rcklaufthermostat */

  FOR I TO 200 REPEAT
    ZF_STOERFREI(I)=1; /* 1: FREI  2: KEINE MELDUNG  3: KEINE STOERUNG */
    ZF_STOERDRIG(I)=0;    
  END;
  ZF_STOERFREI(61)=2;
  FOR I TO 160 REPEAT
    Z_DOHAND(I)=0;
  END;
  FOR I TO 150 REPEAT    
    Z_DIBEWERT(I)=1;
  END;
  B_FSLKESAUTO='1'B;
  B_FSLBHKWAUTO='1'B;


  FOR I TO 150 REPEAT        /* Fuehlerparameter vorbesetzen           */
   IF FP_HARD(I) < 151 AND FP_HARD(I) > 0 THEN
    CASE FP_TYP(I)
      ALT /* KTY                      1                              */
        FP_ULOW(FP_HARD(I))=975;   /* Fuehlersp. in mV bei   0 Grad   */
        FP_UHIGH(FP_HARD(I))=4070; /* Fuehlersp. in mV bei 100 Grad   */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=100.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* Kelvin pro Bit                    */
      ALT /* Leistung                 2                              */
        FP_ULOW(FP_HARD(I))=   0;  /* Fuehlersp. in mV bei  0 kW      */
        FP_UHIGH(FP_HARD(I))= 200; /* Fuehlersp. in mV bei 10 kW      */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=10.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* KW pro Bit                        */
      ALT /* PT 1000  neu             3                              */
        FP_ULOW(FP_HARD(I))=1200;  /* Fuehlersp. in mV bei   0 Grad   */
        /* Kennlinie:  T=(U(mV)-1200)/(28.1176-0.000638333*U(mV))       */
      ALT /* %                        4                              */
        FP_ULOW(FP_HARD(I))=000;    /* Fuehlersp. in mV bei    0 %     */
        FP_UHIGH(FP_HARD(I))=5000; /* Fuehlersp. in mV bei  100 %     */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=100.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* %    pro Bit                      */
      ALT /* Druckaufnehmer  0-4  bar  5                             */
        FP_ULOW(FP_HARD(I))=1000;  /* Fuehlersp. in mV bei  0 bar     */
        FP_UHIGH(FP_HARD(I))=5000; /* Fuehlersp. in mV bei  4 bar     */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=4.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* bar pro Bit                       */
      ALT /* Druckaufnehmer  0-6  bar  6                             */
        FP_ULOW(FP_HARD(I))=1000;  /* Fuehlersp. in mV bei  0 bar     */
        FP_UHIGH(FP_HARD(I))=5000; /* Fuehlersp. in mV bei  4 bar     */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=6.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* bar pro Bit                       */
      ALT /* Gassensor  (0 - 5V)      7                              */
        FP_ULOW(FP_HARD(I))=2500;  /* Fuehlersp. in mV bei  0V        */
        FP_UHIGH(FP_HARD(I))=3567; /* Fuehlersp. in mV bei  1V        */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=1.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* V   pro Bit                       */
      ALT /* Thermoelement Typ K     8  (-82 bis 830 Grad)           */
        FP_ULOW(FP_HARD(I))=450;   /* Fšhlersp. in mV bei   0 Grad   */
        FP_UHIGH(FP_HARD(I))=1000; /* Fšhlersp. in mV bei 100 Grad   */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=100.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* Kelvin pro Bit                    */
      ALT /* Spannungsmessung 0-30V  9                               */
        FP_ULOW(FP_HARD(I))=0;     /* Fšhlersp. in mV bei    0 V     */
        FP_UHIGH(FP_HARD(I))=5000; /* Fšhlersp. in mV bei   30 V     */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=30.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* mV pro Bit                        */
      ALT /* Leistung PBedarf Seidel 10   (auch negative Leistung moeglich) */
        FP_ULOW(FP_HARD(I))=2500;  /* Fuehlersp. in mV bei  0 kW      */
        FP_UHIGH(FP_HARD(I))=3000; /* Fuehlersp. in mV bei 10 kW      */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=10.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* KW pro Bit                        */
      ALT /* Sollwertpoti 15 - 30Grad 11                             */
        FP_ULOW(FP_HARD(I))=-5000; /* Fuehlersp. in mV bei   0 Grad   */
        FP_UHIGH(FP_HARD(I))=5000; /* Fuehlersp. in mV bei  30 Grad   */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=30/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* Kelvin pro Bit                    */
      ALT /* PT 500 an PT1000 Eing    12                             */
        FP_ULOW(FP_HARD(I))=1200;  /* Fuehlersp. in mV bei   0 Grad   */
        /* Kennlinie:  T=2*(U(mV)-1200)/(28.1176-0.000638333*U(mV))     */

      ALT /* Temp. als 4-20mA         13                             */
        FP_ULOW(FP_HARD(I))=  800; /* Fuehlersp. in mV bei   0 Grad   */
        FP_UHIGH(FP_HARD(I))=4000; /* Fuehlersp. in mV bei 100 Grad   */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=100.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* Kelvin pro Bit                    */
      ALT /* DF    als 4-20mA         14                             */
        FP_ULOW(FP_HARD(I))=  800; /* Fuehlersp. in mV bei   0 m^3/h  */
        FP_UHIGH(FP_HARD(I))=4000; /* Fuehlersp. in mV bei 100 m^3/h  */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=100.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* Kelvin pro Bit                    */
      ALT /* PT 1000 Eingang alt      15                             */
        FP_ULOW(FP_HARD(I))=1136;  /* Fuehlersp. in mV bei   0 Grad   */
        /* Kennlinie:  T=(U(mV)-1136)/(32,7219-0,638333*U(mV))       */
      ALT /* Druckaufnehmer     0-10.0mWS 16                         */
        FP_ULOW(FP_HARD(I))= 1000; /* Fuehlersp. in mV bei  0 mWS     */
        FP_UHIGH(FP_HARD(I))=5000; /* Fuehlersp. in mV bei 10.0mWS    */
        FP_NULL(FP_HARD(I))=ENTIER(1023*(FP_ULOW(FP_HARD(I))/5000));
                                /* Nullpunkt in Bit des AD-Wandlers  */
        FP_STEIG(FP_HARD(I))=10.0/((1023*(FP_UHIGH(FP_HARD(I))/5000))
                             -FP_NULL(FP_HARD(I)));
                                /* mWS pro Bit                       */
      ALT /* PT 1000  Platine IF555-5 17                             */
        FP_ULOW(FP_HARD(I))=1280;  /* Fuehlersp. in mV bei   0 Grad   */
        /* Kennlinie:  T=(U(mV)-1200)/(28.1176-0.000638333*U(mV))       */
      OUT 
    FIN;
   FIN;
  END;

  FOR I TO 32 REPEAT         /* Heizkreisparameter vorbesetzen           */
    TD_ABSHK(I)=6.0;         /* Anhebung der Aussentemperatur bei Absenkung */
    RP_M(I)=1.0;             /* P-Anteil HK-Mischerregelung                    */
    RI_M(I)=0.05;            /* I-Anteil        "                              */
    RDI_M(I)=0.0;            /* DI-Anteil       "                              */
    RD_M(I)=20.0;            /* D-Anteil        "                              */
    RTAU_M(I)=15.0;          /* TauD            "                              */     
    ZUST_HK(I)=1;            /* Heizkreis mit Automatikbetrieb                 */
    P_HKMIN(I)=10.0;         /* Pumpenmindestdruck    <<<   */
    TC_HMT(I)=22.0;          /* Tagheizgrenzen der Heizkreise          */
    TC_HMN(I)=12.0;          /* Nachtheizgrenzen der Heizkreise        */
    FL_EXPHK(I)=1.3;         /* Heizk”rperexponent            */
    TD_HKSPREI(I)=20.0;      /* Heizkreisistspreizung         */
    TC_HKVMIN(I)=25.0;       /* Heizkreismindestvorlauftemp.  */
    TC_HKINENN(I)=25.0;      /* Heizkreisnennraumtemperatur   */
    TC_HKVNENN(I)=80.0;      /* Heizkreisnennvorlauftemp.     */
    TC_HKANENN(I)=-12.0;     /* Heizkr.Ausslegungsaussentemp. */
    W_HKTH(I)=0.0(55);       /* Waermemengenzaehler = 0              */
    TC_HKSTW(I)=180.0;       /* Grenzwert Sicherheitstemp-Waechter   */
    ZF_HKMISTELL(I)=120;     /* Mischerstellzeit (s)                 */
    FL_SOLLATM10(I)= 50.0;   /* Soll HK-Pumpe bei -10 Grad    */
    FL_SOLLAT5(I)=40.0;      /* Soll HK-Pumpe bei   5 Grad    */
    FL_SOLLAT20(I)=30.0;     /* Soll HK-Pumpe bei  20 Grad    */
    TC_TAGSOLL(I)=19.0;      /* Raumsolltemp. Tag             */
    TC_BEREITSOLL(I)=17.0;   /* Raumsolltemp. Tag             */
    TC_NACHTSOLL(I)=12.0;    /* Raumsolltemp. Nacht           */
    TD_HKINTMAX(I)=5.0;      /* langfrist. Integr. MAX        */
    TD_HKINTMIN(I)=-2.0;     /* langfrist. Integr. MIN        */
    F_ESTRICH(I,1)=15.0;  /* ESTRICHTROCKNUNG */
    F_ESTRICH(I,2)=20.0;
    F_ESTRICH(I,3)=25.0;
    F_ESTRICH(I,4)=30.0;
    F_ESTRICH(I,5)=35.0;
    F_ESTRICH(I,6)=35.0;
    F_ESTRICH(I,7)=30.0;
    F_ESTRICH(I,8)=25.0;
    F_ESTRICH(I,9)=20.0;
    F_ESTRICH(I,10)=15.0;
    F_ESTRICH(I,11)=0.0;
    F_ESTRICH(I,12)=0.0;
    F_ESTRICH(I,13)=0.0;
    F_ESTRICH(I,14)=0.0;
    F_ESTRICH(I,15)=0.0;
    F_ESTRICH(I,16)=0.0;
    F_ESTRICH(I,17)=0.0;
    F_ESTRICH(I,18)=0.0;
    F_ESTRICH(I,19)=0.0;
    F_ESTRICH(I,20)=0.0;
    F_ESTRICH(I,21)=0.0;  /* RESTLAUFZ (MIN) 1440=1TAG 14400=10TAGE */
    ZF_HKPEXT(I)=0;
    ZF_HKMIEXT(I)=0;
    FL_HKEXT(I)=0.0;
  END;

  /* Initialisierung der UPE-Pumpen */
  FOR I TO 32 REPEAT
    B_UPEHAND(I)='0'B;      /* 1: UPE-Pumpe im Handbetr.   */
    Z_UPEKOMMAND(I)=1;      /* Kommando UPE-Pumpe        */
    Z_UPESOLLHAND(I)=45;    /* Handsollstufe UPE-Pumpe     */
    UPE_PRESSSCALE(I)=0.023529; /* Skalierungsfaktor Pumpendruck (UPE 25-60)       */
    UPE_FLOWSCALE(I)=0.019608;  /* Skalierungsfaktor Pumpendurchfl. (UPE 25-60)    */
    UPE_TEMPSCALE(I)=0.996078;  /* Skalierungsfaktor Wassertemp. (UPE 25-60)       */
    UPE_FRQSCALE(I)=0.082353;   /* Skalierungsfaktor PMP-Motorfrequenz (UPE 25-60) */
    UPE_PDCSCALE(I)=0.003922;   /* Skalierungsfaktor PMP-Pel (UPE 25-60)           */
    UPE_FREIG(I)=1;             /* Kommunikation freigegeben */
    UPE_KENN(I,1)=1;            /* upe Sollstufe bei   0,4%  */
    UPE_KENN(I,2)=2;            /* upe Sollstufe bei   0,8%  */
    UPE_KENN(I,3)=254;          /* upe Sollstufe bei  99,6%  */
    UPE_KENN(I,4)=255;          /* upe Sollstufe bei 100,0%  */
  END;  


  FOR I TO 8 REPEAT     /* BHKW-Parameter vorbesetzen               */
    ZF_BPNL(I)=240;     /* Pumpennachlaufzeit BHKW  (s)            */
    FS_LBHKW(I)=I;      /* Rang von BHKW I                               */
    Z_START(I)=0(31);   /* Startz„hler          BHKW                     */
    XA_BPMP(I)=100.0;   /* Analogausgang BHKW-Pumpenleistung           */
    PE_MAXBHKW(I)= 50.0; /* Maximalleistung des BHKW                  */
    PE_MINBHKW(I)= 20.0; /* Minimalleistung des BHKW                  */
    PE_BMINPRO(I)= 60.0; /* Pel Min erlaubt in % (wg eta)     */
    TC_BVLMIN(I)=76.0;  /* BHKW MindestVL Temp     */
    TC_BHZGVO(I)=89.0;  /* BHKW Vorlaufthermostat  */
    TC_BHZGRO(I)=69.5;  /* BHKW Ruecklaufthermostat */
    B_BERLAUBT(I)='1'B; /* BHKW freigegeben                          */
    FL_BLFZGESHZG(I)=0.0(55);
    FL_BKWHGESHZG(I)=0.0(55);
    FL_BLFZWARTINT(I)=1000.0; 
    FL_BLFZWART(I)=FL_BLFZWARTINT(I); 
    FOR K TO 13 REPEAT
      STR_AUS(I,K)='                ';
    END;
    ZF_BEINEXT(I)=0;
  END;

  B_FSLKESAUTO='1'B;
  FOR I TO 10 REPEAT        /* Kesselparameter vorbesetzen            */
    PT_KES(I)=200.0; /* Kesselleistung vorbesetzen                   */
    FS_LKES(I)=I;    /* Zeiger auf logischen Kessel                  */
    RP_K(I)=0.50;    /* P-Anteil der Leistungsregelung               */
    RI_K(I)=0.02;    /* I-Anteil der Leistungsregelung               */
    RD_K(I)=20.0;    /* D-Anteil der Leistungsregelung               */
    RDI_K(I)=0.0;    /* DI-Anteil der Leistungsregelung              */
    RTAU_K(I)=20.0;  /* Zeitkonst. der Leistungsregelung             */
    RP_KP(I)=1.00;   /* P-Anteil der Pumpenregelung                  */
    RI_KP(I)=0.06;   /* I-Anteil der Pumpenregelung                  */
    RD_KP(I)=20.0;   /* D-Anteil der Pumpenregelung                  */
    RDI_KP(I)=0.0;   /* DI-Anteil der Pumpenregelung                 */
    RTAU_KP(I)=15.0; /* Zeitkonst. der Pumpenregelung                */
    FL_KWART(I)=20.0;/* Kesselst”rungserkennung in 20 Min            */
    TD_KMIN(I)=5.0;  /*          "              bei dT< 5K           */
    PT_KES(I)=200.0; /* Kesselleistung vorbesetzen                   */
    ZF_KPNL(I)=180;    /* Pumpennachlauf in s                        */
    ZF_KWARML(I)=180;  /* Kesselwarmlaufzeit in s                    */
    ZF_KSTELL(I)=30;   /* Brennerverstellzeit von MIN->MAX in s      */
    TC_KRMIN(I)=50.0;  /* Kesselmindest-RL-Temp bei Anhebemischer    */
    TC_KVMAX(I)=84.0;  /* Kessel-MAX-VL-TEMP fuer Regelung (+4K=AUS) */
    TD_KVLPLUS(I)=3.0; /* Kessel-VL-SOLL Ueberhoehung                */
    TD_KMAX(I)=24.0;   /* Kessel-MAX erl. Spreizung                  */
    X_AAKMIN(I)=20.0;  /* Mindest AA bei Kesselbetrieb               */
    Z_KESLFZ(I)=0(31); /* Laufzeit 0s                                */
    Z_KSTART(I)=0(31); /* Anzahl Neuanforderungen = 0                */
    B_KERLAUBT(I)='1'B; /* Kessel freigegeben                          */
    ZF_KEINEXT(I)=0;
    ZF_KPMPEXT(I)=0;
  END;
 

  FOR I TO 10 REPEAT      /* Speicherparameter vorbesetzen            */
    TC_LEGIO(I)=65.0;
    TC_BWSOLL(I)=60.0; /* Brauchwasserspeicher Solltemperatur        */
    TC_BWMIN (I)=55.0; /* Brauchwasserspeicher Mindesttemp.          */
    TC_BWZRSOLL(I)=54.0; /* Sollwert Zirkulationsruecklauf            */
    TC_BOMAX(I) =66.0; /* maximale obere Speichertemperatur          */
    TD_BWNORM(I)= 3.0; /* Brauchwasserlad. normal Grenze             */
    TD_BWDRIG(I)= 5.5; /* Brauchwasserlad. dringend Grenze           */
    TD_BWB(I)   = 1.0; /* Ueberladungssoll fuer Abforderung          */
    TD_BWTW(I)  = 1.5; /* Pumpensteuerung aussenliegende WT          */
    TD_BWTOO(I) = 4.0; /* Start WW-Lad wenn VL > Sp o + TD_BWTOO     */
    TD_BWTOU(I) = 2.0; /* Stop WW-Lad wenn  VL < Sp o + TD_BWTOU     */
    TD_BWLS(I)  = 6.0; /* Haupt VL-Sollanf. = BWSOLL+TD_BWLS         */
    RP_BWL(I)   = 1.5; /* Lade/Speise-PMP-Regelung  P                */
    RI_BWL(I)   = 0.3; /*                           I                */
    RD_BWL(I)   = 8.0; /*                           D                */
    TC_BWRSOLL(I)=40.0;/* Lade RL Soll                               */
    RP_WWZ(I)   = 2.0; /* Zirk-Pumpenregelung       P                */
    RI_WWZ(I)   = 0.01; /*                          I                */
    RD_WWZ(I)   = 5.0; /*                           D                */
    RDI_WWZ(I)  = 0.0; /*                          DI                */
    RTAU_WWZ(I) =20.0; /*                       TAU D                */
    RP_WWL(I)   = 0.55; /* Lade-Pumpenregelung      P                */
    RI_WWL(I)   = 0.03; /*  (ev. auch mit Mischer)  I                */
    RD_WWL(I)   =18.5; /*                           D                */
    RDI_WWL(I)  = 0.0; /*                          DI                */
    RTAU_WWL(I) = 2.8; /*                       TAU D                */
    ZF_LMISTELL(I)= 60;/* Lademischerstellzeit (s)                   */
    ZF_WWMI(I)  =3;    /* 1: nur Pumpe  2: PMP+Mi  3: PMP+Mi 2s  4: nur Mi  5: nur Mi 2s */
  END;


  FOR I TO 20 REPEAT       /* Alle Ausgangskarten vorbesetzen        */
    BI_OFF(I)='FFFF'B4; /* Handschalter auf Automatik                */
    BI_ON(I)='0000'B4;  /* Handschalter auf Automatik                */
  END;

  FOR I TO 60 REPEAT       /* Alle Analogausgaenge vorbesetzen        */
    CASE AP_TYP(I)
      ALT /* 1 Heizkreispumpen                                       */
        AP_ULOW(I)= 0.0;  /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
      ALT /* 2 Solleistungsausgang BHKW                              */
        AP_ULOW(I)=0.0;   /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
      ALT /* 3 Kesselpumpen                                          */
        AP_ULOW(I)=0.0;   /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
      ALT /* 4 WW-Ladepumpen                                         */
        AP_ULOW(I)=0.0;   /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
      ALT /* 5 WW-Speisepumpen                                       */
        AP_ULOW(I)=0.0;   /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
      ALT /* 6 WW-Zirkulationspumpen                                 */
        AP_ULOW(I)=0.0;   /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
      ALT /* 7 BHKW Pumpen                                           */
        AP_ULOW(I)=0.0;   /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
      ALT /* 8 Kesselleistung                                        */
        AP_ULOW(I)=0.0;   /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
      ALT /* 9 sonstiges 0-20 mA                                     */
        AP_ULOW(I)=0.0;   /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
      OUT /*                                                    >10  */
        AP_ULOW(I)=0.0;   /* Analogausgangssp. bei 0% Sollausgang    */
        AP_UHIGH(I)=10.0; /* Analogausgangssp. bei 100% Sollausgang  */
    FIN;
    X_AHAND(I)=50.0;   /* Ausgang in % bei Handbetrieb               */
    X_AAUSMIN(I)= 0.0;  /* Mindestwert Analogausgang                */
    X_AAUSMAX(I)=100.0; /* Maximalwert Analogausgang                */
    Z_AAUTO(I)=1;       /* Ausgang auf Automatik                     */
  END;
  
  FOR I TO 20 REPEAT     /* Alle PWMausgaenge vorbesetzen        */
    X_PWMHAND(I)=50.0;   /* Ausgang in % bei Handbetrieb         */
    X_PWMMIN(I)=25.0;    /* Mindestwert PWM-Ausgang              */
    X_PWMMAX(I)=100.0;   /* Maximalwert PWM-Ausgang              */
    Z_PWMAUTO(I)=1;      /* Ausgang auf Automatik                */
  END;
  
  /*-----------------------------------------------------------------*/
  FOR I TO 46 REPEAT        /* Alle m”glichen Einzelr„ume (46)       */
    FOR K TO 1008 REPEAT
      B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='0'B;
      IF K < 720 THEN /* wochentags */
        /* jeden Tag von 5:00 bis 24:00 anheben    */                     
        IF K REM 144 > 30 AND K REM 144 <= 144                           
           OR K REM 144 <= 0 THEN                                         
          B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='1'B;
        FIN;
      ELSE
        IF K < 876 THEN /* bis Sonntag 02:00 */
          /* von 6:00 bis  1:30 anheben  */                  
          IF    K REM 144 > 36 AND K REM 144 <= 144                      
             OR K REM 144 <= 9 THEN                                     
            B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='1'B;
          FIN;
        ELSE  /* Rest vom Sonntag */
          /* von 7:00 bis  24:00 anheben                   */
          IF    K REM 144 > 36 AND K REM 144 <= 144 THEN
            B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='1'B;           
          FIN;
        FIN;
      FIN;
    END;
  END;

  FOR I FROM 33 TO 42 REPEAT        /* WW-Timer                      */
    FOR K TO 1008 REPEAT
      B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='0'B;
      /* jeden Tag ab  3:40  Tagbetrieb                              */
      IF K REM 144 > 22 THEN
        B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='1'B;
      FIN;
    END;
  END;

  FOR I FROM 43 TO 52 REPEAT        /* Timer Legionellen             */
    FOR K TO 1008 REPEAT
      IF K== 780 OR K==781 THEN  /* Samstagmorgen */
        B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='1'B;
      ELSE
        B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='0'B;
      FIN;      
    END;
  END;

  FOR I FROM 55 TO 56 REPEAT        /* Die beiden Tarifkalender      */
    FOR K TO 1008 REPEAT
      B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='0'B;
      /* jeden Tag von 6:00 bis 22:00    HT                          */
      IF K REM 144 > 36 AND K REM 144 < 133 THEN
        B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='1'B;
      FIN;
    END;
  END;
  FOR I FROM 60 TO 60 REPEAT        /* Timer BHKW Freigabe           */
    FOR K TO 1008 REPEAT
      B_ZONE1((I-1)//16+1,K).BIT((I-1) REM 16 + 1)='1'B;
    END;
  END;


  FOR I TO 12 REPEAT
    FOR J TO 31 REPEAT
      FOR K TO 32 REPEAT
        B_JAHRAB(I,J).BIT(K)='0'B;  /* Jahreskalender fuer 32 Heizkreise */
      END;
    END;
  END;

  FOR I TO 25 REPEAT                
    TX_STOER(I)='                '; 
    ZT_STOER(I)=0(31);                  
    ART_STOER(I)=0;                  
  END;                              

  FOR I TO 20 REPEAT
    FOR K TO 13 REPEAT
      Z_BLAUFZ(I,K)=0(31);
      ZP_BAUS(I,K)=00:00:00;
      DAT_BAUS(I,K)=0;
    END;
  END;
  FOR I TO 10 REPEAT
    FOR K TO 13 REPEAT
      Z_KLAUFZ(I,K)=0(31);
      ZP_KAUS(I,K)=00:00:00;
      DAT_KAUS(I,K)=0;
    END;
  END;

  W_ERZHT=0.0(55);
  W_BEDHT=0.0(55);
  W_EINHT=0.0(55);
  W_BEZHT=0.0(55);
  W_ERZNT=0.0(55);
  W_BEDNT=0.0(55);
  W_EINNT=0.0(55);
  W_BEZNT=0.0(55);

  FOR I TO 10 REPEAT
    NAMESTR(I)='                                 ';
    DA_DATCALL(I)=0;
    DA_MONCALL(I)=0;
    ZP_CALL(I)=00:00:00; 
  END;  

  PUT 'mkdir /h0/MIN1WERT' TO RTOS;
  ACTIVATE RAMSCHREIB; /* vorgegebene Werte auf h0. uebertragen       */
  AFTER 2.0 SEC RESUME;

END; /* of PROC I_PARA */

/*********************************************************************/
/* Prozedur I_F zum initialisieren der Fuehlerparameter               */
/*********************************************************************/
I_F: PROC (NAME CHAR(20),
           (HARD, TYP) FIXED,
           MITTEL           FLOAT,
           (ID, NUM, SEITE, ZEILE) FIXED,
           (MINUEB,MAXUEB) FLOAT,
           FUEB  FIXED) GLOBAL;

! PUT N_FUEHLER TO A12 BY F(5),SKIP;

  N_FUEHLER=N_FUEHLER+1;
  /* Name des Analogeingangs (bis 15 Buchstaben):                    */
  FP_NAME(N_FUEHLER)=NAME;
  /* Hardwarekanal des Analogeingangs                                */
  FP_HARD(N_FUEHLER)=HARD;
  /* Fuehlertyp (1: KTY, 2: Pelektr., 3: Centra, 4: Digital, 5:Druck, */
  /*            6: Drehzahl) des Analogeingangs                      */
  FP_TYP(N_FUEHLER) =TYP;
  /* Mittelwertbildung (gleitend mit Tau=MITTEL Sec) des Hardw.-Kan. */
  FP_MIT(HARD) =MITTEL;
  
  IF FL_XAEINMAX(201) < 667.0 OR FL_XAEINMAX(201) > 669.0 THEN
    IF FUEB==1 THEN
      B_FUEHLWACH(N_FUEHLER)='1'B;
    ELSE
      B_FUEHLWACH(N_FUEHLER)='0'B;
    FIN;
    FL_XAEINMIN(N_FUEHLER)=MINUEB;
    FL_XAEINMAX(N_FUEHLER)=MAXUEB;
  FIN;

  /* Zeiger fuer logische Ger„tenummern:                              */
  CASE ID
    ALT /* 1. BHKW-Istleistung          */ ZE_PB   (NUM)=HARD;
    ALT /* 2. Heizkreisvorlauf          */ ZE_HK   (NUM)=HARD;
                                           FP_HZKR(N_FUEHLER) =NUM;
    ALT /* 3. Kesselvorlauftemperatur   */ ZE_KV   (NUM)=HARD;
    ALT /* 4. Brauchwasser oben         */ ZE_BWO  (NUM)=HARD;
    ALT /* 5.                           */ 
    ALT /* 6. Brauchwasser Speise VL    */ ZE_BWIST(NUM)=HARD;
    ALT /* 7. Kesselruecklauftemperatur */ ZE_KR   (NUM)=HARD;
    ALT /* 8. BHKW Vorlauftemperatur    */ ZE_BV   (NUM)=HARD;
    ALT /* 9. BHKW Ruecklauftemperatur  */ ZE_BR   (NUM)=HARD;
    ALT /* 10. Aussentemperatur         */ ZE_AUSSEN  =HARD;
    ALT /* 11.                          */                    
    ALT /* 12. Hauptvorlauftemp         */ ZE_VORLAUF =HARD;
    ALT /* 13. Strombedarf              */ ZE_PEBED   =HARD;
    ALT /* 14. BW-Ruecklauftemp.        */ ZE_BWRUECK(NUM)=HARD;
    ALT /* 15. Hauptruecklauftemp.      */ ZE_RUECK   =HARD;
    ALT /* 16. šberstr”mung             */ ZE_UEBER   =HARD;
    ALT /* 17. BW-Vorlauftemp.          */ ZE_BWVOR(NUM)=HARD;
    ALT /* 18.                          */                     
    ALT /* 19.                          */ 
    ALT /* 20.                          */ 
    ALT /* 21.                          */ 
    ALT /* 22.                          */
    ALT /* 23. Heizkreisruecklauf       */ ZE_HKR(NUM)=HARD;
    ALT /* 24.                          */                     
    ALT /* 25.                          */ 
    ALT /* 26.                          */ 
    ALT /* 27.                          */ 
    ALT /* 28.                          */ 
    ALT /* 29.                          */ 
    ALT /* 30. Zirkulations RL          */ ZE_ZIRK(NUM)=HARD;
    ALT /* 31.                          */                    
    ALT /* 32.                          */                   
    ALT /* 33.                          */ 
    OUT /* nicht definiert              */
  FIN;
  /* Falls der Fuehler auf einer Seite dargestellt werden soll:       */
  IF SEITE>0  THEN  FP_POS(SEITE,ZEILE)=N_FUEHLER; FIN;
 
END; /* of PROC I_F */

A_F:PROC (NAME CHAR(20),(HARD,ID,NUM) FIXED) GLOBAL;

  IF ID == 20 THEN  /* PWM-Ausgang */
    N_PWM=N_PWM+1;
    PW_NAME(N_PWM)=NAME;
  ELSE
    N_ANALOG=N_ANALOG+1;
    AP_HARD(N_ANALOG)=HARD;
    AP_NAME(N_ANALOG)=NAME;
    AP_TYP(N_ANALOG)=ID;

    CASE ID
      ALT /* 1. Heizkreispumpenleistung       */  ZA_PHK    (NUM)=N_ANALOG;
      ALT /* 2. BHKW-Leistung                 */  ZA_PEBHKW (NUM)=N_ANALOG;
      ALT /* 3. Kesselpumpenleistung          */  ZA_KESPMP (NUM)=N_ANALOG;
      ALT /* 4. Brauchwasserladepumpenleist.  */  ZA_BWLPMP (NUM)=N_ANALOG;
      ALT /* 5. Brauchwasserspeisepumpenleist.*/  ZA_BWSPMP (NUM)=N_ANALOG;
      ALT /* 6. Brauchwasserzirkpmpleistung   */  ZA_BWZPMP (NUM)=N_ANALOG;
      ALT /* 7. BHKW Pumpenleistung           */  ZA_BHKWPMP(NUM)=N_ANALOG;
      ALT /* 8. Ansteuerung Kesselleistung    */  ZA_KANST  (NUM)=N_ANALOG;
      ALT /* 9. sonstiges 0-20mA              */
      ALT /*10. irgendeine Pumpe              */
      OUT
    FIN;
  FIN;

END; /* of PROC A_F */


I_UPE: PROC (NAME CHAR(20),(ID,NUM) FIXED) GLOBAL;

  N_UPE=N_UPE+1;
  UPE_NAME(N_UPE)=NAME;
  UPE_TYP(N_UPE)=ID;

END;


/*********************************************************************/
/* Prozedur I_DO zum initialisieren der Digitalausg{nge              */
/*********************************************************************/
I_DO:PROC (NAME CHAR(22),(HARD,TON,TOFF) FIXED) GLOBAL;

  N_DIGOUT=N_DIGOUT+1;
  DO_HARD(N_DIGOUT)=HARD;
  DO_NAME(HARD)=NAME;
  DO_TON(HARD)=TON;
  DO_TOFF(HARD)=TOFF;
  IF TON < 1000 AND Z_DOHAND(HARD) > 0 THEN
    Z_DOHAND(HARD)=0;    /* Z_DOHAND ist batteriegepuffert  */
  FIN;    
  IF TOFF > -1000 AND Z_DOHAND(HARD) < 0 THEN
    Z_DOHAND(HARD)=0;    /* Z_DOHAND ist batteriegepuffert  */
  FIN;    

END; /* of PROC I_DO */


/* Task zum löschen der aktuellen Monatsmeldedatei */
MONLOESCH: TASK PRIO 12;
  DCL TEXT    CHAR(80);
  DCL B1      BIT(1);
  DCL F15     FIXED;

  F15=DA_MON;
  IF DA_DAT==31 AND DA_MON==12 AND ZP_NOW>23:58:00 THEN /* Jahreswechsel  */ 
    F15=1;
  FIN;  
  
  IF B_FLASHVORH THEN
    CASE F15
      ALT /*  1 */
        TEXT='RM /H0/MONP01';     
      ALT /*  2 */
        TEXT='RM /H0/MONP02';     
      ALT /*  3 */
        TEXT='RM /H0/MONP03';     
      ALT /*  4 */
        TEXT='RM /H0/MONP04';     
      ALT /*  5 */
        TEXT='RM /H0/MONP05';     
      ALT /*  6 */
        TEXT='RM /H0/MONP06';     
      ALT /*  7 */
        TEXT='RM /H0/MONP07';     
      ALT /*  8 */
        TEXT='RM /H0/MONP08';     
      ALT /*  9 */
        TEXT='RM /H0/MONP09';     
      ALT /* 10 */
        TEXT='RM /H0/MONP10';     
      ALT /* 11 */
        TEXT='RM /H0/MONP11';     
      ALT /* 12 */
        TEXT='RM /H0/MONP12';     
      OUT
    FIN;

    /* Koordinierung der Zugriffe auf Compact Flash                 */
    /* mit Z_RAMSON anfordern und warten bis alle anderen fertig  */
    Z_RAMSON=50;
    AFTER 0.5 SEC RESUME;
    WHILE Z_RAMDUE2 > 0 OR Z_RAMSTAT > 0 OR Z_RAMPAR > 0 OR Z_RAMSTOER > 0 REPEAT
      IF Z_RAMDUE2  > 0 THEN  Z_RAMDUE2 = Z_RAMDUE2 -1;  FIN; 
      IF Z_RAMSTAT  > 0 THEN  Z_RAMSTAT = Z_RAMSTAT -1;  FIN; 
      IF Z_RAMPAR   > 0 THEN  Z_RAMPAR  = Z_RAMPAR  -1;  FIN; 
      IF Z_RAMSTOER > 0 THEN  Z_RAMSTOER= Z_RAMSTOER-1;  FIN;
      AFTER 0.5 SEC RESUME;
    END;

    B1=CMD_EXW(TEXT);                
    TEXT='sync h0.';     
    B1=CMD_EXW(TEXT);                
    Z_RAMSON=0;  /* FERTIG */

  FIN;
  
END;


/* Task zum Abschalten der Wärmeerzeuger */
AUS: TASK PRIO 13;
  DCL F15 FIXED;

  F15=0;
  WHILE F15 < 3000 REPEAT
    FOR I TO N_KESSEL REPEAT
      IF B_KEIN(I) THEN
        B_KEIN(I)='0'B;
        Z_KPNL(I)=20;         /* Pumpennachlauf setzen       */
      FIN;
    END;
    FOR I TO N_BHKW REPEAT
      IF B_BEIN(I) THEN
        B_BEIN(I)='0'B;
        Z_BPNL(I)=20;       /* Pumpennachlauf setzen       */
      FIN;
    END;
    F15=F15+1;
    AFTER 0.1 SEC RESUME;
  END;

END;


/*********************************************************************/
/* Der Systemgrundtakt, die zentrale Regelungstask, teilt sich in    */
/* mehrere Funktionsbl”cke, die durch Sternchenreihen getrennt sind: */
/*********************************************************************/
SYSTAKT: TASK PRIO 14;

  DCL B_LOOP  BIT(1);
  DCL B_LOOP2 BIT(1);
  DCL B_PMP   BIT(1);
  DCL X_A     FLOAT;
  DCL X_B     FLOAT;
  DCL X_C     FLOAT;
  DCL ABW     FLOAT;
  DCL ABW2    FLOAT;
  DCL F31     FIXED(31);
  DCL F_15    FIXED;
  DCL FIX1    FIXED;
  DCL FIX2    FIXED;
  DCL X_M     FIXED;
  DCL X_O     FIXED;
  DCL IND1    FIXED;
  DCL IND2    FIXED;
  DCL STAT    BIT(32);
  DCL CHAR8   CHAR(8);
  DCL F(10)   FIXED;
  DCL FL55    FLOAT(55);
  DCL FL1     FLOAT;
  DCL FL2     FLOAT;
  DCL FL3     FLOAT;
  DCL Z_DI    FIXED;
  DCL Y_P     FLOAT;
  DCL Y_I     FLOAT;
  DCL Y_D     FLOAT;
  DCL Y_DI    FLOAT;
  DCL TC_B    FLOAT;
  DCL ZP_H    CLOCK; 
  DCL ZD1       DUR;
  DCL ZP_1    CLOCK; 
  DCL ZP_2    CLOCK; 


  ZP_1=NOW;
  /*******************************************************************/
  /* Erfassung der Systemzust„nde:                                   */
  /*******************************************************************/
  CALL SYSTEMOUT(1);   /* Organisation der Systemmeldungen           */
  
  /*******************************************************************/
  /* Zeitdauermessung der Digitaleing„nge auf zu kurze Zeitdauern    */
  /* untersuchen                                                     */ 
  /*******************************************************************/
  FOR I TO N_DIGIN REPEAT
    X_A=(NOW-ZP_IMPALT(I)) / 1.0 SEC;
    IF X_A < 0.000 THEN
      X_A=X_A+86400.0;
    FIN;
    IF X_A > FL_IMPDAU(I) THEN
      FL_IMPDAU(I)=X_A;
    FIN;
  END;       

  /*-----------------------------------------------------------------*/
  /* Analogeingangswerte aufnehmen:                                  */
  IF Z_DIVIERT(150) < 120 THEN     /* Abwechselnd 5ms spaeter AIs auslesen um Schwebung zu verhindern */
    FIX1=10;                       /* muss globale Variable sein, damit bei naechsten SYSTAKT der     */
    Z_DIVIERT(150)=130;            /* Wert noch erhalten ist                                          */
  ELSE
    FIX1=0;
    Z_DIVIERT(150)=0;
  FIN;
  AFTER FIX1*0.001 SEC RESUME;     /* Abwechselnd 15ms spaeter AIs auslesen um Schwebung zu verhindern */

  CALL AIN(0);
  Z_SERVPAUS=Z_SERVPAUS+1;
  IF Z_SERVPAUS > 21610 THEN
    Z_SERVPAUS=0;
  FIN;

  IF Z_HMNEU > 0 THEN
    Z_HMNEU=Z_HMNEU-1;
  FIN;


  Z_MINVIERT= (ZF_MIN REM 15) + 1; /* Minutenstand der akt. 1/4h */
  CALL FIXGRENZ(15,1,Z_MINVIERT);  

  B_LOOP='1'B;
  B_LOOP2='0'B;
  IF Z_LZ > 15(31) THEN  /* Fuehlerfehler fruehestens nach 15s */
    FIX1=1;
    WHILE FIX1 < N_FUEHLER+1 AND B_LOOP REPEAT
      FL_AIVIERT(FIX1,Z_MINVIERT)=FL_AIVIERT(FIX1,Z_MINVIERT)+X_AEIN(FIX1);
      IF B_FUEHLWACH(FIX1) THEN
        IF X_AEIN(FIX1) > FL_XAEINMAX(FIX1) THEN
          IF Z_FUEHLST(FIX1) < 2 THEN
            F(1)=FIX1//100;
            F(2)=(FIX1-F(1)*100)//10;
            F(3)=FIX1 REM 10;
            CALL STOERMELD(74,'Wert >MAX AI' CAT TOCHAR(F(1)+48)
                                             CAT TOCHAR(F(2)+48) 
                                             CAT TOCHAR(F(3)+48));
            Z_FUEHLST(FIX1)=900;
            B_LOOP='0'B;
          FIN;
          IF Z_FUEHLST(FIX1) < 900 THEN   Z_FUEHLST(FIX1)=Z_FUEHLST(FIX1)+1;   FIN;
        ELSE        
          IF X_AEIN(FIX1) < FL_XAEINMIN(FIX1) THEN
            IF Z_FUEHLST(FIX1) < 2 THEN
              F(1)=FIX1//100;
              F(2)=(FIX1-F(1)*100)//10;
              F(3)=FIX1 REM 10;
              CALL STOERMELD(74,'Wert <MIN AI' CAT TOCHAR(F(1)+48) 
                                               CAT TOCHAR(F(2)+48)
                                               CAT TOCHAR(F(3)+48));
              Z_FUEHLST(FIX1)=900;
              B_LOOP='0'B;
            FIN;
            IF Z_FUEHLST(FIX1) < 900 THEN   Z_FUEHLST(FIX1)=Z_FUEHLST(FIX1)+1;   FIN;
          ELSE
            IF Z_FUEHLST(FIX1) > 0 THEN   Z_FUEHLST(FIX1)=Z_FUEHLST(FIX1)-1;   FIN;
          FIN;
        FIN;
        IF Z_FUEHLST(FIX1) > 10 THEN
          B_LOOP2='1'B;
        FIN;
      ELSE
        Z_FUEHLST(FIX1)=0;
      FIN;
      FIX1=FIX1+1;  
    END;
  FIN;
  B_STOER(74)=B_LOOP2;

 
  FL_AIVIERT(201,Z_MINVIERT)=FL_AIVIERT(201,Z_MINVIERT)+PE_BEDARF;     /* 1/4h Integrator Pel Bedarf  */
  FL_AIVIERT(202,Z_MINVIERT)=FL_AIVIERT(202,Z_MINVIERT)+PE_BGES;       /* 1/4h Integrator Pel BHKW  */
  FL_AIVIERT(203,Z_MINVIERT)=FL_AIVIERT(203,Z_MINVIERT)+PT_KAKT;       /* 1/4h Integrator Pth Kessel  */
  FL_AIVIERT(204,Z_MINVIERT)=FL_AIVIERT(204,Z_MINVIERT)+TC_AUSSEN;     /* 1/4h Integrator Aussentemp */
  FL_AIVIERT(205,Z_MINVIERT)=FL_AIVIERT(205,Z_MINVIERT)+PT_AKT;        /* 1/4h Integrator Pth gesamt  */

  FL_AIVIERT(191,Z_MINVIERT)=FL_AIVIERT(191,Z_MINVIERT)+TC_VIST;       /* 1/4h Integrator VL-Ist  */
  FL_AIVIERT(190,Z_MINVIERT)=FL_AIVIERT(190,Z_MINVIERT)+TC_VSOLL;      /* 1/4h Integrator VL-Soll */

  FL_AIVIERT(181,Z_MINVIERT)=FL_AIVIERT(181,Z_MINVIERT)+X_AEIN(181);   /* 1/4h Integrator BHKW1 VL */
  FL_AIVIERT(182,Z_MINVIERT)=FL_AIVIERT(182,Z_MINVIERT)+X_AEIN(182);   /* 1/4h Integrator BHKW1 RL */
  FL_AIVIERT(183,Z_MINVIERT)=FL_AIVIERT(183,Z_MINVIERT)+X_AEIN(183);   /* 1/4h Integrator BHKW2 VL */
  FL_AIVIERT(184,Z_MINVIERT)=FL_AIVIERT(184,Z_MINVIERT)+X_AEIN(184);   /* 1/4h Integrator BHKW2 RL */
  FL_AIVIERT(185,Z_MINVIERT)=FL_AIVIERT(185,Z_MINVIERT)+X_AEIN(185);   /* 1/4h Integrator BHKW3 VL */
  FL_AIVIERT(186,Z_MINVIERT)=FL_AIVIERT(186,Z_MINVIERT)+X_AEIN(186);   /* 1/4h Integrator BHKW3 RL */

  IF B_PMPHK(4) THEN
    FL_AIVIERT(188,Z_MINVIERT)=FL_AIVIERT(188,Z_MINVIERT)+100.0;   /* <<< 1/4h Integrator Betrieb Trocknung */
  FIN;

! FL_AIVIERT(188,Z_MINVIERT)=FL_AIVIERT(188,Z_MINVIERT)+UPE_PRO(3);   /* 1/4h Integrator ZUBR PMP HAUS A */
! FL_AIVIERT(189,Z_MINVIERT)=FL_AIVIERT(189,Z_MINVIERT)+UPE_PRO(4);   /* 1/4h Integrator ZUBR PMP VILLA  */


! /* <<< fuer die ersten 6 HKs Tempereturen von Mbus aufzeichnen */ 
! FOR I TO 6 REPEAT
!   IF ZT_MBUS(I+3) > ZT_JAHR - 12000(31) THEN
!     FL_AIVIERT(I+150,Z_MINVIERT)=FL_AIVIERT(I+150,Z_MINVIERT)+TCV_MBUS(I+3);   /* 1/4h Integrator HK VL */
!     FL_AIVIERT(I+160,Z_MINVIERT)=FL_AIVIERT(I+160,Z_MINVIERT)+TCR_MBUS(I+3);   /* 1/4h Integrator HK RL */
!   ELSE
!     FL_AIVIERT(I+150,Z_MINVIERT)=FL_AIVIERT(I+150,Z_MINVIERT)+ (-988.0);   /* 1/4h Integrator HK VL */
!     FL_AIVIERT(I+160,Z_MINVIERT)=FL_AIVIERT(I+160,Z_MINVIERT)+ (-988.0);   /* 1/4h Integrator HK RL */
!   FIN;
! END;


  FOR I TO 90 REPEAT  /* <<< */
    FOR K TO 1 REPEAT
      FL_AIVIERTEXT(I,K,Z_MINVIERT)=FL_AIVIERTEXT(I,K,Z_MINVIERT)+X_AEINEXT(I,K);
    END;
  END;


  FOR I TO N_RELPLT REPEAT
    FOR K TO 8 REPEAT
      IF BI_DAUS(I).BIT(17-K) THEN
        Z_DOVIERT(I*8+K-8)=Z_DOVIERT(I*8+K-8)+1;
      FIN;
    END;
  END;
  FOR I TO N_DIGIN REPEAT
    CASE Z_DIBEWERT(I)
      ALT
        BI_DEINBEW(I)=BI_DEIN(I);
      ALT
        BI_DEINBEW(I)=NOT BI_DEIN(I);
      ALT  
        BI_DEINBEW(I)='1'B;
      ALT  
        BI_DEINBEW(I)='0'B;
      OUT
        BI_DEINBEW(I)=BI_DEIN(I);
    FIN;
    IF BI_DEINBEW(I) THEN
      Z_DIVIERT(I)=Z_DIVIERT(I)+1;
    FIN;
  END;


  /* analoge Eingangssignale auf Variablen uebertragen                */
  /* wird hier ueber Impulsz„hlung ermittelt                          */
! PE_BEDARF=X_AEIN(ZE_PEBED);                         /* PBedarf AI Messung -> Verbraucher    */
! PE_BEDARF=X_AEIN(ZE_PEBED)+PE_BIST(1);              /* PBedarf AI Messung Netzseitig (+-P)  */
! PE_BEDARF=3600.0/FL_IMPDAU(12)/FL_IMP(12);          /* PBedarf Impulse -> Verbraucher       */
! P_DI(16)=3600.0/FL_IMPDAU(16)/FL_IMP(16);           /* Pel Bezug von EVU */
! P_DI(15)=3600.0/FL_IMPDAU(15)/FL_IMP(15);           /* Pel Einspeisung an EVU */
! P_DI(13)=3600.0/FL_IMPDAU(13)/FL_IMP(13);           /* Pel PV                 */
! PE_BIST(1)=3600.0/FL_IMPDAU(12)/FL_IMP(12);         /* Pel BHKW 1     */
! PE_BEDARF=P_DI(16)+PE_BIST(1)+P_DI(13)  -P_DI(15);  /* PBedarf = Bezug+PBHKW-Einspeisung */

  PE_BEDARF=PE_MAXBHKW(1)*0.6;

  IF Z_FUEHLST(ZE_AUSSEN) > 800 THEN  /* Ueberwachung AI AT */
    TC_AUSSEN=0.0;
  ELSE /* evtl 2. AT ?   <<< */
!   IF X_AEIN(33) < X_AEIN(ZE_AUSSEN) THEN
!     TC_AUSSEN=X_AEIN(33);  /* 2. AT */
!   ELSE
      TC_AUSSEN=X_AEIN(ZE_AUSSEN);  /* Aussentemperatur                  */
!   FIN;
  FIN;
  TC_VIST  =X_AEIN(ZE_VORLAUF); /* Hauptkreisvorlauftemperatur       */
  TC_RUECK =X_AEIN(ZE_RUECK);   /* Hauptkreisruecklauftemperatur      */
  TC_UEBER =X_AEIN(ZE_UEBER);   /* šberstr”mung    <<< Puffer oben                  */
  P_VERTEIL=X_AEIN(32);         /* Druck Verteiler  <<<              */
  FL_GAS   =X_AEIN(31)+2.5;     /* Analogsignal Gassensor <<<        */


! IF NOT B_STOER(52) THEN  /* CAN UST OK! */
!   TC_VIST=X_AEINEXT( 8,1);
!   TC_RUECK=X_AEINEXT( 9,1);
!   TC_UEBER=X_AEINEXT( 7,1); 
!   IF TC_UEBER > TC_VIST THEN
!     TC_VIST=TC_UEBER;
!   FIN;
! FIN;
  

  IF TC_UEBER-0.0 > TC_VIST THEN   /* wenn šberstr”mung > Hauptkreis */
    TC_VIST=TC_UEBER-0.0;          /* dann Hauptkreis=šberstr”mung   */
  FIN;                                         /* HYD WEICHE    <<<  */

  /* <<<   */ 
  IF Z_BANFORD < 1 AND PT_SCHNITT > 30.0 AND TC_UEBER < TC_VIST THEN
    TC_VIST=TC_UEBER;            /* PUFFER1 unten   */
! ELSE
!   TC_VIST=X_AEIN(ZE_VORLAUF);  /* HAUPTK VL      */
  FIN;

  /* <<< POSITION HAUPTKREISVL              */
  CALL FIXGRENZ(4,1,ZF_HKPEXT(32));  
  CASE ZF_HKPEXT(32)
    ALT
      TC_VIST=X_AEIN(13);
      IF TC_UEBER-0.0 > TC_VIST THEN   /* wenn šberstr”mung > Hauptkreis */
        TC_VIST=TC_UEBER-0.0;          /* dann Hauptkreis=šberstr”mung   */
      FIN;                                         /* HYD WEICHE    <<<  */
      IF X_AEIN(10) > TC_VIST THEN
        TC_VIST=X_AEIN(10);
      FIN;
      IF X_AEIN(11) > TC_VIST THEN
        TC_VIST=X_AEIN(11);
      FIN;
    ALT
      TC_VIST=X_AEIN( 9);       /* MITTE OBEN */
      IF X_AEIN(10) > TC_VIST THEN
        TC_VIST=X_AEIN(10);
      FIN;
      IF X_AEIN(11) > TC_VIST THEN
        TC_VIST=X_AEIN(11);
      FIN;
    ALT
      TC_VIST=X_AEIN(10);       /* MITTE      */
      IF X_AEIN(11) > TC_VIST THEN
        TC_VIST=X_AEIN(11);
      FIN;
    ALT
      TC_VIST=X_AEIN(11);       /* MITTE UNTEN */
    OUT
  FIN;

  FOR I TO N_BHKW REPEAT /* BHKW-Leistung und Temperaturen zuordnen: */
!   PE_BIST(I)=X_AEIN(ZE_PB(I));    /* */
    TC_BHZGV(I)=X_AEIN(ZE_BV(I));   /* */
    TC_BHZGR(I)=X_AEIN(ZE_BR(I));   /* */
    IF B_BPMP(I) THEN
      Z_LZBPMP(I)=Z_LZBPMP(I)+1(31);
    ELSE
      Z_LZBPMP(I)=0(31);
    FIN;    
    B_BERLAUBT2(I)=B_BERLAUBT(I); 
 !  B_BERLAUBT2(I)=B_BERLAUBT(I) AND BI_DEINBEW(xx);
  END;

  FOR I TO N_HZKR REPEAT /* Heizkreistemperaturen und Druck zuordnen:*/
 !  IF I == 1 THEN
 !    TC_HKIST(I)=X_AEIN( 17     ); /* <<< HAUPT VL */
 !    TC_HKR(I)=X_AEIN( 18      );  /* <<< HAUPT RL */
 !  ELSE
      TC_HKIST(I)=X_AEIN(ZE_HK(I)); 
      TC_HKR(I)=X_AEIN(ZE_HKR(I));  
 !  FIN;    
    IF B_PMPHK(I) THEN
      Z_LZHKPMP(I)=Z_LZHKPMP(I)+1(31);
    ELSE
      Z_LZHKPMP(I)=0(31);
    FIN;    
  END;

  TC_HKIST(4)=X_AEIN(21);  /* <<< Zuluft Trocknung */
  TC_HKR(4)=8.8;  

! IF B_PMPHK(22) THEN           /* NAHWAERMEPUMPE  HAUS A   */
!   Z_LZHKPMP(22)=Z_LZHKPMP(22)+1(31);
! ELSE
!   Z_LZHKPMP(22)=0(31);
! FIN;    
! IF B_PMPHK(23) THEN           /* NAHWAERMEPUMPE  VILLA    */
!   Z_LZHKPMP(23)=Z_LZHKPMP(23)+1(31);
! ELSE
!   Z_LZHKPMP(23)=0(31);
! FIN;    

! TC_HKIST(21)=X_AEIN(16      ); 
! TC_HKR(21)=X_AEIN(17       );  

! TC_RISTAKT(1)=X_AEIN(26);
! IF X_AEIN(27) < TC_RISTAKT(1) THEN
!   TC_RISTAKT(1)=X_AEIN(27);
! FIN;



  FOR I TO N_SPEI REPEAT /* Speichertemperaturen zuordnen:           */
!   TC_BWO  (I)=X_AEIN(ZE_BWO  (I));      /* hier WT Austritt */
!   TC_BWIST(I)=X_AEIN(ZE_BWIST(I));      /* */
    TC_BWVOR(I)=X_AEIN(ZE_BWVOR(I));  /* */
    TC_BWRUECK(I)=X_AEIN(ZE_BWRUECK(I));  /* */
    TC_ZIRK(I)=X_AEIN(ZE_ZIRK(I));        /* */
    IF B_LPMP(I) THEN
      Z_LZBWLPMP(I)=Z_LZBWLPMP(I)+1(31);
    ELSE
      Z_LZBWLPMP(I)=0(31);
    FIN;    
    IF B_SPMP(I) THEN
      Z_LZBWSPMP(I)=Z_LZBWSPMP(I)+1(31);
    ELSE
      Z_LZBWSPMP(I)=0(31);
    FIN;    
    IF B_ZIRKPMP(I) THEN
      Z_LZBWZPMP(I)=Z_LZBWZPMP(I)+1(31);
    ELSE
      Z_LZBWZPMP(I)=0(31);
    FIN;    
  END;

! TC_BWO(1)=X_AEIN( 6); /* Pu Zentrale */
! TC_BWO(2)=X_AEIN(37); /* Pu Haus A   */
! TC_BWO(3)=X_AEIN(53); /* Pu Villa    */

  FOR I TO N_KESSEL REPEAT /* Kesseltemperaturen zuordnen            */
    TC_KV(I)=X_AEIN(ZE_KV(I));  /* <<< */
 !  TC_KR(I)=X_AEIN(  5     );  /* <<< Sammel RL */
    TC_KR(I)=X_AEIN(ZE_KR(I));  /* <<< */
                 /*   <<<       */
    IF B_KPMP(I) AND Z_KHARDST(I) < 900 THEN
      Z_LZKPMP(I)=Z_LZKPMP(I)+1(31);
    ELSE
      Z_LZKPMP(I)=0(31);
    FIN;    
  END;
  


  /* <<< hier P-BHKW ueber CAN   */


  /* P= MBUS ODER Digitaleingang */
! FL1=0.0;
! IF ZT_MBUS(4) > ZT_JAHR - 12000(31) THEN
!   FL1=PTH_MBUS(4)*0.05;
! FIN;
! IF FL1 > 10.0 AND FL1 < 888.0 THEN
!   PE_BIST(1)=FL1;        /* <<< */
! ELSE
!   IF BI_DEINBEW( 2) THEN
!     PE_BIST(1)=PE_MAXBHKW(1);
!   ELSE
!     PE_BIST(1)=0.0;
!   FIN;
! FIN;

  /* P= Analogeingang ODER Digitaleingang */
! IF X_AEIN(30) > 3.0 THEN
!   PE_BIST(1)=X_AEIN(30); /* <<< */
! ELSE
!   IF BI_DEINBEW(19) THEN
!     PE_BIST(1)=PE_MAXBHKW(1);
!   ELSE
!     PE_BIST(1)=0.0;
!   FIN;
! FIN;

  /* P= Impulse ODER Digitaleingang */
! FL1=3600.0/FL_IMPDAU( 8)/FL_IMP( 8); 
! IF FL1 > 3.0 THEN
!   PE_BIST(1)=FL1;
! ELSE
!   IF BI_DEINBEW(19) THEN
!     PE_BIST(1)=PE_MAXBHKW(1);
!   ELSE
!     PE_BIST(1)=0.0;
!   FIN;
! FIN;

  B_BEIN(1)='1'B;                             /* <<< */

  IF X_AEIN(22) > TC_HKVNENN(15) THEN           /* <<< BHKW BETRIEBSERKENNUNG BEI VL > ... */
    PE_BIST(1)=PE_MAXBHKW(1);
  FIN;
  IF X_AEIN(22) < TC_HKVNENN(15)-2.0 THEN
    PE_BIST(1)=0.0;
  FIN;

  /* BHKW Betriebszustaende ueber AI/DI */
  IF PE_BIST(1) > 2.5 THEN                                     /*  */
    B_BL(1)='1'B;       /* BHKW laeuft, wenn Leistung> 2.5 KW ist  */
  ELSE                                                         /*  */
    B_BL(1)='0'B;                                              /*  */
  FIN;                                                         /*  */

! B_BSTOER(1)=BI_DEINBEW(20);                                     /*  */
! B_BBEREIT(1)=NOT B_BSTOER(1) AND Z_BTHERMVL(1) < 1 AND Z_BTHERMRL(1) < 1;                               /*  */

  X_A=0.0;
  FOR I TO N_BHKW REPEAT
    IF B_BL(I) THEN
      X_A=X_A+PE_BIST(I);
    FIN;
  END;
  PE_BGES=X_A;
  

  /* UMGANG MIT DEN HOLZKESSELN (keine Anf-Moeglichkeit, Abgriff Stokerschnecke) <<< */
  B_KL( 8)='0'B;
  IF TC_KV(1) > TC_KVMAX(1) - 2.0 THEN /* TEMP > MAX ? */
    IF Z_KTEMPEIN( 8) < 300 THEN
      Z_KTEMPEIN( 8)=300;        /* dann Betrieb fuer mindestens 5MIN */
    FIN;
  FIN;
  IF Z_STOKMS( 8) > 0 THEN       /* STOKER GELAUFEN?                  */
    Z_KTEMPEIN( 8)=1800;         /* dann Betrieb fuer mindestens 1/2h */
    B_KL( 8)='1'B;               /* fuer Lfz-prot Stokerschn          */
  FIN;
  IF Z_KTEMPEIN( 8) > 0 THEN
    Z_KTEMPEIN( 8)=Z_KTEMPEIN( 8)-1;
    B_KL(1)='1'B;     
  ELSE
    B_KL(1)='0'B;
  FIN;

  FIX1=ROUND(Z_STOKMS( 8)*0.01);                  /* Lfz Stok in 1/10s */
  Z_STOKMS( 8)=0;
  W_55( 8)=W_55( 8)+FIX1*0.1(55)*0.00027777(55);  /* Lfz Stok gesamt (s) */
  FL_AIVIERT(208,Z_MINVIERT)=FL_AIVIERT(208,Z_MINVIERT)+FIX1*0.1;       /* Lfz 1/4h (s) */
  Z_STOKVIERT( 8)=Z_STOKVIERT( 8)+FIX1;
  Z_STOKVIERT(10)=Z_STOKVIERT(10)+10;

  TC_KVMAX( 8)=TC_KVMAX( 8)+FIX1*0.1*0.016666;    /* Lfz Stok heute (Min) */

  X_A=(Z_STOKVIERT( 8)/Z_STOKVIERT(10))*5.00*PT_KES(1);  /* Annahme: 20% laufzeit Stoker = 100% Leistung */
  IF X_A > PT_KES(1) THEN
    PT_KESAKT(8)=PT_KES(1);
  ELSE
    PT_KESAKT(8)=X_A;
  FIN;


  B_KL( 9)='0'B;
  IF TC_KV(2) > TC_KVMAX(2) - 2.0 THEN /* TEMP > MAX ? */
    IF Z_KTEMPEIN( 9) < 300 THEN
      Z_KTEMPEIN( 9)=300;        /* dann Betrieb fuer mindestens 5MIN */
    FIN;
  FIN;
  IF Z_STOKMS( 9) > 0 THEN       /* STOKER GELAUFEN?                  */
    Z_KTEMPEIN( 9)=1800;         /* dann Betrieb fuer mindestens 1/2h */
    B_KL( 9)='1'B;               /* fuer Lfz-prot Stokerschn          */
  FIN;
  IF Z_KTEMPEIN( 9) > 0 THEN
    Z_KTEMPEIN( 9)=Z_KTEMPEIN( 9)-1;
    B_KL(2)='1'B;     
  ELSE
    B_KL(2)='0'B;
  FIN;

  FIX1=ROUND(Z_STOKMS( 9)*0.01);                  /* Lfz Stok in 1/10s */
  Z_STOKMS( 9)=0;
  W_55( 9)=W_55( 9)+FIX1*0.1(55)*0.00027777(55);  /* Lfz Stok gesamt (s) */
  FL_AIVIERT(209,Z_MINVIERT)=FL_AIVIERT(209,Z_MINVIERT)+FIX1*0.1;       /* Lfz 1/4h (s) */
  Z_STOKVIERT( 9)=Z_STOKVIERT( 9)+FIX1;

  TC_KVMAX( 9)=TC_KVMAX( 9)+FIX1*0.1*0.016666;    /* Lfz Stok heute (Min) */

  X_A=(Z_STOKVIERT( 9)/Z_STOKVIERT(10))*5.00*PT_KES(2);  /* Annahme: 20% laufzeit Stoker = 100% Leistung */
  IF X_A > PT_KES(2) THEN
    PT_KESAKT(9)=PT_KES(2);
  ELSE
    PT_KESAKT(9)=X_A;
  FIN;



  /* <<< */
! B_KL(1)=B_KEIN(1)      /* */
! B_KL(1)=B_KEIN(1) AND BI_DEINBEW(2); /* */
! B_KL(2)=B_KEIN(2) AND BI_DEINBEW(4); /* */
  B_KL(3)=B_KEIN(3) AND BI_DEINBEW( 6);    /* K1 Anforderung und Betriebsmeldung DI */
! B_KL(2)=B_KEIN(2) AND BI_DEINBEW( 4);    /* K1 Anforderung und Betriebsmeldung DI */
! B_KL(1)=B_KEIN(1) AND X_AEIN(28) > 15.0; /* K1 Anforderung und Betriebsmeldung AI */
! B_KL(2)=B_KEIN(2) AND X_AEIN(29) > 15.0; /* K1 Anforderung und Betriebsmeldung AI */
! B_KL(1)=B_KEIN(1) AND (X_AEIN(29) > 15.0 OR BI_DEINBEW(2)); /* K1 Anf und Betrieb AI ODER DI */
! B_KL(2)=B_KEIN(2) AND (X_AEIN(30) > 15.0 OR BI_DEINBEW(4)); /* K2  */
! B_KL(3)=B_KEIN(3) AND (X_AEIN(30) > 15.0 OR BI_DEINBEW(8)); /* K3  */


  PE_VIERTEL=PE_VIERTEL+PE_BEDARF;     /* PE_BEDARF aufintegrieren */

  PE_ERZVIERTEL=PE_ERZVIERTEL+PE_BGES; /* PE_BIST(.)aufintegrieren */
  

  IF PE_BEDARF>PE_BGES THEN
    PE_BEZUGVIERT=PE_BEZUGVIERT+PE_BEDARF-PE_BGES;
  FIN;


  /* Organisation der erlaubten Maximaleinspeisung uebers Jahr */
! FL1=0.0;
! IF P_DI(13) > 0.2 THEN
!   FL1=P_DI(13);
! FIN;
! W_HKTH(21)=W_HKTH(21)+FL1*1.0(55);     /* akt Jahr Erzeugung PV */
! 
! FL1=0.0;
! IF PE_BIST(1) > 0.2 THEN
!   FL1=PE_BIST(1);
! FIN;
! W_HKTH(22)=W_HKTH(22)+FL1*1.0(55);     /* akt Jahr Erzeugung BHKW */
!
! W_HKTH(23)=W_HKTH(21)+W_HKTH(22);      /* akt Jahr Erzeugung GESAMT  */
! 
! FL1=0.0;
! IF P_DI(24) > 0.15 THEN
!   FL1=P_DI(24);
! FIN;
! W_HKTH(24)=W_HKTH(24)+FL1*1.0(55);     /* akt Jahr Einspeis. -> EVU */
! 
! IF W_HKTH(23) > 0.5(55) THEN
!   FL_EINSPPRO=(W_HKTH(24)/W_HKTH(23)) FIT FL_EINSPPRO;   /* akt. Jahr Einspeisung der Stromerzeugung (%) 0-1 */
! ELSE
!   FL_EINSPPRO=0.0;                 
! FIN;


!!IF TC_VIST > TC_VSOLL THEN
!!  B_BBEREIT(8)='1'B;
!!FIN;
!!IF TC_VIST < TC_VSOLL-1.0 THEN
!   B_BBEREIT(8)='0'B;
!!FIN;
!
! IF FL_EINSPPRO > (FL_EXPHK(15)*0.01)-0.01 THEN  /* ZU VIEL EINGESPEIST */
!   IF P_DI(15) > 3.0 THEN 
!!    IF B_BBEREIT(8) THEN
!!      B_BEIN(8)='1'B;   /* HEIZEN UNTERE PATRONE */
!!      B_BEIN(7)='0'B;
!!    ELSE
!       B_BEIN(7)='1'B;   /* HEIZEN OBERE PATRONE */
!       B_BEIN(8)='0'B;
!!    FIN;
!   FIN;
!   IF P_DI(15) < 1.0 THEN
!     B_BEIN(8)='0'B;
!     B_BEIN(7)='0'B;
!   FIN;
! ELSE
!   B_BEIN(8)='0'B;
!   B_BEIN(7)='0'B;
! FIN;
! IF B_BEIN(8) THEN
!   X_AAPBHKW(8)=(P_DI(15)-1.0)*10.0;
!   CALL FLOGRENZ(100.0,1.0,X_AAPBHKW(8)); 
! ELSE
!   X_AAPBHKW(8)=0.0;
! FIN;
! IF B_BEIN(7) THEN
!   X_AAPBHKW(7)=(P_DI(15)-1.0)*10.0;
!   CALL FLOGRENZ(100.0,1.0,X_AAPBHKW(7)); 
! ELSE
!   X_AAPBHKW(7)=0.0;
! FIN;


  /* Gas GESAMT                                                         */
! Z_DI=10;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI); 
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
! FIN;                                                          /*   */

  /* Gas BHKW                                                         */
! Z_DI= 9;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI); 
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
! FIN;                                                          /*   */ 


  /* WEL BHKW 100%                                                       */
! Z_DI=14;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI); 
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
! FIN;                                                          /*   */
 
! /* WEL PV                                                            */
! Z_DI=13;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI); 
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
! FIN;                                                          /*   */
 
! /* WEL Heizpatronen                                                  */
! Z_DI=14;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI); 
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
! FIN;                                                          /*   */
 
! /* WEL Heizpatrone2                                                  */
! Z_DI=22;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI); 
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
! FIN;                                                          /*   */
 
 
! /* Waerme HK1                                                         */
! Z_DI=26;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI); 
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
! FIN;                                                          /*   */
 

  /* GAS BHKW2                                                          */
! Z_DI=17;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI); 
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
! FIN;                                                          /*   */

  /* VOL HZG NACHSP                                                     */
! Z_DI=21;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI); 
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
! FIN;                                                          /*   */
 

 

  /* Stromgr”áen z„hlen   <<<                                   */
  IF B_HT THEN
    W_ERZHT=W_ERZHT+PE_BGES*0.000277777(55);     /*              */       
 !  W_BEDHT=W_BEDHT+PE_BEDARF*0.000277777(55);   /*              */
 !  IF PE_BGES > PE_BEDARF THEN
 !    W_EINHT=W_EINHT+(PE_BGES-PE_BEDARF)*0.000277777(55);
 !  ELSE
 !    W_BEZHT=W_BEZHT+(PE_BEDARF-PE_BGES)*0.000277777(55);
 !  FIN;
    W_HKTH(10)=W_HKTH(10)+PE_BGES*0.000277777(55);   /*              */
    W_HKTH(11)=W_HKTH(11)+PE_BEDARF*0.000277777(55);   /*              */
  ELSE
    W_ERZNT=W_ERZNT+PE_BGES*0.000277777(55);     /*              */      
 !  W_BEDNT=W_BEDNT+PE_BEDARF*0.000277777(55);   /*              */ 
 !  IF PE_BGES > PE_BEDARF THEN
 !    W_EINNT=W_EINNT+(PE_BGES-PE_BEDARF)*0.000277777(55);
 !  ELSE
 !    W_BEZNT=W_BEZNT+(PE_BEDARF-PE_BGES)*0.000277777(55);
 !  FIN;
    W_HKTH(10)=W_HKTH(10)+PE_BGES*0.000277777(55);   /*              */
    W_HKTH(11)=W_HKTH(11)+PE_BEDARF*0.000277777(55);   /*              */
  FIN;

  /* Stromeinspeisung z„hlen                                              */
! Z_DI=15;  /* P Einsp   */                               /*   */
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
!   IF B_HT THEN                                                /*   */
!     W_EINHT=W_EINHT+F31*0.5(55)/FL_IMP(Z_DI);                /*   */ 
!   ELSE                                                        /*   */
!     W_EINNT=W_EINNT+F31*0.5(55)/FL_IMP(Z_DI);                /*   */    
!   FIN;                                                        /*   */
! FIN;                                                          /*   */
 
  /* Strombezug z„hlen                                              */
! Z_DI=16;  /* P Bezug   */                               /*   */
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
!   IF B_HT THEN                                                /*   */
!     W_BEZHT=W_BEZHT+F31*0.5(55)/FL_IMP(Z_DI);                /*   */ 
!   ELSE                                                        /*   */
!     W_BEZNT=W_BEZNT+F31*0.5(55)/FL_IMP(Z_DI);                /*   */    
!   FIN;                                                        /*   */
! FIN;                                                          /*   */ 


  /* Strombedarf z„hlen                                              */
! Z_DI=12;                                                      /*   */
! P_DI(Z_DI)=3600.0/FL_IMPDAU(Z_DI)/FL_IMP(Z_DI);
! IF Z_ZAEHLMERK(Z_DI) < Z_ZAEHL(Z_DI) THEN                     /*   */
!   F31=Z_ZAEHL(Z_DI)-Z_ZAEHLMERK(Z_DI);                       /*   */
!   Z_ZAEHLMERK(Z_DI)=Z_ZAEHLMERK(Z_DI)+F31;                   /*   */
!   Z_IMPDIVIERT(Z_DI,Z_MINVIERT)=(Z_IMPDIVIERT(Z_DI,Z_MINVIERT)+F31) FIT Z_IMPDIVIERT(Z_DI,Z_MINVIERT); /*   */
!   IF B_HT THEN                                                /*   */
!     W_BEDHT=W_BEDHT+F31*0.5(55)/FL_IMP(Z_DI);                /*   */ 
!   ELSE                                                        /*   */
!     W_BEDNT=W_BEDNT+F31*0.5(55)/FL_IMP(Z_DI);                /*   */    
!   FIN;                                                        /*   */
! FIN;                                                          /*   */



  /* Softwarewaermemengen-Zaehler       <<<                           */
  /* und Durchfluesse und thermische Leistungen ermitteln             */
  /*                               T(warm)  T(kalt)                   */
  /*             Nr DI    Zaehler    AI 1     AI 2    AI Uhr          */
! CALL WAEZAEHL(   13,       1,        2,       3,       3);/* WMZ BHKW          */
! X_AEIN(75)=10.0;
! CALL WAEZAEHL(   14,       1,       35,      75,      75);/* WMZ ww1 VERBR.     */
! CALL WAEZAEHL(   19,       2,       42,      75,      75);/* WMZ ww2 VERBR.     */
! CALL WAEZAEHL(   24,       3,       47,      75,      75);/* WMZ ww3 VERBR.     */
! CALL WAEZAEHL(   25,       4,       52,      75,      75);/* WMZ ww4 VERBR.     */


/* ETW:  1/4h-Wert Pth-BHKW ueber CAN */ 
! IF NOT B_STOER(53) THEN  /* BHKW1-CAN OK   */ 
!   W_HKTH(30)=W_HKTH(30)+PT_BIST(1)*0.000277777(55);   /*              */
!   FL_THVIERT(30,Z_MINVIERT)=FL_THVIERT(30,Z_MINVIERT)+PT_BIST(1)*0.000277777;
! FIN;  

! IF NOT B_STOER(54) THEN  /* BHKW2-CAN OK   */ 
!   W_HKTH(30)=W_HKTH(30)+PT_BIST(2)*0.000277777(55);   /*              */
!   FL_THVIERT(30,Z_MINVIERT)=FL_THVIERT(30,Z_MINVIERT)+PT_BIST(2)*0.000277777;
! FIN;  

/* 1/4h-Werte M-Bus bestimmen */ 
  Z_DI= 1;                                                      /*   */
  X_A=WTH_MBUS(Z_DI); /* WMZ BHKW            */
  IF X_A > WTH_MBUSMERK(Z_DI)+0.09 AND X_A < WTH_MBUSMERK(Z_DI)+950.0 THEN
    FL_MBUSVIERT(Z_DI,Z_MINVIERT)=FL_MBUSVIERT(Z_DI,Z_MINVIERT)+(X_A-WTH_MBUSMERK(Z_DI));
  FIN;
  WTH_MBUSMERK(Z_DI)=X_A;
 
  Z_DI= 2;                                                      /*   */
  X_A=WTH_MBUS(Z_DI); /* WMZ Holzkessel1     */
  IF X_A > WTH_MBUSMERK(Z_DI)+0.09 AND X_A < WTH_MBUSMERK(Z_DI)+950.0 THEN
    FL_MBUSVIERT(Z_DI,Z_MINVIERT)=FL_MBUSVIERT(Z_DI,Z_MINVIERT)+(X_A-WTH_MBUSMERK(Z_DI));
  FIN;
  WTH_MBUSMERK(Z_DI)=X_A;
 
  Z_DI= 3;                                                      /*   */
  X_A=WTH_MBUS(Z_DI); /* WMZ Holzkessel2        */
  IF X_A > WTH_MBUSMERK(Z_DI)+0.09 AND X_A < WTH_MBUSMERK(Z_DI)+950.0 THEN
    FL_MBUSVIERT(Z_DI,Z_MINVIERT)=FL_MBUSVIERT(Z_DI,Z_MINVIERT)+(X_A-WTH_MBUSMERK(Z_DI));
  FIN;
  WTH_MBUSMERK(Z_DI)=X_A;
 
  Z_DI= 4;                                                      /*   */
  X_A=WTH_MBUS(Z_DI); /* WMZ Biogaskessel         */
  IF X_A > WTH_MBUSMERK(Z_DI)+0.09 AND X_A < WTH_MBUSMERK(Z_DI)+950.0 THEN
    FL_MBUSVIERT(Z_DI,Z_MINVIERT)=FL_MBUSVIERT(Z_DI,Z_MINVIERT)+(X_A-WTH_MBUSMERK(Z_DI));
  FIN;
  WTH_MBUSMERK(Z_DI)=X_A;
 
  Z_DI= 5;                                                      /*   */
  X_A=WTH_MBUS(Z_DI); /* WMZ HK1                  */
  IF X_A > WTH_MBUSMERK(Z_DI)+0.09 AND X_A < WTH_MBUSMERK(Z_DI)+950.0 THEN
    FL_MBUSVIERT(Z_DI,Z_MINVIERT)=FL_MBUSVIERT(Z_DI,Z_MINVIERT)+(X_A-WTH_MBUSMERK(Z_DI));
  FIN;
  WTH_MBUSMERK(Z_DI)=X_A;
 
  Z_DI= 6;                                                      /*   */
  X_A=WTH_MBUS(Z_DI); /* WMZ HK2                   */
  IF X_A > WTH_MBUSMERK(Z_DI)+0.09 AND X_A < WTH_MBUSMERK(Z_DI)+950.0 THEN
    FL_MBUSVIERT(Z_DI,Z_MINVIERT)=FL_MBUSVIERT(Z_DI,Z_MINVIERT)+(X_A-WTH_MBUSMERK(Z_DI));
  FIN;
  WTH_MBUSMERK(Z_DI)=X_A;
 
  Z_DI= 7;                                                      /*   */
  X_A=WTH_MBUS(Z_DI); /* WMZ HK3                    */
  IF X_A > WTH_MBUSMERK(Z_DI)+0.09 AND X_A < WTH_MBUSMERK(Z_DI)+950.0 THEN
    FL_MBUSVIERT(Z_DI,Z_MINVIERT)=FL_MBUSVIERT(Z_DI,Z_MINVIERT)+(X_A-WTH_MBUSMERK(Z_DI));
  FIN;
  WTH_MBUSMERK(Z_DI)=X_A;
 


  /*-----------------------------------------------------------------*/

  ZP_NOW=NOW; /* einmal die Systemzeit feststellen                   */

  IF TC_AUSSEN<TC_AUSSENMIN THEN
    TC_AUSSENMIN=TC_AUSSEN;                      /* ATmin merken     */
    ZP_AUSSENMIN=ZP_NOW;                         /* Zeit merken      */
  FIN;

  IF TC_AUSSEN>TC_AUSSENMAX THEN
    TC_AUSSENMAX=TC_AUSSEN;                      /* ATmax merken     */
    ZP_AUSSENMAX=ZP_NOW;                         /* Zeit merken      */
  FIN;

  /* Falls Mitternacht, neues Datum auslesen:                        */
  IF ZP_NOW<00:02:00 THEN
    IF B_DATUMNEU THEN
      B_DATUMNEU='0'B;
      TC_AUSSENMAX=-100.0;  /* Merker fuer ATmax und ATmin auf        */
      TC_AUSSENMIN=100.0;   /* Extremwerte setzen                    */
      CALL RTC_DATUM;  /* Datum aus Echtzeituhr lesen                */
      /* zum Tageswechsel den aufintegrierten Wert der HKsoll-       */
      /* abweichung und alle Mischersoftwareendkonakte auf 0 setzen  */

      /* zum Tageswechsel auf Null setzen        */
      FOR I TO N_HZKR REPEAT
        TD_HKINT(I)=0.0;  /* zum Tageswechsel auf Null setzen        */
        Z_HKMI(I)=0;
      END;
      FOR I TO N_BHKW REPEAT
        Z_BHKWMI(I)=0;
      END;
      FOR I TO N_KESSEL REPEAT
        Z_KESMI(I)=0;
      END;
      IF Z_HZGFUELL < ZF_HZGFUELL THEN
        Z_HZGFUELL=0;
      FIN;
      Z_START24=0;
      FOR I TO 200 REPEAT
        Z_STOERNEU(I)=0;
      END;

      TC_KVMAX( 8)=0.0;  /* <<< */
      TC_KVMAX( 9)=0.0;

      FOR I TO 20 REPEAT      /* Laufzeiten aelter 1Monat loeschen */
        FOR K FROM 2 TO 13 REPEAT
          IF    DAT_BAUS(I,K) == DA_DAT 
             OR (DA_DAT > 27 AND DAT_BAUS(I,K) > DA_DAT) THEN
            Z_BLAUFZ(I,K)=0(31);
            ZP_BAUS(I,K)=00:00:00;
            DAT_BAUS(I,K)=0;
          FIN;
        END;
      END;

      FOR I TO 10 REPEAT      /* Laufzeiten aelter 1Monat loeschen */
        FOR K FROM 2 TO 13 REPEAT
          IF    DAT_KAUS(I,K) == DA_DAT 
             OR (DA_DAT > 27 AND DAT_KAUS(I,K) > DA_DAT) THEN
            Z_KLAUFZ(I,K)=0(31);
            ZP_KAUS(I,K)=00:00:00;
            DAT_KAUS(I,K)=0;
          FIN;
        END;
      END;

  
      IF DA_DAT==1 THEN
        PE_STRMAX(DA_MON)=0.0;
        DA_STRMAX(DA_MON)=0;
        Z_STRMAX(DA_MON)=0;
  

        AT_MON(1,DA_MON)=0.0;
        AT_MON(2,DA_MON)=0.0;
        ACTIVATE MONLOESCH;
  
        IF DA_MON==1 THEN  /* 1.1. */
          W_HKTH(25)=W_HKTH(21);  W_HKTH(21)=0.0(55);  /* Erzeugung PV     speichern und 0setzen */
          W_HKTH(26)=W_HKTH(22);  W_HKTH(22)=0.0(55);  /* Erzeugung BHKW   speichern und 0setzen */
          W_HKTH(27)=W_HKTH(23);  W_HKTH(23)=0.0(55);  /* Erzeugung gesamt speichern und 0setzen */
          W_HKTH(28)=W_HKTH(24);  W_HKTH(24)=0.0(55);  /* Einspeis. -> EVU speichern und 0setzen */
        FIN;

      FIN;

    FIN;


  ELSE
    B_DATUMNEU='1'B;
  FIN;

  /* Start der automatischen 1/4h-Daten-Abholung kurz nach Mitternacht */
  IF ZP_NOW > 00:05:00 AND ZP_NOW < 00:08:00 THEN
    IF Z_PANELSEND < 60 THEN
      Z_PANELSEND=180;
      PUT TOCHAR(27),TOCHAR(27),'q' TO LCD BY A,A,A;
    FIN;
    Z_PANELSEND=Z_PANELSEND-1;
  ELSE
    Z_PANELSEND=0;
  FIN;
! IF Z_PANELSEND > 3 THEN  /* stuendlich <<<< */
!   Z_PANELSEND=0;
!   PUT TOCHAR(27),TOCHAR(27),'q' TO LCD BY A,A,A;
! FIN;

  /* Softwareendkontakte der Mischer sind aktiv wenn die folgenden   */
  /* Zeilen auskommentiert werden           <<<                      */
  FOR I TO N_HZKR   REPEAT Z_HKMI(I)=0;   END;            /*    */
  FOR I TO N_BHKW   REPEAT Z_BHKWMI(I)=0; END;            /*    */
  FOR I TO N_KESSEL REPEAT Z_KESMI(I)=0;  END;            /*    */


  IF ZP_NOW>03:00:00 AND ZP_NOW<03:10:00 THEN
    /* Umschaltung auf Sommerzeit am letzten Sonntag im M„rz         */
    IF DA_MON==3 AND DA_WOTAG==7 AND DA_DAT+7>31 THEN
      Z_RTC=1000;
      AFTER 0.5 SEC RESUME;
      PUT 'CLOCKSET -T ',ZP_NOW + 1 HRS TO RTOS BY A,T(8);
      Z_RTC=0;
    FIN;
    /* Umschaltung auf Winterzeit am letzten Sonntag im Oktober wenn nicht schon passiert */
    IF NOT B_WINTER THEN
      IF   DA_MON==10 AND DA_WOTAG==7 AND DA_DAT+7>31  THEN
        B_WINTER='1'B;         /* Merker setzen */
        Z_RTC=1000;
        AFTER 0.5 SEC RESUME;
        PUT 'CLOCKSET -T ',ZP_NOW - 1 HRS TO RTOS BY A,T(8);
        Z_RTC=0;
      FIN;
    FIN;
    IF DA_MON<9 THEN
      B_WINTER='0'B;
    FIN;
  FIN;

  /* hier den Beginn der letzten Minute der jeweiligen 1/4h erkennen und 1/4h-Datenaufzeichnung einplanen */
  FIX1=ZF_MIN;   /* Merker */
  ZF_STD=ENTIER( (ZP_NOW-00:00:00)/ 1 HRS );
  ZF_MIN=ENTIER( (ZP_NOW-00:00:00)/ 1 MIN ) - 60*ZF_STD;
  IF FIX1==13 AND ZF_MIN==14 THEN
    Z_SCHNITT=6;
  FIN;
  IF FIX1==28 AND ZF_MIN==29 THEN
    Z_SCHNITT=6;
  FIN;
  IF FIX1==43 AND ZF_MIN==44 THEN
    Z_SCHNITT=6;
  FIN;
  IF FIX1==58 AND ZF_MIN==59 THEN
    Z_SCHNITT=6;
  FIN;

  F31=ZF_STD*ZK_STUND+ZF_MIN*ZK_MIN;
  ZF_SEK=ENTIER( 0.1*((ZP_NOW-00:00:00)/0.1 SEC-F31));
  /* Zehntelsekundenstand des Jahres                                 */
  ZT_JAHR=(Z_JAHRTAG-1)*ZK_TAG+F31+ENTIER((ZP_NOW-00:00:00)/0.1 SEC-F31);
  /* Zehnminutenstand der Woche                                      */
  Z_ZEHN=144*(DA_WOTAG-1)+ENTIER((ZP_NOW-00:00:00)/10 MIN)+1;
  IF Z_ZEHN<1 THEN
    Z_ZEHN=1;
  FIN;
  IF Z_ZEHN>1005 THEN
    Z_ZEHN=1005;
  FIN;
  Z_SEKTAG=ENTIER(((ZP_NOW-00:00:00)/1.0 SEC)-ZF_STD*3600(31))+ZF_STD*3600(31);

  Z_LZ=Z_LZ+1(31);      /* hier wird die kontinuierliche Steuerungs- */
                        /* laufzeit gez„hlt                          */

  B_TAKT1='1'B;
  B_TAKT2='0'B;
  B_TAKT3='0'B;
  B_TAKT4='0'B;
  B_TAKT5='0'B;
  B_TAKT10='0'B;
  B_TAKT15='0'B;
  B_TAKT20='0'B;
  B_TAKT30='0'B;
  B_TAKT60='0'B;
  IF Z_LZ REM 2(31) == 1(31) THEN
    B_TAKT2='1'B;
  FIN;
  IF Z_LZ REM 3(31) == 1(31) THEN
    B_TAKT3='1'B;
  FIN;
  IF Z_LZ REM 4(31) == 1(31) THEN
    B_TAKT4='1'B;
  FIN;
  IF Z_LZ REM 5(31) == 1(31) THEN                                      
    B_TAKT5='1'B;
  FIN;
  IF Z_LZ REM 10(31) == 1(31) THEN                                      
    B_TAKT10='1'B;
  FIN;
  IF Z_LZ REM 15(31) == 1(31) THEN                                      
    B_TAKT15='1'B;
  FIN;
  IF Z_LZ REM 20(31) == 1(31) THEN                                      
    B_TAKT20='1'B;
  FIN;
  IF Z_LZ REM 30(31) == 1(31) THEN                                      
    B_TAKT30='1'B;
  FIN;
  IF Z_LZ REM 60(31) == 1(31) THEN                                      
    B_TAKT60='1'B;
  FIN;


  IF B_TAKT60 THEN

    TC_ATTAU=(TC_ATTAU*60.0*FL_ATTAU+TC_AUSSEN)/(60.0*FL_ATTAU+1.0);      /* durchschn. AT berechnen */
    

    /* ESTRICHTROCKNUNG <<< */
    FOR I TO N_HZKR REPEAT
      IF F_ESTRICH(I,21) > 0.0 THEN
        F_ESTRICH(I,21)=F_ESTRICH(I,21)-1.0;
      FIN;
    END;

    B_LOOP='0'B;
    FOR K TO 1008 REPEAT
      IF K < 1006 AND K > 2 THEN 
        IF NOT B_ZONE1(4,K).BIT(12) THEN /* <<< Kontrolle Timer BHKW (60) */
          B_LOOP='1'B;
        FIN;
      FIN;
    END;
    FIX1=60;                                             /*    */
    IF B_LOOP THEN                            /* TIMER BHKW??  */
      IF NOT B_STOER(FIX1) THEN                          /*    */
        B_STOER(FIX1)='1'B;                              /*    */
        CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
      FIN;                                               /*    */
    ELSE                                                 /*    */
      B_STOER(FIX1)='0'B;                                /*    */
    FIN;                                                 /*    */

!   FL1=W_HKTH(1) FIT FL1;
!   MON_ZAEHL( 3,DA_MON)=FL1;                         !CALL I_MON('W„rme HK1 Neueland76     ','kWh  ', 3);
!   FL1=(W_BEDHT+W_BEDNT) FIT FL1;
!   MON_ZAEHL( 5,DA_MON)=FL1;                         !CALL I_MON('Wel Bedarf               ','kWh  ', 5);
!   FL1=(W_BEDHT+W_BEDNT) FIT FL1;
!   MON_ZAEHL( 5,DA_MON)=FL1;                         !CALL I_MON('Wel Bedarf               ','kWh  ', 5);
!   MON_ZAEHL( 6,DA_MON)=Z_ZAEHL(14)/FL_IMP(14)/2.0;  !CALL I_MON('Wel Bezug                ','kWh  ', 6);
!   MON_ZAEHL( 7,DA_MON)=Z_ZAEHL(13)/FL_IMP(13)/2.0;  !CALL I_MON('Wel Einspeisung          ','kWh  ', 7);
!   MON_ZAEHL( 1,DA_MON)=Z_ZAEHL(19)/FL_IMP(19)/2.0;  !CALL I_MON('Waerme Kessel            ','kWh  ', 1);
!   FL1=(W_BEDHT+W_BEDNT) FIT FL1;
!   MON_ZAEHL(10,DA_MON)=FL1;                         !CALL I_MON('Wel Bedarf               ','kWh  ',10);
!   FL1=W_HKTH(1) FIT FL1;
!   MON_ZAEHL( 8,DA_MON)=FL1;                         !CALL I_MON('Waerme WW1 Verbrauch     ','kWh  ', 8);
!   MON_ZAEHL(12,DA_MON)=Z_ZAEHL(12)/FL_IMP(12)/2.0;  !CALL I_MON('Wel Bedarf gesamt        ','kWh  ',12);
!   MON_ZAEHL(13,DA_MON)=Z_ZAEHL(10)/FL_IMP(10)/2.0;  !CALL I_MON('Wel Einspeisung          ','kWh  ',13);
!   MON_ZAEHL(14,DA_MON)=Z_ZAEHL( 9)/FL_IMP( 9)/2.0;  !CALL I_MON('Wel Bezug                ','kWh  ',14);
!   MON_ZAEHL(19,DA_MON)=Z_ZAEHL(11)/FL_IMP(11)/2.0;  !CALL I_MON('Wel Bedarf Energiez.     ','kWh  ',19);
!   MON_ZAEHL(20,DA_MON)=Z_ZAEHL(17)/FL_IMP(17)/2.0;  !CALL I_MON('HZG-Nachspeisung         ','l    ',20);
!   CALL MONZAEHL( 7,FL_BKWHGES(1)             ,ZT_JAHR);       !CALL I_MON('Wel BHKW1                ','kWh  ', 7);
!   CALL MONZAEHL( 8,FL_BKWHGESHZG(2)          ,ZT_JAHR);       !CALL I_MON('Wel BHKW2                ','kWh  ', 8);
!   CALL MONZAEHL( 9,FL_BLFZGES(1)             ,ZT_JAHR);       !CALL I_MON('BHKW1 Betriebsstunden    ','h    ', 9);
!   CALL MONZAEHL(10,FL_BLFZGES(2)             ,ZT_JAHR);       !CALL I_MON('BHKW2 Betriebsstunden    ','h    ',10);
!   CALL MONZAEHL(11,Z_KESLFZ(1)/3600.0        ,ZT_JAHR);       !CALL I_MON('Kessel1 Betriebsstunden  ','h    ',11);
!   CALL MONZAEHL(12,Z_KESLFZ(2)/3600.0        ,ZT_JAHR);       !CALL I_MON('Kessel2 Betriebsstunden  ','h    ',12);
!   CALL MONZAEHL(13,Z_KESLFZ(3)/3600.0        ,ZT_JAHR);       !CALL I_MON('Kessel3 Betriebsstunden  ','h    ',13);
 !  CALL MONZAEHL( 1,Z_ZAEHL(26)/FL_IMP(26)/2.0,ZT_JAHR);       !CALL I_MON('Waerme HK1 Kueche        ','kWh  ', 1);
 !  CALL MONZAEHL( 2,Z_ZAEHL(27)/FL_IMP(27)/2.0,ZT_JAHR);       !CALL I_MON('Waerme HK2 Klima Kueche  ','kWh  ', 2);
 !  CALL MONZAEHL( 3,Z_ZAEHL(28)/FL_IMP(28)/2.0,ZT_JAHR);       !CALL I_MON('Waerme HK3 West          ','kWh  ', 3);
 !  CALL MONZAEHL( 4,Z_ZAEHL(29)/FL_IMP(29)/2.0,ZT_JAHR);       !CALL I_MON('Waerme HK4 Flur          ','kWh  ', 4);
 !  CALL MONZAEHL( 5,Z_ZAEHL(30)/FL_IMP(30)/2.0,ZT_JAHR);       !CALL I_MON('Waerme HK5 Sued          ','kWh  ', 5);
 !  CALL MONZAEHL( 6,Z_ZAEHL(31)/FL_IMP(31)/2.0,ZT_JAHR);       !CALL I_MON('Waerme HK6 FBH           ','kWh  ', 6);
 !  CALL MONZAEHL( 7,Z_ZAEHL(32)/FL_IMP(32)/2.0,ZT_JAHR);       !CALL I_MON('Waerme WW Ladung         ','kWh  ', 7);
!   CALL MONZAEHL( 3,Z_ZAEHL(14)/FL_IMP(14)/2.0,ZT_JAHR);       !CALL I_MON('Wel Heizpatronen         ','kWh  ', 3);
!   CALL MONZAEHL( 4,Z_ZAEHL(16)/FL_IMP(16)/2.0,ZT_JAHR);       !CALL I_MON('Wel Bezug <- EVU         ','kWh  ', 4);
!   CALL MONZAEHL( 5,Z_ZAEHL(15)/FL_IMP(15)/2.0,ZT_JAHR);       !CALL I_MON('Wel Einspeisung -> EVU   ','kWh  ', 5);
!   CALL MONZAEHL( 6,(W_BEDHT+W_BEDNT)         ,ZT_JAHR);       !CALL I_MON('Wel Bedarf               ','kWh  ', 6);
!   CALL MONZAEHL( 7,Z_ZAEHL(13)/FL_IMP(13)/2.0,ZT_JAHR);       !CALL I_MON('Wel Photovoltaik         ','kWh  ', 7);
!   CALL MONZAEHL(13,Z_ZAEHL(21)/FL_IMP(21)/2.0,ZT_JAHR);       !CALL I_MON('HZG-Nachspeisung         ','l    ',13);
!   CALL MONZAEHL( 3,W_HKTH(1)                 ,ZT_JAHR);       !CALL I_MON('Waerme WW1 Kueche Verbr. ','kWh  ', 3);
!   CALL MONZAEHL( 9,Z_ZAEHL(10)/FL_IMP(10)/2.0,ZT_JAHR);       !CALL I_MON('Gas gesamt               ','m^3  ', 9);
!   CALL MONZAEHL(10,Z_ZAEHL( 9)/FL_IMP( 9)/2.0,ZT_JAHR);       !CALL I_MON('Gas BHKW                 ','m^3  ',10);
!   CALL MONZAEHL( 6,WQM_MBUS( 6)              ,ZT_MBUS( 6));   !CALL I_MON('Gas gesamt               ','kWh  ', 6);
!   CALL MONZAEHL( 7,WQM_MBUS( 7)              ,ZT_MBUS( 7));   !CALL I_MON('Gas BHKW1                ','kWh  ', 7);
!   CALL MONZAEHL( 8,WQM_MBUS( 8)              ,ZT_MBUS( 8));   !CALL I_MON('Gas BHKW2                ','kWh  ', 8);
!   CALL MONZAEHL(14,Z_ZAEHL(13)/FL_IMP(13)/2.0,ZT_JAHR);       !CALL I_MON('HZG-Nachspeisung         ','l    ',14);


    CALL MONZAEHL( 1,WTH_MBUS( 1)              ,ZT_MBUS( 1));   !CALL I_MON('Waerme BHKW              ','kWh  ', 1);
    CALL MONZAEHL( 2,WTH_MBUS( 2)              ,ZT_MBUS( 2));   !CALL I_MON('Waerme Holzkessel1       ','kWh  ', 2);
    CALL MONZAEHL( 3,WTH_MBUS( 3)              ,ZT_MBUS( 3));   !CALL I_MON('Waerme Holzkessel2       ','kWh  ', 3);
    CALL MONZAEHL( 4,WTH_MBUS( 4)              ,ZT_MBUS( 4));   !CALL I_MON('Waerme Biogaskessel      ','kWh  ', 4);
    CALL MONZAEHL( 5,WTH_MBUS( 5)              ,ZT_MBUS( 5));   !CALL I_MON('Waerme HK1 Nordtrasse    ','kWh  ', 5);
    CALL MONZAEHL( 6,WTH_MBUS( 6)              ,ZT_MBUS( 6));   !CALL I_MON('Waerme HK2 Westtrasse    ','kWh  ', 6);
    CALL MONZAEHL( 7,WTH_MBUS( 7)              ,ZT_MBUS( 7));   !CALL I_MON('Waerme HK3 Suedtrasse    ','kWh  ', 7);
    CALL MONZAEHL( 8,FL_BKWHGESHZG(1)          ,ZT_JAHR);       !CALL I_MON('Wel BHKW (ca.)           ','kWh  ', 8);
    CALL MONZAEHL( 9,FL_BLFZGESHZG(1)          ,ZT_JAHR);       !CALL I_MON('BHKW1 Betriebsstunden    ','h    ', 9);
    CALL MONZAEHL(10,Z_KESLFZ(1)/3600.0        ,ZT_JAHR);       !CALL I_MON('Holzkessel1 Betriebsst.  ','h    ',10);
    CALL MONZAEHL(11,Z_KESLFZ(2)/3600.0        ,ZT_JAHR);       !CALL I_MON('Holzkessel2 Betriebsst.  ','h    ',11);
    CALL MONZAEHL(12,Z_KESLFZ(3)/3600.0        ,ZT_JAHR);       !CALL I_MON('Biogaskessel Betriebsst. ','h    ',12);

    AT_MON(1,DA_MON)=AT_MON(1,DA_MON)+TC_AUSSEN;
    AT_MON(2,DA_MON)=AT_MON(2,DA_MON)+1.0;
    IF DA_MON == 11 THEN
      FOR I TO 99 REPEAT
        MON_ZAEHLJAN(I)=MON_ZAEHL(I,1);
      END;
      FOR I TO 99 REPEAT
        MON_ZAEHLJAN(I+100)=MON_ZAEHL(I,1)-MON_ZAEHL(I,12); /* z.B.: jan2007 - dez 2006(ist im nov2007 noch vorhanden) */
      END;
    FIN;



    IF DA_DAT==31 AND DA_MON==12 AND ZP_NOW>23:58:00 THEN /* gleich ist Jahreswechsel  */ 
      FOR I TO 99 REPEAT
        JAHR_ZAEHL(I,2)=JAHR_ZAEHL(I,1);                      /* Jahreszaehlerstände als Vorjahreszaehlerstaende merken  */
        JAHR_ZAEHL(I,3)=MON_ZAEHL(I,12);                      /* akt Zaehlerstaende merken  */
      END;  
    ELSE
      FOR I TO 99 REPEAT
        JAHR_ZAEHL(I,1)=MON_ZAEHL(I,DA_MON)-JAHR_ZAEHL(I,3);  /* Jahreszaehlerstaende berechnen  */
      END;  
    FIN;


!   /* GASBEDARF ZUR WÄRMEERZEUGUNG DER EINZELNEN MONATE */
!   FL55=0.0;
!   FOR I TO 12 REPEAT
!     IF I == 1 THEN                                                            /* Wel BHKW1+2 100% */
!       IF DA_MON < 12 THEN    /*            GAS gesamt                -           Stromerz. BHKWs * 1.144    */
!         WIRT_ZAEHL(1,I)=((MON_ZAEHL(16,I)-MON_ZAEHL(16,12))*FL_GASHO - (MON_ZAEHL(22,I)-MON_ZAEHL(22,12))*1.144);
!       FIN;
!     ELSE
!       IF I == DA_MON THEN
!         WIRT_ZAEHL(1,I)=((MON_ZAEHL(16,I)-MON_ZAEHL(16,I-1))*FL_GASHO - (MON_ZAEHL(22,I)-MON_ZAEHL(22,I-1))*1.144);
!       FIN;
!     FIN;
! !   IF I <= DA_MON THEN
!       FL55=FL55+WIRT_ZAEHL(1,I);
! !   FIN;
!   END;
!   WIRT_ZAEHL(1,13)=FL55;    
!
!   /* GASPROGNOSE ALTZUSTAND DER EINZELNEN MONATE */
!   FL55=0.0;
!   FOR I TO 12 REPEAT
!     FL55=FL55+WIRT_ZAEHL(2,I);
!   END;
!   WIRT_ZAEHL(2,13)=FL55;    
!
!   /* EINSPARUNG GAS DER EINZELNEN MONATE */
!   FL55=0.0;
!   FOR I TO 12 REPEAT
!     IF WIRT_ZAEHL(1,I) > 1.0 THEN
!       WIRT_ZAEHL(3,I)=(WIRT_ZAEHL(2,I)-WIRT_ZAEHL(1,I));
!     ELSE
!       WIRT_ZAEHL(3,I)=0.0;
!     FIN;
! !   IF I <= DA_MON THEN
!       FL55=FL55+WIRT_ZAEHL(3,I);
! !   FIN;
!   END;
!   WIRT_ZAEHL(3,13)=FL55;    
!
!   /* EINSPARUNG EURO DER EINZELNEN MONATE */
!   FL55=0.0;
!   FOR I TO 12 REPEAT
!     WIRT_ZAEHL(4,I)=WIRT_ZAEHL(3,I)*FL_GASCENTPROKWH*0.01;
! !   IF I <= DA_MON THEN
!       FL55=FL55+WIRT_ZAEHL(4,I);
! !   FIN;
!   END;
!   WIRT_ZAEHL(4,13)=FL55;    


  FIN;    


  /********Terminbearbeitung******************************************/

  /*-------Termine mit Wiedereinplanung------------------------------*/

   /* M-Bus Auslesung */
   Z_MBUSLES=Z_MBUSLES+1;
   IF Z_MBUSLES > ZF_MBUSLES THEN
     B_MBUSLES='1'B;
     Z_MBUSLES=0;
     IF ZF_MBUSLES < 5 THEN  ZF_MBUSLES=5;  FIN;
   FIN;
   
   /*  w”chentliche Zeitkorrektur                            */
!  IF DA_WOTAG==2 THEN  /* Dienstags um 9 */
!    IF ZP_NOW > 09:00:00 AND ZP_NOW < 09:01:01 THEN
!      IF Z_RTC2 < 10 THEN 
!        IF Z_KALSEC > 0 OR Z_KALSEC < 0 THEN
!          ZD1=Z_KALSEC * 1 SEC;
!          Z_RTC=1000;
!          AFTER 0.5 SEC RESUME;
!          PUT 'CLOCKSET -T ',ZP_NOW + ZD1 TO RTOS BY A,T(12,3);
!          Z_RTC=0;
!        FIN;
!        Z_RTC2=1000;
!      FIN;
!    FIN;    
!  ELSE
!    Z_RTC2=0;
!  FIN;

  /*----------Aktionen ohne Wiedereinplanung-------------------------*/

  /*  TEIN abgelaufen ?                                 */
   IF Z_TEIN > 0 THEN
     Z_TEIN=Z_TEIN-1;
     IF Z_TEIN < 1 THEN
       PE_THERM=PE_BSOLLGES; /* Thermische Solleist. vorbesetzen */
     FIN;
   FIN;

  /* Ende der Leistungsregelungssperre ?                    */
   IF Z_LRSPERR > 0 THEN
     Z_LRSPERR=Z_LRSPERR-1;
     IF Z_LRSPERR < 1 THEN
       PE_THERM=PE_BSOLLGES; /* Thermische Solleist. vorbesetzen */
     FIN;
   FIN;

  /* Mindestauszeit ?                                */
   IF Z_TMA > 0 THEN
     Z_TMA=Z_TMA-1;
   FIN;


  /*-------------direkte Einplanungen nach Uhrzeit------------------*/
  /* Pumpenschonung                                         */
   ZP_PUMPSCH=06:00:00;
   IF ZP_NOW>ZP_PUMPSCH AND ZP_NOW<ZP_PUMPSCH+1 MIN THEN
     B_PUMPSCH='1'B;
   ELSE
     B_PUMPSCH='0'B;
   FIN;

  /* Erfassung der Systemzust„nde beendet                            */


  /*******************************************************************/
  /* Aktionen im Grundtakt:                                          */
  /*******************************************************************/

  /*-----------------------------------------------------------------*/
  /* BHKW-Status erfassen: ( Laufzustand, St”rungen, Pumpen)         */
  Z_BAKT=0;     /* Z„hler fuer Anzahl der aktiven BHKW ruecksetzen     */
  Z_BANFORD=0;  /* Anforderungsz„hler zuruecksetzen                   */
  Z_BLZMIN=10000(31); /* mit hohem Wert vorbesetzen                  */

  FOR I TO N_BHKW REPEAT /* Schleife ueber alle BHKW:                 */


    /* BHKW Thermostat   <<<                                         */
    IF FS_LBHKW(I)==3 THEN  /* 3. BHKW */
      IF    TC_BHZGV(I) > TC_BHZGVO(1)-2.5 THEN                       /*   */
        Z_BTHERMVL(I)=120;                                           /*   */
      FIN;
      IF    TC_BHZGR(I) > TC_BHZGRO(1)-2.5 THEN                   /*   */
        Z_BTHERMRL(I)=120;                                          /*   */
      FIN;                                                        /*   */
    ELSE /*         */
      IF FS_LBHKW(I)==2 THEN  /* 2. BHKW */
        IF    TC_BHZGV(I) > TC_BHZGVO(1)-1.5 THEN                       /*   */
          Z_BTHERMVL(I)=120;                                           /*   */
        FIN;
        IF    TC_BHZGR(I) > TC_BHZGRO(1)-1.5 THEN                   /*   */
          Z_BTHERMRL(I)=120;                                          /*   */
        FIN;                                                        /*   */
      ELSE /* 1. BHKW */
        IF    TC_BHZGV(I) > TC_BHZGVO(1) THEN                       /*   */
          Z_BTHERMVL(I)=120;                                           /*   */
        FIN;
        IF    TC_BHZGR(I) > TC_BHZGRO(1) THEN                       /*   */
          Z_BTHERMRL(I)=120;                                          /*   */
        FIN;                                                        /*   */
      FIN;
    FIN;
                                                                /*   */
                                                                /*   */
    IF TC_BHZGV(I) < TC_BHZGVO(1)-2.5 THEN                      /*   */
      IF Z_BTHERMVL(I) > 0 THEN  Z_BTHERMVL(I)=Z_BTHERMVL(I)-1;  FIN;     /*   */
    FIN;                                                        /*   */
                                                                /*   */
    IF TC_BHZGR(I) < TC_BHZGRO(1)-2.5 THEN                      /*   */
      IF Z_BTHERMRL(I) > 0 THEN  Z_BTHERMRL(I)=Z_BTHERMRL(I)-1;  FIN;     /*   */
    FIN;                                                        /*   */
                                                                /*   */
!   FOR K TO N_BHKW REPEAT                                      /*   */
!     Z_BTHERMVL(K)=0;                                           /*   */
!     Z_BTHERMRL(K)=0;                                           /*   */
!   END;                                                        /*   */

  ! IF B_BL(I) OR Z_SVS(I) > 0 THEN /* Falls das BHKW l„uft oder Startet */
    IF (B_BL(I) OR Z_SVS(I) > 0) AND Z_LZ > 20(31) THEN /* Falls das BHKW l„uft oder Startet */
      IF Z_SVS(I) > 0 THEN
        Z_SVS(I)=Z_SVS(I)-1;
      FIN;
      Z_BAKT=Z_BAKT+1;     /* Z„hler aktive BHKW erh”hen             */
      Z_LETZT=I;           /* Nr. I ist der potentielle letzte WE    */
      Z_BLZ(I)=Z_BLZ(I)+1(31); /* kontinuierliche Laufzeit erh”hen.  */
      Z_BLAUFZ(I,1)=Z_BLZ(I);                /*  Laufzeit merken      */
      ZP_BAUS(I,1)=ZP_NOW;              /* Abschaltzeitp. merken      */
      DAT_BAUS(I,1)=DA_DAT;             /* Abschaltdatum  merken      */
      Z_BLZVIERT(I)=Z_BLZVIERT(I)+1;
      IF B_BL(I) THEN
        B_BSTOER(I)='0'B;   /* laufendes BHKW ist nicht gestoert      */
        FL_BLFZGESHZG(I)=FL_BLFZGESHZG(I)+0.000277777(55);  
        FL_BKWHGESHZG(I)=FL_BKWHGESHZG(I)+PE_BIST(I)*0.000277777(55);
      FIN;
      IF Z_BLZ(I)<Z_BLZMIN THEN
        Z_BLZMIN=Z_BLZ(I);
      FIN;

      IF Z_BLZ(I) == 1(31) THEN   /* BHKW STARTS ZAEHLEN  */
        Z_START24=Z_START24+1;
      FIN;

    ELSE

      /* wenn BHKW gerade noch lief und Umsortierung abgeschlossen   */
      IF Z_BLZ(I) > 0(31) OR Z_BLAUFZ(I,1) > 0(31) THEN
        FOR K FROM 12 BY -1 TO 1 REPEAT
          /* Laufzeiten umsortieren                                  */
          Z_BLAUFZ(I,K+1)=Z_BLAUFZ(I,K);
          /* Abschaltzeitp. umsortieren                              */
          ZP_BAUS(I,K+1)=ZP_BAUS(I,K);
          /* Abschaltdatum umsortieren                               */
          DAT_BAUS(I,K+1)=DAT_BAUS(I,K);
          /* <<<                                                     */
          STR_AUS(I,K+1)=STR_AUS(I,K);
        END;
        Z_BLAUFZ(I,1)=0(31);            /*                           */
        Z_TCKLEIN=0;     /* immer wenn eins AUS zuruecksetzen        */
      FIN;

      /* lief das BHKW laenger als 20s                               */
      IF Z_BLZ(I) > 20(31) THEN
        Z_BPNL(I)=ZF_BPNL(I); /* Pumpennachlauf aktivieren           */
      FIN;

 /*   Thermostat Heizungssteuerung oder interner BHKW-Thermostat */
      IF Z_BLZ(I) > 0(31) THEN      
     !  IF ((Z_BTHERMVL(I) > 1 OR Z_BTHERMRL(I) > 1) AND Z_BLZ(I) > 20)
     !  OR (TC_BHZGR(I) > 63.0 AND Z_BLZ(I) >= 240(31))
     !  THEN                            /* Stoerung wegen */
     !    IF (Z_BTHERMVL(I) > 1 OR Z_BTHERMRL(I) > 1) AND Z_BLZ(I) > 20 THEN
     !      IF Z_BTHERMVL(I) > 1 THEN
     !        STR_AUS(I,2)='Therm. HZG-ST VL';
     !      ELSE
     !        STR_AUS(I,2)='Therm. HZG-ST RL';
     !      FIN;
     !    ELSE
     !      STR_AUS(I,2)='BHKW-Thermost. ?';
     !    FIN;
     !    IF TC_VIST > TC_VSOLL-8.0 THEN  /* wenn einigermassen warm genug */
     !      B_BEIN(I)='0'B;               /* Anforderung zuruecknehmen   */
     !      Z_SVS(I)=0;
     !    FIN;
  !       IF Z_KAKT>0 THEN              /* wenn jetzt noch Kessel      */
  !         TO Z_KAKT REPEAT            /* eingeschaltet, dann         */
  !           CALL SCH_KAB;             /* Kessel abschalten           */
  !         END;
  !       FIN;
     !  ELSE
          IF B_BEIN(I) THEN
            STR_AUS(I,2)='BHKW intern     ';
          ELSE
            STR_AUS(I,2)='HZG-ST AUS      ';
          FIN;
     !  FIN;
      FIN;
      
      Z_BLZ(I)=0(31); /* Z„hler fuer n„chsten Durchlauf zuruecksetzen*/

    FIN;

    IF B_BERLAUBT2(I) AND B_ABSEIN(60) THEN  /* <<< */
      IF B_BEIN(I) THEN                                     
        Z_BANFORD=Z_BANFORD+1;   /* Anforderung feststellen          */
      FIN;
    ELSE
      B_BEIN(I)='0'B;            /* Anforderung trotzdem erhoehen um */
      Z_BANFORD=Z_BANFORD+1;     /* weitere Waermeerzeuger nicht zu  */
    FIN;                         /* behindern                        */

  END; /* of 1 - N_BHKW                                              */
  Z_BAKTLR=Z_BAKT+1;

  /* --------------------------------------------------------------- */
  /* St”rungen auswerten und Pumpen schalten                         */
  /* --------------------------------------------------------------- */
  X_O=1;
  B_LOOP='1'B;
  WHILE B_LOOP REPEAT /* Schleife ueber alle BHKW:                    */

    /* Falls das BHKW gest”rt oder nicht bereit ist                  */
    IF B_BSTOER(X_O) OR NOT B_BBEREIT(X_O) OR NOT B_BERLAUBT2(X_O) THEN

      FOR I TO N_BHKW REPEAT
        /* wenn aktuelles BHKW sp„teren Rang als das gest”rte hat    */
        /* und nicht gest”rt ist, dann tauschen die beiden BHKWs     */
        /* die Rangfolge                                             */ 
  !     IF FS_LBHKW(I) > FS_LBHKW(X_O)                                 
  !        AND NOT B_BSTOER(I) AND B_BBEREIT(I) AND B_BERLAUBT2(I) THEN 
  !       X_M=FS_LBHKW(I);                                             
  !       FS_LBHKW(I)=FS_LBHKW(X_O);                                   
  !       FS_LBHKW(X_O)=X_M;                                           
  !     FIN;                                                           
      END;

    FIN;

    IF Z_BPNL(X_O) > 0 THEN
      Z_BPNL(X_O)=Z_BPNL(X_O)-1;
    FIN;
    /* Pumpe einschalten, wenn einer der folgenden F„lle erfuellt ist:*/
    B_PMP= B_BL(X_O)               /* Leistung gr”~er 0.7 kW         */
        OR Z_BPNL(X_O)>0           /* Pumpennachlauf ist aktiv       */
        OR Z_SVS(X_O)>0            /* Startversuch                   */
        OR B_PUMPSCH;              /* Pumpenschonung aktiviert       */


    B_BPMP(X_O)=B_PMP;                       /* Wert zuweisen        */

    IF B_LOOP THEN     /* nur wenn nicht umsortiert wurde            */
      X_O=X_O+1;
    FIN;

    IF X_O>N_BHKW THEN                   /* wenn alle BHKW behandelt */
      B_LOOP='0'B;                       /* dann Schleifenausstieg   */
    ELSE
      B_LOOP='1'B;
    FIN;

  END; /* of 1 - N_BHKW                                              */

  /*-----------------------------------------------------------------*/
  /* Kesselstatus auswerten:                                         */
  Z_KAKT=0;     /* Z„hler fuer aktiven Kessel zuruecksetzen            */
  Z_KANFORD=0;  /* Anforderungsz„hler zuruecksetzen                   */
  Z_KLZMIN=10000(31); /* mit hohem Wert vorbesetzen                  */

  FOR I TO N_KESSEL REPEAT /* Schleife ueber alle Kessel              */
    IF B_KEIN(I) THEN      /* Falls der Kessel l„uft:                */
      Z_KANFORD=Z_KANFORD+1; /* Anforderungsz„hler erh”hen           */
      Z_LETZT=I+N_BHKW;    /* Nr. I ist der potentielle letzte WE    */
      Z_KLZ(I)=Z_KLZ(I)+1(31); /* kontinuierliche Laufzeit erh”hen   */
      Z_KLAUFZ(I,1)=Z_KLZ(I);               /*  Laufzeit merken      */
      ZP_KAUS(I,1)=NOW;                /* Abschaltzeitp. merken      */
      DAT_KAUS(I,1)=DA_DAT;            /* Abschaltdatum  merken      */
   /* Bei 2-stufigen Kesseln auf Index+5 arbeiten  */
   !  IF B_KST2(I) THEN  /* <<< 2. Stufe */
   !    Z_KLZ(I+5)=Z_KLZ(I+5)+1(31); /* kontinuierliche Laufzeit erh”hen   */
   !    Z_KLAUFZ(I+5,1)=Z_KLZ(I+5);               /*  Laufzeit merken      */
   !    ZP_KAUS(I+5,1)=NOW;                /* Abschaltzeitp. merken      */
   !    DAT_KAUS(I+5,1)=DA_DAT;            /* Abschaltdatum  merken      */
   !  FIN;                                 /* */
      IF Z_KLZ(I) < Z_KLZMIN THEN  /* kuerzeste Kessellaufzeit        */
        Z_KLZMIN=Z_KLZ(I);         /* herausfinden und merken        */
      FIN;
      IF B_KL(I) THEN
        Z_KAKT=Z_KAKT+1;     /* Z„hler aktive Kessel erh”hen           */
        IF Z_KL(I) < 30000 THEN
          Z_KL(I)=Z_KL(I)+1;
        FIN;
      ELSE
        Z_KL(I)=0;
      FIN;
      IF NOT B_KERLAUBT(I) THEN  /* <<< */
        B_KEIN(I)='0'B;
      FIN;
    ELSE
      Z_KL(I)=0;
    FIN;

    IF (Z_KLZ(I) > 0(31) OR Z_KLAUFZ(I,1) > 0(31)) AND NOT B_KEIN(I) THEN
      FOR K FROM 12 BY -1 TO 1 REPEAT
        /* Laufzeiten umsortieren                                    */
        Z_KLAUFZ(I,K+1)=Z_KLAUFZ(I,K);
        /* Abschaltzeitp. umsortieren                                */
        ZP_KAUS(I,K+1)=ZP_KAUS(I,K);
        /* Abschaltdatum umsortieren                                 */
        DAT_KAUS(I,K+1)=DAT_KAUS(I,K);
      END;
      Z_KLZ(I)=0;
      Z_KLAUFZ(I,1)=0(31);  
      Z_KPNL(I)=ZF_KPNL(I); /* Pumpennachlauf aktivieren             */
    FIN;

 /* Bei 2-stufigen Kesseln auf Index+5 arbeiten  */
 !  IF (Z_KLZ(I+5) > 0(31) OR Z_KLAUFZ(I+5,1) > 0(31)) AND NOT B_KST2(I) THEN
 !    FOR K FROM 12 BY -1 TO 1 REPEAT
 !      /* Laufzeiten umsortieren                                    */
 !      Z_KLAUFZ(I+5,K+1)=Z_KLAUFZ(I+5,K);
 !      /* Abschaltzeitp. umsortieren                                */
 !      ZP_KAUS(I+5,K+1)=ZP_KAUS(I+5,K);
 !      /* Abschaltdatum umsortieren                                 */
 !      DAT_KAUS(I+5,K+1)=DAT_KAUS(I+5,K);
 !    END;
 !    Z_KLZ(I+5)=0;
 !    Z_KLAUFZ(I+5,1)=0(31);  
 !  FIN;


    IF Z_KPNL(I) > 0 THEN
      Z_KPNL(I)=Z_KPNL(I)-1;
    FIN;
    /* Pumpe einschalten, wenn einer der folgenden F„lle erfuellt ist:*/
    B_PMP=   B_KEIN(I)           /* Kessel eingeschaltet             */
          OR Z_KPNL(I)>0         /* Pumpennachlauf ist aktiv         */
          OR B_PUMPSCH;          /* Pumpenschonung aktiviert         */


    IF B_PMP THEN            
      B_KPMP(I)='1'B;
    ELSE
      B_KPMP(I)='0'B;
    FIN;


  END; /* of 1 - N_KESSEL                                            */


  /*******************************************************************/
  /* Systemdatenkorrektur (alle 10s)                                 */
  /*******************************************************************/
  IF B_TAKT10 THEN

!   IF PT_SCHNITT < (PE_BMAXMOGL/N_BHKW)*(PT_GRUND+PT_FAKTOR+0.3) THEN
!     ZF_TEIN=ROUND(((PE_BMAXMOGL/N_BHKW)*
!                     (PT_GRUND+PT_FAKTOR+0.4)-PT_SCHNITT)*120);
!   ELSE                                             /* ZF_TEIN */
      ZF_TEIN=120;
!   FIN;
!   IF ZF_TEIN>600 OR ZF_TEIN<0 THEN ZF_TEIN=600; FIN;

    IF PT_SCHNITT<(PE_BMAXMOGL*(PT_GRUND+PT_FAKTOR+0.3)) THEN
      ZF_HOCH=300;
    ELSE                                              /* ZF_HOCH  */
      ZF_HOCH=40;
    FIN;

    IF PT_SCHNITT < (PE_MAX*(PT_GRUND+PT_FAKTOR+0.3)) THEN
      ZF_RUNT=120;                                    /* ZF_RUNT  */
    ELSE
      ZF_RUNT=60;
    FIN;
!   ZF_HOCH=10;  /* <<< */
!   ZF_RUNT=10;

    IF Z_LZ < 500(31) THEN 
      ZF_HOCH=2; 
      ZF_RUNT=2; 
    FIN;  

    IF PT_SCHNITT<PE_MAX*(PT_GRUND+PT_FAKTOR-0.7) THEN
      PE_STUFE=PE_MAX*0.0005;                         /* PE_STUFE */
    ELSE
      PE_STUFE=(PT_SCHNITT**2)*0.00001+0.001;         /* PE_STUFE */
    FIN;

    IF PT_AKT<1.0 THEN
      X_A=1.0;
    ELSE
      X_A=PT_AKT;
    FIN;

    IF X_A > PT_SCHNITT THEN
      TD_STUFEA=0.09*X_A/PT_SCHNITT;                  /* TD_STUFEA */
      TD_STUFEB=0.07*PT_SCHNITT/X_A;                  /* TD_STUFEB */
    ELSE
      TD_STUFEA=0.07*PT_SCHNITT/X_A;                  /* TD_STUFEA */
      TD_STUFEB=0.09*X_A/PT_SCHNITT;                  /* TD_STUFEB */
    FIN;

    IF TD_STUFEA>0.3 THEN
      TD_STUFEA=0.3;
    FIN;
    IF TD_STUFEA<0.03 THEN
      TD_STUFEA=0.03;
    FIN;
    IF TD_STUFEB>0.3 THEN
      TD_STUFEB=0.3;
    FIN;
    IF TD_STUFEB<0.03 THEN
      TD_STUFEB=0.03;
    FIN;                  


    X_A=PT_SCHNITT;
    IF X_A<0.5*PE_MAX THEN
      X_A=0.5*PE_MAX;
    FIN;

/*  ZF_NKE=ROUND((PE_MAX*PE_MAX*PE_MAX*500)/(EXP(3.5*LN(X_A+0.01)))); */
    ZF_NKE=ROUND((PE_MAX*PE_MAX*PE_MAX*(PT_GRUND+PT_FAKTOR)*213)/
                 (EXP(3.5*LN(X_A+0.01))));

    CALL FIXGRENZ(20,3,ZF_NKE);  

/*  ZF_LMAX=ROUND((PE_MAX*PE_MAX*PE_MAX*500)/(EXP(3.1*LN(X_A+0.01)))); */
    ZF_LMAX=ROUND((PE_MAX*PE_MAX*PE_MAX*(PT_GRUND+PT_FAKTOR)*213)/
                  (EXP(3.1*LN(X_A+0.01))));
    CALL FIXGRENZ(80,10,ZF_LMAX);  

    IF B_BWDRIGG THEN
      ZD_EIN=25 MIN;                                 /* ZD_EIN   */
    ELSE
      ZD_EIN=0 MIN;
    FIN;

    IF N_BHKW < 1 THEN
      X_A=20.0;
    ELSE
      X_A=1.0;
    FIN;
    FOR I TO N_BHKW REPEAT
      X_A=X_A+PE_MAXBHKW(I)*(PT_GRUND+PT_FAKTOR);
    END;
    FOR I TO N_KESSEL REPEAT
      X_A=X_A+PT_KES(I);
    END;

    IF PT_SCHNITT > PE_BMAXMOGL THEN
      ZD_VOR=ROUND(100.0*PT_SCHNITT/X_A)*40 SEC+ZD_EIN;  /* ZD_VOR   */
    ELSE
      ZD_VOR=600 SEC;
    FIN;

    IF ZD_VOR>70 MIN THEN
      ZD_VOR=70 MIN;
    FIN;

    ZF_NBA=8;                                        /* ZF_NBA (80s)  */

    IF PT_SCHNITT < (PE_MAX*(PT_GRUND+PT_FAKTOR)) THEN
      ZF_NBE=10;
    ELSE                                             /* ZF_NBE   */
      ZF_NBE=4;
    FIN;

    ZF_LKMAX=ROUND(30*PT_AKT/PT_SCHNITT);            /* ZF_LKMAX */
    CALL FIXGRENZ(60,20,ZF_LKMAX);  

    TD_MAX=10.0;                                     /* TD_MAX   */

    ZF_SOLLST=900;                                   /* ZF_SOLLST =15MIN */

    IF PT_SCHNITT < PT_AKT THEN
      ZF_LRSPERR=180;
    ELSE                                             /* ZF_LRSPERR */
      ZF_LRSPERR=360;
    FIN;

    IF PT_SCHNITT < PE_MAX * 2.0 THEN
      ZF_TMA=480;
    ELSE                                             /* ZF_TMA    */
      ZF_TMA=180;
    FIN;

    FOR I TO 48 REPEAT
      IF Z_ZAEHL(I) < 0(31) THEN 
        Z_ZAEHL(I)=0(31);
        Z_ZAEHLMERK(I)=0(31);
      FIN;
    END;    

    IF Z_BETRIEB==2 THEN     /* Betrieb der BHKW nach Strombedarf    */
      ZF_LMAX=10;            /* restliche W„rme liefern die Kessel   */
      ZF_NKE=2;
      ZF_TEIN=10;
      ZF_TMA=180;
    FIN;

    /* falls die Speicheraustrittstemp viel zu klein wird, dann die Grenzen */
    /* fr die Zuschaltung weiterer W„rmeerzeuger herabsetzen   <<<         */
    IF Z_BWKALT > 100 THEN
      ZF_LMAX=10;            
      ZF_NKE=2;
      ZF_TEIN=10;
      ZF_TMA=180;
      PE_STUFE=(PT_SCHNITT**2)*0.0001+0.005;       
      TD_STUFEA=0.3;
      TD_STUFEB=0.3;
      Z_TEIN=0;
    FIN;


    X_A=0.0;
    X_B=0.0;
    X_C=0.0;
    FOR I TO 12 REPEAT
      IF PE_STRMAX(I)>X_A THEN
        X_A=PE_STRMAX(I);
        X_O=I;
      FIN;
    END;
    FOR I TO 12 REPEAT
      IF PE_STRMAX(I)>X_B AND I/=X_O THEN
        X_B=PE_STRMAX(I);
        X_M=I;
      FIN;
    END;
    FOR I TO 12 REPEAT
      IF PE_STRMAX(I)>X_C AND I/=X_O AND I/=X_M THEN
        X_C=PE_STRMAX(I);
      FIN;
    END;

  FIN; /* Ende der Systemdatenkorrektur                              */

  /*******************************************************************/
  /* T HAUPT Routinen                                                */
  /*******************************************************************/
  IF B_TAKT10 THEN

    IF TC_VIST < TC_VSOLL-1.0 THEN
      IF Z_TCKLEIN < 2000 THEN
        Z_TCKLEIN=Z_TCKLEIN+1;
      FIN;
    ELSE
      IF Z_TCKLEIN > 0 THEN
        Z_TCKLEIN=Z_TCKLEIN-2;
      FIN;
    FIN;

    PT_AKT=0.0;
    PT_KAKT=0.0;
    PT_BHKWMOEG=0.0;
                          /* thermische BHKW-Leistung aufintegrieren */
 /* PE_BGES=0.0;    <<<  */         
    PE_BMAXMOGL=0.0;
    PE_MAX=0.01;
    PE_MIN=0.0;
    FOR I TO N_BHKW REPEAT
      IF NOT B_BSTOER(I) AND B_BBEREIT(I) AND B_BERLAUBT2(I) THEN
        PE_BMAXMOGL=PE_BMAXMOGL+PE_MAXBHKW(I);
      FIN;
      IF B_BL(I) THEN
        PE_MAX=PE_MAX+PE_MAXBHKW(I);
        PE_MIN=PE_MIN+PE_MINBHKW(I);
        PT_AKT=PT_AKT+PT_GRUND*PE_MAXBHKW(I)+PT_FAKTOR*PE_BIST(I);
        PT_BHKWMOEG=PT_BHKWMOEG+PT_GRUND*PE_MAXBHKW(I)+PT_FAKTOR*PE_MAXBHKW(I);
      FIN;
    END;
    
    IF Z_BAKT < 1 THEN
      PE_RMIN=0.0;
    ELSE
      IF Z_BAKT < 2 THEN
        PE_RMIN=PE_RMIN1B;
      ELSE
        PE_RMIN=Z_BAKT*PE_MAX/(Z_BAKT+2)-1.0;
      FIN;
    FIN;

    FOR I TO N_KESSEL REPEAT                                    
!     /* an dieser Stelle die Freiblaszeit des Kessels eingeben,     */
!     /* wenn bekannt. Sonst sch„tzen    <<<                         */
!     /* wenn Kessel angefordert und Laufzeit > Freiblaszeit         */
!     IF B_KEIN(I) AND Z_KLZ(I) > 20 THEN     
!     IF B_KEIN(I) AND B_KL(I) THEN  /* <<< */
      IF B_KL(I) THEN  /* <<< */
!!      IF I >1 THEN
!!                  /* thermische Kessel-Leistung dazuintegrieren    */
!  !      PT_KESAKT(I)=0.3*PT_KES(I)+Z_PKES(I)/ZF_KSTELL(I)*0.7*PT_KES(I); /* */
!         PT_KESAKT(I)=0.3*PT_KES(I)+Z_KTHERM(I)/ZF_KSTELL(I)*0.7*PT_KES(I); /* */
!!        PT_KESAKT(I)=0.30*PT_KES(I)+PT_KSOLL(I)/100.0*0.70*PT_KES(I); /* */
!!        PT_KESAKT(I)=(0.2+X_AAUS(21)*0.008)*PT_KES(I); /* <<< */
!!        IF 0.2*PT_KES(I)+PT_KSOLL(I)/100.0*0.80*PT_KES(I) > PT_KESAKT(I) THEN
!!          PT_KESAKT(I)=0.2*PT_KES(I)+PT_KSOLL(I)/100.0*0.80*PT_KES(I);
!!        FIN;
          IF I==1 THEN                                                         /* Holzkessel1 */
      !     IF PTH_MBUS( 2) > 15.0 AND ZT_MBUS( 2) > ZT_JAHR - 12000(31) THEN  /* <<< Rueckmeldung */
      !       PT_KESAKT(I)=PTH_MBUS( 2); /* */
      !     ELSE
      !       PT_KESAKT(I)=PT_KES(I)*0.01*X_AAUS( 1); /* */
      !       PT_KESAKT(I)=0.30*PT_KES(I)+PT_KSOLL(I)/100.0*0.70*PT_KES(I); /* */
              PT_KESAKT(I)=PT_KESAKT(8);                                    /* */
      !     FIN;
            PT_KESSOLL(I)=0.01*X_AAUS( 1);
          FIN;
          IF I==2 THEN                                                         /* Holzkessel2 */
      !     IF PTH_MBUS( 3) > 15.0 AND ZT_MBUS( 3) > ZT_JAHR - 12000(31) THEN  /* <<< Rueckmeldung */
      !       PT_KESAKT(I)=PTH_MBUS( 3); /* */
      !     ELSE
      !       PT_KESAKT(I)=PT_KES(I)*0.01*X_AAUS( 1); /* */
      !       PT_KESAKT(I)=0.30*PT_KES(I)+PT_KSOLL(I)/100.0*0.70*PT_KES(I); /* */
              PT_KESAKT(I)=PT_KESAKT(9);                                    /* */
      !     FIN;
            PT_KESSOLL(I)=0.01*X_AAUS( 3);
          FIN;
          IF I==3 THEN                                                         /* Biogaskessel */
      !     IF PTH_MBUS( 4) > 15.0 AND ZT_MBUS( 4) > ZT_JAHR - 12000(31) THEN  /* <<< Rueckmeldung */
      !       PT_KESAKT(I)=PTH_MBUS( 4); /* */
      !     ELSE
      !       PT_KESAKT(I)=PT_KES(I)*0.01*X_AAUS( 1); /* */
      !       PT_KESAKT(I)=0.30*PT_KES(I)+PT_KSOLL(I)/100.0*0.70*PT_KES(I); /* */
              PT_KESAKT(I)=0.3*PT_KES(I)+Z_KTHERM(I)/ZF_KSTELL(I)*0.7*PT_KES(I); /* */
      !    FIN;
            PT_KESSOLL(I)=0.30*PT_KES(I)+PT_KSOLL(I)/100.0*0.70*PT_KES(I);
          FIN;
       !  IF I==2 THEN  
       !    IF X_AEIN(30) > 15.0 THEN  /* <<< Rueckmeldung */
       !      PT_KESAKT(I)=PT_KES(I)*0.01*X_AEIN(30); /* */
       !    ELSE
       !      PT_KESAKT(I)=PT_KES(I)*0.01*X_AAUS( 2); /* */
       !    FIN;
       !    PT_KESSOLL(I)=0.01*X_AAUS( 2);
       !  FIN;
       !  IF I==3 THEN  
       !    IF X_AEIN(30) > 15.0 THEN  /* <<< Rueckmeldung */
       !      PT_KESAKT(I)=PT_KES(I)*0.01*X_AEIN(30); /* */
       !    ELSE
       !      PT_KESAKT(I)=PT_KES(I)*0.01*X_AAUS( 3); /* */
       !    FIN;
       !  FIN;
!      !  IF I==4 AND X_AEIN(29) > 15.0 THEN  /* <<< Rueckmeldung */
!      !    PT_KESAKT(I)=PT_KES(I)*0.01*X_AEIN(29); /* */
!      !  ELSE
!      !    PT_KESAKT(I)=PT_KES(I)*0.01*X_AAUS( 5); /* */
!      !  FIN;
!      !  IF B_KST2(I) AND B_KL(I+2) THEN 
!!          PT_KESAKT(I)=PT_KES(I);        /* */
!         /* Bei 2-stufigen Kesseln auf Index+5 arbeiten */
!      !    Z_KESLFZ(I+5)=Z_KESLFZ(I+5)+10(31);  /* <<< */
!      !  ELSE
!      !    PT_KESAKT(I)=PT_KES(I)*0.6;        /* */
!      !  FIN; 
!!        PT_KESAKT(I)=X_AAUS(I)*0.01*PT_KES(I); /* <<< */
!!      ELSE
!!        PT_KESAKT(I)=0.30*PT_KES(I)+PT_KSOLL(I)/100.0*0.70*PT_KES(I); /* */
!!        PT_KESAKT(I)=0.10*PT_KES(I)+PT_KSOLL(I)/100.0*0.90*PT_KES(I); /* */
!!        PT_KESAKT(I)=PT_KES(I);        /* */
!!      FIN;
        PT_AKT=PT_AKT+PT_KESAKT(I);
        PT_KAKT=PT_KAKT+PT_KESAKT(I);
        PT_KVIERTEL=PT_KVIERTEL+PT_KESAKT(I);
        IF B_KEIN(I) THEN
          Z_KESLFZ(I)=Z_KESLFZ(I)+10(31);  /* <<< */
        FIN;
      ELSE
        IF B_KEIN(I) THEN
          IF I==1 THEN  
            PT_KESSOLL(I)=0.01*X_AAUS( 1);
          FIN;
          IF I==2 THEN  
            PT_KESSOLL(I)=0.01*X_AAUS( 2);
          FIN;
        ELSE
          PT_KESSOLL(I)=0.0;
        FIN;
        PT_KESAKT(I)=0.0;
      FIN;
    END;

!   IF NOT B_STOER(52) THEN  /* CAN UST OK! */
!     PT_KESAKT(1)=X_AEINEXT(61,1);
!     PT_KESAKT(2)=X_AEINEXT(62,1);
!   ELSE
!     PT_KESAKT(1)=0.0;
!     PT_KESAKT(2)=0.0;
!   FIN;
!   PT_AKT=PT_AKT+PT_KESAKT(1)+PT_KESAKT(2);


    W_HKTH(16)=W_HKTH(16)+PT_AKT*0.002777777(55); /* <<< */

    /* Meldungen ueber Digitaleing„nge */
/*  IF BI_DEINBEW(21) THEN PT_AKT=PT_AKT+PT_KES(1); FIN;   */
/*  IF BI_DEINBEW(22) THEN PT_AKT=PT_AKT+PT_KES(2); FIN;   */
/*  IF BI_DEINBEW(29) THEN PT_AKT=PT_AKT+PT_KES(3); FIN;   */
/*  IF BI_DEINBEW(30) THEN PT_AKT=PT_AKT+PT_KES(4); FIN;   */

    PT_VIERTEL=PT_VIERTEL+PT_AKT;

    TC_ATVIERTEL=TC_ATVIERTEL+TC_AUSSEN; /* AT aufintegrieren        */


    IF Z_SCHNITT > 0 THEN  
      Z_SCHNITT=Z_SCHNITT-1;
    FIN;

    IF Z_SCHNITT==1 THEN  /* viertelstuendlich neuen Schnitt bilden     */

      IF ZF_MIN > 50 THEN  /* vor Ende der vollen Stunde PANEL Datenabholung anstossen */
        Z_PANELSEND=5;
      FIN;

      /* Strombedarf */
      X_A=0.0;
      IF ZP_NOW < ZP_SPITZE+1 MIN AND ZP_NOW+61 MIN > ZP_SPITZE THEN
        PE_SPITZE=0.0;  /* der Spitzenwert ist „lter als 24 h        */
      FIN;

      FOR I FROM 95 BY -1 TO 1 REPEAT
        PE_FELD(I+1)=PE_FELD(I);           /* Feld umsortieren und   */
        X_A=X_A+PE_FELD(I+1);
        IF PE_FELD(I) > PE_SPITZE THEN     /* h”chsten 15 MIN-Wert   */
          PE_SPITZE=PE_FELD(I);            /* herausfinden           */
          ZP_SPITZE=ZP_NOW-I*15 MIN;       /* Zeitpunkt merken       */
        FIN;
      END;
      PE_FELD(1)=PE_VIERTEL/900.0;
      X_A=X_A+PE_FELD(1);
      PE_SCHNITT=X_A/96;                   /* neuen Schnitt bilden   */
      PE_VIERTEL=0.0;

      IF ZP_SPITZE<00:00:00 THEN           /* fals Zeitpunkt negativ */
        ZP_SPITZE=ZP_SPITZE+24 HRS;
      FIN;

      IF PE_FELD(1)>PE_SPITZE THEN      /* nochmal den neusten       */
        PE_SPITZE=PE_FELD(1);           /* vergleichen wenn gr”~er   */
        ZP_SPITZE=ZP_NOW;               /* dann Wert und Zeit merken */
      FIN;

      /* Stromerzeugung  */
      FOR I FROM 95 BY -1 TO 1 REPEAT
        PE_ERZFELD(I+1)=PE_ERZFELD(I);     /* Feld umsortieren       */
      END;
      PE_ERZFELD(1)=PE_ERZVIERTEL/900.0;
      PE_ERZVIERTEL=0.0;

      /* Au~entemperatur */
      X_A=0.0;
      FOR I FROM 95 BY -1 TO 1 REPEAT      /* Feld der Aussentemp.   */
        TC_ATFELD(I+1)=TC_ATFELD(I);       /* umsortieren            */
        X_A=X_A+TC_ATFELD(I+1);
      END;
      TC_ATFELD(1)=TC_ATVIERTEL/90.0;
      X_A=X_A+TC_ATFELD(1);
      TC_ATVIERTEL=0.0;

      /* thermische Leistung */
      X_A=0.0;
      FOR I FROM 96-1 BY -1 TO 1 REPEAT   /* Feld der einzelnen      */
        PT_FELD(I+1)=PT_FELD(I); /* Vietelstundendurchschnittswerte  */
        ZP_H=ZP_NOW - I*15 MIN;           /* umsortieren             */
        IF ZP_H < 00:00:00 THEN
          ZP_H=ZP_H + 24 HRS;
        FIN;                   /* wenn in der Hauptnutzungsdauer     */
        IF ZP_H < (ZP_SCHEND+1 MIN) AND ZP_H > ZP_SCHANF THEN
          X_A=X_A+PT_FELD(I+1);              /* dann aufaddieren     */
        FIN;
      END;
      PT_FELD(1)=PT_VIERTEL/90.0;

      B_LOOP='1'B;
      Z_HAUPTNUTZ=0;
      WHILE B_LOOP REPEAT
        IF ZP_SCHEND > (ZP_SCHANF + Z_HAUPTNUTZ*15 MIN) THEN
          Z_HAUPTNUTZ=Z_HAUPTNUTZ+1;  /* Anzahl der 15 MIN-Durchschnitte pro */
        ELSE                      /* Tag                                 */
          B_LOOP='0'B;
        FIN;
      END;
      CALL FIXGRENZ(96,1,Z_HAUPTNUTZ);  
      IF ZP_NOW < (ZP_SCHEND+1 MIN) AND ZP_NOW > ZP_SCHANF THEN
        X_A=X_A+PT_FELD(1);
        PT_SCHNITT=X_A/Z_HAUPTNUTZ;
        IF PT_SCHNITT < 5.0 THEN
          PT_SCHNITT=5.0;      /* begrenzen     */
        FIN;
/*      Bei Objekten in denen der Waermebedarf von einem Tag zum anderen */
/*      stark schwanken kann (Gewerbe und Schulen nach Wochenenden)<<<   */
/*      IF PT_SCHNITT < (PT_ALT*0.90) THEN  /* darf sich PT_SCHNITT      */
/*        PT_SCHNITT=PT_ALT*0.90;           /* nach unten evtl. nicht    */
/*      FIN;                                /* beliebig schnell aendern  */
      ELSE
        PT_ALT=PT_SCHNITT;                  /* Merker fuer PT_SCHNITT    */
      FIN;
      PT_VIERTEL=0.0;

      /* wenn brauchbare Daten vorhanden dann  <<<                   */
      IF Z_LZ> 60(31) THEN
        /* Aktivierung der Betriebsdatenauswertung                   */
        AFTER 1 SEC ACTIVATE STATISTIK;
      FIN;

      Z_STOKVIERT( 8)=0;  /* <<< */
      Z_STOKVIERT( 9)=0;
      Z_STOKVIERT(10)=1;

      IF PE_BEZUGVIERT/900.0 > PE_STRMAX(DA_MON) THEN         /* <<< */
        PE_STRMAX(DA_MON)=PE_BEZUGVIERT/900.0;
        DA_STRMAX(DA_MON)=DA_DAT;
        Z_STRMAX(DA_MON)=4*ZF_STD+ZF_MIN//15;
      FIN;
      PE_BEZUGVIERT=0.0;

    FIN; /* of Z_SCHNITT  */
                                

    B_HT=B_ABSEIN(55); /* Tarifkalender                      */

    /*---------------------------------------------------------------*/

    IF Z_HMNEU < 1 THEN /* Jede Stunde die Tagheizgrenze ueberpruefen      */
      Z_HMNEU=3600;
      B_HMTGES='0'B;                                 /* vorbesetzen  */
      FOR I TO N_HZKR REPEAT
        IF TC_AUSSEN<TC_HMT(I) AND TC_ATTAU<TC_HMT(I) THEN
          B_HMT(I)='1'B;
          B_HMTGES='1'B; /* Hausmeister wenn einer der Heizkr. ein   */
        ELSE
          B_HMT(I)='0'B;
        FIN;
      END;

      /* BHKWs in der Rangfolge nach Laufzeiten sortieren <<< */
      IF B_FSLBHKWAUTO THEN
       /* <<< BHKWs nach Laufzeit sortieren */
        B_LOOP='1'B;
        FOR K TO N_BHKW REPEAT
          FOR I TO N_BHKW REPEAT
            IF  ( (FS_LBHKW(I) < FS_LBHKW(K)
               AND FL_BLFZGES(I) > FL_BLFZGES(K)+20.0) /* 20 h   */        
               OR  (B_BSTOER(I) AND NOT B_BSTOER(K)) 
               OR  (NOT B_BERLAUBT2(I) AND B_BERLAUBT2(K))
               OR  (NOT B_BBEREIT(I) AND B_BBEREIT(K)))         
               AND B_LOOP THEN 
              B_LOOP='0'B;
              X_M=FS_LBHKW(I);                                             
              FS_LBHKW(I)=FS_LBHKW(K);                                   
              FS_LBHKW(K)=X_M;                                            
            FIN;                                                           
          END;
        END;
        B_LOOP='1'B;
        FOR K TO N_BHKW REPEAT
          FOR I TO N_BHKW REPEAT
            IF  ( (FS_LBHKW(I) < FS_LBHKW(K))
               AND (B_BSTOER(I) AND NOT B_BSTOER(K))          
               AND (NOT B_BERLAUBT2(I) AND B_BERLAUBT2(K))         
               AND (NOT B_BBEREIT(I) AND B_BBEREIT(K)))         
               AND B_LOOP THEN 
              B_LOOP='0'B;
              X_M=FS_LBHKW(I);                                             
              FS_LBHKW(I)=FS_LBHKW(K);                                   
              FS_LBHKW(K)=X_M;                                            
            FIN;                                                           
          END;
        END;
     
      FIN;

  !!                                     FL_BLFZGES kommt ueber CAN  
  !!    IF FS_LBHKW(2) > FS_LBHKW(1) AND FL_BLFZGES(2) < FL_BLFZGES(1) - 20.0 
  !!       AND NOT B_BSTOER(2) AND B_BBEREIT(2) AND B_BERLAUBT2(2) THEN 
  !!      FS_LBHKW(1)=2;                                   
  !!      FS_LBHKW(2)=1;                                           
  !!    FIN;                                                           
  !!
  !!    IF FS_LBHKW(1) > FS_LBHKW(2) AND FL_BLFZGES(1) < FL_BLFZGES(2) - 20.0 
  !!       AND NOT B_BSTOER(1) AND B_BBEREIT(1) AND B_BERLAUBT2(1) THEN 
  !!      FS_LBHKW(1)=1;                                   
  !!      FS_LBHKW(2)=2;                                           
  !!    FIN;                                                           
   
   !                                     FL_BLFZGESHZG wir hier gezaehlt und laesst sich einstellen   
   !    IF FS_LBHKW(2) > FS_LBHKW(1) AND FL_BLFZGESHZG(2) < FL_BLFZGESHZG(1) - 20.0 
   !       AND NOT B_BSTOER(2) AND B_BBEREIT(2) AND B_BERLAUBT2(2) THEN 
   !      FS_LBHKW(1)=2;                                   
   !      FS_LBHKW(2)=1;                                           
   !    FIN;                                                           
   
   !    IF FS_LBHKW(1) > FS_LBHKW(2) AND FL_BLFZGESHZG(1) < FL_BLFZGESHZG(2) - 20.0 
   !       AND NOT B_BSTOER(1) AND B_BBEREIT(1) AND B_BERLAUBT2(1) THEN 
   !      FS_LBHKW(1)=1;                                   
   !      FS_LBHKW(2)=2;                                           
   !    FIN;                                                           

   !  FS_LBHKW(1)=1;                                   

    FIN;

    /*---------------------------------------------------------------*/
    /* Heizungszustaende ermitteln:                                  */

    /* Heizung nach Waermebedarf */
    B_HZGWB  =     B_HMTGES AND NOT B_KERNABS
               OR  B_HMNGES
               OR  B_VOR AND B_HMTGES;

    /* Waermeanforderung */
    B_WA     =     B_HZGWB OR B_BWANFGES OR B_WASONST;

    /* Betrieb der BHKW nach Strombedarf */
    B_SB     =     NOT B_WA
               OR  Z_BETRIEB==2;

    /* Kesselzwangsausschaltbedingung */
    B_KESAUS =     NOT B_WA
               OR  B_VOR AND NOT B_HMNGES AND PT_SCHNITT < PE_MAX*(PT_GRUND+PT_FAKTOR-0.2);
                                                           /* <<< */
    /* Kesseleinschaltsperre */
    B_ESPK   =     B_KERNABS AND NOT B_HMNGES AND Z_BAKT==Z_BANFORD
                   AND NOT B_WA;

    /* BHKW-Einschaltsperre */
    B_ESPB   =     B_KERNABS AND NOT (B_VOR OR B_HT OR B_HMNGES)
                   AND NOT B_WA;


    /*---------------------------------------------------------------*/
    /* Vorlaufsolltemperaturen der einzelnen Heizkreise berechnen    */
    TC_B=0.0;        /* Hilfsvariable fuer hoechstes Vorlaufsoll     */
    TC_VSOLLMAX=0.0; /* fuer Ermittlung des Maximums ruecksetzen     */
    B_NAER='1'B;     /* Erstmal annehmen, dass Nachtabsenkung und    */
    B_TAER='0'B;     /* nicht Tag erreicht                           */
    B_VOR='0'B;      /* vorbesetzen                                  */

!   FOR I TO   7    REPEAT  /* <<< */
    FOR I TO N_HZKR REPEAT

      /* Nachtheizgrenze fuer jeden Heizkreis und insgesamt ueberpr.   */
      IF TC_AUSSEN<TC_HMN(I) THEN
        B_HMN(I)='1'B;
        B_HMT(I)='1'B;
      FIN;
      IF TC_AUSSEN>TC_HMN(I)+1.0 THEN
        B_HMN(I)='0'B;
      FIN;

      /* Falls Heizkreis in der Runterphase ist  */
      IF B_RUNTHK(I) THEN
        IF B_ABSHK(I) THEN
          Z_RUNTHK(I)=Z_RUNTHK(I)+1;
        FIN;
        IF Z_RUNTHK(I)>=ZF_RUNT THEN /* Runterende erreicht ?        */
          B_RUNTHK(I)='0'B;          /* Runterphase beenden !        */
          B_NAERHK(I)='1'B;          /* Nachtabsenkung erreicht !    */
        FIN;
        IF TC_ATTAU < TC_AUSSEN THEN  
          TC_A=TC_ATTAU+TD_ABSHK(I)*Z_RUNTHK(I)/ZF_RUNT;
        ELSE
          TC_A=TC_AUSSEN+TD_ABSHK(I)*Z_RUNTHK(I)/ZF_RUNT;
        FIN;
        /* Aussentemperatur wird mit steigendem Zaehlerstand angehoben*/
      ELSE
        /* Falls Heizkreis in der Hochphase ist                      */
        IF B_HOCHHK(I) THEN
           /* nur hochzaehlen wenn folgende Bedingung erfuellt ist     */
          IF (B_VORHK(I) AND TC_VIST>TC_VSOLL OR NOT B_ABSHK(I)) THEN
            Z_HOCHHK(I)=Z_HOCHHK(I)+1;
          FIN;

          IF Z_HOCHHK(I)>=ZF_HOCH THEN /* Hochende erreicht ?        */
            B_HOCHHK(I)='0'B;          /* Hochphase beenden !        */
            B_TAERHK(I)='1'B;          /* Tag erreicht !             */
          FIN;
          IF TC_ATTAU < TC_AUSSEN THEN  
            TC_A=TC_ATTAU+TD_ABSHK(I)*(ZF_HOCH-Z_HOCHHK(I))/ZF_HOCH;
          ELSE
            TC_A=TC_AUSSEN+TD_ABSHK(I)*(ZF_HOCH-Z_HOCHHK(I))/ZF_HOCH;
          FIN;
          /* Aussentemp. sinkt mit steigendem Zaehlerstand             */
        ELSE
          IF B_ABSHK(I) AND NOT B_TAERHK(I) THEN
            IF TC_ATTAU < TC_AUSSEN THEN  
              TC_A=TC_ATTAU+TD_ABSHK(I); /* volle Manipulation der AT */
            ELSE
              TC_A=TC_AUSSEN+TD_ABSHK(I); /* volle Manipulation der AT */
            FIN;
          ELSE
            IF TC_ATTAU < TC_AUSSEN THEN  
              TC_A=TC_ATTAU; /* keine Manipulation der Aussentemperatur */
            ELSE
              TC_A=TC_AUSSEN; /* keine Manipulation der Aussentemperatur */
            FIN;
          FIN;
        FIN;
      FIN;
      /* Jetzt enthaelt TC_A die Aussentemperatur die dem jeweiligen HK zugeordnet ist  */


      /* wenn alle Heizkreise NAER, bleibt B_NAER wahr:              */
      B_NAER=B_NAER AND B_NAERHK(I);

      /* wenn B_NAER wahrgeblieben ist und alle Heizkreise durch     */
      /* dann die Kernabsenkung setzen                               */
      IF B_NAER AND NOT B_KERNABS AND I==N_HZKR THEN
        B_KERNABS='1'B;
      FIN;

      /* wenn ein Heizkreis TAER, wird B_TAER wahr:                  */
      B_TAER=B_TAER OR B_TAERHK(I);

      IF (B_TAER OR NOT B_ABSHK(I)) AND B_KERNABS THEN
        B_KERNABS='0'B;
        Z_HMNEU=0;
        ZP_KABSEAKT=ZP_NOW;
        DA_KABSEAKT=DA_DAT;
      FIN;

      /* in der Vorphase wird die Heizung schon vor Ende der eingest.*/
      /* Absenkung des jeweiligen Heizkreises in Betrieb genommen    */
      /* Die Vorphase der gesamten Heizung wird hier mit den         */
      /* Vorphasen der einzelnen Heizkreise verodert                 */
      B_VOR=B_VOR OR (B_VORHK(I) AND B_KERNABS);


      X_A=100.0*(TC_HKINENN(I)-TC_A)/(TC_HKINENN(I)-TC_HKANENN(I)); /* Pth HK in % */
      CALL FLOGRENZ(100.0,1.0,X_A); 


!     IF I==1 THEN /* <<< HK1 TENNISHALLE     */
!       IF BI_DEINBEW(xx) THEN          
!         TC_RSOLLAKT(1)=TC_TAGSOLL(1);
!       ELSE 
!         IF B_ABSHK( 1) THEN
!           TC_RSOLLAKT(1)=TC_NACHTSOLL(1);
!         ELSE
!           TC_RSOLLAKT(1)=TC_BEREITSOLL(1);
!         FIN;
!       FIN;
!     FIN;


      IF B_PMPHK(I) THEN

        /* Heizkreisistspreizung mit Tau=1.16 Tage bestimmen, wenn   */
        /* normaler Heizbetrieb                                      */
        IF TC_AUSSEN < 13.0 AND TC_ATTAU < 8.0 AND NOT B_ABSHK(I)
           THEN
          TD_HKSPREI(I)=(TD_HKSPREI(I)*9999.0+(TC_HKIST(I)-TC_HKR(I)))
                        *0.0001;
        FIN;


        /* NENNVL MUSS  2K  GROESSER ALS NENNINNEN SEIN */                       
        IF TC_HKVNENN(I)-TC_HKINENN(I) <  2.0 THEN
          TC_HKVNENN(I)=TC_HKINENN(I)+ 2.0;
        FIN;
        FL1=15.0;   /* NENNSPREIZUNG FUER FORMEL */
        IF FL1 > (TC_HKVNENN(I)-TC_HKINENN(I)) -1.0 THEN
          FL1=(TC_HKVNENN(I)-TC_HKINENN(I))-1.0;
        FIN;

        X_B=((  FL1       *X_A/100.0        )/(
                     1.0))/(1-EXP((EXP((FL_EXPHK(I)-1.0)/FL_EXPHK(I)*
            LN(X_A/100.0        )))/(            1.0 )*
            LN(1.0- FL1         /(TC_HKVNENN(I)-TC_HKINENN(I)))))+
            TC_HKINENN(I);


    !   IF I==1 THEN /* <<< HK1 TENNISHALLE     */
    !     X_C=TC_RSOLLAKT(1)-TC_RISTAKT(1);
    !     CALL FLOGRENZ(4.0,-6.0,X_C); 
    !     IF X_C < 0.0 THEN
    !       X_B=X_B+X_C*8.0;
    !     ELSE
    !       X_B=X_B+X_C*4.0;
    !     FIN;           
    !   FIN;

        IF I==2 THEN /* <<< HK2 mit TROCKNUNG dran     */
          /* TROCKN BETRIEB   */ 
          IF B_PMPHK(4) THEN
            IF X_B < TC_HKVNENN(21) THEN
              X_B=TC_HKVNENN(21);
            FIN;
          FIN;
        FIN;

        IF X_B<TC_HKVMIN(I) THEN /* bei eingeschaltetem HK die           */
          X_B=TC_HKVMIN(I);      /* Mindestvorlauftemp. beruecksichtigen */
        FIN;
      

      ELSE  /* wenn die Pumpe nicht l„uft, dann kleine Temperatur    */
        X_B= 8.8;
      FIN;

      /* evtl. besteht die Gefahr des ueberfluessigen Zuschaltens von  */
      /* Waermeerzeugern ?                                            */
      IF X_B<TC_HKSOLL(I) AND Z_STKLEIN>0 OR Z_LZ<100(31) THEN
        TC_HKSOLL(I)=X_B;
      ELSE
        TC_HKSOLL(I)=(TC_HKSOLL(I)*14.0+X_B)/15.0;     /* Tau=150s     */
      FIN;

      /* ESTRICHTROCKNUNG <<< */
      IF F_ESTRICH(I,21) > 0.0 THEN
        FIX1=ROUND((29520.0-F_ESTRICH(I,21))/1440.0); /* 0,50 - 20,50  =  1 - 20 */
        CALL FIXGRENZ(20,1,FIX1);  
        TC_HKSOLL(I)=F_ESTRICH(I,FIX1);
        IF TC_HKSOLL(I) < 1.0 THEN  /* WENN SOLL < 1 DANN ESTRICHTROCKNUNG BEENDEN <<< */
          F_ESTRICH(I,21)=0.0; 
        FIN;  
        TD_HKINT(I)=0.0;
        B_HMT(I)='1'B;
        B_HMN(I)='1'B;
      FIN;


      /* Heizkreisvorlaufsoll nach oben begrenzen                    */
      IF TC_HKSOLL(I)>TC_HKVNENN(I) THEN
        TC_HKSOLL(I)=TC_HKVNENN(I);
      FIN;

      /* H”chstes Vorlaufsollmaximum ermitteln:                      */
      IF TC_VSOLLMAX<TC_HKVNENN(I) THEN
        TC_VSOLLMAX=TC_HKVNENN(I);
      FIN;

      /* Ist dieses Vorlaufsoll das hoechste ? Dann merken !         */
      /* bei den Heizkreisen den Korrekturfaktor dazuaddieren        */
      /* 5 Kelvin pro 5000 aufintegrierter Wert                      */
      IF TC_HKSOLL(I)+TD_HKINT(I) > TC_B THEN
        /* Anforderung des aktuellen Heizkreises auf Nennvorlauf des */
        /* aktuellen Heizkreises begrenzen                           */
        IF TC_HKSOLL(I)+TD_HKINT(I)<TC_HKVNENN(I) THEN
          TC_B=TC_HKSOLL(I)+TD_HKINT(I);
        ELSE
          IF TC_HKVNENN(I) > TC_B THEN
            TC_B=TC_HKVNENN(I);
          FIN;
        FIN;
      FIN;

    END;


    B_WASONST='0'B;
    TC_WASONST=0.0;  


    /* Einbau Nahwärme zur Dueppelstr. <<< */
!   IF B_PMPHK(2) THEN
!     B_WASONST='1'B;
!     TC_WASONST=TC_HKSOLL(2)+2.0;
!   FIN;
!   IF B_BWANF(2) THEN
!     B_WASONST='1'B;
!     IF TC_WASONST < TC_BWVLS(2)+2.0 THEN
!       TC_WASONST=TC_BWVLS(2)+2.0;
!     FIN;
!   FIN;
!   TC_HKSOLL(3)=TC_WASONST-2.0;

!   IF X_AEINEXT(44,1) > 10.0     THEN  /* <<< UST KESSEL       */
!     B_WASONST='1'B;
!     IF X_AEINEXT(44,1) > TC_WASONST THEN      
!       TC_WASONST=X_AEINEXT(44,1);
!     FIN;
!   FIN;


    
    B_LOOP='0'B;
    FOR I TO N_HZKR REPEAT
      B_LOOP=B_LOOP OR B_HMN(I);
    END;  
    B_HMNGES=B_LOOP;

    /* Brauchwasserladung gefordert ?                                */
    IF B_BWANFGES AND TC_BWVLSGES>TC_B THEN 
      TC_B=TC_BWVLSGES; 
      IF TC_VSOLLMAX<TC_BWVLSGES THEN
        TC_VSOLLMAX=TC_BWVLSGES;
      FIN;
    FIN;

    /* Besteht sonstige W„rmeanforderung ?                           */
    IF B_WASONST AND TC_WASONST > TC_B THEN 
      TC_B=TC_WASONST; 
      IF TC_VSOLLMAX<TC_WASONST THEN
        TC_VSOLLMAX=TC_WASONST;
      FIN;
    FIN;


    /* Altes Vorlaufsoll gegen neues ersetzen:                       */
    /* evtl. besteht die Gefahr des ueberfluessigen Zuschaltens von    */
    /* Waermeerzeugern ?                                              */
    IF TD_UEBERHEIZ > 10.0 THEN                       /* <<< */
      TD_UEBERHEIZ=10.0;
    FIN;  
    IF TD_UEBERHEIZ < 0.0 THEN
      TD_UEBERHEIZ=0.0;
    FIN;  
    IF TC_B<TC_VSOLL AND Z_STKLEIN>0 OR Z_LZ<100(31) THEN
      TC_VSOLL=TC_B+TD_UEBERHEIZ;                      /* <<< */
    ELSE
      TC_VSOLL=(TC_VSOLL*9.0+TC_B+TD_UEBERHEIZ)*0.1;   /* <<< */ 
    FIN;

 
    /*---------------------------------------------------------------*/
    /* T max šberpruefung:                                            */
    TC_MAX=TC_VSOLL+TD_MAX-0.01;         /* Normalfall                    */
    IF     TC_MAX>TC_VSOLLMAX+5.0   /* Vorlaufsoll an oberer Grenze  */
       AND TC_MAX>TC_BWVLSGES+TD_MAX
       AND TC_MAX>TC_WASONST+TD_MAX
       AND TC_MAX>TC_MAXMIN THEN   /* <<< */
      TC_MAX=TC_VSOLLMAX+5.0;                                         
      IF TC_VSOLL+5.0 > TC_MAX THEN
        TC_MAX=TC_VSOLL+5.0;
      FIN;
      IF TC_VIST>TC_MAX THEN  /* Bedingungen fuer W„rmeerzeuger     */
        B_TM3='1'B;
      FIN;
      IF TC_VIST<TC_MAX-0.1 THEN
        B_TM3='0'B;
      FIN;

      IF TC_VIST>TC_MAX-0.5 THEN
        B_TM2='1'B;
      FIN;                    /* Bedingungen fuer Notkuehler         */
      IF TC_VIST<TC_MAX-1.0 THEN
        B_TM2='0'B;
      FIN;

      IF TC_VIST>TC_MAX-1.5 THEN  /* Beding. fuer W„rmevernichtung  */
        B_TM1='1'B;
      FIN;
      IF TC_VIST<TC_MAX-2.0 THEN
        B_TM1='0'B;
      FIN;

    ELSE

      IF TC_MAX<TC_MAXMIN THEN TC_MAX=TC_MAXMIN; FIN; /* <<< */
      IF TC_VIST>TC_MAX THEN    /* Bedingungen fuer W„rmeerzeuger     */
        B_TM3='1'B;
      FIN;
      IF TC_VIST<TC_MAX-0.5 THEN
        B_TM3='0'B;
      FIN;

      IF TC_VIST>TC_MAX-1.0 THEN
        B_TM2='1'B;
      FIN;                      /* Bedingungen fuer Notkuehler         */
      IF TC_VIST<TC_MAX-3.0 THEN
        B_TM2='0'B;
      FIN;

      IF TC_VIST>TC_MAX-4.0 THEN    /* Beding. fuer W„rmevernichtung  */
        B_TM1='1'B;
      FIN;
      IF TC_VIST<TC_MAX-4.5 THEN
        B_TM1='0'B;
      FIN;
    FIN;

    /* wenn die thermische Durchschnittsleistung auch mit einem BHKW */
    /* weniger erreicht werden kann und TM1 oefter erreicht wird     */
    /* dann den Zaehler hoch und bald geht eins aus                  */
    IF B_TM1 AND Z_BAKT>1 THEN     /* <<< */
      IF (PT_GRUND*(Z_BAKT-1)*PE_MAX/Z_BAKT+PT_FAKTOR*(Z_BAKT-1)*PE_MAX/Z_BAKT) > (0.95*PT_SCHNITT) THEN
        Z_STGROSS=Z_STGROSS+1;
      FIN;
    FIN;


    /* Zaehler fuer Leistungsgrenzen                                   */

    IF    (PE_BSOLLGES <= PE_RMIN*1.01 AND Z_BAKT > 1)      
       OR (PE_THERM    <= PE_RMIN*1.01 AND Z_BAKT > 1)      
       OR (PE_BSOLLGES <= PE_RMIN*1.01 AND PE_BEDARF <= PE_RMIN*1.01 AND Z_BAKT == 1) THEN
      /* Falls die Leistungsgrenze unterschritten ist,               */
      B_PMIN='1'B;
      IF Z_LMIN<30000 THEN  /* Zaehlerstand begrenzen                */
        Z_LMIN=Z_LMIN+1;    /* Zaehler um 10 SEC erh”hen             */
      FIN;
    ELSE
      B_PMIN='0'B;
      IF Z_LMIN>0 THEN
        Z_LMIN=Z_LMIN-1;
      FIN;
    FIN;

    /* el. Solleistung an der oberen Regelgrenze der aktiven BHKW    */
                                  
    IF PE_BSOLLGES>=PE_MAX*0.99 THEN
      B_PMAX='1'B;
      IF Z_LMAX<30000 THEN        /* Zaehlerstand nach oben begrenzen */
        Z_LMAX=Z_LMAX+1;                         /* Zaehler erhoehen  */
      FIN;
    ELSE
      B_PMAX='0'B;
      IF Z_LMAX>0 THEN
        Z_LMAX=Z_LMAX-1;                     /* Zaehler runterzaehlen */
      FIN;
    FIN;

    IF Z_KANFORD>0 AND PT_MINKES > 98.0 THEN   /* Mind. ein Kes und Max Leist.  */
      Z_LKMAX=Z_LKMAX+1;          /* angefordert dann Zaehler erhoehen */
    ELSE
      Z_LKMAX=0;                  /* sonst auf Null setzen             */
    FIN;


    IF B_SCHORNGES AND TC_VIST > TC_VSOLL+1.0 AND Z_KANFORD>0 THEN
      CALL SCH_KAB;
    FIN;
    IF B_SCHORNGES AND TC_VIST > TC_VSOLL+5.0 AND Z_BANFORD>0 THEN
      CALL SCH_BAB;
    FIN;

    B_SCHORNGES='0'B;
    FOR I TO 10 REPEAT
      IF Z_SCHORNK(I) > 0 THEN
        Z_SCHORNK(I)=Z_SCHORNK(I)-10;
        B_KEIN(I)='1'B;
        B_SCHORNGES='1'B;
      FIN;
      IF Z_SCHORNKMAX(I) > 0 THEN
        Z_SCHORNKMAX(I)=Z_SCHORNKMAX(I)-10;
        IF Z_SCHORNK(I) < Z_SCHORNKMAX(I) THEN
          Z_SCHORNK(I)=Z_SCHORNKMAX(I);
        FIN;
      FIN;
    END;
    FOR I TO 8 REPEAT
      IF Z_SCHORNB(I) > 0 THEN
        Z_SCHORNB(I)=Z_SCHORNB(I)-10;
        B_BEIN(I)='1'B;
        B_SCHORNGES='1'B;
      FIN;
    END;

    IF NOT B_SCHORNGES THEN
      /*---------------------------------------------------------------*/
      /* jetzt die neuen BHKW-/Kesselanforderungen bestimmen           */
      /* Wenn noch kein BHKW angefordert und Einschaltbed. 1. BHKW     */
      IF Z_BAKT==0 AND Z_BANFORD < N_BHKW AND TST_B1ZU THEN
        CALL SCH_BZU;     /* Einschalten des ersten oder einzigen BHKW */
      ELSE /* 1 bis n BHKW's, bzw. 1 bis n Kessel sind angefordert     */
        IF Z_BANFORD < N_BHKW AND Z_BAKT > 0 AND TST_BNZU1 THEN
          CALL SCH_BZU;          /* Zuschalten eines weiteren BHKW     */
        ELSE
          IF Z_BAKT==1 AND TST_B1AB AND Z_BANFORD > 0 THEN
            CALL SCH_BAB;    /* Abschalten des letzten BHKW            */
          ELSE               /* Abschaltbedingungen n BHKW             */
            IF Z_BAKT>1 AND TST_BNAB AND Z_BANFORD > 0 THEN
              CALL SCH_BAB;    /* Abschalten eines BHKW                */
            ELSE
              /* Einschaltbedingungen fuer ersten Kessel erfuellt und    */
              /* alle BHKW angefordert oder BHKW nach Strombedarf      */
              /* und noch kein Kessel angefordert                      */
              IF TST_K1ZU1 AND (Z_BANFORD==N_BHKW OR B_SB)
                AND Z_KANFORD==0 THEN
                CALL SCH_KZU;    /* Einschalten des 1. Kessel          */
              ELSE
                IF Z_KANFORD<N_KESSEL AND TST_KNZU1 THEN
                  /* Zuschaltbedingungen n. Kessel erfuellt             */
                  CALL SCH_KZU;    /* weitere Kessel einschalten       */
                ELSE
                  IF TST_KAB AND Z_KANFORD > 0 THEN /* Abschaltbed n. Kes ? */
                    CALL SCH_KAB;    /* einen Kessel ausschalten       */
                  FIN;
                FIN;
              FIN;
            FIN;
          FIN;
        FIN;
      FIN; /* Jetzt sind die neuen BHKW-/Kesselanforderungen bestimmt! */
    FIN; /* of IF NOT B_SCHORNGES */


  FIN; /* Ende der Haupt Routinen                                    */

/*********************************************************************/
/*     Thermisches Leistungssoll BHKWs berechnen (in KW elektrisch)  */
/*********************************************************************/

  IF B_TAKT10 THEN

    /* Regelabweichung Hauptkreisvorlauf (Vorlaufist zu Vorlaufsoll) */
    IF Z_BLZMIN < 3600(31) THEN
      TD_RA = (TC_VSOLL-3.0) - TC_VIST;
    ELSE
      TD_RA = TC_VSOLL - TC_VIST;
    FIN;

    IF TD_RA<0 AND ST_VIST>ST_VSOLL THEN /* es ist zu warm:          */
      /* Neues Soll=Altes Soll - Anzahl der Stufen * Stufe           */
      PE_THERM=PE_THERM-ROUND(ABS(TD_RA)/TD_STUFEA)*PE_STUFE;
    FIN;
    /* Wenn die thermische Istleistung > thermische Durchschnittsl.  */
    /* und es zu kalt ist und die thermische Durchschnittsl. < als   */
    /* 16 kW * Anzahl der BHKW ist,                                  */
    IF PT_AKT > PT_SCHNITT AND TD_RA > 0 AND Z_BWKALT < 100 AND /* <<< */
       PT_SCHNITT < PE_BMAXMOGL*(PT_GRUND+PT_FAKTOR+0.3) THEN
      IF ST_VIST < ST_VSOLL THEN
        /* dann thermische Leistung nur sehr langsam erh”hen         */
        PE_THERM=PE_THERM+PE_MAX*0.015;
      FIN;
    ELSE

      IF    TD_RA-1.5 > 0                  /* unterhalb von BU       */
        AND PE_BEDARF > PE_RMIN            /* Bedarf ueber RMIN       */
        AND ST_VIST < ST_VSOLL THEN        /* Steigung reicht nit    */
        /* Neues Soll=Altes Soll + Anzahl der Stufen  * Stufe        */
        PE_THERM=PE_THERM+ROUND((TD_RA-1.5)/TD_STUFEB)*PE_STUFE;
      FIN;

      IF    TD_RA > 0                      /* unterhalb von TC_VSOLL */
        AND PE_BEDARF <= PE_RMIN           /* Bedarf unter RMIN      */
        AND ST_VIST < ST_VSOLL THEN        /* Steigung reicht nicht  */
        /* Neues Soll=Altes Soll + Anzahl der Stufen * Stufe         */
        PE_THERM=PE_THERM+ROUND(TD_RA/TD_STUFEB)*PE_STUFE;
      FIN;

    FIN;

    /* <<<  */
    /* Die el. Solleistungsanforderung aufgrund thermischer Bed.     */
    /* soll so bestimmt werden, daá die th. BHKW-Leistung mindestens */
    /* 85% von PT_SCHNITT betr„gt                                    */
    IF ZP_NOW < (ZP_SCHEND+1 MIN) AND ZP_NOW > ZP_SCHANF THEN /* waehrend Hauptnutzungsdauer 85% */
      IF (PT_GRUND*PE_MAX+PT_FAKTOR*PE_THERM) < 0.85*PT_SCHNITT THEN
        PE_THERM=(0.85*PT_SCHNITT-PT_GRUND*PE_MAX)/PT_FAKTOR;  
      FIN;
    ELSE                                                      /* sonst 60%  */
      IF (PT_GRUND*PE_MAX+PT_FAKTOR*PE_THERM) < 0.60*PT_SCHNITT THEN
        PE_THERM=(0.60*PT_SCHNITT-PT_GRUND*PE_MAX)/PT_FAKTOR;  
      FIN;
    FIN;

    /**********************************/
    /* Puffer1 OBEN soll warm <<<     */
    /**********************************/
 !  IF PT_SCHNITT >  35.0 AND ZP_NOW < (ZP_SCHEND-1 MIN) AND ZP_NOW > ZP_SCHANF THEN
 !    IF PT_SCHNITT >  60.0 THEN
    IF PT_SCHNITT > PT_BHKWMOEG*0.8 AND ZP_NOW < (ZP_SCHEND-1 MIN) AND ZP_NOW > ZP_SCHANF THEN
      IF PT_SCHNITT >  PT_BHKWMOEG*1.1 THEN
        IF X_AEIN(10) < 71.0 THEN  /* PUFFER2 u     */
          B_BPMP(8)='1'B;
        FIN;
        IF X_AEIN(10) > 72.0 THEN
          B_BPMP(8)='0'B;
        FIN;
      ELSE
        IF X_AEIN( 8) < 71.0 THEN  /* PUFFER1 u     */
          B_BPMP(8)='1'B;
        FIN;
        IF X_AEIN( 8) > 72.0 THEN
          B_BPMP(8)='0'B;
        FIN;
      FIN;
    ELSE
      B_BPMP(8)='0'B;
    FIN;

    IF X_AEIN( 7) < 72.0 THEN  /* PUFFER o     IMMER!! */
      B_BPMP(8)='1'B;
    FIN;

    /* LEISTUNG BEGRENZEN <<<<  z.B. bei Puffer unten > xxx  */
 !  IF X_AEIN(15) > TC_BHZGRO(1) THEN 
 !    B_BPMP(8)='0'B;
 !    IF TC_VIST > TC_VSOLL-1.0 THEN
 !      PE_THERM=PE_RMIN;
 !    FIN;
 !  FIN;


    IF B_BPMP(8) THEN
      PE_THERM=PE_MAX;
    FIN;

    IF PE_THERM<PE_RMIN THEN            /* nach unten begrenzen      */
      PE_THERM=PE_RMIN;
    FIN;
    IF PE_THERM>PE_MAX THEN             /* nach oben begrenzen       */
      PE_THERM=PE_MAX;
    FIN;
    IF Z_KAKT>0 AND Z_BAKT>0 THEN  /* wichtig nach St”rungen, damit  */
      PE_THERM=PE_MAX;             /* wiederlaufende BHKW mit voller */
    FIN;                           /* Leistung betrieben werden      */

    IF Z_KAKT>0 AND Z_BANFORD < N_BHKW AND NOT B_SB AND NOT B_SCHORNGES THEN    /* BEI LAUFENDEM KESSEL */
      CALL SCH_BZU;                                                             /* ALLE BHKWS ANFORDERN */
    FIN;  

  FIN; /* Ende der t BHKW Routinen                                   */

/*********************************************************************/
/* t Mess Routinen                                                   */
/*********************************************************************/
  Z_TMESS=Z_TMESS+1; 
  IF Z_TMESS > ZF_TMESS THEN
    Z_TMESS=1; 

    /* Vorlaufsteigung = ( Ist - Istalt ) / Me~zeitraum              */
    ST_VIST = (TC_VIST-TC_VALT) /  ZF_TMESS;
    TC_VALT = TC_VIST; /* Vorlauf-Istwert fuer's n„chste mal merken   */

    /* Vorlaufsollsteigung = Soll - Ist /  Sollsteigunszeit          */
    ST_VSOLL = (TC_VSOLL-TC_VIST) / ZF_SOLLST;

    /* Wieviel Messzeiten ist die Vorlauf-Ist-Steigung kleiner als   */
    /* die Sollsteigung ? Anzahl in Z_STKLEIN festhalten             */

    IF ST_VIST<ST_VSOLL THEN /* Vorlaufsteigung kleiner Sollsteig.?  */
      /* noch nicht alle BHKW angef. und Betrieb nach W„rmebedarf    */
      IF Z_BANFORD<N_BHKW AND NOT B_SB THEN
        IF TST_BNZU2 THEN 
          X_A=TC_VSOLL-TC_VIST;
          IF X_A > 2.0*TD_KS THEN    /* bei grosser Abweichung +2 */
            Z_STKLEIN=Z_STKLEIN+2; 
          ELSE
            Z_STKLEIN=Z_STKLEIN+1; 
          FIN;
        FIN;
      ELSE                     /* Kessel-Zuschaltbedingungen testen  */
        IF Z_KANFORD==0 THEN /* 1. Kessel testen                     */
          IF TST_K1ZU2 THEN 
            X_A=TC_VSOLL-TC_VIST;
            IF X_A > 2.0*TD_KS THEN    /* bei grosser Abweichung +2 */ 
              Z_STKLEIN=Z_STKLEIN+2; 
            ELSE
              Z_STKLEIN=Z_STKLEIN+1; 
            FIN;
          FIN;
        ELSE                 
          IF TST_KNZU2 THEN  /* n. Kessel testen                     */
            X_A=TC_VSOLL-TC_VIST;
            IF X_A > 2.0*TD_KS THEN 
              Z_STKLEIN=Z_STKLEIN+2; 
            ELSE
              Z_STKLEIN=Z_STKLEIN+1; 
            FIN;
          FIN;
        FIN;
      FIN;
    ELSE
      IF Z_STKLEIN > 0 THEN
        Z_STKLEIN=Z_STKLEIN-1;   /*          Z„hler zurueckz„hlen     */
      FIN;
    FIN;

    IF Z_STKLEIN > 3000 THEN
      Z_STKLEIN=3000;
    FIN;

    /* Ist der Hauptkreis viel zu warm und die Steigung gr”~er Null  */
    IF TC_VIST>TC_MAX AND ST_VIST>=0 THEN
      Z_STGROSS=Z_STGROSS+1;     /* Z„hler erh”hen                   */
    ELSE
      IF Z_STGROSS > 0 THEN
        Z_STGROSS=Z_STGROSS-1;   /*          Z„hler zurueckz„hlen     */
      FIN;
    FIN;

    /*****************************************************************/
    /* bevor ein neuer W„rmeerzeuger eingeschaltet wird, erstmal den */
    /* Pumpennachlauf des W„rmeerzeugers der als n„chster dran w„re  */
    /* nochmal setzen und Warmwasseranf. zuruecksetzen               */
    /* <<< Pumpenvorlauf macht bei manchen Hydr. keinen Sinn  PPP    */
    /*****************************************************************/ 
    IF Z_BANFORD < N_BHKW THEN
      IF      (Z_STKLEIN > 0 AND Z_STKLEIN > ZF_NBE-2 AND Z_BANFORD > 0)
         OR   (Z_BANFORD==0 AND (TC_VIST+1.0 < TC_VSOLL-TD_1EIN OR Z_TCKLEIN > ZF_T1EIN*5)) THEN
        B_LOOP='1'B;           /* erstmal auf 1 setzen                     */
        X_O=1;
        WHILE B_LOOP REPEAT    /* bis ein einsatzf{higes BHKW gefunden     *
          /* ist die Rangfolge des aktuellen BHKW kleiner oder gleich der  */
          /* Anzahl der angeforderten BHKWs + 1                            */
          IF FS_LBHKW(X_O) <= Z_BANFORD+1 THEN
            /* wenn das Modul nicht gest|rt und noch nicht angefordert ist */
            IF     NOT B_BSTOER(X_O) AND NOT B_BEIN(X_O) 
               AND B_BBEREIT(X_O) AND B_BERLAUBT2(X_O) THEN
              B_LOOP='0'B;            /* Schleifenausgang mit Erfolg       */
              IF B_PMPVORL THEN
                Z_BPNL(X_O)=30;   /* PPP   Pumpenvorlauf setzen            */
              FIN;
              FOR I TO N_SPEI REPEAT    
                B_BWNORM(I)='0'B;    
                B_BWDRIG(I)='0'B;    
              END;
              FOR I TO 4 REPEAT
                Z_BWSPAREXT(I)=39;  /* <<< */
              END;
            ELSE
              X_O=X_O+1;
            FIN;
          ELSE
            X_O=X_O+1;
          FIN;
          IF X_O > N_BHKW THEN
            B_LOOP='0'B;   /* Schleifenausstieg ohne Erlolg                */
          FIN;
        END;
      FIN;  
    ELSE  /* Z_BANFORD nicht kleiner N_BHKW */
      IF Z_KANFORD < N_KESSEL THEN
        IF (Z_STKLEIN > 0 AND Z_STKLEIN > ZF_NKE-3)
   ! <<<   OR (Z_BAKT==0 AND Z_KANFORD==0 AND TC_VIST < TC_VSOLL) THEN
                                                                  THEN
          B_LOOP='1'B;
          X_O=1;
          WHILE B_LOOP REPEAT  /* bis ein Kessel gefunden wurde        */
            /* ist die Rangfolge des aktuellen Kessels kleiner oder    */
            /* gleich der Anzahl der angeforderten Kessel + 1 ?        */
            IF FS_LKES(X_O) <= Z_KANFORD+1 THEN
              /* wenn der Kessel noch nicht angefordert ist            */
              IF NOT B_KEIN(X_O) THEN
                B_LOOP='0'B;            /* Schleifenausgang mit Erfolg */
                IF B_PMPVORL THEN
                  Z_KPNL(X_O)=30;   /* PPP   Pumpenvorlauf setzen            */
                FIN;
          !     IF PT_SCHNITT < PE_MAX*3.0 THEN !<<< 
                  FOR I TO N_SPEI REPEAT    
                    B_BWNORM(I)='0'B;                                       
                    B_BWDRIG(I)='0'B;    
                  END;
          !     FIN;
                FOR I TO 4 REPEAT
                  Z_BWSPAREXT(I)=39;  /* <<< */
                END;
              ELSE
                X_O=X_O+1;
              FIN;
            ELSE
              X_O=X_O+1;
            FIN;
            IF X_O > N_KESSEL THEN
              B_LOOP='0'B;   /* Schleifenausstieg ohne Erlolg          */
            FIN;
          END;
        FIN;
      FIN;
    FIN;

  FIN;

/*********************************************************************/
/* Brauchwasserregelung:                                             */
/*********************************************************************/

  FOR I TO 4 REPEAT
    IF  Z_BWFREIEXT(I) > 0 THEN  Z_BWFREIEXT(I)=Z_BWFREIEXT(I)-1;  FIN;
    IF  Z_BWSPAREXT(I) > 0 THEN  Z_BWSPAREXT(I)=Z_BWSPAREXT(I)-1;  FIN;
    IF  Z_BWMOGLEXT(I) > 0 THEN  Z_BWMOGLEXT(I)=Z_BWMOGLEXT(I)-1;  FIN;
!   IF B_TM2 AND Z_BAKT > 0 THEN
!     Z_BWMOGLEXT(I)=20;
!   FIN;
  END;
  IF B_TM1 AND Z_BAKT > 0 THEN
    Z_BWFREIEXT( 1)=30;
    Z_BWFREIEXT( 2)=30;
    Z_BWFREIEXT( 3)=30;
    Z_BWFREIEXT( 4)=30;
  FIN;

  FOR I TO N_SPEI REPEAT   /* Legionellenanforderungen beruecksichtigen */
    IF Z_LEGIO(I) > 0 THEN
      Z_LEGIO(I)=Z_LEGIO(I)-1;
      IF TC_BWO(I) > TC_LEGIO(I) THEN
        Z_LEGIO(I)=0;
      FIN;
      IF Z_LEGIO(I) < 1 THEN
        Z_LEGNACH(I)=3000;
      FIN;
    FIN;
    IF Z_LEGNACH(I) > 0 THEN
      Z_LEGNACH(I)=Z_LEGNACH(I)-1;
    FIN;
    CASE I
      ALT 
        B_LOOP=B_ABSEIN(43);
      ALT 
        B_LOOP=B_ABSEIN(44);
      ALT 
        B_LOOP=B_ABSEIN(45);
      ALT 
        B_LOOP=B_ABSEIN(46);
      OUT
    FIN;
    IF B_LOOP THEN
      Z_LEGIO(I)=21600;
      Z_LEGNACH(I)=0;
    FIN;
  END;

  /* Sollwerte der einzelnen WW-Ladungen bestimmen */
  FOR I TO N_SPEI REPEAT
    CASE I
      ALT 
        B_LOOP=B_ABSEIN(33);
      ALT 
        B_LOOP=B_ABSEIN(34);
      ALT 
        B_LOOP=B_ABSEIN(35);
      ALT 
        B_LOOP=B_ABSEIN(36);
      OUT
    FIN;
    IF (Z_LEGIO(I) > 0 OR Z_LEGNACH(I) > 0) AND TC_LEGIO(I) > TC_BWSOLL(I) THEN
      TC_BWS(I)=TC_LEGIO(I);
    ELSE
      IF B_LOOP THEN  /* WW-Timer  */
        TC_BWS(I)=TC_BWSOLL(I);   /* WW Soll */
      ELSE
        TC_BWS(I)=TC_BWMIN(I);
      FIN;
    FIN;
    IF B_LOOP THEN  /* WW-Timer  */
      TC_BWZS(I)=TC_BWZRSOLL(I);  /* Zirk-RL-Soll */
      B_ZIRKPMP(I)='1'B;
    ELSE
      TC_BWZS(I)=TC_BWMIN(I)-6.0;
  !   B_ZIRKPMP(I)='0'B OR TC_AUSSEN < 0.0;
      B_ZIRKPMP(I)='1'B;  /* Zirkulation immer an <<< */
    FIN;
  END;

  
  

  FOR I TO N_SPEI REPEAT
    
    IF B_ZIRKPMP(I) THEN
      ABW=TC_BWZS(I)-TC_ZIRK(I);
 
      RA_WWZP(I)=ABW*RP_WWZ(I);
      Y_P=RA_WWZP(I);
  
      CALL FLOGRENZ(100.0,0.0001,RI_WWZ(I));  /* I-Anteil darf nicht 0 sein */
      RA_WWZI(I)=RA_WWZI(I)+(RI_WWZ(I)*ABW);           /* YI = YI + I * XD  */
      CALL FLOGRENZ(100.0,0.0,RA_WWZI(I));                                   
 
      Y_I=RA_WWZI(I); 
 
      /*    geglättet mit TAU                   DXD            *  D                      */
      RA_WWZDTAU(I)=(RA_WWZDTAU(I)*RTAU_WWZ(I)+(ABW-RA_WWZ1(I))*RD_WWZ(I))/(RTAU_WWZ(I)+1.0);
      Y_D=RA_WWZDTAU(I);        
 
      X_B= Y_P+Y_I+Y_D;
      CALL FLOGRENZ(100.0,0.0,X_B);  
 
      IF Z_LEGNACH(I) > 1 THEN
        X_B=100.0;
        RA_WWZI(I)=100.0;
      FIN;
 
      /* aktuelle Regelabweichung fuers naechste Mal merken          */
      RA_WWZ1(I)=ABW;
 
      XA_WWZI(I)=X_B;
    ELSE
      RA_WWZ1(I)=0.0;
      XA_WWZI(I)=0.0;
      RA_WWZP(I)=0.0;
      RA_WWZI(I)=0.0;
      RA_WWZDTAU(I)=0.0;
      XA_WWZI(I)=0.0;
    FIN;  /* ENDE B_ZIRKPMP  */
  
  END;


  B_BWANFGES='0'B;
  TC_BWVLSGES=0.0;
 
! FOR I TO N_SPEI REPEAT
  FOR I TO  0     REPEAT
 
    B_BWANF(I)='1'B;
    B_BWANFGES='1'B;
    TC_BWVLS(I)=TC_BWS(I)+TD_BWLS(I);
    IF TC_BWVLS(I) > TC_BWVLSGES THEN
      TC_BWVLSGES=TC_BWVLS(I);  
    FIN; 
   
    ABW=TC_BWS(I)-TC_BWO(I);
  
    RA_WWLP(I)=ABW*RP_WWL(I);
    Y_P=RA_WWLP(I);
 
    CALL FLOGRENZ(100.0,0.001,RI_WWL(I));  /* I-Anteil darf nicht 0 sein */
    RA_WWLI(I)=RA_WWLI(I)+(RI_WWL(I)*ABW);           /* YI = YI + I * XD  */
    CALL FLOGRENZ(100.0,0.0,RA_WWLI(I));                                   
 
    Y_I=RA_WWLI(I); 
 
    /*    geglättet mit TAU                   DXD            *  D                      */
    RA_WWLDTAU(I)=(RA_WWLDTAU(I)*RTAU_WWL(I)+(ABW-RA_WWL1(I))*RD_WWL(I))/(RTAU_WWL(I)+1.0);
    Y_D=RA_WWLDTAU(I);        
 
    X_B= Y_P+Y_I+Y_D;
    CALL FLOGRENZ(100.0,0.0,X_B);  
 
    /* aktuelle Regelabweichung fuers naechste Mal merken          */
    RA_WWL1(I)=ABW;
 
    XA_WWLAD(I)=X_B;
 
 !  IF I==1 THEN  /* WW1 ZENTR */
      X_A=TC_VIST;
      IF TC_BWVOR(I) > X_A THEN  /* <<< Lade VL > Hauptkr ?? */
        X_A=TC_BWVOR(I);
      FIN;
  !   IF X_AEIN(35) > X_A THEN  /* <<< Lade VL > Hauptkr ?? */
  !     X_A=X_AEIN(35);
  !   FIN;
 !  ELSE          /* WW2 UST */
 !    X_A=X_AEIN(35); /* PU O */
 !    IF X_AEIN(40) > X_A THEN  /* <<< Lade VL > Hauptkr ?? */
 !      X_A=X_AEIN(40);
 !    FIN;
 !  FIN;
 
    /* wenn Ladeueberhoehung < 3K dann auf 20% begrenzen */
    IF X_A < TC_BWS(I) + 3.0 AND X_A < TC_BWS(I) + TD_BWLS(I) AND TC_BWO(I) > X_A-5.0 THEN
      CALL FLOGRENZ(      20.0       ,0.0,XA_WWLAD(I));  
      CALL FLOGRENZ(      20.0       ,0.0,RA_WWLI(I));  
    FIN;
  
  END;
 
 
! FOR I TO N_SPEI REPEAT
  FOR I TO  0     REPEAT
    
    B_LPMP(I)='1'B;
    IF ZF_WWMI(I) < 2 THEN  /* NUR PUMPE NICHT!!  */
      ZF_WWMI(I)=2;
    FIN;
    IF ZF_WWMI(I) > 1 THEN  /* Mischer nutzen */
      IF ZF_WWMI(I) > 3 THEN  /* Regelung nur mit Mischer */
        XA_WWLADMI(I)=XA_WWLAD(I);
        XA_WWLADP(I)=80.0;
      ELSE
        X_A=XA_WWLAD(I)/0.20;   /* 0-20% XA_WWLAD -> 0-100% Mischer */
        CALL FLOGRENZ(100.0,0.0,X_A);  
        XA_WWLADMI(I)=X_A;
  
        X_A=XA_WWLAD(I)-15.0;   /* 0-15% XA_WWLAD -> Pumpe auf MIN */
        X_A=X_A/0.85;           /* 0-85 -> 0-100 */
        CALL FLOGRENZ(100.0,0.4,X_A);  
        XA_WWLADP(I)=X_A;                                          
      FIN;
 
      /* %Signal fuer Lademischer umsetzen in AUF/ZU <<< */
      B_LMIAUF(I)='0'B; B_LMIZU(I)='0'B;
      IF XA_WWLADMI(I)*(ZF_LMISTELL(I)*0.01) > Z_LMISTELL(I)+1 OR XA_WWLADMI(I) > 99.0 THEN
        B_LMIAUF(I)='1'B;
        IF Z_LMISTELL(I) < ZF_LMISTELL(I) THEN  Z_LMISTELL(I)=Z_LMISTELL(I)+1;  FIN;
      ELSE
        IF XA_WWLADMI(I)*(ZF_LMISTELL(I)*0.01) < Z_LMISTELL(I) OR XA_WWLADMI(I) < 1.0 THEN
          B_LMIZU(I)='1'B;
          IF Z_LMISTELL(I) > 0 THEN  Z_LMISTELL(I)=Z_LMISTELL(I)-1;  FIN;
        FIN;
      FIN;
 
      IF ZF_WWMI(I) == 3 OR ZF_WWMI(I) == 5 THEN  /* Mischer mit 2s Takt nutzen */
        B_LMIAUF(I)='0'B; B_LMIZU(I)='0'B;
        IF Z_LMISTELL(I) > Z_LMISTELL(I+10)+2 OR (Z_LMISTELL(I) > Z_LMISTELL(I+10) AND Z_LMISTELL(I+10) REM 2 > 0) OR Z_LMISTELL(I)+1 > ZF_LMISTELL(I) THEN
          B_LMIAUF(I)='1'B;
          IF Z_LMISTELL(I+10) < ZF_LMISTELL(I) THEN  Z_LMISTELL(I+10)=Z_LMISTELL(I+10)+1;  FIN;
        ELSE
          IF Z_LMISTELL(I) < Z_LMISTELL(I+10)-2 OR (Z_LMISTELL(I) < Z_LMISTELL(I+10) AND Z_LMISTELL(I+10) REM 2 > 0) OR Z_LMISTELL(I) < 1 THEN
            B_LMIZU(I)='1'B;
            IF Z_LMISTELL(I+10) > 0 THEN  Z_LMISTELL(I+10)=Z_LMISTELL(I+10)-1;  FIN;
          FIN;
        FIN;
      ELSE
        Z_LMISTELL(I+10)=Z_LMISTELL(I);
      FIN;
 
    ELSE  /* Mischer nicht nutzen  */
 
      XA_WWLADMI(I)=100.0;
      XA_WWLADP(I)=XA_WWLAD(I);
      B_LMIAUF(I)='1'B; 
      B_LMIZU(I)='0'B;
      Z_LMISTELL(I)=ZF_LMISTELL(I);
      Z_LMISTELL(I+10)=ZF_LMISTELL(I);
 
    FIN;
 
  END;


  /* Spezialbedingungen Lohkamp  */
! FOR I TO 4 REPEAT
!
!   ABW=TC_BWS(I)-TC_BWO(I);
!   IF DF_HKTH(I) > 0.15 OR ABW < -(FL_EXPHK(13)-0.5) THEN  /* <<< ZIRKP auf MAX  */
!     XA_WWZI(I)=100.0;
!   FIN;
!   IF ABW < -FL_EXPHK(13) AND ABW < RA_BWALT(I) AND DF_HKTH(I) < 0.20 THEN  /* Ladep AUS wenn viel zu warm */
!     XA_WWLADP(I)=0.0;
!   FIN;
!   IF ABW > FL_EXPHK(14) AND ABW > RA_BWALT(I) THEN       /* Ladep P+ wenn viel zu kalt */
!     XA_WWLADP(I)=XA_WWLADP(I)+(ABW-FL_EXPHK(14))*10.0;
!     CALL FLOGRENZ(100.0,0.0,XA_WWLADP(I));  
!   FIN;
!   RA_BWALT(I)=ABW;
!
! END;





! IF  1 > 2    THEN
  IF B_TAKT4 THEN

    /* Zust„nde vorerst zuruecksetzen:                                */
    B_BWMOGLG='0'B; /* Laden m”glich gesamt                          */
    B_BWNORMG='0'B; /* Laden normal gesamt                           */
    B_BWDRIGG='0'B; /* Laden dringend gesamt                         */
    TC_B=100.0;     /* erstmal auf einen hohen Wert setzen           */

    /* Ladezustand der einzelnen Speicher ermitteln:                 */
    FOR I TO N_SPEI REPEAT    

      TD_BWB(I)=0.5;

      /* Brauchwasserladen dringend testen:                          */
      IF TC_BWO(I) < TC_BWS(I) - TD_BWDRIG(I) THEN
        B_BWDRIG(I)='1'B;
      FIN;
      IF TC_BWO(I) > TC_BWS(I) - (TD_BWDRIG(I)-1.5) THEN
        B_BWDRIG(I)='0'B;
      FIN;

      /* Brauchwasserladen normal testen:                            */
      IF TC_BWO(I) < TC_BWS(I) -TD_BWNORM(I) THEN
        B_BWNORM(I)='1'B;
      FIN;
      IF TC_BWO(I) > TC_BWS(I) +TD_BWB(I) THEN
        B_BWNORM(I)='0'B;
      FIN;

      /* Brauchwasserladen m”glich testen:                           */
      IF TC_BWO(I)<TC_BOMAX(I)-2.0 THEN
        B_BWMOGL(I)='1'B;
      FIN;
      IF TC_BWO(I)>TC_BOMAX(I) THEN
        B_BWMOGL(I)='0'B;
      FIN;

      /* Brauchwasserladen nacht testen:                           */
      IF TC_BWO(I)<TC_BWMIN(I) -TD_BWNORM(I) THEN
        B_BWNACHT(I)='1'B;
      FIN;
      IF TC_BWO(I)>TC_BWMIN(I)+1.5 OR NOT B_BWNORM(I) THEN
        B_BWNACHT(I)='0'B;
      FIN;

    END;

    /* Steuerung der Ladepumpen:                                     */
    B_BWANFGES='0'B;   /* Anforderung vorerst zuruecknehmen              */
    TC_BWVLSGES=0.0;   /* Vorlaufsoll ruecksetzen                        */
    FOR I TO N_SPEI REPEAT    

    /* Steuerung der Ladepumpen:                                     */

      TC_BWVLS(I)=0.0;
      B_BWANF(I)='0'B;

      IF B_BWDRIG(I) OR B_BWNORM(I) OR B_BWNACHT(I) OR B_TM1 OR NOT B_WA THEN
        /* Brauchwasservorlaufsoll bestimmen und anfordern:          */
        IF B_BWNORM(I) OR B_BWDRIG(I) OR B_BWNACHT(I) THEN       
          IF TC_BWS(I) + TD_BWLS(I) > TC_BWVLSGES THEN
            TC_BWVLSGES= TC_BWS(I) + TD_BWLS(I);
          FIN;
          TC_BWVLS(I)=TC_BWS(I)+TD_BWLS(I);
          B_BWANF(I)='1'B;
          B_BWANFGES='1'B;
        FIN;

        FL1=TC_VIST;
        IF TC_BWVOR(I) > FL1 THEN
     !    FL1=TC_BWVOR(I);  /* Lade VL > Hauptkreis ? */
          FL1=X_AEIN(27);   /* SPORTHALLE VL > Hauptkreis ? */
        FIN;
        /* Ist der Hauptkreis warm genug zum Brauchwasser laden ?    */
        /* mit TD_BWTOO und TD_BWTOU wird eine Hysterese eingestellt */
        /* die den Ladevorgang ingangsetzen und unterbrechen kann    */
        IF FL1 > TC_BWO(I) + TD_BWTOO(I) THEN
          B_BWB(I)='1'B;
        FIN;
        IF FL1 < TC_BWO(I) + TD_BWTOU(I) THEN
          B_BWB(I)='0'B;
        FIN;

        /* Brauchwasserladepumpe einschalten wenn W„rmevernichtung   */
        /* oder keine W„rmeanforderung und aktueller Speicher noch   */
        /* geladen werden kann und keine normale oder dringende      */
        /* Gesamtanforderung ansteht oder der aktuelle Speicher mu~  */
        /* oder Anforderung dringend                                 */
        /* oder Anforderung normal                                   */
        /* oder Anforderung Mindestwert                              */
        /* UND Temperatur reicht zum laden                           */
        B_PMP=    (  ((B_TM1 OR NOT B_WA) AND B_BWMOGL(I) AND
                       NOT B_BWNORMG AND NOT B_BWDRIGG AND Z_BAKT > 0 )
                   OR  B_TM3 AND B_BWMOGL(I)                      
                   OR  B_BWDRIG(I)                               
                   OR  B_BWNORM(I)
                   OR  B_BWNACHT(I)
                   OR  Z_LEGIO(I) > 0
                   OR  Z_LEGNACH(I) > 0 )
                  AND  B_BWB(I);                                            
                  

        /* Pumpensteuerung fuer innenliegende W„rmetauscher:          */
        B_LPMP(I)=B_PMP;    /* Ladepumpe des aktuellen Speichers     */

        /* <<< Ladepumpen-Ansteuerung nach RL */
     !  IF I==2 THEN
     !    IF B_LPMP(I) THEN
     !      XA_WWLADP(I)=50.0-(TC_BWRUECK(I)-TC_BWRSOLL(I))*15.0; 
     !      CALL FLOGRENZ(100.0,0.4,XA_WWLADP(I));  
     !      IF B_BWDRIG(I) THEN
     !        XA_WWLADP(I)=100.0;
     !      FIN;
     !    ELSE
     !      XA_WWLADP(I)=0.0; 
     !    FIN;
     !  FIN;


!       IF I == 1          THEN   /* dann kontinuierlich   <<< */
        IF 1 > 2 THEN

          /*------------------ Analogausgang --------------------------*/
          IF B_LPMP(I) THEN                                        /*  */
            B_SPMP(I)='1'B;                                        /*  */
            CALL FLOGRENZ(100.0,0.3,XA_WWSPEIP(I));  
            X_A=XA_WWLADP(I)/XA_WWSPEIP(I);                      /*  */
                                                                 /*  */
            /* die Speisesolltemp. bestimmen                     /*  */
            IF (B_BWDRIG(I) OR B_BWNORM(I) OR B_BWNACHT(I) OR Z_LEGIO(I) > 0 OR Z_LEGNACH(I) > 0) AND NOT B_TM3 THEN   /*  */
              TC_BWTW(I)=TC_BWS(I)   +TD_BWTW(I);                 /*  */
            ELSE                  /* wenn moeglich geladen werden soll*/
              /* dann sollen moeglichst beide Pumpen auf 100% laufen  */
              IF     TC_BWIST(I) > TC_BWSOLL(I)                  /*    */
                 AND TC_BWIST(I) < TC_BOMAX(I) THEN              /*    */
                IF X_A>1.0 THEN                                  /*    */
                  TC_BWTW(I)=TC_BWIST(I)-1.0;                    /*    */
                ELSE                                             /*    */
                  TC_BWTW(I)=TC_BWIST(I)+1.0;                    /*    */
                FIN;                                             /*    */
              ELSE                                               /*    */
                TC_BWTW(I)=TC_BOMAX(I);  /* dann hoeheren Wert         */
              FIN;                                             /*    */
              X_CALT(I)=TC_BWIST(I)/TC_BWTW(I); /* bei m”glich ohne D-Ant. */
            FIN;                                               /*    */
            X_C=TC_BWIST(I)/TC_BWTW(I);   /* neues Verh„ltnis bestimmen */
                                                                 /*  */
            X_B=1.0+(X_C-1.0)*RP_BWL(I)+(X_C-X_CALT(I))*RD_BWL(I);  /*  */
            IF X_B<0.01 THEN                                     /*  */
              X_B=0.01;                                          /*  */
            FIN;                                                 /*  */      
            X_A=X_A/X_B;                                         /*  */
                                                                 /*  */
            X_CALT(I)=X_C;                                       /*  */
                                                                 /*  */
            X_B=100.0;   /* eine der Pumpen laeuft auf 100%          */
            IF X_A > 1.0 THEN                                    /*  */
              XA_WWLADP(I)=X_B;                                  /*  */
              XA_WWSPEIP(I)=X_B/X_A;                             /*  */
            ELSE                                                 /*  */
              XA_WWSPEIP(I)=X_B;                                 /*  */
              XA_WWLADP(I)=X_B*X_A;                              /*  */
            FIN;                                                 /*  */
                                                                   /*  */
            IF TC_BWIST(I) > TC_BOMAX(I)+5.0 AND Z_LEGIO(I) < 10 AND Z_LEGNACH(I) < 10 THEN   /*  */
              B_LPMP(I)='0'B;  /* NOT-AUS Ladepumpe bei Speisetemp viel zu hoch   */
            FIN;                                                        /*  */
            CALL FLOGRENZ(100.0, 4.0,XA_WWLADP(I));  /* auf sinnvolle Werte */
            CALL FLOGRENZ(100.0, 4.0,XA_WWSPEIP(I)); /* begrenzen           */
          ELSE                                                     /*  */
            B_SPMP(I)='0'B;                                        /*  */
            TC_BWTW(I)=0.0;                                        /*  */
          FIN;                                                     /*  */
        FIN;

      ELSE /* dieser Speicher soll nicht geladen werden:             */
        B_LPMP(I)='0'B OR B_PUMPSCH;     /* aus oder Pumpenschonung  */
        B_SPMP(I)='0'B OR B_PUMPSCH;     /* aus oder Pumpenschonung  */
        TC_BWTW(I)=0.0;  
        XA_WWLADP(I)=0.0;                                  /*  */
        XA_WWSPEIP(I)=0.0;                                 /*  */
      FIN;

    END;


  FIN;



  /* falls die Speicheraustrittstemp viel zu klein wird, dann die Grenzen */
  /* fuer die Zuschaltung weiterer Waermeerzeuger herabsetzen   <<<       */
! IF B_BWANF(1) AND B_ZIRKPMP(1) AND X_AEIN(32) < TC_BWSOLL(1)-TD_BWDRIG(1) THEN
!   Z_BWKALT=Z_BWKALT+1;
!   CALL FIXGRENZ(1000,0,Z_BWKALT);  
! ELSE  
!   Z_BWKALT=Z_BWKALT-1;
!   CALL FIXGRENZ(105,0,Z_BWKALT);  
! FIN;
  Z_BWKALT=0;
  

/*********************************************************************/
/* Mischerregelung                                                   */
/*********************************************************************/

  IF B_TAKT4 THEN 
    Z_PMPHK=0;     /* Z„hler fuer laufende Heizkreispumpen            */

     
    /* GESAMTE HEIZUNG AUS ? */
    IF B_JAHRAB(DA_MON,DA_DAT).BIT(32) THEN
      IF TC_AUSSEN > 3.5 THEN
        B_HMN(32)='0'B;
      FIN;
      IF TC_AUSSEN < 3.0 THEN
        B_HMN(32)='1'B;
      FIN;
    ELSE
      B_HMN(32)='1'B;
    FIN;
     
 !  FOR I TO N_HZKR REPEAT /* alle Heizkreise regeln  <<<          */
    FOR I TO  4     REPEAT /* alle Heizkreise regeln  <<<          */

      B_LOOP= B_HMN(32)                  
               AND B_HMT(I)                  
               AND(  NOT B_ABSHK(I)
                OR B_TAERHK(I)
                OR B_VORHK(I)
                OR B_RUNTHK(I)
                OR B_HMN(I));  


      IF I==4 THEN  /* TROCKNUNG        */
        /* TIMER ZWANG     WAERMEVERNICHTUNG */ 
        IF B_ABSEIN(61) OR B_PMPHK(11) THEN
          B_LOOP='1'B;
        FIN;
        IF NOT BI_DEINBEW(16) OR ZF_HKPEXT(32)==4 THEN /* NOT-AUS TROCHN  ODER  HK-REF=PU4 */
          B_LOOP='0'B;
        FIN;
      FIN;

      IF I==2 THEN  /* HK2 mit TROCKNUNG dran       */
        /* TIMER ZWANG     WAERMEVERNICHTUNG */ 
        IF (B_ABSEIN(61) OR B_PMPHK(11)) AND BI_DEINBEW(16) AND ZF_HKPEXT(32) < 4 THEN
          B_LOOP='1'B;
        FIN;
      FIN;


      /* <<< EINFLUSS MODBUS */
      IF ZF_HKPEXT(I) > 0 THEN   B_LOOP='1'B;   FIN;
      IF ZF_HKPEXT(I) < 0 THEN   B_LOOP='0'B;   FIN;

      IF B_LOOP  
              
      THEN

        B_PMPHK(I)='1'B;   /* Heizkreispumpe einschalten und       */
        Z_PMPHK=Z_PMPHK+1; /* Z„hler fuer aktive Pumpen erh”hen     */


        /* aktuelle Regelabweichung ermitteln                      */
        /* Sollwert mit dem langfristigen Integrator korrigieren   */
        TC_HKSOLLGES(I)=TC_HKSOLL(I)+TD_HKINT(I);
        CALL FLOGRENZ(TC_HKVNENN(I),0.0,TC_HKSOLLGES(I));  /* auf TC_HKVNENN begrenzen */

        ABW=TC_HKSOLLGES(I)-TC_HKIST(I);  /* XD */

        /* <<< TROCKNUNG */
        IF I==4 THEN    /* FESTER ZULUFTSOLLWERT  */
          TC_HKSOLLGES(4)=TC_HKVNENN(4);
          ABW=TC_HKSOLLGES(4)-TC_HKIST(4);  
          TD_HKINT(I)=0.0;
        FIN;

    !   /* <<< FREIBAD */
    !   IF I==7 THEN       /* SOLL     + ZUSCHLAG   +(  SOLL      - IST(RL)  )* FAKTOR  */
    !     TC_HKSOLLGES(22)=FL_EXPHK(22)+FL_EXPHK(24)+(FL_EXPHK(22)-X_AEIN(45))*FL_EXPHK(26);
    !     CALL FLOGRENZ(FL_EXPHK(22)+15.0,0.0,TC_HKSOLLGES(22)); 
    !     ABW=TC_HKSOLLGES(22)-X_AEIN(44);  /* BADVL-SOLL - BADVL-IST */
    !     TD_HKINT(I)=0.0;
    !   FIN;


        /* Brauchwasservorrangregelung wenn Hauptkreis zu kalt zum   */
        /* Brauchwasserladen und thermische Durchschnittsleistung    */
        /* kleiner als aktuell moegliche th. BHKW-Leistung und die   */
        /* thermische Istleistung groesser als die thermische Durch- */
        /* schnittsleistung ist                                      */
     !  IF B_BWANFGES AND TC_VIST < TC_BWVLSGES-6.0
     !     AND PT_SCHNITT < PE_BMAXMOGL*(PT_GRUND+PT_FAKTOR-0.2)
     !     AND PT_AKT > PT_SCHNITT THEN
     !    ABW=-1.0;
     !  FIN;
   
        RA_MP(I)=ABW*RP_M(I);
        Y_P=RA_MP(I);
      
        CALL FLOGRENZ(100.0,0.0001,RI_M(I));  /* I-Anteil darf nicht 0 sein */
        RA_MI(I)=RA_MI(I)+(RI_M(I)*ABW);           /* YI = YI + I * XD  */
        CALL FLOGRENZ(100.0,0.0,RA_MI(I));                                   
   
        Y_I=RA_MI(I); 
    
        /*    geglättet mit TAU                DXD           *  D                      */
        RA_MDTAU(I)=(RA_MDTAU(I)*RTAU_M(I)+(ABW-RA_M1(I))*RD_M(I))/(RTAU_M(I)+1.0);
        Y_D=RA_MDTAU(I);        
   
        X_B= Y_P+Y_I+Y_D;
        CALL FLOGRENZ(100.0,0.0,X_B);  
  
        /* aktuelle Regelabweichung fuers naechste Mal merken          */
        RA_M1(I)=ABW;
   
        XA_HKMI(I)=X_B;

        /* langfristigen Integrator fuer die Abweichung aufint.     */
        TD_HKINT(I)=TD_HKINT(I)+(TC_HKSOLL(I)-TC_HKIST(I))*0.001;
        CALL FLOGRENZ(TD_HKINTMAX(I),TD_HKINTMIN(I),TD_HKINT(I));  

      ELSE
        B_PMPHK(I)='0'B OR B_PUMPSCH;      /* Heizkreispumpe aus   */
        RA_MP(I)=0.0;
        RA_MI(I)=0.0;
        RA_MDTAU(I)=0.0;
        XA_HKMI(I)=0.0;
        TC_HKSOLLGES(I)=TC_HKSOLL(I);
      FIN;


    END;



 !  FOR I FROM 21 TO 21 REPEAT /* PRIMAERPUMPE regeln  <<<          */
 !
 !    B_LOOP= B_PMPHK(1) OR B_PMPHK(2) OR B_PMPHK(3) OR B_PMPHK(4) OR B_PMPHK(5) OR B_PMPHK(6);                  
 !
 !    FL1=0.0;
 !    FOR K TO 6 REPEAT
 !      IF TC_HKSOLLGES(K) > FL1 THEN
 !        FL1=TC_HKSOLLGES(K);
 !      FIN;
 !    END;
 !    TC_HKSOLLGES(I)=FL1;
 !
 !    IF B_LOOP  
 !            
 !    THEN
 !
 !      B_PMPHK(I)='1'B;   /* Heizkreispumpe einschalten und       */
 !      Z_PMPHK=Z_PMPHK+1; /* Z„hler fuer aktive Pumpen erh”hen     */
 !
 !
 !      ABW=TC_HKSOLLGES(I)-TC_HKIST(I);  /* XD */
 !
 !      IF XA_HKMI(I) < 0.3 THEN   /* <<< */
 !        Z_FREECOUNT(40)=15;
 !      FIN;
 !      IF Z_FREECOUNT(40) > 0 THEN
 !        Z_FREECOUNT(40)=Z_FREECOUNT(40)-1;
 !        IF ABW > 0.2 THEN
 !          ABW=0.2;
 !        FIN;
 !      FIN;
 !        
 !
 !      RA_MP(I)=ABW*RP_M(I);
 !      Y_P=RA_MP(I);
 !    
 !      CALL FLOGRENZ(100.0,0.0001,RI_M(I));  /* I-Anteil darf nicht 0 sein */
 !      RA_MI(I)=RA_MI(I)+(RI_M(I)*ABW);           /* YI = YI + I * XD  */
 !      CALL FLOGRENZ(100.0,0.0,RA_MI(I));                                   
 ! 
 !      Y_I=RA_MI(I); 
 !  
 !      /*    geglättet mit TAU                DXD           *  D                      */
 !      RA_MDTAU(I)=(RA_MDTAU(I)*RTAU_M(I)+(ABW-RA_M1(I))*RD_M(I))/(RTAU_M(I)+1.0);
 !      Y_D=RA_MDTAU(I);        
 ! 
 !      X_B= Y_P+Y_I+Y_D;
 !      CALL FLOGRENZ(100.0,0.0,X_B);  
 !
 !      /* aktuelle Regelabweichung fuers naechste Mal merken          */
 !      RA_M1(I)=ABW;
 ! 
 !      XA_HKMI(I)=X_B;
 !
 !      X_A=TC_VIST;
 !      IF X_AEIN(14) > X_A THEN  /* <<< Hauptkreis prim VL > Hauptkr ?? */
 !        X_A=X_AEIN(14);
 !      FIN;
 !
 !      /* wenn ueberhoehung < 3K dann auf 10% begrenzen */
 !      IF X_A < TC_HKSOLLGES(I) + 3.0 AND TC_HKIST(I) > X_A-6.0 THEN
 !        CALL FLOGRENZ(      10.0       ,0.0,XA_HKMI(I));  
 !        CALL FLOGRENZ(      10.0       ,0.0,RA_MI(I));  
 !      FIN;
 !
 !    ELSE
 !      B_PMPHK(I)='0'B OR B_PUMPSCH;      /* Heizkreispumpe aus   */
 !      RA_MP(I)=0.0;
 !      RA_MI(I)=0.0;
 !      RA_MDTAU(I)=0.0;
 !      XA_HKMI(I)=0.0;
 !      TC_HKSOLLGES(I)=0.0;           
 !    FIN;
 !
 !
 !  END;

  
  FIN; /* Ende der Mischerregelung      */
  


  /* das eigentliche Schalten der Mischerausg„nge passiert alle 2SEC  */
  FOR I TO  4     REPEAT
! FOR I TO N_HZKR REPEAT
          
    IF B_TAKT2 THEN        /* Analogsignal fuer Mischer alle 2 s umsetzen in AUF / ZU */
      IF XA_HKMI(I)*1.000*(ZF_HKMISTELL(I)*0.01) > Z_HKMISTELL(I)+1 THEN    /** nach Regler: AUF noetig **/
        IF NOT B_MIZU(I) THEN
           B_MIAUF(I)='1'B;                                                   /* AUF wenn nicht gerade ZU war */
        ELSE
           B_MIZU(I)='0'B;                                                    /* sonst ZU zuruecknehmen */
        FIN;
      ELSE
        IF XA_HKMI(I)*1.000*(ZF_HKMISTELL(I)*0.01) < Z_HKMISTELL(I) THEN    /** nach Regler: ZU noetig **/
          IF NOT B_MIAUF(I) THEN
            B_MIZU(I)='1'B;                                                   /* ZU wenn nicht gerade AUF war */
          ELSE
            B_MIAUF(I)='0'B;                                                  /* sonst AUF zuruecknehmen */
          FIN;
        ELSE                                                                /** nach Regler kein Stellbedarf **/
          B_MIAUF(I)='0'B;
          B_MIZU(I)='0'B;                                                     /* beide Ausgaenge Null setzten */
        FIN;
      FIN;
    FIN;

    IF XA_HKMI(I) < 1.0 THEN      /* unteres Ende des Regelbereichs */
      IF NOT B_MIAUF(I) THEN
        B_MIZU(I)='1'B;           /* zu, wenn nicht vom letzten Durchlauf oder aus B_TAKT2 'AUF' war */
      ELSE
        B_MIAUF(I)='0'B;          /* AUF jedenfalls zuruecknehmen */
      FIN;
  !   IF XA_HKMI(I) < 1.0 AND B_TAKT10 THEN B_MIZU(I)='0'B; FIN; /* <<<< alle 10 s Relais ausschalten, falls es hängt */
    ELSE
      IF XA_HKMI(I) >99.0 THEN    /* oberes Ende des Regelbereichs */
        IF NOT B_MIZU(I) THEN
          B_MIAUF(I)='1'B;        /* auf, wenn nicht vom letzten Durchlauf oder aus B_TAKT2 'ZU' war */
        ELSE
          B_MIZU(I)='0'B;         /* ZU jedenfalls zuruecknehmen */
        FIN;
      ELSE
        IF NOT B_TAKT2 THEN       /* Schaltungen aus B_TAKT2 zuruecksetzen; wenn nicht am Ende des Regelbereichs */
          B_MIAUF(I)='0'B;
          B_MIZU(I)='0'B;
        FIN;
      FIN;
    FIN;

    IF ZF_HKMIEXT(I) < 0  THEN   B_MIAUF(I)='0'B; B_MIZU(I)='0'B;  FIN;   /* <<< EINFLUSS MODBUS keine Ansteuerung */
    IF ZF_HKMIEXT(I) == 1 THEN   B_MIAUF(I)='1'B; B_MIZU(I)='0'B;  FIN;   /* <<< EINFLUSS MODBUS Dauer AUF         */
    IF ZF_HKMIEXT(I) >  1 THEN   B_MIAUF(I)='0'B; B_MIZU(I)='1'B;  FIN;   /* <<< EINFLUSS MODBUS Dauer ZU          */

    IF B_MIAUF(I) THEN
      IF Z_HKMISTELL(I) < ZF_HKMISTELL(I) THEN  Z_HKMISTELL(I)=Z_HKMISTELL(I)+1;  FIN;
    ELSE
      IF B_MIZU(I) THEN
        IF Z_HKMISTELL(I) > 0 THEN  Z_HKMISTELL(I)=Z_HKMISTELL(I)-1;  FIN;
      FIN;
    FIN;

  END; 

  /* das eigentliche Schalten der Mischerausg„nge passiert alle 2SEC  */
 !FOR I TO  3     REPEAT
! FOR I TO N_HZKR REPEAT
! ! B_MIAUF(I)='0'B; B_MIZU(I)='0'B;
! ! IF I== 32 THEN /* <<< HK4 Kombi aus Pumpe und Mischer (33% fuer Mischer) */
! !   IF B_TAKT2 OR XA_HKMI(I) > 33.0 OR XA_HKMI(I) < 1.0 THEN
! !     /* Analogsignal fuer Mischer umsetzen in AUF/ZU <<< */
! !     IF XA_HKMI(I)*3.0*(ZF_HKMISTELL(I)*0.01) > Z_HKMISTELL(I)+1 OR XA_HKMI(I) > 33.0 THEN
! !       B_MIAUF(I)='1'B;
! !     ELSE
! !       IF XA_HKMI(I)*3.0*(ZF_HKMISTELL(I)*0.01) < Z_HKMISTELL(I) OR XA_HKMI(I) < 1.0 THEN
! !         B_MIZU(I)='1'B;
! !       FIN;
! !     FIN;
! !   FIN;
! ! ELSE
! !   IF B_TAKT2 OR XA_HKMI(I) > 99.0 OR XA_HKMI(I) < 1.0 THEN
! !     /* Analogsignal fuer Mischer umsetzen in AUF/ZU <<< */
! !     IF XA_HKMI(I)*(ZF_HKMISTELL(I)*0.01) > Z_HKMISTELL(I)+1 OR XA_HKMI(I) > 99.0 THEN
! !       B_MIAUF(I)='1'B;
! !     ELSE
! !       IF XA_HKMI(I)*(ZF_HKMISTELL(I)*0.01) < Z_HKMISTELL(I) OR XA_HKMI(I) < 1.0 THEN
! !         B_MIZU(I)='1'B;
! !       FIN;
! !     FIN;
! !   FIN;
! ! FIN;
!
!   B_LOOP=B_MIAUF(I) OR B_MIZU(I);   /* einer WAR geschaltet ? */
!   B_MIAUF(I)='0'B; B_MIZU(I)='0'B;
!   IF B_TAKT2 OR XA_HKMI(I) > 99.0 OR XA_HKMI(I) < 1.0 THEN
!     /* Analogsignal fuer Mischer umsetzen in AUF/ZU <<< */
!     IF XA_HKMI(I)*(ZF_HKMISTELL(I)*0.01) > Z_HKMISTELL(I)+1 OR XA_HKMI(I) > 99.0 THEN
!       B_MIAUF(I)='1'B;
!       IF Z_HKMISTELL(I) < ZF_HKMISTELL(I) THEN  Z_HKMISTELL(I)=Z_HKMISTELL(I)+1;  FIN;
!     ELSE
!       IF XA_HKMI(I)*(ZF_HKMISTELL(I)*0.01) < Z_HKMISTELL(I) OR XA_HKMI(I) < 1.0 THEN
!         B_MIZU(I)='1'B;
!         IF Z_HKMISTELL(I) > 0 THEN  Z_HKMISTELL(I)=Z_HKMISTELL(I)-1;  FIN;
!       FIN;
!     FIN;
!   FIN;
!   IF (XA_HKMI(I) < 99.0 AND XA_HKMI(I) > 60.0 AND B_LOOP) OR (XA_HKMI(I) < 40.0 AND XA_HKMI(I) > 1.0 AND B_LOOP) THEN
!     B_MIAUF(I)='0'B; B_MIZU(I)='0'B;
!   FIN;
!
!   IF ZF_HKMIEXT(I) < 0  THEN   B_MIAUF(I)='0'B; B_MIZU(I)='0'B;  FIN;   /* <<< EINFLUSS MODBUS keine Ansteuerung */
!   IF ZF_HKMIEXT(I) == 1 THEN   B_MIAUF(I)='1'B; B_MIZU(I)='0'B;  FIN;   /* <<< EINFLUSS MODBUS Dauer AUF         */
!   IF ZF_HKMIEXT(I) >  1 THEN   B_MIAUF(I)='0'B; B_MIZU(I)='1'B;  FIN;   /* <<< EINFLUSS MODBUS Dauer ZU          */
!
!   IF B_MIAUF(I) THEN
!     IF Z_HKMISTELL(I) < ZF_HKMISTELL(I) THEN  Z_HKMISTELL(I)=Z_HKMISTELL(I)+1;  FIN;
!   ELSE
!     IF B_MIZU(I) THEN
!       IF Z_HKMISTELL(I) > 0 THEN  Z_HKMISTELL(I)=Z_HKMISTELL(I)-1;  FIN;
!     FIN;
!   FIN;
!
! END; 


! FOR I FROM 3 TO   5    REPEAT    /* <<< HK3 WEST  HK4 FLUR  HK5 SUED haben Mischer mit analoger Anst. */
!
!   IF ZF_HKMIEXT(I) < 0  THEN   XA_HKMI(I)=0.0;  FIN;           /* <<< EINFLUSS MODBUS keine Ansteuerung */
!   IF ZF_HKMIEXT(I) > 0  THEN   XA_HKMI(I)=ZF_HKMIEXT(I); FIN;  /* <<< EINFLUSS MODBUS fester Wert       */
!
! END; 


  /*******************************************************************/
  /*  Kessel- und BHKW-Ruecklaufanhebung                              */
  /*******************************************************************/

! FOR I O N_KESSEL REPEAT
  FOR I FROM 3 TO N_KESSEL REPEAT
    B_KESMIA(I)='0'B;
    B_KESMIZ(I)='0'B;
    IF B_KPMP(I) THEN
      B_KESMIA(I)=   B_KPMP(I) AND TC_KR(I) > TC_KRMIN(I)+7.0
                   OR B_KPMP(I) AND TC_KR(I) > TC_KRMIN(I)+4.0 AND B_TAKT3 
                   OR B_KPMP(I) AND TC_KR(I) > TC_KRMIN(I)+0.0 AND B_TAKT10;
      IF NOT B_KESMIA(I) THEN
        B_KESMIZ(I)=   NOT B_KEIN(I) AND Z_KPNL(I) < 1
                     OR B_KEIN(I) AND TC_KR(I) < TC_KRMIN(I)-8.0 AND B_TAKT3
                     OR B_KEIN(I) AND TC_KR(I) < TC_KRMIN(I)-20.0
                     OR B_KEIN(I) AND TC_KR(I) < TC_KRMIN(I)-2.0 AND B_TAKT10;
      FIN;
    ELSE
      B_KESMIZ(I)='1'B;
    FIN;
    IF B_KESMIA(I) THEN
      IF Z_KMISTELL(I)<120 THEN Z_KMISTELL(I)=Z_KMISTELL(I)+1; FIN;
    FIN;
    IF B_KESMIZ(I) THEN
      IF Z_KMISTELL(I)>0   THEN Z_KMISTELL(I)=Z_KMISTELL(I)-1; FIN;
    FIN;
  END;



  FOR I TO N_BHKW REPEAT
    B_BHKWMIA(I)='0'B;
    B_BHKWMIZ(I)='0'B;
    B_BHKWMIA(I)=   B_BL(I) AND TC_BHZGR(I) > TC_BRMIN+6.0
                 OR B_BL(I) AND TC_BHZGR(I) > TC_BRMIN+2.0 AND B_TAKT5
                 OR (Z_BPNL(I)>0 AND NOT B_BL(I));

    IF NOT B_BHKWMIA(I) THEN
      B_BHKWMIZ(I)=   NOT B_BL(I) AND Z_BPNL(I)<1
                   OR B_BL(I) AND TC_BHZGR(I) < TC_BRMIN AND B_TAKT3;
    FIN;
  END;


  /*******************************************************************/
  /*  Softwareendkontakte fuer die Mischer von Kessel, BHKW und HK    */
  /*******************************************************************/
  FOR I TO N_HZKR REPEAT
    IF B_MIAUF(I) THEN
      Z_HKMI(I)=Z_HKMI(I)+1;
      IF Z_HKMI(I)<0 THEN  Z_HKMI(I)=Z_HKMI(I)+1;  FIN;
    FIN;
    IF B_MIZU(I) THEN
      Z_HKMI(I)=Z_HKMI(I)-1;
      IF Z_HKMI(I)>0 THEN  Z_HKMI(I)=Z_HKMI(I)-1;  FIN;
    FIN;
    IF Z_HKMI(I) > 600 THEN
      B_MIAUF(I)='0'B;
      Z_HKMI(I)= 600;
    FIN;
    IF Z_HKMI(I) < -600 THEN
      B_MIZU(I)='0'B;
      Z_HKMI(I)= -600;
    FIN;
  END;

  FOR I TO N_KESSEL REPEAT
    IF B_KESMIA(I) THEN
      Z_KESMI(I)=Z_KESMI(I)+1;
      IF Z_KESMI(I)<0 THEN  Z_KESMI(I)=Z_KESMI(I)+1;  FIN;
    FIN;
    IF B_KESMIZ(I) THEN
      Z_KESMI(I)=Z_KESMI(I)-1;
      IF Z_KESMI(I)>0 THEN  Z_KESMI(I)=Z_KESMI(I)-1;  FIN;
    FIN;
    IF Z_KESMI(I) > 600 THEN
      B_KESMIA(I)='0'B;
      Z_KESMI(I)= 600;
    FIN;
    IF Z_KESMI(I) < -600 THEN
      B_KESMIZ(I)='0'B;
      Z_KESMI(I)= -600;
    FIN;
  END;

  FOR I TO N_BHKW REPEAT
    IF B_BHKWMIA(I) THEN
      Z_BHKWMI(I)=Z_BHKWMI(I)+1;
      IF Z_BHKWMI(I)<0 THEN  Z_BHKWMI(I)=Z_BHKWMI(I)+1;  FIN;
    FIN;
    IF B_BHKWMIZ(I) THEN
      Z_BHKWMI(I)=Z_BHKWMI(I)-1;
      IF Z_BHKWMI(I)>0 THEN  Z_BHKWMI(I)=Z_BHKWMI(I)-1;  FIN;
    FIN;
    IF Z_BHKWMI(I) > 600 THEN
      B_BHKWMIA(I)='0'B;
      Z_BHKWMI(I)= 600;
    FIN;
    IF Z_BHKWMI(I) < -600 THEN
      B_BHKWMIZ(I)='0'B;
      Z_BHKWMI(I)= -600;
    FIN;
  END;


/*********************************************************************/
/* BHKW-Leistungsregelung                                            */
/*********************************************************************/

  IF B_TM3 THEN /* Falls T max ueberschritten ist:                    */
    X_B        =PE_RMIN;         /* Solleistung untere Regelgrenze   */
  ELSE
    /* wenn Leistungsregelersperre aktiv und nicht Betrieb nach      */
    /* Strombedarf, dann maximale Leistung der aktiven BHKW anfordern*/
    IF Z_LRSPERR > 0 AND NOT B_SB THEN
      X_B        =PE_MAX;
    ELSE
      /* wenn Tein aktiv dann Strombedarf abfahren                   */
      IF Z_TEIN > 0 THEN
        X_B        =PE_BEDARF-0.5; /* Solleistung=Bedarf des Objekts     */
        IF X_B        <PE_RMIN1B THEN /* Leistungsgrenze unterschr.: */
          X_B        =PE_RMIN1B;
        FIN;
      ELSE /* Leistungsregelung ist freigegeben:                     */
        IF B_SB THEN /* Regelung nach Strombedarf                    */
          IF PE_BEDARF<=PE_MIN THEN
            /* Falls die Leistungsgrenze unterschritten ist,         */
            /* die Solleistung auf aktuelles Minimum begrenzen:      */
            IF Z_BAKT==1 AND PE_BEDARF<=PE_RMIN1B THEN
              X_B        =PE_RMIN1B; /* bei einem BHKW auf PE_RMIN1B */
            ELSE
              X_B        =PE_MIN;
            FIN;
          ELSE
            X_B        =PE_BEDARF-0.5;  /*   Solleistung gleich Bedarf   */
          FIN;
        ELSE /* Normalbetrieb, Automatik                             */
          /* wenn elektrische Anforderung gr”~er als thermische      */
          /* Anforderung, dann elektrische Anforderung sonst th.     */
          IF PE_BEDARF>PE_THERM THEN
            X_B        =PE_BEDARF-0.5;
          ELSE
            X_B        =PE_THERM;
          FIN;
          /* Mindestanforderung ist untere Regelgrenze               */
          IF X_B        <=PE_RMIN THEN
            X_B        =PE_RMIN;
          FIN;
        FIN;
      FIN;
    FIN;
  FIN;

  /* Anforderung auf maximal m”gliche Leistung begrenzen             */
  IF X_B        >=PE_MAX THEN
    X_B        =PE_MAX;
  FIN;


  PE_BSOLLGES=(PE_BSOLLGES*3.0+X_B)*0.25;


  IF B_TAKT3 THEN  /* */
    FOR I TO N_BHKW REPEAT /* alle BHKW regeln:                      */
      /* Solleistung pro BHKW:                                       */
      IF B_BL(I) AND PE_MAX * PE_MAXBHKW(I) > 0.5 THEN
        IF ZF_BEINEXT(I) > 1 THEN   /* <<< EINFLUSS MODBUS */
          PE_BSOLL(I)=(ZF_BEINEXT(I)/100.0)*PE_MAXBHKW(I);
        ELSE
          PE_BSOLL(I)=PE_BSOLLGES/PE_MAX*PE_MAXBHKW(I);
        FIN;
        /* pro BHKW immer mindestens die Minimalleistung anfordern   */
        CALL FLOGRENZ(PE_MAXBHKW(I),PE_MINBHKW(I),PE_BSOLL(I));  
        X_A=PE_MAXBHKW(I)*PE_BMINPRO(I)*0.01;  /* <<< */
        CALL FLOGRENZ(PE_MAXBHKW(I),X_A,PE_BSOLL(I));  
      ELSE
        PE_BSOLL(I)=0.0;
      FIN;

  /*  Bei Regelung mit Analogausgang                                 */
  !   IF B_BL(I) AND PE_BIST(I) >  5.0 THEN                       /* */
  !     X_B=(PE_BSOLL(I)-PE_BIST(I))/PE_BIST(I);                  /* */
  !     IF ABS(PE_BSOLL(I)-PE_BIST(I)) < 20.0 THEN                /* */
  !       X_AAPBHKW(I)=X_AAPBHKW(I)*(1+0.1*X_B);                  /* */
  !     ELSE                                                      /* */
  !       X_AAPBHKW(I)=X_AAPBHKW(I)*(1+0.3*X_B);                  /* */
  !     FIN;                                                      /* */
  !                                                               /* */
  !     /* Analogausgang BHKW-Leistung nach unten begrenzen       /* */
  !     IF X_AAPBHKW(I)< 5.0 THEN                                 /* */
  !       X_AAPBHKW(I)= 5.0;                                      /* */
  !     FIN;                                                      /* */
  !   FIN;                                                        /* */
  !                                                               /* */
  !   X_AAPBHKW(I)=100.0*PE_BSOLL(I)/PE_MAXBHKW(I);   /* <<< Steuerung der Leistung ohne Rueckmeldung */
      
      

    END;

  FIN;  /* */


/*********************************************************************/
/* Kesselleistungsregelung                                           */
/*********************************************************************/
  IF B_TAKT1 THEN    /* Leistungsregelung ausfuehren:                 */
 
    FL1=0.0;
    FIX1=0;
    FOR I TO N_KESSEL REPEAT
      IF B_KL(I) THEN
        FIX1=FIX1+1;
        FL1=FL1+PT_KSOLL(I);
      FIN;
      IF FIX1 > 0 THEN
        FL3=FL1/FIX1;  /* DURCHSCHN KESSELLEISTUNG */
      FIN;
    END;

    CALL FIXGRENZ(3,1,ZF_HKPEXT(31));  

    FOR I TO N_KESSEL REPEAT
      /* w„hrend der ersten 4 Minuten nach dem Einschalten des       */
      /* Kessels wird die Leistung auf dem minimalen Wert gehalten   */
      IF B_KEIN(I) AND Z_KLZ(I) > ZF_KWARML(I) THEN
 
        IF I==3 THEN   /* Biogaskessel */
          /* <<< Betriebsart Biogaskessel           */
          CASE ZF_HKPEXT(31)
            ALT   /* maximale Leistung (Gasvernichtung) */
              /* Regelabweichung                                           */
              TC_HKSOLL(19)=TC_KVMAX(I) - 5.0;
              ABW=(TC_KVMAX(I) - 5.0) - X_AEIN(11);  /* PUFFER4 AUF HOHE TEMP REGELN */
            ALT   /* Leistung geregelt auf HauptkreisIST */
              ABW=TC_VSOLL - (TC_VIST+0.0);  /* ein halbes Grad zu tief regeln */
            ALT   /* Leistung geregelt auf HauptkreisIST */
              ABW=TC_VSOLL - (TC_VIST+3.5);  /* ein halbes Grad zu tief regeln */
              IF ABW < 0.0 THEN  ABW=ABW*4.0;  FIN;
            OUT
          FIN;
        ELSE
          /* Regelabweichung                                           */
   !      ABW=TC_VSOLL - (TC_VIST+0.5);  /* ein halbes Grad zu tief regeln */
          ABW=TC_VSOLL - (TC_VIST+0.0);  /* ein halbes Grad zu tief regeln */
        FIN;

        IF ABW > 5.0 THEN              /* auf 5K zu kalt begrenzen */
          ABW=5.0;
        FIN;
  
        IF I==3 THEN   /* Biogaskessel */

        ELSE

      !   IF ZP_NOW < (ZP_SCHEND+1 MIN) AND ZP_NOW > ZP_SCHANF THEN /* waehrend Hauptnutzungsdauer 90% */
      !     IF PT_AKT < PT_SCHNITT*0.90 AND X_AEIN( 7) < TC_VSOLL- 5.0 THEN  /* <<< langsamer reduzieren ab PT-Schnitt wenn Pu2 oben noch zu kalt */
      !       IF ABW <  0.05 THEN
      !         ABW=  0.05;
      !       FIN;
      !     FIN;
      !   ELSE                                                      /* sonst 70% */
      !     IF PT_AKT < PT_SCHNITT*0.70 AND X_AEIN( 7) < TC_VSOLL- 5.0 THEN  /* <<< langsamer reduzieren ab PT-Schnitt wenn Pu2 oben noch zu kalt */
      !       IF ABW <  0.05 THEN
      !         ABW=  0.05;
      !       FIN;
      !     FIN;
      !   FIN;
  
          IF TC_VIST > TC_VSOLL-2.0   AND PT_AKT > PT_SCHNITT*1.2 THEN  /* <<< schnell reduzieren auf PT-Schnitt */
            IF ABW > -2.0 THEN
              ABW= -2.0;
            FIN;
          FIN;
  
          /* Leistungsangleichung */
          IF FIX1 > 0 THEN
            IF PT_KSOLL(I) < FL3*0.95 THEN
              ABW=ABW+0.4;
            FIN;
          FIN;
      
        FIN; 
 
        RA_KTP(I)=ABW*RP_K(I);
        Y_P=RA_KTP(I);
    
        CALL FLOGRENZ(100.0,0.001,RI_K(I));  /* I-Anteil darf nicht 0 sein */
        RA_KTI(I)=RA_KTI(I)+(RI_K(I)*ABW);           /* YI = YI + I * XD  */
        CALL FLOGRENZ(100.0,0.0,RA_KTI(I));                                   
 
        Y_I=RA_KTI(I); 
  
        /*    geglättet mit TAU             DXD           *  D                      */
        RA_KTDTAU(I)=(RA_KTDTAU(I)*RTAU_K(I)+(ABW-RA_KT1(I))*RD_K(I))/(RTAU_K(I)+1.0);
        Y_D=RA_KTDTAU(I);        
 
        X_B= Y_P+Y_I+Y_D;
        CALL FLOGRENZ(100.0,0.0,X_B);  

        /* aktuelle Regelabweichung fuers naechste Mal merken          */
        RA_KT1(I)=ABW;
 
        PT_KSOLL(I)=X_B;

      ! IF I==3 THEN  /* <<< BIOGASKESSEL NACH FUELLSTAND BIOGASSPEICHER */
      !   X_B=(X_AEIN(30)-TC_HKVNENN(13))*20.0; /* z.B.:  (87 - 85)*20 = 40%  */
      !   CALL FLOGRENZ(100.0,0.0,X_B);  
      !   PT_KSOLL(I)=X_B;
      ! FIN;

      ELSE
        TC_HKSOLL(19)=0.0;
        RA_KT1(I)=100.0;
        PT_KSOLL(I)=0.0;
        RA_KTP(I)=0.0;
        RA_KTI(I)=0.0;
        RA_KTDTAU(I)=0.0;
      FIN;


    END;
 
 
  FIN;

  FL1=150.0;
  FOR I TO N_KESSEL REPEAT
    IF B_KEIN(I) THEN
      Z_PKES(I)=ROUND(PT_KSOLL(I)*0.01*ZF_KSTELL(I));
      IF PT_KSOLL(I) < FL1 THEN
        FL1=PT_KSOLL(I);
      FIN;
    FIN;
    IF B_KEIN(I) THEN
      IF Z_PKES(I) > ZF_KSTELL(I)-1 THEN
        B_KST2(I)='1'B;
      ELSE
        B_KST2(I)='0'B;
      FIN;
    ELSE
      B_KST2(I)='0'B;
    FIN;
  END;
  PT_MINKES=FL1;
  IF PT_MINKES < 0.5 THEN
    IF Z_PTMINKES < 30000 THEN
      Z_PTMINKES=Z_PTMINKES+1;
    FIN;
  ELSE
    Z_PTMINKES=0;
  FIN;

  /* AUSGABE AN DIE KESSEL ERMITTELN      <<< */
  FOR I TO N_KESSEL REPEAT
 
    IF TC_KV(I) > TC_KVMAX(I)+4.0 THEN
      B_KTHERM(I)='0'B;
    FIN;  
    IF TC_KV(I) < TC_KVMAX(I)+1.0 THEN
      B_KTHERM(I)='1'B;
    FIN;  
 
    IF B_KEIN(I) THEN
      X_AAKPTH(I)=       TC_VSOLL+TD_KVLPLUS(I)   + Z_PKES(I)/ZF_KSTELL(I)*15.0;
      IF Z_PKES(I) > ZF_KSTELL(I)-1 THEN
        X_AAKPTH(I)=100.0;
      FIN;
      IF X_AAKPTH(I) < X_AAKMIN(I) THEN  /* <<< */
        X_AAKPTH(I)=X_AAKMIN(I);
      FIN;
      IF Z_SCHORNK(I) > 0 THEN
        IF Z_SCHORNKMAX(I) > 0 THEN
          X_AAKPTH(I)=100.0;
      ! ELSE
      !   X_AAKPTH(I)=X_AAKMIN(I);
        FIN;
      FIN;
    ELSE
      X_AAKPTH(I)=0.0;
    FIN;
 
    /* <<< EINFLUSS MODBUS */
    IF ZF_KEINEXT(I) > 1 THEN
      X_AAKPTH(I)=ZF_KEINEXT(I);
      CALL FLOGRENZ(100.0,X_AAKMIN(I),X_AAKPTH(I));
      Z_PKES(I)=ROUND(ZF_KEINEXT(I)*0.01*ZF_KSTELL(I));
    FIN;

  END;

  /* AUSGABE AN DIE KESSEL ERMITTELN      <<< */
  /* hier Kessel mit Solltemp-Vorgabe     <<< */
! FOR I TO N_KESSEL REPEAT
!
!   IF TC_KV(I) > TC_KVMAX(I)+4.0 THEN
!     B_KTHERM(I)='0'B;
!   FIN;  
!   IF TC_KV(I) < TC_KVMAX(I)+1.0 THEN
!     B_KTHERM(I)='1'B;
!   FIN;  
!
!   IF B_KEIN(I) THEN
!     X_AAKPTH(I)=       TC_VSOLL+TD_KVLPLUS(I)   + Z_PKES(I)/ZF_KSTELL(I)*8.0;
!     IF Z_PKES(I) > ZF_KSTELL(I)-1 THEN
!       X_AAKPTH(I)=100.0;
!     FIN;
!     IF X_AAKPTH(I) < X_AAKMIN(I) THEN  /* <<< */
!       X_AAKPTH(I)=X_AAKMIN(I);
!     FIN;
!     IF Z_SCHORNK(I) > 0 THEN
!       IF Z_SCHORNKMAX(I) > 0 THEN
!         X_AAKPTH(I)=100.0;
!     ! ELSE
!     !   X_AAKPTH(I)=X_AAKMIN(I);
!       FIN;
!     FIN;
!   ELSE
!     X_AAKPTH(I)=0.0;
!   FIN;
!
!   /* <<< EINFLUSS MODBUS */
!   IF ZF_KEINEXT(I) > 1 THEN
!     X_AAKPTH(I)=(100.0-X_AAKMIN(I))*0.01*ZF_KEINEXT(I)+X_AAKMIN(I);
!     CALL FLOGRENZ(100.0,X_AAKMIN(I),X_AAKPTH(I));
!   FIN;
!
! END;


  FOR I TO 2 REPEAT   /* 2 HOLZKESSEL MISCHER UND PMPs BEDIENEN <<< */
    IF B_KL(I) THEN
      B_KPMP(I)='1'B;
      B_KESMIA(I)='0'B;
      B_KESMIZ(I)='0'B;
      IF NOT B_KEIN(I) THEN  /* Kessel laeuft, soll aber keine Waerme abgeben -> VL regeln auf TC_KVMAX */


        IF B_TAKT4 THEN

          TC_KVSOLL(I+5)=TC_KVMAX(I);      

          ABW=TC_KV(I) - TC_KVMAX(I); 
  
          IF ABW > 5.0 THEN              /* auf 5K zu warm begrenzen */
            ABW=5.0;
          FIN;

          FL1= (TC_KR(I)+5.0) - TC_KVMAX(I);    /* RL+5 > SOLLWERT? */
          IF FL1 > ABW AND TC_KV(I) < TC_KVMAX(I)+1.0 THEN
            ABW=FL1;
          FIN;

          IF TC_KR(I) < TC_KVMAX(I)-6.0 THEN    /* RL schon ziemlich kalt -> nur noch langsam oeffnen */
            IF ABW > 0.05 THEN
              ABW=0.05;
            FIN;
          FIN;

       !  IF TC_KR(I) < TC_KRMIN(I) THEN
       !    IF ABW < 0.1 THEN
       !      ABW=0.1;
       !    FIN;
       !  FIN;     
       !  IF Z_KMISTELL(I) < 30 AND TC_KV(I) > TC_KVMAX(I)-5.0 THEN
       !    IF ABW < -0.5 THEN
       !      ABW= -0.5;
       !    FIN;
       !  FIN;
    
          ABW2=ABW;
          IF ABW > 0.1 AND RA_KTDTAU(I+7) < -0.5 THEN   /* zu warm und RL faellt */
            ABW2=ABW*0.4;
          FIN;
          IF ABW < -0.1 AND RA_KTDTAU(I+7) > 0.5 THEN   /* zu kalt und RL steigt */
            ABW2=ABW*0.4;
          FIN;
          IF Z_KMISTELL(I) < 25 AND TC_KV(I) > TC_KVMAX(I)-4.0 AND TC_KV(I) < TC_KVMAX(I)+1.0 AND TC_KR(I) < TC_KVMAX(I)-4.0 THEN
            ABW2=ABW2*0.2;     
          FIN;
          IF Z_KMISTELL(I) < 22 AND TC_KV(I) > TC_KVMAX(I)+0.1 THEN
            IF ABW2 < 2.0 THEN
              ABW2=2.0;
            FIN;     
          FIN;


          IF TC_KV(I) > TC_KVMAX(I) - 3.0 AND TC_KV(I) < TC_KVMAX(I) THEN   /* etwas zu kalt        */
            IF RA_KTDTAU(I+5) > 1.5 THEN                                    /* aber steigt staerker */
              RA_KTI(I+5)=RA_KTI(I+5)+TC_HMT(21)*RI_K(I+5);
            FIN;
          FIN; 
  
          IF TC_KV(I) > TC_KVMAX(I) THEN       /* zu warm              */
            IF RA_KTDTAU(I+5) < -1.5 THEN      /* aber faellt staerker */
              RA_KTI(I+5)=RA_KTI(I+5)-TC_HMT(21)*RI_K(I+5);
            FIN;
          FIN; 
  
          /* Kessel gut zufrieden, nur noch ganz langsam Mischer schliessen */
          IF TC_KV(I) > TC_KVMAX(I) - 3.0 AND TC_KV(I) < TC_KVMAX(I) + 1.0 AND TC_KR(I) >  TC_KVMAX(I) - 7.0 THEN
            IF ABW2 < -0.05 THEN
              ABW2= -0.05;
            FIN;
          FIN;


          RA_KTP(I+5)=ABW2*RP_K(I+5);
          Y_P=RA_KTP(I+5);
      
          CALL FLOGRENZ(100.0,0.001,RI_K(I+5));  /* I-Anteil darf nicht 0 sein */
          RA_KTI(I+5)=RA_KTI(I+5)+(RI_K(I+5)*ABW2);           /* YI = YI + I * XD  */
          CALL FLOGRENZ(100.0,0.0,RA_KTI(I+5));                                   
   
          Y_I=RA_KTI(I+5); 
    
          /*    geglättet mit TAU             DXD           *  D                      */
          RA_KTDTAU(I+5)=(RA_KTDTAU(I+5)*RTAU_K(I+5)+(ABW-RA_KT1(I+5))*RD_K(I+5))/(RTAU_K(I+5)+1.0);
          Y_D=RA_KTDTAU(I+5);        
   

          RA_KTDTAU(I+7)=(RA_KTDTAU(I+7)*RTAU_K(I+5)+(TC_KR(I)-RA_KT1(I+7))*RD_K(I+5))/(RTAU_K(I+5)+1.0);  /* D-ANTEIL RL */
          RA_KT1(I+7)=TC_KR(I);


          X_B= Y_P+Y_I+Y_D;
          CALL FLOGRENZ(100.0,0.0,X_B);  
  
          /* aktuelle Regelabweichung fuers naechste Mal merken          */
          RA_KT1(I+5)=ABW;
   
          PT_KSOLL(I+5)=X_B;
  
        FIN;


        XA_KPMP(I)=(PT_KSOLL(I+5)-30.00)*1.4286;  /* ab 33.33% Pumpe erhoehen */
        IF TC_KV(I) > TC_KVMAX(I)+2.0 THEN       /* zu warm              */
          FL1= 5.0 + (TC_KV(I) - (TC_KVMAX(I)+2.0))*18.0;
          CALL FLOGRENZ(100.0,0.0,FL1);
          IF XA_KPMP(I) < FL1 THEN  XA_KPMP(I)=FL1;  FIN; /* MINDESTWERT */
        FIN;      
        CALL FLOGRENZ(100.0,0.0,XA_KPMP(I));
        FIX1=ROUND(3.60*PT_KSOLL(I+5));           /* Sollstellung Mischer (33,3% Mischer, Rest Pumpe) */
        CALL FIXGRENZ(120,0,FIX1);  
        IF ((Z_KMISTELL(I) < FIX1-1 AND B_TAKT2) OR FIX1 > 118) THEN
          B_KESMIA(I)='1'B;
        ELSE
          IF ((Z_KMISTELL(I) > FIX1+1 AND B_TAKT2) OR FIX1 < 2) THEN
            B_KESMIZ(I)='1'B;
          FIN;
        FIN;


      ELSE   /* B_KEIN  */

        TC_KVSOLL(I+5)=0.0;      

        TC_KVSOLL(I)=TC_VSOLL+TD_KVLPLUS(I);
        IF PT_KSOLL(I) > 35.0 THEN
          IF TC_KV(I) < TC_KVSOLL(I)-0.1  AND TC_KV(I) < RA_KT1(I+5) THEN  /* < Soll und sinkend  */
     !      X_AAKMIN(I+5)=X_AAKMIN(I+5) + (TC_KV(I) - TC_KVSOLL(I))*0.02;
            X_AAKMIN(I+5)=X_AAKMIN(I+5)-0.005;
          ELSE
            IF TC_KV(I) > TC_KVSOLL(I)+0.6 AND TC_KV(I) > RA_KT1(I+5) THEN  /* > Soll + 0,5 und steigend */
              X_AAKMIN(I+5)=X_AAKMIN(I+5)+0.050;
              CALL FLOGRENZ(XA_KPMP(I)+4.0,15.0,X_AAKMIN(I+5));
     !        IF B_KEIN(1) AND B_KEIN(2) THEN                /* wenn 2 Kess ANGEFORDERT */
     !          IF RA_KTI(I) > (X_AAUSMAX(I)-X_AAUSMIN(I))*0.01*X_AAKMIN(I+5)+X_AAUSMIN(I)+2.0 THEN        /* dann I-Anteil Kes-Reg   */    
     !            RA_KTI(I)=RA_KTI(I)-0.2;                   /* begrenzen               */
     !          FIN;
     !        FIN;
            FIN;
          FIN;
        ELSE
          X_AAKMIN(I+5)=XA_KPMP(I)+5.0;
        FIN;
        CALL FLOGRENZ(100.0,15.0,X_AAKMIN(I+5));
        IF TC_VIST > TC_VSOLL+0.2 THEN                 /* wenn warm genug         */
          IF RA_KTI(I) > (X_AAUSMAX(I)-X_AAUSMIN(I))*0.01*X_AAKMIN(I+5)+X_AAUSMIN(I)+2.0 THEN        /* dann I-Anteil Kes-Reg   */    
            RA_KTI(I)=RA_KTI(I)-0.4;                   /* begrenzen               */
          FIN;
        FIN;
        RA_KT1(I+5)=TC_KV(I);                      /* VL merken */

        XA_KPMP(I)=(PT_KSOLL(I)-30.00)*1.4286;  /* ab 30.00% Pumpe erhoehen */
        CALL FLOGRENZ(X_AAKMIN(I+5),0.0,XA_KPMP(I));
        IF TC_KV(I) > TC_KVMAX(I)-2.0 THEN
          FL1=25.0 + (TC_KV(I) - TC_KVMAX(I)-2.0)*10.0;
          CALL FLOGRENZ(100.0,0.0,FL1);
          IF XA_KPMP(I) < FL1 THEN  XA_KPMP(I)=FL1;  FIN; /* MINDESTWERT */
        FIN;

        IF TC_KR(I) < TC_KRMIN(I)-1.0 THEN
          IF B_TAKT15 THEN
            IF TC_KR(I) < RA_KT1(I+7) OR  TC_KR(I) < TC_KRMIN(I)-4.0 THEN
              Z_KMISTELL(I+5)=Z_KMISTELL(I+5)-1;  /* Max-Oeffn Mischer wg K-RL */
            FIN;
            RA_KT1(I+7)=TC_KR(I);
          FIN;
        FIN;
        IF TC_KR(I) > TC_KRMIN(I)+0.6 THEN
          IF B_TAKT10 THEN
            IF TC_KR(I) > RA_KT1(I+7) OR  TC_KR(I) > TC_KRMIN(I)+4.0 THEN
              Z_KMISTELL(I+5)=Z_KMISTELL(I+5)+1;  /* Max-Oeffn Mischer wg K-RL */
            FIN;
            RA_KT1(I+7)=TC_KR(I);
          FIN;
        FIN;
        CALL FIXGRENZ(Z_KMISTELL(I)+5,0,Z_KMISTELL(I+5));  
        CALL FIXGRENZ(120,0,Z_KMISTELL(I+5));  

        F_15=ROUND((TC_KV(I)-(TC_KVMAX(I)-1.0))*25.0);  /* Mindestoeff wg. K-VL (100% bei 4K drueber) */
        CALL FIXGRENZ(120,0,F_15);  
        
        FIX2=ROUND(TC_HMT(22)*1.2);               /* Mindestoeffnung bei Anforderung */
        FIX1=FIX2+ROUND((120-FIX2)*0.0333*PT_KSOLL(I));          /* Sollstellung Mischer (30,0% Mischer, Rest Pumpe) */

        CALL FIXGRENZ(Z_KMISTELL(I+5),F_15,FIX1); /* begr.  Max wg RL < FIX1 > Min wg VL */ 
        IF (Z_KMISTELL(I) < FIX1-1 AND B_TAKT2) OR FIX1 > 118 THEN
          B_KESMIA(I)='1'B;
        ELSE
          IF (Z_KMISTELL(I) > FIX1+1 AND B_TAKT2) OR FIX1 < 2 THEN
            B_KESMIZ(I)='1'B;
          FIN;
        FIN;

      FIN;
    ELSE

      Z_KMISTELL(I+5)=60;
      TC_KVSOLL(I+5)=0.0;      

      B_KPMP(I)='0'B;
      IF B_KPMP(I+5) THEN            /* Kesselwarmhaltung? */
        B_KPMP(I)='1'B;
        IF NOT B_KESMIZ(I) THEN
          B_KESMIA(I)='1'B;
        FIN;
        B_KESMIZ(I)='0'B;
      ELSE
        IF NOT B_KESMIA(I) THEN
          B_KESMIZ(I)='1'B;
        FIN;
        B_KESMIA(I)='0'B;
      FIN;
      XA_KPMP(I)=0.0; 
      IF TC_KR(I) < 45.0 OR TC_KV(I) < 45.0 THEN
        B_KPMP(I+5)='1'B;
      FIN;
      IF TC_KR(I) > 50.0 AND TC_KV(I) > 50.0 THEN
        B_KPMP(I+5)='0'B;
      FIN;
    FIN;
    IF B_KESMIA(I) THEN
      IF Z_KMISTELL(I)<120 THEN Z_KMISTELL(I)=Z_KMISTELL(I)+1; FIN;
    FIN;
    IF B_KESMIZ(I) THEN
      IF Z_KMISTELL(I)>0   THEN Z_KMISTELL(I)=Z_KMISTELL(I)-1; FIN;
    FIN;
  END;





 
  FOR I TO N_KESSEL REPEAT

    /* <<< EINFLUSS MODBUS */
    IF ZF_KPMPEXT(I) > 0 THEN
      B_KPMP(I)='1'B;
    FIN;
    IF ZF_KPMPEXT(I) < 0 THEN
      B_KPMP(I)='0'B;
    FIN;

  ! IF B_KPMP(I) THEN
  !   X_A=100.0*Z_PKES(I)/ZF_KSTELL(I);  /* 0-100 */
  !   IF X_A > XA_KPMP(I) OR TC_KV(I) > (TC_KVMAX(I)-4.0) THEN
  !     IF TC_KV(I) > TC_VSOLL - 1.0 OR TC_KV(I) > TC_KR(I)+36.0 OR TC_KV(I) > (TC_KVMAX(I)-4.0) THEN
  !       XA_KPMP(I)=XA_KPMP(I)+0.05;
  !       IF TC_KV(I) > TC_VSOLL + 0.5 THEN
  !         XA_KPMP(I)=XA_KPMP(I)+0.025;
  !       FIN;
  !     ELSE
  !       IF TC_KV(I) < TC_VSOLL - 2.5 THEN
  !         XA_KPMP(I)=XA_KPMP(I)-0.025;
  !       FIN;
  !     FIN;
  !   ELSE
  !     IF X_A < XA_KPMP(I)-0.15 THEN
  !       XA_KPMP(I)=XA_KPMP(I)-0.15;
  !     FIN;
  !   FIN;
  !   CALL FLOGRENZ(100.0,0.0,XA_KPMP(I));
  ! ELSE
  !   XA_KPMP(I)=0.0;
  ! FIN;

    /* <<< EINFLUSS MODBUS */
    IF ZF_KPMPEXT(I) > 1 THEN
      XA_KPMP(I)=0.4+(ZF_KPMPEXT(I)-2)*1.0162;
    FIN;
 
  END;

  /* AUSGABE AN DIE KESSEL ERMITTELN      <<< */
  /* Analogsignal an jeweiligen Kessel ausgeben, hier findet die Entkopplung von logischer */
  /* Anforderung der Leistungsregelung und den Moeglichkeiten des jeweiligen Kessels statt */
  /* z.B. beruecksichtigen von Spreizung und VL */ 
! FOR I TO 1 REPEAT
!
!   IF TC_KV(I) > TC_KVMAX(I)+4.0 THEN
!     B_KTHERM(I)='0'B;
!   FIN;  
!   IF TC_KV(I) < TC_KVMAX(I)+1.0 THEN
!     B_KTHERM(I)='1'B;
!   FIN;  
!
!   IF X_AAKMIN(I) < 20.0 THEN  /* <<< */
!     X_AAKMIN(I)=20.0;
!   FIN;
!
!   IF (Z_KL(I) > 100 AND B_KTHERM(I)) OR Z_SCHORNKMAX(I) > 0 THEN
!     X_A=X_AAKMIN(I)+PT_KSOLL(I)*(1.0-(X_AAKMIN(I)*0.01));
!     IF X_A < X_AAKPTH(I) THEN
!       X_AAKPTH(I)=X_A;
!     ELSE
!       IF B_TAKT10 THEN
!         IF TC_VIST > TC_VSOLL+0.5 THEN
!           IF X_A > X_AAKPTH(I)+2.0 THEN
!             RA_KTI(I)=RA_KTI(I)-3.0;
!           FIN;
!         FIN;    
!         IF X_A > X_AAKPTH(I) THEN
!           IF     TC_KV(I) < TC_KVMERK(I)+0.5
!              AND TC_KV(I) < TC_KVMAX(I) - 2.0
!              AND (TC_KV(I) - TC_KR(I)) < TD_KMAX(I)-1.0 
!              AND Z_KL(I) > 300 THEN    
!             X_AAKPTH(I)=X_AAKPTH(I)+2.0*1.0;
!           ELSE
!             IF     TC_KV(I) < TC_KVMERK(I)+0.6
!                AND TC_KV(I) < TC_KVMAX(I) + 2.0
!                AND (TC_KV(I) - TC_KR(I)) < TD_KMAX(I)+3.0 THEN
!               X_AAKPTH(I)=X_AAKPTH(I)+0.5*1.0;
!             FIN;
!           FIN;
!           IF    (TC_KV(I) > TC_KVMAX(I) + 3.0 AND TC_KV(I) > TC_KVMERK(I)-0.5)
!              OR ((TC_KV(I) - TC_KR(I)) > TD_KMAX(I)+4.0 AND TC_KV(I) > TC_KVMERK(I)-0.5) THEN
!             X_AAKPTH(I)=X_AAKPTH(I)-1.0*0.6;
!             IF Z_KL(I) > 200 THEN  Z_KL(I)=200;  FIN;
!           FIN;  
!           IF (TC_KV(I) - TC_KR(I)) > TD_KMAX(I)+5.5 AND TC_KV(I) > TC_KVMERK(I)-1.0 THEN 
!             X_AAKPTH(I)=X_AAKPTH(I)-2.0*0.6;
!           FIN;  
!         FIN;
!         TC_KVMERK(I)=TC_KV(I);
!       FIN;            
!     FIN;
!     IF Z_SCHORNK(I) > 0 THEN
!       IF Z_SCHORNKMAX(I) > 0 THEN
!         X_AAKPTH(I)=100.0;
!       ELSE
!         X_AAKPTH(I)=X_AAKMIN(I);
!       FIN;
!     FIN;
!     CALL FLOGRENZ(100.0,X_AAKMIN(I),X_AAKPTH(I));
!   ELSE
!     IF B_KEIN(I) AND B_KTHERM(I) THEN
!       X_AAKPTH(I)=X_AAKMIN(I);
!     ELSE
!       X_AAKPTH(I)= 0.0;
!     FIN;
!   FIN;
!
!   /* <<< EINFLUSS MODBUS */
!   IF ZF_KEINEXT(I) > 1 THEN
!     X_AAKPTH(I)=(100.0-X_AAKMIN(I))*0.01*ZF_KEINEXT(I)+X_AAKMIN(I);
!     CALL FLOGRENZ(100.0,X_AAKMIN(I),X_AAKPTH(I));
!   FIN;
!
! END;

  /* ANALOGSIGNAL UMSETZEN IN RAUF/RUNTER <<< */
  B_KLRUNT(3)='0'B; B_KLRAUF(3)='0'B;
  IF Z_KL(3) >  90 THEN
    IF Z_PKES(3) < Z_KTHERM(3) OR Z_PKES(3) < 1 THEN
      B_KLRUNT(3)='1'B;
      IF Z_KTHERM(3)>0   THEN Z_KTHERM(3)=Z_KTHERM(3)-1; FIN;
    ELSE
   !  IF B_TAKT60 THEN
   !    IF (Z_PKES(3) > Z_KTHERM(3)+0 OR Z_PKES(3) > ZF_KSTELL(3)-1) AND TC_KV(3) < TC_KVMERK(3)+0.3 AND (TC_KV(3) < TC_KVMAX(3) - 0.0 OR TC_KV(3) < TC_KVMERK(3)-0.2) THEN
   !      B_KLRAUF(3)='1'B;
   !      IF Z_KTHERM(3)<ZF_KSTELL(3)  THEN Z_KTHERM(3)=Z_KTHERM(3)+1; FIN;
   !    FIN;
   !  FIN;
      IF B_TAKT10 THEN
     !  IF TC_VIST > TC_VSOLL+0.2 THEN
     !    IF Z_PKES(3) > Z_KTHERM(3)+1 THEN
     !      RA_KTI(3)=RA_KTI(3)-5.0;
     !    FIN;
     !  FIN;    
              /* <<<   VL zu groß        UND  FÄLLT NICHT                 ODER   STEIGUNG ZU GROSS */
        IF (TC_KV(3) > TC_KVMAX(3) + 0.5 AND TC_KV(3) > TC_KVMERK(3)-1.5) OR TC_KV(3) > TC_KVMERK(3)+3.5 THEN 
          B_KLRUNT(3)='1'B;
          IF Z_KTHERM(3)>0   THEN Z_KTHERM(3)=Z_KTHERM(3)-1; FIN;
        ELSE
          IF (Z_PKES(3) > Z_KTHERM(3)+0 OR Z_PKES(3) > ZF_KSTELL(3)-1) AND TC_KV(3) < TC_KVMERK(3)+2.5 THEN
            B_KLRAUF(3)='1'B;
            IF Z_KTHERM(3)<ZF_KSTELL(3)  THEN Z_KTHERM(3)=Z_KTHERM(3)+1; FIN;
          FIN;
        FIN;
      ! IF TC_VIST > TC_VSOLL+0.5 THEN
      !   IF Z_PKES(3) > Z_KTHERM(3) THEN
      !     RA_KTI(3)=RA_KTI(3)-3.0;
      !   FIN;
      ! FIN;    
 
        TC_KVMERK(3)=TC_KV(3);
      FIN;
    FIN;
  ELSE
    B_KLRUNT(3)='1'B;
    IF Z_KTHERM(3)>0   THEN Z_KTHERM(3)=Z_KTHERM(3)-1; FIN;
  FIN;


  FOR I FROM 3 TO 3 REPEAT
 
    /* <<< EINFLUSS MODBUS */
    IF ZF_KPMPEXT(I) > 0 THEN
      B_KPMP(I)='1'B;
    FIN;
    IF ZF_KPMPEXT(I) < 0 THEN
      B_KPMP(I)='0'B;
    FIN;
 
    IF B_KPMP( I) THEN  
 
  !   TC_KVSOLL(I)=TC_VSOLL+TD_KVLPLUS(I);
  !   IF TC_KVSOLL(I) > TC_KR(I) + TD_KMAX(I) THEN
  !     TC_KVSOLL(I)=TC_KR(I)+TD_KMAX(I);
  !   FIN;
  !   IF TC_KVSOLL(I) > TC_KVMAX(I) - 1.0 THEN
  !     TC_KVSOLL(I)=TC_KVMAX(I)-1.0;
  !   FIN;
            
      FL1=0.0;
      IF Z_KL(I) < 1200 THEN
        FL1=8.0-Z_KL(I)*0.0066666;
      FIN;

      /* <<< Betriebsart Biogaskessel           */
      CASE ZF_HKPEXT(31)
        ALT   /* maximale Leistung (Gasvernichtung) */
          TC_KVSOLL(I)= 80.0 + TD_KVLPLUS(I) - FL1;      
        ALT   /* Leistung geregelt auf HauptkreisIST */
          TC_KVSOLL(I)=TC_VSOLL+TD_KVLPLUS(I)-FL1;
          IF TC_KVSOLL(I) > TC_KR(I) + TD_KMAX(I) THEN
            TC_KVSOLL(I)=TC_KR(I)+TD_KMAX(I);
          FIN;
          IF TC_KVSOLL(I) > TC_KVMAX(I) - 1.0 THEN
            TC_KVSOLL(I)=TC_KVMAX(I)-1.0;
          FIN;
        ALT   /* Leistung geregelt auf HauptkreisIST */
          TC_KVSOLL(I)=TC_VSOLL+TD_KVLPLUS(I)-FL1;
          IF TC_KVSOLL(I) > TC_KR(I) + TD_KMAX(I) THEN
            TC_KVSOLL(I)=TC_KR(I)+TD_KMAX(I);
          FIN;
          IF TC_KVSOLL(I) > TC_KVMAX(I) - 1.0 THEN
            TC_KVSOLL(I)=TC_KVMAX(I)-1.0;
          FIN;
        OUT
      FIN;

            
      ABW=TC_KV(I) - TC_KVSOLL(I);  /* XD */
  
 
      RA_KPP(I)=ABW*RP_KP(I);
      Y_P=RA_KPP(I);
    
      CALL FLOGRENZ(100.0,0.001,RI_KP(I));  /* I-Anteil darf nicht 0 sein */
      RA_KPI(I)=RA_KPI(I)+(RI_KP(I)*ABW);           /* YI = YI + I * XD  */
      CALL FLOGRENZ(100.0,0.0,RA_KPI(I));                                   
 
      Y_I=RA_KPI(I); 
  
      /*    geglättet mit TAU                DXD           *  D                      */
      RA_KPDTAU(I)=(RA_KPDTAU(I)*RTAU_KP(I)+(ABW-RA_KP1(I))*RD_KP(I))/(RTAU_KP(I)+1.0);
      Y_D=RA_KPDTAU(I);        
 
      X_B= Y_P+Y_I+Y_D;
      CALL FLOGRENZ(100.0,0.0,X_B);  
 
      /* aktuelle Regelabweichung fuers naechste Mal merken          */
      RA_KP1(I)=ABW;
 
      XA_KPMP(I)=X_B;
 
      IF Z_SCHORNKMAX(I) > 0 THEN
        XA_KPMP(I)=100.0;
      FIN;
 
      /* <<< EINFLUSS MODBUS */
      IF ZF_KPMPEXT(I) > 1 THEN
        XA_KPMP(I)=0.4+(ZF_KPMPEXT(I)-2)*1.0162;
      FIN;
 
    ELSE
      TC_KVSOLL(I)=0.0;
      RA_KPP(I)=0.0;
      RA_KPI(I)=0.0;
      RA_KPDTAU(I)=0.0;
      XA_KPMP(I)=0.0;
    FIN;
 
  END;
 

  /*****************************************************************/
  /* Vorlaufregelung UNTERSTATIONEN       <<<                      */
  /*****************************************************************/

! TC_VSOLLEXT(1)=TC_HKSOLLGES(1);        /* Soll Pu o Zentrale */
! IF TC_BWS(1) > TC_VSOLLEXT(1) THEN
!   TC_VSOLLEXT(1)=TC_BWS(1);      
! FIN;
!
! TC_VSOLLEXT(2)=TC_HKSOLLGES(2);        /* Soll Pu o Haus A */
! IF TC_BWS(2) > TC_VSOLLEXT(2) THEN
!   TC_VSOLLEXT(2)=TC_BWS(2);      
! FIN;
! IF X_AEIN(37) < TC_VSOLLEXT(2) - TD_BWNORM(2) AND X_AEIN(38) < TC_VSOLLEXT(2) - 7.0 THEN
!   B_PMPHK(22)='1'B;
! FIN;
! IF (X_AEIN(37) > TC_VSOLLEXT(2) + 0.8 AND X_AEIN(38) > TC_VSOLLEXT(2) - 9.0) OR (X_AEIN(37) > TC_VSOLLEXT(2) - 2.5 AND TC_VIST < TC_VSOLL AND PT_SCHNITT < 70.0 AND Z_KANFORD < 1) OR (X_AEIN(38) > TC_VSOLLEXT(2) - 4.0) THEN
!   B_PMPHK(22)='0'B;
! FIN;
! IF X_AEIN( 9) > 65.0 AND X_AEIN(38) < 63.0 AND B_BL(1) AND TC_VIST > TC_VSOLL THEN  /* Waerme aus Puffer (Pu2 unten) holen  */
!   B_PMPHK(22)='1'B;
! FIN;
! FL1= -10.0;
! IF B_PMPHK(22) THEN
!   IF Z_LZHKPMP(22) > 240(31) OR B_BWDRIG(2) THEN
!     FL1=TC_VSOLLEXT(2)-X_AEIN(37);
!   ELSE
!     IF FL1 < 0.0 THEN
!       FL1=0.0;
!     FIN;
!   FIN;
! FIN;
! /* NAHWAERMEPUMPE  HAUS A  */
! IF FL1 > -9.0 THEN   /* NETZPUMPE SOLL LAUFEN */
!   IF FL1 < 3.9 AND XA_HKP(22) > 30.0 THEN
!     XA_HKP(22)=XA_HKP(22)-0.25;
!   ELSE
!     IF FL1 > 2.0 THEN  /* PU O UST ZU KALT */
!       FL2=FL1-2.1;
!     ! FL2=FL2*0.5;
!       CALL FLOGRENZ(2.0,0.0,FL2);  
!       /* Hauptkr VL    */                /* <<<          */
!       IF X_AEIN(11) > TC_VSOLLEXT(2)-2.5  OR Z_KL(1) > 180(31) THEN
!         IF XA_HKP(22) < 40.0 THEN
!           XA_HKP(22)=XA_HKP(22)+0.05*FL2;
!         ELSE
!           XA_HKP(22)=XA_HKP(22)+0.010*FL2;
!         FIN;
!       FIN;
!       IF X_AEIN(11) < TC_VSOLLEXT(2)-5.5 THEN
!         XA_HKP(22)=XA_HKP(22)-0.02;
!       FIN;
!     ELSE
!       IF FL1 > 1.5 THEN  /* PU O UST noch wenig ZU KALT */
!         FL2=2.0-FL1;
!         FL2=FL2*1.0;          
!         XA_HKP(22)=XA_HKP(22)-0.05*FL2;
!       ELSE
!         XA_HKP(22)=XA_HKP(22)-0.25;
!       FIN;
!     FIN;
!   FIN;
!   CALL FLOGRENZ(100.0,0.4,XA_HKP(22));  
! ELSE
!  XA_HKP(22)=0.0;
! FIN;
!
!
! TC_VSOLLEXT(3)=TC_HKSOLLGES(3);        /* Soll Pu o VILLA  */
! IF TC_BWS(3) > TC_VSOLLEXT(3) THEN
!   TC_VSOLLEXT(3)=TC_BWS(3);      
! FIN;
! IF X_AEIN(53) < TC_VSOLLEXT(3) - TD_BWNORM(3) AND X_AEIN(54) < TC_VSOLLEXT(3) - 7.0 THEN
!   B_PMPHK(23)='1'B;
! FIN;
! IF (X_AEIN(53) > TC_VSOLLEXT(2) + 0.8 AND X_AEIN(54) > TC_VSOLLEXT(3) - 9.0) OR (X_AEIN(53) > TC_VSOLLEXT(3) - 2.5 AND TC_VIST < TC_VSOLL AND PT_SCHNITT < 70.0 AND Z_KANFORD < 1) OR (X_AEIN(54) > TC_VSOLLEXT(3) - 4.0) THEN
!   B_PMPHK(23)='0'B;
! FIN;
! IF X_AEIN( 9) > 65.2 AND X_AEIN(54) < 63.0 AND B_BL(1) AND TC_VIST > TC_VSOLL THEN  /* Waerme aus Puffer (Pu2 unten) holen  */
!   B_PMPHK(23)='1'B;
! FIN;
! FL1= -10.0;
! IF B_PMPHK(23) THEN
!   IF Z_LZHKPMP(23) > 240(31) OR B_BWDRIG(3) THEN
!     FL1=TC_VSOLLEXT(3)-X_AEIN(53);
!   ELSE
!     IF FL1 < 0.0 THEN
!       FL1=0.0;
!     FIN;
!   FIN;
! FIN;
! /* NAHWAERMEPUMPE  VILLA   */
! IF FL1 > -9.0 THEN   /* NETZPUMPE SOLL LAUFEN */
!   IF FL1 < 3.9 AND XA_HKP(23) > 30.0 THEN
!     XA_HKP(23)=XA_HKP(23)-0.25;
!   ELSE
!     IF FL1 > 2.0 THEN  /* PU O UST ZU KALT */
!       FL2=FL1-2.1;
!     ! FL2=FL2*0.5;
!       CALL FLOGRENZ(2.0,0.0,FL2);  
!       /* Hauptkr VL    */                /* <<<          */
!       IF X_AEIN(11) > TC_VSOLLEXT(3)-2.5  OR Z_KL(1) > 180(31) THEN
!         IF XA_HKP(23) < 40.0 THEN
!           XA_HKP(23)=XA_HKP(23)+0.05*FL2;
!         ELSE
!           XA_HKP(23)=XA_HKP(23)+0.010*FL2;
!         FIN;
!       FIN;
!       IF X_AEIN(11) < TC_VSOLLEXT(3)-5.5 THEN
!         XA_HKP(23)=XA_HKP(23)-0.02;
!       FIN;
!     ELSE
!       IF FL1 > 1.5 THEN  /* PU O UST noch wenig ZU KALT */
!         FL2=2.0-FL1;
!         FL2=FL2*1.0;          
!         XA_HKP(23)=XA_HKP(23)-0.05*FL2;
!       ELSE
!         XA_HKP(23)=XA_HKP(23)-0.25;
!       FIN;
!     FIN;
!   FIN;
!   CALL FLOGRENZ(100.0,0.4,XA_HKP(23));  
! ELSE
!   XA_HKP(23)=0.0;
! FIN;




  /*******************************************************************/
  /* !!! Heizkreispumpen nach Aussentemp. steuern                    */
  /*******************************************************************/
  FOR I TO N_HZKR REPEAT
    IF B_PMPHK(I) THEN
      IF TC_AUSSEN > 20.0 THEN
        XA_HKP(I)=FL_SOLLAT20(I);
      ELSE
        IF TC_AUSSEN > 5.0 THEN
          XA_HKP(I)=(FL_SOLLAT5(I)-FL_SOLLAT20(I))*(15.0-(TC_AUSSEN-5.0))/15.0+FL_SOLLAT20(I);
        ELSE
          XA_HKP(I)=(FL_SOLLATM10(I)-FL_SOLLAT5(I))*(15.0-(TC_AUSSEN+10.0))/15.0+FL_SOLLAT5(I);
        FIN;
      FIN;
      CALL FLOGRENZ(100.0,0.4,XA_HKP(I));  
    ELSE
      XA_HKP(I)=0.0;
    FIN;
  END;


  /*******************************************************************/
  /* !!! Signale zu den UPE-Pumpen aufbereiten                       */
  /*******************************************************************/
  IF B_KPMP(1) AND Z_KHARDST(1) < 940 THEN 
    CALL FLOGRENZ(100.0,0.4,XA_KPMP(1)); 
  FIN; 
  UPE_PRO( 1)=XA_KPMP(1);  /* PMP KES1 */
 
! IF B_KPMP(2) AND Z_KHARDST(2) < 940 THEN 
!   CALL FLOGRENZ(100.0,0.4,XA_KPMP(2)); 
! FIN; 
! UPE_PRO( 2)=XA_KPMP(2);  /* PMP KES2 */
!
! /* <<< EINFLUSS MODBUS */
  IF ZF_HKPEXT( 1) > 1 THEN    XA_HKP( 1)=0.4+(ZF_HKPEXT( 1)-2)*1.0162;    FIN;
  IF ZF_HKPEXT( 2) > 1 THEN    XA_HKP( 2)=0.4+(ZF_HKPEXT( 2)-2)*1.0162;    FIN;
  IF ZF_HKPEXT( 3) > 1 THEN    XA_HKP( 3)=0.4+(ZF_HKPEXT( 3)-2)*1.0162;    FIN;
! IF ZF_HKPEXT( 4) > 1 THEN    XA_HKP( 4)=0.4+(ZF_HKPEXT( 4)-2)*1.0162;    FIN;
! IF ZF_HKPEXT( 5) > 1 THEN    XA_HKP( 5)=0.4+(ZF_HKPEXT( 5)-2)*1.0162;    FIN;
! IF ZF_HKPEXT( 6) > 1 THEN    XA_HKP( 6)=0.4+(ZF_HKPEXT( 6)-2)*1.0162;    FIN;
! IF ZF_HKPEXT( 7) > 1 THEN    XA_HKP( 7)=0.4+(ZF_HKPEXT( 7)-2)*1.0162;    FIN;

! IF B_PMPHK(1)  AND NOT B_STOERSTW(1) THEN     /* Pumpen HK1 */
!
!                         /* Stoe DI P2         Stoe UPE P2            P1 DI OK            P1 UPE OK */
!   IF (DA_TNR REM 2 == 1 OR Z_STOER(32) > 5 OR Z_STOER(45) > 120) AND Z_STOER(31) < 4 AND Z_STOER(44) < 4 THEN /* Fuehrung NW PUMPE1             */
!     
!     B_PMPHK(11)='1'B;
!     UPE_PRO(2)=XA_HKP(1);
!
!   ELSE         
!                           /* Stoe DI P1         Stoe UPE P1            P2 DI OK            P2 UPE OK  */
!     IF (DA_TNR REM 2 == 0 OR Z_STOER(31) > 5 OR Z_STOER(44) > 120) AND Z_STOER(32) < 4 AND Z_STOER(45) < 4 THEN /* Fuehrung NW PUMPE2             */
!       B_PMPHK(21)='1'B;
!       UPE_PRO(3)=XA_HKP(1);
!     ELSE  /* BEIDE PUMPEN GESTOERT */
!       B_PMPHK(11)='1'B;
!       UPE_PRO(2)=XA_HKP(1);
!       B_PMPHK(21)='1'B;
!       UPE_PRO(3)=XA_HKP(1);
!     FIN;
!
!   FIN;
!
! ELSE
!   B_PMPHK(11)='0'B;
!   B_PMPHK(21)='0'B;
!   UPE_PRO(2)=0.0;  
!   UPE_PRO(3)=0.0;  
! FIN;
!
!
!
! IF B_PMPHK(2)  AND NOT B_STOERSTW(2) THEN     /* Pumpen HK2 */
!
!                         /* Stoe DI P2         Stoe UPE P2            P1 DI OK            P1 UPE OK */
!   IF (DA_TNR REM 2 == 1 OR Z_STOER(34) > 5 OR Z_STOER(47) > 120) AND Z_STOER(33) < 4 AND Z_STOER(46) < 4 THEN /* Fuehrung NW PUMPE1             */
!     
!     B_PMPHK(12)='1'B;
!     UPE_PRO(4)=XA_HKP(2);
!
!   ELSE         
!                           /* Stoe DI P1         Stoe UPE P1            P2 DI OK            P2 UPE OK  */
!     IF (DA_TNR REM 2 == 0 OR Z_STOER(33) > 5 OR Z_STOER(46) > 120) AND Z_STOER(34) < 4 AND Z_STOER(47) < 4 THEN /* Fuehrung NW PUMPE2             */
!       B_PMPHK(22)='1'B;
!       UPE_PRO(5)=XA_HKP(2);
!     ELSE  /* BEIDE PUMPEN GESTOERT */
!       B_PMPHK(12)='1'B;
!       UPE_PRO(4)=XA_HKP(2);
!       B_PMPHK(22)='1'B;
!       UPE_PRO(5)=XA_HKP(2);
!     FIN;
!
!   FIN;
!
! ELSE
!   B_PMPHK(12)='0'B;
!   B_PMPHK(22)='0'B;
!   UPE_PRO(4)=0.0;  
!   UPE_PRO(5)=0.0;  
! FIN;


! UPE_PRO( 2)=XA_HKP( 1);  /* PMP HK1  */
!
! UPE_PRO( 3)=XA_HKP(22);  /* PMP ZUBR HAUS A  */
!
! UPE_PRO( 4)=XA_HKP(23);  /* PMP ZUBR VILLA   */
!
! UPE_PRO( 4)=XA_HKP( 3);  /* PMP HK3  */
!
! UPE_PRO( 5)=XA_HKP( 4);  /* PMP HK4  */
!
! UPE_PRO( 6)=XA_HKP( 5);  /* PMP HK5  */
!
! UPE_PRO( 7)=XA_WWLADP( 2);  /* PMP WW2 Ladung   */
!
! UPE_PRO( 8)=XA_WWLADP( 1);  /* PMP WW1 Ladung   */
!
! UPE_PRO( 3)=XA_HKMI(21);  /* PRIMAERPUMPE HKs */
 
! X_A=XA_HKMI( 4)-33.0;   /* 0-33% XA_HKMI  -> Pumpe auf MIN */
! X_A=X_A/0.67;           /* 0-67 -> 0-100 */
! IF B_PMPHK(4) THEN
!   CALL FLOGRENZ(100.0,0.4,X_A);  
! FIN;
! UPE_PRO( 5)=X_A;          /* PMP PRI HK4 */               

 
! UPE_PRO( 4)=XA_WWZI(1);  /* WW1 ZIRKP */


!
! IF B_PMPHK(1) THEN
!   X_A=(XA_HKP(1)*0.1)-X_AEIN(27);             /* Abweichung Solldruck Istdruck */
!   CALL FLOGRENZ(2.0,-2.0,X_A);  
!   X_AAUSMIN(41)=X_AAUSMIN(41)+X_A*0.02;
!   CALL FLOGRENZ(100.0,0.3,X_AAUSMIN(41));  
!   IF X_AAUSMIN(41) < 80.0 THEN
!     IF BI_DAUS(2).BIT(15) THEN  /* HKP 1  */
!       UPE_PRO(4)=X_AAUSMIN(41)*1.333;  
!       CALL FLOGRENZ(100.0,0.4,UPE_PRO(4));  
!     ELSE
!       UPE_PRO(4)=0.0;  
!     FIN;  
!     IF BI_DAUS(2).BIT(14) THEN  /* HKP 2  */
!       UPE_PRO(5)=X_AAUSMIN(41)*1.333;  
!       CALL FLOGRENZ(100.0,0.4,UPE_PRO(5));  
!     ELSE
!       UPE_PRO(5)=0.0;  
!     FIN; 
!   ELSE
!     UPE_PRO(4)=X_AAUSMIN(41)*1.0;  
!     UPE_PRO(5)=X_AAUSMIN(41)*1.0;  
!   FIN;
! ELSE
!   UPE_PRO(4)=0.0;  
!   UPE_PRO(5)=0.0;  
! FIN;
!
!
! IF BI_DAUS(2).BIT(13) THEN  /* P1 HK2 */
!   UPE_PRO(6)=XA_HKP( 2);  
!   CALL FLOGRENZ(100.0,0.4,UPE_PRO(6));  
! ELSE
!   UPE_PRO(6)=0.0;  
! FIN;  
! IF BI_DAUS(2).BIT(12) THEN  /* P2 HK2 */
!   UPE_PRO(7)=XA_HKP( 2);  
!   CALL FLOGRENZ(100.0,0.4,UPE_PRO(7));  
! ELSE
!   UPE_PRO(7)=0.0;  
! FIN; 
!
! IF B_ZIRKPMP(1) THEN 
!   CALL FLOGRENZ(100.0,0.4,XA_WWZI(1)); 
! FIN; 
! UPE_PRO(8)=XA_WWZI(1);  /* WW1 ZIRKP */
!
! UPE_PRO(5)=XA_WWLADP( 2);  /* PMP WW2 LADUNG  */
!
! IF B_ZIRKPMP(2) THEN 
!   CALL FLOGRENZ(100.0,0.4,XA_WWZI(2)); 
! FIN; 
! UPE_PRO(6)=XA_WWZI(2);  /* WW2 ZIRKP */


 

  FOR I TO N_UPE REPEAT
    UPE_SOLLKOMM(I)=Z_UPEKOMMAND(I);
    IF B_UPEHAND(I) THEN
      UPE_SOLLST(I)=Z_UPESOLLHAND(I);
    ELSE  
      IF UPE_PRO(I) < 0.3 THEN
        UPE_SOLLST(I)=0;
        UPE_ZSOLLMIN(I)=1000;   
      ELSE
        IF UPE_PRO(I) < 0.588 THEN
          IF UPE_ZSOLLMIN(I) < 1000 THEN   
            UPE_ZSOLLMIN(I)=UPE_ZSOLLMIN(I)+1;
          FIN;
    !     IF UPE_ZSOLLMIN(I) > 120 THEN         /* evtl. MIN erst nach Wartezeit */
            UPE_SOLLST(I)=ROUND(UPE_KENN(I,1));
    !     ELSE
    !       UPE_SOLLST(I)=ROUND(UPE_KENN(I,2));
    !     FIN;
        ELSE
          UPE_ZSOLLMIN(I)=0;
          IF UPE_PRO(I) < 99.41 THEN
            FL1=(UPE_KENN(I,3)-UPE_KENN(I,2))/100.0;   /* z.B.: 120 - 2 = 118   118/100=1,18 stufen pro % */
            UPE_SOLLST(I)=ROUND((UPE_PRO(I)-0.8)*FL1+UPE_KENN(I,2));
          ELSE  
            UPE_SOLLST(I)=ROUND(UPE_KENN(I,4));
          FIN;
        FIN;
      FIN;   
    FIN;

  END;




! IF X_AEIN(30) > TC_HKVNENN(14) THEN     /* ZWANGSBETRIEB BIOGASFACKEL? */
!   B_KEIN(9)='1'B;
! FIN;
! IF X_AEIN(30) < TC_HKVNENN(14)-1.0 THEN
!   B_KEIN(9)='0'B;
! FIN;
  IF BI_DEINBEW(15) THEN  /* DI Biogas MAX-Fuellstand    */
    B_KEIN(9)='1'B;
  ELSE
    B_KEIN(9)='0'B;
  FIN;

  IF NOT B_SCHORNGES THEN    
 !  IF X_AEIN(30) > TC_HKVNENN(13) THEN     /* ZWANGSBETRIEB BIOGASKESSEL? */
 !    B_KEIN(3)='1'B;
 !  FIN;
 !  IF X_AEIN(30) < TC_HKVNENN(13)-2.0 THEN
 !    B_KEIN(3)='0'B;
 !  FIN;
    IF NOT B_BL(1) THEN     /* ZWANGSBETRIEB BIOGASKESSEL? */
      IF ZF_HKPEXT(31) > 2 THEN
        IF TC_VIST < TC_VSOLL - 6.0 THEN
          B_KEIN(3)='1'B;
        FIN;
      ELSE 
        B_KEIN(3)='1'B;
      FIN;
    FIN;
    IF ZF_HKPEXT(31) > 2 THEN
      IF TC_VIST > TC_VSOLL - 1.0 THEN
        B_KEIN(3)='0'B;
      FIN;
      IF Z_BLZ(1) > 30(31) THEN
        B_KEIN(3)='0'B;
      FIN;
    ELSE
      IF Z_BLZ(1) > 30(31) THEN
        B_KEIN(3)='0'B;
      FIN;
    FIN;
    IF BI_DEINBEW(15) THEN  /* DI Biogas MAX-Fuellstand    */
      B_KEIN(3)='1'B;
    FIN;
  FIN;

  IF X_AEIN(11) > TC_HKVNENN(12) THEN     /* ZWANGSBETRIEB TROCKNUNG WG PUFFER4 ?     */
    B_PMPHK(11)='1'B;
  FIN;
  IF X_AEIN(11) < TC_HKVNENN(12)-2.0 THEN
    B_PMPHK(11)='0'B;
  FIN;

  /* <<< EINFLUSS MODBUS */
! IF B_TAKT5 THEN

 !  IF ZF_BEINEXT( 1) > 0 THEN 
 !    B_BEIN(1)='1'B;  
 !    Z_BTHERMVL(1)=0;                                  
 !    Z_BTHERMRL(1)=0;
 !  FIN;
 !  IF ZF_BEINEXT( 1) < 0 THEN 
 !    B_BEIN(1)='0'B;  
 !    B_BERLAUBT(1)='0'B;
 !  FIN;
 !
 !  IF ZF_BEINEXT( 2) > 0 THEN 
 !    B_BEIN(2)='1'B;  
 !    Z_BTHERMVL(2)=0;                                  
 !    Z_BTHERMRL(2)=0;
 !  FIN;
 !  IF ZF_BEINEXT( 2) < 0 THEN 
 !    B_BEIN(2)='0'B;  
 !    B_BERLAUBT(2)='0'B;
 !  FIN;
 !
 !  IF ZF_BEINEXT( 3) > 0 THEN 
 !    B_BEIN(3)='1'B;  
 !    Z_BTHERMVL(3)=0;                                  
 !    Z_BTHERMRL(3)=0;
 !  FIN;
 !  IF ZF_BEINEXT( 3) < 0 THEN 
 !    B_BEIN(3)='0'B;  
 !    B_BERLAUBT(3)='0'B;
 !  FIN;

    IF ZF_KEINEXT( 1) > 0 THEN 
      B_KEIN(1)='1'B;
      B_KTHERM(1)='1'B;
    FIN;
    IF ZF_KEINEXT( 1) < 0 THEN 
      B_KEIN(1)='0'B;  
      B_KERLAUBT(1)='0'B;
    FIN;

    IF ZF_KEINEXT( 2) > 0 THEN 
      B_KEIN(2)='1'B;
      B_KTHERM(2)='1'B;
    FIN;
    IF ZF_KEINEXT( 2) < 0 THEN 
      B_KEIN(2)='0'B;  
      B_KERLAUBT(2)='0'B;
    FIN;

    IF ZF_KEINEXT( 3) > 0 THEN 
      B_KEIN(3)='1'B;
      B_KTHERM(3)='1'B;
    FIN;
    IF ZF_KEINEXT( 3) < 0 THEN 
      B_KEIN(3)='0'B;  
      B_KERLAUBT(3)='0'B;
    FIN;

! FIN;


  /*******************************************************************/
  /* !!! Signale den Analogausgaengen zuordnen                       */
  /*******************************************************************/

! /* Solltemp Holzkessel1 */
! IND1=1;  
! FL1=X_AAKPTH(1);

  /* Soll PMP BIOGASKESSEL */
  IND1=1;  
  FL1=XA_KPMP(3);
  IF B_KPMP(3) OR Z_AAUTO(IND1)==2 THEN 
    IF Z_AAUTO(IND1) < 2 THEN  
      X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);
    ELSE
      X_AAUS(IND1)=X_AHAND(IND1);
    FIN;
    CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
  ELSE
    X_AAUS(IND1)=0.0;
  FIN;

  /* Sollvorgabe Pumpe Kessel1  */
  IND1=2;  
  FL1=XA_KPMP(1);
  IF B_KPMP(1) AND Z_KHARDST(1) < 940 OR Z_AAUTO(IND1)==2 OR B_KL(1) OR B_KPMP(6) THEN 
    IF Z_AAUTO(IND1) < 2 THEN  
      X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);  
    ELSE
      X_AAUS(IND1)=X_AHAND(IND1);
    FIN;
    CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
  ELSE
    X_AAUS(IND1)=0.0;
  FIN;
 
  /* Solltemp Holzkessel2 */
  IND1=3;  
  FL1=X_AAKPTH(2);
  IF B_KEIN(2) AND B_KTHERM(2) OR Z_AAUTO(IND1)==2 THEN
    IF Z_AAUTO(IND1) < 2 THEN  
      X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);
    ELSE
      X_AAUS(IND1)=X_AHAND(IND1);
    FIN;
    CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
  ELSE
    X_AAUS(IND1)=0.0;
  FIN;

  /* Sollvorgabe Pumpe Kessel2  */
  IND1=4;  
  FL1=XA_KPMP(2);
  IF B_KPMP(2) AND Z_KHARDST(2) < 940 OR Z_AAUTO(IND1)==2 OR B_KL(2) OR B_KPMP(7) THEN 
    IF Z_AAUTO(IND1) < 2 THEN  
      X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);  
    ELSE
      X_AAUS(IND1)=X_AHAND(IND1);
    FIN;
    CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
  ELSE
    X_AAUS(IND1)=0.0;
  FIN;
 
  /* Sollvorgabe Ventilator Trocknung <<< */
  IND1=5;  
  IF B_PMPHK(4)   THEN
    FL1=(X_AEIN(11)-(TC_HKVNENN(12)+1.0))*20.0; /* z.B.:  (73 - 71)*20 = 40%  Betrieb wg Puunten: je heisser desto blas */
    CALL FLOGRENZ(TC_HKVNENN(31),0.0,FL1);  /* MAX:  MAX-Wert normal */
    IF B_ABSEIN(61) THEN                  /* bei Betrieb wg Timer -> Mindestwert */
      IF FL1 < TC_HKVNENN(20) THEN
        FL1=TC_HKVNENN(20);
      FIN;
    FIN;
    IF B_ABSEIN(62) THEN                  /* bei Leisebetrieb -> MAXwert */
      IF FL1 > TC_HKVNENN(19) THEN
        FL1=TC_HKVNENN(19);
      FIN;
    FIN;
  FIN;
  IF B_PMPHK(4) OR Z_AAUTO(IND1)==2 THEN 
    IF Z_AAUTO(IND1) < 2 THEN  
      X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);  
    ELSE
      X_AAUS(IND1)=X_AHAND(IND1);
    FIN;
    CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
  ELSE
    X_AAUS(IND1)=0.0;
  FIN;
 
  /* Soll Pumpe HK1    */
  IND1=6;  
  FL1=XA_HKP(1); 
  IF B_PMPHK(1) OR Z_AAUTO(IND1)==2 THEN
    IF Z_AAUTO(IND1) < 2 THEN  
      X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);
    ELSE
      X_AAUS(IND1)=X_AHAND(IND1);
    FIN;
    CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
  ELSE
    X_AAUS(IND1)=0.0;
  FIN;
 
  /* Soll Pumpe HK2    */
  IND1=7;  
  FL1=XA_HKP(2); 
  IF B_PMPHK(2) OR Z_AAUTO(IND1)==2 THEN
    IF Z_AAUTO(IND1) < 2 THEN  
      X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);
    ELSE
      X_AAUS(IND1)=X_AHAND(IND1);
    FIN;
    CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
  ELSE
    X_AAUS(IND1)=0.0;
  FIN;
 
  /* Soll Pumpe HK3    */
  IND1=8;  
  FL1=XA_HKP(3); 
  IF B_PMPHK(3) OR Z_AAUTO(IND1)==2 THEN
    IF Z_AAUTO(IND1) < 2 THEN  
      X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);
    ELSE
      X_AAUS(IND1)=X_AHAND(IND1);
    FIN;
    CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
  ELSE
    X_AAUS(IND1)=0.0;
  FIN;
 
  /* Kessel2 Sollvorgabe */
! IND1=2;  
! FL1=X_AAKPTH(2);
! IF B_KEIN(2) AND B_KTHERM(2) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;

  /* Soll Pumpe HK2    */
! IND1=4;  
! FL1=XA_HKP(2); 
! IF B_PMPHK(2) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;
 

! /* Soll Mischer HK1  */
! IND1=6;  
! FL1=XA_HKMI(1); 
! IF B_PMPHK(1) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*FL1+X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;
 
! /* Kessel2 Sollvorgabe */
! IND1=2;  
! IF B_KEIN(2) AND B_KTHERM(2) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*  X_AAKPTH(2)  +X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;
!
! /* Soll Mischer HK3  */
! IND1=4;  
! IF B_PMPHK(3) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*  XA_HKMI(3)  +X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;
!
!
!
! /* Soll Pumpe FW       */
! IND1=1;  
! IF B_PMPHK(4) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*XA_HKP( 4)+X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;
!
! /* Soll Pumpe2 HK3     */
! IND1=7;  
! IF BI_DAUS(2).BIT(14) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*XA_HKP( 3)+X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;

  /* Kessel1 Sollvorgabe */
! IND1=1;  
! IF B_KEIN(1) AND B_KTHERM(1) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*X_AAKPTH(1)+X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;
!
! /* BHKW1   Sollvorgabe */
! IND1=1;  
! IF B_BL(1) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*X_AAPBHKW(1)+X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;

  /* hier Sonderfall, die AAs fuer die Ladepumpen werden in Mpc.p/DIN getaktet */
! /* WW1 Ladepumpe      */
! IND1=ZA_BWLPMP(1);
! IF B_LPMP(1) OR Z_AAUTO(IND1)==2 THEN
!   IF Z_AAUTO(IND1) < 2 THEN  
!     X_AAUS(IND1)=(X_AAUSMAX(IND1)-X_AAUSMIN(IND1))*0.01*XA_WWLADP(1)+X_AAUSMIN(IND1);
!   ELSE
!     X_AAUS(IND1)=X_AHAND(IND1);
!   FIN;
!   CALL FLOGRENZ(X_AAUSMAX(IND1),X_AAUSMIN(IND1),X_AAUS(IND1));
! ELSE
!   X_AAUS(IND1)=0.0;
! FIN;



  /*******************************************************************/
  /* !!! Signale fuer die PWM aufbereiten                            */
  /*******************************************************************/
  /* WW Zirkulationspumpe1        */
! IND1=1;                           
! FL1=XA_WWZI(1);   
! IF B_ZIRKPMP(1) OR Z_PWMAUTO(IND1)==2 THEN 
!   IF Z_PWMAUTO(IND1) < 2 THEN
!     FL_PWMPRO(IND1)=(X_PWMMAX(IND1)-X_PWMMIN(IND1))*0.01*  FL1     +X_PWMMIN(IND1);
!   ELSE
!     FL_PWMPRO(IND1)=X_PWMHAND(IND1);
!   FIN;  
!   CALL FLOGRENZ(X_PWMMAX(IND1),X_PWMMIN(IND1),FL_PWMPRO(IND1));
! ELSE
!   FL_PWMPRO(IND1)=0.0;
! FIN;

  /* Heizpatrone1 (oben)          */
! IND1=1; 
! FL1=X_AAPBHKW(7);   
! IF B_BEIN(7) OR Z_PWMAUTO(IND1)==2 THEN 
!   IF Z_PWMAUTO(IND1) < 2 THEN
!     FL_PWMPRO(IND1)=(X_PWMMAX(IND1)-X_PWMMIN(IND1))*0.01*FL1+X_PWMMIN(IND1);
!   ELSE
!     FL_PWMPRO(IND1)=X_PWMHAND(IND1);
!   FIN;  
!   CALL FLOGRENZ(X_PWMMAX(IND1),X_PWMMIN(IND1),FL_PWMPRO(IND1));
! ELSE
!   FL_PWMPRO(IND1)=0.0;
! FIN;

! /* Heizpatrone2 (unten)         */
! IND1=2; 
! FL1=X_AAPBHKW(8);   
! IF B_BEIN(8) OR Z_PWMAUTO(IND1)==2 THEN 
!   IF Z_PWMAUTO(IND1) < 2 THEN
!     FL_PWMPRO(IND1)=(X_PWMMAX(IND1)-X_PWMMIN(IND1))*0.01*FL1+X_PWMMIN(IND1);
!   ELSE
!     FL_PWMPRO(IND1)=X_PWMHAND(IND1);
!   FIN;  
!   CALL FLOGRENZ(X_PWMMAX(IND1),X_PWMMIN(IND1),FL_PWMPRO(IND1));
! ELSE
!   FL_PWMPRO(IND1)=0.0;
! FIN;

  /* WW1-Ladepumpe */
! IND1=ZA_BWLPMP(1);
! IF B_LPMP(1) OR Z_PWMAUTO(IND1)==2 THEN
!   IF Z_PWMAUTO(IND1) < 2 THEN  
!     X_A=XA_WWLADP(IND1);
!     IF TC_BWRUECK(1) > TC_BWRSOLL(1) AND NOT B_BWDRIG(1) THEN  /* <<< */
!                                                  /* 1/95 * ( 50...2.5      - 5) */
!       FL_PWMPRO(IND1)=(X_PWMMAX(IND1)-X_PWMMIN(IND1))*0.01053*((X_A       *0.5)-5.0)+X_PWMMIN(IND1);
!     ELSE
!                                                  /* 1/95 * (100...5        - 5) */
!       FL_PWMPRO(IND1)=(X_PWMMAX(IND1)-X_PWMMIN(IND1))*0.01053*( X_A            -5.0)+X_PWMMIN(IND1);
!     FIN;
!   ELSE
!     FL_PWMPRO(IND1)=X_PWMHAND(IND1);
!   FIN;  
!   CALL FLOGRENZ(X_PWMMAX(IND1),X_PWMMIN(IND1),FL_PWMPRO(IND1));
! ELSE
!   FL_PWMPRO(IND1)=0.0;
! FIN;

  /* WW1-Speisepumpe */
! IND1=ZA_BWSPMP(1);
! IF B_SPMP(1) OR Z_PWMAUTO(IND1)==2 THEN
!   IF Z_PWMAUTO(IND1) < 2 THEN  
!     X_A=XA_WWSPEIP(IND1)*1.0;                        /* 1/95 * (100...5 - 5) */
!     FL_PWMPRO(IND1)=(X_PWMMAX(IND1)-X_PWMMIN(IND1))*0.01053*(X_A       -5.0)+X_PWMMIN(IND1);
!   ELSE
!     FL_PWMPRO(IND1)=X_PWMHAND(IND1);
!   FIN;  
!   CALL FLOGRENZ(X_PWMMAX(IND1),X_PWMMIN(IND1),FL_PWMPRO(IND1));
! ELSE
!   FL_PWMPRO(IND1)=0.0;
! FIN;
! CALL FLOGRENZ(100.0,0.0,X_AAUS(IND1));


  /*****************************************************************************/
  /* verschiedene Laufzeitprotokolle (BHKW-Variablen Index 9-20 missbrauchen)  */
  /*****************************************************************************/
  FOR I TO  7 REPEAT
    B_LOOP='0'B;
    IND1=20;
    CASE I
      ALT  /*  1 */
        IND1= 9;
        IF B_KL(1) THEN /* Kessel1 Betrieb */
          B_LOOP='1'B;
        FIN;
      ALT  /*  2 */
        IND1=10;
        IF B_KL(2) THEN /* Kessel2 Betrieb */
          B_LOOP='1'B;
        FIN;
      ALT  /*  3 */
        IND1=11;
        IF B_KL(3) THEN /* Kessel3 Betrieb */
          B_LOOP='1'B;
        FIN;
      ALT  /*  4 */
        IND1=12;
        IF B_KEIN(9) THEN /* Betrieb FACKEL    */
          B_LOOP='1'B;
        FIN;
      ALT  /*  5 */
        IND1=13;
        IF B_PMPHK(4) THEN /* Betrieb Trocknung */
          B_LOOP='1'B;
        FIN;
      ALT  /*  6 */
        IND1=14;
        IF B_KL( 8) THEN     /* STOCKER HOLZK1        */
          B_LOOP='1'B;
        FIN;
      ALT  /*  7 */
        IND1=15;
        IF B_KL( 9) THEN     /* STOCKER HOLZK2        */
          B_LOOP='1'B;
        FIN;
   !  ALT  /*  3 */
   !    IND1=12;
   !    IF B_PMPHK(23) THEN     /* NW VILLA              */
   !      B_LOOP='1'B;
   !    FIN;
   !  ALT  /*  2 */
   !    IND1=11;
   !    IF B_BWANF(2) THEN       /* WW2 ANF             */
   !      B_LOOP='1'B;
   !    FIN;
   !  ALT  /*  2 */
   !    IND1=10;
   !    IF B_KL(2) THEN /* Kessel2 Betrieb */
   !      B_LOOP='1'B;
   !    FIN;
   !  ALT  /*  4 */
   !    IND1=12;
   !    IF B_BEIN(8) THEN       /* HP2               */
   !      B_LOOP='1'B;
   !    FIN;
    ! ALT  /*  3 */
    !   IND1=11;
    !   IF BI_DEINBEW(16) THEN  /* WANF HALLENBAD    */
    !     B_LOOP='1'B;
    !   FIN;
    ! ALT  /*  4 */
    !   IND1=12;
    !   IF BI_DEINBEW(17) THEN  /* WANF FREIBAD      */
    !     B_LOOP='1'B;
    !   FIN;
    ! ALT  /*  2 */
    !   IND1=10;
    !   IF Z_FREECOUNT(49) > 0 THEN  /* SYSTAKT hat laenger 2,5s gebraucht */
    !     Z_FREECOUNT(49)=Z_FREECOUNT(49)-1;
    !     B_LOOP='1'B;
    !   FIN;
      OUT
    FIN;

    IF B_LOOP AND Z_LZ > 20(31) THEN 
      Z_BLZ(IND1)=Z_BLZ(IND1)+1(31); /* kontinuierliche Laufzeit erhoehen.  */
      Z_BLAUFZ(IND1,1)=Z_BLZ(IND1);                /*  Laufzeit merken      */
      ZP_BAUS(IND1,1)=NOW;                    /* Abschaltzeitp. merken      */
      DAT_BAUS(IND1,1)=DA_DAT;                /* Abschaltdatum  merken      */
      Z_BLZVIERT(IND1)=Z_BLZVIERT(IND1)+1;    /* 1/4 Laufzeit               */
      FL_BLFZGESHZG(IND1)=FL_BLFZGESHZG(IND1)+1.0;  /* Gesamtlaufzeit       */
    ELSE
      IF Z_BLZ(IND1) > 0(31) OR Z_BLAUFZ(IND1,1) > 0(31) THEN
        FOR K FROM 12 BY -1 TO 1 REPEAT
          /* Laufzeiten umsortieren                                  */
          Z_BLAUFZ(IND1,K+1)=Z_BLAUFZ(IND1,K);
          /* Abschaltzeitp. umsortieren                              */
          ZP_BAUS(IND1,K+1)=ZP_BAUS(IND1,K);
          /* Abschaltdatum umsortieren                               */
          DAT_BAUS(IND1,K+1)=DAT_BAUS(IND1,K);
        END;
        Z_BLAUFZ(IND1,1)=0(31);            /*                            */
        Z_BLZ(IND1)=0(31);
      FIN;
    FIN;
  END;



  /*********************************************************************/
  /* Kessel nach Laufzeit bzw. Stoerungsstatus sortieren               */
  /*********************************************************************/
! IF B_TAKT60 AND B_FSLKESAUTO THEN
!   /* <<< Kessel nach Laufzeit sortieren */
!   B_LOOP='1'B;
!   FOR K TO N_KESSEL REPEAT
!     FOR I TO N_KESSEL REPEAT
!       IF  ( (FS_LKES(I) < FS_LKES(K)
!          AND Z_KESLFZ(I) > Z_KESLFZ(K)+172800(31)) /* 2 Tage */        
!          OR  (B_KHARDST(I) AND NOT B_KHARDST(K)) 
!          OR  (NOT B_KERLAUBT(I) AND B_KERLAUBT(K)))
!          AND B_LOOP THEN 
!         B_LOOP='0'B;
!         X_M=FS_LKES(I);                                             
!         FS_LKES(I)=FS_LKES(K);                                   
!         FS_LKES(K)=X_M;                                            
!       FIN;                                                           
!     END;
!   END;
!   B_LOOP='1'B;
!   FOR K TO N_KESSEL REPEAT
!     FOR I TO N_KESSEL REPEAT
!       IF  ( (FS_LKES(I) < FS_LKES(K))
!          AND (B_KHARDST(I) AND NOT B_KHARDST(K))          
!          AND (NOT B_KERLAUBT(I) AND B_KERLAUBT(K)))         
!          AND B_LOOP THEN 
!         B_LOOP='0'B;
!         X_M=FS_LKES(I);                                             
!         FS_LKES(I)=FS_LKES(K);                                   
!         FS_LKES(K)=X_M;                                           
!       FIN;                                                           
!     END;
!   END;
! FIN;


! FS_LKES(1)=1; /* hier nur ein Kessel */



  /* Organisation HZG-Wassernachfuellung */
  IF P_VERTEIL < FL_HZGFUEEIN AND P_VERTEIL > FL_DRWARN THEN
    B_HZGFUELL='1'B;
  FIN;
 
  IF P_VERTEIL > FL_HZGFUEAUS OR Z_HZGFUELL >= ZF_HZGFUELL THEN
    B_HZGFUELL='0'B;
  FIN;
 
  IF B_HZGFUELL THEN
    Z_HZGFUELL=Z_HZGFUELL+1;
  FIN;
 
  IF P_VERTEIL > FL_HZGFUEAUS AND Z_HZGFUELL >= ZF_HZGFUELL THEN
    Z_HZGFUELL=ROUND(ZF_HZGFUELL*0.6);
  FIN;



  /*********************************************************/
  /* WW-Bypassventil einbinden                             */
  /* dazu zunaechst die tiefste WW-Lade-VL Temp ermitteln  */
  /* und die groesste WW-Lademischer-Stellung ermitteln    */
  FL1=300.0;
  IF TC_BWVOR(1) < FL1 THEN
    FL1=TC_BWVOR(1);
  FIN;
! IF TC_BWVOR(2) < FL1 THEN
!   FL1=TC_BWVOR(2);
! FIN;
! IF TC_BWVOR(3) < FL1 THEN
!   FL1=TC_BWVOR(3);
! FIN;
! IF TC_BWVOR(4) < FL1 THEN
!   FL1=TC_BWVOR(4);        /* LAD VL MIN */
! FIN;
  
  FL2=0.0;
  IF XA_WWLADMI(1) > FL2 THEN 
    FL2=XA_WWLADMI(1);
  FIN;
! IF XA_WWLADMI(2) > FL2 THEN 
!   FL2=XA_WWLADMI(2);
! FIN;
! IF XA_WWLADMI(3) > FL2 THEN 
!   FL2=XA_WWLADMI(3);
! FIN;
! IF XA_WWLADMI(4) > FL2 THEN 
!   FL2=XA_WWLADMI(4);      /* MI STELLUNG MAX */
! FIN;

! B_MIAUF(30)='0'B;
! B_MIZU (30)='0'B;
! IF B_TAKT10  THEN
!   IF XA_HKMI(1) > 98.0 OR XA_HKMI(2) > 98.0 OR XA_HKMI(3) > 98.0 OR XA_HKMI(4) > 98.0 THEN    /* HKs unterversorgt ? */
!     B_MIZU(30)='1'B;
!   ELSE                                                     /* HKs zufrieden                     LAD VL > HVL - 2    LADMI < 85%  */
!     IF XA_HKMI(1) < 92.0 AND XA_HKMI(2) < 92.0 AND XA_HKMI(3) < 92.0 AND XA_HKMI(4) < 92.0 AND ( FL1 > TC_VIST-2.0 OR FL2 < 85.0) THEN
!       IF Z_FREECOUNT(50) REM 3 == 0 THEN
!         B_MIAUF(30)='1'B;
!       FIN;
!     FIN;
!   FIN;
!   IF Z_FREECOUNT(50) > 0 THEN  Z_FREECOUNT(50)=Z_FREECOUNT(50)-1;  FIN;
! FIN;
! IF B_TAKT5  THEN                                                              /* LAD VL < HVL - 4    LADMI > 95%  */
!   IF NOT B_PMPHK(1) AND NOT B_PMPHK(2) AND NOT B_PMPHK(3) AND NOT B_PMPHK(4) OR ( FL1 < TC_VIST-4.0 AND FL2 > 95.0) THEN
!     B_MIAUF(30)='0'B;
!     B_MIZU (30)='1'B;
!     Z_FREECOUNT(50)=12;
!   FIN;
! FIN;
!
! IF B_MIAUF(30) THEN
!   IF Z_HKMISTELL(30)<120 THEN Z_HKMISTELL(30)=Z_HKMISTELL(30)+1; FIN;
! FIN;
! IF B_MIZU(30)  THEN
!   IF Z_HKMISTELL(30)>0   THEN Z_HKMISTELL(30)=Z_HKMISTELL(30)-1; FIN;
! FIN;






  /* St”rung BHKW 1   */
! FIX1=1;
! IF B_BSTOER(1) AND B_BERLAUBT2(1) THEN
!   IF NOT B_STOER(FIX1) THEN
!     B_STOER(FIX1)='1'B;
!     CALL STOERMELD (FIX1,TX_STOERMEL(FIX1));
!   FIN;
! ELSE
!   B_STOER(FIX1)='0'B;
! FIN;


  /* Warnung Heizungsdruck MAX    */ /* <<<< */
  FIX1=4;
  IF P_VERTEIL > FL_DRMAX THEN
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;
    IF Z_STOER(FIX1)>10 AND NOT B_STOER(FIX1) THEN
      B_STOER(FIX1)='1'B;
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */  
    FIN;
  ELSE
    IF P_VERTEIL < FL_DRMAX*0.97 THEN
      Z_STOER(FIX1)=0;
      B_STOER(FIX1)='0'B;
    FIN;
  FIN;

  /* Warnung Heizungsdruck        */       /* <<<< */
  FIX1=5;
  IF P_VERTEIL < FL_DRWARN THEN
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;
    IF Z_STOER(FIX1)>10 AND NOT B_STOER(FIX1) THEN
      B_STOER(FIX1)='1'B;
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */  
    FIN;
  ELSE
    IF P_VERTEIL > FL_DRWARN*1.03 THEN
      Z_STOER(FIX1)=0;
      B_STOER(FIX1)='0'B;
    FIN;
  FIN;

  /* Stoerung Heizungsnotschalter */
  FIX1=6;
  IF NOT BI_DEINBEW( 1) THEN                                   
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;
    IF Z_STOER(FIX1)>5 THEN
      FOR I TO N_BHKW REPEAT
        B_BEIN(I)='0'B;
      END;
      FOR I TO N_KESSEL REPEAT
        B_KEIN(I)='0'B;
      END;
    FIN;
    IF Z_STOER(FIX1)>4 AND NOT B_STOER(FIX1) THEN
      B_STOER(FIX1)='1'B;
      CALL STOERMELD (FIX1,TX_STOERMEL(FIX1));
      FOR I TO N_BHKW REPEAT
        IF B_BL(I) THEN
          CALL STOERMELD (FIX1,'ERR-Notschl. B' CAT TOCHAR(I+48));
        FIN;
      END;
    FIN;
  ELSE
    Z_STOER(FIX1)=0;
    B_STOER(FIX1)='0'B;
  FIN;


  /* Stoerung Gassensor  <<<   */     /* <<<< */
! FIX1=7;
! IF FL_GAS > FL_GASSTOER THEN                         /* */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /* */
!   IF Z_STOER(FIX1)>3 THEN                            /* */
!     FOR I TO N_BHKW REPEAT                           /* */
!       B_BEIN(I)='0'B;                                /* */
!     END;                                             /* */
!     Z_TMA=240;            /* Mindestauszeit setzen     */
!     FOR I TO N_KESSEL REPEAT                         /* */ 
!       B_KEIN(I)='0'B;                                /* */
!     END;                                             /* */
!     IF NOT B_STOER(FIX1) THEN                        /* */
!       B_STOER(FIX1)='1'B;                            /* */ 
!       CALL STOERMELD (FIX1,TX_STOERMEL(FIX1));       /* */
!     FIN;                                             /* */
!   FIN;                                               /* */
! ELSE                                                 /* */
!   IF Z_STOER(FIX1) > 0 THEN                          /*    */
!     Z_STOER(FIX1)=Z_STOER(FIX1)-1;                   /*    */  
!   FIN;                                               /*    */
!   IF Z_STOER(FIX1) < 1 THEN                          /*    */
!     B_STOER(FIX1)='0'B;                              /*    */  
!   FIN;                                               /*    */
!   IF Z_STOER(FIX1) > 600 THEN                        /*    */
!     Z_STOER(FIX1)=600;                               /*    */  
!   FIN;                                               /*    */
! FIN;                                                 /* */
!
! /* Warnung Gassensor  <<<   */     /* <<<< */
! FIX1=8;
! IF (FL_GAS > FL_GASWARN OR FL_GAS < 0.75)       /* */
!    AND FL_GAS <= FL_GASSTOER THEN               /* */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                /* */
!   IF Z_STOER(FIX1)>3 THEN                       /* */
!     IF NOT B_STOER(FIX1) THEN                   /* */
!       B_STOER(FIX1)='1'B;                       /* */
!       IF FL_GAS > FL_GASWARN THEN               /* */
!         CALL STOERMELD (FIX1,TX_STOERMEL(FIX1));/* */
!       ELSE                                      /* */
!         CALL STOERMELD (FIX1,'Gassens. defekt');  /* */
!       FIN;                                      /* */
!     FIN;                                        /* */
!   FIN;                                          /* */
! ELSE                                            /* */
!   Z_STOER(FIX1)=0;                              /* */
!   B_STOER(FIX1)='0'B;                           /* */   
! FIN;                                            /* */


! /* Kessel1 Störung Sicherheitskette               */
! FIX1= 9;
! IF NOT BI_DEINBEW( 2) AND BI_DEINBEW( 1) THEN        /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                  /*    */
!   IF Z_STOER(FIX1)>40 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                           /*    */
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */
!   FIN;                                            /*    */
! ELSE                                              /*    */
!   Z_STOER(FIX1)=0;                                /*    */
!   B_STOER(FIX1)='0'B;                             /*    */
! FIN;                                              /*    */  

  /* Kessel1 Stoerung                                        */
  FIX1= 9;
! IF BI_DEINBEW( 3) OR (B_KEIN(1) AND X_AEIN(29) > 3.0 AND X_AEIN(29) < 10.0) THEN        /*    */
  IF BI_DEINBEW( 3) THEN        /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                  /*    */
    IF Z_STOER(FIX1)>30 AND NOT B_STOER(FIX1) THEN  /*    */
      B_STOER(FIX1)='1'B;                           /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */
    FIN;                                            /*    */
  ELSE                                              /*    */
    Z_STOER(FIX1)=0;                                /*    */
    B_STOER(FIX1)='0'B;                             /*    */
  FIN;                                              /*    */

  /* Stoerung Kessel1 keine Rueckmeldung  */
  FIX1=10;
  IF Z_KLZ(1) > 720(31) AND NOT B_KL(1) THEN           /*    */  
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
    IF Z_STOER(FIX1)>30 AND NOT B_STOER(FIX1) THEN     /*    */  
      B_STOER(FIX1)='1'B;                              /*    */  
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */  
    FIN;                                               /*    */  
  ELSE                                                 /*    */  
    Z_STOER(FIX1)=0;                                   /*    */  
    B_STOER(FIX1)='0'B;                                /*    */  
  FIN;                                                 /*    */  
 
  B_KHARDST(1)=   B_STOER( 9) OR  B_STOER(10);
  IF B_KHARDST(1) AND NOT B_KL(1) THEN
    IF Z_KHARDST(1) < 1200 THEN
      Z_KHARDST(1)=Z_KHARDST(1)+1;
    FIN;
  ELSE
    Z_KHARDST(1)=0;
  FIN;


  /* Kessel2 Stoerung                                   */
  FIX1=11;
  IF BI_DEINBEW( 5) THEN        /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                  /*    */
    IF Z_STOER(FIX1)>30 AND NOT B_STOER(FIX1) THEN  /*    */
      B_STOER(FIX1)='1'B;                           /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */
    FIN;                                            /*    */
  ELSE                                              /*    */
    Z_STOER(FIX1)=0;                                /*    */
    B_STOER(FIX1)='0'B;                             /*    */
  FIN;                                              /*    */
 
  /* Stoerung Kessel2 keine Rueckmeldung  */
  FIX1=12;
  IF Z_KLZ(2) > 720(31) AND NOT B_KL(2) THEN           /*    */  
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
    IF Z_STOER(FIX1)>30 AND NOT B_STOER(FIX1) THEN     /*    */  
      B_STOER(FIX1)='1'B;                              /*    */  
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */  
    FIN;                                               /*    */  
  ELSE                                                 /*    */  
    Z_STOER(FIX1)=0;                                   /*    */  
    B_STOER(FIX1)='0'B;                                /*    */  
  FIN;                                                 /*    */  
 
  B_KHARDST(2)=   B_STOER(11) OR  B_STOER(12);
  IF B_KHARDST(2) AND NOT B_KL(2) THEN
    IF Z_KHARDST(2) < 1200 THEN
      Z_KHARDST(2)=Z_KHARDST(2)+1;
    FIN;
  ELSE
    Z_KHARDST(2)=0;
  FIN;


  /* Kessel3 Stoerung                                   */
  FIX1=13;
  IF BI_DEINBEW( 7) THEN        /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                  /*    */
    IF Z_STOER(FIX1)>30 AND NOT B_STOER(FIX1) THEN  /*    */
      B_STOER(FIX1)='1'B;                           /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */
    FIN;                                            /*    */
  ELSE                                              /*    */
    Z_STOER(FIX1)=0;                                /*    */
    B_STOER(FIX1)='0'B;                             /*    */
  FIN;                                              /*    */
 
  /* Stoerung Kessel2 keine Rueckmeldung  */
  FIX1=14;
  IF Z_KLZ(3) > 720(31) AND NOT B_KL(3) THEN           /*    */  
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
    IF Z_STOER(FIX1)>30 AND NOT B_STOER(FIX1) THEN     /*    */  
      B_STOER(FIX1)='1'B;                              /*    */  
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */  
    FIN;                                               /*    */  
  ELSE                                                 /*    */  
    Z_STOER(FIX1)=0;                                   /*    */  
    B_STOER(FIX1)='0'B;                                /*    */  
  FIN;                                                 /*    */  
 
  B_KHARDST(3)=   B_STOER(13) OR  B_STOER(14);
  IF B_KHARDST(3) AND NOT B_KL(3) THEN
    IF Z_KHARDST(3) < 1200 THEN
      Z_KHARDST(3)=Z_KHARDST(3)+1;
    FIN;
  ELSE
    Z_KHARDST(3)=0;
  FIN;


  /* St”rung Hauptkreis auf Dauer zu kalt                */
  FIX1=17;
! IF TC_VIST < TC_VSOLL-10.0 AND B_WA THEN          /*    */  
  IF X_AEIN(13) < TC_VSOLL-10.0 AND B_WA THEN          /*    */  
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                  /*    */  
    IF Z_STOER(FIX1) == 2700 THEN   /* <<<                   */  
      CALL SCH_KZU;                                    /*    */
      CALL STOERMELD(63,'K EIN wg. Hauptk');         /*    */
    FIN;                                               /*    */
    IF Z_STOER(FIX1)>3600 AND NOT B_STOER(FIX1) THEN   /*    */  
      B_STOER(FIX1)='1'B;                            /*    */  
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));         /*    */
    FIN;                                           /*    */  
  ELSE                                             /*    */  
    Z_STOER(FIX1)=0;                                 /*    */  
    B_STOER(FIX1)='0'B;                              /*    */  
  FIN;                                             /*    */  


! /* Stoerung WW1-AUSTRITT auf Dauer zu kalt                */
! FIX1=15;
! IF TC_BWO(1) < TC_BWS(1)-10.0                       /*    */
!      AND TC_BWO(1) < 42.0 THEN                      /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
!   IF Z_STOER(FIX1)>1200 AND NOT B_STOER(FIX1) THEN    /*    */  
!     B_STOER(FIX1)='1'B;                              /*    */  
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */  
! ELSE                                                 /*    */  
!   Z_STOER(FIX1)=0;                                   /*    */  
!   B_STOER(FIX1)='0'B;                                /*    */  
! FIN;                                                 /*    */  

  /* Stoerung WW-Speicher1 auf Dauer zu kalt                */
! FIX1=15;
! IF B_BWANF(1)   AND TC_BWO(1)<TC_BWS(1)-          /*    */
!    TD_BWDRIG(1)-3.0 AND TC_BWO(1)<42.0 THEN          /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
!   IF Z_STOER(FIX1)>3600 AND NOT B_STOER(FIX1) THEN   /*    */  
!     B_STOER(FIX1)='1'B;                              /*    */  
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */  
! ELSE                                                 /*    */  
!   Z_STOER(FIX1)=0;                                   /*    */  
!   B_STOER(FIX1)='0'B;                                /*    */  
! FIN;                                                 /*    */  
!
! /* Stoerung WW-ZIRK auf Dauer zu kalt                */
! FIX1=16;
! IF TC_ZIRK(1) < TC_BWZS(1)-5.0                       /*    */
!      AND TC_ZIRK(1) < 50.0 THEN                      /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
!   IF Z_STOER(FIX1)>3600 AND NOT B_STOER(FIX1) THEN    /*    */  
!     B_STOER(FIX1)='1'B;                              /*    */  
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */  
! ELSE                                                 /*    */  
!   Z_STOER(FIX1)=0;                                   /*    */  
!   B_STOER(FIX1)='0'B;                                /*    */  
! FIN;                                                 /*    */  
!
! /* Stoerung WW-Speicher2 auf Dauer zu kalt                */
! FIX1=17;
! IF B_BWANF(2)   AND TC_BWO(2)<TC_BWS(2)-          /*    */
!    TD_BWDRIG(2)-3.0 AND TC_BWO(2)<42.0 THEN          /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
!   IF Z_STOER(FIX1)>3600 AND NOT B_STOER(FIX1) THEN   /*    */  
!     B_STOER(FIX1)='1'B;                              /*    */  
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */  
! ELSE                                                 /*    */  
!   Z_STOER(FIX1)=0;                                   /*    */  
!   B_STOER(FIX1)='0'B;                                /*    */  
! FIN;                                                 /*    */  
!
! /* Stoerung WW-ZIRK auf Dauer zu kalt                */
! FIX1=18;
! IF TC_ZIRK(2) < TC_BWZS(2)-5.0                       /*    */
!      AND TC_ZIRK(2) < 50.0 THEN                      /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
!   IF Z_STOER(FIX1)>3600 AND NOT B_STOER(FIX1) THEN    /*    */  
!     B_STOER(FIX1)='1'B;                              /*    */  
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */  
! ELSE                                                 /*    */  
!   Z_STOER(FIX1)=0;                                   /*    */  
!   B_STOER(FIX1)='0'B;                                /*    */  
! FIN;                                                 /*    */  
!
! /* Stoerung WW-Speicher2 auf Dauer zu kalt                */
! FIX1=19;
! IF B_BWANF(3)   AND TC_BWO(3)<TC_BWS(3)-          /*    */
!    TD_BWDRIG(3)-3.0 AND TC_BWO(3)<42.0 THEN          /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
!   IF Z_STOER(FIX1)>3600 AND NOT B_STOER(FIX1) THEN   /*    */  
!     B_STOER(FIX1)='1'B;                              /*    */  
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */  
! ELSE                                                 /*    */  
!   Z_STOER(FIX1)=0;                                   /*    */  
!   B_STOER(FIX1)='0'B;                                /*    */  
! FIN;                                                 /*    */  
!
! /* Stoerung WW-ZIRK auf Dauer zu kalt                */
! FIX1=20;
! IF TC_ZIRK(3) < TC_BWZS(3)-5.0                       /*    */
!      AND TC_ZIRK(3) < 50.0 THEN                      /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */  
!   IF Z_STOER(FIX1)>3600 AND NOT B_STOER(FIX1) THEN    /*    */  
!     B_STOER(FIX1)='1'B;                              /*    */  
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */  
! ELSE                                                 /*    */  
!   Z_STOER(FIX1)=0;                                   /*    */  
!   B_STOER(FIX1)='0'B;                                /*    */  
! FIN;                                                 /*    */  


  /* Warnung Heizungsdruck MAX    */ /* <<<< */
! FIX1=17;
! IF X_AEIN(28) > FL_EXPHK(13) THEN
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;
!   IF Z_STOER(FIX1)>10 AND NOT B_STOER(FIX1) THEN
!     B_STOER(FIX1)='1'B;
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */  
!   FIN;
! ELSE
!   IF X_AEIN(28) < FL_EXPHK(13)*0.95 THEN
!     Z_STOER(FIX1)=0;
!     B_STOER(FIX1)='0'B;
!   FIN;
! FIN;

  /* Warnung Heizungsdruck        */       /* <<<< */
! FIX1=18;
! IF X_AEIN(28) < FL_EXPHK(14) THEN
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;
!   IF Z_STOER(FIX1)>10 AND NOT B_STOER(FIX1) THEN
!     B_STOER(FIX1)='1'B;
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */  
!   FIN;
! ELSE
!   IF X_AEIN(28) > FL_EXPHK(14)*1.05 THEN
!     Z_STOER(FIX1)=0;
!     B_STOER(FIX1)='0'B;
!   FIN;
! FIN;



  /* Stoerung Heizkreise auf Dauer zu kalt                        */
  FIX1=20;
  FOR I TO N_HZKR REPEAT                                   /*    */
    IF     TC_HKIST(I) < TC_HKSOLL(I)-8.0                  /*    */
       AND TC_VIST     > TC_HKIST(I) +8.0                  /*    */
       AND TC_HKIST(I) < 65.0 THEN                         /*    */  
      Z_STOER(FIX1+I)=Z_STOER(FIX1+I)+1;                   /*    */  
      IF Z_STOER(FIX1+I)>3600 AND NOT B_STOER(FIX1+I) THEN /*    */  
        B_STOER(FIX1+I)='1'B;                              /*    */  
        CALL STOERMELD(FIX1+I,TX_STOERMEL(FIX1+I));        /*    */
      FIN;                                                 /*    */  
    ELSE                                                   /*    */  
      IF Z_STOER(FIX1+I) > 5 THEN                          /*    */
        Z_STOER(FIX1+I)=Z_STOER(FIX1+I)-5;                 /*    */  
        B_STOER(FIX1+I)='0'B;                              /*    */  
      FIN;                                                 /*    */
      IF Z_STOER(FIX1+I) > 3000 THEN                       /*    */
        Z_STOER(FIX1+I)=3000;                              /*    */  
      FIN;                                                 /*    */
    FIN;                                                   /*    */  
    /* Stoerung HK zu warm                                        */
    IF     TC_HKIST(I) > TC_HKSTW(I) THEN                  /*    */
      Z_STOERSTW(I)=Z_STOERSTW(I)+1;                       /*    */  
      IF Z_STOERSTW(I)>600 AND NOT B_STOERSTW(I) THEN      /*    */  
        B_STOERSTW(I)='1'B;                                /*    */  
        F(1)=I//10;                                        /*    */
        F(2)=I REM 10;                                     /*    */
        CALL STOERMELD(64,'HK'               /*    */
                      CAT TOCHAR(F(1)+48)    /*    */  
                      CAT TOCHAR(F(2)+48)    /*    */  
                      CAT ' STW VL   ');     /*    */  
        B_STOER(64)='1'B;                              /*    */
      FIN;                                             /*    */  
    ELSE                                               /*    */  
      IF Z_STOERSTW(I) > 5 THEN                        /*    */
        Z_STOERSTW(I)=Z_STOERSTW(I)-5;                 /*    */  
      ELSE                                             /*    */
        B_STOERSTW(I)='0'B;                            /*    */  
      FIN;                                             /*    */
    FIN;                                               /*    */  
    CALL FIXGRENZ(700,0,Z_STOERSTW(I));                /*    */  
    IF ZF_HKPEXT(I) > 0 THEN          /* <<< EINFLUSS MODBUS */
      B_STOERSTW(I)='0'B;                  
    FIN; 
  END;                                                 /*    */
  B_LOOP='0'B;                                         /*    */
  FOR I TO N_HZKR REPEAT                               /*    */
    IF B_STOERSTW(I) THEN                              /*    */
      B_LOOP='1'B;                                     /*    */
    FIN;                                               /*    */
  END;                                                 /*    */
  B_STOER(64)=B_LOOP;                                  /*    */



  /* WW Desinfektion Warnung                           */
! FOR I TO N_SPEI REPEAT                                     /*    */
!   IF Z_LEGIO(I) == 2 AND TC_BWO(I) < TC_LEGIO(I)-1.0 THEN  /*    */
!     Z_STOER(65)=4800;                                      /*    */
!     F(1)=I REM 10;                                         /*    */
!     CALL STOERMELD(65,'WW'                                 /*    */
!                   CAT TOCHAR(F(1)+48)                      /*    */  
!                   CAT ' Desinf. Warn');                    /*    */  
!   FIN;                                                     /*    */
! END;                                                       /*    */
! IF Z_STOER(65) > 0 THEN                                    /*    */
!   Z_STOER(65)=Z_STOER(65)-1;                               /*    */
! FIN;                                                       /*    */
! B_STOER(65)=Z_STOER(65) > 1;                               /*    */


  /* Stoerung BHKW1 Rueckmeld.                         */
! FIX1=30;                                             /*    */
! IF B_BEIN(1) AND B_BERLAUBT2(1) AND NOT B_BL(1) THEN     /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
!   IF Z_STOER(FIX1)> 1800 AND NOT B_STOER(FIX1) THEN     /*    */
!     B_STOER(FIX1)='1'B;                              /*    */
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */
! ELSE                                                 /*    */
!   Z_STOER(FIX1)=0;                                   /*    */
!   B_STOER(FIX1)='0'B;                                /*    */
! FIN;                                                 /*    */

  /* Stoerung PMP HK1                                  */
  FIX1=30;                                             /*    */
  IF     BI_DEINBEW( 9) THEN           /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
    IF Z_STOER(FIX1)> 10 AND NOT B_STOER(FIX1) THEN     /*    */
      B_STOER(FIX1)='1'B;                              /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
    FIN;                                               /*    */
  ELSE                                                 /*    */
    Z_STOER(FIX1)=0;                                   /*    */
    B_STOER(FIX1)='0'B;                                /*    */
  FIN;                                                 /*    */

  /* Stoerung PMP HK2                                 */
  FIX1=31;                                             /*    */
  IF     BI_DEINBEW(11) THEN           /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
    IF Z_STOER(FIX1)> 10 AND NOT B_STOER(FIX1) THEN     /*    */
      B_STOER(FIX1)='1'B;                              /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
    FIN;                                               /*    */
  ELSE                                                 /*    */
    Z_STOER(FIX1)=0;                                   /*    */
    B_STOER(FIX1)='0'B;                                /*    */
  FIN;                                                 /*    */

  /* Stoerung PMP HK3                                 */
  FIX1=32;                                             /*    */
  IF     BI_DEINBEW(13) THEN           /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
    IF Z_STOER(FIX1)> 10 AND NOT B_STOER(FIX1) THEN     /*    */
      B_STOER(FIX1)='1'B;                              /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
    FIN;                                               /*    */
  ELSE                                                 /*    */
    Z_STOER(FIX1)=0;                                   /*    */
    B_STOER(FIX1)='0'B;                                /*    */
  FIN;                                                 /*    */

  /* Stoerung Druckhaltung                             */
  FIX1=33;                                             /*    */
  IF     BI_DEINBEW(14) THEN           /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
    IF Z_STOER(FIX1)> 10 AND NOT B_STOER(FIX1) THEN     /*    */
      B_STOER(FIX1)='1'B;                              /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
    FIN;                                               /*    */
  ELSE                                                 /*    */
    Z_STOER(FIX1)=0;                                   /*    */
    B_STOER(FIX1)='0'B;                                /*    */
  FIN;                                                 /*    */

  /* Stoerung Biogas MAX                               */
  FIX1=34;                                             /*    */
  IF     BI_DEINBEW(15) THEN           /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
    IF Z_STOER(FIX1)> 10 AND NOT B_STOER(FIX1) THEN     /*    */
      B_STOER(FIX1)='1'B;                              /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
    FIN;                                               /*    */
  ELSE                                                 /*    */
    Z_STOER(FIX1)=0;                                   /*    */
    B_STOER(FIX1)='0'B;                                /*    */
  FIN;                                                 /*    */

  /* Stoerung Not-Aus Trockn                           */
  FIX1=35;                                             /*    */
  IF NOT BI_DEINBEW(16) THEN           /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
    IF Z_STOER(FIX1)> 10 AND NOT B_STOER(FIX1) THEN     /*    */
      B_STOER(FIX1)='1'B;                              /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
    FIN;                                               /*    */
  ELSE                                                 /*    */
    Z_STOER(FIX1)=0;                                   /*    */
    B_STOER(FIX1)='0'B;                                /*    */
  FIN;                                                 /*    */

! /* Stoerung DRUCKHALT                                */
! FIX1=35;                                             /*    */
! IF     BI_DEINBEW(11) THEN           /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
!   IF Z_STOER(FIX1)> 10 AND NOT B_STOER(FIX1) THEN     /*    */
!     B_STOER(FIX1)='1'B;                              /*    */
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */
! ELSE                                                 /*    */
!   Z_STOER(FIX1)=0;                                   /*    */
!   B_STOER(FIX1)='0'B;                                /*    */
! FIN;                                                 /*    */
!
! /* Stoerung NACHSPEIS                                */
! FIX1=36;                                             /*    */
! IF     BI_DEINBEW(12) THEN           /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
!   IF Z_STOER(FIX1)> 10 AND NOT B_STOER(FIX1) THEN     /*    */
!     B_STOER(FIX1)='1'B;                              /*    */
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */
! ELSE                                                 /*    */
!   Z_STOER(FIX1)=0;                                   /*    */
!   B_STOER(FIX1)='0'B;                                /*    */
! FIN;                                                 /*    */
!
!
!
! /* Laufzeit Wassernachfuellung ueberwachen             */
! FIX1=37;
! IF Z_HZGFUELL >= ZF_HZGFUELL THEN                 /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                  /*    */
!   IF Z_STOER(FIX1)>1  AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                           /*    */
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */
!   FIN;                                            /*    */
! ELSE                                              /*    */
!   Z_STOER(FIX1)=0;                                /*    */
!   B_STOER(FIX1)='0'B;                             /*    */
! FIN;                                              /*    */


!  /* HEIZRAUM WARM                                    */
! FIX1=36;                                             /*    */
! IF X_AEIN(24) > TC_HKINENN(16) THEN           /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                     /*    */
!   IF Z_STOER(FIX1)> 5 AND NOT B_STOER(FIX1) THEN     /*    */
!     B_STOER(FIX1)='1'B;                              /*    */
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!   FIN;                                               /*    */
! ELSE                                                 /*    */
!   IF X_AEIN(24) < TC_HKINENN(16)-1.0 THEN           /*    */
!     Z_STOER(FIX1)=0;                                   /*    */
!     B_STOER(FIX1)='0'B;                                /*    */
!   FIN;
! FIN;                                                 /*    */

    
  /* Stoerung UPE-Pumpe1 Kess1                  */
! FIX1= 43;
! IF B_DO( 2) AND UPE_FEHLER(1) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER(1)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE1 Kessel  St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE1 Kessel  St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO( 2) AND UPE_FEHLER(1) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */
!
! /* Stoerung UPE-Pumpe2 P2 HK1                 */
! FIX1= 44;
! IF B_DO( 3) AND UPE_FEHLER(2) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER(2)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE2 P1 HK1  St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE2 P1 HK1  St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO( 3) AND UPE_FEHLER(2) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */
!
! /* Stoerung UPE-Pumpe3 P2 HK1                 */
! FIX1= 45;
! IF B_DO( 4) AND UPE_FEHLER(3) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER(3)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE3 P2 HK1  St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE3 P2 HK1  St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO( 4) AND UPE_FEHLER(3) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */
!
! /* Stoerung UPE-Pumpe4  P1 HK2                 */
! FIX1= 46;
! IF B_DO( 7) AND UPE_FEHLER( 4) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER( 4)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE4 P1 HK2  St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE4 P1 HK2  St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO( 7) AND UPE_FEHLER( 4) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */
!
!   /* Stoerung UPE-Pumpe5  P2 HK2                 */
! FIX1= 47;
! IF B_DO( 8) AND UPE_FEHLER( 5) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER( 5)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE5 P2 HK2  St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE5 P2 HK2  St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO( 8) AND UPE_FEHLER( 5) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */
 
! /* Stoerung UPE-Pumpe6  HK5                    */
! FIX1= 48;
! IF B_DO(15) AND UPE_FEHLER( 6) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER( 6)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE6 HK5 Kon St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE6 HK5 Kon St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO(15) AND UPE_FEHLER( 6) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */
!
! /* Stoerung UPE-Pumpe7  WW2 lad                */
! FIX1= 49;
! IF B_DO(18) AND UPE_FEHLER( 7) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER( 7)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE7 WW2 Spo St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE7 WW2 Spo St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO(18) AND UPE_FEHLER( 7) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */
!
! /* Stoerung UPE-Pumpe8  WW1                    */
! FIX1= 50;
! IF B_DO(21) AND UPE_FEHLER( 8) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER( 8)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE8 WW1 Kue St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE8 WW1 Kue St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO(21) AND UPE_FEHLER( 8) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */
 
! /* Stoerung UPE-Pumpe9  Hallenbad              */
! FIX1=108;
! IF B_DO(33) AND UPE_FEHLER( 9) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER( 9)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE9 Hallb   St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE9 Hallb   St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO(33) AND UPE_FEHLER( 9) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */
!
! /* Stoerung UPE-Pumpe10 HK8                    */
! FIX1=109;
! IF B_DO(36) AND UPE_FEHLER(10) > 0 THEN 
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                   /*    */
!   IF Z_STOER(FIX1)>180 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                            /*    */
!     IF UPE_FEHLER(10)==1 THEN                       /*    */
!       CALL STOERMELD(FIX1,'UPE10 Freib  St. int');     /*    */
!     ELSE                                           /*    */ 
!       CALL STOERMELD(FIX1,'UPE10 Freib  St. Bus');     /*    */ 
!     FIN;                                           /*    */
!   FIN;                                             /*    */
! ELSE                                               /*    */
!   IF B_DO(36) AND UPE_FEHLER(10) < 1 THEN 
!     Z_STOER(FIX1)=0;                                 /*    */
!     B_STOER(FIX1)='0'B;                              /*    */
!   FIN;
! FIN;                                               /*    */





  /* BHKW STARTS UEBERWACHEN                                      */
! FIX1=52;
! IF Z_START24 > ZF_STARTMAX THEN                            /*    */
!   Z_STOER(FIX1)=Z_STOER(FIX1)+1;                  /*    */
!   IF Z_STOER(FIX1)>0 AND NOT B_STOER(FIX1) THEN  /*    */
!     B_STOER(FIX1)='1'B;                           /*    */
!     CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */
!   FIN;                                            /*    */
! ELSE                                              /*    */
!   Z_STOER(FIX1)=0;                                /*    */
!   B_STOER(FIX1)='0'B;                             /*    */
! FIN;                                              /*    */


  /* Stoerungen MBUS-Zaehler                                       */
  FIX1=84;                                                  /*    */
  FOR I TO  7 REPEAT                                        /*    */
    IF ZT_MBUS(I) < ZT_JAHR - 12000(31) THEN                /*    */
      Z_STOER(FIX1+I)=Z_STOER(FIX1+I)+1;                    /*    */
      IF Z_STOER(FIX1+I)>3600 AND NOT B_STOER(FIX1+I) THEN  /*    */
        B_STOER(FIX1+I)='1'B;                               /*    */
        CALL STOERMELD(FIX1+I,TX_STOERMEL(FIX1+I));         /*    */
      FIN;                                                  /*    */
    ELSE                                                    /*    */
      Z_STOER(FIX1+I)=0;                                    /*    */
      B_STOER(FIX1+I)='0'B;                                 /*    */
    FIN;                                                    /*    */
  END;                                                      /*    */



  /* Stoerung CAN-Verbindung zur Unterstation                     */
! FOR I TO 1 REPEAT
!   FIX1=51+I;
!   IF Z_UCAN(I) < -60 THEN
!     IF NOT B_STOER(FIX1) THEN     /*    */
!       B_STOER(FIX1)='1'B;                              /*    */
!       CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!     FIN;                                               /*    */
!   ELSE
!     IF Z_UCAN(I) > 5 THEN
!       B_STOER(FIX1)='0'B;
!     FIN;
!   FIN;
!   Z_UCAN(I)=Z_UCAN(I)-1; 
!   IF Z_UCAN(I) > 100   THEN  Z_UCAN(I)=100;    FIN;
!   IF Z_UCAN(I) < -300  THEN  Z_UCAN(I)=-300;   FIN;
! END;
  


! X_AEINEXT(47,x)  enthaelt Stoernummer Unterstation
!             +1  Hauptkreis kalt
!             +2  HK kalt         
!             +4  Kesselstoe      
!             +8  Sammelstoe
!      
!             0   keine Stoerung
!             1   Hauptkreis kalt
!             2   HK kalt
!             3   Hauptkreis kalt + HK kalt
!             4   WW kalt
!             5   Hauptkreis kalt + WW kalt
!             6   HK kalt + WW kalt
!             7   Hauptkreis kalt + HK kalt + WW kalt
!             8   sonstiges
!             9   sonstiges + Hauptkreis kalt
!            10   sonstiges + HK kalt
!            11   sonstiges + Hauptkreis kalt + HK kalt
!            12   sonstiges + WW kalt
!            13   sonstiges + Hauptkreis kalt + WW kalt
!            14   sonstiges + HK kalt + WW kalt
!            15   sonstiges + Hauptkreis kalt + HK kalt + WW kalt

! FOR I TO 1 REPEAT                                      /*    */
!   BI_DAUS(20)=TOBIT(ROUND(X_AEINEXT(45,I)));           /*    */
!   FOR K TO 4 REPEAT                                    /*    */
!     FIX1=42+I*5+K;                                     /*    */
!     IF BI_DAUS(20).BIT(17-K) THEN                      /*    */
!       IF NOT B_STOER(FIX1) THEN                        /*    */
!         B_STOER(FIX1)='1'B;                            /*    */
!         CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));        /*    */
!       FIN;                                             /*    */
!     ELSE                                               /*    */
!       B_STOER(FIX1)='0'B;                              /*    */
!     FIN;                                               /*    */
!   END;                                                 /*    */
!!  FIX1=39+I*5;
!!  IF X_AEINEXT(30,I) > 0.5 THEN           /* UST STOE PMP HK */
!!    IF NOT B_STOER(FIX1) THEN                          /*    */
!!      B_STOER(FIX1)='1'B;                              /*    */
!!      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));          /*    */
!!    FIN;                                               /*    */
!!  ELSE                                                 /*    */
!!    B_STOER(FIX1)='0'B;                                /*    */
!!  FIN;                                                 /*    */    
! END;


  /* Display aufgehaengt Abschaltung                           */
  FIX1=72;                                              /*    */
  IF Z_PANELPAUS > 9800 THEN                            /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                      /*    */
    IF Z_STOER(FIX1)>0 AND NOT B_STOER(FIX1) THEN       /*    */
      B_STOER(FIX1)='1'B;                               /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));           /*    */
      Z_PANELRESET=Z_PANELRESET+1;                      /*    */
    FIN;                                                /*    */
  ELSE                                                  /*    */
    Z_STOER(FIX1)=0;                                    /*    */
    B_STOER(FIX1)='0'B;                                 /*    */
  FIN;                                                  /*    */
 
  /* Display aufgehaengt total                          */
  FIX1=73;                                              /*    */
  IF Z_PANELPAUS > 12000 THEN                           /*    */
    Z_STOER(FIX1)=Z_STOER(FIX1)+1;                      /*    */
    IF Z_STOER(FIX1)>1 AND NOT B_STOER(FIX1) THEN       /*    */
      B_STOER(FIX1)='1'B;                               /*    */
      CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));           /*    */
    FIN;                                                /*    */
  ELSE                                                  /*    */
    Z_STOER(FIX1)=0;                                    /*    */
    B_STOER(FIX1)='0'B;                                 /*    */
  FIN;                                                  /*    */



  /* Kontrolle Compact Flash-Karte                     */
  FIX1=80;
  IF NOT B_FLASHVORH THEN                           /*    */
    IF NOT B_STOER(FIX1) THEN                       /*    */
      B_STOER(FIX1)='1'B;                           /*    */
      CALL STOERMELD(FIX1,'SD-Karte??');       /*    */
    FIN;                                            /*    */
  FIN;                                              /*    */

  /* Kontrolle UDN-Bausteine                           */
  IF Z_LZ > 10(31) THEN
    FIX1=81;
    B_LOOP='0'B;
    FOR I TO N_RELPLT REPEAT
      IF Z_UDNSTOER(I) > 10 THEN
        B_LOOP='1'B;
        IF Z_UDNSTOER(I) > 15 THEN
          Z_UDNSTOER(I)=15;
        FIN;
      FIN;
    END;
    IF B_LOOP THEN                           /*    */
      IF NOT B_STOER(FIX1) THEN                       /*    */
        B_STOER(FIX1)='1'B;                           /*    */
        CALL STOERMELD(FIX1,TX_STOERMEL(FIX1));       /*    */
      FIN;                                            /*    */
    ELSE
      B_STOER(FIX1)='0'B;                             /*    */
    FIN;                                              /*    */
  FIN;

  /* bei noch nicht gemeldeten St”rungen Wartez„hler erh”hen         */
  B_LOOP='0'B;
  B_LOOP2='0'B;
  B_STSAMMGES='0'B;
  FOR I TO 200 REPEAT

    IF ZF_STOERFREI(I) > 2 THEN
      B_STOER(I)='0'B;
      Z_STOER(I)=0;
    FIN;


    IF B_STOER(I) AND ZF_STOERFREI(I) < 2 THEN
      IF NOT B_STOERMERK(I) THEN
        Z_STOERNEU(I)=Z_STOERNEU(I)+1;
        CALL FIXGRENZ(30000,0,Z_STOERNEU(I));  
        B_STOERMERK(I)='1'B;
      FIN;
    ELSE
      B_STOERMERK(I)='0'B;
    FIN;

    CALL FIXGRENZ(30000,0,Z_STOER(I));  
    IF B_STOER(I) AND ZF_STOERFREI(I) < 2 THEN
  !   IF I /= 56 THEN  /* <<< BHKW Warnung soll kein Störungsblinken verursachen */
      IF I /= 56 AND I /= 57 THEN  /* <<< BHKW Warnung soll kein Störungsblinken verursachen */
        B_LOOP='1'B;
      FIN;
    FIN;
    IF B_STOER(I) AND ZF_STOERFREI(I) < 2 AND B_STSAMMFREI(I) THEN
      B_STSAMMGES='1'B;
    FIN;
    IF B_STOER(I) AND ZF_STOERFREI(I) < 2 AND ZF_STOERDRIG(I) > 0 THEN
      Z_STOERFAST(I)=1800;
    ELSE
      IF Z_STOERFAST(I) > 0 THEN  Z_STOERFAST(I)=Z_STOERFAST(I)-1;  FIN;
      IF ZF_STOERFREI(I) > 1 OR ZF_STOERDRIG(I) < 1 THEN
        Z_STOERFAST(I)=0;
      FIN;
    FIN;
  END;

  /* wenn keine St”rung anliegt dann Fehlerdatei l”schen             */
  IF NOT B_LOOP THEN
    B_SAMMELST='0'B;
  ELSE
    B_SAMMELST='1'B;
  FIN;

! IF B_PMPHK(22) THEN       /* ZUBR HAUS A <<< */
!   Z_FREECOUNT(22)=100;
! FIN;
! IF Z_FREECOUNT(22) > 0 THEN
!   Z_FREECOUNT(22)=Z_FREECOUNT(22)-1;
! FIN;
!
! IF B_PMPHK(23) THEN       /* ZUBR VILLA */
!   Z_FREECOUNT(23)=60;
! FIN;
! IF Z_FREECOUNT(23) > 0 THEN
!   Z_FREECOUNT(23)=Z_FREECOUNT(23)-1;
! FIN;

  /*!!!--------------------------------------------------------------*/
  /*     Auflegen der logischen Signale auf die Ausg„nge             */

  /*                      Relaisplatine 1:   Ausgang:                */
! BI_DAUS(1).BIT(16)='1'B;                               /* 1: KESSEL VERS       */
  BI_DAUS(1).BIT(16)=B_KEIN(1) AND B_KTHERM(1);          /* 1: KESSEL1           */
! BI_DAUS(1).BIT(15)=B_KPMP(1) AND (Z_KHARDST(1) < 940 OR ZF_KPMPEXT(1) > 0);        /* 2: K1 PMP ANF        */
  BI_DAUS(1).BIT(15)=B_KPMP(1) AND (Z_KHARDST(1) < 940 OR ZF_KPMPEXT(1) > 0) OR B_KL(1) OR B_KPMP(6);        /* 2: K1 PMP ANF        */
  BI_DAUS(1).BIT(14)=B_KESMIA(1);                        /* 3: K1 RL-MI AUF      */
  BI_DAUS(1).BIT(13)=B_KESMIZ(1);                        /* 4: K1 RL-MI ZU       */
  BI_DAUS(1).BIT(12)=B_KEIN(2) AND B_KTHERM(2);          /* 5: KESSEL2           */
  BI_DAUS(1).BIT(11)=B_KPMP(2) AND (Z_KHARDST(2) < 940 OR ZF_KPMPEXT(2) > 0) OR B_KL(2) OR B_KPMP(7);        /* 6: K2 PMP ANF        */
  BI_DAUS(1).BIT(10)=B_KESMIA(2);                        /* 7: K2 RL-MI AUF      */
  BI_DAUS(1).BIT( 9)=B_KESMIZ(2);                        /* 8: K2 RL-MI ZU       */

  /*                      Relaisplatine 2:   Ausgang:                */
  BI_DAUS(2).BIT(16)=B_KEIN(3) AND B_KTHERM(3);          /* 1: KESSEL3           */
  BI_DAUS(2).BIT(15)=B_KLRAUF(3);                        /* 2: K3 PRAUF          */
  BI_DAUS(2).BIT(14)=B_KLRUNT(3);                        /* 3: K3 PRUNTER        */
  BI_DAUS(2).BIT(13)=B_KPMP(3) AND (Z_KHARDST(3) < 940 OR ZF_KPMPEXT(3) > 0);        /* 2: K3 PMP ANF        */
  BI_DAUS(2).BIT(12)=B_KESMIA(3);                        /* 5: K3 RL-MI AUF      */
  BI_DAUS(2).BIT(11)=B_KESMIZ(3);                        /* 6: K3 RL-MI ZU       */
  BI_DAUS(2).BIT(10)=B_PMPHK( 1) AND NOT B_STOERSTW( 1); /* 7: PMP HK1           */
  BI_DAUS(2).BIT( 9)=B_MIAUF( 1);                        /* 8: MI AUF              */

  /*                      Relaisplatine 3:   Ausgang:                */
  BI_DAUS(3).BIT(16)=B_MIZU( 1);                         /* 1: MI ZU             */
  BI_DAUS(3).BIT(15)=B_PMPHK( 2) AND NOT B_STOERSTW( 2); /* 2: PMP HK2           */
  BI_DAUS(3).BIT(14)=B_MIAUF( 2);                        /* 3: MI AUF              */
  BI_DAUS(3).BIT(13)=B_MIZU( 2);                         /* 4: MI ZU             */
  BI_DAUS(3).BIT(12)=B_PMPHK( 3) AND NOT B_STOERSTW( 3); /* 5: PMP HK3           */
  BI_DAUS(3).BIT(11)=B_MIAUF( 3);                        /* 6: MI AUF              */
  BI_DAUS(3).BIT(10)=B_MIZU( 3);                         /* 7: MI ZU             */
  BI_DAUS(3).BIT( 9)=B_KEIN(9);                          /* 8: BIOGASFACKEL      */

  /*                      Relaisplatine 4:   Ausgang:                */
  BI_DAUS(4).BIT(16)=B_PMPHK( 4);                        /* 1: VENT TROCKN       */
  BI_DAUS(4).BIT(15)=B_MIAUF( 4);                        /* 2: MI AUF              */
  BI_DAUS(4).BIT(14)=B_MIZU( 4);                         /* 3: MI ZU             */
  BI_DAUS(4).BIT(13)=B_KEIN(3) AND B_KTHERM(3);          /* 4: VERDICHETER BIOGAS */
  BI_DAUS(4).BIT(12)='0'B;                               /* 5: ---                */
  BI_DAUS(4).BIT(11)=B_STSAMMGES;                        /* 6: SAMMELSTÖRUNG     */
  BI_DAUS(4).BIT(10)=(Z_PANELPAUS > 9800 AND Z_PANELPAUS < 9900);  /* 7: PANEL PC AUS         */
  BI_DAUS(4).BIT( 9)=Z_SERVPAUS > 21600;                 /* 8: SSV AUS       */


 



! BI_DAUS(3).BIT(16)=B_HZGFUELL;                        /* 1: MV HZG             */
! BI_DAUS(3).BIT(11)=B_CANAUS;                          /* 6: CAN EW AUS          */
! BI_DAUS(1).BIT(14)=B_KPMP(1) AND (Z_KHARDST(1) < 940 OR ZF_KPMPEXT(1) > 0);        /* 3: MOV KES AUF      */
! BI_DAUS(1).BIT(13)=NOT (B_KPMP(1) AND (Z_KHARDST(1) < 940 OR ZF_KPMPEXT(1) > 0));  /* 4: MOV KES ZU   */
! BI_DAUS(2).BIT(12)=B_LPMP( 1);                         /* 5: WW LADEP          */
! BI_DAUS(2).BIT(11)=B_ZIRKPMP( 1);      PWM             /* 6: WW ZIRKP             */
! BI_DAUS(1).BIT(12)=B_PMPHK( 1) AND NOT B_STOERSTW( 1); /* 5: PMP HK1           */
! BI_DAUS(2).BIT(13)=B_LMIAUF( 1);                       /* 4: WW1 LADMI AUF         */
! BI_DAUS(2).BIT(12)=B_LMIZU( 1);                        /* 5: WW1 LADMI ZU       */
! BI_DAUS(4).BIT(13)=Z_IPLICHT > 1;                     /* 4: LICHT IP-KAM        */
!  IF Z_IPLICHT > 0 THEN  Z_IPLICHT=Z_IPLICHT-1;  FIN;
! BI_DAUS(3).BIT(11)=B_CANAUS;                          /* 6: CAN EW AUS          */


  /*----------------------------<<<----------------------------------*/

  /*******************************************************************/
  /* Alle Softwarehandschalter-Eingriffsmoeglichkeiten fuer digitale */
  /* Ausgaenge kontrollieren und evtl. setzen oder zuruecksetzen     */
  /*******************************************************************/
  FOR I TO N_DIGOUT REPEAT
    IF Z_DOHAND(DO_HARD(I)) > 0 THEN
      BI_ON (1+(DO_HARD(I)-1)//8).BIT(16-(DO_HARD(I)-1) REM 8)='1'B;
      BI_OFF(1+(DO_HARD(I)-1)//8).BIT(16-(DO_HARD(I)-1) REM 8)='1'B;
      IF Z_DOHAND(DO_HARD(I)) < 1000 THEN
        Z_DOHAND(DO_HARD(I))=Z_DOHAND(DO_HARD(I))-1;
      FIN;
    ELSE
      IF Z_DOHAND(DO_HARD(I)) < 0 THEN
        BI_ON (1+(DO_HARD(I)-1)//8).BIT(16-(DO_HARD(I)-1) REM 8)='0'B;
        BI_OFF(1+(DO_HARD(I)-1)//8).BIT(16-(DO_HARD(I)-1) REM 8)='0'B;
        IF Z_DOHAND(DO_HARD(I)) > -1000 THEN
          Z_DOHAND(DO_HARD(I))=Z_DOHAND(DO_HARD(I))+1;
        FIN;
      ELSE  /* ==0 */
        BI_ON (1+(DO_HARD(I)-1)//8).BIT(16-(DO_HARD(I)-1) REM 8)='0'B;
        BI_OFF(1+(DO_HARD(I)-1)//8).BIT(16-(DO_HARD(I)-1) REM 8)='1'B;
      FIN;
    FIN;
  END;

  /* falls die Task bis hier gekommen ist, den Watchdog beruhigen:   */
  B_WATCHDOG='1'B;
       
  ZP_2=NOW;
  FL_SYS=((ZP_2-ZP_1) / 0 HRS 00 MIN 00.001 SEC)*0.001;

  IF FL_SYS > 0.8 THEN
    Z_FREECOUNT(49)=3;
    ZFELD=ZFELD+1;
    CALL FIXGRENZ(120,1,ZFELD);  
    IF ZFELD < 100 THEN
      ZDFELD1(ZFELD)=FL_SYS;
      ZDFELD2(ZFELD)=ZT_JAHR;
    FIN;
  FIN;


END; /* of TASK SYSTAKT                                              */

ZDOUT: TASK PRIO 30;
  DCL MON  FIXED;
  DCL DAT  FIXED;
  DCL STD  FIXED;
  DCL MIN  FIXED;
  DCL SEK  FIXED;

  FOR I TO 100 REPEAT
    PUT I,ZDFELD1(I) TO A12 BY F(5),F(6,3);
    CALL DATETIME(ZDFELD2(I),DAT,MON,STD,MIN,SEK);
    PUT '   ',DAT,'.',MON,'.  ',STD,':',MIN,':',SEK TO A12 
      BY A,F(3),A,F(2),A,F(2),A,F(2),A,F(2),SKIP;
  END;

  AFTER 10 SEC RESUME;

  FOR I TO 100 REPEAT
    ZDFELD1(I)=0.0;
    ZDFELD2(I)=0(31);
  END;
  ZFELD=0;

END;

ZSTOEROUT: TASK PRIO 30;
  FOR I TO 120 REPEAT
    PUT I,Z_STOERNEU(I) TO A12 BY F(5),F(6),SKIP;
  END;
END;


/* 48 Timer auslesen */
RAUMABS: TASK PRIO 50;
 /* Dauerl„ufer,kontrolliert TIMER                                   */
  DCL B_ABS      BIT(1);

  REPEAT
    FOR I TO 64 REPEAT

      Z_RAUMABS=Z_RAUMABS+2;

      B_ABSEIN(I)=B_ZONE1((I-1)//16+1,Z_ZEHN).BIT((I-1) REM 16 +1);
      AFTER 0.2 SEC RESUME;
    END;
  END;

END;  /* of Task RAUMABS                                             */


/* Heizkreisabsenkungen auslesen */
HKABS: TASK PRIO 70;

  DCL B_MERK(48) BIT(1);
  DCL B_SCHL     BIT(1);
  DCL B_ABS      BIT(1);
  DCL B_VORHILF  BIT(1);
  DCL SOLL       FLOAT;
  DCL INDEX1     FIXED;
  DCL INDEX2     FIXED;
  DCL Z_VOR      FIXED;

  DCL ZUST_HZGMERK FIXED;   /* Hilfsvariable fuer Heizungszustand    */

  REPEAT
    ZUST_HZGMERK=3;  /* mit Dauernachtbetrieb vorbesetzen           */
    FOR I TO N_HZKR REPEAT

      Z_HKABS=Z_HKABS+2;

      B_ABS='1'B;
      B_VORHILF='0'B;
      INDEX1=(I-1)//16 + 1;
      INDEX2=(I-1) REM 16 + 1;
      IF B_ZONE1(INDEX1,Z_ZEHN).BIT(INDEX2) THEN      
        B_ABS='0'B;
      ELSE
        B_ABS='1'B;
      FIN;

      Z_VOR=10000;  
      IF Z_ZEHN < 995 AND B_ABS THEN
        FOR J FROM Z_ZEHN TO Z_ZEHN+10 WHILE Z_VOR==10000 REPEAT
          IF B_ZONE1(INDEX1,J).BIT(INDEX2) THEN    
            Z_VOR=J-Z_ZEHN;
          FIN;  
        END;
      FIN;     
      IF Z_VOR <= ROUND(ZD_VOR/10 MIN) THEN
        B_VORHILF='1'B;
      FIN;  
        
      CASE ZUST_HK(I)
        ALT      /* Automatikbetrieb   */
          IF ZUST_HZGMERK/=2 THEN /* wenn nicht schon Dauertag-    */
            ZUST_HZGMERK=1;       /* dann Automatik  (Zentrale)    */
          FIN;
        ALT      /* Dauernachtbetrieb   */
          B_ABS='1'B;
          B_HOCHHK(I)='0'B;
          B_VORHK(I)='0'B;
          B_VORHILF='0'B;
        ALT      /* Dauertagbetrieb (T1)*/
          B_ABS='0'B;
          ZUST_HZGMERK=2;      /* Heizzentrale im Dauertagbetrieb */
          B_VORHILF='0'B;
        OUT
      FIN;
      /* an dieser Stelle den HK-Jahreskalender einbauen          */
      IF B_JAHRAB(DA_MON,DA_DAT).BIT(I) THEN
        B_ABS='1'B;
        B_HOCHHK(I)='0'B;
        B_VORHK(I)='0'B;
        B_VORHILF='0'B;
      FIN;

        
   !  IF I==2 THEN        /* <<< HK2 LUEFTUNG  KALENDER ODER Digitaleingang */
   !    B_VORHILF='0'B;
   !    IF BI_DEINBEW(22) THEN 
   !      B_ABS='0'B;
   !    FIN;
   !  FIN;



      /* wenn Absenkung laut Kalender und noch nicht abgesenkt und  */
      /* sp„ter als Montag 00:10:00 dann absenken                   */
      IF B_ABS AND NOT B_ABSHK(I) AND Z_ZEHN>1 THEN
        B_TAERHK(I)='0'B;
        B_RUNTHK(I)='1'B;
        B_HOCHHK(I)='0'B;
        Z_HOCHHK(I)=0;
        B_ABSHK(I)='1'B;
      FIN;
      /* wenn keine Absenkung laut Kalender und Heizkreis ist       */
      /* abgesenkt und sp„ter als Montag 00:10:00 dann anheben      */
      IF NOT B_ABS AND B_ABSHK(I) AND Z_ZEHN>1 THEN
        B_RUNTHK(I)='0'B;
        B_VORHK(I)='0'B;
        B_NAERHK(I)='0'B;
        B_HOCHHK(I)='1'B;
        Z_RUNTHK(I)=0;
        B_ABSHK(I)='0'B;
        ZP_ABSEHK(I)=ZP_NOW;
        DA_ABSEHK(I)=DA_DAT;
      FIN;
      /* wenn Vorzeit laut Kalender und Heizkreis abgesenkt und     */
      /* dieser Heizkreis noch nicht in Vorphase und Heizkreis nicht*/
      /* im Dauernachtbetrieb und kein Absenkungstoggel dann Vorph. */
   !  IF B_VORHILF AND B_ABSHK(I) AND NOT B_VORHK(I) THEN
   !    B_RUNTHK(I)='0'B;
   !    B_NAERHK(I)='0'B;
   !    B_VORHK(I)='1'B;
   !    B_HOCHHK(I)='1'B;
   !  FIN;
      IF NOT B_ABSSTELL THEN /* schnell laufen wenn Verstellung      */
        /* Dauerl„ufertask legt sich hier erstmal fuer 1 SEC aufs Ohr */
        AFTER 0.5 SEC RESUME;
      FIN;
    END;
    ZUST_HZG=ZUST_HZGMERK;  /* Zustand uebernehmen                   */
    AFTER 0.1 SEC RESUME;   /* falls N_HZKR mal =0                   */
  END;
END;  /* of Task HKABS                                               */


/*********************************************************************/
/* Test der Zu und Abschaltbedingungen:                              */
/*********************************************************************/
/* Zuschalten des ersten BHKW:                                       */
TST_B1ZU: PROC RETURNS(BIT(1));
  RETURN((B_WA AND NOT B_SB OR           /* W„rmeanforderung und      */
                                         /* nicht BHKW nach Strombed. */
          B_SB AND PE_BEDARF>PE_RMIN1B+1.0) /*SB und Bed. gr. Prmin  */
         AND ((TC_VIST < TC_VSOLL - 0.5  /* Vorlauftemp. zu klein ?   */
               AND Z_TCKLEIN>ZF_T1EIN*6) /* Zeit- oder Temperatur- */
           OR (TC_VIST<TC_VSOLL-TD_1EIN AND Z_TCKLEIN > 10))  /* Bedingung              */
         AND Z_TMA < 1                   /* Mindestauszeit abgelaufen?*/
         AND NOT B_ESPB);                /* keine Einschaltsperre ?   */

END;

/* Zuschalten weiterer BHKW:                                         */
TST_BNZU1: PROC RETURNS(BIT(1));
  RETURN(    TST_BNZU2                  /* Alle Einschaltbed. gueltig?*/
         AND (Z_STKLEIN>=ZF_NBE OR      /* Steigung zu klein         */
             B_SB)                 );   /* oder Strombedarf          */
END;

TST_BNZU2: PROC RETURNS(BIT(1));
  RETURN(   Z_LMAX>ZF_LMAX              /* Leistungssoll an Grenze   */
        AND Z_TEIN < 1                  /* T ein abgelaufen?         */
        AND Z_TMA < 1                   /* Mindestauszeit abgelaufen?*/
        AND TC_VIST < TC_VSOLL - TD_BU);/* Vorlauftemp. zu klein ?   */
END;

/* Zuschalten des ersten Kessel:                                     */
TST_K1ZU1: PROC RETURNS(BIT(1));
    RETURN(    TST_K1ZU2                /* Alle Einschaltbed. gueltig?*/
           AND Z_STKLEIN>=ZF_NKE    );  /* Steigung zu klein         */
END;

TST_K1ZU2: PROC RETURNS(BIT(1));
  IF B_SB AND Z_BANFORD==0 THEN
    RETURN((   Z_LMAX>ZF_LMAX           /* Leistungssoll an Grenze   */
            OR B_SB            ) /* oder fehlende W„rme vom Kessel */
           AND Z_TEIN < 1               /* Ein-Zeit BHKW abgelaufen  */
           AND ((TC_VIST < TC_VSOLL-TD_KS /* Vorlauftemp. zu klein ? */
               AND Z_TCKLEIN>ZF_T1EIN*6)   /* Zeit- oder Temperatur- */
           OR (TC_VIST<TC_VSOLL-TD_1EIN))  /* Bedingung              */
           AND NOT B_ESPK               /* keine Einschaltsperre ?   */
           AND NOT B_KESAUS             /* Kessel aus                */
           AND Z_TMA < 1                /* Mindestauszeit abgelaufen */
           AND PE_THERM>=PE_MAX);
  ELSE
    RETURN((   Z_LMAX>ZF_LMAX           /* Leistungssoll an Grenze   */
            OR B_SB            )        /* oder BHKW nach Strombedarf */
           AND Z_TEIN < 1               /* Ein-Zeit BHKW abgelaufen  */
           AND TC_VIST < TC_VSOLL-TD_KS /* Vorlauftemp. zu klein ?   */
           AND NOT B_ESPK               /* keine Einschaltsperre ?   */
           AND NOT B_KESAUS             /* Kessel aus                */
           AND Z_TMA < 1                /* Mindestauszeit abgelaufen */
           AND PE_THERM>=PE_MAX);
  FIN;
END;

/* Zuschalten weiterer Kessel:                                       */
TST_KNZU1: PROC RETURNS(BIT(1));
  RETURN(    TST_KNZU2                  /* Alle Einschaltbed. gueltig?*/
         AND Z_STKLEIN>=ZF_NKE      );  /* Steigung zu klein         */
END;

TST_KNZU2: PROC RETURNS(BIT(1));
  RETURN(    Z_LKMAX>ZF_LKMAX           /* Leistungssoll an Grenze   */
         AND TC_VIST < TC_VSOLL - TD_KS /* Vorlauftemp. zu klein ?   */
         AND NOT B_ESPK                 /* keine Einschaltsperre ?   */
         AND NOT B_KESAUS               /* Kessel aus                */
         AND Z_TMA < 1                  /* Mindestauszeit abgelaufen */
         AND PE_THERM>=PE_MAX);
END;

/* Abschalten weiterer BHKW:                                         */
TST_BNAB: PROC RETURNS(BIT(1));
  RETURN(    Z_LMIN>ZF_TAUS*6           /* Leistungssoll an Grenze   */
         AND TC_VIST > TC_VSOLL + TD_BO /* Vorlauftemp. zu gro~  ?   */
         AND B_PMIN                     /* Solleistung untere Grenze?*/
         AND Z_LRSPERR < 1              /* Leistungsregelsperre aus? */
         AND ST_VIST > ST_VSOLL         /* Steigung zu gro~ ?        */
       OR   (TC_VIST > TC_MAX AND       /* T max erreicht            */
             Z_STGROSS>=ZF_NBA)         /* Steigung NBA*Messtakt>0   */
       OR   (B_SB AND                   /* Strombedarf und           */
             Z_LMIN>ZF_TAUS*6));        /* Leistungssoll an Grenze   */
END;

/* Abschalten des letzten BHKW:                                      */
/* wenn nicht nach Strombedarf gefahren wird, dann kann das letzte   */
/* BHKW nur thermostatisch ausgehen                                  */
TST_B1AB: PROC RETURNS(BIT(1));
  RETURN    (B_SB AND                   /* Strombedarf und           */
             Z_LMIN>ZF_TAUS*6);         /* Leistungssoll an Grenze   */
END;

/* Abschalten eines Kessels:                                         */
TST_KAB: PROC RETURNS(BIT(1));                
  DCL X_A FLOAT;
  DCL FL1 FLOAT;
  DCL FL2 FLOAT;

  /* Sonderbedingung, je nach Anzahl laufender BHKWs und PT-Schnitt   */
  /* die Abschaltbedingung variieren                                  */
! IF Z_BAKT > 0 THEN
!   X_A=300.0;
!   IF Z_BAKT > 1 THEN
!     X_A=360.0;
!   FIN;
! ELSE
!   X_A=  5.0;
! FIN;
! X_A=PT_BHKWMOEG*0.8;
  X_A=50.0;

  CASE ZF_HKPEXT(32)       /* <<< POSITION HAUPTKREISVL              */
    ALT
      FL1=X_AEIN( 9);        /* MITTE OBEN */
      IF X_AEIN(10) > FL1 THEN
        FL1=X_AEIN(10);
      FIN;
      IF X_AEIN(11) > FL1 THEN
        FL1=X_AEIN(11);
      FIN;
    ALT
      FL1=X_AEIN(10);        /* MITTE      */
      IF X_AEIN(11) > FL1 THEN
        FL1=X_AEIN(11);
      FIN;
    ALT
      FL1=X_AEIN(11);       /* MITTE UNTEN */
    ALT
      FL1=X_AEIN(11);       /* MITTE UNTEN */
    OUT
  FIN;

  IF PT_SCHNITT > X_A THEN
    RETURN ((  TC_VIST > TC_VSOLL+1.0     /* Vorlauftemp. zu gross     */
           AND ST_VIST > ST_VSOLL         /* Steigung zu gross         */
           AND Z_LRSPERR < 1              /* Leistungsregelsperre aus  */
           AND Z_KLZMIN > 60(31)          /* mindestens 1 MIN ein      */
           AND Z_PTMINKES > 200           /* mind. 200s mind. ein Kessel auf PMIN */
           AND   FL1      > TC_VSOLL-4.0  /*                    <<<     */
           OR  (TC_VIST > TC_VSOLL+0.8 AND Z_KAKT > 1)  /* bei 2Kes   <<<     */
           OR  (B_TM1 AND Z_LRSPERR < 1)  /* T max1 erreicht           */
           OR  B_TM2                      /* T max2 erreicht           */
    	     OR  B_KESAUS));                /* Kessel AUS gueltig         */
  ELSE
    RETURN ((  TC_VIST > TC_VSOLL+1.5     /* Vorlauftemp. zu gross     */
           AND ST_VIST > ST_VSOLL         /* Steigung zu gross         */
           AND Z_LRSPERR < 1              /* Leistungsregelsperre aus  */
           AND Z_KLZMIN > 60(31)          /* mindestens 1 MIN ein      */
           AND Z_PTMINKES > 150           /* mind. 150s mind. ein Kessel auf PMIN */
           OR  (B_TM1 AND Z_LRSPERR < 1)  /* T max1 erreicht           */
           OR  B_TM2                      /* T max2 erreicht           */
    	     OR  B_KESAUS));                /* Kessel AUS gueltig         */
  FIN;

END;

/*********************************************************************/
/* Schaltroutinen fuer BHKW und Kessel                                */
/*********************************************************************/

SCH_BZU: PROC;           /* BHKW zuschalten                          */

  DCL B_LOOP  BIT(1);
  DCL INDEX   FIXED;

  B_LOOP='1'B;           /* erstmal auf 1 setzen                     */
  INDEX=1;
  WHILE B_LOOP REPEAT    /* bis ein einsatzf„higes BHKW gefunden     *

    /* ist die Rangfolge des aktuellen BHKW kleiner oder gleich der  */
    /* Anzahl der angeforderten BHKWs + 1                            */
    IF FS_LBHKW(INDEX) <= Z_BANFORD+1 THEN

      /* wenn das Modul nicht gest”rt und noch nicht angefordert ist */
      IF     NOT B_BSTOER(INDEX) AND NOT B_BEIN(INDEX) 
         AND B_BBEREIT(INDEX) AND B_BERLAUBT2(INDEX) THEN
        B_BEIN(INDEX)='1'B;       /* Ausgabebit setzen                 */
        Z_BANFORD=Z_BANFORD+1;  /* Anforderung erh”hen               */
        B_LOOP='0'B;            /* Schleifenausgang mit Erfolg       */

          /* Startz„hler des jeweiligen BHKW erh”hen                 */
        Z_START(INDEX)=Z_START(INDEX)+1(31);

        /* wenn das erste BHKW eingeschaltet wird, dann Tein setzen  */
        IF Z_BANFORD==1 THEN
          Z_TEIN=ZF_TEIN;                      /* T ein starten      */
        FIN;

        Z_SVS(INDEX)=240;                   /* Startversuch anmelden   */
        Z_BPNL(INDEX)=0;           /* Pumpennachlauf beenden           */

        Z_LMIN=0;    /* Zaehler fuer Leistung minx zuruecksetzen     */
        Z_STKLEIN=0; /* Steigungszaehler zuruecksetzen               */
        Z_LMAX=0;    /* Zaehler fuer Leistung max zuruecksetzen      */
      ELSE
        INDEX=INDEX+1;
      FIN;
    ELSE
      INDEX=INDEX+1;
    FIN;

    IF INDEX > N_BHKW THEN
      INDEX=1;                  /* erste Durchlaeufe haben es nicht    */
      Z_BANFORD=Z_BANFORD+1;  /* gebracht, also nochmal              */
    FIN;

    IF Z_BANFORD > N_BHKW THEN
      B_LOOP='0'B;   /* Schleifenausstieg ohne Erlolg                */
             /* Steigungs- und Leistungszaehler nicht zuruecksetzen  */
      FOR I TO N_BHKW REPEAT            /* wenn keins mehr frei war  */
        IF B_BERLAUBT2(I) THEN
          B_BEIN(I)='1'B;               /*    dann alle anfordern    */
          IF Z_BTHERMVL(I) > 1 OR Z_BTHERMRL(I) > 1 THEN         
            Z_SVS(I)=150;               /* Startversuch anmelden   */
          FIN;
        FIN;
      END;
    FIN;

  END;               /* of REPEAT                                    */
END;                 /* of PROC SCH_BZU                              */

SCH_KZU: PROC;   /* einen Kessel zuschalten                          */

  DCL B_LOOP  BIT(1);
  DCL INDEX     FIXED;

  B_LOOP='1'B;
  INDEX=1;
  WHILE B_LOOP REPEAT  /* bis ein Kessel gefunden wurde              */

    /* ist die Rangfolge des aktuellen Kessels kleiner oder gleich   */
    /* der Anzahl der angeforderten Kessel + 1                       */
    IF FS_LKES(INDEX) <= Z_KANFORD+1 THEN

      /* wenn der Kessel noch nicht angefordert ist                  */
      IF NOT B_KEIN(INDEX) AND B_KERLAUBT(INDEX) THEN
        B_KEIN(INDEX)='1'B;        /* Ausgangsbit setzen               */
        Z_KSTART(INDEX)=Z_KSTART(INDEX)+1(31); /* Starts zaehlen         */
        B_KPMP(INDEX)='1'B;        /* Pumpe anfordern                  */
        Z_KANFORD=Z_KANFORD+1;   /* Anforderung erhoehen             */
        B_LOOP='0'B;             /* Schleifenausgang mit Erfolg      */
        Z_LKMAX=0;    /* Zaehler fuer Kesselleistung Max zuruecksetzen */
        Z_STKLEIN=0;  /* Zaehler fuer zu kleine Steigung zuruecksetzen */
      ELSE
        INDEX=INDEX+1;
      FIN;
    ELSE
      INDEX=INDEX+1;
    FIN;
    IF INDEX > N_KESSEL THEN

      B_LOOP='0'B;   /* Schleifenausstieg ohne Erlolg                */
             /* Steigungs- und Leistungszaehler nicht zuruecksetzen  */
      Z_KANFORD=N_KESSEL; /* wenn keiner mehr frei war, dann sind    */
                                             /* alle angefordert     */
    FIN;
  END;
END; /* of PROC SCH_KZU */

SCH_KAB: PROC; /* Kessel abschalten                                  */

  DCL B_LOOP  BIT(1);
  DCL INDEX     FIXED;

  B_LOOP='1'B;              /* erstmal auf 1 setzen                  */
  INDEX=N_KESSEL;             /* erstmal auf Anzahl der Kessel setzen  */

  WHILE B_LOOP REPEAT
    /* ist die Rangfolge des aktuellen Kessels gr”~er oder gleich    */
    /* der Anzahl der angeforderten Kessel                           */
 !  IF (FS_LKES(INDEX) >= Z_KANFORD OR B_SCHORNGES) AND Z_SCHORNK(INDEX)<10 THEN
    IF (FS_LKES(INDEX) >= Z_KANFORD OR B_SCHORNGES) AND Z_SCHORNK(INDEX)<10 AND INDEX < 3 THEN     /* <<<  Biogaskessel wird anders geschaltet */

      /* wenn der Kessel angefordert ist                             */
      IF B_KEIN(INDEX) THEN
        B_KEIN(INDEX)='0'B;       /* Kessel ausschalten                */
        Z_KANFORD=Z_KANFORD-1;  /* Anforderung zuruecknehmen         */
        B_LOOP='0'B;            /* Schleifenausstieg mit Erfolg      */
        Z_LRSPERR=ZF_LRSPERR;  /* Leistungsreglersperre aktivieren   */
        Z_STGROSS=0; /* Steigungszaehler zuruecksetzen               */
        IF NOT B_SB THEN   /* nur wenn auch BHKW nach Waermebedarf   */
          Z_LMAX=0;  /* BHKW-Leistungsmaxzaehler auf Null setzen     */
        FIN;
        Z_LKMAX=0;      /* Zaehler fuer Kesselleistungmax zuruecksetzen */
        Z_STKLEIN=0;   /* Zaehler fuer zu kleine Steigung zuruecksetzen */
      FIN;
    FIN;

    INDEX=INDEX-1;

    IF INDEX < 1 THEN
      B_LOOP='0'B;      /* Schleifenausstieg ohne Erfolg             */
      Z_KANFORD=0;      /* wenn sich kein Kessel mehr abschalten     */
                  /* laesst, dann ist auch keiner mehr eingeschaltet */
    FIN;
  END;
END;  /* of PROC SCH_KAB                                             */

SCH_BAB: PROC; /* ein BHKW abschalten                                */

  DCL B_LOOP  BIT(1);
  DCL INDEX     FIXED;

  B_LOOP='1'B;                /* erstmal auf 1 setzen                */
  INDEX=N_BHKW;                 /* erstmal auf Anzahl der BHKW setzen  */
  WHILE B_LOOP REPEAT

    /* ist die Rangfolge des aktuellen BHKWs gr”~er oder gleich      */
    /* der Anzahl der angeforderten BHKWs                            */
    IF (FS_LBHKW(INDEX) >= Z_BANFORD OR B_SCHORNGES) AND Z_SCHORNB(INDEX)<10 THEN

      /* wenn Modul nicht gest”rt und angefordert                    */
      IF NOT B_BSTOER(INDEX) AND B_BEIN(INDEX) AND B_BBEREIT(INDEX) THEN
        B_BEIN(INDEX)='0'B;            /* Modul ausschalten            */
        Z_BANFORD=Z_BANFORD-1;       /* Anforderung zuruecknehmen     */
        B_LOOP='0'B;                 /* Schleifenausstieg mit Erfolg */

        Z_LRSPERR=ZF_LRSPERR;   /* Leistungsreglersperre aktivieren        */

        Z_TMA=ZF_TMA;   /* Mindestauszeit setzen                     */

        Z_LMIN=0;    /* Leistungszaehler neu initialisieren           */
        Z_STGROSS=0; /* Steigungszaehler zuruecksetzen                 */
        Z_STKLEIN=0;   /* Zaehler fuer zu kleine Steigung zuruecksetzen */
      FIN;
    FIN;

    INDEX=INDEX-1;

    IF INDEX < 1 THEN
      INDEX=N_BHKW;             /* erste Durchlaeufe haben es nicht     */
      Z_BANFORD=Z_BANFORD-1;  /* gebracht, also nochmal              */
    FIN;

    IF Z_BANFORD < 1 THEN
      B_LOOP='0'B;
    FIN;

  END;
END; /* of PROC SCH_BAB                                              */

/*********************************************************************/
/* Berechnung einer eindeutigen Tagesnummer:                         */
/*********************************************************************/
TAGESNR: PROC ((DAY,MONTH,YEAR) FIXED) RETURNS (FIXED) GLOBAL;
  /* Diese Funktion errechnet eine fortlaufende Tagesnummer.         */
  /* Rein: Tagesdatum, Monat, Jahr. Raus: Fortlaufende Tagesnummer   */
  IF MONTH>2 THEN
    RETURN(365*YEAR+DAY+31*(MONTH-1)-ENTIER(.4*MONTH+2.3)+ENTIER(YEAR*.25)-
           ENTIER(.75*(ENTIER(YEAR*.01)+1))                    );
  ELSE
    RETURN(365*YEAR+DAY+31*(MONTH-1)+ENTIER((YEAR-1)*.25)-
           ENTIER(.75*(ENTIER(1+(YEAR-1)*.01)))   );
  FIN;
END; /* of PROC TAGESNR */

/*********************************************************************/
/* Prozedur fr die W„rmemengenz„hlung                               */
/*********************************************************************/
WAEZAEHL: PROC ((DI,HK,AI1,AI2,AIZ) FIXED) GLOBAL;

  DCL F_31  FIXED(31);
  DCL CWA   FLOAT;

  P_DI(DI)=3600.0/FL_IMPDAU(DI)/FL_IMP(DI); 
  CWA=1.1705-X_AEIN(AIZ)*0.0005;
  TD_INTHK(HK)=TD_INTHK(HK)+X_AEIN(AI1)-X_AEIN(AI2);
  Z_IMPWART(DI)=Z_IMPWART(DI)+1(31);
  DF_HKTH(HK)=(3600.0/FL_IMPDAU(DI))/FL_IMP(DI);
  P_HKTH(HK) =CWA*DF_HKTH(HK)*(TD_INTHK(HK)/Z_IMPWART(DI));
  IF Z_ZAEHLMERK(DI) < Z_ZAEHL(DI) THEN                            
    F_31=Z_ZAEHL(DI)-Z_ZAEHLMERK(DI);                      
    Z_ZAEHLMERK(DI)=Z_ZAEHLMERK(DI)+F_31;              
    Z_IMPDIVIERT(DI,Z_MINVIERT)=(Z_IMPDIVIERT(DI,Z_MINVIERT)+F_31) FIT Z_IMPDIVIERT(DI,Z_MINVIERT); /*   */
    IF TD_INTHK(HK) > 0.0 THEN
      W_HKTH(HK)=W_HKTH(HK)+CWA*0.5(55)/FL_IMP(DI)
                     *(TD_INTHK(HK)/Z_IMPWART(DI))*F_31;
      FL_THVIERT(HK,Z_MINVIERT)=FL_THVIERT(HK,Z_MINVIERT)+CWA*0.5/FL_IMP(DI)
                                *(TD_INTHK(HK)/Z_IMPWART(DI))*F_31;
    FIN;
    TD_INTHK(HK)=0.0;
    Z_IMPWART(DI)=0(31);
  FIN;
  
END; /* of PROC WAEZAEHL */

/*********************************************************************/
/* Begrenzung einer FIXED Variablen                                  */
/*********************************************************************/
FIXGRENZ: PROC ((MAX,MIN) FIXED, WERT FIXED IDENT) GLOBAL;

  IF WERT>MAX THEN WERT=MAX; FIN; /* Wert im zul{ssigen Intervall ?  */
  IF WERT<MIN THEN WERT=MIN; FIN;

END; 

/*********************************************************************/
/* Begrenzung einer FLOAT Variablen                                  */
/*********************************************************************/
FLOGRENZ: PROC ((MAX,MIN) FLOAT, WERT FLOAT IDENT) GLOBAL;

  IF WERT>MAX THEN WERT=MAX; FIN; /* Wert im zul{ssigen Intervall ?  */
  IF WERT<MIN THEN WERT=MIN; FIN;

END; 

/*********************************************************************/
/* Errechnung von Datum, Uhrzeit aus Fixed(31) - Variable            */
/*********************************************************************/
DATETIME: PROC ( F31 FIXED(31), (DAT,MON,STD,MIN,SEK) FIXED IDENT) GLOBAL;
  DCL F311 FIXED(31);
  DCL F312 FIXED(31);

  F311=F31;
  F312=F311//864000(31)+1;  /* x-ter Tag des Jahres */
  MON=1;
  FOR K TO 12 REPEAT
    IF F312>28(31) AND MON==2 AND (DA_JAH REM 4)/=0 THEN
      MON=MON+1;
      F312=F312-28(31);
    FIN;
    IF F312>29(31) AND MON==2 AND (DA_JAH REM 4)==0 THEN
      MON=MON+1;
      F312=F312-29(31);
    FIN;
    IF F312>30(31) AND (MON==4 OR MON==6 OR MON==9 OR MON==11) THEN
      MON=MON+1;
      F312=F312-30(31);
    FIN;
    IF F312>31(31) AND (MON==1 OR MON==3 OR MON==5 OR MON==7 OR MON==8 OR MON==10 OR MON==12) THEN
      MON=MON+1;
      F312=F312-31(31);
    FIN;
  END;
  DAT=F312 FIT DAT;

  IF F31 < 1(31) THEN
    DAT=0;
    MON=0;
  FIN;

  F312=F311 REM 864000(31);  /* Zehntelsekunden des Tages */
  STD=(F312//36000(31)) FIT STD;
  F312=F312-STD*36000(31);
  MIN=(F312//600(31)) FIT MIN;
  F312=F312-MIN*600(31);
  SEK=(F312//10(31)) FIT SEK;

END; 

/*********************************************************************/
/* Behandlung Monatszaehler                                          */
/*********************************************************************/
MONZAEHL: PROC ( IND FIXED, ZAEHL FLOAT(55), TIME FIXED(31)) GLOBAL;
  DCL FL1 FLOAT;

  FL1=ZAEHL FIT FL1;
  IF TIME > ZT_JAHR - 12000(31) THEN  /* Zeitstempel juenger als 20MIN */
    MON_ZAEHL(IND,DA_MON)=FL1;
    JAHR_ZAEHL(IND,8)=FL1;            /* letzter intakter Wert (z.B. fuer MODBUS)     */
    JAHR_ZAEHL(IND,7)=FL1;            /* Wert fuer andere Zwecke (mit Erkennung -111) */
  ELSE
    JAHR_ZAEHL(IND,7)= -111.0;        /* Wert fuer andere Zwecke (mit Erkennung -111) */
  FIN;

END; 


TESTTIMER: TASK PRIO 20;

  PUT TO TERM BY SKIP;
  FOR K TO 1008 REPEAT
    IF K < 1000 AND K > 8 THEN 
      IF NOT B_ZONE1(3,K).BIT(8) THEN /* <<< Kontrolle Timer BHKW */
        PUT '0' TO TERM BY A;
      ELSE
        PUT '1' TO TERM BY A;
      FIN;
    FIN;
  END;

END;


WEB2: TASK PRIO 10;   /* zum testen */

  B32='ABCD5678'B4; 
  FLANTWORT1=2.3;
  FLANTWORT2=3.4;
  FL55ANTWORT=4.5(55);
  F31ANTWORT1=10(31);
  F31ANTWORT2=20(31);
  F31ANTWORT3=30(31);
  CHANTWORT1='ABCDEFGHIJKLMNOPQRST';
  CHANTWORT2='12345678901234567890';
  CHANTWORT3='abcdefghijklmnopqrst12345678901234567890abcdefghijklmnopqrst12345678901234567890';
  DISPSTATUS.BIT(1)='1'B; 
  DISPSTATUS.BIT(32)='1'B; 
  XROT=21; 
  YROT=8; 
  ZROT=4; 

  BZEIL='00000000'B4;
  FOR I TO 18 REPEAT
    ZEIL(I)='1234567890123456789012345678901234567890abcdef';
    IF I==8 THEN
      ZEIL(I-1)='abcdefghijkl* opqrstuvwxy*1234567890ABCDEabcdef';
      ZEIL(I)='abcdefghijkl  opqrstuvwxy 1234567890ABCDEabcdef';
    FIN;
    BZEIL.BIT(I)='1'B;
  END;

  FOR I TO 25 REPEAT
    ZEIL80(I)='1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij';
    IF I==8 THEN
      ZEIL80(I)='1234567890  CDEF    1234567890ABC     ij1234567890 bcdefghi 1234567890 bcdefghij';
    FIN;
    BZEIL.BIT(I)='1'B;
  END;

  FOR I TO 20 REPEAT
    ZEILVIS(I)=  '123456789012345678901234567890123456789012345678901234567890';
    IF I==8 THEN
      ZEILVIS(I)='abcdefghijkl  opqrstuvwxy 1234567890ABCD12345678901234567890';
    FIN;
  END;

  FOR I TO 20 REPEAT
    ZEILRUECK(I)='abcdefghijklmnopqrst12345678901234567890a1234567890123456789';
    IF I==8 THEN
      ZEILRUECK(I)='CDEF    1234567890ABC     ij1234567890   1234567890123456789';
    FIN;
  END;

  FTAST=10;

END;


WEB3: TASK PRIO 10;      /* zum testen */
  DCL F15     FIXED;

  PUT TO A1 BY SKIP; 
  FOR I TO 18 REPEAT
    PUT ZEIL(I) TO A1 BY A,SKIP;
  END;
  PUT XROT,YROT,ZROT TO A1 BY F(5),F(3),F(3),SKIP; 
  FOR I TO 16 REPEAT
    FOR K TO 23 REPEAT
      F15=TOFIXED(ZEIL(I).CHAR(K));
      PUT F15 TO A1 BY F(4);
    END;
    PUT TO A1 BY SKIP; 
    FOR K TO 23 REPEAT
      F15=TOFIXED(ZEIL(I).CHAR(K+23));
      PUT F15 TO A1 BY F(4);
    END;
    PUT TO A1 BY SKIP; 
  END;
  PUT TO A1 BY SKIP; 

END;

/*+L*/

MODEND;













