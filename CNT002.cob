        IDENTIFICATION          DIVISION.
        PROGRAM-ID.             CNT002.
        DATA                    DIVISION.
        WORKING-STORAGE         SECTION.
        01 CNT  PIC 9(5) VALUE 0.
        01 WTIME.                 *>作業用
           03 HH        PIC 9(2).
           03 MM        PIC 9(2).
           03 SS        PIC 9(2).
        01 STIME        PIC 9(6) VALUE 0.
        01 ETIME        PIC 9(6) VALUE 0.
        01 XTIME        PIC 9(6) VALUE 0.
        PROCEDURE               DIVISION.
           ACCEPT WTIME FROM TIME
           COMPUTE STIME = (HH * 3600) + (MM * 60) + SS
           PERFORM UNTIL CNT = 10000
               ADD 1 TO CNT DISPLAY CNT
           END-PERFORM
           ACCEPT WTIME FROM TIME
           COMPUTE ETIME = (HH * 3600) + (MM * 60) + SS           
           COMPUTE XTIME = ETIME - STIME
           COMPUTE HH = XTIME / 3600
           COMPUTE XTIME = XTIME - (HH * 3600)
           COMPUTE MM = XTIME / 60
           COMPUTE SS = XTIME - (MM * 60)
           DISPLAY "STIME = " STIME
           DISPLAY "ETIME = " ETIME           
           DISPLAY "TIME = " HH ":" MM ":" SS
           STOP RUN.
           