require 'ffi'

module Windows
  module File
    module Functions
      extend FFI::Library
      ffi_lib :kernel32

      attach_function 'GetFileAttributesW', [:buffer_in], :ulong
      attach_function 'SetFileAttributesW', [:buffer_in, :ulong], :ulong
    end
  end
end

class String
  # Convenience method for converting strings to UTF-16LE for wide character
  # functions that require it.
  def wincode
    (self.tr(File::SEPARATOR, File::ALT_SEPARATOR) + 0.chr).encode('UTF-16LE')
  end
end
