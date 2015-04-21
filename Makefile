.PHONY: clean develop env extras package release test virtualenv

PYENV = . env/bin/activate;
PYTHON = $(PYENV) python
DISTRIBUTE = sdist bdist_wheel

package: env
	$(PYTHON) setup.py $(DISTRIBUTE)

release: env
	$(PYTHON) setup.py $(DISTRIBUTE) upload -r livefyre

test: extras
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
	pip uninstall $(PYMODULE) || true
	python setup.py develop

env virtualenv: env/bin/activate
env/bin/activate: setup.py
	test -f $@ || virtualenv --no-site-packages env
	$(PYENV) pip install -U pip wheel
	$(PYENV) pip install -e .
	touch $@
