* Creating index-value correspondence dataset
* Author: LIMA, Gonçalo (goncalo.lima@novasbe.pt)

**************
* DIRECTORIES
**************
* OUTPUT DIRECTORIES
cd "D:\users\goncalo.lima" // Replace appropriately
cap mkdir misi_cleaning // Creating project's folder
cd "D:\users\goncalo.lima\misi_cleaning" // Setting the working directory
cap mkdir datasets // Creating folder to save datasets
global wd "D:\users\goncalo.lima\misi_cleaning" // Setting main work directory global
global data "$wd\datasets" // Setting datasets directory global

* INPUT DIRECTORIES
global misi "D:\data-anon\18.01\misi-pub"
global eneb "D:\data-anon\18.01\eneb"
global enes "D:\data-anon\18.01\enes"
global priv "D:\data-anon\18.01\misi-priv"
global inqpriv "D:\data-anon\18.01\inq-priv"
global personnel "D:\data-anon\18.01\misi-pub-pessoal"
global feeder "$wd/feeder_data"

global personnel_labels "D:\data-anon\18.01\misi-pub-pessoal\doc"
global labels "D:\data-anon\18.01\misi-pub\doc"

**************
* PACKAGES
**************
ssc install workdays

* Setting the structure of the dataset
set obs 429

