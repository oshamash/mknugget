_I:=

# Run command directly
# ${_I} will allow multiple calls in same target
define time_it_verbose
	$(eval $@_TIMEFILE${$@_I}:=$(shell mktemp /tmp/timeit-time.XXXXXXX))
	@date +%s > ${$@_TIMEFILE${$@_I}}
	$(call log, ($(strip $(1)), g0dsp33d  ...))
	+@bash -c '$(strip $(2))' || bash -c 'rm ${$@_TIMEFILE${$@_I}} && false'
	$(call log, ($(strip $(1)), took $$(($$(date +%s)-$$(cat ${$@_TIMEFILE${$@_I}}))) seconds))
	@rm ${$@_TIMEFILE${$@_I}}
	$(eval $@_I:=${$@_I}_)
endef


# ${_I} will allow multiple calls in same target
# Run command redirecting output to tmp-file, error/out will be printed on error 
# line-2: @bash -c "while [ -e /proc/$(strip $(shell ps -o ppid= -p $$$$)) ] ; do sleep 0.7 ; done && rm -f ${$@_TMPFILE${$@_I}}" &
define time_it
	$(eval $@_TMPFILE${$@_I}:=$(shell mktemp /tmp/timeit-log.XXXXXXX))
	$(eval $@_TIMEFILE${$@_I}:=$(shell mktemp /tmp/timeit-time.XXXXXXX))
	@date +%s > ${$@_TIMEFILE${$@_I}}
	$(call log, ($(strip $(1)), g0dsp33d  ...))
	+@bash -c '$(strip $(2))' > ${$@_TMPFILE${$@_I}} 2>&1 && rm ${$@_TMPFILE${$@_I}} || bash -c "cat ${$@_TMPFILE${$@_I}} && rm ${$@_TMPFILE${$@_I}} ${$@_TIMEFILE${$@_I}} && false"
	$(call log, ($(strip $(1)), took $$(($$(date +%s)-$$(cat ${$@_TIMEFILE${$@_I}}))) seconds))
	@rm ${$@_TIMEFILE${$@_I}}
	$(eval $@_I:=${$@_I}_)
endef


# Behold da magic
define time_it_NOTPARALLEL
	$(eval $@_PIDFILE${$@_I}:=$(shell mktemp /tmp/timeit_once-pid.XXXXXXX))
	$(eval $@_TMPFILE${$@_I}:=$(shell mktemp /tmp/timeit_once-log.XXXXXXX))
	$(eval $@_TIMEFILE${$@_I}:=$(shell mktemp /tmp/timeit-time.XXXXXXX))
	$(call log_printf, ($(strip $(1)), g0dsp33d ))
	@bash -c 'while [ -e /proc/$(strip $(shell ps -o ppid= -p $$$$)) ] ; do printf "\033[01;89m.\033[0m" && sleep 0.7 ; done \
		&& rm -f ${$@_TIMEFILE${$@_I}} ${$@_TMPFILE${$@_I}} ${$@_PIDFILE${$@_I}}' & echo "$$!" > ${$@_PIDFILE${$@_I}}
	@date +%s > ${$@_TIMEFILE${$@_I}}
	+@bash -c '$(strip $(2))' 2>&1 > ${$@_TMPFILE${$@_I}} && kill `cat ${$@_PIDFILE${$@_I}}` && \
		rm -f ${$@_TMPFILE${$@_I}} ${$@_PIDFILE${$@_I}} || bash -c "kill `cat ${$@_PIDFILE${$@_I}}` && \
		echo -e '\n$(strip $(2)):' && cat ${$@_TMPFILE${$@_I}} && rm -f ${$@_TIMEFILE${$@_I}} ${$@_TMPFILE${$@_I}} ${$@_PIDFILE${$@_I}} && false"
	@echo ''
	$(call relog, ($(strip $(1)), took $$(($$(date +%s)-$$(cat ${$@_TIMEFILE${$@_I}}))) seconds))
	@rm -f ${$@_TIMEFILE${$@_I}}
	$(eval $@_I:=${$@_I}_)
endef

define generate_folder_hash
	$(call time_it, Hash (MD5SUM) ($(strip $1)) , \
		find $(strip $1) -type f \
			\( $$(awk 'BEGIN{ORS=" -and "} y{print s}{s="-not -name "$$0; y=1}END{ORS=""; print s}' ${ROOT}/.hashignore) \) \
			-print0 | sort -z | xargs -0 -L1 -I{} md5sum {} > $(strip $1)/$(strip $2))
endef

define validate_generated_path
	$(call generate_folder_hash, $(1), md5sum_validate.txt)
	@if [ ! -e $(strip $1)/md5sum.txt ]; then \
		echo "\033[31m\033[1m$(1)/md5sum.txt Doesn't exist! create initial version\33[0m"; \
		false; \
	fi
	@if [ "$$(diff $(strip $1)/md5sum.txt $(strip $1)/md5sum_validate.txt | wc -l)" != "0" ]; then \
		echo "\033[31m\033[1m$(strip $2)\33[0m"; \
		diff $(strip $1)/md5sum.txt $(strip $1)/md5sum_validate.txt; \
		echo "diff returned $$?"; \
		false; \
	fi
endef

