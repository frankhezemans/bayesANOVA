// note: code adapted from Sorensen, Hohenstein, & Vasishth (2016). doi: 10.20982/tqmp.12.3.p175
//-----------------------------------------------
// user-defined functions
functions {
  // ...
}
// required data for the model
data {
  int<lower=1> N;                 // number of observations (positive integer)
  int<lower=1> P;                 // number of predictor terms (positive integer)
  int<lower=1> J;                 // number of subjects (positive integer)
  int<lower=1> n_u;               // number of by-subject random effects (positive integer)
  int<lower=1,upper=J> subj[N];   // subject indicator for row N
  row_vector[P] X[N];             // fixed effects design matrix
  row_vector[n_u] Z_u[N];         // subject random effects design matrix
  vector[N] y;                    // response variable
}
// declaration of constants and data transforms
transformed data {
  // ...
}
// the 'unknowns' aka model parameters
parameters {
  vector[P] beta;                 // fixed effects coefficients
  cholesky_factor_corr[n_u] L_u;  // matrix square root (cholesky factor) of subject random effects correlation matrix
  vector<lower=0>[n_u] sigma_u;   // subject random effects standard deviation
  real<lower=0> sigma_e;          // standard deviation of the errors (residual std)
  vector[n_u] z_u[J];             // subject random effects
}
// define variables in terms of data - save parameters for use in model
transformed parameters {
  vector[n_u] u[J];               // subject randon effects
  {
    matrix[n_u,n_u] Sigma_u;      // subject random effects covariance matrix
    Sigma_u = diag_pre_multiply(sigma_u,L_u);
    for(j in 1:J)
      u[j] = Sigma_u * z_u[j];
  }
}
// the generative model - define the log probability function
model {
  // priors
  // we implicitly place uniform (minimally informative) priors on beta, sigma_u and sigma_e by omitting prior specification
  L_u ~ lkj_corr_cholesky(2.0);   // place lkj priors on the random effects correlation matrix
  for (j in 1:J)
    z_u[j] ~ normal(0,1);         // place normal prior on subject random effects
  // likelihood
  for (i in 1:N)
    y[i] ~ normal(X[i] * beta + Z_u[i] * u[subj[i]], sigma_e);
}
// derivatives of the parameters
generated quantities {
  // ...
}
