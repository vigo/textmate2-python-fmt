#!/usr/bin/env ruby18

require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/executor'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'

$OUTPUT = ""
$TOOLTIP_OUTPUT = []
$DOCUMENT = STDIN.read
$ERROR_LINES = {}
$DEBUG_OUT = []

TM_PYTHON_FMT_DISABLE_ISORT = ENV['TM_PYTHON_FMT_DISABLE_ISORT'] || false
TM_PYTHON_FMT_DISABLE_BLACK = ENV['TM_PYTHON_FMT_DISABLE_BLACK'] || false
TM_PYTHON_FMT_DISABLE_FLAKE8 = ENV['TM_PYTHON_FMT_DISABLE_FLAKE8'] || false
TM_PYTHON_FMT_DISABLE_PYLINT = ENV['TM_PYTHON_FMT_DISABLE_PYLINT'] || false

if ENV['TM_PYTHON_FMT_DEBUG']
  $DEBUG_OUT << "TM_PYTHON_FMT_DISABLE_ISORT: #{TM_PYTHON_FMT_DISABLE_ISORT}"
  $DEBUG_OUT << "TM_PYTHON_FMT_DISABLE_BLACK: #{TM_PYTHON_FMT_DISABLE_BLACK}"
  $DEBUG_OUT << "TM_PYTHON_FMT_DISABLE_FLAKE8: #{TM_PYTHON_FMT_DISABLE_FLAKE8}"
  $DEBUG_OUT << "TM_PYTHON_FMT_DISABLE_PYLINT: #{TM_PYTHON_FMT_DISABLE_PYLINT}"
end

