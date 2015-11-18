        IDENTIFICATION DIVISION.
        PROGRAM-ID.    SAMPLE.
        AUTHOR. Fujishinko.
        ENVIRONMENT DIVISION.
        DATA DIVISION.
        WORKING-STORAGE SECTION.
        77 CMD PIC 9.
        PROCEDURE DIVISION.
        PG-TOP.
        PERFORM 1000 TIMES
                DISPLAY "Hello World"
        END-PERFORM
        STOP RUN.
