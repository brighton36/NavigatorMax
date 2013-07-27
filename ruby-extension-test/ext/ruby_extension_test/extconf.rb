# File: extconf.rb
require 'mkmf'

extension_name = 'ruby_extension_test'

HEADER_DIRS = [ '/Library/Frameworks/Phidget21.framework/Headers' ]

find_header 'phidget21.h', *HEADER_DIRS
have_framework 'Phidget21' 

dir_config extension_name
create_makefile extension_name
