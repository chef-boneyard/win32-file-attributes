require File.join(File.dirname(__FILE__), 'windows', 'constants')
require File.join(File.dirname(__FILE__), 'windows', 'structs')
require File.join(File.dirname(__FILE__), 'windows', 'functions')

class File
  include Windows::File::Constants
  include Windows::File::Functions
  extend Windows::File::Structs
  extend Windows::File::Functions

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

    if SetFileAttributesW(file, attributes) == 0
      raise SystemCallError.new("SetFileAttributes", FFI.errno)
    end

    self
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
end
