# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl VDS-Record.t'

#########################
# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 18;
use Benchmark qw( :all :hireswallclock );
use Data::Dumper;

BEGIN { print "\nSection 1: Using Mods\n" };
BEGIN { use_ok('Moose') };
BEGIN { use_ok('ODG::Record') };
BEGIN { use_ok('ODG::Layout') };
BEGIN { use_ok('ODG::Metadata') };


#########################
print "\nSection 2: ODG::Metadata\n";

  # Test ODG::Metadata::Field
	my $metadata_1 = ODG::Metadata->new( { 
	   name => 'first_name' ,
	} );

	my $metadata_2 = ODG::Metadata->new( { 
	   name => 'last_name' ,
	} );

	my $metadata_3 = ODG::Metadata->new( { 
	   name => 'daughter' ,
	} );

	
	isa_ok( $metadata_1, "ODG::Metadata"  );

    can_ok( $metadata_1, qw( name ) );

    ok( $metadata_1->name eq 'first_name', 'Accessing via accessor' );
    ok( $metadata_1->{name} eq 'first_name', 'Accessing directly directly' );

    # is_faster( -5, sub { $metadata_1->name; }, sub { $metadata_1->{name}; } );
    print "\n";
    cmpthese( -0.2 , 
             { 
               'Accessor access'   =>  sub { $metadata_1->name }     ,
               'Direct access'     =>  sub { $metadata_1->{name} }   ,
             }    
    );


#########################
print "\nSection 3: ODG::Layout Role\n";

BEGIN {
    package ODG::Layout::Blank;
    use Moose;
    with 'ODG::Layout';
}

    my $layout = ODG::Layout::Blank->new( { 
            _metadata_ => 
            [ 
                $metadata_1 ,
                $metadata_2 ,
            ]
    } );

	isa_ok( $layout, 'ODG::Layout::Blank' ); 
    can_ok( $layout, 
            qw( 
                first_name last_name 
                _metadata_ _index_name
                get set push pop shift unshift insert
                clear delete empty
                map find grep
            ) );
            
    
    ok( $layout->_metadata_->[1]->{index} == 1, 
        "Metadata index" 
    );  
	
    ok( $layout->get(1)->name eq 'last_name' ,
        "MooseX::AttributeHelper access"
    );

    $layout->push( $metadata_3 );
    ok( $layout->get(2)->name eq 'daughter' ,
        "Push metadata field"
    );

###########################    
print "\nSection 4: ODG::Record\n";

  # Test ODG::Record
	my $record = ODG::Record->new( 
	    { 
	        _data_     => [ qw( fred flintstone pebbles) ] ,
	        _layout_   => $layout 
	    } 
    );
	
	isa_ok( $record, 'ODG::Record' );
    can_ok( $record, qw( first_name last_name daughter ) ); 

###########################    
print "\nSection 5: ODG::Record Setting and Getting\n";

# Test Accessors
ok( $record->last_name eq 'flintstone', 'Checking getter method' );

$record->last_name = 'rubble';    
ok( $record->last_name eq 'rubble', 'Checking lvalue setter method' );

$record->last_name( 'flintstone' );
ok( $record->last_name eq 'flintstone', 'Checking moose setter method' );

