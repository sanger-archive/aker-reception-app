FactoryBot.define do
  factory :manifest_uploaded_valid_state do
    initialize_with do
      {
        manifest: {
          manifest_id: 123,
          schema: schema,
          mapping: {
            matched: [
              { observed: "suppn", expected: "supplier_name" },
              { observed: "plate_id", expected: "plate_id" },
              { observed: "well_position", expected: "well_position" }
            ],
            observed: ["something_else"]
          },
          content: {
            # All data as specified by the user manifest
            raw: [ [{plate_id: "Labware 1", well_position: "A:1", suppn: "Tyranosaurus Rex", something_else: "value", gndr: "Female"}] ],
            structured: {
              labwares: {
                "Labware 1" => {
                  addresses: {
                    "A:1" => {
                      fields: {
                        "gender": {
                          value: "Female"
                        },
                        "supplier_name": {
                          value: "Tyranosaurus Rex"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    end
  end

  factory :manifest_editor_valid_state do
    initialize_with do
      {
        manifest: {
          manifest_id: 123,
          schema: schema,
          mapping: {
            matched: [
              { observed: "suppn", expected: "supplier_name" },
              { observed: "plate_id", expected: "plate_id" },
              { observed: "well_position", expected: "well_position" }
            ],
            observed: ["something_else"]
          },
          updates: {
            "Labware 1" => {
              "A:1" => {
                "supplier_name" => "Velociraptor"
              }
            }
          },
          content: {
            # All data as specified by the user manifest
            structured: {
              labwares: {
                "Labware 1" => {
                  addresses: {
                    "A:1" => {
                      fields: {
                        "supplier_name": {
                          value: "Tyranosaurus Rex"
                        }
                      }
                    },
                    "B:1" => {
                      fields: {
                        "supplier_name": {
                          value: "Triceratops"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    end
  end
end
