VISUAL: PROC; ! Visualisierungsdaten   Biogas dralle Hohne  

  DCL FL1             FLOAT;
  DCL FL2             FLOAT;
  DCL FL3             FLOAT;

  /* Einheiten: */
  /* 1: °C  */
  /* 2: bar  */
  /* 3: V    */
  /* 4: kW   */
  /* 5: m^3/h*/
  /* 6: mWS  */
  /* 7: %    */
  /* 8: kWh  */
  /* 9: Bh   */
  /*10: m^3 */
  /*11: °Cø */
  /*12: mV  */
  /*13: UPM */
  /*14: s   */
  /*15: mbar*/
  /*16: A   */
  /*17: Hz  */
  /*18: l/h */
  /*19: l   */
  /*40: keine Einheit */

    PUT TOCHAR(27),TOCHAR(27),'V' TO TEMP;
  
    PUT 'HK  1, CLICK',ZEXT(1) TO TEMP BY A,F(1);  /* Button fuer: HK1 Nordtrasse    */
    PUT 'HK  2, CLICK',ZEXT(2) TO TEMP BY A,F(1);  /* Button fuer: HK2 Westtrasse    */
    PUT 'HK  3, CLICK',ZEXT(3) TO TEMP BY A,F(1);  /* Button fuer: HK3 Suedtrasse    */
    PUT 'HK  4, CLICK',ZEXT(4) TO TEMP BY A,F(1);  /* Button fuer: Trocknung         */

    PUT 'KES 1, CLICK',ZEXT(1) TO TEMP BY A,F(1);  /* Button fuer: Holzkessel1  */
    PUT 'KES 2, CLICK',ZEXT(2) TO TEMP BY A,F(1);  /* Button fuer: Holzkessel2  */
    PUT 'KES 3, CLICK',ZEXT(3) TO TEMP BY A,F(1);  /* Button fuer: Biogaskessel */


    PUT 'HKNA 1',HK_NAME( 1) TO TEMP BY A,A;   /* Text, Name HK1  */
    PUT 'HKNA 2',HK_NAME( 2) TO TEMP BY A,A;   /* Text, Name HK2  */
    PUT 'HKNA 3',HK_NAME( 3) TO TEMP BY A,A;   /* Text, Name HK3  */
   
    PUT 'PMK 1,0, 4',PT_KES( 1) TO TEMP BY A,F(7,2);       /* Maximalleistung Holzkessel1   */
    PUT 'PMK 2,0, 4',PT_KES( 2) TO TEMP BY A,F(7,2);       /* Maximalleistung Holzkessel2   */
    PUT 'PMK 3,0, 4',PT_KES( 3) TO TEMP BY A,F(7,2);       /* Maximalleistung Biogaskessel  */
    PUT 'PMB 1,0, 4',PE_MAXBHKW( 1) TO TEMP BY A,F(7,2);   /* Maximalleistung BHKW     */

    /* anstehende Störungen  */
    FOR I TO 120 REPEAT
      IF B_STOER(I) AND ZF_STOERFREI(I) < 2 THEN
        PUT 'STOE',I,TX_STOERMEL(I) TO TEMP BY A,F(3),A;
      FIN;
    END;
  
    /* relevante Analogeingänge */
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

    PUT 'TH  1,1, 1',TC_VIST    TO TEMP BY A,F(7,2); /* Hauptkreis VL IST */ 
    PUT 'TH  2,1, 1',TC_VSOLL   TO TEMP BY A,F(7,2); /* Hauptkreis VL SOLL */
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
     /* relevante Durchflüsse */
    PUT 'DF  1,1, 5',DF_MBUS( 1)  TO TEMP BY A,F(7,2); /* Durchfluss BHKW             */
    PUT 'DF  2,1, 5',DF_MBUS( 2)  TO TEMP BY A,F(7,2); /* Durchfluss Holzkessel1      */
    PUT 'DF  3,1, 5',DF_MBUS( 3)  TO TEMP BY A,F(7,2); /* Durchfluss Holzkessel2      */      
    PUT 'DF  4,1, 5',DF_MBUS( 4)  TO TEMP BY A,F(7,2); /* Durchfluss Biogaskessel     */      
    PUT 'DF  5,1, 5',DF_MBUS( 5)  TO TEMP BY A,F(7,2); /* Durchfluss HK1 Nordtrasse   */      
    PUT 'DF  6,1, 5',DF_MBUS( 6)  TO TEMP BY A,F(7,2); /* Durchfluss HK2 Westtrasse   */    
    PUT 'DF  7,1, 5',DF_MBUS( 7)  TO TEMP BY A,F(7,2); /* Durchfluss HK3 Suedtrasse   */    
    /* relevante P_DI-Leistungen */
    PUT 'PBH 1,1, 4',PE_BIST(1) TO TEMP BY A,F(7,2);       /* el. Istleistung BHKW (ca.) */
    /* relevante Analogausgänge */
    PUT 'AA  1,1, 7',X_AAUS(1)           TO TEMP BY A,F(7,2);    /* Soll Pumpe Biogaskessel <<< */    
    PUT 'AA  2,1, 7',X_AAUS(2)           TO TEMP BY A,F(7,2);    /* Soll Pumpe Holzkessel1   */    
    PUT 'AA  4,1, 7',X_AAUS(4)           TO TEMP BY A,F(7,2);    /* Soll Pumpe Holzkessel2   */   
    PUT 'AA  5,1, 7',X_AAUS(5)           TO TEMP BY A,F(7,2);    /* Soll Ventilator Trocknung */  
    PUT 'AA  6,1, 7',X_AAUS(6)           TO TEMP BY A,F(7,2);    /* Soll Pumpe HK1 Nordtrasse <<< */  
    PUT 'AA  7,1, 7',X_AAUS(7)           TO TEMP BY A,F(7,2);    /* Soll Pumpe HK2 Westtrasse <<< */  
    PUT 'AA  8,1, 7',X_AAUS(8)           TO TEMP BY A,F(7,2);    /* Soll Pumpe HK3 Suedtrasse <<< */  

    /* relevante Mischerstellungen */
    PUT 'MS  1,1, 7',Z_HKMISTELL( 1)/ZF_HKMISTELL( 1)*100 TO TEMP BY A,F(7,2); /* Mi HK1 Nordtrasse     */
    PUT 'MS  2,1, 7',Z_HKMISTELL( 2)/ZF_HKMISTELL( 2)*100 TO TEMP BY A,F(7,2); /* Mi HK2 Westtrasse     */
    PUT 'MS  3,1, 7',Z_HKMISTELL( 3)/ZF_HKMISTELL( 3)*100 TO TEMP BY A,F(7,2); /* Mi HK3 Suedtrasse     */   
    PUT 'MS  4,1, 7',Z_HKMISTELL( 4)/ZF_HKMISTELL( 4)*100 TO TEMP BY A,F(7,2); /* Motorventil Trocknung */ 
    PUT 'MS 11,1, 7',Z_KMISTELL( 1)                       TO TEMP BY A,F(7,2); /* RL-Mischer Holzkessel1 */
    PUT 'MS 12,1, 7',Z_KMISTELL( 2)                       TO TEMP BY A,F(7,2); /* RL-Mischer Holzkessel2 */ 
    PUT 'MS 13,1, 7',Z_KMISTELL( 3)                       TO TEMP BY A,F(7,2); /* RL-Mischer Biogaskessel */
  
    /* relevante Digitaldaten  <<< evtl. bei Digitalausgängen Handeinstellungen berücksichtigen ? */
    PUT 'PH  1,0, 0',B_DO(15)  TO TEMP BY A,B(1);  /* Pumpe HK1 Nordtrasse  */
    PUT 'PH  2,0, 0',B_DO(18)  TO TEMP BY A,B(1);  /* Pumpe HK2 Westtrasse  */
    PUT 'PH  3,0, 0',B_DO(21)  TO TEMP BY A,B(1);  /* Pumpe HK3 Suedtrasse  */
    PUT 'PH 11,0, 0',B_DO(25)  TO TEMP BY A,B(1);  /* Ventilator Trocknung  */
    PUT 'PH 12,0, 0',B_DO(24)  TO TEMP BY A,B(1);  /* Freigabe Gasfackel    */   
  
    PUT 'KPU 1,0, 0',B_DO( 2)  TO TEMP BY A,B(1);  /* Pumpe Holzkessel1  */
    PUT 'KPU 2,0, 0',B_DO( 5)  TO TEMP BY A,B(1);  /* Pumpe Holzkessel2  */    
    PUT 'KPU 3,0, 0',B_DO(12)  TO TEMP BY A,B(1);  /* Pumpe Biogaskessel */    
    PUT 'KL  1,0, 0',B_KL(1)   TO TEMP BY A,B(1);  /* Holzkessel1 Betrieb */
    PUT 'KL  2,0, 0',B_KL(2)   TO TEMP BY A,B(1);  /* Holzkessel2 Betrieb */      
    PUT 'KL  3,0, 0',B_KL(3)   TO TEMP BY A,B(1);  /* Biogaskessel Betrieb */      
    PUT 'BPU 1,0, 0',B_BPMP(1) TO TEMP BY A,B(1);  /* Pumpe BHKW (grau) */
    PUT 'BL  1,0, 0',B_BL(1)   TO TEMP BY A,B(1);  /* BHKW Betrieb  */


    PUT 'SG  1,0, 0',B_SAMMELST   TO TEMP BY A,B(1);  /* Sammelstoerung */
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
  
    PUT 'GR  1,2, 2',FL_DRWARN    TO TEMP BY A,F(7,2); /* Warngrenze HZG-Druck MIN */
    PUT TOCHAR(27),TOCHAR(27),'v' TO TEMP;



END; ! of VISUAL: PROC

