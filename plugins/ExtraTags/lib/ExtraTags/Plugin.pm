# Copyright (C) 2009 Byrne Reese.
package ExtraTags::Plugin;

use strict;
use MT::Util qw( ts2epoch );

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

    my $count = MT->model('page')->count( undef , $args);
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

###########################################################################

=head2 EntryModifiedDate
                                                                                                      
Outputs the modification date of the current entry in context.
See the L<Date> tag for supported attributes.
                                                                                                      
=for tags date

=cut

sub tag_asset_mod_date {
    my ($ctx, $args) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    $args->{ts} = $a->modified_on || $a->created_on;
    return MT::Template::Context::_hdlr_date($ctx, $args);
}

###########################################################################

=head2 days_old

A template tag modifier that transforms a date into an integer representing 
the number of days from now (the time the tag was processed) and the tag 
itself.
                                                                                                      
=for tags date

=cut

sub mod_days_old {
    my ($ts, $val, $ctx) = @_;
    my $epoch = ts2epoch(undef,$ts);
    my $now = time();
    my $diff = $now - $epoch;
    return int($diff / ( 60 * 60 * 24));
}

###########################################################################

=head2 AssetEntries

Iterates over the list of entries associated with the current asset in 
context.

B<Example:>

The following will output thumbnails for all of the assets embedded in all
of the entries on the system. Each thumbnail will be square and have a
max height/width of 100 pixels.

    <mt:Assets>
        <mt:AssetEntries>
            <$mt:EntryTitle$>
        </mt:AssetEntries>
    </mt:Assets>

=for assets entry

=cut

sub tag_asset_entries {
    my ($ctx, $args, $cond) = @_;
    my $obj = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    
    my $place_class = MT->model('objectasset');
    my @places = $place_class->load({
        blog_id => $obj->blog_id || 0,
        asset_id => $obj->parent ? $obj->parent : $obj->id
    });
    my $res = '';
    my $count = 0;
    my $vars = $ctx->{__stash}{vars};
    foreach my $place (@places) {
        my $entry_class = MT->model($place->object_ds) or next;
        next unless $entry_class->isa('MT::Entry');
        my $entry = $entry_class->load($place->object_id)
            or next;
        local $vars->{'__first__'}   = ($count == 0);
        local $vars->{'__last__'}    = ($count == $#places);
        local $vars->{'__odd__'} = ($count % 2 ) == 1;
        local $vars->{'__even__'} = ($count % 2 ) == 0;
        local $vars->{'__counter__'} = ++$count;
        local $ctx->{__stash}{'entry'} = $entry;
        defined(my $out = $builder->build($ctx, $tokens, $cond))
            or return $ctx->error($builder->errstr);
        $res .= $out;
    }
    return _hdlr_pass_tokens_else(@_) unless $res eq '';
    return $out;
}

###########################################################################

=head2 IsTopLevelFolder

Evaluates contained template tags if the current folder in context is the 
top most, root level folder on the system.

This tag is important to differentiate between the tag "HasParentFolder"
which returns false if the current folder in context is at the root level
OR the first level.

B<Example:>

    <mt:Pages>
        <mt:PageFolder>
            <mt:IfTopLevelFolder>
              <$mt:PageTitle$> is in the root folder.
            </mt:IfTopLevelFolder>
        </mt:PageFolder>
    </mt:Pages>

=for assets entry

=cut

sub tag_is_top_level {
    my ($ctx, $args) = @_;
    # Get the current category
    defined (my $cat = MT::Template::Context::_get_category_context($ctx))
        or return $ctx->error($ctx->errstr);
    return $ctx->error("Could not find a category in current context.")
        if ($cat eq '');
    return $cat->parent == 0 ? 1 : 0;
}

1;
