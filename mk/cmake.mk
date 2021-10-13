CMAKE ?= cmake

define build_cmake_project
	$(call log, building $(strip $(1)))
	@mkdir -p $(1)/build$(3)

	$(call log, (invoking cmake (configure) for $(strip $(1))))
	$(call time_it, CONFIGURE, cd $(1)/build$(3) && ${CMAKE} .. $(2))

	$(call log, (invoking cmake (make-build) for $(strip $(1))))
	$(call time_it_verbose, MAKE $(strip $(1)), ${MAKE} $(4) -C $(1)/build$(3))

	$(call log, (invoking cmake (make-install) for $(strip $(1))))
	$(call time_it, MAKE $(strip $(1)), ${MAKE} install -C $(1)/build$(3))
endef
