package # hide from PAUSE 
    DBICTest::Schema::Artist;

use base 'DBIx::Class::Core';

__PACKAGE__->table('artist');
__PACKAGE__->source_info({
    "source_info_key_A" => "source_info_value_A",
    "source_info_key_B" => "source_info_value_B",
    "source_info_key_C" => "source_info_value_C",
});
__PACKAGE__->add_columns(
  'artistid' => {
    data_type => 'integer',
    is_auto_increment => 1,
	bind_attributes => { testkey1 => 1},
  },
  'name' => {
    data_type => 'varchar',
    size      => 100,
    is_nullable => 1,
	bind_attributes => {testkey2 =>2},
  },
);
__PACKAGE__->set_primary_key('artistid');

__PACKAGE__->mk_classdata('field_name_for', {
    artistid    => 'primary key',
    name        => 'artist name',
});

__PACKAGE__->has_many(
    cds => 'DBICTest::Schema::CD', undef,
    { order_by => 'year' },
);

__PACKAGE__->has_many( twokeys => 'DBICTest::Schema::TwoKeys' );
__PACKAGE__->has_many( onekeys => 'DBICTest::Schema::OneKey' );

__PACKAGE__->has_many(
  artist_undirected_maps => 'DBICTest::Schema::ArtistUndirectedMap',
  [ {'foreign.id1' => 'self.artistid'}, {'foreign.id2' => 'self.artistid'} ],
  { cascade_copy => 0 } # this would *so* not make sense
);

1;
