R = R --vanilla CMD


all: build check install clean

build:
	$(R) build .

check: build
	$(R) check --no-manual *.tar.gz

install:
	$(R) INSTALL .

clean:
	rm -rf *.tar.gz *.Rcheck ..Rcheck
