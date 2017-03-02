namespace :label_templates do
  desc "Find or register label templates in print-my-barcode"
  task setup: :environment do
    # Find the possible label templates and trigger their registration
    Dir['./lib/label_types/*'].each {|f| require f }
    puts "Label types loaded..."
    Dir['./lib/label_templates/*'].each {|f| require f }
    puts "Templates loaded..."
    LabelTemplateSetup.find_or_register_each_template!
  end
end

