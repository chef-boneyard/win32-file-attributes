#############################################################################
# test_win32_file_attribute_constants.rb
#
# Test cases for the "shortcut" constants for File attributes.
#############################################################################
require 'test-unit'
require 'win32/file/attributes'

class TC_Win32_File_Attribute_Constants < Test::Unit::TestCase
  test "shortcut constants are defined" do
    assert_not_nil(File::ARCHIVE)
    assert_not_nil(File::HIDDEN)
    assert_not_nil(File::NORMAL)
    assert_not_nil(File::INDEXED)
    assert_not_nil(File::OFFLINE)
    assert_not_nil(File::READONLY)
    assert_not_nil(File::SYSTEM)
    assert_not_nil(File::TEMPORARY)
    assert_not_nil(File::CONTENT_INDEXED)
  end

  test "CONTENT_INDEXED is identical to INDEXED" do
    assert_equal(File::INDEXED, File::CONTENT_INDEXED)
  end
end
