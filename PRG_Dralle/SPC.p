/*********************************************************************/
/*                                     Ersterstellung:    13.07.22   */
/* Include Datei in der alle benîtigten Variablen fÅuer               */
/*             'BIOGASANLAGE DRALLE  HOHNE                           */
/* deklariert sind. ZusÑtzlich existiert noch DCL.p in der alle      */
/* Variablen deklariert sind.                                        */
/* DCL.p  ins Modul HAUPT                                            */
/* SPC.p  in alle anderen Module                                     */
/* Stand: 13.07.22                                                   */
/* Suchen mit "<<<"                                                  */
/*********************************************************************/

  /* HAUPT-Modulvariblen <<<  */
  /* Systemvorgaben                                                  */
  SPC BIT32     INV BIT(32)  GLOBAL                   ; 
  SPC NR_PRJ    INV FIXED GLOBAL           ; /* PROJEKTNUMMER        */
  SPC VERSION   INV FIXED GLOBAL         ; /* Versionsnummer des PRG */
  SPC N_BHKW    INV FIXED GLOBAL         ; /* 1-8  BHKW              */
  SPC N_KESSEL  INV FIXED GLOBAL         ; /* 1-4  Kessel            */
  SPC N_HZKR    INV FIXED GLOBAL         ; /* 1-16 Heizkreise        */
  SPC N_SPEI    INV FIXED GLOBAL         ; /* 1-4  Brauchwasserspei. */
  SPC N_RELPLT  INV FIXED GLOBAL         ; /* 1-10 Relaisplatinen    */
  SPC N_SEITE   INV FIXED GLOBAL         ; /* 1-8  DISPLAY-Seiten    */
  SPC N_USEITE  INV FIXED GLOBAL         ; /* 1-n  Unterseiten       */
  SPC N_DIGIN   INV FIXED GLOBAL         ; /* 1 -144 Digitaleingaenge*/
  SPC ZCANPLAT  INV FIXED GLOBAL         ; /* Anz. CAN-EW-Platinen   */
  SPC CANBASE   INV FIXED GLOBAL          ; /* CAN-Basisadresse      */
  SPC B_PANEL  INV BIT(1) GLOBAL         ; /* 0: LCD  1: PANEL       */
    /* ANPASSEN DATENSTATIONEN in Mpc.p <<<<                         */

  SPC B32          BIT(32)   GLOBAL;
  SPC FLANTWORT1   FLOAT     GLOBAL;
  SPC FLANTWORT2   FLOAT     GLOBAL;
  SPC FL55ANTWORT  FLOAT(55) GLOBAL;
  SPC F31ANTWORT1  FIXED(31) GLOBAL;
  SPC F31ANTWORT2  FIXED(31) GLOBAL;
  SPC F31ANTWORT3  FIXED(31) GLOBAL;
  SPC CHANTWORT1   CHAR(20)  GLOBAL;
  SPC CHANTWORT2   CHAR(20)  GLOBAL;
  SPC CHANTWORT3   CHAR(80)  GLOBAL;
  SPC FTAST        FIXED     GLOBAL;
  SPC BZEIL        BIT(32)   GLOBAL;  /* WELCHE ZEILEN HABEN SICH GEAENDERT... ZEILE1 -> BIT(1)  */
  SPC DISPSTATUS   BIT(32)   GLOBAL;  /* 1: normales Menue ab POS(x,y) z Zeichen rot  2: Anzeigemenue rechte Displayhaelfte rot (ab POS(x>20))  3: grosses Menue(80 Spalten, 25 Zeilen) ab POS(x,y) z Zeichen rot */
  SPC XROT         FIXED     GLOBAL;  /* POS x ab der das Menue rot sein soll */
  SPC YROT         FIXED     GLOBAL;  /* POS y ab der das Menue rot sein soll */
  SPC ZROT         FIXED     GLOBAL;  /* Anzahl der roten Zeichen ab POS x,y  */
  SPC ZEIL(  )     CHAR(46)  GLOBAL;
  SPC DISPSTATUS2  BIT(32)   GLOBAL;  /* 1: normales Menue ab POS(x,y) z Zeichen rot  2: Anzeigemenue rechte Displayhaelfte rot (ab POS(x>20))  3: grosses Menue(80 Spalten, 25 Zeilen) ab POS(x,y) z Zeichen rot */
  SPC XROT2        FIXED     GLOBAL;  /* POS x ab der das Menue rot sein soll */
  SPC YROT2        FIXED     GLOBAL;  /* POS y ab der das Menue rot sein soll */
  SPC ZROT2        FIXED     GLOBAL;  /* Anzahl der roten Zeichen ab POS x,y  */
  SPC ZEIL80(  )   CHAR(80)  GLOBAL;
  SPC DISPSTATUS3  BIT(32)   GLOBAL;  /* 1: normales Menue ab POS(x,y) z Zeichen rot  2: Anzeigemenue rechte Displayhaelfte rot (ab POS(x>20))  3: grosses Menue(80 Spalten, 25 Zeilen) ab POS(x,y) z Zeichen rot */
  SPC XROT3        FIXED     GLOBAL;  /* POS x ab der das Menue rot sein soll */
  SPC YROT3        FIXED     GLOBAL;  /* POS y ab der das Menue rot sein soll */
  SPC ZROT3        FIXED     GLOBAL;  /* Anzahl der roten Zeichen ab POS x,y  */
  SPC INFOTXT      CHAR(120) GLOBAL;  /* Infotext fuer Webbrowser  */
  SPC IDPI         CHAR(50)  GLOBAL;  /* Steuerungsname fuer PI         */
  SPC IDPI2        CHAR(50)  GLOBAL;  /* ---                            */
  SPC IDPI3        CHAR(50)  GLOBAL;  /* ---                            */
  SPC IDPI4        CHAR(50)  GLOBAL;  /* ---                            */
  SPC IDPI5        CHAR(50)  GLOBAL;  /* ---                            */
  SPC ZEILVIS(  )  CHAR(60)  GLOBAL;  /* Textfeld fuer ext. Einstellungen AN Visu */
  SPC ZEILRUECK(  )CHAR(60)  GLOBAL;  /* Textfeld fuer ext. Einstellungen VON Visu */

  SPC LCDZEIL      FIXED     GLOBAL;  /* Schreibpos. Zeile( )        */
  SPC LCDSPALT     FIXED     GLOBAL;  /* Schreibpos. Spalte in Zeile */
  SPC BROT         BIT(1)    GLOBAL;  /* 1: rot schreiben aktiv      */
  SPC CHIN30       CHAR(30)  GLOBAL;  /* String fuer Tastatureingaben */
  SPC Z_CIN30      FIXED     GLOBAL;  /* Position Tastatureingaben   */
  SPC Z_BUTTON     FIXED     GLOBAL;  /* Anzahl BedienButtons        */
  SPC BUTTON(  , ) FIXED     GLOBAL;  /* BUTTON Bedienung an Pos x,y,? */
  SPC Z_BEDIEN     FIXED     GLOBAL;  /* Anzahl Bediener             */
  SPC CH_BEDIEN( ) CHAR(30)  GLOBAL;  /* Name Bediener               */
  SPC Z_BEDDAUER( ) FIXED    GLOBAL;  /* Bediendauer Bediener        */
  SPC Z_IPLICHT    FIXED     GLOBAL;  /* Zaehler ext. Lichtanforderung */
  SPC FL_ATEXT     FLOAT     GLOBAL;  /* Wert ext. AT-Vorgabe         */

  /*-----------------------------------------------------------------*/
  /* Fuehlerbezogene Daten (1 bis N_FUEHL):                           */
  SPC X_AEIN   (   ) FLOAT  GLOBAL;/* Absolute Eingangswerte          */
  SPC FP_HARD  (   ) FIXED  GLOBAL;/* Hardwarekanal des Analogeingangs*/
  SPC FP_TYP   (   ) FIXED  GLOBAL;/* Fuehlertyp des Analogkanals      */
  SPC FP_HZKR  (   ) FIXED  GLOBAL;/* Heizkreisnummer des Fuehlers     */
  SPC FP_MIT   (   ) FLOAT  GLOBAL;/* Mittelwertbildung Tau in s      */
  SPC FP_NAME  (   ) CHAR(20)GLOBAL;/* Name des Fuehlers               */
  SPC FP_POS(  ,  ) FIXED  GLOBAL;/* Anzeigeposition Seite, Zeile    */
  SPC Z_FUEHLST(   ) FIXED  GLOBAL;/* Fehlerzaehler Ueberwachung AI     */
  SPC FL_AIVIERT(   ,  )  FLOAT  GLOBAL; /* Viertelst. Integr. AI       */
  SPC FELD(   )      FLOAT  GLOBAL; /* Feld fuer Bitwerte Analogeingaenge */            
  
  /* Analogausgangsdaten                                             */
  SPC X_AAUS  (   ) FLOAT   GLOBAL;/* Analogausgangswerte in %  >60 z.B. UPE,... */
  SPC AP_NAME  (  ) CHAR(20)GLOBAL;/* Name des Analogausgangs        */
  SPC AP_HARD  (  ) FIXED   GLOBAL;/* Hardwarekanal des Analogausg.  */
  SPC AP_TYP   (  ) FIXED   GLOBAL;/* Art des Analogausgangs         */
  SPC X_AAUSMERK(  ) FLOAT  GLOBAL;/* Merker fuer Analogausgangswerte */
  SPC PW_NAME  (  ) CHAR(20)GLOBAL;/* Name des PWM Ausgangs          */
  SPC Z_PWM(  )     FIXED   GLOBAL; /* Zaehler fuer Pulsweitenmodulation */
  SPC FL_PWMPRO(  ) FLOAT   GLOBAL; /* Ausgang PWM in %               */

  /* Digitalausgangsdaten                                            */
  SPC DO_NAME(   )   CHAR(22) GLOBAL;/* Name des Digitalausgangs      */
  SPC DO_HARD(   )   FIXED    GLOBAL;/* Digital-Hardwareausgangsnr    */
  SPC DO_TON (   )   FIXED    GLOBAL;/* Dauer Soft-Hand-EIN in SEC    */
  SPC DO_TOFF(   )   FIXED    GLOBAL;/* Dauer Soft-Hand-AUS in SEC    */
  SPC N_DIGOUT       FIXED    GLOBAL;/* Anzahl init. Digitalausgaenge  */
  SPC Z_DOVIERT(   ) FIXED    GLOBAL;/* Viertelst. Zaehler DO        */
  SPC BI_DAUS (  )   BIT(16)  GLOBAL;/* Digitaldaten fuer Relaisplatinen */
  SPC Z_UDNSTOER(  ) FIXED    GLOBAL;/* Stoerungszaehler Ausgangsbausteine */
  SPC B_DO   (   )   BIT(1)   GLOBAL;/* Zustand Relais()               */
  SPC B_DOMERK(   )  BIT(1)   GLOBAL;/* Zustand Relais()               */
  SPC B_DONEU (   )  BIT(1)   GLOBAL;/* Zustand Relais()               */

  /* Digitaleingangsdaten                                            */
  SPC DI_NAME(   ) CHAR(25)  GLOBAL; /* Name des Digitaleingangs      */
  SPC Z_ZAEHLMERK(   ) FIXED(31) GLOBAL;/* Merker fÅr Zaehlerstaende    */
  SPC Z_DIVIERT(   )   FIXED  GLOBAL; /* Viertelst. Zaehler DI        */
  SPC Z_IMPDIVIERT(   ,  ) FIXED  GLOBAL; /* 1/4h Zaehler Impulse DI      */
  SPC BI_DEIN(   )     BIT(1) GLOBAL; /* Digitaleingaenge                 */
  SPC BI_DEINMERK(   ) BIT(1) GLOBAL; /* Merker fuer Digitaleingaenge   */
  SPC BI_DEINBEW(   )  BIT(1) GLOBAL; /* bewertete Digitaleingaenge   */
  SPC P_DI(   )        FLOAT  GLOBAL; /* Impulsabstaende in Leistung      */ 
  SPC FL_IMPDAU (   ) FLOAT     GLOBAL;/* Impulsdauermessung         */
  SPC ZP_IMPALT (   ) CLOCK     GLOBAL;/* Zeitpunkt letzter Impuls   */
  SPC Z_IMPWART (   ) FIXED(31) GLOBAL;/* Warted. auf neuen Imp. (s) */
  SPC B_IMPNEU  (   ) BIT(1)    GLOBAL;/* neuer Impuls Digitaleing.  */

  /* Variablen fuer die BHKW (1 bis N_BHKW)                           */
  SPC B_BEIN   (  ) BIT(1) GLOBAL;/* BHKW EIN/AUS Signal             */
  SPC B_BBEREIT(  ) BIT(1) GLOBAL;/* 1: BHKW ist lauffÑhig           */
  SPC B_BPMP   (  ) BIT(1) GLOBAL;/* Pumpe EIN/AUS                   */
  SPC PE_BIST  (  ) FLOAT  GLOBAL;/* Ist-Leistung des BHKW           */
  SPC PE_BSOLL (  ) FLOAT  GLOBAL;/* Solleistung  des BHKW           */
  SPC Z_BPNL   (  ) FIXED  GLOBAL;/* Zaehler fuer BHKW-Pumpennachl.  */
  SPC Z_SVS    (  ) FIXED  GLOBAL;/* Zaehler fuer BHKW-Startversuch  */
  SPC B_BSTOER (  ) BIT(1) GLOBAL;/* BHKW ist gestîrt                */
  SPC B_BL     (  ) BIT(1) GLOBAL;/* BHKW lÑuft                      */
  SPC ZA_PEBHKW(  ) FIXED GLOBAL; /* Zeiger Anaout BHKW-Leistung     */
  SPC ZA_BHKWPMP(  ) FIXED GLOBAL;/* Zeiger Anaout BHKW-Pumpenleist. */
  SPC ZE_PB    (  ) FIXED GLOBAL; /* Zeiger auf Anain BHKW-Leistung  */
  SPC ZE_BV    (  ) FIXED GLOBAL; /* Zeiger auf Anain BHKW-Vorlauf   */
  SPC ZE_BR    (  ) FIXED GLOBAL; /* Zeiger auf Anain BHKW-Ruecklauf */
  SPC Z_BLZ(  ) FIXED(31) GLOBAL; /* Zaehler fuer kont. Laufzeit     */
  SPC TC_BHZGV (  ) FLOAT GLOBAL; /* BHKW Vorlauftemperaturen        */
  SPC TC_BHZGR (  ) FLOAT GLOBAL; /* BHKW Ruecklauftemperaturen      */
  SPC TC_BVSOLL(  ) FLOAT GLOBAL; /* BHKW VL-Soll-Temp               */
  SPC B_BHKWMIA(  ) BIT(1) GLOBAL;/* BHKW-Mischer auf                */
  SPC B_BHKWMIZ(  ) BIT(1) GLOBAL;/* BHKW-Mischer zu                 */
  SPC Z_BHKWMI (  ) FIXED  GLOBAL; /* Softwareendkontakt fuer BHKWmi. */
  SPC FL_BLFZGES(  ) FLOAT GLOBAL; /* BHKW-Gesamtlaufzeit in h       */
  SPC FL_BKWHGES(  ) FLOAT GLOBAL; /* BHKW-Gesamterzeugung in kWh    */
  SPC Z_BLZVIERT(  ) FIXED  GLOBAL;/* BHKW-Viertelstundenlaufzeit    */
  SPC Z_BTHERMVL(  ) FIXED  GLOBAL;/* Zaehler BHKW-Thermostat VL     */
  SPC Z_BTHERMRL(  ) FIXED  GLOBAL;/* Zaehler BHKW-Thermostat RL     */
  SPC Z_BLZMIN   FIXED(31) GLOBAL;/* kuerzeste BHKW-Laufzeit         */
  SPC PE_MAX        FLOAT  GLOBAL;/* max. Gesamtleistung fuer n BHKW  */
  SPC PE_MIN        FLOAT  GLOBAL;/* min. Gesamtleistung fuer n BHKW  */
  SPC PE_RMIN       FLOAT  GLOBAL;/* untere Regelgrenze (Gesamtleist)*/
  SPC PE_BMAXMOGL   FLOAT  GLOBAL;/* maximal moegl. el. BHKW-Leistung */
  SPC PT_GRUND      FLOAT  GLOBAL;/* Faktoren fuer die Bestimmung    */
  SPC PT_FAKTOR     FLOAT  GLOBAL;/* der thermischen BHKW-Leistung   */
  SPC Z_LZBPMP ( ) FIXED(31) GLOBAL; /* Z. Laufz. BHKW-PMP-HZG       */
  SPC PT_BIST  (  ) FLOAT  GLOBAL;/* thermische Ist-Leistung des BHKW*/
  SPC FL_BTHKWH(  )  FLOAT GLOBAL; /* BHKW-Waermeerzeugung in kWh     */
  SPC B_BERLAUBT2(  ) BIT(1) GLOBAL; /* 1: BHKW( ) ist freigegeben   */
  SPC B_BLHILF( ) BIT(1)    GLOBAL; /* Hilfsbit fuer CAN-Bus BHKW-laeuft */
  SPC B_BMUSSEIN( )   BIT(1) GLOBAL;/* BHKW soll angefordert werden  */
  SPC B_BMUSSAUS( )   BIT(1) GLOBAL;/* BHKW-Anforderung soll weg     */
  SPC Z_MUSSAUS(  )   FIXED GLOBAL; /* Hilfsvariable CAN-Komm        */ 
  SPC Z_BBL    (  )   FIXED GLOBAL; /* Hilfsvariable CAN-Komm        */ 
  SPC Z_BCAN(  )  FIXED     GLOBAL; /* Zaehler fuer CAN-Sendungen BHKWs  */
  SPC Z_FEHLERKRA(  ) FIXED GLOBAL; /* CAN-Fehlernummer Kraftwerk-BHKW */
  SPC Z_WARNKRA(  )  FIXED  GLOBAL; /* CAN-Warnnummer Kraftwerk-BHKW */
  SPC Z_MINAUSKRA(  ) FIXED GLOBAL; /* CAN-Mindestauszeit Kraftwerk-BHKW */
  SPC B_BWARN(  ) BIT(1)    GLOBAL; /* 1: BHKW-Warnung                   */
  SPC B_START(  ) BIT(1)    GLOBAL; /* 1: BHKW-Start laeuft              */
  SPC Z_START24       FIXED GLOBAL; /* Starts in 24h                 */
  SPC X_AAPBHKW(  ) FLOAT GLOBAL; /* Analoge Ansteuerung P-BHKW     (%) */
  SPC PT_BHKWMOEG     FLOAT GLOBAL; /* thermische BHKW-Leistung      */

  /* Variablen fuer die Kessel (1 bis N_KESSEL)                       */
  SPC B_KEIN   (  ) BIT(1) GLOBAL;/* Kessel EIN/AUS Signal           */
  SPC B_KL     (  ) BIT(1) GLOBAL;/* Kessel laeuft                   */
  SPC B_KPMP   (  ) BIT(1) GLOBAL;/* KesselPumpe                     */
  SPC Z_KPNL   (  ) FIXED  GLOBAL; /* Zaehler fuer Kesselpumpennachlauf */
  SPC B_KLRAUF (  ) BIT(1) GLOBAL;/* Kessel-Leistung rauf Signal     */
  SPC B_KLRUNT (  ) BIT(1) GLOBAL;/* Kessel-Leistung runter Signal   */
  SPC Z_KSTELL (  ) FIXED  GLOBAL;/* Stellung Kesselbrenner in s     */
  SPC ZE_KV    (  ) FIXED GLOBAL; /* Zeiger auf Anain Kesselvorlauf   */
  SPC ZE_KR    (  ) FIXED GLOBAL; /* Zeiger auf Anain Kesselruecklauf  */
  SPC ZA_KESPMP(  ) FIXED GLOBAL; /* Zeiger Anaout  Kesselpumpenleist.*/
  SPC ZA_KANST (  ) FIXED GLOBAL; /* Zeiger Anaout  Kesselansteuerung */
  SPC RA_KTI   (  ) FLOAT GLOBAL; /* Pth-Regler I-Anteil              */
  SPC RA_KTP   (  ) FLOAT GLOBAL; /* Pth-Regler P-Anteil              */
  SPC RA_KT1   (  ) FLOAT GLOBAL; /* Pth-Regler, alte Abweichung     */
  SPC RA_KTDTAU (  ) FLOAT GLOBAL; /* Pth-Regler geglaett. D-Anteil   */
  SPC RA_KTDITAU(  ) FLOAT GLOBAL; /* Pth-Regler geglaett. DI-Anteil  */
  SPC RA_KPI   (  ) FLOAT GLOBAL; /* KPMP-Regler I-Anteil              */
  SPC RA_KPP   (  ) FLOAT GLOBAL; /* KPMP-Regler P-Anteil              */
  SPC RA_KP1   (  ) FLOAT GLOBAL; /* KPMP-Regler, alte Abweichung     */
  SPC RA_KPDTAU (  ) FLOAT GLOBAL; /* KPMP-Regler geglaett. D-Anteil   */
  SPC RA_KPDITAU(  ) FLOAT GLOBAL; /* KPMP-Regler geglaett. DI-Anteil  */
  SPC B_KESMIA (  ) BIT(1) GLOBAL;/* Kesselmischer auf               */
  SPC B_KESMIZ (  ) BIT(1) GLOBAL;/* Kesselmischer zu                */
  SPC Z_KESMI  (  ) FIXED  GLOBAL; /* Softwareendkontakt fuer Kesmi.  */
  SPC Z_KMISTELL(  ) FIXED  GLOBAL;/* Stellung Kesselmischer in s    */
  SPC XA_KPMP  (  ) FLOAT GLOBAL; /* Ansteuerung Kesselpumpe         */
  SPC Z_KLZ    (  ) FIXED(31) GLOBAL; /* Kesselanforderungszeit (s)      */
  SPC Z_KLZMIN      FIXED(31) GLOBAL; /* kuerzeste Kessellaufzeit         */
  SPC TC_KV    (  ) FLOAT GLOBAL; /* Kesselvorlauftemperaturen       */
  SPC TC_KR    (  ) FLOAT GLOBAL; /* Kesselruecklauftemperaturen      */
  SPC Z_KHARDST(  ) FIXED GLOBAL; /* Zaehler Kessel Hardwarestoerung   */
  SPC B_KHARDST(  ) BIT(1) GLOBAL;/* Kesselstoerung wg. Digitaleing.  */
  SPC B_KSOFTST(  ) BIT(1) GLOBAL;/* Kesselstoerung wg. keine Spreiz. */
  SPC Z_LZKPMP (  ) FIXED(31) GLOBAL; /* Z. Laufz. Kesselpumpe        */
  SPC Z_PKES   (  ) FIXED  GLOBAL;/* Zaehler Kesselleistungseinstellung */
  SPC PT_KESAKT(  ) FLOAT GLOBAL; /* aktuelle Kesselleistung         */
  SPC PT_KESSOLL(  ) FLOAT GLOBAL; /* aktuelle Kesselsollleistung    */
  SPC Z_KL     (  ) FIXED GLOBAL; /* Kesselbetriebszeit in s         */
  SPC TC_KVSOLL(  ) FLOAT GLOBAL; /* Kesselvorlauf-Soll-Temp         */
  SPC PT_KSOLL (  ) FLOAT GLOBAL; /* Anforderung gemaess Waermebedarf (%) */
  SPC X_AAKPTH (  ) FLOAT GLOBAL; /* Analoge Ansteuerung P-Kessel   (%) */
  SPC PT_MINKES     FLOAT GLOBAL; /* kleinste PT-Anforderung aller Kessel (%) */
  SPC Z_PTMINKES    FIXED GLOBAL; /* Zaehler Kessel Min-Leistung     */
  SPC B_KTHERM (  ) BIT(1) GLOBAL;/* Kessel-Thermostat ( >KVMAX+4)     */
  SPC Z_KTHERM (  ) FIXED  GLOBAL;/* Kessel-Stellung Brenner in s      */
  SPC TC_KVMERK(  ) FLOAT GLOBAL; /* Kesselvorlauftemperaturmerker   */
  SPC B_KST2   (  ) BIT(1) GLOBAL; /* 1: Kessel 2. Stufe angefordert    */
  SPC KES_TXT1 (  ) CHAR(40) GLOBAL;/* Kes-Beschreibung Text1        */
  SPC KES_TXT2 (  ) CHAR(40) GLOBAL;/* Kes-Beschreibung Text2        */
  SPC Z_STOKMS (  ) FIXED GLOBAL;/* Stockerschn LFZ ms            */
  SPC Z_STOKVIERT(  ) FIXED GLOBAL;/* Stockerschn LFZ (1/4h) (s *10)     */
  SPC Z_KTEMPEIN(  ) FIXED GLOBAL;/* >0: Stoker vor < 30Min noch gelaufen */

  /* Variablen fuer die Brauchwasserspeicher (1 bis N_SPEI)           */
  SPC B_ZIRKPMP  (  )BIT(1) GLOBAL;/* Brauchwasserzirkulationspumpe   */
  SPC B_LPMP     (  )BIT(1) GLOBAL;/* Brauchwasserladepumpe           */
  SPC B_SPMP     (  )BIT(1) GLOBAL;/* Brauchwasserspeisepumpe         */
  SPC TC_BWO     (  )FLOAT GLOBAL; /* Brauchwassertemperatur oben     */
  SPC TC_BWIST   (  )FLOAT GLOBAL; /* Speise VL                       */
  SPC TC_BWVOR   (  )FLOAT GLOBAL; /* Lade VL                         */
  SPC TC_BWRUECK (  )FLOAT GLOBAL; /* Lade RL                         */
  SPC TC_ZIRK    (  )FLOAT GLOBAL; /* Zirkulation RL                  */
  SPC ZE_BWIST   (  )FIXED GLOBAL; /* Zeiger auf Anain Speise VL      */
  SPC ZE_BWO     (  )FIXED GLOBAL; /* Zeiger auf Anain Speicher oben  */
  SPC ZE_BWVOR   (  )FIXED GLOBAL; /* Zeiger auf Anain Lade VL        */
  SPC ZE_BWRUECK (  )FIXED GLOBAL; /* Zeiger auf Anain Lade RL        */
  SPC ZE_ZIRK    (  )FIXED GLOBAL; /* Zeiger auf Anain Zirkulation RL */
  SPC ZA_BWLPMP  (  )FIXED GLOBAL; /* Zeiger auf Anaout Ladepumpe     */
  SPC ZA_BWSPMP  (  )FIXED GLOBAL; /* Zeiger auf Anaout Speisepumpe   */
  SPC ZA_BWZPMP  (  )FIXED GLOBAL; /* Zeiger auf Anaout Zirkpumpe     */
  SPC B_BWDRIG   (  )BIT(1) GLOBAL;/* 1: Brauchwasseranforderung drin.*/
  SPC B_BWMOGL   (  )BIT(1) GLOBAL;/* 1: Brauchwasseranforderung moegl.*/
  SPC B_BWNORM   (  )BIT(1) GLOBAL;/* 1: Brauchwasseranforderung norm.*/
  SPC B_BWNACHT  (  )BIT(1) GLOBAL;/* 1: Brauchwasseranforderung Nacht*/
  SPC B_BWB      (  )BIT(1) GLOBAL;/* Bedingung Lade VL warm genug    */
  SPC TC_BWTW    (  )FLOAT GLOBAL; /* Bw-Speisesolltemp               */
  SPC Z_LZBWLPMP (  )FIXED(31) GLOBAL; /* Z. Laufz. BW-Ladepumpe     */
  SPC Z_LZBWSPMP (  )FIXED(31) GLOBAL; /* Z. Laufz. BW-Speisepumpe   */
  SPC Z_LZBWZPMP (  )FIXED(31) GLOBAL; /* Z. Laufz. BW-Zirkpmp       */
  SPC B_BWANF    (  )BIT(1) GLOBAL;/* 1: Brauchwasseranforderung      */
  SPC B_BWANFGES     BIT(1) GLOBAL;/* 1: Brauchwasseranforderungges   */
  SPC TC_BWVLS   (  )FLOAT GLOBAL; /* gef. Brauchwasser-Vorlaufsoll   */
  SPC TC_BWVLSGES    FLOAT GLOBAL; /* gef. Brauchwasser-Vorlaufsollges*/
  SPC TC_BWS     (  )FLOAT GLOBAL; /* aktueller WW-Sollwert           */
  SPC Z_LEGIO    (  )FIXED GLOBAL; /* Zaehler fuer Legionellenkill    */
  SPC Z_LEGNACH  (  )FIXED GLOBAL; /* Zaehler fuer nach Legionellenkill  */
  SPC RA_WWLI    (  )FLOAT GLOBAL; /* WW-Lade-Regler I-Anteil           */
  SPC RA_WWLP    (  )FLOAT GLOBAL; /* WW-Lade-Regler P-Anteil          */
  SPC RA_WWL1    (  )FLOAT GLOBAL; /* WW-Lade-Regler, alte Abweichung     */
  SPC RA_WWLDTAU (  )FLOAT GLOBAL; /* WW-Lade-Regler geglaett. D-Anteil   */
  SPC RA_WWLDITAU(  )FLOAT GLOBAL; /* WW-Lade-Regler geglaett. DI-Anteil  */
  SPC XA_WWLAD   (  )FLOAT GLOBAL; /* WW-Lade-Ansteuerung gesamt      */
  SPC XA_WWLADMI (  )FLOAT GLOBAL; /* WW-Lade-Ansteuerung Mischer     */
  SPC XA_WWLADP  (  )FLOAT GLOBAL; /* WW-Lade-Ansteuerung Pumpe       */
  SPC B_LMIAUF   (  )BIT(1) GLOBAL; /* Mischersignal AUF              */
  SPC B_LMIZU    (  )BIT(1) GLOBAL; /* Mischersignal ZU               */
  SPC Z_LMISTELL (  )FIXED GLOBAL; /* Stellung Lademischer in s       */
  SPC TC_BWZS    (  )FLOAT GLOBAL; /* aktueller Zirk-RL-Sollwert      */
  SPC RA_WWZI    (  )FLOAT GLOBAL; /* WW-Zirk-Regler I-Anteil           */
  SPC RA_WWZP    (  )FLOAT GLOBAL; /* WW-Zirk-Regler P-Anteil          */
  SPC RA_WWZ1    (  )FLOAT GLOBAL; /* WW-Zirk-Regler, alte Abweichung     */
  SPC RA_WWZDTAU (  )FLOAT GLOBAL; /* WW-Zirk-Regler geglaett. D-Anteil   */
  SPC RA_WWZDITAU(  )FLOAT GLOBAL; /* WW-Zirk-Regler geglaett. DI-Anteil  */
  SPC XA_WWZI    (  )FLOAT GLOBAL; /* WW-Zirk-Ansteuerung             */
  SPC XA_WWSPEIP (  )FLOAT GLOBAL; /* WW-Speisepumpenansteuerung      */
  SPC X_CALT     (  )FLOAT GLOBAL; /* Merker fuer Reg Speisep.        */
  SPC WW_NAME    (  )CHAR(15) GLOBAL;/* Name der WW-Bereitung          */
  SPC Z_BWKALT       FIXED GLOBAL; /* Zaehler BW-Austritt zu kalt in s */
  SPC RA_BWALT   ( ) FLOAT GLOBAL;

  /* Heizkreisbezogene Daten (1 bis N_HZKR)                          */
  SPC ZE_HK    (  ) FIXED GLOBAL; /* Fuehlernummer des Heizkreisvor.  */
  SPC ZE_HKR   (  ) FIXED GLOBAL; /* Fuehlernummer des Heizkreisrueck. */
  SPC ZA_PHK   (  ) FIXED GLOBAL; /* Zeiger auf analog AUS Pumpe     */
  SPC B_PMPHK  (  ) BIT(1) GLOBAL; /* Heizkreispumpe                 */
  SPC B_MIAUF  (  ) BIT(1) GLOBAL; /* Mischersignal AUF              */
  SPC B_MIZU   (  ) BIT(1) GLOBAL; /* Mischersignal ZU               */
  SPC TC_HKSOLL(  ) FLOAT GLOBAL; /* Heizkreisvorlaufsolltemperatur  */
  SPC TC_HKSOLLGES(  ) FLOAT GLOBAL; /* Heizkreisvorlaufsolltemperatur incl. Integrator */
  SPC TC_HKIST (  ) FLOAT GLOBAL; /* Ist-Temperatur des Heizkreises  */
  SPC TC_HKR   (  ) FLOAT GLOBAL; /* Ist-Temperatur des Heizkreisr.  */
  SPC RA_MI    (  ) FLOAT GLOBAL; /* HK-Mischer-Regler I-Anteil           */
  SPC RA_MP    (  ) FLOAT GLOBAL; /* HK-Mischer-Regler P-Anteil          */
  SPC RA_M1    (  ) FLOAT GLOBAL; /* HK-Mischer-Regler, alte Abweichung     */
  SPC RA_MDTAU (  ) FLOAT GLOBAL; /* HK-Mischer-Regler geglaett. D-Anteil   */
  SPC RA_MDITAU(  ) FLOAT GLOBAL; /* HK-Mischer-Regler geglaett. DI-Anteil  */
  SPC XA_HKMI  (  ) FLOAT GLOBAL; /* HK-Mischer-Ansteuerung          */
  SPC XA_HKP   (  ) FLOAT GLOBAL; /* HK-Pumpen-Ansteuerung           */
  SPC Z_HOCHHK (  ) FIXED  GLOBAL;/* Zaehler Hochlaufphase           */
  SPC Z_RUNTHK (  ) FIXED  GLOBAL;/* Zaehler Runterlaufphase         */
  SPC B_TAERHK (  ) BIT(1) GLOBAL;/* Tag erreicht (einzelner Hzkr.)  */
  SPC B_NAERHK (  ) BIT(1) GLOBAL;/* Nachtabsenkung Hzkr. erreicht   */
  SPC B_ABSHK  (  ) BIT(1) GLOBAL;/* 1: Absenk. Heizkreis(n) aktiv   */
  SPC B_ABSTOG (  ) BIT(1) GLOBAL;/* Absenkung Heizkreis umschalten  */
  SPC B_VORHK  (  ) BIT(1) GLOBAL;/* Vor-Phase des Heizkreises       */
  SPC B_HOCHHK (  ) BIT(1) GLOBAL;/* Hochlaufphase des einzelnen Hzkr*/
  SPC B_RUNTHK (  ) BIT(1) GLOBAL;/* Runter-Phase des einzelnen Hzkr */
  SPC ZP_ABSEHK(  ) CLOCK  GLOBAL;/* Zeit aktuelles Absenkungsende   */
  SPC DA_ABSEHK(  ) FIXED  GLOBAL;/* Tagesnummer akt. Absenkungsende */
  SPC B_HMT    (  ) BIT(1) GLOBAL; /* Heizkreis EIN wg. Tagesheizgr. */
  SPC B_HMR    (  ) BIT(1) GLOBAL; /* Hausmeister Raum               */
  SPC B_HMN    (  ) BIT(1) GLOBAL; /* Heizkreis EIN wg. Nachtheizgr. */
  SPC Z_HKMI   (  ) FIXED  GLOBAL; /* Softwareendkontakt fuer HK-Mi. */
  SPC TD_HKINT (  ) FLOAT  GLOBAL; /* langfrist. Integrator Soll-Ist */
  SPC Z_HKMISTELL(  ) FIXED  GLOBAL;/* Stellung HK-Mischer in s      */
  SPC P_HKTH(  )     FLOAT GLOBAL; /* Pth von Softwarewaermezaehler  */
  SPC DF_HKTH(  )    FLOAT GLOBAL; /* Df  von Softwarewaermezaehler  */                          
  SPC TD_INTHK(  )   FLOAT GLOBAL; /* Integrator dT fuer SoftWMZ     */
  SPC FL_THVIERT(  ,  ) FLOAT   GLOBAL;/* kWh th.-Leistung der akt. 1/4h*/
  SPC Z_LZHKPMP (  ) FIXED(31) GLOBAL; /* Z. Laufz. HK-Pumpe         */
  SPC B_STOERSTW(  ) BIT(1) GLOBAL;/* 1: Heizkreis Stoerung STW      */
  SPC Z_STOERSTW(  ) FIXED  GLOBAL;/* Zaehler Heizkreis Stoerung STW */
  SPC TC_RSOLLAKT(  )   FLOAT  GLOBAL; /* akt. Raumsolltemperaturen     */
  SPC TC_RISTAKT(  )    FLOAT  GLOBAL; /* akt. Raumisttemperaturen      */

  /* Variablen fuer die Timer                                         */
  SPC B_ABSEIN (  ) BIT(1) GLOBAL; /* Zustand Timer                  */
  SPC T_NAME(  ) CHAR(20) GLOBAL;  /* Name Timer                       */

  /* Variable fuer den Terminkalender:                                */
  SPC Z_JAHRTAG  FIXED GLOBAL; /* ZÑhler fuer den aktuellen Jahrestag */
  SPC ZT_JAHR    FIXED(31) GLOBAL; /* Zehntelsekundenstand des Jahres*/
  SPC ZK_WOCH    INV FIXED(31) GLOBAL                  ;/* Wochenkonst */
  SPC ZK_TAG     INV FIXED(31) GLOBAL                 ; /* Tageskonst  */
  SPC ZK_STUND   INV FIXED(31) GLOBAL                 ; /* Stundenkonst*/
  SPC ZK_MIN     INV FIXED(31) GLOBAL               ;   /* Minutenkonst*/
  SPC ZK_SEC     INV FIXED(31) GLOBAL              ;    /* Sekundenkons*/

  /* Das aktuelle Datum:                                             */
  SPC ZP_NOW    CLOCK GLOBAL; /* Die globale Zeit                    */
  SPC DA_WOTAG  FIXED GLOBAL; /* aktueller Wochentag, MO bis SO: 1-7 */
  SPC DA_DAT    FIXED GLOBAL; /* 1. bis 31. des Monats               */
  SPC DA_MON    FIXED GLOBAL; /* 1. bis 12. Monat                    */
  SPC DA_JAH    FIXED GLOBAL; /* Jahr 1973-32767                     */
  SPC DA_TNR    FIXED GLOBAL; /* Tagesnummer des aktuellen Datums    */
  SPC ZF_STD    FIXED      GLOBAL; /* Aktuelle Zeit als FIXED        */
  SPC ZF_MIN    FIXED      GLOBAL; /* Aktuelle Zeit als FIXED        */
  SPC ZF_SEK    FIXED      GLOBAL; /* Aktuelle Zeit als FIXED        */
  SPC Z_SEKTAG  FIXED(31) GLOBAL; /* Tagessekundenstand       */
  SPC B_DATUMNEU  BIT(1) GLOBAL; /* Falls Mitternacht, Datum auslesen*/
  SPC ZP_RESET   CLOCK   GLOBAL; /* RESET-Zeitpunkt                  */
  SPC DA_RESDAT  FIXED   GLOBAL; /* RESET-Datum                      */
  SPC DA_RESMON  FIXED   GLOBAL; /* RESET-Monat                      */

  /* diverse:                                                        */
  SPC N_ANALOG      FIXED  GLOBAL;/* 1-60 Analogausgangskanaele       */
  SPC N_PWM         FIXED  GLOBAL;/* 1-20 PWM-Ausgaenge               */
  SPC N_FUEHLER     FIXED  GLOBAL;/* 1-144 Analogeingangskanaele       */
  SPC B_WDINIT      BIT(1) GLOBAL;/* 1: Watchdog haelt still          */
  SPC B_WATCHDOG BIT(1)  GLOBAL; /* 1: Watchdog beruhigen erlaubt    */
  SPC B_BENUTZER BIT(1)  GLOBAL; /* 1: Watchdog beruhigen erlaubt    */
  SPC B_OUTENA   BIT(1)  GLOBAL; /* 1: digitale Ausgabe erlaubt      */
  SPC B_PARANEU  BIT(1)  GLOBAL; /* 1: Parameter neu initialisieren  */
  SPC B_HT          BIT(1) GLOBAL;/* akt. Tarifzustand 1: HT, 0: NT  */
  SPC ZP_KABSEAKT   CLOCK  GLOBAL;/* Zeit akt. Kernabsenkungsende    */
  SPC DA_KABSEAKT   FIXED  GLOBAL;/* Tagesnr. akt. Kernabsenkungsende*/
  SPC B_KERNABS     BIT(1) GLOBAL;/* 1: Kernabsenkung aktiv          */
  SPC ZD_VOR        DUR    GLOBAL;/* Zeitdauer vor Absenkungsende    */
  SPC B_VOR         BIT(1) GLOBAL;/* 1: T VOR aktiv                  */
  SPC B_NAER        BIT(1) GLOBAL;/* 1: Nachtabsenkungstemp erreicht */
  SPC B_TAER        BIT(1) GLOBAL;/* 1: Tag erreicht                 */
  SPC B_HMNGES      BIT(1) GLOBAL;/* veroderte Heizkreisnachtheizgr. */
  SPC B_HMTGES      BIT(1) GLOBAL;/* veroderte Heizkreistagesheizgr. */
  SPC B_TM1         BIT(1) GLOBAL;/* 1: T max fuer Waermevernichtung   */
  SPC B_TM2         BIT(1) GLOBAL;/* 1: T max fuer Notkuehler          */
  SPC B_TM3         BIT(1) GLOBAL;/* 1: T max fuer Waermeerzeuger      */
  SPC B_WA          BIT(1) GLOBAL;/* 1: WÑrmeanforderung             */
  SPC B_SB          BIT(1) GLOBAL;/* 1: Strombedarf                  */
  SPC B_ESPB        BIT(1) GLOBAL;/* 1: Einschaltsperre BHKW         */
  SPC B_ESPK        BIT(1) GLOBAL;/* 1: Einschaltsperre Kessel       */
  SPC B_KESAUS      BIT(1) GLOBAL;/* 1: Kessel aus                   */
  SPC B_PMIN        BIT(1) GLOBAL;/* 1: untere Leistungsgrenze BHKWs */
  SPC B_PMAX        BIT(1) GLOBAL;/* 1: obere Leistungsgrenze BHKWs  */
  SPC B_HZGWB       BIT(1) GLOBAL;/* 1: Heizung WÑrmebedarf          */
  SPC Z_TMA         FIXED  GLOBAL;/* Zaehler Mindestauszeit          */
  SPC ZF_TMA        FIXED  GLOBAL;/* Mindestauszeit                  */
  SPC TC_VSOLL      FLOAT  GLOBAL;/* Hauptkreisvorlauftemp. Sollwert */
  SPC PE_BEDARF     FLOAT  GLOBAL;/* Leistungsbedarf elt. der Anlage */
  SPC PE_BSOLLGES   FLOAT  GLOBAL;/* Gesamtsolleistung aller BHKW    */
  SPC PE_THERM      FLOAT  GLOBAL;/* elt. Solleist. wegen Temperatur */
  SPC TC_MAX        FLOAT  GLOBAL;/* maximale Hauptkreisvorlauftemp. */
  SPC Z_TEIN        FIXED  GLOBAL;/* Zaehler BHKW1 Einzeit           */
  SPC ZF_TEIN       FIXED  GLOBAL;/* BHKW1 Einzeit (s)               */
  SPC B_BWDRIGG     BIT(1) GLOBAL;/* 1: Brauchwasseranforderung dring*/
  SPC B_BWMOGLG     BIT(1) GLOBAL;/* 1: Brauchwasseranforderung moegl */
  SPC B_BWNORMG     BIT(1) GLOBAL;/* 1: Brauchwasseranforderung norm */
  SPC B_WASONST     BIT(1) GLOBAL;/* 1: Sonstige Waermeanforderung    */
  SPC B_PUMPSCH     BIT(1) GLOBAL;/* 1: Pumpenschonung aktiv         */
  SPC Z_TMESS       FIXED  GLOBAL; /* Zaehler fuer TMESS Routine     */
  SPC Z_HMNEU       FIXED  GLOBAL; /* Zaehler fuer Hausmeister     */
  SPC Z_LRSPERR     FIXED  GLOBAL; /* Zaehler fuer Leistungsregelersperre */
  SPC ZF_LRSPERR    FIXED  GLOBAL;/* Leistungsregler-Sperrzeit         */
  SPC TC_AUSSEN     FLOAT GLOBAL; /* Aussentemperatur                */
  SPC ZUST_HZG      FIXED GLOBAL; /* 1: Auto 2: Tag 3: Nacht         */
  SPC PE_ERZFELD(  ) FLOAT GLOBAL;/* Feld der 15 MIN-PE-Erzeugung    */
  SPC PE_ERZVIERTEL FLOAT GLOBAL; /* Viertelstundenwert PE_BIST(...) */
  SPC PE_FELD(  )   FLOAT GLOBAL;/* Feld der 15 MIN-Durchschnitte PE */
  SPC PE_VIERTEL    FLOAT GLOBAL; /* Viertelstundenwert PE_BEDARF    */
  SPC PE_SCHNITT    FLOAT GLOBAL; /* durchschnittlicher Strombed.    */
  SPC PE_SPITZE     FLOAT GLOBAL; /* maximale 15 MIN-Leistung        */
  SPC ZP_SPITZE     CLOCK GLOBAL; /* Zeitpunkt maximale 15 MIN-Leist.*/
  SPC TC_ATFELD(  ) FLOAT GLOBAL;/* Feld der 15 MIN-Durchschnitte AT */
  SPC TC_ATVIERTEL  FLOAT GLOBAL; /* Viertelstundenwert TC_AUSSEN    */
  SPC TC_AUSSENMAX  FLOAT GLOBAL; /* maximale Aussentemperatur       */
  SPC ZP_AUSSENMAX  CLOCK GLOBAL; /*  Zeitpunkt maximale Aussentemp  */
  SPC TC_AUSSENMIN  FLOAT GLOBAL; /* minimale Aussentemperatur       */
  SPC ZP_AUSSENMIN  CLOCK GLOBAL; /*  Zeitpunkt minimale Aussentemp  */
  SPC TC_VIST       FLOAT GLOBAL; /* Hauptkreisvorlauftemperatur     */
  SPC P_VERTEIL     FLOAT GLOBAL; /* Druck Verteiler                 */
  SPC TC_RUECK      FLOAT GLOBAL; /* Hauptkreisruecklauftemperatur    */
  SPC TC_UEBER      FLOAT GLOBAL; /* Ueberstrîmungstemperatur         */
  SPC TC_VSOLLMAX   FLOAT GLOBAL; /* hoechstes Vorlaufsollmax der HKs */
  SPC TC_WASONST    FLOAT GLOBAL; /* Vorlaufsoll sonstige Anford.    */
  SPC TC_VALT       FLOAT GLOBAL; /* Vorlauftemperatur letzte Messp. */
  SPC ST_VIST       FLOAT GLOBAL; /* Vorlauftemperatursteigung       */
  SPC ST_VSOLL      FLOAT GLOBAL; /* Vorlauftemperatursollsteigung   */
  SPC TD_RA         FLOAT GLOBAL; /* Regelabw. Vorlauftemperatur     */
  SPC Z_STKLEIN FIXED(31) GLOBAL; /* Steigung n Intervalle zu klein  */
  SPC Z_STGROSS FIXED(31) GLOBAL; /* Steigung n Intervalle zu gross  */
  SPC ZF_LMAX   FIXED     GLOBAL; /* Zaehlergrenze fuer BHKW-Pmax      */
  SPC Z_LMAX    FIXED(31) GLOBAL; /* Leistung an oberer Grenze (BHKW)*/
  SPC Z_LMIN    FIXED(31) GLOBAL;/* Leistung an unterer Grenze (BHKW)*/
  SPC ZF_LKMAX  FIXED     GLOBAL; /* Zaehlergrenze fuer Kessel-Pmax  */
  SPC Z_LKMAX   FIXED(31) GLOBAL; /* Leistung an oberer Grenze (Kess)*/
  SPC Z_BANFORD     FIXED GLOBAL; /* Anzahl der angeforderten BHKW   */
  SPC Z_BAKT        FIXED GLOBAL; /* Anzahl der aktiven BHKW         */
  SPC Z_ZEHN        FIXED GLOBAL; /* Zehnminutenstand der Woche      */ 
  SPC Z_KANFORD     FIXED GLOBAL; /* Anzahl der angeforderten Kessel */
  SPC Z_KAKT        FIXED GLOBAL; /* Anzahl der aktiven Kessel       */
  SPC Z_BAKTLR      FIXED GLOBAL; /* Anzahl der aktiven BHKW + 1     */
  SPC Z_PMPHK       FIXED GLOBAL; /* Anzahl aktiver Heizkreispumpen  */
  SPC Z_LETZT       FIXED GLOBAL; /* Zeiger auf letzten akt. Waermeerz*/
  SPC ZE_AUSSEN     FIXED GLOBAL; /* Zeiger auf Anain Aussentemperatur*/
  SPC ZE_VORLAUF    FIXED GLOBAL; /* Zeiger auf Anain Hauptkreisvorl. */
  SPC ZE_RUECK      FIXED GLOBAL; /* Zeiger auf Anain Hauptkreisrueckl.*/
  SPC ZE_UEBER      FIXED GLOBAL; /* Zeiger auf Anain öberstroemung    */
  SPC ZE_PEBED      FIXED GLOBAL; /* Zeiger auf Anain Leistungsbedarf */
  SPC ZF_SOLLST     FIXED GLOBAL; /* Sollsteigungszeit                */
  SPC TD_MAX        FLOAT GLOBAL;/* Grenztemperatur T max             */
  SPC TD_STUFEA     FLOAT GLOBAL;/* Temperaturdiff. eine Stufe rauf   */
  SPC TD_STUFEB     FLOAT GLOBAL;/* Temperaturdiff. eine Stufe runter */
  SPC PE_STUFE      FLOAT GLOBAL;/* Leistungsdiff. eine Stufe rauf    */
  SPC ZD_EIN        DUR   GLOBAL;/* EIN Zeit Brauchwasserladung       */
  SPC ZF_RUNT       FIXED GLOBAL;/* Dauer Absenkungsphase (in 10s)    */
  SPC ZF_HOCH       FIXED GLOBAL;/* Dauer Anhebungssphase (in 10s)    */
  SPC ZF_NKE        FIXED GLOBAL;/* nach Kessel ein                   */
  SPC ZF_NBE        FIXED GLOBAL;/* nach BHKW ein                     */
  SPC ZF_NBA        FIXED GLOBAL;/* nach BHKW aus                     */
  SPC B_ABSSTELL   BIT(1) GLOBAL;/* 1: Absenkung wird gerade verst.   */
  SPC Z_LZ      FIXED(31) GLOBAL; /* kont. Steuerungslaufzeit         */
  SPC FL_SYS        FLOAT GLOBAL;/* Zeitdauer 1*Systakt               */

  SPC PE_BGES     FLOAT GLOBAL;/* gesamte el. Leistung               */
  SPC PT_VIERTEL  FLOAT GLOBAL;/* thermischer Viertelstundenwert     */
  SPC PT_AKT      FLOAT GLOBAL;/* aktuelle thermische Leistung       */
  SPC PT_KAKT     FLOAT GLOBAL;/* aktuelle thermische Leistung KESSEL */
  SPC PT_KVIERTEL FLOAT GLOBAL;/* th. Viertelstundenwert Kessel  */
  SPC PT_FELD(  ) FLOAT GLOBAL;/* 15 MIN-Leistungsbedarfsfeld        */
  SPC PT_ALT      FLOAT GLOBAL;/* Merker fuer PT_SCHNITT              */
  SPC Z_SCHNITT   FIXED  GLOBAL;/* Zaehler Durchschnittsleistungsberechnung  */
  SPC Z_HAUPTNUTZ FIXED  GLOBAL;/* Anzahl der 15 MIN-Durchschnitte/d */
  SPC Z_PANELSEND FIXED  GLOBAL;/* Zaehler zum Anstoss 1/4h Daten Panel */
  SPC B_TAKT1     BIT(1) GLOBAL;/* Taktbit: immer                    */
  SPC B_TAKT2     BIT(1) GLOBAL;/* Taktbit: alle 2 s                 */
  SPC B_TAKT3     BIT(1) GLOBAL;/* Taktbit: alle 4 s                 */
  SPC B_TAKT4     BIT(1) GLOBAL;/* Taktbit: alle 3 s                 */
  SPC B_TAKT5     BIT(1) GLOBAL;/* Taktbit: alle 5 s                 */
  SPC B_TAKT10    BIT(1) GLOBAL;/* Taktbit: alle 10 s                */
  SPC B_TAKT15    BIT(1) GLOBAL;/* Taktbit: alle 15 s                */
  SPC B_TAKT20    BIT(1) GLOBAL;/* Taktbit: 3*     pro MIN           */
  SPC B_TAKT30    BIT(1) GLOBAL;/* Taktbit: 2*     pro MIN           */
  SPC B_TAKT60    BIT(1) GLOBAL;/* Taktbit: einmal pro MIN           */
  SPC B_SAMMELST  BIT(1) GLOBAL; /* Sammelstoerungsmeldung            */
  SPC TX_STOERMEL(   )   CHAR(20) GLOBAL; /* Stoerungsmeldetexte     */  
  SPC Z_STOERNEU(   ) FIXED GLOBAL;/* Zaehler Stoerung neu / Tag      */
  SPC Z_STOER(   ) FIXED   GLOBAL;/* Stoerungsverzoegerer            */
  SPC B_STOERMERK(   ) BIT(1) GLOBAL;/* Stoerungsmerker              */
  SPC B_STOER(   ) BIT(1)  GLOBAL;/* 1: Stoerung steht an            */
  SPC Z_STOERFAST(   ) FIXED GLOBAL;/* >0: dringende Stoerung        */
  SPC Z_TCKLEIN   FIXED   GLOBAL;/* Zaehler TC_VIST<TC_VSOLL          */
  SPC IDSTRING    CHAR(46) GLOBAL; /* Steuerungsname                 */
  SPC PE_BEZUGVIERT FLOAT GLOBAL; /* el. Viertelstundenbez.          */
  SPC P_GAS          FLOAT   GLOBAL;/* akt. Gasleistung gesamt       */
  SPC P_GASK         FLOAT   GLOBAL;/* akt. Gasleistung Kessel       */
  SPC P_GASB         FLOAT   GLOBAL;/* akt. Gasleistung BHKW         */
  SPC FL_GAS         FLOAT   GLOBAL;/* Analogsignal Gassensor + 2.5V */
  SPC N_UPE             FIXED GLOBAL; /* Anzahl UPE-Pumpen           */  
  SPC UPE_ISTST(  )     FIXED GLOBAL; /* Iststufe von UPE-Pumpe      */  
  SPC UPE_ISTKOMM(  )   FIXED GLOBAL; /* Istkommando von UPE-Pumpe   */  
  SPC UPE_ISTDF(  )     FLOAT GLOBAL; /* Istdurchflu· von UPE-Pumpe  */  
  SPC UPE_ISTDRUCK(  )  FLOAT GLOBAL; /* Istdruck von UPE-Pumpe      */  
  SPC UPE_ISTTEMP(  )   FLOAT GLOBAL; /* Isttemperatur von UPE-Pumpe */  
  SPC UPE_WTHERM(  )    FLOAT GLOBAL; /* therm. Arbeit von UPE-Pumpe */  
  SPC UPE_PTHERM(  )    FLOAT GLOBAL; /* therm. Leistung von UPE-Pumpe */  
  SPC UPE_FEHLER(  )    FIXED GLOBAL; /* Fehlerstatus von UPE-Pumpe  */  
  SPC UPE_SOLLST(  )    FIXED GLOBAL; /* Sollstufe an UPE-Pumpe      */  
  SPC UPE_ZSOLLMIN(  )  FIXED GLOBAL; /* Zaehler Sollstufe MIN       */  
  SPC UPE_SOLLKOMM(  )  FIXED GLOBAL; /* Sollkommando an UPE-Pumpe   */  
  SPC UPE_PRO(  )       FLOAT GLOBAL; /* %-Wert fuer UPE-Pumpe       */  
  SPC UPE_NAME(  )   CHAR(20) GLOBAL; /* Name von UPE-Pumpe          */  
  SPC UPE_TYP(  )       FIXED GLOBAL; /* Typ UPE-Pumpe               */  
  SPC UPE_FRQ(  )       FLOAT GLOBAL; /* el. Frequenz Pumpenmotor    */
  SPC UPE_PDC(  )       FLOAT GLOBAL; /* el. Leistung DC Pumpenmotor */

  SPC B_PUENTLAD       BIT(1) GLOBAL; /* Pufferentladepumpe          */
  SPC Z_SCHORNK(  )    FIXED  GLOBAL; /* >1: Schornsteinfegertest Kessel() */
  SPC Z_SCHORNKMAX(  ) FIXED  GLOBAL; /* >1: Schornsteinf. MAX    Kessel() */
  SPC Z_SCHORNB( )     FIXED  GLOBAL; /* >1: Schornsteinfegertest BHKW()   */
  SPC B_SCHORNGES      BIT(1) GLOBAL; /* 1: irgendein Schornsteinfegertest */
  SPC Z_GFCONTR        FIXED  GLOBAL; /* Kontrollzaehler fuer Grundfos-Task */
  SPC Z_GFCONTR2       FIXED  GLOBAL; /* Kontrollzaehler fuer Grundfos-Task */
  SPC Z_GFNEUST        FIXED  GLOBAL; /* Zaehler fuer Grundfos-Task-Neustart */
  SPC Z_GFNEUST2       FIXED  GLOBAL; /* Zaehler fuer Grundfos-Task-Neustart */
  SPC Z_CAN1CONTR      FIXED  GLOBAL; /* Kontrollzaehler fuer CAN1 Empfangstask */
  SPC Z_CAN1NEUST      FIXED  GLOBAL; /* Zaehler fuer CAN1 Empfangstask-Neustart */
  SPC B_STSAMMGES       BIT(1) GLOBAL; /* Gesamtergebnis von Sammelstoerung */
  SPC Z_HZGFUELL        FIXED  GLOBAL; /* Tageslaufzeitzaehler fuer HZG-Nachspeisung */
  SPC B_HZGFUELL        BIT(1) GLOBAL; /* 1: HZG-Nachspeisung aktiv           */
  SPC Z_MBUS            FIXED  GLOBAL; /* Kontrollzaehler fuer M-Bus Task     */
  SPC Z_MBUSNEUST       FIXED  GLOBAL; /* Zaehler fuer M-Bus Neustart         */
  SPC Z_HKABS           FIXED  GLOBAL; /* Kontrollzaehler fuer HKABS          */
  SPC Z_RAUMABS         FIXED  GLOBAL; /* Kontrollzaehler fuer RAUMABS        */
  SPC Z_TASKCONTR       FIXED  GLOBAL; /* Kontrollzaehler fuer TASKCONTR      */
  SPC Z_PANELPAUS       FIXED  GLOBAL; /* Kontrollzaehler fuer Panel-PC       */
  SPC Z_PANELRESET      FIXED  GLOBAL; /* Zaehler fuer Panel-PC Reset         */
  SPC Z_MODBUS          FIXED  GLOBAL; /* Kontrollzaehler MODBUS              */
  SPC Z_MODBUSNEUST     FIXED  GLOBAL; /* Zaehler fuer MODBUS Neustart        */

  SPC TC_VSOLLEXT(  )   FLOAT  GLOBAL; /* Unterst. VL-Soll                    */
  SPC TC_VISTEXT (  )   FLOAT  GLOBAL; /* Unterst. VL-Ist                     */
  SPC TC_VIST2          FLOAT  GLOBAL; /* 2. Hauptkreis-Temp.                 */
  SPC Z_BWFREIEXT(  )   FIXED  GLOBAL; /* Unterst. bitte WW-Laden             */
  SPC Z_BWSPAREXT(  )   FIXED  GLOBAL; /* Unterst. bitte WW-Ladung sparen     */
  SPC Z_BWMOGLEXT(  )   FIXED  GLOBAL; /* Unterst. bitte WW-Laden             */
  SPC ZT_LASTCAN(  ) FIXED(31) GLOBAL; /* letzte CAN-Meldung Teilnehmer () 1/10s Jahr */
  SPC X_AEINEXT(  ,  )  FLOAT  GLOBAL; /* Uebertragene Daten von UST          */
  SPC FL_AIVIERTEXT(  ,  ,  ) FLOAT GLOBAL; /* 1/4h Integrator Uebertr. Daten    */
  SPC Z_UCAN(  )        FIXED  GLOBAL; /* Kontrollzaehler UST                 */
  SPC Z_FREECOUNT(  )   FIXED  GLOBAL; /* Zaehler fuer sonstiges              */
  SPC Z_IND             FIXED  GLOBAL; /* freie Verwendung                    */
  SPC Z_CWSJOY          FIXED  GLOBAL; /* Zaehler JOYSTICK haengt             */
  SPC Z_H0COPY          FIXED  GLOBAL; /* Zaehler Sich BATRAM1 heute          */
  SPC FL_EINSPPRO       FLOAT  GLOBAL; /* akt. Jahr Einspeisung der Stromerzeugung (%) 0-1 */
  
  /*-----------------------------------------------------------------*/
  /* Bedien-Variable  <<<          */
  SPC ME_TEX  (   ) CHAR(30) GLOBAL;/* Text des Menuepunkts            */
  SPC ME_POST (   ,  ) FIXED GLOBAL;/* Zeiger auf Folge-Elemente      */
  SPC ME_PRAE (   )   FIXED GLOBAL; /* Zeiger auf Vorgaenger-Element   */
  SPC ME_POSTMAX INV FIXED GLOBAL         ;/* maximal 15 Folge-Elem. */
  SPC ME_ZALT (   )  FIXED  GLOBAL; /* letzte Zeigerposition des Menus*/
  SPC ME_EBENE(   )  FIXED  GLOBAL; /* Menuebene                      */
  SPC ME_PUNKT(   )  FIXED  GLOBAL; /* Menu fuer TON                  */
  SPC ME_ZEIG (   )  FIXED  GLOBAL; /* Menu fuer TON                  */
  SPC ME_AKTION(   ) FIXED  GLOBAL; /* Menu fuer TON                  */
  SPC ME_PUHILF      FIXED  GLOBAL; /* Menu fuer TON                  */
  SPC ME_ZEIGHILF    FIXED  GLOBAL; /* Menu fuer TON                  */
  SPC ME_ZHILF2(   ) FIXED  GLOBAL; /* Menu fuer TON                  */
  SPC ME_ZWAHL      FIXED  GLOBAL; /* Zeiger auf Auswahlleiste       */
  SPC ME_INDEX      FIXED  GLOBAL; /* Zeiger fuer Menueinitialisierung */
  SPC ME_ZAEHL      FIXED  GLOBAL; /* Zaehler fuer Sohnelemente (init) */
  SPC ME_EXIT   BIT(1)     GLOBAL; /* Testvariable Schleifenausgang  */
  SPC B_MENU    BIT(1)     GLOBAL; /* 1: Menumodus 0: Anzeigemodus   */
  SPC B_MENUNEU BIT(1)     GLOBAL; /* 1: Menue neu aufbauen           */
  SPC B_KEY     BIT(1)     GLOBAL; /* gueltige Taste betaetigt        */
  SPC B_WEITER  BIT(1)     GLOBAL; /* bei CALL EINGABE keine Taste   */
  SPC B_NEUSEITE BIT(1)    GLOBAL; /* neue Seite wurde angewaehlt     */
  SPC Z_WAIT    FIXED      GLOBAL; /* Wartezeit keine Taste betaetigt*/
  SPC Z_SEITE   FIXED      GLOBAL; /* Seite die angezeigt werden soll*/
  SPC Z_USEITE  FIXED      GLOBAL; /* Unterseite fuer Anzeige         */
  SPC Z_USEITE2 FIXED      GLOBAL; /* Unterseite fuer Anzeige         */
  SPC Z_ZEILE   FIXED      GLOBAL; /* Hilfszeiger fuer DISPLAY Zeile  */
  SPC Z_BLINK   FIXED     GLOBAL;  /* Zaehler fuer Darstellung         */
  SPC B_BLINK   BIT(1)    GLOBAL;  /* Bit fuer blinkende Darstellung  */
  SPC PUNKT          FIXED GLOBAL; /* Zeiger auf aktuellen Menuepunkt */
  SPC ZEIG           FIXED GLOBAL; /* Menue: vertikale Zeigerposition */
  SPC WAHL           FIXED GLOBAL; /* Ausgewaehlter Menuepunkt         */
  SPC WAHLMAX        FIXED GLOBAL; /* Hilfszeiger fuer Auswahl        */
  SPC TX_LEER   CHAR(80)   GLOBAL; /* Zum Zeilen loeschen            */
  SPC TX_TAG( ) CHAR(2)    GLOBAL; /* Mo bis So                      */
  SPC TX_STAT   CHAR(4)    GLOBAL; /* Zustand der Waermeerzeuger      */
  SPC TX_HZKR   CHAR(1)    GLOBAL; /* Zustand des Heizkreises        */
  SPC X_GEHEIM  FIXED      GLOBAL; /* Geheimnummer fuer verschiedenes */
  SPC X_GEHEIMINT  FIXED   GLOBAL; /* Geheimzahl intern              */
  SPC X_GEHEIMEXT  FIXED   GLOBAL; /* Geheimzahl extern (von Master) */
  SPC X_ZUGANG     FIXED   GLOBAL; /* Zugangsberechigung fuer Parameterveraenderungen */
  SPC X_ZUGANGKAL  FIXED   GLOBAL; /* Zugangsberechigung fuer Absenkungskalender      */
  SPC X_R       FIXED      GLOBAL; /* Richtung des Steuerknueppels   */
  SPC K_O INV FIXED GLOBAL        ; /* Wert fuer Taste oben        */
  SPC K_U INV FIXED GLOBAL        ; /* Wert fuer Taste unten       */
  SPC K_L INV FIXED GLOBAL        ; /* Wert fuer Taste links       */
  SPC K_R INV FIXED GLOBAL        ; /* Wert fuer Taste rechts      */
  SPC K_E INV FIXED GLOBAL        ; /* Wert fuer Eingabetaste        */
  SPC B_FUEHL       BIT(1) GLOBAL; /* Mittelwertbildung in AIN EIN/AUS*/
  SPC B_FERN        BIT(1) GLOBAL; /* 1: Fernbedienung EIN           */
  SPC Z_FERN        FIXED  GLOBAL; /* BHKWnr das Fernbedient wird    */
  SPC IND           FIXED  GLOBAL; /* Hilfsvariable Bedienung        */
  SPC CHB(   )   CHAR(30)  GLOBAL; /* Hilfsvariable Bedienung        */
  SPC BUTT       CHAR( 1)  GLOBAL; /* Hilfsvariable fuer Button      */
  SPC B_EINOBJ   BIT(1)    GLOBAL; /* Hilfsvariable fuer Button      */
  SPC B_NOTAUSWAHL BIT(1)  GLOBAL; /* Hilfsvariable fuer Button      */

  /* Variablen fuer Communikation mit BHKW ueber CAN-Bus */
  SPC ID_BBEIN( )      FIXED GLOBAL;
  SPC ID_PEBSOLL( )    FIXED GLOBAL;
  SPC ID_BBPNL( )      FIXED GLOBAL;
  SPC ID_BUHRDAT( )    FIXED GLOBAL;

  /*-----------------------------------------------------------------*/
  /* MPC-Modulvariable <<< */
  SPC X_F          FIXED  GLOBAL; /* variable Tastaturwiederholrate  */
  SPC TX_REV     CHAR(80) GLOBAL; /* LCD-Attribut reverse            */
  SPC TX_SET     CHAR(51) GLOBAL; /*'CLOCKSET 12:34:56--DATESET 18-02*/
  SPC TX_DATUM   CHAR(10) GLOBAL; /* fuer RTC_TIME                    */
  SPC Z_WATCH       FIXED GLOBAL; /* Zaehlvariable fuer Watchdog       */
  SPC Z_DIN         FIXED GLOBAL; /* Kontrollvar. fuer DIN            */
  SPC Z_BHKWSEND    FIXED GLOBAL; /* Kontrollvar. fuer BHKWSEND       */
  SPC Z_CANIO       FIXED GLOBAL; /* Kontrollvar. fuer CANIOPLAT      */
  SPC Z_BHKWGET     FIXED GLOBAL; /* Kontrollvar. fuer BHKWGET        */
  SPC Z_WATCHDOG FIXED(31) GLOBAL; /* Kontrollvar. fuer Watchdog      */
  SPC STRING      CHAR(1) GLOBAL; /* Variable fuer Joystickeingabe    */
  SPC CHAR40     CHAR(40) GLOBAL; /* Variable fuer Joystickeingabe    */
  SPC X_MERK       FIXED GLOBAL; /* Hilfsv. f. Loeschen der Invers-  */
  SPC Y_MERK       FIXED GLOBAL; /* Darstellung bei Fernbedienung    */
  SPC Z_WATCHEXT   FIXED GLOBAL; /* Zaehlvariable fuer ext. Watchdog   */
  SPC Z_LASTCANERR FIXED(31) GLOBAL; /* Merker in s Steuerungslfz. letzter CAN-Fehler */
  SPC Z_FERNGESENDET FIXED  GLOBAL; /* aktuelle Fernbediennr. auf CAN-Bus */
  SPC Z_FERNEND   FIXED     GLOBAL; /* Fernbedienungsendemeldung von CAN-Bus */
  SPC Z_CANUPD    FIXED     GLOBAL; /* Zaehler fuer Updateanforderung von CAN-Bus */
  SPC YOMIN       FIXED     GLOBAL; /* Merker fuer Display invers  */
  SPC YUMAX       FIXED     GLOBAL; /* Merker fuer Display invers  */
  SPC XLMIN       FIXED     GLOBAL; /* Merker fuer Display invers  */
  SPC XRMAX       FIXED     GLOBAL; /* Merker fuer Display invers  */
  SPC VREFH( )    FIXED(15) GLOBAL; /* Referenzspannung high in Bit     */ 
  SPC VREFL( )    FIXED(15) GLOBAL; /* Referenzspannung low in Bit      */   
  SPC VREFM( )    FIXED(15) GLOBAL; /* Referenzspannung Mitte in Bit    */   
  SPC B_CANREADAKT BIT(1)   GLOBAL; /* 1: CANREAD soll aufs Display schreiben */
  SPC B_TASTATUR   BIT(1)   GLOBAL; /* 1: Eingabe ueber Tastatur bei Fernbedienung */
  SPC B_CANAUS     BIT(1)   GLOBAL; /* 1: Abschaltung 24V CAN-Platinen    */
  SPC Z_RTC        FIXED    GLOBAL; /* >0 Uhrz. wird gestellt, CAN-SEND unterbrechen */
  SPC Z_RTC2       FIXED    GLOBAL; /* Merker fuer woechentliche Zeitkorr. */

  SPC SCHL_STA(  )  CHAR(1)   GLOBAL;  /* Variblen fuer Schleichupdate UST */
  SPC SCHL_BYTE(  ) FIXED(31) GLOBAL;  /*   "                              */
  SPC SCHL_CRC (  ) FIXED(31) GLOBAL;  /*   "                              */
  SPC SCHL_DOPP(  ) FIXED(31) GLOBAL;  /*   "                              */
  SPC SCHL_ERR (  ) FIXED(31) GLOBAL;  /*   "                              */
  SPC SCHL_ANZEMPF  FIXED     GLOBAL;  /*   "                              */
  SPC SCHL_DOPPM    FIXED(31) GLOBAL;  /*   "                              */
  SPC SCHL_BYTEM    FIXED(31) GLOBAL;  /*   "                              */
  SPC SCHL_CRCM     FIXED(31) GLOBAL;  /*   "                              */
  
  SPC Z_SERVAKT     FIXED     GLOBAL;  /* Zaehler Empfangsbytes von Server */
  SPC D_SERVDAT(  ) FIXED     GLOBAL;  /* Zwischenspeicher Empfangsbytes   */
  SPC B_VISSERV     BIT(1)    GLOBAL;  /* 1: Ausgabe VIS-Daten an Server (ser1) */ 
  SPC B_VISLCD      BIT(1)    GLOBAL;  /* 1: Ausgabe VIS-Daten waehrend Fernbedienung */ 
  SPC B_VISPANEL    BIT(1)    GLOBAL;  /* 1: Ausgabe VIS-Daten an Panel (ser2) */ 
  SPC Z_SERVPAUS    FIXED     GLOBAL;  /* Zaehler wie lange nicht angesprochen */
  
  /* Variablen fuer Idletest mittels Endlosschleife                   */
  SPC B_IDLE    BIT(1) GLOBAL;     /* 1: Idletest eingeschaltet      */
  SPC IT_REST   FLOAT GLOBAL;      /* Freie Rechenzeit in Prozent    */
  SPC IT_COUNT1 FIXED(31) GLOBAL;  /* Zaehlvariable fuer Endlosschleife*/
  SPC IT_COUNT2 FIXED(31) GLOBAL;  /* Zaehlvariable fuer Endlosschleife*/
  SPC IT_COUNT3 FIXED(31) GLOBAL;  /* Zaehlvariable fuer Endlosschleife*/

  /* Variablen fuer die Protokollfunktion                             */
  SPC FL_PROTINT(  ) FLOAT GLOBAL; /* Prot.: Integrator Messtelle     */
  SPC Z_PROTART(  ) FIXED GLOBAL;  /* Prot.: Art 1:AI 2:AO 3:DI 4:DO  */
  SPC Z_PROTNUM(  ) FIXED GLOBAL;  /* Prot.: Ein- Ausgangsnummer      */
  SPC ZF_PROTTAKT  FIXED GLOBAL;  /* Prot.: TaktzÑhlgr. fÅr Zyklisch */
  SPC Z_PROTTAKT   FIXED GLOBAL;  /* Prot.: TaktzÑhler fÅr Zyklisch  */
  SPC Z_PROTWART   FIXED(31) GLOBAL;/* Prot.: Wartezeit bis Start (s)*/
  SPC Z_PROTFUELL  FIXED(31) GLOBAL;/* Prot.: Dateigroesse             */
  SPC B_PROTVOLL   BIT(1) GLOBAL; /* Prot.: 1:Datei voll             */
  SPC B_PROTSPERR  BIT(1) GLOBAL; /* Prot.: 1:Aufzeichnung gesperrt  */
  SPC B_PROTMERK   BIT(1) GLOBAL; /* Prot.: Merker fÅr Zustandsgest. */

  
  /*-----------------------------------------------------------------*/
  /* SONDER-Modulvariablen <<<    */
  SPC N_ZAEHLER      FIXED GLOBAL;     /* Anzahl der Zaehleingaenge    */
  SPC ZP_NAME(   )   CHAR(27) GLOBAL;  /* Zaehlernamen                */
  SPC ZP_EIN(   )    FIXED GLOBAL;     /* Softwarekanaln. des Zaehlers*/
  SPC ZP_TYP(   )    FIXED GLOBAL;     /* Art des Zaehlers            */
  SPC B_DUE2         BIT(1)    GLOBAL; /* 1/4h Uebertragung laeuft DUE3,4,32 */
  SPC DATANZ INV FIXED GLOBAL          ; /* Groesse Datenfeld in Daten  */
  SPC STATJAHR2      FIXED     GLOBAL;  /* Jahreszahl fuer Datenverarbeitung */
  SPC STATMON2       FIXED     GLOBAL;  /* Monatszahl fuer Datenverarbeitung */
  SPC STATDAT2       FIXED     GLOBAL;  /* Datumzahl fuer Datenverarbeitung */
  SPC STATWOTA2      FIXED     GLOBAL;  /* Wochentag fuer Datenverarbeitung */
  SPC MAXDAT         FIXED     GLOBAL;  /* Anzahl genutzter 1/4h-Daten     */
  SPC DATFAKT(   )   FIXED     GLOBAL;  /* Speicherfaktor der 1/4h-Daten 1,10,100 */
  SPC VIERT_NAME(   ) CHAR(20)  GLOBAL;  /* Name des Viertelstundenkanals */
  SPC VIERT_EINH(   ) CHAR(5)   GLOBAL;  /* Einheit des Viertelstundenkanals */
  SPC Z_GRAPHTAG     FIXED     GLOBAL;  /* Merker fuer Tagesnr graphische Darstellung */
  SPC Z_GRAPHART     FIXED     GLOBAL;  /* Merker fuer Kanal graphische Darstellung */
  SPC TAGDAT(  )     FIXED     GLOBAL;  /* Zwischenspeicher fuer Tagesdaten */
  SPC MON_NAME(  )   CHAR(25)  GLOBAL;  /* Name des Monatskanals         */
  SPC MON_EINH(  )   CHAR(5)   GLOBAL;  /* Einheit des Monatskanals      */
  SPC N_MONZAEHL     FIXED     GLOBAL;  /* Anzahl Monatsz‰hler           */
  
  /*-----------------------------------------------------------------*/
  /* MBUS-Modulvariable <<< */
  SPC ZT_MBUS(  )    FIXED(31) GLOBAL;  /* Jahreszentelsek.stand M-Bus Meldung */
  SPC WTH_MBUS(  )   FLOAT     GLOBAL;  /* WMZ M-Bus                     */
  SPC PTH_MBUS(  )   FLOAT     GLOBAL;  /* Pthermisch M-Bus              */
  SPC WQM_MBUS(  )   FLOAT     GLOBAL;  /* Volumenzaehler M-Bus           */
  SPC DF_MBUS(  )    FLOAT     GLOBAL;  /* Durchfl.   M-Bus              */
  SPC TCV_MBUS(  )   FLOAT     GLOBAL;  /* Vorlauftemp. M-Bus            */
  SPC TCR_MBUS(  )   FLOAT     GLOBAL;  /* Ruecklauftemp. M-Bus           */
  SPC WTH_MBUSMERK(  ) FLOAT   GLOBAL;  /* WMZ M-Bus Merker              */
  SPC FL_MBUSVIERT(  ,  ) FLOAT   GLOBAL;  /* Zwischenspeicher fuer 1/4h Daten */
  SPC Z_MBUSLES      FIXED     GLOBAL;  /* Zaehler Auslesung             */
  SPC B_MBUSLES      BIT(1)    GLOBAL;  /* 1: Auslesung angefordert      */

  /*-----------------------------------------------------------------*/
  /* GRUNDFOS-Modulvariable <<< */
  SPC UPE_FRAG(  )      CHAR(40) GLOBAL;   /* Fragetexte an Pumpen       */
  SPC UPE_ANTW(  )      CHAR(40) GLOBAL;   /* Antworttexte von Pumpen    */
  SPC Z_UPEOK(  )       FIXED GLOBAL;      /* Zaehler Comm OK            */
  SPC Z_UPEERR(  )      FIXED GLOBAL;      /* Zaehler Comm ERR           */
  SPC Z_UPESTAT(  )     FIXED GLOBAL;      /* Status Ser Antwort         */
  SPC Z_UPEANZ(  )      FIXED GLOBAL;      /* Laenge Ser Antwort         */
  
  /*-----------------------------------------------------------------*/
  /* FLAMCO-Modulvariable <<< */
  SPC ZT_FLAMCO      FIXED(31) GLOBAL;  /* Jahreszentelsek.stand Meldung */
  SPC FLAM_DRU       FLOAT     GLOBAL;  /* ANLAGENDRUCK                  */
  SPC Z_FLAMCO       FIXED     GLOBAL; /* Kontrollzaehler fuer FLAMCO Task */
  SPC Z_FLAMCONEUST  FIXED     GLOBAL; /* Zaehler fuer FLAMCO Neustart   */
  SPC B_FLAMCONEUST  BIT(1)    GLOBAL; /* Merker fuer FLAMCO Neustart  */
  
  /*-----------------------------------------------------------------*/
  /* PARAM-Modulvariable <<< */
  SPC B_RAMSPERR  BIT(1) GLOBAL; /* 1: Datensicherung auf R0. gesperrt */
  SPC Z_RAMPAR    FIXED  GLOBAL; /* RAMSCHREIB  Zaehler zur          */ 
  SPC Z_RAMDUE2   FIXED  GLOBAL; /* DUE3,4,32   Koordination         */ 
  SPC Z_RAMSTAT   FIXED  GLOBAL; /* STATISTIK   der Zugriffe         */ 
  SPC Z_RAMSTOER  FIXED  GLOBAL; /* MONSTOER    auf Compact Flash    */ 
  SPC Z_RAMSON    FIXED  GLOBAL; /* andere                           */ 
  SPC B_FLASHMERK BIT(1) GLOBAL; /* Merker fuer Tagesparametersicherung */
  SPC B_FLASHVORH BIT(1) GLOBAL; /* 1: Flashdisk ist vorhanden       */
  /*******************************************************************/
  /* im folgenden sind alle Variablen deklariert die auf der         */
  /* RAM-Disk R0 und auf /H0/BATRAM1 gespeichert werden              */
  /*******************************************************************/

  /* diverse Variablen                                               */
  SPC BI_PARA      BIT(32)  GLOBAL; /* Magic Word                    */
  SPC Z_BETRIEB    FIXED    GLOBAL; /* Betriebsart der Anlage        */
  SPC B_ROTSP      BIT(1)   GLOBAL; /* 1: rote Taste gesperrt        */
  SPC B_WINTER     BIT(1)   GLOBAL; /* 1: Umsch. auf Winterz. erfolgt*/
  SPC ZF_TMESS     FIXED    GLOBAL; /* Steigungsmessintervall        */
  SPC TD_BO        FLOAT    GLOBAL; /* obere BHKW-Abweichung Vorl.so */
  SPC TD_BU        FLOAT    GLOBAL; /* untere BHKW-Abw. Vorlaufsoll  */
  SPC TD_KS        FLOAT    GLOBAL; /* untere Kessel-Abw. Vorlaufso. */
  SPC TC_MAXMIN    FLOAT    GLOBAL; /* Minimale Maximaltemp. (z.B: WW ueberladen) */
  SPC PE_RMIN1B    FLOAT    GLOBAL; /* Minimal beachteter Strombedarf */
  SPC ZF_TAUS      FIXED    GLOBAL; /* Ausschaltzeit BHKW            */
  SPC ZF_T1EIN     FIXED    GLOBAL; /* Einschaltverz. BHKW1 in Min   */
  SPC TD_1EIN      FLOAT    GLOBAL; /* Einschalttempdifferenz BHKW1  */
  SPC Z_KALSEC     FIXED    GLOBAL; /* Zeitkorrektur in SEC pro Woche*/
  SPC Z_RESET      FIXED(31) GLOBAL; /* Resetzaehler                   */
  SPC ZP_SCHANF    CLOCK    GLOBAL; /* Beginn PT_SCHNITT-Berechnung  */
  SPC ZP_SCHEND    CLOCK    GLOBAL; /* Ende PT_SCHNITT-Berechnung    */
  SPC ZP_PUMPSCH   CLOCK    GLOBAL; /* Zeitpunkt Pumpenschonung      */
  SPC PT_SCHNITT   FLOAT    GLOBAL; /* durchschnittl. therm. Leist.  */
  SPC Z_ZAEHL(   ) FIXED(31) GLOBAL; /* Zaehler fuer Digitale Eingaenge  */
  SPC FL_IMP(   )     FLOAT  GLOBAL; /* Zaehlerkonst. fÅr Impulszaehler */
  SPC Z_STRMAX(  )    FIXED GLOBAL; /* Viertelstunde Maxbezug        */
  SPC DA_STRMAX(  )   FIXED GLOBAL; /* Datum         Maxbezug        */
  SPC PE_STRMAX(  )   FLOAT GLOBAL; /* Wert          Maxbezug        */
  SPC FL_GASSTOER     FLOAT GLOBAL; /* Stoerschwelle Gassensor       */
  SPC FL_GASWARN      FLOAT GLOBAL; /* Warnschwelle Gassensor        */
  SPC FL_DRWARN       FLOAT GLOBAL; /* Minschwelle HZG-Drucksens     */
  SPC FL_DRMAX        FLOAT GLOBAL; /* Maxschwelle HZG-Drucksens     */
  SPC Z_SYSOUT    FIXED     GLOBAL; /* Ausgabekanal Systemmeldungen  */
  SPC FL_GASHU       FLOAT  GLOBAL; /* unterer Heizwert des Gases    */
  SPC FL_GASHO       FLOAT  GLOBAL; /* oberer Heizwert des Gases     */
  SPC TD_UEBERHEIZ   FLOAT  GLOBAL; /* Ueberheizung Hauptkreis       */
  SPC W_ERZHT     FLOAT(55) GLOBAL;/* Stromerzeugung HT              */
  SPC W_ERZNT     FLOAT(55) GLOBAL;/* Stromerzeugung NT              */
  SPC W_BEDHT     FLOAT(55) GLOBAL;/* Strombedarf    HT              */
  SPC W_BEDNT     FLOAT(55) GLOBAL;/* Strombedarf    NT              */
  SPC W_EINHT     FLOAT(55) GLOBAL;/* Stromeinspeis. HT              */
  SPC W_EINNT     FLOAT(55) GLOBAL;/* Stromeinspeis. NT              */
  SPC W_BEZHT     FLOAT(55) GLOBAL;/* Strombezug     HT              */
  SPC W_BEZNT     FLOAT(55) GLOBAL;/* Strombezug     NT              */
  SPC W_55(  )    FLOAT(55) GLOBAL;/* freie Zaehler                  */
  SPC TX_STOER(  )  CHAR(20) GLOBAL;/* Stoerungstexte                */
  SPC ZT_STOER(  ) FIXED(31) GLOBAL;/* Stoerungsdatum + Uhrzeit      */
  SPC ART_STOER(  ) FIXED    GLOBAL;/* Stoerungsarten                */

  /* Analogeingangsvariablen                                         */
  SPC FP_ULOW (   ) FIXED    GLOBAL; /* Analogein in mV fuer unt. Wert */
  SPC FP_UHIGH(   ) FIXED    GLOBAL; /* Analogein in mV fuer ob.  Wert */
  SPC FP_NULL (   ) FIXED    GLOBAL; /* Bitanzahl bei unt. Wert       */
  SPC FP_STEIG(   ) FLOAT    GLOBAL; /* Steigung in Einheit pro Bit   */
  SPC B_FUEHLWACH(   ) BIT(1) GLOBAL; /* 1: Fuehlerueberwachung freigegeben */
  SPC FL_XAEINMAX(   ) FLOAT GLOBAL; /* Maximalwert fuer Fuehlerueberwachung */
  SPC FL_XAEINMIN(   ) FLOAT GLOBAL; /* Minimalwert fuer Fuehlerueberwachung */

  /* Heizkreisvariablen                                              */
  SPC TD_ABSHK(  ) FLOAT    GLOBAL; /* Heizkreisabsenktemperatur     */
  SPC RP_M    (  ) FLOAT    GLOBAL; /* Mischerregelung       P       */
  SPC RI_M    (  ) FLOAT    GLOBAL; /*                       I       */
  SPC RD_M    (  ) FLOAT    GLOBAL; /*   >32: Missbrauch     D       */
  SPC RDI_M   (  ) FLOAT    GLOBAL; /*        fuer andere    DI      */
  SPC RTAU_M  (  ) FLOAT    GLOBAL; /*        Regler     TAU D       */
  SPC ZUST_HK (  ) FIXED    GLOBAL; /* Heizkreisbetriebszustand      */
  SPC P_HKMIN (  ) FLOAT    GLOBAL; /* Pumpenmindestdruck            */
  SPC TC_HMT  (  ) FLOAT    GLOBAL; /* Heizkreistagheizgrenzen       */
  SPC TC_HMN  (  ) FLOAT    GLOBAL; /* Heizkreisnachtheizgrenzen     */
  SPC FL_EXPHK (  ) FLOAT   GLOBAL; /* Heizkoerperexponent           */
  SPC TD_HKSPREI(  ) FLOAT  GLOBAL; /* Heizkreisistspreizung         */
  SPC TC_HKINENN(  ) FLOAT  GLOBAL; /* Heizkreisnennraumtemperatur   */
  SPC TC_HKVMIN(  )  FLOAT  GLOBAL; /* Heizkreismindestvorlauftemp.  */
  SPC TC_HKVNENN(  ) FLOAT  GLOBAL; /* Heizkreisnennvorlauftemp.     */
  SPC TC_HKANENN(  ) FLOAT  GLOBAL; /* Heizkr.Ausslegungsaussentemp. */
  SPC W_HKTH    (  ) FLOAT(55)  GLOBAL; /* thermische Arbeit HKs     */
  SPC TC_HKSTW (  )   FLOAT  GLOBAL; /* Heizkr. VL TH STW            */
  SPC ZF_HKMISTELL(  )FIXED  GLOBAL; /* Mischerstellzeit (s)         */
  SPC HK_NAME  (  ) CHAR(20)GLOBAL;/* Name des Heizkreises           */
  SPC FL_SOLLATM10(  )  FLOAT  GLOBAL; /* HK-Pumpensollst. bei -10 Grad */
  SPC FL_SOLLAT5(  )    FLOAT  GLOBAL; /* HK-Pumpensollst. bei   5 Grad */
  SPC FL_SOLLAT20(  )   FLOAT  GLOBAL; /* HK-Pumpensollst. bei  20 Grad */
  SPC TC_TAGSOLL(  )    FLOAT  GLOBAL; /* Sollraumtemp. Tag (HK)        */
  SPC TC_BEREITSOLL(  ) FLOAT  GLOBAL; /* Sollraumtemp. bereit (HK)     */
  SPC TC_NACHTSOLL(  )  FLOAT  GLOBAL; /* Sollraumtemp. Nacht (HK)      */
  SPC TD_HKINTMAX(  ) FLOAT  GLOBAL; /* langfrist. Integr. MAX          */
  SPC TD_HKINTMIN(  ) FLOAT  GLOBAL; /* langfrist. Integr. MIN          */
  SPC F_ESTRICH(  ,  )   FLOAT  GLOBAL; /* Verschiedene Pamam: Estrichtrocknung  */
  SPC FL_ATTAU        FLOAT  GLOBAL; /* Tau Glaettung At fuer AT Schnitt (h)  */
  SPC TC_ATTAU        FLOAT  GLOBAL; /* Geglaettete AT               */
  SPC ZF_HKPEXT(  )   FIXED  GLOBAL; /* ext. Eingriff HK-Pumpe        */
  SPC ZF_HKMIEXT(  )  FIXED  GLOBAL; /* ext. Eingriff HK-Mischer      */
  SPC FL_HKEXT(  )    FLOAT  GLOBAL; /* frei (ext. Eingriff)          */

  /* BHKW-Variablen                                                  */
  SPC FS_LBHKW ( )  FIXED   GLOBAL; /* BHKW-Ranfolge                 */
  SPC Z_START  ( )  FIXED(31) GLOBAL; /* BHKW-Startzaehler              */
  SPC XA_BPMP  ( )  FLOAT   GLOBAL; /* Pumpenleistung fuer Spreizung  */
  SPC PE_MAXBHKW( ) FLOAT   GLOBAL; /* Pel Max BHKW                  */
  SPC PE_MINBHKW( ) FLOAT   GLOBAL; /* Pel Min BHKW                  */
  SPC PE_BMINPRO( ) FLOAT   GLOBAL; /* Pel Min erlaubt in % (wg eta) */
  SPC TC_BVLMIN ( ) FLOAT   GLOBAL; /* BHKW Mindestvorlauftemp       */
  SPC TC_BHZGVO ( ) FLOAT   GLOBAL; /* BHKW Vorlaufthermostat        */
  SPC TC_BHZGRO ( ) FLOAT   GLOBAL; /* BHKW Ruecklaufthermostat      */
  SPC B_BERLAUBT( ) BIT(1)  GLOBAL; /* 1: BHKW freigegeben           */
  SPC ZF_BPNL( )    FIXED   GLOBAL; /* Pumpennachlaufzeit BHKW (s)   */
  SPC Z_BLAUFZ(  ,  ) FIXED(31) GLOBAL;/*  Laufzeitmerker     BHKW     */
  SPC ZP_BAUS(  ,  )  CLOCK   GLOBAL; /*  Abschaltzeitmerker  BHKW     */
  SPC DAT_BAUS(  ,  ) FIXED   GLOBAL; /*  Abschaltdatummerker BHKW     */
  SPC FL_BLFZGESHZG(  ) FLOAT(55) GLOBAL; /* BHKW-Gesamtlfz Heizungsst. (h) */
  SPC FL_BKWHGESHZG(  ) FLOAT(55) GLOBAL; /* BHKW-Gesamterzeugung in kWh (HZG) */
  SPC TC_BRMIN      FLOAT   GLOBAL; /* BHKW-Mindestruecklauftemp.     */
  SPC TD_BHZGSOLL   FLOAT   GLOBAL; /* BHKW-HZG-Sollspreizung        */
  SPC STR_AUS(  ,  )    CHAR(16) GLOBAL; /* Abschaltgrundmerker BHKW    */
  SPC FL_BLFZWART( )    FLOAT(55) GLOBAL; /* BHKW-Wartungs-Laufzeit     (h) */
  SPC FL_BLFZWARTINT( ) FLOAT(55) GLOBAL; /* BHKW-Wartungsintervall     (h) */
  SPC B_FSLBHKWAUTO     BIT(1)    GLOBAL; /* 1: autom. Sortierung BHKWs     */
  SPC ZF_STARTMAX       FIXED     GLOBAL; /* Warn. bei Starts > (in 24h)   */
  SPC ZF_BEINEXT(  ) FIXED  GLOBAL; /* frei (ext. Eingriff)          */

  /* Kesselvariablen                                                 */
  SPC FS_LKES  (  )  FIXED   GLOBAL; /* Kesselrangfolge               */
  SPC RP_K     (  )  FLOAT   GLOBAL; /* Kesselleistungsregelung  P    */
  SPC RI_K     (  )  FLOAT   GLOBAL; /*                          I    */
  SPC RD_K     (  )  FLOAT   GLOBAL; /*                          D    */
  SPC RDI_K    (  )  FLOAT   GLOBAL; /*                         DI    */
  SPC RTAU_K   (  )  FLOAT   GLOBAL; /*                      TAU D    */
  SPC RP_KP    (  )  FLOAT   GLOBAL; /* KesselPumpenregelung     P    */
  SPC RI_KP    (  )  FLOAT   GLOBAL; /*                          I    */
  SPC RD_KP    (  )  FLOAT   GLOBAL; /*                          D    */
  SPC RDI_KP   (  )  FLOAT   GLOBAL; /*                         DI    */
  SPC RTAU_KP  (  )  FLOAT   GLOBAL; /*                      TAU D    */
  SPC FL_KWART (  )  FLOAT   GLOBAL; /* Kesselstoerungsverz. in MIN    */
  SPC TD_KMIN  (  )  FLOAT   GLOBAL; /* Kesselmindestspr. nach Verz.  */
  SPC PT_KES   (  )  FLOAT   GLOBAL; /* thermische Kesselleistungen   */
  SPC Z_KLAUFZ(  ,  ) FIXED(31) GLOBAL; /*  Laufzeitmerker   Kessel   */
  SPC ZP_KAUS(  ,  ) CLOCK   GLOBAL; /*  Abschaltzeitmerker  Kessel   */
  SPC DAT_KAUS(  ,  ) FIXED  GLOBAL; /*  Abschaltdatummerker Kessel   */
  SPC ZF_KPNL  (  )  FIXED  GLOBAL; /* Pumpennachlauf (s)            */
  SPC ZF_KWARML(  )  FIXED  GLOBAL; /* Kesselwarmlaufzeit (s)        */
  SPC ZF_KSTELL(  )  FIXED  GLOBAL; /* Kesselbrennerstellzeit (s)    */
  SPC TC_KRMIN (  )  FLOAT  GLOBAL; /* Kesselmindestruecklauftemp.   */
  SPC TC_KVMAX (  )  FLOAT  GLOBAL; /* Kessel-MAX-VL-Temp.           */
  SPC TD_KVLPLUS(  ) FLOAT  GLOBAL; /* KesselVL-Soll-Ueberhoehung    */
  SPC TD_KMAX   (  ) FLOAT  GLOBAL; /* Kessel-Max-erlaubte Spreizung */
  SPC X_AAKMIN  (  ) FLOAT  GLOBAL; /* Mindest AA bei Kesselbetrieb  */
  SPC Z_KESLFZ (  )  FIXED(31) GLOBAL; /* Kessellaufzeit in s         */
  SPC Z_KSTART (  )  FIXED(31) GLOBAL; /* Kesselstarts                */
  SPC B_KERLAUBT(  ) BIT(1)    GLOBAL; /* 1: Kessel freigegeben           */
  SPC B_FSLKESAUTO   BIT(1)    GLOBAL; /* 1: autom. Sortierung Kessel */
  SPC B_PMPVORL      BIT(1)    GLOBAL; /* 1: Pumpenvorlauf erlaubt    */
  SPC ZF_KEINEXT(  ) FIXED  GLOBAL; /* ext. Eingriff Kessel-Betrieb  */
  SPC ZF_KPMPEXT(  ) FIXED  GLOBAL; /* ext. Eingriff Kessel-Pumpe    */

  /* Brauchwasservariablen                                           */
  SPC TC_BWSOLL(  )  FLOAT   GLOBAL; /* Brauchwassersolltemperatur    */
  SPC TC_BWZRSOLL(  )FLOAT   GLOBAL; /* BW-Zirkulationsruecklaufsoll   */
  SPC TC_BOMAX (  )  FLOAT   GLOBAL; /* max. erl. obere Speichertemp. */
  SPC TD_BWNORM(  )  FLOAT   GLOBAL; /* Grenze zum normal Laden       */
  SPC TD_BWDRIG(  )  FLOAT   GLOBAL; /* Grenze zum dringen Laden      */
  SPC TD_BWB   (  )  FLOAT   GLOBAL; /* Hysterese zum Ausschalten     */
  SPC TD_BWTW  (  )  FLOAT   GLOBAL; /* Speisesolldifferenz aussen WT */
  SPC TD_BWTOO (  )  FLOAT   GLOBAL; /* Start WW-Lad wenn VL > Sp o + TD_BWTOO     */
  SPC TD_BWTOU (  )  FLOAT   GLOBAL; /* Stop WW-Lad wenn  VL < Sp o + TD_BWTOU     */
  SPC TD_BWLS  (  )  FLOAT   GLOBAL; /* VL-Soll Ueberhoehung          */
  SPC TC_BWMIN (  )  FLOAT   GLOBAL; /* Brauchwassermindesttemp.      */
  SPC TC_LEGIO (  )  FLOAT   GLOBAL; /* Sollwert bei Legionellenkill   */
  SPC RP_BWL   (  )  FLOAT   GLOBAL; /* Lade/Speise-PMP-Regelung P    */
  SPC RI_BWL   (  )  FLOAT   GLOBAL; /*                          I    */
  SPC RD_BWL   (  )  FLOAT   GLOBAL; /*                          D    */
  SPC TC_BWRSOLL(  ) FLOAT   GLOBAL; /* Lade RL Soll                  */
  SPC RP_WWZ   (  )  FLOAT   GLOBAL; /* Zirk-Pumpenregelung      P    */
  SPC RI_WWZ   (  )  FLOAT   GLOBAL; /*                          I    */
  SPC RD_WWZ   (  )  FLOAT   GLOBAL; /*                          D    */
  SPC RDI_WWZ  (  )  FLOAT   GLOBAL; /*                         DI    */
  SPC RTAU_WWZ (  )  FLOAT   GLOBAL; /*                      TAU D    */
  SPC RP_WWL   (  )  FLOAT   GLOBAL; /* Lade-Pumpenregelung      P    */
  SPC RI_WWL   (  )  FLOAT   GLOBAL; /*  (ev. auch mit Mischer)  I    */
  SPC RD_WWL   (  )  FLOAT   GLOBAL; /*                          D    */
  SPC RDI_WWL  (  )  FLOAT   GLOBAL; /*                         DI    */
  SPC RTAU_WWL (  )  FLOAT   GLOBAL; /*                      TAU D    */
  SPC ZF_LMISTELL(  )FIXED   GLOBAL; /* Lademischerstellzeit (s)      */
  SPC ZF_WWMI  (  )  FIXED   GLOBAL; /* 0: Mi nicht nutzen  1: Mi nutzen  2: Mi 2s  */

  /* Softwarehandschalter                                             */
  SPC BI_ON   (  )  BIT(16) GLOBAL; /* Bits logische Verknuepfungen   */
  SPC BI_OFF  (  )  BIT(16) GLOBAL; /* fuer Softwarehandschalter      */
  SPC Z_DOHAND(   ) FIXED   GLOBAL; /* Zaehler fuer Handb. Digitalausgang  */
  SPC Z_DIBEWERT(   ) FIXED GLOBAL; /* Bewertung Digitaleingaenge 1: normal 2: getoggelt 3: EINS 4: NULL */

  /* Variablen fuer die Analogausg{nge                                */
  SPC AP_ULOW (  )  FLOAT   GLOBAL; /* Analogspannung bei 0% Soll    */
  SPC AP_UHIGH(  )  FLOAT   GLOBAL; /* Analogspannung bei 100% Soll  */
  SPC X_AHAND (  )  FLOAT   GLOBAL; /* Analogspannung bei Handb. in% */
  SPC Z_AAUTO (  )  FIXED   GLOBAL; /* 1: Auto 2: Hand n. Wert 3: Hand + Ausg. */
  SPC X_AAUSMIN(  ) FLOAT   GLOBAL; /* Mindestwert Analogausgang()   */  
  SPC X_AAUSMAX(  ) FLOAT   GLOBAL; /* Maximalwert Analogausgang()   */  
  SPC X_PWMHAND(  ) FLOAT   GLOBAL; /* PWM Ausgang bei Handb. in%    */
  SPC Z_PWMAUTO(  ) FIXED   GLOBAL; /* 1: Auto 2: Hand n. Wert 3: Hand + Ausg. */
  SPC X_PWMMIN(  )  FLOAT   GLOBAL; /* Mindestwert PWMausgang()      */  
  SPC X_PWMMAX(  )  FLOAT   GLOBAL; /* Maximalwert PWMausgang()      */  

  /* Wochenabsenkungs- und Timerkalender und Jahreskalender          */
  SPC B_ZONE1( ,    ) BIT(16) GLOBAL; /* Bitfeld fuer 64 Wochentimer */
  SPC B_JAHRAB(  ,  ) BIT(32) GLOBAL; /* Jahreskalender              */

  /* <<< Anlagenspezifisches                                         */
  SPC IDBATRAM     CHAR(40) GLOBAL; /* Steuerungsidentifier auf      */
                                    /* Ramdisk -> muss an dieser     */
                                    /* Position stehenbleiben        */
                                    /* Spaetere Aenderungen koennen  */
                                    /* ab hier gemacht werden        */
  SPC B_UPEHAND(  )       BIT(1) GLOBAL; /* 1: UPE-Pumpe im Handbetr.   */
  SPC Z_UPEKOMMAND(  )     FIXED GLOBAL; /* Kommando UPE-Pumpe          */
  SPC Z_UPESOLLHAND(  )    FIXED GLOBAL; /* Handsollstufe UPE-Pumpe     */
  SPC UPE_PRESSSCALE(  ) FLOAT GLOBAL; /* Skalierungsfaktor Pumpendruck */
  SPC UPE_FLOWSCALE(  )  FLOAT GLOBAL; /* Skalierungsfaktor Pumpendurchfl. */
  SPC UPE_TEMPSCALE(  )  FLOAT GLOBAL; /* Skalierungsfaktor Wassertemp. */
  SPC UPE_FRQSCALE(  )   FLOAT GLOBAL; /* Skalierungsfaktor PMP-Motorfrequenz */
  SPC UPE_PDCSCALE(  )   FLOAT GLOBAL; /* Skalierungsfaktor PMP-Pel     */
  SPC UPE_FREIG(  )      FIXED GLOBAL; /* >0: Kommunikationfreig. UPE-Pumpe */
  SPC UPE_KENN(  , )     FLOAT GLOBAL; /* Feld fuer Pumpenkennlinien     */
  SPC UPE_EXT(  )        FIXED GLOBAL; /* frei (ext. Einfluss)              */
  SPC ZF_STOERDRIG(   ) FIXED  GLOBAL; /* >0: Stoerungsm. I dringend     */
  SPC ZF_STOERFREI(   ) FIXED  GLOBAL; /* 1: FREI  2: KEINE MELDUNG  3: KEINE STOERUNG */
  SPC B_STSAMMFREI(   )  BIT(1) GLOBAL; /* 1: Stoerung gehoert zu Sammelstoerung  */
  SPC MARKOW(   , )     FLOAT   GLOBAL; /* Markowmatrize (erstmal frei) */
  SPC IDSTRING2         CHAR(20) GLOBAL; /* Erkennungsstring Steuerung (erstmal frei)   */
  SPC FL_ZEITZAEHL      FLOAT   GLOBAL; /* ZÑhler fÅr wîch. Uhrzeitkorr. */  
  SPC NAMESTR(  )      CHAR(34) GLOBAL;/* Bedienername Anruferliste      */
  SPC DA_DATCALL(  )   FIXED    GLOBAL;/* Datum Anruferliste             */
  SPC DA_MONCALL(  )   FIXED    GLOBAL;/* Monat Anruferliste             */
  SPC ZP_CALL(  )      CLOCK    GLOBAL;/* Uhrzeit Anruferliste           */
  SPC ZF_WTAUP        FIXED     GLOBAL; /* Zyklus Regelung Nahwaermepmp   */
  SPC ANZ_SLAVE       FIXED     GLOBAL; /* SCHLEICHUPDATE  Anzahl Slaves */
  SPC VERZ_SLAVE      FIXED     GLOBAL; /* SCHLEICHUPDATE  Verzoegerung bei Uebertragung (ms) */
  SPC FL_HZGFUEEIN      FLOAT     GLOBAL; /* Heizungsdruck unterhalb dem Nachfuellung eingeschaltet wird */
  SPC FL_HZGFUEAUS      FLOAT     GLOBAL; /* Heizungsdruck oberhalb dem Nachfuellung ausgeschaltet wird */
  SPC ZF_HZGFUELL       FIXED     GLOBAL; /* erlaubte Tageslaufzeit fuer Wassernachfuellung in s */
  SPC MON_ZAEHL(  ,  )  FLOAT     GLOBAL; /* Monatszaehlerstaende           */
  SPC AT_MON   (  ,  )  FLOAT     GLOBAL; /* Monats Aussentemp Schnitt    */
  SPC MON_ZAEHLJAN(   ) FLOAT     GLOBAL; /* Monatszaehlerstaende alter Januar */
  SPC JAHR_ZAEHL(  , )  FLOAT     GLOBAL; /* Jahreszaehlerstaende           */
  SPC WIRT_ZAEHL( ,  )  FLOAT(55) GLOBAL; /* Zaehlerstaende Wirtschaftl. ETW */
  SPC FL_GASCENTPROKWH  FLOAT     GLOBAL; /* Gaspreis ETW                 */
  SPC Z_WAERMEBHKW      FIXED     GLOBAL; /* 1: SOFT BHKW  2: SOFTWMZ ETW */
  SPC POSWTH(  )        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  SPC POSPTH(  )        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  SPC POSWQM(  )        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  SPC POSDF(  )         FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  SPC POSTCV(  )        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  SPC POSTCR(  )        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  SPC POSFIX(  )        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  SPC ZF_MBUSLES        FIXED     GLOBAL; /* MBUS-Auslesung Zyklus(s)     */
  SPC ZF_TASTVERZ       FIXED     GLOBAL; /* Verzoegerung Tastatur(s)     */
  SPC ZF_STOERMAX24     FIXED     GLOBAL; /* max. Stoerung() in 24h       */

  SPC DUMMYP(  )      FIXED  GLOBAL; /* nicht zur Verwendung          */

