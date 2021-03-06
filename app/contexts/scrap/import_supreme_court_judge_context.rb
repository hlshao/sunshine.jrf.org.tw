class Scrap::ImportSupremeCourtJudgeContext < BaseContext
  before_perform  :parse_data
  before_perform  :build_judge
  after_perform   :import_branch
  after_perform   :record_import_daily_branch

  def initialize(data_array)
    @data_array = data_array
    @court = Court.find_or_create_by(full_name: '最高法院', code: 'TPS')
  end

  def perform
    run_callbacks :perform do
      return add_error(:scrap_judge_create_fail) unless @judge.save
      @judge
    end
  end

  private

  def parse_data
    @judge_name, @branch_name, @chamber_name = @data_array
  end

  def build_judge
    @judge = @court.judges.find_or_initialize_by(name: @judge_name)
  end

  def import_branch
    @branch = Scrap::ImportBranchContext.new(@judge).perform(@chamber_name, @branch_name)
  end

  def record_import_daily_branch
    Redis::List.new('import_supreme_branch_ids') << @branch.id
  end
end
