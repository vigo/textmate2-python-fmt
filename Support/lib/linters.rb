require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'

module Linters
  extend Logging::ClassMethods

  TM_PROJECT_DIRECTORY = ENV["TM_PROJECT_DIRECTORY"]
  TM_FILENAME = ENV["TM_FILENAME"]
  TM_FILEPATH = ENV["TM_FILEPATH"]
  
  TM_PYTHON_FMT_BLACK_DEFAULTS = ENV["TM_PYTHON_FMT_BLACK_DEFAULTS"]
  TM_PYTHON_FMT_ISORT_DEFAULTS = ENV["TM_PYTHON_FMT_ISORT_DEFAULTS"]
  TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS = ENV["TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS"]
  
  module_function

  def find_config(config_file, check_home=false)
    path = check_home ? File.join(ENV["HOME"], config_file) : File.join(TM_PROJECT_DIRECTORY, config_file)
    File.exists?(path) ? path : nil
  end

  def pad_number(lines_count, line_number)
    padding = lines_count.to_s.length
    padding = 2 if lines_count < 10
    return sprintf("%0#{padding}d", line_number)
  end

  def parse_isort_errors(err)
    return nil if err.empty?

    original_errors = err.split("\n")
    errors = ["⚠️ isort Error ⚠️\n"] + original_errors
    Storage.add(errors)
    return errors
  end

  def parse_black_errors(err)
    return nil if err.empty?
    
    if err.start_with?("error:")
      original_errors = err.split("\n")
      errors = ["⚠️ black Error ⚠️\n"] + original_errors
      Storage.add(errors)
      
      match = original_errors.first.match(/^(.+?)\s(\d+):(\d+):/)
      if match
        message = match[1]
        line_number = match[2]
        column_number = match[3]
      end

      Helpers.set_marker "warning", line_number, message
      Helpers.goto "#{line_number}:#{column_number}"
      return errors
    end
    
    return nil
  end

  def parse_pylint_errors(err)
    return nil if err.empty?
    
    original_errors = err.split("\n")
    errors = ["⚠️ pylint Error ⚠️\n"] + original_errors
    Storage.add(errors)
    return errors
  end

  def parse_flake8_errors(err)
    return nil if err.empty?
    
    original_errors = err.split("\n")
    errors = ["⚠️ flake8 Error ⚠️\n"] + original_errors
    Storage.add(errors)
    return errors
  end

  def isort(options={})
    cmd = options[:cmd]
    input = options[:input]
    black_enabled = options[:black_enabled]
    virtual_env = options[:virtual_env]

    cmd_version = `#{cmd} --version-number`.chomp

    projects_config_file = find_config(".isort.cfg")
    unless projects_config_file
      errors = [
        "⚠️ isort Error ⚠️\n",
        "config file not found.",
        "project's config: #{projects_config_file}",
      ]
      Storage.add(errors)
      return input, errors
    end

    args = []
    
    users_black_config_file = find_config(".black", true)
    projects_black_config_file = find_config("pyproject.toml")

    args += ["--profile", "black"] if [users_black_config_file, projects_black_config_file].any? && black_enabled
    args << "--honor-noqa"
    args += ["--virtual-env", virtual_env] if !virtual_env.empty?

    if TM_PYTHON_FMT_ISORT_DEFAULTS
      isort_defaults = TM_PYTHON_FMT_ISORT_DEFAULTS.tokenize
      logger.debug "isort_defaults: #{isort_defaults.inspect}"
      args += isort_defaults
    end
    args << "-"

    logger.debug "cmd: #{cmd.inspect} | version: #{cmd_version} | args: #{args.inspect}"

    out, err = TextMate::Process.run(cmd, args, :input => input)
    logger.debug "out:\n#{out.inspect}\n\nerr: #{err.inspect}"

    errors = parse_isort_errors(err)
    out = input unless errors.nil?
    return out, errors
  end

  def black_formatter(options={})
    cmd = options[:cmd]
    input = options[:input]
    cmd_version = `#{cmd} --version | xargs`.chomp

    users_config_file = find_config(".black", true)
    projects_config_file = find_config("pyproject.toml")
    use_users_config_file = users_config_file && !projects_config_file
    
    possible_config_files = [users_config_file, projects_config_file]
    unless possible_config_files.any?
      errors = [
        "⚠️ black Error ⚠️\n",
        "config file not found.",
        "user's config: #{users_config_file}",
        "project's config: #{projects_config_file}",
      ]
      Storage.add(errors)
      return input, errors
    end
    
    args = ["--stdin-filename", TM_FILENAME]
    if TM_PYTHON_FMT_BLACK_DEFAULTS
      black_defaults = TM_PYTHON_FMT_BLACK_DEFAULTS.tokenize
      logger.debug "black_defaults: #{black_defaults.inspect}"
      args += black_defaults
    end

    args << "--pyi" if TM_FILENAME.end_with?(".pyi")
    args += ["--config", users_config_file] if use_users_config_file
    args << "-"

    logger.debug "cmd: #{cmd.inspect} | version: #{cmd_version} | args: #{args.inspect}"

    out, err = TextMate::Process.run(cmd, args, :input => input)
    logger.debug "out:\n#{out.inspect}\n\nerr: #{err.inspect}"

    errors = parse_black_errors(err)
    out = input unless errors.nil?
    return out, errors
  end

  def flake8(options={})
    cmd = options[:cmd]
    all_errors = options[:all_errors]
    
    cmd_version = `#{cmd} --version | xargs`.chomp

    users_config_file = find_config(".flake8", true)
    projects_config_file = find_config(".flake8")
    projects_setup_config_file = find_config("setup.cfg")
    
    args = [
      "--format",
      "%(row)d || %(col)d || %(code)s || %(text)s",
      "--stdin-display-name", TM_FILENAME
    ]
    
    found_any_config = [users_config_file, projects_config_file, projects_setup_config_file].any?
    if !found_any_config && TM_PYTHON_FMT_FLAKE8_DEFAULTS
      flkae8_defaults = TM_PYTHON_FMT_FLAKE8_DEFAULTS.tokenize
      logger.debug "flkae8_defaults: #{flkae8_defaults.inspect}"
      args += flkae8_defaults
    end
    
    logger.debug "cmd: #{cmd.inspect} | version: #{cmd_version} | args: #{args.inspect}"
    out, err = TextMate::Process.run(cmd, args, TM_FILEPATH)
    logger.debug "out:\n#{out.inspect}\n\nerr: #{err.inspect}"

    errors = parse_flake8_errors(err)
    return extract_flake8_errors(out, all_errors), errors
  end

  def pylint(options={})
    cmd = options[:cmd]
    all_errors = options[:all_errors]

    cmd_version = `#{cmd} --version | xargs`.chomp
    
    users_config_file = find_config(".pylintrc", true)
    projects_config_file = find_config(".pylintrc")
    
    pylintrc_file = nil
    pylintrc_file = users_config_file if users_config_file
    pylintrc_file = projects_config_file if projects_config_file # override
    
    args = [
      "--msg-template",
      "{line} || {column} || {msg_id} || {msg}",
    ]
    args << '--rcfile' << pylintrc_file
    
    if TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS
      pylint_defaults = TM_PYTHON_FMT_PYLINT_EXTRA_OPTIONS.tokenize
      logger.debug "pylint_defaults: #{pylint_defaults.inspect}"
      args += pylint_defaults
    end
    
    logger.debug "cmd: #{cmd.inspect} | version: #{cmd_version} | args: #{args.inspect}"
    
    out, err = TextMate::Process.run(cmd, args, TM_FILEPATH)
    logger.debug "out:\n#{out.inspect}\n\nerr: #{err.inspect}"
    
    errors = parse_pylint_errors(err)
    return extract_pylint_errors(out, all_errors), errors
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
          :column => column.to_i,
          :code => code,
          :message => "[#{error_type}] [#{code}]: #{message}",
          :type => error_type,
          :line_number => line_number.to_i,
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
          :column => column.to_i,
          :code => code,
          :message => "[#{error_type}] [#{code}]: #{message}",
          :type => error_type,
          :line_number => line_number.to_i,
        }
      end
    end
    
    return "flake8 check completed"
  end

  def generate_error_report(all_errors, pylint_success_message, flake8_message, line_count, linters)
    pylint_errors = []
    flake8_errors = []
    go_to_errors = []

    Storage.destroy(true)

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
      error_report << "\t black 👍" if linters[:black]
      error_report << "\t isort 👍" if linters[:isort]
      error_report << "\t pylint 👍" if linters[:pylint]
      error_report << "\t flake8 👍" if linters[:flake8]
      error_report << "\nGood to go! ✨ 🍰 ✨\n"
    else
      total_error_count = pylint_error_count+flake8_error_count
      str_total_error = Helpers.pluralize(total_error_count, "error", "errors")

      error_report << "⚠️ found #{total_error_count} #{str_total_error} ⚠️"
      error_report << ""

      if pylint_error_count > 0
        error_report << "[#{pylint_error_count}] pylint #{Helpers.pluralize(pylint_error_count, 'error', 'errors')}:"
        pylint_errors.sort_by{|err| err[:line_number]}.each do |err|
          error_report << "  - #{err[:line_number]} -> #{err[:message]}"
          fmt_ln = pad_number(line_count, err[:line_number])
          fmt_cn = pad_number(line_count, err[:column])
          go_to_errors << "#{fmt_ln}:#{fmt_cn} | #{err[:message]}"
        end
        error_report << ""
      end

      if flake8_error_count > 0
        error_report << "[#{flake8_error_count}] flake8 #{Helpers.pluralize(flake8_error_count, 'error', 'errors')}:"
        flake8_errors.sort_by{|err| err[:line_number]}.each do |err|
          error_report << "  - #{err[:line_number]} -> #{err[:message]}"
          fmt_ln = pad_number(line_count, err[:line_number])
          fmt_cn = pad_number(line_count, err[:column])
          go_to_errors << "#{fmt_ln}:#{fmt_cn} | #{err[:message]}"
        end
        error_report << ""
      end
    end
    
    error_report << pylint_success_message unless pylint_success_message.nil?
    Storage.add(go_to_errors, true) if go_to_errors
    return error_report
  end

end