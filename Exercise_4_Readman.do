***** Exercise_4_Readman.do
***** regressing factor variables using CPS-ORGS CPI data from exercise 3 (in Data folder)
***** analyzing earnings inequality and return to schooling

cd "~/Dropbox/@10,000 feet and Runway/MA in Economics at Hunter/ECO 727 - Data Analysis and Research Methods/Analysis"
log using Exercise_4_Readman.smcl, name(results) replace
set scheme s2color
global ex=4
global lname="Readman"
global syear=1982 // start year
global eyear=2024 // end year
global numyear=$eyear-$syear+1

* part a: using the merged CPS-ORG/CPI data from exercise 3
  use "../Data/CPS-ORG with CPI, 1982-2024.dta", replace
  run data_check
  keep if earnweek!=.
  generate experience=age-grade-6
  drop if experience <=0 // experience less then 0 makes no sense
  label variable experience "experience as function of age and education"
  generate exp2=experience^2
  label variable exp2 "experience squared"
  generate lrwage=log(rwage)
  label variable lrwage "log of real weekly wage"
  describe
  summarize
*** end part a

* part b: estimating a simple log-wage regression
  regress lrwage grade experience exp2 [pw=earnwt]
   test experience exp2
   display "The log-wage profile peaks at" , %4.1f -e(b)[1,2]/(2*e(b)[1,3]) , "years of experience." // Compute and display peak experience
*** end part b

* part c: adding factor variables
  regress lrwage grade experience exp2 female i.race i.region i.occupation i.industry i.year [pw=earnwt]
   testparm i.race
   testparm i.region
   testparm i.occupation
   testparm i.industry
   testparm i.year
*** end part c

* part e: merging the grade coefficients with the 90-10 differential (in logs)
  use "../Data/CPS-ORG, Wage Percentiles, 1982-2024.dta", clear
   keep year ldiff
   list, noobs
   describe
   summarize
   tempfile temp2
   save `temp2', replace
  use `temp1', clear
   merge 1:1 year using `temp2'
   assert _merge==3
   drop _merge
  list
  describe
  summarize 

* saving 
  save "../Data/Grade_coef and ldiff, 1982-2024.dta", replace
  describe
  summarize
  list
*** end part e

* part f: plots
* line graph of log-wage differential and grade coefficients
  line ldiff year, yaxis(1) || line grade_coef year, yaxis(2) ///
   xtitle(Year) xlabel(1980(10)2025) xtick(1980(5)2015) ///
   ytitle("90-10 log-Wage Differential (%)", axis(1)) ylabel(150(10)200, format(%10.0g) noticks axis(1)) ///
   ytitle("Rate of Return to Schooling (%)", axis(2)) ylabel(5(1)10, noticks axis(2)) ///
   text(183 1985 "90-10 Differential") text(155 1985 "Return to Schooling") ///
   scheme(Wide727Scheme) name(g1, replace)
  graph export results/inequality_schooling_line.png, name (g1) width(600) replace

* scatter plot of log-wage-differential and grade coefficients
  scatter ldiff grade_coef || lfit ldiff grade_coef ||, ///
   xtitle(Rate of Return to Schooling (%)) xlabel(4(1)10) ///
   ytitle("90-10 log-Wage Differential (%)") ylabel(160(10)200, format(%10.0g) noticks) ///
   scheme(Squarish727Scheme) name(g2, replace)
  graph export results/inequality_schooling_scatter.png, name (g2)  width(450) replace
*** end part f

log close results
