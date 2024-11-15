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

  REPEAT
    /* Ausgabe Parameter JW */
    IF ZVISUAL==2 OR ZVISUAL==120 THEN
      IF ZVISUAL==120 THEN  ZVISUAL=20;  FIN;  /* alle ca. 160s  */
      OPEN TEMP BY IDF('TEMP'),ANY;
      CALL REWIND(TEMP);
    
      PUT '{' TO TEMP BY A;						/* start JSON-Object*/	  
	  PUT 'prjNo:',NR_PRJ TO TEMP BY A,F(4);
      PUT ',prjName:',IDPI TO TEMP BY A,A;
	  
      PUT ',date:"',DA_DAT,'.',DA_MON,'.',DA_JAH,' ',ZP_NOW,'"' TO TEMP BY A,F(2),A,F(2),A,F(4),A,T(8),A;
    
      PUT ',AI:' TO TEMP BY A;
	  PUT '{' TO TEMP BY A;						/* start JSON-Object*/
      FOR I TO N_FUEHLER REPEAT
		PUT 'no:', I TO TEMP BY A,F(3);
		PUT ',name:', FP_NAME(I) TO TEMP BY A,A;
		PUT ',uMin:',FP_ULOW(I) TO TEMP BY A,F(6);
		IF FP_TYP(I)/=3 AND FP_TYP(I)/=12 AND FP_TYP(I)/=15 THEN
		PUT ',uMax:',FP_UHIGH(I) TO TEMP BY A,F(6);
        FIN;
		PUT ',min:',FL_XAEINMIN(I) TO TEMP BY A,F(6,1);
		PUT ',max:',FL_XAEINMAX(I) TO TEMP BY A,F(6,1);
		PUT ',rangeCheck:',B_FUEHLWACH(I) TO TEMP BY A,B(1);
		PUT '}' TO TEMP BY A;						/* end JSON-Object*/
      END;
	  
	  PUT ',AO:' TO TEMP BY A;
	  PUT '{' TO TEMP BY A;						/* start JSON-Object*/
      FOR I TO N_ANALOG REPEAT
		PUT 'no:', I TO TEMP BY A,F(3);
		PUT ',name:', AP_NAME(I) TO TEMP BY A,A;
		PUT ',uMin:',AP_ULOW(I) TO TEMP BY A,F(6,2);
		PUT ',uMax:',AP_UHIGH(I) TO TEMP BY A,F(6,2);
		PUT ',betriebsart:',Z_AAUTO(I) TO TEMP BY A,F(1); /*auto, hand, hand(nurWert)*/
		PUT ',handwert:',X_AHAND(I) TO TEMP BY A,F(6,1);
		PUT ',min:',X_AAUSMIN(I) TO TEMP BY A,F(6,1);
		PUT ',max:',X_AAUSMAX(I) TO TEMP BY A,F(6,1);
		PUT '}' TO TEMP BY A;						/* end JSON-Object*/
      END;
	  
	  PUT ',DO:' TO TEMP BY A;
	  PUT '{' TO TEMP BY A;						/* start JSON-Object*/
      FOR I TO N_RELPLT*8 REPEAT
		PUT 'no:', I TO TEMP BY A,F(3);
		PUT ',name:', DO_NAME(I) TO TEMP BY A,A;
		PUT ',betriebsart:',Z_DOHAND(I) TO TEMP BY A,F(6); /*0=auto, >0=ein, <0=aus*/
		PUT '}' TO TEMP BY A;						/* end JSON-Object*/
      END;
	  
	  PUT ',DI:' TO TEMP BY A;
	  PUT '{' TO TEMP BY A;						/* start JSON-Object*/
      FOR I TO N_DIGIN REPEAT
		PUT 'no:', I TO TEMP BY A,F(3);
		PUT ',name:', DI_NAME(I) TO TEMP BY A,A;
		PUT ',betriebsart:',Z_DIBEWERT(I) TO TEMP BY A,F(1); /*norm, toggle, eins, null*/
		PUT '}' TO TEMP BY A;						/* end JSON-Object*/
      END;	
	  
      FOR I TO N_KESSEL REPEAT
        PUT 'Kessel',I,':' TO TEMP BY A,F(2),A;
		    PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        
        PUT 'Leistung(kW):',PT_KES(I) TO TEMP BY A,F(5);
        PUT ',Pumpennachlauf(s):',ZF_KPNL(I) TO TEMP BY A,F(5);
        PUT ',Anf. Zeit bis P-Reg(s):',ZF_KWARML(I) TO TEMP BY A,F(5);
        PUT ',Max VL-Temp (>+4K AUS):',TC_KVMAX(I) TO TEMP BY A,F(5,1);
        PUT ',Max Spreizung(K):',TD_KMAX(I) TO TEMP BY A,F(5,1);
        PUT ',Ueberh. VL-Soll(K):',TD_KVLPLUS(I) TO TEMP BY A,F(5,1);
        PUT ',MindestAA Betrieb(%):',X_AAKMIN(I) TO TEMP BY A,F(5,1);
        PUT ',Stellzeit P-Reg(s):',ZF_KSTELL(I) TO TEMP BY A,F(5);
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

        PUT ',allgemeineKesselparameter:' TO TEMP BY A;
        PUT '{' TO TEMP BY A;						/* start JSON-Object*/
        PUT 'autoKesselrangfolge:',B_FSLKESAUTO TO TEMP BY A,B(1);
        PUT ',KesseltoleranzHauptkreis:',TD_KS TO TEMP BY A,F(5,1);
        PUT ',PumpenvorlaufAktiv:',B_PMPVORL TO TEMP BY A,B(1);
        PUT '}' TO TEMP BY A;						/* end JSON-Object*/
      END;
    
      FOR I TO N_BHKW REPEAT
        PUT 'BHKW',I,':' TO TEMP BY A,F(2),A;
        PUT 'Pel Max(kW):             ',PE_MAXBHKW(I) TO TEMP BY A,F(5,1);
        PUT 'Pel Min(kW):             ',PE_MINBHKW(I) TO TEMP BY A,F(5,1);
        PUT 'erl. Pel-Soll(%) 100 -   ',PE_BMINPRO(I) TO TEMP BY A,F(5,1);
        PUT 'Thermostat VL:           ',TC_BHZGVO(I) TO TEMP BY A,F(5,1);
        PUT 'Thermostat RL:           ',TC_BHZGRO(I) TO TEMP BY A,F(5,1);
        PUT 'Mindest VL-Soll:         ',TC_BVLMIN(I) TO TEMP BY A,F(5,1);
        PUT 'Pumpennachlauf(s):       ',ZF_BPNL(I) TO TEMP BY A,F(5);
        PUT 'Freigabe? :              ' TO TEMP BY A;
        IF B_BERLAUBT(I) THEN
          PUT '   JA  ' TO TEMP BY A;
        ELSE
          PUT '  NEIN ' TO TEMP BY A;
        FIN;
        PUT TO TEMP BY SKIP;
      END;
    
      PUT ' Warn. bei Starts > (in 24h):    ',ZF_STARTMAX TO TEMP BY A,F(5);
      PUT ' BHKW1 Einschaltverz. in MIN:    ',ZF_T1EIN TO TEMP BY A,F(5);
      PUT ' BHKW1 Einschalttemp. Differ.:   ',TD_1EIN TO TEMP BY A,F(5);
      PUT ' Min TCMAX (WW ueberladen,...):  ',TC_MAXMIN TO TEMP BY A,F(5,1);
      PUT ' Minimal beachteter Strombedarf: ',PE_RMIN1B TO TEMP BY A,F(5,1);
      PUT TO TEMP BY SKIP;
    
      PUT TO TEMP BY SKIP;
      FOR I TO N_HZKR REPEAT
        PUT 'HK',I,': ',HK_NAME(I) TO TEMP BY A,F(2),A,A;
        PUT 'Nennvorlauf:   ',TC_HKVNENN(I),' Mindestvorl.:  ',TC_HKVMIN(I)  TO TEMP BY A,F(4),A,F(4);
        PUT 'Tagheizgrenze: ',TC_HMT(I),    ' Nachtheizgr.: ',TC_HMN(I)      TO TEMP BY A,F(4,1),A,F(5,1);
        PUT 'Nennraumtemp.: ',TC_HKINENN(I),' Nennaussen:   ',TC_HKANENN(I)  TO TEMP BY A,F(4,1),A,F(5,1);
        PUT 'Exponent:      ',FL_EXPHK(I),  ' Absenkung um:  ',TD_ABSHK(I)   TO TEMP BY A,F(4,1),A,F(4,1);
        PUT 'STW HK VL:     ',TC_HKSTW(I)                                    TO TEMP BY A,F(4);
        PUT 'Stellzeit Mischer(s):    ',ZF_HKMISTELL(I) TO TEMP BY A,F(5);
        PUT 'Langfr. Integrator MAX:  ',TD_HKINTMAX(I) TO TEMP BY A,F(5,1);
        PUT 'Langfr. Integrator MIN:  ',TD_HKINTMIN(I) TO TEMP BY A,F(5,1);
        PUT ' Vorlaufregelung  ' TO TEMP BY A;
        PUT '      P    I         D    TauD(s)' TO TEMP BY A;
        PUT RP_M(I),RI_M(I),RD_M(I),RTAU_M(I) TO TEMP BY F(8,1),F(8,4),F(8,1),F(8,1);
        IF I==99 THEN
          PUT '   Solldruck in mWS bei              ' TO TEMP BY A;
          PUT	'   AT=20      AT=5       AT=-10 ' TO TEMP BY A;
          PUT	FL_SOLLAT20(I),FL_SOLLAT5(I),FL_SOLLATM10(I)	TO TEMP BY F(8,1),F(10,1),F(12,1);
        ELSE
          PUT '   Sollwert in %                     ' TO TEMP BY A;
          PUT	'   AT=20      AT=5       AT=-10 ' TO TEMP BY A;
          PUT	FL_SOLLAT20(I),FL_SOLLAT5(I),FL_SOLLATM10(I)	TO TEMP BY F(8,1),F(10,1),F(12,1);
        FIN;
        PUT TO TEMP BY SKIP;
      END;
    
      PUT TO TEMP BY SKIP;
      FOR I TO N_SPEI REPEAT
        PUT 'WW',I,': ',WW_NAME(I) TO TEMP BY A,F(2),A,A;
        PUT 'Sollwert (Tag):',TC_BWSOLL(I),' Min-W. (Nacht):',TC_BWMIN(I)    TO TEMP BY A,F(4),A,F(4);
        PUT 'Soll Desinf.:  ',TC_LEGIO(I), ' Zirk-RL-Soll:  ',TC_BWZRSOLL(I) TO TEMP BY A,F(4),A,F(4);
        PUT 'Abw.-Norm:     ',TD_BWNORM(I),' Abw.-Dring:    ',TD_BWDRIG(I)   TO TEMP BY A,F(4,1),A,F(4,1);
        PUT 'Max-Wert (Waermeuebersch.):    ',TC_BOMAX(I)                       TO TEMP BY A,F(4,1);
        PUT 'Mehranf. Hauptkr. bei Ladung:  ',TD_BWLS(I)                        TO TEMP BY A,F(4,1);
        PUT 'Start Lad bei Hauptk > Spei +  ',TD_BWTOO(I)                       TO TEMP BY A,F(4,1);
        PUT 'Stop  Lad bei Hauptk < Spei +  ',TD_BWTOU(I)                       TO TEMP BY A,F(4,1);
        PUT 'Max gewuenschte Lade-RL:       ',TC_BWRSOLL(I)                     TO TEMP BY A,F(4,1);
        PUT 'Ueberhoeh. Speise VL:          ',TD_BWTW(I)                        TO TEMP BY A,F(4,1);
        PUT '   WW-Laderegelung (AussenWT) ' TO TEMP BY A;
        PUT '    P(I)     D    ' TO TEMP BY A;
        PUT RP_BWL(I),RD_BWL(I) TO TEMP BY F(8,2),F(8,2);
        PUT '   WW-Laderegelung (FWS) ' TO TEMP BY A;
        PUT '      P     I         D    TauD(s)' TO TEMP BY A;
        PUT RP_WWL(I),RI_WWL(I),RD_WWL(I),RTAU_WWL(I) TO TEMP BY F(8,1),F(8,3),F(8,1),F(8,1);
        PUT '   WW-Zirk-RL-Regelung  ' TO TEMP BY A;
        PUT '      P     I         D    TauD(s)' TO TEMP BY A;
        PUT RP_WWZ(I),RI_WWZ(I),RD_WWZ(I),RTAU_WWZ(I) TO TEMP BY F(8,1),F(8,4),F(8,1),F(8,1);
        PUT TO TEMP BY SKIP;
      END;
    
      PUT TO TEMP BY SKIP;
      PUT 'Genibuspumpen:  ' TO TEMP BY A;
      PUT ' Nr Name                 Kennl-Typ     Betrieb Handw.  ST(0,4%) ST(0,8%) ST(99,6%) ST(100%)' TO TEMP BY A;
      FOR I TO N_UPE REPEAT
        PUT I,' ',UPE_NAME(I) TO TEMP BY F(3),A,A;
        CASE UPE_SOLLKOMM(I)+1
          ALT /*  0 */ PUT ' Konst. Druck  ' TO TEMP BY A;
          ALT /*  1 */ PUT ' Prop. Druck   ' TO TEMP BY A;
          ALT /*  2 */ PUT ' Konst. Kennl. ' TO TEMP BY A;
          ALT /*  3 */ PUT ' Konst. Leist. ' TO TEMP BY A;
          OUT          PUT '               ' TO TEMP BY A;
        FIN;
        IF B_UPEHAND(I) THEN
          PUT 'HAND   ' TO TEMP BY A;
        ELSE  
          PUT 'AUTO   ' TO TEMP BY A;
        FIN;
        PUT Z_UPESOLLHAND(I) TO TEMP BY F(4);
        PUT UPE_KENN(I,1) TO TEMP BY F(9);
        PUT UPE_KENN(I,2) TO TEMP BY F(9);
        PUT UPE_KENN(I,3) TO TEMP BY F(9);
        PUT UPE_KENN(I,4) TO TEMP BY F(9);
        PUT TO TEMP BY SKIP;
      END;
    
      PUT TO TEMP BY SKIP;
      PUT 'Impulszaehler:  ' TO TEMP BY A;
      PUT ' Nr Name                       Imp./Einh.   ' TO TEMP BY A;
      FOR I TO N_ZAEHLER REPEAT
        PUT I,' ',ZP_NAME(I) TO TEMP BY F(3),A,A;
        PUT FL_IMP(ZP_EIN(I)) TO TEMP BY F(8,3);
        PUT TO TEMP BY SKIP;
      END;
    
      PUT TO TEMP BY SKIP;
      PUT 'Unterer Heizwert Gas: ',FL_GASHU TO TEMP BY A,F(5,2);
    
      PUT TO TEMP BY SKIP;
      PUT 'Gassensorstoerschwelle(V) :',FL_GASSTOER TO TEMP BY A,F(7,2);
      PUT 'Gassensorwarnschwelle (V) :',FL_GASWARN  TO TEMP BY A,F(7,2); 
    
      PUT TO TEMP BY SKIP;
      PUT 'HZG-Druck-MIN-Warnschwelle (bar): ',FL_DRWARN TO TEMP BY A,F(5,2);
      PUT 'HZG-Druck-MAX-Warnschwelle (bar): ',FL_DRMAX  TO TEMP BY A,F(5,2); 
    
      PUT TO TEMP BY SKIP;
      PUT 'Ueberheizung Hauptkreis (K): ',TD_UEBERHEIZ TO TEMP BY A,F(5,1);
    
      PUT TO TEMP BY SKIP;
      PUT 'Hauptnutzungsdauer Heizung: ',ZP_SCHANF,' - ',ZP_SCHEND TO TEMP BY A,T(8),A,T(8);
    
      PUT TOCHAR(27),TOCHAR(27),'D4' TO TEMP BY A,A,A;

      CLOSE TEMP;  
      F15=SETPRI(1);
      PUT 'ER NIL.;rm /RD02/prot.txt' TO RTOS BY A;
      PUT 'ER NIL.;RENAME /RD02/TEMP > prot.txt' TO RTOS BY A;
      F15=SETPRI(30);

    FIN; /* Ende Protokoll */



 !  ZP2=NOW;
 !  PUT ZP1,ZP2,ZP2-ZP1 TO A1 BY T(18,3),T(18,3),D(27,3);

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
      PUT 'GETVIS:',AS TO A1 BY A,F(4);
    FIN;
    IF AS > 0 THEN
      AFTER 0.4 SEC RESUME;
      IF AS==88 THEN                             /* X    */

    !   FOR I TO 20 REPEAT
    !     PUT ZEILRUECK(I) TO A1 BY A;  /* Testausgabe */
    !   END;
        PUT TO A1 BY SKIP;
        PUT 'VIS-Fragezeilen: ' TO A1 BY A;
      
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
        PUT 'VIS-Antwortzeilen: ' TO A1 BY A;
      
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
                PUT FL1 TO A1 BY F(10,4);
                IF FL1 > 10.0 AND FL1 < 100.0 THEN
                  TC_HKVNENN(FIX1)=FL1;               /* NennVL       */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 3) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4);
                IF FL1 > 10.0 AND FL1 < 100.0 THEN
                  TC_HKVMIN(FIX1)=FL1;                /* MindestVL    */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 4) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4);
                IF FL1 > -2.1 AND FL1 < 100.0 THEN
                  TC_HMT(FIX1)=FL1;                   /* Tagheizgrenze */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 5) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4);
                IF FL1 > -2.1 AND FL1 < 100.0 THEN
                  TC_HMN(FIX1)=FL1;                   /* Nachtheizgr  */
                FIN;
              FIN;
              FL1=0.0;

              F152=0;
              CONVERT CHAR24,F15 FROM ZEILRUECK( 6) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT F15 TO A1 BY F(5);
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
                PUT FL1 TO A1 BY F(10,4);
                IF FL1 > -0.1 AND FL1 < 100.1 THEN
                  FL_SOLLAT20(FIX1)=FL1;              /* AT=20        */
                FIN;                                  
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 8) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4);
                IF FL1 > -0.1 AND FL1 < 100.1 THEN
                  FL_SOLLAT5(FIX1)=FL1;               /* AT=5         */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,FL1 FROM ZEILRUECK( 9) BY RST(conv_error), A(24), RST(conv_error2), F(10,4);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT FL1 TO A1 BY F(10,4);
                IF FL1 > -0.1 AND FL1 < 100.1 THEN
                  FL_SOLLATM10(FIX1)=FL1;             /* AT= -10      */
                FIN;
              FIN;
              FL1=0.0;

              CONVERT CHAR24,F15 FROM ZEILRUECK(10) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT F15 TO A1 BY F(5);
                IF F15 > -2 AND F15 < 101 THEN
                  ZF_HKMIEXT(FIX1)=F15;               /* Mischer      */
                FIN;
              FIN;
              F15=0;

         !    IF F152 < 10 THEN  /* Betriebsart wurde noch nicht geaendert */
         !      CONVERT CHAR24,F15 FROM ZEILRUECK(11) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
         !      IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
         !        PUT F15 TO A1 BY F(5);
         !        IF F15 > -2 AND F15 < 101 THEN
         !          ZF_HKPEXT(FIX1)=F15;                /* Betriebsart Pumpe */
         !        FIN;
         !      FIN;
         !    FIN;
         !    F15=0;

              CONVERT CHAR24,F15 FROM ZEILRUECK(11) BY RST(conv_error), A(24), RST(conv_error2), F(5);  
              IF conv_error==0 AND conv_error2==0 AND CHAR24 /= '     ' THEN
                PUT F15 TO A1 BY F(5);
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

    PUT CHANTWORT2,'  conv OK' TO A1 BY A,A;     /* TESTAUSGABE */
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
    PUT CHANTWORT2,' conv ERR' TO A1 BY A,A;     /* TESTAUSGABE */
  FIN;

  
  FOR I TO 20 REPEAT
    PUT ZEILVIS(I) TO A1 BY A;  /* Testausgabe */
  END;
  PUT TO A1 BY SKIP;


END;


CHECKZEIL: TASK PRIO 20;
  DCL CH1  CHAR(1);

  PUT TO A1 BY SKIP;

  PUT 'VIS-Fragezeilen: ' TO A1 BY A;

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
  PUT 'VIS-Antwortzeilen: ' TO A1 BY A;

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
  PUT 'ZEIL46: ' TO A1 BY A;

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
  PUT 'ZEIL80: ' TO A1 BY A;

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

