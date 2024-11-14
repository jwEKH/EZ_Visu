/*********************************************************************/
/*                  Heizungssteuerungsmodul                13.07.22  */
/* MPC: Ein und Ausgabe, AD-Wandlung, RTC, Watchdog                  */
/* Stand: 13.07.22          'BIOGASANLAGE DRALLE  HOHNE              */
/* spezifische Anpassungen der Module durch "<<<" gekennzeichnet     */
/*********************************************************************/

P=MPC604+FPU(4);

/*SC=5A000 ,CODE=$0000 ,VAR=$0000; /**/
  SC=50000;  /* */

MODULE MPC;
/* Compileroptionen einstellen: */;
/*-L Listing PEARL-Compiler     */;
/*-B Big Module                 */;
/*+M Markierung Zeilennummer    */;
/*+T Test auf Feldgrenzen       */;
/*-P Protokoll Hyperproc Code   */;

SYSTEM;
  TAST:     C2 (TFU=1,AI=$3A00) <-> ;  /* Tastatur Panel               <<<< FUER PANEL    */
  A1:       A1.            ->;         /* Testausgaben ins nichts      <<<< FUER PANEL    */
  A12:      A1.            ->;         /* Testausgaben2                                   */
  SLNUM:    ED.slnum      <->;     /* Editordatei Slavenummer        */
  TEST:     ED.TEST       <->;     /* Editordatei                    */
  MIST:     ED.MIST   (NE) <->;    /* Editordatei                    */
  MIST2:    ED.MIST2  (NE) <->;    /* Editordatei                    */
  FEHLER:   ED.FEHLER (NE) <->;    /* Editordatei                    */
! PROT:     LD/3,0/.PROT (NE) <->; /* Protokolldatei auf h0.         */
! FEHL2:    LD/3,0/.FEHLER (NE) <->;/* h0-Datei fuer Fehlermeldungen */
! BATRAM:   LD/124,0/.BATRAMX    <->; /* Parameterdatei auf Rmdisk      */
! TEMP:     LD/124,1/.TEMP       <->; /* temporaere Datei auf Ramdisk   */
! DATEN:    LD/3,0/.DATEN <->;     /* H0-Datei fuer Betriebsdaten   */
! INFO:     LD/3,0/.INFO    <->;   /* H0-Datei fuer Notizen             */
! MONPROT:  LD/3,0/.MONPXX <->;    /* H0-Dateien fuer Langzeitmeldeprotokoll */
  PROT:     H0.PROT (NE) <->; /* Protokolldatei auf h0.         */
  FEHL2:    H0.FEHLER (NE) <->;/* h0-Datei fuer Fehlermeldungen */
  BATRAM:   RD.BATRAMX    <->; /* Parameterdatei auf Rmdisk      */
  TEMP:     RD02.TEMP       <->; /* temporaere Datei auf Ramdisk   */
  DATEN:    H0.DATEN <->;     /* H0-Datei fuer Betriebsdaten   */
  INFO:     H0.INFO    <->;   /* H0-Datei fuer Notizen             */
  MONPROT:  H0.MONPXX <->;    /* H0-Dateien fuer Langzeitmeldeprotokoll */
  MIN1WERT: H0/MIN1WERT/XXXXXXXX.XXX (NE) <->; /* H0-Dateien fuer 1MIN csv Dateien */
  MONLES:   ED.MONLES <->;         /* Editor-Datei fuer Langzeitmeldeprotokoll */
  SLAVE:    H0.slave  <->;         /* H0-Datei fuer SLAVE-UPDATE      */
  TERM:     B1.(TFU=1) <->;        /* Terminal                        */
  VIERTOUT: B1.(TFU=1)  ->;        /* Ausgang 1/4h Uebertragung          */
  VIERTIN:  B1.(TFU=1,NE,AI=$3A83) <-; /* Eingang 1/4h Uebertragung      */
  TASTVIERT: C2 (TFU=1,AI=$3A00) <->;  /* C-Eingang fuer 1/4h            */
  TAST2:    C2 (TFU=1,AI=$3A00) <->;   /* Tastatureingang fuer Fernbed.  */
  TAST1:    C1 (TFU=1,AI=$3A00) <->;   /* Eingang Ser1 fuer Server       */
  RTOS:     XC             ->;     /* Bedieninterface                */
  XC:       XC             ->;     /* Bedieninterface                */
  BTASTIN:  B1.(NE)       <-> ;    /* Eingang Bedienung Tastatureingabe */
  A2:       A2.            ->;     /* Ausgabe ser2 an PANEL    */
  SERV:     B1.(TFU=1) <->;        /* Ausgabe an Server        */

  RIM:       /RIM;
  CRIM:      /CRIM;
  MY_RIM:    /NIL  ->;
  CAN_RIM:   /NIL  ->;
  STOER_RIM: /NIL  ->;
  LCD:       /NIL  ->;

   MTY :  A1. ;
   MTY1:  A1.(TFU=1) ;
   MTYC1: C1.(TFU=1) ;

  ETH_ADDR: LD/16,10/.ETH_ADR (NE) ;
  ETH_SET : LD/17,2/STOP_NN (NE) ;
  EV_BFVS:   EV(00100000) ;
  EV_VSYNC:  EV(00010000) ;



PROBLEM;
  SPC TAST                          DATION IN    ALPHIC CONTROL(ALL);
  SPC A1                            DATION   OUT ALPHIC CONTROL(ALL);
  SPC A12                           DATION   OUT ALPHIC CONTROL(ALL);
  SPC SLNUM                         DATION INOUT ALPHIC CONTROL(ALL);
  SPC TEST                          DATION INOUT ALPHIC CONTROL(ALL);
  SPC MIST                          DATION INOUT ALPHIC CONTROL(ALL);  
  SPC MIST2                         DATION INOUT ALPHIC CONTROL(ALL);  
  SPC FEHLER                        DATION INOUT ALPHIC CONTROL(ALL);
  SPC PROT                          DATION INOUT ALPHIC CONTROL(ALL);
  SPC FEHL2                         DATION INOUT ALPHIC CONTROL(ALL);
  SPC BATRAM                        DATION INOUT ALPHIC CONTROL(ALL);
  SPC TEMP                          DATION INOUT ALPHIC CONTROL(ALL);
  SPC DATEN                         DATION INOUT ALPHIC CONTROL(ALL);
  SPC INFO                          DATION INOUT ALPHIC CONTROL(ALL);
  SPC MONPROT                       DATION INOUT ALPHIC CONTROL(ALL);
  SPC MIN1WERT                      DATION INOUT ALPHIC CONTROL(ALL);
  SPC MONLES                        DATION INOUT ALPHIC CONTROL(ALL);
  SPC SLAVE                         DATION INOUT ALPHIC CONTROL(ALL);
  SPC TERM                          DATION INOUT ALPHIC CONTROL(ALL);
  SPC VIERTOUT                      DATION   OUT ALPHIC CONTROL(ALL);
  SPC VIERTIN                       DATION IN    ALPHIC CONTROL(ALL);
  SPC TASTVIERT                     DATION INOUT ALPHIC CONTROL(ALL);
  SPC TAST2                         DATION INOUT ALPHIC CONTROL(ALL);
  SPC TAST1                         DATION INOUT ALPHIC CONTROL(ALL);
  SPC RTOS                          DATION   OUT ALPHIC CONTROL(ALL);
  SPC XC                            DATION   OUT ALPHIC CONTROL(ALL);
  SPC BTASTIN                       DATION INOUT ALPHIC CONTROL(ALL);
  SPC A2                            DATION   OUT ALPHIC CONTROL(ALL);
  SPC SERV                          DATION   OUT ALPHIC CONTROL(ALL);

  SPC RIM       DATION IN    ALPHIC;
  SPC CRIM      DATION IN    ALPHIC;
  SPC MY_RIM    DATION   OUT ALPHIC;
  SPC CAN_RIM   DATION   OUT ALPHIC;
  SPC STOER_RIM DATION   OUT ALPHIC;
  SPC LCD       DATION   OUT ALPHIC;

   SPC MTY                           DATION   OUT ALPHIC CONTROL(ALL);

  SPC EV_BFVS    INTERRUPT ;
  SPC EV_VSYNC   INTERRUPT ;
  SPC ETH_ADDR  DATION IN ALPHIC CONTROL(ALL) ;
  SPC ETH_SET  DATION OUT ALPHIC CONTROL(ALL) ;


/* Tasks */
  SPC NAHBED     TASK;        /* Umschalten auf Nahbedienung         */
  SPC SERTAST    TASK;        /* Abfrage der seriellen Schnittstelle */
  SPC SERTAST1   TASK;        /* Abfrage der seriellen Schnittstelle 1 */
  SPC DIN        TASK;        /* Digitaleingangstask                 */
  SPC WATCHDOG   TASK;        /* Watchdogtask                        */
  SPC IT_LOOP    TASK;        /* Restkapazit{tsmessung               */
  SPC CANREAD    TASK;        /* Empfangstask CAN-Fernbedienung      */
  SPC JOYSTICK   TASK;        /* Task zur Tastaturausleseung         */
  SPC VISUAL     TASK GLOBAL; /* Visualisierung                       */
  SPC RAMLES     TASK GLOBAL; /* gepufferte Variablen von H0. lesen    */
  SPC RAMSCHREIB TASK GLOBAL; /* beschreiben von H0. mit Parametern  */
  SPC I_DISP     TASK GLOBAL; /* Umschalten von Fern- auf Nahbed.    */
  SPC DISPLAY    TASK GLOBAL; /* Umschalten von Fern- auf Nahbed.    */
  SPC MENU       TASK GLOBAL; /* Umschalten von Fern- auf Nahbed.    */
  SPC ENDE       TASK GLOBAL; /* Geheimzahl auf Null stellen         */
  SPC START      TASK GLOBAL; /* Starttask in HAUPT                  */

/* Prozeduren */
  SPC ROUNDLG   ENTRY (FLOAT(55)) RETURNS(FIXED(31)) GLOBAL; /* runden von Gleitkommazahlen > 32768 */
  SPC RTC_DATUM ENTRY;       /* Datum aus Echtzeituhr lesen          */
  SPC STICK     ENTRY;        /* Auswertung des Steuerkn}ppels        */
  SPC D_CLR     ENTRY;        /* L|schen des Bildschirms              */
  SPC D_CS      ENTRY (FIXED, FIXED);        /* Cursorpositionierung                 */
  SPC D_GRAPHCLR  ENTRY;     /* LCD Graphik l|schen                  */
  SPC D_ROFF      ENTRY;     /* LCD Invers AUS                       */
  SPC D_RON       ENTRY;     /* Reverse an           */
  SPC DIGOUT      ENTRY;     /* Digitaldaten ausgeben               */
  SPC TAGESNR   ENTRY (FIXED, FIXED, FIXED) RETURNS(FIXED) GLOBAL;/* Tagesnummer berechnen  */
  SPC INP_RTC   ENTRY GLOBAL; /* Eingabe der aktuellen Uhrzeit (DISP) */
  SPC STOERMELD ENTRY (FIXED, CHAR(20)) GLOBAL; /* Prozedur fuer Stoerungsmeldung        */
  SPC FIXGRENZ  ENTRY (FIXED, FIXED, FIXED IDENT) GLOBAL; /* Fixwert begrenzen         */
  SPC FLOGRENZ  ENTRY (FLOAT, FLOAT, FLOAT IDENT) GLOBAL; /* Floatwert begrenzen       */
  SPC ANZ_AUS   ENTRY GLOBAL;
  SPC QUITTIER  ENTRY GLOBAL;
  SPC DATE      ENTRY RETURNS(CHAR(10)) GLOBAL;/* Datumsfunktion      */
  SPC CMD_EXW   ENTRY (CHAR(255)) RETURNS (BIT( 1)) GLOBAL; /* Bedieni.*/
  SPC TASKST    ENTRY (CHAR(24)) RETURNS (BIT(32)) GLOBAL; /* Status? */
  SPC (READ,WRITE) ENTRY GLOBAL; /* Schreib- und Leseproceduren      */
  SPC SET_DATION ENTRY (DATION INOUT ALPHIC IDENT, CHAR(128)) GLOBAL;
  SPC CLEAR     ENTRY GLOBAL ;
  SPC BOX_FILLED ENTRY( FIXED(15), FIXED(15), FIXED(15), FIXED(15), FIXED(15) ) GLOBAL ;
  SPC DISPLAY_MODE ENTRY( FIXED(31) ) GLOBAL ;
  SPC PLINIT    ENTRY GLOBAL ;
  SPC SETPRI    ENTRY(FIXED) RETURNS(FIXED) GLOBAL;
  SPC RANF      ENTRY( FIXED(31) IDENT, FIXED(31) IDENT) RETURNS(FLOAT(23)) GLOBAL ;
  SPC DUE32         ENTRY GLOBAL; 
  SPC VISTEXTFELD   ENTRY GLOBAL; 
  SPC INP_ABS     ENTRY (FIXED, FIXED) GLOBAL;  /* Wochenkalender                   */

  DCL MAX_DA_CHANNEL INV FIXED INIT( 8) ;
  DCL MAX_AD_CHANNEL INV FIXED INIT(16) ;

  TYPE  dac_type STRUCT[ c( MAX_DA_CHANNEL )  BIT(16)] ; 
  TYPE  adc_type STRUCT[ c( MAX_AD_CHANNEL ) BIT(16)] ; 

  SPC SPI_GET_DO_ERR  ENTRY RETURNS( BIT(16) ) GLOBAL ;
  SPC SPI_SET_HUPE ENTRY( onoff FIXED(15) ) GLOBAL ;
  SPC SPI_RW_DIO ENTRY( value BIT(32) ) RETURNS( BIT(32) ) GLOBAL ;
  SPC SPI_READ_DIO ENTRY RETURNS( BIT(32) ) GLOBAL ;
  SPC SPI_WRITE_DAC ENTRY( val REF dac_type ) GLOBAL  ;
  SPC SPI_READ_ADC1 ENTRY( val REF adc_type )  GLOBAL ;
  SPC SPI_READ_ADC2 ENTRY( val REF adc_type )  GLOBAL ;

  SPC SPI_TX_SERIELL ENTRY( chan FIXED , len FIXED , REF CHAR(1) ) GLOBAL ;
  SPC SPI_RX_SERIELL ENTRY( chan FIXED , maxlen FIXED , REF CHAR(1) ) RETURNS( FIXED ) GLOBAL ;
  SPC SPI_WAIT_SERIELL ENTRY( chan FIXED , timeout DURATION ) RETURNS( FIXED ) GLOBAL ;
  SPC SPI_LEN_SERIELL ENTRY( chan FIXED ) RETURNS( FIXED ) GLOBAL ;
  SPC SPI_SETUP_SERIELL ENTRY( chan FIXED , baud FIXED(31) , conf REF CHAR(3) ) RETURNS( FIXED ) GLOBAL ;

/* CAN- Vereinbarungen                                               */

  TYPE CAN_CHAR STRUCT
  [
     identifier  FIXED(31) ,
     frame_format FIXED(15),
     rtr         FIXED(15) ,
     data_length FIXED(15) ,
     data1       CHAR(1),   
     data2       CHAR(1),   
     data3       CHAR(1),   
     data4       CHAR(1),   
     data5       CHAR(1),   
     data6       CHAR(1),   
     data7       CHAR(1),   
     data8       CHAR(1)    
  ];
  
  TYPE CAN_BIT STRUCT
  [
     identifier  FIXED(31) ,
     frame_format FIXED(15),
     rtr         FIXED(15) ,
     data_length FIXED(15) ,
     data1       BIT(1) ,
     data2       BIT(1) ,
     data3       BIT(1) ,
     data4       BIT(1) 
  ];
  
  TYPE CAN_FIXED STRUCT
  [
     identifier  FIXED(31) ,
     frame_format FIXED(15),
     rtr         FIXED(15) ,
     data_length FIXED(15) ,
     data1       FIXED(15) ,
     data2       FIXED(15) ,
     data3       FIXED(15) ,
     data4       FIXED(15) 
  ];
  
  TYPE CAN_LONG STRUCT
  [
     identifier  FIXED(31) ,
     frame_format FIXED(15),
     rtr         FIXED(15) ,
     data_length FIXED(15) ,
     data1       FIXED(31) ,
     data2       FIXED(31) 
  ];
  
  TYPE CAN_FLOAT STRUCT
  [
     identifier  FIXED(31) ,
     frame_format FIXED(15),
     rtr         FIXED(15) ,
     data_length FIXED(15) ,
     data1       FLOAT(23) ,
     data2       FLOAT(23) 
  ];
  
  
  TYPE can_init STRUCT
  [
     can_clock   FIXED(31),
     phase_seg1  FIXED(15),
     phase_seg2  FIXED(15),
     samp        FIXED(15), 
     sjw         FIXED(15), 
     baudrate    FIXED(15), 
     anz         FIXED(15) 
  ] ;
  
  TYPE VOID REF STRUCT[];
  

  SPC CAN_INIT           ENTRY( /*can_nr*/ FIXED(15), can_init IDENT ) RETURNS( FIXED(15) ) GLOBAL ;
  SPC CAN_READ           ENTRY( /*can_nr*/ FIXED(15), CAN_CHAR IDENT ) RETURNS( FIXED(15) ) GLOBAL ;
  SPC CAN_WRITE          ENTRY( /*can_nr*/ FIXED(15), FIXED(31) IDENT ) RETURNS( FIXED(15) ) GLOBAL ;
  SPC CAN_NR_OF_MESSAGES ENTRY( /*can_nr*/ FIXED(15), FIXED(15) IDENT ) RETURNS( FIXED(15) ) GLOBAL ;
  SPC CAN_SET_TIMEOUT    ENTRY( /*can_nr*/ FIXED(15), /*timeout*/ DURATION ) RETURNS( FIXED(15) ) GLOBAL ;
  SPC TORTOS             ENTRY(FLOAT IDENT) GLOBAL;
  SPC TOIEES             ENTRY(FLOAT IDENT) GLOBAL;

  /* !!! */
  DCL FELDHILF(150)  FIXED(15); /* Hilfsfeld f¸r Bitwerte Analogeing‰nge */            
  DCL Z_IMPHILF(150) FIXED(15); /* Hilfsfeld Imp. Digitaleing‰nge   */            
  DCL Z_DIHILF(150)  FIXED(15); /* Hilfsfeld Zust. Digitaleing‰nge  */            
  DCL DOHILF(160)    FIXED(15); /* Hilfsfeld Zust. Digitalausg‰nge  */            
  DCL ZSTEU   FIXED;
  DCL STEU1   FIXED;
  DCL STEU2   FIXED;
  DCL STEU3   FIXED;
  DCL B_TESTRUF   BIT(1);
  DCL LINEX1  FIXED;
  DCL LINEX2  FIXED;
  DCL LINEY1  FIXED;
  DCL LINEY2  FIXED;
  DCL LINETYP FIXED;

  DCL CHFERN(10000)  CHAR(1);
  DCL Z_SCHREIBFERN  FIXED;
  DCL Z_LESFERN      FIXED;

  DCL F31_CANSENERR   FIXED(31);
  DCL F31_CANEMPERR   FIXED(31);
  DCL F31_ZEMPFRECH1  FIXED(31);
  DCL F31_ZEMPFRECH2  FIXED(31);
  DCL F31_ZSENDRECH1  FIXED(31);
  DCL F31_ZSENDRECH2  FIXED(31);
  DCL F31_LFZRECH1    FIXED(31);
  DCL F31_LFZRECH2    FIXED(31);
  DCL B_CANHAND       BIT(1);
  DCL DIGOUTS         BIT(32) ;
  DCL DOERR           BIT(16) ;
  DCL NEWDAT          CHAR(128); /* Hilfsvariable  */

  DCL ZPTEST1(300)    CLOCK;
  DCL F1TEST1(300)    FIXED;
  DCL F2TEST1(300)    FIXED;
  DCL F3TEST1(300)    FIXED;
  DCL ZPTEST2(300)    CLOCK;
  DCL F1TEST2(300)    FIXED;
  DCL F2TEST2(300)    FIXED;
  DCL F3TEST2(300)    FIXED;
  DCL BTEST1          BIT(1);
  DCL BTEST2          BIT(1);
  DCL ZTEST1          FIXED;
  DCL ZTEST2          FIXED;
  DCL B_CANRIM        BIT(1);
  DCL Z_TASTVERZ      FIXED;
  DCL NR_BUTTON       FIXED;

/*-------------------------------------------------------------------*/
#INCLUDE c:\p907\033bgadrallehohne\spc.p;


BTEST1: TASK PRIO 30;
  ZTEST1=1;
  ZTEST2=1;
  BTEST1='1'B;
  BTEST2='1'B;
END;

SHOWTEST: TASK PRIO 200;
  BTEST1='0'B;
  BTEST2='0'B;
  PUT TO TERM BY SKIP;
  FOR I TO 300 REPEAT
    PUT ZPTEST1(I),F1TEST1(I),F2TEST1(I),F3TEST1(I),ZPTEST2(I),F1TEST2(I),F2TEST2(I),F3TEST2(I) TO TERM BY T(12,3),F(5),F(5),F(5),T(14,3),F(5),F(5),F(5),SKIP;
  END;
END;

/*********************************************************************/
/* Prozeduren f¸r CAN-Sendefunktionen                                */
/*********************************************************************/
CANERRDEC: PROC( (CH,ID,error) FIXED(15) ) ;
  DCL F(10) FIXED;

! PUT 'CANERR',CH,ID,error TO A1 BY A,F(2),F(5),F(5),SKIP;


  IF error/=9 THEN
    IF Z_LZ > Z_LASTCANERR+10(31) THEN
      IF ID > 5000 THEN
        ID=ID-5000;
        F(1)=ID//1000;
        F(2)=(ID-F(1)*1000)//100;
        F(3)=(ID-F(1)*1000-F(2)*100)//10;
        F(4)=ID REM 10;
        F(5)=error//10;
        F(6)=error REM 10;
        CALL STOERMELD(61,'CAN' CAT TOCHAR(CH+48)
                                CAT 'e '
                                CAT TOCHAR(F(1)+48)
                                CAT TOCHAR(F(2)+48)
                                CAT TOCHAR(F(3)+48)
                                CAT TOCHAR(F(4)+48)
                                CAT '  -'
                                CAT TOCHAR(F(5)+48)
                                CAT TOCHAR(F(6)+48));
      ELSE
        F(1)=ID//1000;
        F(2)=(ID-F(1)*1000)//100;
        F(3)=(ID-F(1)*1000-F(2)*100)//10;
        F(4)=ID REM 10;
        F(5)=error//10;
        F(6)=error REM 10;
        CALL STOERMELD(61,'CAN' CAT TOCHAR(CH+48)
                                CAT 's '
                                CAT TOCHAR(F(1)+48)
                                CAT TOCHAR(F(2)+48)
                                CAT TOCHAR(F(3)+48)
                                CAT TOCHAR(F(4)+48)
                                CAT '  -'
                                CAT TOCHAR(F(5)+48)
                                CAT TOCHAR(F(6)+48));
      FIN;
      Z_LASTCANERR=Z_LZ;
    FIN;
  FIN;

  
END ; /* PROC ErrorDecoder --------------------------------------------------*/


SENDCANCHAR: PROC((NR,ID,LEN) FIXED, (CH1,CH2,CH3,CH4,CH5,CH6,CH7,CH8) CHAR(1), VERSUCHE FIXED);
  DCL error           FIXED(15);
  DCL CH              FIXED(15);
  DCL canchar         CAN_CHAR;

  IF NR==1 THEN  /* bei IF555-5 ist CAN1 = Kanal3, CAN2 = Kanal4 */
    CH=3;
  ELSE
    CH=4;
  FIN;

  canchar.identifier  = ID;
  canchar.frame_format= 0;
  canchar.rtr         = 0;
  canchar.data_length = LEN;
  canchar.data1=CH1;
  canchar.data2=CH2;
  canchar.data3=CH3;
  canchar.data4=CH4;
  canchar.data5=CH5;
  canchar.data6=CH6;
  canchar.data7=CH7;
  canchar.data8=CH8;

  IF Z_RTC > 0 THEN
    Z_RTC=Z_RTC-1;
  ELSE
    error = CAN_WRITE(CH, canchar.identifier ) ;
    !  0  : kein Fehler
    ! -1  : CAN-Baustein nicht verfuegbar
    ! -2  : Warning Level CAN-Baustein erreicht
    ! -5  : keine Initialisierung durchgefuehrt
    ! -6  : Off Bus
    ! -9  : Reset ausgeloest (can_init) 
    ! -10 : Identifier unzulaessig      
    ! -11 : Laenge unzulaessig              
    ! -13 : rtr-Wert unzulaessig            
    ! -15 : Timeout beim senden              
    
    IF error < 0 THEN
      CANERRDEC(NR,ID,(-error)) ;
    FIN ;
  FIN;

END;

SENDCANBIT: PROC((NR,ID,LEN) FIXED, (BI1,BI2,BI3,BI4) BIT(1), VERSUCHE FIXED);
  DCL error           FIXED(15);
  DCL CH              FIXED(15);
  DCL canbit          CAN_BIT;

  IF NR==1 THEN  /* bei IF555-5 ist CAN1 = Kanal3, CAN2 = Kanal4 */
    CH=3;
  ELSE
    CH=4;
  FIN;

  canbit.identifier  = ID;
  canbit.frame_format= 0;
  canbit.rtr         = 0;
  canbit.data_length = LEN;
  canbit.data1=BI1;
  canbit.data2=BI2;
  canbit.data3=BI3;
  canbit.data4=BI4;

  IF Z_RTC > 0 THEN
    Z_RTC=Z_RTC-1;
  ELSE
    error = CAN_WRITE(CH, canbit.identifier ) ;
  
    IF error < 0 THEN
      CANERRDEC(NR,ID,(-error)) ;
    FIN ;
  FIN;

END;

SENDCANFIXED: PROC((NR,ID,LEN) FIXED, (F1,F2,F3,F4) FIXED(15), VERSUCHE FIXED) GLOBAL;
  DCL error           FIXED(15);
  DCL CH              FIXED(15);
  DCL canfixed        CAN_FIXED;

  IF NR==1 THEN  /* bei IF555-5 ist CAN1 = Kanal3, CAN2 = Kanal4 */
    CH=3;
  ELSE
    CH=4;
  FIN;

  canfixed.identifier  = ID;
  canfixed.frame_format= 0;
  canfixed.rtr         = 0;
  canfixed.data_length = LEN;
  canfixed.data1=F1;
  canfixed.data2=F2;
  canfixed.data3=F3;
  canfixed.data4=F4;

  IF Z_RTC > 0 THEN
    Z_RTC=Z_RTC-1;
  ELSE
    error = CAN_WRITE(CH, canfixed.identifier ) ;
  
    IF error < 0 THEN
      CANERRDEC(NR,ID,(-error)) ;
    FIN ;
  FIN;
  
END;

SENDCANLONG: PROC((NR,ID,LEN) FIXED, (F311,F312) FIXED(31), VERSUCHE FIXED);
  DCL error           FIXED(15);
  DCL CH              FIXED(15);
  DCL canlong         CAN_LONG;

  IF NR==1 THEN  /* bei IF555-5 ist CAN1 = Kanal3, CAN2 = Kanal4 */
    CH=3;
  ELSE
    CH=4;
  FIN;

  canlong.identifier  = ID;
  canlong.frame_format= 0;
  canlong.rtr         = 0;
  canlong.data_length = LEN;
  canlong.data1=F311;
  canlong.data2=F312;

  IF Z_RTC > 0 THEN
    Z_RTC=Z_RTC-1;
  ELSE
    error = CAN_WRITE(CH, canlong.identifier ) ;
  
    IF error < 0 THEN
      CANERRDEC(NR,ID,(-error)) ;
    FIN ;
  FIN;

END;

SENDCANFLOAT: PROC((NR,ID,LEN) FIXED, (FL1,FL2) FLOAT(23), VERSUCHE FIXED);
  DCL error           FIXED(15);
  DCL CH              FIXED(15);
  DCL canfloat        CAN_FLOAT;

  IF NR==1 THEN  /* bei IF555-5 ist CAN1 = Kanal3, CAN2 = Kanal4 */
    CH=3;
  ELSE
    CH=4;
  FIN;

  canfloat.identifier  = ID;
  canfloat.frame_format= 0;
  canfloat.rtr         = 0;
  canfloat.data_length = LEN;
  CALL TORTOS(FL1);
  CALL TORTOS(FL2);
  canfloat.data1=FL1;
  canfloat.data2=FL2;

  IF Z_RTC > 0 THEN
    Z_RTC=Z_RTC-1;
  ELSE
    error = CAN_WRITE(CH, canfloat.identifier ) ;
  
    IF error < 0 THEN
      CANERRDEC(NR,ID,(-error)) ;
    FIN ;
  FIN;

END;


