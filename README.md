![Version](https://img.shields.io/badge/version-3.0.1-orange.svg)
![Plaftorm](https://img.shields.io/badge/platform-TextMate-blue.svg)
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

## Installation: `pyenv` Users

Checker your Python binary. Python 3+ recommended:

```bash
$ pyenv which python
/Users/vigo/.pyenv/versions/3.7.0/bin/python     # example output, use this for TM_PYTHON
```

Check your `TM_PYTHON` variable from **TextMate > Preferences > Variables**.
Set to:

        TM_PYTHON    /Users/vigo/.pyenv/versions/3.7.0/bin/python

Now install packages:

```bash
$ pip install isort black flake8 pylint
```


Now clone the repo:

```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/
$ git clone https://github.com/vigo/textmate2-python-fmt.git Python-FMT.tmbundle
```

and restart TextMate!

## Installation: `homebrew` Users

Check your Python binary:

```bash
$ which python
/usr/local/bin/python              # example output
```

Set `TM_PYTHON` variable from  **TextMate > Preferences > Variables**:

    TM_PYTHON    /usr/local/bin/python

Now install packages:

```bash
$ pip install isort black flake8 pylint
```


And finally clone the repo:

```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/
$ git clone https://github.com/vigo/textmate2-python-fmt.git Python-FMT.tmbundle
```

and restart TextMate!

## Installation: macOS Defaults

macOS ships with **Python 2.7.10** which is not good but you can still
use the bundle...

```bash
$ sudo /usr/bin/easy_install --script-dir=/usr/bin/ isort
$ sudo /usr/bin/easy_install --script-dir=/usr/bin/ black
$ sudo /usr/bin/easy_install --script-dir=/usr/bin/ flake8
$ sudo /usr/bin/easy_install --script-dir=/usr/bin/ pylint
```

You don’t need to set `TM_PYTHON` variable... Now clone repo:

```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/
$ git clone https://github.com/vigo/textmate2-python-fmt.git Python-FMT.tmbundle
```

and restart TextMate!

---

## Recommended flake8 plugins

* `flake8-blind-except`: Checks for blind, catch-all `except:` statements.
* `flake8-builtins`: Check for python builtins being used as variables or parameters
* `flake8-import-order`: Check invalid import order (*double checks after isort*)
* `flake8-quotes`: Install this if you are single quote person like me!
* `flake8-string-format`: Checks for strings and parameters using `str.format`
* `flake8-print`: Checks for `print` statements in python files.
* `flake8-bugbear`: A plugin for Flake8 finding likely bugs and design problems in your program.
* `flake8-bandit`: For writing secure code!

To install all:

```bash
# Homebrew or pyenv
$ pip install flake8-{blind-except,builtins,import-order,quotes,string-format,print,bugbear,bandit} # or
```

Check your installation after:

```bass
$ flake8 -h

# you’ll see all of the options. at the last part you’ll find the list of installed
# plugins
Installed plugins: flake8-bandit: v1.0.2, flake8-blind-except: 0.1.1,
flake8-bugbear: 18.8.0, flake8-print: 3.1.0, flake8-string-format: 0.2.3,
flake8_builtins: 1.4.1, flake8_quotes: 1.0.0, import-order: 0.18, mccabe:
0.6.1, pycodestyle: 2.4.0, pyflakes: 2.0.0
```

---

## Hot Keys and Snippets

| Hot Keys and TAB Completions    | Description                                                                                                                                                                                        |
|:--------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <kbd>⌘</kbd> + <kbd>{</kbd>    | Bypass selection while formatting with `black`. This adds `# fmt: off` and `# fmt: on` to beginning and ending of selection. Used James Edward Gray II’s commenting tool which ships with TextMate. |
| <kbd>noq</kbd> + <kbd>⇥</kbd>  | Inserts `# noqa` with error numbers                                                                                                                                                                 |
| <kbd>ski</kbd> + <kbd>⇥</kbd>  | Inserts `# isort: skip`                                                                                                                                                                             |
| <kbd>pyl</kbd> + <kbd>⇥</kbd>  | Inserts `# pylint: disable` with error numbers                                                                                                                                                      |

## TextMate Variables

| Variable                             | Information                                                                                                         |
|:-------------------------------------|:--------------------------------------------------------------------------------------------------------------------|
| `TM_PYTHON`                          | To run everything :)                                                                                                |
| `TM_PYTHON_FMT_ISORT`                | Binary location for `isort`. To set custom binary, enter full path here. Example: `/path/to/isort`                  |
| `TM_PYTHON_FMT_VIRTUAL_ENV`          | Good for `isort`. Use `.tm_properties` file to set this. If set, passes `--virtual-env` to `isort` with given value |
| `TM_PYTHON_FMT_BLACK`                | Binary location for `black`. To set custom binary, enter full path here. Example: `/path/to/black`                  |
| `TM_PYTHON_FMT_FLAKE8`               | Binary location for `flake8`. To set custom binary, enter full path here. Example: `/path/to/black`                 |
| `TM_PYTHON_FMT_PYLINT`               | Binary location for `pylint`. To set custom binary, enter full path here. Example: `/path/to/pylint`                |
| `TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS` | You can pass additional options/params to `pylint`.                                                                 |

Using `pylint` to display compile-time errors only. This means, using
`--errors-only` option. Also, for `flake8` and `pylint` using same
error output format:

    LINE_NUMBER || COLUMN_NUMBER || ERROR_CODE || ERROR_MESSAGE

You can pass extra arguments via `TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS`. Set this
variable in TextMate’s global settings (**TextMate > Preferences > Variables**.)
or set it in `.tm_properties`. Space delimited arguments required...

Example `.tm_properties` for `TM_PYTHON_FMT_VIRTUAL_ENV` and 
`TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS` usage:

    TM_PYTHON_FMT_VIRTUAL_ENV=~/.virtualenvs/YOUR_VENV
    TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS=--py3k

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

```toml
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

**2018-11-19**

* Update: Added missing information on README
* Version bump to: 3.0.1

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
