package Acme::Samurai;
use strict;
use warnings;
our $VERSION = '0.02';

use utf8;
use base 'Acme::Samurai::Base';
use Lingua::JA::Alphabet::Yomi;
use Lingua::JA::Numbers;
use Unicode::Japanese;

sub gozaru {
    shift->new->transform(@_);
}

sub prepare {
    my $self = shift;
    my $text = Unicode::Japanese->new($self->text);
    $text->z2hNum->h2zAlpha;
    $self->text($text->getu);
}

sub finalize {
    my $self = shift;
    $self->{text} =~ s/(?:ておりまする|ていまする?)\b/ており候/g;
    $self->{text} =~ s/(?:どうも)?かたじけない(?:ございま(?:する|す|した))?/かたじけない/g;
}

sub 名詞_rule {
    my ($self, $node) = @_;
    
    if ($node->features->{extra}) {
        return $node->features->{extra};
    }
    elsif ($node->features->{category1} eq '数' and
        $node->surface =~ /^[0-9]+$/) {
        if ($node->prev_node->surface =~ /[.．]/) {
            my $r = "";
            $r .= Lingua::JA::Numbers::num2ja($_) for split //, $node->surface;
            return $r;
        } else {
            return Lingua::JA::Numbers::num2ja($node->surface);
        }
    }
    elsif ($node->features->{category1} eq '数') {
        my $text = $node->surface;
        $text =~ tr{〇一二三四五六七八九十百万}
                   {零壱弐参四伍六七八九拾佰萬};
        return $text;
    }
    elsif ($node->surface =~ /^\p{Latin}+$/) {
        my $text = $node->features->{pronounse} || $node->surface;
        $text = Lingua::JA::Alphabet::Yomi->alphabet2yomi($text);
        $text = Unicode::Japanese->new($text)->kata2hira->getu;
        return $text;
    }
    return;
}

*記号_rule = \&名詞_rule;

sub 動詞_rule {
    my ($self, $node) = @_;
    if ($node->surface =~ /(.+?)(じる)$/) {
        return "$1ずる";
    }
    if ($node->surface eq 'い' and
        $node->feature =~ /^動詞,非自立,[*],[*],一段,連用形/ and
        $node->next_node->features->{pos} !~ /詞/) {
        return "おっ" if $node->next_node->features->{original} eq 'た';
        return "おり" if $node->next_node->features->{original} eq 'ます';
    }
    return;
}

sub 形容詞_rule {
    my ($self, $node) = @_;
    if ($node->surface =~ /^(.+?)(しい|しく)$/) {
        my $a = $1;
        my $b = { 'しい' => 'しき', 'しく' => 'しゅう' }->{$2};
        return "$a$b";
    }
    return;
}

sub 助詞_rule {
    my ($self, $node) = @_;
    if ($node->feature eq '助詞,終助詞,*,*,*,*,の,の,の,のか' and
        $node->prev_node->surface eq 'な') {
        $self->parts_pop;
        return "なの";
    }
    elsif ($node->surface eq 'ので' and
        $node->prev_node->surface eq 'な') {
        $self->parts_pop;
        return "ゆえに";
    }
    elsif ($node->surface eq 'ね' and
        $node->prev_node->surface eq 'の') {
        return "だな";
    }
    return;
}

sub 助動詞_rule {
    my ($self, $node) = @_;
    if ($node->surface eq 'ない') {
        if ($node->prev_node->surface eq 'し' and
            $node->next_node->surface and
            $node->next_node->features->{pos} !~ /詞/) {
            $self->parts_pop;
            return "せぬ";
        }
        if ($node->prev_node->surface ne 'し' and
            $node->prev_node->features->{inflect_type} eq '未然形') {
            return "ぬ";
        }
    }
    elsif ($node->surface eq 'なけれ') {
        if ($node->prev_node->surface eq 'し') {
            $self->parts_pop;
            return "せね";
        }
    }
    return;
}

sub 感動詞_rule {
    my ($self, $node) = @_;
    if ($node->next_node->features->{pos} !~ /詞/) {
        my $text = $node->features->{extra} || $node->surface;
        return $text . "でござる";
    }
    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

Acme::Samurai - Samurai de gozaru

=head1 SYNOPSIS

  use Acme::Samurai;
  use utf8;

  Acme::Samurai->gozaru("私、侍です"); # それがし、侍でござる

=head1 DESCRIPTION

Acme::Samurai translates present-day Japanese to 時代劇
(L<http://en.wikipedia.org/wiki/Jidaigeki>) speak.

=head1 METHODS

=over 4

=item gozaru( $text )

=back

=head1 SEE ALSO

Sample form: L<http://samurai.koneta.org/>

L<Text::MeCab>

L<http://coderepos.org/share/browser/lang/perl/Acme-Samurai> (repository)

=head1 AUTHOR

Naoki Tomita E<lt>tomita@cpan.orgE<gt>

Special thanks to kazina, this module started from てきすたー dictionary.
L<http://kazina.com/texter/index.html>

and Hiroko Nagashima, Shin Yamauchi for addition samurai vocabulary.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
