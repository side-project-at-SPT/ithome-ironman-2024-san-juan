require 'swagger_helper'

RSpec.describe 'WalkingSkeleton', type: :request do
  path '/walking-skeleton' do
    get 'Examine the walking skeleton' do
      tags 'Walking Skeleton'
      produces 'application/json'

      response '200', 'Walk' do
        schema type: :object,
          properties: {
            message: { type: :string }
          },
          required: [ 'message' ]

        run_test!
      end
    end
  end
end
