Sequel.migration do
  change do
    create_table :todo_items do
      column :id, :uuid, null: false
      String :title, null: false
      TrueClass :completed, null: false
      primary_key [:id]
    end
  end
end
