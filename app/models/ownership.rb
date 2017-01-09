class Ownership
  include OwnershipClient
  extend ActiveModel::Callbacks
  define_model_callbacks :create
  before_create :create_remote_ownership

  def create_remote_ownership(obj)
  	post(obj)
  end


  def initialize(obj)
  end
  
end
