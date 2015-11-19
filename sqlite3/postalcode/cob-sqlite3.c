/*   cob-sqlite3.c   Version  4.1                              31/07/2008    */
/*   Copyright (C) sanpontze. All Rights Reserved                            */

#include          <stdio.h>
#include          <stdlib.h>
#include          <string.h>
#include          <stdarg.h>
#include          <libcob.h>
#include          <sqlite3.h>

#define  FORMAT_CHAR        '%'
#define  ERRMSGSIZE         100

#define min(a,b)  ((a) < (b) ? (a) : (b))

static int  nCol, nRow, RowCount, errout, rc;
static char **result, *sql;
char   *ErrMsg, err_msg[ERRMSGSIZE];
static int (*func)(char *errno, const char *errmsg); 
sqlite3 *dbx;

void err_exit(int);                                 // proto type of err_exit

int SQLite3_Open(sqlite3 **db, ...)
{
    va_list args;
    char *db_name, *fname;

    va_start(args, db);
      
    db_name = va_arg(args, char *);

    if( cob_call_params > 2 )
        fname = va_arg(args, char *);
    else 
        fname = "";

    va_end(args);
 
    if( !strcmp(fname, "stderr") )  errout = 1;  // stderr
    else if( !strcmp(fname, "") )   errout = 2;  // default
    else {
           cob_init(0, NULL);
           func = cob_resolve(fname);
           if(func == NULL){
              fprintf(stderr, "%s\n", cob_resolve_error());
              (void)exit(1);
           }
           errout = 3;                           // user function
    }

    if( rc=sqlite3_open(db_name, &*db ) ){
        sprintf(err_msg, "sqlite3_open: %s\n", sqlite3_errmsg(*db));
    }
    dbx = *db; 
    err_exit(rc);
    return rc;
}

int SQLite3_Close(sqlite3 **db)
{
    if( rc=sqlite3_close(*db) ){
        sprintf(err_msg, "sqlite3_close: %s\n", sqlite3_errmsg(*db));
    }
    err_exit(rc);
    return rc;
}

int gen_string(char *in_sql, va_list ap)
{ 
    char *p, *w,*argv=0, fmt[3] = {"% "},buf[30];
    int j, len, sql_size=strlen(in_sql);

    sql = (char*)sqlite3_malloc(sql_size);

    for(p=in_sql, j=0; *p; p++){
      if( *p == '\\' ){
         *(sql+j++) = *++p;  continue;                      // escaped by '\'
      } else 
      if( *p != FORMAT_CHAR ){
         *(sql+j++) = *p;    continue;                      // ordinal chars
      }
      switch(fmt[1]=*++p){                                  // next to '%'
         case 'i' : case 'd':
           argv = sqlite3_mprintf(fmt, *va_arg(ap, int *));
           break;
         case 'u' :
           argv = sqlite3_mprintf(fmt, *va_arg(ap, unsigned *));
           break;
         case 'f' :
           argv = sqlite3_mprintf(fmt, *va_arg(ap, float *));
           break;
         case 'F' :
           argv = sqlite3_mprintf("%f", *va_arg(ap, double *));
           break;
         case 's'  :case 'q' : case 'Q' :
           argv = sqlite3_mprintf(fmt, va_arg(ap, char *));
           break;
         default:
           sprintf(err_msg, "GenString: %s not supported", fmt);
           return -7;
      }
      len = strlen(argv);
      sql_size += len;
      if( (sql=(char*)sqlite3_realloc(sql, sql_size)) == NULL ){
          strcpy(err_msg, "SQL generate error: memory realloc");
          sqlite3_free(argv);
          return -7;
      }
      strcpy(sql+j, argv);
      j += len;
      sqlite3_free(argv);
    }
    *(sql+j) = 0;
    return 0;
}

int strtolowercmp(unsigned char *dst, unsigned char *lower)
{
    for(;*lower;lower++){
      if( *lower != tolower(*dst++) ) return -1;            // not equal
    }
    return 0;                                               // equal
}

