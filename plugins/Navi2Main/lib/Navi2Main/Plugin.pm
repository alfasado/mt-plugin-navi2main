package Navi2Main::Plugin;

use strict;
use File::Basename;

sub _build_page {
    my ( $cb, %args ) = @_;
    my $blog = $args{ blog };
    my $plugin = MT->component( 'Navi2Main' );
    if ( $plugin->get_config_value( 'nav2main_enable', 'blog:' . $blog->id ) ) {
        my $cfg_extensions = $plugin->get_config_value( 'nav2main_extensions', 'blog:' . $blog->id );
        my @extensions = split( /,/, $cfg_extensions );
        my $file = $args{ file };
        my $basename = File::Basename::basename( $file );
        my $extension;
        if ( $basename =~ /(\.[^.]+)\z/ ) {
            $extension = quotemeta( lc( $1 ) );
        } else {
            return 1;
        }
        if ( grep( /^$extension$/, @extensions ) ) {
            my $content = $args{ content };
            if ( $$content =~ m/<main.*?>/i ) {
                if ( $$content =~ m/<body.*?>/i ) {
                    my $link = $plugin->get_config_value( 'nav2main_link', 'blog:' . $blog->id );
                    my $anchor = $plugin->get_config_value( 'nav2main_anchor', 'blog:' . $blog->id );
                    $anchor = MT->translate_templatized(
                        "<__trans_section component=\"Navi2Main\">${anchor}</__trans_section>" );
                    $link = MT->translate_templatized(
                        "<__trans_section component=\"Navi2Main\">${link}</__trans_section>" );
                    $$content =~ s/(<body.*?>)/$1$link/i;
                    $$content =~ s/(<main.*?>)/$1$anchor/i;
                }
            }
        }
    }
    return 1;
}

sub _hdlr_transnav2main {
    my ( $ctx, $args, $cond ) = @_;
    my $build = $ctx->stash( 'builder' )->build( $ctx, $ctx->stash( 'tokens' ), $cond );
    $build = "<__trans_section component=\"Navi2Main\">${build}</__trans_section>";
    return MT->translate_templatized( $build );
}

1;