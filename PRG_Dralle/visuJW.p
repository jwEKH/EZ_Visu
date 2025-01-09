/****************************************************************************/
/* Programm-Modul fuer Visualisierung, Zaehlerdaten, Stoerungen             */
/*                                                                          */
/* Stand: 13.07.22          BIOGASANLAGE DRALLE  HOHNE                      */
/*                                                                          */
/*                                                                          */
/*                                                                          */
/****************************************************************************/

P=MPC604+FPU(4);

/* SC=30000 ,CODE=0 ,VAR=0;  /*  */
   SC=30000;                 /*  */ 

MODULE MODBUS;

/*+M*/
/*+T*/
/*-L*/

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

/* Tasks      */
  SPC I_DISP     TASK GLOBAL; /* Umschalten von Fern- auf Nahbed.    */
  SPC DISPLAY    TASK GLOBAL; /* Umschalten von Fern- auf Nahbed.    */
  SPC MENU       TASK GLOBAL; /* Umschalten von Fern- auf Nahbed.    */

/* Prozeduren */
  SPC ANZ_AUS   ENTRY GLOBAL;
  SPC SETPRI    ENTRY(FIXED) RETURNS(FIXED) GLOBAL;
  SPC INP_ABS     ENTRY (FIXED, FIXED) GLOBAL;  /* Wochenkalender                   */
  SPC TASKST    ENTRY (CHAR(24)) RETURNS (BIT(32)) GLOBAL; /* Status? */

/* Datenstationen */


/* Variablen  */
  DCL ZTESTVIS  FIXED;


#INCLUDE c:\p907\033bgadrallehohne\spc.p;