/*********************************************************************/
/* ZENTRALE CAN-Empfangstask                                         */
/*********************************************************************/
CAN1EMPF: TASK PRIO 2;
  DCL error           FIXED(15);
  DCL canchar         CAN_CHAR;
  DCL FL1             FLOAT;
  DCL FL2             FLOAT;
  DCL void            VOID;
  DCL FID             FIXED;
  DCL FID2            FIXED(31);
  DCL F11             FIXED;
  DCL F12             FIXED;
  DCL F13             FIXED;
  DCL F14             FIXED;
  DCL F31             FIXED(31);
  DCL F32             FIXED(31);
  DCL REFFIX          REF FIXED;
  DCL REFCHAR         REF CHAR(1);
  DCL REFCHAR8        REF CHAR(8);
  DCL REFBIT          REF BIT(1);
  DCL REFLONG         REF FIXED(31);
  DCL REFFLOAT        REF FLOAT;
  DCL CH              CHAR(1);
  DCL B16             BIT(16);
  DCL STAT            BIT(32);
  DCL CHAR8           CHAR(8);
  DCL CANREC(8)       CHAR(1);

! F11=SETPRI(-10);

  FOR I TO 10000 REPEAT
    CHFERN(I)=TOCHAR(0);
  END;

  REPEAT
    START:

  ! error = CAN_READ( 1, canchar ) ;
    error = CAN_READ( 3, canchar ) ;  /* bei IF555-5 ist CAN1 = Kanal3, CAN2 = Kanal4 */

  ! >0  : Anzahl noch wartender Messages
  !  0  : kein Fehler
  ! -1  : CAN-Baustein nicht verfuegbar
  ! -2  : Warning Level CAN-Baustein erreicht
  ! -5  : keine Initialisierung durchgefuehrt
  ! -6  : Off Bus
  ! -7  : Overrun CAN-Baustein aufgetreten
  ! -8  : Overrun Merlin Puffer aufgetreten
  ! -9  : Reset ausgeloest (can_init) 
    
    FID2=canchar.identifier;

    FID=FID2 FIT FID;
!   PUT FID TO A1 BY F(6);

    IF B_CANRIM THEN
      CANREC(1)=canchar.data1;
      CANREC(2)=canchar.data2;
      CANREC(3)=canchar.data3;
      CANREC(4)=canchar.data4;
      CANREC(5)=canchar.data5;
      CANREC(6)=canchar.data6;
      CANREC(7)=canchar.data7;
      CANREC(8)=canchar.data8;
      PUT FID TO CAN_RIM BY F(4);
      FOR I TO 8 REPEAT
        PUT ' ',TOBIT(TOFIXED(CANREC(I))) TO CAN_RIM BY A,B4(2);
      END;
      PUT TO CAN_RIM BY SKIP;
    FIN;  

    IF Z_FREECOUNT(12)==2 THEN
      CANREC(1)=canchar.data1;
      CANREC(2)=canchar.data2;
      CANREC(3)=canchar.data3;
      CANREC(4)=canchar.data4;
      CANREC(5)=canchar.data5;
      CANREC(6)=canchar.data6;
      CANREC(7)=canchar.data7;
      CANREC(8)=canchar.data8;
      void=canchar.data1;
      REFFIX=void;
      F11=REFFIX;
      REFADD(REFFIX,1);
      F12=REFFIX;
      REFADD(REFFIX,1);
      F13=REFFIX;       /* F13 ungenutzt ? */
      REFADD(REFFIX,1);
      F14=REFFIX;       /* F14 : im 8. Byte des CAN-Identifiers steht die Warnnummer */
      CALL D_CS(1,Z_FREECOUNT(11));
      PUT NOW TO LCD BY T(12,3);
      PUT FID TO LCD BY F(5);
      FOR I TO 8 REPEAT
        PUT ' ',TOBIT(TOFIXED(CANREC(I))) TO LCD BY A,B4(2);
      END;
      Z_FREECOUNT(11)=Z_FREECOUNT(11)+1;
      IF Z_FREECOUNT(11) > 16 THEN
        Z_FREECOUNT(11)=9;
      FIN;
      CALL D_CS(14,Z_FREECOUNT(11));
      PUT F11,F12,F13,F14 TO LCD BY F(6),F(6),F(6),F(6);
      Z_FREECOUNT(11)=Z_FREECOUNT(11)+1;
      IF Z_FREECOUNT(11) > 16 THEN
        Z_FREECOUNT(11)=9;
      FIN;
    FIN;  

    IF error < 0 THEN
      CANERRDEC(1,5000+FID,(-error)) ;
    FIN;
    Z_CAN1CONTR=Z_CAN1CONTR+2;

    /*    NO_CAN         NO_INIT         OFF_BUS   */
    IF error == -1 OR error == -5 OR error == -6 THEN
      AFTER 0.1 SEC RESUME;
    FIN;


    /* sind verwertbare Daten empfangen worden ? */ 
    IF error > -1 OR error == -2 OR error == -7 OR error == -8 THEN

      
      IF FID==1281 THEN  /* LCD-Daten Kraftwerk BHKWs */
        CANREC(1)=canchar.data1;
        CANREC(2)=canchar.data2;
        CANREC(3)=canchar.data3;
        CANREC(4)=canchar.data4;
        CANREC(5)=canchar.data5;
        CANREC(6)=canchar.data6;
        CANREC(7)=canchar.data7;
        CANREC(8)=canchar.data8;
        F11=canchar.data_length;
        IF F11 > 8 THEN  F11=8;  FIN;
        IF F11 < 0 THEN  F11=0;  FIN;
        FOR I TO F11 REPEAT
          IF Z_SCHREIBFERN > 9999 OR Z_SCHREIBFERN < 1 THEN
            Z_SCHREIBFERN=1;
          ELSE 
            Z_SCHREIBFERN=Z_SCHREIBFERN+1;
          FIN;
          CHFERN(Z_SCHREIBFERN)=CANREC(I);
        END;
        B_CANHAND='1'B;
        GOTO START;
      FIN;


      IF FID==1282 THEN  /* Fernbedienungsende Kraftwerk BHKWs */
        void=canchar.data1;
        REFFIX=void;
        Z_FERNEND=REFFIX;
        GOTO START;
      FIN;


!     IF FID==92 THEN    /* Fernbedienungsende Steinecke BHKWs */
!       void=canchar.data1;
!       REFFIX=void;
!       Z_FERNEND=REFFIX;
!       GOTO START;
!     FIN;

!     IF FID==1950 THEN  /* Mastersteuerung sendet Aufforderung zum Update ueber CAN-Bus */
!       void=canchar.data1;
!       REFFIX=void;
!       F11=REFFIX;
!       IF F11 == -32198 THEN 
!         Z_CANUPD=Z_CANUPD+1;
!       FIN;
!       IF Z_CANUPD == 100 THEN
!         CALL STOERMELD(64,'PRG-Update CAN');
!         ACTIVATE RAMSCHREIB;
!       FIN;
!       IF Z_CANUPD == 105 THEN
!         ACTIVATE RAMSCHREIB;
!       FIN;
!       IF Z_CANUPD == 130 THEN
!         PUT 'TERMINATE Watch -- PREVENT WATCHDOG' TO RTOS;
!       FIN;
!       GOTO START;
!     FIN;

      IF FID==1 THEN      /* Meldungen 1 Kraftwerk BHKW1 */
        void=canchar.data1;
        REFFIX=void;
        F11=REFFIX;
        REFADD(REFFIX,1);
        F12=REFFIX;
        REFADD(REFFIX,1);
        F13=REFFIX;       /* F13 ungenutzt ? */
        REFADD(REFFIX,1);
        F14=REFFIX;       /* F14 : im 8. Byte des CAN-Identifiers steht die Warnnummer */
        B16=TOBIT(F11);
        B_BBEREIT(1) =B16.BIT(8);
        B_BLHILF(1)  =B16.BIT(7);
        B_BMUSSEIN(1)=B16.BIT(6);
        B_BMUSSAUS(1)=B16.BIT(5);
        B_BWARN(1)   =B16.BIT(4);
        B_BSTOER(1)  =B16.BIT(3);
        B_START(1)   =B16.BIT(16);
        Z_FEHLERKRA(1)  =F12 REM 256;
        Z_MINAUSKRA(1)  =F12 // 256;
        Z_WARNKRA(1)    =F14 REM 256;
        GOTO START;
      FIN;
      IF FID==257 THEN    /* Meldungen 2 Kraftwerk BHKW1 */
        void=canchar.data1;
        REFFIX=void;
        PE_BIST(1)=REFFIX*0.01;
        Z_BCAN(1)=Z_BCAN(1)+15;    /* <<< Zaehler fuer CAN-Sendungen BHKW1 */
        GOTO START;
      FIN;
      IF FID==258 THEN    /* Meldungen 3 Kraftwerk BHKW1 */
        void=canchar.data1;
        REFFIX=void;
        IF BTEST1 THEN
          ZPTEST1(ZTEST1)=NOW;
          F1TEST1(ZTEST1)=REFFIX;
        FIN;
        PT_BIST(1)=REFFIX*0.01;
        REFADD(REFFIX,1);
        IF BTEST1 THEN
          F2TEST1(ZTEST1)=REFFIX;
        FIN;
        X_AEIN(181)=REFFIX*0.1;  /* T VL */
        REFADD(REFFIX,1);
        IF BTEST1 THEN
          F3TEST1(ZTEST1)=REFFIX;
          ZTEST1=ZTEST1+1;
          IF ZTEST1 > 299 THEN BTEST1='0'B; FIN;
        FIN;
        X_AEIN(182)=REFFIX*0.1;  /* T RL */
        GOTO START;
      FIN;
      IF FID==769 THEN    /* Meldungen 4 Kraftwerk BHKW1 */
        void=canchar.data1;
        REFLONG=void;
        FL_BLFZGES(1)=REFLONG/3600.0;
        GOTO START;
      FIN;
      IF FID==770 THEN    /* Meldungen 5 Kraftwerk BHKW1 */
        void=canchar.data1;
        REFLONG=void;
        FL_BKWHGES(1)=REFLONG*0.01;
        REFADD(REFLONG,1);
        FL_BTHKWH(1)=REFLONG*0.01;
        GOTO START;
      FIN;
      IF FID==1025 THEN   /* Meldungen 6 Kraftwerk BHKW1 */
        void=canchar.data1;
        REFFIX=void;
     !  PE_MAXBHKW(1)=REFFIX*0.01;
        REFADD(REFFIX,1);
     !  PE_MINBHKW(1)=REFFIX*0.01;
        GOTO START;
      FIN;


      IF FID==6 THEN      /* Meldungen 1 Kraftwerk BHKW2 */
        void=canchar.data1;
        REFFIX=void;
        F11=REFFIX;
        REFADD(REFFIX,1);
        F12=REFFIX;
        REFADD(REFFIX,1);
        F13=REFFIX;       /* F13 ungenutzt ? */
        B16=TOBIT(F11);
        B_BBEREIT(2) =B16.BIT(8);
        B_BLHILF(2)  =B16.BIT(7);
        B_BMUSSEIN(2)=B16.BIT(6);
        B_BMUSSAUS(2)=B16.BIT(5);
        B_BWARN(2)   =B16.BIT(4);
        B_BSTOER(2)  =B16.BIT(3);
        B_START(2)   =B16.BIT(16);
        Z_FEHLERKRA(2)  =F12 REM 256;
        Z_MINAUSKRA(2)  =F12 // 256;
        GOTO START;
      FIN;
      IF FID==262 THEN    /* Meldungen 2 Kraftwerk BHKW2 */
        void=canchar.data1;
        REFFIX=void;
        PE_BIST(2)=REFFIX*0.01;
        Z_BCAN(2)=Z_BCAN(2)+5;    /* <<< Zaehler fuer CAN-Sendungen BHKW2 */
        GOTO START;
      FIN;
      IF FID==263 THEN    /* Meldungen 3 Kraftwerk BHKW2 */
        void=canchar.data1;
        REFFIX=void;
        IF BTEST2 THEN
          ZPTEST2(ZTEST2)=NOW;
          F1TEST2(ZTEST2)=REFFIX;
        FIN;
        PT_BIST(2)=REFFIX*0.01;
        REFADD(REFFIX,1);
        IF BTEST2 THEN
          F2TEST2(ZTEST2)=REFFIX;
        FIN;
        X_AEIN(183)=REFFIX*0.1;   /* T VL */
        REFADD(REFFIX,1);
        IF BTEST2 THEN
          F3TEST2(ZTEST2)=REFFIX;
          ZTEST2=ZTEST2+1;
          IF ZTEST2 > 299 THEN BTEST2='0'B; FIN;
        FIN;
        X_AEIN(184)=REFFIX*0.1;   /* T RL */
        GOTO START;
      FIN;
      IF FID==774 THEN    /* Meldungen 4 Kraftwerk BHKW2 */
        void=canchar.data1;
        REFLONG=void;
        FL_BLFZGES(2)=REFLONG/3600.0;
        GOTO START;
      FIN;
      IF FID==775 THEN    /* Meldungen 5 Kraftwerk BHKW2 */
        void=canchar.data1;
        REFLONG=void;
        FL_BKWHGES(2)=REFLONG*0.01;
        REFADD(REFLONG,1);
        FL_BTHKWH(2)=REFLONG*0.01;
        GOTO START;
      FIN; 
      IF FID==1030 THEN   /* Meldungen 6 Kraftwerk BHKW2 */
        void=canchar.data1;
        REFFIX=void;
     !  PE_MAXBHKW(2)=REFFIX*0.01;
        REFADD(REFFIX,1);
     !  PE_MINBHKW(2)=REFFIX*0.01;
        GOTO START;
      FIN;



      IF FID==11 THEN      /* Meldungen 1 Kraftwerk BHKW3 */
        void=canchar.data1;
        REFFIX=void;
        F11=REFFIX;
        REFADD(REFFIX,1);
        F12=REFFIX;
        REFADD(REFFIX,1);
        F13=REFFIX;       /* F13 ungenutzt ? */
        B16=TOBIT(F11);
        B_BBEREIT(3) =B16.BIT(8);
        B_BLHILF(3)  =B16.BIT(7);
        B_BMUSSEIN(3)=B16.BIT(6);
        B_BMUSSAUS(3)=B16.BIT(5);
        B_BWARN(3)   =B16.BIT(4);
        B_BSTOER(3)  =B16.BIT(3);
        B_START(3)   =B16.BIT(16);
        Z_FEHLERKRA(3)  =F12 REM 256;
        Z_MINAUSKRA(3)  =F12 // 256;
        GOTO START;
      FIN;
      IF FID==267 THEN    /* Meldungen 2 Kraftwerk BHKW3 */
        void=canchar.data1;
        REFFIX=void;
        PE_BIST(3)=REFFIX*0.01;
        Z_BCAN(3)=Z_BCAN(3)+5;    /* <<< Z‰hler f¸r CAN-Sendungen BHKW3 */
        GOTO START;
      FIN;
      IF FID==268 THEN    /* Meldungen 3 Kraftwerk BHKW3 */
        void=canchar.data1;
        REFFIX=void;
        PT_BIST(3)=REFFIX*0.01;
        REFADD(REFFIX,1);
        X_AEIN(185)=REFFIX*0.1;
        REFADD(REFFIX,1);
        X_AEIN(186)=REFFIX*0.1;
        GOTO START;
      FIN;
      IF FID==779 THEN    /* Meldungen 4 Kraftwerk BHKW3 */
        void=canchar.data1;
        REFLONG=void;
        FL_BLFZGES(3)=REFLONG/3600.0;
        GOTO START;
      FIN;
      IF FID==780 THEN    /* Meldungen 5 Kraftwerk BHKW3 */
        void=canchar.data1;
        REFLONG=void;
        FL_BKWHGES(3)=REFLONG*0.01;
        REFADD(REFLONG,1);
        FL_BTHKWH(3)=REFLONG*0.01;
        GOTO START;
      FIN; 
      IF FID==1035 THEN   /* Meldungen 6 Kraftwerk BHKW3 */
        void=canchar.data1;
        REFFIX=void;
    !   PE_MAXBHKW(3)=REFFIX*0.01;
        REFADD(REFFIX,1);
    !   PE_MINBHKW(3)=REFFIX*0.01;
        GOTO START;
      FIN;


      /* UNTERSTATIONEN <<< */
      IF FID==83 THEN      /* Rueckmeldung Schleichupdate UST1 (NR_SLAVE=4) */
        void=canchar.data1;
        REFLONG=void;
        F31=REFLONG;
        REFADD(REFLONG,1);
        F32=REFLONG;
        SCHL_STA(1)='0';
        IF F31 > 29000000(31) THEN
          SCHL_STA(1)='F';
          F31=F31-29000000(31);
        FIN;
        IF F31 > 20000000(31) THEN
          SCHL_STA(1)='D';
          F31=F31-20000000(31);
        FIN;
        IF F31 > 10000000(31) THEN
          SCHL_STA(1)='E';
          F31=F31-10000000(31);
        FIN;
        SCHL_BYTE( 1)=F31;
        SCHL_CRC ( 1)=F32;
        SCHL_ANZEMPF=SCHL_ANZEMPF+1;
      FIN;
    
 
 
      IF FID==179 THEN      /* Meldungen DISPLAYSTATUS UNTERSTATIONEN */
        void=canchar.data1;
        REFLONG=void;
        F31=REFLONG;
        REFADD(REFLONG,1);
        F32=REFLONG;
        F14=F32 FIT F14;
   
        CASE F14
          ALT /* 1  DISPLAYSTATUS */
            DISPSTATUS=TOBIT(F31);
            DISPSTATUS2=TOBIT(F31);
            DISPSTATUS3=TOBIT(F31);
          OUT
        FIN;
   
        GOTO START;
      FIN;
 
!
!     IF FID==186 THEN      /* Meldungen 1 UNTERSTATION1 */
!       ZT_LASTCAN(1)=ZT_JAHR;
!       Z_UCAN(1)=Z_UCAN(1)+3;    /* Zaehler fuer CAN-Sendungen */
!       void=canchar.data1;
!       REFFIX=void;
!       F11=REFFIX;
!       REFADD(REFFIX,1);
!       F12=REFFIX;
!       REFADD(REFFIX,1);
!       F13=REFFIX;       
!       REFADD(REFFIX,1);
!       F14=REFFIX;       
!
!       CASE F14
!         ALT /* 1  AI 1-3 */
!           X_AEINEXT( 1,1)=F11*0.1;      /* Aussentemp   */
!           X_AEINEXT( 2,1)=F12*0.1;      /* k1 VL        */
!           X_AEINEXT( 3,1)=F13*0.1;      /* k1 RL        */
!         ALT /* 2  AI 4-6 */
!           X_AEINEXT( 4,1)=F11*0.1;      /* k2 VL        */
!           X_AEINEXT( 5,1)=F12*0.1;      /* k2 RL        */
!           X_AEINEXT( 6,1)=F13*0.1;      /* k samm vl    */
!         ALT /* 3  AI 7-9 */
!           X_AEINEXT( 7,1)=F11*0.1;      /* hyd wei      */
!           X_AEINEXT( 8,1)=F12*0.1;      /* haupt VL     */
!           X_AEINEXT( 9,1)=F13*0.1;      /* haupt RL     */
!         ALT /* 4  AI 10-12 */
!           X_AEINEXT(10,1)=F11*0.1;      /* HK1 Sauna VL   */
!           X_AEINEXT(11,1)=F12*0.1;      /* HK1 Sauna RL   */
!           X_AEINEXT(12,1)=F13*0.1;      /* HK2 Kosmet VL  */
!         ALT /* 5  AI 13-15 */
!           X_AEINEXT(13,1)=F11*0.1;      /* HK2 Kosmet RL  */
!           X_AEINEXT(14,1)=F12*0.1;      /* HK3 Calad. VL  */
!           X_AEINEXT(15,1)=F13*0.1;      /* HK3 Calad. RL  */
!         ALT /* 6  */
!           X_AEINEXT(16,1)=F11*0.1;      /* HK4 FBH VL     */
!           X_AEINEXT(17,1)=F12*0.1;      /* HK4 FBH RL     */
!           X_AEINEXT(18,1)=F13*0.1;      /* HK5 Lueft. VL  */
!         ALT /* 7  */
!           X_AEINEXT(19,1)=F11*0.1;      /* HK5 Lueft. RL  */
!           X_AEINEXT(20,1)=F12*0.1;      /* WW Austritt    */
!           X_AEINEXT(21,1)=F13*0.1;      /* WW Zirk RL     */
!         ALT /* 8  */
!           X_AEINEXT(22,1)=F11*0.1;      /* HK6 Bettenh VL */
!           X_AEINEXT(23,1)=F12*0.1;      /* HK6 Bettenh RL */
!           X_AEINEXT(24,1)=F13*0.1;      /* ---            */
!         ALT /* 9  */
!           X_AEINEXT(25,1)=F11*0.1;      /* ---            */
!           X_AEINEXT(26,1)=F12*0.01;      /* GASSENS        */
!           X_AEINEXT(27,1)=F13*0.01;      /* DRUCK VERT     */
!         ALT /* 10  */
!           X_AEINEXT(28,1)=F11*0.1;      /* TC_VIST     */
!           X_AEINEXT(29,1)=F12*0.1;      /* MISCHERSTELLUNG HK1 % */
!           X_AEINEXT(30,1)=F13*0.1;      /* MISCHERSTELLUNG HK2 % */
!         ALT /* 11 */
!           X_AEINEXT(31,1)=F11*0.1;      /* MISCHERSTELLUNG HK3 % */
!           X_AEINEXT(32,1)=F12*0.1;      /* MISCHERSTELLUNG HK4 % */
!           X_AEINEXT(33,1)=F13*0.1;      /* MISCHERSTELLUNG HK5 % */
!         ALT /* 12 */
!           X_AEINEXT(34,1)=F11*0.1;      /* MISCHERSTELLUNG HK6 % */
!           X_AEINEXT(35,1)=F12*0.1;      /* SOLL PUMPE HK1    % */
!           X_AEINEXT(36,1)=F13*0.1;      /* SOLL PUMPE HK6    % */
!         ALT /* 13 */
!           X_AEINEXT(37,1)=F11*0.1;      /* VL-ANF  HK1    */
!           X_AEINEXT(38,1)=F12*0.1;      /* VL-ANF  HK2    */
!           X_AEINEXT(39,1)=F13*0.1;      /* VL-ANF  HK3    */
!         ALT /* 14 */
!           X_AEINEXT(40,1)=F11*0.1;      /* VL-ANF  HK4    */
!           X_AEINEXT(41,1)=F12*0.1;      /* VL-ANF  HK5    */
!           X_AEINEXT(42,1)=F13*0.1;      /* VL-ANF  HK6    */
!         ALT /* 15 */
!           X_AEINEXT(43,1)=F11    ;      /* PRG VERSION    */
!           X_AEINEXT(44,1)=F12*0.1;      /* VL-Soll        */
!           X_AEINEXT(45,1)=F13    ;      /* Stˆrungsstatus */
!         ALT /* 16 */
!           X_AEINEXT(46,1)=F11    ;      /* Absenk HK1      */
!           X_AEINEXT(47,1)=F12    ;      /* Absenk HK2      */
!           X_AEINEXT(48,1)=F13    ;      /* Absenk HK3      */
!         ALT /* 17 */
!           X_AEINEXT(49,1)=F11    ;      /* Absenk HK4      */
!           X_AEINEXT(50,1)=F12    ;      /* Absenk HK5      */
!           X_AEINEXT(51,1)=F13    ;      /* Absenk HK6      */
!         ALT /* 18 */
!           X_AEINEXT(52,1)=F11    ;      /* BETRIEB K1      */
!           X_AEINEXT(53,1)=F12    ;      /* BETRIEB K2      */
!           X_AEINEXT(54,1)=F13    ;      /* ANF K1          */
!         ALT /* 19 */
!           X_AEINEXT(55,1)=F11    ;      /* ANF K2          */
!           X_AEINEXT(56,1)=F12    ;      /* STOER K1        */
!           X_AEINEXT(57,1)=F13    ;      /* STOER K2        */
!         ALT /* 20 */
!           X_AEINEXT(58,1)=F11    ;      /* K1 PMP          */
!           X_AEINEXT(59,1)=F12    ;      /* K2 PMP          */
!           X_AEINEXT(60,1)=F13*0.1;      /* K2 RL-MISCHER       % */
!         ALT /* 21 */
!           X_AEINEXT(61,1)=F11*0.1;      /* PTH K1        */
!           X_AEINEXT(62,1)=F12*0.1;      /* PTH K2        */
!           X_AEINEXT(63,1)=F13    ;      /* Z_MINKES        */
!         ALT /* 22 */
!           X_AEINEXT(64,1)=F11    ;      /* HK1 PMP         */
!           X_AEINEXT(65,1)=F12    ;      /* HK2 PMP         */
!           X_AEINEXT(66,1)=F13    ;      /* HK3 PMP         */
!         ALT /* 23 */
!           X_AEINEXT(67,1)=F11    ;      /* HK4 PMP         */
!           X_AEINEXT(68,1)=F12    ;      /* HK6 PMP         */
!           X_AEINEXT(69,1)=F13    ;      /* WW Sauna Zirkp  */
!         ALT /* 24 */
!           X_AEINEXT(70,1)=F11*0.01;      /* DRUCK UPE PMP1 HK1  */
!           X_AEINEXT(71,1)=F12*0.01;      /* DRUCK UPE PMP2 HK6  */
!           X_AEINEXT(72,1)=F13*0.01;      /* Warngr. HZG-Druck */
!         OUT
!       FIN;
!
!       GOTO START;
!     FIN;
!
!     IF FID==187 THEN      /* Meldungen 2 UNTERSTATION1 */
!       void=canchar.data1;
!       REFLONG=void;
!       F31=REFLONG;
!       REFADD(REFLONG,1);
!       F32=REFLONG;
!       F14=F32 FIT F14;
!  
!       CASE F14
!         ALT /* 1  LFZ Gaskes */
!           X_AEINEXT(80,1)=F31*1.0;
!         ALT /* 2  LFZ Oelkes */
!           X_AEINEXT(81,1)=F31*1.0;
!  !      ALT /* 3  WMZ HK2  */
!  !        X_AEINEXT(52,1)=F31*1.0;
!         OUT
!       FIN;
!  
!       GOTO START;
!     FIN;



      /* ab hier Meldungen der CAN-Erweiterungskarten */
      IF FID==CANBASE+3 THEN /* Digitaleingaenge 33-36 */
        Z_DIHILF(33)=TOFIXED(canchar.data1);
        Z_IMPHILF(33)=TOFIXED(canchar.data2);
        Z_DIHILF(34)=TOFIXED(canchar.data3);
        Z_IMPHILF(34)=TOFIXED(canchar.data4);
        Z_DIHILF(35)=TOFIXED(canchar.data5);
        Z_IMPHILF(35)=TOFIXED(canchar.data6);
        Z_DIHILF(36)=TOFIXED(canchar.data7);
        Z_IMPHILF(36)=TOFIXED(canchar.data8);
        GOTO START;
      FIN;

      IF FID==CANBASE+4 THEN /* Digitaleingaenge 37-40 */
        Z_DIHILF(37)=TOFIXED(canchar.data1);
        Z_IMPHILF(37)=TOFIXED(canchar.data2);
        Z_DIHILF(38)=TOFIXED(canchar.data3);
        Z_IMPHILF(38)=TOFIXED(canchar.data4);
        Z_DIHILF(39)=TOFIXED(canchar.data5);
        Z_IMPHILF(39)=TOFIXED(canchar.data6);
        Z_DIHILF(40)=TOFIXED(canchar.data7);
        Z_IMPHILF(40)=TOFIXED(canchar.data8);
        GOTO START;
      FIN;

      IF FID==CANBASE+5 THEN /* Digitaleingaenge 41-44 */
        Z_DIHILF(41)=TOFIXED(canchar.data1);
        Z_IMPHILF(41)=TOFIXED(canchar.data2);
        Z_DIHILF(42)=TOFIXED(canchar.data3);
        Z_IMPHILF(42)=TOFIXED(canchar.data4);
        Z_DIHILF(43)=TOFIXED(canchar.data5);
        Z_IMPHILF(43)=TOFIXED(canchar.data6);
        Z_DIHILF(44)=TOFIXED(canchar.data7);
        Z_IMPHILF(44)=TOFIXED(canchar.data8);
        GOTO START;
      FIN;

      IF FID==CANBASE+6 THEN /* Digitaleingaenge 45-48 */
        Z_DIHILF(45)=TOFIXED(canchar.data1);
        Z_IMPHILF(45)=TOFIXED(canchar.data2);
        Z_DIHILF(46)=TOFIXED(canchar.data3);
        Z_IMPHILF(46)=TOFIXED(canchar.data4);
        Z_DIHILF(47)=TOFIXED(canchar.data5);
        Z_IMPHILF(47)=TOFIXED(canchar.data6);
        Z_DIHILF(48)=TOFIXED(canchar.data7);
        Z_IMPHILF(48)=TOFIXED(canchar.data8);
        GOTO START;
      FIN;

      IF FID==CANBASE+7 THEN /* Analogeingaenge 33-36  */
        void=canchar.data1;
        REFFIX=void;
        FELDHILF(33)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(34)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(35)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(36)=REFFIX;
        GOTO START;
      FIN;

      IF FID==CANBASE+8 THEN /* Analogeingaenge 37-40  */
        void=canchar.data1;
        REFFIX=void;
        FELDHILF(37)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(38)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(39)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(40)=REFFIX;
        GOTO START;
      FIN;

      IF FID==CANBASE+9 THEN /* Analogeingaenge 41-44  */
        void=canchar.data1;
        REFFIX=void;
        FELDHILF(41)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(42)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(43)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(44)=REFFIX;
        GOTO START;
      FIN;

      IF FID==CANBASE+10 THEN /* Analogeingaenge 45-48  */
        void=canchar.data1;
        REFFIX=void;
        FELDHILF(45)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(46)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(47)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(48)=REFFIX;
        GOTO START;
      FIN;

      IF FID==CANBASE+19 THEN /* Digitaleingaenge 49-52 */
        Z_DIHILF(49)=TOFIXED(canchar.data1);
        Z_IMPHILF(49)=TOFIXED(canchar.data2);
        Z_DIHILF(50)=TOFIXED(canchar.data3);
        Z_IMPHILF(50)=TOFIXED(canchar.data4);
        Z_DIHILF(51)=TOFIXED(canchar.data5);
        Z_IMPHILF(51)=TOFIXED(canchar.data6);
        Z_DIHILF(52)=TOFIXED(canchar.data7);
        Z_IMPHILF(52)=TOFIXED(canchar.data8);
        GOTO START;
      FIN;

      IF FID==CANBASE+20 THEN /* Digitaleingaenge 53-56 */
        Z_DIHILF(53)=TOFIXED(canchar.data1);
        Z_IMPHILF(53)=TOFIXED(canchar.data2);
        Z_DIHILF(54)=TOFIXED(canchar.data3);
        Z_IMPHILF(54)=TOFIXED(canchar.data4);
        Z_DIHILF(55)=TOFIXED(canchar.data5);
        Z_IMPHILF(55)=TOFIXED(canchar.data6);
        Z_DIHILF(56)=TOFIXED(canchar.data7);
        Z_IMPHILF(56)=TOFIXED(canchar.data8);
        GOTO START;
      FIN;

      IF FID==CANBASE+21 THEN /* Digitaleingaenge 57-60 */
        Z_DIHILF(57)=TOFIXED(canchar.data1);
        Z_IMPHILF(57)=TOFIXED(canchar.data2);
        Z_DIHILF(58)=TOFIXED(canchar.data3);
        Z_IMPHILF(58)=TOFIXED(canchar.data4);
        Z_DIHILF(59)=TOFIXED(canchar.data5);
        Z_IMPHILF(59)=TOFIXED(canchar.data6);
        Z_DIHILF(60)=TOFIXED(canchar.data7);
        Z_IMPHILF(60)=TOFIXED(canchar.data8);
        GOTO START;
      FIN;

      IF FID==CANBASE+22 THEN /* Digitaleingaenge 61-64 */
        Z_DIHILF(61)=TOFIXED(canchar.data1);
        Z_IMPHILF(61)=TOFIXED(canchar.data2);
        Z_DIHILF(62)=TOFIXED(canchar.data3);
        Z_IMPHILF(62)=TOFIXED(canchar.data4);
        Z_DIHILF(63)=TOFIXED(canchar.data5);
        Z_IMPHILF(63)=TOFIXED(canchar.data6);
        Z_DIHILF(64)=TOFIXED(canchar.data7);
        Z_IMPHILF(64)=TOFIXED(canchar.data8);
        GOTO START;
      FIN;

      IF FID==CANBASE+23 THEN /* Analogeingaenge 49-52  */
        void=canchar.data1;
        REFFIX=void;
        FELDHILF(49)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(50)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(51)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(52)=REFFIX;
        GOTO START;
      FIN;

      IF FID==CANBASE+24 THEN /* Analogeingaenge 53-56  */
        void=canchar.data1;
        REFFIX=void;
        FELDHILF(53)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(54)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(55)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(56)=REFFIX;
        GOTO START;
      FIN;

      IF FID==CANBASE+25 THEN /* Analogeingaenge 57-60  */
        void=canchar.data1;
        REFFIX=void;
        FELDHILF(57)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(58)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(59)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(60)=REFFIX;
        GOTO START;
      FIN;

      IF FID==CANBASE+26 THEN /* Analogeingaenge 61-64  */
        void=canchar.data1;
        REFFIX=void;
        FELDHILF(61)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(62)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(63)=REFFIX;
        REFADD(REFFIX,1);
        FELDHILF(64)=REFFIX;
        GOTO START;
      FIN;



      IF FID==CANBASE+1 THEN /* UDN-Staerungen CAN1 */
        F11=TOFIXED(canchar.data5);
        IF F11==10 THEN  Z_UDNSTOER(5)=Z_UDNSTOER(5)+1; FIN;
        IF F11==20 THEN  Z_UDNSTOER(6)=Z_UDNSTOER(6)+1; FIN;
        IF F11==30 THEN  Z_UDNSTOER(5)=Z_UDNSTOER(5)+1;  Z_UDNSTOER(6)=Z_UDNSTOER(6)+1; FIN;
        GOTO START;
      FIN;
      IF FID==CANBASE+17 THEN /* UDN-Stoerungen CAN2 */
        F11=TOFIXED(canchar.data5);
        IF F11==10 THEN  Z_UDNSTOER(7)=Z_UDNSTOER(7)+1; FIN;
        IF F11==20 THEN  Z_UDNSTOER(8)=Z_UDNSTOER(8)+1; FIN;
        IF F11==30 THEN  Z_UDNSTOER(7)=Z_UDNSTOER(7)+1;  Z_UDNSTOER(8)=Z_UDNSTOER(8)+1; FIN;
        GOTO START;
      FIN;
      IF FID==CANBASE+33 THEN /* UDN-Stoerungen CAN3 */
        F11=TOFIXED(canchar.data5);
        IF F11==10 THEN  Z_UDNSTOER(9)=Z_UDNSTOER(9)+1; FIN;
        IF F11==20 THEN  Z_UDNSTOER(10)=Z_UDNSTOER(10)+1; FIN;
        IF F11==30 THEN  Z_UDNSTOER(9)=Z_UDNSTOER(9)+1;  Z_UDNSTOER(10)=Z_UDNSTOER(10)+1; FIN;
        GOTO START;
      FIN;
      /* Ende Meldungen der CAN-Erweiterungskarten */


    FIN;
  END;

