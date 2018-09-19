# Class responsible for providing arguments to Rails' render method
# It takes a Transformer (e.g. Excel --> CSV) and uses that to provide a JSON response
class TransformedResponse

  def initialize(options = {})
    @transformer = options.fetch(:transformer)
  end

  def response
    status, json = transform
    return { status: status, json: json }
  end

private

  attr_reader :transformer, :status

  def transform
    if transformer.transform
      return :ok, { contents: transformer.contents }
    else
      return :unprocessable_entity, { errors: transformer.errors.full_messages }
    end
  end

end