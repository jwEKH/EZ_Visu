/*********************************************************************/
/*        Heizungssteuerungsmodul         Ersterstellung:   13.07.22 */
/* BEDIEN: Benutzerfuehrung und Anzeigesystem  'BIOGASANLAGE DRALLE  HOHNE  */
/* Stand: 13.07.22                                                   */
/* Auf jeden Fall kontollieren ob Anpassungen noetig:  "<<<<"        */
/* Sonstige Besonderheiten:   "<<<"                                  */
/*********************************************************************/

P=MPC604+FPU(4);

/*SC=90000 ,CODE=$0000 ,VAR=$0000; /**/
  SC=70000;  /* */

MODULE BEDIEN;

/* Compileroptionen einstellen: */;
/*-L Listing PEARL-Compiler     */;
/*+B Big Module                 */;
/*+M Markierung Zeilennummer    */;
/*+T Test auf Feldgrenzen       */;
/*-P Protokoll Hyperproc Code   */;

SYSTEM;
/* BEDIEN kennt keine Hardware !                                     */

PROBLEM;
  /* benutzte Hardware aus anderen Modulen                           */
  SPC LCD    DATION   OUT ALPHIC CONTROL(ALL) GLOBAL; /* LC-Display  */
  SPC RTOS   DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* Bedieninterf*/
  SPC A1     DATION   OUT ALPHIC CONTROL(ALL) GLOBAL;
  SPC BTASTIN   DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* Eingabe Tastatur   */
  SPC MONLES DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* Hilfsdatei Langzeitprotokoll */
  SPC TEMP   DATION INOUT ALPHIC CONTROL(ALL) GLOBAL; /* temporaere Datei auf Ramdisk  */

  /* Tasks aus anderen Modulen */
  SPC RAUMABS    TASK GLOBAL; /* Timertask                           */
  SPC RAMSCHREIB TASK GLOBAL; /* Parametersicherung auf H0.          */
  SPC SYSTAKT    TASK GLOBAL; /* Hauptregelungstask (jede SEC)       */
  SPC HKABS      TASK GLOBAL; /* Heizkreisabsenkungstask             */
  SPC WATCHDOG   TASK GLOBAL; /* Aufpassertask                       */
  SPC LICHTAUS   TASK GLOBAL; /* Ausschalten der LCD-Beleuchtung     */
  SPC GFSCALE    TASK GLOBAL; /* Grundfosskalierungsfaktoren lesen  <<< nur vorhanden wenn Modul grundfos.psr mitgelinkt */
  SPC GRUNDFOS   TASK GLOBAL; /* Grundfos-Pumpenkommunikation       <<< nur vorhanden wenn Modul grundfos.psr mitgelinkt */
  SPC MBUSOUT    TASK GLOBAL; /* Anzeige MBUS-Busdaten Send/Empf    <<< nur vorhanden wenn Modul mbus.psr mitgelinkt */
  SPC MBUSOUT2   TASK GLOBAL; /* Anzeige MBUS-Busdaten Empf 255Byte <<< nur vorhanden wenn Modul mbus.psr mitgelinkt */
  SPC MBUSANZOUT TASK GLOBAL; /* Anzeige MBUS Werte (Wth, Pth,...)  <<< nur vorhanden wenn Modul mbus.psr mitgelinkt */
  SPC MODBUSOUT  TASK GLOBAL; /* Anzeige Modbus                     <<< nur vorhanden wenn Modul modbus.psr mitgelinkt */
  SPC FLAMOUT    TASK GLOBAL; /* Anzeige Busdaten FLAMCO            <<< nur vorhanden wenn Modul flamco.psr mitgelinkt */
  SPC FLAMANZOUT TASK GLOBAL; /* Anzeige Werte FLAMCO               <<< nur vorhanden wenn Modul flamco.psr mitgelinkt */

  /* Tasks aus BEDIEN          */
  SPC I_DISP       TASK; /* Initialisiert Anzeige                    */
  SPC DISPLAY      TASK; /* stellt Anzeigeseiten dar                 */
  SPC MENU         TASK; /* betreut Tastatur und Menue               */
  SPC STOEROUT     TASK; /* Anzeige akt. anstehender Stoerungen      */
  SPC STOERFREIOUT TASK; /* Anzeige fuer Stoerungsfreigabe           */
  SPC ANAINOUT     TASK; /* Darstellung Analogeingaenge              */
  SPC ANALOUT      TASK; /* Darstellung Analogausgaenge              */
  SPC PWMOUT       TASK; /* Darstellung PWM-Ausgaenge                */
  SPC DIGITALOUT   TASK; /* Darstellung Digitalausgaenge             */
  SPC DIGINOUT     TASK; /* Darstellung Digitaleingaenge             */
  SPC PKESOUT      TASK; /* Anzeigetask Kesselleistungsregelung      */
  SPC PKESOUT1     TASK; /* Anzeigetask Kesselleistungsregelung      */
  SPC PKESOUT2     TASK; /* Anzeigetask Kesselleistungsregelung      */
  SPC PMPKESOUT    TASK; /* Anzeigetask Kesselpumpenregelung         */
  SPC BHKWPROT     TASK; /* Anzeige Betriebsprotokoll BHKW Merlin    */
  SPC ZEIGB        TASK; /* Anzeige CAN-Kommunikation BHKW           */
  SPC HKKURVEOUT   TASK; /* Anzeige Heizkurveneinstellung            */
  SPC HKREGOUT     TASK; /* Anzeige Heizkreispumpenregelung          */
  SPC HKMIOUT      TASK; /* Anzeige Heizkreismischerregelung         */
  SPC HKMIOUT2     TASK; /* Anzeige Heizkreismischerregelung         */
  SPC ESTRICHOUT   TASK; /* Anzeige Estrichtrocknung                 */
  SPC WWSOLLOUT    TASK; /* Anzeige WW-Ladung (innen/aussen WT)      */
  SPC WWSOLLOUT2   TASK; /* Anzeige WW-Ladung (FWS)                  */
  SPC WWREGOUT     TASK; /* Anzeige Regelung WW (aussen WT)          */
  SPC WWREGOUT2    TASK; /* Anzeige Regelung WW (FWS)                */
  SPC WWZIRKOUT    TASK; /* Anzeige Regelung Zirkulation             */
  SPC UPEOUT       TASK; /* Anzeige Bedienung Grundfos-Pumpen        */
  SPC UPEOUT2      TASK; /* Anzeige Busdaten Grundfospumpen          */
  SPC HZGSPEIOUT   TASK; /* Anzeige Heizungnachspeisung              */
  SPC OUT_FUEHLER  TASK; /* Anzeige Fuehlerabgleich                  */
  SPC STROMOUT     TASK; /* Anzeige Strommenue                       */
  SPC SCHORNOUT    TASK; /* Anzeige Schornsteinfegermenue            */
  SPC JAHROUT      TASK; /* Anzeige Jahreskalender                   */
  SPC WOCHOUT      TASK; /* Anzeige Wochenkalender                   */
  SPC MONZAEHLOUT  TASK; /* Anzeige Monatszaehler                    */

/* externe Prozeduren */
  SPC D_RON     ENTRY GLOBAL; /* Rotschrift an                       */
  SPC D_ROFF    ENTRY GLOBAL; /* Rotschrift aus                      */
  SPC D_CS      ENTRY (FIXED, FIXED) GLOBAL; /* Cursor auf Position x,y   */
  SPC D_CLR     ENTRY GLOBAL; /* loescht LCD                         */
  SPC D_GRAPHCLR ENTRY GLOBAL; /* loescht Graphic                    */
  SPC STICK     ENTRY GLOBAL; /* wartet bis Eingabe erfolgt          */
  SPC RTC_SETZE ENTRY (FIXED, FIXED, FIXED, FIXED, FIXED) GLOBAL;  /* RTC stellen  */
  SPC RTC_DATUM  ENTRY GLOBAL;/* Datum aus Echtzeituhr lesen         */
  SPC BHKWBEDIEN   ENTRY GLOBAL; /* Bedienung der BHKW-Funktionen    */
  SPC SYSTEMOUT    ENTRY (FIXED) GLOBAL; /* Organisation der Systemmeldungen */
  SPC FIXGRENZ     ENTRY (FIXED, FIXED, FIXED IDENT) GLOBAL; /* Fixwert begrenzen      */
  SPC FLOGRENZ     ENTRY (FLOAT, FLOAT, FLOAT IDENT) GLOBAL; /* Floatwert begrenzen    */
! SPC CANINIT      ENTRY GLOBAL ; /* CAN-Bus initialisieren */
  SPC MBUSBUS      ENTRY GLOBAL; /* M-Bus Busdatendarstellung        */
  SPC MBUSANZ      ENTRY GLOBAL; /* M-Bus Wertedarstellung           */
  SPC FLAMBUS      ENTRY GLOBAL; /* FLAMCO Busdatendarstellung        */
  SPC FLAMANZ      ENTRY GLOBAL; /* FLAMCO Wertedarstellung           */
  SPC DATETIME     ENTRY (FIXED(31), FIXED IDENT, FIXED IDENT, FIXED IDENT, FIXED IDENT, FIXED IDENT) GLOBAL;
  SPC GF_PUT       ENTRY GLOBAL; /* GeniBus Testeingabe       */
  SPC MB_PUT       ENTRY GLOBAL; /* MBus Testeingabe       */
  SPC TASKST   ENTRY (CHAR(24)) RETURNS (BIT(32)) GLOBAL; /* Status? */
  SPC CMD_EXW  ENTRY (CHAR(255)) RETURNS (BIT( 1)) GLOBAL; /* Bedieni.*/
  SPC SENDCANFIXED ENTRY (FIXED, FIXED, FIXED, FIXED, FIXED, FIXED, FIXED, FIXED) GLOBAL;

/* interne Prozeduren */
  SPC I_MENU      ENTRY; /* Initialisierung des Menus                */
  SPC SET_MENU    ENTRY (FIXED, FIXED, CHAR(30)); /* Setze Menue-Eintrag (Aufruf durch I_MENU) */
  SPC EINGABE     ENTRY; /* Eingabe der Werte (called by MENU)       */
  SPC ANZ_AUS     ENTRY; /* Abschalten einiger Anzeigefunktionen     */
  SPC QUITTIER    ENTRY (FIXED); /* Anzeigen und Quittieren von Stoerungen */
  SPC STOERFREI   ENTRY; /* Freigabe der Stoerungsmeldungen           */
  SPC STOERZEIG3  ENTRY; /* Langzeitmeldeprotokoll                   */
  SPC ANAINRAUS   ENTRY; /* Darstellung der Analogeingaenge          */
  SPC ANALOGRAUS  ENTRY; /* Bedienung der Analogausgaenge          */
  SPC DIGITALRAUS ENTRY; /* Bedienung der Digitalausgaenge         */
  SPC PWMRAUS     ENTRY; /* Bedienung der PWM-Ausgaenge             */
  SPC DIGINRAUS   ENTRY; /* Bedienung der Digitaleingaenge          */
  SPC INP_PKES    ENTRY; /* Leistungsregelung Kessel                 */
  SPC INP_PKES1   ENTRY; /* Leistungsregelung Kessel                 */
  SPC INP_PKES2   ENTRY; /* Leistungsregelung Kessel                 */
  SPC INP_PMPKES  ENTRY; /* Pumpenregelung Kessel                 */
  SPC INP_KESPAR  ENTRY; /* Kesselparameter                       */
  SPC BHKWBEDIENC ENTRY; /* Fernbediennung der BHKWs ber CAN        */
  SPC BHKWBEDIENC2 ENTRY; /* Fernbediennung Unterstationen            */
  SPC INP_BHKWPAR ENTRY; /* BHKW-Parameter                       */
  SPC INP_HKKURVE ENTRY; /* Heizkurven eingeben                      */
  SPC HKZON       ENTRY; /* Heizkreis-Wochenkalender                 */
  SPC INP_JAHR    ENTRY; /* Heizkreis-Jahreskalender               */
  SPC INP_JAHR2   ENTRY; /* Jahreskalender HZG AUS bei AT < 5      */
  SPC INP_HKREG   ENTRY; /* Heizkreispumpenregelung                  */
  SPC INP_HKMI    ENTRY; /* Heizkreismischerregelung                  */
  SPC INP_HKMI2   ENTRY; /* Heizkreismischerregelung                  */
  SPC INP_HKPAR   ENTRY; /* Heizkreisparameter                      */
  SPC ESTRICHTROCK ENTRY; /* Estrichtrocknung                        */
  SPC INP_WWSOLL  ENTRY; /* WW-Solltemperaturen (innen/aussen WT)   */
  SPC INP_WWSOLL2 ENTRY; /* WW-Solltemperaturen (FWS)               */
  SPC WWZON       ENTRY; /* WW-Wochenkalender                       */
  SPC WWZON2      ENTRY; /* WW-Desinfektion-Wochenkalender          */
  SPC INP_WWREG   ENTRY; /* WW-Regelung (innen/aussen WT)           */
  SPC INP_WWREG2  ENTRY; /* WW-Regelung (FWS)                       */
  SPC INP_WWZIRK  ENTRY; /* WW-Zirkulation-Regelung                 */
  SPC ZAEHL_ANZEIG ENTRY; /* Zaehlerstaende anzeigen und korr. */
  SPC WTH_ANZEIG  ENTRY; /* Waermemengenzaehler (Soft)               */
  SPC WEL_ANZEIG  ENTRY; /* Strombilanzen                            */
  SPC MONZAEHL_ZEIG ENTRY; /* aktuelle Zaehlerstaende                  */
  SPC MON_ZEIG    ENTRY; /* Monatszaehlerstaende                    */
  SPC JAHR_ZEIG   ENTRY; /* Jahreszaehlerstaende                    */
  SPC SONST_ANZEIG ENTRY; /* Sonstige Zaehler                        */
  SPC UPE_BEDIEN  ENTRY; /* Bedienung Grundfos-Pumpen               */
  SPC UPE_SCAL    ENTRY; /* Skalierungsfaktoren Grundfos            */
  SPC UPE_SCAL2   ENTRY; /* Kennlinien Grundfos  % -> Stufe         */
  SPC UPE_BUS     ENTRY; /* Beobachtung UPE-Bus                      */
  SPC INP_HZGSPEIS ENTRY; /* Heizungsnachspeisung                   */   
  SPC INP_NUTZ    ENTRY; /* Nutzungsdauer Heizung eingeben           */
  SPC INP_FUEHLER ENTRY; /* Abgleich Analogeingaenge                 */
  SPC INP_ANAL    ENTRY; /* Abgleich Analogausgaenge                 */
  SPC ZAEHL_ABGL  ENTRY; /* Impulszaehler abgleichen                */
  SPC INP_RTC     ENTRY; /* Uhrzeit / Datum stellen                 */
  SPC INP_ROTSP   ENTRY; /* Zustand Eingabetaste                    */
  SPC RESETINFO   ENTRY; /* Infoseite fuer Resetzeitpunkt, -datum etc.*/
  SPC INP_SCHORN  ENTRY; /* Schornsteinfegermenue                     */   
  SPC INP_BAD     ENTRY; /* Baedertemperaturen                        */   
  SPC INP_FUEHR   ENTRY (FIXED, FIXED, RANG() FIXED IDENT); /* Rangfolgen    */
  SPC ZEITBHKW    ENTRY (FIXED); /* Darstellung BHKW-Laufzeiten              */
  SPC ZEITKESSEL  ENTRY (FIXED); /* Darstellung Kessel-Laufzeiten            */
  SPC NEUSTART    ENTRY; /* Reset ausloesen                          */
  SPC INP_ABS     ENTRY (FIXED, FIXED);  /* Wochenkalender                   */
  SPC BEDIENUST   ENTRY; /* Fernbediennung von Unterstationen       */
  SPC ONLINE      ENTRY (CHAR(12)); /* Prozedur: CALL STICK mit Taskaktivierung */
  SPC INP_CHAR    ENTRY (FIXED, FIXED, CHAR(1) IDENT, CHAR(12), FIXED IDENT); /* Zeichen eingeben   */
  SPC INP_BIT     ENTRY (FIXED, FIXED, CHAR(6), CHAR(6), BIT(1) IDENT, CHAR(12)); /* Bit-variable eingeben                    */
  SPC INP_FLO     ENTRY (FIXED, FIXED, FIXED, FIXED, FLOAT, FLOAT, FLOAT, FLOAT IDENT, CHAR(12)); /* FLOAT-Wert eingeben: (X,Y,ST,NK,wert)    */
  SPC INP_FIX     ENTRY (FIXED, FIXED, FIXED, FIXED, FIXED, FIXED, FIXED IDENT, CHAR(12));  /* FIXED-Wert eingeben: (X,Y,ST,wert)       */
  SPC INP_F55     ENTRY (FIXED, FIXED, FIXED, FIXED, FLOAT(55), FLOAT(55), FLOAT(55), FLOAT(55) IDENT, CHAR(12)); /* FLOAT55-Wert eingeben: (X,Y,ST,NK,wert)  */
  SPC INP_CLO     ENTRY (FIXED, FIXED, FIXED, CLOCK IDENT, CHAR(12));  /* Zeitpunkt  eingeben: (X,Y,Genauigkeit,wert)          */
  SPC INP_BETRIEB ENTRY (FIXED, FIXED, NAME1() CHAR(30) IDENT, FIXED, FIXED IDENT, CHAR(12)); /* Auswahl eingeben              */
  SPC LRROT       ENTRY (FIXED IDENT);  /* Tastatur fuer INP_ Routinen auswerten */
  SPC ROUNDLG     ENTRY (FLOAT(55)) RETURNS(FIXED(31)); /* runden von Gleitkommazahlen > 32768 */
  SPC OBJAUSWAHL  ENTRY (CHAR(40),FIXED, NAME() CHAR(30) IDENT, CHAR(12)); /* Auswahl Objekte ueber Tasten oder Button   */
  SPC INP_EXTHK   ENTRY; /* ext. Einfluesse                       */
  SPC INP_EXTKES  ENTRY; /* ext. Einfluesse                       */
  SPC INP_EXTBHKW ENTRY; /* ext. Einfluesse                       */
  SPC INP_STROM   ENTRY; /* Strommenue                            */
  SPC INP_CANTEST ENTRY; /* CANTEST                            */
   
  DCL X_H           FIXED; /* Hilfsvariable                  */
  DCL B_LOOPB      BIT(1); /* Hilfsvariable                  */
  DCL (M,N,O,P)     FIXED; /* Arbeitsvariablen fuer EINGABE  */
  DCL X_D           FLOAT; /* Hilfsvariable                  */
  DCL (X_POS,Y_POS) FIXED; /* Positionsvariablen             */
  DCL ZP_HILF       CLOCK; /* Hilfsvariable                  */
  DCL INDMERK       FIXED; /* Hilfsvariable                  */
  DCL KOMMANDO   CHAR(80); /* Hilfsvariable                  */
  DCL Z_USEITE2MAX  FIXED; /* Hilfsvariable                  */

/*-------------------------------------------------------------------*/
#INCLUDE c:\p907\033bgadrallehohne\spc.p;




/*********************************************************************/
/* Initialisierung des Menuebaums:                                    */
/*********************************************************************/
I_DISP: TASK PRIO 15;

  BUTT=TOCHAR(127);
  X_ZUGANGKAL=1;  /* Aufruf Hauptmenue */

  PUNKT=1; ZEIG=1; /* Menuezeiger vorbesetzen                         */

  IF Z_LZ < 20(31) THEN
    CALL I_MENU;    /* Menuebaum aufbauen                             */
  FIN;

  ACTIVATE MENU;  /* Menue starten                                    */

! CALL LICHTAN;  
! AFTER 5 MIN ACTIVATE LICHTAUS;
  B_KEY='0'B;
  
  /*-----------------------------------------------------------------*/
  /* Ueberwachung von Display und Menue, automatische Umschaltung    */
  Z_WAIT=17500;
  B_MENU='1'B;
  /* nach 10 Sec Umschaltung auf Displaymode, Seitenschaltung:       */
  REPEAT
    IF Z_WAIT<18000 AND B_MENU THEN
      IF B_KEY THEN /* Ist eine gueltige Taste betaetigt worden ?    */
        Z_WAIT=0;        /* Zaehler zuruecksetzen, Taste quittieren  */
        B_KEY='0'B;
      ELSE
        Z_WAIT=Z_WAIT+1;        /* Zaehler erhoehen                  */
      FIN;
    ELSE

      IF B_MENU THEN    /* Wartezeit ueberschritten, Menue killen:   */
        B_MENU='0'B;    /* Jetzt ist der Displaymodus aktiv:         */
        CALL ANZ_AUS;   /* einige Anzeigefunktionen abschalten       */
        TERMINATE MENU; 
        AFTER 0.2 SEC RESUME;
      FIN;
      Z_SEITE=1; 
      Z_USEITE=1;
      Z_USEITE2=1;
      CALL D_CLR;

      WHILE NOT B_MENU REPEAT; /* solange der Displaymodus aktiv ist:*/
        /* Neu einplanen, damit Seite sofort dargestellt wird:       */
        IF (B_FERN OR B_PANEL) THEN
          AFTER 1.0 SEC ALL 2.1 SEC ACTIVATE DISPLAY;
        ELSE
          ALL 2.1 SEC ACTIVATE DISPLAY;
        FIN;
        B_NEUSEITE='1'B;     /* Darstellung der neuen Seite anfordern*/
        AFTER 0.2 SEC RESUME;/* auf Darstellung warten               */
        CALL STICK;          /* und auf Benutzer warten              */
        Z_WAIT=0;
        IF X_R > 1000 THEN  /* Button geklickt */
          B_MENU='1'B;
        ELSE
          CASE X_R
            ALT /* Hebel nach oben:                                    */
              IF Z_SEITE>1 THEN
                Z_SEITE =Z_SEITE-1;
              ELSE
                IF Z_USEITE2 > 1 THEN
                  Z_USEITE2=Z_USEITE2-1;
                ELSE
                  B_MENU='1'B; /* Menuemodus einschalten                 */
                FIN;
              FIN;
            ALT /* Hebel nach unten:                                   */
              IF Z_USEITE > 1 THEN
                Z_USEITE2=Z_USEITE2+1;
                IF Z_USEITE2 > Z_USEITE2MAX THEN
                  Z_SEITE=Z_SEITE+1; 
                  Z_USEITE=1;
                  Z_USEITE2=1;
                FIN;                  
              ELSE
                IF Z_SEITE<N_SEITE THEN
                  Z_SEITE=Z_SEITE+1; 
                  Z_USEITE=1;
                  Z_USEITE2=1;
                FIN;
              FIN;
            ALT /* Hebel nach links:                                   */
              IF Z_USEITE>1 THEN
                Z_USEITE=Z_USEITE-1;
                Z_USEITE2=1;
              ELSE
                B_MENU='1'B; /* Menuemodus einschalten                 */
              FIN;
            ALT /* Hebel nach rechts:  ( nur auf Seite 1 )             */
         !    IF Z_USEITE < N_USEITE AND Z_SEITE==1 THEN
              IF Z_USEITE < N_USEITE THEN
                Z_SEITE=1;
                Z_USEITE=Z_USEITE+1;
                Z_USEITE2=1;
              FIN;
            OUT /* Rot betaetigt                                       */
              B_MENU='1'B; /* Menuemodus einschalten                   */
          FIN;
        FIN;
      END;
      PREVENT DISPLAY;   /* Display ausplanen                        */
      TERMINATE DISPLAY; /* Display beenden                          */
      Z_WAIT=0;
      ACTIVATE MENU;
    FIN;
    AFTER 0.2 SEC RESUME;
  END;
END; /* of TASK IDISP */


/********* alle Laufzeitprotokolle <<<< *********/
DISPLFZ: PROC;
  
  Z_USEITE2MAX=11;
  IF Z_USEITE2 > Z_USEITE2MAX THEN  Z_USEITE2=Z_USEITE2MAX;  FIN;

  CASE Z_USEITE2
    ALT  /*  1 */
      CALL D_CS(21,1); PUT ' Laufzeitp. BHKW     ' TO LCD BY A;
  !   CALL D_CS(21,2); PUT ' Neuanford.:',Z_START(1) TO LCD BY A,F(6);
      CALL D_CS(21,4); PUT ' Laufz.    ZPaus     '   TO LCD BY A;
      CALL ZEITBHKW(1);
    ALT  /*  2 */
      CALL D_CS(21,1); PUT ' Anforderungszeiten  ' TO LCD BY A;
      CALL D_CS(21,2); PUT '    Holzkessel1      ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Anfdau    Anf - Ende'   TO LCD BY A;
      CALL ZEITKESSEL(1);
    ALT  /*  3 */
      CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
      CALL D_CS(21,2); PUT '    Holzkessel1      ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
      CALL ZEITBHKW( 9);
    ALT  /*  4 */
      CALL D_CS(21,1); PUT ' Anforderungszeiten  ' TO LCD BY A;
      CALL D_CS(21,2); PUT '    Holzkessel2      ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Anfdau    Anf - Ende'   TO LCD BY A;
      CALL ZEITKESSEL(2);
    ALT  /*  5 */
      CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
      CALL D_CS(21,2); PUT '    Holzkessel2      ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
      CALL ZEITBHKW(10);
    ALT  /*  6 */
      CALL D_CS(21,1); PUT ' Anforderungszeiten  ' TO LCD BY A;
      CALL D_CS(21,2); PUT '    Biogaskessel     ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Anfdau    Anf - Ende'   TO LCD BY A;
      CALL ZEITKESSEL(3);
    ALT  /*  7 */
      CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
      CALL D_CS(21,2); PUT '    Biogaskessel     ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
      CALL ZEITBHKW(11);
    ALT  /*  8 */
      CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
      CALL D_CS(21,2); PUT '   Freigabe Fackel   ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
      CALL ZEITBHKW(12);
    ALT  /*  9 */
      CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
      CALL D_CS(21,2); PUT '    Trocknung        ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
      CALL ZEITBHKW(13);
    ALT  /* 10 */
      CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
      CALL D_CS(21,2); PUT '   Stocker Holzk1    ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
      CALL ZEITBHKW(14);
    ALT  /* 11 */
      CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
      CALL D_CS(21,2); PUT '   Stocker Holzk2    ' TO LCD BY A;
      CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
      CALL ZEITBHKW(15);
   
      CALL D_CS(38,16); PUT '---' TO LCD BY A;  /* Endeerkennung letzes Laufz-Prot */

  ! ALT  /*  2 */
  !   CALL D_CS(21,1); PUT ' Laufzeitp. BHKW 2  ' TO LCD BY A;
  !   CALL D_CS(21,2); PUT ' Neuanford.:',Z_START(2) TO LCD BY A,F(6);
  !   CALL D_CS(21,4); PUT ' Laufz.      ZPaus  '   TO LCD BY A;
  !   CALL ZEITBHKW(2);
  ! ALT  /*  6 */
  !   CALL D_CS(21,1); PUT ' Anforderungszeiten  ' TO LCD BY A;
  !   CALL D_CS(21,2); PUT '     Kessel2         ' TO LCD BY A;
  !   CALL D_CS(21,4); PUT ' Anfdau    Anf - Ende'   TO LCD BY A;
  !   CALL ZEITKESSEL(2);
  ! ALT  /*  7 */
  !   CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
  !   CALL D_CS(21,2); PUT '     Kessel2         ' TO LCD BY A;
  !   CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
  !   CALL ZEITBHKW(10);
  ! ALT  /*  3 */
  !   CALL D_CS(21,1); PUT ' Laufzeitp. BHKW 3  ' TO LCD BY A;
  !   CALL D_CS(21,2); PUT ' Neuanford.:',Z_START(3) TO LCD BY A,F(6);
  !   CALL D_CS(21,4); PUT ' Laufz.      ZPaus  '   TO LCD BY A;
  !   CALL ZEITBHKW(3);
  ! ALT  /*  7 */
  !   CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
  !   CALL D_CS(21,2); PUT '  Heizpatrone2 unten ' TO LCD BY A;
  !   CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
  !   CALL ZEITBHKW(12);
 !  ALT  /*  6 */
 !    CALL D_CS(21,1); PUT ' Betriebszeiten      ' TO LCD BY A;
 !    CALL D_CS(21,2); PUT '   WW-Anforderung    ' TO LCD BY A;
 !    CALL D_CS(21,4); PUT ' Laufz.    ZPaus     ' TO LCD BY A;
 !    CALL ZEITBHKW(11);
  ! ALT  /*  7 */
  !   CALL D_CS(21,1); PUT ' Anforderungszeiten ' TO LCD BY A;
  !   CALL D_CS(21,2); PUT '     Kessel3        ' TO LCD BY A;
  !   CALL D_CS(21,4); PUT ' Anfdau   Anf - Ende'   TO LCD BY A;
  !   CALL ZEITKESSEL(3);
  ! ALT  /*  8 */
  !   CALL D_CS(21,1); PUT ' Betriebszeiten     ' TO LCD BY A;
  !   CALL D_CS(21,2); PUT '     Kessel3        ' TO LCD BY A;
  !   CALL D_CS(21,4); PUT ' Laufz.      ZPaus  ' TO LCD BY A;
  !   CALL ZEITBHKW(11);

!   ALT  /*  5 */
!     CALL D_CS(21,1); PUT ' Anforderungszeiten ' TO LCD BY A;
!     CALL D_CS(21,2); PUT '     Kessel2        ' TO LCD BY A;
!     CALL D_CS(21,4); PUT ' Anfdau   Anf - Ende'   TO LCD BY A;
!     CALL ZEITKESSEL(2);
!   ALT  /*  6 */
!     CALL D_CS(21,1); PUT ' Anforderungszeiten ' TO LCD BY A;
!     CALL D_CS(21,2); PUT '     Kessel 1 ST2   ' TO LCD BY A;
!     CALL D_CS(21,4); PUT ' Anfdau   Anf - Ende'   TO LCD BY A;
!     CALL ZEITKESSEL(6);
    OUT 

      FOR I FROM 1 TO 16 REPEAT /* rechte Displayhaelfte loeschen:       */
        CALL D_CS(20,I); PUT TX_LEER TO LCD BY A(26);
      END;

  FIN;
  CALL D_CS(41,16); PUT Z_USEITE2 TO LCD BY F(1);  

END;

/********* alle Waermezaehler die mit Impulsen zu tun haben <<<< *********/
WAERMZAEHL: PROC;
  
  CASE Z_USEITE2
    ALT  /*  1  */
      CALL D_CS(21, 1); PUT 'WW1 Verbrauch     '  TO LCD BY A;
      CALL D_CS(21, 2); PUT 'VORL   ',X_AEIN(37)  TO LCD BY A,F(11,1);
      CALL D_CS(21, 3); PUT 'RUECKL ',X_AEIN(75)  TO LCD BY A,F(11,1);
      CALL D_CS(21, 4); PUT 'W(kWh) ',W_HKTH(1)   TO LCD BY A,F(11,1);
      CALL D_CS(21, 5); PUT 'Df     ',DF_HKTH(1)  TO LCD BY A,F(11,1);
      CALL D_CS(21, 6); 
                        IF P_HKTH(1) < 0.0 AND B_BLINK THEN
                          PUT 'PT(kW)              ' TO LCD BY A;
                        ELSE 
                         PUT 'PT(kW) ',P_HKTH(1)   TO LCD BY A,F(11,1);
                        FIN;
                        IF B_IMPNEU(22) THEN
                          PUT '*' TO LCD BY A;
                          B_IMPNEU(22)='0'B;
                        ELSE  
                          PUT ' ' TO LCD BY A;
                        FIN;  
      CALL D_CS(21, 8); PUT 'WW2 Verbrauch     '  TO LCD BY A;
      CALL D_CS(21, 9); PUT 'VORL   ',X_AEIN(42)  TO LCD BY A,F(11,1);
      CALL D_CS(21,10); PUT 'RUECKL ',X_AEIN(75)  TO LCD BY A,F(11,1);
      CALL D_CS(21,11); PUT 'W(kWh) ',W_HKTH(2)   TO LCD BY A,F(11,1);
      CALL D_CS(21,12); PUT 'Df     ',DF_HKTH(2)  TO LCD BY A,F(11,1);
      CALL D_CS(21,13); 
                        IF P_HKTH(2) < 0.0 AND B_BLINK THEN
                          PUT 'PT(kW)              ' TO LCD BY A;
                        ELSE 
                          PUT 'PT(kW) ',P_HKTH(2)   TO LCD BY A,F(11,1);
                        FIN;
                        IF B_IMPNEU(23) THEN
                          PUT '*' TO LCD BY A;
                          B_IMPNEU(23)='0'B;
                        ELSE  
                          PUT ' ' TO LCD BY A;
                        FIN;  
      CALL D_CS(37,16); PUT 'vvv' TO LCD BY A;  /* es gibt noch mehr               */
    ALT   /*  2 */
      CALL D_CS(21, 1); PUT 'WW3 Verbrauch     '  TO LCD BY A;
      CALL D_CS(21, 2); PUT 'VORL   ',X_AEIN(47)  TO LCD BY A,F(11,1);
      CALL D_CS(21, 3); PUT 'RUECKL ',X_AEIN(75)  TO LCD BY A,F(11,1);
      CALL D_CS(21, 4); PUT 'W(kWh) ',W_HKTH(3)   TO LCD BY A,F(11,1);
      CALL D_CS(21, 5); PUT 'Df     ',DF_HKTH(3)  TO LCD BY A,F(11,1);
      CALL D_CS(21, 6); 
                        IF P_HKTH(3) < 0.0 AND B_BLINK THEN
                          PUT 'PT(kW)              ' TO LCD BY A;
                        ELSE 
                         PUT 'PT(kW) ',P_HKTH(3)   TO LCD BY A,F(11,1);
                        FIN;
                        IF B_IMPNEU(24) THEN
                          PUT '*' TO LCD BY A;
                          B_IMPNEU(24)='0'B;
                        ELSE  
                          PUT ' ' TO LCD BY A;
                        FIN;  
      CALL D_CS(21, 8); PUT 'WW4 Verbrauch     '  TO LCD BY A;
      CALL D_CS(21, 9); PUT 'VORL   ',X_AEIN(52)  TO LCD BY A,F(11,1);
      CALL D_CS(21,10); PUT 'RUECKL ',X_AEIN(75)  TO LCD BY A,F(11,1);
      CALL D_CS(21,11); PUT 'W(kWh) ',W_HKTH(4)   TO LCD BY A,F(11,1);
      CALL D_CS(21,12); PUT 'Df     ',DF_HKTH(4)  TO LCD BY A,F(11,1);
      CALL D_CS(21,13); 
                        IF P_HKTH(4) < 0.0 AND B_BLINK THEN
                          PUT 'PT(kW)              ' TO LCD BY A;
                        ELSE 
                          PUT 'PT(kW) ',P_HKTH(4)   TO LCD BY A,F(11,1);
                        FIN;
                        IF B_IMPNEU(25) THEN
                          PUT '*' TO LCD BY A;
                          B_IMPNEU(25)='0'B;
                        ELSE  
                          PUT ' ' TO LCD BY A;
                        FIN;  

      CALL D_CS(37,16); PUT '---' TO LCD BY A;  /* Endeerkennung letzer WMZ        */
!   ALT   /*  3 */
!        CALL D_CS(21, 8); PUT 'WMZ KESSEL        '  TO LCD BY A;
!        CALL D_CS(21, 7); PUT Z_ZAEHL( 7)/FL_IMP( 7)/2.0 TO LCD BY A,F(11,1);
!                          IF B_IMPNEU( 7) THEN
!                            PUT '*' TO LCD BY A;
!                            B_IMPNEU( 7)='0'B;
!                          ELSE  
!                            PUT ' ' TO LCD BY A;
!                          FIN;  

    OUT 

      IF Z_USEITE2 > 2 THEN  Z_USEITE2=2;  FIN;

      FOR I FROM 1 TO 16 REPEAT /* rechte Displayhaelfte loeschen:       */
        CALL D_CS(20,I); PUT TX_LEER TO LCD BY A(26);
      END;
  FIN;
  CALL D_CS(40,16); PUT Z_USEITE2 TO LCD BY F(1);  

END;

DISPSTAT: PROC;

  FOR I TO 32 REPEAT
    DISPSTATUS2.BIT(I)=DISPSTATUS.BIT(I); 
    DISPSTATUS3.BIT(I)=DISPSTATUS.BIT(I); 
  END;
END;


/*********************************************************************/
/* Alles was sich hinter Menuepunkt "Anzeige" verbirgt                */
/*********************************************************************/
DISPLAY: TASK PRIO 19;

  DCL X_A  FLOAT;
  DCL FIX1 FIXED;
  DCL F311 FIXED(31);
  DCL F312 FIXED(31);
  DCL MON  FIXED;
  DCL DAT  FIXED;
  DCL STD  FIXED;
  DCL MIN  FIXED;
  DCL SEK  FIXED;

  /* Auf der linken Displayhaelfte werden die wichtigsten Systemdaten */
  /* in Zeile 1 bis 15 staendig dargestellt:                          */

  DISPSTATUS.BIT( 1)='0'B; /* normales Display  */
  DISPSTATUS.BIT( 2)='1'B; /* "Anzeige"         */
  DISPSTATUS.BIT( 3)='0'B; /* grosses Display   */
  DISPSTATUS.BIT( 4)='0'B; /* grafischer Absenkungskalender */
  CALL DISPSTAT;

  /* Zeile 1: Datum                                                  */
  CALL D_CS(1,1);
  Z_BUTTON=0;
  PUT '<',BUTT,' ',TX_TAG(DA_WOTAG),' ',DA_DAT,'.',DA_MON,'.',DA_JAH
      TO LCD BY A,A,A,A,A,F(2),A,F(2),A,F(4),SKIP;

  /* Zeile 2: Uhrzeit                                                */
  PUT ZP_NOW TO LCD BY T(8);

  PUT TO LCD BY SKIP;

  /* Zeile 3: Heizungsstatus:                                        */
  IF B_HZGWB  THEN PUT 'HZG EIN ' TO LCD;
  ELSE             PUT 'HZG AUS ' TO LCD; FIN;
  CASE Z_BETRIEB
    ALT PUT 'Auto      ' TO LCD BY A;
    ALT PUT 'SB  !!    ' TO LCD BY A;
    OUT PUT '-         ' TO LCD BY A;
  FIN;
  PUT TO LCD BY SKIP;

  /* Zeile 4: Absenkungsstatus:                                      */
  IF NOT B_HMN(32) THEN
    PUT 'Sommerbetrieb!    ' TO LCD BY A,SKIP;
  ELSE
    IF ZUST_HZG==2 THEN 
      PUT 'Dauertagbetrieb!  ' TO LCD BY A,SKIP;
    ELSE
      IF ZUST_HZG==3 THEN 
        PUT 'Dauernachtbetrieb!' TO LCD BY A,SKIP;
      ELSE
        IF B_KERNABS THEN 
          PUT 'Nachtbetrieb      ' TO LCD BY A,SKIP;
        ELSE              
          PUT 'Tagbetrieb        ' TO LCD BY A,SKIP;
        FIN;
      FIN;
    FIN;
  FIN;

  /* Zeile  5: Heizungsdruck                                          */
  PUT '  HZG-Druck:',P_VERTEIL TO LCD BY A,F(5,2),SKIP;   
! PUT 'HZG-Pri-Dr.:',P_VERTEIL TO LCD BY A,F(5,2),SKIP;   
! PUT 'HZG-Sek-Dr.:',X_AEIN(28) TO LCD BY A,F(5,2),SKIP;   

  /* Zeile  6: Aussentemperatur                                       */
  PUT 'Aussentemp.:',TC_AUSSEN TO LCD BY A,F(5,1),SKIP;

  /* Zeile  7: Vorlaufsolltemperatur:                                 */
  PUT 'Vorlaufsoll:',TC_VSOLL  TO LCD BY A,F(5,1),SKIP;

  /* Zeile  8: Vorlaufisttemperatur:                                  */
  PUT 'Vorlauf ist:',TC_VIST  TO LCD BY A,F(5,1),SKIP;

  /* Zeile  9: Strombedarf des Objekts                                */
! PUT 'elt. Bedarf:',PE_BEDARF TO LCD BY A,F(5,1);
! IF B_IMPNEU(12) THEN
!   PUT '*' TO LCD BY A;
!   B_IMPNEU(12)='0'B;
! ELSE
!   PUT ' ' TO LCD BY A;
! FIN;
! PUT TO LCD BY SKIP;
  
  /* Zeile 10: Sollwert der BHKWs                                     */
! PUT 'Soll BHKW  :',PE_BSOLLGES  TO LCD BY A,F(5,1);
! IF B_PMAX AND PE_BSOLLGES>0.1 THEN    PUT '^'  TO LCD BY A,SKIP;
! ELSE
!   IF B_PMIN AND PE_BSOLLGES>0.1 THEN  PUT 'v'  TO LCD BY A,SKIP;
!   ELSE            PUT ' '  TO LCD BY A,SKIP;
!   FIN;
! FIN;
!
! /* Zeile 11:                                     */
! PUT '  Gassensor:',FL_GAS,'V' TO LCD BY A,F(5,2),A,SKIP;    

  /* Zeile 12:                                      */
! PUT 'Gasverb. in m^3/h ' TO LCD BY A,SKIP;      /*  */
!
! /* Zeile 13:                                      */
! PUT 'Gas gesamt: ',P_DI(10) TO LCD BY A,F(5,1);
! IF B_IMPNEU(10) THEN                            /*  */
!   PUT '*' TO LCD BY A;                          /*  */
!   B_IMPNEU(10)='0'B;                            /*  */ 
! ELSE                                            /*  */  
!   PUT ' ' TO LCD BY A;                          /*  */
! FIN;                                            /*  */
! PUT TO LCD BY SKIP;
! /* Zeile 14:                                      */
! PUT 'Gas BHKW:   ',P_DI( 9) TO LCD BY A,F(5,1);
! IF B_IMPNEU( 9) THEN                            /*  */
!   PUT '*' TO LCD BY A;                          /*  */
!   B_IMPNEU( 9)='0'B;                            /*  */ 
! ELSE                                            /*  */  
!   PUT ' ' TO LCD BY A;                          /*  */
! FIN;                                            /*  */
! PUT TO LCD BY SKIP;
! /* Zeile 14:                                      */
! PUT 'Gas BHKW2:  ',P_DI(17) TO LCD BY A,F(5,1);
! IF B_IMPNEU(17) THEN                            /*  */
!   PUT '*' TO LCD BY A;                          /*  */
!   B_IMPNEU(17)='0'B;                            /*  */ 
! ELSE                                            /*  */  
!   PUT ' ' TO LCD BY A;                          /*  */
! FIN;                                            /*  */
! PUT TO LCD BY SKIP;

  PUT TO LCD BY SKIP;
  PUT TO LCD BY SKIP;
  PUT TO LCD BY SKIP;
  PUT TO LCD BY SKIP;
  PUT TO LCD BY SKIP;
  PUT TO LCD BY SKIP;
  PUT TO LCD BY SKIP;


  /* Zeile 16: Restkapazit„t des Rechners                            */
! IF B_IDLE THEN
!   PUT 'Leerlauf:',IT_REST,'%' TO LCD BY A,F(5,1),A;
! ELSE
!   PUT 'Seite: ',Z_SEITE,TOCHAR(64+Z_USEITE) TO LCD BY A,F(1),A;
! FIN;
! IF Z_USEITE2MAX > 1 THEN
!   PUT '.',Z_USEITE2 TO LCD BY A,F(1);
! ELSE
!   PUT '  ' TO LCD BY A;
! FIN;
!
! 
! PUT TO LCD BY SKIP;
! IF B_BLINK AND B_SAMMELST THEN
!   PUT 'STOERUNG!' TO LCD BY A;
! ELSE
!   PUT '          ' TO LCD BY A;
! FIN;

  IF B_SAMMELST THEN
    IF B_BLINK THEN
      IF Z_USEITE2MAX > 1 THEN
        PUT 'S.: ',Z_SEITE,TOCHAR(64+Z_USEITE) TO LCD BY A,F(1),A;
        PUT '.',Z_USEITE2,' STOERUNG! ' TO LCD BY A,F(1),A;
      ELSE
        PUT 'Seite: ',Z_SEITE,TOCHAR(64+Z_USEITE) TO LCD BY A,F(1),A;
        PUT ' STOERUNG! ' TO LCD BY A;
      FIN;
    ELSE
      IF Z_USEITE2MAX > 1 THEN
        PUT 'S.: ',Z_SEITE,TOCHAR(64+Z_USEITE) TO LCD BY A,F(1),A;
        PUT '.',Z_USEITE2,'           ' TO LCD BY A,F(1),A;
      ELSE
        PUT 'Seite: ',Z_SEITE,TOCHAR(64+Z_USEITE) TO LCD BY A,F(1),A;
        PUT '           ' TO LCD BY A;
      FIN;
    FIN;
  ELSE
    PUT 'Seite: ',Z_SEITE,TOCHAR(64+Z_USEITE) TO LCD BY A,F(1),A;
    IF Z_USEITE2MAX > 1 THEN
      PUT '.',Z_USEITE2,'         ' TO LCD BY A,F(1),A;
    ELSE
      PUT '           ' TO LCD BY A;
    FIN;
  FIN;

! PUT TO LCD BY SKIP;
! PUT '1234567890123456789012345678901234567890123456' TO LCD BY A,SKIP;
! PUT 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRST' TO LCD BY A;

  IF B_NEUSEITE THEN /* Falls eine neue Seite gewaehlt ist,          */
    B_NEUSEITE='0'B; /* neue Seite quittieren                        */
    FOR I FROM 1 TO 16 REPEAT /* rechte Displayhaelfte loeschen:     */
      CALL D_CS(20,I); PUT TX_LEER TO LCD BY A(26);
    END;
  FIN;

  B_BLINK=NOT B_BLINK;

  IF Z_BLINK<96 THEN
    IF B_BLINK THEN
      Z_BLINK=Z_BLINK+1;
    FIN;
  ELSE
    Z_BLINK=1;
  FIN;

  IF B_BLINK AND (Z_BLINK-1) REM 4 == 0 THEN
    IF X_H < N_HZKR THEN         
      X_H=X_H+1;
    ELSE
      X_H=1;
    FIN;
  FIN;

  IF X_GEHEIM>0 AND X_GEHEIM<=N_HZKR THEN
    X_H=X_GEHEIM;
  FIN;

! CALL D_RON; 
  IF Z_SEITE==1 THEN
   Z_USEITE2MAX=1;   
   IF Z_USEITE <  8 THEN
    CASE Z_USEITE /* die einzelnen Unterseiten darstellen            */
      ALT         /* Seite 1A: Status der einzelnen W{rmerzeuger     */

        CALL D_CS(21,1); /* Titelzeile darstellen                    */
        PUT 'Rang Modul  STA P/KW' TO LCD;
 
        FOR I TO N_BHKW REPEAT /* Anzeige der BHKW-Daten             */
          M=FS_LBHKW(I);       /* BHKW-Rang                          */
 
          /* Zustand des BHKW ermitteln:                             */
          IF B_BL(I) THEN         TX_STAT=' EIN';
          ELSE
            IF B_BSTOER(I) THEN
              IF B_BLINK THEN
                TX_STAT='    ';
              ELSE
                TX_STAT=' ERR';
              FIN;
            ELSE
              IF Z_BTHERMVL(I) < 1 AND Z_BTHERMRL(I) < 1 THEN
                IF B_BERLAUBT2(I) THEN                            
                  IF Z_BPNL(I)>0 THEN                   
                    IF B_BEIN(I) THEN
                      TX_STAT=' ANF';
                    ELSE
                      TX_STAT=' PNL';
                    FIN;
                  ELSE                                     
                    IF B_BEIN(I) THEN
                      TX_STAT=' ANF';
                    ELSE
                      TX_STAT=' AUS';
                    FIN;
                  FIN;                             
                ELSE
                  IF B_BERLAUBT(I) THEN /* <<< */
                    TX_STAT=' SP2';     /* <<< */
                  ELSE                  /* <<< */
                    TX_STAT=' SPR'; 
                  FIN;                  /* <<< */
                FIN;
              ELSE
                IF B_BLINK THEN
                  TX_STAT='    ';
                ELSE
                  TX_STAT=' TH ';
                FIN;
              FIN;
            FIN;
          FIN;  

          CALL D_CS(21,M+1);
          IF B_BWARN(I) AND B_BLINK THEN
            PUT M,'. BHKW W!',I,TX_STAT,PE_BIST(I)
!            TO LCD BY F(1),A,F(1),A,F(5,1);
             TO LCD BY F(1),A,F(1),A,F(5,0);
          ELSE
!           PUT M,'. BHKW   ',I,TX_STAT,PE_BIST(I)
!            TO LCD BY F(1),A,F(1),A,F(5,1);
            PUT M,'. BHKW    ',TX_STAT,PE_BIST(I) TO LCD BY F(1),A,A,F(5,0);
          FIN;
        END;
 
        FOR I TO N_KESSEL REPEAT /* Anzeige der Kesseldaten          */
          M=FS_LKES(I)+N_BHKW;   /* Kesselrang                       */
          IF B_KEIN(I) THEN
            IF B_KL(I) THEN
              TX_STAT=' EIN';
            ELSE
              IF Z_KHARDST(I) > 250 THEN /* <<< */
                IF B_BLINK THEN
                  TX_STAT='    ';
                ELSE
                  TX_STAT=' ERR';
                FIN;
              ELSE
                TX_STAT=' ANF';
              FIN;
            FIN;              
            X_A=PT_KESAKT(I);
          ELSE
            X_A=0.0;
            IF Z_KPNL(I)>0 THEN 
              TX_STAT=' PNL';
            ELSE
              IF B_KERLAUBT(I) THEN
                IF B_KL(I) THEN
                  TX_STAT=' ERH';
                  X_A=PT_KESAKT(I);
                ELSE  
                  TX_STAT=' AUS'; 
                FIN;            
              ELSE
                TX_STAT=' SPR'; 
              FIN;
            FIN;
  !         IF B_STOER(11) THEN  /* <<< THERMOKONTAKT KESSELPUMPE */
  !           IF B_BLINK THEN
  !             TX_STAT='    ';
  !           ELSE
  !             TX_STAT=' TK ';
  !           FIN;
  !         FIN;
          FIN;
          CALL D_CS(21,M+1);
          CASE I
            ALT
              PUT M,'. Holzk.1 '  ,TX_STAT,X_A TO LCD BY F(1),A     ,A,F(5);
            ALT
              PUT M,'. Holzk.2 '  ,TX_STAT,X_A TO LCD BY F(1),A     ,A,F(5);
            ALT
              PUT M,'. Biogask.'  ,TX_STAT,X_A TO LCD BY F(1),A     ,A,F(5);
       !    ALT
       !      PUT M,'. Kes 2.2 '  ,TX_STAT,X_A TO LCD BY F(1),A     ,A,F(5);
            ALT
              PUT M,'. Kessel ',I,TX_STAT,X_A TO LCD BY F(1),A,F(1),A,F(5);
            OUT
          FIN;
        END;

      ! CALL D_CS(21, 5);
      ! PUT 'Heizpatrone  ',FL_PWMPRO(1),'%' TO LCD BY A,F(6,1),A;
      ! CALL D_CS(21, 6);
      ! PUT 'Heizp. unten ',FL_PWMPRO(2),'%' TO LCD BY A,F(6,1),A;

    !   CALL D_CS(21, 6);
    !   PUT 'Rueckm. Kes ',X_AEIN(30),'%' TO LCD BY A,F(6,1),A;
    !   CALL D_CS(21, 9);
    !   PUT 'Rueckm. Kes2',X_AEIN(30),'%' TO LCD BY A,F(6,1),A;

        CALL D_CS(21, 7);
        PUT 'Pth BHKW:   ',PTH_MBUS(1),'kW' TO LCD BY A,F(6,1),A;
        CALL D_CS(21, 9);
        PUT 'StoK1 1/4h: ',Z_STOKVIERT( 8)*0.1,'s' TO LCD BY A,F(6,1),A;
        CALL D_CS(21,10);
        PUT 'StoK1 heute:',TC_KVMAX( 8),'Min' TO LCD BY A,F(6,1),A;
        CALL D_CS(21,11);
        PUT 'StoK2 1/4h: ',Z_STOKVIERT( 9)*0.1,'s' TO LCD BY A,F(6,1),A;
        CALL D_CS(21,12);
        PUT 'StoK2 heute:',TC_KVMAX( 9),'Min' TO LCD BY A,F(6,1),A;
    !   CALL D_CS(21, 8);
    !   PUT 'Fuell Biog.:',X_AEIN(30),'%' TO LCD BY A,F(6,1),A;
    !   CALL D_CS(21, 9);
    !   PUT 'Pth BHKW2:',PTH_MBUS(3),'kW' TO LCD BY A,F(6,1),A;
    !   PUT 'Pth BHKW: ',P_DI(21),'kW' TO LCD BY A,F(6,1),A;
    !   IF B_IMPNEU(21) THEN                            /*  */
    !     PUT '*' TO LCD BY A;                          /*  */
    !     B_IMPNEU(21)='0'B;                            /*  */
    !   ELSE                                            /*  */  
    !     PUT ' ' TO LCD BY A;                          /*  */
    !   FIN;                                            /*  */
    !   CALL D_CS(21,10);
    !   PUT 'Pth Kes:  ',PTH_MBUS(1),'kW' TO LCD BY A,F(6,1),A;
    !   CALL D_CS(21,11);
    !   PUT 'Pth Kes2: ',PTH_MBUS(3),'kW' TO LCD BY A,F(6,1),A;
    !   PUT 'Pth Kes.: ',P_DI(19),'kW' TO LCD BY A,F(6,1),A;
    !   IF B_IMPNEU(19) THEN                            /*  */
    !     PUT '*' TO LCD BY A;                          /*  */
    !     B_IMPNEU(19)='0'B;                            /*  */
    !   ELSE                                            /*  */  
    !     PUT ' ' TO LCD BY A;                          /*  */
    !   FIN;                                            /*  */

    !   CALL D_CS(21,10);
    !   PUT 'elt Bezug:',P_DI(16),'kW' TO LCD BY A,F(6,1),A;
    !   IF B_IMPNEU(16) THEN                            /*  */
    !     PUT '*' TO LCD BY A;                          /*  */
    !     B_IMPNEU(16)='0'B;                            /*  */
    !   ELSE                                            /*  */  
    !     PUT ' ' TO LCD BY A;                          /*  */
    !   FIN;                                            /*  */
    !   CALL D_CS(21,11);
    !   PUT 'elt Einsp:',P_DI(15),'kW' TO LCD BY A,F(6,1),A;
    !   IF B_IMPNEU(15) THEN                            /*  */
    !     PUT '*' TO LCD BY A;                          /*  */
    !     B_IMPNEU(15)='0'B;                            /*  */
    !   ELSE                                            /*  */  
    !     PUT ' ' TO LCD BY A;                          /*  */
    !   FIN;                                            /*  */

    !   CALL D_CS(21,12);
    !   PUT ZF_SEK TO LCD BY F(4);

        CALL D_CS(23,14);
        PUT 'naech. Waermeerz. ' TO LCD BY A;
        CALL D_CS(23,15);
        IF TC_VIST > TC_VSOLL-1.0 THEN
          PUT ' Warm genug !!     ' TO LCD BY A;
        ELSE
          IF N_BHKW > 0 AND Z_BANFORD < 1 THEN
            FIX1=10*(ZF_T1EIN*6-Z_TCKLEIN);
            PUT ' in ca. ',FIX1,'s    ' TO LCD BY A,F(6),A;
          ELSE
            IF N_BHKW > 1 AND Z_BANFORD < N_BHKW THEN
              SEK=Z_LMAX FIT SEK;
              FIX1=10*(ZF_LMAX-SEK);
              IF FIX1 < 0 THEN  FIX1=0;  FIN;
              SEK=Z_STKLEIN FIT SEK;
              FIX1=FIX1+ZF_TMESS*(ZF_NBE-SEK);
              PUT ' in ca. ',FIX1,'s    ' TO LCD BY A,F(6),A;
            ELSE
              IF N_KESSEL > 0 AND Z_KANFORD < 1 THEN
                SEK=Z_LMAX FIT SEK;
                FIX1=10*(ZF_LMAX-SEK);
                IF FIX1 < 0 THEN  FIX1=0;  FIN;
                SEK=Z_STKLEIN FIT SEK;
                FIX1=FIX1+ZF_TMESS*(ZF_NKE-SEK);
                PUT ' in ca. ',FIX1,'s    ' TO LCD BY A,F(6),A;
              ELSE
                IF N_KESSEL > 1 AND Z_KANFORD < N_KESSEL THEN
                  SEK=Z_LKMAX FIT SEK;
                  FIX1=10*(ZF_LKMAX-SEK);
                  IF FIX1 < 0 THEN  FIX1=0;  FIN;
                  SEK=Z_STKLEIN FIT SEK;
                  FIX1=FIX1+ZF_TMESS*(ZF_NKE-SEK);
                  IF Z_LKMAX < 1 THEN
                    PUT ' in ca. >',FIX1,'s    ' TO LCD BY A,F(6),A;
                  ELSE
                    PUT ' in ca.  ',FIX1,'s    ' TO LCD BY A,F(6),A;
                  FIN;
                ELSE
                  PUT ' Alles angefordert!' TO LCD BY A;
                FIN;
              FIN;
            FIN;
          FIN;
        FIN;


   !    CALL D_CS(21, 8);
   !    PUT 'Pth BHKW: ',P_DI(11),'kW' TO LCD BY A,F(6,1),A;
   !    IF B_IMPNEU(11) THEN                            /*  */
   !      PUT '*' TO LCD BY A;                          /*  */
   !      B_IMPNEU(11)='0'B;                            /*  */
   !    ELSE                                            /*  */  
   !      PUT ' ' TO LCD BY A;                          /*  */
   !    FIN;                                            /*  */


!       CALL D_CS(21, 6);
!       PUT 'UST Neubau' TO LCD BY A;
!       CALL D_CS(21, 7);
!       PUT 'VL Soll:',X_AEINEXT(18,1) TO LCD BY A,F(6,1);
!       CALL D_CS(21, 8);
!       PUT 'VL Ist: ',X_AEINEXT( 4,1) TO LCD BY A,F(6,1);

!       CALL D_CS(21,10);
!       PUT 'Sum Verb: ',P_HKTH( 1)+P_HKTH(2)+P_HKTH(3)+P_HKTH(4)+P_HKTH(5),'kW' TO LCD BY A,F(6,1),A;


        CALL D_CS(21,16);
!       IF FL_GAS > FL_GASSTOER THEN
        IF B_STOER(7)           THEN  /* <<< */
          IF B_BLINK THEN
            PUT 'Gassensor' TO LCD BY A;
          ELSE
            PUT '         ' TO LCD BY A;
          FIN;
        ELSE
          PUT '         ' TO LCD BY A;
        FIN;
 
      ALT    /* alle Laufzeitprotokolle */

         CALL DISPLFZ;  

      ALT

         CALL D_CS(21, 1); PUT 'Holzkessel1     ' TO LCD BY A;
         CALL D_CS(21, 2); PUT 'Laufz    ',Z_KESLFZ(1)/3600.0,'h'
                            TO LCD BY A,F(10,2),A;
         CALL D_CS(21, 4); PUT 'Holzkessel2     ' TO LCD BY A;
         CALL D_CS(21, 5); PUT 'Laufz    ',Z_KESLFZ(2)/3600.0,'h'
                            TO LCD BY A,F(10,2),A;
         CALL D_CS(21, 7); PUT 'Biogaskessel    ' TO LCD BY A;
         CALL D_CS(21, 8); PUT 'Laufz    ',Z_KESLFZ(3)/3600.0,'h'
                            TO LCD BY A,F(10,2),A;
         CALL D_CS(21,10); PUT 'BHKW (Angaben ca.)  ' TO LCD BY A;
         CALL D_CS(21,11); PUT 'Laufz.:',FL_BLFZGESHZG(1),'h'
                            TO LCD BY A,F(10,2),A;
         CALL D_CS(21,12); PUT 'Wel.:  ',FL_BKWHGESHZG(1),'kWh'
                            TO LCD BY A,F(10,2),A;
     !   CALL D_CS(21, 3); PUT 'Laufz St2',Z_KESLFZ(6)/3600.0,'h'
     !                      TO LCD BY A,F(10,2),A;
     !   CALL D_CS(21, 4); PUT 'Kessel2         ' TO LCD BY A;
     !   CALL D_CS(21, 5); PUT 'Laufz    ',Z_KESLFZ(2)/3600.0,'h'
     !                      TO LCD BY A,F(10,2),A;
   !     CALL D_CS(21, 7); PUT 'Kessel3         ' TO LCD BY A;
   !     CALL D_CS(21, 8); PUT 'Laufz    ',Z_KESLFZ(3)/3600.0,'h'
   !                        TO LCD BY A,F(10,2),A;
   !     CALL D_CS(21, 7); PUT 'BHKW1           ' TO LCD BY A;
   !     CALL D_CS(21, 8); PUT 'Laufz.:',FL_BLFZGES(1),'h'
   !                        TO LCD BY A,F(10,2),A;
   !     CALL D_CS(21, 9); PUT 'Wel.:  ',FL_BKWHGES(1),'kWh'
   !                        TO LCD BY A,F(10,2),A;
   !
   !     CALL D_CS(21,10); PUT 'BHKW2           ' TO LCD BY A;
   !     CALL D_CS(21,11); PUT 'Laufz.:',FL_BLFZGES(2),'h'
   !                        TO LCD BY A,F(10,2),A;
   !     CALL D_CS(21,12); PUT 'Wel.:  ',FL_BKWHGES(2),'kWh'
   !                        TO LCD BY A,F(10,2),A;
     !   CALL D_CS(21,13); PUT 'BHKW3           ' TO LCD BY A;
     !   CALL D_CS(21,14); PUT 'Laufz.:',FL_BLFZGES(3),'h'
     !                      TO LCD BY A,F(10,2),A;
     !   CALL D_CS(21,15); PUT 'Wel.:  ',FL_BKWHGES(3),'kWh'
     !                      TO LCD BY A,F(10,2),A;
   !     Z_USEITE2=1;

      ALT

         CALL D_CS(21, 1); PUT 'Waermeanforderungen' TO LCD BY A;
         CALL D_CS(21, 2); PUT 'der Verbraucher:   ' TO LCD BY A;
         CALL D_CS(21, 3); PUT 'HK1 Nord       ',TC_HKSOLLGES(1) TO LCD BY A,F(6,2);
         CALL D_CS(21, 4); PUT 'HK2 West       ',TC_HKSOLLGES(2) TO LCD BY A,F(6,2);
         CALL D_CS(21, 5); PUT 'HK3 Sued       ',TC_HKSOLLGES(3) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 5); PUT 'HK Villa       ',TC_HKSOLLGES(3) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 6); PUT 'WW1 Lad Zentr  ',TC_BWVLS(1) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 7); PUT 'WW2 Lad Haus A ',TC_BWVLS(2) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 8); PUT 'WW3 Lad Villa  ',TC_BWVLS(3) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 5); PUT 'HK3 Tischlerei ',TC_HKSOLLGES(3) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 6); PUT 'HK4 Schlosserei',TC_HKSOLLGES(4) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 7); PUT 'HK5 Sued       ',TC_HKSOLLGES(5) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 8); PUT 'HK6 FBH        ',TC_HKSOLLGES(6) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 9); PUT 'HKs sekundaer  ',TC_HKSOLLGES(21) TO LCD BY A,F(6,2);
!        CALL D_CS(21,10); PUT 'HK8 Buero su   ',TC_HKSOLLGES(8) TO LCD BY A,F(6,2);
!        CALL D_CS(21,11); PUT 'HK9 Labor su   ',TC_HKSOLLGES(9) TO LCD BY A,F(6,2);
!        CALL D_CS(21,12); PUT 'HK10 Labor no  ',TC_HKSOLLGES(10) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 4); PUT 'HK2 Malerei    ',TC_HKSOLLGES(2) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 5); PUT 'HK3 Buero      ',TC_HKSOLLGES(3) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 6); PUT 'HK4 DAA        ',TC_HKSOLLGES(4) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 4); PUT 'Nahwaerme  ',TC_WASONST TO LCD BY A,F(6,2);
!        CALL D_CS(21, 6); PUT 'WW2-Ladung ',TC_BWVLS(2) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 9); PUT 'WW3-Ladung ',TC_BWVLS(3) TO LCD BY A,F(6,2);
!        CALL D_CS(21,10); PUT 'WW4-Ladung ',TC_BWVLS(4) TO LCD BY A,F(6,2);
!        CALL D_CS(21, 4); PUT 'U1 Behind  ',X_AEINEXT(29,1) TO LCD BY A,F(6,2);

      ALT

         CALL D_CS(21,1); PUT 'Aussentemperatur' TO LCD BY A;
         CALL D_CS(21,2); PUT 'Schnitt der letzten' TO LCD BY A;
         CALL D_CS(21,3); PUT FL_ATTAU,'h:   ',TC_ATTAU TO LCD BY F(5,1),A,F(6,2);
         CALL D_CS(21,5); PUT 'Tagesmaximum ',TC_AUSSENMAX TO LCD BY A,F(6,2);
         CALL D_CS(21,6); PUT 'Zeitpunkt   ',ZP_AUSSENMAX TO LCD BY A,T(8);
         CALL D_CS(21,7); PUT 'Tagesminimum ',TC_AUSSENMIN TO LCD BY A,F(6,2);
         CALL D_CS(21,8); PUT 'Zeitpunkt   ',ZP_AUSSENMIN TO LCD BY A,T(8);

      ALT

         CALL D_CS(21,1); PUT 'Strombedarf     ' TO LCD BY A;
         CALL D_CS(21,2); PUT 'Schnitt der letzten' TO LCD BY A;
         CALL D_CS(21,3); PUT '24 h:  ',PE_SCHNITT TO LCD BY A,F(6,2);
         CALL D_CS(21,4); PUT '15 MIN-Max der' TO LCD BY A;
         CALL D_CS(21,5); PUT 'letzten 24 h: ',PE_SPITZE TO LCD BY A,F(6,2);
         CALL D_CS(21,6); PUT 'von ',ZP_SPITZE - 15 MIN TO LCD BY A,T(8);
         CALL D_CS(21,7); PUT 'bis ',ZP_SPITZE TO LCD BY A,T(8);

      ALT

         CALL D_CS(21,1); PUT '15 MIN-Wert',PT_VIERTEL TO LCD BY A,F(8,1);
         CALL D_CS(21,2); PUT 'SCHNITT ',PT_SCHNITT TO LCD BY A,F(11,1);
         CALL D_CS(21,3); PUT 'PTHAKT  ',PT_AKT TO LCD BY A,F(11,1);
         CALL D_CS(21,4); PUT 'PETH    ',PE_THERM TO LCD BY A,F(11,1);
         CALL D_CS(21,5); PUT 'TAGESNR    ',DA_TNR TO LCD BY A,F(8);
         CALL D_CS(21,6); PUT 'B-Start24  ',Z_START24 TO LCD BY A,F(8);
         IF X_GEHEIM==100 OR X_GEHEIM==226 THEN
           CALL D_CS(21,8); PUT 'Z_HAUPTNUTZ',Z_HAUPTNUTZ TO LCD BY A,F(8);
           CALL D_CS(21,9); PUT 'PTFELD ',Z_BLINK,PT_FELD(Z_BLINK)
                            TO LCD BY A,F(3),F(8,1);
           CALL D_CS(21,10); PUT 'PEFELD ',Z_BLINK,PE_FELD(Z_BLINK)
                            TO LCD BY A,F(3),F(8,1);
           CALL D_CS(21,11); PUT 'TCATFELD ',Z_BLINK,TC_ATFELD(Z_BLINK)
                            TO LCD BY A,F(3),F(6,1);
           ZP_HILF=((ZF_STD*60+ZF_MIN//15*15) * 1 MIN + 00:00:00)
                   -((Z_BLINK-1)* 15 MIN);
           IF ZP_HILF<00:15:00 THEN
             ZP_HILF=ZP_HILF + 24 HRS;
           FIN;
           CALL D_CS(21,12); PUT ZP_HILF - 15 MIN,' -',ZP_HILF
                            TO LCD BY T(8),A,T(9);
         FIN;

         CALL D_CS(21,15); PUT 'ZDSYS: ',FL_SYS TO LCD BY A,F(6,3);
         CALL D_CS(21,16); PUT Z_LZ,IT_REST,'%' TO LCD BY F(7),F(8,1),A;

  !   ALT
  !      CALL WAERMZAEHL;  /* alle Waermezaehler die mit Impulsen zu tun haben  */
      OUT
     FIN;
    ELSE
     CASE (Z_USEITE- 7)
!     ALT

!       CALL D_CS(21, 1); PUT 'PRG Vers. Unterst' TO LCD BY A;
!       CALL D_CS(21, 2); PUT 'UST1',X_AEINEXT(43,1),X_AEINEXT(45,1) TO LCD BY A,F(3),F(5);
!!      CALL D_CS(21, 3); PUT 'UST2',X_AEINEXT(28,2),X_AEINEXT(27,2) TO LCD BY A,F(3),F(5);
!!      CALL D_CS(21, 4); PUT 'UST3',X_AEINEXT(28,3),X_AEINEXT(27,3) TO LCD BY A,F(3),F(5);
!!      CALL D_CS(21, 5); PUT 'UST4',X_AEINEXT(28,4),X_AEINEXT(27,4) TO LCD BY A,F(3),F(5);
!!      CALL D_CS(21, 6); PUT 'UST5',X_AEINEXT(28,5),X_AEINEXT(27,5) TO LCD BY A,F(3),F(5);
!!
!       CALL D_CS(21, 7); PUT 'letzte CAN-Message' TO LCD BY A;
!       FOR I TO 1 REPEAT
!         CALL DATETIME(T_CAN(I),DAT,MON,STD,MIN,SEK);
!         CALL D_CS(21,I+7);
!         PUT DAT,'.',MON,'.  ',STD,':',MIN,':',SEK TO LCD BY F(3),A,F(2),A,F(2),A,F(2),A,F(2);
!       END;
!
!     ALT
!
!       CALL D_CS(21, 1); PUT 'Schleichupdate     ' TO LCD BY A;
!       CALL D_CS(21, 2); PUT '   Byte      DOPP  ' TO LCD BY A;
!       CALL D_CS(21, 3); PUT ' M',SCHL_BYTEM,SCHL_DOPPM TO LCD BY A,F(8),F(6);
!       
!       FOR I TO 1 REPEAT
!         CALL D_CS(21, I+3); PUT I,SCHL_BYTE(I),SCHL_DOPP(I) TO LCD BY F(2),F(8),F(6);
!       END;
!
!       CALL D_CS(21, 6); PUT '   CRC       ERR   ' TO LCD BY A;
!       CALL D_CS(21, 7); PUT ' M',SCHL_CRCM            TO LCD BY A,F(9);
!       
!       FOR I TO 1 REPEAT
!         CALL D_CS(21, I+ 7); PUT I,SCHL_CRC(I),SCHL_ERR(I) TO LCD BY F(2),F(9),F(6);
!       END;

      ALT

         CALL D_CS(21, 1); PUT 'WA      ',B_WA      TO LCD BY A,B(1);
         CALL D_CS(21, 2); PUT 'SB      ',B_SB      TO LCD BY A,B(1);
         CALL D_CS(21, 3); PUT 'HZGWB   ',B_HZGWB   TO LCD BY A,B(1);
         CALL D_CS(21, 4); PUT 'ESPB    ',B_ESPB    TO LCD BY A,B(1);
         CALL D_CS(21, 5); PUT 'ESPK    ',B_ESPK    TO LCD BY A,B(1);
         CALL D_CS(21, 6); PUT 'TMA     ',Z_TMA     TO LCD BY A,F(5);
         CALL D_CS(21, 7); PUT 'TEIN    ',Z_TEIN    TO LCD BY A,F(5);
         CALL D_CS(21,10); PUT 'Grundfos    1    2'  TO LCD BY A;
         CALL D_CS(21,11); PUT 'Contr   ',Z_GFCONTR,Z_GFCONTR2 TO LCD BY A,F(4),F(4);
         CALL D_CS(21,12); PUT 'Neust   ',Z_GFNEUST,Z_GFNEUST2 TO LCD BY A,F(4),F(4);

      ALT

         CALL D_CS(21,1); PUT HK_NAME(X_H) TO LCD BY A;
         CALL D_CS(21,2); PUT 'B_ABSHK',B_ABSHK(X_H),X_H
           TO LCD BY A,X(4),B(1),F(4);
         CALL D_CS(21,3); PUT 'B_RUNT ',B_RUNTHK(X_H),X_H
           TO LCD BY A,X(4),B(1),F(4);
         CALL D_CS(21,4); PUT 'Z_RUNT ',Z_RUNTHK(X_H),X_H
           TO LCD BY A,F(5),F(4);
         CALL D_CS(21,5); PUT 'B_HOCH ',B_HOCHHK(X_H),X_H
           TO LCD BY A,X(4),B(1),F(4);
         CALL D_CS(21,6); PUT 'Z_HOCH ',Z_HOCHHK(X_H),X_H
           TO LCD BY A,F(5),F(4);
         CALL D_CS(21,7); PUT 'EK ',ZP_KABSEAKT,DA_KABSEAKT
           TO LCD BY A,T(8),F(7);
         CALL D_CS(21,8); PUT 'E',X_H,ZP_ABSEHK(X_H),DA_ABSEHK(X_H)
           TO LCD BY A,F(1),T(9),F(7);
         CALL D_CS(21,9); PUT 'TDHKINT',TD_HKINT(X_H),X_H
           TO LCD BY A,F(8,1),F(3);
    !    CALL D_CS(21,9); PUT 'VOR ',00:00:00+ZD_VOR TO LCD BY A,T(8);

      ALT

         CALL D_CS(21,1); PUT 'BWDRIG  ' TO LCD BY A;
         FOR I TO N_SPEI REPEAT         
           PUT B_BWDRIG(I) TO LCD BY B(1);
         END;
         PUT '  ',B_BWDRIGG TO LCD BY A,B(1);
         CALL D_CS(21,2); PUT 'BWNORM  ' TO LCD BY A;
         FOR I TO N_SPEI REPEAT       
           PUT B_BWNORM(I) TO LCD BY B(1);
         END;
         PUT '  ',B_BWNORMG TO LCD BY A,B(1);
         CALL D_CS(21,3); PUT 'BWMOGL  ' TO LCD BY A;
         FOR I TO N_SPEI REPEAT       
           PUT B_BWMOGL(I) TO LCD BY B(1);
         END;
         PUT '  ',B_BWMOGLG TO LCD BY A,B(1);
         CALL D_CS(21,4); PUT 'TCBWVLS ',TC_BWVLSGES  TO LCD BY A,F(8,3);
         CALL D_CS(21,5); PUT 'PETHERM ',PE_THERM,PE_STUFE TO LCD BY A,(2)(F(6,2));                      
         CALL D_CS(21,6); PUT 'HMT  ' TO LCD BY A;
         FOR I TO N_HZKR REPEAT         
           PUT B_HMT(I) TO LCD BY B(1);
         END;
         PUT B_HMTGES TO LCD BY X(1),B(1);
         CALL D_CS(21,7); PUT 'HMN  ' TO LCD BY A;
         FOR I TO N_HZKR REPEAT          
           PUT B_HMN(I) TO LCD BY B(1);
         END;
         PUT B_HMNGES TO LCD BY X(1),B(1);
         CALL D_CS(21, 8); PUT 'T MAX  ',TC_MAX    TO LCD BY A,F(11,5);
         CALL D_CS(21, 9); PUT 'BTM1    ',B_TM1   TO LCD BY A,B(1);
         CALL D_CS(21,10); PUT 'BTM2    ',B_TM2   TO LCD BY A,B(1);
         CALL D_CS(21,11); PUT 'BTM3    ',B_TM3   TO LCD BY A,B(1);
         CALL D_CS(21,12); PUT 'Legio 1 ',Z_LEGIO(1) TO LCD BY A,F(6);
         CALL D_CS(21,13); PUT 'Legio 2 ',Z_LEGIO(2) TO LCD BY A,F(6);
         CALL D_CS(21,14); PUT 'Legio 3 ',Z_LEGIO(3) TO LCD BY A,F(6);
         CALL D_CS(21,16); PUT 'TCKLEIN ',Z_TCKLEIN TO LCD BY A,F(6);

      ALT

         CALL D_CS(21, 1); PUT 'KERNABS ',B_KERNABS TO LCD BY A,B(1);
         CALL D_CS(21, 2); PUT 'VOR     ',B_VOR     TO LCD BY A,B(1);
         CALL D_CS(21, 3); PUT 'NAER    ',B_NAER    TO LCD BY A,B(1);
         CALL D_CS(21, 4); PUT 'TAER    ',B_TAER    TO LCD BY A,B(1);
         CALL D_CS(21, 5); PUT 'LRSPERR ',Z_LRSPERR TO LCD BY A,F(5);
         CALL D_CS(21, 6); PUT 'JAHRTAG ',Z_JAHRTAG TO LCD BY A,F(4);
         CALL D_CS(21, 7); PUT 'JAHR    ',ZT_JAHR   TO LCD BY A,F(10);
         CALL D_CS(21, 9); PUT 'TOUCH   '  TO LCD BY A;
         CALL D_CS(21,10); PUT 'Inaktiv ',Z_PANELPAUS TO LCD BY A,F(5);
         CALL D_CS(21,11); PUT 'Resets  ',Z_PANELRESET TO LCD BY A,F(5);
         CALL D_CS(21,12); PUT 'Can1empf'  TO LCD BY A;
         CALL D_CS(21,13); PUT 'Contr   ',Z_CAN1CONTR TO LCD BY A,F(5);
         CALL D_CS(21,14); PUT 'Neust   ',Z_CAN1NEUST TO LCD BY A,F(5);

      ALT

         CALL D_CS(21, 1); PUT 'STKLEIN',Z_STKLEIN,ZF_NBE,ZF_NKE TO LCD BY A,F(4),F(4),F(4);
         CALL D_CS(21, 2); PUT 'STGROSS',Z_STGROSS,ZF_NBA TO LCD BY A,F(4),F(4);
         CALL D_CS(21, 3); PUT 'LMIN   ',Z_LMIN,ZF_TAUS*6 TO LCD BY A,F(4),F(4);
         CALL D_CS(21, 4); PUT 'LMAX   ',Z_LMAX,ZF_LMAX TO LCD BY A,F(4),F(4);
         CALL D_CS(21, 5); PUT 'LKMAX  ',Z_LKMAX,ZF_LKMAX TO LCD BY A,F(4),F(4);
         CALL D_CS(21, 6); PUT 'STVSOLL',ST_VSOLL  TO LCD BY A,F(11,5);
         CALL D_CS(21, 7); PUT 'STVIST ',ST_VIST   TO LCD BY A,F(11,5);
         CALL D_CS(21, 8); PUT 'BEIN(1) ',B_BEIN(1) TO LCD BY A,B(1);
         CALL D_CS(21, 9); PUT 'ZBTH(1) ',Z_BTHERMVL(1),Z_BTHERMRL(1) TO LCD BY A,F(5),F(5);
!        CALL D_CS(21,10); PUT 'BEIN(2) ',B_BEIN(2) TO LCD BY A,B(1);
!        CALL D_CS(21,11); PUT 'ZBTH(2) ',Z_BTHERMVL(2),Z_BTHERMRL(2) TO LCD BY A,F(5),F(5);
!        CALL D_CS(21,12); PUT 'BEIN(3) ',B_BEIN(3) TO LCD BY A,B(1);
!        CALL D_CS(21,13); PUT 'ZBTH(3) ',Z_BTHERMVL(3),Z_BTHERMRL(3) TO LCD BY A,F(5),F(5);
         CALL D_CS(21,11); PUT 'KEIN(1) ',B_KEIN(1) TO LCD BY A,B(1);
         CALL D_CS(21,12); PUT 'KEIN(2) ',B_KEIN(2) TO LCD BY A,B(1);
         CALL D_CS(21,13); PUT 'KEIN(3) ',B_KEIN(3) TO LCD BY A,B(1);
!        CALL D_CS(21,14); PUT 'KEIN(4) ',B_KEIN(4) TO LCD BY A,B(1);
         CALL D_CS(21,15); PUT 'ZKESMIN ',Z_PTMINKES TO LCD BY A,F(5);
         CALL D_CS(21,16); PUT 'MINKES  ',PT_MINKES TO LCD BY A,F(5,1);

     ALT

        CALL D_CS(21,1);
        PUT 'MONATSSP. Gr.:',X_A  TO LCD BY A,F(5,1);
        CALL D_CS(21,2); PUT 'JAN:',PE_STRMAX( 1),DA_STRMAX( 1),'.',
                            Z_STRMAX( 1)//4,':',15*(Z_STRMAX( 1) REM 4) 
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,3); PUT 'FEB:',PE_STRMAX( 2),DA_STRMAX( 2),'.',
                            Z_STRMAX( 2)//4,':',15*(Z_STRMAX( 2) REM 4)
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,4); PUT 'MAR:',PE_STRMAX( 3),DA_STRMAX( 3),'.',
                            Z_STRMAX( 3)//4,':',15*(Z_STRMAX( 3) REM 4) 
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,5); PUT 'APR:',PE_STRMAX( 4),DA_STRMAX( 4),'.',
                            Z_STRMAX( 4)//4,':',15*(Z_STRMAX( 4) REM 4)
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,6); PUT 'MAI:',PE_STRMAX( 5),DA_STRMAX( 5),'.',
                            Z_STRMAX( 5)//4,':',15*(Z_STRMAX( 5) REM 4)
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,7); PUT 'JUN:',PE_STRMAX( 6),DA_STRMAX( 6),'.',
                            Z_STRMAX( 6)//4,':',15*(Z_STRMAX( 6) REM 4)
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,8); PUT 'JUL:',PE_STRMAX( 7),DA_STRMAX( 7),'.',
                            Z_STRMAX( 7)//4,':',15*(Z_STRMAX( 7) REM 4) 
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,9); PUT 'AUG:',PE_STRMAX( 8),DA_STRMAX( 8),'.',
                            Z_STRMAX( 8)//4,':',15*(Z_STRMAX( 8) REM 4) 
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,10); PUT 'SEP:',PE_STRMAX( 9),DA_STRMAX( 9),'.',
                            Z_STRMAX( 9)//4,':',15*(Z_STRMAX( 9) REM 4) 
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,11); PUT 'OKT:',PE_STRMAX(10),DA_STRMAX(10),'.',
                            Z_STRMAX(10)//4,':',15*(Z_STRMAX(10) REM 4)
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,12); PUT 'NOV:',PE_STRMAX(11),DA_STRMAX(11),'.',
                            Z_STRMAX(11)//4,':',15*(Z_STRMAX(11) REM 4)
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);
        CALL D_CS(21,13); PUT 'DEZ:',PE_STRMAX(12),DA_STRMAX(12),'.',
                            Z_STRMAX(12)//4,':',15*(Z_STRMAX(12) REM 4)
        TO LCD BY A,F(5,1),F(4),A,F(3),A,F(2);

      OUT;
    FIN;
   FIN; /* of if z_useite <  */
  ELSE /* Seitenzahl ist groesser 1, Temperaturen etc. darstellen      */
    FOR ZEILE TO 16 REPEAT
      M=FP_POS(Z_SEITE,ZEILE); /*Fuehlernummer dieser Anzeigeposition*/
      /* Pruefen, ob ein Fuehler fuer diese Position eingetragen ist:   */
      IF M>0 THEN
        CALL D_CS(20,ZEILE);
        N=FP_HZKR(M); /* N ist evtl. die Nummer eines HK-VL-Fuehlers */
        /* Testen, ob der Fuehler zu einem Heizkreis gehoert:          */
        IF N>0 THEN
          /* Dann Zustand des Heizkreises darstellen:                */
          IF B_BLINK THEN
            IF B_PMPHK(N) THEN
              TX_HZKR='*';
            ELSE
              TX_HZKR=' ';
            FIN;
          ELSE  
            IF B_RUNTHK(N) THEN     TX_HZKR='v'; /* Hzkr. Runterphase  */
            ELSE
              IF B_HOCHHK(N) OR B_VORHK(N) THEN
                TX_HZKR='^';                     /* Hzkr. Hochphase    */
              ELSE
                IF B_ABSHK(N) THEN  TX_HZKR='-'; /* Hzkr. abgesenkt    */
                ELSE                TX_HZKR='+'; /* Hzkr. nicht abges. */
                FIN;
              FIN;
            FIN;
          FIN;
        ELSE
          TX_HZKR=' '; /* kein Heizkreis     */
          /* <<< evtl. fuer manche Fuehler noch ein Sternchen     */ 
          IF FP_HARD(M)== 22 AND B_BPMP   (1) THEN  /* BHKW VL */
            TX_HZKR='*';                                 
          FIN;                                           
       !  IF FP_HARD(M)==183 AND B_BPMP   (2) THEN  /* BHKW2 VL */
       !    TX_HZKR='*';                                 
       !  FIN;                                              
       !  IF FP_HARD(M)==185 AND B_BPMP   (3) THEN  /* BHKW3 VL */
       !    TX_HZKR='*';                                 
       !  FIN;                                              
          IF FP_HARD(M)== 2 AND Z_LZKPMP(1) > 0(31)  THEN  /* Kessel VL */
            TX_HZKR='*';                           /* */
          FIN;                                     /* */
          IF FP_HARD(M)== 4 AND Z_LZKPMP(2) > 0(31)  THEN  /* Kessel VL */
            TX_HZKR='*';                           /* */
          FIN;                                     /* */
          IF FP_HARD(M)== 6 AND Z_LZKPMP(3) > 0(31)  THEN  /* Kessel VL */
            TX_HZKR='*';                           /* */
          FIN;                                     /* */
        FIN;


        /* Namen und Analogeingangswert darstellen:                  */
        /* wenn es sich um einen Druck (5+11) handelt, dann mehr     */
        /* Nachkommastellen, bei einem Gassensor (14) +2.5           */
        IF    FP_TYP(M)==5   /* 0-4 Bar */
           OR FP_TYP(M)==6   /* 0-6 Bar */
           OR FP_TYP(M)==7   /* Gassensor */
           OR FP_TYP(M)==8   /* 0-800 Grad */
           OR FP_TYP(M)==9   /* 0-30V      */   
           OR FP_TYP(M)==14 THEN  /* Durchfl 0-100m^3/h */    /* Gassens  */
          IF FP_TYP(M)==7 THEN
            PUT TX_HZKR,FP_NAME(M),X_AEIN(FP_HARD(M))+2.5 TO LCD BY A,A,F(5,2);
          ELSE 
            IF FP_TYP(M)==8 THEN
              PUT TX_HZKR,FP_NAME(M),X_AEIN(FP_HARD(M)) TO LCD BY A,A,F(5);
            ELSE
              PUT TX_HZKR,FP_NAME(M),X_AEIN(FP_HARD(M)) TO LCD BY A,A,F(5,2);
            FIN;
          FIN;
        ELSE
          IF N>0 AND (X_GEHEIM==100 OR X_GEHEIM==226) AND Z_BLINK REM 5 == 0 THEN
            PUT TX_HZKR,FP_NAME(M),TC_HKSOLLGES(N) TO LCD BY A,A,F(5,2);
          ELSE
            PUT TX_HZKR,FP_NAME(M),X_AEIN(FP_HARD(M)) TO LCD BY A,A,F(5,1);
          FIN;
        FIN;
      FIN;
    END;
  FIN;
! CALL D_ROFF;

  BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */

END; /* of TASK DISPLAY */


/*********************************************************************/
/* Beenden aller zyklischen Ausgabetasks                             */
/*********************************************************************/
ANZ_AUS: PROC GLOBAL;
  TERMINATE STOEROUT;   
  TERMINATE STOERFREIOUT;   
  TERMINATE ANAINOUT;
  TERMINATE ANALOUT;
  TERMINATE PWMOUT;
  TERMINATE DIGITALOUT;
  TERMINATE DIGINOUT;
  TERMINATE PKESOUT;
  TERMINATE PKESOUT1;
  TERMINATE PKESOUT2;
  TERMINATE PMPKESOUT;
  TERMINATE BHKWPROT;   
  TERMINATE ZEIGB;  
  TERMINATE HKKURVEOUT;  
  TERMINATE HKREGOUT;
  TERMINATE HKMIOUT;
  TERMINATE HKMIOUT2;
  TERMINATE ESTRICHOUT; 
  TERMINATE WWSOLLOUT; 
  TERMINATE WWSOLLOUT2; 
  TERMINATE WWREGOUT; 
  TERMINATE WWREGOUT2; 
  TERMINATE WWZIRKOUT; 
  TERMINATE UPEOUT;
  TERMINATE UPEOUT2;
  TERMINATE HZGSPEIOUT; 
  TERMINATE OUT_FUEHLER;
  TERMINATE STROMOUT;
  TERMINATE SCHORNOUT;
  TERMINATE JAHROUT;  
  TERMINATE WOCHOUT;  
  TERMINATE MONZAEHLOUT;  
  TERMINATE MBUSOUT;      /* <<<< auskommentieren wenn mbus.p nicht mitgelinkt */
  TERMINATE MBUSOUT2;     /* <<<< auskommentieren wenn mbus.p nicht mitgelinkt */
  TERMINATE MBUSANZOUT;   /* <<<< auskommentieren wenn mbus.p nicht mitgelinkt */  
! TERMINATE MODBUSOUT;    /* <<<< auskommentieren wenn modbus.p nicht mitgelinkt */  
! TERMINATE FLAMOUT;      /* <<<< auskommentieren wenn flamco.p nicht mitgelinkt */
! TERMINATE FLAMANZOUT;   /* <<<< auskommentieren wenn flamco.p nicht mitgelinkt */  
  Z_FREECOUNT(12)=0;

  B_FUEHL='0'B; /* F}hlerabgleich wird beendet                 */
  B_RAMSPERR='0'B;
END;


/*********************************************************************/
/* Arbeiten im Menuebaum (DISPLAY nicht aktv)                        */
/*********************************************************************/
MENU: TASK PRIO 20; 

  PUNKT=1; ZEIG=1; /* Zeiger vorbesetzen                             */
  /* Hebelbewegung nach links vortaeuschen, um Hauptmenue darzustellen:*/
  X_R=K_L;
  CALL D_CLR;
  REPEAT /* Menueabfrage in einer Endlosschleife                      */

    IF X_R > 1000 THEN                   /* BUTTON geklickt */

      IF PUNKT == 1 THEN                 /* Hauptmenue */
        ZEIG=X_R-1000;
        IF PUNKT > 150 THEN  PUNKT=150;  FIN;  /* NNNNN */
        IF PUNKT < 1   THEN  PUNKT=1;    FIN;
        IF ZEIG  > 15  THEN  ZEIG =15;   FIN;
        IF ZEIG  < 1   THEN  ZEIG =1;    FIN;
        ME_ZALT(PUNKT)=ZEIG;  /* Zeigerposition fuer spaeter sichern   */
        IF ME_POST(PUNKT,ZEIG) < 1 THEN  ME_POST(PUNKT,ZEIG)=1;  FIN;
        WAHL=ME_POST(ME_POST(PUNKT,ZEIG),1); /* Folgeelement bestimm.*/
        IF WAHL > 0 THEN
          PUNKT=ME_POST(PUNKT,ZEIG); /* Folgeelement angewaehlt       */
        ELSE
          IF WAHL == 0 THEN /* nicht definiert, zurueck ins Hauptmenu */
            PUNKT=1;
          ELSE /* dann negativ  ein Eingabepunkt wurde angewaehlt:    */
            CALL EINGABE;   /* in die Eingaberoutine verzweigen:     */
            IF NOT B_WEITER THEN
              CALL STICK;   /* noch eine Bewegung abwarten           */
            FIN;
            B_WEITER='0'B;
            CALL D_CLR;     /* Bildschirm loeschen                    */
          FIN;
        FIN;
        B_MENUNEU='1'B; /* Neuaufbau des Menues erzwingen             */
      ELSE                               /* nicht Hauptmenue */
        IF X_R == 1001 THEN              /* < BUTTON1 zurueck  */
          /* Eine Menueebene hoeher gehen:                               */
          ME_ZALT(PUNKT)=ZEIG;  /* Zeigerposition fuer spaeter sichern   */
          PUNKT=ME_PRAE(PUNKT); /* eine Ebene hoeher                    */
          B_MENUNEU='1'B;       /* Neuaufbau des Menues erzwingen       */
          IF PUNKT==1 THEN
            CALL ANZ_AUS;
          FIN;
        ELSE                             /* Menueauswahl */
          ZEIG=X_R-1001;
          IF PUNKT > 150 THEN  PUNKT=150;  FIN;  /* NNNNN */
          IF PUNKT < 1   THEN  PUNKT=1;    FIN;
          IF ZEIG  > 15  THEN  ZEIG =15;   FIN;
          IF ZEIG  < 1   THEN  ZEIG =1;    FIN;
          ME_ZALT(PUNKT)=ZEIG;  /* Zeigerposition fuer spaeter sichern   */
          WAHL=ME_POST(ME_POST(PUNKT,ZEIG),1); /* Folgeelement bestimm.*/
          IF WAHL > 0 THEN
            PUNKT=ME_POST(PUNKT,ZEIG); /* Folgeelement angewaehlt       */
          ELSE
            IF WAHL == 0 THEN /* nicht definiert, zurueck ins Hauptmenu */
              PUNKT=1;
            ELSE /* dann negativ  ein Eingabepunkt wurde angewaehlt:    */
              CALL EINGABE;   /* in die Eingaberoutine verzweigen:     */
              IF NOT B_WEITER THEN
                CALL STICK;   /* noch eine Bewegung abwarten           */
              FIN;
              B_WEITER='0'B;
              CALL D_CLR;     /* Bildschirm loeschen                    */
            FIN;
          FIN;
          B_MENUNEU='1'B; /* Neuaufbau des Menues erzwingen             */
        FIN;
      FIN;

    ELSE                                 /* Tastaturbedienung */

      CASE X_R /* je nach Hebelbewegung:                               */
  
        ALT /* 1: Hebel nach oben bewegt                               */
          IF ZEIG>1 THEN  /* gibt's davor noch einen Menuepunkt ?       */
            /* Alten Zeiger auf LC-Display loeschen                     */
            CALL D_CS(1,ZEIG+1); PUT '  ' TO LCD;
            ZEIG=ZEIG-1; /* Zeiger auf Menuepunkt verringern            */
          FIN;
  
        ALT /* 2: Hebel nach unten bewegt                              */
          IF ZEIG<WAHLMAX THEN /* gibt's danach noch einen Menuepunkt ? */
            /* Alten Zeiger auf LC-Display loeschen                     */
            CALL D_CS(1,ZEIG+1); PUT '  ' TO LCD;
            ZEIG=ZEIG+1; /* Zeiger auf Menuepunkt erhoehen               */
          FIN;
  
        ALT /* 3: Hebel nach links bewegt                              */
          /* Eine Menueebene hoeher gehen:                               */
          ME_ZALT(PUNKT)=ZEIG;  /* Zeigerposition fuer spaeter sichern   */
          PUNKT=ME_PRAE(PUNKT); /* eine Ebene hoeher                    */
          B_MENUNEU='1'B;       /* Neuaufbau des Menues erzwingen       */
          IF PUNKT==1 THEN
            CALL ANZ_AUS;
          FIN;
        ALT /* 4: Hebel nach rechts bewegt                             */
          /* Eine Menueebene tiefer gehen:                              */
          ME_ZALT(PUNKT)=ZEIG;  /* Zeigerposition fuer spaeter sichern   */
          WAHL=ME_POST(ME_POST(PUNKT,ZEIG),1); /* Folgeelement bestimm.*/
     !    CALL D_CS(70,2);                   /* Test */
     !    PUT 'WA:',WAHL  TO LCD BY A,F(4);  /*      */
          IF WAHL > 0 THEN
            PUNKT=ME_POST(PUNKT,ZEIG); /* Folgeelement angewaehlt       */
          ELSE
            IF WAHL == 0 THEN /* nicht definiert, zurueck ins Hauptmenu */
              PUNKT=1;
            ELSE /* dann negativ  ein Eingabepunkt wurde angewaehlt:    */
              CALL EINGABE;   /* in die Eingaberoutine verzweigen:     */
              IF NOT B_WEITER THEN
                CALL STICK;   /* noch eine Bewegung abwarten           */
              FIN;
              B_WEITER='0'B;
              CALL D_CLR;     /* Bildschirm loeschen                    */
            FIN;
          FIN;
          B_MENUNEU='1'B; /* Neuaufbau des Menues erzwingen             */
        OUT;
          B_MENUNEU='1'B; /* Neuaufbau des Menues erzwingen             */
      FIN;
 
    FIN;

    IF B_MENUNEU THEN /* Neuaufbau des Menues erforderlich?           */
      DISPSTATUS.BIT( 1)='1'B; /* normales Display  */
      DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
      DISPSTATUS.BIT( 3)='0'B; /* grosses Display   */
      DISPSTATUS.BIT( 4)='0'B; /* grafischer Absenkungskalender */
      CALL DISPSTAT;
      B_MENUNEU='0'B;
      /* Titelzeile der aktuellen Menu-Ebene:                        */
      CALL D_CLR;
      CALL D_CS(1,1);
      IF PUNKT == 1 THEN
        PUT '***  ',ME_TEX(PUNKT),'  ***' TO LCD;
      ELSE
        PUT '<',BUTT,'   ',ME_TEX(PUNKT) TO LCD BY A,A,A,A;
      FIN;

      /* alle Menuepunkte dieser Menueebene ausgeben:                  */
      FOR I TO ME_POSTMAX REPEAT
        IF ME_POST(PUNKT,I) > 0 THEN
          WAHLMAX=I; /* Hoechstzahl der anzuwaehlenden Menuepunkte      */
    !     PUT '     ',ME_TEX(ME_POST(PUNKT,I)) TO LCD BY SKIP,A,A;
          PUT '   ',BUTT,' ',ME_TEX(ME_POST(PUNKT,I)) TO LCD BY SKIP,A,A,A,A;
        FIN;
      END;
      ZEIG=ME_ZALT(PUNKT);  /* alte Zeigerposition restaurieren      */
      INDMERK=0;
    FIN;

    /* Zeiger auf aktuellen Men}punkt setzen:                        */
    CALL D_CS(1,ZEIG+1); 
    CALL D_RON;
    PUT '>>' TO LCD;
    CALL D_ROFF;

 !  CALL D_CS(70,3);                   /* Test */
 !  PUT 'PU:',PUNKT TO LCD BY A,F(4);  /*      */
 !  CALL D_CS(70,4);                   /*      */
 !  PUT 'ZE:',ZEIG  TO LCD BY A,F(4);  /*      */

    CALL STICK; /* auf erneute Eingabe warten                        */

  END;
END;


ENDE: TASK PRIO 20 GLOBAL;      /* STST */
  X_GEHEIMINT=0;
  X_GEHEIMEXT=0;
  X_GEHEIM=0;
END;


EINGABETEXT: PROC;
  Z_BUTTON=0;
  PUT '<',BUTT,'  ' TO LCD BY A,A,A;
  IF B_ROTSP AND X_ZUGANG < 1 THEN    /* STST */
    PUT 'EINGABETASTE BLOCKIERT' TO LCD BY X(9),A;
  ELSE
    PUT 'Wert einstellen, EINGABE bestaetigt.' TO LCD;
  FIN;
  PUT 'Eingabe: ' TO LCD BY SKIP,SKIP,A;
  CALL D_RON;
  PUT ME_TEX(ME_POST(PUNKT,ZEIG)) TO LCD BY A;
  CALL D_ROFF;
END;


/*********************************************************************/
/* Verzweigungen des Menuebaums (aus I_MENUE)                        */
/*********************************************************************/
EINGABE: PROC;

  DCL X_A  FLOAT;
  DCL F15  FIXED;

  CALL D_CLR;
  DISPSTATUS.BIT( 1)='1'B; /* normales Display  */
  DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
  DISPSTATUS.BIT( 3)='0'B; /* grosses Display   */
  DISPSTATUS.BIT( 4)='0'B; /* grafischer Absenkungskalender */
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;

  CASE ABS(WAHL) /* abhaengig vom angewaehlten Menuepunkt verzweigen:   */
    /* Anzeigemodus einschalten:                                     */
    ALT CALL D_CLR; B_MENU='0'B; TERMINATE MENU;

    ALT  /* Stoerungsprotokoll  (PROC in sonder.p)   */ 
      CALL QUITTIER(1);
      B_WEITER='1'B;

    ALT  /* Anzeige aktuell anstehende Stoerungen */                        
      IND=1;                   
      WHILE IND>0 REPEAT       
        CALL D_CLR;              
        ACTIVATE STOEROUT;       
        CALL STICK;              
        TERMINATE STOEROUT;      
        IF X_R > 1000 THEN  /* Button */
          CASE X_R-1000
            ALT    /* EXIT */
              IND=0;
            ALT    /* WEITER  */
              IND=IND+1;       
            ALT    /* ZURUECK */           
              IF IND > 1 THEN
                IND=IND-1;     
              FIN;
            OUT
          FIN;
        ELSE
          CASE X_R                 
            ALT /* O  */           
              IF IND > 1 THEN
                IND=IND-1;     
              FIN;
            ALT /* U  */           
              IND=IND+1;       
            ALT /* LI */           
              IND=0;             
            ALT /* RE */           
            ALT /* RO */           
          FIN;                     
        FIN;
      END;                       
      TERMINATE STOEROUT;        
      B_WEITER='1'B;
     
    ALT  /* Stoerungsfreigabe  */ 
      CALL STOERFREI;
      B_WEITER='1'B;

    ALT /* Langzeitmeldeprotokoll */
      CALL STOERZEIG3; /* Meldeprotokoll aufs Display         */
      B_WEITER='1'B;
         
    ALT  /* Wiederkehrende Stoerungen */                                          
      CALL D_CLR;                                            
      CALL D_CS(1,1);                                        
      Z_BUTTON=0;
      PUT '<',BUTT,'  Wiederkehrende Stoerungen:' TO LCD BY A,A,A;
      CALL D_CS(1,3);                                        
      PUT 'Wenn Stoerungen mehrmals am Tag        ' TO LCD BY A;          
      CALL D_CS(1,4);                                        
      PUT 'auftreten, dann werden sie ab          ' TO LCD BY A;          
      CALL D_CS(6,5);                                       
      PUT ZF_STOERMAX24,'   Wiederholungen pro Tag' TO LCD BY F(4),A;
      CALL D_CS(1,6);                                        
      PUT 'als anstehende Stoerungen fuer         ' TO LCD BY A;          
      CALL D_CS(1,7);                                        
      PUT 'die WebTerm Stoerungslogik bewertet.   ' TO LCD BY A;          
      CALL D_CS(1,8);                                        
      PUT 'So koennen auch kurzzeitig anstehende  ' TO LCD BY A;          
      CALL D_CS(1,9);                                        
      PUT 'Stoerungen eine Benachrichtigung       ' TO LCD BY A;          
      CALL D_CS(1,10);                                        
      PUT 'ausloesen.                             ' TO LCD BY A;          

      CALL INP_FIX(6,5,4,1,999,1,ZF_STOERMAX24,'LEER');         

    ALT /* Anzeige Analogeingaenge */
      CALL ANAINRAUS;          
      B_WEITER='1'B;            

    ALT /* Menue Analogausgaenge  */
      CALL ANALOGRAUS;           
      B_WEITER='1'B;             

    ALT /* Menue PWM-Ausgaenge  */ 
      CALL PWMRAUS;             
      B_WEITER='1'B;             

    ALT /* Menue Digitalausgaenge  */
      CALL DIGITALRAUS;
      B_WEITER='1'B;

    ALT /* Menue Digitaleingaenge  */
      CALL DIGINRAUS;
      B_WEITER='1'B;

    ALT /* Leistungsregelung Kessel   */
      CALL INP_PKES;                
      B_WEITER='1'B;
  
    ALT /* Kesselpumpenregelung           */
      CALL INP_PMPKES;                
      B_WEITER='1'B;
  
 !  ALT /* GeniBus Pumpenkommunikation */
 !    CALL UPE_BEDIEN;          
 !    B_WEITER='1'B;            
  
    ALT /* Kesselparameter            */
      CALL INP_KESPAR;                
      B_WEITER='1'B;
  
    ALT CALL EINGABETEXT; /* Kesseltoleranz Hauptkreis */
        CALL INP_FLO(19,6,4,1,1.0,15.0,0.1,TD_KS,'LEER');
  
    ALT /* Kesselrangfolge  */
      CALL INP_FUEHR ( 2        ,N_KESSEL,FS_LKES  );
      B_WEITER='1'B;
  
    ALT CALL EINGABETEXT;     /* Pumpenvorlauf erlaubt?     */
      CALL INP_BIT(15,6,'  JA  ',' NEIN ',B_PMPVORL,'LEER');      /* */
      B_WEITER='0'B;

    ALT /* Erhaltungsregelung  Holzkessel1   */
      CALL INP_PKES1;                
      B_WEITER='1'B;
  
    ALT /* Erhaltungsregelung  Holzkessel2   */
      CALL INP_PKES2;                
      B_WEITER='1'B;
  
    ALT CALL EINGABETEXT; /* Mindestoeffn K-Mi bei Anf (%)  */
        CALL INP_FLO(19,6,4,0,20.0,99.0,1.0,TC_HMT(22),'LEER');
  
    ALT  /* Position Hauptkreisfuehler */                                          
      CALL D_CLR;                                            
      CALL D_CS(1,1);                                        
      Z_BUTTON=0;
      PUT '<',BUTT,'  Position HauptkreisISTwert:' TO LCD BY A,A,A;
      CALL D_CS(1,3);                                        
      PUT '1: Hauptkreis VL                       ' TO LCD BY A;          
      CALL D_CS(1,4);                                        
      PUT '2: Puffer Mitte oben                   ' TO LCD BY A;          
      CALL D_CS(1,5);                                        
      PUT '3: Puffer Mitte                        ' TO LCD BY A;          
      CALL D_CS(1,6);                                        
      PUT '4: Puffer Mitte unten                  ' TO LCD BY A;          

      CALL INP_FIX(10,8,4,1,4,1,ZF_HKPEXT(32),'LEER');         

    ALT  /* Betriebsart Biogaskessel  */                                          
      CALL D_CLR;                                            
      CALL D_CS(1,1);                                        
      Z_BUTTON=0;
      PUT '<',BUTT,'  Betriebsart Biogaskessel:  ' TO LCD BY A,A,A;
      CALL D_CS(1,3);                                        
      IF ZF_HKPEXT(31) < 3 THEN
        PUT '  Kessel IMMER EIN wenn BHKW AUS       ' TO LCD BY A;          
      FIN;
      CALL D_CS(1,4);                                        
      PUT '                                       ' TO LCD BY A;          
      CALL D_CS(1,5);                                        
      PUT '1: maximale Leistung (Gasvernichtung)  ' TO LCD BY A;          
      CALL D_CS(1,6);                                        
      PUT '2: Leistung geregelt auf HauptkreisIST ' TO LCD BY A;          
      CALL D_CS(1,7);                                        
      PUT '3: P gereg. Hauptkr mit Abschaltung    ' TO LCD BY A;          

      CALL INP_FIX(10,9,4,1,3,1,ZF_HKPEXT(31),'LEER');         


 !  ALT /* BHKW Bedienung Kraftwerk */
 !    CALL BHKWBEDIENC;                                 /* */  
 !    B_WEITER='1'B;            
  
    ALT /* BHKW Betriebsprotokoll Merlin                   */
      IND=1;
      WHILE IND > 0 AND IND <= N_BHKW REPEAT
        FOR I TO N_BHKW REPEAT
          CHB(I)='BHKW' CAT TOCHAR(I+48);
        END; 
        CALL OBJAUSWAHL('  BHKW Betriebsprotokoll:',N_BHKW,CHB,'LEER        '); 
    
        IF IND < 1 OR IND > N_BHKW THEN  
          EXIT;
        FIN;

        CALL ONLINE('BHKWPROT');
        CASE X_R 
          ALT /* oben  */
            IND=IND-1;
          ALT /* unten   */
            IND=IND+1; 
          ALT /* links  */
            IND=0;  
          OUT /* rechts oder EINGABE  */
            IND=IND+1; 
        FIN;    
        IF X_R > 1000 THEN  /* BUTTON geklickt */
          IND=0;
        FIN;  

        IF B_EINOBJ AND X_R > 1000 THEN  
          EXIT;
        FIN;
        
      END;
      B_WEITER='1'B;
  
 !  ALT CALL INP_ABS(60             , 2);     /* Wochenkal. BHKW FREIG */
 !    B_WEITER='1'B;
  
    ALT /* BHKW Parameter             */
      CALL INP_BHKWPAR;                
      B_WEITER='1'B;
  
    ALT CALL EINGABETEXT; /* BHKW Betrieb ab VL > */
        CALL INP_FLO(19,6,4,1,65.0,98.0,0.1,TC_HKVNENN(15),'LEER');
  
    ALT CALL EINGABETEXT;  /* Min TCMAX (WW ueberladen,...) */
        CALL INP_FLO(19,6,4,1,50.0,99.0,0.1,TC_MAXMIN,'LEER');

    ALT CALL EINGABETEXT; /* Biogaskessel Ein ab Fuellst > */
        CALL INP_FLO(19,6,4,1,40.0,98.0,0.1,TC_HKVNENN(13),'LEER');
  
    ALT CALL EINGABETEXT; /* Biogasfackel Ein ab Fuellst > */
        CALL INP_FLO(19,6,4,1,65.0,98.0,0.1,TC_HKVNENN(14),'LEER');
  
    ALT CALL INP_ABS(61             , 2);     /* Timer Trocknung Zwangsbetrieb */
      B_WEITER='1'B;
  
    ALT CALL EINGABETEXT; /* Minwert Geblaese "Zwang" */
        CALL INP_FLO(19,6,4,1,10.0,99.0,0.1,TC_HKVNENN(20),'LEER');

    ALT CALL EINGABETEXT; /* Minwert HK2-VL bei "Zwang"  */
        CALL INP_FLO(19,6,4,1,10.0,99.0,0.1,TC_HKVNENN(21),'LEER');

    ALT CALL EINGABETEXT; /* Trocknung Ein ab Pu unten > */
        CALL INP_FLO(19,6,4,1,50.0,98.0,0.1,TC_HKVNENN(12),'LEER');
  
    ALT CALL EINGABETEXT; /* Trocknung Zuluftsollwert */
        CALL INP_FLO(19,6,4,1,20.0,80.0,0.1,TC_HKVNENN(4),'LEER');
  
    ALT CALL INP_ABS(62             , 2);     /* Timer Trocknung Leisebetrieb */
      B_WEITER='1'B;
  
    ALT CALL EINGABETEXT; /* Maxwert Geblaese "Leise" */
        CALL INP_FLO(19,6,4,1,10.0,99.0,0.1,TC_HKVNENN(19),'LEER');
  
    ALT CALL EINGABETEXT; /* Maxwert Geblaese -Normal- (%)*/
        CALL INP_FLO(19,6,4,1,10.0,99.0,0.1,TC_HKVNENN(31),'LEER');
  
 !  ALT  /* BHKW Rangfolge  */
 !    CALL INP_FUEHR ( 1        ,N_BHKW  ,FS_LBHKW);
 !    B_WEITER='1'B;
  
 !  ALT CALL EINGABETEXT;  /* Warn. bei Starts > (in 24h)  */
 !      CALL INP_FIX(19,6,4,1,240,1,ZF_STARTMAX,'LEER');         
  
 !  ALT CALL EINGABETEXT;  /* BHKW Betriebsart */
 !      FOR I TO 10 REPEAT CHB(I)='                              '; END;
 !      CHB(1)='Automatik (normal)            ';
 !      CHB(2)='SB , BHKW nach Strombedarf    ';
 !      CALL INP_BETRIEB(3,5,CHB,2,Z_BETRIEB,'LEER');
 !      B_WEITER='0'B;
  
 !  ALT  /* BHKW CAN-Kommunikation                 */
 !    IND=1;
 !    WHILE IND > 0 AND IND <= N_BHKW REPEAT
 !      FOR I TO N_BHKW REPEAT
 !        CHB(I)='BHKW' CAT TOCHAR(I+48);
 !      END; 
 !      CALL OBJAUSWAHL('  BHKW CAN-Kommunikation:',N_BHKW,CHB,'LEER        '); 
 !  
 !      IF IND < 1 OR IND > N_BHKW THEN  
 !        EXIT;
 !      FIN;
 !
 !      CALL ONLINE('ZEIGB');
 !      CASE X_R 
 !        ALT /* oben  */
 !          IND=IND-1;
 !        ALT /* unten   */
 !          IND=IND+1; 
 !        ALT /* links  */
 !          IND=0;  
 !        ALT /* rechts */
 !          IND=IND+1; 
 !        OUT /* EINGABE  */
 !          B_BEIN(IND)=NOT B_BEIN(IND);   
 !      FIN;    
 !      IF X_R > 1000 THEN  /* BUTTON geklickt */
 !        IND=0;
 !      FIN;  
 !
 !      IF B_EINOBJ AND X_R > 1000 THEN  
 !        EXIT;
 !      FIN;
 !
 !    END;
 !    B_WEITER='1'B;
  
 !  ALT CALL EINGABETEXT;  /* obere BHKW Toleranz Hauptkreis  nur bei > 1 BHKW  */
 !      CALL INP_FLO(19,6,4,1,1.0,10.0,0.1,TD_BO,'LEER');
 !
 !  ALT CALL EINGABETEXT;  /* untere BHKW Toleranz Hauptkreis  nur bei > 1 BHKW  */
 !      CALL INP_FLO(19,6,4,1,1.0,5.0,0.1,TD_BU,'LEER');
 !
 !  ALT CALL EINGABETEXT;  /* BHKW-Ausschaltverz. in MIN  nur bei > 1 BHKW  */
 !      CALL INP_FIX(19,6,4,5,180,1,ZF_TAUS,'LEER');          
  
 !  ALT CALL EINGABETEXT;  /* BHKW1 Einschaltverz. in MIN  */
 !      CALL INP_FIX(19,6,4,1,240,1,ZF_T1EIN,'LEER');         
 !
 !  ALT CALL EINGABETEXT;  /* BHKW1 Einschalttemp. Differ. */
 !      CALL INP_FLO(19,6,5,1, 1.0, 15.0, 1.0, TD_1EIN,'LEER');             
   
 !  ALT  /* BHKW1 Einschaltbedingungen */                                                        
 !    CALL D_CLR;                                            
 !    CALL D_CS(1,1);                                        
 !    PUT '<',BUTT,'  BHKW1 Einschaltbedingungen: ' TO LCD BY A,A,A;          
 !    CALL D_CS(1,3);                                       
 !    PUT '     Hauptkreis < Soll-1K fuer ',ZF_T1EIN,' MIN',BUTT TO LCD BY A,F(5),A,A,SKIP;
 !    PUT 'ODER Hauptkreis < Soll-        ',TD_1EIN,' K  ',BUTT  TO LCD BY A,F(5,0),A,A,SKIP; 
 !    M=1; /* Eingabepunkt 1-2                                     */
 !    WHILE M>0 AND M<3 REPEAT                                
 !      CASE M                                                
 !        ALT                                                 
 !          CALL INP_FIX(32,3,4,1,240,1,ZF_T1EIN,'LEER');
 !        ALT                                                 
 !          CALL INP_FLO(32,4,4,0, 1.0, 15.0, 1.0, TD_1EIN,'LEER');    IF X_R > 3 THEN  M=M-1;  FIN;
 !        OUT;                                                 
 !      FIN;                                                   
 !      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?  */
 !      IF X_R > 1000 THEN  /* BUTTON geklickt */
 !        M=X_R-1001;
 !      FIN;  
 !    END;                                                     
 !
 !  ALT CALL EINGABETEXT;  /* Min TCMAX (WW ueberladen,...) */
 !      CALL INP_FLO(19,6,4,1,50.0,90.0,0.1,TC_MAXMIN,'LEER');
 !
 !  ALT CALL EINGABETEXT;  /* Minimal beachteter Strombedarf */
 !      CALL INP_FLO(19,6,4,1,-2.0,55.0, 0.1, PE_RMIN1B,'LEER');

    ALT   /* Eingabe der Heizkurven       */
      CALL INP_HKKURVE;   
      B_WEITER='1'B;

    ALT   /* HK Wochenkalender  */
      CALL HKZON;      
      B_WEITER='1'B;

    ALT   /* HK Jahreskalender  */
      CALL INP_JAHR;    
      B_WEITER='1'B;

    ALT   /* HK-Pumpenregelung */
      CALL INP_HKREG;    
      B_WEITER='1'B;
                      
  ! ALT /* GeniBus Pumpenkommunikation */
  !   CALL UPE_BEDIEN;          
  !   B_WEITER='1'B;            

    ALT /* HK-Vorlaufregelung             */
      CALL INP_HKMI;                
      B_WEITER='1'B;

    ALT /* HK-Parameter                   */
      CALL INP_HKPAR;                
      B_WEITER='1'B;

    ALT CALL EINGABETEXT;  /* Tau AT-Schnitt (h) */
        CALL INP_FLO(19,6,4,1,0.0,72.0,0.1,FL_ATTAU,'LEER');

    ALT CALL EINGABETEXT;  /* AT-Schnitt  */
        CALL INP_FLO(19,6,6,1,-20.0,50.0,0.1,TC_ATTAU,'LEER');

    ALT /* ESTRICHTROCKNUNG */
      CALL ESTRICHTROCK;        /* */
      B_WEITER='1'B;            /* */

    ALT   /* Jahreskal. HZG-AUS bei AT > 3  */
      CALL INP_JAHR2;    
      B_WEITER='1'B;

 !  ALT /* Regelung Prim-PMP HKs           */
 !    CALL INP_HKMI2;                
 !    B_WEITER='1'B;

 !  ALT   /* Baedertemperaturen             */
 !    CALL INP_BAD;    
 !    B_WEITER='1'B;

 !  ALT  /* WW Solltemperaturen  (Speicher mit innen- oder aussenliegendem WT) <<<<   */
 !    CALL INP_WWSOLL;

 !  ALT  /* WW Solltemperaturen  (FWS) <<<<   */
 !    CALL INP_WWSOLL2;

 !  ALT   /* Timer WW Tagbetrieb   */
 !    CALL WWZON;      
 !    B_WEITER='1'B;
  
 !  ALT   /* Timer WW Desinfektion   */
 !    CALL WWZON2;      
 !    B_WEITER='1'B;

 !  ALT  /* Regelung WW-Ladung  (Speicher mit innen- oder aussenliegendem WT) <<<<   */
 !    CALL INP_WWREG;

 !  ALT  /* Regelung WW-Ladung  (FWS)  <<<<  */
 !    CALL INP_WWREG2;

 !  ALT  /* Regelung WW-Zirkulation      */
 !    CALL INP_WWZIRK;

 !  ALT CALL EINGABETEXT;    /* LP AUS AB AUSTR > SOLL +  */         /* <<< */
 !      CALL INP_FLO(19,6,4,1, 0.0,30.0, 0.1, FL_EXPHK(13),'LEER');  /* <<< */
 !  ALT CALL EINGABETEXT;    /* LP P+  AB AUSTR < SOLL -  */         /* <<< */
 !      CALL INP_FLO(19,6,4,1, 0.0,30.0, 0.1, FL_EXPHK(14),'LEER');  /* <<< */
 !  ALT CALL EINGABETEXT;  /* Grundtakt WW-Ladepumpe (s) */          /* <<< */
 !      CALL INP_FIX(19,6,4,4,30,1,ZF_WWMI(10),'LEER');              /* <<< */

 !  ALT /* GeniBus Pumpenkommunikation */
 !    CALL UPE_BEDIEN;          
 !    B_WEITER='1'B;            

    ALT  /* Aktuelle Zaehlerstaende    */
      CALL MONZAEHL_ZEIG;         
      B_WEITER='1'B;

 !  ALT  /* Impulszaehler  */
 !    CALL ZAEHL_ANZEIG;  
 !    B_WEITER='1'B;      

 !  ALT  /* Waermemengenzaehler (Soft) */
 !    CALL WTH_ANZEIG;         
 !    B_WEITER='1'B;      

 !  ALT  /* Strombilanzen              */
 !    CALL WEL_ANZEIG;             
 !    B_WEITER='1'B;

 !  ALT  /* Tarifkalender HT/NT  */
 !    CALL INP_ABS(55             , 1);   
 !    B_WEITER='1'B;

    ALT  /* Monatszaehler    */
      CALL MON_ZEIG;         
      B_WEITER='1'B;

    ALT  /* Jahreszaehler  */
      CALL JAHR_ZEIG;         
      B_WEITER='1'B;

    ALT  /* Jahreszaehler  */
      CALL SONST_ANZEIG;         
      B_WEITER='1'B;

    ALT /* M-Bus Werte darstellen (PROC in mbus.p) */
      CALL MBUSANZ;            
      B_WEITER='1'B;         
  
    ALT /* M-Bus Kommunikation (PROC in mbus.p)    */
      CALL MBUSBUS;            
      B_WEITER='1'B;          
  
    ALT CALL EINGABETEXT;                                  
        CALL INP_FIX(19,6,4, 5,900,1,ZF_MBUSLES,'LEER');           

  ! ALT /* MBus manuelle Kommunikation (PROC in mbus.p)  */
  !   CALL MB_PUT;           
  !   B_WEITER='1'B;           

  ! ALT /* UPE Pumpenkommunikation */
  !   CALL UPE_BEDIEN;         
  !   B_WEITER='1'B;           
  !
  ! ALT /* UPE Pumpenskalierungsfaktoren */
  !   CALL UPE_SCAL;          
  !   B_WEITER='1'B;
  !
  ! ALT /* UPE Busdaten                  */
  !   CALL UPE_BUS;            
  !   B_WEITER='1'B;
  !
  ! ALT /* UPE Pumpenkennlinie           */
  !   CALL UPE_SCAL2;          
  !   B_WEITER='1'B;
  !
  ! ALT /* GeniBus manuelle Kommunikation (PROC in grundfos.p)  */
  !   CALL GF_PUT;           
  !   B_WEITER='1'B;           
   
  ! ALT  /* MODBUS             */
  !   Z_IND=1;
  !   WHILE Z_IND > 0 REPEAT
  !     CALL D_CLR;
  !     PUT '<',BUTT TO LCD BY A,A;
  !     CALL ONLINE('MODBUSOUT');
  !     IF X_R==4 THEN
  !       Z_IND=Z_IND+1;
  !       WHILE Z_IND > 1 AND Z_IND < 4 REPEAT
  !         CALL D_CLR;
  !         PUT '<',BUTT TO LCD BY A,A;
  !         CALL ONLINE('MODBUSOUT');
  !         IF X_R==4 THEN
  !           Z_IND=Z_IND+1;
  !         ELSE
  !           Z_IND=Z_IND-1;
  !         FIN;
  !       END;
  !       Z_IND=1;
  !     ELSE
  !       Z_IND=0;
  !     FIN;
  !   END;
  !   B_WEITER='1'B;
  !
  ! ALT  /* MODBUS             */
  !   Z_IND=4;
  !   WHILE Z_IND > 0 REPEAT
  !     CALL D_CLR;
  !     PUT '<',BUTT TO LCD BY A,A;
  !     CALL ONLINE('MODBUSOUT');
  !     IF X_R==5 THEN
  !       Z_IND=5;
  !     ELSE
  !       Z_IND=0;
  !     FIN;
  !   END;
  !   B_WEITER='1'B;

    ALT /* ext. Einfl. HKs            */
      CALL INP_EXTHK;                
      B_WEITER='1'B;

    ALT /* ext. Einfl. Kessel         */
      CALL INP_EXTKES;                
      B_WEITER='1'B;

  ! ALT /* ext. Einfl. BHKW           */
  !   CALL INP_EXTBHKW;                
  !   B_WEITER='1'B;

    ALT  /* Schwellen Gassensor */
      CALL D_CLR;                                                
      CALL D_CS(1,1);                                        
      PUT '<',BUTT,'  Gassensorschwellen:  ' TO LCD BY A,A,A;          
      CALL D_CS(1,3);                                            
      PUT 'Gassensorstoerschwelle(V) :',FL_GASSTOER TO LCD BY A,F(7,2),SKIP;
      PUT 'Gassensorwarnschwelle (V) :',FL_GASWARN  TO LCD BY A,F(7,2); 
      IF X_ZUGANG==5 THEN    /* STST */                                   
        M=1; /* Eingabepunkt 1-2                         */
        WHILE M>0 AND M<3 REPEAT                               
          CASE M                                                
            ALT                                                 
              CALL INP_FLO(28,3,6,2,-9.0,99.0, 0.01, FL_GASSTOER,'LEER');
            ALT                                                  
              CALL INP_FLO(28,4,6,2,-9.0,99.0, 0.01, FL_GASWARN,'LEER');
            OUT;                                               
          FIN;                                                  
          CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?  */
        END;                                                     
      ELSE                                                        
      FIN;                                                      

    ALT  /* Schwellen Heizungsdruck */                                                        
      CALL D_CLR;                                            
      CALL D_CS(1,1);                                        
      PUT '<',BUTT,'  HZG-Druck-Warnschwellen: ' TO LCD BY A,A,A;          
      CALL D_CS(1,3);                                       
      PUT 'HZG-Druck-MIN-Warnschwelle (bar): ',FL_DRWARN,BUTT TO LCD BY A,F(5,2),A,SKIP;
      PUT 'HZG-Druck-MAX-Warnschwelle (bar): ',FL_DRMAX,BUTT  TO LCD BY A,F(5,2),A,SKIP; 
      PUT TO LCD BY SKIP;
      M=1; /* Eingabepunkt 1-2                                     */
      WHILE M>0 AND M<3 REPEAT                                
        CASE M                                                
          ALT                                                 
            CALL INP_FLO(34,3,5,2,0.0,FL_DRMAX*0.92, 0.01, FL_DRWARN,'LEER');
          ALT                                                 
            CALL INP_FLO(34,4,5,2,FL_DRWARN*1.08,30.0, 0.01, FL_DRMAX,'LEER');    IF X_R > 3 THEN  M=M-1;  FIN;
          OUT;                                                 
        FIN;                                                   
        CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?  */
        IF X_R > 1000 THEN  /* BUTTON geklickt */
          M=X_R-1001;
        FIN;  
      END;                                                     

 !  ALT  /* Schwellen Heizungsdruck */                                                        
 !    CALL D_CLR;                                            
 !    CALL D_CS(1,1);                                        
 !    PUT '<',BUTT,'  HZG-Druck-Warnschwellen: ' TO LCD BY A,A,A;          
 !    CALL D_CS(1,3);                                       
 !    PUT 'PRI-Druck-MIN-Warnschwelle (bar): ',FL_DRWARN,BUTT TO LCD BY A,F(5,2),A,SKIP;
 !    PUT 'PRI-Druck-MAX-Warnschwelle (bar): ',FL_DRMAX,BUTT  TO LCD BY A,F(5,2),A,SKIP; 
 !    PUT TO LCD BY SKIP;
 !    PUT 'SEK-Druck-MIN-Warnschwelle (bar): ',FL_EXPHK(14),BUTT TO LCD BY A,F(5,2),A,SKIP;
 !    PUT 'SEK-Druck-MAX-Warnschwelle (bar): ',FL_EXPHK(13),BUTT  TO LCD BY A,F(5,2),A,SKIP; 
 !    M=1; /* Eingabepunkt 1-2                                     */
 !    WHILE M>0 AND M<5 REPEAT                                
 !      CASE M                                                
 !        ALT                                                 
 !          CALL INP_FLO(34,3,5,2,0.0,FL_DRMAX*0.92, 0.01, FL_DRWARN,'LEER');
 !        ALT                                                 
 !          CALL INP_FLO(34,4,5,2,FL_DRWARN*1.08,30.0, 0.01, FL_DRMAX,'LEER');   
 !        ALT                                                 
 !          CALL INP_FLO(34,6,5,2,0.0,FL_EXPHK(13)*0.92, 0.01, FL_EXPHK(14),'LEER');
 !        ALT                                                 
 !          CALL INP_FLO(34,7,5,2,FL_EXPHK(14)*1.08,30.0, 0.01, FL_EXPHK(13),'LEER');    IF X_R > 3 THEN  M=M-1;  FIN;
 !        OUT;                                                 
 !      FIN;                                                   
 !      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?  */
 !      IF X_R > 1000 THEN  /* BUTTON geklickt */
 !        M=X_R-1001;
 !      FIN;  
 !    END;                                                     


 !  ALT   /* HZG-Wassernachspeisung  <<<< */                                                        /* */
 !    CALL INP_HZGSPEIS;
 !    B_WEITER='1'B;

    ALT CALL EINGABETEXT; /* Ueberheizung Hauptkreis (K) */                                             
        CALL INP_FLO(19,6,4,1,0.0,10.0, 0.1, TD_UEBERHEIZ,'LEER');       

    ALT  /* Hauptnutzungsdauer Heizung */
      CALL INP_NUTZ;

    ALT  /* Analogeingaenge abgleichen  */
      CALL INP_FUEHLER;
      B_WEITER='1'B;

    ALT  /* Analogausgaenge abgleichen         */
      CALL INP_ANAL;    
      B_WEITER='1'B;

    ALT  /* Zaehleing„nge abgleichen                 */
      CALL ZAEHL_ABGL;  
      B_WEITER='1'B;

    ALT CALL EINGABETEXT;  /* Unterer Heizwert Gas */
        CALL INP_FLO(19,6,5,2,0.0,99.0, 0.01, FL_GASHU,'LEER');   /* */

!   ALT CALL EINGABETEXT;  /* Oberer Heizwert Gas */                               
!       CALL INP_FLO(19,6,5,2,0.0,99.0, 0.01, FL_GASHO,'LEER');   /* */

!   ALT CALL EINGABETEXT;  /* Eingabe der woechentlichen Zeitkorrektur der Uhrzeit */ 
!     CALL D_CS(3,5); PUT 'Korrektur in Sekunden pro Woche:' TO LCD;
!     CALL INP_FIX(17,6,4,-99,99,1,Z_KALSEC,'LEER');          

    ALT CALL EINGABETEXT;  /* Uhrzeit / Datum             */
      CALL INP_RTC;  
      B_WEITER='1'B;

    ALT CALL EINGABETEXT;  /* Zustand der Eingabetaste          */
      CALL INP_ROTSP;         /* STST */
      /* ein paar besondere Geheimzahlen    <<<      */
      IF X_GEHEIM==100 THEN
        PUT TO LCD BY SKIP(3);
        PUT '   ERWEITERTE ANZEIGE' TO LCD BY A;
        AFTER 3 HRS ACTIVATE ENDE;
      FIN;
      IF X_GEHEIM==226 THEN
        AFTER 60 MIN ACTIVATE ENDE;
      FIN;
      IF X_GEHEIM==333 THEN
        CALL NEUSTART;    /* Reset ausloesen                     */
      FIN;
      IF X_GEHEIM==20 THEN
        CALL D_CLR;
        CALL D_CS(9,2);
        PUT 'Pth-SCHNITT' TO LCD BY A;
        CALL D_CS(15,4);
        PUT PT_SCHNITT TO LCD BY F(5);
        CALL INP_FLO(15,4,5,0,10.0,5000.0,1.0,PT_SCHNITT,'LEER');
        FOR I TO 96 REPEAT
          PT_FELD(I)=PT_SCHNITT;
        END;
      FIN;
      IF X_GEHEIM==21 THEN
        CALL D_CLR;
        CALL D_CS(9,2);
        PUT 'FAKTOR H-KESSEL' TO LCD BY A;
        CALL D_CS(15,4);
        PUT TC_HMT(21) TO LCD BY F(5);
        CALL INP_FLO(15,4,5,0,0.0,100.0,1.0,TC_HMT(21),'LEER');
      FIN;
      B_WEITER='1'B;

    ALT   /* Resetinfo            */
      CALL RESETINFO; 
      B_WEITER='1'B;

  ! ALT  /* Letzte Anrufer Fernbedienung */
  !   CALL D_CLR;
  !   PUT ' Letzte Anrufer Fernbedienung: ' TO LCD BY A,SKIP;
  !   FOR I TO 7 REPEAT
  !     PUT NAMESTR(I) TO LCD BY A,SKIP;
  !     PUT 'am ',DA_DATCALL(I),'.',DA_MONCALL(I),'. um',ZP_CALL(I) TO LCD BY A,F(2),A,F(2),A,T(10),SKIP;
  !   END;

  ! ALT CALL EINGABETEXT;   /* Schleichupdate Verz. ms */
  !     CALL INP_FIX(19,6,3,2,990,1,VERZ_SLAVE,'LEER');      

  ! ALT CALL EINGABETEXT;   /* Schleichupdate Mindestanz. Slaves */
  !     CALL INP_FIX(19,6,3,1,10,1,ANZ_SLAVE,'LEER');      

    ALT CALL EINGABETEXT;  /* Ausgabekanal Systemmeldungen    */
      FOR I TO 10 REPEAT CHB(I)='                              '; END;
      CHB(1)='normal                        ';
      CHB(2)='auf ED.FEHLER                 ';
      CHB(3)='auf H0.FEHLER                 ';
      CHB(4)='auf B2.                       ';
      CALL INP_BETRIEB(3,5,CHB,4,Z_SYSOUT,'LEER');

    ALT  /* Systemmeldungen ausgeben */ 
      CALL SYSTEMOUT(2);  /* PROC in mpc.p */
      B_WEITER='1'B;

    ALT  /* geplanter RESET                        */
      CALL D_CLR;
      PUT '<',BUTT,' Mit Eingabetaste Reset in 2 MIN ' TO LCD BY A,A,A,SKIP;
      PUT '   (2MIN alle Waermeerz. AUS)      ' TO LCD BY A,SKIP;
      PUT '   Alle anderen Tasten -> zurueck  ' TO LCD BY A,SKIP;
      CALL STICK;
      IF X_R==5 THEN
        F15=120;
        REPEAT  
          FOR I TO N_KESSEL REPEAT
            B_KEIN(I)='0'B;
            Z_KPNL(I)=20;
          END;
          FOR I TO N_BHKW REPEAT
            B_BEIN(I)='0'B;
            Z_BPNL(I)=20;
          END;
          CALL D_CS(4,8);
          PUT 'Reset in',F15,'s' TO LCD BY A,F(4),A;
          F15=F15-1;
          IF F15 < 5 THEN
            PUT 'TERMINATE Watch -- PREVENT WATCHDOG' TO RTOS;
          FIN;
          AFTER 1 SEC RESUME;
        END;
      FIN;
      B_WEITER='1'B;

    ALT   /* Einstellwerte neu initialis.     */
      CALL D_CLR;
      PUT '<',BUTT,' Mit Eingabe der korrekten ' TO LCD BY A,A,A,SKIP;
      PUT '   Geheimzahl werden alle          ' TO LCD BY A,SKIP;
      PUT '   Parameter auf Grundwerte        ' TO LCD BY A,SKIP;
      PUT '   und alle Zaehler = 0 gesetzt!!! ' TO LCD BY A,SKIP;
      X_GEHEIM=0; CALL INP_FIX(19,6,4,0,9999,1,X_GEHEIM,'LEER');
      IF X_GEHEIM==1101 THEN
        BI_PARA='ABCD5678'B4; /* Magic Word auf Neuinit setzen       */
        ACTIVATE RAMSCHREIB;
        AFTER 0.8 SEC RESUME;
        ACTIVATE RAMSCHREIB; 
        AFTER 0.8 SEC RESUME;
        
        CALL NEUSTART;        /* Reset ausloesen                     */
      FIN;
      X_GEHEIM=0;
      B_WEITER='1'B;

    ALT CALL EINGABETEXT;  /* Verzoerung Tastatur (ms) */
        CALL INP_FIX(19,6,4,  0,2000,1,ZF_TASTVERZ,'LEER');          

    ALT CALL EINGABETEXT;  /* Interv. Steigungsmessung (s) */
        CALL INP_FIX(19,6,4, 10,  60,1,ZF_TMESS,'LEER');          

    ALT  /* Status Relais (Handschalter)  */
      CALL D_CLR;        
      PUT '<',BUTT,'  Status der Digitalausgaenge: ',ZP_NOW TO LCD BY A,A,A,T(10),SKIP;
      FOR I TO N_RELPLT REPEAT
        PUT 'Ausgaenge ',8*(I-1)+1,' bis ',8*I TO LCD BY A,F(3),A,F(3);
        IF Z_UDNSTOER(I) > 10 THEN
          PUT ': ERR' TO LCD BY A;
        ELSE
          PUT ': OK ' TO LCD BY A;
        FIN;
        PUT TO LCD BY SKIP;
      END;
      CALL STICK;
      B_WEITER='1'B;

  ! ALT  /* ascii  */
  !   CALL D_CLR;        
  !   PUT 'ASCII 118 - 218: ',ZP_NOW TO LCD BY A,T(10),SKIP;
  !   FOR I TO 10 REPEAT
  !     FOR K TO 10 REPEAT
  !       PUT TOCHAR(107+I*10+K) TO LCD BY A;
  !       PUT '-' TO LCD BY A;
  !     END;
  !     PUT TO LCD BY SKIP;
  !   END;
  !   CALL STICK;
  !   B_WEITER='1'B;

  ! ALT /* Strom Erzeugung/Einspeisung */
  !   CALL INP_STROM; 
  !   B_WEITER='1'B;

    ALT /* Schornsteinfegermenue */
      CALL INP_SCHORN;
      B_WEITER='1'B;

  ! ALT /* Unterstation  */
  !   CALL BHKWBEDIENC2;                                 /* */  
  !   B_WEITER='1'B;            

 !  ALT /* Unterstation  */
 !    CALL INP_CANTEST;                                /* */  
 !    B_WEITER='1'B;            

    OUT PUT '     >>> nicht vorhanden <<<' TO LCD BY SKIP,SKIP,A;

  FIN;
  CALL D_ROFF;
  IF X_R==K_E THEN AFTER 0.2 SEC RESUME; FIN;
END;   /* Ende Eingabe */




INP_CANTEST: PROC;
  DCL F15     FIXED;

  F15=0;
  CALL D_CLR;
  CALL D_CS(1,1);
  PUT '<',BUTT,'   Test CAN  ' TO LCD BY A,A,A;
  CALL D_CS(1,2);
  IF Z_FREECOUNT(1)==0 THEN
    Z_FREECOUNT(1)=199;
    Z_FREECOUNT(2)=33;
    Z_FREECOUNT(3)=55;
    Z_FREECOUNT(4)=444;
    Z_FREECOUNT(5)=7777;
  FIN;
  PUT 'CAN Identifier:          ',Z_FREECOUNT(1),BUTT TO LCD BY A,F(5),A,SKIP;
  PUT 'Daten CAN1 (Byte1+2):    ',Z_FREECOUNT(2),BUTT TO LCD BY A,F(5),A,SKIP;
  PUT 'Daten CAN2 (Byte3+4):    ',Z_FREECOUNT(3),BUTT TO LCD BY A,F(5),A,SKIP;
  PUT 'Daten CAN3 (Byte5+6):    ',Z_FREECOUNT(4),BUTT TO LCD BY A,F(5),A,SKIP;
  PUT 'Daten CAN4 (Byte7+8):    ',Z_FREECOUNT(5),BUTT TO LCD BY A,F(5),A,SKIP;
  PUT 'Click um zu Senden:        ',BUTT TO LCD BY A,A,SKIP;

  Z_FREECOUNT(11)=9;  /* ZEILE */
  Z_FREECOUNT(12)=2;  /* FREIGABE CANRIM */
  M=1; /* Eingabepunkt 1-5                                     */
  WHILE M>0 AND M<7 REPEAT
    CASE M
      ALT CALL INP_FIX(25, 2,5  ,  0    , 1950  ,1     ,Z_FREECOUNT(1) ,'LEER'); 
      ALT CALL INP_FIX(25, 3,5  ,  0    ,32000  ,1     ,Z_FREECOUNT(2) ,'LEER'); 
      ALT CALL INP_FIX(25, 4,5  ,  0    ,32000  ,1     ,Z_FREECOUNT(3) ,'LEER'); 
      ALT CALL INP_FIX(25, 5,5  ,  0    ,32000  ,1     ,Z_FREECOUNT(4) ,'LEER');                                
      ALT CALL INP_FIX(25, 6,5  ,  0    ,32000  ,1     ,Z_FREECOUNT(5) ,'LEER'); IF X_R == 5 THEN  M=M-1;  FIN;
      ALT 
          CALL SENDCANFIXED(1, Z_FREECOUNT(1), 8, Z_FREECOUNT(2), Z_FREECOUNT(3), Z_FREECOUNT(4), Z_FREECOUNT(5), 20);    F15=12;
      OUT;
    FIN;
    CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
    IF X_R > 1000 THEN  /* BUTTON geklickt */
      M=X_R-1001;
    FIN;  
    IF F15==12 THEN
      M=1; 
      F15=0;
    FIN;
  END; /* of WHILE 1-8                                         */
  Z_FREECOUNT(12)=0;  /* SPERRE CANRIM */

END; /* of PROC INP_MODRTU                                            */




/*********************************************************************/
/* Stoerungsprotokoll                                                */
/*********************************************************************/
QUITTIER: PROC(ART FIXED) GLOBAL;  
                                   
  DCL COUNT   FIXED;
  DCL Z       FIXED;
  DCL BMERK   BIT(1);
  DCL MON  FIXED;
  DCL DAT  FIXED;
  DCL STD  FIXED;
  DCL MIN  FIXED;
  DCL SEK  FIXED;

  COUNT=0;
  X_R=2;
  BMERK='0'B;

  WHILE COUNT<12 REPEAT
    Z=1;
    CALL D_CLR;
    Z_BUTTON=0;
    PUT '<',BUTT,'  letzte Stoerungen:   ' TO LCD BY A,A,A,SKIP;
    WHILE Z < 15 REPEAT
      CALL DATETIME(ZT_STOER(COUNT+Z),DAT,MON,STD,MIN,SEK);
      PUT COUNT+Z,'. ',TX_STOER(COUNT+Z),' am',DAT,'.',MON,'.  ',STD,':',MIN,':',SEK 
        TO LCD BY F(2),A,A(20),A,F(3),A,F(2),A,F(2),A,F(2),A,F(2),SKIP;
      Z=Z+1;
    END;
    IF X_ZUGANG > 0 THEN
      PUT 'weiter:',BUTT,'  zurueck:',BUTT,'  loeschen:',BUTT TO LCD BY A,A,A,A,A,A;
    ELSE
      PUT 'weiter:',BUTT,'  zurueck:',BUTT TO LCD BY A,A,A,A;
    FIN;
    CALL STICK;
    IF X_R > 1000 THEN  /* Button */
      CASE X_R-1000
        ALT
          X_R=3; /* EXIT */
        ALT
          X_R=2; /* WEITER */
        ALT
          X_R=1; /* ZURUECK */
        ALT
          X_R=5; /* LOESCHEN */
        OUT
          X_R=3; /* EXIT */
      FIN;
    FIN;
    CASE X_R /* wohin wurde der Hebel bewegt ?                       */
      ALT /* oben   */
        COUNT=COUNT-1;
        IF COUNT<0 THEN  COUNT=0;  FIN;
      ALT /* unten  */
        COUNT=COUNT+4;
        IF COUNT>11 THEN  COUNT=11;  FIN;
      ALT /* links  */
        COUNT=100; 
      ALT /* rechts */
        COUNT=COUNT+4;
        IF COUNT>11 THEN  COUNT=11;  FIN;
      ALT /* rot    */
        IF X_ZUGANG > 0 THEN
          FOR I TO 25 REPEAT
            TX_STOER(I)='                ';
            ZT_STOER(I)=0(31);
          END;
          FOR I TO 200 REPEAT
            B_STOER(I)='0'B;
            Z_STOERNEU(I)=0;
            Z_STOERFAST(I)=0;
          END;
          FOR I TO 200 REPEAT
            Z_FUEHLST(I)=0;
          END;
          CALL D_CLR;
          CALL D_CS(4,5);
          PUT 'einen Moment bitte' TO LCD BY A;
          AFTER 2.5 SEC RESUME;
          BMERK='1'B;
        FIN;
    FIN;
  END;

END;

/*********************************************************************/
/* Anzeige aktuell anstehende Stoerungen                             */
/*********************************************************************/
STOEROUT: TASK PRIO 19;
  DCL MMERK FIXED;
  
  REPEAT
    M=0;
    O=0;
    N=IND;
    FOR I TO 120 REPEAT
      IF B_STOER(I) AND ZF_STOERFREI(I) < 2 THEN
        M=M+1;
      FIN;
    END;
    IF N > (M-1)//14+1 THEN
      N=(M-1)//14+1;
      IND=N;
    FIN;
    IF M < MMERK THEN
      CALL D_CLR;
    FIN;
    MMERK=M;
    CALL D_CS(1,1);
    Z_BUTTON=0;
    PUT '<',BUTT,'  anstehende Stoerungen:   ' TO LCD BY A,A,A,SKIP;
    PUT ' Nr  Stoerung   ' TO LCD BY A;
    PUT TX_TAG(DA_WOTAG),' ',DA_DAT,'.',
      DA_MON,'.',DA_JAH,' ',ZP_NOW
      TO LCD BY A,A,F(2),A,F(2),A,F(4),A,T(9),SKIP;
    FOR I TO 120 REPEAT
      IF B_STOER(I) AND ZF_STOERFREI(I) < 2 THEN
        O=O+1;
        IF O > (N-1)*14 AND O <= N*14 THEN
          PUT I,'  ',TX_STOERMEL(I),'           ' TO LCD BY F(3),A,A,A,SKIP;
        FIN;
      FIN;
    END;
    IF M < 15 THEN
      PUT 'keine weiteren Stoerungen       ' TO LCD;
    ELSE
      PUT 'weiter: ',BUTT,'  zurueck:',BUTT TO LCD BY A,A,A,A;
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;


/*********************************************************************/
/* Einstellung Stoerungsfreigabe                                     */
/*********************************************************************/
STOERFREIOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      CALL D_CS(28,2);
      PUT 'Stoe?  Freig.' TO LCD BY A;
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= 200 THEN
          CALL D_CS(32,Y); Y=Y+1;
          PUT B_STOER(I) TO LCD BY B(1);
          CASE ZF_STOERFREI(I)
            ALT
              PUT '  JA    ' TO LCD BY A;
            ALT
              PUT '  NEIN  ' TO LCD BY A;
            OUT
              PUT '  NEIN!!' TO LCD BY A;
          FIN; 
        FIN;
      END;
    ELSE
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;


STOERFREI: PROC;
  DCL BDRIG BIT(1);

  IND=1;
  WHILE IND>0 AND IND<=200 REPEAT

    FOR I TO 200 REPEAT
      CHB(I)=TX_STOERMEL(I);
    END; 
    CALL OBJAUSWAHL('  Stoerungsfreigabe: ',200,CHB,'STOERFREIOUT'); 

    IF IND < 1 OR IND > 200 THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    PUT '<',BUTT,'  Stoerung',IND,':  ',TX_STOERMEL(IND) TO LCD BY A,A,A,F(3),A,A;
    CALL D_CS(3, 3);
    PUT 'Freigabe:       ',BUTT TO LCD BY A,A;
    CASE ZF_STOERFREI(IND)
      ALT
        PUT '  JA                   ' TO LCD BY A;
      ALT
        PUT '  NEIN (keine Meldung) ' TO LCD BY A;
      ALT
        PUT '  NEIN!! (gesperrt)    ' TO LCD BY A;
      OUT
    FIN;
    CALL D_CS(3, 5);
    PUT 'Dringende Weiterl.: ',BUTT TO LCD BY A,A;
    IF ZF_STOERDRIG(IND) > 0 THEN
      PUT '    JA  ' TO LCD BY A;
    ELSE
      PUT '   NEIN ' TO LCD BY A;
    FIN;
    CALL D_CS(3, 7);
    PUT 'Auf Sammelstoerrel.:',BUTT TO LCD BY A,A;
    IF B_STSAMMFREI(IND) THEN
      PUT '    JA  ' TO LCD BY A;
    ELSE
      PUT '   NEIN ' TO LCD BY A;
    FIN;

    N=1;
    WHILE N<4 AND N>0 REPEAT
      CASE N
        ALT  /* Freigabe      */
          CHB(1)=' JA                   ';
          CHB(2)=' NEIN (keine Meldung) ';
          CHB(3)=' NEIN!! (gesperrt)    ';
          IF X_ZUGANG == 5 THEN
            CALL INP_BETRIEB(21,3,CHB,3,ZF_STOERFREI(IND),'STOERFREIOUT');
          ELSE
            IF ZF_STOERFREI(IND)==3 AND X_ZUGANG < 5 THEN
              IF X_R == 3 THEN
              ELSE
                X_R=4;
              FIN;
            ELSE
              CALL INP_BETRIEB(21,3,CHB,2,ZF_STOERFREI(IND),'STOERFREIOUT');
            FIN;  
          FIN;
        ALT  /* Dringende Weiterl. */
          IF ZF_STOERDRIG(IND) > 0 THEN  BDRIG='1'B;  ELSE  BDRIG='0'B;  FIN;
          CALL INP_BIT(25,5,'  JA  ',' NEIN ',BDRIG,'STOERFREIOUT'); 
          IF BDRIG THEN  ZF_STOERDRIG(IND)=1;  ELSE  ZF_STOERDRIG(IND)=0;  FIN;
        ALT  /* Sammelstoerung? */
          CALL INP_BIT(25,7,'  JA  ',' NEIN ',B_STSAMMFREI(IND),'STOERFREIOUT');    IF X_R > 3 THEN  N=N-1;  FIN;
        OUT
      FIN;
      CALL LRROT(N);
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        N=X_R-1001;
      FIN;  
    END;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;


/*********************************************************************/
/* Langzeitmeldeprotokoll                                            */
/*********************************************************************/
STOERZEIG3: PROC GLOBAL;

  DCL TEXT    CHAR(80);
  DCL B1      BIT(1);
  DCL CHAR38  CHAR(38);
  DCL CH1     CHAR(1);
  DCL DAT     FIXED;
  DCL F15     FIXED;
  DCL ZP      CLOCK;
  DCL POSEND  FIXED(31);
  DCL POS     FIXED(31);

  M=DA_MON;

AGAIN:
  CALL D_CLR;

  Z_BUTTON=0;
  PUT '<',BUTT,'  Monatsmeldeprotokolle:   ' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  JAN' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  FEB' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  MAR' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  APR' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  MAI' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  JUN' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  JUL' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  AUG' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  SEP' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  OKT' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  NOV' TO LCD BY A,A,A,SKIP;
  PUT '    ',BUTT,'  DEZ' TO LCD BY A,A,A,SKIP;

  WHILE M > 0 AND M < 13 REPEAT
    CALL D_CS(2,M+1);
    CALL D_RON;
    PUT '>>' TO LCD BY A;
    CALL D_ROFF;
    CALL STICK;
    CALL D_CS(2,M+1);
    PUT '  ' TO LCD BY A;
    IF X_R > 1000 THEN  /* Button */
      IF X_R==1001 THEN  /* EXIT */
        M=0;
      ELSE
        M=X_R-1001;
        GOTO WEITER;
      FIN;
    ELSE
      CASE X_R /* wohin wurde der Hebel bewegt ?                       */
        ALT /* oben   */
          M=M-1;
        ALT /* unten  */
          M=M+1;
        ALT /* links  */
          M=0; 
        ALT /* rechts */
          GOTO WEITER;
        ALT /* rot    */
      FIN;
    FIN;
  END;    

WEITER:

  IF M > 0 THEN
    CALL D_CS(1,16);
    PUT 'einen Moment bitte' TO LCD BY A;

    TEXT='ER NIL.;rm /ED/MONLES';     
    B1=CMD_EXW(TEXT);                

    /* Koordinierung der Zugriffe auf Compact Flash                 */
    /* mit Z_RAMSON anfordern und warten bis alle anderen fertig   */
    F15=0;
    WHILE (Z_RAMSTOER > 0 OR Z_RAMSTAT > 0 OR Z_RAMPAR > 0 OR Z_RAMDUE2 > 0) AND F15 < 3 REPEAT
      F15=F15+1;
      AFTER 0.5 SEC RESUME;
    END;
    Z_RAMSON=50;
    WHILE Z_RAMSTOER > 0 OR Z_RAMSTAT > 0 OR Z_RAMPAR > 0 OR Z_RAMDUE2 > 0 REPEAT
      IF Z_RAMSTOER > 0 THEN  Z_RAMSTOER= Z_RAMSTOER-1; FIN; 
      IF Z_RAMSTAT  > 0 THEN  Z_RAMSTAT = Z_RAMSTAT-1;  FIN; 
      IF Z_RAMPAR   > 0 THEN  Z_RAMPAR  = Z_RAMPAR -1;  FIN; 
      IF Z_RAMDUE2  > 0 THEN  Z_RAMDUE2 = Z_RAMDUE2-1;  FIN;
      AFTER 0.5 SEC RESUME;
      PUT Z_RAMSTOER,Z_RAMSTAT,Z_RAMPAR,Z_RAMDUE2 TO LCD BY (4)(F(5)),SKIP;
    END;

    CASE M
      ALT /*  1 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP01 > /ED/MONLES';     
      ALT /*  2 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP02 > /ED/MONLES';     
      ALT /*  3 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP03 > /ED/MONLES';     
      ALT /*  4 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP04 > /ED/MONLES';     
      ALT /*  5 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP05 > /ED/MONLES';     
      ALT /*  6 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP06 > /ED/MONLES';     
      ALT /*  7 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP07 > /ED/MONLES';     
      ALT /*  8 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP08 > /ED/MONLES';     
      ALT /*  9 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP09 > /ED/MONLES';     
      ALT /* 10 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP10 > /ED/MONLES';     
      ALT /* 11 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP11 > /ED/MONLES';     
      ALT /* 12 */
        TEXT='ER NIL.;COPY PRIO 15 /H0/MONP12 > /ED/MONLES';     
      OUT
    FIN;
  
  
    B1=CMD_EXW(TEXT);                
    Z_RAMSON=0;  /* FERTIG */

    CALL APPEND(MONLES);
    CALL SAVEP(MONLES,POSEND);
  
    CALL REWIND(MONLES);   /* Fehlerdatei zur}ckspulen                 */
    F15=0;
    WHILE ST(MONLES)==0 AND F15 < 15 REPEAT
      IF F15==0 THEN
        CALL D_CLR;
        PUT 'Monatsmeldungen ' TO LCD BY A;     
        CASE M
          ALT /*  1 */
            PUT 'Januar' TO LCD BY A;     
          ALT /*  1 */
            PUT 'Februar' TO LCD BY A;     
          ALT /*  1 */
            PUT 'M„rz' TO LCD BY A;     
          ALT /*  1 */
            PUT 'April' TO LCD BY A;     
          ALT /*  1 */
            PUT 'Mai' TO LCD BY A;     
          ALT /*  1 */
            PUT 'Juni' TO LCD BY A;     
          ALT /*  1 */
            PUT 'Juli' TO LCD BY A;     
          ALT /*  1 */
            PUT 'August' TO LCD BY A;     
          ALT /*  1 */
            PUT 'September' TO LCD BY A;     
          ALT /*  1 */
            PUT 'Oktober' TO LCD BY A;     
          ALT /*  1 */
            PUT 'November' TO LCD BY A;     
          ALT /*  1 */
            PUT 'Dezember' TO LCD BY A;     
          OUT
        FIN;
        IF M > DA_MON THEN
          PUT DA_JAH-1,':' TO LCD BY F(5),A,SKIP;
        ELSE
          PUT DA_JAH,':' TO LCD BY F(5),A,SKIP;
        FIN;
      FIN;
      CALL SAVEP(MONLES,POS);
      IF POS < POSEND - 25(31) THEN
        GET CHAR38 FROM MONLES BY SKIP,A(38);
      FIN;
      IF ST(MONLES)==0 AND POS < POSEND - 34(31) THEN
        /* 'Gassensor Stoer       2. 4.  13:21    HZG-Notr' */
     !  PUT CHAR38 TO LCD BY A;
        FOR I TO 38 REPEAT
          CH1=CHAR38.CHAR(I);
          IF TOFIXED(CH1) > 31 THEN
            PUT CH1 TO LCD BY A;
          FIN;
        END;
     !  IF NOT B_FERN AND NOT B_PANEL THEN
          PUT TO LCD BY SKIP;
     !  FIN;
      FIN;
      F15=F15+1;
      IF ST(MONLES) /= 0 OR POS > POSEND - 34(31) THEN
        Z_BUTTON=0;
        PUT '<',BUTT,'  keine weiteren Meldungen ' TO LCD BY A,A,A,SKIP;
        CALL STICK;
        F15=30;
      FIN;
      IF F15>13 AND F15 < 25 THEN
        Z_BUTTON=0;
        PUT '<',BUTT,'  weitere Meldungen ',BUTT TO LCD BY A,A,A,A,SKIP;
        CALL STICK;
        IF X_R > 1000 THEN  /* Button */
          IF X_R==1001 THEN  /* EXIT */
            F15=30;
          ELSE
            F15=0;
          FIN;
        ELSE
          CASE X_R /* wohin wurde der Hebel bewegt ?                       */
            ALT /* oben   */
            ALT /* unten  */
              F15=0;
            ALT /* links  */
              F15=30; 
            ALT /* rechts */
              F15=0;
            ALT /* rot    */
              F15=0;
          FIN;
        FIN;
      FIN;
    END;
    GOTO AGAIN;
  FIN;

END;



/*********************************************************************/
/* Anzeige Analogeingaenge                                           */
/*********************************************************************/
ANAINOUT: TASK PRIO 19;

  REPEAT
    CALL D_CS(1,2);

    FOR I TO 16 REPEAT
      PUT  I+IND,' ',FP_NAME( I+IND),X_AEIN( I+IND),FELD( I+IND) TO LCD BY F(3),A,A(20),F(7,2),F(8);
      IF I < 16 THEN
        PUT TO LCD BY SKIP;
      FIN;
    END;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;

END;

ANAINRAUS: PROC;
  IND=0;
  WHILE IND >= 0 AND IND < N_FUEHLER-15 REPEAT

    CALL D_CLR;
    PUT '<',BUTT,'  Analogeingaenge: ' TO LCD BY A,A,A,SKIP;
    CALL D_CS(42,17);
    PUT '>',BUTT TO LCD BY A,A;
    AFTER 0.1 SEC RESUME;
    ACTIVATE ANAINOUT;
    CALL STICK;
    PREVENT ANAINOUT;
    TERMINATE ANAINOUT;
    IF X_R > 1000 THEN                   /* BUTTON geklickt */
      IF X_R == 1001 THEN                /* < BUTTON1 EXIT  */
        IND=IND-16;
      ELSE
        IND=IND+16;
      FIN;
    FIN;
    CASE X_R
      ALT /* oben   */
        IND=IND-16;
      ALT /* unten  */
        IND=IND+16;
      ALT /* links  */
        IND=-1;
      ALT /* rechts */
        IND=IND+16;
      ALT /* rot    */
        IND=IND+16;
      OUT
    FIN;
    IF IND > N_FUEHLER-15 THEN
      IND=N_FUEHLER-15;
    FIN;  

  END;
END;



/*********************************************************************/
/* Menue Analogausgaenge     <<<<                                    */
/*********************************************************************/
ANALOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_ANALOG THEN
          CALL D_CS(33,Y); Y=Y+1;
          PUT X_AAUS(I),'%' TO LCD BY F(5,1),A;
          IF Z_AAUTO(I) < 2 THEN
            PUT ' Auto  ' TO LCD BY A;
          ELSE
            PUT ' HAND!!' TO LCD BY A;
          FIN;
        FIN;
      END;
    ELSE
      CALL D_CS(2,3);
      CASE IND
        ALT /* 1 Sollwert Kessel1    */
    !     PUT 'Heizkr. VL:',TC_HKIST(2)  TO LCD BY A,F(6,2);
    !     PUT 'Pth ber.: ',PT_KESAKT(1),'kW  ' TO LCD BY A,F(5,1);
    !     PUT 'Kes VL: ',TC_KV(1),' Soll: ',TC_VSOLL+2.0  TO LCD BY A,F(5,1),A,F(5,1);
        ALT /* 2 WW1 LADEP  */
    !     PUT 'WW Austr.: ',TC_BWO(1) TO LCD BY A,F(5,1);
        ALT /* 3 WW2 LADEP  */
    !     PUT 'WW Austr.: ',TC_BWO(2) TO LCD BY A,F(5,1);
        ALT /* 4 WW3 LADEP  */
    !     PUT 'WW Austr.: ',TC_BWO(3) TO LCD BY A,F(5,1);
        ALT /* 5 WW4 LADEP  */
    !     PUT 'WW Austr.: ',TC_BWO(4) TO LCD BY A,F(5,1);
        ALT /* 6 frei                           */
        ALT /* 7 frei                           */
        ALT /* 8 frei                           */
    !   ALT /* 1 BHKW1-Leistung   */
    !     PUT 'BHKW-Leist. Ist:',PE_BIST(1),'  Soll:',PE_BSOLL(1)
    !     TO LCD BY A,F(6,1),A,F(6,1);
    !   ALT /* 3 RL-Mischer Kessel2  */
    !     PUT 'Kes2 RL: ',TC_KR(2) TO LCD BY A,F(5,1);
    !   ALT /* 4 Regelventil HK2 Haus A/B */
    !     PUT 'Heizkr. VL:',TC_HKIST(2)  TO LCD BY A,F(6,2);
    !   ALT /* 4 Pumpe Kessel2                  */
    !     PUT 'VL: ',TC_KV(2),' RL: ',TC_KR(2) TO LCD BY A,F(5,1),A,F(5,1);
    !   ALT /* 5 Regelventil HK5 Zuluft Seminar */
    !     PUT 'Zuluft:',X_AEIN(16)  TO LCD BY A,F(6,2);
        OUT
      FIN;
      CALL D_CS(2,4);
      PUT 'Ausgang       in %       in V ' TO LCD BY A;
      CALL D_CS(15,5);
      PUT X_AAUS(IND),X_AAUS(IND)*(AP_UHIGH(IND)-AP_ULOW(IND))*0.01+AP_ULOW(IND) TO LCD BY F(5,1),F(11,1);
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;


ANALOGRAUS: PROC;
              
  IND=1;
  WHILE IND>0 AND IND<=N_ANALOG REPEAT

    FOR I TO N_ANALOG REPEAT
      CHB(I)=AP_NAME(I);
    END; 
    CALL OBJAUSWAHL('  Analogausgaenge: ',N_ANALOG,CHB,'ANALOUT     '); 

    IF IND < 1 OR IND > N_ANALOG THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    PUT '<',BUTT,'  Analogausgang',IND,':  ',AP_NAME(IND) TO LCD BY A,A,A,F(2),A,A;
    CALL D_CS(3,7);
    PUT 'Handbetriebswert:',BUTT,X_AHAND(IND) TO LCD BY A,A,F(7,1);
    CALL D_CS(3, 8);
    PUT 'Betriebsart:     ',BUTT TO LCD BY A,A;
    CASE Z_AAUTO(IND)
      ALT
        PUT '  Automatikbetrieb     ' TO LCD BY A;
      ALT
        PUT '  HAND !!!             ' TO LCD BY A;
      ALT
        PUT '  HAND (Teilautom.) !!!' TO LCD BY A;
      OUT
    FIN;
    CALL D_CS(3, 9);
    PUT 'Max Ausgang (%): ',BUTT,X_AAUSMAX(IND) TO LCD BY A,A,F(7,1);
    CALL D_CS(3,10);
    PUT 'Min Ausgang (%): ',BUTT,X_AAUSMIN(IND) TO LCD BY A,A,F(7,1);
    N=1;
    WHILE N<5 AND N>0 REPEAT
      CASE N
        ALT  /* Wert fuer Handbetrieb */
          CALL INP_FLO(22,7,5,1, 0.1,100.0,0.1,X_AHAND(IND),'ANALOUT     ');
        ALT  /* Betriebsart   */
          CHB(1)='Automatikbetrieb     ';
          CHB(2)='HAND !!!             ';
          CHB(3)='HAND (Teilautom.) !!!';
          CALL INP_BETRIEB(22,8,CHB,3,Z_AAUTO(IND),'ANALOUT     ');
        ALT  /* Maximaler Ausgangswert (%) */
          CALL INP_FLO(22, 9,5,1, 0.1,100.0,0.1,X_AAUSMAX(IND),'ANALOUT     ');
        ALT  /* Minimaler Ausgangswert (%) */
          CALL INP_FLO(22,10,5,1, 0.0,100.0,0.1,X_AAUSMIN(IND),'ANALOUT     ');    IF X_R > 3 THEN  N=N-1;  FIN;
        OUT
      FIN;
      CALL LRROT(N);
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        N=X_R-1001;
      FIN;  
    END;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;
END;



/*********************************************************************/
/* Menue PWM-Ausgaenge  <<<<                                         */
/*********************************************************************/
PWMOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_PWM THEN
          CALL D_CS(33,Y); Y=Y+1;
          PUT FL_PWMPRO(I),'%' TO LCD BY F(5,1),A;
          IF Z_PWMAUTO(I) < 2 THEN
            PUT ' Auto  ' TO LCD BY A;
          ELSE
            PUT ' HAND!!' TO LCD BY A;
          FIN;
        FIN;
      END;
    ELSE
      CALL D_CS(2,3);
      CASE IND
        ALT /* 1 WW Zirkulationspumpe1          */
    !     PUT 'Zirkrl: ',TC_ZIRK(1) TO LCD BY A,F(5,1);
        ALT /* 2 WW Zirkulationspumpe2          */
    !     PUT 'Zirkrl: ',TC_ZIRK(2) TO LCD BY A,F(5,1);
        ALT /* 3 WW Zirkulationspumpe3          */
    !     PUT 'Zirkrl: ',TC_ZIRK(3) TO LCD BY A,F(5,1);
        ALT /* 4 WW Zirkulationspumpe4          */
    !     PUT 'Zirkrl: ',TC_ZIRK(4) TO LCD BY A,F(5,1);
    !   ALT /* 1 KES1 PMP */
    !     PUT 'K VL: ',TC_KV(1),' Soll: ',TC_VSOLL+3.5  TO LCD BY A,F(5,1),A,F(5,1),A,F(5,2);
    !   ALT /* 3 WW1 LADEPUMPE   */
    !     PUT 'Speiset.: ',TC_BWIST(1),' Speisep.:',X_AAUS(32)       ,'%' TO LCD BY A,F(5,1),A,F(5,1),A;
    !   ALT /* 4 WW1 Speisepumpe */
    !     PUT 'Speiset.: ',TC_BWIST(1),'  Ladep.:',X_AAUS(31)       ,'%' TO LCD BY A,F(5,1),A,F(5,1),A;
        OUT
      FIN;
      CALL D_CS(2,5);
      PUT 'Ausgang     in % :   ' TO LCD BY A;
      PUT FL_PWMPRO(IND) TO LCD BY F(5,1);
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

PWMRAUS: PROC;

  IND=1;
  WHILE IND>0 AND IND<=N_PWM REPEAT

    FOR I TO N_PWM REPEAT
      CHB(I)=PW_NAME(I);
    END; 
    CALL OBJAUSWAHL('  PWM-Ausgaenge: ',N_PWM,CHB,'PWMOUT     '); 

    IF IND < 1 OR IND > N_PWM THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    PUT '<',BUTT,'  PWM-Ausgang',IND,':  ',PW_NAME(IND) TO LCD BY A,A,A,F(2),A,A;
    CALL D_CS(3,7);
    PUT 'Handbetriebswert:',BUTT,X_PWMHAND(IND) TO LCD BY A,A,F(7,1);
    CALL D_CS(3, 8);
    PUT 'Betriebsart:     ',BUTT TO LCD BY A,A;
    CASE Z_PWMAUTO(IND)
      ALT
        PUT '  Automatikbetrieb     ' TO LCD BY A;
      ALT
        PUT '  HAND !!!             ' TO LCD BY A;
      ALT
        PUT '  HAND (Teilautom.) !!!' TO LCD BY A;
      OUT
    FIN;
    CALL D_CS(3, 9);
    PUT 'Max Ausgang (%): ',BUTT,X_PWMMAX(IND) TO LCD BY A,A,F(7,1);
    CALL D_CS(3,10);
    PUT 'Min Ausgang (%): ',BUTT,X_PWMMIN(IND) TO LCD BY A,A,F(7,1);
    N=1;
    WHILE N<5 AND N>0 REPEAT
      CALL D_ROFF;
      CASE N
        ALT  /* Wert fuer Handbetrieb */
          CALL INP_FLO(22,7,5,1, 0.1,100.0,0.1,X_PWMHAND(IND),'PWMOUT      ');
        ALT  /* Betriebsart   */
          CHB(1)='Automatikbetrieb     ';
          CHB(2)='HAND !!!             ';
          CHB(3)='HAND (Teilautom.) !!!';
          CALL INP_BETRIEB(22,8,CHB,3,Z_PWMAUTO(IND),'PWMOUT      ');
        ALT  /* Maximaler Ausgangswert (%) */
          CALL INP_FLO(22, 9,5,1, 0.1,100.0,0.1,X_PWMMAX(IND),'PWMOUT      ');
        ALT  /* Minimaler Ausgangswert (%) */
          CALL INP_FLO(22,10,5,1, 0.0,100.0,0.1,X_PWMMIN(IND),'PWMOUT      ');    IF X_R > 3 THEN  N=N-1;  FIN;
        OUT
      FIN;
      CALL LRROT(N);
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        N=X_R-1001;
      FIN;  
    END;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;


/*********************************************************************/
/* Menue Digitalausgaenge                                            */
/*********************************************************************/
DIGITALOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_RELPLT*8 THEN
          CALL D_CS(35,Y); Y=Y+1;
          PUT B_DO(I) TO LCD BY B(1);
          IF B_DONEU(I) THEN
            B_DONEU(I)='0'B;
            PUT '*' TO LCD BY A;
          ELSE
            PUT ' ' TO LCD BY A;
          FIN;
          IF Z_DOHAND(I) == 0 THEN
            PUT ' AUTO      ' TO LCD BY A;
          ELSE
            IF Z_DOHAND(I) > 0 THEN
              PUT ' EIN HAND!!' TO LCD BY A;
            ELSE
              PUT ' AUS HAND!!' TO LCD BY A;
            FIN;
          FIN;
        FIN;
      END;
    ELSE
      CALL D_CS(28,3);
      PUT B_DO(IND) TO LCD BY B(1);
      IF B_DONEU(IND) THEN
        B_DONEU(IND)='0'B;
        PUT '*' TO LCD BY A;
      ELSE
        PUT ' ' TO LCD BY A;
      FIN;
      IF Z_DOHAND(IND) > 0 THEN
        PUT ' EIN' TO LCD BY A;
        IF Z_DOHAND(IND) < 1000 THEN
          PUT Z_DOHAND(IND) TO LCD BY F(6);
        ELSE
          PUT ' HAND!!' TO LCD BY A;
        FIN;
      ELSE
        IF Z_DOHAND(IND) < 0 THEN
          PUT ' AUS' TO LCD BY A;
          IF Z_DOHAND(IND) > -1000 THEN
            PUT -Z_DOHAND(IND) TO LCD BY F(6);
          ELSE
            PUT ' HAND!!' TO LCD BY A;
          FIN;
        ELSE
          PUT 'AUTO       ' TO LCD BY A;
        FIN;
      FIN;
    FIN;

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

DIGITALRAUS: PROC;
  DCL NREL FIXED;
  DCL FIX1 FIXED;

  NREL=N_RELPLT*8;
 
  IND=1;
  WHILE IND>0 AND IND<=NREL REPEAT

    FOR I TO NREL REPEAT
      CHB(I)=DO_NAME(I);
    END; 
    CALL OBJAUSWAHL('  Digitalausgaenge: ',NREL,CHB,'DIGITALOUT  '); 

    IF IND < 1 OR IND > NREL THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    PUT '<',BUTT,'  Digitalausgang',IND,':  ' TO LCD BY A,A,A,F(3),A;
    CALL D_CS(1,3);
    PUT DO_NAME(IND) TO LCD BY A;
    CALL D_CS(3, 5);
    PUT 'Betriebsart:     ',BUTT TO LCD BY A,A;
    IF Z_DOHAND(IND) > 0 THEN
      FIX1=2; /* EIN HAND */
    ELSE
      IF Z_DOHAND(IND) < 0 THEN
        FIX1=3; /* AUS HAND */
      ELSE
        FIX1=1; /* AUTO */
      FIN;
    FIN;
    CASE FIX1
      ALT
        PUT '  AUTO                 ' TO LCD BY A;
      ALT
        PUT '  EIN HAND!!           ' TO LCD BY A;
      ALT
        PUT '  AUS HAND!!           ' TO LCD BY A;
      OUT
    FIN;
    N=1;
    WHILE N<2 AND N>0 REPEAT
      CALL D_ROFF;
      CASE N
        ALT  /* Betriebsart   */
          CHB(1)='AUTO                 ';
          CHB(2)='EIN HAND!!           ';
          CHB(3)='AUS HAND!!           ';
          CALL INP_BETRIEB(22,5,CHB,3,FIX1,'DIGITALOUT  ');     IF X_R > 3 THEN  N=N-1;  FIN;
          IF IND > 0 THEN
            IF FIX1 == 2 THEN
              Z_DOHAND(IND)=DO_TON(IND); /* EIN HAND */
            ELSE
              IF FIX1 == 3 THEN
                Z_DOHAND(IND)=DO_TOFF(IND); /* EIN HAND */
              ELSE
                Z_DOHAND(IND)=0; /* AUTO */
              FIN;
            FIN;
          FIN;
        OUT
      FIN;
      CALL LRROT(N);
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        N=X_R-1001;
      FIN;  
    END;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;



/*********************************************************************/
/* Menue Digitaleingaenge                                            */
/*********************************************************************/
DIGINOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_DIGIN THEN
          CALL D_CS(36,Y); Y=Y+1;
          PUT BI_DEIN(I) TO LCD BY B(1);
          IF B_IMPNEU(I) THEN
            B_IMPNEU(I)='0'B;
            PUT '*' TO LCD BY A;
          ELSE
            PUT ' ' TO LCD BY A;
          FIN;
          PUT BI_DEINBEW(I) TO LCD BY B(1);
          CASE Z_DIBEWERT(I)
            ALT
              PUT ' norm  ' TO LCD BY A;
            ALT
              PUT ' TOGG!!' TO LCD BY A;
            ALT
              PUT ' EINS!!' TO LCD BY A;
            ALT
              PUT ' NULL!!' TO LCD BY A;
            OUT
          FIN;
        FIN;
      END;
    ELSE
      CALL D_CS(28,3);
      PUT BI_DEIN(IND) TO LCD BY B(1);
      IF B_IMPNEU(IND) THEN
        B_IMPNEU(IND)='0'B;
        PUT '*' TO LCD BY A;
      ELSE
        PUT ' ' TO LCD BY A;
      FIN;
      PUT BI_DEINBEW(IND) TO LCD BY B(1);
      CASE Z_DIBEWERT(IND)
        ALT
          PUT '  norm   ' TO LCD BY A;
        ALT
          PUT '  TOGG!! ' TO LCD BY A;
        ALT
          PUT '  EINS!! ' TO LCD BY A;
        ALT
          PUT '  NULL!! ' TO LCD BY A;
        OUT
      FIN;
    FIN;

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

DIGINRAUS: PROC;
  DCL FIX1 FIXED;

  IND=1;
  WHILE IND>0 AND IND<=N_DIGIN REPEAT

    FOR I TO N_DIGIN REPEAT
      CHB(I)=DI_NAME(I);
    END; 
    CALL OBJAUSWAHL('  Digitaleingaenge: ',N_DIGIN,CHB,'DIGINOUT    '); 

    IF IND < 1 OR IND > N_DIGIN THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    PUT '<',BUTT,'  Digitaleingang',IND,':  ' TO LCD BY A,A,A,F(3),A;
    CALL D_CS(1,3);
    PUT DI_NAME(IND) TO LCD BY A;
    CALL D_CS(3, 5);
    PUT 'Betriebsart:     ',BUTT TO LCD BY A,A;
    CASE Z_DIBEWERT(IND)
      ALT
        PUT '  norm                 ' TO LCD BY A;
      ALT
        PUT '  TOGG!! (invertiert)  ' TO LCD BY A;
      ALT
        PUT '  EINS!!               ' TO LCD BY A;
      ALT
        PUT '  NULL!!               ' TO LCD BY A;
      OUT
    FIN;
    N=1;
    WHILE N<2 AND N>0 REPEAT
      CALL D_ROFF;
      CASE N
        ALT  /* Betriebsart   */
          CHB(1)='norm                 ';
          CHB(2)='TOGG!! (invertiert) ';
          CHB(3)='EINS!!               ';
          CHB(4)='NULL!!               ';
          CALL INP_BETRIEB(22,5,CHB,4,Z_DIBEWERT(IND),'DIGINOUT    ');     IF X_R > 3 THEN  N=N-1;  FIN;
        OUT
      FIN;
      CALL LRROT(N);
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        N=X_R-1001;
      FIN;  
    END;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;



/*********************************************************************/
/* Kesselleistungsregelung  <<<<                                       */
/*********************************************************************/
PKESOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_KESSEL THEN
          CALL D_CS(33,Y); Y=Y+1;
          PUT PT_KESAKT(I),'kW' TO LCD BY F(5,1),A;
        FIN;
      END;
    ELSE
      CALL D_CS(2, 6); PUT 'Leistung:  ',PT_KESAKT(IND) TO LCD BY A,F(6);
      CALL D_CS(2, 7); PUT 'Anf-Zeit:',Z_KLZ(IND),    '  Laufz.:',Z_KL(IND) TO LCD BY A,F(8),A,F(6);
      IF IND==3 THEN  /* Biogaskessel  */
        CALL D_CS(2, 8); PUT 'Pu4-Soll:  ',TC_HKSOLL(19),'  Ist:   ',X_AEIN(11) TO LCD BY A,F(6,2),A,F(6,2);
      ELSE
   !    CALL D_CS(2, 8); PUT 'HKVL-Soll: ',TC_VSOLL-0.5,'  Ist:   ',TC_VIST TO LCD BY A,F(6,2),A,F(6,2);
        CALL D_CS(2, 8); PUT 'HKVL-Soll: ',TC_VSOLL-0.0,'  Ist:   ',TC_VIST TO LCD BY A,F(6,2),A,F(6,2);
      FIN;
      CALL D_CS(2, 9); PUT 'KES VL:    ',TC_KV(IND),  '  RL:    ',TC_KR(IND) TO LCD BY A,F(6,2),A,F(6,2);
      CALL D_CS(2,11); PUT 'Regler P: ',RA_KTP(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,12); PUT 'Regler I: ',RA_KTI(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,13); PUT 'Regler D: ',RA_KTDTAU(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,14); PUT 'Summe   : ',RA_KTP(IND)+RA_KTI(IND)+RA_KTDTAU(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,15); PUT 'Ausst.:   ',PT_KSOLL(IND),'%' TO LCD BY A,F(7,2),A;
      CASE IND
        ALT
     !    PUT '  AA:',X_AAUS(1),'%' TO LCD BY A,F(5,1),A;
          CALL D_CS(2,16);
          PUT 'AA Pumpe:',X_AAUS(2),'%' TO LCD BY A,F(7,2),A;
          PUT '  RL Mischer:',Z_KMISTELL(1)/120*100,'%' TO LCD BY A,F(5),A;
          CALL D_CS(2,17);
          PUT 'AA P Max:',(X_AAUSMAX(2)-X_AAUSMIN(2))*0.01*X_AAKMIN(6)+X_AAUSMIN(2),'%' TO LCD BY A,F(7,2),A;
        ALT              
     !    PUT '  AA:',X_AAUS(3),'%' TO LCD BY A,F(5,1),A;
          CALL D_CS(2,16);
          PUT 'AA Pumpe:',X_AAUS(4),'%' TO LCD BY A,F(7,2),A;
          PUT '  RL Mischer:',Z_KMISTELL(2)/120*100,'%' TO LCD BY A,F(5),A;
          CALL D_CS(2,17);
          PUT 'AA P Max:',(X_AAUSMAX(4)-X_AAUSMIN(4))*0.01*X_AAKMIN(7)+X_AAUSMIN(4),'%' TO LCD BY A,F(7,2),A;
        ALT
          PUT '  Stell:',Z_KTHERM(3),'s' TO LCD BY A,F(4),A;
          PUT ' P Anf:' TO LCD BY A;
          IF B_KEIN(3) THEN
            PUT Z_KTHERM(3)/ZF_KSTELL(3)*70.0+30.0,'%' TO LCD BY F(5,1),A;
          ELSE
            PUT Z_KTHERM(3)/ZF_KSTELL(3)*70.0+0.0,'%' TO LCD BY F(5,1),A;
          FIN;
          CALL D_CS(2,16);
          PUT 'RL Mischer:',Z_KMISTELL(3)/120*100,'%' TO LCD BY A,F(5),A;
     !    PUT '  Stufe2: ',B_KST2(1) TO LCD BY A,B(1);
     !    CALL D_CS(2,16);
     !    PUT 'AA Pumpe:',X_AAUS(2),'%' TO LCD BY A,F(7,2),A;
     !    PUT 'PWM Pumpe:',FL_PWMPRO(1),'%' TO LCD BY A,F(7,2),A;
     !    PUT 'RL-Mischer:', Z_KMISTELL(I),'%' TO LCD BY A,F(7,2),A;
     !  ALT
     !    PUT '  AA:',X_AAUS(3),'%' TO LCD BY A,F(5,1),A;
     !    CALL D_CS(2,16);
     !    PUT 'Anst. Pumpe: ',UPE_SOLLST(3)/2.55,'%' TO LCD BY A,F(6,1),A;
        OUT
      FIN;
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;

END;

INP_PKES: PROC;
  DCL K_NAME (10) CHAR(15);

  FOR I TO 10 REPEAT
    K_NAME(I)='Kessel' CAT TOCHAR(I+48);
  END;
  K_NAME(1)='Holzkessel1';
  K_NAME(2)='Holzkessel2';
  K_NAME(3)='Biogaskessel';

  IND=1; 
  WHILE IND > 0 AND IND <= N_KESSEL REPEAT 
    CALL D_CLR;

    FOR I TO N_KESSEL REPEAT
      CHB(I)=K_NAME(I);
    END; 
    CALL OBJAUSWAHL('  Kessel Leistungsregelung:  ',N_KESSEL,CHB,'PKESOUT     '); 

    IF IND < 1 OR IND > N_KESSEL THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Leistungsregelung  ' TO LCD BY A,A,A;
    PUT K_NAME(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT '      P      I           D     TauD(s)' TO LCD BY A,SKIP;
    PUT RP_K(IND),BUTT,RI_K(IND),BUTT,RD_K(IND),BUTT,RTAU_K(IND),BUTT TO LCD BY F(8,1),A,F(9,4),A,F(8,1),A,F(8,1),A,SKIP;

    M=1; /* Eingabepunkt 1-4                                     */
    WHILE M>0 AND M<5 REPEAT
      CASE M
        ALT CALL INP_FLO( 3,4,5,1,0.0   ,99.0,0.1   ,RP_K(IND)  ,'PKESOUT');
        ALT CALL INP_FLO(11,4,7,4,0.0001,99.0,0.0001,RI_K(IND)  ,'PKESOUT');
        ALT CALL INP_FLO(22,4,5,1,0.0   ,99.0,0.1   ,RD_K(IND)  ,'PKESOUT');
        ALT CALL INP_FLO(31,4,5,1,0.1   ,99.0,0.1   ,RTAU_K(IND),'PKESOUT');   IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT bet{tigt ?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-4                                         */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_PKES                                            */



PKESOUT1: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    CALL D_CS(2, 6); PUT 'Leistung:  ',PT_KESAKT(1) TO LCD BY A,F(6);
    CALL D_CS(2, 7); PUT 'Stok1/4h:',Z_STOKVIERT( 8)*0.1,    '  1/4h:',Z_STOKVIERT(10)*0.1 TO LCD BY A,F(8,1),A,F(6);
    CALL D_CS(2, 8); PUT 'K-VL-Soll: ',TC_KVSOLL(6)   TO LCD BY A,F(6,2);
    CALL D_CS(2, 9); PUT 'KES VL:    ',TC_KV(1),  '  RL:    ',TC_KR(1) TO LCD BY A,F(6,2),A,F(6,2);
    CALL D_CS(2,11); PUT 'Regler P: ',RA_KTP(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,12); PUT 'Regler I: ',RA_KTI(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,13); PUT 'Regler D: ',RA_KTDTAU(IND),'%  dRL:',RA_KTDTAU(IND+2) TO LCD BY A,F(7,2),A,F(7,2);
    CALL D_CS(2,14); PUT 'Summe   : ',RA_KTP(IND)+RA_KTI(IND)+RA_KTDTAU(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,15); PUT 'Ausst.:   ',PT_KSOLL(IND),'%' TO LCD BY A,F(7,2),A;

    CALL D_CS(2,16);
    PUT 'AA Pumpe:',X_AAUS(2),'%' TO LCD BY A,F(7,2),A;
    PUT '  RL Mischer:',Z_KMISTELL(1)/120*100,'%' TO LCD BY A,F(5),A;

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;

END;

INP_PKES1: PROC;

  IND=6; 
  WHILE IND > 5 AND IND <= 6 REPEAT 
    CALL D_CLR;

    CALL D_CS(1,1);
    PUT '<',BUTT,'   Erhaltungsregelung  Holzkessel1 ' TO LCD BY A,A,A;
    CALL D_CS(1,3);
    PUT '      P      I           D     TauD(s)' TO LCD BY A,SKIP;
    PUT RP_K(IND),BUTT,RI_K(IND),BUTT,RD_K(IND),BUTT,RTAU_K(IND),BUTT TO LCD BY F(8,1),A,F(9,4),A,F(8,1),A,F(8,1),A,SKIP;

    M=1; /* Eingabepunkt 1-4                                     */
    WHILE M>0 AND M<5 REPEAT
      CASE M
        ALT CALL INP_FLO( 3,4,5,1,0.0   ,99.0,0.1   ,RP_K(IND)  ,'PKESOUT1');
        ALT CALL INP_FLO(11,4,7,4,0.0001,99.0,0.0001,RI_K(IND)  ,'PKESOUT1');
        ALT CALL INP_FLO(22,4,5,1,0.0   ,99.0,0.1   ,RD_K(IND)  ,'PKESOUT1');
        ALT CALL INP_FLO(31,4,5,1,0.1   ,99.0,0.1   ,RTAU_K(IND),'PKESOUT1');   IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT bet{tigt ?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-4                                         */

    EXIT;

  END;

END; /* of PROC INP_PKES                                            */



PKESOUT2: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    CALL D_CS(2, 6); PUT 'Leistung:  ',PT_KESAKT(2) TO LCD BY A,F(6);
    CALL D_CS(2, 7); PUT 'Stok1/4h:',Z_STOKVIERT( 9)*0.1,    '  1/4h:',Z_STOKVIERT(10)*0.1 TO LCD BY A,F(8,1),A,F(6);
    CALL D_CS(2, 8); PUT 'K-VL-Soll: ',TC_KVSOLL(7)   TO LCD BY A,F(6,2);
    CALL D_CS(2, 9); PUT 'KES VL:    ',TC_KV(2),  '  RL:    ',TC_KR(2) TO LCD BY A,F(6,2),A,F(6,2);
    CALL D_CS(2,11); PUT 'Regler P: ',RA_KTP(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,12); PUT 'Regler I: ',RA_KTI(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,13); PUT 'Regler D: ',RA_KTDTAU(IND),'%  dRL:',RA_KTDTAU(IND+2) TO LCD BY A,F(7,2),A,F(7,2);
    CALL D_CS(2,14); PUT 'Summe   : ',RA_KTP(IND)+RA_KTI(IND)+RA_KTDTAU(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,15); PUT 'Ausst.:   ',PT_KSOLL(IND),'%' TO LCD BY A,F(7,2),A;

    CALL D_CS(2,16);
    PUT 'AA Pumpe:',X_AAUS(4),'%' TO LCD BY A,F(7,2),A;
    PUT '  RL Mischer:',Z_KMISTELL(2)/120*100,'%' TO LCD BY A,F(5),A;

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;

END;

INP_PKES2: PROC;

  IND=7; 
  WHILE IND > 6 AND IND <= 7 REPEAT 
    CALL D_CLR;

    CALL D_CS(1,1);
    PUT '<',BUTT,'   Erhaltungsregelung  Holzkessel2 ' TO LCD BY A,A,A;
    CALL D_CS(1,3);
    PUT '      P      I           D     TauD(s)' TO LCD BY A,SKIP;
    PUT RP_K(IND),BUTT,RI_K(IND),BUTT,RD_K(IND),BUTT,RTAU_K(IND),BUTT TO LCD BY F(8,1),A,F(9,4),A,F(8,1),A,F(8,1),A,SKIP;

    M=1; /* Eingabepunkt 1-4                                     */
    WHILE M>0 AND M<5 REPEAT
      CASE M
        ALT CALL INP_FLO( 3,4,5,1,0.0   ,99.0,0.1   ,RP_K(IND)  ,'PKESOUT2');
        ALT CALL INP_FLO(11,4,7,4,0.0001,99.0,0.0001,RI_K(IND)  ,'PKESOUT2');
        ALT CALL INP_FLO(22,4,5,1,0.0   ,99.0,0.1   ,RD_K(IND)  ,'PKESOUT2');
        ALT CALL INP_FLO(31,4,5,1,0.1   ,99.0,0.1   ,RTAU_K(IND),'PKESOUT2');   IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT bet{tigt ?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-4                                         */

    EXIT;

  END;

END; /* of PROC INP_PKES                                            */



/*********************************************************************/
/* Kesselpumpenregelung  <<<<                                        */
/*********************************************************************/
PMPKESOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_KESSEL THEN
          CALL D_CS(33,Y); Y=Y+1;
          PUT XA_KPMP(I),'%' TO LCD BY F(5,1),A;
        FIN;
      END;
    ELSE
      IF TC_KV(IND)-TC_KR(IND) > TD_KMAX(IND) THEN
        CALL D_CS(1, 6); PUT '*akt. Spr.:  ',TC_KV(IND)-TC_KR(IND) TO LCD BY A,F(6,2);
                         PUT '  Max:  ',TD_KMAX(IND) TO LCD BY A,F(5,1);
        CALL D_CS(1, 7); PUT ' Kes VL:     ',TC_KV(IND) TO LCD BY A,F(6,2);
      ELSE
        CALL D_CS(1, 6); PUT ' akt. Spr.:  ',TC_KV(IND)-TC_KR(IND) TO LCD BY A,F(6,2);
                         PUT '  Max:  ',TD_KMAX(IND) TO LCD BY A,F(5,1);
        CALL D_CS(1, 7); PUT '*Kes VL:     ',TC_KV(IND) TO LCD BY A,F(6,2);
      FIN;
                       PUT '  Soll: ',TC_KVSOLL(IND) TO LCD BY A,F(5,1);
      CALL D_CS(2, 8); PUT 'Kes RL:     ',TC_KR(IND)   TO LCD BY A,F(6,2);
      CALL D_CS(2,10); PUT 'Regler P:  ',RA_KPP(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,11); PUT 'Regler I:  ',RA_KPI(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,12); PUT 'Regler D:  ',RA_KPDTAU(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,13); PUT 'Summe   :  ',XA_KPMP(IND),'%' TO LCD BY A,F(7,2),A;
      CASE IND
        ALT
          CALL D_CS(2,14);
          PUT 'Anst. Pumpe: ',UPE_SOLLST(1)/2.55,'%' TO LCD BY A,F(6,1),A;
          PUT '  Pth. ca.:',PT_KESAKT(1) TO LCD BY A,F(6);
        ALT
          CALL D_CS(2,14);
          PUT 'Anst. Pumpe: ',UPE_SOLLST(2)/2.55,'%' TO LCD BY A,F(6,1),A;
          PUT '  Pth. ca.:',PT_KESAKT(2) TO LCD BY A,F(6);
        ALT
          CALL D_CS(2,14);
          PUT 'AA Pumpe:',X_AAUS(1),'%' TO LCD BY A,F(5,1),A;
     !    PUT 'Anst. Pumpe: ',UPE_SOLLST(3)/2.55,'%' TO LCD BY A,F(6,1),A;
          PUT '  Pth. ca.:',PT_KESAKT(3) TO LCD BY A,F(6);
     !  ALT
     !    CALL D_CS(2,14);
     !    PUT 'AA Pumpe:',X_AAUS(1),'%' TO LCD BY A,F(5,1),A;
     !    PUT 'PWM Pumpe:  ',FL_PWMPRO(2),'%' TO LCD BY A,F(6,1),A;
     !    PUT '  Pth. ca.:',PT_KESAKT(2) TO LCD BY A,F(6);
        OUT
      FIN;
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_PMPKES: PROC;
  DCL K_NAME (10) CHAR(15);


  FOR I TO 10 REPEAT
    K_NAME(I)='Kessel' CAT TOCHAR(I+48);
  END;
! K_NAME(1)='Kessel 1.1';

  IND=3; 
  WHILE IND > 0 AND IND <= N_KESSEL REPEAT 
    CALL D_CLR;

  ! FOR I TO N_KESSEL REPEAT
  !   CHB(I)=K_NAME(I);
  ! END; 
  ! CALL OBJAUSWAHL('  Kessel Durchflussregelung:  ',N_KESSEL,CHB,'PMPKESOUT   '); 

    B_EINOBJ='1'B;     /* <<< */
    B_LOOPB='0'B;     /* <<< */

    IF IND < 1 OR IND > N_KESSEL THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Durchflussregelung  ' TO LCD BY A,A,A;
    PUT K_NAME(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT '      P      I          D     TauD(s)' TO LCD BY A,SKIP;
    PUT RP_KP(IND),BUTT,RI_KP(IND),BUTT,RD_KP(IND),BUTT,RTAU_KP(IND),BUTT TO LCD BY F(8,1),A,F(9,4),A,F(8,1),A,F(8,1),A,SKIP;

    M=1; /* Eingabepunkt 1-4                                     */
    WHILE M>0 AND M<5 REPEAT
      CASE M
        ALT CALL INP_FLO( 3,4,5,1,0.0   ,99.0,0.1   ,RP_KP(IND)  ,'PMPKESOUT');
        ALT CALL INP_FLO(11,4,7,4,0.001 ,99.0,0.0001,RI_KP(IND)  ,'PMPKESOUT');
        ALT CALL INP_FLO(22,4,5,1,0.0   ,99.0,0.1   ,RD_KP(IND)  ,'PMPKESOUT');
        ALT CALL INP_FLO(31,4,5,1,0.1   ,99.0,0.1   ,RTAU_KP(IND),'PMPKESOUT');   IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-4                                         */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_PMPKES                                            */



/*********************************************************************/
/* Kesselparameter                                                   */
/*********************************************************************/
INP_KESPAR: PROC;
  DCL K_NAME (10) CHAR(15);

  FOR I TO 10 REPEAT
    K_NAME(I)='Kessel' CAT TOCHAR(I+48);
  END;
  K_NAME(1)='Holzkessel1';
  K_NAME(2)='Holzkessel2';
  K_NAME(3)='Biogaskessel';

  IND=1; 
  WHILE IND > 0 AND IND <= N_KESSEL REPEAT 
    CALL D_CLR;

    FOR I TO N_KESSEL REPEAT
      CHB(I)=K_NAME(I);
    END; 
    CALL OBJAUSWAHL('  Kessel Parameter:  ',N_KESSEL,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_KESSEL THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Parameter   ' TO LCD BY A,A,A;
    PUT K_NAME(IND) TO LCD BY A;
    CALL D_CS(1,2);
    PUT KES_TXT1(IND) TO LCD BY A,SKIP;
    PUT KES_TXT2(IND) TO LCD BY A,SKIP;
    CALL D_CS(1,5);
    PUT 'Leistung(kW):            ',PT_KES(IND),BUTT TO LCD BY A,F(5),A,SKIP;
    PUT 'Pumpennachlauf(s):       ',ZF_KPNL(IND),BUTT TO LCD BY A,F(5),A,SKIP;
    PUT 'Anf. Zeit bis P-Reg(s):  ',ZF_KWARML(IND),BUTT TO LCD BY A,F(5),A,SKIP;
    PUT 'Max VL-Temp (>+4K AUS):  ',TC_KVMAX(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'Max Spreizung(K):        ',TD_KMAX(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'Ueberh. VL-Soll(K):      ',TD_KVLPLUS(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'Mindest RL-Temp:         ',TC_KRMIN(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'MindestAA Betrieb(%):    ',X_AAKMIN(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'Stellzeit P-Reg(s):      ',ZF_KSTELL(IND),BUTT TO LCD BY A,F(5),A,SKIP;
    PUT 'Betriebsstatus:        ' TO LCD BY A;
    IF B_KERLAUBT(IND) THEN
      PUT '  AUTO ',BUTT TO LCD BY A,A,SKIP;
    ELSE
      PUT ' Sperre',BUTT TO LCD BY A,A,SKIP;
    FIN;

    M=1; /* Eingabepunkt 1-8                                     */
    WHILE M>0 AND M<11 REPEAT
      CASE M
        ALT CALL INP_FLO(25, 5,5,0, 5.0   ,9999.0,1.0   ,PT_KES(IND)    ,'LEER');
        ALT CALL INP_FIX(25, 6,5  , 30    ,1800  ,1     ,ZF_KPNL(IND)   ,'LEER'); 
        ALT CALL INP_FIX(25, 7,5  , 30    ,1800  ,1     ,ZF_KWARML(IND) ,'LEER'); 
        ALT CALL INP_FLO(25, 8,5,1,55.0   ,150.0 ,0.1   ,TC_KVMAX(IND)  ,'LEER');
        ALT CALL INP_FLO(25, 9,5,1, 8.0   , 50.0 ,0.1   ,TD_KMAX(IND)   ,'LEER');
        ALT CALL INP_FLO(25,10,5,1,-5.0   , 10.0 ,0.1   ,TD_KVLPLUS(IND),'LEER');
        ALT CALL INP_FLO(25,11,5,1, 5.0   , 80.0 ,0.1   ,TC_KRMIN(IND),'LEER');
        ALT CALL INP_FLO(25,12,5,1, 0.0   ,100.0 ,0.1   ,X_AAKMIN(IND)  ,'LEER');
        ALT CALL INP_FIX(25,13,5  ,  5    ,  60  ,1     ,ZF_KSTELL(IND) ,'LEER'); 
        ALT CALL INP_BIT(24,14,' AUTO ','Sperre',B_KERLAUBT(IND),'LEER');    IF X_R > 3 THEN  M=M-1;  FIN;   
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-8                                         */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_KESPAR                                            */



/*********************************************************************/
/* BHKW Bedienung ueber CAN-Bus (Kraftwerk)                          */
/*********************************************************************/
BHKWBEDIENC: PROC;

  DCL COUNT      FIXED;
  DCL B_NAME (10) CHAR(15);

  FOR I TO 10 REPEAT
    B_NAME(I)='BHKW' CAT TOCHAR(I+48);
  END;
! K_NAME(1)='Kessel 1.1';

  IND=1; 
  WHILE IND > 0 AND IND <= N_BHKW REPEAT 
    CALL D_CLR;

    FOR I TO N_BHKW REPEAT
      CHB(I)=B_NAME(I);
    END; 
    CALL OBJAUSWAHL('  BHKW Bedienung:  ',N_BHKW,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_BHKW THEN  
      EXIT;
    FIN;

    COUNT=0;
 !  CALL CANINIT;
    B_CANREADAKT='1'B;
    IF (B_FERN OR B_PANEL) THEN
      Z_FERN=(IND)*2 + 16384;
    ELSE
      Z_FERN=(IND)*2 + 16384;
 !    Z_FERN=(IND)*2-1 + 16384;
    FIN;
    WHILE Z_FERN > 0 AND COUNT<20 REPEAT
      CALL STICK;
  /*  CALL D_CS(33,15);                     /* <<< */
  /*  PUT 'T: ',X_R TO LCD BY A,F(3);       /* Testausgabe */
  /*  CALL D_CS(33,16);                     /*             */
  /*  PUT 'Z: ',COUNT TO LCD BY A,F(3);     /* <<< */
      IF X_R==3 THEN
        COUNT=COUNT+1;
      ELSE
        COUNT=0;
      FIN;
    END;
    Z_FERN=0;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;


/*********************************************************************/
/* Bedienung Unterstationen ueber CAN-Bus                            */
/*********************************************************************/
BHKWBEDIENC2: PROC;

  DCL ZEILE1     FIXED;
  DCL COUNT      FIXED;

  ZEILE1=2;
  COUNT=0;

  WHILE ZEILE1 > 0 AND X_R/=3 REPEAT
    CALL D_CLR;
    PUT '***  Bedienung Unterstationen        ***' TO LCD BY A,SKIP;
    PUT '     UST1 Haveland                      ' TO LCD BY A,SKIP;
    PUT '     UST2 Verwaltung                    ' TO LCD BY A,SKIP;
    PUT '     UST3 Luch                          ' TO LCD BY A,SKIP;
    CALL D_CS(1,ZEILE1);
    CALL D_RON;
    PUT '>>>>' TO LCD BY A;
    CALL D_ROFF;
    CALL STICK;
    CASE X_R
      ALT /* oben   */
        IF ZEILE1>2 THEN ZEILE1=ZEILE1-1; FIN;
      ALT /* unten  */
        IF ZEILE1<4  THEN ZEILE1=ZEILE1+1; FIN;
      ALT /* links  */
        ZEILE1=0;
        X_R=0;
      ALT /* rechts */
        COUNT=0;
!!      IF B_APWHA(25) THEN
    !     CALL CANINIT;
!!      FIN;
        B_CANREADAKT='1'B;
   !    CALL DISPLAY_MODE( 0(31) ) ;  /* bei SLAVE=Piccolo benutzen, bei SLAVE=MPC auskommentieren */
 !      IF (B_FERN OR B_PANEL) THEN
 ! !        Z_FERN=(ZEILE1+3)*2;   /* 10,12,14,16  */
 !          Z_FERN=(ZEILE1+2)*2;   /* 8,10,12,14,... */
 !      ELSE
            Z_FERN=(ZEILE1+2)*2-1; /* 7,9,11,13,...  */
 !      FIN;
        WHILE Z_FERN > 0 AND COUNT<20 REPEAT
          CALL STICK;
      /*  CALL D_CS(33,15);                     /* <<< */
      /*  PUT 'T: ',X_R TO LCD BY A,F(3);       /* Testausgabe */
      /*  CALL D_CS(33,16);                     /*             */
      /*  PUT 'Z: ',COUNT TO LCD BY A,F(3);     /* <<< */
          IF X_R==3 THEN
            COUNT=COUNT+1;
          ELSE
            COUNT=0;
          FIN;
        END;
        Z_FERN=0;
   !    CALL DISPLAY_MODE( 1(31) ) ;
      OUT /* rot    */
 
    FIN;
  END;

END;


/*********************************************************************/
/* BHKW Betriebsprotokoll Merlin                                     */
/*********************************************************************/
BHKWPROT: TASK PRIO 19;

  DCL X_J FIXED(31);
  DCL X_K FIXED(31);

  CALL D_CLR;

  REPEAT

    CALL D_CS(1,1); 
    Z_BUTTON=0;
    PUT '<',BUTT,' Betriebsprotokoll' TO LCD BY A,A,A;
  ! CALL D_RON;
    PUT ' BHKW ',IND TO LCD BY A,F(1);
  ! CALL D_ROFF;
    CALL D_CS(1,2); PUT ' Neuanford.:',Z_START(IND)
    TO LCD BY A,F(6);
    CALL D_CS(1,4); PUT 'Grund Abschalt.  Laufz.      ZPaus '   TO LCD BY A;

    X_J=ENTIER(Z_BLZ(IND)/3600);
    CALL D_CS(1,3); 
    PUT ' Laufz. aktuell: ',X_J TO LCD BY A,F(4);
    X_K=ENTIER((Z_BLZ(IND)-X_J*3600)/60);
    X_J=Z_BLZ(IND)-X_J*3600-X_K*60;
    PUT ':',X_K,':',X_J TO LCD BY A,F(2),A,F(2);
    FOR I FROM 2 TO 13 REPEAT
      CALL D_CS(1,I+3);
      PUT STR_AUS(IND,I) TO LCD BY A(16);
      X_J=ENTIER(Z_BLAUFZ(IND,I)/3600);
      PUT  X_J TO LCD BY F(4);
      X_K=ENTIER((Z_BLAUFZ(IND,I)-X_J*3600)/60);
      X_J=Z_BLAUFZ(IND,I)-X_J*3600-X_K*60;
      PUT ':',X_K,':',X_J,DAT_BAUS(IND,I),ZP_BAUS(IND,I)
      TO LCD BY A,F(2),A,F(2),F(3),T(9);
    END;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
    
END;




/*********************************************************************/
/* BHKW Parameter                                                    */
/*********************************************************************/
INP_BHKWPAR: PROC;
  DCL B_NAME ( 8) CHAR(15);

  FOR I TO  8 REPEAT
    B_NAME(I)='BHKW' CAT TOCHAR(I+48);
  END;
! B_NAME(1)='BHKW Senertec';

  IND=1; 
  WHILE IND > 0 AND IND <= N_BHKW REPEAT 
    CALL D_CLR;

    FOR I TO N_BHKW REPEAT
      CHB(I)=B_NAME(I);
    END; 
    CALL OBJAUSWAHL('  BHKW Parameter:  ',N_BHKW,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_BHKW THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Parameter   ' TO LCD BY A,A,A;
    PUT B_NAME(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT 'Pel Max(kW):             ',PE_MAXBHKW(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'Pel Min(kW):             ',PE_MINBHKW(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'erl. Pel-Soll(%) 100 -   ',PE_BMINPRO(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'Thermostat VL:           ',TC_BHZGVO(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'Thermostat RL:           ',TC_BHZGRO(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'Mindest VL-Soll:         ',TC_BVLMIN(IND),BUTT TO LCD BY A,F(5,1),A,SKIP;
    PUT 'Pumpennachlauf(s):       ',ZF_BPNL(IND),BUTT TO LCD BY A,F(5),A,SKIP;
    PUT 'Betriebsstatus:        ' TO LCD BY A;
    IF B_BERLAUBT(IND) THEN
      PUT '  AUTO ',BUTT TO LCD BY A,A,SKIP;
    ELSE
      PUT ' Sperre',BUTT TO LCD BY A,A,SKIP;
    FIN;
    PUT 'Wel (Merlin):      ',FL_BKWHGESHZG(IND) TO LCD BY A,F(11,1),SKIP;
    PUT 'Bh (Merlin):        ',FL_BLFZGESHZG(IND),BUTT TO LCD BY A,F(10,1),A,SKIP;
    PUT '(Bh fuer Rangfolge)     ' TO LCD BY A,SKIP;

    M=1; /* Eingabepunkt 1-10                                     */
    WHILE M>0 AND M<11 REPEAT
      CASE M
        ALT CALL INP_FLO(25, 3,5,1, 3.0   , 999.0,0.1   ,PE_MAXBHKW(IND),'LEER');
        ALT CALL INP_FLO(25, 4,5,1, 3.0   , 999.0,0.1   ,PE_MINBHKW(IND),'LEER');
        ALT CALL INP_FLO(25, 5,5,1,30.0   , 100.0,0.1   ,PE_BMINPRO(IND),'LEER');
        ALT CALL INP_FLO(25, 6,5,1,60.0   , 150.0,0.1   ,TC_BHZGVO(IND) ,'LEER');
        ALT CALL INP_FLO(25, 7,5,1,50.0   , 150.0,0.1   ,TC_BHZGRO(IND) ,'LEER');
        ALT CALL INP_FLO(25, 8,5,1, 0.0   , 150.0,0.1   ,TC_BVLMIN(IND) ,'LEER');
        ALT CALL INP_FIX(25, 9,5  , 30    ,1800  ,1     ,ZF_BPNL(IND)   ,'LEER'); 
        ALT CALL INP_BIT(24,10,' AUTO ','Sperre',B_BERLAUBT(IND),'LEER');      
        ALT                
          IF X_ZUGANG ==5 THEN  /* STST */
            CALL INP_F55(19,11,11,1,0.0,99999999.9, 1.0, FL_BKWHGESHZG(IND),'LEER');
          ELSE
            IF X_R > 1000 THEN  X_R=4;  FIN;
          FIN;
        ALT CALL INP_F55(20,12,10,1,0.0,99999999.9, 1.0, FL_BLFZGESHZG(IND),'LEER');  IF X_R > 3 THEN  M=M-1;  FIN; 
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-10                                        */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_BHKWPAR                                          */



/*********************************************************************/
/* BHKW CAN Kommunikation                                            */
/*********************************************************************/
ZEIGB: TASK PRIO 19;

    REPEAT
      CALL D_CS(1,1);
      Z_BUTTON=0;
      PUT '<',BUTT,' Empfangsdaten' TO LCD BY A,A,A;
   !  CALL D_RON;
      PUT ' BHKW',IND,':   ' TO LCD BY A,F(1),A,SKIP;
   !  CALL D_ROFF;
      PUT 'BL:        ',B_BL(IND),
          '   BBEREIT:  ',B_BBEREIT(IND),
          '   BMUSSAUS: ',B_BMUSSAUS(IND)
        TO LCD BY (3)(A,B(1)),SKIP;
      PUT 'BMUSSEIN:  ',B_BMUSSEIN(IND),
          '   WARN:     ',B_BWARN(IND),
          '   Pel:  ',PE_BIST(IND)
        TO LCD BY (2)(A,B(1)),A,F(5,1),SKIP;
      PUT 'MINBHKW: ',PE_MINBHKW(IND),
          ' MAXBHKW:',PE_MAXBHKW(IND),
          ' Pth:  ',PT_BIST(IND)
        TO LCD BY (2)(A,F(5,1)),A,F(5,1),SKIP;
      PUT 'LAUFZ:',FL_BLFZGES(IND),'  KWHel:',FL_BKWHGES(IND)
        TO LCD BY A,F(12,3),A,F(12,3),SKIP;
      PUT 'KWHth:',FL_BTHKWH(IND),'  CANZAEH ',Z_BCAN(IND)
        TO LCD BY A,F(12,3),A,F(5),SKIP;
      PUT 'FEHLNR:  ',Z_FEHLERKRA(IND),
          ' MINAUS: ',Z_MINAUSKRA(IND),
          ' BSTOER: ',B_BSTOER(IND)
        TO LCD BY (2)(A,F(5)),A,B(1),SKIP;
      PUT 'WARNNR:  ',Z_WARNKRA(IND) TO LCD BY A,F(5),SKIP,SKIP;
      PUT ' Sendedaten BHKW',IND,':   ' TO LCD BY A,F(1),A,SKIP;
      PUT 'BEIN:      ',B_BEIN(IND),
          '   PSOLL:   ',PE_BSOLL(IND)
        TO LCD BY A,B(1),A,F(5,1),SKIP;
      PUT 'BPMP:      ',B_BPMP(IND)  TO LCD BY A,B(1),SKIP,SKIP;
      IF B_BEIN(IND) THEN
        PUT 'mit EINGABE ausschalten' TO LCD BY A;
      ELSE
        PUT 'mit EINGABE anfordern  ' TO LCD BY A;
      FIN;

      PUT TO LCD BY SKIP;
      PUT 'Z_SVS: ',Z_SVS(IND) TO LCD BY A,F(4);
      PUT 'Z_BLZ: ',Z_BLZ(IND) TO LCD BY A,F(8);
      BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
      AFTER 2 SEC RESUME;
    END;
    
END;



/*********************************************************************/
/* Eingabe der Heizkurven                                            */
/*********************************************************************/
HKKURVEOUT: TASK PRIO 19;
  DCL PTH  FLOAT;
  DCL Z1   FIXED;
  DCL Z2   FIXED;
  DCL TCV(15) FLOAT;
  DCL AT   FLOAT;
  DCL AT2  FLOAT;
  DCL FL1  FLOAT;


  Z2=0;
  REPEAT

    AT=-12.0;
    IF Z2 > 5 THEN Z2=0; FIN;
    Z2=Z2+1; 
    FOR I TO 14 REPEAT
      IF Z2 REM 5 == 0 OR Z2 REM 6 == 0 THEN
        AT2=AT+TD_ABSHK(IND);
      ELSE
        AT2=AT;
      FIN;

      PTH=80.0        *(TC_HKINENN(IND)-AT2)/
               (TC_HKINENN(IND)-TC_HKANENN(IND));

      IF PTH < 1.0 THEN
        PTH=1.0;
      FIN;

      FL1=15.0;   /* NENNSPREIZUNG FUER FORMEL */
      IF FL1 > (TC_HKVNENN(IND)-TC_HKINENN(IND)) -1.0 THEN
        FL1=(TC_HKVNENN(IND)-TC_HKINENN(IND))-1.0;
      FIN;

      TCV(I)=((FL1 *PTH/80.0        )/(
                       1.0))/(1-EXP((EXP((FL_EXPHK(IND)-1.0)/FL_EXPHK(IND)*
              LN(PTH/80.0        )))/(             1.0)*
              LN(1.0-     FL1 /(TC_HKVNENN(IND)-TC_HKINENN(IND)))))+
              TC_HKINENN(IND);

      IF TCV(I) > TC_HKVNENN(IND) THEN
        TCV(I)=TC_HKVNENN(IND);
      FIN;

      IF TCV(I) < TC_HKVMIN(IND) THEN
        TCV(I)=TC_HKVMIN(IND);
      FIN;

      IF Z2 REM 5 == 0 OR Z2 REM 6 == 0 THEN
        IF AT >= TC_HMN(IND) THEN
          TCV(I)=0.0;
        FIN;
      ELSE
        IF AT >= TC_HMT(IND) THEN
          TCV(I)=0.0;
        FIN;
      FIN;
      AT=AT+3.0;
    END;

    CALL D_CS(2,10);  PUT '  -12: ',TCV( 1),'       9: ',TCV( 8) TO LCD BY A,F(5,1),A,F(5,1); 
    IF Z2 REM 5 == 0 OR Z2 REM 6 == 0 THEN
      PUT ' ABGESENKT' TO LCD BY A; 
    ELSE
      PUT '          ' TO LCD BY A; 
    FIN;
    CALL D_CS(2,11);  PUT '   -9: ',TCV( 2),'      12: ',TCV( 9) TO LCD BY A,F(5,1),A,F(5,1); 
    CALL D_CS(2,12);  PUT '   -6: ',TCV( 3),'      15: ',TCV(10) TO LCD BY A,F(5,1),A,F(5,1); 
    CALL D_CS(2,13);  PUT '   -3: ',TCV( 4),'      18: ',TCV(11) TO LCD BY A,F(5,1),A,F(5,1); 
    CALL D_CS(2,14);  PUT '    0: ',TCV( 5),'      21: ',TCV(12) TO LCD BY A,F(5,1),A,F(5,1); 
    CALL D_CS(2,15);  PUT '    3: ',TCV( 6),'      24: ',TCV(13) TO LCD BY A,F(5,1),A,F(5,1); 
    CALL D_CS(2,16);  PUT '    6: ',TCV( 7),'      27: ',TCV(14) TO LCD BY A,F(5,1),A,F(5,1); 

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_HKKURVE: PROC;
  DCL HK_NAME2 (32) CHAR(20);

  FOR I TO 32 REPEAT
    HK_NAME2(I)=HK_NAME(I);
  END; 

  IND=1; 
  WHILE IND > 0 AND IND <= N_HZKR REPEAT 
    
    FOR I TO N_HZKR REPEAT
      CHB(I)=HK_NAME2(I);
    END; 
    CALL OBJAUSWAHL('  Heizkurven Heizkreise: ',N_HZKR,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_HZKR THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    PUT '<',BUTT,'         ',HK_NAME2(IND) TO LCD BY A,A,A,A,SKIP;
    PUT 'Nennvorlauf:   ',TC_HKVNENN(IND),BUTT,'  Mindestvorl.:  ',TC_HKVMIN(IND),BUTT  TO LCD BY A,F(4),A,A,F(4),A,SKIP;
    PUT 'Tagheizgrenze: ',TC_HMT(IND),BUTT,    '  Nachtheizgr.: ',TC_HMN(IND),BUTT      TO LCD BY A,F(4,1),A,A,F(5,1),A,SKIP,SKIP;
    PUT 'Nennraumtemp.: ',TC_HKINENN(IND),BUTT,'  Nennaussen:   ',TC_HKANENN(IND),BUTT  TO LCD BY A,F(4,1),A,A,F(5,1),A,SKIP;
    PUT 'Exponent:      ',FL_EXPHK(IND),BUTT,  '  Absenkung um:  ',TD_ABSHK(IND),BUTT   TO LCD BY A,F(4,1),A,A,F(4,1),A,SKIP;
    PUT 'STW HK VL:     ',TC_HKSTW(IND),BUTT                                            TO LCD BY A,F(4),A;

    M=1; /* Eingabepunkt 1-9                                     */
    WHILE M>0 AND M<10 REPEAT
      CASE M
        ALT CALL INP_FLO(15,2,4,0,TC_HKINENN(IND)+ 2.0,99.0,1.0,TC_HKVNENN(IND),'HKKURVEOUT');
        ALT CALL INP_FLO(37,2,4,0,20.0,99.0,1.0,TC_HKVMIN(IND),'HKKURVEOUT');
        ALT CALL INP_FLO(15,3,4,1,8.0,50.0,0.1,TC_HMT(IND),'HKKURVEOUT');
        ALT CALL INP_FLO(36,3,5,1,-20.0,50.0,0.1,TC_HMN(IND),'HKKURVEOUT');
        ALT CALL INP_FLO(15,5,4,1,5.0,TC_HKVNENN(IND)- 2.0,0.1,TC_HKINENN(IND),'HKKURVEOUT');
        ALT CALL INP_FLO(36,5,5,1,-20.0,30.0,0.1,TC_HKANENN(IND),'HKKURVEOUT');
        ALT CALL INP_FLO(15,6,4,1,0.2,4.0,0.1,FL_EXPHK(IND),'HKKURVEOUT');
        ALT CALL INP_FLO(37,6,4,1,1.0,15.0,0.1,TD_ABSHK(IND),'HKKURVEOUT');
        ALT CALL INP_FLO(15,7,4,0,10.0,300.0,1.0,TC_HKSTW(IND),'HKKURVEOUT');   IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder EINGABE ?             */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-9                                         */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;
  Z_HMNEU=0;

END; /* of PROC INP_HKKURVE                                          */



/*********************************************************************/
/* Heizkreiswochenkalender                                           */
/*********************************************************************/
WOCHOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      CALL D_CS(32,2);
      PUT 'aktuell:' TO LCD BY A;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_HZKR THEN
          CALL D_CS(33,Y); Y=Y+1;
          IF B_ABSHK(I) THEN
            PUT 'Nachtbetrieb' TO LCD BY A;
          ELSE
            PUT 'Tagbetrieb  ' TO LCD BY A;
          FIN;
        FIN;
      END;
    FIN;
    AFTER 2 SEC RESUME;
  END;
END;

HKZON: PROC;
  DCL HK_NAME2 (32) CHAR(30);
  DCL F15 FIXED;

  FOR I TO 32 REPEAT
    HK_NAME2(I)=HK_NAME(I);
  END;
! HK_NAME2( 4)=' Fernwaerme    ';
! HK_NAME2( 5)=' HK5 Lueft +(Anf DI15)';
! HK_NAME2( 6)=' Hallenbad +(Anf DI16)';
! HK_NAME2( 7)=' Freibad   +(Anf DI17)';

  IND=1; 
  WHILE IND > 0 AND IND <= N_HZKR REPEAT 

    FOR I TO N_HZKR REPEAT
      CHB(I)=HK_NAME2(I);
    END; 

    CALL OBJAUSWAHL('  Heizkreise Absenkung Wochenkalender: ',N_HZKR,CHB,'WOCHOUT     '); 

    IF IND < 1 OR IND > N_HZKR THEN  
      EXIT;
    FIN;

    IF IND==99 OR IND==98 THEN
    ELSE
      CALL INP_ABS(IND,3);
    FIN;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;



/*********************************************************************/
/* Heizkreisjahreskalender                                           */
/*********************************************************************/
JAHROUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      CALL D_CS(32,2);
      PUT 'aktuell:' TO LCD BY A;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_HZKR THEN
          CALL D_CS(33,Y); Y=Y+1;
          IF B_JAHRAB(DA_MON,DA_DAT).BIT(I) THEN
            PUT 'Nachtbetrieb' TO LCD BY A;
          ELSE
            PUT 'Tagbetrieb  ' TO LCD BY A;
          FIN;
        FIN;
      END;
    FIN;
    AFTER 2 SEC RESUME;
  END;
END;

INP_JAHR: PROC;

  DCL (MON,TAG,MONVOR) FIXED;
  DCL HK_NAME2 (32) CHAR(30);
  DCL F15 FIXED;

  FOR I TO 32 REPEAT
    HK_NAME2(I)=HK_NAME(I);
  END;
! HK_NAME2( 4)=' Fernwaerme    ';
! HK_NAME2(14)=HK_NAME(I) CAT '(Anf. DI19)';

  IND=1; 
  WHILE IND > 0 AND IND <= N_HZKR REPEAT 

    FOR I TO N_HZKR REPEAT
      CHB(I)=HK_NAME2(I);
    END; 

    CALL OBJAUSWAHL('  Heizkreise Absenkung Jahreskalender: ',N_HZKR,CHB,'JAHROUT     '); 

    IF IND < 1 OR IND > N_HZKR THEN  
      EXIT;
    FIN;

    MON=DA_MON;
    TAG=DA_DAT;
    CALL D_CLR;
    CALL D_CS(1,1);
    Z_BUTTON=0;
    PUT '<',BUTT,'  1   5    10   15   20   25   30' TO LCD BY A,A,A,SKIP;
    FOR I TO 12 REPEAT
      CALL D_CS(1,I+1);
      CASE I 
        ALT PUT 'JAN' TO LCD BY A;
        ALT PUT 'FEB' TO LCD BY A;
        ALT PUT 'MAR' TO LCD BY A;
        ALT PUT 'APR' TO LCD BY A;
        ALT PUT 'MAI' TO LCD BY A;
        ALT PUT 'JUN' TO LCD BY A;
        ALT PUT 'JUL' TO LCD BY A;
        ALT PUT 'AUG' TO LCD BY A;
        ALT PUT 'SEP' TO LCD BY A;
        ALT PUT 'OKT' TO LCD BY A;
        ALT PUT 'NOV' TO LCD BY A;
        ALT PUT 'DEZ' TO LCD BY A;
      FIN;
      FOR K TO 31 REPEAT
        CALL D_CS(K+4,I+1);
        IF B_JAHRAB(I,K).BIT(IND) THEN
          PUT '.' TO LCD BY A;
        ELSE
          PUT '-' TO LCD BY A;
        FIN;
      END;
    END;

    WHILE MON<13 AND MON>0 REPEAT
      CALL D_ROFF;
      CALL D_CS(1,14);
      PUT HK_NAME2(IND),' am ',TAG,'.',MON,'.'
         TO LCD BY A(20),A,F(2),A,F(2),A;
      IF B_JAHRAB(MON,TAG).BIT(IND) THEN
        PUT '  Nachtbetrieb  ' TO LCD BY A;
      ELSE
        PUT '  Tagbetrieb    ' TO LCD BY A;
      FIN;
      CALL D_CS(TAG+4,MON+1);
      CALL D_RON;
      IF B_JAHRAB(MON,TAG).BIT(IND) THEN
        PUT '.' TO LCD BY A;
      ELSE
        PUT '-' TO LCD BY A;
      FIN;
      CALL STICK;
      CALL D_CS(TAG+4,MON+1);
      CALL D_ROFF;
      IF B_JAHRAB(MON,TAG).BIT(IND) THEN
        PUT '.' TO LCD BY A;
      ELSE
        PUT '-' TO LCD BY A;
      FIN;
      CASE X_R
        ALT /* oben  */ MON=MON-1;
        ALT /* unten */ MON=MON+1;
        ALT /* links */ TAG=TAG-1;
        ALT /* rechts*/ TAG=TAG+1;
        ALT /* rot   */ 
          IF B_ROTSP AND X_ZUGANG < 1 THEN   /* STST */
            CALL INP_ROTSP;
         !  IND=0;
         !  M=0;
         !  N=0;
         !  B_WEITER='1'B;
         !  X_R=3;
         !  EXIT;
          ELSE
            B_JAHRAB(MON,TAG).BIT(IND)=NOT B_JAHRAB(MON,TAG).BIT(IND);
            CALL D_CS(TAG+4,MON+1);
            IF NOT (B_FERN OR B_PANEL) THEN 
              CALL D_RON;
            FIN; 
            IF B_JAHRAB(MON,TAG).BIT(IND) THEN
              PUT '.' TO LCD BY A;
            ELSE
              PUT '-' TO LCD BY A;
            FIN;
          FIN;
          TAG=TAG+1;
          CALL D_CS(TAG+4,MON+1);
        OUT
          IF X_R > 1000 THEN  /* BUTTON */
            MON=0;
          FIN;
      FIN;
      IF TAG<1 THEN
        MON=MON-1;
        TAG=31;
      FIN;
      IF TAG>31 THEN
        MON=MON+1;
        TAG=1;
      FIN;
    END;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;


END; /* Ende INP_JAHR                                                */


/*********************************************************************/
/* Jahreskal. HZG-AUS bei AT > 3                                     */
/*********************************************************************/
INP_JAHR2: PROC;

  DCL (MON,TAG,MONVOR) FIXED;

  M=32;
  MON=DA_MON;
  TAG=DA_DAT;
  CALL D_CLR;
  CALL D_CS(1,1);
  Z_BUTTON=0;
  PUT '<',BUTT,'  1   5    10   15   20   25   30' TO LCD BY A,A,A,SKIP;
  FOR I TO 12 REPEAT
    CALL D_CS(1,I+1);
    CASE I 
      ALT PUT 'JAN' TO LCD BY A;
      ALT PUT 'FEB' TO LCD BY A;
      ALT PUT 'MAR' TO LCD BY A;
      ALT PUT 'APR' TO LCD BY A;
      ALT PUT 'MAI' TO LCD BY A;
      ALT PUT 'JUN' TO LCD BY A;
      ALT PUT 'JUL' TO LCD BY A;
      ALT PUT 'AUG' TO LCD BY A;
      ALT PUT 'SEP' TO LCD BY A;
      ALT PUT 'OKT' TO LCD BY A;
      ALT PUT 'NOV' TO LCD BY A;
      ALT PUT 'DEZ' TO LCD BY A;
    FIN;
    FOR K TO 31 REPEAT
      CALL D_CS(K+4,I+1);
      IF B_JAHRAB(I,K).BIT(M) THEN
        PUT '.' TO LCD BY A;
      ELSE
        PUT '-' TO LCD BY A;
      FIN;
    END;
  END;

  WHILE MON<13 AND MON>0 REPEAT
    CALL D_ROFF;
    CALL D_CS(1,14);
    PUT 'Zustand Heizung  am ',TAG,'.',MON,'.' TO LCD BY A,F(2),A,F(2),A;
    IF B_JAHRAB(MON,TAG).BIT(M) THEN
      PUT '  AUS bei AT > 3' TO LCD BY A;
    ELSE
      PUT '  Normalbetrieb ' TO LCD BY A;
    FIN;
    CALL D_CS(TAG+4,MON+1);
    CALL D_RON;
    IF B_JAHRAB(MON,TAG).BIT(M) THEN
      PUT '.' TO LCD BY A;
    ELSE
      PUT '-' TO LCD BY A;
    FIN;
    CALL STICK;
    CALL D_CS(TAG+4,MON+1);
    CALL D_ROFF;
    IF B_JAHRAB(MON,TAG).BIT(M) THEN
      PUT '.' TO LCD BY A;
    ELSE
      PUT '-' TO LCD BY A;
    FIN;
    CASE X_R
      ALT /* oben  */ MON=MON-1;
      ALT /* unten */ MON=MON+1;
      ALT /* links */ TAG=TAG-1;
      ALT /* rechts*/ TAG=TAG+1;
      ALT /* rot   */ 
        IF B_ROTSP AND X_ZUGANG < 1 THEN   /* STST */
          CALL INP_ROTSP;
        ELSE
          B_JAHRAB(MON,TAG).BIT(M)=NOT B_JAHRAB(MON,TAG).BIT(M);
          CALL D_CS(TAG+4,MON+1);
          IF NOT (B_FERN OR B_PANEL) THEN 
            CALL D_RON;
          FIN; 
          IF B_JAHRAB(MON,TAG).BIT(M) THEN
            PUT '.' TO LCD BY A;
          ELSE
            PUT '-' TO LCD BY A;
          FIN;
        FIN;
        TAG=TAG+1;
        CALL D_CS(TAG+4,MON+1);
      OUT
        IF X_R > 1000 THEN  /* BUTTON */
          MON=0;
        FIN;
    FIN;
    IF TAG<1 THEN
      MON=MON-1;
      TAG=31;
    FIN;
    IF TAG>31 THEN
      MON=MON+1;
      TAG=1;
    FIN;
  END;


END; /* Ende INP_JAHR2                                                */



/***************************************************************************/
/* HK Pumpenregelung  <<<<                                                 */
/***************************************************************************/
HKREGOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_HZKR THEN
          CALL D_CS(33,Y); Y=Y+1;
          PUT XA_HKP(I),'%' TO LCD BY F(5,1),A;
        FIN;
      END;
    ELSE
  !   CALL D_CS(2, 8); PUT '                Soll %   dP mWS  ' TO LCD BY A;
      CALL D_CS(2, 8); PUT '                     Soll %      ' TO LCD BY A;
  !   CALL D_CS(2, 9); PUT 'P1 HK 1+2 OG',X_AAUS(2)           TO LCD BY A,F(7,1);
  !   CALL D_CS(2,10); PUT 'P2 HK 1+2 OG',X_AAUS(3)           TO LCD BY A,F(7,1);
  !   CALL D_CS(2,11); PUT 'P1 HK EG    ',X_AAUS(4)           TO LCD BY A,F(7,1);
  !   CALL D_CS(2,12); PUT 'P2 HK EG    ',X_AAUS(5)           TO LCD BY A,F(7,1);
  !   CALL D_CS(2,13); PUT 'P1 HK 3-6 OG',X_AAUS(6)           TO LCD BY A,F(7,1);
  !   CALL D_CS(2,14); PUT 'P2 HK 3-6 OG',X_AAUS(7)           TO LCD BY A,F(7,1);
  !   CALL D_CS(2,15); PUT 'PMP Fernw.  ',X_AAUS(1)           TO LCD BY A,F(7,1);

  !   CALL D_CS(2, 9); PUT HK_NAME(IND),UPE_SOLLST(IND+8)/2.55        TO LCD BY A,F(7,1);

      CALL D_CS(2, 9); PUT HK_NAME(1),X_AAUS( 6)    TO LCD BY A,F(9,1);
      CALL D_CS(2,10); PUT HK_NAME(2),X_AAUS( 7)    TO LCD BY A,F(9,1);
      CALL D_CS(2,11); PUT HK_NAME(3),X_AAUS( 8)    TO LCD BY A,F(9,1);

  !   CALL D_CS(2, 9); PUT 'Pumpe1 HK1         ',UPE_SOLLST( 2)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2,10); PUT 'Pumpe2 HK1         ',UPE_SOLLST( 3)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2,11); PUT 'Pumpe1 HK2         ',UPE_SOLLST( 4)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2,12); PUT 'Pumpe2 HK2         ',UPE_SOLLST( 5)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2, 9); PUT HK_NAME(1),UPE_SOLLST( 2)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2,10); PUT HK_NAME(2),UPE_SOLLST( 3)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2,11); PUT HK_NAME(3),UPE_SOLLST( 4)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2,12); PUT HK_NAME(4),UPE_SOLLST( 5)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2,13); PUT HK_NAME(5),UPE_SOLLST( 6)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2,12); PUT ' HK4 Neubau sekund. ',UPE_SOLLST( 6)/2.55        TO LCD BY A,F(7,1);
  !   CALL D_CS(2,13); PUT HK_NAME(6),UPE_SOLLST( 9)/2.55        TO LCD BY A,F(7),F(9,1);
  !   CALL D_CS(2,14); PUT HK_NAME(7),UPE_SOLLST(10)/2.55        TO LCD BY A,F(7),F(9,1);
  !   CALL D_CS(2,12); PUT HK_NAME(4),UPE_SOLLST(5),UPE_PRO(5)  TO LCD BY A,F(7),F(9,1);
  !   CALL D_CS(2, 9); PUT ' Netzpumpe    ',UPE_SOLLST(3),UPE_PRO(3)  TO LCD BY A,F(7),F(9,1);
  !   CALL D_CS(2, 9); PUT HK_NAME(1),FL_PWMPRO( 2) TO LCD BY A,F(9,1);
  !   CALL D_CS(2, 9); PUT 'Pumpe1 HK1  ',UPE_SOLLST(4)/2.55,X_AEIN(27),X_AAUSMIN(41)  TO LCD BY A,F(7,1),F(9,1),F(6,1);
  !   CALL D_CS(2,10); PUT 'Pumpe2 HK1  ',UPE_SOLLST(5)/2.55,X_AEIN(27)  TO LCD BY A,F(7,1),F(9,1);
      CALL D_CS(2,16); PUT ' Aussent.:',TC_AUSSEN TO LCD BY A,F(6,2);
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_HKREG: PROC;
  DCL HK_NAME2 (32) CHAR(20);
  DCL FL1 FLOAT;

  FOR I TO 32 REPEAT
    HK_NAME2(I)=HK_NAME(I);
  END;
! HK_NAME2( 4)=' Fernwaerme    ';

! IND=1; 
! WHILE IND > 0 AND IND <=  1     REPEAT 
  IND=1; 
  WHILE IND > 0 AND IND <= N_HZKR REPEAT 
    
    FOR I TO N_HZKR REPEAT
      CHB(I)=HK_NAME2(I);
    END; 
    CALL OBJAUSWAHL('   Heizkreis-Pumpenregelung: ',N_HZKR,CHB,'HKREGOUT'); 
   
    IF IND < 1 OR IND > N_HZKR THEN  
      EXIT;
    FIN;

  ! FOR I FROM 1 TO  1     REPEAT
  !   CHB(I)=HK_NAME2(I);
  ! END; 
  ! CALL OBJAUSWAHL('   Heizkreis-Pumpenregelung: ', 1    ,CHB,'LEER        '); 
  !
  !
  ! IF IND < 1 OR IND >  1     THEN  
  !   EXIT;
  ! FIN;

    CALL D_CLR;
    PUT '<',BUTT,'         ',HK_NAME2(IND) TO LCD BY A,A,A,A,SKIP,SKIP;

    IF IND < 16 THEN
      PUT '   Pumpensoll (%) bei   ' TO LCD BY A,SKIP;
    ELSE
      PUT '   Solldruck in mWS bei ' TO LCD BY A,SKIP;
    FIN;
    PUT '   AT=20      AT=5       AT=-10 ',
        FL_SOLLAT20(IND),BUTT,FL_SOLLAT5(IND),BUTT,FL_SOLLATM10(IND),BUTT
       TO LCD BY A,SKIP,F(8,1),A,F(9,1),A,F(11,1),A;


    M=1; /* Eingabepunkt 1-3                                     */
    WHILE M>0 AND M<4 REPEAT
      CASE M
        ALT CALL INP_FLO(3,5,5,1,0.0,100.0,0.1,FL_SOLLAT20(IND),'HKREGOUT');
        ALT CALL INP_FLO(13,5,5,1,0.0,100.0,0.1,FL_SOLLAT5(IND),'HKREGOUT');
        ALT CALL INP_FLO(25,5,5,1,0.0,100.0,0.1,FL_SOLLATM10(IND),'HKREGOUT');    IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-3                                         */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;




/***************************************************************************/
/* HK Mischerregelung                                                      */
/***************************************************************************/
HKMIOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
  !     IF I <= N_HZKR THEN
        IF I <=   4    THEN
          CALL D_CS(33,Y); Y=Y+1;
          PUT XA_HKMI(I),'%' TO LCD BY F(5,1),A;
        FIN;
      END;
    ELSE
      CALL D_CS(1,6);
      IF IND==4 OR IND==7 THEN  /* <<< */
        IF IND==4 THEN
          PUT 'Zuluft-Soll: ',TC_HKSOLLGES(4) TO LCD BY A,F(5,1),SKIP;
          PUT 'Zuluft-Ist:  ',X_AEIN(21) TO LCD BY A,F(5,1),SKIP;
        FIN;
   !    IF IND==7 THEN
   !      PUT 'VL-Soll: ',TC_HKSOLLGES(22) TO LCD BY A,F(5,1),SKIP;
   !      PUT 'VL-Ist:  ',X_AEIN(44) TO LCD BY A,F(5,1),SKIP;
   !      PUT 'Bad-RL:  ',X_AEIN(45) TO LCD BY A,F(5,1),SKIP;
   !    FIN;
      ELSE
        PUT 'VL-Soll: ',TC_HKSOLLGES(IND) TO LCD BY A,F(5,1);
        PUT '  (Integr.: ',TD_HKINT(IND),')' TO LCD BY A,F(6,3),A,SKIP;
        PUT 'VL-Ist:  ',TC_HKIST(IND) TO LCD BY A,F(5,1);
        IF TC_ATTAU < TC_AUSSEN THEN
          PUT '  (AT-Reg.: ',TC_ATTAU,')' TO LCD BY A,F(6,3),A,SKIP;
        ELSE
          PUT '  (AT-Reg.: ',TC_AUSSEN,')' TO LCD BY A,F(6,3),A,SKIP;
        FIN;
        PUT 'HK-RL:   ',TC_HKR(IND) TO LCD BY A,F(5,1),SKIP;
      FIN;
  
      CALL D_CS(2,10); PUT 'Regler P:  ',RA_MP(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,11); PUT 'Regler I:  ',RA_MI(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,12); PUT 'Regler D:  ',RA_MDTAU(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,13); PUT 'Summe   :  ',XA_HKMI(IND),'%' TO LCD BY A,F(7,2),A;
      CALL D_CS(2,14); PUT 'Position Mischer:  ',100.0*Z_HKMISTELL(IND)/ZF_HKMISTELL(IND),'%' TO LCD BY A,F(7,1),A;
      CASE IND
        ALT
     !    CALL D_CS(2,15);
     !    PUT 'AA Mischer: ',X_AAUS(6),'%' TO LCD BY A,F(5,1),A;
        ALT
        ALT
     !    CALL D_CS(2,15);
     !    PUT 'AA Mischer: ',X_AAUS(3),'%' TO LCD BY A,F(5,1),A;
        ALT
          CALL D_CS(2,15);
          PUT 'AA Luefter: ',X_AAUS(5),'%' TO LCD BY A,F(5,1),A;
        ALT
     !    CALL D_CS(2,15);
     !    PUT 'AA Mischer: ',X_AAUS(5),'%' TO LCD BY A,F(5,1),A;
        ALT
        ALT
        ALT
          CALL D_CS(2,15);
          PUT 'PMP prim.:  ',UPE_SOLLST( 5)/2.55,'%' TO LCD BY A,F(5,1),A;
        ALT
     !  ALT
     !    CALL D_CS(2,15);
     !    PUT 'AA Mischer: ',X_AAUS(4),'%' TO LCD BY A,F(5,1),A;
        OUT
      FIN;
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_HKMI: PROC;
  DCL HK_NAME2 (32) CHAR(20);

  FOR I TO 32 REPEAT
    HK_NAME2(I)=HK_NAME(I);
  END;
  HK_NAME2( 4)=' Zuluft Trockn.';


  IND=1; 
! WHILE IND > 0 AND IND <= N_HZKR REPEAT 
  WHILE IND > 0 AND IND <=   4    REPEAT 
    
  ! FOR I TO N_HZKR REPEAT
  !   CHB(I)=HK_NAME2(I);
  ! END; 
  ! CALL OBJAUSWAHL('  Heizkreise Vorlaufregelung: ',N_HZKR,CHB,'HKMIOUT     '); 
  !
  ! IF IND < 1 OR IND > N_HZKR THEN  
  !   EXIT;
  ! FIN;

    FOR I TO   4    REPEAT
      CHB(I)=HK_NAME2(I);
    END; 
    CALL OBJAUSWAHL('  Heizkreise Vorlaufregelung: ',  4   ,CHB,'HKMIOUT     '); 

    IF IND < 1 OR IND >   4    THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Vorlaufregelung  ' TO LCD BY A,A,A;
    PUT HK_NAME2(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT '      P      I         D     TauD(s)' TO LCD BY A,SKIP;
    PUT RP_M(IND),BUTT,RI_M(IND),BUTT,RD_M(IND),BUTT,RTAU_M(IND),BUTT TO LCD BY F(8,1),A,F(9,4),A,F(7,1),A,F(8,1),A,SKIP;

    M=1; /* Eingabepunkt 1-4                                     */
    WHILE M>0 AND M<5 REPEAT
      CASE M
        ALT CALL INP_FLO( 3,4,5,1,0.0    ,99.0,0.1    ,RP_M(IND)  ,'HKMIOUT');
        ALT CALL INP_FLO(11,4,7,4,0.0001 ,99.0,0.0001 ,RI_M(IND)  ,'HKMIOUT');
        ALT CALL INP_FLO(21,4,5,1,0.0    ,99.0,0.1    ,RD_M(IND)  ,'HKMIOUT');
        ALT CALL INP_FLO(30,4,5,1,0.1    ,99.0,0.1    ,RTAU_M(IND),'HKMIOUT');    IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT bet{tigt ?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-4                                         */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_HKMI                                              */




/***************************************************************************/
/* Heizkreisparameter                                                      */
/***************************************************************************/
INP_HKPAR: PROC;
  DCL HK_NAME2 (32) CHAR(20);
  DCL ETAST         FIXED; 

  FOR I TO 32 REPEAT
    HK_NAME2(I)=HK_NAME(I);
  END;
! HK_NAME2( 8)=' Nahwaermenetz ';

  IND=1; 
  WHILE IND > 0 AND IND <= N_HZKR REPEAT 
   
 !  FOR I TO  4     REPEAT
    FOR I TO N_HZKR REPEAT
      CHB(I)=HK_NAME2(I);
    END; 
    CALL OBJAUSWAHL('   Heizkreisparameter:  ',N_HZKR,CHB,'LEER        '); 
 !  CALL OBJAUSWAHL('   Heizkreisparameter:  ', 4    ,CHB,'LEER        '); 

 !  IF IND < 1 OR IND >  4     THEN  
    IF IND < 1 OR IND > N_HZKR THEN  
      EXIT;
    FIN;

    AGAIN:
    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Parameter  ' TO LCD BY A,A,A;
    PUT HK_NAME2(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT 'Stellzeit Mischer(s):    ',BUTT,ZF_HKMISTELL(IND) TO LCD BY A,A,F(8),SKIP;
    PUT 'Langfr. Integrator MAX:  ',BUTT,TD_HKINTMAX(IND) TO LCD BY A,A,F(8,1),SKIP;
    PUT 'Langfr. Integrator MIN:  ',BUTT,TD_HKINTMIN(IND) TO LCD BY A,A,F(8,1),SKIP;
    PUT 'Bezeichnung HK:          ' TO LCD BY A,SKIP;
    PUT '               ',BUTT,'   ',HK_NAME(IND) TO LCD BY A,A,A,A;

    M=1; 
    WHILE M>0 AND M<24 REPEAT
      CASE M
        ALT CALL INP_FIX(29, 3,5  ,  20,240 ,1  ,ZF_HKMISTELL(IND),'LEER'); 
        ALT CALL INP_FLO(29, 4,5,1, 0.0,10.0,0.1,TD_HKINTMAX(IND),'LEER');
        ALT CALL INP_FLO(29, 5,5,1,-5.0, 0.0,0.1,TD_HKINTMIN(IND),'LEER');
        OUT
          ETAST=0;
          WHILE M>3 AND M<24 REPEAT
            CALL INP_CHAR(16+M, 7,HK_NAME(IND).CHAR(M-3),'LEER',ETAST);
            HK_NAME2(IND).CHAR(M-3)=HK_NAME(IND).CHAR(M-3);
            CALL LRROT(M);
            IF X_R==10 THEN  M=24;  FIN;
          END;
          GOTO AGAIN;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE                                             */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_HKPAR                                          */



/*********************************************************************/
/* Estrichtrocknung                                                  */
/*********************************************************************/
ESTRICHOUT: TASK PRIO 19;
  DCL Y FIXED;
  
  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_HZKR THEN
          CALL D_CS(33,Y); Y=Y+1;
          PUT F_ESTRICH(I,21)/1440.0,'Tage' TO LCD BY F(5,2),A;
        FIN;
      END;
    ELSE
      CALL D_CS(1,16);
      IF F_ESTRICH(IND,21) > 0.01 THEN
        PUT 'Laeuft noch',F_ESTRICH(IND,21)/1440.0,' Tage  Akt. Soll:',TC_HKSOLL(IND) TO LCD BY A,F(7,3),A,F(3);
      ELSE
        PUT 'Laeuft nicht                           ' TO LCD BY A;
      FIN;
    FIN;    
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

ESTRICHTROCK: PROC;
  DCL HK_NAME2 (32) CHAR(20);
  DCL LOOP          BIT(1);

  FOR I TO 32 REPEAT
    HK_NAME2(I)=HK_NAME(I);
  END;
! HK_NAME2( 8)=' Nahwaermenetz ';

  IND=1; 
  WHILE IND > 0 AND IND <= N_HZKR REPEAT 
   
 !  FOR I TO  4     REPEAT
    FOR I TO N_HZKR REPEAT
      CHB(I)=HK_NAME2(I);
    END; 
    CALL OBJAUSWAHL('   Estrichtrocknung:   ',N_HZKR,CHB,'ESTRICHOUT  '); 

 !  IF IND < 1 OR IND >  4     THEN  
    IF IND < 1 OR IND > N_HZKR THEN  
      EXIT;
    FIN;

    AGAIN:
    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Estrichtrocknung' TO LCD BY A,A,A,SKIP;
    PUT '      ',HK_NAME2(IND) TO LCD BY A,A;
    CALL D_CS(1,3);
    PUT '   (bei Soll=0 -> STOP Estrichtr.)' TO LCD BY A;
   
    FOR I TO 10 REPEAT
      CALL D_CS(1,I+3);                                      
      PUT 'Tag',I,' Soll:',F_ESTRICH(IND,I),BUTT TO LCD BY A,F(2),A,F(6),A;
    END;
    FOR I TO 10 REPEAT
      CALL D_CS(21,I+3);                                      
      PUT 'Tag',I+10,' Soll:',F_ESTRICH(IND,I+10),BUTT TO LCD BY A,F(2),A,F(6),A;
    END;

    CALL D_CS(1,14);                                      
    IF F_ESTRICH(IND,21) > 0.01 THEN
      LOOP='1'B;
      PUT 'Betrieb:    JA   ',BUTT TO LCD BY A,A;
    ELSE
      LOOP='0'B;
      PUT 'Betrieb:   NEIN  ',BUTT TO LCD BY A,A;
    FIN;    

    M=1; 
    WHILE M>0 AND M<22 REPEAT
      CASE M
          
        ALT                                                   /* */
          CALL INP_FLO(12, 4,5,0,0.0,80.0, 1.0, F_ESTRICH(IND, 1),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(12, 5,5,0,0.0,80.0, 1.0, F_ESTRICH(IND, 2),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(12, 6,5,0,0.0,80.0, 1.0, F_ESTRICH(IND, 3),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(12, 7,5,0,0.0,80.0, 1.0, F_ESTRICH(IND, 4),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(12, 8,5,0,0.0,80.0, 1.0, F_ESTRICH(IND, 5),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(12, 9,5,0,0.0,80.0, 1.0, F_ESTRICH(IND, 6),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(12,10,5,0,0.0,80.0, 1.0, F_ESTRICH(IND, 7),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(12,11,5,0,0.0,80.0, 1.0, F_ESTRICH(IND, 8),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(12,12,5,0,0.0,80.0, 1.0, F_ESTRICH(IND, 9),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(12,13,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,10),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32, 4,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,11),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32, 5,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,12),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32, 6,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,13),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32, 7,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,14),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32, 8,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,15),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32, 9,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,16),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32,10,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,17),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32,11,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,18),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32,12,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,19),'ESTRICHOUT'); /* */
        ALT                                                   /* */
          CALL INP_FLO(32,13,5,0,0.0,80.0, 1.0, F_ESTRICH(IND,20),'ESTRICHOUT'); /* */   
        ALT                                                   /* */
          CALL INP_BIT(10,14,'  JA  ',' NEIN ',LOOP,'ESTRICHOUT  ');   IF X_R > 3 THEN  M=M-1;  FIN; 
          IF LOOP THEN
            F_ESTRICH(IND,21)=28800.0;
          ELSE
            F_ESTRICH(IND,21)=0.0;
          FIN;
        OUT;                                                  /* */
      FIN;                                                    /* */
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE                                             */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;

/***************************************************************************/
/* Regelung Prim-PMP HKs                                                   */
/***************************************************************************/
HKMIOUT2: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    CALL D_CS(1,6);
    PUT 'Sek-VL-Soll: ',TC_HKSOLLGES(IND) TO LCD BY A,F(5,1),SKIP;
    PUT 'Sek-VL-Ist:  ',TC_HKIST(IND) TO LCD BY A,F(5,1),SKIP;
    PUT 'Sek-RL:      ',TC_HKR(IND) TO LCD BY A,F(5,1),SKIP;

    CALL D_CS(2,10); PUT 'Regler P:  ',RA_MP(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,11); PUT 'Regler I:  ',RA_MI(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,12); PUT 'Regler D:  ',RA_MDTAU(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,13); PUT 'Summe   :  ',XA_HKMI(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,14); PUT 'Anst. Pumpe:       ',UPE_SOLLST( 3)/2.55,'%' TO LCD BY A,F(7,1),A;

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_HKMI2: PROC;
  DCL HK_NAME2 (32) CHAR(20);

  FOR I TO 32 REPEAT
    HK_NAME2(I)=HK_NAME(I);
  END;
  HK_NAME2(21)=' Prim-PMP HKs  ';


  IND=21; 
  WHILE IND > 20 AND IND <= 21 REPEAT 
    
    B_EINOBJ='1'B;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Vorlaufregelung  ' TO LCD BY A,A,A;
    PUT HK_NAME2(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT '      P      I         D     TauD(s)' TO LCD BY A,SKIP;
    PUT RP_M(IND),BUTT,RI_M(IND),BUTT,RD_M(IND),BUTT,RTAU_M(IND),BUTT TO LCD BY F(8,1),A,F(9,4),A,F(7,1),A,F(8,1),A,SKIP;

    M=1; /* Eingabepunkt 1-4                                     */
    WHILE M>0 AND M<5 REPEAT
      CASE M
        ALT CALL INP_FLO( 3,4,5,1,0.0    ,99.0,0.1    ,RP_M(IND)  ,'HKMIOUT2');
        ALT CALL INP_FLO(11,4,7,4,0.0001 ,99.0,0.0001 ,RI_M(IND)  ,'HKMIOUT2');
        ALT CALL INP_FLO(21,4,5,1,0.0    ,99.0,0.1    ,RD_M(IND)  ,'HKMIOUT2');
        ALT CALL INP_FLO(30,4,5,1,0.1    ,99.0,0.1    ,RTAU_M(IND),'HKMIOUT2');    IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT bet{tigt ?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-4                                         */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_HKMI                                              */


INP_BAD: PROC;

  CALL D_CLR;
  CALL D_ROFF;
  CALL D_CS(1,1);
  PUT '<',BUTT,'  Regelung Baedertemperaturen:     ' TO LCD BY A,A,A,SKIP;
  PUT '                                         ' TO LCD BY A,SKIP;
  PUT '   Badewassersoll und -ist beziehen sich ' TO LCD BY A,SKIP;
  PUT '   auf die Badewasserruecklauftemperaturen' TO LCD BY A,SKIP;
  PUT '                                         ' TO LCD BY A,SKIP;
  PUT '   Zulaufsoll= Badewassersoll + Zuschlag ' TO LCD BY A,SKIP;
  PUT '              +(Badewassersoll - Ist) *  ' TO LCD BY A,SKIP;
  PUT '               Faktor                    ' TO LCD BY A,SKIP;
  PUT '                                         ' TO LCD BY A,SKIP;
  PUT '                 Hallenbad    Freibad    ' TO LCD BY A,SKIP;
  PUT 'Badewassersoll: ',BUTT,FL_EXPHK(21),'  ',BUTT,FL_EXPHK(22) TO LCD BY A,A,F(7,1),A,A,F( 8,1),SKIP;
  PUT '      Zuschlag: ',BUTT,FL_EXPHK(23),'  ',BUTT,FL_EXPHK(24) TO LCD BY A,A,F(7,1),A,A,F( 8,1),SKIP;
  PUT '        Faktor: ',BUTT,FL_EXPHK(25),'  ',BUTT,FL_EXPHK(26) TO LCD BY A,A,F(7,1),A,A,F( 8,1),SKIP;

  M=1; /* Eingabepunkt 1-7                                     */
  WHILE M>0 AND M<7 REPEAT
    CASE M
      ALT CALL INP_FLO(19,11,5,1,10.0,40.0,0.1,FL_EXPHK(21),'LEER');
      ALT CALL INP_FLO(30,11,5,1,10.0,40.0,0.1,FL_EXPHK(22),'LEER');
      ALT CALL INP_FLO(19,12,5,1,0.0,15.0,0.1,FL_EXPHK(23),'LEER');
      ALT CALL INP_FLO(30,12,5,1,0.0,15.0,0.1,FL_EXPHK(24),'LEER');
      ALT CALL INP_FLO(19,13,5,1,0.0,15.0,0.1,FL_EXPHK(25),'LEER');
      ALT CALL INP_FLO(30,13,5,1,0.0,15.0,0.1,FL_EXPHK(26),'LEER');    IF X_R > 3 THEN  M=M-1;  FIN;
      OUT;
    FIN;
    CALL LRROT(M); /* LINKS, RECHTS oder ROT bet{tigt ?        */
    IF X_R > 1000 THEN  /* BUTTON geklickt */
      M=X_R-1001;
    FIN;  

  END; /* of WHILE                                         */

END;


/***************************************************************************/
/* Eingabe der WW-Parameter (Speicher mit innen- oder aussenliegendem WT)  */
/***************************************************************************/
WWSOLLOUT: TASK PRIO 19;

  REPEAT

    CALL D_CS(2,14);  PUT 'akt. Soll:  ',TC_BWS(IND),'   akt. Ist: ',TC_BWO(IND) TO LCD BY A,F(5,1),A,F(5,1);
    CALL D_CS(2,15);  PUT 'Ladung: ' TO LCD BY A;
                      IF B_LPMP(IND) OR B_SPMP(IND) THEN
                        IF Z_LEGIO(IND) > 0 THEN
                          PUT 'Desinfekt. noch ',Z_LEGIO(IND),'s' TO LCD BY A,F(5),A;
                        ELSE
                          IF Z_LEGNACH(IND) > 0 THEN
                            PUT 'Desinfekt. noch ',Z_LEGNACH(IND),'s' TO LCD BY A,F(5),A;
                          ELSE
                            IF B_BWDRIG(IND) THEN
                              PUT 'EIN (dringend)        ' TO LCD BY A;
                            ELSE
                              IF B_BWNORM(IND) OR B_BWNACHT(IND) THEN
                                PUT 'EIN (normal)          ' TO LCD BY A;
                              ELSE
                                PUT 'EIN (Waermeuebersch.) ' TO LCD BY A;
                              FIN;
                            FIN;
                          FIN;
                        FIN;
                      ELSE
                        PUT 'AUS                   ' TO LCD BY A;
                      FIN;
    CALL D_CS(2,16);  PUT 'Anf. Hauptkr.:  ',TC_BWVLS(IND) TO LCD BY A,F(5,1); 

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;

  END;
END;

INP_WWSOLL: PROC;

  IND=1; 
  WHILE IND > 0 AND IND <= N_SPEI REPEAT 
    
    FOR I TO N_SPEI REPEAT
      CHB(I)=WW_NAME(I);
    END; 
    CALL OBJAUSWAHL('  Warmwasser-Ladung: ',N_SPEI,CHB,'LEER        '); 
   
    IF IND < 1 OR IND > N_SPEI THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Warmwasser-Ladung  ' TO LCD BY A,A,A;
    PUT WW_NAME(IND) TO LCD BY A,SKIP,SKIP;
    PUT 'Sollwert (Tag):',TC_BWSOLL(IND),BUTT,' Min-W. (Nacht):',TC_BWMIN(IND),BUTT    TO LCD BY A,F(4),A,A,F(4),A,SKIP;
    PUT 'Soll Desinf.:  ',TC_LEGIO(IND),BUTT, ' Zirk-RL-Soll:  ',TC_BWZRSOLL(IND),BUTT TO LCD BY A,F(4),A,A,F(4),A,SKIP,SKIP;
    PUT 'Abw.-Norm:     ',TD_BWNORM(IND),BUTT,' Abw.-Dring:    ',TD_BWDRIG(IND),BUTT   TO LCD BY A,F(4,1),A,A,F(4,1),A,SKIP;
    PUT 'Max-Wert (Waermeuebersch.):    ',TC_BOMAX(IND),BUTT                       TO LCD BY A,F(4,1),A,SKIP;
    PUT 'Mehranf. Hauptkr. bei Ladung:  ',TD_BWLS(IND),BUTT                        TO LCD BY A,F(4,1),A,SKIP;
    PUT 'Start Lad bei Hauptk > Spei +  ',TD_BWTOO(IND),BUTT                       TO LCD BY A,F(4,1),A,SKIP;
    PUT 'Stop  Lad bei Hauptk < Spei +  ',TD_BWTOU(IND),BUTT                       TO LCD BY A,F(4,1),A,SKIP;
    PUT 'Max gewuenschte Lade-RL:       ',TC_BWRSOLL(IND),BUTT                     TO LCD BY A,F(4,1),A,SKIP;
    PUT 'Ueberhoeh. Speise VL:          ',TD_BWTW(IND),BUTT                        TO LCD BY A,F(4,1),A,SKIP;


    M=1; /* Eingabepunkt 1-12                                    */
    WHILE M>0 AND M<13 REPEAT
      CASE M
        ALT CALL INP_FLO(16, 3,3,0,20.0,80.0,1.0,TC_BWSOLL(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(37, 3,3,0,20.0,80.0,1.0,TC_BWMIN(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(16, 4,3,0,20.0,85.0,1.0,TC_LEGIO(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(37, 4,3,0,20.0,75.0,1.0,TC_BWZRSOLL(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(15, 6,4,1, 1.0, 8.0,0.1,TD_BWNORM(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(36, 6,4,1, 2.0,12.0,0.1,TD_BWDRIG(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(31, 7,4,1,20.0,90.0,0.1,TC_BOMAX(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(31, 8,4,1, 0.0,25.0,0.1,TD_BWLS(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(31, 9,4,1,-5.0,15.0,0.1,TD_BWTOO(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(31,10,4,1,-5.0,15.0,0.1,TD_BWTOU(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(31,11,4,1,20.0,90.0,0.1,TC_BWRSOLL(IND),'WWSOLLOUT');
        ALT CALL INP_FLO(31,12,4,1,-5.0,10.0,0.1,TD_BWTW(IND),'WWSOLLOUT');    IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder EINGABE ?             */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-12                                        */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_WWSOLL                                           */



/***************************************************************************/
/* Eingabe der WW-Parameter (Frischwasserstationen)                        */
/***************************************************************************/
WWSOLLOUT2: TASK PRIO 19;

  REPEAT

    CALL D_CS(2,11);  PUT 'akt. Soll:  ',TC_BWS(IND),'   akt. Ist: ',TC_BWO(IND) TO LCD BY A,F(5,1),A,F(5,1);
    CALL D_CS(2,12);  PUT 'Anf. Hauptkr.:  ',TC_BWVLS(IND) TO LCD BY A,F(5,1); 

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;

  END;
END;

INP_WWSOLL2: PROC;

! IND=1; 
! WHILE IND > 0 AND IND <= N_SPEI REPEAT 
  IND=1; 
  WHILE IND > 0 AND IND <=  1     REPEAT 
    
  ! FOR I TO N_SPEI REPEAT
  !   CHB(I)=WW_NAME(I);
  ! END; 
  ! CALL OBJAUSWAHL('  Warmwasser-Ladung: ',N_SPEI,CHB,'LEER        '); 
  !
  ! IF IND < 1 OR IND > N_SPEI THEN  
  !   EXIT;
  ! FIN;

    FOR I TO N_SPEI REPEAT
      CHB(I)=WW_NAME(I);
    END; 
    CALL OBJAUSWAHL('  Warmwasser-Ladung: ',  1   ,CHB,'LEER        '); 

    IF IND < 1 OR IND >  1     THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Warmwasser-Ladung  ' TO LCD BY A,A,A;
    PUT WW_NAME(IND) TO LCD BY A,SKIP,SKIP;
    PUT 'Sollwert (Tag):',TC_BWSOLL(IND),BUTT,' Min-W. (Nacht):',TC_BWMIN(IND),BUTT    TO LCD BY A,F(4),A,A,F(4),A,SKIP;
    PUT 'Soll Desinf.:  ',TC_LEGIO(IND),BUTT, ' Zirk-RL-Soll:  ',TC_BWZRSOLL(IND),BUTT TO LCD BY A,F(4),A,A,F(4),A,SKIP,SKIP;
    PUT 'Mehranf. Hauptkr. bei Ladung:  ',TD_BWLS(IND),BUTT                        TO LCD BY A,F(4,1),A,SKIP;
    PUT 'Ladeverfahren:  ',BUTT,'  '                                             TO LCD BY A,A,A;
      CASE ZF_WWMI(IND)
        ALT PUT ' nur Pumpe           ' TO LCD BY A,SKIP;
        ALT PUT 'Pumpe + Mischer      ' TO LCD BY A,SKIP;
        ALT PUT 'Pumpe + Mischer (2s) ' TO LCD BY A,SKIP;
        ALT PUT ' nur Mischer         ' TO LCD BY A,SKIP;
        ALT PUT ' nur Mischer (2s)    ' TO LCD BY A,SKIP;
        OUT
      FIN;
    PUT 'Stellzeit Mischer(s):          ',ZF_LMISTELL(IND),BUTT                    TO LCD BY A,F(4),A,SKIP;


    M=1; /* Eingabepunkt 1-7                                   */
    WHILE M>0 AND M<8 REPEAT
      CASE M
        ALT CALL INP_FLO(16, 3,3,0,20.0,80.0,1.0,TC_BWSOLL(IND),'WWSOLLOUT2');
        ALT CALL INP_FLO(37, 3,3,0,20.0,80.0,1.0,TC_BWMIN(IND),'WWSOLLOUT2');
        ALT CALL INP_FLO(16, 4,3,0,20.0,85.0,1.0,TC_LEGIO(IND),'WWSOLLOUT2');
        ALT CALL INP_FLO(37, 4,3,0,20.0,75.0,1.0,TC_BWZRSOLL(IND),'WWSOLLOUT2');
        ALT CALL INP_FLO(31, 6,4,1, 0.0,25.0,0.1,TD_BWLS(IND),'WWSOLLOUT2');
        ALT
          FOR I TO 10 REPEAT CHB(I)='                              '; END;
          CHB(1)=' nur Pumpe           ';
          CHB(2)='Pumpe + Mischer      ';
          CHB(3)='Pumpe + Mischer (2s) ';
          CHB(4)=' nur Mischer         ';
          CHB(5)=' nur Mischer (2s)    ';
          CALL INP_BETRIEB(19,7,CHB,5,ZF_WWMI(IND),'WWSOLLOUT2');
        ALT CALL INP_FIX(31,8,4,0,1800,1,ZF_LMISTELL(IND),'WWSOLLOUT2');
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder EINGABE ?             */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-7                                         */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;
END; /* of PROC INP_WWSOLL2                                          */



/***************************************************************************/
/* Timer WW Tagbetrieb                                                     */
/***************************************************************************/
WWZON: PROC;

  IND=1; 
  WHILE IND > 0 AND IND <= N_HZKR REPEAT 

    FOR I TO N_SPEI REPEAT
      CHB(I)=WW_NAME(I);
    END; 

    CALL OBJAUSWAHL('  Timer WW Tagbetrieb: ',N_SPEI,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_SPEI THEN  
      EXIT;
    FIN;

    IF IND==99 OR IND==98 THEN
    ELSE
      CALL INP_ABS(IND+32,2);
    FIN;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;



/***************************************************************************/
/* Timer WW Desinfektion                                                   */
/***************************************************************************/
WWZON2: PROC;

  IND=1; 
  WHILE IND > 0 AND IND <= N_HZKR REPEAT 

    FOR I TO N_SPEI REPEAT
      CHB(I)=WW_NAME(I);
    END; 

    CALL OBJAUSWAHL('  Timer WW Desinfektion: ',N_SPEI,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_SPEI THEN  
      EXIT;
    FIN;

    IF IND==99 OR IND==98 THEN
    ELSE
      CALL INP_ABS(IND+42,2);
    FIN;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;




/***************************************************************************/
/* WW-Laderegelung  (Speicher mit aussenliegendem WT)  <<<<                */
/***************************************************************************/
WWREGOUT: TASK PRIO 19;
  REPEAT
    CALL D_CS(2, 6); PUT 'Speise Soll:',TC_BWTW(IND) TO LCD BY A,F(5,1);
    CALL D_CS(2, 7); PUT 'Speise Ist: ',TC_BWIST(IND),'  Speise RL: ' TO LCD BY A,F(5,1),A;
                !    CASE IND
                !      ALT PUT X_AEIN(38) TO LCD BY F(5,1);
                !      ALT PUT X_AEIN(43) TO LCD BY F(5,1);
                !      OUT
                !    FIN;
    CALL D_CS(2, 8); PUT 'WW Lad VL:  ',TC_BWVOR(IND),'  WW Lad RL: ',TC_BWRUECK(IND) TO LCD BY A,F(5,1),A,F(5,1); 
    CALL D_CS(2, 9); PUT 'Anst. Ladepumpe:      ' TO LCD BY A;         
 !  CASE IND
 !    ALT PUT FL_PWMPRO( 1),'%' TO LCD BY F(5,1),A;
 !    ALT PUT X_AAUS(3),'%' TO LCD BY F(5,1),A;
 !    OUT
 !  FIN;
    CALL D_CS(2,10); PUT 'Anst. Speisepumpe:    ' TO LCD BY A;         
 !  CASE IND
 !    ALT PUT FL_PWMPRO( 2),'%' TO LCD BY F(5,1),A;
 !    ALT PUT X_AAUS(4),'%' TO LCD BY F(5,1),A;
 !    OUT
 !  FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_WWREG: PROC;

  IND=1; 
  WHILE IND > 0 AND IND <= N_SPEI REPEAT 
    
    FOR I TO N_SPEI REPEAT
      CHB(I)=WW_NAME(I);
    END; 
    CALL OBJAUSWAHL('  WW-Laderegelung: ',N_SPEI,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_SPEI THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   WW-Laderegelung  ' TO LCD BY A,A,A;
    PUT WW_NAME(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT '    P(I)     D    ' TO LCD BY A,SKIP;
    PUT RP_BWL(IND),BUTT,RD_BWL(IND),BUTT TO LCD BY F(8,2),A,F(8,2),A,SKIP;

    M=1; /* Eingabepunkt 1-2                                     */
    WHILE M>0 AND M<3 REPEAT
      CASE M
        ALT CALL INP_FLO( 3,4,5,2,0.1   ,99.0,0.01   ,RP_BWL(IND)  ,'WWREGOUT');
        ALT CALL INP_FLO(12,4,5,2,0.0   ,99.0,0.01   ,RD_BWL(IND)  ,'WWREGOUT');    IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS, EINGABE?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-2                               */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;
END; /* of PROC INP_WWREG                                  */





/***************************************************************************/
/* WW-Laderegelung  (Frischwasserstationen)  <<<<                          */
/***************************************************************************/
WWREGOUT2: TASK PRIO 19;
  REPEAT
    CALL D_CS(2, 6); PUT 'WW soll:    ',TC_BWS(IND) TO LCD BY A,F(5,1);
    CALL D_CS(2, 7); PUT 'WW Austr.:  ',TC_BWO(IND) TO LCD BY A,F(5,1);
 !  CALL D_CS(2, 7); PUT 'WW Austr.:  ',TC_BWO(IND),'  WW Eintr.: ' TO LCD BY A,F(5,1),A;
 !                   CASE IND
 !                     ALT PUT X_AEIN(34) TO LCD BY F(5,1);
 !                 !   ALT PUT X_AEIN(43) TO LCD BY F(5,1);
 !                 !   ALT PUT X_AEIN(48) TO LCD BY F(5,1);
 !                 !   ALT PUT X_AEIN(53) TO LCD BY F(5,1);
 !                     OUT
 !                   FIN;
    CALL D_CS(2, 8); PUT 'WW Lad VL:  ',TC_BWVOR(IND),'  WW Lad RL: ',TC_BWRUECK(IND) TO LCD BY A,F(5,1),A,F(5,1); 
  ! CALL D_CS(2, 9); PUT 'WW L VL gem:',TC_BWVOR(IND)                              TO LCD BY A,F(5,1)         ; 
  ! CALL D_CS(2,10); PUT 'WW Verb-Df: ',DF_HKTH(IND),'m^3/h' TO LCD BY A,F(5,2),A; 

    CALL D_CS(2,11); PUT 'Regler P:  ',RA_WWLP(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,12); PUT 'Regler I:  ',RA_WWLI(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,13); PUT 'Regler D:  ',RA_WWLDTAU(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,14); PUT 'Summe   :  ',XA_WWLAD(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,15); PUT 'Position Mischer: ',100.0*Z_LMISTELL(IND+10)/ZF_LMISTELL(IND),'%' TO LCD BY A,F(5,1),A;
    CALL D_CS(2,16); PUT 'Anst. Pumpe:      '                                               TO LCD BY A;         
    CASE IND
      ALT PUT UPE_SOLLST(8)/2.55,'%' TO LCD BY F(5,1),A;
 !    ALT PUT UPE_SOLLST(5)/2.55,'%' TO LCD BY F(5,1),A;
 !    ALT PUT X_AAUS(3),'%' TO LCD BY F(5,1),A;
 !    ALT PUT X_AAUS(4),'%' TO LCD BY F(5,1),A;
 !    ALT PUT X_AAUS(5),'%' TO LCD BY F(5,1),A;
      OUT
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_WWREG2: PROC;

  IND=1; 
  WHILE IND > 0 AND IND <= N_SPEI REPEAT 
    
  ! FOR I TO N_SPEI REPEAT
  !   CHB(I)=WW_NAME(I);
  ! END; 
  ! CALL OBJAUSWAHL('  WW-Laderegelung: ',N_SPEI,CHB,'LEER        '); 
  !
  ! IF IND < 1 OR IND > N_SPEI THEN  
  !   EXIT;
  ! FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   WW-Laderegelung  ' TO LCD BY A,A,A;
    PUT WW_NAME(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT '      P     I         D    TauD(s)' TO LCD BY A,SKIP;
    PUT RP_WWL(IND),BUTT,RI_WWL(IND),BUTT,RD_WWL(IND),BUTT,RTAU_WWL(IND),BUTT TO LCD BY F(8,1),A,F(8,3),A,F(8,1),A,F(8,1),A,SKIP;

    M=1; /* Eingabepunkt 1-4                                     */
    WHILE M>0 AND M<5 REPEAT
      CASE M
        ALT CALL INP_FLO( 3,4,5,1,0.0   ,99.0,0.1   ,RP_WWL(IND)  ,'WWREGOUT2');
        ALT CALL INP_FLO(11,4,6,3,0.001 ,99.0,0.001 ,RI_WWL(IND)  ,'WWREGOUT2');
        ALT CALL INP_FLO(21,4,5,1,0.0   ,99.0,0.1   ,RD_WWL(IND)  ,'WWREGOUT2');
        ALT CALL INP_FLO(30,4,5,1,0.1   ,99.0,0.1   ,RTAU_WWL(IND),'WWREGOUT2');   IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS, EINGABE?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-4                               */

  ! IF B_EINOBJ THEN  
      EXIT;
  ! FIN;

  END;
END; /* of PROC INP_WWREG2                                 */




/***************************************************************************/
/* WW-Laderegelung  (Frischwasserstationen)                                */
/***************************************************************************/
WWZIRKOUT: TASK PRIO 19;
  REPEAT
    CALL D_CS(2, 6); PUT 'Zirk RL Soll:',TC_BWZS(IND) TO LCD BY A,F(5,1);
    CALL D_CS(2, 7); PUT 'Zirk RL Ist: ',TC_ZIRK(IND) TO LCD BY A,F(5,1);
    CALL D_CS(2, 8); PUT 'WW Austr.:   ',TC_BWO(IND) TO LCD BY A,F(5,1); 

    CALL D_CS(2,10); PUT 'Regler P:  ',RA_WWZP(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,11); PUT 'Regler I:  ',RA_WWZI(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,12); PUT 'Regler D:  ',RA_WWZDTAU(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,13); PUT 'Summe   :  ',XA_WWZI(IND),'%' TO LCD BY A,F(7,2),A;
    CALL D_CS(2,14); PUT 'Anst. Pumpe:      '    TO LCD BY A;         
    CASE IND
  !   ALT PUT UPE_SOLLST(4)/2.55,'%' TO LCD BY F(5,1),A;
  !   ALT PUT UPE_SOLLST(6)/2.55,'%' TO LCD BY F(5,1),A;
      ALT PUT FL_PWMPRO(1),'% von 100s' TO LCD BY F(5,1),A;
  !   ALT PUT FL_PWMPRO(3),'%' TO LCD BY F(5,1),A;
  !   ALT PUT FL_PWMPRO(4),'%' TO LCD BY F(5,1),A;
      OUT
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_WWZIRK: PROC;

  IND=1; 
  WHILE IND > 0 AND IND <= N_SPEI REPEAT 
    
    FOR I TO N_SPEI REPEAT
      CHB(I)=WW_NAME(I);
    END; 
    CALL OBJAUSWAHL('  WW-Zirkulation: ',N_SPEI,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_SPEI THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  WW-Zirkulationsregelung  ' TO LCD BY A,A,A;
    PUT WW_NAME(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT '      P      I          D     TauD(s)' TO LCD BY A,SKIP;
    PUT RP_WWZ(IND),BUTT,RI_WWZ(IND),BUTT,RD_WWZ(IND),BUTT,RTAU_WWZ(IND),BUTT TO LCD BY F(8,1),A,F(9,4),A,F(8,1),A,F(8,1),A,SKIP;

    M=1; /* Eingabepunkt 1-4                                     */
    WHILE M>0 AND M<5 REPEAT
      CASE M
        ALT CALL INP_FLO( 3,4,5,1,0.0    ,99.0,0.1    ,RP_WWZ(IND)  ,'WWZIRKOUT');
        ALT CALL INP_FLO(11,4,7,4,0.0001 ,99.0,0.0001 ,RI_WWZ(IND)  ,'WWZIRKOUT');
        ALT CALL INP_FLO(22,4,5,1,0.0    ,99.0,0.1    ,RD_WWZ(IND)  ,'WWZIRKOUT');
        ALT CALL INP_FLO(31,4,5,1,0.1    ,99.0,0.1    ,RTAU_WWZ(IND),'WWZIRKOUT');
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS, EINGABE?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-4                               */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_WWREG2                                 */




/*********************************************************************/
/*  Anzeige der Impuszaehlerstaende mit Korrekturmoeglichkeit        */
/*********************************************************************/
ZAEHL_ANZEIG: PROC;

  DCL X_HILF1    FIXED;
  DCL X_HILF2    FIXED;
  DCL X_STELL    FIXED;
  DCL X_X        FIXED;
  DCL X_Y        FIXED;
  DCL X_31       FIXED(31);
  DCL X_VERSTELL FLOAT;
  DCL FL1        FLOAT;
  DCL FL55       FLOAT(55);
  DCL X_Z        FIXED;  
  DCL F15  FIXED;

  CALL D_CLR;
  CALL D_CS(1,1);
  PUT '<',BUTT,'  Impulszaehlerstaende: ' TO LCD BY A,A,A,SKIP;

  X_Z=1;
  WHILE X_Z <= N_ZAEHLER AND X_Z > 0 REPEAT

    CALL D_CS(1,((X_Z-1) REM 16)+2);
    CASE ZP_TYP(X_Z)
      ALT /* 1: m^3          */
        PUT ZP_NAME(X_Z),Z_ZAEHL(ZP_EIN(X_Z))/FL_IMP(ZP_EIN(X_Z))/2.0,' m^3' TO LCD BY A,F(9),A;
      ALT /* 2: kWh         */
        PUT ZP_NAME(X_Z),Z_ZAEHL(ZP_EIN(X_Z))/FL_IMP(ZP_EIN(X_Z))/2.0,' kWh' TO LCD BY A,F(9),A;
      ALT /* 3: Liter       */
        PUT ZP_NAME(X_Z),Z_ZAEHL(ZP_EIN(X_Z))/FL_IMP(ZP_EIN(X_Z))/2.0,' l  ' TO LCD BY A,F(9),A;
      OUT
    FIN;
    IF X_Z REM 16 == 0 OR X_Z == N_ZAEHLER THEN
      X_STELL=1;

      /* nur die aktuell angezeigten Zaehlerstaende bearbeiten         */
      IF X_Z REM 16 == 0 THEN
        X_HILF1=X_Z-(X_Z-16)//16*16;
      ELSE
        X_HILF1=X_Z REM 16;
      FIN;

      IF X_ZUGANG == 5 THEN   /* STST */
        WHILE X_STELL <= X_HILF1 AND X_STELL > 0 REPEAT

          /* aktuellen Zaehler herausfinden                           */
          X_HILF2=X_Z-(X_HILF1-X_STELL);

       !  PUT Z_ZAEHL(ZP_EIN(X_HILF2)) TO A1 BY F(15),SKIP;

          FL55=Z_ZAEHL(ZP_EIN(X_HILF2))/FL_IMP(ZP_EIN(X_HILF2))/2.0;

          CALL INP_F55(26,X_STELL+1,10,0,0.0,99999999.9, 1.0, FL55,'LEER');
          FL1=FL55 FIT FL1;

          X_31=ROUNDLG(FL1*2.0*FL_IMP(ZP_EIN(X_HILF2)));

          IF X_R==5 THEN  /* bei roter Taste den eingestellten Stand */
            Z_ZAEHL(ZP_EIN(X_HILF2))    =X_31;  /* uebernehmen       */
            Z_ZAEHLMERK(ZP_EIN(X_HILF2))=X_31;  /* uebernehmen       */
          FIN;

       !  PUT Z_ZAEHL(ZP_EIN(X_HILF2)) TO A1 BY F(15),SKIP;

          /* Zaehlerstand nocheinmal darstellen                       */
          CALL D_CS(28,X_STELL+1);
          PUT Z_ZAEHL(ZP_EIN(X_HILF2))/FL_IMP(ZP_EIN(X_HILF2))/2.0 TO LCD BY F(9);


          CASE X_R
            ALT  /* OBEN */
            ALT  /* UNTEN */
            ALT  /* LINKS */
              X_STELL=X_STELL-1;   /* einen Zaehler zurueck */
            OUT  /* RECHTS ODER ROT */
              X_STELL=X_STELL+1;   /* einen Zaehler weiter */
          FIN;
        END;
      ELSE
        CALL STICK;
      FIN;
      CALL D_CLR;
      CALL D_CS(1,1);
      CASE X_R
        ALT  /* OBEN */
          IF X_Z REM 16 == 0 THEN /* zurueck zur letzten Anzeige      */
            X_Z=(X_Z//16-2)*16;
          ELSE
            X_Z=(X_Z//16-1)*16;
          FIN;
        ALT  /* UNTEN */
        ALT  /* LINKS */
          IF X_Z REM 16 == 0 THEN /* zurueck zur letzten Anzeige      */
            X_Z=(X_Z//16-2)*16;
          ELSE
            X_Z=(X_Z//16-1)*16;
          FIN;
        OUT  /* RECHTS ODER ROT */
      FIN;
    FIN;
    X_Z=X_Z+1;
  END;  /* of WHILE < N_FUEHLER */
END;   /* of PROC */




/*****************************************************************************/
/*  Anzeige der Softwarewaermemengenzaehler mit Korrekturmoeglichkeit  <<<<  */
/*****************************************************************************/
WTH_ANZEIG: PROC;

  DCL FL1  FLOAT;

  CALL D_CLR;
  CALL D_CS(1,1);
  PUT '<',BUTT,'  Software Waermemengen in kWh ' TO LCD BY A,A,A,SKIP;
  CALL D_CS(1,2);
  PUT 'WMZ WW1 Kueche Verbr.  ',W_HKTH(1) TO LCD BY A,F(10,1),SKIP;
! PUT 'WMZ WW2 UST Verbr.     ',W_HKTH(2) TO LCD BY A,F(10,1),SKIP;
  IF X_ZUGANG==5 THEN    /* STST */
    M=1;
    WHILE M>0 AND M<2 REPEAT
      CALL INP_F55(23,M+1,10,1,0.0,99999999.9, 1.0, W_HKTH(M),'LEER');
      CALL LRROT(M);
    END;
  FIN;
  CALL D_CS(1,16);
  PUT ' BITTE TASTE DRUECKEN ' TO LCD BY A;
  CALL STICK;

END;




/************************************************************************/
/*  Anzeige der Strombilanz mit Korrekturmoeglichkeit                   */
/************************************************************************/
WEL_ANZEIG: PROC;


  CALL D_CLR;
  CALL D_CS(1,1);
  PUT '  Strombilanz in kWh  ' TO LCD BY A,SKIP,SKIP;
  PUT 'BHKW:  ',FL_BLFZGES(1),' Bh ',FL_BKWHGES(1),' kWh '  /* */
    TO LCD BY A,F(10,1),A,F(10,1),A,SKIP;             /* */ 
! PUT 'BHKW2: ',FL_BLFZGES(2),' Bh ',FL_BKWHGES(2),' kWh '  /* */
!   TO LCD BY A,F(10,1),A,F(10,1),A,SKIP;             /* */ 
! PUT 'BHKW1: ',FL_BLFZGESHZG(1),' Bh ',FL_BKWHGESHZG(1),' kWh '  /* */
!   TO LCD BY A,F(10,1),A,F(10,1),A,SKIP;             /* */ 
! PUT 'BHKW2: ',FL_BLFZGESHZG(2),' Bh ',FL_BKWHGESHZG(2),' kWh '  /* */
!   TO LCD BY A,F(10,1),A,F(10,1),A,SKIP;             /* */ 
  PUT TO LCD BY SKIP;
  PUT 'HT-Erzeugung:   ',W_ERZHT TO LCD BY A,F(10,1),SKIP;
  PUT 'NT-Erzeugung:   ',W_ERZNT TO LCD BY A,F(10,1),SKIP;
  PUT 'HT-Bedarf:      ',W_BEDHT TO LCD BY A,F(10,1),SKIP;
  PUT 'NT-Bedarf:      ',W_BEDNT TO LCD BY A,F(10,1),SKIP;
  PUT 'HT-Einspeisung: ',W_EINHT TO LCD BY A,F(10,1),SKIP;
  PUT 'NT-Einspeisung: ',W_EINNT TO LCD BY A,F(10,1),SKIP;
  PUT 'HT-Bezug:       ',W_BEZHT TO LCD BY A,F(10,1),SKIP;
  PUT 'NT-Bezug:       ',W_BEZNT TO LCD BY A,F(10,1),SKIP,SKIP;
  PUT 'Monats Max. Bez. ',PE_STRMAX(DA_MON),' am ',DA_STRMAX(DA_MON),
      '. um ',Z_STRMAX(DA_MON)//4,':',15*(Z_STRMAX(DA_MON) REM 4)
    TO LCD BY A,F(5,1),A,F(4),A,F(2),A,F(2);

  IF X_ZUGANG==5 THEN   /* STST */
    M=1;
    WHILE M>0 AND M< 9 REPEAT
      CASE M
        ALT
          CALL INP_F55(16,M+4,10,1,0.0,99999999.9, 1.0, W_ERZHT,'LEER');
        ALT                  
          CALL INP_F55(16,M+4,10,1,0.0,99999999.9, 1.0, W_ERZNT,'LEER');
        ALT
          CALL INP_F55(16,M+4,10,1,0.0,99999999.9, 1.0, W_BEDHT,'LEER');
        ALT
          CALL INP_F55(16,M+4,10,1,0.0,99999999.9, 1.0, W_BEDNT,'LEER');
        ALT
          CALL INP_F55(16,M+4,10,1,0.0,99999999.9, 1.0, W_EINHT,'LEER');
        ALT
          CALL INP_F55(16,M+4,10,1,0.0,99999999.9, 1.0, W_EINNT,'LEER');
        ALT
          CALL INP_F55(16,M+4,10,1,0.0,99999999.9, 1.0, W_BEZHT,'LEER');
        ALT
          CALL INP_F55(16,M+4,10,1,0.0,99999999.9, 1.0, W_BEZNT,'LEER');
        OUT
      FIN;
      CALL LRROT(M);
    END;
  FIN;
  CALL D_CS(1,16);
  PUT ' BITTE TASTE DRUECKEN ' TO LCD BY A;
  CALL STICK;
  
END;


/************************************************************************/
/*  Anzeige der Monatszaehler mit Korrekturmoeglichkeit                 */
/************************************************************************/
MONZAEHLOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_MONZAEHL THEN
      !   CALL D_CS(33,Y); Y=Y+1;
      !   PUT MON_ZAEHL(I,DA_MON),MON_EINH(I) TO LCD BY F(12,1),A;
          CALL D_CS(29,Y); Y=Y+1;
          PUT MON_ZAEHL(I,DA_MON) TO LCD BY F(11); 
          PUT ' ',MON_EINH(I) TO LCD BY A,A;
        FIN;
      END;
    ELSE
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

MONZAEHL_ZEIG: PROC;

  B_NOTAUSWAHL='1'B;
  FOR I TO N_MONZAEHL REPEAT
    CHB(I)=MON_NAME(I);
  END; 
  IND=1;
  CALL OBJAUSWAHL('  Aktuelle Zaehlerstaende: ',N_MONZAEHL,CHB,'MONZAEHLOUT'); 

END;

MON_ZEIG: PROC;
  DCL FL1 FLOAT(55);
  DCL FL2 FLOAT(55);
  DCL FL3 FLOAT(55);
  DCL K   FIXED;
  

  IND=1; 
  WHILE IND > 0 AND IND <= N_MONZAEHL REPEAT 
   
    FOR I TO N_MONZAEHL REPEAT
      CHB(I)=MON_NAME(I);
    END; 
    CALL OBJAUSWAHL('   Monatszaehler:      ',N_MONZAEHL,CHB,'LEER       '); 

    IF IND < 1 OR IND > N_MONZAEHL THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  Monatszaehlerstaende zum Monatsende: ' TO LCD BY A,A,A,SKIP;
    PUT '  ' TO LCD BY A;
    PUT MON_NAME(IND) TO LCD BY A,SKIP;
    PUT ' MON   Zaehlerstand    Verbr.   ATschnitt' TO LCD BY A,SKIP;
    FL1=MON_ZAEHL(IND, 1)-MON_ZAEHL(IND,12);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2, 1) > 1.0 THEN  FL2=AT_MON(2, 1);  FIN;
    FL3=AT_MON(1, 1)/FL2;
    PUT ' JAN:',MON_ZAEHL(IND, 1),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND, 2)-MON_ZAEHL(IND, 1);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2, 2) > 1.0 THEN  FL2=AT_MON(2, 2);  FIN;
    FL3=AT_MON(1, 2)/FL2;
    PUT ' FEB:',MON_ZAEHL(IND, 2),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND, 3)-MON_ZAEHL(IND, 2);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2, 3) > 1.0 THEN  FL2=AT_MON(2, 3);  FIN;
    FL3=AT_MON(1, 3)/FL2;
    PUT ' MAR:',MON_ZAEHL(IND, 3),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND, 4)-MON_ZAEHL(IND, 3);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2, 4) > 1.0 THEN  FL2=AT_MON(2, 4);  FIN;
    FL3=AT_MON(1, 4)/FL2;
    PUT ' APR:',MON_ZAEHL(IND, 4),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND, 5)-MON_ZAEHL(IND, 4);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2, 5) > 1.0 THEN  FL2=AT_MON(2, 5);  FIN;
    FL3=AT_MON(1, 5)/FL2;
    PUT ' MAI:',MON_ZAEHL(IND, 5),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND, 6)-MON_ZAEHL(IND, 5);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2, 6) > 1.0 THEN  FL2=AT_MON(2, 6);  FIN;
    FL3=AT_MON(1, 6)/FL2;
    PUT ' JUN:',MON_ZAEHL(IND, 6),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND, 7)-MON_ZAEHL(IND, 6);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2, 7) > 1.0 THEN  FL2=AT_MON(2, 7);  FIN;
    FL3=AT_MON(1, 7)/FL2;
    PUT ' JUL:',MON_ZAEHL(IND, 7),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND, 8)-MON_ZAEHL(IND, 7);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2, 8) > 1.0 THEN  FL2=AT_MON(2, 8);  FIN;
    FL3=AT_MON(1, 8)/FL2;
    PUT ' AUG:',MON_ZAEHL(IND, 8),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND, 9)-MON_ZAEHL(IND, 8);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2, 9) > 1.0 THEN  FL2=AT_MON(2, 9);  FIN;
    FL3=AT_MON(1, 9)/FL2;
    PUT ' SEP:',MON_ZAEHL(IND, 9),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND,10)-MON_ZAEHL(IND, 9);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2,10) > 1.0 THEN  FL2=AT_MON(2,10);  FIN;
    FL3=AT_MON(1,10)/FL2;
    PUT ' OKT:',MON_ZAEHL(IND,10),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND,11)-MON_ZAEHL(IND,10);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2,11) > 1.0 THEN  FL2=AT_MON(2,11);  FIN;
    FL3=AT_MON(1,11)/FL2;
    PUT ' NOV:',MON_ZAEHL(IND,11),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    FL1=MON_ZAEHL(IND,12)-MON_ZAEHL(IND,11);  IF FL1 < 0.0 THEN  FL1=0.0;  FIN;
    FL2=1.0;
    IF AT_MON(2,12) > 1.0 THEN  FL2=AT_MON(2,12);  FIN;
    FL3=AT_MON(1,12)/FL2;
    PUT ' DEZ:',MON_ZAEHL(IND,12),MON_EINH(IND),FL1,FL3 TO LCD BY A,F(11),A,F(8),F(8,1),SKIP;

    PUT ' JAN:',MON_ZAEHLJAN(IND),MON_EINH(IND),MON_ZAEHLJAN(IND+31) TO LCD BY A,F(11),A,F( 8);
    IF DA_MON > 10 THEN
      PUT ' (',DA_JAH,')' TO LCD BY A,F(4),A;
    ELSE
      PUT ' (',DA_JAH-1,')' TO LCD BY A,F(4),A;
    FIN;

    IF X_ZUGANG==5 THEN    /* STST */

      M=1; /* Eingabepunkt 1-12                                    */
      WHILE M>0 AND M<14 REPEAT
        CASE M
          ALT CALL INP_FLO(6, 4,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND, 1),'LEER');
          ALT CALL INP_FLO(6, 5,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND, 2),'LEER');
          ALT CALL INP_FLO(6, 6,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND, 3),'LEER');
          ALT CALL INP_FLO(6, 7,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND, 4),'LEER');
          ALT CALL INP_FLO(6, 8,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND, 5),'LEER');
          ALT CALL INP_FLO(6, 9,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND, 6),'LEER');
          ALT CALL INP_FLO(6,10,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND, 7),'LEER');
          ALT CALL INP_FLO(6,11,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND, 8),'LEER');
          ALT CALL INP_FLO(6,12,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND, 9),'LEER');
          ALT CALL INP_FLO(6,13,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND,10),'LEER');
          ALT CALL INP_FLO(6,14,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND,11),'LEER');
          ALT CALL INP_FLO(6,15,10,0,0.0,1000000000.0, 1.0, MON_ZAEHL(IND,12),'LEER');
          ALT CALL INP_FLO(6,16,10,0,0.0,1000000000.0, 1.0, MON_ZAEHLJAN(IND),'LEER');   
          OUT;
        FIN;
        CALL LRROT(M); /* LINKS, RECHTS oder ROT bet{tigt ?        */
        IF X_R > 1000 THEN  /* BUTTON geklickt */
          M=X_R-1001;
        FIN;  
      END; /* of WHILE 1-9                                         */
    ELSE
      CALL STICK; 
    FIN;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;  


/************************************************************************/
/*  Anzeige der Jahreszaehler mit Korrekturmoeglichkeit                 */
/************************************************************************/
JAHR_ZEIG: PROC;
  DCL FL1 FLOAT;
  DCL FL2 FLOAT;
  DCL FL3 FLOAT;
  DCL K   FIXED;
  
  IND=1; 
  WHILE IND > 0 AND IND <= N_MONZAEHL REPEAT 
   
    FOR I TO N_MONZAEHL REPEAT
      CHB(I)=MON_NAME(I);
    END; 
    CALL OBJAUSWAHL('   Jahreszaehlerstaende:   ',N_MONZAEHL,CHB,'LEER       '); 

    IF IND < 1 OR IND > N_MONZAEHL THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  Jahreszaehlerstaende: ' TO LCD BY A,A,A,SKIP;
    PUT '  ' TO LCD BY A;
    PUT MON_NAME(IND) TO LCD BY A,SKIP;
    PUT TO LCD BY SKIP,SKIP;
    PUT 'Summe akt. Jahr:      ',JAHR_ZAEHL(IND,1),'  (',DA_JAH,')' TO LCD BY A,F(10),A,F(4),A,SKIP;
    PUT 'Summe Vorjahr:        ',JAHR_ZAEHL(IND,2),'  (',DA_JAH-1,')' TO LCD BY A,F(10),A,F(4),A,SKIP;
    PUT 'Zaehler Ende Vorjahr: ',JAHR_ZAEHL(IND,3),'  (',DA_JAH-1,')' TO LCD BY A,F(10),A,F(4),A,SKIP;
    
    IF X_ZUGANG==5 THEN    /* STST */
      CALL D_ROFF;

      M=1; /* Eingabepunkt 1-2                                    */
      WHILE M>0 AND M<3 REPEAT
        CASE M
          ALT CALL INP_FLO(22, 6,10,0,0.0,1000000000.0, 1.0, JAHR_ZAEHL(IND, 2),'LEER');
          ALT CALL INP_FLO(22, 7,10,0,0.0,1000000000.0, 1.0, JAHR_ZAEHL(IND, 3),'LEER');   
          OUT;
        FIN;
        CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?        */
        IF X_R > 1000 THEN  /* BUTTON geklickt */
          M=X_R-1001;
        FIN;  
      END; /* of WHILE 1-3                                         */
    ELSE
      CALL STICK; 
    FIN;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;  

/*****************************************************************************/
/*  Anzeige sonstiger Zaehler mit Korrekturmoeglichkeit  <<<<                */
/*****************************************************************************/
SONST_ANZEIG: PROC;

  DCL FL1  FLOAT;

  CALL D_CLR;
  CALL D_CS(1,1);
  PUT '<',BUTT,'  Sonstige Zaehler:  ' TO LCD BY A,A,A;
  CALL D_CS(1,2);
  PUT 'Bh Holzkessel1        ',Z_KESLFZ(1)/3600.0 TO LCD BY A,F(10,1),SKIP;
  PUT 'Bh Holzkessel2        ',Z_KESLFZ(2)/3600.0 TO LCD BY A,F(10,1),SKIP;
  PUT 'Bh Biogaskessel       ',Z_KESLFZ(3)/3600.0 TO LCD BY A,F(10,1),SKIP;
 !PUT 'Bh Kessel2:           ',Z_KESLFZ(2)/3600.0 TO LCD BY A,F(10,1),SKIP;
 !PUT 'Bh Kessel3:           ',Z_KESLFZ(3)/3600.0 TO LCD BY A,F(10,1),SKIP;
 !PUT 'Bh WW-Ladung:         ',FL_BLFZGESHZG(15) TO LCD BY A,F(10,1),SKIP;
  IF X_ZUGANG==5 THEN    /* STST */
    M=1; /* Eingabepunkt 1-x                                      */
    WHILE M>0 AND M<4  REPEAT
      CASE M
        ALT 
          FL1=Z_KESLFZ(1)/3600.0;
          CALL INP_FLO(22,M+1,10,1,0.0,99999999.0, 1.0,FL1,'LEER');
          Z_KESLFZ(1)=ROUNDLG(FL1*3600.0);
        ALT 
          FL1=Z_KESLFZ(2)/3600.0;
          CALL INP_FLO(22,M+1,10,1,0.0,99999999.0, 1.0,FL1,'LEER');
          Z_KESLFZ(2)=ROUNDLG(FL1*3600.0);
        ALT 
          FL1=Z_KESLFZ(3)/3600.0;
          CALL INP_FLO(22,M+1,10,1,0.0,99999999.0, 1.0,FL1,'LEER');
          Z_KESLFZ(3)=ROUNDLG(FL1*3600.0);
 !      ALT 
 !        CALL INP_F55(22,M+1,10,1,0.0,99999999.9, 1.0, FL_BLFZGESHZG(15),'LEER');
        OUT
      FIN;
      CALL LRROT(M);
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END;
  FIN;
! CALL D_CS(1,16);
! PUT ' BITTE TASTE DRUECKEN ' TO LCD BY A;
  CALL STICK;

END;



/************************************************************************/
/*  Bedienung der GeniBus-Pumpen                                        */
/************************************************************************/
UPEOUT: TASK PRIO 19;
  DCL Y FIXED;

  REPEAT
    IF B_LOOPB THEN
      Y=3;
      FOR I FROM IND TO IND+7 REPEAT
        IF I <= N_UPE THEN
          CALL D_CS(33,Y); Y=Y+1;
          PUT UPE_SOLLST(I)/2.55,'%' TO LCD BY F(5,1),A;
        FIN;
      END;
    ELSE
      CALL D_CS(1,8);
      PUT 'Kommando:  ',UPE_SOLLKOMM(IND) TO LCD BY A,F(4);
      CASE UPE_SOLLKOMM(IND)+1
        ALT /*  0 */ PUT ' (Konst. Druck)         ' TO LCD BY A;
        ALT /*  1 */ PUT ' (Prop. Druck)          ' TO LCD BY A;
        ALT /*  2 */ PUT ' (Konst. Kennl.)        ' TO LCD BY A;
        ALT /*  3 */ PUT ' (Konst. Leist.)        ' TO LCD BY A;
        OUT
          IF UPE_SOLLKOMM(IND) > 15 AND UPE_SOLLKOMM(IND) < 20 THEN
            PUT ' (Lokal Setpoint)       ' TO LCD BY A;
          ELSE
            PUT ' (???)                  ' TO LCD BY A;
          FIN;
      FIN;       
      PUT TO LCD BY SKIP;         
      PUT 'Sollstufe: ',UPE_SOLLST(IND),' (',UPE_SOLLST(IND)/2.55,'%)' TO LCD BY A,F(4),A,F(5,1),A;
      PUT TO LCD BY SKIP;         
      IF UPE_FEHLER(IND)==9 THEN  
        PUT 'Volumenstrom:         ??','m^3/h'
          TO LCD BY A,A,SKIP;     
        PUT 'Differenzdruck:       ??','mWs'
          TO LCD BY A,A,SKIP;     
        PUT 'Temperatur:           ??' TO LCD BY A,SKIP;  
        PUT 'Motor:                ??            ' TO LCD BY A,SKIP;
      ELSE
        PUT 'Volumenstrom:     ',UPE_ISTDF(IND),'m^3/h'
          TO LCD BY A,F(6,2),A,SKIP;     
        PUT 'Differenzdruck:   ',UPE_ISTDRUCK(IND),'mWs'
          TO LCD BY A,F(6,2),A,SKIP;     
        PUT 'Temperatur:       ',UPE_ISTTEMP(IND) TO LCD BY A,F(6,1),SKIP;     
        PUT 'Motor:     Freq.: ',UPE_FRQ(IND),'Hz  P:',UPE_PDC(IND),'W'
          TO LCD BY A,F(5,1),A,F(5),A,SKIP;     
      FIN;
      PUT 'Fehlernummer:     ',UPE_FEHLER(IND) TO LCD BY A,F(6),SKIP;     
      PUT TO LCD BY SKIP;
  !   CASE IND
  !     ALT  /* 1 PMP Kessel 1     */
  !       PUT 'K-VL: ',X_AEIN(2),' K-RL: ',X_AEIN(3),'  Lfz.:',Z_KLZ(1)
  !         TO LCD BY A,F(5,1),A,F(5,1),A,F(7);
  !     OUT
  !   FIN;
    FIN;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;    


UPE_BEDIEN: PROC;

  IND=1;
! WHILE IND>0 AND IND<= 6    REPEAT
!
!   FOR I TO  6    REPEAT
!     IF I < 3 THEN
!       CHB(I)=UPE_NAME(I);
!     ELSE
!       CHB(I)=UPE_NAME(I+6);
!     FIN;
!   END; 
!   CALL OBJAUSWAHL(' GeniBus-Pumpenkommunikation: ', 6   ,CHB,'UPEOUT      '); 
!
!   IF IND < 1 OR IND >  6    THEN  
!     EXIT;
!   FIN;

  WHILE IND>0 AND IND<=N_UPE REPEAT
 
    FOR I TO N_UPE REPEAT
      CHB(I)=UPE_NAME(I);
    END; 
    CALL OBJAUSWAHL(' GeniBus-Pumpenkommunikation: ',N_UPE,CHB,'UPEOUT      '); 
 
    IF IND < 1 OR IND > N_UPE THEN  
      EXIT;
    FIN;


    CALL D_CLR;
    CALL D_ROFF;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  GeniBus - Pumpenkommunikation' TO LCD BY A,A,A;
    CALL D_CS(1,2);
    PUT IND,'   ' TO LCD BY F(8),A;
    PUT UPE_NAME(IND) TO LCD BY A;
    CALL D_CS(1,4);
    PUT 'Kennlinientyp:      ',Z_UPEKOMMAND(IND),BUTT TO LCD BY A,F(4),A,SKIP;
    CALL D_CS(1,5);
    PUT 'Betriebsart:      ' TO LCD BY A;
    IF B_UPEHAND(IND) THEN
      PUT ' HAND ',BUTT TO LCD BY A,A;
    ELSE  
      PUT ' AUTO ',BUTT TO LCD BY A,A;
    FIN;
    CALL D_CS(1,6);
    PUT 'Sollstufe HAND:     ',Z_UPESOLLHAND(IND),BUTT TO LCD BY A,F(4),A,SKIP;

    N=1;
    CALL D_CS(1,2);
    WHILE N<4 AND N>0 REPEAT
      CALL D_ROFF;
      CASE N
        ALT  /* Kommando manuell */
          CALL INP_FIX(20,4,4,0,3,1,Z_UPEKOMMAND(IND),'UPEOUT ');
        ALT  /* Betriebsart   */
          CALL INP_BIT(18,5,' HAND ',' AUTO ',B_UPEHAND(IND),'UPEOUT ');    
        ALT  /* Sollstufe manuell */
          CALL INP_FIX(20,6,4,0,255,1,Z_UPESOLLHAND(IND),'UPEOUT ');    IF X_R > 3 THEN  N=N-1;  FIN;
        OUT
      FIN;
      CALL LRROT(N);
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        N=X_R-1001;
      FIN;  
    END;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;


/************************************************************************/
/*  Genibus Skalierungsfaktoren abrufen / einstellen                    */
/************************************************************************/
UPE_SCAL: PROC;
  DCL STAT    BIT(32);

  CALL D_CLR;
  PUT 'Sollen die GeniBus-Skalierungsfaktoren' TO LCD BY A,SKIP;
  PUT 'automatisch ermittelt werden?' TO LCD BY A,SKIP;
  PUT 'Dann EINGEBETASTE sonst RECHTS' TO LCD BY A,SKIP,SKIP;
  CALL STICK;
  IF X_R==5 THEN
    CALL D_CLR;
    PUT 'ermittle Skalierungsfaktoren' TO LCD BY A,SKIP; 
    PUT 'einen Moment bitte ' TO LCD BY A,SKIP; 
    PREVENT   GRUNDFOS;
    TERMINATE GRUNDFOS;
    AFTER 1.5 SEC RESUME;
    ACTIVATE GFSCALE;
    STAT=TASKST('GFSCALE');
    WHILE NOT STAT.BIT(1) REPEAT
      STAT=TASKST('GFSCALE');
      AFTER 0.5 SEC RESUME;
    END;
    ACTIVATE GRUNDFOS;
    AFTER 2 SEC RESUME;
  FIN;    

  IND=1; /* Bei Pumpe 1 beginnen:                                  */
  WHILE IND>0 AND IND<=N_UPE REPEAT /* Schleife über Pumpen:        */
    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '  Mit AUF und AB Pumpe auswaehlen:  ' TO LCD BY A,SKIP;
    PUT IND,'  >' TO LCD BY F(8),A;
    CALL D_RON;
    PUT UPE_NAME(IND) TO LCD BY A;
    CALL D_ROFF;
    PUT '<' TO LCD BY A,SKIP,SKIP;
    PUT ' GeniBus-Pumpenskalierungsfaktoren:' TO LCD BY A,SKIP,SKIP;
    PUT ' Pumpendruck:       ',UPE_PRESSSCALE(IND) TO LCD BY A,F(8,6),SKIP;
    PUT ' Pumpendurchfluss:  ',UPE_FLOWSCALE(IND) TO LCD BY A,F(8,6),SKIP;
    PUT ' Wassertemperatur:  ',UPE_TEMPSCALE(IND) TO LCD BY A,F(8,6),SKIP;
    PUT ' el. Frequenz:      ',UPE_FRQSCALE(IND) TO LCD BY A,F(8,6),SKIP;
    PUT ' el. Leistung:      ',UPE_PDCSCALE(IND) TO LCD BY A,F(8,6),SKIP;
 
 
    CALL STICK;
    CASE X_R
      ALT /* oben            */
        IND=IND-1;
      ALT /* unten           */
        IND=IND+1;
      ALT /* links           */
        IND=0;
      OUT /* rechts oder Eingabe    */
        CALL D_ROFF;
        CALL D_CS(1,1);
        PUT 'Bitte Daten der Pumpe eingeben!       ',
            IND,'   ',UPE_NAME(IND),' ' TO LCD BY A,SKIP,F(8),A,A,A,SKIP,SKIP;
 
        M=1; /* Eingabepunkt 1-5                                     */
        WHILE M>0 AND M<6 REPEAT
          CASE M
            ALT CALL INP_FLO(20,M+5,8,6,0.0,9.9, 0.000001, UPE_PRESSSCALE(IND),'LEER');
            ALT CALL INP_FLO(20,M+5,8,6,0.0,9.9, 0.000001, UPE_FLOWSCALE(IND),'LEER');
            ALT CALL INP_FLO(20,M+5,8,6,0.0,9.9, 0.000001, UPE_TEMPSCALE(IND),'LEER');
            ALT CALL INP_FLO(20,M+5,8,6,0.0,9.9, 0.000001, UPE_FRQSCALE(IND),'LEER');
            ALT CALL INP_FLO(20,M+5,8,6,0.0,9.9, 0.000001, UPE_PDCSCALE(IND),'LEER');
            OUT;
          FIN;
          CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
        END; /* of WHILE 1-5                                         */
      /* end of OUT X_R                                              */
    FIN; /* of CASE X_R                                              */
    CALL LRROT(IND); /* LINKS, RECHTS oder ROT betaetigt ?              */
    IF IND>N_UPE THEN
      IND=N_UPE;
    FIN;
  END;

END;    

/************************************************************************/
/*  Darstellung der Genibus Busdaten                                    */
/************************************************************************/
UPEOUT2: TASK PRIO 19;
  REPEAT
    CALL D_CS(1,6);
    FOR I TO 13 REPEAT
      PUT TOBIT(TOFIXED(UPE_FRAG(IND).CHAR(I))),' ' TO LCD BY B4(2),A;
    END;
    CALL D_CS(1,7);
    FOR I TO 13 REPEAT
      PUT TOBIT(TOFIXED(UPE_FRAG(IND).CHAR(I+13))),' ' TO LCD BY B4(2),A;
    END;
    CALL D_CS(1,8);
    FOR I TO 13 REPEAT
      PUT TOBIT(TOFIXED(UPE_FRAG(IND).CHAR(I+26))),' ' TO LCD BY B4(2),A;
    END;
    CALL D_CS(1,11);
    FOR I TO 13 REPEAT
      PUT TOBIT(TOFIXED(UPE_ANTW(IND).CHAR(I))),' ' TO LCD BY B4(2),A;
    END;
    CALL D_CS(1,12);
    FOR I TO 13 REPEAT
      PUT TOBIT(TOFIXED(UPE_ANTW(IND).CHAR(I+13))),' ' TO LCD BY B4(2),A;
    END;
    CALL D_CS(1,13);
    FOR I TO 13 REPEAT
      PUT TOBIT(TOFIXED(UPE_ANTW(IND).CHAR(I+26))),' ' TO LCD BY B4(2),A;
    END;
    CALL D_CS(1,14);
    PUT 'Zaehler OK:',Z_UPEOK(IND),'  Zaehler ERR:',Z_UPEERR(IND) TO LCD BY A,F(6),A,F(6);
    CALL D_CS(1,15);
    PUT 'STAT:      ',Z_UPESTAT(IND),'  ANZ:        ',Z_UPEANZ(IND) TO LCD BY A,F(6),A,F(6);
    CALL D_CS(29,1);
    PUT ZP_NOW TO LCD BY T(8);

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;    


UPE_BUS: PROC;
  IND=1;
  WHILE IND>0 AND IND<=N_UPE REPEAT

    FOR I TO N_UPE REPEAT
      CHB(I)=UPE_NAME(I);
    END; 
    CALL OBJAUSWAHL(' GeniBus-Buskommunikation: ',N_UPE,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_UPE THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_ROFF;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  GeniBus - Buskommunikation' TO LCD BY A,A,A;
    CALL D_CS(1,2);
    PUT IND,'   ' TO LCD BY F(8),A;
    PUT UPE_NAME(IND) TO LCD BY A;

    CALL D_CS(1,3);
    PUT '  Kommunikation:' TO LCD BY A;
    IF UPE_FREIG(IND) == 1 THEN
      PUT '   aktiv   ',BUTT TO LCD BY A,A;
    ELSE  
      PUT '   gesperrt',BUTT TO LCD BY A,A;
    FIN;    
    PUT '  Zaehler auf 0',BUTT TO LCD BY A,A;
    CALL D_CS(1,5);
    PUT 'letzte Sendedaten:' TO LCD BY A;
    CALL D_CS(1,10);
    PUT 'letzte Empfangsdaten:' TO LCD BY A;

    N=1;
    WHILE N>0 AND N<3 REPEAT
      CASE N
        ALT  /* Betriebsart   */
          CHB(1)='   aktiv   ';
          CHB(2)='   gesperrt';
          CALL INP_BETRIEB(17,3,CHB,2,UPE_FREIG(IND),'UPEOUT2     ');  
        ALT /* Zaehler auf 0   */
          CALL D_CS(29,3);
          CALL D_RON;
          PUT '  Zaehler auf 0' TO LCD BY A;
          CALL D_ROFF;
          IF X_R==5 OR X_R==1003 THEN
            Z_UPEOK(IND)=0;
            Z_UPEERR(IND)=0;
            Z_GFNEUST=0;
            N=N-2;
          FIN;
        OUT
      FIN;
      IF N /= 2 THEN
        CALL D_CS(29,3);
        PUT '  Zaehler auf 0' TO LCD BY A;
      FIN;
      CALL LRROT(N);
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        N=X_R-1001;
      FIN;  
    END;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;



/************************************************************************/
/*  Genibus Pumpenkennlinie (% -> Sollstufe) einstellen                 */
/************************************************************************/
UPE_SCAL2: PROC;

  IND=1;
  WHILE IND>0 AND IND<=N_UPE REPEAT

    FOR I TO N_UPE REPEAT
      CHB(I)=UPE_NAME(I);
    END; 
    CALL OBJAUSWAHL(' GeniBus-Pumpenkennlinien: ',N_UPE,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_UPE THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_ROFF;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  GeniBus - Pumpenkennlinie' TO LCD BY A,A,A;
    CALL D_CS(1,2);
    PUT IND,'   ' TO LCD BY F(8),A;
    PUT UPE_NAME(IND) TO LCD BY A;
    CALL D_CS(1,4);
    PUT '     %    Sollstufe    ' TO LCD BY A,SKIP;
    PUT '   0,4%  ',UPE_KENN(IND,1),BUTT TO LCD BY A,F(5),A,SKIP;
    PUT '   0,8%  ',UPE_KENN(IND,2),BUTT TO LCD BY A,F(5),A,SKIP;
    PUT '  99,6%  ',UPE_KENN(IND,3),BUTT TO LCD BY A,F(5),A,SKIP;
    PUT ' 100,0%  ',UPE_KENN(IND,4),BUTT TO LCD BY A,F(5),A,SKIP;
 
    M=1; /* Eingabepunkt 1-4                                     */
    WHILE M>0 AND M<5 REPEAT
      CASE M
        ALT CALL INP_FLO(10, 5,4,0,0.0,255.0, 1.0, UPE_KENN(IND,1),'LEER');
        ALT CALL INP_FLO(10, 6,4,0,0.0,255.0, 1.0, UPE_KENN(IND,2),'LEER');
        ALT CALL INP_FLO(10, 7,4,0,0.0,255.0, 1.0, UPE_KENN(IND,3),'LEER');
        ALT CALL INP_FLO(10, 8,4,0,0.0,255.0, 1.0, UPE_KENN(IND,4),'LEER');
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-4                                         */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END;    


/************************************************************************/
/*  Externe Einfluesse sichtbar und veraenderbar machen                 */
/************************************************************************/
INP_EXTHK: PROC;
  DCL HK_NAME2 (32) CHAR(20);
  DCL ETAST         FIXED; 

  FOR I TO 32 REPEAT
    HK_NAME2(I)=HK_NAME(I);
  END;
  HK_NAME2( 4)=' Zuluft Trockn ';

  IND=1; 
! WHILE IND > 0 AND IND <= N_HZKR REPEAT 
  WHILE IND > 0 AND IND <=   4    REPEAT 
   
    FOR I TO  4     REPEAT
 !  FOR I TO N_HZKR REPEAT
      CHB(I)=HK_NAME2(I);
    END; 
    CALL OBJAUSWAHL('   Ext. Einfluss Heizkreise:  ', 4    ,CHB,'LEER        '); 
 !  CALL OBJAUSWAHL('   Heizkreisparameter:  ', 4    ,CHB,'LEER        '); 

    IF IND < 1 OR IND >  4     THEN  
 !  IF IND < 1 OR IND > N_HZKR THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  Ext. Einfl.  ' TO LCD BY A,A,A;
    PUT HK_NAME2(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT 'Betrieb HK (Pumpe): ',BUTT,ZF_HKPEXT(IND) TO LCD BY A,A,F(8),SKIP;
    PUT '(-1: AUS  0: AUTO  1: EIN  2..100: PMP%) ' TO LCD BY A,SKIP;
    PUT 'Mischer:            ',BUTT,ZF_HKMIEXT(IND) TO LCD BY A,A,F(8),SKIP;
    PUT '(3P:     -1: AUS  0: AUTO  1: AUF >1: ZU)   ' TO LCD BY A,SKIP;
    PUT '(0-10V:  -1: ZU   0: AUTO  1..100:   Mi%)   ' TO LCD BY A,SKIP;

    M=1; 
    WHILE M>0 AND M<3  REPEAT
      CASE M
        ALT CALL INP_FIX(24, 3,5  ,  -1,100 ,1  ,ZF_HKPEXT(IND),'LEER'); 
        ALT CALL INP_FIX(24, 5,5  ,  -1,100 ,1  ,ZF_HKMIEXT(IND),'LEER');   IF X_R > 3 THEN  M=M-1;  FIN;
        OUT
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE                                             */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_EXTHK                                         */

INP_EXTKES: PROC;
  DCL K_NAME (10) CHAR(15);

  FOR I TO 10 REPEAT
    K_NAME(I)='Kessel' CAT TOCHAR(I+48);
  END;
  K_NAME(1)='Holzkessel1';
  K_NAME(2)='Holzkessel2';
  K_NAME(3)='Biogaskessel';

  IND=1; 
  WHILE IND > 0 AND IND <= N_KESSEL REPEAT 
    CALL D_CLR;

    FOR I TO N_KESSEL REPEAT
      CHB(I)=K_NAME(I);
    END; 
    CALL OBJAUSWAHL('  Ext. Einfluss Kessel:  ',N_KESSEL,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_KESSEL THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  Ext. Einfl.  ' TO LCD BY A,A,A;
    PUT K_NAME(IND) TO LCD BY A;
    CALL D_CS(1,2);
    PUT KES_TXT1(IND) TO LCD BY A,SKIP;
    PUT KES_TXT2(IND) TO LCD BY A,SKIP;
    CALL D_CS(1,5);
    PUT 'Betrieb Kessel:     ',BUTT,ZF_KEINEXT(IND) TO LCD BY A,A,F(8),SKIP;
    PUT '(-1: AUS  0: AUTO  1: EIN  2..100: Pth%) ' TO LCD BY A,SKIP;
    PUT 'Betrieb K-Pumpe:    ',BUTT,ZF_KPMPEXT(IND) TO LCD BY A,A,F(8),SKIP;
    PUT '(-1: AUS  0: AUTO  1: EIN  2..100: PMP%) ' TO LCD BY A,SKIP;

    M=1; 
    WHILE M>0 AND M<3  REPEAT
      CASE M
        ALT CALL INP_FIX(24, 5,5  ,  -1,100 ,1  ,ZF_KEINEXT(IND),'LEER'); 
        ALT CALL INP_FIX(24, 7,5  ,  -1,100 ,1  ,ZF_KPMPEXT(IND),'LEER');   IF X_R > 3 THEN  M=M-1;  FIN;
        OUT
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE                                             */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_EXTKES                                          */

INP_EXTBHKW: PROC;
  DCL B_NAME ( 8) CHAR(15);

  FOR I TO  8 REPEAT
    B_NAME(I)='BHKW' CAT TOCHAR(I+48);
  END;
! B_NAME(1)='BHKW Senertec';

  IND=1; 
  WHILE IND > 0 AND IND <= N_BHKW REPEAT 
    CALL D_CLR;

    FOR I TO N_BHKW REPEAT
      CHB(I)=B_NAME(I);
    END; 
    CALL OBJAUSWAHL('  Ext. Einfluss BHKW:  ',N_BHKW,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_BHKW THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  Ext. Einfl.  ' TO LCD BY A,A,A;
    PUT B_NAME(IND) TO LCD BY A;
    CALL D_CS(1,3);
    PUT 'Betrieb BHKW:       ',BUTT,ZF_BEINEXT(IND) TO LCD BY A,A,F(8),SKIP;
    PUT '(-1: AUS  0: AUTO  1: EIN  2..100: Pel%  ' TO LCD BY A,SKIP;

    M=1; 
    WHILE M>0 AND M<2  REPEAT
      CASE M
        ALT CALL INP_FIX(24, 3,5  ,  -1,100 ,1  ,ZF_BEINEXT(IND),'LEER');   IF X_R > 3 THEN  M=M-1;  FIN;
        OUT
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE                                             */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* of PROC INP_EXTBHKW                                          */




/************************************************************************/
/*  Menue HZG-Nachspeisung                                              */
/************************************************************************/
HZGSPEIOUT: TASK PRIO 19;
  DCL AUS BIT(1);
  
  AUS='1'B;
  REPEAT
    AUS=NOT AUS;
    CALL D_CS(1,9);
    PUT 'Druck Verteiler:  ',P_VERTEIL,'bar' TO LCD BY A,F(5,2),A,SKIP;
    PUT 'Nachspeiseventil: ' TO LCD BY A;
    IF B_HZGFUELL THEN
      PUT ' EIN ' TO LCD BY A,SKIP;
    ELSE
      PUT ' AUS ' TO LCD BY A,SKIP;
    FIN;
    PUT 'Nachspeisezeit heute: ' TO LCD BY A;
    IF AUS AND Z_HZGFUELL >= ZF_HZGFUELL THEN
      PUT '       ' TO LCD BY A,SKIP;
    ELSE
      PUT Z_HZGFUELL,'s' TO LCD BY F(5),A,SKIP;
    FIN;
    PUT 'Nachspeisung l: ',Z_ZAEHL(21)/FL_IMP(21)/2.0 TO LCD BY A,F(12,3),SKIP;
    
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_HZGSPEIS: PROC;
  CALL D_CLR;                                                 /* */
  CALL D_CS(1,1);                                             /* */
  PUT '<',BUTT,'   HZG-Wassernachspeisung:    ' TO LCD BY A,A,A;
  CALL D_CS(1,3);                                             /* */
  PUT 'HZG-Druck-Nachspeisebeginn (bar): ',FL_HZGFUEEIN,BUTT TO LCD BY A,F(5,2),A,SKIP; /* */
  PUT 'HZG-Druck-Nachspeisestop   (bar): ',FL_HZGFUEAUS,BUTT TO LCD BY A,F(5,2),A,SKIP; /* */
  PUT 'erl. Tageslaufz. Nachspei. (s):   ',ZF_HZGFUELL,BUTT  TO LCD BY A,F(5),A,SKIP; /* */
  M=1; /* Eingabepunkt 1-2                                     */
  WHILE M>0 AND M<4 REPEAT                                  /* */
    CASE M                                                  /* */
      ALT                                                   /* */
        CALL INP_FLO(34,3,5,2,0.0,FL_HZGFUEAUS*0.98, 0.01, FL_HZGFUEEIN,'HZGSPEIOUT');/* */
      ALT                                                   /* */
        CALL INP_FLO(34,4,5,2,FL_HZGFUEEIN*1.02,30.0, 0.01, FL_HZGFUEAUS,'HZGSPEIOUT'); /* */
      ALT
        CALL INP_FIX(34,5,5,10,5400,1,ZF_HZGFUELL,'HZGSPEIOUT');      IF X_R > 3 THEN  M=M-1;  FIN;
      OUT;                                                  /* */
    FIN;                                                    /* */
    CALL LRROT(M); /* LINKS, RECHTS oder ROT bet{tigt ?        */
    IF X_R > 1000 THEN  /* BUTTON geklickt */
      M=X_R-1001;
    FIN;  
  END;                                                      /* */
END;


/************************************************************************/
/*  Eingabe Hauptnutzungsdauer Heizung                                  */
/************************************************************************/
INP_NUTZ: PROC;          /* Eingabe der Nutzungsdauer der Heizanlage */
  B_LOOPB='1'B;
  WHILE B_LOOPB REPEAT
    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'   Hauptnutzungsdauer der Heizzentrale' TO LCD BY A,A,A;
    CALL D_CS(1,3);
    PUT '       Anfang        Ende  ' TO LCD BY A;
    CALL D_CS(8,5);
    PUT ZP_SCHANF,BUTT TO LCD BY T(8),A;
    CALL D_CS(20,5);
    PUT ZP_SCHEND,BUTT TO LCD BY T(8),A;

    M=1; 
    WHILE M>0 AND M<3 REPEAT
      CASE M
        ALT CALL INP_CLO(7,5,1,ZP_SCHANF,'LEER');
        ALT CALL INP_CLO(19,5,1,ZP_SCHEND,'LEER');
        OUT
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS oder ROT betaetigt ?       */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE                                             */

    IF ZP_SCHANF<=ZP_SCHEND THEN
      B_LOOPB='0'B;
    ELSE
      CALL D_CS(2,7);
      PUT 'Anfang muss frueher als Ende sein !!' TO LCD BY A;
      AFTER 3 SEC RESUME;
    FIN;
  END;
END;


/************************************************************************/
/*  Analogeingaenge abgleichen                                          */
/************************************************************************/
OUT_FUEHLER: TASK PRIO 19;
  REPEAT
    CALL D_CS(22,4);
    PUT '  Wert: ',X_AEIN(FP_HARD(IND)) TO LCD BY A,F(7,2);

    IF IND>0 THEN
      /* Nullpunkt in Bit, sowie Steigung berechnen:                 */
      CASE FP_TYP(IND)
        ALT /*  1 KTY      0-100 Grad */ X_D=100.0;
        ALT /*  2 Leistung 0-10  kW   */ X_D=10.0;
        ALT /*  3 PT 1000c 0-100 Grad */ X_D=100.0; 
        ALT /*  4 %        0-100 %    */ X_D=100.0;
        ALT /*  5 Druck    0- 4 bar   */ X_D=4.0;
        ALT /*  6 Druck    0- 6 bar   */ X_D=6.0;
        ALT /*  7 Gassens. 0-5  V     */ X_D=1.0;
        ALT /*  8 Thermoel. -82 - 830 */ X_D=100.0;
        ALT /*  9 Spannung 0-30V      */ X_D=30.0;
        ALT /* 10 PBed Seidel -10-10mA*/ X_D=10.0;
        ALT /* 11 Solltemp 15-30°C    */ X_D=30.0;
        ALT /* 12 PT  500  0-100 Grad */ X_D=100.0; 
        ALT /* 13 T 4-20   0-100 Grad */ X_D=100.0; 
        ALT /* 14 DF 4-20  0-100 m^3/h*/ X_D=100.0; 
        ALT /* 15 PT 1000a 0-100 Grad */ X_D=100.0;                         
        ALT /* 16 dP       0-10 mWS   */ X_D=10.0;                         
        ALT /* 17 PT 1000  0-100 Grad */ X_D=100.0;                         
         OUT;
      FIN;

      /* Nullpunkt in Bit berechnen:                                 */
      FP_NULL(FP_HARD(IND))=ENTIER(1023*(FP_ULOW(FP_HARD(IND))/5000));
      /* Steigung berechnen:                                         */
      FP_STEIG(FP_HARD(IND))=X_D/((1023*(FP_UHIGH(FP_HARD(IND))/5000))-FP_NULL(FP_HARD(IND)));
    FIN;

    CALL D_CS(1,11);
    PUT 'Kanal',FP_HARD(IND),':',FELD(FP_HARD(IND)),' Bit',FELD(FP_HARD(IND))*4.8828,' mV'
     TO LCD BY A,F(3),A,F(6),A,F(6),A;


    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END; /* of Task */

INP_FUEHLER: PROC;  

  IND=1;
  B_FUEHL='1'B; /* damit wird die Mittelwertbildung abgeschaltet     */
  WHILE IND>0 AND IND<=N_FUEHLER REPEAT

    FOR I TO N_FUEHLER REPEAT
      CHB(I)=FP_NAME(I);
    END; 
  
    CALL OBJAUSWAHL('  Analogeingaenge abgleichen: ',N_FUEHLER,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_FUEHLER THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  Analogeingaenge abgleichen' TO LCD BY A,A,A;
    CALL D_CS(1,3);
    PUT 'Eingang:        ',IND,'  >' TO LCD BY A,F(3),A;
    PUT FP_NAME(IND) TO LCD BY A;
    CALL D_CS(1,4);
    PUT 'Hardwarekanal:  ',FP_HARD(IND) TO LCD BY A,F(3),SKIP;
    CALL D_CS(1,5);

    CASE FP_TYP(IND)
      ALT /*  1 */ PUT 'Temperatur:      0    100 Grad ' TO LCD;
      ALT /*  2 */ PUT 'P BHKW    :      0     10 KW   ' TO LCD;
      ALT /*  3 */ PUT 'Temp PT 1000ew:    0 Grad      ' TO LCD;
      ALT /*  4 */ PUT 'rel. %    :      0    100 %    ' TO LCD;
      ALT /*  5 */ PUT 'Druck     :      0      4 bar  ' TO LCD;
      ALT /*  6 */ PUT 'Druck     :      0      6 bar  ' TO LCD;
      ALT /*  7 */ PUT 'Gassens.  :      0      1 V    ' TO LCD;
      ALT /*  8 */ PUT 'Thermoelem:      0    100 Grad ' TO LCD;
      ALT /*  9 */ PUT 'Spannung  :      0     30 V    ' TO LCD;
      ALT /* 10 */ PUT 'P Bedarf  :      0     10 KW   ' TO LCD;
      ALT /* 11 */ PUT 'Solltemp. :      0     30 Grad ' TO LCD;
      ALT /* 12 */ PUT 'Temp PT 500:       0 Grad      ' TO LCD;
      ALT /* 13 */ PUT 'Temp 4-20mA:     0    100 Grad ' TO LCD;
      ALT /* 14 */ PUT 'Df  4-20mA:      0    100 m^3/h' TO LCD;
      ALT /* 15 */ PUT 'Temp PT 1000 alt   0 Grad      ' TO LCD;
      ALT /* 16 */ PUT 'Druck     :      0     10 mWS  ' TO LCD;
      ALT /* 17 */ PUT 'Temp PT 1000:      0 Grad      ' TO LCD;
      OUT;
    FIN;

    IF FP_TYP(IND)==3 OR FP_TYP(IND)==12 OR FP_TYP(IND)==15 OR FP_TYP(IND)==17 THEN
      PUT 'Spannung  :',FP_ULOW(FP_HARD(IND)),BUTT,'  mV              ' TO LCD BY SKIP,A,F(9),A,A;
    ELSE
      PUT 'Spannung  :',FP_ULOW(FP_HARD(IND)),BUTT,FP_UHIGH(FP_HARD(IND)),BUTT,'  mV' TO LCD BY SKIP,A,F(7),A,F(7),A,A;
    FIN;
    PUT TO LCD BY SKIP;
    PUT TO LCD BY SKIP;
    PUT 'Ueberwachung: MIN-Wert MAX-Wert  aktiv?' TO LCD BY A,SKIP;
    PUT FL_XAEINMIN(FP_HARD(IND)),BUTT,FL_XAEINMAX(FP_HARD(IND)),BUTT TO LCD BY F(20,1),A,F(9,1),A;
    IF B_FUEHLWACH(FP_HARD(IND)) THEN
      PUT '    JA  ',BUTT TO LCD BY A,A;
    ELSE
      PUT '   NEIN ',BUTT TO LCD BY A,A;
    FIN;      
   
    IF FP_TYP(IND)==3 OR FP_TYP(IND)==12 OR FP_TYP(IND)==15 OR FP_TYP(IND)==17 THEN /* Pt 1000                     */
      N=1;
      WHILE N>0 AND N<5 REPEAT 
        CASE N
          ALT
            CALL INP_FIX(15,6,5,-9999,9999,1,FP_ULOW(FP_HARD(IND)),'OUT_FUEHLER ');
          ALT
            CALL INP_FLO(13,9,7,1,-9990.0,99999.0,0.1,FL_XAEINMIN(FP_HARD(IND)),'OUT_FUEHLER ');
          ALT
            CALL INP_FLO(24,9,6,1,-9990.0,99999.0,0.1,FL_XAEINMAX(FP_HARD(IND)),'OUT_FUEHLER ');
          ALT
            CALL INP_BIT(33,9,'  JA  ',' NEIN ',B_FUEHLWACH(FP_HARD(IND)),'OUT_FUEHLER ');    IF X_R > 3 THEN  N=N-1;  FIN;
        FIN;
        CALL LRROT(N);
        IF X_R > 1000 THEN  /* BUTTON geklickt */
          N=X_R-1001;
        FIN;  
      END;
    ELSE
      N=1;
      WHILE N>0 AND N<6 REPEAT 
        CASE N
          ALT
            CALL INP_FIX(13,6,5,-9999,9999,1,FP_ULOW(FP_HARD(IND)),'OUT_FUEHLER ');
          ALT
            CALL INP_FIX(21,6,5,-9999,9999,1,FP_UHIGH(FP_HARD(IND)),'OUT_FUEHLER ');
          ALT
            CALL INP_FLO(13,9,7,1,-9990.0,99999.0,0.1,FL_XAEINMIN(FP_HARD(IND)),'OUT_FUEHLER ');
          ALT
            CALL INP_FLO(24,9,6,1,-9990.0,99999.0,0.1,FL_XAEINMAX(FP_HARD(IND)),'OUT_FUEHLER ');
          ALT
            CALL INP_BIT(33,9,'  JA  ',' NEIN ',B_FUEHLWACH(FP_HARD(IND)),'OUT_FUEHLER ');    IF X_R > 3 THEN  N=N-1;  FIN;
        FIN;
        CALL LRROT(N);
        IF X_R > 1000 THEN  /* BUTTON geklickt */
          N=X_R-1001;
        FIN;  
      END;
    FIN;

    IF IND>0 THEN
      /* Nullpunkt in Bit, sowie Steigung berechnen:                 */
      CASE FP_TYP(IND)
        ALT /*  1 KTY      0-100 Grad */ X_D=100.0;
        ALT /*  2 Leistung 0-10  kW   */ X_D=10.0;
        ALT /*  3 PT 1000c 0-100 Grad */ X_D=100.0; 
        ALT /*  4 %        0-100 %    */ X_D=100.0;
        ALT /*  5 Druck    0- 4 bar   */ X_D=4.0;
        ALT /*  6 Druck    0- 6 bar   */ X_D=6.0;
        ALT /*  7 Gassens. 0-5  V     */ X_D=1.0;
        ALT /*  8 Thermoel. -82 - 830 */ X_D=100.0;
        ALT /*  9 Spannung 0-30V      */ X_D=30.0;
        ALT /* 10 PBed Seidel -10-10mA*/ X_D=10.0;
        ALT /* 11 Solltemp 15-30°C    */ X_D=30.0;
        ALT /* 12 PT  500  0-100 Grad */ X_D=100.0; 
        ALT /* 13 T 4-20   0-100 Grad */ X_D=100.0; 
        ALT /* 14 DF 4-20  0-100 m^3/h*/ X_D=100.0; 
        ALT /* 15 PT 1000a 0-100 Grad */ X_D=100.0;                         
        ALT /* 16 dP       0-10 mWS   */ X_D=10.0;                         
        ALT /* 17 PT 1000  0-100 Grad */ X_D=100.0;                         
        OUT;
      FIN;

      /* Nullpunkt in Bit berechnen:                                 */
      FP_NULL(FP_HARD(IND))=ENTIER(1023*(FP_ULOW(FP_HARD(IND))/5000));
      /* Steigung berechnen:                                         */
      FP_STEIG(FP_HARD(IND))=X_D/((1023*(FP_UHIGH(FP_HARD(IND))/5000))-FP_NULL(FP_HARD(IND)));
    FIN;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;
  B_FUEHL='0'B;       /* Mittelwertbildung wieder einschalten        */

END; /* of PROC INP_FUE */



/************************************************************************/
/*  Analogausgaenge abgleichen                                          */
/************************************************************************/
INP_ANAL: PROC;  

  IND=1;
  WHILE IND>0 AND IND<=N_ANALOG REPEAT
   
    FOR I TO N_ANALOG REPEAT
      CHB(I)=AP_NAME(I);
    END; 
  
    CALL OBJAUSWAHL('  Analogausgaenge abgleichen: ',N_ANALOG,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_ANALOG THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  Analogausgaenge abgleichen' TO LCD BY A,A,A;

    CALL D_CS(1,3);
    PUT 'Ausgang:  ',IND,'  ' TO LCD BY A,F(2),A;
    PUT AP_NAME(IND) TO LCD BY A;
    CALL D_CS(1,6);
    PUT '    Wert:       0%     100%' TO LCD BY A;
    CALL D_CS(1,7);
    PUT 'Spannung:   ',AP_ULOW(IND),BUTT,AP_UHIGH(IND),BUTT,'   V ' TO LCD BY A,F(7,2),A,X(1),F(7,2),A,A;

    N=1;
    WHILE N>0 AND N<3 REPEAT;
      IF N==1 THEN
        CALL INP_FLO(14,7,5,2,0.0,15.0,0.01,AP_ULOW(IND),'LEER');
      ELSE
        CALL INP_FLO(23,7,5,2,0.0,15.0,0.01,AP_UHIGH(IND),'LEER');    IF X_R > 3 THEN  N=N-1;  FIN;
      FIN;
      CALL LRROT(N); /* LINKS, RECHTS oder ROT bet{tigt ?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        N=X_R-1001;
      FIN;  
    END;

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;

END; /* INP_ANAL     */




/************************************************************************/
/*  Zaehleingaenge abgleichen                                           */
/************************************************************************/
ZAEHL_ABGL: PROC;   
  DCL D FIXED;
  
  CALL D_CLR;
  CALL D_CS(1,1);
  PUT '     Zaehleingaenge abgleichen ' TO LCD BY A;
  IND=1;
  WHILE IND>0 AND IND<=N_ZAEHLER REPEAT
    FOR I TO N_ZAEHLER REPEAT
      CHB(I)=ZP_NAME(I);
    END; 
  
    CALL OBJAUSWAHL('  Zaehleingaenge abgleichen: ',N_ZAEHLER,CHB,'LEER        '); 

    IF IND < 1 OR IND > N_ZAEHLER THEN  
      EXIT;
    FIN;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  Zaehleingaenge abgleichen' TO LCD BY A,A,A;

    CALL D_CS(1,3);
    PUT 'Eing.: ',IND,'  ' TO LCD BY A,F(3),A;
    PUT ZP_NAME(IND) TO LCD BY A;
    PUT TO LCD BY SKIP;
    PUT 'Hardw.:',ZP_EIN(IND) TO LCD BY A,F(3);
    CALL D_CS(1,6);
    CASE ZP_TYP(IND)
      ALT
        PUT '    Impulse pro m^3   ' TO LCD BY A;
      ALT
        PUT '    Impulse pro kWh   ' TO LCD BY A;
      ALT
        PUT '    Impulse pro l     ' TO LCD BY A;
      OUT
        PUT '                      ' TO LCD BY A;
    FIN;        
    CALL D_CS(1,8);
    PUT '        ',FL_IMP(ZP_EIN(IND)) TO LCD BY A,F(8,3);

    IF FL_IMP(ZP_EIN(IND)) > 100.0 THEN
      FL_IMP(ZP_EIN(IND))=(ROUND(10.0*FL_IMP(ZP_EIN(IND))))/10.0;   
    ELSE
      IF FL_IMP(ZP_EIN(IND)) > 10.0 THEN
        FL_IMP(ZP_EIN(IND))=(ROUND(100.0*FL_IMP(ZP_EIN(IND))))/100.0;   
      ELSE
        FL_IMP(ZP_EIN(IND))=(ROUND(1000.0*FL_IMP(ZP_EIN(IND))))/1000.0;   
      FIN;
    FIN;
    CALL INP_FLO(8,8,8,3,0.001,3000.0,0.001,FL_IMP(ZP_EIN(IND)),'LEER');
    IF FL_IMP(ZP_EIN(IND)) > 100.0 THEN
      FL_IMP(ZP_EIN(IND))=(ROUND(10.0*FL_IMP(ZP_EIN(IND))))/10.0;   
    ELSE
      IF FL_IMP(ZP_EIN(IND)) > 10.0 THEN
        FL_IMP(ZP_EIN(IND))=(ROUND(100.0*FL_IMP(ZP_EIN(IND))))/100.0;   
      ELSE
        FL_IMP(ZP_EIN(IND))=(ROUND(1000.0*FL_IMP(ZP_EIN(IND))))/1000.0;   
      FIN;
    FIN;

  ! IF X_R > 1000 THEN  /* BUTTON geklickt */
  !   N=X_R-1001;
  ! FIN;  

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;
END; /* ZAEHL_ABGL    */



/************************************************************************/
/*  Uhrzeit / Datum stellen                                             */
/************************************************************************/
INP_RTC: PROC GLOBAL;
  DCL (DATUM,MONAT,JAHR,STUNDE,MINUTE) FIXED;

  DATUM=DA_DAT; 
  MONAT=DA_MON; 
  JAHR=DA_JAH;
  STUNDE=ZF_STD; 
  MINUTE=ZF_MIN;

  CALL D_CLR;
  CALL D_CS(1,1);
  PUT '<',BUTT,'  Datum/Uhrzeit einstellen  ' TO LCD BY A,A,A;

  CALL D_CS(1,4);
  PUT 'Datum:',DATUM,BUTT,' .',MONAT,BUTT,' .',JAHR,BUTT,
      'Zeit :   ',STUNDE,BUTT,' :',MINUTE,BUTT
    TO LCD BY A,F(4),A,A,F(4),A,A,F(6),A,SKIP,A,F(3),A,A,F(3),A;
  M=1;
  WHILE M>0 AND M<6 REPEAT
    CASE M
      ALT CALL INP_FIX( 8,4,2,   1,  31,1,DATUM,'LEER');
      ALT CALL INP_FIX(15,4,2,   1,  12,1,MONAT,'LEER');
      ALT CALL INP_FIX(22,4,4,1991,2059,1,JAHR,'LEER');
      ALT CALL INP_FIX(10,5,2,   0,  23,1,STUNDE,'LEER');
      OUT CALL INP_FIX(16,5,2,   0,  59,1,MINUTE,'LEER');
    FIN;
    CALL LRROT(M); /* LINKS, RECHTS oder ROT bet{tigt ?              */
    IF X_R > 1000 THEN  /* BUTTON geklickt */
      M=X_R-1001;
    FIN;  
  END;

  IF M > 5 THEN
    CALL D_CS(1,7);
    CALL D_ROFF;
    PUT  ' UEBERNAHME ERST NACH BESTAETIGUNG !!',
         ' Bestaetigung der Einstellungen     ',
         '   mit Eingabetaste !!             ' 
      TO LCD BY (3)(A,SKIP);
    CALL STICK;
    IF X_R==K_E AND (NOT B_ROTSP OR X_ZUGANG > 0) THEN  /* STST */
      CALL RTC_SETZE(STUNDE,MINUTE,DATUM,MONAT,JAHR);
    FIN;
    AFTER 0.01 SEC RESUME;
    CALL RTC_DATUM;  /* Datum aus Echtzeituhr lesen                */
  FIN;

END; /* of PROC INP_RTC */


/*********************************************************************/
/* Zustand der EINGABETASTE                                          */
/*********************************************************************/
INP_ROTSP: PROC;    /* STST */
  DCL F15  FIXED;
  DCL FL1 FLOAT;
  DCL FIX1    FIXED;
  DCL WERT2   FIXED;
  DCL DISPSTATUSALT   BIT(32);
  DCL ZEILEN(25)      CHAR(80);
  DCL XROTALT         FIXED;
  DCL YROTALT         FIXED;
  DCL ZROTALT         FIXED;
  DCL BUTTONALT(30,3) FIXED;
  DCL Z_BUTTONALT     FIXED;

  
  DISPSTATUSALT=DISPSTATUS;
  XROTALT=XROT;
  YROTALT=YROT;
  ZROTALT=ZROT;
  FOR I TO 25 REPEAT
    IF DISPSTATUS.BIT( 1) THEN
      IF I < 19 THEN
        ZEILEN(I)=ZEIL(I);
      FIN;
    ELSE
      ZEILEN(I)=ZEIL80(I);
    FIN;
  END;
  FOR I TO 30 REPEAT
    FOR J TO 3 REPEAT
      BUTTONALT(I,J)=BUTTON(I,J);
    END;
  END;
  Z_BUTTONALT=Z_BUTTON;

  DISPSTATUS.BIT( 1)='1'B; /* normales Display  */
  DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
  DISPSTATUS.BIT( 3)='0'B; /* grosses Display   */
  DISPSTATUS.BIT( 4)='0'B; /* grafischer Absenkungskalender */
  DISPSTATUS.BIT(31)='1'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;
  CHIN30='                              ';
  Z_CIN30=0;
  B_TASTATUR='0'B;

  CALL D_CLR;
  PUT '<',BUTT,'  Zustand der Eingabetaste' TO LCD BY A,A,A,SKIP,SKIP;
  IF B_ROTSP THEN
    PUT '     Die EINGABETASTE ist blockiert' TO LCD;
  ELSE
    PUT '     Die EINGABETASTE ist aktiv'     TO LCD;
  FIN;
  X_GEHEIM=0;
  X_GEHEIMINT=0;
  CALL D_CS(6,5);
  PUT 'Bitte den Schluessel eingeben:' TO LCD;
  CALL D_CS(18,6);
  CALL D_RON;
  PUT '>',X_GEHEIM,'<' TO LCD BY A,F(5),A;
  CALL D_ROFF;
  CALL STICK;
  X_R=0;
  WHILE X_R<3 REPEAT /* solange Hebel hoch oder runter:              */
    IF Z_CIN30 < 1 THEN
      IF X_R==1 THEN 
        X_GEHEIM=X_GEHEIM+X_F;
      FIN;
      IF X_R==2 THEN 
        X_GEHEIM=X_GEHEIM-X_F; 
      FIN;
      IF X_GEHEIM<0    THEN X_GEHEIM=0;    FIN;
      IF X_GEHEIM>9999 THEN X_GEHEIM=9999; FIN;
      CALL D_CS(19,6);
      CALL D_RON;
      PUT X_GEHEIM TO LCD BY F(5);
      CALL D_ROFF;
    ELSE
      CALL D_CS(19,6);
      PUT '               ' TO LCD BY A(6);
      CALL D_CS(19,6);
      CALL D_RON;
 !    PUT WERT2 TO LCD BY F(ST,NK);
      F15=Z_CIN30;
      IF F15 > 5 THEN  F15=5;  FIN;
      PUT CHIN30 TO LCD BY A(F15);
      CALL D_ROFF;
    FIN;
    CALL STICK;
    IF X_R==144 THEN    /* Ausstieg Tastatureingabe */
      F15=INSTR(CHIN30,1,30,'-',1,1);
      IF F15 > 0 AND Z_CIN30 < 2 THEN
        WERT2= -0;
      ELSE
        F15=INSTR(CHIN30,1,30,'.',1,1);
        IF F15 > 0 THEN                        /* . enthalten */
          WERT2= -19999;
          CHIN30='                              ';
          Z_CIN30=0;
        ELSE
          CONVERT FIX1 FROM CHIN30 BY RST(F15), F(15);  
          IF F15==0 THEN
            WERT2=FIX1;
          ELSE
            WERT2= -19999;
            CHIN30='                              ';
            Z_CIN30=0;
          FIN;
        FIN;
      FIN;
      X_R=0;
    FIN;
  END;
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;

  IF WERT2 > -19990 THEN
    X_GEHEIM=WERT2;
    IF X_GEHEIM<0    THEN X_GEHEIM=0;    FIN;
    IF X_GEHEIM>9999 THEN X_GEHEIM=9999; FIN;
  FIN;

  IF X_GEHEIM==789 THEN B_ROTSP=NOT B_ROTSP; FIN;
  IF X_GEHEIM==100 THEN 
    X_GEHEIMINT=100;
    PUT 'AFTER 20 MIN ACTIVATE ENDE' TO RTOS BY A;
  FIN;
  IF X_GEHEIM==226 THEN 
    X_GEHEIMINT=226;
    PUT 'AFTER 20 MIN ACTIVATE ENDE' TO RTOS BY A;
  FIN;
  IF X_GEHEIM==78 THEN
    X_GEHEIMINT=78;
    PUT 'AFTER 20 MIN ACTIVATE ENDE' TO RTOS BY A;
  FIN;
  CALL D_CLR; CALL D_CS(1,4);
  PUT '<',BUTT,' ' TO LCD BY A,A,A;
  IF B_ROTSP AND X_GEHEIM /= 226 AND X_GEHEIM /= 78 THEN
    PUT 'Die EINGABETASTE ist blockiert' TO LCD;
  ELSE
    IF B_ROTSP AND (X_GEHEIM == 226 OR X_GEHEIM == 78) THEN
      PUT '  Die EINGABETASTE ist fuer 20MIN aktiv'     TO LCD;
    ELSE
      PUT '  Die EINGABETASTE ist aktiv'     TO LCD;
    FIN;
  FIN;
  CALL STICK;

  DISPSTATUS=DISPSTATUSALT;
  XROT=XROTALT;
  YROT=YROTALT;
  ZROT=ZROTALT;
  FOR I TO 25 REPEAT
    IF DISPSTATUS.BIT( 1) THEN
      IF I < 19 THEN
        ZEIL(I)=ZEILEN(I);
      FIN;
    ELSE
      ZEIL80(I)=ZEILEN(I);
    FIN;
  END;
  FOR I TO 30 REPEAT
    FOR J TO 3 REPEAT
      BUTTON(I,J)=BUTTONALT(I,J);
    END;
  END;
  Z_BUTTON=Z_BUTTONALT;



END;


/*********************************************************************/
/* Informationen ueber letzten Reset ausgeben:                       */
/*********************************************************************/
RESETINFO: PROC;

  CALL D_GRAPHCLR;


  CALL D_CS(1,2);
  PUT '<',BUTT,' ' TO LCD BY A,A,A;
  PUT IDSTRING,
      ' Projekt: ',NR_PRJ,'   Version: ',VERSION,
/*    '          ',IDSTRING2,   /* <<< */
      '           Reset Nr.',Z_RESET,
      '     am ',DA_RESDAT,'.',DA_RESMON,'.',DA_JAH,'    um',ZP_RESET,
      '       Weiter mit Taste!'
  TO LCD BY
       A,SKIP,
       A,F(5),A,F(5),SKIP,SKIP,
/*     A,A,SKIP,SKIP,  /* */
       A,F(6),SKIP,
       A,F(2),A,F(2),A,F(4),A,T(10),SKIP,SKIP,
       A;

  CALL STICK;
  CALL D_GRAPHCLR;

END; /* of PROC RESETINFO */



/***************************************************************************/
/* Strom Erzeugung/Einspeisung                                             */
/***************************************************************************/
STROMOUT: TASK PRIO 19;
  REPEAT
    CALL D_CS(2, 5); PUT 'Pel Bedarf:     ',PE_BEDARF    TO LCD BY A,F(5,1);
                     PUT '   Pel BHKW:  ',PE_BIST(1)   TO LCD BY A,F(5,1);
    CALL D_CS(2, 6); PUT 'Pel Bez <- EVU: ',P_DI(16)     TO LCD BY A,F(5,1);
                     IF B_IMPNEU(16) THEN                            /*  */
                       PUT '*' TO LCD BY A;                          /*  */
                       B_IMPNEU(16)='0'B;                            /*  */ 
                     ELSE                                            /*  */  
                       PUT ' ' TO LCD BY A;                          /*  */
                     FIN;                                            /*  */
                     PUT '  Pel PV:    ',P_DI(13)     TO LCD BY A,F(5,1);
                     IF B_IMPNEU(13) THEN                            /*  */
                       PUT '*' TO LCD BY A;                          /*  */
                       B_IMPNEU(13)='0'B;                            /*  */ 
                     ELSE                                            /*  */  
                       PUT ' ' TO LCD BY A;                          /*  */
                     FIN;                                            /*  */
    CALL D_CS(2, 7); PUT 'Pel Ein -> EVU: ',P_DI(15)     TO LCD BY A,F(5,1);
                     IF B_IMPNEU(15) THEN                            /*  */
                       PUT '*' TO LCD BY A;                          /*  */
                       B_IMPNEU(15)='0'B;                            /*  */ 
                     ELSE                                            /*  */  
                       PUT ' ' TO LCD BY A;                          /*  */
                     FIN;                                            /*  */
    CALL D_CS(2, 9); PUT '                 akt. Jahr    Vorjahr ' TO LCD BY A;
    CALL D_CS(2,10); PUT 'Wel BHKW:       ',W_HKTH(22),W_HKTH(26)    TO LCD BY A,F(9,2),F(11,2);
    CALL D_CS(2,11); PUT 'Wel PV:         ',W_HKTH(21),W_HKTH(25)    TO LCD BY A,F(9,2),F(11,2);
    CALL D_CS(2,12); PUT 'Wel Erz. ges.:  ',W_HKTH(23),W_HKTH(27)    TO LCD BY A,F(9,2),F(11,2);
    CALL D_CS(2,13); PUT 'Wel Ein -> EVU: ',W_HKTH(24),W_HKTH(28)    TO LCD BY A,F(9,2),F(11,2);
    CALL D_CS(2,14); PUT 'Einsp/ErzGes:   ',FL_EINSPPRO*100.0,'%'    TO LCD BY A,F(9,2),A;
                     IF W_HKTH(27) > 1.0(55) THEN
                       PUT W_HKTH(28)/W_HKTH(27)*100.0,'%'    TO LCD BY F(10,2),A;
                     ELSE
                       PUT 0.0                        ,'%'    TO LCD BY F(10,2),A;
                     FIN;
    CALL D_CS(2,16); PUT 'Heizpatrone:  ',FL_PWMPRO(1),'%',P_DI(14) TO LCD BY A,F(5,1),A,F(9,1);
                     IF B_IMPNEU(14) THEN                            /*  */
                       PUT '*' TO LCD BY A;                          /*  */
                       B_IMPNEU(14)='0'B;                            /*  */ 
                     ELSE                                            /*  */  
                       PUT ' ' TO LCD BY A;                          /*  */
                     FIN;                                            /*  */
                     PUT Z_ZAEHL(14)/FL_IMP(14)/2.0 TO LCD BY F(10,1);
 !  CALL D_CS(2,17); PUT 'Heizp. unten: ',FL_PWMPRO(2),'%',P_DI(22) TO LCD BY A,F(5,1),A,F(9,1);
 !                   IF B_IMPNEU(22) THEN                            /*  */
 !                     PUT '*' TO LCD BY A;                          /*  */
 !                     B_IMPNEU(22)='0'B;                            /*  */ 
 !                   ELSE                                            /*  */  
 !                     PUT ' ' TO LCD BY A;                          /*  */
 !                   FIN;                                            /*  */
 !                   PUT Z_ZAEHL(22)/FL_IMP(22)/2.0 TO LCD BY F(10,1);

    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;

INP_STROM: PROC;

  IND=1; 
  WHILE IND > 0 AND IND <= 1 REPEAT 
    
    B_EINOBJ='1'B;

    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,'  Strom Erzeugung/Einspeisung ' TO LCD BY A,A,A;
    CALL D_CS(1,3);
    PUT ' erlaubte Einsp. der Erz.:  ',BUTT,FL_EXPHK(15),' %' TO LCD BY A,A,F(6,1),A;

    M=1; /* Eingabepunkt 1-2                                     */
    WHILE M>0 AND M<2 REPEAT
      CASE M
        ALT CALL INP_FLO(31,3,5,1,0.1   ,99.0,0.1   ,FL_EXPHK(15)  ,'STROMOUT');     IF X_R > 3 THEN  M=M-1;  FIN;
        OUT;
      FIN;
      CALL LRROT(M); /* LINKS, RECHTS, EINGABE?        */
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        M=X_R-1001;
      FIN;  
    END; /* of WHILE 1-2                               */

    IF B_EINOBJ THEN  
      EXIT;
    FIN;

  END;
END; /* of PROC INP_WWREG                                  */


/*********************************************************************/
/* Schornsteinfegermenue                                             */
/*********************************************************************/
SCHORNOUT: TASK PRIO 19;
  DCL F1 FIXED;

  REPEAT
    CALL D_CS(28,1);
    PUT ZP_NOW TO LCD BY T(9);
    F1=9;
    FOR I TO N_KESSEL REPEAT
      CALL D_CS(15,F1);
      IF Z_SCHORNK(I) > 2 THEN
        IF Z_SCHORNKMAX(I) > 2 THEN
          PUT 'noch',Z_SCHORNK(I),'s     ',Z_SCHORNKMAX(I),'s MAX' TO LCD BY A,F(5),A,F(5),A;
        ELSE
          PUT 'noch',Z_SCHORNK(I),'s MIN     0s MAX' TO LCD BY A,F(5),A;
        FIN;
      ELSE
        PUT '                          ' TO LCD BY A;
      FIN;
      F1=F1+1;
    END;
    FOR I TO N_BHKW REPEAT
      CALL D_CS(15,F1);
      IF Z_SCHORNB(I) > 2 THEN
        PUT 'noch',Z_SCHORNB(I),'s' TO LCD BY A,F(5),A;
      ELSE
        PUT '           ' TO LCD BY A;
      FIN;
      F1=F1+1;
    END;
    BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */
    AFTER 2 SEC RESUME;
  END;
END;


INP_SCHORN: PROC;
  DCL ZTK(10) FIXED;

  FOR I TO 10 REPEAT
    ZTK(I)=0;
    IF Z_SCHORNK(I) > 0 THEN
      ZTK(I)=1;
    FIN;
    IF Z_SCHORNKMAX(I) > 0 THEN
      ZTK(I)=2;
    FIN;
  END;

  CALL D_CLR;
  M=1;

  WHILE M > 0 AND M <= (N_KESSEL+N_BHKW) REPEAT

    Z_BUTTON=0;
    CALL D_CS(1,1);
    PUT BUTT,'   SCHORNSTEINFEGERMENUE:' TO LCD BY A,A,SKIP;
    PUT 'ROT mit AUF/AB-Tasten auf den' TO LCD BY A,SKIP;
    PUT 'gewuenschten Waermeerzeuger stellen und' TO LCD BY A,SKIP;
    PUT 'dann mit der EINGABE-Taste den' TO LCD BY A,SKIP;
    PUT 'Waermeerzeuger starten (MANUELL EIN).' TO LCD BY A,SKIP;
    PUT 'Nochmal Eingabe-Taste: Anf. MAX 240s ' TO LCD BY A,SKIP;
    PUT 'Ende: nach 20MIN zurueck auf AUTOMATIK.' TO LCD BY A,SKIP;
  
    CALL D_CS(1,9);
    FOR I TO N_KESSEL REPEAT
      IF M==I THEN
        CALL D_RON;
      FIN;
      PUT BUTT,' Kessel',I TO LCD BY A,A,F(1),SKIP;
      CALL D_ROFF;
    END;
    FOR I TO N_BHKW REPEAT
      IF M==I+N_KESSEL THEN
        CALL D_RON;
      FIN;
      PUT BUTT,' BHKW',I TO LCD BY A,A,F(1),SKIP;
      CALL D_ROFF;
    END;

    CALL D_ROFF;
    AFTER 0.1 SEC ACTIVATE SCHORNOUT;
    CALL STICK;
    TERMINATE SCHORNOUT;
    IF X_R > 1000 THEN  /* BUTTON geklickt */
      M=X_R-1001;
      IF M==0 THEN
        EXIT;
      ELSE
        X_R=5;
      FIN;
    FIN;  
    
    CASE X_R                       /* */
      ALT /* O                     /* */ 
        M=M-1;                     /* */
      ALT /* U                     /* */
        M=M+1;                     /* */
      ALT /* LI                    /* */
        M=0;                       /* */
      ALT /* RE                    /* */         
      ALT /* RO                    /* */
        IF M > N_KESSEL THEN                    
          IF Z_SCHORNB(M-N_KESSEL) > 0 THEN
            Z_SCHORNB(M-N_KESSEL)=0;
          ELSE
            Z_SCHORNB(M-N_KESSEL)=1200;
          FIN;
        ELSE
          IF ZTK(M) == 0 THEN
            Z_SCHORNK(M)=1200;   
            ZTK(M)=1;
          ELSE
            IF ZTK(M) == 1 THEN
              Z_SCHORNKMAX(M)=240;   
              ZTK(M)=2;
            ELSE
              IF ZTK(M) == 2 THEN
                IF Z_SCHORNKMAX(M) > 0 THEN
                  Z_SCHORNKMAX(M)=0;   
                  ZTK(M)=3;
                ELSE
                  Z_SCHORNKMAX(M)=240;   
                FIN;
              FIN;
            FIN;
          FIN;
          IF ZTK(M) == 3 THEN
            Z_SCHORNK(M)=0;   
            ZTK(M)=0;
          FIN;
        FIN;
      OUT
    FIN;                           /* */

  END;
  PREVENT SCHORNOUT;
  TERMINATE SCHORNOUT;
    
END;




/*********************************************************************/
/* JETZT FOLGEN PROCEDUREN DIE ETWAS ALLGEMEINER SIND                */
/*********************************************************************/

/*********************************************************************/
/* Eingabe der Fuehrungsreihenfolge fuer BHKW, Kessel, Speicher      */
/*********************************************************************/
INP_FUEHR: PROC (ID        FIXED,        /* Name fuer Anzeige        */
                 ANZAHL    FIXED,        /* Anzahl der Systeme       */
                 RANG   () FIXED IDENT); /* Rangfolge                */

  /* Maximal 10 Positionen koennen eingegeben werden:                */
  DCL DUMMY(10) FIXED; /* Neue Reihenfolge erst in Dummy ablegen     */
  DCL NAME     CHAR(8);
  DCL AUTO     BIT(1);

  CASE ID
    ALT
      NAME='BHKW    ';
      AUTO=B_FSLBHKWAUTO;
    ALT
      NAME='Kessel  ';
      AUTO=B_FSLKESAUTO;
    ALT
      NAME='Speicher';
      AUTO='0'B;
    OUT
  FIN;

  CALL D_CLR;
  IF ANZAHL<2 THEN /* Keine Reihenfolge bei 0-1 Systemen:            */
    PUT '<',BUTT,'      Nicht genuegend ',NAME,'!' TO LCD BY SKIP,SKIP,A,A,A,A,A;
    CALL STICK;
  ELSE
    N=1; /* Abbruchbedingung fuer While-Schleife                      */
    WHILE N==1 REPEAT; /* Eingabe solange, bis eindeutige Reihenfolge*/
      PUT '<',BUTT,' Rangfolgen der ',NAME TO LCD BY A,A,A,A;
      
      CALL D_CS(1,3);
      PUT 'Sortierung: ' TO LCD BY A;
      IF AUTO THEN
        PUT 'AUTOMA' TO LCD BY A;
      ELSE
        PUT 'MANUEL' TO LCD BY A;
      FIN;
      
      /* Ausgabe der aktuellen Reihenfolge:                          */
      CALL D_CS(1,5);
      PUT 'Manuelle Reihenfolge der Systeme: ',
           NAME  ,
          'Platz' 
      TO LCD BY A,SKIP,SKIP,A,SKIP,SKIP,A;

      FOR I TO ANZAHL REPEAT;
        DUMMY(I)=RANG(I);
        CALL D_CS(I*3+8,7); PUT I          TO LCD BY F(1);
        CALL D_CS(I*3+8,9); PUT DUMMY(I)   TO LCD BY F(1);
      END;

      CALL INP_BIT(12,3,'AUTOMA','MANUEL',AUTO,'LEER'); 
      IF X_R > 1000 THEN  /* BUTTON geklickt */
        GOTO AUSGANG;
      FIN;  
      CASE ID
        ALT
          B_FSLBHKWAUTO=AUTO;
        ALT
          B_FSLKESAUTO=AUTO;
        ALT
          AUTO='0'B;
        OUT
      FIN;

      /* Eingabe der neuen Reihenfolge  */
      M=1; /* Zeiger vorbesetzen                                     */
      WHILE M>0 AND M<=ANZAHL REPEAT /* Eingabe der neuen Reihenfolge*/
        CALL INP_FIX(M*3+7,9,1,1,ANZAHL,1,DUMMY(M),'LEER');
        CALL LRROT(M);  /* LINKS, RECHTS oder ROT bet{tigt ?         */
        IF X_R > 1000 THEN  /* BUTTON geklickt */
          GOTO AUSGANG;
        FIN;  
      END;

      /* Syntaxcheck: Pruefen ob Elemente doppelt vorhanden sind     */
      N=0; /* Wenn N=1 wird, ist ein Element doppelt vorhanden       */
      FOR I TO ANZAHL REPEAT /* Jedes Element mit jedem vergleichen: */
        FOR J FROM I+1 TO ANZAHL REPEAT;
          /* Ist die Elementnummer gleich einer anderen ?            */
          IF DUMMY(I) == DUMMY(J) AND I /= J THEN
            N=1; /* dann Merker setzen                               */
          FIN;
        END;
      END;

      IF N==1 THEN /* Warnmeldung ausgeben:                          */
        CALL D_CS(1,1);
        PUT '> Systeme doppelt vorhanden, nochmal ! <' TO LCD;
        AFTER 2.5 SEC RESUME;
        CALL D_CLR;
      FIN;

    END;
    CALL D_CS(1,1);
    PUT '> Reihenfolge OK ? Dann EINGABETASTE ! <' TO LCD;
    CALL STICK;
    IF X_R==K_E THEN /* Wenn ROT bet{tigt,                           */
      /* Rangfolge uebernehmen                                       */
      FOR I TO ANZAHL REPEAT;
        RANG(I)   =DUMMY(I);
      END;
    FIN;
    FOR I TO ANZAHL REPEAT /* aktuellen Zustand nochmal darstellen:  */
      CALL D_CS(I*3+8,9); PUT RANG(I)    TO LCD BY F(1);
    END;
  FIN;
  AUSGANG:

END; /* of PROC INP_FUEHR */


ZEITBHKW: PROC(K FIXED);

  DCL X_J FIXED(31);
  DCL X_K FIXED(31);

  X_J=ENTIER(Z_BLZ(K)/3600);
  CALL D_CS(20,3); 
  PUT '  aktuell: ',X_J TO LCD BY A,F(4);
  X_K=ENTIER((Z_BLZ(K)-X_J*3600)/60);
  X_J=Z_BLZ(K)-X_J*3600-X_K*60;
  PUT ':',X_K,':',X_J TO LCD BY A,F(2),A,F(2);
  FOR I FROM 2 TO 13 REPEAT
    X_J=ENTIER(Z_BLAUFZ(K,I)/3600);
    CALL D_CS(20,I+3); PUT  X_J TO LCD BY F(4);
    X_K=ENTIER((Z_BLAUFZ(K,I)-X_J*3600)/60);
    X_J=Z_BLAUFZ(K,I)-X_J*3600-X_K*60;
    PUT ':',X_K,':',X_J,DAT_BAUS(K,I),ZP_BAUS(K,I)
    TO LCD BY A,F(2),A,F(2),F(3),T(9);
  END;
  CALL D_CS(38,16); PUT 'vvv' TO LCD BY A;  
END;


ZEITKESSEL: PROC(K FIXED);

  DCL X_J FIXED(31);
  DCL X_K FIXED(31);

  X_J=ENTIER(Z_KLZ(K)/3600);
  CALL D_CS(20,3); 
  PUT '  aktuell: ',X_J TO LCD BY A,F(4);
  X_K=ENTIER((Z_KLZ(K)-X_J*3600)/60);
  X_J=Z_KLZ(K)-X_J*3600-X_K*60;
  PUT ':',X_K,':',X_J TO LCD BY A,F(2),A,F(2);
  FOR I FROM 2 TO 13 REPEAT
    X_J=ENTIER(Z_KLAUFZ(K,I)/3600);
    CALL D_CS(20,I+3); PUT  X_J TO LCD BY F(4);
    X_K=ENTIER((Z_KLAUFZ(K,I)-X_J*3600)/60);
    X_J=Z_KLAUFZ(K,I)-X_J*3600-X_K*60;
    PUT ':',X_K,':',X_J,DAT_KAUS(K,I),ZP_KAUS(K,I)
    TO LCD BY A,F(2),A,F(2),F(3),T(9);
  END;
  CALL D_CS(38,16); PUT 'vvv' TO LCD BY A;  
END;


NEUSTART: PROC; /* loest ueber den Watchdog einen Reset aus:           */
  CALL D_CLR; PUT 'Neustart, bitte warten...' TO LCD;
  AFTER 1 SEC RESUME;
  B_BENUTZER='0'B; /* Watchdog den Reset ausloesen lassen             */
  B_WDINIT  ='0'B; /* Watchdog den Reset ausloesen lassen             */
  REPEAT
    ZP_NOW=NOW;
    CALL D_CS(10,4);
    PUT ZP_NOW TO LCD BY T(12,1);
    AFTER 1 SEC RESUME;
  END;
END;


/*********************************************************************/
/* Grafischer Wochenkalender                                         */
/*********************************************************************/
STRICH: PROC((NUM,ZEIT,ART)  FIXED);

  DCL INDEX1 FIXED;
  DCL INDEX2 FIXED;


  INDEX1=(NUM-1)//16+1;
  INDEX2=(NUM-1) REM 16+1;

  X_POS=8+(ZEIT-1) REM 72;
  Y_POS=4+((ZEIT-1)//72);
  CALL D_CS(X_POS,Y_POS);
  /* darstellen des Zustandes des Zehnminutenwertes                */
  IF B_ZONE1(INDEX1,ZEIT).BIT(INDEX2) THEN
    PUT '1' TO LCD BY A;
  ELSE
    PUT '0' TO LCD BY A;
  FIN;
 
END;

/* ]bersicht des Kalenders erstellen                                 */
ABSSCHAU: PROC((NUM,ART) FIXED); /* Zonennummer, ART                 */

  /* Erstellung der Oberfl{che                            */
 
  CALL D_CS(1,4);
  FOR I TO 7 REPEAT
    PUT TX_TAG(I),'  12 ' TO LCD BY A(2),A,SKIP;
    PUT TX_TAG(I),'  24 ' TO LCD BY A(2),A,SKIP;
  END;
 
  FOR I TO 1008 REPEAT
    CALL STRICH(NUM,I,ART);
    IF I REM 20 == 0 THEN
      AFTER 0.04 SEC RESUME;
    FIN;
  END;
 
END; /* of PROC */


/*********************************************************************/
/* Darstellen der aktuellen Cursorposition und Uhrzeit mit Datum     */
/*********************************************************************/
CURS: PROC((NUM,ZEIT) FIXED);
  DCL Z_ZEIT   CLOCK; 
  DCL INDEX1 FIXED;
  DCL INDEX2 FIXED;

 
  /* Anzeigen: Zeitpunkt  */
  CALL D_CS(40,2);
  CASE ((ZEIT-1)//144+1)
    ALT
      PUT 'Montag    ' TO LCD BY A;
    ALT
      PUT 'Dienstag  ' TO LCD BY A;
    ALT
      PUT 'Mittwoch  ' TO LCD BY A;
    ALT
      PUT 'Donnerstag' TO LCD BY A;
    ALT
      PUT 'Freitag   ' TO LCD BY A;
    ALT
      PUT 'Samstag   ' TO LCD BY A;
    ALT
      PUT 'Sonntag   ' TO LCD BY A;
  FIN;

  Z_ZEIT=00:00:00+(((ZEIT-1) REM 144)*10 MIN); 

  PUT Z_ZEIT TO LCD BY X(2),T(8);

  X_POS=8+(ZEIT-1) REM 72;
  Y_POS=4+((ZEIT-1)//72);
  CALL D_CS(X_POS,Y_POS);
  CALL D_RON;

  INDEX1=(NUM-1)//16+1;
  INDEX2=(NUM-1) REM 16+1;
  /* darstellen des Zustandes des Zehnminutenwertes                */
  IF B_ZONE1(INDEX1,ZEIT).BIT(INDEX2) THEN
    PUT '1' TO LCD BY A;
  ELSE
    PUT '0' TO LCD BY A;
  FIN;
  CALL D_ROFF;
 

END;

/*********************************************************************/
/* Eingabe des Absenkungskalenders:                                  */
/*********************************************************************/
INP_ABS: PROC((NUM,ART) FIXED) GLOBAL;   /* Zonennummer und Art             */

 /*-----------------------------------------------------------------*/
  DCL ACT          FIXED;    /* 1: Schauen                          */
                             /* 2: B_ZONE1 setzen                   */
  DCL AKT_ZEIT FIXED;        /* Wochenzeit in Fixed                 */
  DCL ALT_ZEIT FIXED;        /* Merker f}r Wochenzeit               */
  DCL TAG_NORM FIXED;        /* Mit ZF_abstakt normierter Tag       */
  DCL INDEX1   FIXED;        /* Index f}r Absenkungsvariablen       */
  DCL INDEX2   FIXED;        /* Index f}r Absenkungsvariablen       */
  DCL X_I      FIXED;
  DCL F15      FIXED;
  DCL TAGAKT   FIXED;
  DCL TAGNEU   FIXED;
  DCL NUMVIS   FIXED;

  TAG_NORM=144;
  ACT=1;

  NUMVIS=NUM;
  IF NUM > 100 THEN  NUM=NUM-100;  FIN;    /* <<< Aufruf kommt von VIS-Button */

  INDEX1=(NUM-1)//16+1;
  INDEX2=(NUM-1) REM 16+1;

  CASE ART
    ALT       /* TARIFKALENDER mit 2 m|glichen Zust{nden            */
      DISPSTATUS.BIT( 1)='0'B; /* normales Display  */
      DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
      DISPSTATUS.BIT( 3)='1'B; /* grosses Display   */
      DISPSTATUS.BIT( 4)='1'B; /* grafischer Absenkungskalender */
      CALL DISPSTAT;

      CALL D_CLR;
      CALL D_CS(1,1);
      Z_BUTTON=0;
      PUT '<',BUTT,'  Wochenkalender von: ' TO LCD BY A,A,A,SKIP;
      PUT T_NAME(NUM) TO LCD BY X(13),A;

      BUTTON(2,1)=2;  /* <<< BUTTON Wokal anschauen */
      BUTTON(2,2)=15;
      BUTTON(3,1)=2;  /* BUTTON rot setzen      */
      BUTTON(3,2)=16;
      BUTTON(4,1)=2;  /* BUTTON blau setzen     */
      BUTTON(4,2)=17;
      Z_BUTTON=4;

      CALL ABSSCHAU(NUM,ART);
      ACT=1;
      CALL D_CS(3,19);
      PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A,SKIP;
      IF (B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1 THEN   /* STST */
        PUT '  (EINGABE blockiert)           ' TO LCD BY A;     
      ELSE
        PUT '  (mit EINGABE Aktion aendern)  ' TO LCD BY A;     
      FIN;

      AKT_ZEIT=Z_ZEHN;
      IF AKT_ZEIT>980 THEN AKT_ZEIT=980; FIN;
      IF AKT_ZEIT<28 THEN AKT_ZEIT=28; FIN;
      ALT_ZEIT=AKT_ZEIT;

      WHILE AKT_ZEIT>0 AND AKT_ZEIT<1009 REPEAT /* in der Woche   */

        IF X_R/=5 AND X_R/=3000 THEN
          IF AKT_ZEIT>=ALT_ZEIT THEN
            FOR K FROM ALT_ZEIT TO AKT_ZEIT REPEAT
              CASE ACT
                ALT
                ALT
                  B_ZONE1(INDEX1,K).BIT(INDEX2)='1'B;
                ALT
                  B_ZONE1(INDEX1,K).BIT(INDEX2)='0'B;
                OUT
              FIN;
              CALL STRICH(NUM,K,ART);
            END;
          FIN;
          IF ALT_ZEIT>AKT_ZEIT THEN
            FOR K FROM AKT_ZEIT TO ALT_ZEIT REPEAT
              CASE ACT
                ALT
                ALT
                  B_ZONE1(INDEX1,K).BIT(INDEX2)='1'B;
                ALT
                  B_ZONE1(INDEX1,K).BIT(INDEX2)='0'B;
                OUT
              FIN;
              CALL STRICH(NUM,K,ART);
            END;
          FIN;
        FIN;

        /* ... und Absenkungszustand */
        CALL D_CS(45,3);
        IF B_ZONE1(INDEX1,AKT_ZEIT).BIT(INDEX2) THEN
          PUT '     HT     ' TO LCD BY A;
        ELSE
          PUT '     NT     ' TO LCD BY A;
        FIN;

        /* darstellen der aktuellen Cursorposition                 */
        CALL CURS(NUM,AKT_ZEIT);

        CALL STICK;            /* Bewegung abwarten             */

        /* l|schen der alten Cursorposition                     */
        CALL STRICH(NUM,AKT_ZEIT,ART);


          IF X_R > 1000 THEN
            IF X_R==1001 THEN                                     /* BUTTON raus */
              IF NUMVIS < 100 THEN  AKT_ZEIT=0;  FIN;             /* Raus nur wenn NICHT Aufruf aus VISU */ 
            FIN;
            IF X_R==1002 THEN                                     /* BUTTON Wochenkalender anschauen */
              ACT=1;
              ALT_ZEIT=AKT_ZEIT;
              CALL D_CS(3,19);
              PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A,SKIP;
            FIN;
            IF X_R==1003 AND NOT ((B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1) THEN  /* BUTTON rot setzen */
              ACT=2;
              X_R=3000;
              ALT_ZEIT=AKT_ZEIT;
              CALL D_CS(3,19);
              PUT 'Aktion:  HT  setzen             ' TO LCD BY A,SKIP;
            FIN;
            IF X_R==1004 AND NOT ((B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1) THEN  /* BUTTON blau setzen */
              ACT=3;
              X_R=3000;
              ALT_ZEIT=AKT_ZEIT;
              CALL D_CS(3,19);
              PUT 'Aktion:  NT  setzen             ' TO LCD BY A,SKIP;
            FIN;
            IF X_R > 4000 THEN                                    /* Klick in Wochenkalender */
         !    TAGAKT=AKT_ZEIT//TAG_NORM;
              X_I=X_R-4000;
         !    TAGNEU=X_I//TAG_NORM;
         !    F15=X_I-TAGNEU*TAG_NORM;                            /* Zehnminutenstand des geklickten Tages */
              F15=X_I-AKT_ZEIT;
              IF ACT==1 THEN
                ALT_ZEIT=AKT_ZEIT;
                AKT_ZEIT=X_I;
              ELSE
         !      IF F15 < 7 OR F15 > 138 OR TAGNEU==TAGAKT THEN
                IF ABS(F15) < 31 OR X_ZUGANG == 5 THEN
                  ALT_ZEIT=AKT_ZEIT;
                  AKT_ZEIT=X_I;
                ELSE
                  AKT_ZEIT=X_I;
                  ALT_ZEIT=AKT_ZEIT;
                  X_R=3000;
                FIN;
              FIN;
            FIN;
          ELSE
            ALT_ZEIT=AKT_ZEIT;
          FIN;


        IF X_F > 6 THEN
          /* BEGRENZUNG AUF STUNDENSPR]NGE */
          X_F = 6;
        FIN;
  
 
        CASE X_R
          ALT /* OBEN --------------------------------------------*/
            AKT_ZEIT=AKT_ZEIT-TAG_NORM;
            ALT_ZEIT=AKT_ZEIT;
            X_F=1;
          ALT /* UNTEN -------------------------------------------*/
            AKT_ZEIT=AKT_ZEIT+TAG_NORM;
            ALT_ZEIT=AKT_ZEIT;  
            X_F=1;
          ALT /* LINKS -------------------------------------------*/
            IF AKT_ZEIT<10 THEN
              X_F=1;
            FIN;
            AKT_ZEIT=AKT_ZEIT-X_F;
          ALT /* RECHTS -----------------------------------------*/
            IF AKT_ZEIT>1000 THEN
              X_F=1;
            FIN;
            AKT_ZEIT=AKT_ZEIT+X_F;
          ALT /* ROT ---------------------------------------------*/
            IF B_ROTSP AND X_ZUGANG < 1 THEN   /* STST */
              IF X_ZUGANGKAL > 0 THEN
                CALL INP_ROTSP;
              FIN;
            ELSE
              IF ACT<3 THEN
                ACT=ACT+1;
              ELSE
                ACT=1;
              FIN;
              CALL D_CS(3,19);
              CASE ACT
                ALT
                  PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A,SKIP;
                ALT
                  PUT 'Aktion:  HT  setzen             ' TO LCD BY A,SKIP;
                ALT
                  PUT 'Aktion:  NT  setzen             ' TO LCD BY A,SKIP;
                OUT
              FIN;
            FIN;
          OUT
        FIN;
        CALL D_CS(1,20);
        IF (B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1 THEN   /* STST */
          PUT '  (EINGABE blockiert)           ' TO LCD BY A;
          ACT=1;
          CALL D_CS(3,19);
          PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A;
        ELSE
          PUT '  (mit EINGABE Aktion aendern)  ' TO LCD BY A;     
        FIN;

      END;
    ALT       /* Timer mit 2 m|glichen Zust{nden               */
      DISPSTATUS.BIT( 1)='0'B; /* normales Display  */
      DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
      DISPSTATUS.BIT( 3)='1'B; /* grosses Display   */
      DISPSTATUS.BIT( 4)='1'B; /* grafischer Absenkungskalender */
      CALL DISPSTAT;

      CALL D_CLR;
      CALL D_CS(1,1);
      Z_BUTTON=0;
      PUT '<',BUTT,'  Wochenkalender von: ' TO LCD BY A,A,A,SKIP;
      PUT T_NAME(NUM) TO LCD BY X(13),A;

      BUTTON(2,1)=2;  /* <<< BUTTON Wokal anschauen */
      BUTTON(2,2)=15;
      BUTTON(3,1)=2;  /* BUTTON rot setzen      */
      BUTTON(3,2)=16;
      BUTTON(4,1)=2;  /* BUTTON blau setzen     */
      BUTTON(4,2)=17;
      Z_BUTTON=4;

      CALL ABSSCHAU(NUM,ART);
      ACT=1;
      CALL D_CS(3,19);
      PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A,SKIP;
      IF (B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1 THEN   /* STST */
        PUT '  (EINGABE blockiert)           ' TO LCD BY A;     
      ELSE
        PUT '  (mit EINGABE Aktion aendern)  ' TO LCD BY A;     
      FIN;
   !  IF B_FERN AND NOT B_MTERM30 THEN
   !    PUT '   genaue Zeitangabe ueber      ' TO LCD BY A,SKIP;
   !  ELSE
   !    PUT ' genaue Zeitangabe rechts neben ' TO LCD BY A,SKIP;
   !  FIN;
   !  PUT '           Kalender!            ' TO LCD BY A,SKIP;

      AKT_ZEIT=Z_ZEHN;
      IF AKT_ZEIT>980 THEN AKT_ZEIT=980; FIN;
      IF AKT_ZEIT<28 THEN AKT_ZEIT=28; FIN;
      ALT_ZEIT=AKT_ZEIT;

      WHILE AKT_ZEIT>0 AND AKT_ZEIT<1009 REPEAT /* in der Woche   */

        IF X_R/=5 AND X_R/=3000 THEN
          IF AKT_ZEIT>=ALT_ZEIT THEN
            FOR K FROM ALT_ZEIT TO AKT_ZEIT REPEAT
              CASE ACT
                ALT
                ALT
                  B_ZONE1(INDEX1,K).BIT(INDEX2)='1'B;
                ALT
                  B_ZONE1(INDEX1,K).BIT(INDEX2)='0'B;
                OUT
              FIN;
              CALL STRICH(NUM,K,ART);
            END;
          FIN;
          IF ALT_ZEIT>AKT_ZEIT THEN
            FOR K FROM AKT_ZEIT TO ALT_ZEIT REPEAT
              CASE ACT
                ALT
                ALT
                  B_ZONE1(INDEX1,K).BIT(INDEX2)='1'B;
                ALT
                  B_ZONE1(INDEX1,K).BIT(INDEX2)='0'B;
                OUT
              FIN;
              CALL STRICH(NUM,K,ART);
            END;
          FIN;
        FIN;

        /* ... und Absenkungszustand */
        CALL D_CS(45,3);
        IF B_ZONE1(INDEX1,AKT_ZEIT).BIT(INDEX2) THEN
          IF NUM<66 THEN  /* <<< */  
             PUT '    EIN     ' TO LCD BY A; 
          ELSE
             PUT '   AUTO     ' TO LCD BY A;
          FIN;
        ELSE
          PUT '    AUS     ' TO LCD BY A;
        FIN;

        /* darstellen der aktuellen Cursorposition                 */
        CALL CURS(NUM,AKT_ZEIT);

        CALL STICK;            /* Bewegung abwarten             */

        /* l|schen der alten Cursorposition                     */
        CALL STRICH(NUM,AKT_ZEIT,ART);


        IF X_R > 1000 THEN
          IF X_R==1001 THEN                                     /* BUTTON raus */
            IF NUMVIS < 100 THEN  AKT_ZEIT=0;  FIN;             /* Raus nur wenn NICHT Aufruf aus VISU */ 
          FIN;
          IF X_R==1002 THEN                                     /* BUTTON Wochenkalender anschauen */
            ACT=1;
            ALT_ZEIT=AKT_ZEIT;
            CALL D_CS(3,19);
            PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A,SKIP;
          FIN;
          IF X_R==1003 AND NOT ((B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1) THEN  /* BUTTON rot setzen */
            ACT=2;
            X_R=3000;
            ALT_ZEIT=AKT_ZEIT;
            CALL D_CS(3,19);
            PUT 'Aktion:  EINschalten            ' TO LCD BY A,SKIP;
          FIN;
          IF X_R==1004 AND NOT ((B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1) THEN  /* BUTTON blau setzen */
            ACT=3;
            X_R=3000;
            ALT_ZEIT=AKT_ZEIT;
            CALL D_CS(3,19);
            PUT 'Aktion:  AUSschalten            ' TO LCD BY A,SKIP;
          FIN;
          IF X_R > 4000 THEN                                    /* Klick in Wochenkalender */
       !    TAGAKT=AKT_ZEIT//TAG_NORM;
            X_I=X_R-4000;
       !    TAGNEU=X_I//TAG_NORM;
       !    F15=X_I-TAGNEU*TAG_NORM;                            /* Zehnminutenstand des geklickten Tages */
            F15=X_I-AKT_ZEIT;
            IF ACT==1 THEN
              ALT_ZEIT=AKT_ZEIT;
              AKT_ZEIT=X_I;
            ELSE
       !      IF F15 < 7 OR F15 > 138 OR TAGNEU==TAGAKT THEN
              IF ABS(F15) < 31 OR X_ZUGANG == 5 THEN
                ALT_ZEIT=AKT_ZEIT;
                AKT_ZEIT=X_I;
              ELSE
                AKT_ZEIT=X_I;
                ALT_ZEIT=AKT_ZEIT;
                X_R=3000;
              FIN;
            FIN;
          FIN;
        ELSE
          ALT_ZEIT=AKT_ZEIT;
        FIN;


        IF X_F > 6 THEN
          /* BEGRENZUNG AUF STUNDENSPR]NGE */
          X_F = 6;
        FIN;


        CASE X_R
          ALT /* OBEN --------------------------------------------*/
            AKT_ZEIT=AKT_ZEIT-TAG_NORM;
            ALT_ZEIT=AKT_ZEIT;
            X_F=1;
          ALT /* UNTEN -------------------------------------------*/
            AKT_ZEIT=AKT_ZEIT+TAG_NORM;
            ALT_ZEIT=AKT_ZEIT;  
            X_F=1;
          ALT /* LINKS -------------------------------------------*/
            IF AKT_ZEIT<10 THEN
              X_F=1;
            FIN;
            AKT_ZEIT=AKT_ZEIT-X_F;
          ALT /* RECHTS -----------------------------------------*/
            IF AKT_ZEIT>1000 THEN
              X_F=1;
            FIN;
            AKT_ZEIT=AKT_ZEIT+X_F;
          ALT /* ROT ---------------------------------------------*/
            IF B_ROTSP AND X_ZUGANG < 1 THEN   /* STST */
              IF X_ZUGANGKAL > 0 THEN
                CALL INP_ROTSP;
              FIN;
            ELSE
              IF ACT<3 THEN
                ACT=ACT+1;
              ELSE
                ACT=1;
              FIN;
              CALL D_CS(3,19);
              CASE ACT
                ALT
                  PUT 'Aktion: Wochenkalender anschauen'
                    TO LCD BY A,SKIP;
                ALT
                  IF NUM<66 THEN /* <<< */
                    PUT 'Aktion:  EINschalten            ' TO LCD BY A,SKIP;
                  ELSE
                    PUT 'Aktion:  AUTOschalten           ' TO LCD BY A,SKIP;
                  FIN; 
                ALT
                  PUT 'Aktion:  AUSschalten            ' TO LCD BY A,SKIP;
                OUT
              FIN;
            FIN;
          OUT
        FIN;
        CALL D_CS(1,20);
        IF (B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1 THEN   /* STST */
          PUT '  (EINGABE blockiert)           ' TO LCD BY A;
          ACT=1;
          CALL D_CS(3,19);
          PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A;
        ELSE
          PUT '  (mit EINGABE Aktion aendern)  ' TO LCD BY A;     
        FIN;

      END;

    ALT       /* Heizkreiswochenkalender mit 2 m|glichen Zust{nden  */
      CALL D_CLR;
      PUT '<',BUTT,'  Heizkreiswochenkalender' TO LCD BY A,A,A;
      CALL D_CS(1,3);
      PUT '   von   ' TO LCD BY A;
      PUT HK_NAME(NUM) TO LCD BY A,SKIP,SKIP;
      PUT '             ',BUTT TO LCD BY A,A,SKIP;
      PUT ' Zustand:    ',BUTT TO LCD BY A,A;
      CASE ZUST_HK(NUM)
        ALT
          PUT '   Automatikbetrieb   ' TO LCD BY A,SKIP;   
        ALT
          PUT '   Dauernachtbetrieb  ' TO LCD BY A,SKIP;    
        ALT
          PUT '   Dauertagbetrieb    ' TO LCD BY A,SKIP;    
        OUT
          PUT '   Dauertagbetrieb T2 ' TO LCD BY A,SKIP;    
      FIN;


      M=1;
    ! IF NUMVIS > 100 THEN  M=6;  FIN;  /* <<< sofort zum Kalender */
      M=6;                              /* <<< sofort zum Kalender */
      WHILE M>0 AND M<3 REPEAT
        CASE M
          ALT  /* zum Kalender?      */
            CALL D_CS(16,5);
            CALL D_RON;
            PUT '  zum Kalender >' TO LCD BY A,A;
            CALL D_ROFF;
            CALL STICK;
            IF X_R > 1000 THEN  /* BUTTON geklickt */
              IF X_R==1001 THEN  M=0;  FIN; /* EXIT */
              IF X_R==1002 THEN  M=6;  FIN; /* zum Kalender */
              IF X_R==1003 THEN  M=2;  FIN; /* Zustand      */
            ELSE
              IF X_R==3   THEN  M=0;  FIN; /* EXIT */
              IF X_R==4   THEN  M=6;  FIN; /* zum Kalender */
              IF X_R==2   THEN  M=2;  FIN; /* Zustand      */
            FIN;  
            CALL D_CS(16,5);
            PUT '  zum Kalender >' TO LCD BY A,A;
            
          ALT  /* Zustand       */
            CHB(1)=' Automatikbetrieb     ';
            CHB(2)=' Dauernachtbetrieb    ';
            CHB(3)=' Dauertagbetrieb      ';
            CALL INP_BETRIEB(16,6,CHB,3,ZUST_HK(NUM),'LEER        ');
            M=1;
          OUT
        FIN;

      END;

      IF M>4 THEN
        DISPSTATUS.BIT( 1)='0'B; /* normales Display  */
        DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
        DISPSTATUS.BIT( 3)='1'B; /* grosses Display   */
        DISPSTATUS.BIT( 4)='1'B; /* grafischer Absenkungskalender */
        CALL DISPSTAT;

        CALL D_CLR;
        CALL D_CS(1,1);
        Z_BUTTON=0;
        PUT '<',BUTT,'  Wochenkalender von Heizkreis: ' TO LCD BY A,A,A,SKIP;
        PUT HK_NAME(NUM) TO LCD BY X(13),A;

        BUTTON(2,1)=2;  /* <<< BUTTON Wokal anschauen */
        BUTTON(2,2)=15;
        BUTTON(3,1)=2;  /* BUTTON rot setzen      */
        BUTTON(3,2)=16;
        BUTTON(4,1)=2;  /* BUTTON blau setzen     */
        BUTTON(4,2)=17;
        BUTTON(5,1)=35;  /* BUTTON AUTOMATIKBETRIEB     */
        BUTTON(5,2)=15;
        BUTTON(6,1)=35;  /* BUTTON DAUERTAGBETRIEB     */
        BUTTON(6,2)=16;
        BUTTON(7,1)=35;  /* BUTTON DAUERNACHTBETRIEB     */
        BUTTON(7,2)=17;
        Z_BUTTON=7;

        CALL ABSSCHAU(NUM,ART);

        CALL D_CS(50,19);
        CASE ZUST_HK(NUM)
          ALT
            PUT '1' TO LCD BY A;    /*  Automatikbetrieb  */
          ALT
            PUT '2' TO LCD BY A;    /*  Dauernachtbetrieb  */    
          ALT
            PUT '3' TO LCD BY A;    /*  Dauertagbetrieb  */    
          OUT
            PUT '?  ',ZUST_HK(NUM) TO LCD BY A,F(3);    /*  ???               */    
        FIN;
        
        ACT=1;
        CALL D_CS(3,19);
        PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A,SKIP;
        IF (B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1 THEN   /* STST */
          PUT '  (EINGABE blockiert)           ' TO LCD BY A;     
        ELSE
          PUT '  (mit EINGABE Aktion aendern)  ' TO LCD BY A;     
        FIN;
    !   IF B_FERN AND NOT B_MTERM30 THEN
    !     PUT '   genaue Zeitangabe ueber      ' TO LCD BY A,SKIP;
    !   ELSE
    !     PUT ' genaue Zeitangabe rechts neben ' TO LCD BY A,SKIP;
    !   FIN;
    !   PUT '            Kalender!           ' TO LCD BY A,SKIP;
    !   PUT '  (mit EINGABE Aktion aendern)  ' TO LCD BY A;     

        AKT_ZEIT=Z_ZEHN;
        IF AKT_ZEIT>980 THEN AKT_ZEIT=980; FIN;
        IF AKT_ZEIT<28 THEN AKT_ZEIT=28; FIN;
        ALT_ZEIT=AKT_ZEIT;

        WHILE AKT_ZEIT>0 AND AKT_ZEIT<1009 REPEAT /* in der Woche   */

          IF X_R/=5 AND X_R/=3000 THEN
            IF AKT_ZEIT>=ALT_ZEIT THEN
              FOR K FROM ALT_ZEIT TO AKT_ZEIT REPEAT
                CASE ACT
                  ALT
                  ALT
                    B_ZONE1(INDEX1,K).BIT(INDEX2)='1'B;
                  ALT
                    B_ZONE1(INDEX1,K).BIT(INDEX2)='0'B;
                  OUT
                FIN;
                CALL STRICH(NUM,K,ART);
              END;
            FIN;
            IF ALT_ZEIT>AKT_ZEIT THEN
              FOR K FROM AKT_ZEIT TO ALT_ZEIT REPEAT
                CASE ACT
                  ALT
                  ALT
                    B_ZONE1(INDEX1,K).BIT(INDEX2)='1'B;
                  ALT
                    B_ZONE1(INDEX1,K).BIT(INDEX2)='0'B;
                  OUT
                FIN;
                CALL STRICH(NUM,K,ART);
              END;
            FIN;
          FIN;

          /* ... und Absenkungszustand */
          CALL D_CS(45,3);
          IF B_ZONE1(INDEX1,AKT_ZEIT).BIT(INDEX2) THEN
            PUT ' Tagbetrieb ' TO LCD BY A;
          ELSE
            PUT ' Nachtbetr. ' TO LCD BY A;
          FIN;

          /* darstellen der aktuellen Cursorposition                 */
          CALL CURS(NUM,AKT_ZEIT);

          CALL STICK;            /* Bewegung abwarten             */

          /* l|schen der alten Cursorposition                     */
          CALL STRICH(NUM,AKT_ZEIT,ART);


          IF X_R > 1000 THEN
            IF X_R==1001 THEN                                     /* BUTTON raus */
              IF NUMVIS < 100 THEN  AKT_ZEIT=0;  FIN;             /* Raus nur wenn NICHT Aufruf aus VISU */ 
            FIN;
            IF X_R==1002 THEN                                     /* BUTTON Wochenkalender anschauen */
              ACT=1;
              ALT_ZEIT=AKT_ZEIT;
              CALL D_CS(3,19);
              PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A,SKIP;
            FIN;
            IF X_R==1003 AND NOT ((B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1) THEN  /* BUTTON rot setzen */
              ACT=2;
              X_R=3000;
              ALT_ZEIT=AKT_ZEIT;
              CALL D_CS(3,19);
              PUT 'Aktion: Tagbetrieb  setzen      ' TO LCD BY A,SKIP;
            FIN;
            IF X_R==1004 AND NOT ((B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1) THEN  /* BUTTON blau setzen */
              ACT=3;
              X_R=3000;
              ALT_ZEIT=AKT_ZEIT;
              CALL D_CS(3,19);
              PUT 'Aktion: Nachtbetrieb setzen     ' TO LCD BY A,SKIP;
            FIN;
            IF X_R==1005 AND NOT ((B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1) THEN  /* BUTTON AUTOMATIKBETRIEB */
              ZUST_HK(NUM)=1;
              CALL D_CS(50,19);
              PUT '1' TO LCD BY A;
            FIN;
            IF X_R==1006 AND NOT ((B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1) THEN  /* BUTTON DAUERTAGBETRIEB */
              ZUST_HK(NUM)=3;
              CALL D_CS(50,19);
              PUT '3' TO LCD BY A;
            FIN;
            IF X_R==1007 AND NOT ((B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1) THEN  /* BUTTON DAUERNACHTBETRIEB */
              ZUST_HK(NUM)=2;
              CALL D_CS(50,19);
              PUT '2' TO LCD BY A;
            FIN;
            IF X_R > 4000 THEN                                    /* Klick in Wochenkalender */
         !    TAGAKT=AKT_ZEIT//TAG_NORM;
              X_I=X_R-4000;
         !    TAGNEU=X_I//TAG_NORM;
         !    F15=X_I-TAGNEU*TAG_NORM;                            /* Zehnminutenstand des geklickten Tages */
              F15=X_I-AKT_ZEIT;
              IF ACT==1 THEN
                ALT_ZEIT=AKT_ZEIT;
                AKT_ZEIT=X_I;
              ELSE
         !      IF F15 < 7 OR F15 > 138 OR TAGNEU==TAGAKT THEN
                IF ABS(F15) < 31 OR X_ZUGANG == 5 THEN
                  ALT_ZEIT=AKT_ZEIT;
                  AKT_ZEIT=X_I;
                ELSE
                  AKT_ZEIT=X_I;
                  ALT_ZEIT=AKT_ZEIT;
                  X_R=3000;
                FIN;
              FIN;
            FIN;
          ELSE
            ALT_ZEIT=AKT_ZEIT;
          FIN;


          IF X_F > 6 THEN
            /* BEGRENZUNG AUF STUNDENSPR]NGE */
            X_F = 6;
          FIN;


          CASE X_R
            ALT /* OBEN --------------------------------------------*/
              AKT_ZEIT=AKT_ZEIT-TAG_NORM;
              ALT_ZEIT=AKT_ZEIT;
              X_F=1;
            ALT /* UNTEN -------------------------------------------*/
              AKT_ZEIT=AKT_ZEIT+TAG_NORM;
              ALT_ZEIT=AKT_ZEIT;
              X_F=1;
            ALT /* LINKS -------------------------------------------*/
              IF AKT_ZEIT<10 THEN
                X_F=1;
              FIN;
              AKT_ZEIT=AKT_ZEIT-X_F;
            ALT /* RECHTS -----------------------------------------*/
              IF AKT_ZEIT>1000 THEN
                X_F=1;
              FIN;
              AKT_ZEIT=AKT_ZEIT+X_F;
            ALT /* ROT ---------------------------------------------*/
              IF B_ROTSP AND X_ZUGANG < 1 THEN   /* STST */
                IF X_ZUGANGKAL > 0 THEN
                  CALL INP_ROTSP;
                FIN;
              ELSE
                IF ACT<3 THEN
                  ACT=ACT+1;
                ELSE
                  ACT=1;
                FIN;
                CALL D_CS(3,19);
                CASE ACT
                  ALT
                    PUT 'Aktion: Wochenkalender anschauen'
                      TO LCD BY A,SKIP;
                  ALT
                    PUT 'Aktion: Tagbetrieb  setzen      '
                      TO LCD BY A,SKIP;
                  ALT
                    PUT 'Aktion: Nachtbetrieb setzen     '
                      TO LCD BY A,SKIP;
                  OUT
                FIN;
              FIN;
            OUT
          FIN;
          CALL D_CS(1,20);
          IF (B_ROTSP AND X_ZUGANG < 1) OR X_ZUGANGKAL < 1 THEN   /* STST */
            PUT '  (EINGABE blockiert)           ' TO LCD BY A;
            ACT=1;
            CALL D_CS(3,19);
            PUT 'Aktion: Wochenkalender anschauen' TO LCD BY A;
          ELSE
            PUT '  (mit EINGABE Aktion aendern)  ' TO LCD BY A;     
          FIN;

        END;

    !   IF X_R < 1000 AND M > 0 THEN
    !     CALL D_CS(1,19);
    !     PUT '                                       ' TO LCD BY A,SKIP;
    !     PUT '            KONTROLLE                  ' TO LCD BY A;
    !  !  PUT '                                       ' TO LCD BY A,SKIP;
    !  !  PUT '                                       ' TO LCD BY A;
    !     CALL D_CS(40,2);
    !     PUT '                                      ' TO LCD BY A;
    !     CALL D_CS(40,3);
    !     PUT '                                      ' TO LCD BY A;
    !     X_H=0;
    !     X_I=0;
    !     B_LOOPB='0'B;
    !     FOR I TO 1008 REPEAT
    !       IF B_ZONE1(INDEX1,I).BIT(INDEX2) THEN
    !         X_H=X_H+1;
    !         IF X_I>0 AND X_I<6 AND I>10 AND I<999 THEN
    !           FOR K FROM I-X_I TO I REPEAT
    !             B_ZONE1(INDEX1,K).BIT(INDEX2)='1'B;
    !           END;
    !           X_H=0;
    !           B_LOOPB='1'B;
    !         FIN;
    !         X_I=0;
    !       ELSE
    !         X_I=X_I+1;
    !         IF X_H>0 AND X_H<6 AND I>10 AND I<999 THEN
    !           FOR K FROM I-X_H TO I REPEAT
    !             B_ZONE1(INDEX1,K).BIT(INDEX2)='0'B;
    !           END;
    !           X_I=0;
    !           B_LOOPB='1'B;
    !         FIN;
    !         X_H=0;
    !       FIN;
    !     END;
    !     AFTER 1 SEC RESUME;
    !     CALL ABSSCHAU(NUM,ART);
    !     CALL D_CS(1,19);
    ! !   PUT '                                       ' TO LCD BY A,SKIP;
    !     PUT '        KONTROLLE  FERTIG              ' TO LCD BY A,SKIP;
    !     IF B_LOOPB THEN
    !       PUT '   (Korrekturen waren noetig)          ' TO LCD BY A;
    !     ELSE
    !       PUT '         (keine Korrekturen)           ' TO LCD BY A;
    !     FIN;
    !     AFTER 3 SEC RESUME;
    !   FIN; /* IF X_R < 1000 */

      FIN;

    OUT
  FIN;

  IF NUMVIS > 100 THEN  PUNKT=1; ZEIG=1;   FIN;  /* <<< Hauptmenue */

  DISPSTATUS.BIT( 1)='1'B; /* normales Display  */
  DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
  DISPSTATUS.BIT( 3)='0'B; /* grosses Display   */
  DISPSTATUS.BIT( 4)='0'B; /* grafischer Absenkungskalender */
  CALL DISPSTAT;

  CALL D_GRAPHCLR; /* Graphik l|schen und auf Textmodus umschalten */

  AFTER 5.5 SEC ACTIVATE RAMSCHREIB;

END;


/* Bedienung Unterstationen ueber CAN    */
BEDIENUST: PROC;

  DCL ZEILE1     FIXED;
  DCL COUNT      FIXED;

  ZEILE1=2;
  COUNT=0;

  WHILE ZEILE1 > 0 AND X_R/=3 REPEAT
    CALL D_CLR;
    PUT '***  Bedienung Unterstationen        ***' TO LCD BY A,SKIP;
    PUT '     UST1 Behindertenhilfe              ' TO LCD BY A,SKIP;
    PUT '     UST2 Haus G                        ' TO LCD BY A,SKIP;
    PUT '     UST3 Haus C                        ' TO LCD BY A,SKIP;
    PUT '     UST4 Haus A                        ' TO LCD BY A,SKIP;
    PUT '     UST5 Haus K                        ' TO LCD BY A,SKIP;
    CALL D_CS(1,ZEILE1);
    CALL D_RON;
    PUT '>>>>' TO LCD BY A;
    CALL D_ROFF;
    CALL STICK;
    CASE X_R
      ALT /* oben   */
        IF ZEILE1>2 THEN ZEILE1=ZEILE1-1; FIN;
      ALT /* unten  */
        IF ZEILE1<6  THEN ZEILE1=ZEILE1+1; FIN;
      ALT /* links  */
        ZEILE1=0;
        X_R=0;
      ALT /* rechts */
        COUNT=0;
     !  CALL CANINIT;
        B_CANREADAKT='1'B;
        IF (B_FERN OR B_PANEL) THEN
            Z_FERN=(ZEILE1)*2; /* 4,6,8,10 */
        ELSE
            Z_FERN=(ZEILE1)*2-1; /* 3,5,7,9 */
        FIN;
        WHILE Z_FERN > 0 AND COUNT<20 REPEAT
          CALL STICK;
      /*  CALL D_CS(33,15);                     /* <<< */
      /*  PUT 'T: ',X_R TO LCD BY A,F(3);       /* Testausgabe */
      /*  CALL D_CS(33,16);                     /*             */
      /*  PUT 'Z: ',COUNT TO LCD BY A,F(3);     /* <<< */
          IF X_R==3 THEN
            COUNT=COUNT+1;
          ELSE
            COUNT=0;
          FIN;
        END;
        Z_FERN=0;
      OUT /* rot    */

    FIN;
  END;
END;



/*********************************************************************/
/* Basis-Eingaberoutinen fuer BIT, FLOAT, FIXED, CLOCK, DUR, CHAR:   */
/*********************************************************************/
LEER: TASK PRIO 20;

END;

ONLINE: PROC (TNAME CHAR(12)) GLOBAL;
  DCL B_TESTB BIT(1);

  IF (B_FERN OR B_PANEL) THEN
    KOMMANDO='AFTER 1.0 SEC ACTIVATE ' CAT TNAME;
  ELSE
    KOMMANDO='AFTER 0.1 SEC ACTIVATE ' CAT TNAME;
  FIN;
  B_TESTB=CMD_EXW(KOMMANDO);
  CALL STICK;
  KOMMANDO='PREVENT ' CAT TNAME;
  B_TESTB=CMD_EXW(KOMMANDO);
  KOMMANDO='TERMINATE ' CAT TNAME;
  B_TESTB=CMD_EXW(KOMMANDO);
END;  

INP_CHAR: PROC ((X,Y)FIXED, WERT CHAR(1) IDENT, TNAME CHAR(12), ETAST FIXED IDENT) GLOBAL;
  DCL DUMMY CHAR(1);
  DCL CHMERK CHAR(1);

  B_WEITER='1'B; 
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;
  CHIN30='                              ';
  Z_CIN30=0;
  B_TASTATUR='0'B;
  B_RAMSPERR='1'B;
  CHMERK=WERT;
  DUMMY=WERT; /* Originalwert übernehmen                             */
  CALL D_CS(X,Y);
  CALL D_RON;
  PUT DUMMY TO LCD BY A;
  CALL D_ROFF;
  CALL D_CS(X,Y);
  X_R=0;
  WHILE X_R<3 REPEAT /* solange Hebel hoch oder runter:              */
    IF X_R==K_O OR X_R==K_U OR X_R==K_E THEN   /* STST */
      IF B_ROTSP AND X_ZUGANG < 1 THEN
        CALL INP_ROTSP;
      FIN;
    FIN;
    IF Z_CIN30 < 1 THEN
      IF X_R==K_O THEN 
        DUMMY=TOCHAR(TOFIXED(DUMMY)+1); 
        ETAST=0;
      FIN;
      IF X_R==K_U THEN 
        DUMMY=TOCHAR(TOFIXED(DUMMY)-1); 
        ETAST=0;
      FIN;
  
      IF TOFIXED(DUMMY) > 122 THEN DUMMY=TOCHAR(122); FIN;
      IF TOFIXED(DUMMY) <  32 THEN DUMMY=TOCHAR( 32); FIN;

      CALL D_CS(X,Y);
      CALL D_RON;
      IF TOFIXED(DUMMY) == 32 THEN
        PUT '_' TO LCD BY A;
      ELSE
        PUT DUMMY TO LCD BY A;
      FIN;
      CALL D_ROFF;

      CALL D_CS(X,Y);
    FIN;
    CALL ONLINE(TNAME);
    IF X_R < 3 OR Z_CIN30 > 0 THEN  
      IF B_ROTSP AND X_ZUGANG < 1 THEN
        CALL INP_ROTSP;
      FIN;
      B_WEITER='0'B; 
    FIN;
    IF X_R==144 THEN    /* Ausstieg Tastatureingabe */
      IF Z_CIN30 > 0 THEN
        ETAST=1;
        DUMMY=CHIN30.CHAR(1);
        X_R=K_E;
      FIN;
    FIN;
  END;
  IF X_R==K_E THEN
    WERT=DUMMY;  /* Wenn ROT -> Wert }bernehmen   */
    AFTER 5.5 SEC ACTIVATE RAMSCHREIB;
    B_WEITER='1'B;
    IF Z_CIN30 < 1 THEN  /* letztes Zeichen war keine Tastatureingabe */
      IF ETAST > 0 THEN  /* aber davor gab es schon Tastatureingabe */
        X_R=10;          /* Mitteielung an Aufrufer ENTER nach Tstatureingabe */
      FIN;
    FIN; 
  ELSE
    WERT=CHMERK;
  FIN;
  B_RAMSPERR='0'B;
  CALL D_ROFF;
  /* den jetzt gueltigen Wert nochmal ausgeben:                       */
  CALL D_CS(X,Y); PUT WERT TO LCD BY A;
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;

END;

/*********************************************************************/
INP_BIT: PROC ((X,Y)FIXED, (C1,C0)CHAR(6), WERT BIT(1) IDENT, 
               TNAME CHAR(12)) GLOBAL;
  /* Hilfsvariable um Originalwert vor Ver{nderung zu sch}tzen:      */
  DCL DUMMY     BIT(1);
  DCL LOOP      BIT(1);
  DCL ZBUTTALT  FIXED;

  B_WEITER='1'B;
  ZBUTTALT=Z_BUTTON;
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;
  DUMMY=WERT; /* Originalwert }bernehmen                             */
  LOOP='1'B;
  X_R=0;
  WHILE LOOP REPEAT /* solange Hebel hoch oder runter:              */
    IF X_R > 1000 THEN   /* BUTTON  */
      IF B_ROTSP AND X_ZUGANG < 1 AND X_R-1000 > ZBUTTALT THEN
        CALL INP_ROTSP;
      ELSE
        IF X_R-1000 == ZBUTTALT+1 THEN
          DUMMY='1'B;
          X_R=K_E;
          LOOP='0'B;
        ELSE
          IF X_R-1000 == ZBUTTALT+2 THEN
            DUMMY='0'B;
            X_R=K_E;
            LOOP='0'B;
          FIN;
        FIN;
      FIN;
    ELSE
      IF X_R==K_O OR X_R==K_U THEN   /* STST */
        IF B_ROTSP AND X_ZUGANG < 1 THEN
          CALL INP_ROTSP;
        ELSE
          DUMMY=NOT DUMMY; /* Bit invertieren                              */
          B_WEITER='0'B;
        FIN;
      FIN;
    FIN;
    CALL D_CS(X,Y);  /* zugeh|rigen Text darstellen:                 */
    PUT '>' TO LCD;
    CALL D_RON; 
    IF DUMMY THEN PUT C1 TO LCD;
    ELSE          PUT C0 TO LCD;  FIN;
    CALL D_ROFF;
    Z_BUTTON=ZBUTTALT;
    CALL D_CS(1,17);
    PUT 'AUSWAHL: ',BUTT,' ',C1 TO LCD BY A,A,A,A,SKIP;
    PUT '         ',BUTT,' ',C0 TO LCD BY A,A,A,A,SKIP;
    IF X_R == 5 THEN
    ELSE
      CALL ONLINE(TNAME);
    FIN;
    IF X_R > 2 THEN
      IF X_R-1000 < ZBUTTALT+1 THEN
        LOOP='0'B;
      FIN;
    FIN;
  END;
  Z_BUTTON=ZBUTTALT;
  CALL D_CS(1,17);
  PUT '                      ' TO LCD BY A;
  CALL D_CS(1,18);
  PUT '                      ' TO LCD BY A;
  IF X_R==K_E THEN /* Wenn ROT, dann Originalwert }bernehmen:        */
    WERT=DUMMY;
    B_WEITER='1'B;
  FIN;
  CALL D_CS(X,Y);
  IF WERT THEN PUT ' ',C1 TO LCD;
  ELSE         PUT ' ',C0 TO LCD; FIN;
END;

/*********************************************************************/
INP_FLO: PROC ((X,Y,ST,NK)FIXED, (MIN,MAX,STEP)FLOAT,
               WERT FLOAT IDENT, TNAME CHAR(12)) GLOBAL;

  DCL FL_MERK   FLOAT;
  DCL FL1       FLOAT;
  DCL WERT2     FLOAT;
  DCL F15  FIXED;

  B_WEITER='1'B;
  DISPSTATUS.BIT(31)='1'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;
  CHIN30='                              ';
  Z_CIN30=0;
  B_TASTATUR='0'B;
  B_RAMSPERR='1'B;
  FL_MERK=WERT;
  WERT2= -99999.9;
  IF WERT>MAX THEN WERT=MAX; FIN; /* Wert im zul{ssigen Intervall ?  */
  IF WERT<MIN THEN WERT=MIN; FIN;

  CALL D_CS(X,Y);
  CALL D_RON;
  PUT '>',WERT TO LCD BY A,F(ST,NK);
  CALL D_ROFF;
  X_R=0;
  WHILE X_R<3 REPEAT /* solange Hebel hoch oder runter:              */
    IF X_R==K_O OR X_R==K_U OR X_R==K_E OR Z_CIN30 > 0 THEN   /* STST */
      IF B_ROTSP AND X_ZUGANG < 1 THEN
        CALL INP_ROTSP;
      FIN;
    FIN;
  ! IF WERT2 < -99999.0 THEN
    IF Z_CIN30 < 1 THEN
      IF X_R==K_O THEN WERT=WERT+STEP*X_F; FIN;
      IF X_R==K_U THEN WERT=WERT-STEP*X_F; FIN;
      IF WERT>MAX THEN WERT=MAX; FIN;
      IF WERT<MIN THEN WERT=MIN; FIN;
      CALL D_CS(X+1,Y);
      CALL D_RON;
      PUT WERT TO LCD BY F(ST,NK);
      CALL D_ROFF;
    ELSE
      CALL D_CS(X+1,Y);
      PUT '               ' TO LCD BY A(ST);
      CALL D_CS(X+1,Y);
      CALL D_RON;
 !    PUT WERT2 TO LCD BY F(ST,NK);
      F15=Z_CIN30;
      IF F15 > ST THEN  F15=ST;  FIN;
      PUT CHIN30 TO LCD BY A(F15);
      CALL D_ROFF;
    FIN;
    CALL ONLINE(TNAME);
    IF X_R < 3 OR Z_CIN30 > 0 THEN  B_WEITER='0'B;  FIN;
    IF X_R==144 THEN    /* Ausstieg Tastatureingabe */
      F15=INSTR(CHIN30,1,30,'-',1,1);
      IF F15 > 0 AND Z_CIN30 < 2 THEN
        WERT2= -0.00001;
      ELSE
        F15=INSTR(CHIN30,1,30,',',1,1);
        IF F15 > 0 THEN                        /* , durch . ersetzen */
          CHIN30.CHAR(F15)='.';
        FIN;
        F15=INSTR(CHIN30,1,30,'.',1,1);
        IF F15 > 0 THEN                        /* . enthalten */
          CONVERT FL1 FROM CHIN30 BY RST(F15), F(15,4);  
          IF F15==0 THEN
            WERT2=FL1;
          ELSE
            WERT2= -99999.9;
            CHIN30='                              ';
            Z_CIN30=0;
          FIN;
        ELSE
          CONVERT FL1 FROM CHIN30 BY RST(F15), F(15);  
          IF F15==0 THEN
            WERT2=FL1;
          ELSE
            WERT2= -99999.9;
            CHIN30='                              ';
            Z_CIN30=0;
          FIN;
        FIN;
      FIN;
      X_R=0;
    FIN;

  END;
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;

  IF WERT2 > -99999.0 THEN
    WERT=WERT2;
    IF WERT>MAX THEN WERT=MAX; FIN;
    IF WERT<MIN THEN WERT=MIN; FIN;
  FIN;

  IF X_R==K_E THEN
    AFTER 5.5 SEC ACTIVATE RAMSCHREIB;
    B_WEITER='1'B;
  ELSE
    WERT=FL_MERK;
  FIN;
  B_RAMSPERR='0'B;

  CALL D_ROFF;
  /* den jetzt gueltigen Wert nochmal ausgeben:                       */
  CALL D_CS(X,Y); PUT ' ',WERT TO LCD BY A,F(ST,NK);

END;

/*********************************************************************/
INP_FIX: PROC ((X,Y,ST,MIN,MAX,STEP) FIXED,
                WERT FIXED IDENT, TNAME CHAR(12)) GLOBAL;  

  DCL FX_MERK FIXED;
  DCL FIX1    FIXED;
  DCL WERT2   FIXED;
  DCL F15  FIXED;
  DCL FL1 FLOAT;

  B_WEITER='1'B; 
  DISPSTATUS.BIT(31)='1'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;
  CHIN30='                              ';
  Z_CIN30=0;
  B_TASTATUR='0'B;
  B_RAMSPERR='1'B;
  FX_MERK=WERT;
  WERT2= -19999;

  IF WERT>MAX THEN WERT=MAX; FIN; /* Wert im zul{ssigen Intervall ?  */
  IF WERT<MIN THEN WERT=MIN; FIN;

  CALL D_CS(X,Y);
  CALL D_RON;
  PUT '>',WERT TO LCD BY A,F(ST);
  CALL D_ROFF;
  X_R=0;
  WHILE X_R<3 REPEAT /* solange Hebel hoch oder runter:              */
    IF X_R==K_O OR X_R==K_U OR X_R==K_E THEN   /* STST */
      IF B_ROTSP AND X_ZUGANG < 1 THEN
        CALL INP_ROTSP;
      FIN;
    FIN;
  ! IF WERT2 < -19998 THEN
    IF Z_CIN30 < 1 THEN
      IF X_R==K_O THEN WERT=WERT+STEP*X_F; FIN;
      IF X_R==K_U THEN WERT=WERT-STEP*X_F; FIN;
      IF WERT>MAX THEN WERT=MAX; FIN;
      IF WERT<MIN THEN WERT=MIN; FIN;
      CALL D_CS(X+1,Y);
      CALL D_RON;
      PUT WERT TO LCD BY F(ST);
      CALL D_ROFF;
    ELSE
      CALL D_CS(X+1,Y);
      PUT '               ' TO LCD BY A(ST);
      CALL D_CS(X+1,Y);
      CALL D_RON;
 !    PUT WERT2 TO LCD BY F(ST,NK);
      F15=Z_CIN30;
      IF F15 > ST THEN  F15=ST;  FIN;
      PUT CHIN30 TO LCD BY A(F15);
      CALL D_ROFF;
    FIN;
    CALL ONLINE(TNAME);
    IF X_R < 3 OR Z_CIN30 > 0 THEN  B_WEITER='0'B;  FIN;
    IF X_R==144 THEN    /* Ausstieg Tastatureingabe */
      F15=INSTR(CHIN30,1,30,'-',1,1);
      IF F15 > 0 AND Z_CIN30 < 2 THEN
        WERT2= -0;
      ELSE
        F15=INSTR(CHIN30,1,30,'.',1,1);
        IF F15 > 0 THEN                        /* . enthalten */
          WERT2= -19999;
          CHIN30='                              ';
          Z_CIN30=0;
        ELSE
          CONVERT FIX1 FROM CHIN30 BY RST(F15), F(15);  
          IF F15==0 THEN
            WERT2=FIX1;
          ELSE
            WERT2= -19999;
            CHIN30='                              ';
            Z_CIN30=0;
          FIN;
        FIN;
      FIN;
      X_R=0;
    FIN;

  END;
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;

  IF WERT2 > -19999 THEN
    WERT=WERT2;
    IF WERT>MAX THEN WERT=MAX; FIN;
    IF WERT<MIN THEN WERT=MIN; FIN;
  FIN;

  IF X_R==K_E THEN
    AFTER 5.5 SEC ACTIVATE RAMSCHREIB;
    B_WEITER='1'B;
  ELSE
    WERT=FX_MERK;
  FIN;
  B_RAMSPERR='0'B;

  CALL D_ROFF;
  /* den jetzt gueltigen Wert nochmal ausgeben:                       */
  CALL D_CS(X,Y); PUT ' ',WERT TO LCD BY A,F(ST);

END;

/*********************************************************************/
INP_F55: PROC ((X,Y,ST,NK)FIXED, (MIN,MAX,STEP)FLOAT(55),
               WERT FLOAT(55) IDENT, TNAME CHAR(12))  GLOBAL;

  DCL FL_MERK   FLOAT(55);
  DCL FL1       FLOAT(55);
  DCL WERT2     FLOAT(55);
  DCL F15  FIXED;


  B_WEITER='1'B; 
  DISPSTATUS.BIT(31)='1'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;
  CHIN30='                              ';
  Z_CIN30=0;
  B_TASTATUR='0'B;
  B_RAMSPERR='1'B;
  FL_MERK=WERT;
  WERT2= -99999.9;
  IF WERT>MAX THEN WERT=MAX; FIN; /* Wert im zul{ssigen Intervall ?  */
  IF WERT<MIN THEN WERT=MIN; FIN;

  CALL D_CS(X,Y);
  CALL D_RON;
  PUT '>',WERT TO LCD BY A,F(ST,NK);
  CALL D_ROFF;
  X_R=0;
  WHILE X_R<3 REPEAT /* solange Hebel hoch oder runter:              */
    IF X_R==K_O OR X_R==K_U OR X_R==K_E THEN   /* STST */
      IF B_ROTSP AND X_ZUGANG < 1 THEN
        CALL INP_ROTSP;
      FIN;
    FIN;
  ! IF WERT2 < -99999.0 THEN
    IF Z_CIN30 < 1 THEN
      IF X_R==K_O THEN WERT=WERT+STEP*X_F; FIN;
      IF X_R==K_U THEN WERT=WERT-STEP*X_F; FIN;
      IF WERT>MAX THEN WERT=MAX; FIN;
      IF WERT<MIN THEN WERT=MIN; FIN;
      CALL D_CS(X+1,Y);
      CALL D_RON;
      PUT WERT TO LCD BY F(ST,NK);
      CALL D_ROFF;
    ELSE
      CALL D_CS(X+1,Y);
      PUT '               ' TO LCD BY A(ST);
      CALL D_CS(X+1,Y);
      CALL D_RON;
 !    PUT WERT2 TO LCD BY F(ST,NK);
      F15=Z_CIN30;
      IF F15 > ST THEN  F15=ST;  FIN;
      PUT CHIN30 TO LCD BY A(F15);
      CALL D_ROFF;
    FIN;
    CALL ONLINE(TNAME);
    IF X_R < 3 OR Z_CIN30 > 0 THEN  B_WEITER='0'B;  FIN;
    IF X_R==144 THEN    /* Ausstieg Tastatureingabe */
      F15=INSTR(CHIN30,1,30,'-',1,1);
      IF F15 > 0 AND Z_CIN30 < 2 THEN
        WERT2= -0.00001;
      ELSE
        F15=INSTR(CHIN30,1,30,',',1,1);
        IF F15 > 0 THEN                        /* , durch . ersetzen */
          CHIN30.CHAR(F15)='.';
        FIN;
        F15=INSTR(CHIN30,1,30,'.',1,1);
        IF F15 > 0 THEN                        /* . enthalten */
          CONVERT FL1 FROM CHIN30 BY RST(F15), F(15,4);  
          IF F15==0 THEN
            WERT2=FL1;
          ELSE
            WERT2= -99999.9;
            CHIN30='                              ';
            Z_CIN30=0;
          FIN;
        ELSE
          CONVERT FL1 FROM CHIN30 BY RST(F15), F(15);  
          IF F15==0 THEN
            WERT2=FL1;
          ELSE
            WERT2= -99999.9;
            CHIN30='                              ';
            Z_CIN30=0;
          FIN;
        FIN;
      FIN;
      X_R=0;
    FIN;

  END;
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;

  IF WERT2 > -99999.0 THEN
    WERT=WERT2;
    IF WERT>MAX THEN WERT=MAX; FIN;
    IF WERT<MIN THEN WERT=MIN; FIN;
  FIN;

  IF X_R==K_E THEN
    AFTER 5.5 SEC ACTIVATE RAMSCHREIB;
    B_WEITER='1'B; 
  ELSE
    WERT=FL_MERK;
  FIN;
  B_RAMSPERR='0'B;

  CALL D_ROFF;
  /* den jetzt gueltigen Wert nochmal ausgeben:                       */
  CALL D_CS(X,Y); PUT ' ',WERT TO LCD BY A,F(ST,NK);

END;

/*********************************************************************/
INP_CLO: PROC ((X,Y,STDMIN) FIXED, WERT CLOCK IDENT, TNAME CHAR(12));
  /* Hilfsvariable um Originalwert vor Ver{nderung zu sch}tzen:      */
  /* STDMIN bestimmt wie genau sich der Wert einst. l{~t             */
  /* 1: nur Stunden 2:Stunden und Minuten 3:Stunden Min und Sec      */
  DCL DUMMY CLOCK;
  DCL HILF FIXED;

  B_WEITER='1'B;  
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;

  /* Test auf Grenz}berschreitung:                                   */
  IF WERT <= 00:00:00 THEN WERT=00:00:00.001; FIN;
  IF WERT >  24:00:00 THEN WERT=24:00:00;     FIN;

  DUMMY=WERT; /* Originalwert }bernehmen                             */
  CALL D_CS(X,Y);
  PUT '>',DUMMY TO LCD BY A,T(8);

  HILF=1;
  X_R=0;
  WHILE HILF>0 AND HILF<=STDMIN REPEAT;
    IF X_R==K_O OR X_R==K_U OR X_R==K_E THEN   /* STST */
      IF B_ROTSP AND X_ZUGANG <1 THEN
        CALL INP_ROTSP;
      FIN;
    FIN;
    CASE X_R
      ALT /* oben   */
        CASE HILF
          ALT /* Stunden  */ DUMMY=DUMMY+1 HRS*X_F;
          ALT /* Minuten  */ DUMMY=DUMMY+1 MIN*X_F;
          OUT /* Sekunden */ DUMMY=DUMMY+1 SEC*X_F;
        FIN;
        IF DUMMY> 24:00:00 THEN DUMMY=24:00:00;     FIN;
        B_WEITER='0'B;  
      ALT /* unten  */
        CASE HILF
          ALT /* Stunden  */ DUMMY=DUMMY-1 HRS*X_F;
          ALT /* Minuten  */ DUMMY=DUMMY-1 MIN*X_F;
          OUT /* Sekunden */ DUMMY=DUMMY-1 SEC*X_F;
        FIN;
        IF DUMMY<=00:00:00 THEN DUMMY=00:00:00.001; FIN;
        B_WEITER='0'B;  
      OUT /* links, rechts, rot                                      */
    FIN;
    CALL D_CS(X+1,Y);
    CALL D_RON;
    PUT DUMMY TO LCD BY T(8);
    CALL D_ROFF;
    CALL ONLINE(TNAME);
    CALL LRROT(HILF);   /* LINKS, RECHTS oder ROT bet{tigt ?         */
    IF X_R > 1000 THEN  /* BUTTON geklickt */
      HILF=0;
    FIN;
  END;
  IF X_R==K_E THEN  WERT=DUMMY;  FIN; /* Wenn ROT -> Wert }bernehmen   */
  /* den jetzt g}ltigen Wert nochmal ausgeben:                       */
  CALL D_ROFF; CALL D_CS(X,Y); PUT ' ',WERT TO LCD BY A,T(8);
END;

/*********************************************************************/
INP_BETRIEB: PROC((X,Y)FIXED, NAME1() CHAR(30) IDENT ,ANZ FIXED, 
                  Z_ZUST FIXED IDENT, TNAME CHAR(12));

  DCL Z FIXED;
  DCL LOOP      BIT(1);
  DCL ZBUTTALT  FIXED;

  B_WEITER='1'B;  
  ZBUTTALT=Z_BUTTON;
  DISPSTATUS.BIT(31)='0'B; /* Zahleneingabe */
  DISPSTATUS.BIT(32)='0'B; /* Texteingabe   */
  CALL DISPSTAT;
  CALL FIXGRENZ(ANZ,1,Z_ZUST);
  Z=Z_ZUST;
  LOOP='1'B;
  X_R=0;
  WHILE LOOP REPEAT /* solange Hebel hoch oder runter:              */
    IF X_R > 1000 THEN   /* BUTTON  */
      IF B_ROTSP AND X_ZUGANG < 1 AND X_R-1000 > ZBUTTALT THEN
        CALL INP_ROTSP;
        X_R=0;
      ELSE
        IF X_R-1000 > ZBUTTALT THEN
          Z=X_R-1000-ZBUTTALT;
          X_R=5;
          LOOP='0'B;
        FIN;
      FIN;
    ELSE
      IF X_R==1 OR X_R==2 OR X_R==5 THEN   /* STST */
        IF B_ROTSP AND X_ZUGANG < 1 THEN
          CALL INP_ROTSP;
        FIN;
      FIN;
   !  PUT X_R TO A1 BY F(8),SKIP;
      CASE X_R /* wohin wurde der Hebel bewegt ?                       */
        ALT /* Hebel nach oben bewegt                                  */
          Z=Z+1; /* Eine Auswahl zurück                                */
          CALL FIXGRENZ(ANZ,1,Z);
        ALT /* Hebel nach unten bewegt                                 */
          Z=Z-1; /* Eine Auswahl vor                                   */
          CALL FIXGRENZ(ANZ,1,Z);
        OUT
      FIN;                                                               
    FIN;
    CALL D_CS(X,Y);  /* zugeh|rigen Text darstellen:                 */
    PUT '>' TO LCD;
    CALL D_RON; 
    PUT NAME1(Z) TO LCD BY A;
    CALL D_ROFF;
    Z_BUTTON=ZBUTTALT;
    CALL D_CS(1,19-ANZ);
    PUT 'AUSWAHL: ',BUTT,' ',NAME1(1) TO LCD BY A,A,A,A,SKIP;
    FOR I TO ANZ-1 REPEAT  
      PUT '         ',BUTT,' ',NAME1(I+1) TO LCD BY A,A,A,A,SKIP;
    END;
    IF X_R == 5 THEN
    ELSE
      CALL ONLINE(TNAME);
      IF X_R < 3 THEN  B_WEITER='0'B;  FIN;
    FIN;
    IF X_R > 2 THEN
      IF X_R-1000 < ZBUTTALT+1 THEN
        LOOP='0'B;
      FIN;
    FIN;
  END;
  Z_BUTTON=ZBUTTALT;
  CALL D_CS(1,19-ANZ);
  FOR I TO ANZ REPEAT  
    PUT '                                           ' TO LCD BY A,SKIP;
  END;
  IF X_R==5 THEN /* Wenn ROT, dann Originalwert }bernehmen:        */
    Z_ZUST=Z;
    B_WEITER='1'B;  
  FIN;
  CALL D_CS(X,Y);  
  PUT ' ',NAME1(Z_ZUST) TO LCD BY A,A;

END; /* of PROC INP_BETRIEB                                          */


/*********************************************************************/
/* Links Rechts Eingabe                                              */
/*********************************************************************/
LRROT: PROC (ZEIGER FIXED IDENT) GLOBAL;
  IF X_R==K_L THEN /* links  */
    ZEIGER=ZEIGER-1; 
  ELSE
    IF X_R==K_R OR X_R==K_E THEN /* rechts oder Eingabe  */
      ZEIGER=ZEIGER+1; 
    FIN;
  FIN;
END; /* of PROC LRROT */

/*********************************************************************/
/* Auswahl verschiedener Objekte mit Tasten oder Button              */
/*********************************************************************/
OBJAUSWAHL: PROC(TEXT CHAR(40), ANZ FIXED, NAME() CHAR(30) IDENT, TNAME CHAR(12) ) GLOBAL;

  DCL FIX1   FIXED;
  DCL FIX2   FIXED;
  DCL YPFEIL FIXED;

  B_LOOPB='1'B;                             
  YPFEIL=3;
  IF INDMERK > 0 THEN
!   IF INDMERK == ANZ THEN
!     INDMERK=INDMERK-1;
!   FIN;
    FIX1=INDMERK//8;
    FIX2=INDMERK REM 8;
    IF FIX1 > 0 AND FIX2 == 0 THEN  /* letztes Element der Auswahl */
      FIX1=FIX1-1;
      FIX2=8;
    FIN;
    IND=1+FIX1*8;
    YPFEIL=FIX2+2;
  FIN;
  IF ANZ < 2 THEN
    IND=1;
    B_LOOPB='0'B;                             
    B_EINOBJ='1'B;                             
  ELSE
    B_EINOBJ='0'B;                             
  FIN;
  WHILE B_LOOPB REPEAT
    CALL D_CLR;
    CALL D_CS(1,1);
    PUT '<',BUTT,TEXT TO LCD BY A,A,A,SKIP;
    CALL D_CS(1,2);
    IF ANZ > 8 THEN
      FIX1=IND;
    ELSE
      FIX1=1;
      INDMERK=1;
    FIN;
    IF FIX1 > 1 THEN
      IF B_NOTAUSWAHL THEN
        PUT '  ',BUTT,'  zurueck' TO LCD BY A,A,A,SKIP;
      ELSE
        PUT '   ',BUTT,'  zurueck' TO LCD BY A,A,A,SKIP;
      FIN;
    ELSE
      PUT '                                         ' TO LCD BY A,SKIP;
    FIN;
    FIX2=0;
    FOR I FROM FIX1 TO FIX1+7 REPEAT
      IF I <= ANZ THEN
        IF B_NOTAUSWAHL THEN
          PUT I,' ',NAME(I) TO LCD BY F(3),A,A,SKIP;
        ELSE
          PUT '   ',BUTT,' ',I,' ',NAME(I) TO LCD BY A,A,A,F(3),A,A,SKIP;
          FIX2=FIX2+1;
        FIN;
      ELSE
        PUT '                                         ' TO LCD BY A,SKIP;
      FIN;
    END;
    IF FIX1+7 < ANZ THEN
      IF B_NOTAUSWAHL THEN
        PUT '  ',BUTT,'  weiter' TO LCD BY A,A,A,SKIP;
      ELSE
        PUT '   ',BUTT,'  weiter' TO LCD BY A,A,A,SKIP;
      FIN;
    ELSE
      PUT '                                         ' TO LCD BY A,SKIP;
    FIN;
    IF B_NOTAUSWAHL THEN
    ELSE
      CALL D_CS(1,YPFEIL);
      CALL D_RON;
      PUT '>>' TO LCD BY A;
      CALL D_ROFF;
    FIN;
  ! CALL STICK;
    CALL ONLINE(TNAME);
    IF X_R > 1000 THEN                   /* BUTTON geklickt */
      IF X_R == 1001 THEN                /* < BUTTON1 EXIT  */
        IND=0; 
        B_LOOPB='0'B;                             
      ELSE
        IF Z_BUTTON > FIX2+2 THEN        /* EXIT + ZURUECK + WEITER */
          IF X_R == 1002 THEN            /* BUTTON2 ZURUECK  */
            IND=IND-8;
            IF IND < 1 THEN  IND=1;  FIN;
            INDMERK=IND;
          ELSE
            IF X_R == 1000+FIX2+3 THEN     /*  BUTTON WEITER  */
              IND=IND+8;
              IF IND > ANZ THEN  IND=ANZ;  FIN;
              INDMERK=IND;
            ELSE                           /* auf Objektauswahl */
              IND=IND+X_R-1003;
              B_LOOPB='0'B;                             
            FIN;
          FIN;
        ELSE
          IF Z_BUTTON > FIX2+1 THEN        /* EXIT + ZURUECK ODER WEITER */
            IF FIX1 > 1 THEN               /* es gibt den zurueck-Button */
              IF X_R == 1002 THEN            /* BUTTON2 ZURUECK  */
                IND=IND-8;
                IF IND < 1 THEN  IND=1;  FIN;
                INDMERK=IND;
              ELSE                           /* auf Objektauswahl */
                IND=IND+X_R-1003;
                B_LOOPB='0'B;                             
              FIN;
            ELSE                             /* es gibt keinen zurueck-Button */
              IF X_R == 1000+FIX2+2 THEN     /*  BUTTON WEITER  */
                IND=IND+8;
                IF IND > ANZ THEN  IND=ANZ;  FIN;
                INDMERK=IND;
              ELSE
                IND=IND+X_R-1002;
                B_LOOPB='0'B;                             
              FIN;
            FIN;
          ELSE                             /* EXIT + OBJEKTE */
            IND=IND+X_R-1002;
            B_LOOPB='0'B;                             
          FIN;
        FIN;
      FIN;
    ELSE                                   /* Bedienung ueber Tasten */
      IF B_NOTAUSWAHL THEN
        CASE X_R 
          ALT /* oben          */
            IND=IND-8;
            IF IND < 1 THEN  IND=1;  FIN;
          ALT /* unten         */
            IF ANZ > 8 THEN
              IND=IND+8;
              IF IND > ANZ THEN  IND=ANZ;  FIN;
            FIN;
          ALT /* links         */
            IND=0; 
            B_LOOPB='0'B;                             
          OUT /* rechts oder Eingabe       */
        FIN;
      ELSE
        CASE X_R 
          ALT /* oben          */
            YPFEIL=YPFEIL-1; 
            IF YPFEIL < 3 THEN
              YPFEIL=3;
              IND=IND-8;
              IF IND < 1 THEN  IND=1;  FIN;
            FIN;
          ALT /* unten         */
            IF IND+YPFEIL-3 < ANZ THEN
              YPFEIL=YPFEIL+1; 
            FIN;
            IF YPFEIL > 10 THEN
              YPFEIL=10;
              IND=IND+8;
              IF IND > ANZ THEN  IND=ANZ;  FIN;
              IF IND+YPFEIL-3 > ANZ THEN  YPFEIL=3;  FIN;
            FIN;
          ALT /* links         */
            IND=0; 
            B_LOOPB='0'B;                             
          OUT /* rechts oder Eingabe       */
            IND=IND+YPFEIL-3;
            INDMERK=IND;
            B_LOOPB='0'B;                             
        FIN;
      FIN;
    FIN;
  END;  /* B_LOOPB  */
  INDMERK=IND;
  B_NOTAUSWAHL='0'B;

END; /* of OBJAUSWAHL                                         */

/*********************************************************************/
/* runden von Gleitkommazahlen auch groesser 32768                   */
/*********************************************************************/
ROUNDLG: PROC ((FL1) FLOAT(55)) RETURNS (FIXED(31)) GLOBAL;
  DCL XH(10) FIXED;
  DCL FL2    FLOAT(55);
  DCL FL3    FLOAT(55);
  DCL Z1     FIXED;
  DCL Z31    FIXED(31);
  DCL Z312   FIXED(31);
  DCL BNEG   BIT(1);

  FOR I TO 10 REPEAT
    XH(I)=0;
  END;

  IF FL1 < 0.0(55) THEN
    BNEG='1'B;
    FL3= -FL1;
  ELSE
    BNEG='0'B;
    FL3=FL1;
  FIN;

  IF FL3 > 2140000000.0(55) THEN   /* 2,14 MILLIARDEN (fast 2^31) */
    FL3=2140000000.0(55);
  FIN;

  WHILE FL3 > 9.9999999(55) REPEAT 
    FL2=FL3;
    Z1=1;
    WHILE FL2 > 9.9999999(55) AND Z1 < 10 REPEAT
      FL2=FL2/10.0(55);
      Z1=Z1+1;
    END;
    XH(Z1)=ENTIER(FL2);
    IF XH(Z1) < 1 THEN  XH(Z1)=1;  FIN;
    FL3=FL3-((XH(Z1)*1.0(55))*(EXP((Z1-1)*LN(10.0(55)))));  /* - XH*10^(Z1-1) */
  END;

  XH(1)=ROUND(FL3);
  Z31=0(31);
  Z312=1(31);
  FOR I TO 10 REPEAT
    Z31=Z31+(XH(I)*1(31))*Z312;
    Z312=Z312*10(31);  /* 1, 10, 100, 1000, ... */
  END;

  IF BNEG THEN
    Z31= -Z31;
  FIN;
  
  RETURN(Z31); /*  */
END;  


/*********************************************************************/
/* Initialisierung des Menuebaums:                                    */
/*********************************************************************/
SET_MENU: PROC ( (EBENE_AKT , POST1) FIXED, TEXT CHAR(30) );

 ME_INDEX           =ME_INDEX+1;/* Anzahl der Menuepunkte erhoehen     */
 ME_EBENE(ME_INDEX) =EBENE_AKT; /* Aktuelle Menueebene zuordnen       */
 ME_TEX(ME_INDEX)   =TEXT;      /* Menuetext dem Element zuweisen     */

 IF POST1 == 1 THEN /* Ausstieg aus Menue gew}nscht:                  */
   ME_ZWAHL=ME_ZWAHL-1;
   ME_POST(ME_INDEX,1)=ME_ZWAHL;  /* Nachfolgeelement zuweisen       */
 FIN;

 ME_EXIT = '0'B;

 IF ME_INDEX /= 1 THEN /* Ausser beim Wurzelelement:                  */
   /* Nach dem Vorgaengerelement suchen:                              */
   FOR I FROM ME_INDEX-1 BY -1 TO 1 WHILE NOT ME_EXIT REPEAT;
     /* Nach der naechst hoeheren Menueebene suchen:                    */
     IF ME_EBENE(I)+1 == EBENE_AKT THEN
       ME_PRAE(ME_INDEX) = I; /* Vorgaengerelement gefunden           */
       ME_EXIT='1'B;          /* und Suche abbrechen                 */
     FIN;
   END;
   IF ME_PUHILF == ME_PRAE(ME_INDEX) THEN
     ME_ZEIGHILF=ME_ZEIGHILF+1;
     ME_ZHILF2(ME_PRAE(ME_INDEX))=ME_ZEIGHILF;
   ELSE
     IF ME_PUHILF < ME_PRAE(ME_INDEX) THEN
       ME_ZEIGHILF=1;
       ME_ZHILF2(ME_PRAE(ME_INDEX))=ME_ZEIGHILF;
     ELSE
       ME_ZEIGHILF=ME_ZHILF2(ME_PRAE(ME_INDEX))+1;
       ME_ZHILF2(ME_PRAE(ME_INDEX))=ME_ZEIGHILF;
     FIN;
   FIN;
   ME_PUNKT(ME_INDEX)=ME_PRAE(ME_INDEX);
   ME_ZEIG(ME_INDEX)=ME_ZEIGHILF;
   IF POST1 == 1 THEN /* Ausstieg aus Menue gew}nscht:                  */
     ME_AKTION(ME_INDEX)=1;
   ELSE
     ME_AKTION(ME_INDEX)=0;
   FIN;
   ME_PUHILF=ME_PUNKT(ME_INDEX);
 ELSE
   ME_PUNKT(ME_INDEX)=1;
   ME_ZEIG(ME_INDEX)=1;
   ME_PUHILF=1;
   ME_ZEIGHILF=0;
 FIN;

 PUT ME_INDEX,': ',EBENE_AKT,',',POST1,',',TEXT TO TEMP BY F(3),A,F(2),A,F(1),A,A(30);
!IF POST1 == 1 THEN
!  PUT ME_PUNKT(ME_INDEX) TO TEMP BY F(5);
!  PUT ME_ZEIG(ME_INDEX) TO TEMP BY F(5);
!FIN;

 PUT TO TEMP BY SKIP;

END; /* of Procedure SET_MENU                                        */


I_MENU: PROC;       /*  <<<<  */

  OPEN TEMP BY IDF('TEMP'),ANY;
  CALL REWIND(TEMP);
  PUT 'P',NR_PRJ TO TEMP BY A,F(4),SKIP;

  ME_INDEX=0;  /* Zaehler fuer Menuepunkte auf Null setzen              */
  ME_PRAE(1)=1;/* Wurzelelement zeigt auf sich selbst                */
  ME_ZWAHL=0;  /*Zeiger des Menueelements auf Auswahlleiste in EINGABE*/

  /* Es folgt der Menuebaum. Aufruf von SET_MENU mit den Parametern:  */
  /* SET_MENU(1-n,   Menueebene (Tiefe des Menues)                     */
  /*         0/1,   0: Knotenpunkt, 1: Endpunkt (Ausstieg in EINGABE)*/
  /*         Text)   0-30 Buchstaben fuer den Menuetext                */

  CALL SET_MENU( 1,0 ,'Hauptmenue, bitte waehlen :');
  CALL SET_MENU( 2, 1,  'Anzeige'                       );
  CALL SET_MENU( 2,0 ,  'Stoerungsverwaltung'             );
  CALL SET_MENU( 3, 1,   'Stoerungsprotokoll '            );
  CALL SET_MENU( 3, 1,   'akt. anstehende Stoerungen'           );
  CALL SET_MENU( 3, 1,   'Stoerungsfreigabe  '            );
  CALL SET_MENU( 3, 1,   'Langzeitmeldeprotokoll'           );
  CALL SET_MENU( 3, 1,   'Wiederkehrende Stoerungen'           );
  CALL SET_MENU( 2,0 ,  'Ein- Ausgaenge'                 );
  CALL SET_MENU( 3, 1,   'Analogeingaenge'                );        
  CALL SET_MENU( 3, 1,   'Analogausgaenge'                );        
  CALL SET_MENU( 3, 1,   'PWM-Ausgaenge'                  );        
  CALL SET_MENU( 3, 1,   'Digitalausgaenge'               );
  CALL SET_MENU( 3, 1,   'Digitaleingaenge'               );
  CALL SET_MENU( 2,0 ,  'Kessel       '                 );
  CALL SET_MENU( 3, 1,   'Kessel Leistungsregelung   ' );      
  CALL SET_MENU( 3, 1,   'Kessel Durchflussregelung  ' );      
! CALL SET_MENU( 3, 1,   'GeniBus Pumpen  ' );      
  CALL SET_MENU( 3, 1,   'Kesselparameter  ' );      
  CALL SET_MENU( 3, 1,   'Kesseltoleranz Hauptkreis ' );      
  CALL SET_MENU( 3, 1,   'Kesselrangfolge  ' );      
  CALL SET_MENU( 3, 1,   'Pumpenvorlauf erlaubt?  ' );      
  CALL SET_MENU( 3, 1,   'Erhaltungsreg. Holzkessel1 ' );      
  CALL SET_MENU( 3, 1,   'Erhaltungsreg. Holzkessel2 ' );      
  CALL SET_MENU( 3, 1,   'Mindestoeffn K-Mi bei Anf (%)  ' );      
  CALL SET_MENU( 3, 1,   'Position HauptkreisISTwert     ' );      
  CALL SET_MENU( 3, 1,   'Betriebsart Biogaskessel       ' );      
  CALL SET_MENU( 2,0 ,  'BHKW         '                 );
! CALL SET_MENU( 3, 1,   'BHKW Bedienung (Kraftwerk)'    );            
  CALL SET_MENU( 3, 1,   'BHKW Betriebsprot. (Merlin)' );          
! CALL SET_MENU( 3, 1,   'Timer BHKW Freigabe  ' );          
  CALL SET_MENU( 3, 1,   'BHKW Parameter  ' );      
  CALL SET_MENU( 3, 1,   'BHKW Betrieb ab VL > ' );          
  CALL SET_MENU( 3, 1,   'Min TCMAX (WW ueberladen,...)'  );
! CALL SET_MENU( 3, 1,   'BHKW Rangfolge  ' );      
! CALL SET_MENU( 3, 1,   'Warn. bei Starts > (in 24h) '        );
! CALL SET_MENU( 3, 1,   'BHKW Betriebsart '        );
! CALL SET_MENU( 3, 1,   'BHKW CAN-Kommunikation        ' );       
! CALL SET_MENU( 3,0 ,   'BHKW Systemeinstellungen   '                 );
! CALL SET_MENU( 4, 1,    'Obere BHKW-Toleranz Hauptkr.'   ); /* nur bei > 1 BHKW <<<< */
! CALL SET_MENU( 4, 1,    'Untere BHKW-Toleranz Hauptkr.'  ); /* nur bei > 1 BHKW <<<< */
! CALL SET_MENU( 4, 1,    'BHKW-Ausschaltverz. in MIN'     ); /* nur bei > 1 BHKW <<<< */
! CALL SET_MENU( 4, 1,    'BHKW1 Einschaltbedingungen '   );
! CALL SET_MENU( 4, 1,    'Min TCMAX (WW ueberladen,...)'  );
! CALL SET_MENU( 4, 1,    'minimal beachteter Strombedarf'  );
  CALL SET_MENU( 2,0 ,  'Biogas       '                 );
  CALL SET_MENU( 3, 1,   'Biogaskessel Ein ab Fuellst >  ' );      
  CALL SET_MENU( 3, 1,   'Biogasfackel Ein ab Fuellst >  ' );      
  CALL SET_MENU( 2,0 ,  'Trocknung    ' );      
  CALL SET_MENU( 3, 1,   'Timer Trocknung Zwangsbetrieb'     );
  CALL SET_MENU( 3, 1,   'Minwert Geblaese -Zwang- (%) '     );
  CALL SET_MENU( 3, 1,   'MindestVL HK2 bei Trockn-Betr'     );
  CALL SET_MENU( 3, 1,   'Trocknung Ein ab Puffer4 >   '     );
  CALL SET_MENU( 3, 1,   'Trocknung Zuluftsollwert     '     );
  CALL SET_MENU( 3, 1,   'Timer Trocknung Leisebetrieb '     );
  CALL SET_MENU( 3, 1,   'Maxwert Geblaese -Leise- (%) '     );
  CALL SET_MENU( 3, 1,   'Maxwert Geblaese -Normal- (%) '     );
  CALL SET_MENU( 2,0 ,  'Heizkreise   '                 );
  CALL SET_MENU( 3, 1,   'Heizkurven   ' );      
  CALL SET_MENU( 3,0 ,   'Absenkung    ' );      
  CALL SET_MENU( 4, 1,    'Heizkreise Wochenkalender'     );
  CALL SET_MENU( 4, 1,    'Heizkreise Jahreskalender'     );
  CALL SET_MENU( 3, 1,   'HK-Pumpenregelung  ' );      
! CALL SET_MENU( 3, 1,   'GeniBus Pumpen  ' );      
  CALL SET_MENU( 3, 1,   'HK-Vorlaufregelung ' );      
  CALL SET_MENU( 3, 1,   'Heizkreisparameter ' );      
  CALL SET_MENU( 3, 1,   'Tau AT-Schnitt (h) ' );      
  CALL SET_MENU( 3, 1,   'AT-Schnitt (aktuell)' );      
  CALL SET_MENU( 3, 1,   'Estrichtrocknung   ' );      
  CALL SET_MENU( 3, 1,   'Jahreskal. HZG-AUS bei AT > 3' );      
! CALL SET_MENU( 3, 1,   'Regelung Prim-PMP HKs        ' );      
! CALL SET_MENU( 3, 1,   'Baedertemperaturen           ' );      
! CALL SET_MENU( 2,0 ,  'Warmwasserbereitung'           );
! CALL SET_MENU( 3, 1,   'Solltemperaturen             ' );      
! CALL SET_MENU( 3, 1,   'Solltemperaturen WW2 Sport   ' );      
! CALL SET_MENU( 3, 1,   'Timer WW Tagbetrieb  ' );          
! CALL SET_MENU( 3, 1,   'Timer WW Desinfektion' );          
! CALL SET_MENU( 3, 1,   'Regelung WW1-Ladung Kueche' );          
! CALL SET_MENU( 3, 1,   'Regelung WW-Zirkulation' );          
! CALL SET_MENU( 3,0 ,   'Sondereinstellungen Lohkamp   ' );  /* <<<< */
! CALL SET_MENU( 4, 1,    'Ladep. AUS ab Austr. > Soll + ');  /* <<<< */
! CALL SET_MENU( 4, 1,    'Ladep. P+ ab Austr. < Soll - ');   /* <<<< */ 
! CALL SET_MENU( 4, 1,    'Grundtakt WW-Ladepumpen (s)   ');  /* <<<< */
! CALL SET_MENU( 3, 1,   'GeniBus Pumpen  ' );      
  CALL SET_MENU( 2,0 ,  'Allgemein          '           );
  CALL SET_MENU( 3,0 ,   'Zaehler                       ' ); 
  CALL SET_MENU( 4, 1,    'Aktuelle Zaehlerstaende       ' ); 
! CALL SET_MENU( 4, 1,    'Impulszaehler                 ' );
! CALL SET_MENU( 4, 1,    'Waermemengenzaehler (Soft)    ' ); 
! CALL SET_MENU( 4, 1,    'Strombilanzen                 ' ); 
! CALL SET_MENU( 4, 1,    'Tarifkalender HT/NT           ' ); 
  CALL SET_MENU( 4, 1,    'Monatszaehler                 ' ); 
  CALL SET_MENU( 4, 1,    'Jahreszaehler                 ' ); 
  CALL SET_MENU( 4, 1,    'Sonstige Zaehler              ' ); 
  CALL SET_MENU( 3,0 ,   'M-Bus                         ' ); 
  CALL SET_MENU( 4, 1,    'M-Bus Werte                   ' );      
  CALL SET_MENU( 4, 1,    'M-Bus Busdaten                ' );      
  CALL SET_MENU( 4, 1,    'M-Bus Lesezyklus (s)          ' );      
! CALL SET_MENU( 4, 1,    'M-Bus manuelle Kommunikation' );  
! CALL SET_MENU( 3,0 ,   'GeniBus Pumpen                ' );  
! CALL SET_MENU( 4, 1,    'GeniBus Pumpenkommunikation   ' );  
! CALL SET_MENU( 4, 1,    'GeniBus Pumpenskalierungsfakt.' );  
! CALL SET_MENU( 4, 1,    'GeniBus Busdaten              ' ); 
! CALL SET_MENU( 4, 1,    'GeniBus Pumpenkennlinie       ' ); 
! CALL SET_MENU( 4, 1,    'GeniBus manuelle Kommunikation' );  
! CALL SET_MENU( 3,0 ,   'ModBus                       ' ); 
! CALL SET_MENU( 4, 1,    'Kommunikation                ' ); 
! CALL SET_MENU( 4, 1,    'Diagnose Empfangsdaten       ' ); 
  CALL SET_MENU( 3,0 ,   'Externe Einfluesse           ' ); 
  CALL SET_MENU( 4, 1,    'Ext. Einfluss Heizkreise    ' );   
  CALL SET_MENU( 4, 1,    'Ext. Einfluss Kessel        ' );   
! CALL SET_MENU( 4, 1,    'Ext. Einfluss BHKWs         ' );   
  CALL SET_MENU( 3,0 ,   'Ausloeseschwellen             ' );
  CALL SET_MENU( 4, 1,    'Gassensor analog (V)          ' );   
  CALL SET_MENU( 4, 1,    'HZG-Druck-Warnschwellen (bar) ' );
! CALL SET_MENU( 3, 1,   'HZG-Wassernachspeisung        ' ); 
  CALL SET_MENU( 3, 1,   'Ueberheizung Hauptkreis (K)   ' );  
  CALL SET_MENU( 3, 1,   'Hauptnutzungsdauer Heizung');
  CALL SET_MENU( 2,0 ,  'Systembereich      '           );
  CALL SET_MENU( 3,0 ,   'Abgleichen'                    );
  CALL SET_MENU( 4, 1,    'Analogeingaenge abgleichen '    );
  CALL SET_MENU( 4, 1,    'Analogausgaenge abgleichen '    );
  CALL SET_MENU( 4, 1,    'Zaehleingaenge abgleichen   '    );
  CALL SET_MENU( 4, 1,    'Gasheizwert (Hu)          '    );   
! CALL SET_MENU( 4, 1,    'Gasheizwert (Ho)          '    );   
! CALL SET_MENU( 4, 1,    'Uhrenabgleich'                 );
  CALL SET_MENU( 3, 1,   'Uhrzeit / Datum'               );  
  CALL SET_MENU( 3, 1,   'Zustand der EINGABETASTE'      );
  CALL SET_MENU( 3, 1,   'Resetinfo'      );
! CALL SET_MENU( 3, 1,   'Letzte Anrufer Fernbedienung'      );
! CALL SET_MENU( 3,0 ,   'Schleichupdate              '  );
! CALL SET_MENU( 4, 1,    'Verz. in ms                 '  );
! CALL SET_MENU( 4, 1,    'Mindestanz. Slaves          '  );
  CALL SET_MENU( 3,0 ,   'RTOS System                 '  );
  CALL SET_MENU( 4,0 ,    'RTOS Systemmeldungen        '  );
  CALL SET_MENU( 5, 1,     'Ausgabekanal Systemmeldungen'  );
  CALL SET_MENU( 5, 1,     'Systemmeldungen ausgeben    '  );
  CALL SET_MENU( 4, 1,    'geplanter RESET             '      );
  CALL SET_MENU( 4, 1,    'Einstellwerte neu initialis.'      );
  CALL SET_MENU( 4, 1,    'Verzoegerung Tastatur (ms)  '      );
  CALL SET_MENU( 4, 1,    'Interv. Steigungsmessung (s)'      );
  CALL SET_MENU( 3, 1,   'Status Relais (Handschalter) '    );
! CALL SET_MENU( 3, 1,   'ascii                        '    );
! CALL SET_MENU( 2, 1,  'Strom Erzeugung/Einspeisung '          );
  CALL SET_MENU( 2, 1,  'Schornsteinfegermenue '          );
! CALL SET_MENU( 2, 1,  'UST Piccolo Dreibrueck'          );
! CALL SET_MENU( 2, 1,  'CAN - Test            '          );

  CLOSE TEMP;  
  PUT 'ER NIL.;rm /RD02/menue.txt' TO RTOS BY A;
  PUT 'ER NIL.;RENAME /RD02/TEMP > menue.txt' TO RTOS BY A;

 /* Alle Nachfolgelemente eines Menuepunkts suchen:                   */
  FOR I TO ME_INDEX REPEAT;
    /* Zeiger auf zuletzt gewaehlten Menuepunkt initialisieren:        */
    ME_ZALT(I)=1;
    /* Nur nach Folgeelementen suchen, wenn kein Ausgang nach EINGABE */
    IF ME_POST(I,1)==0 THEN
      ME_EXIT ='0'B;
      ME_ZAEHL=0;
      FOR J FROM I+1 TO ME_INDEX WHILE NOT ME_EXIT REPEAT;
        /* Testen, ob sich die Elemente auf gleicher Ebene befinden: */
        IF ME_EBENE(J) == ME_EBENE(I) THEN
          ME_EXIT = '1'B; /* Keine Nachfolger da gleiche Ebene       */
        ELSE
          /* Testen, ob das naechste Element eine Ebene tiefer ist:   */
          IF ME_EBENE(J) == ME_EBENE(I)+1 THEN
            /* ist die maximale Anzahl Elemente pro Ebene erreicht:  */
            IF ME_ZAEHL == ME_POSTMAX THEN
              ME_EXIT='1'B; /* POSTMAX erreicht, raus aus der Schleife */
            ELSE
              ME_ZAEHL=ME_ZAEHL+1;   /* Z{hler inkrementieren        */
              ME_POST(I,ME_ZAEHL)=J; /* Nachfolgeelement eintragen   */
            FIN;
          FIN;
        FIN;
      END;
    FIN;
  END;

END; /* of Procedure MENUINIT                                        */

/*+L*/;
MODEND;



















