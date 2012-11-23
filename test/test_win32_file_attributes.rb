#############################################################################
# test_win32_file_attributes.rb
#
# Test case for the attribute related methods of win32-file. You should run
# this via the 'rake test' or 'rake test_attributes' task.
#############################################################################
require 'ffi'
require 'test-unit'
require 'win32/file/attributes'

class TC_Win32_File_Attributes < Test::Unit::TestCase
  extend FFI::Library
  ffi_lib :kernel32

  attach_function :GetFileAttributes, :GetFileAttributesA, [:string], :ulong
  attach_function :SetFileAttributes, :SetFileAttributesA, [:string, :ulong], :ulong

  def self.startup
    Dir.chdir(File.dirname(File.expand_path(File.basename(__FILE__))))
    @@file = File.join(Dir.pwd, 'test_file.txt')
    File.open(@@file, 'w'){ |fh| fh.puts "This is a test." }
  end

  def setup
    @fh   = File.open(@@file)
    @attr = GetFileAttributes(@@file)
  end

  test "version is set to expected value" do
    assert_equal('0.7.0', File::WIN32_FILE_VERSION)
  end

  test "temporary? singleton method basic functionality" do
    assert_respond_to(File, :temporary?)
    assert_nothing_raised{ File.temporary?(@@file) }
  end

  test "temporary? singleton method returns expected value" do
    assert_false(File.temporary?(@@file))
  end

  test "temporary? singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.temporary? }
    assert_raises(ArgumentError){ File.temporary?(@@file, 'foo') }
  end

  test "temporary? instance method basic functionality" do
    assert_respond_to(@fh, :temporary=)
    assert_nothing_raised{ @fh.temporary = true }
  end

  test "temporary? instance method works as expected" do
    assert_false(File.temporary?(@@file))
    @fh.temporary = true
    assert_true(File.temporary?(@@file))
  end

  test "system? singleton method basic functionality" do
    assert_respond_to(File, :system?)
    assert_nothing_raised{ File.system?(@@file) }
  end

  test "system? singleton method returns the expected value" do
    assert_false(File.system?(@@file))
  end

  test "system singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.system? }
    assert_raises(ArgumentError){ File.system?(@@file, 'foo') }
  end

  test "system instance method basic functionality" do
    assert_respond_to(@fh, :system=)
    assert_nothing_raised{ @fh.system = true }
  end

  test "system instance method works as expected" do
    assert_false(File.system?(@@file))
    @fh.system = true
    assert_true(File.system?(@@file))
  end

  test "sparse? singleton method basic functionality" do
    assert_respond_to(File, :sparse?)
    assert_nothing_raised{ File.sparse?(@@file) }
  end

  test "sparse? singleton method returns expected value" do
    assert_false(File.sparse?(@@file))
  end

  test "sparse? singleton method requires one argument" do
    assert_raises(ArgumentError){ File.sparse? }
    assert_raises(ArgumentError){ File.sparse?(@@file, 'foo') }
  end

  # I don't actually test true assignment here since making a file a
  # sparse file can't be undone.
  test "sparse? instance method basic functionality" do
    assert_respond_to(@fh, :sparse=)
    assert_nothing_raised{ @fh.sparse= false }
  end

  test "reparse_point? singleton method basic functionality" do
    assert_respond_to(File, :reparse_point?)
    assert_nothing_raised{ File.reparse_point?(@@file) }
  end

  test "reparse_point? singleton method returns the expected value" do
    assert_false(File.reparse_point?(@@file))
  end

  test "reparse_point? singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.reparse_point? }
    assert_raises(ArgumentError){ File.reparse_point?(@@file, 'foo') }
  end

  test "readonly? singleton method basic functionality" do
    assert_respond_to(File, :readonly?)
    assert_nothing_raised{ File.readonly?(@@file) }
  end

  test "readonly? singleton method returns expected result" do
    assert_false(File.readonly?(@@file))
  end

  test "readonly? singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.read_only? }
    assert_raises(ArgumentError){ File.read_only?(@@file, 'foo') }
  end

  test "read_only? is an alias for readonly?" do
    assert_respond_to(File, :read_only?)
    assert_alias_method(File, :read_only?, :readonly?)
  end

  test "readonly? instance method basic functionality" do
    assert_respond_to(@fh, :readonly=)
    assert_nothing_raised{ @fh.readonly = true }
  end

  test "readonly? instance method returns expected value" do
    assert_false(File.readonly?(@@file))
    @fh.readonly = true
    assert_true(File.readonly?(@@file))
  end

  test "offline? singleton method basic functionality" do
    assert_respond_to(File, :offline?)
    assert_nothing_raised{ File.offline?(@@file) }
  end

  test "offline? singleton method returns expected result" do
    assert_false(File.offline?(@@file))
  end

  test "offline? singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.offline? }
    assert_raises(ArgumentError){ File.offline?(@@file, 'foo') }
  end

  test "offline? instance method basic functionality" do
    assert_respond_to(@fh, :offline=)
    assert_nothing_raised{ @fh.offline =  true }
  end

  test "offline? instance method returns expected value" do
    assert_false(File.offline?(@@file))
    @fh.offline = true
    assert_true(File.offline?(@@file))
  end

  test "normal? singleton method basic functionality" do
    assert_respond_to(File, :normal?)
    assert_nothing_raised{ File.normal?(@@file) }
  end

  test "normal? singleton method returns expected results" do
    assert_false(File.normal?(@@file))
    @fh.normal = true
    assert_true(File.normal?(@@file))
  end

  test "normal? singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.normal? }
    assert_raises(ArgumentError){ File.normal?(@@file, 'foo') }
  end

  test "normal? instance method basic functionality" do
    assert_respond_to(@fh, :normal=)
    assert_nothing_raised{ @fh.normal = true }
  end

  test "normal? instance method setter does not accept false" do
    assert_raises(ArgumentError){ @fh.normal = false }
  end

  test "hidden? singleton method basic functionality" do
    assert_respond_to(File, :hidden?)
    assert_nothing_raised{ File.hidden?(@@file) }
  end

  test "hidden? singleton method returns the expected result" do
    assert_false(File.hidden?(@@file))
    @fh.hidden = true
    assert_true(File.hidden?(@@file))
  end

  test "hidden? singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.hidden? }
    assert_raises(ArgumentError){ File.hidden?(@@file, 'foo') }
  end

  test "hidden? instance method basic functionality" do
    assert_respond_to(@fh, :hidden=)
    assert_nothing_raised{ @fh.hidden = true }
  end

  test "encrypted? singleton method basic functionality" do
    assert_respond_to(File, :encrypted?)
    assert_nothing_raised{ File.encrypted?(@@file) }
  end

  test "encrypted? singleton method returns the expected result" do
    assert_false(File.encrypted?(@@file))
  end

  test "encrypted? singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.encrypted? }
    assert_raises(ArgumentError){ File.encrypted?(@@file, 'foo') }
  end

  test "indexed? singleton method basic functionality" do
    assert_respond_to(File, :indexed?)
    assert_nothing_raised{ File.indexed?(@@file) }
  end

  test "indexed? singleton method returns the expected results" do
    assert_true(File.indexed?(@@file))
    @fh.indexed = false
    assert_false(File.indexed?(@@file))
  end

  test "content_indexed? is an alias for indexed?" do
    assert_respond_to(File, :content_indexed?)
    assert_alias_method(File, :content_indexed?, :indexed?)
  end

  test "indexed? singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.indexed? }
    assert_raises(ArgumentError){ File.indexed?(@@file, 'foo') }
  end

  test "indexed? instance method basic functionality" do
    assert_respond_to(@fh, :indexed=)
    assert_nothing_raised{ @fh.indexed = true }
  end

  test "indexed? instance method returns expected method" do
    assert_true(File.indexed?(@@file))
    @fh.indexed = false
    assert_false(File.indexed?(@@file))
  end

  test "compressed? singleton method basic functionality" do
    assert_respond_to(File, :compressed?)
    assert_nothing_raised{ File.compressed?(@@file) }
  end

  test "compressed? singleton method returns the expected result" do
    assert_false(File.compressed?(@@file))
  end

  test "compressed instance method setter basic functionality" do
    assert_respond_to(@fh, :compressed=)
    assert_false(File.compressed?(@@file))
  end

  test "compressed? singleton method requires a single argument" do
    assert_raises(ArgumentError){ File.compressed? }
    assert_raises(ArgumentError){ File.compressed?(@@file, 'foo') }
  end

  # We have to explicitly reset the compressed attribute to false as
  # the last of these assertions.

  test "compressed instance method setter works as expected" do
    assert_nothing_raised{ @fh.compressed = true }
    assert_true(File.compressed?(@@file))
    assert_nothing_raised{ @fh.compressed = false }
    assert_false(File.compressed?(@@file))
  end
