class CreateBirds < ActiveRecord::Migration[7.1]
  def change
    create_table :birds do |t|
      t.integer :node_id
      t.integer :bird_id
      t.string :bird_name

      t.index [:node_id, :bird_id]

      t.timestamps
    end
  end
end
