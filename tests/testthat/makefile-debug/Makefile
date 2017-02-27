all:  .drake/timestamps/a .drake/timestamps/c .drake/timestamps/b .drake/timestamps/d .drake/timestamps/e .drake/timestamps/'e' .drake/timestamps/sha .drake/timestamps/final .drake/timestamps/'d' 

.drake/timestamps/a:  
	Rscript -e 'drake:::build("a", verbose = FALSE, force_rehash = FALSE)'

.drake/timestamps/c: .drake/timestamps/a 
	Rscript -e 'drake:::build("c", verbose = FALSE, force_rehash = FALSE)'

.drake/timestamps/b: .drake/timestamps/a 
	Rscript -e 'drake:::build("b", verbose = FALSE, force_rehash = FALSE)'

.drake/timestamps/d: .drake/timestamps/b .drake/timestamps/c 
	Rscript -e 'drake:::build("d", verbose = FALSE, force_rehash = FALSE)'

.drake/timestamps/e: .drake/timestamps/b .drake/timestamps/d 
	Rscript -e 'drake:::build("e", verbose = FALSE, force_rehash = FALSE)'

.drake/timestamps/'e': .drake/timestamps/e 
	Rscript -e 'drake:::build(drake::as_file("e"), verbose = FALSE, force_rehash = FALSE)'

.drake/timestamps/sha:  
	Rscript -e 'drake:::build("sha", verbose = FALSE, force_rehash = FALSE)'

.drake/timestamps/final: .drake/timestamps/'e' 
	Rscript -e 'drake:::build("final", verbose = FALSE, force_rehash = FALSE)'

.drake/timestamps/'d': .drake/timestamps/d 
	Rscript -e 'drake:::build(drake::as_file("d"), verbose = FALSE, force_rehash = FALSE)'
