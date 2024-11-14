/*********************************************************************/
/*                  Heizungssteuerungsmodul                13.07.22  */
/* STARTWEB: koordiniertes starten von Programm und Webumgebung      */
/* Stand: 13.07.22        BIOGASANLAGE DRALLE  HOHNE                 */
/* spezifische Anpassungen der Module durch "<<<" gekennzeichnet     */
/*********************************************************************/
P=MPC604+FPU(4);

/*SC=2000 ,CODE=$0000 ,VAR=$0000; /**/
  SC=2000;  /* */

MODULE WEB;
/* Compileroptionen einstellen: */;
/*-L Listing PEARL-Compiler     */;
/*-B Big Module                 */;
/*+M Markierung Zeilennummer    */;
/*+T Test auf Feldgrenzen       */;
/*-P Protokoll Hyperproc Code   */;

SYSTEM;
  A12 :     A1. ;
  RTOS:     XC             ->;     /* Bedieninterface                */
  TAST1:    C1 (TFU=1,AI=$3A00) <->;   /* Eingang Ser1 fuer Server       */
  AUTO:     H0.AUTO.EXT (NE) <->; /* AUTO.EX - Datei auf h0.         */


PROBLEM;
  SPC A12                           DATION   OUT ALPHIC CONTROL(ALL);
  SPC RTOS                          DATION   OUT ALPHIC CONTROL(ALL);
  SPC TAST1                         DATION INOUT ALPHIC CONTROL(ALL);
  SPC AUTO                          DATION INOUT ALPHIC CONTROL(ALL);

  SPC CMD_EXW  ENTRY (CHAR(255)) RETURNS (BIT( 1)) GLOBAL; /* Bedieni.*/


LADEN: PROC;
  DCL B1     BIT(1);
  DCL TEXT    CHAR(200);

  TEXT='load AD 200000 HAUPT.psr + MPC.psr + BEDIEN.psr + SONDER.psr + PARAM.psr + VISU.psr + MBUS.psr LO /ed/label';    
! TEXT='load AD 200000 HAUPT.psr + MPC.psr + BEDIEN.psr + SONDER.psr + PARAM.psr + GRUNDFOS.psr + VISU.psr + MBUS.psr + MODBUS.psr + MODBUSSEND.psr LO /ed/label';  /* <<<< */  
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;
  PUT 'Steuerungsprogramm geladen, starte Steuerungsprogramm' TO A12 BY A,SKIP;

END;

STOPWEB: TASK PRIO 10;
  DCL STRING CHAR(1);
  DCL F1     FIXED;

  F1=1;
  WHILE F1 < 60 REPEAT
    F1=F1+1;
    GET STRING  FROM TAST1 BY A(1);         
    IF TOFIXED(STRING)==83 OR TOFIXED(STRING)==115 THEN   /* ABBRUCH MIT "S" ODER "s"  */
      PUT 'TERMINATE WEB' TO RTOS BY A;
      PUT TO A12 BY SKIP;
      PUT 'Start abgebrochen' TO A12 BY A,SKIP;
      F1=100;
    FIN;
    AFTER 0.1 SEC RESUME;
  END;
END;

      
A1RESET: TASK PRIO 10;
  AFTER 3 SEC RESUME;
  FOR I TO 15 REPEAT
    PUT 'CLEAR B1.' TO RTOS;           /* SER1 zuruecksetzen */
    AFTER 0.1 SEC RESUME;
    PUT 'sb a1. 57600' TO RTOS;
    AFTER 1 SEC RESUME;
  END;
END;
        
WEB: TASK PRIO 10;
  DCL CHAR1  CHAR(1);
  DCL B1     BIT(1);
  DCL TEXT    CHAR(120);

  ACTIVATE A1RESET;

  PUT TO A12 BY SKIP;
  PUT 'Los geht es in 5s (fuer Abbruch "s" eingeben)' TO A12 BY A;

  ACTIVATE STOPWEB;

  FOR I TO 5 REPEAT
    AFTER 0.8 SEC RESUME;
    PUT I TO A12 BY F(4);
  END;
  
  TERMINATE STOPWEB;

  PUT TO A12 BY SKIP;

  TEXT='FORM D /RD/C5DS100';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;

  TEXT='FORM D /RD02/C5DS80';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;

! TEXT='COPY /h0/WEB/HOSTS > /r0/HOSTS';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
!
! PUT 'NETIO.NETIO -I=192.168.2.20 -M=255.255.255.0 -G=192.168.2.1' TO RTOS BY A,SKIP;     
! PUT 'TEL_SERVER -t=20' TO RTOS BY A,SKIP;     
! PUT 'SET_GW_ADDR -N=0.0.0.0 -G=192.168.2.1' TO RTOS BY A,SKIP;     


  PUT TO A12 BY SKIP;
  PUT 'lade Steuerungsprogramm' TO A12 BY A,SKIP;
  TEXT='cd FD.';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;
  TEXT='cd PRG';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;

  CALL LADEN;

  PUT 'START' TO RTOS BY A,SKIP;     

  AFTER 0.2 SEC RESUME;
  PUT 'INET' TO RTOS BY A,SKIP;     