END;

/******************************************************************************/
/* Zyklische Kommunikationstask fuer die CAN-Erweiterungskarten               */
/******************************************************************************/
CANIOPLAT: TASK PRIO 10;
  DCL ZP1 CLOCK;
  DCL ZP2 CLOCK;
  DCL DUR DURATION;
  DCL ZD_IMP  DURATION;
  DCL FIX1 FIXED;
  DCL PWMAA(8) FIXED;
  DCL BCANST(3)  BIT(1);
  DCL ZLOOP2     FIXED;

  REPEAT
    ZP1=NOW;
    Z_CANIO=Z_CANIO+10;

    ZLOOP2=ZLOOP2+1;
    IF ZLOOP2 > 10 THEN
      FOR I TO 12 REPEAT
        IF Z_UDNSTOER(I+4) > 0 THEN
          Z_UDNSTOER(I+4)=Z_UDNSTOER(I+4)-4;
        FIN;
      END;
      ZLOOP2=1;
    FIN;  

                   /* AI1 EW1 keine Daten    AI9 EW1 keine Daten */
    IF ZCANPLAT > 0 AND (FELDHILF(33) < 0 OR FELDHILF(41) < 0) THEN
      Z_STOER(79)=Z_STOER(79)+1;
      IF Z_STOER(79) > 70 AND NOT B_STOER(79) THEN
        B_STOER(79)='1'B;
        CALL STOERMELD(79,'CAN EW-Karte 1');
      FIN;
    ELSE
      IF Z_STOER(79) > 65 THEN Z_STOER(79)=65; FIN;
      IF Z_STOER(79) > 1 THEN
        Z_STOER(79)=Z_STOER(79)-1;
      ELSE
        B_STOER(79)='0'B;
      FIN;
    FIN;

                   /* AI1 EW2 keine Daten    AI9 EW2 keine Daten */
    IF ZCANPLAT > 1 AND (FELDHILF(49) < 0 OR FELDHILF(57) < 0) THEN
      Z_STOER(78)=Z_STOER(78)+1;
      IF Z_STOER(78) > 70 AND NOT B_STOER(78) THEN
        B_STOER(78)='1'B;
        CALL STOERMELD(78,'CAN EW-Karte 2');
      FIN;
    ELSE
      IF Z_STOER(78) > 65 THEN Z_STOER(78)=65; FIN;
      IF Z_STOER(78) > 1 THEN
        Z_STOER(78)=Z_STOER(78)-1;
      ELSE
        B_STOER(78)='0'B;
      FIN;
    FIN;

                   /* AI1 EW3 keine Daten    AI9 EW3 keine Daten */
    IF ZCANPLAT > 2 AND (FELDHILF(65) < 0 OR FELDHILF(73) < 0) THEN
      Z_STOER(77)=Z_STOER(77)+1;
      IF Z_STOER(77) > 70 AND NOT B_STOER(77) THEN
        B_STOER(77)='1'B;
        CALL STOERMELD(77,'CAN EW-Karte 3');
      FIN;
    ELSE
      IF Z_STOER(77) > 65 THEN Z_STOER(77)=65; FIN;
      IF Z_STOER(77) > 1 THEN
        Z_STOER(77)=Z_STOER(77)-1;
      ELSE
        B_STOER(77)='0'B;
      FIN;
    FIN;


    /* Spannungsabschaltungen CAN-EW-KARTEN     <<< */
    BCANST(1)='0'B;
    BCANST(2)='0'B;
    BCANST(3)='0'B;
    IF ZF_STOERFREI(79) < 2 AND Z_STOER(79) > 150 AND Z_STOER(79) < 160 THEN
      BCANST(1)='1'B;
    FIN;
    IF ZF_STOERFREI(78) < 2 AND Z_STOER(78) > 150 AND Z_STOER(78) < 160 THEN
      BCANST(2)='1'B;
    FIN;
    IF ZF_STOERFREI(77) < 2 AND Z_STOER(77) > 150 AND Z_STOER(77) < 160 THEN
      BCANST(3)='1'B;
    FIN;

    IF ZF_STOERFREI(79) < 2 AND Z_STOER(79) > 350 AND Z_STOER(79) < 360 THEN
      BCANST(1)='1'B;
    FIN;
    IF ZF_STOERFREI(78) < 2 AND Z_STOER(78) > 350 AND Z_STOER(78) < 360 THEN
      BCANST(2)='1'B;
    FIN;
    IF ZF_STOERFREI(77) < 2 AND Z_STOER(77) > 350 AND Z_STOER(77) < 360 THEN
      BCANST(3)='1'B;
    FIN;

    B_CANAUS=BCANST(1) OR BCANST(2) OR BCANST(3);

    /* nach 60 Min externe Abschaltung + Reset Hauptsteuerung durch Endlosschleife + Watchdog */
    IF ZF_STOERFREI(79) < 2 AND Z_STOER(79) > 3600 THEN
      REPEAT
        B_CANAUS='1'B;
        AFTER 1 SEC RESUME;
      END;
    FIN;
    IF ZF_STOERFREI(78) < 2 AND Z_STOER(78) > 3600 THEN
      REPEAT
        B_CANAUS='1'B;
        AFTER 1 SEC RESUME;
      END;
    FIN;
    IF ZF_STOERFREI(77) < 2 AND Z_STOER(77) > 3600 THEN
      REPEAT
        B_CANAUS='1'B;
        AFTER 1 SEC RESUME;
      END;
    FIN;

    
    FOR I FROM 33 TO 80 REPEAT   /* Auswertung der eingegangenen Meldungen */
      IF FELDHILF(I) > -1 THEN
        FELD(I)=FELDHILF(I);     /* AI */
      FIN;
      FELDHILF(I)=-9;
    END;

    FOR I FROM 33 TO 80 REPEAT                                
      FIX1=I;                                           
      IF Z_DIHILF(I) > -1 THEN    /* DI Zustand */
        IF Z_DIHILF(I) > 0 THEN
          BI_DEIN(FIX1)='1'B;
        ELSE      
          BI_DEIN(FIX1)='0'B;
        FIN;
      FIN;
      Z_DIHILF(I)=-9;
      IF Z_IMPHILF(I) > 0 THEN   /* DI Impulse  */
        FOR K TO Z_IMPHILF(I) REPEAT
          Z_ZAEHL(FIX1)=Z_ZAEHL(FIX1)+1(31);  /* Eingangsimpulse zaehlen */
          IF Z_ZAEHL(FIX1) REM 2(31) == 0(31) THEN
            IF K-Z_IMPHILF(I) < 2 THEN
              ZD_IMP=NOW-ZP_IMPALT(FIX1);
              ZP_IMPALT(FIX1)=NOW;
            FIN;
            FL_IMPDAU(FIX1)=ZD_IMP / 1.0 SEC;
            IF FL_IMPDAU(FIX1) < 0.000 THEN
              FL_IMPDAU(FIX1)=FL_IMPDAU(FIX1)+86400.0;
            FIN;
            B_IMPNEU(FIX1)='1'B;
          FIN;           
        END;
      FIN;
      Z_IMPHILF(I)=-9;
    END;
    
    /* AI und DI von CAN-Erweiterungskarte 1 anfordern */
    IF ZCANPLAT > 0 THEN
      CALL SENDCANCHAR(1, CANBASE+2, 1, TOCHAR(3), ' ', ' ', ' ', ' ', ' ', ' ', ' ', 20 );
      AFTER 0.1 SEC RESUME; /* kurz warten */
    FIN;
    /* AI und DI von CAN-Erweiterungskarte 2 anfordern */
    IF ZCANPLAT > 1 THEN
      CALL SENDCANCHAR(1, CANBASE+18, 1, TOCHAR(3), ' ', ' ', ' ', ' ', ' ', ' ', ' ', 20 );
      AFTER 0.1 SEC RESUME; /* kurz warten */
    FIN;
    /* AI und DI von CAN-Erweiterungskarte 3 anfordern */
    IF ZCANPLAT > 2 THEN
      CALL SENDCANCHAR(1, CANBASE+34, 1, TOCHAR(3), ' ', ' ', ' ', ' ', ' ', ' ', ' ', 20 );
      AFTER 0.1 SEC RESUME; /* kurz warten */
    FIN;
    
    FOR I FROM 5 TO 6 REPEAT  /* Digitalausgaenge CAN-EW-Karte 1 */
      FOR K TO 8 REPEAT
        IF B_DO((I-1)*8+K) THEN       /* EIN  */
          DOHILF((I-1)*8+K)=100;
        ELSE                          /* AUS  */
          DOHILF((I-1)*8+K)=0;
        FIN;
      END;
  !   IF Z_DOHAND(33)==0 THEN
  !     DOHILF(33)=ROUND(FL_PWMPRO(1)); /* PWM WW1 ZIRKP               */
  !   FIN;
  !   IF Z_DOHAND(34)==0 THEN
  !     DOHILF(34)=ROUND(FL_PWMPRO(2)); /* PWM WW2 ZIRKP         */
  !   FIN;
  !   IF Z_DOHAND(35)==0 THEN
  !     DOHILF(35)=ROUND(FL_PWMPRO(3)); /* PWM WW3 ZIRKP         */
  !   FIN;
  !   IF Z_DOHAND(36)==0 THEN
  !     DOHILF(36)=ROUND(FL_PWMPRO(4)); /* PWM WW4 ZIRKP         */
  !   FIN;
      /* senden Digitalausgaenge CAN-Erweiterungskarte 1 */
      IF ZCANPLAT > 0 THEN
        IF I==5 THEN         
          CALL SENDCANFIXED(1, CANBASE+11, 8, DOHILF(33), DOHILF(34), DOHILF(35), DOHILF(36), 20);
          CALL SENDCANFIXED(1, CANBASE+12, 8, DOHILF(37), DOHILF(38), DOHILF(39), DOHILF(40), 20);
        ELSE
          CALL SENDCANFIXED(1, CANBASE+13, 8, DOHILF(41), DOHILF(42), DOHILF(43), DOHILF(44), 20);
          CALL SENDCANFIXED(1, CANBASE+14, 8, DOHILF(45), DOHILF(46), DOHILF(47), DOHILF(48), 20);
        FIN;
      FIN;
    END;
!   FOR I FROM 7 TO 8 REPEAT  /* Digitalausgaenge CAN-EW-Karte 2 */
!     FOR K TO 8 REPEAT
 !      IF B_DO((I-1)*8+K) THEN       /* EIN  */
 !        DOHILF((I-1)*8+K)=100;
 !      ELSE                          /* AUS  */
 !        DOHILF((I-1)*8+K)=0;
 !      FIN;
!     END;
!     /* senden Digitalausgaenge CAN-Erweiterungskarte 2 */
!     IF ZCANPLAT > 1 THEN
!       IF I==7 THEN
!         CALL SENDCANFIXED(1, CANBASE+27, 8, DOHILF(49), DOHILF(50), DOHILF(51), DOHILF(52), 20);
!         CALL SENDCANFIXED(1, CANBASE+28, 8, DOHILF(53), DOHILF(54), DOHILF(55), DOHILF(56), 20);
!       ELSE
!         CALL SENDCANFIXED(1, CANBASE+29, 8, DOHILF(57), DOHILF(58), DOHILF(59), DOHILF(60), 20);
!         CALL SENDCANFIXED(1, CANBASE+30, 8, DOHILF(61), DOHILF(62), DOHILF(63), DOHILF(64), 20);
!       FIN;
!     FIN;
!   END;
!   FOR I FROM 9 TO 10 REPEAT  /* Digitalausgaenge CAN-EW-Karte 3 */
!     FOR K TO 8 REPEAT
 !      IF B_DO((I-1)*8+K) THEN       /* EIN  */
 !        DOHILF((I-1)*8+K)=100;
 !      ELSE                          /* AUS  */
 !        DOHILF((I-1)*8+K)=0;
 !      FIN;
!     END;
!     IF Z_DOHAND(65)==0 THEN
!       DOHILF(65)=ROUND(FL_PWMPRO(23)); /* WW2 Ladepumpe           */
!     FIN;
!     IF Z_DOHAND(67)==0 THEN
!       DOHILF(67)=ROUND(FL_PWMPRO(24)); /* WW2 Speisepumpe   */
!     FIN;
!     /* senden Digitalausg‰nge CAN-Erweiterungskarte 3 */
!     IF ZCANPLAT > 2 THEN
!       IF I==9 THEN         
!         CALL SENDCANFIXED(1, CANBASE+43, 8, DOHILF(65), DOHILF(66), DOHILF(67), DOHILF(68), 20);
!         CALL SENDCANFIXED(1, CANBASE+44, 8, DOHILF(69), DOHILF(70), DOHILF(71), DOHILF(72), 20);
!       ELSE
!         CALL SENDCANFIXED(1, CANBASE+45, 8, DOHILF(73), DOHILF(74), DOHILF(75), DOHILF(76), 20);
!         CALL SENDCANFIXED(1, CANBASE+46, 8, DOHILF(77), DOHILF(78), DOHILF(79), DOHILF(80), 20);
!       FIN;
!     FIN;
!   END;
!   /* senden Analogausgaenge CAN-Erweiterungskarte 1 */
!   IF ZCANPLAT > 0 THEN  /* <<< Ausgaenge 9-12 an CAN-Platine1 */
!     FOR I TO 4 REPEAT
!       PWMAA(I)=1000-ROUND((((AP_UHIGH(I+8)-AP_ULOW(I+8))*0.01*X_AAUS(I+8)+AP_ULOW(I+8))/10.0)*1000.0);
!     END; 
!     CALL SENDCANFIXED(1, CANBASE+15, 8, PWMAA(1), PWMAA(2), PWMAA(3), PWMAA(4), 20);
!   FIN;
!   /* senden Analogausgaenge CAN-Erweiterungskarte 2 */
!   IF ZCANPLAT > 1 THEN  /* <<< Ausgaenge 13-16 an CAN-Platine2 */
!     FOR I TO 4 REPEAT
!       PWMAA(I)=1000-ROUND((((AP_UHIGH(I+12)-AP_ULOW(I+12))*0.01*X_AAUS(I+12)+AP_ULOW(I+12))/10.0)*1000.0);
!     END; 
!     CALL SENDCANFIXED(1, CANBASE+31, 8, PWMAA(1), PWMAA(2), PWMAA(3), PWMAA(4), 20);
!   FIN;
!   /* senden Analogausgaenge CAN-Erweiterungskarte 3 */
!   IF ZCANPLAT > 2 THEN  /* <<< Ausgaenge 17-20 an CAN-Platine3 */
!     FOR I TO 4 REPEAT
!       PWMAA(I)=1000-ROUND((((AP_UHIGH(I+16)-AP_ULOW(I+16))*0.01*X_AAUS(I+16)+AP_ULOW(I+16))/10.0)*1000.0);
!     END; 
!     CALL SENDCANFIXED(1, CANBASE+47, 8, PWMAA(1), PWMAA(2), PWMAA(3), PWMAA(4), 20);
!   FIN;

    AFTER 0.5 SEC RESUME;

!   PUT 'CANIO FERTIG' TO A12 BY A,SKIP;

  END;

END;



BITWERT: PROC ((BI) BIT(1)) RETURNS (FIXED) GLOBAL;
  IF BI THEN
    RETURN(1);
  ELSE
    RETURN(0);
  FIN;
END;
FIXBIT: PROC ((FIX) FIXED) RETURNS (BIT(1)) GLOBAL;
  IF FIX==1 THEN
    RETURN('1'B);
  ELSE
    RETURN('0'B);
  FIN;
END;

/*********************************************************************/
/* Uebertragung der BHKW-Solldaten an die BHKW-Steuerung             */
/*********************************************************************/
BHKWSEND: TASK PRIO 29; /* Version Kraftwerk */

  DCL FIX1         FIXED;
  DCL FIX2         FIXED;
  DCL FIX3         FIXED;
  DCL FIX4         FIXED;
  DCL Z_EINZAE(8)  FIXED;
  DCL ZT_DATELETZT FIXED(31);
  DCL FL1          FLOAT;
  DCL F31          FIXED(31);

  ID_BBEIN(1)=   65;
  ID_PEBSOLL(1)= 321;
  ID_BBPNL(1)=   322;
  ID_BUHRDAT(1)=   323;
  ID_BBEIN(2)=   97;
  ID_PEBSOLL(2)= 353;
  ID_BBPNL(2)=   354;
  ID_BUHRDAT(2)=   355;

  Z_BCAN(1)=70;  /* 70s vorstrecken, CAN startet bei kraftwerk erst spaeter */
  Z_BCAN(2)=70;  /* 70s vorstrecken, CAN startet bei kraftwerk erst spaeter */

  REPEAT
    Z_BHKWSEND=Z_BHKWSEND+40;
    FOR I TO N_BHKW REPEAT
!   FOR I TO   0    REPEAT

      IF B_BEIN(I) AND Z_BTHERMVL(I) < 1 AND Z_BTHERMRL(I) < 1 THEN         
        Z_EINZAE(I)=Z_EINZAE(I)+1; 
      ELSE
        Z_EINZAE(I)=Z_EINZAE(I)-1;
      FIN;
      CALL FIXGRENZ(2,0,Z_EINZAE(I));

      IF Z_LZ > 50(31) THEN
        IF B_STOER(7) THEN  /* <<< GASSENSOR  */
          CALL SENDCANFIXED(1, ID_BBEIN(I), 2,   -1, 0, 0, 0, 50);
        ELSE
          IF Z_EINZAE(I)==2 THEN
            CALL SENDCANFIXED(1, ID_BBEIN(I), 2,    1, 0, 0, 0, 50);
          FIN;
          IF Z_EINZAE(I)==0 THEN
            CALL SENDCANFIXED(1, ID_BBEIN(I), 2,    0, 0, 0, 0, 50);
          FIN;
        FIN;
      ELSE
        IF B_BL(I) THEN
          B_BEIN(I)='1'B;
        FIN;
      FIN;

      AFTER 0.02 SEC RESUME;

      CALL SENDCANFIXED(1, ID_PEBSOLL(I), 2, ROUND(PE_BSOLL(I)*100), 0, 0, 0, 50);
      AFTER 0.02 SEC RESUME;

      FIX1=BITWERT(Z_BPNL(I) > 1 OR B_BPMP(I));       /* BHKW- Pumpe oder Pumpennachlauf */
      IF FIX1 > 0 THEN
        FL1=TC_VSOLL+4.0;                         /* Soll-VL BHKW  */
        IF FL1 < TC_BVLMIN(I) THEN                /* Mindestwert */
          FL1=TC_BVLMIN(I);
        FIN;
        IF FL1 > TC_BHZGVO(1)-3.0 THEN            /* < VL-Thermostat - 3 */
          FL1=TC_BHZGVO(1)-3.0;
        FIN;
        TC_BVSOLL(I)=FL1;
        FIX2=ROUND(FL1*10);
        CALL SENDCANFIXED(1, ID_BBPNL(I), 2, FIX2, 0, 0, 0, 50);
      ELSE
        CALL SENDCANFIXED(1, ID_BBPNL(I), 2, FIX1, 0, 0, 0, 50);
        TC_BVSOLL(I)=0.0;
      FIN;
      AFTER 0.02 SEC RESUME;

      IF ZT_JAHR > ZT_DATELETZT THEN   /* Stuendlich Datum/Uhrzeit senden */
        FIX1=DA_JAH;               /* Datum und Manat in einer Variablen */
        FIX2=DA_DAT+DA_MON*256;
        FIX3=ZF_MIN+ZF_STD*256;    /* Stunde und Minute in einer Varaiblen */
        IF DA_WOTAG==7 THEN       
          FIX4=0+ZF_SEK*256;       /* Sekunde und Wochentag in einer Var.  */
        ELSE
          FIX4=DA_WOTAG+ZF_SEK*256;/* Sekunde und Wochentag in einer Var.  */
        FIN;
        CALL SENDCANFIXED(1, ID_BUHRDAT(I), 8, FIX1, FIX2, FIX3, FIX4, 50);
        AFTER 0.02 SEC RESUME;
      FIN;


      /****************************************************************/   
      /* Auswertung der Empfangsdaten von den BHKWs                   */ 
      /****************************************************************/

      IF Z_BCAN(I) > 5 THEN

      ELSE

        B_BBEREIT(I)= '0'B;                
        B_BLHILF(I)=  '0'B;               
        B_BMUSSEIN(I)='0'B;               
        B_BMUSSAUS(I)='0'B;                
        B_BWARN(I)=   '0'B;                
        PE_BIST(I)=   0.0;             
        PT_BIST(I)=   0.0;            
        X_AEIN(I*2+179) =  0.0;            
        X_AEIN(I*2+180) =  0.0;      

      FIN; 

      IF B_BSTOER(I) AND B_BERLAUBT(I) THEN  
        IF NOT B_STOER(I) THEN
          B_STOER(I)='1'B;
          FIX1=Z_FEHLERKRA(I)//100;
          FIX2=(Z_FEHLERKRA(I)-FIX1*100)//10;
          FIX3=Z_FEHLERKRA(I) REM 10;
          CALL STOERMELD(I,'BHKW ' CAT TOCHAR(I+48) CAT ' ' CAT TOCHAR(FIX1+48)
                                                            CAT TOCHAR(FIX2+48)
                                                            CAT TOCHAR(FIX3+48));
        FIN;
      ELSE
        B_STOER(I)='0'B;
      FIN; 
 
      IF B_BWARN(I) THEN
        IF NOT B_STOER(I+55) AND B_BERLAUBT(I) THEN
          B_STOER(I+55)='1'B;
          FIX1=Z_WARNKRA(I)//100;
          FIX2=(Z_WARNKRA(I)-FIX1*100)//10;
          FIX3=Z_WARNKRA(I) REM 10;
          CALL STOERMELD(I+55,'Warn. BHKW' CAT TOCHAR(I+48) CAT ' ' CAT TOCHAR(FIX1+48)
                                                                    CAT TOCHAR(FIX2+48)
                                                                    CAT TOCHAR(FIX3+48));
        FIN;
      ELSE
        B_STOER(I+55)='0'B;
      FIN;                  

      IF B_BLHILF(I) THEN
        IF Z_BBL(I)<8 THEN
          Z_BBL(I)=Z_BBL(I)+1;
        FIN;
      ELSE
        IF Z_BBL(I)>0 THEN 
          Z_BBL(I)=Z_BBL(I)-1;
        FIN;
      FIN;
      IF Z_BBL(I)>3 THEN
        B_BL(I)='1'B;
      ELSE
        B_BL(I)='0'B;         
      FIN;

      IF B_BMUSSEIN(I) THEN
        B_BEIN(I)='1'B;
      FIN;

      IF B_BMUSSAUS(I) THEN
        Z_MUSSAUS(I)=Z_MUSSAUS(I)+1;   
        IF Z_MUSSAUS(I)<10 THEN
          IF TC_VIST > TC_VSOLL - 2.0 THEN /* nur wenn warm genug die Anf. zuruecknehmen */
            B_BEIN(I)='0'B;
          FIN;
        ELSE
          Z_MUSSAUS(I)=11;
        FIN;
      ELSE
        Z_MUSSAUS(I)=0;
      FIN;

      Z_BCAN(I)=Z_BCAN(I)-1;
      CALL FIXGRENZ(150,-10,Z_BCAN(I));
      IF Z_BCAN(I) < -5 THEN
        IF NOT B_STOER(I+52) AND B_BERLAUBT2(I) THEN
          CALL STOERMELD(I+52,'CAN - BHKW' CAT TOCHAR(I+48));
          B_STOER(I+52)='1'B;
        FIN;
      ELSE
        IF Z_BCAN(I) > 40 THEN
          B_STOER(I+52)='0'B;
        FIN;
      FIN;

      /****************************************************************/
      
    END;
    AFTER 0.8 SEC RESUME;

    /* <<< UNTERSTATIONEN   */
    IF ZT_JAHR > ZT_DATELETZT THEN   /* Stuendlich Datum/Uhrzeit senden */
      FIX1=DA_DAT+DA_MON*256;  /* Datum und Manat in einer Variablen */
      FIX2=DA_JAH;
      FIX3=ZF_STD+ZF_MIN*256;  /* Stunde und Minute in einer Varaiblen */
      IF DA_WOTAG==7 THEN
        FIX4=ZF_SEK+0*256;/* Sekunde und Wochentag in einer Var.  */
      ELSE
        FIX4=ZF_SEK+DA_WOTAG*256;/* Sekunde und Wochentag in einer Var.  */
      FIN;
      CALL SENDCANFIXED(1, 100, 8, FIX1, FIX2, FIX3, FIX4, 50);
      AFTER 0.02 SEC RESUME;
      ZT_DATELETZT=ZT_JAHR+36000(31);
    FIN;

