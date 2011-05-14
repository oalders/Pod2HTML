use Test::More; 
use strict;
use warnings;

use MetaCPAN::Pod;

new_ok('MetaCPAN::Pod');

my $pod = MetaCPAN::Pod->new;
    
diag( $pod->convert('DBIx::Class') );

done_testing();
