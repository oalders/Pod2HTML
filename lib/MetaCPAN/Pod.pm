package MetaCPAN::Pod;

use Moose;

use Archive::Tar;
use CHI;
use Data::Dump qw( dump );
use Furl;
use JSON;
use MetaCPAN::Pod::XHTML;
use Modern::Perl;
use Pod::POM;
use Pod::POM::View::Pod;
use Try::Tiny;
use WWW::Mechanize::Cached;

has 'mech' => ( is => 'rw', lazy_build => 1 );
has 'cpan' => ( is => 'rw', isa => 'Str', default => "$ENV{HOME}/minicpan" );

sub convert {

    my $self = shift;
    my $name = shift;

    my $url = "http://api.beta.metacpan.org/pod/$name?content-type=text/x-pod";
    my $res = $self->mech->get( $url );
    
    if ( !$res->is_success ) {
        die $res->content . ' ' . $res->status_line;
    }

    my $parser = MetaCPAN::Pod::XHTML->new();

    $parser->index( 1 );
    $parser->html_header( '' );
    $parser->html_footer( '' );
    $parser->perldoc_url_prefix( '' );
    $parser->no_errata_section( 1 );
    #$parser->complain_stderr( 1 );

    my $html = "";
    $parser->output_string( \$html );
    $parser->parse_string_document( $res->content );

    die "no content" if !$parser->content_seen;

    return $html;

}

sub local_pod {
    
    my $self = shift;
    my ($author, $release, $path ) = @_;
    
    my $file = $self->author_dir( $author ) . '/' . $release . '.tar.gz';
    my $tar = undef;
    try { $tar = Archive::Tar->new( $file ) };

    if ( $tar->error ) {
        say "*" x 30 . ' tar error: ' . $tar->error;
        return 0;
    }
    
    my $content = $tar->get_content( $release . '/' . $path );
    my $parser = Pod::POM->new;
    my $pom    = $parser->parse_text( $content );
    return Pod::POM::View::Pod->print( $pom );
    
}

sub _build_mech {
    
    return WWW::Mechanize->new;
    my $folder = "$ENV{HOME}/tmp/pod2html";
    
    my $cache = CHI->new(
        driver   => 'File',
        root_dir => $folder,
    );
    
    my $mech = WWW::Mechanize::Cached->new( cache => $cache );
    $mech->agent( "iCPAN Pod2HTML Cacher" );
    return $mech;
    
}

sub author_dir {
    my $self = shift;
    my $pauseid = shift;
    my $dir = 'authors/id/'
      . sprintf( "%s/%s/%s",
                 substr( $pauseid, 0, 1 ),
                 substr( $pauseid, 0, 2 ), $pauseid );
    return $self->cpan . '/' . $dir;
}

1;
