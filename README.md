# NewProj #

A Makefile and directory structure for building new C Projects or Libraries

## Howto use NewProj ##

* Clone or fork this repo
* Remove the `.git` folder and `.gitignore` file (if need be)
* Rename `LICENSE` to `LICENSE.Makefile`
* Customize the project layout and `Makefile` to your needs

If you\'re building an binary,
* In `Makefile`, define `EXE`
* Put your code in `src/`
* Put your headers in `inc/`
* Put your tests in `t/`
* Then you can type `make`, `make test`, `make install`, `make showconfig`

If you\'re building a library
* In `Makefile`, define `LNK`
* Put your code in `lib/`
* Put your headers in `inc/`
* Put your tests in `t/`
* Then you can type `make`, `make test`, `make install`, `make showconfig`

You can also customize `CFLAGS`, `LDFLAGS`, `DEST`, and `PREFIX` from the command line or in the `Makefile`
