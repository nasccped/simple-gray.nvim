NVIM_EXEC=nvim
TEST_RUNNER=./test-aux/runner.lua
NVIM_TEST_FLAGS=--headless -u $(TEST_RUNNER)

test: $(TEST_RUNNER)
	$(NVIM_EXEC) $(NVIM_TEST_FLAGS)

.PHONY: test
