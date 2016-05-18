class Scrap::ImportBranchContext < BaseContext
  # TODO 更新部分還要確認, 目前就先拆開
  before_perform  :find_branch
  before_perform  :bulid_branch
  before_perform  :update_branch, unless: :is_new_record?
  before_perform  :update_missed

  def initialize(judge)
    @judge = judge
    @court = judge.court
  end

  def perform(chamber_name, branch_name)
    @chamber_name = chamber_name
    @branch_name = branch_name
    run_callbacks :perform do
      return add_error(:data_create_fail, "branch find_or_create fail") unless @branch.save
      @branch
    end
  end

  def find_branch
    @branch = Branch.includes(:court).find_by(court: @court, chamber_name: @chamber_name, name: @branch_name )
  end

  def bulid_branch
    @branch = Branch.new(court: @court, judge: @judge, chamber_name: @chamber_name, name: @branch_name ) unless @branch
  end

  def is_new_record?
    @branch.new_record?
  end

  def update_branch
    @branch.assign_attributes(judge: @judge) unless @branch.judge == @judge
  end

  def update_missed
    @branch.assign_attributes(missed: false)
  end
end
