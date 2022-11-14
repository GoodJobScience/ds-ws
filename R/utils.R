

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param outputfiles PARAM_DESCRIPTION
#' @param min_test_user_id PARAM_DESCRIPTION
#' @param min_level_id PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
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
