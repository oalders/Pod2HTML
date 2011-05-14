package Pod2HTML;
use Dancer ':syntax';

use MetaCPAN::Pod;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/pod/:name' => sub {

    my $pod = MetaCPAN::Pod->new;
    
    return $pod->convert( params->{name} ); 

};

true;

=pod

plackup bin/app.pl

http://localhost:5000/pod/DBIx::Class

=cut
