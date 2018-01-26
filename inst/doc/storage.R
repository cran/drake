## ----suppression, echo = F-----------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE, verbose = FALSE)
unlink(
  c(
    "Makefile", "report.Rmd", "shell.sh",
    "STDIN.o*", "Thumbs.db",
    "faster_cache", "my_storr"
  ),
  recursive = TRUE
)
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)

## ----basic_storage-------------------------------------------------------
library(drake)
load_basic_example(verbose = FALSE) # Get the code with drake_example("basic").
config <- make(my_plan, verbose = FALSE)

## ----explore_basic-------------------------------------------------------
head(cached())

readd(small)

loadd(large)

head(large)

rm(large) # Does not remove `large` from the cache.

## ----get_storrs----------------------------------------------------------
class(config$cache) # from `config <- make(...)`

cache <- get_cache() # Get the default cache from the last build.

class(cache)

cache$list() # Functionality from storr

cache$get("small") # Functionality from storr

## ----hashes--------------------------------------------------------------
library(digest) # package for hashing objects and files
smaller_data <- 12
larger_data <- rnorm(1000)

digest(smaller_data) # compute the hash

digest(larger_data)

## ----compare_algo_lengths------------------------------------------------
digest(larger_data, algo = "sha512")

digest(larger_data, algo = "md5")

digest(larger_data, algo = "xxhash64")

digest(larger_data, algo = "murmur32")

## ----justified_hash_choices----------------------------------------------
default_short_hash_algo()

default_long_hash_algo()

short_hash(cache)

long_hash(cache)

## ----default_cache_reset-------------------------------------------------
cache_path(cache) # Default cache from before.

# Start from scratch to reset both hash algorithms.
clean(destroy = TRUE)

tmp <- new_cache(
  path = default_cache_path(), # The `.drake/` folder.
  short_hash_algo = "crc32",
  long_hash_algo = "sha1"
)

## ----default_cache_control-----------------------------------------------
config <- make(my_plan, verbose = FALSE)

short_hash(config$cache) # xxhash64 is the default_short_hash_algo()

long_hash(config$cache) # sha256 is the default_long_hash_algo()

## ----more_cache----------------------------------------------------------
outdated(config) # empty

config$cache <- configure_cache(
  config$cache,
  long_hash_algo = "murmur32",
  overwrite_hash_algos = TRUE
)

## ----newhashmorecache----------------------------------------------------
config <- drake_config(my_plan, verbose = FALSE, cache = config$cache)
outdated(config)

config <- make(my_plan, verbose = FALSE)

short_hash(config$cache) # same as before

long_hash(config$cache) # different from before

## ---- custom cache-------------------------------------------------------
faster_cache <- new_cache(
  path = "faster_cache",
  short_hash_algo = "murmur32",
  long_hash_algo = "murmur32"
)

cache_path(faster_cache)

cache_path(cache) # location of the previous cache

short_hash(faster_cache)

long_hash(faster_cache)

new_plan <- drake_plan(
  simple = 1 + 1
)

make(new_plan, cache = faster_cache)

cached(cache = faster_cache)

readd(simple, cache = faster_cache)

## ----oldcachenoeval, eval = FALSE----------------------------------------
#  old_cache <- this_cache("faste_cache") # Get a cache you know exists...
#  recovered <- recover_cache("faster_cache") # or create a new one if missing.

## ----use_storr_directly--------------------------------------------------
library(storr)
my_storr <- storr_rds("my_storr", mangle_key = TRUE)
make(new_plan, cache = my_storr)

cached(cache = my_storr)

readd(simple, cache = my_storr)

## ----memory_caches-------------------------------------------------------
memory_cache <- storr_environment()
other_plan <- drake_plan(
  some_data = rnorm(50),
  more_data = rpois(75, lambda = 10),
  result = mean(c(some_data, more_data))
)

make(other_plan, cache = memory_cache)

cached(cache = memory_cache)

readd(result, cache = memory_cache)

## ----dbi_caches, eval = FALSE--------------------------------------------
#  mydb <- DBI::dbConnect(RSQLite::SQLite(), "my-db.sqlite")
#  cache <- storr::storr_dbi(
#    tbl_data = "data",
#    tbl_keys = "keys",
#    con = mydb
#  )
#  load_basic_example() # Get the code with drake_example("basic").
#  unlink(".drake", recursive = TRUE)
#  make(my_plan, cache = cache)

## ----cleaning_up---------------------------------------------------------
clean(small, large)

cached() # 'small' and 'large' are gone

clean(destroy = TRUE)

clean(destroy = TRUE, cache = faster_cache)
clean(destroy = TRUE, cache = my_storr)

## ----cleanup_storage, echo = FALSE---------------------------------------
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

