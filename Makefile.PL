use inc::Module::Install;

name 'Bot-Synopsis';
all_from 'lib/Bot/Synopsis.pm';

requires 'Moose';
requires 'Adam';
requires 'Moses';
requires 'Web::Scraper';

build_requires 'Test::More';
build_requires 'ok';

WriteAll();