VISUAL: TASK PRIO 30; ! Visualisierungsdaten,...

  DCL FL1             FLOAT;
  DCL FL2             FLOAT;
  DCL FL3             FLOAT;
  DCL ZVISUAL         FIXED;
  DCL F15             FIXED;
  DCL EINH            CHAR(3);
  DCL ZP1       CLOCK;
  DCL ZP2       CLOCK;
  DCL ZEXT(32)        FIXED;

  ZVISUAL=1;

  OPEN TEMP BY IDF('TEMP'),ANY;
  CALL REWIND(TEMP);

  PUT 'P',NR_PRJ TO TEMP BY A,F(4);
  PUT '  ',DA_DAT,'.',DA_MON,'.',DA_JAH,'  ' TO TEMP BY A,F(2),A,F(2),A,F(4),A;
  PUT ZP_NOW,'             ' TO TEMP BY T(8),A,SKIP;
  FOR I TO 120 REPEAT
    PUT I,TX_STOERMEL(I) TO TEMP BY F(3),A(20);
  END;
  PUT TOCHAR(27),TOCHAR(27),'D4' TO TEMP BY A,A,A;

  CLOSE TEMP;  
  PUT 'ER NIL.;rm /RD02/stoertx.txt' TO RTOS BY A;
  PUT 'ER NIL.;RENAME /RD02/TEMP > stoertx.txt' TO RTOS BY A;

  OPEN TEMP BY IDF('TEMP'),ANY;
  CALL REWIND(TEMP);

  PUT 'P',NR_PRJ TO TEMP BY A,F(4);
  PUT '  ',DA_DAT,'.',DA_MON,'.',DA_JAH,'  ' TO TEMP BY A,F(2),A,F(2),A,F(4),A;
  PUT ZP_NOW,'             ' TO TEMP BY T(8),A,SKIP;
  PUT MAXDAT TO TEMP BY F(3);
  FOR I TO MAXDAT REPEAT
    PUT VIERT_EINH(I) TO TEMP BY A(5);
  END;
  FOR I TO MAXDAT REPEAT
    PUT VIERT_NAME(I) TO TEMP BY A(20);
  END;
  PUT TOCHAR(27),TOCHAR(27),'D5' TO TEMP BY A,A,A;

  CLOSE TEMP;  
  PUT 'ER NIL.;rm /RD02/vierttx.txt' TO RTOS BY A;
  PUT 'ER NIL.;RENAME /RD02/TEMP > vierttx.txt' TO RTOS BY A;



  REPEAT 
    /* Einheiten: */
    /* 1: �C  */
    /* 2: bar  */
    /* 3: V    */
    /* 4: kW   */
    /* 5: m^3/h*/
    /* 6: mWS  */
    /* 7: %    */
    /* 8: kWh  */
    /* 9: Bh   */
    /*10: m^3 */
    /*11: �C� */
    /*12: mV  */
    /*13: UPM */
    /*14: s   */
    /*15: mbar*/
    /*16: A   */
    /*17: Hz  */
    /*18: l/h */
    /*19: l   */
    /*40: keine Einheit */

    ZP1=NOW; 
    
    ZVISUAL=ZVISUAL+1;
    IF ZVISUAL==100 THEN
      PUT 'ER NIL.;rm /RD02/viertdat.txt' TO RTOS BY A; /* vor ca. 200s wurde 1/4h-DAT geholt */
    FIN;

    OPEN TEMP BY IDF('TEMP'),ANY;
    CALL REWIND(TEMP);
    PUT 'P',NR_PRJ TO TEMP BY A,F(4);
    PUT '  ',DA_DAT,'.',DA_MON,'.',DA_JAH,'  ' TO TEMP BY A,F(2),A,F(2),A,F(4),A;
    PUT ZP_NOW,'             ' TO TEMP BY T(8),A,SKIP;
  
    PUT TOCHAR(27),TOCHAR(27),'V' TO TEMP;
  
    FOR I TO 32 REPEAT
      IF ZF_HKPEXT(I) > 0 OR ZF_HKPEXT(I) < 0 OR ZF_HKMIEXT(I) > 0 OR ZF_HKMIEXT(I) < 0 THEN
        ZEXT(I)=1;
      ELSE
        ZEXT(I)=0;
      FIN;
    END;
    PUT 'HK  1, CLICK',ZEXT(1) TO TEMP BY A,F(1);  /* Button fuer: HK1 Nordtrasse    */
    PUT 'HK  2, CLICK',ZEXT(2) TO TEMP BY A,F(1);  /* Button fuer: HK2 Westtrasse    */
    PUT 'HK  3, CLICK',ZEXT(3) TO TEMP BY A,F(1);  /* Button fuer: HK3 Suedtrasse    */
    PUT 'HK  4, CLICK',ZEXT(4) TO TEMP BY A,F(1);  /* Button fuer: Trocknung         */

    FOR I TO 10 REPEAT
      IF ZF_KEINEXT(I) > 0 OR ZF_KEINEXT(I) < 0 OR ZF_KPMPEXT(I) > 0 OR ZF_KPMPEXT(I) < 0 THEN
        ZEXT(I)=1;
      ELSE
        ZEXT(I)=0;
      FIN;
    END;
    PUT 'KES 1, CLICK',ZEXT(1) TO TEMP BY A,F(1);  /* Button fuer: Holzkessel1  */
    PUT 'KES 2, CLICK',ZEXT(2) TO TEMP BY A,F(1);  /* Button fuer: Holzkessel2  */
    PUT 'KES 3, CLICK',ZEXT(3) TO TEMP BY A,F(1);  /* Button fuer: Biogaskessel */

    FOR I TO 8 REPEAT
      IF ZF_BEINEXT(I) > 0 OR ZF_BEINEXT(I) < 0 THEN
        ZEXT(I)=1;
      ELSE
        ZEXT(I)=0;
      FIN;
    END;
 !  PUT 'BHK 1, CLICK',ZEXT(1) TO TEMP BY A,F(1);  /* Button fuer: BHKW1        */
 !  PUT 'BHK 2, CLICK',ZEXT(2) TO TEMP BY A,F(1);  /* Button fuer: BHKW2        */
 !  PUT 'BHK 3, CLICK',ZEXT(3) TO TEMP BY A,F(1);  /* Button fuer: BHKW3        */

    FOR I TO 10 REPEAT
      ZEXT(I)=0;
    END;
 !  PUT 'WWL 1, CLICK',ZEXT(1) TO TEMP BY A,F(1);  /* Button fuer: WW1-Ladung Zentrale */
 !  PUT 'WWL 2, CLICK',ZEXT(2) TO TEMP BY A,F(1);  /* Button fuer: WW2-Ladung Haus A   */
 !  PUT 'WWL 3, CLICK',ZEXT(3) TO TEMP BY A,F(1);  /* Button fuer: WW3-Ladung Villa    */

    PUT 'HKNA 1',HK_NAME( 1) TO TEMP BY A,A;   /* Text, Name HK1  */
    PUT 'HKNA 2',HK_NAME( 2) TO TEMP BY A,A;   /* Text, Name HK2  */
    PUT 'HKNA 3',HK_NAME( 3) TO TEMP BY A,A;   /* Text, Name HK3  */
   
    PUT 'PMK 1,0, 4',PT_KES( 1) TO TEMP BY A,F(7,2);       /* Maximalleistung Holzkessel1   */
    PUT 'PMK 2,0, 4',PT_KES( 2) TO TEMP BY A,F(7,2);       /* Maximalleistung Holzkessel2   */
    PUT 'PMK 3,0, 4',PT_KES( 3) TO TEMP BY A,F(7,2);       /* Maximalleistung Biogaskessel  */
    PUT 'PMB 1,0, 4',PE_MAXBHKW( 1) TO TEMP BY A,F(7,2);   /* Maximalleistung BHKW     */
 !  PUT 'PMB 2,0, 4',PE_MAXBHKW( 2) TO TEMP BY A,F(7,2);   /* Maximalleistung BHKW2    */
 !  PUT 'PMB 3,0, 4',PE_MAXBHKW( 3) TO TEMP BY A,F(7,2);   /* Maximalleistung BHKW3    */

    /* anstehende St�rungen  */
    FOR I TO 120 REPEAT
      IF B_STOER(I) AND ZF_STOERFREI(I) < 2 THEN
        PUT 'STOE',I,TX_STOERMEL(I) TO TEMP BY A,F(3),A;
      FIN;
    END;
  
    /* relevante Analogeing�nge */
    PUT 'AI  0,1,11',TC_ATTAU   TO TEMP BY A,F(7,2);  /* durchschn. Aussentemp der letzten 24h */
    PUT 'AI  1,1, 1',X_AEIN( 1) TO TEMP BY A,F(7,2);    /* akt. Aussentemp. */
    PUT 'AI  2,1, 1',X_AEIN( 2) TO TEMP BY A,F(7,2);    /* Holzkessel1 VL       */
    PUT 'AI  3,1, 1',X_AEIN( 3) TO TEMP BY A,F(7,2);    /* Holzkessel1 RL       */
    PUT 'AI  4,1, 1',X_AEIN( 4) TO TEMP BY A,F(7,2);    /* Holzkessel2 VL       */
    PUT 'AI  5,1, 1',X_AEIN( 5) TO TEMP BY A,F(7,2);    /* Holzkessel2 RL       */
    PUT 'AI  6,1, 1',X_AEIN( 6) TO TEMP BY A,F(7,2);    /* Biogaskessel VL      */
    PUT 'AI  7,1, 1',X_AEIN( 7) TO TEMP BY A,F(7,2);    /* Biogaskessel RL      */
    PUT 'AI  8,1, 1',X_AEIN( 8) TO TEMP BY A,F(7,2);    /* Puffer1 oben         */
    PUT 'AI  9,1, 1',X_AEIN( 9) TO TEMP BY A,F(7,2);    /* Puffer1 Mitte oben   */
    PUT 'AI 10,1, 1',X_AEIN(10) TO TEMP BY A,F(7,2);    /* Puffer1 Mitte        */
    PUT 'AI 11,1, 1',X_AEIN(11) TO TEMP BY A,F(7,2);    /* Puffer1 Mitte unten  */
    PUT 'AI 12,1, 1',X_AEIN(12) TO TEMP BY A,F(7,2);    /* Puffer1 unten        */
    PUT 'AI 13,1, 1',X_AEIN(13) TO TEMP BY A,F(7,2);    /* Hauptkreis VL        */
    PUT 'AI 14,1, 1',X_AEIN(14) TO TEMP BY A,F(7,2);    /* Hauptkreis RL        */
    PUT 'AI 15,1, 1',X_AEIN(15) TO TEMP BY A,F(7,2);    /* HK1 Nordtrasse VL    */
    PUT 'AI 16,1, 1',X_AEIN(16) TO TEMP BY A,F(7,2);    /* HK1 Nordtrasse RL    */
    PUT 'AI 17,1, 1',X_AEIN(17) TO TEMP BY A,F(7,2);    /* HK2 Westtrasse VL    */
    PUT 'AI 18,1, 1',X_AEIN(18) TO TEMP BY A,F(7,2);    /* HK2 Westtrasse RL    */
    PUT 'AI 19,1, 1',X_AEIN(19) TO TEMP BY A,F(7,2);    /* HK3 Suedtrasse VL    */    
    PUT 'AI 20,1, 1',X_AEIN(20) TO TEMP BY A,F(7,2);    /* HK3 Suedtrasse RL    */    
    PUT 'AI 21,1, 1',X_AEIN(21) TO TEMP BY A,F(7,2);    /* Zuluft Trocknung     */    
    PUT 'AI 22,1, 1',X_AEIN(22) TO TEMP BY A,F(7,2);    /* BHKW VL              */    
    PUT 'AI 23,1, 1',X_AEIN(23) TO TEMP BY A,F(7,2);    /* BHKW RL              */    
    PUT 'AI 24,1, 1',X_AEIN(24) TO TEMP BY A,F(7,2);    /* Puffer2 oben        <<< */
    PUT 'AI 25,1, 1',X_AEIN(25) TO TEMP BY A,F(7,2);    /* Puffer2 Mitte oben  <<< */
    PUT 'AI 26,1, 1',X_AEIN(26) TO TEMP BY A,F(7,2);    /* Puffer2 Mitte       <<< */
    PUT 'AI 27,1, 1',X_AEIN(27) TO TEMP BY A,F(7,2);    /* Puffer2 Mitte unten <<< */
    PUT 'AI 28,1, 1',X_AEIN(28) TO TEMP BY A,F(7,2);    /* Puffer2 unten       <<< */
    PUT 'AI 30,1, 7',X_AEIN(30) TO TEMP BY A,F(7,2);    /* Biogas Fuellstand    */    
    PUT 'AI 32,2, 2',X_AEIN(32) TO TEMP BY A,F(7,2);    /* Druck Verteiler      */

 !  PUT 'AI181,1, 1',X_AEIN(181) TO TEMP BY A,F(7,2);    /* BHKW1 VL       */
 !  PUT 'AI182,1, 1',X_AEIN(182) TO TEMP BY A,F(7,2);    /* BHKW1 RL      */
 !  PUT 'AI183,1, 1',X_AEIN(183) TO TEMP BY A,F(7,2);    /* BHKW2 VL       */
 !  PUT 'AI184,1, 1',X_AEIN(184) TO TEMP BY A,F(7,2);    /* BHKW2 RL      */
  
 !  PUT 'AI201,1, 1',TCV_MBUS(11) TO TEMP BY A,F(7,2);   /* Unterstation1 VL       */
 !  PUT 'AI202,1, 1',TCR_MBUS(11) TO TEMP BY A,F(7,2);   /* Unterstation1 RL       */

    PUT 'TH  1,1, 1',TC_VIST    TO TEMP BY A,F(7,2); /* Hauptkreis VL IST */ 
    PUT 'TH  2,1, 1',TC_VSOLL   TO TEMP BY A,F(7,2); /* Hauptkreis VL SOLL */
 !  PUT 'GA  1,2, 3',FL_GAS     TO TEMP BY A,F(7,2); /* Spannung Gassensor */
    /* relevante th. Leistungen */
    PUT 'PKT 1,0, 4',PT_KESAKT( 1) TO TEMP BY A,F(7,2); /* thermische Leistung Holzkessel1 ca. */
    PUT 'PKT 2,0, 4',PT_KESAKT( 2) TO TEMP BY A,F(7,2); /* thermische Leistung Holzkessel2 ca. */
    PUT 'PKT 3,0, 4',PT_KESAKT( 3) TO TEMP BY A,F(7,2); /* thermische Leistung Biogaskessel ca. */
    PUT 'PT  1,1, 4',PTH_MBUS( 1)  TO TEMP BY A,F(7,2); /* Pth BHKW             */
    PUT 'PT  2,1, 4',PTH_MBUS( 2)  TO TEMP BY A,F(7,2); /* Pth Holzkessel1       */
    PUT 'PT  3,1, 4',PTH_MBUS( 3)  TO TEMP BY A,F(7,2); /* Pth Holzkessel2       */ 
    PUT 'PT  4,1, 4',PTH_MBUS( 4)  TO TEMP BY A,F(7,2); /* Pth Biogaskessel      */ 
    PUT 'PT  5,1, 4',PTH_MBUS( 5)  TO TEMP BY A,F(7,2); /* Pth HK1 Nordtrasse    */ 
    PUT 'PT  6,1, 4',PTH_MBUS( 6)  TO TEMP BY A,F(7,2); /* Pth HK2 Westtrasse    */ 
    PUT 'PT  7,1, 4',PTH_MBUS( 7)  TO TEMP BY A,F(7,2); /* Pth HK1 Suedtrasse    */ 
     /* relevante Durchfl�sse */
    PUT 'DF  1,1, 5',DF_MBUS( 1)  TO TEMP BY A,F(7,2); /* Durchfluss BHKW             */
    PUT 'DF  2,1, 5',DF_MBUS( 2)  TO TEMP BY A,F(7,2); /* Durchfluss Holzkessel1      */
    PUT 'DF  3,1, 5',DF_MBUS( 3)  TO TEMP BY A,F(7,2); /* Durchfluss Holzkessel2      */      
    PUT 'DF  4,1, 5',DF_MBUS( 4)  TO TEMP BY A,F(7,2); /* Durchfluss Biogaskessel     */      
    PUT 'DF  5,1, 5',DF_MBUS( 5)  TO TEMP BY A,F(7,2); /* Durchfluss HK1 Nordtrasse   */      
    PUT 'DF  6,1, 5',DF_MBUS( 6)  TO TEMP BY A,F(7,2); /* Durchfluss HK2 Westtrasse   */    
    PUT 'DF  7,1, 5',DF_MBUS( 7)  TO TEMP BY A,F(7,2); /* Durchfluss HK3 Suedtrasse   */    
   /* relevante Pumpendr�cke */
 !  PUT 'UDR 1,1, 6',UPE_ISTDRUCK( 1) TO TEMP BY A,F(7,2);  /* Differenzdruck Pumpe Kessel           */
 !  PUT 'UDR 2,1, 6',UPE_ISTDRUCK( 2) TO TEMP BY A,F(7,2);  /* Differenzdruck Pumpe1 HK1 NW nord    */
 !  PUT 'UDR 3,1, 6',UPE_ISTDRUCK( 3) TO TEMP BY A,F(7,2);  /* Differenzdruck Pumpe2 HK1 NW nord    */
 !  PUT 'UDR 4,1, 6',UPE_ISTDRUCK( 4) TO TEMP BY A,F(7,2);  /* Differenzdruck Pumpe1 HK2 NW sued    */
 !  PUT 'UDR 5,1, 6',UPE_ISTDRUCK( 5) TO TEMP BY A,F(7,2);  /* Differenzdruck Pumpe2 HK2 NW sued    */
    /* relevante P_DI-Leistungen */
 !  PUT 'PGG 1,0, 4',P_DI(10)*FL_GASHU TO TEMP BY A,F(7,2); /* Gas gesamt    */
 !  PUT 'PGB 1,0, 4',P_DI( 9)*FL_GASHU TO TEMP BY A,F(7,2); /* Gas BHKW       */
    PUT 'PBH 1,1, 4',PE_BIST(1) TO TEMP BY A,F(7,2);       /* el. Istleistung BHKW (ca.) */
    /* relevante Analogausg�nge */
    PUT 'AA  1,1, 7',X_AAUS(1)           TO TEMP BY A,F(7,2);    /* Soll Pumpe Biogaskessel <<< */    
    PUT 'AA  2,1, 7',X_AAUS(2)           TO TEMP BY A,F(7,2);    /* Soll Pumpe Holzkessel1   */    
    PUT 'AA  4,1, 7',X_AAUS(4)           TO TEMP BY A,F(7,2);    /* Soll Pumpe Holzkessel2   */   
    PUT 'AA  5,1, 7',X_AAUS(5)           TO TEMP BY A,F(7,2);    /* Soll Ventilator Trocknung */  
    PUT 'AA  6,1, 7',X_AAUS(6)           TO TEMP BY A,F(7,2);    /* Soll Pumpe HK1 Nordtrasse <<< */  
    PUT 'AA  7,1, 7',X_AAUS(7)           TO TEMP BY A,F(7,2);    /* Soll Pumpe HK2 Westtrasse <<< */  
    PUT 'AA  8,1, 7',X_AAUS(8)           TO TEMP BY A,F(7,2);    /* Soll Pumpe HK3 Suedtrasse <<< */  
 !  PUT 'AA 51,1, 7',UPE_SOLLST( 1)/2.55 TO TEMP BY A,F(7,2);    /* Soll Pumpe Kessel        */
 !  PUT 'AA 52,1, 7',UPE_SOLLST( 2)/2.55 TO TEMP BY A,F(7,2);    /* Soll Pumpe1 HK1 NW nord    */
 !  PUT 'AA 53,1, 7',UPE_SOLLST( 3)/2.55 TO TEMP BY A,F(7,2);    /* Soll Pumpe2 HK1 NW nord    */
 !  PUT 'AA 54,1, 7',UPE_SOLLST( 4)/2.55 TO TEMP BY A,F(7,2);    /* Soll Pumpe1 HK2 NW sued    */
 !  PUT 'AA 55,1, 7',UPE_SOLLST( 5)/2.55 TO TEMP BY A,F(7,2);    /* Soll Pumpe2 HK2 NW sued    */

    /* relevante Mischerstellungen */
    PUT 'MS  1,1, 7',Z_HKMISTELL( 1)/ZF_HKMISTELL( 1)*100 TO TEMP BY A,F(7,2); /* Mi HK1 Nordtrasse     */
    PUT 'MS  2,1, 7',Z_HKMISTELL( 2)/ZF_HKMISTELL( 2)*100 TO TEMP BY A,F(7,2); /* Mi HK2 Westtrasse     */
    PUT 'MS  3,1, 7',Z_HKMISTELL( 3)/ZF_HKMISTELL( 3)*100 TO TEMP BY A,F(7,2); /* Mi HK3 Suedtrasse     */   
    PUT 'MS  4,1, 7',Z_HKMISTELL( 4)/ZF_HKMISTELL( 4)*100 TO TEMP BY A,F(7,2); /* Motorventil Trocknung */ 
    PUT 'MS 11,1, 7',Z_KMISTELL( 1)/120*100               TO TEMP BY A,F(7,2); /* RL-Mischer Holzkessel1 */
    PUT 'MS 12,1, 7',Z_KMISTELL( 2)/120*100               TO TEMP BY A,F(7,2); /* RL-Mischer Holzkessel2 */ 
    PUT 'MS 13,1, 7',Z_KMISTELL( 3)/120*100               TO TEMP BY A,F(7,2); /* RL-Mischer Biogaskessel */
 !  PUT 'MS 21,1, 7',Z_LMISTELL(11)/ZF_LMISTELL(1)*100 TO TEMP BY A,F(7,2); /* Mi WW1-Ladung Kueche  */
 !  IF B_DO( 7) THEN
 !    PUT 'MS 22,1, 7',100                               TO TEMP BY A,F(7,2); /* Mi Zubr. Haus A       */   
 !  ELSE
 !    PUT 'MS 22,1, 7',  0                               TO TEMP BY A,F(7,2);    
 !  FIN;
 !  IF B_DO(10) THEN                                                                                       
 !    PUT 'MS 23,1, 7',100                               TO TEMP BY A,F(7,2); /* Mi Zubr. Villa        */  
 !  ELSE                                                                                                   
 !    PUT 'MS 23,1, 7',  0                               TO TEMP BY A,F(7,2);                              
 !  FIN;                                                                                                   
 !  PUT 'MS  3,1, 7',X_AAUS(4)                           TO TEMP BY A,F(7,2); /* Mi HK3 Buero */
  
    /* relevante Digitaldaten  <<< evtl. bei Digitalausg�ngen Handeinstellungen ber�cksichtigen ? */
    PUT 'PH  1,0, 0',B_DO(15)  TO TEMP BY A,B(1);  /* Pumpe HK1 Nordtrasse  */
    PUT 'PH  2,0, 0',B_DO(18)  TO TEMP BY A,B(1);  /* Pumpe HK2 Westtrasse  */
    PUT 'PH  3,0, 0',B_DO(21)  TO TEMP BY A,B(1);  /* Pumpe HK3 Suedtrasse  */
    PUT 'PH 11,0, 0',B_DO(25)  TO TEMP BY A,B(1);  /* Ventilator Trocknung  */
    PUT 'PH 12,0, 0',B_DO(24)  TO TEMP BY A,B(1);  /* Freigabe Gasfackel    */   
  
    PUT 'KPU 1,0, 0',B_DO( 2)  TO TEMP BY A,B(1);  /* Pumpe Holzkessel1  */
    PUT 'KPU 2,0, 0',B_DO( 6)  TO TEMP BY A,B(1);  /* Pumpe Holzkessel2  */    
    PUT 'KPU 3,0, 0',B_DO(12)  TO TEMP BY A,B(1);  /* Pumpe Biogaskessel */    
 !  PUT 'KPU11,0, 0',B_DO( 3)  TO TEMP BY A,B(1);  /* Motorv. Kessel1   */
    PUT 'KL  1,0, 0',B_KL(1)   TO TEMP BY A,B(1);  /* Holzkessel1 Betrieb */
    PUT 'KL  2,0, 0',B_KL(2)   TO TEMP BY A,B(1);  /* Holzkessel2 Betrieb */      
    PUT 'KL  3,0, 0',B_KL(3)   TO TEMP BY A,B(1);  /* Biogaskessel Betrieb */      
    PUT 'BPU 1,0, 0',B_BPMP(1) TO TEMP BY A,B(1);  /* Pumpe BHKW (grau) */
    PUT 'BL  1,0, 0',B_BL(1)   TO TEMP BY A,B(1);  /* BHKW Betrieb  */
 !  PUT 'LP  1,0, 0',B_DO(21)  TO TEMP BY A,B(1);  /* WW1 Ladepumpe Kueche */
 !  PUT 'LP  2,0, 0',B_DO(18)  TO TEMP BY A,B(1);  /* WW2 Ladepumpe Sporth */
 !  PUT 'ZP  1,0, 0',B_DO(24)  TO TEMP BY A,B(1);  /* WW1 Zirkp Kueche     */


    PUT 'SG  1,0, 0',B_SAMMELST   TO TEMP BY A,B(1);  /* Sammelstoerung */
 !  PUT 'BI 66,0, 0',B_BSTOER(1)  TO TEMP BY A,B(1);  /* BHKW1 Stoerung */
 !  PUT 'BI 67,0, 0',B_BSTOER(2)  TO TEMP BY A,B(1);  /* BHKW2 Stoerung */
    PUT 'BI 35,0, 0',B_KHARDST(1) TO TEMP BY A,B(1);  /* Holzkessel1  Stoerung */
    PUT 'BI 36,0, 0',B_KHARDST(2) TO TEMP BY A,B(1);  /* Holzkessel2  Stoerung */ 
    PUT 'BI 37,0, 0',B_KHARDST(3) TO TEMP BY A,B(1);  /* Biogaskessel Stoerung */ 
  
    PUT 'BI111,0, 0',B_ABSHK(1)   TO TEMP BY A,B(1);  /* Absenkung HK1 Nordtrasse  */
    PUT 'BI112,0, 0',B_ABSHK(2)   TO TEMP BY A,B(1);  /* Absenkung HK2 Westtrasse  */
    PUT 'BI113,0, 0',B_ABSHK(3)   TO TEMP BY A,B(1);  /* Absenkung HK3 Suedtrasse  */  
  
    PUT 'HKT 1,1, 1',TC_HKSOLLGES(1)  TO TEMP BY A,F(7,2);  /* HK1 Nordtrasse  VL-Sollwert  */
    PUT 'HKT 2,1, 1',TC_HKSOLLGES(2)  TO TEMP BY A,F(7,2);  /* HK2 Westtrasse  VL-Sollwert  */
    PUT 'HKT 3,1, 1',TC_HKSOLLGES(3)  TO TEMP BY A,F(7,2);  /* HK3 Suedtrasse  VL-Sollwert  */
    PUT 'HKT 4,1, 1',TC_HKSOLLGES(4)  TO TEMP BY A,F(7,2);  /* Trocknung   Zuluft-Sollwert  */
  ! PUT 'HKT22,1, 1',TC_VSOLLEXT(2)   TO TEMP BY A,F(7,2);  /* Zubr. Haus A      VL-Sollwert  */
  ! PUT 'HKT23,1, 1',TC_VSOLLEXT(3)   TO TEMP BY A,F(7,2);  /* Zubr. Villa       VL-Sollwert  */
  
  ! PUT 'BWT 1,1, 1',TC_BWS(1)       TO TEMP BY A,F(7,2);     /* WW1 Sollwert  */
  ! PUT 'BWT 2,1, 1',TC_VSOLLEXT(2)  TO TEMP BY A,F(7,2);     /* WW2 Sollwert (Puffer Haus A oben) */
  ! PUT 'BWT 3,1, 1',TC_VSOLLEXT(3)  TO TEMP BY A,F(7,2);     /* WW3 Sollwert (Puffer Villa oben) */
  
    PUT 'GR  1,2, 2',FL_DRWARN    TO TEMP BY A,F(7,2); /* Warngrenze HZG-Druck MIN */
  ! PUT 'GR  2,2, 3',FL_GASWARN   TO TEMP BY A,F(7,2); /* Warngrenze Gassensor     */
  ! PUT 'GR  3,2, 3',FL_GASSTOER  TO TEMP BY A,F(7,2); /* Stoergrenze Gassensor    */
    PUT TOCHAR(27),TOCHAR(27),'v' TO TEMP;
  
    CLOSE TEMP;  
    F15=SETPRI(1);
    PUT 'ER NIL.;rm /RD02/visdat.txt' TO RTOS BY A;
    PUT 'ER NIL.;RENAME /RD02/TEMP > visdat.txt' TO RTOS BY A;
    F15=SETPRI(30);



    /* Ausgabe anstehende Stoerungen */
    OPEN TEMP BY IDF('TEMP'),ANY;
    CALL REWIND(TEMP);
  
    PUT 'P',NR_PRJ TO TEMP BY A,F(4);
    PUT '  ',DA_DAT,'.',DA_MON,'.',DA_JAH,'  ' TO TEMP BY A,F(2),A,F(2),A,F(4),A;
    PUT ZP_NOW,'  ' TO TEMP BY T(8),A,SKIP;
    FOR I TO 200 REPEAT
      IF ((B_STOER(I) OR Z_STOERNEU(I) > ZF_STOERMAX24) OR Z_STOERFAST(I) > 0) AND ZF_STOERFREI(I) < 2 THEN
        IF Z_STOERFAST(I) > 0 THEN
          PUT I+500 TO TEMP BY F(3);
        ELSE
          PUT I TO TEMP BY F(3);
        FIN;
      FIN;
    END;
    PUT TOCHAR(27),TOCHAR(27),'D4' TO TEMP BY A,A,A;
  
    CLOSE TEMP;  
    F15=SETPRI(1);
    PUT 'ER NIL.;rm /RD02/stoerung.txt' TO RTOS BY A;
    PUT 'ER NIL.;RENAME /RD02/TEMP > stoerung.txt' TO RTOS BY A;
    F15=SETPRI(30);



    /*Ausgabe Zaehlerstaende */
    IF ZVISUAL REM 5 == 0 THEN
      OPEN TEMP BY IDF('TEMP'),ANY;
      CALL REWIND(TEMP);
    
      PUT 'P',NR_PRJ TO TEMP BY A,F(4);
      PUT '  ',DA_DAT,'.',DA_MON,'.',DA_JAH,'  ' TO TEMP BY A,F(2),A,F(2),A,F(4),A;
      PUT ZP_NOW,'             ' TO TEMP BY T(8),A,SKIP;
      PUT '                               akt. Stand       akt. Jahr         Vorjahr ' TO TEMP BY A,SKIP;

      PUT 'Waerme BHKW:               ' TO TEMP BY A;    EINH='kWh';  F15= 1;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;

      PUT 'Waerme Holzkessel1:        ' TO TEMP BY A;    EINH='kWh';  F15= 2;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;

      PUT 'Waerme Holzkessel2:        ' TO TEMP BY A;    EINH='kWh';  F15= 3;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;

      PUT 'Waerme Biogaskessel:       ' TO TEMP BY A;    EINH='kWh';  F15= 4;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;

      PUT 'Waerme HK1 Nordtrasse:     ' TO TEMP BY A;    EINH='kWh';  F15= 5;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;

      PUT 'Waerme HK2 Westtrasse:     ' TO TEMP BY A;    EINH='kWh';  F15= 6;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;

      PUT 'Waerme HK3 Suedtrasse:     ' TO TEMP BY A;    EINH='kWh';  F15= 7;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;

      PUT 'Wel BHKW (ca.):            ' TO TEMP BY A;    EINH='kWh';  F15= 8;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;
    
      PUT 'BHKW Betriebsstunden (ca.):' TO TEMP BY A;    EINH='h  ';  F15= 9;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;
    
      PUT 'Holzkessel1 Betriebsst:    ' TO TEMP BY A;    EINH='h  ';  F15=10;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;
    
      PUT 'Holzkessel2 Betriebsst:    ' TO TEMP BY A;    EINH='h  ';  F15=11;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;
    
      PUT 'Biogaskessel Betriebsst:   ' TO TEMP BY A;    EINH='h  ';  F15=12;
        PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
        PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;
    
   !  PUT 'Gas gesamt:                ' TO TEMP BY A;    EINH='m^3';  F15= 6;
   !    PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
   !    PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;
   !
   !  PUT 'Gas BHKW1:                 ' TO TEMP BY A;    EINH='m^3';  F15= 7;
   !    PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
   !    PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;
   !
   !  PUT 'HZG-Nachspeisung:          ' TO TEMP BY A;    EINH='l  ';  F15=14;
   !    PUT JAHR_ZAEHL(F15,7),EINH TO TEMP BY F(11,1),A;
   !    PUT JAHR_ZAEHL(F15,1),EINH,JAHR_ZAEHL(F15,2),EINH TO TEMP BY F(13,1),A,F(13,1),A,SKIP;
    
   
      PUT TOCHAR(27),TOCHAR(27),'D4' TO TEMP BY A,A,A;

      CLOSE TEMP;  
      F15=SETPRI(1);
      PUT 'ER NIL.;rm /RD02/zaehl.txt' TO RTOS BY A;
      PUT 'ER NIL.;RENAME /RD02/TEMP > zaehl.txt' TO RTOS BY A;
      F15=SETPRI(30);

    FIN; /* Ende Zaehlerstaende */



    /* Ausgabe Protokoll */
    IF ZVISUAL==2 OR ZVISUAL==120 THEN
      IF ZVISUAL==120 THEN  ZVISUAL=20;  FIN;  /* alle ca. 160s  */
      OPEN TEMP BY IDF('TEMP'),ANY;
      CALL REWIND(TEMP);
    
      PUT '{' TO TEMP BY A;						/* start JSON-Object*/	  
	    PUT 'prjNo:',NR_PRJ TO TEMP BY A,F(4);
      PUT ',prjName:"',IDPI,'"' TO TEMP BY A,A,A;
	  
      PUT ',date:"',DA_DAT,'.',DA_MON,'.',DA_JAH,' ',ZP_NOW,'"' TO TEMP BY A,F(2),A,F(2),A,F(4),A,T(8),A;
    
      PUT ',AI:' TO TEMP BY A;
      PUT '[' TO TEMP BY A;						/* start JSON-Array*/
      FOR I TO N_FUEHLER REPEAT
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'no:', I TO TEMP BY A,F(3);
        PUT ',name:"', FP_NAME(I),'"' TO TEMP BY A,A,A;
        PUT ',uMin:',FP_ULOW(I) TO TEMP BY A,F(6);
        IF FP_TYP(I)/=3 AND FP_TYP(I)/=12 AND FP_TYP(I)/=15 THEN
          PUT ',uMax:',FP_UHIGH(I) TO TEMP BY A,F(6);
          FIN;
        PUT ',min:',FL_XAEINMIN(I) TO TEMP BY A,F(6,1);
        PUT ',max:',FL_XAEINMAX(I) TO TEMP BY A,F(6,1);
        PUT ',rangeCheck:',B_FUEHLWACH(I) TO TEMP BY A,B(1);
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/
        IF I<N_FUEHLER THEN
          PUT ',' TO TEMP BY A;
          FIN;
      END;
      PUT ']' TO TEMP BY A;						/* end JSON-Array*/
	  
      PUT ',AO:' TO TEMP BY A;
      PUT '[' TO TEMP BY A;						/* start JSON-Array*/
      FOR I TO N_ANALOG REPEAT
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'no:', I TO TEMP BY A,F(3);
        PUT ',name:"', AP_NAME(I),'"' TO TEMP BY A,A,A;
        PUT ',uMin:',AP_ULOW(I) TO TEMP BY A,F(6,2);
        PUT ',uMax:',AP_UHIGH(I) TO TEMP BY A,F(6,2);
        PUT ',betriebsart:',Z_AAUTO(I) TO TEMP BY A,F(1); /*auto, hand, hand(nurWert)*/
        PUT ',handwert:',X_AHAND(I) TO TEMP BY A,F(6,1);
        PUT ',min:',X_AAUSMIN(I) TO TEMP BY A,F(6,1);
        PUT ',max:',X_AAUSMAX(I) TO TEMP BY A,F(6,1);
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/
        IF I<N_ANALOG THEN
          PUT ',' TO TEMP BY A;
          FIN;
      END;
      PUT ']' TO TEMP BY A;						/* end JSON-Array*/
	  
      PUT ',DO:' TO TEMP BY A;
      PUT '[' TO TEMP BY A;						/* start JSON-Array*/
      FOR I TO N_RELPLT*8 REPEAT
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'no:', I TO TEMP BY A,F(3);
        PUT ',name:"', DO_NAME(I),'"' TO TEMP BY A,A,A;
        PUT ',betriebsart:',Z_DOHAND(I) TO TEMP BY A,F(6); /*0=auto, >0=ein, <0=aus*/
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/
        IF I<N_RELPLT*8 THEN
          PUT ',' TO TEMP BY A;
          FIN;
      END;
      PUT ']' TO TEMP BY A;						/* end JSON-Array*/
	  
      PUT ',DI:' TO TEMP BY A;
      PUT '[' TO TEMP BY A;						/* start JSON-Array*/
      FOR I TO N_DIGIN REPEAT
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'no:', I TO TEMP BY A,F(3);
        PUT ',name:"', DI_NAME(I),'"' TO TEMP BY A,A,A;
        PUT ',betriebsart:',Z_DIBEWERT(I) TO TEMP BY A,F(1); /*norm, toggle, eins, null*/
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/
        IF I<N_DIGIN THEN
          PUT ',' TO TEMP BY A;
          FIN;
      END;
      PUT ']' TO TEMP BY A;						/* end JSON-Array*/
	  
      FOR I TO N_KESSEL REPEAT
        PUT ',Kessel',I,':' TO TEMP BY A,F(2),A;
		    PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        
        PUT 'Leistung:',PT_KES(I) TO TEMP BY A,F(5);
        PUT ',Pumpennachlauf:',ZF_KPNL(I) TO TEMP BY A,F(5);
        PUT ',AnfZeitBisPreg:',ZF_KWARML(I) TO TEMP BY A,F(5);
        PUT ',MaxVLtemp:',TC_KVMAX(I) TO TEMP BY A,F(5,1);
        PUT ',MaxSpreizung:',TD_KMAX(I) TO TEMP BY A,F(5,1);
        PUT ',UeberhVLsoll:',TD_KVLPLUS(I) TO TEMP BY A,F(5,1);
        PUT ',MindestAABetrieb:',X_AAKMIN(I) TO TEMP BY A,F(5,1);
        PUT ',StellzeitPreg:',ZF_KSTELL(I) TO TEMP BY A,F(5);
        PUT ',Kesselrang:',FS_LKES(I) TO TEMP BY A,F(5);
        
        PUT ',Leistungsregelung:' TO TEMP BY A;
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'P:',RP_K(I) TO TEMP BY A,F(8,1);
        PUT ',I:',RI_K(I) TO TEMP BY A,F(8,4);
        PUT ',D:',RD_K(I) TO TEMP BY A,F(8,1);
        PUT ',TauD:',RTAU_K(I) TO TEMP BY A,F(8,1);
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/
        
        PUT ',Durchflussregelung:' TO TEMP BY A;
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'P:',RP_KP(I) TO TEMP BY A,F(8,1);
        PUT ',I:',RI_KP(I) TO TEMP BY A,F(8,4);
        PUT ',D:',RD_KP(I) TO TEMP BY A,F(8,1);
        PUT ',TauD:',RTAU_KP(I) TO TEMP BY A,F(8,1);
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/

        PUT ',allgemeineParameter:' TO TEMP BY A;
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'autoKesselrangfolge:',B_FSLKESAUTO TO TEMP BY A,B(1);
        PUT ',KesseltoleranzHauptkreis:',TD_KS TO TEMP BY A,F(5,1);
        PUT ',PumpenvorlaufAktiv:',B_PMPVORL TO TEMP BY A,B(1);
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/

        PUT '}' TO TEMP BY A;						/* end JSON-Object*/
      END;
    
      FOR I TO N_BHKW REPEAT
        PUT ',BHKW',I,':' TO TEMP BY A,F(2),A;
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/

        PUT 'PelMax:',PE_MAXBHKW(I) TO TEMP BY A,F(5,1);
        PUT ',PelMin:',PE_MINBHKW(I) TO TEMP BY A,F(5,1);
        PUT ',PelSollMin:',PE_BMINPRO(I) TO TEMP BY A,F(5,1);
        PUT ',ThermostatVL:',TC_BHZGVO(I) TO TEMP BY A,F(5,1);
        PUT ',ThermostatRL:',TC_BHZGRO(I) TO TEMP BY A,F(5,1);
        PUT ',MindestVLsoll:',TC_BVLMIN(I) TO TEMP BY A,F(5,1);
        PUT ',Pumpennachlauf:',ZF_BPNL(I) TO TEMP BY A,F(5);
        PUT ',gesperrt:', NOT B_BERLAUBT(I) TO TEMP BY A, B(1);

        PUT ',allgemeineParameter:' TO TEMP BY A;
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'WarnungBeiStartanzahl:',ZF_STARTMAX TO TEMP BY A,F(5);
        PUT ',BHKW1EinschaltverzMinuten:',ZF_T1EIN TO TEMP BY A,F(5);
        PUT ',BHKW1DeltaEinschalttemp:',TD_1EIN TO TEMP BY A,F(5);
        PUT ',MinTCMAX:',TC_MAXMIN TO TEMP BY A,F(5,1);
        PUT ',MinimalBeachteterStrombedarf:',PE_RMIN1B TO TEMP BY A,F(5,1);
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/
        
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/
      END;
    
      FOR I TO N_HZKR REPEAT
        PUT ',HK',I,':' TO TEMP BY A,F(2),A;
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'name:"',HK_NAME(I),'"' TO TEMP BY A,A,A;
        PUT ',NennVL:',TC_HKVNENN(I) TO TEMP BY A,F(4);
        PUT ',MindestVL:',TC_HKVMIN(I) TO TEMP BY A,F(4);
        PUT ',Tagheizgrenze:',TC_HMT(I) TO TEMP BY A,F(4,1);    
        PUT ',Nachtheizgrenze:',TC_HMN(I) TO TEMP BY A,F(5,1);
        PUT ',Nennraumtemp:',TC_HKINENN(I) TO TEMP BY A,F(4,1);
        PUT ',Nennaussentemp:',TC_HKANENN(I) TO TEMP BY A,F(5,1);
        PUT ',Exponent:',FL_EXPHK(I) TO TEMP BY A,F(4,1); 
        PUT ',deltaAbsenkung:',TD_ABSHK(I) TO TEMP BY A,F(4,1);
        PUT ',STWhkVL:',TC_HKSTW(I) TO TEMP BY A,F(4);
        PUT ',StellzeitMischer:',ZF_HKMISTELL(I) TO TEMP BY A,F(5);
        PUT ',LangfrIntegratorMax:',TD_HKINTMAX(I) TO TEMP BY A,F(5,1);
        PUT ',LangfrIntegratorMin:',TD_HKINTMIN(I) TO TEMP BY A,F(5,1);
        
        PUT ',Temperaturregelung:' TO TEMP BY A;
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'P:',RP_M(I) TO TEMP BY A,F(8,1);
        PUT ',I:',RI_M(I) TO TEMP BY A,F(8,4);
        PUT ',D:',RD_M(I) TO TEMP BY A,F(8,1);
        PUT ',TauD:',RTAU_M(I) TO TEMP BY A,F(8,1);
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/

        PUT ',Durchflussregelung:' TO TEMP BY A;
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'AT20:',FL_SOLLAT20(I) TO TEMP BY A,F(8,1);
        PUT ',AT5:',FL_SOLLAT5(I) TO TEMP BY A,F(8,1);
        PUT ',AT_10:',FL_SOLLATM10(I) TO TEMP BY A,F(8,1);
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/

        PUT ',Wochenkalender:"' TO TEMP BY A;
        FOR INDEX TO 1008 REPEAT  /* 7[tage]*24[std]*6[10min] = 1008 */
          PUT B_ZONE1((I-1)//16+1,INDEX).BIT((I-1) REM 16+1) TO TEMP BY B(1);
        END;
        PUT '"' TO TEMP BY A;

        PUT ',Jahreskalender:"' TO TEMP BY A;
        FOR MONAT TO 12 REPEAT
          FOR TAG TO 31 REPEAT
            PUT B_JAHRAB(MONAT,TAG).BIT(I) TO TEMP BY B(1);
          END;
        END;
        PUT '"' TO TEMP BY A;

        PUT '}' TO TEMP BY A;						/* end JSON-Object*/

        
      END;

      PUT '}' TO TEMP BY A;						/* end JSON-Object*/

      CLOSE TEMP;  
      F15=SETPRI(1);
      PUT 'ER NIL.;rm /RD02/prot.txt' TO RTOS BY A;
      PUT 'ER NIL.;RENAME /RD02/TEMP > prot.txt' TO RTOS BY A;
      F15=SETPRI(30);

    FIN; /* Ende Protokoll */



 !  ZP2=NOW;
 !  PUT ZP1,ZP2,ZP2-ZP1 TO A1 BY T(18,3),T(18,3),D(27,3),SKIP;

    AFTER 2 SEC RESUME;

  END;  /* REPEAT ENDLOS */

END; ! of VISUAL


TESTVIS: TASK PRIO 10;
  ZTESTVIS=100;
END;

/* ANTWORT DER VISUALISIERUNG ENTGEGEGNEHMEN */
GETVISANTWORT: TASK PRIO 18;
  DCL CH1  CHAR(1);
  DCL CHAR3   CHAR(3);
  DCL CHAR24  CHAR(24);
  DCL F15     FIXED;
  DCL F152    FIXED;
  DCL FIX1    FIXED;
  DCL FL1     FLOAT;
  DCL AS      FIXED;
  DCL conv_error FIXED;
  DCL conv_error2 FIXED;


  REPEAT
    AS=TOFIXED(ZEILRUECK(20).CHAR(60));
    IF ZTESTVIS > 0 THEN
      ZTESTVIS=ZTESTVIS-1;
      PUT 'GETVIS:',AS TO A1 BY A,F(4),SKIP;
    FIN;
    IF AS > 0 THEN
      AFTER 0.4 SEC RESUME;
      IF AS==88 THEN                             /* X    */

    !   FOR I TO 20 REPEAT
    !     PUT ZEILRUECK(I) TO A1 BY A,SKIP;  /* Testausgabe */
    !   END;
        PUT TO A1 BY SKIP;
        PUT 'VIS-Fragezeilen: ' TO A1 BY A,SKIP;
      
        FOR I TO 20 REPEAT
          PUT 'V',I+69,' ' TO A1 BY A,F(3),A;
          FOR K TO 60 REPEAT
            CH1=ZEILVIS(I).CHAR(K);
            IF TOFIXED(CH1) < 33 THEN
              PUT '-' TO A1 BY A;
            ELSE
              PUT CH1 TO A1 BY A;
            FIN;
          END;
          PUT TO A1 BY SKIP;
        END;

        PUT TO A1 BY SKIP;
        PUT 'VIS-Antwortzeilen: ' TO A1 BY A,SKIP;
      
        FOR I TO 20 REPEAT
          PUT 'V',I+89,' ' TO A1 BY A,F(3),A;  
          FOR K TO 60 REPEAT
            CH1=ZEILRUECK(I).CHAR(K);
            IF TOFIXED(CH1) < 33 THEN
              PUT '-' TO A1 BY A;
            ELSE
              PUT CH1 TO A1 BY A;
            FIN;
          END;
          PUT TO A1 BY SKIP;
        END;

        CONVERT CHAR3,FIX1 FROM ZEILRUECK( 1) BY RST(conv_error), A(3), RST(conv_error2), F(2);  

        IF conv_error==0 AND conv_error2==0 THEN


          F15=INSTR(CHAR3,1,3,'BHK',1,3);
          IF F15 > 0 THEN                 /* BHKW      */
            IF FIX1 > 0 AND FIX1 <  9 THEN
              CONVERT CHAR24,F15 FROM ZEILRUECK( 2) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 > -2 AND F15 < 101 THEN
                  IF F15 > -1 THEN  B_BERLAUBT(FIX1)='1'B;  FIN;
                  ZF_BEINEXT(FIX1)=F15;               /* Betriebsart  */
                FIN;
              FIN;

              CONVERT CHAR24,F15 FROM ZEILRUECK( 3) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 >  0 AND F15 < 101 THEN
                  B_BEIN(FIX1)='1'B;                  /* Einmalig EINschalten      */
                FIN;
              FIN;

              CONVERT CHAR24,F15 FROM ZEILRUECK( 4) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 >  0 AND F15 < 101 THEN
                  B_BEIN(FIX1)='0'B;                  /* Einmalig AUSschalten      */
                FIN;
              FIN;

              CONVERT CHAR24,F15 FROM ZEILRUECK( 5) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 >  0 AND F15 < 101 THEN
                  PREVENT I_DISP;
                  TERMINATE I_DISP;
                  PREVENT DISPLAY;
                  TERMINATE DISPLAY;
                  PREVENT MENU;
                  TERMINATE MENU;
                  CALL ANZ_AUS;
                  AFTER 0.1 SEC RESUME;
                  CALL ANZ_AUS;
                  ACTIVATE I_DISP;
                  AFTER 0.3 SEC RESUME;
                  Z_WAIT=0;
              !   B_MENU='0'B;
                  IF F15 > 1 THEN  X_ZUGANGKAL=0;  FIN;  /* Kalender nur darstellen */
                  FOR I TO 25 REPEAT
                    ZEIL80(I)='                                                                                ';
                  END;
                  CALL INP_ABS(  60+100,2);   /* so kann man direkt von hier aus den BHKW Freigabekalender aufrufen ( 60   + 100) */
                FIN;
              FIN;

            FIN;  /* IF FIX1 */
            FOR I TO 20 REPEAT   /* abgearbeitet */
              ZEILRUECK(I)='                                                            ';
            END;
            CHAR3='   ';
     !      TERMINATE;

          FIN; /* IF F15  BHK */


          F15=INSTR(CHAR3,1,3,'HK',1,2);
          IF F15 > 0 THEN                 /* Heizkreis */
            IF FIX1 > 0 AND FIX1 < 33 THEN
              CONVERT CHAR24,FL1 FROM ZEILRUECK( 2) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4),SKIP;
                IF FL1 > 10.0 AND FL1 < 100.0 THEN
                  TC_HKVNENN(FIX1)=FL1;               /* NennVL       */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 3) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4),SKIP;
                IF FL1 > 10.0 AND FL1 < 100.0 THEN
                  TC_HKVMIN(FIX1)=FL1;                /* MindestVL    */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 4) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4),SKIP;
                IF FL1 > -2.1 AND FL1 < 100.0 THEN
                  TC_HMT(FIX1)=FL1;                   /* Tagheizgrenze */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 5) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4),SKIP;
                IF FL1 > -2.1 AND FL1 < 100.0 THEN
                  TC_HMN(FIX1)=FL1;                   /* Nachtheizgr  */
                FIN;
              FIN;
              FL1=0.0;

              F152=0;
              CONVERT CHAR24,F15 FROM ZEILRUECK( 6) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT F15 TO A1 BY F(5),SKIP;
                IF F15 > -2 AND F15 < 101 THEN
                  IF F15 /= ZF_HKPEXT(FIX1) THEN
                    ZF_HKPEXT(FIX1)=F15;                /* Betriebsart HK */
                    F152=111;                           /* Merker: Betriebsart geaendert */
                  FIN;
                FIN;
              FIN;
              F15=0;


              CONVERT CHAR24,FL1 FROM ZEILRUECK( 7) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4),SKIP;
                IF FL1 > -0.1 AND FL1 < 100.1 THEN
                  FL_SOLLAT20(FIX1)=FL1;              /* AT=20        */
                FIN;                                  
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 8) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4),SKIP;
                IF FL1 > -0.1 AND FL1 < 100.1 THEN
                  FL_SOLLAT5(FIX1)=FL1;               /* AT=5         */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 9) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4),SKIP;
                IF FL1 > -0.1 AND FL1 < 100.1 THEN
                  FL_SOLLATM10(FIX1)=FL1;             /* AT= -10      */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,F15 FROM ZEILRUECK(10) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT F15 TO A1 BY F(5),SKIP;
                IF F15 > -2 AND F15 < 101 THEN
                  ZF_HKMIEXT(FIX1)=F15;               /* Mischer      */
                FIN;
              FIN;
              F15=0;

         !    IF F152 < 10 THEN  /* Betriebsart wurde noch nicht geaendert */
         !      CONVERT CHAR24,F15 FROM ZEILRUECK(11) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
         !      IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
         !        PUT F15 TO A1 BY F(5),SKIP;
         !        IF F15 > -2 AND F15 < 101 THEN
         !          ZF_HKPEXT(FIX1)=F15;                /* Betriebsart Pumpe */
         !        FIN;
         !      FIN;
         !    FIN;
         !    F15=0;

              CONVERT CHAR24,F15 FROM ZEILRUECK(11) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT F15 TO A1 BY F(5),SKIP;
                IF F15 >  0 AND F15 < 101 THEN
                  PREVENT I_DISP;
                  TERMINATE I_DISP;
                  PREVENT DISPLAY;
                  TERMINATE DISPLAY;
                  PREVENT MENU;
                  TERMINATE MENU;
                  CALL ANZ_AUS;
                  AFTER 0.1 SEC RESUME;
                  CALL ANZ_AUS;
                  ACTIVATE I_DISP;
                  AFTER 0.3 SEC RESUME;
                  Z_WAIT=0;
                  TERMINATE MENU;
                  IF F15 > 1 THEN  X_ZUGANGKAL=0;  FIN;  /* Kalender nur darstellen */
                  FOR I TO 25 REPEAT
                    ZEIL80(I)='                                                                                ';
                  END;
            ! !   IF FIX1 > 29 THEN
            ! !     CALL INP_ABS(FIX1+100,2);   /* so kann man direkt von hier aus einen ZONEN-Absenkungskalender aufrufen (Index + 100) */
            ! !   ELSE
            !       CALL INP_ABS(FIX1+100,3);   /* so kann man direkt von hier aus einen HK-Absenkungskalender aufrufen (Index + 100) */
            ! !   FIN; 
                  IF FIX1 >  3 THEN     /* <<< */
                    CALL INP_ABS( 61 +100,2);   /* so kann man direkt von hier aus einen Timer aufrufen (61 = Timer Trocknung ZwangsEIN) */
                  ELSE
                    CALL INP_ABS(FIX1+100,3);   /* so kann man direkt von hier aus einen HK-Absenkungskalender aufrufen (Index + 100) */
                  FIN; 
               FIN;
              FIN;
              F15=0;

              Z_HMNEU=0;
            FIN;  /* IF FIX1 */
            FOR I TO 20 REPEAT   /* abgearbeitet */
              ZEILRUECK(I)='                                                            ';
            END;
            CHAR3='   ';
     !      TERMINATE;

          FIN; /* IF F15   HK */


          F15=INSTR(CHAR3,1,3,'KES',1,3);
          IF F15 > 0 THEN                 /* Kessel    */
            IF FIX1 > 0 AND FIX1 < 11 THEN
              CONVERT CHAR24,F15 FROM ZEILRUECK( 2) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 > -2 AND F15 < 101 THEN
                  IF F15 > -1 THEN  B_KERLAUBT(FIX1)='1'B;  FIN;
                  ZF_KEINEXT(FIX1)=F15;               /* Betriebsart  */
                FIN;
              FIN;

              CONVERT CHAR24,F15 FROM ZEILRUECK( 3) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 >  0 AND F15 < 101 THEN
                  B_KEIN(FIX1)='1'B;                  /* Einmalig EINschalten      */
                FIN;
              FIN;

              CONVERT CHAR24,F15 FROM ZEILRUECK( 4) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 >  0 AND F15 < 101 THEN
                  B_KEIN(FIX1)='0'B;                  /* Einmalig AUSschalten      */
                FIN;
              FIN;

              CONVERT CHAR24,F15 FROM ZEILRUECK( 5) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 > -1 AND F15 < 101 THEN
                  ZF_KPMPEXT(FIX1)=F15;               /* Kesselpumpe      */
                FIN;
              FIN;

           !  CONVERT CHAR24,FL1 FROM ZEILRUECK( 6) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
           !  IF conv_error==0 THEN
           !    IF FL1 > 10.0 AND FL1 < 100.0 THEN
           !      TC_KVMAX(FIX1)=FL1;                 /* VL-Thermostat (+4K=AUS)      */
           !    FIN;
           !  FIN;

            FIN;  /* IF FIX1 */
            FOR I TO 20 REPEAT   /* abgearbeitet */
              ZEILRUECK(I)='                                                            ';
            END;
            CHAR3='   ';
     !      TERMINATE;

          FIN; /* IF F15  KES */



          F15=INSTR(CHAR3,1,3,'WWL',1,3);
          IF F15 > 0 THEN                 /* WW-Ladung */
            IF FIX1 > 0 AND FIX1 < 11 THEN
              CONVERT CHAR24,FL1 FROM ZEILRUECK( 2) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF FL1 > 10.0 AND FL1 < 100.0 THEN
                  TC_BWSOLL(FIX1)=FL1;                /* Sollwert Tag */
                FIN;
              FIN;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 3) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF FL1 > 10.0 AND FL1 < 100.0 THEN
                  TC_BWMIN(FIX1)=FL1;                 /* Sollwert Nacht */
                FIN;
              FIN;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 4) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF FL1 > 10.0 AND FL1 < 100.0 THEN
                  TC_BWZRSOLL(FIX1)=FL1;                 /* Sollwert Zirk-RL */
                FIN;
              FIN;

              CONVERT CHAR24,F15 FROM ZEILRUECK( 5) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 >  0 AND F15 < 101 THEN
                  Z_LEGIO(FIX1)=21600;
                FIN;
              FIN;

              CONVERT CHAR24,F15 FROM ZEILRUECK( 6) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                IF F15 >  0 AND F15 < 101 THEN
                  PREVENT I_DISP;
                  TERMINATE I_DISP;
                  PREVENT DISPLAY;
                  TERMINATE DISPLAY;
                  PREVENT MENU;
                  TERMINATE MENU;
                  CALL ANZ_AUS;
                  AFTER 0.1 SEC RESUME;
                  CALL ANZ_AUS;
                  ACTIVATE I_DISP;
                  AFTER 0.3 SEC RESUME;
                  Z_WAIT=0;
                  TERMINATE MENU;
                  IF F15 > 1 THEN  X_ZUGANGKAL=0;  FIN;  /* Kalender nur darstellen */
                  FOR I TO 25 REPEAT
                    ZEIL80(I)='                                                                                ';
                  END;
                  CALL INP_ABS(FIX1+33+100,2);   /* so kann man direkt von hier aus einen WW-Absenkungskalender aufrufen (Index + 33 + 100) */
                FIN;
              FIN;

            FIN;  /* IF FIX1 */
            FOR I TO 20 REPEAT   /* abgearbeitet */
              ZEILRUECK(I)='                                                            ';
            END;
            CHAR3='   ';
     !      TERMINATE;

          FIN; /* IF F15  WWL */

        FIN;  /* IF conv_error */

      ELSE  /* NICHT X */
        
      FIN;
    ELSE  /* NICHT > 0 */
      AFTER 0.2 SEC RESUME;
    FIN;
  END; /* REPEAT */

