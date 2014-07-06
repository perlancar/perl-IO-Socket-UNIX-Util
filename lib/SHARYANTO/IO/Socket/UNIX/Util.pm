package SHARYANTO::IO::Socket::UNIX::Util;

use 5.010001;
use strict;
use warnings;

use IO::Socket::UNIX;
use POSIX qw(locale_h);

# DATE
# VERSION

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       create_unix_socket
               );

sub create_unix_socket {
    my ($path, $mode) = @_;

    my $old_locale = setlocale(LC_ALL);
    setlocale(LC_ALL, "C"); # so that error messages are in English

    # probe the Unix socket first, delete if stale
    my $sock = IO::Socket::UNIX->new(
        Type => SOCK_STREAM,
        Peer => $path,
    );
    my $err = $@ unless $sock;
    if ($sock) {
        die "Some process is already listening on $path, aborting";
    } elsif ($err =~ /^connect: permission denied/i) {
        die "Cannot access $path, aborting";
    } elsif (1) { #$err =~ /^connect: connection refused/i) {
        unlink $path;
    } elsif ($err !~ /^connect: no such file/i) {
        die "Cannot bind to $path: $err";
    }

    setlocale(LC_ALL, $old_locale);

    if (defined $mode) {
        warn "Can't chmod $path: $!" unless chmod($mode, $path);
    }

    $sock;
}

1;
# ABSTRACT: Unix domain socket utilities

=head1 FUNCTIONS

=head2 create_unix_socket($path[, $mode]) => SOCKET

Create a listening Unix socket. Die on failure.

This function creates Unix domain socket with L<IO::Socket::UNIX> with some
extra stuffs: remove stale socket first, show more detailed/precise error
message, chmod with $mode.


=head1 SEE ALSO

L<SHARYANTO>

=cut
