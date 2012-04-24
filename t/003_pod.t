use strict;
use warnings;

use Test::More;
use MetaCPAN::Pod;

new_ok( 'MetaCPAN::Pod' );

my $mcp = MetaCPAN::Pod->new;

#diag( $pod->convert('Plack::Middleware::HTMLify') );

my $author  = 'OALDERS';
my $release = 'HTML-Restrict-1.0.3';
my $path    = 'lib/HTML/Restrict.pm';

is( $mcp->author_dir( 'OALDERS' ),
    "/home/wunderadmin/minicpan/authors/id/O/OA/OALDERS",
    "author dir"
);
ok( -e $mcp->author_dir( $author ), "author dir exists" );
my $pod = $mcp->local_pod( $author, $release, $path );
ok( $pod, "got pod for $release" );

my $tar = $mcp->build_tar( $author, $release );
isa_ok( $tar, "Archive::Tar", "got tar object" );

my $pod_from_tar = $mcp->pod_from_tar( $release, $path );
ok( $pod_from_tar, "pod_from_tar" );

my $url_path = join "/", $author, $release, $path;

my $metacpan_url = $mcp->metacpan_url( $url_path );
is( $metacpan_url,
    'http://api.beta.metacpan.org/pod/OALDERS/HTML-Restrict-1.0.3/lib/HTML/Restrict.pm?content-type=text/x-pod',
    'correct url on MetaCPAN'
);

my $pod_from_metacpan = $mcp->convert( $url_path );
ok( $pod_from_metacpan, "can find pod on MetaCPAN" );
diag( $mcp->parse_pod( $pod ) );
done_testing();
