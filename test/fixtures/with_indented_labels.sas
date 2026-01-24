/* Test fixture for indented label statements */
/* This tests the fix for label statements that are indented */

*filename testfile '/directory/testdata.txt';
*filename testfile pipe 'gunzip -c /directory/testdata.txt.gz';

options nocenter validvarname=upcase;

data testdata;
  infile testfile lrecl=100 missover pad;
  input @001 record_id                    $char10.
        @011 field_a                      $char5.
        @016 field_b                      $char8.
        @024 numeric_field                8.
        @032 decimal_field                10.2
        @042 another_char                 $char15.
        @057 final_field                  $char20.
        ;

  label record_id                    = "Unique Record Identifier"
        field_a                      = "First Character Field"
        field_b                      = "Second Character Field"
        numeric_field                = "An Integer Field"
        decimal_field                = "A Decimal Field"
        another_char                 = "Another Character Field"
        final_field                  = "The Final Field"
        ;

proc contents data=testdata position;
run;
