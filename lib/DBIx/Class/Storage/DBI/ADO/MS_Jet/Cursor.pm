package DBIx::Class::Storage::DBI::ADO::MS_Jet::Cursor;

use strict;
use warnings;
use base 'DBIx::Class::Storage::DBI::Cursor';
use mro 'c3';
use DBIx::Class::Storage::DBI::ADO::CursorUtils '_normalize_guids';
use namespace::clean;

=head1 NAME

DBIx::Class::Storage::DBI::ADO::MS_Jet::Cursor - GUID Support for MS Access over
ADO

=head1 DESCRIPTION

This class is for normalizing GUIDs retrieved from Microsoft Access over ADO.

You probably don't want to be here, see
L<DBIx::Class::Storage::DBI::ACCESS> for information on the Microsoft
Access driver.

Unfortunately when using L<DBD::ADO>, GUIDs come back wrapped in braces, the
purpose of this class is to remove them.
L<DBIx::Class::Storage::DBI::ADO::MS_Jet> sets
L<cursor_class|DBIx::Class::Storage::DBI/cursor_class> to this class by default.
It is overridable via your
L<connect_info|DBIx::Class::Storage::DBI/connect_info>.

You can use L<DBIx::Class::Cursor::Cached> safely with this class and not lose
the GUID normalizing functionality,
L<::Cursor::Cached|DBIx::Class::Cursor::Cached> uses the underlying class data
for the inner cursor class.

=cut

sub _dbh_next {
  my ($storage, $dbh, $self) = @_;

  my $next = $self->next::can;

  my @row = $next->(@_);

  my $col_infos = $storage->_resolve_column_info($self->args->[0]);

  my $select = $self->args->[1];

  _normalize_guids($select, $col_infos, \@row, $storage);

  return @row;
}

sub _dbh_all {
  my ($storage, $dbh, $self) = @_;

  my $next = $self->next::can;

  my @rows = $next->(@_);

  my $col_infos = $storage->_resolve_column_info($self->args->[0]);

  my $select = $self->args->[1];

  _normalize_guids($select, $col_infos, $_, $storage) for @rows;

  return @rows;
}

1;

=head1 AUTHOR

See L<DBIx::Class/AUTHOR> and L<DBIx::Class/CONTRIBUTORS>.

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

# vim:sts=2 sw=2:
