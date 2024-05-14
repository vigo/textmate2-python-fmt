require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'

class String
  def tokenize
    self.
      split(/\s(?=(?:[^'"]|'[^']*'|"[^"]*")*$)/).
      select {|s| not s.empty? }.
      map {|s| s.gsub(/(^ +)|( +$)|(^["']+)|(["]+$)/, '')}
  end
end

module Helpers
  TM_DOCUMENT_UUID = ENV["TM_DOCUMENT_UUID"]

  TM_PROJECT_DIRECTORY = ENV["TM_PROJECT_DIRECTORY"]
  TM_FILENAME = ENV["TM_FILENAME"]

  TOOLTIP_LINE_LENGTH = ENV["TM_PYTHON_FMT_TOOLTIP_LINE_LENGTH"] || "100"
  TOOLTIP_LEFT_PADDING = ENV["TM_PYTHON_FMT_TOOLTIP_LEFT_PADDING"] || "2"
  TOOLTIP_BORDER_CHAR = ENV["TM_PYTHON_FMT_TOOLTIP_BORDER_CHAR"] || "-"

  module_function
  
  def pluralize(n, singular, plural=nil)
    return plural.nil? ? singular + "s" : plural if n > 1
    return singular
  end

  def goto(line)
    system(ENV["TM_MATE"], "--uuid", TM_DOCUMENT_UUID, "--line", line)
  end
  
  def reset_markers
    system(
      ENV["TM_MATE"],
      "--uuid", TM_DOCUMENT_UUID,
      "--clear-mark=note",
      "--clear-mark=warning",
      "--clear-mark=error"
    )
  end

  def set_marker(mark, line, msg)
    unless line.nil?
      tm_args = [
        '--uuid', TM_DOCUMENT_UUID,
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

  def exit_discard
    TextMate.exit_discard
  end

  def chunkify(s, max_len, left_padding)
    out = []
    s.split("\n").each do |line|
      if line.size > max_len
        words_matrix = []
        words_matrix_index = 0
        words_len = 0
        line.split(" ").each do |word|
          unless words_matrix[words_matrix_index].nil?
            words_len = words_matrix[words_matrix_index].join(" ").size
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
        padding_word = " " * left_padding
        words_matrix.each do |row|
          rows << "#{padding_word}#{row.join(" ")}" 
        end
        out << rows.join("\n#{padding_word}↪")
      else
        out << line
      end
    end
    out.join("\n")
  end

  def boxify(txt)
    s = chunkify(txt, TOOLTIP_LINE_LENGTH.to_i, TOOLTIP_LEFT_PADDING.to_i)
    s = s.split("\n")
    ll = s.map{|l| l.size}.max || 1
    lsp = TOOLTIP_BORDER_CHAR * ll
    s.unshift(lsp)
    s << lsp
    s = s.map{|l| "  #{l}  "}
    s.join("\n")
  end

  def exit_boxify_tool_tip(msg)
    TextMate.exit_show_tool_tip(boxify(msg))
  end

  def find_config(config_file, check_home=false)
    path = check_home ? File.join(ENV["HOME"], config_file) : File.join(TM_PROJECT_DIRECTORY, config_file)
    File.exists?(path) ? path : nil
  end

  def pad_number(lines_count, line_number)
    padding = lines_count.to_s.length
    padding = 2 if lines_count < 10
    return sprintf("%0#{padding}d", line_number)
  end
  
  def get_required_config_file(options={})
    to_use = nil
    
    files = options[:files] || []
    if files.size > 0
      files.each do |cfg|
        config_file = cfg[:file]
        check_home = cfg[:home] || false
        possible_config = find_config(config_file, check_home)
        to_use = possible_config if possible_config
      end
    end
    
    to_use
  end
end