

create_rmd <- function(title, metadata, .fun, ...) {

  # build filename ??  distill already does this


  # get all files in wd
  old_files <- list.files(pattern = '.rmd', recursive = TRUE, ignore.case = TRUE)

  if (is.null(.fun)) {
    rmarkdown::draft(...)
  } else {
    call(.fun, ...)
  }

  # wait for render.




  # get filename
  if ('# not defined') {
    # detect new file
    new_file <- setdiff(list.files(pattern = '.rmd', recursive = TRUE, ignore.case = TRUE),
                        old_files)
  } else {
    new_file <- filename
  }


  # add meta
  ## get existing
  doc <- readLines(new_file)
  yaml_delimiters <- grep("^(---|\\.\\.\\.)\\s*$", doc)
  md <- rmarkdown::yaml_front_matter(new_file)

  md$uuid <- uuid::UUIDgenerate()

  writeLines(c(paste0("---\n",
                      yaml::as.yaml(md),
                      "---"),
               "\n\n",
               doc[(yaml_delimiters[2] + 1):length(doc)]),
             new_file)


}
