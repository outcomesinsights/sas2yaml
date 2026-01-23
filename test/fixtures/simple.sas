/* Simple SAS input statement for testing */
data example;
infile 'data.dat' lrecl=50;
input
  @1   patient_id   8.
  @9   age          3.
  @12  gender       $char1.
  @13  weight       5.2
  @18  diagnosis    $char10.
;
label
  patient_id = "Patient ID"
  age = "Age in years"
;
run;
