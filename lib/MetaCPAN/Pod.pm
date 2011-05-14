package MetaCPAN::Pod;

use Moose;
use Data::Dump qw( dump );
use Furl;
use JSON;
use MetaCPAN::Pod::XHTML;

sub convert {

    my $self = shift;
    my $name = shift;

    my $furl = Furl->new(
        agent   => "Pod2HTML",
        timeout => 10,
    );

    my $res = $furl->get( "http://api.beta.metacpan.org/module/$name" );
    die $res->status_line unless $res->is_success;

    my $module = from_json( $res->content );
    my $pod = $module->{pod};
    my $parser = Pod::Simple::XHTML->new();

    $parser->index( 1 );
    $parser->html_header( '' );
    $parser->html_footer( '' );
    $parser->perldoc_url_prefix( '' );
    $parser->no_errata_section( 1 );
    $parser->complain_stderr( 1 );

    my $html = "";
    $parser->output_string( \$html );
    $parser->parse_string_document( \$pod );
    
    die "no content" if !$parser->content_seen;
    
    return dump( $html );

}

1;
