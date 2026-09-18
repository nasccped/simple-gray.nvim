GT=git
NV=nvim

TESTS=./tests
TEST_DEPS=./test-deps
SCRIPTS=./scripts

TEST_INIT=$(SCRIPTS)/test_init.lua
LAUNCH=$(SCRIPTS)/launch.lua
MINI_PATH=$(TEST_DEPS)/mini.nvim
MINI_URL=https://github.com/nvim-mini/mini.nvim

CLONE_FLAGS=--depth=1 --filter=blob:none
TEST_FLAGS=--headless

# create deps dir if not exists
$(TEST_DEPS):
	mkdir $@

# clones mini.nvim if not exists
$(MINI_PATH): $(TEST_DEPS)
	$(GT) clone $(CLONE_FLAGS) $(MINI_URL) $@

# testing requires mini.nvim dep
test: $(TESTS) $(MINI_PATH) $(TEST_INIT)
	$(NV) $(TEST_FLAGS) -u $(TEST_INIT) -c "lua MiniTest.run()"

# easily launch neovim without adding plugin to config dir.
launch: $(LAUNCH) $(MINI_PATH)
	$(NV) -c "source $(LAUNCH)"

# remove testing dependencies
clean: $(TEST_DEPS)
	rm -rf $<

.PHONY: test launch clean
