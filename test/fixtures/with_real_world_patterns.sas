/* Test fixture for real-world SAS patterns from SEER Medicare files */
/* Tests: leading zeros, inline comments, trailing semicolons */

*filename testfile '/directory/testdata.txt';
*filename testfile pipe 'gunzip -c /directory/testdata.txt.gz';

options nocenter validvarname=upcase;

data testdata;
  infile testfile lrecl=80 missover pad;
  input
    @00001 patient_id                  $char15.  /*  Patient ID  */
    @00016 claim_id                    $char15.  /*  Encrypted  */
    @00031 service_dt                  $char8.   /*  YYMMDD8  */
    @00039 amount                      10.2      /*  Dollar amount  */
    @00049 integer_field               8.
    @00057 decimal_field               6.4
    @00063 final_char                  $char10.;

  label
    patient_id    = "Patient Identifier"
    claim_id      = "Claim Identifier"
    service_dt    = "Service Date"
    amount        = "Amount"
    ;

run;
