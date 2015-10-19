.PHONY: clean develop env extras package release test virtualenv build_ext

PYMODULE := cityhash
EXTENSION := $(PYMODULE).so
EXTENSION_INTERMEDIATE := ./src/$(PYMODULE).cpp
EXTENSION_DEPS := ./src/$(PYMODULE).pyx
PYPI_HOST := pypi
DISTRIBUTE := sdist bdist_wheel
EXTRAS_REQS := dev-requirements.txt $(wildcard extras-*-requirements.txt)

PYENV := . env/bin/activate;
PYTHON := $(PYENV) python
PIP := $(PYENV) pip


package: env build_ext
	$(PYTHON) setup.py $(DISTRIBUTE)

release: env build_ext
	$(PYTHON) setup.py $(DISTRIBUTE) upload -r $(PYPI_HOST)

build_ext: $(EXTENSION)
	@echo "done building '$(EXTENSION)' extension"

$(EXTENSION): env $(EXTENSION_DEPS)
	$(PYTHON) setup.py build_ext --inplace

test: extras build_ext | test_cpp
	$(PYENV) nosetests $(NOSEARGS)
	$(PYENV) py.test README.rst

nuke: clean
	rm -rf *.egg *.egg-info env

clean: | clean_cpp
	python setup.py clean
	rm -rf dist build
	rm -f $(EXTENSION) $(EXTENSION_INTERMEDIATE)
	find . -path ./env -prune -o -type f -name "*.pyc" -exec rm {} \;

develop:
	@echo "Installing for " `which pip`
	-pip uninstall --yes $(PYMODULE)
	pip install -e .

extras: env/make.extras
env/make.extras: $(EXTRAS_REQS) | env
	rm -rf env/build
	$(PYENV) for req in $?; do pip install -r $$req; done
	touch $@

env virtualenv: env/bin/activate
env/bin/activate: setup.py
	test -f $@ || virtualenv --no-site-packages env
	$(PYENV) easy_install -U pip
	$(PIP) install -U wheel cython
	$(PIP) install -e .
	touch $@
