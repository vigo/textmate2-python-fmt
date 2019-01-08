![Version](https://img.shields.io/badge/version-3.4.1-orange.svg)
![Plaftorm](https://img.shields.io/badge/platform-TextMate-blue.svg)
![Python 3.7+](https://img.shields.io/badge/python-3.7+-blue.svg)
![macOS](https://img.shields.io/badge/macos-HighSierra-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Mojave-yellow.svg)
![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)

# Python FMT bundle for TextMate

> Hit <kbd>⌘</kbd> + <kbd>S</kbd> I’ll handle the rest!

This little TextMate bundle helps you to write better and safer Python code.
Using TextMate’s before/after event callbacks to check/format/lint your
Python code. Integrated tools are:

| Tool         | Descriptiopn                             |
|:-------------|:-----------------------------------------|
| [isort][01]  | Sorts `import` statements                |
| [black][02]  | Format source code                       |
| [pylint][03] | Check errors before run it!              |
| [flake8][04] | Linting, checking source code with ease! |

---

Before Python FMT for TextMate

![Before Python FMT for TextMate bundle](Screenshots/before.png?2 "before Python FMT for TextMate")

After Python FMT for TextMate

![After Python FMT for TextMate](Screenshots/after.png?2 "after Python FMT for TextMate")

After pylint/flake8 running

![After Python FMT for TextMate](Screenshots/after-checks.png?2 "after Python FMT for TextMate")

Error information

![After Python FMT for TextMate](Screenshots/after-checks-errors.png?2 "after Python FMT for TextMate")

---

## Installation

Checker your Python binary. You need Python 3+.

```bash
$ which python
/Users/vigo/.pyenv/shims/python                  # or
$ pyenv which python
/Users/vigo/.pyenv/versions/3.7.0/bin/python
```

You need to set `TM_PYTHON_FMT_PYTHON_PATH` variable (**TextMate > Preferences > Variables**)
and set the value according to the result above.


```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/
$ git clone https://github.com/vigo/textmate2-python-fmt.git Python-FMT.tmbundle
```

Now install python packages:

```bash
$ cd Python-FMT.tmbundle/
$ pip install -r requirements.txt
```

Bundled `flake8` plugins are:

* `flake8-bandit`: For writing secure code!
* `flake8-blind-except`: Checks for blind, catch-all `except:` statements.
* `flake8-bugbear`: A plugin for Flake8 finding likely bugs and design problems in your program.
* `flake8-builtins`: Check for python builtins being used as variables or parameters
* `flake8-print`: Checks for `print` statements in python files.
* `flake8-quotes`: Install this if you are single quote person like me!
* `flake8-string-format`: Checks for strings and parameters using `str.format`

Now you can restart TextMate!

---

## Hot Keys and Snippets

| Hot Keys and TAB Completions    | Description                                                                                                                                                                                           |
|:--------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <kbd>⌘</kbd> + <kbd>{</kbd>    | Bypass selection while formatting with `black`. This adds `# fmt: off` and `# fmt: on` to beginning and ending of selection.<br>Used James Edward Gray II’s commenting tool which ships with TextMate. |
| <kbd>noq</kbd> + <kbd>⇥</kbd>  | Choose desired bypass method                                                                                                                                                                           |
| <kbd>envi</kbd> + <kbd>⇥</kbd> | Inserts helpful environment variables if you are editing on `.tm_properties` file. Try :)                                                                                                              |

## TextMate Variables

| Variable                             | Information                                                                                                         |
|:-------------------------------------|:--------------------------------------------------------------------------------------------------------------------|
| `TM_PYTHON_FMT_PYTHON_PATH`          | Binary location of your `python` executable :)                                                                      |
| `TM_PYTHON_FMT_ISORT`                | Binary location for `isort`. To set custom binary, enter full path here. Example: `/path/to/isort`                  |
| `TM_PYTHON_FMT_VIRTUAL_ENV`          | Good for `isort`. Use `.tm_properties` file to set this. If set, passes `--virtual-env` to `isort` with given value |
| `TM_PYTHON_FMT_BLACK`                | Binary location for `black`. To set custom binary, enter full path here. Example: `/path/to/black`                  |
| `TM_PYTHON_FMT_FLAKE8`               | Binary location for `flake8`. To set custom binary, enter full path here. Example: `/path/to/black`                 |
| `TM_PYTHON_FMT_FLAKE8_DEFAULTS`      | Unless `.flake8` or `setup.cfg` doesn’t exists, this parameters will be used as defaults for `flake8` configuration |
| `TM_PYTHON_FMT_PYLINT`               | Binary location for `pylint`. To set custom binary, enter full path here. Example: `/path/to/pylint`                |
| `TM_PYTHON_FMT_PYLINTRC`             | Location of `pylintrc` or `.pylintrc` file if you like to set                                                       |
| `TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS` | You can pass additional options/params to `pylint`.                                                                 |
| `TM_PYTHON_FMT_BLACK_DEFAULTS`       | Unless `pyproject.toml` doesn’t exists, this parameters will be used if provided                                    |
| `TM_PYTHON_FMT_ISORT_DEFAULTS`       | Unless `.isort.cfg` doesn’t exists, this parameters will be used if provided                                        |
| `TM_PYTHON_FMT_DISABLE`              | You this variable if you need to disable this bundle temporarily                                                    |

Using `pylint` to display compile-time errors only. This means, using
`--errors-only` option. Also, for `flake8` and `pylint` using same
error output format:

    LINE_NUMBER || COLUMN_NUMBER || ERROR_CODE || ERROR_MESSAGE

You can pass extra arguments via `TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS`. Set this
variable in TextMate’s global settings (**TextMate > Preferences > Variables**.)
or set it in `.tm_properties`. Space delimited arguments required...

Example `.tm_properties` usage:

    TM_PYTHON_FMT_VIRTUAL_ENV=/Users/YOU/.virtualenvs/YOUR_VENV   # or
    TM_PYTHON_FMT_VIRTUAL_ENV=$HOME/.virtualenvs/YOUR_VENV        # or
                                                                  # It’s ok to use shell variables and TextMate variables but
                                                                  # never user like this: `~/.virtualenvs/ENV`
    TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS=--py3k
    TM_PYTHON_FMT_PYLINTRC=$TM_PROJECT_DIRECTORY/.pylintrc        # or
    TM_PYTHON_FMT_PYLINTRC=/path/to/.pylintrc                     # or

Also, you can set project based configurations for all of the tools. Check
their official documentations:

- https://github.com/timothycrosley/isort/wiki/isort-Settings
- https://github.com/ambv/black#pyprojecttoml
- http://flake8.pycqa.org/en/latest/user/configuration.html#configuration-locations
- https://pylint.readthedocs.io/en/latest/user_guide/run.html#command-line-options

### Example Configurations

For a Django project, `pyproject.toml`:

```toml
[tool.black]
line-length = 119
py36 = true
skip-string-normalization = true
quiet = true
exclude='''
/(
    \.git
  | \.hg
  | \.tox
  | \.venv
  | _build
  | buck-out
  | build
  | dist
)/
'''
```

and `setup.cfg`:

```cfg
[flake8]
max-line-length = 119

[isort]
line_length = 60
multi_line_output = 3
use_parentheses = true
include_trailing_comma = true
quiet = true
force_grid_wrap = 0
known_django = django
sections = FUTURE,STDLIB,DJANGO,THIRDPARTY,FIRSTPARTY,LOCALFOLDER
```

I like **Vertical Hanging Ident**, If you use this `isort` configuration,
you’ll have something like this:

```python
from django.contrib.postgres.fields import (
    ArrayField,
    JSONField
)
from django.db import models
from django.utils.translation import ugettext_lazy as _
from mptt.models import (
    MPTTModel,
    TreeForeignKey,
    TreeManyToManyField
)

from ..models import (
    BaseModelWithSoftDelete,
    BaseModelWithSoftDeleteQuerySet
)
```


---


---

## Contributer(s)

* [Uğur "vigo" Özyılmazel](https://github.com/vigo) - Creator, maintainer


---


## Contribute

All PR’s are welcome!

1. `fork` (https://github.com/vigo/textmate2-python-fmt/fork)
1. Create your `branch` (`git checkout -b my-features`)
1. `commit` yours (`git commit -am 'added killer options'`)
1. `push` your `branch` (`git push origin my-features`)
1. Than create a new **Pull Request**!


---


## License

This project is licensed under MIT


---


## Change Log

**2019-01-08**

* Fix missing environment variable for python executable: `TM_PYTHON_FMT_PYTHON_PATH`
* You can disable this bundle temporarily via `TM_PYTHON_FMT_DISABLE` variable.

**2018-12-27**

* Now using `TM_PYTHON_FMT_PYTHON_PATH` instead of `TM_PYTHON`. You must fix
  this, otherwise your bundle will not work!

**2018-12-23**

* `TM_PYTHON_FMT_FLAKE8_DEFAULTS` env-var for setting defaults for `flake8`
* `env` + <kbd>⇥</kbd> changed to `envi` + <kbd>⇥</kbd> due to other TM bundle collision.
* Bundle menu grouping for `tm_properties` helper

**2018-11-29**

* `TM_PYTHON_FMT_BLACK_DEFAULTS` env-var for setting `black` defaults.
* `TM_PYTHON_FMT_ISORT_DEFAULTS` env-var for setting `isort` defaults.
* `TM_PYTHON_FMT_DEBUG` env-var for debugging.


**2018-11-21**

* Monkeypatch: `flake8-bandit` causes warning: `Possible nested set at position 1`
* Version bump to: 3.1.0

**2018-11-19**

* Update: Added missing information on `README.md`
* Update: Virtual Environmet support for `pylint`
* Update: `pylintrc` support for `pylint`
* Fix: `isort:skip_file` bug
* Addition: <kbd>env</kbd> + <kbd>⇥</kbd> for environment variables
* Change: All the bypass declarations are using <kbd>noq</kbd> + <kbd>⇥</kbd>
* Version bump to: 3.0.5

**2018-11-18**

* Upgrade: Rewritten from scratch. `autopep8` removed.

**2018-11-17**

* Update: `black` integration
* `flake8-commas` removed.

**2018-11-15**

* Update: `setup.cfg` config file support added.

**2018-11-14**

* Fix: Added `--trailing-comma` for isort imports
* Added: List of `flake8` plugins

**2018-10-28**

* `TM_PYTHON_FMT_DEBUG` if set, you’ll see running commands
* Version is now `2.1.4`

**2018-10-24**

* Fix: Added missing `git clone` information
* Fix: runners.
* Version is now `2.1.3`

**2018-10-24**

* Bundle re-written from scratch
* Now using `callback.document.will-save` and `callback.document.did-save` hooks
* `isort` support added
* Version is now `2.1.0`

**2017-07-02**

* Updated: README file. Added useful setup instructions.
* Added: Badges :)

**2017-05-14**

* Updated: Success tooltip message now shows maximum characters value
* Updated: Screenshot of `before-and-after-flake8.png`
* Changed: Overriding default save keys (<kbd>⌘</kbd> + <kbd>S</kbd>) was a bad idea :)

**2017-05-13**

* First release :)

**2017-05-06**

* Initial commit


[01]: https://pypi.python.org/pypi/isort "isort fixes import order"
[02]: https://pypi.python.org/pypi/black "black code formatter"
[03]: https://pypi.python.org/pypi/pylint "pylint source code checker"
[04]: https://pypi.python.org/pypi/flake8 "flake8 source code checker"
