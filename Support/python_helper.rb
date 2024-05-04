#!/usr/bin/env ruby18

require 'logger'

require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/executor'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'

module Colors
  BLACK            = "\e[30m"
  RED              = "\e[32m"
  RED_BOLD         = "\e[01;32m"
  GREEN            = "\e[32m"
  GREEN_BOLD       = "\e[01;32m"
  YELLOW           = "\e[33m"
  YELLOW_BOLD      = "\e[01;33m"
  BLUE             = "\e[34m"
  BLUE_BOLD        = "\e[01;34m"
  MAGENTA          = "\e[35m"
  MAGENTA_BOLD     = "\e[01;35m"
  CYAN             = "\e[36m"
  CYAN_BOLD        = "\e[01;36m"
  WHITE            = "\e[37m"
  WHITE_BOLD       = "\e[01;37m"
  EXTENDED         = "\e[38m"
  OFF              = "\e[0m"
end


module Configuration
  TM_PROJECT_DIRECTORY = ENV["TM_PROJECT_DIRECTORY"]
  TM_FILENAME = ENV["TM_FILENAME"]

  TOOLTIP_LINE_LENGTH = ENV["TM_PYTHON_FMT_TOOLTIP_LINE_LENGTH"] || '120'
  TOOLTIP_LEFT_PADDING = ENV["TM_PYTHON_FMT_TOOLTIP_LEFT_PADDING"] || '20'
  TOOLTIP_BORDER_CHAR = ENV["TM_PYTHON_FMT_TOOLTIP_BORDER_CHAR"] || '-'
  
  ENABLE_LOGGING = !ENV["ENABLE_LOGGING"].nil?
  TM_PYTHON_FMT_DISABLE = ENV["TM_PYTHON_FMT_DISABLE"].nil?

  TM_PYTHON_FMT_PYTHON_PATH = ENV["TM_PYTHON_FMT_PYTHON_PATH"] || nil
  TM_PYTHON_FMT_VIRTUAL_ENV = ENV["TM_PYTHON_FMT_VIRTUAL_ENV"] || nil

  TM_PYTHON_FMT_BLACK = ENV["TM_PYTHON_FMT_BLACK"] || nil
  TM_PYTHON_FMT_BLACK_DEFAULTS = ENV["TM_PYTHON_FMT_BLACK_DEFAULTS"] || nil
  TM_PYTHON_FMT_DISABLE_BLACK = !ENV["TM_PYTHON_FMT_DISABLE_BLACK"].nil?
  
  TM_PYTHON_FMT_ISORT = ENV["TM_PYTHON_FMT_ISORT"] || nil
  TM_PYTHON_FMT_ISORT_DEFAULTS = ENV["TM_PYTHON_FMT_ISORT_DEFAULTS"] | nil
  TM_PYTHON_FMT_DISABLE_ISORT = !ENV["TM_PYTHON_FMT_DISABLE_ISORT"].nil?

  TM_PYTHON_FMT_DISABLE_PYLINT = !ENV["TM_PYTHON_FMT_DISABLE_PYLINT"].nil?
  TM_PYTHON_FMT_PYLINT = ENV["TM_PYTHON_FMT_PYLINT"] || nil
  TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS = ENV["TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS"] || nil

  TM_PYTHON_FMT_DISABLE_FLAKE8 = !ENV["TM_PYTHON_FMT_DISABLE_FLAKE8"].nil?
  TM_PYTHON_FMT_FLAKE8 = ENV["TM_PYTHON_FMT_FLAKE8"] || nil
  TM_PYTHON_FMT_FLAKE8_DEFAULTS = ENV["TM_PYTHON_FMT_FLAKE8_DEFAULTS"] || nil

  def self.logging_enabled?
    ENABLE_LOGGING
  end
end


module Storage
  def self.file_path(name)
    "/tmp/textmate-python-fmt-#{name}.error"
  end

  def self.add(name, error_message)
    File.open(file_path(name), 'w') do |file|
      file.puts error_message
    end
  end

  def self.get(name)
    path = file_path(name)
    if File.exist?(path)
      File.open(path, 'r') do |file|
        return file.read
      end
    end
    nil
  end

  def self.destroy(name)
    path = file_path(name)
    if File.exist?(path)
      File.delete(path)
    end
  end
end


