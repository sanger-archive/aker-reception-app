class Ownership
  include OwnershipClient
  include ActiveModel::Model

  # define_model_callbacks :create
  # before_create :create_remote_ownership

  validates :model_id,   presence: true, length: { maximum: 36 }
  validates :model_type, presence: true
  validates :owner_id,   presence: true

  attr_accessor :model_id, :model_type, :owner_id

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) if respond_to?("#{name}=")
    end
  end

  # params = {:model_id => SecureRandom.uuid, :model_type => 'bio', :owner_id => 'hc6@sanger.ac.uk'}
  def self.create_remote_ownership(params)
  	create OwnershipClient::post(params)
  end

  # obj = 'b7a32344-cd0b-4b46-b986-48c1888c99a1'
  def self.get_remote_ownership(uuid)
  	create OwnershipClient::get(uuid)
  end

  private

  def self.create(obj)
    # filter form json, reject method
    Ownership.new(model_id: obj["model_id"], model_type: obj["model_type"], owner_id: obj["owner_id"], x: obj["x"])
  end

end
