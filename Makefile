# Makefile to help automate key steps

.DEFAULT_GOAL := help
INSTALL_PREFIX := 'dist'
# Will likely fail on Windows, but Makefiles are in general not Windows
# compatible so we're not too worried
TEMP_FILE := $(shell mktemp)
CMAKE_LANG_CONFIG_FILE := '.cmakelang.yaml'
CMAKE_LISTS_FILES := 'CMakeLists.txt src/fgen_example/_lib/CMakeLists.txt'

# A helper script to get short descriptions of each target in the Makefile
define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([\$$\(\)a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-30s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT


help:  ## print short description of each target
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

.PHONY: checks
checks:  ## run all the linting checks of the codebase
	@echo "=== pre-commit ==="; poetry run pre-commit run --all-files || echo "--- pre-commit failed ---" >&2; \
		echo "=== mypy ==="; MYPYPATH=stubs poetry run mypy src || echo "--- mypy failed ---" >&2; \
		echo "=== cmake-lint ==="; poetry run cmake-lint $(CMAKE_LISTS_FILES) -c $(CMAKE_LANG_CONFIG_FILE) || echo "--- cmake-lint failed ---" >&2; \
		echo "======"

.PHONY: black
black:  ## format the code using black
	poetry run black src tests docs/source/conf.py scripts docs/source/notebooks/*.py
	poetry run blackdoc src

.PHONY: ruff-fixes
ruff-fixes:  ## fix the code using ruff
	poetry run ruff src tests scripts docs/source/conf.py docs/source/notebooks/*.py --fix

.PHONY: cmake-format
cmake-format:  ## format the `CMakeLists.txt` files
	poetry run cmake-format $(CMAKE_LISTS_FILES) -i -c $(CMAKE_LANG_CONFIG_FILE) --log-level debug

.PHONY: test
test:  ## run the tests
	# Need project name after cov in case we don't do an editable install
	poetry run pytest src tests -r a -v --doctest-modules --cov fgen_example

.PHONY: docs
docs:  ## build the docs
	poetry run sphinx-build -T -b html docs/source docs/build/html

.PHONY: changelog-draft
changelog-draft:  ## compile a draft of the next changelog
	poetry run towncrier build --draft

.PHONY: licence-check
licence-check:  ## Check that licences of the dependencies are suitable
	# Will likely fail on Windows, but Makefiles are in general not Windows
	# compatible so we're not too worried
	poetry export --without=tests --without=docs --without=dev > $(TEMP_FILE)
	poetry run liccheck -r $(TEMP_FILE) -R licence-check.txt
	rm -f $(TEMP_FILE)

.PHONY: virtual-environment
virtual-environment:  ## update virtual environment, create a new one if it doesn't already exist
	poetry lock --no-update
	# Put virtual environments in the project
	poetry config --local virtualenvs.in-project true
	poetry install --all-extras
	poetry self add poetry-plugin-export
	# Use pip (not poetry) to build and install the extension module
	poetry run pip install -e .
	poetry run pre-commit install