=begin

   def test_archive
      assert_respond_to(File, :archive?)
      assert_nothing_raised{ File.archive?(@@file) }
      assert_equal(true, File.archive?(@@file))
   end

   def test_archive_instance
      assert_respond_to(@fh, :archive=)
      assert_nothing_raised{ @fh.archive = false }
      assert_equal(false, File.archive?(@@file))
   end

   def test_archive_expected_errors
      assert_raises(ArgumentError){ File.archive? }
      assert_raises(ArgumentError){ File.archive?(@@file, 'foo') }
   end

   def test_attributes
      assert_respond_to(File, :attributes)
      assert_kind_of(Array, File.attributes(@@file))
      assert_equal(['archive', 'indexed'], File.attributes(@@file))
   end

   def test_set_attributes
      assert_respond_to(File, :set_attributes)
      assert_nothing_raised{ File.set_attributes(@@file, File::HIDDEN) }
      assert(File.hidden?(@@file))
   end

   def test_set_attr_alias
      assert_respond_to(File, :set_attr)
      assert(File.method(:set_attr) == File.method(:set_attributes))
   end

   def test_remove_attributes
      assert_respond_to(File, :remove_attributes)
      assert_nothing_raised{ File.remove_attributes(@@file, File::ARCHIVE) }
      assert_equal(false, File.archive?(@@file))
   end

   def test_unset_attr_alias
      assert_respond_to(File, :unset_attr)
      assert(File.method(:unset_attr) == File.method(:remove_attributes))
   end
=end

  def teardown
    SetFileAttributes(@@file, @attr)
    @fh.close
  end

  def self.shutdown
    File.delete(@@file)
    @@file = nil
  end
end
