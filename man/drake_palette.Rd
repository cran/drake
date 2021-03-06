% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprecated.R
\name{drake_palette}
\alias{drake_palette}
\title{Show drake's color palette.
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}}
\usage{
drake_palette()
}
\value{
There is a console message,
but the actual return value is \code{NULL}.
}
\description{
Deprecated on 2019-01-12.
}
\details{
This function is
used in both the console and graph visualizations.
Your console must have the crayon package enabled.
This palette applies to console output
(internal functions \code{console()} and
\code{console_many_targets()}) and the node colors
in the graph visualizations.
So if you want to contribute improvements to the palette,
please both \code{drake_palette()} and
\code{visNetwork::visNetwork(nodes = legend_nodes())}
}
\keyword{internal}
