# Include all sub-makes

# no deps
include mk/env.mk
include mk/logger.mk

# depends on logger
include mk/utils.mk
include mk/cmake.mk

.PHONY: list_targets

# Help DBUILD
list_targets:
	@grep -E '^[a-zA-Z0-9_-]+:([^=]+|$$)' $(MAKEFILE_LIST) \
	| awk -F ':' '{ print $$2 }' \
	| sort | column -s '\n' -c 200

test_log_title:
	$(call log_title, =, Creating TITLE (190) (=) \033[32mw00t!\033[0m, 190)
	$(call log_title, -, Creating TITLE (180) (-) \033[32mw00t!\033[0m, 180)
	$(call log_title, _, Creating TITLE (170) (_) \033[32mw00t!\033[0m, 170)
	$(call log_title, !, Creating TITLE (160) (!) \033[32mw00t!\033[0m, 160)
	$(call log_title, ~, Creating TITLE (150) (~) \033[32mw00t!\033[0m, 150)
	$(call log_title, *, Creating TITLE (DEF) (*) \033[32mw00t!\033[0m)

test_timer_ok:
	$(call time_it, \033[32mTIMER-OK\033[0m, echo OK && sleep 4)
test_timer_fail:
	$(call time_it, \033[31mTIMER-FAIL\033[0m, echo FAIL && sleep 4 && false)

test_timer_verbose_ok:
	$(call time_it_verbose, \033[32mTIMER-V-OK\033[0m, echo PRE-SLEEP && sleep 4 && echo 'OK')
test_timer_verbose_fail:
	$(call time_it_verbose, \033[31mTIMER-V-FAIL\033[0m, echo PRE-SLEEP && sleep 4 && echo 'FAIL' && false)

test_timer_multi_ok:
	$(call time_it, sleep-1, sleep 1)
	$(call time_it, sleep-1, sleep 1)
	$(call time_it, sleep-1, sleep 1)
	$(call time_it, sleep-1, sleep 1)
	$(call time_it, sleep-1, sleep 1)

.NOTPARALLEL: test_time_it_NOTPARALLEL
test_timer_notparallel:
	$(call time_it_NOTPARALLEL, test time-it (NOTPARALLEL), sleep 4)
test_timer_notparallel_multi:
	$(call time_it_NOTPARALLEL, sleep-3, sleep 3)
	$(call time_it_NOTPARALLEL, sleep-3, sleep 3)
	$(call time_it_NOTPARALLEL, sleep-3, sleep 3)
