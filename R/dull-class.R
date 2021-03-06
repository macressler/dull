#' Dull application class object
#'
#' An R6 class which is the backbone of the dull package.
#'
#' @docType class
#' @keywords internal
#' @format An R6 class object.
#' @importFrom R6 R6Class
#' @importFrom httpuv runServer
#' @importFrom magrittr %>%
#' @export
#' @name dull_app
dull_app <- R6::R6Class(
  'dull_app',
  public = list(
    routes = NULL,
    default_404 = NULL,
    host = NULL,
    port = NULL,

    initialize = function() {
      self$routes <- list()
      self$default_404 <- list(
        status = 404,
        headers = list(
          'Content-Type' = 'text/html'
        ),
        body = paste('Sorry, page not found')
      )
      self$host <- '127.0.0.1'
      self$port <- 3030

      invisible(self)
    },

    call = function(req) {
      self$handle_request(req)
    },
    run = function(host, port) {
      if (missing(host)) {
        message(paste('Host defaulting to', self$host))
        host <- self$host
      }
      if (missing(port)) {
        message(paste('Port defaulting to', self$port))
        port <- self$port
      }

      httpuv::runServer(host, port, self)
    },

    add_route = function(method, uri, callback) {
      route_to_be <- route$new(method, uri, callback)

      if (route_to_be$uri %in% names(self$routes))
        self$routes[[route_to_be$uri]]$assign_callback(method, callback)
      else
        self$routes[[route_to_be$uri]] <- route_to_be

      invisible(self)
    },
    handle_request = function(rook_envir) {
      route <- self$find_route(rook_envir[['PATH_INFO']])

      if (route %>% is.null) return(self$default_404)

      callback <- route$get_callback(rook_envir[['REQUEST_METHOD']])

      if (callback %>% is.null) return(self$default_404)

      req <- request$new(route, rook_envir)
      res <- response$new()

      tryCatch({
        load_callback_envir(callback)(req, res)

        list(
          status = 500,
          headers = list('Content-Type' = 'text/plain'),
          body = 'send() is never called for response object'
        )
      },
      end_response = function(c) {
        res$as_Rook_response()
      },
      error = function(e) {
        list(
          status = 500,
          headers = list('Content-Type' = 'text/plain'),
          body = paste('Server error:', e, sep = '\n')
        )
      })
    },
    find_route = function(uri) {
      route_name = Find(function(nm) self$routes[[nm]]$uri_matches(uri), names(self$routes), nomatch = NULL)

      if (route_name %>% is.null) return(NULL)

      self$routes[[route_name]]
    }
  )
)
