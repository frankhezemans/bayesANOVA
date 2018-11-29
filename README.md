# bayesANOVA

Code in support of talk presented at the [MRC CBU Methods Day](http://imaging.mrc-cbu.cam.ac.uk/methods/MethodsDaySchedule), titled: *Going beyond ANOVA: Bayesian linear mixed models in R*.

The main analysis and corresponding Stan code (`factorial_normal.stan`) was taken from a tutorial paper by Sorensen, Hohenstein and Vasishth (click [here](http://dx.doi.org/10.20982/tqmp.12.3.p175) for the paper and [here](https://github.com/vasishth/BayesLMMTutorial) for the associated GitHub repository).

This repository is organised as follows:
* `analysis.R` is the main analysis script that returns the desired output. If you're just interested in reproducing the results and figures from my presentation (without understanding the underlying code), this is all you really need to look at.
* `factorial_stan.R` is the Stan code for our linear mixed model, essentially copied from the last page of the Sorensen et al. paper. We call this code in the `analysis.R` script to fit the model via R.
* `functions`
    * `packages.R` installs and loads R packages
    * `factorialdata.R` simulates data for a typical 2x2 full factorial design
    * `bayessimpleregression.R` illustrates Bayesian inference in the context of a simple linear regression
    * `lawlargenumbers.R` illustrates the law of large numbers
    * `bayesplots.R` contains several functions to plot the results of the Bayesian model fitting

## Dependencies

The model fitting is performed by `RStan`, which is an [R](https://www.r-project.org) interface to the [Stan](http://mc-stan.org) programming language. If you've never used the `RStan` package before, check out the [quick start guide](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started).

The R packages needed to run the analysis are installed and loaded as needed in the main analysis script (`analysis.R`) using my function `packages.R`.

I ran the analysis on a macOS 10.14 machine with R version 3.4.3 and RStan version 2.17.3. I haven't tried it on another system so I can't guarantee that everything will run perfectly on your system.
