***** Exercise_5_Readman.do
***** recreating results from Angrist and Krueuger 1991 using Birth Quarter data
***** creating and formatting results tables using esttab

cd "~/Dropbox/@10,000 feet and Runway/MA in Economics at Hunter/ECO 727 - Data Analysis and Research Methods/Analysis"
log using Exercise_5_Readman.smcl, name(results) replace
global ex=5
global lname="Readman"

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
*** end part a

* part b: Estimate the log-Wage Regression by OLS and 2SLS
  eststo ols:    regress lwklywge educ
  eststo wald:   ivregress 2sls lwklywge (educ = q1)
   estat firststage
  eststo qob_iv: ivregress 2sls lwklywge (educ = ib4.qob) ib49.yob, first
   estat firststage
   estat overid
*** end part b

* part c: Reproducing Angrist and Krueger’s results for Table 6
* estimating OLS and TSLS regressions
  eststo column_1: regress lwklywge educ i.yob // OLS (1)
  eststo column_2: ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob // TSLS (2)
   estat firststage
   estat overid
  eststo column_3: regress lwklywge educ i.yob ageq ageqsq // OLS (3)
  eststo column_4: ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob ageq ageqsq // TSLS (4)
   estat firststage
   estat overid
  eststo column_5: regress lwklywge educ i.race i.smsa i.married i.yob i.region // OLS (5)
  eststo column_6: ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) i.race i.smsa i.married ib49.yob ib9.region // TSLS (6)
   estat firststage
   estat overid
  eststo column_7: regress lwklywge educ i.race i.smsa i.married i.yob i.region ageq ageqsq // OLS (7)
  eststo column_8: ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) i.race i.smsa i.married ib49.yob ib9.region ageq ageqsq // TSLS (8)
   estat firststage
   estat overid
*** end part c

* part d: Comparing the Estimates

  /*
    My Wald estimate suggests a very small negative effect of education on wages (-1%) that is not statistically
    significant due to large standard errors, whereas Angrist and Krueger's Wald estimate from Table III indicates an economically significant positive return to education of about 10.2%. This represents an 11 percentage point difference between the estimates, with their result being more precisely estimated and statistically significant.
  */ 
  /*
    The 2SLS estimates using three quarter-of-birth dummies as instruments (-5.5%) and quarter-of-birth dummies controlling for birth year (-6.1%) yield similar negative effects on weekly wages, with both estimates being similarly precise (standard errors around 0.025) and statistically significant at conventional levels.
    The addition of birth year controls results in only a small change in the estimated return to education, suggesting the simpler specification with just quarter-of-birth instruments captures most of the relevant variation.
  */

  /*Are the over-identifying restrictions rejected in the models with
    (a) three birth-quarter instruments or
    (b) 29 birth-quarter/birthyear instruments?
  */
 * test for overidentification

  /*
    Final Write-Up:
	1.	The Wald estimate in Part B (0.055 ) differs significantly from Angrist and Krueger’s table 3 estimate ( +0.102 ), both in sign and magnitude.
	2.	The 2SLS estimate with three birth-quarter instruments ( -0.055 ) is smaller in magnitude compared to the 2SLS estimate with 29 birth-quarter × birth-year instruments ( -0.253 ), but both suggest negative returns to education, which is counterintuitive.
	3.	The over-identifying restrictions are rejected for both models, indicating that the instruments in both cases are invalid.
  */

*** end part d

* part e: Creating a Table of Estimates from Part B
  estimates dir

  * stata version
  esttab ols wald qob_iv, ///
   nodepvars nostar obslast nobaselevels varwidth(24) ///
   title("Least-Squares Estimates of the log-Wage Regression") ///
   mtitles("OLS" "1 IV" "QOB IV") ///
   b(4) se(4) stats(r2 N, fmt(%4.3f %9.0fc) labels("R^2" "N")) ///
   coeflabels(_cons Constant educ "Years of Education") ///
   order(_cons educ) ///
   indicate("Birth Year Effects = *.yob") ///
   nonotes addnotes("Standard errors in parentheses." "Data source: 1980 Census.")

  * tex version
  esttab ols wald qob_iv using results/Exercise_5_table_a_readman.tex, replace ///
   b(4) se(4) stats(r2 N, fmt(%4.3f %9.0fc) labels("\$R^2\$" "\$N\$")) ///
   nodepvars nostar obslast nobaselevels varwidth(24) ///
   alignment(D{.}{.}{-1}) ///
   title("Least-Squares Estimates of the log-Wage Regression") ///
   mtitles("OLS" "1 IV" "QOB IV") ///
   coeflabels(_cons Constant educ "Years of education") ///
   order(_cons educ) ///
   indicate("Birth Year Effects = *.yob", labels(\checkmark \text{})) ///
   nonotes addnotes("Standard errors in parentheses." "Data source: 1980 Census.")
*** end part e

* part f: Reproducing Angrist and Krueger’s Table 6
  * stata version
  esttab column_1 column_2 column_3 column_4, ///
   order(educ *.yob ageq ageqsq) ///
   b(4) se(4) stats(r2, fmt(%4.3f) labels("R^2")) ///
   nodepvars nostar obslast nobaselevels varwidth(24) ///
   title("OLS and TSLS Estimates of the Return to Education for Men Born 1940-1949: 1980 Census") ///
   indicate("9 Year-of-birth dummies = *.yob") ///
   mtitles("OLS" "2SLS" "OLS" "2SLS") ///
   coeflabels(educ "Years of education" ageq "Age" ageqsq "Age-squared") ///
   nonotes addnotes("a. Standard errors in parentheses. Sample size is 486,926. Instruments are a full set of quarter-of-birth times year-of-birth interactions." ///
     "Sample consists of males born in the United States. The sample is drawn from the 5 percent samples of the 1980 Census." ///
     "The dependent variable is the log of weekly earnings. Age and age-squared are measured in quarters of years." ///
     "Each equation also includes an intercept.")

  * tex version //
  esttab column_1 column_2 column_3 column_4 using results/Exercise_5_table_b_readman.tex, replace ///
   order(_cons educ *.yob ageq ageqsq) ///
   b(4) se(4) stats(r2, fmt(%4.3f) labels("\$R^2\$")) ///
   nodepvars nostar obslast nobaselevels varwidth(24) alignment(D{.}{.}{-1}) ///
   title("OLS and TSLS Estimates of the Return to Education for Men Born 1940-1949: 1980 Census") ///
   indicate("9 Year-of-birth dummies = *.yob", labels(\text{yes} \text{no})) ///
   mtitles("OLS" "2SLS" "OLS" "2SLS") ///
   coeflabels(_cons Constant educ "Years of education" ageq "Age" ageqsq "Age-squared") ///
   nonotes addnotes("a. Standard errors in parentheses. Sample size is 486,926. Instruments are a full set of quarter-of-birth times year-of-birth interactions." ///
     "Sample consists of males born in the United States. The sample is drawn from the 5 percent samples of the 1980 Census." ///
     "The dependent variable is the log of weekly earnings. Age and age-squared are measured in quarters of years." ///
     "Each equation also includes an intercept.")
*** end part f

log close results   