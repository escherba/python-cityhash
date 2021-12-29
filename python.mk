PYMODULE := cityhash
EXTENSION := $(PYMODULE).so
SRC_DIR := src
EXTENSION_INTERMEDIATE := ./$(SRC_DIR)/$(PYMODULE).cpp
EXTENSION_DEPS := ./$(SRC_DIR)/$(PYMODULE).pyx
PYPI_URL := https://upload.pypi.org/legacy/

DISTRIBUTE := sdist
ifeq ($(shell uname -s),Darwin)
DISTRIBUTE += bdist_wheel
endif

PYENV := PYTHONPATH=. . env/bin/activate;
INTERPRETER := python3
PACKAGE_MGR := pip3
PYVERSION := $(shell $(INTERPRETER) --version 2>&1)
PYTHON := $(PYENV) $(INTERPRETER)
PIP := $(PYENV) $(PACKAGE_MGR)

VENV_OPTS := --python="$(shell which $(INTERPRETER))"
ifeq ($(PIP_SYSTEM_SITE_PACKAGES),1)
VENV_OPTS += --system-site-packages
endif

BOLD := $(shell tput bold)
END := $(shell tput sgr0)

.PHONY: package
package: env build_ext  ## build package
	@echo "Packaging using $(PYVERSION)"
	$(PYTHON) setup.py $(DISTRIBUTE)

# See https://packaging.python.org/guides/migrating-to-pypi-org/
.PHONY: release
release: env build_ext  ## upload package to PyPI
	@echo "Releasing using $(PYVERSION)"
	$(PYTHON) setup.py $(DISTRIBUTE) upload -r $(PYPI_URL)

.PHONY: shell
shell: build_ext  ## open Python shell within the virtualenv
	@echo "Using $(PYVERSION)"
	$(PYENV) python

.PHONY: build_ext
build_ext: $(EXTENSION)  ## build C extension(s)
	@echo "done building '$(EXTENSION)' extension"

$(EXTENSION): env $(EXTENSION_DEPS)
	@echo "Building using $(PYVERSION)"
	$(PYTHON) setup.py build_ext --inplace

.PHONY: test
test: build_ext  ## run Python unit tests
	$(PYENV) pytest
	$(PYENV) pytest README.rst

.PHONY: nuke
nuke: clean  ## clean and remove virtual environment
	rm -f $(EXTENSION_INTERMEDIATE)
	rm -rf *.egg *.egg-info env
	find $(SRC_DIR) -depth -type d -name *.egg-info -exec rm -rf {} \;

.PHONY: clean
clean:  ## remove temporary files
	python setup.py clean
	rm -rf dist build __pycache__
	rm -f *.so
	find $(SRC_DIR) -type f -name "*.pyc" -exec rm {} \;
	find $(SRC_DIR) -type f -name "*.cpp" -exec rm {} \;
	find $(SRC_DIR) -type f -name "*.so" -exec rm {} \;

.PHONY: install
install:  build_ext  ## install package
	@echo "Installing for " `which pip`
	-pip uninstall --yes $(PYMODULE)
	pip install -e .

.PRECIOUS: env/bin/activate
.PHONY: env
env: env/bin/activate  ## set up a virtual environment
env/bin/activate: setup.py requirements.txt
	test -f $@ || virtualenv $(VENV_OPTS) env
	export SETUPTOOLS_USE_DISTUTILS=stdlib; $(PYENV) curl https://bootstrap.pypa.io/ez_setup.py | $(INTERPRETER)
	$(PIP) install -U pip
	export SETUPTOOLS_USE_DISTUTILS=stdlib; $(PIP) install -r requirements.txt
	$(PIP) install -e .
	$(PIP) freeze > pip-freeze.txt
	touch $@
