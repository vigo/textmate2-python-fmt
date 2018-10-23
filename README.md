![Version](https://img.shields.io/badge/version-2.0.0-orange.svg)
![Plaftorm](https://img.shields.io/badge/platform-TextMate-blue.svg)
![macOS](https://img.shields.io/badge/macos-HighSierra-yellow.svg)


# Python FMT bundle for TextMate

Hit <kbd>⌘</kbd> + <kbd>S</kbd> I’ll handle the rest!

While writing Python code in `Python` or `Django` scope, this bundle
handles before and after save events and formats/lints/checks your code.

Using:

- [autopep8][01]
- [flake8][02]

Todo:

- Black integration...

Before and after **autopep8**:

![Python FMT for TextMate](Screenshots/before-and-after-autopep8.png "autopep8 filtering")

Before and after **flake8**:

![Python FMT for TextMate](Screenshots/before-and-after-flake8.png "flake8 filtering")


## Installation: `pyenv` Users

Checker your Python binary:

```bash
$ pyenv which python
/Users/vigo/.pyenv/versions/3.6.4/bin/python # example output
```

Install packages:

```bash
$ pip install autopep8
$ pip install -e git+https://gitlab.com/pycqa/flake8#egg=flake8
```

Then set `TM_PYTHON` variable from **TextMate > Preferences > Variables**:

    TM_PYTHON    /Users/vigo/.pyenv/versions/3.6.4/bin/python

Now bundle auto discovers the packages. Now clone repo:

```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/
$ git clone https://github.com/vigo/textmate2-python-fmt.git
```

and restart TextMate!

## Installation: `homebrew` Users

Check you Python and set `TM_PYTHON` variable from **TextMate > Preferences > Variables**:

```bash
$ which python
/usr/local/bin/python # example output
$ pip install autopep8
$ pip install -e git+https://gitlab.com/pycqa/flake8#egg=flake8
```

    TM_PYTHON    /usr/local/bin/python

Now clone repo:

```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/
$ git clone https://github.com/vigo/textmate2-python-fmt.git
```

and restart TextMate!

## Installation: macOS Defaults

```bash
$ sudo /usr/bin/easy_install --script-dir=/usr/bin/ flake8
$ sudo /usr/bin/easy_install --script-dir=/usr/bin/ autopep8
```

You don’t need to set `TM_PYTHON` variable... Now clone repo:

```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/
$ git clone https://github.com/vigo/textmate2-python-fmt.git
```

and restart TextMate!

## TextMate Variables

`TM_PYTHON_FMT_AUTOPEP8`  
It’s possible to set binary location of `autopep8`. This is handy if you don’t
set `TM_PYTHON` variable.


`TM_PYTHON_FMT_CUSTOM_MAX_CHARS`  
By default, maximum character limit is: `79`. Use this variable to set yours.

`TM_PYTHON_FMT_DJANGO_MAX_CHARS`  
Django allows `119` characters. If your scope is `source.django` and you would
like to check against 119 chars (*or what number you’d like to*), you need to 
set `TM_PYTHON_FMT_DJANGO_MAX_CHARS`.

`TM_PYTHON_FMT_AUTOPEP8_EXTRA_OPTIONS`  
By default, `autopep8` arguments are:

```bash
$ autopep8 --in-place --aggressive --aggressive --max-line-length 79
# 79 or what number you set via TM_PYTHON_FMT_CUSTOM_MAX_CHARS variable
```

You can add more parameters via `TM_PYTHON_FMT_AUTOPEP8_EXTRA_OPTIONS` variable.
If you set, values will be appended to default parameters.

`TM_PYTHON_FMT_AUTOPEP8_CUSTOM_OPTIONS`  
If you like to run your own (*this will override defaults*) just use:
`TM_PYTHON_FMT_AUTOPEP8_CUSTOM_OPTIONS` variable. Example:

    --max-line-length 79 --line-range 20 40

`TM_PYTHON_FMT_FLAKE8_EXTRA_OPTIONS`  
Will append extra options to `flake8` defaults. By defaults, `flake8`
arguments are:

```bash
$ flake8 --max-line-length 79 --format "%(row)d || %(col)d || %(code)s || %(text)s"
# 79 or what number you set via TM_PYTHON_FMT_CUSTOM_MAX_CHARS variable
```

`TM_PYTHON_FMT_FLAKE8_CUSTOM_OPTIONS`  
If you like to run your own (*this will override defaults*) just use:
`TM_PYTHON_FMT_FLAKE8_CUSTOM_OPTIONS` variable.

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

**2018-10-24**

* Bundle re-written from scratch
* Now using `callback.document.will-save` and `callback.document.did-save` hooks
* Version is now `2.0.0`

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

[01]: https://pypi.python.org/pypi/autopep8 "autopep8 PEP8 checker"
[02]: https://pypi.python.org/pypi/flake8 "flake8 source code checker"