# ----------------------------------------------------------------------
# Role ODG::Layout
#   Container Role for ArrayRef (colleciton) of 
#   ODG::Metadata objects
#
#   Slot:
#     _metadata_   ArrayRef[ODG::Metadata::Field]
#                  Collection::Array (metaclass)
#
#   Methods:
#     _metadata_ slot containing  ODG::Metadata objects
#     
#     One public accessor method for each field name 
#
#   Reserved methods: 
#       get, pop push, set, shift, unshift, insert,
#       clear, delete 
#       count
#
# ----------------------------------------------------------------------
package ODG::Layout;
    use Moose::Role;
    use MooseX::AttributeHelpers;
 

  # Slot: _metadata_
  #   This slot contains the ODG::Metadata objects.  When the
  #   slot is filed or changed it triggers an indexing so that the 
  #   we can use both name and index based accessors. 
    has _metadata_  => ( 
        metaclass   => 'Collection::Array' ,
        is          => 'rw' , 
        isa         => 'ArrayRef[ODG::Metadata]' ,
        default     => sub { [] } ,
        provides    => {
                            'get'       => 'get'    ,
                            'set'       => 'set'    ,
                            'pop'       => 'pop'    ,
                            'push'      => 'push'   ,
                            'shift'     => 'shift'  ,
                            'unshift'   => 'unshift',
                            'insert'    => 'insert' ,
                            'clear'     => 'clear'  ,
                            'delete'    => 'delete' ,
                            'count'     => 'count'  ,
                            'empty'     => 'empty'  ,
                            'find'      => 'find'   ,
                            'grep'      => 'grep'   ,
                            'map'       => 'map'    ,
                       } ,      

      # Trigger to index the _metadata_
      #     Permitting for $layout->field_name->index;
        trigger     => \&_create_index            , 

    );


  # Event: after _metadata_ change 
    after qw(_metadata_ set pop push shift unshift insert clear delete empty)
        => sub { 
                  $_[0]->_create_index;
                  $_[0]->_install_named_accessors;
           };


  # TODO:
  # Attribute: _index_name:
  #   Defines the name of the attribute used to as the index. 
  #   An attribute with this name is installed as an attribute in each
  #   ODG::Metadata object of the _metadata_ ArrayRef.
    has _index_name => (
        is      => 'ro'         ,
        isa     => 'Str'        ,
        default => 'index'    
    );



  # -------------------------------------------------------------------
  # Installed by MooseX::Attribute::Helper Collection::Array
  # Return the field names as found in the order of the _metadata_ slot
  # -------------------------------------------------------------------
    sub get_field_names { 
       
        return $_[0]->map( sub { $_->name } );
        
    }            

    
  # -------------------------------------------------------------------
  # SUBROUTINE: _create_index
  #   Mostly internal function for creating an index over the _metadata_
  #   Launched as a trigger by _metadata_ attribute.
  #
  # -------------------------------------------------------------------
    sub _create_index { 

      # Place a index attribute into each of the ODG::Metadata objects
      # in the Metadata field
        my $self = shift;
        my $i;
        $self->map( sub { $_->{ $self->_index_name } = $i++; } );

    } # END SUBROUTINE: _create_index



  # -------------------------------------------------------------------
  # SUBROUTINE: _install_named_accessors
  # -------------------------------------------------------------------
    sub _install_named_accessors {

        my $self = shift;

      # Create a method for each of the ODG::Metadata objects
        METHODS: foreach my $field ( @{$self->{_metadata_} } ) {
             
             $self->meta->add_method( $field->name => sub { return $field } );
                    
        }

    } # END SUB: _install_named_accessors 



  # -------------------------------------------------------------------
  # SUBROUTINE: BUILD
  #   - Create index
  #   - Install name based accessors to the metadata objects
  # -------------------------------------------------------------------
    sub BUILD {

        my ( $self, @args ) = @_;

        $self->_create_index;
        $self->_install_named_accessors;

    }



