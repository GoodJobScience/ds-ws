#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param train_data PARAM_DESCRIPTION
#' @param test_data PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[cmdstanr]{cmdstan_model}}
#'  \code{\link[dplyr]{select}}, \code{\link[dplyr]{mutate}}, \code{\link[dplyr]{group_by}}, \code{\link[dplyr]{summarise}}
#'  \code{\link[tidyr]{pivot_longer}}, \code{\link[tidyr]{separate}}
#' @rdname odds_table_creator
#' @export 
#' @importFrom cmdstanr cmdstan_model
#' @importFrom dplyr select mutate group_by summarise
#' @importFrom tidyr pivot_longer separate
odds_table_creator <- function(train_data,test_data,stan_file){

  # model <- cmdstanr::cmdstan_model('geometric_model_00.stan')
  model <- cmdstanr::cmdstan_model(stan_file)

  input_list <- list(
    N = nrow(train_data),
    user_id = train_data$user_id,
    N_of_user_id = max(train_data$user_id),
    level_id = train_data$level_id  - 100,
    N_of_level_id = max(train_data$level_id) - 100,
    retrial_count = train_data$retrial_count,
    N_of_test_user = length(unique(test_data$user_id)),
    N_of_test_level = length(unique(test_data$level_id))
  )

  fit <- model$sample(
    data = input_list,
    iter_warmup = 150,
    iter_sampling = 150,
    seed = 1,
    chains = 4,
    parallel_chains = 4,
    refresh = 20,
    show_messages=FALSE
  )

  df <- vroom(fit$output_files(), comment = '#', delim = ',')

  simulated_retry <- df %>%
    dplyr::select(starts_with('simulated_retry.'))  %>%
    tidyr::pivot_longer(everything()) %>%
    tidyr::separate(name, c("_", "user_id", "level_id"), sep = "\\.") %>%
    dplyr::mutate(user_id = as.numeric(user_id) + 100) %>%
    dplyr::mutate(level_id = as.numeric(level_id) + 150)

  simulated_retry %>%
    dplyr::mutate(line=1.5) %>%
    dplyr::mutate(t=value < line) %>%
    dplyr::group_by(user_id, level_id, line) %>%
    dplyr::summarise(p=sum(t)/600) %>%
    dplyr::mutate(o=(1-p)/p) %>%
    dplyr::mutate(odd=o/ pmax(rnorm(n(),1, 0.35),0.3) / 2+ 1) %>%
    dplyr::mutate(OU='U') %>%
    dplyr::select(user_id, level_id, line, OU, odd)    #write.csv('odds_table.csv', row.names = FALSE)

}