END;



VISTEXTFELD: PROC GLOBAL;   /* Aufruf aus GETCHANTWORT2 (MPC.P) */
  DCL CHAR2  CHAR(2);
  DCL CHAR3  CHAR(3);
  DCL conv_error FIXED;
  DCL F15    FIXED;
  DCL FIX1   FIXED;
  DCL OBJNAME (64) CHAR(20);
  DCL STAT    BIT(32);

  FOR I TO 20 REPEAT
    ZEILVIS(I)=  '                                                            ';
    ZEILRUECK(I)='                                                            ';
  END;
  FOR I TO 64 REPEAT
    OBJNAME(I)='                    ';
  END;

  /* uebertragenen String auswerten z.B.:  http://172.16.0.102/JSONADD/PUT?V008=QzHK  2  also "QzHK  2"   */
  /* dann fuer das gemeinte Objekt ein Textfeld erstellen (20 Zeilen je 60 Zeichen)                       */
  /* entfernter Browser liest das aus und stellt die Infos dar                                            */
  /* bei Aenderungen an Parametern wird das ganze Textfeld zurueckuebertragen und hier wieder ausgewertet */

  CONVERT CHAR2,CHAR3,FIX1 FROM CHANTWORT2 BY RST(conv_error), A(2), A(3), F(5);  /* CHAR2: "Qz" CHAR3: z.B.: "HK "  FIX1: Objektnummer (z.B.: " 2" fuer HK2) */
  IF conv_error==0 THEN

    PREVENT I_DISP;
    TERMINATE I_DISP;
    PREVENT DISPLAY;
    TERMINATE DISPLAY;
    PREVENT MENU;
    TERMINATE MENU;
    CALL ANZ_AUS;
    PREVENT GETVISANTWORT;
    TERMINATE GETVISANTWORT;
    AFTER 0.1 SEC RESUME;
    CALL ANZ_AUS;
    ACTIVATE I_DISP;

    PUT CHANTWORT2,'  conv OK' TO A1 BY A,A,SKIP;     /* TESTAUSGABE */
    /* Daten machen Sinn, jetzt suchen was gemeint war */

    F15=INSTR(CHAR3,1,3,'BHK',1,3);
    IF F15 > 0 THEN                 /* BHKW      */
      FOR I TO  8 REPEAT
        CONVERT ' ','BHKW',I TO OBJNAME(I) BY A,A,F(2);
      END; 
      IF FIX1 > 0 AND FIX1 <  9 THEN  /* 8 BHKWs */                         /*   MAX        MIN     NK */
        CONVERT 'BHK',FIX1,'                   ',OBJNAME(FIX1)                                                   TO ZEILVIS( 1) BY A,F(2),A;     ZEILVIS( 1).CHAR(60)='H';  /* letztes Zeichen H */
        CONVERT 'Betriebsart             ',ZF_BEINEXT(FIX1),        '       ', 100.0,' ',  -1.0,' ', 0,'      '  TO ZEILVIS( 2) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Einmalig EINschalten    ',0,                       '       ',   1.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS( 3) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Einmalig AUSschalten    ',0,                       '       ',   1.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS( 4) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Wochenk. BHKWs Freigabe ',0,                       '       ',   2.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS( 5) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        ZEILVIS(20).CHAR(60)='X';
      FIN;
      CHAR3='   '; /* fertig */
    FIN;

    F15=INSTR(CHAR3,1,3,'HK',1,2);
    IF F15 > 0 THEN                 /* Heizkreis */
      FOR I TO 32 REPEAT
        OBJNAME(I)=HK_NAME(I);
      END; 
      OBJNAME(4)=' Trocknung ';
   !  FOR I FROM 29 TO 55 REPEAT   /* Zonen  */
   !    OBJNAME(I)=T_NAME(I);
   !  END; 
      IF FIX1 > 0 AND FIX1 < 32 THEN   /*   HKs */                          /*   MAX        MIN     NK */
        CONVERT 'HK ',FIX1,'                   ',OBJNAME(FIX1)                                                   TO ZEILVIS( 1) BY A,F(2),A,A;     ZEILVIS( 1).CHAR(60)='H';  /* letztes Zeichen H */
        IF FIX1 > 0 AND FIX1 <  4 THEN /* mit Pumpenregelung   */
          CONVERT 'NennVL                  ',TC_HKVNENN(FIX1),        '  ',       98.0,' ',  20.0,' ', 1,' &degC'  TO ZEILVIS( 2) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;   
          CONVERT 'MindestVL               ',TC_HKVMIN(FIX1),         '  ',       95.0,' ',  20.0,' ', 1,' &degC'  TO ZEILVIS( 3) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
          CONVERT 'Tagheizgrenze           ',TC_HMT(FIX1),            '  ',       55.0,' ',  -1.0,' ', 1,' &degC'  TO ZEILVIS( 4) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
          CONVERT 'Nachtheizgrenze         ',TC_HMN(FIX1),            '  ',       55.0,' ',  -2.0,' ', 1,' &degC'  TO ZEILVIS( 5) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
          CONVERT 'HK-Betriebsart          ',ZF_HKPEXT(FIX1),         '       ', 100.0,' ',  -1.0,' ', 0,' %    '  TO ZEILVIS( 6) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
          CONVERT '20 &degC                ',FL_SOLLAT20(FIX1),       '  ',      100.0,' ',   0.0,' ', 1,' %    '  TO ZEILVIS( 7) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
          CONVERT '5 &degC                 ',FL_SOLLAT5(FIX1),        '  ',      100.0,' ',   0.0,' ', 1,' %    '  TO ZEILVIS( 8) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
          CONVERT '-10 &degC               ',FL_SOLLATM10(FIX1),      '  ',      100.0,' ',   0.0,' ', 1,' %    '  TO ZEILVIS( 9) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
          CONVERT 'Mischer-Betriebsart     ',ZF_HKMIEXT(FIX1),        '       ',   2.0,' ',  -1.0,' ', 0,' %    '  TO ZEILVIS(10) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;     /* auf/zu Mischer */
     !    CONVERT 'Mischer-Betriebsart     ',ZF_HKMIEXT(FIX1),        '       ', 100.0,' ',  -1.0,' ', 0,' %    '  TO ZEILVIS(10) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;     /* 0-10V Mischer */
          CONVERT 'HK-Wochenkalender       ',0,                       '       ',   2.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS(11) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        ELSE
          CONVERT 'Zuluftsoll              ',TC_HKVNENN(FIX1),        '  ',       70.0,' ',  20.0,' ', 1,' &degC'  TO ZEILVIS( 2) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;   
          CONVERT 'Betriebsart             ',ZF_HKPEXT(FIX1),         '       ',   1.0,' ',  -1.0,' ', 0,' %    '  TO ZEILVIS( 6) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
          CONVERT 'Mischer-Betriebsart     ',ZF_HKMIEXT(FIX1),        '       ',   2.0,' ',  -1.0,' ', 0,'      '  TO ZEILVIS(10) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
          CONVERT 'Kalender ZwangsEIN      ',0,                       '       ',   2.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS(11) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        FIN;
        ZEILVIS(20).CHAR(60)='X';    /* Erkennung fuer Rueckuebertragung */
      FIN;
   !  IF FIX1 > 29 AND FIX1 < 56 THEN   /* <<<  Zonen */                   /*   MAX        MIN     NK */
   !    CONVERT 'HK ',FIX1,'                   ',OBJNAME(FIX1)                                                   TO ZEILVIS( 1) BY A,F(2),A,A;     ZEILVIS( 1).CHAR(60)='H';  /* letztes Zeichen H */
   !    CONVERT 'Sollwert Tag            ',TC_HKVNENN(FIX1),        '  ',       30.0,' ',   5.0,' ', 1,' &degC'  TO ZEILVIS( 2) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
   !    CONVERT 'Sollwert Nacht          ',TC_HKVMIN(FIX1),         '  ',       30.0,' ',   4.0,' ', 1,' &degC'  TO ZEILVIS( 3) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
   !    CONVERT 'Tagheizgrenze           ',TC_HMT(FIX1),            '  ',       55.0,' ',  -1.0,' ', 1,' &degC'  TO ZEILVIS( 4) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
   !    CONVERT 'Nachtheizgrenze         ',TC_HMN(FIX1),            '  ',       55.0,' ',  -2.0,' ', 1,' &degC'  TO ZEILVIS( 5) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
   !    CONVERT 'Zone-Betriebsart        ',ZF_HKPEXT(FIX1),         '       ',   1.0,' ',  -1.0,' ', 0,' %    '  TO ZEILVIS( 6) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
   !!   CONVERT '20 &degC                ',FL_SOLLAT20(FIX1),       '  ',      100.0,' ',   0.0,' ', 1,' %    '  TO ZEILVIS( 7) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
   !!   CONVERT '5 &degC                 ',FL_SOLLAT5(FIX1),        '  ',      100.0,' ',   0.0,' ', 1,' %    '  TO ZEILVIS( 8) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
   !!   CONVERT '-10 &degC               ',FL_SOLLATM10(FIX1),      '  ',      100.0,' ',   0.0,' ', 1,' %    '  TO ZEILVIS( 9) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
   !    CONVERT 'Ventil-Betriebsart      ',ZF_HKMIEXT(FIX1),        '       ',   2.0,' ',  -1.0,' ', 0,' %    '  TO ZEILVIS(10) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
   !    CONVERT 'Zone-Wochenkalender     ',0,                       '       ',   2.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS(11) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
   !    ZEILVIS(20).CHAR(60)='X';    /* Erkennung fuer Rueckuebertragung */
   !  FIN;
      CHAR3='   '; /* fertig */
    FIN;

    F15=INSTR(CHAR3,1,3,'KES',1,3);
    IF F15 > 0 THEN                 /* Kessel    */
      FOR I TO 10 REPEAT
        CONVERT ' ','Kessel',I TO OBJNAME(I) BY A,A,F(2);
      END; 
      IF FIX1 > 0 AND FIX1 < 11 THEN  /* 10 Kessel */                       /*   MAX        MIN     NK */
        CONVERT 'KES',FIX1,'                   ',OBJNAME(FIX1)                                                   TO ZEILVIS( 1) BY A,F(2),A;     ZEILVIS( 1).CHAR(60)='H';  /* letztes Zeichen H */
        CONVERT 'Betriebsart             ',ZF_KEINEXT(FIX1),        '       ', 100.0,' ',  -1.0,' ', 0,' %    '  TO ZEILVIS( 2) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Einmalig EINschalten    ',0,                       '       ',   1.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS( 3) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Einmalig AUSschalten    ',0,                       '       ',   1.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS( 4) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Pumpe-Betriebsart       ',ZF_KPMPEXT(FIX1),        '       ', 100.0,' ',   0.0,' ', 0,' %    '  TO ZEILVIS( 5) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        ZEILVIS(20).CHAR(60)='X';
      FIN;
      CHAR3='   '; /* fertig */
    FIN;

    F15=INSTR(CHAR3,1,3,'WWL',1,3);
    IF F15 > 0 THEN                 /* WW-Ladung */
      FOR I TO 10 REPEAT
        OBJNAME(I)=WW_NAME(I);
      END; 
      IF FIX1 > 0 AND FIX1 < 11 THEN  /* 10 WW-Ladungen */                  /*   MAX        MIN     NK */
        CONVERT 'WWL',FIX1,'                   ',OBJNAME(FIX1)                                                   TO ZEILVIS( 1) BY A,F(2),A;     ZEILVIS( 1).CHAR(60)='H';  /* letztes Zeichen H */
        CONVERT 'Sollwert Tag            ',TC_BWSOLL(FIX1),         '  ',       80.0,' ',  20.0,' ', 1,' &degC'  TO ZEILVIS( 2) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Sollwert Nacht          ',TC_BWMIN(FIX1),          '  ',       75.0,' ',  15.0,' ', 1,' &degC'  TO ZEILVIS( 3) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Sollwert Zirk-RL        ',TC_BWZRSOLL(FIX1),       '  ',       75.0,' ',  15.0,' ', 1,' &degC'  TO ZEILVIS( 4) BY A,F(10,4),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Einmalig Desinf. starten',0,                       '       ',   1.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS( 5) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        CONVERT 'Wochenkal. Tag/Nacht    ',0,                       '       ',   2.0,' ',   0.0,' ', 0,'      '  TO ZEILVIS( 6) BY A,F(5),A,F(5,1),A,F(5,1),A,F(1),A;
        ZEILVIS(20).CHAR(60)='X';
      FIN;
      CHAR3='   '; /* fertig */
    FIN;

    STAT=TASKST('GETVISANTWORT');
    IF STAT.BIT(1) THEN /* DORM */
      ACTIVATE GETVISANTWORT;
    FIN;

  ELSE
    PUT CHANTWORT2,' conv ERR' TO A1 BY A,A,SKIP;     /* TESTAUSGABE */
  FIN;

  
  FOR I TO 20 REPEAT
    PUT ZEILVIS(I) TO A1 BY A,SKIP;  /* Testausgabe */
  END;
  PUT TO A1 BY SKIP,SKIP;