int SQLite3_Exec(sqlite3 **db, char *cob_sql, ...)
{
    char     *w;
    int     len;
    va_list  ap;

    if( cob_call_params > 2 ){
        va_start(ap, cob_sql);                              // with actual params
        if( rc=gen_string( cob_sql, ap ) ){
           va_end(ap);
           return rc;                                       // fail to generate
        }
        va_end(ap);
    } else {
        len = strlen(cob_sql) + 1;                          // no actual params
        if( (sql=(char*)sqlite3_malloc(len)) == NULL ){
            strcpy(err_msg, "Exec error: memory alloc");
            return -7;
        }
        memcpy(sql, cob_sql, len);
    }

    if( !strtolowercmp(sql, "select") ){                    // strnicmp()
    /* select */
       if( rc = sqlite3_get_table(*db, sql, &result, &nRow, &nCol, &ErrMsg) ){
           w = strtok(sql, " *");
           sprintf(err_msg, "sqlite3_exec(%s):%s", w, ErrMsg);
       } else {
         RowCount = 1;                                      // start from row 1 
       }
    } else {
    /* except for select */
       if( rc = sqlite3_exec(*db, sql, NULL, NULL, NULL) ){
           w = strtok(sql, " ;(");
           sprintf(err_msg, "sqlite3_exec(%s):%s", w, sqlite3_errmsg(*db));
       }
    }
    sqlite3_free(sql);
    err_exit(rc);
    return rc;
}

void SQLite3_changes(sqlite3 **db, int *rc)
{
   *rc = sqlite3_changes(*db);
   return ;
}

void SQLite3_total_changes(sqlite3 **db, int *rc)
{
   *rc = sqlite3_total_changes(*db);
   return ;
}

int move_to_cob(char *cob_dat, char *dat)
{
    int len = strlen(cob_dat);                              // data length in cob
    memset(cob_dat, ' ', len);                              // clear with spaces
    memcpy(cob_dat, dat, min(len, strlen(dat)));            // data copy
    return 0;
}

int move_values(char *str, int base, va_list arg)
{
    int j, params = min(cob_call_params, nCol);
    for( j=0; j<params; j++ ){
         move_to_cob( str, result[ base + j ] );
         str = va_arg(arg, char *);
    }
    return 0;
}

int Fetch_Row(char *str, ...)
{ 
    va_list arg; 

    if( RowCount <= nRow ){
        va_start(arg, str);
        move_values(str, nCol * RowCount, arg);
        va_end(arg);
        RowCount++;
        return 0;                                           // not eof
    }
    else {
        sqlite3_free_table(result);
        return EOF;                                         // eof
    }
}

int Column_Name(char *str, ...)
{
    va_list arg;

    va_start(arg, str);
    move_values(str, 0, arg);                               // row no. 0
    va_end(arg);
    return rc;
}

int Gen_String(char *cob_sql, char *in_sql, ...)
{
    va_list arg; 

    va_start(arg, *in_sql);
    if( !(rc=gen_string(in_sql, arg)) ){
        move_to_cob(cob_sql, sql);
        sqlite3_free(sql);
    }
    va_end(arg);
    err_exit(rc);
    return rc;
}

void Row_Num(int *n)
{
    *n = nRow;
    return;
}

void Col_Num(int *n)
{
    *n = nCol;
    return;
} 

int Error_Msg(char *str)
{
    move_to_cob(str, err_msg);
    return sqlite3_errcode(dbx);
}

