module ApplicationHelper
  def number_to_currency_td(number)
    number_to_currency(
      number,
      format: "<td align=\"right\">%u</td><td align=\"right\">%n</td>".html_safe, 
      negative_format: "<td align=\"right\">-%u</td><td align=\"right\">%n</td>".html_safe )
  end
end