!   FIX1=ROUND(TC_VIST*10.0);  
! ! FIX1=ROUND(X_AEIN(2)*10.0);  
!   FIX2=ROUND(TC_AUSSEN*10.0);  
!   FIX3=ROUND(TC_ATSCHNITT*10.0);  
! ! FIX3=ROUND(TC_VSOLL*10.0);  
!   FIX4=1;  
!   CALL SENDCANFIXED(1, 101, 8, FIX1, FIX2, FIX3, FIX4, 50);
!   AFTER 0.02 SEC RESUME;

  ! IF B_KEIN(1) THEN
  !   FIX1=10;  
  ! ELSE
  !   FIX1= 0;  
  ! FIN;
  ! IF B_KEIN(2) THEN
  !   FIX2=10;  
  ! ELSE
  !   FIX2= 0;  
  ! FIN;
  ! FIX3=ROUND(X_AEIN(31)*100.0);  
  ! FIX4=0;  
  ! CALL SENDCANFIXED(1, 102, 8, FIX1, FIX2, FIX3, FIX4, 50);
  ! AFTER 0.02 SEC RESUME;

!   FOR I TO 1 REPEAT
!     FIX1=Z_BWFREIEXT(I);
!     FIX2=Z_BWSPAREXT(I);
!     FIX3=Z_BWMOGLEXT(I);
!     FIX4=0;
!     CALL SENDCANFIXED(1, 115+I*5, 8, FIX1, FIX2, FIX3, FIX4, 50);
!     AFTER 0.02 SEC RESUME;
!   END;

 !  PUT 'BHKWSEND FERTIG' TO A12 BY A,SKIP;


  END;

END;


LCD: TASK PRIO 15;
  DCL rim     DATION IN ALPHIC CREATED(RIM);
  DCL CHAR1  CHAR(1);
  DCL F15    FIXED;
  DCL ZESC   FIXED;

  OPEN LCD BY IDF('/LCD');
  
  ZESC=0;   
  LCDZEIL=1;
  LCDSPALT=1;
  REPEAT
    CHAR1=TOCHAR(0);    
    GET CHAR1 FROM rim BY A(1);
    BZEIL.BIT(32)='1'B;   /* es findet Schreibaktivitaet statt */
    F15=TOFIXED(CHAR1);
!   PUT F15 TO A2 BY F(4);
!   IF F15 > 32 AND F15 < 127 THEN
!     PUT ' ',CHAR1 TO A2 BY A,A;
!   FIN;
!   PUT TO A2 BY SKIP;
!   IF BTEST1 THEN
!     PUT ' Z:',LCDZEIL TO A2 BY A,F(4);
!     PUT ' S:',LCDSPALT TO A2 BY A,F(4),SKIP;
!     BTEST1='0'B;
!   FIN;
!   IF B_FERN OR 2>1 THEN
    IF B_FERN THEN
      PUT CHAR1 TO TERM BY A;
    ELSE
      IF F15 == 127 THEN  /* BUTTON */
        IF Z_BUTTON < 30 THEN
          Z_BUTTON=Z_BUTTON+1;
        FIN;
        BUTTON(Z_BUTTON,1)=LCDSPALT;
        BUTTON(Z_BUTTON,2)=LCDZEIL;
      FIN;
      IF ZESC > 0 THEN
        CASE ZESC
          ALT /* 1 */
            IF F15 == 89 OR F15 == 61 THEN  /* "Y" oder "=" jetzt kommt POS Cursur */
              ZESC=2;
            FIN;
            IF F15 == 31 THEN  /* umschalten auf ROT */
              XROT=LCDSPALT;
              YROT=LCDZEIL;      
              ZROT=0;   
              BROT='1'B;   
              ZESC=4;
            FIN;
            IF F15 == 30 THEN  /* umschalten auf NORMAL */
              BROT='0'B;   
              ZESC=4;
            FIN;
          ALT /* 2 POS Y  (ZEILE) */
            LCDZEIL=F15-31;
            IF DISPSTATUS.BIT( 3) THEN /* grosses Display   */
              IF LCDZEIL > 25 THEN  LCDZEIL=25;  FIN;
            ELSE
              IF LCDZEIL > 18 THEN  LCDZEIL=18;  FIN;
            FIN;
            IF LCDZEIL <  1 THEN  LCDZEIL= 1;  FIN;
            ZESC=3;
          ALT /* 3 POS X (SPALTE) */
            LCDSPALT=F15-31;
            IF DISPSTATUS.BIT( 3) THEN /* grosses Display   */
              IF LCDSPALT > 80 THEN  LCDSPALT=80;  FIN;
            ELSE
              IF LCDSPALT > 46 THEN  LCDSPALT=46;  FIN;
            FIN;
            IF LCDSPALT <  1 THEN  LCDSPALT= 1;  FIN;
     !      BTEST1='1'B;
            ZESC=0;
          ALT /* 4 jetzt kommt noch ein m (ENDE von umschalten ROT/NORMAL) */
            ZESC=0;
          ALT /* 5 jetzt kommt noch ein TOCHAR(30) (ENDE DISPLAY LOESCHEN) */
            ZESC=0;
          OUT
            ZESC=0;
        FIN;
      ELSE
        IF F15 == 27 THEN  /* ESC */
          ZESC=1;   
        FIN;
        IF F15 == 26 THEN  /* DISPLAY LOESCHEN */
          ZESC=5;   
          FOR I TO 18 REPEAT
       !    ZEIL(I)='1234567890123456789012345678901234567890abcdef';
            ZEIL(I)='                                              ';         
          END;
          FOR I TO 25 REPEAT
       !    ZEIL80(I)='1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij';
            ZEIL80(I)='                                                                                ';
          END;
          LCDZEIL=1;
          LCDSPALT=1;
          XROT=0;
          YROT=0;      
          ZROT=0;   
          BROT='0'B;   
          FOR I TO 30 REPEAT
            FOR K TO 2 REPEAT
              BUTTON(I,K)=0;
            END;
          END;
          Z_BUTTON=0;
        FIN;
        IF ZESC < 1 THEN
          IF F15 == 13 THEN  /* SKIP */
            LCDSPALT=1;
            LCDZEIL=LCDZEIL+1;
            IF DISPSTATUS.BIT( 3) THEN /* grosses Display   */
              IF LCDZEIL > 25 THEN  LCDZEIL=25;  FIN;
            ELSE
              IF LCDZEIL > 18 THEN  LCDZEIL=18;  FIN;
            FIN;
          ELSE
            IF F15 == 10 THEN  /* AUCH NOCH SKIP */
            ELSE
              IF DISPSTATUS.BIT( 3) THEN /* grosses Display   */
                IF LCDSPALT > 80 THEN  LCDSPALT=80;  FIN;
                IF LCDZEIL > 25  THEN  LCDZEIL=25;   FIN;
                ZEIL80(LCDZEIL).CHAR(LCDSPALT)=CHAR1;
                IF LCDSPALT < 47 AND LCDZEIL < 19 THEN
                  ZEIL(LCDZEIL).CHAR(LCDSPALT)=CHAR1;
                FIN;
              ELSE
                IF LCDSPALT > 46 THEN  LCDSPALT=46;  FIN;
                IF LCDZEIL > 18  THEN  LCDZEIL=18;   FIN;
                ZEIL(LCDZEIL).CHAR(LCDSPALT)=CHAR1;
                ZEIL80(LCDZEIL).CHAR(LCDSPALT)=CHAR1;
              FIN;
              BZEIL.BIT(LCDZEIL)='1'B;
              LCDSPALT=LCDSPALT+1;
              IF BROT THEN  ZROT=ZROT+1;  FIN;
            FIN;
          FIN;
        FIN;
      FIN;
    FIN;
!   IF Z_FERN > 6 AND Z_FERN < 27 THEN  /* Unterstationen 1-10 (NR_SLAVE=4-13) */
!     IF DISPSTATUS.BIT( 1) THEN  /* normales Display  */
!       DISPSTATUS.BIT( 1)='0'B; /* normales Display  */
!       DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
!       DISPSTATUS.BIT( 3)='1'B; /* grosses Display   */
!     FIN;
!     IF ZROT > 30 THEN 
!       DISPSTATUS.BIT( 1)='0'B; /* normales Display  */
!       DISPSTATUS.BIT( 2)='1'B; /* "Anzeige"         */
!       DISPSTATUS.BIT( 3)='0'B; /* grosses Display   */
!     FIN; 
!     IF ZROT > 0 AND ZROT < 6 AND NOT BROT AND DISPSTATUS.BIT( 2) THEN 
!       DISPSTATUS.BIT( 1)='0'B; /* normales Display  */
!       DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
!       DISPSTATUS.BIT( 3)='1'B; /* grosses Display   */
!     FIN;
!
!     IF LCDSPALT > 46 THEN 
!       DISPSTATUS.BIT( 1)='0'B; /* normales Display  */
!       DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
!       DISPSTATUS.BIT( 3)='1'B; /* grosses Display   */
!     FIN;
!     IF ZROT > 30 THEN 
!       DISPSTATUS.BIT( 1)='0'B; /* normales Display  */
!       DISPSTATUS.BIT( 2)='1'B; /* "Anzeige"         */
!       DISPSTATUS.BIT( 3)='0'B; /* grosses Display   */
!     ELSE
!       IF ZROT > 0 AND NOT BROT AND DISPSTATUS.BIT( 2) THEN 
!         DISPSTATUS.BIT( 1)='1'B; /* normales Display  */
!         DISPSTATUS.BIT( 2)='0'B; /* "Anzeige"         */
!         DISPSTATUS.BIT( 3)='0'B; /* grosses Display   */
!       FIN;
!     FIN;
!   FIN;
    XROT2=XROT;
    YROT2=YROT;
    ZROT2=ZROT;
    XROT3=XROT;
    YROT3=YROT;
    ZROT3=ZROT;
 !  PUT XROT,YROT,ZROT TO A1 BY F(3),F(3),F(3),SKIP;
  END;
    
END;


CANRIM: TASK PRIO 27;
  DCL rim     DATION IN ALPHIC CREATED(RIM);
  DCL CHAR1  CHAR(1);
  DCL ZZEI   FIXED;

  OPEN CAN_RIM BY IDF('/CANRIM');
  
  B_CANRIM='1'B;
  ZZEI=0;
  WHILE ZZEI < 4000 REPEAT
    CHAR1=TOCHAR(0);    
    ZZEI=ZZEI+1;
    GET CHAR1 FROM rim BY A(1);
    PUT CHAR1 TO A1 BY A(1);
  END;
  B_CANRIM='0'B;

  CLOSE CAN_RIM;
    
END;

CANRIMEND: TASK PRIO 27;
  
  B_CANRIM='0'B;
  AFTER 5 SEC RESUME;
  TERMINATE CANRIM;
    
END;


/*********************************************************************/
RESET: TASK PRIO 30;
  PUT 'TERMINATE Watch -- PREVENT WATCHDOG' TO RTOS BY A;
END;



TESTLCD: TASK PRIO 10;

  CALL D_CLR;
  PUT 'Teste LCD' TO LCD BY A,SKIP;
  PUT 'OK' TO LCD BY A,SKIP;

END;


/*********************************************************************/
FERNBED2: TASK PRIO 4;
  DCL CHAR1   CHAR(1);
  DCL BLOOP   BIT(1);
  DCL F15     FIXED; 
  DCL Z       FIXED; 

  AFTER 20 MIN ACTIVATE NAHBED;
  BLOOP='1'B;
  F15=0;
  WHILE BLOOP REPEAT
    IF FTAST > 0 OR F31ANTWORT1 > 0 THEN
      BLOOP='0'B;
    ELSE
      AFTER 0.01 SEC RESUME;
    FIN;    
    F15=F15+1;
  END;  

  CALL ANZ_AUS;
  PUT TOCHAR(7) TO LCD;      /* TV 920 BEEP */
  AFTER 1.0 SEC RESUME;
  CALL D_CLR;
  PUT 'Taste vor Ort betaetigt!!' TO LCD BY A;
  AFTER 1.0 SEC RESUME;
  ACTIVATE NAHBED;
END;

/*********************************************************************/
FERNBED: TASK PRIO 8;
  DCL CH34 CHAR(34);
  DCL CH5  CHAR(5);
  DCL CH1  CHAR(1);
  DCL LCDTEST  FIXED;
  DCL STAT    BIT(32);

  Z_SERVPAUS=0;
  STAT=TASKST('FERNBED2');
  IF STAT.BIT(1) THEN /* DORM */
    X_GEHEIMINT=0;
    X_GEHEIMEXT=0;
    X_GEHEIM=0;
    B_TASTATUR='0'B;
    Z_FERN=0;
    PREVENT NAHBED;
    TERMINATE NAHBED;
    PREVENT RESET;
    AFTER 20 MIN ACTIVATE NAHBED;
  
    NEWDAT='/TY';
    OPEN TERM BY IDF(NEWDAT);
  
    NEWDAT='/TYB';
    OPEN BTASTIN BY IDF(NEWDAT);
  
    PUT TOCHAR(26) TO TERM;            /* TV 910/912/920 lîschen       */
    PUT TOCHAR(30) TO TERM;            /* TV 910/912/920 POS 1         */
    PUT TOCHAR(7)  TO TERM;            /* TV 920 Beep                  */
    
    PUT 'Guten Tag!' TO TERM BY A,SKIP,SKIP;
  
    PUT 'Sie sind mit der ',IDSTRING TO TERM BY A,A,SKIP;             /* <<< */
  /*PUT 'Sie sind mit der ',IDSTRING,IDSTRING2 TO TERM BY A,A,A,SKIP; /*     */
    PUT 'verbunden. Die letzten Anrufer waren: ' TO TERM BY A,SKIP,SKIP;
    FOR I TO 10 REPEAT
      PUT NAMESTR(I),'am ',DA_DATCALL(I),'.',DA_MONCALL(I),'. um',ZP_CALL(I) 
       TO TERM BY A,A,F(2),A,F(2),A,T(10),SKIP;
    END;
    PUT TO TERM BY SKIP;
    AFTER 1 SEC RESUME;
  
  
    PUT 'Bitte geben Sie jetzt Ihren Namen ein!',
        '(max. 34 Zeichen)',
  
        '.................................. (mit ENTER bestaetigen)'
      TO TERM BY A,SKIP,A,SKIP,SKIP,A;
  
    PUT TOCHAR(27),'=',TOCHAR(31+20),TOCHAR(31+1) TO TERM;
    GET CH34 FROM BTASTIN BY SKIP,A;
    IF CH34 /= 'mst sulingenn' AND CH34 /= 'mst sulingenN' THEN
      FOR K FROM 9 BY -1 TO 1 REPEAT
        NAMESTR(K+1)=NAMESTR(K);
        DA_DATCALL(K+1)=DA_DATCALL(K);
        DA_MONCALL(K+1)=DA_MONCALL(K);
        ZP_CALL(K+1)=ZP_CALL(K);
      END;
      NAMESTR(1)=CH34;
      DA_DATCALL(1)=DA_DAT;
      DA_MONCALL(1)=DA_MON;
      ZP_CALL(1)=ZP_NOW;
    FIN;
  
  
    PREVENT I_DISP;
    TERMINATE I_DISP;
    PREVENT DISPLAY;
    TERMINATE DISPLAY;
    PREVENT MENU;
    TERMINATE MENU;
    CALL ANZ_AUS;
    AFTER 0.2 SEC RESUME;
    CALL ANZ_AUS;
  
  
    CALL D_CLR;
    CALL D_CS(1,4); /* nach unten verschoben wegen grossem Display */
    
 !  IF LCDTEST < 20 THEN
 !    PUT TOCHAR(27),'Q' TO LCD;
 !    PUT TOCHAR(27),'V' TO LCD;
 !    PUT ' --------------------------------------' TO LCD BY A,SKIP;
 !    PUT ' I      > > > R T O S - U H < < <     I' TO LCD BY A,SKIP;
 !    PUT ' I        Fernbedienung laeuft        I' TO LCD BY A,SKIP;
 !    PUT ' I           Bitte  warten.           I' TO LCD BY A,SKIP;
 !    PUT ' I            Anruf durch:            I' TO LCD BY A,SKIP;
 !    PUT ' I                                    I' TO LCD BY A,SKIP;
 !    PUT ' I                                    I' TO LCD BY A,SKIP;
 !    PUT ' --------------------------------------' TO LCD BY A;
 !
 !    CALL D_CS(4,10);
 !    IF CH34 /= 'mst sulingenn' AND CH34 /= 'mst sulingenN' THEN
 !      PUT NAMESTR(1) TO LCD BY A;
 !    ELSE
 !      PUT 'mst sulingen' TO LCD BY A;
 !    FIN;
 !  ELSE
 !    PUT TO TERM BY SKIP;
 !    PUT 'LCD-Ausgabe blockiert, evtl. Reset erforderlich.  (ENTER)' TO TERM BY A;
 !    GET CH5 FROM BTASTIN BY SKIP,A;
 !  FIN;
      
    AFTER 0.2 SEC RESUME;
 !  NEWDAT='/TY';
 !  OPEN LCD BY IDF(NEWDAT);
    NEWDAT='/TYC';
    OPEN TAST2 BY IDF(NEWDAT);
    NEWDAT='/TYB';
    OPEN VIERTIN BY IDF(NEWDAT);
    NEWDAT='/TYB';
    OPEN BTASTIN BY IDF(NEWDAT);
    AFTER 0.1 SEC RESUME;
    B_FERN='1'B;
  
    PUT TOCHAR(7) TO LCD;        /* TV 920 BEEP                       */
    PUT TOCHAR(27),'f' TO LCD;   /* TV 920 Statuszeile beschreiben    */
 !  IF X_ZUGANG==1 THEN 
      PUT ' Ende: <E>      Invers: <I>             ',IDSTRING TO LCD BY A,A,SKIP;
 !  ELSE
 !    PUT ' Ende: <E>                  öbersicht:  ',IDSTRING TO LCD BY A,A,SKIP;
 !  FIN;
    PUT TOCHAR(27),'g' TO LCD;
  
    PUT TOCHAR(27),TOCHAR(27),'L' TO LCD;
  
    CALL D_CLR;
    CALL D_CS(1,1);
  
    STRING=TOCHAR(0);
    ACTIVATE I_DISP;
    ACTIVATE FERNBED2;
  ELSE
    NEWDAT='/TYB';
    OPEN MTY BY IDF(NEWDAT);
    PUT 'Fernbedienung ist schon aktiv Anrufer: ',
      NAMESTR(1),' am',DA_DATCALL(1),'.',DA_MONCALL(1),'. um',ZP_CALL(1) 
      TO MTY BY SKIP,A,SKIP,A,A,F(3),A,F(2),A,T(11),SKIP;
    PUT 'Bitte spaeter nochmal versuchen.' TO MTY BY A,SKIP;
  FIN;
END;



NAHBED: TASK PRIO 30 GLOBAL;

  Z_FERN=0;
  PREVENT FERNBED;                            
  TERMINATE FERNBED;
  PREVENT FERNBED2;                            
  TERMINATE FERNBED2;
  AFTER 2 MIN ACTIVATE RESET;
  B_DUE2='0'B;
  PREVENT I_DISP;
  TERMINATE I_DISP;
  PREVENT DISPLAY;
  TERMINATE DISPLAY;
  PREVENT MENU;
  TERMINATE MENU;
  CALL ANZ_AUS;
  AFTER 0.2 SEC RESUME;
  CALL ANZ_AUS;
  AFTER 0.2 SEC RESUME;

  PUT TOCHAR(7) TO LCD;      /* TV 920 BEEP */
  AFTER 0.2 SEC RESUME;
  CALL D_CLR;
  PUT '... Fernbedienung beendet ...' TO LCD BY A,SKIP;
  PUT TOCHAR(27),'f' TO LCD; /* TV 920 Statuszeile beschreiben */
  PUT ' - OFFLINE - ' TO LCD BY A,SKIP;
  PUT TOCHAR(27),'e' TO LCD; /* TV 920 Statuszeile ausschalten */
  PUT TOCHAR(27),TOCHAR(27),'T' TO LCD;

  B_FERN='0'B;   
  AFTER 0.5 SEC RESUME;
  GET CHAR40 FROM TAST2 BY A(40);
  IF B_PANEL THEN  /* PANEL */
!   NEWDAT='/A2';   
!   OPEN LCD BY IDF(NEWDAT);
    NEWDAT='/C1';
    OPEN TAST2 BY IDF(NEWDAT);
    NEWDAT='/B1';
    OPEN TERM BY IDF(NEWDAT);
    NEWDAT='/B2';  
    OPEN BTASTIN BY IDF(NEWDAT);
    NEWDAT='/B2';  
    OPEN VIERTIN BY IDF(NEWDAT);
  ELSE   /* LCD    */
!   NEWDAT='/LD/14.0/MDT';
!   OPEN LCD BY IDF(NEWDAT);
    NEWDAT='/C1';
    OPEN TAST2 BY IDF(NEWDAT);
    NEWDAT='/B1';
    OPEN TERM BY IDF(NEWDAT);
    NEWDAT='/B1';
    OPEN BTASTIN BY IDF(NEWDAT);
    NEWDAT='/B1';
    OPEN VIERTIN BY IDF(NEWDAT);
  FIN;
  AFTER 0.5 SEC RESUME;
  CALL D_CLR;
  ACTIVATE I_DISP;
  PREVENT RESET;
  X_GEHEIMINT=0;
  X_GEHEIMEXT=0;
  X_GEHEIM=0;

END;



/**********************************************************************************/           
/* TASK nach Reset um das Programm anhalten zu koennen bevor es richtig loslaeuft */
/**********************************************************************************/
STOP: TASK PRIO 10;
  DCL FIX1 FIXED;

! IF B_PANEL THEN  /* PANEL PC */
!   FIX1=1;
!   WHILE FIX1 == 1 REPEAT
!     GET STRING  FROM TAST BY A(1);         /* "v"        ALIVE MTERM PANEL */
!     IF TOFIXED(STRING)/=0 AND TOFIXED(STRING)/=118 AND TOFIXED(STRING)/=40 THEN
!       FIX1=2;
!     ELSE
!       AFTER 0.1 SEC RESUME;
!     FIN;
!   END;
! ELSE            /* LCD  */
!   GET STRING FROM TAST BY A(1);  /* Wartet auf Tastendruck      */
! FIN;
!
! TERMINATE START;
! CALL D_CS(3,6);
! PUT '         START abgebrochen!        ' TO LCD BY A;
! CALL D_CS(3,7);
! PUT '     System-Reset in 10 Minuten    ' TO LCD BY A;
! AFTER 10 MIN ACTIVATE RESET;

END;



/***************/
/*  SetBeepOn  */
/***************/

SetBeepOn : PROC ;

  SPI_SET_HUPE( 1 );

END; /* PROC SetBeepOn ------------------------------------------------------*/

/****************/
/*  SetBeepOff  */
/****************/

SetBeepOff : PROC ;

  SPI_SET_HUPE( 0 );

END; /* PROC SetBeepOff -----------------------------------------------------*/




CANINIT: TASK PRIO 8;
  DCL error   FIXED(15);
  DCL CAN_IN  can_init;

  /* CAN-Bus auf 125kBIT setzen                     */
  CAN_IN.baudrate  =   4  ;  /* 125kBit */
  CAN_IN.anz  =  64  ;

! error = CAN_INIT( 1, CAN_IN) ;  /* CAN-Bus 1 */
  error = CAN_INIT( 3, CAN_IN) ;  /* CAN-Bus 1   bei IF555-5 ist CAN1 = Kanal3, CAN2 = Kanal4 */
  !  0  : kein Fehler
  ! -1  : CAN-Baustein nicht verfuegbar
  ! -3  : Interface unzulaessig         
  ! -4  : Empfangspuffergroesse unzulaessig
  ! -14 : kein Speicher fuer Empfangspuffer  

  IF error < 0 THEN
    CANERRDEC(1,3000,(-error)) ;  
  FIN ;

  /* CAN-Bus Timeout setzen */
! error = CAN_SET_TIMEOUT( 1, 0.05 SEC ) ;
  error = CAN_SET_TIMEOUT( 3, 0.05 SEC ) ;  /* bei IF555-5 ist CAN1 = Kanal3, CAN2 = Kanal4 */
  !  0  : kein Fehler
  ! -1  : CAN-Baustein nicht verfuegbar
  ! -5  : keine Initialisierung durchgefuehrt

  IF error < 0 THEN
    CANERRDEC(1,4000,(-error)) ;
  FIN ;

! ACTIVATE CAN1EMPF;

END;


/**************/
/*  WatchExt  */
/**************/
WATCHEXT: TASK PRIO 5;
   DCL pWatch REF CHAR(1) ;

  /* 
   * Hier wird der externe Watchdog angeworfen. Dazu reichen Zugriffe
   * auf die angegebene Adresse.
   */

  REPEAT
    IF Z_WATCHEXT > 0 THEN
      pWatch = NIL ; REFADD( pWatch , TOFIXED('F7000000'B4) ) ;
      CONT pWatch = TOCHAR(0) ;
      Z_WATCHEXT=Z_WATCHEXT-1;
    FIN;
    AFTER 0.5 SEC RESUME ;
  END ;

END ; /* TASK WatchExt ------------------------------------------------------*/



I_HARDW: PROC GLOBAL;

  DCL TEXT    CHAR(80);
  DCL B1      BIT(1);
  DCL STAT    BIT(32);
  DCL error   FIXED(15);
  DCL FIX1    FIXED(15);
  DCL CAN_IN  can_init;
  DCL ZUFF1   FIXED(31);
  DCL ZUFF2   FIXED(31);
  DCL ZUFFL   FLOAT;

  PUT 'ANFANG noch nichts gemacht weiter in 10s   ' TO A1 BY A,SKIP;

  DISPSTATUS.BIT(1)='1'B; 
  BZEIL='FFFFFFFF'B4;
  ZEIL(3)=IDSTRING;
  ZEIL(5)='      Startvorgang laeuft !                   ';
  
! AFTER 10 SEC RESUME;
  AFTER  1 SEC RESUME;

  ZUFFL=RANF(ZUFF1,ZUFF2);
  FIX1=ROUND(ZUFFL*1000.0);
  PUT 'Zufallswartezeit  ',FIX1 TO A1 BY A,F(6),SKIP;
  CALL FIXGRENZ(1000,1,FIX1);
  AFTER FIX1*0.001 SEC RESUME;
  Z_WATCHEXT=100;
  ACTIVATE WATCHEXT;

  PUT 'weiter ANFANG ' TO A1 BY A,SKIP;

  B_TASTATUR='0'B;
  ACTIVATE CANINIT;

  PUT 'nach CANINT   ' TO A1 BY A,SKIP;

  ACTIVATE CAN1EMPF;
  PUT 'nach CAN1EMPF     ' TO A1 BY A,SKIP;


  /* <<< kontrollieren ob evtl. ein Programmupdate ueber den CAN-Bus */
  /* gemacht werden soll, dann SLAVEUPDATE aktivieren               */
  Z_CANUPD=0;
  FOR I TO 4 REPEAT
    AFTER 1 SEC RESUME;
  END;
  IF Z_CANUPD > 20 THEN
    OPEN SLNUM BY IDF('slnum'),ANY;
    CALL REWIND(SLNUM);
    FIX1=1;    /* Slavenummer in ed-Datei schreiben */
    PUT FIX1 TO SLNUM BY F(5);
    CLOSE SLNUM;
    AFTER 1 SEC RESUME;
    TERMINATE CAN1EMPF;
    AFTER 1 SEC RESUME;
    PUT 'ACTIVATE SLAVEUPDATE' TO RTOS BY A;
    PUT 'TERMINATE START' TO RTOS BY A;
  FIN;
  PUT 'nach UPDATE-Kontrolle  ' TO A1 BY A,SKIP;

  ACTIVATE LCD;

  FOR I TO 80 REPEAT            ! Strings fuer Atributplane besetzen
    TX_LEER.CHAR(I)=' ';        ! LeerString vorbesetzen TOCHAR(32)
    TX_REV.CHAR(I) ='U';        ! InversString vorbesetzen XXXX0101
  END;

  CALL D_GRAPHCLR;

  CALL D_CS(1,4);
  PUT IDSTRING TO LCD BY A;
  CALL D_CS(1,6);
  PUT '           START in ca.  8 s        ' TO LCD BY A,SKIP;
  PUT '     Abbruch mit irgendeiner Taste  ' TO LCD BY A,SKIP;


  ACTIVATE STOP;
  FOR I TO 6 REPEAT
    CALL D_CS(25,6);
    PUT 15-I TO LCD BY F(2);
    AFTER 0.1 SEC RESUME;
  END;

  PUT 'UNLOAD STOP' TO RTOS BY A,SKIP;
  PREVENT RESET;