gen indice = .
gen anoletivo_1 = .
gen anoletivo_2 = .
forvalues i=1/33 {
 forvalues j=1/13 {
	replace indice = `i' if _n == 33*(`j'-1) + `i'
	replace anoletivo_1 = (`j' + 2005) - 2000 if _n == 33*(`j'-1) + `i'
	replace anoletivo_2 = (`j' + 2006) - 2000 if _n == 33*(`j'-1) + `i'
	}
}
gen anoletivo = "."
replace anoletivo = string(anoletivo_1)+"0"+string(anoletivo_2) ///
	if anoletivo_2 <= 9
replace anoletivo = string(anoletivo_1)+string(anoletivo_2) ///
	if anoletivo_2 >= 10
destring anoletivo, replace
drop anoletivo_1 anoletivo_2
order anoletivo indice
gen year = int(anoletivo/100)+2000
label var year "Year"

* Importing correspondance of index numbers
preserve
clear
cd $personnel_labels
import excel Tabelas_Pessoal2011_2012_16Novembro, sheet("Indice_PD") cellrange(A2:B144) clear
rename A indice
destring indice, replace
rename B index

tempfile index
save `index'
restore

merge m:1 indice using `index', gen(_merge_index)
drop if _merge_index == 2
drop _merge_index

destring index, replace
sort anoletivo indice
label var index "Pay index"

* Setting Index-100 value
gen i_100 = .
replace i_100 = 909.36 if year >= 2009
replace i_100 = 883.73 if year == 2008
replace i_100 = 865.55 if year == 2007
replace i_100 = 852.76 if year == 2006
label var i_100 "Index 100"

* Setting expected monthly pay, given index
gen index_pay = .
replace index_pay = i_100*index / 100
label var index_pay "Base pay according to index"

* Setting daily meal subsidy
gen meal_sub = .
replace meal_sub = 3.83 if year == 2006
replace meal_sub = 3.95 if year == 2007
replace meal_sub = 4.03 if year == 2008
replace meal_sub = 4.11 if year == 2009
replace meal_sub = 4.27 if (year >= 2010 & anoletivo <= 2016)
replace meal_sub = 4.52 if year == 2017
replace meal_sub = 4.77 if year == 2018
label var meal_sub "Daily meal subsidy"

* Setting number of actually received months
gen months_pay = .
replace months_pay = 14 if year <= 2010 | year >= 2013
replace months_pay = 13.5 if year == 2011
replace months_pay = 12 if year == 2012
label var months_pay "Number of monthly salaries during year"

* Pay changes
gen pay_change = 0

** Salary cuts (2011-2013)
replace pay_change = -18.63 if year >= 2011 & year <= 2013 & index == 167
replace pay_change = -59.83 if year >= 2011 & year <= 2013 & index == 188
replace pay_change = -65.25 if year >= 2011 & year <= 2013 & index == 205
replace pay_change = -69.38 if year >= 2011 & year <= 2013 & index == 218
replace pay_change = -74.46 if year >= 2011 & year <= 2013 & index == 223
replace pay_change = -91.92 if year >= 2011 & year <= 2013 & index == 235
replace pay_change = -106.47 if year >= 2011 & year <= 2013 & index == 245
replace pay_change = -145.85 if year >= 2011 & year <= 2013 & index == 272
replace pay_change = -185.03 if year >= 2011 & year <= 2013 & index == 299
replace pay_change = -244.69 if year >= 2011 & year <= 2013 & index == 340
replace pay_change = -288.34 if year >= 2011 & year <= 2013 & index == 370

** Salary cuts (2014)
replace pay_change = -28.03 if year == 2014 & index == 89
replace pay_change = -50.55 if year == 2014 & index == 112
replace pay_change = -67.32 if year == 2014 & index == 126
replace pay_change = -103.06 if year == 2014 & index == 151
replace pay_change = -129.82 if year == 2014 & index == 167
replace pay_change = -169.55 if year == 2014 & index == 188
replace pay_change = -205.55 if year == 2014 & index == 205
replace pay_change = -235.39 if year == 2014 & index == 218
replace pay_change = -243.34 if year == 2014 & index == 223
replace pay_change = -256.44 if year == 2014 & index == 235
replace pay_change = -267.35 if year == 2014 & index == 245
replace pay_change = -296.92 if year == 2014 & index == 272
replace pay_change = -326.27 if year == 2014 & index == 299
replace pay_change = -371.02 if year == 2014 & index == 340
replace pay_change = -403.42 if year == 2014 & index == 370

** Salary cuts (2015)
replace pay_change = -18.63 if year == 2015 & index == 167
replace pay_change = -47.86 if year == 2015 & index == 188
replace pay_change = -52.2 if year == 2015 & index == 205
replace pay_change = -55.51 if year == 2015 & index == 218
replace pay_change = -56.78 if year == 2015 & index == 223
replace pay_change = -73.54 if year == 2015 & index == 235
replace pay_change = -85.18 if year == 2015 & index == 245
replace pay_change = -116.70 if year == 2015 & index == 272
replace pay_change = -148.02 if year == 2015 & index == 299
replace pay_change = -195.75 if year == 2015 & index == 340
replace pay_change = -230.33 if year == 2015 & index == 370

** Salary cuts quarterly reversion (2016) 
replace pay_change = -18.63 + 18.63*(0*0.5 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 167
replace pay_change = -47.86 + 47.86*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 188
replace pay_change = -52.2 + 52.20*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 205
replace pay_change = -55.51 + 55.51*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 218
replace pay_change = -56.78 + 56.78*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 223
replace pay_change = -73.54 + 73.54*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 235
replace pay_change = -85.18 + 85.18*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 245
replace pay_change = -116.70 + 116.70*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 272
replace pay_change = -148.02 + 148.02*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 299
replace pay_change = -195.75 + 195.75*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 340
replace pay_change = -230.33 + 230.33*(0.4*0.25 + 0.6*0.25 + 0.8*0.25 + 1*0.25) ///
	if year == 2016 & index == 370
	
label var pay_change "Temporary pay change"

* Number of work days in each year
gen year_start = .
gen year_end = .
qui levelsof year, local(years)
foreach x of local years{
		replace year_start = mdy(1,1,`x') if year == `x'
		replace year_end = mdy(12,31,`x') if year == `x'
}
workdays year_start year_end, gen(days_worked)
drop year_start year_end
label var days_worked "Number of days worked in the year"

* Expected annual and monthly pay
gen exp_paya = (index_pay + pay_change)*months_pay + meal_sub*days_worked 
gen exp_paym = exp_paya/12
label var exp_paya "Expected annual gross salary"
label var exp_paym "Expected monthly gross salary"

* IRS rates
gen irs_lb = .
gen irs_ub = .
gen irs = .

// Index 89
replace irs_lb = 0.00 if year == 2006 & index == 89
replace irs_ub = 0.075 if year == 2006 & index == 89
replace irs = 0.065 if year == 2006 & index == 89

replace irs_lb = 0.00 if year == 2007 & index == 89
replace irs_ub = 0.065 if year == 2007 & index == 89
replace irs = 0.055 if year == 2007 & index == 89

replace irs_lb = 0.00 if (year == 2008 | year == 2009) & index == 89
replace irs_ub = 0.06 if (year == 2008 | year == 2009) & index == 89
replace irs = 0.05 if (year == 2008 | year == 2009) & index == 89

replace irs_lb = 0.00 if (year == 2010 | year == 2011) & index == 89
replace irs_ub = 0.06 if (year == 2010 | year == 2011) & index == 89
replace irs = 0.05 if (year == 2010 | year == 2011)& index == 89

replace irs_lb = 0.01 if year == 2012 & index == 89
replace irs_ub = 0.065 if year == 2012 & index == 89
replace irs = 0.055 if year == 2012 & index == 89

replace irs_lb = 0.005 if year == 2013 & index == 89
replace irs_ub = 0.085 if year == 2013 & index == 89
replace irs = 0.075 if year == 2013 & index == 89

replace irs_lb = 0.01 if year == 2014 & index == 89
replace irs_ub = 0.085 if year == 2014 & index == 89
replace irs = 0.075 if year == 2014 & index == 89

replace irs_lb = 0.00 if (year == 2015 | year == 2016) & index == 89
replace irs_ub = 0.11 if (year == 2015 | year == 2016) & index == 89
replace irs = 0.091 if (year == 2015 | year == 2016) & index == 89

replace irs_lb = 0.00 if year == 2017 & index == 89
replace irs_ub = 0.085 if year == 2017 & index == 89
replace irs = 0.056 if year == 2017 & index == 89

replace irs_lb = 0.00 if year == 2018 & index == 89
replace irs_ub = 0.084 if year == 2018 & index == 89
replace irs = 0.055 if year == 2018 & index == 89

// Index 99
replace irs_lb = 0.00 if (year == 2006 | year == 2007) & index == 99
replace irs_ub = 0.075 if (year == 2006 | year == 2007) & index == 99
replace irs = 0.065 if (year == 2006 | year == 2007) & index == 99

replace irs_lb = 0.00 if (year == 2008 | year == 2009) & index == 99
replace irs_ub = 0.07 if (year == 2008 | year == 2009) & index == 99
replace irs = 0.06 if (year == 2008 | year == 2009) & index == 99

// Index 112
replace irs_lb = 0.005 if year == 2006 & index == 112
replace irs_ub = 0.095 if year == 2006 & index == 112
replace irs = 0.085 if year == 2006 & index == 112

replace irs_lb = 0.005 if year == 2007 & index == 112
replace irs_ub = 0.085 if year == 2007 & index == 112
replace irs = 0.085 if year == 2007 & index == 112

replace irs_lb = 0.00 if (year == 2008 | year == 2009) & index == 112
replace irs_ub = 0.08 if (year == 2008 | year == 2009)  & index == 112
replace irs = 0.07 if (year == 2008 | year == 2009)  & index == 112

replace irs_lb = 0.00 if (year == 2010 | year == 2011 | year == 2012) & index == 112
replace irs_ub = 0.09 if (year == 2010 | year == 2011 | year == 2012) & index == 112
replace irs = 0.08 if (year == 2010 | year == 2011 | year == 2012) & index == 112

replace irs_lb = 0.02 if year == 2013 & index == 112
replace irs_ub = 0.135 if year == 2013 & index == 112
replace irs = 0.115 if year == 2013 & index == 112

replace irs_lb = 0.05 if year == 2014 & index == 112
replace irs_ub = 0.125 if year == 2014 & index == 112
replace irs = 0.115 if year == 2014 & index == 112

replace irs_lb = 0.023 if (year == 2015 | year == 2016) & index == 112
replace irs_ub = 0.135 if (year == 2015 | year == 2016) & index == 112
replace irs = 0.116 if (year == 2015 | year == 2016) & index == 112

replace irs_lb = 0.013 if year == 2017 & index == 112
replace irs_ub = 0.135 if year == 2017 & index == 112
replace irs = 0.106 if year == 2017 & index == 112

replace irs_lb = 0.012 if year == 2018 & index == 112
replace irs_ub = 0.127 if year == 2018 & index == 112
replace irs = 0.10 if year == 2018 & index == 112

// Index 125 - Previous Career Stage 2 (2006) / Index 126
replace irs_lb = 0.025 if (year == 2006 | year == 2007) & (index == 125 | index == 126)
replace irs_ub = 0.115 if (year == 2006 | year == 2007) & (index == 125 | index == 126)
replace irs = 0.115 if (year == 2006 | year == 2007) & (index == 125 | index == 126)

replace irs_lb = 0.02 if (year == 2008 | year == 2009) & (index == 125 | index == 126)
replace irs_ub = 0.10 if (year == 2008 | year == 2009) & (index == 125 | index == 126)
replace irs = 0.09 if (year == 2008 | year == 2009) & (index == 125 | index == 126)

replace irs_lb = 0.02 if (year == 2010 | year == 2011) & (index == 125 | index == 126)
replace irs_ub = 0.11 if (year == 2010 | year == 2011) & (index == 125 | index == 126)
replace irs = 0.10 if (year == 2010 | year == 2011) & (index == 125 | index == 126)

replace irs_lb = 0.01 if year == 2012 & index == 126
replace irs_ub = 0.10 if year == 2012 & index == 126
replace irs = 0.09 if year == 2012 & index == 126

replace irs_lb = 0.02 if year == 2013 & index == 126
replace irs_ub = 0.145 if year == 2013 & index == 126
replace irs = 0.135 if year == 2013 & index == 126

replace irs_lb = 0.06 if year == 2014 & index == 126
replace irs_ub = 0.145 if year == 2014 & index == 126
replace irs = 0.134 if year == 2014 & index == 126

replace irs_lb = 0.033 if (year == 2015 | year == 2016) & index == 126
replace irs_ub = 0.175 if (year == 2015 | year == 2016) & index == 126
replace irs = 0.166 if (year == 2015 | year == 2016) & index == 126

replace irs_lb = 0.023 if year == 2017 & index == 126
replace irs_ub = 0.155 if year == 2017 & index == 126
replace irs = 0.137 if year == 2017 & index == 126

replace irs_lb = 0.022 if year == 2018 & index == 126
replace irs_ub = 0.148 if year == 2018 & index == 126
replace irs = 0.131 if year == 2018 & index == 126

// Index 136
replace irs_lb = 0.045 if year == 2006 & index == 136
replace irs_ub = 0.115 if year == 2006  & index == 136
replace irs = 0.115 if year == 2006 & index == 136

replace irs_lb = 0.045 if year == 2007 & index == 136
replace irs_ub = 0.125 if year == 2007  & index == 136
replace irs = 0.125 if year == 2007 & index == 136

replace irs_lb = 0.04 if (year == 2008 | year == 2009) & index == 136
replace irs_ub = 0.11 if (year == 2008 | year == 2009)  & index == 136
replace irs = 0.11 if (year == 2008 | year == 2009) & index == 136

// Index 151 - Previous Career Stage 3 (2006)
replace irs_lb = 0.055 if (year == 2006 | year == 2007) & index == 151
replace irs_ub = 0.135 if (year == 2006 | year == 2007)  & index == 151
replace irs = 0.135 if (year == 2006 | year == 2007) & index == 151

replace irs_lb = 0.05 if (year == 2008 | year == 2009) & index == 151
replace irs_ub = 0.12 if (year == 2008 | year == 2009)  & index == 151
replace irs = 0.12 if (year == 2008 | year == 2009) & index == 151

replace irs_lb = 0.05 if (year == 2010 | year == 2011) & index == 151
replace irs_ub = 0.13 if (year == 2010 | year == 2011)  & index == 151
replace irs = 0.13 if (year == 2010 | year == 2011) & index == 151

replace irs_lb = 0.03 if year == 2012 & index == 151
replace irs_ub = 0.12 if year == 2012  & index == 151
replace irs = 0.11 if year == 2012 & index == 151

replace irs_lb = 0.065 if year == 2013 & index == 151
replace irs_ub = 0.165 if year == 2013  & index == 151
replace irs = 0.165 if year == 2013 & index == 151

replace irs_lb = 0.075 if year == 2014 & index == 151
replace irs_ub = 0.165 if year == 2014 & index == 151
replace irs = 0.165 if year == 2014 & index == 151

replace irs_lb = 0.033 if (year == 2015 | year == 2016) & index == 151
replace irs_ub = 0.175 if (year == 2015 | year == 2016) & index == 151
replace irs = 0.166 if (year == 2015 | year == 2016) & index == 151

replace irs_lb = 0.048 if year == 2017 & index == 151
replace irs_ub = 0.175 if year == 2017 & index == 151
replace irs = 0.167 if year == 2017 & index == 151

replace irs_lb = 0.046 if year == 2018 & index == 151
replace irs_ub = 0.169 if year == 2018 & index == 151
replace irs = 0.161 if year == 2018 & index == 151

// Index 156
replace irs_lb = 0.055 if (year == 2006 | year == 2007) & index == 156
replace irs_ub = 0.135 if (year == 2006 | year == 2007)  & index == 156
replace irs = 0.135 if (year == 2006 | year == 2007) & index == 156

replace irs_lb = 0.05 if (year == 2008 | year == 2009) & index == 156
replace irs_ub = 0.13 if (year == 2008 | year == 2009)  & index == 156
replace irs = 0.13 if (year == 2008 | year == 2009) & index == 156

// Index 167 - Career Stage 1
replace irs_lb = 0.055 if (year == 2006 | year == 2007) & index == 167
replace irs_ub = 0.145 if (year == 2006 | year == 2007)  & index == 167
replace irs = 0.145 if (year == 2006 | year == 2007) & index == 167

replace irs_lb = 0.05 if (year == 2008 | year == 2009) & index == 167
replace irs_ub = 0.13 if (year == 2008 | year == 2009)  & index == 167
replace irs = 0.13 if (year == 2008 | year == 2009) & index == 167

replace irs_lb = 0.06 if (year == 2010 | year == 2011) & index == 167
replace irs_ub = 0.14 if (year == 2010 | year == 2011)  & index == 167
replace irs = 0.14 if (year == 2010 | year == 2011) & index == 167

replace irs_lb = 0.05 if year == 2012 & index == 167
replace irs_ub = 0.13 if year == 2012 & index == 167
replace irs = 0.13 if year == 2012 & index == 167

replace irs_lb = 0.075 if (year == 2013 | year == 2014) & index == 167
replace irs_ub = 0.175 if (year == 2013 | year == 2014) & index == 167
replace irs = 0.175 if (year == 2013 | year == 2014) & index == 167

replace irs_lb = 0.068 if (year == 2015 | year == 2016) & index == 167
replace irs_ub = 0.185 if (year == 2015 | year == 2016) & index == 167
replace irs = 0.176 if (year == 2015 | year == 2016) & index == 167

replace irs_lb = 0.068 if year == 2017 & index == 167
replace irs_ub = 0.185 if year == 2017 & index == 167
replace irs = 0.177 if year == 2017 & index == 167

replace irs_lb = 0.066 if year == 2018 & index == 167
replace irs_ub = 0.18 if year == 2018 & index == 167
replace irs = 0.172 if year == 2018 & index == 167

// Index 188 - Career Stage 2
replace irs_lb = 0.085 if (year == 2006 | year == 2007) & index == 188
replace irs_ub = 0.155 if (year == 2006 | year == 2007)  & index == 188
replace irs = 0.155 if (year == 2006 | year == 2007) & index == 188

replace irs_lb = 0.08 if (year == 2008 | year == 2009) & index == 188
replace irs_ub = 0.15 if (year == 2008 | year == 2009)  & index == 188
replace irs = 0.15 if (year == 2008 | year == 2009) & index == 188

replace irs_lb = 0.11 if year == 2010 & index == 188
replace irs_ub = 0.165 if year == 2010 & index == 188
replace irs = 0.165 if year == 2010 & index == 188

replace irs_lb = 0.10 if year == 2011 & index == 188
replace irs_ub = 0.155 if year == 2011 & index == 188
replace irs = 0.155 if year == 2011 & index == 188

replace irs_lb = 0.06 if year == 2012 & index == 188
replace irs_ub = 0.15 if year == 2012 & index == 188
replace irs = 0.15 if year == 2012 & index == 188

replace irs_lb = 0.075 if year == 2013 & index == 188
replace irs_ub = 0.185 if year == 2013 & index == 188
replace irs = 0.185 if year == 2013 & index == 188

replace irs_lb = 0.11 if year == 2014 & index == 188
replace irs_ub = 0.2 if year == 2014 & index == 188
replace irs = 0.2 if year == 2014 & index == 188

replace irs_lb = 0.083 if (year == 2015 | year == 2016) & index == 188
replace irs_ub = 0.2 if (year == 2015 | year == 2016) & index == 188
replace irs = 0.191 if (year == 2015 | year == 2016) & index == 188

replace irs_lb = 0.083 if year == 2017 & index == 188
replace irs_ub = 0.215 if year == 2017 & index == 188
replace irs = 0.208 if year == 2017 & index == 188

replace irs_lb = 0.081 if year == 2018 & index == 188
replace irs_ub = 0.209 if year == 2018 & index == 188
replace irs = 0.203 if year == 2018 & index == 188

// Index 205 - Career Stage 3
replace irs_lb = 0.095 if (year == 2006 | year == 2007) & index == 205
replace irs_ub = 0.175 if (year == 2006 | year == 2007)  & index == 205
replace irs = 0.175 if (year == 2006 | year == 2007) & index == 205

replace irs_lb = 0.09 if (year == 2008 | year == 2009) & index == 205
replace irs_ub = 0.16 if (year == 2008 | year == 2009)  & index == 205
replace irs = 0.16 if (year == 2008 | year == 2009) & index == 205

replace irs_lb = 0.1 if year == 2010 & index == 205
replace irs_ub = 0.175 if year == 2010 & index == 205
replace irs = 0.175 if year == 2010 & index == 205

replace irs_lb = 0.1 if year == 2011 & index == 205
replace irs_ub = 0.165 if year == 2011 & index == 205
replace irs = 0.165 if year == 2011 & index == 205

replace irs_lb = 0.06 if year == 2012 & index == 205
replace irs_ub = 0.165 if year == 2012 & index == 205
replace irs = 0.165 if year == 2012 & index == 205

replace irs_lb = 0.1 if year == 2013 & index == 205
replace irs_ub = 0.2 if year == 2013 & index == 205
replace irs = 0.2 if year == 2013 & index == 205

replace irs_lb = 0.11 if year == 2014 & index == 205
replace irs_ub = 0.2 if year == 2014 & index == 205
replace irs = 0.2 if year == 2014 & index == 205

replace irs_lb = 0.096 if (year == 2015 | year == 2016) & index == 205
replace irs_ub = 0.215 if (year == 2015 | year == 2016) & index == 205
replace irs = 0.207 if (year == 2015 | year == 2016) & index == 205

replace irs_lb = 0.107 if year == 2017 & index == 205
replace irs_ub = 0.225 if year == 2017 & index == 205
replace irs = 0.22 if year == 2017 & index == 205

replace irs_lb = 0.104 if year == 2018 & index == 205
replace irs_ub = 0.219 if year == 2018 & index == 205
replace irs = 0.214 if year == 2018 & index == 205

// Index 218 - Career Stage 4
replace irs_lb = 0.105 if (year == 2006 | year == 2007) & index == 218
replace irs_ub = 0.185 if (year == 2006 | year == 2007)  & index == 218
replace irs = 0.185 if (year == 2006 | year == 2007) & index == 218

replace irs_lb = 0.10 if (year == 2008 | year == 2009) & index == 218
replace irs_ub = 0.17 if (year == 2008 | year == 2009)  & index == 218
replace irs = 0.17 if (year == 2008 | year == 2009) & index == 218

replace irs_lb = 0.11 if year == 2010 & index == 218 
replace irs_ub = 0.185 if year == 2010 & index == 218 
replace irs = 0.185 if year == 2010 & index == 218

replace irs_lb = 0.10 if year == 2011 & index == 218 
replace irs_ub = 0.175 if year == 2011 & index == 218 
replace irs = 0.175 if year == 2011 & index == 218

replace irs_lb = 0.085 if year == 2012 & index == 218 
replace irs_ub = 0.165 if year == 2012 & index == 218 
replace irs = 0.165 if year == 2012 & index == 218

replace irs_lb = 0.12 if (year == 2013 | year == 2014) & index == 218 
replace irs_ub = 0.215 if (year == 2013 | year == 2014) & index == 218 
replace irs = 0.215 if (year == 2013 | year == 2014) & index == 218

replace irs_lb = 0.106 if (year == 2015 | year == 2016) & index == 218
replace irs_ub = 0.225 if (year == 2015 | year == 2016) & index == 218
replace irs = 0.217 if (year == 2015 | year == 2016) & index == 218

replace irs_lb = 0.107 if year == 2017 & index == 218
replace irs_ub = 0.235 if year == 2017 & index == 218
replace irs = 0.23 if year == 2017 & index == 218

replace irs_lb = 0.104 if year == 2018 & index == 218
replace irs_ub = 0.229 if year == 2018 & index == 218
replace irs = 0.224 if year == 2018 & index == 218

// Index 223 - Previous Career Stage 7, Lvl 2
replace irs_lb = 0.105 if (year == 2006 | year == 2007) & index == 223
replace irs_ub = 0.185 if (year == 2006 | year == 2007)  & index == 223
replace irs = 0.185 if (year == 2006 | year == 2007) & index == 223

replace irs_lb = 0.10 if (year == 2008 | year == 2009) & index == 223
replace irs_ub = 0.17 if (year == 2008 | year == 2009)  & index == 223
replace irs = 0.17 if (year == 2008 | year == 2009) & index == 223

*** No info for years 2010 and 2011, index 223, yet

replace irs_lb = 0.085 if year == 2012 & index == 223
replace irs_ub = 0.165 if year == 2012 & index == 223
replace irs = 0.165 if year == 2012 & index == 223

replace irs_lb = 0.11 if (year == 2013 | year == 2014) & index == 223
replace irs_ub = 0.215 if (year == 2013 | year == 2014) & index == 223
replace irs = 0.215 if (year == 2013 | year == 2014) & index == 223

replace irs_lb = 0.116 if (year == 2015 | year == 2016) & index == 223
replace irs_ub = 0.235 if (year == 2015 | year == 2016) & index == 223
replace irs = 0.227 if (year == 2015 | year == 2016) & index == 223

replace irs_lb = 0.117 if year == 2017 & index == 223
replace irs_ub = 0.235 if year == 2017 & index == 223
replace irs = 0.23 if year == 2017 & index == 223

replace irs_lb = 0.114 if year == 2018 & index == 223
replace irs_ub = 0.229 if year == 2018 & index == 223
replace irs = 0.224 if year == 2018 & index == 223

// Index 235 - Career Stage 5
replace irs_lb = 0.115 if (year == 2006 | year == 2007) & index == 235
replace irs_ub = 0.195 if (year == 2006 | year == 2007)  & index == 235
replace irs = 0.195 if (year == 2006 | year == 2007) & index == 235

replace irs_lb = 0.11 if (year == 2008 | year == 2009) & index == 235
replace irs_ub = 0.18 if (year == 2008 | year == 2009)  & index == 235
replace irs = 0.18 if (year == 2008 | year == 2009) & index == 235

replace irs_lb = 0.115 if year == 2010 & index == 235
replace irs_ub = 0.195 if year == 2010  & index == 235
replace irs = 0.195 if year == 2010 & index == 235

replace irs_lb = 0.105 if year == 2011 & index == 235
replace irs_ub = 0.185 if year == 2011  & index == 235
replace irs = 0.185 if year == 2011 & index == 235

replace irs_lb = 0.095 if year == 2012 & index == 235
replace irs_ub = 0.18 if year == 2012  & index == 235
replace irs = 0.18 if year == 2012 & index == 235

replace irs_lb = 0.12 if (year == 2013 | year == 2014) & index == 235
replace irs_ub = 0.225 if (year == 2013 | year == 2014) & index == 235
replace irs = 0.225 if (year == 2013 | year == 2014) & index == 235

replace irs_lb = 0.116 if (year == 2015 | year == 2016) & index == 235
replace irs_ub = 0.245 if (year == 2015 | year == 2016) & index == 235
replace irs = 0.237 if (year == 2015 | year == 2016) & index == 235

replace irs_lb = 0.117 if year == 2017 & index == 235
replace irs_ub = 0.245 if year == 2017 & index == 235
replace irs = 0.24 if year == 2017 & index == 235

replace irs_lb = 0.114 if year == 2018 & index == 235
replace irs_ub = 0.239 if year == 2018 & index == 235
replace irs = 0.234 if year == 2018 & index == 235

// Index 245 - Career Stage 6
replace irs_lb = 0.135 if year == 2006  & index == 245
replace irs_ub = 0.205 if year == 2006  & index == 245
replace irs = 0.205 if year == 2006 & index == 245

replace irs_lb = 0.115 if year == 2007  & index == 245
replace irs_ub = 0.195 if year == 2007  & index == 245
replace irs = 0.195 if year == 2007 & index == 245 

replace irs_lb = 0.11 if (year == 2008 | year == 2009) & index == 245
replace irs_ub = 0.19 if (year == 2008 | year == 2009)  & index == 245
replace irs = 0.19 if (year == 2008 | year == 2009) & index == 245

replace irs_lb = 0.12 if year == 2010 & index == 245
replace irs_ub = 0.205 if year == 2010 & index == 245
replace irs = 0.205 if year == 2010 & index == 245

replace irs_lb = 0.11 if year == 2011 & index == 245
replace irs_ub = 0.195 if year == 2011 & index == 245
replace irs = 0.195 if year == 2011 & index == 245

replace irs_lb = 0.095 if year == 2012 & index == 245
replace irs_ub = 0.18 if year == 2012 & index == 245
replace irs = 0.18 if year == 2012 & index == 245

replace irs_lb = 0.13 if (year == 2013 | year == 2014) & index == 245
replace irs_ub = 0.235 if (year == 2013 | year == 2014) & index == 245
replace irs = 0.235 if (year == 2013 | year == 2014) & index == 245

replace irs_lb = 0.126 if (year == 2015 | year == 2016) & index == 245
replace irs_ub = 0.245 if (year == 2015 | year == 2016) & index == 245
replace irs = 0.237 if (year == 2015 | year == 2016) & index == 245

replace irs_lb = 0.127 if year == 2017 & index == 245
replace irs_ub = 0.255 if year == 2017 & index == 245
replace irs = 0.25 if year == 2017 & index == 245

replace irs_lb = 0.124 if year == 2018 & index == 245
replace irs_ub = 0.249 if year == 2018 & index == 245
replace irs = 0.245 if year == 2018 & index == 245

// Index 272 - Career Stage 7
replace irs_lb = 0.12 if year == 2010 & index == 272
replace irs_ub = 0.215 if year == 2010 & index == 272
replace irs = 0.215 if year == 2010 & index == 272

replace irs_lb = 0.12 if year == 2011 & index == 272
replace irs_ub = 0.205 if year == 2011 & index == 272
replace irs = 0.205 if year == 2011 & index == 272

replace irs_lb = 0.115 if year == 2012 & index == 272
replace irs_ub = 0.20 if year == 2012 & index == 272
replace irs = 0.20 if year == 2012 & index == 272

replace irs_lb = 0.14 if (year == 2013 | year == 2014) & index == 272
replace irs_ub = 0.245 if (year == 2013 | year == 2014) & index == 272
replace irs = 0.245 if (year == 2013 | year == 2014) & index == 272

replace irs_lb = 0.148 if (year == 2015 | year == 2016) & index == 272
replace irs_ub = 0.265 if (year == 2015 | year == 2016) & index == 272
replace irs = 0.257 if (year == 2015 | year == 2016) & index == 272

replace irs_lb = 0.147 if year == 2017 & index == 272
replace irs_ub = 0.265 if year == 2017 & index == 272
replace irs = 0.26 if year == 2017 & index == 272

replace irs_lb = 0.144 if year == 2018 & index == 272
replace irs_ub = 0.26 if year == 2018 & index == 272
replace irs = 0.255 if year == 2018 & index == 272

// Index 299 - Career Stage 8
replace irs_lb = 0.145 if (year == 2006 | year == 2007) & index == 299
replace irs_ub = 0.225 if (year == 2006 | year == 2007)  & index == 299
replace irs = 0.225 if (year == 2006 | year == 2007) & index == 299

replace irs_lb = 0.14 if (year == 2008 | year == 2009) & index == 299
replace irs_ub = 0.22 if (year == 2008 | year == 2009)  & index == 299
replace irs = 0.22 if (year == 2008 | year == 2009) & index == 299

replace irs_lb = 0.145 if (year == 2010 | year == 2011) & index == 299
replace irs_ub = 0.225 if (year == 2010 | year == 2011) & index == 299
replace irs = 0.225 if (year == 2010 | year == 2011) & index == 299

replace irs_lb = 0.125 if year == 2012 & index == 299
replace irs_ub = 0.21 if year == 2012 & index == 299
replace irs = 0.21 if year == 2012 & index == 299

replace irs_lb = 0.16 if (year == 2013 | year == 2014) & index == 299
replace irs_ub = 0.265 if (year == 2013 | year == 2014) & index == 299
replace irs = 0.265 if (year == 2013 | year == 2014) & index == 299

replace irs_lb = 0.156 if (year == 2015 | year == 2016) & index == 299
replace irs_ub = 0.275 if (year == 2015 | year == 2016) & index == 299
replace irs = 0.267 if (year == 2015 | year == 2016) & index == 299

replace irs_lb = 0.157 if year == 2017 & index == 299
replace irs_ub = 0.275 if year == 2017 & index == 299
replace irs = 0.27 if year == 2017 & index == 299

replace irs_lb = 0.154 if year == 2018 & index == 299
replace irs_ub = 0.27 if year == 2018 & index == 299
replace irs = 0.265 if year == 2018 & index == 299

// Index 340 - Career Stage 9
replace irs_lb = 0.155 if (year == 2006 | year == 2007) & index == 340
replace irs_ub = 0.235 if (year == 2006 | year == 2007)  & index == 340
replace irs = 0.235 if (year == 2006 | year == 2007) & index == 340

replace irs_lb = 0.15 if (year == 2008 | year == 2009) & index == 340
replace irs_ub = 0.23 if (year == 2008 | year == 2009)  & index == 340
replace irs = 0.23 if (year == 2008 | year == 2009) & index == 340

replace irs_lb = 0.165 if year == 2010 & index == 340
replace irs_ub = 0.245 if year == 2010 & index == 340
replace irs = 0.245 if year == 2010 & index == 340

replace irs_lb = 0.155 if year == 2011 & index == 340
replace irs_ub = 0.235 if year == 2011 & index == 340
replace irs = 0.235 if year == 2011 & index == 340

replace irs_lb = 0.145 if year == 2012 & index == 340
replace irs_ub = 0.23 if year == 2012 & index == 340
replace irs = 0.23 if year == 2012 & index == 340

replace irs_lb = 0.17 if (year == 2013 | year == 2014) & index == 340
replace irs_ub = 0.275 if (year == 2013 | year == 2014) & index == 340
replace irs = 0.275 if (year == 2013 | year == 2014) & index == 340

replace irs_lb = 0.188 if (year == 2015 | year == 2016) & index == 340
replace irs_ub = 0.285 if (year == 2015 | year == 2016) & index == 340
replace irs = 0.277 if (year == 2015 | year == 2016) & index == 340

replace irs_lb = 0.189 if year == 2017 & index == 340
replace irs_ub = 0.285 if year == 2017 & index == 340
replace irs = 0.28 if year == 2017 & index == 340

replace irs_lb = 0.189 if year == 2018 & index == 340
replace irs_ub = 0.283 if year == 2018 & index == 340
replace irs = 0.278 if year == 2018 & index == 340


// Index 370 - Career Stage 10
replace irs_lb = 0.165 if (year == 2010 | year == 2011) & index == 370
replace irs_ub = 0.245 if (year == 2010 | year == 2011)& index == 370
replace irs = 0.245 if (year == 2010 | year == 2011) & index == 370

replace irs_lb = 0.155 if year == 2012 & index == 370
replace irs_ub = 0.24 if year == 2012 & index == 370
replace irs = 0.24 if year == 2012 & index == 370

replace irs_lb = 0.17 if (year == 2013 | year == 2014) & index == 370
replace irs_ub = 0.285 if (year == 2013 | year == 2014) & index == 370
replace irs = 0.285 if (year == 2013 | year == 2014) & index == 370

replace irs_lb = 0.188 if (year == 2015 | year == 2016) & index == 370
replace irs_ub = 0.295 if (year == 2015 | year == 2016) & index == 370
replace irs = 0.291 if (year == 2015 | year == 2016) & index == 370

replace irs_lb = 0.199 if year == 2017 & index == 370
replace irs_ub = 0.295 if year == 2017 & index == 370
replace irs = 0.294 if year == 2017 & index == 370

replace irs_lb = 0.199 if year == 2017 & index == 370
replace irs_ub = 0.295 if year == 2017 & index == 370
replace irs = 0.294 if year == 2017 & index == 370

label var irs_lb "IRS rate lower bound"
label var irs_ub "IRS rate upper bound"
label var irs "IRS rate (2 workers, 1 child)"

* IRS values
gen irs_value_lb = irs_lb*(index_pay + pay_change)
gen irs_value_ub = irs_ub*(index_pay + pay_change)
gen irs_value = irs*(index_pay + pay_change)

label var irs_value_lb "IRS value (lower bound)"
label var irs_value_ub "IRS value (upper bound)"
label var irs_value "IRS value (2 workers, 1 child)"

* ADSE rates
gen adse = .
replace adse = 0.01 if year == 2006
replace adse = 0.015 if year > 2006 & year < 2014
replace adse = 0.025 if year == 2014
replace adse = 0.035 if year >= 2015
label var adse "ADSE rate (health system discounts)"

* ADSE values
gen adse_value = adse *(index_pay + pay_change)
label var adse_value "ADSE value discounted"

* CGA rates
gen cga = .
replace cga = 0.1 if year < 2011
replace cga = 0.11 if year >= 2011
label var cga "Retirement discount rate"

* CGA values
gen cga_value = cga * (index_pay + pay_change)
label var cga_value "Retirement discounts (Social Security)"

* Minimum wage
gen min_wage = .
replace min_wage = 385.9 if year == 2006
replace min_wage = 403 if year == 2007
replace min_wage = 426 if year == 2008
replace min_wage = 450 if year == 2009
replace min_wage = 475 if year == 2010
replace min_wage = 485 if year >= 2011 & year <= 2014
replace min_wage = 505 if year == 2015
replace min_wage = 530 if year == 2016
replace min_wage = 557 if year == 2017
replace min_wage = 580 if year == 2018
label var min_wage "National minimum wage"

* Surcharges rates
gen surcharge = 0.00
replace surcharge = 0.035 if (year == 2014 | year == 2015 | year == 2016)
replace surcharge = 0.0175 if year == 2017 & (index_pay + pay_change) <= 3094
replace surcharge = 0.03 if year == 2017 & (index_pay + pay_change) > 3094 ///
	& (index_pay + pay_change) <= 5862
replace surcharge = 0.035 if year == 2017 & (index_pay + pay_change) > 5862
label var surcharge "Tax surcharge rate"

* Surcharge value
foreach x in _lb _ub "" {
gen surcharge_value`x' = ///
 (index_pay + pay_change - irs_value`x' - adse_value - cga_value - min_wage)*surcharge
}
label var surcharge_value "Tax surcharge value (2 workers, 1 child)"
label var surcharge_value_lb "Tax surcharge value (lower bound)"
label var surcharge_value_ub "Tax surcharge value (upper bound)"

* Net salary
foreach x in _lb _ub "" {
gen net_paym`x' = ///
	(exp_paya - irs_value`x' * months_pay ///
	- adse_value * months_pay ///
	- cga_value * months_pay ///
	- surcharge_value`x' * months_pay) / 12
}

label var net_paym "Monthly net salary (2 workers, 1 child)"
label var net_paym_lb "Monthly net salary (lower bound)"
label var net_paym_ub "Monthly net salary (upper bound)"

* Total retention rate
foreach x in _lb _ub "" {
gen retention_rate`x' = (exp_paym - net_paym`x')/exp_paym
}
label var retention_rate "Total retention rate (2 workers, 1 child)"
label var retention_rate_lb "Total retention rate (lower bound)"
label var retention_rate_ub "Total retention rate (upper bound)"

* Inflation rate
gen inf_rate =.
replace inf_rate = 0.031 if year == 2006
replace inf_rate = 0.025 if year == 2007
replace inf_rate = 0.026 if year == 2008
replace inf_rate = -0.008 if year == 2009
replace inf_rate = 0.014 if year == 2010
replace inf_rate = 0.037 if year == 2011
replace inf_rate = 0.028 if year == 2012
replace inf_rate = 0.003 if year == 2013
replace inf_rate = -0.003 if year == 2014
replace inf_rate = 0.005 if year == 2015
replace inf_rate = 0.006 if year == 2016
replace inf_rate = 0.014 if year == 2017
replace inf_rate = 0.01 if year == 2018
label var inf_rate "Inflation rate (Country average)"

* CPI (Base = 2006)
preserve
collapse (mean) inf_rate, by(year)

gen cpi = .
replace cpi = 100 if year == 2006
sort year
replace cpi = cpi[_n-1] + 100*inf_rate if year > 2006

tempfile cpi
save `cpi'
restore

merge m:1 year using `cpi'
drop _merge
label var cpi "Consumer Price Index (Base = 2006)"

* Real salary (2006 euros)
foreach x in _lb _ub "" {
gen real_paym`x' = ///
	net_paym`x' / cpi * 100
}
label var real_paym "Monthly real salary (2 workers, 1 child, 2006 euros)"
label var real_paym_lb "Monthly real salary (lower bound, 2006 euros)"
label var real_paym_ub "Monthly real salary (upper bound, 2006 euros)"

* Keeping the observations for which there are net salaries
keep if irs != . 

* Graphs
cd "D:\shared\joao_goncalo_pedro"

// Expected gross pay given index
scatter exp_paym year if index >= 167, connect(L) by(index) ///
	saving(exp_pay, replace)
	
// Real salary evolution (2006 euros) by pay index and minimum and maximum tax rates
preserve
keep if index >= 167
twoway scatter real_paym_lb year, connect(L) by(index) || ///
	scatter real_paym_ub year, connect(L) by(index) ///
	saving(real_paym, replace)
restore

* Rounding
foreach x in exp_paya exp_paym irs_value_lb irs_value_ub irs_value adse_value ///
	cga_value surcharge_value_lb surcharge_value_ub surcharge_value net_paym_lb ///
	net_paym_ub net_paym real_paym_lb real_paym_ub real_paym {
	replace `x' = round(`x', 0.01)
}

foreach x in retention_rate_lb retention_rate_ub retention_rate {
	replace `x' = round(`x', 0.001)
	}

* Saving
save index_pay, replace

