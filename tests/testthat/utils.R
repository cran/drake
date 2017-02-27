skipped = function(){
  s = status()
  s$output[s$status == "skipped"]
}

built_ = function(){
  s = status()
  s$output[s$status == "built"]
}

imported_ = function(){
  s = status()
  s$output[s$status == "imported"]
}

updated = function(){
  s = status()
  s$output[s$status %in% c("built", "imported")]
}
