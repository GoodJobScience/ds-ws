

#' @title Get Simulated Retry
#' @description The function designed to read stan results and return the simulated retry counts
#' @param outputfiles Stan output files
#' @param min_test_user_id Minimum user id given in the stan model
#' @param min_level_id Minimum level id given in the stan model
#' @return return a dataframe level_id; user_id; simulated value
#' @details The function requires to be used with provided stanfiles
#' @examples 
#' \dontrun{
#' test_users_simulated_try_model_1 <- get_simulated_retry(
#'  fit$output_files(), 
#'  MIN_TEST_USER_ID,
#'  MIN_TEST_LEVEL_ID
#'  )
#' }
#' @seealso 
#'  \code{\link[vroom]{vroom}}
#'  \code{\link[dplyr]{select}}, \code{\link[dplyr]{mutate}}
#'  \code{\link[tidyr]{pivot_longer}}, \code{\link[tidyr]{separate}}
#' @rdname get_simulated_retry
#' @export 
#' @importFrom vroom vroom
#' @importFrom dplyr select mutate
#' @importFrom tidyr pivot_longer separate
get_simulated_retry <- function(outputfiles, min_test_user_id, min_level_id) {
  
  simulated_retry <-  vroom::vroom(outputfiles, comment = '#', delim = ',') |>
    dplyr::select(starts_with('simulated_retry.'))  |>
    tidyr::pivot_longer(everything()) |>
    tidyr::separate(name, c("_", "user_id", "level_id"), sep = "\\.") |>
    dplyr::mutate(user_id = as.numeric(user_id) + min_test_user_id - 1) |>
    dplyr::mutate(level_id = as.numeric(level_id) + min_level_id - 1) |>
    dplyr::select(-`_`)

  simulated_retry
}
