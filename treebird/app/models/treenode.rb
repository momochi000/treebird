require 'csv'

class Treenode < ApplicationRecord
  has_many :birds, foreign_key: :node_id, primary_key: :node_id

  # Return all birds associated with the given nodes and their descendants
  def self.associated_birds(node_ids)
    sql =
      <<-SQL
        WITH RECURSIVE outer_tree AS (
          SELECT *
          FROM treenodes
          WHERE node_id in (?)
          UNION ALL
            SELECT subtree.*
            FROM treenodes subtree
              JOIN outer_tree
                ON subtree.parent_id = outer_tree.node_id
        )
        SELECT birds.*
        FROM outer_tree
        JOIN birds
          ON outer_tree.node_id = birds.node_id
        ;
      SQL

    sql = ActiveRecord::Base.sanitize_sql_array([sql, node_ids])

    ActiveRecord::Base.connection.exec_query(sql)
      .map {|row| Bird.new(row)}
      .uniq
  end

  # Return the nearest common ancestor to the given pair of nodes (given as ids)
  def self.common_ancestor(node_id_a, node_id_b)
    path_from_a = get_ancestors(node_id_a)
    if node_id_a == node_id_b
      return {
        root_id: path_from_a.last.node_id,
        lowest_common_ancestor: node_id_a.to_i,
        depth: path_from_a.length
      }
    end

    path_from_b = get_ancestors(node_id_b)

    if path_from_a.empty? || path_from_b.empty? || path_from_a.last != path_from_b.last
      return common_ancestor_empty_result
    end

    a_to_root = path_from_a.reverse
    b_to_root = path_from_b.reverse

    root_id = a_to_root.first.node_id
    curr_lca = nil
    curr_depth = 0

    while true
      curr_a = a_to_root[curr_depth]
      curr_b = b_to_root[curr_depth]
      break if curr_a != curr_b
      curr_lca = curr_a
      curr_depth +=1
    end

    {
      root_id: root_id,
      lowest_common_ancestor: curr_lca.node_id,
      depth: curr_depth
    }
  end

  # Get the list of ancestors of a given node (given as id)
  def self.get_ancestors(starting_node_id)
    result = ancestor_query(starting_node_id)
    result.map {|row| Treenode.new(row)}
  end

  # Get the list of descendants of a given node (given as id)
  def self.get_descendants(starting_node_id)
    sql =
      <<-SQL
        WITH RECURSIVE subtree AS (
          SELECT *
          FROM treenodes
          WHERE node_id = ?
          UNION ALL
            SELECT t.*
            FROM treenodes t
              JOIN subtree
                ON t.parent_id = subtree.node_id
        ) SELECT * FROM subtree;
      SQL

    ActiveRecord::Base.connection.exec_query(sql, 'node_id', [starting_node_id])
      .map {|row| Treenode.new(row)}
  end

  # Return the root node (of a given id)
  def self.get_root(starting_node_id)
    result = ancestor_query(starting_node_id)
    final_node = result.to_a.last
    Treenode.new(final_node)
  end

  # Takes either raw csv data as a string or a csv File object and loads it
  # into the database.
  def self.load_data(input_data)
    if input_data.is_a? File
      load_from_file(input_data)
    elsif input_data.is_a? String
      load_from_text(input_data)
    else
      raise ArgumentError.new("Error attempting to load node data, must provide csv data as text or a valid file")
    end
  end

  # return all birds associated with this node and it's descendants
  def associated_birds
    # while this is nice and clean, it results in n+1 queries
    #descendants.map { |node| node.birds}.flatten

    sql =
      <<-SQL
        WITH RECURSIVE outer_tree AS (
          SELECT *
          FROM treenodes
          WHERE node_id = ?
          UNION ALL
            SELECT subtree.*
            FROM treenodes subtree
              JOIN outer_tree
                ON subtree.parent_id = outer_tree.node_id
        )
        SELECT birds.*
        FROM outer_tree
        JOIN birds
          ON outer_tree.node_id = birds.node_id
        ;
      SQL

    ActiveRecord::Base.connection.exec_query(sql, 'node_id', [self.node_id])
      .map {|row| Bird.new(row)}
  end

  def descendants
    Treenode.get_descendants(self.node_id)
  end

  def root
    Treenode.get_root(self.node_id)
  end

  private

  def self.ancestor_query(starting_node_id)
    sql =
      <<-SQL
        WITH RECURSIVE subtree AS (
          SELECT *
          FROM treenodes
          WHERE node_id = ?
          UNION ALL
            SELECT t.*
            FROM treenodes t
              JOIN subtree
                ON subtree.parent_id = t.node_id
        ) SELECT * FROM subtree;
      SQL

    ActiveRecord::Base.connection.exec_query(sql, 'node_id', [starting_node_id])
  end

  # TODO: speed this up by doing a bulk insert.
  def self.insert_data(csv_data)
    csv_data.each do |row|
      node_id = row['id'].to_i
      parent_id = row['parent_id'] ? row['parent_id'].to_i : nil
      Treenode.create(node_id: node_id, parent_id: parent_id)
    end
  end

  def self.load_from_file(file)
    csv = CSV.open(file, headers: :first_row)
    insert_data(csv)
  end

  def self.load_from_text(raw_data)
    csv = CSV.new(raw_data, headers: :first_row)
    insert_data(csv)
  end

  def self.common_ancestor_empty_result
    {
      root_id: nil,
      lowest_common_ancestor: nil,
      depth: nil
    }
  end
end
