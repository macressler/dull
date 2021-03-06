#
# example file demonstrating multiple HTTP methods for the same URI
# make sure the package meta files are up-to-date before loading
#

library(dull)
library(magrittr)

arg = commandArgs(TRUE)
port = ifelse(length(arg) == 1, as.integer(arg), 3030)
cat("Listening on port", port, "\n")

dull() %>%
  get(c('^$', '^index$'), function(req, res) {
    # c('^$', '^index$') is equivalent to '^$|^index$'
    res %>%
      status(200) %>%
      headers(Connection = 'close') %>%
      body('<div align="center"><h1>Hello, world!</h1><p>(and all who inhabit it)</p></div') %>%
      send

  }) %>%
  post('^$', function(req, res) {
    # different method for the same uri

    if (any(grepl('please', body(req), ignore.case = TRUE))) {
      res %>%
        send('<h4>Sorry, still nothing to show, but thank you for asking nicely.</h4>')
    }

    res %>%
      status(405) %>%
      body('<h4>Sorry, this is just a test</h4><p>Washington or Huffington?</p>') %>%
      send

  }) %>%
  get('^user/(?<id>[0-9]+)$', function(req, res) {
    res %>%
      body(paste0('<h4>User info<h4></br><p>No records for ID ', params(req)['id'], '</p>')) %>%
      send

  }) %>%
  get('^redirect/', function(req, res) {
    req_path <- original_url(req)
    redirect_path <- sub('^/redirect/', '/redirected/', req_path, perl = TRUE)

    res %>%
      body(paste0('<p>', 302, ' Redirecting to <a href="', redirect_path, '">', redirect_path, '</a></p>')) %>%
      redirect(redirect_path)

  }) %>%
  get('^redirected/', function(req, res) {
    redir_subject <- gsub('/', ' ', sub('^/redirected/', '', original_url(req)))

    res %>%
      send(paste('<h3>Welcome to the new and improved', redir_subject, 'page!</h3>'))

  }) %>%
  listen('0.0.0.0', port)
