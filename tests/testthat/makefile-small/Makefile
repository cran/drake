all:  .drake/timestamps/f .drake/timestamps/d .drake/timestamps/e .drake/timestamps/c .drake/timestamps/b .drake/timestamps/a 

.drake/timestamps/f:  
	Rscript -e 'drake:::build("f", verbose = TRUE, force_rehash = FALSE)'

.drake/timestamps/d:  
	Rscript -e 'drake:::build("d", verbose = TRUE, force_rehash = FALSE)'

.drake/timestamps/e:  
	Rscript -e 'drake:::build("e", verbose = TRUE, force_rehash = FALSE)'

.drake/timestamps/c: .drake/timestamps/d .drake/timestamps/f 
	Rscript -e 'drake:::build("c", verbose = TRUE, force_rehash = FALSE)'

.drake/timestamps/b: .drake/timestamps/d .drake/timestamps/e 
	Rscript -e 'drake:::build("b", verbose = TRUE, force_rehash = FALSE)'

.drake/timestamps/a: .drake/timestamps/b .drake/timestamps/c 
	Rscript -e 'drake:::build("a", verbose = TRUE, force_rehash = FALSE)'
