% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/drake_example.R
\name{drake_example}
\alias{drake_example}
\title{Download the files of an example \code{drake} project.
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}}
\usage{
drake_example(
  example = "main",
  to = getwd(),
  destination = NULL,
  overwrite = FALSE,
  quiet = TRUE
)
}
\arguments{
\item{example}{Name of the example.
The possible values are the names of the folders at
\verb{https://github.com/wlandau/drake-examples}.}

\item{to}{Character scalar,
the folder containing the code files for the example.
passed to the \code{exdir} argument of \code{utils::unzip()}.}

\item{destination}{Deprecated; use \code{to} instead.}

\item{overwrite}{Logical, whether to overwrite an existing folder
with the same name as the drake example.}

\item{quiet}{Logical, passed to \code{downloader::download()}
and thus \code{utils::download.file()}. Whether
to download quietly or print progress.}
}
\value{
\code{NULL}
}
\description{
The \code{drake_example()} function downloads a
folder from \verb{https://github.com/wlandau/drake-examples}.
By default, it creates a new folder with the example name
in your current working directory. After the files are written,
have a look at the enclosed \code{README} file.
Other instructions are available in the files at
\verb{https://github.com/wlandau/drake-examples}.
}
\examples{
\dontrun{
isolate_example("Quarantine side effects.", {
if (requireNamespace("downloader")) {
drake_examples() # List all the drake examples.
# Sets up the same example from load_mtcars_example()
drake_example("mtcars")
# Sets up the SLURM example.
drake_example("slurm")
}
})
}
}
\seealso{
\code{\link[=drake_examples]{drake_examples()}}, \code{\link[=make]{make()}}
}
