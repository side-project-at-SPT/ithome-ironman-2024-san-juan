class MockUser
  class << self
    def find_by(id:)
      return new("visitor") unless id

      new(id)
    end
  end

  def initialize(id)
    @id = id
  end

  def id
    @id
  end

  def email
    "mock_user_#{@id}@localhost"
  end
end
