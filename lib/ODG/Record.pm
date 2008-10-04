our $VERSION = '0.28';


# ----------------------------------------------------------------------
# CLASS: ODG::Record
#
# ----------------------------------------------------------------------
package ODG::Record;
use Moose;
use ODG::Layout;

  # has _type_     => ( is => 'rw', isa => 'Str' );

  # Attribute _metadata_
	has _layout_ => ( 
        is          => 'ro'          , 
        isa         => 'ODG::Layout' , 
        required    => 1             ,
    );

  # Attribute: _data
	has _data_   => ( 
	    isa         => 'ArrayRef'     , 
	    predicate   => '_has_data_'   ,
        default     => sub { [] }     ,
	);


# _data_
#   lvalue 
sub _data_ :lvalue {

    $_[0]->{_data_} = $_[1] if ( $_[1] );
    $_[0]->{_data_};

}


sub _metadata_ {
 
    $_[0]->_layout_->_metadata_;

}

  # Should setter (writer) be defined?
    # has _is_rw_  => ( is => 'rw', isa => 'Bool', default => 1 );

  # Should lvalue accessors be generated
    # has _has_lvalue_ => ( is => 'rw', isa => 'Bool', default => 1 );



    
# -----------------------------------------------------------------------
# FIELD ACCESSORS:
#    Create FIELD ACCESSORS for each _layout_ field.
#
#  We want to install instance methods and not class methods.  The class
#  method would cause these methods to be available to subsequent classes.
#  This would be undesirable because there might be two ODG::Record objects
#  in the same program.
#
#  The solution is to create the methods in a reblessed anonymous class.
#  Thanks to Paul Driver     
# -----------------------------------------------------------------------
sub BUILD {

    my ( $self, @args ) = @_;

  # ---------------------------------------------------------------
  # Foreach field identified in the metadata install a new lvalue 
  # accesor method.
  #
  # Note:
  #   - the offset '-1' to correct for Perl's indexing beginning
  #     at 1    
  # ---------------------------------------------------------------
    my $methods = {};
    METHODS: foreach my $field ( @{ $self->_layout_->_metadata_ } ) {
    
      # add_method:
        $self->meta->add_method( $field->name , sub :lvalue { 

              # Update the old value if used  second argument is passed 
                $self->{_data_}->[ $field->{ index } ] = $_[1] if ( $_[1] ); 
        
              # LVALUE return 
                $self->{_data_}->[ $field->{ index } ] ;
            }
        )

    } # END LOOP: METHODS 

    return( $self );

} # END SUB: BUILD


1;

__END__

=head1 NAME

ODG::Record - Perl extension for efficient and simple manipulation of row based records. 

=head1 SYNOPSIS

  use ODG::Record;
  my $record = ODG::Record->new( 
    { 
        _data_      => [1..25] ,
        _layout_  => ODG::Layout->new( .. )
    } 
  );

  # Data can then be accessed with the _data_ l-value accessor
  $record->_data_ = [ 26..50 ] ;   


=head1 DESCRIPTION

ODG::Record is an extensible class for efficiently and simply working
with row based records.  In short, this module provides two functions:
lvalue accesors to the record (for simplicity) and manipultation data
using an ArrayRefs for (for Performance).

lvalue accessors allow you to be terse with your code.

    $record->first_name = "Frank" 



head1 DETAILS

Data and layout information are separate concerns existing in seperate 
slots (_data_ and _layout_ ) within the ODG::Record object.

Since the _layout_ (i.e. metadata) does not change between records, 
separating the _data_ from _layout_ allows for greater efficient 
when processing row based records via object recycling.  Rather than
creating a new object for each record, the new data is
placed in the _data_ slot of an existing ODG::Record object.  Since
data is stored as an ArrayRef, this is a huge performance win.

ODG::Records require an L<ODG::Layout> object ( a _data_ ArrayRef is
optional ) for instantiation.  During object construction, name-based 
accessors are built for each recod field. By default, the accessors 
permit lvalue assignment. 


