
SRC = postalcode.cob cob-sqlite3.c

CC = /usr/local/bin/cobc
# CFLAGS_DEBUG= -fdebugging-line
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
	-rm yubin.csv
	-rm yubin.db
	-rm postalcode.exe