module Python
  module_function
  def env_err(var)
    "Error: #{var} variable is not set"
  end
  
  def handle_err_messages(msg)
    if ENV['TM_PYTHON_FMT_DEBUG']
      TextMate.exit_create_new_document(msg)
    else
      TextMate.exit_show_tool_tip(msg)
    end
  end
  
  def config_file_exist?(filename)
    return File.exists?(File.join(ENV['TM_PROJECT_DIRECTORY'], filename))
  end

  def check_env(var)
    $DEBUG_OUT << "var: #{var} -> #{ENV[var]}" if ENV['TM_PYTHON_FMT_DEBUG']
    return nil if ENV[var]
    return env_err(var)
  end

  def setup
    err = check_env("TM_PYTHON_FMT_PYTHON_PATH")
    ENV["PATH"] = "#{File.dirname(ENV["TM_PYTHON_FMT_PYTHON_PATH"])}:#{ENV["PATH"]}" if err.nil?

    unless err.nil?
      check_tm_python = check_env("TM_PYTHON")
      err = check_tm_python if check_tm_python.nil?
    end
    
    $DEBUG_OUT << "TM_PYTHON -> #{ENV['TM_PYTHON']}" if ENV['TM_PYTHON_FMT_DEBUG']
    $DEBUG_OUT << "PATH -> #{ENV['PATH']}" if ENV['TM_PYTHON_FMT_DEBUG']
    err
  end
  
  def boxify(text)
    "#{"-" * 80}\n #{text}\n#{"-" * 80}"
  end

  def reset_markers
    system(
      ENV["TM_MATE"],
      "--uuid",
      ENV["TM_DOCUMENT_UUID"],
      "--clear-mark=note",
      "--clear-mark=warning",
      "--clear-mark=error"
    )
  end
  
  def set_markers
    $ERROR_LINES.each do |line_number, errs|
      out_message = []
      errs.each do |data|
        out_message << "[#{data[:code]}]: #{data[:message]}"
      end
      tm_args = [
        "--uuid",
        ENV["TM_DOCUMENT_UUID"],
        "--line",
        "#{line_number}",
        "--set-mark",
        "error:#{out_message.join("\n")}",
      ]
      system(ENV["TM_MATE"], *tm_args)
    end
  end
  
  def update_errors(input)
    input.split("\n").each do |line|
      line_result = line.split(" || ")

      if line_result.length > 1
        line_number = line_result[0].to_i
        column = line_result[1]
        code = line_result[2]
        message = line_result[3]
        $ERROR_LINES[line_number] = [] unless $ERROR_LINES.has_key?(line_number)
        $ERROR_LINES[line_number] << {
          :column => column,
          :code => code,
          :message => message,
        }
      end
    end
  end

  # callback.document.will-save
  def isort
    cmd = ENV["TM_PYTHON_FMT_ISORT"] || `command -v isort`.chomp
    TextMate.exit_show_tool_tip(boxify("isort binary not found!")) if cmd.empty?

    args = []
    args << "--virtual-env" << ENV["TM_PYTHON_FMT_VIRTUAL_ENV"] if ENV["TM_PYTHON_FMT_VIRTUAL_ENV"]
    args += ENV["TM_PYTHON_FMT_ISORT_DEFAULTS"].split if ENV["TM_PYTHON_FMT_ISORT_DEFAULTS"] and !config_file_exist?('.isort.cfg')
    args << "-"
    
    if ENV['TM_PYTHON_FMT_DEBUG']
      isort_version = `#{cmd} --version-number`.chomp
      $DEBUG_OUT << "isort version: #{isort_version}"
      $DEBUG_OUT << "isort args: #{args.join(' ')}" 
    end
    
    $OUTPUT, err = TextMate::Process.run(cmd, args, :input => $DOCUMENT)
    handle_err_messages(err) unless err.nil? || err == ""

    unless $OUTPUT.empty?
      $DOCUMENT = $OUTPUT
    else
      $OUTPUT = $DOCUMENT
    end
  end

  # callback.document.will-save
  def black
    cmd = ENV["TM_PYTHON_FMT_BLACK"] || `command -v black`.chomp
    TextMate.exit_show_tool_tip(boxify("black binary not found!")) if cmd.empty?
    
    local_configfile = File.join(ENV['HOME'], ".black")
    args = []
    args += ENV["TM_PYTHON_FMT_BLACK_DEFAULTS"].split if ENV["TM_PYTHON_FMT_BLACK_DEFAULTS"] and !config_file_exist?('pyproject.toml')
    args += ["--config", local_configfile] if File.exists?(local_configfile) and !config_file_exist?('pyproject.toml')
    args << "-"
    
    if ENV['TM_PYTHON_FMT_DEBUG']
      black_version = `#{cmd} --version | xargs`.chomp
      $DEBUG_OUT << "black version: #{black_version}" 
      $DEBUG_OUT << "black args: #{args.join(' ')}" 
    end
    
    $OUTPUT, err = TextMate::Process.run(cmd, args, :input => $DOCUMENT)
    $DOCUMENT = $OUTPUT
  end
  
  # callback.document.did-save
  def flake8
    cmd = ENV["TM_PYTHON_FMT_FLAKE8"] || `command -v flake8`.chomp
    TextMate.exit_show_tool_tip(boxify("flake8 binary not found!")) if cmd.empty?

    args = [
      "--format",
      "%(row)d || %(col)d || %(code)s || %(text)s",
    ]

    unless [config_file_exist?('setup.cfg'), config_file_exist?('.flake8')].any?
      args += ENV["TM_PYTHON_FMT_FLAKE8_DEFAULTS"].split if ENV["TM_PYTHON_FMT_FLAKE8_DEFAULTS"]
    end

    if ENV['TM_PYTHON_FMT_DEBUG']
      flake8_version = `#{cmd} --version | xargs`
      $DEBUG_OUT << "flake8 version: #{flake8_version}" 
      $DEBUG_OUT << "flake8 args: #{args.join(' ')}" 
    end
    
    out, err = TextMate::Process.run(cmd, args, ENV["TM_FILEPATH"])
    
    err = nil if err && err.include?("\n") && err.split("\n").first && err.split("\n").first.downcase.start_with?("possible nested set")
    handle_err_messages(err) unless err.nil? || err == ""

    if out.empty?
      $TOOLTIP_OUTPUT << "\t flake8 👍"
    else
      update_errors(out)
    end
  end
  
  # callback.document.did-save
  def pylint
    cmd = ENV["TM_PYTHON_FMT_PYLINT"] || `command -v pylint`.chomp

    if ENV["TM_PYTHON_FMT_VIRTUAL_ENV"]
      pylint_path_venv = "#{ENV["TM_PYTHON_FMT_VIRTUAL_ENV"]}/bin/pylint"
      pylint_cmd_exist = `command -v #{pylint_path_venv}`.chomp
      cmd = pylint_path_venv unless pylint_cmd_exist.empty?
    end

    TextMate.exit_show_tool_tip(boxify("pylint binary not found!")) if cmd.empty?

    args = [
      "--msg-template",
      "{line} || {column} || {msg_id} || {msg}",
    ]
    
    pylintrc = nil
    local_pylintrc = File.join(ENV['HOME'], '.pylintrc')
    pylintrc = local_pylintrc if File.exists?(local_pylintrc)
    pylintrc = ENV["TM_PYTHON_FMT_PYLINTRC"] if ENV["TM_PYTHON_FMT_PYLINTRC"]
    
    TextMate.exit_show_tool_tip(boxify("pylintrc not found")) unless pylintrc
    TextMate.exit_show_tool_tip(boxify("pylintrc not found")) unless File.exists?(pylintrc)
    
    args << "--rcfile" << pylintrc if pylintrc
    
    args += ENV["TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS"].split if ENV["TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS"]
    
    if ENV['TM_PYTHON_FMT_DEBUG']
      pylint_version = `#{cmd} --version | xargs`.chomp
      $DEBUG_OUT << "pylint args: #{args.join(' ')}"
      $DEBUG_OUT << "pylint version: #{pylint_version.split("\n").join(' ')}"
    end
    
    out, err = TextMate::Process.run(cmd, args, ENV["TM_FILEPATH"])
    handle_err_messages(err) unless err.nil? || err == ""

    if out.include?("||")
      update_errors(out)
    end
    
    success_msg = ""
    if out.include?("has been rated")
      success_msg += "\t" + out.gsub(/[-\n]/, '') + "\n\n"
    end
    success_msg+= "\t pylint 👍" if out.empty? or !args.include?("--errors-only")

    
    $TOOLTIP_OUTPUT << success_msg unless success_msg.empty?
  end
  
  # before save
  def run_document_will_save
    reset_markers

    return if $DOCUMENT.empty?
    TextMate.exit_discard if ENV["TM_PYTHON_FMT_DISABLE"] or $DOCUMENT.split('\n').first.include?('# TM_PYTHON_FMT_DISABLE')

    err = setup
    handle_err_messages(err) unless err.nil?
    
    if TM_PYTHON_FMT_DISABLE_BLACK
      $OUTPUT = $DOCUMENT
    else
      black
    end
    
    if TM_PYTHON_FMT_DISABLE_ISORT
      $OUTPUT = $DOCUMENT
    else
      isort
    end

    puts "#{$DEBUG_OUT.map{|i| "# #{i}"}.join("\n")}" if ENV['TM_PYTHON_FMT_DEBUG']
    print $OUTPUT
  end
  
  # after save
  def run_document_did_save
    return if $DOCUMENT.empty?
    TextMate.exit_discard if ENV["TM_PYTHON_FMT_DISABLE"] or $DOCUMENT.split("\n").first.rstrip == '# TM_PYTHON_FMT_DISABLE'
    
    err = setup
    handle_err_messages(err) unless err.nil?

    pylint unless TM_PYTHON_FMT_DISABLE_PYLINT
    flake8 unless TM_PYTHON_FMT_DISABLE_FLAKE8

    set_markers

    if $ERROR_LINES.empty?
      $TOOLTIP_OUTPUT.unshift("\t black 👍") unless TM_PYTHON_FMT_DISABLE_BLACK
      $TOOLTIP_OUTPUT.unshift("\t isort 👍") unless TM_PYTHON_FMT_DISABLE_ISORT
      $TOOLTIP_OUTPUT.unshift("Following checks completed:\n")
      $TOOLTIP_OUTPUT << "\nGood to go! ✨ 🍰 ✨"
      result = $TOOLTIP_OUTPUT.join("\n")
    else
      result = ["Found #{$ERROR_LINES.length} error(s)\n"]
      $ERROR_LINES.each do |line, data|
        result << "[line #{line}]"
        data.each do |err|
          result << "\t- #{err[:code]} : #{err[:message]}"
        end
      end
      result = result.join("\n")
    end

    result = "#{result}\n\n#{$DEBUG_OUT.map{|i| "# #{i}"}.join("\n")}" if ENV['TM_PYTHON_FMT_DEBUG']

    handle_err_messages(boxify(result))
  end
end

