prefix = /usr/local
exec_prefix = ${prefix}
bin_dir = ${exec_prefix}/bin
man1_dir = ${prefix}/share/man/man1
doc_dir = ${prefix}/share/doc/checksum_tools

PROGRAMS = checksum_tool clear_checksums cull_dupes find_dupes \
           find_orphans get_metadata link_dupes prune_dirs \
           restore_to_xa_location symlink_dupes update_checksums \
           verify_checksums

ALL:

install: install-bin install-man install-doc

install-bin: ${PROGRAMS}
	mkdirhier "${bin_dir}"
	for f in ${PROGRAMS} ; do \
		cp -va $${f} "${bin_dir}"/ ; \
	done

install-man: man/*.1
	mkdirhier "${man1_dir}"
	for f in man/*.1 ; do \
		cp -va $${f} "${man1_dir}"/ ; \
	done

install-doc:
	mkdirhier "${doc_dir}"
	cp -va README.md       "${doc_dir}"/
	cp -va Changes.md      "${doc_dir}"/
	cp -va INSTALL         "${doc_dir}"/
	cp -va Internals.md    "${doc_dir}"/
	cp -va Localization.md "${doc_dir}"/
	cp -va LICENSE         "${doc_dir}"/

uninstall:
	for f in ${PROGRAMS} ; do \
		rm -v "${bin_dir}/$${f}" ; \
	done
	rm -rv "${doc_dir}"
	for f in man/*.1 ; do \
		rm -v "${man1_dir}/$${f}" ; \
	done
