# NAME

Acme::Samurai - Samurai de gozaru

# SYNOPSIS

    use Acme::Samurai;
    use utf8;

    Acme::Samurai->gozaru("私、侍です"); # それがし、侍でござる

# DESCRIPTION

Acme::Samurai translates present-day Japanese to 時代劇
([http://en.wikipedia.org/wiki/Jidaigeki](http://en.wikipedia.org/wiki/Jidaigeki)) speak.

# METHODS

- gozaru( $text )

# SEE ALSO

Test form: [http://samurai.koneta.org/](http://samurai.koneta.org/)

[Text::MeCab](http://search.cpan.org/perldoc?Text::MeCab)

[http://coderepos.org/share/browser/lang/perl/Acme-Samurai](http://coderepos.org/share/browser/lang/perl/Acme-Samurai) (repository)

# AUTHOR

Naoki Tomita <tomita@cpan.org>

Special thanks to kazina, this module started from てきすたー dictionary.
[http://kazina.com/texter/index.html](http://kazina.com/texter/index.html)

and Hiroko Nagashima, Shin Yamauchi for addition samurai vocabulary.

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
