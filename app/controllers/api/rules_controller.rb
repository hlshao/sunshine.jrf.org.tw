class Api::RulesController < Api::BaseController

  def index
    context = Story::FindContext.new(params[:court_code], params[:id])
    @story = context.perform
    return respond_error(context.error_messages.join(','), 404) unless @story
    @court = @story.court
    @rules = @story.rules.search_sort
    return respond_error('此案件尚未有裁決書', 404) unless @rules.present?
  end
end