END;


CHECKZEIL: TASK PRIO 20;
  DCL CH1  CHAR(1);

  PUT TO A1 BY SKIP;

  PUT 'VIS-Fragezeilen: ' TO A1 BY A,SKIP;

  FOR I TO 20 REPEAT
    PUT 'V',I+69,' ' TO A1 BY A,F(3),A;
    FOR K TO 60 REPEAT
      CH1=ZEILVIS(I).CHAR(K);
      IF TOFIXED(CH1) < 33 THEN
        PUT '-' TO A1 BY A;
      ELSE
        PUT CH1 TO A1 BY A;
      FIN;
    END;
    PUT TO A1 BY SKIP;
  END;

  PUT TO A1 BY SKIP;
  PUT 'VIS-Antwortzeilen: ' TO A1 BY A,SKIP;

  FOR I TO 20 REPEAT
    PUT 'V',I+89,' ' TO A1 BY A,F(3),A;  
    FOR K TO 60 REPEAT
      CH1=ZEILRUECK(I).CHAR(K);
      IF TOFIXED(CH1) < 33 THEN
        PUT '-' TO A1 BY A;
      ELSE
        PUT CH1 TO A1 BY A;
      FIN;
    END;
    PUT TO A1 BY SKIP;
  END;

  PUT TO A1 BY SKIP;
  PUT 'ZEIL46: ' TO A1 BY A,SKIP;

  FOR I TO 18 REPEAT
    PUT 'V',I+15,' ' TO A1 BY A,F(3),A;  
    FOR K TO 46 REPEAT
      CH1=ZEIL(I).CHAR(K);
      IF TOFIXED(CH1) < 0 THEN
        PUT '-' TO A1 BY A;
      ELSE
        PUT CH1 TO A1 BY A;
      FIN;
    END;
    PUT TO A1 BY SKIP;
  END;

  PUT TO A1 BY SKIP;
  PUT 'ZEIL80: ' TO A1 BY A,SKIP;

  FOR I TO 22 REPEAT
    PUT 'V',I+37,' ' TO A1 BY A,F(3),A;  
    FOR K TO 80 REPEAT
      CH1=ZEIL80(I).CHAR(K);
      IF TOFIXED(CH1) < 0 THEN
        PUT '-' TO A1 BY A;
      ELSE
        PUT CH1 TO A1 BY A;
      FIN;
    END;
    PUT TO A1 BY SKIP;
  END;

END;


MODEND;