1; # Magic Number

__END__

=head1 NAME

ODG::Layout - Container role for managing metadata  

=head1 SYNOPSIS
  
  package My::Layout;
  use Moose;
    with 'ODG::Layout';

    ...install additional attributes, methods and logic...


  package main;

    my $layout = My::Layout->new( { 
        _metadata_ => [ 
            ODG::Metadata->new( { name => 'field_1'  ] ,
            ODG::Metadata->new( { name => 'field_2'  ] ,
        ]
    } );

  # Access the metadata.
    $layout->_metadata_->[0];
    $layout->get(0);
    $layout->field_1;

  ...


=head1 DESCRIPTION

ODG::Layout is an container role that defines a record layout.  
It containter L<ODG::Metadata> objects in an ArrayRef slot called
_metadata_.  When the slot is populated or changed, two things occur

=item * an b<index> attribute is added to each of the ODG::Metadata 
objects. The index attribute indicates the fields position within the 
layout.  

=item * named based accessors are installed for each of the 
ODG::Metadata objects

ODG::Layout is part of the ODG::Record distribution.  Here is an object
model

 ODG::Record
   |
   |- slot: _data_
   |
   |- slot: _layout_ (container for ODG::Metadata objects )
   |    |
   |    |- slot: _metadata_
   |
   |- slot: _metadata_  ( Refs ODG::Record::_layout_::_metadata_ ) 


=head1 SLOTS

=head2 _metadata_

ArrayRef[ODG::Metadata] with metaclass Collection::Array.  

Standard array methods ( push, pop, shift, ... ) operating on the 
derived class operate on this slot.  The slot can also be accessed with
the _metadata_ accessor.


=head1 ATTRIBUTES 

=head2 _index_name

Private.  Str.  What the attribute is called that is installed in each of the 
ODG::Metadata objects in _metadata_ slot.


=head1 PUBLIC METHODS

=head2 new

Constructor method.  Can optionally take a _metadata_ Attribute ArrayRef  
Installs name based accessors.  Additionally, installs an B<index> 
attribute into each of the ODG::Metadata objects in the _metadata_ 
slot.  This allows for accessing the position of the field by
name.

=head2 Accessor Methods

The _metadata_ can be accessed by name or by position. 

  # Name based.
  $layout->field_1;         # Return the ODG::Metadata object
  $layout->field_1->name;   # field_1
  $layout->field_1->index;  # Position in layout.
  
  # Position based
  $layout->_metadata_->[0];      # Returns the first field.
  $layout->get(0);               # Same using MooseX::AttributeHelpers


=head2 TODO: push, pop, shift, unshift, insert

This permits the layout defintiion to be built one field at a time
or cloned and modified.

See L<MooseX::AttributeHelpers>


=head2 TODO: clear, delete, empty

See L<MooseX::AttributeHelpers>


=head2 count

See L<MooseX::AttributeHelpers>


=head2 grep, map, find

See L<MooseX::AttributeHelpers>


=head1 PRIVATE METHODS

=head2 _create_index

Installs an b<index> attribute in each of each ODG::Metadata object in 
the _metadata_ slot.  The value of the index is the position in that 
slot.


=head2 _install_named_accessors

Installs named based accessors to ODG::Metadata objects in the 
_metadata_ slot.  One accessor is defined and named for each 
ODG::Metadata object.

=head1 TODO

=item * Private method return values

Should we provide a return value (T/F) for succes of the private methods.

=item * Enforce unique metadata names(?)


=head1 Extending

    package My::Layout;
    use Moose;
        with 'ODG::Layout';


=head1 SEE ALSO

L<ODG::Metadata>, L<ODG::Record>, L<Moose>, L<MooseX::AttributeHelpers>;

=head1 THANKS

Steven Little, author of L<Moose>

Members of moose@perl.org

=head1 AUTHOR

Christopher Brown, E<lt>http://www.opendatagroup,comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Open Data 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
