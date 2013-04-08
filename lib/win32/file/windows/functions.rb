require 'ffi'

module Windows
  module File
    module Functions
      extend FFI::Library
      typedef :ulong, :dword
      typedef :uintptr_t, :handle

      ffi_lib :kernel32

      attach_function :CloseHandle, [:handle], :bool
      attach_function :CreateFileW, [:buffer_in, :dword, :dword, :pointer, :dword, :dword, :handle], :handle
      attach_function :DeviceIoControl, [:handle, :dword, :pointer, :dword, :pointer, :dword, :pointer, :pointer], :bool
      attach_function :GetFileAttributesW, [:buffer_in], :dword
      attach_function :SetFileAttributesW, [:buffer_in, :dword], :bool

      def CTL_CODE(device, function, method, access)
         ((device) << 16) | ((access) << 14) | ((function) << 2) | (method)
      end

      def FSCTL_SET_COMPRESSION
         CTL_CODE(9, 16, 0, 3)
      end

      def FSCTL_SET_SPARSE
         CTL_CODE(9, 49, 0, 0)
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
