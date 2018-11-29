#------
# Going beyond ANOVA: Bayesian linear mixed models in R
# Analysis script in support of talk presented at the Cambridge Methods Day, 4 December 2018
# Written by Frank H. Hezemans, MRC Cognition and Brain Sciences Unit, November 2018

#-----
# Starting up

# Set directory to location of current script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
root <- getwd()

# Load support functions
functionfilenames <- list.files(path = paste0(root, "/functions"))
sapply(functionfilenames, source) # apply the source() function to the list of filenames

# Load some general-purpose packages
packages(dplyr, ggplot2)

#-----
# Typical analysis approach

# Simulate data for a typical 2x2 within-subjects design
packages(MASS) # contains function for sampling from multivariate normal distribution
data <- factorialdata()

# perform ANOVA
packages(afex) # package for pain-free ANOVA
afex::aov_ez(
    data = data,
    id = "ID",
    dv = "time",
    within = c("coffee", "cake")
) # you should get significant main effects, but a p value of .06 for the interaction

# illustrate the data
myboxplot <- ggplot2::ggplot(data = data,
                             ggplot2::aes(x = coffee, y = time, colour = cake)) +
    ggplot2::geom_boxplot() +
    ggplot2::scale_colour_brewer(palette = "Dark2",
                                 labels = c("no cake", "cake")) +
    ggplot2::scale_x_discrete(labels = c("no coffee", "coffee")) +
    ggplot2::ylab("break time (minutes)") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
        axis.title.x = ggplot2::element_blank(),
        axis.title.y = ggplot2::element_text(size = 20),
        axis.text.x = ggplot2::element_text(size = 20, colour = "black"),
        legend.position = c(0.5, 0.9),
        legend.direction = "horizontal",
        legend.title = ggplot2::element_blank(),
        legend.text = ggplot2::element_text(size = 18),
        legend.box.background = ggplot2::element_rect(fill = "grey90", colour = "white"),
        text = element_text(family = "Arial Narrow")
    )

#-----
# Bayesian Inference in the context of linear regression

packages(Bolstad) # contains function for Bayesian inference for simple linear regression
bayesregressionplot <- bayessimpleregression()

#-----
# Law of large numbers

samplingplot <- lawlargenumbers() # add animation = TRUE as input argument if you want a GIF

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

packages(bayesplot, ggridges)

# Plot the results of our modelling
mytraceplot <- traceplot(bayesModel)

# Highlight the first few warmup iterations
mywarmuptraceplot <- traceplot(bayesModel, warmup = TRUE, window = c(0, 50))

# Plot the posterior densities
myposteriorplot <- posteriorplot(bayesModel)

# Add region of practical equivalence (ROPE)
myposteriorplotROPE <- posteriorplot(bayesModel, rope = TRUE, limits = c(-0.25, 0.25))




