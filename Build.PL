use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name         => 'Remind-Parser',
    dist_author         => 'Paul Hoffman (nkuitse AT cpan DOT org)',
    dist_version_from   => 'lib/Remind/Parser.pm',
    requires            => {},
    license             => 'perl',
    create_readme       => 0,
    create_makefile_pl  => 'traditional',
);
  
$build->create_build_script;
