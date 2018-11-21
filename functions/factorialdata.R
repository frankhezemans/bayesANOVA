# Simulate data for a 2x2 full factorial within-subjects design
#-----
# Ackowledgement: Code adapted from:
# https://gist.github.com/gjkerns/1608265
# https://cognitivedatascientist.com/2015/12/14/power-simulation-in-r-the-repeated-measures-anova-5/
#-----
factorialdata <- function(){
    
    require(MASS) # for sampling from multivariate normal distribution
    
    # Define the parameters
    mu <- c(5, 10, 7, 12) # true effects: no coffee no cake; coffee no cake; no coffee with cake; coffee and cake
    sigma <- 2 # population standard deviation
    rho <- 0.75 # correlation between repeated measures
    nsubs <- 25
    
    # Initialise data frame
    data <- expand.grid(coffee = letters[1:2],
                        cake = letters[1:2],
                        subject = as.character(1:nsubs),
                        stringsAsFactors = TRUE)
    
    # Set up variance-covariance matrix
    # for simplicity we're assuming compound symmetry: all covariances are equal and all variances are equal (http://homepages.gold.ac.uk/aphome/spheric.html)
    mycov <- rep(sigma, length(mu)) %o% rep(1, length(mu)) # initialise 4x4 matrix with variance
    mycov <- mycov^2 * rho # covariance is variance squared multiplied by correlation (https://en.wikipedia.org/wiki/Covariance_and_correlation)
    diag(mycov) <- sigma^2 # diagonal is just variance
    
    # Given true means and covariance matrix, sample data from multivariate normal distribution
    set.seed(10) # for reproducibility
    outcome <- MASS::mvrnorm(n = nsubs, mu = mu, Sigma = mycov)
    # above returns a nsubs x 4 matrix, so we need to wrangle it into a vector and then we can add it as a column to the data frame
    data$time <- as.vector(t(outcome))
    
    return(data)
}