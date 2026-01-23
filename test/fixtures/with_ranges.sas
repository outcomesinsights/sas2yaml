/* SAS input with range-based field definitions */
data vitals;
infile 'vitals.dat';
input
  @1   subject_id   6.
  @7   (bp1-bp3)    (3.)
  @16  (temp1-temp3) ($char4.)
;
label
  subject_id = "Subject ID"
;
run;
