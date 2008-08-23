use Test::Dependencies
    exclude => [qw( Test::Dependencies Acme::Samurai )],
    style => 'light';

ok_dependencies();
