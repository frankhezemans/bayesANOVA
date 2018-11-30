# Going beyond ANOVA: Bayesian linear mixed models in R

Code in support of talk presented at the [MRC CBU Methods Day](http://imaging.mrc-cbu.cam.ac.uk/methods/MethodsDaySchedule). The main analysis and corresponding Stan code was taken from a tutorial paper by Sorensen, Hohenstein and Vasishth (click [here](http://dx.doi.org/10.20982/tqmp.12.3.p175) for the paper and [here](https://github.com/vasishth/BayesLMMTutorial) for the associated GitHub repository).

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

## Resources

Sorensen, T., Hohenstein, S., & Vasishth, S. (2016). Bayesian linear mixed models using Stan: A tutorial for psychologists, linguists, and cognitive scientists. *The Quantitative Methods for Psychology*, *12*(3), 175-200. doi: 10.20982/tqmp.12.3.p175

Kruschke, J. K., & Liddell, T. M. (2018). The Bayesian New Statistics: Hypothesis testing, estimation, meta-analysis, and power analysis from a Bayesian perspective. *Psychonomic Bulletin & Review*, *25*, 178-206. doi: 10.3758/s13423-016-1221-4

McElreath, R. (2015). Statistical Rethinking: A Bayesian course with examples in R and Stan. https://xcelab.net/rm/statistical-rethinking/

Lambert, B. (2018). A student's guide to Bayesian statistics. https://www.youtube.com/watch?v=P_og8H-VkIY&list=PLwJRxp3blEvZ8AKMXOy0fc0cqT61GsKCG

Kruschke, J. K. (2014). Doing Bayesian data analysis: A tutorial with R, JAGS and Stan. https://sites.google.com/site/doingbayesiandataanalysis/

van Ravenzwaaij, D., Cassey, P., & Brown, S. D. (2018). A simple introduction to Markov Chain Monte-Carlo sampling. *Psychonomic Bulletin & Review*, *25*, 143-154. doi: 10.3758/s13423-016-1015-8

Wagenmakers, EJ., Marsman, M., Jamil, T., Ly, A., Verhagen, J., Love, J., ... Morey, R. D. (2018). Bayesian inference for psychology. Part I: Theoretical advantages and practical ramifications. *Psychonomic Bulletin & Review*, *25*, 35-57. doi: 10.3758/s13423-017-1343-3

Colling, L. J., & Szűcs, D. (2018). Statistical inference and the replication crisis. *Review of Philosophy and Psychology*. doi: 10.1007/s13164-018-0421-4



