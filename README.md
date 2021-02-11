![Version](https://img.shields.io/badge/version-3.6.1-orange.svg)
![Plaftorm](https://img.shields.io/badge/platform-TextMate-blue.svg)
![Python 3.7+](https://img.shields.io/badge/python-3.7+-blue.svg)
![macOS](https://img.shields.io/badge/macos-HighSierra-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Mojave-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Catalina-yellow.svg)
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
and set the value according to the result above. If `TM_PYTHON` exists, bundle
will fall back to `TM_PYTHON` value as python executable.


```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/
$ git clone https://github.com/vigo/textmate2-python-fmt.git Python-FMT.tmbundle
```

If your project already contains lint/format config files (such as `.pylintrc`
etc...) or packages (such as `pylint`, `flake8` binaries etc..) You don’t need
to install anything. Just create `.tm_properties` and fill the config variables.
Try with <kbd>⌥</kbd> + <kbd>T</kbd> (option + T)

For global usage, you can install python packages and config files for any
python file/project:

```bash
$ cd Python-FMT.tmbundle/
$ mkvirtualenv textmate-python-fmt
$ pip install -r requirements.txt
```

When you open any single python file or project, when you hit save, bundle
checks for local or global linter binaries and config files.

Now, you can add all the config files inside of the `textmate-python-fmt` env:

```bash
$ cdvirtualenv # or
$ cd ~/.virtualenvs/textmate-python-fmt
$ pylint --generate-rcfile > pylintrc
$ touch isort flake8
```

You can create

- `.isort.cfg` 
- `.pylintrc`
- `.flake8`
- `pyproject.toml`
 
via <kbd>⌥</kbd> + <kbd>T</kbd> and choose from list!

Now you can set `TM_` variables:

    TM_PYTHON                               /Users/YOUR-USER-NAME/.pyenv/versions/3.8.0/bin/python
    TM_PYTHON_FMT_PYLINTRC                  /Users/YOUR-USER-NAME/.virtualenvs/textmate-python-fmt/pylintrc
    TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS      --disable missing-module-docstring,missing-function-docstring
    TM_PYTHON_FMT_BLACK_DEFAULTS            --skip-string-normalization --target-version py38 --quiet
    TM_PYTHON_FMT_PYLINTRC                  /Users/YOUR-USER-NAME/.virtualenvs/textmate-python-fmt/pylintrc
    TM_PYTHON_FMT_FLAKE8_DEFAULTS           --config /Users/YOUR-USER-NAME/.virtualenvs/textmate-python-fmt/flake8
    TM_PYTHON_FMT_ISORT_DEFAULTS            --settings-file /Users/YOUR-USER-NAME/.virtualenvs/textmate-python-fmt/isort

This variable setup helps you to run/check/lint your python code without
any project requirement. For bigger apps/projects please consider using
of `.tm_properties` file. Hit <kbd>⌥</kbd> + <kbd>T</kbd> to create!

Bundled `flake8` plugins are:

* `flake8-bandit`: For writing secure code!
* `flake8-blind-except`: Checks for blind, catch-all `except:` statements.
* `flake8-bugbear`: A plugin for Flake8 finding likely bugs and design problems in your program.
* `flake8-builtins`: Check for python builtins being used as variables or parameters
* `flake8-print`: Checks for `print` statements in python files.
* `flake8-quotes`: Install this if you are single quote person like me!
* `flake8-string-format`: Checks for strings and parameters using `str.format`
* `flake8-return`: Checks return statements.

Current package versions are:

```bash
black==20.8b1
isort==5.6.4
pylint==2.6.0
flake8==3.8.4
flake8-bandit==2.1.2
flake8-blind-except==0.1.1
flake8-bugbear==20.1.4
flake8-builtins==1.5.3
flake8-print==3.1.4
flake8-quotes==3.2.0
flake8-string-format==0.3.0
flake8-return==1.1.2
```

Now you can restart TextMate!

---

## Hot Keys and Snippets

| Hot Keys and TAB Completions       | Description                                                                                                                                                                                           |
|:-----------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <kbd>⌘</kbd> + <kbd>{</kbd>       | Bypass selection while formatting with `black`. This adds `# fmt: off` and `# fmt: on` to beginning and ending of selection.<br>Used James Edward Gray II’s commenting tool which ships with TextMate. |
| <kbd>noq</kbd> + <kbd>⇥</kbd>     | Choose desired bypass method |
| <kbd>envi</kbd> + <kbd>⇥</kbd>    | Inserts helpful environment variables if you are editing on `.tm_properties` file. Try :) |
| <kbd>disable</kbd> + <kbd>⇥</kbd> | Inserts `# TM_PYTHON_FMT_DISABLE`, put this in to first line if you want to disable this bundle |
| <kbd>⌥</kbd> + <kbd>T</kbd>       | Create `.tm_properties` or linter config files |


## TextMate Variables

| Variable                             | Information                                                                                                         |
|:-------------------------------------|:--------------------------------------------------------------------------------------------------------------------|
| `TM_PYTHON_FMT_PYTHON_PATH`          | Binary location of your `python` executable :)                                                                      |
| `TM_PYTHON_FMT_VIRTUAL_ENV`          | Good for `isort`. Use `.tm_properties` file to set this. If set, passes `--virtual-env` to `isort` with given value |
| `TM_PYTHON_FMT_ISORT`                | Binary location for `isort`. To set custom binary, enter full path here. Example: `/path/to/isort`                  |
| `TM_PYTHON_FMT_ISORT_DEFAULTS`       | Unless `.isort.cfg` doesn’t exists, this parameters will be used if provided                                        |
| `TM_PYTHON_FMT_BLACK`                | Binary location for `black`. To set custom binary, enter full path here. Example: `/path/to/black`                  |
| `TM_PYTHON_FMT_BLACK_DEFAULTS`       | Unless `pyproject.toml` doesn’t exists, this parameters will be used if provided                                    |
| `TM_PYTHON_FMT_FLAKE8`               | Binary location for `flake8`. To set custom binary, enter full path here. Example: `/path/to/black`                 |
| `TM_PYTHON_FMT_FLAKE8_DEFAULTS`      | Unless `.flake8` or `setup.cfg` doesn’t exists, this parameters will be used as defaults for `flake8` configuration |
| `TM_PYTHON_FMT_PYLINT`               | Binary location for `pylint`. To set custom binary, enter full path here. Example: `/path/to/pylint`                |
| `TM_PYTHON_FMT_PYLINTRC`             | Location of `pylintrc` or `.pylintrc` file if you like to set                                                       |
| `TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS` | You can pass additional options/params to `pylint`.                                                                 |
| `TM_PYTHON_FMT_DISABLE`              | You this variable if you need to disable this bundle temporarily                                                    |
| `TM_PYTHON_FMT_DEBUG`                | Enable debug mode |

`pylint` now shows every available error. You can set extra options to
display compile-time errors only via `TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS` set
the value to: (**TextMate > Preferences > Variables**.) or `.tm_properties`.
Space delimited arguments required...

    --errors-only

`flake8` and `pylint` using same error output format:

    LINE_NUMBER || COLUMN_NUMBER || ERROR_CODE || ERROR_MESSAGE

Example `.tm_properties` usage:

    TM_PYTHON_FMT_VIRTUAL_ENV=/Users/YOU/.virtualenvs/YOUR_VENV   # or
    TM_PYTHON_FMT_VIRTUAL_ENV=$HOME/.virtualenvs/YOUR_VENV        # or
                                                                  # It’s ok to use shell variables and TextMate variables but
                                                                  # never user like this: `~/.virtualenvs/ENV`
    TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS=--py3k
    TM_PYTHON_FMT_PYLINTRC=$TM_PROJECT_DIRECTORY/.pylintrc        # or
    TM_PYTHON_FMT_PYLINTRC=/path/to/.pylintrc                     # or

**Update**

Now bundle checks for `~/.pylintrc`. First checks local `pylintrc`, then checks 
`TM_PYTHON_FMT_PYLINTRC` variable. This overrides local `pylintrc` if `TM_PYTHON_FMT_PYLINTRC`
is set.

Also, you can set project based configurations for all of the tools. Check
their official documentations:

- https://github.com/timothycrosley/isort/wiki/isort-Settings
- https://github.com/ambv/black#pyprojecttoml
- http://flake8.pycqa.org/en/latest/user/configuration.html#configuration-locations
- https://pylint.readthedocs.io/en/latest/user_guide/run.html#command-line-options

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

**2021-02-11**

- Add linter config generator: <kbd>⌥</kbd> + <kbd>T</kbd>
- Add config existence check, now you can’t overwrite file!
- Remove config examples

**2020-11-18**

- Add `TM_PYTHON` fall-back unless `TM_PYTHON_FMT_PYTHON_PATH` exists
- Add virtualenv/config examples to README
- Fix `isort` version display on debug mode.

**2019-12-05**

- Add version information to debug text

**2019-10-11**

- Add Rakefile for bump version tasks
- Add missing environment variable description to README

**2019-09-19**

- Add missing `ENV_NAME` identifier to `.tm_properties` creator snippet
- Bump version: 3.5.5

**2019-08-06**

- Add local `~/.pylintrc` lookup feature
- Add `bumpversion` config

**2019-07-24**

- Skip pylint check unless `pylintrc` exists

**2019-04-11**

- Create `.tm_properties` file to current working directory <kbd>⌥</kbd> + <kbd>T</kbd>
- Create `.tm_properties` file to project root directory <kbd>⌥</kbd> + <kbd>T</kbd>

**2019-04-05**

- Fix: `pylint` configuration
- Fix: `pylint` result
- New: Now shows `pylint score`
- Update: Python packages

**2019-03-22**

- You can create `.tm_properties` file
- Extra snippets for tm_properties helper

**2019-01-13**

- Put `# TM_PYTHON_FMT_DISABLE` as first line in to your code to disable bundle (or hit `disable` + <kbd>⇥</kbd>)
- When bundle is disabled from code or from env, nothing will pop! All silent now!

**2019-01-08**

- Fix missing environment variable for python executable: `TM_PYTHON_FMT_PYTHON_PATH`
- You can disable this bundle temporarily via `TM_PYTHON_FMT_DISABLE` variable.

**2018-12-27**

- Now using `TM_PYTHON_FMT_PYTHON_PATH` instead of `TM_PYTHON`. You must fix
  this, otherwise your bundle will not work!

**2018-12-23**

- `TM_PYTHON_FMT_FLAKE8_DEFAULTS` env-var for setting defaults for `flake8`
- `env` + <kbd>⇥</kbd> changed to `envi` + <kbd>⇥</kbd> due to other TM bundle collision.
- Bundle menu grouping for `tm_properties` helper

**2018-11-29**

- `TM_PYTHON_FMT_BLACK_DEFAULTS` env-var for setting `black` defaults.
- `TM_PYTHON_FMT_ISORT_DEFAULTS` env-var for setting `isort` defaults.
- `TM_PYTHON_FMT_DEBUG` env-var for debugging.


**2018-11-21**

- Monkeypatch: `flake8-bandit` causes warning: `Possible nested set at position 1`
- Version bump to: 3.1.0

**2018-11-19**

- Update: Added missing information on `README.md`
- Update: Virtual Environmet support for `pylint`
- Update: `pylintrc` support for `pylint`
- Fix: `isort:skip_file` bug
- Addition: <kbd>env</kbd> + <kbd>⇥</kbd> for environment variables
- Change: All the bypass declarations are using <kbd>noq</kbd> + <kbd>⇥</kbd>
- Version bump to: 3.0.5

**2018-11-18**

- Upgrade: Rewritten from scratch. `autopep8` removed.

**2018-11-17**

- Update: `black` integration
- `flake8-commas` removed.

**2018-11-15**

- Update: `setup.cfg` config file support added.

**2018-11-14**

- Fix: Added `--trailing-comma` for isort imports
- Added: List of `flake8` plugins

**2018-10-28**

- `TM_PYTHON_FMT_DEBUG` if set, you’ll see running commands
- Version is now `2.1.4`

**2018-10-24**

- Fix: Added missing `git clone` information
- Fix: runners.
- Version is now `2.1.3`

**2018-10-24**

- Bundle re-written from scratch
- Now using `callback.document.will-save` and `callback.document.did-save` hooks
- `isort` support added
- Version is now `2.1.0`

**2017-07-02**

- Updated: README file. Added useful setup instructions.
- Added: Badges :)

**2017-05-14**

- Updated: Success tooltip message now shows maximum characters value
- Updated: Screenshot of `before-and-after-flake8.png`
- Changed: Overriding default save keys (<kbd>⌘</kbd> + <kbd>S</kbd>) was a bad idea :)

**2017-05-13**

- First release :)

**2017-05-06**

- Initial commit


[01]: https://pypi.python.org/pypi/isort "isort fixes import order"
[02]: https://pypi.python.org/pypi/black "black code formatter"
[03]: https://pypi.python.org/pypi/pylint "pylint source code checker"
[04]: https://pypi.python.org/pypi/flake8 "flake8 source code checker"
