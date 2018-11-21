# Illustrate the law of large numbers by randomly sampling from a normal distribution
#-----
lawlargenumbers <- function(animation = FALSE, filename = NULL){
    
    # Check if required packages have actually been loaded
    #-----
    if (animation){
        require(gganimate) # create animated ggplots
        require(magick) # combine gifs into single plot
    } else {
        require(ggpubr) # for combining ggplot images into single plot
    }
    require(ggplot2) # grammar of graphics
    require(dplyr) # data organisation
    
    # Support functions
    #-----
    # Calculate cumulative ("expanding window") summary statistics
    cumulative <- function(data, fun = "mean"){
        n <- length(data)
        means <- cumsum(data)/(1:n)
        if (fun == "SD"){
            # code from https://stackoverflow.com/a/7475664
            means_shifted <- c(NA, means[1:(n-1)])
            ssd <- (data - means)*(data - means_shifted)
            v <- c(0, cumsum(ssd[-1])/(1:(n-1)))
            SD <- sqrt(v)
            return(SD)
        } else {
            return(means)
        }
    }
    
    # Get data to iteratively build up histogram
    cumulativeHist <- function(data, animation = FALSE){
        # First, get the final histogram
        finalhist <- hist(data$value, plot = FALSE)
        mybreaks <- finalhist$breaks
        nbins <- length(finalhist$counts)
        nsamples <- length(data$sample)
        # initialise dataframe
        histdat <- data.frame(
            sample = rep(data$sample, each = nbins),
            xmin = rep(mybreaks[1:nbins], times = nsamples),
            xmax = rep(mybreaks[-1], times = nsamples),
            ymin = rep(0, times = nbins*nsamples),
            ymax = rep(0, times = nbins*nsamples),
            mean = rep(0, times = nbins*nsamples),
            sd = rep(0, times = nbins*nsamples),
            lineEnd = rep(0, times = nbins*nsamples)
        )
        if (!animation){
            histdat <- histdat[histdat$sample == nsamples, ]
            histdat$sample <- NULL
            histdat$ymax <- finalhist$counts
            histdat$mean <- mean(data$value)
            histdat$sd <- sd(data$value)
            histdat$lineEnd <- max(finalhist$counts)
        } else {
            # iteratively fill up the histogram data, with the histogram breaks defined by the final histogram
            for (i in seq(from = 1, to = nsamples)){
                temp <- hist(data$value[1:i], breaks = mybreaks, plot = FALSE)
                histdat[histdat$sample == i, "ymax"] <- temp$counts
                histdat[histdat$sample == i, "mean"] <- mean(data[1:i, "value"])
                histdat[histdat$sample == i, "sd"] <- sd(data[1:i, "value"])
                histdat[histdat$sample == i, "lineEnd"] <- max(temp$counts)
            }
            histdat$sample <- as.factor(histdat$sample)
        }
        return(histdat)
    }
    
    # Create data
    #-----
    
    # Define the random number generator state for reproducibility
    set.seed(10)
    
    # Randomly sample from normal distribution with mean = 0 and SD = 5
    samples <- 1000
    data <- data.frame(sample = seq(samples),
                       value = rnorm(n = samples, mean = 0, sd = 5)) %>%
        # get cumulative summary statistics
        dplyr::mutate(means = cumulative(value),
                      SDs = cumulative(value, fun = "SD"))
    
    # Given this random data, get data for building corresponding histogram
    histdata <- cumulativeHist(data = data, animation = animation)

    # Create figures
    #-----
    
    # Scatterplot of samples
    plot <- ggplot2::ggplot(data = data,
                            ggplot2::aes(x = sample, y = value)) +
        ggplot2::geom_point(shape = 20) +
        ggplot2::scale_y_continuous(limits = c(-25, 25), expand = c(0,0)) +
        ggplot2::coord_flip() +
        ggplot2::ylab("sampled values") +
        ggplot2::theme_minimal() +
        ggplot2::theme(axis.line.y = ggplot2::element_blank(),
                       axis.title.x = ggplot2::element_text(size = 15),
              axis.title.y = ggplot2::element_blank(),
              axis.text.x = ggplot2::element_text(size = 12),
              axis.text.y = ggplot2::element_blank(),
              axis.ticks.y = ggplot2::element_blank(),
              panel.grid.major.y = ggplot2::element_blank(),
              panel.grid.minor = ggplot2::element_blank()) +
        if (animation){
            ggplot2::geom_rug(sides = "b")
        } else {
            ggplot2::geom_rug(sides = "b", alpha = 0.2)
        }
    if (animation){
        plot <- plot +
            gganimate::transition_time(sample) +
            gganimate::shadow_mark(exclude_layer = 2)
        plot_gif <- gganimate::animate(plot = plot, duration = 6,
                                       width = 600, height = 600)
    }
    
    # Histogram
    hist <- ggplot2::ggplot(data = histdata) +
        ggplot2::geom_rect(ggplot2::aes(xmin = xmin, xmax = xmax,
                                        ymin = ymin, ymax = ymax),
                  colour = "black", fill = "grey") +
        ggplot2::geom_segment(ggplot2::aes(x = mean, xend = mean,
                                           y = 0, yend = lineEnd),
                     colour = "#004380") +
        ggplot2::geom_rect(ggplot2::aes(xmin = mean - sd, xmax = mean + sd,
                                        ymin = 0, ymax = lineEnd),
                  colour = ggplot2::alpha("grey", 0),
                  fill = ggplot2::alpha("#004380", 0.05)) +
        ggplot2::scale_x_continuous(limits = c(-25, 25), expand = c(0,0)) +
        ggplot2::theme_minimal() +
        ggplot2::theme(axis.line = ggplot2::element_blank(),
                       axis.title = ggplot2::element_blank(),
                       axis.text = ggplot2::element_blank(),
                       axis.ticks = ggplot2::element_blank(),
                       panel.grid.major.y = ggplot2::element_blank(),
                       panel.grid.minor = ggplot2::element_blank())
    if (animation){
        hist <- hist +
            gganimate::transition_manual(frames = sample)
        hist_gif <- gganimate::animate(plot = hist, duration = 6, width = 600, height = 200)
    }
    
    # Combine plots into single figure
    if (animation){
        # code taken from: https://github.com/thomasp85/gganimate/wiki/Animation-Composition
        plot_mgif <- magick::image_read(plot_gif)
        hist_mgif <- magick::image_read(hist_gif)
        
        combined_gif <- magick::image_append(c(hist_mgif[1], plot_mgif[1]), stack = TRUE)
        for (i in 2:100){
            temp <- magick::image_append(c(hist_mgif[i], plot_mgif[i]), stack = TRUE)
            combined_gif <- c(combined_gif, temp)
        }
        if (!is.null(filename)){
            # Save the gif to a file
            magick::image_write(combined_gif, "Desktop/combined.gif")
        }
        return(combined_gif)
    } else {
        combined_plot <- ggpubr::ggarrange(hist, plot,
                                           ncol = 1, nrow = 2,
                                           heights = c((1/3), 1))
        return(combined_plot)
    }
}
