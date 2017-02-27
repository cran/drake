hash_code = function(x){
  digest(x, algo = "md5", serialize = F)
}

hash_file = function(x){
  md5sum(x) %>% unname
}
