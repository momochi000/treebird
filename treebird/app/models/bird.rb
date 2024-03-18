require 'csv'

class Bird < ApplicationRecord
  belongs_to :treenode, foreign_key: :node_id, optional: true

  def self.load_data(input_data)
    if input_data.is_a? File
      load_from_file(input_data)
    elsif input_data.is_a? String
      load_from_text(input_data)
    else
      raise ArgumentError.new("Error attempting to load bird data, must provide csv data as text or a valid file")
    end
  end

  private

  def self.insert_data(csv_data)
    csv_data.each do |row|
      Bird.create(
        node_id: row['node_id'].to_i,
        bird_name: row['bird_name'],
        bird_id: row['bird_id'])
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
end
