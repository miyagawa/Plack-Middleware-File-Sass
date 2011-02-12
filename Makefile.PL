use inc::Module::Install;
name 'Plack-Middleware-File-Sass';
all_from 'lib/Plack/Middleware/File/Sass.pm';
readme_from 'lib/Plack/Middleware/File/Sass.pm';
build_requires 'Test::More';
test_requires 'Test::Requires';
requires 'Plack::App::File';
requires 'Text::Sass::Expr'; # Temporary hack till Text::Sass is fixed on PAUSE
auto_include_deps;
author_tests('xt');
auto_set_repository;
WriteAll;
