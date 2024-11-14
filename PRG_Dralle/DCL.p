/*********************************************************************/
/*                                     Ersterstellung:    13.07.22   */
/* Include Datei in der alle benîtigten Variablen fuer               */
/*             'BIOGASANLAGE DRALLE  HOHNE                           */
/* deklariert sind. ZusÑtzlich existiert noch SPC.p in der alle      */
/* Variablen spezifiziert sind.                                      */
/* DCL.p  ins Modul HAUPT                                            */
/* SPC.p  in alle anderen Module                                     */
/* Stand: 13.07.22                                                   */
/* Suchen mit "<<<"                                                  */
/*********************************************************************/

  /* HAUPT-Modulvariblen <<<  */
  /* Systemvorgaben                                                  */
  DCL NR_PRJ    INV FIXED GLOBAL INIT(2033); /* PROJEKTNUMMER        */
  DCL VERSION   INV FIXED GLOBAL INIT(01); /* Versionsnummer des PRG */
  DCL N_BHKW    INV FIXED GLOBAL INIT( 1); /* 1-8  BHKW              */
  DCL N_KESSEL  INV FIXED GLOBAL INIT( 3); /* 1-10  Kessel            */
  DCL N_HZKR    INV FIXED GLOBAL INIT( 3); /* 1-32 Heizkreise        */
  DCL N_SPEI    INV FIXED GLOBAL INIT( 0); /* 1-10 Brauchwasserspei. */
  DCL N_RELPLT  INV FIXED GLOBAL INIT( 4); /* 1-20 Relaisplatinen    */
  DCL N_SEITE   INV FIXED GLOBAL INIT( 4); /* 1-12 DISPLAY-Seiten    */
  DCL N_USEITE  INV FIXED GLOBAL INIT(36); /* 1-n  Unterseiten       */
  DCL N_DIGIN   INV FIXED GLOBAL INIT(16); /* 1 -144 Digitaleingaenge*/
  DCL ZCANPLAT  INV FIXED GLOBAL INIT( 0); /* Anz. CAN-EW-Platinen   */
  DCL CANBASE   INV FIXED GLOBAL INIT(384); /* CAN-Basisadresse      */
  DCL B_PANEL  INV BIT(1) GLOBAL INIT('0'B); /* 0: LCD  1: PANEL     */
    /* ANPASSEN DATENSTATIONEN in Mpc.p <<<<                         */

  DCL B32          BIT(32)   GLOBAL;
  DCL FLANTWORT1   FLOAT     GLOBAL;
  DCL FLANTWORT2   FLOAT     GLOBAL;
  DCL FL55ANTWORT  FLOAT(55) GLOBAL;
  DCL F31ANTWORT1  FIXED(31) GLOBAL;
  DCL F31ANTWORT2  FIXED(31) GLOBAL;
  DCL F31ANTWORT3  FIXED(31) GLOBAL;
  DCL CHANTWORT1   CHAR(20)  GLOBAL;
  DCL CHANTWORT2   CHAR(20)  GLOBAL;
  DCL CHANTWORT3   CHAR(80)  GLOBAL;
  DCL FTAST        FIXED     GLOBAL;
  DCL BZEIL        BIT(32)   GLOBAL;  /* WELCHE ZEILEN HABEN SICH GEAENDERT... ZEILE1 -> BIT(1)  */
  DCL DISPSTATUS   BIT(32)   GLOBAL;  /* 1: normales Menue ab POS(x,y) z Zeichen rot  2: Anzeigemenue rechte Displayhaelfte rot (ab POS(x>20))  3: grosses Menue(80 Spalten, 25 Zeilen) ab POS(x,y) z Zeichen rot */
  DCL XROT         FIXED     GLOBAL;  /* POS x ab der das Menue rot sein soll */
  DCL YROT         FIXED     GLOBAL;  /* POS y ab der das Menue rot sein soll */
  DCL ZROT         FIXED     GLOBAL;  /* Anzahl der roten Zeichen ab POS x,y  */
  DCL ZEIL(18)     CHAR(46)  GLOBAL;
  DCL DISPSTATUS2  BIT(32)   GLOBAL;  /* 1: normales Menue ab POS(x,y) z Zeichen rot  2: Anzeigemenue rechte Displayhaelfte rot (ab POS(x>20))  3: grosses Menue(80 Spalten, 25 Zeilen) ab POS(x,y) z Zeichen rot */
  DCL XROT2        FIXED     GLOBAL;  /* POS x ab der das Menue rot sein soll */
  DCL YROT2        FIXED     GLOBAL;  /* POS y ab der das Menue rot sein soll */
  DCL ZROT2        FIXED     GLOBAL;  /* Anzahl der roten Zeichen ab POS x,y  */
  DCL ZEIL80(25)   CHAR(80)  GLOBAL;
  DCL DISPSTATUS3  BIT(32)   GLOBAL;  /* 1: normales Menue ab POS(x,y) z Zeichen rot  2: Anzeigemenue rechte Displayhaelfte rot (ab POS(x>20))  3: grosses Menue(80 Spalten, 25 Zeilen) ab POS(x,y) z Zeichen rot */
  DCL XROT3        FIXED     GLOBAL;  /* POS x ab der das Menue rot sein soll */
  DCL YROT3        FIXED     GLOBAL;  /* POS y ab der das Menue rot sein soll */
  DCL ZROT3        FIXED     GLOBAL;  /* Anzahl der roten Zeichen ab POS x,y  */
  DCL INFOTXT      CHAR(120) GLOBAL;  /* Infotext fuer Webbrowser  */
  DCL IDPI         CHAR(50)  GLOBAL;  /* Steuerungsname fuer PI         */
  DCL IDPI2        CHAR(50)  GLOBAL;  /* ---                            */
  DCL IDPI3        CHAR(50)  GLOBAL;  /* ---                            */
  DCL IDPI4        CHAR(50)  GLOBAL;  /* ---                            */
  DCL IDPI5        CHAR(50)  GLOBAL;  /* ---                            */
  DCL ZEILVIS(20)  CHAR(60)  GLOBAL;  /* Textfeld fuer ext. Einstellungen AN Visu */
  DCL ZEILRUECK(20)CHAR(60)  GLOBAL;  /* Textfeld fuer ext. Einstellungen VON Visu */

  DCL LCDZEIL      FIXED     GLOBAL;  /* Schreibpos. Zeile( )        */
  DCL LCDSPALT     FIXED     GLOBAL;  /* Schreibpos. Spalte in Zeile */
  DCL BROT         BIT(1)    GLOBAL;  /* 1: rot schreiben aktiv      */
  DCL CHIN30       CHAR(30)  GLOBAL;  /* String fuer Tastatureingaben */
  DCL Z_CIN30      FIXED     GLOBAL;  /* Position Tastatureingaben   */
  DCL Z_BUTTON     FIXED     GLOBAL;  /* Anzahl BedienButtons        */
  DCL BUTTON(30,3) FIXED     GLOBAL;  /* BUTTON Bedienung an Pos x,y,? */
  DCL Z_BEDIEN     FIXED     GLOBAL;  /* Anzahl Bediener             */
  DCL CH_BEDIEN(5) CHAR(30)  GLOBAL;  /* Name Bediener               */
  DCL Z_BEDDAUER(5) FIXED    GLOBAL;  /* Bediendauer Bediener        */
  DCL Z_IPLICHT    FIXED     GLOBAL;  /* Zaehler ext. Lichtanforderung */
  DCL FL_ATEXT     FLOAT     GLOBAL;  /* Wert ext. AT-Vorgabe         */

  /*-----------------------------------------------------------------*/
  /* Fuehlerbezogene Daten (1 bis N_FUEHL):                           */
  DCL X_AEIN   (200) FLOAT  GLOBAL;/* Absolute Eingangswerte          */
  DCL FP_HARD  (200) FIXED  GLOBAL;/* Hardwarekanal des Analogeingangs*/
  DCL FP_TYP   (200) FIXED  GLOBAL;/* Fuehlertyp des Analogkanals      */
  DCL FP_HZKR  (200) FIXED  GLOBAL;/* Heizkreisnummer des Fuehlers     */
  DCL FP_MIT   (200) FLOAT  GLOBAL;/* Mittelwertbildung Tau in s      */
  DCL FP_NAME  (200) CHAR(20)GLOBAL;/* Name des Fuehlers               */
  DCL FP_POS(12,18) FIXED  GLOBAL;/* Anzeigeposition Seite, Zeile    */
  DCL Z_FUEHLST(200) FIXED  GLOBAL;/* Fehlerzaehler Ueberwachung AI     */
  DCL FL_AIVIERT(210,15)  FLOAT  GLOBAL; /* Viertelst. Integr. AI       */
  DCL FELD(200)      FLOAT  GLOBAL; /* Feld fuer Bitwerte Analogeingaenge */            
  
  /* Analogausgangsdaten                                             */
  DCL X_AAUS  (100) FLOAT   GLOBAL;/* Analogausgangswerte in %  >60 z.B. UPE,... */
  DCL AP_NAME  (60) CHAR(20)GLOBAL;/* Name des Analogausgangs        */
  DCL AP_HARD  (60) FIXED   GLOBAL;/* Hardwarekanal des Analogausg.  */
  DCL AP_TYP   (60) FIXED   GLOBAL;/* Art des Analogausgangs         */
  DCL X_AAUSMERK(60) FLOAT  GLOBAL;/* Merker fuer Analogausgangswerte */
  DCL PW_NAME  (20) CHAR(20)GLOBAL;/* Name des PWM Ausgangs          */
  DCL Z_PWM(20)     FIXED   GLOBAL; /* Zaehler fuer Pulsweitenmodulation */
  DCL FL_PWMPRO(20) FLOAT   GLOBAL; /* Ausgang PWM in %               */

  /* Digitalausgangsdaten                                            */
  DCL DO_NAME(160)   CHAR(22) GLOBAL;/* Name des Digitalausgangs      */
  DCL DO_HARD(160)   FIXED    GLOBAL;/* Digital-Hardwareausgangsnr    */
  DCL DO_TON (160)   FIXED    GLOBAL;/* Dauer Soft-Hand-EIN in SEC    */
  DCL DO_TOFF(160)   FIXED    GLOBAL;/* Dauer Soft-Hand-AUS in SEC    */
  DCL N_DIGOUT       FIXED    GLOBAL;/* Anzahl init. Digitalausgaenge  */
  DCL Z_DOVIERT(160) FIXED    GLOBAL;/* Viertelst. Zaehler DO        */
  DCL BI_DAUS (20)   BIT(16)  GLOBAL;/* Digitaldaten fuer Relaisplatinen */
  DCL Z_UDNSTOER(20) FIXED    GLOBAL;/* Stoerungszaehler Ausgangsbausteine */
  DCL B_DO   (160)   BIT(1)   GLOBAL;/* Zustand Relais()               */
  DCL B_DOMERK(160)  BIT(1)   GLOBAL;/* Zustand Relais()               */
  DCL B_DONEU (160)  BIT(1)   GLOBAL;/* Zustand Relais()               */

  /* Digitaleingangsdaten                                            */
  DCL DI_NAME(150) CHAR(25)  GLOBAL; /* Name des Digitaleingangs      */
  DCL Z_ZAEHLMERK(150) FIXED(31) GLOBAL;/* Merker fÅr Zaehlerstaende    */
  DCL Z_DIVIERT(150)   FIXED  GLOBAL; /* Viertelst. Zaehler DI        */
  DCL Z_IMPDIVIERT(150,15) FIXED  GLOBAL; /* 1/4h Zaehler Impulse DI      */
  DCL BI_DEIN(150)     BIT(1) GLOBAL; /* Digitaleingaenge                 */
  DCL BI_DEINMERK(150) BIT(1) GLOBAL; /* Merker fuer Digitaleingaenge   */
  DCL BI_DEINBEW(150)  BIT(1) GLOBAL; /* bewertete Digitaleingaenge   */
  DCL P_DI(150)        FLOAT  GLOBAL; /* Impulsabstaende in Leistung      */ 
  DCL FL_IMPDAU (150) FLOAT     GLOBAL;/* Impulsdauermessung         */
  DCL ZP_IMPALT (150) CLOCK     GLOBAL;/* Zeitpunkt letzter Impuls   */
  DCL Z_IMPWART (150) FIXED(31) GLOBAL;/* Warted. auf neuen Imp. (s) */
  DCL B_IMPNEU  (150) BIT(1)    GLOBAL;/* neuer Impuls Digitaleing.  */

  /* Variablen fuer die BHKW (1 bis N_BHKW)                           */
  DCL B_BEIN   ( 8) BIT(1) GLOBAL;/* BHKW EIN/AUS Signal             */
  DCL B_BBEREIT( 8) BIT(1) GLOBAL;/* 1: BHKW ist lauffÑhig           */
  DCL B_BPMP   ( 8) BIT(1) GLOBAL;/* Pumpe EIN/AUS                   */
  DCL PE_BIST  ( 8) FLOAT  GLOBAL;/* Ist-Leistung des BHKW           */
  DCL PE_BSOLL ( 8) FLOAT  GLOBAL;/* Solleistung  des BHKW           */
  DCL Z_BPNL   ( 8) FIXED  GLOBAL;/* Zaehler fuer BHKW-Pumpennachl.  */
  DCL Z_SVS    ( 8) FIXED  GLOBAL;/* Zaehler fuer BHKW-Startversuch  */
  DCL B_BSTOER ( 8) BIT(1) GLOBAL;/* BHKW ist gestîrt                */
  DCL B_BL     ( 8) BIT(1) GLOBAL;/* BHKW lÑuft                      */
  DCL ZA_PEBHKW( 8) FIXED GLOBAL; /* Zeiger Anaout BHKW-Leistung     */
  DCL ZA_BHKWPMP( 8) FIXED GLOBAL;/* Zeiger Anaout BHKW-Pumpenleist. */
  DCL ZE_PB    ( 8) FIXED GLOBAL; /* Zeiger auf Anain BHKW-Leistung  */
  DCL ZE_BV    ( 8) FIXED GLOBAL; /* Zeiger auf Anain BHKW-Vorlauf   */
  DCL ZE_BR    ( 8) FIXED GLOBAL; /* Zeiger auf Anain BHKW-Ruecklauf */
  DCL Z_BLZ(20) FIXED(31) GLOBAL; /* Zaehler fuer kont. Laufzeit     */
  DCL TC_BHZGV ( 8) FLOAT GLOBAL; /* BHKW Vorlauftemperaturen        */
  DCL TC_BHZGR ( 8) FLOAT GLOBAL; /* BHKW Ruecklauftemperaturen      */
  DCL TC_BVSOLL( 8) FLOAT GLOBAL; /* BHKW VL-Soll-Temp               */
  DCL B_BHKWMIA( 8) BIT(1) GLOBAL;/* BHKW-Mischer auf                */
  DCL B_BHKWMIZ( 8) BIT(1) GLOBAL;/* BHKW-Mischer zu                 */
  DCL Z_BHKWMI ( 8) FIXED  GLOBAL; /* Softwareendkontakt fuer BHKWmi. */
  DCL FL_BLFZGES(20) FLOAT GLOBAL; /* BHKW-Gesamtlaufzeit in h       */
  DCL FL_BKWHGES(20) FLOAT GLOBAL; /* BHKW-Gesamterzeugung in kWh    */
  DCL Z_BLZVIERT(20) FIXED  GLOBAL;/* BHKW-Viertelstundenlaufzeit    */
  DCL Z_BTHERMVL( 8) FIXED  GLOBAL;/* Zaehler BHKW-Thermostat VL     */
  DCL Z_BTHERMRL( 8) FIXED  GLOBAL;/* Zaehler BHKW-Thermostat RL     */
  DCL Z_BLZMIN   FIXED(31) GLOBAL;/* kuerzeste BHKW-Laufzeit         */
  DCL PE_MAX        FLOAT  GLOBAL;/* max. Gesamtleistung fuer n BHKW  */
  DCL PE_MIN        FLOAT  GLOBAL;/* min. Gesamtleistung fuer n BHKW  */
  DCL PE_RMIN       FLOAT  GLOBAL;/* untere Regelgrenze (Gesamtleist)*/
  DCL PE_BMAXMOGL   FLOAT  GLOBAL;/* maximal moegl. el. BHKW-Leistung */
  DCL PT_GRUND      FLOAT  GLOBAL;/* Faktoren fuer die Bestimmung    */
  DCL PT_FAKTOR     FLOAT  GLOBAL;/* der thermischen BHKW-Leistung   */
  DCL Z_LZBPMP (8) FIXED(31) GLOBAL; /* Z. Laufz. BHKW-PMP-HZG       */
  DCL PT_BIST  ( 8) FLOAT  GLOBAL;/* thermische Ist-Leistung des BHKW*/
  DCL FL_BTHKWH( 8)  FLOAT GLOBAL; /* BHKW-Waermeerzeugung in kWh     */
  DCL B_BERLAUBT2( 8) BIT(1) GLOBAL; /* 1: BHKW( ) ist freigegeben   */
  DCL B_BLHILF(8) BIT(1)    GLOBAL; /* Hilfsbit fuer CAN-Bus BHKW-laeuft */
  DCL B_BMUSSEIN(8)   BIT(1) GLOBAL;/* BHKW soll angefordert werden  */
  DCL B_BMUSSAUS(8)   BIT(1) GLOBAL;/* BHKW-Anforderung soll weg     */
  DCL Z_MUSSAUS( 8)   FIXED GLOBAL; /* Hilfsvariable CAN-Komm        */ 
  DCL Z_BBL    ( 8)   FIXED GLOBAL; /* Hilfsvariable CAN-Komm        */ 
  DCL Z_BCAN( 8)  FIXED     GLOBAL; /* Zaehler fuer CAN-Sendungen BHKWs  */
  DCL Z_FEHLERKRA( 8) FIXED GLOBAL; /* CAN-Fehlernummer Kraftwerk-BHKW */
  DCL Z_WARNKRA( 8)  FIXED  GLOBAL; /* CAN-Warnnummer Kraftwerk-BHKW */
  DCL Z_MINAUSKRA( 8) FIXED GLOBAL; /* CAN-Mindestauszeit Kraftwerk-BHKW */
  DCL B_BWARN( 8) BIT(1)    GLOBAL; /* 1: BHKW-Warnung                   */
  DCL B_START( 8) BIT(1)    GLOBAL; /* 1: BHKW-Start laeuft              */
  DCL Z_START24       FIXED GLOBAL; /* Starts in 24h                 */
  DCL X_AAPBHKW( 8) FLOAT GLOBAL; /* Analoge Ansteuerung P-BHKW     (%) */
  DCL PT_BHKWMOEG     FLOAT GLOBAL; /* thermische BHKW-Leistung      */

  /* Variablen fuer die Kessel (1 bis N_KESSEL)                       */
  DCL B_KEIN   (10) BIT(1) GLOBAL;/* Kessel EIN/AUS Signal           */
  DCL B_KL     (10) BIT(1) GLOBAL;/* Kessel laeuft                   */
  DCL B_KPMP   (10) BIT(1) GLOBAL;/* KesselPumpe                     */
  DCL Z_KPNL   (10) FIXED  GLOBAL; /* Zaehler fuer Kesselpumpennachlauf */
  DCL B_KLRAUF (10) BIT(1) GLOBAL;/* Kessel-Leistung rauf Signal     */
  DCL B_KLRUNT (10) BIT(1) GLOBAL;/* Kessel-Leistung runter Signal   */
  DCL Z_KSTELL (10) FIXED  GLOBAL;/* Stellung Kesselbrenner in s     */
  DCL ZE_KV    (10) FIXED GLOBAL; /* Zeiger auf Anain Kesselvorlauf   */
  DCL ZE_KR    (10) FIXED GLOBAL; /* Zeiger auf Anain Kesselruecklauf  */
  DCL ZA_KESPMP(10) FIXED GLOBAL; /* Zeiger Anaout  Kesselpumpenleist.*/
  DCL ZA_KANST (10) FIXED GLOBAL; /* Zeiger Anaout  Kesselansteuerung */
  DCL RA_KTI   (10) FLOAT GLOBAL; /* Pth-Regler I-Anteil              */
  DCL RA_KTP   (10) FLOAT GLOBAL; /* Pth-Regler P-Anteil              */
  DCL RA_KT1   (10) FLOAT GLOBAL; /* Pth-Regler, alte Abweichung     */
  DCL RA_KTDTAU (10) FLOAT GLOBAL; /* Pth-Regler geglaett. D-Anteil   */
  DCL RA_KTDITAU(10) FLOAT GLOBAL; /* Pth-Regler geglaett. DI-Anteil  */
  DCL RA_KPI   (10) FLOAT GLOBAL; /* KPMP-Regler I-Anteil              */
  DCL RA_KPP   (10) FLOAT GLOBAL; /* KPMP-Regler P-Anteil              */
  DCL RA_KP1   (10) FLOAT GLOBAL; /* KPMP-Regler, alte Abweichung     */
  DCL RA_KPDTAU (10) FLOAT GLOBAL; /* KPMP-Regler geglaett. D-Anteil   */
  DCL RA_KPDITAU(10) FLOAT GLOBAL; /* KPMP-Regler geglaett. DI-Anteil  */
  DCL B_KESMIA (10) BIT(1) GLOBAL;/* Kesselmischer auf               */
  DCL B_KESMIZ (10) BIT(1) GLOBAL;/* Kesselmischer zu                */
  DCL Z_KESMI  (10) FIXED  GLOBAL; /* Softwareendkontakt fuer Kesmi.  */
  DCL Z_KMISTELL(10) FIXED  GLOBAL;/* Stellung Kesselmischer in s    */
  DCL XA_KPMP  (10) FLOAT GLOBAL; /* Ansteuerung Kesselpumpe         */
  DCL Z_KLZ    (10) FIXED(31) GLOBAL; /* Kesselanforderungszeit (s)      */
  DCL Z_KLZMIN      FIXED(31) GLOBAL; /* kuerzeste Kessellaufzeit         */
  DCL TC_KV    (10) FLOAT GLOBAL; /* Kesselvorlauftemperaturen       */
  DCL TC_KR    (10) FLOAT GLOBAL; /* Kesselruecklauftemperaturen      */
  DCL Z_KHARDST(10) FIXED GLOBAL; /* Zaehler Kessel Hardwarestoerung   */
  DCL B_KHARDST(10) BIT(1) GLOBAL;/* Kesselstoerung wg. Digitaleing.  */
  DCL B_KSOFTST(10) BIT(1) GLOBAL;/* Kesselstoerung wg. keine Spreiz. */
  DCL Z_LZKPMP (10) FIXED(31) GLOBAL; /* Z. Laufz. Kesselpumpe        */
  DCL Z_PKES   (10) FIXED  GLOBAL;/* Zaehler Kesselleistungseinstellung */
  DCL PT_KESAKT(10) FLOAT GLOBAL; /* aktuelle Kesselleistung         */
  DCL PT_KESSOLL(10) FLOAT GLOBAL; /* aktuelle Kesselsollleistung    */
  DCL Z_KL     (20) FIXED GLOBAL; /* Kesselbetriebszeit in s         */
  DCL TC_KVSOLL(10) FLOAT GLOBAL; /* Kesselvorlauf-Soll-Temp         */
  DCL PT_KSOLL (10) FLOAT GLOBAL; /* Anforderung gemaess Waermebedarf (%) */
  DCL X_AAKPTH (10) FLOAT GLOBAL; /* Analoge Ansteuerung P-Kessel   (%) */
  DCL PT_MINKES     FLOAT GLOBAL; /* kleinste PT-Anforderung aller Kessel (%) */
  DCL Z_PTMINKES    FIXED GLOBAL; /* Zaehler Kessel Min-Leistung     */
  DCL B_KTHERM (10) BIT(1) GLOBAL;/* Kessel-Thermostat ( >KVMAX+4)     */
  DCL Z_KTHERM (10) FIXED  GLOBAL;/* Kessel-Stellung Brenner in s      */
  DCL TC_KVMERK(10) FLOAT GLOBAL; /* Kesselvorlauftemperaturmerker   */
  DCL B_KST2   (10) BIT(1) GLOBAL; /* 1: Kessel 2. Stufe angefordert    */
  DCL KES_TXT1 (10) CHAR(40) GLOBAL;/* Kes-Beschreibung Text1        */
  DCL KES_TXT2 (10) CHAR(40) GLOBAL;/* Kes-Beschreibung Text2        */
  DCL Z_STOKMS (10) FIXED GLOBAL;/* Stockerschn LFZ ms            */
  DCL Z_STOKVIERT(10) FIXED GLOBAL;/* Stockerschn LFZ (1/4h) (s *10)     */
  DCL Z_KTEMPEIN(10) FIXED GLOBAL;/* >0: Stoker vor < 30Min noch gelaufen */

  /* Variablen fuer die Brauchwasserspeicher (1 bis N_SPEI)           */
  DCL B_ZIRKPMP  (10)BIT(1) GLOBAL;/* Brauchwasserzirkulationspumpe   */
  DCL B_LPMP     (10)BIT(1) GLOBAL;/* Brauchwasserladepumpe           */
  DCL B_SPMP     (10)BIT(1) GLOBAL;/* Brauchwasserspeisepumpe         */
  DCL TC_BWO     (10)FLOAT GLOBAL; /* Brauchwassertemperatur oben     */
  DCL TC_BWIST   (10)FLOAT GLOBAL; /* Speise VL                       */
  DCL TC_BWVOR   (10)FLOAT GLOBAL; /* Lade VL                         */
  DCL TC_BWRUECK (10)FLOAT GLOBAL; /* Lade RL                         */
  DCL TC_ZIRK    (10)FLOAT GLOBAL; /* Zirkulation RL                  */
  DCL ZE_BWIST   (10)FIXED GLOBAL; /* Zeiger auf Anain Speise VL      */
  DCL ZE_BWO     (10)FIXED GLOBAL; /* Zeiger auf Anain Speicher oben  */
  DCL ZE_BWVOR   (10)FIXED GLOBAL; /* Zeiger auf Anain Lade VL        */
  DCL ZE_BWRUECK (10)FIXED GLOBAL; /* Zeiger auf Anain Lade RL        */
  DCL ZE_ZIRK    (10)FIXED GLOBAL; /* Zeiger auf Anain Zirkulation RL */
  DCL ZA_BWLPMP  (10)FIXED GLOBAL; /* Zeiger auf Anaout Ladepumpe     */
  DCL ZA_BWSPMP  (10)FIXED GLOBAL; /* Zeiger auf Anaout Speisepumpe   */
  DCL ZA_BWZPMP  (10)FIXED GLOBAL; /* Zeiger auf Anaout Zirkpumpe     */
  DCL B_BWDRIG   (10)BIT(1) GLOBAL;/* 1: Brauchwasseranforderung drin.*/
  DCL B_BWMOGL   (10)BIT(1) GLOBAL;/* 1: Brauchwasseranforderung moegl.*/
  DCL B_BWNORM   (10)BIT(1) GLOBAL;/* 1: Brauchwasseranforderung norm.*/
  DCL B_BWNACHT  (10)BIT(1) GLOBAL;/* 1: Brauchwasseranforderung Nacht*/
  DCL B_BWB      (10)BIT(1) GLOBAL;/* Bedingung Lade VL warm genug    */
  DCL TC_BWTW    (10)FLOAT GLOBAL; /* Bw-Speisesolltemp               */
  DCL Z_LZBWLPMP (10)FIXED(31) GLOBAL; /* Z. Laufz. BW-Ladepumpe     */
  DCL Z_LZBWSPMP (10)FIXED(31) GLOBAL; /* Z. Laufz. BW-Speisepumpe   */
  DCL Z_LZBWZPMP (10)FIXED(31) GLOBAL; /* Z. Laufz. BW-Zirkpmp       */
  DCL B_BWANF    (10)BIT(1) GLOBAL;/* 1: Brauchwasseranforderung      */
  DCL B_BWANFGES     BIT(1) GLOBAL;/* 1: Brauchwasseranforderungges   */
  DCL TC_BWVLS   (10)FLOAT GLOBAL; /* gef. Brauchwasser-Vorlaufsoll   */
  DCL TC_BWVLSGES    FLOAT GLOBAL; /* gef. Brauchwasser-Vorlaufsollges*/
  DCL TC_BWS     (10)FLOAT GLOBAL; /* aktueller WW-Sollwert           */
  DCL Z_LEGIO    (10)FIXED GLOBAL; /* Zaehler fuer Legionellenkill    */
  DCL Z_LEGNACH  (10)FIXED GLOBAL; /* Zaehler fuer nach Legionellenkill  */
  DCL RA_WWLI    (10)FLOAT GLOBAL; /* WW-Lade-Regler I-Anteil           */
  DCL RA_WWLP    (10)FLOAT GLOBAL; /* WW-Lade-Regler P-Anteil          */
  DCL RA_WWL1    (10)FLOAT GLOBAL; /* WW-Lade-Regler, alte Abweichung     */
  DCL RA_WWLDTAU (10)FLOAT GLOBAL; /* WW-Lade-Regler geglaett. D-Anteil   */
  DCL RA_WWLDITAU(10)FLOAT GLOBAL; /* WW-Lade-Regler geglaett. DI-Anteil  */
  DCL XA_WWLAD   (10)FLOAT GLOBAL; /* WW-Lade-Ansteuerung gesamt      */
  DCL XA_WWLADMI (10)FLOAT GLOBAL; /* WW-Lade-Ansteuerung Mischer     */
  DCL XA_WWLADP  (10)FLOAT GLOBAL; /* WW-Lade-Ansteuerung Pumpe       */
  DCL B_LMIAUF   (10)BIT(1) GLOBAL; /* Mischersignal AUF              */
  DCL B_LMIZU    (10)BIT(1) GLOBAL; /* Mischersignal ZU               */
  DCL Z_LMISTELL (20)FIXED GLOBAL; /* Stellung Lademischer in s       */
  DCL TC_BWZS    (10)FLOAT GLOBAL; /* aktueller Zirk-RL-Sollwert      */
  DCL RA_WWZI    (10)FLOAT GLOBAL; /* WW-Zirk-Regler I-Anteil           */
  DCL RA_WWZP    (10)FLOAT GLOBAL; /* WW-Zirk-Regler P-Anteil          */
  DCL RA_WWZ1    (10)FLOAT GLOBAL; /* WW-Zirk-Regler, alte Abweichung     */
  DCL RA_WWZDTAU (10)FLOAT GLOBAL; /* WW-Zirk-Regler geglaett. D-Anteil   */
  DCL RA_WWZDITAU(10)FLOAT GLOBAL; /* WW-Zirk-Regler geglaett. DI-Anteil  */
  DCL XA_WWZI    (10)FLOAT GLOBAL; /* WW-Zirk-Ansteuerung             */
  DCL XA_WWSPEIP (10)FLOAT GLOBAL; /* WW-Speisepumpenansteuerung      */
  DCL X_CALT     (10)FLOAT GLOBAL; /* Merker fuer Reg Speisep.        */
  DCL WW_NAME    (10)CHAR(15) GLOBAL;/* Name der WW-Bereitung          */
  DCL Z_BWKALT       FIXED GLOBAL; /* Zaehler BW-Austritt zu kalt in s */
  DCL RA_BWALT   (8) FLOAT GLOBAL;

  /* Heizkreisbezogene Daten (1 bis N_HZKR)                          */
  DCL ZE_HK    (32) FIXED GLOBAL; /* Fuehlernummer des Heizkreisvor.  */
  DCL ZE_HKR   (32) FIXED GLOBAL; /* Fuehlernummer des Heizkreisrueck. */
  DCL ZA_PHK   (32) FIXED GLOBAL; /* Zeiger auf analog AUS Pumpe     */
  DCL B_PMPHK  (32) BIT(1) GLOBAL; /* Heizkreispumpe                 */
  DCL B_MIAUF  (32) BIT(1) GLOBAL; /* Mischersignal AUF              */
  DCL B_MIZU   (32) BIT(1) GLOBAL; /* Mischersignal ZU               */
  DCL TC_HKSOLL(32) FLOAT GLOBAL; /* Heizkreisvorlaufsolltemperatur  */
  DCL TC_HKSOLLGES(32) FLOAT GLOBAL; /* Heizkreisvorlaufsolltemperatur incl. Integrator */
  DCL TC_HKIST (32) FLOAT GLOBAL; /* Ist-Temperatur des Heizkreises  */
  DCL TC_HKR   (32) FLOAT GLOBAL; /* Ist-Temperatur des Heizkreisr.  */
  DCL RA_MI    (60) FLOAT GLOBAL; /* HK-Mischer-Regler I-Anteil           */
  DCL RA_MP    (60) FLOAT GLOBAL; /* HK-Mischer-Regler P-Anteil          */
  DCL RA_M1    (60) FLOAT GLOBAL; /* HK-Mischer-Regler, alte Abweichung     */
  DCL RA_MDTAU (60) FLOAT GLOBAL; /* HK-Mischer-Regler geglaett. D-Anteil   */
  DCL RA_MDITAU(60) FLOAT GLOBAL; /* HK-Mischer-Regler geglaett. DI-Anteil  */
  DCL XA_HKMI  (60) FLOAT GLOBAL; /* HK-Mischer-Ansteuerung          */
  DCL XA_HKP   (32) FLOAT GLOBAL; /* HK-Pumpen-Ansteuerung           */
  DCL Z_HOCHHK (32) FIXED  GLOBAL;/* Zaehler Hochlaufphase           */
  DCL Z_RUNTHK (32) FIXED  GLOBAL;/* Zaehler Runterlaufphase         */
  DCL B_TAERHK (32) BIT(1) GLOBAL;/* Tag erreicht (einzelner Hzkr.)  */
  DCL B_NAERHK (32) BIT(1) GLOBAL;/* Nachtabsenkung Hzkr. erreicht   */
  DCL B_ABSHK  (32) BIT(1) GLOBAL;/* 1: Absenk. Heizkreis(n) aktiv   */
  DCL B_ABSTOG (32) BIT(1) GLOBAL;/* Absenkung Heizkreis umschalten  */
  DCL B_VORHK  (32) BIT(1) GLOBAL;/* Vor-Phase des Heizkreises       */
  DCL B_HOCHHK (32) BIT(1) GLOBAL;/* Hochlaufphase des einzelnen Hzkr*/
  DCL B_RUNTHK (32) BIT(1) GLOBAL;/* Runter-Phase des einzelnen Hzkr */
  DCL ZP_ABSEHK(32) CLOCK  GLOBAL;/* Zeit aktuelles Absenkungsende   */
  DCL DA_ABSEHK(32) FIXED  GLOBAL;/* Tagesnummer akt. Absenkungsende */
  DCL B_HMT    (32) BIT(1) GLOBAL; /* Heizkreis EIN wg. Tagesheizgr. */
  DCL B_HMR    (32) BIT(1) GLOBAL; /* Hausmeister Raum               */
  DCL B_HMN    (32) BIT(1) GLOBAL; /* Heizkreis EIN wg. Nachtheizgr. */
  DCL Z_HKMI   (32) FIXED  GLOBAL; /* Softwareendkontakt fuer HK-Mi. */
  DCL TD_HKINT (32) FLOAT  GLOBAL; /* langfrist. Integrator Soll-Ist */
  DCL Z_HKMISTELL(60) FIXED  GLOBAL;/* Stellung HK-Mischer in s      */
  DCL P_HKTH(32)     FLOAT GLOBAL; /* Pth von Softwarewaermezaehler  */
  DCL DF_HKTH(32)    FLOAT GLOBAL; /* Df  von Softwarewaermezaehler  */                          
  DCL TD_INTHK(32)   FLOAT GLOBAL; /* Integrator dT fuer SoftWMZ     */
  DCL FL_THVIERT(32,15) FLOAT   GLOBAL;/* kWh th.-Leistung der akt. 1/4h*/
  DCL Z_LZHKPMP (32) FIXED(31) GLOBAL; /* Z. Laufz. HK-Pumpe         */
  DCL B_STOERSTW(32) BIT(1) GLOBAL;/* 1: Heizkreis Stoerung STW      */
  DCL Z_STOERSTW(32) FIXED  GLOBAL;/* Zaehler Heizkreis Stoerung STW */
  DCL TC_RSOLLAKT(32)   FLOAT  GLOBAL; /* akt. Raumsolltemperaturen     */
  DCL TC_RISTAKT(32)    FLOAT  GLOBAL; /* akt. Raumisttemperaturen      */

  /* Variablen fuer die Timer                                         */
  DCL B_ABSEIN (64) BIT(1) GLOBAL; /* Zustand Timer                  */
  DCL T_NAME(64) CHAR(20) GLOBAL;  /* Name Timer                       */

  /* Variable fuer den Terminkalender:                                */
  DCL Z_JAHRTAG  FIXED GLOBAL; /* ZÑhler fuer den aktuellen Jahrestag */
  DCL ZT_JAHR    FIXED(31) GLOBAL; /* Zehntelsekundenstand des Jahres*/
  DCL ZK_WOCH    INV FIXED(31) GLOBAL INIT(6048000(31));/* Wochenkonst */
  DCL ZK_TAG     INV FIXED(31) GLOBAL INIT(864000(31)); /* Tageskonst  */
  DCL ZK_STUND   INV FIXED(31) GLOBAL INIT( 36000(31)); /* Stundenkonst*/
  DCL ZK_MIN     INV FIXED(31) GLOBAL INIT( 600(31));   /* Minutenkonst*/
  DCL ZK_SEC     INV FIXED(31) GLOBAL INIT( 10(31));    /* Sekundenkons*/

  /* Das aktuelle Datum:                                             */
  DCL ZP_NOW    CLOCK GLOBAL; /* Die globale Zeit                    */
  DCL DA_WOTAG  FIXED GLOBAL; /* aktueller Wochentag, MO bis SO: 1-7 */
  DCL DA_DAT    FIXED GLOBAL; /* 1. bis 31. des Monats               */
  DCL DA_MON    FIXED GLOBAL; /* 1. bis 12. Monat                    */
  DCL DA_JAH    FIXED GLOBAL; /* Jahr 1973-32767                     */
  DCL DA_TNR    FIXED GLOBAL; /* Tagesnummer des aktuellen Datums    */
  DCL ZF_STD    FIXED      GLOBAL; /* Aktuelle Zeit als FIXED        */
  DCL ZF_MIN    FIXED      GLOBAL; /* Aktuelle Zeit als FIXED        */
  DCL ZF_SEK    FIXED      GLOBAL; /* Aktuelle Zeit als FIXED        */
  DCL Z_SEKTAG  FIXED(31) GLOBAL; /* Tagessekundenstand       */
  DCL B_DATUMNEU  BIT(1) GLOBAL; /* Falls Mitternacht, Datum auslesen*/
  DCL ZP_RESET   CLOCK   GLOBAL; /* RESET-Zeitpunkt                  */
  DCL DA_RESDAT  FIXED   GLOBAL; /* RESET-Datum                      */
  DCL DA_RESMON  FIXED   GLOBAL; /* RESET-Monat                      */

  /* diverse:                                                        */
  DCL N_ANALOG      FIXED  GLOBAL;/* 1-60 Analogausgangskanaele       */
  DCL N_PWM         FIXED  GLOBAL;/* 1-20 PWM-Ausgaenge               */
  DCL N_FUEHLER     FIXED  GLOBAL;/* 1-144 Analogeingangskanaele       */
  DCL B_WDINIT      BIT(1) GLOBAL;/* 1: Watchdog haelt still          */
  DCL B_WATCHDOG BIT(1)  GLOBAL; /* 1: Watchdog beruhigen erlaubt    */
  DCL B_BENUTZER BIT(1)  GLOBAL; /* 1: Watchdog beruhigen erlaubt    */
  DCL B_OUTENA   BIT(1)  GLOBAL; /* 1: digitale Ausgabe erlaubt      */
  DCL B_PARANEU  BIT(1)  GLOBAL; /* 1: Parameter neu initialisieren  */
  DCL B_HT          BIT(1) GLOBAL;/* akt. Tarifzustand 1: HT, 0: NT  */
  DCL ZP_KABSEAKT   CLOCK  GLOBAL;/* Zeit akt. Kernabsenkungsende    */
  DCL DA_KABSEAKT   FIXED  GLOBAL;/* Tagesnr. akt. Kernabsenkungsende*/
  DCL B_KERNABS     BIT(1) GLOBAL;/* 1: Kernabsenkung aktiv          */
  DCL ZD_VOR        DUR    GLOBAL;/* Zeitdauer vor Absenkungsende    */
  DCL B_VOR         BIT(1) GLOBAL;/* 1: T VOR aktiv                  */
  DCL B_NAER        BIT(1) GLOBAL;/* 1: Nachtabsenkungstemp erreicht */
  DCL B_TAER        BIT(1) GLOBAL;/* 1: Tag erreicht                 */
  DCL B_HMNGES      BIT(1) GLOBAL;/* veroderte Heizkreisnachtheizgr. */
  DCL B_HMTGES      BIT(1) GLOBAL;/* veroderte Heizkreistagesheizgr. */
  DCL B_TM1         BIT(1) GLOBAL;/* 1: T max fuer Waermevernichtung   */
  DCL B_TM2         BIT(1) GLOBAL;/* 1: T max fuer Notkuehler          */
  DCL B_TM3         BIT(1) GLOBAL;/* 1: T max fuer Waermeerzeuger      */
  DCL B_WA          BIT(1) GLOBAL;/* 1: WÑrmeanforderung             */
  DCL B_SB          BIT(1) GLOBAL;/* 1: Strombedarf                  */
  DCL B_ESPB        BIT(1) GLOBAL;/* 1: Einschaltsperre BHKW         */
  DCL B_ESPK        BIT(1) GLOBAL;/* 1: Einschaltsperre Kessel       */
  DCL B_KESAUS      BIT(1) GLOBAL;/* 1: Kessel aus                   */
  DCL B_PMIN        BIT(1) GLOBAL;/* 1: untere Leistungsgrenze BHKWs */
  DCL B_PMAX        BIT(1) GLOBAL;/* 1: obere Leistungsgrenze BHKWs  */
  DCL B_HZGWB       BIT(1) GLOBAL;/* 1: Heizung WÑrmebedarf          */
  DCL Z_TMA         FIXED  GLOBAL;/* Zaehler Mindestauszeit          */
  DCL ZF_TMA        FIXED  GLOBAL;/* Mindestauszeit                  */
  DCL TC_VSOLL      FLOAT  GLOBAL;/* Hauptkreisvorlauftemp. Sollwert */
  DCL PE_BEDARF     FLOAT  GLOBAL;/* Leistungsbedarf elt. der Anlage */
  DCL PE_BSOLLGES   FLOAT  GLOBAL;/* Gesamtsolleistung aller BHKW    */
  DCL PE_THERM      FLOAT  GLOBAL;/* elt. Solleist. wegen Temperatur */
  DCL TC_MAX        FLOAT  GLOBAL;/* maximale Hauptkreisvorlauftemp. */
  DCL Z_TEIN        FIXED  GLOBAL;/* Zaehler BHKW1 Einzeit           */
  DCL ZF_TEIN       FIXED  GLOBAL;/* BHKW1 Einzeit (s)               */
  DCL B_BWDRIGG     BIT(1) GLOBAL;/* 1: Brauchwasseranforderung dring*/
  DCL B_BWMOGLG     BIT(1) GLOBAL;/* 1: Brauchwasseranforderung moegl */
  DCL B_BWNORMG     BIT(1) GLOBAL;/* 1: Brauchwasseranforderung norm */
  DCL B_WASONST     BIT(1) GLOBAL;/* 1: Sonstige Waermeanforderung    */
  DCL B_PUMPSCH     BIT(1) GLOBAL;/* 1: Pumpenschonung aktiv         */
  DCL Z_TMESS       FIXED  GLOBAL; /* Zaehler fuer TMESS Routine     */
  DCL Z_HMNEU       FIXED  GLOBAL; /* Zaehler fuer Hausmeister     */
  DCL Z_LRSPERR     FIXED  GLOBAL; /* Zaehler fuer Leistungsregelersperre */
  DCL ZF_LRSPERR    FIXED  GLOBAL;/* Leistungsregler-Sperrzeit         */
  DCL TC_AUSSEN     FLOAT GLOBAL; /* Aussentemperatur                */
  DCL ZUST_HZG      FIXED GLOBAL; /* 1: Auto 2: Tag 3: Nacht         */
  DCL PE_ERZFELD(96) FLOAT GLOBAL;/* Feld der 15 MIN-PE-Erzeugung    */
  DCL PE_ERZVIERTEL FLOAT GLOBAL; /* Viertelstundenwert PE_BIST(...) */
  DCL PE_FELD(96)   FLOAT GLOBAL;/* Feld der 15 MIN-Durchschnitte PE */
  DCL PE_VIERTEL    FLOAT GLOBAL; /* Viertelstundenwert PE_BEDARF    */
  DCL PE_SCHNITT    FLOAT GLOBAL; /* durchschnittlicher Strombed.    */
  DCL PE_SPITZE     FLOAT GLOBAL; /* maximale 15 MIN-Leistung        */
  DCL ZP_SPITZE     CLOCK GLOBAL; /* Zeitpunkt maximale 15 MIN-Leist.*/
  DCL TC_ATFELD(96) FLOAT GLOBAL;/* Feld der 15 MIN-Durchschnitte AT */
  DCL TC_ATVIERTEL  FLOAT GLOBAL; /* Viertelstundenwert TC_AUSSEN    */
  DCL TC_AUSSENMAX  FLOAT GLOBAL; /* maximale Aussentemperatur       */
  DCL ZP_AUSSENMAX  CLOCK GLOBAL; /*  Zeitpunkt maximale Aussentemp  */
  DCL TC_AUSSENMIN  FLOAT GLOBAL; /* minimale Aussentemperatur       */
  DCL ZP_AUSSENMIN  CLOCK GLOBAL; /*  Zeitpunkt minimale Aussentemp  */
  DCL TC_VIST       FLOAT GLOBAL; /* Hauptkreisvorlauftemperatur     */
  DCL P_VERTEIL     FLOAT GLOBAL; /* Druck Verteiler                 */
  DCL TC_RUECK      FLOAT GLOBAL; /* Hauptkreisruecklauftemperatur    */
  DCL TC_UEBER      FLOAT GLOBAL; /* Ueberstrîmungstemperatur         */
  DCL TC_VSOLLMAX   FLOAT GLOBAL; /* hoechstes Vorlaufsollmax der HKs */
  DCL TC_WASONST    FLOAT GLOBAL; /* Vorlaufsoll sonstige Anford.    */
  DCL TC_VALT       FLOAT GLOBAL; /* Vorlauftemperatur letzte Messp. */
  DCL ST_VIST       FLOAT GLOBAL; /* Vorlauftemperatursteigung       */
  DCL ST_VSOLL      FLOAT GLOBAL; /* Vorlauftemperatursollsteigung   */
  DCL TD_RA         FLOAT GLOBAL; /* Regelabw. Vorlauftemperatur     */
  DCL Z_STKLEIN FIXED(31) GLOBAL; /* Steigung n Intervalle zu klein  */
  DCL Z_STGROSS FIXED(31) GLOBAL; /* Steigung n Intervalle zu gross  */
  DCL ZF_LMAX   FIXED     GLOBAL; /* Zaehlergrenze fuer BHKW-Pmax      */
  DCL Z_LMAX    FIXED(31) GLOBAL; /* Leistung an oberer Grenze (BHKW)*/
  DCL Z_LMIN    FIXED(31) GLOBAL;/* Leistung an unterer Grenze (BHKW)*/
  DCL ZF_LKMAX  FIXED     GLOBAL; /* Zaehlergrenze fuer Kessel-Pmax  */
  DCL Z_LKMAX   FIXED(31) GLOBAL; /* Leistung an oberer Grenze (Kess)*/
  DCL Z_BANFORD     FIXED GLOBAL; /* Anzahl der angeforderten BHKW   */
  DCL Z_BAKT        FIXED GLOBAL; /* Anzahl der aktiven BHKW         */
  DCL Z_ZEHN        FIXED GLOBAL; /* Zehnminutenstand der Woche      */ 
  DCL Z_KANFORD     FIXED GLOBAL; /* Anzahl der angeforderten Kessel */
  DCL Z_KAKT        FIXED GLOBAL; /* Anzahl der aktiven Kessel       */
  DCL Z_BAKTLR      FIXED GLOBAL; /* Anzahl der aktiven BHKW + 1     */
  DCL Z_PMPHK       FIXED GLOBAL; /* Anzahl aktiver Heizkreispumpen  */
  DCL Z_LETZT       FIXED GLOBAL; /* Zeiger auf letzten akt. Waermeerz*/
  DCL ZE_AUSSEN     FIXED GLOBAL; /* Zeiger auf Anain Aussentemperatur*/
  DCL ZE_VORLAUF    FIXED GLOBAL; /* Zeiger auf Anain Hauptkreisvorl. */
  DCL ZE_RUECK      FIXED GLOBAL; /* Zeiger auf Anain Hauptkreisrueckl.*/
  DCL ZE_UEBER      FIXED GLOBAL; /* Zeiger auf Anain öberstroemung    */
  DCL ZE_PEBED      FIXED GLOBAL; /* Zeiger auf Anain Leistungsbedarf */
  DCL ZF_SOLLST     FIXED GLOBAL; /* Sollsteigungszeit                */
  DCL TD_MAX        FLOAT GLOBAL;/* Grenztemperatur T max             */
  DCL TD_STUFEA     FLOAT GLOBAL;/* Temperaturdiff. eine Stufe rauf   */
  DCL TD_STUFEB     FLOAT GLOBAL;/* Temperaturdiff. eine Stufe runter */
  DCL PE_STUFE      FLOAT GLOBAL;/* Leistungsdiff. eine Stufe rauf    */
  DCL ZD_EIN        DUR   GLOBAL;/* EIN Zeit Brauchwasserladung       */
  DCL ZF_RUNT       FIXED GLOBAL;/* Dauer Absenkungsphase (in 10s)    */
  DCL ZF_HOCH       FIXED GLOBAL;/* Dauer Anhebungssphase (in 10s)    */
  DCL ZF_NKE        FIXED GLOBAL;/* nach Kessel ein                   */
  DCL ZF_NBE        FIXED GLOBAL;/* nach BHKW ein                     */
  DCL ZF_NBA        FIXED GLOBAL;/* nach BHKW aus                     */
  DCL B_ABSSTELL   BIT(1) GLOBAL;/* 1: Absenkung wird gerade verst.   */
  DCL Z_LZ      FIXED(31) GLOBAL; /* kont. Steuerungslaufzeit         */
  DCL FL_SYS        FLOAT GLOBAL;/* Zeitdauer 1*Systakt               */

  DCL PE_BGES     FLOAT GLOBAL;/* gesamte el. Leistung               */
  DCL PT_VIERTEL  FLOAT GLOBAL;/* thermischer Viertelstundenwert     */
  DCL PT_AKT      FLOAT GLOBAL;/* aktuelle thermische Leistung       */
  DCL PT_KAKT     FLOAT GLOBAL;/* aktuelle thermische Leistung KESSEL */
  DCL PT_KVIERTEL FLOAT GLOBAL;/* th. Viertelstundenwert Kessel  */
  DCL PT_FELD(96) FLOAT GLOBAL;/* 15 MIN-Leistungsbedarfsfeld        */
  DCL PT_ALT      FLOAT GLOBAL;/* Merker fuer PT_SCHNITT              */
  DCL Z_SCHNITT   FIXED  GLOBAL;/* Zaehler Durchschnittsleistungsberechnung  */
  DCL Z_HAUPTNUTZ FIXED  GLOBAL;/* Anzahl der 15 MIN-Durchschnitte/d */
  DCL Z_PANELSEND FIXED  GLOBAL;/* Zaehler zum Anstoss 1/4h Daten Panel */
  DCL B_TAKT1     BIT(1) GLOBAL;/* Taktbit: immer                    */
  DCL B_TAKT2     BIT(1) GLOBAL;/* Taktbit: alle 2 s                 */
  DCL B_TAKT3     BIT(1) GLOBAL;/* Taktbit: alle 4 s                 */
  DCL B_TAKT4     BIT(1) GLOBAL;/* Taktbit: alle 3 s                 */
  DCL B_TAKT5     BIT(1) GLOBAL;/* Taktbit: alle 5 s                 */
  DCL B_TAKT10    BIT(1) GLOBAL;/* Taktbit: alle 10 s                */
  DCL B_TAKT15    BIT(1) GLOBAL;/* Taktbit: alle 15 s                */
  DCL B_TAKT20    BIT(1) GLOBAL;/* Taktbit: 3*     pro MIN           */
  DCL B_TAKT30    BIT(1) GLOBAL;/* Taktbit: 2*     pro MIN           */
  DCL B_TAKT60    BIT(1) GLOBAL;/* Taktbit: einmal pro MIN           */
  DCL B_SAMMELST  BIT(1) GLOBAL; /* Sammelstoerungsmeldung            */
  DCL TX_STOERMEL(200)   CHAR(20) GLOBAL; /* Stoerungsmeldetexte     */  
  DCL Z_STOERNEU(200) FIXED GLOBAL;/* Zaehler Stoerung neu / Tag      */
  DCL Z_STOER(200) FIXED   GLOBAL;/* Stoerungsverzoegerer            */
  DCL B_STOERMERK(200) BIT(1) GLOBAL;/* Stoerungsmerker              */
  DCL B_STOER(200) BIT(1)  GLOBAL;/* 1: Stoerung steht an            */
  DCL Z_STOERFAST(200) FIXED GLOBAL;/* >0: dringende Stoerung        */
  DCL Z_TCKLEIN   FIXED   GLOBAL;/* Zaehler TC_VIST<TC_VSOLL          */
  DCL IDSTRING    CHAR(46) GLOBAL; /* Steuerungsname                 */
  DCL PE_BEZUGVIERT FLOAT GLOBAL; /* el. Viertelstundenbez.          */
  DCL P_GAS          FLOAT   GLOBAL;/* akt. Gasleistung gesamt       */
  DCL P_GASK         FLOAT   GLOBAL;/* akt. Gasleistung Kessel       */
  DCL P_GASB         FLOAT   GLOBAL;/* akt. Gasleistung BHKW         */
  DCL FL_GAS         FLOAT   GLOBAL;/* Analogsignal Gassensor + 2.5V */
  DCL N_UPE             FIXED GLOBAL; /* Anzahl UPE-Pumpen           */  
  DCL UPE_ISTST(32)     FIXED GLOBAL; /* Iststufe von UPE-Pumpe      */  
  DCL UPE_ISTKOMM(32)   FIXED GLOBAL; /* Istkommando von UPE-Pumpe   */  
  DCL UPE_ISTDF(32)     FLOAT GLOBAL; /* Istdurchflu· von UPE-Pumpe  */  
  DCL UPE_ISTDRUCK(32)  FLOAT GLOBAL; /* Istdruck von UPE-Pumpe      */  
  DCL UPE_ISTTEMP(32)   FLOAT GLOBAL; /* Isttemperatur von UPE-Pumpe */  
  DCL UPE_WTHERM(32)    FLOAT GLOBAL; /* therm. Arbeit von UPE-Pumpe */  
  DCL UPE_PTHERM(32)    FLOAT GLOBAL; /* therm. Leistung von UPE-Pumpe */  
  DCL UPE_FEHLER(32)    FIXED GLOBAL; /* Fehlerstatus von UPE-Pumpe  */  
  DCL UPE_SOLLST(32)    FIXED GLOBAL; /* Sollstufe an UPE-Pumpe      */  
  DCL UPE_ZSOLLMIN(32)  FIXED GLOBAL; /* Zaehler Sollstufe MIN       */  
  DCL UPE_SOLLKOMM(32)  FIXED GLOBAL; /* Sollkommando an UPE-Pumpe   */  
  DCL UPE_PRO(32)       FLOAT GLOBAL; /* %-Wert fuer UPE-Pumpe       */  
  DCL UPE_NAME(32)   CHAR(20) GLOBAL; /* Name von UPE-Pumpe          */  
  DCL UPE_TYP(32)       FIXED GLOBAL; /* Typ UPE-Pumpe               */  
  DCL UPE_FRQ(32)       FLOAT GLOBAL; /* el. Frequenz Pumpenmotor    */
  DCL UPE_PDC(32)       FLOAT GLOBAL; /* el. Leistung DC Pumpenmotor */

  DCL B_PUENTLAD       BIT(1) GLOBAL; /* Pufferentladepumpe          */
  DCL Z_SCHORNK(10)    FIXED  GLOBAL; /* >1: Schornsteinfegertest Kessel() */
  DCL Z_SCHORNKMAX(10) FIXED  GLOBAL; /* >1: Schornsteinf. MAX    Kessel() */
  DCL Z_SCHORNB(8)     FIXED  GLOBAL; /* >1: Schornsteinfegertest BHKW()   */
  DCL B_SCHORNGES      BIT(1) GLOBAL; /* 1: irgendein Schornsteinfegertest */
  DCL Z_GFCONTR        FIXED  GLOBAL; /* Kontrollzaehler fuer Grundfos-Task */
  DCL Z_GFCONTR2       FIXED  GLOBAL; /* Kontrollzaehler fuer Grundfos-Task */
  DCL Z_GFNEUST        FIXED  GLOBAL; /* Zaehler fuer Grundfos-Task-Neustart */
  DCL Z_GFNEUST2       FIXED  GLOBAL; /* Zaehler fuer Grundfos-Task-Neustart */
  DCL Z_CAN1CONTR      FIXED  GLOBAL; /* Kontrollzaehler fuer CAN1 Empfangstask */
  DCL Z_CAN1NEUST      FIXED  GLOBAL; /* Zaehler fuer CAN1 Empfangstask-Neustart */
  DCL B_STSAMMGES       BIT(1) GLOBAL; /* Gesamtergebnis von Sammelstoerung */
  DCL Z_HZGFUELL        FIXED  GLOBAL; /* Tageslaufzeitzaehler fuer HZG-Nachspeisung */
  DCL B_HZGFUELL        BIT(1) GLOBAL; /* 1: HZG-Nachspeisung aktiv           */
  DCL Z_MBUS            FIXED  GLOBAL; /* Kontrollzaehler fuer M-Bus Task     */
  DCL Z_MBUSNEUST       FIXED  GLOBAL; /* Zaehler fuer M-Bus Neustart         */
  DCL Z_HKABS           FIXED  GLOBAL; /* Kontrollzaehler fuer HKABS          */
  DCL Z_RAUMABS         FIXED  GLOBAL; /* Kontrollzaehler fuer RAUMABS        */
  DCL Z_TASKCONTR       FIXED  GLOBAL; /* Kontrollzaehler fuer TASKCONTR      */
  DCL Z_PANELPAUS       FIXED  GLOBAL; /* Kontrollzaehler fuer Panel-PC       */
  DCL Z_PANELRESET      FIXED  GLOBAL; /* Zaehler fuer Panel-PC Reset         */
  DCL Z_MODBUS          FIXED  GLOBAL; /* Kontrollzaehler MODBUS              */
  DCL Z_MODBUSNEUST     FIXED  GLOBAL; /* Zaehler fuer MODBUS Neustart        */

  DCL TC_VSOLLEXT( 5)   FLOAT  GLOBAL; /* Unterst. VL-Soll                    */
  DCL TC_VISTEXT ( 5)   FLOAT  GLOBAL; /* Unterst. VL-Ist                     */
  DCL TC_VIST2          FLOAT  GLOBAL; /* 2. Hauptkreis-Temp.                 */
  DCL Z_BWFREIEXT( 5)   FIXED  GLOBAL; /* Unterst. bitte WW-Laden             */
  DCL Z_BWSPAREXT( 5)   FIXED  GLOBAL; /* Unterst. bitte WW-Ladung sparen     */
  DCL Z_BWMOGLEXT( 5)   FIXED  GLOBAL; /* Unterst. bitte WW-Laden             */
  DCL ZT_LASTCAN( 5) FIXED(31) GLOBAL; /* letzte CAN-Meldung Teilnehmer () 1/10s Jahr */
  DCL X_AEINEXT(90, 5)  FLOAT  GLOBAL; /* Uebertragene Daten von UST          */
  DCL FL_AIVIERTEXT(90, 2,15) FLOAT GLOBAL; /* 1/4h Integrator Uebertr. Daten    */
  DCL Z_UCAN( 5)        FIXED  GLOBAL; /* Kontrollzaehler UST                 */
  DCL Z_FREECOUNT(50)   FIXED  GLOBAL; /* Zaehler fuer sonstiges              */
  DCL Z_IND             FIXED  GLOBAL; /* freie Verwendung                    */
  DCL Z_CWSJOY          FIXED  GLOBAL; /* Zaehler JOYSTICK haengt             */
  DCL Z_H0COPY          FIXED  GLOBAL; /* Zaehler Sich BATRAM1 heute          */
  DCL FL_EINSPPRO       FLOAT  GLOBAL; /* akt. Jahr Einspeisung der Stromerzeugung (%) 0-1 */
  
  /*-----------------------------------------------------------------*/
  /* Bedien-Variable  <<<          */
  DCL ME_TEX  (150) CHAR(30) GLOBAL;/* Text des Menuepunkts            */
  DCL ME_POST (150,15) FIXED GLOBAL;/* Zeiger auf Folge-Elemente      */
  DCL ME_PRAE (150)   FIXED GLOBAL; /* Zeiger auf Vorgaenger-Element   */
  DCL ME_POSTMAX INV FIXED GLOBAL INIT(15);/* maximal 15 Folge-Elem. */
  DCL ME_ZALT (150)  FIXED  GLOBAL; /* letzte Zeigerposition des Menus*/
  DCL ME_EBENE(150)  FIXED  GLOBAL; /* Menuebene                      */
  DCL ME_PUNKT(150)  FIXED  GLOBAL; /* Menu fuer TON                  */
  DCL ME_ZEIG (150)  FIXED  GLOBAL; /* Menu fuer TON                  */
  DCL ME_AKTION(150) FIXED  GLOBAL; /* Menu fuer TON                  */
  DCL ME_PUHILF      FIXED  GLOBAL; /* Menu fuer TON                  */
  DCL ME_ZEIGHILF    FIXED  GLOBAL; /* Menu fuer TON                  */
  DCL ME_ZHILF2(150) FIXED  GLOBAL; /* Menu fuer TON                  */
  DCL ME_ZWAHL      FIXED  GLOBAL; /* Zeiger auf Auswahlleiste       */
  DCL ME_INDEX      FIXED  GLOBAL; /* Zeiger fuer Menueinitialisierung */
  DCL ME_ZAEHL      FIXED  GLOBAL; /* Zaehler fuer Sohnelemente (init) */
  DCL ME_EXIT   BIT(1)     GLOBAL; /* Testvariable Schleifenausgang  */
  DCL B_MENU    BIT(1)     GLOBAL; /* 1: Menumodus 0: Anzeigemodus   */
  DCL B_MENUNEU BIT(1)     GLOBAL; /* 1: Menue neu aufbauen           */
  DCL B_KEY     BIT(1)     GLOBAL; /* gueltige Taste betaetigt        */
  DCL B_WEITER  BIT(1)     GLOBAL; /* bei CALL EINGABE keine Taste   */
  DCL B_NEUSEITE BIT(1)    GLOBAL; /* neue Seite wurde angewaehlt     */
  DCL Z_WAIT    FIXED      GLOBAL; /* Wartezeit keine Taste betaetigt*/
  DCL Z_SEITE   FIXED      GLOBAL; /* Seite die angezeigt werden soll*/
  DCL Z_USEITE  FIXED      GLOBAL; /* Unterseite fuer Anzeige         */
  DCL Z_USEITE2 FIXED      GLOBAL; /* Unterseite fuer Anzeige         */
  DCL Z_ZEILE   FIXED      GLOBAL; /* Hilfszeiger fuer DISPLAY Zeile  */
  DCL Z_BLINK   FIXED     GLOBAL;  /* Zaehler fuer Darstellung         */
  DCL B_BLINK   BIT(1)    GLOBAL;  /* Bit fuer blinkende Darstellung  */
  DCL PUNKT          FIXED GLOBAL; /* Zeiger auf aktuellen Menuepunkt */
  DCL ZEIG           FIXED GLOBAL; /* Menue: vertikale Zeigerposition */
  DCL WAHL           FIXED GLOBAL; /* Ausgewaehlter Menuepunkt         */
  DCL WAHLMAX        FIXED GLOBAL; /* Hilfszeiger fuer Auswahl        */
  DCL TX_LEER   CHAR(80)   GLOBAL; /* Zum Zeilen loeschen            */
  DCL TX_TAG(7) CHAR(2)    GLOBAL; /* Mo bis So                      */
  DCL TX_STAT   CHAR(4)    GLOBAL; /* Zustand der Waermeerzeuger      */
  DCL TX_HZKR   CHAR(1)    GLOBAL; /* Zustand des Heizkreises        */
  DCL X_GEHEIM  FIXED      GLOBAL; /* Geheimnummer fuer verschiedenes */
  DCL X_GEHEIMINT  FIXED   GLOBAL; /* Geheimzahl intern              */
  DCL X_GEHEIMEXT  FIXED   GLOBAL; /* Geheimzahl extern (von Master) */
  DCL X_ZUGANG     FIXED   GLOBAL; /* Zugangsberechigung fuer Parameterveraenderungen */
  DCL X_ZUGANGKAL  FIXED   GLOBAL; /* Zugangsberechigung fuer Absenkungskalender      */
  DCL X_R       FIXED      GLOBAL; /* Richtung des Steuerknueppels   */
  DCL K_O INV FIXED GLOBAL INIT(1); /* Wert fuer Taste oben        */
  DCL K_U INV FIXED GLOBAL INIT(2); /* Wert fuer Taste unten       */
  DCL K_L INV FIXED GLOBAL INIT(3); /* Wert fuer Taste links       */
  DCL K_R INV FIXED GLOBAL INIT(4); /* Wert fuer Taste rechts      */
  DCL K_E INV FIXED GLOBAL INIT(5); /* Wert fuer Eingabetaste        */
  DCL B_FUEHL       BIT(1) GLOBAL; /* Mittelwertbildung in AIN EIN/AUS*/
  DCL B_FERN        BIT(1) GLOBAL; /* 1: Fernbedienung EIN           */
  DCL Z_FERN        FIXED  GLOBAL; /* BHKWnr das Fernbedient wird    */
  DCL IND           FIXED  GLOBAL; /* Hilfsvariable Bedienung        */
  DCL CHB(200)   CHAR(30)  GLOBAL; /* Hilfsvariable Bedienung        */
  DCL BUTT       CHAR( 1)  GLOBAL; /* Hilfsvariable fuer Button      */
  DCL B_EINOBJ   BIT(1)    GLOBAL; /* Hilfsvariable fuer Button      */
  DCL B_NOTAUSWAHL BIT(1)  GLOBAL; /* Hilfsvariable fuer Button      */

  /* Variablen fuer Communikation mit BHKW ueber CAN-Bus */
  DCL ID_BBEIN(8)      FIXED GLOBAL;
  DCL ID_PEBSOLL(8)    FIXED GLOBAL;
  DCL ID_BBPNL(8)      FIXED GLOBAL;
  DCL ID_BUHRDAT(8)    FIXED GLOBAL;

  /*-----------------------------------------------------------------*/
  /* MPC-Modulvariable <<< */
  DCL X_F          FIXED  GLOBAL; /* variable Tastaturwiederholrate  */
  DCL TX_REV     CHAR(80) GLOBAL; /* LCD-Attribut reverse            */
  DCL TX_SET     CHAR(51) GLOBAL; /*'CLOCKSET 12:34:56--DATESET 18-02*/
  DCL TX_DATUM   CHAR(10) GLOBAL; /* fuer RTC_TIME                    */
  DCL Z_WATCH       FIXED GLOBAL; /* Zaehlvariable fuer Watchdog       */
  DCL Z_DIN         FIXED GLOBAL; /* Kontrollvar. fuer DIN            */
  DCL Z_BHKWSEND    FIXED GLOBAL; /* Kontrollvar. fuer BHKWSEND       */
  DCL Z_CANIO       FIXED GLOBAL; /* Kontrollvar. fuer CANIOPLAT      */
  DCL Z_BHKWGET     FIXED GLOBAL; /* Kontrollvar. fuer BHKWGET        */
  DCL Z_WATCHDOG FIXED(31) GLOBAL; /* Kontrollvar. fuer Watchdog      */
  DCL STRING      CHAR(1) GLOBAL; /* Variable fuer Joystickeingabe    */
  DCL CHAR40     CHAR(40) GLOBAL; /* Variable fuer Joystickeingabe    */
  DCL X_MERK       FIXED GLOBAL; /* Hilfsv. f. Loeschen der Invers-  */
  DCL Y_MERK       FIXED GLOBAL; /* Darstellung bei Fernbedienung    */
  DCL Z_WATCHEXT   FIXED GLOBAL; /* Zaehlvariable fuer ext. Watchdog   */
  DCL Z_LASTCANERR FIXED(31) GLOBAL; /* Merker in s Steuerungslfz. letzter CAN-Fehler */
  DCL Z_FERNGESENDET FIXED  GLOBAL; /* aktuelle Fernbediennr. auf CAN-Bus */
  DCL Z_FERNEND   FIXED     GLOBAL; /* Fernbedienungsendemeldung von CAN-Bus */
  DCL Z_CANUPD    FIXED     GLOBAL; /* Zaehler fuer Updateanforderung von CAN-Bus */
  DCL YOMIN       FIXED     GLOBAL; /* Merker fuer Display invers  */
  DCL YUMAX       FIXED     GLOBAL; /* Merker fuer Display invers  */
  DCL XLMIN       FIXED     GLOBAL; /* Merker fuer Display invers  */
  DCL XRMAX       FIXED     GLOBAL; /* Merker fuer Display invers  */
  DCL VREFH(2)    FIXED(15) GLOBAL; /* Referenzspannung high in Bit     */ 
  DCL VREFL(2)    FIXED(15) GLOBAL; /* Referenzspannung low in Bit      */   
  DCL VREFM(2)    FIXED(15) GLOBAL; /* Referenzspannung Mitte in Bit    */   
  DCL B_CANREADAKT BIT(1)   GLOBAL; /* 1: CANREAD soll aufs Display schreiben */
  DCL B_TASTATUR   BIT(1)   GLOBAL; /* 1: Eingabe ueber Tastatur bei Fernbedienung */
  DCL B_CANAUS     BIT(1)   GLOBAL; /* 1: Abschaltung 24V CAN-Platinen    */
  DCL Z_RTC        FIXED    GLOBAL; /* >0 Uhrz. wird gestellt, CAN-SEND unterbrechen */
  DCL Z_RTC2       FIXED    GLOBAL; /* Merker fuer woechentliche Zeitkorr. */

  DCL SCHL_STA(10)  CHAR(1)   GLOBAL;  /* Variblen fuer Schleichupdate UST */
  DCL SCHL_BYTE(10) FIXED(31) GLOBAL;  /*   "                              */
  DCL SCHL_CRC (10) FIXED(31) GLOBAL;  /*   "                              */
  DCL SCHL_DOPP(10) FIXED(31) GLOBAL;  /*   "                              */
  DCL SCHL_ERR (10) FIXED(31) GLOBAL;  /*   "                              */
  DCL SCHL_ANZEMPF  FIXED     GLOBAL;  /*   "                              */
  DCL SCHL_DOPPM    FIXED(31) GLOBAL;  /*   "                              */
  DCL SCHL_BYTEM    FIXED(31) GLOBAL;  /*   "                              */
  DCL SCHL_CRCM     FIXED(31) GLOBAL;  /*   "                              */
  
  DCL Z_SERVAKT     FIXED     GLOBAL;  /* Zaehler Empfangsbytes von Server */
  DCL D_SERVDAT(30) FIXED     GLOBAL;  /* Zwischenspeicher Empfangsbytes   */
  DCL B_VISSERV     BIT(1)    GLOBAL;  /* 1: Ausgabe VIS-Daten an Server (ser1) */ 
  DCL B_VISLCD      BIT(1)    GLOBAL;  /* 1: Ausgabe VIS-Daten waehrend Fernbedienung */ 
  DCL B_VISPANEL    BIT(1)    GLOBAL;  /* 1: Ausgabe VIS-Daten an Panel (ser2) */ 
  DCL Z_SERVPAUS    FIXED     GLOBAL;  /* Zaehler wie lange nicht angesprochen */
  
  /* Variablen fuer Idletest mittels Endlosschleife                   */
  DCL B_IDLE    BIT(1) GLOBAL;     /* 1: Idletest eingeschaltet      */
  DCL IT_REST   FLOAT GLOBAL;      /* Freie Rechenzeit in Prozent    */
  DCL IT_COUNT1 FIXED(31) GLOBAL;  /* Zaehlvariable fuer Endlosschleife*/
  DCL IT_COUNT2 FIXED(31) GLOBAL;  /* Zaehlvariable fuer Endlosschleife*/
  DCL IT_COUNT3 FIXED(31) GLOBAL;  /* Zaehlvariable fuer Endlosschleife*/

  /* Variablen fuer die Protokollfunktion                             */
  DCL FL_PROTINT(16) FLOAT GLOBAL; /* Prot.: Integrator Messtelle     */
  DCL Z_PROTART(16) FIXED GLOBAL;  /* Prot.: Art 1:AI 2:AO 3:DI 4:DO  */
  DCL Z_PROTNUM(16) FIXED GLOBAL;  /* Prot.: Ein- Ausgangsnummer      */
  DCL ZF_PROTTAKT  FIXED GLOBAL;  /* Prot.: TaktzÑhlgr. fÅr Zyklisch */
  DCL Z_PROTTAKT   FIXED GLOBAL;  /* Prot.: TaktzÑhler fÅr Zyklisch  */
  DCL Z_PROTWART   FIXED(31) GLOBAL;/* Prot.: Wartezeit bis Start (s)*/
  DCL Z_PROTFUELL  FIXED(31) GLOBAL;/* Prot.: Dateigroesse             */
  DCL B_PROTVOLL   BIT(1) GLOBAL; /* Prot.: 1:Datei voll             */
  DCL B_PROTSPERR  BIT(1) GLOBAL; /* Prot.: 1:Aufzeichnung gesperrt  */
  DCL B_PROTMERK   BIT(1) GLOBAL; /* Prot.: Merker fÅr Zustandsgest. */

  
  /*-----------------------------------------------------------------*/
  /* SONDER-Modulvariablen <<<    */
  DCL N_ZAEHLER      FIXED GLOBAL;     /* Anzahl der Zaehleingaenge    */
  DCL ZP_NAME(150)   CHAR(27) GLOBAL;  /* Zaehlernamen                */
  DCL ZP_EIN(150)    FIXED GLOBAL;     /* Softwarekanaln. des Zaehlers*/
  DCL ZP_TYP(150)    FIXED GLOBAL;     /* Art des Zaehlers            */
  DCL B_DUE2         BIT(1)    GLOBAL; /* 1/4h Uebertragung laeuft DUE3,4,32 */
  DCL DATANZ INV FIXED GLOBAL INIT(300); /* Groesse Datenfeld in Daten  */
  DCL STATJAHR2      FIXED     GLOBAL;  /* Jahreszahl fuer Datenverarbeitung */
  DCL STATMON2       FIXED     GLOBAL;  /* Monatszahl fuer Datenverarbeitung */
  DCL STATDAT2       FIXED     GLOBAL;  /* Datumzahl fuer Datenverarbeitung */
  DCL STATWOTA2      FIXED     GLOBAL;  /* Wochentag fuer Datenverarbeitung */
  DCL MAXDAT         FIXED     GLOBAL;  /* Anzahl genutzter 1/4h-Daten     */
  DCL DATFAKT(300)   FIXED     GLOBAL;  /* Speicherfaktor der 1/4h-Daten 1,10,100 */
  DCL VIERT_NAME(300) CHAR(20)  GLOBAL;  /* Name des Viertelstundenkanals */
  DCL VIERT_EINH(300) CHAR(5)   GLOBAL;  /* Einheit des Viertelstundenkanals */
  DCL Z_GRAPHTAG     FIXED     GLOBAL;  /* Merker fuer Tagesnr graphische Darstellung */
  DCL Z_GRAPHART     FIXED     GLOBAL;  /* Merker fuer Kanal graphische Darstellung */
  DCL TAGDAT(96)     FIXED     GLOBAL;  /* Zwischenspeicher fuer Tagesdaten */
  DCL MON_NAME(60)   CHAR(25)  GLOBAL;  /* Name des Monatskanals         */
  DCL MON_EINH(60)   CHAR(5)   GLOBAL;  /* Einheit des Monatskanals      */
  DCL N_MONZAEHL     FIXED     GLOBAL;  /* Anzahl Monatsz‰hler           */
  
  /*-----------------------------------------------------------------*/
  /* MBUS-Modulvariable <<< */
  DCL ZT_MBUS(32)    FIXED(31) GLOBAL;  /* Jahreszentelsek.stand M-Bus Meldung */
  DCL WTH_MBUS(32)   FLOAT     GLOBAL;  /* WMZ M-Bus                     */
  DCL PTH_MBUS(32)   FLOAT     GLOBAL;  /* Pthermisch M-Bus              */
  DCL WQM_MBUS(32)   FLOAT     GLOBAL;  /* Volumenzaehler M-Bus           */
  DCL DF_MBUS(32)    FLOAT     GLOBAL;  /* Durchfl.   M-Bus              */
  DCL TCV_MBUS(32)   FLOAT     GLOBAL;  /* Vorlauftemp. M-Bus            */
  DCL TCR_MBUS(32)   FLOAT     GLOBAL;  /* Ruecklauftemp. M-Bus           */
  DCL WTH_MBUSMERK(32) FLOAT   GLOBAL;  /* WMZ M-Bus Merker              */
  DCL FL_MBUSVIERT(32,15) FLOAT   GLOBAL;  /* Zwischenspeicher fuer 1/4h Daten */
  DCL Z_MBUSLES      FIXED     GLOBAL;  /* Zaehler Auslesung             */
  DCL B_MBUSLES      BIT(1)    GLOBAL;  /* 1: Auslesung angefordert      */

  /*-----------------------------------------------------------------*/
  /* GRUNDFOS-Modulvariable <<< */
  DCL UPE_FRAG(16)      CHAR(40) GLOBAL;   /* Fragetexte an Pumpen       */
  DCL UPE_ANTW(16)      CHAR(40) GLOBAL;   /* Antworttexte von Pumpen    */
  DCL Z_UPEOK(16)       FIXED GLOBAL;      /* Zaehler Comm OK            */
  DCL Z_UPEERR(16)      FIXED GLOBAL;      /* Zaehler Comm ERR           */
  DCL Z_UPESTAT(16)     FIXED GLOBAL;      /* Status Ser Antwort         */
  DCL Z_UPEANZ(16)      FIXED GLOBAL;      /* Laenge Ser Antwort         */
  
  /*-----------------------------------------------------------------*/
  /* FLAMCO-Modulvariable <<< */
  DCL ZT_FLAMCO      FIXED(31) GLOBAL;  /* Jahreszentelsek.stand Meldung */
  DCL FLAM_DRU       FLOAT     GLOBAL;  /* ANLAGENDRUCK                  */
  DCL Z_FLAMCO       FIXED     GLOBAL; /* Kontrollzaehler fuer FLAMCO Task */
  DCL Z_FLAMCONEUST  FIXED     GLOBAL; /* Zaehler fuer FLAMCO Neustart   */
  DCL B_FLAMCONEUST  BIT(1)    GLOBAL; /* Merker fuer FLAMCO Neustart  */
  
  /*-----------------------------------------------------------------*/
  /* PARAM-Modulvariable <<< */
  DCL B_RAMSPERR  BIT(1) GLOBAL; /* 1: Datensicherung auf R0. gesperrt */
  DCL Z_RAMPAR    FIXED  GLOBAL; /* RAMSCHREIB  Zaehler zur          */ 
  DCL Z_RAMDUE2   FIXED  GLOBAL; /* DUE3,4,32   Koordination         */ 
  DCL Z_RAMSTAT   FIXED  GLOBAL; /* STATISTIK   der Zugriffe         */ 
  DCL Z_RAMSTOER  FIXED  GLOBAL; /* MONSTOER    auf Compact Flash    */ 
  DCL Z_RAMSON    FIXED  GLOBAL; /* andere                           */ 
  DCL B_FLASHMERK BIT(1) GLOBAL; /* Merker fuer Tagesparametersicherung */
  DCL B_FLASHVORH BIT(1) GLOBAL; /* 1: Flashdisk ist vorhanden       */
  /*******************************************************************/
  /* im folgenden sind alle Variablen deklariert die auf der         */
  /* RAM-Disk R0 und auf /H0/BATRAM1 gespeichert werden              */
  /*******************************************************************/

  /* diverse Variablen                                               */
  DCL BI_PARA      BIT(32)  GLOBAL; /* Magic Word                    */
  DCL Z_BETRIEB    FIXED    GLOBAL; /* Betriebsart der Anlage        */
  DCL B_ROTSP      BIT(1)   GLOBAL; /* 1: rote Taste gesperrt        */
  DCL B_WINTER     BIT(1)   GLOBAL; /* 1: Umsch. auf Winterz. erfolgt*/
  DCL ZF_TMESS     FIXED    GLOBAL; /* Steigungsmessintervall        */
  DCL TD_BO        FLOAT    GLOBAL; /* obere BHKW-Abweichung Vorl.so */
  DCL TD_BU        FLOAT    GLOBAL; /* untere BHKW-Abw. Vorlaufsoll  */
  DCL TD_KS        FLOAT    GLOBAL; /* untere Kessel-Abw. Vorlaufso. */
  DCL TC_MAXMIN    FLOAT    GLOBAL; /* Minimale Maximaltemp. (z.B: WW ueberladen) */
  DCL PE_RMIN1B    FLOAT    GLOBAL; /* Minimal beachteter Strombedarf */
  DCL ZF_TAUS      FIXED    GLOBAL; /* Ausschaltzeit BHKW            */
  DCL ZF_T1EIN     FIXED    GLOBAL; /* Einschaltverz. BHKW1 in Min   */
  DCL TD_1EIN      FLOAT    GLOBAL; /* Einschalttempdifferenz BHKW1  */
  DCL Z_KALSEC     FIXED    GLOBAL; /* Zeitkorrektur in SEC pro Woche*/
  DCL Z_RESET      FIXED(31) GLOBAL; /* Resetzaehler                   */
  DCL ZP_SCHANF    CLOCK    GLOBAL; /* Beginn PT_SCHNITT-Berechnung  */
  DCL ZP_SCHEND    CLOCK    GLOBAL; /* Ende PT_SCHNITT-Berechnung    */
  DCL ZP_PUMPSCH   CLOCK    GLOBAL; /* Zeitpunkt Pumpenschonung      */
  DCL PT_SCHNITT   FLOAT    GLOBAL; /* durchschnittl. therm. Leist.  */
  DCL Z_ZAEHL(300) FIXED(31) GLOBAL; /* Zaehler fuer Digitale Eingaenge  */
  DCL FL_IMP(150)     FLOAT  GLOBAL; /* Zaehlerkonst. fÅr Impulszaehler */
  DCL Z_STRMAX(12)    FIXED GLOBAL; /* Viertelstunde Maxbezug        */
  DCL DA_STRMAX(12)   FIXED GLOBAL; /* Datum         Maxbezug        */
  DCL PE_STRMAX(12)   FLOAT GLOBAL; /* Wert          Maxbezug        */
  DCL FL_GASSTOER     FLOAT GLOBAL; /* Stoerschwelle Gassensor       */
  DCL FL_GASWARN      FLOAT GLOBAL; /* Warnschwelle Gassensor        */
  DCL FL_DRWARN       FLOAT GLOBAL; /* Minschwelle HZG-Drucksens     */
  DCL FL_DRMAX        FLOAT GLOBAL; /* Maxschwelle HZG-Drucksens     */
  DCL Z_SYSOUT    FIXED     GLOBAL; /* Ausgabekanal Systemmeldungen  */
  DCL FL_GASHU       FLOAT  GLOBAL; /* unterer Heizwert des Gases    */
  DCL FL_GASHO       FLOAT  GLOBAL; /* oberer Heizwert des Gases     */
  DCL TD_UEBERHEIZ   FLOAT  GLOBAL; /* Ueberheizung Hauptkreis       */
  DCL W_ERZHT     FLOAT(55) GLOBAL;/* Stromerzeugung HT              */
  DCL W_ERZNT     FLOAT(55) GLOBAL;/* Stromerzeugung NT              */
  DCL W_BEDHT     FLOAT(55) GLOBAL;/* Strombedarf    HT              */
  DCL W_BEDNT     FLOAT(55) GLOBAL;/* Strombedarf    NT              */
  DCL W_EINHT     FLOAT(55) GLOBAL;/* Stromeinspeis. HT              */
  DCL W_EINNT     FLOAT(55) GLOBAL;/* Stromeinspeis. NT              */
  DCL W_BEZHT     FLOAT(55) GLOBAL;/* Strombezug     HT              */
  DCL W_BEZNT     FLOAT(55) GLOBAL;/* Strombezug     NT              */
  DCL W_55(10)    FLOAT(55) GLOBAL;/* freie Zaehler                  */
  DCL TX_STOER(25)  CHAR(20) GLOBAL;/* Stoerungstexte                */
  DCL ZT_STOER(25) FIXED(31) GLOBAL;/* Stoerungsdatum + Uhrzeit      */
  DCL ART_STOER(25) FIXED    GLOBAL;/* Stoerungsarten                */

  /* Analogeingangsvariablen                                         */
  DCL FP_ULOW (200) FIXED    GLOBAL; /* Analogein in mV fuer unt. Wert */
  DCL FP_UHIGH(200) FIXED    GLOBAL; /* Analogein in mV fuer ob.  Wert */
  DCL FP_NULL (200) FIXED    GLOBAL; /* Bitanzahl bei unt. Wert       */
  DCL FP_STEIG(200) FLOAT    GLOBAL; /* Steigung in Einheit pro Bit   */
  DCL B_FUEHLWACH(200) BIT(1) GLOBAL; /* 1: Fuehlerueberwachung freigegeben */
  DCL FL_XAEINMAX(201) FLOAT GLOBAL; /* Maximalwert fuer Fuehlerueberwachung */
  DCL FL_XAEINMIN(200) FLOAT GLOBAL; /* Minimalwert fuer Fuehlerueberwachung */

  /* Heizkreisvariablen                                              */
  DCL TD_ABSHK(32) FLOAT    GLOBAL; /* Heizkreisabsenktemperatur     */
  DCL RP_M    (60) FLOAT    GLOBAL; /* Mischerregelung       P       */
  DCL RI_M    (60) FLOAT    GLOBAL; /*                       I       */
  DCL RD_M    (60) FLOAT    GLOBAL; /*   >32: Missbrauch     D       */
  DCL RDI_M   (60) FLOAT    GLOBAL; /*        fuer andere    DI      */
  DCL RTAU_M  (60) FLOAT    GLOBAL; /*        Regler     TAU D       */
  DCL ZUST_HK (32) FIXED    GLOBAL; /* Heizkreisbetriebszustand      */
  DCL P_HKMIN (32) FLOAT    GLOBAL; /* Pumpenmindestdruck            */
  DCL TC_HMT  (32) FLOAT    GLOBAL; /* Heizkreistagheizgrenzen       */
  DCL TC_HMN  (32) FLOAT    GLOBAL; /* Heizkreisnachtheizgrenzen     */
  DCL FL_EXPHK (32) FLOAT   GLOBAL; /* Heizkoerperexponent           */
  DCL TD_HKSPREI(32) FLOAT  GLOBAL; /* Heizkreisistspreizung         */
  DCL TC_HKINENN(32) FLOAT  GLOBAL; /* Heizkreisnennraumtemperatur   */
  DCL TC_HKVMIN(32)  FLOAT  GLOBAL; /* Heizkreismindestvorlauftemp.  */
  DCL TC_HKVNENN(32) FLOAT  GLOBAL; /* Heizkreisnennvorlauftemp.     */
  DCL TC_HKANENN(32) FLOAT  GLOBAL; /* Heizkr.Ausslegungsaussentemp. */
  DCL W_HKTH    (32) FLOAT(55)  GLOBAL; /* thermische Arbeit HKs     */
  DCL TC_HKSTW (32)   FLOAT  GLOBAL; /* Heizkr. VL TH STW            */
  DCL ZF_HKMISTELL(32)FIXED  GLOBAL; /* Mischerstellzeit (s)         */
  DCL HK_NAME  (32) CHAR(20)GLOBAL;/* Name des Heizkreises           */
  DCL FL_SOLLATM10(32)  FLOAT  GLOBAL; /* HK-Pumpensollst. bei -10 Grad */
  DCL FL_SOLLAT5(32)    FLOAT  GLOBAL; /* HK-Pumpensollst. bei   5 Grad */
  DCL FL_SOLLAT20(32)   FLOAT  GLOBAL; /* HK-Pumpensollst. bei  20 Grad */
  DCL TC_TAGSOLL(32)    FLOAT  GLOBAL; /* Sollraumtemp. Tag (HK)        */
  DCL TC_BEREITSOLL(32) FLOAT  GLOBAL; /* Sollraumtemp. bereit (HK)     */
  DCL TC_NACHTSOLL(32)  FLOAT  GLOBAL; /* Sollraumtemp. Nacht (HK)      */
  DCL TD_HKINTMAX(32) FLOAT  GLOBAL; /* langfrist. Integr. MAX          */
  DCL TD_HKINTMIN(32) FLOAT  GLOBAL; /* langfrist. Integr. MIN          */
  DCL F_ESTRICH(32,21)   FLOAT  GLOBAL; /* Verschiedene Pamam: Estrichtrocknung  */
  DCL FL_ATTAU        FLOAT  GLOBAL; /* Tau Glaettung At fuer AT Schnitt (h)  */
  DCL TC_ATTAU        FLOAT  GLOBAL; /* Geglaettete AT               */
  DCL ZF_HKPEXT(32)   FIXED  GLOBAL; /* ext. Eingriff HK-Pumpe        */
  DCL ZF_HKMIEXT(32)  FIXED  GLOBAL; /* ext. Eingriff HK-Mischer      */
  DCL FL_HKEXT(32)    FLOAT  GLOBAL; /* frei (ext. Eingriff)          */

  /* BHKW-Variablen                                                  */
  DCL FS_LBHKW (8)  FIXED   GLOBAL; /* BHKW-Ranfolge                 */
  DCL Z_START  (8)  FIXED(31) GLOBAL; /* BHKW-Startzaehler              */
  DCL XA_BPMP  (8)  FLOAT   GLOBAL; /* Pumpenleistung fuer Spreizung  */
  DCL PE_MAXBHKW(8) FLOAT   GLOBAL; /* Pel Max BHKW                  */
  DCL PE_MINBHKW(8) FLOAT   GLOBAL; /* Pel Min BHKW                  */
  DCL PE_BMINPRO(8) FLOAT   GLOBAL; /* Pel Min erlaubt in % (wg eta) */
  DCL TC_BVLMIN (8) FLOAT   GLOBAL; /* BHKW Mindestvorlauftemp       */
  DCL TC_BHZGVO (8) FLOAT   GLOBAL; /* BHKW Vorlaufthermostat        */
  DCL TC_BHZGRO (8) FLOAT   GLOBAL; /* BHKW Ruecklaufthermostat      */
  DCL B_BERLAUBT(8) BIT(1)  GLOBAL; /* 1: BHKW freigegeben           */
  DCL ZF_BPNL(8)    FIXED   GLOBAL; /* Pumpennachlaufzeit BHKW (s)   */
  DCL Z_BLAUFZ(20,13) FIXED(31) GLOBAL;/*  Laufzeitmerker     BHKW     */
  DCL ZP_BAUS(20,13)  CLOCK   GLOBAL; /*  Abschaltzeitmerker  BHKW     */
  DCL DAT_BAUS(20,13) FIXED   GLOBAL; /*  Abschaltdatummerker BHKW     */
  DCL FL_BLFZGESHZG(20) FLOAT(55) GLOBAL; /* BHKW-Gesamtlfz Heizungsst. (h) */
  DCL FL_BKWHGESHZG(20) FLOAT(55) GLOBAL; /* BHKW-Gesamterzeugung in kWh (HZG) */
  DCL TC_BRMIN      FLOAT   GLOBAL; /* BHKW-Mindestruecklauftemp.     */
  DCL TD_BHZGSOLL   FLOAT   GLOBAL; /* BHKW-HZG-Sollspreizung        */
  DCL STR_AUS(20,13)    CHAR(16) GLOBAL; /* Abschaltgrundmerker BHKW    */
  DCL FL_BLFZWART(8)    FLOAT(55) GLOBAL; /* BHKW-Wartungs-Laufzeit     (h) */
  DCL FL_BLFZWARTINT(8) FLOAT(55) GLOBAL; /* BHKW-Wartungsintervall     (h) */
  DCL B_FSLBHKWAUTO     BIT(1)    GLOBAL; /* 1: autom. Sortierung BHKWs     */
  DCL ZF_STARTMAX       FIXED     GLOBAL; /* Warn. bei Starts > (in 24h)   */
  DCL ZF_BEINEXT( 8) FIXED  GLOBAL; /* frei (ext. Eingriff)          */
                               
  /* Kesselvariablen                                                 */
  DCL FS_LKES  (10)  FIXED   GLOBAL; /* Kesselrangfolge               */
  DCL RP_K     (10)  FLOAT   GLOBAL; /* Kesselleistungsregelung  P    */
  DCL RI_K     (10)  FLOAT   GLOBAL; /*                          I    */
  DCL RD_K     (10)  FLOAT   GLOBAL; /*                          D    */
  DCL RDI_K    (10)  FLOAT   GLOBAL; /*                         DI    */
  DCL RTAU_K   (10)  FLOAT   GLOBAL; /*                      TAU D    */
  DCL RP_KP    (10)  FLOAT   GLOBAL; /* KesselPumpenregelung     P    */
  DCL RI_KP    (10)  FLOAT   GLOBAL; /*                          I    */
  DCL RD_KP    (10)  FLOAT   GLOBAL; /*                          D    */
  DCL RDI_KP   (10)  FLOAT   GLOBAL; /*                         DI    */
  DCL RTAU_KP  (10)  FLOAT   GLOBAL; /*                      TAU D    */
  DCL FL_KWART (10)  FLOAT   GLOBAL; /* Kesselstoerungsverz. in MIN    */
  DCL TD_KMIN  (10)  FLOAT   GLOBAL; /* Kesselmindestspr. nach Verz.  */
  DCL PT_KES   (10)  FLOAT   GLOBAL; /* thermische Kesselleistungen   */
  DCL Z_KLAUFZ(10,13) FIXED(31) GLOBAL; /*  Laufzeitmerker   Kessel   */
  DCL ZP_KAUS(10,13) CLOCK   GLOBAL; /*  Abschaltzeitmerker  Kessel   */
  DCL DAT_KAUS(10,13) FIXED  GLOBAL; /*  Abschaltdatummerker Kessel   */
  DCL ZF_KPNL  (10)  FIXED  GLOBAL; /* Pumpennachlauf (s)            */
  DCL ZF_KWARML(10)  FIXED  GLOBAL; /* Kesselwarmlaufzeit (s)        */
  DCL ZF_KSTELL(10)  FIXED  GLOBAL; /* Kesselbrennerstellzeit (s)    */
  DCL TC_KRMIN (10)  FLOAT  GLOBAL; /* Kesselmindestruecklauftemp.   */
  DCL TC_KVMAX (10)  FLOAT  GLOBAL; /* Kessel-MAX-VL-Temp.           */
  DCL TD_KVLPLUS(10) FLOAT  GLOBAL; /* KesselVL-Soll-Ueberhoehung    */
  DCL TD_KMAX   (10) FLOAT  GLOBAL; /* Kessel-Max-erlaubte Spreizung */
  DCL X_AAKMIN  (10) FLOAT  GLOBAL; /* Mindest AA bei Kesselbetrieb  */
  DCL Z_KESLFZ (10)  FIXED(31) GLOBAL; /* Kessellaufzeit in s         */
  DCL Z_KSTART (10)  FIXED(31) GLOBAL; /* Kesselstarts                */
  DCL B_KERLAUBT(10) BIT(1)    GLOBAL; /* 1: Kessel freigegeben           */
  DCL B_FSLKESAUTO   BIT(1)    GLOBAL; /* 1: autom. Sortierung Kessel */
  DCL B_PMPVORL      BIT(1)    GLOBAL; /* 1: Pumpenvorlauf erlaubt    */
  DCL ZF_KEINEXT(10) FIXED  GLOBAL; /* ext. Eingriff Kessel-Betrieb  */
  DCL ZF_KPMPEXT(10) FIXED  GLOBAL; /* ext. Eingriff Kessel-Pumpe    */

  /* Brauchwasservariablen                                           */
  DCL TC_BWSOLL(10)  FLOAT   GLOBAL; /* Brauchwassersolltemperatur    */
  DCL TC_BWZRSOLL(10)FLOAT   GLOBAL; /* BW-Zirkulationsruecklaufsoll   */
  DCL TC_BOMAX (10)  FLOAT   GLOBAL; /* max. erl. obere Speichertemp. */
  DCL TD_BWNORM(10)  FLOAT   GLOBAL; /* Grenze zum normal Laden       */
  DCL TD_BWDRIG(10)  FLOAT   GLOBAL; /* Grenze zum dringen Laden      */
  DCL TD_BWB   (10)  FLOAT   GLOBAL; /* Hysterese zum Ausschalten     */
  DCL TD_BWTW  (10)  FLOAT   GLOBAL; /* Speisesolldifferenz aussen WT */
  DCL TD_BWTOO (10)  FLOAT   GLOBAL; /* Start WW-Lad wenn VL > Sp o + TD_BWTOO     */
  DCL TD_BWTOU (10)  FLOAT   GLOBAL; /* Stop WW-Lad wenn  VL < Sp o + TD_BWTOU     */
  DCL TD_BWLS  (10)  FLOAT   GLOBAL; /* VL-Soll Ueberhoehung          */
  DCL TC_BWMIN (10)  FLOAT   GLOBAL; /* Brauchwassermindesttemp.      */
  DCL TC_LEGIO (10)  FLOAT   GLOBAL; /* Sollwert bei Legionellenkill   */
  DCL RP_BWL   (10)  FLOAT   GLOBAL; /* Lade/Speise-PMP-Regelung P    */
  DCL RI_BWL   (10)  FLOAT   GLOBAL; /*                          I    */
  DCL RD_BWL   (10)  FLOAT   GLOBAL; /*                          D    */
  DCL TC_BWRSOLL(10) FLOAT   GLOBAL; /* Lade RL Soll                  */
  DCL RP_WWZ   (10)  FLOAT   GLOBAL; /* Zirk-Pumpenregelung      P    */
  DCL RI_WWZ   (10)  FLOAT   GLOBAL; /*                          I    */
  DCL RD_WWZ   (10)  FLOAT   GLOBAL; /*                          D    */
  DCL RDI_WWZ  (10)  FLOAT   GLOBAL; /*                         DI    */
  DCL RTAU_WWZ (10)  FLOAT   GLOBAL; /*                      TAU D    */
  DCL RP_WWL   (10)  FLOAT   GLOBAL; /* Lade-Pumpenregelung      P    */
  DCL RI_WWL   (10)  FLOAT   GLOBAL; /*  (ev. auch mit Mischer)  I    */
  DCL RD_WWL   (10)  FLOAT   GLOBAL; /*                          D    */
  DCL RDI_WWL  (10)  FLOAT   GLOBAL; /*                         DI    */
  DCL RTAU_WWL (10)  FLOAT   GLOBAL; /*                      TAU D    */
  DCL ZF_LMISTELL(10)FIXED   GLOBAL; /* Lademischerstellzeit (s)      */
  DCL ZF_WWMI  (10)  FIXED   GLOBAL; /* 0: Mi nicht nutzen  1: Mi nutzen  2: Mi 2s  */

  /* Softwarehandschalter                                             */
  DCL BI_ON   (20)  BIT(16) GLOBAL; /* Bits logische Verknuepfungen   */
  DCL BI_OFF  (20)  BIT(16) GLOBAL; /* fuer Softwarehandschalter      */
  DCL Z_DOHAND(160) FIXED   GLOBAL; /* Zaehler fuer Handb. Digitalausgang  */
  DCL Z_DIBEWERT(150) FIXED GLOBAL; /* Bewertung Digitaleingaenge 1: normal 2: getoggelt 3: EINS 4: NULL */

  /* Variablen fuer die Analogausg{nge                                */
  DCL AP_ULOW (60)  FLOAT   GLOBAL; /* Analogspannung bei 0% Soll    */
  DCL AP_UHIGH(60)  FLOAT   GLOBAL; /* Analogspannung bei 100% Soll  */
  DCL X_AHAND (60)  FLOAT   GLOBAL; /* Analogspannung bei Handb. in% */
  DCL Z_AAUTO (60)  FIXED   GLOBAL; /* 1: Auto 2: Hand n. Wert 3: Hand + Ausg. */
  DCL X_AAUSMIN(60) FLOAT   GLOBAL; /* Mindestwert Analogausgang()   */  
  DCL X_AAUSMAX(60) FLOAT   GLOBAL; /* Maximalwert Analogausgang()   */  
  DCL X_PWMHAND(20) FLOAT   GLOBAL; /* PWM Ausgang bei Handb. in%    */
  DCL Z_PWMAUTO(20) FIXED   GLOBAL; /* 1: Auto 2: Hand n. Wert 3: Hand + Ausg. */
  DCL X_PWMMIN(20)  FLOAT   GLOBAL; /* Mindestwert PWMausgang()      */  
  DCL X_PWMMAX(20)  FLOAT   GLOBAL; /* Maximalwert PWMausgang()      */  

  /* Wochenabsenkungs- und Timerkalender und Jahreskalender          */
  DCL B_ZONE1(4,1008) BIT(16) GLOBAL; /* Bitfeld fuer 64 Wochentimer */
  DCL B_JAHRAB(12,31) BIT(32) GLOBAL; /* Jahreskalender              */

  /* <<< Anlagenspezifisches                                         */
  DCL IDBATRAM     CHAR(46) GLOBAL; /* Steuerungsidentifier auf      */
                                    /* Ramdisk -> muss an dieser     */
                                    /* Position stehenbleiben        */
                                    /* Spaetere Aenderungen koennen  */
                                    /* ab hier gemacht werden        */
  DCL B_UPEHAND(32)       BIT(1) GLOBAL; /* 1: UPE-Pumpe im Handbetr.   */
  DCL Z_UPEKOMMAND(32)     FIXED GLOBAL; /* Kommando UPE-Pumpe          */
  DCL Z_UPESOLLHAND(32)    FIXED GLOBAL; /* Handsollstufe UPE-Pumpe     */
  DCL UPE_PRESSSCALE(32) FLOAT GLOBAL; /* Skalierungsfaktor Pumpendruck */
  DCL UPE_FLOWSCALE(32)  FLOAT GLOBAL; /* Skalierungsfaktor Pumpendurchfl. */
  DCL UPE_TEMPSCALE(32)  FLOAT GLOBAL; /* Skalierungsfaktor Wassertemp. */
  DCL UPE_FRQSCALE(32)   FLOAT GLOBAL; /* Skalierungsfaktor PMP-Motorfrequenz */
  DCL UPE_PDCSCALE(32)   FLOAT GLOBAL; /* Skalierungsfaktor PMP-Pel     */
  DCL UPE_FREIG(32)      FIXED GLOBAL; /* >0: Kommunikationfreig. UPE-Pumpe */
  DCL UPE_KENN(32,5)     FLOAT GLOBAL; /* Feld fuer Pumpenkennlinien     */
  DCL UPE_EXT(32)        FIXED GLOBAL; /* frei (ext. Einfluss)              */
  DCL ZF_STOERDRIG(200) FIXED  GLOBAL; /* >0: Stoerungsm. I dringend     */
  DCL ZF_STOERFREI(200) FIXED  GLOBAL; /* 1: FREI  2: KEINE MELDUNG  3: KEINE STOERUNG */
  DCL B_STSAMMFREI(200)  BIT(1) GLOBAL; /* 1: Stoerung gehoert zu Sammelstoerung  */
  DCL MARKOW(100,5)     FLOAT   GLOBAL; /* Markowmatrize (erstmal frei) */
  DCL IDSTRING2         CHAR(20) GLOBAL; /* Erkennungsstring Steuerung (erstmal frei)   */
  DCL FL_ZEITZAEHL      FLOAT   GLOBAL; /* ZÑhler fÅr wîch. Uhrzeitkorr. */  
  DCL NAMESTR(10)      CHAR(34) GLOBAL;/* Bedienername Anruferliste      */
  DCL DA_DATCALL(10)   FIXED    GLOBAL;/* Datum Anruferliste             */
  DCL DA_MONCALL(10)   FIXED    GLOBAL;/* Monat Anruferliste             */
  DCL ZP_CALL(10)      CLOCK    GLOBAL;/* Uhrzeit Anruferliste           */
  DCL ZF_WTAUP        FIXED     GLOBAL; /* Zyklus Regelung Nahwaermepmp   */
  DCL ANZ_SLAVE       FIXED     GLOBAL; /* SCHLEICHUPDATE  Anzahl Slaves */
  DCL VERZ_SLAVE      FIXED     GLOBAL; /* SCHLEICHUPDATE  Verzoegerung bei Uebertragung (ms) */
  DCL FL_HZGFUEEIN      FLOAT     GLOBAL; /* Heizungsdruck unterhalb dem Nachfuellung eingeschaltet wird */
  DCL FL_HZGFUEAUS      FLOAT     GLOBAL; /* Heizungsdruck oberhalb dem Nachfuellung ausgeschaltet wird */
  DCL ZF_HZGFUELL       FIXED     GLOBAL; /* erlaubte Tageslaufzeit fuer Wassernachfuellung in s */
  DCL MON_ZAEHL(99,12)  FLOAT     GLOBAL; /* Monatszaehlerstaende           */
  DCL AT_MON   ( 2,12)  FLOAT     GLOBAL; /* Monats Aussentemp Schnitt    */
  DCL MON_ZAEHLJAN(200) FLOAT     GLOBAL; /* Monatszaehlerstaende alter Januar */
  DCL JAHR_ZAEHL(99,8)  FLOAT     GLOBAL; /* Jahreszaehlerstaende           */
  DCL WIRT_ZAEHL(6,15)  FLOAT(55) GLOBAL; /* Zaehlerstaende Wirtschaftl. ETW */
  DCL FL_GASCENTPROKWH  FLOAT     GLOBAL; /* Gaspreis ETW                 */
  DCL Z_WAERMEBHKW      FIXED     GLOBAL; /* 1: SOFT BHKW  2: SOFTWMZ ETW */
  DCL POSWTH(99)        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  DCL POSPTH(99)        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  DCL POSWQM(99)        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  DCL POSDF(99)         FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  DCL POSTCV(99)        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  DCL POSTCR(99)        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  DCL POSFIX(99)        FIXED     GLOBAL; /* Position MBUS-Protokoll      */
  DCL ZF_MBUSLES        FIXED     GLOBAL; /* MBUS-Auslesung Zyklus(s)     */
  DCL ZF_TASTVERZ       FIXED     GLOBAL; /* Verzoegerung Tastatur(s)     */
  DCL ZF_STOERMAX24     FIXED     GLOBAL; /* max. Stoerung() in 24h       */

  DCL DUMMYP(20)      FIXED  GLOBAL; /* nicht zur Verwendung          */

