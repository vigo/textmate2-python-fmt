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

![Demo 1](Screenshots/demo-1.gif? "Demo 1")

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

> **IMPORTANT**: Bundle ships with TextMate grammar: **Python FMT**. You
**must** set your language scope to **Python FMT** for the bundle to
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

![Demo 2](Screenshots/demo-2.gif? "Demo 2")

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

There is a helper snippet for disabling features easily, write `envi<TAB>`
in `.tm_properties` file and select which feature to disable.

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
| `TM_PYTHON_FMT_BLACK_DEFAULTS` |  | Override current `black` config with extra parameters if provided |
| `TM_PYTHON_FMT_ISORT_DEFAULTS` |  | Override current `isort` config with extra parameters if parameters |
| `TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS` |  | Override current `pylint` config with extra parameters if parameters |
| `TM_PYTHON_FMT_FLAKE8_DEFAULTS` |  | Override current `flake8` config with extra parameters if parameters |

`*`: Bundle tries to find binary path, fall-back is empty/nil value, if you get
error, you need to set exact binary path.

For `black`, bundle checks config files in order below, last found overrides
all!

1. `${HOME}/.black`
1. `${TM_PROJECT_DIRECTORY}/pyproject.toml`

also filenames end with `.pyi`

For `isort`, bundle checks config file order;

1. `${HOME}/.isort.cfg`
1. `${TM_PROJECT_DIRECTORY}/.isort.cfg`

For `pylint`, bundle checks config files below;

1. `${HOME}/.pylintrc`
1. `${TM_PROJECT_DIRECTORY}/.pylintrc`

For `flake8`, bundle checks config files below;

1. `${HOME}/.flake8`
1. `${TM_PROJECT_DIRECTORY}/.flake8`
1. `${TM_PROJECT_DIRECTORY}/tox.ini`
1. `${TM_PROJECT_DIRECTORY}/setup.cfg`

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
    
    # overriders
    TM_PYTHON_FMT_BLACK_DEFAULTS="--line-length=100"
    TM_PYTHON_FMT_ISORT_DEFAULTS="--line-length=40 --multi-line=GRID"
    TM_PYTHON_FMT_FLAKE8_DEFAULTS="--extend-ignore F401"
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
| <kbd>⌥</kbd> + <kbd>D</kbd>       | Bypass selection while formatting with `black`. This adds `# fmt: off` and `# fmt: on` to beginning and ending of selection.<br>Used James Edward Gray II’s commenting tool which ships with TextMate. |
| <kbd>⌥</kbd> + <kbd>T</kbd>       | Create `.tm_properties` or linter config files |
| <kbd>⌥</kbd> + <kbd>G</kbd>       | Go to error line! New feature! |
| <kbd>noq</kbd> + <kbd>⇥</kbd>     | Choose desired bypass method |
| <kbd>envi</kbd> + <kbd>⇥</kbd>    | Inserts helpful environment variables if you are editing on `.tm_properties` file. Try :) |
| <kbd>disable</kbd> + <kbd>⇥</kbd> | Inserts `# TM_PYTHON_FMT_DISABLE`, put this in to first line if you want to disable this bundle |

---

## Bug Report

Please set/enable the logger via setting `ENABLE_LOGGING=1`. Logs are written to
the `/tmp/textmate-python-fmt.log` file. You can `tail` while running via;
`tail -f /tmp/textmate-python-fmt.log` in another Terminal tab. You can see
live what’s going on. Please provide the log information for bug reporting.

`callback.document.will-save` errors are written to 
`/tmp/textmate-python-fmt-DOCUMENT-ID.error`.

Bundle log looks like this:

    [2024-05-13 01:39:48][Python-FMT][INFO][python_fmt.rb->run_document_will_save]: will run isort
    [2024-05-13 01:39:48][Python-FMT][DEBUG][linters.rb->isort]: cmd: "/Users/vigo/.virtualenvs/thesarraf.com/bin/isort" | version: 5.13.2 | args: ["--profile", "black", "--honor-noqa", "--virtual-env", "/Users/vigo/.virtualenvs/thesarraf.com", "-"]
    [2024-05-13 01:39:48][Python-FMT][DEBUG][linters.rb->isort]: out:
    "FOO = 1\n"

    err: ""
    [2024-05-13 01:39:48][Python-FMT][INFO][python_fmt.rb->find_binary]: python -> path: "/Users/vigo/.virtualenvs/thesarraf.com/bin/python"
    [2024-05-13 01:39:48][Python-FMT][INFO][python_fmt.rb->find_binary]: black -> path: "/Users/vigo/.virtualenvs/thesarraf.com/bin/black"
    [2024-05-13 01:39:48][Python-FMT][INFO][python_fmt.rb->find_binary]: isort -> path: "/Users/vigo/.virtualenvs/thesarraf.com/bin/isort"
    [2024-05-13 01:39:48][Python-FMT][INFO][python_fmt.rb->find_binary]: pylint -> path: "/Users/vigo/.virtualenvs/thesarraf.com/bin/pylint"
    [2024-05-13 01:39:48][Python-FMT][INFO][python_fmt.rb->find_binary]: flake8 -> path: "/Users/vigo/.virtualenvs/thesarraf.com/bin/flake8"
    [2024-05-13 01:39:48][Python-FMT][INFO][python_fmt.rb->can_run_run_document_did_save?]: any? true
    [2024-05-13 01:39:48][Python-FMT][ERROR][python_fmt.rb->can_run_run_document_did_save?]: warning_messages: []
    [2024-05-13 01:39:49][Python-FMT][ERROR][python_fmt.rb->run_document_did_save]: errors_flake8: nil
    [2024-05-13 01:39:49][Python-FMT][ERROR][python_fmt.rb->run_document_did_save]: all_errors: {}
    [2024-05-13 01:39:49][Python-FMT][INFO][storage.rb->destroy]: storage.destroy for 1D082B22-3346-4DCE-BF76-FAE8BF4AE776 - (/tmp/textmate-python-fmt-1D082B22-3346-4DCE-BF76-FAE8BF4AE776.goto)
    [2024-05-13 01:39:49][Python-FMT][INFO][storage.rb->add]: storage.add for 1D082B22-3346-4DCE-BF76-FAE8BF4AE776 (/tmp/textmate-python-fmt-1D082B22-3346-4DCE-BF76-FAE8BF4AE776.goto)


After you fix the source code (next run) bundle removes those files if there
is no error. According to you bug report, you can `tail` or copy/paste the
contents of error file to issue.

Also, while running bundle script (which is TextMate’s default ruby 1.8.7),
if error occurs, TextMate pops up an alert window. Please add that screen shot
or try to copy error text from modal dialog.

---

## Change Log

**2024-05-13**

Another refactoring

- Add go to line with `option+G`
- Implement zero-config run, if you have linter, runs w/o config file, uses defaults
- Improve error handling
- Improve code structure
- Add all the `noqa` codes for `pylint` and `flake8` for autocompletion.

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
