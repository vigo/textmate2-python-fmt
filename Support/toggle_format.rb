require ENV["TM_SUPPORT_PATH"] + "/lib/escape"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/logger"

$selected = false

module PythonFmt
  include Logging
  
  COMMENT_START = "# fmt: off\n"
  COMMENT_END = "# fmt: on\n"
  
  module_function

  def toggle_format
    logger.info "running toggle format"

    document = STDIN.read
    exit if document.empty?

    selected = ENV["TM_SELECTED_TEXT"].nil? ? false : true
    selection = selected ? document : ENV["TM_CURRENT_LINE"] + "\n"
    selection_array = selection.to_a
    document_array = document.to_a
    
    if selected
      logger.debug "we have selection:\n#{selection_array.inspect}"
      print "${0:"
      print COMMENT_START unless selection_array.first == COMMENT_START
      if selection_array.first == COMMENT_START && selection_array.last == COMMENT_END
        print selection_array[1..-2]
      else
        print selection
      end
      print COMMENT_END unless selection_array.last == COMMENT_END
      print "}"
    else
      logger.debug "we don't have selection, we have:\n#{selection.inspect}"
      current_line_number = ENV["TM_LINE_NUMBER"].to_i
      current_line_index = current_line_number - 1

      lines_till_start = document_array[0, current_line_index]
      lines_after_current_line = document_array[current_line_number..-1]

      print lines_till_start.join
      print "${0:"
      print COMMENT_START
      print selection
      print COMMENT_END
      print "}"
      print lines_after_current_line.join
    end
  end
end
