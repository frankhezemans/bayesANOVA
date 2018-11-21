# Illustrate Bayesian inference in the context of simple linear regression
#-----
# Acknowledgement: Idea for plot came from Lionel Rigoux's talk at the 2018 Computational Psychiatry Course (ETH Zurich):
# https://www.video.ethz.ch/lectures/d-itet/2018/autumn/227-0971-00L/c2820ba3-882c-4910-8181-94471171a507.html
#-----
bayessimpleregression <- function(){

    require(Bolstad) # contains function to perform Bayesian inference for simple linear regression
    require(ggplot2) # grammar of graphics
    
    # Support functions
    #-----
    # retrieve list objects by name
    listfilter <- function(mylist, mynames){
        index <- which(names(mylist) %in% mynames)
        mylist[index]
    }
    
    # get values for desired percentages of cumulative density
    densityInterval <- function(x, probs, parameterdist){
        cumulativedensity <- cumsum(x)/sum(x)
        indices <- integer(length = length(probs))
        for (i in 1:length(probs)){
            indices[i] <- which(cumulativedensity >= probs[i])[1]
        }
        interval <- parameterdist[indices]
        return(interval)
    }
    
    # Define prior and simulate data
    #-----
    # parameters for prior
    priormean <- 0
    priorSD <- 1.5
    # parameters for data
    slope <- 5
    sigma <- 2 # SD of residuals
    nobs <- 20
    # sample from the normal distribution to create paired observations
    # for visualisation purposes, I want the intercept to be approximately zero, so that's why I'm using a repeat{...{break}} loop. But there might be a more elegant way of achieving this.
    set.seed(100)
    repeat{
        x <- rnorm(n = nobs, mean = 1, sd = 1/2)
        y <- rnorm(n = nobs, mean = slope*x, sd = sigma)
        intercept <- lm(y ~ x)$coefficients[1]
        if (!(abs(intercept) > 0.01)){break}
    }
    
    # Find the likelihood and posterior distributions of the linear regression slope
    #-----
    # the regression function automatically returns a plot which we're not interested in, so to suppress this we're opening and closing a bogus plot file around the function call
    ff <- tempfile()
    grDevices::png(filename = ff)
    # now we call the function (wrap it in capture.output() to suppress output to console)
    capture.output(bayesRegress <- Bolstad::bayes.lin.reg(y, x,
                                                          slope.prior = "normal", mb0 = priormean, sb0 = priorSD,
                                                          intcpt.prior = "flat", sigma = sigma))
    dev.off()
    unlink(ff)
    
    # extract range of values for slope
    slopes <- listfilter(bayesRegress$slope, mynames = "param.x")
    slopes <- unlist(slopes, use.names = FALSE)
    
    # extract likelihood and posterior distributions corresponding to the range of slopes
    densities <- listfilter(bayesRegress$slope, mynames = c("likelihood", "posterior"))
    
    # Illustrate range of slopes under the prior, likelihood and posterior distributions
    #-----
    # define the intervals of the distributions for which we want slope estimates
    myprobs <- seq(from = 0.05, to = 0.95, length.out = 7)
    
    # get slope estimates under the prior distribution
    priorslopes <- qnorm(myprobs, mean = priormean, sd = priorSD)
    # get slope estimates under the likelihood and posterior distributions
    estimates <- lapply(densities, densityInterval, probs = myprobs, parameterdist = slopes)
    
    # construct data frame so that it can be plotted
    data <- data.frame(distribution = rep(c("prior", "likelihood", "posterior"),
                                          each = length(myprobs)),
                       probability = rep(as.character(myprobs), times = 3),
                       estimates = c(priorslopes, unlist(estimates, use.names = FALSE)),
                       alpha = rep(c(0.1, 0.3, 0.7, 1, 0.7, 0.3, 0.1), times = 3), # transparency for plot: less likely estimates are more transparent
                       intercept = rep(0, times = 3*length(myprobs)),
                       stringsAsFactors = FALSE)
    data$distribution <- factor(myplotdata$distribution, levels = c("prior", "likelihood", "posterior")) # fix the order of the distributions
    data$probability <- as.factor(myplotdata$probability)
    
    # put the raw data (random pairs) in a separate dataframe, because we only need it for the likelihood plot
    rawdata <- data.frame(x = x, y = y,
                          distribution = factor("likelihood",
                                                levels = c("prior", "likelihood", "posterior")))
    
    # create the plot
    plot <- ggplot2::ggplot(data) +
        ggplot2::geom_point(data = rawdata, ggplot2::aes(x = x, y = y)) +
        ggplot2::geom_abline(ggplot2::aes(intercept = intercept,
                                          slope = estimates,
                                          alpha = alpha, colour = distribution)) +
        ggplot2::facet_wrap(~distribution) +
        ggplot2::scale_colour_brewer(palette = "Set2") +
        ggplot2::coord_cartesian(xlim = c(0, 2), ylim = c(-10, 10), expand = FALSE) +
        ggplot2::labs(x = "predictor", y = "response") +
        ggplot2::theme_minimal() +
        ggplot2::theme(legend.position = "none",
                       axis.title = ggplot2::element_text(size = 20),
                       strip.text.x = ggplot2::element_text(size = 20),
                       axis.text = ggplot2::element_text(size = 12),
                       panel.grid.minor = ggplot2::element_blank(),
                       text = ggplot2::element_text(family = "Arial Narrow"))
    return(plot)
}
