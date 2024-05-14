require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

require ENV["TM_BUNDLE_SUPPORT"] + "/lib/constants"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/storage"

module PythonFmt
  include Constants
  include Storage
  
  module_function

  def goto_error
    if File.exist?(GOTO_FILE)
      errors = File.read(GOTO_FILE)

      if errors
        errors = errors.split("\n").sort
        selected_index = TextMate::UI.menu(errors)

        unless selected_index.nil?
          selected_error = errors[selected_index]
          if selected_error
            line = selected_error.split(" ").first
            system(ENV["TM_MATE"], "--uuid", TM_DOCUMENT_UUID, "--line", line)
          end
        end

      end
    end
  end
end
