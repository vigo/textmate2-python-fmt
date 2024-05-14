require ENV["TM_BUNDLE_SUPPORT"] + "/lib/constants"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/logger"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/storage"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/helpers"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/linters"

module PythonFmt
  include Logging
  include Constants

  extend Storage
  extend Helpers

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
    reset_markers
    destroy_storage

    can_run, messages = can_run_document_will_save

    unless can_run
      logger.fatal "can not run run_document_will_save"

      str_binary = pluralize(messages.size, 'binary', 'binaries')
      errors = ["Warning!\n"] + messages.map{|msg| "\t- #{msg}"}
      errors += ["\nYou need to install required #{str_binary} to continue."]
      errors += ["\nIf you are in a virtual environment please set\n\t- TM_PYTHON_FMT_VIRTUAL_ENV"]
      errors += ["variable or use:\n\t- TM_PYTHON_FMT_DISABLE_<LINTER> convention"]
      create_storage(errors)
      exit_boxify_tool_tip(errors.join("\n"))
    end
    
    exit_discard unless enabled?
    
    @document = STDIN.read
    
    exit_discard if document_empty?
    exit_discard if document_has_first_line_comment?
    
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
    storage_err = get_storage
    exit_boxify_tool_tip(storage_err) if storage_err

    can_run, messages = can_run_run_document_did_save

    unless can_run
      logger.fatal "can not run run_document_did_save"

      str_binary = pluralize(messages.size, 'binary', 'binaries')
      errors = ["Warning!\n"] + messages.map{|msg| "\t- #{msg}"}
      errors += ["\nYou need to install required #{str_binary} to continue."]
      errors += ["\nIf you are in a virtual environment please set\n\t- TM_PYTHON_FMT_VIRTUAL_ENV"]
      errors += ["variable or use:\n\t- TM_PYTHON_FMT_DISABLE_<LINTER> convention"]
      create_storage(errors)
      exit_boxify_tool_tip(errors.join("\n"))
    end
    
    exit_discard unless enabled?

    @document = STDIN.read
    
    exit_discard if document_empty?
    exit_discard if document_has_first_line_comment?
    
    logger.info "running run_document_did_save"
    
    storage_err = get_storage
    if storage_err
      logger.error "storage_err: #{storage_err.inspect}"
      exit_boxify_tool_tip(storage_err)
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
    set_markers("error", all_errors) if all_errors
    
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
    exit_boxify_tool_tip(error_report.join("\n"))
  end
end
