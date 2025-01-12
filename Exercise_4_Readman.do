***** Exercise_4_Readman.do
***** organizing the CPI and CPS-ORG Data, 1982–2024
***** cps-org data extracted from ipums and cleaned on 1/7/2024

cd "~/Dropbox/@10,000 feet and Runway/MA in Economics at Hunter/ECO 727 - Data Analysis and Research Methods/Analysis"
log using Exercise_4_Readman.smcl, name(results) replace
set scheme s2color
global ex=4
global lname="Readman"

* part a: using the merged CPS-ORG/CPI data from exercise 3
  use "../Data/CPS-ORG with CPI, 1982-2024.dta", replace
  run data_check
  keep if earnweek!=.
  generate experience=age-grade-6
  label variable experience "experience as function of age and education"
  generate exp2=experience^2
  label variable exp2 "quadratic of experience"
  generate lrwage=log(rwage)
  label variable lrwage "log of real weekly wage"
  describe
  summarize

*** end part a

* part b: estimating a simple log-wage regression
  regress lrwage grade experience exp2 [pw=earnwt]
  test experience exp2 // joinly significant at any conventional level
  display "The sign of the coefficient on exp2 is negative, reflecting diminishing marginal returns to experience."
  display "The log-wage profile peaks at" , %4.1f -e(b)[1,2]/(2*e(b)[1,3]) , "years of experience." // Compute and display peak experience

*** end part b

* part c: adding factor variables
  regress lrwage grade experience exp2 i.female i.race i.region i.occupation i.industry year [pw=earnwt]
  testparm i.female
  testparm i.race
  testparm i.region
  testparm i.occupation
  testparm i.industry

*** end part c

* part d: estimate year-specific grade coefficients
  regress lrwage year#c.grade grade experience exp2 i.female i.race i.region i.occupation i.industry year [pw=earnwt]
  matrix b = e(b)[1, "1982.year#c.grade".."2024.year#c.grade"]'
  clear
  svmat2 b, names(grade_coef) rnames(tag)
  list in 1/10, noobs
  generate year=real(substr(tag, 1, 4))
  drop tag
  order year grade_coef
  replace grade_coef = grade_coef * 100 // convert to percentages
  list, noobs
  describe
  summarize
  tempfile temp1
  save `temp1', replace
  
*** end part d

* part e: merging the grade coefficients with the 90-10 differential (in logs)
  use "../Data/CPS-ORG, Wage Percentiles, 1982-2024.dta", clear
  keep year ldiff
  describe
  summarize
  tempfile temp2
  save `temp2', replace

* merge
  use `temp1', clear
  merge 1:1 year using `temp2'
  assert _merge==3
  drop _merge

* saving
  save "../Data/Grade_coef and ldiff, 1982-2024.dta", replace
  describe
  summarize
  list

*** end part e

* part f: plotting the relationship between the grade coefficients and the 90-10 differential


*** end part f

log close results