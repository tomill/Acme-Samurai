requires 'Class::Accessor::Fast';
requires 'Class::Trigger';
requires 'Encode';
requires 'File::ShareDir';
requires 'Filter::Util::Call';
requires 'Lingua::JA::Alphabet::Yomi';
requires 'Lingua::JA::Numbers';
requires 'Text::MeCab';
requires 'Unicode::Japanese';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.36';
};

on test => sub {
    requires 'Test::More';
    requires 'Test::Base';
    requires 'Encode';
};
