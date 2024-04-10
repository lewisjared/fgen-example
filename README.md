# Fgen Example

<!---
Can use start-after and end-before directives in docs, see
https://myst-parser.readthedocs.io/en/latest/syntax/organising_content.html#inserting-other-documents-directly-into-the-current-document
-->

<!--- sec-begin-description -->

Example project using fgen to wrap a simple module



[![CI](https://github.com/lewisjared/fgen-example/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/lewisjared/fgen-example/actions/workflows/ci.yaml)
[![Coverage](https://codecov.io/gh/climate-resource/fgen-example/branch/main/graph/badge.svg)](https://codecov.io/gh/climate-resource/fgen-example)
[![Docs](https://readthedocs.org/projects/fgen-example/badge/?version=latest)](https://fgen-example.readthedocs.io)

**PyPI :**
[![PyPI](https://img.shields.io/pypi/v/fgen-example.svg)](https://pypi.org/project/fgen-example/)
[![PyPI: Supported Python versions](https://img.shields.io/pypi/pyversions/fgen-example.svg)](https://pypi.org/project/fgen-example/)
[![PyPI install](https://github.com/lewisjared/fgen-example/actions/workflows/install.yaml/badge.svg?branch=main)](https://github.com/lewisjared/fgen-example/actions/workflows/install.yaml)

**Other info :**
[![License](https://img.shields.io/github/license/lewisjared/fgen-example.svg)](https://github.com/lewisjared/fgen-example/blob/main/LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/lewisjared/fgen-example.svg)](https://github.com/lewisjared/fgen-example/commits/main)
[![Contributors](https://img.shields.io/github/contributors/lewisjared/fgen-example.svg)](https://github.com/lewisjared/fgen-example/graphs/contributors)


<!--- sec-end-description -->

Full documentation can be found at:
[fgen-example.readthedocs.io](https://fgen-example.readthedocs.io/en/latest/).
We recommend reading the docs there because the internal documentation links
don't render correctly on GitHub's viewer.

## Installation

<!--- sec-begin-installation -->

TODO: set up this part of the workflow and test it (https://gitlab.com/magicc/copier-fgen-based-repository/-/issues/5)

Fgen Example can be installed with conda or pip:

```bash
pip install fgen-example
conda install -c conda-forge fgen-example
```


<!--- sec-end-installation -->

### For developers

<!--- sec-begin-installation-dev -->

```sh
make virtual-environment
make fgen-wrappers
make build-fgen
make install
make test
```

TODO: update this because we have non-Python dependencies (related to https://gitlab.com/magicc/copier-fgen-based-repository/-/issues/6)

For development, we rely on [poetry](https://python-poetry.org) for all our
dependency management. To get started, you will need to make sure that poetry
is installed
([instructions here](https://python-poetry.org/docs/#installing-with-the-official-installer),
we found that pipx and pip worked better to install on a Mac).

For all of our work, we use our `Makefile`.
You can read the instructions out and run the commands by hand if you wish,
but we generally discourage this because it can be error prone.
In order to create your environment, run `make virtual-environment`.

If there are any issues, the messages from the `Makefile` should guide you
through. If not, please raise an issue in the [issue tracker][issue_tracker].

For the rest of our developer docs, please see [](development-reference).

[issue_tracker]: https://github.com/lewisjared/fgen-example/issues

<!--- sec-end-installation-dev -->
