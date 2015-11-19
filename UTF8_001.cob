        IDENTIFICATION             DIVISION.
        PROGRAM-ID.                UTF8_001.
        ENVIRONMENT                DIVISION.
        INPUT-OUTPUT               SECTION.
        FILE-CONTROL.
             SELECT  F1  ASSIGN  TO  "UTF8_001.cob"  STATUS  FST.
        DATA                       DIVISION.
        FILE                       SECTION.
        FD  F1.
        01  バッファ             PIC X(72).
        WORKING-STORAGE            SECTION.
        01  FST                    PIC X(02).
        77  CNT                    PIC 9(02) VALUE 0.
        PROCEDURE                  DIVISION.
          PERFORM 10 TIMES
              COMPUTE CNT = CNT + 1
              DISPLAY "[" CNT "]" "ようこそ、opensource COBOLへ"
          END-PERFORM.
          STOP RUN.
        END PROGRAM UTF8_001.

