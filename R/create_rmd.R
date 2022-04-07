

#' @title Create a New RMarkdown File
#'
#' @param title
#' @param .fun
#' @param ... arbitrary metadata added to yaml header
#'
#' @import rmarkdown
#' @import yaml
#' @import rstudioapi
#' @importFrom glue glue
#' @importFrom uuid UUIDgenerate
#'
#'
#' @return
#' @export
#'
#' @examples
create_document <- function(title, .fun = NULL, ...) {

  # build filename ??  distill already does this
  slug <- gsub('[[:punct:]]', '', title)
  slug <- gsub(' |  ', '-', slug)
  slug <- tolower(slug)

  filename <- paste0(format(Sys.Date(), '%Y-%m-%d'),
                     '-',
                     slug,
                     ifelse(.fun == 'quarto',
                            '.qmd',
                            '.Rmd'))

  # get all files in wd
  old_files <- list.files(pattern = '.rmd', recursive = TRUE, ignore.case = TRUE)

  if (is.null(.fun)) {
    rmarkdown::draft(filename, edit = FALSE) #, ...)
  } else if (.fun == 'quarto') {
    # write function to create empty quarto with min yaml
    quarto_new(filename, title)
  } else {
    do.call(.fun, args = list(title = title)) #, ...))
  }

  # wait for render.

  # get filename
  if (file.exists(filename)) {
    new_file <- filename
  } else {
    # detect new file
    new_file <- setdiff(list.files(pattern = '.rmd', recursive = TRUE, ignore.case = TRUE),
                        old_files)
  }


  # add meta
  ## get existing
  doc <- readLines(new_file)
  yaml_delimiters <- grep("^(---|\\.\\.\\.)\\s*$", doc)
  md <- rmarkdown::yaml_front_matter(new_file)



  # add default entries
  md$uuid <- uuid::UUIDgenerate()
  md$draft <- TRUE # renders as yes (yaml spec 1.1) not sure if will cause issues

  # search for about.yml file in working directory
  if (file.exists('about.yml')) {
    template <- yaml::read_yaml('about.yml')
    md <- c(md, template)
  }

  # add arbitrary metadata here
  md <- c(md, list(...))

  writeLines(c(paste0("---\n",
                      yaml::as.yaml(md,
                                    omap = TRUE,
                                    indent = 2,
                                    indent.mapping.sequence = TRUE),
                      "---"),
               "\n\n",
               doc[(yaml_delimiters[2] + 1):length(doc)]),
             new_file)

  if (rstudioapi::hasFun("navigateToFile"))
    rstudioapi::navigateToFile(new_file)
  else utils::file.edit(new_file)

  invisible(new_file)
}


quarto_new <- function(filename, title){
  template <- readLines(system.file('templates/basic_quarto.qmd', package = 'about'))
  template[2] <- glue::glue('title: {title}')
  writeLines(template, filename)
}
