#!/usr/bin/env ruby -wKU

require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/executor'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/save_current_document'

MAXIMUM_CHARACTER_AMOUNT = ENV['TM_PEP8ER_CUSTOM_MAX_CHARS'] || (ENV['TM_SCOPE'].include?('source.python.django') && ENV['TM_PEP8ER_DJANGO_MAX_CHARS']) || "79"

module Pep8er
  def Pep8er::autopep8(options={})
    save_in_place = true
    save_in_place = options[:save] if options.has_key?(:save)

    shell_command = ENV['TM_PEP8ER_AUTOPEP8'] || `command -v autopep8`.chomp

    if save_in_place
      TextMate.save_current_document('py')
    else
      TextMate.save_if_untitled('py')
    end

    args = []
    args.push('--in-place') if save_in_place
    args += [
      '--aggressive',
      '--aggressive',
      '--max-line-length',
      MAXIMUM_CHARACTER_AMOUNT,
    ]

    # if you like to add extra params use this TM variable
    args += ENV['TM_PEP8ER_AUTOPEP8_EXTRA_OPTIONS'] if ENV['TM_PEP8ER_AUTOPEP8_EXTRA_OPTIONS']
    
    # this will override everything defined by default
    # do not forget to add: --in-place
    args = ENV['TM_PEP8ER_AUTOPEP8_CUSTOM_OPTIONS'] if ENV['TM_PEP8ER_AUTOPEP8_CUSTOM_OPTIONS']
    
    out, err = TextMate::Process.run(shell_command, args, ENV['TM_FILEPATH'])
    TextMate.exit_replace_document(out) unless save_in_place
  end

  def Pep8er::flake8(options={})
    shell_command = ENV['TM_PEP8ER_FLAKE8'] || `command -v flake8`.chomp

    TextMate.save_current_document('py') unless ENV['TM_FILEPATH']

    args = [
      '--max-line-length',
      MAXIMUM_CHARACTER_AMOUNT,
      '--format',
      '%(row)d || %(code)s || %(text)s',
    ]
    # if you like to add extra params use this TM variable
    args += ENV['TM_PEP8ER_FLAKE8_EXTRA_OPTIONS'] if ENV['TM_PEP8ER_FLAKE8_EXTRA_OPTIONS']

    # this will override everything defined by default
    args = ENV['TM_PEP8ER_FLAKE8_CUSTOM_OPTIONS'] if ENV['TM_PEP8ER_FLAKE8_CUSTOM_OPTIONS']

    out, err = TextMate::Process.run(shell_command, args, ENV['TM_FILEPATH'])

    system(ENV['TM_MATE'], "--clear-mark=note", "--clear-mark=warning", "--clear-mark=error")
    
    lines = out.split("\n")
    if lines.count == 0
      
      succes_tooltip_message = "#{"-"*64}\n"\
        "Source looks great 👍\n"\
        "Checked agains *#{MAXIMUM_CHARACTER_AMOUNT}* chars!\n"\
        "#{"-"*64}"

      TextMate.exit_show_tool_tip(succes_tooltip_message) 
    end

    lines.each do |line|
      line_result   = line.split(" || ")

      line_number   = line_result[0]
      error_code    = line_result[1]
      error_message = line_result[2]

      system(ENV['TM_MATE'], '--line', "#{line_number}", '--set-mark', 'error:"' + error_message +'"')
    end
  end
end