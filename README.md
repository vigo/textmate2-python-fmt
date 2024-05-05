![Version](https://img.shields.io/badge/version-4.0.3-orange.svg)
![Plaftorm](https://img.shields.io/badge/platform-TextMate-blue.svg)
![Python 3.7+](https://img.shields.io/badge/python-3.7+-blue.svg)
![macOS](https://img.shields.io/badge/macos-HighSierra-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Mojave-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Catalina-yellow.svg)
![macOS](https://img.shields.io/badge/macos-BigSur-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Monterey-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Ventura-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Sonoma-yellow.svg)
![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)
[![Imports: isort](https://img.shields.io/badge/%20imports-isort-%231674b1?style=flat&labelColor=ef8336)](https://pycqa.github.io/isort/)
[![linting: pylint](https://img.shields.io/badge/linting-pylint-yellowgreen)](https://github.com/pylint-dev/pylint)
[![style: flake8](https://img.shields.io/badge/style-flake8-blue)](https://github.com/PyCQA/flake8)
![Powered by Rake](https://img.shields.io/badge/powered_by-rake-blue?logo=ruby)

# Python FMT bundle for TextMate

![Example](Screenshots/demo.gif?1 "Demo output")

This bundle runs various linters and checkers when you save a Python file,
both formatting the code and highlighting any errors. The supported linters
and checkers are as follows:

- `isort`: Sorts `import` statements.
- `black`: Formats source code.
- `pylint`: Analyses source code.
- `flake8`: Checks source code for style guide enforcement.

---

## Installation

`python` must be installed, whether through `brew`, `pyenv`, or any other
method. Please check your python installation:

```bash
command -v python
```

Bundle checks the `TM_PYTHON_FMT_PYTHON_PATH` environment variable. This
variable can be set in `.tm_properties` or via the 
**TextMate > Preferences > Variables** menu. If it is not set anywhere, the 
bundle attempts to locate the python path using the `command -v python` command 
and `TM_PYTHON_FMT_VIRTUAL_ENV` environment variable internally. If the bundle
reports that it cannot find the `TM_PYTHON_FMT_PYTHON_PATH`, you need to set 
it manually to the desired python path.

If you are in a virtual environment, all you need is to set
`TM_PYTHON_FMT_VIRTUAL_ENV` variable. Bundle will handle all the installed
linters/checkers from the virtual environment.

If you are not in a virtual environment, you need to set all the required
variables:

- `TM_PYTHON_FMT_PYTHON_PATH`
- `TM_PYTHON_FMT_BLACK`
- `TM_PYTHON_FMT_ISORT`
- `TM_PYTHON_FMT_PYLINT`
- `TM_PYTHON_FMT_FLAKE8`

if you want to use all of it. You can disable partially by setting
`TM_PYTHON_FMT_DISABLE_<NAME>` environment variable(s).

You can set the values globally from command-line:

```bash
$ defaults write com.macromates.TextMate environmentVariables \
    -array-add "{enabled = 1; value = \"$(command -v python)\"; name = \"TM_PYTHON_FMT_PYTHON_PATH\"; }"
```

You need to restart TextMate to take effect. Now clone the bundle:

```bash
cd "${HOME}/Library/Application\ Support/TextMate/Bundles/"
git clone https://github.com/vigo/textmate2-python-fmt.git Python-FMT.tmbundle
```

> **IMPORTANT**: Bundle ships with TextMate grammar: **PYTHON FMT**. You
**must** set your language scope to **PYTHON FMT** for the bundle to
function/work properly. Scope automatically loads `source.python` and 
`source.python.django` grammars. Due to TextMate’s callback flow, I was forced 
to create a separate scope. Otherwise, it would conflict with all bundles that 
use `source.python`. Due to this situation, previous version was working too
slow.

If you are within a project folder, the bundle automatically uses any existing
linter configuration files you have, such as `.isort`, `.flake8` and all the
other configuration files.

The bundle includes a `requirements.txt` file, which allows for easy
installation either into your virtual environment or system-wide:

```bash
cd Python-FMT.tmbundle/
# if you need to create new environment uncomment below
# mkvirtualenv myenv
pip install -r requirements.txt
```

`requirements.txt` contains:

    black
    isort
    pylint
    flake8
    flake8-bandit
    flake8-blind-except
    flake8-bugbear
    flake8-builtins
    flake8-commas
    flake8-print
    flake8-quotes
    flake8-return
    flake8-string-format

Bundle contains easy config creation command; hit 
<kbd>⌥</kbd> + <kbd>T</kbd> (option + T) for helper commands.

---

## Enable / Disable Bundle or Features

To completely disable the bundle, simply assign a value to `TM_PYTHON_FMT_DISABLE`. 
This allows you to proceed as if the bundle does not exist. Additionally, if 
the first line of your Python file contains comment **TM\_PYTHON\_FMT_DISABLE**:

```python
# TM_PYTHON_FMT_DISABLE
print('ok')
```
 
the bundle will also be disabled for that file. You can partially disable
features by setting related environment variable:

- Set `TM_PYTHON_FMT_DISABLE_BLACK=1` to bypass `black` formatter
- Set `TM_PYTHON_FMT_DISABLE_ISORT=1` to bypass `isort`
- Set `TM_PYTHON_FMT_DISABLE_PYLINT=1` to disable `pylint` (well a bit useless :)
- Set `TM_PYTHON_FMT_DISABLE_FLAKE8=1` to disable `flake8`

---

## TextMate Variables

| Variable | Default Value | Description | 
|:---------|:-----|:-----|
| `ENABLE_LOGGING` |  | Set for development purposes |
| `TOOLTIP_LINE_LENGTH` | `100` | Width of pop-up window |
| `TOOLTIP_LEFT_PADDING` | `2` | Alignment value |
| `TOOLTIP_BORDER_CHAR` | `-` | Border value |
| `TM_PYTHON_FMT_VIRTUAL_ENV` |  | Set this variable if you are in a virtual environment |
| `TM_PYTHON_FMT_BLACK` | * | Binary path of `black` |
| `TM_PYTHON_FMT_ISORT` | * | Binary path of `isort` |
| `TM_PYTHON_FMT_PYLINT` | * | Binary path of `pylint` |
| `TM_PYTHON_FMT_FLAKE8` | * | Binary path of `flake8` |
| `TM_PYTHON_FMT_DISABLE` |  | Disable bundle |
| `TM_PYTHON_FMT_DISABLE_BLACK` |  | Disable `black` formatter |
| `TM_PYTHON_FMT_DISABLE_ISORT` |  | Disable `isort` |
| `TM_PYTHON_FMT_DISABLE_PYLINT` |  | Disable `pylint` checker |
| `TM_PYTHON_FMT_DISABLE_FLAKE8` |  | Disable `flake8` style guide |
| `TM_PYTHON_FMT_BLACK_DEFAULTS` |  | Unless config file doesn’t exists, this parameters will be used if provided |
| `TM_PYTHON_FMT_ISORT_DEFAULTS` |  | Unless config file doesn’t exists, this parameters will be used if provided |
| `TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS` |  | Unless config file doesn’t exists, this parameters will be used if provided |
| `TM_PYTHON_FMT_FLAKE8_DEFAULTS` |  | Unless config file doesn’t exists, this parameters will be used if provided |

`*`: Bundle tries to find binary path, fall-back is empty/nil value, if you get
error, you need to set exact binary path.

For `black`, bundle checks config files below;

- `${HOME}/.black`
- `${TM_PROJECT_DIRECTORY}/pyproject.toml`
- Filenames end with `.pyi`

For `isort`, bundle checks config files below;

- `${TM_PROJECT_DIRECTORY}/.isort.cfg`

For `pylint`, bundle checks config files below;

- `${HOME}/.pylintrc`
- `${TM_PROJECT_DIRECTORY}/.pylintrc`

For `flake8`, bundle checks config files below;

- `${TM_PROJECT_DIRECTORY}/setup.cfg`
- `${TM_PROJECT_DIRECTORY}/.flake8`

`pylint` now shows every available error. You can set extra options to
display **compile-time errors** only by setting `TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS`
variable. Space delimited arguments are required:

    # .tm_properties or from TextMate > Preferences > Variables
    TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS="--errors-only"

`flake8` and `pylint` using same error output format:

    LINE_NUMBER || COLUMN_NUMBER || ERROR_CODE || ERROR_MESSAGE

Example `.tm_properties`:

    TM_PYTHON_FMT_VIRTUAL_ENV="/Users/YOU/.virtualenvs/YOUR_VENV"   # or
    TM_PYTHON_FMT_VIRTUAL_ENV="${HOME}/.virtualenvs/YOUR_VENV"
    
    # It’s ok to use shell variables and TextMate variables but never use like this:
    # ~/.virtualenvs/ENV
    
    TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS="--py3k"

Also, you can set project based configurations for all of the tools. Check
their official documentations:

- https://black.readthedocs.io/en/stable/
- https://pycqa.github.io/isort/
- https://pylint.pycqa.org/en/latest/
- https://flake8.pycqa.org/en/latest/

---

## Hot Keys and Snippets

| Hot Keys and TAB Completions       | Description                                                                                                                                                                                           |
|:-----------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <kbd>⌘</kbd> + <kbd>{</kbd>       | Bypass selection while formatting with `black`. This adds `# fmt: off` and `# fmt: on` to beginning and ending of selection.<br>Used James Edward Gray II’s commenting tool which ships with TextMate. |
| <kbd>noq</kbd> + <kbd>⇥</kbd>     | Choose desired bypass method |
| <kbd>envi</kbd> + <kbd>⇥</kbd>    | Inserts helpful environment variables if you are editing on `.tm_properties` file. Try :) |
| <kbd>disable</kbd> + <kbd>⇥</kbd> | Inserts `# TM_PYTHON_FMT_DISABLE`, put this in to first line if you want to disable this bundle |
| <kbd>⌥</kbd> + <kbd>T</kbd>       | Create `.tm_properties` or linter config files |

---

## Bug Report

Please set/enable the logger via setting `ENABLE_LOGGING=1`. Logs are written to
the `/tmp/textmate-python-fmt.log` file. You can `tail` while running via;
`tail -f /tmp/textmate-python-fmt.log` in another Terminal tab. You can see
live what’s going on. Please provide the log information for bug reporting.

`callback.document.will-save` errors are written to:

- `/tmp/textmate-python-fmt-black.error`
- `/tmp/textmate-python-fmt-isort.error`

After you fix the source code (next run) bundle removes those files if there
is no error. According to you bug report, you can `tail` or copy/paste the
contents of error file to issue.

Also, while running bundle script (which is TextMate’s default ruby 1.8.8),
if error occurs, TextMate pops up an alert window. Please add that screen shot
or try to copy error text from modal dialog

---

## Change Log

**2024-05-05**

Mega refactoring, improved code structure and speed.

- Remove `TM_PYTHON_FMT_DEBUG` TextMate variable.
- Add logging mechanism
- Improve `callback.document.will-save` and `callback.document.did-save` handling.
  Now if error occurs before `callback.document.did-save` bundle stops execution.

You can read the whole story [here][changelog].

---

## Contributor(s)

* [Uğur "vigo" Özyılmazel](https://github.com/vigo) - Creator, maintainer

---

## Contribute

All PR’s are welcome!

1. `fork` (https://github.com/vigo/textmate2-python-fmt/fork)
1. Create your `branch` (`git checkout -b my-features`)
1. `commit` yours (`git commit -am 'add awesome features'`)
1. `push` your `branch` (`git push origin my-features`)
1. Than create a new **Pull Request**!

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [code of conduct][coc].

---

## License

This project is licensed under MIT

---

[coc]: https://github.com/vigo/statoo/blob/main/CODE_OF_CONDUCT.md
[changelog]: https://github.com/vigo/statoo/blob/main/CHANGELOG.md
