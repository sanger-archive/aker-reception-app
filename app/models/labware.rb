class Labware < ApplicationRecord
  belongs_to :material_submission
  has_one :material_reception

  scope :with_barcode, ->(barcode) { where(barcode: barcode) }

  def labware_type
    material_submission.labware_type
  end

  def increment_print_count!
    update_attributes(print_count: print_count+1)
  end

  def num_of_rows
    labware_type.num_of_rows
  end

  def num_of_cols
    labware_type.num_of_cols
  end

  def col_is_alpha
    labware_type.col_is_alpha
  end

  def row_is_alpha
    labware_type.row_is_alpha
  end

  def size
    num_of_rows * num_of_cols
  end

  def barcode_printed?
    print_count > 0
  end

  def claimed?
    claimed.present?
  end

  def ready_for_claim?
    received? && !claimed?
  end

  def received?
    material_reception.present?
  end

  def positions
    if (!col_is_alpha && !row_is_alpha)
      return (1..size).map(&:to_s)
    end

    if col_is_alpha
      x = ("A"..("A".ord + num_of_cols - 1).chr).to_a
    else
      x = (1..num_of_cols).map(&:to_s)
    end

    if row_is_alpha
      y = ("A"..("A".ord + num_of_rows - 1).chr).to_a
    else
      y = (1..num_of_rows).map(&:to_s)
    end

    y.product(x).map { |a,b| a+':'+b }
  end

  def any_human_material?
    contents && contents.any? { |address, data| material_is_human?(data) }
  end

  def ethical?
    return true unless contents
    contents.all? { |address, data| check_ethics(data) }
  end

  def set_hmdmc(hmdmc, username)
    _set_hmdmc(hmdmc, false, username)
  end

  def set_hmdmc_not_required(username)
    _set_hmdmc(nil, true, username)
  end

  def clear_hmdmc
    return if contents.nil?
    contents.each do |address, data|
      data.delete('hmdmc')
      data.delete('hmdmc_set_by')
      data.delete('hmdmc_not_required_confirmed_by')
    end
  end

  def first_hmdmc
    return nil if contents.nil?
    contents.each do |k,v|
      h = material_is_human?(v) && v['hmdmc']
      return h if h
    end
    nil
  end

  def confirmed_no_hmdmc?
    contents && contents.any? { |k,v| material_is_human?(v) && v['hmdmc_not_required_confirmed_by'].present? }
  end

private

  def _set_hmdmc(hmdmc, confirmed_not_required, username)
    return if contents.nil?
    contents.each do |address, data|
      human = material_is_human?(data)
      if human && !confirmed_not_required
        data['hmdmc'] = hmdmc
        data['hmdmc_set_by'] = username
      else
        data.delete('hmdmc')
        data.delete('hmdmc_set_by')
      end
      if human && confirmed_not_required
        data['hmdmc_not_required_confirmed_by'] = username
      else
        data.delete('hmdmc_not_required_confirmed_by')
      end
    end
  end

  def material_is_human?(material)
    species = material['scientific_name']
    species.present? && species.strip.downcase=='homo sapiens'
  end

  def check_ethics(data)
    return true unless material_is_human?(data)
    if data['hmdmc_not_required_confirmed_by']
      return !data['hmdmc_set_by'] && !data['hmdmc']
    else
      return data['hmdmc_set_by'] && data['hmdmc']
    end
  end
end
