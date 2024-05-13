# Change Log

**2024-05-13**

Another refactoring

- Add go to line with `option+G`
- Implement zero-config run, if you have linter, runs w/o config file, uses defaults
- Improve error handling
- Improve code structure
- Add all the `noqa` codes for `pylint` and `flake8` for autocompletion.

---

**2024-05-05**

Mega refactoring, improved code structure and speed.

- Remove `TM_PYTHON_FMT_DEBUG` TextMate variable.
- Add logging mechanism
- Improve `callback.document.will-save` and `callback.document.did-save` handling.
  Now if error occurs before `callback.document.did-save` bundle stops execution.

---

**2021-04-27, Covid Days**

Add disable option for each linter/formatter via `TM_PYTHON_FMT_DISABLE_` prefix.
You can quickly set those variables via `tm_properties Helper` > `Disable linter/formatter`
from the bundle menu. <kbd>envi</kbd> + <kbd>⇥</kbd>

- `TM_PYTHON_FMT_DISABLE_ISORT` to disable `isort`
- `TM_PYTHON_FMT_DISABLE_BLACK` to disable `black`
- `TM_PYTHON_FMT_DISABLE_FLAKE8` to disable `flake8`
- `TM_PYTHON_FMT_DISABLE_PYLINT` to disable `pylint`

This was the request from [nextmat](https://github.com/nextmat) - [issue 7](https://github.com/vigo/textmate2-python-fmt/issues/7)

Fix reset markers, now resets before anything goes on. Display enabled items
at the end of the process.

---

**2021-02-11**

- Add linter config generator: <kbd>⌥</kbd> + <kbd>T</kbd>
- Add config existence check, now you can’t overwrite file!
- Remove config examples

---

**2020-11-18**

- Add `TM_PYTHON` fall-back unless `TM_PYTHON_FMT_PYTHON_PATH` exists
- Add virtualenv/config examples to README
- Fix `isort` version display on debug mode.

---

**2019-12-05**

- Add version information to debug text

---

**2019-10-11**

- Add Rakefile for bump version tasks
- Add missing environment variable description to README

---

**2019-09-19**

- Add missing `ENV_NAME` identifier to `.tm_properties` creator snippet
- Bump version: 3.5.5

---

**2019-08-06**

- Add local `~/.pylintrc` lookup feature
- Add `bumpversion` config

---

**2019-07-24**

- Skip pylint check unless `pylintrc` exists

---

**2019-04-11**

- Create `.tm_properties` file to current working directory <kbd>⌥</kbd> + <kbd>T</kbd>
- Create `.tm_properties` file to project root directory <kbd>⌥</kbd> + <kbd>T</kbd>

---

**2019-04-05**

- Fix: `pylint` configuration
- Fix: `pylint` result
- New: Now shows `pylint score`
- Update: Python packages

---

**2019-03-22**

- You can create `.tm_properties` file
- Extra snippets for tm_properties helper

---

**2019-01-13**

- Put `# TM_PYTHON_FMT_DISABLE` as first line in to your code to disable bundle (or hit `disable` + <kbd>⇥</kbd>)
- When bundle is disabled from code or from env, nothing will pop! All silent now!

---

**2019-01-08**

- Fix missing environment variable for python executable: `TM_PYTHON_FMT_PYTHON_PATH`
- You can disable this bundle temporarily via `TM_PYTHON_FMT_DISABLE` variable.

---

**2018-12-27**

- Now using `TM_PYTHON_FMT_PYTHON_PATH` instead of `TM_PYTHON`. You must fix
  this, otherwise your bundle will not work!

---

**2018-12-23**

- `TM_PYTHON_FMT_FLAKE8_DEFAULTS` env-var for setting defaults for `flake8`
- `env` + <kbd>⇥</kbd> changed to `envi` + <kbd>⇥</kbd> due to other TM bundle collision.
- Bundle menu grouping for `tm_properties` helper

---

**2018-11-29**

- `TM_PYTHON_FMT_BLACK_DEFAULTS` env-var for setting `black` defaults.
- `TM_PYTHON_FMT_ISORT_DEFAULTS` env-var for setting `isort` defaults.
- `TM_PYTHON_FMT_DEBUG` env-var for debugging.

---

**2018-11-21**

- Monkeypatch: `flake8-bandit` causes warning: `Possible nested set at position 1`
- Version bump to: 3.1.0

---

**2018-11-19**

- Update: Added missing information on `README.md`
- Update: Virtual Environmet support for `pylint`
- Update: `pylintrc` support for `pylint`
- Fix: `isort:skip_file` bug
- Addition: <kbd>env</kbd> + <kbd>⇥</kbd> for environment variables
- Change: All the bypass declarations are using <kbd>noq</kbd> + <kbd>⇥</kbd>
- Version bump to: 3.0.5

---

**2018-11-18**

- Upgrade: Rewritten from scratch. `autopep8` removed.

---

**2018-11-17**

- Update: `black` integration
- `flake8-commas` removed.

---

**2018-11-15**

- Update: `setup.cfg` config file support added.

---

**2018-11-14**

- Fix: Added `--trailing-comma` for isort imports
- Added: List of `flake8` plugins

---

**2018-10-28**

- `TM_PYTHON_FMT_DEBUG` if set, you’ll see running commands
- Version is now `2.1.4`

---

**2018-10-24**

- Fix: Added missing `git clone` information
- Fix: runners.
- Version is now `2.1.3`

---

**2018-10-24**

- Bundle re-written from scratch
- Now using `callback.document.will-save` and `callback.document.did-save` hooks
- `isort` support added
- Version is now `2.1.0`

---

**2017-07-02**

- Updated: README file. Added useful setup instructions.
- Added: Badges :)

---

**2017-05-14**

- Updated: Success tooltip message now shows maximum characters value
- Updated: Screenshot of `before-and-after-flake8.png`
- Changed: Overriding default save keys (<kbd>⌘</kbd> + <kbd>S</kbd>) was a bad idea :)

---

**2017-05-13**

- First release :)

---

**2017-05-06**

- Initial commit
