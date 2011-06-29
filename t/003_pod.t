use Test::More; 
use strict;
use warnings;

use MetaCPAN::Pod;

new_ok('MetaCPAN::Pod');

my $pod = MetaCPAN::Pod->new;
    
#diag( $pod->convert('Plack::Middleware::HTMLify') );

ok( -e $pod->author_dir("OALDERS") );

my $pod = $pod->local_pod( "OALDERS", "HTML-Restrict-0.06", "lib/HTML/Restrict.pm" );
diag ( $pod );

done_testing();
