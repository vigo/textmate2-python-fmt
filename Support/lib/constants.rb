module Constants
  TM_PYTHON_FMT_VIRTUAL_ENV = ENV["TM_PYTHON_FMT_VIRTUAL_ENV"]

  module_function
  def find_binary(cmd)
    path = ""
    case cmd
    when "python"
      path = ENV["TM_PYTHON_FMT_PYTHON_PATH"] || ENV["TM_PYTHON"] || `command -v #{cmd}`.chomp
    when "black" then
      path = ENV["TM_PYTHON_FMT_BLACK"] || `command -v #{cmd}`.chomp
    when "isort" then
      path = ENV["TM_PYTHON_FMT_ISORT"] || `command -v #{cmd}`.chomp
    when "pylint" then
      path = ENV["TM_PYTHON_FMT_PYLINT"] || `command -v #{cmd}`.chomp
    when "flake8" then
      path = ENV["TM_PYTHON_FMT_FLAKE8"] || `command -v #{cmd}`.chomp
    end
    
    path = File.join(TM_PYTHON_FMT_VIRTUAL_ENV, "bin", cmd) if TM_PYTHON_FMT_VIRTUAL_ENV
    
    path = "" unless File.exists?(path)
    path
  end

  TM_PYTHON_FMT_DISABLE = !!ENV["TM_PYTHON_FMT_DISABLE"]

  TM_PYTHON_FMT_PYTHON_PATH = find_binary("python")
  TM_PYTHON_FMT_BLACK = find_binary("black")
  TM_PYTHON_FMT_ISORT = find_binary("isort")
  TM_PYTHON_FMT_PYLINT = find_binary("pylint")
  TM_PYTHON_FMT_FLAKE8 = find_binary("flake8")

  TM_PYTHON_FMT_DISABLE_BLACK = !!ENV["TM_PYTHON_FMT_DISABLE_BLACK"]
  TM_PYTHON_FMT_DISABLE_ISORT = !!ENV["TM_PYTHON_FMT_DISABLE_ISORT"]
  TM_PYTHON_FMT_DISABLE_PYLINT = !!ENV["TM_PYTHON_FMT_DISABLE_PYLINT"]
  TM_PYTHON_FMT_DISABLE_FLAKE8 = !!ENV["TM_PYTHON_FMT_DISABLE_FLAKE8"]

  TM_PROJECT_DIRECTORY = ENV["TM_PROJECT_DIRECTORY"]
  TM_FILENAME = ENV["TM_FILENAME"]
  TM_FILEPATH = ENV["TM_FILEPATH"]

  TM_PYTHON_FMT_BLACK_DEFAULTS = ENV["TM_PYTHON_FMT_BLACK_DEFAULTS"]
  TM_PYTHON_FMT_ISORT_DEFAULTS = ENV["TM_PYTHON_FMT_ISORT_DEFAULTS"]
  TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS = ENV["TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS"]
  TM_PYTHON_FMT_FLAKE8_DEFAULTS = ENV["TM_PYTHON_FMT_FLAKE8_DEFAULTS"]
end