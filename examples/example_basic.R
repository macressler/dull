#
# example file for basic functionality
# make sure the package meta files are up-to-date before loading
#

library(dull)
library(magrittr)

arg = commandArgs(TRUE)
port = ifelse(length(arg) == 1, as.integer(arg), 3030)
cat("Listening on port", port, "\n")

# NOTE: the parameter structure for the "get" function
# is currently ignored within the dull_class object
dull() %>% 
  get('^$', function(req, res) {
    res %>% 
      status(200) %>% 
      headers(Connection = 'close') %>% 
      body('<div align="center"><h1>Hello, world!</h1><p>(and all who inhabit it)</p></div>')
    
    # NOTE: It is not necessary to return the response object, but send() must be called
    send(res)
    
    print("What do you mean I'm not printed?!")
  }) %>% 
  get('^get/404/$', function(req, res) {
    # res %>% 
    #    http_404_page
    
    # but for now,
    res %>% 
      status(404) %>% 
      body('<h4>Whoops, page not found!</h4><p>Better luck next time</p>')
    
    send(res)
  }) %>% 
  listen('0.0.0.0', port)
