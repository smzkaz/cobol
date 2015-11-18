        identification           division.
        program-id.               sample1.
        data                     division.
        working-storage           section.
        01  db               pic    9(04).
        01  db-rec           pic    x(60).
        01  a                pic    x(06).
        01  b                pic    x(10).
        01  c                pic    z,zz9.
        01  rc               pic    9(02).
        01  err-msg          pic    x(60).
        01  flag             pic    x(01).
        procedure                division.

       * DB connection
           call  "SQLite3_Open"  using db "test.db"
           if return-code not = 0  then
              perform  db-error
           end-if

       * executing select
           call  "SQLite3_Exec" using db
                               "SELECT * FROM fruits"
                       
           if return-code not = 0  then
              perform  db-error
           end-if

       * column names
           call "Column_Name"  using a b c
           display "|" a "|" b "|" c "|"

       * getting row data from table
           perform  until flag not = flag
             call "Fetch_Row" using a b c
             if return-code not = 0 then
                exit perform
             end-if
             move c to c
       *     display   a b c
             display "|" a "|" b "|" c "|"
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
           