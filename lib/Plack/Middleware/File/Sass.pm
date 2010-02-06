package Plack::Middleware::File::Sass;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use parent qw(Plack::Middleware);
use Plack::Util::Accessor qw(sass);
use Plack::Util;
use Text::Sass;

sub prepare_app {
    my $self = shift;
    $self->sass(Text::Sass->new);
}

sub call {
    my($self, $env) = @_;

    # Depends on how App::File works -- not really comfortable
    my $orig_path_info = $env->{PATH_INFO};
    if ($env->{PATH_INFO} =~ s/\.css$/.sass/i) {
        my $res = $self->app->($env);

        return $res unless ref $res eq 'ARRAY';

        if ($res->[0] == 200) {
            my $sass; Plack::Util::foreach($res->[2], sub { $sass .= $_[0] });
            my $css = $self->sass->sass2css($sass);

            my $h = Plack::Util::headers($res->[1]);
            $h->set('Content-Type' => 'text/css');
            $h->set('Content-Length' => length $css);

            $res->[2] = [ $css ];
        } elsif ($res->[0] == 404) {
            $env->{PATH_INFO} = $orig_path_info;
            $res = $self->app->($env);
        }

        return $res;
    }

    return $self->app->($env);
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Plack::Middleware::File::Sass - Sass support for all Plack frameworks

=head1 SYNOPSIS

  use Plack::App::File;
  use Plack::Builder;

  builder {
      mount "/stylesheets" => builder {
          enable "File::Sass";
          Plack::App::File->new(root => "./stylesheets");
      };
  };

  # Or with Middleware::Static
  enable "File::Sass";
  enable "Static", path => qr/\.css$/, root => "./static";

=head1 DESCRIPTION

Plack::Middleware::File::Sass is a Plack middleware component that
works with L<Plack::App::File> or L<Plack::Middleware::Static> to
compile L<Sass|http://sass-lang.com/> templates into CSS stylesheet in
every request.

When a request comes in for I<.css> file, this middleware changes the
internal path to I<.sass> in the same directory. If the Sass template
is found, a new CSS stylesheet is built on memory and served to the
browsers.  Otherwise, it falls back to the original I<.css> file in
the directory.

This middleware should be very handy for the development. While Sass
to CSS rendering is reasonably fast, for the production environment
you might want to precompile Sass templates to CSS files on disk and
serves them with a real web server like nginx or lighttpd.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Plack::App::File> L<Text::Sass> L<http://sass-lang.com/>

=cut
