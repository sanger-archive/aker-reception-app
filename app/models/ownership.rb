class Ownership
  include OwnershipClient
  include ActiveModel::Model

  # define_model_callbacks :create
  # before_create :create_remote_ownership

  validates :model_id,   presence: true, length: { maximum: 36 }
  validates :model_type, presence: true
  validates :owner_id,   presence: true

  # obj = {:model_id => SecureRandom.uuid, :model_type => 'bio', :owner_idd => 'hc6@sanger.ac.uk'}
  def create_remote_ownership(obj)
  	post(obj)
  end

  # obj = 'b7a32344-cd0b-4b46-b986-48c1888c99a1'
  def get_remote_ownership(obj)
  	get(obj)
  end

end
