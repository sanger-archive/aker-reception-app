var DATA = null;
$.ajax({url: '/materials_schema', 
	success: $.proxy(function(json) {
		DATA= {type: 'Mytype', type: 'object', properties: json };
}, this),
	async: false})

function CustomFieldTemplate(props) {
  const {id, classNames, label, help, required, description, errors, children} = props;
  return (
    <td className={classNames}>
      {description}
      {children}
      {errors}
      {help}
    </td>
  );
}


window.SchemaForm = React.createClass({ render: function() {
	var Form = JSONSchemaForm.default;
	return React.createElement('tr', {}, React.createElement(Form, {
	  schema: DATA,
	  FieldTemplate: CustomFieldTemplate 
	}));
} });
