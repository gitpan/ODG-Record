# ----------------------------------------------------------------------
# CLASS: ODG::Metadata
#   Defines the metadata of a field
#  
#   name        field name
#   index       ordinal position of field in record
#   type        the type of value
#
# ----------------------------------------------------------------------
package ODG::Metadata;
use Moose;

    has 'name'        => ( is => 'rw', isa => 'Str', required => 1  );
    # has 'index'       => ( is => 'rw', isa => 'Int', required => 1 );
    # has 'type'        => ( is => 'rw', isa => 'Str' );

1; # Magic Number


__END__

=head1 NAME

ODG::Metadata - Extensible class for defining metadata fields

=head1 SYNOPSIS

    use ODG::Metadata

    my $first_name = ODG::Metadata->new( 
        { name => 'first_name' } 
    );

=head1 DESCRIPTION

The ODG::Metadata class is used to hold all of the metadata for a 
single field.  It does not define the position of fields use 
L<ODG::Layout> for that.  ODG::Metadata simply describes the field
metadata.

When used with L<ODG::Layout> and L<ODG::Record>, this class allows
name based accessors to data and efficient processing of row based
data.


=head1 METHODS

=head2 new

    my $metadata = ODG::Metadata->new( 
        {
           name    => 'field_1' ,
        } 
    );

Creates a new ODG::Metadata object.  Takes a hashref of object 
attributes.  There is only one required attributes:

    name:   a unqiue name for the field 
    

=head1 Extending

    package My::Class;
    use Moose;
    extends ODG::Metadata;

    ...


=head1 SEE ALSO 
  
L<ODG::Metadta>, L<ODG::Record>, L<Moose>   

=head1 AUTHOR

Christopher BRown, E<lt>http://www.opendatagroup.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Open Data 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


