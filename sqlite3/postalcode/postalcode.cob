        identification           division.
        program-id.               postal_code.
        data                     division.
        working-storage           section.
        01  POSTAL_CODE.
            03 dantai           pic x(4).
            03 zip_5            pic X(05).
            03 zip_7.
               05 zip_7_3       pic X(03).
               05 zip_7_4       pic X(04).
            03 ken_kana         pic X(100).
            03 shi_kana         pic X(100).
            03 cho_kana         pic X(100).
            03 ken              pic X(100).
            03 shi              pic X(100).
            03 cho              pic X(100).
            03 item_01          pic 9(02).
            03 item_02          pic 9(02).
            03 item_03          pic 9(02).
            03 item_04          pic 9(02).
            03 item_05          pic 9(02).
            03 item_06          pic 9(02).
        01  POSTAL_CODE_NAME.
            03 i_01         pic X(20).
            03 i_02         pic X(20).            
            03 i_03         pic X(20).
            03 i_04         pic X(20).
            03 i_05         pic X(20).
            03 i_06         pic X(20).
            03 i_07         pic X(20).
            03 i_08         pic X(20).
            03 i_09         pic X(20).
            03 i_10         pic X(20).
            03 i_11         pic X(20).
            03 i_12         pic X(20).
            03 i_13         pic X(20).
            03 i_14         pic X(20).
            03 i_15         pic X(20).            
        01  db               pic    9(04).
        01  db-rec           pic    x(60).
        01  rc               pic    9(02).
        01  err-msg          pic    x(60).
        01  flag             pic    x(01).
        procedure                division.

       * DB connection
           call  "SQLite3_Open"  using db "yubin.db"
           if return-code not = 0  then
              perform  db-error
           end-if

       * executing select
           call  "SQLite3_Exec" using db
                 "SELECT * FROM POSTAL_CODE where zip_7 = '1110023' "
                       
           if return-code not = 0  then
              perform  db-error
           end-if

       * column names
           call "Column_Name"  using i_01 i_02 i_03 i_04 i_05 i_06 i_07  -
                i_08 i_09 i_10 i_11 i_12 i_13 i_14 i_15    
           display "|" i_01 "|" i_02 "|" i_03 "|" i_04 "|" i_05          -
                   "|" i_06 "|" i_07 "|" i_08 "|" i_09 "|" i_10          -
                   "|" i_10 "|" i_11 "|" i_12 "|" i_13 "|" i_14 "|" i_15 

       * getting row data from table
           perform  until flag not = flag
             call "Fetch_Row" using i_01 i_02 i_03 i_04 i_05 i_06 i_07   -
                  i_08 i_09 i_10 i_11 i_12 i_13 i_14 i_15                 
             if return-code not = 0 then
                exit perform
             end-if
           display "|" i_01 "|" i_02 "|" i_03 "|" i_04 "|" i_05          -
                   "|" i_06 "|" i_07 "|" i_08 "|" i_09 "|" i_10          -
                   "|" i_10 "|" i_11 "|" i_12 "|" i_13 "|" i_14 "|" i_15 
           end-perform

       * DB disconnection
           call  "SQLite3_Close" using db
           if return-code not = 0 then
              perform  db-error
           end-if
           stop run.

       * error 
        db-error.
           call "Error_Msg" using err-msg
           move return-code to rc
           display "rc=" rc ":" err-msg
           stop run.
           