END;



INET: TASK PRIO 10;
  DCL CHAR1  CHAR(1);
  DCL B1     BIT(1);
  DCL TEXT    CHAR(120);



! TEXT='mkdir /RD/HTML';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
! TEXT='mkdir /RD/HTTP';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
  TEXT='LOAD /FD/WEB/HTTPSERV.SR';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;
  TEXT='LOAD /FD/WEB/HTTP_INI.SR';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;
  TEXT='LOADX /FD/WEB/JSONADD.SR';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;
! TEXT='COPY /FD/WEB/HTTPSERV.INI > /RD/HTTP/HTTPSERV.INI';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
! TEXT='COPY /FD/WEB/HTTP400.HTM > /RD/HTML/HTTP400.HTM';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
! TEXT='COPY /FD/WEB/HTTP404.HTM > /RD/HTML/HTTP404.HTM';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
! TEXT='COPY /FD/WEB/index.html > /RD/HTML/index.html';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
! TEXT='COPY /FD/WEB/EK.JS > /RD/HTML/EK.JS';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
! TEXT='COPY /FD/WEB/main.css > /RD/HTML/main.css';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
! TEXT='COPY /FD/WEB/HTTP.TXT > /RD/HTTP/HTTP.TXT';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
! TEXT='ENVSET -G HTTPDIR=/RD/HTML';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
! TEXT='ENVSET -G HTTPINIDIR=/RD/HTTP';     
! B1=CMD_EXW(TEXT);                
! PUT B1 TO A12 BY B(1),SKIP;
  
  PUT 'HTTP_Demon' TO RTOS BY A,SKIP;     

END;


MAKEAUTO: TASK PRIO 10;

  OPEN AUTO BY IDF('AUTO.EX'),ANY;
  CALL REWIND(AUTO);

  PUT 'NETIO.NETIO -I=172.16.0.102 -M=255.255.255.0 -G=172.16.0.254' TO AUTO BY A,SKIP;
  PUT 'TEL_SERVER -t=20' TO AUTO BY A,SKIP;
  PUT 'SET_GW_ADDR -N=0.0.0.0 -G=172.16.0.254' TO AUTO BY A,SKIP;
  PUT 'FTPSRV PRIO 50 -p=/H0/PASSWD -o=1' TO AUTO BY A,SKIP;
  PUT 'LOAD /FD/PRG/STARTWEB.psr -- WEB' TO AUTO BY A,SKIP;
  PUT 'ENVSET -G HTTPDIR=/FD/WEB' TO AUTO BY A,SKIP;
  PUT 'ENVSET -G HTTPINIDIR=/FD/WEB' TO AUTO BY A,SKIP;
  PUT 'SD /TY/ 33' TO AUTO BY A,SKIP;

  CLOSE AUTO;  
  PUT 'sync h0.' TO RTOS BY A,SKIP;

END;  


ALONE: TASK PRIO 10;
  DCL CHAR1  CHAR(1);
  DCL B1     BIT(1);
  DCL TEXT    CHAR(120);

  PUT TO A12 BY SKIP;

  TEXT='FORM D /RD/C5DS100';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;

  TEXT='FORM D /RD02/C5DS80';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;

  PUT TO A12 BY SKIP;
  PUT 'lade Steuerungsprogramm' TO A12 BY A,SKIP;
  TEXT='cd FD.';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;
  TEXT='cd PRG';     
  B1=CMD_EXW(TEXT);                
  PUT B1 TO A12 BY B(1),SKIP;

  CALL LADEN;

  PUT 'START' TO RTOS BY A,SKIP;     

END;


REST: TASK PRIO 254;
  DCL ZP3 CLOCK;
  DCL ZP4 CLOCK;
  DCL F31 FIXED(31);
  DCL FL  FLOAT;
  DCL BLOOP BIT(1);
  DCL NEWDAT  CHAR(128); 

  NEWDAT='/TY';
  OPEN A12 BY IDF(NEWDAT);

  FOR I TO 1000 REPEAT
    F31=0(31);
    BLOOP='1'B;
    ZP3=NOW;
    WHILE BLOOP REPEAT
      F31=F31+1(31);
      ZP4=NOW;
      IF ZP4-ZP3 > 0 HRS 00 MIN 01.000 SEC THEN
        BLOOP='0'B;
      FIN;
    END;
    FL=F31/7847.0;
    PUT I,FL,'%' TO A12 BY F(4),F(6,1),A,SKIP; 
  END;

END;

   

/*+L*/                                           

MODEND;
