package Acme::Samurai::Base;
use strict;
use warnings;
use Class::Trigger;
use Encode;
use File::ShareDir 'module_file';
use Text::MeCab;

use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw( text parts mecab_option ));

my $encoding = Encode::find_encoding( Text::MeCab::ENCODING );

sub parts_push {
    push @{ shift->parts }, @_;
}

sub parts_pop {
    pop @{ shift->parts };
}

sub mecab_new {
    my $self = shift;
    my $mecab = Text::MeCab->new({
        node_format => '%m,%H',
        unk_format  => '%m,%H',
        bos_format  => '%m,%H',
        eos_format  => '%m,%H',
        userdic     => module_file(ref $self, 'user.dic'),
        %{ $self->mecab_option || {} },
    });
}

sub call {
    my ($self, $method, @args) = @_;
    
    $self->call_trigger("pre.$method", @args);
    
    if ($self->can($method)) {
        $self->$method(@args);
    }
    
    $self->call_trigger("post.$method",  @args);
}

sub transform {
    my ($self, $text) = @_;
    
    $self->text($text || "");
    $self->parts([]);

    $self->call('prepare');
    
    my $mecab = $self->mecab_new;
    
    for my $part (split /(\s+)/, $self->text) {
        if ($part =~ /\s/) {
            $self->parts_push($part);
            next;
        }
        foreach (
            my $node = $mecab->parse( $encoding->encode($part) );
            $node;
            $node = $node->next
        ) {
            next if $node->stat_type =~ /BOS|EOS/;
            $self->call('node_filter', $node->decoded_node($mecab));
        }
    }
    
    $self->text(join "", @{ $self->parts });
    $self->call('finalize');
    $self->text;
}

sub node_filter {
    my ($self, $node) = @_;
    my $part = $node->features->{extra} || $node->surface;
     
    if (my $sub = $self->can($node->features->{pos} . '_rule') ) {
        my $ret = $sub->($self, $node);
        $part = $ret if defined $ret;
    }
    
    $self->parts_push($part);
}

sub Text::MeCab::Node::stat_type {
    {
        0 => 'MECAB_NOR_NODE', # normal
        1 => 'MECAB_UNK_NODE', # unknown
        2 => 'MECAB_BOS_NODE', # begin of sentence
        3 => 'MECAB_EOS_NODE', # end of sentence
    }->{
        shift->stat()
    };
}

our @dic_keys = qw(
    pos category1 category2 category3
    inflect inflect_type original yomi pronounse
    extra extra2 extra3
);

sub Text::MeCab::Node::decoded_node {
    my ($node, $mecab) = @_;
    
    my $format = $encoding->decode( $node->format($mecab) );
    my ($surface, @feature) = split /,/, $format;
    
    return Acme::Samurai::Base::Node->new({
        mecab     => $mecab,
        node      => $node,
        stat_type => $node->stat_type,
        surface   => $surface,
        feature   => join(",", @feature),
        features  => do {
            my %_tmp; @_tmp{ @dic_keys } = @feature;
            \%_tmp;
        },
    });
}


package Acme::Samurai::Base::Node;
use strict;
use Scalar::Util qw(weaken);

use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw( mecab node stat_type surface feature features ));

sub new {
    my $self = shift->SUPER::new(@_);
    weaken $self->{mecab};
    $self;
}

for my $sub (qw( next prev )) {
    no strict 'refs'; ## no critic
    *{__PACKAGE__ . "::${sub}_node"} = sub {
        my $self = shift;
        my $node = $self->node->$sub;
        return $node->decoded_node($self->mecab)
            if $node;
    };
}

1;
