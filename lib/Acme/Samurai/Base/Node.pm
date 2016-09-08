package Acme::Samurai::Base::Node;
use strict;
use warnings;
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
