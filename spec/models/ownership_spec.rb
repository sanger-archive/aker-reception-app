require 'rails_helper'

describe Ownership, type: :model do
	include ActiveModel::Lint::Tests
 	
  	it_should_behave_like "ActiveModel"	
end
