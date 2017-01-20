require './lib/label_template_setup'

# Same label type defininion that Sequencescape uses currently (20/Jan/2017)
LabelTemplateSetup.register_label_type("Tube", {
    type: "label_types",
    attributes: {
    	"feed_value":"008",
    	"fine_adjustment":"10",
    	"pitch_length":"0430",
		"print_width":"0300",
		"print_length":"0400",
		"name":"Tube"
		}
	}
)

