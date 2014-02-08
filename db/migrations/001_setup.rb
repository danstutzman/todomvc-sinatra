Sequel.migration do
  change do
    create_table :todo_items do
      primary_key :id
      String :title, null: false
      TrueClass :completed, null: false
    end
  end
end
