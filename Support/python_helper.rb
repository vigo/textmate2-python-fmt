#!/usr/bin/env ruby18

require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/executor'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/save_current_document'

$OUTPUT = ""
$DOCUMENT = STDIN.read

$ERROR_ENVVAR = "Please set\n%s \nenvironment variable"
$ERROR_COMMAND_ENVVAR = "%s not found. At least please set\n%s \nenvironment variable"

MAXIMUM_CHARACTER_AMOUNT = ENV['TM_PYTHON_FMT_CUSTOM_MAX_CHARS'] || (ENV['TM_SCOPE'].include?('source.python.django') && ENV['TM_PYTHON_FMT_DJANGO_MAX_CHARS']) || "79"

def tooltip_box(txt)
  "#{"-" * 64}\n#{txt}\n#{"-" * 64}"
end

def check_env(env_var)
  if ENV[env_var]
    return nil
  else
    return tooltip_box($ERROR_ENVVAR % env_var)
  end
end

def apply_config_if_exist(args, cmd)
  project_level_config_file = File.join(ENV['TM_PROJECT_DIRECTORY'], 'setup.cfg')
  folder_level_config_file = File.join(ENV['TM_DIRECTORY'], 'setup.cfg')
  
  arg_config = "--settings-path"
  arg_config = "--config" if cmd == :flake8
  arg_config = "--global-config" if cmd == :autopep8

  arg_config_val = folder_level_config_file
  
  return_args = args
  return_args = [arg_config, folder_level_config_file] if File.exist?(folder_level_config_file)
  return_args = [arg_config, project_level_config_file] if File.exist?(project_level_config_file)
  return_args << "--format" << "%(row)d || %(col)d || %(code)s || %(text)s" if cmd == :flake8
  
  if cmd == :isort && ENV['TM_PYTHON_FMT_VENV'] && return_args.index('--settings-path') > -1
    file_data = File.read(return_args[return_args.index('--settings-path')+1])
    return_args << "--virtual-env" << ENV['TM_PYTHON_FMT_VENV'] unless file_data.include?('virtual_env')
  end
  return_args
end


