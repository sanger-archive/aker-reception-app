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

end
