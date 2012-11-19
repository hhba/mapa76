class Register
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::References

  def self.actions
    ActionEntity::VERBS
  end
end
