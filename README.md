This plugin provides Movable Type users with an assortment of miscellaneous tags that do not ship with Movable Type by default. These tags are:

# Modifiers

## `days_old`

A template tag modifier designed for use with date strings. User is intended to use a date string formatted as a timestamp e.g. %Y%m%d%H%M%S. The tag will then output the number of days since the date in question.

**Example**

    <ul>
    <mt:assets lastn="5">
    <li><$mt:AssetLabel$> (<$mt:AssetModifiedDate format="%Y%m%d%H%M%S" days_old="1"$> days old)</li>
    </mt:assets>
    </ul>

# Template Tags

## `<mt:FolderHasPages>`

A container tag that evaluates to true if the current folder in context contains any published pages.

**Example**

    <mt:Folders>
      <mt:FolderHasPages>
        <$mt:FolderLabel$> has pages.
      <mt:Else>
        <$mt:FolderLabel$> has NO pages. 
     </mt:FolderHasPages>
    </mt:Folders>

## `<mt:FolderHasIndex></mt:FolderHasIndex>`

A container tag that evaluates to true if the current folder in context contains a page that has a baename equal to 'index.'

**Example**

    <mt:Folders>
      <mt:FolderHasIndex>
        <$mt:FolderLabel$> has an index page.
      <mt:Else>
        <$mt:FolderLabel$> has NO index page. 
     </mt:FolderHasPages>
    </mt:Folders>

## `<$mt:AssetModifiedDate$>`

Outputs the modification date of the current asset in context. See the L<Date> tag for supported attributes.

# Requesting Template Tags of Your Own

Need a template tag for Movable Type? Ask us to write one for you. If it is quick and easy we will happily do so:

   http://help.endevver.com/

# About Endevver

We design and develop web sites, products and services with a focus on 
simplicity, sound design, ease of use and community. We specialize in 
Movable Type and offer numerous services and packages to help customers 
make the most of this powerful publishing platform.

http://www.endevver.com/

# Copyright

Copyright 2009-2010, Endevver, LLC. All rights reserved.

# License

This plugin is licensed under the same terms as Perl itself.