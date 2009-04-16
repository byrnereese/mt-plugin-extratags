# Copyright (C) 2009 Byrne Reese.
package ExtraTags::Plugin;

use strict;

###########################################################################

=head2 mt:FolderHasPages

This template tag is a conditional block tag that is evaluated if the 
current folder in context has any pages within it.

B<Attributes:>

None.

=for tags plugin, block, container, conditional, folder, pages

=cut
sub tag_has_pages {
    my ($ctx, $args, $cond) = @_;
    my $c = $ctx->stash('category')
        or return _no_folder_error($ctx->stash('tag'));
    require MT::Page;
    require MT::Placement;
    my $clause = ' = entry_entry_id';
    my %args = (
        join => MT::Placement->join_on( category_id => $c->id, { entry_id => \$clause }),
        );

    my $count = MT::Page->count( undef , $args);
    return $count > 0;
}

###########################################################################

=head2 mt:FolderHasIndex

This template tag is a conditional block tag that is evaluated if the 
current folder in context has a page with a basename of 'index', or in
laymans terms: an index page (e.g. index.php or index.html).

B<Attributes:>

None.

=for tags plugin, block, container, conditional, folder, pages

=cut
sub tag_has_index {
    my ($ctx, $args, $cond) = @_;
    my $c = $ctx->stash('category')
        or return _no_folder_error($ctx,$ctx->stash('tag'));
    require MT::Placement;
    my $clause = ' = entry_id';
    my %args = (
		'join' => MT::Placement->join_on( 'entry_id' , { 
		      entry_id => \$clause,
		      category_id => $c->id,
		   }),
		);
    require MT::Page;
    my @pages = MT::Page->load({ basename => 'index' }, \%args);
    return $#pages > -1;
}

sub _no_folder_error {
    my ($ctx) = @_;
    my $tag_name = $ctx->stash('tag');
    $tag_name = 'mt' . $tag_name unless $tag_name =~ m/^MT/i;
    return $ctx->error(MT->translate(
        "You used an '[_1]' tag outside of the context of a folder; " .
        "perhaps you mistakenly placed it outside of an 'MTFolders' " .
        "container?", $tag_name
    ));
}

1;