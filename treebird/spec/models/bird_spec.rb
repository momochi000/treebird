require 'rails_helper'

describe Bird do
  let(:test_bird_data) {
    <<~CSV
      node_id,bird_name,bird_id
      125,ginger,21
      2820230,cucumber,123
      130,trixie,1
      125,hilda,12
      4430546,jojo,423
    CSV
  }
  let(:test_bird_count) { 5 }

  context 'loading data' do
    context 'from text' do
      it 'loads the data' do
        Bird.load_data(test_bird_data)
        expect(Bird.count).to be(test_bird_count)
      end
    end

    context 'from a file' do
      let(:test_bird_data_file) {
        File.new(File.expand_path("../fixtures/test_birds.csv", __dir__))
      }

      it 'loads the data' do
        Bird.load_data(test_bird_data)
        expect(Bird.count).to be(test_bird_count)
        expect(Bird.first.node_id).not_to be_nil
        expect(Bird.first.bird_name).not_to be_nil
        expect(Bird.first.bird_id).not_to be_nil
      end
    end
  end
end
