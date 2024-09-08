require 'swagger_helper'

RSpec.describe "Api::V1::Games", type: :request do
  path '/api/v1/games' do
    get 'List all games' do
      tags 'Games'
      produces 'application/json'

      before do
        Game.create
        Game.create(status: 'playing')
      end

      response '200', 'Games found' do
        schema type: :object,
          properties: {
            games: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  status: { type: :string }
                },
                required: [ 'id', 'status' ]
              }
            }
          },
          required: [ 'games' ]

        run_test! do
          json = JSON.parse(response.body)
          expect(json['games'].size).to eq(2)
          expect(json['games'].any? { |game| game['status'] == 'unknown' }).to be_truthy
          expect(json['games'].any? { |game| game['status'] == 'playing' }).to be_truthy
        end
      end
    end
  end
end
