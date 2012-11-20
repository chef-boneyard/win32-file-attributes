require 'ffi'

module Windows
  module File
    module Functions
      extend FFI::Library
      ffi_lib :kernel32

      attach_function :CloseHandle, [:ulong], :bool
      attach_function :CreateFileW, [:buffer_in, :ulong, :ulong, :pointer, :ulong, :ulong, :ulong], :ulong
      attach_function :DeviceIoControl, [:ulong, :ulong, :pointer, :ulong, :pointer, :ulong, :pointer, :pointer], :bool
      attach_function :GetFileAttributesW, [:buffer_in], :ulong
      attach_function :SetFileAttributesW, [:buffer_in, :ulong], :ulong

      def CTL_CODE(device, function, method, access)
         ((device) << 16) | ((access) << 14) | ((function) << 2) | (method)
      end

      def FSCTL_SET_COMPRESSION
         CTL_CODE(9, 16, 0, 3)
      end
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
