DROP TABLE IF EXISTS fruits;
CREATE TABLE fruits(
fcode   INTEGER,
fname   VARCHAR(10),
price   INTEGR,
PRIMARY  KEY(fcode)
);
BEGIN;
INSERT INTO fruits(fcode, fname, price) VALUES(1001,'apple',2180);
INSERT INTO fruits(fcode, fname, price) VALUES(1002,'banana',1155);
INSERT INTO fruits(fcode, fname, price) VALUES(1003,'peach',2324);
INSERT INTO fruits(fcode, fname, price) VALUES(1004,'plum',3185);
INSERT INTO fruits(fcode, fname, price) VALUES(1005,'orange',5220);
INSERT INTO fruits(fcode, fname, price) VALUES(1006,'grape',3358);
INSERT INTO fruits(fcode, fname, price) VALUES(1007,'pear',2253);
INSERT INTO fruits(fcode, fname, price) VALUES(1008,'mango',4423);
COMMIT;
