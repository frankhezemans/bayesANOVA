#------
# Going beyond ANOVA: Bayesian linear mixed models in R
# Analysis script in support of talk presented at the Cambridge Methods Day, 4 December 2018
# Written by Frank H. Hezemans, MRC Cognition and Brain Sciences Unit, November 2018

#-----
# Starting up

# Make sure you've set your working directory correctly before running this next line
root <- getwd()

# Load support functions
functionfilenames <- list.files(path = paste0(root, "/functions"), full.names = TRUE)
sapply(functionfilenames, source) # apply the source() function to the list of filenames

# Load some general-purpose packages
packages(dplyr, ggplot2)

#-----
# Typical analysis approach

# Simulate data for a typical 2x2 within-subjects design
packages(MASS) # contains function for sampling from multivariate normal distribution
data <- factorialdata()

# illustrate the data
factorialplot <- myboxplot(data)

# perform ANOVA
packages(afex) # package for pain-free ANOVA
afex::aov_ez(
    data = data,
    id = "subject",
    dv = "time",
    within = c("coffee", "cake")
) # you should get significant main effects, but a p value of .06 for the interaction

#-----
# Bayesian Inference in the context of linear regression

packages(Bolstad) # contains function for Bayesian inference for simple linear regression
bayesregressionplot <- bayessimpleregression()

#-----
# Law of large numbers

# Specify if you want GIF animation or static image
animated <- FALSE
if (animated){
    packages(gganimate, magick) # for animated ggplots, and putting together GIFs
} else {
    packages(ggpubr) # for putting together ggplots
}

samplingplot <- lawlargenumbers(animation = animated)

#-----
# Fitting Bayesian linear mixed model with Stan

packages(rstan)

# Use contrast coding for the factors (see http://talklab.psy.gla.ac.uk/tvw/catpred/)
cleandata <- data
cleandata$coffee <- ifelse(cleandata$coffee == "b", 1, -1)
cleandata$cake <- ifelse(cleandata$cake == "b", 1, -1)
cleandata$interaction <- cleandata$coffee * cleandata$cake

# Make design matrix
X <- unname(model.matrix( ~ 1 + coffee + cake + interaction, cleandata))
attr(X, "assign") <- NULL

# Organise the data into a list object that our Stan code can understand
stanDat <- within(list(),
                  {
                      N <- nrow(X) # number of observations (rows) in the data frame
                      P <- n_u <- ncol(X) # number of parameters
                      X <- Z_u <- X # initialise the fixed- and random-effect parameters with the design matrix created above
                      J <- length(levels(cleandata$subject)) # number of subjects
                      y <- cleandata$time # dependent variable
                      subj <- as.integer(cleandata$subject) # subject indicator
                  }
)

# Fit the model
options(mc.cores = parallel::detectCores())
bayesModel <- rstan::stan(file = paste0(root, "/factorial_normal.stan"),
                          data = stanDat, iter = 4000, chains = 4)
print(bayesModel, pars = "beta", probs = c(0.025, 0.5, 0.975))

# Save the result (WARNING this is a relatively large file)
save(list = "bayesModel", file = paste0(root, "/bayesModel.Rda"), compress = "xz")

#-----
# Plot results

packages(bayesplot)

# Plot the results of our modelling
mytraceplot <- mytraceplot(bayesModel)

# Highlight the first few warmup iterations
mywarmuptraceplot <- mytraceplot(bayesModel, warmup = TRUE, window = c(0, 50))

# Plot the posterior densities
myposteriorplot <- posteriorplot(bayesModel)

# Add region of practical equivalence (ROPE)
myposteriorplotROPE <- posteriorplot(bayesModel, rope = TRUE, limits = c(-0.25, 0.25))
