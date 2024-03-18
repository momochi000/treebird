class TreeController < ApplicationController
  def common_ancestor
    a = params['a']
    b = params['b']

    unless a.present? && b.present?
      return render json: { error: "Params a and/or b were missing" }, status: :bad_request
    end

    render json: Treenode.common_ancestor(a, b)
  end

  def birds
    node_ids = JSON.parse(params['node_ids'])
    out = Treenode.associated_birds(node_ids)
    render json: {bird_ids: out.map(&:bird_id)}
  rescue Exception => _
    render json: { error: "Improperly formatted params, please pass as a valid json array of integers representing node ids" }, status: :bad_request
  end
end
