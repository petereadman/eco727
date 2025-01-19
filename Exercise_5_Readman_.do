capture log close
log using "Exercise_5_Readman_", smcl replace
//_1
use "../Data/Birth Quarter.dta" if cohort==4, clear
//_2
describe
tabulate census
assert census==80
assert _N==486926
//_3
generate ageqsq=ageq^2
tab qob
generate q1=1 if qob==1
replace  q1=0 if q1==.
tab q1
label variable q1 "quarter 1"
label variable ageqsq "age quarter squared"
describe
//_4
eststo wald:   ivregress 2sls lwklywge (educ = q1)
 estat firststage
eststo qob_iv: ivregress 2sls lwklywge (educ = ib4.qob) ib49.yob, first
 estat firststage
 estat overid
//_5
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
 estat firststage
 estat overid
eststo column_8: ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) i.race i.smsa i.married ib49.yob ib9.region ageq ageqsq // TSLS (8)
 estat firststage
 estat overid
//_6
estimates dir
//_7
esttab ols wald qob_iv, ///
 nodepvars nostar obslast nobaselevels varwidth(24) ///
 title("Least-Squares Estimates of the log-Wage Regression") ///
 mtitles("OLS" "1 IV" "QOB IV") ///
 b(4) se(4) stats(r2 N, fmt(%4.3f %9.0fc) labels("R^2" "N")) ///
 coeflabels(_cons Constant educ "Years of Education") ///
 order(_cons educ) ///
 indicate("Birth Year Effects = *.yob") ///
 nonotes addnotes("Standard errors in parentheses." "Data source: 1980 Census.")
//_8
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
//_9
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
//_10
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
//_^
log close
