class CreateTreenodes < ActiveRecord::Migration[7.1]
  def change
    create_table :treenodes do |t|
      t.integer :node_id
      t.integer :parent_id

      t.timestamps
    end
  end
end
