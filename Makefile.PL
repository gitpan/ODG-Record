use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'ODG::Record',
    VERSION_FROM      => 'lib/ODG/Record.pm', # finds $VERSION
    PREREQ_PM         => { Moose => 0.40 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/ODG/Record.pm', # retrieve abstract from module
       AUTHOR         => 'Christopher Brown <cbrown@hungrygoat.org>') : ()),
);
