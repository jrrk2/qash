P = -package lwt,lwt.unix,pcre,yojson,lwt,ppx_deriving.show,ppx_deriving.make,ppx_yojson_conv,unix,sqlite3,lwt_ppx,csv,ocamlformat,eqaf
S = lib/util.ml lib/model.ml lib/p.mli lib/p.ml lib/l.ml lib/qparser.ml lib/loader.ml \
	lib/generator.ml lib/datastore.mli lib/datastore.ml lib/verifier.ml lib/regex.ml lib/sql_writer.ml \
	lib_fsnotify/stub/fsnotify.ml lib/command.ml
U = lib/web_server.ml
UL = dream,digestif,dream-httpaf

qashtop: $S
	ocamlfind ocamlmktop -o $@ -strict-sequence -thread -linkpkg $P -I lib -I lib_fsnotify/stub -I /Users/jonathan/.opam/default/lib/digestif/c $S  /Users/jonathan/.opam/default/lib/digestif/c/digestif_c.cma

lib/p.ml lib/p.mli: lib/p.mly
	ocamlfind ocamlc -I lib -I +unix $P -c lib/util.ml lib/model.ml
	menhir --ocamlc 'ocamlfind ocamlc $P -c -I lib' --base lib/p --infer lib/p.mly

lib/l.ml lib/l.mli: lib/l.mll
	ocamllex $<

