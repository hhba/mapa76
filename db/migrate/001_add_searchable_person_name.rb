class AddSearchablePersonName < Sequel::Migration
  def up
    alter_table(:people) do
      rename_column :name, :searchable_name
      add_column  :name,  String
    end
  end

  def down
    alter_table(:people) do
      drop_column :people, :name
      rename_column :searchable_name, :name
    end
  end
end
