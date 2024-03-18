require 'rails_helper'

describe Treenode do
  let(:test_node_data) {
    <<~CSV
      id,parent_id
      125,130
      130
      2820230,125
      4430546,125
      5497637,4430546
    CSV
  }
  let(:test_node_count) { 5 }
  let(:root_node_id) { 130 }

  context 'loading data' do
    context 'from text' do
      it 'loads the data' do
        Treenode.load_data(test_node_data)
        expect(Treenode.count).to be(test_node_count)
      end
    end

    context 'from a file' do
      let(:test_node_data_file) {
        File.new(File.expand_path("../fixtures/test_nodes.csv", __dir__))
      }

      it 'loads the data' do
        Treenode.load_data(test_node_data_file)
        expect(Treenode.count).to be(test_node_count)
      end
    end
  end

  context 'querying data' do
    context 'when a tree is loaded in the db' do
      before do
        Treenode.load_data(test_node_data)
      end

      context '.get_root' do
        it 'finds the root' do
          expect(Treenode.get_root(root_node_id).node_id).to be(root_node_id)
          expect(Treenode.get_root(125).node_id).to be(root_node_id)
          expect(Treenode.get_root(2820230).node_id).to be(root_node_id)
          expect(Treenode.get_root(4430546).node_id).to be(root_node_id)
          expect(Treenode.get_root(5497637).node_id).to be(root_node_id)
        end
      end

      context '.get_ancestors' do
        it 'finds the ancestors' do
          ancestors = Treenode.get_ancestors(root_node_id).map(&:node_id)
          expect(ancestors).to eq([root_node_id])

          ancestors = Treenode.get_ancestors(125).map(&:node_id)
          expect(ancestors).to eq([125, root_node_id])

          ancestors = Treenode.get_ancestors(2820230).map(&:node_id)
          expect(ancestors).to eq([2820230, 125, root_node_id])

          ancestors = Treenode.get_ancestors(4430546).map(&:node_id)
          expect(ancestors).to eq([4430546, 125, root_node_id])

          ancestors = Treenode.get_ancestors(5497637).map(&:node_id)
          expect(ancestors).to eq([5497637, 4430546, 125, root_node_id])
        end
      end

      context '.get_descendants' do
        it 'finds the descendants' do
          descendants = Treenode.get_descendants(5497637).map(&:node_id)
          expect(descendants).to eq([5497637])

          descendants = Treenode.get_descendants(4430546).map(&:node_id)
          expect(descendants).to eq([4430546, 5497637])


          descendants = Treenode.get_descendants(125).map(&:node_id)
          expect(descendants).to eq([125, 2820230, 4430546, 5497637])
        end
      end

      context '.common_ancestor' do
        subject { described_class.common_ancestor(node_id_a, node_id_b) }
        let(:result) {subject}

        context 'when the two given nodes share a root' do
          let(:node_id_a) { 2820230 }
          let(:node_id_b) { 5497637 }

          it 'finds the shared root' do
            expect(result[:root_id]).to be(root_node_id)
          end

          it 'finds the lowest common ancestor' do
            expect(result[:lowest_common_ancestor]).to be(125)
          end

          it 'finds the correct depth' do
            expect(result[:depth]).to be(2)
          end

          context 'other test cases' do
            let(:cases) {
              [
                {
                  node_id_a: 5497637, node_id_b: root_node_id, expected_output: {
                    root_id: root_node_id,
                    lowest_common_ancestor: root_node_id,
                    depth: 1 },
                  node_id_a: 5497637, node_id_b: 4430546, expected_output: {
                    root_id: root_node_id,
                    lowest_common_ancestor: 4430546,
                    depth: 3 },
                }
              ]
            }

            it 'returns the correct results' do
              cases.each do |test_case|
                result = described_class.common_ancestor(test_case[:node_id_a], test_case[:node_id_b])

                expect(result).to eq(test_case[:expected_output])
              end
            end
          end

          context 'another test case' do
          end
        end

        context 'when the two given nodes do not share a root' do
          let(:node_id_a) { 9 }
          let(:node_id_b) { 4430546	}

          it 'returns nil for all fields' do
            expect(result[:root_id]).to be_nil
            expect(result[:lowest_common_ancestor]).to be_nil
            expect(result[:depth]).to be_nil
          end
        end

        context 'when the two given nodes are the same' do
          let(:node_id_a) { 4430546 }
          let(:node_id_b) { 4430546 }

          it 'returns itself as the common ancestor' do
            expect(result[:root_id]).to eq(root_node_id)
            expect(result[:lowest_common_ancestor]).to eq(node_id_a)
            expect(result[:depth]).to eq(3)
          end
        end

        context 'when neither node is in the tree' do
          let(:node_id_a) { 2389 }
          let(:node_id_b) { 926	}

          it 'returns nil for all fields' do
            expect(result[:root_id]).to be_nil
            expect(result[:lowest_common_ancestor]).to be_nil
            expect(result[:depth]).to be_nil
          end
        end

        context 'when given strings as input' do
          context 'and both nodes are the same' do
            let(:node_id_a) { '4430546' }
            let(:node_id_b) { '4430546' }

            it 'returns itself as the common ancestor as an integer' do
              expect(result[:root_id]).to eq(root_node_id)
              expect(result[:lowest_common_ancestor]).to eq(node_id_a.to_i)
              expect(result[:depth]).to eq(3)
            end
          end
        end
      end

      context 'when some birds are loaded in the db' do
        let(:test_bird_data_file) {
          File.new(File.expand_path("../fixtures/test_birds.csv", __dir__))
        }
        before do
          Bird.load_data(test_bird_data_file)
        end

        context 'associations' do
          context 'birds' do
            it 'returns associated birds' do
              expect(Treenode.find_by(node_id: root_node_id).birds).to eq(
                Bird.where(node_id: root_node_id)
              )
            end
          end
        end

        context '#associated_birds' do
          it 'returns all birds associated with the given node and descendants' do
            node = Treenode.find_by(node_id: 5497637)
            expect(node.associated_birds).to be_empty

            node = Treenode.find_by(node_id: 4430546)
            expect(node.associated_birds.map(&:bird_id)).to eq([423])

            node = Treenode.find_by(node_id: 2820230)
            expect(node.associated_birds.map(&:bird_id)).to eq([123])

            node = Treenode.find_by(node_id: 125)
            expect(node.associated_birds.map(&:bird_id)).to match_array([21, 12, 123, 423])
          end

          context 'when given an array of node ids' do
            let(:input) { [4430546, 2820230] }
            let(:expected_output) { [423, 123] }

            it 'returns all birds associated with the given node and descendants' do

              expect(
                Treenode.associated_birds(input).map(&:bird_id)
              ).to match_array(expected_output)
            end
          end
        end
      end
    end
  end
end
