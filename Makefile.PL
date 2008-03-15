use inc::Module::Install;

name 'Bot-Synopsis';
all_from 'lib/Bot/Synopsis.pm';

build_requires 'Test::More';
build_requires 'ok';

WriteAll();
