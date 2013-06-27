module ApplicationHelper
  def tab_label(key)
    t 'main.index.tabs.%s.label' % key.tr(*%w(- _))
  end
end
