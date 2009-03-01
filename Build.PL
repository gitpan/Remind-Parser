use strict;
use warnings;

use Module::Build;

my $has_yaml;
eval { require YAML; $has_yaml = 1; };

my $build = Module::Build->new(
    'module_name'        => 'Remind-Parser',
    'dist_author'        => 'Paul Hoffman (nkuitse AT cpan DOT org)',
    'dist_version_from'  => 'lib/Remind/Parser.pm',
    'requires'           => {},
    'recommends'         => { 'YAML' => 0, },
    'build_requires'     => {
        'Test::More' => 0,
        'Data::Dumper' => 0,
    },
    'license'            => 'perl',
    'create_readme'      => 0,
    'create_makefile_pl' => 'traditional',
);

if ($has_yaml) {
    $build->script_files(['script/rem2yaml']);
}
else {
    print STDERR "YAML is not available, so rem2yaml will not be installed\n";
}

$build->create_build_script;
