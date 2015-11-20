      **=================================================================
      ** シーケンシャルファイルの生成
      ** 入力：郵便番号データベース
      ** 出力：シーケンシャルファイル
      **=================================================================
        identification           division.
        program-id.              postal_code.
      **=================================================================
        environment              division.
        input-output              section.
        file-control.
        select o-file
            assign to W-OUTPUT-FILENAME
            organization line sequential.
      **=================================================================
        data                     division.
        file                      section.
        fd  o-file
            label records are standard.
        01  POSTAL_CODE_REC
            03 全国地方公共団体コード   pic X(5).
            03 旧郵便番号（５桁）       pic X(5).
            03 郵便番号７桁             pic X(7).
            03 都道府県名（カナ）       pic N(6).
            03 市町村名（カナ）         pic N(19).
            03 町域名（カナ）           pic N(63).
            03 都道府県名（漢字）       pic N(4).
            03 市町村名（漢字）         pic N(10).
            03 町域名（漢字）           pic N(37).
            03 opt_01                   pic X(1).
            03 opt_02                   pic X(1).
            03 opt_03                   pic X(1).
            03 opt_04                   pic X(1).
            03 opt_05                   pic X(1).
            03 opt_06                   pic X(1).
    
        working-storage           section.
      *****************************************
      ** 表示色定義
      *****************************************
        78  black                       value 0.
        78  blue                        value 1.
        78  green                       value 2.
        78  cyan                        value 3.
        78  red                         value 4.
        78  magenta                     value 5.
        78  yellow                      value 6.
        78  white                       value 7.
      *****************************************
      ** 入力DATABASE定義
      *****************************************
        01  W-INPUT-DBNAME  pic X(256) values "yubin.db".

      *****************************************
      ** 出力ファイル定義（シーケンシャル)
      *****************************************
        01  W-OUTPUT-FILENAME  pic X(256) values "yubin_seq.dat".
        01  POSTAL_CODE_DB_REC.
            03 dantai      pic N(100).
            03 zip_5       pic N(100).            
            03 zip_7       pic N(100).
            03 ken_kana    pic N(100).
            03 shi_kana    pic N(100).
            03 cho_kana    pic N(100).
            03 ken         pic N(100).
            03 shi         pic N(100).
            03 cho         pic N(100).
            03 i_1         pic N(100).
            03 i_2         pic N(100).
            03 i_3         pic N(100).
            03 i_4         pic N(100).
            03 i_5         pic N(100).
            03 i_6         pic N(100).
            
        01  POSTAL_CODE_NAME.
            03 i_01         pic N(100).
            03 i_02         pic N(100).            
            03 i_03         pic N(100).
            03 i_04         pic N(100).
            03 i_05         pic N(100).
            03 i_06         pic N(100).
            03 i_07         pic N(100).
            03 i_08         pic N(100).
            03 i_09         pic N(100).
            03 i_10         pic N(100).
            03 i_11         pic N(100).
            03 i_12         pic N(100).
            03 i_13         pic N(100).
            03 i_14         pic N(100).
            03 i_15         pic N(100).
        01  sbuff           pic X(100).
        01  db               pic    9(04).
        01  db-rec           pic    x(60).
        01  rc               pic    9(02).
        01  err-msg          pic    x(60).
        01  flag             pic    x(01).
        01  i               pic 99.
        01  argc            pic 9(04).
        01  rec-count        pic    9(7).
        01  wk-count        pic    9(7).
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
      * *    03 values N"郵便番号:" LINE 1  COL 10.
      * *    03 a_15    LINE 1  COL 30 pic X(20) using zip_7.
            03 values N"郵便番号:" LINE 1  COL 10.
            03 a_15    LINE 1  COL 30 pic X(7) using 郵便番号７桁.
      * *    03 filler line 15 column 10 values "郵便番号:".
      * *    03 a_15  pic x(20) line 16 column 30 HIGHLIGHT.
      * *    03 filler line 16 column 10 values N"都道府県".
      * *    03 a_16  pic x(20) line 16 column 30 HIGHLIGHT.

        01 blank-screen.
           03 filler line 1 col 1 blank screen background-color black.
           03 ERASE EOS.

        01 result-screen.
           03 filler values NC"郵便番号(7桁) :"  line 11 col 10.
           03 r_01 pic N(100)  from zip_7        line 11 col 30.
           03 filler values NC"都道府県名    :"  line 12 col 10.
           03 r_02 pic N(100)  from ken          line 12 col 30.
           03 filler values NC"市区町村名    :"  line 13 col 10.
           03 r_03 pic N(100)  from shi          line 13 col 30.
           03 filler values NC"町域名        :"  line 14 col 10.
           03 r_04 pic N(100)  from cho          line 14 col 30.
           03 filter values NC"書き込み中:"　　　line 20 col 10.
           03 r_05 pic X(10) from wk-count       line 20 col 30.
           03 filler values "/"                  line 20 col 42.
           03 r_05 pic X(10) from rec-count      line 20 col 44.
      *     03 zip_7  from i_03          line 1 col 30.
      *     03 ken    from i_07          line 2 col 30.
      *     03 shi    from i_08          line 3 col 30.
      *     03 cho    from i_09          line 4 col 30.
        procedure               division.
      **コマンドパラメータ数
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

        perform DB-Open-S thru DB-Open-E.
        open output o-file.

        perform DB-GetCount-S thru DB-GetCount-E.
        perform DB-Select-S thru DB-Select-E.
        perform DB-Fetch-S thru DB-Fetch-E.

        perform DB-Close-S thru DB-Close-E.
        close o-file.

        screen-loop.
          display search-screen.
          accept search-screen.
      *   display blank-screen.
      D   display "1:a_15=" a_15.
          move 0 to sleep_time.
      D   move 5 to sleep_time.
          display blank-screen.
          perform DB-Select-S thru DB-Select-E.
          perform DB-Fetch-S thru DB-Fetch-E.
          
          if a_15(1:1) equal "q" then
            display ">> Enter q <<"
            perform SLEEP-S THRU SLEEP-E
          else
            go to screen-loop
          end-if.
          perform DB-Close-S thru DB-Close-E.
          stop run.

      ****************************************************************** 
        DB-Open-S. 
      * DB connection
      D    display ">> DB connection ".
           call  "SQLite3_Open"  using db "yubin.db".
           if return-code not = 0  then
      D       display ">> DB connection ERROR"
      D       perform SLEEP-S THRU SLEEP-E
              perform db-error
           end-if.
      D    display "<< DB connection " .          
        DB-Open-E. 

        DB-GetCount-S.
      D    display ">> GetCount ".
           initialize sbuff.
           string "SELECT COUNT(*) FROM POSTAL_CODE" into sbuff.
           call "SQLite3_Exec" using db sbuff.
           if return-code not = 0  then
      D       display "GetCount ERROR : " return-code
              perform  db-error
           else
              call "Fetch_Row" using rec-count
              if return-code not = 0  then
                 display "GetCount ERROR : " return-code
                 perform  db-error
              end-if
           end-if.
           
      D    display "<< GetCount ".
        DB-GetCount-E.
        
        DB-Select-S.
      * executing select 
      D    display ">> executing select ".
      D    perform SLEEP-S THRU SLEEP-E.
           initialize sbuff.
           string "SELECT * FROM POSTAL_CODE" into sbuff.
           call  "SQLite3_Exec" using db sbuff.
           if return-code not = 0  then
      D       display ">> executing select ERROR : "return-code
              perform  db-error
           end-if.
      D    display "<< executing select ".
        DB-Select-E.

        DB-GetColumnName-S.
      * column names
      D    display ">> column names ".
      D    perform SLEEP-S THRU SLEEP-E.
           call "Column_Name"  using i_01 i_02 i_03 i_04 i_05 i_06 i_07  -
                i_08 i_09 i_10 i_11 i_12 i_13 i_14 i_15.    
      *    display "|" i_01 "|" i_02 "|" i_03 "|" i_04 "|" i_05          -
      *            "|" i_06 "|" i_07 "|" i_08 "|" i_09 "|" i_10          -
      *            "|" i_10 "|" i_11 "|" i_12 "|" i_13 "|" i_14 "|" i_15. 
      D    display "<< column names ".
      D    perform SLEEP-S THRU SLEEP-E.
        DB-GetColumnName-E.

        DB-Fetch-S.
      * getting row data from table
      D    display ">> getting row data from table".
      D    perform SLEEP-S THRU SLEEP-E.
           move 1 to wk-count.
           perform  until flag not = flag
             call "Fetch_Row"                                            -
                   using dantai                                          -
                         zip_5 zip_7                                     - 
                         ken_kana shi_kana cho_kana                      -
                         ken      shi      cho                           - 
                         i_1 i_2 i_3 i_4 i_5 i_6
             if return-code not = 0 then
                exit perform
             end-if

             move dantai   to 全国地方公共団体コード
             move zip_5    to 旧郵便番号（５桁）
             move zip_7    to 郵便番号７桁
             move ken_kana to 都道府県名（カナ）
             move shi_kana to 市町村名（カナ）
             move cho_kana to 町域名（カナ）
             move ken      to 都道府県名（漢字）
             move shi      to 市町村名（漢字）
             move cho      to 町域名（漢字）
             move i_1      to opt_01
             move i_2      to opt_02
             move i_3      to opt_03
             move i_4      to opt_04
             move i_5      to opt_05
             move i_6      to opt_06
             write POSTAL_CODE_REC
             display result-screen
             compute wk-count = wk-count + 1
           end-perform.
      D    display "<< getting row data from table".           
      D    perform SLEEP-S THRU SLEEP-E.
        DB-Fetch-E.      

        DB-Close-S.
      * DB disconnection
      D    display ">> DB disconnection".
           call  "SQLite3_Close" using db.
           if return-code not = 0 then
              perform  db-error
           end-if.
      D    display "<< DB disconnection".
      D    perform SLEEP-S THRU SLEEP-E.
        DB-Close-E.


      * error 
        db-error.
      D    display ">> db-error".
      D    perform SLEEP-S THRU SLEEP-E.      
           call "Error_Msg" using err-msg.
           move return-code to rc.
           display "rc=" rc ":" err-msg.
      D    display "<< db-error".           
           stop run.

      * sleep func    
        SLEEP-S.
      D    DISPLAY SLEEP-CALL.
           if sleep_time > 0 then
              call "system" using SLEEP-CALL
           end-if.
        SLEEP-E.
        
