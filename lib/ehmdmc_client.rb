require 'faraday'

module EHMDMCClient

  class Validation
    # This class will store the message for the error produced by the HMDMC service provider, 
    # depending on the type of error it will generate a different content. Its purpose is to solve
    # the following problems:
    # - Publish the error message to the Logging facility to be able to track the problem
    # - Provide to the user a meaningful text indicating the problem but without giving too much
    # details about the internal process
    # - Depending on the type of error, be able to know if the validation already happened (is_validated)
    # or if we would need to retry in future, because it has not been validated
    # - Indicate, when the validation has been performed, if the hmdmc is considered valid or not
    # - Generate a valid json message for the client to display the relevant information for the user

    attr_reader :error_message, :hmdmc, :text

    def initialize(hmdmc)
      @hmdmc = hmdmc
      reset
    end

    def reset
      @validated = false
      @valid = false      
    end

    def is_validated?
      @validated
    end

    def valid?
      @validated && @valid
    end

    def log
      Rails.logger.send(@facility, @text) unless @text.nil?
    end

    def load_message(type_of_message, facility, text, validated)
      not_validated_msg = "The HMDMC #{hmdmc} is considered invalid by the HMDMC service"
      unknown_validation_msg = 'We cannot validate with the HMDMC service at this time. Please contact the administrators if the problem persists.'

      # Type of message loaded.
      # Valid values:
      # - :user_message means that the message can be displayed to the user
      # - :infrastructure_message means that the message describes some internal information that
      #      is not relevant for the user, although it is for the logging.
      @type_of_message = type_of_message 

      # Level of logging where the message will be emitted
      # Valid values: Any facility understood by Rails.logger like :info, :error, ...
      @facility = facility

      # Text with the content of the message
      @text = text

      # Indicates if this error message means that a validation process has been completed
      # Some errors (like connection failed) do not mean that the validation happened
      @validated = validated

      # This field 'valid' will indicate if the HMDMC has been considered valid or invalid by the service
      # If the service could not give an answer about it, it won't be marked as valid or invalid by the message (for example, when
      # we query the service but at that moment is down, we cannot consider it as not valid)
      @valid = @validated ?  @text.nil? : nil

      # This field 'error_message' will give as the error message that we can display to the user. 
      # There are some errors that are infrastructure-specific (json invalid, error codes, etc...) not 
      # relevant for the user. In these cases, a generic message will be provided, instead of the 
      # message loaded.
      unless @text.nil?
        if (@type_of_message == :infrastructure_message)
          @error_message = @validated ? not_validated_msg : unknown_validation_msg
        elsif (@type_of_message == :user_message)
          @error_message = @text
        end
      end

      log

      # Needs to return self
      return self
    end

    def to_json
      {valid: @valid, error_message: @error_message}.reject{|k,v| v.nil?}.to_json
    end

    def set_as_valid
      @validated = true
      @valid = true
      self
    end

    def validate(response)
      return load_message(:user_message, :info, 'Connection to HMDMC service failed', false) unless response
      return load_message(:infrastructure_message, :error, "Attempting to validate HMDMC #{hmdmc} returned status code #{response.status}", true) unless response.status == 200

      begin
        data = JSON.parse(response.body)
      rescue JSON::ParserError
        return load_message(:infrastructure_message, :error, "Attempting to validate HMDMC #{hmdmc} produced invalid JSON: #{response.body}", false)
      end

      # Error codes, from Stephen Rice:
      # 0: no error (valid)
      # 1: system error
      # 2: syntax error, i.e. malformed HMDMC number
      # 3: number has correct syntax but does not exist in system
      # 4: number does exist in system but is not approved
      # 5: valid but failed to find any product classes
      return load_message(:infrastructure_message, :info, "HMDMC rejected: #{hmdmc}, error code: #{data['errorcode']}", true) unless data['valid']

      set_as_valid
    end
  end

  def self.get_response_for_hmdmc(hmdmc)
    begin
      r = connection.get('?hmdmc=' + sanitise(hmdmc))
      return r
    rescue Faraday::ConnectionFailed => e
      return nil
    end
  end

  def self.validate_hmdmc(hmdmc)
    validator = Validation.new(hmdmc)

    response = get_response_for_hmdmc(hmdmc)

    validator.validate(response)
  end

  def self.sanitise(hmdmc)
    hmdmc.sub('/','_')
  end

  def self.connection
    Faraday.new(url: Rails.application.config.ehmdmc_url)
  end
end
