LOG_PREFIX:="\033[01;93m[MAKE] $$(date "+[%F %T.%s]")\033[0m "
LOG_PREFIX_LEN:=$(shell expr length "[MAKE] [1900-01-01 00:00:00.0000000000] ")
LOG_PREFIX_FMT_LEN:=$(shell expr ${LOG_PREFIX_LEN} + 1)

# NOTE(OS): not reusing functions as running "make -j" makes the logs overwrite themselves otherwise

# Better to not ask questions - it works
# but if you still insist - see https://vasvir.wordpress.com/2021/03/25/gnu-make-function-arguments-with-comma/
#	Usage example 1: $(call log, LOG_MSG)
#		Output: [MAKE] [DATE_AND_TIME] LOG_MSG
#	Usage exmaple 2: $(call log, (here we, use, commas, and parentheses ()()() and it works,,()))
#		Output: [MAKE] [DATE_AND_TIME] here we, use, commas, and parentheses ()()() and it works,,()
define printf_format
	@printf "\033[01;89m%s\033[0m" "`echo \"$(subst \,\\\,$(strip $1))\" | sed -e 's/^\s*(\|)$$//g'`"
endef

define echo_format
	@echo "\033[01;89m`echo \"$(subst \,\\\,$(strip $1))\" | sed -e 's/^\s*(\|)$$//g'`\033[0m"
endef

define log
	@echo ${LOG_PREFIX}"\033[01;89m`echo \"$(subst \,\\\,$(strip $1))\" | sed -e 's/^\s*(\|)$$//g'`\033[0m"
endef

define log_printf
	@printf ${LOG_PREFIX}"\033[01;89m%s\033[0m" "`echo \"$(subst \,\\\,$(strip $1))\" | sed -e 's/^\s*(\|)$$//g'`"
endef

define relog
	@echo "\033[1A\033[${LOG_PREFIX_LEN}C\033[0K\033[01;89m`echo \"$(subst \,\\\,$(strip $1))\" | sed -e 's/^\s*(\|)$$//g'`\033[0m"
endef

define log_title_sep
	$(eval COLS_$@:=$(or $(strip $2),140))
	$(call log, $(shell printf '$(strip $1)%.0s' $(shell seq ${LOG_PREFIX_FMT_LEN} ${COLS_$@})))
endef

define log_title
	$(call log_title_sep, $1, $3)
	$(eval MSG_LEN_$@:= $(shell echo '$(strip $2)' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | wc -m))
	$(call log_printf,)
	@printf '\033[01;89m%*s%b%*s\033[0m\n' \
		'-$(shell python3 -c "import math; print(math.ceil((${COLS_$@} - ${LOG_PREFIX_LEN} - ${MSG_LEN_$@}) / 2))")' '$(strip $1)' \
		'$(strip $2)' \
		'$(shell python3 -c "import math; print(math.floor((${COLS_$@} - ${LOG_PREFIX_LEN} - ${MSG_LEN_$@}) / 2) + 1)")' '$(strip $1)'
	$(call log_title_sep, $1, $3)
endef
