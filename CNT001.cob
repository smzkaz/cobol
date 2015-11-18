        IDENTIFICATION  DIVISION.
        PROGRAM-ID.     CNT001.
        DATA            DIVISION.
        WORKING-STORAGE SECTION.
        01 CNT   PIC 9(3) VALUE 0.
        PROCEDURE       DIVISION.
            PERFORM 100 TIMES
                ADD 1 TO CNT
                DISPLAY "COUNT = " CNT
            END-PERFORM
            STOP RUN.
        