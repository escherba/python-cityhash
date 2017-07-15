.PHONY: clean develop env extras package release test virtualenv build_ext

PYMODULE := cityhash
EXTENSION := $(PYMODULE).so
SRC_DIR := src
EXTENSION_INTERMEDIATE := ./$(SRC_DIR)/$(PYMODULE).cpp
EXTENSION_DEPS := ./$(SRC_DIR)/$(PYMODULE).pyx
PYPI_URL := https://upload.pypi.org/legacy/
UNAME_S := $(shell uname -s)
DISTRIBUTE := sdist
ifeq ($(UNAME_S),Darwin)
	DISTRIBUTE += bdist_wheel
endif
EXTRAS_REQS := dev-requirements.txt $(wildcard extras-*-requirements.txt)

PYENV := PYTHONPATH=. . env/bin/activate;
INTERPRETER := python3
PACKAGE_MGR := pip3
PYVERSION := $(shell $(INTERPRETER) --version 2>&1)
PYTHON := $(PYENV) $(INTERPRETER)
PIP := $(PYENV) $(PACKAGE_MGR)


package: env build_ext
	@echo "Packaging using $(PYVERSION)"
	$(PYTHON) setup.py $(DISTRIBUTE)

# See https://packaging.python.org/guides/migrating-to-pypi-org/
release: env build_ext
	@echo "Releasing using $(PYVERSION)"
	$(PYTHON) setup.py $(DISTRIBUTE) upload -r $(PYPI_URL)

shell: extras build_ext
	@echo "Using $(PYVERSION)"
	$(PYENV) $(ENV_EXTRA) ipython

build_ext: $(EXTENSION)
	@echo "done building '$(EXTENSION)' extension"

$(EXTENSION): env $(EXTENSION_DEPS)
	@echo "Building using $(PYVERSION)"
	$(PYTHON) setup.py build_ext --inplace

test: extras build_ext
	$(PYENV) nosetests $(NOSEARGS)
	$(PYENV) py.test README.rst

nuke: clean
	rm -f $(EXTENSION_INTERMEDIATE)
	rm -rf *.egg *.egg-info env

clean:
	python setup.py clean
	rm -rf dist build
	rm -f $(EXTENSION)
	find $(SRC_DIR) -type f -name "*.pyc" -exec rm {} \;
	find $(SRC_DIR) -type f -name "*.cpp" -exec rm {} \;
	find $(SRC_DIR) -type f -name "*.so" -exec rm {} \;

develop:
	@echo "Installing for " `which pip`
	-pip uninstall --yes $(PYMODULE)
	pip install -e .

extras: env/make.extras
env/make.extras: $(EXTRAS_REQS) | env
	rm -rf env/build
	$(PYENV) for req in $?; do pip install -r $$req; done
	touch $@

VENV_OPTS := --python="$(shell which $(INTERPRETER))"
ifeq ($(PIP_SYSTEM_SITE_PACKAGES),1)
VENV_OPTS += --system-site-packages
else
VENV_OPTS += --no-site-packages
endif

env virtualenv: env/bin/activate
env/bin/activate: setup.py
	test -f $@ || virtualenv $(VENV_OPTS) env
	$(PYENV) curl https://bootstrap.pypa.io/ez_setup.py | $(INTERPRETER)
	$(PIP) install -U pip
	$(PIP) install -U markerlib
	$(PIP) install -U wheel
	$(PIP) install -U cython
	$(PIP) install -e .
	touch $@
