class Ownership
  include OwnershipClient
  include ActiveModel::Model

  # define_model_callbacks :create
  # before_create :create_remote_ownership

  validates :model_id,   presence: true, length: { maximum: 36 }
  validates :model_type, presence: true
  validates :owner_id,   presence: true

  attr_accessor :model_id, :model_type, :owner_id

  # params = {:model_id => SecureRandom.uuid, :model_type => 'bio', :owner_id => 'hc6@sanger.ac.uk'}
  def self.create_remote_ownership(params)
  	create OwnershipClient::post(params)
  end

  # params = [{model_id: SecureRandom.uuid, model_type: 'bio', owner_id: 'hc6@sanger.ac.uk'},{model_id: SecureRandom.uuid, model_type: 'bio', owner_id: 'hc6@sanger.ac.uk'}]
  def self.create_remote_ownership_batch(params)
    create_batch OwnershipClient::post_batch(params)
  end

  # obj = 'b7a32344-cd0b-4b46-b986-48c1888c99a1'
  def self.get_remote_ownership(uuid)
  	create OwnershipClient::get(uuid)
  end

  private

  def self.create_batch(obj)
    obj.map { |item| create(item) }
  end

  def self.create(obj)
    new filter(obj)
  end

  def self.filter(h)
    {:model_id => h["model_id"], :model_type => h["model_type"], :owner_id => h["owner_id"]}
  end

end
