package Pod2HTML;
use Dancer ':syntax';
use Data::Dump qw( dump );
use MetaCPAN::Pod;

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
    my $path = join( "/", @{$matches[0]} );
    #return $path;
    my $pod = MetaCPAN::Pod->new;

    return $pod->convert( $path );

};

true;

=pod

plackup bin/app.pl

http://localhost:5000/pod/DBIx::Class

=cut
