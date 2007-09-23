use strict;
use warnings;

use Test::More;

$| = 1;

eval "use Test::Pod::Coverage 1.00";

plan 'skip_all' => "Test::Pod::Coverage 1.00 required for testing POD coverage"
    if $@;

all_pod_coverage_ok();

