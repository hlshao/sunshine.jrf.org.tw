class Admin::CourtUpdateContext < BaseContext
  PERMITS = [:full_name, :name, :weight, :is_hidden].freeze

  before_perform :assign_value
  after_perform :assign_weight
  after_perform :remove_weight, unless: :court_sortable?
  after_perform :add_weight, if: :court_sortable?

  def initialize(court)
    @court = court
  end

  def perform(params)
    @params = permit_params(params[:admin_court] || params, PERMITS)
    run_callbacks :perform do
      return add_error(:data_update_fail, @court.errors.full_messages) unless @court.save
      true
    end
  end

  private

  def assign_value
    @court.assign_attributes @params.except(:weight)
  end

  def remove_weight
    @court.remove_from_list if @court.in_list?
  end

  def assign_weight
    @court.weight = @params[:weight].to_i if @params[:weight] && @params[:weight][/^[1-9][0-9]+$/]
  end

  def add_weight
    if @court.not_in_list?
      @court.insert_at(1)
      @court.move_to_bottom
    end
  end

  def court_sortable?
    !@court.is_hidden
  end

end
