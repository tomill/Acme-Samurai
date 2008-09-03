use inc::Module::Install;

name 'Acme-Samurai';
all_from 'lib/Acme/Samurai.pm';

requires 'Class::Accessor::Fast';
requires 'Class::Trigger';
requires 'Encode';
requires 'File::ShareDir';
requires 'Lingua::JA::Numbers';
requires 'Lingua::JA::Alphabet::Yomi';
requires 'Text::MeCab';
requires 'Unicode::Japanese';

test_requires 'Test::More';
test_requires 'Test::Base';

use_test_base;
install_share qw( module Acme::Samurai ), 'share';
auto_include;

WriteAll;
