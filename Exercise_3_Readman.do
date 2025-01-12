***** Exercise_3_Readman.do
***** organizing the CPI and CPS-ORG Data, 1982–2024
***** cps-org data extracted from ipums and cleaned on 1/7/2024

cd "~/Dropbox/@10,000 feet and Runway/MA in Economics at Hunter/ECO 727 - Data Analysis and Research Methods/Analysis"
log using Exercise_3_Readman.smcl, name(results) replace
set scheme s2color
global ex=3
global lname="Readman"
global eyear=2024
global emonth=11

* part a: use the CPS-ORG files from the NBER

* appending three morg data sets from nber
  clear
  append using "../Data/morg79.dta" "../Data/morg80.dta" "../Data/morg81.dta"
  keep year intmonth minsamp classer esr age race sex gradeat uhours earnwke earnwt
  run data_check
  describe
  summarize
  list in -10/l, noobs

* renaming month variables to align with IPUMS
  rename (minsamp intmonth) (mish month)
  label define MONTH 1 "january" 2 "february" 3 "march" 4 "april" 5 "may" 6 "june" ///
                     7 "july" 8 "august" 9 "september" 10 "october" 11 "november" 12 "december"
  label values month MONTH
  label define MISH 4 "four" 8 "eight"
  label values mish MISH
  tabulate month mish

* keeping people ages 18–64, employed last week, working for a private firm or government
  numlabel classer, add
  tabulate classer
  keep if inrange(age, 18, 64) & (classer == 1 | classer == 2)
  describe
  summarize
  summarize earnwke, detail
  tab year if earnwke == .

*** end part a 

* part b: preparing the CPI data

* preparing CPI data to merge into CPS data
  import excel using "../Data/SeriesReport-20250109151624_b18e88.xlsx", cellrange(A12:M124) firstrow clear
  describe
  summarize
  rename Year year // rename to match CPS
  rename (Jan-Dec) m#, addnumber
  reshape long m, i(year) j(month)
  rename m cpi
  describe
  label variable month "Month"
  label variable cpi "Consumer Price Index"
  format cpi %9.3f

* sorting and saving
  sort year month
  list if year>=1982 & year<1984, noobs clean
  save "../Data/CPI 1913-2024.dta", replace
  summarize
  describe

*** end part b

* part c: merging the CPI into the CPS-ORGS

* merging the CPI into the CPS data from previous session
  use "../Data/CPS ORGs, 1982-2024, Cleaned.dta", clear
  describe
  summarize
  sort year month
  merge m:1 year month using "../Data/CPI 1913-2024.dta", keep(match)
  assert _merge ==3
  drop _merge 

* computing real wage
  summarize cpi if year==$eyear & month==$emonth, meanonly
  return list
  scalar cpi_scalar = r(mean)
  generate rwage=(cpi_scalar*earnweek)/cpi // latest month dollars
  label variable rwage "real wage in November 2024 dollars"

* saving
  save "../Data/CPS-ORG with CPI, 1982-2024.dta", replace
  describe
  summarize
*** end part c

* part d: creating and plotting a data set of statistics.

* calculating annual statistics for real weekly wage
  collapse (mean) mean=rwage /// mean
                  (p10) p10=rwage /// 10th percentile
                  (p50) p50=rwage /// 10th percentile
                  (p90) p90=rwage /// 90th percentile
                  [pw=earnwt], by(year)
  generate ldiff=100*(ln(p90) - ln(p10))
  format ldiff %4.1f
  save "../Data/CPS-ORG, Wage Percentiles, 1982-2024", replace
  describe
  summarize
  list in 1/5, noobs

* plotting trend in real weekly wages
  line p10 year || line p50 year || line p90 year || line mean year, ///
  title("Real weekly wages since 1982") ///
  xtitle("Year") xlabel(1980(5)2025, format(%ty)) ///
  ytitle("Real Weekly Wage, 1982=100") ylabel(0(500)3000, noticks) ///
  text(416.25 2025 "P10") text(1042.354 2025 "P50") text(1650 2025 "mean") text(2672.061 2025 "P90") ///
  scheme(Wide727Scheme)
  graph export "Results/fig1.png", width(600) replace

* Plot difference between 10th and 90th percentiles
  line ldiff year, sort ///
  title("Income inequality since 1982") ///
  xtitle("Year") xlabel(1980(5)2025, format(%ty)) ///
  ytitle("Log Difference") ///
  scheme(Wide727Scheme)
  graph export "Results/fig2.png", width(600) replace

*** end part d

log close results