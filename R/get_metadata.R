


#' @title Read Website Metadata
#'
#' @param url charcter url of website, or path to html document
#' @param output character defining desired output type. Must be one of:
#' \itemize{
#'   \item(list)
#'   \item{data.frame}
#' }
#' @param force logical force metadata retrieval where site does not
#' authorise scraping. This option should only be used if you are
#' the owner of the site.
#'
#' @import rvest
#' @import httr
#' @import purrr
#' @import dplyr
#' @importFrom robotstxt paths_allowed
#'
#' @return list or data.frame
#' @export
#'
#' @examples
#' read_metadata('https://www.w3.org/')
read_metadata <- function(url, output = c('list','data.frame'), force = FALSE){

  # check ok to scrape
  suppressMessages({
    is_ok <- robotstxt::paths_allowed(url)
  })
  if (!is_ok | force) {
    message('This website does not wish to be scraped.')
    message('    use "force = TRUE", if you are the owner of this site.')
    stop()
  }

  output <- match.arg(output, several.ok = FALSE)

  page <- file(url, open = "r")
  continue <- TRUE
  doc <- as.character()

  while(continue){
    l <- readLines(page, n = 1)
    continue <- !grepl('</head>', x = l, ignore.case = TRUE)
    doc <- c(doc, l)
  }

  close(page)

  nodes <- doc |>
    paste0(collapse = '') |>
    read_html() |>
    html_nodes('meta, title')

  metadata <- map_dfr(c('property', 'name'), function(tag){
    nodes |>
      map_dfr(~ dplyr::tibble(property = html_attr(.x, tag),
                       content = html_attr(.x, 'content'))) |>
      dplyr::filter(!is.na(property))
  })

  # check for a title tag
  title <- nodes |> html_nodes(xpath = "/html/head/title") |> html_text()
  title_tag <- if ('og:title' %in% metadata$property) 'title' else 'og:title'

  if (length(title) > 0) {
    metadata <- metadata |>
      add_row(property = title_tag,
              content = title)
  }

  if (output == 'list') {
    metadata <- setNames(as.list(metadata$content), metadata$property)
  }

  return(metadata)

}
