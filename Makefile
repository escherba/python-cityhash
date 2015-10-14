.PHONY: clean develop env extras package release test virtualenv build_ext

PYMODULE := cityhash
EXTENSION := $(PYMODULE)
PYENV := . env/bin/activate;
PYTHON := $(PYENV) python
PIP := $(PYENV) pip
DISTRIBUTE := sdist bdist_wheel
EXTRAS_REQS := dev-requirements.txt $(wildcard extras-*-requirements.txt)


package: env
	$(PYTHON) setup.py $(DISTRIBUTE)

release: env
	$(PYTHON) setup.py $(DISTRIBUTE) upload -r livefyre

build_ext: $(EXTENSION).so
	@echo "finished building extension"

$(EXTENSION).so:
	$(PYTHON) setup.py build_ext --inplace

test: extras $(EXTENSION).so
	$(PYENV) nosetests $(NOSEARGS)
	$(PYENV) py.test README.rst

nuke: clean
	rm -rf *.egg *.egg-info env

clean:
	python setup.py clean
	rm -rf dist build
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
	$(PIP) install -U pip wheel
	$(PIP) install cython
	$(PIP) install -e .
	touch $@
