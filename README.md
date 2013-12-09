# Spoilerific

This is the source distribution of Spoilerific, a web application by Jason McIntosh (jmac@jmac.org) that helps people share ROT13-encoded messages via Twitter. [A more complete justification for its existence](http://spoilerific.jmac.org/about) might be found at [http://spoilerific.jmac.org](http://spoilerific.jmac.org), the live, public instance of Spoilerific that I run for the good of mankind.

## Why's the code on GitHub?

Just for fun, and in the spirit of sharing how the web app works. Spoilerific isn't a commercial project or anything, so I have little to lose by pulling the curtain back for anyone who wishes to see the gears.

While I would react with sadness were you to run a public copy of Spoilerific under your own name, or something, I do invite you to clone or fork the code and mess around with it as much as you please for the sake of your own enlightenment.

## Contributing

If you mess around with the code to the degree that you actually end up with a patch, then feel free to share it in the form of a pull request.

## Running a local copy of Spoilerific

1. Have a fairly recent Perl handy. (Consider using `perlbrew`.)

1. Install all the CPAN modules listed as requirements in Makefile.PL. (Consider using `cpanm`.)

1. Update `t/conf/spoilerific.conf` with your application's Twitter credentials.

1. Run `prove -l lib t` and make sure all the tests pass.

1. Run `script/spoilerific_server.pl -r -d`. If it succeeds (and prints a lot of neatly formatted debug information to the terminal), you should be able to access the app at `http://localhost:3000`.

This is a Catalyst-based application; to do just about anything else with it, I commend you to [the Catalyst manual](https://metacpan.org/module/ETHER/Catalyst-Manual-5.9007/lib/Catalyst/Manual.pm) or [the Catalyst book](http://www.apress.com/9781430223658).