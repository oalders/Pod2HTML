package Pod2HTML;

use Dancer ':syntax';

use MetaCPAN::Pod;
use Try::Tiny;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/pod/:name' => sub {
    my $pod = MetaCPAN::Pod->new;

    return $pod->convert( params->{name} );
};

get '/podpath/**' => sub {
    my @matches = splat;
    my $path = join( "/", @{ $matches[0] } );

    #return $path;
    my $pod = MetaCPAN::Pod->new;

    return $pod->convert($path);
};

my $pod = MetaCPAN::Pod->new( debug => 1 );

get '/from_cache/**' => sub {
    my @matches = splat;
    my $path = join( "/", @{ $matches[0] } );

    my $pod;
    try {
        $pod = $pod->convert($path);
    };
    return $pod if $pod;

    status 'not_found';
};

true;

=pod

plackup bin/app.pl

http://localhost:5000/pod/DBIx::Class

=cut