module Python
  include Colors
  include Configuration
  include Storage
  
  @logger = if Configuration.logging_enabled?
    Logger.new('/tmp/textmate-python-fmt.log')
  else
    Logger.new(nil)
  end

  # DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
  if Configuration.logging_enabled?
    @logger.level = Logger::DEBUG
    @logger.progname = "Python-FMT"
    @logger.formatter = proc do |severity, _, progname, msg|
      color_code = case severity
        when "DEBUG" then BLUE
        when "INFO" then GREEN
        when "WARN" then YELLOW
        when "ERROR" then RED
        when "FATAL" then MAGENTA
      end
      caller_info = caller(5).first
      method_name = caller_info.match(/`([^']*)'/) ? caller_info.match(/`([^']*)'/)[1] : "unknown"
      "[#{WHITE_BOLD}#{progname}#{OFF}][#{color_code}#{severity}#{OFF}][#{CYAN_BOLD}#{method_name}#{OFF}]: #{msg}\n"
    end
  end
  
  @document = nil
  
  module_function
  
  def logger
    @logger
  end

  def read_stdin
    @document = STDIN.read
  end  

  def document
    @document
  end

  def document=(value)
    @document = value
  end

  def chunkify(s, max_len, left_padding)
    out = []
    s.split("\n").each do |line|
      if line.size > max_len
        words_matrix = []
        words_matrix_index = 0
        words_len = 0
        line.split(' ').each do |word|
          unless words_matrix[words_matrix_index].nil?
            words_len = words_matrix[words_matrix_index].join(' ').size
          end

          if words_len + word.size < max_len
            words_matrix[words_matrix_index] = [] if words_matrix[words_matrix_index].nil?
            words_matrix[words_matrix_index] << word
          else
            words_matrix_index = words_matrix_index + 1
            words_matrix[words_matrix_index] = [] if words_matrix[words_matrix_index].nil?
            words_matrix[words_matrix_index] << word
          end
        end
      
        rows = []
        words_matrix.each do |row|
          rows << row.join(' ')
        end
      
        padding_word = ' ' * left_padding
        out << rows.join("\n" + padding_word)
      else
        out << line
      end
    end
    out.join("\n")
  end

  def boxify(txt)
    s = chunkify(txt, TOOLTIP_LINE_LENGTH.to_i, TOOLTIP_LEFT_PADDING.to_i)
    s = s.split("\n")
    ll = s.map{|l| l.size}.max
    lsp = TOOLTIP_BORDER_CHAR * ll
    s.unshift(lsp)
    s << lsp
    s = s.map{|l| "  #{l}  "}
    s.join("\n")
  end

  def bundle_enabled?
    TM_PYTHON_FMT_DISABLE
  end

  def document_empty?
    document.nil? || document.empty? || document.match(/\S/).nil?
  end
  
  def reset_markers
    system(ENV["TM_MATE"], "--uuid", ENV["TM_DOCUMENT_UUID"], "--clear-mark=note",
                                                              "--clear-mark=warning",
                                                              "--clear-mark=error"
    )
  end
  
  def set_marker(mark, line, msg)
    unless line.nil?
      tm_args = [
        '--uuid', ENV['TM_DOCUMENT_UUID'],
        '--line', "#{line}",
        '--set-mark', "#{mark}:#{msg}",
      ]
      system(ENV['TM_MATE'], *tm_args)
    end
  end

  def set_markers(mark, errors_list)
    errors_list.each do |line_number, errors|
      messages = []
      errors.each do |data|
        messages << "#{data[:message]}"
      end
      set_marker(mark, line_number, messages.join("\n"))
    end
  end

  def extract_black_errors(error_message)
    if error_message =~ /(\d+):(\d+)/
      line_number = $1
      column_number = $2
      "#{line_number}"
    else
      nil
    end
  end

  def extract_pylint_errors(errors, all_errors)
    pylint_success_message = ""
    error_type = "pylint"
    errors.each do |line|
      if line.include?("||")
        pylint_message = line.split(" || ")

        line_number = pylint_message[0].to_i
        column = pylint_message[1]
        code = pylint_message[2]
        message = pylint_message[3].chomp

        all_errors[line_number] = [] unless all_errors.has_key?(line_number)
        all_errors[line_number] << {
          :column => column,
          :code => code,
          :message => "[#{error_type}] [#{code}]: #{message}",
          :type => error_type,
          :line_number => line_number,
        }
      end

      if line.include?('has been rated')
        pylint_success_message = line.gsub(/[-\n]/, "")
      end
    end
    
    return pylint_success_message
  end

  def extract_flake8_errors(errors, all_errors)
    error_type = "flake8"
    errors.each do |line|
      if line.include?("||")
        flake8_message = line.split(" || ")

        line_number = flake8_message[0].to_i
        column = flake8_message[1]
        code = flake8_message[2]
        message = flake8_message[3].chomp

        all_errors[line_number] = [] unless all_errors.has_key?(line_number)
        all_errors[line_number] << {
          :column => column,
          :code => code,
          :message => "[#{error_type}] [#{code}]: #{message}",
          :type => error_type,
          :line_number => line_number,
        }
      end
    end
  end
  
  def setup_ok?
    return false, "TM_PYTHON_FMT_PYTHON_PATH is not set" unless TM_PYTHON_FMT_PYTHON_PATH
    ENV["PATH"] = "#{File.dirname(TM_PYTHON_FMT_PYTHON_PATH)}:#{ENV["PATH"]}"
    return true, "SETUP OK"
  end
  
  def display_err(msg)
    TextMate.exit_show_tool_tip(boxify(msg))
  end
  
  def config_file_exists?(filename, local=false)
    file = local ? File.join(ENV["HOME"], filename) : File.join(TM_PROJECT_DIRECTORY, filename)
    file_exists = File.exists?(file)
    return file, file_exists
  end
  
  def run_isort
    cmd = TM_PYTHON_FMT_ISORT || `command -v isort`.chomp
    if cmd.empty?
      display_err("isort binary not found")
    end

    configfile, configfile_exists = config_file_exists?(".isort.cfg")

    args = []
    
    black_local_configfile, black_local_configfile_exists = config_file_exists?(".black", true)
    black_configfile, black_configfile_exists = config_file_exists?("pyproject.toml")
    
    args.concat(["--profile", "black"]) if (black_local_configfile_exists || black_configfile_exists) && !TM_PYTHON_FMT_DISABLE_BLACK
    
    args << "--honor-noqa"
    args << "--virtual-env" << TM_PYTHON_FMT_VIRTUAL_ENV if TM_PYTHON_FMT_VIRTUAL_ENV
    args.concat(TM_PYTHON_FMT_ISORT_DEFAULTS.split) if TM_PYTHON_FMT_ISORT_DEFAULTS && !configfile_exists
    args << "-"

    cmd_version = `#{cmd} --version | xargs`.chomp
    result, err = TextMate::Process.run(cmd, args, :input => document)
    
    err = "[isort]: #{err}" unless err.empty?
    return result, err
  end
  
  def run_black_formatter
    cmd = TM_PYTHON_FMT_BLACK || `command -v black`.chomp
    if cmd.empty?
      display_err("black binary not found")
    end
    
    local_configfile, local_configfile_exists = config_file_exists?(".black", true)
    configfile, configfile_exists = config_file_exists?("pyproject.toml")
    
    args = []
    args.concat(TM_PYTHON_FMT_BLACK_DEFAULTS.split) if TM_PYTHON_FMT_BLACK_DEFAULTS && !configfile_exists
    args << "--pyi" if TM_FILENAME.end_with?(".pyi")
    args.concat(["--config", local_configfile]) if local_configfile_exists &&  !configfile_exists
    args << "-"

    cmd_version = `#{cmd} --version | xargs`.chomp
    result, err = TextMate::Process.run(cmd, args, :input => document)
    err = "[black]: #{err}" unless err.empty?
    return result, err
  end
  
  def run_flake8
    cmd = TM_PYTHON_FMT_FLAKE8 || `command -v flake8`.chomp

    if TM_PYTHON_FMT_VIRTUAL_ENV
      flake8_bin_from_virtual_env = File.join(TM_PYTHON_FMT_VIRTUAL_ENV, "bin", "flake8")
      cmd = flake8_bin_from_virtual_env unless `command -v #{flake8_bin_from_virtual_env}`.chomp.empty?
    end
    
    if cmd.empty?
      display_err("flake8 binary not found")
    end
    
    _, setup_configfile_exists = config_file_exists?("setup.cfg")
    _, configfile_exists = config_file_exists?(".flake8")

    args = [
      '--format',
      '%(row)d || %(col)d || %(code)s || %(text)s',
    ]

    unless [setup_configfile_exists, configfile_exists].any?
      args.concat(TM_PYTHON_FMT_FLAKE8_DEFAULTS.split) if TM_PYTHON_FMT_FLAKE8_DEFAULTS
    end
    
    cmd_version = `#{cmd} --version | xargs`.chomp
    result, err = TextMate::Process.run(cmd, args, ENV['TM_FILEPATH'])
    return result, err
  end
  
  def run_pylint
    cmd = TM_PYTHON_FMT_PYLINT || `command -v pylint`.chomp

    if TM_PYTHON_FMT_VIRTUAL_ENV
      pylint_bin_from_virtual_env = File.join(TM_PYTHON_FMT_VIRTUAL_ENV, "bin", "pylint")
      cmd = pylint_bin_from_virtual_env unless `command -v #{pylint_bin_from_virtual_env}`.chomp.empty?
    end

    if cmd.empty?
      display_err("pylint binary not found")
    end
    
    local_configfile, local_configfile_exists = config_file_exists?(".pylintrc", true)
    configfile, configfile_exists = config_file_exists?(".pylintrc")
    
    pylintrc_file = local_configfile if local_configfile_exists
    
    # override local pylint, use project's pylintrc
    pylintrc_file = configfile if configfile_exists
    
    args = [
      '--msg-template',
      '{line} || {column} || {msg_id} || {msg}',
    ]
    args << '--rcfile' << pylintrc_file if pylintrc_file
    
    args.concat(TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS.split) if TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS && !pylintrc_file
    
    cmd_version = `#{cmd} --version | xargs`.chomp
    result, _ = TextMate::Process.run(cmd, args, ENV['TM_FILEPATH'])
    return result, ""
  end
  
  # callback.document.will-save.100
  def run_document_will_save
    TextMate.exit_discard unless bundle_enabled?

    read_stdin
    
    TextMate.exit_discard if document_empty?
    TextMate.exit_discard if document.split("\n").first.include?("# TM_PYTHON_FMT_DISABLE")

    reset_markers
    
    ok, err = setup_ok?
    display_err(err) unless ok
    
    unless TM_PYTHON_FMT_DISABLE_BLACK
      result, err = run_black_formatter 
      if err.empty?
        self.document = result
        Storage.destroy("black")
      else
        Storage.add("black", err)
        set_marker("error", extract_black_errors(err), err.chomp)
        display_err(err)
      end
    end

    unless TM_PYTHON_FMT_DISABLE_ISORT && Storage.get("black").nil?
      result, err = run_isort
      if err.empty?
        self.document = result
        Storage.destroy("isort")
      else
        Storage.add("isort", err)
        display_err(err)
      end
    end
    
    print document
  end

  # callback.document.did-save.100
  def run_document_did_save
    TextMate.exit_discard unless bundle_enabled?

    read_stdin
    
    TextMate.exit_discard if document_empty?
    TextMate.exit_discard if document.split("\n").first.include?("# TM_PYTHON_FMT_DISABLE")

    if !Storage.get("black").nil?
      TextMate.exit_discard
    end

    if !Storage.get("isort").nil?
      TextMate.exit_discard
    end
    
    all_errors = {}
    
    unless TM_PYTHON_FMT_DISABLE_PYLINT
      result, err = run_pylint
      display_err(err) unless err.empty?
      pylint_success_message = extract_pylint_errors(result, all_errors)
    end
    
    unless TM_PYTHON_FMT_DISABLE_FLAKE8
      result, err = run_flake8
      display_err(err) unless err.empty?
      extract_flake8_errors(result, all_errors)
    end

    set_markers("error", all_errors)
    error_report = generate_error_report(all_errors, pylint_success_message)

    display_err(error_report.join("\n")) if error_report
  end

  def generate_error_report(all_errors, pylint_success_message)
    pylint_errors = []
    flake8_errors = []

    all_errors.each do |line_number, errors|
      errors.each do |error|
        pylint_errors << error if error[:type] == "pylint"
        flake8_errors << error if error[:type] == "flake8"
      end
    end
    
    pylint_error_count = pylint_errors.size
    flake8_error_count = flake8_errors.size
    error_report = []

    if all_errors.size == 0
      error_report << "following checks completed:\n"
      error_report << "\t black 👍" unless TM_PYTHON_FMT_DISABLE_BLACK
      error_report << "\t isort 👍" unless TM_PYTHON_FMT_DISABLE_ISORT
      error_report << "\t pylint 👍" unless TM_PYTHON_FMT_DISABLE_PYLINT
      error_report << "\t flake8 👍" unless TM_PYTHON_FMT_DISABLE_FLAKE8
      error_report << "\nGood to go! ✨ 🍰 ✨\n"
    else
      error_report << "⚠️ found #{pylint_error_count+flake8_error_count} error(s) ⚠️"
      error_report << ""
      if pylint_error_count > 0
        error_report << "[#{pylint_error_count}] pylint error(s)"
        pylint_errors.each do |err|
          error_report << "\t- #{err[:message]} in line: #{err[:line_number]}"
        end
        error_report << ""
      end
      if flake8_error_count > 0
        error_report << "[#{flake8_error_count}] flake8 error(s)"
        flake8_errors.each do |err|
          error_report << "\t- #{err[:message]} in line: #{err[:line_number]}"
        end
        error_report << ""
      end
    end
    
    error_report << pylint_success_message if pylint_success_message
    
    return error_report
  end

end