! CALL D_CS(1,6);
! PUT '                                    ' TO LCD BY A,SKIP;
! PUT '     kein Abbruch mehr moeglich     ' TO LCD BY A,SKIP;

  AFTER 20 SEC ALL 0.8 SEC ACTIVATE WATCHDOG;

  IF N_FUEHLER>2 THEN
    TX_SET= 'TERMINATE Watch -- PREVENT WATCHDOG';
    PUT TX_SET TO RTOS BY A,SKIP; /* echten Reset durchfÅhren        */
  FIN;

  CALL RTC_DATUM;
  /* Befehlsstring vorbesetzen:                                      */
  TX_SET= 'DATESET 01-01-1995--CLOCKSET -T 00:00:00';

! PUT 'formatiere Ramdisk R0. ' TO A1 BY A,SKIP;
! PUT 'O A1.;FORM D /R0/C5DS10' TO RTOS BY A;
  AFTER 0.4 SEC RESUME;
  
  PUT 'vor RAMLES ' TO A1 BY A,SKIP;

  ZP_NOW=NOW;
  ACTIVATE RAMLES; /* gepufferte Variablen von H0. lesen             */
  Z_LETZT=0;
  STAT=TASKST('RAMLES');
  WHILE NOT STAT.BIT(1) AND Z_LETZT < 30 REPEAT
    Z_LETZT=Z_LETZT+1;
    AFTER 0.5 SEC RESUME;
    STAT=TASKST('RAMLES');
  END;  

  IF Z_LETZT > 29 THEN
    PUT 'nach RAMLES nicht geschafft ' TO A1 BY A,SKIP;
    TERMINATE RAMLES;
  ELSE
    PUT 'nach RAMLES geschafft ' TO A1 BY A,SKIP;
  FIN;
  AFTER 0.2 SEC RESUME;
  
  PUT 'ER NIL.; LOAD H0.SR--TEST;' TO RTOS BY A;

  ALL 0.8 SEC ACTIVATE WATCHDOG;
  PUT 'TERMINATE Watch' TO XC;    /* das war die Uebergabe an unseren eigen Watchdog */

  ACTIVATE CANREAD;
  ACTIVATE IT_LOOP;

  AFTER 10 SEC ACTIVATE SERTAST1;

  PUT 'ENDE IHARDW ' TO A1 BY A,SKIP;
        
END;


PROTPUT: PROC(FL FLOAT);
  DCL D   FIXED;
  DCL F15 FIXED;

  D=ROUND(FL*10.0);
  
  IF D < 0 THEN
    F15=D//10;
    IF F15 == 0 THEN
      PUT '   -0' TO PROT BY A;
    ELSE
      PUT F15 TO PROT BY F(5);
    FIN;
    PUT ',' TO PROT BY A;
    D=-D;
    PUT D REM 10 TO PROT BY F(1);
  ELSE
    PUT D // 10 TO PROT BY F(5);
    PUT ',' TO PROT BY A;
    PUT D REM 10 TO PROT BY F(1);
  FIN;
END;

SYSTEMOUT: PROC (AKT FIXED) REENT GLOBAL;
/*********************************************************************/
/* Prozedur zur Lenkung von Fehlermeldungen                          */
/*********************************************************************/
  DCL F31   FIXED(31);
  DCL Q     FIXED;    
  DCL P     FIXED;
  DCL B1    BIT(1);
  DCL TEXT  CHAR(80);
  DCL CHAR1 CHAR(1);
  DCL STAT  BIT(32);
  DCL FIX1  FIXED;
  DCL FIX2  FIXED;
  DCL FIX3  FIXED;
  DCL FIX4  FIXED;
  DCL tmp32 BIT(32) ;
  DCL tmp16 BIT(16) ;



  STAT=TASKST('JOYSTICK');               /* NNNNN */
  IF STAT.BIT(21) OR (Z_PANELPAUS > 30 AND Z_PANELPAUS < 42) OR (Z_PANELPAUS > 90 AND Z_PANELPAUS < 102) THEN      /* TASK haengt vermutlich mit CWS? ODER PI REDET NICHT */
    Z_CWSJOY=Z_CWSJOY+1;
    IF Z_CWSJOY > 2 THEN
      PUT 'CLEAR B1.' TO RTOS;           /* SER1 zuruecksetzen */
      AFTER 0.1 SEC RESUME;
      PUT 'sb a1. 57600' TO RTOS;
      Z_CWSJOY=0;
      AFTER 0.1 SEC RESUME;
      PUT TO A1 BY SKIP;
      IF STAT.BIT(21) THEN     
        PUT 'A1 RESET JOY' TO A1 BY A,SKIP;
        CALL STOERMELD(82,'A1 RESET JOY');
      FIN;
      IF (Z_PANELPAUS > 30 AND Z_PANELPAUS < 42) OR (Z_PANELPAUS > 90 AND Z_PANELPAUS < 102) THEN     
        PUT 'A1 RESET PI' TO A1 BY A,SKIP;
        CALL STOERMELD(82,'A1 RESET PI');
      FIN;
    FIN;
  ELSE
    Z_CWSJOY=0;
  FIN;

! FIX1=DA_DAT+DA_MON*256;  /* Datum und Manat in einer Variablen */
! FIX2=DA_JAH;
! FIX3=ZF_STD+ZF_MIN*256;  /* Stunde und Minute in einer Varaiblen */
! FIX4=ZF_SEK+DA_WOTAG*256;/* Sekunde und Wochentag in einer Var.  */

  /* hier Master: Uhrzeit + Datum senden */
