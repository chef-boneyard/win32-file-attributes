require File.join(File.dirname(__FILE__), 'windows', 'constants')
require File.join(File.dirname(__FILE__), 'windows', 'structs')
require File.join(File.dirname(__FILE__), 'windows', 'functions')

class File
  include Windows::File::Constants
  include Windows::File::Functions
  extend Windows::File::Constants
  extend Windows::File::Structs
  extend Windows::File::Functions

  WIN32_FILE_VERSION = '0.7.0'

  ## SINGLETON METHODS

  def self.attributes(file)
    attributes = GetFileAttributesW(file.wincode)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    arr = []

    arr << 'archive' if attributes & FILE_ATTRIBUTE_ARCHIVE > 0
    arr << 'compressed' if attributes & FILE_ATTRIBUTE_COMPRESSED > 0
    arr << 'directory' if attributes & FILE_ATTRIBUTE_DIRECTORY > 0
    arr << 'encrypted' if attributes & FILE_ATTRIBUTE_ENCRYPTED > 0
    arr << 'hidden' if attributes & FILE_ATTRIBUTE_HIDDEN > 0
    arr << 'indexed' if attributes & FILE_ATTRIBUTE_NOT_CONTENT_INDEXED == 0
    arr << 'normal' if attributes & FILE_ATTRIBUTE_NORMAL > 0
    arr << 'offline' if attributes & FILE_ATTRIBUTE_OFFLINE > 0
    arr << 'readonly' if attributes & FILE_ATTRIBUTE_READONLY > 0
    arr << 'reparse_point' if attributes & FILE_ATTRIBUTE_REPARSE_POINT > 0
    arr << 'sparse' if attributes & FILE_ATTRIBUTE_SPARSE_FILE > 0
    arr << 'system' if attributes & FILE_ATTRIBUTE_SYSTEM > 0
    arr << 'temporary' if attributes & FILE_ATTRIBUTE_TEMPORARY > 0

    arr
  end

  # Sets the file attributes based on the given (numeric) +flags+. This does
  # not remove existing attributes, it merely adds to them. Use the
  # File.remove_attributes method if you want to remove them.
  #
  # Please not that certain attributes cannot always be applied. For example,
  # you cannot convert a regular file into a directory. Common sense should
  # guide you here.
  #
  def self.set_attributes(file, flags)
    wfile = file.wincode
    attributes = GetFileAttributesW(wfile)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    attributes |= flags

    if SetFileAttributesW(wfile, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  # Removes the file attributes based on the given (numeric) +flags+.
  #
  def self.remove_attributes(file, flags)
    wfile = file.wincode
    attributes = GetFileAttributesW(wfile)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    attributes &= ~flags

    if SetFileAttributesW(wfile, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  def self.normal?(file)
    check_for_attribute(file, FILE_ATTRIBUTE_NORMAL)
  end

  def self.offline?(file)
    check_for_attribute(file, FILE_ATTRIBUTE_OFFLINE)
  end

  def self.readonly?(file)
    check_for_attribute(file, FILE_ATTRIBUTE_READONLY)
  end

  def self.reparse_point?(file)
    check_for_attribute(file, FILE_ATTRIBUTE_REPARSE_POINT)
  end

  def self.sparse?(file)
    check_for_attribute(file, FILE_ATTRIBUTE_SPARSE_FILE)
  end

  def self.system?(file)
    check_for_attribute(file, FILE_ATTRIBUTE_SYSTEM)
  end

  def self.temporary?(file)
    check_for_attribute(file, FILE_ATTRIBUTE_TEMPORARY)
  end

  class << self
    alias read_only? readonly?
  end

  ## INSTANCE METHODS

  def archive=(bool)
    wide_path  = self.path.wincode
    attributes = GetFileAttributesW(wide_path)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    if bool
      attributes |= FILE_ATTRIBUTE_ARCHIVE;
    else
      attributes &= ~FILE_ATTRIBUTE_ARCHIVE;
    end

    if SetFileAttributesW(wide_path, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  def compressed=(bool)
    in_buf = FFI::MemoryPointer.new(:ulong)
    bytes  = FFI::MemoryPointer.new(:ulong)

    compression_value = bool ? COMPRESSION_FORMAT_DEFAULT : COMPRESSION_FORMAT_NONE
    in_buf.write_ulong(compression_value)

    # We can't use get_osfhandle here because we need specific attributes
    handle = CreateFileW(
      self.path.wincode,
      FILE_READ_DATA | FILE_WRITE_DATA,
      FILE_SHARE_READ | FILE_SHARE_WRITE,
      nil,
      OPEN_EXISTING,
      0,
      0
    )

    if handle == INVALID_HANDLE_VALUE
      raise SystemCallError.new("CreateFile", FFI.errno)
    end

    begin
      bool = DeviceIoControl(
        handle,
        FSCTL_SET_COMPRESSION(),
        in_buf,
        in_buf.size,
        nil,
        0,
        bytes,
        nil
      )

      unless bool
        raise SystemCallError.new("DeviceIoControl", FFI.errno)
      end
    ensure
      CloseHandle(handle)
    end

    self
  end

  # Sets the hidden attribute to true or false.  Setting this attribute to
  # true means that the file is not included in an ordinary directory listing.
  #
  def hidden=(bool)
    wide_path  = self.path.wincode
    attributes = GetFileAttributesW(wide_path)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    if bool
      attributes |= FILE_ATTRIBUTE_HIDDEN;
    else
      attributes &= ~FILE_ATTRIBUTE_HIDDEN;
    end

    if SetFileAttributesW(wide_path, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  # Sets the 'indexed' attribute to true or false.  Setting this to
  # false means that the file will not be indexed by the content indexing
  # service.
  #
  def indexed=(bool)
    wide_path  = self.path.wincode
    attributes = GetFileAttributesW(wide_path)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    if bool
      attributes &= ~FILE_ATTRIBUTE_NOT_CONTENT_INDEXED;
    else
      attributes |= FILE_ATTRIBUTE_NOT_CONTENT_INDEXED;
    end

    if SetFileAttributes(wide_path, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  alias :content_indexed= :indexed=

  # Sets the normal attribute. Note that only 'true' is a valid argument,
  # which has the effect of removing most other attributes.  Attempting to
  # pass any value except true will raise an ArgumentError.
  #
  def normal=(bool)
    unless bool
      raise ArgumentError, "only 'true' may be passed as an argument"
    end

    if SetFileAttributesW(self.path.wincode, FILE_ATTRIBUTE_NORMAL) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  # Sets whether or not a file is online or not.  Setting this to false means
	# that the data of the file is not immediately available. This attribute
	# indicates that the file data has been physically moved to offline storage.
	# This attribute is used by Remote Storage, the hierarchical storage
	# management software.
  #
	# Applications should not arbitrarily change this attribute.
  #
  def offline=(bool)
    wide_path  = self.path.wincode
    attributes = GetFileAttributesW(wide_path)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    if bool
      attributes |= FILE_ATTRIBUTE_OFFLINE;
    else
      attributes &= ~FILE_ATTRIBUTE_OFFLINE;
    end

    if SetFileAttributesW(wide_path, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  # Sets the readonly attribute.  If set to true the the file or directory is
  # readonly. Applications can read the file but cannot write to it or delete
  # it. In the case of a directory, applications cannot delete it.
  #
  def readonly=(bool)
    wide_path  = self.path.wincode
    attributes = GetFileAttributesW(wide_path)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    if bool
      attributes |= FILE_ATTRIBUTE_READONLY;
    else
      attributes &= ~FILE_ATTRIBUTE_READONLY;
    end

    if SetFileAttributesW(wide_path, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  # Sets the file to a sparse (usually image) file.  Note that you cannot
  # remove the sparse property from a file.
  #
  def sparse=(bool)
    unless bool
      warn 'cannot remove sparse property from a file - operation ignored'
      return
    end

    bytes = FFI::MemoryPointer.new(:ulong)

    handle = CreateFileW(
      self.path.wincode,
      FILE_READ_DATA | FILE_WRITE_DATA,
      FILE_SHARE_READ | FILE_SHARE_WRITE,
      0,
      OPEN_EXISTING,
      FSCTL_SET_SPARSE(),
      0
    )

    if handle == INVALID_HANDLE_VALUE
      raise SystemCallError.new("CreateFile", FFI.errno)
    end

    begin
      bool = DeviceIoControl(
        handle,
        FSCTL_SET_SPARSE(),
        nil,
        0,
        nil,
        0,
        bytes,
        nil
      )

      unless bool == 0
        raise SystemCallError.new("DeviceIoControl", FFI.errno)
      end
    ensure
      CloseHandle(handle)
    end

    self
  end

  # Set whether or not the file is a system file.  A system file is a file
	# that is part of the operating system or is used exclusively by it.
  #
  def system=(bool)
    wide_path  = self.path.wincode
    attributes = GetFileAttributesW(wide_path)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    if bool
      attributes |= FILE_ATTRIBUTE_SYSTEM;
    else
      attributes &= ~FILE_ATTRIBUTE_SYSTEM;
    end

    if SetFileAttributesW(wide_path, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  # Sets whether or not the file is being used for temporary storage.
  #
  # File systems avoid writing data back to mass storage if sufficient cache
  # memory is available, because often the application deletes the temporary
  # file shortly after the handle is closed. In that case, the system can
  # entirely avoid writing the data. Otherwise, the data will be written
  # after the handle is closed.
  #
  def temporary=(bool)
    wide_path  = self.path.wincode
    attributes = GetFileAttributesW(wide_path)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    if bool
      attributes |= FILE_ATTRIBUTE_TEMPORARY;
    else
      attributes &= ~FILE_ATTRIBUTE_TEMPORARY;
    end

    if SetFileAttributesW(wide_path, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
  end

  private

  def self.check_for_attribute(file, attribute)
    attributes = GetFileAttributesW(file.wincode)

    if attributes == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new("GetFileAttributes", FFI.errno)
    end

    attributes & attribute > 0 ? true : false
  end
end
