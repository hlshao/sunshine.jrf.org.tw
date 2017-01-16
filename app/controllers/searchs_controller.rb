class SearchsController < BaseController
  def index
    set_meta(image: ActionController::Base.helpers.asset_path('hero-searchs-index-M.png'))
  end

  def suits
    get_params_utf8(['q', 'state'])
    @suit = Suit.shown.find_state(params_utf8[:state]).front_like_search(title: params_utf8[:q], summary: params_utf8[:q], content: params_utf8[:q], keyword: params_utf8[:q]).page(params[:page]).per(12)
    set_meta(image: ActionController::Base.helpers.asset_path('hero-searchs-index-M.png'))
  end

  def judges
    get_params_utf8(['q', 'judge'])
    @judges = Judge.shown.where(court: Court.find_by(full_name: params_utf8[:judge])).ransack(name_cont: params_utf8[:q]).result.order(:name).page(params[:page]).per(12)
    set_meta(image: ActionController::Base.helpers.asset_path('hero-searchs-index-M.png'))
  end

  def prosecutors
    get_params_utf8(['q', 'prosecutor'])
    @prosecutors = Prosecutor.shown.where(prosecutors_office: ProsecutorsOffice.find_by(full_name: params_utf8[:prosecutor])).ransack(name_cont: params_utf8[:q]).result.order(:name).page(params[:page]).per(12)
    set_meta(
      title: '檢察官搜尋結果',
      description: '檢察官搜尋結果，快來看看有哪些檢察官資料！',
      keywords: '找檢察官,檢察官,檢察署',
      image: ActionController::Base.helpers.asset_path('hero-searchs-index-M.png')
    )
  end

end
