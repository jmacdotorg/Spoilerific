use strict;
use warnings;

use Spoilerific;

my $app = Spoilerific->apply_default_middlewares(Spoilerific->psgi_app);
$app;

