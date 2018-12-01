R = R --vanilla CMD


all: build check install clean

build:
	$(R) build .

check: build
	$(R) check --no-manual *.tar.gz

define devtools_check
	Rscript -e " \
		tryCatch( \
			invisible(packageVersion('devtools')), \
			error = function(e) { \
				install.packages('devtools', repos = 'https://cloud.r-project.org') \
			} \
		)"
endef
install:
	@$(devtools_check); \
	Rscript -e 'devtools::install()'

install_src:
	$(R) INSTALL .

clean:
	rm -rf *.tar.gz *.Rcheck ..Rcheck