module Python
  # Environment Variables:
  #
  # TM_PYTHON_FMT_DEBUG: If set, this means true...
  # TM_PYTHON_FMT_AUTOPEP8: binary of "autopep8" tool.
  # TM_PYTHON_FMT_CUSTOM_MAX_CHARS: If it's not set, 79 used by default.
  # TM_PYTHON_FMT_DJANGO_MAX_CHARS: If scope is django and this set...
  # TM_PYTHON_FMT_AUTOPEP8_EXTRA_OPTIONS: Extra args
  # TM_PYTHON_FMT_AUTOPEP8_CUSTOM_OPTIONS: Overrides all
  
  # TM_PYTHON_FMT_FLAKE8: binary of "flake8" tool.
  # TM_PYTHON_FMT_FLAKE8_EXTRA_OPTIONS: Extra args
  # TM_PYTHON_FMT_FLAKE8_CUSTOM_OPTIONS: Overrides all
  
  # TM_PYTHON_FMT_ISORT: binary of "isort" tool
  # TM_PYTHON_FMT_ISORT_EXTRA_OPTIONS: Extra args
  
  # TM_PYTHON_FMT_VENV: Pass your active virtual-env path
  #                     example:
  #                     /Users/YOU/.virtualenvs/NAME
  #
  def Python::reset_markers
    system(ENV['TM_MATE'], "--uuid", ENV['TM_DOCUMENT_UUID'], "--clear-mark=note", "--clear-mark=warning", "--clear-mark=error")
  end

  def Python::set_markers(input)
    input.split("\n").each do |line|
      line_result   = line.split(" || ")

      line_number   = line_result[0]
      column_number = line_result[1]
      error_code    = line_result[2]
      error_message = line_result[3]
      
      tm_args = [
        "--uuid",
        ENV['TM_DOCUMENT_UUID'],
        "--line",
        "#{line_number}:#{column_number}",
        "--set-mark",
        "error: [#{error_code}]: #{error_message}",
      ]
      system(ENV['TM_MATE'], *tm_args)
    end
  end

  # callback.document.will-save
  def Python::isort
    shell_command = ENV['TM_PYTHON_FMT_ISORT'] || `command -v isort`.chomp
    TextMate.exit_show_tool_tip(tooltip_box($ERROR_COMMAND_ENVVAR % ["isort", "TM_PYTHON_FMT_ISORT"])) if shell_command.empty?
    
    args = [
      "--trailing-comma",
      "--quiet",
      "--line-width",
      MAXIMUM_CHARACTER_AMOUNT,
    ]
    
    args += ENV['TM_PYTHON_FMT_ISORT_EXTRA_OPTIONS'].split if ENV['TM_PYTHON_FMT_ISORT_EXTRA_OPTIONS']

    # this will override everything
    args = apply_config_if_exist(args, :isort)

    args += ["-"]

    skip_operation = false
    args.each_index.select{|i| args[i] == "--skip"}.each do |i|
      skip_operation = true if args[i+1] == ENV['TM_FILENAME']
    end
    
    unless skip_operation
      $OUTPUT, err = TextMate::Process.run(shell_command, args, :input => $DOCUMENT)
      TextMate.exit_show_tool_tip(err) unless err.nil? || err == ""
      $OUTPUT += "# isort #{args.join(' ')}" if ENV['TM_PYTHON_FMT_DEBUG']
      $DOCUMENT = $OUTPUT
    end
  end

  # callback.document.will-save
  def Python::autopep8
    shell_command = ENV['TM_PYTHON_FMT_AUTOPEP8'] || `command -v autopep8`.chomp
    TextMate.exit_show_tool_tip(tooltip_box($ERROR_COMMAND_ENVVAR % ["autopep8", "TM_PYTHON_FMT_AUTOPEP8"])) if shell_command.empty?

    args = [
      "--aggressive",
      "--aggressive",
      "--max-line-length",
      MAXIMUM_CHARACTER_AMOUNT,
    ]
    
    args += ENV['TM_PYTHON_FMT_AUTOPEP8_EXTRA_OPTIONS'].split if ENV['TM_PYTHON_FMT_AUTOPEP8_EXTRA_OPTIONS']
    
    # TM_PYTHON_FMT_AUTOPEP8_CUSTOM_OPTIONS will override everything...
    args = ENV['TM_PYTHON_FMT_AUTOPEP8_CUSTOM_OPTIONS'] if ENV['TM_PYTHON_FMT_AUTOPEP8_CUSTOM_OPTIONS']
    
    # this will override everything
    args = apply_config_if_exist(args, :autopep8)

    args += ["-"]
    $OUTPUT, err = TextMate::Process.run(shell_command, args, :input => $DOCUMENT)
    TextMate.exit_show_tool_tip(err) unless err.nil? || err == ""
    
    $OUTPUT += "\n# autopep8 #{args.join(' ')}" if ENV['TM_PYTHON_FMT_DEBUG']
    $DOCUMENT = $OUTPUT
  end

  def Python::run_will_save
    check_python = check_env("TM_PYTHON")
    TextMate.exit_show_tool_tip(check_python) unless check_python.nil?
    ENV['PATH'] = "#{File.dirname(ENV['TM_PYTHON'])}:#{ENV['PATH']}"
    
    self.autopep8
    self.isort
    
    print $OUTPUT
  end

  # callback.document.did-save
  def Python::flake8
    check_python = check_env("TM_PYTHON")
    TextMate.exit_show_tool_tip(check_python) unless check_python.nil?
    ENV['PATH'] = "#{File.dirname(ENV['TM_PYTHON'])}:#{ENV['PATH']}"

    shell_command = ENV['TM_PYTHON_FMT_FLAKE8'] || `command -v flake8`.chomp
    TextMate.exit_show_tool_tip(tooltip_box($ERROR_COMMAND_ENVVAR % ["flake8", "TM_PYTHON_FMT_FLAKE8"])) if shell_command.empty?
    
    args = [
      "--max-line-length",
      MAXIMUM_CHARACTER_AMOUNT,
      "--format",
      "%(row)d || %(col)d || %(code)s || %(text)s",
    ]
    
    args += ENV['TM_PYTHON_FMT_FLAKE8_EXTRA_OPTIONS'].split if ENV['TM_PYTHON_FMT_FLAKE8_EXTRA_OPTIONS']
    
    # TM_PYTHON_FMT_FLAKE8_CUSTOM_OPTIONS will override everything!
    args = ENV['TM_PYTHON_FMT_FLAKE8_CUSTOM_OPTIONS'] if ENV['TM_PYTHON_FMT_FLAKE8_CUSTOM_OPTIONS']
    
    # this will override everything
    args = apply_config_if_exist(args, :flake8)
    
    self.reset_markers
    
    out, err = TextMate::Process.run(shell_command, args, ENV['TM_FILEPATH'])
    TextMate.exit_show_tool_tip(err) unless err.nil? || err == ""

    if out.empty?
      success_message = "Source looks great 👍\nChecked agains \"#{MAXIMUM_CHARACTER_AMOUNT}\" chars!"
      success_message += "\n\nflake8 #{args.join(' ')}" if ENV['TM_PYTHON_FMT_DEBUG']
      TextMate.exit_show_tool_tip(tooltip_box(success_message))
    else
      self.set_markers(out)
      TextMate.exit_show_tool_tip("Fix error(s)!")
    end
    
  end
end
