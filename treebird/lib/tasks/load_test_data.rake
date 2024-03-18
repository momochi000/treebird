require 'rake'
require 'rails'

desc 'Load test node data and bird data into the database. This clears existing data. It only includes 5 nodes and 5 birds'
task load_test_data: :environment do
  Treenode.delete_all
  Bird.delete_all

  test_node_data_file = File.new(Rails.root.join("..", "data", "test_nodes.csv"))
  Treenode.load_data(test_node_data_file)
  test_bird_data_file = File.new(Rails.root.join("..", "data", "test_birds.csv"))
  Bird.load_data(test_bird_data_file)
end

desc 'Load tree node data as given in the assignment packet. This will also delete existing data'
task load_data: :environment do
  Treenode.delete_all
  Bird.delete_all

  test_node_data_file = File.new(Rails.root.join("..", "data", "nodes.csv"))
  Treenode.load_data(test_node_data_file)
end
