# Functions for plotting the result of Bayesian model fitting
#-----
traceplot <- function(bayesmodel, warmup = FALSE, window = NULL){
    
    require(ggplot2)
    require(bayesplot)
    if (warmup){
        require(rstan)
    }
    
    # extract samples for key parameters
    if (warmup){
        posterior_beta <- rstan::extract(bayesmodel, pars = c("beta[2]", "beta[3]", "beta[4]"),
                                         permuted = FALSE, inc_warmup = TRUE)
    } else {
        posterior_beta <- as.array(bayesmodel, pars = c("beta[2]", "beta[3]", "beta[4]"))
        # extract diagnostic information for the No-U-Turn-Sampler (NUTS)
        # np <- bayesplot::nuts_params(bayesmodel)
    }
    # make the parameter names informative
    dimnames(posterior_beta)$parameters <- c(expression(paste(hat(beta)," coffee")),
                                             expression(paste(hat(beta)," cake")),
                                             expression(paste(hat(beta)," interaction")))
    
    # create the plot
    if (warmup){
        xlabel <- "warm-up iteration"
    } else {
        xlabel <- "post warm-up iteration"
    }
    bayesplot::color_scheme_set("mix-blue-red")
    traceplot <- bayesplot::mcmc_trace(
        posterior_beta, window = window,
        facet_args = list(ncol = 1, strip.position = "left",
                                          labeller = ggplot2::label_parsed)) +
        ggplot2::xlab(xlabel) +
        ggplot2::theme(axis.title = ggplot2::element_text(size = 20),
                       strip.text = ggplot2::element_text(size = 20),
                       legend.position = "top",
                       legend.direction = "horizontal",
                       legend.margin = ggplot2::margin(t = 0, unit = "cm"))
    
    return(traceplot)
}

posteriorplot <- function(bayesmodel, rope = FALSE, limits = NULL){
    
    # Acknowledgement: Code adapted from https://www.tjmahr.com/ridgelines-in-bayesplot-1-5-0-release/
    
    require(ggplot2)
    require(bayesplot)
    require(ggridges)
    require(dplyr)
    
    # extract samples for key parameters
    posterior_beta <- as.array(bayesmodel, pars = c("beta[2]", "beta[3]", "beta[4]"))
    # make the parameter names informative
    dimnames(posterior_beta)$parameters <- c("coffee", "cake", "interaction")

    # extract data for 95% density, 50% density, and point estimate
    plotdata <- bayesplot::mcmc_areas_data(posterior_beta, prob_outer = 0.95) %>% 
        dplyr::mutate(interval = factor(interval, c("outer", "inner", "point")))
    
    # extract data for full density
    fullrangedata <- bayesplot::mcmc_areas_data(posterior_beta, prob_outer = 1) %>%
        dplyr::mutate(interval = factor(interval, c("outer", "inner", "point"))) %>%
        dplyr::filter(interval == "outer") %>%
        dplyr::select(-interval)
    
    # create plot
    posteriorplot <- ggplot2::ggplot(
        plotdata, ggplot2::aes(x = x, y = parameter, fill = interval, height = density)) +
        bayesplot::vline_0(colour = "grey", linetype = 2) +
        ggridges::geom_density_ridges(
            stat = "identity", colour = "white") +
        ggridges::geom_density_ridges(
            stat = "identity", data = fullrangedata, color = "black",
            size = 1, fill = NA) +
        ggplot2::scale_fill_brewer(type = "seq") + 
        ggplot2::guides(fill = FALSE) +
        ggplot2::xlab(expression(hat(beta))) +
        ggplot2::scale_y_discrete(limits = rev(levels(plotdata$parameter)),
                                  expand = c(0,0.5),
                                  labels = c("interaction", "    cake", "coffee")) +
        bayesplot::theme_default() +
        ggplot2::theme(axis.title.y = ggplot2::element_blank(),
                       axis.line.y = ggplot2::element_blank(),
                       axis.ticks.y = ggplot2::element_blank(),
                       panel.grid.major.y = ggplot2::element_line(colour = "#e0e0e0", size = 0.1),
                       axis.text.y = element_text(angle = 90, hjust = 0,
                                                  colour = "black", size = 20),
                       axis.text.x = element_text(size = 15),
                       axis.title.x = element_text(size = 20))
    
    if (rope){
        posteriorplot <- posteriorplot +
            ggplot2::annotate(
                geom = "rect",
                xmin = limits[1], xmax = limits[2],
                ymin = 0, ymax = 5,
                colour = NA, fill = "red", alpha = 0.3
            ) +
            ggplot2::annotate(
                geom = "text",
                x = 0, y = 0.25, label = "ROPE",
                colour = "red4", size = 8
            )
    }
    
    return(posteriorplot)
}
