class Search::BaseController < ApplicationController
  include CrudConcern
  before_action :init_meta

  private

  def init_meta
    set_meta
  end
end
