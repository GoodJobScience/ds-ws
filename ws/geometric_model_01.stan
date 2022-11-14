data {
  
  int<lower=0> N;
  
  int<lower=1> N_of_user_id;
  int<lower=1, upper=N_of_user_id> user_id[N];
  
  
  int<lower=1> N_of_level_id;
  int<lower=1, upper=N_of_level_id> level_id[N];
  
  vector<lower=0>[N_of_level_id] superundo[N_of_user_id];
  vector<lower=0>[N_of_level_id] shuffle[N_of_user_id];
  
  int<lower=0> retrial_count[N];
  
  int<lower=1> N_of_test_user;
  int<lower=1> N_of_test_level;
}

parameters {
  
  
  real<lower=0> user_sigma_hyper_parameter;
  real<lower=0> level_sigma_hyper_parameter;
  
  vector[N_of_user_id] u;
  vector[N_of_level_id] l;
  
  real b_shuffle;
  real b_superundo;
  
}

model {
  
  // priors
  target += exponential_lpdf(user_sigma_hyper_parameter | 1);
  target += exponential_lpdf(level_sigma_hyper_parameter | 1);
  
  
  target += normal_lpdf(l | 0, level_sigma_hyper_parameter);
  target += normal_lpdf(u | 0, user_sigma_hyper_parameter);
  
  target += normal_lpdf(b_shuffle | 0, 1);
  target += normal_lpdf(b_superundo | 0, 1);
  
  for (z in 1:N){
    
    int i = user_id[z];
    int j = level_id[z];
    
    real p = inv_logit(u[i] - l[j] + b_shuffle * shuffle[i, j]+ b_superundo * superundo[i, j]);
    
    target += neg_binomial_lpmf(retrial_count[z] | 1, p / (1 - p)); // geometric(p)
  }
  
}

generated quantities{
  int simulated_retry[N_of_test_user, N_of_test_level];
  
  for(i_test in 1:N_of_test_user){
    for(j_test in 1:N_of_test_level){
      
      int i = N_of_user_id - N_of_test_user + i_test;
      int j = N_of_level_id - N_of_test_level + j_test;
      
      real p = inv_logit(u[i] - l[j]+ b_shuffle * shuffle[i, j]+ b_superundo * superundo[i, j]);
          
      simulated_retry[i_test, j_test] = neg_binomial_rng(1, p / (1 - p)); // geometric(p)
    }
  }
}
