***** Exercise_5_Readman.do
***** 
***** 

cd "~/Dropbox/@10,000 feet and Runway/MA in Economics at Hunter/ECO 727 - Data Analysis and Research Methods/Analysis"
log using Exercise_5_Readman.smcl, name(results) replace
set scheme s2color
global ex=5
global lname="Readman"
tempfile temp1

* part a: using the “Birth Quarter.dta” data
  use "../Data/Birth Quarter.dta" if cohort==4, clear
  run data_check
  describe
  assert _N == 486926

* generating new variables
  generate ageqsq=ageq^2
  tab qob
  generate q1=1 if qob==1
  replace  q1=0 if q1==.
  tab q1

* add labels and save
  label variable q1 "quarter 1"
  label variable ageqsq "age quarter squared"
  describe
  save `temp1', replace
*** end part a

* part b: Estimate the log-Wage Regression by OLS and 2SLS

* OLS regression
  regress lwklywge educ
  eststo ols

*2SLS regression using q1 as the only instrument (Wald estimate)
  ivregress 2sls lwklywge (educ = q1), first
  estat firststage  // Check instrument strength
  eststo wald

* Step 3: 2SLS regression using qob as instruments and including birth-year effects
  ivregress 2sls lwklywge (educ = qob) i.yob
  estat firststage  // Check instrument strength
  estat overid      // Test overidentifying restrictions
  eststo qob_iv

* Step 4: Export the results for comparison
  esttab ols wald qob_iv, stats(N r2) se label nonumbers



log close results   