Sequel.migration do
  change do
    create_table(:schema_info) do
      Integer :version, :default=>0, :null=>false
    end
    
    create_table(:users) do
      primary_key :id
      String :name, :text=>true
    end
  end
end
