NVIM_EXEC=nvim
TEST_RUNNER=./test-aux/runner.lua
NVIM_TEST_FLAGS=--headless -u $(TEST_RUNNER)
NVIM_PREPEND_CMD='lua vim.opt.rtp:prepend(".")'

test: $(TEST_RUNNER)
	$(NVIM_EXEC) $(NVIM_TEST_FLAGS)

launch:
	nvim -c $(NVIM_PREPEND_CMD)

.PHONY: test launch
