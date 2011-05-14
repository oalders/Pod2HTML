package MetaCPAN::Pod;

use Moose;

use CHI;
use Data::Dump qw( dump );
use Furl;
use JSON;
use MetaCPAN::Pod::XHTML;
use WWW::Mechanize::Cached;

has 'mech' => ( is => 'rw', lazy_build => 1 );

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

    my $file_res = $self->mech->get(
        sprintf(
            "http://api.beta.metacpan.org/source/%s/%s/%s",
            $module->{author}, $module->{release}, $module->{path}
        )
    );
    
    die $file_res->status_line unless $file_res->is_success;

    my $parser = MetaCPAN::Pod::XHTML->new();

    $parser->index( 1 );
    $parser->html_header( '' );
    $parser->html_footer( '' );
    $parser->perldoc_url_prefix( '' );
    $parser->no_errata_section( 1 );
    #$parser->complain_stderr( 1 );

    my $html = "";
    $parser->output_string( \$html );
    $parser->parse_string_document( $file_res->content );

    die "no content" if !$parser->content_seen;

    return $html;

}

sub _build_mech {
    
    my $cache = CHI->new(
        driver   => 'File',
        root_dir => '/tmp/pod2html'
    );
    
    return WWW::Mechanize::Cached->new( cache => $cache );   
    
}

1;
