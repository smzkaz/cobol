SRC = postalcode.cob cob-sqlite3.c

CC = cobc
CFLAGS_DEBUG= -fdebugging-line -ftraceall
CFLAGS = -x $(CFLAGS_DEBUG)

LFLAGS = -lsqlite3 

all : yubin.db postalcode.exe 

postalcode.exe : $(SRC)
	$(CC) $(CFLAGS) $(SRC) $(LFLAGS)

yubin.db : yubin.csv postalcode.sql
	sqlite3 yubin.db ".read postalcode.sql"
	sqlite3 -separator , yubin.db ".import yubin.csv POSTAL_CODE"

yubin.csv : KEN_ALL.CSV
	nkf -w -Lu KEN_ALL.CSV > yubin.csv

clean :
	@if test -f yubin.csv; then \
	    rm yubin.csv ; \
	 fi
	@if test -f yubin.db; then \
	    rm yubin.db ; \
	 fi
	@if test -f postalcode.exe ; then \
	    rm postalcode.exe ; \
	 fi
	@if test -f postalcode; then \
	    rm postalcode ; \
	 fi


