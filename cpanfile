requires 'perl', '5.010001';

requires 'Text::Mecabist';

requires 'Encode';
requires 'File::ShareDir';
requires 'Lingua::JA::Alphabet::Yomi';
requires 'Lingua::JA::Numbers';
requires 'Unicode::Japanese';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.36';
};

on test => sub {
    requires 'Test::More';
    requires 'Test::Base';
    requires 'Encode';
};