!  CALL SENDCANFIXED(1, 304, 8, FIX1, FIX2, FIX3, FIX4, 10);
  
  !IF 1 > 2 THEN
    CASE AKT
      ALT
        F31=0(31);
        IF Z_LZ REM 10(31) < 1(31) THEN
          IF Z_SYSOUT < 1 THEN Z_SYSOUT=1; FIN;
          CASE Z_SYSOUT
            ALT
              TEXT='PER B1.';
              B1=CMD_EXW(TEXT);
            ALT
              TEXT='PER /ED/FEHLER';
              B1=CMD_EXW(TEXT);
            ALT
              TEXT='PER /H0/FEHLER';
              B1=CMD_EXW(TEXT);
            ALT
              TEXT='PER B2.';
              B1=CMD_EXW(TEXT);
            OUT
          FIN;
        FIN;
        IF Z_LZ REM 3(31)==0(31) THEN
          CASE Z_SYSOUT     
            ALT
            ALT
              CALL SAVEP(FEHLER,F31);
              IF F31 > 4900(31) THEN
                TEXT='RM /ED/FEHLER';
                B1=CMD_EXW(TEXT);
              FIN;
            ALT
              CALL SAVEP(FEHL2,F31);
              IF F31 > 19500(31) AND Z_WATCH < 1 THEN
                TEXT='RM /H0/FEHLER';
                B1=CMD_EXW(TEXT);
              FIN;
            OUT
          FIN;
        FIN;
      ALT
        CALL D_CLR;
        CASE Z_SYSOUT    
          ALT
            PUT 'Systemmeldungen auf B1.' TO LCD BY A;
          ALT
            TEXT='ER NIL.; COPY.COP PRIO 10 /ED/FEHLER>/ED/MIST;';
            B1=CMD_EXW(TEXT);
            AFTER 0.1 SEC RESUME;
            CALL APPEND(FEHLER);
          ALT
            TEXT='ER NIL.; COPY.COP PRIO 10 /H0/FEHLER>/ED/MIST--;';
            B1=CMD_EXW(TEXT);
            AFTER 0.1 SEC RESUME;
            CALL APPEND(FEHL2);
          OUT
        FIN;
        Q=1;
        IF Z_SYSOUT==2 OR Z_SYSOUT==3 THEN
          OPEN MIST;
          CALL REWIND(MIST);
          Q=1;
          P=1;
          WHILE ST(MIST)==0 AND Q<10 REPEAT
            GET CHAR1 FROM MIST BY A(1);
            IF ST(MIST)==0 THEN
              PUT CHAR1 TO LCD BY A(1);
              P=P+1;
            ELSE
              PUT 'keine weiteren Meldungen' TO LCD BY SKIP,A;
              Q=7;
            FIN;
            IF (TOFIXED(CHAR1)==13 OR P>40) AND Q/=7 THEN           
              PUT TO LCD BY SKIP;
              Q=Q+1;
              P=1;
            FIN;
            IF Q>5 THEN
              IF Q==7 THEN
                PUT '   links: Ende     rot: loeschen        '
                  TO LCD BY SKIP,A;
              ELSE
                PUT 'links: Ende   unten: mehr  rot: loeschen'
                  TO LCD BY SKIP,A;
              FIN;
              CALL STICK;
              CALL D_CLR;
              CASE X_R
                ALT /* oben   */
                  Q=1;
                ALT /* unten  */
                  Q=1;
                ALT /* links  */
                  Q=20;
                ALT /* rechts */
                  Q=1;
                ALT /* rot    */
                  TEXT='ER NIL.; RM /ED/MIST';
                  B1=CMD_EXW(TEXT);
                  IF Z_SYSOUT == 2 THEN
                    TEXT='ER NIL.; RM /ED/FEHLER';
                    B1=CMD_EXW(TEXT);
                  ELSE
                    TEXT='ER NIL.; RM /H0/FEHLER';
                    B1=CMD_EXW(TEXT);
                  FIN;
                  Q=20;
                OUT
              FIN;
            FIN;
          END;
          CLOSE MIST;
        FIN;
      OUT
    FIN;
    
    B1='0'B;
    IF Z_PROTWART>0(31) THEN
      Z_PROTWART=Z_PROTWART-1(31);
    FIN;  
    IF     NOT B_PROTVOLL 
       AND NOT B_PROTSPERR 
       AND Z_PROTART(1)>0 
       AND Z_PROTWART<1 THEN
      IF ZF_PROTTAKT==0 THEN
        CASE Z_PROTART(1)
          ALT
          ALT
          ALT
            IF B_PROTMERK /= BI_DEINBEW(Z_PROTNUM(1)) THEN
              B1='1'B;
              B_PROTMERK=BI_DEINBEW(Z_PROTNUM(1));
            FIN;
          ALT
            IF B_PROTMERK /= BI_DAUS((Z_PROTNUM(1)-1)//8+1).BIT(16-((Z_PROTNUM(1)-1) REM 8)) THEN
              B1='1'B;
              B_PROTMERK=BI_DAUS((Z_PROTNUM(1)-1)//8+1).BIT(16-((Z_PROTNUM(1)-1) REM 8));
            FIN;
          ALT
          ALT
          OUT
        FIN;                              
      ELSE
        Z_PROTTAKT=Z_PROTTAKT+1;
        FOR I TO 16 REPEAT
          CASE Z_PROTART(I)+1
            ALT
            ALT  /* AI */
              FL_PROTINT(I)=FL_PROTINT(I)+X_AEIN(Z_PROTNUM(I));    
            ALT  /* AO */
              IF Z_PROTNUM(I) > 100 THEN
                FL_PROTINT(I)=FL_PROTINT(I)+FL_PWMPRO(Z_PROTNUM(I)-100);    
              ELSE
                FL_PROTINT(I)=FL_PROTINT(I)+X_AAUS(Z_PROTNUM(I));    
              FIN;
            ALT  /* DI Zustand */
              IF BI_DEINBEW(Z_PROTNUM(I)) THEN
                FL_PROTINT(I)=FL_PROTINT(I)+1.0;    
              FIN;  
            ALT  /* DO */
              IF BI_DAUS((Z_PROTNUM(I)-1)//8+1).BIT(16-((Z_PROTNUM(I)-1) REM 8)) THEN
                FL_PROTINT(I)=FL_PROTINT(I)+1.0;    
              FIN;  
            ALT  /* DI Impulse */
              FL_PROTINT(I)=FL_PROTINT(I)+P_DI(Z_PROTNUM(I));   
            ALT  /* HK VL IST */
              FL_PROTINT(I)=FL_PROTINT(I)+TC_VIST;    
            ALT  /* HK VL SOLL */
              FL_PROTINT(I)=FL_PROTINT(I)+TC_VSOLL;    
            OUT
          FIN;
        END;
  
        IF Z_PROTTAKT>=ZF_PROTTAKT THEN
          B1='1'B;
          Z_PROTTAKT=0;
        FIN;
      FIN;
      IF B1 THEN
        OPEN PROT BY IDF('PROT'),ANY;
        CALL APPEND(PROT);
        PUT DA_DAT,'.',DA_MON,'.',ZP_NOW TO PROT BY F(2),A,F(2),A,T(9);
        FOR I TO 16 REPEAT
          CASE Z_PROTART(I)+1
            ALT
            ALT  /* AI */
              IF ZF_PROTTAKT==0 THEN
                CALL PROTPUT(X_AEIN(Z_PROTNUM(I)));    
              ELSE
                CALL PROTPUT(FL_PROTINT(I)/ZF_PROTTAKT);    
              FIN;  
            ALT  /* AO */
              IF ZF_PROTTAKT==0 THEN
                IF Z_PROTNUM(I) > 100 THEN
                  CALL PROTPUT(FL_PWMPRO(Z_PROTNUM(I)-100));    
                ELSE
                  CALL PROTPUT(X_AAUS(Z_PROTNUM(I)));    
                FIN;
              ELSE
                CALL PROTPUT(FL_PROTINT(I)/ZF_PROTTAKT);    
              FIN;  
            ALT  /* DI Zustand */
              IF ZF_PROTTAKT==0 THEN
                IF BI_DEINBEW(Z_PROTNUM(I)) THEN
                  CALL PROTPUT(1);
                ELSE  
                  CALL PROTPUT(0);
                FIN;  
              ELSE
                CALL PROTPUT(FL_PROTINT(I)/ZF_PROTTAKT*100.0);    
              FIN;  
            ALT  /* DO */
              IF ZF_PROTTAKT==0 THEN
                IF BI_DAUS((Z_PROTNUM(I)-1)//8+1).BIT(16-((Z_PROTNUM(I)-1) REM 8)) THEN
                  CALL PROTPUT(1);
                ELSE  
                  CALL PROTPUT(0);
                FIN;  
              ELSE
                CALL PROTPUT(FL_PROTINT(I)/ZF_PROTTAKT*100.0);    
              FIN;  
            ALT  /* DI Leistung */
              IF ZF_PROTTAKT==0 THEN
                CALL PROTPUT(P_DI(Z_PROTNUM(I)));    
              ELSE
                CALL PROTPUT(FL_PROTINT(I)/ZF_PROTTAKT);    
              FIN;  
            ALT  /* HK VL IST */
              IF ZF_PROTTAKT==0 THEN
                CALL PROTPUT(TC_VIST);    
              ELSE
                CALL PROTPUT(FL_PROTINT(I)/ZF_PROTTAKT);    
              FIN;  
            ALT  /* HK VL SOLL */
              IF ZF_PROTTAKT==0 THEN
                CALL PROTPUT(TC_VSOLL);    
              ELSE
                CALL PROTPUT(FL_PROTINT(I)/ZF_PROTTAKT);    
              FIN;  
            OUT
          FIN;
          FL_PROTINT(I)=0.0;
        END;
        PUT TO PROT BY SKIP;
        CALL SAVEP(PROT,Z_PROTFUELL);
        IF Z_PROTFUELL > 700000(31) THEN
          B_PROTVOLL='1'B;
        FIN;      
        CLOSE PROT;       
      FIN;
    FIN;
    IF Z_PROTART(1)<1 THEN
      Z_PROTFUELL=0(31);
    FIN;
  !FIN;


   /* Kontrolle der UDNs */
   DOERR = SPI_GET_DO_ERR() ; /* */
   /* Ausgang 1-8  */
   IF DOERR.BIT(1) THEN
     Z_UDNSTOER(1)=0;  
   ELSE
     Z_UDNSTOER(1)=50;   
   FIN ;
   
   /* Ausgang 9-16  */
   IF DOERR.BIT(2) THEN
     Z_UDNSTOER(2)=0;  
   ELSE
     Z_UDNSTOER(2)=50;   
   FIN ;

   /* Ausgang 17-24  */
   IF DOERR.BIT(3) THEN
     Z_UDNSTOER(3)=0;  
   ELSE
     Z_UDNSTOER(3)=50;   
   FIN ;
   
   /* Ausgang 25-32  */
   IF DOERR.BIT(4) THEN
     Z_UDNSTOER(4)=0;  
   ELSE
     Z_UDNSTOER(4)=50;   
   FIN ;

  
END;

/*********************************************************************/
/* Protokollfunktion zum Aufzeichen der ZustÑnde von bis zu 8 KanÑlen*/
/*********************************************************************/
DATPROT: PROC;

  DCL X1    FIXED;
  DCL X2    FIXED;
  DCL X3    FIXED;
  DCL X4    FIXED;
  DCL X5    FIXED;
  DCL B1    BIT(1);
  DCL B2    BIT(1);
  DCL B3    BIT(1);
  DCL TEXT2 CHAR(80);
  DCL CH    CHAR(1);
  DCL STAT  BIT(32);
  

AGAIN:

  PUT TOCHAR(27),TOCHAR(27),'T' TO TERM;   /* Umschalten auf TVI  */
  PUT TOCHAR(26) TO TERM;                  /* TERMINAL LôSCHEN    */
  PUT TOCHAR(30) TO TERM;                  /* TERMINAL POS 1,1    */

      X1=0;
      B2='1'B;
      WHILE B2 REPEAT
        PUT TOCHAR(26) TO TERM;                  /* TERMINAL LôSCHEN    */
        PUT TOCHAR(30) TO TERM;                  /* TERMINAL POS 1,1    */
        PUT TOCHAR(27),'=',TOCHAR(31+2),TOCHAR(31+1) TO TERM; /* POS X,Y*/
        PUT '    Datenaufzeichnungsfunktion fuer Ein- und Ausgaenge' 
          TO TERM BY A,SKIP,SKIP;
        IF Z_PROTART(1) /= 0 THEN
          PUT '    Aufzeichnung' TO TERM BY A;
          FOR I TO 16 REPEAT     
            CASE Z_PROTART(I)+1
              ALT
              ALT
                PUT '  AI(',Z_PROTNUM(I),')' TO TERM BY A,F(3),A;
              ALT
                PUT '  AO(',Z_PROTNUM(I),')' TO TERM BY A,F(3),A;
              ALT
                PUT '  DI Zust(',Z_PROTNUM(I),')' TO TERM BY A,F(3),A;
              ALT
                PUT '  DO(',Z_PROTNUM(I),')' TO TERM BY A,F(3),A;
              ALT
                PUT '  DI Imp(',Z_PROTNUM(I),')' TO TERM BY A,F(3),A;
              ALT
                PUT ' HK-IST ' TO TERM BY A;
              ALT
                PUT ' HK-SOLL' TO TERM BY A;
              OUT
            FIN;
          END;
          PUT TO TERM BY SKIP;
          IF B_PROTVOLL THEN
            PUT '    lief   ' TO TERM BY A;
          ELSE
            PUT '    laeuft ' TO TERM BY A;
          FIN;
          IF ZF_PROTTAKT == 0 THEN
            PUT 'Zustandsgesteuert ' TO TERM BY A,SKIP;
          ELSE
            PUT 'alle ',ZF_PROTTAKT,' Sekunden' TO TERM BY A,F(5),A,SKIP;
          FIN;
          PUT '    Dateigroesse: ',Z_PROTFUELL TO TERM BY A,F(8),SKIP;
          IF B_PROTVOLL THEN
            PUT '    Datei ist voll ' TO TERM BY A,SKIP;
          FIN;           
        ELSE
          PUT '    keine Aufzeichnung aktiv ' TO TERM BY A,SKIP;
        FIN;

        PUT   'Auswahl:',
              ' 1: neue Aufzeichnung starten (alte Datei wird geloescht)',
              ' 2: gespeicherte Datei uebertragen '
        TO TERM BY A,SKIP,SKIP,A,SKIP,A,SKIP;
        IF Z_PROTART(1) /= 0 THEN
          PUT ' 3: Datei loeschen, Aufzeichnung fortsetzen',
              ' 4: Aufzeichnung beenden'
               
          TO TERM BY A,SKIP,A,SKIP;
        FIN;
        PUT   ' 5: ENDE Datenaufzeichnungsfunktion' TO TERM BY A,SKIP;
        PUT   'Eingabe: ' TO TERM BY SKIP,A;
        GET X1 FROM BTASTIN BY SKIP,F(3);

        IF X1 < 1 THEN GOTO AGAIN; FIN;

        CASE X1
          ALT /* 1: neue Aufzeichnung starten */
            ZF_PROTTAKT=0;
            FOR I TO 16 REPEAT
              Z_PROTART(I)=0;
              Z_PROTNUM(I)=0;
              FL_PROTINT(I)=0.0;
            END;         
            TEXT2='ER NIL.; RM /H0/PROT';
            B_PROTSPERR='1'B;
            B1=CMD_EXW(TEXT2);
            OPEN PROT BY IDF('PROT'),ANY;
            CALL REWIND(PROT);
            PUT 'Neue Aufzeichnung eingerichtet am   ',
               DA_DAT,'.',DA_MON,'.',DA_JAH,ZP_NOW
               TO PROT BY A,F(2),A,F(2),A,F(4),T(12),SKIP,SKIP; 
            B1='1'B;
            X1=1;
            WHILE B1 AND X1<17 REPEAT
              PUT TOCHAR(26) TO TERM;                  /* TERMINAL LôSCHEN    */
              PUT TOCHAR(30) TO TERM;                  /* TERMINAL POS 1,1    */
              PUT TOCHAR(27),'=',TOCHAR(31+2),TOCHAR(31+1) TO TERM; /* POS X,Y*/
              PUT '    Auswahl Kanal',X1,':' TO TERM BY A,F(2),A,SKIP;
              PUT '    1: Analogeingang  (AI)' TO TERM BY A,SKIP;
              PUT '    2: Analogausgang  (AO)' TO TERM BY A,SKIP;
              PUT '    3: Digitaleingang (DI Zustand)' TO TERM BY A,SKIP;
              PUT '    4: Digitalausgang (DO)' TO TERM BY A,SKIP;
              PUT '    5: Digitaleingang (DI Leistung(Imp))' TO TERM BY A,SKIP;
              PUT '    6: Hauptkreisvorlaufist' TO TERM BY A,SKIP;
              PUT '    7: Hauptkreisvorlaufsoll' TO TERM BY A,SKIP;
              PUT '    8: beenden' TO TERM BY A,SKIP;
              PUT '       Eingabe: ' TO TERM BY A;
              GET X2 FROM BTASTIN BY SKIP,F(3);
              PUT TO TERM BY SKIP;
              B3='1'B;
              CASE X2
                ALT
                  PUT '       AI(1-200): ' TO TERM BY A;
                ALT
                  PUT '       AO(1-120 (>100=PWM)): ' TO TERM BY A;
                ALT
                  PUT '       DI Zustand (1-150): ' TO TERM BY A;
                ALT
                  PUT '       DO(1-160): ' TO TERM BY A;
                ALT
                  PUT '       DI Leistung (1-150): ' TO TERM BY A;
                ALT
                  B3='0'B;
                ALT
                  B3='0'B;
                OUT
                  B1='0'B;
              FIN;
              IF B1 THEN
                IF B3 THEN
                  GET X3 FROM BTASTIN BY SKIP,F(3);
                FIN;
                CASE X2
                  ALT
                    IF X3>200 THEN X3=200; FIN;
                  ALT
                    IF X3>120 THEN X3=120; FIN;
                  ALT
                    IF X3>150 THEN X3=150; FIN;
                  ALT
                    IF X3>160 THEN X3=160; FIN;
                  ALT
                    IF X3>150 THEN X3=150; FIN;
                  ALT
                  ALT
                FIN;
                IF X3<1 THEN X3=1; FIN;
                IF X1==1 THEN
                  PUT TO TERM BY SKIP;
                  IF X2>2 AND X2<5 THEN
                    PUT '       1: Zustandsgesteuert' TO TERM BY A,SKIP;
                    PUT '       2: Zyklisch' TO TERM BY A,SKIP;
                    PUT '          Eingabe: ' TO TERM BY A;
                    GET X4 FROM BTASTIN BY SKIP,F(3);
                  ELSE
                    X4=2;
                  FIN;          
                  IF X4==2 THEN
                    PUT TO TERM BY SKIP; 
                    PUT '          Abtastrate in Sec: ' TO TERM BY A;
                    GET X5 FROM BTASTIN BY SKIP,F(5);
                    IF X5<1 THEN X5=1; FIN;
                    ZF_PROTTAKT=X5;
                  ELSE
                    ZF_PROTTAKT=0;      
                  FIN;                  
                FIN;    
                Z_PROTART(X1)=X2;
                Z_PROTNUM(X1)=X3;
                PUT 'Kanal',X1,':  ' TO PROT BY A,F(2),A;
                CASE Z_PROTART(X1)
                  ALT
                    PUT ' AI',Z_PROTNUM(X1) TO PROT BY A,F(3),SKIP;
                  ALT
                    PUT ' AO',Z_PROTNUM(X1) TO PROT BY A,F(3),SKIP;
                  ALT
                    PUT ' DI (Zust)',Z_PROTNUM(X1) TO PROT BY A,F(3),SKIP;
                  ALT
                    PUT ' DO',Z_PROTNUM(X1) TO PROT BY A,F(3),SKIP;
                  ALT
                    PUT ' DI (Imp)',Z_PROTNUM(X1) TO PROT BY A,F(3),SKIP;
                  ALT
                    PUT ' HK-IST ' TO PROT BY A,SKIP;
                  ALT
                    PUT ' HK-SOLL' TO PROT BY A,SKIP;
                  OUT   
                FIN;    
                X1=X1+1;   
              FIN;
          
            END;  
            PUT TO PROT BY SKIP;
            PUT ' Datum Uhrzeit ' TO PROT BY A; 
            FOR I TO X1-1 REPEAT
              PUT I TO PROT BY F(7);
            END;  
            PUT TO PROT BY SKIP;
            CLOSE PROT; 
            B_PROTSPERR='0'B;
            B_PROTVOLL='0'B;
            PUT TO TERM BY SKIP,SKIP;
            PUT 'aktuelles Datum: ',DA_DAT,'.',DA_MON,'.',DA_JAH,
                '  aktuelle Uhrzeit: ',ZP_NOW
               TO TERM BY A,F(2),A,F(2),A,F(4),A,T(12),SKIP; 
            PUT 'Start der Aufzeichnung in (Min): ' TO TERM BY A;
            GET X1 FROM BTASTIN BY SKIP,F(4);
            Z_PROTWART=X1*60(31);

    !     ALT /* 2: gespeicherte Datei Åbertragen */ 
    !       PUT TOCHAR(26) TO TERM;                  /* TERMINAL LôSCHEN    */
    !       PUT TOCHAR(30) TO TERM;                  /* TERMINAL POS 1,1    */
    !       AFTER 0.5 SEC RESUME;
    !       PUT '...........Datenuebertragung............',
    !           '.....bitte ASCII-Download starten!......'
    !         TO TERM BY A,SKIP,A,SKIP;
    !       AFTER 1 SEC RESUME;
    !       PUT TOCHAR(27),TOCHAR(27),'R' TO TERM;
    !
    !       GET X1 FROM BTASTIN BY SKIP,F(3);
    !  
    !       TEXT2='ER NIL.; COPY /H0/PROT > B2.';
    !       B_PROTSPERR='1'B;
    !       B1=CMD_EXW(TEXT2);
    !       AFTER 1 SEC RESUME;
    !       B_PROTSPERR='0'B;
    !       PUT TOCHAR(27),TOCHAR(27),'E' TO TERM;
    !       AFTER 3 SEC RESUME;
          ALT /* 2: gespeicherte Datei Åbertragen */ 
            PUT TOCHAR(26) TO TERM;                  /* TERMINAL LôSCHEN    */
            PUT TOCHAR(30) TO TERM;                  /* TERMINAL POS 1,1    */
            AFTER 0.3 SEC RESUME;
            PUT '...........Datenuebertragung............',
                '.....bitte ASCII-Download starten!......'
              TO TERM BY A,SKIP,A,SKIP;
            AFTER 1 SEC RESUME;
            PUT TOCHAR(27),TOCHAR(27),'R' TO TERM;

            GET X1 FROM BTASTIN BY SKIP,F(3);
       
            B_PROTSPERR='1'B;
            AFTER 0.1 SEC RESUME;
            CALL SEEK (PROT,0(31));          /* Anfang aufsuchen             */
            WHILE ST(PROT)==0 REPEAT
              CALL READ(PROT,CH);
              PUT CH TO TERM BY A;
              IF CH==TOCHAR(13) THEN
                PUT TOCHAR(10) TO TERM BY A;
              FIN;
            END;

            AFTER 1 SEC RESUME;
            B_PROTSPERR='0'B;
            PUT TOCHAR(27),TOCHAR(27),'E' TO TERM;
            PUT TO TERM BY SKIP;
            AFTER 3 SEC RESUME;
          ALT /* 3: */ 
            TEXT2='ER NIL.; RM /H0/PROT';
            B_PROTSPERR='1'B;
            B1=CMD_EXW(TEXT2);
            B_PROTSPERR='0'B;
            B_PROTVOLL='0'B;
          ALT /* 4: */ 
            ZF_PROTTAKT=0;
            FOR I TO 16 REPEAT
              Z_PROTART(I)=0;
              Z_PROTNUM(I)=0;
              FL_PROTINT(I)=0.0;
            END;         
            B_PROTVOLL='0'B;
          OUT /* 5: */
            B2='0'B;
        FIN;  
      END;

  PUT TOCHAR(27),TOCHAR(27),'E' TO TERM;
  AFTER 1 SEC RESUME;
  CALL D_CLR;
  PUT TOCHAR(27),TOCHAR(27),'L' TO TERM;   /* Umschalten auf LCD  */

END;  




/*********************************************************************/
RTC_DATUM: PROC GLOBAL;          /* Holt das Datum                   */

  DCL X_I  FIXED;

  TX_DATUM=DATE;

  DA_DAT=10*(TOFIXED(TX_DATUM.CHAR( 1))-48)+
             TOFIXED(TX_DATUM.CHAR( 2))-48;
  DA_MON=10*(TOFIXED(TX_DATUM.CHAR( 4))-48)+
             TOFIXED(TX_DATUM.CHAR( 5))-48;
  DA_JAH=10*(TOFIXED(TX_DATUM.CHAR( 9))-48)+
             TOFIXED(TX_DATUM.CHAR(10))-48;
  DA_JAH=1000*(TOFIXED(TX_DATUM.CHAR( 7))-48)+
          100*(TOFIXED(TX_DATUM.CHAR( 8))-48)+
           10*(TOFIXED(TX_DATUM.CHAR( 9))-48)+
               TOFIXED(TX_DATUM.CHAR(10))-48;

  IF DA_JAH>2059 THEN DA_JAH=2059; FIN;   /* > Tagesnummernueberlauf */
  DA_TNR=TAGESNR(DA_DAT, DA_MON, DA_JAH); /* Tagesnummer berechnen   */
  DA_WOTAG=1+( (DA_TNR-1) REM 7); /* Wochentag Montag bis Sonnetag   */
  X_I=TAGESNR(1,1,DA_JAH)-1;  /* Tagesnummer des 01.01 dieses Jahres */
  Z_JAHRTAG=DA_TNR-X_I;       /* Jahrestag des Jahres                */

END; /* of PROC RTC_DATUM */

/*********************************************************************/
RTC_SETZE: PROC ((STD,MIN,DAT,MON,JAH) FIXED) GLOBAL;
  DCL J1 FIXED;

  /* Zeit in Fixed wandeln                                           */
  ZF_STD=ENTIER( (ZP_NOW-00:00:00)/ 1 HRS );
  ZF_MIN=ENTIER( (ZP_NOW-00:00:00)/ 1 MIN ) - 60*ZF_STD;

  /* Befehlsstring vorbereiten                                       */
  TX_SET.CHAR(33)=TOCHAR(48+ ENTIER(STD/10));
  TX_SET.CHAR(34)=TOCHAR(48 + (STD REM 10));
  TX_SET.CHAR(36)=TOCHAR(48 + ENTIER(MIN/10));
  TX_SET.CHAR(37)=TOCHAR(48 + (MIN REM 10));
  TX_SET.CHAR(09)=TOCHAR(48 + ENTIER(DAT/10));
  TX_SET.CHAR(10)=TOCHAR(48 + (DAT REM 10));
  TX_SET.CHAR(12)=TOCHAR(48 + ENTIER(MON/10));
  TX_SET.CHAR(13)=TOCHAR(48 + (MON REM 10));
  IF DA_JAH>2059 THEN DA_JAH=2059; FIN;   /* > Tagesnummernueberlauf */
  TX_SET.CHAR(15)=TOCHAR(48 + ENTIER(JAH/1000));
  J1=ENTIER(JAH/1000);
  TX_SET.CHAR(16)=TOCHAR(48 + ENTIER((JAH-J1*1000)/100));
  J1=ENTIER(JAH/100);
  TX_SET.CHAR(17)=TOCHAR(48 + ENTIER((JAH-J1*100)/10));
  TX_SET.CHAR(18)=TOCHAR(48 + (JAH REM 10));
  Z_RTC=1000;
  AFTER 0.05 SEC RESUME;
  PUT TX_SET TO RTOS BY A,SKIP;
  Z_RTC=0;

END; /* of PROC RTCSET */

/**********************************************************************/
/* Die folgenden D_... Prozeduren versorgen den Terminal-Bildschirm,  */
/* wenn B_FERN = 1 ist und das LC-Display, wenn B_FERN = 0 ist.       */
/**********************************************************************/

D_CS: PROC ((X,Y) FIXED) GLOBAL;        ! Cursor auf Position X,Y

  PUT TOCHAR(27),'Y',TOCHAR(31+Y),TOCHAR(31+X) TO LCD;

END;


D_CLR: PROC GLOBAL;                     ! Lîscht Display- und Attributplane

  PUT TOCHAR(26) TO LCD;              ! TV 910/912/920 lîschen
  PUT TOCHAR(30) TO LCD;              ! TV 910/912/920 POS1

END;

D_RON: PROC GLOBAL;   ! umschalten auf ROT

  PUT TOCHAR(27),TOCHAR(31),'m' TO LCD;
 
END;

D_ROFF: PROC GLOBAL;            ! umschalten auf normal

  PUT TOCHAR(27),TOCHAR(30),'m' TO LCD;

END;


D_GRAPHCLR: PROC GLOBAL;                ! lîscht Grafik

  PUT TOCHAR(26) TO LCD;              ! TV 910/912/920 lîschen
  PUT TOCHAR(30) TO LCD;              ! TV 910/912/920 POS1

END;
/*********************************************************************/



CANREAD: TASK PRIO 16;
  DCL CHAR1(8)   CHAR(1);
  DCL TXID1   FIXED;
  DCL TXID2   FIXED;
  DCL TXID3   FIXED;
  DCL COUNT   FIXED;
  DCL B1      BIT(1);
  DCL WART    FIXED(31);
  DCL CH      CHAR(1);

  TXID1=1360; /* Handshake fuer Uebertragungen BHKW1 */                     
  TXID2=1392; /* Handshake fuer Uebertragungen BHKW2 */                     
  TXID3=1424; /* Handshake fuer Uebertragungen BHKW3 */                     

  COUNT=1;


  ZSTEU=0;
  REPEAT

    IF B_CANHAND THEN  /* Handshake erforderlich? (Kraftwerk) */
      IF N_BHKW > 0 THEN
        CALL SENDCANCHAR(1, TXID1, 0, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 180 );
      FIN;
      IF N_BHKW > 1 THEN
        CALL SENDCANCHAR(1, TXID2, 0, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 180 );
      FIN;
      IF N_BHKW > 1 THEN
        CALL SENDCANCHAR(1, TXID3, 0, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 180 );
      FIN;
      B_CANHAND='0'B;
    FIN;

    B1='1'B;
    IF Z_SCHREIBFERN /= Z_LESFERN THEN
      IF Z_LESFERN > 9999 THEN
        Z_LESFERN=1;
      ELSE 
        Z_LESFERN=Z_LESFERN+1;
      FIN;
      CH=CHFERN(Z_LESFERN);
      CHFERN(Z_LESFERN)=TOCHAR(0);
      
   !  IF TOFIXED(CH) > 0 THEN
   !    PUT CH TO A1 BY A;
   !  FIN;

      IF Z_FERN>0 AND TOFIXED(CH) > 0 THEN
        IF Z_FERN > 16000 THEN  /* KRAFTWERK-BHKW */
          IF ZSTEU > 0 THEN     /* ESC im Spiel */
            CASE ZSTEU
              ALT /* 1 */
                STEU1=TOFIXED(CH);
              ALT /* 2 */
                STEU2=TOFIXED(CH);
                IF STEU1==71 THEN    /* "G" irgendwas mit invers */
                  IF STEU2 > 48 THEN
                    IF LCDZEIL > 1 THEN
                      CALL D_RON;
                    FIN;
                  ELSE
                    IF LCDZEIL > 1 THEN
                      CALL D_ROFF;
                    FIN;
                  FIN;
                  ZSTEU= -1;
                FIN;
              ALT /* 3 */
                STEU3=TOFIXED(CH);
                IF B_CANREADAKT THEN
                  PUT TOCHAR(27) TO LCD BY A;                
                  PUT TOCHAR(STEU1) TO LCD BY A;                
                  PUT TOCHAR(STEU2) TO LCD BY A;                
                  PUT TOCHAR(STEU3) TO LCD BY A;                
                FIN;
                ZSTEU= -1; 
              OUT
            FIN;
            ZSTEU=ZSTEU+1;
          ELSE
            IF TOFIXED(CH)==26 THEN /* CLR */
              CALL D_CLR;
              ZSTEU=0;
            ELSE
              IF TOFIXED(CH)==27 THEN /* ESC */
                ZSTEU=1;
              ELSE
                IF B_CANREADAKT THEN
                  PUT CH TO LCD BY A;             /* Zeichen auf Anzeige     */
                FIN;
              FIN;
            FIN;
          FIN;
          CH=TOCHAR(0);
        ELSE  /* Z_FERN < 16000 */
          IF TOFIXED(CH)==255 THEN /* jetzt kommen 3 Steuerzeichen */
            ZSTEU=4;
          FIN;
          IF ZSTEU>0 THEN
            CASE ZSTEU
              ALT
                STEU3=TOFIXED(CH);
                CH=TOCHAR(0);
              ALT
                STEU2=TOFIXED(CH);
                CH=TOCHAR(0);
              ALT
                STEU1=TOFIXED(CH);
                CH=TOCHAR(0);
              OUT
            FIN;
            ZSTEU=ZSTEU-1;
            IF ZSTEU==0 THEN  /* alle Steuerzeichen ¸bertr. -> Auswertung */
              IF STEU1 == 254 THEN
                CALL D_CLR;
              ELSE
                IF STEU1 == 253 THEN
                  CALL D_ROFF;
                ELSE
                  IF STEU1 > 0 THEN
                    CALL D_RON;
                  FIN;
                FIN;
              FIN;
            FIN;
          ELSE              
            IF B_CANREADAKT THEN
              PUT CH TO LCD BY A;             /* Zeichen auf Anzeige     */
          !   PUT CH TO A1 BY A;             /* Zeichen auf Anzeige     */
            FIN;
            CH=TOCHAR(0);
          FIN;
        FIN;
      FIN;
    ELSE
      AFTER 0.1 SEC RESUME;
    FIN;

  END;
  
END;


                        
JOYSTICK: TASK PRIO 10;
  DCL CHAR1      CHAR(1);
  DCL F15        FIXED;
  DCL Z          FIXED;
  DCL ZPANEL1    FIXED;
  DCL FMENUEALT  FIXED;
  DCL ZEI        FIXED;
  DCL SPA        FIXED;

  FMENUEALT=0;
  FTAST=0;
  F31ANTWORT1=0;
  CHIN30=TOCHAR(0);
  Z_CIN30=1;
  REPEAT

    IF FTAST > 0 OR F31ANTWORT1 > 0 THEN
      Z_PANELPAUS=0;
      B_KEY='1'B;
      IF FTAST > 0 THEN
        PUT FTAST,' T' TO A1 BY F(6),A,SKIP;     /* TESTAUSGABE */
      FIN;
      IF F31ANTWORT1 > 0 THEN
        PUT F31ANTWORT1,' M' TO A1 BY F(6),A,SKIP;     /* TESTAUSGABE */
      FIN;
      IF FTAST > 4000 THEN /* Positionen aus Wochenkalender */
        NR_BUTTON=FTAST;
        STRING=TOCHAR(145);   /* Ausstieg aus STICK:  */
        FTAST=0;
      FIN;
      IF FTAST > 1000 THEN
        FTAST = FTAST - 1000;     
        ZEI = FTAST // 100;       /* 1-99 Z1, 100-199 Z2,... */
        SPA = FTAST REM 100;      /* 1-99 SPALTE */
        PUT ZEI,SPA TO A1 BY F(6),F(6),SKIP;     /* TESTAUSGABE */
        FOR I TO Z_BUTTON REPEAT                                                                               /* wenn einer der Buttons die Klickposition hat, */
          IF (BUTTON(I,1) == SPA-1 OR BUTTON(I,1) == SPA OR BUTTON(I,1) == SPA+1) AND BUTTON(I,2) == ZEI THEN  /* (bei Spalte +-1 Toleranz) dann Button Nr. I gedrueckt */
            NR_BUTTON=I+1000;
            PUT 'B',NR_BUTTON-1000,Z_BUTTON TO A1 BY A,F(4),F(4),SKIP;     /* TESTAUSGABE */
            STRING=TOCHAR(145);   /* Ausstieg aus STICK:  */
          FIN;  
        END;
        FTAST=0;                  /* keine weiteren Aktionen */
      FIN;
      IF FTAST > 0 THEN
     !  PUT FTAST TO A1 BY F(4),SKIP;     /* TESTAUSGABE */
        IF FTAST > 255 THEN  FTAST=255;  FIN;
        STRING=TOCHAR(FTAST);
     !  IF DISPSTATUS.BIT(31) THEN                                               /* Zahleneingabe moeglich */
          IF FTAST==11 OR FTAST==10 OR FTAST==8 OR FTAST==12 OR FTAST==13 THEN   /* Pfeiltasten oder ENTER */
            CHIN30='                              ';
            Z_CIN30=0;
          ELSE
            IF Z_CIN30 < 1 THEN  
              Z_CIN30=1;
            ELSE
              Z_CIN30=Z_CIN30+1;
              IF Z_CIN30 > 30 THEN  Z_CIN30=1;  FIN;
            FIN;
            CHIN30.CHAR(Z_CIN30)=TOCHAR(FTAST);
            IF FTAST==63 OR FTAST==36 OR FTAST==167 THEN   /* ? oder $ oder ß */
            ELSE
              STRING=TOCHAR(144);   /* Ausstieg aus STICK:  */
            FIN;
          FIN;
     !    PUT CHIN30 TO A1 BY A,SKIP;     /* TESTAUSGABE */
     !  ELSE
     !    CHIN30='                              ';
     !!   FOR I TO 30 REPEAT
     !!     CHIN30.CHAR(I)=TOCHAR(0);
     !!   END;
     !    Z_CIN30=1;
     !  FIN;
        F15=FTAST;
        FTAST=0;
        IF B_TASTATUR AND F15/=84 AND F15/=116 THEN
          B_TASTATUR='0'B;
        FIN;
        IF Z_FERN>0 THEN
          IF N_BHKW > 0 THEN
            CALL SENDCANFIXED(1, 1361, 2, F15, 0, 0, 0, 20);
          FIN;
          IF N_BHKW > 1 THEN
            CALL SENDCANFIXED(1, 1393, 2, F15, 0, 0, 0, 20);
          FIN;
          IF N_BHKW > 2 THEN
            CALL SENDCANFIXED(1, 1425, 2, F15, 0, 0, 0, 20);
          FIN;
          IF Z_FERN > 6 AND Z_FERN < 27 THEN  /* Unterstationen 1-10 (NR_SLAVE=4-13) */
            CALL SENDCANFIXED(1, 93, 4, X_GEHEIM, X_ZUGANG, 0, 0, 20);
            CALL SENDCANFIXED(1, 90, 2, F15, 0, 0, 0, 20);
          FIN;
        FIN;
      FIN;
      IF F31ANTWORT1 > 0 THEN
    !   PUT F31ANTWORT1 TO A1 BY F(4),SKIP;     /* TESTAUSGABE */
        IF Z_FERN > 0 THEN
          Z_FERN=0;
          AFTER 1 SEC RESUME;
        FIN;
        IF F31ANTWORT1 > 150 THEN  F31ANTWORT1=150;  FIN;
        F15=F31ANTWORT1 FIT F15;
        F31ANTWORT1=0(31);
     !  IF F15 /= FMENUEALT THEN
          FMENUEALT=F15;
          PREVENT I_DISP;
          TERMINATE I_DISP;
          PREVENT DISPLAY;
          TERMINATE DISPLAY;
          PREVENT MENU;
          TERMINATE MENU;
          PUT 'PREVENT GETVISANTWORT' TO RTOS BY A;
          PUT 'TERMINATE GETVISANTWORT' TO RTOS BY A;
          CALL ANZ_AUS;
          AFTER 0.1 SEC RESUME;
          CALL ANZ_AUS;
          ACTIVATE I_DISP;
          AFTER 0.1 SEC RESUME;
          PUNKT=ME_PUNKT(F15);
          ZEIG=ME_ZEIG(F15);
          IF F15 == 1 THEN
            STRING=TOCHAR(13);  /* ENTER */
          ELSE
            STRING=TOCHAR(12);  /* TASTE RECHTS */
          FIN;
     !  FIN;
      FIN;
      AFTER 3.5 SEC ACTIVATE RAMSCHREIB;  /* NNNNN */
    ELSE
      AFTER 0.05 SEC RESUME;
      ZPANEL1=ZPANEL1+1;
      IF ZPANEL1 > 7 THEN
        IF Z_PANELPAUS < 30000 AND NOT B_FERN THEN
          Z_PANELPAUS=Z_PANELPAUS+1;           /* alle 0,4s +1  ->  9000 pro Stunde */
        FIN;
        ZPANEL1=0;
        IF Z_PANELPAUS > 8999 THEN   /* nach einer Stunde ohne Kommunikation den Zaehler auf 0                         */
          Z_PANELPAUS=0;             /* dann kann 'A1 Reset PI' wiederholt werden; evtl. war ja zwischendurch schon    */
        FIN;                         /* 'Pi/Monitor reset' oder VPN-Modul AUS (-> neue Chance auf Erfolg)              */ 
      FIN;
    FIN;
    IF Z_TASTVERZ < 10000 THEN
      Z_TASTVERZ=Z_TASTVERZ+50;
    FIN;

  END;
END;



SERTAST: TASK PRIO 10;

  DCL CHAR1   CHAR(1);
  DCL F15     FIXED;

  REPEAT
    IF NOT B_FERN OR B_DUE2 THEN
      AFTER 1 SEC RESUME;
    ELSE
      GET CHAR1  FROM TAST2 BY A(1);
      IF TOFIXED(CHAR1)/=0 THEN
        STRING=CHAR1;
        IF Z_FERN>0 THEN
          F15=TOFIXED(STRING);
          IF N_BHKW > 0 THEN
            CALL SENDCANFIXED(1, 1361, 2, F15, 0, 0, 0, 20);
          FIN;
          IF N_BHKW > 1 THEN
            CALL SENDCANFIXED(1, 1393, 2, F15, 0, 0, 0, 20);
          FIN;
          IF N_BHKW > 2 THEN
            CALL SENDCANFIXED(1, 1425, 2, F15, 0, 0, 0, 20);
          FIN;
        FIN;
        IF Z_FERN > 6 AND Z_FERN < 27 THEN  /* Unterstationen 1-10 (NR_SLAVE=4-13) */
          CALL SENDCANFIXED(1, 93, 4, X_GEHEIM, X_ZUGANG, 0, 0, 20);
          CALL SENDCANFIXED(1, 90, 2, F15, 0, 0, 0, 20);
        FIN;
      ELSE
        AFTER 0.05 SEC RESUME;
      FIN;
    FIN;
    IF Z_TASTVERZ < 10000 THEN
      Z_TASTVERZ=Z_TASTVERZ+50;
    FIN;

  END;
END;


/* SERVERMeldungen ENTGEGEGNEHMEN z.B.:  "QA+energiekontor EM"  Benutzer "energiekontor EM" hat sich fuer die Bedienung angemeldet */
GETCHANTWORT3: TASK PRIO 18;
  DCL CHAR3      CHAR(3);
  DCL CHAR30(5)  CHAR(30);
  DCL AS         FIXED;
  DCL F15        FIXED;
  DCL ZDURCH     FIXED;
  DCL FIX1       FIXED;
  DCL FIX2       FIXED;
  DCL FIX3       FIXED;
  DCL conv_error FIXED;


  CHANTWORT3=TOCHAR(0);
  ZDURCH=0;
  REPEAT
    AS=TOFIXED(CHANTWORT3.CHAR(1));

    IF AS > 0 THEN
      AFTER 0.4 SEC RESUME;

      IF AS==81 THEN                             /* Q    */

        AS=TOFIXED(CHANTWORT3.CHAR( 2));
        IF AS==65 THEN                           /* A irgendwas mit Bediener           */
          AS=TOFIXED(CHANTWORT3.CHAR( 3));
          IF AS==62 THEN                         /* > Anmeldung Bediener               */
            CONVERT CHAR3,CHAR30(1) FROM CHANTWORT3 BY RST(conv_error), A(3), A(30);  
            IF conv_error==0 THEN
              Z_BEDIEN=Z_BEDIEN+1;
              IF Z_BEDIEN > 5 THEN  Z_BEDIEN=5;  FIN;
              CH_BEDIEN(Z_BEDIEN)=CHAR30(1);
              Z_BEDDAUER(Z_BEDIEN)=1800;
            ELSE
       !      PUT 'Anmeldung:  ERR' TO A1 BY A,SKIP;     /* TESTAUSGABE */
            FIN;
          ELSE
            IF AS==60 THEN                       /* < Abmeldung Bediener               */
              CONVERT CHAR3,CHAR30(1) FROM CHANTWORT3 BY RST(conv_error), A(3), A(30);  
              IF conv_error==0 THEN
                FOR I TO 5 REPEAT
                  IF CH_BEDIEN(I)==CHAR30(1) THEN
                    CH_BEDIEN(I)=TOCHAR(0);
                    Z_BEDIEN=Z_BEDIEN-1;
                    IF Z_BEDIEN < 1 THEN  Z_BEDIEN=1;  FIN;
                    Z_BEDDAUER(I)=0;
                  FIN;
                END;
              ELSE
      !         PUT 'Abmeldung:  ERR' TO A1 BY A,SKIP;     /* TESTAUSGABE */
              FIN;
            FIN;
          FIN;
        ELSE  /* NICHT A */

        FIN;
        CHANTWORT3=TOCHAR(0); /* abgearbeitet */

      ELSE  /* NICHT Q */
        CHANTWORT3=TOCHAR(0);
      FIN;
    ELSE  /* NICHT > 0 */
      AFTER 0.2 SEC RESUME;
      IF ZDURCH==0 THEN
        F15=0;
        FOR I TO 5 REPEAT
          IF Z_BEDDAUER(I) > 0 THEN            /* Bedienung extern?  Anzahl? */
            F15=F15+1;
            CHAR30(F15)=CH_BEDIEN(I);
            Z_BEDDAUER(I)=Z_BEDDAUER(I)-2;
            IF Z_BEDDAUER(I) < 1 THEN
              CH_BEDIEN(I)=TOCHAR(0);
            FIN;
          FIN;
        END;
        IF F15==0 THEN
          INFOTXT='Bedienung lokal';
        ELSE
          INFOTXT='Bedienung  ';
          FIX1=12;
          FOR I TO F15 REPEAT                  /* extern Bedientexte uebertragen in INFOTXT  jew. hoechstens 4 Leerzeichen */
            FIX2=0;
            FIX3=0;
            FOR K TO 30 REPEAT
              AS=TOFIXED(CHAR30(I).CHAR(K));
              IF AS == 32 OR AS == 0 THEN
                IF FIX2 < 4 THEN
                  FIX2=FIX2+1;  
                FIN;
              ELSE
                IF FIX2 < 4 THEN
                  FIX2=0;  
                FIN;
              FIN;
              IF FIX2 < 4 THEN
                FIX3=FIX3+1;
              FIN;
            END;
            FOR K TO FIX3 REPEAT
              AS=TOFIXED(CHAR30(I).CHAR(K));
              IF AS < 32 THEN  AS=32;  FIN;
              IF FIX1 > 120 THEN  FIX1=120;  FIN;
              INFOTXT.CHAR(FIX1)=TOCHAR(AS);
              FIX1=FIX1+1;  
            END;
          END;
        FIN;  
   !    PUT INFOTXT,CH_BEDIEN(1) TO A1 BY A,A,SKIP;
      FIN;
      ZDURCH=ZDURCH+1;
      IF ZDURCH > 9 THEN  ZDURCH=0;  FIN;
    FIN;
  END; /* REPEAT */

END;


/* SERVEREINGRIFFE ENTGEGEGNEHMEN z.B.:  Qa  -51 = -5,1∞C Aussentemp. */
GETCHANTWORT2: TASK PRIO 18;
  DCL CHAR1   CHAR(1);
  DCL CHAR2   CHAR(2);
  DCL AS      FIXED;
  DCL F15     FIXED;
  DCL conv_error FIXED;
  DCL JAH     FIXED;
  DCL MON     FIXED;
  DCL DAT     FIXED;
  DCL STD     FIXED;
  DCL MIN     FIXED;
  DCL SEK     FIXED;
  DCL F31     FIXED(31);


  CHANTWORT2=TOCHAR(0);

  REPEAT
    AS=TOFIXED(CHANTWORT2.CHAR(1));
    IF AS > 0 THEN
      AFTER 0.4 SEC RESUME;
      IF AS==81 THEN                             /* Q    */

        AS=TOFIXED(CHANTWORT2.CHAR( 2));
        IF AS==97 THEN                           /* a extern zugefuehrte Aussentemp.   */
          CONVERT CHAR2,F15 FROM CHANTWORT2 BY RST(conv_error), A(2), F(5);  
          IF conv_error==0 THEN
     !      PUT 'AT: ',F15*0.1 TO A1 BY A,F(6,1),SKIP;     /* TESTAUSGABE */
            FL_ATEXT=F15*0.1;
          ELSE
     !      PUT 'AT:  ERR' TO A1 BY A,SKIP;     /* TESTAUSGABE */
          FIN;
        ELSE  /* NICHT a */
          IF AS==98 THEN                         /* b externe Anforderung Beleuchtung IP-Kamera */
            CONVERT CHAR2,F15 FROM CHANTWORT2 BY RST(conv_error), A(2), F(5);  
            IF conv_error==0 THEN
     !        PUT 'Licht: ',F15,'s' TO A1 BY A,F(5),A,SKIP;     /* TESTAUSGABE */
              Z_IPLICHT=F15;
            ELSE
     !        PUT 'Licht:  ERR' TO A1 BY A,SKIP;     /* TESTAUSGABE */
            FIN;
          ELSE  /* NICHT b */
            IF AS==99 THEN                       /* c externe Angabe Datum, Uhrzeit */
              CONVERT CHAR2,JAH,MON,DAT,STD,MIN,SEK FROM CHANTWORT2 BY RST(conv_error), A(2), F(4), F(2), F(2), F(2), F(2), F(2);  
              IF conv_error==0 THEN
     !          PUT 'Jahr: ',JAH TO A1 BY A,F(5),SKIP;     /* TESTAUSGABE */
     !          PUT 'Mon:  ',MON TO A1 BY A,F(5),SKIP;     /* TESTAUSGABE */
     !          PUT 'Dat:  ',DAT TO A1 BY A,F(5),SKIP;     /* TESTAUSGABE */
     !          PUT 'Std:  ',STD TO A1 BY A,F(5),SKIP;     /* TESTAUSGABE */
     !          PUT 'Min:  ',MIN TO A1 BY A,F(5),SKIP;     /* TESTAUSGABE */
     !          PUT 'Sek:  ',SEK TO A1 BY A,F(5),SKIP;     /* TESTAUSGABE */
                F31=(STD*3600(31)+MIN*60(31)+SEK*1(31));
     !          PUT 'sTex:',F31 TO A1 BY A,F(6),SKIP;     /* TESTAUSGABE */
     !          PUT 'sTag:',Z_SEKTAG TO A1 BY A,F(6),SKIP;     /* TESTAUSGABE */
                IF Z_SEKTAG > 3600(31) AND Z_SEKTAG < 82800(31) THEN  /* nur zwischen 01:00 und 23:00 */
                  IF F31 > Z_SEKTAG + 30(31) THEN
                    Z_RTC=1000;
                    AFTER 0.5 SEC RESUME;
                    PUT 'CLOCKSET -T ',ZP_NOW + 10 SEC TO RTOS BY A,T(8);
                    Z_RTC=0;
                  ELSE
                    IF F31 < Z_SEKTAG - 30(31) THEN
                      Z_RTC=1000;
                      AFTER 0.5 SEC RESUME;
                      PUT 'CLOCKSET -T ',ZP_NOW - 10 SEC TO RTOS BY A,T(8);
                      Z_RTC=0;
                    ELSE
                      IF JAH /= DA_JAH OR DAT /= DA_DAT OR MON /= DA_MON THEN
                        IF  NOT B_STOER(71) THEN     /*    */
                          B_STOER(71)='1'B;                              /*    */
                          CALL STOERMELD(71,TX_STOERMEL(71));          /*    */
                        FIN;                                               /*    */
                      ELSE
                        B_STOER(71)='0'B;
                      FIN;
                    FIN;
                  FIN;
                FIN;
              ELSE
     !          PUT 'Date/Time:  ERR' TO A1 BY A,SKIP;     /* TESTAUSGABE */
              FIN;
            ELSE  /* NICHT c */
              IF AS==122 THEN                       /* z BUTTON in der Visu gedrueckt  */
                CALL VISTEXTFELD;
              ELSE /* NICHT z */
              FIN;
            FIN;
          FIN;
        FIN;
        CHANTWORT2=TOCHAR(0); /* abgearbeitet */

      ELSE  /* NICHT Q */
        CHANTWORT2=TOCHAR(0);
      FIN;
    ELSE  /* NICHT > 0 */
      AFTER 0.2 SEC RESUME;
    FIN;
  END; /* REPEAT */

END;



/* SERVERABFRAGEN ENTGEGEGNEHMEN z.B.:  Q22019061848 = Daten vorhanden bis 18.06.2019 12:00*/
SERTAST1: TASK PRIO 18;
  DCL CHAR1   CHAR(1);
  DCL AS      FIXED;
  DCL Z       FIXED;
  DCL Z2      FIXED;
  DCL Z3      FIXED;
  DCL ZREIHE  FIXED;
  DCL F15     FIXED;

  ACTIVATE GETCHANTWORT2;
  ACTIVATE GETCHANTWORT3;
  ACTIVATE VISUAL;

  CHANTWORT1=TOCHAR(0);

  REPEAT

    IF F31ANTWORT2 > 0(31) THEN
      F31ANTWORT2=0(31);
      Z_PANELPAUS=0;           /* Pi OK */
  !   PUT 'V005 Daten' TO A1 BY A,SKIP;
    FIN;

    AS=TOFIXED(CHANTWORT1.CHAR(1));
    IF AS > 0 THEN
      DISPSTATUS.BIT(30)='1'B; /* Datei wird erstellt  */
      AFTER 0.4 SEC RESUME;
      IF AS==80 OR AS==81 THEN                   /* P (von Pi)  Q (von Webterm)    */
        IF AS==80 THEN  Z_PANELPAUS=0;  FIN;     /* Pi OK */
        IF AS==81 THEN  Z_SERVPAUS=0;   FIN;     /* VPN OK */
        AS=TOFIXED(CHANTWORT1.CHAR( 2));
        IF AS==50 THEN                           /* 2    */
          AS=TOFIXED(CHANTWORT1.CHAR( 3));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM JAHR 1 */
            D_SERVDAT( 1)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR( 4));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM JAHR 2 */
            D_SERVDAT( 2)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR( 5));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM JAHR 3 */
            D_SERVDAT( 3)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR( 6));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM JAHR 4 */
            D_SERVDAT( 4)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR( 7));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM MONAT 1 */
            D_SERVDAT( 5)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR( 8));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM MONAT 2 */
            D_SERVDAT( 6)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR( 9));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM TAG   1 */
            D_SERVDAT( 7)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR(10));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM TAG   2 */
            D_SERVDAT( 8)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR(11));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM VIERT 1 */
            D_SERVDAT( 9)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR(12));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  DATUM VIERT 2 */
            D_SERVDAT(10)=AS-48;
          FIN;  
          D_SERVDAT(11)=9; D_SERVDAT(12)=6;      /* mit 96 vorbesetzen */
          AS=TOFIXED(CHANTWORT1.CHAR(13));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  gewuenschte ANZ 1/4h Teil1 */
            D_SERVDAT(11)=AS-48;
          FIN;  
          AS=TOFIXED(CHANTWORT1.CHAR(14));
          IF AS > 47 AND AS < 58 THEN            /* 0-9  gewuenschte ANZ 1/4h Teil2 */
            D_SERVDAT(12)=AS-48;
          FIN;  
          CHANTWORT1=TOCHAR(0);
          PREVENT VISUAL;
          TERMINATE VISUAL;
          AFTER 0.1 SEC RESUME;
          PUT 'ER NIL.;rm /RD02/viertdat.txt' TO RTOS BY A;
          PUT 'ER NIL.;rm /RD02/TEMP' TO RTOS BY A;
          OPEN TEMP BY IDF('TEMP'),ANY;
          CALL REWIND(TEMP);
          PUT 'P',NR_PRJ TO TEMP BY A,F(4);
          CALL DUE32;
          CLOSE TEMP;  
          PUT 'ER NIL.;RENAME /RD02/TEMP > viertdat.txt' TO RTOS BY A;
          AFTER 0.1 SEC RESUME;
          DISPSTATUS.BIT(30)='0'B; /* Datei fertig      */
          ACTIVATE VISUAL;
        ELSE  /* NICHT 2 */
          CHANTWORT1=TOCHAR(0);
        FIN;
      ELSE  /* NICHT Q */
        CHANTWORT1=TOCHAR(0);
      FIN;
    ELSE  /* NICHT > 0 */
      AFTER 0.05 SEC RESUME;
    FIN;
    DISPSTATUS.BIT(30)='0'B; /* Datei fertig      */
  END; /* REPEAT */

