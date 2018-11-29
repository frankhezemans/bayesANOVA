# bayesANOVA

Code in support of talk presented at the [MRC CBU Methods Day](http://imaging.mrc-cbu.cam.ac.uk/methods/MethodsDaySchedule), titled *Going beyond ANOVA: Bayesian linear mixed models in R*.

## Dependencies

The model fitting is performed by `RStan`, which is an [R](https://www.r-project.org) interface to the [Stan](http://mc-stan.org) programming language. If you have never used the `RStan` package before, check out the [quick start guide](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started).

The R packages needed to run the analysis are installed and loaded as needed in the main analysis script, `analysis.R`, using my function `packages.R`.

I ran the analysis on a macOS 10.14 machine with R version 3.4.3 and RStan version 2.17.3. I haven't tried it on another system so I can't guarantee that everything will run perfectly on your system.
