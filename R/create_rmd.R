

create_rmd <- function(title, metadata, .fun = NULL, ...) {

  # build filename ??  distill already does this
  slug <- gsub('[[:punct:]]', '', title)
  slug <- gsub(' |  ', '-', slug)
  slug <- tolower(slug)

  filename <- paste0(format(Sys.Date(), '%Y-%m-%d'),
                     '-',
                     slug,
                     '.Rmd')

  # get all files in wd
  old_files <- list.files(pattern = '.rmd', recursive = TRUE, ignore.case = TRUE)

  if (is.null(.fun)) {
    rmarkdown::draft(filename, edit = FALSE, ...)
  } else {
    do.call(.fun, args = list(title = title, ...))
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

  md$uuid <- uuid::UUIDgenerate()
  md$draft <- TRUE # renders as yes (yaml spec 1.1) not sure if will cause issues

  writeLines(c(paste0("---\n",
                      yaml::as.yaml(md),
                      "---"),
               "\n\n",
               doc[(yaml_delimiters[2] + 1):length(doc)]),
             new_file)

  if (rstudioapi::hasFun("navigateToFile"))
    rstudioapi::navigateToFile(new_file)
  else utils::file.edit(new_file)

  invisible(new_file)
}