END;

    

STICK: PROC GLOBAL;

  DCL ID_FERNEND  FIXED;
  DCL ID_XR       FIXED;
  DCL ID_ZFERN    FIXED;
  DCL ID_XGEHEIM  FIXED;
  DCL ID_XR1      FIXED;
  DCL ID_ZFERN1   FIXED;
  DCL ID_XGEHEIM1 FIXED;
  DCL ID_XR2      FIXED;
  DCL ID_ZFERN2   FIXED;
  DCL ID_XGEHEIM2 FIXED;
  DCL ID_XR3      FIXED;
  DCL ID_ZFERN3   FIXED;
  DCL ID_XGEHEIM3 FIXED;
  DCL STAT        BIT(32);       /* !!! */
  DCL B_LOOP      BIT(1);        /* !!! */
  DCL X_RCAN      FIXED;
  DCL ZXR0        FIXED;
  DCL Z           FIXED;
  DCL ALTSTRING   CHAR(1);

    ID_XR1=1361;      ! H_Taste
    ID_ZFERN1=1362;   ! H_Fernbed_nr
    ID_XGEHEIM1=1363; ! H_GEHEIM
    ID_XR2=1393;      ! H_Taste
    ID_ZFERN2=1394;   ! H_Fernbed_nr
    ID_XGEHEIM2=1395; ! H_GEHEIM
    ID_XR3=1425;      ! H_Taste
    ID_ZFERN3=1426;   ! H_Fernbed_nr
    ID_XGEHEIM3=1427; ! H_GEHEIM
 !  ID_XR3=  90;      ! H_Taste
 !  ID_ZFERN3=  91;   ! H_Fernbed_nr
 !  ID_XGEHEIM3=  93; ! H_GEHEIM

    ID_XR=90;
    ID_ZFERN=91;
    ID_XGEHEIM=93;

    ID_FERNEND=1282;



  ZXR0=0;

  BZEIL.BIT(32)='0'B;   /* es findet KEINE Schreibaktivitaet statt */

  IF B_FERN THEN
    B_LOOP='1'B;
    WHILE B_LOOP REPEAT

      X_R=0;
  !   AFTER ZF_TASTVERZ*0.001 SEC RESUME;
      AFTER 0.10 SEC RESUME;
      STAT=TASKST('SERTAST');
      IF STAT.BIT(1) THEN
        ACTIVATE SERTAST;
      FIN;

  !   IF X_F==1 THEN
  !     AFTER 0.1 SEC RESUME;
  !   FIN;

      IF TOFIXED(STRING) == 0  THEN X_R=0;                            FIN; /* MITTE*/
      IF TOFIXED(STRING) == 11 THEN X_R=1; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* OBEN */
      IF TOFIXED(STRING) == 10 THEN X_R=2; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* UNTEN*/
      IF TOFIXED(STRING) == 8  THEN X_R=3; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* LINKS*/
      IF TOFIXED(STRING) == 12 THEN X_R=4; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* RECH.*/
      IF TOFIXED(STRING) == 13 THEN X_R=5; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* ENTER*/
      IF TOFIXED(STRING) == 144 THEN X_R=144; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* Ausstieg Tastatureingabe */
   !  IF TOFIXED(STRING) > 0  THEN 
   !    IF ALTSTRING==STRING THEN     /* selbe Taste nochmal? */
   !    ELSE
   !      Z_TASTVERZ=ZF_TASTVERZ+1;
   !    FIN;
   !    ALTSTRING=STRING;
   !  FIN;

      IF (STRING == 'T' OR STRING == 't') AND Z_FERN==0 THEN
        B_TASTATUR='1'B;
        X_R=0;
        B_LOOP='0'B;
      FIN;

      IF NOT B_LOOP THEN
        B_KEY='1'B;
      FIN;

      IF B_DUE2 THEN
        WHILE B_DUE2 REPEAT
          AFTER 2 SEC RESUME;
        END;        
        X_R=3; B_LOOP='0'B; /* LINKS*/
      FIN;

      IF Z_FERN==0 THEN
        IF STRING == 'E' OR STRING == 'e' THEN
          AFTER 0.2 SEC ACTIVATE NAHBED;
        FIN;

        IF STRING == '?' THEN
          X_GEHEIMINT=226;
          X_GEHEIM=226;
          PUT 'AFTER 20 MIN ACTIVATE ENDE' TO RTOS BY A;
        FIN;
        IF STRING == '$' THEN
          X_GEHEIMINT=78;
          X_GEHEIM=78;
          PUT 'AFTER 20 MIN ACTIVATE ENDE' TO RTOS BY A;
        FIN;
        IF STRING == 'ß' THEN
          X_GEHEIMINT=0;
          X_GEHEIM=0;
        FIN;                                

        IF STRING == 'D' OR STRING == 'd' THEN
          PREVENT DISPLAY;
          CALL ANZ_AUS;
          AFTER 0.3 SEC RESUME;
          CALL DATPROT;
          CALL D_CLR;
          AFTER 1 SEC RESUME;
          CALL D_CLR;
          B_LOOP='0'B;
          X_R=3;
        FIN;    

        IF (X_R-48) > 0 AND (X_R-48) <= N_HZKR THEN
          X_GEHEIM=X_R-48;
        FIN;  
      FIN;

      X_RCAN=X_R;
      IF    TOFIXED(STRING) > 31 
         OR (Z_FERN > 0
             AND TOFIXED(STRING) > 1)  THEN
        X_RCAN=TOFIXED(STRING);
        B_LOOP='0'B;     /* <<< */
      FIN;  
      STRING=TOCHAR(0);  /* <<< */

      IF Z_TASTVERZ > ZF_TASTVERZ THEN
        X_F=0;
      ELSE
        IF X_R > 0 THEN
          IF X_F<2000 THEN  /* Auto-Repeat max. 1000 statt vorher 10 */
            IF X_F < 50 THEN
              X_F=X_F+1;
            ELSE
              X_F=X_F+10;
            FIN;
          FIN;
        FIN;
      FIN;                                                   

      IF Z_FERN>0 THEN
        
        IF Z_FERNGESENDET /= Z_FERN THEN
          IF N_BHKW > 0 THEN
            CALL SENDCANFIXED(1, ID_ZFERN1, 2, Z_FERN, 0, 0, 0, 180);
          FIN;
          IF N_BHKW > 1 THEN
            CALL SENDCANFIXED(1, ID_ZFERN2, 2, Z_FERN, 0, 0, 0, 180);
          FIN;
          IF N_BHKW > 2 THEN
            CALL SENDCANFIXED(1, ID_ZFERN3, 2, Z_FERN, 0, 0, 0, 180);
          FIN;

       !  CALL SENDCANFIXED(1, ID_ZFERN3, 2, Z_FERN, 0, 0, 0, 180);    /* UST <<< */

          Z_FERNGESENDET=Z_FERN;
        FIN;

        IF Z_FERNEND > 0 THEN
          Z_FERN=0;
          B_LOOP='0'B;   /* <<< */
        FIN;
        B_CANREADAKT='1'B;
      ELSE
        B_CANREADAKT='0'B;

        IF  Z_FERNGESENDET /= 0 THEN
          IF N_BHKW > 0 THEN
            CALL SENDCANFIXED(1, ID_ZFERN1, 2, 0, 0, 0, 0, 180);
          FIN;  
          IF N_BHKW > 1 THEN
            CALL SENDCANFIXED(1, ID_ZFERN2, 2, 0, 0, 0, 0, 180);
          FIN;  
          IF N_BHKW > 2 THEN
            CALL SENDCANFIXED(1, ID_ZFERN3, 2, 0, 0, 0, 0, 180);
          FIN;  

      !   CALL SENDCANFIXED(1, ID_ZFERN3, 2, Z_FERN, 0, 0, 0, 180);    /* UST <<< */

          Z_FERNGESENDET=0;
        FIN;
        
        
        Z_FERNEND=0;
      FIN;
    END;

  ELSE                                 /* nicht B_FERN */

    B_LOOP='1'B;
    WHILE B_LOOP REPEAT

      X_R=0;                                               
   !  AFTER ZF_TASTVERZ*0.001 SEC RESUME;
      AFTER 0.10 SEC RESUME;
      STAT=TASKST('JOYSTICK');
      IF STAT.BIT(1) THEN
        ACTIVATE JOYSTICK;
      FIN;

   !  IF X_F==1 THEN
   !    AFTER 0.1 SEC RESUME;
   !  FIN;

      IF TOFIXED(STRING) == 0  THEN X_R=0;                            FIN; /* MITTE*/
      IF TOFIXED(STRING) == 11 THEN X_R=1; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* OBEN */
      IF TOFIXED(STRING) == 10 THEN X_R=2; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* UNTEN*/
      IF TOFIXED(STRING) == 8  THEN X_R=3; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* LINKS*/
      IF TOFIXED(STRING) == 12 THEN X_R=4; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* RECH.*/
      IF TOFIXED(STRING) == 13 THEN X_R=5; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* ENTER*/
      IF TOFIXED(STRING) == 144 THEN X_R=144; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* Ausstieg Tastatureingabe */
      IF TOFIXED(STRING) == 145 THEN X_R=NR_BUTTON; Z_TASTVERZ=0; B_LOOP='0'B; FIN; /* Ausstieg Mausklick */
   !  IF TOFIXED(STRING) > 0  THEN 
   !    IF ALTSTRING==STRING THEN     /* selbe Taste nochmal? */
   !    ELSE
   !      Z_TASTVERZ=ZF_TASTVERZ+1;
   !    FIN;
   !    ALTSTRING=STRING;
   !  FIN;

   !  IF STRING == 'T' OR STRING == 't' THEN
   !    B_TASTATUR='1'B;
   !    X_R=0;
   !    B_LOOP='0'B;
   !  FIN;

      IF NOT B_LOOP AND NOT B_KEY THEN
        B_KEY='1'B;
    !   CALL LICHTAN;  
    !   AFTER 30 MIN ACTIVATE LICHTAUS;
      FIN;


      IF STRING == '?' THEN
        X_GEHEIM=226;
        X_GEHEIMINT=226;
        PUT 'AFTER 20 MIN ACTIVATE ENDE' TO RTOS BY A;
        IF Z_CIN30 > 1 THEN  B_LOOP='0'B;  FIN;
      FIN;
      IF STRING == '$' THEN
        X_GEHEIM=78;
        X_GEHEIMINT=78;
        PUT 'AFTER 20 MIN ACTIVATE ENDE' TO RTOS BY A;
        IF Z_CIN30 > 1 THEN  B_LOOP='0'B;  FIN;
      FIN;
      IF STRING == 'ß' THEN
        X_GEHEIMINT=0;
        X_GEHEIM=0;
        IF Z_CIN30 > 1 THEN  B_LOOP='0'B;  FIN;
   !    PUT 'ENDE 226' TO A1 BY A,SKIP;
      FIN;                                

      STRING=TOCHAR(0);  /* <<< */ 
      IF Z_TASTVERZ > ZF_TASTVERZ THEN
        X_F=0;
      ELSE
        IF X_R > 0 THEN
          IF X_F<2000 THEN  /* Auto-Repeat max. 1000 statt vorher 10 */
            IF X_F < 50 THEN
              X_F=X_F+1;
            ELSE
              X_F=X_F+10;
            FIN;
          FIN;
        FIN;
      FIN;                                                   


      X_RCAN=X_R;


      IF Z_FERN>0 THEN
        
        IF Z_FERNGESENDET /= Z_FERN THEN
          IF N_BHKW > 0 THEN
            CALL SENDCANFIXED(1, ID_ZFERN1, 2, Z_FERN, 0, 0, 0, 180);
          FIN;
          IF N_BHKW > 1 THEN
            CALL SENDCANFIXED(1, ID_ZFERN2, 2, Z_FERN, 0, 0, 0, 180);
          FIN;
          IF N_BHKW > 2 THEN
            CALL SENDCANFIXED(1, ID_ZFERN3, 2, Z_FERN, 0, 0, 0, 180);
          FIN;

    !     CALL SENDCANFIXED(1, ID_ZFERN3, 2, Z_FERN, 0, 0, 0, 180);   /* UST <<< */

          Z_FERNGESENDET=Z_FERN;
        FIN;
        
        IF Z_FERNEND > 0 THEN
          Z_FERN=0;
          B_LOOP='0'B;   /* <<< */
        FIN;
        B_CANREADAKT='1'B;
      ELSE
        B_CANREADAKT='0'B;

        IF  Z_FERNGESENDET /= 0 THEN
          IF N_BHKW > 0 THEN
            CALL SENDCANFIXED(1, ID_ZFERN1, 2, 0, 0, 0, 0, 180);
          FIN;  
          IF N_BHKW > 1 THEN
            CALL SENDCANFIXED(1, ID_ZFERN2, 2, 0, 0, 0, 0, 180);
          FIN;  
          IF N_BHKW > 2 THEN
            CALL SENDCANFIXED(1, ID_ZFERN3, 2, 0, 0, 0, 0, 180);
          FIN;  

    !     CALL SENDCANFIXED(1, ID_ZFERN3, 2, Z_FERN, 0, 0, 0, 180);   /* UST <<< */

          Z_FERNGESENDET=0;
        FIN;
        
        Z_FERNEND=0;
      FIN;

    END;

  FIN;

! IF Z_FERN > 6 AND Z_FERN < 10 THEN  /* Unterstation */
!   CALL SENDCANFIXED(1, ID_XGEHEIM3, 4, X_GEHEIM, X_ZUGANG, 0, 0, 20);
!   CALL SENDCANFIXED(1, ID_XR3, 2, X_RCAN, 0, 0, 0, 20);
! FIN;
! AFTER 30 MIN ACTIVATE LICHTAUS;
! CALL LICHTAN;
  IF X_R==5 THEN AFTER 0.5 SEC ACTIVATE RAMSCHREIB; FIN;

  IF B_ROTSP THEN
    X_ZUGANG=0;
  ELSE
    X_ZUGANG=1;
  FIN;
  IF X_GEHEIMINT==226 OR X_GEHEIMEXT==226 THEN
    X_GEHEIM=226;
    X_ZUGANG=5;
  ELSE
    IF X_GEHEIMINT==78 OR X_GEHEIMEXT==78 THEN
      X_GEHEIM=78;
      X_ZUGANG=1;
    ELSE
      IF X_GEHEIMINT==100 OR X_GEHEIMEXT==100 THEN
        X_GEHEIM=100;
      FIN;
    FIN;
  FIN;

END;


/*********************************************************************/
DIGOUT: PROC GLOBAL; /* Digitalausgabe                      */
  DCL F15  FIXED;
  /*-----------------------------------------------------------------*/
  /* Ausgabe digitalen Datenbus, Relaisplatinen                      */
  IF B_OUTENA THEN /* Nur wenn Ausgabe freigeschaltet                */
  
    DIGOUTS.BIT( 1)= BI_DAUS(1).BIT(16) AND BI_OFF(1).BIT(16) OR BI_ON(1).BIT(16);
    DIGOUTS.BIT( 2)= BI_DAUS(1).BIT(15) AND BI_OFF(1).BIT(15) OR BI_ON(1).BIT(15);
    DIGOUTS.BIT( 3)= BI_DAUS(1).BIT(14) AND BI_OFF(1).BIT(14) OR BI_ON(1).BIT(14);
    DIGOUTS.BIT( 4)= BI_DAUS(1).BIT(13) AND BI_OFF(1).BIT(13) OR BI_ON(1).BIT(13);
    DIGOUTS.BIT( 5)= BI_DAUS(1).BIT(12) AND BI_OFF(1).BIT(12) OR BI_ON(1).BIT(12);
    DIGOUTS.BIT( 6)= BI_DAUS(1).BIT(11) AND BI_OFF(1).BIT(11) OR BI_ON(1).BIT(11);
    DIGOUTS.BIT( 7)= BI_DAUS(1).BIT(10) AND BI_OFF(1).BIT(10) OR BI_ON(1).BIT(10);
    DIGOUTS.BIT( 8)= BI_DAUS(1).BIT( 9) AND BI_OFF(1).BIT( 9) OR BI_ON(1).BIT( 9);

    DIGOUTS.BIT( 9)= BI_DAUS(2).BIT(16) AND BI_OFF(2).BIT(16) OR BI_ON(2).BIT(16);
    DIGOUTS.BIT(10)= BI_DAUS(2).BIT(15) AND BI_OFF(2).BIT(15) OR BI_ON(2).BIT(15);
    DIGOUTS.BIT(11)= BI_DAUS(2).BIT(14) AND BI_OFF(2).BIT(14) OR BI_ON(2).BIT(14);
    DIGOUTS.BIT(12)= BI_DAUS(2).BIT(13) AND BI_OFF(2).BIT(13) OR BI_ON(2).BIT(13);
    DIGOUTS.BIT(13)= BI_DAUS(2).BIT(12) AND BI_OFF(2).BIT(12) OR BI_ON(2).BIT(12);
    DIGOUTS.BIT(14)= BI_DAUS(2).BIT(11) AND BI_OFF(2).BIT(11) OR BI_ON(2).BIT(11);
    DIGOUTS.BIT(15)= BI_DAUS(2).BIT(10) AND BI_OFF(2).BIT(10) OR BI_ON(2).BIT(10);
    DIGOUTS.BIT(16)= BI_DAUS(2).BIT( 9) AND BI_OFF(2).BIT( 9) OR BI_ON(2).BIT( 9);

    DIGOUTS.BIT(17)= BI_DAUS(3).BIT(16) AND BI_OFF(3).BIT(16) OR BI_ON(3).BIT(16);
    DIGOUTS.BIT(18)= BI_DAUS(3).BIT(15) AND BI_OFF(3).BIT(15) OR BI_ON(3).BIT(15);
    DIGOUTS.BIT(19)= BI_DAUS(3).BIT(14) AND BI_OFF(3).BIT(14) OR BI_ON(3).BIT(14);
    DIGOUTS.BIT(20)= BI_DAUS(3).BIT(13) AND BI_OFF(3).BIT(13) OR BI_ON(3).BIT(13);
    DIGOUTS.BIT(21)= BI_DAUS(3).BIT(12) AND BI_OFF(3).BIT(12) OR BI_ON(3).BIT(12);
    DIGOUTS.BIT(22)= BI_DAUS(3).BIT(11) AND BI_OFF(3).BIT(11) OR BI_ON(3).BIT(11);
    DIGOUTS.BIT(23)= BI_DAUS(3).BIT(10) AND BI_OFF(3).BIT(10) OR BI_ON(3).BIT(10);
    DIGOUTS.BIT(24)= BI_DAUS(3).BIT( 9) AND BI_OFF(3).BIT( 9) OR BI_ON(3).BIT( 9);

    DIGOUTS.BIT(25)= BI_DAUS(4).BIT(16) AND BI_OFF(4).BIT(16) OR BI_ON(4).BIT(16);
    DIGOUTS.BIT(26)= BI_DAUS(4).BIT(15) AND BI_OFF(4).BIT(15) OR BI_ON(4).BIT(15);
    DIGOUTS.BIT(27)= BI_DAUS(4).BIT(14) AND BI_OFF(4).BIT(14) OR BI_ON(4).BIT(14);
    DIGOUTS.BIT(28)= BI_DAUS(4).BIT(13) AND BI_OFF(4).BIT(13) OR BI_ON(4).BIT(13);
    DIGOUTS.BIT(29)= BI_DAUS(4).BIT(12) AND BI_OFF(4).BIT(12) OR BI_ON(4).BIT(12);
    DIGOUTS.BIT(30)= BI_DAUS(4).BIT(11) AND BI_OFF(4).BIT(11) OR BI_ON(4).BIT(11);
    DIGOUTS.BIT(31)= BI_DAUS(4).BIT(10) AND BI_OFF(4).BIT(10) OR BI_ON(4).BIT(10);
    DIGOUTS.BIT(32)= BI_DAUS(4).BIT( 9) AND BI_OFF(4).BIT( 9) OR BI_ON(4).BIT( 9);

    FOR I TO N_RELPLT REPEAT
      B_DO((I-1)*8+1)=BI_DAUS(I).BIT(16) AND BI_OFF(I).BIT(16) OR BI_ON(I).BIT(16);
      B_DO((I-1)*8+2)=BI_DAUS(I).BIT(15) AND BI_OFF(I).BIT(15) OR BI_ON(I).BIT(15);
      B_DO((I-1)*8+3)=BI_DAUS(I).BIT(14) AND BI_OFF(I).BIT(14) OR BI_ON(I).BIT(14);
      B_DO((I-1)*8+4)=BI_DAUS(I).BIT(13) AND BI_OFF(I).BIT(13) OR BI_ON(I).BIT(13);
      B_DO((I-1)*8+5)=BI_DAUS(I).BIT(12) AND BI_OFF(I).BIT(12) OR BI_ON(I).BIT(12);
      B_DO((I-1)*8+6)=BI_DAUS(I).BIT(11) AND BI_OFF(I).BIT(11) OR BI_ON(I).BIT(11);
      B_DO((I-1)*8+7)=BI_DAUS(I).BIT(10) AND BI_OFF(I).BIT(10) OR BI_ON(I).BIT(10);
      B_DO((I-1)*8+8)=BI_DAUS(I).BIT( 9) AND BI_OFF(I).BIT( 9) OR BI_ON(I).BIT( 9);
    END;

    F15=N_RELPLT*8;
    FOR I TO F15 REPEAT
      IF B_DO(I) /= B_DOMERK(I) THEN  
        B_DONEU(I)='1'B;  
      FIN;
      B_DOMERK(I)=B_DO(I);
    END;

  ELSE

    DIGOUTS='00000000000000000000000000000000'B1;

  FIN;

END;


AOUT:PROC GLOBAL;
  DCL PWM FIXED;
  DCL F15 FIXED;
  DCL PROMAX FLOAT;
  DCL PROMIN FLOAT;
  DCL FL1    FLOAT;
  DCL DAOUT dac_type ;

  FOR I TO N_ANALOG REPEAT
    IF Z_AAUTO(I)==2 THEN
      X_AAUS(I)=X_AHAND(I);
    FIN;

    IF X_AAUS(I)>100.0 THEN
      X_AAUS(I)=100.0;
    FIN;
    IF X_AAUS(I)>X_AAUSMAX(I) THEN
      X_AAUS(I)=X_AAUSMAX(I);
    FIN;
    IF X_AAUS(I)<0.0 THEN
      X_AAUS(I)=0.0;
    FIN;

    /* Analogausgaenge fuer Phasenanschnittsteuerungen ohne Rueckkopplung */
    /* werden hier alle 20s fuer 2s auf 100% gefahren                     */
  ! IF Z_LZ REM 20(31) < 2(31) THEN
  !   IF    AP_TYP(I)==3 OR AP_TYP(I)==4 OR AP_TYP(I)==5
  !      OR AP_TYP(I)==6 OR AP_TYP(I)==9 THEN
  !     FL1=100.0;
  !   ELSE
  !     FL1=X_AAUS(I);
  !   FIN;
  ! ELSE
  !   FL1=X_AAUS(I);
  ! FIN;
    FL1=X_AAUS(I);

    PROMIN=AP_ULOW(I)/0.1;
    PROMAX=AP_UHIGH(I)/0.1;

    PWM=ROUND((((PROMAX-PROMIN)*0.01*FL1+PROMIN)/100.0)*4095.0);
