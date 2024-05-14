require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'

require ENV["TM_BUNDLE_SUPPORT"] + "/lib/constants"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/storage"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/helpers"

module Linters
  include Constants

  extend Logging::ClassMethods
  extend Storage
  extend Helpers

  module_function

  def parse_isort_errors(err, out)
    return nil if err.empty? && !out.empty?
    original_errors = []
    original_errors = err.split("\n") unless err.empty?
    original_errors = ["check your config or extra options, something is wrong"] if out.empty?
    errors = ["⚠️ isort Error ⚠️\n"] + original_errors
    create_storage(errors)
    return errors
  end

  def parse_black_errors(err)
    return nil if err.empty?
    
    if err.start_with?("error:") || err.include?("Error") || err.include?("error")
      original_errors = err.split("\n")
      errors = ["⚠️ black Error ⚠️\n"] + original_errors
      create_storage(errors)
      
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
    create_storage(errors)
    return errors
  end

  def parse_flake8_errors(err)
    return nil if err.empty?
    
    original_errors = err.split("\n")
    errors = ["⚠️ flake8 Error ⚠️\n"] + original_errors
    create_storage(errors)
    return errors
  end

  def black_formatter(options={})
    cmd = options[:cmd]
    input = options[:input]
    cmd_version = `#{cmd} --version | xargs`.chomp

    cfg_files = [
      {:file => ".black", :home => true},
      {:file => "pyproject.toml"},
    ]
    which_config_to_use = get_required_config_file(:files => cfg_files)
    logger.debug "black_formatter config: #{which_config_to_use.inspect}"

    args = ["--stdin-filename", TM_FILENAME]
    if TM_PYTHON_FMT_BLACK_DEFAULTS
      black_defaults = TM_PYTHON_FMT_BLACK_DEFAULTS.tokenize
      logger.debug "black_defaults: #{black_defaults.inspect}"
      args += black_defaults
    end

    args << "--pyi" if TM_FILENAME.end_with?(".pyi")
    args += ["--config", which_config_to_use] if which_config_to_use
    args << "-"

    logger.debug "cmd: #{cmd.inspect} | version: #{cmd_version} | args: #{args.inspect}"

    out, err = TextMate::Process.run(cmd, args, :input => input)
    logger.debug "out:\n#{out.inspect}\n\nerr: #{err.inspect}"

    errors = parse_black_errors(err)
    out = input unless errors.nil?
    return out, errors
  end

  def isort(options={})
    cmd = options[:cmd]
    input = options[:input]
    black_enabled = options[:black_enabled]
    virtual_env = options[:virtual_env]
    
    cmd_version = `#{cmd} --version-number`.chomp

    cfg_files = [
      {:file => ".isort.cfg", :home => true},
      {:file => ".isort.cfg"},
    ]
    which_config_to_use = get_required_config_file(:files => cfg_files)
    logger.debug "isort config: #{which_config_to_use.inspect}"

    args = []
    
    users_black_config_file = find_config(".black", true)
    projects_black_config_file = find_config("pyproject.toml")

    args += ["--profile", "black"] if [users_black_config_file, projects_black_config_file].any? && black_enabled
    args << "--honor-noqa"
    args += ["--virtual-env", virtual_env] if virtual_env
    args += ["--settings-path", which_config_to_use] if which_config_to_use

    if TM_PYTHON_FMT_ISORT_DEFAULTS
      isort_defaults = TM_PYTHON_FMT_ISORT_DEFAULTS.tokenize
      logger.debug "isort_defaults: #{isort_defaults.inspect}"
      args += isort_defaults
    end
    args << "-"

    logger.debug "cmd: #{cmd.inspect} | version: #{cmd_version} | args: #{args.inspect}"

    out, err = TextMate::Process.run(cmd, args, :input => input)
    logger.debug "out:\n#{out.inspect}\n\nerr: #{err.inspect}"

    errors = parse_isort_errors(err, out)
    out = input unless errors.nil?
    return out, errors
  end

  def pylint(options={})
    cmd = options[:cmd]
    all_errors = options[:all_errors]

    cmd_version = `#{cmd} --version | xargs`.chomp
    
    cfg_files = [
      {:file => ".pylintrc", :home => true},
      {:file => ".pylintrc"},
    ]
    which_config_to_use = get_required_config_file(:files => cfg_files)
    logger.debug "pylint config: #{which_config_to_use.inspect}"
    
    args = [
      "--msg-template",
      "{line} || {column} || {msg_id} || {msg}",
    ]
    args += ["--rcfile", which_config_to_use] if which_config_to_use
    
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
  
  def flake8(options={})
    cmd = options[:cmd]
    all_errors = options[:all_errors]
    
    cmd_version = `#{cmd} --version | xargs`.chomp

    cfg_files = [
      {:file => ".flake8", :home => true},
      {:file => ".flake8"},
      {:file => "tox.ini"},
      {:file => "setup.cfg"},
    ]
    which_config_to_use = get_required_config_file(:files => cfg_files)
    logger.debug "flake8 config: #{which_config_to_use.inspect}"

    args = [
      "--format",
      "%(row)d || %(col)d || %(code)s || %(text)s",
      "--stdin-display-name", TM_FILENAME
    ]
    
    args += ["--config", which_config_to_use] if which_config_to_use
    
    if !which_config_to_use && TM_PYTHON_FMT_FLAKE8_DEFAULTS
      flake8_defaults = TM_PYTHON_FMT_FLAKE8_DEFAULTS.tokenize
      logger.debug "flake8_defaults: #{flake8_defaults.inspect}"
      args += flake8_defaults
    end
    
    logger.debug "cmd: #{cmd.inspect} | version: #{cmd_version} | args: #{args.inspect}"

    out, err = TextMate::Process.run(cmd, args, TM_FILEPATH)
    logger.debug "out:\n#{out.inspect}\n\nerr: #{err.inspect}"

    errors = parse_flake8_errors(err)
    return extract_flake8_errors(out, all_errors), errors
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

    destroy_storage(true)

    all_errors.each do |line_number, errors|
      errors.each do |error|
        pylint_errors << error if error[:type] == "pylint"
        flake8_errors << error if error[:type] == "flake8"
      end
    end
    
    pylint_error_count = pylint_errors.size
    flake8_error_count = flake8_errors.size
    error_report = []
    
    possible_linter_checks = []

    if linters[:black]
      cfg_files = [
        {:file => ".black", :home => true},
        {:file => "pyproject.toml"},
      ]
      used_config_file = get_required_config_file(:files => cfg_files)
      linter_name = "[black]"
      linter_name += "(#{used_config_file})" if used_config_file
      possible_linter_checks << linter_name
    end

    if linters[:isort]
      cfg_files = [
        {:file => ".isort.cfg", :home => true},
        {:file => ".isort.cfg"},
      ]
      used_config_file = get_required_config_file(:files => cfg_files)
      linter_name = "[isort]"
      linter_name += "(#{used_config_file})" if used_config_file
      possible_linter_checks << linter_name
    end

    if linters[:pylint]
      cfg_files = [
        {:file => ".pylintrc", :home => true},
        {:file => ".pylintrc"},
      ]
      used_config_file = get_required_config_file(:files => cfg_files)
      linter_name = "[pylint]"
      linter_name += "(#{used_config_file})" if used_config_file
      possible_linter_checks << linter_name
    end

    if linters[:flake8]
      cfg_files = [
        {:file => ".flake8", :home => true},
        {:file => ".flake8"},
        {:file => "tox.ini"},
        {:file => "setup.cfg"},
      ]
      used_config_file = get_required_config_file(:files => cfg_files)
      linter_name = "[flake8]"
      linter_name += "(#{used_config_file})" if used_config_file
      possible_linter_checks << linter_name
    end

    if all_errors.size == 0
      if possible_linter_checks.size > 0
        str_checks = Helpers.pluralize(possible_linter_checks.size, "check")
        error_report << "following #{str_checks} completed:\n"
        possible_linter_checks.each do |linter|
          error_report << "\t ✅ #{linter}"
        end
        error_report << "\n"
      end
      error_report << "Good to go! ✨ 🍰 ✨\n"
    else
      total_error_count = pylint_error_count+flake8_error_count
      str_total_error = Helpers.pluralize(total_error_count, "error", "errors")

      error_report << "⚠️ found #{total_error_count} #{str_total_error} ⚠️\n"
      error_report << "🔍 Use Option ( ⌥ ) + G to jump error line!"
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
    create_storage(go_to_errors, true) if go_to_errors
    return error_report
  end
end