=head1 Object Model

  ODG::Record
    |
    |- slot: _data_
    |
    |- slot: _layout_ (container for ODG::Metadata objects )
    |    |
    |    |- slot: _metadata_
    |              
    |               
    |- slot: _metadata_ ( ref to ODG::Record::_layout_::_metadata_


=head1 DISCUSSION

=head2 Object Recycling

This module is designed for efficient streaming, i.e. accessing
only one record at a time.  By repopulating the data slot, i.e. 
recycling the record object, we do not incur the expensive of 
object instantiation for each record.  A huge win.

The downside is that the checking / validation in new object creation
might be lost. This may or not be acceptable depending on the situation.
Generally, when the records are well-defined and well-maintained,  
i.e. from a database, this is not an issue.  The data from one record 
to the next is fairly consistent.  

Encapsulation may also be lost.  Again, whether this is acceptable
depends on the situation.  There are several methods of object 
recycling ( as opposed to creating a new object).  They are: 

* using a standard accessor, 
* using an lvalue accessor (not officially supported
  by Moose -and- may break encapsulation.  ( Since this is Moose,  
  other Moose techniques can be used for validation, e.g. after method)
* direct access (breaks encapsulation).    


=head2 _data_ assignment performance

Here is a comparison of methods for placing new data in the record
object on an Intel(R) Xeon(TM) CPU 3.06GHz processor:

  Data has 5 elements: 1..5
                      Rate    new object moose accessor lvalue moose direct access
  new object        1268/s            --           -99%        -100%         -100%
  moose accessor  222222/s        17428%             --         -56%          -78%
  lvalue moose    500000/s        39337%           125%           --          -50%
  direct access  1000000/s        78775%           350%         100%            --


  Data has 25 elements: 1..25
                     Rate    new object moose accessor  lvalue moose direct access
  new object       1243/s            --           -99%         -100%         -100%
  moose accessor 166667/s        13308%             --          -37%          -54%
  lvalue moose   266667/s        21353%            60%            --          -27%
  direct access  363636/s        29155%           118%           36%            --
  
  
  new object      : ODG::Record->new( { _data_ => qw( [ 1..5] ) } );
  moose accessor  : $record->data( [ 1..5 ] ) 
  lvalue moose    : $record->data = [ 1..5 ] 
  direct access   : $record->_data_ = [ 1.5 ]
 
In real situations, there is probably not much of a difference between
the last three techniques, other bottleneck are likely to occur in the
the code such as I/O ability to return > 100k/s.
 
Note to self: What is the comparison to fully encapsulate inside-out objects.  Since
inside out objects uses references, we would expect them to behave 
similar to the moose accessors.
  

=head2 RecordSet

This idea can be extended to a RecordSet where multiple records 
are placed in the data slot.  This may be advantageous when 
batching is more appropriate.  Some reasons for this might be 
related to:

    * I/O constraints, especially latency provide for more 
      efficient batch processing 

    * Processing requires batch methods, look-backs e.g.  

    * Processing benefits from batch methods. i.e. records
      are sorted in order and one event needs to be triggered
      for all records of one type.  
 
An example of a RecordSet is demonstrated at:

    http://code2.0beta.co.uk/moose/svn/Moose/trunk/t/200_examples/008_record_set_iterator.t

This demonstration is not efficient since it seems that each 
record object requires instantiation (costly).  


=head2 Mixing of attributes, data and metadata

It is bad design to store object attributes, data and metadata
in the same construct, ie all as attributes.  A conflict arises when 
the field names of data conflict with the field names of the metadata.
These should be seperated.
  
The interface should be designed such that the user has
access principally to the data, via object->field syntax.  And it seems
sloppy to save the metadata with a alternate naming convention.  Some 
alternative might be:

A special slot for attributes and metadata.  These can be called 
_data_ and _layout_, e.g.

    $record->field_1

    sub field1 :lvalue {

            $_[0]->{_data_}->[ $_[0]->{_layout_}->{field1}->{pos} ]


Use $record->meta already exists, so this seems like a bad place to store
information.  

Absent a better methodology we stick to _name_.  



=head1 METHODS

=head2 new

Object constructor.  Creates and returns a ODG::Record object.  It
takes the following options. 


=over 4

_layout_  A ODG::Layout object containing the metadata for 
          record.  By convention, the first position has 
          an index of 0.

=back

=head2 _data_ 

L-value object accessor to the record data.  Data is stroed internally
as an array reference, so data  This is the very fast 
accessor for the _data_,    

  #  Getter
    $record->_data_               # Retrieve entire array ref
    $record->_data_->[ $index ]   # Get a specific field
  
  # Setter
    $record->_data_( [ .. ] )
    $record->_data_ = [ .. ]

    $record->_data_->[ $index ] = $value    


=head2 _layout_

READ-ONLY accessor to the layout object.  

=head2 _metadata_

Convenience method for accessing the _layout_->_metadata_ object.


=head2 EXPORT

None by default.


=head1 SEE ALSO

ODG::Metadata, Moose


=head1 THANKS

Steven Little, author of L<Moose>

Paul Driver for suggesting to place the accessor methods in the instance rather than the class.

Members of moose@perl.org.

=head1 AUTHOR

Christopher Brown, E<lt>http://www.opendatagroup,comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Open Data 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
