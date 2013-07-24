module ApplicationHelper
  def page_title_for(fragment)
    t ['pages',fragment.tr(*%w(- _)),'title'].join('.')
  end

  def data_table( title, rows, options = {})
    legends_for = options[:legends] || []
    columns = options[:columns] || ['','Value'] 

    [ '<h3>%s</h3>' % title,
      '<table class="%s" id="%s">' % [ 
        %w(table table-striped table-bordered table-condensed).join(' '), 
        underscore2(title)
      ],
      '<thead><tr>%s</tr></thead>' % columns.collect{|c| '<th>%s</th>' % c }.join,
      '<tbody>',
      rows.collect{|r| 
        shorthand = underscore2(r)
        '<tr><th>%s</th><td class="%s"></td></tr>' % [
          [(legends_for.include?(shorthand) ) ? legend_for(r) : nil, r].compact.join,
          shorthand ]
      },
      '</tbody>',
      '</table>' ].join.html_safe
  end

  def legend_for(column)
    ('<div class="%s"></div>' % [ 'legend_indicator' ,
      [underscore2(column), 'legend_indicator'].join('_'),
    ].join(' ')).html_safe
  end

  # Not a creative name, but this works a bit better for us than the default rails
  # underscore
  def underscore2(val)
    val.downcase.tr(' ','_').tr('^a-z0-9_','')
  end
end
