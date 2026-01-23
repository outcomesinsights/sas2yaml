/* SAS input with arrays and loops */
data claims;
infile 'claims.dat' lrecl=100;
array dgn(5) $ dgn_cd1-dgn_cd5;
input
  @1   claim_id     10.
  @11  service_dt   8.
;
do i = 1 to 5;
  input @inc dgn(i) $char5.;
  inc = inc + 5;
end;
label
  claim_id = "Claim ID"
;
run;
