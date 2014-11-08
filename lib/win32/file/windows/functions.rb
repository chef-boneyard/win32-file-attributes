require 'ffi'

module Windows
  module File
    module Functions
      extend FFI::Library

      private

      # Wrapper method for attach_function + private
      def self.attach_pfunc(*args)
        attach_function(*args)
        private args[0]
      end

      typedef :ulong, :dword
      typedef :uintptr_t, :handle

      ffi_lib :kernel32

      attach_pfunc :CloseHandle, [:handle], :bool
      attach_pfunc :CreateFileW, [:buffer_in, :dword, :dword, :pointer, :dword, :dword, :handle], :handle
      attach_pfunc :DeviceIoControl, [:handle, :dword, :pointer, :dword, :pointer, :dword, :pointer, :pointer], :bool
      attach_pfunc :GetFileAttributesW, [:buffer_in], :dword
      attach_pfunc :SetFileAttributesW, [:buffer_in, :dword], :bool

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
  unless instance_methods.include?(:wincode)
    # Convenience method for converting strings to UTF-16LE for wide character
    # functions that require it.
    def wincode
      (self.tr(File::SEPARATOR, File::ALT_SEPARATOR) + 0.chr).encode('UTF-16LE')
    end
  end
end
