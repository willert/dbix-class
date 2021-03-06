use strict;
use warnings;

use Test::More;
use Test::Exception;
use lib qw(t/lib);
use DBICTest;

my $schema = DBICTest->init_schema();

lives_ok(sub {
  # while cds.* will be selected anyway (prefetch currently forces the result of _resolve_prefetch)
  # only the requested me.name column will be fetched.

  # reference sql with select => [...]
  #   SELECT me.name, cds.title, cds.cdid, cds.artist, cds.title, cds.year, cds.genreid, cds.single_track FROM ...

  my $rs = $schema->resultset('Artist')->search(
    { 'cds.title' => { '!=', 'Generic Manufactured Singles' } },
    {
      prefetch => [ qw/ cds / ],
      order_by => [ { -desc => 'me.name' }, 'cds.title' ],
      select => [qw/ me.name  cds.title / ],
    }
  );

  is ($rs->count, 2, 'Correct number of collapsed artists');
  my $we_are_goth = $rs->first;
  is ($we_are_goth->name, 'We Are Goth', 'Correct first artist');
  is ($we_are_goth->cds->count, 1, 'Correct number of CDs for first artist');
  is ($we_are_goth->cds->first->title, 'Come Be Depressed With Us', 'Correct cd for artist');
}, 'explicit prefetch on a keyless object works');


lives_ok(sub {
  # test implicit prefetch as well

  my $rs = $schema->resultset('CD')->search(
    { title => 'Generic Manufactured Singles' },
    {
      join=> 'artist',
      select => [qw/ me.title artist.name / ],
    }
  );

  my $cd = $rs->next;
  is ($cd->title, 'Generic Manufactured Singles', 'CD title prefetched correctly');
  isa_ok ($cd->artist, 'DBICTest::Artist');
  is ($cd->artist->name, 'Random Boy Band', 'Artist object has correct name');

}, 'implicit keyless prefetch works');

# sane error
throws_ok(
  sub {
    $schema->resultset('Track')->search({}, { join => { cd => 'artist' }, '+columns' => 'artist.name' } )->next;
  },
  qr|\QCan't inflate manual prefetch into non-existent relationship 'artist' from 'Track', check the inflation specification (columns/as) ending in 'artist.name'|,
  'Sensible error message on mis-specified "as"',
);

# check complex limiting prefetch without the join-able columns
{
  my $pref_rs = $schema->resultset('Owners')->search({}, {
    rows => 3,
    offset => 1,
    columns => 'name',  # only the owner name, still prefetch all the books
    prefetch => 'books',
  });

  lives_ok {
    is ($pref_rs->all, 1, 'Expected count of objects on limtied prefetch')
  } "Complex limited prefetch works with non-selected join condition";
}


done_testing;
