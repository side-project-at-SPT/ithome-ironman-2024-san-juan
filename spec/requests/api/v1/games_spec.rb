require 'swagger_helper'

RSpec.describe "Api::V1::Games", type: :request do
  path '/api/v1/games' do
    get 'List all games' do
      tags 'Games'
      produces 'application/json'

      before do
        Game.create
        Game.start_new_game
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

    post 'Create a game' do
      tags 'Games'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          seed: { type: :string, example: '1234567890abcdef', description: 'Optional' }
        }
      }

      let(:payload) { { seed: '1234567890abcdef' } }

      response '200', 'Game created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            status: { type: :string }
          },
          required: [ 'id', 'status' ]

        run_test! do
          json = JSON.parse(response.body)
          expect(json['status']).to eq('playing')
          expect(json['game_config']['seed']).to eq('1234567890abcdef')
          expect(json['game_data']['current_price']).to eq([ 1, 2, 2, 2, 3 ])
          expect(json['game_data']['supply_pile'].size).to eq(110 - 4 - 4 * 4)
          # pp json['game_data']['supply_pile'].index { |card| card == '01' }
          expect(json['game_data']['supply_pile'][27]).to eq("01")
          expect(json['game_data']['players'].size).to eq(4)
          expect(json['game_data']['players'][0]['buildings'].size).to eq(1)
          expect(json['game_data']['players'][0]['buildings'][0]['id']).to eq("01")
          # pp json['game_data']['players'].map { |player| player['id'] }
          expect(json['game_data']['current_player_index']).to eq(0)
          expect(json['game_data']['players'][0]['id']).to eq(1)
          expect(json['game_data']['players'][0]['hand'].size).to eq(4)
          expect(json['game_data']['players'][0]['hand']).to match_array([ "00", "00", "00", "00" ])

          expect(json['game_data']['roles']).to match_array([
            "Games::Roles::Builder",
            "Games::Roles::Councillor",
            "Games::Roles::Producer",
            "Games::Roles::Prospector",
            "Games::Roles::Trader"
          ])
          expect(json['game_data']['phase']).to eq('choose_role')
        end
      end
    end
  end

  path '/api/v1/games/{id}' do
    get 'Show a game' do
      tags 'Games'
      produces 'application/json'

      let(:game) { Game.start_new_game }
      let(:id) { game.id }

      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'Game found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            status: { type: :string }
          },
          required: [ 'id', 'status' ]

        run_test! do
          json = JSON.parse(response.body)
          expect(json['id']).to eq(id)
          expect(json['status']).to eq('playing')
        end
      end

      response '404', 'Game not found' do
        let(:id) { 0 }

        run_test!
      end
    end
  end

  path '/api/v1/games/{id}/roles/{role}' do
    post 'Player chooses a role' do
      tags 'Games'
      consumes 'application/json'
      produces 'application/json'

      let(:game) { Game.start_new_game(seed: '1234567890abcdef') }
      let(:id) { game.id }
      let(:role) { 'prospector' }

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :role,
                in: :path,
                description: 'Role to choose',
                enum: Games::Roles::All.map(&:demodulize).map(&:downcase).zip(
                  %w[建築師 製造商 貿易商 礦工 議員]
                ).to_h,
                schema: {
                  type: :string,
                  enum: Games::Roles::All.map(&:demodulize).map(&:downcase)
                }, required: true
      parameter name: :np,
                in: :query,
                description: 'Automatically move game state to the next player',
                schema: {
                  type: :string,
                  example: '0'
                }, required: false

      response '200', 'Choose a role successfully' do
        schema type: :object,
        properties: {
          message: { type: :string }
        },
        required: [ 'message' ]

        context 'when not automatically move game state to the next player' do
          let(:np) { '0' }

          run_test! do
            json = JSON.parse(response.body)
            expect(json['message']).to eq('你選擇了: prospector')
            expect(json['game_data']['roles']).to match_array([
              "Games::Roles::Builder",
              "Games::Roles::Councillor",
              "Games::Roles::Producer",
              "Games::Roles::Trader"
            ])
            expect(json['game_data']['phase']).to eq('prospector')

            # the prospector's privilege is to draw a card
            # so the player should have 1 more card in hand
            # current_player_index = json['game_data']['current_player_index']
            # expect(json['game_data']['players'][current_player_index]['hand'].size).to eq(5)

            # since the current player will turn to the next player, we should check the previous player's hand
            current_player_index = json['game_data']['current_player_index']
            previous_player_index = (current_player_index - 1) % 4
            expect(json['game_data']['players'][previous_player_index]['hand'].size).to eq(5)
          end
        end

        context 'when choose ++councillor' do
          let(:role) { 'councillor' }

          run_test! do
            json = JSON.parse(response.body)
            expect(json['message']).to eq('你選擇了: councillor')
            expect(json['game_data']['roles']).to match_array([
              "Games::Roles::Builder",
              "Games::Roles::Producer",
              "Games::Roles::Trader",
              "Games::Roles::Prospector"
            ])
            expect(json['game_data']['phase']).to eq('councillor')

            pp json['game_data']['players'].map { |player| player['draw_cards'] }
          end
        end
      end

      response '400', 'Game is already finished' do
        before { game.status_finished! }

        run_test!
      end

      response '422', 'Role is being taken' do
        schema type: :object,
        properties: { error: { type: :array, items: { type: :string } } },
        required: [ 'error' ]

        before do
          game.game_data['roles'].delete(Games::Roles::Prospector.to_s)
          game.save
        end

        run_test! do
          json = JSON.parse(response.body)
          expect(json['error']).to match_array([ 'Role Prospector is being taken' ])
        end
      end
    end
  end
end
