package MT::LightEntrySaveRebuild;

use strict;
use warnings;

sub init_app { return 1; } # dummy

{
    no warnings qw( redefine );
    my $__rebuild_entry = \&MT::rebuild_entry;
    *MT::rebuild_entry = sub {
        my $caller = (caller 1)[3];
        my ( $mt, %args ) = @_;
        # 記事の保存後の再構築からは前後の記事の再構築を除く
        if ( $caller eq 'MT::CMS::Blog::rebuild_pages' && !$args{BuildDependencies} ) {
            delete $args{BuildDependencies};
            $args{BuildIndexes} = 1;
            $args{BuildArchives} = 1;
        }
        $__rebuild_entry->($mt, %args);
    };
}

sub entries_filter {
    my ( $ctx, $args, $cond ) = @_;
    my ( $from, $to ) = split(/\s*,\s*/, $args->{from_to_ts}, 2);
    MT::log($args->{from_to_ts});
    $ctx->{terms}->{authored_on} = [$from, $to];
    $ctx->{args}->{range_incl} ||= {};
    $ctx->{args}->{range_incl}->{authored_on} = 1;
    1;
}

1;
