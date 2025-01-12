***** Exercise_4_Readman.do
***** organizing the CPI and CPS-ORG Data, 1982–2024
***** cps-org data extracted from ipums and cleaned on 1/7/2024

cd "~/Dropbox/@10,000 feet and Runway/MA in Economics at Hunter/ECO 727 - Data Analysis and Research Methods/Analysis"
log using Exercise_4_Readman.smcl, name(results) replace
set scheme s2color
global ex=4
global lname="Readman"
global eyear=2024
global emonth=11

* part a: using the merged CPS-ORG/CPI data from exercise 3

  use "../Data/CPS-ORG with CPI, 1982-2024.dta", replace
  run data_check
  keep if earnweek!=.
  generate experience=age-grade-6
  generate exp2=experience^2
  generate lrwage=log(rwage)
  describe
  summarize
  
  *label new variables

* part b: estimating a simple log-wage regression
  regress lrwage grade experience exp2 [pw=earnwt]
  display "The log-wage profile peaks at" , %4.1f -e(b)[1,2]/(2*e(b)[1,3]) , "years of experience."


* part c: adding factor variables



* part d: estimate year-specific grade coefficients



* part e: merging the grade coefficients with the 90-10 differential (in logs)



* part f: plotting the relationship between the grade coefficients and the 90-10 differential

log close results