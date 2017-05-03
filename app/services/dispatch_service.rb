class DispatchService

  def process(list)
    passed = []
    list.each do |service|
      if service.up
        passed.push(service)
      else
        passed.reverse.each do |p|
          p.down
        end
        return false
      end
    end
    true
  end

  # def process(material_submission)
  #   SetClientService.new.up(material_submission)
  #   EmailService(material_submissions)
  # end

end


# class ServiceProcess

# end


# class SetClientService

#   def up(material_submission)

#   end

#   def down
#   end

# end