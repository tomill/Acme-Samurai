use inc::Module::Install;
name 'Acme-Samurai';
all_from 'lib/Acme/Samurai.pm';

build_requires 'Test::More';

requires 'Encode';
requires 'File::ShareDir';
requires 'Lingua::JA::Numbers';
requires 'Lingua::JA::Alphabet::Yomi';
requires 'Text::MeCab';
requires 'Unicode::Japanese';

use_test_base;
install_share;
auto_include;

WriteAll;
