#library(gganimate)
#library(ggplot2)
#library(gifski)
#library(png)   
#library(gridExtra)

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param play_vector PARAM_DESCRIPTION
#' @param scores PARAM_DESCRIPTION
#' @param odds_table PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[dplyr]{mutate}}, \code{\link[dplyr]{group_by}}, \code{\link[dplyr]{count}}
#'  \code{\link[ggplot2]{ggplot}}, \code{\link[ggplot2]{aes}}, \code{\link[ggplot2]{geom_path}}, \code{\link[ggplot2]{geom_bar}}, \code{\link[ggplot2]{geom_label}}, \code{\link[ggplot2]{position_stack}}, \code{\link[ggplot2]{c("guide_bins", "guide_colourbar", "guide_coloursteps", "guide_legend", "guides", "guides")}}, \code{\link[ggplot2]{guide_legend}}, \code{\link[ggplot2]{coord_polar}}, \code{\link[ggplot2]{ggtheme}}
#'  \code{\link[gridExtra]{arrangeGrob}}
#' @rdname score_the_play_vector
#' @export 
#' @importFrom dplyr mutate group_by tally
#' @importFrom ggplot2 ggplot aes geom_line geom_col geom_label position_stack guides guide_legend coord_polar theme_void
#' @importFrom gridExtra grid.arrange
score_the_play_vector <- function(play_vector,scores,odds_table){
  
  scores <- merge(scores,odds_table) %>% 
    dplyr::mutate(play=play_vector) %>% 
    dplyr::mutate(index=row_number()) %>%
    dplyr::mutate(profit_loss=play*(odd - 1)*(retrial_count<line) + play * (retrial_count>line) * -1) %>%
    dplyr::mutate(profit=cumsum(profit_loss * 10))
  
  p1 <- ggplot2::ggplot(scores, ggplot2::aes(x=index, y=profit)) +
    ggplot2::geom_line()
  
  play_or_not <- scores %>% dplyr::mutate(play_factor = as.factor(play)) %>% 
    dplyr::group_by(play_factor) %>% 
    dplyr::tally() %>% 
    dplyr::mutate(perc = floor(n / 25), labels=perc)
  
  p2 <- ggplot2::ggplot(play_or_not, ggplot2::aes(x = "", y = perc, fill = play_factor)) +
    ggplot2::geom_col(color = "black") +
    ggplot2::geom_label(ggplot2::aes(label = labels), color = c('black'),
               position = ggplot2::position_stack(vjust = 0.5),
               show.legend = FALSE) +
    ggplot2::guides(fill = ggplot2::guide_legend(title = "Play or Not")) +
    ggplot2::coord_polar(theta = "y") + 
    ggplot2::theme_void() 
  
  
  p3 <- gridExtra::grid.arrange(p1, p2, ncol = 2,  widths = 2:1)
  p3
}
