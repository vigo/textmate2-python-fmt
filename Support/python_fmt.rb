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
    
    path = File.join(TM_PYTHON_FMT_VIRTUAL_ENV, "bin", cmd) if TM_PYTHON_FMT_VIRTUAL_ENV
    
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

  def document_empty?
    @document.nil? || @document.empty? || @document.match(/\S/).nil?
  end

  def document_has_first_line_comment?
    @document.split("\n").first.include?("# TM_PYTHON_FMT_DISABLE")
  end

  def enabled?
    !TM_PYTHON_FMT_DISABLE
  end

  def can_run_document_will_save
    messages = []
    messages << "[black] required" if TM_PYTHON_FMT_BLACK.empty? && !TM_PYTHON_FMT_DISABLE_BLACK
    messages << "[isort] required" if TM_PYTHON_FMT_ISORT.empty? && !TM_PYTHON_FMT_DISABLE_ISORT
    can_run = messages.size == 0
    
    logger.debug "can_run_document_will_save: #{can_run} | #{messages.inspect}"
    return can_run, messages
  end

  def can_run_run_document_did_save
    messages = []
    messages << "[pylint] required" if TM_PYTHON_FMT_PYLINT.empty? && !TM_PYTHON_FMT_DISABLE_PYLINT
    messages << "[flake8] required" if TM_PYTHON_FMT_FLAKE8.empty? && !TM_PYTHON_FMT_DISABLE_FLAKE8
    can_run = messages.size == 0
    
    logger.debug "can_run_run_document_did_save: #{can_run} | #{messages.inspect}"
    return can_run, messages
  end

  def run_document_will_save(options={})
    Helpers.reset_markers
    Storage.destroy

    can_run, messages = can_run_document_will_save

    unless can_run
      logger.fatal "can not run run_document_will_save"

      str_binary = Helpers.pluralize(messages.size, 'binary', 'binaries')
      errors = ["Warning!\n"] + messages.map{|msg| "\t- #{msg}"}
      errors += ["\nYou need to install required #{str_binary} to continue."]
      errors += ["\nIf you are in a virtual environment please set\n\t- TM_PYTHON_FMT_VIRTUAL_ENV"]
      errors += ["variable or use:\n\t- TM_PYTHON_FMT_DISABLE_<LINTER> convention"]
      Storage.add(errors)
      Helpers.exit_boxify_tool_tip(errors.join("\n"))
    end
    
    Helpers.exit_discard unless enabled?
    
    @document = STDIN.read
    
    Helpers.exit_discard if document_empty?
    Helpers.exit_discard if document_has_first_line_comment?
    
    logger.info "running run_document_will_save"
    
    errors_black_formatter = nil
    errors_isort = nil
    
    unless TM_PYTHON_FMT_DISABLE_BLACK
      logger.info "will run black"
      out, errors_black_formatter = Linters.black_formatter(:cmd => TM_PYTHON_FMT_BLACK, :input => @document)
      @document = out
    end

    if errors_black_formatter.nil? && !TM_PYTHON_FMT_DISABLE_ISORT
      logger.info "will run isort"
      out, _ = Linters.isort :cmd => TM_PYTHON_FMT_ISORT, 
                                        :input => @document,
                                        :black_enabled => !TM_PYTHON_FMT_DISABLE_BLACK,
                                        :virtual_env => TM_PYTHON_FMT_VIRTUAL_ENV
      @document = out
      
    end

    print @document
  end

  def run_document_did_save
    storage_err = Storage.get
    if storage_err
      Helpers.exit_boxify_tool_tip(storage_err)
    end

    can_run, messages = can_run_run_document_did_save

    unless can_run
      logger.fatal "can not run run_document_did_save"

      str_binary = Helpers.pluralize(messages.size, 'binary', 'binaries')
      errors = ["Warning!\n"] + messages.map{|msg| "\t- #{msg}"}
      errors += ["\nYou need to install required #{str_binary} to continue."]
      errors += ["\nIf you are in a virtual environment please set\n\t- TM_PYTHON_FMT_VIRTUAL_ENV"]
      errors += ["variable or use:\n\t- TM_PYTHON_FMT_DISABLE_<LINTER> convention"]
      Storage.add(errors)
      Helpers.exit_boxify_tool_tip(errors.join("\n"))
    end
    
    Helpers.exit_discard unless enabled?

    @document = STDIN.read
    
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
      @document.split("\n").size,
      linters
    )
    Helpers.exit_boxify_tool_tip(error_report.join("\n"))
  end
end
