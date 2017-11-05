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

## ----basic_storage-------------------------------------------------------
library(drake)
load_basic_example()
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
cache$list() # functionality from storr
cache$get("small") # functionality from storr

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
default_short_hash_algo() # for drake
default_long_hash_algo()
short_hash(cache)
long_hash(cache)

## ----default_cache_reset-------------------------------------------------
cache_path(cache) # default cache from before
clean(destroy = TRUE) # start from scratch to reset both hash algorithms
tmp <- new_cache(
  path = default_cache_path(), # the `.drake/` folder
  short_hash_algo = "crc32",
  long_hash_algo = "sha1"
)

## ----default_cache_control-----------------------------------------------
config <- make(my_plan, verbose = FALSE)
short_hash(config$cache) # would have been xxhash64 (default_short_hash_algo())
long_hash(config$cache) # would have been sha256 (default_long_hash_algo())

## ----more_cache----------------------------------------------------------
outdated(my_plan, verbose = FALSE) # empty
config$cache <- configure_cache(
  config$cache,
  long_hash_algo = "murmur32",
  overwrite_hash_algos = TRUE
)

## ----newhashmorecache----------------------------------------------------
outdated(my_plan, verbose = FALSE)
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
new_plan <- workplan(
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
other_plan <- workplan(
  some_data = rnorm(50),
  more_data = rpois(75, lambda = 10),
  result = mean(c(some_data, more_data))
)
make(other_plan, cache = memory_cache)
cached(cache = memory_cache)
readd(result, cache = memory_cache)

## ----cache_types---------------------------------------------------------
default_cache_type()
cache_types()
in_memory_cache_types()
env <- new.env()
my_type <- new_cache(type = "storr_environment")
my_type_2 <- new_cache(type = "storr_environment", envir = env)
ls(env)

## ----cleaning_up---------------------------------------------------------
clean(small, large)
cached() # 'small' and 'large' are gone
clean(destroy = TRUE)
clean(destroy = TRUE, cache = faster_cache)
clean(destroy = TRUE, cache = my_storr)

## ----cleanup_storage, echo = FALSE---------------------------------------
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

