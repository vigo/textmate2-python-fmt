require ENV["TM_BUNDLE_SUPPORT"] + "/lib/logger"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/storage"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/helpers"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/linters"

module PythonFmt
  include Logging

  TM_PYTHON_FMT_VIRTUAL_ENV = ENV["TM_PYTHON_FMT_VIRTUAL_ENV"]

  def self.find_binary(cmd)
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
    
    path = File.join(TM_PYTHON_FMT_VIRTUAL_ENV, "bin", cmd) unless TM_PYTHON_FMT_VIRTUAL_ENV.empty?
    
    logger.info "#{cmd} -> path: #{path.inspect}"
    
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

  @document = nil
  
  module_function

  def read_stdin
    @document = STDIN.read
  end  
  
  def document
    @document
  end

  def document=(value)
    @document = value
  end
  
  def document_empty?
    document.nil? || document.empty? || document.match(/\S/).nil?
  end

  def document_has_first_line_comment?
    document.split("\n").first.include?("# TM_PYTHON_FMT_DISABLE")
  end

  def enabled?
    !TM_PYTHON_FMT_DISABLE
  end

  def can_run_document_will_save?
    warning_messages = []
    any_binary = []

    if TM_PYTHON_FMT_PYTHON_PATH.empty?
      warning_messages << '"python" is required.'
    else
      any_binary << TM_PYTHON_FMT_PYTHON_PATH
    end

    if TM_PYTHON_FMT_BLACK.empty?
      warning_messages << '"black" is required.'
    else
      any_binary << TM_PYTHON_FMT_BLACK
    end

    if TM_PYTHON_FMT_ISORT.empty?
      warning_messages << '"isort" is required.'
    else
      any_binary << TM_PYTHON_FMT_ISORT
    end
    
    logger.info "any? #{any_binary.any?}"
    logger.error "warning_messages: #{warning_messages.inspect}"

    return any_binary.any?, warning_messages
  end

  def can_run_run_document_did_save?
    warning_messages = []
    any_binary = []

    if TM_PYTHON_FMT_PYLINT.empty?
      warning_messages << '"pylint" is required.'
    else
      any_binary << TM_PYTHON_FMT_PYLINT
    end

    logger.info "any? #{any_binary.any?}"
    logger.error "warning_messages: #{warning_messages.inspect}"

    return any_binary.any?, warning_messages
  end

  def run_document_will_save(options={})
    Helpers.reset_markers
    Storage.destroy

    can_run_document_will_save, warning_messages = can_run_document_will_save?
    
    unless can_run_document_will_save
      logger.fatal "can not run run_document_will_save"
      str_binary = Helpers.pluralize(warning_messages.size, 'binary', 'binaries')
      errors = ["Warning!\n"] + warning_messages.map{|msg| "\t- #{msg}"}
      errors += ["\nYou need to install required #{str_binary} to continue."]
      Storage.add(errors)
      Helpers.exit_boxify_tool_tip(errors.join("\n"))
    end
    
    Helpers.exit_discard unless enabled?
    
    read_stdin
    
    Helpers.exit_discard if document_empty?
    Helpers.exit_discard if document_has_first_line_comment?
    
    logger.info "running run_document_will_save"
    
    errors_black_formatter = nil
    errors_isort = nil
    
    unless TM_PYTHON_FMT_DISABLE_BLACK
      out, errors_black_formatter = Linters.black_formatter :cmd => TM_PYTHON_FMT_BLACK, :input => document
      document = out
    end

    if errors_black_formatter.nil? && !TM_PYTHON_FMT_DISABLE_ISORT
      logger.info "will run isort"
      out, _ = Linters.isort :cmd => TM_PYTHON_FMT_ISORT, 
                                        :input => document,
                                        :black_enabled => !TM_PYTHON_FMT_DISABLE_BLACK,
                                        :virtual_env => TM_PYTHON_FMT_VIRTUAL_ENV
      document = out
      
    end

    print document
  end

  def run_document_did_save
    can_run_run_document_did_save, warning_messages = can_run_run_document_did_save?

    unless can_run_run_document_did_save
      logger.fatal "can not run run_document_did_save"
      str_binary = Helpers.pluralize(warning_messages.size, 'binary', 'binaries')
      errors = ["Warning!\n"] + warning_messages.map{|msg| "\t- #{msg}"}
      errors += ["\nYou need to install required #{str_binary} to continue."]
      Storage.add(errors)
      Helpers.exit_boxify_tool_tip(errors.join("\n"))
    end
    
    Helpers.exit_discard unless enabled?

    read_stdin
    
    Helpers.exit_discard if document_empty?
    Helpers.exit_discard if document_has_first_line_comment?
    
    logger.info "running run_document_did_save"
    
    storage_err = Storage.get
    if storage_err
      logger.error "storage_err: #{storage_err.inspect}"
      Helpers.exit_boxify_tool_tip(storage_err)
    end
    
    all_errors = {}
    
    pylint_result = nil
    flake8_result = nil
    
    errors_pylint = nil
    errors_flake8 = nil
    
    unless TM_PYTHON_FMT_DISABLE_PYLINT
      logger.info "will run pylint"
      pylint_result, errors_pylint = Linters.pylint :cmd => TM_PYTHON_FMT_PYLINT,
                                                    :all_errors => all_errors
      logger.error "pylint_result: #{pylint_result.inspect}"
      logger.error "errors_pylint: #{errors_pylint.inspect}"
    end

    if errors_pylint.nil? && !TM_PYTHON_FMT_DISABLE_FLAKE8
      logger.info "will run flake8"
      flake8_result, errors_flake8 = Linters.flake8 :cmd => TM_PYTHON_FMT_FLAKE8,
                                                    :all_errors => all_errors
      logger.error "flake8_result: #{flake8_result.inspect}"
      logger.error "errors_flake8: #{errors_flake8.inspect}"
    end

    logger.error "all_errors: #{all_errors.inspect}"
    Helpers.set_markers("error", all_errors) if all_errors
    
    linters = {
      :black => !TM_PYTHON_FMT_DISABLE_BLACK,
      :isort => !TM_PYTHON_FMT_DISABLE_ISORT,
      :pylint => !TM_PYTHON_FMT_DISABLE_PYLINT,
      :flake8 => !TM_PYTHON_FMT_DISABLE_FLAKE8,
    }
    
    error_report = Linters.generate_error_report(
      all_errors,
      pylint_result,
      errors_flake8,
      document.split("\n").size,
      linters
    )
    Helpers.exit_boxify_tool_tip(error_report.join("\n"))
  end
end