/* 出口処理 */
void err_exit(int rc)
{
/*   正常終了 rc  = 0 ではそのまま復帰する                                       */
/*   異常終了 rc != 0 では初期設定(MySQL_init)で設定されたエラー出口にしたがって */
/*   処理を分ける:                                                               */
/*     errout = 1:  エラーメッセージを stderr に出力して終了する                 */
/*     errout = 2:  エラーは呼び出し元で処理されるものとしてそのまま復帰する　　 */
/*     errout = 3:  エラーはユーザ作成のプログラムで処理されるものとして、       */
/*　　　　　　　　　errno, errmsg をパラメタとして指定されたプログラムを呼ぶ。   */

    char errno[10];

    if( !rc ) return;

    switch(errout){
        case 1: 
             fprintf(stderr, "Sqlite3 Error: %d\n", rc);
             fprintf(stderr,"%s\n", err_msg);
             exit(1);
        case 2:
             break;
        case 3:
             sprintf(errno, "%02d", rc);
             func(errno, err_msg);
    }
    return;
}

/*---------------------------------------------------------------------------*/

int SQLite3_prepare(sqlite3 **db, sqlite3_stmt **stmt, char *sql)
{
    char *p;

    p = sql + strlen(sql) - 1;
    while(p>sql && *p==' ') p--; 
    rc = sqlite3_prepare(*db, sql, (p-sql+1), &*stmt, NULL);
    if( *stmt == NULL ){
        sprintf(err_msg, "sqlite3_prepare:%s", sqlite3_errmsg(dbx));
    }
    err_exit(rc);
    return sqlite3_errcode(dbx);
}

int SQLite3_step(sqlite3_stmt **stmt)
{
    rc = sqlite3_step(*stmt);
    if( !(rc == SQLITE_ROW || rc == SQLITE_DONE) || rc ){
        rc = sqlite3_errcode(dbx);
        sprintf(err_msg, "sqlite3_step:%s", sqlite3_errmsg(dbx));
    }
    return sqlite3_errcode(dbx);
}

int SQLite3_finalize(sqlite3_stmt **stmt)
{
    rc = sqlite3_finalize(*stmt);
    if( rc ) {
       sprintf(err_msg, "sqlite3_finalize:%s", sqlite3_errmsg(dbx));
    }
    err_exit(rc);
    return sqlite3_errcode(dbx);
}

int SQLite3_reset(sqlite3_stmt **stmt)
{
   rc = sqlite3_reset(*stmt);
   if( rc ){
      sprintf(err_msg, "sqlite3_reset:%s", sqlite3_errmsg(dbx));
   }
   err_exit(rc);
   return sqlite3_errcode(dbx);
}

int SQLite3_bind_int(sqlite3_stmt **stmt, int *iCol, int *var)
{
   rc = sqlite3_bind_int(*stmt, *iCol, *var);
   if( rc ){
       sprintf(err_msg, "sqlite3_bind_int:%s", sqlite3_errmsg(dbx));
   }
   err_exit(rc);
   return sqlite3_errcode(dbx);
}

int SQLite3_bind_text(sqlite3_stmt **stmt, int *iCol, char *buf)
{
   char *p;

   p = buf + strlen(buf) - 1;
   while(p>buf && *p==' ') p--; 
   rc = sqlite3_bind_text(*stmt, *iCol, buf, (p-buf+1), SQLITE_STATIC);
   if( rc ){
       sprintf(err_msg, "sqlite3_bind_text:%s", sqlite3_errmsg(dbx));
   }
   err_exit(rc);
   return sqlite3_errcode(dbx);
}

void SQLite3_column_int(sqlite3_stmt **stmt, int *iCol, char *var)
{
    char buf[10];
    sprintf(buf, "%d", sqlite3_column_int(*stmt, *iCol));
    move_to_cob(var, buf);
    return;
}

void SQLite3_column_text(sqlite3_stmt **stmt, int *iCol, char *str)
{
    move_to_cob(str, (char *)sqlite3_column_text(*stmt, *iCol-1));
    return;
}

void SQLite3_column_name(sqlite3_stmt **stmt, int *iPos, char *str)
{
    move_to_cob(str, (char *)sqlite3_column_name(*stmt, *iPos-1));
    return;
}

void SQLite3_column_count(sqlite3_stmt **stmt, int *n)
{
    *n = sqlite3_column_count(*stmt);
    return;
}

