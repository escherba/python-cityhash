PYMODULE := cityhash
EXTENSION := $(PYMODULE).so
SRC_DIR := src
PYPI_URL := https://test.pypi.org/legacy/
EXTENSION_DEPS := $(shell find $(SRC_DIR) -type f -name "*.pyx")
EXTENSION_INTERMEDIATE := $(patsubst %.pyx,%.cpp,$(EXTENSION_DEPS))
EXTENSION_OBJS := $(patsubst %.pyx,%.so,$(EXTENSION_DEPS))

BUILD_STAMP = .build_stamp
ENV_STAMP = env/bin/activate

DISTRIBUTE := sdist bdist_wheel

PYENV := PYTHONPATH=. . env/bin/activate;
INTERPRETER := python3
PACKAGE_MGR := pip3
PYVERSION := $(shell $(INTERPRETER) --version 2>&1)
PYTHON := $(PYENV) $(INTERPRETER)
PIP := $(PYENV) $(PACKAGE_MGR)

VENV_OPTS := ""
ifeq ($(PIP_SYSTEM_SITE_PACKAGES),1)
VENV_OPTS += --system-site-packages
endif

BOLD := $(shell tput bold)
END := $(shell tput sgr0)

.PHONY: package
package: $(DISTRIBUTE)  ## package for distribution (deprecated)
$(DISTRIBUTE): $(BUILD_STAMP) | $(ENV_STAMP)
	@echo "Packaging using $(PYVERSION)"
	$(PYTHON) setup.py $(DISTRIBUTE)

.PHONY: release
release: $(BUILD_STAMP) | $(ENV_STAMP)  ## upload package to PyPI (deprecated)
	@echo "Releasing using $(PYVERSION)"
	$(PYTHON) setup.py $(DISTRIBUTE) upload -r $(PYPI_URL)

.PHONY: shell
shell: build  ## open Python shell within the virtual environment
	@echo "Using $(PYVERSION)"
	$(PYENV) python

.PHONY: build
build: $(EXTENSION_OBJS)  ## build C extension(s)
	@echo "completed $@ target"

$(BUILD_STAMP): $(EXTENSION_DEPS) | $(ENV_STAMP)
	@echo "Building using $(PYVERSION)"
	$(PYTHON) setup.py build_ext --inplace
	@echo "$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')" > $@

$(EXTENSION_OBJS): $(BUILD_STAMP)
	@echo "done building $@"

.PHONY: test
test: build  ## run Python unit tests
	$(PYENV) pytest

.PHONY: nuke
nuke: clean  ## clean and remove virtual environment
	rm -f $(BUILD_STAMP) $(EXTENSION_INTERMEDIATE)
	rm -rf *.egg *.egg-info env
	find $(SRC_DIR) -depth -type d -name *.egg-info -exec rm -rf {} \;

.PHONY: clean
clean:  ## remove temporary files
	$(PYTHON) setup.py clean
	rm -rf dist build __pycache__
	rm -f *.so
	find $(SRC_DIR) -type f -name "*.pyc" -exec rm {} \;
	find $(SRC_DIR) -type f -name "*.cpp" -exec rm {} \;
	find $(SRC_DIR) -type f -name "*.so" -exec rm {} \;

.PHONY: install
install:  $(BUILD_STAMP)  ## install package
	$(PIP) install -e .

.PRECIOUS: $(ENV_STAMP)
.PHONY: env
env: $(ENV_STAMP)  ## set up a virtual environment
$(ENV_STAMP): setup.py requirements.txt
	test -f $@ || $(INTERPRETER) -m venv $(VENV_OPTS) env
	$(PIP) install -U pip wheel
	export SETUPTOOLS_USE_DISTUTILS=stdlib; $(PIP) install -r requirements.txt
	$(PIP) freeze > pip-freeze.txt
	$(PIP) install -e .
	touch $@
