        identification           division.
        program-id.              postal_code.
        data                     division.
        working-storage           section.
        78  black                       value 0.
        78  blue                        value 1.
        78  green                       value 2.
        78  cyan                        value 3.
        78  red                         value 4.
        78  magenta                     value 5.
        78  yellow                      value 6.
        78  white                       value 7.
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
        01  i               pic 99.
        01  argc            pic 9(04).
        01  STD.
            03 default_arg_num pic 99 values 10.
        01  params.
            03 param  occurs 10  pic X(50).
        01  SLEEP-CALL.
            03 sleep_cmd  pic x(6) values "sleep ".
            03 sleep_time pic 9(1) values 2.
        01  SCREEN_ITEM.
            03 search-screen-items.
               05 i_yubin pic N(10) values N"郵便番号:".
        SCREEN section.
        01 search-screen.
      **    03 values N"郵便番号:" LINE 1  COL 10.
      **    03 a_15    LINE 1  COL 30 pic X(20) using zip_7.
            03 values N"郵便番号:" LINE 1  COL 10.
            03 a_15    LINE 1  COL 30 pic X(7) using zip_7.
      * *    03 filler line 15 column 10 values "郵便番号:".
      * *    03 a_15  pic x(20) line 16 column 30 HIGHLIGHT.
      * *    03 filler line 16 column 10 values N"都道府県".
      * *    03 a_16  pic x(20) line 16 column 30 HIGHLIGHT.

        01 blank-screen.
           05 filler line 1 blank screen background-color black.
           05 ERASE EOS.

        01 result-screen.
           03 values N"郵便番号(7桁) :" line 1 col 10.
           03 values N"都道府県名    :" line 2 col 10.
           03 values N"市区町村名    :" line 3 col 10.
           03 values N"町域名        :" line 4 col 10.
      *    03 zip_7                     line 1 col 30.
      *    03 ken                       line 2 col 30.
      *    03 shi                       line 3 col 30.
      *    03 cho                       line 4 col 30.
           
        procedure               division.
       *コマンドパラメータ数
          accept argc from argument-number.
          display "argc = " argc.
          if argc > 0 then  
             if argc > 0 and argc < default_arg_num then
      **********************************************
      * *コマンドパラメータ取得
                move 1 to i
                perform until argc < i
                accept param(i) from argument-value
                display "param(" i ")=" param(i)
                compute i = i + 1
                end-perform
      **********************************************
             else
      * *********************************************
                display "Error: argc=" argc " (<" default_arg_num")"
                stop run
      ***********************************************
             end-if
         end-if.

        SLEEP-S.
      D    DISPLAY SLEEP-CALL
           call "system" using SLEEP-CALL.
        SLEEP-E.

       .screen-loop.
          display search-screen.
          accept search-screen.
          display blank-screen.
      D   display "1:a_15=" a_15.

          if a_15(1:1) equal "q" then
             display ">> Enter q <<"
             stop run
          end-if.
          display "2:a_15=" a_15.

      *  DB connection
           call  "SQLite3_Open"  using db "yubin.db"
           if return-code not = 0  then
              perform  db-error
           end-if

      * executing select
           call  "SQLite3_Exec" using db
                 "SELECT * FROM POSTAL_CODE where zip_7 = '" a_15 "' "
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
