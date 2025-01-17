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
  tabulate census
  assert census==80
  assert _N==486926

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
  eststo ols: regress lwklywge educ
  eststo wald: ivregress 2sls lwklywge (educ = q1), first
   estadd scalar widstat=e(F)
  eststo qob_iv: ivregress 2sls lwklywge i.yob (educ = i.qob), first
   estadd scalar widstat=e(F)
*** end part b

* part c: Reproducing Angrist and Krueger’s Table 6
* estimating OLS regressions for table columns 1, 3, 5, 7
regress lwklywge educ i.yob // OLS (1)
 eststo column_1
regress lwklywge educ i.yob ageq ageqsq // OLS (3)
 eststo column_3
regress lwklywge educ i.race i.smsa i.married i.yob i.region // OLS (5)
 eststo column_5
regress lwklywge educ i.race i.smsa i.married i.yob i.region ageq ageqsq // OLS (7)
 eststo column_7

* estimating 2SLS regressions for table columns 2, 4, 6, 8
ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob // TSLS (2)
 eststo column_2
 estat firststage
ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob ageq ageqsq // TSLS (4)
 eststo column_4
 estat firststage
ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) i.race i.smsa i.married ib49.yob i.region // TSLS (6)
 eststo column_6
 estat firststage
ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) i.race i.smsa i.married ib49.yob i.region ageq ageqsq // OLS (8)
 eststo column_8
 estat firststage
*** end part c

* part d: Comparing the Estimates

*** end part d

* part e: Creating a Table of Estimates from Part B
 esttab ols wald qob_iv, ///
    b(3) se(3) stats(r2 widstat N , fmt(%4.3f %4.1f %9.0fc) labels("R-squared" "First-stage F-stat" "Observations")) ///
    nodepvars nostar obslast nobaselevels varwidth(24) alignment(r) ///
    title("Returns to Education Estimates") ///
    mtitles("OLS" "Wald" "2SLS") ///
    coeflabels(_cons "Constant" educ "Highest Grade Completed") ///
    order(_cons educ) ///
    indicate("Birth Year Effects = *.yob") ///
    nonotes addnotes("Standard errors in parentheses." "Data source: 1980 Census.")
*** end part e

* part f: Reproducing Angrist and Krueger’s Table 6

*** end part f



log close results   