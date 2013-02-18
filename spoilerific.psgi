use strict;
use warnings;

use FindBin::libs;
use Spoilerific;

my $app = Spoilerific->apply_default_middlewares(Spoilerific->psgi_app);
$app;

