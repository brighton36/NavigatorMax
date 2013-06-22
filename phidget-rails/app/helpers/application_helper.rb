module ApplicationHelper
  def title_from_url(url)
    t ['pages',url.tr('/','').tr('-','_'),'title'].join('.')
  end
end
