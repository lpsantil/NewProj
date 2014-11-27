# NewProj #

A Makefile and directory structure for building new C Projects or Libraries

## Howto use NewProj ##

* Clone or fork this repo
* Remove the `.git` folder and `.gitignore` file (if need be)
* Rename `LICENSE` to `LICENSE.Makefile`
* Rename `README.md` to `README.Makefile.md`
* Customize the project layout and `Makefile` to your needs

If you're building an binary,
* In `Makefile`, define `EXE`
* Put your code in `src/`
* Put your headers in `inc/`
* Put your tests in `t/`
* Then you can type `make`, `make test`, `make install`, `make showconfig`

If you're building a library
* In `Makefile`, define `LNK`
* Put your code in `lib/`
* Put your headers in `inc/`
* Put your tests in `t/`
* Then you can type `make`, `make test`, `make install`, `make showconfig`

With `watch` installed, you can do continuous integration, test, or deployment.
* For continuous integration (`make clean all`), type `make start_ci`.  To kill it, type `make stop_ci`
* For continuous test (`make test`), type `make start_ct`.  To kill it, type `make stop_cd`
* For continuous deployment (`make install`), type `make start_cd`.  To kill it, type `make stop_cd`

You can also customize `CFLAGS`, `LDFLAGS`, `DEST`, and `PREFIX` from the command line or in the `Makefile`