!   512=       ( 100  -   0  )*0.01*50 +   0  )/100.0)*1024)
!   102=       (  90  -  10  )*0.01* 0 +  10  )/100.0)*1024)
!   266=       (  90  -  10  )*0.01*20 +  10  )/100.0)*1024)
!   922=       (  90  -  10  )*0.01*100+  10  )/100.0)*1024)
 
    IF PWM > 4095 THEN  PWM=4095;  FIN;
    IF PWM <    0 THEN  PWM=   0;  FIN;

    DAOUT.c(I)= TOBIT(PWM);

  END;
  SPI_WRITE_DAC( DAOUT );

  /* FREQUENZVENTIL REGELUNG BEZOGEN AUF 100Hz Grundtakt */
! IF FL_PWMPRO(13) > 1.0 THEN
!   /* umrechnen 0-100% = 0-10 ms von 10ms; 0-10ms Einzeit = 0-6250 Takte*/
!   /* 1ms = 625 Takte 1% = 62.5 Takte */
!   PWM=ROUND(FL_PWMPRO(13)*62.5);
! ELSE
!   PWM=0;
! FIN;
! SEND PWM TO PWM8;    /* an TPU A CH 7 senden */

END;


/*********************************************************************/
WATCHDOG: TASK PRIO 3;
  DCL p_watch REF BIT(16);


  Z_WATCHDOG=Z_WATCHDOG+1(31);
  /* Wenn alles OK ist, darf der Watchdog beruhigt werden:           */
  IF    B_WATCHDOG AND B_BENUTZER
        AND Z_DIN>20                  /*   */
    !   AND Z_BHKWSEND>0              /*   */
        AND Z_TASKCONTR>0             /*   */
    !   AND Z_CANIO>0                 /*   */
    /*  AND Z_BHKWGET>0               /*   */     
     OR B_WDINIT AND Z_WATCHDOG < 1500(31) THEN
    Z_WATCH=0;     /* alles OK, der Zaehler kann zurueckgesetzt werden */
    B_WATCHDOG='1'B;
  ELSE
    Z_WATCH=Z_WATCH+1; /* Fehler, den Zaehler erhoehen                 */
    IF Z_WATCH>30 THEN
      PUT 'TERMINATE Watch -- PREVENT WATCHDOG' TO RTOS BY A;
    FIN;
    IF Z_WATCH>4 THEN
      CALL D_CS(1,15);
      IF Z_DIN<21 THEN                                  /*  */
        PUT 'Fehler DIN' TO LCD BY A,SKIP;              /*  */
        PUT 'Fehler DIN' TO A1  BY A,SKIP;              /*  */
        PUT 'Fehler DIN',Z_WATCH TO FEHL2  BY A,F(2),SKIP;              /*  */
      FIN;                                              /*  */
   !  IF Z_BHKWSEND<1 THEN                              /*  */
   !    PUT 'Fehler BHKWSEND' TO LCD BY A,SKIP;         /*  */
   !    PUT 'Fehler BHKWSEND' TO A1  BY A,SKIP;         /*  */
   !    PUT 'Fehler BHKWSEND',Z_WATCH TO FEHL2  BY A,F(2),SKIP;              /*  */
   !  FIN;                                              /*  */
      IF Z_TASKCONTR<1 THEN                             /*  */
        PUT 'Fehler TASKCONTR' TO LCD BY A,SKIP;         /*  */
        PUT 'Fehler TASKCONTR' TO A1  BY A,SKIP;         /*  */
        PUT 'Fehler TASKCONTR',Z_WATCH TO FEHL2  BY A,F(2),SKIP;              /*  */
      FIN;                                              /*  */
   !  IF Z_CANIO<1 THEN                                 /*  */
   !    PUT 'Fehler CANIOPLAT' TO LCD BY A,SKIP;        /*  */
   !    PUT 'Fehler CANIOPLAT' TO A1  BY A,SKIP;         /*  */
   !    PUT 'Fehler CANIOPLAT',Z_WATCH TO FEHL2  BY A,F(2),SKIP;              /*  */
   !  FIN;                                              /*  */
/*    IF Z_BHKWGET<1 THEN                               /*  */
/*      PUT 'Fehler BHKWGET' TO LCD BY A,SKIP;          /*  */
/*    FIN;                                              /*  */
      IF NOT B_WATCHDOG THEN                            /*  */
        PUT 'Fehler SYSTAKT' TO LCD BY A,SKIP;          /*  */
        PUT 'Fehler SYSTAKT' TO A1  BY A,SKIP;          /*  */
        PUT 'Fehler SYSTAKT',Z_WATCH TO FEHL2  BY A,F(2),SKIP;              /*  */
      FIN;                                              /*  */
      IF B_WDINIT THEN                                  /*  */
        PUT 'Fehler Initialisierung' TO LCD BY A,SKIP;  /*  */
        PUT 'Fehler Initialisierung' TO A1  BY A,SKIP;  /*  */
        PUT 'Fehler Initialisierung',Z_WATCH TO FEHL2  BY A,F(2),SKIP;              /*  */
      FIN;                                              /*  */
      PUT 'SYNC H0.' TO RTOS;
    FIN; 
    B_WATCHDOG='1'B;                            
  FIN;

  IF B_WATCHDOG AND Z_WATCH<7 THEN
    p_watch = NIL; CALL REFADD(p_watch, TOFIXED('F000090E'B4) // 2);
    CONT p_watch = '556C'B4;
    CONT p_watch = 'AA39'B4;
    /* Jetzt sind es wieder 1,024 Sec bis zum naechsten Reset         */
    IF Z_WATCHEXT < 4 THEN
      Z_WATCHEXT=4;
    FIN;
  FIN;

  B_WATCHDOG='0'B;
  Z_BHKWSEND=Z_BHKWSEND-1;
  IF Z_BHKWSEND>80 THEN Z_BHKWSEND=80; FIN;
  Z_CANIO=Z_CANIO-1;
  IF Z_CANIO>40 THEN Z_CANIO=40; FIN;
  Z_BHKWGET=Z_BHKWGET-1;
  IF Z_BHKWGET >10 THEN Z_BHKWGET =10; FIN;
  Z_TASKCONTR=Z_TASKCONTR-1;
  IF Z_TASKCONTR >150 THEN Z_TASKCONTR =150; FIN;
  Z_DIN=0; 
  IF Z_WATCH > 5 OR Z_LZ REM 60(31) == 1(31) THEN
    IF Z_SYSOUT==3 OR Z_SYSOUT==2 THEN
      CALL SYNC(FEHL2);
    FIN;
  FIN;

END; /* of TASK WATCHDOG */



AIN: PROC (NR FIXED) GLOBAL;
/*********************************************************************/
/* A/D-Wandlung fÅr alle (wenn 0 Åbergeben wird) oder fÅr einen      */
/* Kanal (wenn eine Zahl>0 Åbergeben wird)                           */
/*********************************************************************/

  DCL X_A  FLOAT;   /* !!! */
  DCL FL1  FLOAT;   /* !!! */
  DCL K    FIXED;   /* !!! */

  DCL AIIN1 adc_type ;
  DCL AIIN2 adc_type ;


  SPI_READ_ADC1( AIIN1 ) ;
  SPI_READ_ADC2( AIIN2 ) ;

  FOR I TO 16 REPEAT
    FELD(I)=(TOFIXED(AIIN1.c(I)))/4.0;
  END;
  FOR I TO 16 REPEAT
    FELD(I+16)=(TOFIXED(AIIN2.c(I)))/4.0;
  END;

  
  IF NR==0 THEN /* alle initialisierten KanÑle auslesen              */
    K=1;
    WHILE K <= N_FUEHLER REPEAT

      FL1 = 4.88759*FELD(K);

      IF FP_TYP(K)==3 THEN   /* Gleichung fuer PT 1000 NEU Fuehler:    */
        /* Kennlinie:  T=(U(mV)-1200)/(28,1176-0,000638333*U(mV))   */
        X_A = (FL1-FP_ULOW(FP_HARD(K)))/(28.1176-0.000638333*FL1);
      ELSE
        IF FP_TYP(K)==12 THEN   /* Gleichung fuer PT 500 NEU Fuehler:*/
          /* Kennlinie:  T=2*(U(mV)-1136)/(32,7219-0,000638333*U(mV)) */
          X_A = 2.0*(FL1-FP_ULOW(FP_HARD(K)))/(32.7219-0.000638333*FL1);
        ELSE
          IF FP_TYP(K)==15 THEN   /* Gleichung fuer PT 1000 ALT Fuehler:*/
            /* Kennlinie:  T=(U(mV)-1136)/(32,7219-0,000638333*U(mV))   */
            X_A = (FL1-FP_ULOW(FP_HARD(K)))/(32.7219-0.000638333*FL1);
           ELSE    /* Bei anderen Fuehlertypen sind bisher nur Steigung*/
             IF FP_TYP(K)==17 THEN   /* Gleichung fuer PT 1000 auf IF555-5 Fuehler:*/
              /* Kennlinie:  T=(U(mV)-1280)/(27,05-0,00065*U(mV))   */
              X_A = (FL1-FP_ULOW(FP_HARD(K)))/(27.05-0.00065*FL1);
             ELSE    /* Bei anderen Fuehlertypen sind bisher nur Steigung*/
                     /* und Nullpunkt zur Umrechnung noetig:             */
              X_A = (FELD(K)-FP_NULL(FP_HARD(K)))*FP_STEIG(FP_HARD(K));
            FIN;
          FIN;
        FIN;
      FIN;

      /* wenn Steuerung schon laenger als 200 sec in Betrieb und  */
      /* nicht gerade die Analogeingaenge abgeglichen werden      */
      IF Z_LZ>200(31) AND NOT B_FUEHL THEN
        /* gleitende Mittelwertbildung mit Tau=FP_MIT(K)sec      */
        X_AEIN(FP_HARD(K))=(X_AEIN(FP_HARD(K))*FP_MIT(FP_HARD(K))+X_A)/(FP_MIT(FP_HARD(K))+1);
      ELSE
        /* sonst direkt Åbernehmen                               */
        X_AEIN(FP_HARD(K))=X_A;
      FIN;
      K=K+1;

    END;
  ELSE  /* nur einen bestimmten Hardwarekanal auslesen */

  FIN;

END;

/* Task zur Restkapazitaetsmessung */
IT_LOOP: TASK PRIO 255 RESIDENT;
  DCL ZP3 CLOCK;
  DCL ZP4 CLOCK;
  DCL F31 FIXED(31);
  DCL FL  FLOAT;
  DCL BLOOP BIT(1);

  REPEAT
    IF IT_COUNT1==1(31) THEN
      IT_COUNT1=0(31);
      IT_COUNT2=0(31);
    FIN;
    IT_COUNT2=IT_COUNT2+1(31);

  END;

END;

REST2: TASK PRIO 1;

  IT_COUNT3=100(31);

END;



/*********************************************************************/
/*  Digitaleingaenge auslesen und evtl PWM-Ausgaenge bedienen        */
/*********************************************************************/
DIN: TASK PRIO 1;    

  DCL DI BIT(32);
  DCL ZD_IMP  DURATION;
  DCL Z_PWMGR FIXED;
  DCL ZAUSZ   FIXED;
  DCL INDEX   FIXED;
  
 REPEAT

  Z_DIN=Z_DIN+1;
  
  DI = SPI_RW_DIO( DIGOUTS ) ;
  FOR I TO 32 REPEAT
    BI_DEIN( I)=DI.BIT(I);
    IF BI_DEIN(I) /= BI_DEINMERK(I) THEN
      Z_ZAEHL(I)=Z_ZAEHL(I)+1(31);  /* Eingangsimpulse zÑhlen */
      BI_DEINMERK(I)=BI_DEIN(I);
      IF Z_ZAEHL(I) REM 2(31) == 0(31) THEN
        ZD_IMP=NOW-ZP_IMPALT(I);
        ZP_IMPALT(I)=NOW;
        FL_IMPDAU(I)=ZD_IMP / 1.0 SEC;
        IF FL_IMPDAU(I) < 0.000 THEN
          FL_IMPDAU(I)=FL_IMPDAU(I)+86400.0;
        FIN;
        B_IMPNEU(I)='1'B;
      FIN;           
    FIN;
  END;

  /* Laufzeit Stokerschnecke Holzk1 */
  IF BI_DEIN( 2) OR Z_DIBEWERT(2) == 3 THEN
    Z_STOKMS( 8)=Z_STOKMS( 8)+20;
  FIN;
  /* Laufzeit Stokerschnecke Holzk2 */
  IF BI_DEIN( 4) OR Z_DIBEWERT(4) == 3 THEN
    Z_STOKMS( 9)=Z_STOKMS( 9)+20;
  FIN;


! INDEX=1;
! IF FL_PWMPRO(INDEX) > 0.5 THEN /* TAKT-PWM WW-ZIRK      */
!   Z_PWM(INDEX)=Z_PWM(INDEX)+4;
!   IF Z_PWM(INDEX) > 19990 THEN  Z_PWM(INDEX)=0;  FIN;
!   Z_PWMGR=ROUND(200.0*FL_PWMPRO(INDEX));
!   IF Z_PWM(INDEX) < Z_PWMGR THEN
!     BI_DAUS(2).BIT(11)='1'B;
!   ELSE
!     BI_DAUS(2).BIT(11)='0'B;
!   FIN;  
! ELSE
!   BI_DAUS(2).BIT(11)='0'B;
! FIN;


! INDEX=2;
! IF XA_WWLADP(1) > 1.0 OR Z_AAUTO(INDEX)==2 THEN /* TAKT-ANALOGAUSGANG WW1 LADEP     */
!   IF Z_AAUTO(INDEX) < 2 THEN  
!     Z_PWM(INDEX)=Z_PWM(INDEX)+2;
!     IF Z_PWM(INDEX) > ZF_WWMI(10)*100 THEN  Z_PWM(INDEX)=0;  FIN;
!     Z_PWMGR=ROUND(ZF_WWMI(10)*XA_WWLADP(1)*2.5);  /* 0-40% TAKTEN */
!     IF Z_PWMGR < 100 THEN  Z_PWMGR=100;  FIN;
!     ZAUSZ=ZF_WWMI(10)*100-Z_PWMGR;
!     IF Z_PWM(INDEX) < Z_PWMGR THEN
!       IF XA_WWLADP(1) > 40.0 THEN
!   !     X_AAUS(INDEX)=20.0+(XA_WWLADP(1)-40.0)*1.6666;
!         X_AAUS(INDEX)=X_AAUSMIN(INDEX)+(X_AAUSMAX(INDEX)-X_AAUSMIN(INDEX))*0.01*(XA_WWLADP(1)-40.0)*1.6666;
!       ELSE
!         X_AAUS(INDEX)=X_AAUSMIN(INDEX);
!       FIN;
!     ELSE
!       IF ZAUSZ > 18 THEN
!         X_AAUS(INDEX)=0.0;
!       FIN;
!     FIN;  
!   ELSE
!     X_AAUS(INDEX)=X_AHAND(INDEX);
!   FIN;
! ELSE
!   X_AAUS(INDEX)=0.0;
!   Z_PWM(INDEX)=0;                                   
! FIN;


! INDEX=1;
! IF FL_PWMPRO(INDEX) > 0.5 THEN /* PWM HEIZPATRONE        */
!   Z_PWM(INDEX)=Z_PWM(INDEX)+100;
!   Z_PWMGR=ROUND(10000.0/FL_PWMPRO(INDEX));
!   IF Z_PWM(INDEX) > Z_PWMGR THEN
!     BI_DAUS(2).BIT(10)='1'B;
!     Z_PWM(INDEX)=Z_PWM(INDEX)-Z_PWMGR;
!   ELSE
!     BI_DAUS(2).BIT(10)='0'B;
!   FIN;  
! ELSE
!   BI_DAUS(2).BIT(10)='0'B;
! FIN;
 
! INDEX=2;
! IF FL_PWMPRO(INDEX) > 0.5 THEN /* PWM HEIZPATRONE2        */
!   Z_PWM(INDEX)=Z_PWM(INDEX)+100;
!   Z_PWMGR=ROUND(10000.0/FL_PWMPRO(INDEX));
!   IF Z_PWM(INDEX) > Z_PWMGR THEN
!     BI_DAUS(3).BIT(14)='1'B;
!     Z_PWM(INDEX)=Z_PWM(INDEX)-Z_PWMGR;
!   ELSE
!     BI_DAUS(3).BIT(14)='0'B;
!   FIN;  
! ELSE
!   BI_DAUS(3).BIT(14)='0'B;
! FIN;
 


  CALL DIGOUT;
  CALL AOUT;     /* <<<  */

  
  AFTER 0.019 SEC RESUME;

 END;
 
END; 



  
/***********************************************************************/
/* Update einer Unterstation ueber CAN-Bus (langsam waehrend Betrieb)  */
/***********************************************************************/
SCHLEICHUPDATE: TASK PRIO 50;
  DCL CHAR1      CHAR(1);
  DCL CH1        CHAR(1);
  DCL CANSEN(8)  CHAR(1);
  DCL Z1         FIXED;
  DCL Z2         FIXED;
  DCL Z31        FIXED(31);
  DCL F31        FIXED(31);
  DCL BLOOP      BIT(1);
  DCL B1         BIT(1);


! ANZ_SLAVE=1; /* Anzahl Slaves */

  CALL STOERMELD(80,'Sl-UPD Start');

  CALL APPEND(SLAVE);
  CALL SAVEP(SLAVE,F31);
  IF F31 > 3500000(31) OR F31 < 500000(31) THEN
    CALL STOERMELD(80,'Sl-UPD Datei-ERR');
    TERMINATE;
  FIN;


  Z1=0;
  Z2=0;
  WHILE Z1 < 200 AND Z2 < ANZ_SLAVE REPEAT
    CH1=TOCHAR(VERZ_SLAVE);
    CALL SENDCANCHAR(1, 72, 2, 'A', CH1, ' ', ' ', ' ', ' ', ' ', ' ', 20); /* Aufforderung zum Empfang */
    Z1=Z1+1;
    Z2=0;
    FOR I TO 10 REPEAT
      IF SCHL_STA(I)=='F' THEN
        Z2=Z2+1;
      FIN;
      SCHL_STA(I)='x';
    END;
    AFTER 2 SEC RESUME;
  END;

  IF Z1 > 199 THEN
    CALL STOERMELD(80,'Sl-UPD AnzSL<');
    TERMINATE;
  FIN;
  
  CALL SENDCANCHAR(1, 72, 2, 'B', CH1, ' ', ' ', ' ', ' ', ' ', ' ', 20); /* ‹BERTRAGUNG LƒUFT */
  AFTER 0.1 SEC RESUME;
  CALL SENDCANCHAR(1, 72, 2, 'B', CH1, ' ', ' ', ' ', ' ', ' ', ' ', 20); /* ‹BERTRAGUNG LƒUFT */
  AFTER 0.1 SEC RESUME;
  CALL SENDCANCHAR(1, 72, 2, 'B', CH1, ' ', ' ', ' ', ' ', ' ', ' ', 20); /* ‹BERTRAGUNG LƒUFT */
  AFTER 0.1 SEC RESUME;
  CALL SENDCANCHAR(1, 72, 2, 'B', CH1, ' ', ' ', ' ', ' ', ' ', ' ', 20); /* ‹BERTRAGUNG LƒUFT */
  AFTER 0.1 SEC RESUME;
  CALL SENDCANCHAR(1, 72, 2, 'B', CH1, ' ', ' ', ' ', ' ', ' ', ' ', 20); /* ‹BERTRAGUNG LƒUFT */

  PUT TO SLAVE BY LIST;
  SCHL_DOPPM=0(31);
  SCHL_CRCM=0(31);
  SCHL_BYTEM=0(31);
  OPEN SLAVE BY IDF('slave'),ANY;
! OPEN SLAVE BY IDF('test'),ANY;
  CALL REWIND(SLAVE);

  B1='1'B;
  WHILE B1 REPEAT
    FOR I TO 8 REPEAT
      CANSEN(I)=TOCHAR(0);
    END;
    FOR I TO 8 REPEAT
      IF B1 THEN
        GET CHAR1 FROM SLAVE BY A(1);
        IF ST(SLAVE) > 0 THEN  /* vermutlich Dateiende */
          B1='0'B;
        ELSE
          SCHL_BYTEM=SCHL_BYTEM+1(31);
          SCHL_CRCM =SCHL_CRCM +1(31)*TOFIXED(CHAR1);
          CANSEN(I)=CHAR1;
        FIN;
        CHAR1=TOCHAR(0);
      FIN; 
    END; 

!   VERZ_SLAVE=2;  /* Verzˆg 20ms */

    CH1=TOCHAR(VERZ_SLAVE);
    CALL SENDCANCHAR(1, 72, 2, 'B', CH1, ' ', ' ', ' ', ' ', ' ', ' ', 20); /* ‹BERTRAGUNG LƒUFT */
    BLOOP='1'B;
    SCHL_DOPPM=SCHL_DOPPM-1(31);
    WHILE BLOOP REPEAT
      SCHL_DOPPM=SCHL_DOPPM+1(31);
      SCHL_ANZEMPF=0;
      FOR I TO 10 REPEAT
        SCHL_STA (I)='x';
      END;
      CALL SENDCANLONG(1, 71, 8, SCHL_BYTEM, SCHL_CRCM, 20);   /* ANZ ZEI + CHKSUM   */
      CALL SENDCANCHAR(1, 70, 8, CANSEN(1), CANSEN(2), CANSEN(3), CANSEN(4), CANSEN(5), CANSEN(6), CANSEN(7), CANSEN(8), 20);
      AFTER VERZ_SLAVE*0.001 SEC RESUME;

      Z2=0;
      WHILE SCHL_ANZEMPF < ANZ_SLAVE AND Z2 < 90 REPEAT
        AFTER VERZ_SLAVE*0.001 SEC RESUME;
        Z2=Z2+VERZ_SLAVE;
      END;

      IF SCHL_ANZEMPF >= ANZ_SLAVE THEN
        Z1=0;
        FOR I TO 10 REPEAT
          IF SCHL_STA(I)=='0' OR SCHL_STA(I)=='D' THEN
            IF SCHL_BYTEM==SCHL_BYTE(I) AND SCHL_CRCM==SCHL_CRC(I) THEN
              Z1=Z1+1;
            FIN;
          FIN;
          IF SCHL_STA(I)=='D' THEN
            SCHL_DOPP(I)=SCHL_DOPP(I)+1(31);
          FIN;
          IF SCHL_STA(I)=='E' THEN
            SCHL_ERR(I)=SCHL_ERR(I)+1(31);
          FIN;
        END;
        IF Z1 >= ANZ_SLAVE THEN
          BLOOP='0'B;
        FIN;
      ELSE
      FIN;
    END;
  END;

  Z1=0;
  WHILE Z1 < 600 REPEAT
    CH1=TOCHAR(VERZ_SLAVE);
    CALL SENDCANCHAR(1, 72, 2, 'C', CH1, ' ', ' ', ' ', ' ', ' ', ' ', 20); /* Aufforderung zum BRENNEN */
    Z1=Z1+1;
    AFTER 0.2 SEC RESUME;
  END;
  CALL STOERMELD(80,'Sl-UPD Ende ');

  
END;


SAVEPRG: TASK PRIO 150;
  DCL CHAR1     CHAR(1);
  DCL ASC(1000) FIXED;
  DCL DATNAM    CHAR(25);
  DCL TEXT      CHAR(80);
  DCL B1        BIT(1);
  DCL Z         FIXED;
  DCL N         FIXED;
  DCL ZPUNKT    FIXED;
  DCL ZLAENG    FIXED;
  DCL ZDAT      FIXED;
  DCL ZRETURN   FIXED;
  DCL BLOOP     BIT(1);
  DCL BLOOPDAT  BIT(1);

  PUT 'ER NIL.; mkdir /h0/PRGALT' TO RTOS;
  PUT 'ER NIL.; rm ed.TEST' TO RTOS;
  AFTER 0.2 SEC RESUME;

  PUT 'o ed.TEST; dir /fd/PRG' TO RTOS BY A;
  AFTER 0.2 SEC RESUME;
  
  FOR I TO 1000 REPEAT
    ASC(I)=0; 
  END;

  OPEN TEST;
  CALL REWIND(TEST);

  Z=0;
  WHILE ST(TEST)==0 AND Z < 999 REPEAT
    GET CHAR1 FROM TEST BY A(1);
    Z=Z+1;
    IF ST(MIST)==0 THEN
      ASC(Z)=TOFIXED(CHAR1);
    FIN;
  END;

  BLOOP='1'B;
  Z=1;
  ZRETURN=0;
  WHILE Z < 999 AND ZRETURN < 2 REPEAT
    IF ASC(Z) == 13 THEN
      ZRETURN=ZRETURN+1;
    FIN;
    Z=Z+1;
  END;
  /* jetzt steht in Z die Anfangsposition des ersten Dateinamens (nach 2*Return) */

  BLOOP='1'B;
  WHILE BLOOP REPEAT
    Z=Z+1;
    IF ASC(Z) == 46 THEN                      /* .  (z.B.: der Punkt in BEDIEN.psr */
      ZPUNKT=Z;
      BLOOPDAT='1'B;
      WHILE BLOOPDAT REPEAT
        Z=Z-1;                                /* jetzt rueckwaerts nach Dateinamensanfang suchen */
        IF ASC(Z) == 32 OR ASC(Z) == 13 THEN  /* " " ODER RETURN */
          BLOOPDAT='0'B;
        FIN;
      END;
      BLOOPDAT='1'B;
      N=1;
      DATNAM='                        ';
      WHILE BLOOPDAT REPEAT
        Z=Z+1;                                /* jetzt vorwaerts bis .+3Zeichen (Endung) */ 
        DATNAM.CHAR(N)=TOCHAR(ASC(Z));
        N=N+1;
        IF Z > ZPUNKT + 3 THEN
          BLOOPDAT='0'B;
        FIN;
      END;
      TEXT='copy prio 150 /fd/PRG/' CAT DATNAM CAT ' > /h0/PRGALT/' CAT DATNAM;
      PUT TEXT TO A1 BY A,SKIP;
      B1=CMD_EXW(TEXT);
    FIN;
    IF Z > 980 THEN
      BLOOP='0'B;
    FIN;
  END;
  PUT 'FERTIG!' TO A1 BY A,SKIP;

END;


RESTOREPRG: TASK PRIO 150;
  DCL CHAR1     CHAR(1);
  DCL ASC(1000) FIXED;
  DCL DATNAM    CHAR(25);
  DCL TEXT      CHAR(80);
  DCL B1        BIT(1);
  DCL Z         FIXED;
  DCL N         FIXED;
  DCL ZPUNKT    FIXED;
  DCL ZLAENG    FIXED;
  DCL ZDAT      FIXED;
  DCL ZRETURN   FIXED;
  DCL BLOOP     BIT(1);
  DCL BLOOPDAT  BIT(1);

  PUT 'ER NIL.; mkdir /fd/PRG' TO RTOS;
  PUT 'ER NIL.; rm ed.TEST' TO RTOS;
  AFTER 0.2 SEC RESUME;

  PUT 'o ed.TEST; dir /h0/PRGALT' TO RTOS BY A;
  AFTER 0.2 SEC RESUME;
  
  FOR I TO 1000 REPEAT
    ASC(I)=0; 
  END;

  OPEN TEST;
  CALL REWIND(TEST);

  Z=0;
  WHILE ST(TEST)==0 AND Z < 999 REPEAT
    GET CHAR1 FROM TEST BY A(1);
    Z=Z+1;
    IF ST(MIST)==0 THEN
      ASC(Z)=TOFIXED(CHAR1);
    FIN;
  END;

  BLOOP='1'B;
  Z=1;
  ZRETURN=0;
  WHILE Z < 999 AND ZRETURN < 2 REPEAT
    IF ASC(Z) == 13 THEN
      ZRETURN=ZRETURN+1;
    FIN;
    Z=Z+1;
  END;
  /* jetzt steht in Z die Anfangsposition des ersten Dateinamens (nach 2*Return) */

  BLOOP='1'B;
  WHILE BLOOP REPEAT
    Z=Z+1;
    IF ASC(Z) == 46 THEN                      /* .  (z.B.: der Punkt in BEDIEN.psr */
      ZPUNKT=Z;
      BLOOPDAT='1'B;
      WHILE BLOOPDAT REPEAT
        Z=Z-1;                                /* jetzt rueckwaerts nach Dateinamensanfang suchen */
        IF ASC(Z) == 32 OR ASC(Z) == 13 THEN  /* " " ODER RETURN */
          BLOOPDAT='0'B;
        FIN;
      END;
      BLOOPDAT='1'B;
      N=1;
      DATNAM='                        ';
      WHILE BLOOPDAT REPEAT
        Z=Z+1;                                /* jetzt vorwaerts bis .+3Zeichen (Endung) */ 
        DATNAM.CHAR(N)=TOCHAR(ASC(Z));
        N=N+1;
        IF Z > ZPUNKT + 3 THEN
          BLOOPDAT='0'B;
        FIN;
      END;
      TEXT='copy prio 150 /h0/PRGALT/' CAT DATNAM CAT ' > /fd/PRG/' CAT DATNAM;
      PUT TEXT TO A1 BY A,SKIP;
      B1=CMD_EXW(TEXT);
    FIN;
    IF Z > 980 THEN
      BLOOP='0'B;
    FIN;
  END;
  PUT 'FERTIG!' TO A1 BY A,SKIP;

END;

/*+L*/

MODEND;
