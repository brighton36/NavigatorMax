module ApplicationHelper
  def page_title_for(fragment)
    t ['pages',fragment.tr(*%w(- _)),'title'].join('.')
  end
end
