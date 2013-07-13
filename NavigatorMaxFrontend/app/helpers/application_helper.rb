module ApplicationHelper
  def page_title_for(fragment)
    t ['pages',fragment.tr(*%w(- _)),'title'].join('.')
  end

  def data_table( title, rows, columns = ['','Value'] )
    [ '<h3>%s</h3>' % title,
      '<table class="%s" id="%s">' % [ 
        %w(table table-striped table-bordered table-condensed).join(' '), 
        title.downcase.tr(' ','_')
      ],
      '<thead><tr>%s</tr></thead>' % columns.collect{|c| '<th>%s</th>' % c }.join,
      '<tbody>',
      rows.collect{|r| '<tr><th>%s</th><td class="%s"></td></tr>' % [ 
        r, r.downcase.tr(' ','_') ] },
      '</tbody>',
      '</table>' ].join.html_safe
  end
end
