class AddIndicesToTreenodes < ActiveRecord::Migration[7.1]
  def change
    add_index :treenodes, :node_id
    add_index :treenodes, :parent_id
  end
end
